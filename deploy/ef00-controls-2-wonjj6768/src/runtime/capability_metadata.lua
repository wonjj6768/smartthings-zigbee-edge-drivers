local a,H={},{"OFF","ON","s","%","none","switch","idle","disarm","arm_away","arm_home","sos","ok","error","scene_1","scene_2","scene_3","scene_4","scene_5","scene_6","scene_7","scene_8","scene_9","scene_10","all","backlightBrightness","lincukooCzfButtonHoldDuration","lincukooCzfArmEndPosition","lincukooCzfArmStartPosition","immaxKeypadArmDelayTime","armDelayTime","daewooWkeArmDelayTime","qaQatSixBacklight","qaQatTwoBacklight","qaQatThreeBacklight","tuyaPsOneCountdown","tuyaPsOneDelaysTime","tuyaPsOneSensitivity","tuyaFingerbotLowerLimit","tuyaFingerbotUpperLimitV2","tuyaFingerbotDelay","ecbPumpDelay","3_min","5_min","15_min","ecbZoneOneDemand","ecbZoneTwoDemand","ecbZoneThreeDemand","ecbZoneFourDemand","ecbZoneFiveDemand","ecbZoneSixDemand","ecbZoneADemand","ecbZoneBDemand","ecbPumpState","ecbBoilerState","ecbZoneOneLinked","ecbZoneTwoLinked","ecbZoneThreeLinked","ecbZoneFourLinked","ecbZoneFiveLinked","ecbZoneSixLinked","lincukooCzfMode","button","lincukooCzfAutoAdjustment","START","lincukooCzfSwitchStates","SWITCH","immaxKeypadAction","action","immaxKeypadBeepSoundEnabled","beepSoundEnabled","immaxKeypadQuickHomeEnabled","quickHomeEnabled","immaxKeypadQuickDisarmEnabled","quickDisarmEnabled","immaxKeypadQuickArmEnabled","quickArmEnabled","immaxKeypadArmDelayBeepSound","armDelayBeepSound","daewooWkeAction","daewooWkeArmMode","daewooWkeArmed","true","false","daewooWkeBeepSoundEnabled","daewooWkeArmDelayBeepSound","daewooWkeQuickHomeEnabled","daewooWkeQuickArmEnabled","daewooWkeQuickDisarmEnabled","daewooWkeQuickSosEnabled","boxErcRecordRf","record","boxErcClearRf","clear","boxErcRfStatus","boxErcRecordScene","boxErcClearScene","boxErcRfSceneStatus","tuyaPsOneRelayStatus","memory","tuyaPsOneLightMode","tuyaPsOneTurnOnPerson","tuyaPsOneTurnOffPerson","tuyaFingerbotMode","program","tuyaFingerbotReverse","tuyaFingerbotTouch","lastPowerResponseTime","ecbZoneAName","ecbZoneBName","ecbZoneOneName","ecbZoneTwoName","ecbZoneThreeName","ecbZoneFourName","ecbZoneFiveName","ecbZoneSixName","immaxKeypadAdminCode","adminCode","immaxKeypadLastAddedUserCode","lastAddedUserCode","immaxKeypadUserId","userId","daewooWkeUserId","daewooWkeUserLastSeen","daewooWkeLastAddedUserCode","daewooWkeAdminCode"}
local function b(g)
if type(g)=="number"then return H[g]end
return g
end
local function p(g)local suffix=b(g);if suffix==nil then return nil end;return"concertmirror08464."..suffix end
local t={}
local function q(k)
if type(k)~="number"then return{}end
local x=t[k]if x~=nil then return x end
local n={}t[k]=n
return n
end
local function s(D,k)
if type(D)~="table"then return nil end
local n=q(k)for A,g in ipairs(D)do n[A]=b(g)end
return n
end
local function i(g,E)
if g==nil then return E end
if g==0 then return nil end
return b(g)
end
local function m(attribute_name)
if type(attribute_name)~="string"or attribute_name==""then return nil end
return"set"..attribute_name:sub(1,1):upper()..attribute_name:sub(2)
end
local function J(g)
if type(g)~="table"then return nil end
local n=q(g[6])n.minimum=g[1]n.maximum=g[2]n.step=g[3]n.unit=b(g[4])n.allowed_values=s(g[5],g[7])return n
end
local function w(j,k)
if j==nil and k==nil then return nil end
local n=q(k)n.allowed_values=j
return n
end
local function G(f)
local attribute_name=b(f[4])return{kind="numeric",emit_name=b(f[1]),range_key=b(f[2]),capability_id=p(f[3]),attribute_name=attribute_name,range_attribute_name=b(f[5]),command_name=i(f[6],m(attribute_name)),argument_name=i(f[7],attribute_name),mapping_name=b(f[8]),label=b(f[9]),default_range=J(f[10]),event_minimum=f[11],event_maximum=f[12],event_unit=b(f[13])}
end
local function K(f)
local attribute_name,u,r=b(f[4]),s(f[10],f[12]),s(f[11],f[14])local d=w(r,f[13])return{kind="enum",emit_name=b(f[1]),range_key=b(f[2]),capability_id=p(f[3]),attribute_name=attribute_name,supported_attribute_name=b(f[5]),command_name=i(f[6],m(attribute_name)),argument_name=i(f[7],attribute_name),mapping_name=b(f[8]),label=b(f[9]),supported_values=u,default_range=d}
end
local function M(f)
local attribute_name=b(f[3])return{kind="text",emit_name=b(f[1]),capability_id=p(f[2]),attribute_name=attribute_name,command_name=i(f[4],m(attribute_name)),argument_name=i(f[5],attribute_name),mapping_name=b(f[6]),label=b(f[7]),maximum_length=f[8]}
end
local function z(L,F)
local n={}for _,f in ipairs(L)do n[#n+1]=F(f)end
return n
end
a.numeric=z({{26,nil,26,"buttonHoldDuration",nil,nil,nil,"lincukoo_czf_button_hold_duration","Lincukoo Czf Button Hold Duration",{0.3,10,0.1,3,nil,1},nil,nil,3},{27,nil,27,"armEndPosition",nil,nil,nil,"lincukoo_czf_arm_end_position","Lincukoo Czf Arm End Position",{0,30,1,nil,nil,2}},{28,nil,28,"armStartPosition",nil,nil,nil,"lincukoo_czf_arm_start_position","Lincukoo Czf Arm Start Position",{0,30,1,nil,nil,3}},{29,nil,29,30,nil,nil,nil,"immax_keypad_arm_delay_time","Immax Keypad Arm Delay Time",{0,180,1,nil,nil,4}},{31,nil,31,30,nil,nil,nil,"daewoo_wke_arm_delay_time","Daewoo Wke Arm Delay Time",{0,180,1,3,nil,5},nil,nil,3},{32,nil,32,25,nil,nil,nil,"qa_qat_six_backlight_brightness","Qa Qat Six Backlight",{0,99,1,4,nil,6},nil,nil,4},{33,nil,33,25,nil,nil,nil,"qa_qat_two_backlight_brightness","Qa Qat Two Backlight",{0,99,1,4,nil,7},nil,nil,4},{34,nil,34,25,nil,nil,nil,"qa_qat_three_backlight_brightness","Qa Qat Three Backlight",{0,99,1,4,nil,8},nil,nil,4},{35,nil,35,"countdown",nil,nil,nil,"tuya_ps_1_countdown","Tuya Ps One Countdown",{0,43200,1,3,nil,9},nil,nil,3},{36,nil,36,"delaysTime",nil,nil,nil,"tuya_ps_1_delays_time","Tuya Ps One Delays Time",{3,3600,1,3,nil,10},nil,nil,3},{37,nil,37,"sensitivity",nil,nil,nil,"tuya_ps_1_sensitivity","Tuya Ps One Sensitivity",{1,10,1,nil,nil,11}},{38,nil,38,"lowerLimit",nil,nil,nil,"tuya_fingerbot_lower_limit","Tuya Fingerbot Lower Limit",{50,100,1,4,nil,12},nil,nil,4},{39,nil,39,"upperLimit",nil,nil,nil,"tuya_fingerbot_upper_limit","Tuya Fingerbot Upper Limit V2",{0,51,1,4,nil,13},nil,nil,4},{40,nil,40,"delay",nil,nil,nil,"tuya_fingerbot_delay","Tuya Fingerbot Delay",{0,10,1,3,nil,14},nil,nil,3}},G)a.enum=z({{41,nil,41,"pumpDelayTime",nil,nil,nil,"ecb_pump_delay_time","Ecb Pump Delay",{1,42,43,44},{1,42,43,44},15,16,15},{45,nil,45,"zoneOneDemand",nil,0,0,"ecb_zone_one_demand","Ecb Zone One Demand",{2,1},{2,1},17,18,17},{46,nil,46,"zoneTwoDemand",nil,0,0,"ecb_zone_two_demand","Ecb Zone Two Demand",{2,1},{2,1},19,20,19},{47,nil,47,"zoneThreeDemand",nil,0,0,"ecb_zone_three_demand","Ecb Zone Three Demand",{2,1},{2,1},21,22,21},{48,nil,48,"zoneFourDemand",nil,0,0,"ecb_zone_four_demand","Ecb Zone Four Demand",{2,1},{2,1},23,24,23},{49,nil,49,"zoneFiveDemand",nil,0,0,"ecb_zone_five_demand","Ecb Zone Five Demand",{2,1},{2,1},25,26,25},{50,nil,50,"zoneSixDemand",nil,0,0,"ecb_zone_six_demand","Ecb Zone Six Demand",{2,1},{2,1},27,28,27},{51,nil,51,"zoneADemand",nil,0,0,"ecb_zone_a_demand","Ecb Zone ADemand",{2,1},{2,1},29,30,29},{52,nil,52,"zoneBDemand",nil,0,0,"ecb_zone_b_demand","Ecb Zone BDemand",{2,1},{2,1},31,32,31},{53,nil,53,"pumpState",nil,0,0,"ecb_pump_state","Ecb Pump State",{2,1},{2,1},33,34,33},{54,nil,54,"boilerState",nil,0,0,"ecb_boiler_state","Ecb Boiler State",{2,1},{2,1},35,36,35},{55,nil,55,"zoneOneLinked",nil,0,0,"ecb_zone_one_linked","Ecb Zone One Linked",{2,1},{2,1},37,38,37},{56,nil,56,"zoneTwoLinked",nil,0,0,"ecb_zone_two_linked","Ecb Zone Two Linked",{2,1},{2,1},39,40,39},{57,nil,57,"zoneThreeLinked",nil,0,0,"ecb_zone_three_linked","Ecb Zone Three Linked",{2,1},{2,1},41,42,41},{58,nil,58,"zoneFourLinked",nil,0,0,"ecb_zone_four_linked","Ecb Zone Four Linked",{2,1},{2,1},43,44,43},{59,nil,59,"zoneFiveLinked",nil,0,0,"ecb_zone_five_linked","Ecb Zone Five Linked",{2,1},{2,1},45,46,45},{60,nil,60,"zoneSixLinked",nil,0,0,"ecb_zone_six_linked","Ecb Zone Six Linked",{2,1},{2,1},47,48,47},{61,nil,61,"mode",nil,nil,nil,"lincukoo_czf_mode","Lincukoo Czf Mode",{62,6},{62,6},49,50,49},{63,nil,63,"autoAdjustment",nil,nil,nil,"lincukoo_czf_auto_adjustment","Lincukoo Czf Auto Adjustment",{64,7},{64,7},51,52,51},{65,nil,65,"switchStates",nil,nil,nil,"lincukoo_czf_switch_states","Lincukoo Czf Switch States",{66,7},{66,7},53,54,53},{67,nil,67,68,nil,0,0,"immax_keypad_action","Immax Keypad Action",{8,9,10,11},{8,9,10,11},55,56,55},{69,nil,69,70,nil,nil,nil,"immax_keypad_beep_sound_enabled","Immax Keypad Beep Sound Enabled",{2,1},{2,1},57,58,57},{71,nil,71,72,nil,nil,nil,"immax_keypad_quick_home_enabled","Immax Keypad Quick Home Enabled",{2,1},{2,1},59,60,59},{73,nil,73,74,nil,nil,nil,"immax_keypad_quick_disarm_enabled","Immax Keypad Quick Disarm Enabled",{2,1},{2,1},61,62,61},{75,nil,75,76,nil,nil,nil,"immax_keypad_quick_arm_enabled","Immax Keypad Quick Arm Enabled",{2,1},{2,1},63,64,63},{77,nil,77,78,nil,nil,nil,"immax_keypad_arm_delay_beep_sound","Immax Keypad Arm Delay Beep Sound",{2,1},{2,1},65,66,65},{79,nil,79,68,nil,0,0,"daewoo_wke_action","Daewoo Wke Action",{8,9,10,11},{8,9,10,11},67,68,67},{80,nil,80,"armMode",nil,0,0,"daewoo_wke_arm_mode","Daewoo Wke Arm Mode",{"0","2"},{"0","2"},69,70,69},{81,nil,81,"armed",nil,nil,nil,"daewoo_wke_armed","Daewoo Wke Armed",{82,83},{82,83},71,72,71},{84,nil,84,70,nil,nil,nil,"daewoo_wke_beep_sound_enabled","Daewoo Wke Beep Sound Enabled",{2,1},{2,1},73,74,73},{85,nil,85,78,nil,nil,nil,"daewoo_wke_arm_delay_beep_sound","Daewoo Wke Arm Delay Beep Sound",{2,1},{2,1},75,76,75},{86,nil,86,72,nil,nil,nil,"daewoo_wke_quick_home_enabled","Daewoo Wke Quick Home Enabled",{2,1},{2,1},77,78,77},{87,nil,87,76,nil,nil,nil,"daewoo_wke_quick_arm_enabled","Daewoo Wke Quick Arm Enabled",{2,1},{2,1},79,80,79},{88,nil,88,74,nil,nil,nil,"daewoo_wke_quick_disarm_enabled","Daewoo Wke Quick Disarm Enabled",{2,1},{2,1},81,82,81},{89,nil,89,"quickSosEnabled",nil,nil,nil,"daewoo_wke_quick_sos_enabled","Daewoo Wke Quick Sos Enabled",{2,1},{2,1},83,84,83},{90,nil,90,"recordRf",nil,nil,nil,"box_erc_record_rf","Box Erc Record Rf",{91},{91},85,86,85},{92,nil,92,"clearRf",nil,nil,nil,"box_erc_clear_rf","Box Erc Clear Rf",{93},{93},87,88,87},{94,nil,94,"rfStatus",nil,0,0,"box_erc_rf_status","Box Erc Rf Status",{12,13},{12,13},89,90,89},{95,nil,95,"recordScene",nil,nil,nil,"box_erc_record_scene","Box Erc Record Scene",{14,15,16,17,18,19,20,21,22,23},{14,15,16,17,18,19,20,21,22,23},91,92,91},{96,nil,96,"clearScene",nil,nil,nil,"box_erc_clear_scene","Box Erc Clear Scene",{14,15,16,17,18,19,20,21,22,23},{14,15,16,17,18,19,20,21,22,23},93,94,93},{97,nil,97,"rfSceneStatus",nil,0,0,"box_erc_rf_scene_status","Box Erc Rf Scene Status",{12,13},{12,13},95,96,95},{98,nil,98,"relayStatus",nil,nil,nil,"tuya_ps_1_relay_status","Tuya Ps One Relay Status",{"off","on",99},{"off","on",99},97,98,97},{100,nil,100,"lightMode",nil,nil,nil,"tuya_ps_1_light_mode","Tuya Ps One Light Mode",{"relay",5,"pos"},{"relay",5,"pos"},99,100,99},{101,nil,101,"turnOnLightForPerson",nil,nil,nil,"tuya_ps_1_turn_on_light_for_person","Tuya Ps One Turn On Person",{5,24},{5,24},101,102,101},{102,nil,102,"turnOffLightForPerson",nil,nil,nil,"tuya_ps_1_turn_off_light_for_person","Tuya Ps One Turn Off Person",{5,24},{5,24},103,104,103},{103,nil,103,"fingerbotMode",nil,nil,nil,"tuya_fingerbot_mode","Tuya Fingerbot Mode",{"click",6,104},{"click",6,104},105,106,105},{105,nil,105,"reverse",nil,nil,nil,"tuya_fingerbot_reverse","Tuya Fingerbot Reverse",{2,1},{2,1},107,108,107},{106,nil,106,"touch",nil,nil,nil,"tuya_fingerbot_touch","Tuya Fingerbot Touch",{2,1},{2,1},109,110,109}},K)a.text=z({{"last_power_response_time",107,107,0,0,nil,"Last power response time",64},{108,108,"zoneAName",nil,nil,"ecb_zone_a_name","Ecb Zone AName",512},{109,109,"zoneBName",nil,nil,"ecb_zone_b_name","Ecb Zone BName",512},{110,110,"zoneOneName",nil,nil,"ecb_zone_one_name","Ecb Zone One Name",512},{111,111,"zoneTwoName",nil,nil,"ecb_zone_two_name","Ecb Zone Two Name",512},{112,112,"zoneThreeName",nil,nil,"ecb_zone_three_name","Ecb Zone Three Name",512},{113,113,"zoneFourName",nil,nil,"ecb_zone_four_name","Ecb Zone Four Name",512},{114,114,"zoneFiveName",nil,nil,"ecb_zone_five_name","Ecb Zone Five Name",512},{115,115,"zoneSixName",nil,nil,"ecb_zone_six_name","Ecb Zone Six Name",512},{116,116,117,0,0,"immax_keypad_admin_code","Immax Keypad Admin Code",256},{118,118,119,0,0,"immax_keypad_last_added_user_code","Immax Keypad Last Added User Code",256},{120,120,121,0,0,"immax_keypad_user_id","Immax Keypad User Id",256},{122,122,121,0,0,"daewoo_wke_user_id","Daewoo Wke User Id",256},{123,123,"userLastSeen",0,0,"daewoo_wke_user_last_seen","Daewoo Wke User Last Seen",256},{124,124,119,0,0,"daewoo_wke_last_added_user_code","Daewoo Wke Last Added User Code",256},{125,125,117,nil,nil,"daewoo_wke_admin_code","Daewoo Wke Admin Code",256}},M)a.driver_message={attribute_name="driverMessage",capability_id="concertmirror08464.driverMessage",emit_name="driver_message",label="Driver message",maximum_length=512}a.by_range_key={}a.by_emit_name={}a.by_capability_id={}
local function o(y)
for _,e in ipairs(y)do
a.by_emit_name[e.emit_name]=e
if type(e.capability_id)=="string"and e.capability_id~=""then a.by_capability_id[e.capability_id]=e end
if type(e.range_key)=="string"and e.range_key~=""then a.by_range_key[e.range_key]=e end
end
end
o(a.numeric)o(a.enum)o(a.text)a.by_emit_name[a.driver_message.emit_name]=a.driver_message
a.by_capability_id[a.driver_message.capability_id]=a.driver_message
local function l(j)
if type(j)~="table"then return nil end
local B={}for A,g in ipairs(j)do B[A]=g end
return B
end
function a.resolve_range(v,e)
if type(e)~="table"then return nil end
local d,C=type(e.default_range)=="table"and e.default_range or nil,type(v)=="table"and v.presence_capability_ranges or nil

local h=type(C)=="table"and C[e.range_key]or nil
if type(h)~="table"then h=d end
if type(h)~="table"then return nil end
return{minimum=type(h.minimum)=="number"and h.minimum or(d and d.minimum or nil),maximum=type(h.maximum)=="number"and h.maximum or(d and d.maximum or nil),step=type(h.step)=="number"and h.step or(d and d.step or nil),unit=type(h.unit)=="string"and h.unit or(d and d.unit or nil),allowed_values=type(h.allowed_values)=="table"and l(h.allowed_values)or l(d and d.allowed_values or nil)}
end
return a
