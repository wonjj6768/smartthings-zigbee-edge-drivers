local function ar(A,aA,br)
br=br or{switch=function()return nil end}
local d,M,aQ,j,bl,r=aA.type_check,aA.table_insert,aA.tonumber_check,aA.merge_options,aA.copy_keys,A.converter





local function ao(Y,J)
if d(Y)~="table"or d(J)~="table"then
return Y
end
for aq,Q in pairs(J)do
if Y[aq]==nil then
Y[aq]=Q
end
end
return Y
end
local function e(c,b,g)
local a={}if d(c)=="string"then
a.name=c
else
j(a,c)end
j(a,b)if a.name==nil and g~=nil then
a.name=g
end
return a
end
local al={"send_policy","command_id","transaction","batch_key","match_transaction","response_dp","response_dps","match_response"}
local function ak(b)
if d(b)~="table"then
return false
end
for _,aq in ipairs(al)do
if b[aq]~=nil then
return true
end
end
return false
end
local function aF(bg,b)
if ak(b)then
return bg
end
return A.apply_fixed_send_policy(bg)
end
local function v(B,g,y,c,b)
local a=e(c,b,g)local z=a.scale
if z==nil then
z=y
end
if a.converter==nil and a.from_device==nil and a.to_device==nil and z~=1 then
a.converter=r.divide_by_pair(z)end
a.scale=nil
return A.dp_numeric(B,a)
end
local function aV(B,g,y,c,b)
local a=e(c,b,g)local z=a.scale
if z==nil then
z=y
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
local an=r.power()local be=an.from
if z~=1 then
a.from_device=r.pipe(be,r.divide_by(z))else
a.converter=an
end
end
a.scale=nil
return A.dp_numeric(B,a)
end
local function aT(B,g,y,c,b)
local a=e(c,b,g)local z=a.scale
if z==nil then
z=y
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=r.signed_number_pair(z)end
if a.signed==nil then
a.signed=true
end
a.scale=nil
return A.dp_numeric(B,a)
end
local function o(B,g,y,bb,c,b)
local a=e(c,b,g)local z=a.scale
if z==nil then
z=y
end
local bq=
a.datatype==A.DP_TYPE_RAW or
a.raw==true or
a.raw_bytes~=nil or
a.raw_length~=nil or
a.raw_from_tail~=nil or
a.raw_start~=nil or
a.raw_offset~=nil
if bq and a.converter==nil and a.from_device==nil and a.to_device==nil then
local aD={bytes=a.raw_bytes or a.raw_length,length=a.raw_length,from_tail=a.raw_from_tail,start=a.raw_start,offset=a.raw_offset}ao(aD,bb)a.converter=r.raw_uint_be(z,aD)if a.datatype==nil then
a.datatype=A.DP_TYPE_RAW
end
elseif a.converter==nil and a.from_device==nil and a.to_device==nil and z~=1 then
a.converter=r.divide_by_pair(z)end
a.scale=nil
a.raw=nil
a.raw_bytes=nil
a.raw_length=nil
a.raw_from_tail=nil
a.raw_start=nil
a.raw_offset=nil
return A.dp_numeric(B,a)
end
local function V(Q,bo,bn)
local az=aQ(Q)if az==nil then
return nil
end
return bo+bn-az
end
local function aS(B,g,J,c,b)
local a=e(c,b,g)local ae=a.raw_min
if ae==nil then
ae=J.raw_min
end
local ad=a.raw_max
if ad==nil then
ad=J.raw_max
end
local H=a.value_min
if H==nil then
H=J.value_min
end
local G=a.value_max
if G==nil then
G=J.value_max
end
local bu=a.invert==true or a.invert_position==true
if a.converter==nil and a.from_device==nil and a.to_device==nil then
if bu then
local bi,bs=r.scale(ae,ad,H,G),r.scale(H,G,ae,ad)a.converter=r.from_to(
function(Q,aX,aN)
local bp=bi(Q,aX,aN)if bp==nil then
return nil
end
return V(bp,H,G)
end,
function(Q,aX,aN)
local aZ=V(Q,H,G)if aZ==nil then
return nil
end
return bs(aZ,aX,aN)
end
)elseif ae~=H or ad~=G then
a.converter=r.scale_pair(ae,ad,H,G)end
end
a.raw_min=nil
a.raw_max=nil
a.value_min=nil
a.value_max=nil
a.invert=nil
a.invert_position=nil
return A.dp_numeric(B,a)
end
local function bj(phase,aY)
if d(phase)=="string"and phase~=""then
return(aY or"phase").."_"..phase
end
return aY or"phase"
end
local function ba(bw,phase)
local bm={}for _,aq in ipairs(bw or{})do
local aG=aq
if d(phase)=="string"and phase~=""then
aG=aq.."_"..phase
end
bm[aG]=true
end
return bm
end
local function bc(B,g,aP,bh,c,b)
local aW=
d(c)=="string"or
(d(c)=="table"and c.name~=nil)or
(d(b)=="table"and b.name~=nil)local a=e(c,b,g)local phase=a.phase
if not aW and a.name==g then
a.name=bj(phase,g)end
if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=aP(a)end
if a.field==nil and a.fields==nil then
a.fields=ba(bh,phase)end
return A.dp_raw(B,a)
end
local function bd(B,c,b)
local a=e(c,b,"threshold")if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=r.threshold_parser()end
if a.field==nil and a.fields==nil then
a.fields={threshold_1=true,threshold_1_protection=true,threshold_1_value=true,threshold_2=true,threshold_2_protection=true,threshold_2_value=true}end
return A.dp_raw(B,a)
end
local function am(m)
if d(m)=="number"and m%1==0 and m>=0 then
return{m}end
if d(m)~="table"then
return{}end
local aH={}for _,B in ipairs(m)do
if d(B)=="number"and B%1==0 and B>=0 then
M(aH,B)end
end
return aH
end
local function Z(b)
if d(b)~="table"then
return b
end
local m=b.dps
if m==nil then
m=b.dp_list
end
if m==nil and b[1]~=nil then
m=b
end
return m
end
local function ac(b)
local m=Z(b)if m~=nil then
return m
end
if d(b)~="table"then
return b
end
return b.dp
end
local function aI(x,b)
b=b or{}local aJ=b.phases
if d(aJ)~="table"then
aJ=b.phase_names
end
local phase=d(aJ)=="table"and aJ[x]or nil
if d(phase)=="string"and phase~=""then
return phase
end
local E=b.phase_prefix
if E==false then
return nil
end
if d(E)~="string"or E==""then
E=nil
end
if E~=nil then
return E..tostring(x)end
return tostring(x)
end
local function ag(x,b)
b=b or{}local K,I=b.first_is_main~=false,b.component_prefix

