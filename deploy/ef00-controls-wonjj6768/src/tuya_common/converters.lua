local function X(av,q)
local az,u,z,f,c,aq,O,ax,A,ae,w=q.utils,q.log,q.math_floor,q.type_check,q.tonumber_check,q.raw_bytes,q.string_byte,q.string_char,q.string_len,q.table_concat,{}










local function aw(h)
return h
end
local function k(ak,e,b)
if f(ak)=="function"then
return ak(e,b)end
return ak
end
local function i(ak,e,b)
local s=k(ak,e,b)if s==nil then
return nil
end
return c(s)
end
local function t(E)
local L={}for au,an in pairs(E)do
L[an]=au
end
return L
end
local function y(E,e,b)
local s=k(E,e,b)if s==nil then
return w
end
if f(s)~="table"then
u.warn(string.format("Tuya lookup expects table map, got %s",f(s)))return w
end
return s
end
local function ac(n,g,j)
if f(n)~="string"then
return nil
end
local T=g or 1
local af=j or(A(n)-T+1)if T<1 or af<1 or(T+af-1)>A(n)then
return nil
end
local h=0
for ag=T,T+af-1 do
h=(h*256)+O(n,ag)end
return h
end
local function M(n,F,e,b)
local R,m=A(n),f(F)=="table"and F or w
local j=i(m.bytes or m.length,e,b)if j==nil then
j=R
end
j=z(j)if j<1 or j>R then
u.warn"Tuya raw_uint_be requires valid byte count"return nil,nil
end
local g=i(m.start,e,b)if g==nil then
local ao=i(m.offset,e,b)if ao~=nil then
g=z(ao)+1
end
end
if g==nil then
local am=k(m.from_tail,e,b)if am==true then
g=R-j+1
else
g=1
end
end
g=z(g)if g<1 or(g+j-1)>R then
u.warn"Tuya raw_uint_be slice is out of range"return nil,nil
end
return g,j
end
local function ar(n)
local ai={}for ag=1,A(n)do
ai[#ai+1]=string.format("%02X",O(n,ag))end
return ae(ai)
end
local function aj(E)
local ah={}for au,_ in pairs(E or w)do
local N=c(au)if N~=nil then
ah[#ah+1]=z(N)end
end
table.sort(ah)return ah
end
local a=av.converter
function a.pipe(...)
local U={...}if #U==1 and f(U[1])=="table"then
U=U[1]end
return function(h,e,b)
local V=h
for _,ay in ipairs(U)do
V=ay(V,e,b)end
return V
end
end
function a.from_to(x,ab)
local as={}if f(x)=="function"then
as.from=x
end
if f(ab)=="function"then
as.to=ab
end
return as
end
function a.from_only(x)
return a.from_to(x,nil)
end
function a.constant(ad)
return function()
return ad
end
end
function a.lookup_from_to(E,r)
local v=f(E)=="table"and E or nil
local Z=v and t(v)or nil
return a.from_to(
function(h,e,b)
local C=v or y(E,e,b)local L=Z or t(C)local I=L[h]if I~=nil then
return I
end
local B=k(r,e,b)if B~=nil then
return B
end
u.warn(string.format("Tuya lookup_from_to missing value: %s",tostring(h)))return nil
end,
a.lookup_value(E,r))
end
function a.lookup_value(E,r)
local v=f(E)=="table"and E or nil
return function(h,e,b)
local C=v or y(E,e,b)local I=C[h]if I~=nil then
return I
end
local B=k(r,e,b)if B~=nil then
return B
end
u.warn(string.format("Tuya lookup missing key: %s",tostring(h)))return nil
end
end
function a.raw_uint_be(o,F)
local Y=f(F)=="table"and F or nil
return a.from_only(function(h,e,b)
local n=aq(h)if n==nil then
u.warn(string.format("Tuya raw_uint_be expects bytes, got %s",f(h)))return nil
end
local g,j=M(n,Y,e,b)if g==nil then
return nil
end
local ap=ac(n,g,j)if ap==nil then
u.warn"Tuya raw_uint_be failed to parse payload"return nil
end
local aa=i(o,e,b)if aa==nil then
aa=1
end
if aa==0 then
u.warn"Tuya raw_uint_be divisor cannot be zero"return nil
end
return ap/aa
end)
end
function a.power()
return a.from_only(function(h)
local d=c(h)if d==nil then
u.warn(string.format("Tuya power expects number, got %s",f(h)))return nil
end
if d>268435455 then
return(429496732-d)*-1
end
return d
end)
end
function a.scale(Q,P,K,J)
return function(h)
local d,D,H,G,S=c(h),c(Q),c(P),c(K),c(J)if d==nil then
u.warn(string.format("Tuya scale expects number, got %s",f(h)))return nil
end
if D==nil or H==nil or G==nil or S==nil then
u.warn"Tuya scale expects numeric ranges"return nil
end
if H==D then
u.warn"Tuya scale input range cannot be zero"return nil
end
return((d-D)*(S-G)/(H-D))+G
end
end
function a.scale_pair(Q,P,K,J)
return a.from_to(a.scale(Q,P,K,J),a.scale(K,J,Q,P))
end
function a.divide_by(o)
return function(h,e,b)
local d,aa=c(h),i(o,e,b)if d==nil or aa==nil then
u.warn"Tuya divide_by expects numeric input and divisor"return nil
end
if aa==0 then
u.warn"Tuya divide_by divisor cannot be zero"return nil
end
return d/aa
end
end
function a.divide_by_pair(o)
return a.from_to(a.divide_by(o),a.multiply_by(o))
end
function a.signed_number_pair(at)
return a.from_to(
function(h,e,W,b)
local l
if f(W)=="table"and c(W.signed_value)~=nil then
l=c(W.signed_value)else
l=c(h)if l~=nil and l>0x7FFFFFFF then
l=l-4294967296
end
end
if l==nil then
u.warn(string.format("Tuya signed_number_pair expects number, got %s",f(h)))return nil
end
local o=i(at,e,b)if o==nil then
o=1
end
if o==0 then
u.warn"Tuya signed_number_pair scale cannot be zero"return nil
end
return l/o
end,
function(h,e,b)
local d=c(h)if d==nil then
u.warn(string.format("Tuya signed_number_pair expects number, got %s",f(h)))return nil
end
local p=i(at,e,b)if p==nil then
p=1
end
if p==0 then
u.warn"Tuya signed_number_pair scale cannot be zero"return nil
end
return d*p
end
)
end
function a.multiply_by(p)
return function(h,e,b)
local d,al=c(h),i(p,e,b)if d==nil or al==nil then
u.warn"Tuya multiply_by expects numeric input and multiplier"return nil
end
return d*al
end
end
function a.threshold_parser()
return function(h)
return av.parse_threshold(h)
end
end
end
return X
