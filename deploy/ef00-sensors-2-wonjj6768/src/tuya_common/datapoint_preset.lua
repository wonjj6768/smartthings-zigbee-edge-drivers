local function ar(J,aA,bt)
bt=bt or{switch=function()return nil end}
local d,M,aR,k,bl,u=aA.type_check,aA.table_insert,aA.tonumber_check,aA.merge_options,aA.copy_keys,J.converter





local function ao(Y,I)
if d(Y)~="table"or d(I)~="table"then
return Y
end
for aq,Q in pairs(I)do
if Y[aq]==nil then
Y[aq]=Q
end
end
return Y
end
local function g(c,b,f)
local a={}if d(c)=="string"then
a.name=c
else
k(a,c)end
k(a,b)if a.name==nil and f~=nil then
a.name=f
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
return J.apply_fixed_send_policy(bg)
end
local function j(B,f,x,c,b)
local a=g(c,b,f)local y=a.scale
if y==nil then
y=x
end
if a.converter==nil and a.from_device==nil and a.to_device==nil and y~=1 then
a.converter=u.divide_by_pair(y)end
a.scale=nil
return J.dp_numeric(B,a)
end
local function aV(B,f,x,c,b)
local a=g(c,b,f)local y=a.scale
if y==nil then
y=x
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
local an=u.power()local be=an.from
if y~=1 then
a.from_device=u.pipe(be,u.divide_by(y))else
a.converter=an
end
end
a.scale=nil
return J.dp_numeric(B,a)
end
local function D(B,f,x,c,b)
local a=g(c,b,f)local y=a.scale
if y==nil then
y=x
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=u.signed_number_pair(y)end
if a.signed==nil then
a.signed=true
end
a.scale=nil
return J.dp_numeric(B,a)
end
local function aG(B,f,x,bb,c,b)
local a=g(c,b,f)local y=a.scale
if y==nil then
y=x
end
local bq=
a.datatype==J.DP_TYPE_RAW or
a.raw==true or
a.raw_bytes~=nil or
a.raw_length~=nil or
a.raw_from_tail~=nil or
a.raw_start~=nil or
a.raw_offset~=nil
if bq and a.converter==nil and a.from_device==nil and a.to_device==nil then
local aD={bytes=a.raw_bytes or a.raw_length,length=a.raw_length,from_tail=a.raw_from_tail,start=a.raw_start,offset=a.raw_offset}ao(aD,bb)a.converter=u.raw_uint_be(y,aD)if a.datatype==nil then
a.datatype=J.DP_TYPE_RAW
end
elseif a.converter==nil and a.from_device==nil and a.to_device==nil and y~=1 then
a.converter=u.divide_by_pair(y)end
a.scale=nil
a.raw=nil
a.raw_bytes=nil
a.raw_length=nil
a.raw_from_tail=nil
a.raw_start=nil
a.raw_offset=nil
return J.dp_numeric(B,a)
end
local function V(Q,bo,bn)
local az=aR(Q)if az==nil then
return nil
end
return bo+bn-az
end
local function aT(B,f,I,c,b)
local a=g(c,b,f)local ae=a.raw_min
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
function(Q,aX,aO)
local bp=bi(Q,aX,aO)if bp==nil then
return nil
end
return V(bp,G,F)
end,
function(Q,aX,aO)
local aZ=V(Q,G,F)if aZ==nil then
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
return J.dp_numeric(B,a)
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
local function bc(B,f,aQ,bh,c,b)
local aW=
d(c)=="string"or
(d(c)=="table"and c.name~=nil)or
(d(b)=="table"and b.name~=nil)local a=g(c,b,f)local phase=a.phase
if not aW and a.name==f then
a.name=bj(phase,f)end
if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=aQ(a)end
if a.field==nil and a.fields==nil then
a.fields=ba(bh,phase)end
return J.dp_raw(B,a)
end
local function bd(B,c,b)
local a=g(c,b,"threshold")if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=u.threshold_parser()end
if a.field==nil and a.fields==nil then
a.fields={threshold_1=true,threshold_1_protection=true,threshold_1_value=true,threshold_2=true,threshold_2_protection=true,threshold_2_value=true}end
return J.dp_raw(B,a)
end
local function am(n)
if d(n)=="number"and n%1==0 and n>=0 then
return{n}end
if d(n)~="table"then
return{}end
local aI={}for _,B in ipairs(n)do
if d(B)=="number"and B%1==0 and B>=0 then
M(aI,B)end
end
return aI
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
local function ac(b)
local n=Z(b)if n~=nil then
return n
end
if d(b)~="table"then
return b
end
return b.dp
end
local function aJ(w,b)
b=b or{}local aK=b.phases
if d(aK)~="table"then
aK=b.phase_names
end
local phase=d(aK)=="table"and aK[w]or nil
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
b=b or{}local K,H=b.first_is_main~=false,b.component_prefix

