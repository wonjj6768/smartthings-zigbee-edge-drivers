local function ac(aE,v)
local aI,y,t,d,c,aw,S,aG,E,M,C=v.utils,v.log,v.math_floor,v.type_check,v.tonumber_check,v.raw_bytes,v.string_byte,v.string_char,v.string_len,v.table_concat,{}










local function aF(g)
return g
end
local function j(aq,e,b)
if d(aq)=="function"then
return aq(e,b)end
return aq
end
local function i(aq,e,b)
local x=j(aq,e,b)if x==nil then
return nil
end
return c(x)
end
local function z(A)
local P={}for aD,at in pairs(A)do
P[at]=aD
end
return P
end
local function r(A,e,b)
local x=j(A,e,b)if x==nil then
return C
end
if d(x)~="table"then
y.warn(string.format("Tuya lookup expects table map, got %s",d(x)))return C
end
return x
end
local function ai(p,h,k)
if d(p)~="string"then
return nil
end
local Y=h or 1
local am=k or(E(p)-Y+1)if Y<1 or am<1 or(Y+am-1)>E(p)then
return nil
end
local g=0
for an=Y,Y+am-1 do
g=(g*256)+S(p,an)end
return g
end
local function Q(p,H,e,b)
local W,o=E(p),d(H)=="table"and H or C
local k=i(o.bytes or o.length,e,b)if k==nil then
k=W
end
k=t(k)if k<1 or k>W then
y.warn"Tuya raw_uint_be requires valid byte count"return nil,nil
end
local h=i(o.start,e,b)if h==nil then
local au=i(o.offset,e,b)if au~=nil then
h=t(au)+1
end
end
if h==nil then
local as=j(o.from_tail,e,b)if as==true then
h=W-k+1
else
h=1
end
end
h=t(h)if h<1 or(h+k-1)>W then
y.warn"Tuya raw_uint_be slice is out of range"return nil,nil
end
return h,k
end
local function ay(p)
local ap={}for an=1,E(p)do
ap[#ap+1]=string.format("%02X",S(p,an))end
return M(ap)
end
local function B(A)
local ao={}for aD,_ in pairs(A or C)do
local R=c(aD)if R~=nil then
ao[#ao+1]=t(R)end
end
table.sort(ao)return ao
end
local a=aE.converter
function a.pipe(...)
local Z={...}if #Z==1 and d(Z[1])=="table"then
Z=Z[1]end
return function(g,e,b)
local aa=g
for _,aH in ipairs(Z)do
aa=aH(aa,e,b)end
return aa
end
end
function a.from_to(D,ag)
local az={}if d(D)=="function"then
az.from=D
end
if d(ag)=="function"then
az.to=ag
end
return az
end
function a.from_only(D)
return a.from_to(D,nil)
end
function a.lookup_from_to(A,w)
local m=d(A)=="table"and A or nil
local ae=m and z(m)or nil
return a.from_to(
function(g,e,b)
local n=m or r(A,e,b)local P=ae or z(n)local L=P[g]if L~=nil then
return L
end
local F=j(w,e,b)if F~=nil then
return F
end
y.warn(string.format("Tuya lookup_from_to missing value: %s",tostring(g)))return nil
end,
a.lookup_value(A,w))
end
function a.lookup_value(A,w)
local m=d(A)=="table"and A or nil
return function(g,e,b)
local n=m or r(A,e,b)local L=n[g]if L~=nil then
return L
end
local F=j(w,e,b)if F~=nil then
return F
end
y.warn(string.format("Tuya lookup missing key: %s",tostring(g)))return nil
end
end
function a.raw_uint_be(q,H)
local ad=d(H)=="table"and H or nil
return a.from_only(function(g,e,b)
local p=aw(g)if p==nil then
y.warn(string.format("Tuya raw_uint_be expects bytes, got %s",d(g)))return nil
end
local h,k=Q(p,ad,e,b)if h==nil then
return nil
end
local av=ai(p,h,k)if av==nil then
y.warn"Tuya raw_uint_be failed to parse payload"return nil
end
local af=i(q,e,b)if af==nil then
af=1
end
if af==0 then
y.warn"Tuya raw_uint_be divisor cannot be zero"return nil
end
return av/af
end)
end
function a.bitmap_flags(A,ak,ax)
local m=d(A)=="table"and A or nil
local al=m and B(m)or nil
return a.from_only(function(g,e,b)
local J=c(g)if J==nil then
y.warn(string.format("Tuya bitmap_flags expects number, got %s",d(g)))return nil
end
local n=m or r(A,e,b)local aj,V,ah=al or B(n),{},t(J)for _,aC in ipairs(aj)do
if t(ah/aC)%2==1 then
local aA=n[aC]or n[tostring(aC)]if aA~=nil then
V[#V+1]=aA
end
end
end
if #V==0 then
return j(ak,e,b)end
local s=j(ax,e,b)if d(s)~="string"then
s=","end
return M(V,s)
end)
end
function a.power()
return a.from_only(function(g)
local f=c(g)if f==nil then
y.warn(string.format("Tuya power expects number, got %s",d(g)))return nil
end
if f>268435455 then
return(429496732-f)*-1
end
return f
end)
end
function a.scale(U,T,O,N)
return function(g)
local f,G,K,I,X=c(g),c(U),c(T),c(O),c(N)if f==nil then
y.warn(string.format("Tuya scale expects number, got %s",d(g)))return nil
end
if G==nil or K==nil or I==nil or X==nil then
y.warn"Tuya scale expects numeric ranges"return nil
end
if K==G then
y.warn"Tuya scale input range cannot be zero"return nil
end
return((f-G)*(X-I)/(K-G))+I
end
end
function a.scale_pair(U,T,O,N)
return a.from_to(a.scale(U,T,O,N),a.scale(O,N,U,T))
end
function a.divide_by(q)
return function(g,e,b)
local f,af=c(g),i(q,e,b)if f==nil or af==nil then
y.warn"Tuya divide_by expects numeric input and divisor"return nil
end
if af==0 then
y.warn"Tuya divide_by divisor cannot be zero"return nil
end
return f/af
end
end
function a.divide_by_pair(q)
return a.from_to(a.divide_by(q),a.multiply_by(q))
end
function a.signed_number_pair(aB)
return a.from_to(
function(g,e,ab,b)
local l
if d(ab)=="table"and c(ab.signed_value)~=nil then
l=c(ab.signed_value)else
l=c(g)if l~=nil and l>0x7FFFFFFF then
l=l-4294967296
end
end
if l==nil then
y.warn(string.format("Tuya signed_number_pair expects number, got %s",d(g)))return nil
end
local q=i(aB,e,b)if q==nil then
q=1
end
if q==0 then
y.warn"Tuya signed_number_pair scale cannot be zero"return nil
end
return l/q
end,
function(g,e,b)
local f=c(g)if f==nil then
y.warn(string.format("Tuya signed_number_pair expects number, got %s",d(g)))return nil
end
local u=i(aB,e,b)if u==nil then
u=1
end
if u==0 then
y.warn"Tuya signed_number_pair scale cannot be zero"return nil
end
return f*u
end
)
end
function a.multiply_by(u)
return function(g,e,b)
local f,ar=c(g),i(u,e,b)if f==nil or ar==nil then
y.warn"Tuya multiply_by expects numeric input and multiplier"return nil
end
return f*ar
end
end
function a.threshold_parser()
return function(g)
return aE.parse_threshold(g)
end
end
end
return ac
