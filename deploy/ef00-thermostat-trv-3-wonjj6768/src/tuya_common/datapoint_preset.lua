local function ar(w,aA,bt)
bt=bt or{switch=function()return nil end}
local d,L,aR,k,bl,u=aA.type_check,aA.table_insert,aA.tonumber_check,aA.merge_options,aA.copy_keys,w.converter





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
return w.apply_fixed_send_policy(bg)
end
local function g(y,h,z,c,b)
local a=e(c,b,h)local A=a.scale
if A==nil then
A=z
end
if a.converter==nil and a.from_device==nil and a.to_device==nil and A~=1 then
a.converter=u.divide_by_pair(A)end
a.scale=nil
return w.dp_numeric(y,a)
end
local function aV(y,h,z,c,b)
local a=e(c,b,h)local A=a.scale
if A==nil then
A=z
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
local an=u.power()local be=an.from
if A~=1 then
a.from_device=u.pipe(be,u.divide_by(A))else
a.converter=an
end
end
a.scale=nil
return w.dp_numeric(y,a)
end
local function aa(y,h,z,c,b)
local a=e(c,b,h)local A=a.scale
if A==nil then
A=z
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=u.signed_number_pair(A)end
if a.signed==nil then
a.signed=true
end
a.scale=nil
return w.dp_numeric(y,a)
end
local function aG(y,h,z,bb,c,b)
local a=e(c,b,h)local A=a.scale
if A==nil then
A=z
end
local bq=
a.datatype==w.DP_TYPE_RAW or
a.raw==true or
a.raw_bytes~=nil or
a.raw_length~=nil or
a.raw_from_tail~=nil or
a.raw_start~=nil or
a.raw_offset~=nil
if bq and a.converter==nil and a.from_device==nil and a.to_device==nil then
local aD={bytes=a.raw_bytes or a.raw_length,length=a.raw_length,from_tail=a.raw_from_tail,start=a.raw_start,offset=a.raw_offset}ao(aD,bb)a.converter=u.raw_uint_be(A,aD)if a.datatype==nil then
a.datatype=w.DP_TYPE_RAW
end
elseif a.converter==nil and a.from_device==nil and a.to_device==nil and A~=1 then
a.converter=u.divide_by_pair(A)end
a.scale=nil
a.raw=nil
a.raw_bytes=nil
a.raw_length=nil
a.raw_from_tail=nil
a.raw_start=nil
a.raw_offset=nil
return w.dp_numeric(y,a)
end
local function U(P,bo,bn)
local az=aR(P)if az==nil then
return nil
end
return bo+bn-az
end
local function aT(y,h,I,c,b)
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
local bi,br=u.scale(ae,ad,G,F),u.scale(G,F,ae,ad)a.converter=u.from_to(
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
a.converter=u.scale_pair(ae,ad,G,F)end
end
a.raw_min=nil
a.raw_max=nil
a.value_min=nil
a.value_max=nil
a.invert=nil
a.invert_position=nil
return w.dp_numeric(y,a)
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
local function bc(y,h,aQ,bh,c,b)
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
return w.dp_raw(y,a)
end
local function bd(y,c,b)
local a=e(c,b,"threshold")if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=u.threshold_parser()end
if a.field==nil and a.fields==nil then
a.fields={threshold_1=true,threshold_1_protection=true,threshold_1_value=true,threshold_2=true,threshold_2_protection=true,threshold_2_value=true}end
return w.dp_raw(y,a)
end
local function am(n)
if d(n)=="number"and n%1==0 and n>=0 then
return{n}end
if d(n)~="table"then
return{}end
local aI={}for _,y in ipairs(n)do
if d(y)=="number"and y%1==0 and y>=0 then
L(aI,y)end
end
return aI
end
local function Y(b)
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
local n=Y(b)if n~=nil then
return n
end
if d(b)~="table"then
return b
end
return b.dp
end
local function aJ(x,b)
b=b or{}local aK=b.phases
if d(aK)~="table"then
aK=b.phase_names
end
local phase=d(aK)=="table"and aK[x]or nil
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
return D..tostring(x)end
return tostring(x)
end
local function ag(x,b)
b=b or{}local J,H=b.first_is_main~=false,b.component_prefix

if d(H)~="string"or H==""then
H="switch"end
local O=b.main_component
if d(O)~="string"or O==""then
O="main"end
local q=b.index_offset
if d(q)~="number"or q%1~=0 then
q=0
end
if x==1 and J then
return O
end
local aB=J and(x-1+q)or(x+q)if aB<1 then
return b.default_component
end
return H..tostring(aB)
end
local function ax(x,b,aP)
b=b or{}local J,V=b.first_is_main~=false,b.key_prefix

if d(V)~="string"or V==""then
V=aP or"switch"end
local at=b.main_key
if d(at)~="string"or at==""then
at=V
end
local q=b.index_offset
if d(q)~="number"or q%1~=0 then
q=0
end
if x==1 and J then
return at
end
local aB=J and(x-1+q)or(x+q)if aB<1 then
return b.default_key
end
return V..tostring(aB)
end
local function Q(i,y,v,b)
if d(y)~="number"or y%1~=0 or y<0 then
return
end
L(i,v(y,b))
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
local function p(b,j)
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
local x=1
while b[x]~=nil do
b[x]=nil
x=x+1
end
return b
end
local function s(b,o,j)
if d(b)~="table"then
return{}end
local r=b[o]if r==nil then
return p(b,j)end
local a=p(b,j)if d(r)=="table"then
k(a,r)else
a.dp=r
end
return a
end
local function t(r)
if r==nil then
return nil
end
if d(r)=="table"then
return r
end
return{dp=r}
end
local function T(b,o)
if d(b)~="table"then
return nil
end
return t(b[o])
end
local function au(as,f)
local K,C=d(as)=="table"and as.item_options or nil,d(f)=="table"and f.item_options or nil

if d(K)~="table"then
return d(C)=="table"and C or nil
end
if d(C)~="table"then
return K
end
local a={}k(a,K)k(a,C)return a
end
local function af(b,o,B,j)
local a={}local r
if d(b)=="table"then
bl(a,b,aj)r=b[o]if d(r)=="table"then
k(a,p(b,j))if j and ab(r)then
E(a)end
k(a,r)elseif r~=nil then
k(a,p(b,j))if j then
E(a)end
a.dp=r
else
k(a,p(b,j))end
end
if a.key_prefix==nil and B~=nil then
a.key_prefix=B
end
a.item_options=au(b,r)return a
end
local function M(b,m)
local l,ap={},T(b,"config")k(l,ap)local av=t(l[m])if av~=nil then
l[m]=av
else
local W=t(l.switch_type)if W==nil then
W=T(b,"switch_type")end
if d(W)=="table"then
l[m]=W
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
local function aU(b,m)
local a={}if d(b)=="table"then
k(a,b)end
local S=N(s(b,"switch_module"),m)if next(S)~=nil then
a.switch_module=S
end
return a
end
local function bk(i,b,o,v)
local f=s(b,o)Q(i,f.dp,v,f)
end
local function aC(i,b,o,v,I)
local f=s(b,o)ao(f,I)Q(i,f.dp,v,f)
end
local function aS(i,b,o,v,ay)
local f=s(b,o)local n=Y(f)if n~=nil and ay~=nil then
Z(i,ay(n,f))return
end
Q(i,f.dp,v,f)
end
local function aL(i,b,o,B,v)
local f=af(b,o,B)Z(i,v(ac(f),f))
end
local function bf(n,v,h,b)
local i,ai,ah={},am(n),d(b)=="table"and b.item_options or nil
for x,y in ipairs(ai)do
local a=e(ah,nil,h)if a.component==nil then
a.component=ag(x,b)end
if a.key==nil and a.preference==nil then
a.key=ax(x,b,h)end
if a.field==nil and a.fields==nil and a.key~=nil then
a.field=a.key
end
L(i,v(y,a))end
return i
end
local function aN(n,v,b)
local i,ai,ah={},am(n),d(b)=="table"and b.item_options or nil
for x,y in ipairs(ai)do
local a=e(ah,nil,nil)if a.phase==nil then
a.phase=aJ(x,b)end
L(i,v(y,a))end
return i
end
local function aM(b,o,v)
local f
if d(b)=="table"then
f=s(b,o,true)else
f={dp=b}end
local i={}Q(i,f.dp,v,f)return i
end
function w.dp_battery(y,c,b)
return g(y,"battery",1,c,b)
end
function w.dp_child_lock(y,c,b)
return w.dp_binary(y,e(c,b,"child_lock"))
end
function w.dp_local_temperature(y,c,b)
return g(y,"local_temperature",10,c,b)
end
function w.dp_current_heating_setpoint(y,c,b)
return g(y,"current_heating_setpoint",10,c,b)
end
function w.dp_local_temperature_calibration(y,c,b)
return aa(y,"local_temperature_calibration",10,c,b)
end
function w.dp_open_window_temperature(y,c,b)
return g(y,"open_window_temperature",10,c,b)
end
function w.dp_comfort_temperature(y,c,b)
return g(y,"comfort_temperature",10,c,b)
end
function w.dp_eco_temperature(y,c,b)
return g(y,"eco_temperature",10,c,b)
end
function w.dp_holiday_temperature(y,c,b)
return g(y,"holiday_temperature",10,c,b)
end
function w.dp_max_temperature_limit(y,c,b)
return g(y,"max_temperature_limit",10,c,b)
end
function w.dp_min_temperature_limit(y,c,b)
return g(y,"min_temperature_limit",10,c,b)
end
function w.dp_system_mode(y,c,b)
return w.dp_enum(y,e(c,b,"system_mode"))
end
function w.dp_running_state(y,c,b)
return w.dp_enum(y,e(c,b,"running_state"))
end
end
return ar
