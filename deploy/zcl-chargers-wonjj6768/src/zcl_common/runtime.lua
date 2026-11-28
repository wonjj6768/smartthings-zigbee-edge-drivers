local function ai(N)
local P,ag,ad,S,T="__zcl_mapping_bucket",setmetatable({},{__mode="k"}),setmetatable({},{__mode="k"}),setmetatable({},{__mode="k"}),require"runtime.capability_support".is_callable
local function l(g)
if type(g)~="number"or g%1~=0 then
return nil
end
return g
end
local function p(d,b)
if type(b)~="table"then
return nil
end
local e=b.component_id or b.component
if type(e)=="string"and e~=""then
return e
end
local g=l(b.endpoint or b.src_endpoint)if g~=nil and type(d.get_component_id_for_endpoint)=="function"then
local G=d:get_component_id_for_endpoint(g)if type(G)=="string"and G~=""then
return G
end
end
return nil
end
local function m(d,b)
if type(b)~="table"then
return nil
end
local g=l(b.endpoint or b.src_endpoint)if g~=nil then
return g
end
local e=b.component_id or b.component
if type(e)=="string"and e~=""and type(d.get_endpoint_for_component_id)=="function"then
local G=d:get_endpoint_for_component_id(e)if type(G)=="table"then
G=G[1]end
return l(G)end
return nil
end
local function y(a,ak)
local aa=ag[a]if aa~=nil then
return aa
end
local B,Q=type(a.converter)=="table"and a.converter or nil,type(a.from_device)=="function"and a.from_device or nil

local M=B and type(B.from)=="function"and B.from or nil
local ab=a.prefer_typed_value==true or
(B and B.prefer_typed_value==true)or
false
local C=T(a.data_type)and a.data_type or nil
local L=T(a.write_type)and a.write_type or C
local o
if a.cluster_id~=nil and a.attribute_id~=nil and N.get_generated_attribute~=nil then
o=N.get_generated_attribute(a.cluster_id,a.attribute_id)end
if o==nil and a.cluster_id~=nil and a.attribute_id~=nil and N.build_dynamic_attribute~=nil then
local R=C or L
if R~=nil then
o=N.build_dynamic_attribute(a.cluster_id,a.attribute_id,R,a.read_only~=true,a.attribute_name,a.complex_type==true)end
end
local ah={from_device=Q or M,custom_from_device=Q~=nil,converter_from_device=M~=nil,prefer_typed_value=ab,prefer_plain_attribute_write=a.prefer_plain_attribute_write==true,to_device=type(a.to_device)=="function"and a.to_device or
(B and type(B.to)=="function"and B.to or nil),emit=type(a.emit)=="function"and a.emit or nil,handler=type(a.handler)=="function"and a.handler or nil,sender=type(a.sender)=="function"and a.sender or nil,command_id=type(a.command_id)=="number"and a.command_id or nil,command_extractor=type(a.command_extractor)=="function"and a.command_extractor or nil,tx_command_id=type(a.tx_command_id)=="number"and a.tx_command_id or nil,tx_command_direction=a.tx_command_direction=="client"and"client"or"server",endpoint=(type(a.endpoint)=="number"or type(a.endpoint)=="function")and a.endpoint or nil,component=(type(a.component)=="string"or type(a.component)=="function")and a.component or nil,read_only=a.read_only==true,write_only=a.write_only==true,minimum_interval=a.minimum_interval,maximum_interval=a.maximum_interval,reportable_change=a.reportable_change,reporting_defaults=a.reporting_defaults,physical_reportable_change=type(a.physical_reportable_change)=="number"and
a.physical_reportable_change or nil,read_on_configure=a.read_on_configure==true,read_on_refresh=a.read_on_refresh,poll_interval=type(a.poll_interval)=="number"and a.poll_interval or nil,ias_configure_method=a.ias_configure_method,mfg_code=type(a.mfg_code)=="number"and a.mfg_code or nil,profile_id=type(a.profile_id)=="number"and a.profile_id or nil,metering_kind=type(a.metering_kind)=="string"and a.metering_kind or nil,scale=type(a.scale)=="number"and a.scale or nil,ignore_reported_scaler=a.ignore_reported_scaler==true,use_reported_unity_scaler=a.use_reported_unity_scaler==true,attribute_def=o,data_type=C or
(o and o.base_type or nil),write_type=L or
(o and o.base_type or nil),name=a.name,cluster_id=a.cluster_id,attribute_id=a.attribute_id}if ak~=false then ag[a]=ah end
return ah
end
local function w(d,a,b)
local ah=y(a)local g=ah.endpoint
if type(g)=="function"then
g=g(d,a,b)end
return l(g)
end
local function q(d,a,b)
local ah=y(a)local e=ah.component
if type(e)=="function"then
e=e(d,a,b)end
if type(e)=="string"and e~=""then
return e
end
return nil
end
local function X(d,a,b,ao)
local f={mapping=a,value=ao}if type(b)=="table"then
for al,ap in pairs(b)do
f[al]=ap
end
end
if f.cluster_id==nil and type(a)=="table"then
f.cluster_id=a.cluster_id
end
if f.attribute_id==nil and type(a)=="table"then
f.attribute_id=a.attribute_id
end
local g=w(d,a,f)if g==nil then
g=m(d,f)end
local e,af=q(d,a,f),d.profile and d.profile.components
if e==nil or(af and af[e]==nil)then
if g~=nil and type(d.get_component_id_for_endpoint)=="function"then
e=d:get_component_id_for_endpoint(g)else
e=p(d,f)end
end
f.endpoint=g
f.component_id=e
f.component=e and d.profile and d.profile.components and d.profile.components[e]or nil
return f
end
local function x(a,d,b)
if type(a)~="table"or d==nil then
return 0
end
local n,u,H,t,i,ae=w(d,a,b),q(d,a,b),y(a).mfg_code,m(d,b),p(d,b),type(b)=="table"and b.mfg_code or nil

