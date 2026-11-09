local function t(l)
local s,aa=require"runtime.battery_refresh",require"zcl_common.on_off_ack"
function l.is_duplicate_attribute_event(b,k,a)
if type(k)~="table"or k.state_change==true or type(b.get_latest_state)~="function"then
return false
end
local C,v=type(k.capability)=="table"and k.capability.ID or nil,type(k.attribute)=="table"and k.attribute.NAME or nil

if C==nil or v==nil then
return false
end
local R=k.value
if type(R)~="table"then
return false
end
local d=R.value
for ad in pairs(R)do
if ad~="value"and ad~="unit"then
return false
end
end
local A=type(d)if A~="number"and A~="string"and A~="boolean"then
return false
end
local U=a.component and a.component.id or"main"return b:get_latest_state(U,C,v)==d
end
local function X(d,N)
if d==nil or N==nil or N==1 then
return d
end
if type(d)=="number"and type(N)=="number"and N~=0 then
return d/N
end
return d
end
local function I(d,Q,i,b,a,h)
if i.from_device~=nil then
return i.from_device(d,b,a,h)end
return Q
end
local function P(i)
local B=i and i.attribute_def or nil
local S=B and B.base_type or nil
return type(S)=="table"and S.NAME or nil
end
local function D(n)
if type(n)~="string"then
return false
end
return n=="Boolean"or
n=="SemiPrecisionFloat"or
n=="SinglePrecisionFloat"or
n=="DoublePrecisionFloat"or
n=="TimeOfDay"or
n=="Date"or
n=="UtcTime"or
n=="IeeeAddress"or
n=="SecurityKey"or
n:match"^Uint%d+$"~=nil or
n:match"^Int%d+$"~=nil or
n:match"^Enum%d+$"~=nil or
n:match"String$"~=nil
end
local function o(c,i,a)
local u=a.typed_value
if u==nil or u==c or type(u)~="table"then
return false
end
if i.prefer_typed_value then
return true
end
if not i.custom_from_device then
return false
end
local T=P(i)if T~=nil then
return not D(T)end
return type(c)~="number"and type(c)~="boolean"and type(c)~="string"
end
local function O(c,i,b,a,h)
local q=l.scale_mapping_value and
l.scale_mapping_value(b,h,c,i,a)or
X(c,i.scale)a.scaled_value=q
local J=o(c,i,a)and
a.typed_value or
q
return I(J,q,i,b,a,h)
end
local function K(b,k,a)
if k==nil then
return
end
s.maybe_schedule_after_event(b,k)if l.is_duplicate_attribute_event(b,k,a)then
return
end
if a.component~=nil and type(b.emit_component_event)=="function"then
b:emit_component_event(a.component,k)return
end
if a.endpoint~=nil and type(b.emit_event_for_endpoint)=="function"then
b:emit_event_for_endpoint(a.endpoint,k)return
end
b:emit_event(k)
end
local function Y(b,E,a)
if E==nil then
return
end
if type(E)=="table"and E[1]~=nil then
for _,k in ipairs(E)do
K(b,k,a)end
return
end
K(b,E,a)
end
local function r(m)
if type(m)~="table"then
return nil
end
local ac=m.address_header and
m.address_header.src_endpoint and
m.address_header.src_endpoint.value or nil
return l.normalize_endpoint(ac)
end
local function H(m)
if type(m)~="table"then
return nil
end
local p=m.body and m.body.zcl_header or nil
local y=p and p.frame_ctrl or nil
if y==nil or type(y.is_mfg_specific_set)~="function"or not y:is_mfg_specific_set()then
return nil
end
local z=p.mfg_code and p.mfg_code.value or nil
return type(z)=="number"and z or nil
end
local function g(d)
if type(d)=="table"and d.value~=nil then
return d.value
end
return d
end
local function x(b,h,c,f)
if h==nil then
return nil
end
local i=l.mapping_meta(h)if i==nil or i.write_only then
return nil
end
local a=l.build_mapping_context(b,h,f,c)a.raw_value=c
a.typed_value=f and f.typed_value or c
local d
if a.command_result then
d=c
else
d=O(c,i,b,a,h)end
if d==nil then
return nil
end
a.value=d
if l.handle_metering_value~=nil then
l.handle_metering_value(b,h,d,i,a)end
if l.handle_switch_state~=nil and i.cluster_id==l.CLUSTER_ON_OFF and i.attribute_id==l.ATTR_ON_OFF then
l.handle_switch_state(b,a.zcl_clusters or nil,d)end
if i.handler~=nil then
i.handler(b,d,a,h)end
if i.emit~=nil then
Y(b,i.emit(b,d,a,h),a)end
return d
end
function l.apply_attribute(b,W,j,e,c,f)
if j==1026 and e==0 and g(c)==-32768 then
return false
end
if j==1 and(e==32 or e==33)and g(c)==255 then
return false
end
local w=f or{}local V=l.find_mappings(W,j,e,b,w)if V[1]==nil then
return false
end
local G=false
for _,h in ipairs(V)do
if x(b,h,c,w)~=nil then
G=true
end
end
if G and w.zb_rx~=nil and j==l.CLUSTER_ON_OFF and e==l.ATTR_ON_OFF then
aa.clear(b,w.endpoint or w.src_endpoint)end
if G and j==1 and(e==32 or e==33)then
s.note_report(b)end
return G
end
function l.build_zigbee_attr_handlers(Z)
local function L(j,e)
return function(_,b,d,ab)
local M=Z(b)if M and M.zcl_clusters then
local F,z,c=r(ab),H(ab),g(d)local f={cluster_id=j,attribute_id=e,zb_rx=ab,src_endpoint=F,endpoint=F,mfg_code=z,typed_value=d,zcl_clusters=M.zcl_clusters}l.handle_internal_attribute(b,j,e,d,f)l.apply_attribute(b,M.zcl_clusters,j,e,c,f)end
end
end
return l.build_attribute_handlers(L)
end
end
return t
