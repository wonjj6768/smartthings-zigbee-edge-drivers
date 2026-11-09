local function au(u,aD,br)
br=br or{switch=function()return nil end}
local d,N,aT,k,bl,m=aD.type_check,aD.table_insert,aD.tonumber_check,aD.merge_options,aD.copy_keys,u.converter





local function ar(Z,K)
if d(Z)~="table"or d(K)~="table"then
return Z
end
for at,R in pairs(K)do
if Z[at]==nil then
Z[at]=R
end
end
return Z
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
for _,at in ipairs(an)do
if b[at]~=nil then
return true
end
end
return false
end
local function B(bg,b)
if am(b)then
return bg
end
return u.apply_fixed_send_policy(bg)
end
local function j(w,g,z,c,b)
local a=e(c,b,g)local A=a.scale
if A==nil then
A=z
end
if a.converter==nil and a.from_device==nil and a.to_device==nil and A~=1 then
a.converter=m.divide_by_pair(A)end
a.scale=nil
return u.dp_numeric(w,a)
end
local function ac(w,g,z,c,b)
local a=e(c,b,g)local A=a.scale
if A==nil then
A=z
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
local ap=m.power()local be=ap.from
if A~=1 then
a.from_device=m.pipe(be,m.divide_by(A))else
a.converter=ap
end
end
a.scale=nil
return u.dp_numeric(w,a)
end
local function aW(w,g,z,c,b)
local a=e(c,b,g)local A=a.scale
if A==nil then
A=z
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=m.signed_number_pair(A)end
if a.signed==nil then
a.signed=true
end
a.scale=nil
return u.dp_numeric(w,a)
end
local function aI(w,g,z,bd,c,b)
local a=e(c,b,g)local A=a.scale
if A==nil then
A=z
end
local bq=
a.datatype==u.DP_TYPE_RAW or
a.raw==true or
a.raw_bytes~=nil or
a.raw_length~=nil or
a.raw_from_tail~=nil or
a.raw_start~=nil or
a.raw_offset~=nil
if bq and a.converter==nil and a.from_device==nil and a.to_device==nil then
local aG={bytes=a.raw_bytes or a.raw_length,length=a.raw_length,from_tail=a.raw_from_tail,start=a.raw_start,offset=a.raw_offset}ar(aG,bd)a.converter=m.raw_uint_be(A,aG)if a.datatype==nil then
a.datatype=u.DP_TYPE_RAW
end
elseif a.converter==nil and a.from_device==nil and a.to_device==nil and A~=1 then
a.converter=m.divide_by_pair(A)end
a.scale=nil
a.raw=nil
a.raw_bytes=nil
a.raw_length=nil
a.raw_from_tail=nil
a.raw_start=nil
a.raw_offset=nil
return u.dp_numeric(w,a)
end
local function W(R,bo,bn)
local aC=aT(R)if aC==nil then
return nil
end
return bo+bn-aC
end
local function aV(w,g,K,c,b)
local a=e(c,b,g)local ag=a.raw_min
if ag==nil then
ag=K.raw_min
end
local af=a.raw_max
if af==nil then
af=K.raw_max
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
local bi,bs=m.scale(ag,af,I,H),m.scale(I,H,ag,af)a.converter=m.from_to(
function(R,aZ,aQ)
local bp=bi(R,aZ,aQ)if bp==nil then
return nil
end
return W(bp,I,H)
end,
function(R,aZ,aQ)
local bb=W(R,I,H)if bb==nil then
return nil
end
return bs(bb,aZ,aQ)
end
)elseif ag~=I or af~=H then
a.converter=m.scale_pair(ag,af,I,H)end
end
a.raw_min=nil
a.raw_max=nil
a.value_min=nil
a.value_max=nil
a.invert=nil
a.invert_position=nil
return u.dp_numeric(w,a)
end
local function bj(phase,ba)
if d(phase)=="string"and phase~=""then
return(ba or"phase").."_"..phase
end
return ba or"phase"
end
local function bc(bw,phase)
local bm={}for _,at in ipairs(bw or{})do
local aJ=at
if d(phase)=="string"and phase~=""then
aJ=at.."_"..phase
end
bm[aJ]=true
end
return bm
end
local function E(w,g,aS,bh,c,b)
local aY=
d(c)=="string"or
(d(c)=="table"and c.name~=nil)or
(d(b)=="table"and b.name~=nil)local a=e(c,b,g)local phase=a.phase
if not aY and a.name==g then
a.name=bj(phase,g)end
if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=aS(a)end
if a.field==nil and a.fields==nil then
a.fields=bc(bh,phase)end
return u.dp_raw(w,a)
end
local function aq(w,c,b)
local a=e(c,b,"threshold")if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=m.threshold_parser()end
if a.field==nil and a.fields==nil then
a.fields={threshold_1=true,threshold_1_protection=true,threshold_1_value=true,threshold_2=true,threshold_2_protection=true,threshold_2_value=true}end
return u.dp_raw(w,a)
end
local function ao(o)
if d(o)=="number"and o%1==0 and o>=0 then
return{o}end
if d(o)~="table"then
return{}end
local aK={}for _,w in ipairs(o)do
if d(w)=="number"and w%1==0 and w>=0 then
N(aK,w)end
end
return aK
end
local function aa(b)
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
local function ae(b)
local o=aa(b)if o~=nil then
return o
end
if d(b)~="table"then
return b
end
return b.dp
end
local function aL(y,b)
b=b or{}local aM=b.phases
if d(aM)~="table"then
aM=b.phase_names
end
local phase=d(aM)=="table"and aM[y]or nil
if d(phase)=="string"and phase~=""then
return phase
end
local F=b.phase_prefix
if F==false then
return nil
end
if d(F)~="string"or F==""then
F=nil
end
if F~=nil then
return F..tostring(y)end
return tostring(y)
end
local function ai(y,b)
b=b or{}local L,J=b.first_is_main~=false,b.component_prefix

