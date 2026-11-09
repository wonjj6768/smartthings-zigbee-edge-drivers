local function Z(ax,s)
local aB,q,B,c,e,as,Q,az,C,ag,y=s.utils,s.log,s.math_floor,s.type_check,s.tonumber_check,s.raw_bytes,s.string_byte,s.string_char,s.string_len,s.table_concat,{}










local function ay(b)
return b
end
local function k(am,g,d)
if c(am)=="function"then
return am(g,d)end
return am
end
local function i(am,g,d)
local u=k(am,g,d)if u==nil then
return nil
end
return e(u)
end
local function v(G)
local N={}for aw,ap in pairs(G)do
N[ap]=aw
end
return N
end
local function A(G,g,d)
local u=k(G,g,d)if u==nil then
return y
end
if c(u)~="table"then
q.warn(string.format("Tuya lookup expects table map, got %s",c(u)))return y
end
return u
end
local function ae(o,h,j)
if c(o)~="string"then
return nil
end
local V=h or 1
local ah=j or(C(o)-V+1)if V<1 or ah<1 or(V+ah-1)>C(o)then
return nil
end
local b=0
for ai=V,V+ah-1 do
b=(b*256)+Q(o,ai)end
return b
end
local function O(o,H,g,d)
local T,n=C(o),c(H)=="table"and H or y
local j=i(n.bytes or n.length,g,d)if j==nil then
j=T
end
j=B(j)if j<1 or j>T then
q.warn"Tuya raw_uint_be requires valid byte count"return nil,nil
end
local h=i(n.start,g,d)if h==nil then
local aq=i(n.offset,g,d)if aq~=nil then
h=B(aq)+1
end
end
if h==nil then
local ao=k(n.from_tail,g,d)if ao==true then
h=T-j+1
else
h=1
end
end
h=B(h)if h<1 or(h+j-1)>T then
q.warn"Tuya raw_uint_be slice is out of range"return nil,nil
end
return h,j
end
local function at(o)
local ak={}for ai=1,C(o)do
ak[#ak+1]=string.format("%02X",Q(o,ai))end
return ag(ak)
end
local function al(G)
local aj={}for aw,_ in pairs(G or y)do
local P=e(aw)if P~=nil then
aj[#aj+1]=B(P)end
end
table.sort(aj)return aj
end
local a=ax.converter
function a.pipe(...)
local W={...}if #W==1 and c(W[1])=="table"then
W=W[1]end
return function(b,g,d)
local X=b
for _,aA in ipairs(W)do
X=aA(X,g,d)end
return X
end
end
function a.from_to(z,ad)
local au={}if c(z)=="function"then
au.from=z
end
if c(ad)=="function"then
au.to=ad
end
return au
end
function a.from_only(z)
return a.from_to(z,nil)
end
function a.to_bool(x,r)
return function(b)
if c(b)=="boolean"then
return b
end
if b==x then
return true
end
if b==r then
return false
end
q.warn(string.format("Tuya to_bool expected %s or %s, got %s",tostring(x),tostring(r),tostring(b)))return nil
end
end
function a.bool_pair(x,r)
return a.from_to(a.to_bool(x,r),
function(b)
if b==true then
return x
end
if b==false then
return r
end
q.warn(string.format("Tuya bool_pair expected boolean, got %s",c(b)))return nil
end
)
end
function a.constant(af)
return function()
return af
end
end
function a.invert_bool_pair()
return a.from_to(a.invert_bool(),a.invert_bool())
end
function a.lookup_from_to(G,t)
local w=c(G)=="table"and G or nil
local ab=w and v(w)or nil
return a.from_to(
function(b,g,d)
local E=w or A(G,g,d)local N=ab or v(E)local K=N[b]if K~=nil then
return K
end
local D=k(t,g,d)if D~=nil then
return D
end
q.warn(string.format("Tuya lookup_from_to missing value: %s",tostring(b)))return nil
end,
a.lookup_value(G,t))
end
function a.lookup_value(G,t)
local w=c(G)=="table"and G or nil
return function(b,g,d)
local E=w or A(G,g,d)local K=E[b]if K~=nil then
return K
end
local D=k(t,g,d)if D~=nil then
return D
end
q.warn(string.format("Tuya lookup missing key: %s",tostring(b)))return nil
end
end
function a.raw_uint_be(m,H)
local aa=c(H)=="table"and H or nil
return a.from_only(function(b,g,d)
local o=as(b)if o==nil then
q.warn(string.format("Tuya raw_uint_be expects bytes, got %s",c(b)))return nil
end
local h,j=O(o,aa,g,d)if h==nil then
return nil
end
local ar=ae(o,h,j)if ar==nil then
q.warn"Tuya raw_uint_be failed to parse payload"return nil
end
local ac=i(m,g,d)if ac==nil then
ac=1
end
if ac==0 then
q.warn"Tuya raw_uint_be divisor cannot be zero"return nil
end
return ar/ac
end)
end
function a.true_false0()
return a.bool_pair(0,1)
end
function a.divide_by_from_only(m)
return a.from_only(a.divide_by(m))
end
function a.power()
return a.from_only(function(b)
local f=e(b)if f==nil then
q.warn(string.format("Tuya power expects number, got %s",c(b)))return nil
end
if f>268435455 then
return(429496732-f)*-1
end
return f
end)
end
function a.scale(S,R,M,L)
return function(b)
local f,F,J,I,U=e(b),e(S),e(R),e(M),e(L)if f==nil then
q.warn(string.format("Tuya scale expects number, got %s",c(b)))return nil
end
if F==nil or J==nil or I==nil or U==nil then
q.warn"Tuya scale expects numeric ranges"return nil
end
if J==F then
q.warn"Tuya scale input range cannot be zero"return nil
end
return((f-F)*(U-I)/(J-F))+I
end
end
function a.scale_pair(S,R,M,L)
return a.from_to(a.scale(S,R,M,L),a.scale(M,L,S,R))
end
function a.divide_by(m)
return function(b,g,d)
local f,ac=e(b),i(m,g,d)if f==nil or ac==nil then
q.warn"Tuya divide_by expects numeric input and divisor"return nil
end
if ac==0 then
q.warn"Tuya divide_by divisor cannot be zero"return nil
end
return f/ac
end
end
function a.divide_by_pair(m)
return a.from_to(a.divide_by(m),a.multiply_by(m))
end
function a.signed_number_pair(av)
return a.from_to(
function(b,g,Y,d)
local l
if c(Y)=="table"and e(Y.signed_value)~=nil then
l=e(Y.signed_value)else
l=e(b)if l~=nil and l>0x7FFFFFFF then
l=l-4294967296
end
end
if l==nil then
q.warn(string.format("Tuya signed_number_pair expects number, got %s",c(b)))return nil
end
local m=i(av,g,d)if m==nil then
m=1
end
if m==0 then
q.warn"Tuya signed_number_pair scale cannot be zero"return nil
end
return l/m
end,
function(b,g,d)
local f=e(b)if f==nil then
q.warn(string.format("Tuya signed_number_pair expects number, got %s",c(b)))return nil
end
local p=i(av,g,d)if p==nil then
p=1
end
if p==0 then
q.warn"Tuya signed_number_pair scale cannot be zero"return nil
end
return f*p
end
)
end
function a.multiply_by(p)
return function(b,g,d)
local f,an=e(b),i(p,g,d)if f==nil or an==nil then
q.warn"Tuya multiply_by expects numeric input and multiplier"return nil
end
return f*an
end
end
function a.invert_bool()
return function(b)
if c(b)=="boolean"then
return not b
end
q.warn(string.format("Tuya invert_bool expects boolean, got %s",c(b)))return nil
end
end
function a.threshold_parser()
return function(b)
return ax.parse_threshold(b)
end
end
end
return Z
