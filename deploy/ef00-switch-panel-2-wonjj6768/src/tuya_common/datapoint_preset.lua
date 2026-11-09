local function ap(X,ay,br)
br=br or{switch=function()return nil end}
local c,I,aQ,j,bl,t=ay.type_check,ay.table_insert,ay.tonumber_check,ay.merge_options,ay.copy_keys,X.converter





local function am(V,F)
if c(V)~="table"or c(F)~="table"then
return V
end
for ao,M in pairs(F)do
if V[ao]==nil then
V[ao]=M
end
end
return V
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
local aj={"send_policy","command_id","transaction","batch_key","match_transaction","response_dp","response_dps","match_response"}
local function ai(b)
if c(b)~="table"then
return false
end
for _,ao in ipairs(aj)do
if b[ao]~=nil then
return true
end
end
return false
end
local function aD(bg,b)
if ai(b)then
return bg
end
return X.apply_fixed_send_policy(bg)
end
local function aL(R,g,w,d,b)
local a=f(d,b,g)local x=a.scale
if x==nil then
x=w
end
if a.converter==nil and a.from_device==nil and a.to_device==nil and x~=1 then
a.converter=t.divide_by_pair(x)end
a.scale=nil
return X.dp_numeric(R,a)
end
local function aV(R,g,w,d,b)
local a=f(d,b,g)local x=a.scale
if x==nil then
x=w
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
local al=t.power()local be=al.from
if x~=1 then
a.from_device=t.pipe(be,t.divide_by(x))else
a.converter=al
end
end
a.scale=nil
return X.dp_numeric(R,a)
end
local function aT(R,g,w,d,b)
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
return X.dp_numeric(R,a)
end
local function aE(R,g,w,bb,d,b)
local a=f(d,b,g)local x=a.scale
if x==nil then
x=w
end
local bq=
a.datatype==X.DP_TYPE_RAW or
a.raw==true or
a.raw_bytes~=nil or
a.raw_length~=nil or
a.raw_from_tail~=nil or
a.raw_start~=nil or
a.raw_offset~=nil
if bq and a.converter==nil and a.from_device==nil and a.to_device==nil then
local aB={bytes=a.raw_bytes or a.raw_length,length=a.raw_length,from_tail=a.raw_from_tail,start=a.raw_start,offset=a.raw_offset}am(aB,bb)a.converter=t.raw_uint_be(x,aB)if a.datatype==nil then
a.datatype=X.DP_TYPE_RAW
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
return X.dp_numeric(R,a)
end
local function S(M,bo,bn)
local ax=aQ(M)if ax==nil then
return nil
end
return bo+bn-ax
end
local function aS(R,g,F,d,b)
local a=f(d,b,g)local ac=a.raw_min
if ac==nil then
ac=F.raw_min
end
local ab=a.raw_max
if ab==nil then
ab=F.raw_max
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
local bi,bs=t.scale(ac,ab,D,C),t.scale(D,C,ac,ab)a.converter=t.from_to(
function(M,aX,aN)
local bp=bi(M,aX,aN)if bp==nil then
return nil
end
return S(bp,D,C)
end,
function(M,aX,aN)
local aZ=S(M,D,C)if aZ==nil then
return nil
end
return bs(aZ,aX,aN)
end
)elseif ac~=D or ab~=C then
a.converter=t.scale_pair(ac,ab,D,C)end
end
a.raw_min=nil
a.raw_max=nil
a.value_min=nil
a.value_max=nil
a.invert=nil
a.invert_position=nil
return X.dp_numeric(R,a)
end
local function bj(phase,aY)
if c(phase)=="string"and phase~=""then
return(aY or"phase").."_"..phase
end
return aY or"phase"
end
local function ba(bw,phase)
local bm={}for _,ao in ipairs(bw or{})do
local aF=ao
if c(phase)=="string"and phase~=""then
aF=ao.."_"..phase
end
bm[aF]=true
end
return bm
end
local function bc(R,g,aP,bh,d,b)
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
return X.dp_raw(R,a)
end
local function bd(R,d,b)
local a=f(d,b,"threshold")if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=t.threshold_parser()end
if a.field==nil and a.fields==nil then
a.fields={threshold_1=true,threshold_1_protection=true,threshold_1_value=true,threshold_2=true,threshold_2_protection=true,threshold_2_value=true}end
return X.dp_raw(R,a)
end
local function ak(m)
if c(m)=="number"and m%1==0 and m>=0 then
return{m}end
if c(m)~="table"then
return{}end
local aG={}for _,R in ipairs(m)do
if c(R)=="number"and R%1==0 and R>=0 then
I(aG,R)end
end
return aG
end
local function W(b)
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
local function aa(b)
local m=W(b)if m~=nil then
return m
end
if c(b)~="table"then
return b
end
return b.dp
end
local function aH(v,b)
b=b or{}local aI=b.phases
if c(aI)~="table"then
aI=b.phase_names
end
local phase=c(aI)=="table"and aI[v]or nil
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
local function ae(v,b)
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
local az=G and(v-1+p)or(v+p)if az<1 then
return b.default_component
end
return E..tostring(az)
end
local function av(v,b,aO)
b=b or{}local G,T=b.first_is_main~=false,b.key_prefix