if t==nil and i~=nil then
t=m(d,{component_id=i})end
if i==nil and t~=nil and type(d.get_component_id_for_endpoint)=="function"then
i=d:get_component_id_for_endpoint(t)end
local ac=type(b)=="table"and
l(b.endpoint or b.src_endpoint)or nil
if n~=nil and t~=n then
if ac~=nil then return-1 end
local K=u
if K==nil and type(d.get_component_id_for_endpoint)=="function"then
K=d:get_component_id_for_endpoint(n)end
if i==nil or K~=i then return-1 end
end
local O=n~=nil and type(b)=="table"and b.zb_rx~=nil
if u~=nil and i~=u and not O then
return-1
end
local U=type(b)=="table"and(b.mfg_code~=nil or
b.zb_rx~=nil or
b.command_id~=nil)if U and H~=nil and ae~=H then
return-1
end
local z=0
if n~=nil then
z=z+4
if n==t then z=z+1 end
end
if u~=nil then
z=z+2
end
if U and H~=nil then
z=z+8
end
return z
end
local function I(k)
return type(k)=="table"and k[P]==true
end
local function V(s,al,a)
local Y=s[al]if Y==nil then
s[al]=a
return
end
if I(Y)then
Y[#Y+1]=a
return
end
s[al]={[P]=true,Y,a}
end
local function D(k,d,b)
if k==nil then
return nil
end
if not I(k)then
if d==nil or x(k,d,b)>=0 then
return k
end
return nil
end
if d==nil then
return k[1]end
local J
local r=-1
for _,a in ipairs(k)do
local z=x(a,d,b)if z>r then
J=a
r=z
end
end
return J
end
local function F(k,d,b)
if k==nil then
return{}end
if not I(k)then
if d==nil or x(k,d,b)>=0 then
return{k}end
return{}end
local J={}local r
for _,a in ipairs(k)do
local z=d==nil and 0 or x(a,d,b)if z>=0 then
if r==nil or z>r then
J={a}r=z
elseif z==r then
J[#J+1]=a
end
end
end
return J
end
local function j(c)
if c==nil then
return nil
end
local aa=ad[c]if aa~=nil then
return aa
end
local v,aj,W,Z={},{},{},{}for _,a in ipairs(c)do
if type(a)=="table"then
local h,A=a.cluster_id,a.attribute_id

if h~=nil and A~=nil then
v[h]=v[h]or{}V(v[h],A,a)if not Z[h]then
Z[h]=true
W[#W+1]=h
end
end
if a.name~=nil then
V(aj,a.name,a)end
end
end
local s={by_cluster_attribute=v,by_name=aj,cluster_ids=W}ad[c]=s
return s
end
N.normalize_endpoint=l
function N.mapping_meta(a,ak)
if type(a)~="table"then
return nil
end
return y(a,ak)
end
N.resolve_context_component_id=p
N.resolve_context_endpoint=m
N.resolve_mapping_endpoint=w
N.resolve_mapping_component_id=q
N.build_mapping_context=X
N.select_mapping_entry=D
N.collect_matching_entries=F
N.build_mapping_index=j
function N.prepare_mappings(c)
if type(c)~="table"then
return c
end
if not S[c]then
S[c]=true
j(c)end
return c
end
function N.find_mapping(c,h,A,d,b)
local s=j(c)if s==nil then
return nil
end
local E=s.by_cluster_attribute[h]if E==nil then
return nil
end
return D(E[A],d,b)
end
function N.find_mappings(c,h,A,d,b)
local s=j(c)if s==nil then
return{}end
local E=s.by_cluster_attribute[h]if E==nil then
return{}end
return F(E[A],d,b)
end
function N.find_mapping_by_name(c,an,d,b)
if c==nil or an==nil then
return nil
end
local s=j(c)if s==nil then
return nil
end
return D(s.by_name[an],d,b)
end
function N.has_cluster(c,h)
if c==nil then
return false
end
local s=j(c)return s~=nil and s.by_cluster_attribute[h]~=nil
end
function N.get_cluster_ids(c)
if c==nil then
return{}end
local s=j(c)if s==nil then
return{}end
local am={}for _,h in ipairs(s.cluster_ids)do
am[#am+1]=h
end
return am
end
end
return ai
