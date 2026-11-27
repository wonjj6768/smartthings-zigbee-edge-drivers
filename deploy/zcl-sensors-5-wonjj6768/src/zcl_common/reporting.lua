local I,ab,ak,x=require"st.zigbee.device_management",require"st.capabilities",require"st.zigbee.data_types",require"st.zigbee.zcl.global_commands".ReadReportingConfigurationResponse.ReportingConfigurationRecord
local ac,aq=x.deserialize,x.get_fields
x.deserialize=function(aP)
local g=ac(aP)if g.status.value~=0 and not g.direction then
g.direction=ak.Uint8.deserialize(aP)g.attr_id=ak.AttributeId.deserialize(aP)end
return g
end
x.get_fields=function(g)
local T=aq(g)T[2],T[3]=g.direction,g.attr_id
return T
end
local e,d,aa,ao,Y,af,T={},setmetatable({},{__mode="k"}),"zcl_reporting_pending",30,{[1032]=true,[1037]=true,[1066]=true,[1067]=true},{[0]={[0]="Heartbeat"},[1]={[32]="BattVolt",[33]="Battery",[62]="BattAlarm",[64]="BattTwo"},[2]={[0]="DeviceTmp"},[6]={[0]="Switch",[16387]="PowerOn"},[8]={[0]="Level"},[13]={[85]="Analog"},[15]={[85]="Binary"},[257]={[0]="Lock"},[258]={[8]="Position",[9]="Tilt"},[513]={[0]="LocalTemp",[8]="Demand",[16]="TempCal",[17]="CoolSet",[18]="HeatSet",[19]="CoolSet",[20]="HeatSet",[28]="Mode",[41]="State",[69]="Louver"},[514]={[0]="FanMode"},[768]={[0]="Hue",[1]="Sat",[7]="ColorTemp"},[1024]={[0]="Light"},[1026]={[0]="Temp"},[1027]={[0]="Pressure",[4]="ScalePres"},[1029]={[0]="Humidity"},[1030]={[0]="Occupancy"},[1032]={[0]="Soil"},[1036]={[0]="Co"},[1037]={[0]="CoTwo"},[1066]={[0]="PmFine"},[1067]={[0]="Hcho"},[1280]={[2]="Ias"},[1794]={[0]="Energy",[1]="Export",[1024]="Power"},[2820]={[768]="Frequency",[772]="TotalPwr",[773]="ReactivePwr",[1285]="Voltage",[1288]="Current",[1291]="Power",[2309]="VoltageB",[2565]="VoltageC",[2312]="CurrentB",[2568]="CurrentC"}},{{"minimum_interval","Min","minimumInterval"},{"maximum_interval","Max","maximumInterval"},{"reportable_change","Change","reportableChange"}}

function e.describe(j,o,a,aV)
local f=j.mapping_meta(o,aV)local p=f.reporting_defaults or f
if f.write_only or f.cluster_id==nil or f.attribute_id==nil or
f.data_type==nil or f.mfg_code~=nil or f.cluster_id>=64512 or
(p.minimum_interval==nil and p.maximum_interval==nil and
p.reportable_change==nil and f.physical_reportable_change==nil)or
(a~=nil and p.supported~=nil and not p.supported(a))or
(j.get_generated_attribute(f.cluster_id,f.attribute_id)==nil and
not(Y[f.cluster_id]and f.attribute_id==0)and
not(f.cluster_id==1794 and f.attribute_id==1 and f.data_type.ID==37))then
return nil
end
local endpoint,item=type(f.endpoint)=="number"and tostring(f.endpoint)or"auto",p.label=="Soil moisture"and"Soil"or(af[f.cluster_id]or{})[f.attribute_id]if item==nil then return nil end
return{key=p.key or string.format("zr%04x%04x%s",f.cluster_id,f.attribute_id,endpoint),group=string.format("%04x:%04x",f.cluster_id,f.attribute_id),meta=f,defaults=p,analog=not f.data_type.is_discrete,item=item}
end
local function J(a,key)
local af=d[a]local item=af and af[key]if item and item.expires and item.expires<=os.time()then af[key],item=nil,nil end
return item
end
local function u(a)
local ag={}for key,c in pairs(d[a]or{})do
if not c.expires and not c.failed then ag[key]=c.selected end
end
a:set_field(aa,next(ag)and ag or nil,{persist=true})
end
local function aw(a,c)
c.failed=true
u(a)
end
local function R(a,descriptor,am)
local c=am and J(a,descriptor.key)return c and not c.failed and c.selected or a:get_field("zcl_reporting:"..descriptor.key)
end
local function al(a,l,v,r,aT)
if r==nil or not a:supports_capability_by_id(l)then return end
local aL={value=r}if aT then aL.unit=aT end
a:emit_event(ab[l][v](aL))
end
function e.configuration(j,a,o,A)
local descriptor=e.describe(j,o,a)if descriptor==nil then return nil end
local f,p,k=descriptor.meta,descriptor.defaults,R(a,descriptor,true)

