local function aq(G,az,br)
br=br or{switch=function()return nil end}
local c,K,aQ,j,bl,q=az.type_check,az.table_insert,az.tonumber_check,az.merge_options,az.copy_keys,G.converter





local function an(X,F)
if c(X)~="table"or c(F)~="table"then
return X
end
for ap,O in pairs(F)do
if X[ap]==nil then
X[ap]=O
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
local function S(bg,b)
if aj(b)then
return bg
end
return G.apply_fixed_send_policy(bg)
end
local function aL(J,g,w,d,b)
local a=e(d,b,g)local x=a.scale
if x==nil then
x=w
end
if a.converter==nil and a.from_device==nil and a.to_device==nil and x~=1 then
a.converter=q.divide_by_pair(x)end
a.scale=nil
return G.dp_numeric(J,a)
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
return G.dp_numeric(J,a)
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
return G.dp_numeric(J,a)
end
local function aE(J,g,w,bb,d,b)
local a=e(d,b,g)local x=a.scale
if x==nil then
x=w
end
local bq=
a.datatype==G.DP_TYPE_RAW or
a.raw==true or
a.raw_bytes~=nil or
a.raw_length~=nil or
a.raw_from_tail~=nil or
a.raw_start~=nil or
a.raw_offset~=nil
if bq and a.converter==nil and a.from_device==nil and a.to_device==nil then
local aC={bytes=a.raw_bytes or a.raw_length,length=a.raw_length,from_tail=a.raw_from_tail,start=a.raw_start,offset=a.raw_offset}an(aC,bb)a.converter=q.raw_uint_be(x,aC)if a.datatype==nil then
a.datatype=G.DP_TYPE_RAW
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
return G.dp_numeric(J,a)
end
local function U(O,bo,bn)
local ay=aQ(O)if ay==nil then
return nil
end
return bo+bn-ay
end
local function aS(J,g,F,d,b)
local a=e(d,b,g)local ad=a.raw_min
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
local bi,bs=q.scale(ad,ac,D,C),q.scale(D,C,ad,ac)a.converter=q.from_to(
function(O,aX,aN)
local bp=bi(O,aX,aN)if bp==nil then
return nil
end
return U(bp,D,C)
end,
function(O,aX,aN)
local aZ=U(O,D,C)if aZ==nil then
return nil
end
return bs(aZ,aX,aN)
end
)elseif ad~=D or ac~=C then
a.converter=q.scale_pair(ad,ac,D,C)end
end
a.raw_min=nil
a.raw_max=nil
a.value_min=nil
a.value_max=nil
a.invert=nil
a.invert_position=nil
return G.dp_numeric(J,a)
end
local function bj(phase,aY)
if c(phase)=="string"and phase~=""then
return(aY or"phase").."_"..phase
end
return aY or"phase"
end
local function ba(bw,phase)
local bm={}for _,ap in ipairs(bw or{})do
local aF=ap
if c(phase)=="string"and phase~=""then
aF=ap.."_"..phase
end
bm[aF]=true
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
return G.dp_raw(J,a)
end
local function bd(J,d,b)
local a=e(d,b,"threshold")if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=q.threshold_parser()end
if a.field==nil and a.fields==nil then
a.fields={threshold_1=true,threshold_1_protection=true,threshold_1_value=true,threshold_2=true,threshold_2_protection=true,threshold_2_value=true}end
return G.dp_raw(J,a)
end
local function al(m)
if c(m)=="number"and m%1==0 and m>=0 then
return{m}end
if c(m)~="table"then
return{}end
local aG={}for _,J in ipairs(m)do
if c(J)=="number"and J%1==0 and J>=0 then
K(aG,J)end
end
return aG
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
local function af(v,b)
b=b or{}local H,E=b.first_is_main~=false,b.component_prefix

