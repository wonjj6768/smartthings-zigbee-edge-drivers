local function aq(O,az,br)
br=br or{switch=function()return nil end}
local c,I,aQ,j,bl,t=az.type_check,az.table_insert,az.tonumber_check,az.merge_options,az.copy_keys,O.converter





local function an(W,F)
if c(W)~="table"or c(F)~="table"then
return W
end
for ap,M in pairs(F)do
if W[ap]==nil then
W[ap]=M
end
end
return W
end
local function f(d,b,g)
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
return O.apply_fixed_send_policy(bg)
end
local function Y(N,g,w,d,b)
local a=f(d,b,g)local x=a.scale
if x==nil then
x=w
end
if a.converter==nil and a.from_device==nil and a.to_device==nil and x~=1 then
a.converter=t.divide_by_pair(x)end
a.scale=nil
return O.dp_numeric(N,a)
end
local function aV(N,g,w,d,b)
local a=f(d,b,g)local x=a.scale
if x==nil then
x=w
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
local am=t.power()local be=am.from
if x~=1 then
a.from_device=t.pipe(be,t.divide_by(x))else
a.converter=am
end
end
a.scale=nil
return O.dp_numeric(N,a)
end
local function aT(N,g,w,d,b)
local a=f(d,b,g)local x=a.scale
if x==nil then
x=w
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=t.signed_number_pair(x)end
if a.signed==nil then
a.signed=true
end
a.scale=nil
return O.dp_numeric(N,a)
end
local function aF(N,g,w,bb,d,b)
local a=f(d,b,g)local x=a.scale
if x==nil then
x=w
end
local bq=
a.datatype==O.DP_TYPE_RAW or
a.raw==true or
a.raw_bytes~=nil or
a.raw_length~=nil or
a.raw_from_tail~=nil or
a.raw_start~=nil or
a.raw_offset~=nil
if bq and a.converter==nil and a.from_device==nil and a.to_device==nil then
local aC={bytes=a.raw_bytes or a.raw_length,length=a.raw_length,from_tail=a.raw_from_tail,start=a.raw_start,offset=a.raw_offset}an(aC,bb)a.converter=t.raw_uint_be(x,aC)if a.datatype==nil then
a.datatype=O.DP_TYPE_RAW
end
elseif a.converter==nil and a.from_device==nil and a.to_device==nil and x~=1 then
a.converter=t.divide_by_pair(x)end
a.scale=nil
a.raw=nil
a.raw_bytes=nil
a.raw_length=nil
a.raw_from_tail=nil
a.raw_start=nil
a.raw_offset=nil
return O.dp_numeric(N,a)
end
local function T(M,bo,bn)
local ay=aQ(M)if ay==nil then
return nil
end
return bo+bn-ay
end
local function aS(N,g,F,d,b)
local a=f(d,b,g)local ad=a.raw_min
if ad==nil then
ad=F.raw_min
end
local ac=a.raw_max
if ac==nil then
ac=F.raw_max
end
local D=a.value_min
if D==nil then
D=F.value_min
end
local C=a.value_max
if C==nil then
C=F.value_max
end
local bu=a.invert==true or a.invert_position==true
if a.converter==nil and a.from_device==nil and a.to_device==nil then
if bu then
local bi,bs=t.scale(ad,ac,D,C),t.scale(D,C,ad,ac)a.converter=t.from_to(
function(M,aX,aN)
local bp=bi(M,aX,aN)if bp==nil then
return nil
end
return T(bp,D,C)
end,
function(M,aX,aN)
local aZ=T(M,D,C)if aZ==nil then
return nil
end
return bs(aZ,aX,aN)
end
)elseif ad~=D or ac~=C then
a.converter=t.scale_pair(ad,ac,D,C)end
end
a.raw_min=nil
a.raw_max=nil
a.value_min=nil
a.value_max=nil
a.invert=nil
a.invert_position=nil
return O.dp_numeric(N,a)
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
local function bc(N,g,aP,bh,d,b)
local aW=
c(d)=="string"or
(c(d)=="table"and d.name~=nil)or
(c(b)=="table"and b.name~=nil)local a=f(d,b,g)local phase=a.phase
if not aW and a.name==g then
a.name=bj(phase,g)end
if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=aP(a)end
if a.field==nil and a.fields==nil then
a.fields=ba(bh,phase)end
return O.dp_raw(N,a)
end
local function bd(N,d,b)
local a=f(d,b,"threshold")if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=t.threshold_parser()end
if a.field==nil and a.fields==nil then
a.fields={threshold_1=true,threshold_1_protection=true,threshold_1_value=true,threshold_2=true,threshold_2_protection=true,threshold_2_value=true}end
return O.dp_raw(N,a)
end
local function al(m)
if c(m)=="number"and m%1==0 and m>=0 then
return{m}end
if c(m)~="table"then
return{}end
local aH={}for _,N in ipairs(m)do
if c(N)=="number"and N%1==0 and N>=0 then
I(aH,N)end
end
return aH
end
local function X(b)
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
local m=X(b)if m~=nil then
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
local A=b.phase_prefix
if A==false then
return nil
end
if c(A)~="string"or A==""then
A=nil
end
if A~=nil then
return A..tostring(v)end
return tostring(v)
end
local function af(v,b)
b=b or{}local G,E=b.first_is_main~=false,b.component_prefix

