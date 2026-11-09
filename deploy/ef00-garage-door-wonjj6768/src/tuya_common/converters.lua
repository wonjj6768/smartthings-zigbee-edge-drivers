local function Z(aw,s)
local aA,q,B,c,e,ar,Q,ay,C,af,y=s.utils,s.log,s.math_floor,s.type_check,s.tonumber_check,s.raw_bytes,s.string_byte,s.string_char,s.string_len,s.table_concat,{}










local function ax(b)
return b
end
local function k(al,g,d)
if c(al)=="function"then
return al(g,d)end
return al
end
local function i(al,g,d)
local u=k(al,g,d)if u==nil then
return nil
end
return e(u)
end
local function v(G)
local N={}for av,ao in pairs(G)do
N[ao]=av
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
local function ae(n,h,j)
if c(n)~="string"then
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
local function O(n,H,g,d)
local T,m=C(n),c(H)=="table"and H or y
local j=i(m.bytes or m.length,g,d)if j==nil then
j=T
end
j=B(j)if j<1 or j>T then
q.warn"Tuya raw_uint_be requires valid byte count"return nil,nil
end
local h=i(m.start,g,d)if h==nil then
local ap=i(m.offset,g,d)if ap~=nil then
h=B(ap)+1
end
end
if h==nil then
local an=k(m.from_tail,g,d)if an==true then
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
local function as(n)
local aj={}for ah=1,C(n)do
aj[#aj+1]=string.format("%02X",Q(n,ah))end
return af(aj)
end
local function ak(G)
local ai={}for av,_ in pairs(G or y)do
local P=e(av)if P~=nil then
ai[#ai+1]=B(P)end
end
table.sort(ai)return ai
end
local a=aw.converter
function a.pipe(...)
local W={...}if #W==1 and c(W[1])=="table"then
W=W[1]end
return function(b,g,d)
local X=b
for _,az in ipairs(W)do
X=az(X,g,d)end
return X
end
end
function a.from_to(z,ad)
local at={}if c(z)=="function"then
at.from=z
end
if c(ad)=="function"then
at.to=ad
end
return at
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
function a.raw_uint_be(o,H)
local aa=c(H)=="table"and H or nil
return a.from_only(function(b,g,d)
local n=ar(b)if n==nil then
q.warn(string.format("Tuya raw_uint_be expects bytes, got %s",c(b)))return nil
end
local h,j=O(n,aa,g,d)if h==nil then
return nil
end
local aq=ae(n,h,j)if aq==nil then
q.warn"Tuya raw_uint_be failed to parse payload"return nil
end
local ac=i(o,g,d)if ac==nil then
ac=1
end
if ac==0 then
q.warn"Tuya raw_uint_be divisor cannot be zero"return nil
end
return aq/ac
end)
end
function a.true_false0()
return a.bool_pair(0,1)
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
function a.divide_by(o)
return function(b,g,d)
local f,ac=e(b),i(o,g,d)if f==nil or ac==nil then
q.warn"Tuya divide_by expects numeric input and divisor"return nil
end
if ac==0 then
q.warn"Tuya divide_by divisor cannot be zero"return nil
end
return f/ac
end
end
function a.divide_by_pair(o)
return a.from_to(a.divide_by(o),a.multiply_by(o))
end
function a.signed_number_pair(au)
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
local o=i(au,g,d)if o==nil then
o=1
end
if o==0 then
q.warn"Tuya signed_number_pair scale cannot be zero"return nil
end
return l/o
end,
function(b,g,d)
local f=e(b)if f==nil then
q.warn(string.format("Tuya signed_number_pair expects number, got %s",c(b)))return nil
end
local p=i(au,g,d)if p==nil then
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
local f,am=e(b),i(p,g,d)if f==nil or am==nil then
q.warn"Tuya multiply_by expects numeric input and multiplier"return nil
end
return f*am
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
return aw.parse_threshold(b)
end
end
end
return Z
