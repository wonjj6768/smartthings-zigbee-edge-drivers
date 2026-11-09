local a,H={},{"ON","OFF","low","high","off","on","normal","alarm","medium","mute","min","alarm_sound","alarm_light","alarm_sound_light","middle","%LEL","ppm","tone_1","tone_2","tone_3","ring1","ring2","ring3","checking","others","idle","neoAbSixAlarmTime","sensitivity","ringtone","alarmStatus","neoAbSixAlarmState","neoAbSixAlarmSwitch","neoAbSixTamperAlarmSwitch","neoAbSixTamperAlarm","neoAbSixAlarmMelody","neoAbSixAlarmMode","neoAbSixCharging","batteryState","test","neoAbTwoDuration","duration","eFourGasLevel","eFourMaxGasAlarm","eFourMaxCoAlarm","times","aZeroEightAlarmTime","zas01pDuration","hs118zTuyaSensitivity","hs118zTuyaIlluminanceSampling","illuminanceSampling","hs118zSensitivity","hs118zIlluminanceSampling","moesZcHmCo","nousE9WarmingUp","warmingUp","nousE9EndOfLife","endOfLife","nousE13WaterLeakAlarm","clear","detected","nousE13AlarmMode","water_presence","water_absence","nousE13Ringtone","muted","lincukooSzw08AlarmStatus","lincukooSzw08Mode","leakage","shortage","lincukooSzw08Ringtone","alarmRingtone","moesZcHmSelfTestResult","success","failure","moesZcHmSilence","no_alarm","melody_1","melody_2","melody_3","not_charging","charging","tuyaVibrationAlarmStatus","tuyaVibrationSensitivity","tuyaVibrationBatteryState","tuyaVibrationDismissAlarm","DISMISS","tuyaVibrationSilentMode","silentMode","neoAbTwoMelody","melody","neoAbTwoVolume","volume","lincukooWFourAlarmStatus","lincukooWFourAlarmSwitch","lincukooWFourBatteryState","lincukooWFourRingtone","nousETwelveWarmingUp","nousETwelveTest","nousETwelveTesting","nousETwelveEndOfLife","nousETwelveBatteryState","eFourSelfChecking","eFourCheckingResult","check_success","check_failure","aZeroEightAlarmState","aZeroEightAlarmVolume","aZeroEightMute","aZeroEightAlarmRingtone","ringtone_1","ringtone_2","ringtone_3","ringtone_4","ringtone_5","ringtone_6","ringtone_7","ringtone_8","ringtone_9","ringtone_10","ringtone_11","ringtone_12","ringtone_13","ringtone_14","ringtone_15","ringtone_16","ringtone_17","ringtone_18","ringtone_19","ringtone_20","ringtone_21","ringtone_22","ringtone_23","ringtone_24","ringtone_25","ringtone_26","ringtone_27","immax07519lSilentMode","immax07519lRingtone","zas01pVolume","zas01pMelody","doorbell","alarm_1","alarm_2","alarm_clock","notification","countdown","emergency_button","fall_detected","equipment_moved","carbon_dioxide","circuit_breaker","door_open","window_open","air_quality","motion_detected","person_detected","camera","vibration","ambient_temperature","target_temperature_reached","heating","water_level_alarm","valve_closed","scheduled_task","door_lock_alarm","smoke_alarm","gas_alarm","low_battery","water_leak_alarm","device_offline","alarm_system_disarmed","alarm_system_armed","zas01pLightMode","breathing","red_flash","zsd20SelfCheck","zsd20Muffling","lastPowerResponseTime"}
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
a.numeric=z({{27,nil,27,27,nil,nil,nil,"neo_ab_six_alarm_time","Neo Ab Six Alarm Time",{1,60,1,11,nil,1},nil,nil,11},{40,nil,40,41,nil,nil,nil,"neo_ab_two_duration","Neo Ab Two Duration",{0,1800,1,"s",nil,2},nil,nil,"s"},{42,nil,42,"gasLevel",nil,0,0,"e_four_gas_level","E Four Gas Level",{0,20,nil,16,nil,3},nil,nil,16},{43,nil,43,"maxGasAlarm",nil,nil,nil,"e_four_max_gas_alarm","E Four Max Gas Alarm",{0.1,20,0.1,16,nil,4},nil,nil,16},{44,nil,44,"maxCoAlarm",nil,nil,nil,"e_four_max_co_alarm","E Four Max Co Alarm",{10,1000,10,17,nil,5},nil,nil,17},{46,nil,46,"alarmTime",nil,nil,nil,"a_zero_eight_alarm_time","A Zero Eight Alarm Time",{0,100,1,45,nil,6},nil,nil,45},{47,nil,47,41,nil,nil,nil,"zas01p_duration","Zas01p Duration",{10,1800,1,"s",nil,7},nil,nil,"s"},{48,nil,48,28,nil,nil,nil,"hs118z_tuya_sensitivity","Hs118z Tuya Sensitivity",{0,9,1,nil,nil,8}},{49,nil,49,50,nil,nil,nil,"hs118z_tuya_illuminance_sampling","Hs118z Tuya Illuminance Sampling",{1,480,1,11,nil,9},nil,nil,11},{51,nil,51,28,nil,nil,nil,"hs118z_sensitivity","Hs118z Sensitivity",{0,9,1,nil,nil,10}},{52,nil,52,50,nil,nil,nil,"hs118z_illuminance_sampling","Hs118z Illuminance Sampling",{1,480,1,11,nil,11},nil,nil,11},{53,nil,53,"co",nil,0,0,"moes_zc_hm_co","Moes Zc Hm Co",{nil,nil,nil,17,nil,12},nil,nil,17}},G)a.enum=z({{54,nil,54,55,nil,0,0,"nous_e9_warming_up","Nous E9Warming Up",{5,6},{5,6},13,14,13},{56,nil,56,57,nil,0,0,"nous_e9_end_of_life","Nous E9End Of Life",{5,6},{5,6},15,16,15},{58,nil,58,"waterLeakAlarm",nil,0,0,"nous_e13_water_leak_alarm","Nous E13Water Leak Alarm",{59,60},{59,60},17,18,17},{61,nil,61,"alarmMode",nil,nil,nil,"nous_e13_alarm_mode","Nous E13Alarm Mode",{62,63},{62,63},19,20,19},{64,nil,64,29,nil,nil,nil,"nous_e13_ringtone","Nous E13Ringtone",{65,18,19,20},{65,18,19,20},21,22,21},{66,nil,66,30,nil,0,0,"lincukoo_szw08_alarm_status","Lincukoo Szw08Alarm Status",{7,8},{7,8},23,24,23},{67,nil,67,"mode",nil,nil,nil,"lincukoo_szw08_mode","Lincukoo Szw08Mode",{68,69},{68,69},25,26,25},{70,nil,70,71,nil,nil,nil,"lincukoo_szw08_alarm_ringtone","Lincukoo Szw08Ringtone",{10,21,22,23},{10,21,22,23},27,28,27},{72,nil,72,"selfTestResult",nil,0,0,"moes_zc_hm_self_test_result","Moes Zc Hm Self Test Result",{24,73,74,25},{24,73,74,25},29,30,29},{75,nil,75,"silence",nil,nil,nil,"moes_zc_hm_silence","Moes Zc Hm Silence",{5,6},{5,6},31,32,31},{31,nil,31,31,nil,0,0,"neo_ab_six_alarm_state","Neo Ab Six Alarm State",{12,13,14,76},{12,13,14,76},33,34,33},{32,nil,32,32,nil,nil,nil,"neo_ab_six_alarm_switch","Neo Ab Six Alarm Switch",{1,2},{1,2},35,36,35},{33,nil,33,33,nil,nil,nil,"neo_ab_six_tamper_alarm_switch","Neo Ab Six Tamper Alarm Switch",{1,2},{1,2},37,38,37},{34,nil,34,34,nil,0,0,"neo_ab_six_tamper_alarm","Neo Ab Six Tamper Alarm",{1,2},{1,2},39,40,39},{35,nil,35,35,nil,nil,nil,"neo_ab_six_alarm_melody","Neo Ab Six Alarm Melody",{77,78,79},{77,78,79},41,42,41},{36,nil,36,36,nil,nil,nil,"neo_ab_six_alarm_mode","Neo Ab Six Alarm Mode",{12,13,14},{12,13,14},43,44,43},{37,nil,37,37,nil,0,0,"neo_ab_six_charging","Neo Ab Six Charging",{80,81},{80,81},45,46,45},{82,nil,82,30,nil,0,0,"tuya_vibration_alarm_status","Tuya Vibration Alarm Status",{7,8},{7,8},47,48,47},{83,nil,83,28,nil,nil,nil,"tuya_vibration_sensitivity","Tuya Vibration Sensitivity",{3,15,4},{3,15,4},49,50,49},{84,nil,84,38,nil,0,0,"tuya_vibration_battery_state","Tuya Vibration Battery State",{3,9,4},{3,9,4},51,52,51},{85,nil,85,"dismissAlarm",nil,nil,nil,"tuya_vibration_dismiss_alarm","Tuya Vibration Dismiss Alarm",{26,86},{26,86},53,54,53},{87,nil,87,88,nil,nil,nil,"tuya_vibration_silent_mode","Tuya Vibration Silent Mode",{2,1},{2,1},55,56,55},{89,nil,89,90,nil,nil,nil,"neo_ab_two_melody","Neo Ab Two Melody",{"1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18"},{"1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18"},57,58,57},{91,nil,91,92,nil,nil,nil,"neo_ab_two_volume","Neo Ab Two Volume",{3,9,4},{3,9,4},59,60,59},{93,nil,93,30,nil,0,0,"lincukoo_w_four_alarm_status","Lincukoo WFour Alarm Status",{7,8},{7,8},61,62,61},{94,nil,94,"alarmSwitch",nil,nil,nil,"lincukoo_w_four_alarm_switch","Lincukoo WFour Alarm Switch",{10,8},{10,8},63,64,63},{95,nil,95,38,nil,0,0,"lincukoo_w_four_battery_state","Lincukoo WFour Battery State",{3,15,4},{3,15,4},65,66,65},{96,nil,96,29,nil,nil,nil,"lincukoo_w_four_ringtone","Lincukoo WFour Ringtone",{21,22,23},{21,22,23},67,68,67},{97,nil,97,55,nil,0,0,"nous_e_twelve_warming_up","Nous ETwelve Warming Up",{5,6},{5,6},69,70,69},{98,nil,98,39,nil,nil,nil,"nous_e_twelve_test","Nous ETwelve Test",{26,39},{26,39},71,72,71},{99,nil,99,"testing",nil,0,0,"nous_e_twelve_testing","Nous ETwelve Testing",{5,6},{5,6},73,74,73},{100,nil,100,57,nil,0,0,"nous_e_twelve_end_of_life","Nous ETwelve End Of Life",{5,6},{5,6},75,76,75},{101,nil,101,38,nil,0,0,"nous_e_twelve_battery_state","Nous ETwelve Battery State",{3,9,4},{3,9,4},77,78,77},{102,nil,102,"selfChecking",nil,nil,nil,"e_four_self_checking","E Four Self Checking",{1,2},{1,2},79,80,79},{103,nil,103,"checkingResult",nil,0,0,"e_four_checking_result","E Four Checking Result",{24,104,105,25},{24,104,105,25},81,82,81},{106,nil,106,"alarmState",nil,nil,nil,"a_zero_eight_alarm_state","A Zero Eight Alarm State",{12,13,14,7},{12,13,14,7},83,84,83},{107,nil,107,"alarmVolume",nil,nil,nil,"a_zero_eight_alarm_volume","A Zero Eight Alarm Volume",{3,15,4,10},{3,15,4,10},85,86,85},{108,nil,108,10,nil,nil,nil,"a_zero_eight_mute","A Zero Eight Mute",{1,2},{1,2},87,88,87},{109,nil,109,71,nil,nil,nil,"a_zero_eight_alarm_ringtone","A Zero Eight Alarm Ringtone",{110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136},{110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136},89,90,89},{137,nil,137,88,nil,nil,nil,"immax_07519l_silent_mode","Immax07519l Silent Mode",{2,1},{2,1},91,92,91},{138,nil,138,29,nil,nil,nil,"immax_07519l_ringtone","Immax07519l Ringtone",{18,19,20},{18,19,20},93,94,93},{139,nil,139,92,nil,nil,nil,"zas01p_volume","Zas01p Volume",{3,9,4},{3,9,4},95,96,95},{140,nil,140,90,nil,nil,nil,"zas01p_melody","Zas01p Melody",{141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172},{141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172},97,98,97},{173,nil,173,"lightMode",nil,nil,nil,"zas01p_light_mode","Zas01p Light Mode",{174,175,"white"},{174,175,"white"},99,100,99},{176,nil,176,"selfCheck",nil,nil,nil,"zsd20_self_check","Zsd20Self Check",{1,2},{1,2},101,102,101},{177,nil,177,"muffling",nil,nil,nil,"zsd20_muffling","Zsd20Muffling",{1,2},{1,2},103,104,103}},K)a.text=z({{"last_power_response_time",178,178,0,0,nil,"Last power response time",64}},M)a.driver_message={attribute_name="driverMessage",capability_id="concertmirror08464.driverMessage",emit_name="driver_message",label="Driver message",maximum_length=512}a.by_range_key={}a.by_emit_name={}a.by_capability_id={}
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
