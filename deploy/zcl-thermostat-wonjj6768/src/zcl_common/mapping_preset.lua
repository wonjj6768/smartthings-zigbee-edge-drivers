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
local resolved={}
if type(name_or_options)=="string"then
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
if type(aliases)=="table"then
for alias,target in pairs(aliases)do
if reverse[target]~=nil then
reverse[alias]=reverse[target]
end
end
end
return{
from=function(value)
local mapped=map[value]
if mapped~=nil then
return mapped
end
if default_from~=nil then
return default_from
end
return value
end,
to=function(value)
local mapped=reverse[value]
if mapped~=nil then
return mapped
end
if default_to~=nil then
return default_to
end
return value
end,
}
end
local function thermostat_mode_pair()
return build_lookup_pair({
[0]="off",
[1]="auto",
[3]="cool",
[4]="heat",
[5]="emergency heat",})
end
local function thermostat_running_state_pair()
return{
from=function(value)
local numeric=value
if type(value)=="table"then
if type(value.is_heat_on_set)=="function"and(value:is_heat_on_set()or(type(value.is_heat_second_stage_on_set)=="function"and value:is_heat_second_stage_on_set()))then
return"heating"
end
if type(value.is_cool_on_set)=="function"and(value:is_cool_on_set()or(type(value.is_cool_second_stage_on_set)=="function"and value:is_cool_second_stage_on_set()))then
return"cooling"
end
if type(value.is_fan_on_set)=="function"and(
value:is_fan_on_set()or
(type(value.is_fan_second_stage_on_set)=="function"and value:is_fan_second_stage_on_set())or
(type(value.is_fan_third_stage_on_set)=="function"and value:is_fan_third_stage_on_set())
)then
return"fan only"
end
numeric=value.value
end
if type(numeric)~="number"then
return numeric
end
if bit32.band(numeric,0x0001)~=0 or bit32.band(numeric,0x0008)~=0 then
return"heating"
end
if bit32.band(numeric,0x0002)~=0 or bit32.band(numeric,0x0010)~=0 then
return"cooling"
end
if bit32.band(numeric,0x0004)~=0 or bit32.band(numeric,0x0020)~=0 or bit32.band(numeric,0x0040)~=0 then
return"fan only"
end
return"idle"
end,
}
end
local function reporting_defaults(minimum_interval,maximum_interval,reportable_change)
return{
minimum_interval=minimum_interval,
maximum_interval=maximum_interval,
reportable_change=reportable_change,
read_on_configure=true,}
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
define_preset("humidity",zcl.relative_humidity,function()
return merge_defaults(
{
emit=emit.humidity(),
scale=100,},
reporting_defaults(30,300,100))
end)
define_preset("switch",zcl.on_off,function(options)
local configure_reporting=options.configure_reporting
options.configure_reporting=nil
if configure_reporting==false then
return{
emit=emit.switch(),}
end
return merge_defaults(
{
emit=emit.switch(),},
reporting_defaults(0,300,nil))
end)
define_preset("local_temperature",zcl.thermostat_local_temperature,function()
return merge_defaults(
{
emit=emit.temperature("C"),
scale=100,},
reporting_defaults(30,300,50))
end)
define_preset("heating_setpoint",zcl.thermostat_heating_setpoint,function()
return merge_defaults(
{
name="current_heating_setpoint",
emit=emit.heating_setpoint("C"),
scale=100,},
reporting_defaults(30,300,50))
end)
define_preset("system_mode",zcl.thermostat_system_mode,function()
return merge_defaults(
{
emit=emit.thermostat_mode(),
converter=thermostat_mode_pair(),},
reporting_defaults(1,300,nil))
end)
define_preset("cooling_setpoint",zcl.thermostat_cooling_setpoint,function()
return merge_defaults(
{
name="current_cooling_setpoint",
emit=emit.cooling_setpoint("C"),
scale=100,},
reporting_defaults(30,300,50))
end)
define_preset("thermostat_operating_state",zcl.thermostat_running_state,function()
return merge_defaults(
{
name="thermostat_operating_state",
emit=emit.thermostat_operating_state(),
converter=thermostat_running_state_pair(),},
reporting_defaults(1,300,nil))
end)
end
return load_mapping_preset
