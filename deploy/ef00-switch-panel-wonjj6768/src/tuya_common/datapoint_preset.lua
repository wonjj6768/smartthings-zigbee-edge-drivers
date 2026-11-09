local function ar(x,aA,br)
br=br or{switch=function()return nil end}
local d,L,aQ,j,bl,p=aA.type_check,aA.table_insert,aA.tonumber_check,aA.merge_options,aA.copy_keys,x.converter





local function ao(X,I)
if d(X)~="table"or d(I)~="table"then
return X
end
for aq,P in pairs(I)do
if X[aq]==nil then
X[aq]=P
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
local function t(bg,b)
if ak(b)then
return bg
end
return x.apply_fixed_send_policy(bg)
end
local function Z(C,g,y,c,b)
local a=e(c,b,g)local z=a.scale
if z==nil then
z=y
end
if a.converter==nil and a.from_device==nil and a.to_device==nil and z~=1 then
a.converter=p.divide_by_pair(z)end
a.scale=nil
return x.dp_numeric(C,a)
end
local function aV(C,g,y,c,b)
local a=e(c,b,g)local z=a.scale
if z==nil then
z=y
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
local an=p.power()local be=an.from
if z~=1 then
a.from_device=p.pipe(be,p.divide_by(z))else
a.converter=an
end
end
a.scale=nil
return x.dp_numeric(C,a)
end
local function aT(C,g,y,c,b)
local a=e(c,b,g)local z=a.scale
if z==nil then
z=y
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=p.signed_number_pair(z)end
if a.signed==nil then
a.signed=true
end
a.scale=nil
return x.dp_numeric(C,a)
end
local function aF(C,g,y,bb,c,b)
local a=e(c,b,g)local z=a.scale
if z==nil then
z=y
end
local bq=
a.datatype==x.DP_TYPE_RAW or
a.raw==true or
a.raw_bytes~=nil or
a.raw_length~=nil or
a.raw_from_tail~=nil or
a.raw_start~=nil or
a.raw_offset~=nil
if bq and a.converter==nil and a.from_device==nil and a.to_device==nil then
local aD={bytes=a.raw_bytes or a.raw_length,length=a.raw_length,from_tail=a.raw_from_tail,start=a.raw_start,offset=a.raw_offset}ao(aD,bb)a.converter=p.raw_uint_be(z,aD)if a.datatype==nil then
a.datatype=x.DP_TYPE_RAW
end
elseif a.converter==nil and a.from_device==nil and a.to_device==nil and z~=1 then
a.converter=p.divide_by_pair(z)end
a.scale=nil
a.raw=nil
a.raw_bytes=nil
a.raw_length=nil
a.raw_from_tail=nil
a.raw_start=nil
a.raw_offset=nil
return x.dp_numeric(C,a)
end
local function U(P,bo,bn)
local az=aQ(P)if az==nil then
return nil
end
return bo+bn-az
end
local function aS(C,g,I,c,b)
local a=e(c,b,g)local ae=a.raw_min
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
local bi,bs=p.scale(ae,ad,G,F),p.scale(G,F,ae,ad)a.converter=p.from_to(
function(P,aX,aN)
local bp=bi(P,aX,aN)if bp==nil then
return nil
end
return U(bp,G,F)
end,
function(P,aX,aN)
local aZ=U(P,G,F)if aZ==nil then
return nil
end
return bs(aZ,aX,aN)
end
)elseif ae~=G or ad~=F then
a.converter=p.scale_pair(ae,ad,G,F)end
end
a.raw_min=nil
a.raw_max=nil
a.value_min=nil
a.value_max=nil
a.invert=nil
a.invert_position=nil
return x.dp_numeric(C,a)
end
local function bj(phase,aY)
if d(phase)=="string"and phase~=""then
return(aY or"phase").."_"..phase
end
return aY or"phase"
end
local function ba(bw,phase)
local bm={}for _,aq in ipairs(bw or{})do
local aG=aq
if d(phase)=="string"and phase~=""then
aG=aq.."_"..phase
end
bm[aG]=true
end
return bm
end
local function bc(C,g,aP,bh,c,b)
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
a.converter=aP(a)end
if a.field==nil and a.fields==nil then
a.fields=ba(bh,phase)end
return x.dp_raw(C,a)
end
local function bd(C,c,b)
local a=e(c,b,"threshold")if a.read_only==nil then
a.read_only=true
end
if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=p.threshold_parser()end
if a.field==nil and a.fields==nil then
a.fields={threshold_1=true,threshold_1_protection=true,threshold_1_value=true,threshold_2=true,threshold_2_protection=true,threshold_2_value=true}end
return x.dp_raw(C,a)
end
local function am(m)
if d(m)=="number"and m%1==0 and m>=0 then
return{m}end
if d(m)~="table"then
return{}end
local aH={}for _,C in ipairs(m)do
if d(C)=="number"and C%1==0 and C>=0 then
L(aH,C)end
end
return aH
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
local function aI(w,b)
b=b or{}local aJ=b.phases
if d(aJ)~="table"then
aJ=b.phase_names
end
local phase=d(aJ)=="table"and aJ[w]or nil
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
local function ag(w,b)
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
local aB=J and(w-1+q)or(w+q)if aB<1 then
return b.default_component
end
return H..tostring(aB)
end
local function ax(w,b,aO)
b=b or{}local J,V=b.first_is_main~=false,b.key_prefix

