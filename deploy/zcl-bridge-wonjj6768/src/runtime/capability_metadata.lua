local custom_capabilities={}
local strings={"heimanHsOneIrActionId","actionId","heiman_hs_one_ir_action_id","Heiman Hs One Ir Action Id","heimanHsOneIrActionKeyCode","actionKeyCode","heiman_hs_one_ir_action_key_code","Heiman Hs One Ir Action Key Code","heimanHsOneIrActionModelType","actionModelType","heiman_hs_one_ir_action_model_type","Heiman Hs One Ir Action Model Type","heimanHsTwoIrActionId","heiman_hs_two_ir_action_id","Heiman Hs Two Ir Action Id","heimanHsTwoIrActionKeyCode","heiman_hs_two_ir_action_key_code","Heiman Hs Two Ir Action Key Code","heimanHsTwoIrActionModelType","heiman_hs_two_ir_action_model_type","Heiman Hs Two Ir Action Model Type","candeoRfHubAction","rfAction","candeo_rf_hub_press","Candeo Rf Hub Action","button_1_single_pressed","button_1_double_pressed","button_1_triple_pressed","button_1_quadruple_pressed","button_1_quintuple_pressed","button_2_single_pressed","button_2_double_pressed","button_2_triple_pressed","button_2_quadruple_pressed","button_2_quintuple_pressed","button_3_single_pressed","button_3_double_pressed","button_3_triple_pressed","button_3_quadruple_pressed","button_3_quintuple_pressed","button_4_single_pressed","button_4_double_pressed","button_4_triple_pressed","button_4_quadruple_pressed","button_4_quintuple_pressed","button_5_single_pressed","button_5_double_pressed","button_5_triple_pressed","button_5_quadruple_pressed","button_5_quintuple_pressed","button_6_single_pressed","button_6_double_pressed","button_6_triple_pressed","button_6_quadruple_pressed","button_6_quintuple_pressed","button_7_single_pressed","button_7_double_pressed","button_7_triple_pressed","button_7_quadruple_pressed","button_7_quintuple_pressed","button_8_single_pressed","button_8_double_pressed","button_8_triple_pressed","button_8_quadruple_pressed","button_8_quintuple_pressed","button_9_single_pressed","button_9_double_pressed","button_9_triple_pressed","button_9_quadruple_pressed","button_9_quintuple_pressed","button_10_single_pressed","button_10_double_pressed","button_10_triple_pressed","button_10_quadruple_pressed","button_10_quintuple_pressed","heimanHsOneIrAction","irAction","heiman_hs_one_ir_action","Heiman Hs One Ir Action","create","learn","heimanHsOneIrActionResult","actionResult","heiman_hs_one_ir_action_result","Heiman Hs One Ir Action Result","success","error","heimanHsTwoIrAction","heiman_hs_two_ir_action","Heiman Hs Two Ir Action","heimanHsTwoIrActionResult","heiman_hs_two_ir_action_result","Heiman Hs Two Ir Action Result","last_power_response_time","lastPowerResponseTime","Last power response time","heimanHsOneIrDevices","devices","heiman_hs_one_ir_devices","Heiman Hs One Ir Devices","heimanHsTwoIrDevices","heiman_hs_two_ir_devices","Heiman Hs Two Ir Devices"}
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
custom_capabilities.numeric=build({{1,nil,1,2,nil,0,0,3,4,{0,255,1,nil,nil,1,nil},nil,nil,nil},{5,nil,5,6,nil,0,0,7,8,{0,255,1,nil,nil,2,nil},nil,nil,nil},{9,nil,9,10,nil,0,0,11,12,{0,255,1,nil,nil,3,nil},nil,nil,nil},{13,nil,13,2,nil,0,0,14,15,{0,255,1,nil,nil,4,nil},nil,nil,nil},{16,nil,16,6,nil,0,0,17,18,{0,255,1,nil,nil,5,nil},nil,nil,nil},{19,nil,19,10,nil,0,0,20,21,{0,255,1,nil,nil,6,nil},nil,nil,nil}},numeric)
custom_capabilities.enum=build({{22,nil,22,23,nil,0,0,24,25,{26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75},{26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75},7,8,7},{76,nil,76,77,nil,0,0,78,79,{80,81},{80,81},9,10,9},{82,nil,82,83,nil,0,0,84,85,{86,87},{86,87},11,12,11},{88,nil,88,77,nil,0,0,89,90,{80,81},{80,81},13,14,13},{91,nil,91,83,nil,0,0,92,93,{86,87},{86,87},15,16,15}},enum)
custom_capabilities.text=build({{94,95,95,0,0,nil,96,64},{97,97,98,0,0,99,100,2048},{101,101,98,0,0,102,103,2048}},text)
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
