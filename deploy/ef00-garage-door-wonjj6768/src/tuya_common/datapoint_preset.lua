local function aq(H,az,br)
br=br or{switch=function()return nil end}
local c,L,aQ,j,bl,q=az.type_check,az.table_insert,az.tonumber_check,az.merge_options,az.copy_keys,H.converter





local function an(X,G)
if c(X)~="table"or c(G)~="table"then
return X
end
for ap,P in pairs(G)do
if X[ap]==nil then
X[ap]=P
end
end
return X
end
local function e(d,b,g)
local a={}if c(d)=="string"then
a.name=d
else
j(a,d)end
j(a,b)if a.name==nil and g~=nil then
a.name=g
end
return a
end
local ak={"send_policy","command_id","transaction","batch_key","match_transaction","response_dp","response_dps","match_response"}
local function aj(b)
if c(b)~="table"then
return false
end
for _,ap in ipairs(ak)do
if b[ap]~=nil then
return true
end
end
return false
end
local function aE(bg,b)
if aj(b)then
return bg
end
return H.apply_fixed_send_policy(bg)
end
local function A(J,g,w,d,b)
local a=e(d,b,g)local x=a.scale
if x==nil then
x=w
end
if a.converter==nil and a.from_device==nil and a.to_device==nil and x~=1 then
a.converter=q.divide_by_pair(x)end
a.scale=nil
return H.dp_numeric(J,a)
end
local function aV(J,g,w,d,b)
local a=e(d,b,g)local x=a.scale
if x==nil then
x=w
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
local am=q.power()local be=am.from
if x~=1 then
a.from_device=q.pipe(be,q.divide_by(x))else
a.converter=am
end
end
a.scale=nil
return H.dp_numeric(J,a)
end
local function aT(J,g,w,d,b)
local a=e(d,b,g)local x=a.scale
if x==nil then
x=w
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=q.signed_number_pair(x)end
if a.signed==nil then
a.signed=true
end
a.scale=nil
return H.dp_numeric(J,a)
end
local function aF(J,g,w,bb,d,b)
local a=e(d,b,g)local x=a.scale
if x==nil then
x=w
end
local bq=
a.datatype==H.DP_TYPE_RAW or
a.raw==true or
a.raw_bytes~=nil or
a.raw_length~=nil or
a.raw_from_tail~=nil or
a.raw_start~=nil or
a.raw_offset~=nil
if bq and a.converter==nil and a.from_device==nil and a.to_device==nil then
local aC={bytes=a.raw_bytes or a.raw_length,length=a.raw_length,from_tail=a.raw_from_tail,start=a.raw_start,offset=a.raw_offset}an(aC,bb)a.converter=q.raw_uint_be(x,aC)if a.datatype==nil then
a.datatype=H.DP_TYPE_RAW
end
elseif a.converter==nil and a.from_device==nil and a.to_device==nil and x~=1 then
a.converter=q.divide_by_pair(x)end
a.scale=nil
a.raw=nil
a.raw_bytes=nil
a.raw_length=nil
a.raw_from_tail=nil
a.raw_start=nil
a.raw_offset=nil
return H.dp_numeric(J,a)
end
local function U(P,bo,bn)
local ay=aQ(P)if ay==nil then
return nil
end
return bo+bn-ay
end
local function aS(J,g,G,d,b)
local a=e(d,b,g)local ad=a.raw_min
if ad==nil then
ad=G.raw_min
end
local ac=a.raw_max
if ac==nil then
ac=G.raw_max
end
local E=a.value_min
if E==nil then
E=G.value_min
end
local D=a.value_max
if D==nil then
D=G.value_max
end
local bu=a.invert==true or a.invert_position==true
if a.converter==nil and a.from_device==nil and a.to_device==nil then
if bu then
local bi,bs=q.scale(ad,ac,E,D),q.scale(E,D,ad,ac)a.converter=q.from_to(
function(P,aX,aN)
local bp=bi(P,aX,aN)if bp==nil then
return nil
end
return U(bp,E,D)
end,
function(P,aX,aN)
local aZ=U(P,E,D)if aZ==nil then
return nil
end
return bs(aZ,aX,aN)
end
)elseif ad~=E or ac~=D then
a.converter=q.scale_pair(ad,ac,E,D)end
end
a.raw_min=nil
a.raw_max=nil
a.value_min=nil
a.value_max=nil
a.invert=nil
a.invert_position=nil
return H.dp_numeric(J,a)
end
local function bj(phase,aY)
if c(phase)=="string"and phase~=""then
return(aY or"phase").."_"..phase
end
return aY or"phase"
end
local function ba(bw,phase)
local bm={}for _,ap in ipairs(bw or{})do
local aG=ap
if c(phase)=="string"and phase~=""then
aG=ap.."_"..phase
end
bm[aG]=true
end
return bm
end
local function bc(J,g,aP,bh,d,b)
local aW=
c(d)=="string"or
(c(d)=="table"and d.name~=nil)or
(c(b)=="table"and b.name~=nil)local a=e(d,b,g)local phase=a.phase
if not aW and a.name==g then
a.name=bj(phase,g)end
if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=aP(a)end
if a.field==nil and a.fields==nil then
a.fields=ba(bh,phase)end
return H.dp_raw(J,a)
end
local function bd(J,d,b)
local a=e(d,b,"threshold")if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=q.threshold_parser()end
if a.field==nil and a.fields==nil then
a.fields={threshold_1=true,threshold_1_protection=true,threshold_1_value=true,threshold_2=true,threshold_2_protection=true,threshold_2_value=true}end
return H.dp_raw(J,a)
end
local function al(m)
if c(m)=="number"and m%1==0 and m>=0 then
return{m}end
if c(m)~="table"then
return{}end
local aH={}for _,J in ipairs(m)do
if c(J)=="number"and J%1==0 and J>=0 then
L(aH,J)end
end
return aH
end
local function Y(b)
if c(b)~="table"then
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
local function ab(b)
local m=Y(b)if m~=nil then
return m
end
if c(b)~="table"then
return b
end
return b.dp
end
local function aI(v,b)
b=b or{}local aJ=b.phases
if c(aJ)~="table"then
aJ=b.phase_names
end
local phase=c(aJ)=="table"and aJ[v]or nil
if c(phase)=="string"and phase~=""then
return phase
end
local B=b.phase_prefix
if B==false then
return nil
end
if c(B)~="string"or B==""then
B=nil
end
if B~=nil then
return B..tostring(v)end
return tostring(v)
end
local function af(v,b)
b=b or{}local I,F=b.first_is_main~=false,b.component_prefix

