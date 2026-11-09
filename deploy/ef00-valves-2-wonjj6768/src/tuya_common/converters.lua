local function Y(au,q)
local ay,u,z,f,c,ap,P,aw,A,ad,w=q.utils,q.log,q.math_floor,q.type_check,q.tonumber_check,q.raw_bytes,q.string_byte,q.string_char,q.string_len,q.table_concat,{}










local function av(h)
return h
end
local function k(aj,e,b)
if f(aj)=="function"then
return aj(e,b)end
return aj
end
local function i(aj,e,b)
local s=k(aj,e,b)if s==nil then
return nil
end
return c(s)
end
local function t(E)
local M={}for at,am in pairs(E)do
M[am]=at
end
return M
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
local U=g or 1
local ae=j or(A(n)-U+1)if U<1 or ae<1 or(U+ae-1)>A(n)then
return nil
end
local h=0
for af=U,U+ae-1 do
h=(h*256)+P(n,af)end
return h
end
local function N(n,G,e,b)
local S,m=A(n),f(G)=="table"and G or w
local j=i(m.bytes or m.length,e,b)if j==nil then
j=S
end
j=z(j)if j<1 or j>S then
u.warn"Tuya raw_uint_be requires valid byte count"return nil,nil
end
local g=i(m.start,e,b)if g==nil then
local an=i(m.offset,e,b)if an~=nil then
g=z(an)+1
end
end
if g==nil then
local al=k(m.from_tail,e,b)if al==true then
g=S-j+1
else
g=1
end
end
g=z(g)if g<1 or(g+j-1)>S then
u.warn"Tuya raw_uint_be slice is out of range"return nil,nil
end
return g,j
end
local function aq(n)
local ah={}for af=1,A(n)do
ah[#ah+1]=string.format("%02X",P(n,af))end
return ad(ah)
end
local function ai(E)
local ag={}for at,_ in pairs(E or w)do
local O=c(at)if O~=nil then
ag[#ag+1]=z(O)end
end
table.sort(ag)return ag
end
local a=au.converter
function a.pipe(...)
local V={...}if #V==1 and f(V[1])=="table"then
V=V[1]end
return function(h,e,b)
local W=h
for _,ax in ipairs(V)do
W=ax(W,e,b)end
return W
end
end
function a.from_to(x,F)
local ar={}if f(x)=="function"then
ar.from=x
end
if f(F)=="function"then
ar.to=F
end
return ar
end
function a.from_only(x)
return a.from_to(x,nil)
end
function a.to_only(F)
return a.from_to(nil,F)
end
function a.lookup_from_to(E,r)
local v=f(E)=="table"and E or nil
local aa=v and t(v)or nil
return a.from_to(
function(h,e,b)
local C=v or y(E,e,b)local M=aa or t(C)local J=M[h]if J~=nil then
return J
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
local C=v or y(E,e,b)local J=C[h]if J~=nil then
return J
end
local B=k(r,e,b)if B~=nil then
return B
end
u.warn(string.format("Tuya lookup missing key: %s",tostring(h)))return nil
end
end
function a.raw_uint_be(o,G)
local Z=f(G)=="table"and G or nil
return a.from_only(function(h,e,b)
local n=ap(h)if n==nil then
u.warn(string.format("Tuya raw_uint_be expects bytes, got %s",f(h)))return nil
end
local g,j=N(n,Z,e,b)if g==nil then
return nil
end
local ao=ac(n,g,j)if ao==nil then
u.warn"Tuya raw_uint_be failed to parse payload"return nil
end
local ab=i(o,e,b)if ab==nil then
ab=1
end
if ab==0 then
u.warn"Tuya raw_uint_be divisor cannot be zero"return nil
end
return ao/ab
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
function a.scale(R,Q,L,K)
return function(h)
local d,D,I,H,T=c(h),c(R),c(Q),c(L),c(K)if d==nil then
u.warn(string.format("Tuya scale expects number, got %s",f(h)))return nil
end
if D==nil or I==nil or H==nil or T==nil then
u.warn"Tuya scale expects numeric ranges"return nil
end
if I==D then
u.warn"Tuya scale input range cannot be zero"return nil
end
return((d-D)*(T-H)/(I-D))+H
end
end
function a.scale_pair(R,Q,L,K)
return a.from_to(a.scale(R,Q,L,K),a.scale(L,K,R,Q))
end
function a.divide_by(o)
return function(h,e,b)
local d,ab=c(h),i(o,e,b)if d==nil or ab==nil then
u.warn"Tuya divide_by expects numeric input and divisor"return nil
end
if ab==0 then
u.warn"Tuya divide_by divisor cannot be zero"return nil
end
return d/ab
end
end
function a.divide_by_pair(o)
return a.from_to(a.divide_by(o),a.multiply_by(o))
end
function a.signed_number_pair(as)
return a.from_to(
function(h,e,X,b)
local l
if f(X)=="table"and c(X.signed_value)~=nil then
l=c(X.signed_value)else
l=c(h)if l~=nil and l>0x7FFFFFFF then
l=l-4294967296
end
end
if l==nil then
u.warn(string.format("Tuya signed_number_pair expects number, got %s",f(h)))return nil
end
local o=i(as,e,b)if o==nil then
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
local p=i(as,e,b)if p==nil then
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
local d,ak=c(h),i(p,e,b)if d==nil or ak==nil then
u.warn"Tuya multiply_by expects numeric input and multiplier"return nil
end
return d*ak
end
end
function a.threshold_parser()
return function(h)
return au.parse_threshold(h)
end
end
end
return Y
