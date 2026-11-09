local function as(i,aB,br)
br=br or{switch=function()return nil end}
local e,M,aR,l,bl,s=aB.type_check,aB.table_insert,aB.tonumber_check,aB.merge_options,aB.copy_keys,i.converter





local function ap(Y,J)
if e(Y)~="table"or e(J)~="table"then
return Y
end
for ar,Q in pairs(J)do
if Y[ar]==nil then
Y[ar]=Q
end
end
return Y
end
local function d(c,b,h)
local a={}if e(c)=="string"then
a.name=c
else
l(a,c)end
l(a,b)if a.name==nil and h~=nil then
a.name=h
end
return a
end
local am={"send_policy","command_id","transaction","batch_key","match_transaction","response_dp","response_dps","match_response"}
local function al(b)
if e(b)~="table"then
return false
end
for _,ar in ipairs(am)do
if b[ar]~=nil then
return true
end
end
return false
end
local function B(bg,b)
if al(b)then
return bg
end
return i.apply_fixed_send_policy(bg)
end
local function f(n,h,z,c,b)
local a=d(c,b,h)local A=a.scale
if A==nil then
A=z
end
if a.converter==nil and a.from_device==nil and a.to_device==nil and A~=1 then
a.converter=s.divide_by_pair(A)end
a.scale=nil
return i.dp_numeric(n,a)
end
local function aV(n,h,z,c,b)
local a=d(c,b,h)local A=a.scale
if A==nil then
A=z
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
local ao=s.power()local be=ao.from
if A~=1 then
a.from_device=s.pipe(be,s.divide_by(A))else
a.converter=ao
end
end
a.scale=nil
return i.dp_numeric(n,a)
end
local function ab(n,h,z,c,b)
local a=d(c,b,h)local A=a.scale
if A==nil then
A=z
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=s.signed_number_pair(A)end
if a.signed==nil then
a.signed=true
end
a.scale=nil
return i.dp_numeric(n,a)
end
local function aG(n,h,z,bb,c,b)
local a=d(c,b,h)local A=a.scale
if A==nil then
A=z
end
local bq=
a.datatype==i.DP_TYPE_RAW or
a.raw==true or
a.raw_bytes~=nil or
a.raw_length~=nil or
a.raw_from_tail~=nil or
a.raw_start~=nil or
a.raw_offset~=nil
if bq and a.converter==nil and a.from_device==nil and a.to_device==nil then
local aE={bytes=a.raw_bytes or a.raw_length,length=a.raw_length,from_tail=a.raw_from_tail,start=a.raw_start,offset=a.raw_offset}ap(aE,bb)a.converter=s.raw_uint_be(A,aE)if a.datatype==nil then
a.datatype=i.DP_TYPE_RAW
end
elseif a.converter==nil and a.from_device==nil and a.to_device==nil and A~=1 then
a.converter=s.divide_by_pair(A)end
a.scale=nil
a.raw=nil
a.raw_bytes=nil
a.raw_length=nil
a.raw_from_tail=nil
a.raw_start=nil
a.raw_offset=nil
return i.dp_numeric(n,a)
end
local function V(Q,bo,bn)
local aA=aR(Q)if aA==nil then
return nil
end
return bo+bn-aA
end
local function aT(n,h,J,c,b)
local a=d(c,b,h)local af=a.raw_min
if af==nil then
af=J.raw_min
end
local ae=a.raw_max
if ae==nil then
ae=J.raw_max
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
local bi,bs=s.scale(af,ae,H,G),s.scale(H,G,af,ae)a.converter=s.from_to(
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
)elseif af~=H or ae~=G then
a.converter=s.scale_pair(af,ae,H,G)end
end
a.raw_min=nil
a.raw_max=nil
a.value_min=nil
a.value_max=nil
a.invert=nil
a.invert_position=nil
return i.dp_numeric(n,a)
end
local function bj(phase,aY)
if e(phase)=="string"and phase~=""then
return(aY or"phase").."_"..phase
end
return aY or"phase"
end
local function ba(bw,phase)
local bm={}for _,ar in ipairs(bw or{})do
local aH=ar
if e(phase)=="string"and phase~=""then
aH=ar.."_"..phase
end
bm[aH]=true
end
return bm
end
local function bc(n,h,aQ,bh,c,b)
local aW=
e(c)=="string"or
(e(c)=="table"and c.name~=nil)or
(e(b)=="table"and b.name~=nil)local a=d(c,b,h)local phase=a.phase
if not aW and a.name==h then
a.name=bj(phase,h)end
if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=aQ(a)end
if a.field==nil and a.fields==nil then
a.fields=ba(bh,phase)end
return i.dp_raw(n,a)
end
local function bd(n,c,b)
local a=d(c,b,"threshold")if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=s.threshold_parser()end
if a.field==nil and a.fields==nil then
a.fields={threshold_1=true,threshold_1_protection=true,threshold_1_value=true,threshold_2=true,threshold_2_protection=true,threshold_2_value=true}end
return i.dp_raw(n,a)
end
local function an(p)
if e(p)=="number"and p%1==0 and p>=0 then
return{p}end
if e(p)~="table"then
return{}end
local aI={}for _,n in ipairs(p)do
if e(n)=="number"and n%1==0 and n>=0 then
M(aI,n)end
end
return aI
end
local function Z(b)
if e(b)~="table"then
return b
end
local p=b.dps
if p==nil then
p=b.dp_list
end
if p==nil and b[1]~=nil then
p=b
end
return p
end
local function ad(b)
local p=Z(b)if p~=nil then
return p
end
if e(b)~="table"then
return b
end
return b.dp
end
local function aJ(y,b)
b=b or{}local aK=b.phases
if e(aK)~="table"then
aK=b.phase_names
end
local phase=e(aK)=="table"and aK[y]or nil
if e(phase)=="string"and phase~=""then
return phase
end
local E=b.phase_prefix
if E==false then
return nil
end
if e(E)~="string"or E==""then
E=nil
end
if E~=nil then
return E..tostring(y)end
return tostring(y)
end
local function ah(y,b)
b=b or{}local K,I=b.first_is_main~=false,b.component_prefix

