local tuya = require "tuya_common"
local emit = require "emitters"
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
tuya.dp_presence(1, { emit = emit.presence() }),
tuya.dp_battery(4, { emit = emit.battery() }),
dp_presence_sensitivity_low_medium_high(9),
dp_presence_delay_enum_cap(10),
}
register_presence_definition(presence_basic, ts0601_fingerprints({
"_TZE284_debczeci",
"_TZE284_1lvln0x6",
"_TZE204_debczeci",
}), {
presence_sensitivity = PRESENCE_SENSITIVITY_LOW_MEDIUM_HIGH_RANGE,
presence_delay = {
minimum = 15,
maximum = 60,
step = 1,
unit = "s",
allowed_values = { 15, 30, 60 },
},
})
local presence_pir24g = {
tuya.dp_presence(1, { emit = emit.presence() }),
tuya.dp_battery(4, { emit = emit.battery() }),
tuya.dp_illuminance(12, { emit = emit.illuminance() }),
dp_presence_detection_range(101),
dp_presence_fading_time(103),
tuya.dp_enum(104, { name = "last_time" }),                      -- 프로파일 미포함
dp_static_detection_sensitivity_cap(105),
dp_motion_detection_sensitivity_cap(106),
}
register_presence_definition(presence_pir24g, ts0601_fingerprints({
"_TZE200_juzago6i",
}), {
static_detection_sensitivity = capability_range(1, 10, 1),
motion_detection_sensitivity = capability_range(1, 10, 1),
presence_detection_range = capability_range(1, 6, 1, "m"),
presence_fading_time = capability_range(10, 180, 10, "s"),
})
local presence_model_zf24 = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
dp_move_sensitivity_cap(2),
dp_presence_detection_range(4, { scale = 100 }),
dp_presence_target_distance(9, {}),
dp_presence_fading_time(101, {}),
tuya.dp_illuminance(102, { emit = emit.illuminance() }),
dp_presence_sensitivity_numeric(103),
tuya.dp_binary(104, { name = "state" }),                        -- 프로파일 미포함
dp_radar_switch_cap(109),
}
register_presence_definition(presence_model_zf24, ts0601_fingerprints({
"_TZE284_pzm3wab5",
"_TZE284_twybxdzl",
"_TZE284_hgeqeyuv",
}), {
move_sensitivity = MOVE_SENSITIVITY_TEN_RANGE,
presence_sensitivity = PRESENCE_SENSITIVITY_TEN_RANGE,
presence_detection_range = PRESENCE_DETECTION_RANGE_075_90_RANGE,
presence_fading_time = capability_range(1, 600, 1, "s"),
radar_switch = capability_values({ "on", "off" }),
})
register_presence_definition(presence_model_zf24, {
device_helpers.create_fingerprint("Tuya", "ZT24"),
device_helpers.create_fingerprint("Tuya", "ZX24"),
}, {
move_sensitivity = MOVE_SENSITIVITY_TEN_RANGE,
presence_sensitivity = PRESENCE_SENSITIVITY_TEN_RANGE,
presence_detection_range = PRESENCE_DETECTION_RANGE_075_90_RANGE,
presence_fading_time = capability_range(1, 600, 1, "s"),
radar_switch = capability_values({ "on", "off" }),
})
local presence_model_zg204zx = {
profile = "safety-presence-illuminance-temp-humidity-battery-zg204zx",
datapoints = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
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
tuya.dp_illuminance(106, { emit = emit.illuminance() }),
tuya.dp_illuminance_interval(107, { emit = emit.illuminanceIntervalZg204zx() }),
tuya.dp_binary(108, {
name = "indicator",
emit = emit.indicatorZg204zx(),
converter = on_off_bool_converter,
}),
tuya.dp_temperature_unit(109, { emit = emit.temperatureUnitZg204zx() }),
tuya.dp_battery(110, { emit = emit.battery() }),
tuya.dp_temperature(111, { emit = emit.temperature("C"), scale = 10 }),
tuya.dp_humidity(101, { emit = emit.humidity() }),
},
query_on_configure = true,
}
register_presence_definition(presence_model_zg204zx, ts0601_fingerprints({
"_TZE200_w0ap83qu",
"HOBEIAN:ZG-204ZX",
}))
local presence_model_excellux_zg301a = {
profile = "safety-presence-illuminance-battery",
datapoints = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_on_off(13, { name = "light_trigger" }),               -- profile 미포함
tuya.dp_battery(14, { emit = emit.battery() }),
tuya.dp_illuminance(20, { emit = emit.illuminance() }),
tuya.dp_numeric(100, { name = "bright_value" }),              -- profile 미포함
tuya.dp_numeric(101, { name = "illuminance_trig" }),          -- profile 미포함
dp_presence_fading_time(102, { name = "presence_time" }),
dp_presence_delay_cap(103, { name = "presence_delay" }),
tuya.dp_numeric(104, { name = "detection_cycle" }),           -- profile 미포함
},
presence_capability_ranges = {
presence_fading_time = capability_range(0, 60, 1, "s"),
presence_delay = capability_range(5, 1800, 1, "s"),
},
query_on_configure = true,
}
register_presence_definition(presence_model_excellux_zg301a, {
device_helpers.create_fingerprint("C6B7KM9", "Excellux"),
})
local presence_model_zd24 = {
profile = "safety-presence-illuminance-battery",
datapoints = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_numeric(4, { name = "distance" }),                   -- profile 미포함
tuya.dp_enum(11, { name = "motion_state" }),                 -- profile 미포함
tuya.dp_numeric(12, { name = "fading_time" }),               -- profile 미포함
tuya.dp_numeric(15, { name = "motion_detection_sensitivity" }), -- profile 미포함
tuya.dp_numeric(16, { name = "static_detection_sensitivity" }), -- profile 미포함
tuya.dp_illuminance(20, { emit = emit.illuminance() }),
tuya.dp_battery(81, { emit = emit.battery() }),
tuya.dp_on_off(101, { name = "init" }),                      -- profile 미포함
tuya.dp_numeric(102, { name = "motion_detection_mode" }),    -- profile 미포함
},
query_on_configure = true,
}
register_presence_definition(presence_model_zd24, device_helpers.create_fingerprints("TS0601", {
"_TZE284_bw4ayyeh",
}))
local presence_model_mir_he200_ty = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
dp_presence_sensitivity_numeric(2),
tuya.dp_occupancy(102, {}),                                     -- 프로파일 미포함
tuya.dp_illuminance(103, { emit = emit.illuminance() }),
dp_tumble_switch_cap(105),
dp_tumble_alarm_time_cap(106),
dp_radar_scene_cap(112, { converter = radar_scene_mir_converter }),
tuya.dp_enum(114, { name = "motion_direction" }),               -- 프로파일 미포함
tuya.dp_numeric(115, { name = "motion_speed" }),                -- 프로파일 미포함
tuya.dp_enum(116, { name = "fall_down_status" }),               -- 프로파일 미포함
tuya.dp_numeric(117, { name = "static_dwell_alarm" }),          -- 미구현
dp_fall_sensitivity_cap(118),
}
register_presence_definition(presence_model_mir_he200_ty, ts0601_fingerprints({
"_TZE200_lu01t0zl",
"_TZE200_vrfecyku",
"_TZE200_ypprdwsl",
"_TZE200_jkbljri7",
"_TZE204_bvfld3xc",
}), {
presence_sensitivity = capability_range(0, 10, 1),
tumble_alarm_time = capability_range(1, 5, 1, "min"),
fall_sensitivity = capability_range(1, 10, 1),
tumble_switch = capability_values({ "on", "off" }),
radar_scene = capability_values({ "default", "area", "toilet", "bedroom", "parlour", "office", "hotel" }),
})
local presence_model_zy_m100_l = {
profile = "safety-presence-zym100l-fixed-illuminance",
tuya.dp_presence(1, { emit = emit.presence() }),
tuya.dp_numeric(2, { name = "presence_sensitivity", emit = emit.presenceSensitivityZym100l() }),
tuya.dp_numeric(3, { name = "minimum_range", scale = 100, emit = emit.minimumRangeZym100l() }),
tuya.dp_numeric(4, { name = "presence_detection_range", scale = 100, emit = emit.presenceDetectionRangeZym100l() }),
tuya.dp_enum(6, {
name = "self_test",
emit = emit.selfTestPresence(),
converter = converter.lookup_from_to({ on = 1, off = 0 }),
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
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
dp_presence_fading_time(102, {}),
tuya.dp_illuminance(103, { emit = emit.illuminance() }),
dp_keep_sensitivity_cap(110),
dp_trigger_sensitivity_cap(114),
dp_presence_target_distance(182, { scale = 10 }),
}
register_presence_definition(presence_model_y1_in, ts0601_fingerprints({
"_TZE204_bmdsp6bs",
}), {
keep_sensitivity = capability_range(0, 10, 1),
trigger_sensitivity = capability_range(1, 20, 1),
presence_fading_time = capability_range(1, 60, 1, "s"),
})
local presence_model_zy_m100_s_1 = {
tuya.dp_illuminance(104, { emit = emit.illuminance() }),
tuya.dp_presence(105, { emit = emit.presence(), converter = converter.true_false1() }),
dp_presence_sensitivity_numeric(106),
dp_presence_detection_range(107, { scale = 100 }),
dp_minimum_range_cap(108, { scale = 100 }),
dp_presence_target_distance(109, {}),
dp_presence_fading_time(110, { scale = 10 }),
dp_detection_delay_cap(111, { scale = 10 }),
}
register_presence_definition(presence_model_zy_m100_s_1, ts0601_fingerprints({
"_TZE204_sxm7l9xa",
"_TZE204_e5m9c5hl",
}), {
presence_sensitivity = capability_range(0, 9, 1),
minimum_range = capability_range(0, 9.5, 0.15, "m"),
presence_detection_range = capability_range(0, 9.5, 0.15, "m"),
detection_delay = capability_range(0, 3600, 0.1, "s"),
presence_fading_time = capability_range(0.5, 1500, 1, "s"),
})
register_presence_definition(presence_model_zy_m100_s_1, {
device_helpers.create_fingerprint("Wenzhi", "WZ-M100-W"),
}, {
presence_sensitivity = capability_range(0, 9, 1),
minimum_range = capability_range(0, 9.5, 0.15, "m"),
presence_detection_range = capability_range(0, 9.5, 0.15, "m"),
detection_delay = capability_range(0, 3600, 0.1, "s"),
presence_fading_time = capability_range(0.5, 1500, 1, "s"),
})
local presence_model_zy_m100_s_2 = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
dp_presence_sensitivity_numeric(2),
dp_minimum_range_cap(3, { scale = 100 }),
dp_presence_detection_range(4, { scale = 100 }),
dp_presence_target_distance(9, {}),
dp_detection_delay_cap(101, { scale = 10 }),
dp_presence_fading_time(102, { scale = 10 }),
tuya.dp_illuminance(104, { emit = emit.illuminance() }),
}
register_presence_definition(presence_model_zy_m100_s_2, ts0601_fingerprints({
"_TZE204_qasjif9e",
"_TZE200_qasjif9e",
"_TZE204_ztqnh5cg",
"_TZE204_iadro9bf",
"_TZE284_iadro9bf",
}), {
presence_sensitivity = capability_range(0, 9, 1),
minimum_range = capability_range(0, 9.5, 0.15, "m"),
presence_detection_range = capability_range(0, 9.5, 0.15, "m"),
detection_delay = capability_range(0, 3600, 0.1, "s"),
presence_fading_time = capability_range(0.5, 1500, 1, "s"),
})
register_presence_definition(presence_model_zy_m100_s_2, {
device_helpers.create_fingerprint("iHseno", "TY_24G_Sensor_V2"),
}, {
presence_sensitivity = capability_range(0, 9, 1),
minimum_range = capability_range(0, 9.5, 0.15, "m"),
presence_detection_range = capability_range(0, 9.5, 0.15, "m"),
detection_delay = capability_range(0, 3600, 0.1, "s"),
presence_fading_time = capability_range(0.5, 1500, 1, "s"),
})
local presence_model_wz_m100 = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
dp_presence_sensitivity_numeric(2),
dp_minimum_range_cap(3, { scale = 100 }),
dp_presence_detection_range(4, { scale = 100 }),
dp_presence_target_distance(9, {}),
tuya.dp_illuminance(103, { emit = emit.illuminance() }),
tuya.dp_numeric(104, { name = "interval_time" }),               -- 미구현
dp_detection_delay_cap(105, { scale = 10 }),
dp_presence_fading_time(106, { scale = 10 }),
}
register_presence_definition(presence_model_wz_m100, ts0601_fingerprints({
"_TZE204_laokfqwu",
}), {
presence_sensitivity = capability_range(1, 9, 1),
minimum_range = capability_range(0, 10, 0.1, "m"),
presence_detection_range = capability_range(0, 10, 0.1, "m"),
detection_delay = capability_range(0, 3600, 0.1, "s"),
presence_fading_time = capability_range(5, 1500, 5, "s"),
})
local presence_hps = {
tuya.dp_presence(1, { emit = emit.presence() }),
tuya.dp_numeric(101, { name = "duration_of_attendance" }),      -- 프로파일 미포함
tuya.dp_numeric(102, { name = "duration_of_absence" }),         -- 프로파일 미포함
tuya.dp_binary(103, { name = "led_state" }),                    -- 지원필요없음
}
register_device_definition(presence_hps, ts0601_fingerprints({
"_TZE200_0u3bj3rc",
"_TZE200_v6ossqfy",
"_TZE200_mx6u6l4y",
}))
local presence_model_zy_hps01 = {
tuya.dp_illuminance(12, { emit = emit.illuminance() }),
tuya.dp_presence(101, { emit = emit.presence(), converter = converter.true_false0() }),
dp_presence_fading_time(104, {}),
dp_move_sensitivity_cap(105),
dp_breath_sensitivity_cap(107),
dp_move_detection_max_distance_cap(109, { scale = 100 }),
dp_move_detection_min_distance_cap(110, { scale = 100 }),
dp_breath_detection_max_distance_cap(111, { scale = 100 }),
dp_breath_detection_min_distance_cap(112, { scale = 100 }),
}
local presence_model_zy_hps01_entry = {
profile = "safety-presence-zy-hps01-illuminance",
datapoints = presence_model_zy_hps01,
presence_capability_ranges = {
presence_fading_time = capability_range(0, 180, 1, "s"),
move_sensitivity = capability_range(0, 10, 1),
breath_sensitivity = capability_range(0, 10, 1),
move_detection_max_distance = capability_range(0, 6, 0.1, "m"),
move_detection_min_distance = capability_range(0, 6, 0.1, "m"),
breath_detection_max_distance = capability_range(0, 6, 0.1, "m"),
breath_detection_min_distance = capability_range(0, 6, 0.1, "m"),
},
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
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
dp_static_detection_sensitivity_cap(2),
dp_presence_detection_range_static(4, {}),
tuya.dp_motion_state(101, {}),                                  -- 프로파일 미포함
dp_presence_fading_time(102, {}),
tuya.dp_illuminance(106, { emit = emit.illuminance() }),
tuya.dp_indicator(107, {}),                                     -- 지원필요없음
tuya.dp_battery(121, { emit = emit.battery() }),
dp_motion_detection_mode_cap(122, { converter = motion_detection_mode_zg204zm_converter }),
dp_motion_detection_sensitivity_cap(123),
}
register_presence_definition(presence_model_zg_204zm, {
device_helpers.create_fingerprint("_TZE200_2aaelwxk", "TS0601"),
device_helpers.create_fingerprint("_TZE200_2aaelwxk", "TS0225"),
device_helpers.create_fingerprint("_TZE200_kb5noeto", "TS0601"),
device_helpers.create_fingerprint("_TZE200_tyffvoij", "TS0601"),
device_helpers.create_fingerprint("_TZE200_yflzeeqj", "TS0601"),
}, {
static_detection_sensitivity = capability_range(0, 10, 1),
motion_detection_sensitivity = capability_range(0, 10, 1),
presence_detection_range = capability_range(0, 6, 0.01, "m"),
presence_fading_time = capability_range(0, 28800, 1, "s"),
motion_detection_mode = capability_values({ "only_pir", "pir_and_radar", "only_radar" }),
})
local presence_model_zg_204zk = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
dp_static_detection_sensitivity_cap(2),
dp_presence_detection_range_static(4, {}),
dp_presence_fading_time(102, {}),
tuya.dp_illuminance(106, { emit = emit.illuminance() }),
tuya.dp_indicator(107, {}),
tuya.dp_battery(121, { emit = emit.battery() }),
dp_motion_detection_sensitivity_cap(123),
}
register_presence_definition(presence_model_zg_204zk, {
device_helpers.create_fingerprint("_TZE200_ka8l86iu", "TS0601"),
device_helpers.create_fingerprint("_TZE200_zbfmvj13", "TS0601"),
device_helpers.create_fingerprint("HOBEIAN", "ZG-204ZK"),
}, {
static_detection_sensitivity = capability_range(0, 10, 1),
motion_detection_sensitivity = capability_range(0, 10, 1),
presence_detection_range = capability_range(0, 5, 0.01, "m"),
presence_fading_time = capability_range(0, 28800, 1, "s"),
})
local presence_model_zg_204ze = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
dp_motion_detection_sensitivity_cap(2),
dp_presence_fading_time(102, {}),
tuya.dp_illuminance(106, { emit = emit.illuminance() }),
tuya.dp_illuminance_interval(107, {}),
tuya.dp_indicator(108, {}),
tuya.dp_battery(110, { emit = emit.battery() }),
}
register_presence_definition(presence_model_zg_204ze, {
device_helpers.create_fingerprint("ZG-204ZE", "CK-BL702-MWS-01(7016)"),
device_helpers.create_fingerprint("_TZE200_cq8lu23i", "TS0601"),
device_helpers.create_fingerprint("_TZE200_4pm4pekt", "TS0601"),
device_helpers.create_fingerprint("HOBEIAN", "ZG-204ZE"),
}, {
motion_detection_sensitivity = capability_range(0, 19, 1),
presence_fading_time = capability_range(0, 28800, 1, "s"),
})
local presence_model_zg_204zv = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
dp_motion_detection_sensitivity_cap(2),
tuya.dp_humidity(101, raw_humidity_options()),
dp_presence_fading_time(102, {}),
tuya.dp_humidity_calibration(104, {}),                         -- 미구현
tuya.dp_temperature_calibration(105, {}),                      -- 미구현
tuya.dp_illuminance(106, { emit = emit.illuminance() }),
tuya.dp_illuminance_interval(107, {}),                         -- 미구현
tuya.dp_indicator(108, {}),                                    -- 지원필요없음
tuya.dp_temperature_unit(109, {}),                             -- 지원필요없음
tuya.dp_battery(110, { emit = emit.battery() }),
tuya.dp_temperature(111, { emit = emit.temperature() }),
}
register_presence_definition(presence_model_zg_204zv, ts0601_fingerprints({
"_TZE200_uli8wasj",
"_TZE200_grgol3xp",
"_TZE200_rhgsbacq",
"_TZE200_y8jijhba",
"HOBEIAN:ZG-204ZV",
}), {
motion_detection_sensitivity = capability_range(0, 19, 1),
presence_fading_time = capability_range(0, 28800, 1, "s"),
})
local presence_model_zg_204zh = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
dp_static_detection_sensitivity_cap(2),
dp_presence_detection_range(4, { scale = 100 }),
tuya.dp_humidity(101, raw_humidity_options()),
dp_presence_fading_time(102, {}),
tuya.dp_enum(103, { name = "motion_state" }),                  -- 프로파일 미포함
tuya.dp_humidity_calibration(104, {}),                         -- 미구현
tuya.dp_temperature_calibration(105, {}),                      -- 미구현
tuya.dp_illuminance(106, { emit = emit.illuminance() }),
tuya.dp_illuminance_interval(107, {}),                         -- 미구현
tuya.dp_indicator(108, {}),                                    -- 지원필요없음
tuya.dp_temperature_unit(109, {}),                             -- 지원필요없음
tuya.dp_battery(110, { emit = emit.battery() }),
tuya.dp_temperature(111, { emit = emit.temperature() }),
dp_motion_detection_mode_cap(112),
dp_motion_detection_sensitivity_cap(123),
}
register_presence_definition(presence_model_zg_204zh, ts0601_fingerprints({
"_TZE200_vuqzj1ej",
"_TZE200_hdih4foa",
"HOBEIAN:ZG-204ZH",
}), {
static_detection_sensitivity = capability_range(0, 10, 1),
motion_detection_sensitivity = capability_range(0, 10, 1),
presence_detection_range = capability_range(0, 5, 0.01, "m"),
presence_fading_time = capability_range(0, 28800, 1, "s"),
motion_detection_mode = capability_values({ "pir_and_radar", "pir_or_radar", "only_radar" }),
})
local presence_model_zg_204zq = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_humidity(101, raw_humidity_options()),
dp_presence_fading_time(102, {}),
tuya.dp_humidity_calibration(104, {}),                         -- 미구현
tuya.dp_temperature_calibration(105, {}),                      -- 미구현
tuya.dp_illuminance(106, { emit = emit.illuminance() }),
tuya.dp_illuminance_interval(107, {}),                         -- 미구현
tuya.dp_indicator(108, {}),                                    -- 지원필요없음
tuya.dp_temperature_unit(109, {}),                             -- 지원필요없음
tuya.dp_battery(110, { emit = emit.battery() }),
tuya.dp_temperature(111, { emit = emit.temperature() }),
}
register_presence_definition(presence_model_zg_204zq, ts0601_fingerprints({
"_TZE200_p9zbdqgs",
"HOBEIAN:ZG-204ZQ",
}), {
presence_fading_time = capability_range(0, 28800, 1, "s"),
})
local presence_model_gnpflcoq = {
profile = "safety-presence-gnpflcoq-illuminance-temp-humidity-battery",
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false0() }),
tuya.dp_numeric(2, { name = "sensitivity", emit = emit.presenceSensitivityGnpflcoq() }),
tuya.dp_battery(4, { emit = emit.battery() }),
tuya.dp_temperature(7, { emit = emit.temperature("C"), scale = 10 }),
tuya.dp_humidity(8, { emit = emit.humidity() }),
tuya.dp_illuminance(11, { emit = emit.illuminance() }),
tuya.dp_fading_time(102, { name = "fading_time", emit = emit.presenceFadingTimeGnpflcoq() }),
}
register_presence_definition(presence_model_gnpflcoq, ts0601_fingerprints({
"_TZE284_gnpflcoq",
}), {
presence_sensitivity = capability_range(0, 10, 1),
presence_fading_time = capability_range(0, 1000, 1, "s"),
})
local presence_switch_model_zg_302zm = {
profile = "switches-presence-switch-3",
named_datapoints = true,
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_numeric(2, { name = "sensitivity" }),                  -- 프로파일 미포함
tuya.dp_numeric(4, { name = "distance", scale = 100 }),        -- 프로파일 미포함
tuya.dp_on_off(101, { name = "switch", component = "main", emit = emit.switch() }),
tuya.dp_on_off(102, { name = "switch", component = "switch2", emit = emit.switch() }),
tuya.dp_on_off(103, { name = "switch", component = "switch3", emit = emit.switch() }),
tuya.dp_on_off(111, { name = "backlight" }),                   -- 프로파일 미포함
tuya.dp_power_outage_memory(112, { name = "power_outage_memory" }), -- 프로파일 미포함
tuya.dp_enum(113, { name = "auto_on", converter = presence_switch_auto_channel_converter }), -- 프로파일 미포함
tuya.dp_numeric(114, { name = "trigger_hold" }),               -- 프로파일 미포함
tuya.dp_enum(115, { name = "auto_off", converter = presence_switch_auto_channel_converter }), -- 프로파일 미포함
tuya.dp_enum(108, { name = "trigger_switch", converter = presence_switch_trigger_channel_converter }), -- 프로파일 미포함
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
profile = "switches-presence-switch-3",
named_datapoints = true,
tuya.dp_presence(101, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_numeric(102, { name = "sensitivity" }),                -- 프로파일 미포함
tuya.dp_on_off(1, { name = "switch", component = "main", emit = emit.switch() }),
tuya.dp_on_off(2, { name = "switch", component = "switch2", emit = emit.switch() }),
tuya.dp_on_off(3, { name = "switch", component = "switch3", emit = emit.switch() }),
tuya.dp_on_off(16, { name = "backlight" }),                    -- 프로파일 미포함
tuya.dp_power_outage_memory(14, { name = "power_outage_memory" }), -- 프로파일 미포함
tuya.dp_numeric(103, { name = "trigger_hold" }),               -- 프로파일 미포함
tuya.dp_enum(104, { name = "auto_on", converter = presence_switch_auto_channel_long_converter }), -- 프로파일 미포함
tuya.dp_enum(105, { name = "auto_off", converter = presence_switch_auto_channel_long_converter }), -- 프로파일 미포함
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
local presence_switch_model_zis03 = {
profile = "safety-presence-switch-illuminance",
named_datapoints = true,
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_numeric(4, { name = "detection_range" }),              -- 프로파일 미포함
tuya.dp_numeric(101, { name = "detection_distance" }),         -- 프로파일 미포함
tuya.dp_binary(102, { name = "indicator" }),                   -- 프로파일 미포함
tuya.dp_illuminance(103, { emit = emit.illuminance() }),
tuya.dp_numeric(104, { name = "fading_time" }),                -- 프로파일 미포함
tuya.dp_numeric(106, { name = "compensation_coefficient" }),   -- 프로파일 미포함
tuya.dp_on_off(107, { name = "switch", component = "main", emit = emit.switch() }),
tuya.dp_binary(108, { name = "radar" }),                       -- 프로파일 미포함
tuya.dp_enum(111, {
name = "detection_area",
converter = converter.lookup_from_to({
all = 0,
left = 1,
right = 2,
}),
}),                                                            -- 프로파일 미포함
tuya.dp_binary(112, { name = "state_reversal" }),              -- 프로파일 미포함
tuya.dp_enum(113, {
name = "sensitivity",
converter = converter.lookup_from_to({
low = 0,
medium = 1,
high = 2,
max = 3,
}),
}),                                                            -- 프로파일 미포함
}
register_presence_definition(presence_switch_model_zis03, ts0601_fingerprints({
"_TZE204_izy1g1mb",
"_TZE204_f2rflfa6",
}))
register_presence_definition(presence_switch_model_zis03, {
device_helpers.create_fingerprint("Novato", "ZIS-04"),
})
local presence_model_zy_m100_24g = {
dp_presence_illuminance_threshold(102),
dp_illuminance_threshold_min_cap(103),
tuya.dp_illuminance(104, { emit = emit.illuminance() }),
tuya.dp_enum(105, { name = "state" }),                          -- 프로파일 미포함
dp_move_sensitivity_cap(106, { converter = converter.divide_by_from_only(10) }),
dp_presence_detection_range(107, { scale = 100 }),
dp_presence_target_distance(109, {}),
dp_presence_fading_time(110, {}),
dp_presence_sensitivity_numeric(111, { converter = converter.divide_by_from_only(10) }),
tuya.dp_presence(112, { emit = emit.presence(), converter = converter.true_false1() }),
}
register_presence_definition(presence_model_zy_m100_24g, ts0601_fingerprints({
"_TZE204_ijxvkhd0",
}), {
move_sensitivity = MOVE_SENSITIVITY_TEN_RANGE,
presence_sensitivity = PRESENCE_SENSITIVITY_TEN_RANGE,
presence_detection_range = capability_range(1.5, 5.5, 1, "m"),
presence_fading_time = PRESENCE_FADING_TIME_1500_RANGE,
illuminance_threshold_min = capability_range(0, 2000, 1, "lux"),
})
local presence_model_zy_m100_24gv2 = {
tuya.dp_enum(1, { name = "state" }),                            -- 프로파일 미포함
dp_move_sensitivity_cap(2),
dp_minimum_range_cap(3, { scale = 100 }),
dp_presence_detection_range(4, { scale = 100 }),
dp_presence_target_distance(9, { scale = 10 }),
dp_presence_sensitivity_numeric(102),
tuya.dp_illuminance(103, { emit = emit.illuminance() }),
tuya.dp_presence(104, { emit = emit.presence(), converter = converter.true_false1() }),
dp_presence_fading_time(105, {}),
}
register_presence_definition(presence_model_zy_m100_24gv2, ts0601_fingerprints({
"_TZE204_7gclukjs",
}), {
move_sensitivity = capability_range(0, 10, 1),
presence_sensitivity = capability_range(0, 10, 1),
minimum_range = PRESENCE_DETECTION_RANGE_075_90_RANGE,
presence_detection_range = PRESENCE_DETECTION_RANGE_075_90_RANGE,
presence_fading_time = PRESENCE_FADING_TIME_1500_RANGE,
})
local presence_model_zy_m100_24gv3 = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false0() }),
dp_move_sensitivity_cap(2),
dp_minimum_range_cap(3, { scale = 100 }),
dp_presence_detection_range(4, { scale = 100 }),
dp_presence_target_distance(9, { scale = 10 }),
tuya.dp_binary(101, { name = "find_switch" }),                  -- 지원필요없음
dp_presence_sensitivity_numeric(102),
tuya.dp_illuminance(103, { emit = emit.illuminance() }),
dp_presence_fading_time(105, {}),
}
register_presence_definition(presence_model_zy_m100_24gv3, ts0601_fingerprints({
"_TZE204_ya4ft0w4",
"_TZE200_ya4ft0w4",
}), {
move_sensitivity = MOVE_SENSITIVITY_TEN_RANGE,
presence_sensitivity = PRESENCE_SENSITIVITY_TEN_RANGE,
minimum_range = PRESENCE_DETECTION_RANGE_075_90_RANGE,
presence_detection_range = PRESENCE_DETECTION_RANGE_075_90_RANGE,
presence_fading_time = PRESENCE_FADING_TIME_15000_RANGE,
})
register_presence_definition(presence_model_zy_m100_24gv3, ts0601_fingerprints({
"_TZE204_gkfbdvyx",
"_TZE200_gkfbdvyx",
}), {
move_sensitivity = MOVE_SENSITIVITY_TEN_RANGE,
presence_sensitivity = PRESENCE_SENSITIVITY_TEN_RANGE,
minimum_range = capability_range(0.5, 9.0, 0.5, "m"),
presence_detection_range = capability_range(0.5, 9.0, 0.5, "m"),
presence_fading_time = PRESENCE_FADING_TIME_15000_RANGE,
})
local presence_model_yxzbrb58 = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
dp_presence_sensitivity_numeric(2),
dp_minimum_range_cap(3, { scale = 100 }),
dp_presence_detection_range(4, { scale = 100 }),
tuya.dp_illuminance(101, { emit = emit.illuminance() }),
dp_detection_delay_cap(102, { scale = 10 }),
dp_presence_fading_time(103, { scale = 10 }),
dp_radar_scene_cap(104, { converter = radar_scene_yxz_converter }),
dp_presence_target_distance(105, {}),
}
register_presence_definition(presence_model_yxzbrb58, ts0601_fingerprints({
"_TZE204_sooucan5",
"_TZE204_oqtpvx51",
}), {
presence_sensitivity = capability_range(0, 9, 1),
minimum_range = capability_range(0, 10, 0.1, "m"),
presence_detection_range = capability_range(0, 10, 0.1, "m"),
detection_delay = capability_range(0, 3600, 0.1, "s"),
presence_fading_time = capability_range(0, 1500, 1, "s"),
radar_scene = capability_values({ "default", "bathroom", "bedroom", "sleeping", "unknown" }),
})
local presence_model_ctl_r1_ty_zigbee = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
dp_presence_sensitivity_numeric(2),
dp_presence_detection_range(4, { scale = 10 }),
tuya.dp_illuminance(101, { emit = emit.illuminance() }),
dp_presence_illuminance_threshold(102),
dp_illuminance_threshold_min_cap(103),
dp_detection_delay_cap(104),
dp_light_switch_cap(105),
dp_light_linkage_cap(106),
tuya.dp_enum(107, { name = "indicator_light" }),                -- 지원필요없음
dp_detection_method_cap(108),
dp_presence_illuminance_switch_cap(109),
}
register_presence_definition(presence_model_ctl_r1_ty_zigbee, ts0601_fingerprints({
"_TZE204_e9ajs4ft",
}), {
presence_sensitivity = capability_range(0, 100, 1),
presence_detection_range = capability_range(1.5, 4.5, 0.1, "m"),
presence_illuminance_threshold = capability_range(0, 2000, 1, "lux"),
illuminance_threshold_min = capability_range(0, 2000, 1, "lux"),
detection_delay = capability_range(0, 3600, 1, "s"),
light_switch = capability_values(ON_OFF_VALUES),
light_linkage = capability_values(ON_OFF_VALUES),
presence_illuminance_switch = capability_values(ON_OFF_VALUES),
detection_method = capability_values({ "only_move", "exist_move" }),
})
local presence_model_rt_zcz03z = {
tuya.dp_presence(1, { emit = emit.presence() }),
dp_presence_target_distance(101, { scale = 100 }),
tuya.dp_illuminance(102, { emit = emit.illuminance() }),
dp_presence_fading_time(103, {}),
tuya.dp_indicator(104, {}),                                     -- 지원필요없음
dp_presence_detection_range(107, { scale = 100 }),
dp_minimum_range_cap(108, { scale = 100 }),
dp_presence_sensitivity_numeric(111),
}
register_presence_definition(presence_model_rt_zcz03z, ts0601_fingerprints({
"_TZE204_uxllnywp",
}), {
presence_sensitivity = PRESENCE_SENSITIVITY_TEN_RANGE,
minimum_range = capability_range(0, 8.4, 0.01, "m"),
presence_detection_range = capability_range(0, 8.4, 0.01, "m"),
presence_fading_time = capability_range(1, 59, 1, "s"),
})
local presence_model_mtg075_zb_rl = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
dp_presence_sensitivity_numeric(2),
dp_shield_range_cap(3, { scale = 100 }),
dp_presence_detection_range(4, { scale = 100 }),
tuya.dp_numeric(6, { name = "equipment_status" }),              -- 프로파일 미포함
dp_presence_target_distance(9, {}),
dp_entry_filter_time_cap(101, { scale = 10 }),
dp_presence_fading_time(102, {}),
tuya.dp_illuminance(104, { emit = emit.illuminance(), scale = 10 }),
dp_entry_sensitivity_cap(105),
dp_entry_distance_indentation_cap(106, { scale = 100 }),
dp_breaker_mode_cap(107),
dp_breaker_status_cap(108),
dp_status_indication_cap(109),
dp_presence_illuminance_threshold(110, { scale = 10 }),
tuya.dp_enum(111, { name = "breaker_polarity" }),               -- 지원필요없음
dp_block_time_cap(112, { scale = 10 }),
dp_sensor_state_mode_cap(115),
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
}), {
entry_sensitivity = capability_range(0, 9, 1),
presence_sensitivity = capability_range(0, 9, 1),
shield_range = capability_range(0, 8, 0.1, "m"),
presence_detection_range = capability_range(0, 8, 0.1, "m"),
entry_filter_time = capability_range(0, 600, 0.1, "s"),
entry_distance_indentation = capability_range(0, 8, 0.01, "m"),
block_time = capability_range(0, 600, 0.1, "s"),
presence_fading_time = capability_range(0, 600, 1, "s"),
presence_illuminance_threshold = capability_range(0, 420, 0.1, "lux"),
breaker_mode = capability_values(STANDARD_LOCAL_VALUES),
breaker_status = capability_values(ON_OFF_VALUES),
status_indication = capability_values(ON_OFF_VALUES),
sensor_state_mode = capability_values(SENSOR_STATE_MODE_VALUES),
})
register_presence_definition(presence_model_mtg075_zb_rl, {
device_helpers.create_fingerprint("Tuya", "MTG275-ZB-RL"),
device_helpers.create_fingerprint("Tuya", "MTG035-ZB-RL"),
device_helpers.create_fingerprint("Tuya", "MTG235-ZB-RL"),
device_helpers.create_fingerprint("QA", "QASZ24R"),
}, {
entry_sensitivity = capability_range(0, 9, 1),
presence_sensitivity = capability_range(0, 9, 1),
shield_range = capability_range(0, 8, 0.1, "m"),
presence_detection_range = capability_range(0, 8, 0.1, "m"),
entry_filter_time = capability_range(0, 600, 0.1, "s"),
entry_distance_indentation = capability_range(0, 8, 0.01, "m"),
block_time = capability_range(0, 600, 0.1, "s"),
presence_fading_time = capability_range(0, 600, 1, "s"),
presence_illuminance_threshold = capability_range(0, 420, 0.1, "lux"),
breaker_mode = capability_values(STANDARD_LOCAL_VALUES),
breaker_status = capability_values(ON_OFF_VALUES),
status_indication = capability_values(ON_OFF_VALUES),
sensor_state_mode = capability_values(SENSOR_STATE_MODE_VALUES),
})
local presence_model_zy_m100_s_3 = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false0() }),
dp_presence_sensitivity_low_medium_high(9),
dp_keep_time_cap(10),
tuya.dp_illuminance(12, { emit = emit.illuminance() }),
}
register_presence_definition(presence_model_zy_m100_s_3, ts0601_fingerprints({
"_TZE204_nbkshs6k",
}), {
presence_sensitivity = PRESENCE_SENSITIVITY_LOW_MEDIUM_HIGH_RANGE,
keep_time = KEEP_TIME_PRESET_RANGE,
})
local presence_model_zg_205z = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false0() }),
dp_presence_target_distance(101, {}),
tuya.dp_illuminance(102, { emit = emit.illuminance() }),
dp_presence_fading_time(103, {}),
tuya.dp_indicator(104, {}),                                     -- 지원필요없음
dp_move_detection_max_distance_cap(107, { scale = 100 }),
dp_move_detection_min_distance_cap(108, { scale = 100 }),
dp_breath_detection_max_distance_cap(109, { scale = 100 }),
dp_breath_detection_min_distance_cap(110, { scale = 100 }),
dp_small_move_detection_max_distance_cap(114, { scale = 100 }),
dp_small_move_detection_min_distance_cap(115, { scale = 100 }),
dp_move_sensitivity_cap(116),
dp_small_move_sensitivity_cap(117),
dp_breath_sensitivity_cap(118),
}
register_presence_definition(presence_model_zg_205z, ts0601_fingerprints({
"_TZE204_dapwryy7",
}), {
presence_fading_time = capability_range(0, 28800, 1, "s"),
move_detection_max_distance = capability_range(0, 10, 0.01, "m"),
move_detection_min_distance = capability_range(0, 10, 0.01, "m"),
small_move_detection_max_distance = capability_range(0, 6, 0.01, "m"),
small_move_detection_min_distance = capability_range(0, 6, 0.01, "m"),
move_sensitivity = capability_range(0, 10, 1),
small_move_sensitivity = capability_range(0, 10, 1),
breath_detection_max_distance = capability_range(0, 6, 0.01, "m"),
breath_detection_min_distance = capability_range(0, 6, 0.01, "m"),
breath_sensitivity = capability_range(0, 10, 1),
})
local presence_model_zg_205za = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
dp_large_motion_detection_sensitivity_cap(2),
dp_large_motion_detection_distance_cap(4, { scale = 100 }),
tuya.dp_enum(101, {
name = "motion_state",
lookup = {
none = 0,
large = 1,
medium = 2,
small = 3,
far = 4,
near = 5,
},
}),
dp_presence_fading_time(102, {}),
dp_medium_motion_detection_distance_cap(104, { scale = 100 }),
dp_medium_motion_detection_sensitivity_cap(105),
tuya.dp_illuminance(106, { emit = emit.illuminance() }),
tuya.dp_indicator(107, {}),
dp_small_motion_detection_distance_cap(108, { scale = 100 }),
dp_small_motion_detection_sensitivity_cap(109),
dp_presence_target_distance(122, {}),
dp_minimum_range_cap(123, { scale = 100 }),
}
register_presence_definition(presence_model_zg_205za, {
device_helpers.create_fingerprint("_TZE200_crq3r3la", "TS0225"),
device_helpers.create_fingerprint("HOBEIAN", "CK-BL702-MWS-01(7016)"),
device_helpers.create_fingerprint("_TZE200_crq3r3la", "CK-BL702-MWS-01(7016)"),
}, {
presence_fading_time = capability_range(0, 28800, 1, "s"),
large_motion_detection_sensitivity = capability_range(0, 10, 1),
large_motion_detection_distance = capability_range(0, 10, 0.01, "m"),
medium_motion_detection_sensitivity = capability_range(0, 10, 1),
medium_motion_detection_distance = capability_range(0, 6, 0.01, "m"),
small_motion_detection_sensitivity = capability_range(0, 10, 1),
small_motion_detection_distance = capability_range(0, 6, 0.01, "m"),
minimum_range = capability_range(0, 10, 0.01, "m"),
})
local presence_model_zg_205zl = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_motion_state(11, {}),
dp_presence_fading_time(12, {}),
dp_large_motion_detection_distance_cap(13, { scale = 100 }),
dp_small_motion_detection_distance_cap(14, { scale = 100 }),
dp_large_motion_detection_sensitivity_cap(15),
dp_small_motion_detection_sensitivity_cap(16),
tuya.dp_illuminance(20, { emit = emit.illuminance() }),
tuya.dp_alarm_time(101, {}),
tuya.dp_alarm_volume(102, {}),
dp_presence_detection_range_static(103, {}),
dp_static_detection_sensitivity_cap(104),
tuya.dp_enum(105, {
name = "mode",
lookup = {
arm = 0,
off = 1,
alarm = 2,
doorbell = 3,
},
}),
}
register_presence_definition(presence_model_zg_205zl, {
device_helpers.create_fingerprint("_TZE200_hl0ss9oa", "TS0225"),
device_helpers.create_fingerprint("ZGAF-205L", "CK-BL702-MWS-01(7016)"),
device_helpers.create_fingerprint("_TZE200_y4mdop0b", "TS0225"),
}, {
presence_fading_time = capability_range(0, 3600, 1, "s"),
large_motion_detection_sensitivity = capability_range(0, 10, 1),
large_motion_detection_distance = capability_range(0, 10, 0.01, "m"),
small_motion_detection_sensitivity = capability_range(0, 10, 1),
small_motion_detection_distance = capability_range(0, 6, 0.01, "m"),
presence_detection_range = capability_range(0, 6, 0.01, "m"),
static_detection_sensitivity = capability_range(0, 10, 1),
})
local sensor_state_mode_mtd085_converter = converter.lookup_from_to({
on = 0,
occupied = 1,
unoccupied = 2,
})
local presence_model_mtd085_zb = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
dp_entry_sensitivity_cap(101),
tuya.dp_numeric(102, {
name = "entry_distance_indentation",
emit = emit.entry_distance_indentation(),
scale = 100,
}),
dp_presence_fading_time(103, {}),
dp_entry_filter_time_cap(104, { scale = 100 }),
dp_block_time_cap(105, { scale = 10 }),
tuya.dp_illuminance(107, { emit = emit.illuminance(), scale = 10 }),
dp_status_indication_cap(114),
dp_presence_sensitivity_numeric(115),
dp_shield_range_cap(116, { scale = 100 }),
dp_presence_detection_range(117, { scale = 100 }),
dp_presence_target_distance(119, { scale = 100 }),
tuya.dp_enum(112, {
name = "sensor_state_mode",
emit = emit.sensor_state_mode(),
converter = sensor_state_mode_mtd085_converter,
}),
}
register_presence_definition({
datapoints = presence_model_mtd085_zb,
query_on_configure = true,
}, {
device_helpers.create_fingerprint("_TZ321C_fkzihax8", "TS0225"),
device_helpers.create_fingerprint("_TZ321C_4slreunp", "TS0225"),
}, {
entry_sensitivity = capability_range(10, 100, 10, "%"),
entry_distance_indentation = capability_range(0, 8, 0.01, "m"),
presence_fading_time = capability_range(5, 7200, 1, "s"),
entry_filter_time = capability_range(0, 0.5, 0.01, "s"),
block_time = capability_range(0, 10, 0.1, "s"),
status_indication = capability_values(ON_OFF_VALUES),
presence_sensitivity = capability_range(10, 100, 10, "%"),
shield_range = capability_range(0, 8, 0.01, "m"),
presence_detection_range = capability_range(0, 8, 0.01, "m"),
presence_target_distance = capability_range(0, 8, 0.01, "m"),
sensor_state_mode = capability_values({ "on", "occupied", "unoccupied" }),
})
local presence_model_zp_301z = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_battery(14, { emit = emit.battery() }),
tuya.dp_illuminance(20, { emit = emit.illuminance() }),
tuya.dp_numeric(100, { name = "brightness_value" }),           -- 프로파일 미포함
tuya.dp_numeric(101, { name = "illuminance_trigger" }),        -- 프로파일 미포함
dp_presence_time_cap(102),
dp_presence_delay_cap(103),
dp_detection_cycle_cap(104),
}
register_presence_definition(presence_model_zp_301z, {
device_helpers.create_fingerprint("_TZE284_d4h8j2n6", "ZP-301Z"),
device_helpers.create_fingerprint("B3876M9", "ZP-301Z"),
}, {
presence_time = capability_range(0, 60, 1, "s"),
presence_delay = capability_range(5, 120, 1, "s"),
detection_cycle = capability_range(10, 1200, 5, "s"),
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
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
dp_presence_detection_range(101, {}),
dp_presence_sensitivity_low_medium_high(102),
dp_radar_switch_cap(103),
tuya.dp_numeric(104, { name = "pir_sensitivity" }),                   -- profile 미포함
dp_presence_fading_time(105, {}),
tuya.dp_binary(107, { name = "led_switch" }),                         -- profile 미포함
tuya.dp_illuminance(108, { emit = emit.illuminance() }),
tuya.dp_battery(109, { emit = emit.battery() }),
},
}
register_device_definition({
profile = "safety-presence-zis01p-illuminance-battery",
datapoints = presence_model_zis_01p.datapoints,
presence_capability_ranges = {
presence_sensitivity = PRESENCE_SENSITIVITY_LOW_MEDIUM_HIGH_RANGE,
presence_detection_range = capability_range(1, 3, 1, "m"),
presence_fading_time = capability_range(10, 600, 10, "s"),
radar_switch = capability_values(ON_OFF_VALUES),
},
query_on_configure = true,
}, ts0601_fingerprints({
"_TZE284_vceqncho",
"_TZE284_who1jxwd",
}))
local presence_model_msa201z = {
profile = "safety-presence-msa201-illuminance",
datapoints = {
tuya.dp_enum(1, { name = "presence", emit = emit.presence(), converter = msa201_presence_converter }),
dp_presence_detection_range(2, { scale = 10 }),
tuya.dp_illuminance(101, { emit = emit.illuminance() }),
tuya.dp_numeric(102, { name = "lux_difference_value" }),              -- profile 미포함
tuya.dp_enum(103, { name = "ai_self_learning" }),                     -- profile 미포함
tuya.dp_enum(104, { name = "factory_reset" }),                        -- profile 미포함
tuya.dp_enum(105, { name = "fast_setting" }),                         -- profile 미포함
dp_presence_fading_time(106, {}),
tuya.dp_indicator(107, {}),                                           -- profile 미포함
tuya.dp_enum(108, { name = "current_status" }),                       -- profile 미포함
tuya.dp_binary(109, { name = "enable_sensor" }),                      -- profile 미포함
tuya.dp_enum(110, { name = "sensitivity" }),                          -- profile 미포함
tuya.dp_binary(112, { name = "status_flip" }),                        -- profile 미포함
tuya.dp_raw(113, { name = "interference_positions" }),                -- profile 미포함
tuya.dp_numeric(114, { name = "forbidden_area", scale = 10 }),        -- profile 미포함
tuya.dp_numeric(115, { name = "daylight_threshold" }),                -- profile 미포함
tuya.dp_enum(116, { name = "sensor_mode" }),                          -- profile 미포함
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
presence_capability_ranges = {
presence_detection_range = capability_range(0.5, 4, 0.5, "m"),
presence_fading_time = capability_range(0, 300, 1, "s"),
},
query_on_configure = true,
}
register_device_definition(presence_model_msa201z, ts0601_fingerprints({
"_TZE284_ajuasrmx",
"_TZE200_hyhl5y36",
"_TZE284_ozf4e02o",
}))
local presence_model_szr07u = {
profile = "safety-presence",
datapoints = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
dp_presence_detection_range(13, { scale = 100 }),
dp_presence_sensitivity_numeric(16),
dp_presence_target_distance(19, {}),
tuya.dp_indicator(101, {}),                                           -- profile 미포함
tuya.dp_raw(102, { name = "presence_notification_toggle" }),          -- profile 미포함
dp_presence_fading_time(103, {}),
},
presence_capability_ranges = {
presence_sensitivity = capability_range(68, 90, 1),
presence_detection_range = capability_range(1.5, 6, 0.75, "m"),
presence_target_distance = capability_range(0, 1000, 1, "cm"),
presence_fading_time = capability_range(3, 1799, 1, "s"),
},
query_on_configure = true,
}
register_device_definition(presence_model_szr07u, ts0601_fingerprints({
"_TZE204_muvkrjr5",
}))
local presence_model_mtd285_zb = {
profile = "safety-presence-illuminance",
datapoints = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
dp_presence_detection_range(3, { name = "min_distance", scale = 10 }), -- profile 미포함
dp_presence_detection_range(4, { scale = 10 }),
dp_presence_target_distance(9, { scale = 10 }),
tuya.dp_raw(112, { name = "configuration_gate" }),                   -- profile 미포함
dp_move_sensitivity_cap(113),
dp_presence_sensitivity_numeric(114),
tuya.dp_numeric(115, { name = "nearest_target_gate" }),              -- profile 미포함
dp_presence_fading_time(116),
tuya.dp_numeric(117, { name = "target_velocity", scale = 100 }),     -- profile 미포함
tuya.dp_enum(119, { name = "led_mode" }),                            -- profile 미포함
dp_presence_delay_cap(120),
dp_block_time_cap(121, { scale = 10 }),
tuya.dp_enum(124, { name = "device_control" }),                      -- profile 미포함
tuya.dp_illuminance(125, { emit = emit.illuminance() }),
},
presence_capability_ranges = {
presence_sensitivity = capability_range(0, 100, 1),
move_sensitivity = capability_range(0, 100, 1),
presence_detection_range = capability_range(0, 10, 0.1, "m"),
presence_target_distance = capability_range(0, 10, 0.1, "m"),
presence_fading_time = capability_range(0, 3600, 1, "s"),
presence_delay = capability_range(0, 3600, 1, "s"),
block_time = capability_range(0, 3600, 0.1, "s"),
},
query_on_configure = true,
}
register_device_definition(presence_model_mtd285_zb, ts0601_fingerprints({
"_TZE284_aai5grix",
"_TZE204_aai5grix",
}))
local presence_model_pj3201a = {
profile = "safety-presence-illuminance",
datapoints = {
tuya.dp_presence(104, { emit = emit.presence(), converter = converter.true_false1() }),
tuya.dp_occupancy(112, { name = "occupancy", emit = emit.motion(), converter = converter.true_false0() }), -- profile 미포함
dp_presence_target_distance(9, { name = "closest_target_distance", scale = 100 }),
dp_presence_fading_time(101, { name = "movement_timeout" }),
dp_presence_delay_cap(102, { name = "idle_timeout" }),
tuya.dp_illuminance(103, { emit = emit.illuminance(), scale = 10 }),
dp_move_sensitivity_cap(105, { name = "far_movement_sensitivity" }),
dp_move_sensitivity_cap(110, { name = "near_movement_sensitivity" }),
dp_presence_sensitivity_numeric(109, { name = "near_presence_sensitivity" }),
dp_presence_sensitivity_numeric(111, { name = "far_presence_sensitivity" }),
dp_presence_detection_range(3, { name = "closest_detection_distance", scale = 100 }),
dp_presence_detection_range(4, { name = "largest_movement_detection_distance", scale = 100 }),
dp_presence_detection_range(108, { name = "largest_presence_detection_distance", scale = 100 }),
tuya.dp_enum(106, { name = "restore_factory" }),                     -- profile 미포함
tuya.dp_enum(107, { name = "led_indicator" }),                        -- profile 미포함
},
presence_capability_ranges = {
presence_sensitivity = capability_range(0, 100, 1),
move_sensitivity = capability_range(0, 100, 1),
presence_detection_range = capability_range(0, 10, 0.01, "m"),
presence_target_distance = capability_range(0, 10, 0.01, "m"),
presence_fading_time = capability_range(0, 3600, 1, "s"),
presence_delay = capability_range(0, 3600, 1, "s"),
},
query_on_configure = true,
}
register_device_definition(presence_model_pj3201a, ts0601_fingerprints({
"_TZE204_eaulras5",
}))
local presence_model_nas_ps09b2 = {
profile = "safety-presence-range-illuminance",
datapoints = {
tuya.dp_occupancy(1, { emit = emit.motion(), converter = converter.true_false0() }),
tuya.dp_enum(11, { name = "human_motion_state" }),                   -- profile 미포함
dp_presence_delay_cap(12, { name = "departure_delay" }),
dp_presence_detection_range(13, { name = "radar_range" }),
dp_move_sensitivity_cap(15, { name = "radar_sensitivity" }),
dp_presence_sensitivity_numeric(16),
dp_presence_target_distance(19, { name = "dis_current" }),
},
presence_capability_ranges = {
presence_sensitivity = capability_range(0, 10, 1),
move_sensitivity = capability_range(0, 10, 1),
presence_detection_range = capability_range(0, 10, 1, "m"),
presence_target_distance = capability_range(0, 10, 1, "m"),
presence_delay = capability_range(0, 3600, 1, "s"),
},
query_on_configure = true,
}
register_device_definition(presence_model_nas_ps09b2, ts0601_fingerprints({
"_TZE204_kyhbrfyl",
}))
local presence_model_rtsc11r = {
profile = "safety-presence-range-delay-illuminance",
datapoints = {
tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
dp_presence_delay_cap(12, { name = "detection_delay" }),
dp_presence_detection_range(19, { name = "detection_distance" }),
tuya.dp_illuminance(20, { emit = emit.illuminance() }),
dp_presence_sensitivity_numeric(101),
dp_keep_time_cap(102),
dp_minimum_range_cap(111),
dp_presence_detection_range(112, { name = "maximum_range" }),
},
presence_capability_ranges = {
presence_sensitivity = capability_range(0, 10, 1),
presence_detection_range = capability_range(0, 10, 1, "m"),
presence_delay = capability_range(0, 3600, 1, "s"),
keep_time = capability_range(0, 3600, 1, "s"),
minimum_range = capability_range(0, 10, 1, "m"),
},
query_on_configure = true,
}
register_device_definition(presence_model_rtsc11r, ts0601_fingerprints({
"_TZE204_mhxn2jso",
}))
local presence_model_rd24g01 = {
profile = "safety-presence-range-illuminance",
datapoints = {
dp_minimum_range_cap(3, { name = "near_detection" }),
dp_presence_detection_range(4, { name = "far_detection" }),
dp_presence_target_distance(9, { name = "target_distance_closest" }),
dp_static_detection_sensitivity_cap(101),
dp_motion_detection_sensitivity_cap(102),
},
presence_capability_ranges = {
static_detection_sensitivity = capability_range(0, 10, 1),
motion_detection_sensitivity = capability_range(0, 10, 1),
presence_detection_range = capability_range(0, 10, 1, "m"),
presence_target_distance = capability_range(0, 10, 1, "m"),
minimum_range = capability_range(0, 10, 1, "m"),
},
query_on_configure = true,
}
register_device_definition(presence_model_rd24g01, ts0601_fingerprints({
"_TZE204_no6qtgtl",
}))
return device_definitions
