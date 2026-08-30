local zcl=require "protocol.zcl"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local zcl_device_helpers=require "contracts.helpers.zcl"
local device_management=require "st.zigbee.device_management"
local data_types=require "st.zigbee.data_types"
local device_definitions,register_device_definition=device_helpers.definition_registry()
local NAMESPACE="concertmirror08464."
local function custom(capability_id)
return assert(emit[capability_id],"missing Wave19 light emitter: " .. capability_id)()
end
local function clamp_round(value,minimum,maximum)
local number=tonumber(value)
if number==nil then return nil end
return math.max(minimum,math.min(maximum,math.floor(number + 0.5)))
end
local function transition_from_device(value)
local number=tonumber(value)
if number==nil then return nil end
return number / 10
end
local function transition_to_device(value)
local number=tonumber(value)
if number==nil then return nil end
if number >=6553.5 then return 65535 end
return math.max(0,math.min(65534,math.floor(number * 10 + 0.5)))
end
local function candeo_action_resolver(zb_rx,cluster_id,command_id,source_endpoint)
if cluster_id ~=zcl.CLUSTER_ON_OFF then return nil,nil,true end
local action,component,handled=zcl_device_helpers.resolve_rd1p_rotary_action(
zb_rx,cluster_id,command_id,source_endpoint
)
if action=="pressed" then return nil,"switch2",true end
return action,"switch2",handled
end
local candeo={
profile="lights-wave19-candeo-rd1pv2-dim",
package_group="wave19-light",
transport_classification="ZCL",
z2m_converter_source="modernExtend.light/electricityMeter + rd1p local converters",
advanced_remote=true,
unprefixed_remote_actions=true,
remote_action_emit_name="candeoRotaryDimAction",
standard_command_action_resolver=candeo_action_resolver,
placeholder_custom_states=false,
zcl_clusters={
zcl.switch({endpoint=1,minimum_interval=0,maximum_interval=65000,reportable_change=1}),
zcl.level({endpoint=1,minimum_interval=1,maximum_interval=3600,reportable_change=1}),
zcl.power({endpoint=1,minimum_interval=5,maximum_interval=300,reportable_change=10}),
zcl.voltage({endpoint=1,minimum_interval=5,maximum_interval=600,reportable_change=500}),
zcl.current({endpoint=1,minimum_interval=5,maximum_interval=900,reportable_change=10}),
zcl.energy({endpoint=1,minimum_interval=5,maximum_interval=1800,reportable_change=50}),
zcl.cluster_attribute(zcl.CLUSTER_ON_OFF,0x8000,{
name="candeoRotaryDim_extra_commands",
endpoint=1,
emit=custom("candeoRotaryDimExtraCommands"),
from_device=function(value)return value and "ON" or "OFF" end,
to_device=function(value)return value=="ON" end,
data_type=data_types.Boolean,
write_type=data_types.Boolean,
configure_reporting=false,
read_on_configure=true,
}),
zcl.cluster_attribute(zcl.CLUSTER_ON_OFF,0x4003,{
name="candeoRotaryDim_power_behavior",
endpoint=1,
emit=custom("candeoRotaryDimPowerBehavior"),
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
name="candeoRotaryDim_on_level",
endpoint=1,
emit=custom("candeoRotaryDimOnLevel"),
from_device=function(value)return clamp_round(value,0,255)end,
to_device=function(value)return clamp_round(value,1,255)end,
numeric_range={minimum=0,maximum=255,step=1},
data_type=data_types.Uint8,
write_type=data_types.Uint8,
read_on_configure=true,
}),
zcl.cluster_attribute(zcl.CLUSTER_LEVEL_CONTROL,0x4000,{
name="candeoRotaryDim_startup_level",
endpoint=1,
emit=custom("candeoRotaryDimStartupLevel"),
from_device=function(value)return clamp_round(value,0,255)end,
to_device=function(value)return clamp_round(value,0,255)end,
numeric_range={minimum=0,maximum=255,step=1},
data_type=data_types.Uint8,
write_type=data_types.Uint8,
read_on_configure=true,
}),
zcl.cluster_attribute(zcl.CLUSTER_LEVEL_CONTROL,0x0010,{
name="candeoRotaryDim_on_transition",
endpoint=1,
emit=custom("candeoRotaryDimOnTransition"),
from_device=transition_from_device,
to_device=transition_to_device,
numeric_range={minimum=0,maximum=6553.5,step=0.1,unit="s"},
data_type=data_types.Uint16,
write_type=data_types.Uint16,
read_on_configure=true,
}),
zcl.cluster_attribute(zcl.CLUSTER_LEVEL_CONTROL,0x0012,{
name="candeoRotaryDim_off_transition",
endpoint=1,
emit=custom("candeoRotaryDimOffTransition"),
from_device=transition_from_device,
to_device=transition_to_device,
numeric_range={minimum=0,maximum=6553.5,step=0.1,unit="s"},
data_type=data_types.Uint16,
write_type=data_types.Uint16,
read_on_configure=true,
}),
},
configure=function(driver,device)
for _,binding in ipairs({
{1,zcl.CLUSTER_ON_OFF},
{1,zcl.CLUSTER_LEVEL_CONTROL},
{1,zcl.CLUSTER_ELECTRICAL_MEASUREMENT},
{1,zcl.CLUSTER_SIMPLE_METERING},
{2,zcl.CLUSTER_ON_OFF},
{2,zcl.CLUSTER_LEVEL_CONTROL},
})do
device:send(device_management.build_bind_request(
device,
binding[2],
driver.environment_info.hub_zigbee_eui,
binding[1]
))
end
end,
}
register_device_definition(candeo,{
device_helpers.create_fingerprint("Candeo","C-ZB-RD1Pv2-DIM"),
})
local XIAOYAN_MFG_CODE=0x1228
local DIMMER_POWER_CLUSTER=0xFCCC
local DIMMER_EFFECT_CLUSTER=0xFCCD
local MIN_KELVIN_DEFAULT=1600
local MAX_KELVIN_DEFAULT=7000
local function u16le(value)
local number=clamp_round(value,0,0xFFFF)
if number==nil then return nil end
return string.char(number % 0x100,math.floor(number / 0x100)% 0x100)
end
local function u32le(value)
local number=clamp_round(value,0,0xFFFFFFFF)
if number==nil then return nil end
return string.char(
number % 0x100,
math.floor(number / 0x100)% 0x100,
math.floor(number / 0x10000)% 0x100,
math.floor(number / 0x1000000)% 0x100
)
end
local function send_manufacturer_command(device,cluster_id,command_id,payload,context)
return zcl.send_raw_cluster_command(
device,
cluster_id,
command_id,
payload,
context.endpoint or 1,
nil,
XIAOYAN_MFG_CODE,
false
)
end
local function rated_current_sender(device,_,value,context)
local current=clamp_round(value,120,4950)
if current==nil then return false end
return send_manufacturer_command(
device,DIMMER_POWER_CLUSTER,0x08,
string.char(0).. u32le(current).. u32le(0),context
)
end
local function startup_calibration_sender(device,_,value,context)
local level=clamp_round(value,0,5000)
if level==nil then return false end
return send_manufacturer_command(device,DIMMER_EFFECT_CLUSTER,0x00,u32le(level),context)
end
local function latest_kelvin(device,capability_id,attribute,fallback)
local value=nil
if type(device.get_latest_state)=="function" then
value=device:get_latest_state("main",NAMESPACE .. capability_id,attribute)
end
local number=tonumber(value)
if number==nil then return fallback end
return number
end
local terncy_min_kelvin_emitter=custom("terncyDimMinKelvin")
local terncy_max_kelvin_emitter=custom("terncyDimMaxKelvin")
local function kelvin_range_sender(kind)
return function(device,_,value,context)
local next_value=clamp_round(value,1000,10000)
if next_value==nil then return false end
local minimum=latest_kelvin(device,"terncyDimMinKelvin","minKelvin",MIN_KELVIN_DEFAULT)
local maximum=latest_kelvin(device,"terncyDimMaxKelvin","maxKelvin",MAX_KELVIN_DEFAULT)
if kind=="minimum" then minimum=next_value else maximum=next_value end
if minimum >=maximum then return false end
local warm_mired=clamp_round(1000000 / maximum,0,0xFFFF)
local cool_mired=clamp_round(1000000 / minimum,0,0xFFFF)
local sent=send_manufacturer_command(
device,DIMMER_EFFECT_CLUSTER,0x03,
u16le(warm_mired).. u16le(cool_mired),context
)
if sent then
if kind=="minimum" then
device:emit_event(terncy_max_kelvin_emitter(device,maximum))
else
device:emit_event(terncy_min_kelvin_emitter(device,minimum))
end
end
return sent
end
end
local terncy={
profile="lights-wave19-terncy-dim003",
package_group="wave19-light",
transport_classification="CUSTOM_ZCL",
z2m_converter_source="custom 0xFCCC/0xFCCD + modernExtend.light",
placeholder_custom_states=false,
zcl_clusters={
zcl.switch({endpoint=1}),
zcl.level({endpoint=1}),
zcl.color_temperature({endpoint=1}),
zcl.cluster_attribute(DIMMER_POWER_CLUSTER,nil,{
name="terncyDim_rated_current",
endpoint=1,
emit=custom("terncyDimRatedCurrent"),
data_type=data_types.Uint32,
write_only=true,
sender=rated_current_sender,
}),
zcl.cluster_attribute(DIMMER_EFFECT_CLUSTER,nil,{
name="terncyDim_startup_calibration",
endpoint=1,
emit=custom("terncyDimStartupCalibration"),
data_type=data_types.Uint32,
write_only=true,
sender=startup_calibration_sender,
}),
zcl.cluster_attribute(DIMMER_EFFECT_CLUSTER,nil,{
name="terncyDim_min_kelvin",
endpoint=1,
emit=terncy_min_kelvin_emitter,
data_type=data_types.Uint16,
write_only=true,
sender=kelvin_range_sender("minimum"),
}),
zcl.cluster_attribute(DIMMER_EFFECT_CLUSTER,nil,{
name="terncyDim_max_kelvin",
endpoint=1,
emit=terncy_max_kelvin_emitter,
data_type=data_types.Uint16,
write_only=true,
sender=kelvin_range_sender("maximum"),
}),
zcl.cluster_attribute(DIMMER_EFFECT_CLUSTER,0x0005,{
name="terncyDim_io_reversed",
endpoint=1,
emit=custom("terncyDimIoReversed"),
from_device=function(value)return value and "ON" or "OFF" end,
to_device=function(value)return value=="ON" end,
data_type=data_types.Boolean,
write_type=data_types.Boolean,
mfg_code=XIAOYAN_MFG_CODE,
configure_reporting=false,
read_on_configure=false,
}),
zcl.cluster_attribute(DIMMER_EFFECT_CLUSTER,0x0007,{
name="terncyDim_light_curve",
endpoint=1,
emit=custom("terncyDimLightCurve"),
from_device=function(value)
return({[0]="fast_start",[1]="uniform",[2]="slow_start"})[value]
end,
to_device=function(value)
return({fast_start=0,uniform=1,slow_start=2})[value]
end,
data_type=data_types.Uint8,
write_type=data_types.Uint8,
mfg_code=XIAOYAN_MFG_CODE,
configure_reporting=false,
read_on_configure=false,
}),
},
configure=function(driver,device)
for _,cluster_id in ipairs({
zcl.CLUSTER_ON_OFF,
zcl.CLUSTER_LEVEL_CONTROL,
zcl.CLUSTER_COLOR_CONTROL,
})do
device:send(device_management.build_bind_request(
device,
cluster_id,
driver.environment_info.hub_zigbee_eui,
1
))
end
end,
}
register_device_definition(terncy,{
device_helpers.create_fingerprint("Xiaoyan","DIM003"),
})
return{
id="zcl.lights.wave19.exact",
registrations=device_definitions,
}
