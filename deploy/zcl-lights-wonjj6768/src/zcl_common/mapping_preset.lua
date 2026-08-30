local function load_mapping_preset(zcl)
local emit=require "capabilities.events.all"
local data_types=require "st.zigbee.data_types"
local zigbee_constants=require "st.zigbee.constants"
local function merge_options(target,source)
if type(target)~="table" then
target={}
end
if type(source)~="table" then
return target
end
for key,value in pairs(source)do
target[key]=value
end
return target
end
local function apply_defaults(target,defaults)
if type(target)~="table" or type(defaults)~="table" then
return target
end
for key,value in pairs(defaults)do
if target[key]==nil then
target[key]=value
end
end
return target
end
local function optional_emit(name,...)
local factory=emit[name]
if type(factory)=="function" then
return factory(...)
end
return nil
end
local function normalize_preset_options(name_or_options,options)
local resolved={}
if type(name_or_options)=="string" then
resolved.name=name_or_options
else
merge_options(resolved,name_or_options)
end
merge_options(resolved,options)
return resolved
end
local function build_lookup_pair(map,default_from,default_to,aliases)
local reverse={}
for key,value in pairs(map)do
reverse[value]=key
end
if type(aliases)=="table" then
for alias,target in pairs(aliases)do
if reverse[target]~=nil then
reverse[alias]=reverse[target]
end
end
end
return{
from=function(value)
local mapped=map[value]
if mapped ~=nil then
return mapped
end
if default_from ~=nil then
return default_from
end
return value
end,
to=function(value)
local mapped=reverse[value]
if mapped ~=nil then
return mapped
end
if default_to ~=nil then
return default_to
end
return value
end,
}
end
local function clamp(value,min_value,max_value)
if value < min_value then
return min_value
end
if value > max_value then
return max_value
end
return value
end
local function level_percent_pair()
return{
from=function(value)
if type(value)~="number" then
return value
end
return math.floor((clamp(value,0,254)* 100 / 254)+ 0.5)
end,
to=function(value)
if type(value)~="number" then
return value
end
return math.floor((clamp(value,0,100)* 254 / 100)+ 0.5)
end,
}
end
local function percent_254_pair()
return{
from=function(value)
if type(value)~="number" then
return value
end
return math.floor((clamp(value,0,254)* 100 / 254)+ 0.5)
end,
to=function(value)
if type(value)~="number" then
return value
end
return math.floor((clamp(value,0,100)* 254 / 100)+ 0.5)
end,
}
end
local function fan_mode_pair()
return build_lookup_pair({
[0]="off",
[1]="low",
[2]="medium",
[3]="high",
[4]="on",
[5]="auto",
[6]="turbo",
})
end
local function power_on_behavior_pair()
return build_lookup_pair({
[0]="off",
[1]="on",
[2]="previous",
},nil,nil,{
restore="previous",
})
end
local function ts110e_switch_type_pair()
return build_lookup_pair({
[0]="momentary",
[1]="toggle",
[2]="state",
})
end
local function light_type_pair()
return build_lookup_pair({
[0]="led",
[1]="incandescent",
[2]="halogen",
})
end
local function encode_uint32_le(value)
local numeric=math.floor(clamp(tonumber(value)or 0,0,0xFFFFFFFF)+ 0.5)
return string.char(bit32.band(numeric,0xFF))..
string.char(bit32.rshift(bit32.band(numeric,0xFF00),8))..
string.char(bit32.rshift(bit32.band(numeric,0xFF0000),16))..
string.char(bit32.rshift(bit32.band(numeric,0xFF000000),24))
end
local function ts110e_brightness_limit_pair()
return{
from=function(value)
if type(value)~="number" then
return value
end
return math.floor(((clamp(value,0,1000)* 254)/ 1000)+ 1 + 0.5)
end,
to=function(value)
if type(value)~="number" then
return value
end
return math.floor((((clamp(value,1,255)- 1)* 1000)/ 254)+ 0.5)
end,
}
end
local function define_enum_attribute(cluster_id,attribute_id,defaults)
return function(name_or_options,options)
local resolved=normalize_preset_options(name_or_options,options)
local converter=defaults.converter_factory()
apply_defaults(resolved,{
name=defaults.name,
emit=defaults.emit,
converter=converter,
to_device=function(value)
return converter.to(value)
end,
data_type=data_types.Enum8,
write_type=data_types.Enum8,
attribute_name=defaults.attribute_name,
mfg_code=defaults.mfg_code,
read_on_configure=true,
})
return zcl.cluster_attribute(cluster_id,attribute_id,resolved)
end
end
local function color_temperature_pair()
local conversion_constant=1000000
return{
from=function(value)
if type(value)~="number" or value <=0 then
return value
end
return math.floor((conversion_constant / value)+ 0.5)
end,
to=function(value)
if type(value)~="number" or value <=0 then
return value
end
return math.floor((conversion_constant / value)+ 0.5)
end,
}
end
local function reporting_defaults(minimum_interval,maximum_interval,reportable_change)
return{
minimum_interval=minimum_interval,
maximum_interval=maximum_interval,
reportable_change=reportable_change,
read_on_configure=true,
}
end
local function merge_defaults(...)
local merged={}
for _,defaults in ipairs({...})do
apply_defaults(merged,defaults)
end
return merged
end
local function define_preset(name,factory,defaults_builder)
zcl[name]=function(name_or_options,options)
local resolved=normalize_preset_options(name_or_options,options)
apply_defaults(resolved,defaults_builder(resolved))
return factory(resolved)
end
end
define_preset("switch",zcl.on_off,function(options)
local configure_reporting=options.configure_reporting
options.configure_reporting=nil
if configure_reporting==false then
return{
emit=emit.switch(),
}
end
return merge_defaults(
{
emit=emit.switch(),
},
reporting_defaults(0,300,nil)
)
end)
zcl.power_on_behavior=define_enum_attribute(zcl.CLUSTER_ON_OFF,0x8002,{
name="power_on_behavior",
emit=optional_emit("power_on_behavior"),
attribute_name="tuyaPowerOnBehavior",
converter_factory=power_on_behavior_pair,
})
zcl.tuya_magic_packet=function(name_or_options,options)
local resolved=normalize_preset_options(name_or_options,options)
apply_defaults(resolved,{
name="tuya_magic_packet",
read_only=true,
read_on_configure=true,
})
return zcl.cluster_attribute(0x0000,0xFFFE,resolved)
end
zcl.ts110e_countdown_timer=function(name_or_options,options)
local resolved=normalize_preset_options(name_or_options,options)
local countdown_emit=resolved.emit or optional_emit("countdownTsOneTenHours","s")
apply_defaults(resolved,{
name="countdown_timer",
emit=countdown_emit,
data_type=data_types.Uint32,
tx_command_id=0xF0,
to_device=function(value)
return encode_uint32_le(clamp(tonumber(value)or 0,0,43200))
end,
numeric_range={
minimum=0,
maximum=43200,
step=1,
unit="s",
},
attribute_name="tuyaCountdown",
read_on_configure=true,
})
return zcl.cluster_attribute(zcl.CLUSTER_ON_OFF,0x4001,resolved)
end
define_preset("level",zcl.level_control,function(options)
local configure_reporting=options.configure_reporting
options.configure_reporting=nil
local defaults={
name="brightness",
emit=emit.level(),
converter=level_percent_pair(),
}
if configure_reporting==false then return defaults end
return merge_defaults(defaults,reporting_defaults(1,3600,1))
end)
zcl.tuya_dimmer_level=function(name_or_options,options)
local resolved=normalize_preset_options(name_or_options,options)
apply_defaults(resolved,{
name="brightness",
emit=emit.level(),
data_type=data_types.Uint16,
write_type=data_types.Uint16,
attribute_name="tuyaCurrentLevel",
from_device=function(value)
if type(value)~="number" then
return value
end
local clamped=clamp(value,10,1000)
return math.floor((((clamped - 10)* 100)/ 990)+ 0.5)
end,
to_device=function(value)
if type(value)~="number" then
return value
end
local percent=clamp(value,0,100)
return math.floor((10 +((percent * 990)/ 100))+ 0.5)
end,
read_on_configure=true,
})
return zcl.cluster_attribute(zcl.CLUSTER_LEVEL_CONTROL,0xF000,resolved)
end
define_preset("power",zcl.electrical_measurement_power,function()
return merge_defaults(
{
emit=emit.power(),
metering_kind="power",
poll_interval=300,
},
reporting_defaults(5,300,1)
)
end)
define_preset("current",zcl.electrical_measurement_current,function()
return merge_defaults(
{
emit=emit.current(),
scale=1000,
metering_kind="current",
poll_interval=300,
},
reporting_defaults(5,300,1)
)
end)
define_preset("voltage",zcl.electrical_measurement_voltage,function()
return merge_defaults(
{
emit=emit.voltage(),
metering_kind="voltage",
poll_interval=300,
},
reporting_defaults(5,300,1)
)
end)
define_preset("energy",zcl.simple_metering,function()
return{
emit=emit.energy(),
read_on_configure=true,
metering_kind="energy",
poll_interval=900,
}
end)
define_preset("fan_mode",zcl.fan_control_mode,function()
return merge_defaults(
{
name="fan_mode",
emit=emit.fan_mode(),
converter=fan_mode_pair(),
},
reporting_defaults(1,300,nil)
)
end)
define_preset("color_temperature",zcl.color_control_temperature,function(options)
local configure_reporting=options.configure_reporting
options.configure_reporting=nil
local defaults={
name="color_temperature",
emit=emit.color_temperature(),
converter=color_temperature_pair(),
tx_command_id=0x0A,
}
if configure_reporting==false then return defaults end
return merge_defaults(defaults,reporting_defaults(1,300,1))
end)
zcl.min_brightness=function(name_or_options,options)
local resolved=normalize_preset_options(name_or_options,options)
apply_defaults(resolved,{
name="min_brightness",
emit=optional_emit("minBrightnessZclThousand"),
data_type=data_types.Uint16,
write_type=data_types.Uint16,
attribute_name="tuyaMinBrightness",
read_on_configure=true,
})
return zcl.cluster_attribute(zcl.CLUSTER_LEVEL_CONTROL,0xFC03,resolved)
end
zcl.ts110e_min_brightness=function(name_or_options,options)
local resolved=normalize_preset_options(name_or_options,options)
apply_defaults(resolved,{
name="min_brightness",
emit=optional_emit("minimumBrightnessTsOneTenMax"),
converter=ts110e_brightness_limit_pair(),
data_type=data_types.Uint16,
write_type=data_types.Uint16,
attribute_name="tuyaMinBrightness",
read_on_configure=true,
})
return zcl.cluster_attribute(zcl.CLUSTER_LEVEL_CONTROL,0xFC03,resolved)
end
zcl.ts110e_max_brightness=function(name_or_options,options)
local resolved=normalize_preset_options(name_or_options,options)
apply_defaults(resolved,{
name="max_brightness",
emit=optional_emit("maxBrightnessTsOneTenMax"),
converter=ts110e_brightness_limit_pair(),
data_type=data_types.Uint16,
write_type=data_types.Uint16,
attribute_name="tuyaMaxBrightness",
read_on_configure=true,
})
return zcl.cluster_attribute(zcl.CLUSTER_LEVEL_CONTROL,0xFC04,resolved)
end
zcl.ts110e_switch_type=function(name_or_options,options)
local resolved=normalize_preset_options(name_or_options,options)
apply_defaults(resolved,{
name="switch_type",
emit=optional_emit("switch_type"),
converter=ts110e_switch_type_pair(),
data_type=data_types.Enum8,
write_type=data_types.Enum8,
attribute_name="tuyaSwitchType",
read_on_configure=true,
})
return zcl.cluster_attribute(zcl.CLUSTER_LEVEL_CONTROL,0xFC02,resolved)
end
zcl.light_type=function(name_or_options,options)
local resolved=normalize_preset_options(name_or_options,options)
apply_defaults(resolved,{
name="light_type",
emit=optional_emit("light_type"),
converter=light_type_pair(),
data_type=data_types.Enum8,
attribute_name="tuyaLightType",
read_on_configure=true,
})
return zcl.cluster_attribute(zcl.CLUSTER_LEVEL_CONTROL,0xFC02,resolved)
end
define_preset("color_hue",zcl.color_control_hue,function(options)
local configure_reporting=options.configure_reporting
options.configure_reporting=nil
local defaults={
name="color_hue",
emit=emit.color_hue(),
converter=percent_254_pair(),
tx_command_id=0x00,
to_device=function(value)
local encoded=percent_254_pair().to(value)
return{encoded,0x00,0x0000,0x00,0x00}
end,
}
if configure_reporting==false then return defaults end
return merge_defaults(defaults,reporting_defaults(1,300,1))
end)
define_preset("color_saturation",zcl.color_control_saturation,function(options)
local configure_reporting=options.configure_reporting
options.configure_reporting=nil
local defaults={
name="color_saturation",
emit=emit.color_saturation(),
converter=percent_254_pair(),
tx_command_id=0x03,
to_device=function(value)
local encoded=percent_254_pair().to(value)
return{encoded,0x0000,0x00,0x00}
end,
}
if configure_reporting==false then return defaults end
return merge_defaults(defaults,reporting_defaults(1,300,1))
end)
zcl.color=function(name_or_options,options)
local resolved=normalize_preset_options(name_or_options,options)
apply_defaults(resolved,{
name="color",
cluster_id=zcl.CLUSTER_COLOR_CONTROL,
attribute_id=zcl.ATTR_CURRENT_HUE,
write_only=true,
tx_command_id=0x06,
to_device=function(value)
if type(value)~="table" then
return value
end
local hue=percent_254_pair().to(value.hue)
local saturation=percent_254_pair().to(value.saturation)
if type(hue)~="number" or type(saturation)~="number" then
return nil
end
return{hue,saturation,0x0000,0x00,0x00}
end,
})
return zcl.cluster_attribute(resolved.cluster_id,resolved.attribute_id,resolved)
end
end
return load_mapping_preset
