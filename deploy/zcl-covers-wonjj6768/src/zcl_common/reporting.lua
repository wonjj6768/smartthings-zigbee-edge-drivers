local H,ai,aa,s=require"st.zigbee.device_management",require"st.capabilities",require"st.zigbee.data_types",require"st.zigbee.zcl.global_commands".ReadReportingConfigurationResponse.ReportingConfigurationRecord
local U,ag=s.deserialize,s.get_fields
s.deserialize=function(aD)
local g=U(aD)if g.status.value~=0 and not g.direction then
g.direction=aa.Uint8.deserialize(aD)g.attr_id=aa.AttributeId.deserialize(aD)end
return g
end
s.get_fields=function(g)
local P=ag(g)P[2],P[3]=g.direction,g.attr_id
return P
end
local c,d,T,X,P={},setmetatable({},{__mode="k"}),{[1032]=true,[1037]=true,[1066]=true,[1067]=true},{[0]={[0]="Heartbeat"},[1]={[32]="BattVolt",[33]="Battery",[62]="BattAlarm",[64]="BattTwo"},[2]={[0]="DeviceTmp"},[6]={[0]="Switch",[16387]="PowerOn"},[8]={[0]="Level"},[13]={[85]="Analog"},[15]={[85]="Binary"},[257]={[0]="Lock"},[258]={[8]="Position",[9]="Tilt"},[513]={[0]="LocalTemp",[8]="Demand",[16]="TempCal",[17]="CoolSet",[18]="HeatSet",[19]="CoolSet",[20]="HeatSet",[28]="Mode",[41]="State",[69]="Louver"},[514]={[0]="FanMode"},[768]={[0]="Hue",[1]="Sat",[7]="ColorTemp"},[1024]={[0]="Light"},[1026]={[0]="Temp"},[1027]={[0]="Pressure",[4]="ScalePres"},[1029]={[0]="Humidity"},[1030]={[0]="Occupancy"},[1032]={[0]="Soil"},[1036]={[0]="Co"},[1037]={[0]="CoTwo"},[1066]={[0]="PmFine"},[1067]={[0]="Hcho"},[1280]={[2]="Ias"},[1794]={[0]="Energy",[1]="Export",[1024]="Power"},[2820]={[768]="Frequency",[772]="TotalPwr",[773]="ReactivePwr",[1285]="Voltage",[1288]="Current",[1291]="Power",[2309]="VoltageB",[2565]="VoltageC",[2312]="CurrentB",[2568]="CurrentC"}},{{"minimum_interval","Min","minimumInterval"},{"maximum_interval","Max","maximumInterval"},{"reportable_change","Change","reportableChange"}}
function c.describe(q,l,b,aJ)
local e=q.mapping_meta(l,aJ)local m=e.reporting_defaults or e
if e.write_only or e.cluster_id==nil or e.attribute_id==nil or
e.data_type==nil or e.mfg_code~=nil or e.cluster_id>=64512 or
(m.minimum_interval==nil and m.maximum_interval==nil and
m.reportable_change==nil and e.physical_reportable_change==nil)or
(b~=nil and m.supported~=nil and not m.supported(b))or
(q.get_generated_attribute(e.cluster_id,e.attribute_id)==nil and
not(T[e.cluster_id]and e.attribute_id==0)and
not(e.cluster_id==1794 and e.attribute_id==1 and e.data_type.ID==37))then
return nil
end
local endpoint,item=type(e.endpoint)=="number"and tostring(e.endpoint)or"auto",m.label=="Soil moisture"and"Soil"or(X[e.cluster_id]or{})[e.attribute_id]if item==nil then return nil end
return{key=m.key or string.format("zr%04x%04x%s",e.cluster_id,e.attribute_id,endpoint),group=string.format("%04x:%04x",e.cluster_id,e.attribute_id),meta=e,defaults=m,analog=not e.data_type.is_discrete,item=item}
end
local function ae(b,key)
local X=d[b]local item=X and X[key]if item and item.expires<=os.time()then X[key],item=nil,nil end
return item
end
local function O(b,descriptor,ac)
local f=ac and ae(b,descriptor.key)return f and not f.failed and f.selected or b:get_field("zcl_reporting:"..descriptor.key)
end
local function ab(b,k,C,o,aH)
if o==nil or not b:supports_capability_by_id(k)then return end
local ax={value=o}if aH then ax.unit=aH end
b:emit_event(ai[k][C](ax))
end
function c.configuration(q,b,l,t)
local descriptor=c.describe(q,l,b)if descriptor==nil then return nil end
local e,m,i=descriptor.meta,descriptor.defaults,O(b,descriptor,true)

if t~=nil then
local ad=type(t)=="table"and t.value or t
b:set_field("zcl_reporting_default:"..descriptor.key,ad)local as=b:get_field("zcl_reporting_change:"..descriptor.key)if as and(i==nil or i.reportable_change==nil)then
ab(b,as,"reportableChange",ad)end
end
local ap=i or{}local r,u=ap.maximum_interval or m.maximum_interval or 300,ap.reportable_change

