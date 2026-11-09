local a,H={},{"C","off","on","unlock","lock","childLock","child_lock","local_temperature_calibration","temperatureCalibration","normal","low","battery_low","kWh","deadzoneTemperature","deadzone_temperature","batteryLow","auto","manual","energyTodayTwcR01","energyYesterdayTwcR01","maxTempLimitTybacCToThirty","max_temperature_limit","minTempLimitTybacCToThirty","min_temperature_limit","screenBrightnessL2TFMfLevel9","saswellTempCalibration","hhstMaxTemperature","maxTemperature","max_temperature","hhstMinTemperature","hhstTempCalibration","hhstDeadzoneTemperature","hhstLocalTemperatureF","l2tfMinTemperatureLimit","l2tfMaxTemperatureLimit","l2tfDeadzoneTemperature","l2tfEcoTemperatureHeating","l2tfEcoTemperatureCooling","twcr01TempCalibration","twcr01OpenWindowTemperature","twcr01Fault","fault","xixlTempCalibration","xixlError","error","xzakt101BoostTime","bac003MaxTemperature","bac003DeadzoneTemperature","bac003TempCalibration","tybacTempCalibration","tybacDeadzoneTemperature","l2tfLocalTempCalibration","manualModeTybac006","manual_mode","manualModeHhstAutoManualTemp","temporary","pilotWireModeTwcR01","comfort","antifrost","comfort_1","comfort_2","saswellWindowDetection","saswellFrostDetection","saswellChildLock","saswellAwayMode","saswellAntiScaling","saswellBatteryLow","hhstChildLock","hhstTemperatureScale","celsius","fahrenheit","l2tfChildLock","twcr01EcoMode","ecoMode","eco_mode","twcr01OpenWindow","twcr01DeviceModeType","snfdSleep","sleep","snfdTurbo","turbo","snfdQuiet","quiet","snfdSwingMode","xixlBatteryLow","xixlChildLock","etopChildLock","sas936ChildLock","sas936TemporaryLeaving","xzakt101ChildLock","ae940kChildLock","ae720kChildLock","ae669kChildLock","bac003Preset","preset","bac003ChildLock","tybacEcoMode","tybacChildLock","tybacValve","lastPowerResponseTime","etopErrorStatus","saswellSunSchedule","saswellMonSchedule","saswellTueSchedule","saswellWedSchedule","saswellThuSchedule","saswellFriSchedule","saswellSatSchedule"}
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
a.numeric=z({{19,nil,19,"energyTodayTwcRZeroOne",nil,0,0,"energy_today","Energy Today Twc R01",{0,999999,0.001,13,nil,1},nil,nil,13},{20,nil,20,"energyYesterdayTwcRZeroOne",nil,0,0,"energy_yesterday","Energy Yesterday Twc R01",{0,999999,0.001,13,nil,2},nil,nil,13},{21,nil,21,"capqrfwpywdvjzmovhdtays",nil,nil,nil,22,"Max Temp Limit Tybac CTo Thirty",{15,30,1,1,nil,3},nil,nil,1},{23,nil,23,"capqheplozwascjxlchygob",nil,nil,nil,24,"Min Temp Limit Tybac CTo Thirty",{15,30,1,1,nil,4},nil,nil,1},{25,nil,25,"screenBrightnessLTwoTFMfLevelNine",nil,nil,nil,"display_brightness","Screen Brightness L2TFMf Level9",{1,9,1,nil,nil,5}},{26,nil,26,9,nil,nil,nil,8,"Saswell Temp Calibration",{-6,6,1,1,nil,6},nil,nil,1},{27,nil,27,28,nil,nil,nil,29,"Hhst Max Temperature",{15,45,0.5,1,nil,7},nil,nil,1},{30,nil,30,"minTemperature",nil,nil,nil,"min_temperature","Hhst Min Temperature",{5,20,0.5,1,nil,8},nil,nil,1},{31,nil,31,9,nil,nil,nil,8,"Hhst Temp Calibration",{-9.9,9.9,0.1,1,nil,9},nil,nil,1},{32,nil,32,14,nil,nil,nil,15,"Hhst Deadzone Temperature",{0,10,1,1,nil,10},nil,nil,1},{33,nil,33,"localTemperatureF",nil,0,0,"local_temperature_f","Hhst Local Temperature F",{0,200,1,"F",nil,11},nil,nil,"F"},{34,nil,34,"minTemperatureLimit",nil,nil,nil,24,"L2tf Min Temperature Limit",{5,20,0.5,1,nil,12},nil,nil,1},{35,nil,35,"maxTemperatureLimit",nil,nil,nil,22,"L2tf Max Temperature Limit",{15,45,0.5,1,nil,13},nil,nil,1},{36,nil,36,14,nil,nil,nil,15,"L2tf Deadzone Temperature",{0,10,1,1,nil,14},nil,nil,1},{37,nil,37,"ecoTemperatureHeating",nil,nil,nil,"eco_temperature_heating","L2tf Eco Temperature Heating",{5,35,0.5,1,nil,15},nil,nil,1},{38,nil,38,"ecoTemperatureCooling",nil,nil,nil,"eco_temperature_cooling","L2tf Eco Temperature Cooling",{5,35,0.5,1,nil,16},nil,nil,1},{39,nil,39,9,nil,nil,nil,8,"Twcr01Temp Calibration",{-8,8,0.5,1,nil,17},nil,nil,1},{40,nil,40,"openWindowTemperature",nil,nil,nil,"open_window_temperature","Twcr01Open Window Temperature",{0,35,1,1,nil,18},nil,nil,1},{41,nil,41,42,nil,0,0,42,"Twcr01Fault",{0,255,1,nil,nil,19}},{43,nil,43,9,nil,nil,nil,8,"Xixl Temp Calibration",{-9.9,9.9,0.1,1,nil,20},nil,nil,1},{44,nil,44,45,nil,0,0,45,"Xixl Error",{0,255,1,nil,nil,21}},{46,nil,46,"boostTime",nil,nil,nil,"boost_time","Xzakt101Boost Time",{0,24,0.5,"h",nil,22},nil,nil,"h"},{47,nil,47,28,nil,nil,nil,29,"Bac003Max Temperature",{35,45,1,1,nil,23},nil,nil,1},{48,nil,48,14,nil,nil,nil,15,"Bac003Deadzone Temperature",{0,5,1,1,nil,24},nil,nil,1},{49,nil,49,9,nil,nil,nil,8,"Bac003Temp Calibration",{-9,9,1,1,nil,25},nil,nil,1},{50,nil,50,9,nil,nil,nil,8,"Tybac Temp Calibration",{-9,9,0.5,1,nil,26},nil,nil,1},{51,nil,51,14,nil,nil,nil,15,"Tybac Deadzone Temperature",{0,5,1,1,nil,27},nil,nil,1},{52,nil,52,"localTemperatureCalibration",nil,nil,nil,8,"L2tf Local Temp Calibration",{-9,9,1,1,nil,28},nil,nil,1}},G)a.enum=z({{12,12,16,16,nil,0,0,12,"Battery low",{10,11},{10,11},29,30,29},{53,nil,53,"manualModeTybacZeroZeroSix",nil,nil,nil,54,"Manual Mode Tybac006",{2,3},{2,3},31,32,31},{55,nil,55,"capvkzueasiklxvfytdgcrp",nil,nil,nil,54,"Manual Mode Hhst Auto Manual Temp",{17,18,56},{17,18,56},33,34,33},{57,nil,57,"pilotWireModeTwcRZeroOne",nil,nil,nil,"pilot_wire_mode","Pilot Wire Mode Twc R01",{58,"eco",59,2,60,61},{58,"eco",59,2,60,61},35,36,35},{62,nil,62,"windowDetection",nil,nil,nil,"window_detection","Saswell Window Detection",{2,3},{2,3},37,38,37},{63,nil,63,"frostDetection",nil,nil,nil,"frost_detection","Saswell Frost Detection",{2,3},{2,3},39,40,39},{64,nil,64,6,nil,nil,nil,7,"Saswell Child Lock",{4,5},{4,5},41,42,41},{65,nil,65,"awayMode",nil,nil,nil,"away_mode","Saswell Away Mode",{2,3},{2,3},43,44,43},{66,nil,66,"antiScaling",nil,nil,nil,"anti_scaling","Saswell Anti Scaling",{2,3},{2,3},45,46,45},{67,nil,67,16,nil,0,0,12,"Saswell Battery Low",{10,11},{10,11},47,48,47},{68,nil,68,6,nil,nil,nil,7,"Hhst Child Lock",{4,5},{4,5},49,50,49},{69,nil,69,"temperatureScale",nil,nil,nil,"temperature_scale","Hhst Temperature Scale",{70,71},{70,71},51,52,51},{72,nil,72,6,nil,nil,nil,7,"L2tf Child Lock",{4,5},{4,5},53,54,53},{73,nil,73,74,nil,nil,nil,75,"Twcr01Eco Mode",{2,3},{2,3},55,56,55},{76,nil,76,"openWindow",nil,nil,nil,"open_window","Twcr01Open Window",{2,3},{2,3},57,58,57},{77,nil,77,"deviceModeType",nil,nil,nil,"device_mode_type","Twcr01Device Mode Type",{2,3},{2,3},59,60,59},{78,nil,78,79,nil,nil,nil,79,"Snfd Sleep",{2,3},{2,3},61,62,61},{80,nil,80,81,nil,nil,nil,81,"Snfd Turbo",{2,3},{2,3},63,64,63},{82,nil,82,83,nil,nil,nil,83,"Snfd Quiet",{2,3},{2,3},65,66,65},{84,nil,84,"swingMode",nil,nil,nil,"swing_mode","Snfd Swing Mode",{2,3},{2,3},67,68,67},{85,nil,85,16,nil,0,0,12,"Xixl Battery Low",{10,11},{10,11},69,70,69},{86,nil,86,6,nil,nil,nil,7,"Xixl Child Lock",{4,5},{4,5},71,72,71},{87,nil,87,6,nil,nil,nil,7,"Etop Child Lock",{4,5},{4,5},73,74,73},{88,nil,88,6,nil,nil,nil,7,"Sas936Child Lock",{4,5},{4,5},75,76,75},{89,nil,89,"temporaryLeaving",nil,nil,nil,"temporary_leaving","Sas936Temporary Leaving",{2,3},{2,3},77,78,77},{90,nil,90,6,nil,nil,nil,7,"Xzakt101Child Lock",{4,5},{4,5},79,80,79},{91,nil,91,6,nil,nil,nil,7,"Ae940k Child Lock",{4,5},{4,5},81,82,81},{92,nil,92,6,nil,nil,nil,7,"Ae720k Child Lock",{4,5},{4,5},83,84,83},{93,nil,93,6,nil,nil,nil,7,"Ae669k Child Lock",{4,5},{4,5},85,86,85},{94,nil,94,95,nil,nil,nil,95,"Bac003Preset",{17,18},{17,18},87,88,87},{96,nil,96,6,nil,nil,nil,7,"Bac003Child Lock",{4,5},{4,5},89,90,89},{97,nil,97,74,nil,nil,nil,75,"Tybac Eco Mode",{2,3},{2,3},91,92,91},{98,nil,98,6,nil,nil,nil,7,"Tybac Child Lock",{4,5},{4,5},93,94,93},{99,nil,99,"valve",nil,0,0,"valve","Tybac Valve",{"open","close"},{"open","close"},95,96,95}},K)a.text=z({{"last_power_response_time",100,100,0,0,nil,"Last power response time",64},{101,101,"errorStatus",0,0,"error_status","Etop Error Status",256},{102,102,"sunSchedule",nil,nil,"saswell_sun_schedule","Saswell Sun Schedule"},{103,103,"monSchedule",nil,nil,"saswell_mon_schedule","Saswell Mon Schedule"},{104,104,"tueSchedule",nil,nil,"saswell_tue_schedule","Saswell Tue Schedule"},{105,105,"wedSchedule",nil,nil,"saswell_wed_schedule","Saswell Wed Schedule"},{106,106,"thuSchedule",nil,nil,"saswell_thu_schedule","Saswell Thu Schedule"},{107,107,"friSchedule",nil,nil,"saswell_fri_schedule","Saswell Fri Schedule"},{108,108,"satSchedule",nil,nil,"saswell_sat_schedule","Saswell Sat Schedule"}},M)a.driver_message={attribute_name="driverMessage",capability_id="concertmirror08464.driverMessage",emit_name="driver_message",label="Driver message",maximum_length=512}a.by_range_key={}a.by_emit_name={}a.by_capability_id={}
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
