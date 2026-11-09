local function Y(ay,r)
local aB,q,w,f,b,ac,s,ag,y,af,z=r.utils,r.log,r.math_floor,r.type_check,r.tonumber_check,r.raw_bytes,r.string_byte,r.string_char,r.string_len,r.table_concat,{}










local function az(d)
return d
end
local function k(an,g,c)
if f(an)=="function"then
return an(g,c)end
return an
end
local function i(an,g,c)
local u=k(an,g,c)if u==nil then
return nil
end
return b(u)
end
local function v(F)
local N={}for ax,aq in pairs(F)do
N[aq]=ax
end
return N
end
local function B(F,g,c)
local u=k(F,g,c)if u==nil then
return z
end
if f(u)~="table"then
q.warn(string.format("Tuya lookup expects table map, got %s",f(u)))return z
end
return u
end
local function ae(n,h,j)
if f(n)~="string"then
return nil
end
local U=h or 1
local ah=j or(y(n)-U+1)if U<1 or ah<1 or(U+ah-1)>y(n)then
return nil
end
local d=0
for ai=U,U+ah-1 do
d=(d*256)+s(n,ai)end
return d
end
local function O(n,G,g,c)
local S,m=y(n),f(G)=="table"and G or z
local j=i(m.bytes or m.length,g,c)if j==nil then
j=S
end
j=w(j)if j<1 or j>S then
q.warn"Tuya raw_uint_be requires valid byte count"return nil,nil
end
local h=i(m.start,g,c)if h==nil then
local ar=i(m.offset,g,c)if ar~=nil then
h=w(ar)+1
end
end
if h==nil then
local ap=k(m.from_tail,g,c)if ap==true then
h=S-j+1
else
h=1
end
end
h=w(h)if h<1 or(h+j-1)>S then
q.warn"Tuya raw_uint_be slice is out of range"return nil,nil
end
return h,j
end
local function au(n)
local ak={}for ai=1,y(n)do
ak[#ak+1]=string.format("%02X",s(n,ai))end
return af(ak)
end
local function am(F)
local aj={}for ax,_ in pairs(F or z)do
local P=b(ax)if P~=nil then
aj[#aj+1]=w(P)end
end
table.sort(aj)return aj
end
local a=ay.converter
function a.pipe(...)
local V={...}if #V==1 and f(V[1])=="table"then
V=V[1]end
return function(d,g,c)
local W=d
for _,aA in ipairs(V)do
W=aA(W,g,c)end
return W
end
end
function a.from_to(A,ad)
local av={}if f(A)=="function"then
av.from=A
end
if f(ad)=="function"then
av.to=ad
end
return av
end
function a.from_only(A)
return a.from_to(A,nil)
end
function a.lookup_from_to(F,t)
local x=f(F)=="table"and F or nil
local aa=x and v(x)or nil
return a.from_to(
function(d,g,c)
local D=x or B(F,g,c)local N=aa or v(D)local K=N[d]if K~=nil then
return K
end
local C=k(t,g,c)if C~=nil then
return C
end
q.warn(string.format("Tuya lookup_from_to missing value: %s",tostring(d)))return nil
end,
a.lookup_value(F,t))
end
function a.lookup_value(F,t)
local x=f(F)=="table"and F or nil
return function(d,g,c)
local D=x or B(F,g,c)local K=D[d]if K~=nil then
return K
end
local C=k(t,g,c)if C~=nil then
return C
end
q.warn(string.format("Tuya lookup missing key: %s",tostring(d)))return nil
end
end
function a.raw_uint_be(o,G)
local Z=f(G)=="table"and G or nil
return a.from_only(function(d,g,c)
local n=ac(d)if n==nil then
q.warn(string.format("Tuya raw_uint_be expects bytes, got %s",f(d)))return nil
end
local h,j=O(n,Z,g,c)if h==nil then
return nil
end
local as=ae(n,h,j)if as==nil then
q.warn"Tuya raw_uint_be failed to parse payload"return nil
end
local ab=i(o,g,c)if ab==nil then
ab=1
end
if ab==0 then
q.warn"Tuya raw_uint_be divisor cannot be zero"return nil
end
return as/ab
end)
end
function a.power_on_behavior()
return a.lookup_from_to{off=0,on=1,previous=2}
end
function a.indicator_mode_none_relay_pos()
return a.lookup_from_to{none=0,relay=1,pos=2}
end
function a.power()
return a.from_only(function(d)
local e=b(d)if e==nil then
q.warn(string.format("Tuya power expects number, got %s",f(d)))return nil
end
if e>268435455 then
return(429496732-e)*-1
end
return e
end)
end
function a.scale(R,Q,M,L)
return function(d)
local e,E,J,I,T=b(d),b(R),b(Q),b(M),b(L)if e==nil then
q.warn(string.format("Tuya scale expects number, got %s",f(d)))return nil
end
if E==nil or J==nil or I==nil or T==nil then
q.warn"Tuya scale expects numeric ranges"return nil
end
if J==E then
q.warn"Tuya scale input range cannot be zero"return nil
end
return((e-E)*(T-I)/(J-E))+I
end
end
function a.scale_pair(R,Q,M,L)
return a.from_to(a.scale(R,Q,M,L),a.scale(M,L,R,Q))
end
function a.divide_by(o)
return function(d,g,c)
local e,ab=b(d),i(o,g,c)if e==nil or ab==nil then
q.warn"Tuya divide_by expects numeric input and divisor"return nil
end
if ab==0 then
q.warn"Tuya divide_by divisor cannot be zero"return nil
end
return e/ab
end
end
function a.divide_by_pair(o)
return a.from_to(a.divide_by(o),a.multiply_by(o))
end
function a.signed_number_pair(aw)
return a.from_to(
function(d,g,X,c)
local l
if f(X)=="table"and b(X.signed_value)~=nil then
l=b(X.signed_value)else
l=b(d)if l~=nil and l>0x7FFFFFFF then
l=l-4294967296
end
end
if l==nil then
q.warn(string.format("Tuya signed_number_pair expects number, got %s",f(d)))return nil
end
local o=i(aw,g,c)if o==nil then
o=1
end
if o==0 then
q.warn"Tuya signed_number_pair scale cannot be zero"return nil
end
return l/o
end,
function(d,g,c)
local e=b(d)if e==nil then
q.warn(string.format("Tuya signed_number_pair expects number, got %s",f(d)))return nil
end
local p=i(aw,g,c)if p==nil then
p=1
end
if p==0 then
q.warn"Tuya signed_number_pair scale cannot be zero"return nil
end
return e*p
end
)
end
function a.multiply_by(p)
return function(d,g,c)
local e,ao=b(d),i(p,g,c)if e==nil or ao==nil then
q.warn"Tuya multiply_by expects numeric input and multiplier"return nil
end
return e*ao
end
end
function a.threshold_parser()
return function(d)
return ay.parse_threshold(d)
end
end
function a.inching_switch()
return a.from_to(
function(d)
local at=ac(d)if at==nil or y(at)<3 then
q.warn"Tuya inching_switch expects at least 3 bytes"return nil
end
local al,H=s(at,1),s(at,2)*256+s(at,3)return{state=(al~=0),duration=H}
end,
function(d)
if f(d)~="table"then
q.warn"Tuya inching_switch expects table {state, duration}"return nil
end
local al,H=d.state and 1 or 0,b(d.duration)or 0

return ag(al,w(H/256)%256,H%256)
end
)
end
end
return Y
