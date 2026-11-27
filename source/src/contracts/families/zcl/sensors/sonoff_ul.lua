-- SONOFF / SNZB-02UL, ZHC 26.137.0 64c312d6; issue58.
local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local helpers = require "contracts.helpers.family"
local caps = require "st.capabilities"
local types = require "st.zigbee.data_types"
local base = require "st.zigbee.cluster_base"
local management = require "st.zigbee.device_management"
local messages = require "st.zigbee.messages"
local zcl_messages = require "st.zigbee.zcl"
local generic_body = require "st.zigbee.generic_body"
local constants = require "st.zigbee.constants"
local log = require "log"

local device_definitions, register = helpers.definition_registry()
local mappings, commands = {}, {}
local PRIVATE, COOLKIT = 0xFC11, 0x1286
local PREFIX, FIELD = "concertmirror08464.", "sonoff_ul_"
local weather_values = { sunny = 0, partly_cloudy = 1, overcast = 2, rain = 3, snow = 4, windy = 5 }

local function custom(id)
  return assert(emit[id], "Missing SNZB-02UL emitter: " .. id)()
end

local function command(id, attribute, name)
  commands[#commands + 1] = {
    capability_id = PREFIX .. id,
    command_name = "set" .. attribute:sub(1, 1):upper() .. attribute:sub(2),
    argument_name = attribute,
    mapping_name = name,
  }
end

local function flags(tx)
  tx.body.zcl_header.frame_ctrl:set_disable_default_response()
  return tx:to_endpoint(1)
end

local function read(device, attribute)
  device:send(flags(base.read_attribute(device, types.ClusterId(PRIVATE), types.AttributeId(attribute))))
end

local function write(device, attribute, value)
  device:send(flags(base.write_attribute(device, types.ClusterId(PRIVATE), types.AttributeId(attribute), value)))
end

