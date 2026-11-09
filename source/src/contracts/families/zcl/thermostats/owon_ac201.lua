-- OWON / AC201 only. ZHC cff1de4731a14a84094a8568d8bbf92aa5feb0db.
-- BEGIN PURE CODEC
local function scalar(value)
  return type(value) == "table" and value.value or value
end
local function finite(value, minimum, maximum)
  return type(value) == "number" and value == value and value >= minimum and value <= maximum
end
local function setpoint_wire(value)
  if not finite(value, 8, 30) then return end
  -- Primary Math.round(Number((value*2).toFixed(1)))/2, including binary64 ties.
  local doubled = value * 2
  local whole = math.floor(doubled)
  local bits = string.unpack("<I8", string.pack("<d", doubled))
  local exponent = ((bits >> 52) & 0x7FF) - 1022
  local mantissa = (bits & 0xFFFFFFFFFFFFF) | 0x10000000000000
  if mantissa * 20 >= (whole * 20 + 9) * (1 << (53 - exponent)) then whole = whole + 1 end
  return whole * 50
end
local function rx_scalar(value, _, context, mapping)
  local rx = context and context.zb_rx
  local records = rx and rx.body and rx.body.zcl_body and rx.body.zcl_body.attr_records
  for _, record in ipairs(records or {}) do
    if record.attr_id.value == mapping.attribute_id and record.data == context.typed_value then
      if (record.status and record.status.value ~= 0) or not record.data_type or record.data_type.value ~= mapping.data_type.ID then return end
      value = scalar(value)
      local minimum, maximum = mapping.data_type.ID == 0x29 and -32767 or 0, mapping.data_type.ID == 0x29 and 32767 or 255
      -- ZCL Int16 0x8000 is invalid, including cooling. No narrower RX SET-range clamp.
      if finite(value, minimum, maximum) and value % 1 == 0 then return value end
      return
    end
  end
end
local function temperature(guard)
  return function(value, device, context, mapping)
    value = rx_scalar(value, device, context, mapping)
    if value == nil then return end
    value = value / 100
    if not guard or value >= -273.15 then return value end
  end
end
local mode_rx = {[0]="off", [1]="auto", [3]="cool", [4]="heat", [5]="emergency heat", [6]="precooling", [7]="fanonly", [8]="dryair", [9]="asleep"}
local mode_tx = {off=0, auto=1, cool=3, heat=4, fanonly=7, dryair=8}
local fan_rx = {[0]="off", [1]="low", [2]="medium", [3]="high", [4]="on", [5]="auto", [6]="smart"}
local fan_tx = {off=0, low=1, medium=2, high=3, on=4, auto=5, smart=6}
local louver_rx = {[0]="fully_closed", [1]="fully_closed", [2]="fully_open", [3]="quarter_open", [4]="half_open", [5]="three_quarters_open"}
local louver_tx = {fully_closed=1, fully_open=2, quarter_open=3, half_open=4, three_quarters_open=5}
local function lookup(values)
  return function(value, device, context, mapping) return values[rx_scalar(value, device, context, mapping)] end
end
local function fan_power(value, device, context, mapping)
  value = rx_scalar(value, device, context, mapping)
  if value ~= nil then return value ~= 0 end
end
-- END PURE CODEC
local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local capabilities = require "st.capabilities"
local types = require "st.zigbee.data_types"
local base = require "st.zigbee.cluster_base"
local definitions, register = device_helpers.definition_registry()

local function write(device, cluster, attribute, kind, value)
  if value == nil then return false end
  local request = base.write_attribute(device, types.ClusterId(cluster), types.AttributeId(attribute), kind(value)):to_endpoint(1)
  request.body.zcl_header.frame_ctrl:set_disable_default_response()
  -- API16 send enqueues; it is not a write-completion or physical AC acknowledgement.
  return pcall(device.send, device, request)
