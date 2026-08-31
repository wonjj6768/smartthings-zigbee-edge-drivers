local custom_capabilities={}
local strings={"C","th05zMaxTempAlarm","maximumTemperatureAlarm","max_temperature_alarm","Th05z Max Temp Alarm","th05zMinTempAlarm","minimumTemperatureAlarm","min_temperature_alarm","Th05z Min Temp Alarm","%","th05zMaxHumidityAlarm","maximumHumidityAlarm","max_humidity_alarm","Th05z Max Humidity Alarm","th05zMinHumidityAlarm","minimumHumidityAlarm","min_humidity_alarm","Th05z Min Humidity Alarm","min","th05zTempReportPeriod","temperatureReportPeriod","temperature_report_interval","Th05z Temp Report Period","th05zTempSensitivity","temperatureSensitivity","temperature_sensitivity","Th05z Temp Sensitivity","th05zHumiditySensitivity","humiditySensitivity","humidity_sensitivity","Th05z Humidity Sensitivity","th05zTempCalibration","temperatureCalibration","temperature_calibration","Th05z Temp Calibration","th05zHumidityCalibration","humidityCalibration","humidity_calibration","Th05z Humidity Calibration","s","airprsOneSamplingInterval","samplingInterval","airprs_one_sampling_interval","Airprs One Sampling Interval","lux","airprsOneIlluminanceVZero","illuminanceVZero","airprs_one_illuminance_v_zero","Airprs One Illuminance VZero","airprsOneIlluminanceVOne","illuminanceVOne","airprs_one_illuminance_v_one","Airprs One Illuminance VOne","airprsOneIlluminanceCalibration","illuminanceCalibration","airprs_one_illuminance_calibration","Airprs One Illuminance Calibration","Volt","airprsOneUv","uv","airprs_one_uv","Airprs One Uv","airprsOneUvLevel","uvLevel","airprs_one_uv_level","Airprs One Uv Level","airprsOneUvCalibration","uvCalibration","airprs_one_uv_calibration","Airprs One Uv Calibration","°C","airprsOneTemperatureCalibration","airprs_one_temperature_calibration","Airprs One Temperature Calibration","airprsOneTemperatureVZero","temperatureVZero","airprs_one_temperature_v_zero","Airprs One Temperature VZero","airprsOneTemperatureVOne","temperatureVOne","airprs_one_temperature_v_one","Airprs One Temperature VOne","hPa","airprsOnePressureCalibration","pressureCalibration","airprs_one_pressure_calibration","Airprs One Pressure Calibration","airprsOnePressureVZero","pressureVZero","airprs_one_pressure_v_zero","Airprs One Pressure VZero","airprsOnePressureVOne","pressureVOne","airprs_one_pressure_v_one","Airprs One Pressure VOne","ezFlProbeTemperature","probeTemperature","ez_fl_probe_temperature","Ez Fl Probe Temperature","ezFlSamplingInterval","ez_fl_sampling_interval","Ez Fl Sampling Interval","ezFlProbeTemperatureCalibration","probeTemperatureCalibration","ez_fl_probe_temperature_calibration","Ez Fl Probe Temperature Calibration","ezFlProbeTemperatureVZero","probeTemperatureVZero","ez_fl_probe_temperature_v_zero","Ez Fl Probe Temperature VZero","ezFlProbeTemperatureVOne","probeTemperatureVOne","ez_fl_probe_temperature_v_one","Ez Fl Probe Temperature VOne","ezFlTemperatureCalibration","ez_fl_temperature_calibration","Ez Fl Temperature Calibration","ezFlTemperatureVZero","ez_fl_temperature_v_zero","Ez Fl Temperature VZero","ezFlTemperatureVOne","ez_fl_temperature_v_one","Ez Fl Temperature VOne","ezFlHumidityCalibration","ez_fl_humidity_calibration","Ez Fl Humidity Calibration","ezFlHumidityVZero","humidityVZero","ez_fl_humidity_v_zero","Ez Fl Humidity VZero","ezFlHumidityVOne","humidityVOne","ez_fl_humidity_v_one","Ez Fl Humidity VOne","μS/cm","ezFlFertility","fertility","ez_fl_fertility","Ez Fl Fertility","ezFlFertilityVZero","fertilityVZero","ez_fl_fertility_v_zero","Ez Fl Fertility VZero","ezFlFertilityVOne","fertilityVOne","ez_fl_fertility_v_one","Ez Fl Fertility VOne","ezFlFertilityCalibration","fertilityCalibration","ez_fl_fertility_calibration","Ez Fl Fertility Calibration","ezFlMoisture","moisture","ez_fl_moisture","Ez Fl Moisture","ezFlMoistureVZero","moistureVZero","ez_fl_moisture_v_zero","Ez Fl Moisture VZero","ezFlMoistureVOne","moistureVOne","ez_fl_moisture_v_one","Ez Fl Moisture VOne","ezFlMoistureCalibration","moistureCalibration","ez_fl_moisture_calibration","Ez Fl Moisture Calibration","ezFsProbeTemperature","ez_fs_probe_temperature","Ez Fs Probe Temperature","ezFsSamplingInterval","ez_fs_sampling_interval","Ez Fs Sampling Interval","ezFsProbeTemperatureCalibration","ez_fs_probe_temperature_calibration","Ez Fs Probe Temperature Calibration","ezFsProbeTemperatureVZero","ez_fs_probe_temperature_v_zero","Ez Fs Probe Temperature VZero","ezFsProbeTemperatureVOne","ez_fs_probe_temperature_v_one","Ez Fs Probe Temperature VOne","ezFsTemperatureCalibration","ez_fs_temperature_calibration","Ez Fs Temperature Calibration","ezFsTemperatureVZero","ez_fs_temperature_v_zero","Ez Fs Temperature VZero","ezFsTemperatureVOne","ez_fs_temperature_v_one","Ez Fs Temperature VOne","ezFsHumidityCalibration","ez_fs_humidity_calibration","Ez Fs Humidity Calibration","ezFsHumidityVZero","ez_fs_humidity_v_zero","Ez Fs Humidity VZero","ezFsHumidityVOne","ez_fs_humidity_v_one","Ez Fs Humidity VOne","ezFsMoisture","ez_fs_moisture","Ez Fs Moisture","ezFsMoistureVZero","ez_fs_moisture_v_zero","Ez Fs Moisture VZero","ezFsMoistureVOne","ez_fs_moisture_v_one","Ez Fs Moisture VOne","ezFsMoistureCalibration","ez_fs_moisture_calibration","Ez Fs Moisture Calibration","ppm","eZeroTwoCCoTwoAlarmValue","coTwoAlarmValue","e_zero_two_c_co_two_alarm_value","E Zero Two CCo Two Alarm Value","ezcZeroFourCoTwoAlarmValue","ezc_zero_four_co_two_alarm_value","Ezc Zero Four Co Two Alarm Value","ezcpZeroFourCoTwoAlarmValue","ezcp_zero_four_co_two_alarm_value","Ezcp Zero Four Co Two Alarm Value","ug/m3","ezcpZeroFourPm25AlarmValue","pmTwoFiveAlarmValue","ezcp_zero_four_pm_two_five_alarm_value","Ezcp Zero Four Pm25Alarm Value","th05zTemperatureUnit","temperatureUnit","temperature_unit","Th05z Temperature Unit","celsius","fahrenheit","th05zTemperatureAlarm","temperatureAlarm","temperature_alarm","Th05z Temperature Alarm","lower_alarm","upper_alarm","cancel","th05zHumidityAlarm","humidityAlarm","humidity_alarm","Th05z Humidity Alarm","airprsOneIlluminanceWarning","illuminanceWarning","airprs_one_illuminance_warning","Airprs One Illuminance Warning","none","low","high","airprsOneUvWarning","uvWarning","airprs_one_uv_warning","Airprs One Uv Warning","Low","Moderate","High","Very High","Extreme","airprsOneTemperatureWarning","temperatureWarning","airprs_one_temperature_warning","Airprs One Temperature Warning","airprsOnePressureWarning","pressureWarning","airprs_one_pressure_warning","Airprs One Pressure Warning","airprsOnePressureTrend","pressureTrend","airprs_one_pressure_trend","Airprs One Pressure Trend","normal","rise","fall","ezFlProbeTemperatureWarning","probeTemperatureWarning","ez_fl_probe_temperature_warning","Ez Fl Probe Temperature Warning","ezFlTemperatureWarning","ez_fl_temperature_warning","Ez Fl Temperature Warning","ezFlHumidityWarning","humidityWarning","ez_fl_humidity_warning","Ez Fl Humidity Warning","ezFlFertilityWarning","fertilityWarning","ez_fl_fertility_warning","Ez Fl Fertility Warning","ezFlMoistureWarning","moistureWarning","ez_fl_moisture_warning","Ez Fl Moisture Warning","ezFsProbeTemperatureWarning","ez_fs_probe_temperature_warning","Ez Fs Probe Temperature Warning","ezFsTemperatureWarning","ez_fs_temperature_warning","Ez Fs Temperature Warning","ezFsHumidityWarning","ez_fs_humidity_warning","Ez Fs Humidity Warning","ezFsMoistureWarning","ez_fs_moisture_warning","Ez Fs Moisture Warning","eZeroTwoCTemperatureUnit","e_zero_two_c_temperature_unit","E Zero Two CTemperature Unit","eZeroTwoCAlarmSwitch","alarmSwitch","e_zero_two_c_alarm_switch","E Zero Two CAlarm Switch","ON","OFF","eZeroTwoCChargeStatus","chargeStatus","e_zero_two_c_charge_status","E Zero Two CCharge Status","charging","eZeroTwoCResetCoTwo","resetCoTwo","e_zero_two_c_reset_co_two","E Zero Two CReset Co Two","reset_co2","eZeroTwoCScreenSleep","screenSleep","e_zero_two_c_screen_sleep","E Zero Two CScreen Sleep","after_30s","after_1minute","after_2minutes","after_5minutes","after_10minutes","never_sleep","eZeroTwoCCoTwoAlarm","coTwoAlarm","e_zero_two_c_co_two_alarm","E Zero Two CCo Two Alarm","ezcZeroFourCoTwoState","coTwoState","ezc_zero_four_co_two_state","Ezc Zero Four Co Two State","alarm","ezcZeroFourAlarmRingtone","alarmRingtone","ezc_zero_four_alarm_ringtone","Ezc Zero Four Alarm Ringtone","ringtone_0","ringtone_1","ringtone_2","ringtone_3","ezcZeroFourTemperatureUnit","ezc_zero_four_temperature_unit","Ezc Zero Four Temperature Unit","ezcZeroFourResetCoTwo","ezc_zero_four_reset_co_two","Ezc Zero Four Reset Co Two","ezcpZeroFourAlarmState","alarmState","ezcp_zero_four_alarm_state","Ezcp Zero Four Alarm State","alarm_co2","alarm_pm25","ezcpZeroFourAlarmRingtone","ezcp_zero_four_alarm_ringtone","Ezcp Zero Four Alarm Ringtone","mute","ezcpZeroFourTemperatureUnit","ezcp_zero_four_temperature_unit","Ezcp Zero Four Temperature Unit","last_power_response_time","lastPowerResponseTime","Last power response time"}
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
custom_capabilities.numeric=build({{2,nil,2,3,nil,nil,nil,4,5,{-20,60,0.1,1,nil,1,nil},nil,nil,1},{6,nil,6,7,nil,nil,nil,8,9,{-20,60,0.1,1,nil,2,nil},nil,nil,1},{11,nil,11,12,nil,nil,nil,13,14,{0,100,1,10,nil,3,nil},nil,nil,10},{15,nil,15,16,nil,nil,nil,17,18,{0,100,1,10,nil,4,nil},nil,nil,10},{20,nil,20,21,nil,nil,nil,22,23,{1,120,1,19,nil,5,nil},nil,nil,19},{24,nil,24,25,nil,nil,nil,26,27,{0.6,2,0.1,1,nil,6,nil},nil,nil,1},{28,nil,28,29,nil,nil,nil,30,31,{6,20,1,10,nil,7,nil},nil,nil,10},{32,nil,32,33,nil,nil,nil,34,35,{-2,2,0.1,1,nil,8,nil},nil,nil,1},{36,nil,36,37,nil,nil,nil,38,39,{-20,20,1,10,nil,9,nil},nil,nil,10},{41,nil,41,42,nil,nil,nil,43,44,{5,1200,5,40,nil,10,nil},nil,nil,40},{46,nil,46,47,nil,nil,nil,48,49,{0,10000,1,45,nil,11,nil},nil,nil,45},{50,nil,50,51,nil,nil,nil,52,53,{0,10000,1,45,nil,12,nil},nil,nil,45},{54,nil,54,55,nil,nil,nil,56,57,{-1000,1000,1,45,nil,13,nil},nil,nil,45},{59,nil,59,60,nil,0,0,61,62,{0,3300,nil,58,nil,14,nil},nil,nil,58},{63,nil,63,64,nil,0,0,65,66,{0,15,0.1,nil,nil,15,nil},nil,nil,nil},{67,nil,67,68,nil,nil,nil,69,70,{-1,1,0.1,nil,nil,16,nil},nil,nil,nil},{72,nil,72,33,nil,nil,nil,73,74,{-2,2,0.01,71,nil,17,nil},nil,nil,71},{75,nil,75,76,nil,nil,nil,77,78,{-40,85,0.01,71,nil,18,nil},nil,nil,71},{79,nil,79,80,nil,nil,nil,81,82,{-40,85,0.01,71,nil,19,nil},nil,nil,71},{84,nil,84,85,nil,nil,nil,86,87,{-10,10,0.01,83,nil,20,nil},nil,nil,83},{88,nil,88,89,nil,nil,nil,90,91,{300,1100,0.01,83,nil,21,nil},nil,nil,83},{92,nil,92,93,nil,nil,nil,94,95,{300,1100,0.01,83,nil,22,nil},nil,nil,83},{96,nil,96,97,nil,0,0,98,99,{-40,120,0.1,71,nil,23,nil},nil,nil,71},{100,nil,100,42,nil,nil,nil,101,102,{5,1200,5,40,nil,24,nil},nil,nil,40},{103,nil,103,104,nil,nil,nil,105,106,{-2,2,0.1,71,nil,25,nil},nil,nil,71},{107,nil,107,108,nil,nil,nil,109,110,{-40,125,0.1,71,nil,26,nil},nil,nil,71},{111,nil,111,112,nil,nil,nil,113,114,{-40,125,0.1,71,nil,27,nil},nil,nil,71},{115,nil,115,33,nil,nil,nil,116,117,{-2,2,0.01,71,nil,28,nil},nil,nil,71},{118,nil,118,76,nil,nil,nil,119,120,{-40,85,0.01,71,nil,29,nil},nil,nil,71},{121,nil,121,80,nil,nil,nil,122,123,{-40,85,0.01,71,nil,30,nil},nil,nil,71},{124,nil,124,37,nil,nil,nil,125,126,{-10,10,0.01,10,nil,31,nil},nil,nil,10},{127,nil,127,128,nil,nil,nil,129,130,{0,100,0.01,10,nil,32,nil},nil,nil,10},{131,nil,131,132,nil,nil,nil,133,134,{0,100,0.01,10,nil,33,nil},nil,nil,10},{136,nil,136,137,nil,0,0,138,139,{0,5000,1,135,nil,34,nil},nil,nil,135},{140,nil,140,141,nil,nil,nil,142,143,{0,5000,1,135,nil,35,nil},nil,nil,135},{144,nil,144,145,nil,nil,nil,146,147,{0,5000,1,135,nil,36,nil},nil,nil,135},{148,nil,148,149,nil,nil,nil,150,151,{0.5,2,0.01,nil,nil,37,nil},nil,nil,nil},{152,nil,152,153,nil,0,0,154,155,{0,100,1,10,nil,38,nil},nil,nil,10},{156,nil,156,157,nil,nil,nil,158,159,{0,100,1,10,nil,39,nil},nil,nil,10},{160,nil,160,161,nil,nil,nil,162,163,{0,100,1,10,nil,40,nil},nil,nil,10},{164,nil,164,165,nil,nil,nil,166,167,{0.2,1.5,0.01,nil,nil,41,nil},nil,nil,nil},{168,nil,168,97,nil,0,0,169,170,{-40,120,0.1,71,nil,42,nil},nil,nil,71},{171,nil,171,42,nil,nil,nil,172,173,{5,1200,5,40,nil,43,nil},nil,nil,40},{174,nil,174,104,nil,nil,nil,175,176,{-2,2,0.1,71,nil,44,nil},nil,nil,71},{177,nil,177,108,nil,nil,nil,178,179,{-40,125,0.1,71,nil,45,nil},nil,nil,71},{180,nil,180,112,nil,nil,nil,181,182,{-40,125,0.1,71,nil,46,nil},nil,nil,71},{183,nil,183,33,nil,nil,nil,184,185,{-2,2,0.01,71,nil,47,nil},nil,nil,71},{186,nil,186,76,nil,nil,nil,187,188,{-40,85,0.01,71,nil,48,nil},nil,nil,71},{189,nil,189,80,nil,nil,nil,190,191,{-40,85,0.01,71,nil,49,nil},nil,nil,71},{192,nil,192,37,nil,nil,nil,193,194,{-10,10,0.01,10,nil,50,nil},nil,nil,10},{195,nil,195,128,nil,nil,nil,196,197,{0,100,0.01,10,nil,51,nil},nil,nil,10},{198,nil,198,132,nil,nil,nil,199,200,{0,100,0.01,10,nil,52,nil},nil,nil,10},{201,nil,201,153,nil,0,0,202,203,{0,100,1,10,nil,53,nil},nil,nil,10},{204,nil,204,157,nil,nil,nil,205,206,{0,100,1,10,nil,54,nil},nil,nil,10},{207,nil,207,161,nil,nil,nil,208,209,{0,100,1,10,nil,55,nil},nil,nil,10},{210,nil,210,165,nil,nil,nil,211,212,{0.2,1.5,0.01,nil,nil,56,nil},nil,nil,nil},{214,nil,214,215,nil,nil,nil,216,217,{1000,10000,100,213,nil,57,nil},nil,nil,213},{218,nil,218,215,nil,nil,nil,219,220,{1000,10000,100,213,nil,58,nil},nil,nil,213},{221,nil,221,215,nil,nil,nil,222,223,{1000,10000,100,213,nil,59,nil},nil,nil,213},{225,nil,225,226,nil,nil,nil,227,228,{10,1000,10,224,nil,60,nil},nil,nil,224}},numeric)
custom_capabilities.enum=build({{229,nil,229,230,nil,nil,nil,231,232,{233,234},{233,234},61,62,61},{235,nil,235,236,nil,0,0,237,238,{239,240,241},{239,240,241},63,64,63},{242,nil,242,243,nil,0,0,244,245,{239,240,241},{239,240,241},65,66,65},{246,nil,246,247,nil,0,0,248,249,{250,251,252},{250,251,252},67,68,67},{253,nil,253,254,nil,0,0,255,256,{257,258,259,260,261},{257,258,259,260,261},69,70,69},{262,nil,262,263,nil,0,0,264,265,{250,251,252},{250,251,252},71,72,71},{266,nil,266,267,nil,0,0,268,269,{250,251,252},{250,251,252},73,74,73},{270,nil,270,271,nil,0,0,272,273,{274,275,276},{274,275,276},75,76,75},{277,nil,277,278,nil,0,0,279,280,{250,251,252},{250,251,252},77,78,77},{281,nil,281,263,nil,0,0,282,283,{250,251,252},{250,251,252},79,80,79},{284,nil,284,285,nil,0,0,286,287,{250,251,252},{250,251,252},81,82,81},{288,nil,288,289,nil,0,0,290,291,{250,251,252},{250,251,252},83,84,83},{292,nil,292,293,nil,0,0,294,295,{250,251,252},{250,251,252},85,86,85},{296,nil,296,278,nil,0,0,297,298,{250,251,252},{250,251,252},87,88,87},{299,nil,299,263,nil,0,0,300,301,{250,251,252},{250,251,252},89,90,89},{302,nil,302,285,nil,0,0,303,304,{250,251,252},{250,251,252},91,92,91},{305,nil,305,293,nil,0,0,306,307,{250,251,252},{250,251,252},93,94,93},{308,nil,308,230,nil,nil,nil,309,310,{233,234},{233,234},95,96,95},{311,nil,311,312,nil,nil,nil,313,314,{315,316},{315,316},97,98,97},{317,nil,317,318,nil,0,0,319,320,{250,321},{250,321},99,100,99},{322,nil,322,323,nil,nil,nil,324,325,{326},{326},101,102,101},{327,nil,327,328,nil,nil,nil,329,330,{331,332,333,334,335,336},{331,332,333,334,335,336},103,104,103},{337,nil,337,338,nil,0,0,339,340,{315,316},{315,316},105,106,105},{341,nil,341,342,nil,0,0,343,344,{345,274},{345,274},107,108,107},{346,nil,346,347,nil,nil,nil,348,349,{350,351,352,353},{350,351,352,353},109,110,109},{354,nil,354,230,nil,nil,nil,355,356,{233,234},{233,234},111,112,111},{357,nil,357,323,nil,nil,nil,358,359,{326},{326},113,114,113},{360,nil,360,361,nil,0,0,362,363,{274,364,365},{274,364,365},115,116,115},{366,nil,366,347,nil,nil,nil,367,368,{369,351,352,353},{369,351,352,353},117,118,117},{370,nil,370,230,nil,nil,nil,371,372,{233,234},{233,234},119,120,119}},enum)
custom_capabilities.text=build({{373,374,374,0,0,nil,375,64}},text)
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
