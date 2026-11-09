local function Z(aw,s)
local aA,r,B,f,d,ar,Q,ay,C,af,y=s.utils,s.log,s.math_floor,s.type_check,s.tonumber_check,s.raw_bytes,s.string_byte,s.string_char,s.string_len,s.table_concat,{}










local function ax(b)
return b
end
local function k(al,g,c)
if f(al)=="function"then
return al(g,c)end
return al
end
local function i(al,g,c)
local u=k(al,g,c)if u==nil then
return nil
end
return d(u)
end
local function v(G)
local N={}for av,ao in pairs(G)do
N[ao]=av
end
return N
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
local V=h or 1
local ag=j or(C(n)-V+1)if V<1 or ag<1 or(V+ag-1)>C(n)then
return nil
end
local b=0
for ah=V,V+ag-1 do
b=(b*256)+Q(n,ah)end
return b
end
local function O(n,H,g,c)
local T,m=C(n),f(H)=="table"and H or y
local j=i(m.bytes or m.length,g,c)if j==nil then
j=T
end
j=B(j)if j<1 or j>T then
r.warn"Tuya raw_uint_be requires valid byte count"return nil,nil
end
local h=i(m.start,g,c)if h==nil then
local ap=i(m.offset,g,c)if ap~=nil then
h=B(ap)+1
end
end
if h==nil then
local an=k(m.from_tail,g,c)if an==true then
h=T-j+1
else
h=1
end
end
h=B(h)if h<1 or(h+j-1)>T then
r.warn"Tuya raw_uint_be slice is out of range"return nil,nil
end
return h,j
end
local function as(n)
local aj={}for ah=1,C(n)do
aj[#aj+1]=string.format("%02X",Q(n,ah))end
return af(aj)
end
local function ak(G)
local ai={}for av,_ in pairs(G or y)do
local P=d(av)if P~=nil then
ai[#ai+1]=B(P)end
end
table.sort(ai)return ai
end
local a=aw.converter
function a.pipe(...)
local W={...}if #W==1 and f(W[1])=="table"then
W=W[1]end
return function(b,g,c)
local X=b
for _,az in ipairs(W)do
X=az(X,g,c)end
return X
end
end
function a.from_to(z,ad)
local at={}if f(z)=="function"then
at.from=z
end
if f(ad)=="function"then
at.to=ad
end
return at
end
function a.from_only(z)
return a.from_to(z,nil)
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
function a.lookup_from_to(G,t)
local w=f(G)=="table"and G or nil
local ab=w and v(w)or nil
return a.from_to(
function(b,g,c)
local E=w or A(G,g,c)local N=ab or v(E)local K=N[b]if K~=nil then
return K
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
local E=w or A(G,g,c)local K=E[b]if K~=nil then
return K
end
local D=k(t,g,c)if D~=nil then
return D
end
r.warn(string.format("Tuya lookup missing key: %s",tostring(b)))return nil
end
end
function a.raw_uint_be(o,H)
local aa=f(H)=="table"and H or nil
return a.from_only(function(b,g,c)
local n=ar(b)if n==nil then
r.warn(string.format("Tuya raw_uint_be expects bytes, got %s",f(b)))return nil
end
local h,j=O(n,aa,g,c)if h==nil then
return nil
end
local aq=ae(n,h,j)if aq==nil then
r.warn"Tuya raw_uint_be failed to parse payload"return nil
end
local ac=i(o,g,c)if ac==nil then
ac=1
end
if ac==0 then
r.warn"Tuya raw_uint_be divisor cannot be zero"return nil
end
return aq/ac
end)
end
function a.true_false1()
return a.bool_pair(1,0)
end
function a.power_outage_memory()
return a.lookup_from_to{off=0,on=1,restore=2}
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
function a.scale(S,R,M,L)
return function(b)
local e,F,J,I,U=d(b),d(S),d(R),d(M),d(L)if e==nil then
r.warn(string.format("Tuya scale expects number, got %s",f(b)))return nil
end
if F==nil or J==nil or I==nil or U==nil then
r.warn"Tuya scale expects numeric ranges"return nil
end
if J==F then
r.warn"Tuya scale input range cannot be zero"return nil
end
return((e-F)*(U-I)/(J-F))+I
end
end
function a.scale_pair(S,R,M,L)
return a.from_to(a.scale(S,R,M,L),a.scale(M,L,S,R))
end
function a.divide_by(o)
return function(b,g,c)
local e,ac=d(b),i(o,g,c)if e==nil or ac==nil then
r.warn"Tuya divide_by expects numeric input and divisor"return nil
end
if ac==0 then
r.warn"Tuya divide_by divisor cannot be zero"return nil
end
return e/ac
end
end
function a.divide_by_pair(o)
return a.from_to(a.divide_by(o),a.multiply_by(o))
end
function a.signed_number_pair(au)
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
r.warn(string.format("Tuya signed_number_pair expects number, got %s",f(b)))return nil
end
local o=i(au,g,c)if o==nil then
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
local p=i(au,g,c)if p==nil then
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
local e,am=d(b),i(p,g,c)if e==nil or am==nil then
r.warn"Tuya multiply_by expects numeric input and multiplier"return nil
end
return e*am
end
end
function a.threshold_parser()
return function(b)
return aw.parse_threshold(b)
end
end
end
return Z
