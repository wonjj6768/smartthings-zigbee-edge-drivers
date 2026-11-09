local function as(I,aB,br)
br=br or{switch=function()return nil end}
local d,L,aS,j,bl,r=aB.type_check,aB.table_insert,aB.tonumber_check,aB.merge_options,aB.copy_keys,I.converter





local function ap(X,H)
if d(X)~="table"or d(H)~="table"then
return X
end
for ar,P in pairs(H)do
if X[ar]==nil then
X[ar]=P
end
end
return X
end
local function f(c,b,g)
local a={}if d(c)=="string"then
a.name=c
else
j(a,c)end
j(a,b)if a.name==nil and g~=nil then
a.name=g
end
return a
end
local al={"send_policy","command_id","transaction","batch_key","match_transaction","response_dp","response_dps","match_response"}
local function ak(b)
if d(b)~="table"then
return false
end
for _,ar in ipairs(al)do
if b[ar]~=nil then
return true
end
end
return false
end
local function aG(bg,b)
if ak(b)then
return bg
end
return I.apply_fixed_send_policy(bg)
end
local function q(B,g,x,c,b)
local a=f(c,b,g)local y=a.scale
if y==nil then
y=x
end
if a.converter==nil and a.from_device==nil and a.to_device==nil and y~=1 then
a.converter=r.divide_by_pair(y)end
a.scale=nil
return I.dp_numeric(B,a)
end
local function aa(B,g,x,c,b)
local a=f(c,b,g)local y=a.scale
if y==nil then
y=x
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
local an=r.power()local be=an.from
if y~=1 then
a.from_device=r.pipe(be,r.divide_by(y))else
a.converter=an
end
end
a.scale=nil
return I.dp_numeric(B,a)
end
local function aV(B,g,x,c,b)
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
return I.dp_numeric(B,a)
end
local function aH(B,g,x,bc,c,b)
local a=f(c,b,g)local y=a.scale
if y==nil then
y=x
end
local bq=
a.datatype==I.DP_TYPE_RAW or
a.raw==true or
a.raw_bytes~=nil or
a.raw_length~=nil or
a.raw_from_tail~=nil or
a.raw_start~=nil or
a.raw_offset~=nil
if bq and a.converter==nil and a.from_device==nil and a.to_device==nil then
local aE={bytes=a.raw_bytes or a.raw_length,length=a.raw_length,from_tail=a.raw_from_tail,start=a.raw_start,offset=a.raw_offset}ap(aE,bc)a.converter=r.raw_uint_be(y,aE)if a.datatype==nil then
a.datatype=I.DP_TYPE_RAW
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
return I.dp_numeric(B,a)
end
local function U(P,bo,bn)
local aA=aS(P)if aA==nil then
return nil
end
return bo+bn-aA
end
local function aU(B,g,H,c,b)
local a=f(c,b,g)local ae=a.raw_min
if ae==nil then
ae=H.raw_min
end
local ad=a.raw_max
if ad==nil then
ad=H.raw_max
end
local F=a.value_min
if F==nil then
F=H.value_min
end
local E=a.value_max
if E==nil then
E=H.value_max
end
local bu=a.invert==true or a.invert_position==true
if a.converter==nil and a.from_device==nil and a.to_device==nil then
if bu then
local bi,bs=r.scale(ae,ad,F,E),r.scale(F,E,ae,ad)a.converter=r.from_to(
function(P,aY,aP)
local bp=bi(P,aY,aP)if bp==nil then
return nil
end
return U(bp,F,E)
end,
function(P,aY,aP)
local ba=U(P,F,E)if ba==nil then
return nil
end
return bs(ba,aY,aP)
end
)elseif ae~=F or ad~=E then
a.converter=r.scale_pair(ae,ad,F,E)end
end
a.raw_min=nil
a.raw_max=nil
a.value_min=nil
a.value_max=nil
a.invert=nil
a.invert_position=nil
return I.dp_numeric(B,a)
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
local function ao(B,g,aR,bh,c,b)
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
return I.dp_raw(B,a)
end
local function bd(B,c,b)
local a=f(c,b,"threshold")if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=r.threshold_parser()end
if a.field==nil and a.fields==nil then
a.fields={threshold_1=true,threshold_1_protection=true,threshold_1_value=true,threshold_2=true,threshold_2_protection=true,threshold_2_value=true}end
return I.dp_raw(B,a)
end
local function am(m)
if d(m)=="number"and m%1==0 and m>=0 then
return{m}end
if d(m)~="table"then
return{}end
local aJ={}for _,B in ipairs(m)do
if d(B)=="number"and B%1==0 and B>=0 then
L(aJ,B)end
end
return aJ
end
local function Y(b)
if d(b)~="table"then
return b
end
local m=b.dps
if m==nil then
m=b.dp_list
end
if m==nil and b[1]~=nil then
m=b
end
return m
end
local function ac(b)
local m=Y(b)if m~=nil then
return m
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
local C=b.phase_prefix
if C==false then
return nil
end
if d(C)~="string"or C==""then
C=nil
end
if C~=nil then
return C..tostring(w)end
return tostring(w)
end
local function ag(w,b)
b=b or{}local J,G=b.first_is_main~=false,b.component_prefix

if d(G)~="string"or G==""then
G="switch"end
local O=b.main_component
if d(O)~="string"or O==""then
O="main"end
local p=b.index_offset
if d(p)~="number"or p%1~=0 then
p=0
end
if w==1 and J then
return O
end
local aC=J and(w-1+p)or(w+p)if aC<1 then
return b.default_component
end
return G..tostring(aC)
end
local function ay(w,b,aQ)
b=b or{}local J,V=b.first_is_main~=false,b.key_prefix

