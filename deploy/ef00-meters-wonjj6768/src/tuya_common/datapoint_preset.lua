local function as(A,aB,br)
br=br or{switch=function()return nil end}
local d,L,aS,k,bl,r=aB.type_check,aB.table_insert,aB.tonumber_check,aB.merge_options,aB.copy_keys,A.converter





local function ap(Y,I)
if d(Y)~="table"or d(I)~="table"then
return Y
end
for ar,P in pairs(I)do
if Y[ar]==nil then
Y[ar]=P
end
end
return Y
end
local function f(c,b,g)
local a={}if d(c)=="string"then
a.name=c
else
k(a,c)end
k(a,b)if a.name==nil and g~=nil then
a.name=g
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
return A.apply_fixed_send_policy(bg)
end
local function j(z,g,x,c,b)
local a=f(c,b,g)local y=a.scale
if y==nil then
y=x
end
if a.converter==nil and a.from_device==nil and a.to_device==nil and y~=1 then
a.converter=r.divide_by_pair(y)end
a.scale=nil
return A.dp_numeric(z,a)
end
local function ab(z,g,x,c,b)
local a=f(c,b,g)local y=a.scale
if y==nil then
y=x
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
local ao=r.power()local be=ao.from
if y~=1 then
a.from_device=r.pipe(be,r.divide_by(y))else
a.converter=ao
end
end
a.scale=nil
return A.dp_numeric(z,a)
end
local function aV(z,g,x,c,b)
local a=f(c,b,g)local y=a.scale
if y==nil then
y=x
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=r.signed_number_pair(y)end
if a.signed==nil then
a.signed=true
end
a.scale=nil
return A.dp_numeric(z,a)
end
local function aH(z,g,x,bc,c,b)
local a=f(c,b,g)local y=a.scale
if y==nil then
y=x
end
local bq=
a.datatype==A.DP_TYPE_RAW or
a.raw==true or
a.raw_bytes~=nil or
a.raw_length~=nil or
a.raw_from_tail~=nil or
a.raw_start~=nil or
a.raw_offset~=nil
if bq and a.converter==nil and a.from_device==nil and a.to_device==nil then
local aE={bytes=a.raw_bytes or a.raw_length,length=a.raw_length,from_tail=a.raw_from_tail,start=a.raw_start,offset=a.raw_offset}ap(aE,bc)a.converter=r.raw_uint_be(y,aE)if a.datatype==nil then
a.datatype=A.DP_TYPE_RAW
end
elseif a.converter==nil and a.from_device==nil and a.to_device==nil and y~=1 then
a.converter=r.divide_by_pair(y)end
a.scale=nil
a.raw=nil
a.raw_bytes=nil
a.raw_length=nil
a.raw_from_tail=nil
a.raw_start=nil
a.raw_offset=nil
return A.dp_numeric(z,a)
end
local function V(P,bo,bn)
local aA=aS(P)if aA==nil then
return nil
end
return bo+bn-aA
end
local function aU(z,g,I,c,b)
local a=f(c,b,g)local af=a.raw_min
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
local bi,bs=r.scale(af,ae,G,F),r.scale(G,F,af,ae)a.converter=r.from_to(
function(P,aY,aP)
local bp=bi(P,aY,aP)if bp==nil then
return nil
end
return V(bp,G,F)
end,
function(P,aY,aP)
local ba=V(P,G,F)if ba==nil then
return nil
end
return bs(ba,aY,aP)
end
)elseif af~=G or ae~=F then
a.converter=r.scale_pair(af,ae,G,F)end
end
a.raw_min=nil
a.raw_max=nil
a.value_min=nil
a.value_max=nil
a.invert=nil
a.invert_position=nil
return A.dp_numeric(z,a)
end
local function bj(phase,aZ)
if d(phase)=="string"and phase~=""then
return(aZ or"phase").."_"..phase
end
return aZ or"phase"
end
local function bb(bw,phase)
local bm={}for _,ar in ipairs(bw or{})do
local aI=ar
if d(phase)=="string"and phase~=""then
aI=ar.."_"..phase
end
bm[aI]=true
end
return bm
end
local function Q(z,g,aR,bh,c,b)
local aX=
d(c)=="string"or
(d(c)=="table"and c.name~=nil)or
(d(b)=="table"and b.name~=nil)local a=f(c,b,g)local phase=a.phase
if not aX and a.name==g then
a.name=bj(phase,g)end
if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=aR(a)end
if a.field==nil and a.fields==nil then
a.fields=bb(bh,phase)end
return A.dp_raw(z,a)
end
local function bd(z,c,b)
local a=f(c,b,"threshold")if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=r.threshold_parser()end
if a.field==nil and a.fields==nil then
a.fields={threshold_1=true,threshold_1_protection=true,threshold_1_value=true,threshold_2=true,threshold_2_protection=true,threshold_2_value=true}end
return A.dp_raw(z,a)
end
local function an(n)
if d(n)=="number"and n%1==0 and n>=0 then
return{n}end
if d(n)~="table"then
return{}end
local aJ={}for _,z in ipairs(n)do
if d(z)=="number"and z%1==0 and z>=0 then
L(aJ,z)end
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
local function ad(b)
local n=Z(b)if n~=nil then
return n
end
if d(b)~="table"then
return b
end
return b.dp
end
local function aK(w,b)
b=b or{}local aL=b.phases
if d(aL)~="table"then
aL=b.phase_names
end
local phase=d(aL)=="table"and aL[w]or nil
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
return D..tostring(w)end
return tostring(w)
end
local function ah(w,b)
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
if w==1 and J then
return O
end
local aC=J and(w-1+q)or(w+q)if aC<1 then
return b.default_component
end
return H..tostring(aC)
end
local function ay(w,b,aQ)
b=b or{}local J,W=b.first_is_main~=false,b.key_prefix