if u==nil then
u=m.reportable_change
if e.physical_reportable_change~=nil then
u=t
end
end
if r==65535 then u=0 end
if descriptor.analog and u==nil then return nil end
if descriptor.analog and type(u)~="table"then
if e.data_type.ID==57 then
local aB=require"st.buf".Reader
u=e.data_type.deserialize(aB(string.pack("<f",u)))else
u=e.data_type(u)end
end
return{cluster=e.cluster_id,attribute=e.attribute_id,data_type=e.data_type,minimum_interval=ap.minimum_interval or m.minimum_interval or 0,maximum_interval=r,reportable_change=descriptor.analog and u or nil},i~=nil
end
local function y(q,b,j,n)
local l=j.zcl_clusters[n]local descriptor=c.describe(q,l,b)if descriptor then return descriptor end
local al=c.describe(q,l)if al then
for _,aw in ipairs(j.zcl_clusters)do
descriptor=c.describe(q,aw,b)if descriptor and descriptor.key==al.key then return descriptor end
end
end
end
function c.discard_unsupported(q,b)
for key,f in pairs(d[b]or{})do
if not y(q,b,f.entry,f.mapping_index)then
d[b][key]=nil
end
end
end
local function F(q,b,j)
for _,item in ipairs(j.reporting_settings)do
local descriptor=y(q,b,j,item.mapping_index)if descriptor then
local i=O(b,descriptor)or{}for B,field in ipairs(P)do
local k=item.capabilities[B]if k then
local o=i[field[1]]or descriptor.defaults[field[1]]if o==nil and B==3 then
o=b:get_field("zcl_reporting_default:"..descriptor.key)end
if type(o)=="table"then o=o.value end
if B==3 then b:set_field("zcl_reporting_change:"..descriptor.key,k)end
ab(b,k,field[3],o,B<3 and"s")end
end
end
end
end
function c.set(q,b,j,n,field,o)
local descriptor=y(q,b,j,n)if descriptor==nil or type(o)~="number"or o~=o or o<0 then return false end
local N=descriptor.meta.data_type
local ak,au=field=="reportable_change"and N.ID==57,field=="minimum_interval"and 65534 or 65535

if field=="reportable_change"then
if not descriptor.analog then return false end
local aG=N.ID>=40 and N.ID<=47
au=ak and 3.4028234663852886e38 or(2 ^(8*N.byte_length-(aG and 1 or 0))-1)end
if o>au or(not ak and o%1~=0)then return false end
local i={}for key,aK in pairs(O(b,descriptor,true)or{})do i[key]=aK end
i[field]=o
local ay,r=i.minimum_interval or descriptor.defaults.minimum_interval or 0,i.maximum_interval or descriptor.defaults.maximum_interval or 300

if r~=0 and r~=65535 and ay>r then return false end
if field=="reportable_change"and r==65535 then return false end
d[b]=d[b]or{}d[b][descriptor.key]={selected=i,entry=j,mapping_index=n,targets={},expires=os.time()+30}local Q={[descriptor.group]={[descriptor.key]=true}}local aM,v=pcall(c.send,q,b,j.zcl_clusters,Q,false)if not aM then
d[b][descriptor.key]=nil
return false
end
if v and q.read_metering_scalers then
q.read_metering_scalers(b,j.zcl_clusters)end
return true
end
function c.send_config(b,key,z,endpoint)
local tx,f=H.attr_config(b,z):to_endpoint(endpoint),key and ae(b,key)if f and not f.failed then
f.targets[z.cluster..":"..endpoint]={wire=tx.body.zcl_body:_serialize()}end
b:send(tx)
end
function c.global_handlers(q,E)
local function an(_,b,rx)
local w,endpoint,D,av=rx.address_header.cluster.value,rx.address_header.src_endpoint.value,rx.body.zcl_header.cmd.value,rx.body.zcl_body