if A~=nil then
local an=type(A)=="table"and A.value or A
a:set_field("zcl_reporting_default:"..descriptor.key,an)local aD=a:get_field("zcl_reporting_change:"..descriptor.key)if aD and(k==nil or k.reportable_change==nil)then
al(a,aD,"reportableChange",an)end
end
local W=k or{}local t,B=W.maximum_interval or p.maximum_interval or 300,W.reportable_change

if B==nil then
B=p.reportable_change
if f.physical_reportable_change~=nil then
B=A
end
end
if t==65535 then B=0 end
if descriptor.analog and B==nil then return nil end
if descriptor.analog and type(B)~="table"then
if f.data_type.ID==57 then
local aN=require"st.buf".Reader
B=f.data_type.deserialize(aN(string.pack("<f",B)))else
B=f.data_type(B)end
end
return{cluster=f.cluster_id,attribute=f.attribute_id,data_type=f.data_type,minimum_interval=W.minimum_interval or p.minimum_interval or 0,maximum_interval=t,reportable_change=descriptor.analog and B or nil},k~=nil
end
local function m(j,a,h,q)
local o=h.zcl_clusters[q]local descriptor=e.describe(j,o,a)if descriptor then return descriptor end
local au=e.describe(j,o)if au then
for _,aH in ipairs(h.zcl_clusters)do
descriptor=e.describe(j,aH,a)if descriptor and descriptor.key==au.key then return descriptor end
end
end
end
function e.discard_unsupported(j,a)
local aB=false
for key,c in pairs(d[a]or{})do
if not m(j,a,c.entry,c.mapping_index)then
d[a][key]=nil
aB=true
end
end
if aB then u(a)end
end
local function H(j,a,h)
for _,item in ipairs(h.reporting_settings)do
local descriptor=m(j,a,h,item.mapping_index)if descriptor then
local k=R(a,descriptor)or{}for E,field in ipairs(T)do
local l=item.capabilities[E]if l then
local r=k[field[1]]or descriptor.defaults[field[1]]if r==nil and E==3 then
r=a:get_field("zcl_reporting_default:"..descriptor.key)end
if type(r)=="table"then r=r.value end
if E==3 then a:set_field("zcl_reporting_change:"..descriptor.key,l)end
al(a,l,field[3],r,E<3 and"s")end
end
end
end
end
local function S(j,a,h)
local ag=a:get_field(aa)or{}d[a]=d[a]or{}for _,item in ipairs(h.reporting_settings)do
if ag[item.key]and not J(a,item.key)and
m(j,a,h,item.mapping_index)then
d[a][item.key]={selected=ag[item.key],entry=h,mapping_index=item.mapping_index,targets={}}end
end
end
function e.queue_defaults(j,a,h,W)
S(j,a,h)for _,item in ipairs(h.reporting_settings)do
if W[item.key]and not J(a,item.key)and
a:get_field("zcl_reporting:"..item.key)==nil and
m(j,a,h,item.mapping_index)then
d[a][item.key]={selected=W[item.key],entry=h,mapping_index=item.mapping_index,targets={},verify_first=true}end
end
u(a)
end
local function P(j,a,key,c)
local descriptor=m(j,a,c.entry,c.mapping_index)if not descriptor then return end
c.targets={}local U={[descriptor.group]={[key]=true}}local aX,C=pcall(e.send,j,a,c.entry.zcl_clusters,U,false)if not aX then d[a][key]=nil;u(a);return false end
if C and j.read_metering_scalers then
j.read_metering_scalers(a,c.entry.zcl_clusters)end
return true
end
function e.on_rx(j,a,rx)
if rx.address_header.profile.value==0 then
if rx.address_header.cluster.value~=19 then return end
else
local aI=rx.body.zcl_header
if not aI.frame_ctrl:is_cluster_specific_set()and aI.cmd.value~=10 then return end
end
e.discard_unsupported(j,a)for key,c in pairs(d[a]or{})do
if not c.expires and not c.failed and(c.last_retry==nil or os.time()-c.last_retry>=ao)then
c.last_retry=os.time()P(j,a,key,c)end
end
end
function e.set(j,a,h,q,field,r)
local descriptor=m(j,a,h,q)if descriptor==nil or type(r)~="number"or r~=r or r<0 then return false end
local Q=descriptor.meta.data_type
local at,aF=field=="reportable_change"and Q.ID==57,field=="minimum_interval"and 65534 or 65535