if d(J)~="string"or J==""then
J="switch"end
local Q=b.main_component
if d(Q)~="string"or Q==""then
Q="main"end
local r=b.index_offset
if d(r)~="number"or r%1~=0 then
r=0
end
if y==1 and L then
return Q
end
local aE=L and(y-1+r)or(y+r)if aE<1 then
return b.default_component
end
return J..tostring(aE)
end
local function aA(y,b,aR)
b=b or{}local L,X=b.first_is_main~=false,b.key_prefix

if d(X)~="string"or X==""then
X=aR or"switch"end
local aw=b.main_key
if d(aw)~="string"or aw==""then
aw=X
end
local r=b.index_offset
if d(r)~="number"or r%1~=0 then
r=0
end
if y==1 and L then
return aw
end
local aE=L and(y-1+r)or(y+r)if aE<1 then
return b.default_key
end
return X..tostring(aE)
end
local function S(h,w,x,b)
if d(w)~="number"or w%1~=0 or w<0 then
return
end
N(h,x(w,b))
end
local function ab(Z,bt)
if d(bt)~="table"then
return Z
end
for _,bv in ipairs(bt)do
N(Z,bv)end
return Z
end
local al={"first_is_main","main_component","component_prefix","index_offset","default_component","key_prefix","main_key","default_key"}
local function az(R)
return d(R)=="number"and R%1==0 and R>0
end
local function q(b,i)
local a={}if d(b)~="table"then
return a
end
for at,R in pairs(b)do
local aH=true
if not i then
if at=="dp"or at=="dps"or at=="dp_list"then
aH=false
elseif az(at)then
aH=false
end
end
if aH then
a[at]=R
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
local function G(b)
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
local function t(b,p,i)
if d(b)~="table"then
return{}end
local s=b[p]if s==nil then
return q(b,i)end
local a=q(b,i)if d(s)=="table"then
k(a,s)else
a.dp=s
end
return a
end
local function v(s)
if s==nil then
return nil
end
if d(s)=="table"then
return s
end
return{dp=s}
end
local function V(b,p)
if d(b)~="table"then
return nil
end
return v(b[p])
end
local function ax(av,f)
local M,D=d(av)=="table"and av.item_options or nil,d(f)=="table"and f.item_options or nil