local aq=w..":"..endpoint
c.discard_unsupported(q,b)for key in pairs(d[b]or{})do
local f=ae(b,key)local ao=f and f.targets[aq]if ao then
local C=string.unpack("<I2",ao.wire,2)if D==7 then
local aE,tx=require"st.zigbee.zcl.global_commands.read_reporting_configuration",H.attr_refresh(b,w,C):to_endpoint(endpoint)tx.body.zcl_body=aE.ReadReportingConfiguration{aE.ReadReportingConfigurationAttributeRecord(0,C)}tx.body.zcl_header.cmd.value=8
if not pcall(b.send,b,tx)then
d[b][key]=nil
end
elseif D==11 then
if(av.cmd.value==6 or av.cmd.value==8)and av.status.value~=0 then f.failed=true end
else
for _,g in ipairs(av.read_reporting_records)do
if getmetatable(g)==s and g.direction.value==0 and g.attr_id.value==C then
if g:_serialize():sub(2)==ao.wire then
f.targets[aq]=nil
if not next(f.targets)then
b:set_field("zcl_reporting:"..key,f.selected,{persist=true})b:remove_configured_attribute(w,C)d[b][key]=nil
F(q,b,f.entry)end
else
f.failed=true
end
end
end
end
end
end
end
for w in pairs(X)do
E[w]=E[w]or{}for _,D in ipairs{7,9,11}do
local am=E[w][D]if am~=nil then
E[w][D]=function(...)
local M=am(...)an(...)return M
end
else
E[w][D]=an
end
end
end
return E
end
function c.attach(q,ah,S)
for _,W in ipairs(S)do
local j=ah[W[1]]local R,L,af,J=j.runtime_start,j.zcl_refresh_before_read_all,{},{}
for key,aI in pairs(j.protocol_writers or{})do af[key]=aI end
for _,D in ipairs(j.capability_commands or{})do J[#J+1]=D end
j.protocol_writers,j.capability_commands,j.reporting_settings=af,J,{}local Z={zcl_clusters=j.zcl_clusters,reporting_settings=j.reporting_settings}j.profile=W[2]local aF={}for n,l in ipairs(j.zcl_clusters or{})do
local descriptor=c.describe(q,l,nil,false)if descriptor and not aF[descriptor.key]then
aF[descriptor.key]=true
local logical_item=W[3]and W[3][descriptor.key]if logical_item==nil then logical_item=descriptor.item end
if logical_item~=false then
local item={mapping_index=n,key=descriptor.key,capabilities={}}j.reporting_settings[#j.reporting_settings+1]=item
for B,field in ipairs(P)do
if B<3 or descriptor.analog then
local short_id="zcl"..logical_item.."Report"..field[2]..
(B==3 and string.format("%02x",descriptor.meta.data_type.ID)or"")local k,aj,V="concertmirror08464."..short_id,"set"..field[3]:sub(1,1):upper()..field[3]:sub(2),"zcl_reporting_"..short_id

item.capabilities[B]=k
J[#J+1]={capability_id=k,command_name=aj,argument_name=field[3],mapping_name=V,attribute_name=field[3]}
af[V]=function(b,o)
return c.set(q,b,Z,n,field[1],o)
end
end
end
end
end
end
j.runtime_start=function(b,...)
local M
if R then M=R(b,...)end
F(q,b,Z)return M
end
j.zcl_refresh_before_read_all=function(b,...)
local M
if L then M=L(b,...)end
F(q,b,Z)return M
end
end
end
function c.groups(q,b,Y)
local Q={}for _,l in ipairs(Y or{})do
local descriptor=c.describe(q,l,b)if descriptor~=nil then
if O(b,descriptor)~=nil then
Q[descriptor.group]=true
end
end
end
return Q
end
function c.send(q,b,Y,Q,aC)
local I,at,S,v={},{},{},false
for _,l in ipairs(Y or{})do
local descriptor=c.describe(q,l,b)local i=descriptor and Q[descriptor.group]if descriptor~=nil and i and(i==true or i[descriptor.key])and
not(aC and descriptor.meta.reporting_defaults~=nil)then
local e,ar,p=descriptor.meta,q.build_mapping_context(b,l),{}
if e.reporting_defaults and e.reporting_defaults.all_endpoints then
for _,endpoint in pairs(b.zigbee_endpoints or{})do
if b:supports_server_cluster(e.cluster_id,endpoint.id)then p[#p+1]=endpoint.id end
end
table.sort(p)elseif ar.endpoint~=nil then
p[1]=ar.endpoint
elseif e.reporting_defaults~=nil then
p[1]=b:get_endpoint(e.cluster_id)else
for _,endpoint in ipairs(b.zigbee_endpoints or{})do
if b:supports_server_cluster(e.cluster_id,endpoint.id)then p[#p+1]=endpoint.id end
end
if #p==0 then p[1]=b:get_endpoint(e.cluster_id)end
end
local z=c.configuration(q,b,l)if z==nil then v=e.physical_reportable_change~=nil or v end
for _,endpoint in ipairs(p)do
local key=descriptor.group..":"..endpoint
local B,g=at[key],{config=z,endpoint=endpoint,explicit=e.endpoint~=nil,key=descriptor.key}if B==nil then
at[key]=#I+1
I[#I+1]=g
elseif g.explicit and not I[B].explicit then
I[B]=g
end
end
end
end
for _,g in ipairs(I)do
local z,endpoint=g.config,g.endpoint
if z~=nil then
local key=z.cluster..":"..endpoint
if aC and not S[key]then
q.bind_cluster(b,z.cluster,b.driver.environment_info.hub_zigbee_eui,endpoint)S[key]=true
end
c.send_config(b,g.key,z,endpoint)end
end
return v
end
return c
