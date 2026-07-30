local capabilities = require "st.capabilities"
local custom_capabilities = require "core.custom_capabilities"
local log = require "log"
local binding = {}
local MAIN_COMPONENT = "main"
local REFRESHED_DEFINITIONS = {}
local function device_name(device)
if type(device) ~= "table" then
return "device"
end
return device.label or device.id or "device"
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
local function supports_component_capability(device, capability_id, component_id)
if type(device) ~= "table" or type(capability_id) ~= "string" or capability_id == "" then
return false
end
component_id = component_id or MAIN_COMPONENT
if type(device.supports_capability_by_id) == "function" then
return device:supports_capability_by_id(capability_id, component_id)
end
local components = device.profile and device.profile.components or nil
local component = type(components) == "table" and components[component_id] or nil
local capabilities_map = component and component.capabilities or nil
return type(capabilities_map) == "table" and capabilities_map[capability_id] ~= nil
end
local function emit_event(device, component_id, event)
component_id = component_id or MAIN_COMPONENT
if component_id == MAIN_COMPONENT then
device:emit_event(event)
else
device:emit_component_event({ id = component_id }, event)
end
end
local function resolve_metadata(reference)
if type(reference) == "table" then
return reference
end
if type(reference) ~= "string" or reference == "" then
return nil
end
return custom_capabilities.by_emit_name[reference] or custom_capabilities.by_capability_id[reference]
end
local function ensure_definition_loaded(capability_id)
if type(capability_id) ~= "string" or capability_id == "" then
return false
end
if REFRESHED_DEFINITIONS[capability_id] == true then
return true
end
local ok, err = pcall(capabilities.get_capability_definition, capability_id, 1, true)
if not ok then
log.warn(string.format("Failed to refresh capability definition for %s: %s", capability_id, tostring(err)))
return false
end
REFRESHED_DEFINITIONS[capability_id] = true
return true
end
local function resolve_attribute(metadata, attribute_name)
if type(metadata) ~= "table" then
return nil, nil
end
ensure_definition_loaded(metadata.capability_id)
local capability = capabilities[metadata.capability_id]
local attribute = capability and capability[attribute_name] or nil
if not is_callable(attribute) and capability and type(capability.attributes) == "table" then
attribute = capability.attributes[attribute_name]
end
return capability, attribute
end
local function log_missing_binding(device, metadata, reason)
if type(device) ~= "table" or type(metadata) ~= "table" then
return
end
local key = string.format("__custom_binding_missing__:%s:%s", metadata.capability_id or "unknown", reason or "unknown")
if type(device.get_field) == "function" and device:get_field(key) then
return
end
if type(device.set_field) == "function" then
device:set_field(key, true, { persist = false })
end
log.warn(string.format(
"[%s] Custom capability binding missing (%s): %s.%s",
device_name(device),
reason or "unknown",
metadata.capability_id or "unknown",
metadata.attribute_name or "unknown"
))
end
local function build_payload(metadata, value, options)
options = options or {}
if metadata.kind == "numeric" then
local payload = { value = value }
local unit = options.unit
if type(unit) ~= "string" or unit == "" then
unit = metadata.event_unit or (metadata.default_range and metadata.default_range.unit or nil)
end
if type(unit) == "string" and unit ~= "" then
payload.unit = unit
end
return payload
end
return { value = value }
end
function binding.supports(device, reference, component_id)
local metadata = resolve_metadata(reference)
return metadata ~= nil and supports_component_capability(device, metadata.capability_id, component_id)
end
function binding.emit_state(device, component_id, reference, value, options)
local metadata = resolve_metadata(reference)
if metadata == nil or value == nil then
return false
end
component_id = component_id or MAIN_COMPONENT
if not supports_component_capability(device, metadata.capability_id, component_id) then
return false
end
if metadata.kind == "enum" and (type(value) ~= "string" or value == "") then
return false
end
if metadata.kind == "text" and type(value) ~= "string" then
return false
end
local capability, attribute = resolve_attribute(metadata, metadata.attribute_name)
if not is_callable(attribute) then
if capability == nil then
log_missing_binding(device, metadata, "capability")
else
log_missing_binding(device, metadata, "attribute")
end
return false
end
emit_event(device, component_id, attribute(build_payload(metadata, value, options)))
return true
end
return binding
