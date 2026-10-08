local custom_capabilities={}local strings={"s","power_poll_interval","powerPollIntervalV2","powerPollInterval","powerPollIntervalRange","Power poll interval","μg/m^3","heimanHs2aqPm10","pmTen","heiman_pmTen","Heiman Hs2aq Pm10","heimanHs2aqAqi","aqi","heiman_aqi","Heiman Hs2aq Aqi","C","thirdRths0324CelsiusCal","rthsZeroThreeTwoFourCelsiusCal","third_rths0324_celsius_calibration","Third Rths0324Celsius Cal","%","thirdRths0324HumidityCal","rthsZeroThreeTwoFourHumidityCal","third_rths0324_humidity_calibration","Third Rths0324Humidity Cal","F","thirdRths0324FahrenheitCal","rthsZeroThreeTwoFourFahrenheitCal","third_rths0324_fahrenheit_calibration","Third Rths0324Fahrenheit Cal","zg9032bTemperatureCompensation","zgNineZeroThreeTwoBTempComp","zg9032b_temperature_compensation","Zg9032b Temperature Compensation","zg9032bHumidityCompensation","zgNineZeroThreeTwoBHumidityComp","zg9032b_humidity_compensation","Zg9032b Humidity Compensation","°","ws90WindDirection","wsNinetyWindDirection","ws90_wind_direction","Ws90Wind Direction","mV","rbSrain01IlluminanceRaw","illuminanceRaw","illuminance_raw","Rb Srain01Illuminance Raw","rbSrain01IlluminanceAverage20min","illuminanceAverageTwentyMin","illuminance_average_20min","Rb Srain01Illuminance Average20min","rbSrain01IlluminanceMaximumToday","illuminanceMaximumToday","illuminance_maximum_today","Rb Srain01Illuminance Maximum Today","rbSrain01RainIntensity","rainIntensity","rain_intensity","Rb Srain01Rain Intensity","ecozyLocalTemperatureCalibration","localTemperatureCalibration","local_temperature_calibration","Ecozy Local Temperature Calibration","ecozyPiHeatingDemand","piHeatingDemand","pi_heating_demand","Ecozy Pi Heating Demand","miMotionRestarts","restartCount","mi_motion_restarts","Mi Motion Restarts","aqM11Restarts","aq_m_eleven_restarts","Aq M11Restarts","aqT1Restarts","aq_t_one_restarts","Aq T1Restarts","aqE1Restarts","aq_e_one_restarts","Aq E1Restarts","aqP1Interval","detectionInterval","aq_p_one_interval","Aq P1Interval","aqT1Interval","aq_t_one_interval","Aq T1Interval","aqE1Interval","aq_e_one_interval","Aq E1Interval","aqP1DeviceTemp","deviceTemperature","aq_p_one_device_temp","Aq P1Device Temp","aqT1DeviceTemp","aq_t_one_device_temp","Aq T1Device Temp","aqE1DeviceTemp","aq_e_one_device_temp","Aq E1Device Temp","aqM11DeviceTemp","aq_m_eleven_device_temp","Aq M11Device Temp","lczTempMax","temperatureMax","lcz_temp_max","Lcz Temp Max","lczTempMin","temperatureMin","lcz_temp_min","Lcz Temp Min","lczHumidityMax","humidityMax","lcz_humidity_max","Lcz Humidity Max","lczHumidityMin","humidityMin","lcz_humidity_min","Lcz Humidity Min","rpsSensitivity","sensitivity","rps_sensitivity","Rps Sensitivity","tsVibrationSensitivity","ts_vibration_sensitivity","Ts Vibration Sensitivity","min","candeoLightInterval","lightInterval","candeo_light_interval","Candeo Light Interval","t1HtDeviceTemperature","t1_ht_device_temperature","T1Ht Device Temperature","t1HtPowerOutageCount","powerOutageCount","t1_ht_power_outage_count","T1Ht Power Outage Count","m/s","shellyWs90WindSpeed","windSpeed","ws90_wind_speed","Shelly Ws90Wind Speed","shellyWs90GustSpeed","gustSpeed","ws90_gust_speed","Shelly Ws90Gust Speed","shellyWs90UvIndex","uvIndex","ws90_uv_index","Shelly Ws90Uv Index","mm","shellyWs90Precipitation","precipitation","ws90_precipitation","Shelly Ws90Precipitation","V","shellyWs90CapacitorVoltage","capacitorVoltage","ws90_capacitor_voltage","Shelly Ws90Capacitor Voltage","battery_low","batteryLow","Battery low","normal","low","zg9032bTemperatureDisplayUnit","zgNineZeroThreeTwoBDisplayUnit","zg9032b_temperature_display_unit","Zg9032b Temperature Display Unit","celsius","fahrenheit","ws90RainStatus","wsNinetyRainStatus","ws90_rain_status","Ws90Rain Status","dry","raining","c3007Pressure","cThreeZeroZeroSevenPressure","pressure","C3007Pressure","clear","detected","rbSrain01CleaningReminder","cleaningReminder","cleaning_reminder","Rb Srain01Cleaning Reminder","needsCleaning","heimanHs2aqBatteryState","batteryState","heiman_battery_state","Heiman Hs2aq Battery State","not_charging","charging","charged","ihRtOneSensitivity","ih_rt_one_sensitivity","Ih Rt One Sensitivity","medium","high","ihRtOneKeepTime","keepTime","ih_rt_one_keep_time","Ih Rt One Keep Time","30","60","120","ihRtTwoSensitivity","ih_rt_two_sensitivity","Ih Rt Two Sensitivity","ihRtTwoKeepTime","ih_rt_two_keep_time","Ih Rt Two Keep Time","zm35Sensitivity","zm35_sensitivity","Zm35Sensitivity","zm35KeepTime","zm35_keep_time","Zm35Keep Time","aqP1Sensitivity","aq_p_one_sensitivity","Aq P1Sensitivity","aqP1Indicator","indicator","aq_p_one_indicator","Aq P1Indicator","on","off","lczTempAlarm","temperatureAlarm","lcz_temp_alarm","Lcz Temp Alarm","below_min_temperature","over_temperature","lczHumidityAlarm","humidityAlarm","lcz_humidity_alarm","Lcz Humidity Alarm","below_min_humdity","over_humidity","kctwDisplayUnit","displayUnit","kctw_display_unit","Kctw Display Unit","rpsCalibration","calibration","rps_calibration","Rps Calibration","Press","candeoMotionSensitivity","candeo_motion_sensitivity","Candeo Motion Sensitivity","candeoMotionKeepTime","candeo_motion_keep_time","Candeo Motion Keep Time","10","cwamLightState","lightState","cwam_light_state","Cwam Light State","dark","bright","last_power_response_time","lastPowerResponseTime","Last power response time","remote_action","remoteAction","Remote action"}
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
local out={}table_groups[group_id]=out
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
local out=grouped_table(value[6])out.minimum=value[1]out.maximum=value[2]out.step=value[3]out.unit=string_value(value[4])out.allowed_values=string_list(value[5],value[7])return out
end
local function allowed_range(allowed_values,group_id)
if allowed_values==nil and group_id==nil then return nil end
local out=grouped_table(group_id)out.allowed_values=allowed_values
return out
end
local function numeric(row)
local attribute_name=string_value(row[4])return{kind="numeric",emit_name=string_value(row[1]),range_key=string_value(row[2]),capability_id=capability_id(row[3]),attribute_name=attribute_name,range_attribute_name=string_value(row[5]),command_name=optional_string(row[6],command_default(attribute_name)),argument_name=optional_string(row[7],attribute_name),mapping_name=string_value(row[8]),label=string_value(row[9]),default_range=range(row[10]),event_minimum=row[11],event_maximum=row[12],event_unit=string_value(row[13])}
end
local function enum(row)
local attribute_name=string_value(row[4])local supported_values=string_list(row[10],row[12])local default_allowed_values=string_list(row[11],row[14])local default_range=allowed_range(default_allowed_values,row[13])return{kind="enum",emit_name=string_value(row[1]),range_key=string_value(row[2]),capability_id=capability_id(row[3]),attribute_name=attribute_name,supported_attribute_name=string_value(row[5]),command_name=optional_string(row[6],command_default(attribute_name)),argument_name=optional_string(row[7],attribute_name),mapping_name=string_value(row[8]),label=string_value(row[9]),supported_values=supported_values,default_range=default_range}
end
local function text(row)
local attribute_name=string_value(row[3])return{kind="text",emit_name=string_value(row[1]),capability_id=capability_id(row[2]),attribute_name=attribute_name,command_name=optional_string(row[4],command_default(attribute_name)),argument_name=optional_string(row[5],attribute_name),mapping_name=string_value(row[6]),label=string_value(row[7]),maximum_length=row[8]}
end
local function build(rows,factory)
local out={}
for _,row in ipairs(rows)do out[#out+1]=factory(row)end
return out
end
custom_capabilities.numeric=build({{2,2,3,4,5,nil,nil,2,6,{5,3600,5,1,nil,1,nil},5,3600,1},{8,nil,8,9,nil,0,0,10,11,{0,65535,1,7,nil,2,nil},nil,nil,7},{12,nil,12,13,nil,0,0,14,15,{0,65535,1,nil,nil,3,nil},nil,nil,nil},{17,nil,17,18,nil,nil,nil,19,20,{-200,200,1,16,nil,4,nil},nil,nil,16},{22,nil,22,23,nil,nil,nil,24,25,{-100,100,1,21,nil,5,nil},nil,nil,21},{27,nil,27,28,nil,nil,nil,29,30,{-200,200,1,26,nil,6,nil},nil,nil,26},{31,nil,31,32,nil,nil,nil,33,34,{-5,5,1,16,nil,7,nil},nil,nil,16},{35,nil,35,36,nil,nil,nil,37,38,{-5,5,1,21,nil,8,nil},nil,nil,21},{40,nil,40,41,nil,0,0,42,43,{0,360,0.1,39,nil,9,nil},nil,nil,39},{45,nil,45,46,nil,0,0,47,48,{0,2147483647,1,44,nil,10,nil},nil,nil,44},{49,nil,49,50,nil,0,0,51,52,{0,2147483647,1,44,nil,11,nil},nil,nil,44},{53,nil,53,54,nil,0,0,55,56,{0,2147483647,1,44,nil,12,nil},nil,nil,44},{57,nil,57,58,nil,0,0,59,60,{0,2147483647,1,44,nil,13,nil},nil,nil,44},{61,nil,61,62,nil,nil,nil,63,64,{-2.5,2.5,0.1,16,nil,14,nil},nil,nil,16},{65,nil,65,66,nil,0,0,67,68,{0,100,1,21,nil,15,nil},nil,nil,21},{69,nil,69,70,nil,0,0,71,72,{nil,nil,nil,nil,nil,16,nil},nil,nil,nil},{73,nil,73,70,nil,0,0,74,75,{nil,nil,nil,nil,nil,17,nil},nil,nil,nil},{76,nil,76,70,nil,0,0,77,78,{nil,nil,nil,nil,nil,18,nil},nil,nil,nil},{79,nil,79,70,nil,0,0,80,81,{nil,nil,nil,nil,nil,19,nil},nil,nil,nil},{82,nil,82,83,nil,0,0,84,85,{2,65535,1,1,nil,20,nil},nil,nil,1},{86,nil,86,83,nil,0,0,87,88,{2,65535,1,1,nil,21,nil},nil,nil,1},{89,nil,89,83,nil,0,0,90,91,{2,65535,1,1,nil,22,nil},nil,nil,1},{92,nil,92,93,nil,0,0,94,95,{-128,127,1,16,nil,23,nil},nil,nil,16},{96,nil,96,93,nil,0,0,97,98,{-128,127,1,16,nil,24,nil},nil,nil,16},{99,nil,99,93,nil,0,0,100,101,{-128,127,1,16,nil,25,nil},nil,nil,16},{102,nil,102,93,nil,0,0,103,104,{-128,127,1,16,nil,26,nil},nil,nil,16},{105,nil,105,106,nil,nil,nil,107,108,{-20,80,1,16,nil,27,nil},nil,nil,16},{109,nil,109,110,nil,nil,nil,111,112,{-20,80,1,16,nil,28,nil},nil,nil,16},{113,nil,113,114,nil,nil,nil,115,116,{0,100,1,21,nil,29,nil},nil,nil,21},{117,nil,117,118,nil,nil,nil,119,120,{0,100,1,21,nil,30,nil},nil,nil,21},{121,nil,121,122,nil,nil,nil,123,124,{1,5,1,nil,nil,31,nil},nil,nil,nil},{125,nil,125,122,nil,nil,nil,126,127,{0,50,1,nil,nil,32,nil},nil,nil,nil},{129,nil,129,130,nil,nil,nil,131,132,{1,720,1,128,nil,33,nil},nil,nil,128},{133,nil,133,93,nil,0,0,134,135,{nil,nil,nil,16,nil,34,nil},nil,nil,16},{136,nil,136,137,nil,0,0,138,139,{nil,nil,nil,nil,nil,35,nil},nil,nil,nil},{141,nil,141,142,nil,0,0,143,144,{0,40,0.1,140,nil,36,nil},nil,nil,140},{145,nil,145,146,nil,0,0,147,148,{0,40,0.1,140,nil,37,nil},nil,nil,140},{149,nil,149,150,nil,0,0,151,152,{0,15,0.1,nil,nil,38,nil},nil,nil,nil},{154,nil,154,155,nil,0,0,156,157,{0,9999,0.1,153,nil,39,nil},nil,nil,153},{159,nil,159,160,nil,0,0,161,162,{nil,nil,nil,158,nil,40,nil},nil,nil,158}},numeric)custom_capabilities.enum=build({{163,163,164,164,nil,nil,nil,163,165,{166,167},{166,167},41,42,41},{168,nil,168,169,nil,nil,nil,170,171,{172,173},{172,173},43,44,43},{174,nil,174,175,nil,0,0,176,177,{178,179},{178,179},45,46,45},{180,nil,180,181,nil,0,0,182,183,{184,185},{184,185},47,48,47},{186,nil,186,187,nil,0,0,188,189,{184,190},{184,190},49,50,49},{191,nil,191,192,nil,0,0,193,194,{195,196,197},{195,196,197},51,52,51},{198,nil,198,122,nil,nil,nil,199,200,{167,201,202},{167,201,202},53,54,53},{203,nil,203,204,nil,nil,nil,205,206,{207,208,209},{207,208,209},55,56,55},{210,nil,210,122,nil,nil,nil,211,212,{167,201,202},{167,201,202},57,58,57},{213,nil,213,204,nil,nil,nil,214,215,{207,208,209},{207,208,209},59,60,59},{216,nil,216,122,nil,nil,nil,217,218,{167,201,202},{167,201,202},61,62,61},{219,nil,219,204,nil,nil,nil,220,221,{207,208,209},{207,208,209},63,64,63},{222,nil,222,122,nil,nil,nil,223,224,{167,201,202},{167,201,202},65,66,65},{225,nil,225,226,nil,nil,nil,227,228,{229,230},{229,230},67,68,67},{231,nil,231,232,nil,0,0,233,234,{235,236,230},{235,236,230},69,70,69},{237,nil,237,238,nil,0,0,239,240,{241,242,230},{241,242,230},71,72,71},{243,nil,243,244,nil,nil,nil,245,246,{172,173},{172,173},73,74,73},{247,nil,247,248,nil,nil,nil,249,250,{251},{251},75,76,75},{252,nil,252,122,nil,nil,nil,253,254,{167,201,202},{167,201,202},77,78,77},{255,nil,255,204,nil,nil,nil,256,257,{258,207,208,209},{258,207,208,209},79,80,79},{259,nil,259,260,nil,0,0,261,262,{263,264},{263,264},81,82,81}},enum)custom_capabilities.text=build({{265,266,266,0,0,nil,267,64},{268,269,269,0,0,nil,270,128}},text)custom_capabilities.driver_message={["attribute_name"]="driverMessage",["capability_id"]="concertmirror08464.driverMessage",["emit_name"]="driver_message",["label"]="Driver message",["maximum_length"]=512}custom_capabilities.by_range_key={}custom_capabilities.by_emit_name={}custom_capabilities.by_capability_id={}
local function index_metadata(definitions)
for _,metadata in ipairs(definitions)do
custom_capabilities.by_emit_name[metadata.emit_name]=metadata
if type(metadata.capability_id)=="string"and metadata.capability_id~=""then custom_capabilities.by_capability_id[metadata.capability_id]=metadata end
if type(metadata.range_key)=="string"and metadata.range_key~=""then custom_capabilities.by_range_key[metadata.range_key]=metadata end
end
end
index_metadata(custom_capabilities.numeric)index_metadata(custom_capabilities.enum)index_metadata(custom_capabilities.text)custom_capabilities.by_emit_name[custom_capabilities.driver_message.emit_name]=custom_capabilities.driver_message
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
minimum=type(resolved.minimum)=="number"and resolved.minimum or(default_range and default_range.minimum or nil),maximum=type(resolved.maximum)=="number"and resolved.maximum or(default_range and default_range.maximum or nil),step=type(resolved.step)=="number"and resolved.step or(default_range and default_range.step or nil),unit=type(resolved.unit)=="string"and resolved.unit or(default_range and default_range.unit or nil),allowed_values=type(resolved.allowed_values)=="table"and clone_allowed_values(resolved.allowed_values)or clone_allowed_values(default_range and default_range.allowed_values or nil),}
end
return custom_capabilities
