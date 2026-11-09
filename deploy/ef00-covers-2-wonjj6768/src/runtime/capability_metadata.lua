local a,H={},{"normal","reversed","ON","OFF","motorDirection","s","opening","closing","stop","set_up","set_down","delete_up","delete_down","stopped","charging","calibration","fully_open","fully_close","none","START","END","FORWARD","BACKWARD","delete_both","start","coverLimit","motorState","adcbziTotalTime","totalTime","adcbziOpenThreshold","adcbziCloseThreshold","adcbziCurtainStatus","adcbziTotalDistance","adcbziFactoryTest","tsCoverTwoFavoritePosition","favoritePosition","znUscCalibrationTime","calibrationTime","cover14A0TotalTime","cover14A0FavoritePosition","zn2sCalibrationTime","moesSfTravelTimeV2","gm25TeqMotorDirection","adcbziWorkState","standby","adcbziSituationSet","situationSet","adcbziFault","adcbziChargingStatus","uncharged","charged","adcbziCalibration","calibrate","calibrate_reverse","blTyzMotorDirection","blTyzAutoPower","zsSrCalibration","zsSrMotorSteering","motorSteering","zcLpCharging","not_charging","zcLpAutomaticMode","zcLpSlowMode","slowMode","zcLpButtonPosition","DOWN","fwjzMotorDirection","fwjzCoverLimit","tsCoverTwoMotorState","tsCoverTwoSlowMode","tsCoverTwoMotorDirection","tsCoverTwoCoverType","roman_pole","roller_blind","canopy_curtain","roman_blind","honeycomb_curtain","tsCoverTwoCoverLimit","tsCoverTwoClickControl","down","xSevenCalibration","finish","znUscMotorSteering","zmpOneMotorState","zmpOneMotorDirection","ercSixDirection","forward","back","ercSixRecordRf","record","ercSixClearRf","clear","moesSfCalibration","moesSfBacklight","backlight","moesSfDirection","limitedCoverMotorDirection","cover5PxCalibration","cover5PxBacklight","cover5PxMotorDirection","cover5PxChildLock","cover14A0MotorDirection","cover14A0MotorState","cover14A0SituationSet","fwjz16ebMotorDirection","fwjz16ebCoverLimit","zn2sMotorDirection","lastPowerResponseTime","adcbziCustomWeekProgOne","adcbziCustomWeekProgTwo","adcbziCustomWeekProgThree","adcbziCustomWeekProgFour"}
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
a.numeric=z({{28,nil,28,29,nil,0,0,"adcbzi_total_time","Adcbzi Total Time",{nil,nil,nil,6,nil,1},nil,nil,6},{30,nil,30,"openThreshold",nil,nil,nil,"adcbzi_open_threshold","Adcbzi Open Threshold",{0,100,1,nil,nil,2}},{31,nil,31,"closeThreshold",nil,nil,nil,"adcbzi_close_threshold","Adcbzi Close Threshold",{0,100,1,nil,nil,3}},{32,nil,32,"curtainStatus",nil,nil,nil,"adcbzi_curtain_status","Adcbzi Curtain Status",{0,255,1,nil,nil,4}},{33,nil,33,"totalDistance",nil,0,0,"adcbzi_total_distance","Adcbzi Total Distance",{nil,nil,nil,"m",nil,5},nil,nil,"m"},{34,nil,34,"factoryTest",nil,0,0,"adcbzi_factory_test","Adcbzi Factory Test",{0,100,1,nil,nil,6}},{35,nil,35,36,nil,nil,nil,"ts_cover_two_favorite_position","Ts Cover Two Favorite Position",{0,100,1,"%",nil,7},nil,nil,"%"},{37,nil,37,38,nil,nil,nil,"zn_usc_calibration_time","Zn Usc Calibration Time",{0,500,1,6,nil,8},nil,nil,6},{39,nil,39,29,nil,0,0,"cover14_a0_total_time","Cover14A0Total Time",{nil,nil,nil,"ms",nil,9},nil,nil,"ms"},{40,nil,40,36,nil,nil,nil,"cover14_a0_favorite_position","Cover14A0Favorite Position",{0,100,1,"%",nil,10},nil,nil,"%"},{41,nil,41,38,nil,nil,nil,"zn2s_calibration_time","Zn2s Calibration Time",{0,500,1,6,nil,11},nil,nil,6},{42,nil,42,"travelTime",nil,nil,nil,"moes_sf_travel_time","Moes Sf Travel Time V2",{nil,nil,nil,6,nil,12},nil,nil,6}},G)a.enum=z({{43,nil,43,"gmTwoFiveTeqMotorDirection",nil,nil,nil,"motor_direction","Gm25Teq Motor Direction",{1,2},{1,2},13,14,13},{44,nil,44,"workState",nil,0,0,"adcbzi_work_state","Adcbzi Work State",{45,7,8},{45,7,8},15,16,15},{46,nil,46,47,nil,nil,nil,"adcbzi_situation_set","Adcbzi Situation Set",{17,18},{17,18},17,18,17},{48,nil,48,"fault",nil,0,0,"adcbzi_fault","Adcbzi Fault",{19},{19},19,20,19},{49,nil,49,"chargingStatus",nil,0,0,"adcbzi_charging_status","Adcbzi Charging Status",{19,50,15,51},{19,50,15,51},21,22,21},{52,nil,52,16,nil,nil,nil,"adcbzi_calibration","Adcbzi Calibration",{9,53,54},{9,53,54},23,24,23},{55,nil,55,5,nil,nil,nil,"bl_tyz_motor_direction","Bl Tyz Motor Direction",{1,2},{1,2},25,26,25},{56,nil,56,"autoPower",nil,nil,nil,"bl_tyz_auto_power","Bl Tyz Auto Power",{3,4},{3,4},27,28,27},{57,nil,57,16,nil,nil,nil,"zs_sr_calibration","Zs Sr Calibration",{20,21},{20,21},29,30,29},{58,nil,58,59,nil,nil,nil,"zs_sr_motor_steering","Zs Sr Motor Steering",{22,23},{22,23},31,32,31},{60,nil,60,15,nil,0,0,"zc_lp_charging","Zc Lp Charging",{15,61},{15,61},33,34,33},{62,nil,62,"automaticMode",nil,nil,nil,"zc_lp_automatic_mode","Zc Lp Automatic Mode",{3,4},{3,4},35,36,35},{63,nil,63,64,nil,nil,nil,"zc_lp_slow_mode","Zc Lp Slow Mode",{3,4},{3,4},37,38,37},{65,nil,65,"buttonPosition",nil,nil,nil,"zc_lp_button_position","Zc Lp Button Position",{"UP",66},{"UP",66},39,40,39},{67,nil,67,5,nil,nil,nil,"fwjz_motor_direction","Fwjz Motor Direction",{1,2},{1,2},41,42,41},{68,nil,68,26,nil,nil,nil,"fwjz_cover_limit","Fwjz Cover Limit",{10,11,12,13,24},{10,11,12,13,24},43,44,43},{69,nil,69,27,nil,0,0,"ts_cover_two_motor_state","Ts Cover Two Motor State",{7,8,14},{7,8,14},45,46,45},{70,nil,70,64,nil,nil,nil,"ts_cover_two_slow_mode","Ts Cover Two Slow Mode",{3,4},{3,4},47,48,47},{71,nil,71,5,nil,nil,nil,"ts_cover_two_motor_direction","Ts Cover Two Motor Direction",{1,2},{1,2},49,50,49},{72,nil,72,"coverType",nil,nil,nil,"ts_cover_two_cover_type","Ts Cover Two Cover Type",{73,74,75,76,77},{73,74,75,76,77},51,52,51},{78,nil,78,26,nil,nil,nil,"ts_cover_two_cover_limit","Ts Cover Two Cover Limit",{10,11,12,13,24},{10,11,12,13,24},53,54,53},{79,nil,79,"clickControl",nil,nil,nil,"ts_cover_two_click_control","Ts Cover Two Click Control",{"up",80},{"up",80},55,56,55},{81,nil,81,16,nil,nil,nil,"x_seven_calibration","X Seven Calibration",{25,82},{25,82},57,58,57},{83,nil,83,59,nil,nil,nil,"zn_usc_motor_steering","Zn Usc Motor Steering",{22,23},{22,23},59,60,59},{84,nil,84,27,nil,0,0,"zmp_one_motor_state","Zmp One Motor State",{7,8,14},{7,8,14},61,62,61},{85,nil,85,5,nil,nil,nil,"zmp_one_motor_direction","Zmp One Motor Direction",{1,2},{1,2},63,64,63},{86,nil,86,"direction",nil,nil,nil,"erc_six_direction","Erc Six Direction",{87,88},{87,88},65,66,65},{89,nil,89,"recordRf",nil,nil,nil,"erc_six_record_rf","Erc Six Record Rf",{90,9},{90,9},67,68,67},{91,nil,91,"clearRf",nil,nil,nil,"erc_six_clear_rf","Erc Six Clear Rf",{92,9},{92,9},69,70,69},{93,nil,93,16,nil,nil,nil,"moes_sf_calibration","Moes Sf Calibration",{25,"end"},{25,"end"},71,72,71},{94,nil,94,95,nil,nil,nil,"moes_sf_backlight","Moes Sf Backlight",{"on","off"},{"on","off"},73,74,73},{96,nil,96,5,nil,nil,nil,"moes_sf_direction","Moes Sf Direction",{1,2},{1,2},75,76,75},{97,nil,97,5,nil,nil,nil,"limited_cover_motor_direction","Limited Cover Motor Direction",{1,2},{1,2},77,78,77},{98,nil,98,16,nil,nil,nil,"cover5_px_calibration","Cover5Px Calibration",{20,21},{20,21},79,80,79},{99,nil,99,95,nil,nil,nil,"cover5_px_backlight","Cover5Px Backlight",{3,4},{3,4},81,82,81},{100,nil,100,5,nil,nil,nil,"cover5_px_motor_direction","Cover5Px Motor Direction",{1,2},{1,2},83,84,83},{101,nil,101,"childLock",nil,nil,nil,"cover5_px_child_lock","Cover5Px Child Lock",{3,4},{3,4},85,86,85},{102,nil,102,5,nil,nil,nil,"cover14_a0_motor_direction","Cover14A0Motor Direction",{1,2},{1,2},87,88,87},{103,nil,103,27,nil,0,0,"cover14_a0_motor_state","Cover14A0Motor State",{7,8,14},{7,8,14},89,90,89},{104,nil,104,47,nil,nil,nil,"cover14_a0_situation_set","Cover14A0Situation Set",{18,17},{18,17},91,92,91},{105,nil,105,5,nil,nil,nil,"fwjz_16eb_motor_direction","Fwjz16eb Motor Direction",{1,2},{1,2},93,94,93},{106,nil,106,26,nil,nil,nil,"fwjz_16eb_cover_limit","Fwjz16eb Cover Limit",{10,11,12,13},{10,11,12,13},95,96,95},{107,nil,107,5,nil,nil,nil,"zn2s_motor_direction","Zn2s Motor Direction",{1,2},{1,2},97,98,97}},K)a.text=z({{"last_power_response_time",108,108,0,0,nil,"Last power response time",64},{109,109,"customWeekProgOne",nil,nil,"adcbzi_custom_week_prog_one","Adcbzi Custom Week Prog One",512},{110,110,"customWeekProgTwo",nil,nil,"adcbzi_custom_week_prog_two","Adcbzi Custom Week Prog Two",512},{111,111,"customWeekProgThree",nil,nil,"adcbzi_custom_week_prog_three","Adcbzi Custom Week Prog Three",512},{112,112,"customWeekProgFour",nil,nil,"adcbzi_custom_week_prog_four","Adcbzi Custom Week Prog Four",512}},M)a.driver_message={attribute_name="driverMessage",capability_id="concertmirror08464.driverMessage",emit_name="driver_message",label="Driver message",maximum_length=512}a.by_range_key={}a.by_emit_name={}a.by_capability_id={}
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
