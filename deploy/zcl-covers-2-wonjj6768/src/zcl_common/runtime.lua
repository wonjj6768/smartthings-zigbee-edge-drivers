local function ag(M)
local O,ae,ab,R,S="__zcl_mapping_bucket",setmetatable({},{__mode="k"}),setmetatable({},{__mode="k"}),setmetatable({},{__mode="k"}),require"runtime.capability_support".is_callable
local function r(g)
if type(g)~="number"or g%1~=0 then
return nil
end
return g
end
local function n(d,b)
if type(b)~="table"then
return nil
end
local e=b.component_id or b.component
if type(e)=="string"and e~=""then
return e
end
local g=r(b.endpoint or b.src_endpoint)if g~=nil and type(d.get_component_id_for_endpoint)=="function"then
local G=d:get_component_id_for_endpoint(g)if type(G)=="string"and G~=""then
return G
end
end
return nil
end
local function k(d,b)
if type(b)~="table"then
return nil
end
local g=r(b.endpoint or b.src_endpoint)if g~=nil then
return g
end
local e=b.component_id or b.component
if type(e)=="string"and e~=""and type(d.get_endpoint_for_component_id)=="function"then
local G=d:get_endpoint_for_component_id(e)if type(G)=="table"then
G=G[1]end
return r(G)end
return nil
end
local function w(a,ai)
local Z=ae[a]if Z~=nil then
return Z
end
local A,P=type(a.converter)=="table"and a.converter or nil,type(a.from_device)=="function"and a.from_device or nil

local L=A and type(A.from)=="function"and A.from or nil
local aa=a.prefer_typed_value==true or
(A and A.prefer_typed_value==true)or
false
local B=S(a.data_type)and a.data_type or nil
local K=S(a.write_type)and a.write_type or B
local l
if a.cluster_id~=nil and a.attribute_id~=nil and M.get_generated_attribute~=nil then
l=M.get_generated_attribute(a.cluster_id,a.attribute_id)end
if l==nil and a.cluster_id~=nil and a.attribute_id~=nil and M.build_dynamic_attribute~=nil then
local Q=B or K
if Q~=nil then
l=M.build_dynamic_attribute(a.cluster_id,a.attribute_id,Q,a.read_only~=true,a.attribute_name,a.complex_type==true)end
end
local af={from_device=P or L,custom_from_device=P~=nil,converter_from_device=L~=nil,prefer_typed_value=aa,prefer_plain_attribute_write=a.prefer_plain_attribute_write==true,to_device=type(a.to_device)=="function"and a.to_device or
(A and type(A.to)=="function"and A.to or nil),emit=type(a.emit)=="function"and a.emit or nil,handler=type(a.handler)=="function"and a.handler or nil,sender=type(a.sender)=="function"and a.sender or nil,command_id=type(a.command_id)=="number"and a.command_id or nil,command_extractor=type(a.command_extractor)=="function"and a.command_extractor or nil,tx_command_id=type(a.tx_command_id)=="number"and a.tx_command_id or nil,tx_command_direction=a.tx_command_direction=="client"and"client"or"server",endpoint=(type(a.endpoint)=="number"or type(a.endpoint)=="function")and a.endpoint or nil,component=(type(a.component)=="string"or type(a.component)=="function")and a.component or nil,read_only=a.read_only==true,write_only=a.write_only==true,minimum_interval=a.minimum_interval,maximum_interval=a.maximum_interval,reportable_change=a.reportable_change,reporting_defaults=a.reporting_defaults,physical_reportable_change=type(a.physical_reportable_change)=="number"and
a.physical_reportable_change or nil,read_on_configure=a.read_on_configure==true,read_on_refresh=a.read_on_refresh,poll_interval=type(a.poll_interval)=="number"and a.poll_interval or nil,ias_configure_method=a.ias_configure_method,mfg_code=type(a.mfg_code)=="number"and a.mfg_code or nil,profile_id=type(a.profile_id)=="number"and a.profile_id or nil,metering_kind=type(a.metering_kind)=="string"and a.metering_kind or nil,scale=type(a.scale)=="number"and a.scale or nil,ignore_reported_scaler=a.ignore_reported_scaler==true,use_reported_unity_scaler=a.use_reported_unity_scaler==true,attribute_def=l,data_type=B or
(l and l.base_type or nil),write_type=K or
(l and l.base_type or nil),name=a.name,cluster_id=a.cluster_id,attribute_id=a.attribute_id}if ai~=false then ae[a]=af end
return af
end
local function t(d,a,b)
local af=w(a)local g=af.endpoint
if type(g)=="function"then
g=g(d,a,b)end
return r(g)
end
local function o(d,a,b)
local af=w(a)local e=af.component
if type(e)=="function"then
e=e(d,a,b)end
if type(e)=="string"and e~=""then
return e
end
return nil
end
local function W(d,a,b,am)
local f={mapping=a,value=am}if type(b)=="table"then
for aj,an in pairs(b)do
f[aj]=an
end
end
if f.cluster_id==nil and type(a)=="table"then
f.cluster_id=a.cluster_id
end
if f.attribute_id==nil and type(a)=="table"then
f.attribute_id=a.attribute_id
end
local g=t(d,a,f)if g==nil then
g=k(d,f)end
local e,ad=o(d,a,f),d.profile and d.profile.components
if e==nil or(ad and ad[e]==nil)then
if g~=nil and type(d.get_component_id_for_endpoint)=="function"then
e=d:get_component_id_for_endpoint(g)else
e=n(d,f)end
end
f.endpoint=g
f.component_id=e
f.component=e and d.profile and d.profile.components and d.profile.components[e]or nil
return f
end
local function u(a,d,b)
if type(a)~="table"or d==nil then
return 0
end
local x,z,H,v,m,ac=t(d,a,b),o(d,a,b),w(a).mfg_code,k(d,b),n(d,b),type(b)=="table"and b.mfg_code or nil