if d(M)~="table"then
return d(D)=="table"and D or nil
end
if d(D)~="table"then
return M
end
local a={}k(a,M)k(a,D)return a
end
local function ah(b,p,C,i)
local a={}local s
if d(b)=="table"then
bl(a,b,al)s=b[p]if d(s)=="table"then
k(a,q(b,i))if i and ad(s)then
G(a)end
k(a,s)elseif s~=nil then
k(a,q(b,i))if i then
G(a)end
a.dp=s
else
k(a,q(b,i))end
end
if a.key_prefix==nil and C~=nil then
a.key_prefix=C
end
a.item_options=ax(b,s)return a
end
local function O(b,n)
local l,as={},V(b,"config")k(l,as)local ay=v(l[n])if ay~=nil then
l[n]=ay
else
local Y=v(l.switch_type)if Y==nil then
Y=V(b,"switch_type")end
if d(Y)=="table"then
l[n]=Y
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
local function P(b,n)
local a={}if d(b)=="table"then
k(a,b)end
local l=O(b,n)if next(l)~=nil then
a.config=l
end
a.switch_type=nil
return a
end
local function aX(b,n)
local a={}if d(b)=="table"then
k(a,b)end
local U=P(t(b,"switch_module"),n)if next(U)~=nil then
a.switch_module=U
end
return a
end
local function bk(h,b,p,x)
local f=t(b,p)S(h,f.dp,x,f)
end
local function aF(h,b,p,x,K)
local f=t(b,p)ar(f,K)S(h,f.dp,x,f)
end
local function aU(h,b,p,x,aB)
local f=t(b,p)local o=aa(f)if o~=nil and aB~=nil then
ab(h,aB(o,f))return
end
S(h,f.dp,x,f)
end
local function aN(h,b,p,C,x)
local f=ah(b,p,C)ab(h,x(ae(f),f))
end
local function bf(o,x,g,b)
local h,ak,aj={},ao(o),d(b)=="table"and b.item_options or nil
for y,w in ipairs(ak)do
local a=e(aj,nil,g)if a.component==nil then
a.component=ai(y,b)end
if a.key==nil and a.preference==nil then
a.key=aA(y,b,g)end
if a.field==nil and a.fields==nil and a.key~=nil then
a.field=a.key
end
N(h,x(w,a))end
return h
end
local function aP(o,x,b)
local h,ak,aj={},ao(o),d(b)=="table"and b.item_options or nil
for y,w in ipairs(ak)do
local a=e(aj,nil,nil)if a.phase==nil then
a.phase=aL(y,b)end
N(h,x(w,a))end
return h
end
local function aO(b,p,x)
local f
if d(b)=="table"then
f=t(b,p,true)else
f={dp=b}end
local h={}S(h,f.dp,x,f)return h
end
function u.dp_on_off(w,c,b)
local a=e(c,b,"switch")if a.name=="switch"and a.emit==nil then
a.emit=br.switch()end
return u.dp_binary(w,a)
end
function u.dp_temperature(w,c,b)
return j(w,"temperature",10,c,b)
end
function u.dp_child_lock(w,c,b)
return u.dp_binary(w,e(c,b,"child_lock"))
end
function u.dp_voltage(w,c,b)
return j(w,"voltage",10,c,b)
end
function u.dp_current(w,c,b)
return j(w,"current",1000,c,b)
end
function u.dp_power(w,c,b)
return ac(w,"power",10,c,b)
end
function u.dp_energy(w,c,b)
return j(w,"energy",100,c,b)
end
function u.dp_ac_frequency(w,c,b)
return j(w,"ac_frequency",100,c,b)
end
function u.dp_phase_variant1(w,c,b)
return E(w,"phase",
function(a)
return m.phase_variant1_parser(a.phase)
end,
{"voltage","current"},c,b)
end
function u.dp_phase_variant2(w,c,b)
return E(w,"phase",
function(a)
return m.phase_variant2_parser(a.phase,a.signed_power)
end,
{"voltage","current","power"},c,b)
end
function u.dp_phase_variant3(w,c,b)
return E(w,"phase",
function(a)
return m.phase_variant3_parser(a.phase)
end,
{"voltage","current","power"},c,b)
end
function u.dp_threshold(w,c,b)
return aq(w,c,b)
end
function u.dp_power_on_behavior(w,c,b)
local a=e(c,b,"power_on_behavior")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=m.power_on_behavior()end
return B(u.dp_enum(w,a),a)
end
function u.dp_power_outage_memory(w,c,b)
local a=e(c,b,"power_outage_memory")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=m.power_outage_memory()end
return B(u.dp_enum(w,a),a)
end
function u.dp_power_factor(w,c,b)
local a=e(c,b,"power_factor")if a.read_only==nil then
a.read_only=true
end
return j(w,"power_factor",1,a)
end
end
return au
