local o,a=require"log",{}a.log=o
a.BASIC_CLUSTER=0
a.TUYA_CLUSTER=61184
a.MAGIC_PACKET_ATTRS={4,0,1,5,7,65534}a.PERSIST_FALSE={persist=false}a.EPOCH_2000_OFFSET=946684800
a.PACKET_ID_FIELD="tuya_packet_id"a.CONFIG_QUEUE_FIELD="config_queue"a.CONFIG_QUEUE_CALLBACK_FIELD="config_queue_callback"a.QUERY_INTERVAL_TIMER_FIELD="tuya_query_interval_timer"a.BASIC_ENDPOINT_FIELD="tuya_basic_endpoint"a.TUYA_ENDPOINT_FIELD="tuya_cluster_endpoint"a.SET_DATA=0
a.GET_DATA=1
a.SET_DATA_RESPONSE=2
a.QUERY_DATA=3
a.SEND_DATA=4
a.REPORT_STATUS=5
a.ACTIVE_STATUS_REPORT=6
a.MCU_VERSION_REQUEST=16
a.MCU_VERSION_RESPONSE=17
a.SET_TIME=36
a.CONNECTION_STATUS=37
a.DEFAULT_MCU_VERSION_TRANSACTION=2
a.DP_TYPE_RAW=0
a.DP_TYPE_BOOL=1
a.DP_TYPE_VALUE=2
a.DP_TYPE_STRING=3
a.DP_TYPE_ENUM=4
a.DP_TYPE_BITMAP=5
a.string_byte=string.byte
a.string_char=string.char
a.string_pack=string.pack
a.string_sub=string.sub
a.string_len=string.len
a.math_floor=math.floor
a.type_check=type
a.table_insert=table.insert
a.table_remove=table.remove
a.table_concat=table.concat
a.os_time=os.time
a.tonumber_check=tonumber
function a.apply_constants(b)
b.BASIC_CLUSTER=a.BASIC_CLUSTER
b.EF00_CLUSTER=a.TUYA_CLUSTER
b.EPOCH_2000_OFFSET=a.EPOCH_2000_OFFSET
b.SET_DATA=a.SET_DATA
b.GET_DATA=a.GET_DATA
b.SET_DATA_RESPONSE=a.SET_DATA_RESPONSE
b.QUERY_DATA=a.QUERY_DATA
b.SEND_DATA=a.SEND_DATA
b.REPORT_STATUS=a.REPORT_STATUS
b.ACTIVE_STATUS_REPORT=a.ACTIVE_STATUS_REPORT
b.MCU_VERSION_REQUEST=a.MCU_VERSION_REQUEST
b.MCU_VERSION_RESPONSE=a.MCU_VERSION_RESPONSE
b.SET_TIME=a.SET_TIME
b.CONNECTION_STATUS=a.CONNECTION_STATUS
b.DEFAULT_MCU_VERSION_TRANSACTION=a.DEFAULT_MCU_VERSION_TRANSACTION
b.DP_TYPE_RAW=a.DP_TYPE_RAW
b.DP_TYPE_BOOL=a.DP_TYPE_BOOL
b.DP_TYPE_VALUE=a.DP_TYPE_VALUE
b.DP_TYPE_STRING=a.DP_TYPE_STRING
b.DP_TYPE_ENUM=a.DP_TYPE_ENUM
b.DP_TYPE_BITMAP=a.DP_TYPE_BITMAP
b.converter={}b.skip={}
end
local f,g=a.type_check,a.EPOCH_2000_OFFSET

local function j(d)
local c={}if f(d)~="table"then
return c
end
for i,l in pairs(d)do
c[i]=l
end
return c
end
local function m(c,d,n)
if f(d)~="table"then
return c
end
for _,i in ipairs(n)do
if d[i]~=nil then
c[i]=d[i]end
end
return c
end
local function h(c,d)
if f(d)~="table"then
return c
end
for i,l in pairs(d)do
c[i]=l
end
return c
end
local function e(k)
if k=="2000"then
return g
end
return 0
end
a.copy_table=j
a.copy_keys=m
a.merge_options=h
a.time_offset_for_start=e
return a
