local zcl=require "protocol.zcl"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local zcl_device_helpers=require "contracts.helpers.zcl"
local device_management=require "st.zigbee.device_management"
local capabilities=require "st.capabilities"
local data_types=require "st.zigbee.data_types"
local device_definitions,register_device_definition=device_helpers.definition_registry()
local function register_aliases(definition,aliases)
register_device_definition(definition,aliases)
end
local function clamp_round(value,minimum,maximum)
value=tonumber(value)
if value==nil then return nil end
return math.max(minimum,math.min(maximum,math.floor(value + 0.5)))
end
local function level_config_seconds_from_device(value)
value=tonumber(value)
if value==nil then return nil end
return value / 10
end
local function level_config_seconds_to_device(value)
if value=="disabled" then return 65535 end
value=tonumber(value)
if value==nil then return nil end
if value >=6553.5 then return 65535 end
return math.max(0,math.min(65534,math.floor((value * 10)+ 0.5)))
end
local candeo_rd1p_dpm={
profile="lights-candeo-rd1p-dpm",
capability_commands={
{
capability_id="concertmirror08464.candeoRd1pDpmOnLevel",
command_name="usePreviousOnLevel",
mapping_name="candeo_rd1p_dpm_on_level",
value="previous",
},
{
capability_id="concertmirror08464.candeoRd1pDpmStartupLevel",
command_name="useMinimumStartupLevel",
mapping_name="candeo_rd1p_dpm_startup_level",
value="minimum",
},
{
capability_id="concertmirror08464.candeoRd1pDpmStartupLevel",
command_name="usePreviousStartupLevel",
mapping_name="candeo_rd1p_dpm_startup_level",
value="previous",
},
{
capability_id="concertmirror08464.candeoRd1pDpmOnTransitionTime",
command_name="disableOnTransitionTime",
mapping_name="candeo_rd1p_dpm_on_transition_time",
value="disabled",
},
{
capability_id="concertmirror08464.candeoRd1pDpmOffTransitionTime",
command_name="disableOffTransitionTime",
mapping_name="candeo_rd1p_dpm_off_transition_time",
value="disabled",
},
},
advanced_remote=true,
unprefixed_remote_actions=true,
remote_action_emit_name="candeoRd1pDpmAction",
standard_command_action_resolver=zcl_device_helpers.resolve_rd1p_rotary_action,
zcl_clusters={
zcl.switch({
endpoint=1,
minimum_interval=0,
maximum_interval=65000,
reportable_change=1,
}),
zcl.level({
endpoint=1,
minimum_interval=1,
maximum_interval=3600,
reportable_change=1,
}),
zcl.power({
endpoint=1,
minimum_interval=5,
maximum_interval=300,
reportable_change=10,
}),
zcl.voltage({
endpoint=1,
minimum_interval=5,
maximum_interval=600,
reportable_change=500,
}),
zcl.current({
endpoint=1,
minimum_interval=5,
maximum_interval=900,
reportable_change=10,
}),
zcl.energy({
endpoint=1,
minimum_interval=5,
maximum_interval=1800,
reportable_change=50,
}),
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
read_on_configure=true,
}),
zcl.cluster_attribute(zcl.CLUSTER_LEVEL_CONTROL,0x0011,{
name="candeo_rd1p_dpm_on_level",
emit=emit.candeoRd1pDpmOnLevel(),
endpoint=1,
from_device=function(value)return clamp_round(value,0,255)end,
to_device=function(value)
if value=="previous" then return 255 end
return clamp_round(value,1,255)
end,
numeric_range={minimum=0,maximum=255,step=1},
data_type=data_types.Uint8,
write_type=data_types.Uint8,
read_on_configure=true,
}),
zcl.cluster_attribute(zcl.CLUSTER_LEVEL_CONTROL,0x4000,{
name="candeo_rd1p_dpm_startup_level",
emit=emit.candeoRd1pDpmStartupLevel(),
endpoint=1,
from_device=function(value)return clamp_round(value,0,255)end,
to_device=function(value)
if value=="minimum" then return 0 end
if value=="previous" then return 255 end
return clamp_round(value,0,255)
end,
numeric_range={minimum=0,maximum=255,step=1},
data_type=data_types.Uint8,
write_type=data_types.Uint8,
read_on_configure=true,
}),
zcl.cluster_attribute(zcl.CLUSTER_LEVEL_CONTROL,0x0010,{
name="candeo_rd1p_dpm_on_transition_time",
emit=emit.candeoRd1pDpmOnTransitionTime(),
endpoint=1,
from_device=level_config_seconds_from_device,
to_device=level_config_seconds_to_device,
numeric_range={minimum=0,maximum=6553.5,step=0.1,unit="s"},
data_type=data_types.Uint16,
write_type=data_types.Uint16,
read_on_configure=true,
}),
zcl.cluster_attribute(zcl.CLUSTER_LEVEL_CONTROL,0x0012,{
name="candeo_rd1p_dpm_off_transition_time",
emit=emit.candeoRd1pDpmOffTransitionTime(),
endpoint=1,
from_device=level_config_seconds_from_device,
to_device=level_config_seconds_to_device,
numeric_range={minimum=0,maximum=6553.5,step=0.1,unit="s"},
data_type=data_types.Uint16,
write_type=data_types.Uint16,
read_on_configure=true,
}),
},
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
binding.endpoint
))
end
end,
}
local function paulmann_send_raw(device,cluster_id,command_id,payload,endpoint)
return zcl.send_raw_cluster_command(device,cluster_id,command_id,payload,endpoint)
end
local function paulmann_rgbww_effect_sender(device,_,value,context)
local endpoint=context.endpoint or 1
local sent=false
if value=="colorloop" then
sent=paulmann_send_raw(device,zcl.CLUSTER_COLOR_CONTROL,0x01,string.char(0x01,17),endpoint)
elseif value=="stop_colorloop" then
sent=paulmann_send_raw(device,zcl.CLUSTER_COLOR_CONTROL,0x01,string.char(0x00,1),endpoint)
else
local effect_id=({
blink=0,
breathe=1,
okay=2,
channel_change=11,
finish_effect=254,
stop_effect=255,
})[value]
if effect_id==nil then return false end
sent=paulmann_send_raw(device,0x0003,0x40,string.char(effect_id,0),endpoint)
end
if sent ~=false then
local event=emit.paulmannRgbwwEffect()(device,value)
if event ~=nil then
device:emit_component_event({id=context.component_id or "main"},event)
end
end
return sent
end
local paulmann_rgbww
paulmann_rgbww={
profile="lights-paulmann-rgbww",
capability_commands={
{
capability_id="concertmirror08464.paulmannRgbwwStartupCct",
command_name="restorePaulmannRgbwwPreviousCct",
mapping_name="paulmann_rgbww_startup_color_temperature",
value=65535,
},
},
color_temperature_range={
minimum=math.floor((1000000 / 454)+ 0.5),
maximum=math.floor((1000000 / 153)+ 0.5),
},
zcl_clusters={
zcl.switch({configure_reporting=false}),
zcl.level({configure_reporting=false}),
zcl.color_temperature({configure_reporting=false}),
zcl.color_hue({configure_reporting=false}),
zcl.color_saturation({configure_reporting=false}),
zcl.color(),
zcl.cluster_attribute(zcl.CLUSTER_ON_OFF,0x4003,{
name="paulmann_rgbww_power_on_behavior",
emit=emit.paulmannRgbwwPowerOnBehavior(),
from_device=function(value)
return({[0]="off",[1]="on",[2]="toggle",[255]="previous"})[value]
end,
to_device=function(value)
return({off=0,on=1,toggle=2,previous=255})[value]
end,
data_type=data_types.Enum8,
write_type=data_types.Enum8,
read_on_configure=true,
}),
zcl.cluster_attribute(zcl.CLUSTER_COLOR_CONTROL,0x4010,{
name="paulmann_rgbww_startup_color_temperature",
emit=emit.paulmannRgbwwStartupCct(),
from_device=function(value)return value end,
to_device=function(value)
value=tonumber(value)
if value==65535 then return value end
if value==nil then return nil end
return math.max(153,math.min(454,math.floor(value + 0.5)))
end,
data_type=data_types.Uint16,
write_type=data_types.Uint16,
read_on_configure=true,
}),
zcl.cluster_attribute(0x0003,0xFFFF,{
name="paulmann_rgbww_effect",
emit=emit.paulmannRgbwwEffect(),
data_type=data_types.Enum8,
write_only=true,
sender=paulmann_rgbww_effect_sender,
}),
},
runtime_start=function(device)
device:emit_component_event(
{id="main"},
capabilities.colorTemperature.colorTemperatureRange({
value=paulmann_rgbww.color_temperature_range,
unit="K",
})
)
return true
end,
}
register_aliases(candeo_rd1p_dpm,{
device_helpers.create_fingerprint("Candeo","C-ZB-RD1Pv2-DPM"),
})
register_aliases(paulmann_rgbww,{
device_helpers.create_fingerprint("Paulmann Licht GmbH","RGBWW"),
})
return{
id="zcl.lights.z2m_absorption",
registrations=device_definitions,
}
