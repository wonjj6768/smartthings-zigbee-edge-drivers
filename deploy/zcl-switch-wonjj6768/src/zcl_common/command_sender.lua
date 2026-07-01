local function load_command_sender(zcl)
local cluster_base = require "st.zigbee.cluster_base"
local data_types = require "st.zigbee.data_types"
local messages = require "st.zigbee.messages"
local zigbee_constants = require "st.zigbee.constants"
local zcl_clusters = require "st.zigbee.zcl.clusters"
local zcl_messages = require "st.zigbee.zcl"
local FrameCtrl = require "st.zigbee.zcl.frame_ctrl"
local generic_body = require "st.zigbee.generic_body"
local log = require "log"
local default_sender_key = "__default"
local sender_registry = {}
local function send_request(device, request, endpoint)
if endpoint ~= nil and type(request.to_endpoint) == "function" then
request = request:to_endpoint(endpoint)
end
device:send(request)
return true
end
local function send_cluster_specific_command(device, cluster_id, command_id, payload, endpoint, direction, mfg_code)
local frame_ctrl = FrameCtrl(0x00)
frame_ctrl:set_cluster_specific()
if direction == "client" then
frame_ctrl:set_direction_client()
end
if mfg_code ~= nil then
frame_ctrl:set_mfg_specific()
end
local zcl_header = {
cmd = data_types.ZCLCommandId(command_id),
frame_ctrl = frame_ctrl,
}
if mfg_code ~= nil then
zcl_header.mfg_code = data_types.Uint16(mfg_code)
end
return send_request(
device,
messages.ZigbeeMessageTx({
address_header = messages.AddressHeader(
zigbee_constants.HUB.ADDR,
zigbee_constants.HUB.ENDPOINT,
device:get_short_address(),
device:get_endpoint(cluster_id),
zigbee_constants.HA_PROFILE_ID,
cluster_id
),
body = zcl_messages.ZclMessageBody({
zcl_header = zcl_messages.ZclHeader(zcl_header),
zcl_body = generic_body.GenericBody(payload or ""),
}),
}),
endpoint
)
end
local function send_cluster_command(device, cluster_id, command_id, payload, endpoint, direction)
return send_cluster_specific_command(device, cluster_id, command_id, payload, endpoint, direction, nil)
end
local function send_manufacturer_specific_command(device, cluster_id, command_id, mfg_code, payload, endpoint, direction)
return send_cluster_specific_command(device, cluster_id, command_id, payload, endpoint, direction, mfg_code)
end
local function write_attribute(device, cluster_id, attribute_id, value, write_type, endpoint)
return send_request(
device,
cluster_base.write_attribute(
device,
data_types.ClusterId(cluster_id),
data_types.AttributeId(attribute_id),
write_type(value)
),
endpoint
)
end
local function read_manufacturer_specific_attribute(device, cluster_id, attribute_id, mfg_code, endpoint)
return send_request(
device,
cluster_base.read_manufacturer_specific_attribute(
device,
cluster_id,
attribute_id,
mfg_code
),
endpoint
)
end
local function write_manufacturer_specific_attribute(device, cluster_id, attribute_id, mfg_code, value, write_type, endpoint)
return send_request(
device,
cluster_base.write_manufacturer_specific_attribute(
device,
cluster_id,
attribute_id,
mfg_code,
write_type,
value
),
endpoint
)
end
local function read_generated_attribute(device, attribute_def, endpoint)
return send_request(device, attribute_def:read(device), endpoint)
end
local function write_generated_attribute(device, attribute_def, value, endpoint)
return send_request(device, attribute_def:write(device, attribute_def(value)), endpoint)
end
local function read_plain_attribute(device, cluster_id, attribute_id, endpoint)
return send_request(
device,
cluster_base.read_attribute(device, data_types.ClusterId(cluster_id), data_types.AttributeId(attribute_id)),
endpoint
)
end
local function clamp_integer(value, min_value, max_value)
return math.max(min_value, math.min(max_value, math.floor(value)))
end
local function encode_uint16_le(value)
return string.char(bit32.band(value, 0xFF))
.. string.char(bit32.rshift(bit32.band(value, 0xFF00), 8))
end
local function clamp_encoded_for_write_type(encoded, write_type, meta)
if type(encoded) ~= "number" or type(write_type) ~= "table" then
return encoded
end
local ranges = {
Uint8 = { 0, 0xFF },
Uint16 = { 0, 0xFFFF },
Uint24 = { 0, 0xFFFFFF },
Uint32 = { 0, 0xFFFFFFFF },
Int8 = { -0x80, 0x7F },
Int16 = { -0x8000, 0x7FFF },
Int24 = { -0x800000, 0x7FFFFF },
Int32 = { -0x80000000, 0x7FFFFFFF },
Enum8 = { 0, 0xFF },
}
local range = ranges[write_type.NAME]
if range == nil then
return encoded
end
local clamped = math.max(range[1], math.min(range[2], math.floor(encoded + 0.5)))
if clamped ~= encoded then
log.warn(string.format(
"ZCL write value clamped for cluster 0x%04X attribute 0x%04X name '%s': %s -> %s",
meta and meta.cluster_id or 0,
meta and meta.attribute_id or 0,
tostring(meta and meta.name or "unknown"),
tostring(encoded),
tostring(clamped)
))
end
return clamped
end
local function write_type_name(write_type)
return type(write_type) == "table" and write_type.NAME or nil
end
local function is_integer_like_write_type(write_type)
local name = write_type_name(write_type)
if type(name) ~= "string" then
return false
end
return name:match("^Uint") ~= nil or name:match("^Int") ~= nil or name:match("^Enum") ~= nil
end
local function should_prefer_plain_attribute_write(meta)
if type(meta) ~= "table" then
return false
end
if meta.mfg_code ~= nil then
return true
end
if type(meta.attribute_id) == "number" and meta.attribute_id >= 0x8000 then
return true
end
return false
end
local function build_or_reuse_mapping_context(device, mapping, context, value)
if type(context) == "table" and context.mapping == mapping then
return context
end
return zcl.build_mapping_context(device, mapping, context, value)
end
local function resolve_write_type(meta, encoded_value)
if meta.write_type ~= nil then
return meta.write_type
end
if meta.attribute_def ~= nil and meta.attribute_def.base_type ~= nil then
return meta.attribute_def.base_type
end
if type(encoded_value) == "boolean" then
return data_types.Boolean
end
return nil
end
local function encode_mapping_value(device, mapping, value, mapping_context, meta)
local encoded = value
if meta.to_device ~= nil then
encoded = meta.to_device(value, device, mapping_context, mapping)
end
if type(encoded) == "string" and type(mapping) == "table" then
local converter = type(mapping.converter) == "table" and mapping.converter or nil
local fallback_to_device = converter and type(converter.to) == "function" and converter.to or nil
if fallback_to_device ~= nil then
local fallback_encoded = fallback_to_device(encoded, device, mapping_context, mapping)
if fallback_encoded ~= nil then
encoded = fallback_encoded
end
end
end
if encoded == nil then
return nil
end
if type(encoded) == "number" and type(meta.scale) == "number" and meta.scale ~= 0 and meta.scale ~= 1 then
encoded = math.floor(encoded * meta.scale)
end
return encoded
end
local function normalize_enum_encoded_value(encoded, mapping, mapping_context, meta)
local write_type = meta and meta.write_type or nil
local type_name = write_type_name(write_type)
if type_name == nil or not tostring(type_name):match("^Enum") then
return encoded
end
if type(encoded) == "number" then
return encoded
end
local raw_value = type(mapping_context) == "table" and mapping_context.raw_value or encoded
local converter = type(mapping) == "table" and type(mapping.converter) == "table" and mapping.converter or nil
local converter_to = converter and type(converter.to) == "function" and converter.to or nil
if converter_to ~= nil then
local converted = converter_to(raw_value, device, mapping_context, mapping)
if type(converted) == "number" then
return converted
end
end
local numeric = tonumber(encoded)
if type(numeric) == "number" then
return numeric
end
log.warn(string.format(
"ZCL enum write conversion failed for cluster 0x%04X attribute 0x%04X name '%s': raw=%s encoded=%s",
meta and meta.cluster_id or 0,
meta and meta.attribute_id or 0,
tostring(meta and meta.name or "unknown"),
tostring(raw_value),
tostring(encoded)
))
return nil
end
local function retry_encoded_with_converter(device, mapping, mapping_context, meta, encoded)
if type(mapping) ~= "table" then
return encoded
end
local converter = type(mapping.converter) == "table" and mapping.converter or nil
local converter_to = converter and type(converter.to) == "function" and converter.to or nil
if converter_to == nil then
return encoded
end
local raw_value = type(mapping_context) == "table" and mapping_context.raw_value or encoded
local retried = converter_to(raw_value, device, mapping_context, mapping)
if retried ~= nil then
return retried
end
return encoded
end
local function encode_command_value(device, mapping, value, mapping_context)
local meta = zcl.mapping_meta(mapping)
if meta == nil then
return nil
end
local encoded = value
if meta.to_device ~= nil then
encoded = meta.to_device(value, device, mapping_context, mapping)
end
return encoded
end
local function normalize_command_args(encoded)
if encoded == nil then
return {}
end
if type(encoded) == "table" and encoded[1] ~= nil then
return encoded
end
return { encoded }
end
local function send_mapping_command(device, mapping, value, context)
local meta = zcl.mapping_meta(mapping)
if meta == nil or meta.tx_command_id == nil or meta.cluster_id == nil then
return false
end
local mapping_context = build_or_reuse_mapping_context(device, mapping, context, value)
local encoded = encode_command_value(device, mapping, value, mapping_context)
local generated_command = nil
if meta.tx_command_direction == "client" then
generated_command = zcl.get_generated_client_command and
zcl.get_generated_client_command(meta.cluster_id, meta.tx_command_id) or nil
else
generated_command = zcl.get_generated_server_command and
zcl.get_generated_server_command(meta.cluster_id, meta.tx_command_id) or nil
end
if generated_command ~= nil then
return send_request(device, generated_command(device, table.unpack(normalize_command_args(encoded))), mapping_context.endpoint)
end
if type(encoded) ~= "string" and encoded ~= nil then
log.warn(string.format(
"ZCL generic command fallback requires string payload for cluster 0x%04X command 0x%02X name '%s'",
meta.cluster_id,
meta.tx_command_id,
tostring(meta.name)
))
return false
end
if meta.mfg_code ~= nil then
return send_manufacturer_specific_command(
device,
meta.cluster_id,
meta.tx_command_id,
meta.mfg_code,
encoded or "",
mapping_context.endpoint,
meta.tx_command_direction
)
end
return send_cluster_command(
device,
meta.cluster_id,
meta.tx_command_id,
encoded or "",
mapping_context.endpoint,
meta.tx_command_direction
)
end
local function read_mapping_attribute(device, mapping, context)
local meta = zcl.mapping_meta(mapping)
if meta == nil or meta.cluster_id == nil or meta.attribute_id == nil then
return false
end
local mapping_context = build_or_reuse_mapping_context(device, mapping, context, nil)
if meta.mfg_code ~= nil then
return read_manufacturer_specific_attribute(
device,
meta.cluster_id,
meta.attribute_id,
meta.mfg_code,
mapping_context.endpoint
)
end
if meta.attribute_def ~= nil and type(meta.attribute_def.read) == "function" then
return read_generated_attribute(device, meta.attribute_def, mapping_context.endpoint)
end
return read_plain_attribute(device, meta.cluster_id, meta.attribute_id, mapping_context.endpoint)
end
local function write_mapping_value(device, mapping, value, context)
local meta = zcl.mapping_meta(mapping)
if meta == nil then
return false
end
local mapping_context = build_or_reuse_mapping_context(device, mapping, context, value)
mapping_context.raw_value = value
local encoded = encode_mapping_value(device, mapping, value, mapping_context, meta)
if encoded == nil then
return false
end
local write_type = resolve_write_type(meta, encoded)
if write_type == nil then
log.warn(string.format(
"ZCL write requires explicit write_type/data_type for cluster 0x%04X attribute 0x%04X name '%s'",
meta.cluster_id or 0,
meta.attribute_id or 0,
tostring(meta.name)
))
return false
end
if type(encoded) ~= "number" then
encoded = retry_encoded_with_converter(device, mapping, mapping_context, meta, encoded)
end
encoded = normalize_enum_encoded_value(encoded, mapping, mapping_context, meta)
if encoded == nil then
return false
end
if type(encoded) == "number" and is_integer_like_write_type(write_type) then
encoded = math.floor(encoded + 0.5)
end
if type(encoded) == "string" and is_integer_like_write_type(write_type) then
log.warn(string.format(
"ZCL write aborted because encoded value is still non-numeric for cluster 0x%04X attribute 0x%04X name '%s': %s",
meta.cluster_id or 0,
meta.attribute_id or 0,
tostring(meta.name),
tostring(encoded)
))
return false
end
encoded = clamp_encoded_for_write_type(encoded, write_type, meta)
mapping_context.encoded_value = encoded
if meta.mfg_code ~= nil then
local ok, result = pcall(
write_manufacturer_specific_attribute,
device,
meta.cluster_id,
meta.attribute_id,
meta.mfg_code,
encoded,
write_type,
mapping_context.endpoint
)
if ok then
return result
end
log.error(string.format(
"ZCL manufacturer write failed for cluster 0x%04X attribute 0x%04X name '%s': %s",
meta.cluster_id or 0,
meta.attribute_id or 0,
tostring(meta.name),
tostring(result)
))
return false
end
if not should_prefer_plain_attribute_write(meta) and meta.attribute_def ~= nil and type(meta.attribute_def.write) == "function" then
local ok, result = pcall(write_generated_attribute, device, meta.attribute_def, encoded, mapping_context.endpoint)
if ok then
return result
end
log.error(string.format(
"ZCL generated write failed for cluster 0x%04X attribute 0x%04X name '%s': %s",
meta.cluster_id or 0,
meta.attribute_id or 0,
tostring(meta.name),
tostring(result)
))
return false
end
local ok, result = pcall(
write_attribute,
device,
meta.cluster_id,
meta.attribute_id,
encoded,
write_type,
mapping_context.endpoint
)
if ok then
return result
end
log.error(string.format(
"ZCL write failed for cluster 0x%04X attribute 0x%04X name '%s': %s",
meta.cluster_id or 0,
meta.attribute_id or 0,
tostring(meta.name),
tostring(result)
))
return false
end
local function schedule_zll_switch_refresh(device, label)
if type(device) ~= "table" or
type(device.get_profile_id) ~= "function" or
device:get_profile_id() ~= zigbee_constants.ZLL_PROFILE_ID or
type(device.thread) ~= "table" or
type(device.thread.call_with_delay) ~= "function" or
type(device.refresh) ~= "function" then
return
end
device.thread:call_with_delay(2, function()
device:refresh()
end, label)
end
local function send_on_off(device, on_off, mapping_context)
local component_id = type(mapping_context) == "table" and mapping_context.component_id or nil
local endpoint = type(mapping_context) == "table" and mapping_context.endpoint or nil
local request = on_off and
zcl_clusters.OnOff.server.commands.On(device) or
zcl_clusters.OnOff.server.commands.Off(device)
if type(component_id) == "string" and component_id ~= "" and type(device.send_to_component) == "function" then
device:send_to_component(component_id, request)
schedule_zll_switch_refresh(device, on_off and "on delayed read" or "off delayed read")
return true
end
if send_request(device, request, endpoint) then
schedule_zll_switch_refresh(device, on_off and "on delayed read" or "off delayed read")
return true
end
return send_cluster_command(device, zcl.CLUSTER_ON_OFF, on_off and 0x01 or 0x00, "", endpoint)
end
local function send_level(device, level, transition_time, endpoint)
local command_def = zcl.get_generated_server_command and
zcl.get_generated_server_command(zcl.CLUSTER_LEVEL_CONTROL, 0x04) or nil
if command_def ~= nil then
return send_request(
device,
command_def(
device,
data_types.Uint8(clamp_integer(level, 0, 254)),
data_types.Uint16(clamp_integer(transition_time or 0, 0, 0xFFFF)),
0x00,
0x00
),
endpoint
)
end
local payload = string.char(clamp_integer(level, 0, 254))
.. encode_uint16_le(clamp_integer(transition_time or 0, 0, 0xFFFF))
return send_cluster_command(device, zcl.CLUSTER_LEVEL_CONTROL, 0x04, payload, endpoint)
end
local function send_cover_position(device, percentage, endpoint)
local command_def = zcl.get_generated_server_command and
zcl.get_generated_server_command(zcl.CLUSTER_WINDOW_COVERING, 0x05) or nil
if command_def ~= nil then
return send_request(
device,
command_def(device, data_types.Uint8(clamp_integer(percentage, 0, 100))),
endpoint
)
end
return send_cluster_command(
device,
zcl.CLUSTER_WINDOW_COVERING,
0x05,
string.char(clamp_integer(percentage, 0, 100)),
endpoint
)
end
local function send_cover_tilt(device, percentage, endpoint)
local command_def = zcl.get_generated_server_command and
zcl.get_generated_server_command(zcl.CLUSTER_WINDOW_COVERING, 0x08) or nil
if command_def ~= nil then
return send_request(
device,
command_def(device, data_types.Uint8(clamp_integer(percentage, 0, 100))),
endpoint
)
end
return send_cluster_command(
device,
zcl.CLUSTER_WINDOW_COVERING,
0x08,
string.char(clamp_integer(percentage, 0, 100)),
endpoint
)
end
local function send_cover_command(device, command, endpoint)
local command_ids = {
open = 0x00,
close = 0x01,
stop = 0x02,
}
local command_id = command_ids[command]
if command_id == nil then
log.warn(string.format("ZCL unknown cover command: %s", tostring(command)))
return false
end
local command_def = zcl.get_generated_server_command and
zcl.get_generated_server_command(zcl.CLUSTER_WINDOW_COVERING, command_id) or nil
if command_def ~= nil then
return send_request(device, command_def(device), endpoint)
end
return send_cluster_command(device, zcl.CLUSTER_WINDOW_COVERING, command_id, "", endpoint)
end
function zcl.send_raw_cluster_command(device, cluster_id, command_id, payload, endpoint, direction, mfg_code)
return send_cluster_specific_command(device, cluster_id, command_id, payload, endpoint, direction, mfg_code)
end
local function send_thermostat_setpoint(device, temperature_celsius, endpoint)
local attribute_def = zcl.get_generated_attribute and
zcl.get_generated_attribute(zcl.CLUSTER_THERMOSTAT, zcl.ATTR_OCCUPIED_HEATING_SETPOINT) or nil
if attribute_def ~= nil and type(attribute_def.write) == "function" then
return write_generated_attribute(device, attribute_def, math.floor(temperature_celsius * 100), endpoint)
end
return write_attribute(
device,
zcl.CLUSTER_THERMOSTAT,
zcl.ATTR_OCCUPIED_HEATING_SETPOINT,
math.floor(temperature_celsius * 100),
data_types.Int16,
endpoint
)
end
local function send_thermostat_mode(device, mode, endpoint)
local attribute_def = zcl.get_generated_attribute and
zcl.get_generated_attribute(zcl.CLUSTER_THERMOSTAT, zcl.ATTR_SYSTEM_MODE) or nil
if attribute_def ~= nil and type(attribute_def.write) == "function" then
return write_generated_attribute(device, attribute_def, mode, endpoint)
end
return write_attribute(
device,
zcl.CLUSTER_THERMOSTAT,
zcl.ATTR_SYSTEM_MODE,
mode,
data_types.Enum8,
endpoint
)
end
function zcl.read_attribute(device, cluster_id, attribute_id, endpoint, mfg_code)
if mfg_code ~= nil then
return read_manufacturer_specific_attribute(device, cluster_id, attribute_id, mfg_code, endpoint)
end
local attribute_def = zcl.get_generated_attribute and zcl.get_generated_attribute(cluster_id, attribute_id) or nil
if attribute_def ~= nil then
return read_generated_attribute(device, attribute_def, endpoint)
end
return read_plain_attribute(device, cluster_id, attribute_id, endpoint)
end
function zcl.read_mapping(device, mapping, context)
return read_mapping_attribute(device, mapping, context)
end
function zcl.read_named_attribute(device, zcl_clusters, name, context)
local mapping = zcl.find_mapping_by_name(zcl_clusters, name, device, context)
if mapping == nil then
return false
end
local meta = zcl.mapping_meta(mapping)
if meta == nil or meta.write_only then
return false
end
return read_mapping_attribute(device, mapping, zcl.build_mapping_context(device, mapping, context, nil))
end
function zcl.read_all_attributes(device, zcl_clusters)
if zcl_clusters == nil then
return
end
local seen = {}
for _, mapping in ipairs(zcl_clusters) do
local meta = type(mapping) == "table" and zcl.mapping_meta(mapping) or nil
if meta ~= nil and not meta.write_only and meta.cluster_id ~= nil and meta.attribute_id ~= nil then
local mapping_context = zcl.build_mapping_context(device, mapping, nil)
local key = string.format(
"%04X:%04X:%s:%s",
meta.cluster_id,
meta.attribute_id,
tostring(mapping_context.endpoint),
tostring(meta.mfg_code)
)
if not seen[key] then
seen[key] = true
read_mapping_attribute(device, mapping, mapping_context)
end
end
end
end
function zcl.register_sender(cluster_id, attribute_id, sender)
if cluster_id == nil or type(sender) ~= "function" then
log.warn(string.format(
"skip invalid zcl sender registration cluster=%s attribute=%s sender=%s",
tostring(cluster_id),
tostring(attribute_id),
type(sender)
))
return nil
end
sender_registry[cluster_id] = sender_registry[cluster_id] or {}
sender_registry[cluster_id][attribute_id or default_sender_key] = sender
return sender
end
function zcl.get_sender(cluster_id, attribute_id)
local cluster_senders = sender_registry[cluster_id]
if cluster_senders == nil then
return nil
end
return cluster_senders[attribute_id] or cluster_senders[default_sender_key]
end
local function resolve_sender(mapping)
return zcl.get_sender(mapping.cluster_id, mapping.attribute_id)
end
zcl.register_sender(zcl.CLUSTER_ON_OFF, zcl.ATTR_ON_OFF, function(device, mapping, value, mapping_context)
return send_on_off(device, value == true or value == "on" or value == "open", mapping_context)
end)
zcl.register_sender(zcl.CLUSTER_LEVEL_CONTROL, zcl.ATTR_LEVEL_CURRENT_LEVEL, function(device, mapping, value, mapping_context)
local encoded = encode_command_value(device, mapping, value, mapping_context)
if type(encoded) ~= "number" then
return false
end
return send_level(device, encoded, nil, mapping_context.endpoint)
end)
zcl.register_sender(zcl.CLUSTER_WINDOW_COVERING, nil, function(device, mapping, value, mapping_context)
if type(value) == "string" then
return send_cover_command(device, value, mapping_context.endpoint)
end
local encoded = encode_command_value(device, mapping, value, mapping_context)
if type(encoded) == "number" then
return send_cover_position(device, encoded, mapping_context.endpoint)
end
return false
end)
zcl.register_sender(zcl.CLUSTER_WINDOW_COVERING, zcl.ATTR_CURRENT_POSITION_TILT_PERCENTAGE, function(device, mapping, value, mapping_context)
local encoded = encode_command_value(device, mapping, value, mapping_context)
if type(encoded) == "number" then
return send_cover_tilt(device, encoded, mapping_context.endpoint)
end
return false
end)
zcl.register_sender(zcl.CLUSTER_THERMOSTAT, zcl.ATTR_OCCUPIED_HEATING_SETPOINT, function(device, mapping, value, mapping_context)
local encoded = encode_command_value(device, mapping, value, mapping_context)
if type(encoded) ~= "number" then
return false
end
return send_thermostat_setpoint(device, encoded, mapping_context.endpoint)
end)
zcl.register_sender(zcl.CLUSTER_THERMOSTAT, zcl.ATTR_SYSTEM_MODE, function(device, mapping, value, mapping_context)
local encoded = encode_command_value(device, mapping, value, mapping_context)
if encoded == nil then
return false
end
return send_thermostat_mode(device, encoded, mapping_context.endpoint)
end)
function zcl.send_named_command(device, zcl_clusters, name, value, context)
local mapping = zcl.find_mapping_by_name(zcl_clusters, name, device, context)
if mapping == nil then
return false
end
local meta = zcl.mapping_meta(mapping)
if meta == nil then
return false
end
if meta.read_only then
log.warn(string.format("ZCL send_named_command: mapping '%s' is read-only", tostring(name)))
return false
end
local mapping_context = zcl.build_mapping_context(device, mapping, context, value)
mapping_context.raw_value = value
if meta.sender ~= nil then
return meta.sender(device, mapping, value, mapping_context) ~= false
end
local sender = resolve_sender(mapping)
if sender ~= nil then
return sender(device, mapping, value, mapping_context)
end
if meta.tx_command_id ~= nil then
return send_mapping_command(device, mapping, value, mapping_context)
end
if meta.cluster_id == nil or meta.attribute_id == nil then
return false
end
if write_mapping_value(device, mapping, value, mapping_context) then
return true
end
log.warn(string.format(
"ZCL send_named_command: no sender for cluster 0x%04X attribute 0x%04X name '%s'",
meta.cluster_id,
meta.attribute_id,
tostring(name)
))
return false
end
end
return load_command_sender
