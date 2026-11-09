local function as(m,aB,br)
br=br or{switch=function()return nil end}
local d,L,aS,k,bl,t=aB.type_check,aB.table_insert,aB.tonumber_check,aB.merge_options,aB.copy_keys,m.converter





local function ap(X,I)
if d(X)~="table"or d(I)~="table"then
return X
end
for ar,P in pairs(I)do
if X[ar]==nil then
X[ar]=P
end
end
return X
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
local am={"send_policy","command_id","transaction","batch_key","match_transaction","response_dp","response_dps","match_response"}
local function al(b)
if d(b)~="table"then
return false
end
for _,ar in ipairs(am)do
if b[ar]~=nil then
return true
end
end
return false
end
local function aG(bg,b)
if al(b)then
return bg
end
return m.apply_fixed_send_policy(bg)
end
local function f(s,h,z,c,b)
local a=e(c,b,h)local A=a.scale
if A==nil then
A=z
end
if a.converter==nil and a.from_device==nil and a.to_device==nil and A~=1 then
a.converter=t.divide_by_pair(A)end
a.scale=nil
return m.dp_numeric(s,a)
end
local function ab(s,h,z,c,b)
local a=e(c,b,h)local A=a.scale
if A==nil then
A=z
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
local ao=t.power()local be=ao.from
if A~=1 then
a.from_device=t.pipe(be,t.divide_by(A))else
a.converter=ao
end
end
a.scale=nil
return m.dp_numeric(s,a)
end
local function aa(s,h,z,c,b)
local a=e(c,b,h)local A=a.scale
if A==nil then
A=z
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=t.signed_number_pair(A)end
if a.signed==nil then
a.signed=true
end
a.scale=nil
return m.dp_numeric(s,a)
end
local function aH(s,h,z,bb,c,b)
local a=e(c,b,h)local A=a.scale
if A==nil then
A=z
end
local bq=
a.datatype==m.DP_TYPE_RAW or
a.raw==true or
a.raw_bytes~=nil or
a.raw_length~=nil or
a.raw_from_tail~=nil or
a.raw_start~=nil or
a.raw_offset~=nil
if bq and a.converter==nil and a.from_device==nil and a.to_device==nil then
local aE={bytes=a.raw_bytes or a.raw_length,length=a.raw_length,from_tail=a.raw_from_tail,start=a.raw_start,offset=a.raw_offset}ap(aE,bb)a.converter=t.raw_uint_be(A,aE)if a.datatype==nil then
a.datatype=m.DP_TYPE_RAW
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
return m.dp_numeric(s,a)
end
local function U(P,bo,bn)
local aA=aS(P)if aA==nil then
return nil
end
return bo+bn-aA
end
local function aU(s,h,I,c,b)
local a=e(c,b,h)local af=a.raw_min
if af==nil then
af=I.raw_min
end
local ae=a.raw_max
if ae==nil then
ae=I.raw_max
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
local bi,bs=t.scale(af,ae,G,F),t.scale(G,F,af,ae)a.converter=t.from_to(
function(P,aX,aP)
local bp=bi(P,aX,aP)if bp==nil then
return nil
end
return U(bp,G,F)
end,
function(P,aX,aP)
local aZ=U(P,G,F)if aZ==nil then
return nil
end
return bs(aZ,aX,aP)
end
)elseif af~=G or ae~=F then
a.converter=t.scale_pair(af,ae,G,F)end
end
a.raw_min=nil
a.raw_max=nil
a.value_min=nil
a.value_max=nil
a.invert=nil
a.invert_position=nil
return m.dp_numeric(s,a)
end
local function bj(phase,aY)
if d(phase)=="string"and phase~=""then
return(aY or"phase").."_"..phase
end
return aY or"phase"
end
local function ba(bw,phase)
local bm={}for _,ar in ipairs(bw or{})do
local aI=ar
if d(phase)=="string"and phase~=""then
aI=ar.."_"..phase
end
bm[aI]=true
end
return bm
end
local function bc(s,h,aR,bh,c,b)
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
a.converter=aR(a)end
if a.field==nil and a.fields==nil then
a.fields=ba(bh,phase)end
return m.dp_raw(s,a)
end
local function bd(s,c,b)
local a=e(c,b,"threshold")if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=t.threshold_parser()end
if a.field==nil and a.fields==nil then
a.fields={threshold_1=true,threshold_1_protection=true,threshold_1_value=true,threshold_2=true,threshold_2_protection=true,threshold_2_value=true}end
return m.dp_raw(s,a)
end
local function an(o)
if d(o)=="number"and o%1==0 and o>=0 then
return{o}end
if d(o)~="table"then
return{}end
local aJ={}for _,s in ipairs(o)do
if d(s)=="number"and s%1==0 and s>=0 then
L(aJ,s)end
end
return aJ
end
local function Y(b)
if d(b)~="table"then
return b
end
local o=b.dps
if o==nil then
o=b.dp_list
end
if o==nil and b[1]~=nil then
o=b
end
return o
end
local function ad(b)
local o=Y(b)if o~=nil then
return o
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
local function ah(y,b)
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
local aC=J and(y-1+r)or(y+r)if aC<1 then
return b.default_component
end
return H..tostring(aC)
end
local function ay(y,b,aQ)
b=b or{}local J,V=b.first_is_main~=false,b.key_prefix

