local function load_mapping_preset(zcl)
local emit=require"capabilities.events.all"
local data_types=require"st.zigbee.data_types"
local zigbee_constants=require"st.zigbee.constants"
local safe_xy_to_hsv=require"st.utils.safe_xy_to_hsv"
local function merge_options(target,source)
if type(target)~="table"then
target={}
end
if type(source)~="table"then
return target
end
for key,value in pairs(source)do
target[key]=value
end
return target
end
local function apply_defaults(target,defaults)
if type(target)~="table"or type(defaults)~="table"then
return target
end
for key,value in pairs(defaults)do
if target[key]==nil then
target[key]=value
end
end
return target
end
local function normalize_preset_options(name_or_options,options)
local resolved={}if type(name_or_options)=="string"then
resolved.name=name_or_options
else
merge_options(resolved,name_or_options)
end
merge_options(resolved,options)return resolved
end
local function clamp(value,min_value,max_value)
if value<min_value then
return min_value
end
if value>max_value then
return max_value
end
return value
end
local function level_percent_pair()
return{
from=function(value)
if type(value)~="number"then
return value
end
return math.floor((clamp(value,0,254)*100/254)+0.5)
end,
to=function(value)
if type(value)~="number"then
return value
end
return math.floor((clamp(value,0,100)*254/100)+0.5)
end,
}
end
local function percent_254_pair()
return{
from=function(value)
if type(value)~="number"then
return value
end
return math.floor((clamp(value,0,254)*100/254)+0.5)
end,
to=function(value)
if type(value)~="number"then
return value
end
return math.floor((clamp(value,0,100)*254/100)+0.5)
end,
}
end
local function color_temperature_pair()
local conversion_constant=1000000
return{
from=function(value)
if type(value)~="number"or value<=0 then
return value
end
return math.floor((conversion_constant/value)+0.5)
end,
to=function(value)
if type(value)~="number"or value<=0 then
return value
end
return math.floor((conversion_constant/value)+0.5)
end,
}
end
local function reporting_defaults(minimum_interval,maximum_interval,reportable_change)
return{
minimum_interval=minimum_interval,maximum_interval=maximum_interval,reportable_change=reportable_change,read_on_configure=true,}
end
local function merge_defaults(...)
local merged={}for _,defaults in ipairs({...})do
apply_defaults(merged,defaults)
end
return merged
end
local function define_preset(name,factory,defaults_builder)
zcl[name]=function(name_or_options,options)
local resolved=normalize_preset_options(name_or_options,options)apply_defaults(resolved,defaults_builder(resolved))return factory(resolved)
end
end
define_preset("switch",zcl.on_off,function(options)
local configure_reporting=options.configure_reporting
options.configure_reporting=nil
if configure_reporting==false then
return{
emit=emit.switch(),}
end
return merge_defaults(
{
emit=emit.switch(),},reporting_defaults(0,300,nil))
end)
zcl.tuya_magic_packet=function(name_or_options,options)
local resolved=normalize_preset_options(name_or_options,options)apply_defaults(resolved,{
name="tuya_magic_packet",read_only=true,read_on_configure=true,})return zcl.cluster_attribute(0x0000,0xFFFE,resolved)
end
define_preset("level",zcl.level_control,function(options)
local configure_reporting=options.configure_reporting
options.configure_reporting=nil
local defaults={
name="brightness",emit=emit.level(),converter=level_percent_pair(),}
if configure_reporting==false then return defaults end
return merge_defaults(defaults,reporting_defaults(1,3600,1))
end)
define_preset("power",zcl.electrical_measurement_power,function()
return merge_defaults(
{
emit=emit.power(),metering_kind="power",poll_interval=300,},reporting_defaults(5,300,1))
end)
define_preset("current",zcl.electrical_measurement_current,function()
return merge_defaults(
{
emit=emit.current(),scale=1000,metering_kind="current",poll_interval=300,},reporting_defaults(5,300,1))
end)
define_preset("voltage",zcl.electrical_measurement_voltage,function()
return merge_defaults(
{
emit=emit.voltage(),metering_kind="voltage",poll_interval=300,},reporting_defaults(5,300,1))
end)
define_preset("energy",zcl.simple_metering,function()
return{
emit=emit.energy(),read_on_configure=true,metering_kind="energy",poll_interval=900,}
end)
define_preset("color_temperature",zcl.color_control_temperature,function(options)
local configure_reporting=options.configure_reporting
options.configure_reporting=nil
local defaults={
name="color_temperature",emit=emit.color_temperature(),converter=color_temperature_pair(),tx_command_id=0x0A,}
if configure_reporting==false then return defaults end
return merge_defaults(defaults,reporting_defaults(1,300,1))
end)
define_preset("color_hue",zcl.color_control_hue,function(options)
local configure_reporting=options.configure_reporting
options.configure_reporting=nil
local defaults={
name="color_hue",emit=emit.color_hue(),converter=percent_254_pair(),tx_command_id=0x00,
to_device=function(value)
local encoded=percent_254_pair().to(value)return{encoded,0x00,0x0000,0x00,0x00}
end,
}
if configure_reporting==false then return defaults end
return merge_defaults(defaults,reporting_defaults(1,300,1))
end)
define_preset("color_saturation",zcl.color_control_saturation,function(options)
local configure_reporting=options.configure_reporting
options.configure_reporting=nil
local defaults={
name="color_saturation",emit=emit.color_saturation(),converter=percent_254_pair(),tx_command_id=0x03,
to_device=function(value)
local encoded=percent_254_pair().to(value)return{encoded,0x0000,0x00,0x00}
end,
}
if configure_reporting==false then return defaults end
return merge_defaults(defaults,reporting_defaults(1,300,1))
end)
zcl.color=function(name_or_options,options)
local resolved=normalize_preset_options(name_or_options,options)apply_defaults(resolved,{
name="color",cluster_id=zcl.CLUSTER_COLOR_CONTROL,attribute_id=zcl.ATTR_CURRENT_HUE,write_only=true,tx_command_id=0x06,
to_device=function(value)
if type(value)~="table"then
return value
end
local hue=percent_254_pair().to(value.hue)local saturation=percent_254_pair().to(value.saturation)if type(hue)~="number"or type(saturation)~="number"then
return nil
end
return{hue,saturation,0x0000,0x00,0x00}
end,
})return zcl.cluster_attribute(resolved.cluster_id,resolved.attribute_id,resolved)
end
function zcl.color_xy(options)
local function receive(value,device,context,mapping)
value=type(value)=="table"and value.value or value
local prefix="_zcl_color_xy_"..tostring(context.endpoint or 1).."_"
device:set_field(prefix..mapping.name,value)local x,y=device:get_field(prefix.."color_x"),device:get_field(prefix.."color_y")local mode=device:get_field(prefix.."color_mode")if x~=nil and y~=nil and(mode==nil or mode==0)then
local hue,saturation=safe_xy_to_hsv(x,y)local component=context.component or{id=context.component_id or"main"}device:emit_component_event(component,emit.color_hue()(device,hue))device:emit_component_event(component,emit.color_saturation()(device,saturation))
end
end
local mappings={}for _,item in ipairs({{"color_x",0x0003},{"color_y",0x0004},{"color_mode",0x0008}})do
local resolved=merge_options({},options)resolved.name,resolved.read_only,resolved.from_device=item[1],true,receive
resolved.data_type=item[2]==0x0008 and data_types.Enum8 or data_types.Uint16
mappings[#mappings+1]=zcl.cluster_attribute(zcl.CLUSTER_COLOR_CONTROL,item[2],resolved)
end
return mappings
end
function zcl.send_light_effect(device,mapping,value,context)
local endpoint=context.endpoint or 1
local cluster,command,payload=0x0003,0x40,nil
if value=="colorloop"or value=="stop_colorloop"then
cluster,command=0x0300,0x01
payload=string.char(value=="colorloop"and 1 or 0,value=="colorloop"and 17 or 1,0,0)else
local effect=({blink=0,breathe=1,okay=2,channel_change=11,finish_effect=254,stop_effect=255})[value]
if effect==nil then return false end
payload=string.char(effect,0)
end
local sent=zcl.send_raw_cluster_command(device,cluster,command,payload,endpoint)if sent~=false then
device:emit_component_event({id=context.component_id or"main"},mapping.emit(device,value))if value=="stop_colorloop"then
device.thread:call_with_delay(0.1,function()
zcl.read_mapping(device,zcl.cluster_attribute(0x0300,0x0000,{endpoint=endpoint}))zcl.read_mapping(device,zcl.cluster_attribute(0x0300,0x0008,{endpoint=endpoint}))
end,"light colorloop stopped")
end
end
return sent
end
end
return load_mapping_preset
