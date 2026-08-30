local custom_capabilities={}
local strings={"s","rjvxCountdown","countdown","Rjvx Countdown","C","rjvxTempCSetpoint","temperatureCelsiusSetpoint","temperature_celsius_setpoint","Rjvx Temp CSetpoint","F","rjvxTempFSetpoint","temperatureFahrenheitSetpoint","temperature_fahrenheit_setpoint","Rjvx Temp FSetpoint","rjvxTemperatureF","temperatureFahrenheit","temperature_fahrenheit","Rjvx Temperature F","rjvxTemperatureRange","temperatureRange","temperature_range","Rjvx Temperature Range","rjvxTempCalibration","temperatureCalibration","temperature_calibration","Rjvx Temp Calibration","min","rjvxCoolingDelay","coolingDelay","cooling_delay","Rjvx Cooling Delay","apiuCountdown","Apiu Countdown","kWh","usb4gProducedEnergy","producedEnergy","produced_energy","Usb4g Produced Energy","mgzgCountdown1","countdownOne","countdown_one","Mgzg Countdown1","usb4gCountdownUsba","Usb4g Countdown Usba","usb4gCountdownUsbc","countdownTwo","countdown_two","Usb4g Countdown Usbc","usb4gCountdownPlugOne","countdownThree","countdown_three","Usb4g Countdown Plug One","usb4gCountdownPlugTwo","countdownFour","countdown_four","Usb4g Countdown Plug Two","scimagicTempTarget","temperatureTarget","temperature_target","Scimagic Temp Target","scimagicTempRange","Scimagic Temp Range","scimagicTempCalibration","Scimagic Temp Calibration","scimagicDelayTime","delayTime","delay_time","Scimagic Delay Time","%","scimagicHumidityTarget","humidityTarget","humidity_target","Scimagic Humidity Target","scimagicHumidityRange","humidityRange","humidity_range","Scimagic Humidity Range","scimagicHumidityCalibration","humidityCalibration","humidity_calibration","Scimagic Humidity Calibration","power_on_behavior","powerOnBehavior","supportedPowerOnBehaviors","Power on behavior","off","on","previous","rjvxAutowork","autowork","Rjvx Autowork","rjvxWorkMode","workMode","work_mode","Rjvx Work Mode","heating","cooling","rjvxTemperatureUnit","temperatureUnit","temperature_unit","Rjvx Temperature Unit","celsius","fahrenheit","rjvxCoolingDelaySwitch","coolingDelaySwitch","cooling_delay_switch","Rjvx Cooling Delay Switch","usb4gRelayStatus","relayStatus","relay_status","Usb4g Relay Status","usb4gBacklight","backlightSwitch","backlight_switch","Usb4g Backlight","usb4gChildLock","childLock","child_lock","Usb4g Child Lock","mgzgPowerOnBehavior","Mgzg Power On Behavior","mgzgBacklightMode","backlightMode","backlight_mode","Mgzg Backlight Mode","scimagicMode","mode","Scimagic Mode","dehumidify","wet","scimagicAutoWork","autoWork","auto_work","Scimagic Auto Work","scimagicDelay","delay","Scimagic Delay","last_power_response_time","lastPowerResponseTime","Last power response time"}
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
custom_capabilities.numeric=build({{2,nil,2,3,nil,nil,nil,3,4,{0,86400,1,1,nil,1,nil},nil,nil,1},{6,nil,6,7,nil,nil,nil,8,9,{-20,102,0.5,5,nil,2,nil},nil,nil,5},{11,nil,11,12,nil,nil,nil,13,14,{-4,221,0.5,10,nil,3,nil},nil,nil,10},{15,nil,15,16,nil,0,0,17,18,{-4,221,0.1,10,nil,4,nil},nil,nil,10},{19,nil,19,20,nil,nil,nil,21,22,{1,9,0.5,5,nil,5,nil},nil,nil,5},{23,nil,23,24,nil,nil,nil,25,26,{-9,9,1,10,nil,6,nil},nil,nil,10},{28,nil,28,29,nil,nil,nil,30,31,{0,10,1,27,nil,7,nil},nil,nil,27},{32,nil,32,3,nil,nil,nil,3,33,{0,120,1,27,nil,8,nil},nil,nil,27},{35,nil,35,36,nil,nil,nil,37,38,{0,1000000,0.01,34,nil,9,nil},nil,nil,34},{39,nil,39,40,nil,nil,nil,41,42,{0,86400,1,1,nil,10,nil},nil,nil,1},{43,nil,43,40,nil,nil,nil,41,44,{0,86400,1,1,nil,11,nil},nil,nil,1},{45,nil,45,46,nil,nil,nil,47,48,{0,86400,1,1,nil,12,nil},nil,nil,1},{49,nil,49,50,nil,nil,nil,51,52,{0,86400,1,1,nil,13,nil},nil,nil,1},{53,nil,53,54,nil,nil,nil,55,56,{0,86400,1,1,nil,14,nil},nil,nil,1},{57,nil,57,58,nil,nil,nil,59,60,{-20,100,0.1,5,nil,15,nil},nil,nil,5},{61,nil,61,20,nil,nil,nil,21,62,{0,20,0.1,5,nil,16,nil},nil,nil,5},{63,nil,63,24,nil,nil,nil,25,64,{-10,10,0.5,5,nil,17,nil},nil,nil,5},{65,nil,65,66,nil,nil,nil,67,68,{0,1440,1,27,nil,18,nil},nil,nil,27},{70,nil,70,71,nil,nil,nil,72,73,{0,100,1,69,nil,19,nil},nil,nil,69},{74,nil,74,75,nil,nil,nil,76,77,{0,100,1,69,nil,20,nil},nil,nil,69},{78,nil,78,79,nil,nil,nil,80,81,{-30,30,1,69,nil,21,nil},nil,nil,69}},numeric)
custom_capabilities.enum=build({{82,82,83,83,84,nil,nil,82,85,{86,87,88},{86,87,88},22,23,22},{89,nil,89,90,nil,nil,nil,90,91,{86,87},{86,87},24,25,24},{92,nil,92,93,nil,nil,nil,94,95,{96,97},{96,97},26,27,26},{98,nil,98,99,nil,nil,nil,100,101,{102,103},{102,103},28,29,28},{104,nil,104,105,nil,nil,nil,106,107,{86,87},{86,87},30,31,30},{108,nil,108,109,nil,nil,nil,110,111,{86,87,88},{86,87,88},32,33,32},{112,nil,112,113,nil,nil,nil,114,115,{86,87},{86,87},34,35,34},{116,nil,116,117,nil,nil,nil,118,119,{86,87},{86,87},36,37,36},{120,nil,120,83,nil,nil,nil,82,121,{86,87,88},{86,87,88},38,39,38},{122,nil,122,123,nil,nil,nil,124,125,{86,87},{86,87},40,41,40},{126,nil,126,127,nil,nil,nil,127,128,{96,129,97,130},{96,129,97,130},42,43,42},{131,nil,131,132,nil,nil,nil,133,134,{86,87},{86,87},44,45,44},{135,nil,135,136,nil,nil,nil,136,137,{86,87},{86,87},46,47,46}},enum)
custom_capabilities.text=build({{138,139,139,0,0,nil,140,64}},text)
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