end
local mappings = {
  zcl.cluster_attribute(0x0201, 0, {
    name="owon_ac201_local_temperature", endpoint=1, data_type=types.Int16,
    read_only=true, read_on_configure=false, read_on_refresh=true,
    from_device=temperature(true), emit=emit.temperature("C"),
    -- Primary raw0.1 is truncated to Int16 zero by the locked herdsman serializer.
    reporting_defaults={minimum_interval=60, maximum_interval=600, reportable_change=0},
  }),
  zcl.cluster_attribute(0x0201, 0x12, {
    name="current_heating_setpoint", endpoint=1, data_type=types.Int16,
    read_only=false, read_on_configure=false, read_on_refresh=true, suppress_optimistic_state=true,
    from_device=temperature(true), emit=emit.heating_setpoint("C"),
    sender=function(device, _, value) return write(device, 0x0201, 0x12, types.Int16, setpoint_wire(value)) end,
    reporting_defaults={minimum_interval=0, maximum_interval=3600, reportable_change=10},
  }),
  zcl.cluster_attribute(0x0201, 0x11, {
    name="current_cooling_setpoint", endpoint=1, data_type=types.Int16,
    read_only=false, read_on_configure=false, read_on_refresh=true, suppress_optimistic_state=true,
    from_device=temperature(false), emit=emit.cooling_setpoint("C"),
    sender=function(device, _, value) return write(device, 0x0201, 0x11, types.Int16, setpoint_wire(value)) end,
    -- The primary configures heating twice and does not configure cooling.
  }),
  zcl.cluster_attribute(0x0201, 0x1C, {
    name="system_mode", endpoint=1, data_type=types.Enum8,
    read_only=false, read_on_configure=false, read_on_refresh=true, suppress_optimistic_state=true,
    from_device=lookup(mode_rx), emit=emit.thermostat_mode(),
    sender=function(device, _, value) return write(device, 0x0201, 0x1C, types.Enum8, mode_tx[value]) end,
    reporting_defaults={minimum_interval=10, maximum_interval=3600},
  }),
  zcl.cluster_attribute(0x0202, 0, {
    name="owon_ac201_fan_mode", component="fan", endpoint=1, data_type=types.Enum8,
    read_only=false, read_on_configure=false, read_on_refresh=true, suppress_optimistic_state=true,
    from_device=lookup(fan_rx), emit=emit.value(capabilities.airConditionerFanMode.fanMode),
    sender=function(device, _, value)
      if type(value) ~= "string" then return false end
      return write(device, 0x0202, 0, types.Enum8, fan_tx[value:lower()])
    end,
    reporting_defaults={minimum_interval=0, maximum_interval=3600},
  }),
  zcl.cluster_attribute(0x0202, 0, {
    name="switch", component="fan", endpoint=1, data_type=types.Enum8,
    read_only=false, read_on_configure=false, read_on_refresh=false, suppress_optimistic_state=true,
    from_device=fan_power, emit=emit.switch(),
    sender=function(device, _, value)
      if type(value) ~= "boolean" then return false end
      return write(device, 0x0202, 0, types.Enum8, value and 4 or 0)
    end,
  }),
  zcl.cluster_attribute(0x0201, 0x45, {
    name="owon_ac201_louver_position", endpoint=1, data_type=types.Enum8,
    read_only=false, read_on_configure=false, read_on_refresh=true, suppress_optimistic_state=true,
    from_device=lookup(louver_rx), emit=emit.owonAc201LouverPosition(),
    sender=function(device, _, value) return write(device, 0x0201, 0x45, types.Enum8, louver_tx[value]) end,
    reporting_defaults={minimum_interval=0, maximum_interval=3600},
  }),
}
local family = {
  profile="thermostats-owon-ac201", zcl_clusters=mappings,
  thermostat_supported_modes={"off","heat","cool","auto","dryair","fanonly"},
  capability_commands={
    {capability_id="airConditionerFanMode", command_name="setFanMode", mapping_name="owon_ac201_fan_mode", argument_name="fanMode"},
  },
  component_to_endpoint=function() return 1 end,
  endpoint_to_component=function() return "main" end,
  runtime_start=function(device)
    device:emit_component_event({id="main"}, capabilities.thermostatMode.supportedThermostatModes({"off","heat","cool","auto","dryair","fanonly"}, {visibility={displayed=false}}))
    device:emit_component_event({id="main"}, capabilities.thermostatHeatingSetpoint.heatingSetpointRange({value={minimum=8,maximum=30,step=1},unit="C"}))
    device:emit_component_event({id="main"}, capabilities.thermostatCoolingSetpoint.coolingSetpointRange({value={minimum=8,maximum=30,step=1},unit="C"}))
    device:emit_component_event({id="fan"}, capabilities.airConditionerFanMode.supportedAcFanModes({"low","medium","high","on","auto"}, {visibility={displayed=false}}))
  end,
  parent_refresh=function(device, definition)
    if definition.zcl_refresh_before_read_all then definition.zcl_refresh_before_read_all(device, definition) end
    for _,target in ipairs({{0x0201,0},{0x0201,0x12},{0x0201,0x11},{0x0201,0x1C},{0x0202,0},{0x0201,0x45}}) do
      local request = base.read_attribute(device, types.ClusterId(target[1]), types.AttributeId(target[2])):to_endpoint(1)
      request.body.zcl_header.frame_ctrl:set_disable_default_response()
      device:send(request)
    end
  end,
  configure=function(driver, device)
    local hub = driver.environment_info.hub_zigbee_eui
    zcl.bind_cluster(device, 0x0202, hub, 1)
    local function configure(index)
      local mapping = mappings[index]
      local defaults = mapping.reporting_defaults
      zcl.configure_reporting(device, {
        cluster=mapping.cluster_id, attribute=mapping.attribute_id, data_type=mapping.data_type,
        minimum_interval=defaults.minimum_interval, maximum_interval=defaults.maximum_interval,
        reportable_change=defaults.reportable_change,
      }, 1, {disable_default_response=true})
    end
    configure(5)
    zcl.bind_cluster(device, 0x0201, hub, 1)
    configure(2)
    configure(2)
    configure(1)
    configure(4)
    configure(7)
  end,
}
register(family, {device_helpers.create_fingerprint("OWON", "AC201")})
-- ZCL REPORTING CAPABILITIES BEGIN
zcl.attach_reporting_capabilities(definitions, {
  {1, "rpt-ars"},
})
-- ZCL REPORTING CAPABILITIES END

return {id="zcl.thermostats.owon_ac201", registrations=definitions,}
