local tuya = require "tuya_common"
local zcl = require "zcl_common"
local registry = require "core.registry"
local custom_capabilities = require "core.custom_capabilities"
local capabilities = require "st.capabilities"
local device_lib = require "st.device"
local data_types = require "st.zigbee.data_types"
local generated_clusters = require "st.zigbee.generated.zcl_clusters"
local component_mapping = require "app.component_mapping"
local custom_capability_runtime_factory = require "app.custom_capability_runtime"
local battery_refresh = require "app.battery_refresh"
local switch_default_on = require "st.zigbee.defaults.switch_defaults.on"
local switch_default_off = require "st.zigbee.defaults.switch_defaults.off"
local power_poll_interval_metadata = custom_capabilities.by_emit_name.power_poll_interval
local learn_ir_code_metadata = custom_capabilities.by_emit_name.learn_ir_code
local ir_code_to_send_metadata = custom_capabilities.by_emit_name.ir_code_to_send
local ef00_minimum_brightness_metadata = custom_capabilities.by_emit_name.ef00Ts0601MinimumBrightness
local WINDOW_SHADE_PRESET_LEVEL_KEY = "_presetLevel"
local DEFAULT_WINDOW_SHADE_PRESET_LEVEL = 50
local EF00_POWER_POLL_INTERVAL_FIELD = "_tuya_power_poll_interval_seconds"
local EF00_DEFAULT_POWER_POLL_INTERVAL = 300
local EF00_POWER_POLL_INTERVAL_MIN = 5
local EF00_POWER_POLL_INTERVAL_MAX = 3600
local EF00_POWER_POLL_INTERVAL_STEP = 5
local EF00_POWER_POLL_INTERVAL_UNIT = "s"
local IAS_WARNING_DEVICE_CLUSTER = 0x0502
local IAS_WARNING_MODE_STOP = 0x00
local IAS_WARNING_MODE_EMERGENCY = 0x03
local IAS_WARNING_LEVEL_LOW = 0x00
local IAS_WARNING_LEVEL_VERY_HIGH = 0x03
local DEFAULT_IAS_WARNING_DURATION = 300
local STATELESS_SWITCH_LEVEL_STEP_ID = "statelessSwitchLevelStep"
local STATELESS_SWITCH_LEVEL_STEP_COMMAND = "stepLevel"
battery_refresh.set_requester(function(device)
return zcl.read_attribute(device, 0x0001, 0x0020, 1)
end)
local preset_cache = setmetatable({}, { __mode = "k" })
local function register_all_zcl_mappings()
local all_definitions = registry.all()
for _, by_model in pairs(all_definitions) do
for _, definition in pairs(by_model) do
if definition.zcl_clusters then
zcl.register_attributes_from_mappings(definition.zcl_clusters)
zcl.register_cluster_commands_from_mappings(definition.zcl_clusters)
zcl.prepare_mappings(definition.zcl_clusters)
end
end
end
end
register_all_zcl_mappings()
local function get_preset(device)
local cached = preset_cache[device]
if cached then
return cached
end
local manufacturer = device:get_manufacturer()
local model = device:get_model()
if not manufacturer or not model then
return nil
end
local definition = registry.find(manufacturer, model)
if not definition then
return nil
end
local preset = tuya.build_base_preset(definition)
for key, value in pairs(definition) do
if key ~= "fingerprints" and preset[key] == nil then
preset[key] = value
end
end
if preset.zcl_clusters then
zcl.prepare_mappings(preset.zcl_clusters)
end
preset_cache[device] = preset
return preset
end
local function is_callable(value)
if type(value) == "function" then
return true
end
if type(value) ~= "table" then
return false
end
local metatable = getmetatable(value)
return type(metatable) == "table" and type(metatable.__call) == "function"
end
local function profile_supports_main_capability(device, capability_id)
if type(device) ~= "table" or type(capability_id) ~= "string" then
return false
end
local components = device.profile and device.profile.components or nil
local main = type(components) == "table" and components.main or nil
local capability_list = type(main) == "table" and main.capabilities or nil
if type(capability_list) ~= "table" then
return false
end
for _, capability in ipairs(capability_list) do
if type(capability) == "table" and capability.id == capability_id then
return true
end
end
return false
end
local function clamp_ef00_power_poll_interval(value)
local numeric = tonumber(value)
if numeric == nil then
return nil
end
numeric = math.floor(numeric + 0.5)
if numeric < EF00_POWER_POLL_INTERVAL_MIN then
numeric = EF00_POWER_POLL_INTERVAL_MIN
elseif numeric > EF00_POWER_POLL_INTERVAL_MAX then
numeric = EF00_POWER_POLL_INTERVAL_MAX
end
local remainder = numeric % EF00_POWER_POLL_INTERVAL_STEP
if remainder ~= 0 then
numeric = numeric - remainder
if numeric < EF00_POWER_POLL_INTERVAL_MIN then
numeric = EF00_POWER_POLL_INTERVAL_MIN
end
end
return numeric
end
local function supports_ef00_power_polling(device, preset)
return type(preset) == "table"
and preset.zcl_clusters == nil
and type(preset.datapoints) == "table"
and power_poll_interval_metadata ~= nil
and profile_supports_main_capability(device, power_poll_interval_metadata.capability_id)
end
local function resolved_ef00_power_poll_interval(device)
local override = clamp_ef00_power_poll_interval(device:get_field(EF00_POWER_POLL_INTERVAL_FIELD))
return override or EF00_DEFAULT_POWER_POLL_INTERVAL
end
local function emit_ef00_power_polling_state(device, preset)
if not supports_ef00_power_polling(device, preset) then
return false
end
local capability = capabilities[power_poll_interval_metadata.capability_id]
local attribute = capability and capability[power_poll_interval_metadata.attribute_name] or nil
if not is_callable(attribute) and capability and type(capability.attributes) == "table" then
attribute = capability.attributes[power_poll_interval_metadata.attribute_name]
end
if not is_callable(attribute) then
return false
end
local range_attribute = capability and capability[power_poll_interval_metadata.range_attribute_name] or nil
if not is_callable(range_attribute) and capability and type(capability.attributes) == "table" then
range_attribute = capability.attributes[power_poll_interval_metadata.range_attribute_name]
end
if is_callable(range_attribute) then
device:emit_event(range_attribute({
value = {
minimum = EF00_POWER_POLL_INTERVAL_MIN,
maximum = EF00_POWER_POLL_INTERVAL_MAX,
step = EF00_POWER_POLL_INTERVAL_STEP,
},
unit = EF00_POWER_POLL_INTERVAL_UNIT,
}))
end
device:emit_event(attribute({
value = resolved_ef00_power_poll_interval(device),
unit = EF00_POWER_POLL_INTERVAL_UNIT,
}))
return true
end
local function start_ef00_power_polling(device, preset)
if not supports_ef00_power_polling(device, preset) then
return false
end
preset:start_query_timer(device, resolved_ef00_power_poll_interval(device))
emit_ef00_power_polling_state(device, preset)
return true
end
local function shade_preset_field_key(component_id)
return string.format("%s:%s", WINDOW_SHADE_PRESET_LEVEL_KEY, tostring(component_id or "main"))
end
local function resolve_window_shade_preset_level(device, component_id)
component_id = component_id or "main"
local latest = device:get_latest_state(component_id, capabilities.windowShadePreset.ID, "position")
if type(latest) == "number" then
return latest
end
local stored = device:get_field(shade_preset_field_key(component_id))
if type(stored) ~= "number" then
stored = device:get_field(WINDOW_SHADE_PRESET_LEVEL_KEY)
end
if type(stored) == "number" then
return stored
end
local preference = device.preferences and device.preferences.presetPosition or nil
if type(preference) == "number" then
return preference
end
return DEFAULT_WINDOW_SHADE_PRESET_LEVEL
end
local function emit_window_shade_preset_state(device)
for _, component_id in ipairs(component_mapping.sorted_profile_component_ids(device)) do
if device:supports_capability_by_id(capabilities.windowShadePreset.ID, component_id) then
device:emit_component_event(
{ id = component_id },
capabilities.windowShadePreset.position(resolve_window_shade_preset_level(device, component_id))
)
end
end
end
local function emit_button_metadata(device, definition)
if type(definition) ~= "table" or type(definition.button_actions) ~= "table" then
return
end
local supported_values = definition.button_actions
for _, component_id in ipairs(component_mapping.sorted_profile_component_ids(device)) do
if device:supports_capability_by_id(capabilities.button.ID, component_id) then
device:emit_component_event({ id = component_id }, capabilities.button.supportedButtonValues(supported_values))
device:emit_component_event({ id = component_id }, capabilities.button.numberOfButtons({ value = 1 }))
end
end
end
local function ef00_handler(_, device, zigbee_message)
local preset = get_preset(device)
if preset then
preset:apply_message(device, zigbee_message)
end
end
local function build_cluster_handlers()
local handlers = {
[tuya.EF00_CLUSTER] = {
[tuya.GET_DATA] = ef00_handler,
[tuya.SET_DATA_RESPONSE] = ef00_handler,
[tuya.REPORT_STATUS] = ef00_handler,
[tuya.ACTIVE_STATUS_REPORT] = ef00_handler,
[tuya.SET_TIME] = ef00_handler,
[tuya.CONNECTION_STATUS] = ef00_handler,
},
}
local zcl_cluster_handlers = zcl.build_zigbee_cluster_handlers(get_preset)
for cluster_id, command_handlers in pairs(zcl_cluster_handlers) do
handlers[cluster_id] = handlers[cluster_id] or {}
for command_id, handler in pairs(command_handlers) do
handlers[cluster_id][command_id] = handler
end
end
return handlers
end
local command_definitions = {
{ capabilities.switch.ID,                    "on",                 "switch",                   true },
{ capabilities.switch.ID,                    "off",                "switch",                   false },
{ capabilities.audioVolume.ID,               "setVolume",          "volume",                   "volume" },
{ capabilities.doorControl.ID,               "open",               "door_control",             true },
{ capabilities.doorControl.ID,               "close",              "door_control",             false },
{ capabilities.valve.ID,                     "open",               "valve",                    "open" },
{ capabilities.valve.ID,                     "close",              "valve",                    "closed" },
{ capabilities.switchLevel.ID,               "setLevel",           "brightness",               "level" },
{ capabilities.windowShade.ID,               "open",               "cover_state",              "open" },
{ capabilities.windowShade.ID,               "close",              "cover_state",              "close" },
{ capabilities.windowShade.ID,               "pause",              "cover_state",              "stop" },
{ capabilities.windowShadeLevel.ID,          "setShadeLevel",      "cover_position",           "shadeLevel" },
{ capabilities.windowShadeTiltLevel.ID,      "setShadeTiltLevel",  "cover_tilt",               "level" },
{ capabilities.thermostatHeatingSetpoint.ID,  "setHeatingSetpoint", "current_heating_setpoint", "setpoint" },
{ capabilities.thermostatCoolingSetpoint.ID,  "setCoolingSetpoint", "current_cooling_setpoint", "setpoint" },
{ capabilities.thermostatMode.ID,            "setThermostatMode",  "system_mode",              "mode" },
{ capabilities.thermostatMode.ID,            "auto",               "system_mode",              "auto" },
{ capabilities.thermostatMode.ID,            "cool",               "system_mode",              "cool" },
{ capabilities.thermostatMode.ID,            "emergencyHeat",      "system_mode",              "emergency heat" },
{ capabilities.thermostatMode.ID,            "heat",               "system_mode",              "heat" },
{ capabilities.thermostatMode.ID,            "off",                "system_mode",              "off" },
{ capabilities.fanMode.ID,                   "setFanMode",         "fan_mode",                 "fanMode" },
{ capabilities.colorTemperature.ID,          "setColorTemperature", "color_temperature",        "temperature", true },
{ capabilities.colorControl.ID,              "setHue",             "color_hue",                "hue", true },
{ capabilities.colorControl.ID,              "setSaturation",      "color_saturation",         "saturation", true },
{ capabilities.colorControl.ID,              "setColor",           "color",                    function(command)
return command.args and command.args.color or nil
end, true },
}
local delayed_read_definitions = {
[capabilities.audioVolume.ID .. ":" .. capabilities.audioVolume.commands.setVolume.NAME] = {
"volume",
},
[capabilities.colorTemperature.ID .. ":" .. capabilities.colorTemperature.commands.setColorTemperature.NAME] = {
"color_temperature",
},
[capabilities.colorControl.ID .. ":" .. capabilities.colorControl.commands.setHue.NAME] = {
"color_hue",
},
[capabilities.colorControl.ID .. ":" .. capabilities.colorControl.commands.setSaturation.NAME] = {
"color_saturation",
},
[capabilities.colorControl.ID .. ":" .. capabilities.colorControl.commands.setColor.NAME] = {
"color_hue",
"color_saturation",
},
}
local function is_child_device(device)
return type(device) == "table" and (
device.network_type == device_lib.NETWORK_TYPE_CHILD or
type(device.parent_assigned_child_key) == "string"
)
end
local function schedule_unexpected_child_cleanup(driver, device)
if type(driver) ~= "table" or type(device) ~= "table" or type(driver.try_delete_device) ~= "function" then
return
end
if device.thread ~= nil and type(device.thread.call_with_delay) == "function" then
device.thread:call_with_delay(1, function()
driver:try_delete_device(device.id)
end, string.format("delete unexpected child %s", tostring(device.id)))
return
end
driver:try_delete_device(device.id)
end
local function send(device, command, name, value)
local preset = get_preset(device)
if preset == nil then
return false
end
local handled = false
if preset.datapoints then
handled = preset:send_named_mapping(device, name, value, {
component_id = command.component,
}) or handled
end
if preset.zcl_clusters then
handled = zcl.send_named_command(device, preset.zcl_clusters, name, value, {
component_id = command.component,
}) or handled
end
return handled
end
local function resolve_definition(device)
return registry.find(device:get_manufacturer(), device:get_model())
end
local function uses_zcl_on_off(device)
local preset = get_preset(device)
return preset ~= nil and preset.zcl_clusters ~= nil and zcl.has_cluster(preset.zcl_clusters, zcl.CLUSTER_ON_OFF)
end
local function resolve_component_endpoint(device, component_id)
if type(device) ~= "table" or type(device.get_endpoint_for_component_id) ~= "function" then
return 1
end
local endpoint = device:get_endpoint_for_component_id(component_id or "main")
if type(endpoint) == "table" then
endpoint = endpoint[1]
end
if type(endpoint) ~= "number" then
return 1
end
return endpoint
end
local function supports_ias_warning_device(device)
local preset = get_preset(device)
return preset ~= nil and preset.zcl_clusters ~= nil and zcl.has_cluster(preset.zcl_clusters, IAS_WARNING_DEVICE_CLUSTER)
end
local function emit_alarm_state(device, component_id, value)
local target_component = component_id or "main"
if type(device) ~= "table" or not device:supports_capability_by_id(capabilities.alarm.ID, target_component) then
return
end
local event = value == "off"
and capabilities.alarm.alarm.off()
or capabilities.alarm.alarm.siren()
device:emit_component_event({ id = target_component }, event)
end
local function send_ias_warning_command(device, component_id, warning_mode, strobe_enabled, siren_level, duration)
if not supports_ias_warning_device(device) then
return false
end
local siren_configuration = generated_clusters.IASWD.types.SirenConfiguration(0)
siren_configuration:set_warning_mode(warning_mode)
siren_configuration:set_strobe(strobe_enabled and 1 or 0)
siren_configuration:set_siren_level(siren_level)
local endpoint = resolve_component_endpoint(device, component_id)
local command = generated_clusters.IASWD.server.commands.StartWarning(
device,
siren_configuration,
data_types.Uint16(duration or 0),
data_types.Uint8(0),
generated_clusters.IASWD.types.IaswdLevel(strobe_enabled and IAS_WARNING_LEVEL_VERY_HIGH or IAS_WARNING_LEVEL_LOW)
)
device:send(command:to_endpoint(endpoint))
return true
end
local custom_capability_runtime = custom_capability_runtime_factory.create({
get_preset = get_preset,
send = send,
resolve_definition = resolve_definition,
})
local function configure_preset(driver, device, preset)
if preset == nil then
return
end
preset:start_configuration(device, driver)
if preset.zcl_clusters then
zcl.start_configuration(device, preset.zcl_clusters)
end
if type(preset.zcl_initial_writes) == "table" then
for _, item in ipairs(preset.zcl_initial_writes) do
zcl.send_named_command(device, preset.zcl_clusters, item.name, item.value)
end
end
end
local function start_preset_runtime(device, preset)
if preset and preset.zcl_clusters then
zcl.start_runtime(device, preset.zcl_clusters)
zcl.emit_power_polling_state(device, preset.zcl_clusters)
if zcl.emit_ir_state ~= nil then
zcl.emit_ir_state(device, preset)
end
if device.thread ~= nil and type(device.thread.call_with_delay) == "function" then
device.thread:call_with_delay(2, function()
zcl.emit_power_polling_state(device, preset.zcl_clusters)
if zcl.emit_ir_state ~= nil then
zcl.emit_ir_state(device, preset)
end
end, "zcl initial power polling state")
end
else
start_ef00_power_polling(device, preset)
end
end
local function refresh_runtime_metadata(device, definition, diagnose_bindings)
custom_capability_runtime.refresh_definitions(device)
if diagnose_bindings then
custom_capability_runtime.diagnose_bindings(device)
end
emit_button_metadata(device, definition)
custom_capability_runtime.emit_numeric_metadata(device, definition)
custom_capability_runtime.emit_enum_metadata(device, definition)
end
local function schedule_follow_up_reads(device, component_id, mapping_names, delay_s)
if type(mapping_names) ~= "table" or mapping_names[1] == nil or device.thread == nil or type(device.thread.call_with_delay) ~= "function" then
return
end
local preset = get_preset(device)
if preset == nil or preset.zcl_clusters == nil then
return
end
device.thread:call_with_delay(delay_s or 2, function()
for _, mapping_name in ipairs(mapping_names) do
zcl.read_named_attribute(device, preset.zcl_clusters, mapping_name, {
component_id = component_id,
})
end
end, string.format("zcl delayed read %s", tostring(component_id or "main")))
end
local function emit_ef00_switch_state(device, component_id, value)
local target_component = component_id or "main"
if type(device) ~= "table" or not device:supports_capability_by_id(capabilities.switch.ID, target_component) then
return
end
local event = value and capabilities.switch.switch.on() or capabilities.switch.switch.off()
device:emit_component_event({ id = target_component }, event)
end
local function schedule_ef00_state_request(device, delay_s, label)
if type(device) ~= "table" or device.thread == nil or type(device.thread.call_with_delay) ~= "function" then
return
end
device.thread:call_with_delay(delay_s, function()
local preset = get_preset(device)
if preset ~= nil and preset.datapoints ~= nil then
preset:send_state_request(device)
end
end, label or "ef00 delayed state request")
end
local function after_ef00_switch_command(device, command, value)
emit_ef00_switch_state(device, command and command.component or "main", value)
schedule_ef00_state_request(device, 1, "ef00 switch state read 1s")
schedule_ef00_state_request(device, 3, "ef00 switch state read 3s")
end
local function clamp_switch_level(value)
local numeric = tonumber(value)
if numeric == nil then
return nil
end
numeric = math.floor(numeric + 0.5)
if numeric < 0 then
return 0
end
if numeric > 100 then
return 100
end
return numeric
end
local function current_switch_level(device, component_id)
if type(device) ~= "table" or type(device.get_latest_state) ~= "function" then
return 0
end
local level = device:get_latest_state(component_id or "main", capabilities.switchLevel.ID, "level")
return clamp_switch_level(level) or 0
end
local function configured_minimum_switch_level(device, component_id)
local metadata = ef00_minimum_brightness_metadata
local target_component = component_id or "main"
if type(device) ~= "table" or type(metadata) ~= "table" then
return 0
end
if not device:supports_capability_by_id(metadata.capability_id, target_component) then
return 0
end
local raw_minimum_state = device:get_latest_state(
target_component,
metadata.capability_id,
metadata.attribute_name
)
local raw_minimum = tonumber(raw_minimum_state)
if raw_minimum == nil or raw_minimum <= 0 then
return 0
end
return clamp_switch_level(math.ceil(raw_minimum / 10)) or 0
end
local function emit_switch_level_state(device, component_id, level)
local target_component = component_id or "main"
if type(device) ~= "table" or not device:supports_capability_by_id(capabilities.switchLevel.ID, target_component) then
return
end
device:emit_component_event({ id = target_component }, capabilities.switchLevel.level(level))
end
local function handle_stateless_switch_level_step(device, command)
local component_id = command and command.component or "main"
local step_size = command and command.args and command.args.stepSize or nil
step_size = tonumber(step_size)
if step_size == nil then
return
end
step_size = math.floor(step_size + 0.5)
if step_size < -100 then
step_size = -100
elseif step_size > 100 then
step_size = 100
end
local target_level = clamp_switch_level(current_switch_level(device, component_id) + step_size)
if target_level == nil then
return
end
local minimum_level = configured_minimum_switch_level(device, component_id)
if target_level < minimum_level then
target_level = minimum_level
end
if target_level > 0 then
send(device, command, "switch", true)
end
local handled = send(device, command, "brightness", target_level)
if target_level == 0 then
handled = send(device, command, "switch", false) or handled
end
if handled then
emit_switch_level_state(device, component_id, target_level)
if target_level == 0 then
after_ef00_switch_command(device, command, false)
else
after_ef00_switch_command(device, command, true)
end
end
end
local function build_capability_handlers()
local handlers = {}
for _, def in ipairs(command_definitions) do
local cap_id, cmd_name, map_name, raw_value, turn_on_first = def[1], def[2], def[3], def[4], def[5]
if handlers[cap_id] == nil then
handlers[cap_id] = {}
end
handlers[cap_id][cmd_name] = function(_, device, command)
local value = raw_value
if type(raw_value) == "function" then
value = raw_value(command)
elseif type(raw_value) == "string" and command.args and command.args[raw_value] ~= nil then
value = command.args[raw_value]
end
if turn_on_first then
send(device, command, "switch", true)
end
local handled = send(device, command, map_name, value)
if handled then
local follow_up = delayed_read_definitions[cap_id .. ":" .. cmd_name]
if follow_up ~= nil then
schedule_follow_up_reads(device, command.component, follow_up, 2)
end
end
end
end
handlers[capabilities.switch.ID] = handlers[capabilities.switch.ID] or {}
handlers[capabilities.switch.ID][capabilities.switch.commands.on.NAME] = function(driver, device, command)
if uses_zcl_on_off(device) then
local preset = get_preset(device)
if preset ~= nil and preset.zcl_clusters ~= nil and zcl.begin_power_poll_burst ~= nil then
zcl.begin_power_poll_burst(device, preset.zcl_clusters)
end
return switch_default_on(driver, device, command)
end
if send(device, command, "switch", true) then
after_ef00_switch_command(device, command, true)
end
end
handlers[capabilities.switch.ID][capabilities.switch.commands.off.NAME] = function(driver, device, command)
if uses_zcl_on_off(device) then
return switch_default_off(driver, device, command)
end
if send(device, command, "switch", false) then
after_ef00_switch_command(device, command, false)
end
end
handlers[STATELESS_SWITCH_LEVEL_STEP_ID] = {
[STATELESS_SWITCH_LEVEL_STEP_COMMAND] = function(_, device, command)
handle_stateless_switch_level_step(device, command)
end,
}
handlers[capabilities.alarm.ID] = {
[capabilities.alarm.commands.off.NAME] = function(_, device, command)
if send_ias_warning_command(device, command.component, IAS_WARNING_MODE_STOP, false, IAS_WARNING_LEVEL_LOW, 0) then
emit_alarm_state(device, command.component, "off")
end
end,
[capabilities.alarm.commands.siren.NAME] = function(_, device, command)
if send_ias_warning_command(device, command.component, IAS_WARNING_MODE_EMERGENCY, false, IAS_WARNING_LEVEL_VERY_HIGH, DEFAULT_IAS_WARNING_DURATION) then
emit_alarm_state(device, command.component, "siren")
end
end,
[capabilities.alarm.commands.strobe.NAME] = function(_, device, command)
if send_ias_warning_command(device, command.component, IAS_WARNING_MODE_EMERGENCY, true, IAS_WARNING_LEVEL_LOW, DEFAULT_IAS_WARNING_DURATION) then
emit_alarm_state(device, command.component, "siren")
end
end,
[capabilities.alarm.commands.both.NAME] = function(_, device, command)
if send_ias_warning_command(device, command.component, IAS_WARNING_MODE_EMERGENCY, true, IAS_WARNING_LEVEL_VERY_HIGH, DEFAULT_IAS_WARNING_DURATION) then
emit_alarm_state(device, command.component, "siren")
end
end,
}
handlers[capabilities.windowShadePreset.ID] = {
[capabilities.windowShadePreset.commands.setPresetPosition.NAME] = function(_, device, command)
local level = command.args and command.args.position or nil
if type(level) ~= "number" then
return
end
device:set_field(shade_preset_field_key(command.component), level, { persist = true })
device:emit_component_event({ id = command.component }, capabilities.windowShadePreset.position(level))
end,
[capabilities.windowShadePreset.commands.presetPosition.NAME] = function(_, device, command)
local level = resolve_window_shade_preset_level(device, command.component)
send(device, command, "cover_position", level)
end,
}
handlers[capabilities.refresh.ID] = {
[capabilities.refresh.commands.refresh.NAME] = function(_, device)
local preset = get_preset(device)
if preset == nil then
return
end
if preset.datapoints then
preset:send_state_request(device)
end
if preset.zcl_clusters then
zcl.read_all_attributes(device, preset.zcl_clusters)
end
end,
}
custom_capability_runtime.register_handlers(handlers)
if power_poll_interval_metadata ~= nil then
handlers[power_poll_interval_metadata.capability_id] = handlers[power_poll_interval_metadata.capability_id] or {}
handlers[power_poll_interval_metadata.capability_id][power_poll_interval_metadata.command_name] = function(_, device, command)
local preset = get_preset(device)
if preset == nil then
return
end
local value = command.args and command.args[power_poll_interval_metadata.argument_name] or nil
if preset.zcl_clusters ~= nil then
zcl.set_power_poll_interval(device, preset.zcl_clusters, value)
return
end
if not supports_ef00_power_polling(device, preset) then
return
end
local interval = clamp_ef00_power_poll_interval(value)
if interval == nil then
return
end
device:set_field(EF00_POWER_POLL_INTERVAL_FIELD, interval, { persist = true })
start_ef00_power_polling(device, preset)
end
end
if learn_ir_code_metadata ~= nil then
handlers[learn_ir_code_metadata.capability_id] = handlers[learn_ir_code_metadata.capability_id] or {}
handlers[learn_ir_code_metadata.capability_id][learn_ir_code_metadata.command_name] = function(_, device, command)
local preset = get_preset(device)
if preset == nil or preset.ir_controller ~= true then
return
end
local value = command.args and command.args[learn_ir_code_metadata.argument_name] or nil
if value == "start" then
zcl.start_ir_learning(device, preset)
elseif value == "stop" then
zcl.stop_ir_learning(device, preset)
end
end
end
if ir_code_to_send_metadata ~= nil then
handlers[ir_code_to_send_metadata.capability_id] = handlers[ir_code_to_send_metadata.capability_id] or {}
handlers[ir_code_to_send_metadata.capability_id][ir_code_to_send_metadata.command_name] = function(_, device, command)
local preset = get_preset(device)
if preset == nil or preset.ir_controller ~= true then
return
end
local args = command.args or {}
local value = args[ir_code_to_send_metadata.argument_name]
if type(value) ~= "string" and type(args.value) == "string" then
value = args.value
end
if type(value) ~= "string" or value == "" then
return
end
zcl.send_ir_code(device, preset, value)
end
end
return handlers
end
local driver_template = {
supported_capabilities = {},
zigbee_handlers = {
cluster = build_cluster_handlers(),
global = zcl.build_zigbee_global_handlers(get_preset),
attr = zcl.build_zigbee_attr_handlers(get_preset),
},
lifecycle_handlers = {
init = function(driver, device)
if is_child_device(device) then
schedule_unexpected_child_cleanup(driver, device)
return
end
local definition = resolve_definition(device)
if definition and definition.profile and device.profile.id ~= definition.profile then
device:try_update_metadata({ profile = definition.profile })
end
component_mapping.apply(device, definition)
refresh_runtime_metadata(device, definition, true)
custom_capability_runtime.emit_driver_message(device, "Custom motion controls initialized.")
local preset = get_preset(device)
start_preset_runtime(device, preset)
battery_refresh.start_daily(device)
emit_window_shade_preset_state(device)
custom_capability_runtime.maybe_request_initial_custom_state(device, preset)
custom_capability_runtime.emit_placeholder_states(device, definition)
end,
doConfigure = function(driver, device)
configure_preset(driver, device, get_preset(device))
end,
infoChanged = function(driver, device, _, args)
if not args.old_st_store then
return
end
local definition = resolve_definition(device)
local profile_changed = device.profile.id ~= args.old_st_store.profile.id
if profile_changed then
component_mapping.apply(device, definition)
configure_preset(driver, device, get_preset(device))
end
local preset = get_preset(device)
if preset then
preset:apply_preferences_changed(device, args.old_st_store.preferences)
if preset.zcl_clusters then
zcl.emit_power_polling_state(device, preset.zcl_clusters)
else
emit_ef00_power_polling_state(device, preset)
end
end
battery_refresh.start_daily(device)
emit_window_shade_preset_state(device)
refresh_runtime_metadata(device, definition, profile_changed)
end,
},
capability_handlers = build_capability_handlers(),
health_check = false,
}
local ZigbeeDriver = require "st.zigbee"
ZigbeeDriver("tuya-universal", driver_template):run()
