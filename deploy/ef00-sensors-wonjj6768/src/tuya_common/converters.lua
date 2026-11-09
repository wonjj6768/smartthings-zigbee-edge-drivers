local function ah(aK,w)
local aN,z,r,e,d,am,L,au,B,J,E=w.utils,w.log,w.math_floor,w.type_check,w.tonumber_check,w.raw_bytes,w.string_byte,w.string_char,w.string_len,w.table_concat,{}










local function aL(c)
return c
end
local function j(ay,f,b)
if e(ay)=="function"then
return ay(f,b)end
return ay
end
local function i(ay,f,b)
local y=j(ay,f,b)if y==nil then
return nil
end
return d(y)
end
local function A(C)
local U={}for aJ,aB in pairs(C)do
U[aB]=aJ
end
return U
end
local function s(C,f,b)
local y=j(C,f,b)if y==nil then
return E
end
if e(y)~="table"then
z.warn(string.format("Tuya lookup expects table map, got %s",e(y)))return E
end
return y
end
local function P(l,h,k)
if e(l)~="string"then
return nil
end
local ad=h or 1
local av=k or(B(l)-ad+1)if ad<1 or av<1 or(ad+av-1)>B(l)then
return nil
end
local c=0
for aa=ad,ad+av-1 do
c=(c*256)+L(l,aa)end
return c
end
local function W(l,M,f,b)
local G,q=B(l),e(M)=="table"and M or E
local k=i(q.bytes or q.length,f,b)if k==nil then
k=G
end
k=r(k)if k<1 or k>G then
z.warn"Tuya raw_uint_be requires valid byte count"return nil,nil
end
local h=i(q.start,f,b)if h==nil then
local aC=i(q.offset,f,b)if aC~=nil then
h=r(aC)+1
end
end
if h==nil then
local aA=j(q.from_tail,f,b)if aA==true then
h=G-k+1
else
h=1
end
end
h=r(h)if h<1 or(h+k-1)>G then
z.warn"Tuya raw_uint_be slice is out of range"return nil,nil
end
return h,k
end
local function V(l)
local ax={}for aa=1,B(l)do
ax[#ax+1]=string.format("%02X",L(l,aa))end
return J(ax)
end
local function D(C)
local aw={}for aJ,_ in pairs(C or E)do
local X=d(aJ)if X~=nil then
aw[#aw+1]=r(X)end
end
table.sort(aw)return aw
end
local a=aK.converter
function a.pipe(...)
local ae={...}if #ae==1 and e(ae[1])=="table"then
ae=ae[1]end
return function(c,f,b)
local af=c
for _,aM in ipairs(ae)do
af=aM(af,f,b)end
return af
end
end
function a.from_to(F,an)
local aF={}if e(F)=="function"then
aF.from=F
end
if e(an)=="function"then
aF.to=an
end
return aF
end
function a.from_only(F)
return a.from_to(F,nil)
end
function a.lookup_from_to(C,x)
local o=e(C)=="table"and C or nil
local aj=o and A(o)or nil
return a.from_to(
function(c,f,b)
local p=o or s(C,f,b)local U=aj or A(p)local R=U[c]if R~=nil then
return R
end
local I=j(x,f,b)if I~=nil then
return I
end
z.warn(string.format("Tuya lookup_from_to missing value: %s",tostring(c)))return nil
end,
a.lookup_value(C,x))
end
function a.lookup_value(C,x)
local o=e(C)=="table"and C or nil
return function(c,f,b)
local p=o or s(C,f,b)local R=p[c]if R~=nil then
return R
end
local I=j(x,f,b)if I~=nil then
return I
end
z.warn(string.format("Tuya lookup missing key: %s",tostring(c)))return nil
end
end
function a.raw_uint_be(n,M)
local ai=e(M)=="table"and M or nil
return a.from_only(function(c,f,b)
local l=am(c)if l==nil then
z.warn(string.format("Tuya raw_uint_be expects bytes, got %s",e(c)))return nil
end
local h,k=W(l,ai,f,b)if h==nil then
return nil
end
local aD=P(l,h,k)if aD==nil then
z.warn"Tuya raw_uint_be failed to parse payload"return nil
end
local ak=i(n,f,b)if ak==nil then
ak=1
end
if ak==0 then
z.warn"Tuya raw_uint_be divisor cannot be zero"return nil
end
return aD/ak
end)
end
function a.raw_identifier()
return a.from_only(function(c)
local l=am(c)if l==nil then
return c
end
local G,aq,al=B(l),{},true
for aa=1,G do
local H=L(l,aa)if H~=0 then
if H<32 or H>126 then
al=false
end
aq[#aq+1]=au(H)end
end
if al and #aq>0 then
return J(aq)end
if G<=4 then
return P(l,1,G)end
return V(l)
end)
end
function a.bitmap_flags(C,as,aE)
local o=e(C)=="table"and C or nil
local at=o and D(o)or nil
return a.from_only(function(c,f,b)
local O=d(c)if O==nil then
z.warn(string.format("Tuya bitmap_flags expects number, got %s",e(c)))return nil
end
local p=o or s(C,f,b)local ap,ab,ao=at or D(p),{},r(O)for _,aI in ipairs(ap)do
if r(ao/aI)%2==1 then
local aG=p[aI]or p[tostring(aI)]if aG~=nil then
ab[#ab+1]=aG
end
end
end
if #ab==0 then
return j(as,f,b)end
local t=j(aE,f,b)if e(t)~="string"then
t=","end
return J(ab,t)
end)
end
function a.alarm_state_lower_upper_cancel()
return a.lookup_from_to{lower_alarm=0,upper_alarm=1,cancel=2}
end
function a.temperature_unit()
return a.lookup_from_to{celsius=0,fahrenheit=1}
end
function a.report_period_hours()
return a.lookup_from_to{["1h"]=0,["2h"]=1,["3h"]=2,["4h"]=3,["6h"]=4,["8h"]=5,["12h"]=6,["24h"]=7,["48h"]=8,["72h"]=9}
end
function a.water_meter_faults()
return a.bitmap_flags({[1]="battery_alarm",[2]="magnetism_alarm",[4]="cover_alarm",[8]="credit_alarm",[16]="switch_gaps_alarm",[32]="meter_body_alarm",[64]="abnormal_water_alarm",[128]="arrearage_alarm",[256]="overflow_alarm",[512]="revflow_alarm",[1024]="over_pre_alarm",[2048]="empty_pipe_alarm",[4096]="transducer_alarm"},"no_alarm",",")
end
function a.water_warning()
return a.lookup_from_to{none=0,alarm=1}
end
function a.soil_fertility_warning()
return a.lookup_from_to{none=0,alarm=1}
end
function a.power()
return a.from_only(function(c)
local g=d(c)if g==nil then
z.warn(string.format("Tuya power expects number, got %s",e(c)))return nil
end
if g>268435455 then
return(429496732-g)*-1
end
return g
end)
end
function a.scale(Z,Y,T,S)
return function(c)
local g,K,Q,N,ac=d(c),d(Z),d(Y),d(T),d(S)if g==nil then
z.warn(string.format("Tuya scale expects number, got %s",e(c)))return nil
end
if K==nil or Q==nil or N==nil or ac==nil then
z.warn"Tuya scale expects numeric ranges"return nil
end
if Q==K then
z.warn"Tuya scale input range cannot be zero"return nil
end
return((g-K)*(ac-N)/(Q-K))+N
end
end
function a.scale_pair(Z,Y,T,S)
return a.from_to(a.scale(Z,Y,T,S),a.scale(T,S,Z,Y))
end
function a.divide_by(n)
return function(c,f,b)
local g,ak=d(c),i(n,f,b)if g==nil or ak==nil then
z.warn"Tuya divide_by expects numeric input and divisor"return nil
end
if ak==0 then
z.warn"Tuya divide_by divisor cannot be zero"return nil
end
return g/ak
end
end
function a.divide_by_pair(n)
return a.from_to(a.divide_by(n),a.multiply_by(n))
end
function a.signed_number_pair(ar)
return a.from_to(
function(c,f,ag,b)
local m
if e(ag)=="table"and d(ag.signed_value)~=nil then
m=d(ag.signed_value)else
m=d(c)if m~=nil and m>0x7FFFFFFF then
m=m-4294967296
end
end
if m==nil then
z.warn(string.format("Tuya signed_number_pair expects number, got %s",e(c)))return nil
end
local n=i(ar,f,b)if n==nil then
n=1
end
if n==0 then
z.warn"Tuya signed_number_pair scale cannot be zero"return nil
end
return m/n
end,
function(c,f,b)
local g=d(c)if g==nil then
z.warn(string.format("Tuya signed_number_pair expects number, got %s",e(c)))return nil
end
local u=i(ar,f,b)if u==nil then
u=1
end
if u==0 then
z.warn"Tuya signed_number_pair scale cannot be zero"return nil
end
return g*u
end
)
end
function a.multiply_by(u)
return function(c,f,b)
local g,az=d(c),i(u,f,b)if g==nil or az==nil then
z.warn"Tuya multiply_by expects numeric input and multiplier"return nil
end
return g*az
end
end
function a.threshold_parser()
return function(c)
return aK.parse_threshold(c)
end
end
function a.tuya_unsigned_temp(ar)
local n=ar or 10
return a.from_to(
function(c)
if c==nil then return nil end
local v=c
if v>8192 then
v=v-65535
end
return v/n
end,
function(c)
if c==nil then return nil end
local aH=r(c*n+0.5)if aH<0 then
aH=aH+65535
end
return aH
end
)
end
end
return ah
