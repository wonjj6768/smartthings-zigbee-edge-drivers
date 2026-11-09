local function as(A,aB,br)
br=br or{switch=function()return nil end}
local d,K,aR,j,bl,q=aB.type_check,aB.table_insert,aB.tonumber_check,aB.merge_options,aB.copy_keys,A.converter





local function ap(X,G)
if d(X)~="table"or d(G)~="table"then
return X
end
for ar,O in pairs(G)do
if X[ar]==nil then
X[ar]=O
end
end
return X
end
local function e(c,b,g)
local a={}if d(c)=="string"then
a.name=c
else
j(a,c)end
j(a,b)if a.name==nil and g~=nil then
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
local function S(bg,b)
if al(b)then
return bg
end
return A.apply_fixed_send_policy(bg)
end
local function Z(H,g,w,c,b)
local a=e(c,b,g)local x=a.scale
if x==nil then
x=w
end
if a.converter==nil and a.from_device==nil and a.to_device==nil and x~=1 then
a.converter=q.divide_by_pair(x)end
a.scale=nil
return A.dp_numeric(H,a)
end
local function aV(H,g,w,c,b)
local a=e(c,b,g)local x=a.scale
if x==nil then
x=w
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
local ao=q.power()local be=ao.from
if x~=1 then
a.from_device=q.pipe(be,q.divide_by(x))else
a.converter=ao
end
end
a.scale=nil
return A.dp_numeric(H,a)
end
local function aT(H,g,w,c,b)
local a=e(c,b,g)local x=a.scale
if x==nil then
x=w
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=q.signed_number_pair(x)end
if a.signed==nil then
a.signed=true
end
a.scale=nil
return A.dp_numeric(H,a)
end
local function aG(H,g,w,bb,c,b)
local a=e(c,b,g)local x=a.scale
if x==nil then
x=w
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
local aE={bytes=a.raw_bytes or a.raw_length,length=a.raw_length,from_tail=a.raw_from_tail,start=a.raw_start,offset=a.raw_offset}ap(aE,bb)a.converter=q.raw_uint_be(x,aE)if a.datatype==nil then
a.datatype=A.DP_TYPE_RAW
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
return A.dp_numeric(H,a)
end
local function U(O,bo,bn)
local aA=aR(O)if aA==nil then
return nil
end
return bo+bn-aA
end
local function ab(H,g,G,c,b)
local a=e(c,b,g)local af=a.raw_min
if af==nil then
af=G.raw_min
end
local ae=a.raw_max
if ae==nil then
ae=G.raw_max
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
local bi,bs=q.scale(af,ae,E,D),q.scale(E,D,af,ae)a.converter=q.from_to(
function(O,aX,aO)
local bp=bi(O,aX,aO)if bp==nil then
return nil
end
return U(bp,E,D)
end,
function(O,aX,aO)
local aZ=U(O,E,D)if aZ==nil then
return nil
end
return bs(aZ,aX,aO)
end
)elseif af~=E or ae~=D then
a.converter=q.scale_pair(af,ae,E,D)end
end
a.raw_min=nil
a.raw_max=nil
a.value_min=nil
a.value_max=nil
a.invert=nil
a.invert_position=nil
return A.dp_numeric(H,a)
end
local function bj(phase,aY)
if d(phase)=="string"and phase~=""then
return(aY or"phase").."_"..phase
end
return aY or"phase"
end
local function ba(bw,phase)
local bm={}for _,ar in ipairs(bw or{})do
local aH=ar
if d(phase)=="string"and phase~=""then
aH=ar.."_"..phase
end
bm[aH]=true
end
return bm
end
local function bc(H,g,aQ,bh,c,b)
local aW=
d(c)=="string"or
(d(c)=="table"and c.name~=nil)or
(d(b)=="table"and b.name~=nil)local a=e(c,b,g)local phase=a.phase
if not aW and a.name==g then
a.name=bj(phase,g)end
if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=aQ(a)end
if a.field==nil and a.fields==nil then
a.fields=ba(bh,phase)end
return A.dp_raw(H,a)
end
local function bd(H,c,b)
local a=e(c,b,"threshold")if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=q.threshold_parser()end
if a.field==nil and a.fields==nil then
a.fields={threshold_1=true,threshold_1_protection=true,threshold_1_value=true,threshold_2=true,threshold_2_protection=true,threshold_2_value=true}end
return A.dp_raw(H,a)
end
local function an(m)
if d(m)=="number"and m%1==0 and m>=0 then
return{m}end
if d(m)~="table"then
return{}end
local aI={}for _,H in ipairs(m)do
if d(H)=="number"and H%1==0 and H>=0 then
K(aI,H)end
end
return aI
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
local function ad(b)
local m=Y(b)if m~=nil then
return m
end
if d(b)~="table"then
return b
end
return b.dp
end
local function aJ(v,b)
b=b or{}local aK=b.phases
if d(aK)~="table"then
aK=b.phase_names
end
local phase=d(aK)=="table"and aK[v]or nil
if d(phase)=="string"and phase~=""then
return phase
end
local B=b.phase_prefix
if B==false then
return nil
end
if d(B)~="string"or B==""then
B=nil
end
if B~=nil then
return B..tostring(v)end
return tostring(v)
end
local function ah(v,b)
b=b or{}local I,F=b.first_is_main~=false,b.component_prefix

