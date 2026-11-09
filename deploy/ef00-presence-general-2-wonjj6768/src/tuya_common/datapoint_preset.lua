local function ar(p,aA,br)
br=br or{switch=function()return nil end}
local d,M,aR,k,bl,q=aA.type_check,aA.table_insert,aA.tonumber_check,aA.merge_options,aA.copy_keys,p.converter





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
local function e(c,b,h)
local a={}if d(c)=="string"then
a.name=c
else
k(a,c)end
k(a,b)if a.name==nil and h~=nil then
a.name=h
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
return p.apply_fixed_send_policy(bg)
end
local function g(t,h,z,c,b)
local a=e(c,b,h)local A=a.scale
if A==nil then
A=z
end
if a.converter==nil and a.from_device==nil and a.to_device==nil and A~=1 then
a.converter=q.divide_by_pair(A)end
a.scale=nil
return p.dp_numeric(t,a)
end
local function aV(t,h,z,c,b)
local a=e(c,b,h)local A=a.scale
if A==nil then
A=z
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
local an=q.power()local be=an.from
if A~=1 then
a.from_device=q.pipe(be,q.divide_by(A))else
a.converter=an
end
end
a.scale=nil
return p.dp_numeric(t,a)
end
local function E(t,h,z,c,b)
local a=e(c,b,h)local A=a.scale
if A==nil then
A=z
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=q.signed_number_pair(A)end
if a.signed==nil then
a.signed=true
end
a.scale=nil
return p.dp_numeric(t,a)
end
local function aG(t,h,z,bb,c,b)
local a=e(c,b,h)local A=a.scale
if A==nil then
A=z
end
local bq=
a.datatype==p.DP_TYPE_RAW or
a.raw==true or
a.raw_bytes~=nil or
a.raw_length~=nil or
a.raw_from_tail~=nil or
a.raw_start~=nil or
a.raw_offset~=nil
if bq and a.converter==nil and a.from_device==nil and a.to_device==nil then
local aD={bytes=a.raw_bytes or a.raw_length,length=a.raw_length,from_tail=a.raw_from_tail,start=a.raw_start,offset=a.raw_offset}ao(aD,bb)a.converter=q.raw_uint_be(A,aD)if a.datatype==nil then
a.datatype=p.DP_TYPE_RAW
end
elseif a.converter==nil and a.from_device==nil and a.to_device==nil and A~=1 then
a.converter=q.divide_by_pair(A)end
a.scale=nil
a.raw=nil
a.raw_bytes=nil
a.raw_length=nil
a.raw_from_tail=nil
a.raw_start=nil
a.raw_offset=nil
return p.dp_numeric(t,a)
end
local function V(Q,bo,bn)
local az=aR(Q)if az==nil then
return nil
end
return bo+bn-az
end
local function aT(t,h,J,c,b)
local a=e(c,b,h)local ae=a.raw_min
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
local bi,bs=q.scale(ae,ad,H,G),q.scale(H,G,ae,ad)a.converter=q.from_to(
function(Q,aX,aO)
local bp=bi(Q,aX,aO)if bp==nil then
return nil
end
return V(bp,H,G)
end,
function(Q,aX,aO)
local aZ=V(Q,H,G)if aZ==nil then
return nil
end
return bs(aZ,aX,aO)
end
)elseif ae~=H or ad~=G then
a.converter=q.scale_pair(ae,ad,H,G)end
end
a.raw_min=nil
a.raw_max=nil
a.value_min=nil
a.value_max=nil
a.invert=nil
a.invert_position=nil
return p.dp_numeric(t,a)
end
local function bj(phase,aY)
if d(phase)=="string"and phase~=""then
return(aY or"phase").."_"..phase
end
return aY or"phase"
end
local function ba(bw,phase)
local bm={}for _,aq in ipairs(bw or{})do
local aH=aq
if d(phase)=="string"and phase~=""then
aH=aq.."_"..phase
end
bm[aH]=true
end
return bm
end
local function bc(t,h,aQ,bh,c,b)
local aW=
d(c)=="string"or
(d(c)=="table"and c.name~=nil)or
(d(b)=="table"and b.name~=nil)local a=e(c,b,h)local phase=a.phase
if not aW and a.name==h then
a.name=bj(phase,h)end
if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=aQ(a)end
if a.field==nil and a.fields==nil then
a.fields=ba(bh,phase)end
return p.dp_raw(t,a)
end
local function bd(t,c,b)
local a=e(c,b,"threshold")if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=q.threshold_parser()end
if a.field==nil and a.fields==nil then
a.fields={threshold_1=true,threshold_1_protection=true,threshold_1_value=true,threshold_2=true,threshold_2_protection=true,threshold_2_value=true}end
return p.dp_raw(t,a)
end
local function am(n)
if d(n)=="number"and n%1==0 and n>=0 then
return{n}end
if d(n)~="table"then
return{}end
local aI={}for _,t in ipairs(n)do
if d(t)=="number"and t%1==0 and t>=0 then
M(aI,t)end
end
return aI
end
local function Z(b)
if d(b)~="table"then
return b
end
local n=b.dps
if n==nil then
n=b.dp_list
end
if n==nil and b[1]~=nil then
n=b
end
return n
end
local function ac(b)
local n=Z(b)if n~=nil then
return n
end
if d(b)~="table"then
return b
end
return b.dp
end
local function aJ(y,b)
b=b or{}local aK=b.phases
if d(aK)~="table"then
aK=b.phase_names
end
local phase=d(aK)=="table"and aK[y]or nil
if d(phase)=="string"and phase~=""then
return phase
end
local D=b.phase_prefix
if D==false then
return nil
end
if d(D)~="string"or D==""then
D=nil
end
if D~=nil then
return D..tostring(y)end
return tostring(y)
end
local function ag(y,b)
b=b or{}local K,I=b.first_is_main~=false,b.component_prefix

