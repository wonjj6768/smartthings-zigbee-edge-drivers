local function z(p,L)
local e,P,w,E,y,K=L.type_check,L.copy_keys,L.merge_options,p.converter,{"name","key","preference","field","fields","emit","handler","endpoint","component","persist","read_only","write_only","command_id","transaction","signed","batch_key","match_transaction","response_dp","response_dps","match_response","skip","value","optimistic_value","suppress_optimistic_state","converter","from_device","to_device"},{"command_id","transaction","batch_key","match_transaction","response_dp","response_dps","match_response"}




local function x(O)
return e(O)=="table"and(e(O.from)=="function"or e(O.to)=="function")
end
local function A(c,a,f)
local r
local k
local b={}if e(c)=="string"then
r=c
else
w(b,c)end
if e(a)=="function"then
b.from_device=a
elseif x(a)then
k=a
else
w(b,a)end
w(b,f)if x(b.converter)then
k=b.converter
end
return r,k,b
end
local function h(s,J,c,a,f)
local r,k,b=
A(c,a,f)local d={dp=s,datatype=b.datatype or J}P(d,b,y)if e(b.send_policy)=="table"then
for _,U in ipairs(K)do
if d[U]==nil and b.send_policy[U]~=nil then
d[U]=b.send_policy[U]end
end
end
if d.name==nil and r~=nil then
d.name=r
end
local u=d.name or d.key
if d.field==nil and d.fields==nil and u~=nil then
d.field=u
end
if k~=nil and d.converter==nil and d.from_device==nil and d.to_device==nil then
d.converter=k
end
return d,b
end
local function q(l)
if e(l)~="table"then
return nil
end
local m=l.endpoint or l.src_endpoint
if m==nil and e(l.dp_info)=="table"then
m=l.dp_info.endpoint
end
if e(m)~="number"or m%1~=0 or m<1 then
return nil
end
return m
end
local function B(l)
if e(l)~="table"then
return nil
end
local s=l.dp
if s==nil and e(l.mapping)=="table"then
s=l.mapping.dp
end
if e(s)~="number"or s%1~=0 or s<0 then
return nil
end
return s
end
function p.dp_binary(s,c,a,f)
local d,b=h(s,p.DP_TYPE_BOOL,c,a,f)if d.converter==nil and d.from_device==nil and d.to_device==nil then
local C,false_value=b.true_value,b.false_value

if C~=nil or false_value~=nil then
d.converter=E.bool_pair(C==nil and true or C,false_value==nil and false or false_value)end
end
return d
end
function p.dp_raw(s,c,a,f)
local d=h(s,p.DP_TYPE_RAW,c,a,f)return d
end
function p.dp_numeric(s,c,a,f)
local d=h(s,p.DP_TYPE_VALUE,c,a,f)return d
end
function p.dp_string(s,c,a,f)
local d=h(s,p.DP_TYPE_STRING,c,a,f)return d
end
function p.dp_enum(s,c,a,f)
local d,b=h(s,p.DP_TYPE_ENUM,c,a,f)if d.converter==nil and d.from_device==nil and d.to_device==nil and b.lookup~=nil then
d.converter=E.lookup_from_to(b.lookup)end
return d
end
function p.dp_bitmap(s,c,a,f)
local d=h(s,p.DP_TYPE_BITMAP,c,a,f)return d
end
function p.dp_light(s,c,a,f)
local d,b=h(s,p.DP_TYPE_VALUE,c,a,f)if d.converter==nil and d.from_device==nil and d.to_device==nil then
local W,V,T,S=b.raw_min or 0,b.raw_max or 1000,b.value_min or 0,b.value_max or 100



d.converter=E.scale_pair(W,V,T,S)end
return d
end
function p.build_component_by_endpoint(F,g)
return function(Q,l)
local m=q(l)if m==nil or e(F)~="table"then
return g
end
local n=F[m]if e(n)=="string"and n~=""then
return n
end
return g
end
end
function p.build_component_by_dp(R,g)
return function(Q,l)
local s=B(l)if s==nil or e(R)~="table"then
return g
end
local n=R[s]if e(n)=="string"and n~=""then
return n
end
return g
end
end
function p.build_component_suffix(I,f)
f=f or{}local t=I
if e(t)~="string"or t==""then
t="switch"end
local o=f.main_endpoint
if e(o)~="number"or o%1~=0 or o<1 then
o=1
end
local i=f.main_component
if e(i)~="string"or i==""then
i="main"end
local j=f.index_offset
if e(j)~="number"or j%1~=0 then
j=0
end
local g=f.default_component
return function(Q,l)
local m=q(l)if m==nil then
return g
end
if m==o then
return i
end
local G=m-o+j
if G<1 then
return g
end
return t..tostring(G)
end
end
function p.build_component_suffix_by_dp(M,f)
f=f or{}local t=f.component_prefix
if e(t)~="string"or t==""then
t="switch"end
local i=f.main_component
if e(i)~="string"or i==""then
i="main"end
local g,j=f.default_component,f.index_offset

if e(j)~="number"or j%1~=0 then
j=0
end
local D,v=f.first_is_main~=false,{}
if e(M)=="table"then
for N,s in ipairs(M)do
if e(s)=="number"and s%1==0 and s>=0 then
if N==1 and D then
v[s]=i
else
local G=D and(N-1+j)or(N+j)if G>=1 then
v[s]=t..tostring(G)end
end
end
end
end
return p.build_component_by_dp(v,g)
end
end
return z