if d(I)~="string"or I==""then
I="switch"end
local P=b.main_component
if d(P)~="string"or P==""then
P="main"end
local q=b.index_offset
if d(q)~="number"or q%1~=0 then
q=0
end
if x==1 and K then
return P
end
local aB=K and(x-1+q)or(x+q)if aB<1 then
return b.default_component
end
return I..tostring(aB)
end
local function ax(x,b,aO)
b=b or{}local K,W=b.first_is_main~=false,b.key_prefix

if d(W)~="string"or W==""then
W=aO or"switch"end
local at=b.main_key
if d(at)~="string"or at==""then
at=W
end
local q=b.index_offset
if d(q)~="number"or q%1~=0 then
q=0
end
if x==1 and K then
return at
end
local aB=K and(x-1+q)or(x+q)if aB<1 then
return b.default_key
end
return W..tostring(aB)
end
local function R(h,B,w,b)
if d(B)~="number"or B%1~=0 or B<0 then
return
end
M(h,w(B,b))
end
local function aa(Y,bt)
if d(bt)~="table"then
return Y
end
for _,bv in ipairs(bt)do
M(Y,bv)end
return Y
end
local aj={"first_is_main","main_component","component_prefix","index_offset","default_component","key_prefix","main_key","default_key"}
local function aw(Q)
return d(Q)=="number"and Q%1==0 and Q>0
end
local function p(b,i)
local a={}if d(b)~="table"then
return a
end
for aq,Q in pairs(b)do
local aE=true
if not i then
if aq=="dp"or aq=="dps"or aq=="dp_list"then
aE=false
elseif aw(aq)then
aE=false
end
end
if aE then
a[aq]=Q
end
end
return a
end
local function ab(b)
if d(b)~="table"then
return false
end
if b.dp~=nil or b.dps~=nil or b.dp_list~=nil or b[1]~=nil then
return true
end
return false
end
local function F(b)
if d(b)~="table"then
return b
end
b.dp=nil
b.dps=nil
b.dp_list=nil
local x=1
while b[x]~=nil do
b[x]=nil
x=x+1
end
return b
end
local function t(b,n,i)
if d(b)~="table"then
return{}end
local s=b[n]if s==nil then
return p(b,i)end
local a=p(b,i)if d(s)=="table"then
j(a,s)else
a.dp=s
end
return a
end
local function u(s)
if s==nil then
return nil
end
if d(s)=="table"then
return s
end
return{dp=s}
end
local function U(b,n)
if d(b)~="table"then
return nil
end
return u(b[n])
end
local function au(as,f)
local L,D=d(as)=="table"and as.item_options or nil,d(f)=="table"and f.item_options or nil

