local function as(B,aB,br)
br=br or{switch=function()return nil end}
local d,L,aR,j,bl,q=aB.type_check,aB.table_insert,aB.tonumber_check,aB.merge_options,aB.copy_keys,B.converter





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
local function T(bg,b)
if al(b)then
return bg
end
return B.apply_fixed_send_policy(bg)
end
local function u(C,g,x,c,b)
local a=e(c,b,g)local y=a.scale
if y==nil then
y=x
end
if a.converter==nil and a.from_device==nil and a.to_device==nil and y~=1 then
a.converter=q.divide_by_pair(y)end
a.scale=nil
return B.dp_numeric(C,a)
end
local function ab(C,g,x,c,b)
local a=e(c,b,g)local y=a.scale
if y==nil then
y=x
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
local ao=q.power()local be=ao.from
if y~=1 then
a.from_device=q.pipe(be,q.divide_by(y))else
a.converter=ao
end
end
a.scale=nil
return B.dp_numeric(C,a)
end
local function aU(C,g,x,c,b)
local a=e(c,b,g)local y=a.scale
if y==nil then
y=x
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=q.signed_number_pair(y)end
if a.signed==nil then
a.signed=true
end
a.scale=nil
return B.dp_numeric(C,a)
end
local function aG(C,g,x,bb,c,b)
local a=e(c,b,g)local y=a.scale
if y==nil then
y=x
end
local bq=
a.datatype==B.DP_TYPE_RAW or
a.raw==true or
a.raw_bytes~=nil or
a.raw_length~=nil or
a.raw_from_tail~=nil or
a.raw_start~=nil or
a.raw_offset~=nil
if bq and a.converter==nil and a.from_device==nil and a.to_device==nil then
local aE={bytes=a.raw_bytes or a.raw_length,length=a.raw_length,from_tail=a.raw_from_tail,start=a.raw_start,offset=a.raw_offset}ap(aE,bb)a.converter=q.raw_uint_be(y,aE)if a.datatype==nil then
a.datatype=B.DP_TYPE_RAW
end
elseif a.converter==nil and a.from_device==nil and a.to_device==nil and y~=1 then
a.converter=q.divide_by_pair(y)end
a.scale=nil
a.raw=nil
a.raw_bytes=nil
a.raw_length=nil
a.raw_from_tail=nil
a.raw_start=nil
a.raw_offset=nil
return B.dp_numeric(C,a)
end
local function V(P,bo,bn)
local aA=aR(P)if aA==nil then
return nil
end
return bo+bn-aA
end
local function aT(C,g,I,c,b)
local a=e(c,b,g)local af=a.raw_min
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
local bi,bs=q.scale(af,ae,G,F),q.scale(G,F,af,ae)a.converter=q.from_to(
function(P,aX,aO)
local bp=bi(P,aX,aO)if bp==nil then
return nil
end
return V(bp,G,F)
end,
function(P,aX,aO)
local aZ=V(P,G,F)if aZ==nil then
return nil
end
return bs(aZ,aX,aO)
end
)elseif af~=G or ae~=F then
a.converter=q.scale_pair(af,ae,G,F)end
end
a.raw_min=nil
a.raw_max=nil
a.value_min=nil
a.value_max=nil
a.invert=nil
a.invert_position=nil
return B.dp_numeric(C,a)
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
local function bc(C,g,aQ,bh,c,b)
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
return B.dp_raw(C,a)
end
local function bd(C,c,b)
local a=e(c,b,"threshold")if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=q.threshold_parser()end
if a.field==nil and a.fields==nil then
a.fields={threshold_1=true,threshold_1_protection=true,threshold_1_value=true,threshold_2=true,threshold_2_protection=true,threshold_2_value=true}end
return B.dp_raw(C,a)
end
local function an(m)
if d(m)=="number"and m%1==0 and m>=0 then
return{m}end
if d(m)~="table"then
return{}end
local aI={}for _,C in ipairs(m)do
if d(C)=="number"and C%1==0 and C>=0 then
L(aI,C)end
end
return aI
end
local function Z(b)
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
local m=Z(b)if m~=nil then
return m
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
return H..tostring(aC)
end
local function ay(w,b,aP)
b=b or{}local J,W=b.first_is_main~=false,b.key_prefix

