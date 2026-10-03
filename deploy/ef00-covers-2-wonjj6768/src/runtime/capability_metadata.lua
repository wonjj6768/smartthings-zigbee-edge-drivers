local custom_capabilities={}
local strings={"s","adcbziTotalTime","totalTime","adcbzi_total_time","Adcbzi Total Time","adcbziOpenThreshold","openThreshold","adcbzi_open_threshold","Adcbzi Open Threshold","adcbziCloseThreshold","closeThreshold","adcbzi_close_threshold","Adcbzi Close Threshold","adcbziCurtainStatus","curtainStatus","adcbzi_curtain_status","Adcbzi Curtain Status","m","adcbziTotalDistance","totalDistance","adcbzi_total_distance","Adcbzi Total Distance","adcbziFactoryTest","factoryTest","adcbzi_factory_test","Adcbzi Factory Test","%","tsCoverTwoFavoritePosition","favoritePosition","ts_cover_two_favorite_position","Ts Cover Two Favorite Position","znUscCalibrationTime","calibrationTime","zn_usc_calibration_time","Zn Usc Calibration Time","moesSfTravelTime","travelTime","moes_sf_travel_time","Moes Sf Travel Time","ms","cover14A0TotalTime","cover14_a0_total_time","Cover14A0Total Time","cover14A0FavoritePosition","cover14_a0_favorite_position","Cover14A0Favorite Position","gm25TeqMotorDirection","gmTwoFiveTeqMotorDirection","motor_direction","Gm25Teq Motor Direction","normal","reversed","adcbziWorkState","workState","adcbzi_work_state","Adcbzi Work State","standby","opening","closing","adcbziSituationSet","situationSet","adcbzi_situation_set","Adcbzi Situation Set","fully_open","fully_close","adcbziFault","fault","adcbzi_fault","Adcbzi Fault","none","adcbziChargingStatus","chargingStatus","adcbzi_charging_status","Adcbzi Charging Status","uncharged","charging","charged","adcbziCalibration","calibration","adcbzi_calibration","Adcbzi Calibration","stop","calibrate","calibrate_reverse","blTyzMotorDirection","motorDirection","bl_tyz_motor_direction","Bl Tyz Motor Direction","blTyzAutoPower","autoPower","bl_tyz_auto_power","Bl Tyz Auto Power","ON","OFF","zsSrCalibration","zs_sr_calibration","Zs Sr Calibration","START","END","zsSrMotorSteering","motorSteering","zs_sr_motor_steering","Zs Sr Motor Steering","FORWARD","BACKWARD","zcLpCharging","zc_lp_charging","Zc Lp Charging","not_charging","zcLpAutomaticMode","automaticMode","zc_lp_automatic_mode","Zc Lp Automatic Mode","zcLpSlowMode","slowMode","zc_lp_slow_mode","Zc Lp Slow Mode","zcLpButtonPosition","buttonPosition","zc_lp_button_position","Zc Lp Button Position","UP","DOWN","fwjzMotorDirection","fwjz_motor_direction","Fwjz Motor Direction","fwjzCoverLimit","coverLimit","fwjz_cover_limit","Fwjz Cover Limit","set_up","set_down","delete_up","delete_down","delete_both","tsCoverTwoMotorState","motorState","ts_cover_two_motor_state","Ts Cover Two Motor State","stopped","tsCoverTwoSlowMode","ts_cover_two_slow_mode","Ts Cover Two Slow Mode","tsCoverTwoMotorDirection","ts_cover_two_motor_direction","Ts Cover Two Motor Direction","tsCoverTwoCoverType","coverType","ts_cover_two_cover_type","Ts Cover Two Cover Type","roman_pole","roller_blind","canopy_curtain","roman_blind","honeycomb_curtain","tsCoverTwoCoverLimit","ts_cover_two_cover_limit","Ts Cover Two Cover Limit","tsCoverTwoClickControl","clickControl","ts_cover_two_click_control","Ts Cover Two Click Control","up","down","xSevenCalibration","x_seven_calibration","X Seven Calibration","start","finish","znUscMotorSteering","zn_usc_motor_steering","Zn Usc Motor Steering","zmpOneMotorState","zmp_one_motor_state","Zmp One Motor State","zmpOneMotorDirection","zmp_one_motor_direction","Zmp One Motor Direction","ercSixDirection","direction","erc_six_direction","Erc Six Direction","forward","back","ercSixRecordRf","recordRf","erc_six_record_rf","Erc Six Record Rf","record","ercSixClearRf","clearRf","erc_six_clear_rf","Erc Six Clear Rf","clear","moesSfCalibration","moes_sf_calibration","Moes Sf Calibration","end","moesSfBacklight","backlight","moes_sf_backlight","Moes Sf Backlight","on","off","moesSfDirection","moes_sf_direction","Moes Sf Direction","limitedCoverMotorDirection","limited_cover_motor_direction","Limited Cover Motor Direction","cover5PxCalibration","cover5_px_calibration","Cover5Px Calibration","cover5PxBacklight","cover5_px_backlight","Cover5Px Backlight","cover5PxMotorDirection","cover5_px_motor_direction","Cover5Px Motor Direction","cover5PxChildLock","childLock","cover5_px_child_lock","Cover5Px Child Lock","cover14A0MotorDirection","cover14_a0_motor_direction","Cover14A0Motor Direction","cover14A0MotorState","cover14_a0_motor_state","Cover14A0Motor State","cover14A0SituationSet","cover14_a0_situation_set","Cover14A0Situation Set","fwjz16ebMotorDirection","fwjz_16eb_motor_direction","Fwjz16eb Motor Direction","fwjz16ebCoverLimit","fwjz_16eb_cover_limit","Fwjz16eb Cover Limit","last_power_response_time","lastPowerResponseTime","Last power response time","adcbziCustomWeekProgOne","customWeekProgOne","adcbzi_custom_week_prog_one","Adcbzi Custom Week Prog One","adcbziCustomWeekProgTwo","customWeekProgTwo","adcbzi_custom_week_prog_two","Adcbzi Custom Week Prog Two","adcbziCustomWeekProgThree","customWeekProgThree","adcbzi_custom_week_prog_three","Adcbzi Custom Week Prog Three","adcbziCustomWeekProgFour","customWeekProgFour","adcbzi_custom_week_prog_four","Adcbzi Custom Week Prog Four"}
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
custom_capabilities.numeric=build({{2,nil,2,3,nil,0,0,4,5,{nil,nil,nil,1,nil,1,nil},nil,nil,1},{6,nil,6,7,nil,nil,nil,8,9,{0,100,1,nil,nil,2,nil},nil,nil,nil},{10,nil,10,11,nil,nil,nil,12,13,{0,100,1,nil,nil,3,nil},nil,nil,nil},{14,nil,14,15,nil,nil,nil,16,17,{0,255,1,nil,nil,4,nil},nil,nil,nil},{19,nil,19,20,nil,0,0,21,22,{nil,nil,nil,18,nil,5,nil},nil,nil,18},{23,nil,23,24,nil,0,0,25,26,{0,100,1,nil,nil,6,nil},nil,nil,nil},{28,nil,28,29,nil,nil,nil,30,31,{0,100,1,27,nil,7,nil},nil,nil,27},{32,nil,32,33,nil,nil,nil,34,35,{0,500,1,1,nil,8,nil},nil,nil,1},{36,nil,36,37,nil,nil,nil,38,39,{10,180,1,1,nil,9,nil},nil,nil,1},{41,nil,41,3,nil,0,0,42,43,{nil,nil,nil,40,nil,10,nil},nil,nil,40},{44,nil,44,29,nil,nil,nil,45,46,{0,100,1,27,nil,11,nil},nil,nil,27}},numeric)
custom_capabilities.enum=build({{47,nil,47,48,nil,nil,nil,49,50,{51,52},{51,52},12,13,12},{53,nil,53,54,nil,0,0,55,56,{57,58,59},{57,58,59},14,15,14},{60,nil,60,61,nil,nil,nil,62,63,{64,65},{64,65},16,17,16},{66,nil,66,67,nil,0,0,68,69,{70},{70},18,19,18},{71,nil,71,72,nil,0,0,73,74,{70,75,76,77},{70,75,76,77},20,21,20},{78,nil,78,79,nil,nil,nil,80,81,{82,83,84},{82,83,84},22,23,22},{85,nil,85,86,nil,nil,nil,87,88,{51,52},{51,52},24,25,24},{89,nil,89,90,nil,nil,nil,91,92,{93,94},{93,94},26,27,26},{95,nil,95,79,nil,nil,nil,96,97,{98,99},{98,99},28,29,28},{100,nil,100,101,nil,nil,nil,102,103,{104,105},{104,105},30,31,30},{106,nil,106,76,nil,0,0,107,108,{76,109},{76,109},32,33,32},{110,nil,110,111,nil,nil,nil,112,113,{93,94},{93,94},34,35,34},{114,nil,114,115,nil,nil,nil,116,117,{93,94},{93,94},36,37,36},{118,nil,118,119,nil,nil,nil,120,121,{122,123},{122,123},38,39,38},{124,nil,124,86,nil,nil,nil,125,126,{51,52},{51,52},40,41,40},{127,nil,127,128,nil,nil,nil,129,130,{131,132,133,134,135},{131,132,133,134,135},42,43,42},{136,nil,136,137,nil,0,0,138,139,{58,59,140},{58,59,140},44,45,44},{141,nil,141,115,nil,nil,nil,142,143,{93,94},{93,94},46,47,46},{144,nil,144,86,nil,nil,nil,145,146,{51,52},{51,52},48,49,48},{147,nil,147,148,nil,nil,nil,149,150,{151,152,153,154,155},{151,152,153,154,155},50,51,50},{156,nil,156,128,nil,nil,nil,157,158,{131,132,133,134,135},{131,132,133,134,135},52,53,52},{159,nil,159,160,nil,nil,nil,161,162,{163,164},{163,164},54,55,54},{165,nil,165,79,nil,nil,nil,166,167,{168,169},{168,169},56,57,56},{170,nil,170,101,nil,nil,nil,171,172,{104,105},{104,105},58,59,58},{173,nil,173,137,nil,0,0,174,175,{58,59,140},{58,59,140},60,61,60},{176,nil,176,86,nil,nil,nil,177,178,{51,52},{51,52},62,63,62},{179,nil,179,180,nil,nil,nil,181,182,{183,184},{183,184},64,65,64},{185,nil,185,186,nil,nil,nil,187,188,{189,82},{189,82},66,67,66},{190,nil,190,191,nil,nil,nil,192,193,{194,82},{194,82},68,69,68},{195,nil,195,79,nil,nil,nil,196,197,{168,198},{168,198},70,71,70},{199,nil,199,200,nil,nil,nil,201,202,{203,204},{203,204},72,73,72},{205,nil,205,86,nil,nil,nil,206,207,{51,52},{51,52},74,75,74},{208,nil,208,86,nil,nil,nil,209,210,{51,52},{51,52},76,77,76},{211,nil,211,79,nil,nil,nil,212,213,{98,99},{98,99},78,79,78},{214,nil,214,200,nil,nil,nil,215,216,{93,94},{93,94},80,81,80},{217,nil,217,86,nil,nil,nil,218,219,{51,52},{51,52},82,83,82},{220,nil,220,221,nil,nil,nil,222,223,{93,94},{93,94},84,85,84},{224,nil,224,86,nil,nil,nil,225,226,{51,52},{51,52},86,87,86},{227,nil,227,137,nil,0,0,228,229,{58,59,140},{58,59,140},88,89,88},{230,nil,230,61,nil,nil,nil,231,232,{65,64},{65,64},90,91,90},{233,nil,233,86,nil,nil,nil,234,235,{51,52},{51,52},92,93,92},{236,nil,236,128,nil,nil,nil,237,238,{131,132,133,134},{131,132,133,134},94,95,94}},enum)
custom_capabilities.text=build({{239,240,240,0,0,nil,241,64},{242,242,243,nil,nil,244,245,512},{246,246,247,nil,nil,248,249,512},{250,250,251,nil,nil,252,253,512},{254,254,255,nil,nil,256,257,512}},text)
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
