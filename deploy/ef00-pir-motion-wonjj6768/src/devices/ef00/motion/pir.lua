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
local pir = {
tuya.dp_occupancy(1, { emit = emit.motion() }),
tuya.dp_battery(4, { emit = emit.battery() }),
tuya.dp_illuminance(101, { emit = emit.illuminance() }),
}
register_device_definition(pir, ts0601_fingerprints({
"_TZE200_f1pvdgoh",
"_TZE200_me6wtiqs",
}))
register_device_definition(pir, {
device_helpers.create_fingerprint("_TZE200_f1pvdgoh", "B"),
device_helpers.create_fingerprint("Immax", "07527L"),
})
local pir_no_battery = {
tuya.dp_occupancy(1, { emit = emit.motion() }),
tuya.dp_illuminance(101, { emit = emit.illuminance() }),
}
register_device_definition(pir_no_battery, ts0601_fingerprints({
"_TZE200_ghynnvos",
}))
register_device_definition(pir_no_battery, {
device_helpers.create_fingerprint("Conecto", "COZIGPMS"),
})
local pir_model_zg_204zl = {
tuya.dp_occupancy(1, { emit = emit.motion() }),
tuya.dp_battery(4, { emit = emit.battery() }),
dp_presence_sensitivity_low_medium_high(9),
dp_keep_time_cap(10),
tuya.dp_illuminance(12, { emit = emit.illuminance() }),
tuya.dp_illuminance_interval(102, {}),                          -- 미구현
}
register_presence_definition(pir_model_zg_204zl, ts0601_fingerprints({
"_TZE200_3towulqd",
"_TZE200_1ibpyhdc",
"_TZE200_bh3n6gk8",
"_TZE200_ttcovulf",
"_TZE200_gjldowol",
"_TZE200_jxyhl4eq",
"_TZE200_qxyh4r7g",
"_TZE200_na5qlzow",
}), {
presence_sensitivity = PRESENCE_SENSITIVITY_LOW_MEDIUM_HIGH_RANGE,
keep_time = KEEP_TIME_PRESET_RANGE,
})
local pir_model_zg_204zl_illuminance_dp101 = {
tuya.dp_occupancy(1, { emit = emit.motion() }),
tuya.dp_battery(4, { emit = emit.battery() }),
dp_presence_sensitivity_low_medium_high(9),
dp_keep_time_cap(10),
tuya.dp_illuminance(101, { emit = emit.illuminance() }),
tuya.dp_illuminance_interval(102, {}),                          -- 미구현
}
register_presence_definition(pir_model_zg_204zl_illuminance_dp101, ts0601_fingerprints({
"_TZE200_s6hzw8g2",
}), {
presence_sensitivity = PRESENCE_SENSITIVITY_LOW_MEDIUM_HIGH_RANGE,
keep_time = KEEP_TIME_PRESET_RANGE,
})
register_presence_definition(pir_model_zg_204zl_illuminance_dp101, {
device_helpers.create_fingerprint("Nedis", "ZBSM20WT"),
}, {
presence_sensitivity = PRESENCE_SENSITIVITY_LOW_MEDIUM_HIGH_RANGE,
keep_time = KEEP_TIME_PRESET_RANGE,
})
local pir_model_zpir_10 = {
tuya.dp_occupancy(1, { emit = emit.motion() }),
tuya.dp_battery(4, { emit = emit.battery() }),
tuya.dp_illuminance(101, { emit = emit.illuminance() }),
}
register_device_definition(pir_model_zpir_10, ts0601_fingerprints({
"_TZE200_ppuj1vem",
"_TZE200_oc7xqqbs",
}))
local pir_solar = {
tuya.dp_occupancy(1, { emit = emit.motion() }),
tuya.dp_battery(4, { emit = emit.battery() }),
dp_presence_sensitivity_high_low(9),
}
register_presence_definition(pir_solar, ts0601_fingerprints({
"_TZE284_tre6haif",
}), {
presence_sensitivity = capability_range_with_allowed_values(1, 3, 1, { 3, 1 }),
})
local pir_legacy = {
tuya.dp_occupancy(1, { emit = emit.motion() }),
tuya.dp_numeric(101, { name = "v_sensitivity" }),               -- 미구현
tuya.dp_numeric(102, { name = "o_sensitivity" }),               -- 미구현
tuya.dp_numeric(103, { name = "vacancy_delay" }),               -- 미구현
tuya.dp_enum(104, { name = "mode" }),                           -- 미구현
tuya.dp_numeric(105, { name = "vacant_confirm_time" }),         -- 미구현
tuya.dp_numeric(106, { name = "reference_luminance" }),         -- 프로파일 미포함
tuya.dp_numeric(107, { name = "light_on_luminance_prefer" }),   -- 프로파일 미포함
tuya.dp_numeric(108, { name = "light_off_luminance_prefer" }),  -- 프로파일 미포함
tuya.dp_illuminance(109, { emit = emit.illuminance() }),
tuya.dp_enum(110, { name = "led_status" }),                     -- 지원필요없음
}
register_device_definition(pir_legacy, ts0601_fingerprints({
"_TZE200_auin8mzr",
}))
local pir_bed = {
tuya.dp_occupancy(1, { emit = emit.motion() }),
tuya.dp_battery(4, { emit = emit.battery() }),
dp_presence_sensitivity_low_medium_high(9),
tuya.dp_illuminance(12, { emit = emit.illuminance() }),
tuya.dp_numeric(101, { name = "interval_time" }),               -- 미구현
dp_presence_delay_cap(102),
dp_presence_time_cap(103),
tuya.dp_enum(104, { name = "work_state" }),                     -- 프로파일 미포함
}
register_presence_definition(pir_bed, ts0601_fingerprints({
"_TZE200_seq9cm6u",
}), {
presence_sensitivity = PRESENCE_SENSITIVITY_LOW_MEDIUM_HIGH_RANGE,
presence_delay = capability_range(0, 3600, 1, "s"),
presence_time = capability_range(0, 3600, 1, "s"),
})
return device_definitions
