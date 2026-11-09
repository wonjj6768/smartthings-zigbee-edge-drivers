-- MEG5779: ZHC cff1de4731a14a84094a8568d8bbf92aa5feb0db.
-- BEGIN PURE CODEC
local function scalar(value)
  return type(value) == "table" and value.value or value
end
local function finite(value, minimum, maximum)
  return type(value) == "number" and value == value and value >= minimum and value <= maximum
end
local function setpoint_wire(value)
  if not finite(value, 4, 30) then return end
  -- Exact decision boundary of Math.round(Number((value*2).toFixed(1))).
  -- Compare the binary64 value against n+9/20 without introducing another rounding.
  local doubled = value * 2
  local whole = math.floor(doubled)
  local bits = string.unpack("<I8", string.pack("<d", doubled))
  local exponent = ((bits >> 52) & 0x7FF) - 1022
  local mantissa = (bits & 0xFFFFFFFFFFFFF) | 0x10000000000000
  if mantissa * 20 >= (whole * 20 + 9) * (1 << (53 - exponent)) then whole = whole + 1 end
  return whole * 50
end
local function demand_percent(value)
  return math.floor(scalar(value) * 100 / 255 + 0.5)
end
-- END PURE CODEC
local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local helpers = require "contracts.helpers.family"
local capabilities = require "st.capabilities"
local types = require "st.zigbee.data_types"
local base = require "st.zigbee.cluster_base"
local THERMOSTAT, UI, MANUFACTURER = 0x0201, 0x0204, 0x105E
local definitions, register = helpers.definition_registry()
local mappings, commands, writers = {}, {}, {}

local function custom(name)
  return assert(emit[name], "Missing actual MEG5779 generated metadata: " .. name)()
end
local function publish(device, event, component)
  if event then device:emit_component_event({id = component or "main"}, event) end
end
local function flags(tx)
  tx.body.zcl_header.frame_ctrl:set_disable_default_response()
  return tx
