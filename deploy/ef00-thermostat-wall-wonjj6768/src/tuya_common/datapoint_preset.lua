local function at(p,aC,br)
br=br or{switch=function()return nil end}
local d,L,aS,k,bl,t=aC.type_check,aC.table_insert,aC.tonumber_check,aC.merge_options,aC.copy_keys,p.converter





local function aq(Y,I)
if d(Y)~="table"or d(I)~="table"then
return Y
end
for as,P in pairs(I)do
if Y[as]==nil then
Y[as]=P
end
end
return Y
end
local function f(c,b,h)
local a={}if d(c)=="string"then
a.name=c
else
k(a,c)end
k(a,b)if a.name==nil and h~=nil then
a.name=h
end
return a
end
local an={"send_policy","command_id","transaction","batch_key","match_transaction","response_dp","response_dps","match_response"}
local function am(b)
if d(b)~="table"then
return false
end
for _,as in ipairs(an)do
if b[as]~=nil then
return true
end
end
return false
end
local function T(bg,b)
if am(b)then
return bg
end
return p.apply_fixed_send_policy(bg)
end
local function e(s,h,z,c,b)
local a=f(c,b,h)local A=a.scale
if A==nil then
A=z
end
if a.converter==nil and a.from_device==nil and a.to_device==nil and A~=1 then
a.converter=t.divide_by_pair(A)end
a.scale=nil
return p.dp_numeric(s,a)
end
local function ac(s,h,z,c,b)
local a=f(c,b,h)local A=a.scale
if A==nil then
A=z
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
local ap=t.power()local be=ap.from
if A~=1 then
a.from_device=t.pipe(be,t.divide_by(A))else
a.converter=ap
end
end
a.scale=nil
return p.dp_numeric(s,a)
end
local function ab(s,h,z,c,b)
local a=f(c,b,h)local A=a.scale
if A==nil then
A=z
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=t.signed_number_pair(A)end
if a.signed==nil then
a.signed=true
end
a.scale=nil
return p.dp_numeric(s,a)
end
local function aH(s,h,z,bb,c,b)
local a=f(c,b,h)local A=a.scale
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
local aF={bytes=a.raw_bytes or a.raw_length,length=a.raw_length,from_tail=a.raw_from_tail,start=a.raw_start,offset=a.raw_offset}aq(aF,bb)a.converter=t.raw_uint_be(A,aF)if a.datatype==nil then
a.datatype=p.DP_TYPE_RAW
end
elseif a.converter==nil and a.from_device==nil and a.to_device==nil and A~=1 then
a.converter=t.divide_by_pair(A)end
a.scale=nil
a.raw=nil
a.raw_bytes=nil
a.raw_length=nil
a.raw_from_tail=nil
a.raw_start=nil
a.raw_offset=nil
return p.dp_numeric(s,a)
end
local function V(P,bo,bn)
local aB=aS(P)if aB==nil then
return nil
end
return bo+bn-aB
end
local function aU(s,h,I,c,b)
local a=f(c,b,h)local ag=a.raw_min
if ag==nil then
ag=I.raw_min
end
local af=a.raw_max
if af==nil then
af=I.raw_max
end
local G=a.value_min
if G==nil then
G=I.value_min
end
local F=a.value_max
if F==nil then
F=I.value_max
end
local bu=a.invert==true or a.invert_position==true
if a.converter==nil and a.from_device==nil and a.to_device==nil then
if bu then
local bi,bs=t.scale(ag,af,G,F),t.scale(G,F,ag,af)a.converter=t.from_to(
function(P,aX,aP)
local bp=bi(P,aX,aP)if bp==nil then
return nil
end
return V(bp,G,F)
end,
function(P,aX,aP)
local aZ=V(P,G,F)if aZ==nil then
return nil
end
return bs(aZ,aX,aP)
end
)elseif ag~=G or af~=F then
a.converter=t.scale_pair(ag,af,G,F)end
end
a.raw_min=nil
a.raw_max=nil
a.value_min=nil
a.value_max=nil
a.invert=nil
a.invert_position=nil
return p.dp_numeric(s,a)
end
local function bj(phase,aY)
if d(phase)=="string"and phase~=""then
return(aY or"phase").."_"..phase
end
return aY or"phase"
end
local function ba(bw,phase)
local bm={}for _,as in ipairs(bw or{})do
local aI=as
if d(phase)=="string"and phase~=""then
aI=as.."_"..phase
end
bm[aI]=true
end
return bm
end
local function bc(s,h,aR,bh,c,b)
local aW=
d(c)=="string"or
(d(c)=="table"and c.name~=nil)or
(d(b)=="table"and b.name~=nil)local a=f(c,b,h)local phase=a.phase
if not aW and a.name==h then
a.name=bj(phase,h)end
if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=aR(a)end
if a.field==nil and a.fields==nil then
a.fields=ba(bh,phase)end
return p.dp_raw(s,a)
end
local function bd(s,c,b)
local a=f(c,b,"threshold")if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=t.threshold_parser()end
if a.field==nil and a.fields==nil then
a.fields={threshold_1=true,threshold_1_protection=true,threshold_1_value=true,threshold_2=true,threshold_2_protection=true,threshold_2_value=true}end
return p.dp_raw(s,a)
end
local function ao(n)
if d(n)=="number"and n%1==0 and n>=0 then
return{n}end
if d(n)~="table"then
return{}end
local aJ={}for _,s in ipairs(n)do
if d(s)=="number"and s%1==0 and s>=0 then
L(aJ,s)end
end
return aJ
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
local function ae(b)
local n=Z(b)if n~=nil then
return n
end
if d(b)~="table"then
return b
end
return b.dp
end
local function aK(y,b)
b=b or{}local aL=b.phases
if d(aL)~="table"then
aL=b.phase_names
end
local phase=d(aL)=="table"and aL[y]or nil
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
local function ai(y,b)
b=b or{}local J,H=b.first_is_main~=false,b.component_prefix