if field=="reportable_change"then
if not descriptor.analog then return false end
local aS=Q.ID>=40 and Q.ID<=47
aF=at and 3.4028234663852886e38 or(2 ^(8*Q.byte_length-(aS and 1 or 0))-1)end
if r>aF or(not at and r%1~=0)then return false end
local k={}for key,aW in pairs(R(a,descriptor,true)or{})do k[key]=aW end
k[field]=r
local aM,t=k.minimum_interval or descriptor.defaults.minimum_interval or 0,k.maximum_interval or descriptor.defaults.maximum_interval or 300

if t~=0 and t~=65535 and aM>t then return false end
if field=="reportable_change"and t==65535 then return false end
d[a]=d[a]or{}d[a][descriptor.key]={selected=k,entry=h,mapping_index=q,targets={},expires=not a:supports_capability_by_id(ab.battery.ID)and os.time()+30 or nil}u(a)return P(j,a,descriptor.key,J(a,descriptor.key))
end
local function ah(a,y,v,endpoint)
local aQ,tx=require"st.zigbee.zcl.global_commands.read_reporting_configuration",I.attr_refresh(a,y,v):to_endpoint(endpoint)tx.body.zcl_body=aQ.ReadReportingConfiguration{aQ.ReadReportingConfigurationAttributeRecord(0,v)}tx.body.zcl_header.cmd.value=8
return tx
end
function e.send_config(a,key,z,endpoint)
local tx,c=I.attr_config(a,z):to_endpoint(endpoint),key and J(a,key)if c and not c.failed then
c.targets[z.cluster..":"..endpoint]={wire=tx.body.zcl_body:_serialize()}if c.verify_first then tx=ah(a,z.cluster,z.attribute,endpoint)end
end
a:send(tx)
end
function e.global_handlers(j,G)
local function ax(_,a,rx)
local y,endpoint,F,ai=rx.address_header.cluster.value,rx.address_header.src_endpoint.value,rx.body.zcl_header.cmd.value,rx.body.zcl_body