if d(V)~="string"or V==""then
V=aQ or"switch"end
local au=b.main_key
if d(au)~="string"or au==""then
au=V
end
local r=b.index_offset
if d(r)~="number"or r%1~=0 then
r=0
end
if y==1 and J then
return au
end
local aC=J and(y-1+r)or(y+r)if aC<1 then
return b.default_key
end
return V..tostring(aC)
end
local function Q(i,s,x,b)
if d(s)~="number"or s%1~=0 or s<0 then
return
end
L(i,x(s,b))
end
local function Z(X,bt)
if d(bt)~="table"then
return X
end
for _,bv in ipairs(bt)do
L(X,bv)end
return X
end
local ak={"first_is_main","main_component","component_prefix","index_offset","default_component","key_prefix","main_key","default_key"}
local function ax(P)
return d(P)=="number"and P%1==0 and P>0
end
local function q(b,j)
local a={}if d(b)~="table"then
return a
end
for ar,P in pairs(b)do
local aF=true
if not j then
if ar=="dp"or ar=="dps"or ar=="dp_list"then
aF=false
elseif ax(ar)then
aF=false
end
end
if aF then
a[ar]=P
end
end
return a
end
local function ac(b)
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
local function v(b,p,j)
if d(b)~="table"then
return{}end
local u=b[p]if u==nil then
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
local function T(b,p)
if d(b)~="table"then
return nil
end
return w(b[p])
end
local function av(at,g)
local K,C=d(at)=="table"and at.item_options or nil,d(g)=="table"and g.item_options or nil

