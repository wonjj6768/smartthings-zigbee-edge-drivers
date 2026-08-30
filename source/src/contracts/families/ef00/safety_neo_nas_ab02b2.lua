local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"

local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()

-- Frozen Zigbee2MQTT v26.99.0 src/devices/neo.ts:46-73 and the exact
-- legacy neo_alarm converters in src/lib/legacy.ts.
local melody_converter = converter.lookup_from_to({
  ["1"] = 1,
  ["2"] = 2,
  ["3"] = 3,
  ["4"] = 4,
  ["5"] = 5,
  ["6"] = 6,
  ["7"] = 7,
  ["8"] = 8,
  ["9"] = 9,
  ["10"] = 10,
  ["11"] = 11,
  ["12"] = 12,
  ["13"] = 13,
  ["14"] = 14,
  ["15"] = 15,
  ["16"] = 16,
  ["17"] = 17,
  ["18"] = 18,
})

local volume_converter = converter.lookup_from_to({
  low = 0,
  medium = 1,
  high = 2,
})

local definition = {
  profile = "safety-alarm-neo-nas-ab02b2",
  query_on_configure = true,
  mcu_version_request_on_configure = true,
  force_time_updates = true,
  time_start = "off",
  initial_custom_state_query = false,
  refresh_state_query = false,
  placeholder_custom_states = false,

  tuya.dp_binary(13, {
    name = "alarm",
    emit = emit.alarm(),
  }),
  tuya.dp_numeric(7, {
    name = "neo_ab_two_duration",
    emit = emit.neoAbTwoDuration(),
  }),
  tuya.dp_battery(15, {
    read_only = true,
    emit = emit.battery(),
  }),
  tuya.dp_enum(21, {
    name = "neo_ab_two_melody",
    emit = emit.neoAbTwoMelody(),
    converter = melody_converter,
  }),
  tuya.dp_enum(5, {
    name = "neo_ab_two_volume",
    emit = emit.neoAbTwoVolume(),
    converter = volume_converter,
  }),
}

register_device_definition(definition, {
  { manufacturer = "_TZE200_t1blo2bj", model = "TS0601" },
  { manufacturer = "_TZE204_t1blo2bj", model = "TS0601" },
  { manufacturer = "_TZE204_q76rtoa9", model = "TS0601" },
})

return {
  id = "neo.nas_ab02b2",
  registrations = device_definitions,
}
