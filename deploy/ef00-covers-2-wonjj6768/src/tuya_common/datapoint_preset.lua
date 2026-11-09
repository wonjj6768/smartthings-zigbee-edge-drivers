local function ar(G,aA,br)
br=br or{switch=function()return nil end}
local c,K,aR,j,bl,q=aA.type_check,aA.table_insert,aA.tonumber_check,aA.merge_options,aA.copy_keys,G.converter





local function ao(W,F)
if c(W)~="table"or c(F)~="table"then
return W
end
for aq,O in pairs(F)do
if W[aq]==nil then
W[aq]=O
end
end
return W
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
local al={"send_policy","command_id","transaction","batch_key","match_transaction","response_dp","response_dps","match_response"}
local function ak(b)
if c(b)~="table"then
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
return G.apply_fixed_send_policy(bg)
end
local function Y(I,g,w,d,b)
local a=e(d,b,g)local x=a.scale
if x==nil then
x=w
end
if a.converter==nil and a.from_device==nil and a.to_device==nil and x~=1 then
a.converter=q.divide_by_pair(x)end
a.scale=nil
return G.dp_numeric(I,a)
end
local function aV(I,g,w,d,b)
local a=e(d,b,g)local x=a.scale
if x==nil then
x=w
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
local an=q.power()local be=an.from
if x~=1 then
a.from_device=q.pipe(be,q.divide_by(x))else
a.converter=an
end
end
a.scale=nil
return G.dp_numeric(I,a)
end
local function aT(I,g,w,d,b)
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
return G.dp_numeric(I,a)
end
local function aG(I,g,w,bb,d,b)
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
local aD={bytes=a.raw_bytes or a.raw_length,length=a.raw_length,from_tail=a.raw_from_tail,start=a.raw_start,offset=a.raw_offset}ao(aD,bb)a.converter=q.raw_uint_be(x,aD)if a.datatype==nil then
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
return G.dp_numeric(I,a)
end
local function T(O,bo,bn)
local az=aR(O)if az==nil then
return nil
end
return bo+bn-az
end
local function aa(I,g,F,d,b)
local a=e(d,b,g)local ae=a.raw_min
if ae==nil then
ae=F.raw_min
end
local ad=a.raw_max
if ad==nil then
ad=F.raw_max
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
local bi,bs=q.scale(ae,ad,D,C),q.scale(D,C,ae,ad)a.converter=q.from_to(
function(O,aX,aO)
local bp=bi(O,aX,aO)if bp==nil then
return nil
end
return T(bp,D,C)
end,
function(O,aX,aO)
local aZ=T(O,D,C)if aZ==nil then
return nil
end
return bs(aZ,aX,aO)
end
)elseif ae~=D or ad~=C then
a.converter=q.scale_pair(ae,ad,D,C)end
end
a.raw_min=nil
a.raw_max=nil
a.value_min=nil
a.value_max=nil
a.invert=nil
a.invert_position=nil
return G.dp_numeric(I,a)
end
local function bj(phase,aY)
if c(phase)=="string"and phase~=""then
return(aY or"phase").."_"..phase
end
return aY or"phase"
end
local function ba(bw,phase)
local bm={}for _,aq in ipairs(bw or{})do
local aH=aq
if c(phase)=="string"and phase~=""then
aH=aq.."_"..phase
end
bm[aH]=true
end
return bm
end
local function bc(I,g,aQ,bh,d,b)
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
a.converter=aQ(a)end
if a.field==nil and a.fields==nil then
a.fields=ba(bh,phase)end
return G.dp_raw(I,a)
end
local function bd(I,d,b)
local a=e(d,b,"threshold")if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=q.threshold_parser()end
if a.field==nil and a.fields==nil then
a.fields={threshold_1=true,threshold_1_protection=true,threshold_1_value=true,threshold_2=true,threshold_2_protection=true,threshold_2_value=true}end
return G.dp_raw(I,a)
end
local function am(m)
if c(m)=="number"and m%1==0 and m>=0 then
return{m}end
if c(m)~="table"then
return{}end
local aI={}for _,I in ipairs(m)do
if c(I)=="number"and I%1==0 and I>=0 then
K(aI,I)end
end
return aI
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
local function ac(b)
local m=X(b)if m~=nil then
return m
end
if c(b)~="table"then
return b
end
return b.dp
end
local function aJ(v,b)
b=b or{}local aK=b.phases
if c(aK)~="table"then
aK=b.phase_names
end
local phase=c(aK)=="table"and aK[v]or nil
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
local function ag(v,b)
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
local aB=H and(v-1+p)or(v+p)if aB<1 then
return b.default_component
end
return E..tostring(aB)
end
local function ax(v,b,aP)
b=b or{}local H,U=b.first_is_main~=false,b.key_prefix

