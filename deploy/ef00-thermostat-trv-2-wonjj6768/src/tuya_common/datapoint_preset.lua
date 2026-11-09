local function ar(m,aA,bt)
bt=bt or{switch=function()return nil end}
local d,L,aR,k,bl,w=aA.type_check,aA.table_insert,aA.tonumber_check,aA.merge_options,aA.copy_keys,m.converter





local function ao(X,I)
if d(X)~="table"or d(I)~="table"then
return X
end
for aq,P in pairs(I)do
if X[aq]==nil then
X[aq]=P
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
return m.apply_fixed_send_policy(bg)
end
local function f(s,h,z,c,b)
local a=e(c,b,h)local A=a.scale
if A==nil then
A=z
end
if a.converter==nil and a.from_device==nil and a.to_device==nil and A~=1 then
a.converter=w.divide_by_pair(A)end
a.scale=nil
return m.dp_numeric(s,a)
end
local function aV(s,h,z,c,b)
local a=e(c,b,h)local A=a.scale
if A==nil then
A=z
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
local an=w.power()local be=an.from
if A~=1 then
a.from_device=w.pipe(be,w.divide_by(A))else
a.converter=an
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
a.converter=w.signed_number_pair(A)end
if a.signed==nil then
a.signed=true
end
a.scale=nil
return m.dp_numeric(s,a)
end
local function aG(s,h,z,bb,c,b)
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
local aD={bytes=a.raw_bytes or a.raw_length,length=a.raw_length,from_tail=a.raw_from_tail,start=a.raw_start,offset=a.raw_offset}ao(aD,bb)a.converter=w.raw_uint_be(A,aD)if a.datatype==nil then
a.datatype=m.DP_TYPE_RAW
end
elseif a.converter==nil and a.from_device==nil and a.to_device==nil and A~=1 then
a.converter=w.divide_by_pair(A)end
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
local az=aR(P)if az==nil then
return nil
end
return bo+bn-az
end
local function aT(s,h,I,c,b)
local a=e(c,b,h)local ae=a.raw_min
if ae==nil then
ae=I.raw_min
end
local ad=a.raw_max
if ad==nil then
ad=I.raw_max
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
local bi,br=w.scale(ae,ad,G,F),w.scale(G,F,ae,ad)a.converter=w.from_to(
function(P,aX,aO)
local bp=bi(P,aX,aO)if bp==nil then
return nil
end
return U(bp,G,F)
end,
function(P,aX,aO)
local aZ=U(P,G,F)if aZ==nil then
return nil
end
return br(aZ,aX,aO)
end
)elseif ae~=G or ad~=F then
a.converter=w.scale_pair(ae,ad,G,F)end
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
local bm={}for _,aq in ipairs(bw or{})do
local aH=aq
if d(phase)=="string"and phase~=""then
aH=aq.."_"..phase
end
bm[aH]=true
end
return bm
end
local function bc(s,h,aQ,bh,c,b)
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
return m.dp_raw(s,a)
end
local function bd(s,c,b)
local a=e(c,b,"threshold")if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=w.threshold_parser()end
if a.field==nil and a.fields==nil then
a.fields={threshold_1=true,threshold_1_protection=true,threshold_1_value=true,threshold_2=true,threshold_2_protection=true,threshold_2_value=true}end
return m.dp_raw(s,a)
end
local function am(o)
if d(o)=="number"and o%1==0 and o>=0 then
return{o}end
if d(o)~="table"then
return{}end
local aI={}for _,s in ipairs(o)do
if d(s)=="number"and s%1==0 and s>=0 then
L(aI,s)end
end
return aI
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
local function ac(b)
local o=Y(b)if o~=nil then
return o
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
local aB=J and(y-1+r)or(y+r)if aB<1 then
return b.default_component
end
return H..tostring(aB)
end
local function ax(y,b,aP)
b=b or{}local J,V=b.first_is_main~=false,b.key_prefix

if d(V)~="string"or V==""then
V=aP or"switch"end
local at=b.main_key
if d(at)~="string"or at==""then
at=V
end
local r=b.index_offset
if d(r)~="number"or r%1~=0 then
r=0
end
if y==1 and J then
return at
end
local aB=J and(y-1+r)or(y+r)if aB<1 then
return b.default_key
end
return V..tostring(aB)
end
local function Q(i,s,x,b)
if d(s)~="number"or s%1~=0 or s<0 then
return
end
L(i,x(s,b))
end
local function Z(X,bs)
if d(bs)~="table"then
return X
end
for _,bv in ipairs(bs)do
L(X,bv)end
return X
end
local aj={"first_is_main","main_component","component_prefix","index_offset","default_component","key_prefix","main_key","default_key"}
local function aw(P)
return d(P)=="number"and P%1==0 and P>0
end
local function q(b,j)
local a={}if d(b)~="table"then
return a
end
for aq,P in pairs(b)do
local aE=true
if not j then
if aq=="dp"or aq=="dps"or aq=="dp_list"then
aE=false
elseif aw(aq)then
aE=false
end
end
if aE then
a[aq]=P
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
local function u(b,p,j)
if d(b)~="table"then
return{}end
local t=b[p]if t==nil then
return q(b,j)end
local a=q(b,j)if d(t)=="table"then
k(a,t)else
a.dp=t
end
return a
end
local function v(t)
if t==nil then
return nil
end
if d(t)=="table"then
return t
end
return{dp=t}
end
local function T(b,p)
if d(b)~="table"then
return nil
end
return v(b[p])
end
local function au(as,g)
local K,C=d(as)=="table"and as.item_options or nil,d(g)=="table"and g.item_options or nil

