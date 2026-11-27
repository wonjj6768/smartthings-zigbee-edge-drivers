local function al(j)
local o,x=require"zcl_common.attribute_reader"(j)local ao,q,aC,B,Q,as,aL,aB,ak,at,V,D=require"st.zigbee.cluster_base",require"st.zigbee.data_types",require"st.zigbee.messages",require"st.zigbee.constants",require"st.zigbee.zcl.clusters",require"st.zigbee.zcl",require"st.zigbee.zcl.frame_ctrl",require"st.zigbee.generic_body",require"log",require"zcl_common.on_off_ack","__default",{}
local function s(
b,h,p,H,f,G,A,w)local N=aL(0)N:set_cluster_specific()if G=="client"then
N:set_direction_client()end
if A~=nil then
N:set_mfg_specific()end
if w then
N:set_disable_default_response()end
local av={cmd=q.ZCLCommandId(p),frame_ctrl=N}if A~=nil then
av.mfg_code=q.Uint16(A)end
return o(b,aC.ZigbeeMessageTx{address_header=aC.AddressHeader(B.HUB.ADDR,B.HUB.ENDPOINT,b:get_short_address(),b:get_endpoint(h),B.HA_PROFILE_ID,h),body=as.ZclMessageBody{zcl_header=as.ZclHeader(av),zcl_body=aB.GenericBody(H or"")}},f)
end
local function m(b,h,p,H,f,G)
return s(b,h,p,H,f,G,nil)
end
local function J(b,h,p,A,H,f,G)
return s(b,h,p,H,f,G,A)
end
local function P(b,h,t,value,i,f)
return o(b,ao.write_attribute(b,q.ClusterId(h),q.AttributeId(t),i(value)),f)
end
local function E(b,h,t,A,value,i,f)
return o(b,ao.write_manufacturer_specific_attribute(b,h,t,A,i,value),f)
end
local function v(b,k,value,f)
return o(b,k:write(b,k(value)),f)
end
local function r(value,aN,aM)
return math.max(aN,math.min(aM,math.floor(value)))
end
local function encode_uint16_le(value)
return string.char(bit32.band(value,255))..string.char(bit32.rshift(bit32.band(value,65280),8))
end
local function S(c,i,d)
if type(c)~="number"or type(i)~="table"then
return c
end
local aS={Uint8={0,255},Uint16={0,65535},Uint24={0,0xFFFFFF},Uint32={0,0xFFFFFFFF},Int8={-128,127},Int16={-32768,32767},Int24={-8388608,8388607},Int32={-0x80000000,0x7FFFFFFF},Enum8={0,255}}local aJ=aS[i.NAME]if aJ==nil then
return c
end
local aw=math.max(aJ[1],math.min(aJ[2],math.floor(c+0.5)))if aw~=c then
ak.warn(string.format("ZCL write value clamped for cluster 0x%04X attribute 0x%04X name '%s': %s -> %s",d and d.cluster_id or 0,d and d.attribute_id or 0,tostring(d and d.name or"unknown"),tostring(c),tostring(aw)))end
return aw
end
local function ae(i)
return type(i)=="table"and i.NAME or nil
end
local function C(i)
local ap=ae(i)if type(ap)~="string"then
return false
end
return ap:match"^Uint"~=nil or ap:match"^Int"~=nil or ap:match"^Enum"~=nil
end
local function I(d)
if type(d)~="table"then
return false
end
if d.prefer_plain_attribute_write==true then
return true
end
if d.mfg_code~=nil then
return true
end
if type(d.attribute_id)=="number"and d.attribute_id>=32768 then
return true
end
return false
end
local function aq(d,aA)
if d.write_type~=nil then
return d.write_type
end
if d.attribute_def~=nil and d.attribute_def.base_type~=nil then
return d.attribute_def.base_type
end
if type(aA)=="boolean"then
return q.Boolean
end
return nil
end
local function ah(b,e,value,a,d)
local c=value
if d.to_device~=nil then
c=d.to_device(value,b,a,e)end
if type(c)=="string"and type(e)=="table"then
local u=type(e.converter)=="table"and e.converter or nil
local W=u and type(u.to)=="function"and u.to or nil
if W~=nil then
local Z=W(c,b,a,e)if Z~=nil then
c=Z
end
end
end
if c==nil then
return nil
end
if type(c)=="number"and type(d.scale)=="number"and d.scale~=0 and d.scale~=1 then
c=math.floor(c*d.scale)end
return c
end
local function T(b,c,e,a,d)
local i=d and d.write_type or nil
local az=ae(i)if az==nil or not tostring(az):match"^Enum"then
return c
end
if type(c)=="number"then
return c
end
local ac,u=type(a)=="table"and a.raw_value or c,type(e)=="table"and type(e.converter)=="table"and e.converter or nil