if d(H)~="string"or H==""then
H="switch"end
local O=b.main_component
if d(O)~="string"or O==""then
O="main"end
local r=b.index_offset
if d(r)~="number"or r%1~=0 then
r=0
end
if y==1 and J then
return O
end
local aD=J and(y-1+r)or(y+r)if aD<1 then
return b.default_component
end
return H..tostring(aD)
end
local function az(y,b,aQ)
b=b or{}local J,W=b.first_is_main~=false,b.key_prefix

if d(W)~="string"or W==""then
W=aQ or"switch"end
local av=b.main_key
if d(av)~="string"or av==""then
av=W
end
local r=b.index_offset
if d(r)~="number"or r%1~=0 then
r=0
end
if y==1 and J then
return av
end
local aD=J and(y-1+r)or(y+r)if aD<1 then
return b.default_key
end
return W..tostring(aD)
end
local function Q(i,s,x,b)
if d(s)~="number"or s%1~=0 or s<0 then
return
end
L(i,x(s,b))
end
local function aa(Y,bt)
if d(bt)~="table"then
return Y
end
for _,bv in ipairs(bt)do
L(Y,bv)end
return Y
end
local al={"first_is_main","main_component","component_prefix","index_offset","default_component","key_prefix","main_key","default_key"}
local function ay(P)
return d(P)=="number"and P%1==0 and P>0
end
local function q(b,j)
local a={}if d(b)~="table"then
return a
end
for as,P in pairs(b)do
local aG=true
if not j then
if as=="dp"or as=="dps"or as=="dp_list"then
aG=false
elseif ay(as)then
aG=false
end
end
if aG then
a[as]=P
end
end
return a
end
local function ad(b)
if d(b)~="table"then
return false
end
if b.dp~=nil or b.dps~=nil or b.dp_list~=nil or b[1]~=nil then
return true
end
return false
end
local function E(b)
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
return q(b,j)end
local a=q(b,j)if d(u)=="table"then
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
local function aw(au,g)
local K,C=d(au)=="table"and au.item_options or nil,d(g)=="table"and g.item_options or nil

