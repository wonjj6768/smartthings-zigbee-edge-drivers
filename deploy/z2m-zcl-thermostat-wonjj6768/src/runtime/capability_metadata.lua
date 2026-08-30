local custom_capabilities={}
local strings={"°C","pirogovMideaOutdoorTemperature","outdoorTemperature","pirogov_midea_outdoor_temperature","Pirogov Midea Outdoor Temperature","C","sberThermLocalCalibration","localCalibration","sber_therm_local_calibration","Sber Therm Local Calibration","sberThermAbsMinHeatLimit","absMinHeatLimit","sber_therm_abs_min_heat_limit","Sber Therm Abs Min Heat Limit","sberThermAbsMaxHeatLimit","absMaxHeatLimit","sber_therm_abs_max_heat_limit","Sber Therm Abs Max Heat Limit","sberThermMinHeatLimit","minHeatLimit","sber_therm_min_heat_limit","Sber Therm Min Heat Limit","sberThermMaxHeatLimit","maxHeatLimit","sber_therm_max_heat_limit","Sber Therm Max Heat Limit","sberThermMinLocalTemperature","minLocalTemperature","sber_therm_min_local_temperature","Sber Therm Min Local Temperature","sberThermMaxLocalTemperature","maxLocalTemperature","sber_therm_max_local_temperature","Sber Therm Max Local Temperature","sberThermHeatingHysteresis","heatingHysteresis","sber_therm_heating_hysteresis","Sber Therm Heating Hysteresis","sberThermRemoteTemperature","remoteTemperature","sber_therm_remote_temperature","Sber Therm Remote Temperature","sberThermRemoteCalibration","remoteCalibration","sber_therm_remote_calibration","Sber Therm Remote Calibration","s","sberThermRemoteSensorTimeout","remoteSensorTimeout","sber_therm_remote_sensor_timeout","Sber Therm Remote Sensor Timeout","sberThermDeviceTemperature","deviceTemperature","sber_therm_device_temperature","Sber Therm Device Temperature","sberThermWiredTemperature","wiredTemperature","sber_therm_wired_temperature","Sber Therm Wired Temperature","mA","sberThermUpperCurrentThreshold","upperCurrentThreshold","sber_therm_upper_current_threshold","Sber Therm Upper Current Threshold","sberThermTemperatureThreshold","temperatureThreshold","sber_therm_temperature_threshold","Sber Therm Temperature Threshold","sberThermBrightnessOperations","brightnessOperations","sber_therm_brightness_operations","Sber Therm Brightness Operations","sberThermBrightnessSteady","brightnessSteady","sber_therm_brightness_steady","Sber Therm Brightness Steady","sberThermResetsCount","resetsCount","sber_therm_resets_count","Sber Therm Resets Count","sberThermUptime","uptime","sber_therm_uptime","Sber Therm Uptime","sberThermButtonClicksOne","buttonClicksOne","sber_therm_button_clicks_one","Sber Therm Button Clicks One","sberThermButtonClicksTwo","buttonClicksTwo","sber_therm_button_clicks_two","Sber Therm Button Clicks Two","sberThermButtonClicksThree","buttonClicksThree","sber_therm_button_clicks_three","Sber Therm Button Clicks Three","sberThermRelaySwitchesOne","relaySwitchesOne","sber_therm_relay_switches_one","Sber Therm Relay Switches One","pirogovMideaPower","power","pirogov_midea_power","Pirogov Midea Power","ON","OFF","pirogovMideaSystemMode","systemMode","pirogov_midea_system_mode","Pirogov Midea System Mode","off","auto","cool","heat","dry","fan_only","pirogovMideaFanMode","fanMode","pirogov_midea_fan_mode","Pirogov Midea Fan Mode","low","medium","high","quiet","pirogovMideaSwingMode","swingMode","pirogov_midea_swing_mode","Pirogov Midea Swing Mode","horizontal","vertical","both","pirogovMideaPreset","preset","pirogov_midea_preset","Pirogov Midea Preset","none","sleep","turbo","pirogovMideaDisplay","display","pirogov_midea_display","Pirogov Midea Display","sberThermEmergencyOvercurrent","emergencyOvercurrent","sber_therm_emergency_overcurrent","Sber Therm Emergency Overcurrent","clear","active","sberThermEmergencyOverheat","emergencyOverheat","sber_therm_emergency_overheat","Sber Therm Emergency Overheat","sberThermEmergencyNoLoad","emergencyNoLoad","sber_therm_emergency_no_load","Sber Therm Emergency No Load","sberThermRemoteDisconnected","sensorRemoteDisconnected","sber_therm_sensor_error_remote_disconnected","Sber Therm Remote Disconnected","sberThermSensorLocalDisconnected","sensorLocalDisconnected","sber_therm_sensor_error_local_disconnected","Sber Therm Sensor Local Disconnected","sberThermSensorShortCircuit","sensorShortCircuit","sber_therm_sensor_error_short_circuit","Sber Therm Sensor Short Circuit","sberThermHeatInefficient","heatInefficient","sber_therm_status_heat_inefficient","Sber Therm Heat Inefficient","sberThermAntifrost","antifrost","sber_therm_status_antifrost","Sber Therm Antifrost","sberThermInvalidTime","invalidTime","sber_therm_status_invalid_time","Sber Therm Invalid Time","sberThermKeypadLockout","keypadLockout","sber_therm_keypad_lockout","Sber Therm Keypad Lockout","unlock","lock1","sberThermControlSequence","controlSequence","sber_therm_control_sequence","Sber Therm Control Sequence","heating_only","sberThermRunningMode","runningMode","sber_therm_running_mode","Sber Therm Running Mode","sberThermProgrammingMode","programmingMode","sber_therm_programming_mode","Sber Therm Programming Mode","setpoint","schedule","sberThermSensorType","sensorType","sber_therm_sensor_type","Sber Therm Sensor Type","4p7K","6p8K","10K","12K","15K","33K","47K","sberThermSensorMode","sensorMode","sber_therm_sensor_mode","Sber Therm Sensor Mode","local","remote","sberThermOutputMode","outputMode","sber_therm_output_mode","Sber Therm Output Mode","normal","inverted","sberThermRtcUnavailable","rtcUnavailable","sber_therm_rtc_unavailable","Sber Therm Rtc Unavailable","sberThermRtcDataNotVaild","rtcDataNotVaild","sber_therm_rtc_data_not_vaild","Sber Therm Rtc Data Not Vaild","last_power_response_time","lastPowerResponseTime","Last power response time","pirogovMideaFirmwareVersion","firmwareVersion","pirogov_midea_firmware_version","Pirogov Midea Firmware Version","sberThermSundaySchedule","sundaySchedule","sber_therm_sunday_schedule","Sber Therm Sunday Schedule","sberThermMondaySchedule","mondaySchedule","sber_therm_monday_schedule","Sber Therm Monday Schedule","sberThermTuesdaySchedule","tuesdaySchedule","sber_therm_tuesday_schedule","Sber Therm Tuesday Schedule","sberThermWednesdaySchedule","wednesdaySchedule","sber_therm_wednesday_schedule","Sber Therm Wednesday Schedule","sberThermThursdaySchedule","thursdaySchedule","sber_therm_thursday_schedule","Sber Therm Thursday Schedule","sberThermFridaySchedule","fridaySchedule","sber_therm_friday_schedule","Sber Therm Friday Schedule","sberThermSaturdaySchedule","saturdaySchedule","sber_therm_saturday_schedule","Sber Therm Saturday Schedule","sberThermSerialNumber","serialNumber","sber_therm_serial_number","Sber Therm Serial Number"}
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
custom_capabilities.numeric=build({{2,nil,2,3,nil,0,0,4,5,{nil,nil,nil,1,nil,1,nil},nil,nil,1},{7,nil,7,8,nil,nil,nil,9,10,{-2.5,2.5,0.1,6,nil,2,nil},nil,nil,6},{11,nil,11,12,nil,0,0,13,14,{nil,nil,nil,6,nil,3,nil},nil,nil,6},{15,nil,15,16,nil,0,0,17,18,{nil,nil,nil,6,nil,4,nil},nil,nil,6},{19,nil,19,20,nil,nil,nil,21,22,{1,35,0.5,6,nil,5,nil},nil,nil,6},{23,nil,23,24,nil,nil,nil,25,26,{5,50,0.5,6,nil,6,nil},nil,nil,6},{27,nil,27,28,nil,nil,nil,29,30,{1,35,0.01,6,nil,7,nil},nil,nil,6},{31,nil,31,32,nil,nil,nil,33,34,{5,50,0.01,6,nil,8,nil},nil,nil,6},{35,nil,35,36,nil,nil,nil,37,38,{1,10,0.1,6,nil,9,nil},nil,nil,6},{39,nil,39,40,nil,nil,nil,41,42,{-273.15,327.67,0.01,6,nil,10,nil},nil,nil,6},{43,nil,43,44,nil,nil,nil,45,46,{-12.8,12.7,0.1,6,nil,11,nil},nil,nil,6},{48,nil,48,49,nil,nil,nil,50,51,{1,65535,1,47,nil,12,nil},nil,nil,47},{52,nil,52,53,nil,0,0,54,55,{nil,nil,nil,6,nil,13,nil},nil,nil,6},{56,nil,56,57,nil,0,0,58,59,{nil,nil,nil,6,nil,14,nil},nil,nil,6},{61,nil,61,62,nil,nil,nil,63,64,{100,16000,100,60,nil,15,nil},nil,nil,60},{65,nil,65,66,nil,nil,nil,67,68,{-200,200,1,6,nil,16,nil},nil,nil,6},{69,nil,69,70,nil,nil,nil,71,72,{0,1000,1,nil,nil,17,nil},nil,nil,nil},{73,nil,73,74,nil,nil,nil,75,76,{0,1000,1,nil,nil,18,nil},nil,nil,nil},{77,nil,77,78,nil,0,0,79,80,{nil,nil,nil,nil,nil,19,nil},nil,nil,nil},{81,nil,81,82,nil,0,0,83,84,{nil,nil,nil,47,nil,20,nil},nil,nil,47},{85,nil,85,86,nil,0,0,87,88,{nil,nil,nil,nil,nil,21,nil},nil,nil,nil},{89,nil,89,90,nil,0,0,91,92,{nil,nil,nil,nil,nil,22,nil},nil,nil,nil},{93,nil,93,94,nil,0,0,95,96,{nil,nil,nil,nil,nil,23,nil},nil,nil,nil},{97,nil,97,98,nil,0,0,99,100,{nil,nil,nil,nil,nil,24,nil},nil,nil,nil}},numeric)
custom_capabilities.enum=build({{101,nil,101,102,nil,nil,nil,103,104,{105,106},{105,106},25,26,25},{107,nil,107,108,nil,nil,nil,109,110,{111,112,113,114,115,116},{111,112,113,114,115,116},27,28,27},{117,nil,117,118,nil,nil,nil,119,120,{112,121,122,123,124},{112,121,122,123,124},29,30,29},{125,nil,125,126,nil,nil,nil,127,128,{111,129,130,131},{111,129,130,131},31,32,31},{132,nil,132,133,nil,nil,nil,134,135,{136,137,138},{136,137,138},33,34,33},{139,nil,139,140,nil,nil,nil,141,142,{105,106},{105,106},35,36,35},{143,nil,143,144,nil,0,0,145,146,{147,148},{147,148},37,38,37},{149,nil,149,150,nil,0,0,151,152,{147,148},{147,148},39,40,39},{153,nil,153,154,nil,0,0,155,156,{147,148},{147,148},41,42,41},{157,nil,157,158,nil,0,0,159,160,{147,148},{147,148},43,44,43},{161,nil,161,162,nil,0,0,163,164,{147,148},{147,148},45,46,45},{165,nil,165,166,nil,0,0,167,168,{147,148},{147,148},47,48,47},{169,nil,169,170,nil,0,0,171,172,{147,148},{147,148},49,50,49},{173,nil,173,174,nil,0,0,175,176,{147,148},{147,148},51,52,51},{177,nil,177,178,nil,0,0,179,180,{147,148},{147,148},53,54,53},{181,nil,181,182,nil,nil,nil,183,184,{185,186},{185,186},55,56,55},{187,nil,187,188,nil,nil,nil,189,190,{191},{191},57,58,57},{192,nil,192,193,nil,0,0,194,195,{111,114},{111,114},59,60,59},{196,nil,196,197,nil,nil,nil,198,199,{200,201},{200,201},61,62,61},{202,nil,202,203,nil,nil,nil,204,205,{206,207,208,209,210,211,212},{206,207,208,209,210,211,212},63,64,63},{213,nil,213,214,nil,nil,nil,215,216,{217,218,131},{217,218,131},65,66,65},{219,nil,219,220,nil,nil,nil,221,222,{223,224},{223,224},67,68,67},{225,nil,225,226,nil,0,0,227,228,{147,148},{147,148},69,70,69},{229,nil,229,230,nil,0,0,231,232,{147,148},{147,148},71,72,71}},enum)
custom_capabilities.text=build({{233,234,234,0,0,nil,235,64},{236,236,237,0,0,238,239,256},{240,240,241,nil,nil,242,243,512},{244,244,245,nil,nil,246,247,512},{248,248,249,nil,nil,250,251,512},{252,252,253,nil,nil,254,255,512},{256,256,257,nil,nil,258,259,512},{260,260,261,nil,nil,262,263,512},{264,264,265,nil,nil,266,267,512},{268,268,269,0,0,270,271,512}},text)
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
