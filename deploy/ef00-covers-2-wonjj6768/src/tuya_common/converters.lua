local function Z(ay,s)
local aC,p,A,h,c,as,P,aA,B,af,x=s.utils,s.log,s.math_floor,s.type_check,s.tonumber_check,s.raw_bytes,s.string_byte,s.string_char,s.string_len,s.table_concat,{}










local function az(f)
return f
end
local function k(am,g,d)
if h(am)=="function"then
return am(g,d)end
return am
end
local function e(am,g,d)
local u=k(am,g,d)if u==nil then
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
local function z(F,g,d)
local u=k(F,g,d)if u==nil then
return x
end
if h(u)~="table"then
p.warn(string.format("Tuya lookup expects table map, got %s",h(u)))return x
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
local f=0
for ai=V,V+ah-1 do
f=(f*256)+P(n,ai)end
return f
end
local function N(n,G,g,d)
local T,m=B(n),h(G)=="table"and G or x
local j=e(m.bytes or m.length,g,d)if j==nil then
j=T
end
j=A(j)if j<1 or j>T then
p.warn"Tuya raw_uint_be requires valid byte count"return nil,nil
end
local i=e(m.start,g,d)if i==nil then
local aq=e(m.offset,g,d)if aq~=nil then
i=A(aq)+1
end
end
if i==nil then
local ao=k(m.from_tail,g,d)if ao==true then
i=T-j+1
else
i=1
end
end
i=A(i)if i<1 or(i+j-1)>T then
p.warn"Tuya raw_uint_be slice is out of range"return nil,nil
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
return function(f,g,d)
local X=f
for _,aB in ipairs(W)do
X=aB(X,g,d)end
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
function(f,g,d)
local D=w or z(F,g,d)local M=ab or v(D)local J=M[f]if J~=nil then
return J
end
local C=k(t,g,d)if C~=nil then
return C
end
p.warn(string.format("Tuya lookup_from_to missing value: %s",tostring(f)))return nil
end,
b.lookup_value(F,t))
end
function b.lookup_value(F,t)
local w=h(F)=="table"and F or nil
return function(f,g,d)
local D=w or z(F,g,d)local J=D[f]if J~=nil then
return J
end
local C=k(t,g,d)if C~=nil then
return C
end
p.warn(string.format("Tuya lookup missing key: %s",tostring(f)))return nil
end
end
function b.raw_uint_be(o,G)
local aa=h(G)=="table"and G or nil
return b.from_only(function(f,g,d)
local n=as(f)if n==nil then
p.warn(string.format("Tuya raw_uint_be expects bytes, got %s",h(f)))return nil
end
local i,j=N(n,aa,g,d)if i==nil then
return nil
end
local ar=ae(n,i,j)if ar==nil then
p.warn"Tuya raw_uint_be failed to parse payload"return nil
end
local ac=e(o,g,d)if ac==nil then
ac=1
end
if ac==0 then
p.warn"Tuya raw_uint_be divisor cannot be zero"return nil
end
return ar/ac
end)
end
function b.power()
return b.from_only(function(f)
local a=c(f)if a==nil then
p.warn(string.format("Tuya power expects number, got %s",h(f)))return nil
end
if a>268435455 then
return(429496732-a)*-1
end
return a
end)
end
function b.scale(S,R,L,K)
return function(f)
local a,E,I,H,U=c(f),c(S),c(R),c(L),c(K)if a==nil then
p.warn(string.format("Tuya scale expects number, got %s",h(f)))return nil
end
if E==nil or I==nil or H==nil or U==nil then
p.warn"Tuya scale expects numeric ranges"return nil
end
if I==E then
p.warn"Tuya scale input range cannot be zero"return nil
end
return((a-E)*(U-H)/(I-E))+H
end
end
function b.scale_pair(S,R,L,K)
return b.from_to(b.scale(S,R,L,K),b.scale(L,K,S,R))
end
function b.divide_by(o)
return function(f,g,d)
local a,ac=c(f),e(o,g,d)if a==nil or ac==nil then
p.warn"Tuya divide_by expects numeric input and divisor"return nil
end
if ac==0 then
p.warn"Tuya divide_by divisor cannot be zero"return nil
end
return a/ac
end
end
function b.divide_by_pair(o)
return b.from_to(b.divide_by(o),b.multiply_by(o))
end
function b.signed_number_pair(av)
return b.from_to(
function(f,g,Y,d)
local l
if h(Y)=="table"and c(Y.signed_value)~=nil then
l=c(Y.signed_value)else
l=c(f)if l~=nil and l>0x7FFFFFFF then
l=l-4294967296
end
end
if l==nil then
p.warn(string.format("Tuya signed_number_pair expects number, got %s",h(f)))return nil
end
local o=e(av,g,d)if o==nil then
o=1
end
if o==0 then
p.warn"Tuya signed_number_pair scale cannot be zero"return nil
end
return l/o
end,
function(f,g,d)
local a=c(f)if a==nil then
p.warn(string.format("Tuya signed_number_pair expects number, got %s",h(f)))return nil
end
local r=e(av,g,d)if r==nil then
r=1
end
if r==0 then
p.warn"Tuya signed_number_pair scale cannot be zero"return nil
end
return a*r
end
)
end
function b.multiply_by(r)
return function(f,g,d)
local a,an=c(f),e(r,g,d)if a==nil or an==nil then
p.warn"Tuya multiply_by expects numeric input and multiplier"return nil
end
return a*an
end
end
function b.wrap_signed(ag,aw)
return b.from_to(
function(f,g,d)
local a,q,Q=c(f),e(ag,g,d),e(aw,g,d)if a==nil or q==nil or Q==nil then
p.warn"Tuya wrapped_signed expects numeric input, modulus, and cutoff"return nil
end
if a>Q then
return a-q
end
return a
end,
function(f,g,d)
local a,q=c(f),e(ag,g,d)if a==nil or q==nil then
p.warn"Tuya wrapped_signed expects numeric input and modulus"return nil
end
if a<0 then
return q+a
end
return a
end
)
end
function b.threshold_parser()
return function(f)
return ay.parse_threshold(f)
end
end
function b.cover_position_inverted()
return b.from_to(
function(f)
local a=c(f)if a==nil then
p.warn"Tuya cover_position_inverted expects number"return nil
end
return 100-a
end,
function(f)
local a=c(f)if a==nil then
p.warn"Tuya cover_position_inverted expects number"return nil
end
return 100-a
end
)
end
end
return Z