if d(F)~="string"or F==""then
F="switch"end
local N=b.main_component
if d(N)~="string"or N==""then
N="main"end
local p=b.index_offset
if d(p)~="number"or p%1~=0 then
p=0
end
if v==1 and I then
return N
end
local aC=I and(v-1+p)or(v+p)if aC<1 then
return b.default_component
end
return F..tostring(aC)
end
local function ay(v,b,aP)
b=b or{}local I,V=b.first_is_main~=false,b.key_prefix

if d(V)~="string"or V==""then
V=aP or"switch"end
local au=b.main_key
if d(au)~="string"or au==""then
au=V
end
local p=b.index_offset
if d(p)~="number"or p%1~=0 then
p=0
end
if v==1 and I then
return au
end
local aC=I and(v-1+p)or(v+p)if aC<1 then
return b.default_key
end
return V..tostring(aC)
end
local function P(h,H,u,b)
if d(H)~="number"or H%1~=0 or H<0 then
return
end
K(h,u(H,b))
end
local function aa(X,bt)
if d(bt)~="table"then
return X
end
for _,bv in ipairs(bt)do
K(X,bv)end
return X
end
local ak={"first_is_main","main_component","component_prefix","index_offset","default_component","key_prefix","main_key","default_key"}
local function ax(O)
return d(O)=="number"and O%1==0 and O>0
end
local function o(b,i)
local a={}if d(b)~="table"then
return a
end
for ar,O in pairs(b)do
local aF=true
if not i then
if ar=="dp"or ar=="dps"or ar=="dp_list"then
aF=false
elseif ax(ar)then
aF=false
end
end
if aF then
a[ar]=O
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
local function C(b)
if d(b)~="table"then
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
if d(b)~="table"then
return{}end
local r=b[n]if r==nil then
return o(b,i)end
local a=o(b,i)if d(r)=="table"then
j(a,r)else
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
local function T(b,n)
if d(b)~="table"then
return nil
end
return t(b[n])
end
local function av(at,f)
local J,z=d(at)=="table"and at.item_options or nil,d(f)=="table"and f.item_options or nil

if d(J)~="table"then
return d(z)=="table"and z or nil
end
if d(z)~="table"then
return J
end
local a={}j(a,J)j(a,z)return a
end
local function ag(b,n,y,i)
local a={}local r
if d(b)=="table"then
bl(a,b,ak)r=b[n]if d(r)=="table"then
j(a,o(b,i))if i and ac(r)then
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
a.item_options=av(b,r)return a
end
local function L(b,l)
local k,aq={},T(b,"config")j(k,aq)local aw=t(k[l])if aw~=nil then
k[l]=aw
else
local W=t(k.switch_type)if W==nil then
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
local function M(b,l)
local a={}if d(b)=="table"then
j(a,b)end
local k=L(b,l)if next(k)~=nil then
a.config=k
end
a.switch_type=nil
return a
end
local function aU(b,l)
local a={}if d(b)=="table"then
j(a,b)end
local R=M(s(b,"switch_module"),l)if next(R)~=nil then
a.switch_module=R
end
return a
end
local function bk(h,b,n,u)
local f=s(b,n)P(h,f.dp,u,f)
end
local function aD(h,b,n,u,G)
local f=s(b,n)ap(f,G)P(h,f.dp,u,f)
end
local function aS(h,b,n,u,az)
local f=s(b,n)local m=Y(f)if m~=nil and az~=nil then
aa(h,az(m,f))return
end
P(h,f.dp,u,f)
end
local function aL(h,b,n,y,u)
local f=ag(b,n,y)aa(h,u(ad(f),f))
end
local function bf(m,u,g,b)
local h,aj,ai={},an(m),d(b)=="table"and b.item_options or nil
for v,H in ipairs(aj)do
local a=e(ai,nil,g)if a.component==nil then
a.component=ah(v,b)end
if a.key==nil and a.preference==nil then
a.key=ay(v,b,g)end
if a.field==nil and a.fields==nil and a.key~=nil then
a.field=a.key
end
K(h,u(H,a))end
return h
end
local function aN(m,u,b)
local h,aj,ai={},an(m),d(b)=="table"and b.item_options or nil
for v,H in ipairs(aj)do
local a=e(ai,nil,nil)if a.phase==nil then
a.phase=aJ(v,b)end
K(h,u(H,a))end
return h
end
local function aM(b,n,u)
local f
if d(b)=="table"then
f=s(b,n,true)else
f={dp=b}end
local h={}P(h,f.dp,u,f)return h
end
function A.dp_on_off(H,c,b)
local a=e(c,b,"switch")if a.name=="switch"and a.emit==nil then
a.emit=br.switch()end
return A.dp_binary(H,a)
end
function A.dp_battery(H,c,b)
return Z(H,"battery",1,c,b)
end
function A.dp_child_lock(H,c,b)
return A.dp_binary(H,e(c,b,"child_lock"))
end
function A.dp_backlight_mode_off_on(H,c,b)
local a=e(c,b,"backlight_mode")return S(A.dp_binary(H,a),a)
end
function A.dp_cover_position(H,c,b)
return ab(H,"cover_position",{raw_min=0,raw_max=100,value_min=0,value_max=100},c,b)
end
function A.dp_cover_position_inverted(H,c,b)
local a=e(c,b,"cover_position")if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=q.cover_position_inverted()end
return A.dp_numeric(H,a)
end
end
return as