if c(F)~="string"or F==""then
F="switch"end
local O=b.main_component
if c(O)~="string"or O==""then
O="main"end
local p=b.index_offset
if c(p)~="number"or p%1~=0 then
p=0
end
if v==1 and I then
return O
end
local aA=I and(v-1+p)or(v+p)if aA<1 then
return b.default_component
end
return F..tostring(aA)
end
local function aw(v,b,aO)
b=b or{}local I,V=b.first_is_main~=false,b.key_prefix

if c(V)~="string"or V==""then
V=aO or"switch"end
local as=b.main_key
if c(as)~="string"or as==""then
as=V
end
local p=b.index_offset
if c(p)~="number"or p%1~=0 then
p=0
end
if v==1 and I then
return as
end
local aA=I and(v-1+p)or(v+p)if aA<1 then
return b.default_key
end
return V..tostring(aA)
end
local function Q(h,J,u,b)
if c(J)~="number"or J%1~=0 or J<0 then
return
end
L(h,u(J,b))
end
local function Z(X,bt)
if c(bt)~="table"then
return X
end
for _,bv in ipairs(bt)do
L(X,bv)end
return X
end
local ai={"first_is_main","main_component","component_prefix","index_offset","default_component","key_prefix","main_key","default_key"}
local function av(P)
return c(P)=="number"and P%1==0 and P>0
end
local function o(b,i)
local a={}if c(b)~="table"then
return a
end
for ap,P in pairs(b)do
local aD=true
if not i then
if ap=="dp"or ap=="dps"or ap=="dp_list"then
aD=false
elseif av(ap)then
aD=false
end
end
if aD then
a[ap]=P
end
end
return a
end
local function aa(b)
if c(b)~="table"then
return false
end
if b.dp~=nil or b.dps~=nil or b.dp_list~=nil or b[1]~=nil then
return true
end
return false
end
local function C(b)
if c(b)~="table"then
return b
end
b.dp=nil
b.dps=nil
b.dp_list=nil
local v=1
while b[v]~=nil do
b[v]=nil
v=v+1
end
return b
end
local function s(b,n,i)
if c(b)~="table"then
return{}end
local r=b[n]if r==nil then
return o(b,i)end
local a=o(b,i)if c(r)=="table"then
j(a,r)else
a.dp=r
end
return a
end
local function t(r)
if r==nil then
return nil
end
if c(r)=="table"then
return r
end
return{dp=r}
end
local function T(b,n)
if c(b)~="table"then
return nil
end
return t(b[n])
end
local function at(ar,f)
local K,z=c(ar)=="table"and ar.item_options or nil,c(f)=="table"and f.item_options or nil