if v==nil and m~=nil then
v=k(d,{component_id=m})end
if m==nil and v~=nil and type(d.get_component_id_for_endpoint)=="function"then
m=d:get_component_id_for_endpoint(v)end
if x~=nil and v~=x then
return-1
end
local N=x~=nil and type(b)=="table"and b.zb_rx~=nil
if z~=nil and m~=z and not N then
return-1
end
local T=type(b)=="table"and(b.mfg_code~=nil or
b.zb_rx~=nil or
b.command_id~=nil)if T and H~=nil and ac~=H then
return-1
end
local C=0
if x~=nil then
C=C+2
end
if z~=nil then
C=C+1
end
if T and H~=nil then
C=C+4
end
return C
end
local function I(j)
return type(j)=="table"and j[O]==true
end
local function U(q,aj,a)
local X=q[aj]if X==nil then
q[aj]=a
return
end
if I(X)then
X[#X+1]=a
return
end
q[aj]={[O]=true,X,a}
end
local function D(j,d,b)
if j==nil then
return nil
end
if not I(j)then
if d==nil or u(j,d,b)>=0 then
return j
end
return nil
end
if d==nil then
return j[1]end
local J
local p=-1
for _,a in ipairs(j)do
local C=u(a,d,b)if C>p then
J=a
p=C
end
end
return J
end
local function F(j,d,b)
if j==nil then
return{}end
if not I(j)then
if d==nil or u(j,d,b)>=0 then
return{j}end
return{}end
local J={}local p
for _,a in ipairs(j)do
local C=d==nil and 0 or u(a,d,b)if C>=0 then
if p==nil or C>p then
J={a}p=C
elseif C==p then
J[#J+1]=a
end
end
end
return J
end
local function i(c)
if c==nil then
return nil
end
local Z=ab[c]if Z~=nil then
return Z
end
local s,ah,V,Y={},{},{},{}for _,a in ipairs(c)do
if type(a)=="table"then
local h,y=a.cluster_id,a.attribute_id

if h~=nil and y~=nil then
s[h]=s[h]or{}U(s[h],y,a)if not Y[h]then
Y[h]=true
V[#V+1]=h
end
end
if a.name~=nil then
U(ah,a.name,a)end
end
end
local q={by_cluster_attribute=s,by_name=ah,cluster_ids=V}ab[c]=q
return q
end
M.normalize_endpoint=r
function M.mapping_meta(a,ai)
if type(a)~="table"then
return nil
end
return w(a,ai)
end
M.resolve_context_component_id=n
M.resolve_context_endpoint=k
M.resolve_mapping_endpoint=t
M.resolve_mapping_component_id=o
M.build_mapping_context=W
M.select_mapping_entry=D
M.collect_matching_entries=F
M.build_mapping_index=i
function M.prepare_mappings(c)
if type(c)~="table"then
return c
end
if not R[c]then
R[c]=true
i(c)end
return c
end
function M.find_mapping(c,h,y,d,b)
local q=i(c)if q==nil then
return nil
end
local E=q.by_cluster_attribute[h]if E==nil then
return nil
end
return D(E[y],d,b)
end
function M.find_mappings(c,h,y,d,b)
local q=i(c)if q==nil then
return{}end
local E=q.by_cluster_attribute[h]if E==nil then
return{}end
return F(E[y],d,b)
end
function M.find_mapping_by_name(c,al,d,b)
if c==nil or al==nil then
return nil
end
local q=i(c)if q==nil then
return nil
end
return D(q.by_name[al],d,b)
end
function M.has_cluster(c,h)
if c==nil then
return false
end
local q=i(c)return q~=nil and q.by_cluster_attribute[h]~=nil
end
function M.get_cluster_ids(c)
if c==nil then
return{}end
local q=i(c)if q==nil then
return{}end
local ak={}for _,h in ipairs(q.cluster_ids)do
ak[#ak+1]=h
end
return ak
end
end
return ag
