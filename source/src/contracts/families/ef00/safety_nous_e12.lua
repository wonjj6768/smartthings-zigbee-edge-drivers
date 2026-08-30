local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"

local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()

-- Frozen Zigbee2MQTT v26.99.0 src/devices/nous.ts:15-67.
local test_converter = converter.lookup_from_to({
  test = true,
  idle = false,
})

local battery_state_converter = converter.from_only(converter.lookup_value({
  [0] = "low",
  [1] = "medium",
  [2] = "high",
}))

local warming_up_capability_emitter = emit.nousETwelveWarmingUp()

local function emit_warming_up(device, value, dp_info, mapping_context)
  local active = value == true
  if active then
    device.thread:call_with_delay(120, function()
      local event = warming_up_capability_emitter(device, "off", dp_info, mapping_context)
      if event ~= nil then
        device:emit_event(event)
      end
    end, "Nous E12 warming-up reset")
  end

  return warming_up_capability_emitter(device, active and "on" or "off", dp_info, mapping_context)
end

local definition = {
  profile = "safety-co-nous-e12",
  query_on_configure = false,
  time_start = "off",
  initial_custom_state_query = false,
  refresh_state_query = false,
  placeholder_custom_states = false,

  tuya.dp_enum(1, {
    name = "carbon_monoxide",
    read_only = true,
    emit = emit.carbon_monoxide(),
    converter = converter.from_only(function(value)
      return type(value) == "number" and value == 0
    end),
  }),
  tuya.dp_numeric(2, {
    name = "carbon_monoxide_value",
    read_only = true,
    emit = emit.carbon_monoxide_level(),
  }),
  tuya.dp_binary(8, {
    name = "nous_e_twelve_test",
    emit = emit.nousETwelveTest(),
    converter = test_converter,
  }),
  tuya.dp_enum(9, {
    name = "nous_e_twelve_testing",
    read_only = true,
    emit = emit.nousETwelveTesting(),
    converter = converter.from_only(function(value)
      return type(value) == "number" and value == 0 and "on" or "off"
    end),
  }),
  tuya.dp_binary(10, {
    name = "nous_e_twelve_warming_up",
    read_only = true,
    emit = emit_warming_up,
  }),
  tuya.dp_bitmap(11, {
    name = "fault",
    read_only = true,
    emit = emit.hardware_fault(),
    converter = converter.from_only(function(value)
      return (tonumber(value) or 0) ~= 0
    end),
  }),
  tuya.dp_binary(12, {
    name = "nous_e_twelve_end_of_life",
    read_only = true,
    emit = emit.nousETwelveEndOfLife(),
    converter = converter.from_only(function(value)
      return value == false and "on" or "off"
    end),
  }),
  tuya.dp_numeric(14, {
    name = "nous_e_twelve_battery_state",
    read_only = true,
    emit = emit.nousETwelveBatteryState(),
    converter = battery_state_converter,
  }),
}

register_device_definition(definition, {
  { manufacturer = "_TZE284_sonkaxrd", model = "TS0601" },
})

return {
  id = "nous.e12",
  registrations = device_definitions,
}
