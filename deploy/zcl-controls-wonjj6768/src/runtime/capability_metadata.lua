local custom_capabilities={}local strings={"tsfKnobStep","stepSize","action_step_size","Tsf Knob Step","tsfKnobBrightnessDelta","brightnessDelta","action_brightness_delta","Tsf Knob Brightness Delta","mired","tsfKnobColorDelta","colorDelta","action_color_temperature_delta","Tsf Knob Color Delta","s","tsfKnobTransition","transitionTime","action_transition_time","Tsf Knob Transition","tsfKnobRate","rate","action_rate","Tsf Knob Rate","battery_low","batteryLow","Battery low","normal","low","power_on_behavior","powerOnBehavior","supportedPowerOnBehaviors","Power on behavior","off","on","previous","switch_mode","switchMode","supportedSwitchModes","Switch mode","switch","scene","operation_mode","operationMode","supportedOperationModes","Operation mode","command","event","learn_ir_code","learnIrCode","supportedLearnIrCodes","Learn IR code","start","stop","security_remote_action","securityRemoteAction","supportedSecurityRemoteActions","Security remote action","disarm","arm_day_zones","arm_night_zones","arm_all_zones","exit_delay","emergency","heiman_rc_partial_security_action","heimanRcPartialSecurityAction","HEIMAN RC partial security action","arm_partial_zones","shellyOneSwitchType","switchType","shelly_one_switch_type","Shelly One Switch Type","toggle","momentary","candeoRd1pRemAction","candeoRdOnepRemAction","candeo_rd1p_rem_action","Candeo Rd1p Rem Action","pressed","double_pressed","held","released","started_rotating_left","started_rotating_right","rotating_right","rotating_left","stopped_rotating","ts0726FourScenePowerBehavior","powerBehavior","ts0726_four_scene_power_behavior","Ts0726Four Scene Power Behavior","ts0726FourSceneSwitchMode","ts0726_four_scene_switch_mode","Ts0726Four Scene Switch Mode","tsfKnobAction","action","tsf_knob_action","Tsf Knob Action","single","double","hold","rotate_left","rotate_right","brightness_step_up","brightness_step_down","color_temperature_step_up","color_temperature_step_down","hue_move","hue_down","hue_stop","tsfKnobMode","Tsf Knob Mode","last_power_response_time","lastPowerResponseTime","Last power response time","remote_action","remoteAction","Remote action","learned_ir_code","learnedIrCode","Learned IR code","ir_code_to_send","irCodeToSend","IR code to send"}
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
custom_capabilities.numeric=build({{1,nil,1,2,nil,0,0,3,4,{0,255,1,nil,nil,1,nil},nil,nil,nil},{5,nil,5,6,nil,0,0,7,8,{-255,255,1,nil,nil,2,nil},nil,nil,nil},{10,nil,10,11,nil,0,0,12,13,{-65535,65535,1,9,nil,3,nil},nil,nil,9},{15,nil,15,16,nil,0,0,17,18,{0,6553.5,0.1,14,nil,4,nil},nil,nil,14},{19,nil,19,20,nil,0,0,21,22,{0,255,1,nil,nil,5,nil},nil,nil,nil}},numeric)custom_capabilities.enum=build({{23,23,24,24,nil,nil,nil,23,25,{26,27},{26,27},6,7,6},{28,28,29,29,30,nil,nil,28,31,{32,33,34},{32,33,34},8,9,8},{35,35,36,36,37,nil,nil,35,38,{39,40},{39,40},10,11,10},{41,41,42,42,43,nil,nil,41,44,{45,46},{45,46},12,13,12},{47,47,48,48,49,nil,nil,47,50,{51,52},{51,52},14,15,14},{53,53,54,54,55,nil,nil,53,56,{57,58,59,60,61,62},{57,58,59,60,61,62},16,17,16},{63,63,64,64,nil,nil,nil,63,65,{57,66,60,62},{57,66,60,62},18,19,18},{67,nil,67,68,nil,nil,nil,69,70,{71,72},{71,72},20,21,20},{73,nil,73,74,nil,0,0,75,76,{77,78,79,80,81,82,83,84,85},{77,78,79,80,81,82,83,84,85},22,23,22},{86,nil,86,87,nil,nil,nil,88,89,{32,33,34},{32,33,34},24,25,24},{90,nil,90,36,nil,nil,nil,91,92,{39,40},{39,40},26,27,26},{93,nil,93,94,nil,0,0,95,96,{97,98,99,100,101,71,102,103,104,105,106,107,108},{97,98,99,100,101,71,102,103,104,105,106,107,108},28,29,28},{109,nil,109,42,nil,nil,nil,41,110,{45,46},{45,46},30,31,30}},enum)custom_capabilities.text=build({{111,112,112,0,0,nil,113,64},{114,115,115,0,0,nil,116,128},{117,118,118,0,0,nil,119,2048},{120,121,121,nil,nil,nil,122,2048}},text)custom_capabilities.driver_message={["attribute_name"]="driverMessage",["capability_id"]="concertmirror08464.driverMessage",["emit_name"]="driver_message",["label"]="Driver message",["maximum_length"]=512}custom_capabilities.by_range_key={}custom_capabilities.by_emit_name={}custom_capabilities.by_capability_id={}
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
