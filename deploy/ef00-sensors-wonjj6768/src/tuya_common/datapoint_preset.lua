local function as(h,aB,bt)
bt=bt or{switch=function()return nil end}
local e,N,aR,o,bl,n=aB.type_check,aB.table_insert,aB.tonumber_check,aB.merge_options,aB.copy_keys,h.converter





local function ap(Z,K)
if e(Z)~="table"or e(K)~="table"then
return Z
end
for ar,R in pairs(K)do
if Z[ar]==nil then
Z[ar]=R
end
end
return Z
end
local function f(b,c,j)
local a={}if e(b)=="string"then
a.name=b
else
o(a,b)end
o(a,c)if a.name==nil and j~=nil then
a.name=j
end
return a
end
local am={"send_policy","command_id","transaction","batch_key","match_transaction","response_dp","response_dps","match_response"}
local function al(c)
if e(c)~="table"then
return false
end
for _,ar in ipairs(am)do
if c[ar]~=nil then
return true
end
end
return false
end
local function aG(bg,c)
if al(c)then
return bg
end
return h.apply_fixed_send_policy(bg)
end
local function d(k,j,B,b,c)
local a=f(b,c,j)local C=a.scale
if C==nil then
C=B
end
if a.converter==nil and a.from_device==nil and a.to_device==nil and C~=1 then
a.converter=n.divide_by_pair(C)end
a.scale=nil
return h.dp_numeric(k,a)
end
local function aV(k,j,B,b,c)
local a=f(b,c,j)local C=a.scale
if C==nil then
C=B
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
local ao=n.power()local be=ao.from
if C~=1 then
a.from_device=n.pipe(be,n.divide_by(C))else
a.converter=ao
end
end
a.scale=nil
return h.dp_numeric(k,a)
end
local function q(k,j,B,b,c)
local a=f(b,c,j)local C=a.scale
if C==nil then
C=B
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=n.signed_number_pair(C)end
if a.signed==nil then
a.signed=true
end
a.scale=nil
return h.dp_numeric(k,a)
end
local function i(k,j,B,bb,b,c)
local a=f(b,c,j)local C=a.scale
if C==nil then
C=B
end
local bq=
a.datatype==h.DP_TYPE_RAW or
a.raw==true or
a.raw_bytes~=nil or
a.raw_length~=nil or
a.raw_from_tail~=nil or
a.raw_start~=nil or
a.raw_offset~=nil
if bq and a.converter==nil and a.from_device==nil and a.to_device==nil then
local aE={bytes=a.raw_bytes or a.raw_length,length=a.raw_length,from_tail=a.raw_from_tail,start=a.raw_start,offset=a.raw_offset}ap(aE,bb)a.converter=n.raw_uint_be(C,aE)if a.datatype==nil then
a.datatype=h.DP_TYPE_RAW
end
elseif a.converter==nil and a.from_device==nil and a.to_device==nil and C~=1 then
a.converter=n.divide_by_pair(C)end
a.scale=nil
a.raw=nil
a.raw_bytes=nil
a.raw_length=nil
a.raw_from_tail=nil
a.raw_start=nil
a.raw_offset=nil
return h.dp_numeric(k,a)
end
local function W(R,bo,bn)
local aA=aR(R)if aA==nil then
return nil
end
return bo+bn-aA
end
local function aT(k,j,K,b,c)
local a=f(b,c,j)local af=a.raw_min
if af==nil then
af=K.raw_min
end
local ae=a.raw_max
if ae==nil then
ae=K.raw_max
end
local I=a.value_min
if I==nil then
I=K.value_min
end
local H=a.value_max
if H==nil then
H=K.value_max
end
local bu=a.invert==true or a.invert_position==true
if a.converter==nil and a.from_device==nil and a.to_device==nil then
if bu then
local bi,br=n.scale(af,ae,I,H),n.scale(I,H,af,ae)a.converter=n.from_to(
function(R,aX,aO)
local bp=bi(R,aX,aO)if bp==nil then
return nil
end
return W(bp,I,H)
end,
function(R,aX,aO)
local aZ=W(R,I,H)if aZ==nil then
return nil
end
return br(aZ,aX,aO)
end
)elseif af~=I or ae~=H then
a.converter=n.scale_pair(af,ae,I,H)end
end
a.raw_min=nil
a.raw_max=nil
a.value_min=nil
a.value_max=nil
a.invert=nil
a.invert_position=nil
return h.dp_numeric(k,a)
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
local function bc(k,j,aQ,bh,b,c)
local aW=
e(b)=="string"or
(e(b)=="table"and b.name~=nil)or
(e(c)=="table"and c.name~=nil)local a=f(b,c,j)local phase=a.phase
if not aW and a.name==j then
a.name=bj(phase,j)end
if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=aQ(a)end
if a.field==nil and a.fields==nil then
a.fields=ba(bh,phase)end
return h.dp_raw(k,a)
end
local function bd(k,b,c)
local a=f(b,c,"threshold")if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=n.threshold_parser()end
if a.field==nil and a.fields==nil then
a.fields={threshold_1=true,threshold_1_protection=true,threshold_1_value=true,threshold_2=true,threshold_2_protection=true,threshold_2_value=true}end
return h.dp_raw(k,a)
end
local function an(s)
if e(s)=="number"and s%1==0 and s>=0 then
return{s}end
if e(s)~="table"then
return{}end
local aI={}for _,k in ipairs(s)do
if e(k)=="number"and k%1==0 and k>=0 then
N(aI,k)end
end
return aI
end
local function aa(c)
if e(c)~="table"then
return c
end
local s=c.dps
if s==nil then
s=c.dp_list
end
if s==nil and c[1]~=nil then
s=c
end
return s
end
local function ad(c)
local s=aa(c)if s~=nil then
return s
end
if e(c)~="table"then
return c
end
return c.dp
end
local function aJ(A,c)
c=c or{}local aK=c.phases
if e(aK)~="table"then
aK=c.phase_names
end
local phase=e(aK)=="table"and aK[A]or nil
if e(phase)=="string"and phase~=""then
return phase
end
local F=c.phase_prefix
if F==false then
return nil
end
if e(F)~="string"or F==""then
F=nil
end
if F~=nil then
return F..tostring(A)end
return tostring(A)
end
local function ah(A,c)
c=c or{}local L,J=c.first_is_main~=false,c.component_prefix

