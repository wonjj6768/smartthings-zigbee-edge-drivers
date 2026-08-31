local log=require "log"
local shared={}
shared.log=log
shared.BASIC_CLUSTER=0x0000
shared.TUYA_CLUSTER=0xEF00
shared.MAGIC_PACKET_ATTRS={0x0004,0x0000,0x0001,0x0005,0x0007,0xFFFE}
shared.PERSIST_FALSE={persist=false}
shared.EPOCH_2000_OFFSET=946684800
shared.PACKET_ID_FIELD="tuya_packet_id"
shared.CONFIG_QUEUE_FIELD="config_queue"
shared.CONFIG_QUEUE_CALLBACK_FIELD="config_queue_callback"
shared.QUERY_INTERVAL_TIMER_FIELD="tuya_query_interval_timer"
shared.BASIC_ENDPOINT_FIELD="tuya_basic_endpoint"
shared.TUYA_ENDPOINT_FIELD="tuya_cluster_endpoint"
shared.SET_DATA=0x00
shared.GET_DATA=0x01
shared.SET_DATA_RESPONSE=0x02
shared.QUERY_DATA=0x03
shared.SEND_DATA=0x04
shared.REPORT_STATUS=0x05
shared.ACTIVE_STATUS_REPORT=0x06
shared.MCU_VERSION_REQUEST=0x10
shared.MCU_VERSION_RESPONSE=0x11
shared.SET_TIME=0x24
shared.CONNECTION_STATUS=0x25
shared.DEFAULT_MCU_VERSION_TRANSACTION=0x0002
shared.DP_TYPE_RAW=0x00
shared.DP_TYPE_BOOL=0x01
shared.DP_TYPE_VALUE=0x02
shared.DP_TYPE_STRING=0x03
shared.DP_TYPE_ENUM=0x04
shared.DP_TYPE_BITMAP=0x05
shared.string_byte=string.byte
shared.string_char=string.char
shared.string_pack=string.pack
shared.string_sub=string.sub
shared.string_len=string.len
shared.math_floor=math.floor
shared.type_check=type
shared.table_insert=table.insert
shared.table_remove=table.remove
shared.table_concat=table.concat
shared.os_time=os.time
shared.tonumber_check=tonumber
function shared.apply_constants(tuya)
tuya.BASIC_CLUSTER=shared.BASIC_CLUSTER
tuya.EF00_CLUSTER=shared.TUYA_CLUSTER
tuya.EPOCH_2000_OFFSET=shared.EPOCH_2000_OFFSET
tuya.SET_DATA=shared.SET_DATA
tuya.GET_DATA=shared.GET_DATA
tuya.SET_DATA_RESPONSE=shared.SET_DATA_RESPONSE
tuya.QUERY_DATA=shared.QUERY_DATA
tuya.SEND_DATA=shared.SEND_DATA
tuya.REPORT_STATUS=shared.REPORT_STATUS
tuya.ACTIVE_STATUS_REPORT=shared.ACTIVE_STATUS_REPORT
tuya.MCU_VERSION_REQUEST=shared.MCU_VERSION_REQUEST
tuya.MCU_VERSION_RESPONSE=shared.MCU_VERSION_RESPONSE
tuya.SET_TIME=shared.SET_TIME
tuya.CONNECTION_STATUS=shared.CONNECTION_STATUS
tuya.DEFAULT_MCU_VERSION_TRANSACTION=shared.DEFAULT_MCU_VERSION_TRANSACTION
tuya.DP_TYPE_RAW=shared.DP_TYPE_RAW
tuya.DP_TYPE_BOOL=shared.DP_TYPE_BOOL
tuya.DP_TYPE_VALUE=shared.DP_TYPE_VALUE
tuya.DP_TYPE_STRING=shared.DP_TYPE_STRING
tuya.DP_TYPE_ENUM=shared.DP_TYPE_ENUM
tuya.DP_TYPE_BITMAP=shared.DP_TYPE_BITMAP
tuya.converter={}
tuya.skip={}
end
local type_check=shared.type_check
local EPOCH_2000_OFFSET=shared.EPOCH_2000_OFFSET
local function copy_table(source)
local target={}
if type_check(source)~="table" then
return target
end
for key,value in pairs(source)do
target[key]=value
end
return target
end
local function copy_keys(target,source,keys)
if type_check(source)~="table" then
return target
end
for _,key in ipairs(keys)do
if source[key]~=nil then
target[key]=source[key]
end
end
return target
end
local function merge_options(target,source)
if type_check(source)~="table" then
return target
end
for key,value in pairs(source)do
target[key]=value
end
return target
end
local function time_offset_for_start(time_start)
if time_start=="2000" then
return EPOCH_2000_OFFSET
end
return 0
end
shared.copy_table=copy_table
shared.copy_keys=copy_keys
shared.merge_options=merge_options
shared.time_offset_for_start=time_offset_for_start
return shared
