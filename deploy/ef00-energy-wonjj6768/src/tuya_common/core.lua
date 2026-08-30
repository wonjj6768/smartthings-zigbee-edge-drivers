local data_types=require "st.zigbee.data_types"
local constants=require "st.zigbee.constants"
local zcl_messages=require "st.zigbee.zcl"
local messages=require "st.zigbee.messages"
local generic_body=require "st.zigbee.generic_body"
local read_attribute=require "st.zigbee.zcl.global_commands.read_attribute"
local cluster_base=require "st.zigbee.cluster_base"
local utils=require "st.utils"
local foundation=require "tuya_common.foundation"
local log=foundation.log
local shared={}
for key,value in pairs(foundation)do
shared[key]=value
end
shared.data_types=data_types
shared.constants=constants
shared.zcl_messages=zcl_messages
shared.messages=messages
shared.generic_body=generic_body
shared.read_attribute=read_attribute
shared.cluster_base=cluster_base
shared.utils=utils
shared.REPORT_COMMANDS={
[shared.GET_DATA]=true,
[shared.SET_DATA_RESPONSE]=true,
[shared.REPORT_STATUS]=true,
[shared.ACTIVE_STATUS_REPORT]=true,
}
local BASIC_CLUSTER=shared.BASIC_CLUSTER
local PACKET_ID_FIELD=shared.PACKET_ID_FIELD
local PERSIST_FALSE=shared.PERSIST_FALSE
local BASIC_ENDPOINT_FIELD=shared.BASIC_ENDPOINT_FIELD
local string_byte=shared.string_byte
local string_char=shared.string_char
local string_pack=shared.string_pack
local string_len=shared.string_len
local math_floor=shared.math_floor
local type_check=shared.type_check
local table_concat=shared.table_concat
local function next_packet_id(device)
local previous_packet_id=device:get_field(PACKET_ID_FIELD)
if type_check(previous_packet_id)~="number" or previous_packet_id % 1 ~=0 then
previous_packet_id=0
end
local packet_id=previous_packet_id + 1
if packet_id >=0x10000 then
packet_id=1
end
device:set_field(PACKET_ID_FIELD,packet_id,PERSIST_FALSE)
return packet_id
end
local function resolve_cluster_endpoint(device,cluster_id,field_name)
local cached=field_name and device:get_field(field_name)or nil
if cached then
return cached
end
local endpoint=device:get_endpoint(cluster_id)
if endpoint and field_name then
device:set_field(field_name,endpoint,PERSIST_FALSE)
end
return endpoint
end
local function extract_payload(message)
if type_check(message)=="string" then
return message
end
if type_check(message)~="table" then
return nil
end
return message.body and message.body.zcl_body and message.body.zcl_body.body_bytes or nil
end
local function extract_command_id(message)
if type_check(message)~="table" then
return nil
end
return message.body and
message.body.zcl_header and
message.body.zcl_header.cmd and
message.body.zcl_header.cmd.value or nil
end
local function extract_source_endpoint(message)
if type_check(message)~="table" then
return nil
end
local endpoint=message.address_header and
message.address_header.src_endpoint and
message.address_header.src_endpoint.value or nil
if type_check(endpoint)=="number" then
return endpoint
end
return nil
end
local function build_basic_read_attributes_message(device,attr_ids)
local endpoint=resolve_cluster_endpoint(device,BASIC_CLUSTER,BASIC_ENDPOINT_FIELD)
if not endpoint then
log.warn(string.format("Cluster 0x%04X endpoint not found",BASIC_CLUSTER))
return nil
end
local zcl_header=zcl_messages.ZclHeader({
cmd=data_types.ZCLCommandId(read_attribute.ReadAttribute.ID)
})
local address_header=messages.AddressHeader(
constants.HUB.ADDR,
constants.HUB.ENDPOINT,
device:get_short_address(),
endpoint,
constants.HA_PROFILE_ID,
BASIC_CLUSTER
)
local message_body=zcl_messages.ZclMessageBody({
zcl_header=zcl_header,
zcl_body=read_attribute.ReadAttribute(attr_ids)
})
return messages.ZigbeeMessageTx({
address_header=address_header,
body=message_body
})
end
local function bytes_from_table(bytes)
local parts={}
for index,byte in ipairs(bytes or{})do
if type_check(byte)~="number" then
return nil
end
local normalized=math_floor(byte)
if normalized ~=byte or normalized < 0 or normalized > 0xFF then
return nil
end
parts[index]=string_char(normalized)
end
return table_concat(parts)
end
local function raw_bytes(value)
if type_check(value)=="string" then
return value
end
if type_check(value)=="table" then
return bytes_from_table(value)
end
return nil
end
local function pack_bitmap(value)
if type_check(value)~="number" then
return nil
end
local normalized=math_floor(value)
if normalized ~=value or normalized < 0 then
return nil
end
value=normalized
if value <=0xFF then
return string_char(value)
elseif value <=0xFFFF then
return string_pack(">I2",value)
elseif value <=0xFFFFFFFF then
return string_pack(">I4",value)
end
return nil
end
local function persist_opt(persist)
if persist then
return{persist=true}
end
return PERSIST_FALSE
end
local function normalize_transaction(transaction)
if transaction==nil then
return nil
end
if type_check(transaction)~="number" then
return nil
end
local normalized=math_floor(transaction)
if normalized ~=transaction then
return nil
end
normalized=normalized % 0x10000
if normalized < 0 then
normalized=normalized + 0x10000
end
return normalized
end
local function extract_transaction(message)
local payload=extract_payload(message)
if payload and string_len(payload)>=2 then
return string_byte(payload,2)
end
return nil
end
shared.next_packet_id=next_packet_id
shared.resolve_cluster_endpoint=resolve_cluster_endpoint
shared.extract_payload=extract_payload
shared.extract_command_id=extract_command_id
shared.extract_source_endpoint=extract_source_endpoint
shared.build_basic_read_attributes_message=build_basic_read_attributes_message
shared.raw_bytes=raw_bytes
shared.pack_bitmap=pack_bitmap
shared.persist_opt=persist_opt
shared.normalize_transaction=normalize_transaction
shared.extract_transaction=extract_transaction
return shared
