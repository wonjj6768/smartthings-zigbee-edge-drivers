local function ar(q,aA,br)
br=br or{switch=function()return nil end}
local e,M,aQ,l,bl,k=aA.type_check,aA.table_insert,aA.tonumber_check,aA.merge_options,aA.copy_keys,q.converter





local function ao(Y,J)
if e(Y)~="table"or e(J)~="table"then
return Y
end
for aq,Q in pairs(J)do
if Y[aq]==nil then
Y[aq]=Q
end
end
return Y
end
local function d(c,b,g)
local a={}if e(c)=="string"then
a.name=c
else
l(a,c)end
l(a,b)if a.name==nil and g~=nil then
a.name=g
end
return a
end
local al={"send_policy","command_id","transaction","batch_key","match_transaction","response_dp","response_dps","match_response"}
local function ak(b)
if e(b)~="table"then
return false
end
for _,aq in ipairs(al)do
if b[aq]~=nil then
return true
end
end
return false
end
local function v(bg,b)
if ak(b)then
return bg
end
return q.apply_fixed_send_policy(bg)
end
local function j(w,g,A,c,b)
local a=d(c,b,g)local B=a.scale
if B==nil then
B=A
end
if a.converter==nil and a.from_device==nil and a.to_device==nil and B~=1 then
a.converter=k.divide_by_pair(B)end
a.scale=nil
return q.dp_numeric(w,a)
end
local function aV(w,g,A,c,b)
local a=d(c,b,g)local B=a.scale
if B==nil then
B=A
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
local an=k.power()local be=an.from
if B~=1 then
a.from_device=k.pipe(be,k.divide_by(B))else
a.converter=an
end
end
a.scale=nil
return q.dp_numeric(w,a)
end
local function aT(w,g,A,c,b)
local a=d(c,b,g)local B=a.scale
if B==nil then
B=A
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=k.signed_number_pair(B)end
if a.signed==nil then
a.signed=true
end
a.scale=nil
return q.dp_numeric(w,a)
end
local function aF(w,g,A,bb,c,b)
local a=d(c,b,g)local B=a.scale
if B==nil then
B=A
end
local bq=
a.datatype==q.DP_TYPE_RAW or
a.raw==true or
a.raw_bytes~=nil or
a.raw_length~=nil or
a.raw_from_tail~=nil or
a.raw_start~=nil or
a.raw_offset~=nil
if bq and a.converter==nil and a.from_device==nil and a.to_device==nil then
local aD={bytes=a.raw_bytes or a.raw_length,length=a.raw_length,from_tail=a.raw_from_tail,start=a.raw_start,offset=a.raw_offset}ao(aD,bb)a.converter=k.raw_uint_be(B,aD)if a.datatype==nil then
a.datatype=q.DP_TYPE_RAW
end
elseif a.converter==nil and a.from_device==nil and a.to_device==nil and B~=1 then
a.converter=k.divide_by_pair(B)end
a.scale=nil
a.raw=nil
a.raw_bytes=nil
a.raw_length=nil
a.raw_from_tail=nil
a.raw_start=nil
a.raw_offset=nil
return q.dp_numeric(w,a)
end
local function V(Q,bo,bn)
local az=aQ(Q)if az==nil then
return nil
end
return bo+bn-az
end
local function aS(w,g,J,c,b)
local a=d(c,b,g)local ae=a.raw_min
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
local bi,bs=k.scale(ae,ad,H,G),k.scale(H,G,ae,ad)a.converter=k.from_to(
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
a.converter=k.scale_pair(ae,ad,H,G)end
end
a.raw_min=nil
a.raw_max=nil
a.value_min=nil
a.value_max=nil
a.invert=nil
a.invert_position=nil
return q.dp_numeric(w,a)
end
local function bj(phase,aY)
if e(phase)=="string"and phase~=""then
return(aY or"phase").."_"..phase
end
return aY or"phase"
end
local function ba(bw,phase)
local bm={}for _,aq in ipairs(bw or{})do
local aG=aq
if e(phase)=="string"and phase~=""then
aG=aq.."_"..phase
end
bm[aG]=true
end
return bm
end
local function bc(w,g,aP,bh,c,b)
local aW=
e(c)=="string"or
(e(c)=="table"and c.name~=nil)or
(e(b)=="table"and b.name~=nil)local a=d(c,b,g)local phase=a.phase
if not aW and a.name==g then
a.name=bj(phase,g)end
if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=aP(a)end
if a.field==nil and a.fields==nil then
a.fields=ba(bh,phase)end
return q.dp_raw(w,a)
end
local function bd(w,c,b)
local a=d(c,b,"threshold")if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=k.threshold_parser()end
if a.field==nil and a.fields==nil then
a.fields={threshold_1=true,threshold_1_protection=true,threshold_1_value=true,threshold_2=true,threshold_2_protection=true,threshold_2_value=true}end
return q.dp_raw(w,a)
end
local function am(o)
if e(o)=="number"and o%1==0 and o>=0 then
return{o}end
if e(o)~="table"then
return{}end
local aH={}for _,w in ipairs(o)do
if e(w)=="number"and w%1==0 and w>=0 then
M(aH,w)end
end
return aH
end
local function Z(b)
if e(b)~="table"then
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
local o=Z(b)if o~=nil then
return o
end
if e(b)~="table"then
return b
end
return b.dp
end
local function aI(z,b)
b=b or{}local aJ=b.phases
if e(aJ)~="table"then
aJ=b.phase_names
end
local phase=e(aJ)=="table"and aJ[z]or nil
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
return E..tostring(z)end
return tostring(z)
end
local function ag(z,b)
b=b or{}local K,I=b.first_is_main~=false,b.component_prefix

if e(I)~="string"or I==""then
I="switch"end
local P=b.main_component
if e(P)~="string"or P==""then
P="main"end
local s=b.index_offset
if e(s)~="number"or s%1~=0 then
s=0
end
if z==1 and K then
return P
end
local aB=K and(z-1+s)or(z+s)if aB<1 then
return b.default_component
end
return I..tostring(aB)
end
local function ax(z,b,aO)
b=b or{}local K,W=b.first_is_main~=false,b.key_prefix

if e(W)~="string"or W==""then
W=aO or"switch"end
local at=b.main_key
if e(at)~="string"or at==""then
at=W
end
local s=b.index_offset
if e(s)~="number"or s%1~=0 then
s=0
end
if z==1 and K then
return at
end
local aB=K and(z-1+s)or(z+s)if aB<1 then
return b.default_key
end
return W..tostring(aB)
end
local function R(h,w,y,b)
if e(w)~="number"or w%1~=0 or w<0 then
return
end
M(h,y(w,b))
end
local function aa(Y,bt)
if e(bt)~="table"then
return Y
end
for _,bv in ipairs(bt)do
M(Y,bv)end
return Y
end
local aj={"first_is_main","main_component","component_prefix","index_offset","default_component","key_prefix","main_key","default_key"}
local function aw(Q)
return e(Q)=="number"and Q%1==0 and Q>0
end
local function r(b,i)
local a={}if e(b)~="table"then
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
local z=1
while b[z]~=nil do
b[z]=nil
z=z+1
end
return b
end
local function u(b,p,i)
if e(b)~="table"then
return{}end
local t=b[p]if t==nil then
return r(b,i)end
local a=r(b,i)if e(t)=="table"then
l(a,t)else
a.dp=t
end
return a
end
local function x(t)
if t==nil then
return nil
end
if e(t)=="table"then
return t
end
return{dp=t}
end
local function U(b,p)
if e(b)~="table"then
return nil
end
return x(b[p])
end
local function au(as,f)
local L,D=e(as)=="table"and as.item_options or nil,e(f)=="table"and f.item_options or nil

if e(L)~="table"then
return e(D)=="table"and D or nil
end
if e(D)~="table"then
return L
end
local a={}l(a,L)l(a,D)return a
end
local function af(b,p,C,i)
local a={}local t
if e(b)=="table"then
bl(a,b,aj)t=b[p]if e(t)=="table"then
l(a,r(b,i))if i and ab(t)then
F(a)end
l(a,t)elseif t~=nil then
l(a,r(b,i))if i then
F(a)end
a.dp=t
else
l(a,r(b,i))end
end
if a.key_prefix==nil and C~=nil then
a.key_prefix=C
end
a.item_options=au(b,t)return a
end
local function N(b,n)
local m,ap={},U(b,"config")l(m,ap)local av=x(m[n])if av~=nil then
m[n]=av
else
local X=x(m.switch_type)if X==nil then
X=U(b,"switch_type")end
if e(X)=="table"then
m[n]=X
end
end
if n~="switch_type"then
m.switch_type=nil
end
if next(m)~=nil then
return m
end
return{}
end
local function O(b,n)
local a={}if e(b)=="table"then
l(a,b)end
local m=N(b,n)if next(m)~=nil then
a.config=m
end
a.switch_type=nil
return a
end
local function aU(b,n)
local a={}if e(b)=="table"then
l(a,b)end
local T=O(u(b,"switch_module"),n)if next(T)~=nil then
a.switch_module=T
end
return a
end
local function bk(h,b,p,y)
local f=u(b,p)R(h,f.dp,y,f)
end
local function aC(h,b,p,y,J)
local f=u(b,p)ao(f,J)R(h,f.dp,y,f)
end
local function aR(h,b,p,y,ay)
local f=u(b,p)local o=Z(f)if o~=nil and ay~=nil then
aa(h,ay(o,f))return
end
R(h,f.dp,y,f)
end
local function aK(h,b,p,C,y)
local f=af(b,p,C)aa(h,y(ac(f),f))
end
local function bf(o,y,g,b)
local h,ai,ah={},am(o),e(b)=="table"and b.item_options or nil
for z,w in ipairs(ai)do
local a=d(ah,nil,g)if a.component==nil then
a.component=ag(z,b)end
if a.key==nil and a.preference==nil then
a.key=ax(z,b,g)end
if a.field==nil and a.fields==nil and a.key~=nil then
a.field=a.key
end
M(h,y(w,a))end
return h
end
local function aM(o,y,b)
local h,ai,ah={},am(o),e(b)=="table"and b.item_options or nil
for z,w in ipairs(ai)do
local a=d(ah,nil,nil)if a.phase==nil then
a.phase=aI(z,b)end
M(h,y(w,a))end
return h
end
local function aL(b,p,y)
local f
if e(b)=="table"then
f=u(b,p,true)else
f={dp=b}end
local h={}R(h,f.dp,y,f)return h
end
function q.dp_on_off(w,c,b)
local a=d(c,b,"switch")if a.name=="switch"and a.emit==nil then
a.emit=br.switch()end
return q.dp_binary(w,a)
end
function q.dp_temperature(w,c,b)
return j(w,"temperature",10,c,b)
end
function q.dp_humidity(w,c,b)
return j(w,"humidity",10,c,b)
end
function q.dp_battery(w,c,b)
return j(w,"battery",1,c,b)
end
function q.dp_contact(w,c,b)
return q.dp_binary(w,d(c,b,"contact"))
end
function q.dp_illuminance(w,c,b)
local a=d(c,b,"illuminance")return q.dp_numeric(w,a)
end
function q.dp_gas(w,c,b)
local a=d(c,b,"gas")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=k.true_false0()end
return q.dp_binary(w,a)
end
function q.dp_smoke(w,c,b)
local a=d(c,b,"smoke")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=k.true_false0()end
return q.dp_binary(w,a)
end
function q.dp_smoke_concentration(w,c,b)
return j(w,"smoke_concentration",10,c,b)
end
function q.dp_silence(w,c,b)
local a=d(c,b,"silence")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=k.true_false1()end
return v(q.dp_binary(w,a),a)
end
function q.dp_alarm_time(w,c,b)
return v(j(w,"alarm_time",1,c,b),d(c,b,"alarm_time"))
end
function q.dp_alarm_ringtone(w,c,b)
local a=d(c,b,"alarm_ringtone")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=k.alarm_ringtone_melody_five()end
return v(q.dp_enum(w,a),a)
end
function q.dp_tamper(w,c,b)
local a=d(c,b,"tamper")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=k.true_false1()end
return q.dp_binary(w,a)
end
function q.dp_battery_low(w,c,b)
local a=d(c,b,"battery_low")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=k.true_false0()end
return q.dp_binary(w,a)
end
function q.dp_carbon_monoxide(w,c,b)
local a=d(c,b,"carbon_monoxide")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=k.true_false0()end
return q.dp_binary(w,a)
end
function q.dp_co(w,c,b)
return j(w,"co",1,c,b)
end
function q.dp_water_leak(w,c,b)
local a=d(c,b,"water_leak")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=k.true_false0()end
return q.dp_binary(w,a)
end
end
return ar
