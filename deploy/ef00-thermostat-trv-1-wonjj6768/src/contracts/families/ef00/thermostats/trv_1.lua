local a,b,t,f,m,j=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family",require"contracts.helpers.ef00",require"contracts.helpers.ef00_thermostat_metadata",require"contracts.helpers.ef00_thermostats"local c=a.converter
local V,d=t.definition_registry()local M=c.lookup_from_to{off=false,on=true}
local function n(aj,ad)
return a.dp_bitmap(35,{name="error_or_battery_low",read_only=true,converter=c.error_or_battery_low(),emit=j.error_or_battery_low_emitter(aj,ad)})
end
local E=c.lookup_from_to{off=false,on=true}local ab=m.attach({profile="thermostats-siterwell-gs361a",package_group="trv-1",a.dp_current_heating_setpoint(2,{scale=10,emit=b.heating_setpoint"C"}),a.dp_local_temperature(3,{scale=10,emit=b.temperature"C"}),a.dp_system_mode(4,{converter=c.lookup_from_to{off=0,auto=1,heat=2},emit=b.thermostat_mode()}),a.dp_binary(7,{name="gs361a_child_lock",emit=b.gsHFourChildLock(),converter=E}),a.dp_binary(18,{name="gs361a_window_detection",emit=b.gsHFourWindowDetection(),converter=E}),a.dp_binary(20,{name="gs361a_valve_detection",emit=b.gsHFourValveDetection(),converter=E}),a.dp_battery(21,{read_only=true,emit=b.battery()}),a.dp_numeric(109,{name="running_state",read_only=true,emit=b.thermostat_operating_state(),
converter=c.from_only(function(e)return tonumber(e)~=0 and"heating"or"idle"end)
})},{"off","auto","heat"},5,30,0.5)d(ab,t.create_fingerprints("TS0601",{"_TZE200_04yfvweb","_TZE200_2cs6g9i7","_TZE200_hhrtiq0x","_TZE200_jeaxp72v","_TZE200_kfvq6avy","_TZE200_lrznf59v","_TZE200_owwdxjbx","_TZE200_ps5v5jor","_TZE200_zivfvd7h","_TZE204_woww89ip"}))local N={profile="thermostats-alecto-smart-heat10",package_group="trv-1",a.dp_current_heating_setpoint(2,{scale=10}),a.dp_local_temperature(3,{scale=10}),a.dp_system_mode(4,{converter=c.lookup_from_to{off=0,auto=1,heat=2}}),a.dp_binary(7,{name="alecto_child_lock",emit=b.alectoSmartHeat10ChildLock(),converter=M}),a.dp_binary(18,{name="alecto_window_detection",emit=b.alectoSmartHeat10WindowDetection(),converter=M}),a.dp_battery(21,{emit=b.battery()})}d(N,{t.create_fingerprint("_TYST11_8daqwrsj","daqwrsj"),t.create_fingerprint("_TZE200_8daqwrsj","TS0601")})local z,s,v=j.valve_position_to_running_state,j.variant1_mode_from_device,j.variant1_mode_to_device


