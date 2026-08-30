local custom_capabilities={}
local strings={"presence_sensitivity","presenceSensitivity","presenceSensitivityRange","Presence sensitivity","static_detection_sensitivity","staticDetectionSensitivity","staticDetectionSensitivityRange","Static detection sensitivity","motion_detection_sensitivity","motionDetectionSensitivity","motionDetectionSensitivityRange","Motion detection sensitivity","move_sensitivity","moveSensitivity","moveSensitivityRange","Move sensitivity","keep_sensitivity","keepSensitivity","keepSensitivityRange","Keep sensitivity","trigger_sensitivity","triggerSensitivity","triggerSensitivityRange","Trigger sensitivity","entry_sensitivity","entrySensitivity","entrySensitivityRange","Entry sensitivity","fall_sensitivity","fallSensitivity","fallSensitivityRange","Fall sensitivity","min","tumble_alarm_time","tumbleAlarmTime","tumbleAlarmTimeRange","Tumble alarm time","large_motion_detection_sensitivity","largeMotionDetectionSensitivity","largeMotionDetectionSensitivityRange","Large motion detection sensitivity","medium_motion_detection_sensitivity","mediumMotionSensitivity","mediumMotionDetectionSensitivity","mediumMotionDetectionSensitivityRange","Medium motion detection sensitivity","small_motion_detection_sensitivity","smallMotionDetectionSensitivity","smallMotionDetectionSensitivityRange","Small motion detection sensitivity","small_move_sensitivity","smallMoveSensitivity","smallMoveSensitivityRange","Small move sensitivity","breath_sensitivity","breathSensitivity","breathSensitivityRange","Breath sensitivity","m","large_motion_detection_distance","largeMotionDetectionDistance","largeMotionDetectionDistanceRange","Large motion detection distance","medium_motion_detection_distance","mediumMotionDetectionDistance","mediumMotionDetectionDistanceRange","Medium motion detection distance","small_motion_detection_distance","smallMotionDetectionDistance","smallMotionDetectionDistanceRange","Small motion detection distance","move_detection_max_distance","moveDetectionMaxDistance","moveDetectionMaxDistanceRange","Move detection max distance","move_detection_min_distance","moveDetectionMinDistance","moveDetectionMinDistanceRange","Move detection min distance","small_move_detection_max_distance","smallMoveDetectionMaxDistance","smallMoveDetectionMaxDistanceRange","Small move detection max distance","small_move_detection_min_distance","smallMoveDetectionMinDistance","smallMoveDetectionMinDistanceRange","Small move detection min distance","breath_detection_max_distance","breathDetectionMaxDistance","breathDetectionMaxDistanceRange","Breath detection max distance","breath_detection_min_distance","breathDetectionMinDistance","breathDetectionMinDistanceRange","Breath detection min distance","minimum_range","minimumRange","minimumRangeRange","Minimum range","s","detection_delay","detectionDelay","detectionDelayRange","Detection delay","keep_time","keepTime","keepTimeRange","Keep time","lux","illuminance_threshold_min","illuminanceThresholdMin","illuminanceThresholdMinRange","Minimum illuminance threshold","shield_range","shieldRange","shieldRangeRange","Shield range","entry_filter_time","entryFilterTime","entryFilterTimeRange","Entry filter time","entry_distance_indentation","entryDistanceIndentation","entryDistanceIndentationRange","Entry distance indentation","block_time","blockTime","blockTimeRange","Block time","presence_time","presenceTime","presenceTimeRange","Presence time","presence_delay","presenceDelay","presenceDelayRange","Presence delay","detection_cycle","detectionCycle","detectionCycleRange","Detection cycle","presence_detection_range","presenceDetectionRange","presenceDetectionRangeRange","Presence detection range","presence_fading_time","detectionHoldTime","detectionHoldTimeRange","Detection hold time","presence_target_distance","presenceTargetDistance","presenceTargetDistanceRange","Presence target distance","presence_illuminance_threshold","presenceIlluminanceThreshold","presenceIlluminanceThresholdRange","Presence illuminance threshold","zg204zlIlluminanceInterval","illuminanceInterval","illuminance_interval","Zg204zl Illuminance Interval","tre6haifAlarmTime","alarmTime","alarm_time","Tre6haif Alarm Time","auin8mzrVacancyDelay","vacancyDelay","vacancy_delay","Auin8mzr Vacancy Delay","auin8mzrVacantConfirmTime","vacantConfirmTime","vacant_confirm_time","Auin8mzr Vacant Confirm Time","auin8mzrReferenceLuminance","referenceLuminance","reference_luminance","Auin8mzr Reference Luminance","auin8mzrLightOnLuminance","lightOnLuminance","light_on_luminance_prefer","Auin8mzr Light On Luminance","auin8mzrLightOffLuminance","lightOffLuminance","light_off_luminance_prefer","Auin8mzr Light Off Luminance","auin8mzrLuminanceLevel","luminanceLevel","luminance_level","Auin8mzr Luminance Level","seq9cm6uIntervalTime","intervalTime","interval_time","Seq9cm6u Interval Time","szlm04uFadingTime","fadingTime","fading_time","Szlm04u Fading Time","light_switch","lightSwitch","Light switch","on","off","presence_illuminance_switch","presenceIlluminanceSwitch","Presence illuminance switch","light_linkage","lightLinkage","Light linkage","breaker_mode","breakerMode","supportedBreakerModes","Breaker mode","standard","local","breaker_status","breakerStatus","Breaker status","sensor_state_mode","sensorStateMode","supportedSensorStateModes","Sensor state mode","occupied","unoccupied","status_indication","statusIndication","Status indication","motion_detection_mode","motionDetectionMode","supportedMotionDetectionModes","Motion detection mode","only_pir","pir_and_radar","pir_or_radar","only_radar","radar_scene","radarScene","supportedRadarScenes","Radar scene","default","area","toilet","bedroom","parlour","office","hotel","bathroom","sleeping","unknown","detection_method","detectionMethod","supportedDetectionMethods","Detection method","only_move","exist_move","radar_switch","radarSwitch","Radar switch","tumble_switch","tumbleSwitch","Tumble switch","zg204zlSensitivity","sensitivity","Zg204zl Sensitivity","low","medium","high","zg204zlKeepTime","Zg204zl Keep Time","10","30","60","120","tre6haifPirSensitivity","pirSensitivity","pir_sensitivity","Tre6haif Pir Sensitivity","tre6haifAlarmMode","alarmMode","alarm_mode","Tre6haif Alarm Mode","arm","silent","disarm","auin8mzrVSensitivity","vSensitivity","v_sensitivity","Auin8mzr VSensitivity","speed_priority","normal_priority","accuracy_priority","auin8mzrOSensitivity","oSensitivity","o_sensitivity","Auin8mzr OSensitivity","sensitive","normal","cautious","auin8mzrMode","mode","Auin8mzr Mode","general_model","temporaty_stay","basic_detection","sensor_test","auin8mzrLedStatus","ledStatus","led_status","Auin8mzr Led Status","ON","OFF","seq9cm6uSensitivity","Seq9cm6u Sensitivity","middle","seq9cm6uWorkState","workState","work_state","Seq9cm6u Work State","presence","none","presence_5min","presence_30min","none_5min","none_30min","szlm04uUsbPower","usbPower","usb_power","Szlm04u Usb Power","szlm04uSensorSwitch","sensorSwitch","switch","Szlm04u Sensor Switch","ay204zSensitivity","Ay204z Sensitivity","ay204zKeepTime","Ay204z Keep Time","last_power_response_time","lastPowerResponseTime","Last power response time"}
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
custom_capabilities.numeric=build({{1,1,2,2,3,nil,nil,1,4,{0,10,1,nil,nil,1,nil},nil,10,nil},{5,5,6,6,7,nil,nil,5,8,{0,20,1,nil,nil,2,nil},nil,100,nil},{9,9,10,10,11,nil,nil,9,12,{0,20,1,nil,nil,3,nil},nil,100,nil},{13,13,14,14,15,nil,nil,13,16,{0,10,1,nil,nil,4,nil},nil,100,nil},{17,17,18,18,19,nil,nil,17,20,{0,10,1,nil,nil,5,nil},nil,100,nil},{21,21,22,22,23,nil,nil,21,24,{0,20,1,nil,nil,6,nil},nil,100,nil},{25,25,26,26,27,nil,nil,25,28,{0,9,1,nil,nil,7,nil},nil,100,nil},{29,29,30,30,31,nil,nil,29,32,{1,10,1,nil,nil,8,nil},nil,100,nil},{34,34,35,35,36,nil,nil,34,37,{1,5,1,33,nil,9,nil},nil,600,33},{38,38,39,39,40,nil,nil,38,41,{0,10,1,nil,nil,10,nil},nil,100,nil},{42,42,43,44,45,nil,nil,42,46,{0,10,1,nil,nil,11,nil},nil,100,nil},{47,47,48,48,49,nil,nil,47,50,{0,10,1,nil,nil,12,nil},nil,100,nil},{51,51,52,52,53,nil,nil,51,54,{0,10,1,nil,nil,13,nil},nil,100,nil},{55,55,56,56,57,nil,nil,55,58,{0,10,1,nil,nil,14,nil},nil,100,nil},{60,60,61,61,62,nil,nil,60,63,{0,10,0.01,59,nil,15,nil},nil,100,59},{64,64,65,65,66,nil,nil,64,67,{0,6,0.01,59,nil,16,nil},nil,100,59},{68,68,69,69,70,nil,nil,68,71,{0,6,0.01,59,nil,17,nil},nil,100,59},{72,72,73,73,74,nil,nil,72,75,{0,10,0.01,59,nil,18,nil},nil,100,59},{76,76,77,77,78,nil,nil,76,79,{0,10,0.01,59,nil,19,nil},nil,100,59},{80,80,81,81,82,nil,nil,80,83,{0,6,0.01,59,nil,20,nil},nil,100,59},{84,84,85,85,86,nil,nil,84,87,{0,6,0.01,59,nil,21,nil},nil,100,59},{88,88,89,89,90,nil,nil,88,91,{0,6,0.01,59,nil,22,nil},nil,100,59},{92,92,93,93,94,nil,nil,92,95,{0,6,0.01,59,nil,23,nil},nil,100,59},{96,96,97,97,98,nil,nil,96,99,{0,20,0.1,59,nil,24,nil},nil,100,nil},{101,101,102,102,103,nil,nil,101,104,{0,3600,1,100,nil,25,nil},nil,3600,nil},{105,105,106,106,107,nil,nil,105,108,{0,3600,1,100,nil,26,nil},nil,3600,nil},{110,110,111,111,112,nil,nil,110,113,{0,20000,1,109,nil,27,nil},nil,20000,nil},{114,114,115,115,116,nil,nil,114,117,{0,20,0.1,59,nil,28,nil},nil,100,nil},{118,118,119,119,120,nil,nil,118,121,{0,3600,1,100,nil,29,nil},nil,3600,nil},{122,122,123,123,124,nil,nil,122,125,{0,20,0.01,59,nil,30,nil},nil,100,nil},{126,126,127,127,128,nil,nil,126,129,{0,3600,1,100,nil,31,nil},nil,3600,nil},{130,130,131,131,132,nil,nil,130,133,{0,3600,1,100,nil,32,nil},nil,3600,nil},{134,134,135,135,136,nil,nil,134,137,{0,3600,1,100,nil,33,nil},nil,3600,nil},{138,138,139,139,140,nil,nil,138,141,{0,3600,1,100,nil,34,nil},nil,3600,nil},{142,142,143,143,144,nil,nil,142,145,{0,20,0.1,59,nil,35,nil},nil,20,nil},{146,146,147,147,148,nil,nil,146,149,{0,300,1,100,nil,36,nil},nil,300,nil},{150,150,151,151,152,nil,nil,150,153,{0,20,0.1,59,nil,37,nil},nil,20,nil},{154,154,155,155,156,nil,nil,154,157,{0,20000,1,109,nil,38,nil},nil,20000,nil},{158,nil,158,159,nil,nil,nil,160,161,{1,720,1,33,nil,39,nil},nil,nil,33},{162,nil,162,163,nil,nil,nil,164,165,{1,180,1,100,nil,40,nil},nil,nil,100},{166,nil,166,167,nil,nil,nil,168,169,{0,1000,1,100,nil,41,nil},nil,nil,100},{170,nil,170,171,nil,0,0,172,173,{nil,nil,nil,nil,nil,42,nil},nil,nil,nil},{174,nil,174,175,nil,0,0,176,177,{nil,nil,nil,nil,nil,43,nil},nil,nil,nil},{178,nil,178,179,nil,nil,nil,180,181,{0,10000,1,nil,nil,44,nil},nil,nil,nil},{182,nil,182,183,nil,nil,nil,184,185,{0,10000,1,nil,nil,45,nil},nil,nil,nil},{186,nil,186,187,nil,0,0,188,189,{nil,nil,nil,nil,nil,46,nil},nil,nil,nil},{190,nil,190,191,nil,nil,nil,192,193,{5,720,5,33,nil,47,nil},nil,nil,33},{194,nil,194,195,nil,nil,nil,196,197,{5,300,1,100,nil,48,nil},nil,nil,100}},numeric)
custom_capabilities.enum=build({{198,198,199,199,nil,nil,nil,198,200,{201,202},{201,202},49,50,49},{203,203,204,204,nil,nil,nil,203,205,{201,202},{201,202},49,51,49},{206,206,207,207,nil,nil,nil,206,208,{201,202},{201,202},49,52,49},{209,209,210,210,211,nil,nil,209,212,{213,214},{213,214},53,54,53},{215,215,216,216,nil,nil,nil,215,217,{201,202},{201,202},49,55,49},{218,218,219,219,220,nil,nil,218,221,{201,202,222,223},{201,202,222,223},56,57,56},{224,224,225,225,nil,nil,nil,224,226,{201,202},{201,202},49,58,49},{227,227,228,228,229,nil,nil,227,230,{231,232,233,234},{231,232,233,234},59,60,59},{235,235,236,236,237,nil,nil,235,238,{239,240,241,242,243,244,245,246,247,248},{239,240,241,242,243,244,245,246,247,248},61,62,61},{249,249,250,250,251,nil,nil,249,252,{253,254},{253,254},63,64,63},{255,255,256,256,nil,nil,nil,255,257,{201,202},{201,202},49,65,49},{258,258,259,259,nil,nil,nil,258,260,{201,202},{201,202},49,66,49},{261,nil,261,262,nil,nil,nil,262,263,{264,265,266},{264,265,266},67,68,67},{267,nil,267,106,nil,nil,nil,105,268,{269,270,271,272},{269,270,271,272},69,70,69},{273,nil,273,274,nil,nil,nil,275,276,{266,264},{266,264},71,72,71},{277,nil,277,278,nil,nil,nil,279,280,{281,282,283},{281,282,283},73,74,73},{284,nil,284,285,nil,nil,nil,286,287,{288,289,290},{288,289,290},75,76,75},{291,nil,291,292,nil,nil,nil,293,294,{295,296,297},{295,296,297},77,78,77},{298,nil,298,299,nil,nil,nil,299,300,{301,302,303,304},{301,302,303,304},79,80,79},{305,nil,305,306,nil,nil,nil,307,308,{309,310},{309,310},81,82,81},{311,nil,311,262,nil,nil,nil,262,312,{264,313,266},{264,313,266},83,84,83},{314,nil,314,315,nil,0,0,316,317,{318,319,320,321,322,323},{318,319,320,321,322,323},85,86,85},{324,nil,324,325,nil,0,0,326,327,{309,310},{309,310},87,88,87},{328,nil,328,329,nil,0,0,330,331,{309,310},{309,310},89,90,89},{332,nil,332,262,nil,nil,nil,262,333,{264,265,266},{264,265,266},91,92,91},{334,nil,334,106,nil,nil,nil,105,335,{269,270,271,272},{269,270,271,272},93,94,93}},enum)
custom_capabilities.text=build({{336,337,337,0,0,nil,338,64}},text)
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