if d(V)~="string"or V==""then
V=aO or"switch"end
local at=b.main_key
if d(at)~="string"or at==""then
at=V
end
local q=b.index_offset
if d(q)~="number"or q%1~=0 then
q=0
end
if w==1 and J then
return at
end
local aB=J and(w-1+q)or(w+q)if aB<1 then
return b.default_key
end
return V..tostring(aB)
end
local function Q(h,C,v,b)
if d(C)~="number"or C%1~=0 or C<0 then
return
end
L(h,v(C,b))
end
local function aa(X,bt)
if d(bt)~="table"then
return X
end
for _,bv in ipairs(bt)do
L(X,bv)end
return X
end
local aj={"first_is_main","main_component","component_prefix","index_offset","default_component","key_prefix","main_key","default_key"}
local function aw(P)
return d(P)=="number"and P%1==0 and P>0
end
local function o(b,i)
local a={}if d(b)~="table"then
return a
end
for aq,P in pairs(b)do
local aE=true
if not i then
if aq=="dp"or aq=="dps"or aq=="dp_list"then
aE=false
elseif aw(aq)then
aE=false
end
end
if aE then
a[aq]=P
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
local function u(r)
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
return u(b[n])
end
local function au(as,f)
local K,B=d(as)=="table"and as.item_options or nil,d(f)=="table"and f.item_options or nil

if d(K)~="table"then
return d(B)=="table"and B or nil
end
if d(B)~="table"then
return K
end
local a={}j(a,K)j(a,B)return a
end
local function af(b,n,A,i)
local a={}local r
if d(b)=="table"then
bl(a,b,aj)r=b[n]if d(r)=="table"then
j(a,o(b,i))if i and ab(r)then
E(a)end
j(a,r)elseif r~=nil then
j(a,o(b,i))if i then
E(a)end
a.dp=r
else
j(a,o(b,i))end
end
if a.key_prefix==nil and A~=nil then
a.key_prefix=A
end
a.item_options=au(b,r)return a
end
local function M(b,l)
local k,ap={},T(b,"config")j(k,ap)local av=u(k[l])if av~=nil then
k[l]=av
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
local function aU(b,l)
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
local function aC(h,b,n,v,I)
local f=s(b,n)ao(f,I)Q(h,f.dp,v,f)
end
local function aR(h,b,n,v,ay)
local f=s(b,n)local m=Y(f)if m~=nil and ay~=nil then
aa(h,ay(m,f))return
end
Q(h,f.dp,v,f)
end
local function aK(h,b,n,A,v)
local f=af(b,n,A)aa(h,v(ac(f),f))
end
local function bf(m,v,g,b)
local h,ai,ah={},am(m),d(b)=="table"and b.item_options or nil
for w,C in ipairs(ai)do
local a=e(ah,nil,g)if a.component==nil then
a.component=ag(w,b)end
if a.key==nil and a.preference==nil then
a.key=ax(w,b,g)end
if a.field==nil and a.fields==nil and a.key~=nil then
a.field=a.key
end
L(h,v(C,a))end
return h
end
local function aM(m,v,b)
local h,ai,ah={},am(m),d(b)=="table"and b.item_options or nil
for w,C in ipairs(ai)do
local a=e(ah,nil,nil)if a.phase==nil then
a.phase=aI(w,b)end
L(h,v(C,a))end
return h
end
local function aL(b,n,v)
local f
if d(b)=="table"then
f=s(b,n,true)else
f={dp=b}end
local h={}Q(h,f.dp,v,f)return h
end
function x.dp_on_off(C,c,b)
local a=e(c,b,"switch")if a.name=="switch"and a.emit==nil then
a.emit=br.switch()end
return x.dp_binary(C,a)
end
function x.dp_child_lock(C,c,b)
return x.dp_binary(C,e(c,b,"child_lock"))
end
function x.dp_power_on_behavior(C,c,b)
local a=e(c,b,"power_on_behavior")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=p.power_on_behavior()end
return t(x.dp_enum(C,a),a)
end
function x.dp_backlight_mode_off_on(C,c,b)
local a=e(c,b,"backlight_mode")return t(x.dp_binary(C,a),a)
end
function x.dp_indicator_mode_none_relay_pos(C,c,b)
local a=e(c,b,"indicator_mode")if a.converter==nil and a.from_device==nil and a.to_device==nil and a.lookup==nil then
a.converter=p.indicator_mode_none_relay_pos()end
return t(x.dp_enum(C,a),a)
end
function x.dp_inching_switch(C,c,b)
local a=e(c,b,"inching_switch")if a.converter==nil and a.from_device==nil and a.to_device==nil then
a.converter=p.inching_switch()end
return x.dp_raw(C,a)
end
function x.dp_countdown(C,c,b)
return Z(C,"countdown",1,c,b)
end
function x.dp_presence(C,c,b)
return x.dp_binary(C,e(c,b,"presence"))
end
end
return ar
