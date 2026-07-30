local tuya = require "tuya_common"
local emit = require "emitters"
local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local ef00_helpers = require "devices.ef00.helpers"
local converter = tuya.converter
local presence_sensitivity_numeric_converter = converter.lookup_from_to({
[1] = 0,
[2] = 1,
[3] = 2,
})
local presence_sensitivity_high_low_converter = converter.lookup_from_to({
[1] = 1,
[3] = 0,
}, 0)
local keep_time_numeric_converter = converter.lookup_from_to({
[10] = 0,
[30] = 1,
[60] = 2,
[120] = 3,
})
local delay_time_numeric_converter = converter.lookup_from_to({
[15] = 0,
[30] = 1,
[60] = 2,
})
local on_off_bool_converter = converter.lookup_from_to({
on = true,
off = false,
})
local radar_switch_converter = on_off_bool_converter
local zis01p_on_off_converter = converter.lookup_from_to({
ON = true,
OFF = false,
})
local on_off_enum1_converter = converter.lookup_from_to({
on = 1,
off = 0,
})
local tumble_switch_converter = converter.lookup_from_to({
on = 0,
off = 1,
})
local breaker_mode_converter = converter.lookup_from_to({
standard = 0,
["local"] = 1,
})
local motion_detection_mode_zg204zm_converter = converter.lookup_from_to({
only_pir = 0,
pir_and_radar = 1,
only_radar = 2,
})
local radar_scene_mir_converter = converter.lookup_from_to({
default = 0,
area = 1,
toilet = 2,
bedroom = 3,
parlour = 4,
office = 5,
hotel = 6,
})
local radar_scene_yxz_converter = converter.lookup_from_to({
default = 0,
bathroom = 1,
bedroom = 2,
sleeping = 3,
unknown = 4,
})
local detection_method_converter = converter.lookup_from_to({
only_move = 0,
exist_move = 1,
})
local sensor_state_mode_converter = converter.lookup_from_to({
on = 0,
off = 1,
occupied = 2,
unoccupied = 3,
})
local presence_switch_auto_channel_converter = converter.lookup_from_to({
off = 0,
all = 1,
ch1 = 1,
ch2 = 2,
ch3 = 3,
ch1_2 = 4,
ch2_3 = 5,
ch1_3 = 6,
})
local presence_switch_auto_channel_long_converter = converter.lookup_from_to({
off = 0,
all = 1,
ch1 = 1,
ch2 = 2,
ch3 = 3,
ch1_and_ch2 = 4,
ch2_and_ch3 = 5,
ch1_and_ch3 = 6,
})
local presence_switch_trigger_channel_converter = converter.lookup_from_to({
ch1 = 0,
ch2 = 1,
ch3 = 2,
})
local HPS_FORCE_TIME_FIELD = "hps_force_time_update_timer"
local HPS_FORCE_TIME_INTERVAL = 60 * 60
local function start_hourly_hps_time_updates(device, preset)
if device.thread == nil or type(device.thread.call_with_delay) ~= "function" or
type(device.get_field) ~= "function" or type(device.set_field) ~= "function" then
return false
end
local previous_timer = device:get_field(HPS_FORCE_TIME_FIELD)
if previous_timer ~= nil and type(previous_timer.cancel) == "function" then
previous_timer:cancel()
end
local schedule_next
schedule_next = function()
local timer = device.thread:call_with_delay(HPS_FORCE_TIME_INTERVAL, function()
preset:send_time(device)
schedule_next()
end, "HPS hourly time update")
device:set_field(HPS_FORCE_TIME_FIELD, timer, { persist = false })
end
schedule_next()
return true
end
local device_definitions, register_device_definition = device_helpers.definition_registry()
local function copy_options(options)
local resolved = {}
if type(options) == "table" then
for key, value in pairs(options) do
resolved[key] = value
end
end
return resolved
end
local function presence_options(options, name, emitter)
local resolved = copy_options(options)
resolved.name = resolved.name or name
resolved.emit = resolved.emit or emitter
return resolved
end
local function options_has_custom_converter(options)
return options.converter ~= nil or options.from_device ~= nil or options.to_device ~= nil or options.lookup ~= nil
end
local function build_presence_dp(preset_fn, name, emitter_factory, default_converter)
return function(dp, options)
local resolved = presence_options(options, name, emitter_factory())
if default_converter ~= nil and not options_has_custom_converter(resolved) then
resolved.converter = default_converter
end
return preset_fn(dp, resolved)
end
end
local dp_presence_sensitivity_numeric = build_presence_dp(tuya.dp_numeric, "presence_sensitivity", emit.presence_sensitivity)
local dp_presence_sensitivity_low_medium_high = build_presence_dp(tuya.dp_pir_sensitivity, "presence_sensitivity", emit.presence_sensitivity, presence_sensitivity_numeric_converter)
local dp_presence_sensitivity_high_low = build_presence_dp(tuya.dp_enum, "presence_sensitivity", emit.presence_sensitivity, presence_sensitivity_high_low_converter)
local dp_presence_sensitivity_static = build_presence_dp(tuya.dp_static_detection_sensitivity, "presence_sensitivity", emit.presence_sensitivity)
local dp_presence_sensitivity_motion = build_presence_dp(tuya.dp_motion_detection_sensitivity, "presence_sensitivity", emit.presence_sensitivity)
local dp_presence_detection_range = build_presence_dp(tuya.dp_numeric, "presence_detection_range", emit.presence_detection_range)
local dp_presence_detection_range_static = build_presence_dp(tuya.dp_static_detection_distance, "presence_detection_range", emit.presence_detection_range)
local dp_presence_fading_time = build_presence_dp(tuya.dp_fading_time, "presence_fading_time", emit.presence_fading_time)
local dp_presence_target_distance = build_presence_dp(tuya.dp_target_distance, "presence_target_distance", emit.presence_target_distance)
local dp_presence_illuminance_threshold = build_presence_dp(tuya.dp_numeric, "presence_illuminance_threshold", emit.presence_illuminance_threshold)
local dp_light_switch_cap = build_presence_dp(tuya.dp_binary, "light_switch", emit.light_switch, on_off_bool_converter)
local dp_presence_illuminance_switch_cap = build_presence_dp(tuya.dp_enum, "presence_illuminance_switch", emit.presence_illuminance_switch, on_off_enum1_converter)
local dp_light_linkage_cap = build_presence_dp(tuya.dp_enum, "light_linkage", emit.light_linkage, on_off_enum1_converter)
local dp_breaker_mode_cap = build_presence_dp(tuya.dp_enum, "breaker_mode", emit.breaker_mode, breaker_mode_converter)
local dp_breaker_status_cap = build_presence_dp(tuya.dp_enum, "breaker_status", emit.breaker_status, on_off_enum1_converter)
local dp_sensor_state_mode_cap = build_presence_dp(tuya.dp_enum, "sensor_state_mode", emit.sensor_state_mode, sensor_state_mode_converter)
local dp_status_indication_cap = build_presence_dp(tuya.dp_enum, "status_indication", emit.status_indication, on_off_enum1_converter)
local dp_motion_detection_mode_cap = build_presence_dp(tuya.dp_motion_detection_mode, "motion_detection_mode", emit.motion_detection_mode)
local dp_radar_scene_cap = build_presence_dp(tuya.dp_enum, "radar_scene", emit.radar_scene)
local dp_detection_method_cap = build_presence_dp(tuya.dp_enum, "detection_method", emit.detection_method, detection_method_converter)
local dp_radar_switch_cap = build_presence_dp(tuya.dp_binary, "radar_switch", emit.radar_switch, radar_switch_converter)
local dp_tumble_switch_cap = build_presence_dp(tuya.dp_enum, "tumble_switch", emit.tumble_switch, tumble_switch_converter)
local dp_static_detection_sensitivity_cap = build_presence_dp(tuya.dp_static_detection_sensitivity, "static_detection_sensitivity", emit.static_detection_sensitivity)
local dp_motion_detection_sensitivity_cap = build_presence_dp(tuya.dp_motion_detection_sensitivity, "motion_detection_sensitivity", emit.motion_detection_sensitivity)
local dp_move_sensitivity_cap = build_presence_dp(tuya.dp_numeric, "move_sensitivity", emit.move_sensitivity)
local dp_keep_sensitivity_cap = build_presence_dp(tuya.dp_numeric, "keep_sensitivity", emit.keep_sensitivity)
local dp_trigger_sensitivity_cap = build_presence_dp(tuya.dp_numeric, "trigger_sensitivity", emit.trigger_sensitivity)
local dp_entry_sensitivity_cap = build_presence_dp(tuya.dp_numeric, "entry_sensitivity", emit.entry_sensitivity)
local dp_fall_sensitivity_cap = build_presence_dp(tuya.dp_numeric, "fall_sensitivity", emit.fall_sensitivity)
local dp_tumble_alarm_time_cap = build_presence_dp(tuya.dp_numeric, "tumble_alarm_time", emit.tumble_alarm_time)
local dp_large_motion_detection_sensitivity_cap = build_presence_dp(tuya.dp_numeric, "large_motion_detection_sensitivity", emit.large_motion_detection_sensitivity)
local dp_medium_motion_detection_sensitivity_cap = build_presence_dp(tuya.dp_numeric, "medium_motion_detection_sensitivity", emit.medium_motion_detection_sensitivity)
local dp_small_motion_detection_sensitivity_cap = build_presence_dp(tuya.dp_numeric, "small_motion_detection_sensitivity", emit.small_motion_detection_sensitivity)
local dp_small_move_sensitivity_cap = build_presence_dp(tuya.dp_numeric, "small_move_sensitivity", emit.small_move_sensitivity)
local dp_breath_sensitivity_cap = build_presence_dp(tuya.dp_numeric, "breath_sensitivity", emit.breath_sensitivity)
local dp_large_motion_detection_distance_cap = build_presence_dp(tuya.dp_numeric, "large_motion_detection_distance", emit.large_motion_detection_distance)
local dp_medium_motion_detection_distance_cap = build_presence_dp(tuya.dp_numeric, "medium_motion_detection_distance", emit.medium_motion_detection_distance)
local dp_small_motion_detection_distance_cap = build_presence_dp(tuya.dp_numeric, "small_motion_detection_distance", emit.small_motion_detection_distance)
local dp_move_detection_max_distance_cap = build_presence_dp(tuya.dp_numeric, "move_detection_max_distance", emit.move_detection_max_distance)
local dp_move_detection_min_distance_cap = build_presence_dp(tuya.dp_numeric, "move_detection_min_distance", emit.move_detection_min_distance)
local dp_small_move_detection_max_distance_cap = build_presence_dp(tuya.dp_numeric, "small_move_detection_max_distance", emit.small_move_detection_max_distance)
local dp_small_move_detection_min_distance_cap = build_presence_dp(tuya.dp_numeric, "small_move_detection_min_distance", emit.small_move_detection_min_distance)
local dp_breath_detection_max_distance_cap = build_presence_dp(tuya.dp_numeric, "breath_detection_max_distance", emit.breath_detection_max_distance)
local dp_breath_detection_min_distance_cap = build_presence_dp(tuya.dp_numeric, "breath_detection_min_distance", emit.breath_detection_min_distance)
local dp_minimum_range_cap = build_presence_dp(tuya.dp_numeric, "minimum_range", emit.minimum_range)
local dp_detection_delay_cap = build_presence_dp(tuya.dp_numeric, "detection_delay", emit.detection_delay)
local dp_keep_time_cap = build_presence_dp(tuya.dp_keep_time, "keep_time", emit.keep_time, keep_time_numeric_converter)
local dp_presence_delay_cap = build_presence_dp(tuya.dp_numeric, "presence_delay", emit.presence_delay)
local dp_presence_delay_enum_cap = build_presence_dp(tuya.dp_enum, "presence_delay", emit.presence_delay, delay_time_numeric_converter)
local dp_presence_time_cap = build_presence_dp(tuya.dp_numeric, "presence_time", emit.presence_time)
local dp_detection_cycle_cap = build_presence_dp(tuya.dp_numeric, "detection_cycle", emit.detection_cycle)
local dp_illuminance_threshold_min_cap = build_presence_dp(tuya.dp_numeric, "illuminance_threshold_min", emit.illuminance_threshold_min)
local dp_shield_range_cap = build_presence_dp(tuya.dp_numeric, "shield_range", emit.shield_range)
local dp_entry_filter_time_cap = build_presence_dp(tuya.dp_numeric, "entry_filter_time", emit.entry_filter_time)
local dp_entry_distance_indentation_cap = build_presence_dp(tuya.dp_numeric, "entry_distance_indentation", emit.entry_distance_indentation)
local dp_block_time_cap = build_presence_dp(tuya.dp_numeric, "block_time", emit.block_time)
local function capability_range(minimum, maximum, step, unit)
local range = {
minimum = minimum,
maximum = maximum,
step = step,
}
if type(unit) == "string" and unit ~= "" then
range.unit = unit
end
return range
end
local function capability_range_with_allowed_values(minimum, maximum, step, allowed_values, unit)
local range = capability_range(minimum, maximum, step, unit)
if type(allowed_values) == "table" then
range.allowed_values = allowed_values
end
return range
end
local function capability_values(values)
return {
allowed_values = values,
}
end
local ON_OFF_VALUES = { "on", "off" }
local STANDARD_LOCAL_VALUES = { "standard", "local" }
local SENSOR_STATE_MODE_VALUES = { "on", "off", "occupied", "unoccupied" }
local function register_presence_definition(definitions_or_table, fingerprint_list, ranges)
local query_on_configure = true
if type(definitions_or_table) == "table" and definitions_or_table.query_on_configure ~= nil then
query_on_configure = definitions_or_table.query_on_configure
end
if type(ranges) == "table" then
register_device_definition({
datapoints = definitions_or_table,
presence_capability_ranges = ranges,
query_on_configure = query_on_configure,
}, fingerprint_list)
return
end
if type(definitions_or_table) == "table" then
local entry = {}
for key, value in pairs(definitions_or_table) do
entry[key] = value
end
if entry.query_on_configure == nil then
entry.query_on_configure = true
end
register_device_definition(entry, fingerprint_list)
return
end
register_device_definition({
datapoints = definitions_or_table,
query_on_configure = true,
}, fingerprint_list)
end
local function ts0601_fingerprints(manufacturer_names)
return ef00_helpers.ts0601_fingerprints( manufacturer_names)
end
local PRESENCE_SENSITIVITY_LOW_MEDIUM_HIGH_RANGE = capability_range(1, 3, 1)
local KEEP_TIME_PRESET_RANGE = {
minimum = 10,
maximum = 120,
step = 1,
unit = "s",
allowed_values = { 10, 30, 60, 120 },
}
local MOVE_SENSITIVITY_TEN_RANGE = capability_range(1, 10, 1)
local PRESENCE_SENSITIVITY_TEN_RANGE = capability_range(1, 10, 1)
local PRESENCE_DETECTION_RANGE_075_90_RANGE = capability_range(0.75, 9.0, 0.75, "m")
local PRESENCE_FADING_TIME_1500_RANGE = capability_range(1, 1500, 1, "s")
local PRESENCE_FADING_TIME_15000_RANGE = capability_range(1, 15000, 1, "s")
local function raw_humidity_options()
return {
emit = emit.humidity(),
scale = 1,
}
end
local raw_non_zero_converter = converter.from_only(function(value)
local number_value = tonumber(value)
return number_value ~= nil and number_value ~= 0
end)
local msa201_presence_converter = converter.from_only(function(value)
return tonumber(value) == 1
end)
local presence_basic = {
profile = "safety-presence-basic-delay-battery",
datapoints = {
tuya.dp_presence(1, { emit = emit.presence(), read_only = true }),
tuya.dp_battery(4, { emit = emit.battery(), read_only = true }),
tuya.dp_enum(9, {
name = "sensitivity",
emit = emit.ihsenoPresenceSensitivity(),
converter = converter.lookup_from_to({ low = 0, middle = 1, high = 2 }),
}),
tuya.dp_enum(10, {
name = "delay_time",
emit = emit.ihsenoPresenceDelayTime(),
converter = converter.lookup_from_to({ ["15s"] = 0, ["30s"] = 1, ["60s"] = 2 }),
}),
},
query_on_configure = false,
}
register_presence_definition(presence_basic, ts0601_fingerprints({
"_TZE284_debczeci",
"_TZE284_1lvln0x6",
"_TZE204_debczeci",
}))
local presence_pir24g = {
profile = "safety-presence-pir24g-dedicated-illuminance-battery",
datapoints = {
tuya.dp_presence(1, { emit = emit.presence(), read_only = true }),
tuya.dp_battery(4, { emit = emit.battery(), read_only = true }),
tuya.dp_illuminance(12, { emit = emit.illuminance(), read_only = true }),
tuya.dp_numeric(101, { name = "detection_distance", emit = emit.pir24gDetectionDistance() }),
tuya.dp_numeric(103, { name = "fading_time", emit = emit.pir24gFadingTime() }),
tuya.dp_enum(104, {
name = "last_time",
emit = emit.pir24gLastTime(),
converter = converter.lookup_from_to({ pir = 0, none = 1 }),
read_only = true,
}),
tuya.dp_numeric(105, {
name = "static_detection_sensitivity",
emit = emit.pir24gStaticSensitivity(),
}),
tuya.dp_numeric(106, {
name = "motion_detection_sensitivity",
emit = emit.pir24gMotionSensitivity(),
}),
},
query_on_configure = false,
}
register_presence_definition(presence_pir24g, ts0601_fingerprints({
"_TZE200_juzago6i",
}))
local presence_model_zf24 = {
profile = "safety-presence-zf24-move-illuminance",
datapoints = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1(), read_only = true }),
tuya.dp_numeric(2, { name = "move_sensitivity", emit = emit.zf24MoveSensitivity() }),
tuya.dp_static_detection_distance(4, {
name = "detection_distance_max",
emit = emit.zf24DetectionDistanceMax(),
}),
tuya.dp_target_distance(9, { name = "distance", read_only = true, emit = emit.zf24Distance() }),
tuya.dp_numeric(101, { name = "presence_timeout", emit = emit.zf24PresenceTimeout() }),
tuya.dp_illuminance(102, { emit = emit.illuminance(), read_only = true }),
tuya.dp_numeric(103, { name = "presence_sensitivity", emit = emit.zf24PresenceSensitivity() }),
tuya.dp_binary(104, { name = "state", emit = emit.zf24Function(), converter = on_off_bool_converter }),
tuya.dp_binary(105, { name = "living_room", emit = emit.zf24LivingRoom(), converter = on_off_bool_converter }),
tuya.dp_binary(106, { name = "bedroom", emit = emit.zf24Bedroom(), converter = on_off_bool_converter }),
tuya.dp_binary(107, { name = "bathroom", emit = emit.zf24Bathroom(), converter = on_off_bool_converter }),
tuya.dp_binary(108, { name = "sleep", emit = emit.zf24Sleep(), converter = on_off_bool_converter }),
tuya.dp_binary(109, {
name = "radar_switch",
emit = emit.zf24RadarSwitch(),
converter = radar_switch_converter,
}),
},
query_on_configure = false,
}
register_presence_definition(presence_model_zf24, ts0601_fingerprints({
"_TZE284_pzm3wab5",
"_TZE284_twybxdzl",
"_TZE284_hgeqeyuv",
"_TZE28C1000000_hgeqeyuv",
"_TZE28C1000000_pzm3wab5",
"_TZE28C1000000_twybxdzl",
}))
local presence_model_zg204zx = {
profile = "safety-presence-illuminance-temp-humidity-battery-zg204zx",
datapoints = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1(), read_only = true }),
tuya.dp_numeric(123, { name = "motion_detection_sensitivity", emit = emit.motionDetectionSensitivityZg204zx() }),
tuya.dp_static_detection_sensitivity(2, { emit = emit.staticDetectionSensitivityZg204zx() }),
tuya.dp_static_detection_distance(4, { name = "detection_distance", emit = emit.presenceDetectionRangeZg204zx() }),
tuya.dp_fading_time(102, { name = "fading_time", emit = emit.presenceFadingTimeZg204zx() }),
tuya.dp_binary(103, {
name = "anti_interference",
emit = emit.antiInterferenceZg204zx(),
converter = on_off_bool_converter,
}),
tuya.dp_humidity_calibration(104, { emit = emit.humidityCalibrationZg204zx() }),
tuya.dp_temperature_calibration(105, { emit = emit.temperatureCalibrationZg204zx() }),
tuya.dp_illuminance(106, { emit = emit.illuminance(), read_only = true }),
tuya.dp_illuminance_interval(107, { emit = emit.illuminanceIntervalZg204zx() }),
tuya.dp_binary(108, {
name = "indicator",
emit = emit.indicatorZg204zx(),
converter = on_off_bool_converter,
}),
tuya.dp_temperature_unit(109, { emit = emit.temperatureUnitZg204zx() }),
tuya.dp_battery(110, { emit = emit.battery(), read_only = true }),
tuya.dp_temperature(111, { emit = emit.temperature("C"), scale = 10, read_only = true }),
tuya.dp_humidity(101, { emit = emit.humidity(), read_only = true }),
},
query_on_configure = false,
}
register_presence_definition(presence_model_zg204zx, ts0601_fingerprints({
"_TZE200_w0ap83qu",
}))
local presence_model_excellux_zg301a = {
profile = "safety-presence-excellux-zg301a",
datapoints = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1(), read_only = true }),
tuya.dp_binary(13, {
name = "light_trigger",
emit = emit.zg301aLightTrigger(),
converter = on_off_bool_converter,
}),
tuya.dp_battery(14, { emit = emit.battery(), read_only = true }),
tuya.dp_illuminance(20, { emit = emit.illuminance(), read_only = true }),
tuya.dp_numeric(100, { name = "bright_value", emit = emit.zg301aBrightValue() }),
tuya.dp_numeric(101, { name = "illuminance_trig", emit = emit.zg301aIlluminanceTrigger() }),
tuya.dp_numeric(102, { name = "presence_time", emit = emit.zg301aPresenceTime() }),
tuya.dp_numeric(103, { name = "presence_delay", emit = emit.zg301aPresenceDelay() }),
tuya.dp_numeric(104, { name = "detection_cycle", emit = emit.zg301aDetectionCycle() }),
},
query_on_configure = false,
}
register_presence_definition(presence_model_excellux_zg301a, {
device_helpers.create_fingerprint("C6B7KM9", "Excellux"),
})
local presence_model_zd24 = {
profile = "safety-presence-zd24-illuminance-battery",
datapoints = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_numeric(4, { name = "distance", read_only = true, emit = emit.zd24Distance() }),
tuya.dp_enum(11, {
name = "motion_state",
read_only = true,
emit = emit.zd24MotionState(),
converter = converter.from_only(converter.lookup_value({
[0] = "none",
[1] = "static",
[2] = "small",
[3] = "large",
})),
}),
tuya.dp_numeric(12, { name = "fading_time", emit = emit.zd24FadingTime() }),
tuya.dp_numeric(15, {
name = "motion_detection_sensitivity",
emit = emit.zd24MotionSensitivity(),
}),
tuya.dp_numeric(16, {
name = "static_detection_sensitivity",
emit = emit.zd24StaticSensitivity(),
}),
tuya.dp_illuminance(20, { emit = emit.illuminance() }),
tuya.dp_battery(81, { emit = emit.battery() }),
tuya.dp_on_off(101, {
name = "init",
emit = emit.zd24Init(),
converter = on_off_bool_converter,
}),
tuya.dp_enum(102, {
name = "motion_detection_mode",
emit = emit.zd24MotionDetectionMode(),
converter = converter.lookup_from_to({
pir_and_radar = 0,
only_radar = 1,
pir_or_radar = 2,
}),
}),
},
query_on_configure = true,
}
register_presence_definition(presence_model_zd24, device_helpers.create_fingerprints("TS0601", {
"_TZE284_bw4ayyeh",
}))
local presence_model_mir_he200_ty = {
profile = "safety-presence-mirhe200-illuminance-fall",
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_numeric(2, { name = "radar_sensitivity", emit = emit.mirhe200RadarSensitivity() }),
tuya.dp_occupancy(102, { emit = emit.occupancy(), converter = converter.true_false1() }),
tuya.dp_illuminance(103, { emit = emit.illuminance() }),
tuya.dp_enum(105, {
name = "tumble_switch",
emit = emit.mirhe200TumbleSwitch(),
converter = tumble_switch_converter,
}),
tuya.dp_numeric(106, { name = "tumble_alarm_time", emit = emit.mirhe200TumbleAlarmTime() }),
tuya.dp_enum(112, {
name = "radar_scene",
emit = emit.mirhe200RadarScene(),
converter = radar_scene_mir_converter,
}),
tuya.dp_enum(114, {
name = "motion_direction",
read_only = true,
emit = emit.mirhe200MotionDirection(),
converter = converter.from_only(converter.lookup_value({
[0] = "standing_still",
[1] = "moving_forward",
[2] = "moving_backward",
})),
}),
tuya.dp_numeric(115, { name = "motion_speed", read_only = true, emit = emit.mirhe200MotionSpeed() }),
tuya.dp_enum(116, {
name = "fall_down_status",
read_only = true,
emit = emit.mirhe200FallDownStatus(),
converter = converter.from_only(converter.lookup_value({
[0] = "none",
[1] = "maybe_fall",
[2] = "fall",
})),
}),
tuya.dp_numeric(117, {
name = "static_dwell_alarm",
read_only = true,
emit = emit.mirhe200StaticDwellAlarm(),
}),
tuya.dp_numeric(118, { name = "fall_sensitivity", emit = emit.mirhe200FallSensitivity() }),
}
register_presence_definition(presence_model_mir_he200_ty, ts0601_fingerprints({
"_TZE200_lu01t0zl",
"_TZE200_vrfecyku",
"_TZE200_ypprdwsl",
"_TZE200_jkbljri7",
"_TZE204_bvfld3xc",
}))
local presence_model_zy_m100_l = {
profile = "safety-presence-zym100l-fixed-illuminance",
tuya.dp_presence(1, { emit = emit.presence() }),
tuya.dp_numeric(2, { name = "presence_sensitivity", emit = emit.presenceSensitivityZym100l() }),
tuya.dp_numeric(3, { name = "minimum_range", scale = 100, emit = emit.minimumRangeZym100l() }),
tuya.dp_numeric(4, { name = "presence_detection_range", scale = 100, emit = emit.presenceDetectionRangeZym100l() }),
tuya.dp_enum(6, {
name = "self_test",
read_only = true,
emit = emit.zym100lSelfTest(),
converter = converter.from_only(converter.lookup_value({
[0] = "checking",
[1] = "check_success",
[2] = "check_failure",
[3] = "others",
[4] = "comm_fault",
[5] = "radar_fault",
})),
}),
tuya.dp_numeric(9, { name = "presence_target_distance", scale = 100, emit = emit.presenceTargetDistanceZym100l() }),
tuya.dp_numeric(101, { name = "detection_delay", scale = 10, emit = emit.detectionDelayZym100l() }),
tuya.dp_numeric(102, { name = "presence_fading_time", scale = 10, emit = emit.presenceFadingTimeZym100l() }),
tuya.dp_illuminance(104, { emit = emit.illuminance() }),
}
register_presence_definition(presence_model_zy_m100_l, ts0601_fingerprints({
"_TZE200_ikvncluo",
"_TZE200_lyetpprm",
"_TZE200_jva8ink8",
"_TZE204_xpq2rzhq",
"_TZE200_holel4dk",
"_TZE200_xpq2rzhq",
"_TZE200_wukb7rhc",
"_TZE204_xsm7l9xa",
"_TZE204_ztc6ggyl",
"_TZE200_ztc6ggyl",
"_TZE200_sgpeacqp",
"_TZE204_fwondbzy",
"_TZE284_fwondbzy",
}))
register_presence_definition(presence_model_zy_m100_l, {
device_helpers.create_fingerprint("Tuya", "ZY-M100-L"),
device_helpers.create_fingerprint("Moes", "ZSS-QY-HP"),
})
local presence_model_y1_in = {
profile = "safety-presence-y1in-dedicated-illuminance",
datapoints = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1(), read_only = true }),
tuya.dp_fading_time(102, { emit = emit.y1inFadingTime() }),
tuya.dp_illuminance(103, { emit = emit.illuminance(), read_only = true }),
tuya.dp_numeric(110, { name = "keep_sensitivity", emit = emit.y1inKeepSensitivity() }),
tuya.dp_numeric(114, { name = "trigger_sensitivity", emit = emit.y1inTriggerSensitivity() }),
tuya.dp_numeric(182, {
name = "target_distance",
converter = converter.divide_by_pair(10),
emit = emit.y1inTargetDistance(),
read_only = true,
}),
},
query_on_configure = false,
}
register_device_definition(presence_model_y1_in, ts0601_fingerprints({
"_TZE204_bmdsp6bs",
}))
local presence_model_zy_m100_s_1 = {
profile = "safety-presence-zym100s1-range-illuminance",
tuya.dp_illuminance(104, { emit = emit.illuminance() }),
tuya.dp_presence(105, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_numeric(106, { name = "radar_sensitivity", emit = emit.zym100s1RadarSensitivity() }),
tuya.dp_numeric(107, { name = "maximum_range", scale = 100, emit = emit.zym100s1MaximumRange() }),
tuya.dp_numeric(108, { name = "minimum_range", scale = 100, emit = emit.zym100s1MinimumRange() }),
tuya.dp_numeric(109, {
name = "target_distance",
scale = 100,
read_only = true,
emit = emit.zym100s1TargetDistance(),
}),
tuya.dp_numeric(110, { name = "fading_time", scale = 10, emit = emit.zym100s1FadingTime() }),
tuya.dp_numeric(111, { name = "detection_delay", scale = 10, emit = emit.zym100s1DetectionDelay() }),
}
register_presence_definition(presence_model_zy_m100_s_1, ts0601_fingerprints({
"_TZE204_sxm7l9xa",
"_TZE204_e5m9c5hl",
}))
register_presence_definition(presence_model_zy_m100_s_1, {
device_helpers.create_fingerprint("Wenzhi", "WZ-M100-W"),
})
local presence_model_zy_m100_s_2 = {
profile = "safety-presence-zym100s2-range-illuminance",
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_numeric(2, { name = "radar_sensitivity", emit = emit.zym100s2RadarSensitivity() }),
tuya.dp_numeric(3, { name = "minimum_range", scale = 100, emit = emit.zym100s2MinimumRange() }),
tuya.dp_numeric(4, { name = "maximum_range", scale = 100, emit = emit.zym100s2MaximumRange() }),
tuya.dp_numeric(9, {
name = "target_distance",
scale = 100,
read_only = true,
emit = emit.zym100s2TargetDistance(),
}),
tuya.dp_numeric(101, { name = "detection_delay", scale = 10, emit = emit.zym100s2DetectionDelay() }),
tuya.dp_numeric(102, { name = "fading_time", scale = 10, emit = emit.zym100s2FadingTime() }),
tuya.dp_illuminance(104, { emit = emit.illuminance() }),
}
register_presence_definition(presence_model_zy_m100_s_2, ts0601_fingerprints({
"_TZE204_qasjif9e",
"_TZE200_qasjif9e",
"_TZE204_ztqnh5cg",
"_TZE204_iadro9bf",
}))
register_presence_definition(presence_model_zy_m100_s_2, {
device_helpers.create_fingerprint("iHseno", "TY_24G_Sensor_V2"),
})
local presence_model_zy_m100_s_2_iadro9bf = {
profile = "safety-presence-zym100s2-range-illuminance",
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false0() }),
tuya.dp_numeric(2, { name = "radar_sensitivity", emit = emit.zym100s2RadarSensitivity() }),
tuya.dp_numeric(3, { name = "minimum_range", scale = 100, emit = emit.zym100s2MinimumRange() }),
tuya.dp_numeric(4, { name = "maximum_range", scale = 100, emit = emit.zym100s2MaximumRange() }),
tuya.dp_numeric(9, {
name = "target_distance",
scale = 100,
read_only = true,
emit = emit.zym100s2TargetDistance(),
}),
tuya.dp_illuminance(12, { emit = emit.illuminance() }),
tuya.dp_numeric(101, { name = "detection_delay", scale = 10, emit = emit.zym100s2DetectionDelay() }),
tuya.dp_numeric(102, { name = "fading_time", scale = 10, emit = emit.zym100s2FadingTime() }),
}
register_presence_definition(presence_model_zy_m100_s_2_iadro9bf, ts0601_fingerprints({
"_TZE284_iadro9bf",
}))
local presence_model_wz_m100 = {
profile = "safety-presence-wzm100-range-delay-illuminance",
datapoints = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1(), read_only = true }),
tuya.dp_numeric(2, { name = "sensitivity", emit = emit.wzM100Sensitivity() }),
tuya.dp_numeric(3, {
name = "minimum_range",
converter = converter.divide_by_pair(100),
emit = emit.wzM100MinimumRange(),
}),
tuya.dp_numeric(4, {
name = "maximum_range",
converter = converter.divide_by_pair(100),
emit = emit.wzM100MaximumRange(),
}),
tuya.dp_numeric(9, {
name = "target_distance",
converter = converter.divide_by_pair(100),
emit = emit.wzM100TargetDistance(),
read_only = true,
}),
tuya.dp_illuminance(103, { emit = emit.illuminance(), read_only = true }),
tuya.dp_numeric(104, { name = "interval_time", emit = emit.wzM100IntervalTime() }),
tuya.dp_numeric(105, {
name = "detection_delay",
converter = converter.divide_by_pair(10),
emit = emit.wzM100DetectionDelay(),
}),
tuya.dp_numeric(106, {
name = "fading_time",
converter = converter.divide_by_pair(10),
emit = emit.wzM100FadingTime(),
}),
},
query_on_configure = false,
}
register_device_definition(presence_model_wz_m100, ts0601_fingerprints({
"_TZE204_laokfqwu",
}))
local presence_hps = {
profile = "safety-presence-hps-duration-led",
time_start = "1970",
runtime_start = start_hourly_hps_time_updates,
datapoints = {
tuya.dp_presence(1, {
emit = emit.presence(),
converter = converter.true_false1(),
read_only = true,
}),
tuya.dp_numeric(101, {
name = "duration_of_attendance",
emit = emit.hpsAttendanceDuration(),
read_only = true,
}),
tuya.dp_numeric(102, {
name = "duration_of_absence",
emit = emit.hpsAbsenceDuration(),
read_only = true,
}),
tuya.dp_binary(103, {
name = "led_state",
emit = emit.hpsLedState(),
converter = on_off_bool_converter,
}),
},
query_on_configure = false,
}
register_device_definition(presence_hps, ts0601_fingerprints({
"_TZE200_0u3bj3rc",
"_TZE200_v6ossqfy",
"_TZE200_mx6u6l4y",
}))
local presence_model_zy_hps01 = {
tuya.dp_illuminance(12, { emit = emit.illuminance() }),
tuya.dp_occupancy(101, { emit = emit.occupancy(), converter = converter.true_false0() }),
tuya.dp_numeric(104, { name = "presence_timeout", emit = emit.zyhps01PresenceTimeout() }),
tuya.dp_numeric(105, { name = "move_sensitivity", emit = emit.zyhps01MoveSensitivity() }),
tuya.dp_numeric(107, { name = "breath_sensitivity", emit = emit.zyhps01BreathSensitivity() }),
tuya.dp_numeric(109, { name = "move_maximum_range", emit = emit.zyhps01MoveMaximumRange() }),
tuya.dp_numeric(110, { name = "move_minimum_range", emit = emit.zyhps01MoveMinimumRange() }),
tuya.dp_numeric(111, { name = "breath_maximum_range", emit = emit.zyhps01BreathMaximumRange() }),
tuya.dp_numeric(112, { name = "breath_minimum_range", emit = emit.zyhps01BreathMinimumRange() }),
}
local presence_model_zy_hps01_entry = {
profile = "safety-presence-zy-hps01-illuminance",
datapoints = presence_model_zy_hps01,
query_on_configure = true,
}
register_device_definition(presence_model_zy_hps01_entry, ts0601_fingerprints({
"_TZE204_ex3rcdha",
"_TZE204_lbbg34rj",
}))
register_device_definition(presence_model_zy_hps01_entry, {
device_helpers.create_fingerprint("Nova Digital", "ZTS-MM"),
})
local presence_model_zg_204zm = {
profile = "safety-presence-zg204zm-illuminance-battery",
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_static_detection_sensitivity(2, { emit = emit.zg204zmStaticSensitivity() }),
tuya.dp_static_detection_distance(4, {
name = "static_detection_distance",
emit = emit.zg204zmStaticDistance(),
}),
tuya.dp_motion_state(101, {
read_only = true,
emit = emit.zg204zmMotionState(),
converter = converter.from_only(converter.lookup_value({
[0] = "none",
[1] = "large",
[2] = "small",
[3] = "static",
})),
}),
tuya.dp_fading_time(102, { emit = emit.zg204zmFadingTime() }),
tuya.dp_illuminance(106, { emit = emit.illuminance() }),
tuya.dp_indicator(107, {
emit = emit.zg204zmIndicator(),
converter = on_off_bool_converter,
}),
tuya.dp_battery(121, { emit = emit.battery() }),
tuya.dp_motion_detection_mode(122, {
emit = emit.zg204zmMotionDetectionMode(),
converter = motion_detection_mode_zg204zm_converter,
}),
tuya.dp_motion_detection_sensitivity(123, { emit = emit.zg204zmMotionSensitivity() }),
}
register_presence_definition(presence_model_zg_204zm, {
device_helpers.create_fingerprint("AOYAN", "AY205Z"),
device_helpers.create_fingerprint("_TZE200_2aaelwxk", "TS0601"),
device_helpers.create_fingerprint("_TZE200_2aaelwxk", "TS0225"),
device_helpers.create_fingerprint("_TZE200_kb5noeto", "TS0601"),
device_helpers.create_fingerprint("_TZE200_tyffvoij", "TS0601"),
device_helpers.create_fingerprint("_TZE200_yflzeeqj", "TS0601"),
})
local presence_model_zg_204zk = {
profile = "safety-presence-zg204zk-battery",
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_static_detection_sensitivity(2, { emit = emit.zg204zkStaticSensitivity() }),
tuya.dp_static_detection_distance(4, {
name = "detection_distance",
emit = emit.zg204zkDetectionDistance(),
}),
tuya.dp_fading_time(102, { emit = emit.zg204zkFadingTime() }),
tuya.dp_illuminance(106, {}),
tuya.dp_indicator(107, {
emit = emit.zg204zkIndicator(),
converter = on_off_bool_converter,
}),
tuya.dp_battery(121, { emit = emit.battery() }),
tuya.dp_binary(122, {
name = "anti_interference",
emit = emit.zg204zkAntiInterference(),
converter = on_off_bool_converter,
}),
tuya.dp_motion_detection_sensitivity(123, { emit = emit.zg204zkMotionSensitivity() }),
}
register_presence_definition(presence_model_zg_204zk, {
device_helpers.create_fingerprint("_TZE200_ka8l86iu", "TS0601"),
device_helpers.create_fingerprint("_TZE200_zbfmvj13", "TS0601"),
device_helpers.create_fingerprint("HOBEIAN", "ZG-204ZK"),
})
local presence_model_zg_204ze = {
profile = "safety-presence-zg204ze-illuminance-battery",
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_motion_detection_sensitivity(2, { emit = emit.zg204zeMotionSensitivity() }),
tuya.dp_fading_time(102, { emit = emit.zg204zeFadingTime() }),
tuya.dp_illuminance(106, { emit = emit.illuminance() }),
tuya.dp_illuminance_interval(107, { emit = emit.zg204zeIlluminanceInterval() }),
tuya.dp_indicator(108, {
emit = emit.zg204zeIndicator(),
converter = on_off_bool_converter,
}),
tuya.dp_battery(110, { emit = emit.battery() }),
}
register_presence_definition(presence_model_zg_204ze, {
device_helpers.create_fingerprint("ZG-204ZE", "CK-BL702-MWS-01(7016)"),
device_helpers.create_fingerprint("_TZE200_cq8lu23i", "TS0601"),
device_helpers.create_fingerprint("_TZE200_4pm4pekt", "TS0601"),
device_helpers.create_fingerprint("_TZE200_y8jijhba", "TS0601"),
device_helpers.create_fingerprint("HOBEIAN", "ZG-204ZE"),
})
local presence_model_zg_204zv = {
profile = "safety-presence-zg204zv-illuminance-temp-humidity-battery",
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_motion_detection_sensitivity(2, { emit = emit.zg204zvMotionSensitivity() }),
tuya.dp_humidity(101, raw_humidity_options()),
tuya.dp_fading_time(102, { emit = emit.zg204zvFadingTime() }),
tuya.dp_humidity_calibration(104, { emit = emit.zg204zvHumidityCalibration() }),
tuya.dp_temperature_calibration(105, { emit = emit.zg204zvTemperatureCalibration() }),
tuya.dp_illuminance(106, { emit = emit.illuminance() }),
tuya.dp_illuminance_interval(107, { emit = emit.zg204zvIlluminanceInterval() }),
tuya.dp_indicator(108, {
emit = emit.zg204zvIndicator(),
converter = on_off_bool_converter,
}),
tuya.dp_temperature_unit(109, { emit = emit.zg204zvTemperatureUnit() }),
tuya.dp_battery(110, { emit = emit.battery() }),
tuya.dp_temperature(111, { emit = emit.temperature() }),
}
register_presence_definition(presence_model_zg_204zv, ts0601_fingerprints({
"_TZE200_uli8wasj",
"_TZE200_grgol3xp",
"_TZE200_rhgsbacq",
"HOBEIAN:ZG-204ZV",
}))
local presence_model_zg_204zh = {
profile = "safety-presence-zg204zh-illuminance-temp-humidity-battery",
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_static_detection_sensitivity(2, { emit = emit.zg204zhStaticSensitivity() }),
tuya.dp_numeric(4, {
name = "static_detection_distance",
scale = 100,
emit = emit.zg204zhStaticDistance(),
}),
tuya.dp_humidity(101, raw_humidity_options()),
tuya.dp_fading_time(102, { emit = emit.zg204zhFadingTime() }),
tuya.dp_enum(103, {
name = "motion_state",
read_only = true,
emit = emit.zg204zhMotionState(),
converter = converter.from_only(converter.lookup_value({
[0] = "none",
[1] = "large",
[2] = "small",
[3] = "static",
})),
}),
tuya.dp_humidity_calibration(104, { emit = emit.zg204zhHumidityCalibration() }),
tuya.dp_temperature_calibration(105, { emit = emit.zg204zhTemperatureCalibration() }),
tuya.dp_illuminance(106, { emit = emit.illuminance() }),
tuya.dp_illuminance_interval(107, { emit = emit.zg204zhIlluminanceInterval() }),
tuya.dp_indicator(108, {
emit = emit.zg204zhIndicator(),
converter = on_off_bool_converter,
}),
tuya.dp_temperature_unit(109, { emit = emit.zg204zhTemperatureUnit() }),
tuya.dp_battery(110, { emit = emit.battery() }),
tuya.dp_temperature(111, { emit = emit.temperature() }),
tuya.dp_motion_detection_mode(112, { emit = emit.zg204zhMotionDetectionMode() }),
tuya.dp_motion_detection_sensitivity(123, { emit = emit.zg204zhMotionSensitivity() }),
}
register_presence_definition(presence_model_zg_204zh, ts0601_fingerprints({
"_TZE200_vuqzj1ej",
"_TZE200_hdih4foa",
"AOYAN:AY208Z",
"HOBEIAN:ZG-204ZH",
}))
local presence_model_zg_204zq = {
profile = "safety-presence-zg204zq-illuminance-temp-humidity-battery",
datapoints = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1(), read_only = true }),
tuya.dp_humidity(101, { emit = emit.humidity(), scale = 1, read_only = true }),
tuya.dp_fading_time(102, { emit = emit.zg204zqFadingTime() }),
tuya.dp_humidity_calibration(104, { emit = emit.zg204zqHumidityCalibration() }),
tuya.dp_temperature_calibration(105, { emit = emit.zg204zqTemperatureCalibration() }),
tuya.dp_illuminance(106, { emit = emit.illuminance(), read_only = true }),
tuya.dp_illuminance_interval(107, { emit = emit.zg204zqIlluminanceInterval() }),
tuya.dp_indicator(108, { emit = emit.zg204zqIndicator(), converter = on_off_bool_converter }),
tuya.dp_temperature_unit(109, {
emit = emit.zg204zqTemperatureUnit(),
converter = converter.lookup_from_to({ celsius = 0, fahrenheit = 1 }),
}),
tuya.dp_battery(110, { emit = emit.battery(), read_only = true }),
tuya.dp_temperature(111, {
emit = emit.temperature("C"),
converter = converter.signed_number_pair(10),
signed = true,
read_only = true,
}),
},
query_on_configure = false,
}
register_device_definition(presence_model_zg_204zq, ts0601_fingerprints({
"_TZE200_p9zbdqgs",
}))
local presence_model_gnpflcoq = {
profile = "safety-presence-gnpflcoq-illuminance-temp-humidity-battery",
datapoints = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false0(), read_only = true }),
tuya.dp_numeric(2, { name = "sensitivity", emit = emit.presenceSensitivityGnpflcoq() }),
tuya.dp_battery(4, { emit = emit.battery(), read_only = true }),
tuya.dp_temperature(7, { emit = emit.temperature("C"), scale = 10, read_only = true }),
tuya.dp_humidity(8, { emit = emit.humidity(), scale = 1, read_only = true }),
tuya.dp_illuminance(11, { emit = emit.illuminance(), read_only = true }),
tuya.dp_fading_time(102, { name = "fading_time", emit = emit.presenceFadingTimeGnpflcoq() }),
},
query_on_configure = false,
}
register_device_definition(presence_model_gnpflcoq, ts0601_fingerprints({
"_TZE284_gnpflcoq",
}))
local presence_switch_model_zg_302zm = {
profile = "switches-presence-switch-3-zg302zm",
named_datapoints = true,
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_numeric(2, { name = "sensitivity", emit = emit.zg302zmSensitivity() }),
tuya.dp_numeric(4, {
name = "distance",
emit = emit.zg302zmDistance(),
converter = converter.divide_by_pair(100),
}),
tuya.dp_on_off(101, { name = "switch", component = "main", emit = emit.switch() }),
tuya.dp_on_off(102, { name = "switch", component = "switch2", emit = emit.switch() }),
tuya.dp_on_off(103, { name = "switch", component = "switch3", emit = emit.switch() }),
tuya.dp_enum(108, {
name = "trigger_switch",
emit = emit.zg302zmTriggerSwitch(),
converter = presence_switch_trigger_channel_converter,
}),
tuya.dp_on_off(111, { name = "backlight", emit = emit.zg302zmBacklight() }),
tuya.dp_power_outage_memory(112, {
name = "power_outage_memory",
emit = emit.zg302zmPowerOutage(),
}),
tuya.dp_enum(113, {
name = "auto_on",
emit = emit.zg302zmAutoOn(),
converter = presence_switch_auto_channel_converter,
}),
tuya.dp_numeric(114, { name = "trigger_hold", emit = emit.zg302zmTriggerHold() }),
tuya.dp_enum(115, {
name = "auto_off",
emit = emit.zg302zmAutoOff(),
converter = presence_switch_auto_channel_converter,
}),
}
register_presence_definition(presence_switch_model_zg_302zm, ts0601_fingerprints({
"_TZE200_kccdzaeo",
"_TZE200_s7rsrtbg",
"_TZE200_tmszbtzq",
"_TZE200_bfmfhxra",
"_TZE200_ahpcyzth",
"_TZE200_kijxnb8q",
"HOBEIAN:ZG-302ZM",
}))
local presence_switch_model_zg_302zl = {
profile = "switches-presence-switch-3-zg302zl",
named_datapoints = true,
tuya.dp_presence(101, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_numeric(102, { name = "sensitivity", emit = emit.zg302zlSensitivity() }),
tuya.dp_on_off(1, { name = "switch", component = "main", emit = emit.switch() }),
tuya.dp_on_off(2, { name = "switch", component = "switch2", emit = emit.switch() }),
tuya.dp_on_off(3, { name = "switch", component = "switch3", emit = emit.switch() }),
tuya.dp_on_off(16, { name = "backlight", emit = emit.zg302zlBacklight() }),
tuya.dp_power_outage_memory(14, {
name = "power_outage_memory",
emit = emit.zg302zlPowerOutage(),
}),
tuya.dp_numeric(103, { name = "trigger_hold", emit = emit.zg302zlTriggerHold() }),
tuya.dp_enum(104, {
name = "auto_on",
emit = emit.zg302zlAutoOn(),
converter = presence_switch_auto_channel_long_converter,
}),
tuya.dp_enum(105, {
name = "auto_off",
emit = emit.zg302zlAutoOff(),
converter = presence_switch_auto_channel_long_converter,
}),
}
register_presence_definition(presence_switch_model_zg_302zl, ts0601_fingerprints({
"_TZE200_khzbklyh",
"_TZE200_df04ghrb",
"_TZE200_toeldckg",
"_TZE200_cqtamhh5",
"_TZE200_xlnzk169",
"_TZE200_llvwkkde",
"HOBEIAN:ZG-302ZL",
}))
local zis03_on_off_string_converter = converter.lookup_from_to({
ON = true,
OFF = false,
})
local zis03_detection_area_converter = converter.lookup_from_to({
all = 0,
left = 1,
right = 2,
})
local zis03_sensitivity_converter = converter.lookup_from_to({
low = 0,
medium = 1,
high = 2,
max = 3,
})
local function build_zis03_datapoints(options)
local datapoints = {
tuya.dp_presence(1, { emit = emit.presence(), converter = msa201_presence_converter }),
tuya.dp_numeric(4, { name = "detection_range", emit = emit.zis03DetectionRange() }),
tuya.dp_binary(102, {
name = "indicator",
emit = emit.zis03Indicator(),
converter = zis03_on_off_string_converter,
}),
tuya.dp_illuminance(103, { emit = emit.illuminance() }),
tuya.dp_numeric(104, { name = "fading_time", emit = emit.zis03FadingTime() }),
tuya.dp_numeric(106, {
name = "compensation_coefficient",
emit = emit.zis03Compensation(),
}),
tuya.dp_on_off(107, { name = "switch", component = "main", emit = emit.switch() }),
tuya.dp_binary(108, {
name = "radar",
emit = emit.zis03Radar(),
converter = zis03_on_off_string_converter,
}),
tuya.dp_enum(111, {
name = "detection_area",
emit = emit.zis03DetectionArea(),
converter = zis03_detection_area_converter,
}),
tuya.dp_binary(112, {
name = "state_reversal",
emit = emit.zis03StateReversal(),
converter = zis03_on_off_string_converter,
}),
tuya.dp_enum(113, {
name = "sensitivity",
emit = emit.zis03Sensitivity(),
converter = zis03_sensitivity_converter,
}),
}
if options.detection_distance then
datapoints[#datapoints + 1] = tuya.dp_numeric(101, {
name = "detection_distance",
read_only = true,
emit = emit.zis04DetectionDistance(),
})
end
return datapoints
end
local presence_switch_model_zis03 = {
profile = "safety-presence-switch-illuminance-zis03",
named_datapoints = true,
datapoints = build_zis03_datapoints({}),
}
register_presence_definition(presence_switch_model_zis03, ts0601_fingerprints({
"_TZE204_izy1g1mb",
}))
local presence_switch_model_zis04 = {
profile = "safety-presence-switch-illuminance-zis04",
named_datapoints = true,
datapoints = build_zis03_datapoints({ detection_distance = true }),
}
register_presence_definition(presence_switch_model_zis04, ts0601_fingerprints({
"_TZE204_f2rflfa6",
}))
local presence_model_zy_m100_24g = {
profile = "safety-presence-zym10024g-illuminance",
named_datapoints = true,
tuya.dp_numeric(102, { name = "illuminance_threshold_max" }),
tuya.dp_numeric(103, { name = "illuminance_threshold_min" }),
tuya.dp_illuminance(104, { emit = emit.illuminance() }),
tuya.dp_enum(105, {
name = "state",
read_only = true,
emit = emit.zym10024gState(),
converter = converter.lookup_from_to({
none = 0,
presence = 1,
move = 2,
}),
}),
tuya.dp_numeric(106, {
name = "move_sensitivity",
emit = emit.zym10024gMoveSensitivity(),
converter = converter.divide_by_from_only(10),
}),
tuya.dp_numeric(107, {
name = "max_range",
emit = emit.zym10024gMaxRange(),
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(109, {
name = "target_distance",
read_only = true,
emit = emit.zym10024gTargetDistance(),
converter = converter.divide_by_from_only(100),
}),
tuya.dp_numeric(110, { name = "presence_timeout", emit = emit.zym10024gTimeout() }),
tuya.dp_numeric(111, {
name = "presence_sensitivity",
emit = emit.zym10024gSensitivity(),
converter = converter.divide_by_from_only(10),
}),
tuya.dp_presence(112, { emit = emit.presence(), converter = converter.true_false1() }),
}
register_presence_definition(presence_model_zy_m100_24g, ts0601_fingerprints({
"_TZE204_ijxvkhd0",
}))
local presence_model_zy_m100_24gv2 = {
profile = "safety-presence-zym10024gv2-move-range-illuminance",
named_datapoints = true,
datapoints = {
tuya.dp_enum(1, {
name = "state",
read_only = true,
emit = emit.zym24gv2State(),
converter = converter.from_only(converter.lookup_value({
[0] = "none",
[1] = "presence",
[2] = "move",
})),
}),
tuya.dp_numeric(2, { name = "move_sensitivity", emit = emit.zym24gv2MoveSensitivity() }),
tuya.dp_numeric(3, {
name = "min_range",
emit = emit.zym24gv2MinRange(),
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(4, {
name = "max_range",
emit = emit.zym24gv2MaxRange(),
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(9, {
name = "target_distance",
read_only = true,
emit = emit.zym24gv2TargetDistance(),
converter = converter.divide_by_from_only(10),
}),
tuya.dp_numeric(102, { name = "presence_sensitivity", emit = emit.zym24gv2Sensitivity() }),
tuya.dp_illuminance(103, { emit = emit.illuminance() }),
tuya.dp_presence(104, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_numeric(105, { name = "presence_timeout", emit = emit.zym24gv2Timeout() }),
},
}
register_presence_definition(presence_model_zy_m100_24gv2, ts0601_fingerprints({
"_TZE204_7gclukjs",
}))
local function zym24gv3_presence_from_state()
local emitter = emit.presence()
return function(device, value, dp_info, mapping_context)
return emitter(device, value == "presence" or value == "move", dp_info, mapping_context)
end
end
local zym24gv3_state_converter = converter.from_only(converter.lookup_value({
[0] = "none",
[1] = "presence",
[2] = "move",
}))
local function build_zym24gv3_datapoints(min_range_emitter, max_range_emitter)
return {
tuya.dp_enum(1, {
name = "presence_state",
read_only = true,
emit = emit.all(emit.zym24gv3State(), zym24gv3_presence_from_state()),
converter = zym24gv3_state_converter,
}),
tuya.dp_numeric(2, { name = "move_sensitivity", emit = emit.zym24gv3MoveSensitivity() }),
tuya.dp_numeric(3, {
name = "min_range",
emit = min_range_emitter,
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(4, {
name = "max_range",
emit = max_range_emitter,
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(9, {
name = "target_distance",
read_only = true,
emit = emit.zym24gv3TargetDistance(),
converter = converter.divide_by_from_only(10),
}),
tuya.dp_binary(101, { name = "find_switch" }),
tuya.dp_numeric(102, { name = "presence_sensitivity", emit = emit.zym24gv3Sensitivity() }),
tuya.dp_illuminance(103, { emit = emit.illuminance() }),
tuya.dp_numeric(105, { name = "presence_timeout", emit = emit.zym24gv3Timeout() }),
}
end
local presence_model_zy_m100_24gv3_b = {
profile = "safety-presence-zym10024gv3-move-range-illuminance",
named_datapoints = true,
datapoints = build_zym24gv3_datapoints(emit.zym24gv3bMinRange(), emit.zym24gv3bMaxRange()),
}
register_presence_definition(presence_model_zy_m100_24gv3_b, ts0601_fingerprints({
"_TZE204_ya4ft0w4",
"_TZE200_ya4ft0w4",
}))
local presence_model_zy_m100_24gv3_a = {
profile = "safety-presence-zym10024gv3a-move-range-illuminance",
named_datapoints = true,
datapoints = build_zym24gv3_datapoints(emit.zym24gv3aMinRange(), emit.zym24gv3aMaxRange()),
}
register_presence_definition(presence_model_zy_m100_24gv3_a, ts0601_fingerprints({
"_TZE204_gkfbdvyx",
"_TZE200_gkfbdvyx",
}))
local presence_model_yxzbrb58 = {
profile = "safety-presence-yxzbrb58-range-delay-scene-illuminance",
named_datapoints = true,
datapoints = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_numeric(2, { name = "radar_sensitivity", emit = emit.yxzbrb58Sensitivity() }),
tuya.dp_numeric(3, {
name = "min_range",
emit = emit.yxzbrb58MinRange(),
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(4, {
name = "max_range",
emit = emit.yxzbrb58MaxRange(),
converter = converter.divide_by_pair(100),
}),
tuya.dp_illuminance(101, { emit = emit.illuminance() }),
tuya.dp_numeric(102, {
name = "detection_delay",
emit = emit.yxzbrb58DetectionDelay(),
converter = converter.divide_by_pair(10),
}),
tuya.dp_numeric(103, {
name = "fading_time",
emit = emit.yxzbrb58FadingTime(),
converter = converter.divide_by_pair(10),
}),
tuya.dp_enum(104, {
name = "radar_scene",
emit = emit.yxzbrb58RadarScene(),
converter = radar_scene_yxz_converter,
}),
tuya.dp_numeric(105, {
name = "target_distance",
read_only = true,
emit = emit.yxzbrb58TargetDistance(),
converter = converter.divide_by_from_only(100),
}),
},
}
register_presence_definition(presence_model_yxzbrb58, ts0601_fingerprints({
"_TZE204_sooucan5",
"_TZE204_oqtpvx51",
}))
local presence_model_ctl_r1_ty_zigbee = {
profile = "safety-presence-ctlr1-threshold-min-delay-illuminance",
named_datapoints = true,
datapoints = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_numeric(2, { name = "presence_sensitivity", emit = emit.ctlr1Sensitivity() }),
tuya.dp_numeric(4, {
name = "detection_range",
emit = emit.ctlr1DetectionRange(),
converter = converter.divide_by_pair(10),
}),
tuya.dp_illuminance(101, { emit = emit.illuminance() }),
tuya.dp_numeric(102, { name = "illuminance_threshold_max", emit = emit.ctlr1ThresholdMax() }),
tuya.dp_numeric(103, { name = "illuminance_threshold_min", emit = emit.ctlr1ThresholdMin() }),
tuya.dp_numeric(104, { name = "detection_delay", emit = emit.ctlr1DetectionDelay() }),
tuya.dp_binary(105, {
name = "light_switch",
read_only = true,
emit = emit.ctlr1LightSwitch(),
converter = converter.lookup_from_to({ ON = true, OFF = false }),
}),
tuya.dp_enum(106, {
name = "light_linkage",
emit = emit.ctlr1LightLinkage(),
converter = on_off_enum1_converter,
}),
tuya.dp_enum(107, {
name = "indicator_light",
emit = emit.ctlr1IndicatorLight(),
converter = converter.lookup_from_to({
presence = 0,
off = 1,
on = 2,
}),
}),
tuya.dp_enum(108, {
name = "detection_method",
emit = emit.ctlr1DetectionMethod(),
converter = detection_method_converter,
}),
tuya.dp_enum(109, {
name = "illuminance_switch",
emit = emit.ctlr1ThresholdSwitch(),
converter = on_off_enum1_converter,
}),
},
}
register_presence_definition(presence_model_ctl_r1_ty_zigbee, ts0601_fingerprints({
"_TZE204_e9ajs4ft",
}))
local presence_model_rt_zcz03z = {
profile = "safety-presence-rtzcz03z-range-illuminance",
named_datapoints = true,
datapoints = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false(4) }),
tuya.dp_numeric(101, {
name = "target_distance",
read_only = true,
emit = emit.rtzcz03zTargetDistance(),
}),
tuya.dp_illuminance(102, { emit = emit.illuminance() }),
tuya.dp_numeric(103, { name = "fading_time", emit = emit.rtzcz03zFadingTime() }),
tuya.dp_binary(104, {
name = "indicator",
emit = emit.rtzcz03zIndicator(),
converter = converter.lookup_from_to({ ON = true, OFF = false }),
}),
tuya.dp_numeric(107, { name = "max_distance", emit = emit.rtzcz03zMaxDistance() }),
tuya.dp_numeric(108, { name = "min_distance", emit = emit.rtzcz03zMinDistance() }),
tuya.dp_numeric(111, { name = "presence_sensitivity", emit = emit.rtzcz03zSensitivity() }),
},
}
register_presence_definition(presence_model_rt_zcz03z, ts0601_fingerprints({
"_TZE204_uxllnywp",
}))
local presence_model_mtg075_zb_rl = {
profile = "safety-presence-mtg075-entry-controls-illuminance",
named_datapoints = true,
datapoints = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_numeric(2, { name = "radar_sensitivity", emit = emit.mtg075RadarSensitivity() }),
tuya.dp_numeric(3, {
name = "shield_range",
emit = emit.mtg075ShieldRange(),
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(4, {
name = "detection_range",
emit = emit.mtg075DetectionRange(),
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(6, { name = "equipment_status", read_only = true }),
tuya.dp_numeric(9, {
name = "target_distance",
read_only = true,
emit = emit.mtg075TargetDistance(),
converter = converter.divide_by_from_only(100),
}),
tuya.dp_numeric(101, {
name = "entry_filter_time",
emit = emit.mtg075EntryFilterTime(),
converter = converter.divide_by_pair(10),
}),
tuya.dp_numeric(102, { name = "departure_delay", emit = emit.mtg075DepartureDelay() }),
tuya.dp_illuminance(104, { emit = emit.illuminance(), scale = 10 }),
tuya.dp_numeric(105, { name = "entry_sensitivity", emit = emit.mtg075EntrySensitivity() }),
tuya.dp_numeric(106, {
name = "entry_distance_indentation",
emit = emit.mtg075EntryIndentation(),
converter = converter.divide_by_pair(100),
}),
tuya.dp_enum(107, {
name = "breaker_mode",
emit = emit.mtg075BreakerMode(),
converter = breaker_mode_converter,
}),
tuya.dp_enum(108, {
name = "breaker_status",
emit = emit.mtg075BreakerStatus(),
converter = converter.lookup_from_to({ OFF = 0, ON = 1 }),
}),
tuya.dp_enum(109, {
name = "status_indication",
emit = emit.mtg075StatusIndication(),
converter = converter.lookup_from_to({ OFF = 0, ON = 1 }),
}),
tuya.dp_numeric(110, {
name = "illuminance_threshold",
emit = emit.mtg075IlluminanceThreshold(),
converter = converter.divide_by_pair(10),
}),
tuya.dp_enum(111, {
name = "breaker_polarity",
emit = emit.mtg075BreakerPolarity(),
converter = converter.lookup_from_to({ NC = 0, NO = 1 }),
}),
tuya.dp_numeric(112, {
name = "block_time",
emit = emit.mtg075BlockTime(),
converter = converter.divide_by_pair(10),
}),
tuya.dp_enum(115, {
name = "sensor_state",
emit = emit.mtg075SensorState(),
converter = sensor_state_mode_converter,
}),
},
}
register_presence_definition(presence_model_mtg075_zb_rl, ts0601_fingerprints({
"_TZE204_sbyx0lm6",
"_TZE204_clrdrnya",
"_TZE204_dtzziy1e",
"_TZE204_iaeejhvf",
"_TZE204_mtoaryre",
"_TZE200_mp902om5",
"_TZE204_pfayrzcw",
"_TZE284_4qznlkbu",
"_TZE200_clrdrnya",
"_TZE200_sbyx0lm6",
}))
local zym100s3_sensitivity_converter = converter.lookup_from_to({
low = 0,
medium = 1,
high = 2,
})
local zym100s3_keep_time_converter = converter.lookup_from_to({
["30"] = 0,
["60"] = 1,
["120"] = 2,
})
local presence_model_zy_m100_s_3 = {
profile = "safety-presence-zym100s3-keep-illuminance",
named_datapoints = true,
datapoints = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false0() }),
tuya.dp_enum(9, {
name = "sensitivity",
emit = emit.zym100s3Sensitivity(),
converter = zym100s3_sensitivity_converter,
}),
tuya.dp_enum(10, {
name = "keep_time",
emit = emit.zym100s3KeepTime(),
converter = zym100s3_keep_time_converter,
}),
tuya.dp_illuminance(12, { emit = emit.illuminance() }),
},
}
register_presence_definition(presence_model_zy_m100_s_3, ts0601_fingerprints({
"_TZE204_nbkshs6k",
}))
local function zg205z_presence_from_state()
local emitter = emit.presence()
return function(device, value, dp_info, mapping_context)
return emitter(device, value ~= "none", dp_info, mapping_context)
end
end
local presence_model_zg_205z = {
profile = "safety-presence-zg205z-illuminance",
named_datapoints = true,
datapoints = {
tuya.dp_enum(1, {
name = "presence_state",
read_only = true,
emit = emit.all(emit.zg205zPresenceState(), zg205z_presence_from_state()),
converter = converter.from_only(converter.lookup_value({
[0] = "none",
[1] = "presence",
[2] = "peaceful",
[3] = "small_movement",
[4] = "large_movement",
})),
}),
tuya.dp_numeric(101, {
name = "target_distance",
read_only = true,
emit = emit.zg205zTargetDistance(),
converter = converter.divide_by_from_only(100),
}),
tuya.dp_illuminance(102, { emit = emit.illuminance() }),
tuya.dp_numeric(103, { name = "none_delay_time", emit = emit.zg205zNoneDelayTime() }),
tuya.dp_binary(104, {
name = "indicator",
emit = emit.zg205zIndicator(),
converter = converter.lookup_from_to({ ON = true, OFF = false }),
}),
tuya.dp_numeric(107, {
name = "move_detection_max",
emit = emit.zg205zMoveMax(),
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(108, {
name = "move_detection_min",
emit = emit.zg205zMoveMin(),
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(109, {
name = "breath_detection_max",
emit = emit.zg205zBreathMax(),
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(110, {
name = "breath_detection_min",
emit = emit.zg205zBreathMin(),
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(114, {
name = "small_move_detection_max",
emit = emit.zg205zSmallMoveMax(),
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(115, {
name = "small_move_detection_min",
emit = emit.zg205zSmallMoveMin(),
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(116, { name = "move_sensitivity", emit = emit.zg205zMoveSensitivity() }),
tuya.dp_numeric(117, { name = "small_move_sensitivity", emit = emit.zg205zSmallMoveSensitivity() }),
tuya.dp_numeric(118, { name = "breath_sensitivity", emit = emit.zg205zBreathSensitivity() }),
},
}
register_presence_definition(presence_model_zg_205z, ts0601_fingerprints({
"_TZE204_dapwryy7",
}))
local presence_model_zg_205za = {
profile = "safety-presence-zg205za-illuminance",
named_datapoints = true,
datapoints = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_numeric(2, {
name = "large_motion_sensitivity",
emit = emit.zg205zaLargeSensitivity(),
}),
tuya.dp_numeric(4, {
name = "large_motion_distance",
emit = emit.zg205zaLargeDistance(),
converter = converter.divide_by_pair(100),
}),
tuya.dp_enum(101, {
name = "motion_state",
read_only = true,
emit = emit.zg205zaMotionState(),
converter = converter.from_only(converter.lookup_value({
[0] = "none",
[1] = "large",
[2] = "medium",
[3] = "small",
[4] = "far",
[5] = "near",
})),
}),
tuya.dp_numeric(102, { name = "fading_time", emit = emit.zg205zaFadingTime() }),
tuya.dp_numeric(104, {
name = "medium_motion_distance",
emit = emit.zg205zaMediumDistance(),
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(105, {
name = "medium_motion_sensitivity",
emit = emit.zg205zaMediumSensitivity(),
}),
tuya.dp_illuminance(106, { emit = emit.illuminance() }),
tuya.dp_binary(107, {
name = "indicator",
emit = emit.zg205zaIndicator(),
converter = converter.lookup_from_to({ ON = true, OFF = false }),
}),
tuya.dp_numeric(108, {
name = "small_detection_distance",
emit = emit.zg205zaSmallDistance(),
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(109, {
name = "small_detection_sensitivity",
emit = emit.zg205zaSmallSensitivity(),
}),
tuya.dp_numeric(122, {
name = "target_distance",
read_only = true,
emit = emit.zg205zaTargetDistance(),
converter = converter.divide_by_from_only(100),
}),
tuya.dp_numeric(123, {
name = "minimum_range",
emit = emit.zg205zaMinimumRange(),
converter = converter.divide_by_pair(100),
}),
},
}
register_presence_definition(presence_model_zg_205za, {
device_helpers.create_fingerprint("_TZE200_crq3r3la", "TS0225"),
device_helpers.create_fingerprint("HOBEIAN", "CK-BL702-MWS-01(7016)"),
device_helpers.create_fingerprint("_TZE200_crq3r3la", "CK-BL702-MWS-01(7016)"),
})
local presence_model_zg_205zl = {
profile = "safety-presence-zg205zl-illuminance",
named_datapoints = true,
datapoints = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_enum(11, {
name = "motion_state",
read_only = true,
emit = emit.zg205zlMotionState(),
converter = converter.from_only(converter.lookup_value({
[0] = "none",
[1] = "large",
[2] = "small",
[3] = "static",
[4] = "far",
[5] = "near",
})),
}),
tuya.dp_numeric(12, { name = "fading_time", emit = emit.zg205zlFadingTime() }),
tuya.dp_numeric(13, {
name = "large_motion_distance",
emit = emit.zg205zlLargeDistance(),
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(14, {
name = "small_motion_distance",
emit = emit.zg205zlSmallDistance(),
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(15, {
name = "large_motion_sensitivity",
emit = emit.zg205zlLargeSensitivity(),
}),
tuya.dp_numeric(16, {
name = "small_motion_sensitivity",
emit = emit.zg205zlSmallSensitivity(),
}),
tuya.dp_illuminance(20, { emit = emit.illuminance() }),
tuya.dp_binary(24, {
name = "light_mode",
emit = emit.zg205zlLightMode(),
converter = converter.lookup_from_to({ ON = true, OFF = false }),
}),
tuya.dp_numeric(101, { name = "alarm_time", emit = emit.zg205zlAlarmTime() }),
tuya.dp_enum(102, {
name = "alarm_volume",
emit = emit.zg205zlAlarmVolume(),
converter = converter.lookup_from_to({
low = 0,
medium = 1,
high = 2,
mute = 3,
}),
}),
tuya.dp_numeric(103, {
name = "static_distance",
emit = emit.zg205zlStaticDistance(),
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(104, {
name = "static_sensitivity",
emit = emit.zg205zlStaticSensitivity(),
}),
tuya.dp_enum(105, {
name = "working_mode",
emit = emit.zg205zlMode(),
converter = converter.lookup_from_to({
arm = 0,
off = 1,
alarm = 2,
doorbell = 3,
}),
}),
},
}
register_presence_definition(presence_model_zg_205zl, {
device_helpers.create_fingerprint("_TZE200_hl0ss9oa", "TS0225"),
device_helpers.create_fingerprint("ZGAF-205L", "CK-BL702-MWS-01(7016)"),
device_helpers.create_fingerprint("_TZE200_y4mdop0b", "TS0225"),
})
local sensor_state_mode_mtd085_converter = converter.lookup_from_to({
on = 0,
occupied = 1,
unoccupied = 2,
})
local debug_mode_mtd085_converter = converter.lookup_from_to({
OFF = 0,
ON = 1,
})
local scene_preset_mtd085_converter = converter.lookup_from_to({
custom = 0,
toilet = 1,
kitchen = 2,
hallway = 3,
bedroom = 4,
livingroom = 5,
meetingroom = 6,
factory_default = 7,
})
local distance_report_mode_mtd085_converter = converter.lookup_from_to({
normal = 0,
occupancy_detection = 1,
})
local presence_model_mtd085_zb = {
profile = "safety-motion-mtd085-illuminance",
datapoints = {
tuya.dp_numeric(101, {
name = "entry_sensitivity",
emit = emit.mtd085EntrySensitivity(),
command_id = tuya.SEND_DATA,
}),
tuya.dp_numeric(102, {
name = "entry_distance",
emit = emit.mtd085EntryDistance(),
converter = converter.divide_by_pair(100),
command_id = tuya.SEND_DATA,
}),
tuya.dp_numeric(103, {
name = "departure_delay",
emit = emit.mtd085DepartureDelay(),
command_id = tuya.SEND_DATA,
}),
tuya.dp_numeric(104, {
name = "entry_filter_time",
emit = emit.mtd085EntryFilterTime(),
converter = converter.divide_by_pair(100),
command_id = tuya.SEND_DATA,
}),
tuya.dp_numeric(105, {
name = "block_time",
emit = emit.mtd085BlockTime(),
converter = converter.divide_by_pair(10),
command_id = tuya.SEND_DATA,
}),
tuya.dp_illuminance(107, {
emit = emit.illuminance(),
converter = converter.divide_by_pair(10),
read_only = true,
}),
tuya.dp_enum(108, {
name = "debug_mode",
emit = emit.mtd085DebugMode(),
converter = debug_mode_mtd085_converter,
command_id = tuya.SEND_DATA,
}),
tuya.dp_numeric(109, {
name = "debug_distance",
emit = emit.mtd085DebugDistance(),
converter = converter.divide_by_pair(100),
read_only = true,
}),
tuya.dp_numeric(110, {
name = "debug_countdown",
emit = emit.mtd085DebugCountdown(),
read_only = true,
}),
tuya.dp_enum(111, {
name = "scene_preset",
emit = emit.mtd085ScenePreset(),
converter = scene_preset_mtd085_converter,
command_id = tuya.SEND_DATA,
}),
tuya.dp_enum(112, {
name = "sensor",
emit = emit.mtd085Sensor(),
converter = sensor_state_mode_mtd085_converter,
command_id = tuya.SEND_DATA,
}),
tuya.dp_numeric(113, { name = "cline", read_only = true }),
tuya.dp_enum(114, {
name = "status_indication",
emit = emit.mtd085StatusIndication(),
converter = debug_mode_mtd085_converter,
command_id = tuya.SEND_DATA,
}),
tuya.dp_numeric(115, {
name = "radar_sensitivity",
emit = emit.mtd085RadarSensitivity(),
command_id = tuya.SEND_DATA,
}),
tuya.dp_numeric(116, {
name = "shield_range",
emit = emit.mtd085ShieldRange(),
converter = converter.divide_by_pair(100),
command_id = tuya.SEND_DATA,
}),
tuya.dp_numeric(117, {
name = "detection_range",
emit = emit.mtd085DetectionRange(),
converter = converter.divide_by_pair(100),
command_id = tuya.SEND_DATA,
}),
tuya.dp_numeric(118, { name = "equipment_status", read_only = true }),
tuya.dp_numeric(119, {
name = "target_distance",
emit = emit.mtd085TargetDistance(),
converter = converter.divide_by_pair(100),
read_only = true,
}),
tuya.dp_enum(120, {
name = "distance_report_mode",
emit = emit.mtd085DistanceReportMode(),
converter = distance_report_mode_mtd085_converter,
command_id = tuya.SEND_DATA,
}),
},
zcl_clusters = {
zcl.motion(),
},
query_on_configure = false,
}
register_device_definition(presence_model_mtd085_zb, {
device_helpers.create_fingerprint("_TZ321C_fkzihax8", "TS0225"),
device_helpers.create_fingerprint("_TZ321C_4slreunp", "TS0225"),
})
local presence_model_zp_301z = {
profile = "safety-presence-zp301z-time-cycle-illuminance-battery",
named_datapoints = true,
datapoints = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_battery(14, { emit = emit.battery() }),
tuya.dp_illuminance(20, { emit = emit.illuminance() }),
tuya.dp_numeric(100, { name = "brightness_value", emit = emit.zp301zBrightnessValue() }),
tuya.dp_numeric(101, { name = "illuminance_trigger", emit = emit.zp301zIlluminanceTrigger() }),
tuya.dp_numeric(102, { name = "presence_time", emit = emit.zp301zPresenceTime() }),
tuya.dp_numeric(103, { name = "presence_delay", emit = emit.zp301zPresenceDelay() }),
tuya.dp_numeric(104, { name = "detection_cycle", emit = emit.zp301zDetectionCycle() }),
},
}
register_presence_definition(presence_model_zp_301z, {
device_helpers.create_fingerprint("_TZE284_d4h8j2n6", "ZP-301Z"),
device_helpers.create_fingerprint("B3876M9", "ZP-301Z"),
})
local pir_model_sp02_zb001 = {
profile = "safety-motion-tamper-battery",
datapoints = {
tuya.dp_occupancy(1, { emit = emit.motion(), converter = converter.true_false0() }),
tuya.dp_battery(4, { emit = emit.battery() }),
tuya.dp_binary(5, { name = "tamper", emit = emit.tamper(), converter = raw_non_zero_converter }),
},
query_on_configure = true,
}
register_device_definition(pir_model_sp02_zb001, ts0601_fingerprints({
"_TZE200_mgxy2d9f",
}))
local presence_model_zis_01p = {
profile = "safety-presence-zis01p-illuminance-battery",
datapoints = {
tuya.dp_occupancy(1, {
emit = emit.motion(),
converter = converter.true_false1(),
read_only = true,
}),
tuya.dp_numeric(101, { name = "radar_delay", read_only = true }),
tuya.dp_numeric(102, {
name = "presence_distance",
emit = emit.zis01pPresenceDistance(),
}),
tuya.dp_numeric(103, {
name = "presence_sensitivity",
emit = emit.zis01pPresenceSensitivity(),
}),
tuya.dp_binary(104, {
name = "radar_switch",
emit = emit.zis01pRadarSwitch(),
converter = zis01p_on_off_converter,
}),
tuya.dp_numeric(105, {
name = "pir_sensitivity",
emit = emit.zis01pPirSensitivity(),
}),
tuya.dp_numeric(106, {
name = "delay_time",
emit = emit.zis01pDelayTime(),
}),
tuya.dp_binary(107, {
name = "led_switch",
emit = emit.zis01pLedSwitch(),
converter = zis01p_on_off_converter,
}),
tuya.dp_illuminance(108, { emit = emit.illuminance(), read_only = true }),
tuya.dp_battery(109, { emit = emit.battery(), read_only = true }),
tuya.dp_numeric(160, { name = "pir_threshold", emit = emit.zis01pPirThreshold() }),
tuya.dp_numeric(161, { name = "pir_trigger_pulses", read_only = true }),
tuya.dp_numeric(162, { name = "pir_trigger_time", read_only = true }),
tuya.dp_numeric(163, { name = "pir_lock_time", read_only = true }),
tuya.dp_numeric(164, { name = "radar_threshold", emit = emit.zis01pRadarThreshold() }),
tuya.dp_numeric(165, { name = "radar_distance_door_test", read_only = true }),
},
query_on_configure = false,
}
register_device_definition(presence_model_zis_01p, ts0601_fingerprints({
"_TZE284_vceqncho",
"_TZE284_who1jxwd",
}))
local presence_model_msa201z = {
profile = "safety-presence-msa201-illuminance",
datapoints = {
tuya.dp_enum(1, { name = "presence", emit = emit.presence(), converter = msa201_presence_converter }),
tuya.dp_numeric(2, { name = "trigger_distance", scale = 10, emit = emit.msa201zTriggerDistance() }),
tuya.dp_illuminance(101, { emit = emit.illuminance() }),
tuya.dp_numeric(102, { name = "lux_difference_value" }),              -- profile 미포함
tuya.dp_enum(103, { name = "ai_self_learning" }),                     -- profile 미포함
tuya.dp_enum(104, { name = "factory_reset" }),                        -- profile 미포함
tuya.dp_enum(105, { name = "fast_setting" }),                         -- profile 미포함
tuya.dp_numeric(106, { name = "hold_delay_time", emit = emit.msa201zHoldDelayTime() }),
tuya.dp_indicator(107, {
emit = emit.msa201zIndicator(),
converter = on_off_bool_converter,
}),
tuya.dp_enum(108, { name = "current_status" }),                       -- profile 미포함
tuya.dp_binary(109, { name = "enable_sensor" }),                      -- profile 미포함
tuya.dp_enum(110, {
name = "sensitivity",
emit = emit.msa201zSensitivity(),
converter = converter.lookup_from_to({ low = 0, medium = 1, high = 2 }),
}),
tuya.dp_binary(112, { name = "status_flip" }),                        -- profile 미포함
tuya.dp_raw(113, { name = "interference_positions" }),                -- profile 미포함
tuya.dp_numeric(114, {
name = "forbidden_area",
scale = 10,
emit = emit.msa201zForbiddenArea(),
}),
tuya.dp_numeric(115, { name = "daylight_threshold" }),                -- profile 미포함
tuya.dp_enum(116, {
name = "sensor_mode",
emit = emit.msa201zSensorMode(),
converter = converter.lookup_from_to({ presence = 0, motion = 1 }),
}),
tuya.dp_binary(117, { name = "single_mode" }),                        -- profile 미포함
tuya.dp_binary(118, { name = "find_device" }),                        -- profile 미포함
tuya.dp_enum(119, { name = "lux_mode" }),                             -- profile 미포함
tuya.dp_enum(120, { name = "lux_report_mode" }),                      -- profile 미포함
tuya.dp_numeric(121, { name = "lux_difference_threshold" }),          -- profile 미포함
tuya.dp_numeric(122, { name = "lux_timed_interval" }),                -- profile 미포함
tuya.dp_binary(123, { name = "absence_circling_report" }),            -- profile 미포함
tuya.dp_numeric(124, { name = "absence_circling_interval" }),         -- profile 미포함
tuya.dp_enum(125, { name = "home_environment" }),                     -- profile 미포함
},
query_on_configure = true,
}
register_device_definition(presence_model_msa201z, ts0601_fingerprints({
"_TZE284_ajuasrmx",
"_TZE200_hyhl5y36",
"_TZE284_ozf4e02o",
}))
local presence_model_szr07u = {
profile = "safety-presence-szr07u-range-delay",
datapoints = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_numeric(13, { name = "detection_range", scale = 100, emit = emit.szr07uDetectionRange() }),
tuya.dp_numeric(16, { name = "radar_sensitivity", emit = emit.szr07uRadarSensitivity() }),
tuya.dp_numeric(19, {
name = "target_distance",
read_only = true,
emit = emit.szr07uTargetDistance(),
}),
tuya.dp_indicator(101, {
emit = emit.szr07uIndicator(),
converter = on_off_bool_converter,
}),
tuya.dp_raw(102, { name = "presence_notification_toggle" }),          -- profile 미포함
tuya.dp_numeric(103, { name = "fading_time", emit = emit.szr07uFadingTime() }),
},
query_on_configure = true,
}
register_device_definition(presence_model_szr07u, ts0601_fingerprints({
"_TZE204_muvkrjr5",
}))
local presence_model_mtd285_zb_presence_converter = converter.from_only(function(value)
local numeric_value = tonumber(value)
return numeric_value ~= nil and numeric_value ~= 0
end)
local presence_model_mtd285_zb_state_converter = converter.from_only(function(value)
local numeric_value = tonumber(value)
if numeric_value == nil or numeric_value == 0 then
return "none"
end
if numeric_value == 1 then
return "presence"
end
return "move"
end)
local presence_model_mtd285_zb_gate_converter = converter.lookup_from_to({ disable = 0, enable = 1 })
local presence_model_mtd285_zb_debug_converter = converter.lookup_from_to({ off = 0, on = 1 })
local presence_model_mtd285_zb_led_converter = converter.lookup_from_to({ silence = 0, status = 1 })
local presence_model_mtd285_zb_judge_converter = converter.lookup_from_to({
large_move = 0,
small_move = 1,
custom_move = 2,
})
local presence_model_mtd285_zb_noise_converter = converter.lookup_from_to({ start = 0, ongoing = 1, complete = 2 })
local presence_model_mtd285_zb_start_converter = converter.lookup_from_to({ start = 0 })
local presence_model_mtd285_zb_control_converter = converter.lookup_from_to({
no_action = 0,
restart = 1,
reset_param = 2,
})
local presence_model_mtd285_zb_sensitivity_converter = converter.lookup_from_to({
high = 0,
medium = 1,
low = 2,
custom = 3,
})
local presence_model_mtd285_zb_scene_converter = converter.lookup_from_to({
custom = 0,
toilet = 1,
kitchen = 2,
corridor = 3,
bedroom = 4,
living_room = 5,
meeting_room = 6,
})
local presence_model_mtd285_zb = {
profile = "safety-presence-mtd285-illuminance",
datapoints = {
tuya.dp_numeric(1, {
name = "presence",
emit = emit.presence(),
converter = presence_model_mtd285_zb_presence_converter,
read_only = true,
}),
tuya.dp_numeric(1, {
name = "state",
emit = emit.mtd285State(),
converter = presence_model_mtd285_zb_state_converter,
read_only = true,
}),
tuya.dp_numeric(3, { name = "min_distance", emit = emit.mtd285MinDistance(), converter = converter.divide_by_pair(10) }),
tuya.dp_numeric(4, { name = "max_distance", emit = emit.mtd285MaxDistance(), converter = converter.divide_by_pair(10) }),
tuya.dp_numeric(9, {
name = "target_distance", emit = emit.mtd285TargetDistance(),
converter = converter.divide_by_pair(10),
read_only = true,
}),
tuya.dp_enum(101, { name = "gate_enable_01", emit = emit.mtd285GateEnable01(), converter = presence_model_mtd285_zb_gate_converter }),
tuya.dp_enum(102, { name = "gate_enable_02", emit = emit.mtd285GateEnable02(), converter = presence_model_mtd285_zb_gate_converter }),
tuya.dp_enum(103, { name = "gate_enable_03", emit = emit.mtd285GateEnable03(), converter = presence_model_mtd285_zb_gate_converter }),
tuya.dp_enum(104, { name = "gate_enable_04", emit = emit.mtd285GateEnable04(), converter = presence_model_mtd285_zb_gate_converter }),
tuya.dp_enum(105, { name = "gate_enable_05", emit = emit.mtd285GateEnable05(), converter = presence_model_mtd285_zb_gate_converter }),
tuya.dp_enum(106, { name = "gate_enable_06", emit = emit.mtd285GateEnable06(), converter = presence_model_mtd285_zb_gate_converter }),
tuya.dp_enum(107, { name = "gate_enable_07", emit = emit.mtd285GateEnable07(), converter = presence_model_mtd285_zb_gate_converter }),
tuya.dp_enum(108, { name = "gate_enable_08", emit = emit.mtd285GateEnable08(), converter = presence_model_mtd285_zb_gate_converter }),
tuya.dp_enum(109, { name = "gate_enable_09", emit = emit.mtd285GateEnable09(), converter = presence_model_mtd285_zb_gate_converter }),
tuya.dp_enum(110, { name = "gate_enable_10", emit = emit.mtd285GateEnable10(), converter = presence_model_mtd285_zb_gate_converter }),
tuya.dp_enum(111, { name = "gate_enable_11", emit = emit.mtd285GateEnable11(), converter = presence_model_mtd285_zb_gate_converter }),
tuya.dp_numeric(112, { name = "configuration_gate", emit = emit.mtd285ConfigurationGate() }),
tuya.dp_numeric(113, { name = "move_threshold", emit = emit.mtd285MoveThreshold() }),
tuya.dp_numeric(114, { name = "presence_threshold", emit = emit.mtd285PresenceThreshold() }),
tuya.dp_numeric(115, { name = "nearest_target_gate", emit = emit.mtd285NearestTargetGate(), read_only = true }),
tuya.dp_numeric(116, { name = "target_countdown", emit = emit.mtd285TargetCountdown(), read_only = true }),
tuya.dp_numeric(117, {
name = "target_velocity", emit = emit.mtd285TargetVelocity(),
converter = converter.signed_number_pair(100),
read_only = true,
}),
tuya.dp_enum(118, { name = "debug_switch", emit = emit.mtd285DebugSwitch(), converter = presence_model_mtd285_zb_debug_converter }),
tuya.dp_enum(119, { name = "led_mode", emit = emit.mtd285LedMode(), converter = presence_model_mtd285_zb_led_converter }),
tuya.dp_numeric(120, { name = "delay_time", emit = emit.mtd285DelayTime() }),
tuya.dp_numeric(121, { name = "block_time", emit = emit.mtd285BlockTime(), converter = converter.divide_by_pair(10) }),
tuya.dp_enum(122, { name = "judge_logic", emit = emit.mtd285JudgeLogic(), converter = presence_model_mtd285_zb_judge_converter }),
tuya.dp_enum(123, {
name = "noise_collect_status", emit = emit.mtd285NoiseCollectStatus(),
converter = presence_model_mtd285_zb_noise_converter,
read_only = true,
}),
tuya.dp_enum(123, {
name = "start_noise_collect",
converter = presence_model_mtd285_zb_start_converter,
write_only = true,
}),
tuya.dp_enum(124, { name = "device_control", emit = emit.mtd285DeviceControl(), converter = presence_model_mtd285_zb_control_converter }),
tuya.dp_illuminance(125, { emit = emit.illuminance(), read_only = true }),
tuya.dp_enum(126, {
name = "presence_sensitivity", emit = emit.mtd285PresenceSensitivity(),
converter = presence_model_mtd285_zb_sensitivity_converter,
}),
tuya.dp_enum(127, {
name = "move_sensitivity", emit = emit.mtd285MoveSensitivity(),
converter = presence_model_mtd285_zb_sensitivity_converter,
}),
tuya.dp_enum(128, { name = "scene_mode", emit = emit.mtd285SceneMode(), converter = presence_model_mtd285_zb_scene_converter }),
tuya.dp_enum(129, { name = "illuminance_report", emit = emit.mtd285IlluminanceReport(), converter = presence_model_mtd285_zb_debug_converter }),
tuya.dp_enum(130, { name = "move_detect", emit = emit.mtd285MoveDetect(), converter = presence_model_mtd285_zb_debug_converter }),
tuya.dp_enum(131, { name = "distance_report", emit = emit.mtd285DistanceReport(), converter = presence_model_mtd285_zb_debug_converter }),
tuya.dp_enum(132, { name = "speed_report", emit = emit.mtd285SpeedReport(), converter = presence_model_mtd285_zb_debug_converter }),
},
query_on_configure = false,
}
register_device_definition(presence_model_mtd285_zb, ts0601_fingerprints({
"_TZE284_aai5grix",
"_TZE204_aai5grix",
}))
local presence_model_pj3201a = {
profile = "safety-presence-pj3201a-illuminance",
datapoints = {
tuya.dp_presence(104, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_occupancy(112, { name = "occupancy", emit = emit.motion(), converter = converter.true_false0() }),
tuya.dp_numeric(9, {
name = "closest_target_distance",
scale = 100,
read_only = true,
emit = emit.pj3201aClosestTargetDistance(),
}),
tuya.dp_numeric(101, { name = "movement_timeout", emit = emit.pj3201aMovementTimeout() }),
tuya.dp_numeric(102, { name = "idle_timeout", emit = emit.pj3201aIdleTimeout() }),
tuya.dp_illuminance(103, { emit = emit.illuminance(), scale = 10 }),
tuya.dp_numeric(105, {
name = "far_movement_sensitivity",
emit = emit.pj3201aFarMovementSensitivity(),
}),
tuya.dp_numeric(110, {
name = "near_movement_sensitivity",
emit = emit.pj3201aNearMovementSensitivity(),
}),
tuya.dp_numeric(109, {
name = "near_presence_sensitivity",
emit = emit.pj3201aNearPresenceSensitivity(),
}),
tuya.dp_numeric(111, {
name = "far_presence_sensitivity",
emit = emit.pj3201aFarPresenceSensitivity(),
}),
tuya.dp_numeric(3, {
name = "closest_detection_distance",
scale = 100,
emit = emit.pj3201aClosestDetectionDistance(),
}),
tuya.dp_numeric(4, {
name = "largest_movement_detection_distance",
scale = 100,
emit = emit.pj3201aLargestMovementDistance(),
}),
tuya.dp_numeric(108, {
name = "largest_presence_detection_distance",
scale = 100,
emit = emit.pj3201aLargestPresenceDistance(),
}),
tuya.dp_enum(106, {
name = "restore_factory",
emit = emit.pj3201aRestoreFactory(),
converter = converter.lookup_from_to({ on = false, off = true }),
}),
tuya.dp_enum(107, {
name = "led_indicator",
emit = emit.pj3201aLedIndicator(),
converter = converter.lookup_from_to({ on = false, off = true }),
}),
},
query_on_configure = true,
}
register_device_definition(presence_model_pj3201a, ts0601_fingerprints({
"_TZE204_eaulras5",
}))
local presence_model_nas_ps09b2 = {
profile = "safety-motion-nas-ps09b2",
datapoints = {
tuya.dp_occupancy(1, {
emit = emit.motion(),
converter = converter.true_false1(),
read_only = true,
}),
tuya.dp_enum(11, {
name = "human_motion_state",
emit = emit.nasps09b2MotionState(),
converter = converter.lookup_from_to({ none = 0, small = 1, large = 2 }),
read_only = true,
}),
tuya.dp_numeric(12, { name = "departure_delay", emit = emit.nasps09b2DepartureDelay() }),
tuya.dp_numeric(13, { name = "radar_range", emit = emit.nasps09b2RadarRange() }),
tuya.dp_numeric(15, { name = "radar_sensitivity", emit = emit.nasps09b2RadarSensitivity() }),
tuya.dp_numeric(16, { name = "presence_sensitivity", emit = emit.nasps09b2PresenceSensitivity() }),
tuya.dp_numeric(19, {
name = "dis_current",
read_only = true,
emit = emit.nasps09b2DisCurrent(),
}),
},
query_on_configure = false,
}
register_device_definition(presence_model_nas_ps09b2, ts0601_fingerprints({
"_TZE204_kyhbrfyl",
}))
local presence_model_rtsc11r = {
profile = "safety-presence-rtsc11r-illuminance",
datapoints = {
tuya.dp_presence(1, {
emit = emit.presence(),
converter = converter.true_false1(),
read_only = true,
}),
tuya.dp_numeric(12, {
name = "detection_delay",
converter = converter.divide_by_pair(10),
emit = emit.rtsc11rDetectionDelay(),
}),
tuya.dp_numeric(19, {
name = "detection_distance",
read_only = true,
emit = emit.rtsc11rDetectionDistance(),
}),
tuya.dp_illuminance(20, { emit = emit.illuminance(), read_only = true }),
tuya.dp_numeric(101, {
name = "sensitivity",
converter = converter.divide_by_pair(10),
emit = emit.rtsc11rSensitivity(),
}),
tuya.dp_numeric(102, { name = "keep_time", emit = emit.rtsc11rKeepTime() }),
tuya.dp_numeric(111, {
name = "minimum_range",
converter = converter.divide_by_pair(100),
emit = emit.rtsc11rMinimumRange(),
}),
tuya.dp_numeric(112, {
name = "maximum_range",
converter = converter.divide_by_pair(100),
emit = emit.rtsc11rMaximumRange(),
}),
},
query_on_configure = false,
}
register_device_definition(presence_model_rtsc11r, ts0601_fingerprints({
"_TZE204_mhxn2jso",
}))
local presence_model_rd24g01 = {
profile = "safety-presence-rd24g01-range",
datapoints = {
tuya.dp_enum(1, {
name = "presence_state",
read_only = true,
emit = emit.rd24g01PresenceState(),
converter = converter.from_only(converter.lookup_value({
[0] = "none",
[1] = "motion",
[2] = "stationary",
})),
}),
tuya.dp_numeric(3, {
name = "near_detection",
scale = 100,
emit = emit.rd24g01NearDetection(),
}),
tuya.dp_numeric(4, {
name = "far_detection",
scale = 100,
emit = emit.rd24g01FarDetection(),
}),
tuya.dp_numeric(9, {
name = "target_distance_closest",
scale = 100,
read_only = true,
emit = emit.rd24g01TargetDistanceClosest(),
}),
tuya.dp_numeric(101, {
name = "static_sensitivity",
emit = emit.rd24g01StaticSensitivity(),
}),
tuya.dp_numeric(102, {
name = "motion_sensitivity",
emit = emit.rd24g01MotionSensitivity(),
}),
},
query_on_configure = true,
}
register_device_definition(presence_model_rd24g01, ts0601_fingerprints({
"_TZE204_no6qtgtl",
}))
return device_definitions
