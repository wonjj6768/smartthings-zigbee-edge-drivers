local data_types=require"st.zigbee.data_types"
local constants=require"st.zigbee.constants"
local zcl_messages=require"st.zigbee.zcl"
local messages=require"st.zigbee.messages"
local generic_body=require"st.zigbee.generic_body"
local tuya={
EF00_CLUSTER=0xEF00,GET_DATA=0x01,SET_DATA_RESPONSE=0x02,REPORT_STATUS=0x05,ACTIVE_STATUS_REPORT=0x06,MCU_VERSION_RESPONSE=0x11,SET_TIME=0x24,CONNECTION_STATUS=0x25,}require"protocol.tuya.runtime.read_only_datapoints"(tuya,true)
local function send(device,command,payload,cluster)
cluster=cluster or tuya.EF00_CLUSTER
local endpoint=device:get_endpoint(cluster)
if not endpoint then return false end
local header=zcl_messages.ZclHeader({cmd=data_types.ZCLCommandId(command)})
if cluster~=0 then header.frame_ctrl:set_cluster_specific()end
header.frame_ctrl:set_disable_default_response()device:send(messages.ZigbeeMessageTx({
address_header=messages.AddressHeader(constants.HUB.ADDR,constants.HUB.ENDPOINT,device:get_short_address(),endpoint,constants.HA_PROFILE_ID,cluster),body=zcl_messages.ZclMessageBody({zcl_header=header,zcl_body=generic_body.GenericBody(payload)}),}))return true
end
function tuya.build_base_preset(options)
local preset={datapoints=options.datapoints,zcl_clusters=options.zcl_clusters}
function preset:start_configuration(device)
local handled=false
if options.magic_packet==true then handled=self:send_magic_packet(device)end
if options.query_on_configure==true then return self:send_state_request(device)end
return handled
end
function preset:start_query_timer(...)return false end
function preset:stop_query_timer(...)return false end
function preset:send_magic_packet(device)
if options.magic_packet~=true then return false end
return send(device,0,string.pack("<I2I2I2I2I2I2",4,0,1,5,7,0xFFFE),0)
end
function preset:send_state_request(device)
if options.query_on_configure~=true and options.query_on_announce~=true then return false end
return send(device,options.query_command_id or 3,"")
end
function preset:apply_preferences_changed(...)return false end
function preset:apply_announce(device)
local handled=false
if type(options.announce_handler)=="function"then
handled=options.announce_handler(device,options)~=false
end
if options.query_on_announce~=true then return handled end
device.thread:call_with_delay(options.announce_delay or 0.5,function()self:send_state_request(device)end)
return true
end
function preset:send_named_mapping(device,name,value,context)
local component=context and context.component_id or"main"
for _,mapping in ipairs(self.datapoints or{})do
if mapping.name==name and mapping.read_only~=true and(mapping.component or"main")==component then
local convert=mapping.to_device or(mapping.converter and mapping.converter.to)local encoded=value
if convert then encoded=convert(value,device,context)end
if convert and encoded==nil then return false end
local datatype,payload=mapping.datatype
if datatype==1 and type(encoded)=="boolean"then
payload=string.char(encoded and 1 or 0)elseif(datatype==2 or datatype==4)and type(encoded)=="number"and encoded%1==0
and encoded>=0 and encoded<=(datatype==4 and 255 or 4294967295)then
payload=datatype==4 and string.char(encoded)or string.pack(">I4",encoded)else
return false
end
local sequence=((device:get_field("__tuya_hybrid_sequence")or 0)+1)%65536
device:set_field("__tuya_hybrid_sequence",sequence)return send(device,mapping.command_id or 0,string.pack(">I2",sequence)..string.char(mapping.dp,datatype)..string.pack(">I2",#payload)..payload)
end
end
return false
end
function preset:apply_message(device,message)
local command=message.body and message.body.zcl_header and message.body.zcl_header.cmd.value
if command==0x25 and options.auto_connection_status~=false then
local payload=message.body.zcl_body and message.body.zcl_body.body_bytes
if type(payload)=="string"and #payload>=2 then
return send(device,0x25,string.char(1,0,1))
end
return false
end
if options.force_time_updates==true and options.time_start~="off"and
(command==1 or command==2 or command==5 or command==6 or command==0x24)then
local now=os.time()if now>(device:get_field("__tuya_hybrid_time_due")or 0)then
local offset=options.time_start=="2000"and 946684800 or 0
local utc=os.date("!*t",now)utc.isdst=false
local zone=os.difftime(now,os.time(utc))device:set_field("__tuya_hybrid_time_due",now+3600)send(device,0x24,string.pack(">I2I4I4",8,now-offset,now+zone-offset))
end
end
return tuya.apply_read_only_datapoints(device,message,self.datapoints)
end
return preset
end
return tuya
