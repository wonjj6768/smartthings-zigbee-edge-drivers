local custom_capabilities={}
local strings={"s","power_poll_interval","powerPollIntervalV2","powerPollInterval","powerPollIntervalRange","Power poll interval","μg/m^3","heimanHs2aqPm10","pmTen","heiman_pmTen","Heiman Hs2aq Pm10","heimanHs2aqAqi","aqi","heiman_aqi","Heiman Hs2aq Aqi","C","thirdRths0324CelsiusCal","rthsZeroThreeTwoFourCelsiusCal","third_rths0324_celsius_calibration","Third Rths0324Celsius Cal","%","thirdRths0324HumidityCal","rthsZeroThreeTwoFourHumidityCal","third_rths0324_humidity_calibration","Third Rths0324Humidity Cal","F","thirdRths0324FahrenheitCal","rthsZeroThreeTwoFourFahrenheitCal","third_rths0324_fahrenheit_calibration","Third Rths0324Fahrenheit Cal","zg9032bTemperatureCompensation","zgNineZeroThreeTwoBTempComp","zg9032b_temperature_compensation","Zg9032b Temperature Compensation","zg9032bHumidityCompensation","zgNineZeroThreeTwoBHumidityComp","zg9032b_humidity_compensation","Zg9032b Humidity Compensation","m/s","ws90WindSpeed","wsNinetyWindSpeed","ws90_wind_speed","Ws90Wind Speed","°","ws90WindDirection","wsNinetyWindDirection","ws90_wind_direction","Ws90Wind Direction","ws90GustSpeed","wsNinetyGustSpeed","ws90_gust_speed","Ws90Gust Speed","ws90UvIndex","wsNinetyUvIndex","ws90_uv_index","Ws90Uv Index","mm","ws90Precipitation","wsNinetyPrecipitation","ws90_precipitation","Ws90Precipitation","mV","rbSrain01IlluminanceRaw","illuminanceRaw","illuminance_raw","Rb Srain01Illuminance Raw","rbSrain01IlluminanceAverage20min","illuminanceAverageTwentyMin","illuminance_average_20min","Rb Srain01Illuminance Average20min","rbSrain01IlluminanceMaximumToday","illuminanceMaximumToday","illuminance_maximum_today","Rb Srain01Illuminance Maximum Today","rbSrain01RainIntensity","rainIntensity","rain_intensity","Rb Srain01Rain Intensity","ecozyLocalTemperatureCalibration","localTemperatureCalibration","local_temperature_calibration","Ecozy Local Temperature Calibration","ecozyPiHeatingDemand","piHeatingDemand","pi_heating_demand","Ecozy Pi Heating Demand","miMotionRestarts","restartCount","mi_motion_restarts","Mi Motion Restarts","aqM11Restarts","aq_m_eleven_restarts","Aq M11Restarts","aqT1Restarts","aq_t_one_restarts","Aq T1Restarts","aqE1Restarts","aq_e_one_restarts","Aq E1Restarts","aqP1Interval","detectionInterval","aq_p_one_interval","Aq P1Interval","aqT1Interval","aq_t_one_interval","Aq T1Interval","aqE1Interval","aq_e_one_interval","Aq E1Interval","aqP1DeviceTemp","deviceTemperature","aq_p_one_device_temp","Aq P1Device Temp","aqT1DeviceTemp","aq_t_one_device_temp","Aq T1Device Temp","aqE1DeviceTemp","aq_e_one_device_temp","Aq E1Device Temp","aqM11DeviceTemp","aq_m_eleven_device_temp","Aq M11Device Temp","lczTempMax","temperatureMax","lcz_temp_max","Lcz Temp Max","lczTempMin","temperatureMin","lcz_temp_min","Lcz Temp Min","lczHumidityMax","humidityMax","lcz_humidity_max","Lcz Humidity Max","lczHumidityMin","humidityMin","lcz_humidity_min","Lcz Humidity Min","rpsSensitivity","sensitivity","rps_sensitivity","Rps Sensitivity","tsVibrationSensitivity","ts_vibration_sensitivity","Ts Vibration Sensitivity","min","candeoLightInterval","lightInterval","candeo_light_interval","Candeo Light Interval","t1HtDeviceTemperature","t1_ht_device_temperature","T1Ht Device Temperature","t1HtPowerOutageCount","powerOutageCount","t1_ht_power_outage_count","T1Ht Power Outage Count","battery_low","batteryLow","Battery low","normal","low","zg9032bTemperatureDisplayUnit","zgNineZeroThreeTwoBDisplayUnit","zg9032b_temperature_display_unit","Zg9032b Temperature Display Unit","celsius","fahrenheit","ws90RainStatus","wsNinetyRainStatus","ws90_rain_status","Ws90Rain Status","dry","raining","c3007Pressure","cThreeZeroZeroSevenPressure","pressure","C3007Pressure","clear","detected","rbSrain01CleaningReminder","cleaningReminder","cleaning_reminder","Rb Srain01Cleaning Reminder","needsCleaning","heimanHs2aqBatteryState","batteryState","heiman_battery_state","Heiman Hs2aq Battery State","not_charging","charging","charged","ihRtOneSensitivity","ih_rt_one_sensitivity","Ih Rt One Sensitivity","medium","high","ihRtOneKeepTime","keepTime","ih_rt_one_keep_time","Ih Rt One Keep Time","30","60","120","ihRtTwoSensitivity","ih_rt_two_sensitivity","Ih Rt Two Sensitivity","ihRtTwoKeepTime","ih_rt_two_keep_time","Ih Rt Two Keep Time","zm35Sensitivity","zm35_sensitivity","Zm35Sensitivity","zm35KeepTime","zm35_keep_time","Zm35Keep Time","aqP1Sensitivity","aq_p_one_sensitivity","Aq P1Sensitivity","aqP1Indicator","indicator","aq_p_one_indicator","Aq P1Indicator","on","off","lczTempAlarm","temperatureAlarm","lcz_temp_alarm","Lcz Temp Alarm","below_min_temperature","over_temperature","lczHumidityAlarm","humidityAlarm","lcz_humidity_alarm","Lcz Humidity Alarm","below_min_humdity","over_humidity","kctwDisplayUnit","displayUnit","kctw_display_unit","Kctw Display Unit","rpsCalibration","calibration","rps_calibration","Rps Calibration","Press","candeoMotionSensitivity","candeo_motion_sensitivity","Candeo Motion Sensitivity","candeoMotionKeepTime","candeo_motion_keep_time","Candeo Motion Keep Time","10","cwamLightState","lightState","cwam_light_state","Cwam Light State","dark","bright","last_power_response_time","lastPowerResponseTime","Last power response time","remote_action","remoteAction","Remote action"}
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
local out={}
table_groups[group_id]=out
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
for _,row in ipairs(rows)do out[#out+1]=factory(row)end
return out
end
custom_capabilities.numeric=build({{2,2,3,4,5,nil,nil,2,6,{5,3600,5,1,nil,1,nil},5,3600,1},{8,nil,8,9,nil,0,0,10,11,{0,65535,1,7,nil,2,nil},nil,nil,7},{12,nil,12,13,nil,0,0,14,15,{0,65535,1,nil,nil,3,nil},nil,nil,nil},{17,nil,17,18,nil,nil,nil,19,20,{-200,200,1,16,nil,4,nil},nil,nil,16},{22,nil,22,23,nil,nil,nil,24,25,{-100,100,1,21,nil,5,nil},nil,nil,21},{27,nil,27,28,nil,nil,nil,29,30,{-200,200,1,26,nil,6,nil},nil,nil,26},{31,nil,31,32,nil,nil,nil,33,34,{-5,5,1,16,nil,7,nil},nil,nil,16},{35,nil,35,36,nil,nil,nil,37,38,{-5,5,1,21,nil,8,nil},nil,nil,21},{40,nil,40,41,nil,0,0,42,43,{0,140,0.1,39,nil,9,nil},nil,nil,39},{45,nil,45,46,nil,0,0,47,48,{0,360,0.1,44,nil,10,nil},nil,nil,44},{49,nil,49,50,nil,0,0,51,52,{0,140,0.1,39,nil,11,nil},nil,nil,39},{53,nil,53,54,nil,0,0,55,56,{0,11,0.1,nil,nil,12,nil},nil,nil,nil},{58,nil,58,59,nil,0,0,60,61,{0,100000,0.1,57,nil,13,nil},nil,nil,57},{63,nil,63,64,nil,0,0,65,66,{0,2147483647,1,62,nil,14,nil},nil,nil,62},{67,nil,67,68,nil,0,0,69,70,{0,2147483647,1,62,nil,15,nil},nil,nil,62},{71,nil,71,72,nil,0,0,73,74,{0,2147483647,1,62,nil,16,nil},nil,nil,62},{75,nil,75,76,nil,0,0,77,78,{0,2147483647,1,62,nil,17,nil},nil,nil,62},{79,nil,79,80,nil,nil,nil,81,82,{-2.5,2.5,0.1,16,nil,18,nil},nil,nil,16},{83,nil,83,84,nil,0,0,85,86,{0,100,1,21,nil,19,nil},nil,nil,21},{87,nil,87,88,nil,0,0,89,90,{nil,nil,nil,nil,nil,20,nil},nil,nil,nil},{91,nil,91,88,nil,0,0,92,93,{nil,nil,nil,nil,nil,21,nil},nil,nil,nil},{94,nil,94,88,nil,0,0,95,96,{nil,nil,nil,nil,nil,22,nil},nil,nil,nil},{97,nil,97,88,nil,0,0,98,99,{nil,nil,nil,nil,nil,23,nil},nil,nil,nil},{100,nil,100,101,nil,0,0,102,103,{2,65535,1,1,nil,24,nil},nil,nil,1},{104,nil,104,101,nil,0,0,105,106,{2,65535,1,1,nil,25,nil},nil,nil,1},{107,nil,107,101,nil,0,0,108,109,{2,65535,1,1,nil,26,nil},nil,nil,1},{110,nil,110,111,nil,0,0,112,113,{-128,127,1,16,nil,27,nil},nil,nil,16},{114,nil,114,111,nil,0,0,115,116,{-128,127,1,16,nil,28,nil},nil,nil,16},{117,nil,117,111,nil,0,0,118,119,{-128,127,1,16,nil,29,nil},nil,nil,16},{120,nil,120,111,nil,0,0,121,122,{-128,127,1,16,nil,30,nil},nil,nil,16},{123,nil,123,124,nil,nil,nil,125,126,{-20,80,1,16,nil,31,nil},nil,nil,16},{127,nil,127,128,nil,nil,nil,129,130,{-20,80,1,16,nil,32,nil},nil,nil,16},{131,nil,131,132,nil,nil,nil,133,134,{0,100,1,21,nil,33,nil},nil,nil,21},{135,nil,135,136,nil,nil,nil,137,138,{0,100,1,21,nil,34,nil},nil,nil,21},{139,nil,139,140,nil,nil,nil,141,142,{1,5,1,nil,nil,35,nil},nil,nil,nil},{143,nil,143,140,nil,nil,nil,144,145,{0,50,1,nil,nil,36,nil},nil,nil,nil},{147,nil,147,148,nil,nil,nil,149,150,{1,720,1,146,nil,37,nil},nil,nil,146},{151,nil,151,111,nil,0,0,152,153,{nil,nil,nil,16,nil,38,nil},nil,nil,16},{154,nil,154,155,nil,0,0,156,157,{nil,nil,nil,nil,nil,39,nil},nil,nil,nil}},numeric)
custom_capabilities.enum=build({{158,158,159,159,nil,nil,nil,158,160,{161,162},{161,162},40,41,40},{163,nil,163,164,nil,nil,nil,165,166,{167,168},{167,168},42,43,42},{169,nil,169,170,nil,0,0,171,172,{173,174},{173,174},44,45,44},{175,nil,175,176,nil,0,0,177,178,{179,180},{179,180},46,47,46},{181,nil,181,182,nil,0,0,183,184,{179,185},{179,185},48,49,48},{186,nil,186,187,nil,0,0,188,189,{190,191,192},{190,191,192},50,51,50},{193,nil,193,140,nil,nil,nil,194,195,{162,196,197},{162,196,197},52,53,52},{198,nil,198,199,nil,nil,nil,200,201,{202,203,204},{202,203,204},54,55,54},{205,nil,205,140,nil,nil,nil,206,207,{162,196,197},{162,196,197},56,57,56},{208,nil,208,199,nil,nil,nil,209,210,{202,203,204},{202,203,204},58,59,58},{211,nil,211,140,nil,nil,nil,212,213,{162,196,197},{162,196,197},60,61,60},{214,nil,214,199,nil,nil,nil,215,216,{202,203,204},{202,203,204},62,63,62},{217,nil,217,140,nil,nil,nil,218,219,{162,196,197},{162,196,197},64,65,64},{220,nil,220,221,nil,nil,nil,222,223,{224,225},{224,225},66,67,66},{226,nil,226,227,nil,0,0,228,229,{230,231,225},{230,231,225},68,69,68},{232,nil,232,233,nil,0,0,234,235,{236,237,225},{236,237,225},70,71,70},{238,nil,238,239,nil,nil,nil,240,241,{167,168},{167,168},72,73,72},{242,nil,242,243,nil,nil,nil,244,245,{246},{246},74,75,74},{247,nil,247,140,nil,nil,nil,248,249,{162,196,197},{162,196,197},76,77,76},{250,nil,250,199,nil,nil,nil,251,252,{253,202,203,204},{253,202,203,204},78,79,78},{254,nil,254,255,nil,0,0,256,257,{258,259},{258,259},80,81,80}},enum)
custom_capabilities.text=build({{260,261,261,0,0,nil,262,64},{263,264,264,0,0,nil,265,128}},text)
custom_capabilities.driver_message={["attribute_name"]="driverMessage",["capability_id"]="concertmirror08464.driverMessage",["emit_name"]="driver_message",["label"]="Driver message",["maximum_length"]=512}
custom_capabilities.by_range_key={}
custom_capabilities.by_emit_name={}
custom_capabilities.by_capability_id={}
local function index_metadata(definitions)
for _,metadata in ipairs(definitions)do
custom_capabilities.by_emit_name[metadata.emit_name]=metadata
if type(metadata.capability_id)=="string"and metadata.capability_id~=""then custom_capabilities.by_capability_id[metadata.capability_id]=metadata end
if type(metadata.range_key)=="string"and metadata.range_key~=""then custom_capabilities.by_range_key[metadata.range_key]=metadata end
end
end
index_metadata(custom_capabilities.numeric)
index_metadata(custom_capabilities.enum)
index_metadata(custom_capabilities.text)
custom_capabilities.by_emit_name[custom_capabilities.driver_message.emit_name]=custom_capabilities.driver_message
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
minimum=type(resolved.minimum)=="number"and resolved.minimum or(default_range and default_range.minimum or nil),
maximum=type(resolved.maximum)=="number"and resolved.maximum or(default_range and default_range.maximum or nil),
step=type(resolved.step)=="number"and resolved.step or(default_range and default_range.step or nil),
unit=type(resolved.unit)=="string"and resolved.unit or(default_range and default_range.unit or nil),
allowed_values=type(resolved.allowed_values)=="table"and clone_allowed_values(resolved.allowed_values)or clone_allowed_values(default_range and default_range.allowed_values or nil),}
end
return custom_capabilities
