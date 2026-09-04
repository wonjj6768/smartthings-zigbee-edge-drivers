local custom_capabilities={}
local strings={"kWh","energyTodayTwcR01","energyTodayTwcRZeroOne","energy_today","Energy Today Twc R01","energyYesterdayTwcR01","energyYesterdayTwcRZeroOne","energy_yesterday","Energy Yesterday Twc R01","C","maxTempLimitTybacCToThirty","capqrfwpywdvjzmovhdtays","max_temperature_limit","Max Temp Limit Tybac CTo Thirty","minTempLimitTybacCToThirty","capqheplozwascjxlchygob","min_temperature_limit","Min Temp Limit Tybac CTo Thirty","screenBrightnessL2TFMfLevel9","screenBrightnessLTwoTFMfLevelNine","display_brightness","Screen Brightness L2TFMf Level9","saswellTempCalibration","temperatureCalibration","local_temperature_calibration","Saswell Temp Calibration","hhstMaxTemperature","maxTemperature","max_temperature","Hhst Max Temperature","hhstMinTemperature","minTemperature","min_temperature","Hhst Min Temperature","hhstTempCalibration","Hhst Temp Calibration","hhstDeadzoneTemperature","deadzoneTemperature","deadzone_temperature","Hhst Deadzone Temperature","F","hhstLocalTemperatureF","localTemperatureF","local_temperature_f","Hhst Local Temperature F","l2tfMinTemperatureLimit","minTemperatureLimit","L2tf Min Temperature Limit","l2tfMaxTemperatureLimit","maxTemperatureLimit","L2tf Max Temperature Limit","l2tfDeadzoneTemperature","L2tf Deadzone Temperature","l2tfEcoTemperatureHeating","ecoTemperatureHeating","eco_temperature_heating","L2tf Eco Temperature Heating","l2tfEcoTemperatureCooling","ecoTemperatureCooling","eco_temperature_cooling","L2tf Eco Temperature Cooling","twcr01TempCalibration","Twcr01Temp Calibration","twcr01OpenWindowTemperature","openWindowTemperature","open_window_temperature","Twcr01Open Window Temperature","twcr01Fault","fault","Twcr01Fault","xixlTempCalibration","Xixl Temp Calibration","xixlError","error","Xixl Error","h","xzakt101BoostTime","boostTime","boost_time","Xzakt101Boost Time","bac003MaxTemperature","Bac003Max Temperature","bac003DeadzoneTemperature","Bac003Deadzone Temperature","bac003TempCalibration","Bac003Temp Calibration","tybacTempCalibration","Tybac Temp Calibration","tybacDeadzoneTemperature","Tybac Deadzone Temperature","l2tfLocalTempCalibration","localTemperatureCalibration","L2tf Local Temp Calibration","battery_low","batteryLow","Battery low","normal","low","manualModeTybac006","manualModeTybacZeroZeroSix","manual_mode","Manual Mode Tybac006","off","on","manualModeHhstAutoManualTemp","capvkzueasiklxvfytdgcrp","Manual Mode Hhst Auto Manual Temp","auto","manual","temporary","pilotWireModeTwcR01","pilotWireModeTwcRZeroOne","pilot_wire_mode","Pilot Wire Mode Twc R01","comfort","eco","antifrost","comfort_1","comfort_2","saswellWindowDetection","windowDetection","window_detection","Saswell Window Detection","saswellFrostDetection","frostDetection","frost_detection","Saswell Frost Detection","saswellChildLock","childLock","child_lock","Saswell Child Lock","unlock","lock","saswellAwayMode","awayMode","away_mode","Saswell Away Mode","saswellAntiScaling","antiScaling","anti_scaling","Saswell Anti Scaling","saswellBatteryLow","Saswell Battery Low","hhstChildLock","Hhst Child Lock","hhstTemperatureScale","temperatureScale","temperature_scale","Hhst Temperature Scale","celsius","fahrenheit","l2tfChildLock","L2tf Child Lock","twcr01EcoMode","ecoMode","eco_mode","Twcr01Eco Mode","twcr01OpenWindow","openWindow","open_window","Twcr01Open Window","twcr01DeviceModeType","deviceModeType","device_mode_type","Twcr01Device Mode Type","snfdSleep","sleep","Snfd Sleep","snfdTurbo","turbo","Snfd Turbo","snfdQuiet","quiet","Snfd Quiet","snfdSwingMode","swingMode","swing_mode","Snfd Swing Mode","xixlBatteryLow","Xixl Battery Low","xixlChildLock","Xixl Child Lock","etopChildLock","Etop Child Lock","sas936ChildLock","Sas936Child Lock","sas936TemporaryLeaving","temporaryLeaving","temporary_leaving","Sas936Temporary Leaving","xzakt101ChildLock","Xzakt101Child Lock","ae940kChildLock","Ae940k Child Lock","ae720kChildLock","Ae720k Child Lock","ae669kChildLock","Ae669k Child Lock","bac003Preset","preset","Bac003Preset","bac003ChildLock","Bac003Child Lock","tybacEcoMode","Tybac Eco Mode","tybacChildLock","Tybac Child Lock","tybacValve","valve","Tybac Valve","open","close","last_power_response_time","lastPowerResponseTime","Last power response time","etopErrorStatus","errorStatus","error_status","Etop Error Status"}
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
custom_capabilities.numeric=build({{2,nil,2,3,nil,0,0,4,5,{0,999999,0.001,1,nil,1,nil},nil,nil,1},{6,nil,6,7,nil,0,0,8,9,{0,999999,0.001,1,nil,2,nil},nil,nil,1},{11,nil,11,12,nil,nil,nil,13,14,{15,30,1,10,nil,3,nil},nil,nil,10},{15,nil,15,16,nil,nil,nil,17,18,{15,30,1,10,nil,4,nil},nil,nil,10},{19,nil,19,20,nil,nil,nil,21,22,{1,9,1,nil,nil,5,nil},nil,nil,nil},{23,nil,23,24,nil,nil,nil,25,26,{-6,6,1,10,nil,6,nil},nil,nil,10},{27,nil,27,28,nil,nil,nil,29,30,{15,45,0.5,10,nil,7,nil},nil,nil,10},{31,nil,31,32,nil,nil,nil,33,34,{5,20,0.5,10,nil,8,nil},nil,nil,10},{35,nil,35,24,nil,nil,nil,25,36,{-9.9,9.9,0.1,10,nil,9,nil},nil,nil,10},{37,nil,37,38,nil,nil,nil,39,40,{0,10,1,10,nil,10,nil},nil,nil,10},{42,nil,42,43,nil,0,0,44,45,{0,200,1,41,nil,11,nil},nil,nil,41},{46,nil,46,47,nil,nil,nil,17,48,{5,20,0.5,10,nil,12,nil},nil,nil,10},{49,nil,49,50,nil,nil,nil,13,51,{15,45,0.5,10,nil,13,nil},nil,nil,10},{52,nil,52,38,nil,nil,nil,39,53,{0,10,1,10,nil,14,nil},nil,nil,10},{54,nil,54,55,nil,nil,nil,56,57,{5,35,0.5,10,nil,15,nil},nil,nil,10},{58,nil,58,59,nil,nil,nil,60,61,{5,35,0.5,10,nil,16,nil},nil,nil,10},{62,nil,62,24,nil,nil,nil,25,63,{-8,8,0.5,10,nil,17,nil},nil,nil,10},{64,nil,64,65,nil,nil,nil,66,67,{0,35,1,10,nil,18,nil},nil,nil,10},{68,nil,68,69,nil,0,0,69,70,{0,255,1,nil,nil,19,nil},nil,nil,nil},{71,nil,71,24,nil,nil,nil,25,72,{-9.9,9.9,0.1,10,nil,20,nil},nil,nil,10},{73,nil,73,74,nil,0,0,74,75,{0,255,1,nil,nil,21,nil},nil,nil,nil},{77,nil,77,78,nil,nil,nil,79,80,{0,24,0.5,76,nil,22,nil},nil,nil,76},{81,nil,81,28,nil,nil,nil,29,82,{35,45,1,10,nil,23,nil},nil,nil,10},{83,nil,83,38,nil,nil,nil,39,84,{0,5,1,10,nil,24,nil},nil,nil,10},{85,nil,85,24,nil,nil,nil,25,86,{-9,9,1,10,nil,25,nil},nil,nil,10},{87,nil,87,24,nil,nil,nil,25,88,{-9,9,0.5,10,nil,26,nil},nil,nil,10},{89,nil,89,38,nil,nil,nil,39,90,{0,5,1,10,nil,27,nil},nil,nil,10},{91,nil,91,92,nil,nil,nil,25,93,{-9,9,1,10,nil,28,nil},nil,nil,10}},numeric)
custom_capabilities.enum=build({{94,94,95,95,nil,nil,nil,94,96,{97,98},{97,98},29,30,29},{99,nil,99,100,nil,nil,nil,101,102,{103,104},{103,104},31,32,31},{105,nil,105,106,nil,nil,nil,101,107,{108,109,110},{108,109,110},33,34,33},{111,nil,111,112,nil,nil,nil,113,114,{115,116,117,103,118,119},{115,116,117,103,118,119},35,36,35},{120,nil,120,121,nil,nil,nil,122,123,{103,104},{103,104},37,38,37},{124,nil,124,125,nil,nil,nil,126,127,{103,104},{103,104},39,40,39},{128,nil,128,129,nil,nil,nil,130,131,{132,133},{132,133},41,42,41},{134,nil,134,135,nil,nil,nil,136,137,{103,104},{103,104},43,44,43},{138,nil,138,139,nil,nil,nil,140,141,{103,104},{103,104},45,46,45},{142,nil,142,95,nil,0,0,94,143,{97,98},{97,98},47,48,47},{144,nil,144,129,nil,nil,nil,130,145,{132,133},{132,133},49,50,49},{146,nil,146,147,nil,nil,nil,148,149,{150,151},{150,151},51,52,51},{152,nil,152,129,nil,nil,nil,130,153,{132,133},{132,133},53,54,53},{154,nil,154,155,nil,nil,nil,156,157,{103,104},{103,104},55,56,55},{158,nil,158,159,nil,nil,nil,160,161,{103,104},{103,104},57,58,57},{162,nil,162,163,nil,nil,nil,164,165,{103,104},{103,104},59,60,59},{166,nil,166,167,nil,nil,nil,167,168,{103,104},{103,104},61,62,61},{169,nil,169,170,nil,nil,nil,170,171,{103,104},{103,104},63,64,63},{172,nil,172,173,nil,nil,nil,173,174,{103,104},{103,104},65,66,65},{175,nil,175,176,nil,nil,nil,177,178,{103,104},{103,104},67,68,67},{179,nil,179,95,nil,0,0,94,180,{97,98},{97,98},69,70,69},{181,nil,181,129,nil,nil,nil,130,182,{132,133},{132,133},71,72,71},{183,nil,183,129,nil,nil,nil,130,184,{132,133},{132,133},73,74,73},{185,nil,185,129,nil,nil,nil,130,186,{132,133},{132,133},75,76,75},{187,nil,187,188,nil,nil,nil,189,190,{103,104},{103,104},77,78,77},{191,nil,191,129,nil,nil,nil,130,192,{132,133},{132,133},79,80,79},{193,nil,193,129,nil,nil,nil,130,194,{132,133},{132,133},81,82,81},{195,nil,195,129,nil,nil,nil,130,196,{132,133},{132,133},83,84,83},{197,nil,197,129,nil,nil,nil,130,198,{132,133},{132,133},85,86,85},{199,nil,199,200,nil,nil,nil,200,201,{108,109},{108,109},87,88,87},{202,nil,202,129,nil,nil,nil,130,203,{132,133},{132,133},89,90,89},{204,nil,204,155,nil,nil,nil,156,205,{103,104},{103,104},91,92,91},{206,nil,206,129,nil,nil,nil,130,207,{132,133},{132,133},93,94,93},{208,nil,208,209,nil,0,0,209,210,{211,212},{211,212},95,96,95}},enum)
custom_capabilities.text=build({{213,214,214,0,0,nil,215,64},{216,216,217,0,0,218,219,256}},text)
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