if e(I)~="string"or I==""then
I="switch"end
local P=b.main_component
if e(P)~="string"or P==""then
P="main"end
local t=b.index_offset
if e(t)~="number"or t%1~=0 then
t=0
end
if y==1 and K then
return P
end
local aC=K and(y-1+t)or(y+t)if aC<1 then
return b.default_component
end
return I..tostring(aC)
end
local function ay(y,b,aP)
b=b or{}local K,W=b.first_is_main~=false,b.key_prefix

if e(W)~="string"or W==""then
W=aP or"switch"end
local au=b.main_key
if e(au)~="string"or au==""then
au=W
end
local t=b.index_offset
if e(t)~="number"or t%1~=0 then
t=0
end
if y==1 and K then
return au
end
local aC=K and(y-1+t)or(y+t)if aC<1 then
return b.default_key
end
return W..tostring(aC)
end
local function R(j,n,x,b)
if e(n)~="number"or n%1~=0 or n<0 then
return
end
M(j,x(n,b))
end
local function aa(Y,bt)
if e(bt)~="table"then
return Y
end
for _,bv in ipairs(bt)do
M(Y,bv)end
return Y
end
local ak={"first_is_main","main_component","component_prefix","index_offset","default_component","key_prefix","main_key","default_key"}
local function ax(Q)
return e(Q)=="number"and Q%1==0 and Q>0
end
local function r(b,k)
local a={}if e(b)~="table"then
return a
end
for ar,Q in pairs(b)do
local aF=true
if not k then
if ar=="dp"or ar=="dps"or ar=="dp_list"then
aF=false
elseif ax(ar)then
aF=false
end
end
if aF then
a[ar]=Q
end
end
return a
end
local function ac(b)
if e(b)~="table"then
return false
end
if b.dp~=nil or b.dps~=nil or b.dp_list~=nil or b[1]~=nil then
return true
end
return false
end
local function F(b)
if e(b)~="table"then
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
local function v(b,q,k)
if e(b)~="table"then
return{}end
local u=b[q]if u==nil then
return r(b,k)end
local a=r(b,k)if e(u)=="table"then
l(a,u)else
a.dp=u
end
return a
end
local function w(u)
if u==nil then
return nil
end
if e(u)=="table"then
return u
end
return{dp=u}
end
local function U(b,q)
if e(b)~="table"then
return nil
end
return w(b[q])
end
local function av(at,g)
local L,D=e(at)=="table"and at.item_options or nil,e(g)=="table"and g.item_options or nil

