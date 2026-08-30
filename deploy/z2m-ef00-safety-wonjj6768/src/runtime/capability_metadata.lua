local custom_capabilities={}
local strings={"min","neoAbSixAlarmTime","neo_ab_six_alarm_time","Neo Ab Six Alarm Time","s","neoAbTwoDuration","duration","neo_ab_two_duration","Neo Ab Two Duration","%LEL","eFourGasLevel","gasLevel","e_four_gas_level","E Four Gas Level","eFourMaxGasAlarm","maxGasAlarm","e_four_max_gas_alarm","E Four Max Gas Alarm","ppm","eFourMaxCoAlarm","maxCoAlarm","e_four_max_co_alarm","E Four Max Co Alarm","times","aZeroEightAlarmTime","alarmTime","a_zero_eight_alarm_time","A Zero Eight Alarm Time","nousE9WarmingUp","warmingUp","nous_e9_warming_up","Nous E9Warming Up","off","on","nousE9EndOfLife","endOfLife","nous_e9_end_of_life","Nous E9End Of Life","nousE13WaterLeakAlarm","waterLeakAlarm","nous_e13_water_leak_alarm","Nous E13Water Leak Alarm","clear","detected","nousE13AlarmMode","alarmMode","nous_e13_alarm_mode","Nous E13Alarm Mode","water_presence","water_absence","nousE13Ringtone","ringtone","nous_e13_ringtone","Nous E13Ringtone","muted","tone_1","tone_2","tone_3","lincukooSzw08AlarmStatus","alarmStatus","lincukoo_szw08_alarm_status","Lincukoo Szw08Alarm Status","normal","alarm","lincukooSzw08Mode","mode","lincukoo_szw08_mode","Lincukoo Szw08Mode","leakage","shortage","lincukooSzw08Ringtone","alarmRingtone","lincukoo_szw08_alarm_ringtone","Lincukoo Szw08Ringtone","mute","ring1","ring2","ring3","moesZcHmSelfTestResult","selfTestResult","moes_zc_hm_self_test_result","Moes Zc Hm Self Test Result","checking","success","failure","others","moesZcHmSilence","silence","moes_zc_hm_silence","Moes Zc Hm Silence","neoAbSixAlarmState","neo_ab_six_alarm_state","Neo Ab Six Alarm State","alarm_sound","alarm_light","alarm_sound_light","no_alarm","neoAbSixAlarmSwitch","neo_ab_six_alarm_switch","Neo Ab Six Alarm Switch","ON","OFF","neoAbSixTamperAlarmSwitch","neo_ab_six_tamper_alarm_switch","Neo Ab Six Tamper Alarm Switch","neoAbSixTamperAlarm","neo_ab_six_tamper_alarm","Neo Ab Six Tamper Alarm","neoAbSixAlarmMelody","neo_ab_six_alarm_melody","Neo Ab Six Alarm Melody","melody_1","melody_2","melody_3","neoAbSixAlarmMode","neo_ab_six_alarm_mode","Neo Ab Six Alarm Mode","neoAbSixCharging","neo_ab_six_charging","Neo Ab Six Charging","not_charging","charging","tuyaVibrationAlarmStatus","tuya_vibration_alarm_status","Tuya Vibration Alarm Status","tuyaVibrationSensitivity","sensitivity","tuya_vibration_sensitivity","Tuya Vibration Sensitivity","low","middle","high","tuyaVibrationBatteryState","batteryState","tuya_vibration_battery_state","Tuya Vibration Battery State","medium","tuyaVibrationDismissAlarm","dismissAlarm","tuya_vibration_dismiss_alarm","Tuya Vibration Dismiss Alarm","idle","DISMISS","tuyaVibrationSilentMode","silentMode","tuya_vibration_silent_mode","Tuya Vibration Silent Mode","neoAbTwoMelody","melody","neo_ab_two_melody","Neo Ab Two Melody","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","neoAbTwoVolume","volume","neo_ab_two_volume","Neo Ab Two Volume","lincukooWFourAlarmStatus","lincukoo_w_four_alarm_status","Lincukoo WFour Alarm Status","lincukooWFourAlarmSwitch","alarmSwitch","lincukoo_w_four_alarm_switch","Lincukoo WFour Alarm Switch","lincukooWFourBatteryState","lincukoo_w_four_battery_state","Lincukoo WFour Battery State","lincukooWFourRingtone","lincukoo_w_four_ringtone","Lincukoo WFour Ringtone","nousETwelveWarmingUp","nous_e_twelve_warming_up","Nous ETwelve Warming Up","nousETwelveTest","test","nous_e_twelve_test","Nous ETwelve Test","nousETwelveTesting","testing","nous_e_twelve_testing","Nous ETwelve Testing","nousETwelveEndOfLife","nous_e_twelve_end_of_life","Nous ETwelve End Of Life","nousETwelveBatteryState","nous_e_twelve_battery_state","Nous ETwelve Battery State","eFourSelfChecking","selfChecking","e_four_self_checking","E Four Self Checking","eFourCheckingResult","checkingResult","e_four_checking_result","E Four Checking Result","check_success","check_failure","aZeroEightAlarmState","alarmState","a_zero_eight_alarm_state","A Zero Eight Alarm State","aZeroEightAlarmVolume","alarmVolume","a_zero_eight_alarm_volume","A Zero Eight Alarm Volume","aZeroEightMute","a_zero_eight_mute","A Zero Eight Mute","aZeroEightAlarmRingtone","a_zero_eight_alarm_ringtone","A Zero Eight Alarm Ringtone","ringtone_1","ringtone_2","ringtone_3","ringtone_4","ringtone_5","ringtone_6","ringtone_7","ringtone_8","ringtone_9","ringtone_10","ringtone_11","ringtone_12","ringtone_13","ringtone_14","ringtone_15","ringtone_16","ringtone_17","ringtone_18","ringtone_19","ringtone_20","ringtone_21","ringtone_22","ringtone_23","ringtone_24","ringtone_25","ringtone_26","ringtone_27","last_power_response_time","lastPowerResponseTime","Last power response time"}
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
custom_capabilities.numeric=build({{2,nil,2,2,nil,nil,nil,3,4,{1,60,1,1,nil,1,nil},nil,nil,1},{6,nil,6,7,nil,nil,nil,8,9,{0,1800,1,5,nil,2,nil},nil,nil,5},{11,nil,11,12,nil,0,0,13,14,{0,20,nil,10,nil,3,nil},nil,nil,10},{15,nil,15,16,nil,nil,nil,17,18,{0.1,20,0.1,10,nil,4,nil},nil,nil,10},{20,nil,20,21,nil,nil,nil,22,23,{10,1000,10,19,nil,5,nil},nil,nil,19},{25,nil,25,26,nil,nil,nil,27,28,{0,100,1,24,nil,6,nil},nil,nil,24}},numeric)
custom_capabilities.enum=build({{29,nil,29,30,nil,0,0,31,32,{33,34},{33,34},7,8,7},{35,nil,35,36,nil,0,0,37,38,{33,34},{33,34},9,10,9},{39,nil,39,40,nil,0,0,41,42,{43,44},{43,44},11,12,11},{45,nil,45,46,nil,nil,nil,47,48,{49,50},{49,50},13,14,13},{51,nil,51,52,nil,nil,nil,53,54,{55,56,57,58},{55,56,57,58},15,16,15},{59,nil,59,60,nil,0,0,61,62,{63,64},{63,64},17,18,17},{65,nil,65,66,nil,nil,nil,67,68,{69,70},{69,70},19,20,19},{71,nil,71,72,nil,nil,nil,73,74,{75,76,77,78},{75,76,77,78},21,22,21},{79,nil,79,80,nil,0,0,81,82,{83,84,85,86},{83,84,85,86},23,24,23},{87,nil,87,88,nil,nil,nil,89,90,{33,34},{33,34},25,26,25},{91,nil,91,91,nil,0,0,92,93,{94,95,96,97},{94,95,96,97},27,28,27},{98,nil,98,98,nil,nil,nil,99,100,{101,102},{101,102},29,30,29},{103,nil,103,103,nil,nil,nil,104,105,{101,102},{101,102},31,32,31},{106,nil,106,106,nil,0,0,107,108,{101,102},{101,102},33,34,33},{109,nil,109,109,nil,nil,nil,110,111,{112,113,114},{112,113,114},35,36,35},{115,nil,115,115,nil,nil,nil,116,117,{94,95,96},{94,95,96},37,38,37},{118,nil,118,118,nil,0,0,119,120,{121,122},{121,122},39,40,39},{123,nil,123,60,nil,0,0,124,125,{63,64},{63,64},41,42,41},{126,nil,126,127,nil,nil,nil,128,129,{130,131,132},{130,131,132},43,44,43},{133,nil,133,134,nil,0,0,135,136,{130,137,132},{130,137,132},45,46,45},{138,nil,138,139,nil,nil,nil,140,141,{142,143},{142,143},47,48,47},{144,nil,144,145,nil,nil,nil,146,147,{102,101},{102,101},49,50,49},{148,nil,148,149,nil,nil,nil,150,151,{152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169},{152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169},51,52,51},{170,nil,170,171,nil,nil,nil,172,173,{130,137,132},{130,137,132},53,54,53},{174,nil,174,60,nil,0,0,175,176,{63,64},{63,64},55,56,55},{177,nil,177,178,nil,nil,nil,179,180,{75,64},{75,64},57,58,57},{181,nil,181,134,nil,0,0,182,183,{130,131,132},{130,131,132},59,60,59},{184,nil,184,52,nil,nil,nil,185,186,{76,77,78},{76,77,78},61,62,61},{187,nil,187,30,nil,0,0,188,189,{33,34},{33,34},63,64,63},{190,nil,190,191,nil,nil,nil,192,193,{142,191},{142,191},65,66,65},{194,nil,194,195,nil,0,0,196,197,{33,34},{33,34},67,68,67},{198,nil,198,36,nil,0,0,199,200,{33,34},{33,34},69,70,69},{201,nil,201,134,nil,0,0,202,203,{130,137,132},{130,137,132},71,72,71},{204,nil,204,205,nil,nil,nil,206,207,{101,102},{101,102},73,74,73},{208,nil,208,209,nil,0,0,210,211,{83,212,213,86},{83,212,213,86},75,76,75},{214,nil,214,215,nil,nil,nil,216,217,{94,95,96,63},{94,95,96,63},77,78,77},{218,nil,218,219,nil,nil,nil,220,221,{130,131,132,75},{130,131,132,75},79,80,79},{222,nil,222,75,nil,nil,nil,223,224,{101,102},{101,102},81,82,81},{225,nil,225,72,nil,nil,nil,226,227,{228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254},{228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254},83,84,83}},enum)
custom_capabilities.text=build({{255,256,256,0,0,nil,257,64}},text)
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
