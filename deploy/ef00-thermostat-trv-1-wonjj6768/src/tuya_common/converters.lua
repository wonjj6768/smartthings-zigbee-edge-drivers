local function Z(ay,s)
local aC,r,A,h,c,as,P,aA,B,af,x=s.utils,s.log,s.math_floor,s.type_check,s.tonumber_check,s.raw_bytes,s.string_byte,s.string_char,s.string_len,s.table_concat,{}










local function az(g)
return g
end
local function k(am,f,d)
if h(am)=="function"then
return am(f,d)end
return am
end
local function e(am,f,d)
local u=k(am,f,d)if u==nil then
return nil
end
return c(u)
end
local function v(F)
local M={}for ax,ap in pairs(F)do
M[ap]=ax
end
return M
end
local function z(F,f,d)
local u=k(F,f,d)if u==nil then
return x
end
if h(u)~="table"then
r.warn(string.format("Tuya lookup expects table map, got %s",h(u)))return x
end
return u
end
local function ae(n,i,j)
if h(n)~="string"then
return nil
end
local V=i or 1
local ah=j or(B(n)-V+1)if V<1 or ah<1 or(V+ah-1)>B(n)then
return nil
end
local g=0
for ai=V,V+ah-1 do
g=(g*256)+P(n,ai)end
return g
end
local function N(n,G,f,d)
local T,m=B(n),h(G)=="table"and G or x
local j=e(m.bytes or m.length,f,d)if j==nil then
j=T
end
j=A(j)if j<1 or j>T then
r.warn"Tuya raw_uint_be requires valid byte count"return nil,nil
end
local i=e(m.start,f,d)if i==nil then
local aq=e(m.offset,f,d)if aq~=nil then
i=A(aq)+1
end
end
if i==nil then
local ao=k(m.from_tail,f,d)if ao==true then
i=T-j+1
else
i=1
end
end
i=A(i)if i<1 or(i+j-1)>T then
r.warn"Tuya raw_uint_be slice is out of range"return nil,nil
end
return i,j
end
local function at(n)
local ak={}for ai=1,B(n)do
ak[#ak+1]=string.format("%02X",P(n,ai))end
return af(ak)
end
local function al(F)
local aj={}for ax,_ in pairs(F or x)do
local O=c(ax)if O~=nil then
aj[#aj+1]=A(O)end
end
table.sort(aj)return aj
end
local b=ay.converter
function b.pipe(...)
local W={...}if #W==1 and h(W[1])=="table"then
W=W[1]end
return function(g,f,d)
local X=g
for _,aB in ipairs(W)do
X=aB(X,f,d)end
return X
end
end
function b.from_to(y,ad)
local au={}if h(y)=="function"then
au.from=y
end
if h(ad)=="function"then
au.to=ad
end
return au
end
function b.from_only(y)
return b.from_to(y,nil)
end
function b.lookup_from_to(F,t)
local w=h(F)=="table"and F or nil
local ab=w and v(w)or nil
return b.from_to(
function(g,f,d)
local D=w or z(F,f,d)local M=ab or v(D)local J=M[g]if J~=nil then
return J
end
local C=k(t,f,d)if C~=nil then
return C
end
r.warn(string.format("Tuya lookup_from_to missing value: %s",tostring(g)))return nil
end,
b.lookup_value(F,t))
end
function b.lookup_value(F,t)
local w=h(F)=="table"and F or nil
return function(g,f,d)
local D=w or z(F,f,d)local J=D[g]if J~=nil then
return J
end
local C=k(t,f,d)if C~=nil then
return C
end
r.warn(string.format("Tuya lookup missing key: %s",tostring(g)))return nil
end
end
function b.raw_uint_be(o,G)
local aa=h(G)=="table"and G or nil
return b.from_only(function(g,f,d)
local n=as(g)if n==nil then
r.warn(string.format("Tuya raw_uint_be expects bytes, got %s",h(g)))return nil
end
local i,j=N(n,aa,f,d)if i==nil then
return nil
end
local ar=ae(n,i,j)if ar==nil then
r.warn"Tuya raw_uint_be failed to parse payload"return nil
end
local ac=e(o,f,d)if ac==nil then
ac=1
end
if ac==0 then
r.warn"Tuya raw_uint_be divisor cannot be zero"return nil
end
return ar/ac
end)
end
function b.valve_state_closed_open()
return b.lookup_from_to{close=0,open=1}
end
function b.temperature_sensor_select_in_al_ou()
return b.lookup_from_to{IN=0,AL=1,OU=2}
end
function b.temperature_sensor_select_internal_external_both()
return b.lookup_from_to{internal=0,external=1,both=2}
end
function b.power()
return b.from_only(function(g)
local a=c(g)if a==nil then
r.warn(string.format("Tuya power expects number, got %s",h(g)))return nil
end
if a>268435455 then
return(429496732-a)*-1
end
return a
end)
end
function b.scale(S,R,L,K)
return function(g)
local a,E,I,H,U=c(g),c(S),c(R),c(L),c(K)if a==nil then
r.warn(string.format("Tuya scale expects number, got %s",h(g)))return nil
end
if E==nil or I==nil or H==nil or U==nil then
r.warn"Tuya scale expects numeric ranges"return nil
end
if I==E then
r.warn"Tuya scale input range cannot be zero"return nil
end
return((a-E)*(U-H)/(I-E))+H
end
end
function b.scale_pair(S,R,L,K)
return b.from_to(b.scale(S,R,L,K),b.scale(L,K,S,R))
end
function b.divide_by(o)
return function(g,f,d)
local a,ac=c(g),e(o,f,d)if a==nil or ac==nil then
r.warn"Tuya divide_by expects numeric input and divisor"return nil
end
if ac==0 then
r.warn"Tuya divide_by divisor cannot be zero"return nil
end
return a/ac
end
end
function b.divide_by_pair(o)
return b.from_to(b.divide_by(o),b.multiply_by(o))
end
function b.signed_number_pair(av)
return b.from_to(
function(g,f,Y,d)
local l
if h(Y)=="table"and c(Y.signed_value)~=nil then
l=c(Y.signed_value)else
l=c(g)if l~=nil and l>0x7FFFFFFF then
l=l-4294967296
end
end
if l==nil then
r.warn(string.format("Tuya signed_number_pair expects number, got %s",h(g)))return nil
end
local o=e(av,f,d)if o==nil then
o=1
end
if o==0 then
r.warn"Tuya signed_number_pair scale cannot be zero"return nil
end
return l/o
end,
function(g,f,d)
local a=c(g)if a==nil then
r.warn(string.format("Tuya signed_number_pair expects number, got %s",h(g)))return nil
end
local q=e(av,f,d)if q==nil then
q=1
end
if q==0 then
r.warn"Tuya signed_number_pair scale cannot be zero"return nil
end
return a*q
end
)
end
function b.multiply_by(q)
return function(g,f,d)
local a,an=c(g),e(q,f,d)if a==nil or an==nil then
r.warn"Tuya multiply_by expects numeric input and multiplier"return nil
end
return a*an
end
end
function b.wrap_signed(ag,aw)
return b.from_to(
function(g,f,d)
local a,p,Q=c(g),e(ag,f,d),e(aw,f,d)if a==nil or p==nil or Q==nil then
r.warn"Tuya wrapped_signed expects numeric input, modulus, and cutoff"return nil
end
if a>Q then
return a-p
end
return a
end,
function(g,f,d)
local a,p=c(g),e(ag,f,d)if a==nil or p==nil then
r.warn"Tuya wrapped_signed expects numeric input and modulus"return nil
end
if a<0 then
return p+a
end
return a
end
)
end
function b.threshold_parser()
return function(g)
return ay.parse_threshold(g)
end
end
function b.error_or_battery_low()
return b.from_only(function(g)
local a=c(g)if a==nil or a%1~=0 or a<0 or a>0xFFFFFFFF then
return nil
end
return{error=a,battery_low=a==1 and"low"or"normal"}
end)
end
end
return Z