local F=u and type(u.to)=="function"and u.to or nil
if F~=nil then
local ay=F(ac,b,a,e)if type(ay)=="number"then
return ay
end
end
local aH=tonumber(c)if type(aH)=="number"then
return aH
end
ak.warn(string.format("ZCL enum write conversion failed for cluster 0x%04X attribute 0x%04X name '%s': raw=%s encoded=%s",d and d.cluster_id or 0,d and d.attribute_id or 0,tostring(d and d.name or"unknown"),tostring(ac),tostring(c)))return nil
end
local function U(b,e,a,d,c)
if type(e)~="table"then
return c
end
local u=type(e.converter)=="table"and e.converter or nil
local F=u and type(u.to)=="function"and u.to or nil
if F==nil then
return c
end
local ac=type(a)=="table"and a.raw_value or c
local aI=F(ac,b,a,e)if aI~=nil then
return aI
end
return c
end
local function l(b,e,value,a)
local d=j.mapping_meta(e)if d==nil then
return nil
end
local c=value
if d.to_device~=nil then
c=d.to_device(value,b,a,e)end
return c
end
local function af(c)
if c==nil then
return{}end
if type(c)=="table"and c[1]~=nil then
return c
end
return{c}
end
local function ai(b,e,value,Y)
local d=j.mapping_meta(e)if d==nil or d.tx_command_id==nil or d.cluster_id==nil then
return false
end
local a=x(b,e,Y,value)local c=l(b,e,value,a)if d.to_device~=nil and c==nil then
return false
end
local y
if d.tx_command_direction=="client"then
y=j.get_generated_client_command and
j.get_generated_client_command(d.cluster_id,d.tx_command_id)or nil
else
y=j.get_generated_server_command and
j.get_generated_server_command(d.cluster_id,d.tx_command_id)or nil
end
if y~=nil and type(c)~="string"then
return o(b,y(b,table.unpack(af(c))),a.endpoint)end
if type(c)~="string"and c~=nil then
ak.warn(string.format("ZCL generic command fallback requires string payload for cluster 0x%04X command 0x%02X name '%s'",d.cluster_id,d.tx_command_id,tostring(d.name)))return false
end
if d.mfg_code~=nil then
return J(b,d.cluster_id,d.tx_command_id,d.mfg_code,c or"",a.endpoint,d.tx_command_direction)end
return m(b,d.cluster_id,d.tx_command_id,c or"",a.endpoint,d.tx_command_direction)
end
local function an(b,e,value,Y)
local d=j.mapping_meta(e)if d==nil then
return false
end
local a=x(b,e,Y,value)a.raw_value=value
local c=ah(b,e,value,a,d)if c==nil then
return false
end
local i=aq(d,c)if i==nil then
ak.warn(string.format("ZCL write requires explicit write_type/data_type for cluster 0x%04X attribute 0x%04X name '%s'",d.cluster_id or 0,d.attribute_id or 0,tostring(d.name)))return false
end
if type(c)~="number"then
c=U(b,e,a,d,c)end
c=T(b,c,e,a,d)if c==nil then
return false
end
if type(c)=="number"and C(i)then
c=math.floor(c+0.5)end
if type(c)=="string"and C(i)then
ak.warn(string.format("ZCL write aborted because encoded value is still non-numeric for cluster 0x%04X attribute 0x%04X name '%s': %s",d.cluster_id or 0,d.attribute_id or 0,tostring(d.name),tostring(c)))return false
end
c=S(c,i,d)a.encoded_value=c
if d.mfg_code~=nil then
local ok,X=pcall(E,b,d.cluster_id,d.attribute_id,d.mfg_code,c,i,a.endpoint)if ok then
return X
end
ak.error(string.format("ZCL manufacturer write failed for cluster 0x%04X attribute 0x%04X name '%s': %s",d.cluster_id or 0,d.attribute_id or 0,tostring(d.name),tostring(X)))return false
end
if not I(d)and d.attribute_def~=nil and type(d.attribute_def.write)=="function"then
local ok,X=pcall(v,b,d.attribute_def,c,a.endpoint)if ok then
return X
end
ak.error(string.format("ZCL generated write failed for cluster 0x%04X attribute 0x%04X name '%s': %s",d.cluster_id or 0,d.attribute_id or 0,tostring(d.name),tostring(X)))return false
end
local ok,X=pcall(P,b,d.cluster_id,d.attribute_id,c,i,a.endpoint)if ok then
return X
end
ak.error(string.format("ZCL write failed for cluster 0x%04X attribute 0x%04X name '%s': %s",d.cluster_id or 0,d.attribute_id or 0,tostring(d.name),tostring(X)))return false
end
local function z(b,aT)
if type(b)~="table"or
type(b.get_profile_id)~="function"or
b:get_profile_id()~=B.ZLL_PROFILE_ID or
type(b.thread)~="table"or
type(b.thread.call_with_delay)~="function"or
type(b.refresh)~="function"then
return
end
b.thread:call_with_delay(2,function()
b:refresh()
end,aT)
end
local function aF(b,ag,a)
local M=type(a)=="table"and a.component_id or nil
local f=type(a)=="table"and a.endpoint or nil
local K=ag and
Q.OnOff.server.commands.On(b)or
Q.OnOff.server.commands.Off(b)if type(M)=="string"and M~=""and type(b.send_to_component)=="function"then
local aD=type(K.to_component)=="function"and K:to_component(b,M)or K
at.remember(b,ag,a,aD)b:send_to_component(M,K)z(b,ag and"on delayed read"or"off delayed read")return true
end
local aD=f~=nil and type(K.to_endpoint)=="function"and K:to_endpoint(f)or K
at.remember(b,ag,a,aD)if o(b,K,f)then
z(b,ag and"on delayed read"or"off delayed read")return true
end
return m(b,j.CLUSTER_ON_OFF,ag and 1 or 0,"",f)
end
local function aK(b,aP,ad,f)
local n=j.get_generated_server_command and
j.get_generated_server_command(j.CLUSTER_LEVEL_CONTROL,4)or nil
if n~=nil then
return o(b,n(b,q.Uint8(r(aP,0,254)),q.Uint16(r(ad or 0,0,65535)),0,0),f)end
local H=string.char(r(aP,0,254))..encode_uint16_le(r(ad or 0,0,65535))return m(b,j.CLUSTER_LEVEL_CONTROL,4,H,f)
end
local function am(b,O,f)
local n=j.get_generated_server_command and
j.get_generated_server_command(j.CLUSTER_WINDOW_COVERING,5)or nil
if n~=nil then
return o(b,n(b,q.Uint8(r(O,0,100))),f)end
return m(b,j.CLUSTER_WINDOW_COVERING,5,string.char(r(O,0,100)),f)
end
local function au(b,O,f)
local n=j.get_generated_server_command and
j.get_generated_server_command(j.CLUSTER_WINDOW_COVERING,8)or nil
if n~=nil then
return o(b,n(b,q.Uint8(r(O,0,100))),f)end
return m(b,j.CLUSTER_WINDOW_COVERING,8,string.char(r(O,0,100)),f)
end
local function ar(b,aG,f)
local aE={open=0,close=1,stop=2}local p=aE[aG]if p==nil then
ak.warn(string.format("ZCL unknown cover command: %s",tostring(aG)))return false
end
local n=j.get_generated_server_command and
j.get_generated_server_command(j.CLUSTER_WINDOW_COVERING,p)or nil
if n~=nil then
return o(b,n(b),f)end
return m(b,j.CLUSTER_WINDOW_COVERING,p,"",f)
end
function j.send_raw_cluster_command(
b,h,p,H,f,G,A,w)return s(b,h,p,H,f,G,A,w)
end
local function aa(b,R,f)
local k=j.get_generated_attribute and
j.get_generated_attribute(j.CLUSTER_THERMOSTAT,j.ATTR_OCCUPIED_HEATING_SETPOINT)or nil
if k~=nil and type(k.write)=="function"then
return v(b,k,math.floor(R*100),f)end
return P(b,j.CLUSTER_THERMOSTAT,j.ATTR_OCCUPIED_HEATING_SETPOINT,math.floor(R*100),q.Int16,f)
end
local function aj(b,aQ,f)
local k=j.get_generated_attribute and
j.get_generated_attribute(j.CLUSTER_THERMOSTAT,j.ATTR_SYSTEM_MODE)or nil
if k~=nil and type(k.write)=="function"then
return v(b,k,aQ,f)end
return P(b,j.CLUSTER_THERMOSTAT,j.ATTR_SYSTEM_MODE,aQ,q.Enum8,f)
end
function j.register_sender(h,t,ab)
if h==nil or type(ab)~="function"then
ak.warn(string.format("skip invalid zcl sender registration cluster=%s attribute=%s sender=%s",tostring(h),tostring(t),type(ab)))return nil
end
D[h]=D[h]or{}D[h][t or V]=ab
return ab
end
function j.get_sender(h,t)
local L=D[h]if L==nil then
return nil
end
return L[t]or L[V]
end
local function ax(e)
return j.get_sender(e.cluster_id,e.attribute_id)
end
j.register_sender(j.CLUSTER_ON_OFF,j.ATTR_ON_OFF,function(b,e,value,a)
return aF(b,value==true or value=="on"or value=="open",a)
end)
j.register_sender(j.CLUSTER_LEVEL_CONTROL,j.ATTR_LEVEL_CURRENT_LEVEL,function(b,e,value,a)
local c=l(b,e,value,a)if type(c)~="number"then
return false
end
return aK(b,c,a.transition_time,a.endpoint)
end)
j.register_sender(j.CLUSTER_WINDOW_COVERING,nil,function(b,e,value,a)
if type(value)=="string"then
return ar(b,value,a.endpoint)end
local c=l(b,e,value,a)if type(c)=="number"then
return am(b,c,a.endpoint)end
return false
end)
j.register_sender(j.CLUSTER_WINDOW_COVERING,j.ATTR_CURRENT_POSITION_TILT_PERCENTAGE,function(b,e,value,a)
local c=l(b,e,value,a)if type(c)=="number"then
return au(b,c,a.endpoint)end
return false
end)
j.register_sender(j.CLUSTER_THERMOSTAT,j.ATTR_OCCUPIED_HEATING_SETPOINT,function(b,e,value,a)
local c=l(b,e,value,a)if type(c)~="number"then
return false
end
return aa(b,c,a.endpoint)
end)
j.register_sender(j.CLUSTER_THERMOSTAT,j.ATTR_SYSTEM_MODE,function(b,e,value,a)
local c=l(b,e,value,a)if c==nil then
return false
end
return aj(b,c,a.endpoint)
end)
function j.send_named_command(b,Q,ap,value,Y)
local e=j.find_mapping_by_name(Q,ap,b,Y)if e==nil then
return false
end
local d=j.mapping_meta(e)if d==nil then
return false
end
if d.read_only then
ak.warn(string.format("ZCL send_named_command: mapping '%s' is read-only",tostring(ap)))return false
end
local a=j.build_mapping_context(b,e,Y,value)a.raw_value=value
if d.sender~=nil then
return d.sender(b,e,value,a)~=false
end
local ab=ax(e)if ab~=nil then
return ab(b,e,value,a)end
if d.tx_command_id~=nil then
return ai(b,e,value,a)end
if d.cluster_id==nil or d.attribute_id==nil then
return false
end
if an(b,e,value,a)then
return true
end
ak.warn(string.format("ZCL send_named_command: no sender for cluster 0x%04X attribute 0x%04X name '%s'",d.cluster_id,d.attribute_id,tostring(ap)))return false
end
end
return al
