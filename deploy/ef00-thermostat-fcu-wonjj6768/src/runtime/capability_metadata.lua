local custom_capabilities={}
local strings={"kWh","energyTodayTwcR01","energyTodayTwcRZeroOne","energy_today","Energy Today Twc R01","energyYesterdayTwcR01","energyYesterdayTwcRZeroOne","energy_yesterday","Energy Yesterday Twc R01","C","maxTempLimitTybacCToThirty","capqrfwpywdvjzmovhdtays","max_temperature_limit","Max Temp Limit Tybac CTo Thirty","minTempLimitTybacCToThirty","capqheplozwascjxlchygob","min_temperature_limit","Min Temp Limit Tybac CTo Thirty","screenBrightnessL2TFMfLevel9","screenBrightnessLTwoTFMfLevelNine","display_brightness","Screen Brightness L2TFMf Level9","saswellTempCalibration","temperatureCalibration","temperature_calibration","Saswell Temp Calibration","hhstMaxTemperature","maxTemperature","max_temperature","Hhst Max Temperature","hhstMinTemperature","minTemperature","min_temperature","Hhst Min Temperature","hhstTempCalibration","Hhst Temp Calibration","hhstDeadzoneTemperature","deadzoneTemperature","deadzone_temperature","Hhst Deadzone Temperature","F","hhstLocalTemperatureF","localTemperatureF","local_temperature_f","Hhst Local Temperature F","l2tfMinTemperatureLimit","minTemperatureLimit","L2tf Min Temperature Limit","l2tfMaxTemperatureLimit","maxTemperatureLimit","L2tf Max Temperature Limit","l2tfTempCalibration","L2tf Temp Calibration","l2tfDeadzoneTemperature","L2tf Deadzone Temperature","l2tfEcoTemperatureHeating","ecoTemperatureHeating","eco_temperature_heating","L2tf Eco Temperature Heating","l2tfEcoTemperatureCooling","ecoTemperatureCooling","eco_temperature_cooling","L2tf Eco Temperature Cooling","twcr01TempCalibration","Twcr01Temp Calibration","twcr01OpenWindowTemperature","openWindowTemperature","open_window_temperature","Twcr01Open Window Temperature","twcr01Fault","fault","Twcr01Fault","xixlTempCalibration","Xixl Temp Calibration","xixlError","error","Xixl Error","h","xzakt101BoostTime","boostTime","boost_time","Xzakt101Boost Time","bac003MaxTemperature","Bac003Max Temperature","bac003DeadzoneTemperature","Bac003Deadzone Temperature","bac003TempCalibration","Bac003Temp Calibration","tybacTempCalibration","Tybac Temp Calibration","tybacDeadzoneTemperature","Tybac Deadzone Temperature","battery_low","batteryLow","Battery low","normal","low","manualModeTybac006","manualModeTybacZeroZeroSix","manual_mode","Manual Mode Tybac006","off","on","manualModeHhstAutoManualTemp","capvkzueasiklxvfytdgcrp","Manual Mode Hhst Auto Manual Temp","auto","manual","temporary","pilotWireModeTwcR01","pilotWireModeTwcRZeroOne","pilot_wire_mode","Pilot Wire Mode Twc R01","comfort","eco","antifrost","comfort_1","comfort_2","saswellWindowDetection","windowDetection","window_detection","Saswell Window Detection","saswellFrostDetection","frostDetection","frost_detection","Saswell Frost Detection","saswellChildLock","childLock","child_lock","Saswell Child Lock","unlock","lock","saswellAwayMode","awayMode","away_mode","Saswell Away Mode","saswellAntiScaling","antiScaling","anti_scaling","Saswell Anti Scaling","saswellBatteryLow","Saswell Battery Low","hhstChildLock","Hhst Child Lock","hhstTemperatureScale","temperatureScale","temperature_scale","Hhst Temperature Scale","celsius","fahrenheit","l2tfChildLock","L2tf Child Lock","twcr01EcoMode","ecoMode","eco_mode","Twcr01Eco Mode","twcr01OpenWindow","openWindow","open_window","Twcr01Open Window","twcr01DeviceModeType","deviceModeType","device_mode_type","Twcr01Device Mode Type","snfdSleep","sleep","Snfd Sleep","snfdTurbo","turbo","Snfd Turbo","snfdQuiet","quiet","Snfd Quiet","snfdSwingMode","swingMode","swing_mode","Snfd Swing Mode","xixlBatteryLow","Xixl Battery Low","xixlChildLock","Xixl Child Lock","etopChildLock","Etop Child Lock","sas936ChildLock","Sas936Child Lock","sas936TemporaryLeaving","temporaryLeaving","temporary_leaving","Sas936Temporary Leaving","xzakt101ChildLock","Xzakt101Child Lock","ae940kChildLock","Ae940k Child Lock","ae720kChildLock","Ae720k Child Lock","ae669kChildLock","Ae669k Child Lock","bac003Preset","preset","Bac003Preset","bac003ChildLock","Bac003Child Lock","tybacEcoMode","Tybac Eco Mode","tybacChildLock","Tybac Child Lock","tybacValve","valve","Tybac Valve","open","close","last_power_response_time","lastPowerResponseTime","Last power response time","etopErrorStatus","errorStatus","error_status","Etop Error Status"}
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
custom_capabilities.numeric=build({{2,nil,2,3,nil,0,0,4,5,{0,999999,0.001,1,nil,1,nil},nil,nil,1},{6,nil,6,7,nil,0,0,8,9,{0,999999,0.001,1,nil,2,nil},nil,nil,1},{11,nil,11,12,nil,nil,nil,13,14,{15,30,1,10,nil,3,nil},nil,nil,10},{15,nil,15,16,nil,nil,nil,17,18,{15,30,1,10,nil,4,nil},nil,nil,10},{19,nil,19,20,nil,nil,nil,21,22,{1,9,1,nil,nil,5,nil},nil,nil,nil},{23,nil,23,24,nil,nil,nil,25,26,{-6,6,1,10,nil,6,nil},nil,nil,10},{27,nil,27,28,nil,nil,nil,29,30,{15,45,0.5,10,nil,7,nil},nil,nil,10},{31,nil,31,32,nil,nil,nil,33,34,{5,20,0.5,10,nil,8,nil},nil,nil,10},{35,nil,35,24,nil,nil,nil,25,36,{-9.9,9.9,0.1,10,nil,9,nil},nil,nil,10},{37,nil,37,38,nil,nil,nil,39,40,{0,10,1,10,nil,10,nil},nil,nil,10},{42,nil,42,43,nil,0,0,44,45,{0,200,1,41,nil,11,nil},nil,nil,41},{46,nil,46,47,nil,nil,nil,17,48,{5,20,0.5,10,nil,12,nil},nil,nil,10},{49,nil,49,50,nil,nil,nil,13,51,{15,45,0.5,10,nil,13,nil},nil,nil,10},{52,nil,52,24,nil,nil,nil,25,53,{-9.9,9.9,0.1,10,nil,14,nil},nil,nil,10},{54,nil,54,38,nil,nil,nil,39,55,{0,10,1,10,nil,15,nil},nil,nil,10},{56,nil,56,57,nil,nil,nil,58,59,{5,35,0.5,10,nil,16,nil},nil,nil,10},{60,nil,60,61,nil,nil,nil,62,63,{5,35,0.5,10,nil,17,nil},nil,nil,10},{64,nil,64,24,nil,nil,nil,25,65,{-8,8,0.5,10,nil,18,nil},nil,nil,10},{66,nil,66,67,nil,nil,nil,68,69,{0,35,1,10,nil,19,nil},nil,nil,10},{70,nil,70,71,nil,0,0,71,72,{0,255,1,nil,nil,20,nil},nil,nil,nil},{73,nil,73,24,nil,nil,nil,25,74,{-9.9,9.9,0.1,10,nil,21,nil},nil,nil,10},{75,nil,75,76,nil,0,0,76,77,{0,255,1,nil,nil,22,nil},nil,nil,nil},{79,nil,79,80,nil,nil,nil,81,82,{0,24,0.5,78,nil,23,nil},nil,nil,78},{83,nil,83,28,nil,nil,nil,29,84,{35,45,1,10,nil,24,nil},nil,nil,10},{85,nil,85,38,nil,nil,nil,39,86,{0,5,1,10,nil,25,nil},nil,nil,10},{87,nil,87,24,nil,nil,nil,25,88,{-9,9,1,10,nil,26,nil},nil,nil,10},{89,nil,89,24,nil,nil,nil,25,90,{-9,9,0.5,10,nil,27,nil},nil,nil,10},{91,nil,91,38,nil,nil,nil,39,92,{0,5,1,10,nil,28,nil},nil,nil,10}},numeric)
custom_capabilities.enum=build({{93,93,94,94,nil,nil,nil,93,95,{96,97},{96,97},29,30,29},{98,nil,98,99,nil,nil,nil,100,101,{102,103},{102,103},31,32,31},{104,nil,104,105,nil,nil,nil,100,106,{107,108,109},{107,108,109},33,34,33},{110,nil,110,111,nil,nil,nil,112,113,{114,115,116,102,117,118},{114,115,116,102,117,118},35,36,35},{119,nil,119,120,nil,nil,nil,121,122,{102,103},{102,103},37,38,37},{123,nil,123,124,nil,nil,nil,125,126,{102,103},{102,103},39,40,39},{127,nil,127,128,nil,nil,nil,129,130,{131,132},{131,132},41,42,41},{133,nil,133,134,nil,nil,nil,135,136,{102,103},{102,103},43,44,43},{137,nil,137,138,nil,nil,nil,139,140,{102,103},{102,103},45,46,45},{141,nil,141,94,nil,0,0,93,142,{96,97},{96,97},47,48,47},{143,nil,143,128,nil,nil,nil,129,144,{131,132},{131,132},49,50,49},{145,nil,145,146,nil,nil,nil,147,148,{149,150},{149,150},51,52,51},{151,nil,151,128,nil,nil,nil,129,152,{131,132},{131,132},53,54,53},{153,nil,153,154,nil,nil,nil,155,156,{102,103},{102,103},55,56,55},{157,nil,157,158,nil,nil,nil,159,160,{102,103},{102,103},57,58,57},{161,nil,161,162,nil,nil,nil,163,164,{102,103},{102,103},59,60,59},{165,nil,165,166,nil,nil,nil,166,167,{102,103},{102,103},61,62,61},{168,nil,168,169,nil,nil,nil,169,170,{102,103},{102,103},63,64,63},{171,nil,171,172,nil,nil,nil,172,173,{102,103},{102,103},65,66,65},{174,nil,174,175,nil,nil,nil,176,177,{102,103},{102,103},67,68,67},{178,nil,178,94,nil,0,0,93,179,{96,97},{96,97},69,70,69},{180,nil,180,128,nil,nil,nil,129,181,{131,132},{131,132},71,72,71},{182,nil,182,128,nil,nil,nil,129,183,{131,132},{131,132},73,74,73},{184,nil,184,128,nil,nil,nil,129,185,{131,132},{131,132},75,76,75},{186,nil,186,187,nil,nil,nil,188,189,{102,103},{102,103},77,78,77},{190,nil,190,128,nil,nil,nil,129,191,{131,132},{131,132},79,80,79},{192,nil,192,128,nil,nil,nil,129,193,{131,132},{131,132},81,82,81},{194,nil,194,128,nil,nil,nil,129,195,{131,132},{131,132},83,84,83},{196,nil,196,128,nil,nil,nil,129,197,{131,132},{131,132},85,86,85},{198,nil,198,199,nil,nil,nil,199,200,{107,108},{107,108},87,88,87},{201,nil,201,128,nil,nil,nil,129,202,{131,132},{131,132},89,90,89},{203,nil,203,154,nil,nil,nil,155,204,{102,103},{102,103},91,92,91},{205,nil,205,128,nil,nil,nil,129,206,{131,132},{131,132},93,94,93},{207,nil,207,208,nil,0,0,208,209,{210,211},{210,211},95,96,95}},enum)
custom_capabilities.text=build({{212,213,213,0,0,nil,214,64},{215,215,216,0,0,217,218,256}},text)
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