if d(H)~="string"or H==""then
H="switch"end
local P=b.main_component
if d(P)~="string"or P==""then
P="main"end
local q=b.index_offset
if d(q)~="number"or q%1~=0 then
q=0
end
if w==1 and K then
return P
end
local aB=K and(w-1+q)or(w+q)if aB<1 then
return b.default_component
end
return H..tostring(aB)
end
local function ax(w,b,aP)
b=b or{}local K,W=b.first_is_main~=false,b.key_prefix

if d(W)~="string"or W==""then
W=aP or"switch"end
local at=b.main_key
if d(at)~="string"or at==""then
at=W
end
local q=b.index_offset
if d(q)~="number"or q%1~=0 then
q=0
end
if w==1 and K then
return at
end
local aB=K and(w-1+q)or(w+q)if aB<1 then
return b.default_key
end
return W..tostring(aB)
end
local function R(h,B,v,b)
if d(B)~="number"or B%1~=0 or B<0 then
return
end
M(h,v(B,b))
end
local function aa(Y,bs)
if d(bs)~="table"then
return Y
end
for _,bv in ipairs(bs)do
M(Y,bv)end
return Y
end
local aj={"first_is_main","main_component","component_prefix","index_offset","default_component","key_prefix","main_key","default_key"}
local function aw(Q)
return d(Q)=="number"and Q%1==0 and Q>0
end
local function p(b,i)
local a={}if d(b)~="table"then
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
local function s(b,o,i)
if d(b)~="table"then
return{}end
local r=b[o]if r==nil then
return p(b,i)end
local a=p(b,i)if d(r)=="table"then
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
local function U(b,o)
if d(b)~="table"then
return nil
end
return t(b[o])
end
local function au(as,e)
local L,A=d(as)=="table"and as.item_options or nil,d(e)=="table"and e.item_options or nil

if d(L)~="table"then
return d(A)=="table"and A or nil
end
if d(A)~="table"then
return L
end
local a={}k(a,L)k(a,A)return a
end
local function af(b,o,z,i)
local a={}local r
if d(b)=="table"then
bl(a,b,aj)r=b[o]if d(r)=="table"then
k(a,p(b,i))if i and ab(r)then
E(a)end
k(a,r)elseif r~=nil then
k(a,p(b,i))if i then
E(a)end
a.dp=r
else
k(a,p(b,i))end
end
if a.key_prefix==nil and z~=nil then
a.key_prefix=z
end
a.item_options=au(b,r)return a
end
local function N(b,m)
local l,ap={},U(b,"config")k(l,ap)local av=t(l[m])if av~=nil then
l[m]=av
else
local X=t(l.switch_type)if X==nil then
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
local function aU(b,m)
local a={}if d(b)=="table"then
k(a,b)end
local T=O(s(b,"switch_module"),m)if next(T)~=nil then
a.switch_module=T
end
return a
end
local function bk(h,b,o,v)
local e=s(b,o)R(h,e.dp,v,e)
end
local function aC(h,b,o,v,I)
local e=s(b,o)ao(e,I)R(h,e.dp,v,e)
end
local function aS(h,b,o,v,ay)
local e=s(b,o)local n=Z(e)if n~=nil and ay~=nil then
aa(h,ay(n,e))return
end
R(h,e.dp,v,e)
end
local function aL(h,b,o,z,v)
local e=af(b,o,z)aa(h,v(ac(e),e))
end
local function bf(n,v,f,b)
local h,ai,ah={},am(n),d(b)=="table"and b.item_options or nil
for w,B in ipairs(ai)do
local a=g(ah,nil,f)if a.component==nil then
a.component=ag(w,b)end
if a.key==nil and a.preference==nil then
a.key=ax(w,b,f)end
if a.field==nil and a.fields==nil and a.key~=nil then
a.field=a.key
end
M(h,v(B,a))end
return h
end
local function aN(n,v,b)
local h,ai,ah={},am(n),d(b)=="table"and b.item_options or nil
for w,B in ipairs(ai)do
local a=g(ah,nil,nil)if a.phase==nil then
a.phase=aJ(w,b)end
M(h,v(B,a))end
return h
end
local function aM(b,o,v)
local e
if d(b)=="table"then
e=s(b,o,true)else
e={dp=b}end
local h={}R(h,e.dp,v,e)return h
end
function J.dp_temperature(B,c,b)
return j(B,"temperature",10,c,b)
end
function J.dp_humidity(B,c,b)
return j(B,"humidity",10,c,b)
end
function J.dp_battery(B,c,b)
return j(B,"battery",1,c,b)
end
function J.dp_temperature_calibration(B,c,b)
return D(B,"temperature_calibration",10,c,b)
end
function J.dp_humidity_calibration(B,c,b)
return D(B,"humidity_calibration",1,c,b)
end
function J.dp_co2(B,c,b)
return j(B,"co2",1,c,b)
end
function J.dp_voc(B,c,b)
return j(B,"voc",1,c,b)
end
function J.dp_formaldehyde(B,c,b)
return j(B,"formaldehyde",1,c,b)
end
end
return ar
