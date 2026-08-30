local custom_capabilities={}
local strings={"zg302zlSensitivity","sensitivity","Zg302zl Sensitivity","s","zg302zlTriggerHold","triggerHold","trigger_hold","Zg302zl Trigger Hold","zis03DetectionRange","detectionRange","detection_range","Zis03Detection Range","zis03FadingTime","fadingTime","fading_time","Zis03Fading Time","zis03Compensation","compensationCoefficient","compensation_coefficient","Zis03Compensation","m","zis04DetectionDistance","detectionDistance","detection_distance","Zis04Detection Distance","zg302zmSensitivity","Zg302zm Sensitivity","zg302zmDistance","distance","Zg302zm Distance","zg302zmTriggerHold","Zg302zm Trigger Hold","power_outage_memory","powerOutageMemory","supportedPowerOutageMemories","Power outage memory","off","on","restore","zg302zlBacklight","backlight","Zg302zl Backlight","ON","OFF","zg302zlPowerOutage","Zg302zl Power Outage","zg302zlAutoOn","autoOn","auto_on","Zg302zl Auto On","all","ch2","ch3","ch1_and_ch2","ch2_and_ch3","ch1_and_ch3","zg302zlAutoOff","autoOff","auto_off","Zg302zl Auto Off","zis03Sensitivity","Zis03Sensitivity","low","medium","high","max","zis03DetectionArea","detectionArea","detection_area","Zis03Detection Area","left","right","zis03Indicator","indicator","Zis03Indicator","zis03Radar","radar","Zis03Radar","zis03StateReversal","stateReversal","state_reversal","Zis03State Reversal","zg302zmBacklight","Zg302zm Backlight","zg302zmPowerOutage","Zg302zm Power Outage","zg302zmAutoOnV2","Zg302zm Auto On V2","ch1","ch1_2","ch2_3","ch1_3","zg302zmAutoOffV2","Zg302zm Auto Off V2","zg302zmTriggerSwitch","triggerSwitch","trigger_switch","Zg302zm Trigger Switch","last_power_response_time","lastPowerResponseTime","Last power response time"}
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
custom_capabilities.numeric=build({{1,nil,1,2,nil,nil,nil,2,3,{0,19,1,nil,nil,1,nil},nil,nil,nil},{5,nil,5,6,nil,nil,nil,7,8,{5,28800,1,4,nil,2,nil},nil,nil,4},{9,nil,9,10,nil,nil,nil,11,12,{1,7,1,nil,nil,3,nil},nil,nil,nil},{13,nil,13,14,nil,nil,nil,15,16,{2,3600,1,4,nil,4,nil},nil,nil,4},{17,nil,17,18,nil,nil,nil,19,20,{1,10,1,nil,nil,5,nil},nil,nil,nil},{22,nil,22,23,nil,0,0,24,25,{0,10,0.01,21,nil,6,nil},nil,nil,21},{26,nil,26,2,nil,nil,nil,2,27,{0,19,1,nil,nil,7,nil},nil,nil,nil},{28,nil,28,29,nil,nil,nil,29,30,{0,6,0.1,21,nil,8,nil},nil,nil,21},{31,nil,31,6,nil,nil,nil,7,32,{5,28800,1,4,nil,9,nil},nil,nil,4}},numeric)
custom_capabilities.enum=build({{33,33,34,34,35,nil,nil,33,36,{37,38,39},{37,38,39},10,11,10},{40,nil,40,41,nil,nil,nil,41,42,{43,44},{43,44},12,13,12},{45,nil,45,34,nil,nil,nil,33,46,{37,38,39},{37,38,39},14,15,14},{47,nil,47,48,nil,nil,nil,49,50,{37,51,52,53,54,55,56},{37,51,52,53,54,55,56},16,17,16},{57,nil,57,58,nil,nil,nil,59,60,{37,51,52,53,54,55,56},{37,51,52,53,54,55,56},18,19,18},{61,nil,61,2,nil,nil,nil,2,62,{63,64,65,66},{63,64,65,66},20,21,20},{67,nil,67,68,nil,nil,nil,69,70,{51,71,72},{51,71,72},22,23,22},{73,nil,73,74,nil,nil,nil,74,75,{43,44},{43,44},24,25,24},{76,nil,76,77,nil,nil,nil,77,78,{43,44},{43,44},26,27,26},{79,nil,79,80,nil,nil,nil,81,82,{43,44},{43,44},28,29,28},{83,nil,83,41,nil,nil,nil,41,84,{43,44},{43,44},30,31,30},{85,nil,85,34,nil,nil,nil,33,86,{37,38,39},{37,38,39},32,33,32},{87,nil,87,48,nil,nil,nil,49,88,{37,51,89,52,53,90,91,92},{37,51,89,52,53,90,91,92},34,35,34},{93,nil,93,58,nil,nil,nil,59,94,{37,51,89,52,53,90,91,92},{37,51,89,52,53,90,91,92},36,37,36},{95,nil,95,96,nil,nil,nil,97,98,{89,52,53},{89,52,53},38,39,38}},enum)
custom_capabilities.text=build({{99,100,100,0,0,nil,101,64}},text)
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
