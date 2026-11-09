local function at(s,aC,br)
br=br or{switch=function()return nil end}
local d,M,aS,k,bl,q=aC.type_check,aC.table_insert,aC.tonumber_check,aC.merge_options,aC.copy_keys,s.converter





local function aq(Y,J)
if d(Y)~="table"or d(J)~="table"then
return Y
end
for as,Q in pairs(J)do
if Y[as]==nil then
Y[as]=Q
end
end
return Y
end
local function e(c,b,g)
local a={}if d(c)=="string"then
a.name=c
else
k(a,c)end
k(a,b)if a.name==nil and g~=nil then
a.name=g
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
local function v(bg,b)
if am(b)then
return bg
end
return s.apply_fixed_send_policy(bg)
end
local function j(y,g,A,c,b)
local a=e(c,b,g)local B=a.scale
if B==nil then
B=A
end
if a.converter==nil and a.from_device==nil and a.to_device==nil and B~=1 then
a.converter=q.divide_by_pair(B)end
a.scale=nil
return s.dp_numeric(y,a)
end
local function ac(y,g,A,c,b)
local a=e(c,b,g)local B=a.scale
if B==nil then
B=A
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
local ap=q.power()local be=ap.from
if B~=1 then
a.from_device=q.pipe(be,q.divide_by(B))else
a.converter=ap
end
end
a.scale=nil
return s.dp_numeric(y,a)
end
local function ab(y,g,A,c,b)
local a=e(c,b,g)local B=a.scale
if B==nil then
B=A
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=q.signed_number_pair(B)end
if a.signed==nil then
a.signed=true
end
a.scale=nil
return s.dp_numeric(y,a)
end
local function aH(y,g,A,bb,c,b)
local a=e(c,b,g)local B=a.scale
if B==nil then
B=A
end
local bq=
a.datatype==s.DP_TYPE_RAW or
a.raw==true or
a.raw_bytes~=nil or
a.raw_length~=nil or
a.raw_from_tail~=nil or
a.raw_start~=nil or
a.raw_offset~=nil
if bq and a.converter==nil and a.from_device==nil and a.to_device==nil then
local aF={bytes=a.raw_bytes or a.raw_length,length=a.raw_length,from_tail=a.raw_from_tail,start=a.raw_start,offset=a.raw_offset}aq(aF,bb)a.converter=q.raw_uint_be(B,aF)if a.datatype==nil then
a.datatype=s.DP_TYPE_RAW
end
elseif a.converter==nil and a.from_device==nil and a.to_device==nil and B~=1 then
a.converter=q.divide_by_pair(B)end
a.scale=nil
a.raw=nil
a.raw_bytes=nil
a.raw_length=nil
a.raw_from_tail=nil
a.raw_start=nil
a.raw_offset=nil
return s.dp_numeric(y,a)
end
local function V(Q,bo,bn)
local aB=aS(Q)if aB==nil then
return nil
end
return bo+bn-aB
end
local function aU(y,g,J,c,b)
local a=e(c,b,g)local ag=a.raw_min
if ag==nil then
ag=J.raw_min
end
local af=a.raw_max
if af==nil then
af=J.raw_max
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
local bi,bs=q.scale(ag,af,H,G),q.scale(H,G,ag,af)a.converter=q.from_to(
function(Q,aX,aP)
local bp=bi(Q,aX,aP)if bp==nil then
return nil
end
return V(bp,H,G)
end,
function(Q,aX,aP)
local aZ=V(Q,H,G)if aZ==nil then
return nil
end
return bs(aZ,aX,aP)
end
)elseif ag~=H or af~=G then
a.converter=q.scale_pair(ag,af,H,G)end
end
a.raw_min=nil
a.raw_max=nil
a.value_min=nil
a.value_max=nil
a.invert=nil
a.invert_position=nil
return s.dp_numeric(y,a)
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
local function bc(y,g,aR,bh,c,b)
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
a.converter=aR(a)end
if a.field==nil and a.fields==nil then
a.fields=ba(bh,phase)end
return s.dp_raw(y,a)
end
local function bd(y,c,b)
local a=e(c,b,"threshold")if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=q.threshold_parser()end
if a.field==nil and a.fields==nil then
a.fields={threshold_1=true,threshold_1_protection=true,threshold_1_value=true,threshold_2=true,threshold_2_protection=true,threshold_2_value=true}end
return s.dp_raw(y,a)
end
local function ao(n)
if d(n)=="number"and n%1==0 and n>=0 then
return{n}end
if d(n)~="table"then
return{}end
local aJ={}for _,y in ipairs(n)do
if d(y)=="number"and y%1==0 and y>=0 then
M(aJ,y)end
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
local function aK(z,b)
b=b or{}local aL=b.phases
if d(aL)~="table"then
aL=b.phase_names
end
local phase=d(aL)=="table"and aL[z]or nil
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
return E..tostring(z)end
return tostring(z)
end
local function ai(z,b)
b=b or{}local K,I=b.first_is_main~=false,b.component_prefix

