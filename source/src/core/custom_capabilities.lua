-- Shared custom capability metadata.
-- Keep capability IDs, command wiring, labels, and fallback ranges in one place
-- so emitters and driver handlers stay aligned.

local custom_capabilities = {}
local family_custom_capabilities = require "core.family_custom_capabilities"

local function range(minimum, maximum, step, unit)
  local value = {
    minimum = minimum,
    maximum = maximum,
    step = step,
  }

  if type(unit) == "string" and unit ~= "" then
    value.unit = unit
  end

  return value
end

local function values(items)
  return {
    allowed_values = items,
  }
end

local function numeric(definition)
  definition.kind = "numeric"
  return definition
end

local function enum(definition)
  definition.kind = "enum"
  if definition.default_range == nil and type(definition.supported_values) == "table" then
    definition.default_range = values(definition.supported_values)
  end
  return definition
end

local ON_OFF_VALUES = { "on", "off" }
local BATTERY_LOW_VALUES = { "normal", "low" }
local INDICATOR_MODE_VALUES = { "off", "off/on", "on/off", "on" }
local STANDARD_LOCAL_VALUES = { "standard", "local" }
local SENSOR_STATE_MODE_VALUES = { "on", "off", "occupied", "unoccupied" }
local POWER_ON_BEHAVIOR_VALUES = { "off", "on", "previous" }
local POWER_OUTAGE_MEMORY_VALUES = { "off", "on", "restore" }
local SWITCH_TYPE_VALUES = { "toggle", "state", "momentary" }
local SWITCH_MODE_VALUES = { "switch", "scene" }
local OPERATION_MODE_VALUES = { "command", "event" }
local LIGHT_TYPE_VALUES = { "led", "incandescent", "halogen" }
local LEARN_IR_CODE_VALUES = { "start", "stop" }
local SECURITY_REMOTE_ACTION_VALUES = {
  "disarm",
  "arm_day_zones",
  "arm_night_zones",
  "arm_all_zones",
  "exit_delay",
  "emergency",
}
local CAPABILITY_NAMESPACE = "concertmirror08464."

local function capability_id(name)
  return CAPABILITY_NAMESPACE .. name
end

local function capitalize(value)
  return value:sub(1, 1):upper() .. value:sub(2)
end

local function meters(minimum, maximum, step)
  return range(minimum, maximum, step, "m")
end

local function seconds(minimum, maximum, step)
  return range(minimum, maximum, step, "s")
end

local function lux(minimum, maximum, step)
  return range(minimum, maximum, step, "lux")
end

local function minutes(minimum, maximum, step)
  return range(minimum, maximum, step, "min")
end

local function make_numeric_capability(options)
  local attribute_name = assert(options.attribute_name, "numeric capability requires attribute_name")
  local read_only = options.read_only == true

  return numeric({
    emit_name = assert(options.emit_name, "numeric capability requires emit_name"),
    range_key = options.range_key or options.emit_name,
    capability_id = capability_id(options.capability_name or attribute_name),
    attribute_name = attribute_name,
    range_attribute_name = options.range_attribute_name ~= nil
      and options.range_attribute_name
      or (read_only and nil or (attribute_name .. "Range")),
    command_name = options.command_name ~= nil
      and options.command_name
      or (read_only and nil or ("set" .. capitalize(attribute_name))),
    argument_name = options.argument_name ~= nil
      and options.argument_name
      or (read_only and nil or attribute_name),
    mapping_name = options.mapping_name or options.emit_name,
    label = assert(options.label, "numeric capability requires label"),
    default_range = options.default_range,
    event_minimum = options.event_minimum,
    event_maximum = options.event_maximum,
    event_unit = options.event_unit,
  })
end

local function make_enum_capability(options)
  local attribute_name = assert(options.attribute_name, "enum capability requires attribute_name")
  local read_only = options.read_only == true

  return enum({
    emit_name = assert(options.emit_name, "enum capability requires emit_name"),
    range_key = options.range_key or options.emit_name,
    capability_id = capability_id(options.capability_name or attribute_name),
    attribute_name = attribute_name,
    supported_attribute_name = options.supported_attribute_name,
    command_name = options.command_name ~= nil
      and options.command_name
      or (read_only and nil or ("set" .. capitalize(attribute_name))),
    argument_name = options.argument_name ~= nil
      and options.argument_name
      or (read_only and nil or attribute_name),
    mapping_name = options.mapping_name or options.emit_name,
    label = assert(options.label, "enum capability requires label"),
    supported_values = assert(options.supported_values, "enum capability requires supported_values"),
  })
end

