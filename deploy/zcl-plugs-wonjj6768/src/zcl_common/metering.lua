local function bg(s)
local au,ai,X,R=require"st.capabilities",require"runtime.capability_metadata",require"runtime.capability_support",require"st.zigbee.constants"local f,p,U,H,W=ai.by_emit_name.power_poll_interval,ai.by_emit_name.last_power_response_time,"_zcl_power_poll_interval_seconds","_zcl_last_power_response_at","_zcl_switch_state"

local i=f and f.default_range or{}local o,n,C,V=i.minimum or 5,i.maximum or 3600,i.step or 5,i.unit or"s"


local ac="--"local ay,aj,ah,j,O,T,E=3600,{1,3,10,30},{1,3},{},{demand="energy",summation="energy"},setmetatable({},{__mode="k"}),setmetatable({},{__mode="k"})

local function aP(e)
if type(e)=="table"then
e=e.value
end
if type(e)~="number"then
return nil
end
return e
end
local function q(c)
return s.normalize_endpoint(c)or 1
end
local function aO(e)
if type(e)=="table"then
e=e.value
end
if type(e)=="string"and e~=""then
local bt=tonumber(e)if bt~=nil then
e=bt
end
end
if type(e)~="number"or e~=e or e==math.huge or e==-math.huge then
return nil
end
return math.floor(e+0.5)
end
local function A(e)
e=aO(e)if e==nil then
return nil
end
if e<o then
e=o
elseif e>n then
e=n
end
e=math.floor((e/C)+0.5)*C
if e<o then
e=o
elseif e>n then
e=n
end
return e
end
local function D(a,m)
if m==nil then
return false
end
return X.supports(a,m.ID,"main")
end
local function ap(a,bf)
return X.supports(a,bf,"main")
end
local function af(a,bn)
if bn==nil then
return false
end
if type(a.emit_component_event)=="function"then
a:emit_component_event({id="main"},bn)return true
end
if type(a.emit_event)=="function"then
a:emit_event(bn)return true
end
return false
end
local aR=X.is_callable
local function w(a,aV,Z)
if type(aV)~="table"or type(Z)~="string"or Z==""then
return nil,nil
end
if not ap(a,aV.capability_id)then
return nil,nil
end
local m=au[aV.capability_id]local z=m and m[Z]or nil
if not aR(z)and m and type(m.attributes)=="table"then
z=m.attributes[Z]end
if not aR(z)then
z=nil
end
return m,z
end
local function aq(aM)
if type(aM)~="number"or aM<=0 then
return ac
end
return os.date("!%Y-%m-%d %H:%M:%S UTC",aM)
end
local function N(a,b)
if type(b)~="table"then
return nil
end
local aC
for _,h in ipairs(b)do
if type(h)=="table"then
local d=s.mapping_meta(h)if d~=nil and d.metering_kind=="power"and not d.write_only then
local aL=s.build_mapping_context(a,h,nil)local bc={mapping=h,meta=d,context=aL}if aL.component_id=="main"then
return bc
end
if aC==nil then
aC=bc
end
end
end
end
return aC
end
local function Q(a,b)
local bv=N(a,b)if bv==nil then
return nil
end
return A(bv.meta.poll_interval)
end
local function L(a,b)
local bi=A(a:get_field(U))if bi~=nil then
return bi
end
return Q(a,b)
end
local function G(e)
if e==true or e=="on"then
return"on"end
if e==false or e=="off"then
return"off"end
return nil
end
local function Y(a)
local bw=G(a:get_field(W))if bw~=nil then
return bw
end
local bs=G(type(a.get_latest_state)=="function"and
a:get_latest_state("main",au.switch.ID,"switch")or nil)if bs~=nil then
return bs
end
return nil
end
local function x(a)
return D(a,au.switch)
end
local function an(a,b)
if type(b)~="table"then
return false
end
local aI,ak=0,{}
for _,h in ipairs(b)do
if type(h)=="table"then
local d=s.mapping_meta(h)if d~=nil and d.metering_kind~=nil and not d.write_only then
local k=s.build_mapping_context(a,h,nil)local aY=string.format("%04X:%04X:%s:%s",d.cluster_id or 0,d.attribute_id or 0,tostring(k.endpoint),tostring(d.mfg_code))if not ak[aY]then
ak[aY]=true
s.read_mapping(a,h,k)aI=aI+1
end
end
end
end
return aI>0
end
local function M(a,b,bb,bq,bp)
if type(b)~="table"or a.thread==nil or type(a.thread.call_with_delay)~="function"then
return false
end
if type(bq)~="table"then
return false
end
local be,P=false,T[a]
if type(P)~="table"then
P={}T[a]=P
end
for _,bm in ipairs(bq)do
if type(bm)=="number"and bm>0 then
local aB=a.thread:call_with_delay(bm,function()
if Y(a)==bb then
an(a,b)end
end,bp)
if aB~=nil then
P[#P+1]=aB
be=true
end
end
end
return be
end
local function az(a,b,d)
if d==nil then
return nil
end
local l=d.poll_interval
if d.metering_kind=="power"then
l=L(a,b)end
if type(l)~="number"or l<=0 then
return l
end
if not x(a)or d.metering_kind==nil then
return l
end
if Y(a)=="off"and d.metering_kind~="voltage"then
return ay
end
return l
end
local function ag(a,b)
local aw=L(a,b)local m,z=w(a,f,f and f.attribute_name or nil)if aw==nil or z==nil or not D(a,m)then
return false
end
local _,aA=w(a,f,f and f.range_attribute_name or nil)if aA~=nil then
af(a,aA{value={minimum=o,maximum=n,step=C},unit=V})end
af(a,z{value=aw,unit=V})return true
end
local function F(a)
local m,z=w(a,p,p and p.attribute_name or nil)if z==nil or not D(a,m)then
return false
end
af(a,z{value=aq(a:get_field(H))})return true
end
local function bd(bu,y,c)
return string.format("_zcl_metering:%s:%s:%d",tostring(bu),tostring(y),q(c))
end
local function ae(bu,av,aZ,bh,aH,aN)
local as,B,J=s.get_generated_cluster_id(av),s.get_generated_attribute_by_name(av,aZ),s.get_generated_attribute_by_name(av,bh)if as==nil or B==nil or J==nil then
return nil
end
return{kind=bu,cluster_id=as,multiplier_attribute_id=B.ID,divisor_attribute_id=J.ID,multiplier_store_key=aH,divisor_store_key=aN}
end
local function ba(a,g,y,e,c)
local S=aP(e)if S==nil then
return false
end
a:set_field(bd(g.kind,y,c),S,{persist=true})if q(c)==1 then
if y=="multiplier"and g.multiplier_store_key~=nil then
a:set_field(g.multiplier_store_key,S,{persist=true})elseif y=="divisor"and g.divisor_store_key~=nil then
a:set_field(g.divisor_store_key,S,{persist=true})end
end
return true
end
local function at(a,g,y,c)
c=q(c)local S=a:get_field(bd(g.kind,y,c))if type(S)=="number"then
return S
end
if c==1 then
local ar=y=="multiplier"and g.multiplier_store_key or g.divisor_store_key
if ar~=nil then
S=a:get_field(ar)if type(S)=="number"then
return S
end
end
end
return nil
end
local function am(a,h,d,g,c)
local aW=d.physical_reportable_change
if type(aW)~="number"or aW<=0 then
return nil
end
local B,J=at(a,g,"multiplier",c),at(a,g,"divisor",c)if type(B)~="number"or B<=0 or type(J)~="number"or J<=0 then
return nil
end
local bl=aW*J/B
if bl~=bl or bl==math.huge or bl==-math.huge then
return nil
end
local aF=math.floor(bl+0.5)if aF<=0 or math.abs(bl-aF)>0.000000001 then
return nil
end
if type(d.data_type)=="function"then
return d.data_type(aF)end
if type(d.data_type)=="table"then
local mt=getmetatable(d.data_type)if type(mt)=="table"and type(mt.__call)=="function"then
return d.data_type(aF)end
end
return aF
end
local function ao(a,g,c,b)
if type(b)~="table"or type(a.send)~="function"then
return false
end
local aK,ak=false,{}
for _,h in ipairs(b)do
local d=type(h)=="table"and s.mapping_meta(h)or nil
if d~=nil and d.metering_kind==g.kind and d.physical_reportable_change~=nil then
local aL=s.build_mapping_context(a,h,nil)local aU=q(aL.endpoint)if aU==c and d.cluster_id~=nil and d.attribute_id~=nil then
local aY=string.format("%04X:%04X:%d",d.cluster_id,d.attribute_id,c)if not ak[aY]then
ak[aY]=true
local ab=am(a,h,d,g,c)if ab~=nil then
local aJ=require"zcl_common.reporting"local bx,aX=aJ.configuration(s,a,h,ab)or{cluster=d.cluster_id,attribute=d.attribute_id,minimum_interval=d.minimum_interval or 0,maximum_interval=d.maximum_interval or 300,data_type=d.data_type,reportable_change=ab,mfg_code=d.mfg_code},aJ.describe(s,h,a)aJ.send_config(a,aX and aX.key,bx,c)aK=true
end
end
end
end
end
return aK
end
local function aa(a,g,y,c,b)
local u=E[a]if u==nil then
u={}E[a]=u
end
u[g.kind]=u[g.kind]or{}local bo=u[g.kind][c]or{}u[g.kind][c]=bo
bo[y]=true
if bo.multiplier~=true or bo.divisor~=true then
return false
end
u[g.kind][c]={}return ao(a,g,c,b)
end
local function ax(a,g,c)
local u=E[a]if u==nil then
u={}E[a]=u
end
u[g.kind]=u[g.kind]or{}u[g.kind][c]={}
end
local function aS(a,g,ad,c)
if s.read_attribute==nil then
return false
end
return s.read_attribute(a,g.cluster_id,ad,c)
end
local function al(a)
local P=T[a]if type(P)~="table"or a.thread==nil or type(a.thread.cancel_timer)~="function"then
T[a]=nil
return
end
for _,aB in ipairs(P)do
if aB~=nil then
a.thread:cancel_timer(aB)end
end
T[a]=nil
end
local function K()
if next(j)~=nil then
return
end
j.energy=ae("energy","SimpleMetering","Multiplier","Divisor",R.SIMPLE_METERING_MULTIPLIER_KEY,R.SIMPLE_METERING_DIVISOR_KEY)j.power=ae("power","ElectricalMeasurement","ACPowerMultiplier","ACPowerDivisor",R.ELECTRICAL_MEASUREMENT_MULTIPLIER_KEY,R.ELECTRICAL_MEASUREMENT_DIVISOR_KEY)j.voltage=ae("voltage","ElectricalMeasurement","ACVoltageMultiplier","ACVoltageDivisor")j.current=ae("current","ElectricalMeasurement","ACCurrentMultiplier","ACCurrentDivisor")j.frequency=ae("frequency","ElectricalMeasurement","ACFrequencyMultiplier","ACFrequencyDivisor")for _,g in pairs(j)do
if g~=nil then
s.register_attribute(g.cluster_id,g.multiplier_attribute_id)s.register_attribute(g.cluster_id,g.divisor_attribute_id)end
end
end
function s.handle_internal_attribute(a,as,ad,r,I)
K()local c=q(type(I)=="table"and
(I.endpoint or I.src_endpoint)or nil)local b=type(I)=="table"and I.zcl_clusters or nil
for _,g in pairs(j)do
if g~=nil and as==g.cluster_id then
if ad==g.multiplier_attribute_id then
local aD=ba(a,g,"multiplier",r,c)if aD then
aa(a,g,"multiplier",c,b)end
return aD
end
if ad==g.divisor_attribute_id then
local aD=ba(a,g,"divisor",r,c)if aD then
aa(a,g,"divisor",c,b)end
return aD
end
end
end
return false
end
function s.scale_mapping_value(a,h,r,d,k)
if r==nil or d==nil then
return r
end
local g=d.metering_kind and j[O[d.metering_kind]or d.metering_kind]or nil
if g~=nil and type(r)=="number"and not d.ignore_reported_scaler then
local c=k and k.endpoint or nil
local t,v=at(a,g,"multiplier",c),at(a,g,"divisor",c)if O[d.metering_kind]then
local br=t and t~=0 and
v and v~=0 and t/v
return r*(br and br*(d.metering_kind=="demand"and 1000 or 1)or 1)end
local B,J=t or 1,v or 1

if J==0 then
J=1
end
if B~=J or(d.use_reported_unity_scaler and
t~=nil and v~=nil and v~=0)then
return r*B/J
end
end
if d.scale==nil or d.scale==1 then
return r
end
if type(r)=="number"and type(d.scale)=="number"and d.scale~=0 then
return r/d.scale
end
return r
end
function s.read_metering_scalers(a,b)
K()if type(b)~="table"then
return false
end
local aK,ak,aT=false,{},{}
for _,h in ipairs(b)do
if type(h)=="table"then
local d=s.mapping_meta(h)local g=d and d.metering_kind and j[O[d.metering_kind]or d.metering_kind]or nil
if g~=nil and not d.ignore_reported_scaler then
local k=s.build_mapping_context(a,h,nil)local c=q(k.endpoint)local bj=string.format("%s:%d",g.kind,c)if not aT[bj]then
aT[bj]=true
ax(a,g,c)end
local aG=string.format("%04X:%04X:%d",g.cluster_id,g.multiplier_attribute_id,c)if not ak[aG]then
ak[aG]=true
aK=aS(a,g,g.multiplier_attribute_id,c)or aK
end
local aQ=string.format("%04X:%04X:%d",g.cluster_id,g.divisor_attribute_id,c)if not ak[aQ]then
ak[aQ]=true
aK=aS(a,g,g.divisor_attribute_id,c)or aK
end
end
end
end
return aK
end
function s.emit_power_polling_state(a,b)
if N(a,b)==nil then
return false
end
local aE=false
aE=ag(a,b)or aE
aE=F(a)or aE
return aE
end
function s.set_power_poll_interval(a,b,e)
if Q(a,b)==nil then
return false
end
local aw=A(e)if aw==nil then
return false
end
a:set_field(U,aw,{persist=true})s.start_runtime(a,b)s.emit_power_polling_state(a,b)return true
end
function s.handle_metering_value(a,_,e,d)
if d==nil or d.metering_kind~="power"or type(e)~="number"then
return false
end
local aM=os.time()if type(aM)~="number"then
return false
end
a:set_field(H,aM,{persist=false})F(a)return true
end
function s.begin_power_poll_burst(a,b)
if not x(a)then
return false
end
a:set_field(W,"on",{persist=false})if type(b)=="table"then
s.start_runtime(a,b)M(a,b,"on",aj,"zcl on-state confirm poll")end
return true
end
function s.handle_switch_state(a,b,e)
e=G(e)if not x(a)or e==nil then
return false
end
local bk=Y(a)a:set_field(W,e,{persist=false})if e=="on"and bk~="on"then
return s.begin_power_poll_burst(a,b)end
if e=="off"and bk~="off"then
if type(b)=="table"then
s.start_runtime(a,b)M(a,b,"off",ah,"zcl off-state confirm poll")end
return true
end
return false
end
function s.start_runtime(a,b)
al(a)if type(b)~="table"or a.thread==nil or type(a.thread.call_on_schedule)~="function"then
return false
end
local P,ak={},{}for _,h in ipairs(b)do
if type(h)=="table"then
local d=s.mapping_meta(h)local l=az(a,b,d)if d~=nil and type(l)=="number"and l>0 and not d.write_only then
local k=s.build_mapping_context(a,h,nil)local aY=string.format("%04X:%04X:%s:%s",d.cluster_id or 0,d.attribute_id or 0,tostring(k.endpoint),tostring(d.mfg_code))if not ak[aY]then
ak[aY]=true
local aB=a.thread:call_on_schedule(l,function()
s.read_mapping(a,h,s.build_mapping_context(a,h,nil))
end,string.format("zcl metering poll %s",tostring(d.name or aY)))
if aB~=nil then
P[#P+1]=aB
end
end
end
end
end
T[a]=P
return #P>0
end
function s.stop_runtime(a)
al(a)
end
K()
end
return bg
