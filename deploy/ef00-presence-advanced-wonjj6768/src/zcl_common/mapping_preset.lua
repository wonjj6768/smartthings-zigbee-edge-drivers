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
zcl.occupancy=function(name_or_options,options)
local resolved=normalize_preset_options(name_or_options,options)
local ias_zone=resolved.ias_zone==true
resolved.ias_zone=nil
if ias_zone then
apply_defaults(resolved,merge_defaults(
{
name="occupancy",
emit=emit.occupancy(),
converter=zone_status_pair(0x0001),
ias_configure_method=zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
command_id=0x00,
command_extractor=extract_zone_status_from_command,
},
reporting_defaults(30,300,nil)
))
return zcl.ias_zone(resolved)
end
apply_defaults(resolved,merge_defaults(
{
emit=emit.occupancy(),
},
reporting_defaults(0,300,nil)
))
return zcl.occupancy_sensing(resolved)
end
end
return load_mapping_preset