if e(J)~="string"or J==""then
J="switch"end
local Q=c.main_component
if e(Q)~="string"or Q==""then
Q="main"end
local v=c.index_offset
if e(v)~="number"or v%1~=0 then
v=0
end
if A==1 and L then
return Q
end
local aC=L and(A-1+v)or(A+v)if aC<1 then
return c.default_component
end
return J..tostring(aC)
end
local function ay(A,c,aP)
c=c or{}local L,X=c.first_is_main~=false,c.key_prefix

if e(X)~="string"or X==""then
X=aP or"switch"end
local au=c.main_key
if e(au)~="string"or au==""then
au=X
end
local v=c.index_offset
if e(v)~="number"or v%1~=0 then
v=0
end
if A==1 and L then
return au
end
local aC=L and(A-1+v)or(A+v)if aC<1 then
return c.default_key
end
return X..tostring(aC)
end
local function S(l,k,z,c)
if e(k)~="number"or k%1~=0 or k<0 then
return
end
N(l,z(k,c))
end
local function ab(Z,bs)
if e(bs)~="table"then
return Z
end
for _,bv in ipairs(bs)do
N(Z,bv)end
return Z
end
local ak={"first_is_main","main_component","component_prefix","index_offset","default_component","key_prefix","main_key","default_key"}
local function ax(R)
return e(R)=="number"and R%1==0 and R>0
end
local function u(c,m)
local a={}if e(c)~="table"then
return a
end
for ar,R in pairs(c)do
local aF=true
if not m then
if ar=="dp"or ar=="dps"or ar=="dp_list"then
aF=false
elseif ax(ar)then
aF=false
end
end
if aF then
a[ar]=R
end
end
return a
end
local function ac(c)
if e(c)~="table"then
return false
end
if c.dp~=nil or c.dps~=nil or c.dp_list~=nil or c[1]~=nil then
return true
end
return false
end
local function G(c)
if e(c)~="table"then
return c
end
c.dp=nil
c.dps=nil
c.dp_list=nil
local A=1
while c[A]~=nil do
c[A]=nil
A=A+1
end
return c
end
local function x(c,t,m)
if e(c)~="table"then
return{}end
local w=c[t]if w==nil then
return u(c,m)end
local a=u(c,m)if e(w)=="table"then
o(a,w)else
a.dp=w
end
return a
end
local function y(w)
if w==nil then
return nil
end
if e(w)=="table"then
return w
end
return{dp=w}
end
local function V(c,t)
if e(c)~="table"then
return nil
end
return y(c[t])
end
local function av(at,g)
local M,E=e(at)=="table"and at.item_options or nil,e(g)=="table"and g.item_options or nil