local function make_text_capability(options)
  local attribute_name = assert(options.attribute_name, "text capability requires attribute_name")

  return {
    kind = "text",
    emit_name = assert(options.emit_name, "text capability requires emit_name"),
    capability_id = capability_id(options.capability_name or attribute_name),
    attribute_name = attribute_name,
    command_name = options.command_name,
    argument_name = options.argument_name,
    label = assert(options.label, "text capability requires label"),
    maximum_length = options.maximum_length,
  }
end

custom_capabilities.numeric = {
  numeric({
    emit_name = "presence_sensitivity",
    range_key = "presence_sensitivity",
    capability_id = "concertmirror08464.presenceSensitivity",
    attribute_name = "presenceSensitivity",
    range_attribute_name = "presenceSensitivityRange",
    command_name = "setPresenceSensitivity",
    argument_name = "presenceSensitivity",
    mapping_name = "presence_sensitivity",
    label = "Presence sensitivity",
    default_range = range(0, 10, 1),
    event_maximum = 10,
  }),
  numeric({
    emit_name = "static_detection_sensitivity",
    range_key = "static_detection_sensitivity",
    capability_id = "concertmirror08464.staticDetectionSensitivity",
    attribute_name = "staticDetectionSensitivity",
    range_attribute_name = "staticDetectionSensitivityRange",
    command_name = "setStaticDetectionSensitivity",
    argument_name = "staticDetectionSensitivity",
    mapping_name = "static_detection_sensitivity",
    label = "Static detection sensitivity",
    default_range = range(0, 20, 1),
    event_maximum = 100,
  }),
  numeric({
    emit_name = "motion_detection_sensitivity",
    range_key = "motion_detection_sensitivity",
    capability_id = "concertmirror08464.motionDetectionSensitivity",
    attribute_name = "motionDetectionSensitivity",
    range_attribute_name = "motionDetectionSensitivityRange",
    command_name = "setMotionDetectionSensitivity",
    argument_name = "motionDetectionSensitivity",
    mapping_name = "motion_detection_sensitivity",
    label = "Motion detection sensitivity",
    default_range = range(0, 20, 1),
    event_maximum = 100,
  }),
  numeric({
    emit_name = "move_sensitivity",
    range_key = "move_sensitivity",
    capability_id = "concertmirror08464.moveSensitivity",
    attribute_name = "moveSensitivity",
    range_attribute_name = "moveSensitivityRange",
    command_name = "setMoveSensitivity",
    argument_name = "moveSensitivity",
    mapping_name = "move_sensitivity",
    label = "Move sensitivity",
    default_range = range(0, 10, 1),
    event_maximum = 100,
  }),
  numeric({
    emit_name = "keep_sensitivity",
    range_key = "keep_sensitivity",
    capability_id = "concertmirror08464.keepSensitivity",
    attribute_name = "keepSensitivity",
    range_attribute_name = "keepSensitivityRange",
    command_name = "setKeepSensitivity",
    argument_name = "keepSensitivity",
    mapping_name = "keep_sensitivity",
    label = "Keep sensitivity",
    default_range = range(0, 10, 1),
    event_maximum = 100,
  }),
  numeric({
    emit_name = "trigger_sensitivity",
    range_key = "trigger_sensitivity",
    capability_id = "concertmirror08464.triggerSensitivity",
    attribute_name = "triggerSensitivity",
    range_attribute_name = "triggerSensitivityRange",
    command_name = "setTriggerSensitivity",
    argument_name = "triggerSensitivity",
    mapping_name = "trigger_sensitivity",
    label = "Trigger sensitivity",
    default_range = range(0, 20, 1),
    event_maximum = 100,
  }),
  numeric({
    emit_name = "entry_sensitivity",
    range_key = "entry_sensitivity",
    capability_id = "concertmirror08464.entrySensitivity",
    attribute_name = "entrySensitivity",
    range_attribute_name = "entrySensitivityRange",
    command_name = "setEntrySensitivity",
    argument_name = "entrySensitivity",
    mapping_name = "entry_sensitivity",
    label = "Entry sensitivity",
    default_range = range(0, 9, 1),
    event_maximum = 100,
  }),
  numeric({
    emit_name = "fall_sensitivity",
    range_key = "fall_sensitivity",
    capability_id = "concertmirror08464.fallSensitivity",
    attribute_name = "fallSensitivity",
    range_attribute_name = "fallSensitivityRange",
    command_name = "setFallSensitivity",
    argument_name = "fallSensitivity",
    mapping_name = "fall_sensitivity",
    label = "Fall sensitivity",
    default_range = range(1, 10, 1),
    event_maximum = 100,
  }),
  numeric({
    emit_name = "tumble_alarm_time",
    range_key = "tumble_alarm_time",
    capability_id = "concertmirror08464.tumbleAlarmTime",
    attribute_name = "tumbleAlarmTime",
    range_attribute_name = "tumbleAlarmTimeRange",
    command_name = "setTumbleAlarmTime",
    argument_name = "tumbleAlarmTime",
    mapping_name = "tumble_alarm_time",
    label = "Tumble alarm time",
    default_range = range(1, 5, 1, "min"),
    event_maximum = 600,
    event_unit = "min",
  }),
  numeric({
    emit_name = "large_motion_detection_sensitivity",
    range_key = "large_motion_detection_sensitivity",
    capability_id = "concertmirror08464.largeMotionDetectionSensitivity",
    attribute_name = "largeMotionDetectionSensitivity",
    range_attribute_name = "largeMotionDetectionSensitivityRange",
    command_name = "setLargeMotionDetectionSensitivity",
    argument_name = "largeMotionDetectionSensitivity",
    mapping_name = "large_motion_detection_sensitivity",
    label = "Large motion detection sensitivity",
    default_range = range(0, 10, 1),
    event_maximum = 100,
  }),
  numeric({
    emit_name = "medium_motion_detection_sensitivity",
    range_key = "medium_motion_detection_sensitivity",
    capability_id = "concertmirror08464.mediumMotionSensitivity",
    attribute_name = "mediumMotionDetectionSensitivity",
    range_attribute_name = "mediumMotionDetectionSensitivityRange",
    command_name = "setMediumMotionDetectionSensitivity",
    argument_name = "mediumMotionDetectionSensitivity",
    mapping_name = "medium_motion_detection_sensitivity",
    label = "Medium motion detection sensitivity",
    default_range = range(0, 10, 1),
    event_maximum = 100,
  }),
  numeric({
    emit_name = "small_motion_detection_sensitivity",
    range_key = "small_motion_detection_sensitivity",
    capability_id = "concertmirror08464.smallMotionDetectionSensitivity",
    attribute_name = "smallMotionDetectionSensitivity",
    range_attribute_name = "smallMotionDetectionSensitivityRange",
    command_name = "setSmallMotionDetectionSensitivity",
    argument_name = "smallMotionDetectionSensitivity",
    mapping_name = "small_motion_detection_sensitivity",
    label = "Small motion detection sensitivity",
    default_range = range(0, 10, 1),
    event_maximum = 100,
  }),
  numeric({
    emit_name = "small_move_sensitivity",
    range_key = "small_move_sensitivity",
    capability_id = "concertmirror08464.smallMoveSensitivity",
    attribute_name = "smallMoveSensitivity",
    range_attribute_name = "smallMoveSensitivityRange",
    command_name = "setSmallMoveSensitivity",
    argument_name = "smallMoveSensitivity",
    mapping_name = "small_move_sensitivity",
    label = "Small move sensitivity",
    default_range = range(0, 10, 1),
    event_maximum = 100,
  }),
  numeric({
    emit_name = "breath_sensitivity",
    range_key = "breath_sensitivity",
    capability_id = "concertmirror08464.breathSensitivity",
    attribute_name = "breathSensitivity",
    range_attribute_name = "breathSensitivityRange",
    command_name = "setBreathSensitivity",
    argument_name = "breathSensitivity",
    mapping_name = "breath_sensitivity",
    label = "Breath sensitivity",
    default_range = range(0, 10, 1),
    event_maximum = 100,
  }),
  numeric({
    emit_name = "large_motion_detection_distance",
    range_key = "large_motion_detection_distance",
    capability_id = "concertmirror08464.largeMotionDetectionDistance",
    attribute_name = "largeMotionDetectionDistance",
    range_attribute_name = "largeMotionDetectionDistanceRange",
    command_name = "setLargeMotionDetectionDistance",
    argument_name = "largeMotionDetectionDistance",
    mapping_name = "large_motion_detection_distance",
    label = "Large motion detection distance",
    default_range = range(0, 10, 0.01, "m"),
    event_maximum = 100,
    event_unit = "m",
  }),
  numeric({
    emit_name = "medium_motion_detection_distance",
    range_key = "medium_motion_detection_distance",
    capability_id = "concertmirror08464.mediumMotionDetectionDistance",
    attribute_name = "mediumMotionDetectionDistance",
    range_attribute_name = "mediumMotionDetectionDistanceRange",
    command_name = "setMediumMotionDetectionDistance",
    argument_name = "mediumMotionDetectionDistance",
    mapping_name = "medium_motion_detection_distance",
    label = "Medium motion detection distance",
    default_range = range(0, 6, 0.01, "m"),
    event_maximum = 100,
    event_unit = "m",
  }),
  numeric({
    emit_name = "small_motion_detection_distance",
    range_key = "small_motion_detection_distance",
    capability_id = "concertmirror08464.smallMotionDetectionDistance",
    attribute_name = "smallMotionDetectionDistance",
    range_attribute_name = "smallMotionDetectionDistanceRange",
    command_name = "setSmallMotionDetectionDistance",
    argument_name = "smallMotionDetectionDistance",
    mapping_name = "small_motion_detection_distance",
    label = "Small motion detection distance",
    default_range = range(0, 6, 0.01, "m"),
    event_maximum = 100,
    event_unit = "m",
  }),
  numeric({
    emit_name = "move_detection_max_distance",
    range_key = "move_detection_max_distance",
    capability_id = "concertmirror08464.moveDetectionMaxDistance",
    attribute_name = "moveDetectionMaxDistance",
    range_attribute_name = "moveDetectionMaxDistanceRange",
    command_name = "setMoveDetectionMaxDistance",
    argument_name = "moveDetectionMaxDistance",
    mapping_name = "move_detection_max_distance",
    label = "Move detection max distance",
    default_range = range(0, 10, 0.01, "m"),
    event_maximum = 100,
    event_unit = "m",
  }),
  numeric({
    emit_name = "move_detection_min_distance",
    range_key = "move_detection_min_distance",
    capability_id = "concertmirror08464.moveDetectionMinDistance",
    attribute_name = "moveDetectionMinDistance",
    range_attribute_name = "moveDetectionMinDistanceRange",
    command_name = "setMoveDetectionMinDistance",
    argument_name = "moveDetectionMinDistance",
    mapping_name = "move_detection_min_distance",
    label = "Move detection min distance",
    default_range = range(0, 10, 0.01, "m"),
    event_maximum = 100,
    event_unit = "m",
  }),
  numeric({
    emit_name = "small_move_detection_max_distance",
    range_key = "small_move_detection_max_distance",
    capability_id = "concertmirror08464.smallMoveDetectionMaxDistance",
    attribute_name = "smallMoveDetectionMaxDistance",
    range_attribute_name = "smallMoveDetectionMaxDistanceRange",
    command_name = "setSmallMoveDetectionMaxDistance",
    argument_name = "smallMoveDetectionMaxDistance",
    mapping_name = "small_move_detection_max_distance",
    label = "Small move detection max distance",
    default_range = range(0, 6, 0.01, "m"),
    event_maximum = 100,
    event_unit = "m",
  }),
  numeric({
    emit_name = "small_move_detection_min_distance",
    range_key = "small_move_detection_min_distance",
    capability_id = "concertmirror08464.smallMoveDetectionMinDistance",
    attribute_name = "smallMoveDetectionMinDistance",
    range_attribute_name = "smallMoveDetectionMinDistanceRange",
    command_name = "setSmallMoveDetectionMinDistance",
    argument_name = "smallMoveDetectionMinDistance",
    mapping_name = "small_move_detection_min_distance",
    label = "Small move detection min distance",
    default_range = range(0, 6, 0.01, "m"),
    event_maximum = 100,
    event_unit = "m",
  }),
  numeric({
    emit_name = "breath_detection_max_distance",
    range_key = "breath_detection_max_distance",
    capability_id = "concertmirror08464.breathDetectionMaxDistance",
    attribute_name = "breathDetectionMaxDistance",
    range_attribute_name = "breathDetectionMaxDistanceRange",
    command_name = "setBreathDetectionMaxDistance",
    argument_name = "breathDetectionMaxDistance",
    mapping_name = "breath_detection_max_distance",
    label = "Breath detection max distance",
    default_range = range(0, 6, 0.01, "m"),
    event_maximum = 100,
    event_unit = "m",
  }),
  numeric({
    emit_name = "breath_detection_min_distance",
    range_key = "breath_detection_min_distance",
    capability_id = "concertmirror08464.breathDetectionMinDistance",
    attribute_name = "breathDetectionMinDistance",
    range_attribute_name = "breathDetectionMinDistanceRange",
    command_name = "setBreathDetectionMinDistance",
    argument_name = "breathDetectionMinDistance",
    mapping_name = "breath_detection_min_distance",
    label = "Breath detection min distance",
    default_range = range(0, 6, 0.01, "m"),
    event_maximum = 100,
    event_unit = "m",
  }),
  make_numeric_capability({
    emit_name = "minimum_range",
    attribute_name = "minimumRange",
    label = "Minimum range",
    default_range = meters(0, 20, 0.1),
    event_maximum = 100,
  }),
  make_numeric_capability({
    emit_name = "detection_delay",
    attribute_name = "detectionDelay",
    label = "Detection delay",
    default_range = seconds(0, 3600, 1),
    event_maximum = 3600,
  }),
  make_numeric_capability({
    emit_name = "keep_time",
    attribute_name = "keepTime",
    label = "Keep time",
    default_range = seconds(0, 3600, 1),
    event_maximum = 3600,
  }),
  make_numeric_capability({
    emit_name = "illuminance_threshold_min",
    attribute_name = "illuminanceThresholdMin",
    label = "Minimum illuminance threshold",
    default_range = lux(0, 20000, 1),
    event_maximum = 20000,
  }),
  make_numeric_capability({
    emit_name = "shield_range",
    attribute_name = "shieldRange",
    label = "Shield range",
    default_range = meters(0, 20, 0.1),
    event_maximum = 100,
  }),
  make_numeric_capability({
    emit_name = "entry_filter_time",
    attribute_name = "entryFilterTime",
    label = "Entry filter time",
    default_range = seconds(0, 3600, 1),
    event_maximum = 3600,
  }),
  make_numeric_capability({
    emit_name = "entry_distance_indentation",
    attribute_name = "entryDistanceIndentation",
    label = "Entry distance indentation",
    default_range = meters(0, 20, 0.01),
    event_maximum = 100,
  }),
  make_numeric_capability({
    emit_name = "block_time",
    attribute_name = "blockTime",
    label = "Block time",
    default_range = seconds(0, 3600, 1),
    event_maximum = 3600,
  }),
  make_numeric_capability({
    emit_name = "presence_time",
    attribute_name = "presenceTime",
    label = "Presence time",
    default_range = seconds(0, 3600, 1),
    event_maximum = 3600,
  }),
  make_numeric_capability({
    emit_name = "presence_delay",
    attribute_name = "presenceDelay",
    label = "Presence delay",
    default_range = seconds(0, 3600, 1),
    event_maximum = 3600,
  }),
  make_numeric_capability({
    emit_name = "detection_cycle",
    attribute_name = "detectionCycle",
    label = "Detection cycle",
    default_range = seconds(0, 3600, 1),
    event_maximum = 3600,
  }),
  make_numeric_capability({
    emit_name = "presence_detection_range",
    attribute_name = "presenceDetectionRange",
    label = "Presence detection range",
    default_range = meters(0, 20, 0.1),
    event_maximum = 20,
  }),
  make_numeric_capability({
    emit_name = "presence_fading_time",
    capability_name = "detectionHoldTime",
    attribute_name = "detectionHoldTime",
    label = "Detection hold time",
    default_range = seconds(0, 300, 1),
    event_maximum = 300,
  }),
  make_numeric_capability({
    emit_name = "presence_target_distance",
    attribute_name = "presenceTargetDistance",
    label = "Presence target distance",
    default_range = meters(0, 20, 0.1),
    event_maximum = 20,
    read_only = true,
  }),
  make_numeric_capability({
    emit_name = "liquid_level_percent",
    capability_name = "liquidLevelPercent",
    attribute_name = "liquidLevelPercent",
    label = "Liquid level percent",
    default_range = range(0, 100, 1, "%"),
    event_maximum = 100,
    event_unit = "%",
    read_only = true,
  }),
  make_numeric_capability({
    emit_name = "liquid_depth",
    capability_name = "liquidDepth",
    attribute_name = "liquidDepth",
    label = "Liquid depth",
    default_range = meters(0, 4, 0.01),
    event_maximum = 4,
    event_unit = "m",
    read_only = true,
  }),
  make_numeric_capability({
    emit_name = "presence_illuminance_threshold",
    attribute_name = "presenceIlluminanceThreshold",
    label = "Presence illuminance threshold",
    default_range = lux(0, 20000, 1),
    event_maximum = 20000,
  }),
  make_numeric_capability({
    emit_name = "power_poll_interval",
    capability_name = "powerPollIntervalV2",
    attribute_name = "powerPollInterval",
    range_attribute_name = "powerPollIntervalRange",
    command_name = "setPowerPollInterval",
    argument_name = "powerPollInterval",
    mapping_name = "power_poll_interval",
    label = "Power poll interval",
    default_range = seconds(5, 3600, 5),
    event_minimum = 5,
    event_maximum = 3600,
    event_unit = "s",
  }),
  make_numeric_capability({
    emit_name = "countdown_timer",
    capability_name = "countdownTimer",
    attribute_name = "countdownTimer",
    range_attribute_name = "countdownTimerRange",
    command_name = "setCountdownTimer",
    argument_name = "countdownTimer",
    mapping_name = "countdown_timer",
    label = "Countdown timer",
    default_range = seconds(0, 43200, 1),
    event_minimum = 0,
    event_maximum = 43200,
    event_unit = "s",
  }),
  make_numeric_capability({
    emit_name = "min_brightness",
    capability_name = "minimumBrightness",
    attribute_name = "minBrightness",
    range_attribute_name = "minBrightnessRange",
    command_name = "setMinBrightness",
    argument_name = "minBrightness",
    mapping_name = "min_brightness",
    label = "Minimum brightness",
    default_range = range(1, 1000, 1),
    event_minimum = 1,
    event_maximum = 1000,
  }),
  make_numeric_capability({
    emit_name = "max_brightness",
    capability_name = "maximumBrightness",
    attribute_name = "maxBrightness",
    range_attribute_name = "maxBrightnessRange",
    command_name = "setMaxBrightness",
    argument_name = "maxBrightness",
    mapping_name = "max_brightness",
    label = "Maximum brightness",
    default_range = range(1, 1000, 1),
    event_minimum = 1,
    event_maximum = 1000,
  }),
  make_numeric_capability({
    emit_name = "temperature_threshold",
    capability_name = "temperatureThreshold",
    attribute_name = "temperatureThreshold",
    label = "Temperature threshold",
    default_range = range(40, 100, 1, "C"),
    event_minimum = 40,
    event_maximum = 100,
    event_unit = "C",
  }),
  make_numeric_capability({
    emit_name = "power_threshold",
    capability_name = "powerThreshold",
    attribute_name = "powerThreshold",
    label = "Power threshold",
    default_range = range(1, 26, 1, "kW"),
    event_minimum = 1,
    event_maximum = 26,
    event_unit = "kW",
  }),
  make_numeric_capability({
    emit_name = "over_current_threshold",
    capability_name = "overCurrentThreshold",
    attribute_name = "overCurrentThreshold",
    label = "Over current threshold",
    default_range = range(1, 64, 1, "A"),
    event_minimum = 1,
    event_maximum = 64,
    event_unit = "A",
  }),
  make_numeric_capability({
    emit_name = "over_voltage_threshold",
    capability_name = "overVoltageThreshold",
    attribute_name = "overVoltageThreshold",
    label = "Over voltage threshold",
    default_range = range(220, 265, 1, "V"),
    event_minimum = 220,
    event_maximum = 265,
    event_unit = "V",
  }),
  make_numeric_capability({
    emit_name = "under_voltage_threshold",
    capability_name = "underVoltageThreshold",
    attribute_name = "underVoltageThreshold",
    label = "Under voltage threshold",
    default_range = range(76, 240, 1, "V"),
    event_minimum = 76,
    event_maximum = 240,
    event_unit = "V",
  }),
}