if d(L)~="table"then
return d(D)=="table"and D or nil
end
if d(D)~="table"then
return L
end
local a={}j(a,L)j(a,D)return a
end
local function af(b,n,C,i)
local a={}local s
if d(b)=="table"then
bl(a,b,aj)s=b[n]if d(s)=="table"then
j(a,p(b,i))if i and ab(s)then
F(a)end
j(a,s)elseif s~=nil then
j(a,p(b,i))if i then
F(a)end
a.dp=s
else
j(a,p(b,i))end
end
if a.key_prefix==nil and C~=nil then
a.key_prefix=C
end
a.item_options=au(b,s)return a
end
local function N(b,l)
local k,ap={},U(b,"config")j(k,ap)local av=u(k[l])if av~=nil then
k[l]=av
else
local X=u(k.switch_type)if X==nil then
X=U(b,"switch_type")end
if d(X)=="table"then
k[l]=X
end
end
if l~="switch_type"then
k.switch_type=nil
end
if next(k)~=nil then
return k
end
return{}
end
local function O(b,l)
local a={}if d(b)=="table"then
j(a,b)end
local k=N(b,l)if next(k)~=nil then
a.config=k
end
a.switch_type=nil
return a
end
local function aU(b,l)
local a={}if d(b)=="table"then
j(a,b)end
local T=O(t(b,"switch_module"),l)if next(T)~=nil then
a.switch_module=T
end
return a
end
local function bk(h,b,n,w)
local f=t(b,n)R(h,f.dp,w,f)
end
local function aC(h,b,n,w,J)
local f=t(b,n)ao(f,J)R(h,f.dp,w,f)
end
local function aR(h,b,n,w,ay)
local f=t(b,n)local m=Z(f)if m~=nil and ay~=nil then
aa(h,ay(m,f))return
end
R(h,f.dp,w,f)
end
local function aK(h,b,n,C,w)
local f=af(b,n,C)aa(h,w(ac(f),f))
end
local function bf(m,w,g,b)
local h,ai,ah={},am(m),d(b)=="table"and b.item_options or nil
for x,B in ipairs(ai)do
local a=e(ah,nil,g)if a.component==nil then
a.component=ag(x,b)end
if a.key==nil and a.preference==nil then
a.key=ax(x,b,g)end
if a.field==nil and a.fields==nil and a.key~=nil then
a.field=a.key
end
M(h,w(B,a))end
return h
end
local function aM(m,w,b)
local h,ai,ah={},am(m),d(b)=="table"and b.item_options or nil
for x,B in ipairs(ai)do
local a=e(ah,nil,nil)if a.phase==nil then
a.phase=aI(x,b)end
M(h,w(B,a))end
return h
end
local function aL(b,n,w)
local f
if d(b)=="table"then
f=t(b,n,true)else
f={dp=b}end
local h={}R(h,f.dp,w,f)return h
end
function A.dp_on_off(B,c,b)
local a=e(c,b,"switch")if a.name=="switch"and a.emit==nil then
a.emit=br.switch()end
return A.dp_binary(B,a)
end
function A.dp_temperature(B,c,b)
return v(B,"temperature",10,c,b)
end
function A.dp_battery(B,c,b)
return v(B,"battery",1,c,b)
end
function A.dp_reverse_water_consumed(B,c,b)
return o(B,"reverse_water_consumed",1000,{bytes=4},c,b)
end
function A.dp_month_consumption(B,c,b)
return o(B,"month_consumption",1000,{bytes=4,from_tail=true},c,b)
end
function A.dp_daily_consumption(B,c,b)
return o(B,"daily_consumption",1000,{bytes=4,from_tail=true},c,b)
end
function A.dp_flow_rate(B,c,b)
return o(B,"flow_rate",1000,{bytes=4},c,b)
end
function A.dp_battery_voltage(B,c,b)
return v(B,"battery_voltage",100,c,b)
end
function A.dp_meter_id(B,c,b)
local a=e(c,b,"meter_id")if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=r.raw_identifier()end
return A.dp_raw(B,a)
end
function A.dp_water_meter_faults(B,c,b)
local a=e(c,b,"faults")if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=r.water_meter_faults()end
return A.dp_numeric(B,a)
end
end
return ar
