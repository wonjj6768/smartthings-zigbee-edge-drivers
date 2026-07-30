local capabilities = require "st.capabilities"
local custom_capabilities = require "core.custom_capabilities"
local battery_refresh = require "app.battery_refresh"
local log = require "log"
local emit = {}
local last_power_response_time_definition = custom_capabilities.by_emit_name.last_power_response_time
local LAST_POWER_RESPONSE_AT_FIELD = "_tuya_last_power_response_at"
local LAST_POWER_RESPONSE_WAITING_TEXT = "waiting"
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
local function resolve_capability_attribute(capability_id, attribute_name)
local capability = capabilities[capability_id]
local attribute = capability and capability[attribute_name] or nil
if not is_callable(attribute) and capability and type(capability.attributes) == "table" then
attribute = capability.attributes[attribute_name]
end
return capability, attribute
end
local function resolve_numeric_value_limit(attribute, key)
if type(attribute) ~= "table" or type(attribute.schema) ~= "table" then
return nil
end
local schema = attribute.schema
if type(schema.properties) ~= "table" or type(schema.properties.value) ~= "table" then
return nil
end
local value_schema = schema.properties.value
local limit_key = key or "maximum"
if type(value_schema[limit_key]) == "number" then
return value_schema[limit_key]
end
return nil
end
local function supports_capability(device, capability_id)
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
local function format_power_response_time(epoch)
if type(epoch) ~= "number" or epoch <= 0 then
return LAST_POWER_RESPONSE_WAITING_TEXT
end
return os.date("%Y-%m-%d %H:%M:%S", epoch)
end
local function last_power_response_event(device)
local definition = last_power_response_time_definition
if type(definition) ~= "table" or not supports_capability(device, definition.capability_id) then
return nil
end
local _, attribute = resolve_capability_attribute(definition.capability_id, definition.attribute_name)
if not is_callable(attribute) then
return nil
end
local epoch = os.time()
if type(epoch) == "number" then
device:set_field(LAST_POWER_RESPONSE_AT_FIELD, epoch, { persist = false })
end
return attribute({
value = format_power_response_time(device:get_field(LAST_POWER_RESPONSE_AT_FIELD)),
})
end
local function log_missing_custom_binding(device, definition, reason)
if type(device) ~= "table" or type(definition) ~= "table" then
return
end
local key = string.format("__custom_emit_missing__:%s:%s", definition.capability_id or "unknown", reason or "unknown")
if device.get_field ~= nil and device.set_field ~= nil and device:get_field(key) then
return
end
if device.set_field ~= nil then
device:set_field(key, true, { persist = false })
end
log.error(string.format(
"[%s] Custom capability emit binding missing (%s): %s.%s",
device.label or device.id or "device",
reason or "unknown",
definition.capability_id or "unknown",
definition.attribute_name or "unknown"
))
end
function emit.all(...)
local emitters = { ... }
return function(device, value, dp_info, mapping_context)
local events = {}
for _, emitter in ipairs(emitters) do
if type(emitter) == "function" then
local event = emitter(device, value, dp_info, mapping_context)
if type(event) == "table" and event[1] ~= nil then
for _, item in ipairs(event) do
events[#events + 1] = item
end
elseif event ~= nil then
events[#events + 1] = event
end
end
end
if #events > 0 then
return events
end
end
end
function emit.switch()
return function(_, value)
if value then
return capabilities.switch.switch.on()
else
return capabilities.switch.switch.off()
end
end
end
function emit.contact()
return function(_, value)
if value then
return capabilities.contactSensor.contact.open()
else
return capabilities.contactSensor.contact.closed()
end
end
end
function emit.motion()
return function(_, value)
if value then
return capabilities.motionSensor.motion.active()
else
return capabilities.motionSensor.motion.inactive()
end
end
end
function emit.water()
return function(_, value)
if value then
return capabilities.waterSensor.water.wet()
else
return capabilities.waterSensor.water.dry()
end
end
end
function emit.smoke()
return function(_, value)
if value then
return capabilities.smokeDetector.smoke.detected()
else
return capabilities.smokeDetector.smoke.clear()
end
end
end
function emit.carbon_monoxide()
return function(_, value)
if value then
return capabilities.carbonMonoxideDetector.carbonMonoxide.detected()
else
return capabilities.carbonMonoxideDetector.carbonMonoxide.clear()
end
end
end
function emit.tamper()
return function(_, value)
if value then
return capabilities.tamperAlert.tamper.detected()
else
return capabilities.tamperAlert.tamper.clear()
end
end
end
function emit.presence()
return function(_, value)
if value then
return capabilities.presenceSensor.presence.present()
else
return capabilities.presenceSensor.presence.not_present()
end
end
end
function emit.gas()
return function(_, value)
if value then
return capabilities.gasDetector.gas.detected()
else
return capabilities.gasDetector.gas.clear()
end
end
end
function emit.valve()
return function(_, value)
if value ~= nil then
return capabilities.valve.valve(value)
end
end
end
function emit.occupancy()
return function(_, value)
if value then
return capabilities.occupancySensor.occupancy.occupied()
else
return capabilities.occupancySensor.occupancy.unoccupied()
end
end
end
function emit.acceleration()
return function(_, value)
if value then
return capabilities.accelerationSensor.acceleration.active()
else
return capabilities.accelerationSensor.acceleration.inactive()
end
end
end
function emit.alarm()
return function(_, value)
if value then
return capabilities.alarm.alarm.siren()
else
return capabilities.alarm.alarm.off()
end
end
end
function emit.temperature(unit)
unit = unit or "C"
return function(_, value)
if value ~= nil then
return capabilities.temperatureMeasurement.temperature({ value = value, unit = unit })
end
end
end
function emit.humidity()
return function(_, value)
if value ~= nil then
return capabilities.relativeHumidityMeasurement.humidity({ value = value })
end
end
end
function emit.battery()
return function(device, value)
if value ~= nil then
battery_refresh.note_report(device)
local clamped = value < 0 and 0 or (value > 100 and 100 or value)
local rounded = math.floor(clamped + 0.5)
return capabilities.battery.battery(rounded)
end
end
end
function emit.illuminance()
return function(_, value)
if value ~= nil then
return capabilities.illuminanceMeasurement.illuminance({ value = value })
end
end
end
function emit.carbon_monoxide_level()
return function(_, value)
if value ~= nil then
return capabilities.carbonMonoxideMeasurement.carbonMonoxideLevel({ value = value, unit = "ppm" })
end
end
end
function emit.atmospheric_pressure()
return function(_, value)
if value ~= nil then
return capabilities.atmosphericPressureMeasurement.atmosphericPressure({ value = value, unit = "kPa" })
end
end
end
function emit.co2()
return function(_, value)
if value ~= nil then
return capabilities.carbonDioxideMeasurement.carbonDioxide({ value = value, unit = "ppm" })
end
end
end
function emit.voc(unit)
unit = unit or "ppb"
return function(_, value)
if value ~= nil then
return capabilities.tvocMeasurement.tvocLevel({ value = value, unit = unit })
end
end
end
function emit.formaldehyde(unit)
unit = unit or "mg/m^3"
return function(_, value)
if value ~= nil then
return capabilities.formaldehydeMeasurement.formaldehydeLevel({ value = value, unit = unit })
end
end
end
function emit.pm25()
return function(_, value)
if value ~= nil then
return capabilities.fineDustSensor.fineDustLevel({ value = value })
end
end
end
function emit.power()
return function(device, value)
if value ~= nil then
local power_event = capabilities.powerMeter.power({ value = value, unit = "W" })
local response_event = last_power_response_event(device)
if response_event ~= nil then
return { power_event, response_event }
end
return power_event
end
end
end
function emit.energy()
return function(_, value)
if value ~= nil then
return capabilities.energyMeter.energy({ value = value, unit = "kWh" })
end
end
end
function emit.voltage()
return function(_, value)
if value ~= nil then
return capabilities.voltageMeasurement.voltage({ value = value, unit = "V" })
end
end
end
function emit.current()
return function(_, value)
if value ~= nil then
return capabilities.currentMeasurement.current({ value = value, unit = "A" })
end
end
end
function emit.audio_volume()
return function(_, value)
if value ~= nil then
local clamped = value < 0 and 0 or (value > 100 and 100 or value)
return capabilities.audioVolume.volume(math.floor(clamped + 0.5))
end
end
end
function emit.level()
return function(_, value)
if value ~= nil then
local clamped = value < 0 and 0 or (value > 100 and 100 or value)
return capabilities.switchLevel.level(clamped)
end
end
end
function emit.shade_level()
return function(_, value)
if value ~= nil then
return capabilities.windowShadeLevel.shadeLevel(value)
end
end
end
function emit.shade_tilt_level()
return function(_, value)
if value ~= nil then
return capabilities.windowShadeTiltLevel.shadeTiltLevel(value)
end
end
end
function emit.shade_preset_position()
return function(_, value)
if value ~= nil then
return capabilities.windowShadePreset.position(value)
end
end
end
function emit.heating_setpoint(unit)
unit = unit or "C"
return function(_, value)
if value ~= nil then
return capabilities.thermostatHeatingSetpoint.heatingSetpoint({ value = value, unit = unit })
end
end
end
function emit.cooling_setpoint(unit)
unit = unit or "C"
return function(_, value)
if value ~= nil then
return capabilities.thermostatCoolingSetpoint.coolingSetpoint({ value = value, unit = unit })
end
end
end
function emit.soil_moisture()
return function(_, value)
if value ~= nil then
local clamped = value < 0 and 0 or (value > 100 and 100 or value)
return capabilities["concertmirror08464.soilMoisture"].soilMoisture({ value = clamped, unit = "%" })
end
end
end
function emit.probe_temperature(unit)
unit = unit or "C"
return function(_, value)
if value ~= nil then
return capabilities["connectamber53538.probeTemperature"].temperature({ value = value, unit = unit })
end
end
end
function emit.soil_ec()
return function(_, value)
if value ~= nil then
return capabilities["concertmirror08464.soilEc"].soilEc({ value = value, unit = "uS/cm" })
end
end
end
local function emit_numeric_custom(definition)
return function(device, value)
if value == nil then
return
end
local clamped = value
local minimum = definition.event_minimum or (definition.default_range and definition.default_range.minimum or nil)
local maximum = definition.event_maximum or (definition.default_range and definition.default_range.maximum or nil)
local _, attribute_fn = resolve_capability_attribute(definition.capability_id, definition.attribute_name)
local schema_minimum = resolve_numeric_value_limit(attribute_fn, "minimum")
local schema_maximum = resolve_numeric_value_limit(attribute_fn)
if type(schema_minimum) == "number" then
if type(minimum) ~= "number" or schema_minimum > minimum then
minimum = schema_minimum
end
end
if type(schema_maximum) == "number" then
if type(maximum) ~= "number" or schema_maximum < maximum then
maximum = schema_maximum
end
end
if type(minimum) == "number" and clamped < minimum then
clamped = minimum
end
if type(maximum) == "number" and clamped > maximum then
clamped = maximum
end
local capability = capabilities[definition.capability_id]
if not is_callable(attribute_fn) and capability and type(capability.attributes) == "table" then
attribute_fn = capability.attributes[definition.attribute_name]
end
if not is_callable(attribute_fn) then
if capability == nil then
log_missing_custom_binding(device, definition, "capability")
else
log_missing_custom_binding(device, definition, "attribute")
end
return
end
local unit = definition.event_unit or (definition.default_range and definition.default_range.unit or nil)
if unit ~= nil then
return attribute_fn({ value = clamped, unit = unit })
end
return attribute_fn({ value = clamped })
end
end
local function emit_enum_custom(definition)
return function(device, value)
if type(value) == "boolean" and type(definition.supported_values) == "table" then
local has_on = false
local has_off = false
for _, supported in ipairs(definition.supported_values) do
if supported == "on" then
has_on = true
elseif supported == "off" then
has_off = true
end
end
if has_on and has_off then
value = value and "on" or "off"
end
end
if type(value) ~= "string" or value == "" then
return
end
local capability, attribute_fn = resolve_capability_attribute(definition.capability_id, definition.attribute_name)
if not is_callable(attribute_fn) then
if capability == nil then
log_missing_custom_binding(device, definition, "capability")
else
log_missing_custom_binding(device, definition, "attribute")
end
return
end
return attribute_fn({ value = value })
end
end
local function emit_text_custom(definition)
return function(device, value)
if type(value) ~= "string" or value == "" then
return
end
local capability, attribute_fn = resolve_capability_attribute(definition.capability_id, definition.attribute_name)
if not is_callable(attribute_fn) then
if capability == nil then
log_missing_custom_binding(device, definition, "capability")
else
log_missing_custom_binding(device, definition, "attribute")
end
return
end
local maximum_length = definition.maximum_length or 512
local message = #value > maximum_length and value:sub(1, maximum_length) or value
return attribute_fn({ value = message })
end
end
for _, definition in ipairs(custom_capabilities.numeric) do
emit[definition.emit_name] = function()
return emit_numeric_custom(definition)
end
end
for _, definition in ipairs(custom_capabilities.enum) do
emit[definition.emit_name] = function()
return emit_enum_custom(definition)
end
end
for _, definition in ipairs(custom_capabilities.text) do
emit[definition.emit_name] = function()
return emit_text_custom(definition)
end
end
function emit.driver_message()
return function(device, value)
if type(value) == "string" and value ~= "" then
local definition = custom_capabilities.driver_message
local capability, attribute_fn = resolve_capability_attribute(definition.capability_id, definition.attribute_name)
if not is_callable(attribute_fn) then
if capability == nil then
log_missing_custom_binding(device, definition, "capability")
else
log_missing_custom_binding(device, definition, "attribute")
end
return
end
local maximum_length = definition.maximum_length or 512
local message = #value > maximum_length and value:sub(1, maximum_length) or value
return attribute_fn({ value = message })
end
end
end
function emit.thermostat_mode()
return function(_, value)
if value ~= nil then
return capabilities.thermostatMode.thermostatMode(value)
end
end
end
function emit.thermostat_operating_state()
return function(_, value)
if value ~= nil then
return capabilities.thermostatOperatingState.thermostatOperatingState(value)
end
end
end
function emit.fan_mode()
return function(_, value)
if value ~= nil then
return capabilities.fanMode.fanMode(value)
end
end
end
function emit.color_temperature()
return function(_, value)
if value ~= nil then
local clamped = value < 1 and 1 or (value > 30000 and 30000 or value)
return capabilities.colorTemperature.colorTemperature(clamped)
end
end
end
function emit.color_hue()
return function(_, value)
if value ~= nil then
local clamped = value < 0 and 0 or (value > 100 and 100 or value)
return capabilities.colorControl.hue(clamped)
end
end
end
function emit.color_saturation()
return function(_, value)
if value ~= nil then
local clamped = value < 0 and 0 or (value > 100 and 100 or value)
return capabilities.colorControl.saturation(clamped)
end
end
end
function emit.shade_state()
return function(_, value)
if value ~= nil then
return capabilities.windowShade.windowShade(value)
end
end
end
function emit.value(capability_attr, unit)
return function(_, value)
if value ~= nil then
if unit then
return capability_attr({ value = value, unit = unit })
else
return capability_attr(value)
end
end
end
end
function emit.binary(capability_attr, true_val, false_val)
return function(_, value)
if value then
return capability_attr(true_val)
else
return capability_attr(false_val)
end
end
end
return emit
