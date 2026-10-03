local zcl=require"protocol.zcl"
local emit=require"capabilities.events.all"
local device_helpers=require"contracts.helpers.family"
local zcl_device_helpers=require"contracts.helpers.zcl"
local device_management=require"st.zigbee.device_management"
local capabilities=require"st.capabilities"
local data_types=require"st.zigbee.data_types"
local device_definitions,register_device_definition=device_helpers.definition_registry()
local ADUROSMART_MANUFACTURERS={
"AduroSmart ERIA",
"ERIA",
"AduroSmart Eria",}
local function register_aliases(definition,aliases)
register_device_definition(definition,aliases)
end
local function adurosmart_fingerprints(models)
local fingerprints={}
for _,model in ipairs(models)do
for _,manufacturer in ipairs(ADUROSMART_MANUFACTURERS)do
fingerprints[#fingerprints+1]=device_helpers.create_fingerprint(manufacturer,model)
end
end
return fingerprints
end
local function build_adurosmart_light(profile,color)
local definition
definition={
profile=profile,
color_temperature_range={
minimum=math.floor((1000000/500)+0.5),
maximum=math.floor((1000000/153)+0.5),},
zcl_clusters={
zcl.switch({endpoint=1,configure_reporting=false}),
zcl.level({endpoint=1,configure_reporting=false}),
zcl.color_temperature({endpoint=1,configure_reporting=false}),},
runtime_start=function(device)
device:emit_component_event(
{id="main"},
capabilities.colorTemperature.colorTemperatureRange({
value=definition.color_temperature_range,
unit="K",}))
return true
end,
}
if color then
definition.zcl_clusters[#definition.zcl_clusters+1]=
zcl.color_hue({endpoint=1,configure_reporting=false})
definition.zcl_clusters[#definition.zcl_clusters+1]=
zcl.color_saturation({endpoint=1,configure_reporting=false})
definition.zcl_clusters[#definition.zcl_clusters+1]=zcl.color({endpoint=1})
end
return definition
end
local adurosmart_tunable_white=build_adurosmart_light("lights-color-temperature",false)
local adurosmart_color_light=build_adurosmart_light("lights-color-temperature-color",true)
local function clamp_round(value,minimum,maximum)
value=tonumber(value)
if value==nil then return nil end
return math.max(minimum,math.min(maximum,math.floor(value+0.5)))
end
local function level_config_seconds_from_device(value)
value=tonumber(value)
if value==nil then return nil end
return value/10
end
local function level_config_seconds_to_device(value)
if value=="disabled"then return 65535 end
value=tonumber(value)
if value==nil then return nil end
if value>=6553.5 then return 65535 end
return math.max(0,math.min(65534,math.floor((value*10)+0.5)))
end
local candeo_rd1p_dpm={
profile="lights-candeo-rd1p-dpm",
capability_commands={
{
capability_id="concertmirror08464.candeoRd1pDpmOnLevel",
command_name="usePreviousOnLevel",
mapping_name="candeo_rd1p_dpm_on_level",
value="previous",},
{
capability_id="concertmirror08464.candeoRd1pDpmStartupLevel",
command_name="useMinimumStartupLevel",
mapping_name="candeo_rd1p_dpm_startup_level",
value="minimum",},
{
capability_id="concertmirror08464.candeoRd1pDpmStartupLevel",
command_name="usePreviousStartupLevel",
mapping_name="candeo_rd1p_dpm_startup_level",
value="previous",},
{
capability_id="concertmirror08464.candeoRd1pDpmOnTransitionTime",
command_name="disableOnTransitionTime",
mapping_name="candeo_rd1p_dpm_on_transition_time",
value="disabled",},
{
capability_id="concertmirror08464.candeoRd1pDpmOffTransitionTime",
command_name="disableOffTransitionTime",
mapping_name="candeo_rd1p_dpm_off_transition_time",
value="disabled",},},
advanced_remote=true,
unprefixed_remote_actions=true,
remote_action_emit_name="candeoRd1pDpmAction",
standard_command_action_resolver=zcl_device_helpers.resolve_rd1p_rotary_action,
zcl_clusters={
zcl.switch({
endpoint=1,
minimum_interval=0,
maximum_interval=65000,}),
zcl.level({
endpoint=1,
minimum_interval=1,
maximum_interval=3600,
reportable_change=1,}),
zcl.power({
endpoint=1,
minimum_interval=5,
maximum_interval=300,
reportable_change=10,}),
zcl.voltage({
endpoint=1,
minimum_interval=5,
maximum_interval=600,
reportable_change=500,}),
zcl.current({
endpoint=1,
minimum_interval=5,
maximum_interval=900,
reportable_change=10,}),
zcl.energy({
endpoint=1,
minimum_interval=5,
maximum_interval=1800,
reportable_change=50,}),
zcl.cluster_attribute(zcl.CLUSTER_ON_OFF,0x4003,{
name="candeo_rd1p_dpm_power_on_behavior",
emit=emit.candeoRd1pDpmPowerBehavior(),
endpoint=1,
from_device=function(value)
return({[0]="off",[1]="on",[2]="toggle",[255]="previous"})[value]
end,
to_device=function(value)
return({off=0,on=1,toggle=2,previous=255})[value]
end,
data_type=data_types.Enum8,
write_type=data_types.Enum8,
read_on_configure=true,}),
zcl.cluster_attribute(zcl.CLUSTER_LEVEL_CONTROL,0x0011,{
name="candeo_rd1p_dpm_on_level",
emit=emit.candeoRd1pDpmOnLevel(),
endpoint=1,
from_device=function(value)return clamp_round(value,0,255)end,
to_device=function(value)
if value=="previous"then return 255 end
return clamp_round(value,1,255)
end,
numeric_range={minimum=0,maximum=255,step=1},
data_type=data_types.Uint8,
write_type=data_types.Uint8,
read_on_configure=true,}),
zcl.cluster_attribute(zcl.CLUSTER_LEVEL_CONTROL,0x4000,{
name="candeo_rd1p_dpm_startup_level",
emit=emit.candeoRd1pDpmStartupLevel(),
endpoint=1,
from_device=function(value)return clamp_round(value,0,255)end,
to_device=function(value)
if value=="minimum"then return 0 end
if value=="previous"then return 255 end
return clamp_round(value,0,255)
end,
numeric_range={minimum=0,maximum=255,step=1},
data_type=data_types.Uint8,
write_type=data_types.Uint8,
read_on_configure=true,}),
zcl.cluster_attribute(zcl.CLUSTER_LEVEL_CONTROL,0x0012,{
name="candeo_rd1p_dpm_on_transition_time",
emit=emit.candeoRd1pDpmOnTransitionTime(),
endpoint=1,
from_device=level_config_seconds_from_device,
to_device=level_config_seconds_to_device,
numeric_range={minimum=0,maximum=6553.5,step=0.1,unit="s"},
data_type=data_types.Uint16,
write_type=data_types.Uint16,
read_on_configure=true,}),
zcl.cluster_attribute(zcl.CLUSTER_LEVEL_CONTROL,0x0013,{
name="candeo_rd1p_dpm_off_transition_time",
emit=emit.candeoRd1pDpmOffTransitionTime(),
endpoint=1,
from_device=level_config_seconds_from_device,
to_device=level_config_seconds_to_device,
numeric_range={minimum=0,maximum=6553.5,step=0.1,unit="s"},
data_type=data_types.Uint16,
write_type=data_types.Uint16,
read_on_configure=true,}),},
configure=function(driver,device)
for _,binding in ipairs({
{endpoint=1,cluster_id=zcl.CLUSTER_ON_OFF},
{endpoint=1,cluster_id=zcl.CLUSTER_LEVEL_CONTROL},
{endpoint=1,cluster_id=zcl.CLUSTER_ELECTRICAL_MEASUREMENT},
{endpoint=1,cluster_id=zcl.CLUSTER_SIMPLE_METERING},
{endpoint=2,cluster_id=zcl.CLUSTER_ON_OFF},
{endpoint=2,cluster_id=zcl.CLUSTER_LEVEL_CONTROL},
})do
device:send(device_management.build_bind_request(
device,
binding.cluster_id,
driver.environment_info.hub_zigbee_eui,
binding.endpoint))
end
end,
}
local paulmann_rgbww
paulmann_rgbww={
profile="lights-paulmann-rgbww",
auto_on_before_light_command=false,
capability_commands={
{
capability_id="concertmirror08464.paulmannRgbwwStartupCct",
command_name="restorePaulmannRgbwwPreviousCct",
mapping_name="paulmann_rgbww_startup_color_temperature",
value=65535,},},
color_temperature_range={
minimum=math.floor((1000000/454)+0.5),
maximum=math.floor((1000000/153)+0.5),},
zcl_clusters={
zcl.switch({configure_reporting=false}),
zcl.level({configure_reporting=false}),
zcl.color_temperature({
configure_reporting=false,
to_device=function(value)return math.max(153,math.min(454,math.floor(1000000/value+0.5)))end,
}),
zcl.color_hue({configure_reporting=false}),
zcl.color_saturation({configure_reporting=false}),
zcl.color(),
zcl.cluster_attribute(zcl.CLUSTER_ON_OFF,0x4003,{
name="paulmann_rgbww_power_on_behavior",
emit=emit.paulmannRgbwwPowerOnBehavior(),
from_device=function(value)
value=type(value)=="table"and value.value or value
return({[0]="off",[1]="on",[2]="toggle",[255]="previous"})[value]
end,
to_device=function(value)
return({off=0,on=1,toggle=2,previous=255})[value]
end,
data_type=data_types.Enum8,
write_type=data_types.Enum8,}),
zcl.cluster_attribute(zcl.CLUSTER_COLOR_CONTROL,0x4010,{
name="paulmann_rgbww_startup_color_temperature",
emit=emit.paulmannRgbwwStartupCct(),
from_device=function(value)return value end,
to_device=function(value)
value=tonumber(value)
if value==65535 then return value end
if value==nil then return nil end
return math.max(153,math.min(454,math.floor(value+0.5)))
end,
data_type=data_types.Uint16,
write_type=data_types.Uint16,}),
zcl.cluster_attribute(0x0003,0xFFFF,{
name="paulmann_rgbww_effect",
emit=emit.paulmannRgbwwEffect(),
write_only=true,
sender=zcl.send_light_effect,}),},
configure=function(_,device)
for _,attribute in ipairs({0x400A,0x400B,0x400C})do
zcl.read_mapping(device,zcl.cluster_attribute(0x0300,attribute,{endpoint=1}))
end
end,
runtime_start=function(device)
device:emit_component_event(
{id="main"},
capabilities.colorTemperature.colorTemperatureRange({
value=paulmann_rgbww.color_temperature_range,
unit="K",}))
return true
end,
}
zcl_device_helpers.append_clusters(paulmann_rgbww.zcl_clusters,zcl.color_xy({endpoint=1}))
local hejhome_z26
hejhome_z26={
profile="lights-color-temperature-color",
color_temperature_range={
minimum=math.floor((1000000/500)+0.5),
maximum=math.floor((1000000/153)+0.5),},
zcl_clusters={
zcl.switch({endpoint=1}),
zcl.level({endpoint=1}),
zcl.color_temperature({endpoint=1}),
zcl.color_hue({endpoint=1}),
zcl.color_saturation({endpoint=1}),
zcl.color({endpoint=1}),
zcl.cluster_attribute(0x0000,0x0001,{
name="hejhome_z26_app_version_keepalive",
endpoint=1,
read_only=true,
data_type=data_types.Uint8,
read_on_configure=true,
poll_interval=120,}),},
runtime_start=function(device)
device:emit_component_event(
{id="main"},
capabilities.colorTemperature.colorTemperatureRange({
value=hejhome_z26.color_temperature_range,
unit="K",}))
return true
end,
}
local function luumr_g9_setting_sender(device,mapping,value,context)
if mapping.name=="luumr_g9_do_not_disturb"then
return zcl.send_raw_cluster_command(device,0x0300,0xFA,string.char(value=="enabled"and 1 or 0),context.endpoint or 1)
end
local effect=({blink=0,breathe=1,okay=2,channel_change=11,finish_effect=254,stop_effect=255})[value]
return zcl.send_raw_cluster_command(device,3,0x40,string.char(effect,0),context.endpoint or 1)
end
local luumr_g9={
profile="lights-luumr-g9",
auto_on_before_light_command=false,
color_temperature_range={minimum=2000,maximum=6536},
zcl_clusters={
zcl.tuya_magic_packet({read_on_configure=false}),
zcl.switch({endpoint=1,minimum_interval=0,maximum_interval=65000}),
zcl.level({endpoint=1,minimum_interval=5,maximum_interval=65000,reportable_change=1}),
zcl.color_temperature({
endpoint=1,minimum_interval=10,maximum_interval=65000,reportable_change=1,
to_device=function(value)return math.max(153,math.min(500,math.floor(1000000/value+0.5)))end,
}),
zcl.cluster_attribute(8,0xF000,{
name="luumr_g9_tuya_brightness",endpoint=1,data_type=data_types.Uint16,read_only=true,emit=emit.level(),
from_device=function(value)return math.floor(value/10+0.5)end,
}),
zcl.cluster_attribute(3,0xFFFF,{
name="luumr_g9_effect",endpoint=1,write_only=true,suppress_optimistic_state=true,
emit=emit.luumrG9Effect(),sender=luumr_g9_setting_sender,}),
zcl.cluster_attribute(0x0300,0xFFFE,{
name="luumr_g9_do_not_disturb",endpoint=1,write_only=true,
emit=emit.luumrG9DoNotDisturb(),sender=luumr_g9_setting_sender,}),},
configure=function(driver,device)
local hub_eui=driver.environment_info.hub_zigbee_eui
for _,cluster in ipairs({6,8,0x0300})do zcl.bind_cluster(device,cluster,hub_eui,1)end
for _,attribute in ipairs({0x400A,0x400B,0x400C})do zcl.read_attribute(device,0x0300,attribute,1)end
end,
runtime_start=function(device)
device:emit_component_event({id="main"},capabilities.colorTemperature.colorTemperatureRange({value={minimum=2000,maximum=6536},unit="K"}))
return true
end,
parent_refresh=function(device)
for _,item in ipairs({{6,0},{8,0},{0x0300,7}})do zcl.read_attribute(device,item[1],item[2],1)end
return true
end,
}
local function tuya_hs_setting_sender(device,mapping,value,context)
if mapping.name:sub(-7)=="_effect"then
local endpoint=context.endpoint or 1
if value=="colorloop"or value=="stop_colorloop"then
local sent=zcl.send_raw_cluster_command(device,0x0300,1,
string.char(value=="colorloop"and 1 or 0,value=="colorloop"and 17 or 1,0,0),endpoint)
if value=="stop_colorloop"and sent~=false then
device.thread:call_with_delay(0.1,function()
zcl.read_attribute(device,0x0300,0,endpoint)
zcl.read_attribute(device,0x0300,8,endpoint)
end)
end
return sent
end
local effect=({blink=0,breathe=1,okay=2,channel_change=11,finish_effect=254,stop_effect=255})[value]
return zcl.send_raw_cluster_command(device,3,0x40,string.char(effect,0),endpoint)
end
if mapping.name:find("_do_not_disturb",1,true)then
return zcl.send_raw_cluster_command(device,0x0300,0xFA,string.char(value=="enabled"and 1 or 0),context.endpoint or 1)
end
local mode=({initial=0,previous=1,customized=2})[value]
return zcl.send_raw_cluster_command(device,0x0300,0xF9,string.char(0,mode)..string.rep("\0",10),context.endpoint or 1)
end
local function build_tuya_hs_light(profile,prefix,color_temperature)
local definition={
profile=profile,
auto_on_before_light_command=false,
placeholder_custom_states=false,
initial_custom_state_query=false,
zcl_clusters={
zcl.switch({endpoint=1,configure_reporting=false}),
zcl.level({endpoint=1,configure_reporting=false}),
zcl.color_hue({endpoint=1,configure_reporting=false}),
zcl.color_saturation({endpoint=1,configure_reporting=false}),
zcl.color({endpoint=1}),
zcl.cluster_attribute(8,0xF000,{
name=prefix.."_tuya_brightness",endpoint=1,data_type=data_types.Uint16,read_only=true,
emit=emit.level(),from_device=function(value)return math.floor(value/10+0.5)end,
}),
zcl.cluster_attribute(3,0xFFFF,{
name=prefix.."_effect",endpoint=1,write_only=true,suppress_optimistic_state=true,
emit=emit[prefix.."Effect"](),sender=tuya_hs_setting_sender,}),
zcl.cluster_attribute(0x0300,0xFFFE,{
name=prefix.."_do_not_disturb",endpoint=1,write_only=true,
emit=emit[prefix.."DoNotDisturb"](),sender=tuya_hs_setting_sender,}),
zcl.cluster_attribute(0x0300,0xFFFD,{
name=prefix.."_color_power_on_behavior",endpoint=1,write_only=true,
emit=emit[prefix.."ColorPowerOnBehavior"](),sender=tuya_hs_setting_sender,}),},
configure=function(_,device)
for _,attribute in ipairs({0x400A,0x400B,0x400C})do zcl.read_attribute(device,0x0300,attribute,1)end
end,
parent_refresh=function(device)
for _,item in ipairs({{6,0},{8,0},{0x0300,0},{0x0300,1},{0x0300,8}})do
zcl.read_attribute(device,item[1],item[2],1)
end
if color_temperature then zcl.read_attribute(device,0x0300,7,1)end
return true
end,
}
if color_temperature then
definition.color_temperature_range={minimum=2000,maximum=6536}
definition.zcl_clusters[#definition.zcl_clusters+1]=zcl.color_temperature({
endpoint=1,configure_reporting=false,
to_device=function(value)return math.max(153,math.min(500,math.floor(1000000/value+0.5)))end,
})
definition.runtime_start=function(device)
device:emit_component_event({id="main"},capabilities.colorTemperature.colorTemperatureRange({value={minimum=2000,maximum=6536},unit="K"}))
return true
end
end
return definition
end
local tuya_ts0505b_hs=build_tuya_hs_light("lights-tuya-ts0505b-hs","ts0505bHs",true)
local tuya_ts0503b_hs=build_tuya_hs_light("lights-tuya-ts0503b-hs","ts0503bHs",false)
register_aliases(candeo_rd1p_dpm,{
device_helpers.create_fingerprint("Candeo","C-ZB-RD1Pv2-DPM"),})
register_aliases(paulmann_rgbww,{
device_helpers.create_fingerprint("Paulmann Licht GmbH","RGBWW"),})
register_aliases(hejhome_z26,{
device_helpers.create_fingerprint("_TZ3210_cnicaghm","TS0505B"),})
register_aliases(adurosmart_tunable_white,adurosmart_fingerprints({
"AD-DL4CT3001",
"AD-DL4CTW3001",
"AD-DL6CT3001",
"AD-DL6CTW3001",
"AD-FLMCT3001",}))
register_aliases(adurosmart_color_light,adurosmart_fingerprints({
"AD-DL4RGBW3001",
"AD-DL6RGBW3001",
"AD-GU10RGB3001",
"AD-GU10RGBW3001",}))
register_aliases(luumr_g9,{
device_helpers.create_fingerprint("_TZ3210_tqwyiitv","TS0502B"),})
register_aliases(tuya_ts0505b_hs,{
device_helpers.create_fingerprint("_TZ3210_ffuna0nr","TS0505B"),})
register_aliases(tuya_ts0503b_hs,{
device_helpers.create_fingerprint("_TZ3210_rbixajyp","TS0503B"),
device_helpers.create_fingerprint("_TZ3210_w7ge4ldo","TS0503B"),})
return{
id="zcl.lights.z2m_absorption",
registrations=device_definitions,}
