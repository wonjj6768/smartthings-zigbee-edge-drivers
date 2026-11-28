local function A(p,L)
local e,P,w,z,y,K=L.type_check,L.copy_keys,L.merge_options,p.converter,{"name","key","preference","field","fields","emit","handler","endpoint","component","persist","read_only","write_only","command_id","transaction","signed","batch_key","match_transaction","response_dp","response_dps","match_response","skip","value","optimistic_value","suppress_optimistic_state","converter","from_device","to_device"},{"command_id","transaction","batch_key","match_transaction","response_dp","response_dps","match_response"}




local function x(O)
return e(O)=="table"and(e(O.from)=="function"or e(O.to)=="function")
end
local function B(d,b,f)
local r
local k
local a={}if e(d)=="string"then
r=d
else
w(a,d)end
if e(b)=="function"then
a.from_device=b
elseif x(b)then
k=b
else
w(a,b)end
w(a,f)if x(a.converter)then
k=a.converter
end
return r,k,a
end
local function h(s,J,d,b,f)
local r,k,a=
B(d,b,f)local c={dp=s,datatype=a.datatype or J}P(c,a,y)if e(a.send_policy)=="table"then
for _,U in ipairs(K)do
if c[U]==nil and a.send_policy[U]~=nil then
c[U]=a.send_policy[U]end
end
end
if c.name==nil and r~=nil then
c.name=r
end
local u=c.name or c.key
if c.field==nil and c.fields==nil and u~=nil then
c.field=u
end
if k~=nil and c.converter==nil and c.from_device==nil and c.to_device==nil then
c.converter=k
end
return c,a
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
local function C(l)
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
function p.dp_binary(s,d,b,f)
local c,a=h(s,p.DP_TYPE_BOOL,d,b,f)if c.converter==nil and c.from_device==nil and c.to_device==nil then
local D,false_value=a.true_value,a.false_value

if D~=nil or false_value~=nil then
c.converter=z.bool_pair(D==nil and true or D,false_value==nil and false or false_value)end
end
return c
end
function p.dp_raw(s,d,b,f)
local c=h(s,p.DP_TYPE_RAW,d,b,f)return c
end
function p.dp_numeric(s,d,b,f)
local c,a=h(s,p.DP_TYPE_VALUE,d,b,f)if c.converter==nil and c.from_device==nil and c.to_device==nil and a.scale~=nil then
c.converter=z.divide_by_pair(a.scale)end
return c
end
function p.dp_string(s,d,b,f)
local c=h(s,p.DP_TYPE_STRING,d,b,f)return c
end
function p.dp_enum(s,d,b,f)
local c,a=h(s,p.DP_TYPE_ENUM,d,b,f)if c.converter==nil and c.from_device==nil and c.to_device==nil and a.lookup~=nil then
c.converter=z.lookup_from_to(a.lookup)end
return c
end
function p.dp_bitmap(s,d,b,f)
local c=h(s,p.DP_TYPE_BITMAP,d,b,f)return c
end
function p.dp_light(s,d,b,f)
local c,a=h(s,p.DP_TYPE_VALUE,d,b,f)if c.converter==nil and c.from_device==nil and c.to_device==nil then
local W,V,T,S=a.raw_min or 0,a.raw_max or 1000,a.value_min or 0,a.value_max or 100



c.converter=z.scale_pair(W,V,T,S)end
return c
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
local s=C(l)if s==nil or e(R)~="table"then
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
local E,v=f.first_is_main~=false,{}
if e(M)=="table"then
for N,s in ipairs(M)do
if e(s)=="number"and s%1==0 and s>=0 then
if N==1 and E then
v[s]=i
else
local G=E and(N-1+j)or(N+j)if G>=1 then
v[s]=t..tostring(G)end
end
end
end
end
return p.build_component_by_dp(v,g)
end
end
return A
