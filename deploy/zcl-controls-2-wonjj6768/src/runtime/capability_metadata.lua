local custom_capabilities={}
local strings={"slackyThreeSceneIdOne","slacky3_scene_id_one","Slacky Three Scene Id One","slackyThreeGroupIdOne","slacky3_group_id_one","Slacky Three Group Id One","slackyThreeMinLevelOne","slacky3_min_level_one","Slacky Three Min Level One","slackyThreeMaxLevelOne","slacky3_max_level_one","Slacky Three Max Level One","slackyThreeSceneIdTwo","slacky3_scene_id_two","Slacky Three Scene Id Two","slackyThreeGroupIdTwo","slacky3_group_id_two","Slacky Three Group Id Two","slackyThreeMinLevelTwo","slacky3_min_level_two","Slacky Three Min Level Two","slackyThreeMaxLevelTwo","slacky3_max_level_two","Slacky Three Max Level Two","slackyThreeSceneIdThree","slacky3_scene_id_three","Slacky Three Scene Id Three","slackyThreeGroupIdThree","slacky3_group_id_three","Slacky Three Group Id Three","slackyThreeMinLevelThree","slacky3_min_level_three","Slacky Three Min Level Three","slackyThreeMaxLevelThree","slacky3_max_level_three","Slacky Three Max Level Three","*","aqH1RotationAngle","rotationAngle","aq_h1_rotation_angle","Aq H1Rotation Angle","aqH1RotationAngleSpeed","rotationAngleSpeed","aq_h1_rotation_angle_speed","Aq H1Rotation Angle Speed","%","aqH1RotationPercent","rotationPercent","aq_h1_rotation_percent","Aq H1Rotation Percent","aqH1RotationPercentSpeed","rotationPercentSpeed","aq_h1_rotation_percent_speed","Aq H1Rotation Percent Speed","ms","aqH1RotationTime","rotationTime","aq_h1_rotation_time","Aq H1Rotation Time","s","stredaSn2OnOffTransitionTime","onOffTransitionTime","streda_sn2_on_off_transition_time","Streda Sn2On Off Transition Time","stredaSn2OnTransitionTime","onTransitionTime","streda_sn2_on_transition_time","Streda Sn2On Transition Time","stredaSn2OffTransitionTime","offTransitionTime","streda_sn2_off_transition_time","Streda Sn2Off Transition Time","stredaSn2OnLevel","onLevel","streda_sn2_on_level","Streda Sn2On Level","stredaSn2StartupLevel","startupLevel","streda_sn2_startup_level","Streda Sn2Startup Level","candeoRd1pRemAction","candeoRdOnepRemAction","candeo_rd1p_rem_action","Candeo Rd1p Rem Action","pressed","double_pressed","held","released","started_rotating_left","started_rotating_right","rotating_right","rotating_left","stopped_rotating","slackyThreeSwitchActionOne","slacky3_switch_action_one","Slacky Three Switch Action One","off","on","toggle","slackyThreeSwitchTypeOne","slacky3_switch_type_one","Slacky Three Switch Type One","momentary","multifunction","brightness_level","brightness_level_up","brightness_level_down","move_to_color_temperature","move_to_color_temperature_up","move_to_color_temperature_down","scene","slackyThreeSwitchActionTwo","slacky3_switch_action_two","Slacky Three Switch Action Two","slackyThreeSwitchTypeTwo","slacky3_switch_type_two","Slacky Three Switch Type Two","slackyThreeSwitchActionThree","slacky3_switch_action_three","Slacky Three Switch Action Three","slackyThreeSwitchTypeThree","slacky3_switch_type_three","Slacky Three Switch Type Three","jetHomeWs7Action","jetHomeWsAction","jethome_ws7_action_in1","Jet Home Ws7Action","release_in1","single_in1","double_in1","triple_in1","hold_in1","release_in2","single_in2","double_in2","triple_in2","hold_in2","release_in3","single_in3","double_in3","triple_in3","hold_in3","sonoffKfAction","action","sonoff_kf_action","Sonoff Kf Action","single","aqH1Action","aq_h1_action","Aq H1Action","hold","double","release","start_rotating","rotation","stop_rotating","aqH1RotationButtonState","rotationButtonState","aq_h1_rotation_button_state","Aq H1Rotation Button State","aqH1OperationMode","operationMode","aq_h1_operation_mode","Aq H1Operation Mode","event","command","aqH1Sensitivity","sensitivity","aq_h1_sensitivity","Aq H1Sensitivity","low","medium","high","stredaBn0sAction","streda_bn0s_action","Streda Bn0s Action","single_up_button_1","double_up_button_1","release_up_button_1","hold_up_button_1","single_down_button_1","double_down_button_1","release_down_button_1","hold_down_button_1","stredaBn0tAction","streda_bn0t_action","Streda Bn0t Action","single_up_button_2","double_up_button_2","release_up_button_2","hold_up_button_2","single_down_button_2","double_down_button_2","release_down_button_2","hold_down_button_2","stredaSn3Action","streda_sn3_action","Streda Sn3Action","stredaSn3kAction","streda_sn3k_action","Streda Sn3k Action","single_doorbell_button","double_doorbell_button","release_doorbell_button","hold_doorbell_button","stredaSn3Doorbell","doorbell","streda_sn3_doorbell","Streda Sn3Doorbell","ring","stredaSn3kDoorbell","streda_sn3k_doorbell","Streda Sn3k Doorbell","stredaSn2ExecuteIfOff","executeIfOff","streda_sn2_execute_if_off","Streda Sn2Execute If Off","r3sb22bzAction","r3sb22bz_action","R3sb22bz Action","triple","quadruple","many","last_power_response_time","lastPowerResponseTime","Last power response time","remote_action","remoteAction","Remote action"}
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
local out={}
table_groups[group_id]=out
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
for _,row in ipairs(rows)do out[#out+1]=factory(row)end
return out
end
custom_capabilities.numeric=build({{1,nil,1,1,nil,nil,nil,2,3,{0,255,1,nil,nil,1,nil},nil,nil,nil},{4,nil,4,4,nil,nil,nil,5,6,{0,65527,1,nil,nil,2,nil},nil,nil,nil},{7,nil,7,7,nil,nil,nil,8,9,{1,255,1,nil,nil,3,nil},nil,nil,nil},{10,nil,10,10,nil,nil,nil,11,12,{1,255,1,nil,nil,4,nil},nil,nil,nil},{13,nil,13,13,nil,nil,nil,14,15,{0,255,1,nil,nil,5,nil},nil,nil,nil},{16,nil,16,16,nil,nil,nil,17,18,{0,65527,1,nil,nil,6,nil},nil,nil,nil},{19,nil,19,19,nil,nil,nil,20,21,{1,255,1,nil,nil,7,nil},nil,nil,nil},{22,nil,22,22,nil,nil,nil,23,24,{1,255,1,nil,nil,8,nil},nil,nil,nil},{25,nil,25,25,nil,nil,nil,26,27,{0,255,1,nil,nil,9,nil},nil,nil,nil},{28,nil,28,28,nil,nil,nil,29,30,{0,65527,1,nil,nil,10,nil},nil,nil,nil},{31,nil,31,31,nil,nil,nil,32,33,{1,255,1,nil,nil,11,nil},nil,nil,nil},{34,nil,34,34,nil,nil,nil,35,36,{1,255,1,nil,nil,12,nil},nil,nil,nil},{38,nil,38,39,nil,0,0,40,41,{nil,nil,nil,37,nil,13,nil},nil,nil,37},{42,nil,42,43,nil,0,0,44,45,{nil,nil,nil,37,nil,14,nil},nil,nil,37},{47,nil,47,48,nil,0,0,49,50,{nil,nil,nil,46,nil,15,nil},nil,nil,46},{51,nil,51,52,nil,0,0,53,54,{nil,nil,nil,46,nil,16,nil},nil,nil,46},{56,nil,56,57,nil,0,0,58,59,{nil,nil,nil,55,nil,17,nil},nil,nil,55},{61,nil,61,62,nil,nil,nil,63,64,{0,6553.5,0.1,60,nil,18,nil},nil,nil,60},{65,nil,65,66,nil,nil,nil,67,68,{0,6553.5,0.1,60,nil,19,nil},nil,nil,60},{69,nil,69,70,nil,nil,nil,71,72,{0,6553.5,0.1,60,nil,20,nil},nil,nil,60},{73,nil,73,74,nil,nil,nil,75,76,{0,255,1,nil,nil,21,nil},nil,nil,nil},{77,nil,77,78,nil,nil,nil,79,80,{0,255,1,nil,nil,22,nil},nil,nil,nil}},numeric)
custom_capabilities.enum=build({{81,nil,81,82,nil,0,0,83,84,{85,86,87,88,89,90,91,92,93},{85,86,87,88,89,90,91,92,93},23,24,23},{94,nil,94,94,nil,nil,nil,95,96,{97,98,99},{97,98,99},25,26,25},{100,nil,100,100,nil,nil,nil,101,102,{99,103,104,105,106,107,108,109,110,111},{99,103,104,105,106,107,108,109,110,111},27,28,27},{112,nil,112,112,nil,nil,nil,113,114,{97,98,99},{97,98,99},29,30,29},{115,nil,115,115,nil,nil,nil,116,117,{99,103,104,105,106,107,108,109,110,111},{99,103,104,105,106,107,108,109,110,111},31,32,31},{118,nil,118,118,nil,nil,nil,119,120,{97,98,99},{97,98,99},33,34,33},{121,nil,121,121,nil,nil,nil,122,123,{99,103,104,105,106,107,108,109,110,111},{99,103,104,105,106,107,108,109,110,111},35,36,35},{124,nil,124,125,nil,0,0,126,127,{128,129,130,131,132,133,134,135,136,137,138,139,140,141,142},{128,129,130,131,132,133,134,135,136,137,138,139,140,141,142},37,38,37},{143,nil,143,144,nil,0,0,145,146,{97,147},{97,147},39,40,39},{148,nil,148,144,nil,0,0,149,150,{151,147,152,153,154,155,156},{151,147,152,153,154,155,156},41,42,41},{157,nil,157,158,nil,0,0,159,160,{88,85},{88,85},43,44,43},{161,nil,161,162,nil,nil,nil,163,164,{165,166},{165,166},45,46,45},{167,nil,167,168,nil,nil,nil,169,170,{171,172,173},{171,172,173},47,48,47},{174,nil,174,144,nil,0,0,175,176,{177,178,179,180,181,182,183,184},{177,178,179,180,181,182,183,184},49,50,49},{185,nil,185,144,nil,0,0,186,187,{177,178,179,180,181,182,183,184,188,189,190,191,192,193,194,195},{177,178,179,180,181,182,183,184,188,189,190,191,192,193,194,195},51,52,51},{196,nil,196,144,nil,0,0,197,198,{177,178,179,180,181,182,183,184,188,189,190,191,192,193,194,195},{177,178,179,180,181,182,183,184,188,189,190,191,192,193,194,195},53,54,53},{199,nil,199,144,nil,0,0,200,201,{177,178,179,180,181,182,183,184,188,189,190,191,192,193,194,195,202,203,204,205},{177,178,179,180,181,182,183,184,188,189,190,191,192,193,194,195,202,203,204,205},55,56,55},{206,nil,206,207,nil,nil,nil,208,209,{210},{210},57,58,57},{211,nil,211,207,nil,nil,nil,212,213,{210},{210},59,60,59},{214,nil,214,215,nil,nil,nil,216,217,{98,97},{98,97},61,62,61},{218,nil,218,144,nil,0,0,219,220,{147,152,151,153,221,222,223},{147,152,151,153,221,222,223},63,64,63}},enum)
custom_capabilities.text=build({{224,225,225,0,0,nil,226,64},{227,228,228,0,0,nil,229,128}},text)
custom_capabilities.driver_message={["attribute_name"]="driverMessage",["capability_id"]="concertmirror08464.driverMessage",["emit_name"]="driver_message",["label"]="Driver message",["maximum_length"]=512}
custom_capabilities.by_range_key={}
custom_capabilities.by_emit_name={}
custom_capabilities.by_capability_id={}
local function index_metadata(definitions)
for _,metadata in ipairs(definitions)do
custom_capabilities.by_emit_name[metadata.emit_name]=metadata
if type(metadata.capability_id)=="string"and metadata.capability_id~=""then custom_capabilities.by_capability_id[metadata.capability_id]=metadata end
if type(metadata.range_key)=="string"and metadata.range_key~=""then custom_capabilities.by_range_key[metadata.range_key]=metadata end
end
end
index_metadata(custom_capabilities.numeric)
index_metadata(custom_capabilities.enum)
index_metadata(custom_capabilities.text)
custom_capabilities.by_emit_name[custom_capabilities.driver_message.emit_name]=custom_capabilities.driver_message
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
minimum=type(resolved.minimum)=="number"and resolved.minimum or(default_range and default_range.minimum or nil),
maximum=type(resolved.maximum)=="number"and resolved.maximum or(default_range and default_range.maximum or nil),
step=type(resolved.step)=="number"and resolved.step or(default_range and default_range.step or nil),
unit=type(resolved.unit)=="string"and resolved.unit or(default_range and default_range.unit or nil),
allowed_values=type(resolved.allowed_values)=="table"and clone_allowed_values(resolved.allowed_values)or clone_allowed_values(default_range and default_range.allowed_values or nil),}
end
return custom_capabilities