if d(I)~="string"or I==""then
I="switch"end
local P=b.main_component
if d(P)~="string"or P==""then
P="main"end
local s=b.index_offset
if d(s)~="number"or s%1~=0 then
s=0
end
if y==1 and K then
return P
end
local aB=K and(y-1+s)or(y+s)if aB<1 then
return b.default_component
end
return I..tostring(aB)
end
local function ax(y,b,aP)
b=b or{}local K,W=b.first_is_main~=false,b.key_prefix

if d(W)~="string"or W==""then
W=aP or"switch"end
local at=b.main_key
if d(at)~="string"or at==""then
at=W
end
local s=b.index_offset
if d(s)~="number"or s%1~=0 then
s=0
end
if y==1 and K then
return at
end
local aB=K and(y-1+s)or(y+s)if aB<1 then
return b.default_key
end
return W..tostring(aB)
end
local function R(i,t,x,b)
if d(t)~="number"or t%1~=0 or t<0 then
return
end
M(i,x(t,b))
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
local function r(b,j)
local a={}if d(b)~="table"then
return a
end
for aq,Q in pairs(b)do
local aE=true
if not j then
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
local y=1
while b[y]~=nil do
b[y]=nil
y=y+1
end
return b
end
local function v(b,o,j)
if d(b)~="table"then
return{}end
local u=b[o]if u==nil then
return r(b,j)end
local a=r(b,j)if d(u)=="table"then
k(a,u)else
a.dp=u
end
return a
end
local function w(u)
if u==nil then
return nil
end
if d(u)=="table"then
return u
end
return{dp=u}
end
local function U(b,o)
if d(b)~="table"then
return nil
end
return w(b[o])
end
local function au(as,f)
local L,C=d(as)=="table"and as.item_options or nil,d(f)=="table"and f.item_options or nil