if d(W)~="string"or W==""then
W=aP or"switch"end
local au=b.main_key
if d(au)~="string"or au==""then
au=W
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
return W..tostring(aC)
end
local function Q(h,C,v,b)
if d(C)~="number"or C%1~=0 or C<0 then
return
end
L(h,v(C,b))
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
local function U(b,n)
if d(b)~="table"then
return nil
end
return t(b[n])
end
local function av(at,f)
local K,A=d(at)=="table"and at.item_options or nil,d(f)=="table"and f.item_options or nil

if d(K)~="table"then
return d(A)=="table"and A or nil
end
if d(A)~="table"then
return K
end
local a={}j(a,K)j(a,A)return a
end
local function ag(b,n,z,i)
local a={}local r
if d(b)=="table"then
bl(a,b,ak)r=b[n]if d(r)=="table"then
j(a,o(b,i))if i and ac(r)then
E(a)end
j(a,r)elseif r~=nil then
j(a,o(b,i))if i then
E(a)end
a.dp=r
else
j(a,o(b,i))end
end
if a.key_prefix==nil and z~=nil then
a.key_prefix=z
end
a.item_options=av(b,r)return a
end
local function M(b,l)
local k,aq={},U(b,"config")j(k,aq)local aw=t(k[l])if aw~=nil then
k[l]=aw
else
local X=t(k.switch_type)if X==nil then
X=U(b,"switch_type")end
if d(X)=="table"then
k[l]=X
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
local function aV(b,l)
local a={}if d(b)=="table"then
j(a,b)end
local S=N(s(b,"switch_module"),l)if next(S)~=nil then
a.switch_module=S
end
return a
end
local function bk(h,b,n,v)
local f=s(b,n)Q(h,f.dp,v,f)
end
local function aD(h,b,n,v,I)
local f=s(b,n)ap(f,I)Q(h,f.dp,v,f)
end
local function aS(h,b,n,v,az)
local f=s(b,n)local m=Z(f)if m~=nil and az~=nil then
aa(h,az(m,f))return
end
Q(h,f.dp,v,f)
end
local function aL(h,b,n,z,v)
local f=ag(b,n,z)aa(h,v(ad(f),f))
end
local function bf(m,v,g,b)
local h,aj,ai={},an(m),d(b)=="table"and b.item_options or nil
for w,C in ipairs(aj)do
local a=e(ai,nil,g)if a.component==nil then
a.component=ah(w,b)end
if a.key==nil and a.preference==nil then
a.key=ay(w,b,g)end
if a.field==nil and a.fields==nil and a.key~=nil then
a.field=a.key
end
L(h,v(C,a))end
return h
end
local function aN(m,v,b)
local h,aj,ai={},an(m),d(b)=="table"and b.item_options or nil
for w,C in ipairs(aj)do
local a=e(ai,nil,nil)if a.phase==nil then
a.phase=aJ(w,b)end
L(h,v(C,a))end
return h
end
local function aM(b,n,v)
local f
if d(b)=="table"then
f=s(b,n,true)else
f={dp=b}end
local h={}Q(h,f.dp,v,f)return h
end
function B.dp_on_off(C,c,b)
local a=e(c,b,"switch")if a.name=="switch"and a.emit==nil then
a.emit=br.switch()end
return B.dp_binary(C,a)
end
function B.dp_occupancy(C,c,b)
local a=e(c,b,"occupancy")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=q.true_false0()end
return B.dp_binary(C,a)
end
function B.dp_voltage(C,c,b)
return u(C,"voltage",10,c,b)
end
function B.dp_current(C,c,b)
return u(C,"current",1000,c,b)
end
function B.dp_power(C,c,b)
return ab(C,"power",10,c,b)
end
function B.dp_power_on_behavior(C,c,b)
local a=e(c,b,"power_on_behavior")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=q.power_on_behavior()end
return T(B.dp_enum(C,a),a)
end
function B.dp_countdown(C,c,b)
return u(C,"countdown",1,c,b)
end
end
return as