custom_capabilities.enum = {
  make_enum_capability({
    emit_name = "battery_low",
    capability_name = "batteryLow",
    attribute_name = "batteryLow",
    label = "Battery low",
    supported_values = BATTERY_LOW_VALUES,
    read_only = true,
  }),
  make_enum_capability({
    emit_name = "light_switch",
    attribute_name = "lightSwitch",
    label = "Light switch",
    supported_values = ON_OFF_VALUES,
    read_only = true,
  }),
  make_enum_capability({
    emit_name = "presence_illuminance_switch",
    attribute_name = "presenceIlluminanceSwitch",
    label = "Presence illuminance switch",
    supported_values = ON_OFF_VALUES,
  }),
  make_enum_capability({
    emit_name = "light_linkage",
    attribute_name = "lightLinkage",
    label = "Light linkage",
    supported_values = ON_OFF_VALUES,
  }),
  make_enum_capability({
    emit_name = "breaker_mode",
    attribute_name = "breakerMode",
    supported_attribute_name = "supportedBreakerModes",
    label = "Breaker mode",
    supported_values = STANDARD_LOCAL_VALUES,
  }),
  make_enum_capability({
    emit_name = "breaker_status",
    attribute_name = "breakerStatus",
    label = "Breaker status",
    supported_values = ON_OFF_VALUES,
  }),
  make_enum_capability({
    emit_name = "temperature_breaker",
    capability_name = "temperatureBreaker",
    attribute_name = "temperatureBreaker",
    supported_attribute_name = "supportedTemperatureBreakers",
    label = "Temperature breaker",
    supported_values = ON_OFF_VALUES,
  }),
  make_enum_capability({
    emit_name = "power_breaker",
    capability_name = "powerBreaker",
    attribute_name = "powerBreaker",
    supported_attribute_name = "supportedPowerBreakers",
    label = "Power breaker",
    supported_values = ON_OFF_VALUES,
  }),
  make_enum_capability({
    emit_name = "over_current_breaker",
    capability_name = "overCurrentBreaker",
    attribute_name = "overCurrentBreaker",
    supported_attribute_name = "supportedOverCurrentBreakers",
    label = "Over current breaker",
    supported_values = ON_OFF_VALUES,
  }),
  make_enum_capability({
    emit_name = "over_voltage_breaker",
    capability_name = "overVoltageBreaker",
    attribute_name = "overVoltageBreaker",
    supported_attribute_name = "supportedOverVoltageBreakers",
    label = "Over voltage breaker",
    supported_values = ON_OFF_VALUES,
  }),
  make_enum_capability({
    emit_name = "under_voltage_breaker",
    capability_name = "underVoltageBreaker",
    attribute_name = "underVoltageBreaker",
    supported_attribute_name = "supportedUnderVoltageBreakers",
    label = "Under voltage breaker",
    supported_values = ON_OFF_VALUES,
  }),
  make_enum_capability({
    emit_name = "sensor_state_mode",
    attribute_name = "sensorStateMode",
    supported_attribute_name = "supportedSensorStateModes",
    label = "Sensor state mode",
    supported_values = SENSOR_STATE_MODE_VALUES,
  }),
  make_enum_capability({
    emit_name = "status_indication",
    attribute_name = "statusIndication",
    label = "Status indication",
    supported_values = ON_OFF_VALUES,
  }),
  make_enum_capability({
    emit_name = "indicator_mode",
    capability_name = "indicatorMode",
    attribute_name = "indicatorMode",
    supported_attribute_name = "supportedIndicatorModes",
    label = "Indicator mode",
    supported_values = INDICATOR_MODE_VALUES,
  }),
  make_enum_capability({
    emit_name = "power_on_behavior",
    capability_name = "powerOnBehavior",
    attribute_name = "powerOnBehavior",
    supported_attribute_name = "supportedPowerOnBehaviors",
    label = "Power on behavior",
    supported_values = POWER_ON_BEHAVIOR_VALUES,
  }),
  make_enum_capability({
    emit_name = "power_outage_memory",
    capability_name = "powerOutageMemory",
    attribute_name = "powerOutageMemory",
    supported_attribute_name = "supportedPowerOutageMemories",
    label = "Power outage memory",
    supported_values = POWER_OUTAGE_MEMORY_VALUES,
  }),
  make_enum_capability({
    emit_name = "switch_type",
    capability_name = "switchType",
    attribute_name = "switchType",
    supported_attribute_name = "supportedSwitchTypes",
    label = "Switch type",
    supported_values = SWITCH_TYPE_VALUES,
  }),
  make_enum_capability({
    emit_name = "switch_mode",
    capability_name = "switchMode",
    attribute_name = "switchMode",
    supported_attribute_name = "supportedSwitchModes",
    label = "Switch mode",
    supported_values = SWITCH_MODE_VALUES,
  }),
  make_enum_capability({
    emit_name = "operation_mode",
    capability_name = "operationMode",
    attribute_name = "operationMode",
    supported_attribute_name = "supportedOperationModes",
    label = "Operation mode",
    supported_values = OPERATION_MODE_VALUES,
  }),
  make_enum_capability({
    emit_name = "light_type",
    capability_name = "lightType",
    attribute_name = "lightType",
    supported_attribute_name = "supportedLightTypes",
    label = "Light type",
    supported_values = LIGHT_TYPE_VALUES,
  }),
  make_enum_capability({
    emit_name = "learn_ir_code",
    capability_name = "learnIrCode",
    attribute_name = "learnIrCode",
    supported_attribute_name = "supportedLearnIrCodes",
    command_name = "setLearnIrCode",
    argument_name = "learnIrCode",
    label = "Learn IR code",
    supported_values = LEARN_IR_CODE_VALUES,
  }),
  make_enum_capability({
    emit_name = "security_remote_action",
    capability_name = "securityRemoteAction",
    attribute_name = "securityRemoteAction",
    supported_attribute_name = "supportedSecurityRemoteActions",
    label = "Security remote action",
    supported_values = SECURITY_REMOTE_ACTION_VALUES,
    read_only = true,
  }),
  make_enum_capability({
    emit_name = "liquid_state",
    capability_name = "liquidState",
    attribute_name = "liquidState",
    label = "Liquid state",
    supported_values = { "low", "normal", "high" },
    read_only = true,
  }),
  make_enum_capability({
    emit_name = "motion_detection_mode",
    attribute_name = "motionDetectionMode",
    supported_attribute_name = "supportedMotionDetectionModes",
    label = "Motion detection mode",
    supported_values = { "only_pir", "pir_and_radar", "pir_or_radar", "only_radar" },
  }),
  make_enum_capability({
    emit_name = "radar_scene",
    attribute_name = "radarScene",
    supported_attribute_name = "supportedRadarScenes",
    label = "Radar scene",
    supported_values = { "default", "area", "toilet", "bedroom", "parlour", "office", "hotel", "bathroom", "sleeping", "unknown" },
  }),
  make_enum_capability({
    emit_name = "detection_method",
    attribute_name = "detectionMethod",
    supported_attribute_name = "supportedDetectionMethods",
    label = "Detection method",
    supported_values = { "only_move", "exist_move" },
  }),
  make_enum_capability({
    emit_name = "radar_switch",
    attribute_name = "radarSwitch",
    label = "Radar switch",
    supported_values = ON_OFF_VALUES,
  }),
  make_enum_capability({
    emit_name = "tumble_switch",
    attribute_name = "tumbleSwitch",
    label = "Tumble switch",
    supported_values = ON_OFF_VALUES,
  }),
}

