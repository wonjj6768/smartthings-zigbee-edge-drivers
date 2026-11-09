local function ad(am,q)
local aD,u,C,g,d,ai,H,an,w,N,x=q.utils,q.log,q.math_floor,q.type_check,q.tonumber_check,q.raw_bytes,q.string_byte,q.string_char,q.string_len,q.table_concat,{}










local function aB(b)
return b
end
local function k(as,f,c)
if g(as)=="function"then
return as(f,c)end
return as
end
local function i(as,f,c)
local s=k(as,f,c)if s==nil then
return nil
end
return d(s)
end
local function t(G)
local Q={}for aA,av in pairs(G)do
Q[av]=aA
end
return Q
end
local function A(G,f,c)
local s=k(G,f,c)if s==nil then
return x
end
if g(s)~="table"then
u.warn(string.format("Tuya lookup expects table map, got %s",g(s)))return x
end
return s
end
local function K(l,h,j)
if g(l)~="string"then
return nil
end
local Z=h or 1
local ao=j or(w(l)-Z+1)if Z<1 or ao<1 or(Z+ao-1)>w(l)then
return nil
end
local b=0
for W=Z,Z+ao-1 do
b=(b*256)+H(l,W)end
return b
end
local function S(l,I,f,c)
local z,n=w(l),g(I)=="table"and I or x
local j=i(n.bytes or n.length,f,c)if j==nil then
j=z
end
j=C(j)if j<1 or j>z then
u.warn"Tuya raw_uint_be requires valid byte count"return nil,nil
end
local h=i(n.start,f,c)if h==nil then
local aw=i(n.offset,f,c)if aw~=nil then
h=C(aw)+1
end
end
if h==nil then
local au=k(n.from_tail,f,c)if au==true then
h=z-j+1
else
h=1
end
end
h=C(h)if h<1 or(h+j-1)>z then
u.warn"Tuya raw_uint_be slice is out of range"return nil,nil
end
return h,j
end
local function R(l)
local aq={}for W=1,w(l)do
aq[#aq+1]=string.format("%02X",H(l,W))end
return N(aq)
end
local function ar(G)
local ap={}for aA,_ in pairs(G or x)do
local T=d(aA)if T~=nil then
ap[#ap+1]=C(T)end
end
table.sort(ap)return ap
end
local a=am.converter
function a.pipe(...)
local aa={...}if #aa==1 and g(aa[1])=="table"then
aa=aa[1]end
return function(b,f,c)
local ab=b
for _,aC in ipairs(aa)do
ab=aC(ab,f,c)end
return ab
end
end
function a.from_to(y,aj)
local ay={}if g(y)=="function"then
ay.from=y
end
if g(aj)=="function"then
ay.to=aj
end
return ay
end
function a.from_only(y)
return a.from_to(y,nil)
end
function a.lookup_from_to(G,r)
local v=g(G)=="table"and G or nil
local af=v and t(v)or nil
return a.from_to(
function(b,f,c)
local E=v or A(G,f,c)local Q=af or t(E)local M=Q[b]if M~=nil then
return M
end
local D=k(r,f,c)if D~=nil then
return D
end
u.warn(string.format("Tuya lookup_from_to missing value: %s",tostring(b)))return nil
end,
a.lookup_value(G,r))
end
function a.lookup_value(G,r)
local v=g(G)=="table"and G or nil
return function(b,f,c)
local E=v or A(G,f,c)local M=E[b]if M~=nil then
return M
end
local D=k(r,f,c)if D~=nil then
return D
end
u.warn(string.format("Tuya lookup missing key: %s",tostring(b)))return nil
end
end
function a.raw_uint_be(o,I)
local ae=g(I)=="table"and I or nil
return a.from_only(function(b,f,c)
local l=ai(b)if l==nil then
u.warn(string.format("Tuya raw_uint_be expects bytes, got %s",g(b)))return nil
end
local h,j=S(l,ae,f,c)if h==nil then
return nil
end
local ax=K(l,h,j)if ax==nil then
u.warn"Tuya raw_uint_be failed to parse payload"return nil
end
local ag=i(o,f,c)if ag==nil then
ag=1
end
if ag==0 then
u.warn"Tuya raw_uint_be divisor cannot be zero"return nil
end
return ax/ag
end)
end
function a.raw_identifier()
return a.from_only(function(b)
local l=ai(b)if l==nil then
return b
end
local z,ak,ah=w(l),{},true
for W=1,z do
local B=H(l,W)if B~=0 then
if B<32 or B>126 then
ah=false
end
ak[#ak+1]=an(B)end
end
if ah and #ak>0 then
return N(ak)end
if z<=4 then
return K(l,1,z)end
return R(l)
end)
end
function a.power_on_behavior()
return a.lookup_from_to{off=0,on=1,previous=2}
end
function a.power_outage_memory()
return a.lookup_from_to{off=0,on=1,restore=2}
end
function a.power()
return a.from_only(function(b)
local e=d(b)if e==nil then
u.warn(string.format("Tuya power expects number, got %s",g(b)))return nil
end
if e>268435455 then
return(429496732-e)*-1
end
return e
end)
end
function a.scale(V,U,P,O)
return function(b)
local e,F,L,J,X=d(b),d(V),d(U),d(P),d(O)if e==nil then
u.warn(string.format("Tuya scale expects number, got %s",g(b)))return nil
end
if F==nil or L==nil or J==nil or X==nil then
u.warn"Tuya scale expects numeric ranges"return nil
end
if L==F then
u.warn"Tuya scale input range cannot be zero"return nil
end
return((e-F)*(X-J)/(L-F))+J
end
end
function a.scale_pair(V,U,P,O)
return a.from_to(a.scale(V,U,P,O),a.scale(P,O,V,U))
end
function a.divide_by(o)
return function(b,f,c)
local e,ag=d(b),i(o,f,c)if e==nil or ag==nil then
u.warn"Tuya divide_by expects numeric input and divisor"return nil
end
if ag==0 then
u.warn"Tuya divide_by divisor cannot be zero"return nil
end
return e/ag
end
end
function a.divide_by_pair(o)
return a.from_to(a.divide_by(o),a.multiply_by(o))
end
function a.signed_number_pair(az)
return a.from_to(
function(b,f,ac,c)
local m
if g(ac)=="table"and d(ac.signed_value)~=nil then
m=d(ac.signed_value)else
m=d(b)if m~=nil and m>0x7FFFFFFF then
m=m-4294967296
end
end
if m==nil then
u.warn(string.format("Tuya signed_number_pair expects number, got %s",g(b)))return nil
end
local o=i(az,f,c)if o==nil then
o=1
end
if o==0 then
u.warn"Tuya signed_number_pair scale cannot be zero"return nil
end
return m/o
end,
function(b,f,c)
local e=d(b)if e==nil then
u.warn(string.format("Tuya signed_number_pair expects number, got %s",g(b)))return nil
end
local p=i(az,f,c)if p==nil then
p=1
end
if p==0 then
u.warn"Tuya signed_number_pair scale cannot be zero"return nil
end
return e*p
end
)
end
function a.multiply_by(p)
return function(b,f,c)
local e,at=d(b),i(p,f,c)if e==nil or at==nil then
u.warn"Tuya multiply_by expects numeric input and multiplier"return nil
end
return e*at
end
end
function a.phase_variant1_parser(Y)
return function(b)
return am.parse_phase_variant1(b,Y)
end
end
function a.phase_variant2_parser(Y,al)
return function(b)
return am.parse_phase_variant2(b,Y,al)
end
end
function a.phase_variant3_parser(Y)
return function(b)
return am.parse_phase_variant3(b,Y)
end
end
function a.threshold_parser()
return function(b)
return am.parse_threshold(b)
end
end
end
return ad