if d(L)~="table"then
return d(C)=="table"and C or nil
end
if d(C)~="table"then
return L
end
local a={}k(a,L)k(a,C)return a
end
local function af(b,o,B,j)
local a={}local u
if d(b)=="table"then
bl(a,b,aj)u=b[o]if d(u)=="table"then
k(a,r(b,j))if j and ab(u)then
F(a)end
k(a,u)elseif u~=nil then
k(a,r(b,j))if j then
F(a)end
a.dp=u
else
k(a,r(b,j))end
end
if a.key_prefix==nil and B~=nil then
a.key_prefix=B
end
a.item_options=au(b,u)return a
end
local function N(b,m)
local l,ap={},U(b,"config")k(l,ap)local av=w(l[m])if av~=nil then
l[m]=av
else
local X=w(l.switch_type)if X==nil then
X=U(b,"switch_type")end
if d(X)=="table"then
l[m]=X
end
end
if m~="switch_type"then
l.switch_type=nil
end
if next(l)~=nil then
return l
end
return{}
end
local function O(b,m)
local a={}if d(b)=="table"then
k(a,b)end
local l=N(b,m)if next(l)~=nil then
a.config=l
end
a.switch_type=nil
return a
end
local function aU(b,m)
local a={}if d(b)=="table"then
k(a,b)end
local T=O(v(b,"switch_module"),m)if next(T)~=nil then
a.switch_module=T
end
return a
end
local function bk(i,b,o,x)
local f=v(b,o)R(i,f.dp,x,f)
end
local function aC(i,b,o,x,J)
local f=v(b,o)ao(f,J)R(i,f.dp,x,f)
end
local function aS(i,b,o,x,ay)
local f=v(b,o)local n=Z(f)if n~=nil and ay~=nil then
aa(i,ay(n,f))return
end
R(i,f.dp,x,f)
end
local function aL(i,b,o,B,x)
local f=af(b,o,B)aa(i,x(ac(f),f))
end
local function bf(n,x,h,b)
local i,ai,ah={},am(n),d(b)=="table"and b.item_options or nil
for y,t in ipairs(ai)do
local a=e(ah,nil,h)if a.component==nil then
a.component=ag(y,b)end
if a.key==nil and a.preference==nil then
a.key=ax(y,b,h)end
if a.field==nil and a.fields==nil and a.key~=nil then
a.field=a.key
end
M(i,x(t,a))end
return i
end
local function aN(n,x,b)
local i,ai,ah={},am(n),d(b)=="table"and b.item_options or nil
for y,t in ipairs(ai)do
local a=e(ah,nil,nil)if a.phase==nil then
a.phase=aJ(y,b)end
M(i,x(t,a))end
return i
end
local function aM(b,o,x)
local f
if d(b)=="table"then
f=v(b,o,true)else
f={dp=b}end
local i={}R(i,f.dp,x,f)return i
end
function p.dp_on_off(t,c,b)
local a=e(c,b,"switch")if a.name=="switch"and a.emit==nil then
a.emit=br.switch()end
return p.dp_binary(t,a)
end
function p.dp_temperature(t,c,b)
return g(t,"temperature",10,c,b)
end
function p.dp_humidity(t,c,b)
return g(t,"humidity",10,c,b)
end
function p.dp_battery(t,c,b)
return g(t,"battery",1,c,b)
end
function p.dp_occupancy(t,c,b)
local a=e(c,b,"occupancy")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=q.true_false0()end
return p.dp_binary(t,a)
end
function p.dp_illuminance(t,c,b)
local a=e(c,b,"illuminance")return p.dp_numeric(t,a)
end
function p.dp_temperature_unit(t,c,b)
local a=e(c,b,"temperature_unit")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=q.temperature_unit()end
return p.dp_enum(t,a)
end
function p.dp_temperature_calibration(t,c,b)
return E(t,"temperature_calibration",10,c,b)
end
function p.dp_humidity_calibration(t,c,b)
return E(t,"humidity_calibration",1,c,b)
end
function p.dp_presence(t,c,b)
return p.dp_binary(t,e(c,b,"presence"))
end
function p.dp_motion_state(t,c,b)
local a=e(c,b,"motion_state")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=q.motion_state()end
return p.dp_enum(t,a)
end
function p.dp_indicator(t,c,b)
return p.dp_binary(t,e(c,b,"indicator"))
end
function p.dp_fading_time(t,c,b)
return g(t,"fading_time",1,c,b)
end
function p.dp_illuminance_interval(t,c,b)
return g(t,"illuminance_interval",1,c,b)
end
function p.dp_static_detection_distance(t,c,b)
return g(t,"static_detection_distance",100,c,b)
end
function p.dp_static_detection_sensitivity(t,c,b)
return g(t,"static_detection_sensitivity",1,c,b)
end
function p.dp_motion_detection_mode(t,c,b)
local a=e(c,b,"motion_detection_mode")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=q.motion_detection_mode()end
return p.dp_enum(t,a)
end
function p.dp_motion_detection_sensitivity(t,c,b)
return g(t,"motion_detection_sensitivity",1,c,b)
end
function p.dp_target_distance(t,c,b)
return g(t,"target_distance",100,c,b)
end
end
return ar