if d(K)~="table"then
return d(C)=="table"and C or nil
end
if d(C)~="table"then
return K
end
local a={}k(a,K)k(a,C)return a
end
local function ag(b,p,B,j)
local a={}local u
if d(b)=="table"then
bl(a,b,ak)u=b[p]if d(u)=="table"then
k(a,q(b,j))if j and ac(u)then
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
a.item_options=av(b,u)return a
end
local function M(b,n)
local l,aq={},T(b,"config")k(l,aq)local aw=w(l[n])if aw~=nil then
l[n]=aw
else
local W=w(l.switch_type)if W==nil then
W=T(b,"switch_type")end
if d(W)=="table"then
l[n]=W
end
end
if n~="switch_type"then
l.switch_type=nil
end
if next(l)~=nil then
return l
end
return{}
end
local function N(b,n)
local a={}if d(b)=="table"then
k(a,b)end
local l=M(b,n)if next(l)~=nil then
a.config=l
end
a.switch_type=nil
return a
end
local function aV(b,n)
local a={}if d(b)=="table"then
k(a,b)end
local S=N(v(b,"switch_module"),n)if next(S)~=nil then
a.switch_module=S
end
return a
end
local function bk(i,b,p,x)
local g=v(b,p)Q(i,g.dp,x,g)
end
local function aD(i,b,p,x,I)
local g=v(b,p)ap(g,I)Q(i,g.dp,x,g)
end
local function aT(i,b,p,x,az)
local g=v(b,p)local o=Y(g)if o~=nil and az~=nil then
Z(i,az(o,g))return
end
Q(i,g.dp,x,g)
end
local function aM(i,b,p,B,x)
local g=ag(b,p,B)Z(i,x(ad(g),g))
end
local function bf(o,x,h,b)
local i,aj,ai={},an(o),d(b)=="table"and b.item_options or nil
for y,s in ipairs(aj)do
local a=e(ai,nil,h)if a.component==nil then
a.component=ah(y,b)end
if a.key==nil and a.preference==nil then
a.key=ay(y,b,h)end
if a.field==nil and a.fields==nil and a.key~=nil then
a.field=a.key
end
L(i,x(s,a))end
return i
end
local function aO(o,x,b)
local i,aj,ai={},an(o),d(b)=="table"and b.item_options or nil
for y,s in ipairs(aj)do
local a=e(ai,nil,nil)if a.phase==nil then
a.phase=aK(y,b)end
L(i,x(s,a))end
return i
end
local function aN(b,p,x)
local g
if d(b)=="table"then
g=v(b,p,true)else
g={dp=b}end
local i={}Q(i,g.dp,x,g)return i
end
function m.dp_on_off(s,c,b)
local a=e(c,b,"switch")if a.name=="switch"and a.emit==nil then
a.emit=br.switch()end
return m.dp_binary(s,a)
end
function m.dp_temperature(s,c,b)
return f(s,"temperature",10,c,b)
end
function m.dp_humidity(s,c,b)
return f(s,"humidity",10,c,b)
end
function m.dp_child_lock(s,c,b)
return m.dp_binary(s,e(c,b,"child_lock"))
end
function m.dp_voltage(s,c,b)
return f(s,"voltage",10,c,b)
end
function m.dp_current(s,c,b)
return f(s,"current",1000,c,b)
end
function m.dp_power(s,c,b)
return ab(s,"power",10,c,b)
end
function m.dp_energy(s,c,b)
return f(s,"energy",100,c,b)
end
function m.dp_temperature_unit(s,c,b)
local a=e(c,b,"temperature_unit")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=t.temperature_unit()end
return m.dp_enum(s,a)
end
function m.dp_local_temperature(s,c,b)
return f(s,"local_temperature",10,c,b)
end
function m.dp_current_heating_setpoint(s,c,b)
return f(s,"current_heating_setpoint",10,c,b)
end
function m.dp_local_temperature_calibration(s,c,b)
return aa(s,"local_temperature_calibration",10,c,b)
end
function m.dp_eco_temperature(s,c,b)
return f(s,"eco_temperature",10,c,b)
end
function m.dp_max_temperature_limit(s,c,b)
return f(s,"max_temperature_limit",10,c,b)
end
function m.dp_min_temperature_limit(s,c,b)
return f(s,"min_temperature_limit",10,c,b)
end
function m.dp_deadzone_temperature(s,c,b)
return f(s,"deadzone_temperature",1,c,b)
end
function m.dp_system_mode(s,c,b)
return m.dp_enum(s,e(c,b,"system_mode"))
end
function m.dp_running_state(s,c,b)
return m.dp_enum(s,e(c,b,"running_state"))
end
function m.dp_fan_mode(s,c,b)
return m.dp_enum(s,e(c,b,"fan_mode"))
end
function m.dp_open_window(s,c,b)
return m.dp_binary(s,e(c,b,"open_window"))
end
function m.dp_eco_mode(s,c,b)
return m.dp_binary(s,e(c,b,"eco_mode"))
end
end
return as
