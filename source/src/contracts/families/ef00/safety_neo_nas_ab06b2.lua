local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"

local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()

-- Frozen Z2M v26.99.0 src/devices/neo.ts:95-144.
-- Registered only after an independent audit verified every DP, profile item,
-- custom capability, and exact fingerprint.
local on_off_converter = converter.lookup_from_to({
  ON = true,
  OFF = false,
})

local alarm_state_converter = converter.from_only(converter.lookup_value({
  [0] = "alarm_sound",
  [1] = "alarm_light",
  [2] = "alarm_sound_light",
  [3] = "no_alarm",
}))

local alarm_melody_converter = converter.lookup_from_to({
  melody_1 = 0,
  melody_2 = 1,
  melody_3 = 2,
})

local alarm_mode_converter = converter.lookup_from_to({
  alarm_sound = 0,
  alarm_light = 1,
  alarm_sound_light = 2,
})

local charging_converter = converter.from_only(function(value)
  return (value == true or value == 1) and "charging" or "not_charging"
end)

local definition = {
  profile = "safety-alarm-neo-nas-ab06b2",
  query_on_configure = false,
  initial_custom_state_query = false,
  refresh_state_query = false,
  placeholder_custom_states = false,
  time_start = "off",

  tuya.dp_enum(1, {
    name = "neo_ab_six_alarm_state",
    read_only = true,
    emit = emit.neoAbSixAlarmState(),
    converter = alarm_state_converter,
  }),
  tuya.dp_binary(13, {
    name = "neo_ab_six_alarm_switch",
    emit = emit.neoAbSixAlarmSwitch(),
    converter = on_off_converter,
  }),
  tuya.dp_binary(101, {
    name = "neo_ab_six_tamper_alarm_switch",
    emit = emit.neoAbSixTamperAlarmSwitch(),
    converter = on_off_converter,
  }),
  tuya.dp_binary(20, {
    name = "neo_ab_six_tamper_alarm",
    read_only = true,
    emit = emit.neoAbSixTamperAlarm(),
    converter = on_off_converter,
  }),
  tuya.dp_enum(21, {
    name = "neo_ab_six_alarm_melody",
    emit = emit.neoAbSixAlarmMelody(),
    converter = alarm_melody_converter,
  }),
  tuya.dp_enum(102, {
    name = "neo_ab_six_alarm_mode",
    emit = emit.neoAbSixAlarmMode(),
    converter = alarm_mode_converter,
  }),
  tuya.dp_numeric(7, {
    name = "neo_ab_six_alarm_time",
    emit = emit.neoAbSixAlarmTime(),
  }),
  tuya.dp_binary(6, {
    name = "neo_ab_six_charging",
    read_only = true,
    emit = emit.neoAbSixCharging(),
    converter = charging_converter,
  }),
  tuya.dp_battery(15, {
    read_only = true,
    emit = emit.battery(),
  }),
}

register_device_definition(definition, {
  { manufacturer = "_TZE200_nlrfgpny", model = "TS0601" },
  { manufacturer = "_TZE284_nlrfgpny", model = "TS0601" },
  { manufacturer = "_TZE204_nlrfgpny", model = "TS0601" },
})

return {
  id = "neo.nas_ab06b2",
  registrations = device_definitions,
}
