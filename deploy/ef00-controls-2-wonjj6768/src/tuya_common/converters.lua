local function aa(ax,s)
local aB,r,B,f,d,as,R,az,C,ag,y=s.utils,s.log,s.math_floor,s.type_check,s.tonumber_check,s.raw_bytes,s.string_byte,s.string_char,s.string_len,s.table_concat,{}










local function ay(b)
return b
end
local function k(am,g,c)
if f(am)=="function"then
return am(g,c)end
return am
end
local function i(am,g,c)
local u=k(am,g,c)if u==nil then
return nil
end
return d(u)
end
local function v(G)
local O={}for aw,ap in pairs(G)do
O[ap]=aw
end
return O
end
local function A(G,g,c)
local u=k(G,g,c)if u==nil then
return y
end
if f(u)~="table"then
r.warn(string.format("Tuya lookup expects table map, got %s",f(u)))return y
end
return u
end
local function ae(n,h,j)
if f(n)~="string"then
return nil
end
local W=h or 1
local ah=j or(C(n)-W+1)if W<1 or ah<1 or(W+ah-1)>C(n)then
return nil
end
local b=0
for ai=W,W+ah-1 do
b=(b*256)+R(n,ai)end
return b
end
local function P(n,I,g,c)
local U,m=C(n),f(I)=="table"and I or y
local j=i(m.bytes or m.length,g,c)if j==nil then
j=U
end
j=B(j)if j<1 or j>U then
r.warn"Tuya raw_uint_be requires valid byte count"return nil,nil
end
local h=i(m.start,g,c)if h==nil then
local aq=i(m.offset,g,c)if aq~=nil then
h=B(aq)+1
end
end
if h==nil then
local ao=k(m.from_tail,g,c)if ao==true then
h=U-j+1
else
h=1
end
end
h=B(h)if h<1 or(h+j-1)>U then
r.warn"Tuya raw_uint_be slice is out of range"return nil,nil
end
return h,j
end
local function at(n)
local ak={}for ai=1,C(n)do
ak[#ak+1]=string.format("%02X",R(n,ai))end
return ag(ak)
end
local function al(G)
local aj={}for aw,_ in pairs(G or y)do
local Q=d(aw)if Q~=nil then
aj[#aj+1]=B(Q)end
end
table.sort(aj)return aj
end
local a=ax.converter
function a.pipe(...)
local X={...}if #X==1 and f(X[1])=="table"then
X=X[1]end
return function(b,g,c)
local Y=b
for _,aA in ipairs(X)do
Y=aA(Y,g,c)end
return Y
end
end
function a.from_to(z,H)
local au={}if f(z)=="function"then
au.from=z
end
if f(H)=="function"then
au.to=H
end
return au
end
function a.from_only(z)
return a.from_to(z,nil)
end
function a.to_only(H)
return a.from_to(nil,H)
end
function a.to_bool(x,q)
return function(b)
if f(b)=="boolean"then
return b
end
if b==x then
return true
end
if b==q then
return false
end
r.warn(string.format("Tuya to_bool expected %s or %s, got %s",tostring(x),tostring(q),tostring(b)))return nil
end
end
function a.bool_pair(x,q)
return a.from_to(a.to_bool(x,q),
function(b)
if b==true then
return x
end
if b==false then
return q
end
r.warn(string.format("Tuya bool_pair expected boolean, got %s",f(b)))return nil
end
)
end
function a.constant(af)
return function()
return af
end
end
function a.lookup_from_to(G,t)
local w=f(G)=="table"and G or nil
local ac=w and v(w)or nil
return a.from_to(
function(b,g,c)
local E=w or A(G,g,c)local O=ac or v(E)local L=O[b]if L~=nil then
return L
end
local D=k(t,g,c)if D~=nil then
return D
end
r.warn(string.format("Tuya lookup_from_to missing value: %s",tostring(b)))return nil
end,
a.lookup_value(G,t))
end
function a.lookup_value(G,t)
local w=f(G)=="table"and G or nil
return function(b,g,c)
local E=w or A(G,g,c)local L=E[b]if L~=nil then
return L
end
local D=k(t,g,c)if D~=nil then
return D
end
r.warn(string.format("Tuya lookup missing key: %s",tostring(b)))return nil
end
end
function a.raw_uint_be(o,I)
local ab=f(I)=="table"and I or nil
return a.from_only(function(b,g,c)
local n=as(b)if n==nil then
r.warn(string.format("Tuya raw_uint_be expects bytes, got %s",f(b)))return nil
end
local h,j=P(n,ab,g,c)if h==nil then
return nil
end
local ar=ae(n,h,j)if ar==nil then
r.warn"Tuya raw_uint_be failed to parse payload"return nil
end
local ad=i(o,g,c)if ad==nil then
ad=1
end
if ad==0 then
r.warn"Tuya raw_uint_be divisor cannot be zero"return nil
end
return ar/ad
end)
end
function a.true_false1()
return a.bool_pair(1,0)
end
function a.power()
return a.from_only(function(b)
local e=d(b)if e==nil then
r.warn(string.format("Tuya power expects number, got %s",f(b)))return nil
end
if e>268435455 then
return(429496732-e)*-1
end
return e
end)
end
function a.scale(T,S,N,M)
return function(b)
local e,F,K,J,V=d(b),d(T),d(S),d(N),d(M)if e==nil then
r.warn(string.format("Tuya scale expects number, got %s",f(b)))return nil
end
if F==nil or K==nil or J==nil or V==nil then
r.warn"Tuya scale expects numeric ranges"return nil
end
if K==F then
r.warn"Tuya scale input range cannot be zero"return nil
end
return((e-F)*(V-J)/(K-F))+J
end
end
function a.scale_pair(T,S,N,M)
return a.from_to(a.scale(T,S,N,M),a.scale(N,M,T,S))
end
function a.divide_by(o)
return function(b,g,c)
local e,ad=d(b),i(o,g,c)if e==nil or ad==nil then
r.warn"Tuya divide_by expects numeric input and divisor"return nil
end
if ad==0 then
r.warn"Tuya divide_by divisor cannot be zero"return nil
end
return e/ad
end
end
function a.divide_by_pair(o)
return a.from_to(a.divide_by(o),a.multiply_by(o))
end
function a.signed_number_pair(av)
return a.from_to(
function(b,g,Z,c)
local l
if f(Z)=="table"and d(Z.signed_value)~=nil then
l=d(Z.signed_value)else
l=d(b)if l~=nil and l>0x7FFFFFFF then
l=l-4294967296
end
end
if l==nil then
r.warn(string.format("Tuya signed_number_pair expects number, got %s",f(b)))return nil
end
local o=i(av,g,c)if o==nil then
o=1
end
if o==0 then
r.warn"Tuya signed_number_pair scale cannot be zero"return nil
end
return l/o
end,
function(b,g,c)
local e=d(b)if e==nil then
r.warn(string.format("Tuya signed_number_pair expects number, got %s",f(b)))return nil
end
local p=i(av,g,c)if p==nil then
p=1
end
if p==0 then
r.warn"Tuya signed_number_pair scale cannot be zero"return nil
end
return e*p
end
)
end
function a.multiply_by(p)
return function(b,g,c)
local e,an=d(b),i(p,g,c)if e==nil or an==nil then
r.warn"Tuya multiply_by expects numeric input and multiplier"return nil
end
return e*an
end
end
function a.threshold_parser()
return function(b)
return ax.parse_threshold(b)
end
end
end
return aa
