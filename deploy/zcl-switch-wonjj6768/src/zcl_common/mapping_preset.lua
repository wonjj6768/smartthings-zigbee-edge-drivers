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
local function power_on_behavior_pair()
return build_lookup_pair({
[0]="off",
[1]="on",
[2]="previous",
},nil,nil,{
restore="previous",
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
local function switch_type_pair()
return build_lookup_pair({
[0]="toggle",
[1]="state",
[2]="momentary",
})
end
local function gen_on_off_switch_type_pair()
return build_lookup_pair({
[0]="momentary",
[1]="toggle",
[2]="state",
})
end
local function on_off_pair()
return build_lookup_pair({
[0]="off",
[1]="on",
})
end
local function encode_uint16_le(value)
local numeric=math.floor(clamp(tonumber(value)or 0,0,0xFFFF)+ 0.5)
return string.char(bit32.band(numeric,0xFF))..
string.char(bit32.rshift(bit32.band(numeric,0xFF00),8))
end
local function encode_uint32_be(value)
local numeric=math.floor(clamp(tonumber(value)or 0,0,0xFFFFFFFF)+ 0.5)
return string.char(bit32.rshift(bit32.band(numeric,0xFF000000),24))..
string.char(bit32.rshift(bit32.band(numeric,0xFF0000),16))..
string.char(bit32.rshift(bit32.band(numeric,0xFF00),8))..
string.char(bit32.band(numeric,0xFF))
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
local function read_latest_state(device,capability_id,attribute_name,default)
if type(device)=="table" and type(device.get_latest_state)=="function" then
local latest=device:get_latest_state("main",capability_id,attribute_name)
if latest ~=nil then
return latest
end
end
return default
end
local function parse_threshold_entries(zb_rx)
local body_bytes=zb_rx and zb_rx.body and zb_rx.body.zcl_body and zb_rx.body.zcl_body.body_bytes or nil
if type(body_bytes)~="string" or #body_bytes < 4 then
return nil
end
local entries={}
local index=1
while index + 3 <=#body_bytes do
local key=string.byte(body_bytes,index)
if key==nil then
break
end
entries[key]={
state=string.byte(body_bytes,index + 1)or 0,
value=(((string.byte(body_bytes,index + 2)or 0)* 256)+(string.byte(body_bytes,index + 3)or 0)),
}
index=index + 4
end
return entries
end
local function threshold_command_extractor(command_id,key,field)
return function(zb_rx)
local actual_command=zb_rx and zb_rx.body and zb_rx.body.zcl_header and zb_rx.body.zcl_header.cmd and zb_rx.body.zcl_header.cmd.value or nil
if actual_command ~=command_id then
return nil
end
local entries=parse_threshold_entries(zb_rx)
local entry=type(entries)=="table" and entries[key]or nil
if type(entry)~="table" then
return nil
end
if field=="state" then
return entry.state
end
return entry.value
end
end
local function ts0049_countdown_command_extractor(zb_rx)
local body_bytes=zb_rx and zb_rx.body and zb_rx.body.zcl_body and zb_rx.body.zcl_body.body_bytes or nil
if type(body_bytes)~="string" or #body_bytes < 12 then
return nil
end
local command=string.byte(body_bytes,3)
local data_type=string.byte(body_bytes,7)
local key=string.byte(body_bytes,8)
if command ~=0x0A or key ~=0x0B or(data_type ~=0x05 and data_type ~=0x06)then
return nil
end
local seconds=((string.byte(body_bytes,9)or 0)* 0x1000000)+
((string.byte(body_bytes,10)or 0)* 0x10000)+
((string.byte(body_bytes,11)or 0)* 0x100)+
(string.byte(body_bytes,12)or 0)
return math.floor((seconds / 60)+ 0.5)
end
local function build_threshold_payload(key,state_value,threshold_value)
local numeric=tonumber(threshold_value)
if type(numeric)~="number" then
return nil
end
numeric=math.floor(numeric + 0.5)
if numeric < 0 then
numeric=0
elseif numeric > 0xFFFF then
numeric=0xFFFF
end
local state=state_value=="on" and 1 or 0
return string.char(
key,
state,
bit32.band(bit32.rshift(numeric,8),0xFF),
bit32.band(numeric,0xFF)
)
end
local function threshold_value_to_device(key,sibling_capability_id,sibling_attribute_name)
return function(value,device)
local state=read_latest_state(device,sibling_capability_id,sibling_attribute_name,"off")
return build_threshold_payload(key,state,value)
end
end
local function threshold_breaker_to_device(key,sibling_capability_id,sibling_attribute_name)
return function(value,device)
local threshold=read_latest_state(device,sibling_capability_id,sibling_attribute_name,0)
return build_threshold_payload(key,value,threshold)
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
define_preset("temperature",zcl.temperature_measurement,function()
return merge_defaults(
{
emit=emit.temperature("C"),
scale=100,
},
reporting_defaults(30,300,50)
)
end)
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
zcl.indicator_mode=define_enum_attribute(zcl.CLUSTER_ON_OFF,0x8001,{
name="indicator_mode",
emit=optional_emit("indicator_mode"),
attribute_name="tuyaBacklightMode",
converter_factory=indicator_mode_pair,
})
zcl.power_on_behavior=define_enum_attribute(zcl.CLUSTER_ON_OFF,0x8002,{
name="power_on_behavior",
emit=optional_emit("power_on_behavior"),
attribute_name="tuyaPowerOnBehavior",
converter_factory=power_on_behavior_pair,
})
zcl.power_outage_memory=define_enum_attribute(zcl.CLUSTER_ON_OFF,0x8002,{
name="power_on_behavior",
emit=optional_emit("power_on_behavior"),
attribute_name="moesStartUpOnOff",
converter_factory=power_on_behavior_pair,
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
zcl.switch_type=define_enum_attribute(0xE001,0xD030,{
name="switch_type",
emit=optional_emit("switch_type"),
attribute_name="tuyaExternalSwitchType",
mfg_code=0x1141,
converter_factory=switch_type_pair,
})
zcl.gen_on_off_switch_type=define_enum_attribute(zcl.CLUSTER_ON_OFF,0x8001,{
name="switch_type",
emit=optional_emit("switch_type"),
attribute_name="tuyaExternalSwitchType",
mfg_code=0x1141,
converter_factory=gen_on_off_switch_type_pair,
})
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
zcl.ts0049_countdown_timer=function(name_or_options,options)
local resolved=normalize_preset_options(name_or_options,options)
apply_defaults(resolved,{
name="countdown_timer",
emit=optional_emit("valveCountdownTs0049Minutes","min"),
tx_command_id=0xFE,
command_id=0x0A,
command_extractor=ts0049_countdown_command_extractor,
to_device=function(value)
local minutes=math.floor(clamp(tonumber(value)or 0,0,255)+ 0.5)
return string.char(0x0B).. encode_uint32_be(minutes * 60)
end,
numeric_range={
minimum=0,
maximum=255,
step=1,
unit="min",
},
attribute_name="tuyaTs0049Countdown",
read_on_configure=false,
})
return zcl.cluster_attribute(0xE001,0x006F,resolved)
end
local function threshold_value_mapping(name_or_options,options,defaults)
local resolved=normalize_preset_options(name_or_options,options)
apply_defaults(resolved,defaults)
return zcl.cluster_attribute(0xE001,defaults.attribute_id,resolved)
end
local function threshold_breaker_mapping(name_or_options,options,defaults)
local resolved=normalize_preset_options(name_or_options,options)
apply_defaults(resolved,defaults)
return zcl.cluster_attribute(0xE001,defaults.attribute_id,resolved)
end
zcl.temperature_threshold=function(name_or_options,options)
return threshold_value_mapping(name_or_options,options,{
name="temperature_threshold",
emit=optional_emit("temperature_threshold"),
tx_command_id=0xE6,
command_id=0xE6,
command_extractor=threshold_command_extractor(0xE6,0x05,"value"),
to_device=threshold_value_to_device(0x05,"concertmirror08464.temperatureBreaker","temperatureBreaker"),
attribute_id=0xF105,
})
end
zcl.temperature_breaker=function(name_or_options,options)
return threshold_breaker_mapping(name_or_options,options,{
name="temperature_breaker",
emit=optional_emit("temperature_breaker"),
converter=on_off_pair(),
tx_command_id=0xE6,
command_id=0xE6,
command_extractor=threshold_command_extractor(0xE6,0x05,"state"),
to_device=threshold_breaker_to_device(0x05,"concertmirror08464.temperatureThreshold","temperatureThreshold"),
attribute_id=0xF185,
})
end
zcl.power_threshold=function(name_or_options,options)
return threshold_value_mapping(name_or_options,options,{
name="power_threshold",
emit=optional_emit("power_threshold"),
tx_command_id=0xE6,
command_id=0xE6,
command_extractor=threshold_command_extractor(0xE6,0x07,"value"),
to_device=threshold_value_to_device(0x07,"concertmirror08464.powerBreaker","powerBreaker"),
attribute_id=0xF107,
})
end
zcl.power_breaker=function(name_or_options,options)
return threshold_breaker_mapping(name_or_options,options,{
name="power_breaker",
emit=optional_emit("power_breaker"),
converter=on_off_pair(),
tx_command_id=0xE6,
command_id=0xE6,
command_extractor=threshold_command_extractor(0xE6,0x07,"state"),
to_device=threshold_breaker_to_device(0x07,"concertmirror08464.powerThreshold","powerThreshold"),
attribute_id=0xF187,
})
end
zcl.over_current_threshold=function(name_or_options,options)
return threshold_value_mapping(name_or_options,options,{
name="over_current_threshold",
emit=optional_emit("over_current_threshold"),
tx_command_id=0xE7,
command_id=0xE7,
command_extractor=threshold_command_extractor(0xE7,0x01,"value"),
to_device=threshold_value_to_device(0x01,"concertmirror08464.overCurrentBreaker","overCurrentBreaker"),
attribute_id=0xF101,
})
end
zcl.over_current_breaker=function(name_or_options,options)
return threshold_breaker_mapping(name_or_options,options,{
name="over_current_breaker",
emit=optional_emit("over_current_breaker"),
converter=on_off_pair(),
tx_command_id=0xE7,
command_id=0xE7,
command_extractor=threshold_command_extractor(0xE7,0x01,"state"),
to_device=threshold_breaker_to_device(0x01,"concertmirror08464.overCurrentThreshold","overCurrentThreshold"),
attribute_id=0xF181,
})
end
zcl.over_voltage_threshold=function(name_or_options,options)
return threshold_value_mapping(name_or_options,options,{
name="over_voltage_threshold",
emit=optional_emit("over_voltage_threshold"),
tx_command_id=0xE7,
command_id=0xE7,
command_extractor=threshold_command_extractor(0xE7,0x03,"value"),
to_device=threshold_value_to_device(0x03,"concertmirror08464.overVoltageBreaker","overVoltageBreaker"),
attribute_id=0xF103,
})
end
zcl.over_voltage_breaker=function(name_or_options,options)
return threshold_breaker_mapping(name_or_options,options,{
name="over_voltage_breaker",
emit=optional_emit("over_voltage_breaker"),
converter=on_off_pair(),
tx_command_id=0xE7,
command_id=0xE7,
command_extractor=threshold_command_extractor(0xE7,0x03,"state"),
to_device=threshold_breaker_to_device(0x03,"concertmirror08464.overVoltageThreshold","overVoltageThreshold"),
attribute_id=0xF183,
})
end
zcl.under_voltage_threshold=function(name_or_options,options)
return threshold_value_mapping(name_or_options,options,{
name="under_voltage_threshold",
emit=optional_emit("under_voltage_threshold"),
tx_command_id=0xE7,
command_id=0xE7,
command_extractor=threshold_command_extractor(0xE7,0x04,"value"),
to_device=threshold_value_to_device(0x04,"concertmirror08464.underVoltageBreaker","underVoltageBreaker"),
attribute_id=0xF104,
})
end
zcl.under_voltage_breaker=function(name_or_options,options)
return threshold_breaker_mapping(name_or_options,options,{
name="under_voltage_breaker",
emit=optional_emit("under_voltage_breaker"),
converter=on_off_pair(),
tx_command_id=0xE7,
command_id=0xE7,
command_extractor=threshold_command_extractor(0xE7,0x04,"state"),
to_device=threshold_breaker_to_device(0x04,"concertmirror08464.underVoltageThreshold","underVoltageThreshold"),
attribute_id=0xF184,
})
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
