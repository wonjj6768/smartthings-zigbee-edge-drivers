local function Y(ag,q)
local aA,u,z,g,c,as,O,ay,A,af,w=q.utils,q.log,q.math_floor,q.type_check,q.tonumber_check,q.raw_bytes,q.string_byte,q.string_char,q.string_len,q.table_concat,{}










local function ax(d)
return d
end
local function k(am,f,b)
if g(am)=="function"then
return am(f,b)end
return am
end
local function i(am,f,b)
local s=k(am,f,b)if s==nil then
return nil
end
return c(s)
end
local function t(E)
local L={}for aw,ap in pairs(E)do
L[ap]=aw
end
return L
end
local function y(E,f,b)
local s=k(E,f,b)if s==nil then
return w
end
if g(s)~="table"then
u.warn(string.format("Tuya lookup expects table map, got %s",g(s)))return w
end
return s
end
local function ad(n,h,j)
if g(n)~="string"then
return nil
end
local U=h or 1
local ah=j or(A(n)-U+1)if U<1 or ah<1 or(U+ah-1)>A(n)then
return nil
end
local d=0
for ai=U,U+ah-1 do
d=(d*256)+O(n,ai)end
return d
end
local function M(n,F,f,b)
local R,m=A(n),g(F)=="table"and F or w
local j=i(m.bytes or m.length,f,b)if j==nil then
j=R
end
j=z(j)if j<1 or j>R then
u.warn"Tuya raw_uint_be requires valid byte count"return nil,nil
end
local h=i(m.start,f,b)if h==nil then
local aq=i(m.offset,f,b)if aq~=nil then
h=z(aq)+1
end
end
if h==nil then
local ao=k(m.from_tail,f,b)if ao==true then
h=R-j+1
else
h=1
end
end
h=z(h)if h<1 or(h+j-1)>R then
u.warn"Tuya raw_uint_be slice is out of range"return nil,nil
end
return h,j
end
local function at(n)
local ak={}for ai=1,A(n)do
ak[#ak+1]=string.format("%02X",O(n,ai))end
return af(ak)
end
local function al(E)
local aj={}for aw,_ in pairs(E or w)do
local N=c(aw)if N~=nil then
aj[#aj+1]=z(N)end
end
table.sort(aj)return aj
end
local a=ag.converter
function a.pipe(...)
local V={...}if #V==1 and g(V[1])=="table"then
V=V[1]end
return function(d,f,b)
local W=d
for _,az in ipairs(V)do
W=az(W,f,b)end
return W
end
end
function a.from_to(x,ac)
local au={}if g(x)=="function"then
au.from=x
end
if g(ac)=="function"then
au.to=ac
end
return au
end
function a.from_only(x)
return a.from_to(x,nil)
end
function a.lookup_from_to(E,r)
local v=g(E)=="table"and E or nil
local aa=v and t(v)or nil
return a.from_to(
function(d,f,b)
local C=v or y(E,f,b)local L=aa or t(C)local I=L[d]if I~=nil then
return I
end
local B=k(r,f,b)if B~=nil then
return B
end
u.warn(string.format("Tuya lookup_from_to missing value: %s",tostring(d)))return nil
end,
a.lookup_value(E,r))
end
function a.lookup_value(E,r)
local v=g(E)=="table"and E or nil
return function(d,f,b)
local C=v or y(E,f,b)local I=C[d]if I~=nil then
return I
end
local B=k(r,f,b)if B~=nil then
return B
end
u.warn(string.format("Tuya lookup missing key: %s",tostring(d)))return nil
end
end
function a.raw_uint_be(o,F)
local Z=g(F)=="table"and F or nil
return a.from_only(function(d,f,b)
local n=as(d)if n==nil then
u.warn(string.format("Tuya raw_uint_be expects bytes, got %s",g(d)))return nil
end
local h,j=M(n,Z,f,b)if h==nil then
return nil
end
local ar=ad(n,h,j)if ar==nil then
u.warn"Tuya raw_uint_be failed to parse payload"return nil
end
local ab=i(o,f,b)if ab==nil then
ab=1
end
if ab==0 then
u.warn"Tuya raw_uint_be divisor cannot be zero"return nil
end
return ar/ab
end)
end
function a.power_on_behavior()
return a.lookup_from_to{off=0,on=1,previous=2}
end
function a.power_outage_memory()
return a.lookup_from_to{off=0,on=1,restore=2}
end
function a.power()
return a.from_only(function(d)
local e=c(d)if e==nil then
u.warn(string.format("Tuya power expects number, got %s",g(d)))return nil
end
if e>268435455 then
return(429496732-e)*-1
end
return e
end)
end
function a.scale(Q,P,K,J)
return function(d)
local e,D,H,G,S=c(d),c(Q),c(P),c(K),c(J)if e==nil then
u.warn(string.format("Tuya scale expects number, got %s",g(d)))return nil
end
if D==nil or H==nil or G==nil or S==nil then
u.warn"Tuya scale expects numeric ranges"return nil
end
if H==D then
u.warn"Tuya scale input range cannot be zero"return nil
end
return((e-D)*(S-G)/(H-D))+G
end
end
function a.scale_pair(Q,P,K,J)
return a.from_to(a.scale(Q,P,K,J),a.scale(K,J,Q,P))
end
function a.divide_by(o)
return function(d,f,b)
local e,ab=c(d),i(o,f,b)if e==nil or ab==nil then
u.warn"Tuya divide_by expects numeric input and divisor"return nil
end
if ab==0 then
u.warn"Tuya divide_by divisor cannot be zero"return nil
end
return e/ab
end
end
function a.divide_by_pair(o)
return a.from_to(a.divide_by(o),a.multiply_by(o))
end
function a.signed_number_pair(av)
return a.from_to(
function(d,f,X,b)
local l
if g(X)=="table"and c(X.signed_value)~=nil then
l=c(X.signed_value)else
l=c(d)if l~=nil and l>0x7FFFFFFF then
l=l-4294967296
end
end
if l==nil then
u.warn(string.format("Tuya signed_number_pair expects number, got %s",g(d)))return nil
end
local o=i(av,f,b)if o==nil then
o=1
end
if o==0 then
u.warn"Tuya signed_number_pair scale cannot be zero"return nil
end
return l/o
end,
function(d,f,b)
local e=c(d)if e==nil then
u.warn(string.format("Tuya signed_number_pair expects number, got %s",g(d)))return nil
end
local p=i(av,f,b)if p==nil then
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
return function(d,f,b)
local e,an=c(d),i(p,f,b)if e==nil or an==nil then
u.warn"Tuya multiply_by expects numeric input and multiplier"return nil
end
return e*an
end
end
function a.phase_variant1_parser(T)
return function(d)
return ag.parse_phase_variant1(d,T)
end
end
function a.phase_variant2_parser(T,ae)
return function(d)
return ag.parse_phase_variant2(d,T,ae)
end
end
function a.phase_variant3_parser(T)
return function(d)
return ag.parse_phase_variant3(d,T)
end
end
function a.threshold_parser()
return function(d)
return ag.parse_threshold(d)
end
end
end
return Y
