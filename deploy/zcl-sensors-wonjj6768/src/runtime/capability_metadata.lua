local custom_capabilities={}
local strings={"presence_sensitivity","presenceSensitivity","presenceSensitivityRange","Presence sensitivity","s","power_poll_interval","powerPollIntervalV2","powerPollInterval","powerPollIntervalRange","Power poll interval","μg/m^3","heimanHs2aqPm10","pmTen","heiman_pmTen","Heiman Hs2aq Pm10","heimanHs2aqAqi","aqi","heiman_aqi","Heiman Hs2aq Aqi","C","thirdRths0324CelsiusCal","rthsZeroThreeTwoFourCelsiusCal","third_rths0324_celsius_calibration","Third Rths0324Celsius Cal","%","thirdRths0324HumidityCal","rthsZeroThreeTwoFourHumidityCal","third_rths0324_humidity_calibration","Third Rths0324Humidity Cal","F","thirdRths0324FahrenheitCal","rthsZeroThreeTwoFourFahrenheitCal","third_rths0324_fahrenheit_calibration","Third Rths0324Fahrenheit Cal","zg9032bTemperatureCompensation","zgNineZeroThreeTwoBTempComp","zg9032b_temperature_compensation","Zg9032b Temperature Compensation","zg9032bHumidityCompensation","zgNineZeroThreeTwoBHumidityComp","zg9032b_humidity_compensation","Zg9032b Humidity Compensation","m/s","ws90WindSpeed","wsNinetyWindSpeed","ws90_wind_speed","Ws90Wind Speed","°","ws90WindDirection","wsNinetyWindDirection","ws90_wind_direction","Ws90Wind Direction","ws90GustSpeed","wsNinetyGustSpeed","ws90_gust_speed","Ws90Gust Speed","ws90UvIndex","wsNinetyUvIndex","ws90_uv_index","Ws90Uv Index","mm","ws90Precipitation","wsNinetyPrecipitation","ws90_precipitation","Ws90Precipitation","mV","rbSrain01IlluminanceRaw","illuminanceRaw","illuminance_raw","Rb Srain01Illuminance Raw","rbSrain01IlluminanceAverage20min","illuminanceAverageTwentyMin","illuminance_average_20min","Rb Srain01Illuminance Average20min","rbSrain01IlluminanceMaximumToday","illuminanceMaximumToday","illuminance_maximum_today","Rb Srain01Illuminance Maximum Today","rbSrain01RainIntensity","rainIntensity","rain_intensity","Rb Srain01Rain Intensity","ecozyLocalTemperatureCalibration","localTemperatureCalibration","local_temperature_calibration","Ecozy Local Temperature Calibration","ecozyPiHeatingDemand","piHeatingDemand","pi_heating_demand","Ecozy Pi Heating Demand","battery_low","batteryLow","Battery low","normal","low","zg9032bTemperatureDisplayUnit","zgNineZeroThreeTwoBDisplayUnit","zg9032b_temperature_display_unit","Zg9032b Temperature Display Unit","celsius","fahrenheit","ws90RainStatus","wsNinetyRainStatus","ws90_rain_status","Ws90Rain Status","dry","raining","c3007Pressure","cThreeZeroZeroSevenPressure","pressure","C3007Pressure","clear","detected","rbSrain01CleaningReminder","cleaningReminder","cleaning_reminder","Rb Srain01Cleaning Reminder","needsCleaning","heimanHs2aqBatteryState","batteryState","heiman_battery_state","Heiman Hs2aq Battery State","not_charging","charging","charged","shellyBluDoorHandlePosition","shelly_handle_position","Shelly Blu Door Handle Position","open","closed","tilted","last_power_response_time","lastPowerResponseTime","Last power response time","remote_action","remoteAction","Remote action"}
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
custom_capabilities.numeric=build({{1,1,2,2,3,nil,nil,1,4,{0,10,1,nil,nil,1,nil},nil,10,nil},{6,6,7,8,9,nil,nil,6,10,{5,3600,5,5,nil,2,nil},5,3600,5},{12,nil,12,13,nil,0,0,14,15,{0,65535,1,11,nil,3,nil},nil,nil,11},{16,nil,16,17,nil,0,0,18,19,{0,65535,1,nil,nil,4,nil},nil,nil,nil},{21,nil,21,22,nil,nil,nil,23,24,{-200,200,1,20,nil,5,nil},nil,nil,20},{26,nil,26,27,nil,nil,nil,28,29,{-100,100,1,25,nil,6,nil},nil,nil,25},{31,nil,31,32,nil,nil,nil,33,34,{-200,200,1,30,nil,7,nil},nil,nil,30},{35,nil,35,36,nil,nil,nil,37,38,{-5,5,1,20,nil,8,nil},nil,nil,20},{39,nil,39,40,nil,nil,nil,41,42,{-5,5,1,25,nil,9,nil},nil,nil,25},{44,nil,44,45,nil,0,0,46,47,{0,140,0.1,43,nil,10,nil},nil,nil,43},{49,nil,49,50,nil,0,0,51,52,{0,360,0.1,48,nil,11,nil},nil,nil,48},{53,nil,53,54,nil,0,0,55,56,{0,140,0.1,43,nil,12,nil},nil,nil,43},{57,nil,57,58,nil,0,0,59,60,{0,11,0.1,nil,nil,13,nil},nil,nil,nil},{62,nil,62,63,nil,0,0,64,65,{0,100000,0.1,61,nil,14,nil},nil,nil,61},{67,nil,67,68,nil,0,0,69,70,{0,2147483647,1,66,nil,15,nil},nil,nil,66},{71,nil,71,72,nil,0,0,73,74,{0,2147483647,1,66,nil,16,nil},nil,nil,66},{75,nil,75,76,nil,0,0,77,78,{0,2147483647,1,66,nil,17,nil},nil,nil,66},{79,nil,79,80,nil,0,0,81,82,{0,2147483647,1,66,nil,18,nil},nil,nil,66},{83,nil,83,84,nil,nil,nil,85,86,{-2.5,2.5,0.1,20,nil,19,nil},nil,nil,20},{87,nil,87,88,nil,0,0,89,90,{0,100,1,25,nil,20,nil},nil,nil,25}},numeric)
custom_capabilities.enum=build({{91,91,92,92,nil,nil,nil,91,93,{94,95},{94,95},21,22,21},{96,nil,96,97,nil,nil,nil,98,99,{100,101},{100,101},23,24,23},{102,nil,102,103,nil,0,0,104,105,{106,107},{106,107},25,26,25},{108,nil,108,109,nil,0,0,110,111,{112,113},{112,113},27,28,27},{114,nil,114,115,nil,0,0,116,117,{112,118},{112,118},29,30,29},{119,nil,119,120,nil,0,0,121,122,{123,124,125},{123,124,125},31,32,31},{126,nil,126,126,nil,0,0,127,128,{129,130,131},{129,130,131},33,34,33}},enum)
custom_capabilities.text=build({{132,133,133,0,0,nil,134,64},{135,136,136,0,0,nil,137,128}},text)
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