if c(U)~="string"or U==""then
U=aP or"switch"end
local at=b.main_key
if c(at)~="string"or at==""then
at=U
end
local p=b.index_offset
if c(p)~="number"or p%1~=0 then
p=0
end
if v==1 and H then
return at
end
local aB=H and(v-1+p)or(v+p)if aB<1 then
return b.default_key
end
return U..tostring(aB)
end
local function P(h,I,u,b)
if c(I)~="number"or I%1~=0 or I<0 then
return
end
K(h,u(I,b))
end
local function Z(W,bt)
if c(bt)~="table"then
return W
end
for _,bv in ipairs(bt)do
K(W,bv)end
return W
end
local aj={"first_is_main","main_component","component_prefix","index_offset","default_component","key_prefix","main_key","default_key"}
local function aw(O)
return c(O)=="number"and O%1==0 and O>0
end
local function o(b,i)
local a={}if c(b)~="table"then
return a
end
for aq,O in pairs(b)do
local aE=true
if not i then
if aq=="dp"or aq=="dps"or aq=="dp_list"then
aE=false
elseif aw(aq)then
aE=false
end
end
if aE then
a[aq]=O
end
end
return a
end
local function ab(b)
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
local function S(b,n)
if c(b)~="table"then
return nil
end
return t(b[n])
end
local function au(as,f)
local J,z=c(as)=="table"and as.item_options or nil,c(f)=="table"and f.item_options or nil

if c(J)~="table"then
return c(z)=="table"and z or nil
end
if c(z)~="table"then
return J
end
local a={}j(a,J)j(a,z)return a
end
local function af(b,n,y,i)
local a={}local r
if c(b)=="table"then
bl(a,b,aj)r=b[n]if c(r)=="table"then
j(a,o(b,i))if i and ab(r)then
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
a.item_options=au(b,r)return a
end
local function L(b,l)
local k,ap={},S(b,"config")j(k,ap)local av=t(k[l])if av~=nil then
k[l]=av
else
local V=t(k.switch_type)if V==nil then
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
local function aC(h,b,n,u,F)
local f=s(b,n)ao(f,F)P(h,f.dp,u,f)
end
local function aS(h,b,n,u,ay)
local f=s(b,n)local m=X(f)if m~=nil and ay~=nil then
Z(h,ay(m,f))return
end
P(h,f.dp,u,f)
end
local function aL(h,b,n,y,u)
local f=af(b,n,y)Z(h,u(ac(f),f))
end
local function bf(m,u,g,b)
local h,ai,ah={},am(m),c(b)=="table"and b.item_options or nil
for v,I in ipairs(ai)do
local a=e(ah,nil,g)if a.component==nil then
a.component=ag(v,b)end
if a.key==nil and a.preference==nil then
a.key=ax(v,b,g)end
if a.field==nil and a.fields==nil and a.key~=nil then
a.field=a.key
end
K(h,u(I,a))end
return h
end
local function aN(m,u,b)
local h,ai,ah={},am(m),c(b)=="table"and b.item_options or nil
for v,I in ipairs(ai)do
local a=e(ah,nil,nil)if a.phase==nil then
a.phase=aJ(v,b)end
K(h,u(I,a))end
return h
end
local function aM(b,n,u)
local f
if c(b)=="table"then
f=s(b,n,true)else
f={dp=b}end
local h={}P(h,f.dp,u,f)return h
end
function G.dp_on_off(I,d,b)
local a=e(d,b,"switch")if a.name=="switch"and a.emit==nil then
a.emit=br.switch()end
return G.dp_binary(I,a)
end
function G.dp_battery(I,d,b)
return Y(I,"battery",1,d,b)
end
function G.dp_illuminance(I,d,b)
local a=e(d,b,"illuminance")return G.dp_numeric(I,a)
end
function G.dp_cover_position(I,d,b)
return aa(I,"cover_position",{raw_min=0,raw_max=100,value_min=0,value_max=100},d,b)
end
function G.dp_cover_position_inverted(I,d,b)
local a=e(d,b,"cover_position")if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=q.cover_position_inverted()end
return G.dp_numeric(I,a)
end
end
return ar