local function l(e)
local ag=tonumber(e)if ag==nil then
return nil
end
if ag==0 then
return"heating"end
if ag==1 then
return"idle"end
end
local D,O,G=c.lookup_from_to{heat=true,off=false},c.lookup_from_to{heating=true,idle=false},c.lookup_from_to{heating=0,idle=1}
local function w(e)
local F={[0]="auto",[1]="heat",[2]="off"}return F[tonumber(e)]
end
local function x(e)
local F={auto=0,heat=1,off=2}return F[e]
end
local aq={profile="thermostats-thermostat-classic-trv",package_group="trv-1",force_time_updates=true,a.dp_current_heating_setpoint(2,{scale=10,emit=b.heating_setpoint"C"}),a.dp_local_temperature(3,{scale=10,emit=b.temperature"C"}),a.dp_enum(4,{name="preset",emit=b.classicTrvPreset(),converter=c.lookup_from_to{schedule=0,manual=1,boost=2,complex=3,comfort=4,eco=5,away=6}}),a.dp_system_mode(4,{from_device=w,to_device=x,emit=b.thermostat_mode()}),a.dp_binary(7,{name="child_lock",emit=b.classicTrvChildLock(),converter=c.lookup_from_to{unlock=false,lock=true}}),a.dp_binary(20,{name="valve_detection",emit=b.classicTrvValveDetection(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_battery(21,{}),a.dp_local_temperature_calibration(44,{scale=10,emit=b.classicTrvTempCalibration()}),a.dp_numeric(102,{name="min_temperature",emit=b.classicTrvMinTemperature()}),a.dp_numeric(103,{name="max_temperature",emit=b.classicTrvMaxTemperature()}),a.dp_raw(104,{name="window_detection",emit=b.classicTrvWindowDetection(),
converter=c.from_only(function(e)
local ar=tostring(e)if #ar<1 then
return nil
end
return string.byte(ar,1)~=0 and"on"or"off"
end)
}),a.dp_numeric(105,{name="boost_time",emit=b.classicTrvBoostTime()}),a.dp_enum(106,{name="force",emit=b.classicTrvForce(),converter=c.lookup_from_to{normal=0,open=1,close=2}}),a.dp_numeric(107,{name="comfort_temperature",emit=b.classicTrvComfortTemperature()}),a.dp_numeric(108,{name="eco_temperature",emit=b.classicTrvEcoTemperature()}),a.dp_numeric(109,{name="position",read_only=true,emit=b.classicTrvPosition()}),a.dp_running_state(109,{datatype=a.DP_TYPE_VALUE,read_only=true,from_device=z,emit=b.thermostat_operating_state()}),a.dp_binary(110,{name="battery_low",read_only=true,emit=b.classicTrvBatteryLow(),
converter=c.from_only(function(e)
return e and"low"or"normal"
end)
}),a.dp_enum(111,{name="week",emit=b.classicTrvWeek(),converter=c.lookup_from_to{["5_2"]=0,["6_1"]=1,["7"]=2}}),a.dp_raw(112,{name="schedule_workday"}),a.dp_raw(113,{name="schedule_holiday"}),a.dp_numeric(114,{name="away_temperature",emit=b.classicTrvAwayTemperature()}),a.dp_binary(115,{name="window_open",read_only=true,emit=b.classicTrvWindowOpen(),
converter=c.from_only(function(e)
return e and"open"or"closed"
end)
}),a.dp_binary(116,{name="auto_lock",emit=b.classicTrvAutoLock(),converter=c.lookup_from_to{manual=false,auto=true}}),a.dp_numeric(117,{name="away_days",emit=b.classicTrvAwayDays()})}d(aq,f.ts0601_fingerprints{"_TZE200_ckud7u2l","_TZE200_ywdxldoj","_TZE200_do5qy8zo","_TZE200_cwnjrr72","_TZE200_pvvbommb","_TZE200_9sfg7gm0","_TZE200_2atgpdho","_TZE200_znlqjmih","_TZE284_znlqjmih","_TZE200_8thwkzxl","_TZE200_4eeyebrt","_TZE200_8whxpsiw","_TZE200_7fqkphoq","_TZE200_rufdtfyv","_TZE200_lpwgshtl","_TZE200_rk1wojce","_TZE200_rndg81sf","_TZE200_qjp4ynvi","_TZE200_xby0s3ta","_TZE200_cpmgn2cf"})local Z={profile="thermostats-thermostat-hy607w",package_group="trv-1",a.dp_local_temperature(16,{scale=10,emit=b.temperature"C"}),a.dp_current_heating_setpoint(50,{name="occupied_heating_setpoint",scale=10,emit=b.heating_setpoint"C"}),a.dp_on_off(125,{name="switch",emit=b.switch()}),a.dp_binary(102,{name="running_state",read_only=true,converter=O,emit=b.thermostat_operating_state()}),a.dp_enum(128,{name="mode_state",emit=b.hy607wModeState(),
from_device=function(e)
if type(e)=="table"then
e=e[1]end
local F={[0]="manual",[1]="auto",[3]="tempOverride"}return F[tonumber(e)]
end,
to_device=function(e)
local F={manual=0,auto=1,tempOverride=3}return F[e]
end
})}d(Z,f.ts0601_fingerprints{"_TZE200_khah2lkr"})local T={profile="thermostats-thermostat-zg-wk-da",package_group="trv-1",a.dp_binary(1,{name="system_mode",converter=D}),a.dp_current_heating_setpoint(2,{scale=10}),a.dp_local_temperature(3,{scale=10}),a.dp_enum(4,{name="preset",emit=b.thermostatPresetZgWkDaAuto(),converter=c.lookup_from_to{manual=0,auto=1}}),a.dp_child_lock(9,{name="child_lock",emit=b.zgwkdaChildLock()}),a.dp_local_temperature_calibration(19,{scale=1,emit=b.zgwkdaTempCalibration()}),a.dp_enum(102,{name="running_state",converter=G,emit=b.thermostat_operating_state()})}d(T,f.ts0601_fingerprints{"_TZE204_atdqo4nj"})local ac={profile="thermostats-thermostat-tgm50",package_group="trv-1",respond_to_mcu_version_response=true,a.dp_binary(1,{name="system_mode",converter=D}),a.dp_current_heating_setpoint(2,{scale=10}),a.dp_local_temperature(3,{scale=10}),a.dp_child_lock(9,{name="child_lock",emit=b.tgm50ChildLock()}),a.dp_max_temperature_limit(15,{scale=10,emit=b.tgm50MaxTemperatureLimit()}),a.dp_local_temperature_calibration(19,{scale=10,emit=b.tgm50TempCalibration()}),a.dp_enum(4,{name="preset",emit=b.tgm50Preset(),converter=c.lookup_from_to{manual=0,auto=1,eco=3}}),a.dp_running_state(101,{converter=c.lookup_from_to{idle=0,heating=1},emit=b.thermostat_operating_state()}),a.dp_frost_protection(102,{emit=b.tgm50FrostProtection()}),a.dp_binary(103,{name="factory_reset",emit=b.tgm50FactoryReset(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_temperature_sensor_select_internal_external_both(106,{name="sensor",emit=b.tgm50Sensor()}),a.dp_temperature(107,{name="temperature_delta",scale=10,emit=b.tempDeltaTgmCToTen()}),a.dp_enum(110,{name="backlight_mode",emit=b.tgm50BacklightMode(),converter=c.lookup_from_to{off=0,alwaysLow=1,alwaysMid=2,alwaysHigh=3}})}d(ac,f.ts0601_fingerprints{"_TZE204_cvub6xbb","_TZE284_cvub6xbb","_TZE204_mwomyz5n"})local W=m.attach_setpoint_only({profile="thermostats-thermostat-tbgecldg",package_group="trv-1",time_start="2000",a.dp_system_mode(1,{converter=c.lookup_from_to{auto=0,heat=1,off=2}}),a.dp_enum(2,{name="preset",emit=b.tbgePreset(),converter=c.lookup_from_to{auto=0,manual=1,holiday=2}}),a.dp_current_heating_setpoint(16,{
converter=c.from_to(c.divide_by(2),function(e)
if type(e)~="number"or e<0.5 or e>29.5 or(e*2)%1~=0 then
return nil
end
return e*2
end),
emit=b.heating_setpoint"C"}),a.dp_local_temperature(24,{scale=10,emit=b.temperature"C"}),a.dp_child_lock(30,{name="child_lock",converter=c.lookup_from_to{unlock=false,lock=true},emit=b.tbgeChildLock()}),
a.dp_battery(34,{emit=b.battery(),converter=c.from_only(function(e)return math.max(0,math.min(100,(tonumber(e)or 50)-50))end)}),
a.dp_comfort_temperature(101,{scale=2,emit=b.tbgeComfortTemperatureV2()}),a.dp_eco_temperature(102,{scale=2,emit=b.tbgeEcoTemperatureV2()}),a.dp_holiday_temperature(103,{scale=2,emit=b.tbgeHolidayTemperatureV2()}),a.dp_local_temperature_calibration(104,{scale=10,emit=b.tbgeLocalTempCalibration()}),a.dp_current_heating_setpoint(105,{name="auto_temperature",scale=2,emit=b.tbgeAutoTemperatureV2()}),a.dp_boost_heating(106,{converter=c.lookup_from_to{off=false,on=true},emit=b.tbgeBoostHeating()}),a.dp_window_open(107,{read_only=true,emit=b.tbgeWindowOpenStatus()}),a.dp_open_window_temperature(116,{scale=2,emit=b.tbgeOpenWindowTemperature()}),a.dp_open_window_time(117,{emit=b.tbgeOpenWindowTime()}),a.dp_boost_time(118,{emit=b.tbgeBoostTime()})},0.5,29.5,0.5)d(W,f.ts0601_fingerprints{"_TZE204_tbgecldg","_TZE284_tbgecldg","_TZE200_tbgecldg"})local P={profile="thermostats-thermostat-g2ki0ejr",package_group="trv-1",a.dp_system_mode(1,{converter=c.lookup_from_to{auto=0,heat=1,off=2}}),a.dp_enum(2,{name="preset",emit=b.g2kiPreset(),converter=c.lookup_from_to{auto=0,holiday=1,manual=2,comfort=3}}),a.dp_current_heating_setpoint(4,{scale=10}),a.dp_local_temperature(5,{scale=10}),a.dp_battery(6,{emit=b.battery()}),a.dp_child_lock(7,{name="child_lock",emit=b.g2kiChildLock()}),a.dp_max_temperature_limit(9,{scale=10,emit=b.g2kiMaxTemperatureLimit()}),a.dp_min_temperature_limit(10,{scale=10,emit=b.g2kiMinTemperatureLimit()}),a.dp_window_detection(14,{emit=b.g2kiWindowDetection()}),a.dp_open_window_temperature(16,{scale=10,emit=b.g2kiOpenWindowTemperature()}),a.dp_open_window_time(17,{emit=b.g2kiOpenWindowTime()}),a.dp_binary(19,{name="factory_reset",emit=b.g2kiFactoryReset()}),a.dp_holiday_temperature(21,{scale=1,emit=b.g2kiHolidayTemperature()}),a.dp_comfort_temperature(24,{scale=10,emit=b.g2kiComfortTemperature()}),a.dp_eco_temperature(25,{scale=10,emit=b.g2kiEcoTemperature()}),a.dp_frost_protection(36,{emit=b.g2kiFrostProtection()}),a.dp_valve_state(49,{emit=b.g2kiValveState()})}d(P,f.ts0601_fingerprints{"_TZE204_g2ki0ejr"})local S={profile="thermostats-thermostat-cgr0rhza",package_group="trv-1",force_time_updates=true,a.dp_enum(2,{name="preset",emit=b.cgr0Preset(),converter=c.lookup_from_to{manual=0,schedule=1,eco=2,comfort=3,antifrost=4,off=5}}),a.dp_current_heating_setpoint(4,{scale=10}),a.dp_local_temperature(5,{scale=10}),a.dp_battery(6,{emit=b.battery()}),a.dp_child_lock(7,{name="child_lock",emit=b.cgr0ChildLock()}),a.dp_window_detection(8,{emit=b.cgr0WindowDetection()}),a.dp_open_window(14,{emit=b.cgr0OpenWindow()}),a.dp_holiday_temperature(21,{scale=1,emit=b.cgr0HolidayTemperature()}),a.dp_comfort_temperature(24,{scale=10,emit=b.cgr0ComfortTemperature()}),a.dp_eco_temperature(25,{scale=10,emit=b.cgr0EcoTemperature()}),n(b.cgr0FaultAlarm(),b.cgr0BatteryLow()),a.dp_frost_protection(36,{emit=b.cgr0FrostProtection()}),a.dp_scale_protection(39,{emit=b.cgr0ScaleProtection()}),a.dp_local_temperature_calibration(47,{scale=1,emit=b.cgr0LocalTempCalibration()}),a.dp_valve_state(49,{emit=b.cgr0ValveState()}),a.dp_boost_heating(101,{emit=b.cgr0BoostHeating()}),a.dp_boost_time(102,{emit=b.cgr0BoostTime()})}d(S,f.ts0601_fingerprints{"_TZE284_cgr0rhza"})
local function Y(e)
if type(e)=="string"then return{e:byte(1,#e)}end
if type(e)=="table"then return e end
end
local h={
from=function(e)
local g=Y(e)if not g or #g<4 then return nil end
local ak=g[2]if ak<2 or ak>16 or ak%2~=0 or #g~=ak+2 then return nil end
local aa={}for i=3,#g,2 do
local B,minute=math.floor(g[i]/10),(g[i]%10)*10
if B>23 or minute>59 then return nil end
aa[#aa+1]=string.format("%02d:%02d/%.1f",B,minute,g[i+1]/2)end
return table.concat(aa," ")
end,
to=function(e)
if type(e)~="string"then return nil end
local g={7,0}for at in e:gmatch"%S+"do
local B,minute,temperature=at:match"^(%d%d):(%d%d)/(%d%d?%.?%d?)$"B,minute,temperature=tonumber(B),tonumber(minute),tonumber(temperature)if not B or B>23 or minute>59 or minute%10~=0
or temperature>99.5 or temperature*2%1~=0 or #g>=18 then return nil end
g[#g+1]=B*10+minute/10
g[#g+1]=temperature*2
end
if #g==2 then return nil end
g[2]=#g-2
return string.char(table.unpack(g))
end
}
local function ae(au)
local ai,K,day,B,minute=au:match"^(%d%d%d%d)/(%d%d)/(%d%d) (%d%d):(%d%d)$"ai,K,day,B,minute=tonumber(ai),tonumber(K),tonumber(day),tonumber(B),tonumber(minute)if not ai or ai<1970 or ai>2106 or K<1 or K>12 or day<1 or day>31 or B>23 or minute>59 then return nil end
local an=ai-(K<=2 and 1 or 0)local aw=math.floor(an/400)local av,ay=an-aw*400,math.floor((153*(K+(K>2 and-3 or 9))+2)/5)+day-1

local ax=aw*146097+av*365+math.floor(av/4)-math.floor(av/100)+ay-719468
local I=ax*86400+B*3600+minute*60
if I<0 or I>4294967295 or os.date("!%Y/%m/%d %H:%M",I)~=au then return nil end
return I
end
local ah={
from=function(e)
local g=Y(e)if not g or #g~=8 then return nil end
local H,last=g[1]*16777216+g[2]*65536+g[3]*256+g[4],g[5]*16777216+g[6]*65536+g[7]*256+g[8]return os.date("!%Y/%m/%d %H:%M",H).." | "..os.date("!%Y/%m/%d %H:%M",last)
end,
to=function(e)
if type(e)~="string"then return nil end
local H,last=e:match"^(.-)%s*|%s*(.-)$"if not H then return nil end
H,last=ae(H),ae(last)if not H or not last or last<H then return nil end
return string.pack(">I4I4",H,last)
end
}local L={profile="thermostats-thermostat-trv603wz",package_group="trv-1",force_time_updates=true,a.dp_enum(2,{name="preset",emit=b.trv603wzPreset(),converter=c.lookup_from_to{schedule=0,holiday=1,manual=2}}),a.dp_current_heating_setpoint(4,{scale=10}),a.dp_local_temperature(5,{scale=10}),a.dp_battery(6,{emit=b.battery()}),a.dp_child_lock(7,{name="child_lock",emit=b.trv603wzChildLock()}),a.dp_window_detection(14,{emit=b.trv603wzWindowDetection()}),a.dp_binary(15,{name="window_open",read_only=true,emit=b.trv603wzWindowOpen(),
converter=c.from_only(function(e)
return e and"open"or"closed"
end)
}),a.dp_holiday_temperature(21,{scale=10,emit=b.trv603wzHolidayTemperature()}),a.dp_frost_protection(36,{emit=b.trv603wzFrostProtection()}),a.dp_binary(39,{name="anti_scale",emit=b.trv603wzAntiScale(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_local_temperature_calibration(47,{scale=10,emit=b.trv603wzLocalTempCalibration()}),a.dp_valve_state(49,{name="valve_status",emit=b.trv603wzValveStatus()}),a.dp_boost_heating(101,{emit=b.trv603wzBoostHeating()}),a.dp_boost_time(102,{emit=b.trv603wzBoostTime()}),a.dp_raw(103,{name="schedule_monday",converter=h,emit=b.trv603Monday()}),a.dp_raw(104,{name="schedule_tuesday",converter=h,emit=b.trv603Tuesday()}),a.dp_raw(105,{name="schedule_wednesday",converter=h,emit=b.trv603Wednesday()}),a.dp_raw(106,{name="schedule_thursday",converter=h,emit=b.trv603Thursday()}),a.dp_raw(107,{name="schedule_friday",converter=h,emit=b.trv603Friday()}),a.dp_raw(108,{name="schedule_saturday",converter=h,emit=b.trv603Saturday()}),a.dp_raw(109,{name="schedule_sunday",converter=h,emit=b.trv603Sunday()}),a.dp_raw(110,{name="holiday_time",converter=ah,emit=b.trv603Holiday()}),a.dp_enum(111,{name="screen_orientation",emit=b.trv603wzScreenOrientation(),converter=c.lookup_from_to{up=0,right=1,down=2,left=3}}),a.dp_temperature(112,{name="antifrost_temperature",scale=10,emit=b.trv603wzAntifrostTemperature()}),a.dp_system_mode(113,{converter=c.lookup_from_to{auto=false,off=true}}),a.dp_local_temperature_calibration(114,{scale=10,emit=b.trv603wzLocalTempCalibration()}),a.dp_numeric(115,{name="programming_mode",emit=b.trv603wzProgrammingMode()}),a.dp_eco_temperature(116,{scale=10,emit=b.trv603wzEcoTemperature()}),a.dp_comfort_temperature(117,{scale=10,emit=b.trv603wzComfortTemperature()}),a.dp_numeric(118,{name="fault_code",read_only=true,emit=b.trv603wzFaultCode()})}d(L,f.ts0601_fingerprints{"_TZE284_ymldrmzx"})local X=m.attach({profile="thermostats-thermostat-zht002",package_group="trv-1",time_start="2000",a.dp_on_off(1),a.dp_binary(1,{name="system_mode",converter=D,emit=b.thermostat_mode()}),a.dp_enum(2,{name="programming_mode",emit=b.zht002ProgrammingMode(),converter=c.lookup_from_to{auto=0,manual=1}}),a.dp_local_temperature(16,{scale=10,read_only=true,emit=b.temperature"C"}),a.dp_min_temperature_limit(18,{name="min_temperature",scale=1,emit=b.zht002MinTemperature()}),a.dp_local_temperature_calibration(19,{scale=1,emit=b.zht002TempCalibration()}),a.dp_enum(23,{name="working_day",emit=b.zht002WorkingDay(),converter=c.lookup_from_to{disabled=0,fiveTwo=1,sixOne=2,seven=3}}),a.dp_temperature_sensor_select(32,{name="sensor",emit=b.zht002Sensor(),converter=c.lookup_from_to{["in"]=0,ou=1,al=2}}),a.dp_max_temperature_limit(34,{name="max_temperature",scale=1,emit=b.zht002MaxTemperature()}),a.dp_child_lock(39,{name="child_lock",emit=b.zht002ChildLock()}),a.dp_eco_mode(40,{emit=b.zht002EcoMode()}),a.dp_valve_state(47,{read_only=true,emit=b.zht002ValveState(),converter=c.from_only(c.lookup_value{[0]="closed",[1]="open"})}),a.dp_running_state(47,{read_only=true,emit=b.thermostat_operating_state(),converter=c.lookup_from_to{idle=0,heating=1}}),a.dp_current_heating_setpoint(50,{scale=1,emit=b.heating_setpoint"C"}),a.dp_max_temperature_limit(101,{name="max_temperature_limit",scale=1,emit=b.maxTempLimitZhtCToSeventy()}),a.dp_deadzone_temperature(102,{scale=1,emit=b.zht002DeadzoneTemperature()})},{"off","heat"},0,50,1)d(X,f.ts0601_fingerprints{"_TZE204_xalsoe3m"})local Q={profile="thermostats-thermostat-trv1",package_group="trv-1",force_time_updates=true,a.dp_system_mode(1,{from_device=s,to_device=v,emit=b.thermostat_mode()}),a.dp_enum(1,{name="preset",emit=b.trv1Preset(),converter=c.lookup_from_to{auto=0,manual=1,off=2,on=3}}),a.dp_current_heating_setpoint(2,{scale=10}),a.dp_local_temperature(3,{scale=10}),a.dp_boost_heating(4,{emit=b.trv1BoostHeating()}),a.dp_numeric(5,{name="boost_time",emit=b.trv1BoostTime()}),a.dp_running_state(6,{converter=c.lookup_from_to{heating=1,idle=0},emit=b.thermostat_operating_state()}),a.dp_enum(7,{name="window",read_only=true,emit=b.trv1Window(),converter=c.from_only(c.lookup_value{[0]="close",[1]="open"})}),a.dp_window_detection(8,{emit=b.trv1WindowDetection()}),a.dp_child_lock(12,{emit=b.trv1ChildLock()}),a.dp_battery(13,{emit=b.battery()}),a.dp_binary(14,{name="alarm_switch",read_only=true,emit=b.trv1AlarmSwitch(),
converter=c.from_only(function(e)
if e==true or e==1 then return"on"end
if e==false or e==0 then return"off"end
end)
}),a.dp_min_temperature_limit(15,{name="min_temperature",scale=10,emit=b.trv1MinTemperature()}),a.dp_max_temperature_limit(16,{name="max_temperature",scale=10,emit=b.trv1MaxTemperature()}),a.dp_local_temperature_calibration(101,{scale=10,emit=b.trv1TempCalibration()}),a.dp_numeric(102,{name="position",read_only=true,converter=c.divide_by_pair(10),emit=b.trv1Position()}),a.dp_enum(116,{name="screen_orientation",emit=b.trv1ScreenOrientation(),converter=c.lookup_from_to{up=0,down=2}}),a.dp_enum(152,{name="display_brightness",emit=b.trv1DisplayBrightness(),converter=c.lookup_from_to{high=0,middle=1,low=2}}),a.dp_enum(153,{name="hysteresis_mode",emit=b.trv1Hysteresis(),converter=c.lookup_from_to{comfort=0,eco=1}}),a.dp_numeric(154,{name="switch_deviation_eco",converter=c.divide_by_pair(10),emit=b.trv1SwitchDeviationEco()})}d(Q,f.ts0601_fingerprints{"_TZE200_a4bpgplm","_TZE200_bvrlmajk","_TZE200_dv8abrrz","_TZE200_z1tyspqw"})local p,o="_trv06_time_zone_hours",c.pipe(c.wrap_signed(4294967296,0x7FFFFFFF).from,c.divide_by(10))
local function J(q,am)
local ap=os.time()return a.send_time_with_offset(q,946684800,ap,ap+am*3600)
end
local k=m.attach({profile="thermostats-thermostat-trv06",package_group="trv-1",time_start="2000",
time_handler=function(q)
return J(q,q:get_field(p)or 0)
end,
protocol_writers={
trv06_time_zone=function(q,am)
if not J(q,am)then return false end
q:set_field(p,am,{persist=true})return true
end
},a.dp_system_mode(2,{converter=c.lookup_from_to{auto=0,heat=1,off=2},emit=b.thermostat_mode()}),a.dp_running_state(3,{read_only=true,from_device=l,emit=b.thermostat_operating_state()}),a.dp_current_heating_setpoint(4,{from_device=o,to_device=c.multiply_by(10),signed=true,emit=b.heating_setpoint"C"}),a.dp_local_temperature(5,{from_device=o,read_only=true,emit=b.temperature"C"}),a.dp_binary(7,{name="child_lock",emit=b.trv06ChildLock(),converter=c.lookup_from_to{unlock=false,lock=true}}),a.dp_bitmap(35,{name="error",read_only=true,emit=b.trv06ErrorBitmap(),converter=c.wrap_signed(4294967296,0x7FFFFFFF)}),a.dp_bitmap(35,{name="battery_low",read_only=true,emit=b.trv06BatteryLow(),converter=c.from_only(j.error_or_battery_low_state)}),a.dp_binary(36,{name="frost_protection",emit=b.trv06FrostProtection(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_binary(39,{name="scale_protection",emit=b.trv06ScaleProtection(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_local_temperature_calibration(47,{scale=1,emit=b.trv06TempCalibration()}),a.dp_numeric(101,{name="pi_heating_demand",read_only=true,emit=b.trv06PiHeatingDemand()})},{"auto","heat","off"},5,35,0.5)local U=k.runtime_start
k.runtime_start=function(q)
U(q)q:emit_component_event({id="main"},b.trv06TimeZone()(q,q:get_field(p)or 0))
end
for as,day in ipairs{{"monday",b.trv06Monday},{"tuesday",b.trv06Tuesday},{"wednesday",b.trv06Wednesday},{"thursday",b.trv06Thursday},{"friday",b.trv06Friday},{"saturday",b.trv06Saturday},{"sunday",b.trv06Sunday}}do
k[#k+1]=a.dp_raw(27+as,{name="schedule_"..day[1],converter=j.daily_schedule(as,6),emit=day[2]()})end
d(k,f.ts0601_fingerprints{"_TZE200_bvu2wnxz","_TZE200_6rdj8dzm","_TZE200_9xfjixap","_TZE200_jkfbph7l","_TZE200_rxntag7i","_TZE200_4utwozi2","_TZE200_yqgbrdyo","_TZE284_p3dbf6qs","_TZE200_rxq4iti9","_TZE204_ogx8u5z6","_TZE200_4utwoz2","_TZE284_ogx8u5z6","_TZE284_o3x45p96","_TZE284_c6wv4xyo","_TZE204_o3x45p96","_TZE200_ow09xlxm","_TZE284_rv6iuyxb","_TZE200_rv6iuyxb","_TZE200_suxywabt","_TZE200_d3z1ukqw"})
local function u(e)
if tonumber(e)==4 then
return"off"end
return"heat"
end
local function y(e)
if e=="off"then
return 4
end
if e=="heat"then
return 0
end
return nil
end
local A={profile="thermostats-thermostat-thah202001",package_group="trv-1",force_time_updates=true,a.dp_system_mode(2,{from_device=u,to_device=y}),a.dp_enum(2,{name="preset",emit=b.thahPreset(),converter=c.lookup_from_to{manual=0,eco=1,away=2,holiday=3}}),a.dp_running_state(3,{converter=c.lookup_from_to{heating=0,idle=1}}),a.dp_current_heating_setpoint(4,{scale=10}),a.dp_local_temperature(5,{scale=10}),a.dp_battery(6,{}),a.dp_binary(14,{name="window_detection",emit=b.thahWindowDetection(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_enum(15,{name="window_open",read_only=true,emit=b.thahWindowOpen(),converter=c.from_only(c.lookup_value{[0]="open",[1]="close"})}),a.dp_holiday_temperature(21,{scale=10,emit=b.thahHolidayTemperature()}),a.dp_eco_temperature(24,{scale=10,emit=b.thahEcoTemperature()}),a.dp_numeric(25,{name="away_temperature",scale=10,emit=b.thahAwayTemperature()}),n(b.thahErrorStatus(),b.thahBatteryLow()),a.dp_binary(36,{name="frost_protection",emit=b.thahFrostProtection(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_binary(39,{name="scale_protection",emit=b.thahScaleProtection(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_local_temperature_calibration(47,{scale=10,emit=b.thahLocalTempCalibration()}),a.dp_numeric(101,{name="operating_time",scale=10,read_only=true,emit=b.thahOperatingTime()}),a.dp_numeric(102,{name="scale_protection_remaining_time",scale=10,read_only=true,emit=b.thahScaleRemainingTime()})}d(A,f.ts0601_fingerprints{"_TZE204_m5r5nlxc"})local R={profile="thermostats-thermostat-trv06b",package_group="trv-1",time_start="2000",a.dp_system_mode(2,{converter=c.lookup_from_to{auto=0,heat=1,off=2}}),a.dp_running_state(3,{from_device=l}),a.dp_current_heating_setpoint(4,{scale=10}),a.dp_local_temperature(5,{scale=10}),a.dp_binary(7,{name="child_lock",emit=b.trv06bChildLock(),converter=c.lookup_from_to{unlock=false,lock=true}}),a.dp_raw(28,{name="schedule_wednesday"}),a.dp_raw(29,{name="schedule_thursday"}),a.dp_raw(30,{name="schedule_friday"}),a.dp_raw(31,{name="schedule_saturday"}),a.dp_raw(32,{name="schedule_sunday"}),a.dp_raw(33,{name="schedule_monday"}),a.dp_raw(34,{name="schedule_tuesday"}),n(b.trv06bError(),b.trv06bBatteryLow()),a.dp_binary(36,{name="frost_protection",emit=b.trv06bFrostProtection(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_binary(39,{name="scale_protection",emit=b.trv06bScaleProtection(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_local_temperature_calibration(47,{scale=1,emit=b.trv06bTempCalibration()}),a.dp_numeric(101,{name="pi_heating_demand",read_only=true,emit=b.trv06bPiHeatingDemand()})}d(R,f.ts0601_fingerprints{"_TZE200_p3dbf6qs","_TZE200_hvaxb2tc"})return{id="ef00.thermostats.trv_1",registrations=V}
