local custom_capabilities={}
local strings={"presence_sensitivity","presenceSensitivity","presenceSensitivityRange","Presence sensitivity","static_detection_sensitivity","staticDetectionSensitivity","staticDetectionSensitivityRange","Static detection sensitivity","motion_detection_sensitivity","motionDetectionSensitivity","motionDetectionSensitivityRange","Motion detection sensitivity","move_sensitivity","moveSensitivity","moveSensitivityRange","Move sensitivity","breath_sensitivity","breathSensitivity","breathSensitivityRange","Breath sensitivity","m","minimum_range","minimumRange","minimumRangeRange","Minimum range","s","detection_delay","detectionDelay","detectionDelayRange","Detection delay","presence_detection_range","presenceDetectionRange","presenceDetectionRangeRange","Presence detection range","presence_fading_time","detectionHoldTime","detectionHoldTimeRange","Detection hold time","presence_target_distance","presenceTargetDistance","presenceTargetDistanceRange","Presence target distance","presenceSensitivityZym100l","presenceSensZymHundredL","Presence Sensitivity Zym100l","minimumRangeZym100l","minimumRangeZymOneZeroZerol","Minimum Range Zym100l","presenceDetectionRangeZym100l","presenceRangeZymHundredL","Presence Detection Range Zym100l","detectionDelayZym100l","detectionDelayZymOneZeroZerol","Detection Delay Zym100l","presenceFadingTimeZym100l","presenceFadingTimeZymOneZeroZerol","Presence Fading Time Zym100l","presenceTargetDistanceZym100l","presenceTargetZymHundredL","Presence Target Distance Zym100l","zg204zqFadingTime","fadingTime","fading_time","Zg204zq Fading Time","%","zg204zqHumidityCalibration","humidityCalibration","humidity_calibration","Zg204zq Humidity Calibration","C","zg204zqTemperatureCalibration","temperatureCalibration","temperature_calibration","Zg204zq Temperature Calibration","min","zg204zqIlluminanceInterval","illuminanceInterval","illuminance_interval","Zg204zq Illuminance Interval","zis01pPresenceDistance","presenceDistance","presence_distance","Zis01p Presence Distance","zis01pPresenceSensitivity","Zis01p Presence Sensitivity","zis01pPirSensitivity","pirSensitivity","pir_sensitivity","Zis01p Pir Sensitivity","zis01pDelayTime","delayTime","delay_time","Zis01p Delay Time","zym100s1RadarSensitivity","radarSensitivity","radar_sensitivity","Zym100s1Radar Sensitivity","zym100s1MinimumRange","Zym100s1Minimum Range","zym100s1MaximumRange","maximumRange","maximum_range","Zym100s1Maximum Range","zym100s1TargetDistance","targetDistance","target_distance","Zym100s1Target Distance","zym100s1DetectionDelay","Zym100s1Detection Delay","zym100s1FadingTime","Zym100s1Fading Time","zym100s2RadarSensitivity","Zym100s2Radar Sensitivity","zym100s2MinimumRange","Zym100s2Minimum Range","zym100s2MaximumRange","Zym100s2Maximum Range","zym100s2TargetDistance","Zym100s2Target Distance","zym100s2DetectionDelay","Zym100s2Detection Delay","zym100s2FadingTime","Zym100s2Fading Time","zg204zkFadingTime","Zg204zk Fading Time","zg204zkDetectionDistance","detectionDistance","detection_distance","Zg204zk Detection Distance","zg204zkStaticSensitivity","Zg204zk Static Sensitivity","zg204zkMotionSensitivity","Zg204zk Motion Sensitivity","zg204zmFadingTime","Zg204zm Fading Time","zg204zmStaticDistance","staticDetectionDistance","static_detection_distance","Zg204zm Static Distance","zg204zmStaticSensitivity","Zg204zm Static Sensitivity","zg204zmMotionSensitivity","Zg204zm Motion Sensitivity","zg204zvFadingTime","Zg204zv Fading Time","zg204zvMotionSensitivity","Zg204zv Motion Sensitivity","zg204zvIlluminanceInterval","Zg204zv Illuminance Interval","zg204zvTemperatureCalibration","Zg204zv Temperature Calibration","zg204zvHumidityCalibration","Zg204zv Humidity Calibration","zg204zeFadingTime","Zg204ze Fading Time","zg204zeMotionSensitivity","Zg204ze Motion Sensitivity","zg204zeIlluminanceInterval","Zg204ze Illuminance Interval","zg204zhFadingTime","Zg204zh Fading Time","zg204zhStaticDistance","Zg204zh Static Distance","zg204zhStaticSensitivity","Zg204zh Static Sensitivity","zg204zhMotionSensitivity","Zg204zh Motion Sensitivity","zg204zhIlluminanceInterval","Zg204zh Illuminance Interval","zg204zhTemperatureCalibration","Zg204zh Temperature Calibration","zg204zhHumidityCalibration","Zg204zh Humidity Calibration","zf24MoveSensitivity","Zf24Move Sensitivity","zf24PresenceSensitivity","Zf24Presence Sensitivity","zf24PresenceTimeout","presenceTimeout","presence_timeout","Zf24Presence Timeout","zf24DetectionDistanceMax","detectionDistanceMax","detection_distance_max","Zf24Detection Distance Max","zf24Distance","distance","Zf24Distance","zyhps01PresenceTimeout","Zyhps01Presence Timeout","zyhps01MoveSensitivity","Zyhps01Move Sensitivity","cm","zyhps01MoveMinimumRange","moveMinimumRange","move_minimum_range","Zyhps01Move Minimum Range","zyhps01MoveMaximumRange","moveMaximumRange","move_maximum_range","Zyhps01Move Maximum Range","zyhps01BreathSensitivity","Zyhps01Breath Sensitivity","zyhps01BreathMinimumRange","breathMinimumRange","breath_minimum_range","Zyhps01Breath Minimum Range","zyhps01BreathMaximumRange","breathMaximumRange","breath_maximum_range","Zyhps01Breath Maximum Range","zd24Distance","Zd24Distance","zd24FadingTime","Zd24Fading Time","zd24MotionSensitivity","Zd24Motion Sensitivity","zd24StaticSensitivity","Zd24Static Sensitivity","zis01pRadarThreshold","radarThreshold","radar_threshold","Zis01p Radar Threshold","zis01pPirThreshold","pirThreshold","pir_threshold","Zis01p Pir Threshold","motion_detection_mode","motionDetectionMode","supportedMotionDetectionModes","Motion detection mode","only_pir","pir_and_radar","pir_or_radar","only_radar","radar_switch","radarSwitch","Radar switch","on","off","zf24Function","radarFunction","state","Zf24Function","zf24LivingRoom","livingRoom","living_room","Zf24Living Room","zf24Bedroom","bedroom","Zf24Bedroom","zf24Bathroom","bathroom","Zf24Bathroom","zf24Sleep","sleep","Zf24Sleep","zg204zqIndicator","indicator","Zg204zq Indicator","zg204zqTemperatureUnit","temperatureUnit","temperature_unit","Zg204zq Temperature Unit","celsius","fahrenheit","zis01pRadarSwitch","Zis01p Radar Switch","ON","OFF","zis01pLedSwitch","ledSwitch","led_switch","Zis01p Led Switch","zg204zkIndicator","Zg204zk Indicator","zg204zkAntiInterference","antiInterference","anti_interference","Zg204zk Anti Interference","zg204zmIndicator","Zg204zm Indicator","zg204zmMotionState","motionState","motion_state","Zg204zm Motion State","none","large","small","static","zg204zmMotionDetectionMode","Zg204zm Motion Detection Mode","zg204zvIndicator","Zg204zv Indicator","zg204zvTemperatureUnit","Zg204zv Temperature Unit","zg204zeIndicator","Zg204ze Indicator","zg204zhIndicator","Zg204zh Indicator","zg204zhTemperatureUnit","Zg204zh Temperature Unit","zg204zhMotionState","Zg204zh Motion State","zg204zhMotionDetectionMode","Zg204zh Motion Detection Mode","zf24RadarSwitch","Zf24Radar Switch","zd24MotionState","Zd24Motion State","zd24Init","init","Zd24Init","zd24MotionDetectionMode","Zd24Motion Detection Mode","zym100lSelfTest","selfTest","self_test","Zym100l Self Test","checking","check_success","check_failure","others","comm_fault","radar_fault","last_power_response_time","lastPowerResponseTime","Last power response time"}
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
custom_capabilities.numeric=build({{1,1,2,2,3,nil,nil,1,4,{0,10,1,nil,nil,1,nil},nil,10,nil},{5,5,6,6,7,nil,nil,5,8,{0,20,1,nil,nil,2,nil},nil,100,nil},{9,9,10,10,11,nil,nil,9,12,{0,20,1,nil,nil,3,nil},nil,100,nil},{13,13,14,14,15,nil,nil,13,16,{0,10,1,nil,nil,4,nil},nil,100,nil},{17,17,18,18,19,nil,nil,17,20,{0,10,1,nil,nil,5,nil},nil,100,nil},{22,22,23,23,24,nil,nil,22,25,{0,20,0.1,21,nil,6,nil},nil,100,nil},{27,27,28,28,29,nil,nil,27,30,{0,3600,1,26,nil,7,nil},nil,3600,nil},{31,31,32,32,33,nil,nil,31,34,{0,20,0.1,21,nil,8,nil},nil,20,nil},{35,35,36,36,37,nil,nil,35,38,{0,300,1,26,nil,9,nil},nil,300,nil},{39,39,40,40,41,nil,nil,39,42,{0,20,0.1,21,nil,10,nil},nil,20,nil},{43,nil,43,44,nil,nil,nil,1,45,{0,9,1,nil,nil,11,nil},nil,nil,nil},{46,nil,46,47,nil,nil,nil,22,48,{0,9.5,0.15,21,nil,12,nil},nil,nil,21},{49,nil,49,50,nil,nil,nil,31,51,{0,9.5,0.15,21,nil,13,nil},nil,nil,21},{52,nil,52,53,nil,nil,nil,27,54,{0,10,0.1,26,nil,14,nil},nil,nil,26},{55,nil,55,56,nil,nil,nil,35,57,{0,1500,1,26,nil,15,nil},nil,nil,26},{58,nil,58,59,nil,0,0,39,60,{0,9.5,0.01,21,nil,16,nil},nil,nil,21},{61,nil,61,62,nil,nil,nil,63,64,{0,28800,1,26,nil,17,nil},nil,nil,26},{66,nil,66,67,nil,nil,nil,68,69,{-30,30,1,65,nil,18,nil},nil,nil,65},{71,nil,71,72,nil,nil,nil,73,74,{-2,2,0.1,70,nil,19,nil},nil,nil,70},{76,nil,76,77,nil,nil,nil,78,79,{1,720,1,75,nil,20,nil},nil,nil,75},{80,nil,80,81,nil,nil,nil,82,83,{1,3,1,nil,nil,21,nil},nil,nil,nil},{84,nil,84,2,nil,nil,nil,1,85,{1,3,1,nil,nil,22,nil},nil,nil,nil},{86,nil,86,87,nil,nil,nil,88,89,{1,3,1,nil,nil,23,nil},nil,nil,nil},{90,nil,90,91,nil,nil,nil,92,93,{10,9600,1,26,nil,24,nil},nil,nil,26},{94,nil,94,95,nil,nil,nil,96,97,{0,9,1,nil,nil,25,nil},nil,nil,nil},{98,nil,98,23,nil,nil,nil,22,99,{0,9.5,0.15,21,nil,26,nil},nil,nil,21},{100,nil,100,101,nil,nil,nil,102,103,{0,9.5,0.15,21,nil,27,nil},nil,nil,21},{104,nil,104,105,nil,0,0,106,107,{0,10,0.01,21,nil,28,nil},nil,nil,21},{108,nil,108,28,nil,nil,nil,27,109,{0,10,0.1,26,nil,29,nil},nil,nil,26},{110,nil,110,62,nil,nil,nil,63,111,{0.5,1500,1,26,nil,30,nil},nil,nil,26},{112,nil,112,95,nil,nil,nil,96,113,{0,9,1,nil,nil,31,nil},nil,nil,nil},{114,nil,114,23,nil,nil,nil,22,115,{0,9.5,0.15,21,nil,32,nil},nil,nil,21},{116,nil,116,101,nil,nil,nil,102,117,{0,9.5,0.15,21,nil,33,nil},nil,nil,21},{118,nil,118,105,nil,0,0,106,119,{0,10,0.01,21,nil,34,nil},nil,nil,21},{120,nil,120,28,nil,nil,nil,27,121,{0,10,0.1,26,nil,35,nil},nil,nil,26},{122,nil,122,62,nil,nil,nil,63,123,{0.5,1500,1,26,nil,36,nil},nil,nil,26},{124,nil,124,62,nil,nil,nil,63,125,{10,28800,1,26,nil,37,nil},nil,nil,26},{126,nil,126,127,nil,nil,nil,128,129,{0,5,0.01,21,nil,38,nil},nil,nil,21},{130,nil,130,6,nil,nil,nil,5,131,{0,10,1,nil,nil,39,nil},nil,nil,nil},{132,nil,132,10,nil,nil,nil,9,133,{0,10,1,nil,nil,40,nil},nil,nil,nil},{134,nil,134,62,nil,nil,nil,63,135,{0,28800,1,26,nil,41,nil},nil,nil,26},{136,nil,136,137,nil,nil,nil,138,139,{0,6,0.01,21,nil,42,nil},nil,nil,21},{140,nil,140,6,nil,nil,nil,5,141,{0,10,1,nil,nil,43,nil},nil,nil,nil},{142,nil,142,10,nil,nil,nil,9,143,{0,10,1,nil,nil,44,nil},nil,nil,nil},{144,nil,144,62,nil,nil,nil,63,145,{0,28800,1,26,nil,45,nil},nil,nil,26},{146,nil,146,10,nil,nil,nil,9,147,{0,19,1,nil,nil,46,nil},nil,nil,nil},{148,nil,148,77,nil,nil,nil,78,149,{1,720,1,75,nil,47,nil},nil,nil,75},{150,nil,150,72,nil,nil,nil,73,151,{-10,10,0.1,70,nil,48,nil},nil,nil,70},{152,nil,152,67,nil,nil,nil,68,153,{-50,50,1,65,nil,49,nil},nil,nil,65},{154,nil,154,62,nil,nil,nil,63,155,{0,28800,1,26,nil,50,nil},nil,nil,26},{156,nil,156,10,nil,nil,nil,9,157,{0,19,1,nil,nil,51,nil},nil,nil,nil},{158,nil,158,77,nil,nil,nil,78,159,{1,720,1,75,nil,52,nil},nil,nil,75},{160,nil,160,62,nil,nil,nil,63,161,{0,28800,1,26,nil,53,nil},nil,nil,26},{162,nil,162,137,nil,nil,nil,138,163,{0,5,0.01,21,nil,54,nil},nil,nil,21},{164,nil,164,6,nil,nil,nil,5,165,{0,10,1,nil,nil,55,nil},nil,nil,nil},{166,nil,166,10,nil,nil,nil,9,167,{0,10,1,nil,nil,56,nil},nil,nil,nil},{168,nil,168,77,nil,nil,nil,78,169,{1,720,1,75,nil,57,nil},nil,nil,75},{170,nil,170,72,nil,nil,nil,73,171,{-10,10,0.1,70,nil,58,nil},nil,nil,70},{172,nil,172,67,nil,nil,nil,68,173,{-50,50,1,65,nil,59,nil},nil,nil,65},{174,nil,174,14,nil,nil,nil,13,175,{1,10,1,nil,nil,60,nil},nil,nil,nil},{176,nil,176,2,nil,nil,nil,1,177,{1,10,1,nil,nil,61,nil},nil,nil,nil},{178,nil,178,179,nil,nil,nil,180,181,{1,600,1,26,nil,62,nil},nil,nil,26},{182,nil,182,183,nil,nil,nil,184,185,{0.75,9.0,0.75,21,nil,63,nil},nil,nil,21},{186,nil,186,187,nil,0,0,187,188,{0,10,0.01,21,nil,64,nil},nil,nil,21},{189,nil,189,179,nil,nil,nil,180,190,{0,180,1,26,nil,65,nil},nil,nil,26},{191,nil,191,14,nil,nil,nil,13,192,{0,10,1,nil,nil,66,nil},nil,nil,nil},{194,nil,194,195,nil,nil,nil,196,197,{0,600,10,193,nil,67,nil},nil,nil,193},{198,nil,198,199,nil,nil,nil,200,201,{0,600,10,193,nil,68,nil},nil,nil,193},{202,nil,202,18,nil,nil,nil,17,203,{0,10,1,nil,nil,69,nil},nil,nil,nil},{204,nil,204,205,nil,nil,nil,206,207,{0,600,10,193,nil,70,nil},nil,nil,193},{208,nil,208,209,nil,nil,nil,210,211,{0,600,10,193,nil,71,nil},nil,nil,193},{212,nil,212,187,nil,0,0,187,213,{0,10,0.01,21,nil,72,nil},nil,nil,21},{214,nil,214,62,nil,nil,nil,63,215,{10,3600,1,26,nil,73,nil},nil,nil,26},{216,nil,216,10,nil,nil,nil,9,217,{1,10,1,nil,nil,74,nil},nil,nil,nil},{218,nil,218,6,nil,nil,nil,5,219,{1,10,1,nil,nil,75,nil},nil,nil,nil},{220,nil,220,221,nil,nil,nil,222,223,{5,255,1,nil,nil,76,nil},nil,nil,nil},{224,nil,224,225,nil,nil,nil,226,227,{1,250,1,nil,nil,77,nil},nil,nil,nil}},numeric)
custom_capabilities.enum=build({{228,228,229,229,230,nil,nil,228,231,{232,233,234,235},{232,233,234,235},78,79,78},{236,236,237,237,nil,nil,nil,236,238,{239,240},{239,240},80,81,80},{241,nil,241,242,nil,nil,nil,243,244,{239,240},{239,240},82,83,82},{245,nil,245,246,nil,nil,nil,247,248,{239,240},{239,240},84,85,84},{249,nil,249,250,nil,nil,nil,250,251,{239,240},{239,240},86,87,86},{252,nil,252,253,nil,nil,nil,253,254,{239,240},{239,240},88,89,88},{255,nil,255,256,nil,nil,nil,256,257,{239,240},{239,240},90,91,90},{258,nil,258,259,nil,nil,nil,259,260,{240,239},{240,239},92,93,92},{261,nil,261,262,nil,nil,nil,263,264,{265,266},{265,266},94,95,94},{267,nil,267,237,nil,nil,nil,236,268,{269,270},{269,270},96,97,96},{271,nil,271,272,nil,nil,nil,273,274,{269,270},{269,270},98,99,98},{275,nil,275,259,nil,nil,nil,259,276,{240,239},{240,239},100,101,100},{277,nil,277,278,nil,nil,nil,279,280,{240,239},{240,239},102,103,102},{281,nil,281,259,nil,nil,nil,259,282,{240,239},{240,239},104,105,104},{283,nil,283,284,nil,0,0,285,286,{287,288,289,290},{287,288,289,290},106,107,106},{291,nil,291,229,nil,nil,nil,228,292,{232,233,235},{232,233,235},108,109,108},{293,nil,293,259,nil,nil,nil,259,294,{240,239},{240,239},110,111,110},{295,nil,295,262,nil,nil,nil,263,296,{265,266},{265,266},112,113,112},{297,nil,297,259,nil,nil,nil,259,298,{240,239},{240,239},114,115,114},{299,nil,299,259,nil,nil,nil,259,300,{240,239},{240,239},116,117,116},{301,nil,301,262,nil,nil,nil,263,302,{265,266},{265,266},118,119,118},{303,nil,303,284,nil,0,0,285,304,{287,288,289,290},{287,288,289,290},120,121,120},{305,nil,305,229,nil,nil,nil,228,306,{233,234,235},{233,234,235},122,123,122},{307,nil,307,237,nil,nil,nil,236,308,{240,239},{240,239},124,125,124},{309,nil,309,284,nil,0,0,285,310,{287,290,289,288},{287,290,289,288},126,127,126},{311,nil,311,312,nil,nil,nil,312,313,{240,239},{240,239},128,129,128},{314,nil,314,229,nil,nil,nil,228,315,{233,235,234},{233,235,234},130,131,130},{316,nil,316,317,nil,0,0,318,319,{320,321,322,323,324,325},{320,321,322,323,324,325},132,133,132}},enum)
custom_capabilities.text=build({{326,327,327,0,0,nil,328,64}},text)
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