if d(K)~="table"then
return d(C)=="table"and C or nil
end
if d(C)~="table"then
return K
end
local a={}k(a,K)k(a,C)return a
end
local function ah(b,o,B,j)
local a={}local u
if d(b)=="table"then
bl(a,b,al)u=b[o]if d(u)=="table"then
k(a,q(b,j))if j and ad(u)then
E(a)end
k(a,u)elseif u~=nil then
k(a,q(b,j))if j then
E(a)end
a.dp=u
else
k(a,q(b,j))end
end
if a.key_prefix==nil and B~=nil then
a.key_prefix=B
end
a.item_options=aw(b,u)return a
end
local function M(b,m)
local l,ar={},U(b,"config")k(l,ar)local ax=w(l[m])if ax~=nil then
l[m]=ax
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
local function N(b,m)
local a={}if d(b)=="table"then
k(a,b)end
local l=M(b,m)if next(l)~=nil then
a.config=l
end
a.switch_type=nil
return a
end
local function aV(b,m)
local a={}if d(b)=="table"then
k(a,b)end
local S=N(v(b,"switch_module"),m)if next(S)~=nil then
a.switch_module=S
end
return a
end
local function bk(i,b,o,x)
local g=v(b,o)Q(i,g.dp,x,g)
end
local function aE(i,b,o,x,I)
local g=v(b,o)aq(g,I)Q(i,g.dp,x,g)
end
local function aT(i,b,o,x,aA)
local g=v(b,o)local n=Z(g)if n~=nil and aA~=nil then
aa(i,aA(n,g))return
end
Q(i,g.dp,x,g)
end
local function aM(i,b,o,B,x)
local g=ah(b,o,B)aa(i,x(ae(g),g))
end
local function bf(n,x,h,b)
local i,ak,aj={},ao(n),d(b)=="table"and b.item_options or nil
for y,s in ipairs(ak)do
local a=f(aj,nil,h)if a.component==nil then
a.component=ai(y,b)end
if a.key==nil and a.preference==nil then
a.key=az(y,b,h)end
if a.field==nil and a.fields==nil and a.key~=nil then
a.field=a.key
end
L(i,x(s,a))end
return i
end
local function aO(n,x,b)
local i,ak,aj={},ao(n),d(b)=="table"and b.item_options or nil
for y,s in ipairs(ak)do
local a=f(aj,nil,nil)if a.phase==nil then
a.phase=aK(y,b)end
L(i,x(s,a))end
return i
end
local function aN(b,o,x)
local g
if d(b)=="table"then
g=v(b,o,true)else
g={dp=b}end
local i={}Q(i,g.dp,x,g)return i
end
function p.dp_on_off(s,c,b)
local a=f(c,b,"switch")if a.name=="switch"and a.emit==nil then
a.emit=br.switch()end
return p.dp_binary(s,a)
end
function p.dp_temperature(s,c,b)
return e(s,"temperature",10,c,b)
end
function p.dp_humidity(s,c,b)
return e(s,"humidity",10,c,b)
end
function p.dp_battery(s,c,b)
return e(s,"battery",1,c,b)
end
function p.dp_child_lock(s,c,b)
return p.dp_binary(s,f(c,b,"child_lock"))
end
function p.dp_voltage(s,c,b)
return e(s,"voltage",10,c,b)
end
function p.dp_current(s,c,b)
return e(s,"current",1000,c,b)
end
function p.dp_power(s,c,b)
return ac(s,"power",10,c,b)
end
function p.dp_energy(s,c,b)
return e(s,"energy",100,c,b)
end
function p.dp_local_temperature(s,c,b)
return e(s,"local_temperature",10,c,b)
end
function p.dp_current_heating_setpoint(s,c,b)
return e(s,"current_heating_setpoint",10,c,b)
end
function p.dp_local_temperature_calibration(s,c,b)
return ab(s,"local_temperature_calibration",10,c,b)
end
function p.dp_eco_temperature(s,c,b)
return e(s,"eco_temperature",10,c,b)
end
function p.dp_holiday_temperature(s,c,b)
return e(s,"holiday_temperature",10,c,b)
end
function p.dp_max_temperature_limit(s,c,b)
return e(s,"max_temperature_limit",10,c,b)
end
function p.dp_min_temperature_limit(s,c,b)
return e(s,"min_temperature_limit",10,c,b)
end
function p.dp_deadzone_temperature(s,c,b)
return e(s,"deadzone_temperature",1,c,b)
end
function p.dp_system_mode(s,c,b)
return p.dp_enum(s,f(c,b,"system_mode"))
end
function p.dp_running_state(s,c,b)
return p.dp_enum(s,f(c,b,"running_state"))
end
function p.dp_frost_protection(s,c,b)
return p.dp_binary(s,f(c,b,"frost_protection"))
end
function p.dp_temperature_sensor_select_internal_external_both(s,c,b)
local a=f(c,b,"temperature_sensor_select")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=t.temperature_sensor_select_internal_external_both()end
return T(p.dp_enum(s,a),a)
end
end
return at
