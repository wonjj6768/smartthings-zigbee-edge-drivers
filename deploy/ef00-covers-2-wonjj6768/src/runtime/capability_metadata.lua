local custom_capabilities={}
local strings={"s","adcbziTotalTime","totalTime","adcbzi_total_time","Adcbzi Total Time","adcbziOpenThreshold","openThreshold","adcbzi_open_threshold","Adcbzi Open Threshold","adcbziCloseThreshold","closeThreshold","adcbzi_close_threshold","Adcbzi Close Threshold","adcbziCurtainStatus","curtainStatus","adcbzi_curtain_status","Adcbzi Curtain Status","m","adcbziTotalDistance","totalDistance","adcbzi_total_distance","Adcbzi Total Distance","adcbziFactoryTest","factoryTest","adcbzi_factory_test","Adcbzi Factory Test","%","tsCoverTwoFavoritePosition","favoritePosition","ts_cover_two_favorite_position","Ts Cover Two Favorite Position","znUscCalibrationTime","calibrationTime","zn_usc_calibration_time","Zn Usc Calibration Time","gm25TeqMotorDirection","gmTwoFiveTeqMotorDirection","motor_direction","Gm25Teq Motor Direction","normal","reversed","adcbziWorkState","workState","adcbzi_work_state","Adcbzi Work State","standby","opening","closing","adcbziSituationSet","situationSet","adcbzi_situation_set","Adcbzi Situation Set","fully_open","fully_close","adcbziFault","fault","adcbzi_fault","Adcbzi Fault","none","adcbziChargingStatus","chargingStatus","adcbzi_charging_status","Adcbzi Charging Status","uncharged","charging","charged","adcbziCalibration","calibration","adcbzi_calibration","Adcbzi Calibration","stop","calibrate","calibrate_reverse","blTyzMotorDirection","motorDirection","bl_tyz_motor_direction","Bl Tyz Motor Direction","blTyzAutoPower","autoPower","bl_tyz_auto_power","Bl Tyz Auto Power","ON","OFF","zsSrCalibration","zs_sr_calibration","Zs Sr Calibration","START","END","zsSrMotorSteering","motorSteering","zs_sr_motor_steering","Zs Sr Motor Steering","FORWARD","BACKWARD","zcLpCharging","zc_lp_charging","Zc Lp Charging","not_charging","zcLpAutomaticMode","automaticMode","zc_lp_automatic_mode","Zc Lp Automatic Mode","zcLpSlowMode","slowMode","zc_lp_slow_mode","Zc Lp Slow Mode","zcLpButtonPosition","buttonPosition","zc_lp_button_position","Zc Lp Button Position","UP","DOWN","fwjzMotorDirection","fwjz_motor_direction","Fwjz Motor Direction","fwjzCoverLimit","coverLimit","fwjz_cover_limit","Fwjz Cover Limit","set_up","set_down","delete_up","delete_down","delete_both","tsCoverTwoMotorState","motorState","ts_cover_two_motor_state","Ts Cover Two Motor State","stopped","tsCoverTwoSlowMode","ts_cover_two_slow_mode","Ts Cover Two Slow Mode","tsCoverTwoMotorDirection","ts_cover_two_motor_direction","Ts Cover Two Motor Direction","tsCoverTwoCoverType","coverType","ts_cover_two_cover_type","Ts Cover Two Cover Type","roman_pole","roller_blind","canopy_curtain","roman_blind","honeycomb_curtain","tsCoverTwoCoverLimit","ts_cover_two_cover_limit","Ts Cover Two Cover Limit","tsCoverTwoClickControl","clickControl","ts_cover_two_click_control","Ts Cover Two Click Control","up","down","xSevenCalibration","x_seven_calibration","X Seven Calibration","start","finish","znUscMotorSteering","zn_usc_motor_steering","Zn Usc Motor Steering","zmpOneMotorState","zmp_one_motor_state","Zmp One Motor State","zmpOneMotorDirection","zmp_one_motor_direction","Zmp One Motor Direction","ercSixDirection","direction","erc_six_direction","Erc Six Direction","forward","back","ercSixRecordRf","recordRf","erc_six_record_rf","Erc Six Record Rf","record","ercSixClearRf","clearRf","erc_six_clear_rf","Erc Six Clear Rf","clear","last_power_response_time","lastPowerResponseTime","Last power response time","adcbziCustomWeekProgOne","customWeekProgOne","adcbzi_custom_week_prog_one","Adcbzi Custom Week Prog One","adcbziCustomWeekProgTwo","customWeekProgTwo","adcbzi_custom_week_prog_two","Adcbzi Custom Week Prog Two","adcbziCustomWeekProgThree","customWeekProgThree","adcbzi_custom_week_prog_three","Adcbzi Custom Week Prog Three","adcbziCustomWeekProgFour","customWeekProgFour","adcbzi_custom_week_prog_four","Adcbzi Custom Week Prog Four"}
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
custom_capabilities.numeric=build({{2,nil,2,3,nil,0,0,4,5,{nil,nil,nil,1,nil,1,nil},nil,nil,1},{6,nil,6,7,nil,nil,nil,8,9,{0,100,1,nil,nil,2,nil},nil,nil,nil},{10,nil,10,11,nil,nil,nil,12,13,{0,100,1,nil,nil,3,nil},nil,nil,nil},{14,nil,14,15,nil,nil,nil,16,17,{0,255,1,nil,nil,4,nil},nil,nil,nil},{19,nil,19,20,nil,0,0,21,22,{nil,nil,nil,18,nil,5,nil},nil,nil,18},{23,nil,23,24,nil,0,0,25,26,{0,100,1,nil,nil,6,nil},nil,nil,nil},{28,nil,28,29,nil,nil,nil,30,31,{0,100,1,27,nil,7,nil},nil,nil,27},{32,nil,32,33,nil,nil,nil,34,35,{0,500,1,1,nil,8,nil},nil,nil,1}},numeric)
custom_capabilities.enum=build({{36,nil,36,37,nil,nil,nil,38,39,{40,41},{40,41},9,10,9},{42,nil,42,43,nil,0,0,44,45,{46,47,48},{46,47,48},11,12,11},{49,nil,49,50,nil,nil,nil,51,52,{53,54},{53,54},13,14,13},{55,nil,55,56,nil,0,0,57,58,{59},{59},15,16,15},{60,nil,60,61,nil,0,0,62,63,{59,64,65,66},{59,64,65,66},17,18,17},{67,nil,67,68,nil,nil,nil,69,70,{71,72,73},{71,72,73},19,20,19},{74,nil,74,75,nil,nil,nil,76,77,{40,41},{40,41},21,22,21},{78,nil,78,79,nil,nil,nil,80,81,{82,83},{82,83},23,24,23},{84,nil,84,68,nil,nil,nil,85,86,{87,88},{87,88},25,26,25},{89,nil,89,90,nil,nil,nil,91,92,{93,94},{93,94},27,28,27},{95,nil,95,65,nil,0,0,96,97,{65,98},{65,98},29,30,29},{99,nil,99,100,nil,nil,nil,101,102,{82,83},{82,83},31,32,31},{103,nil,103,104,nil,nil,nil,105,106,{82,83},{82,83},33,34,33},{107,nil,107,108,nil,nil,nil,109,110,{111,112},{111,112},35,36,35},{113,nil,113,75,nil,nil,nil,114,115,{40,41},{40,41},37,38,37},{116,nil,116,117,nil,nil,nil,118,119,{120,121,122,123,124},{120,121,122,123,124},39,40,39},{125,nil,125,126,nil,0,0,127,128,{47,48,129},{47,48,129},41,42,41},{130,nil,130,104,nil,nil,nil,131,132,{82,83},{82,83},43,44,43},{133,nil,133,75,nil,nil,nil,134,135,{40,41},{40,41},45,46,45},{136,nil,136,137,nil,nil,nil,138,139,{140,141,142,143,144},{140,141,142,143,144},47,48,47},{145,nil,145,117,nil,nil,nil,146,147,{120,121,122,123,124},{120,121,122,123,124},49,50,49},{148,nil,148,149,nil,nil,nil,150,151,{152,153},{152,153},51,52,51},{154,nil,154,68,nil,nil,nil,155,156,{157,158},{157,158},53,54,53},{159,nil,159,90,nil,nil,nil,160,161,{93,94},{93,94},55,56,55},{162,nil,162,126,nil,0,0,163,164,{47,48,129},{47,48,129},57,58,57},{165,nil,165,75,nil,nil,nil,166,167,{40,41},{40,41},59,60,59},{168,nil,168,169,nil,nil,nil,170,171,{172,173},{172,173},61,62,61},{174,nil,174,175,nil,nil,nil,176,177,{178,71},{178,71},63,64,63},{179,nil,179,180,nil,nil,nil,181,182,{183,71},{183,71},65,66,65}},enum)
custom_capabilities.text=build({{184,185,185,0,0,nil,186,64},{187,187,188,nil,nil,189,190,512},{191,191,192,nil,nil,193,194,512},{195,195,196,nil,nil,197,198,512},{199,199,200,nil,nil,201,202,512}},text)
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
