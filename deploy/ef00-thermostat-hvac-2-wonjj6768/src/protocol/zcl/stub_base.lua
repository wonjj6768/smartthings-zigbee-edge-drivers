local cluster_base=require "st.zigbee.cluster_base"
local data_types=require "st.zigbee.data_types"
local device_management=require "st.zigbee.device_management"
local function build_stub()
local zcl={}
zcl.CLUSTER_ON_OFF=0x0006
zcl.CLUSTER_POWER_CONFIGURATION=0x0001
zcl.CLUSTER_IAS_ZONE=0x0500
zcl.CLUSTER_ILLUMINANCE=0x0400
zcl.CLUSTER_OCCUPANCY_SENSING=0x0406
zcl.ATTR_ON_OFF=0x0000
zcl.ATTR_BATTERY_VOLTAGE=0x0020
zcl.ATTR_BATTERY_PERCENTAGE_REMAINING=0x0021
zcl.ATTR_ZONE_STATUS=0x0002
zcl.ATTR_MEASURED_VALUE=0x0000
zcl.ATTR_OCCUPANCY=0x0000
function zcl.cluster_attribute(cluster_id,attribute_id,options)
local mapping=options or{}
mapping.protocol="zcl"
mapping.cluster_id=cluster_id
mapping.attribute_id=attribute_id
return mapping
end
function zcl.switch(options)
local mapping=zcl.cluster_attribute(zcl.CLUSTER_ON_OFF,zcl.ATTR_ON_OFF,options or{})
if mapping.name==nil then mapping.name="switch" end
return mapping
end
function zcl.battery(options)
local mapping=zcl.cluster_attribute(
zcl.CLUSTER_POWER_CONFIGURATION,
zcl.ATTR_BATTERY_PERCENTAGE_REMAINING,
options or{}
)
if mapping.name==nil then mapping.name="battery" end
if mapping.scale==nil then mapping.scale=2 end
return mapping
end
function zcl.register_attributes_from_mappings(value)return value end
function zcl.register_cluster_commands_from_mappings(value)return value end
function zcl.prepare_mappings(value)return value end
function zcl.has_cluster(...)return false end
function zcl.build_zigbee_global_handlers(_)return{}end
function zcl.start_runtime(...)return false end
function zcl.send_named_command(...)return false end
function zcl.send_raw_cluster_command(...)return false end
function zcl.register_cluster_command_handler(...)return nil end
function zcl.read_named_attribute(...)return false end
function zcl.read_all_attributes(...)return false end
function zcl.find_mapping_by_name(...)return nil end
function zcl.emit_power_polling_state(...)return false end
function zcl.set_power_poll_interval(...)return false end
function zcl.begin_power_poll_burst(...)return false end
function zcl.read_attribute(device,cluster_id,attribute_id,endpoint)
local request=cluster_base.read_attribute(
device,
data_types.ClusterId(cluster_id),
data_types.AttributeId(attribute_id)
)
if endpoint ~=nil and type(request.to_endpoint)=="function" then
request=request:to_endpoint(endpoint)
end
device:send(request)
return true
end
local function stub_emit(device,mapping,value)
if mapping.emit==nil then
return
end
local event=mapping.emit(device,value,{},mapping)
if event==nil then
return
end
if mapping.component ~=nil and type(device.emit_component_event)=="function" then
device:emit_component_event({id=mapping.component},event)
return
end
device:emit_event(event)
end
local function matching_mappings(zcl_clusters,cluster_id,attribute_id)
local found={}
for _,mapping in ipairs(zcl_clusters or{})do
if mapping.cluster_id==cluster_id and mapping.attribute_id==attribute_id then
found[#found + 1]=mapping
end
end
return found
end
local function raw_value(value)
if type(value)=="table" and value.value ~=nil then
return value.value
end
return value
end
function zcl.build_zigbee_attr_handlers(get_preset)
local function factory(cluster_id,attribute_id,transform)
return function(_,device,value)
local preset=get_preset(device)
if preset==nil or preset.zcl_clusters==nil then
return
end
local raw=raw_value(value)
for _,mapping in ipairs(matching_mappings(preset.zcl_clusters,cluster_id,attribute_id))do
stub_emit(device,mapping,transform(raw,mapping))
end
end
end
return{
[zcl.CLUSTER_ON_OFF]={
[zcl.ATTR_ON_OFF]=factory(zcl.CLUSTER_ON_OFF,zcl.ATTR_ON_OFF,function(raw)
return raw==true or raw==1
end),
},
[zcl.CLUSTER_POWER_CONFIGURATION]={
[zcl.ATTR_BATTERY_PERCENTAGE_REMAINING]=factory(
zcl.CLUSTER_POWER_CONFIGURATION,
zcl.ATTR_BATTERY_PERCENTAGE_REMAINING,
function(raw,mapping)
local scale=mapping.scale
if type(raw)=="number" and type(scale)=="number" and scale ~=0 then
return raw / scale
end
return raw
end
),
},
[zcl.CLUSTER_ILLUMINANCE]={
[zcl.ATTR_MEASURED_VALUE]=factory(
zcl.CLUSTER_ILLUMINANCE,
zcl.ATTR_MEASURED_VALUE,
function(raw)
if type(raw)~="number" then
return raw
end
if raw <=0 then
return 0
end
return math.floor(10 ^((raw - 1)/ 10000)+ 0.5)
end
),
},
}
end
function zcl.build_zigbee_cluster_handlers(get_preset)
local function zone_status_handler(_,device,zb_rx)
local preset=get_preset(device)
if preset==nil or preset.zcl_clusters==nil then
return
end
local zcl_body=zb_rx and zb_rx.body and zb_rx.body.zcl_body or nil
local zone_status=zcl_body and zcl_body.zone_status or nil
if zone_status==nil then
return
end
local bits=type(zone_status)=="table" and zone_status.value or zone_status
if type(bits)~="number" then
return
end
for _,mapping in ipairs(matching_mappings(
preset.zcl_clusters,
zcl.CLUSTER_IAS_ZONE,
zcl.ATTR_ZONE_STATUS
))do
local mask=mapping.zone_status_mask
if type(mask)=="number" then
stub_emit(device,mapping,(bits %(mask * 2))>=mask)
end
end
end
return{
[zcl.CLUSTER_IAS_ZONE]={
[0x00]=zone_status_handler,
},
}
end
function zcl.start_configuration(device,zcl_clusters)
local seen={}
for _,mapping in ipairs(zcl_clusters or{})do
local cluster_id=mapping.cluster_id
if type(cluster_id)=="number" and not seen[cluster_id]then
seen[cluster_id]=true
device:send(device_management.build_bind_request(
device,
cluster_id,
device.driver.environment_info.hub_zigbee_eui
))
end
end
return true
end
return zcl
end
return build_stub
