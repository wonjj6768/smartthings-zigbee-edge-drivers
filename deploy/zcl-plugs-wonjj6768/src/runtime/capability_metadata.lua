local custom_capabilities={}
local strings={"s","power_poll_interval","powerPollIntervalV2","powerPollInterval","powerPollIntervalRange","Power poll interval","ts011fPlug1Countdown","countdown","ts011f_plug1_countdown","Ts011f Plug1Countdown","bacchusPumpDuration","pumpDuration","bacchus_pump_duration","Bacchus Pump Duration","nousA11zCountdown","nous_a11z_countdown","Nous A11z Countdown","countdownTimerZclTwelveHours","countdown_timer","Countdown Timer Zcl Twelve Hours","indicator_mode","indicatorMode","supportedIndicatorModes","Indicator mode","off","off/on","on/off","on","power_outage_memory","powerOutageMemory","supportedPowerOutageMemories","Power outage memory","restore","ts011fPlug1PowerOutageMemory","ts011f_plug1_power_outage_memory","Ts011f Plug1Power Outage Memory","ts011fPlug1IndicatorMode","ts011f_plug1_indicator_mode","Ts011f Plug1Indicator Mode","off_on","on_off","ts011fPlug1ChildLock","childLock","ts011f_plug1_child_lock","Ts011f Plug1Child Lock","ts011fPlug1SwitchTypeButton","switchTypeButton","ts011f_plug1_switch_type_button","Ts011f Plug1Switch Type Button","release","press","bacchusBeeperOnLeak","beeperOnLeak","bacchus_beeper_on_leak","Bacchus Beeper On Leak","bacchusTankFull","tankFull","bacchus_tank_full","Bacchus Tank Full","normal","full","nousA11zPowerBehavior","powerOnBehavior","nous_a11z_power_on_behavior","Nous A11z Power Behavior","previous","nousA11zIndicatorMode","nous_a11z_indicator_mode","Nous A11z Indicator Mode","nousA11zChildLock","nous_a11z_child_lock","Nous A11z Child Lock","nousA11zSwitchType","switchType","nous_a11z_switch_type","Nous A11z Switch Type","nousA11zIdentify","identify","nous_a11z_identify","Nous A11z Identify","child_lock","Child Lock","last_power_response_time","lastPowerResponseTime","Last power response time"}
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
custom_capabilities.numeric=build({{2,2,3,4,5,nil,nil,2,6,{5,3600,5,1,nil,1,nil},5,3600,1},{7,nil,7,8,nil,nil,nil,9,10,{0,43200,1,1,nil,2,nil},nil,nil,1},{11,nil,11,12,nil,nil,nil,13,14,{0,600,1,1,nil,3,nil},nil,nil,1},{15,nil,15,8,nil,nil,nil,16,17,{0,43200,1,1,nil,4,nil},nil,nil,1},{18,nil,18,18,nil,nil,nil,19,20,{0,43200,1,1,nil,5,nil},nil,nil,1}},numeric)
custom_capabilities.enum=build({{21,21,22,22,23,nil,nil,21,24,{25,26,27,28},{25,26,27,28},6,7,6},{29,29,30,30,31,nil,nil,29,32,{25,28,33},{25,28,33},8,9,8},{34,nil,34,30,nil,nil,nil,35,36,{25,28,33},{25,28,33},10,11,10},{37,nil,37,22,nil,nil,nil,38,39,{25,40,41,28},{25,40,41,28},12,13,12},{42,nil,42,43,nil,nil,nil,44,45,{25,28},{25,28},14,15,14},{46,nil,46,47,nil,nil,nil,48,49,{50,51},{50,51},16,17,16},{52,nil,52,53,nil,nil,nil,54,55,{25,28},{25,28},18,19,18},{56,nil,56,57,nil,0,0,58,59,{60,61},{60,61},20,21,20},{62,nil,62,63,nil,nil,nil,64,65,{25,28,66},{25,28,66},22,23,22},{67,nil,67,22,nil,nil,nil,68,69,{25,40,41,28},{25,40,41,28},24,25,24},{70,nil,70,43,nil,nil,nil,71,72,{25,28},{25,28},26,27,26},{73,nil,73,74,nil,nil,nil,75,76,{50,51},{50,51},28,29,28},{77,nil,77,78,nil,nil,nil,79,80,{78},{78},30,31,30},{43,nil,43,43,nil,nil,nil,81,82,{25,28},{25,28},32,33,32}},enum)
custom_capabilities.text=build({{83,84,84,0,0,nil,85,64}},text)
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