custom_capabilities.text = {
  make_text_capability({
    emit_name = "last_power_response_time",
    capability_name = "lastPowerResponseTime",
    attribute_name = "lastPowerResponseTime",
    label = "Last power response time",
    maximum_length = 64,
  }),
  make_text_capability({
    emit_name = "remote_action",
    capability_name = "remoteAction",
    attribute_name = "remoteAction",
    label = "Remote action",
    maximum_length = 128,
  }),
  make_text_capability({
    emit_name = "learned_ir_code",
    capability_name = "learnedIrCode",
    attribute_name = "learnedIrCode",
    label = "Learned IR code",
    maximum_length = 2048,
  }),
  make_text_capability({
    emit_name = "ir_code_to_send",
    capability_name = "irCodeToSend",
    attribute_name = "irCodeToSend",
    command_name = "setIrCodeToSend",
    argument_name = "irCodeToSend",
    label = "IR code to send",
    maximum_length = 2048,
  }),
}

local function append_definitions(target, source)
  if type(target) ~= "table" or type(source) ~= "table" then
    return
  end

  for _, definition in ipairs(source) do
    target[#target + 1] = definition
  end
end

append_definitions(custom_capabilities.numeric, family_custom_capabilities.numeric)
append_definitions(custom_capabilities.enum, family_custom_capabilities.enum)
append_definitions(custom_capabilities.text, family_custom_capabilities.text)

custom_capabilities.driver_message = {
  emit_name = "driver_message",
  capability_id = "concertmirror08464.driverMessage",
  attribute_name = "driverMessage",
  label = "Driver message",
  maximum_length = 512,
}

custom_capabilities.by_range_key = {}
custom_capabilities.by_emit_name = {}
custom_capabilities.by_capability_id = {}

local function index_metadata(definitions)
  for _, metadata in ipairs(definitions) do
    custom_capabilities.by_emit_name[metadata.emit_name] = metadata
    if type(metadata.capability_id) == "string" and metadata.capability_id ~= "" then
      custom_capabilities.by_capability_id[metadata.capability_id] = metadata
    end
    if type(metadata.range_key) == "string" and metadata.range_key ~= "" then
      custom_capabilities.by_range_key[metadata.range_key] = metadata
    end
  end
end

index_metadata(custom_capabilities.numeric)
index_metadata(custom_capabilities.enum)
index_metadata(custom_capabilities.text)

custom_capabilities.by_emit_name[custom_capabilities.driver_message.emit_name] = custom_capabilities.driver_message
custom_capabilities.by_capability_id[custom_capabilities.driver_message.capability_id] = custom_capabilities.driver_message

local function clone_allowed_values(allowed_values)
  if type(allowed_values) ~= "table" then
    return nil
  end

  local copied = {}
  for index, value in ipairs(allowed_values) do
    copied[index] = value
  end
  return copied
end

function custom_capabilities.resolve_range(definition, metadata)
  if type(metadata) ~= "table" then
    return nil
  end

  local default_range = type(metadata.default_range) == "table" and metadata.default_range or nil
  local ranges = type(definition) == "table" and definition.presence_capability_ranges or nil
  local resolved = type(ranges) == "table" and ranges[metadata.range_key] or nil

  if type(resolved) ~= "table" then
    resolved = default_range
  end

  if type(resolved) ~= "table" then
    return nil
  end

  return {
    minimum = type(resolved.minimum) == "number" and resolved.minimum or (default_range and default_range.minimum or nil),
    maximum = type(resolved.maximum) == "number" and resolved.maximum or (default_range and default_range.maximum or nil),
    step = type(resolved.step) == "number" and resolved.step or (default_range and default_range.step or nil),
    unit = type(resolved.unit) == "string" and resolved.unit or (default_range and default_range.unit or nil),
    allowed_values = type(resolved.allowed_values) == "table"
      and clone_allowed_values(resolved.allowed_values)
      or clone_allowed_values(default_range and default_range.allowed_values or nil),
  }
end

return custom_capabilities