local function setting(id, attribute, wire, kind, low, high, lookup)
  local name = FIELD .. attribute
  local event = custom(id)
  local from = lookup and function(value) return lookup[value] end or nil
  local mapping = zcl.cluster_attribute(PRIVATE, wire, {
    name = name, endpoint = 1, data_type = kind, write_type = kind,
    scale = lookup and 1 or 100, from_device = from, emit = event, read_on_configure = true,
    sender = function(device, _, value)
      local encoded
      if lookup then
        for code, label in pairs(lookup) do if label == value then encoded = code end end
      elseif type(value) == "number" and value == value and value >= low and value <= high then
        encoded = math.floor(value * 10 + 0.5) * 10
      end
      if encoded == nil then return false end
      log.info(string.format("SNZB-02UL setting %s=%s; waiting for device readback", attribute, tostring(value)))
      write(device, wire, kind(encoded))
      read(device, wire)
      return true
    end,
  })
  mappings[#mappings + 1] = mapping
  command(id, attribute, name)
end

local function saved(device, id, attribute, value)
  device:set_field(FIELD .. attribute, value, { persist = true })
  -- These are saved outbound display inputs/policy, not measured sensor values.
  device:emit_event(custom(id)(device, value))
end

local function remote_item(kind, state, payload)
  return string.char(kind, 0, state, #payload) .. payload
end

local function remote_write(device, items)
  local body = table.concat(items)
  local bytes = string.char(1, 1, 0, 3, #body + 1, #items) .. body
  -- API16 ArrayABC encodes count + repeated typed elements (Struct layout).
  -- This device requires the standard homogeneous Array layout: type/count/data.
  -- Keep the SDK transport and the family-owned wire codec separate.
  local payload = string.pack("<I2BBI2", 0x601E, 0x48, 0x20, #bytes) .. bytes
  local tx = messages.ZigbeeMessageTx({
    address_header = messages.AddressHeader(constants.HUB.ADDR, constants.HUB.ENDPOINT,
      device:get_short_address(), 1, constants.HA_PROFILE_ID, PRIVATE),
    body = zcl_messages.ZclMessageBody({
      zcl_header = zcl_messages.ZclHeader({ cmd = types.ZCLCommandId(2) }),
      zcl_body = generic_body.GenericBody(payload),
    }),
  })
  device:send(flags(tx))
end

local function local_mapping(id, attribute, sender)
  local name = FIELD .. attribute
  mappings[#mappings + 1] = zcl.cluster_attribute(PRIVATE, 0x601E, {
    name = name, endpoint = 1, write_only = true, read_on_configure = false,
    read_on_refresh = false, sender = sender,
  })
  command(id, attribute, name)
end

local temperature_value, humidity_value = FIELD .. "measured_temperature", FIELD .. "measured_humidity"
local function remember(field)
  return function(device, value) device:set_field(field, value, { persist = false }) end
end

local function round(value, digits)
  local factor = 10 ^ digits
  return (value < 0 and math.ceil(value * factor - 0.5) or math.floor(value * factor + 0.5)) / factor
end

local function calculated(device)
  local temperature, humidity = device:get_field(temperature_value), device:get_field(humidity_value)
  if type(temperature) ~= "number" or type(humidity) ~= "number" then return end
  local saturation = 0.61078 * math.exp(17.27 * temperature / (temperature + 237.3))
  local events = { custom("sonoffUlVpd")(device, round(saturation * (1 - humidity / 100), 2)) }
  if humidity > 0 then
    local alpha = 17.27 * temperature / (temperature + 237.7) + math.log(humidity / 100)
    events[#events + 1] = caps.dewPoint.dewpoint({ value = round(237.7 * alpha / (17.27 - alpha), 1), unit = "C" })
  end
  return events
end

mappings[#mappings + 1] = zcl.temperature({ endpoint = 1, minimum_interval = 5, maximum_interval = 1800,
  reportable_change = 20, read_only = true, handler = remember(temperature_value) })
mappings[#mappings + 1] = zcl.humidity({ endpoint = 1, minimum_interval = 5, maximum_interval = 1800,
  reportable_change = 100, read_only = true, handler = remember(humidity_value) })
mappings[#mappings + 1] = zcl.battery({ endpoint = 1, minimum_interval = 3600, maximum_interval = 65000,
  reportable_change = 10, read_only = true })
for _, source in ipairs({ {0x0402, types.Int16}, {0x0405, types.Uint16} }) do
  mappings[#mappings + 1] = zcl.cluster_attribute(source[1], 0, {
    name = FIELD .. "calculated_" .. tostring(source[1]), endpoint = 1, data_type = source[2],
    scale = 100, read_only = true, read_on_configure = false, read_on_refresh = false, emit = calculated,
  })
end

setting("sonoffUlComfortTempMin", "comfortTempMin", 0x0004, types.Int16, 0, 50)
setting("sonoffUlComfortTempMax", "comfortTempMax", 0x0003, types.Int16, 0, 50)
setting("sonoffUlComfortHumidityMin", "comfortHumidityMin", 0x0005, types.Uint16, 5, 95)
setting("sonoffUlComfortHumidityMax", "comfortHumidityMax", 0x0006, types.Uint16, 5, 95)
setting("sonoffUlTempCal", "temperatureCalibration", 0x2003, types.Int16, -50, 50)
setting("sonoffUlHumidityCal", "humidityCalibration", 0x2004, types.Int16, -50, 50)
setting("sonoffUlTempUnits", "temperatureUnits", 0x0007, types.Uint16, nil, nil,
  { [0] = "celsius", [1] = "fahrenheit" })

local stored_inputs = {
  { "sonoffUlRemoteTemp", "remoteTemperature", 0, -20, 60, "<i2" },
  { "sonoffUlRemoteHumidity", "remoteHumidity", 1, 5, 95, "<I2" },
  { "sonoffUlRemotePressure", "remotePressure", 2, 700, 1100, "<i4" },
}
for _, input in ipairs(stored_inputs) do
  local id, attribute, sensor_type, low, high, format = table.unpack(input)
  local_mapping(id, attribute, function(device, _, value)
    if type(value) ~= "number" or value ~= value or value < low or value > high then return false end
    if device:get_field(FIELD .. "remoteMode") ~= "disable" then
      local raw = math.floor(value * 100 + 0.5)
      remote_write(device, { remote_item(sensor_type, 1, string.pack(format, raw)) })
    end
    saved(device, id, attribute, value)
    return true
  end)
