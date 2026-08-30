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
local function illuminance_measurement_pair()
return{
from=function(value)
if type(value)~="number" then
return value
end
if value <=0 then
return 0
end
local lux=10 ^((value - 1)/ 10000)
return math.floor(lux + 0.5)
end,
to=function(value)
if type(value)~="number" then
return value
end
if value <=0 then
return 0
end
local raw=10000 *(math.log(value)/ math.log(10))+ 1
return math.floor(raw + 0.5)
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
define_preset("illuminance",zcl.illuminance_measurement,function(options)
local configure_reporting=options.configure_reporting
options.configure_reporting=nil
if configure_reporting==false then
return{
emit=emit.illuminance(),
converter=illuminance_measurement_pair(),
read_on_configure=true,
}
end
return merge_defaults(
{
emit=emit.illuminance(),
converter=illuminance_measurement_pair(),
},
reporting_defaults(30,300,100)
)
end)
end
return load_mapping_preset
