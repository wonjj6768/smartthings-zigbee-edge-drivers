local custom_capabilities={}
local strings={"%","zmsFourBacklightBrightness","backlightBrightness","zms206_backlight_brightness","Zms Four Backlight Brightness","s","zmsFourCountdown","countdown","zms206_countdown","Zms Four Countdown","zmsFourBacklightSetting","backlightSetting","zms206_backlight_mode","Zms Four Backlight Setting","OFF","ON","zmsFourChildLock","childLock","zms206_child_lock","Zms Four Child Lock","off","on","zmsFourRadarConfig","radarConfig","zms206_radar_config","Zms Four Radar Config","none","10s","20s","30s","45s","60s","zmsFourSwitchColorOn","switchColorOn","zms206_switch_color_on","Zms Four Switch Color On","red","blue","green","white","yellow","magenta","cyan","warm_white","warm_yellow","zmsFourSwitchColorOff","switchColorOff","zms206_switch_color_off","Zms Four Switch Color Off","zmsFourIndicatorStatus","indicatorStatus","zms206_indicator_status","Zms Four Indicator Status","on_off_status","switch_position","zmsFourDelayOffColor","delayOffColor","zms206_delay_off_color","Zms Four Delay Off Color","zmsFourRelayStatus","relayStatus","zms206_relay_status","Zms Four Relay Status","power_on","power_off","restart_memory","last_power_response_time","lastPowerResponseTime","Last power response time","zmsFourSwitchName","switchName","zms206_switch_name","Zms Four Switch Name"}
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
custom_capabilities.numeric=build({{2,nil,2,3,nil,nil,nil,4,5,{0,100,1,1,nil,1,nil},nil,nil,1},{7,nil,7,8,nil,nil,nil,9,10,{0,43200,1,6,nil,2,nil},nil,nil,6}},numeric)
custom_capabilities.enum=build({{11,nil,11,12,nil,nil,nil,13,14,{15,16},{15,16},3,4,3},{17,nil,17,18,nil,nil,nil,19,20,{21,22},{21,22},5,6,5},{23,nil,23,24,nil,nil,nil,25,26,{27,28,29,30,31,32},{27,28,29,30,31,32},7,8,7},{33,nil,33,34,nil,nil,nil,35,36,{37,38,39,40,41,42,43,44,45},{37,38,39,40,41,42,43,44,45},9,10,9},{46,nil,46,47,nil,nil,nil,48,49,{37,38,39,40,41,42,43,44,45},{37,38,39,40,41,42,43,44,45},11,12,11},{50,nil,50,51,nil,nil,nil,52,53,{21,54,55},{21,54,55},13,14,13},{56,nil,56,57,nil,nil,nil,58,59,{37,38,39,40,41,42,43,44,45},{37,38,39,40,41,42,43,44,45},15,16,15},{60,nil,60,61,nil,nil,nil,62,63,{64,65,66},{64,65,66},17,18,17}},enum)
custom_capabilities.text=build({{67,68,68,0,0,nil,69,64},{70,70,71,nil,nil,72,73,12}},text)
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