local aA=y..":"..endpoint
e.discard_unsupported(j,a)for key in pairs(d[a]or{})do
local c=J(a,key)local az=c and c.targets[aA]if az then
local v=string.unpack("<I2",az.wire,2)if F==7 then
local ay=ai.global_status and ai.global_status.value
for _,g in ipairs(ai.config_records or{})do
if g.direction.value==0 and g.attr_id.value==v then ay=g.status.value end
end
if ay~=nil and ay~=0 then aw(a,c)end
local tx=ah(a,y,v,endpoint)if not pcall(a.send,a,tx)then
d[a][key]=nil
u(a)end
elseif F==11 then
if(ai.cmd.value==6 or ai.cmd.value==8)and ai.status.value~=0 then aw(a,c)end
else
for _,g in ipairs(ai.read_reporting_records)do
if getmetatable(g)==x and g.direction.value==0 and g.attr_id.value==v then
if g:_serialize():sub(2)==az.wire then
c.targets[aA]=nil
if not next(c.targets)then
a:set_field("zcl_reporting:"..key,c.selected,{persist=true})a:remove_configured_attribute(y,v)d[a][key]=nil
u(a)H(j,a,c.entry)end
elseif c.verify_first and(g.status.value==0 or g.status.value==139)then
c.verify_first=nil
P(j,a,key,c)elseif g.status.value~=0 then
aw(a,c)end
end
end
end
end
end
end
for y in pairs(af)do
G[y]=G[y]or{}for _,F in ipairs{7,9,11}do
local av=G[y][F]if av~=nil then
G[y][F]=function(...)
local O=av(...)ax(...)return O
end
else
G[y][F]=ax
end
end
end
return G
end
function e.attach(j,ar,X)
for _,ae in ipairs(X)do
local h=ar[ae[1]]local V,N,ap,L=h.runtime_start,h.zcl_refresh_before_read_all,{},{}
for key,aU in pairs(h.protocol_writers or{})do ap[key]=aU end
for _,F in ipairs(h.capability_commands or{})do L[#L+1]=F end
h.protocol_writers,h.capability_commands,h.reporting_settings=ap,L,{}local Z={zcl_clusters=h.zcl_clusters,reporting_settings=h.reporting_settings}h.profile=ae[2]local aR={}for q,o in ipairs(h.zcl_clusters or{})do
local descriptor=e.describe(j,o,nil,false)if descriptor and not aR[descriptor.key]then
aR[descriptor.key]=true
local logical_item=ae[3]and ae[3][descriptor.key]if logical_item==nil then logical_item=descriptor.item end
if logical_item~=false then
local item={mapping_index=q,key=descriptor.key,capabilities={}}h.reporting_settings[#h.reporting_settings+1]=item
for E,field in ipairs(T)do
if E<3 or descriptor.analog then
local short_id="zcl"..logical_item.."Report"..field[2]..
(E==3 and string.format("%02x",descriptor.meta.data_type.ID)or"")local l,as,ad="concertmirror08464."..short_id,"set"..field[3]:sub(1,1):upper()..field[3]:sub(2),"zcl_reporting_"..short_id

item.capabilities[E]=l
L[#L+1]={capability_id=l,command_name=as,argument_name=field[3],mapping_name=ad,attribute_name=field[3]}
ap[ad]=function(a,r)
return e.set(j,a,Z,q,field[1],r)
end
end
end
end
end
end
h.runtime_start=function(a,...)
local O
if V then O=V(a,...)end
S(j,a,Z)H(j,a,Z)return O
end
h.zcl_refresh_before_read_all=function(a,...)
local O
if N then O=N(a,...)end
H(j,a,Z)return O
end
end
end
function e.groups(j,a,aj)
local U={}for _,o in ipairs(aj or{})do
local descriptor=e.describe(j,o,a)if descriptor~=nil then
if R(a,descriptor,true)~=nil then
U[descriptor.group]=true
end
end
end
return U
end
function e.send(j,a,aj,U,aO)
local K,aE,X,C={},{},{},false
for _,o in ipairs(aj or{})do
local descriptor=e.describe(j,o,a)local k=descriptor and U[descriptor.group]if descriptor~=nil and k and(k==true or k[descriptor.key])and
not(aO and descriptor.meta.reporting_defaults~=nil)then
local f,aC,s=descriptor.meta,j.build_mapping_context(a,o),{}
if f.reporting_defaults and f.reporting_defaults.all_endpoints then
for _,endpoint in pairs(a.zigbee_endpoints or{})do
if a:supports_server_cluster(f.cluster_id,endpoint.id)then s[#s+1]=endpoint.id end
end
table.sort(s)elseif aC.endpoint~=nil then
s[1]=aC.endpoint
elseif f.reporting_defaults~=nil then
s[1]=a:get_endpoint(f.cluster_id)else
for _,endpoint in ipairs(a.zigbee_endpoints or{})do
if a:supports_server_cluster(f.cluster_id,endpoint.id)then s[#s+1]=endpoint.id end
end
if #s==0 then s[1]=a:get_endpoint(f.cluster_id)end
end
local z=e.configuration(j,a,o)if z==nil then C=f.physical_reportable_change~=nil or C end
for _,endpoint in ipairs(s)do
local key=descriptor.group..":"..endpoint
local E,g=aE[key],{config=z,endpoint=endpoint,explicit=f.endpoint~=nil,key=descriptor.key}if E==nil then
aE[key]=#K+1
K[#K+1]=g
elseif g.explicit and not K[E].explicit then
K[E]=g
end
end
end
end
for _,g in ipairs(K)do
local z,endpoint=g.config,g.endpoint
if z~=nil then
local key=z.cluster..":"..endpoint
if aO and not X[key]then
j.bind_cluster(a,z.cluster,a.driver.environment_info.hub_zigbee_eui,endpoint)X[key]=true
end
e.send_config(a,g.key,z,endpoint)end
end
return C
end
return e