if d(W)~="string"or W==""then
W=aQ or"switch"end
local au=b.main_key
if d(au)~="string"or au==""then
au=W
end
local q=b.index_offset
if d(q)~="number"or q%1~=0 then
q=0
end
if w==1 and J then
return au
end
local aC=J and(w-1+q)or(w+q)if aC<1 then
return b.default_key
end
return W..tostring(aC)
end
local function R(h,z,v,b)
if d(z)~="number"or z%1~=0 or z<0 then
return
end
L(h,v(z,b))
end
local function aa(Y,bt)
if d(bt)~="table"then
return Y
end
for _,bv in ipairs(bt)do
L(Y,bv)end
return Y
end
local ak={"first_is_main","main_component","component_prefix","index_offset","default_component","key_prefix","main_key","default_key"}
local function ax(P)
return d(P)=="number"and P%1==0 and P>0
end
local function p(b,i)
local a={}if d(b)~="table"then
return a
end
for ar,P in pairs(b)do
local aF=true
if not i then
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
local w=1
while b[w]~=nil do
b[w]=nil
w=w+1
end
return b
end
local function t(b,o,i)
if d(b)~="table"then
return{}end
local s=b[o]if s==nil then
return p(b,i)end
local a=p(b,i)if d(s)=="table"then
k(a,s)else
a.dp=s
end
return a
end
local function u(s)
if s==nil then
return nil
end
if d(s)=="table"then
return s
end
return{dp=s}
end
local function U(b,o)
if d(b)~="table"then
return nil
end
return u(b[o])
end
local function av(at,e)
local K,C=d(at)=="table"and at.item_options or nil,d(e)=="table"and e.item_options or nil

if d(K)~="table"then
return d(C)=="table"and C or nil
end
if d(C)~="table"then
return K
end
local a={}k(a,K)k(a,C)return a
end
local function ag(b,o,B,i)
local a={}local s
if d(b)=="table"then
bl(a,b,ak)s=b[o]if d(s)=="table"then
k(a,p(b,i))if i and ac(s)then
E(a)end
k(a,s)elseif s~=nil then
k(a,p(b,i))if i then
E(a)end
a.dp=s
else
k(a,p(b,i))end
end
if a.key_prefix==nil and B~=nil then
a.key_prefix=B
end
a.item_options=av(b,s)return a
end
local function M(b,m)
local l,aq={},U(b,"config")k(l,aq)local aw=u(l[m])if aw~=nil then
l[m]=aw
else
local X=u(l.switch_type)if X==nil then
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
local function aW(b,m)
local a={}if d(b)=="table"then
k(a,b)end
local T=N(t(b,"switch_module"),m)if next(T)~=nil then
a.switch_module=T
end
return a
end
local function bk(h,b,o,v)
local e=t(b,o)R(h,e.dp,v,e)
end
local function aD(h,b,o,v,I)
local e=t(b,o)ap(e,I)R(h,e.dp,v,e)
end
local function aT(h,b,o,v,az)
local e=t(b,o)local n=Z(e)if n~=nil and az~=nil then
aa(h,az(n,e))return
end
R(h,e.dp,v,e)
end
local function aM(h,b,o,B,v)
local e=ag(b,o,B)aa(h,v(ad(e),e))
end
local function bf(n,v,g,b)
local h,aj,ai={},an(n),d(b)=="table"and b.item_options or nil
for w,z in ipairs(aj)do
local a=f(ai,nil,g)if a.component==nil then
a.component=ah(w,b)end
if a.key==nil and a.preference==nil then
a.key=ay(w,b,g)end
if a.field==nil and a.fields==nil and a.key~=nil then
a.field=a.key
end
L(h,v(z,a))end
return h
end
local function aO(n,v,b)
local h,aj,ai={},an(n),d(b)=="table"and b.item_options or nil
for w,z in ipairs(aj)do
local a=f(ai,nil,nil)if a.phase==nil then
a.phase=aK(w,b)end
L(h,v(z,a))end
return h
end
local function aN(b,o,v)
local e
if d(b)=="table"then
e=t(b,o,true)else
e={dp=b}end
local h={}R(h,e.dp,v,e)return h
end
function A.dp_on_off(z,c,b)
local a=f(c,b,"switch")if a.name=="switch"and a.emit==nil then
a.emit=br.switch()end
return A.dp_binary(z,a)
end
function A.dp_temperature(z,c,b)
return j(z,"temperature",10,c,b)
end
function A.dp_voltage(z,c,b)
return j(z,"voltage",10,c,b)
end
function A.dp_current(z,c,b)
return j(z,"current",1000,c,b)
end
function A.dp_power(z,c,b)
return ab(z,"power",10,c,b)
end
function A.dp_energy(z,c,b)
return j(z,"energy",100,c,b)
end
function A.dp_ac_frequency(z,c,b)
return j(z,"ac_frequency",100,c,b)
end
function A.dp_phase_variant2(z,c,b)
return Q(z,"phase",
function(a)
return r.phase_variant2_parser(a.phase,a.signed_power)
end,
{"voltage","current","power"},c,b)
end
function A.dp_phase_variant3(z,c,b)
return Q(z,"phase",
function(a)
return r.phase_variant3_parser(a.phase)
end,
{"voltage","current","power"},c,b)
end
function A.dp_power_factor(z,c,b)
local a=f(c,b,"power_factor")if a.read_only==nil then
a.read_only=true
end
return j(z,"power_factor",1,a)
end
end
return as
