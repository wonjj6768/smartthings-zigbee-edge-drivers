local custom_capabilities={}
local strings={"slackyThreeSceneIdOne","slacky3_scene_id_one","Slacky Three Scene Id One","slackyThreeGroupIdOne","slacky3_group_id_one","Slacky Three Group Id One","slackyThreeMinLevelOne","slacky3_min_level_one","Slacky Three Min Level One","slackyThreeMaxLevelOne","slacky3_max_level_one","Slacky Three Max Level One","slackyThreeSceneIdTwo","slacky3_scene_id_two","Slacky Three Scene Id Two","slackyThreeGroupIdTwo","slacky3_group_id_two","Slacky Three Group Id Two","slackyThreeMinLevelTwo","slacky3_min_level_two","Slacky Three Min Level Two","slackyThreeMaxLevelTwo","slacky3_max_level_two","Slacky Three Max Level Two","slackyThreeSceneIdThree","slacky3_scene_id_three","Slacky Three Scene Id Three","slackyThreeGroupIdThree","slacky3_group_id_three","Slacky Three Group Id Three","slackyThreeMinLevelThree","slacky3_min_level_three","Slacky Three Min Level Three","slackyThreeMaxLevelThree","slacky3_max_level_three","Slacky Three Max Level Three","candeoRd1pRemAction","candeoRdOnepRemAction","candeo_rd1p_rem_action","Candeo Rd1p Rem Action","pressed","double_pressed","held","released","started_rotating_left","started_rotating_right","rotating_right","rotating_left","stopped_rotating","slackyThreeSwitchActionOne","slacky3_switch_action_one","Slacky Three Switch Action One","off","on","toggle","slackyThreeSwitchTypeOne","slacky3_switch_type_one","Slacky Three Switch Type One","momentary","multifunction","brightness_level","brightness_level_up","brightness_level_down","move_to_color_temperature","move_to_color_temperature_up","move_to_color_temperature_down","scene","slackyThreeSwitchActionTwo","slacky3_switch_action_two","Slacky Three Switch Action Two","slackyThreeSwitchTypeTwo","slacky3_switch_type_two","Slacky Three Switch Type Two","slackyThreeSwitchActionThree","slacky3_switch_action_three","Slacky Three Switch Action Three","slackyThreeSwitchTypeThree","slacky3_switch_type_three","Slacky Three Switch Type Three","jetHomeWs7Action","jetHomeWsAction","jethome_ws7_action_in1","Jet Home Ws7Action","release_in1","single_in1","double_in1","triple_in1","hold_in1","release_in2","single_in2","double_in2","triple_in2","hold_in2","release_in3","single_in3","double_in3","triple_in3","hold_in3","sonoffKfAction","action","sonoff_kf_action","Sonoff Kf Action","single","last_power_response_time","lastPowerResponseTime","Last power response time","remote_action","remoteAction","Remote action"}
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
custom_capabilities.numeric=build({{1,nil,1,1,nil,nil,nil,2,3,{0,255,1,nil,nil,1,nil},nil,nil,nil},{4,nil,4,4,nil,nil,nil,5,6,{0,65527,1,nil,nil,2,nil},nil,nil,nil},{7,nil,7,7,nil,nil,nil,8,9,{1,255,1,nil,nil,3,nil},nil,nil,nil},{10,nil,10,10,nil,nil,nil,11,12,{1,255,1,nil,nil,4,nil},nil,nil,nil},{13,nil,13,13,nil,nil,nil,14,15,{0,255,1,nil,nil,5,nil},nil,nil,nil},{16,nil,16,16,nil,nil,nil,17,18,{0,65527,1,nil,nil,6,nil},nil,nil,nil},{19,nil,19,19,nil,nil,nil,20,21,{1,255,1,nil,nil,7,nil},nil,nil,nil},{22,nil,22,22,nil,nil,nil,23,24,{1,255,1,nil,nil,8,nil},nil,nil,nil},{25,nil,25,25,nil,nil,nil,26,27,{0,255,1,nil,nil,9,nil},nil,nil,nil},{28,nil,28,28,nil,nil,nil,29,30,{0,65527,1,nil,nil,10,nil},nil,nil,nil},{31,nil,31,31,nil,nil,nil,32,33,{1,255,1,nil,nil,11,nil},nil,nil,nil},{34,nil,34,34,nil,nil,nil,35,36,{1,255,1,nil,nil,12,nil},nil,nil,nil}},numeric)
custom_capabilities.enum=build({{37,nil,37,38,nil,0,0,39,40,{41,42,43,44,45,46,47,48,49},{41,42,43,44,45,46,47,48,49},13,14,13},{50,nil,50,50,nil,nil,nil,51,52,{53,54,55},{53,54,55},15,16,15},{56,nil,56,56,nil,nil,nil,57,58,{55,59,60,61,62,63,64,65,66,67},{55,59,60,61,62,63,64,65,66,67},17,18,17},{68,nil,68,68,nil,nil,nil,69,70,{53,54,55},{53,54,55},19,20,19},{71,nil,71,71,nil,nil,nil,72,73,{55,59,60,61,62,63,64,65,66,67},{55,59,60,61,62,63,64,65,66,67},21,22,21},{74,nil,74,74,nil,nil,nil,75,76,{53,54,55},{53,54,55},23,24,23},{77,nil,77,77,nil,nil,nil,78,79,{55,59,60,61,62,63,64,65,66,67},{55,59,60,61,62,63,64,65,66,67},25,26,25},{80,nil,80,81,nil,0,0,82,83,{84,85,86,87,88,89,90,91,92,93,94,95,96,97,98},{84,85,86,87,88,89,90,91,92,93,94,95,96,97,98},27,28,27},{99,nil,99,100,nil,0,0,101,102,{53,103},{53,103},29,30,29}},enum)
custom_capabilities.text=build({{104,105,105,0,0,nil,106,64},{107,108,108,0,0,nil,109,128}},text)
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