if c(E)~="string"or E==""then
E="switch"end
local L=b.main_component
if c(L)~="string"or L==""then
L="main"end
local p=b.index_offset
if c(p)~="number"or p%1~=0 then
p=0
end
if v==1 and G then
return L
end
local aA=G and(v-1+p)or(v+p)if aA<1 then
return b.default_component
end
return E..tostring(aA)
end
local function aw(v,b,aO)
b=b or{}local G,U=b.first_is_main~=false,b.key_prefix

if c(U)~="string"or U==""then
U=aO or"switch"end
local as=b.main_key
if c(as)~="string"or as==""then
as=U
end
local p=b.index_offset
if c(p)~="number"or p%1~=0 then
p=0
end
if v==1 and G then
return as
end
local aA=G and(v-1+p)or(v+p)if aA<1 then
return b.default_key
end
return U..tostring(aA)
end
local function P(h,N,u,b)
if c(N)~="number"or N%1~=0 or N<0 then
return
end
I(h,u(N,b))
end
local function Z(W,bt)
if c(bt)~="table"then
return W
end
for _,bv in ipairs(bt)do
I(W,bv)end
return W
end
local ai={"first_is_main","main_component","component_prefix","index_offset","default_component","key_prefix","main_key","default_key"}
local function av(M)
return c(M)=="number"and M%1==0 and M>0
end
local function o(b,i)
local a={}if c(b)~="table"then
return a
end
for ap,M in pairs(b)do
local aD=true
if not i then
if ap=="dp"or ap=="dps"or ap=="dp_list"then
aD=false
elseif av(ap)then
aD=false
end
end
if aD then
a[ap]=M
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
local function B(b)
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
local function r(b,n,i)
if c(b)~="table"then
return{}end
local q=b[n]if q==nil then
return o(b,i)end
local a=o(b,i)if c(q)=="table"then
j(a,q)else
a.dp=q
end
return a
end
local function s(q)
if q==nil then
return nil
end
if c(q)=="table"then
return q
end
return{dp=q}
end
local function S(b,n)
if c(b)~="table"then
return nil
end
return s(b[n])
end
local function at(ar,e)
local H,z=c(ar)=="table"and ar.item_options or nil,c(e)=="table"and e.item_options or nil

if c(H)~="table"then
return c(z)=="table"and z or nil
end
if c(z)~="table"then
return H
end
local a={}j(a,H)j(a,z)return a
end
local function ae(b,n,y,i)
local a={}local q
if c(b)=="table"then
bl(a,b,ai)q=b[n]if c(q)=="table"then
j(a,o(b,i))if i and aa(q)then
B(a)end
j(a,q)elseif q~=nil then
j(a,o(b,i))if i then
B(a)end
a.dp=q
else
j(a,o(b,i))end
end
if a.key_prefix==nil and y~=nil then
a.key_prefix=y
end
a.item_options=at(b,q)return a
end
local function J(b,l)
local k,ao={},S(b,"config")j(k,ao)local au=s(k[l])if au~=nil then
k[l]=au
else
local V=s(k.switch_type)if V==nil then
V=S(b,"switch_type")end
if c(V)=="table"then
k[l]=V
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
local function K(b,l)
local a={}if c(b)=="table"then
j(a,b)end
local k=J(b,l)if next(k)~=nil then
a.config=k
end
a.switch_type=nil
return a
end
local function aU(b,l)
local a={}if c(b)=="table"then
j(a,b)end
local R=K(r(b,"switch_module"),l)if next(R)~=nil then
a.switch_module=R
end
return a
end
local function bk(h,b,n,u)
local e=r(b,n)P(h,e.dp,u,e)
end
local function aB(h,b,n,u,F)
local e=r(b,n)an(e,F)P(h,e.dp,u,e)
end
local function aR(h,b,n,u,ax)
local e=r(b,n)local m=X(e)if m~=nil and ax~=nil then
Z(h,ax(m,e))return
end
P(h,e.dp,u,e)
end
local function aK(h,b,n,y,u)
local e=ae(b,n,y)Z(h,u(ab(e),e))
end
local function bf(m,u,g,b)
local h,ah,ag={},al(m),c(b)=="table"and b.item_options or nil
for v,N in ipairs(ah)do
local a=f(ag,nil,g)if a.component==nil then
a.component=af(v,b)end
if a.key==nil and a.preference==nil then
a.key=aw(v,b,g)end
if a.field==nil and a.fields==nil and a.key~=nil then
a.field=a.key
end
I(h,u(N,a))end
return h
end
local function aM(m,u,b)
local h,ah,ag={},al(m),c(b)=="table"and b.item_options or nil
for v,N in ipairs(ah)do
local a=f(ag,nil,nil)if a.phase==nil then
a.phase=aI(v,b)end
I(h,u(N,a))end
return h
end
local function aL(b,n,u)
local e
if c(b)=="table"then
e=r(b,n,true)else
e={dp=b}end
local h={}P(h,e.dp,u,e)return h
end
function O.dp_on_off(N,d,b)
local a=f(d,b,"switch")if a.name=="switch"and a.emit==nil then
a.emit=br.switch()end
return O.dp_binary(N,a)
end
function O.dp_battery(N,d,b)
return Y(N,"battery",1,d,b)
end
function O.dp_presence(N,d,b)
return O.dp_binary(N,f(d,b,"presence"))
end
end
return aq
