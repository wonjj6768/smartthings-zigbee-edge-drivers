local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"

local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()

-- Frozen Zigbee2MQTT v26.99.0 src/devices/lincukoo.ts:407-439.
-- The source definition changes its exposed battery/control surface by exact
-- manufacturer, so each surface owns a separate registration and profile.
local alarm_status_converter = converter.lookup_from_to({
  normal = 0,
  alarm = 1,
})

local sensitivity_converter = converter.lookup_from_to({
  low = 0,
  middle = 1,
  high = 2,
})

local battery_state_converter = converter.from_only(converter.lookup_value({
  [0] = "low",
  [1] = "medium",
  [2] = "high",
}))

local dismiss_alarm_converter = converter.from_to(
  function() return "idle" end,
  function(value) return value == "DISMISS" and 0 or nil end
)

local silent_mode_converter = converter.lookup_from_to({
  OFF = false,
  ON = true,
})

local vibration_battery = {
  profile = "safety-vibration-tuya-battery",
  query_on_configure = true,
  time_start = "off",
  initial_custom_state_query = false,
  refresh_state_query = false,
  placeholder_custom_states = false,

  tuya.dp_enum(1, {
    name = "tuya_vibration_alarm_status",
    read_only = true,
    emit = emit.tuyaVibrationAlarmStatus(),
    converter = alarm_status_converter,
  }),
  tuya.dp_enum(101, {
    name = "tuya_vibration_sensitivity",
    emit = emit.tuyaVibrationSensitivity(),
    converter = sensitivity_converter,
  }),
  tuya.dp_enum(102, {
    name = "tuya_vibration_dismiss_alarm",
    emit = emit.tuyaVibrationDismissAlarm(),
    converter = dismiss_alarm_converter,
  }),
  tuya.dp_binary(103, {
    name = "tuya_vibration_silent_mode",
    emit = emit.tuyaVibrationSilentMode(),
    converter = silent_mode_converter,
  }),
  tuya.dp_battery(4, {
    read_only = true,
    emit = emit.battery(),
  }),
}

register_device_definition(vibration_battery, {
  { manufacturer = "_TZE284_aghfucwi", model = "TS0601" },
})

local vibration_battery_state_only = {
  profile = "safety-vibration-tuya-battery-state",
  query_on_configure = true,
  time_start = "off",
  initial_custom_state_query = false,
  refresh_state_query = false,
  placeholder_custom_states = false,

  tuya.dp_enum(1, {
    name = "tuya_vibration_alarm_status",
    read_only = true,
    emit = emit.tuyaVibrationAlarmStatus(),
    converter = alarm_status_converter,
  }),
  tuya.dp_enum(101, {
    name = "tuya_vibration_sensitivity",
    emit = emit.tuyaVibrationSensitivity(),
    converter = sensitivity_converter,
  }),
  tuya.dp_numeric(3, {
    name = "tuya_vibration_battery_state",
    read_only = true,
    emit = emit.tuyaVibrationBatteryState(),
    converter = battery_state_converter,
  }),
}

register_device_definition(vibration_battery_state_only, {
  { manufacturer = "_TZE284_2qx7sivb", model = "TS0601" },
})

local vibration_battery_state_controls = {
  profile = "safety-vibration-tuya-battery-state-controls",
  query_on_configure = true,
  time_start = "off",
  initial_custom_state_query = false,
  refresh_state_query = false,
  placeholder_custom_states = false,

  tuya.dp_enum(1, {
    name = "tuya_vibration_alarm_status",
    read_only = true,
    emit = emit.tuyaVibrationAlarmStatus(),
    converter = alarm_status_converter,
  }),
  tuya.dp_enum(101, {
    name = "tuya_vibration_sensitivity",
    emit = emit.tuyaVibrationSensitivity(),
    converter = sensitivity_converter,
  }),
  tuya.dp_numeric(3, {
    name = "tuya_vibration_battery_state",
    read_only = true,
    emit = emit.tuyaVibrationBatteryState(),
    converter = battery_state_converter,
  }),
  tuya.dp_enum(102, {
    name = "tuya_vibration_dismiss_alarm",
    emit = emit.tuyaVibrationDismissAlarm(),
    converter = dismiss_alarm_converter,
  }),
  tuya.dp_binary(103, {
    name = "tuya_vibration_silent_mode",
    emit = emit.tuyaVibrationSilentMode(),
    converter = silent_mode_converter,
  }),
}

register_device_definition(vibration_battery_state_controls, {
  { manufacturer = "_TZE284_8sejxcue", model = "TS0601" },
  { manufacturer = "_TZE284_7trh4ihp", model = "TS0601" },
})

return {
  id = "tuya.vibration_alarm",
  registrations = device_definitions,
}
