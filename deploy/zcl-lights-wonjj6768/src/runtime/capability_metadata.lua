local custom_capabilities={}local strings={"s","power_poll_interval","powerPollIntervalV2","powerPollInterval","powerPollIntervalRange","Power poll interval","countdownTsOneTenHours","countdown_timer","Countdown Ts One Ten Hours","countdownTsOneTenHalfMinute","Countdown Ts One Ten Half Minute","minBrightnessZclThousand","min_brightness","Min Brightness Zcl Thousand","minimumBrightnessTsOneTenMax","Minimum Brightness Ts One Ten Max","maxBrightnessTsOneTenMax","max_brightness","Max Brightness Ts One Ten Max","candeoRd1pDpmOnLevel","onLevel","candeo_rd1p_dpm_on_level","Candeo Rd1p Dpm On Level","candeoRd1pDpmStartupLevel","startupLevel","candeo_rd1p_dpm_startup_level","Candeo Rd1p Dpm Startup Level","candeoRd1pDpmOnTransitionTime","onTransitionTime","candeo_rd1p_dpm_on_transition_time","Candeo Rd1p Dpm On Transition Time","candeoRd1pDpmOffTransitionTime","offTransitionTime","candeo_rd1p_dpm_off_transition_time","Candeo Rd1p Dpm Off Transition Time","power_on_behavior","powerOnBehavior","supportedPowerOnBehaviors","Power on behavior","off","on","previous","switch_type","switchType","supportedSwitchTypes","Switch type","toggle","state","momentary","light_type","lightType","supportedLightTypes","Light type","led","incandescent","halogen","fanModeSequenceAcController","fan_mode_sequence","Fan Mode Sequence Ac Controller","low_medium_high","low_high","on_auto","candeoRd1pDpmAction","dpmAction","candeo_rd1p_dpm_action","Candeo Rd1p Dpm Action","pressed","double_pressed","held","released","started_rotating_left","started_rotating_right","rotating_right","rotating_left","stopped_rotating","candeoRd1pDpmPowerBehavior","candeo_rd1p_dpm_power_on_behavior","Candeo Rd1p Dpm Power Behavior","tsFanBacklight","backlightMode","ts_fan_backlight","Ts Fan Backlight","red_when_on","pink_when_on","red_on_blue_off","pink_on_blue_off","lonD2PowerOne","lon_d_two_power_one","Lon D2Power One","lonD2PowerTwo","lon_d_two_power_two","Lon D2Power Two","livarnoEffect","effect","livarno_effect","Livarno Effect","blink","breathe","okay","channel_change","finish_effect","stop_effect","colorloop","stop_colorloop","livarnoDoNotDisturb","doNotDisturb","livarno_do_not_disturb","Livarno Do Not Disturb","enabled","disabled","livarnoColorPowerBehavior","colorPowerBehavior","livarno_color_power_on_behavior","Livarno Color Power Behavior","initial","customized","ts0505bTwoEffect","ts0505b_two_effect","Ts0505b Two Effect","ts0505bTwoDoNotDisturb","ts0505b_two_do_not_disturb","Ts0505b Two Do Not Disturb","ts0505bTwoColorPowerBehavior","ts0505b_two_color_power_on_behavior","Ts0505b Two Color Power Behavior","ledvanceA60PowerBehavior","powerBehavior","ledvance_a60_power_behavior","Ledvance A60Power Behavior","ledvanceA60Effect","ledvance_a60_effect","Ledvance A60Effect","last_power_response_time","lastPowerResponseTime","Last power response time"}
local function string_value(value)
if type(value)=="number"then return strings[value]end
return value
end
local function capability_id(value)local suffix=string_value(value);if suffix==nil then return nil end;return"concertmirror08464."..suffix end
local table_groups={}
local function grouped_table(group_id)
if type(group_id)~="number"then return{}end
local existing=table_groups[group_id]
if existing~=nil then return existing end
local out={}table_groups[group_id]=out
return out
end
local function string_list(values,group_id)
if type(values)~="table"then return nil end
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
if type(attribute_name)~="string"or attribute_name==""then return nil end
return"set"..attribute_name:sub(1,1):upper()..attribute_name:sub(2)
end
local function range(value)
if type(value)~="table"then return nil end
local out=grouped_table(value[6])out.minimum=value[1]out.maximum=value[2]out.step=value[3]out.unit=string_value(value[4])out.allowed_values=string_list(value[5],value[7])return out
end
local function allowed_range(allowed_values,group_id)
if allowed_values==nil and group_id==nil then return nil end
local out=grouped_table(group_id)out.allowed_values=allowed_values
return out
end
local function numeric(row)
local attribute_name=string_value(row[4])return{kind="numeric",emit_name=string_value(row[1]),range_key=string_value(row[2]),capability_id=capability_id(row[3]),attribute_name=attribute_name,range_attribute_name=string_value(row[5]),command_name=optional_string(row[6],command_default(attribute_name)),argument_name=optional_string(row[7],attribute_name),mapping_name=string_value(row[8]),label=string_value(row[9]),default_range=range(row[10]),event_minimum=row[11],event_maximum=row[12],event_unit=string_value(row[13])}
end
local function enum(row)
local attribute_name=string_value(row[4])local supported_values=string_list(row[10],row[12])local default_allowed_values=string_list(row[11],row[14])local default_range=allowed_range(default_allowed_values,row[13])return{kind="enum",emit_name=string_value(row[1]),range_key=string_value(row[2]),capability_id=capability_id(row[3]),attribute_name=attribute_name,supported_attribute_name=string_value(row[5]),command_name=optional_string(row[6],command_default(attribute_name)),argument_name=optional_string(row[7],attribute_name),mapping_name=string_value(row[8]),label=string_value(row[9]),supported_values=supported_values,default_range=default_range}
end
local function text(row)
local attribute_name=string_value(row[3])return{kind="text",emit_name=string_value(row[1]),capability_id=capability_id(row[2]),attribute_name=attribute_name,command_name=optional_string(row[4],command_default(attribute_name)),argument_name=optional_string(row[5],attribute_name),mapping_name=string_value(row[6]),label=string_value(row[7]),maximum_length=row[8]}
end
local function build(rows,factory)
local out={}
for _,row in ipairs(rows)do out[#out+1]=factory(row)end
return out
end
custom_capabilities.numeric=build({{2,2,3,4,5,nil,nil,2,6,{5,3600,5,1,nil,1,nil},5,3600,1},{7,nil,7,7,nil,nil,nil,8,9,{0,43200,1,1,nil,2,nil},nil,nil,1},{10,nil,10,10,nil,nil,nil,8,11,{0,43200,30,1,nil,3,nil},nil,nil,1},{12,nil,12,12,nil,nil,nil,13,14,{0,1000,1,nil,nil,4,nil},nil,nil,nil},{15,nil,15,15,nil,nil,nil,13,16,{1,255,1,nil,nil,5,nil},nil,nil,nil},{17,nil,17,17,nil,nil,nil,18,19,{1,255,1,nil,nil,6,nil},nil,nil,nil},{20,nil,20,21,nil,nil,nil,22,23,{0,255,1,nil,nil,7,nil},nil,nil,nil},{24,nil,24,25,nil,nil,nil,26,27,{0,255,1,nil,nil,8,nil},nil,nil,nil},{28,nil,28,29,nil,nil,nil,30,31,{0,6553.5,0.1,1,nil,9,nil},nil,nil,1},{32,nil,32,33,nil,nil,nil,34,35,{0,6553.5,0.1,1,nil,10,nil},nil,nil,1}},numeric)custom_capabilities.enum=build({{36,36,37,37,38,nil,nil,36,39,{40,41,42},{40,41,42},11,12,11},{43,43,44,44,45,nil,nil,43,46,{47,48,49},{47,48,49},13,14,13},{50,50,51,51,52,nil,nil,50,53,{54,55,56},{54,55,56},15,16,15},{57,nil,57,57,nil,nil,nil,58,59,{60,61,62},{60,61,62},17,18,17},{63,nil,63,64,nil,0,0,65,66,{67,68,69,70,71,72,73,74,75},{67,68,69,70,71,72,73,74,75},19,20,19},{76,nil,76,37,nil,nil,nil,77,78,{40,41,47,42},{40,41,47,42},21,22,21},{79,nil,79,80,nil,nil,nil,81,82,{83,84,85,86},{83,84,85,86},23,24,23},{87,nil,87,37,nil,nil,nil,88,89,{40,41,47,42},{40,41,47,42},25,26,25},{90,nil,90,37,nil,nil,nil,91,92,{40,41,47,42},{40,41,47,42},27,28,27},{93,nil,93,94,nil,nil,nil,95,96,{97,98,99,100,101,102,103,104},{97,98,99,100,101,102,103,104},29,30,29},{105,nil,105,106,nil,nil,nil,107,108,{109,110},{109,110},31,32,31},{111,nil,111,112,nil,nil,nil,113,114,{115,42,116},{115,42,116},33,34,33},{117,nil,117,94,nil,nil,nil,118,119,{97,98,99,100,101,102,103,104},{97,98,99,100,101,102,103,104},35,36,35},{120,nil,120,106,nil,nil,nil,121,122,{109,110},{109,110},37,38,37},{123,nil,123,112,nil,nil,nil,124,125,{115,42,116},{115,42,116},39,40,39},{126,nil,126,127,nil,nil,nil,128,129,{40,41,47,42},{40,41,47,42},41,42,41},{130,nil,130,94,nil,nil,nil,131,132,{97,98,99,100,101,102,103,104},{97,98,99,100,101,102,103,104},43,44,43}},enum)custom_capabilities.text=build({{133,134,134,0,0,nil,135,64}},text)custom_capabilities.driver_message={["attribute_name"]="driverMessage",["capability_id"]="concertmirror08464.driverMessage",["emit_name"]="driver_message",["label"]="Driver message",["maximum_length"]=512}custom_capabilities.by_range_key={}custom_capabilities.by_emit_name={}custom_capabilities.by_capability_id={}
local function index_metadata(definitions)
for _,metadata in ipairs(definitions)do
custom_capabilities.by_emit_name[metadata.emit_name]=metadata
if type(metadata.capability_id)=="string"and metadata.capability_id~=""then custom_capabilities.by_capability_id[metadata.capability_id]=metadata end
if type(metadata.range_key)=="string"and metadata.range_key~=""then custom_capabilities.by_range_key[metadata.range_key]=metadata end
end
end
index_metadata(custom_capabilities.numeric)index_metadata(custom_capabilities.enum)index_metadata(custom_capabilities.text)custom_capabilities.by_emit_name[custom_capabilities.driver_message.emit_name]=custom_capabilities.driver_message
custom_capabilities.by_capability_id[custom_capabilities.driver_message.capability_id]=custom_capabilities.driver_message
local function clone_allowed_values(allowed_values)
if type(allowed_values)~="table"then return nil end
local copied={}
for index,value in ipairs(allowed_values)do copied[index]=value end
return copied
end
function custom_capabilities.resolve_range(definition,metadata)
if type(metadata)~="table"then return nil end
local default_range=type(metadata.default_range)=="table"and metadata.default_range or nil
local ranges=type(definition)=="table"and definition.presence_capability_ranges or nil
local resolved=type(ranges)=="table"and ranges[metadata.range_key]or nil
if type(resolved)~="table"then resolved=default_range end
if type(resolved)~="table"then return nil end
return{
minimum=type(resolved.minimum)=="number"and resolved.minimum or(default_range and default_range.minimum or nil),maximum=type(resolved.maximum)=="number"and resolved.maximum or(default_range and default_range.maximum or nil),step=type(resolved.step)=="number"and resolved.step or(default_range and default_range.step or nil),unit=type(resolved.unit)=="string"and resolved.unit or(default_range and default_range.unit or nil),allowed_values=type(resolved.allowed_values)=="table"and clone_allowed_values(resolved.allowed_values)or clone_allowed_values(default_range and default_range.allowed_values or nil),}
end
return custom_capabilities
