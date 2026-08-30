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
local function indicator_mode_pair()
return build_lookup_pair({
[0]="off",
[1]="off/on",
[2]="on/off",
[3]="on",
},nil,nil,{
off_on="off/on",
on_off="on/off",
normal="off/on",
inverted="on/off",
})
end
local function power_outage_memory_pair()
return build_lookup_pair({
[0]="off",
[1]="on",
[2]="restore",
},nil,nil,{
previous="restore",
})
end
local function encode_uint16_le(value)
local numeric=math.floor(clamp(tonumber(value)or 0,0,0xFFFF)+ 0.5)
return string.char(bit32.band(numeric,0xFF))..
string.char(bit32.rshift(bit32.band(numeric,0xFF00),8))
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
zcl.indicator_mode=define_enum_attribute(zcl.CLUSTER_ON_OFF,0x8001,{
name="indicator_mode",
emit=optional_emit("indicator_mode"),
attribute_name="tuyaBacklightMode",
converter_factory=indicator_mode_pair,
})
zcl.tuya_power_outage_memory=define_enum_attribute(zcl.CLUSTER_ON_OFF,0x8002,{
name="power_outage_memory",
emit=optional_emit("power_outage_memory"),
attribute_name="moesStartUpOnOff",
converter_factory=power_outage_memory_pair,
})
zcl.child_lock=function(name_or_options,options)
local resolved=normalize_preset_options(name_or_options,options)
apply_defaults(resolved,{
name="child_lock",
emit=optional_emit("childLock"),
from_device=function(value)
return value and "on" or "off"
end,
to_device=function(value)
return value==true or value=="on" or value=="lock" or value=="LOCK"
end,
data_type=data_types.Boolean,
write_type=data_types.Boolean,
attribute_name="tuyaChildLock",
read_on_configure=true,
})
return zcl.cluster_attribute(zcl.CLUSTER_ON_OFF,0x8000,resolved)
end
zcl.tuya_magic_packet=function(name_or_options,options)
local resolved=normalize_preset_options(name_or_options,options)
apply_defaults(resolved,{
name="tuya_magic_packet",
read_only=true,
read_on_configure=true,
})
return zcl.cluster_attribute(0x0000,0xFFFE,resolved)
end
zcl.countdown_timer=function(name_or_options,options)
local resolved=normalize_preset_options(name_or_options,options)
apply_defaults(resolved,{
name="countdown_timer",
emit=optional_emit("countdownTimerZclTwelveHours","s"),
data_type=data_types.Uint16,
write_type=data_types.Uint16,
tx_command_id=0x42,
to_device=function(value)
local countdown=clamp(tonumber(value)or 0,0,43200)
return string.char(0x00).. encode_uint16_le(countdown).. encode_uint16_le(countdown)
end,
numeric_range={
minimum=0,
maximum=43200,
step=1,
unit="s",
},
attribute_name="onTime",
read_on_configure=true,
})
return zcl.cluster_attribute(zcl.CLUSTER_ON_OFF,0x4001,resolved)
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
end
return load_mapping_preset