if e(M)~="table"then
return e(E)=="table"and E or nil
end
if e(E)~="table"then
return M
end
local a={}o(a,M)o(a,E)return a
end
local function ag(c,t,D,m)
local a={}local w
if e(c)=="table"then
bl(a,c,ak)w=c[t]if e(w)=="table"then
o(a,u(c,m))if m and ac(w)then
G(a)end
o(a,w)elseif w~=nil then
o(a,u(c,m))if m then
G(a)end
a.dp=w
else
o(a,u(c,m))end
end
if a.key_prefix==nil and D~=nil then
a.key_prefix=D
end
a.item_options=av(c,w)return a
end
local function O(c,r)
local p,aq={},V(c,"config")o(p,aq)local aw=y(p[r])if aw~=nil then
p[r]=aw
else
local Y=y(p.switch_type)if Y==nil then
Y=V(c,"switch_type")end
if e(Y)=="table"then
p[r]=Y
end
end
if r~="switch_type"then
p.switch_type=nil
end
if next(p)~=nil then
return p
end
return{}
end
local function P(c,r)
local a={}if e(c)=="table"then
o(a,c)end
local p=O(c,r)if next(p)~=nil then
a.config=p
end
a.switch_type=nil
return a
end
local function aU(c,r)
local a={}if e(c)=="table"then
o(a,c)end
local U=P(x(c,"switch_module"),r)if next(U)~=nil then
a.switch_module=U
end
return a
end
local function bk(l,c,t,z)
local g=x(c,t)S(l,g.dp,z,g)
end
local function aD(l,c,t,z,K)
local g=x(c,t)ap(g,K)S(l,g.dp,z,g)
end
local function aS(l,c,t,z,az)
local g=x(c,t)local s=aa(g)if s~=nil and az~=nil then
ab(l,az(s,g))return
end
S(l,g.dp,z,g)
end
local function aL(l,c,t,D,z)
local g=ag(c,t,D)ab(l,z(ad(g),g))
end
local function bf(s,z,j,c)
local l,aj,ai={},an(s),e(c)=="table"and c.item_options or nil
for A,k in ipairs(aj)do
local a=f(ai,nil,j)if a.component==nil then
a.component=ah(A,c)end
if a.key==nil and a.preference==nil then
a.key=ay(A,c,j)end
if a.field==nil and a.fields==nil and a.key~=nil then
a.field=a.key
end
N(l,z(k,a))end
return l
end
local function aN(s,z,c)
local l,aj,ai={},an(s),e(c)=="table"and c.item_options or nil
for A,k in ipairs(aj)do
local a=f(ai,nil,nil)if a.phase==nil then
a.phase=aJ(A,c)end
N(l,z(k,a))end
return l
end
local function aM(c,t,z)
local g
if e(c)=="table"then
g=x(c,t,true)else
g={dp=c}end
local l={}S(l,g.dp,z,g)return l
end
function h.dp_temperature(k,b,c)
return d(k,"temperature",10,b,c)
end
function h.dp_humidity(k,b,c)
return d(k,"humidity",10,b,c)
end
function h.dp_battery(k,b,c)
return d(k,"battery",1,b,c)
end
function h.dp_illuminance(k,b,c)
local a=f(b,c,"illuminance")return h.dp_numeric(k,a)
end
function h.dp_temperature_unit(k,b,c)
local a=f(b,c,"temperature_unit")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=n.temperature_unit()end
return h.dp_enum(k,a)
end
function h.dp_inlet_water_temperature(k,b,c)
return d(k,"inlet_water_temperature",100,b,c)
end
function h.dp_outlet_water_temperature(k,b,c)
return d(k,"outlet_water_temperature",100,b,c)
end
function h.dp_temperature_calibration(k,b,c)
return q(k,"temperature_calibration",10,b,c)
end
function h.dp_humidity_calibration(k,b,c)
return q(k,"humidity_calibration",1,b,c)
end
function h.dp_max_temperature_alarm(k,b,c)
return d(k,"max_temperature_alarm",10,b,c)
end
function h.dp_min_temperature_alarm(k,b,c)
return d(k,"min_temperature_alarm",10,b,c)
end
function h.dp_max_humidity_alarm(k,b,c)
return d(k,"max_humidity_alarm",1,b,c)
end
function h.dp_min_humidity_alarm(k,b,c)
return d(k,"min_humidity_alarm",1,b,c)
end
function h.dp_temperature_alarm(k,b,c)
local a=f(b,c,"temperature_alarm")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=n.alarm_state_lower_upper_cancel()end
return h.dp_enum(k,a)
end
function h.dp_humidity_alarm(k,b,c)
local a=f(b,c,"humidity_alarm")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=n.alarm_state_lower_upper_cancel()end
return h.dp_enum(k,a)
end
function h.dp_soil_moisture(k,b,c)
return d(k,"soil_moisture",1,b,c)
end
function h.dp_soil_calibration(k,b,c)
return q(k,"soil_calibration",1,b,c)
end
function h.dp_temperature_sampling(k,b,c)
return d(k,"temperature_sampling",1,b,c)
end
function h.dp_report_interval(k,b,c)
return d(k,"report_interval",1,b,c)
end
function h.dp_soil_sampling(k,b,c)
return d(k,"soil_sampling",1,b,c)
end
function h.dp_soil_warning(k,b,c)
return d(k,"soil_warning",1,b,c)
end
function h.dp_illuminance_calibration(k,b,c)
return q(k,"illuminance_calibration",1,b,c)
end
function h.dp_water_warning(k,b,c)
local a=f(b,c,"water_warning")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=n.water_warning()end
return h.dp_enum(k,a)
end
function h.dp_soil_fertility(k,b,c)
return d(k,"soil_fertility",1,b,c)
end
function h.dp_soil_fertility_calibration(k,b,c)
return q(k,"soil_fertility_calibration",1,b,c)
end
function h.dp_soil_fertility_warning(k,b,c)
local a=f(b,c,"soil_fertility_warning")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=n.soil_fertility_warning()end
return h.dp_enum(k,a)
end
function h.dp_water_consumed(k,b,c)
return i(k,"water_consumed",1000,{bytes=4,from_tail=true},b,c)
end
function h.dp_reverse_water_consumed(k,b,c)
return i(k,"reverse_water_consumed",1000,{bytes=4},b,c)
end
function h.dp_month_consumption(k,b,c)
return i(k,"month_consumption",1000,{bytes=4,from_tail=true},b,c)
end
function h.dp_daily_consumption(k,b,c)
return i(k,"daily_consumption",1000,{bytes=4,from_tail=true},b,c)
end
function h.dp_flow_rate(k,b,c)
return i(k,"flow_rate",1000,{bytes=4},b,c)
end
function h.dp_instantaneous_flow_rate(k,b,c)
return i(k,"instantaneous_flow_rate",1000,{bytes=4},b,c)
end
function h.dp_cumulative_heat(k,b,c)
return i(k,"cumulative_heat",100,{bytes=4},b,c)
end
function h.dp_battery_voltage(k,b,c)
return d(k,"battery_voltage",100,b,c)
end
function h.dp_meter_id(k,b,c)
local a=f(b,c,"meter_id")if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=n.raw_identifier()end
return h.dp_raw(k,a)
end
function h.dp_water_meter_faults(k,b,c)
local a=f(b,c,"faults")if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=n.water_meter_faults()end
return h.dp_numeric(k,a)
end
function h.dp_alarm(k,b,c)
return h.dp_binary(k,f(b,c,"alarm"))
end
function h.dp_co2(k,b,c)
return d(k,"co2",1,b,c)
end
function h.dp_voc(k,b,c)
return d(k,"voc",1,b,c)
end
function h.dp_pm25(k,b,c)
return d(k,"pm25",1,b,c)
end
function h.dp_formaldehyde(k,b,c)
return d(k,"formaldehyde",1,b,c)
end
end
return as