if c(K)~="table"then
return c(z)=="table"and z or nil
end
if c(z)~="table"then
return K
end
local a={}j(a,K)j(a,z)return a
end
local function ae(b,n,y,i)
local a={}local r
if c(b)=="table"then
bl(a,b,ai)r=b[n]if c(r)=="table"then
j(a,o(b,i))if i and aa(r)then
C(a)end
j(a,r)elseif r~=nil then
j(a,o(b,i))if i then
C(a)end
a.dp=r
else
j(a,o(b,i))end
end
if a.key_prefix==nil and y~=nil then
a.key_prefix=y
end
a.item_options=at(b,r)return a
end
local function M(b,l)
local k,ao={},T(b,"config")j(k,ao)local au=t(k[l])if au~=nil then
k[l]=au
else
local W=t(k.switch_type)if W==nil then
W=T(b,"switch_type")end
if c(W)=="table"then
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
local a={}if c(b)=="table"then
j(a,b)end
local k=M(b,l)if next(k)~=nil then
a.config=k
end
a.switch_type=nil
return a
end
local function aU(b,l)
local a={}if c(b)=="table"then
j(a,b)end
local S=N(s(b,"switch_module"),l)if next(S)~=nil then
a.switch_module=S
end
return a
end
local function bk(h,b,n,u)
local f=s(b,n)Q(h,f.dp,u,f)
end
local function aB(h,b,n,u,G)
local f=s(b,n)an(f,G)Q(h,f.dp,u,f)
end
local function aR(h,b,n,u,ax)
local f=s(b,n)local m=Y(f)if m~=nil and ax~=nil then
Z(h,ax(m,f))return
end
Q(h,f.dp,u,f)
end
local function aK(h,b,n,y,u)
local f=ae(b,n,y)Z(h,u(ab(f),f))
end
local function bf(m,u,g,b)
local h,ah,ag={},al(m),c(b)=="table"and b.item_options or nil
for v,J in ipairs(ah)do
local a=e(ag,nil,g)if a.component==nil then
a.component=af(v,b)end
if a.key==nil and a.preference==nil then
a.key=aw(v,b,g)end
if a.field==nil and a.fields==nil and a.key~=nil then
a.field=a.key
end
L(h,u(J,a))end
return h
end
local function aM(m,u,b)
local h,ah,ag={},al(m),c(b)=="table"and b.item_options or nil
for v,J in ipairs(ah)do
local a=e(ag,nil,nil)if a.phase==nil then
a.phase=aI(v,b)end
L(h,u(J,a))end
return h
end
local function aL(b,n,u)
local f
if c(b)=="table"then
f=s(b,n,true)else
f={dp=b}end
local h={}Q(h,f.dp,u,f)return h
end
function H.dp_on_off(J,d,b)
local a=e(d,b,"switch")if a.name=="switch"and a.emit==nil then
a.emit=br.switch()end
return H.dp_binary(J,a)
end
function H.dp_battery(J,d,b)
return A(J,"battery",1,d,b)
end
function H.dp_occupancy(J,d,b)
local a=e(d,b,"occupancy")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=q.true_false0()end
return H.dp_binary(J,a)
end
function H.dp_illuminance(J,d,b)
local a=e(d,b,"illuminance")return H.dp_numeric(J,a)
end
function H.dp_countdown(J,d,b)
return A(J,"countdown",1,d,b)
end
end
return aq