end

local_mapping("sonoffUlRemoteMode", "remoteMode", function(device, _, value)
  if value ~= "enable" and value ~= "disable" then return false end
  if value == "disable" then
    remote_write(device, { remote_item(0, 0, ""), remote_item(1, 0, ""), remote_item(2, 0, "") })
  end
  -- ZHC enable is a local policy change; values are sent by their own setters.
  saved(device, "sonoffUlRemoteMode", "remoteMode", value)
  return true
end)

local function weather_command(device, value, request)
  local tx = base.build_manufacturer_specific_command(device, PRIVATE, 0x14, COOLKIT, string.char(0, 1, value))
  local header = tx.body.zcl_header
  if request then
    header.seqno = types.Uint8(request.seqno.value)
    if request.frame_ctrl.value & 0x08 == 0 then header.frame_ctrl:set_direction_client() end
  end
  device:send(flags(tx))
end

local_mapping("sonoffUlWeather", "weatherIcon", function(device, _, value)
  local code = weather_values[value]
  if code == nil then return false end
  weather_command(device, code)
  saved(device, "sonoffUlWeather", "weatherIcon", value)
  return true
end)

local function receive(device, rx)
  if rx.address_header.src_endpoint.value ~= 1 or rx.address_header.cluster.value ~= PRIVATE then return end
  local header = rx.body.zcl_header
  if header.cmd.value ~= 0x14 or header.frame_ctrl.value & 0x03 ~= 1 then return end
  if header.mfg_code and header.mfg_code.value ~= COOLKIT then return end
  local bytes = rx.body.zcl_body.body_bytes
  if type(bytes) ~= "string" or #bytes ~= 9 or bytes:byte(1) ~= 0 then return end
  local icon = device:get_field(FIELD .. "weatherIcon")
  if weather_values[icon] == nil then
    log.info("SNZB-02UL weather request: no icon selected")
    return
  end
  weather_command(device, weather_values[icon], header)
  log.info("SNZB-02UL weather request answered with saved icon: " .. icon)
end

local writers = {}
writers.sonoff_ul_weather_updates = function(device)
  -- Upstream's fixed coordinates enable the device's request timer. They are
  -- protocol trigger values, not the user's location or a weather data source.
  write(device, 0x5016, types.Int32(114057900))
  write(device, 0x5017, types.Int32(22543100))
  return true
end
commands[#commands + 1] = { capability_id = PREFIX .. "sonoffUlWeatherUpdates",
  command_name = "enableUpdates", mapping_name = "sonoff_ul_weather_updates" }

register({
  profile = "sonoff-snzb02ul-environment", package_group = "sonoff-ul", magic_packet = false,
  initial_custom_state_query = false, zcl_clusters = mappings, capability_commands = commands,
  protocol_writers = writers, zigbee_message_handler = receive,
  runtime_start = function(device)
    for _, item in ipairs(stored_inputs) do
      local value = device:get_field(FIELD .. item[2])
      if value ~= nil then device:emit_event(custom(item[1])(device, value)) end
    end
    for _, item in ipairs({ {"sonoffUlRemoteMode", "remoteMode"}, {"sonoffUlWeather", "weatherIcon"} }) do
      local value = device:get_field(FIELD .. item[2])
      if value ~= nil then device:emit_event(custom(item[1])(device, value)) end
    end
  end,
  configure = function(driver, device)
    for _, cluster in ipairs({ 0x0020, 0x0006 }) do
      device:send(management.build_bind_request(device, cluster, driver.environment_info.hub_zigbee_eui, 1))
    end
  end,
}, { helpers.create_fingerprint("SONOFF", "SNZB-02UL") })

-- ZCL REPORTING CAPABILITIES BEGIN
zcl.attach_reporting_capabilities(device_definitions, {
  {1, "rpt-sgl"},
})
-- ZCL REPORTING CAPABILITIES END

return {
  id = "zcl.sensors.sonoff_ul",
  registrations = device_definitions,
}
