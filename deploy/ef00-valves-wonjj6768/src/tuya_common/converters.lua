local function ag(aI,v)
local aL,y,t,d,c,al,K,as,A,I,D=v.utils,v.log,v.math_floor,v.type_check,v.tonumber_check,v.raw_bytes,v.string_byte,v.string_char,v.string_len,v.table_concat,{}










local function aJ(e)
return e
end
local function j(aw,f,b)
if d(aw)=="function"then
return aw(f,b)end
return aw
end
local function i(aw,f,b)
local x=j(aw,f,b)if x==nil then
return nil
end
return c(x)
end
local function z(B)
local T={}for aH,az in pairs(B)do
T[az]=aH
end
return T
end
local function r(B,f,b)
local x=j(B,f,b)if x==nil then
return D
end
if d(x)~="table"then
y.warn(string.format("Tuya lookup expects table map, got %s",d(x)))return D
end
return x
end
local function O(l,h,k)
if d(l)~="string"then
return nil
end
local ac=h or 1
local at=k or(A(l)-ac+1)if ac<1 or at<1 or(ac+at-1)>A(l)then
return nil
end
local e=0
for Z=ac,ac+at-1 do
e=(e*256)+K(l,Z)end
return e
end
local function V(l,L,f,b)
local F,q=A(l),d(L)=="table"and L or D
local k=i(q.bytes or q.length,f,b)if k==nil then
k=F
end
k=t(k)if k<1 or k>F then
y.warn"Tuya raw_uint_be requires valid byte count"return nil,nil
end
local h=i(q.start,f,b)if h==nil then
local aA=i(q.offset,f,b)if aA~=nil then
h=t(aA)+1
end
end
if h==nil then
local ay=j(q.from_tail,f,b)if ay==true then
h=F-k+1
else
h=1
end
end
h=t(h)if h<1 or(h+k-1)>F then
y.warn"Tuya raw_uint_be slice is out of range"return nil,nil
end
return h,k
end
local function U(l)
local av={}for Z=1,A(l)do
av[#av+1]=string.format("%02X",K(l,Z))end
return I(av)
end
local function C(B)
local au={}for aH,_ in pairs(B or D)do
local W=c(aH)if W~=nil then
au[#au+1]=t(W)end
end
table.sort(au)return au
end
local a=aI.converter
function a.pipe(...)
local ad={...}if #ad==1 and d(ad[1])=="table"then
ad=ad[1]end
return function(e,f,b)
local ae=e
for _,aK in ipairs(ad)do
ae=aK(ae,f,b)end
return ae
end
end
function a.from_to(E,am)
local aD={}if d(E)=="function"then
aD.from=E
end
if d(am)=="function"then
aD.to=am
end
return aD
end
function a.from_only(E)
return a.from_to(E,nil)
end
function a.lookup_from_to(B,w)
local n=d(B)=="table"and B or nil
local ai=n and z(n)or nil
return a.from_to(
function(e,f,b)
local p=n or r(B,f,b)local T=ai or z(p)local Q=T[e]if Q~=nil then
return Q
end
local H=j(w,f,b)if H~=nil then
return H
end
y.warn(string.format("Tuya lookup_from_to missing value: %s",tostring(e)))return nil
end,
a.lookup_value(B,w))
end
function a.lookup_value(B,w)
local n=d(B)=="table"and B or nil
return function(e,f,b)
local p=n or r(B,f,b)local Q=p[e]if Q~=nil then
return Q
end
local H=j(w,f,b)if H~=nil then
return H
end
y.warn(string.format("Tuya lookup missing key: %s",tostring(e)))return nil
end
end
function a.raw_uint_be(o,L)
local ah=d(L)=="table"and L or nil
return a.from_only(function(e,f,b)
local l=al(e)if l==nil then
y.warn(string.format("Tuya raw_uint_be expects bytes, got %s",d(e)))return nil
end
local h,k=V(l,ah,f,b)if h==nil then
return nil
end
local aB=O(l,h,k)if aB==nil then
y.warn"Tuya raw_uint_be failed to parse payload"return nil
end
local aj=i(o,f,b)if aj==nil then
aj=1
end
if aj==0 then
y.warn"Tuya raw_uint_be divisor cannot be zero"return nil
end
return aB/aj
end)
end
function a.raw_identifier()
return a.from_only(function(e)
local l=al(e)if l==nil then
return e
end
local F,ap,ak=A(l),{},true
for Z=1,F do
local G=K(l,Z)if G~=0 then
if G<32 or G>126 then
ak=false
end
ap[#ap+1]=as(G)end
end
if ak and #ap>0 then
return I(ap)end
if F<=4 then
return O(l,1,F)end
return U(l)
end)
end
function a.bitmap_flags(B,aq,aC)
local n=d(B)=="table"and B or nil
local ar=n and C(n)or nil
return a.from_only(function(e,f,b)
local N=c(e)if N==nil then
y.warn(string.format("Tuya bitmap_flags expects number, got %s",d(e)))return nil
end
local p=n or r(B,f,b)local ao,aa,an=ar or C(p),{},t(N)for _,aG in ipairs(ao)do
if t(an/aG)%2==1 then
local aE=p[aG]or p[tostring(aG)]if aE~=nil then
aa[#aa+1]=aE
end
end
end
if #aa==0 then
return j(aq,f,b)end
local s=j(aC,f,b)if d(s)~="string"then
s=","end
return I(aa,s)
end)
end
function a.report_period_hours()
return a.lookup_from_to{["1h"]=0,["2h"]=1,["3h"]=2,["4h"]=3,["6h"]=4,["8h"]=5,["12h"]=6,["24h"]=7,["48h"]=8,["72h"]=9}
end
function a.water_meter_faults()
return a.bitmap_flags({[1]="battery_alarm",[2]="magnetism_alarm",[4]="cover_alarm",[8]="credit_alarm",[16]="switch_gaps_alarm",[32]="meter_body_alarm",[64]="abnormal_water_alarm",[128]="arrearage_alarm",[256]="overflow_alarm",[512]="revflow_alarm",[1024]="over_pre_alarm",[2048]="empty_pipe_alarm",[4096]="transducer_alarm"},"no_alarm",",")
end
function a.divide_by_from_only(o)
return a.from_only(a.divide_by(o))
end
function a.power()
return a.from_only(function(e)
local g=c(e)if g==nil then
y.warn(string.format("Tuya power expects number, got %s",d(e)))return nil
end
if g>268435455 then
return(429496732-g)*-1
end
return g
end)
end
function a.scale(Y,X,S,R)
return function(e)
local g,J,P,M,ab=c(e),c(Y),c(X),c(S),c(R)if g==nil then
y.warn(string.format("Tuya scale expects number, got %s",d(e)))return nil
end
if J==nil or P==nil or M==nil or ab==nil then
y.warn"Tuya scale expects numeric ranges"return nil
end
if P==J then
y.warn"Tuya scale input range cannot be zero"return nil
end
return((g-J)*(ab-M)/(P-J))+M
end
end
function a.scale_pair(Y,X,S,R)
return a.from_to(a.scale(Y,X,S,R),a.scale(S,R,Y,X))
end
function a.divide_by(o)
return function(e,f,b)
local g,aj=c(e),i(o,f,b)if g==nil or aj==nil then
y.warn"Tuya divide_by expects numeric input and divisor"return nil
end
if aj==0 then
y.warn"Tuya divide_by divisor cannot be zero"return nil
end
return g/aj
end
end
function a.divide_by_pair(o)
return a.from_to(a.divide_by(o),a.multiply_by(o))
end
function a.signed_number_pair(aF)
return a.from_to(
function(e,f,af,b)
local m
if d(af)=="table"and c(af.signed_value)~=nil then
m=c(af.signed_value)else
m=c(e)if m~=nil and m>0x7FFFFFFF then
m=m-4294967296
end
end
if m==nil then
y.warn(string.format("Tuya signed_number_pair expects number, got %s",d(e)))return nil
end
local o=i(aF,f,b)if o==nil then
o=1
end
if o==0 then
y.warn"Tuya signed_number_pair scale cannot be zero"return nil
end
return m/o
end,
function(e,f,b)
local g=c(e)if g==nil then
y.warn(string.format("Tuya signed_number_pair expects number, got %s",d(e)))return nil
end
local u=i(aF,f,b)if u==nil then
u=1
end
if u==0 then
y.warn"Tuya signed_number_pair scale cannot be zero"return nil
end
return g*u
end
)
end
function a.multiply_by(u)
return function(e,f,b)
local g,ax=c(e),i(u,f,b)if g==nil or ax==nil then
y.warn"Tuya multiply_by expects numeric input and multiplier"return nil
end
return g*ax
end
end
function a.threshold_parser()
return function(e)
return aI.parse_threshold(e)
end
end
end
return ag