if d(I)~="string"or I==""then
I="switch"end
local P=b.main_component
if d(P)~="string"or P==""then
P="main"end
local r=b.index_offset
if d(r)~="number"or r%1~=0 then
r=0
end
if z==1 and K then
return P
end
local aD=K and(z-1+r)or(z+r)if aD<1 then
return b.default_component
end
return I..tostring(aD)
end
local function az(z,b,aQ)
b=b or{}local K,W=b.first_is_main~=false,b.key_prefix

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
if z==1 and K then
return av
end
local aD=K and(z-1+r)or(z+r)if aD<1 then
return b.default_key
end
return W..tostring(aD)
end
local function R(h,y,x,b)
if d(y)~="number"or y%1~=0 or y<0 then
return
end
M(h,x(y,b))
end
local function aa(Y,bt)
if d(bt)~="table"then
return Y
end
for _,bv in ipairs(bt)do
M(Y,bv)end
return Y
end
local al={"first_is_main","main_component","component_prefix","index_offset","default_component","key_prefix","main_key","default_key"}
local function ay(Q)
return d(Q)=="number"and Q%1==0 and Q>0
end
local function p(b,i)
local a={}if d(b)~="table"then
return a
end
for as,Q in pairs(b)do
local aG=true
if not i then
if as=="dp"or as=="dps"or as=="dp_list"then
aG=false
elseif ay(as)then
aG=false
end
end
if aG then
a[as]=Q
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
local function F(b)
if d(b)~="table"then
return b
end
b.dp=nil
b.dps=nil
b.dp_list=nil
local z=1
while b[z]~=nil do
b[z]=nil
z=z+1
end
return b
end
local function u(b,o,i)
if d(b)~="table"then
return{}end
local t=b[o]if t==nil then
return p(b,i)end
local a=p(b,i)if d(t)=="table"then
k(a,t)else
a.dp=t
end
return a
end
local function w(t)
if t==nil then
return nil
end
if d(t)=="table"then
return t
end
return{dp=t}
end
local function U(b,o)
if d(b)~="table"then
return nil
end
return w(b[o])
end
local function aw(au,f)
local L,D=d(au)=="table"and au.item_options or nil,d(f)=="table"and f.item_options or nil

if d(L)~="table"then
return d(D)=="table"and D or nil
end
if d(D)~="table"then
return L
end
local a={}k(a,L)k(a,D)return a
end
local function ah(b,o,C,i)
local a={}local t
if d(b)=="table"then
bl(a,b,al)t=b[o]if d(t)=="table"then
k(a,p(b,i))if i and ad(t)then
F(a)end
k(a,t)elseif t~=nil then
k(a,p(b,i))if i then
F(a)end
a.dp=t
else
k(a,p(b,i))end
end
if a.key_prefix==nil and C~=nil then
a.key_prefix=C
end
a.item_options=aw(b,t)return a
end
local function N(b,m)
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
local function O(b,m)
local a={}if d(b)=="table"then
k(a,b)end
local l=N(b,m)if next(l)~=nil then
a.config=l
end
a.switch_type=nil
return a
end
local function aV(b,m)
local a={}if d(b)=="table"then
k(a,b)end
local T=O(u(b,"switch_module"),m)if next(T)~=nil then
a.switch_module=T
end
return a
end
local function bk(h,b,o,x)
local f=u(b,o)R(h,f.dp,x,f)
end
local function aE(h,b,o,x,J)
local f=u(b,o)aq(f,J)R(h,f.dp,x,f)
end
local function aT(h,b,o,x,aA)
local f=u(b,o)local n=Z(f)if n~=nil and aA~=nil then
aa(h,aA(n,f))return
end
R(h,f.dp,x,f)
end
local function aM(h,b,o,C,x)
local f=ah(b,o,C)aa(h,x(ae(f),f))
end
local function bf(n,x,g,b)
local h,ak,aj={},ao(n),d(b)=="table"and b.item_options or nil
for z,y in ipairs(ak)do
local a=e(aj,nil,g)if a.component==nil then
a.component=ai(z,b)end
if a.key==nil and a.preference==nil then
a.key=az(z,b,g)end
if a.field==nil and a.fields==nil and a.key~=nil then
a.field=a.key
end
M(h,x(y,a))end
return h
end
local function aO(n,x,b)
local h,ak,aj={},ao(n),d(b)=="table"and b.item_options or nil
for z,y in ipairs(ak)do
local a=e(aj,nil,nil)if a.phase==nil then
a.phase=aK(z,b)end
M(h,x(y,a))end
return h
end
local function aN(b,o,x)
local f
if d(b)=="table"then
f=u(b,o,true)else
f={dp=b}end
local h={}R(h,f.dp,x,f)return h
end
function s.dp_on_off(y,c,b)
local a=e(c,b,"switch")if a.name=="switch"and a.emit==nil then
a.emit=br.switch()end
return s.dp_binary(y,a)
end
function s.dp_temperature(y,c,b)
return j(y,"temperature",10,c,b)
end
function s.dp_humidity(y,c,b)
return j(y,"humidity",10,c,b)
end
function s.dp_child_lock(y,c,b)
return s.dp_binary(y,e(c,b,"child_lock"))
end
function s.dp_voltage(y,c,b)
return j(y,"voltage",10,c,b)
end
function s.dp_current(y,c,b)
return j(y,"current",1000,c,b)
end
function s.dp_power(y,c,b)
return ac(y,"power",10,c,b)
end
function s.dp_energy(y,c,b)
return j(y,"energy",100,c,b)
end
function s.dp_temperature_unit(y,c,b)
local a=e(c,b,"temperature_unit")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=q.temperature_unit()end
return s.dp_enum(y,a)
end
function s.dp_power_on_behavior(y,c,b)
local a=e(c,b,"power_on_behavior")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=q.power_on_behavior()end
return v(s.dp_enum(y,a),a)
end
function s.dp_backlight_mode_off_on(y,c,b)
local a=e(c,b,"backlight_mode")return v(s.dp_binary(y,a),a)
end
function s.dp_indicator_mode_none_relay_pos(y,c,b)
local a=e(c,b,"indicator_mode")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=q.indicator_mode_none_relay_pos()end
return v(s.dp_enum(y,a),a)
end
function s.dp_countdown(y,c,b)
return j(y,"countdown",1,c,b)
end
function s.dp_temperature_calibration(y,c,b)
return ab(y,"temperature_calibration",10,c,b)
end
end
return at
