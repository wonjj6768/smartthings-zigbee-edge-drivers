local E,s,p,D,K,k,J,ab,F=require"st.zigbee.data_types",require"st.zigbee.constants",require"st.zigbee.zcl",require"st.zigbee.messages",require"st.zigbee.generic_body",require"st.zigbee.zcl.global_commands.read_attribute",require"st.zigbee.cluster_base",require"st.utils",require"tuya_common.foundation"local ad,a=F.log,{}
for ac,f in pairs(F)do
a[ac]=f
end
a.data_types=E
a.constants=s
a.zcl_messages=p
a.messages=D
a.generic_body=K
a.read_attribute=k
a.cluster_base=J
a.utils=ab
a.REPORT_COMMANDS={[a.GET_DATA]=true,[a.SET_DATA_RESPONSE]=true,[a.REPORT_STATUS]=true,[a.ACTIVE_STATUS_REPORT]=true}local m,r,n,w,P,A,B,R,x,d,M=a.BASIC_CLUSTER,a.PACKET_ID_FIELD,a.PERSIST_FALSE,a.BASIC_ENDPOINT_FIELD,a.string_byte,a.string_char,a.string_pack,a.string_len,a.math_floor,a.type_check,a.table_concat










local function H(j)
local e=j:get_field(r)if d(e)~="number"or e%1~=0 then
e=0
end
local u=e+1
if u>=65536 then
u=1
end
j:set_field(r,u,n)return u
end
local function h(j,Q,o)
local T=o and j:get_field(o)or nil
if T then
return T
end
local g=j:get_endpoint(Q)if g and o then
j:set_field(o,g,n)end
return g
end
local function t(c)
if d(c)=="string"then
return c
end
if d(c)~="table"then
return nil
end
return c.body and c.body.zcl_body and c.body.zcl_body.body_bytes or nil
end
local function z(c)
if d(c)~="table"then
return nil
end
return c.body and
c.body.zcl_header and
c.body.zcl_header.cmd and
c.body.zcl_header.cmd.value or nil
end
local function q(c)
if d(c)~="table"then
return nil
end
local g=c.address_header and
c.address_header.src_endpoint and
c.address_header.src_endpoint.value or nil
if d(g)=="number"then
return g
end
return nil
end
local function i(j,V)
local g=h(j,m,w)if not g then
ad.warn(string.format("Cluster 0x%04X endpoint not found",m))return nil
end
local S,G=p.ZclHeader{cmd=E.ZCLCommandId(k.ReadAttribute.ID)},D.AddressHeader(s.HUB.ADDR,s.HUB.ENDPOINT,j:get_short_address(),g,s.HA_PROFILE_ID,m)local L=p.ZclMessageBody{zcl_header=S,zcl_body=k.ReadAttribute(V)}return D.ZigbeeMessageTx{address_header=G,body=L}
end
local function C(Z)
local X={}for aa,W in ipairs(Z or{})do
if d(W)~="number"then
return nil
end
local b=x(W)if b~=W or b<0 or b>255 then
return nil
end
X[aa]=A(b)end
return M(X)
end
local function U(f)
if d(f)=="string"then
return f
end
if d(f)=="table"then
return C(f)end
return nil
end
local function N(f)
if d(f)~="number"then
return nil
end
local b=x(f)if b~=f or b<0 then
return nil
end
f=b
if f<=255 then
return A(f)elseif f<=65535 then
return B(">I2",f)elseif f<=0xFFFFFFFF then
return B(">I4",f)end
return nil
end
local function O(Y)
if Y then
return{persist=true}end
return n
end
local function v(l)
if l==nil then
return nil
end
if d(l)~="number"then
return nil
end
local b=x(l)if b~=l then
return nil
end
b=b%65536
if b<0 then
b=b+65536
end
return b
end
local function y(c)
local I=t(c)if I and R(I)>=2 then
return P(I,2)end
return nil
end
a.next_packet_id=H
a.resolve_cluster_endpoint=h
a.extract_payload=t
a.extract_command_id=z
a.extract_source_endpoint=q
a.build_basic_read_attributes_message=i
a.raw_bytes=U
a.pack_bitmap=N
a.persist_opt=O
a.normalize_transaction=v
a.extract_transaction=y
return a