if d(V)~="string"or V==""then
V=aQ or"switch"end
local au=b.main_key
if d(au)~="string"or au==""then
au=V
end
local p=b.index_offset
if d(p)~="number"or p%1~=0 then
p=0
end
if w==1 and J then
return au
end
local aC=J and(w-1+p)or(w+p)if aC<1 then
return b.default_key
end
return V..tostring(aC)
end
local function Q(h,B,v,b)
if d(B)~="number"or B%1~=0 or B<0 then
return
end
L(h,v(B,b))
end
local function Z(X,bt)
if d(bt)~="table"then
return X
end
for _,bv in ipairs(bt)do
L(X,bv)end
return X
end
local aj={"first_is_main","main_component","component_prefix","index_offset","default_component","key_prefix","main_key","default_key"}
local function ax(P)
return d(P)=="number"and P%1==0 and P>0
end
local function o(b,i)
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
local function ab(b)
if d(b)~="table"then
return false
end
if b.dp~=nil or b.dps~=nil or b.dp_list~=nil or b[1]~=nil then
return true
end
return false
end
local function D(b)
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
local function t(b,n,i)
if d(b)~="table"then
return{}end
local s=b[n]if s==nil then
return o(b,i)end
local a=o(b,i)if d(s)=="table"then
j(a,s)else
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
local function T(b,n)
if d(b)~="table"then
return nil
end
return u(b[n])
end
local function av(at,e)
local K,A=d(at)=="table"and at.item_options or nil,d(e)=="table"and e.item_options or nil

if d(K)~="table"then
return d(A)=="table"and A or nil
end
if d(A)~="table"then
return K
end
local a={}j(a,K)j(a,A)return a
end
local function af(b,n,z,i)
local a={}local s
if d(b)=="table"then
bl(a,b,aj)s=b[n]if d(s)=="table"then
j(a,o(b,i))if i and ab(s)then
D(a)end
j(a,s)elseif s~=nil then
j(a,o(b,i))if i then
D(a)end
a.dp=s
else
j(a,o(b,i))end
end
if a.key_prefix==nil and z~=nil then
a.key_prefix=z
end
a.item_options=av(b,s)return a
end
local function M(b,l)
local k,aq={},T(b,"config")j(k,aq)local aw=u(k[l])if aw~=nil then
k[l]=aw
else
local W=u(k.switch_type)if W==nil then
W=T(b,"switch_type")end
if d(W)=="table"then
k[l]=W
end
end
if l~="switch_type"then
k.switch_type=nil
end
if next(k)~=nil then
return k
end
return{}
end
local function N(b,l)
local a={}if d(b)=="table"then
j(a,b)end
local k=M(b,l)if next(k)~=nil then
a.config=k
end
a.switch_type=nil
return a
end
local function aW(b,l)
local a={}if d(b)=="table"then
j(a,b)end
local S=N(t(b,"switch_module"),l)if next(S)~=nil then
a.switch_module=S
end
return a
end
local function bk(h,b,n,v)
local e=t(b,n)Q(h,e.dp,v,e)
end
local function aD(h,b,n,v,H)
local e=t(b,n)ap(e,H)Q(h,e.dp,v,e)
end
local function aT(h,b,n,v,az)
local e=t(b,n)local m=Y(e)if m~=nil and az~=nil then
Z(h,az(m,e))return
end
Q(h,e.dp,v,e)
end
local function aM(h,b,n,z,v)
local e=af(b,n,z)Z(h,v(ac(e),e))
end
local function bf(m,v,g,b)
local h,ai,ah={},am(m),d(b)=="table"and b.item_options or nil
for w,B in ipairs(ai)do
local a=f(ah,nil,g)if a.component==nil then
a.component=ag(w,b)end
if a.key==nil and a.preference==nil then
a.key=ay(w,b,g)end
if a.field==nil and a.fields==nil and a.key~=nil then
a.field=a.key
end
L(h,v(B,a))end
return h
end
local function aO(m,v,b)
local h,ai,ah={},am(m),d(b)=="table"and b.item_options or nil
for w,B in ipairs(ai)do
local a=f(ah,nil,nil)if a.phase==nil then
a.phase=aK(w,b)end
L(h,v(B,a))end
return h
end
local function aN(b,n,v)
local e
if d(b)=="table"then
e=t(b,n,true)else
e={dp=b}end
local h={}Q(h,e.dp,v,e)return h
end
function I.dp_on_off(B,c,b)
local a=f(c,b,"switch")if a.name=="switch"and a.emit==nil then
a.emit=br.switch()end
return I.dp_binary(B,a)
end
function I.dp_temperature(B,c,b)
return q(B,"temperature",10,c,b)
end
function I.dp_voltage(B,c,b)
return q(B,"voltage",10,c,b)
end
function I.dp_current(B,c,b)
return q(B,"current",1000,c,b)
end
function I.dp_power(B,c,b)
return aa(B,"power",10,c,b)
end
function I.dp_energy(B,c,b)
return q(B,"energy",100,c,b)
end
function I.dp_phase_variant2(B,c,b)
return ao(B,"phase",
function(a)
return r.phase_variant2_parser(a.phase,a.signed_power)
end,
{"voltage","current","power"},c,b)
end
end
return as