if c(T)~="string"or T==""then
T=aO or"switch"end
local ar=b.main_key
if c(ar)~="string"or ar==""then
ar=T
end
local p=b.index_offset
if c(p)~="number"or p%1~=0 then
p=0
end
if v==1 and G then
return ar
end
local az=G and(v-1+p)or(v+p)if az<1 then
return b.default_key
end
return T..tostring(az)
end
local function N(h,R,u,b)
if c(R)~="number"or R%1~=0 or R<0 then
return
end
I(h,u(R,b))
end
local function Y(V,bt)
if c(bt)~="table"then
return V
end
for _,bv in ipairs(bt)do
I(V,bv)end
return V
end
local ah={"first_is_main","main_component","component_prefix","index_offset","default_component","key_prefix","main_key","default_key"}
local function au(M)
return c(M)=="number"and M%1==0 and M>0
end
local function o(b,i)
local a={}if c(b)~="table"then
return a
end
for ao,M in pairs(b)do
local aC=true
if not i then
if ao=="dp"or ao=="dps"or ao=="dp_list"then
aC=false
elseif au(ao)then
aC=false
end
end
if aC then
a[ao]=M
end
end
return a
end
local function Z(b)
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
local function Q(b,n)
if c(b)~="table"then
return nil
end
return s(b[n])
end
local function as(aq,e)
local H,z=c(aq)=="table"and aq.item_options or nil,c(e)=="table"and e.item_options or nil

if c(H)~="table"then
return c(z)=="table"and z or nil
end
if c(z)~="table"then
return H
end
local a={}j(a,H)j(a,z)return a
end
local function ad(b,n,y,i)
local a={}local q
if c(b)=="table"then
bl(a,b,ah)q=b[n]if c(q)=="table"then
j(a,o(b,i))if i and Z(q)then
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
a.item_options=as(b,q)return a
end
local function J(b,l)
local k,an={},Q(b,"config")j(k,an)local at=s(k[l])if at~=nil then
k[l]=at
else
local U=s(k.switch_type)if U==nil then
U=Q(b,"switch_type")end
if c(U)=="table"then
k[l]=U
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
local P=K(r(b,"switch_module"),l)if next(P)~=nil then
a.switch_module=P
end
return a
end
local function bk(h,b,n,u)
local e=r(b,n)N(h,e.dp,u,e)
end
local function aA(h,b,n,u,F)
local e=r(b,n)am(e,F)N(h,e.dp,u,e)
end
local function aR(h,b,n,u,aw)
local e=r(b,n)local m=W(e)if m~=nil and aw~=nil then
Y(h,aw(m,e))return
end
N(h,e.dp,u,e)
end
local function aJ(h,b,n,y,u)
local e=ad(b,n,y)Y(h,u(aa(e),e))
end
local function bf(m,u,g,b)
local h,ag,af={},ak(m),c(b)=="table"and b.item_options or nil
for v,R in ipairs(ag)do
local a=f(af,nil,g)if a.component==nil then
a.component=ae(v,b)end
if a.key==nil and a.preference==nil then
a.key=av(v,b,g)end
if a.field==nil and a.fields==nil and a.key~=nil then
a.field=a.key
end
I(h,u(R,a))end
return h
end
local function aM(m,u,b)
local h,ag,af={},ak(m),c(b)=="table"and b.item_options or nil
for v,R in ipairs(ag)do
local a=f(af,nil,nil)if a.phase==nil then
a.phase=aH(v,b)end
I(h,u(R,a))end
return h
end
local function aK(b,n,u)
local e
if c(b)=="table"then
e=r(b,n,true)else
e={dp=b}end
local h={}N(h,e.dp,u,e)return h
end
function X.dp_on_off(R,d,b)
local a=f(d,b,"switch")if a.name=="switch"and a.emit==nil then
a.emit=br.switch()end
return X.dp_binary(R,a)
end
end
return ap
