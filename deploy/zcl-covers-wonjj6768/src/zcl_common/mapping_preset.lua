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
local function clamp(value,min_value,max_value)
if value < min_value then
return min_value
end
if value > max_value then
return max_value
end
return value
end
local function window_shade_state_from_position()
return{
from=function(value)
if type(value)~="number" then
return value
end
local clamped=clamp(value,0,100)
if clamped <=0 then
return "closed"
end
if clamped >=100 then
return "open"
end
return "partially open"
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
define_preset("battery",zcl.power_configuration_battery,function()
return merge_defaults(
{
emit=emit.battery(),
scale=2,
},
reporting_defaults(300,21600,2)
)
end)
zcl.tuya_magic_packet=function(name_or_options,options)
local resolved=normalize_preset_options(name_or_options,options)
apply_defaults(resolved,{
name="tuya_magic_packet",
read_only=true,
read_on_configure=true,
})
return zcl.cluster_attribute(0x0000,0xFFFE,resolved)
end
define_preset("cover_position",zcl.window_covering_position,function()
return merge_defaults(
{
emit=emit.shade_level(),
},
reporting_defaults(0,600,1)
)
end)
define_preset("cover_state",zcl.window_covering_position,function()
return{
name="cover_state",
write_only=true,
}
end)
define_preset("window_shade_state",zcl.window_covering_position,function()
return merge_defaults(
{
name="window_shade_state",
emit=emit.shade_state(),
converter=window_shade_state_from_position(),
},
reporting_defaults(0,600,1)
)
end)
end
return load_mapping_preset
