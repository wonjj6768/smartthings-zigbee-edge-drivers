local x,l,m,s,q,v=require"st.zigbee.data_types",require"st.zigbee.constants",require"st.zigbee.zcl",require"st.zigbee.messages",require"st.zigbee.generic_body",{EF00_CLUSTER=61184,GET_DATA=1,SET_DATA_RESPONSE=2,REPORT_STATUS=5,ACTIVE_STATUS_REPORT=6,MCU_VERSION_RESPONSE=17,SET_TIME=36,CONNECTION_STATUS=37}require"protocol.tuya.runtime.read_only_datapoints"(v,true)
local function t(a,f,payload,j)
j=j or v.EF00_CLUSTER
local p=a:get_endpoint(j)if not p then return false end
local r=m.ZclHeader{cmd=x.ZCLCommandId(f)}if j~=0 then r.frame_ctrl:set_cluster_specific()end
r.frame_ctrl:set_disable_default_response()a:send(s.ZigbeeMessageTx{address_header=s.AddressHeader(l.HUB.ADDR,l.HUB.ENDPOINT,a:get_short_address(),p,l.HA_PROFILE_ID,j),body=m.ZclMessageBody{zcl_header=r,zcl_body=q.GenericBody(payload)}})return true
end
function v.build_base_preset(b)
local e={datapoints=b.datapoints,zcl_clusters=b.zcl_clusters}
function e:start_configuration(a)
local k=false
if b.magic_packet==true then k=self:send_magic_packet(a)end
if b.query_on_configure==true then return self:send_state_request(a)end
return k
end
function e:start_query_timer(...)return false end
function e:stop_query_timer(...)return false end
function e:send_magic_packet(a)
if b.magic_packet~=true then return false end
return t(a,0,string.pack("<I2I2I2I2I2I2",4,0,1,5,7,65534),0)
end
function e:send_state_request(a)
if b.query_on_configure~=true and b.query_on_announce~=true then return false end
return t(a,b.query_command_id or 3,"")
end
function e:apply_preferences_changed(...)return false end
function e:apply_announce(a)
local k=false
if type(b.announce_handler)=="function"then
k=b.announce_handler(a,b)~=false
end
if b.query_on_announce~=true then return k end
a.thread:call_with_delay(b.announce_delay or 0.5,function()self:send_state_request(a)end)
return true
end
function e:send_named_mapping(a,C,A,n)
local y=n and n.component_id or"main"for _,d in ipairs(self.datapoints or{})do
if d.name==C and d.read_only~=true and(d.component or"main")==y then
local o,c=d.to_device or(d.converter and d.converter.to),A
if o then c=o(A,a,n)end
if o and c==nil then return false end
local h,payload=d.datatype
if h==1 and type(c)=="boolean"then
payload=string.char(c and 1 or 0)elseif(h==2 or h==4)and type(c)=="number"and c%1==0
and c>=0 and c<=(h==4 and 255 or 4294967295)then
payload=h==4 and string.char(c)or string.pack(">I4",c)else
return false
end
local u=((a:get_field"__tuya_hybrid_sequence"or 0)+1)%65536
a:set_field("__tuya_hybrid_sequence",u)return t(a,d.command_id or 0,string.pack(">I2",u)..string.char(d.dp,h)..string.pack(">I2",#payload)..payload)end
end
return false
end
function e:apply_message(a,i)
local f=i.body and i.body.zcl_header and i.body.zcl_header.cmd.value
if f==37 and b.auto_connection_status~=false then
local payload=i.body.zcl_body and i.body.zcl_body.body_bytes
if type(payload)=="string"and #payload>=2 then
return t(a,37,string.char(1,0,1))end
return false
end
if b.force_time_updates==true and b.time_start~="off"and
(f==1 or f==2 or f==5 or f==6 or f==36)then
local w=os.time()if w>(a:get_field"__tuya_hybrid_time_due"or 0)then
local z,B=b.time_start=="2000"and 946684800 or 0,os.date("!*t",w)
B.isdst=false
local D=os.difftime(w,os.time(B))a:set_field("__tuya_hybrid_time_due",w+3600)t(a,36,string.pack(">I2I4I4",8,w-z,w+D-z))end
end
return v.apply_read_only_datapoints(a,i,self.datapoints)
end
return e
end
return v
