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
local function power_on_behavior_pair()
return build_lookup_pair({
[0]="off",
[1]="on",
[2]="previous",
},nil,nil,{
restore="previous",
})
end
local function switch_mode_pair()
return build_lookup_pair({
[0]="switch",
[1]="scene",
})
end
local function operation_mode_pair()
return build_lookup_pair({
[0]="command",
[1]="event",
})
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
local function zone_status_pair(mask)
return{
from=function(value)
if type(value)=="table" then
if mask==0x0001 then
if type(value.is_alarm1_set)=="function" and value:is_alarm1_set()then
return true
end
if type(value.is_alarm2_set)=="function" and value:is_alarm2_set()then
return true
end
elseif mask==0x0004 and type(value.is_tamper_set)=="function" then
return value:is_tamper_set()
elseif value.value ~=nil then
value=value.value
else
return value
end
end
if type(value)~="number" then
return value
end
return bit32.band(value,mask)~=0
end,
}
end
local function extract_zone_status_from_command(zb_rx)
local zone_status=zb_rx and zb_rx.body and zb_rx.body.zcl_body and zb_rx.body.zcl_body.zone_status or nil
if zone_status==nil then
return nil
end
return{
raw_value=zone_status.value or zone_status,
typed_value=zone_status,
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
define_preset("battery",zcl.power_configuration_battery,function()
return merge_defaults(
{
emit=emit.battery(),
scale=2,
},
reporting_defaults(300,21600,2)
)
end)
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
zcl.operation_mode=function(name_or_options,options)
local resolved=normalize_preset_options(name_or_options,options)
apply_defaults(resolved,{
name="operation_mode",
emit=optional_emit("operation_mode"),
converter=operation_mode_pair(),
data_type=data_types.Enum8,
attribute_name="tuyaOperationMode",
read_on_configure=true,
})
return zcl.cluster_attribute(zcl.CLUSTER_ON_OFF,0x8004,resolved)
end
zcl.switch_mode=define_enum_attribute(0xE001,0xD000,{
name="switch_mode",
emit=optional_emit("switch_mode"),
attribute_name="tuyaSwitchMode",
mfg_code=0x1141,
converter_factory=switch_mode_pair,
})
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
define_preset("tamper",zcl.ias_zone,function()
return merge_defaults(
{
name="tamper",
emit=emit.tamper(),
converter=zone_status_pair(0x0004),
ias_configure_method=zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
command_id=0x00,
command_extractor=extract_zone_status_from_command,
},
reporting_defaults(0,300,nil)
)
end)
define_preset("battery_low",zcl.ias_zone,function()
return merge_defaults(
{
name="battery_low",
emit=optional_emit("battery_low"),
converter=zone_status_pair(0x0008),
ias_configure_method=zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
command_id=0x00,
command_extractor=extract_zone_status_from_command,
},
reporting_defaults(0,300,nil)
)
end)
end
return load_mapping_preset
