local function load_datapoint_preset(tuya, shared)
local type_check = shared.type_check
local table_insert = shared.table_insert
local tonumber_check = shared.tonumber_check
local merge_options = shared.merge_options
local copy_keys = shared.copy_keys
local converter = tuya.converter
local function apply_defaults(target, defaults)
if type_check(target) ~= "table" or type_check(defaults) ~= "table" then
return target
end
for key, value in pairs(defaults) do
if target[key] == nil then
target[key] = value
end
end
return target
end
local function normalize_preset_options(name_or_options, options, default_name)
local resolved = {}
if type_check(name_or_options) == "string" then
resolved.name = name_or_options
else
merge_options(resolved, name_or_options)
end
merge_options(resolved, options)
if resolved.name == nil and default_name ~= nil then
resolved.name = default_name
end
return resolved
end
local send_policy_option_keys = {
"send_policy",
"command_id",
"transaction",
"batch_key",
"match_transaction",
"response_dp",
"response_dps",
"match_response",
}
local function has_send_policy_options(options)
if type_check(options) ~= "table" then
return false
end
for _, key in ipairs(send_policy_option_keys) do
if options[key] ~= nil then
return true
end
end
return false
end
local function apply_default_fixed_send_policy(mapping, options)
if has_send_policy_options(options) then
return mapping
end
return tuya.apply_fixed_send_policy(mapping)
end
local function build_scaled_numeric_preset(dp, default_name, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, default_name)
local scale = resolved.scale
if scale == nil then
scale = 10
end
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and scale ~= 1 then
resolved.converter = converter.divide_by_pair(scale)
end
resolved.scale = nil
return tuya.dp_numeric(dp, resolved)
end
local function build_divided_numeric_preset(dp, default_name, default_scale, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, default_name)
local scale = resolved.scale
if scale == nil then
scale = default_scale
end
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and scale ~= 1 then
resolved.converter = converter.divide_by_pair(scale)
end
resolved.scale = nil
return tuya.dp_numeric(dp, resolved)
end
local function build_power_numeric_preset(dp, default_name, default_scale, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, default_name)
local scale = resolved.scale
if scale == nil then
scale = default_scale
end
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil then
local power_converter = converter.power()
local from_device = power_converter.from
if scale ~= 1 then
resolved.from_device = converter.pipe(
from_device,
converter.divide_by(scale)
)
else
resolved.converter = power_converter
end
end
resolved.scale = nil
return tuya.dp_numeric(dp, resolved)
end
local function build_signed_numeric_preset(dp, default_name, default_scale, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, default_name)
local scale = resolved.scale
if scale == nil then
scale = default_scale
end
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil then
resolved.converter = converter.signed_number_pair(scale)
end
if resolved.signed == nil then
resolved.signed = true
end
resolved.scale = nil
return tuya.dp_numeric(dp, resolved)
end
local function build_raw_aware_numeric_preset(dp, default_name, default_scale, raw_defaults, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, default_name)
local scale = resolved.scale
if scale == nil then
scale = default_scale
end
local wants_raw =
resolved.datatype == tuya.DP_TYPE_RAW or
resolved.raw == true or
resolved.raw_bytes ~= nil or
resolved.raw_length ~= nil or
resolved.raw_from_tail ~= nil or
resolved.raw_start ~= nil or
resolved.raw_offset ~= nil
if wants_raw and resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil then
local raw_options = {
bytes = resolved.raw_bytes or resolved.raw_length,
length = resolved.raw_length,
from_tail = resolved.raw_from_tail,
start = resolved.raw_start,
offset = resolved.raw_offset,
}
apply_defaults(raw_options, raw_defaults)
resolved.converter = converter.raw_uint_be(scale, raw_options)
if resolved.datatype == nil then
resolved.datatype = tuya.DP_TYPE_RAW
end
elseif resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and scale ~= 1 then
resolved.converter = converter.divide_by_pair(scale)
end
resolved.scale = nil
resolved.raw = nil
resolved.raw_bytes = nil
resolved.raw_length = nil
resolved.raw_from_tail = nil
resolved.raw_start = nil
resolved.raw_offset = nil
return tuya.dp_numeric(dp, resolved)
end
local function invert_numeric_value(value, min_value, max_value)
local number_value = tonumber_check(value)
if number_value == nil then
return nil
end
return min_value + max_value - number_value
end
local function build_ranged_numeric_preset(dp, default_name, defaults, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, default_name)
local raw_min = resolved.raw_min
if raw_min == nil then
raw_min = defaults.raw_min
end
local raw_max = resolved.raw_max
if raw_max == nil then
raw_max = defaults.raw_max
end
local value_min = resolved.value_min
if value_min == nil then
value_min = defaults.value_min
end
local value_max = resolved.value_max
if value_max == nil then
value_max = defaults.value_max
end
local invert = resolved.invert == true or resolved.invert_position == true
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil then
if invert then
local from_scale = converter.scale(raw_min, raw_max, value_min, value_max)
local to_scale = converter.scale(value_min, value_max, raw_min, raw_max)
resolved.converter = converter.from_to(
function(value, device, context)
local scaled = from_scale(value, device, context)
if scaled == nil then
return nil
end
return invert_numeric_value(scaled, value_min, value_max)
end,
function(value, device, context)
local inverted = invert_numeric_value(value, value_min, value_max)
if inverted == nil then
return nil
end
return to_scale(inverted, device, context)
end
)
elseif raw_min ~= value_min or raw_max ~= value_max then
resolved.converter = converter.scale_pair(raw_min, raw_max, value_min, value_max)
end
end
resolved.raw_min = nil
resolved.raw_max = nil
resolved.value_min = nil
resolved.value_max = nil
resolved.invert = nil
resolved.invert_position = nil
return tuya.dp_numeric(dp, resolved)
end
local function phase_name(phase, fallback)
if type_check(phase) == "string" and phase ~= "" then
return (fallback or "phase") .. "_" .. phase
end
return fallback or "phase"
end
local function phase_fields(keys, phase)
local fields = {}
for _, key in ipairs(keys or {}) do
local field_name = key
if type_check(phase) == "string" and phase ~= "" then
field_name = key .. "_" .. phase
end
fields[field_name] = true
end
return fields
end
local function build_phase_raw_preset(dp, default_name, parser_builder, field_keys, name_or_options, options)
local explicit_name =
type_check(name_or_options) == "string" or
(type_check(name_or_options) == "table" and name_or_options.name ~= nil) or
(type_check(options) == "table" and options.name ~= nil)
local resolved = normalize_preset_options(name_or_options, options, default_name)
local phase = resolved.phase
if not explicit_name and resolved.name == default_name then
resolved.name = phase_name(phase, default_name)
end
if resolved.read_only == nil then
resolved.read_only = true
end
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil then
resolved.converter = parser_builder(resolved)
end
if resolved.field == nil and resolved.fields == nil then
resolved.fields = phase_fields(field_keys, phase)
end
return tuya.dp_raw(dp, resolved)
end
local function build_threshold_preset(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "threshold")
if resolved.read_only == nil then
resolved.read_only = true
end
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil then
resolved.converter = converter.threshold_parser()
end
if resolved.field == nil and resolved.fields == nil then
resolved.fields = {
threshold_1 = true,
threshold_1_protection = true,
threshold_1_value = true,
threshold_2 = true,
threshold_2_protection = true,
threshold_2_value = true,
}
end
return tuya.dp_raw(dp, resolved)
end
local function integer_dp_list(dp_list)
if type_check(dp_list) == "number" and dp_list % 1 == 0 and dp_list >= 0 then
return { dp_list }
end
if type_check(dp_list) ~= "table" then
return {}
end
local normalized = {}
for _, dp in ipairs(dp_list) do
if type_check(dp) == "number" and dp % 1 == 0 and dp >= 0 then
table_insert(normalized, dp)
end
end
return normalized
end
local function resolve_list_source(options)
if type_check(options) ~= "table" then
return options
end
local dp_list = options.dps
if dp_list == nil then
dp_list = options.dp_list
end
if dp_list == nil and options[1] ~= nil then
dp_list = options
end
return dp_list
end
local function resolve_list_or_dp_source(options)
local dp_list = resolve_list_source(options)
if dp_list ~= nil then
return dp_list
end
if type_check(options) ~= "table" then
return options
end
return options.dp
end
local function phase_for_index(index, options)
options = options or {}
local phases = options.phases
if type_check(phases) ~= "table" then
phases = options.phase_names
end
local phase = type_check(phases) == "table" and phases[index] or nil
if type_check(phase) == "string" and phase ~= "" then
return phase
end
local phase_prefix = options.phase_prefix
if phase_prefix == false then
return nil
end
if type_check(phase_prefix) ~= "string" or phase_prefix == "" then
phase_prefix = nil
end
if phase_prefix ~= nil then
return phase_prefix .. tostring(index)
end
return tostring(index)
end
local function component_name_for_index(index, options)
options = options or {}
local first_is_main = options.first_is_main ~= false
local component_prefix = options.component_prefix
if type_check(component_prefix) ~= "string" or component_prefix == "" then
component_prefix = "switch"
end
local main_component = options.main_component
if type_check(main_component) ~= "string" or main_component == "" then
main_component = "main"
end
local index_offset = options.index_offset
if type_check(index_offset) ~= "number" or index_offset % 1 ~= 0 then
index_offset = 0
end
if index == 1 and first_is_main then
return main_component
end
local suffix = first_is_main and (index - 1 + index_offset) or (index + index_offset)
if suffix < 1 then
return options.default_component
end
return component_prefix .. tostring(suffix)
end
local function key_name_for_index(index, options, default_prefix)
options = options or {}
local first_is_main = options.first_is_main ~= false
local key_prefix = options.key_prefix
if type_check(key_prefix) ~= "string" or key_prefix == "" then
key_prefix = default_prefix or "switch"
end
local main_key = options.main_key
if type_check(main_key) ~= "string" or main_key == "" then
main_key = key_prefix
end
local index_offset = options.index_offset
if type_check(index_offset) ~= "number" or index_offset % 1 ~= 0 then
index_offset = 0
end
if index == 1 and first_is_main then
return main_key
end
local suffix = first_is_main and (index - 1 + index_offset) or (index + index_offset)
if suffix < 1 then
return options.default_key
end
return key_prefix .. tostring(suffix)
end
local function append_preset(datapoints, dp, builder, options)
if type_check(dp) ~= "number" or dp % 1 ~= 0 or dp < 0 then
return
end
table_insert(datapoints, builder(dp, options))
end
local function append_preset_list(target, items)
if type_check(items) ~= "table" then
return target
end
for _, item in ipairs(items) do
table_insert(target, item)
end
return target
end
local gang_shared_option_keys = {
"first_is_main",
"main_component",
"component_prefix",
"index_offset",
"default_component",
"key_prefix",
"main_key",
"default_key",
}
local function is_positive_integer(value)
return type_check(value) == "number" and value % 1 == 0 and value > 0
end
local function copy_parent_group_options(options, keep_direct_source)
local resolved = {}
if type_check(options) ~= "table" then
return resolved
end
for key, value in pairs(options) do
local keep_key = true
if not keep_direct_source then
if key == "dp" or key == "dps" or key == "dp_list" then
keep_key = false
elseif is_positive_integer(key) then
keep_key = false
end
end
if keep_key then
resolved[key] = value
end
end
return resolved
end
local function has_direct_source_options(options)
if type_check(options) ~= "table" then
return false
end
if options.dp ~= nil or options.dps ~= nil or options.dp_list ~= nil or options[1] ~= nil then
return true
end
return false
end
local function clear_direct_source_options(options)
if type_check(options) ~= "table" then
return options
end
options.dp = nil
options.dps = nil
options.dp_list = nil
local index = 1
while options[index] ~= nil do
options[index] = nil
index = index + 1
end
return options
end
local function resolve_group_options(options, group_name, keep_direct_source)
if type_check(options) ~= "table" then
return {}
end
local grouped = options[group_name]
if grouped == nil then
return copy_parent_group_options(options, keep_direct_source)
end
local resolved = copy_parent_group_options(options, keep_direct_source)
if type_check(grouped) == "table" then
merge_options(resolved, grouped)
else
resolved.dp = grouped
end
return resolved
end
local function normalize_direct_group_options(grouped)
if grouped == nil then
return nil
end
if type_check(grouped) == "table" then
return grouped
end
return { dp = grouped }
end
local function direct_group_options(options, group_name)
if type_check(options) ~= "table" then
return nil
end
return normalize_direct_group_options(options[group_name])
end
local function resolve_item_options(parent_options, group_options)
local parent_item_options = type_check(parent_options) == "table" and parent_options.item_options or nil
local group_item_options = type_check(group_options) == "table" and group_options.item_options or nil
if type_check(parent_item_options) ~= "table" then
return type_check(group_item_options) == "table" and group_item_options or nil
end
if type_check(group_item_options) ~= "table" then
return parent_item_options
end
local resolved = {}
merge_options(resolved, parent_item_options)
merge_options(resolved, group_item_options)
return resolved
end
local function build_gang_group_options(options, group_name, default_key_prefix, keep_direct_source)
local resolved = {}
local grouped = nil
if type_check(options) == "table" then
copy_keys(resolved, options, gang_shared_option_keys)
grouped = options[group_name]
if type_check(grouped) == "table" then
merge_options(resolved, copy_parent_group_options(options, keep_direct_source))
if keep_direct_source and has_direct_source_options(grouped) then
clear_direct_source_options(resolved)
end
merge_options(resolved, grouped)
elseif grouped ~= nil then
merge_options(resolved, copy_parent_group_options(options, keep_direct_source))
if keep_direct_source then
clear_direct_source_options(resolved)
end
resolved.dp = grouped
else
merge_options(resolved, copy_parent_group_options(options, keep_direct_source))
end
end
if resolved.key_prefix == nil and default_key_prefix ~= nil then
resolved.key_prefix = default_key_prefix
end
resolved.item_options = resolve_item_options(options, grouped)
return resolved
end
local function build_switch_config_variant_options(options, variant_group_name)
local config_options = {}
local direct_config_options = direct_group_options(options, "config")
merge_options(config_options, direct_config_options)
local variant_group = normalize_direct_group_options(config_options[variant_group_name])
if variant_group ~= nil then
config_options[variant_group_name] = variant_group
else
local source_group = normalize_direct_group_options(config_options.switch_type)
if source_group == nil then
source_group = direct_group_options(options, "switch_type")
end
if type_check(source_group) == "table" then
config_options[variant_group_name] = source_group
end
end
if variant_group_name ~= "switch_type" then
config_options.switch_type = nil
end
if next(config_options) ~= nil then
return config_options
end
return {}
end
local function build_switch_module_variant_options(options, variant_group_name)
local resolved = {}
if type_check(options) == "table" then
merge_options(resolved, options)
end
local config_options = build_switch_config_variant_options(options, variant_group_name)
if next(config_options) ~= nil then
resolved.config = config_options
end
resolved.switch_type = nil
return resolved
end
local function build_plug_variant_options(options, variant_group_name)
local resolved = {}
if type_check(options) == "table" then
merge_options(resolved, options)
end
local switch_module_options = build_switch_module_variant_options(
resolve_group_options(options, "switch_module"),
variant_group_name
)
if next(switch_module_options) ~= nil then
resolved.switch_module = switch_module_options
end
return resolved
end
local function append_group_preset(datapoints, options, group_name, builder)
local group_options = resolve_group_options(options, group_name)
append_preset(datapoints, group_options.dp, builder, group_options)
end
local function append_group_preset_with_defaults(datapoints, options, group_name, builder, defaults)
local group_options = resolve_group_options(options, group_name)
apply_defaults(group_options, defaults)
append_preset(datapoints, group_options.dp, builder, group_options)
end
local function append_group_or_list_preset(datapoints, options, group_name, builder, list_builder)
local group_options = resolve_group_options(options, group_name)
local dp_list = resolve_list_source(group_options)
if dp_list ~= nil and list_builder ~= nil then
append_preset_list(datapoints, list_builder(dp_list, group_options))
return
end
append_preset(datapoints, group_options.dp, builder, group_options)
end
local function append_gang_group_preset_list(datapoints, options, group_name, default_key_prefix, builder)
local group_options = build_gang_group_options(options, group_name, default_key_prefix)
append_preset_list(datapoints, builder(resolve_list_or_dp_source(group_options), group_options))
end
local function build_gang_datapoints(dp_list, builder, default_name, options)
local datapoints = {}
local resolved_dps = integer_dp_list(dp_list)
local item_options = type_check(options) == "table" and options.item_options or nil
for index, dp in ipairs(resolved_dps) do
local resolved = normalize_preset_options(item_options, nil, default_name)
if resolved.component == nil then
resolved.component = component_name_for_index(index, options)
end
if resolved.key == nil and resolved.preference == nil then
resolved.key = key_name_for_index(index, options, default_name)
end
if resolved.field == nil and resolved.fields == nil and resolved.key ~= nil then
resolved.field = resolved.key
end
table_insert(datapoints, builder(dp, resolved))
end
return datapoints
end
local function build_phase_meter_datapoints(dp_list, builder, options)
local datapoints = {}
local resolved_dps = integer_dp_list(dp_list)
local item_options = type_check(options) == "table" and options.item_options or nil
for index, dp in ipairs(resolved_dps) do
local resolved = normalize_preset_options(item_options, nil, nil)
if resolved.phase == nil then
resolved.phase = phase_for_index(index, options)
end
table_insert(datapoints, builder(dp, resolved))
end
return datapoints
end
local function build_single_group_datapoints(options, group_name, builder)
local group_options = nil
if type_check(options) == "table" then
group_options = resolve_group_options(options, group_name, true)
else
group_options = { dp = options }
end
local datapoints = {}
append_preset(datapoints, group_options.dp, builder, group_options)
return datapoints
end
function tuya.dp_on_off(dp, name_or_options, options)
return tuya.dp_binary(dp, normalize_preset_options(name_or_options, options, "switch"))
end
function tuya.dp_temperature(dp, name_or_options, options)
return build_scaled_numeric_preset(dp, "temperature", name_or_options, options)
end
function tuya.dp_humidity(dp, name_or_options, options)
return build_scaled_numeric_preset(dp, "humidity", name_or_options, options)
end
function tuya.dp_battery(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "battery", 1, name_or_options, options)
end
function tuya.dp_contact(dp, name_or_options, options)
return tuya.dp_binary(dp, normalize_preset_options(name_or_options, options, "contact"))
end
function tuya.dp_occupancy(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "occupancy")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.true_false0()
end
return tuya.dp_binary(dp, resolved)
end
function tuya.dp_child_lock(dp, name_or_options, options)
return tuya.dp_binary(dp, normalize_preset_options(name_or_options, options, "child_lock"))
end
function tuya.dp_illuminance(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "illuminance")
return tuya.dp_numeric(dp, resolved)
end
function tuya.dp_brightness(dp, name_or_options, options)
return tuya.dp_light(dp, normalize_preset_options(name_or_options, options, "brightness"))
end
function tuya.dp_voltage(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "voltage", 10, name_or_options, options)
end
function tuya.dp_current(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "current", 1000, name_or_options, options)
end
function tuya.dp_power(dp, name_or_options, options)
return build_power_numeric_preset(dp, "power", 10, name_or_options, options)
end
function tuya.dp_energy(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "energy", 100, name_or_options, options)
end
function tuya.dp_ac_frequency(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "ac_frequency", 100, name_or_options, options)
end
function tuya.dp_phase_variant1(dp, name_or_options, options)
return build_phase_raw_preset(
dp,
"phase",
function(resolved)
return converter.phase_variant1_parser(resolved.phase)
end,
{ "voltage", "current" },
name_or_options,
options
)
end
function tuya.dp_phase_variant2(dp, name_or_options, options)
return build_phase_raw_preset(
dp,
"phase",
function(resolved)
return converter.phase_variant2_parser(resolved.phase, resolved.signed_power)
end,
{ "voltage", "current", "power" },
name_or_options,
options
)
end
function tuya.dp_phase_variant3(dp, name_or_options, options)
return build_phase_raw_preset(
dp,
"phase",
function(resolved)
return converter.phase_variant3_parser(resolved.phase)
end,
{ "voltage", "current", "power" },
name_or_options,
options
)
end
function tuya.dp_threshold(dp, name_or_options, options)
return build_threshold_preset(dp, name_or_options, options)
end
function tuya.dp_action(dp, name_or_options, options)
return tuya.dp_enum(dp, normalize_preset_options(name_or_options, options, "action"))
end
function tuya.dp_battery_state(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "battery_state")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.battery_state()
end
return tuya.dp_enum(dp, resolved)
end
function tuya.dp_battery_state_low_medium_high(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "battery_state")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.battery_state_low_medium_high()
end
return tuya.dp_enum(dp, resolved)
end
function tuya.dp_temperature_unit(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "temperature_unit")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.temperature_unit()
end
return tuya.dp_enum(dp, resolved)
end
function tuya.dp_power_on_behavior(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "power_on_behavior")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.power_on_behavior()
end
return apply_default_fixed_send_policy(tuya.dp_enum(dp, resolved), resolved)
end
function tuya.dp_power_outage_memory(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "power_outage_memory")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.power_outage_memory()
end
return apply_default_fixed_send_policy(tuya.dp_enum(dp, resolved), resolved)
end
function tuya.dp_switch_type(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "switch_type")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.switch_type()
end
return apply_default_fixed_send_policy(tuya.dp_enum(dp, resolved), resolved)
end
function tuya.dp_switch_type_curtain(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "switch_type_curtain")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.switch_type_curtain()
end
return apply_default_fixed_send_policy(tuya.dp_enum(dp, resolved), resolved)
end
function tuya.dp_switch_type_button(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "switch_type_button")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.switch_type_button()
end
return apply_default_fixed_send_policy(tuya.dp_enum(dp, resolved), resolved)
end
function tuya.dp_switch_mode(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "switch_mode")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.switch_mode()
end
return apply_default_fixed_send_policy(tuya.dp_enum(dp, resolved), resolved)
end
function tuya.dp_backlight_mode(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "backlight_mode")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.backlight_mode_off_normal_inverted()
end
return apply_default_fixed_send_policy(tuya.dp_enum(dp, resolved), resolved)
end
function tuya.dp_backlight_mode_low_medium_high(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "backlight_mode")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.backlight_mode_low_medium_high()
end
return apply_default_fixed_send_policy(tuya.dp_enum(dp, resolved), resolved)
end
function tuya.dp_backlight_mode_off_on(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "backlight_mode")
return apply_default_fixed_send_policy(tuya.dp_binary(dp, resolved), resolved)
end
function tuya.dp_indicator_mode(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "indicator_mode")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.indicator_mode()
end
return apply_default_fixed_send_policy(tuya.dp_enum(dp, resolved), resolved)
end
function tuya.dp_indicator_mode_none_relay_pos(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "indicator_mode")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.indicator_mode_none_relay_pos()
end
return apply_default_fixed_send_policy(tuya.dp_enum(dp, resolved), resolved)
end
function tuya.dp_color_temperature(dp, name_or_options, options)
return build_ranged_numeric_preset(
dp,
"color_temperature",
{ raw_min = 0, raw_max = 1000, value_min = 0, value_max = 100 },
name_or_options,
options
)
end
function tuya.dp_color_hue(dp, name_or_options, options)
return build_ranged_numeric_preset(
dp,
"color_hue",
{ raw_min = 0, raw_max = 360, value_min = 0, value_max = 360 },
name_or_options,
options
)
end
function tuya.dp_color_saturation(dp, name_or_options, options)
return build_ranged_numeric_preset(
dp,
"color_saturation",
{ raw_min = 0, raw_max = 1000, value_min = 0, value_max = 100 },
name_or_options,
options
)
end
function tuya.dp_color_data(dp, name_or_options, options)
return tuya.dp_string(dp, normalize_preset_options(name_or_options, options, "color_data"))
end
function tuya.dp_cover_position(dp, name_or_options, options)
return build_ranged_numeric_preset(
dp,
"cover_position",
{ raw_min = 0, raw_max = 100, value_min = 0, value_max = 100 },
name_or_options,
options
)
end
function tuya.dp_cover_position_inverted(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "cover_position")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil then
resolved.converter = converter.cover_position_inverted()
end
return tuya.dp_numeric(dp, resolved)
end
function tuya.dp_do_not_disturb(dp, name_or_options, options)
return tuya.dp_binary(dp, normalize_preset_options(name_or_options, options, "do_not_disturb"))
end
function tuya.dp_inching_switch(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "inching_switch")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil then
resolved.converter = converter.inching_switch()
end
return tuya.dp_raw(dp, resolved)
end
function tuya.dp_local_temperature(dp, name_or_options, options)
return build_scaled_numeric_preset(dp, "local_temperature", name_or_options, options)
end
function tuya.dp_current_heating_setpoint(dp, name_or_options, options)
return build_scaled_numeric_preset(dp, "current_heating_setpoint", name_or_options, options)
end
function tuya.dp_occupied_heating_setpoint(dp, name_or_options, options)
return build_scaled_numeric_preset(dp, "occupied_heating_setpoint", name_or_options, options)
end
function tuya.dp_occupied_cooling_setpoint(dp, name_or_options, options)
return build_scaled_numeric_preset(dp, "occupied_cooling_setpoint", name_or_options, options)
end
function tuya.dp_local_temperature_calibration(dp, name_or_options, options)
return build_signed_numeric_preset(dp, "local_temperature_calibration", 10, name_or_options, options)
end
function tuya.dp_open_window_temperature(dp, name_or_options, options)
return build_scaled_numeric_preset(dp, "open_window_temperature", name_or_options, options)
end
function tuya.dp_comfort_temperature(dp, name_or_options, options)
return build_scaled_numeric_preset(dp, "comfort_temperature", name_or_options, options)
end
function tuya.dp_eco_temperature(dp, name_or_options, options)
return build_scaled_numeric_preset(dp, "eco_temperature", name_or_options, options)
end
function tuya.dp_holiday_temperature(dp, name_or_options, options)
return build_scaled_numeric_preset(dp, "holiday_temperature", name_or_options, options)
end
function tuya.dp_max_temperature_limit(dp, name_or_options, options)
return build_scaled_numeric_preset(dp, "max_temperature_limit", name_or_options, options)
end
function tuya.dp_min_temperature_limit(dp, name_or_options, options)
return build_scaled_numeric_preset(dp, "min_temperature_limit", name_or_options, options)
end
function tuya.dp_deadzone_temperature(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "deadzone_temperature", 1, name_or_options, options)
end
function tuya.dp_inlet_water_temperature(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "inlet_water_temperature", 100, name_or_options, options)
end
function tuya.dp_outlet_water_temperature(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "outlet_water_temperature", 100, name_or_options, options)
end
function tuya.dp_open_window_time(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "open_window_time", 1, name_or_options, options)
end
function tuya.dp_system_mode(dp, name_or_options, options)
return tuya.dp_enum(dp, normalize_preset_options(name_or_options, options, "system_mode"))
end
function tuya.dp_running_state(dp, name_or_options, options)
return tuya.dp_enum(dp, normalize_preset_options(name_or_options, options, "running_state"))
end
function tuya.dp_fan_mode(dp, name_or_options, options)
return tuya.dp_enum(dp, normalize_preset_options(name_or_options, options, "fan_mode"))
end
function tuya.dp_fan_speed(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "fan_speed", 1, name_or_options, options)
end
function tuya.dp_frost_protection(dp, name_or_options, options)
return tuya.dp_binary(dp, normalize_preset_options(name_or_options, options, "frost_protection"))
end
function tuya.dp_window_detection(dp, name_or_options, options)
return tuya.dp_binary(dp, normalize_preset_options(name_or_options, options, "window_detection"))
end
function tuya.dp_open_window(dp, name_or_options, options)
return tuya.dp_binary(dp, normalize_preset_options(name_or_options, options, "open_window"))
end
function tuya.dp_window_open(dp, name_or_options, options)
return tuya.dp_binary(dp, normalize_preset_options(name_or_options, options, "window_open"))
end
function tuya.dp_boost_heating(dp, name_or_options, options)
return tuya.dp_binary(dp, normalize_preset_options(name_or_options, options, "boost_heating"))
end
function tuya.dp_scale_protection(dp, name_or_options, options)
return tuya.dp_binary(dp, normalize_preset_options(name_or_options, options, "scale_protection"))
end
function tuya.dp_eco_mode(dp, name_or_options, options)
return tuya.dp_binary(dp, normalize_preset_options(name_or_options, options, "eco_mode"))
end
function tuya.dp_valve_state(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "valve_state")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.valve_state_closed_open()
end
return tuya.dp_enum(dp, resolved)
end
function tuya.dp_valve_state_unknown_open_closed(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "valve_state")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.valve_state_unknown_open_closed()
end
return tuya.dp_enum(dp, resolved)
end
function tuya.dp_temperature_sensor_select(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "temperature_sensor_select")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.temperature_sensor_select_in_al_ou()
end
return apply_default_fixed_send_policy(tuya.dp_enum(dp, resolved), resolved)
end
function tuya.dp_temperature_sensor_select_internal_external_both(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "temperature_sensor_select")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.temperature_sensor_select_internal_external_both()
end
return apply_default_fixed_send_policy(tuya.dp_enum(dp, resolved), resolved)
end
function tuya.dp_countdown(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "countdown", 1, name_or_options, options)
end
function tuya.dp_boost_time(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "boost_time", 1, name_or_options, options)
end
function tuya.dp_boost_timeset_countdown(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "boost_timeset_countdown", 1, name_or_options, options)
end
function tuya.dp_temperature_calibration(dp, name_or_options, options)
return build_signed_numeric_preset(dp, "temperature_calibration", 10, name_or_options, options)
end
function tuya.dp_humidity_calibration(dp, name_or_options, options)
return build_signed_numeric_preset(dp, "humidity_calibration", 1, name_or_options, options)
end
function tuya.dp_max_temperature_alarm(dp, name_or_options, options)
return build_scaled_numeric_preset(dp, "max_temperature_alarm", name_or_options, options)
end
function tuya.dp_min_temperature_alarm(dp, name_or_options, options)
return build_scaled_numeric_preset(dp, "min_temperature_alarm", name_or_options, options)
end
function tuya.dp_max_humidity_alarm(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "max_humidity_alarm", 1, name_or_options, options)
end
function tuya.dp_min_humidity_alarm(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "min_humidity_alarm", 1, name_or_options, options)
end
function tuya.dp_temperature_alarm(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "temperature_alarm")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.alarm_state_lower_upper_cancel()
end
return tuya.dp_enum(dp, resolved)
end
function tuya.dp_humidity_alarm(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "humidity_alarm")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.alarm_state_lower_upper_cancel()
end
return tuya.dp_enum(dp, resolved)
end
function tuya.dp_soil_moisture(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "soil_moisture", 1, name_or_options, options)
end
function tuya.dp_soil_calibration(dp, name_or_options, options)
return build_signed_numeric_preset(dp, "soil_calibration", 1, name_or_options, options)
end
function tuya.dp_temperature_sampling(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "temperature_sampling", 1, name_or_options, options)
end
function tuya.dp_report_interval(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "report_interval", 1, name_or_options, options)
end
function tuya.dp_soil_sampling(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "soil_sampling", 1, name_or_options, options)
end
function tuya.dp_soil_warning(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "soil_warning", 1, name_or_options, options)
end
function tuya.dp_illuminance_calibration(dp, name_or_options, options)
return build_signed_numeric_preset(dp, "illuminance_calibration", 1, name_or_options, options)
end
function tuya.dp_water_warning(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "water_warning")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.water_warning()
end
return tuya.dp_enum(dp, resolved)
end
function tuya.dp_soil_fertility(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "soil_fertility", 1, name_or_options, options)
end
function tuya.dp_soil_fertility_calibration(dp, name_or_options, options)
return build_signed_numeric_preset(dp, "soil_fertility_calibration", 1, name_or_options, options)
end
function tuya.dp_soil_fertility_warning_setting(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "soil_fertility_warning_setting", 1, name_or_options, options)
end
function tuya.dp_soil_fertility_warning(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "soil_fertility_warning")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.soil_fertility_warning()
end
return tuya.dp_enum(dp, resolved)
end
function tuya.dp_water_consumed(dp, name_or_options, options)
return build_raw_aware_numeric_preset(
dp,
"water_consumed",
1000,
{ bytes = 4, from_tail = true },
name_or_options,
options
)
end
function tuya.dp_reverse_water_consumed(dp, name_or_options, options)
return build_raw_aware_numeric_preset(
dp,
"reverse_water_consumed",
1000,
{ bytes = 4 },
name_or_options,
options
)
end
function tuya.dp_month_consumption(dp, name_or_options, options)
return build_raw_aware_numeric_preset(
dp,
"month_consumption",
1000,
{ bytes = 4, from_tail = true },
name_or_options,
options
)
end
function tuya.dp_daily_consumption(dp, name_or_options, options)
return build_raw_aware_numeric_preset(
dp,
"daily_consumption",
1000,
{ bytes = 4, from_tail = true },
name_or_options,
options
)
end
function tuya.dp_flow_rate(dp, name_or_options, options)
return build_raw_aware_numeric_preset(
dp,
"flow_rate",
1000,
{ bytes = 4 },
name_or_options,
options
)
end
function tuya.dp_instantaneous_flow_rate(dp, name_or_options, options)
return build_raw_aware_numeric_preset(
dp,
"instantaneous_flow_rate",
1000,
{ bytes = 4 },
name_or_options,
options
)
end
function tuya.dp_cumulative_heat(dp, name_or_options, options)
return build_raw_aware_numeric_preset(
dp,
"cumulative_heat",
100,
{ bytes = 4 },
name_or_options,
options
)
end
function tuya.dp_battery_voltage(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "battery_voltage", 100, name_or_options, options)
end
function tuya.dp_meter_id(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "meter_id")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil then
resolved.converter = converter.raw_identifier()
end
return tuya.dp_raw(dp, resolved)
end
function tuya.dp_water_meter_faults(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "faults")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil then
resolved.converter = converter.water_meter_faults()
end
return tuya.dp_numeric(dp, resolved)
end
function tuya.dp_water_meter_report_period(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "report_period")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.report_period_hours()
end
return apply_default_fixed_send_policy(tuya.dp_enum(dp, resolved), resolved)
end
function tuya.dp_gas(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "gas")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.true_false0()
end
return tuya.dp_binary(dp, resolved)
end
function tuya.dp_gas_value(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "gas_value", 1, name_or_options, options)
end
function tuya.dp_smoke(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "smoke")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.true_false0()
end
return tuya.dp_binary(dp, resolved)
end
function tuya.dp_smoke_concentration(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "smoke_concentration", 10, name_or_options, options)
end
function tuya.dp_self_test_result(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "self_test_result")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.self_test_result()
end
return tuya.dp_enum(dp, resolved)
end
function tuya.dp_self_test_state(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "self_test")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.self_test_state()
end
return tuya.dp_enum(dp, resolved)
end
function tuya.dp_fault_alarm(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "fault_alarm")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.true_false1()
end
return tuya.dp_binary(dp, resolved)
end
function tuya.dp_silence(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "silence")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.true_false1()
end
return apply_default_fixed_send_policy(tuya.dp_binary(dp, resolved), resolved)
end
function tuya.dp_alarm_time(dp, name_or_options, options)
return apply_default_fixed_send_policy(
build_divided_numeric_preset(dp, "alarm_time", 1, name_or_options, options),
normalize_preset_options(name_or_options, options, "alarm_time")
)
end
function tuya.dp_alarm_volume(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "alarm_volume")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.alarm_volume()
end
return apply_default_fixed_send_policy(tuya.dp_enum(dp, resolved), resolved)
end
function tuya.dp_alarm_ringtone(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "alarm_ringtone")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.alarm_ringtone_melody_five()
end
return apply_default_fixed_send_policy(tuya.dp_enum(dp, resolved), resolved)
end
function tuya.dp_preheat(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "preheat")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.true_false1()
end
return tuya.dp_binary(dp, resolved)
end
function tuya.dp_alarm_switch(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "alarm_switch")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.true_false1()
end
return apply_default_fixed_send_policy(tuya.dp_binary(dp, resolved), resolved)
end
function tuya.dp_device_fault(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "device_fault")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.true_false1()
end
return tuya.dp_binary(dp, resolved)
end
function tuya.dp_gas_fault_status(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "fault")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.gas_fault_status()
end
return tuya.dp_enum(dp, resolved)
end
function tuya.dp_tamper(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "tamper")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.true_false1()
end
return tuya.dp_binary(dp, resolved)
end
function tuya.dp_battery_low(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "battery_low")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.true_false0()
end
return tuya.dp_binary(dp, resolved)
end
function tuya.dp_pir_sensitivity(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "sensitivity")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.pir_sensitivity_low_medium_high()
end
return apply_default_fixed_send_policy(tuya.dp_enum(dp, resolved), resolved)
end
function tuya.dp_hold_time(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "hold_time")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.pir_keep_time_ten_thirty_sixty_one_twenty()
end
return apply_default_fixed_send_policy(tuya.dp_enum(dp, resolved), resolved)
end
function tuya.dp_keep_time(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "keep_time")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.pir_keep_time_ten_thirty_sixty_one_twenty()
end
return apply_default_fixed_send_policy(tuya.dp_enum(dp, resolved), resolved)
end
function tuya.dp_alarm(dp, name_or_options, options)
return tuya.dp_binary(dp, normalize_preset_options(name_or_options, options, "alarm"))
end
function tuya.dp_lock(dp, name_or_options, options)
return tuya.dp_binary(dp, normalize_preset_options(name_or_options, options, "lock"))
end
function tuya.dp_presence(dp, name_or_options, options)
return tuya.dp_binary(dp, normalize_preset_options(name_or_options, options, "presence"))
end
function tuya.dp_motion_state(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "motion_state")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.motion_state()
end
return tuya.dp_enum(dp, resolved)
end
function tuya.dp_indicator(dp, name_or_options, options)
return tuya.dp_binary(dp, normalize_preset_options(name_or_options, options, "indicator"))
end
function tuya.dp_fading_time(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "fading_time", 1, name_or_options, options)
end
function tuya.dp_illuminance_interval(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "illuminance_interval", 1, name_or_options, options)
end
function tuya.dp_static_detection_distance(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "static_detection_distance", 100, name_or_options, options)
end
function tuya.dp_static_detection_sensitivity(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "static_detection_sensitivity", 1, name_or_options, options)
end
function tuya.dp_motion_detection_mode(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "motion_detection_mode")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.motion_detection_mode()
end
return tuya.dp_enum(dp, resolved)
end
function tuya.dp_motion_detection_sensitivity(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "motion_detection_sensitivity", 1, name_or_options, options)
end
function tuya.dp_target_distance(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "target_distance", 100, name_or_options, options)
end
function tuya.dp_carbon_monoxide(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "carbon_monoxide")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.true_false0()
end
return tuya.dp_binary(dp, resolved)
end
function tuya.dp_co(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "co", 1, name_or_options, options)
end
function tuya.dp_co2(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "co2", 1, name_or_options, options)
end
function tuya.dp_voc(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "voc", 1, name_or_options, options)
end
function tuya.dp_pm25(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "pm25", 1, name_or_options, options)
end
function tuya.dp_formaldehyde(dp, name_or_options, options)
return build_divided_numeric_preset(dp, "formaldehyde", 1, name_or_options, options)
end
function tuya.dp_light_type(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "light_type")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.light_type()
end
return apply_default_fixed_send_policy(tuya.dp_enum(dp, resolved), resolved)
end
function tuya.dp_light_mode(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "light_mode")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.light_mode()
end
return apply_default_fixed_send_policy(tuya.dp_enum(dp, resolved), resolved)
end
function tuya.dp_motor_direction(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "motor_direction")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.motor_direction()
end
return apply_default_fixed_send_policy(tuya.dp_enum(dp, resolved), resolved)
end
function tuya.dp_error_status(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "error_status")
if resolved.read_only == nil then
resolved.read_only = true
end
return tuya.dp_numeric(dp, resolved)
end
function tuya.dp_water_leak(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "water_leak")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.true_false0()
end
return tuya.dp_binary(dp, resolved)
end
function tuya.dp_switch_mode_curtain(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "switch_mode")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.switch_mode_curtain()
end
return apply_default_fixed_send_policy(tuya.dp_enum(dp, resolved), resolved)
end
function tuya.dp_color_power_on_behavior(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "color_power_on_behavior")
if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
resolved.converter = converter.color_power_on_behavior()
end
return apply_default_fixed_send_policy(tuya.dp_enum(dp, resolved), resolved)
end
function tuya.dp_power_factor(dp, name_or_options, options)
local resolved = normalize_preset_options(name_or_options, options, "power_factor")
if resolved.read_only == nil then
resolved.read_only = true
end
return build_divided_numeric_preset(dp, "power_factor", 1, resolved)
end
function tuya.dp_min_brightness(dp, name_or_options, options)
return build_ranged_numeric_preset(
dp,
"min_brightness",
{ raw_min = 0, raw_max = 1000, value_min = 0, value_max = 100 },
name_or_options,
options
)
end
function tuya.dp_max_brightness(dp, name_or_options, options)
return build_ranged_numeric_preset(
dp,
"max_brightness",
{ raw_min = 0, raw_max = 1000, value_min = 0, value_max = 100 },
name_or_options,
options
)
end
local single_group_presets = {
{ "switch", "switch", "on_off" },
"temperature",
"humidity",
"battery",
"battery_state",
{ "battery_state_low_medium_high", "battery_state" },
"contact",
"occupancy",
"illuminance",
"temperature_unit",
"child_lock",
"power_on_behavior",
"power_outage_memory",
"switch_type",
"switch_type_button",
"switch_type_curtain",
"switch_mode",
"backlight_mode",
"backlight_mode_low_medium_high",
"backlight_mode_off_on",
"indicator_mode",
"indicator_mode_none_relay_pos",
"brightness",
"action",
"countdown",
"voltage",
"current",
"power",
"energy",
"ac_frequency",
"phase_variant1",
"phase_variant2",
"phase_variant3",
"threshold",
"color_temperature",
"color_hue",
"color_saturation",
"color_data",
"cover_position",
"local_temperature",
"current_heating_setpoint",
"occupied_heating_setpoint",
"occupied_cooling_setpoint",
"local_temperature_calibration",
"open_window_temperature",
"comfort_temperature",
"eco_temperature",
"holiday_temperature",
"max_temperature_limit",
"min_temperature_limit",
"deadzone_temperature",
"inlet_water_temperature",
"outlet_water_temperature",
"open_window_time",
"system_mode",
"running_state",
"fan_mode",
"fan_speed",
"frost_protection",
"window_detection",
"open_window",
"window_open",
"boost_heating",
"scale_protection",
"eco_mode",
"valve_state",
{ "valve_state_unknown_open_closed", "valve_state" },
"temperature_sensor_select",
{ "temperature_sensor_select_internal_external_both", "temperature_sensor_select" },
"temperature_calibration",
"humidity_calibration",
"max_temperature_alarm",
"min_temperature_alarm",
"max_humidity_alarm",
"min_humidity_alarm",
"temperature_alarm",
"humidity_alarm",
"soil_moisture",
"soil_calibration",
"temperature_sampling",
"report_interval",
"soil_sampling",
"soil_warning",
"illuminance_calibration",
"water_warning",
"soil_fertility",
"soil_fertility_calibration",
"soil_fertility_warning_setting",
"soil_fertility_warning",
"water_consumed",
"reverse_water_consumed",
"month_consumption",
"daily_consumption",
"flow_rate",
"instantaneous_flow_rate",
"cumulative_heat",
"battery_voltage",
"meter_id",
{ "water_meter_faults", "faults" },
{ "water_meter_report_period", "report_period" },
"gas",
"gas_value",
"smoke",
"smoke_concentration",
"self_test_result",
{ "self_test_state", "self_test" },
"fault_alarm",
"silence",
"alarm_time",
"alarm_volume",
"alarm_ringtone",
"preheat",
"alarm_switch",
"device_fault",
"gas_fault_status",
"tamper",
"battery_low",
{ "pir_sensitivity", "sensitivity" },
"hold_time",
"keep_time",
"alarm",
"presence",
"motion_state",
"indicator",
"fading_time",
"illuminance_interval",
"static_detection_distance",
"static_detection_sensitivity",
"motion_detection_mode",
"motion_detection_sensitivity",
"target_distance",
"carbon_monoxide",
"co",
"co2",
"voc",
"pm25",
"formaldehyde",
"boost_time",
"boost_timeset_countdown",
"light_type",
"light_mode",
"motor_direction",
"error_status",
"water_leak",
{ "switch_mode_curtain", "switch_mode" },
"color_power_on_behavior",
"power_factor",
"min_brightness",
"max_brightness",
}
for _, entry in ipairs(single_group_presets) do
local suffix, group, dp_suffix
if type_check(entry) == "string" then
suffix, group, dp_suffix = entry, entry, entry
else
suffix = entry[1]
group = entry[2] or suffix
dp_suffix = entry[3] or suffix
end
tuya["build_" .. suffix .. "_datapoints"] = function(options)
return build_single_group_datapoints(options, group, tuya["dp_" .. dp_suffix])
end
end
local sensor_group_builders = {
temperature = "dp_temperature",
humidity = "dp_humidity",
battery = "dp_battery",
battery_state = "dp_battery_state",
contact = "dp_contact",
illuminance = "dp_illuminance",
temperature_unit = "dp_temperature_unit",
temperature_calibration = "dp_temperature_calibration",
humidity_calibration = "dp_humidity_calibration",
max_temperature_alarm = "dp_max_temperature_alarm",
min_temperature_alarm = "dp_min_temperature_alarm",
max_humidity_alarm = "dp_max_humidity_alarm",
min_humidity_alarm = "dp_min_humidity_alarm",
temperature_alarm = "dp_temperature_alarm",
humidity_alarm = "dp_humidity_alarm",
soil_moisture = "dp_soil_moisture",
soil_calibration = "dp_soil_calibration",
temperature_sampling = "dp_temperature_sampling",
report_interval = "dp_report_interval",
soil_sampling = "dp_soil_sampling",
soil_warning = "dp_soil_warning",
illuminance_calibration = "dp_illuminance_calibration",
water_warning = "dp_water_warning",
soil_fertility = "dp_soil_fertility",
soil_fertility_calibration = "dp_soil_fertility_calibration",
soil_fertility_warning_setting = "dp_soil_fertility_warning_setting",
soil_fertility_warning = "dp_soil_fertility_warning",
}
local function build_sensor_group_datapoints(options, group_names)
options = options or {}
local datapoints = {}
for _, group_name in ipairs(group_names or {}) do
local dp_fn_name = sensor_group_builders[group_name]
if dp_fn_name ~= nil then
append_group_preset(datapoints, options, group_name, tuya[dp_fn_name])
end
end
return datapoints
end
function tuya.build_sensor_datapoints(options)
return build_sensor_group_datapoints(options, {
"temperature",
"humidity",
"battery",
"battery_state",
"contact",
"illuminance",
"temperature_unit",
"temperature_calibration",
"humidity_calibration",
})
end
function tuya.build_temperature_sensor_datapoints(options)
return build_sensor_group_datapoints(options, {
"temperature",
"battery",
"battery_state",
"temperature_unit",
"temperature_calibration",
})
end
function tuya.build_temperature_humidity_sensor_datapoints(options)
return build_sensor_group_datapoints(options, {
"temperature",
"humidity",
"battery",
"battery_state",
"temperature_unit",
"temperature_calibration",
"humidity_calibration",
"max_temperature_alarm",
"min_temperature_alarm",
"max_humidity_alarm",
"min_humidity_alarm",
"temperature_alarm",
"humidity_alarm",
})
end
function tuya.build_illuminance_sensor_datapoints(options)
return build_sensor_group_datapoints(options, {
"illuminance",
"battery",
"battery_state",
})
end
function tuya.build_contact_sensor_datapoints(options)
return build_sensor_group_datapoints(options, {
"contact",
"battery",
"battery_state",
})
end
function tuya.build_occupancy_sensor_datapoints(options)
options = options or {}
local datapoints = {}
append_group_preset(datapoints, options, "occupancy", tuya.dp_occupancy)
append_group_preset(datapoints, options, "illuminance", tuya.dp_illuminance)
append_group_preset(datapoints, options, "battery", tuya.dp_battery)
append_group_preset(datapoints, options, "battery_low", tuya.dp_battery_low)
append_group_preset(datapoints, options, "battery_state", tuya.dp_battery_state)
append_group_preset(datapoints, options, "tamper", tuya.dp_tamper)
append_group_preset(datapoints, options, "sensitivity", tuya.dp_pir_sensitivity)
append_group_preset(datapoints, options, "hold_time", tuya.dp_hold_time)
append_group_preset(datapoints, options, "keep_time", tuya.dp_keep_time)
return datapoints
end
function tuya.build_environment_sensor_datapoints(options)
return build_sensor_group_datapoints(options, {
"temperature",
"humidity",
"illuminance",
"battery",
"battery_state",
"temperature_unit",
"temperature_calibration",
"humidity_calibration",
"max_temperature_alarm",
"min_temperature_alarm",
"max_humidity_alarm",
"min_humidity_alarm",
"temperature_alarm",
"humidity_alarm",
})
end
function tuya.build_soil_sensor_datapoints(options)
return build_sensor_group_datapoints(options, {
"temperature",
"humidity",
"illuminance",
"illuminance_calibration",
"soil_moisture",
"temperature_unit",
"battery",
"battery_state",
"temperature_calibration",
"humidity_calibration",
"soil_calibration",
"temperature_sampling",
"report_interval",
"soil_sampling",
"soil_warning",
"water_warning",
"max_temperature_alarm",
"min_temperature_alarm",
"max_humidity_alarm",
"min_humidity_alarm",
"temperature_alarm",
"humidity_alarm",
})
end
function tuya.build_soil_fertility_sensor_datapoints(options)
return build_sensor_group_datapoints(options, {
"temperature",
"humidity",
"illuminance",
"illuminance_calibration",
"soil_moisture",
"soil_fertility",
"temperature_unit",
"battery",
"battery_state",
"temperature_calibration",
"humidity_calibration",
"soil_calibration",
"temperature_sampling",
"report_interval",
"soil_sampling",
"soil_warning",
"water_warning",
"soil_fertility_calibration",
"soil_fertility_warning_setting",
"soil_fertility_warning",
"max_temperature_alarm",
"min_temperature_alarm",
"max_humidity_alarm",
"min_humidity_alarm",
"temperature_alarm",
"humidity_alarm",
})
end
function tuya.build_gas_sensor_datapoints(options)
options = options or {}
local datapoints = {}
append_group_preset(datapoints, options, "gas", tuya.dp_gas)
append_group_preset(datapoints, options, "gas_value", tuya.dp_gas_value)
append_group_preset(datapoints, options, "battery", tuya.dp_battery)
append_group_preset(datapoints, options, "battery_state", tuya.dp_battery_state_low_medium_high)
append_group_preset(datapoints, options, "self_test_result", tuya.dp_self_test_result)
append_group_preset(datapoints, options, "gas_fault_status", tuya.dp_gas_fault_status)
append_group_preset(datapoints, options, "fault_alarm", tuya.dp_fault_alarm)
append_group_preset(datapoints, options, "silence", tuya.dp_silence)
append_group_preset(datapoints, options, "alarm_ringtone", tuya.dp_alarm_ringtone)
append_group_preset(datapoints, options, "alarm_time", tuya.dp_alarm_time)
append_group_preset(datapoints, options, "preheat", tuya.dp_preheat)
append_group_preset(datapoints, options, "alarm_switch", tuya.dp_alarm_switch)
return datapoints
end
function tuya.build_smoke_sensor_datapoints(options)
options = options or {}
local datapoints = {}
append_group_preset(datapoints, options, "smoke", tuya.dp_smoke)
append_group_preset(datapoints, options, "tamper", tuya.dp_tamper)
append_group_preset(datapoints, options, "battery_low", tuya.dp_battery_low)
append_group_preset(datapoints, options, "smoke_concentration", tuya.dp_smoke_concentration)
append_group_preset(datapoints, options, "battery", tuya.dp_battery)
append_group_preset(datapoints, options, "battery_state", tuya.dp_battery_state_low_medium_high)
append_group_preset(datapoints, options, "self_test", tuya.dp_self_test_state)
append_group_preset(datapoints, options, "fault_alarm", tuya.dp_fault_alarm)
append_group_preset(datapoints, options, "device_fault", tuya.dp_device_fault)
append_group_preset(datapoints, options, "silence", tuya.dp_silence)
append_group_preset(datapoints, options, "alarm_volume", tuya.dp_alarm_volume)
append_group_preset(datapoints, options, "alarm_switch", tuya.dp_alarm_switch)
return datapoints
end
function tuya.build_carbon_monoxide_sensor_datapoints(options)
options = options or {}
local datapoints = {}
append_group_preset(datapoints, options, "carbon_monoxide", tuya.dp_carbon_monoxide)
append_group_preset(datapoints, options, "co", tuya.dp_co)
append_group_preset(datapoints, options, "battery", tuya.dp_battery)
append_group_preset(datapoints, options, "battery_state", tuya.dp_battery_state_low_medium_high)
append_group_preset(datapoints, options, "silence", tuya.dp_silence)
append_group_preset(datapoints, options, "self_test", tuya.dp_self_test_state)
return datapoints
end
function tuya.build_gas_carbon_monoxide_sensor_datapoints(options)
options = options or {}
local datapoints = {}
append_preset_list(datapoints, tuya.build_carbon_monoxide_sensor_datapoints(options))
append_group_preset(datapoints, options, "gas", tuya.dp_gas)
append_group_preset(datapoints, options, "gas_value", tuya.dp_gas_value)
append_group_preset(datapoints, options, "gas_fault_status", tuya.dp_gas_fault_status)
append_group_preset(datapoints, options, "fault_alarm", tuya.dp_fault_alarm)
append_group_preset(datapoints, options, "alarm_time", tuya.dp_alarm_time)
append_group_preset(datapoints, options, "alarm_ringtone", tuya.dp_alarm_ringtone)
append_group_preset(datapoints, options, "preheat", tuya.dp_preheat)
append_group_preset(datapoints, options, "alarm_switch", tuya.dp_alarm_switch)
return datapoints
end
function tuya.build_color_light_datapoints(options)
options = options or {}
local switch_module_options = resolve_group_options(options, "switch_module")
local datapoints = {}
append_preset_list(datapoints, tuya.build_switch_module_datapoints(switch_module_options))
append_group_preset(datapoints, options, "brightness", tuya.dp_brightness)
append_group_preset(datapoints, options, "min_brightness", tuya.dp_min_brightness)
append_group_preset(datapoints, options, "max_brightness", tuya.dp_max_brightness)
append_group_preset(datapoints, options, "color_temperature", tuya.dp_color_temperature)
append_group_preset(datapoints, options, "color_hue", tuya.dp_color_hue)
append_group_preset(datapoints, options, "color_saturation", tuya.dp_color_saturation)
append_group_preset(datapoints, options, "color_data", tuya.dp_color_data)
append_group_preset(datapoints, options, "color_power_on_behavior", tuya.dp_color_power_on_behavior)
append_group_preset(datapoints, options, "light_type", tuya.dp_light_type)
append_group_preset(datapoints, options, "light_mode", tuya.dp_light_mode)
append_group_preset(datapoints, options, "do_not_disturb", tuya.dp_do_not_disturb)
return datapoints
end
function tuya.build_cover_datapoints(options)
options = options or {}
local datapoints = {}
append_group_preset(datapoints, options, "cover_position", tuya.dp_cover_position)
append_group_preset(datapoints, options, "cover_position_inverted", tuya.dp_cover_position_inverted)
append_group_preset(datapoints, options, "motor_direction", tuya.dp_motor_direction)
append_group_preset(datapoints, options, "child_lock", tuya.dp_child_lock)
append_group_preset(datapoints, options, "switch_type_curtain", tuya.dp_switch_type_curtain)
return datapoints
end
function tuya.build_dimmer_datapoints(options)
options = options or {}
local switch_module_options = resolve_group_options(options, "switch_module")
local datapoints = {}
append_preset_list(datapoints, tuya.build_switch_module_datapoints(switch_module_options))
append_group_preset(datapoints, options, "brightness", tuya.dp_brightness)
append_group_preset(datapoints, options, "min_brightness", tuya.dp_min_brightness)
append_group_preset(datapoints, options, "max_brightness", tuya.dp_max_brightness)
append_group_preset(datapoints, options, "light_type", tuya.dp_light_type)
append_group_preset(datapoints, options, "light_mode", tuya.dp_light_mode)
append_group_preset(datapoints, options, "do_not_disturb", tuya.dp_do_not_disturb)
return datapoints
end
function tuya.build_water_leak_sensor_datapoints(options)
options = options or {}
local datapoints = {}
append_group_preset(datapoints, options, "water_leak", tuya.dp_water_leak)
append_group_preset(datapoints, options, "battery", tuya.dp_battery)
append_group_preset(datapoints, options, "battery_state", tuya.dp_battery_state)
append_group_preset(datapoints, options, "battery_low", tuya.dp_battery_low)
return datapoints
end
function tuya.build_thermostat_datapoints(options)
options = options or {}
local datapoints = {}
append_group_preset(datapoints, options, "local_temperature", tuya.dp_local_temperature)
append_group_preset(datapoints, options, "current_heating_setpoint", tuya.dp_current_heating_setpoint)
append_group_preset(datapoints, options, "occupied_heating_setpoint", tuya.dp_occupied_heating_setpoint)
append_group_preset(datapoints, options, "occupied_cooling_setpoint", tuya.dp_occupied_cooling_setpoint)
append_group_preset(datapoints, options, "system_mode", tuya.dp_system_mode)
append_group_preset(datapoints, options, "running_state", tuya.dp_running_state)
append_group_preset(datapoints, options, "fan_mode", tuya.dp_fan_mode)
append_group_preset(datapoints, options, "local_temperature_calibration", tuya.dp_local_temperature_calibration)
append_group_preset(datapoints, options, "frost_protection", tuya.dp_frost_protection)
append_group_preset(datapoints, options, "window_detection", tuya.dp_window_detection)
append_group_preset(datapoints, options, "open_window", tuya.dp_open_window)
append_group_preset(datapoints, options, "window_open", tuya.dp_window_open)
append_group_preset(datapoints, options, "open_window_temperature", tuya.dp_open_window_temperature)
append_group_preset(datapoints, options, "open_window_time", tuya.dp_open_window_time)
append_group_preset(datapoints, options, "comfort_temperature", tuya.dp_comfort_temperature)
append_group_preset(datapoints, options, "eco_temperature", tuya.dp_eco_temperature)
append_group_preset(datapoints, options, "holiday_temperature", tuya.dp_holiday_temperature)
append_group_preset(datapoints, options, "max_temperature_limit", tuya.dp_max_temperature_limit)
append_group_preset(datapoints, options, "min_temperature_limit", tuya.dp_min_temperature_limit)
append_group_preset(datapoints, options, "deadzone_temperature", tuya.dp_deadzone_temperature)
append_group_preset(datapoints, options, "boost_time", tuya.dp_boost_time)
append_group_preset(datapoints, options, "boost_timeset_countdown", tuya.dp_boost_timeset_countdown)
append_group_preset(datapoints, options, "boost_heating", tuya.dp_boost_heating)
append_group_preset(datapoints, options, "scale_protection", tuya.dp_scale_protection)
append_group_preset(datapoints, options, "eco_mode", tuya.dp_eco_mode)
append_group_preset(datapoints, options, "valve_state", tuya.dp_valve_state)
append_group_preset(datapoints, options, "temperature_sensor_select", tuya.dp_temperature_sensor_select)
append_group_preset(datapoints, options, "temperature_unit", tuya.dp_temperature_unit)
append_group_preset(datapoints, options, "battery", tuya.dp_battery)
append_group_preset(datapoints, options, "battery_state", tuya.dp_battery_state)
return datapoints
end
function tuya.build_trv_datapoints(options)
return tuya.build_thermostat_datapoints(options)
end
function tuya.build_fan_datapoints(options)
options = options or {}
local switch_options = resolve_group_options(options, "switch", true)
local datapoints = {}
append_preset(datapoints, switch_options.dp, tuya.dp_on_off, switch_options)
append_group_preset(datapoints, options, "fan_mode", tuya.dp_fan_mode)
append_group_preset(datapoints, options, "fan_speed", tuya.dp_fan_speed)
return datapoints
end
function tuya.build_siren_datapoints(options)
options = options or {}
local datapoints = {}
append_group_preset(datapoints, options, "alarm", tuya.dp_alarm)
return datapoints
end
function tuya.build_lock_datapoints(options)
options = options or {}
local datapoints = {}
append_group_preset(datapoints, options, "lock", tuya.dp_lock)
append_group_preset(datapoints, options, "child_lock", tuya.dp_child_lock)
append_group_preset(datapoints, options, "battery", tuya.dp_battery)
append_group_preset(datapoints, options, "battery_state", tuya.dp_battery_state)
return datapoints
end
function tuya.build_air_quality_sensor_datapoints(options)
options = options or {}
local datapoints = {}
append_group_preset(datapoints, options, "co2", tuya.dp_co2)
append_group_preset(datapoints, options, "voc", tuya.dp_voc)
append_group_preset(datapoints, options, "pm25", tuya.dp_pm25)
append_group_preset(datapoints, options, "formaldehyde", tuya.dp_formaldehyde)
append_group_preset(datapoints, options, "temperature", tuya.dp_temperature)
append_group_preset(datapoints, options, "humidity", tuya.dp_humidity)
append_group_preset(datapoints, options, "temperature_unit", tuya.dp_temperature_unit)
append_group_preset(datapoints, options, "temperature_calibration", tuya.dp_temperature_calibration)
append_group_preset(datapoints, options, "humidity_calibration", tuya.dp_humidity_calibration)
append_group_preset(datapoints, options, "battery", tuya.dp_battery)
append_group_preset(datapoints, options, "battery_state", tuya.dp_battery_state)
return datapoints
end
function tuya.build_water_meter_datapoints(options)
options = options or {}
local datapoints = {}
append_group_preset(datapoints, options, "water_consumed", tuya.dp_water_consumed)
append_group_preset(datapoints, options, "reverse_water_consumed", tuya.dp_reverse_water_consumed)
append_group_preset(datapoints, options, "month_consumption", tuya.dp_month_consumption)
append_group_preset(datapoints, options, "daily_consumption", tuya.dp_daily_consumption)
append_group_preset(datapoints, options, "flow_rate", tuya.dp_flow_rate)
append_group_preset(datapoints, options, "instantaneous_flow_rate", tuya.dp_instantaneous_flow_rate)
append_group_preset(datapoints, options, "cumulative_heat", tuya.dp_cumulative_heat)
append_group_preset(datapoints, options, "inlet_water_temperature", tuya.dp_inlet_water_temperature)
append_group_preset(datapoints, options, "outlet_water_temperature", tuya.dp_outlet_water_temperature)
append_group_preset_with_defaults(datapoints, options, "temperature", tuya.dp_temperature, { scale = 100 })
append_group_preset(datapoints, options, "battery_voltage", tuya.dp_battery_voltage)
append_group_preset(datapoints, options, "meter_id", tuya.dp_meter_id)
append_group_preset(datapoints, options, "faults", tuya.dp_water_meter_faults)
append_group_preset(datapoints, options, "report_period", tuya.dp_water_meter_report_period)
return datapoints
end
function tuya.build_radar_presence_sensor_datapoints(options)
options = options or {}
local datapoints = {}
append_group_preset(datapoints, options, "presence", tuya.dp_presence)
append_group_preset(datapoints, options, "motion_state", tuya.dp_motion_state)
append_group_preset(datapoints, options, "indicator", tuya.dp_indicator)
append_group_preset(datapoints, options, "fading_time", tuya.dp_fading_time)
append_group_preset(datapoints, options, "illuminance_interval", tuya.dp_illuminance_interval)
append_group_preset(datapoints, options, "static_detection_distance", tuya.dp_static_detection_distance)
append_group_preset(datapoints, options, "static_detection_sensitivity", tuya.dp_static_detection_sensitivity)
append_group_preset(datapoints, options, "motion_detection_mode", tuya.dp_motion_detection_mode)
append_group_preset(datapoints, options, "motion_detection_sensitivity", tuya.dp_motion_detection_sensitivity)
append_group_preset(datapoints, options, "target_distance", tuya.dp_target_distance)
append_group_preset(datapoints, options, "illuminance", tuya.dp_illuminance)
append_group_preset(datapoints, options, "temperature", tuya.dp_temperature)
append_group_preset(datapoints, options, "humidity", tuya.dp_humidity)
append_group_preset(datapoints, options, "temperature_unit", tuya.dp_temperature_unit)
append_group_preset(datapoints, options, "temperature_calibration", tuya.dp_temperature_calibration)
append_group_preset(datapoints, options, "humidity_calibration", tuya.dp_humidity_calibration)
append_group_preset(datapoints, options, "battery", tuya.dp_battery)
append_group_preset(datapoints, options, "battery_state", tuya.dp_battery_state)
return datapoints
end
local gang_presets = {
{ "gang_switch", "on_off", "switch" },
{ "gang_child_lock", "child_lock", "child_lock" },
{ "gang_power_on_behavior", "power_on_behavior", "power_on_behavior" },
{ "gang_switch_mode", "switch_mode", "switch_mode" },
{ "gang_switch_type", "switch_type", "switch_type" },
{ "gang_switch_type_button", "switch_type_button", "switch_type_button" },
{ "gang_switch_type_curtain", "switch_type_curtain", "switch_type_curtain" },
{ "gang_brightness", "brightness", "brightness" },
{ "gang_countdown", "countdown", "countdown" },
{ "gang_do_not_disturb", "do_not_disturb", "do_not_disturb" },
}
for _, entry in ipairs(gang_presets) do
local suffix, dp_suffix, default_name = entry[1], entry[2], entry[3]
tuya["build_" .. suffix .. "_datapoints"] = function(dp_list, options)
return build_gang_datapoints(dp_list, tuya["dp_" .. dp_suffix], default_name, options)
end
end
local phase_meter_presets = {
{ "phase_variant1_meter", "phase_variant1" },
{ "phase_variant2_meter", "phase_variant2" },
{ "phase_variant3_meter", "phase_variant3" },
}
for _, entry in ipairs(phase_meter_presets) do
local suffix, dp_suffix = entry[1], entry[2]
tuya["build_" .. suffix .. "_datapoints"] = function(dp_list, options)
return build_phase_meter_datapoints(dp_list, tuya["dp_" .. dp_suffix], options)
end
end
function tuya.build_light_datapoints(options)
options = options or {}
local switch_module_options = resolve_group_options(options, "switch_module")
local datapoints = {}
append_preset_list(datapoints, tuya.build_switch_module_datapoints(switch_module_options))
append_group_preset(datapoints, options, "brightness", tuya.dp_brightness)
append_group_preset(datapoints, options, "min_brightness", tuya.dp_min_brightness)
append_group_preset(datapoints, options, "max_brightness", tuya.dp_max_brightness)
append_group_preset(datapoints, options, "light_type", tuya.dp_light_type)
append_group_preset(datapoints, options, "light_mode", tuya.dp_light_mode)
append_group_preset(datapoints, options, "do_not_disturb", tuya.dp_do_not_disturb)
return datapoints
end
function tuya.build_switch_config_datapoints(options)
options = options or {}
local datapoints = {}
append_group_preset(datapoints, options, "child_lock", tuya.dp_child_lock)
append_group_preset(datapoints, options, "power_on_behavior", tuya.dp_power_on_behavior)
append_group_preset(datapoints, options, "power_outage_memory", tuya.dp_power_outage_memory)
append_group_preset(datapoints, options, "switch_type", tuya.dp_switch_type)
append_group_preset(datapoints, options, "switch_type_button", tuya.dp_switch_type_button)
append_group_preset(datapoints, options, "switch_type_curtain", tuya.dp_switch_type_curtain)
append_group_preset(datapoints, options, "backlight_mode", tuya.dp_backlight_mode)
append_group_preset(datapoints, options, "backlight_mode_low_medium_high", tuya.dp_backlight_mode_low_medium_high)
append_group_preset(datapoints, options, "backlight_mode_off_on", tuya.dp_backlight_mode_off_on)
append_group_preset(datapoints, options, "indicator_mode", tuya.dp_indicator_mode)
append_group_preset(datapoints, options, "indicator_mode_none_relay_pos", tuya.dp_indicator_mode_none_relay_pos)
return datapoints
end
function tuya.build_switch_module_datapoints(options)
options = options or {}
local switch_options = resolve_group_options(options, "switch", true)
local config_options = resolve_group_options(options, "config")
local datapoints = {}
append_preset(datapoints, switch_options.dp, tuya.dp_on_off, switch_options)
append_group_preset(datapoints, options, "countdown", tuya.dp_countdown)
append_group_preset(datapoints, options, "inching_switch", tuya.dp_inching_switch)
append_group_preset(datapoints, options, "switch_mode", tuya.dp_switch_mode)
append_preset_list(datapoints, tuya.build_switch_config_datapoints(config_options))
return datapoints
end
function tuya.build_button_switch_config_datapoints(options)
return tuya.build_switch_config_datapoints(
build_switch_config_variant_options(options, "switch_type_button")
)
end
function tuya.build_curtain_switch_config_datapoints(options)
return tuya.build_switch_config_datapoints(
build_switch_config_variant_options(options, "switch_type_curtain")
)
end
function tuya.build_button_switch_module_datapoints(options)
return tuya.build_switch_module_datapoints(
build_switch_module_variant_options(options, "switch_type_button")
)
end
function tuya.build_curtain_switch_module_datapoints(options)
return tuya.build_switch_module_datapoints(
build_switch_module_variant_options(options, "switch_type_curtain")
)
end
function tuya.build_meter_datapoints(options)
options = options or {}
local datapoints = {}
append_group_preset(datapoints, options, "voltage", tuya.dp_voltage)
append_group_preset(datapoints, options, "current", tuya.dp_current)
append_group_preset(datapoints, options, "power", tuya.dp_power)
append_group_preset(datapoints, options, "energy", tuya.dp_energy)
append_group_preset(datapoints, options, "ac_frequency", tuya.dp_ac_frequency)
append_group_or_list_preset(
datapoints,
options,
"phase_variant1",
tuya.dp_phase_variant1,
tuya.build_phase_variant1_meter_datapoints
)
append_group_or_list_preset(
datapoints,
options,
"phase_variant2",
tuya.dp_phase_variant2,
tuya.build_phase_variant2_meter_datapoints
)
append_group_or_list_preset(
datapoints,
options,
"phase_variant3",
tuya.dp_phase_variant3,
tuya.build_phase_variant3_meter_datapoints
)
append_group_preset(datapoints, options, "threshold", tuya.dp_threshold)
append_group_preset(datapoints, options, "power_factor", tuya.dp_power_factor)
append_group_preset(datapoints, options, "meter_id", tuya.dp_meter_id)
return datapoints
end
function tuya.build_gang_switch_config_datapoints(options)
options = options or {}
local datapoints = {}
append_gang_group_preset_list(datapoints, options, "child_lock", "child_lock", tuya.build_gang_child_lock_datapoints)
append_gang_group_preset_list(datapoints, options, "power_on_behavior", "power_on_behavior", tuya.build_gang_power_on_behavior_datapoints)
append_gang_group_preset_list(datapoints, options, "switch_type", "switch_type", tuya.build_gang_switch_type_datapoints)
append_gang_group_preset_list(datapoints, options, "switch_type_button", "switch_type_button", tuya.build_gang_switch_type_button_datapoints)
append_gang_group_preset_list(datapoints, options, "switch_type_curtain", "switch_type_curtain", tuya.build_gang_switch_type_curtain_datapoints)
return datapoints
end
function tuya.build_gang_switch_module_datapoints(options)
options = options or {}
local switch_options = build_gang_group_options(options, "switch", "switch", true)
local config_options = resolve_group_options(options, "config")
local datapoints = {}
append_preset_list(datapoints, tuya.build_gang_switch_datapoints(resolve_list_or_dp_source(switch_options), switch_options))
append_gang_group_preset_list(datapoints, options, "countdown", "countdown", tuya.build_gang_countdown_datapoints)
append_gang_group_preset_list(datapoints, options, "switch_mode", "switch_mode", tuya.build_gang_switch_mode_datapoints)
append_preset_list(datapoints, tuya.build_gang_switch_config_datapoints(config_options))
return datapoints
end
function tuya.build_gang_button_switch_config_datapoints(options)
return tuya.build_gang_switch_config_datapoints(
build_switch_config_variant_options(options, "switch_type_button")
)
end
function tuya.build_gang_curtain_switch_config_datapoints(options)
return tuya.build_gang_switch_config_datapoints(
build_switch_config_variant_options(options, "switch_type_curtain")
)
end
function tuya.build_gang_button_switch_module_datapoints(options)
return tuya.build_gang_switch_module_datapoints(
build_switch_module_variant_options(options, "switch_type_button")
)
end
function tuya.build_gang_curtain_switch_module_datapoints(options)
return tuya.build_gang_switch_module_datapoints(
build_switch_module_variant_options(options, "switch_type_curtain")
)
end
function tuya.build_plug_datapoints(options)
options = options or {}
local switch_module_options = resolve_group_options(options, "switch_module")
local meter_options = resolve_group_options(options, "meter")
local datapoints = {}
append_preset_list(datapoints, tuya.build_switch_module_datapoints(switch_module_options))
append_preset_list(datapoints, tuya.build_meter_datapoints(meter_options))
return datapoints
end
function tuya.build_button_plug_datapoints(options)
return tuya.build_plug_datapoints(
build_plug_variant_options(options, "switch_type_button")
)
end
function tuya.build_curtain_plug_datapoints(options)
return tuya.build_plug_datapoints(
build_plug_variant_options(options, "switch_type_curtain")
)
end
function tuya.build_gang_plug_datapoints(options)
options = options or {}
local switch_module_options = resolve_group_options(options, "switch_module")
local meter_options = resolve_group_options(options, "meter")
local datapoints = {}
append_preset_list(datapoints, tuya.build_gang_switch_module_datapoints(switch_module_options))
append_preset_list(datapoints, tuya.build_meter_datapoints(meter_options))
return datapoints
end
function tuya.build_gang_button_plug_datapoints(options)
return tuya.build_gang_plug_datapoints(
build_plug_variant_options(options, "switch_type_button")
)
end
function tuya.build_gang_curtain_plug_datapoints(options)
return tuya.build_gang_plug_datapoints(
build_plug_variant_options(options, "switch_type_curtain")
)
end
function tuya.build_gang_light_datapoints(options)
options = options or {}
local switch_module_options = resolve_group_options(options, "switch_module")
local brightness_options = build_gang_group_options(options, "brightness", "brightness")
local datapoints = {}
append_preset_list(datapoints, tuya.build_gang_switch_module_datapoints(switch_module_options))
append_preset_list(datapoints, tuya.build_gang_brightness_datapoints(resolve_list_or_dp_source(brightness_options), brightness_options))
return datapoints
end
end
return load_datapoint_preset
