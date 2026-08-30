local custom_capabilities={}
local strings={"%","coverPositionReportRm28Le","coverPositionReportRmTwoEightLe","position_report","Cover Position Report Rm28Le","coverPositionReportZm79eDt","coverPositionReportZmSevenNineeDt","Cover Position Report Zm79e Dt","coverPositionReportBx82Tyz1","coverPositionReportBxEightTwoTyzOne","Cover Position Report Bx82Tyz1","favoritePositionZbSm","favorite_position","Favorite Position Zb Sm","zsm01PositionBest","positionBest","position_best","Zsm01Position Best","ms","zbSmCycleTime","cycleTime","cycle_time","Zb Sm Cycle Time","zbSmCycleCount","cycleCount","cycle_count","Zb Sm Cycle Count","mW","zbSmActivePower","activePower","active_power","Zb Sm Active Power","s","pims3028TimeTotal","timeTotal","time_total","Pims3028Time Total","pims3028PositionBest","Pims3028Position Best","°","pims3028AngleHorizontal","angleHorizontal","angle_horizontal","Pims3028Angle Horizontal","pims3028QuickCalibration","quickCalibration","quick_calibration","Pims3028Quick Calibration","rm28leCountdownLeft","countdownLeft","countdown_left","Rm28le Countdown Left","rm28leTimeTotal","Rm28le Time Total","rm28lePositionBest","Rm28le Position Best","coverOneMotorSpeed","motorSpeed","motor_speed","Cover One Motor Speed","switch_type","switchType","supportedSwitchTypes","Switch type","toggle","state","momentary","tiltModeMb60l","tiltModeMbSixZerol","tilt_mode","Tilt Mode Mb60l","off","on","manualModeEpjZbEnableDisable","manual_mode","Manual Mode Epj Zb Enable Disable","enable","disable","windowDetectionEpjZbState","window_detection","Window Detection Epj Zb State","opened","closed","pending","motorDirectionZbSmNormalRev","motor_direction","Motor Direction Zb Sm Normal Rev","normal","reversed","motorDirectionZm79eDtLeftRight","caprayirlspeprfrwwysgxh","Motor Direction Zm79e Dt Left Right","left","right","motorDirectionBxTyzNormalRev","capnfcnnbmfkahvrbckxcij","Motor Direction Bx Tyz Normal Rev","motorDirectionMbNormalRev","capultkjbczgdpnaciiuoqx","Motor Direction Mb Normal Rev","motorDirectionEpjZbSide","Motor Direction Epj Zb Side","left_side","right_side","coverWorkPimsActual","capcpcfsvmnkqqvbyfklqpl","work_state","Cover Work Pims Actual","opening","closing","value_123","coverWorkRmOpeningClosing","capmtldrdyfbzxvbdlnhcgl","Cover Work Rm Opening Closing","coverWorkStateZm79eDtLearning","coverWorkStateZmSevenNineeDtLearning","Cover Work State Zm79e Dt Learning","standby","success","learning","coverCalibrationPims3028StartEnd","capvonpjrddxpdpephlodgy","calibration","Cover Calibration Pims3028Start End","start","end","zsm01ControlBackMode","controlBackMode","control_back_mode","Zsm01Control Back Mode","forward","back","zsm01ClickControl","clickControl","click_control","Zsm01Click Control","up","down","zbSmMotorState","motorState","motor_state","Zb Sm Motor State","stopped","zbSmTopLimit","topLimit","top_limit","Zb Sm Top Limit","set","clear","zbSmBottomLimit","bottomLimit","bottom_limit","Zb Sm Bottom Limit","pims3028Mode","mode","Pims3028Mode","up_delete","remove_up_down","pims3028ControlBack","controlBack","control_back","Pims3028Control Back","pims3028AutoPower","autoPower","auto_power","Pims3028Auto Power","pims3028SituationSet","situationSet","situation_set","Pims3028Situation Set","fully_open","fully_close","pims3028Fault","fault","Pims3028Fault","pims3028Border","border","Pims3028Border","down_delete","remove_top_bottom","pims3028BestTrigger","bestTrigger","best_position_trigger","Pims3028Best Trigger","pims3028Reset","reset","Pims3028Reset","rm28leMode","Rm28le Mode","morning","night","rm28leAutoPower","Rm28le Auto Power","rm28leCountdown","countdown","Rm28le Countdown","cancel","1h","2h","3h","4h","rm28leSituationSet","Rm28le Situation Set","rm28leMotorFault","motorFault","motor_fault","Rm28le Motor Fault","rm28leBorder","Rm28le Border","rm28leClickControl","Rm28le Click Control","coverThreeReverseDirection","reverseDirection","reverse_direction","Cover Three Reverse Direction","coverThreeLimit","coverLimit","cover_limit","Cover Three Limit","set_up","set_down","delete_up","delete_down","delete_both","coverThreeClickControl","Cover Three Click Control","coverThreeMotorFault","Cover Three Motor Fault","coverOneReverseDirection","Cover One Reverse Direction","zm79eOpeningMode","openingMode","opening_mode","Zm79e Opening Mode","tilt","lift","zm79eSetUpperLimit","setUpperLimit","set_upper_limit","Zm79e Set Upper Limit","stop","zm79eFactoryReset","factoryReset","factory_reset","Zm79e Factory Reset","mb60lSetLimits","setLimits","set_limits","Mb60l Set Limits","mb60lChildLock","childLock","child_lock","Mb60l Child Lock","trwaxi57Calibration","Trwaxi57Calibration","trwaxi57Backlight","backlight","backlight_mode","Trwaxi57Backlight","trwaxi57MotorSteering","motorSteering","motor_steering","Trwaxi57Motor Steering","backward","trwaxi57ChildLock","Trwaxi57Child Lock","last_power_response_time","lastPowerResponseTime","Last power response time","zbSmMotorType","motorType","motor_type","Zb Sm Motor Type"}
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
custom_capabilities.numeric=build({{2,nil,2,3,nil,0,0,4,5,{0,100,1,1,nil,1,nil},nil,nil,1},{6,nil,6,7,nil,0,0,4,8,{0,100,1,1,nil,2,nil},nil,nil,1},{9,nil,9,10,nil,0,0,4,11,{0,100,1,1,nil,3,nil},nil,nil,1},{12,nil,12,12,nil,nil,nil,13,14,{0,100,1,1,nil,4,nil},nil,nil,1},{15,nil,15,16,nil,nil,nil,17,18,{0,100,1,1,nil,5,nil},nil,nil,1},{20,nil,20,21,nil,0,0,22,23,{0,999999,1,19,nil,6,nil},nil,nil,19},{24,nil,24,25,nil,0,0,26,27,{0,999999,1,nil,nil,7,nil},nil,nil,nil},{29,nil,29,30,nil,0,0,31,32,{0,999999,1,28,nil,8,nil},nil,nil,28},{34,nil,34,35,nil,0,0,36,37,{0,600,1,33,nil,9,nil},nil,nil,33},{38,nil,38,16,nil,nil,nil,17,39,{1,100,1,1,nil,10,nil},nil,nil,1},{41,nil,41,42,nil,nil,nil,43,44,{0,100,25,40,nil,11,nil},nil,nil,40},{45,nil,45,46,nil,nil,nil,47,48,{0,900,1,33,nil,12,nil},nil,nil,33},{49,nil,49,50,nil,0,0,51,52,{0,86400,1,33,nil,13,nil},nil,nil,33},{53,nil,53,35,nil,0,0,36,54,{0,999999,1,19,nil,14,nil},nil,nil,19},{55,nil,55,16,nil,nil,nil,17,56,{0,100,1,1,nil,15,nil},nil,nil,1},{57,nil,57,58,nil,nil,nil,59,60,{0,255,1,nil,nil,16,nil},nil,nil,nil}},numeric)
custom_capabilities.enum=build({{61,61,62,62,63,nil,nil,61,64,{65,66,67},{65,66,67},17,18,17},{68,nil,68,69,nil,nil,nil,70,71,{72,73},{72,73},19,20,19},{74,nil,74,74,nil,nil,nil,75,76,{77,78},{77,78},21,22,21},{79,nil,79,79,nil,nil,nil,80,81,{82,83,84},{82,83,84},23,24,23},{85,nil,85,85,nil,nil,nil,86,87,{88,89},{88,89},25,26,25},{90,nil,90,91,nil,nil,nil,86,92,{93,94},{93,94},27,28,27},{95,nil,95,96,nil,nil,nil,86,97,{88,89},{88,89},29,30,29},{98,nil,98,99,nil,nil,nil,86,100,{88,89},{88,89},31,32,31},{101,nil,101,101,nil,nil,nil,86,102,{103,104},{103,104},33,34,33},{105,nil,105,106,nil,0,0,107,108,{109,110,111},{109,110,111},35,36,35},{112,nil,112,113,nil,0,0,107,114,{109,110},{109,110},37,38,37},{115,nil,115,116,nil,0,0,107,117,{118,119,120},{118,119,120},39,40,39},{121,nil,121,122,nil,nil,nil,123,124,{125,126},{125,126},41,42,41},{127,nil,127,128,nil,nil,nil,129,130,{131,132},{131,132},43,44,43},{133,nil,133,134,nil,nil,nil,135,136,{137,138},{137,138},45,46,45},{139,nil,139,140,nil,0,0,141,142,{109,143,110},{109,143,110},47,48,47},{144,nil,144,145,nil,nil,nil,146,147,{148,149},{148,149},49,50,49},{150,nil,150,151,nil,nil,nil,152,153,{148,149},{148,149},51,52,51},{154,nil,154,155,nil,nil,nil,155,156,{137,157,158},{137,157,158},53,54,53},{159,nil,159,160,nil,nil,nil,161,162,{131,132},{131,132},55,56,55},{163,nil,163,164,nil,nil,nil,165,166,{72,73},{72,73},57,58,57},{167,nil,167,168,nil,0,0,169,170,{171,172},{171,172},59,60,59},{173,nil,173,174,nil,0,0,174,175,{88,174},{88,174},61,62,61},{176,nil,176,177,nil,nil,nil,177,178,{179,180},{179,180},63,64,63},{181,nil,181,182,nil,nil,nil,183,184,{72,73},{72,73},65,66,65},{185,nil,185,186,nil,nil,nil,186,187,{186},{186},67,68,67},{188,nil,188,155,nil,nil,nil,155,189,{190,191},{190,191},69,70,69},{192,nil,192,164,nil,nil,nil,165,193,{72,73},{72,73},71,72,71},{194,nil,194,195,nil,nil,nil,195,196,{197,198,199,200,201},{197,198,199,200,201},73,74,73},{202,nil,202,168,nil,0,0,169,203,{171,172},{171,172},75,76,75},{204,nil,204,205,nil,0,0,206,207,{88,174},{88,174},77,78,77},{208,nil,208,177,nil,nil,nil,177,209,{137,138,157,179,180},{137,138,157,179,180},79,80,79},{210,nil,210,134,nil,nil,nil,135,211,{137,138},{137,138},81,82,81},{212,nil,212,213,nil,nil,nil,214,215,{131,132},{131,132},83,84,83},{216,nil,216,217,nil,nil,nil,218,219,{220,221,222,223,224},{220,221,222,223,224},85,86,85},{225,nil,225,134,nil,nil,nil,135,226,{137,138},{137,138},87,88,87},{227,nil,227,205,nil,0,0,206,228,{88,174},{88,174},89,90,89},{229,nil,229,213,nil,nil,nil,214,230,{131,132},{131,132},91,92,91},{231,nil,231,232,nil,nil,nil,233,234,{235,236},{235,236},93,94,93},{237,nil,237,238,nil,nil,nil,239,240,{125,241},{125,241},95,96,95},{242,nil,242,243,nil,nil,nil,244,245,{148},{148},97,98,97},{246,nil,246,247,nil,nil,nil,248,249,{137,138,186},{137,138,186},99,100,99},{250,nil,250,251,nil,nil,nil,252,253,{72,73},{72,73},101,102,101},{254,nil,254,123,nil,nil,nil,123,255,{125,126},{125,126},103,104,103},{256,nil,256,257,nil,nil,nil,258,259,{72,73},{72,73},105,106,105},{260,nil,260,261,nil,nil,nil,262,263,{131,264},{131,264},107,108,107},{265,nil,265,251,nil,nil,nil,252,266,{72,73},{72,73},109,110,109}},enum)
custom_capabilities.text=build({{267,268,268,0,0,nil,269,64},{270,270,271,0,0,272,273,32}},text)
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
