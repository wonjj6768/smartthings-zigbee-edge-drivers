local custom_capabilities={}
local strings={"s","power_poll_interval","powerPollIntervalV2","powerPollInterval","powerPollIntervalRange","Power poll interval","countdownTsOneTenHours","countdown_timer","Countdown Ts One Ten Hours","countdownTsOneTenHalfMinute","Countdown Ts One Ten Half Minute","minBrightnessZclThousand","min_brightness","Min Brightness Zcl Thousand","minimumBrightnessTsOneTenMax","Minimum Brightness Ts One Ten Max","maxBrightnessTsOneTenMax","max_brightness","Max Brightness Ts One Ten Max","dimmer2gMinBrightnessCh1","minBrightness","Dimmer2g Min Brightness Ch1","dimmer2gMaxBrightnessCh1","maxBrightness","Dimmer2g Max Brightness Ch1","dimmer2gCountdownCh1","countdown","Dimmer2g Countdown Ch1","dimmer2gMinBrightnessCh2","Dimmer2g Min Brightness Ch2","dimmer2gMaxBrightnessCh2","Dimmer2g Max Brightness Ch2","dimmer2gCountdownCh2","Dimmer2g Countdown Ch2","candeoRd1pDpmOnLevel","onLevel","candeo_rd1p_dpm_on_level","Candeo Rd1p Dpm On Level","candeoRd1pDpmStartupLevel","startupLevel","candeo_rd1p_dpm_startup_level","Candeo Rd1p Dpm Startup Level","candeoRd1pDpmOnTransitionTime","onTransitionTime","candeo_rd1p_dpm_on_transition_time","Candeo Rd1p Dpm On Transition Time","candeoRd1pDpmOffTransitionTime","offTransitionTime","candeo_rd1p_dpm_off_transition_time","Candeo Rd1p Dpm Off Transition Time","power_on_behavior","powerOnBehavior","supportedPowerOnBehaviors","Power on behavior","off","on","previous","switch_type","switchType","supportedSwitchTypes","Switch type","toggle","state","momentary","light_type","lightType","supportedLightTypes","Light type","led","incandescent","halogen","fanModeSequenceAcController","fan_mode_sequence","Fan Mode Sequence Ac Controller","low_medium_high","low_high","on_auto","dimmer2gLightTypeCh1","Dimmer2g Light Type Ch1","dimmer2gLightTypeCh2","Dimmer2g Light Type Ch2","dimmer2gPowerOnBehavior","Dimmer2g Power On Behavior","fanLightHmqzPowerOnBehavior","Fan Light Hmqz Power On Behavior","candeoRd1pDpmAction","dpmAction","candeo_rd1p_dpm_action","Candeo Rd1p Dpm Action","pressed","double_pressed","held","released","started_rotating_left","started_rotating_right","rotating_right","rotating_left","stopped_rotating","candeoRd1pDpmPowerBehavior","candeo_rd1p_dpm_power_on_behavior","Candeo Rd1p Dpm Power Behavior","last_power_response_time","lastPowerResponseTime","Last power response time"}
local function string_value(value)
if type(value)=="number" then return strings[value]end
return value
end
local function capability_id(value)local suffix=string_value(value);if suffix==nil then return nil end;return "concertmirror08464." .. suffix end
local table_groups={}
local function grouped_table(group_id)
if type(group_id)~="number" then return{}end
local existing=table_groups[group_id]
if existing ~=nil then return existing end
local out={}
table_groups[group_id]=out
return out
end
local function string_list(values,group_id)
if type(values)~="table" then return nil end
local out=grouped_table(group_id)
for index,value in ipairs(values)do out[index]=string_value(value)end
return out
end
local function optional_string(value,default)
if value==nil then return default end
if value==0 then return nil end
return string_value(value)
end
local function command_default(attribute_name)
if type(attribute_name)~="string" or attribute_name=="" then return nil end
return "set" .. attribute_name:sub(1,1):upper().. attribute_name:sub(2)
end
local function range(value)
if type(value)~="table" then return nil end
local out=grouped_table(value[6])
out.minimum=value[1]
out.maximum=value[2]
out.step=value[3]
out.unit=string_value(value[4])
out.allowed_values=string_list(value[5],value[7])
return out
end
local function allowed_range(allowed_values,group_id)
if allowed_values==nil and group_id==nil then return nil end
local out=grouped_table(group_id)
out.allowed_values=allowed_values
return out
end
local function numeric(row)
local attribute_name=string_value(row[4])
return{kind="numeric",emit_name=string_value(row[1]),range_key=string_value(row[2]),capability_id=capability_id(row[3]),attribute_name=attribute_name,range_attribute_name=string_value(row[5]),command_name=optional_string(row[6],command_default(attribute_name)),argument_name=optional_string(row[7],attribute_name),mapping_name=string_value(row[8]),label=string_value(row[9]),default_range=range(row[10]),event_minimum=row[11],event_maximum=row[12],event_unit=string_value(row[13])}
end
local function enum(row)
local attribute_name=string_value(row[4])
local supported_values=string_list(row[10],row[12])
local default_allowed_values=string_list(row[11],row[14])
local default_range=allowed_range(default_allowed_values,row[13])
return{kind="enum",emit_name=string_value(row[1]),range_key=string_value(row[2]),capability_id=capability_id(row[3]),attribute_name=attribute_name,supported_attribute_name=string_value(row[5]),command_name=optional_string(row[6],command_default(attribute_name)),argument_name=optional_string(row[7],attribute_name),mapping_name=string_value(row[8]),label=string_value(row[9]),supported_values=supported_values,default_range=default_range}
end
local function text(row)
local attribute_name=string_value(row[3])
return{kind="text",emit_name=string_value(row[1]),capability_id=capability_id(row[2]),attribute_name=attribute_name,command_name=optional_string(row[4],command_default(attribute_name)),argument_name=optional_string(row[5],attribute_name),mapping_name=string_value(row[6]),label=string_value(row[7]),maximum_length=row[8]}
end
local function build(rows,factory)
local out={}
for _,row in ipairs(rows)do out[#out + 1]=factory(row)end
return out
end
custom_capabilities.numeric=build({{2,2,3,4,5,nil,nil,2,6,{5,3600,5,1,nil,1,nil},5,3600,1},{7,nil,7,7,nil,nil,nil,8,9,{0,43200,1,1,nil,2,nil},nil,nil,1},{10,nil,10,10,nil,nil,nil,8,11,{0,43200,30,1,nil,3,nil},nil,nil,1},{12,nil,12,12,nil,nil,nil,13,14,{0,1000,1,nil,nil,4,nil},nil,nil,nil},{15,nil,15,15,nil,nil,nil,13,16,{1,255,1,nil,nil,5,nil},nil,nil,nil},{17,nil,17,17,nil,nil,nil,18,19,{1,255,1,nil,nil,6,nil},nil,nil,nil},{20,nil,20,21,nil,nil,nil,13,22,{0,1000,1,nil,nil,7,nil},nil,nil,nil},{23,nil,23,24,nil,nil,nil,18,25,{0,1000,1,nil,nil,8,nil},nil,nil,nil},{26,nil,26,27,nil,nil,nil,27,28,{0,43200,1,1,nil,9,nil},nil,nil,1},{29,nil,29,21,nil,nil,nil,13,30,{0,1000,1,nil,nil,10,nil},nil,nil,nil},{31,nil,31,24,nil,nil,nil,18,32,{0,1000,1,nil,nil,11,nil},nil,nil,nil},{33,nil,33,27,nil,nil,nil,27,34,{0,43200,1,1,nil,12,nil},nil,nil,1},{35,nil,35,36,nil,nil,nil,37,38,{0,255,1,nil,nil,13,nil},nil,nil,nil},{39,nil,39,40,nil,nil,nil,41,42,{0,255,1,nil,nil,14,nil},nil,nil,nil},{43,nil,43,44,nil,nil,nil,45,46,{0,6553.5,0.1,1,nil,15,nil},nil,nil,1},{47,nil,47,48,nil,nil,nil,49,50,{0,6553.5,0.1,1,nil,16,nil},nil,nil,1}},numeric)
custom_capabilities.enum=build({{51,51,52,52,53,nil,nil,51,54,{55,56,57},{55,56,57},17,18,17},{58,58,59,59,60,nil,nil,58,61,{62,63,64},{62,63,64},19,20,19},{65,65,66,66,67,nil,nil,65,68,{69,70,71},{69,70,71},21,22,21},{72,nil,72,72,nil,nil,nil,73,74,{75,76,77},{75,76,77},23,24,23},{78,nil,78,66,nil,nil,nil,65,79,{69,70,71},{69,70,71},25,26,25},{80,nil,80,66,nil,nil,nil,65,81,{69,70,71},{69,70,71},27,28,27},{82,nil,82,52,nil,nil,nil,51,83,{55,56,57},{55,56,57},29,30,29},{84,nil,84,52,nil,nil,nil,51,85,{55,56},{55,56},31,32,31},{86,nil,86,87,nil,0,0,88,89,{90,91,92,93,94,95,96,97,98},{90,91,92,93,94,95,96,97,98},33,34,33},{99,nil,99,52,nil,nil,nil,100,101,{55,56,62,57},{55,56,62,57},35,36,35}},enum)
custom_capabilities.text=build({{102,103,103,0,0,nil,104,64}},text)
custom_capabilities.driver_message={["attribute_name"]="driverMessage",["capability_id"]="concertmirror08464.driverMessage",["emit_name"]="driver_message",["label"]="Driver message",["maximum_length"]=512}
custom_capabilities.by_range_key={}
custom_capabilities.by_emit_name={}
custom_capabilities.by_capability_id={}
local function index_metadata(definitions)
for _,metadata in ipairs(definitions)do
custom_capabilities.by_emit_name[metadata.emit_name]=metadata
if type(metadata.capability_id)=="string" and metadata.capability_id ~="" then custom_capabilities.by_capability_id[metadata.capability_id]=metadata end
if type(metadata.range_key)=="string" and metadata.range_key ~="" then custom_capabilities.by_range_key[metadata.range_key]=metadata end
end
end
index_metadata(custom_capabilities.numeric)
index_metadata(custom_capabilities.enum)
index_metadata(custom_capabilities.text)
custom_capabilities.by_emit_name[custom_capabilities.driver_message.emit_name]=custom_capabilities.driver_message
custom_capabilities.by_capability_id[custom_capabilities.driver_message.capability_id]=custom_capabilities.driver_message
local function clone_allowed_values(allowed_values)
if type(allowed_values)~="table" then return nil end
local copied={}
for index,value in ipairs(allowed_values)do copied[index]=value end
return copied
end
function custom_capabilities.resolve_range(definition,metadata)
if type(metadata)~="table" then return nil end
local default_range=type(metadata.default_range)=="table" and metadata.default_range or nil
local ranges=type(definition)=="table" and definition.presence_capability_ranges or nil
local resolved=type(ranges)=="table" and ranges[metadata.range_key]or nil
if type(resolved)~="table" then resolved=default_range end
if type(resolved)~="table" then return nil end
return{
minimum=type(resolved.minimum)=="number" and resolved.minimum or(default_range and default_range.minimum or nil),
maximum=type(resolved.maximum)=="number" and resolved.maximum or(default_range and default_range.maximum or nil),
step=type(resolved.step)=="number" and resolved.step or(default_range and default_range.step or nil),
unit=type(resolved.unit)=="string" and resolved.unit or(default_range and default_range.unit or nil),
allowed_values=type(resolved.allowed_values)=="table" and clone_allowed_values(resolved.allowed_values)or clone_allowed_values(default_range and default_range.allowed_values or nil),
}
end
return custom_capabilities
