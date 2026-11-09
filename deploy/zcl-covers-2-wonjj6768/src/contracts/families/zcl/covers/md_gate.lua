local v,af,ak,i,ac,C,M,m=require"protocol.zcl",require"capabilities.events.all",require"st.capabilities",require"st.zigbee.data_types",require"st.buf".Reader,require"st.zigbee.cluster_base",require"st.zigbee.device_management",require"contracts.helpers.family"
local B,W=m.definition_registry()local T,S,z,o,A,N,l,x="covers-md-gate-main","covers-md-gate-walk","mdGate:sensor_mode","mdGate:contacts","mdGate:requested_profile",{persist=true},{persist=false},af.mdGateState()
local function R(b)
return type(b)=="number"and b==b and b~=math.huge and b~=-math.huge
end
local function X(b)
return i.SinglePrecisionFloat.deserialize(ac(string.pack("<f",b)))
end
local function p(a)return a:supports_server_cluster(6,5)end
local h={main={"momentary","concertmirror08464.mdGateState","concertmirror08464.mdGatePulseDuration","refresh","signalStrength"},closedLimit={"contactSensor"},openLimit={"contactSensor"},walk={"momentary"}}
local function f(a)
local w,ah=a.profile.components,p(a)for Z in pairs(w)do
if h[Z]==nil or Z=="walk"and not ah then return false end
end
for Z,D in pairs(h)do
if Z~="walk"or ah then
local d=w[Z]if d==nil or #(d.capabilities or{})~=#D then return false end
for _,K in ipairs(D)do
if not a:supports_capability_by_id(K,Z)then return false end
end
end
end
return true
end
local function j(a)
local g,O=a:get_field(o)or{},"unknown"if type(g.closed)=="boolean"then
if a:get_field(z)~="two"then O=g.closed and"closed"or"open"elseif type(g.open)=="boolean"then
O=g.closed and(g.open and"sensor_error"or"closed")or(g.open and"open"or"intermediate")end
end
return O
end
local function y(a)
if a:supports_capability_by_id("concertmirror08464.mdGateState","main")then
a:emit_component_event({id="main"},x(a,j(a)))end
end
local function E(a,b)
if b~="one"and b~="two"then return false end
if a:get_field(z)~=b then
a:set_field(z,b,N)a:set_field(o,nil,l)y(a)end
return true
end
local function n(a)
local F=p(a)and S or T
if f(a)then a:set_field(A,nil,l)elseif a:get_field(A)~=F then
a:set_field(A,F,l)a:try_update_metadata{profile=F}end
end
local function ai(a,_,H)
local d=H and H.component or"main"local c=d=="main"and 1 or d=="walk"and 5 or nil
if not c or not f(a)or(c==5 and not p(a))then return false end
local ok,am=pcall(v.send_raw_cluster_command,a,6,1,"",c,nil,nil,true)return ok and am or false
end
local function u(b)
if R(b)and b%1==0 and b>=0 and b<=1000 then return X(b)end
end
local function U(a,aa,b)
local J=aa.to_device(b)if J==nil then return false end
local ab=C.write_attribute(a,i.ClusterId(13),i.AttributeId(85),J):to_endpoint(4)if not pcall(a.send,a,ab)then return false end
a.thread:call_with_delay(.25,function()pcall(v.read_attribute,a,13,85,4)end,
"MD gate duration readback250ms after enqueue")return true
end
local function G(a)
v.read_attribute(a,13,85,4)v.read_attribute(a,15,85,2)v.read_attribute(a,15,85,3)
end
local function e(a,c,Y,Q,al,ad)
a:send(M.attr_config(a,{cluster=Y,attribute=Q,data_type=al,minimum_interval=0,maximum_interval=65535,reportable_change=ad}):to_endpoint(c))
end
local function q(b)
if b==true or b==1 then return true end
if b==false or b==0 then return false end
end
local k={v.cluster_attribute(13,85,{name="md_gate_pulse_duration",endpoint=4,component="main",data_type=i.SinglePrecisionFloat,to_device=u,sender=U,suppress_optimistic_state=true,emit=af.mdGatePulseDuration(),
from_device=function(b,_,I)
local P=I and I.typed_value
if type(P)=="table"and P.ID==57 then b=string.unpack("<f",P:_serialize())end
if R(b)then return b end
end,
read_on_configure=false,read_on_refresh=false})}for _,L in ipairs{{2,"closed","closedLimit"},{3,"open","openLimit"}}do
local c,key,d=L[1],L[2],L[3]k[#k+1]=v.cluster_attribute(15,85,{name="md_gate_state",endpoint=c,component="main",data_type=i.Boolean,read_only=true,read_on_configure=false,read_on_refresh=false,
from_device=function(b,a)
local t=q(b)if t==nil then return end
local g=a:get_field(o)or{}g[key]=t
a:set_field(o,g,l)return j(a)
end,
emit=x})k[#k+1]=v.cluster_attribute(15,85,{name="md_gate_"..key.."_contact",endpoint=c,component=d,data_type=i.Boolean,read_only=true,read_on_configure=false,read_on_refresh=false,
from_device=function(b)
local t=q(b)if t~=nil then return t and"closed"or"open"end
end,
emit=function(_,b)return ak.contactSensor.contact(b)end
})end
local r,s={main=4,walk=5,closedLimit=2,openLimit=3},{[1]="main",[4]="main",[5]="walk",[2]="closedLimit",[3]="openLimit"}local ag={profile=T,auxiliary_profiles={S},valid_parent_profiles={[T]=true,[S]=true},parent_profile_matches=f,magic_packet=false,
component_to_endpoint=function(_,d)return r[d]end,
endpoint_to_component=function(_,c)return s[c]end,
protocol_writers={md_gate_pulse=ai},capability_commands={{capability_id="momentary",command_name="push",mapping_name="md_gate_pulse"}},
preferences_changed=function(a)E(a,a.preferences.mdGateSensorMode)end,
zcl_clusters=k,
runtime_start=function(a)
n(a)local V=a:get_field(z)E(a,a.preferences.mdGateSensorMode or a:get_field(z)or"one")if V==a:get_field(z)then y(a)end
end,
parent_refresh=G,
configure=function(ae,a)
n(a)e(a,1,6,0,i.Boolean)if p(a)then e(a,5,6,0,i.Boolean)end
e(a,4,13,85,i.SinglePrecisionFloat,X(100))v.read_attribute(a,13,85,4)for _,c in ipairs{2,3}do
v.bind_cluster(a,15,ae.environment_info.hub_zigbee_eui,c)e(a,c,15,85,i.Boolean)v.read_attribute(a,15,85,c)end
end
}W(ag,{m.create_fingerprint("MakeDIY","MD-GATE-ZB1")})return{id="zcl.covers.md_gate",registrations=B}
