local custom_capabilities={}
local strings={"s","lincukooCzfButtonHoldDuration","buttonHoldDuration","lincukoo_czf_button_hold_duration","Lincukoo Czf Button Hold Duration","lincukooCzfArmEndPosition","armEndPosition","lincukoo_czf_arm_end_position","Lincukoo Czf Arm End Position","lincukooCzfArmStartPosition","armStartPosition","lincukoo_czf_arm_start_position","Lincukoo Czf Arm Start Position","immaxKeypadArmDelayTime","armDelayTime","immax_keypad_arm_delay_time","Immax Keypad Arm Delay Time","daewooWkeArmDelayTime","daewoo_wke_arm_delay_time","Daewoo Wke Arm Delay Time","%","qaQatSixBacklight","backlightBrightness","qa_qat_six_backlight_brightness","Qa Qat Six Backlight","qaQatTwoBacklight","qa_qat_two_backlight_brightness","Qa Qat Two Backlight","qaQatThreeBacklight","qa_qat_three_backlight_brightness","Qa Qat Three Backlight","tuyaPsOneCountdown","countdown","tuya_ps_1_countdown","Tuya Ps One Countdown","tuyaPsOneDelaysTime","delaysTime","tuya_ps_1_delays_time","Tuya Ps One Delays Time","tuyaPsOneSensitivity","sensitivity","tuya_ps_1_sensitivity","Tuya Ps One Sensitivity","tuyaFingerbotLowerLimit","lowerLimit","tuya_fingerbot_lower_limit","Tuya Fingerbot Lower Limit","tuyaFingerbotUpperLimit","upperLimit","tuya_fingerbot_upper_limit","Tuya Fingerbot Upper Limit","tuyaFingerbotDelay","delay","tuya_fingerbot_delay","Tuya Fingerbot Delay","ecbPumpDelay","pumpDelayTime","ecb_pump_delay_time","Ecb Pump Delay","OFF","3_min","5_min","15_min","ecbZoneOneDemand","zoneOneDemand","ecb_zone_one_demand","Ecb Zone One Demand","ON","ecbZoneTwoDemand","zoneTwoDemand","ecb_zone_two_demand","Ecb Zone Two Demand","ecbZoneThreeDemand","zoneThreeDemand","ecb_zone_three_demand","Ecb Zone Three Demand","ecbZoneFourDemand","zoneFourDemand","ecb_zone_four_demand","Ecb Zone Four Demand","ecbZoneFiveDemand","zoneFiveDemand","ecb_zone_five_demand","Ecb Zone Five Demand","ecbZoneSixDemand","zoneSixDemand","ecb_zone_six_demand","Ecb Zone Six Demand","ecbZoneADemand","zoneADemand","ecb_zone_a_demand","Ecb Zone ADemand","ecbZoneBDemand","zoneBDemand","ecb_zone_b_demand","Ecb Zone BDemand","ecbPumpState","pumpState","ecb_pump_state","Ecb Pump State","ecbBoilerState","boilerState","ecb_boiler_state","Ecb Boiler State","ecbZoneOneLinked","zoneOneLinked","ecb_zone_one_linked","Ecb Zone One Linked","ecbZoneTwoLinked","zoneTwoLinked","ecb_zone_two_linked","Ecb Zone Two Linked","ecbZoneThreeLinked","zoneThreeLinked","ecb_zone_three_linked","Ecb Zone Three Linked","ecbZoneFourLinked","zoneFourLinked","ecb_zone_four_linked","Ecb Zone Four Linked","ecbZoneFiveLinked","zoneFiveLinked","ecb_zone_five_linked","Ecb Zone Five Linked","ecbZoneSixLinked","zoneSixLinked","ecb_zone_six_linked","Ecb Zone Six Linked","lincukooCzfMode","mode","lincukoo_czf_mode","Lincukoo Czf Mode","button","switch","lincukooCzfAutoAdjustment","autoAdjustment","lincukoo_czf_auto_adjustment","Lincukoo Czf Auto Adjustment","START","idle","lincukooCzfSwitchStates","switchStates","lincukoo_czf_switch_states","Lincukoo Czf Switch States","SWITCH","immaxKeypadAction","action","immax_keypad_action","Immax Keypad Action","disarm","arm_away","arm_home","sos","immaxKeypadBeepSoundEnabled","beepSoundEnabled","immax_keypad_beep_sound_enabled","Immax Keypad Beep Sound Enabled","immaxKeypadQuickHomeEnabled","quickHomeEnabled","immax_keypad_quick_home_enabled","Immax Keypad Quick Home Enabled","immaxKeypadQuickDisarmEnabled","quickDisarmEnabled","immax_keypad_quick_disarm_enabled","Immax Keypad Quick Disarm Enabled","immaxKeypadQuickArmEnabled","quickArmEnabled","immax_keypad_quick_arm_enabled","Immax Keypad Quick Arm Enabled","immaxKeypadArmDelayBeepSound","armDelayBeepSound","immax_keypad_arm_delay_beep_sound","Immax Keypad Arm Delay Beep Sound","daewooWkeAction","daewoo_wke_action","Daewoo Wke Action","daewooWkeArmMode","armMode","daewoo_wke_arm_mode","Daewoo Wke Arm Mode","0","2","daewooWkeArmed","armed","daewoo_wke_armed","Daewoo Wke Armed","true","false","daewooWkeBeepSoundEnabled","daewoo_wke_beep_sound_enabled","Daewoo Wke Beep Sound Enabled","daewooWkeArmDelayBeepSound","daewoo_wke_arm_delay_beep_sound","Daewoo Wke Arm Delay Beep Sound","daewooWkeQuickHomeEnabled","daewoo_wke_quick_home_enabled","Daewoo Wke Quick Home Enabled","daewooWkeQuickArmEnabled","daewoo_wke_quick_arm_enabled","Daewoo Wke Quick Arm Enabled","daewooWkeQuickDisarmEnabled","daewoo_wke_quick_disarm_enabled","Daewoo Wke Quick Disarm Enabled","daewooWkeQuickSosEnabled","quickSosEnabled","daewoo_wke_quick_sos_enabled","Daewoo Wke Quick Sos Enabled","boxErcRecordRf","recordRf","box_erc_record_rf","Box Erc Record Rf","record","boxErcClearRf","clearRf","box_erc_clear_rf","Box Erc Clear Rf","clear","boxErcRfStatus","rfStatus","box_erc_rf_status","Box Erc Rf Status","ok","error","boxErcRecordScene","recordScene","box_erc_record_scene","Box Erc Record Scene","scene_1","scene_2","scene_3","scene_4","scene_5","scene_6","scene_7","scene_8","scene_9","scene_10","boxErcClearScene","clearScene","box_erc_clear_scene","Box Erc Clear Scene","boxErcRfSceneStatus","rfSceneStatus","box_erc_rf_scene_status","Box Erc Rf Scene Status","tuyaPsOneRelayStatus","relayStatus","tuya_ps_1_relay_status","Tuya Ps One Relay Status","off","on","memory","tuyaPsOneLightMode","lightMode","tuya_ps_1_light_mode","Tuya Ps One Light Mode","relay","none","pos","tuyaPsOneTurnOnPerson","turnOnLightForPerson","tuya_ps_1_turn_on_light_for_person","Tuya Ps One Turn On Person","all","tuyaPsOneTurnOffPerson","turnOffLightForPerson","tuya_ps_1_turn_off_light_for_person","Tuya Ps One Turn Off Person","tuyaFingerbotMode","fingerbotMode","tuya_fingerbot_mode","Tuya Fingerbot Mode","click","program","tuyaFingerbotReverse","reverse","tuya_fingerbot_reverse","Tuya Fingerbot Reverse","tuyaFingerbotTouch","touch","tuya_fingerbot_touch","Tuya Fingerbot Touch","last_power_response_time","lastPowerResponseTime","Last power response time","ecbZoneAName","zoneAName","ecb_zone_a_name","Ecb Zone AName","ecbZoneBName","zoneBName","ecb_zone_b_name","Ecb Zone BName","ecbZoneOneName","zoneOneName","ecb_zone_one_name","Ecb Zone One Name","ecbZoneTwoName","zoneTwoName","ecb_zone_two_name","Ecb Zone Two Name","ecbZoneThreeName","zoneThreeName","ecb_zone_three_name","Ecb Zone Three Name","ecbZoneFourName","zoneFourName","ecb_zone_four_name","Ecb Zone Four Name","ecbZoneFiveName","zoneFiveName","ecb_zone_five_name","Ecb Zone Five Name","ecbZoneSixName","zoneSixName","ecb_zone_six_name","Ecb Zone Six Name","immaxKeypadAdminCode","adminCode","immax_keypad_admin_code","Immax Keypad Admin Code","immaxKeypadLastAddedUserCode","lastAddedUserCode","immax_keypad_last_added_user_code","Immax Keypad Last Added User Code","immaxKeypadUserId","userId","immax_keypad_user_id","Immax Keypad User Id","daewooWkeUserId","daewoo_wke_user_id","Daewoo Wke User Id","daewooWkeUserLastSeen","userLastSeen","daewoo_wke_user_last_seen","Daewoo Wke User Last Seen","daewooWkeLastAddedUserCode","daewoo_wke_last_added_user_code","Daewoo Wke Last Added User Code","daewooWkeAdminCode","daewoo_wke_admin_code","Daewoo Wke Admin Code"}
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
custom_capabilities.numeric=build({{2,nil,2,3,nil,nil,nil,4,5,{0.3,10,0.1,1,nil,1,nil},nil,nil,1},{6,nil,6,7,nil,nil,nil,8,9,{0,30,1,nil,nil,2,nil},nil,nil,nil},{10,nil,10,11,nil,nil,nil,12,13,{0,30,1,nil,nil,3,nil},nil,nil,nil},{14,nil,14,15,nil,nil,nil,16,17,{0,180,1,nil,nil,4,nil},nil,nil,nil},{18,nil,18,15,nil,nil,nil,19,20,{0,180,1,1,nil,5,nil},nil,nil,1},{22,nil,22,23,nil,nil,nil,24,25,{0,99,1,21,nil,6,nil},nil,nil,21},{26,nil,26,23,nil,nil,nil,27,28,{0,99,1,21,nil,7,nil},nil,nil,21},{29,nil,29,23,nil,nil,nil,30,31,{0,99,1,21,nil,8,nil},nil,nil,21},{32,nil,32,33,nil,nil,nil,34,35,{0,43200,1,1,nil,9,nil},nil,nil,1},{36,nil,36,37,nil,nil,nil,38,39,{3,3600,1,1,nil,10,nil},nil,nil,1},{40,nil,40,41,nil,nil,nil,42,43,{1,10,1,nil,nil,11,nil},nil,nil,nil},{44,nil,44,45,nil,nil,nil,46,47,{50,100,1,21,nil,12,nil},nil,nil,21},{48,nil,48,49,nil,nil,nil,50,51,{0,50,1,21,nil,13,nil},nil,nil,21},{52,nil,52,53,nil,nil,nil,54,55,{0,10,1,1,nil,14,nil},nil,nil,1}},numeric)
custom_capabilities.enum=build({{56,nil,56,57,nil,nil,nil,58,59,{60,61,62,63},{60,61,62,63},15,16,15},{64,nil,64,65,nil,0,0,66,67,{68,60},{68,60},17,18,17},{69,nil,69,70,nil,0,0,71,72,{68,60},{68,60},19,20,19},{73,nil,73,74,nil,0,0,75,76,{68,60},{68,60},21,22,21},{77,nil,77,78,nil,0,0,79,80,{68,60},{68,60},23,24,23},{81,nil,81,82,nil,0,0,83,84,{68,60},{68,60},25,26,25},{85,nil,85,86,nil,0,0,87,88,{68,60},{68,60},27,28,27},{89,nil,89,90,nil,0,0,91,92,{68,60},{68,60},29,30,29},{93,nil,93,94,nil,0,0,95,96,{68,60},{68,60},31,32,31},{97,nil,97,98,nil,0,0,99,100,{68,60},{68,60},33,34,33},{101,nil,101,102,nil,0,0,103,104,{68,60},{68,60},35,36,35},{105,nil,105,106,nil,0,0,107,108,{68,60},{68,60},37,38,37},{109,nil,109,110,nil,0,0,111,112,{68,60},{68,60},39,40,39},{113,nil,113,114,nil,0,0,115,116,{68,60},{68,60},41,42,41},{117,nil,117,118,nil,0,0,119,120,{68,60},{68,60},43,44,43},{121,nil,121,122,nil,0,0,123,124,{68,60},{68,60},45,46,45},{125,nil,125,126,nil,0,0,127,128,{68,60},{68,60},47,48,47},{129,nil,129,130,nil,nil,nil,131,132,{133,134},{133,134},49,50,49},{135,nil,135,136,nil,nil,nil,137,138,{139,140},{139,140},51,52,51},{141,nil,141,142,nil,nil,nil,143,144,{145,140},{145,140},53,54,53},{146,nil,146,147,nil,0,0,148,149,{150,151,152,153},{150,151,152,153},55,56,55},{154,nil,154,155,nil,nil,nil,156,157,{68,60},{68,60},57,58,57},{158,nil,158,159,nil,nil,nil,160,161,{68,60},{68,60},59,60,59},{162,nil,162,163,nil,nil,nil,164,165,{68,60},{68,60},61,62,61},{166,nil,166,167,nil,nil,nil,168,169,{68,60},{68,60},63,64,63},{170,nil,170,171,nil,nil,nil,172,173,{68,60},{68,60},65,66,65},{174,nil,174,147,nil,0,0,175,176,{150,151,152,153},{150,151,152,153},67,68,67},{177,nil,177,178,nil,0,0,179,180,{181,182},{181,182},69,70,69},{183,nil,183,184,nil,nil,nil,185,186,{187,188},{187,188},71,72,71},{189,nil,189,155,nil,nil,nil,190,191,{68,60},{68,60},73,74,73},{192,nil,192,171,nil,nil,nil,193,194,{68,60},{68,60},75,76,75},{195,nil,195,159,nil,nil,nil,196,197,{68,60},{68,60},77,78,77},{198,nil,198,167,nil,nil,nil,199,200,{68,60},{68,60},79,80,79},{201,nil,201,163,nil,nil,nil,202,203,{68,60},{68,60},81,82,81},{204,nil,204,205,nil,nil,nil,206,207,{68,60},{68,60},83,84,83},{208,nil,208,209,nil,nil,nil,210,211,{212},{212},85,86,85},{213,nil,213,214,nil,nil,nil,215,216,{217},{217},87,88,87},{218,nil,218,219,nil,0,0,220,221,{222,223},{222,223},89,90,89},{224,nil,224,225,nil,nil,nil,226,227,{228,229,230,231,232,233,234,235,236,237},{228,229,230,231,232,233,234,235,236,237},91,92,91},{238,nil,238,239,nil,nil,nil,240,241,{228,229,230,231,232,233,234,235,236,237},{228,229,230,231,232,233,234,235,236,237},93,94,93},{242,nil,242,243,nil,0,0,244,245,{222,223},{222,223},95,96,95},{246,nil,246,247,nil,nil,nil,248,249,{250,251,252},{250,251,252},97,98,97},{253,nil,253,254,nil,nil,nil,255,256,{257,258,259},{257,258,259},99,100,99},{260,nil,260,261,nil,nil,nil,262,263,{258,264},{258,264},101,102,101},{265,nil,265,266,nil,nil,nil,267,268,{258,264},{258,264},103,104,103},{269,nil,269,270,nil,nil,nil,271,272,{273,134,274},{273,134,274},105,106,105},{275,nil,275,276,nil,nil,nil,277,278,{68,60},{68,60},107,108,107},{279,nil,279,280,nil,nil,nil,281,282,{68,60},{68,60},109,110,109}},enum)
custom_capabilities.text=build({{283,284,284,0,0,nil,285,64},{286,286,287,nil,nil,288,289,512},{290,290,291,nil,nil,292,293,512},{294,294,295,nil,nil,296,297,512},{298,298,299,nil,nil,300,301,512},{302,302,303,nil,nil,304,305,512},{306,306,307,nil,nil,308,309,512},{310,310,311,nil,nil,312,313,512},{314,314,315,nil,nil,316,317,512},{318,318,319,0,0,320,321,256},{322,322,323,0,0,324,325,256},{326,326,327,0,0,328,329,256},{330,330,327,0,0,331,332,256},{333,333,334,0,0,335,336,256},{337,337,323,0,0,338,339,256},{340,340,319,nil,nil,341,342,256}},text)
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
