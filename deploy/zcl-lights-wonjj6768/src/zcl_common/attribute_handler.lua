local function load_attribute_handler(zcl)
local battery_refresh = require "app.battery_refresh"
local function apply_scale(value, scale)
if value == nil or scale == nil or scale == 1 then
return value
end
if type(value) == "number" and type(scale) == "number" and scale ~= 0 then
return value / scale
end
return value
end
local function apply_converter(value, fallback_value, meta, device, mapping_context, mapping)
if meta.from_device ~= nil then
return meta.from_device(value, device, mapping_context, mapping)
end
return fallback_value
end
local function base_type_name(meta)
local attribute_def = meta and meta.attribute_def or nil
local base_type = attribute_def and attribute_def.base_type or nil
return type(base_type) == "table" and base_type.NAME or nil
end
local function is_scalar_base_type(name)
if type(name) ~= "string" then
return false
end
return name == "Boolean" or
name == "SemiPrecisionFloat" or
name == "SinglePrecisionFloat" or
name == "DoublePrecisionFloat" or
name == "TimeOfDay" or
name == "Date" or
name == "UtcTime" or
name == "IeeeAddress" or
name == "SecurityKey" or
name:match("^Uint%d+$") ~= nil or
name:match("^Int%d+$") ~= nil or
name:match("String$") ~= nil
end
local function should_prefer_typed_value(raw_value, meta, mapping_context)
local typed_value = mapping_context.typed_value
if typed_value == nil or typed_value == raw_value or type(typed_value) ~= "table" then
return false
end
if meta.prefer_typed_value then
return true
end
if not meta.custom_from_device then
return false
end
local type_name = base_type_name(meta)
if type_name ~= nil then
return not is_scalar_base_type(type_name)
end
return type(raw_value) ~= "number" and type(raw_value) ~= "boolean" and type(raw_value) ~= "string"
end
local function transform_value(raw_value, meta, device, mapping_context, mapping)
local scaled_value = zcl.scale_mapping_value and
zcl.scale_mapping_value(device, mapping, raw_value, meta, mapping_context) or
apply_scale(raw_value, meta.scale)
mapping_context.scaled_value = scaled_value
local converter_value = should_prefer_typed_value(raw_value, meta, mapping_context) and
mapping_context.typed_value or
scaled_value
return apply_converter(converter_value, scaled_value, meta, device, mapping_context, mapping)
end
local function emit_event(device, event, mapping_context)
if event == nil then
return
end
battery_refresh.maybe_schedule_after_event(device, event)
if mapping_context.component ~= nil and type(device.emit_component_event) == "function" then
device:emit_component_event(mapping_context.component, event)
return
end
if mapping_context.endpoint ~= nil and type(device.emit_event_for_endpoint) == "function" then
device:emit_event_for_endpoint(mapping_context.endpoint, event)
return
end
device:emit_event(event)
end
local function emit_events(device, events, mapping_context)
if events == nil then
return
end
if type(events) == "table" and events[1] ~= nil then
for _, event in ipairs(events) do
emit_event(device, event, mapping_context)
end
return
end
emit_event(device, events, mapping_context)
end
local function extract_source_endpoint(message)
if type(message) ~= "table" then
return nil
end
local endpoint = message.address_header and
message.address_header.src_endpoint and
message.address_header.src_endpoint.value or nil
return zcl.normalize_endpoint(endpoint)
end
local function extract_mfg_code(message)
if type(message) ~= "table" then
return nil
end
local zcl_header = message.body and message.body.zcl_header or nil
local frame_ctrl = zcl_header and zcl_header.frame_ctrl or nil
if frame_ctrl == nil or type(frame_ctrl.is_mfg_specific_set) ~= "function" or not frame_ctrl:is_mfg_specific_set() then
return nil
end
local mfg_code = zcl_header.mfg_code and zcl_header.mfg_code.value or nil
return type(mfg_code) == "number" and mfg_code or nil
end
local function extract_raw_attribute_value(value)
if type(value) == "table" and value.value ~= nil then
return value.value
end
return value
end
local function apply_single_mapping(device, mapping, raw_value, attribute_info)
if mapping == nil then
return nil
end
local meta = zcl.mapping_meta(mapping)
if meta == nil or meta.write_only then
return nil
end
local mapping_context = zcl.build_mapping_context(device, mapping, attribute_info, raw_value)
mapping_context.raw_value = raw_value
mapping_context.typed_value = attribute_info and attribute_info.typed_value or raw_value
local value = transform_value(raw_value, meta, device, mapping_context, mapping)
if value == nil then
return nil
end
mapping_context.value = value
if zcl.handle_metering_value ~= nil then
zcl.handle_metering_value(device, mapping, value, meta, mapping_context)
end
if zcl.handle_switch_state ~= nil and meta.cluster_id == zcl.CLUSTER_ON_OFF and meta.attribute_id == zcl.ATTR_ON_OFF then
zcl.handle_switch_state(device, mapping_context.zcl_clusters or nil, value)
end
if meta.handler ~= nil then
meta.handler(device, value, mapping_context, mapping)
end
if meta.emit ~= nil then
emit_events(device, meta.emit(device, value, mapping_context, mapping), mapping_context)
end
return value
end
function zcl.apply_attribute(device, zcl_clusters, cluster_id, attribute_id, raw_value, attribute_info)
if cluster_id == 0x0001 and (attribute_id == 0x0020 or attribute_id == 0x0021) then
battery_refresh.note_report(device)
end
local context = attribute_info or {}
local mappings = zcl.find_mappings(zcl_clusters, cluster_id, attribute_id, device, context)
if mappings[1] == nil then
return false
end
local applied = false
for _, mapping in ipairs(mappings) do
if apply_single_mapping(device, mapping, raw_value, context) ~= nil then
applied = true
end
end
return applied
end
function zcl.build_zigbee_attr_handlers(get_preset)
local function handler_factory(cluster_id, attribute_id)
return function(_, device, value, zb_rx)
if cluster_id == 0x0001 and (attribute_id == 0x0020 or attribute_id == 0x0021) then
battery_refresh.note_report(device)
end
local preset = get_preset(device)
if preset and preset.zcl_clusters then
local src_endpoint = extract_source_endpoint(zb_rx)
local mfg_code = extract_mfg_code(zb_rx)
local raw_value = extract_raw_attribute_value(value)
local attribute_info = {
cluster_id = cluster_id,
attribute_id = attribute_id,
zb_rx = zb_rx,
src_endpoint = src_endpoint,
endpoint = src_endpoint,
mfg_code = mfg_code,
typed_value = value,
zcl_clusters = preset.zcl_clusters,
}
zcl.handle_internal_attribute(device, cluster_id, attribute_id, value, attribute_info)
zcl.apply_attribute(device, preset.zcl_clusters, cluster_id, attribute_id, raw_value, attribute_info)
end
end
end
return zcl.build_attribute_handlers(handler_factory)
end
end
return load_attribute_handler