if e(L)~="table"then
return e(D)=="table"and D or nil
end
if e(D)~="table"then
return L
end
local a={}l(a,L)l(a,D)return a
end
local function ag(b,q,C,k)
local a={}local u
if e(b)=="table"then
bl(a,b,ak)u=b[q]if e(u)=="table"then
l(a,r(b,k))if k and ac(u)then
F(a)end
l(a,u)elseif u~=nil then
l(a,r(b,k))if k then
F(a)end
a.dp=u
else
l(a,r(b,k))end
end
if a.key_prefix==nil and C~=nil then
a.key_prefix=C
end
a.item_options=av(b,u)return a
end
local function N(b,o)
local m,aq={},U(b,"config")l(m,aq)local aw=w(m[o])if aw~=nil then
m[o]=aw
else
local X=w(m.switch_type)if X==nil then
X=U(b,"switch_type")end
if e(X)=="table"then
m[o]=X
end
end
if o~="switch_type"then
m.switch_type=nil
end
if next(m)~=nil then
return m
end
return{}
end
local function O(b,o)
local a={}if e(b)=="table"then
l(a,b)end
local m=N(b,o)if next(m)~=nil then
a.config=m
end
a.switch_type=nil
return a
end
local function aU(b,o)
local a={}if e(b)=="table"then
l(a,b)end
local T=O(v(b,"switch_module"),o)if next(T)~=nil then
a.switch_module=T
end
return a
end
local function bk(j,b,q,x)
local g=v(b,q)R(j,g.dp,x,g)
end
local function aD(j,b,q,x,J)
local g=v(b,q)ap(g,J)R(j,g.dp,x,g)
end
local function aS(j,b,q,x,az)
local g=v(b,q)local p=Z(g)if p~=nil and az~=nil then
aa(j,az(p,g))return
end
R(j,g.dp,x,g)
end
local function aL(j,b,q,C,x)
local g=ag(b,q,C)aa(j,x(ad(g),g))
end
local function bf(p,x,h,b)
local j,aj,ai={},an(p),e(b)=="table"and b.item_options or nil
for y,n in ipairs(aj)do
local a=d(ai,nil,h)if a.component==nil then
a.component=ah(y,b)end
if a.key==nil and a.preference==nil then
a.key=ay(y,b,h)end
if a.field==nil and a.fields==nil and a.key~=nil then
a.field=a.key
end
M(j,x(n,a))end
return j
end
local function aN(p,x,b)
local j,aj,ai={},an(p),e(b)=="table"and b.item_options or nil
for y,n in ipairs(aj)do
local a=d(ai,nil,nil)if a.phase==nil then
a.phase=aJ(y,b)end
M(j,x(n,a))end
return j
end
local function aM(b,q,x)
local g
if e(b)=="table"then
g=v(b,q,true)else
g={dp=b}end
local j={}R(j,g.dp,x,g)return j
end
function i.dp_on_off(n,c,b)
local a=d(c,b,"switch")if a.name=="switch"and a.emit==nil then
a.emit=br.switch()end
return i.dp_binary(n,a)
end
function i.dp_temperature(n,c,b)
return f(n,"temperature",10,c,b)
end
function i.dp_battery(n,c,b)
return f(n,"battery",1,c,b)
end
function i.dp_child_lock(n,c,b)
return i.dp_binary(n,d(c,b,"child_lock"))
end
function i.dp_local_temperature(n,c,b)
return f(n,"local_temperature",10,c,b)
end
function i.dp_current_heating_setpoint(n,c,b)
return f(n,"current_heating_setpoint",10,c,b)
end
function i.dp_local_temperature_calibration(n,c,b)
return ab(n,"local_temperature_calibration",10,c,b)
end
function i.dp_open_window_temperature(n,c,b)
return f(n,"open_window_temperature",10,c,b)
end
function i.dp_comfort_temperature(n,c,b)
return f(n,"comfort_temperature",10,c,b)
end
function i.dp_eco_temperature(n,c,b)
return f(n,"eco_temperature",10,c,b)
end
function i.dp_holiday_temperature(n,c,b)
return f(n,"holiday_temperature",10,c,b)
end
function i.dp_max_temperature_limit(n,c,b)
return f(n,"max_temperature_limit",10,c,b)
end
function i.dp_min_temperature_limit(n,c,b)
return f(n,"min_temperature_limit",10,c,b)
end
function i.dp_deadzone_temperature(n,c,b)
return f(n,"deadzone_temperature",1,c,b)
end
function i.dp_open_window_time(n,c,b)
return f(n,"open_window_time",1,c,b)
end
function i.dp_system_mode(n,c,b)
return i.dp_enum(n,d(c,b,"system_mode"))
end
function i.dp_running_state(n,c,b)
return i.dp_enum(n,d(c,b,"running_state"))
end
function i.dp_frost_protection(n,c,b)
return i.dp_binary(n,d(c,b,"frost_protection"))
end
function i.dp_window_detection(n,c,b)
return i.dp_binary(n,d(c,b,"window_detection"))
end
function i.dp_open_window(n,c,b)
return i.dp_binary(n,d(c,b,"open_window"))
end
function i.dp_window_open(n,c,b)
return i.dp_binary(n,d(c,b,"window_open"))
end
function i.dp_boost_heating(n,c,b)
return i.dp_binary(n,d(c,b,"boost_heating"))
end
function i.dp_scale_protection(n,c,b)
return i.dp_binary(n,d(c,b,"scale_protection"))
end
function i.dp_eco_mode(n,c,b)
return i.dp_binary(n,d(c,b,"eco_mode"))
end
function i.dp_valve_state(n,c,b)
local a=d(c,b,"valve_state")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=s.valve_state_closed_open()end
return i.dp_enum(n,a)
end
function i.dp_temperature_sensor_select(n,c,b)
local a=d(c,b,"temperature_sensor_select")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=s.temperature_sensor_select_in_al_ou()end
return B(i.dp_enum(n,a),a)
end
function i.dp_temperature_sensor_select_internal_external_both(n,c,b)
local a=d(c,b,"temperature_sensor_select")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=s.temperature_sensor_select_internal_external_both()end
return B(i.dp_enum(n,a),a)
end
function i.dp_boost_time(n,c,b)
return f(n,"boost_time",1,c,b)
end
end
return as
