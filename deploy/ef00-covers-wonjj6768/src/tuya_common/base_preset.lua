local function load_base_preset(tuya, shared)
local EPOCH_2000_OFFSET = shared.EPOCH_2000_OFFSET
local type_check = shared.type_check
local prepare_mappings = shared.prepare_mappings
local configure_option_keys = {
"magic_packet",
"query_on_configure",
"query_command_id",
"mcu_version_request_on_configure",
"bind_basic_on_configure",
"bind_target_eui",
"query_interval_seconds",
"step_delay",
"initial_delay",
"named_mappings",
"named_mapping_values",
"named_mapping_names",
"named_datapoints",
"named_key_field",
}
local announce_option_keys = {
"query_on_announce",
"announce_delay",
"query_command_id",
}
local message_option_keys = {
"config_queue",
"queue_delay",
"auto_time",
"time_offset",
"time_start",
"utc_time",
"local_time",
"auto_connection_status",
"connection_status_bytes",
}
local preferences_option_keys = {
"preference_names",
"use_queue",
}
local named_mapping_option_keys = {
"named_mappings",
"named_datapoints",
"named_key_field",
"named_mapping_values",
"named_mapping_names",
}
local copy_table = shared.copy_table
local copy_keys = shared.copy_keys
local time_offset_for_start = shared.time_offset_for_start
local function resolve_datapoints(options)
return options.datapoints
end
local function resolve_preference_map(options, datapoints)
if options.preference_map ~= nil then
return options.preference_map
end
if options.preference_datapoints ~= nil then
local preference_datapoints = options.preference_datapoints
if preference_datapoints == true then
preference_datapoints = datapoints
end
if preference_datapoints == nil then
return nil
end
return tuya.build_preference_map(preference_datapoints, options.preference_key_field)
end
return nil
end
local function normalize_named_mapping_options(options)
local normalized = copy_table(options and options.named_mapping)
copy_keys(normalized, options, named_mapping_option_keys)
return normalized
end
local function resolve_named_mappings(named_mapping_options, datapoints)
if named_mapping_options.named_mappings ~= nil then
return named_mapping_options.named_mappings
end
if named_mapping_options.named_datapoints ~= nil then
local named_datapoints = named_mapping_options.named_datapoints
if named_datapoints == true then
named_datapoints = datapoints
end
if named_datapoints == nil then
return nil
end
if named_mapping_options.named_key_field ~= nil then
return tuya.build_named_map(named_datapoints, named_mapping_options.named_key_field)
end
return named_datapoints
end
if named_mapping_options.named_mapping_values ~= nil or named_mapping_options.named_mapping_names ~= nil then
if datapoints == nil then
return nil
end
if named_mapping_options.named_key_field ~= nil then
return tuya.build_named_map(datapoints, named_mapping_options.named_key_field)
end
return datapoints
end
return nil
end
local function resolve_variant_datapoints(options, builder)
if type_check(options) ~= "table" then
return builder(options)
end
if options.datapoints ~= nil then
return options.datapoints
end
if options.datapoint_options ~= nil then
return builder(options.datapoint_options)
end
return builder(options)
end
local function build_variant_preset(options, builder)
local resolved_options = copy_table(options)
resolved_options.datapoints = resolve_variant_datapoints(options, builder)
return tuya.build_base_preset(resolved_options)
end
local function resolve_list_variant_args(options)
if type_check(options) ~= "table" then
return options, nil
end
local builder_options = options.datapoint_options
if type_check(builder_options) ~= "table" then
builder_options = options
end
local dp_list = builder_options.dps
if dp_list == nil then
dp_list = builder_options.dp_list
end
if dp_list == nil and builder_options.dp ~= nil then
dp_list = { builder_options.dp }
end
if dp_list == nil and builder_options[1] ~= nil then
dp_list = builder_options
end
return dp_list, builder_options
end
local function build_list_variant_preset(options, builder)
local resolved_options = copy_table(options)
if resolved_options.datapoints == nil then
local dp_list, builder_options = resolve_list_variant_args(options)
resolved_options.datapoints = builder(dp_list, builder_options)
end
return tuya.build_base_preset(resolved_options)
end
local function normalize_base_preset_options(options)
options = options or {}
local datapoints = resolve_datapoints(options)
local named_mapping_options = normalize_named_mapping_options(options)
local preference_map = resolve_preference_map(options, datapoints)
local named_mappings = resolve_named_mappings(named_mapping_options, datapoints)
local named_mappings_by_name = nil
if type_check(named_mappings) == "table" then
named_mappings_by_name = tuya.build_named_map(named_mappings, "name")
end
local configure_options = copy_table(options.configure)
copy_keys(configure_options, options, configure_option_keys)
if preference_map ~= nil and configure_options.preference_map == nil then
configure_options.preference_map = preference_map
end
if options.preference_names ~= nil and configure_options.preference_names == nil then
configure_options.preference_names = options.preference_names
end
if named_mappings ~= nil and configure_options.named_mappings == nil then
configure_options.named_mappings = named_mappings
end
if named_mapping_options.named_mapping_values ~= nil and configure_options.named_mapping_values == nil then
configure_options.named_mapping_values = named_mapping_options.named_mapping_values
end
if named_mapping_options.named_mapping_names ~= nil and configure_options.named_mapping_names == nil then
configure_options.named_mapping_names = named_mapping_options.named_mapping_names
end
local announce_options = copy_table(options.announce)
copy_keys(announce_options, options, announce_option_keys)
local message_handlers = copy_table(options.message)
copy_keys(message_handlers, options, message_option_keys)
if datapoints ~= nil and message_handlers.datapoints == nil then
message_handlers.datapoints = datapoints
end
local preferences_options = copy_table(options.preferences)
copy_keys(preferences_options, options, preferences_option_keys)
if options.preference_names ~= nil and preferences_options.preference_names == nil then
preferences_options.preference_names = options.preference_names
end
if datapoints ~= nil then
prepare_mappings(datapoints)
end
if preference_map ~= nil then
prepare_mappings(preference_map)
end
if named_mappings ~= nil and named_mappings ~= datapoints then
prepare_mappings(named_mappings)
end
return {
datapoints = datapoints,
zcl_clusters = options.zcl_clusters,
preference_map = preference_map,
named_mappings = named_mappings,
named_mappings_by_name = named_mappings_by_name,
configure_options = configure_options,
announce_options = announce_options,
message_handlers = message_handlers,
preferences_options = preferences_options,
named_mapping_options = named_mapping_options,
}
end
local preset_methods = {}
local function resolve_preset_preference_map(preset)
if preset.preference_map ~= nil then
return preset.preference_map
end
return preset.datapoints
end
local function resolve_preset_named_mappings(preset)
if preset.named_mappings ~= nil then
return preset.named_mappings
end
return preset.datapoints
end
function preset_methods.start_configuration(self, device, driver)
return tuya.start_configuration(device, self.configure_options, driver)
end
function preset_methods.send_magic_packet(self, device)
return tuya.send_magic_packet(device)
end
function preset_methods.send_state_request(self, device, command_id)
local resolved_command_id = command_id
if resolved_command_id == nil then
resolved_command_id = self.configure_options.query_command_id
end
if resolved_command_id == nil then
resolved_command_id = self.announce_options.query_command_id
end
return tuya.send_state_request(device, resolved_command_id)
end
function preset_methods.send_mcu_version_request(self, device, transaction)
return tuya.send_mcu_version_request(device, transaction)
end
function preset_methods.send_connection_status(self, device, transaction, status_bytes)
local handlers = self.message_handlers
return tuya.send_connection_status(
device,
transaction,
status_bytes or handlers.connection_status_bytes
)
end
function preset_methods.send_time(self, device, utc_time, local_time)
local handlers = self.message_handlers
local resolved_utc_time = utc_time or handlers.utc_time
local resolved_local_time = local_time or handlers.local_time
local time_offset = handlers.time_offset
if time_offset ~= nil then
return tuya.send_time_with_offset(device, time_offset, resolved_utc_time, resolved_local_time)
end
local time_start = handlers.time_start
if time_start == "off" then
return false
end
if time_start ~= nil then
local offset = time_offset_for_start(time_start)
if offset ~= 0 then
return tuya.send_time_with_offset(device, offset, resolved_utc_time, resolved_local_time)
end
end
return tuya.send_time(device, resolved_utc_time, resolved_local_time)
end
function preset_methods.send_time_with_offset(self, device, offset_seconds, utc_time, local_time)
local handlers = self.message_handlers
local resolved_offset = offset_seconds
if resolved_offset == nil then
resolved_offset = handlers.time_offset
end
if resolved_offset == nil and handlers.time_start ~= nil then
resolved_offset = time_offset_for_start(handlers.time_start)
end
return tuya.send_time_with_offset(
device,
resolved_offset,
utc_time or handlers.utc_time,
local_time or handlers.local_time
)
end
function preset_methods.apply_time_request(self, device, message)
local handlers = self.message_handlers
local time_offset = handlers.time_offset
if time_offset ~= nil then
return tuya.apply_time_request_with_offset(device, message, time_offset, handlers.utc_time, handlers.local_time)
end
local time_start = handlers.time_start
if time_start == "off" then
return false
end
if time_start ~= nil then
local offset = time_offset_for_start(time_start)
if offset ~= 0 then
return tuya.apply_time_request_with_offset(device, message, offset, handlers.utc_time, handlers.local_time)
end
end
return tuya.apply_time_request(device, message, handlers.utc_time, handlers.local_time)
end
function preset_methods.apply_connection_status_request(self, device, message)
return tuya.apply_connection_status_request(device, message, self.message_handlers.connection_status_bytes)
end
function preset_methods.start_query_timer(self, device, interval_seconds, command_id)
local configure_options = self.configure_options
return tuya.start_query_timer(
device,
interval_seconds or configure_options.query_interval_seconds,
command_id or configure_options.query_command_id
)
end
function preset_methods.stop_query_timer(self, device)
return tuya.stop_query_timer(device)
end
function preset_methods.apply_announce(self, device)
return tuya.apply_announce(device, self.announce_options)
end
function preset_methods.apply_message(self, device, message)
return tuya.apply_message(device, message, self.message_handlers)
end
function preset_methods.apply_preferences_changed(self, device, old_prefs)
local preference_map = resolve_preset_preference_map(self)
if preference_map == nil then
return false
end
return tuya.apply_preferences_changed(device, preference_map, old_prefs, self.preferences_options)
end
function preset_methods.send_preferences(self, device, old_prefs, preference_names)
local preference_map = resolve_preset_preference_map(self)
if preference_map == nil then
return false
end
local preferences_options = self.preferences_options
return tuya.send_preferences(
device,
preference_map,
old_prefs,
preference_names or preferences_options.preference_names
)
end
function preset_methods.build_preference_config_queue(self, device, old_prefs, preference_names)
local preference_map = resolve_preset_preference_map(self)
if preference_map == nil then
return {}
end
local preferences_options = self.preferences_options
return tuya.build_preference_config_queue(
device,
preference_map,
preference_names or preferences_options.preference_names,
old_prefs
)
end
function preset_methods.start_preference_config_queue(self, device, old_prefs, preference_names)
local preference_map = resolve_preset_preference_map(self)
if preference_map == nil then
return false
end
local preferences_options = self.preferences_options
return tuya.start_preference_config_queue(
device,
preference_map,
preference_names or preferences_options.preference_names,
old_prefs
)
end
function preset_methods.send_named_mapping(self, device, name, value, context)
local named_mappings = resolve_preset_named_mappings(self)
if named_mappings == nil then
return nil
end
local named_mapping_options = self.named_mapping_options
local resolved_value = value
if resolved_value == nil and
type_check(name) == "string" and
type_check(named_mapping_options.named_mapping_values) == "table" then
resolved_value = named_mapping_options.named_mapping_values[name]
end
return tuya.send_named_mapping(device, named_mappings, name, resolved_value, context)
end
function preset_methods.send_named_mappings(self, device, values, names, context)
local named_mappings = resolve_preset_named_mappings(self)
if named_mappings == nil then
return nil
end
local named_mapping_options = self.named_mapping_options
return tuya.send_named_mappings(
device,
named_mappings,
values or named_mapping_options.named_mapping_values,
names or named_mapping_options.named_mapping_names,
context
)
end
function preset_methods.build_named_mapping_config_queue(self, device, values, names, context)
local named_mappings = resolve_preset_named_mappings(self)
if named_mappings == nil then
return {}
end
local named_mapping_options = self.named_mapping_options
return tuya.build_named_mapping_config_queue(
device,
named_mappings,
values or named_mapping_options.named_mapping_values,
names or named_mapping_options.named_mapping_names,
context
)
end
function preset_methods.start_named_mapping_config_queue(self, device, values, names, context)
local named_mappings = resolve_preset_named_mappings(self)
if named_mappings == nil then
return false
end
local named_mapping_options = self.named_mapping_options
return tuya.start_named_mapping_config_queue(
device,
named_mappings,
values or named_mapping_options.named_mapping_values,
names or named_mapping_options.named_mapping_names,
context
)
end
function preset_methods.build_driver_template(self, options)
options = options or {}
local function cluster_handler(driver, device, zb_rx)
self:apply_message(device, zb_rx)
end
local EF00 = tuya.EF00_CLUSTER
local template = {
supported_capabilities = options.supported_capabilities,
zigbee_handlers = {
cluster = {
[EF00] = {
[tuya.GET_DATA] = cluster_handler,
[tuya.SET_DATA_RESPONSE] = cluster_handler,
[tuya.REPORT_STATUS] = cluster_handler,
[tuya.ACTIVE_STATUS_REPORT] = cluster_handler,
[tuya.SET_TIME] = cluster_handler,
[tuya.CONNECTION_STATUS] = cluster_handler,
},
},
},
lifecycle_handlers = {
init = function(driver, device)
device:set_find_child(function() return device end)
end,
doConfigure = function(driver, device)
self:start_configuration(device, driver)
end,
},
capability_handlers = {
["refresh"] = {
["refresh"] = function(driver, device)
self:send_state_request(device)
end,
},
},
health_check = false,
}
if options.preferences then
template.lifecycle_handlers.infoChanged = function(_, device, _, args)
if args.old_st_store then
self:apply_preferences_changed(device, args.old_st_store.preferences)
end
end
end
if options.lifecycle_handlers then
for k, v in pairs(options.lifecycle_handlers) do
template.lifecycle_handlers[k] = v
end
end
if options.capability_handlers then
for k, v in pairs(options.capability_handlers) do
template.capability_handlers[k] = v
end
end
if options.sub_drivers then
template.sub_drivers = options.sub_drivers
end
return template
end
local function bind_preset_method(preset, method)
return function(first, ...)
if first == preset then
return method(preset, ...)
end
return method(preset, first, ...)
end
end
local preset_method_names = {
"start_configuration", "send_magic_packet",
"send_state_request", "send_mcu_version_request",
"send_connection_status", "send_time", "send_time_with_offset",
"apply_time_request", "apply_connection_status_request",
"start_query_timer", "stop_query_timer",
"apply_announce", "apply_message", "apply_preferences_changed",
"send_preferences", "build_preference_config_queue",
"start_preference_config_queue",
"send_named_mapping", "send_named_mappings",
"build_named_mapping_config_queue", "start_named_mapping_config_queue",
"build_driver_template",
}
function tuya.build_base_preset(options)
local normalized = normalize_base_preset_options(options)
for _, name in ipairs(preset_method_names) do
normalized[name] = bind_preset_method(normalized, preset_methods[name])
end
return normalized
end
local variant_preset_names = {
"sensor", "temperature_sensor", "temperature_humidity_sensor",
"illuminance_sensor", "contact_sensor", "occupancy_sensor",
"environment_sensor", "soil_sensor", "soil_fertility_sensor",
"gas_sensor", "smoke_sensor", "carbon_monoxide_sensor",
"gas_carbon_monoxide_sensor",
"switch", "temperature", "humidity", "battery",
"battery_state", "battery_state_low_medium_high",
"contact", "occupancy", "illuminance", "temperature_unit",
"child_lock", "power_on_behavior", "power_outage_memory",
"switch_type", "switch_type_button", "switch_type_curtain",
"switch_mode", "backlight_mode", "backlight_mode_low_medium_high",
"backlight_mode_off_on", "indicator_mode", "indicator_mode_none_relay_pos",
"brightness", "action", "countdown",
"voltage", "current", "power", "energy", "ac_frequency",
"phase_variant1", "phase_variant2", "phase_variant3", "threshold",
"color_temperature", "color_hue", "color_saturation", "color_data",
"cover_position", "cover_position_inverted",
"do_not_disturb", "inching_switch",
"local_temperature", "current_heating_setpoint",
"occupied_heating_setpoint", "occupied_cooling_setpoint",
"local_temperature_calibration", "open_window_temperature",
"comfort_temperature", "eco_temperature", "holiday_temperature",
"max_temperature_limit", "min_temperature_limit",
"deadzone_temperature", "inlet_water_temperature",
"outlet_water_temperature", "open_window_time",
"system_mode", "running_state", "fan_mode", "fan_speed",
"frost_protection", "window_detection", "open_window", "window_open",
"boost_heating", "scale_protection", "eco_mode",
"valve_state", "valve_state_unknown_open_closed",
"temperature_sensor_select", "temperature_sensor_select_internal_external_both",
"temperature_calibration", "humidity_calibration",
"max_temperature_alarm", "min_temperature_alarm",
"max_humidity_alarm", "min_humidity_alarm",
"temperature_alarm", "humidity_alarm",
"soil_moisture", "soil_calibration", "temperature_sampling",
"report_interval", "soil_sampling", "soil_warning",
"illuminance_calibration", "water_warning",
"soil_fertility", "soil_fertility_calibration",
"soil_fertility_warning_setting", "soil_fertility_warning",
"gas", "gas_value", "smoke", "smoke_concentration",
"self_test_result", "self_test_state",
"fault_alarm", "silence", "alarm_time", "alarm_volume", "alarm_ringtone",
"preheat", "alarm_switch", "device_fault", "gas_fault_status",
"tamper", "battery_low", "pir_sensitivity", "hold_time", "keep_time",
"alarm", "presence", "motion_state", "indicator", "fading_time",
"illuminance_interval", "static_detection_distance",
"static_detection_sensitivity", "motion_detection_mode",
"motion_detection_sensitivity", "target_distance",
"carbon_monoxide", "co", "co2", "voc", "pm25", "formaldehyde",
"water_consumed", "reverse_water_consumed",
"month_consumption", "daily_consumption",
"flow_rate", "instantaneous_flow_rate", "cumulative_heat",
"battery_voltage", "meter_id",
"water_meter_faults", "water_meter_report_period",
"boost_time", "boost_timeset_countdown",
"switch_module", "switch_config",
"button_switch_config", "curtain_switch_config",
"button_switch_module", "curtain_switch_module", "meter",
"gang_switch_config", "gang_button_switch_config", "gang_curtain_switch_config",
"gang_switch_module", "gang_button_switch_module", "gang_curtain_switch_module",
"light", "color_light", "gang_light",
"cover", "thermostat", "trv", "fan", "siren", "lock",
"air_quality_sensor", "water_meter", "radar_presence_sensor",
"plug", "button_plug", "curtain_plug",
"gang_plug", "gang_button_plug", "gang_curtain_plug",
}
for _, name in ipairs(variant_preset_names) do
tuya["build_" .. name .. "_preset"] = function(options)
return build_variant_preset(options, tuya["build_" .. name .. "_datapoints"])
end
end
local list_variant_preset_names = {
"gang_switch", "gang_child_lock", "gang_power_on_behavior",
"gang_switch_mode", "gang_switch_type", "gang_switch_type_button",
"gang_switch_type_curtain", "gang_brightness", "gang_countdown",
"phase_variant1_meter", "phase_variant2_meter", "phase_variant3_meter",
}
for _, name in ipairs(list_variant_preset_names) do
tuya["build_" .. name .. "_preset"] = function(options)
return build_list_variant_preset(options, tuya["build_" .. name .. "_datapoints"])
end
end
function tuya.build_driver(name, preset, options)
local ZigbeeDriver = require "st.zigbee"
return ZigbeeDriver(name, preset:build_driver_template(options))
end
end
return load_base_preset
