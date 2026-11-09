local u,r,h=require"st.zigbee.cluster_base",require"st.zigbee.data_types",require"st.zigbee.device_management"
local function w()
local b={}
function b.attach_reporting_capabilities(...)end
function b.configure_reporting(...)return false end
b.CLUSTER_ON_OFF=6
b.CLUSTER_POWER_CONFIGURATION=1
b.CLUSTER_IAS_ZONE=1280
b.CLUSTER_ILLUMINANCE=1024
b.CLUSTER_OCCUPANCY_SENSING=1030
b.ATTR_ON_OFF=0
b.ATTR_BATTERY_VOLTAGE=32
b.ATTR_BATTERY_PERCENTAGE_REMAINING=33
b.ATTR_ZONE_STATUS=2
b.ATTR_MEASURED_VALUE=0
b.ATTR_OCCUPANCY=0
function b.bind_cluster(d,c,E,n)
d:send(h.build_bind_request(d,c,E,n))return true
end
function b.cluster_attribute(c,e,l)
local a=l or{}a.protocol="zcl"a.cluster_id=c
a.attribute_id=e
return a
end
function b.switch(l)
local a=b.cluster_attribute(b.CLUSTER_ON_OFF,b.ATTR_ON_OFF,l or{})if a.name==nil then a.name="switch"end
return a
end
function b.battery(l)
local a=b.cluster_attribute(b.CLUSTER_POWER_CONFIGURATION,b.ATTR_BATTERY_PERCENTAGE_REMAINING,l or{})if a.name==nil then a.name="battery"end
if a.scale==nil then a.scale=2 end
return a
end
function b.register_attributes_from_mappings(f)return f end
function b.register_cluster_commands_from_mappings(f)return f end
function b.prepare_mappings(f)return f end
function b.has_cluster(...)return false end
function b.build_zigbee_global_handlers(_)return{}end
function b.start_runtime(...)return false end
function b.send_named_command(...)return false end
function b.send_raw_cluster_command(...)return false end
function b.register_cluster_command_handler(...)return nil end
function b.read_named_attribute(...)return false end
function b.read_all_attributes(...)return false end
function b.find_mapping_by_name(...)return nil end
function b.emit_power_polling_state(...)return false end
function b.set_power_poll_interval(...)return false end
function b.begin_power_poll_burst(...)return false end
function b.read_attribute(d,c,e,n)
local q=u.read_attribute(d,r.ClusterId(c),r.AttributeId(e))if n~=nil and type(q.to_endpoint)=="function"then
q=q:to_endpoint(n)end
d:send(q)return true
end
local function t(d,a,f)
if a.emit==nil then
return
end
local x=a.emit(d,f,{},a)if x==nil then
return
end
if a.component~=nil and type(d.emit_component_event)=="function"then
d:emit_component_event({id=a.component},x)return
end
d:emit_event(x)
end
local function i(k,c,e)
local y={}for _,a in ipairs(k or{})do
if a.cluster_id==c and a.attribute_id==e then
y[#y+1]=a
end
end
return y
end
local function B(f)
if type(f)=="table"and f.value~=nil then
return f.value
end
return f
end
function b.build_zigbee_attr_handlers(o)
local function s(c,e,C)
return function(_,d,f)
local j=o(d)if j==nil or j.zcl_clusters==nil then
return
end
local m=B(f)for _,a in ipairs(i(j.zcl_clusters,c,e))do
t(d,a,C(m,a))end
end
end
return{[b.CLUSTER_ON_OFF]={
[b.ATTR_ON_OFF]=s(b.CLUSTER_ON_OFF,b.ATTR_ON_OFF,function(m)
return m==true or m==1
end)
},[b.CLUSTER_POWER_CONFIGURATION]={[b.ATTR_BATTERY_PERCENTAGE_REMAINING]=s(b.CLUSTER_POWER_CONFIGURATION,b.ATTR_BATTERY_PERCENTAGE_REMAINING,
function(m,a)
local z=a.scale
if type(m)=="number"and type(z)=="number"and z~=0 then
return m/z
end
return m
end
)},[b.CLUSTER_ILLUMINANCE]={[b.ATTR_MEASURED_VALUE]=s(b.CLUSTER_ILLUMINANCE,b.ATTR_MEASURED_VALUE,
function(m)
if type(m)~="number"then
return m
end
if m<=0 then
return 0
end
return math.floor(10 ^((m-1)/10000)+0.5)
end
)}}
end
function b.build_zigbee_cluster_handlers(o)
local function p(_,d,A)
local j=o(d)if j==nil or j.zcl_clusters==nil then
return
end
local v=A and A.body and A.body.zcl_body or nil
local g=v and v.zone_status or nil
if g==nil then
return
end
local F=type(g)=="table"and g.value or g
if type(F)~="number"then
return
end
for _,a in ipairs(i(j.zcl_clusters,b.CLUSTER_IAS_ZONE,b.ATTR_ZONE_STATUS))do
local D=a.zone_status_mask
if type(D)=="number"then
t(d,a,(F%(D*2))>=D)end
end
end
return{[b.CLUSTER_IAS_ZONE]={[0]=p}}
end
function b.start_configuration(d,k)
local G={}for _,a in ipairs(k or{})do
local c=a.cluster_id
if type(c)=="number"and not G[c]then
G[c]=true
d:send(h.build_bind_request(d,c,d.driver.environment_info.hub_zigbee_eui))end
end
return true
end
return b
end
return w
