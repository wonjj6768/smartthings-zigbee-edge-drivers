local function load_protocol(tuya, shared)
local data_types = shared.data_types
local constants = shared.constants
local zcl_messages = shared.zcl_messages
local messages = shared.messages
local generic_body = shared.generic_body
local log = shared.log
local TUYA_CLUSTER = shared.TUYA_CLUSTER
local TUYA_ENDPOINT_FIELD = shared.TUYA_ENDPOINT_FIELD
local MAGIC_PACKET_ATTRS = shared.MAGIC_PACKET_ATTRS
local SET_DATA = shared.SET_DATA
local QUERY_DATA = shared.QUERY_DATA
local MCU_VERSION_REQUEST = shared.MCU_VERSION_REQUEST
local SET_TIME = shared.SET_TIME
local CONNECTION_STATUS = shared.CONNECTION_STATUS
local DEFAULT_MCU_VERSION_TRANSACTION = shared.DEFAULT_MCU_VERSION_TRANSACTION
local DP_TYPE_RAW = shared.DP_TYPE_RAW
local DP_TYPE_BOOL = shared.DP_TYPE_BOOL
local DP_TYPE_VALUE = shared.DP_TYPE_VALUE
local DP_TYPE_STRING = shared.DP_TYPE_STRING
local DP_TYPE_ENUM = shared.DP_TYPE_ENUM
local DP_TYPE_BITMAP = shared.DP_TYPE_BITMAP
local string_byte = shared.string_byte
local string_char = shared.string_char
local string_pack = shared.string_pack
local string_sub = shared.string_sub
local string_len = shared.string_len
local math_floor = shared.math_floor
local type_check = shared.type_check
local table_insert = shared.table_insert
local os_time = shared.os_time
local next_packet_id = shared.next_packet_id
local resolve_cluster_endpoint = shared.resolve_cluster_endpoint
local extract_payload = shared.extract_payload
local extract_command_id = shared.extract_command_id
local extract_source_endpoint = shared.extract_source_endpoint
local build_basic_read_attributes_message = shared.build_basic_read_attributes_message
local raw_bytes = shared.raw_bytes
local pack_bitmap = shared.pack_bitmap
local normalize_transaction = shared.normalize_transaction
local THRESHOLD_STATE_LOOKUP = {
[0] = "not_set",
[1] = "over_current_threshold",
[3] = "over_voltage_threshold",
}
local THRESHOLD_PROTECTION_LOOKUP = {
[0] = "OFF",
[1] = "ON",
}
local build_bytes
local parse_uint
local parse_int
local build_value_bytes
local parse_value
local build_connection_status_payload
local build_time_payload
local build_time_payload_with_offset
local function is_byte(value)
return type_check(value) == "number" and value >= 0 and value <= 0xFF and value % 1 == 0
end
local function normalize_uint32(value, label)
if type_check(value) ~= "number" then
log.warn(string.format("Tuya %s expects number, got %s", label, type_check(value)))
return nil
end
local normalized = math_floor(value)
if normalized ~= value or normalized < 0 or normalized > 0xFFFFFFFF then
log.warn(string.format("Tuya %s expects integer in range 0..0xFFFFFFFF, got %s", label, tostring(value)))
return nil
end
return normalized
end
local function default_if_nil(value, fallback)
if value == nil then
return fallback
end
return value
end
build_bytes = function(value)
local encoded = raw_bytes(value)
if encoded ~= nil then
return encoded
end
log.warn(string.format("Tuya bytes expects string or byte array, got %s", type_check(value)))
return nil
end
function tuya.parse_phase_variant1(value, phase)
local buffer = raw_bytes(value)
if buffer == nil or string_len(buffer) < 15 then
log.warn("Tuya phase_variant1 expects at least 15 bytes")
return nil
end
local voltage = parse_uint(buffer, 14, 2) / 10
local current = parse_uint(buffer, 12, 2) / 1000
if type_check(phase) == "string" and phase ~= "" then
return {
["voltage_" .. phase] = voltage,
["current_" .. phase] = current,
}
end
return {
voltage = voltage,
current = current,
}
end
function tuya.parse_phase_variant2(value, phase, signed_power)
local buffer = raw_bytes(value)
if buffer == nil or string_len(buffer) < 8 then
log.warn("Tuya phase_variant2 expects at least 8 bytes")
return nil
end
local voltage = parse_uint(buffer, 1, 2) / 10
local current = parse_uint(buffer, 4, 2) / 1000
local power = parse_uint(buffer, 7, 2)
if signed_power and power > 0x7FFF then
power = (0x999A - power) * -1
end
if type_check(phase) == "string" and phase ~= "" then
return {
["voltage_" .. phase] = voltage,
["current_" .. phase] = current,
["power_" .. phase] = power,
}
end
return {
voltage = voltage,
current = current,
power = power,
}
end
function tuya.parse_phase_variant3(value, phase)
local buffer = raw_bytes(value)
if buffer == nil or string_len(buffer) < 8 then
log.warn("Tuya phase_variant3 expects at least 8 bytes")
return nil
end
local voltage = parse_uint(buffer, 1, 2) / 10
local current = parse_uint(buffer, 3, 3) / 1000
local power = parse_uint(buffer, 6, 3)
if type_check(phase) == "string" and phase ~= "" then
return {
["voltage_" .. phase] = voltage,
["current_" .. phase] = current,
["power_" .. phase] = power,
}
end
return {
voltage = voltage,
current = current,
power = power,
}
end
function tuya.parse_threshold(value)
local buffer = raw_bytes(value)
if buffer == nil or string_len(buffer) < 8 then
log.warn("Tuya threshold expects at least 8 bytes")
return nil
end
return {
threshold_1_protection = THRESHOLD_PROTECTION_LOOKUP[string_byte(buffer, 2)],
threshold_1 = THRESHOLD_STATE_LOOKUP[string_byte(buffer, 1)],
threshold_1_value = parse_uint(buffer, 3, 2),
threshold_2_protection = THRESHOLD_PROTECTION_LOOKUP[string_byte(buffer, 6)],
threshold_2 = THRESHOLD_STATE_LOOKUP[string_byte(buffer, 5)],
threshold_2_value = parse_uint(buffer, 7, 2),
}
end
function tuya.send_magic_packet(device)
local message = build_basic_read_attributes_message(device, MAGIC_PACKET_ATTRS)
if not message then
return false
end
device:send(message)
return true
end
parse_uint = function(buffer, start, len)
if type_check(buffer) ~= "string" then
log.warn(string.format("Tuya parse_uint expects string, got %s", type_check(buffer)))
return nil
end
local offset = default_if_nil(start, 1)
local size = len
if type_check(offset) ~= "number" or offset % 1 ~= 0 or offset < 1 then
log.warn(string.format("Tuya parse_uint expects positive integer offset, got %s", tostring(offset)))
return nil
end
if size == nil then
size = string_len(buffer) - offset + 1
end
if type_check(size) ~= "number" or size % 1 ~= 0 or size < 1 then
log.warn(string.format("Tuya parse_uint expects positive integer length, got %s", tostring(size)))
return nil
end
if offset + size - 1 > string_len(buffer) then
log.warn(string.format("Tuya parse_uint out of range: offset=%d len=%d buffer_len=%d", offset, size, string_len(buffer)))
return nil
end
if size == 1 then
return string_byte(buffer, offset)
elseif size == 2 then
return (string_byte(buffer, offset) * 256) + string_byte(buffer, offset + 1)
elseif size == 4 then
return (string_byte(buffer, offset) * 16777216) +
(string_byte(buffer, offset + 1) * 65536) +
(string_byte(buffer, offset + 2) * 256) +
string_byte(buffer, offset + 3)
end
local value = 0
for i = 0, size - 1 do
value = value * 256 + string_byte(buffer, offset + i)
end
return value
end
parse_int = function(buffer, start, len)
if type_check(buffer) ~= "string" then
log.warn(string.format("Tuya parse_int expects string, got %s", type_check(buffer)))
return nil
end
local offset = default_if_nil(start, 1)
local size = len
if size == nil then
if type_check(offset) ~= "number" or offset % 1 ~= 0 then
log.warn(string.format("Tuya parse_int expects integer offset, got %s", tostring(offset)))
return nil
end
size = string_len(buffer) - offset + 1
end
local unsigned = parse_uint(buffer, offset, size)
if unsigned == nil then
return nil
end
local max_value = 2 ^ (size * 8)
local sign_bit = max_value / 2
if unsigned >= sign_bit then
return unsigned - max_value
end
return unsigned
end
build_value_bytes = function(datatype, value, signed)
if datatype == DP_TYPE_BOOL then
if value == true or value == 1 then
return string_char(1)
end
if value == false or value == 0 then
return string_char(0)
end
log.warn(string.format("Tuya BOOL expects boolean or 0/1, got %s", tostring(value)))
return nil
end
if datatype == DP_TYPE_VALUE then
if type_check(value) ~= "number" then
log.warn(string.format("Tuya VALUE expects number, got %s", type_check(value)))
return nil
end
local int_value = math_floor(value)
if signed then
if int_value < -0x80000000 then int_value = -0x80000000 end
if int_value > 0x7FFFFFFF then int_value = 0x7FFFFFFF end
if int_value < 0 then
int_value = int_value + 0x100000000
end
else
if int_value < 0 then int_value = 0 end
if int_value > 0xFFFFFFFF then int_value = 0xFFFFFFFF end
end
return string_pack(">I4", int_value)
end
if datatype == DP_TYPE_ENUM then
if type_check(value) ~= "number" then
log.warn(string.format("Tuya ENUM expects number, got %s", type_check(value)))
return nil
end
local enum_value = math_floor(value)
if enum_value ~= value or enum_value < 0 or enum_value > 0xFF then
log.warn(string.format("Tuya ENUM expects byte integer, got %s", tostring(value)))
return nil
end
return string_char(enum_value)
end
if datatype == DP_TYPE_BITMAP then
if type_check(value) == "number" then
local bitmap = pack_bitmap(value)
if bitmap ~= nil then
return bitmap
end
log.warn(string.format("Tuya BITMAP expects non-negative integer up to 0xFFFFFFFF, got %s", tostring(value)))
return nil
end
if type_check(value) == "string" then
return value
end
log.warn(string.format("Tuya BITMAP expects number or string, got %s", type_check(value)))
return nil
end
if datatype == DP_TYPE_RAW then
local raw_value = build_bytes(value)
if raw_value == nil then
return nil
end
return raw_value
end
if datatype == DP_TYPE_STRING then
if type_check(value) ~= "string" then
log.warn(string.format("Tuya type %d expects string, got %s", datatype, type_check(value)))
return nil
end
return value
end
log.warn(string.format("Unsupported Tuya datatype: %d", datatype))
return nil
end
parse_value = function(datatype, value_bytes)
if type_check(value_bytes) ~= "string" then
return nil
end
if datatype == DP_TYPE_BOOL then
local bool_value = string_byte(value_bytes, 1)
if bool_value == 0 then
return false
end
if bool_value == 1 then
return true
end
log.warn(string.format("Tuya BOOL payload expects 0x00 or 0x01, got %s", tostring(bool_value)))
return nil
elseif datatype == DP_TYPE_VALUE then
return parse_uint(value_bytes)
elseif datatype == DP_TYPE_ENUM then
return string_byte(value_bytes, 1)
elseif datatype == DP_TYPE_BITMAP then
return parse_uint(value_bytes)
end
return value_bytes
end
function tuya.build_datapoint(dp, datatype, value, signed)
if not is_byte(dp) or not is_byte(datatype) then
log.warn(string.format("Tuya datapoint expects byte dp/datatype, got dp=%s datatype=%s", tostring(dp), tostring(datatype)))
return nil
end
local value_bytes = build_value_bytes(datatype, value, signed)
if not value_bytes then
return nil
end
local value_length = string_len(value_bytes)
if value_length > 0xFFFF then
log.warn(string.format("Tuya datapoint value too long: %d", value_length))
return nil
end
return string_char(dp, datatype) .. string_pack(">I2", value_length) .. value_bytes
end
function tuya.build_datapoints(items)
local parts = {}
for _, item in ipairs(items or {}) do
local payload = tuya.build_datapoint(item.dp, item.datatype, item.value, item.signed)
if not payload then
return nil
end
table_insert(parts, payload)
end
return table.concat(parts)
end
local function resolve_packet_id(device, transaction)
local normalized = normalize_transaction(transaction)
if transaction ~= nil and normalized == nil then
log.warn(string.format("Tuya transaction expects number, got %s", type_check(transaction)))
return nil
end
if normalized ~= nil then
return normalized
end
return next_packet_id(device)
end
function tuya.send_raw(device, command_id, payload)
if not is_byte(command_id) then
log.warn(string.format("Tuya command id expects byte value, got %s", tostring(command_id)))
return false
end
if payload == nil then
payload = ""
end
if type_check(payload) ~= "string" then
log.warn(string.format("Tuya raw payload expects string, got %s", type_check(payload)))
return false
end
local endpoint = resolve_cluster_endpoint(device, TUYA_CLUSTER, TUYA_ENDPOINT_FIELD)
if not endpoint then
log.warn("Tuya cluster endpoint not found")
return false
end
local zcl_header = zcl_messages.ZclHeader({ cmd = data_types.ZCLCommandId(command_id) })
zcl_header.frame_ctrl:set_cluster_specific()
zcl_header.frame_ctrl:set_disable_default_response()
local address_header = messages.AddressHeader(
constants.HUB.ADDR,
constants.HUB.ENDPOINT,
device:get_short_address(),
endpoint,
constants.HA_PROFILE_ID,
TUYA_CLUSTER
)
local message_body = zcl_messages.ZclMessageBody({
zcl_header = zcl_header,
zcl_body = generic_body.GenericBody(payload)
})
device:send(messages.ZigbeeMessageTx({
address_header = address_header,
body = message_body
}))
return true
end
function tuya.send_datapoint(device, dp, datatype, value, command_id, signed, transaction)
local dp_payload = tuya.build_datapoint(dp, datatype, value, signed)
if not dp_payload then
return nil
end
local packet_id = resolve_packet_id(device, transaction)
if packet_id == nil then
return nil
end
local cmd = command_id
if cmd == nil then
cmd = SET_DATA
end
if not tuya.send_raw(device, cmd, string_pack(">I2", packet_id) .. dp_payload) then
return nil
end
return packet_id
end
function tuya.send_datapoints(device, items, command_id, transaction)
local dps_payload = tuya.build_datapoints(items)
if not dps_payload then
return nil
end
local packet_id = resolve_packet_id(device, transaction)
if packet_id == nil then
return nil
end
local cmd = command_id
if cmd == nil then
cmd = SET_DATA
end
if not tuya.send_raw(device, cmd, string_pack(">I2", packet_id) .. dps_payload) then
return nil
end
return packet_id
end
function tuya.send_state_request(device, command_id)
local cmd = command_id
if cmd == nil then
cmd = QUERY_DATA
end
return tuya.send_raw(device, cmd, "")
end
function tuya.send_mcu_version_request(device, transaction)
local effective_transaction = transaction
if effective_transaction == nil then
effective_transaction = DEFAULT_MCU_VERSION_TRANSACTION
end
local packet_id = resolve_packet_id(device, effective_transaction)
if packet_id == nil then
return nil
end
if not tuya.send_raw(device, MCU_VERSION_REQUEST, string_pack(">I2", packet_id)) then
return nil
end
return packet_id
end
build_connection_status_payload = function(transaction, status_bytes)
local tsn = 0
if transaction ~= nil then
if type_check(transaction) ~= "number" then
log.warn(string.format("Tuya connection status transaction expects number, got %s", type_check(transaction)))
return nil
end
local normalized = math_floor(transaction)
if normalized ~= transaction then
log.warn(string.format("Tuya connection status transaction expects integer, got %s", tostring(transaction)))
return nil
end
tsn = normalized % 0x100
if tsn < 0 then
tsn = tsn + 0x100
end
end
local status = status_bytes == nil and "\x01" or build_bytes(status_bytes)
if status == nil then
return nil
end
if string_len(status) > 0xFF then
log.warn(string.format("Tuya connection status payload too long: %d", string_len(status)))
return nil
end
return string_char(tsn) .. string_char(string_len(status)) .. status
end
function tuya.send_connection_status(device, transaction, status_bytes)
local payload = build_connection_status_payload(transaction, status_bytes)
if payload == nil then
return false
end
return tuya.send_raw(device, CONNECTION_STATUS, payload)
end
build_time_payload = function(utc_time, local_time)
local utc_value = normalize_uint32(default_if_nil(utc_time, os_time()), "utc_time")
if utc_value == nil then
return nil
end
local local_value = normalize_uint32(default_if_nil(local_time, utc_value), "local_time")
if local_value == nil then
return nil
end
return string_pack(">I4I4", utc_value, local_value)
end
build_time_payload_with_offset = function(offset_seconds, utc_time, local_time)
local offset = normalize_uint32(default_if_nil(offset_seconds, 0), "time_offset")
if offset == nil then
return nil
end
local base_utc = normalize_uint32(default_if_nil(utc_time, os_time()), "utc_time")
if base_utc == nil or base_utc < offset then
log.warn(string.format("Tuya time offset underflow: utc=%s offset=%s", tostring(base_utc), tostring(offset)))
return nil
end
local base_local = normalize_uint32(default_if_nil(local_time, base_utc), "local_time")
if base_local == nil or base_local < offset then
log.warn(string.format("Tuya time offset underflow: local=%s offset=%s", tostring(base_local), tostring(offset)))
return nil
end
local utc_value = base_utc - offset
local local_value = base_local - offset
return build_time_payload(utc_value, local_value)
end
function tuya.send_time(device, utc_time, local_time)
local payload = build_time_payload(utc_time, local_time)
if payload == nil then
return false
end
return tuya.send_raw(device, SET_TIME, payload)
end
function tuya.send_time_with_offset(device, offset_seconds, utc_time, local_time)
local payload = build_time_payload_with_offset(offset_seconds, utc_time, local_time)
if payload == nil then
return false
end
return tuya.send_raw(device, SET_TIME, payload)
end
function tuya.apply_time_request(device, message, utc_time, local_time)
if extract_command_id(message) ~= SET_TIME then
return false
end
return tuya.send_time(device, utc_time, local_time) == true
end
function tuya.apply_time_request_with_offset(device, message, offset_seconds, utc_time, local_time)
if extract_command_id(message) ~= SET_TIME then
return false
end
return tuya.send_time_with_offset(device, offset_seconds, utc_time, local_time) == true
end
function tuya.apply_connection_status_request(device, message, status_bytes)
if extract_command_id(message) ~= CONNECTION_STATUS then
return false
end
local info = tuya.parse_connection_status(message)
if info == nil then
return false
end
return tuya.send_connection_status(device, info.transaction, status_bytes) == true
end
function tuya.parse_connection_status(message)
local payload = extract_payload(message)
if not payload or string_len(payload) < 1 then
return nil
end
local transaction = string_byte(payload, 1)
local status_length = nil
local status_bytes = ""
if string_len(payload) >= 2 then
status_length = string_byte(payload, 2)
if string_len(payload) >= status_length + 2 then
status_bytes = string_sub(payload, 3, status_length + 2)
else
status_bytes = string_sub(payload, 3)
end
end
return {
transaction = transaction,
status_length = status_length,
status_bytes = status_bytes,
payload = payload,
}
end
function tuya.parse_mcu_version_response(message)
local payload = extract_payload(message)
if not payload or string_len(payload) < 3 then
return nil
end
local transaction_hi = string_byte(payload, 1)  -- 2바이트 트랜잭션 ID의 상위 바이트
local transaction_lo = string_byte(payload, 2)  -- 2바이트 트랜잭션 ID의 하위 바이트
local version_raw = string_byte(payload, 3)
local major = math_floor(version_raw / 64)
local minor = math_floor((version_raw % 64) / 16)
local release = version_raw % 16
return {
transaction_hi = transaction_hi,
transaction_lo = transaction_lo,
version_raw = version_raw,
version = string.format("%d.%d.%d", major, minor, release),
payload = payload,
}
end
function tuya.parse_datapoint(buffer, index)
local payload = extract_payload(buffer)
local start_index = default_if_nil(index, 3)
if not payload then
return nil
end
if type_check(start_index) ~= "number" or start_index % 1 ~= 0 or start_index < 1 then
log.warn(string.format("Tuya parse_datapoint expects positive integer index, got %s", tostring(start_index)))
return nil
end
local payload_len = string_len(payload)
if payload_len < start_index + 3 then
if payload_len >= start_index then
log.warn(string.format(
"Tuya DP header truncated at index %d (payload_len=%d)",
start_index,
payload_len
))
end
return nil
end
local dp = string_byte(payload, start_index)
local datatype = string_byte(payload, start_index + 1)
local len = (string_byte(payload, start_index + 2) * 256) + string_byte(payload, start_index + 3)
local value_start = start_index + 4
local next_index = value_start + len
if next_index - 1 > payload_len then
log.warn(string.format(
"Tuya DP payload truncated: dp=%d datatype=%d len=%d index=%d payload_len=%d",
dp,
datatype,
len,
start_index,
payload_len
))
return nil
end
local value_bytes = string_sub(payload, value_start, next_index - 1)
local decoded_value = parse_value(datatype, value_bytes)
return {
dp = dp,
datatype = datatype,
length = len,
value_bytes = value_bytes,
value = decoded_value,
int_value = parse_uint(value_bytes),
signed_value = parse_int(value_bytes),
next_index = next_index,
}
end
function tuya.parse_datapoints(buffer, index)
local payload = extract_payload(buffer)
if payload == nil then
return nil
end
local cursor = default_if_nil(index, 3)
if type_check(cursor) ~= "number" or cursor % 1 ~= 0 or cursor < 1 then
log.warn(string.format("Tuya parse_datapoints expects positive integer index, got %s", tostring(cursor)))
return nil
end
local payload_len = string_len(payload)
local datapoints = {}
while cursor <= payload_len do
local dp_info = tuya.parse_datapoint(payload, cursor)
if not dp_info then
return nil
end
table_insert(datapoints, dp_info)
cursor = dp_info.next_index
end
return datapoints
end
function tuya.parse_datapoint_report(message)
local payload = extract_payload(message)
if not payload then
return nil
end
if string_len(payload) < 2 then
log.warn(string.format("Tuya report too short (payload_len=%d)", string_len(payload)))
return nil
end
local frame = {
command_id = extract_command_id(message),
endpoint = extract_source_endpoint(message),
status = string_byte(payload, 1),
transaction = string_byte(payload, 2),
payload = payload,
datapoints = {},
}
local datapoints = tuya.parse_datapoints(payload, 3)
if datapoints == nil then
return nil
end
for _, dp_info in ipairs(datapoints) do
dp_info.endpoint = frame.endpoint
end
frame.datapoints = datapoints
return frame
end
end
return load_protocol
