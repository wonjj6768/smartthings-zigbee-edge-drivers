local R,V,x,P,u=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.capabilities",require"st.zigbee.device_management"local E,s=x.definition_registry()local C,c,h,i,o,t=257,268,1,8,"bridge-wave19-sunricher-dali-dimmer-child","bridge-wave19-sunricher-dali-cct-child"




local function L(a)
return string.format("%02X",a)
end
local function l(b)
local M=b and b.parent_assigned_child_key
if type(M)~="string"or M:match"^%x%x$"==nil then return nil end
local a=tonumber(M,16)if a==nil or a<h or a>i then
return nil
end
return a
end
local function B(b,a)
return b and b.zigbee_endpoints and b.zigbee_endpoints[a]or nil
end
local function d(b,a)
local I=B(b,a)return I and I.device_id or nil
end
local function e(b,a)
local device_id=d(b,a)return device_id==C or device_id==c
end
local function z(b,a)
if d(b,a)==c then
return t
end
return o
end
local function f(b,g)
local m=b.profile and b.profile.components
if type(m)~="table"or m.main==nil then return false end
for Q in pairs(m)do if Q~="main"then return false end end
return b:supports_capability_by_id("switch","main")and
b:supports_capability_by_id("switchLevel","main")and
b:supports_capability_by_id("refresh","main")and
b:supports_capability_by_id("colorTemperature","main")==g
end
local function r(a,O,q)
local M=L(a)
return function(b,aa,Y,Z)
local device_id=d(b,a)if not e(b,a)or
(q~=nil and device_id~=q)then
return nil
end
local p=b:get_child_by_parent_assigned_key(M)if p==nil or not f(p,device_id==c)then return nil end
local W=O(p,aa,Y,Z)if W~=nil then p:emit_event(W)end
return nil
end
end
local function y(F,b)
if type(b.zigbee_endpoints)~="table"then return end
for a=h,i do
local M=L(a)local p=b:get_child_by_parent_assigned_key(M)if e(b,a)then
local T=z(b,a)if p~=nil then
if not f(p,d(b,a)==c)then
p:try_update_metadata{profile=T}end
else
F:try_create_device{type="EDGE_CHILD",parent_assigned_child_key=M,parent_device_id=b.id,label=string.format("%s DALI %d",b.label,a),profile=T}end
elseif p~=nil and type(F.try_delete_device)=="function"then
F:try_delete_device(p.id)end
end
end
local function G(j,b)
local a=l(b)if a==nil or not e(j,a)then return false end
local H=z(j,a)if not f(b,d(j,a)==c)then
b:try_update_metadata{profile=H}end
return true
end
local function A(b,_,j)
local a=l(b)if a==nil or d(j,a)~=c then
return
end
if not f(b,true)then return end
b:emit_component_event({id="main"},P.colorTemperature.colorTemperatureRange{value={minimum=2000,maximum=6667},unit="K"})
end
local function D(b)
if type(b)~="table"or type(b.get_parent_device)~="function"then
return nil
end
return b:get_parent_device()
end
local function k(b,a,g)
R.read_attribute(b,6,0,a)R.read_attribute(b,8,0,a)if g then
R.read_attribute(b,768,8,a)R.read_attribute(b,768,7,a)end
end
local function N(b)
local j,a=D(b),l(b)if a==nil or not e(j,a)then return end
k(b,a,d(j,a)==c)
end
local function J(b)
if type(b.zigbee_endpoints)~="table"then return end
for a=h,i do
if e(b,a)then
k(b,a,d(b,a)==c)end
end
end
local function w(b,Q)
local j,a=D(b),l(b)if a==nil or not e(j,a)then return false end
if not f(b,d(j,a)==c)then return false end
if Q=="switch"or Q=="brightness"then return true end
return Q=="color_temperature"and
d(j,a)==c
end
local function U(F,b)
local S=F.environment_info.hub_zigbee_eui
for a=h,i do
if e(b,a)then
for _,X in ipairs{6,8}do
b:send(u.build_bind_request(b,X,S,a))end
local g=
d(b,a)==c
if g then
b:send(u.build_bind_request(b,768,S,a))end
k(b,a,g)end
end
end
local n={}for a=h,i do
n[#n+1]=R.switch{endpoint=a,configure_reporting=false,emit=r(a,V.switch())}n[#n+1]=R.level{endpoint=a,configure_reporting=false,emit=r(a,V.level())}n[#n+1]=R.color_temperature{endpoint=a,configure_reporting=false,emit=r(a,V.color_temperature(),c)}end
local K={profile="bridge-wave19-sunricher-dali-parent",
parent_profile_matches=function(b)
local m=b.profile and b.profile.components
return type(m)=="table"and m.main~=nil and
b:supports_capability_by_id("refresh","main")and
not b:supports_capability_by_id("switch","main")and
not b:supports_capability_by_id("switchLevel","main")
end,
auxiliary_profiles={o,t},package_group="wave19-dali",zcl_clusters=n,allow_child_devices=true,is_expected_child=G,create_child_devices=y,child_runtime_start=A,child_refresh=N,parent_refresh=J,child_command_allowed=w,configure=U}s(K,{x.create_fingerprint("Sunricher","Light")})return{id="zcl.lights.wave19_dali",registrations=E}