if c(E)~="string"or E==""then
E="switch"end
local N=b.main_component
if c(N)~="string"or N==""then
N="main"end
local p=b.index_offset
if c(p)~="number"or p%1~=0 then
p=0
end
if v==1 and H then
return N
end
local aA=H and(v-1+p)or(v+p)if aA<1 then
return b.default_component
end
return E..tostring(aA)
end
local function aw(v,b,aO)
b=b or{}local H,V=b.first_is_main~=false,b.key_prefix

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
if v==1 and H then
return as
end
local aA=H and(v-1+p)or(v+p)if aA<1 then
return b.default_key
end
return V..tostring(aA)
end
local function P(h,J,u,b)
if c(J)~="number"or J%1~=0 or J<0 then
return
end
K(h,u(J,b))
end
local function Z(X,bt)
if c(bt)~="table"then
return X
end
for _,bv in ipairs(bt)do
K(X,bv)end
return X
end
local ai={"first_is_main","main_component","component_prefix","index_offset","default_component","key_prefix","main_key","default_key"}
local function av(O)
return c(O)=="number"and O%1==0 and O>0
end
local function o(b,i)
local a={}if c(b)~="table"then
return a
end
for ap,O in pairs(b)do
local aD=true
if not i then
if ap=="dp"or ap=="dps"or ap=="dp_list"then
aD=false
elseif av(ap)then
aD=false
end
end
if aD then
a[ap]=O
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
local I,z=c(ar)=="table"and ar.item_options or nil,c(f)=="table"and f.item_options or nil

if c(I)~="table"then
return c(z)=="table"and z or nil
end
if c(z)~="table"then
return I
end
local a={}j(a,I)j(a,z)return a
end
local function ae(b,n,y,i)
local a={}local r
if c(b)=="table"then
bl(a,b,ai)r=b[n]if c(r)=="table"then
j(a,o(b,i))if i and aa(r)then
B(a)end
j(a,r)elseif r~=nil then
j(a,o(b,i))if i then
B(a)end
a.dp=r
else
j(a,o(b,i))end
end
if a.key_prefix==nil and y~=nil then
a.key_prefix=y
end
a.item_options=at(b,r)return a
end
local function L(b,l)
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
local function M(b,l)
local a={}if c(b)=="table"then
j(a,b)end
local k=L(b,l)if next(k)~=nil then
a.config=k
end
a.switch_type=nil
return a
end
local function aU(b,l)
local a={}if c(b)=="table"then
j(a,b)end
local R=M(s(b,"switch_module"),l)if next(R)~=nil then
a.switch_module=R
end
return a
end
local function bk(h,b,n,u)
local f=s(b,n)P(h,f.dp,u,f)
end
local function aB(h,b,n,u,F)
local f=s(b,n)an(f,F)P(h,f.dp,u,f)
end
local function aR(h,b,n,u,ax)
local f=s(b,n)local m=Y(f)if m~=nil and ax~=nil then
Z(h,ax(m,f))return
end
P(h,f.dp,u,f)
end
local function aJ(h,b,n,y,u)
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
K(h,u(J,a))end
return h
end
local function aM(m,u,b)
local h,ah,ag={},al(m),c(b)=="table"and b.item_options or nil
for v,J in ipairs(ah)do
local a=e(ag,nil,nil)if a.phase==nil then
a.phase=aH(v,b)end
K(h,u(J,a))end
return h
end
local function aK(b,n,u)
local f
if c(b)=="table"then
f=s(b,n,true)else
f={dp=b}end
local h={}P(h,f.dp,u,f)return h
end
function G.dp_on_off(J,d,b)
local a=e(d,b,"switch")if a.name=="switch"and a.emit==nil then
a.emit=br.switch()end
return G.dp_binary(J,a)
end
function G.dp_illuminance(J,d,b)
local a=e(d,b,"illuminance")return G.dp_numeric(J,a)
end
function G.dp_power_outage_memory(J,d,b)
local a=e(d,b,"power_outage_memory")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=q.power_outage_memory()end
return S(G.dp_enum(J,a),a)
end
function G.dp_presence(J,d,b)
return G.dp_binary(J,e(d,b,"presence"))
end
end
return aq