if d(K)~="table"then
return d(C)=="table"and C or nil
end
if d(C)~="table"then
return K
end
local a={}k(a,K)k(a,C)return a
end
local function af(b,p,B,j)
local a={}local t
if d(b)=="table"then
bl(a,b,aj)t=b[p]if d(t)=="table"then
k(a,q(b,j))if j and ab(t)then
E(a)end
k(a,t)elseif t~=nil then
k(a,q(b,j))if j then
E(a)end
a.dp=t
else
k(a,q(b,j))end
end
if a.key_prefix==nil and B~=nil then
a.key_prefix=B
end
a.item_options=au(b,t)return a
end
local function M(b,n)
local l,ap={},T(b,"config")k(l,ap)local av=v(l[n])if av~=nil then
l[n]=av
else
local W=v(l.switch_type)if W==nil then
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
local function aU(b,n)
local a={}if d(b)=="table"then
k(a,b)end
local S=N(u(b,"switch_module"),n)if next(S)~=nil then
a.switch_module=S
end
return a
end
local function bk(i,b,p,x)
local g=u(b,p)Q(i,g.dp,x,g)
end
local function aC(i,b,p,x,I)
local g=u(b,p)ao(g,I)Q(i,g.dp,x,g)
end
local function aS(i,b,p,x,ay)
local g=u(b,p)local o=Y(g)if o~=nil and ay~=nil then
Z(i,ay(o,g))return
end
Q(i,g.dp,x,g)
end
local function aL(i,b,p,B,x)
local g=af(b,p,B)Z(i,x(ac(g),g))
end
local function bf(o,x,h,b)
local i,ai,ah={},am(o),d(b)=="table"and b.item_options or nil
for y,s in ipairs(ai)do
local a=e(ah,nil,h)if a.component==nil then
a.component=ag(y,b)end
if a.key==nil and a.preference==nil then
a.key=ax(y,b,h)end
if a.field==nil and a.fields==nil and a.key~=nil then
a.field=a.key
end
L(i,x(s,a))end
return i
end
local function aN(o,x,b)
local i,ai,ah={},am(o),d(b)=="table"and b.item_options or nil
for y,s in ipairs(ai)do
local a=e(ah,nil,nil)if a.phase==nil then
a.phase=aJ(y,b)end
L(i,x(s,a))end
return i
end
local function aM(b,p,x)
local g
if d(b)=="table"then
g=u(b,p,true)else
g={dp=b}end
local i={}Q(i,g.dp,x,g)return i
end
function m.dp_temperature(s,c,b)
return f(s,"temperature",10,c,b)
end
function m.dp_battery(s,c,b)
return f(s,"battery",1,c,b)
end
function m.dp_child_lock(s,c,b)
return m.dp_binary(s,e(c,b,"child_lock"))
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
function m.dp_open_window_temperature(s,c,b)
return f(s,"open_window_temperature",10,c,b)
end
function m.dp_comfort_temperature(s,c,b)
return f(s,"comfort_temperature",10,c,b)
end
function m.dp_eco_temperature(s,c,b)
return f(s,"eco_temperature",10,c,b)
end
function m.dp_holiday_temperature(s,c,b)
return f(s,"holiday_temperature",10,c,b)
end
function m.dp_max_temperature_limit(s,c,b)
return f(s,"max_temperature_limit",10,c,b)
end
function m.dp_min_temperature_limit(s,c,b)
return f(s,"min_temperature_limit",10,c,b)
end
function m.dp_system_mode(s,c,b)
return m.dp_enum(s,e(c,b,"system_mode"))
end
function m.dp_running_state(s,c,b)
return m.dp_enum(s,e(c,b,"running_state"))
end
function m.dp_frost_protection(s,c,b)
return m.dp_binary(s,e(c,b,"frost_protection"))
end
function m.dp_window_detection(s,c,b)
return m.dp_binary(s,e(c,b,"window_detection"))
end
function m.dp_open_window(s,c,b)
return m.dp_binary(s,e(c,b,"open_window"))
end
function m.dp_window_open(s,c,b)
return m.dp_binary(s,e(c,b,"window_open"))
end
function m.dp_boost_heating(s,c,b)
return m.dp_binary(s,e(c,b,"boost_heating"))
end
function m.dp_scale_protection(s,c,b)
return m.dp_binary(s,e(c,b,"scale_protection"))
end
end
return ar