end
local function endpoints(device, cluster)
  local result = {}
  for _, endpoint in pairs(device.zigbee_endpoints or {}) do
    if device:supports_server_cluster(cluster, endpoint.id) then result[#result + 1] = endpoint.id end
  end
  table.sort(result)
  return result
end
local function read(device, cluster, attribute, manufacturer, endpoint)
  local tx = manufacturer and base.read_manufacturer_specific_attribute(device, cluster, attribute, manufacturer)
    or base.read_attribute(device, types.ClusterId(cluster), types.AttributeId(attribute))
  device:send(flags(tx:to_endpoint(endpoint or device:get_endpoint(cluster))))
end
local function write(device, cluster, attribute, kind, value, manufacturer, endpoint)
  local tx = manufacturer and base.write_manufacturer_specific_attribute(device, cluster, attribute, manufacturer, kind, value)
    or base.write_attribute(device, types.ClusterId(cluster), types.AttributeId(attribute), kind(value))
  -- API16 send is an enqueue operation with no write-completion result.
  -- Never publish the requested value from this return. Existing RX mappings
  -- publish only the actual device readback/report; no ACK queue or TSN owner.
  if not pcall(device.send, device, flags(tx:to_endpoint(endpoint or device:get_endpoint(cluster)))) then return false end
  return pcall(read, device, cluster, attribute, manufacturer, endpoint)
end
local function command(cap, cmd, mapping, arg, value)
  commands[#commands + 1] = {capability_id = cap, command_name = cmd, mapping_name = mapping, argument_name = arg, value = value}
end
local function add(cluster, attribute, name, kind, from, emitter, options)
  options = options or {}
  options.name, options.data_type, options.from_device, options.emit = name, kind, from, emitter
  options.read_on_configure, options.read_on_refresh = false, false
  if options.read_only == nil then options.read_only = true end
  local mapping = zcl.cluster_attribute(cluster, attribute, options)
  mappings[#mappings + 1] = mapping
  return mapping
end
local function temperature(guard)
  return function(value, _, context, mapping)
    local rx = context and context.zb_rx
    local records = rx and rx.body and rx.body.zcl_body and rx.body.zcl_body.attr_records
    for _, record in ipairs(records or {}) do
      if record.attr_id.value == mapping.attribute_id and record.data == context.typed_value then
        -- API16 augmentation can hide a different reported datatype on record.data.
        if (record.status and record.status.value ~= 0) or not record.data_type or record.data_type.value ~= 0x29 then return end
        value = scalar(value)
        -- 0x8000 is not a temperature state. Do not turn invalid into -327.68 C.
        if not finite(value, -32767, 32767) or value % 1 ~= 0 then return end
        value = value / 100
        if not guard or value >= -273.15 then return value end
        return
      end
    end
  end
end
local function lookup(values)
  return function(value) return values[scalar(value)] end
end

local local_temp = add(THERMOSTAT, 0, "meg5779_local_temperature", types.Int16, temperature(true), emit.temperature("C"))
local_temp.reporting_defaults = {minimum_interval = 0, maximum_interval = 3600, reportable_change = 10}
local setpoints = {
  {0x12, "main", emit.heating_setpoint("C"), true},
  {0x14, "unoccupied", emit.heating_setpoint("C"), false},
  {0x11, "main", emit.cooling_setpoint("C"), false},
  {0x13, "unoccupied", emit.cooling_setpoint("C"), false},
}
for _, row in ipairs(setpoints) do
  local mapping = add(THERMOSTAT, row[1], "meg5779_setpoint_" .. row[1], types.Int16, temperature(row[4]), row[3], {
    component = row[2], endpoint = function(device) return device:get_endpoint(THERMOSTAT) end,
  })
  mapping.reporting_defaults = {minimum_interval = 0, maximum_interval = 3600, reportable_change = 10}
end
for _, row in ipairs({{"heat", "thermostatHeatingSetpoint", "heatingSetpoint", 0x12, 0x14}, {"cool", "thermostatCoolingSetpoint", "coolingSetpoint", 0x11, 0x13}}) do
  local route = "meg5779_" .. row[1] .. "_setpoint"
  writers[route] = function(device, value, request)
    local component = request.component or "main"
    if component ~= "main" and component ~= "unoccupied" then return false end
    local encoded = setpoint_wire(value)
    if encoded == nil then return false end
    return write(device, THERMOSTAT, component == "main" and row[4] or row[5], types.Int16, encoded)
  end
  command(row[2], row[1] == "heat" and "setHeatingSetpoint" or "setCoolingSetpoint", route, "setpoint")
end

local modes = {[0] = "off", [3] = "cool", [4] = "heat"}
local mode_map = add(THERMOSTAT, 0x1C, "meg5779_mode_rx", types.Enum8, lookup(modes), emit.thermostat_mode())
mode_map.reporting_defaults = {minimum_interval = 0, maximum_interval = 3600}
writers.meg5779_mode = function(device, value)
  local encoded = ({off = 0, cool = 3, heat = 4})[value]
  if encoded == nil then return false end
  return write(device, THERMOSTAT, 0x1C, types.Enum8, encoded)
end
command("thermostatMode", "setThermostatMode", "meg5779_mode", "mode")
for _, mode in ipairs({"off", "heat", "cool"}) do command("thermostatMode", mode, "meg5779_mode", nil, mode) end

local demand = add(THERMOSTAT, 8, "meg5779_heatDemand", types.Uint8, demand_percent, custom("meg5779HeatDemand"))
demand.reporting_defaults = {minimum_interval = 0, maximum_interval = 3600, reportable_change = 0}
-- Passive native reports remain understood; neither GET nor ConfigureReporting uses0029.
local native_states = {[0]="idle",[1]="heating",[2]="cooling",[4]="fan only",[5]="heating",[6]="cooling",[8]="heating",[9]="heating",[10]="cooling",[12]="cooling",[14]="cooling",[15]="cooling",[22]="cooling",[33]="heating",[34]="cooling",[65]="heating",[66]="cooling",[32768]="idle",[32769]="heating"}
add(THERMOSTAT, 0x29, "meg5779_native_state_rx", types.Bitmap16, lookup(native_states), emit.thermostat_operating_state())

local settings = {
  {THERMOSTAT,0x15,types.Int16,"meg5779HeatMin","heatMin",nil,4,30,true,true},
  {THERMOSTAT,0x16,types.Int16,"meg5779HeatMax","heatMax",nil,4,30,true,true},
  {THERMOSTAT,0x17,types.Int16,"meg5779CoolMin","coolMin",nil,4,30,true,false},
  {THERMOSTAT,0x18,types.Int16,"meg5779CoolMax","coolMax",nil,4,30,true,false},
  {UI,0xE000,types.Uint8,"meg5779ActiveBrightness","activeBrightness",MANUFACTURER,0,100},
  {UI,0xE001,types.Uint8,"meg5779InactiveBrightness","inactiveBrightness",MANUFACTURER,0,100},
  {UI,0xE002,types.Uint16,"meg5779DisplayTimeout","displayTimeout",MANUFACTURER,5,600},
}
for _, row in ipairs(settings) do
  local emitter = custom(row[4])
  local route = "meg5779_" .. row[5]
  -- Cooling limits preserve the signed16 numeric carrier; Table6-13 range is audited separately.
  local mapping = add(row[1], row[2], route, row[3], row[9] and temperature(row[10]) or scalar, emitter, {read_only = false, mfg_code = row[6]})
  mapping.sender = function(device, _, value)
    if not finite(value, row[7], row[8]) then return false end
    local encoded = row[9] and setpoint_wire(value) or math.modf(value)
    return write(device, row[1], row[2], row[3], encoded, row[6])
  end
  command("concertmirror08464." .. row[4], "set" .. row[5]:sub(1,1):upper() .. row[5]:sub(2), route, row[5])
end
local enums = {
  {UI,0,"meg5779DisplayUnit","displayUnit",nil,{[0]="celsius",[1]="fahrenheit"}},
  {UI,1,"meg5779Keypad","keypad",nil,{[0]="unlock",[1]="lock1"}},
  {THERMOSTAT,0xE216,"meg5779Application","application",MANUFACTURER,{[0]="Occupied Space",[1]="Floor",[255]="Not known"}},
  {THERMOSTAT,0xE217,"meg5779HeatingFuel","heatingFuel",MANUFACTURER,{[0]="electricity",[1]="gas",[2]="oil",[3]="solid_fuel",[4]="solar",[5]="community_heating",[6]="heat_pump",[255]="not_specified"}},
  {THERMOSTAT,0xE218,"meg5779TransferMedium","transferMedium",MANUFACTURER,{[0]="nothing",[1]="hydronic",[2]="air"}},
  {THERMOSTAT,0xE21A,"meg5779HeatingEmitter","heatingEmitter",MANUFACTURER,{[0]="None",[1]="Radiator",[2]="Fan Assisted Radiator",[3]="Radiant Panel",[4]="Floor",[255]="Not specified"}},
}
for _, row in ipairs(enums) do
  local emitter, inverse = custom(row[3]), {}
  for raw, label in pairs(row[6]) do inverse[label] = raw end
  local route = "meg5779_" .. row[4]
  local mapping = add(row[1], row[2], route, types.Enum8, lookup(row[6]), emitter, {read_only = false, mfg_code = row[5]})
  mapping.sender = function(device, _, value)
    local encoded = inverse[value]
    if encoded == nil then return false end
    return write(device, row[1], row[2], types.Enum8, encoded, row[5])
  end
  command("concertmirror08464." .. row[3], "set" .. row[4]:sub(1,1):upper() .. row[4]:sub(2), route, row[4])
end
add(THERMOSTAT, 0xE012, "meg5779_windowOpen", types.Uint8, function(value)
  return scalar(value) == 1 and "active" or "inactive"
end, custom("meg5779WindowOpen"), {mfg_code = MANUFACTURER})

local function running_state(device, rx)
  local header = rx.body and rx.body.zcl_header
  if not header or header.frame_ctrl:is_cluster_specific_set() or (header.cmd.value ~= 1 and header.cmd.value ~= 10) then return end
  if rx.address_header.cluster.value ~= THERMOSTAT then return end
  local values = {}
  for _, record in ipairs(rx.body.zcl_body.attr_records or {}) do
    if record.data and (not record.status or record.status.value == 0) then values[record.attr_id.value] = scalar(record.data) end
  end
  local value, state
  if values[8] ~= nil then value, state = values[8], "heating"
  elseif values[7] ~= nil then value, state = values[7], "cooling" end
  if value ~= nil then publish(device, capabilities.thermostatOperatingState.thermostatOperatingState(value > 0 and state or "idle")) end
end
local function queries(device)
  for _, endpoint in ipairs(endpoints(device, THERMOSTAT)) do
    for _, attribute in ipairs({0,0x12,0x14,0x11,0x13,0x1C,8,0x16,0x15,0x18,0x17}) do read(device, THERMOSTAT, attribute, nil, endpoint) end
  end
  for _, endpoint in ipairs(endpoints(device, UI)) do
    for _, attribute in ipairs({0xE000,0xE001,0xE002}) do read(device, UI, attribute, MANUFACTURER, endpoint) end
    read(device, UI, 0, nil, endpoint)
    read(device, UI, 1, nil, endpoint)
  end
  for _, endpoint in ipairs(endpoints(device, THERMOSTAT)) do
    for _, attribute in ipairs({0xE216,0xE217,0xE218,0xE21A,0xE012}) do read(device, THERMOSTAT, attribute, MANUFACTURER, endpoint) end
  end
end
local family = {
  profile = "thermostats-schneider-meg5779", zcl_clusters = mappings,
  capability_commands = commands, protocol_writers = writers,
  zigbee_message_handler = running_state,
  component_to_endpoint = function(device) return device:get_endpoint(THERMOSTAT) end,
  endpoint_to_component = function() return "main" end,
  runtime_start = function(device)
    publish(device, capabilities.thermostatMode.supportedThermostatModes({"off","heat","cool"}, {visibility = {displayed = false}}))
    publish(device, capabilities.thermostatOperatingState.supportedThermostatOperatingStates({"idle","heating","cooling","fan only"}, {visibility = {displayed = false}}))
  end,
  configure = function(driver, device)
    for _, endpoint in ipairs(endpoints(device, THERMOSTAT)) do zcl.bind_cluster(device, THERMOSTAT, driver.environment_info.hub_zigbee_eui, endpoint) end
    for _, mapping in ipairs(mappings) do
      local defaults = mapping.reporting_defaults
      if defaults then
        for _, endpoint in ipairs(endpoints(device, mapping.cluster_id)) do
          zcl.configure_reporting(device, {
            cluster = mapping.cluster_id, attribute = mapping.attribute_id, data_type = mapping.data_type,
            minimum_interval = defaults.minimum_interval, maximum_interval = defaults.maximum_interval,
            reportable_change = defaults.reportable_change,
          }, endpoint, {auto_endpoint = true, disable_default_response = true})
        end
      end
    end
    queries(device)
    -- Passive defaults describe shared controls; family configure sends them once.
  end,
  parent_refresh = function(device) queries(device) end,
}
register(family, {helpers.create_fingerprint("Schneider Electric", "MEG5779")})
-- ZCL REPORTING CAPABILITIES BEGIN
zcl.attach_reporting_capabilities(definitions, {
  {1, "rpt-men", {zr02010011auto = "CoolSet", zr02010012auto = "HeatSet", zr02010013auto = "CoolSetTwo", zr02010014auto = "HeatSetTwo"}},
})
-- ZCL REPORTING CAPABILITIES END

return {id = "zcl.thermostats.meg5779", registrations = definitions,}
