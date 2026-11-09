local function Z(ax,t)
local aB,s,B,f,d,ar,Q,az,C,af,y=t.utils,t.log,t.math_floor,t.type_check,t.tonumber_check,t.raw_bytes,t.string_byte,t.string_char,t.string_len,t.table_concat,{}










local function ay(b)
return b
end
local function j(al,g,c)
if f(al)=="function"then
return al(g,c)end
return al
end
local function i(al,g,c)
local v=j(al,g,c)if v==nil then
return nil
end
return d(v)
end
local function w(G)
local N={}for aw,ao in pairs(G)do
N[ao]=aw
end
return N
end
local function A(G,g,c)
local v=j(G,g,c)if v==nil then
return y
end
if f(v)~="table"then
s.warn(string.format("Tuya lookup expects table map, got %s",f(v)))return y
end
return v
end
local function ae(o,h,k)
if f(o)~="string"then
return nil
end
local V=h or 1
local ag=k or(C(o)-V+1)if V<1 or ag<1 or(V+ag-1)>C(o)then
return nil
end
local b=0
for ah=V,V+ag-1 do
b=(b*256)+Q(o,ah)end
return b
end
local function O(o,H,g,c)
local T,n=C(o),f(H)=="table"and H or y
local k=i(n.bytes or n.length,g,c)if k==nil then
k=T
end
k=B(k)if k<1 or k>T then
s.warn"Tuya raw_uint_be requires valid byte count"return nil,nil
end
local h=i(n.start,g,c)if h==nil then
local ap=i(n.offset,g,c)if ap~=nil then
h=B(ap)+1
end
end
if h==nil then
local an=j(n.from_tail,g,c)if an==true then
h=T-k+1
else
h=1
end
end
h=B(h)if h<1 or(h+k-1)>T then
s.warn"Tuya raw_uint_be slice is out of range"return nil,nil
end
return h,k
end
local function as(o)
local aj={}for ah=1,C(o)do
aj[#aj+1]=string.format("%02X",Q(o,ah))end
return af(aj)
end
local function ak(G)
local ai={}for aw,_ in pairs(G or y)do
local P=d(aw)if P~=nil then
ai[#ai+1]=B(P)end
end
table.sort(ai)return ai
end
local a=ax.converter
function a.pipe(...)
local W={...}if #W==1 and f(W[1])=="table"then
W=W[1]end
return function(b,g,c)
local X=b
for _,aA in ipairs(W)do
X=aA(X,g,c)end
return X
end
end
function a.from_to(z,ad)
local au={}if f(z)=="function"then
au.from=z
end
if f(ad)=="function"then
au.to=ad
end
return au
end
function a.from_only(z)
return a.from_to(z,nil)
end
function a.to_bool(p,r)
return function(b)
if f(b)=="boolean"then
return b
end
if b==p then
return true
end
if b==r then
return false
end
s.warn(string.format("Tuya to_bool expected %s or %s, got %s",tostring(p),tostring(r),tostring(b)))return nil
end
end
function a.bool_pair(p,r)
return a.from_to(a.to_bool(p,r),
function(b)
if b==true then
return p
end
if b==false then
return r
end
s.warn(string.format("Tuya bool_pair expected boolean, got %s",f(b)))return nil
end
)
end
function a.lookup_from_to(G,u)
local x=f(G)=="table"and G or nil
local ab=x and w(x)or nil
return a.from_to(
function(b,g,c)
local E=x or A(G,g,c)local N=ab or w(E)local K=N[b]if K~=nil then
return K
end
local D=j(u,g,c)if D~=nil then
return D
end
s.warn(string.format("Tuya lookup_from_to missing value: %s",tostring(b)))return nil
end,
a.lookup_value(G,u))
end
function a.lookup_value(G,u)
local x=f(G)=="table"and G or nil
return function(b,g,c)
local E=x or A(G,g,c)local K=E[b]if K~=nil then
return K
end
local D=j(u,g,c)if D~=nil then
return D
end
s.warn(string.format("Tuya lookup missing key: %s",tostring(b)))return nil
end
end
function a.raw_uint_be(m,H)
local aa=f(H)=="table"and H or nil
return a.from_only(function(b,g,c)
local o=ar(b)if o==nil then
s.warn(string.format("Tuya raw_uint_be expects bytes, got %s",f(b)))return nil
end
local h,k=O(o,aa,g,c)if h==nil then
return nil
end
local aq=ae(o,h,k)if aq==nil then
s.warn"Tuya raw_uint_be failed to parse payload"return nil
end
local ac=i(m,g,c)if ac==nil then
ac=1
end
if ac==0 then
s.warn"Tuya raw_uint_be divisor cannot be zero"return nil
end
return aq/ac
end)
end
function a.true_false0()
return a.bool_pair(0,1)
end
function a.true_false1()
return a.bool_pair(1,0)
end
function a.true_false(p)
return a.from_only(function(b,g,c)
local at=j(p,g,c)return b==at
end)
end
function a.divide_by_from_only(m)
return a.from_only(a.divide_by(m))
end
function a.power()
return a.from_only(function(b)
local e=d(b)if e==nil then
s.warn(string.format("Tuya power expects number, got %s",f(b)))return nil
end
if e>268435455 then
return(429496732-e)*-1
end
return e
end)
end
function a.scale(S,R,M,L)
return function(b)
local e,F,J,I,U=d(b),d(S),d(R),d(M),d(L)if e==nil then
s.warn(string.format("Tuya scale expects number, got %s",f(b)))return nil
end
if F==nil or J==nil or I==nil or U==nil then
s.warn"Tuya scale expects numeric ranges"return nil
end
if J==F then
s.warn"Tuya scale input range cannot be zero"return nil
end
return((e-F)*(U-I)/(J-F))+I
end
end
function a.scale_pair(S,R,M,L)
return a.from_to(a.scale(S,R,M,L),a.scale(M,L,S,R))
end
function a.divide_by(m)
return function(b,g,c)
local e,ac=d(b),i(m,g,c)if e==nil or ac==nil then
s.warn"Tuya divide_by expects numeric input and divisor"return nil
end
if ac==0 then
s.warn"Tuya divide_by divisor cannot be zero"return nil
end
return e/ac
end
end
function a.divide_by_pair(m)
return a.from_to(a.divide_by(m),a.multiply_by(m))
end
function a.signed_number_pair(av)
return a.from_to(
function(b,g,Y,c)
local l
if f(Y)=="table"and d(Y.signed_value)~=nil then
l=d(Y.signed_value)else
l=d(b)if l~=nil and l>0x7FFFFFFF then
l=l-4294967296
end
end
if l==nil then
s.warn(string.format("Tuya signed_number_pair expects number, got %s",f(b)))return nil
end
local m=i(av,g,c)if m==nil then
m=1
end
if m==0 then
s.warn"Tuya signed_number_pair scale cannot be zero"return nil
end
return l/m
end,
function(b,g,c)
local e=d(b)if e==nil then
s.warn(string.format("Tuya signed_number_pair expects number, got %s",f(b)))return nil
end
local q=i(av,g,c)if q==nil then
q=1
end
if q==0 then
s.warn"Tuya signed_number_pair scale cannot be zero"return nil
end
return e*q
end
)
end
function a.multiply_by(q)
return function(b,g,c)
local e,am=d(b),i(q,g,c)if e==nil or am==nil then
s.warn"Tuya multiply_by expects numeric input and multiplier"return nil
end
return e*am
end
end
function a.threshold_parser()
return function(b)
return ax.parse_threshold(b)
end
end
end
return Z
