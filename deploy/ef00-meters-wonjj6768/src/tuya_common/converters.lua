local function X(ak,q)
local aA,u,z,g,c,as,O,ay,A,ae,w=q.utils,q.log,q.math_floor,q.type_check,q.tonumber_check,q.raw_bytes,q.string_byte,q.string_char,q.string_len,q.table_concat,{}










local function ax(e)
return e
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
local function ac(n,h,j)
if g(n)~="string"then
return nil
end
local T=h or 1
local af=j or(A(n)-T+1)if T<1 or af<1 or(T+af-1)>A(n)then
return nil
end
local e=0
for ag=T,T+af-1 do
e=(e*256)+O(n,ag)end
return e
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
local ai={}for ag=1,A(n)do
ai[#ai+1]=string.format("%02X",O(n,ag))end
return ae(ai)
end
local function al(E)
local ah={}for aw,_ in pairs(E or w)do
local N=c(aw)if N~=nil then
ah[#ah+1]=z(N)end
end
table.sort(ah)return ah
end
local a=ak.converter
function a.pipe(...)
local U={...}if #U==1 and g(U[1])=="table"then
U=U[1]end
return function(e,f,b)
local V=e
for _,az in ipairs(U)do
V=az(V,f,b)end
return V
end
end
function a.from_to(x,ab)
local au={}if g(x)=="function"then
au.from=x
end
if g(ab)=="function"then
au.to=ab
end
return au
end
function a.from_only(x)
return a.from_to(x,nil)
end
function a.lookup_from_to(E,r)
local v=g(E)=="table"and E or nil
local Z=v and t(v)or nil
return a.from_to(
function(e,f,b)
local C=v or y(E,f,b)local L=Z or t(C)local I=L[e]if I~=nil then
return I
end
local B=k(r,f,b)if B~=nil then
return B
end
u.warn(string.format("Tuya lookup_from_to missing value: %s",tostring(e)))return nil
end,
a.lookup_value(E,r))
end
function a.lookup_value(E,r)
local v=g(E)=="table"and E or nil
return function(e,f,b)
local C=v or y(E,f,b)local I=C[e]if I~=nil then
return I
end
local B=k(r,f,b)if B~=nil then
return B
end
u.warn(string.format("Tuya lookup missing key: %s",tostring(e)))return nil
end
end
function a.raw_uint_be(o,F)
local Y=g(F)=="table"and F or nil
return a.from_only(function(e,f,b)
local n=as(e)if n==nil then
u.warn(string.format("Tuya raw_uint_be expects bytes, got %s",g(e)))return nil
end
local h,j=M(n,Y,f,b)if h==nil then
return nil
end
local ar=ac(n,h,j)if ar==nil then
u.warn"Tuya raw_uint_be failed to parse payload"return nil
end
local aa=i(o,f,b)if aa==nil then
aa=1
end
if aa==0 then
u.warn"Tuya raw_uint_be divisor cannot be zero"return nil
end
return ar/aa
end)
end
function a.power()
return a.from_only(function(e)
local d=c(e)if d==nil then
u.warn(string.format("Tuya power expects number, got %s",g(e)))return nil
end
if d>268435455 then
return(429496732-d)*-1
end
return d
end)
end
function a.scale(Q,P,K,J)
return function(e)
local d,D,H,G,S=c(e),c(Q),c(P),c(K),c(J)if d==nil then
u.warn(string.format("Tuya scale expects number, got %s",g(e)))return nil
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
return function(e,f,b)
local d,aa=c(e),i(o,f,b)if d==nil or aa==nil then
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
function a.signed_number_pair(av)
return a.from_to(
function(e,f,W,b)
local l
if g(W)=="table"and c(W.signed_value)~=nil then
l=c(W.signed_value)else
l=c(e)if l~=nil and l>0x7FFFFFFF then
l=l-4294967296
end
end
if l==nil then
u.warn(string.format("Tuya signed_number_pair expects number, got %s",g(e)))return nil
end
local o=i(av,f,b)if o==nil then
o=1
end
if o==0 then
u.warn"Tuya signed_number_pair scale cannot be zero"return nil
end
return l/o
end,
function(e,f,b)
local d=c(e)if d==nil then
u.warn(string.format("Tuya signed_number_pair expects number, got %s",g(e)))return nil
end
local p=i(av,f,b)if p==nil then
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
return function(e,f,b)
local d,an=c(e),i(p,f,b)if d==nil or an==nil then
u.warn"Tuya multiply_by expects numeric input and multiplier"return nil
end
return d*an
end
end
function a.phase_variant2_parser(aj,ad)
return function(e)
return ak.parse_phase_variant2(e,aj,ad)
end
end
function a.phase_variant3_parser(aj)
return function(e)
return ak.parse_phase_variant3(e,aj)
end
end
function a.threshold_parser()
return function(e)
return ak.parse_threshold(e)
end
end
end
return X
