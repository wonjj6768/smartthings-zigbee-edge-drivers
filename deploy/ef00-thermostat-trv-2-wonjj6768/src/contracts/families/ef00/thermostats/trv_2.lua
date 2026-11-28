local a,b,V,g,f=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family",require"contracts.helpers.ef00",require"contracts.helpers.ef00_thermostats"local c=a.converter
local N,d=V.definition_registry()local y,n,s=f.valve_position_to_running_state,f.variant1_mode_from_device,f.variant1_mode_to_device


local E={profile="thermostats-thermostat-battery-ar331",package_group="trv-2",a.dp_enum(2,{name="preset",emit=b.ar331Preset(),converter=c.lookup_from_to{auto=0,manual=1,leave=2}}),a.dp_running_state(3,{converter=c.lookup_from_to{heating=1,idle=0},emit=b.thermostat_operating_state()}),a.dp_current_heating_setpoint(4,{scale=10,emit=b.heating_setpoint"C"}),a.dp_local_temperature(5,{read_only=true,emit=b.temperature"C",
from_device=function(e)
return(e>32767 and e-65536 or e)/10
end}),
a.dp_battery(6,{emit=b.battery()}),a.dp_child_lock(7,{name="child_lock",emit=b.ar331ChildLock(),converter=c.lookup_from_to{lock=false,unlock=true}})}d(E,g.ts0601_fingerprints{"_TZE284_noixx2uz"})local L={profile="thermostats-thermostat-s366",package_group="trv-2",force_time_updates=true,a.dp_system_mode(1,{datatype=a.DP_TYPE_BOOL,converter=c.lookup_from_to{heat=true,off=false},emit=b.thermostat_mode()}),a.dp_enum(2,{name="preset",emit=b.s366Preset(),converter=c.lookup_from_to{manual=0,holiday=1,program=2}}),a.dp_open_window(8,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},emit=b.s366OpenWindow()}),a.dp_frost_protection(10,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},emit=b.s366FrostProtection()}),a.dp_current_heating_setpoint(16,{scale=10,emit=b.heating_setpoint"C"}),a.dp_local_temperature(24,{scale=10,emit=b.temperature"C"}),a.dp_local_temperature_calibration(27,{scale=10,emit=b.s366TempCalibration()}),a.dp_binary(35,{name="battery_low",read_only=true,emit=b.s366BatteryLow(),
converter=c.from_only(function(e)
return(e==false or e==0)and"low"or"normal"
end)
}),a.dp_child_lock(40,{converter=a.converter.lookup_from_to{["unlock"]=false,["lock"]=true},emit=b.s366ChildLock()}),a.dp_numeric(45,{name="error_status",read_only=true,emit=b.s366ErrorStatus()})}d(L,g.ts0601_fingerprints{"_TZE200_0hg58wyk"})local M={profile="thermostats-thermostat-trv4",package_group="trv-2",force_time_updates=true,a.dp_system_mode(49,{converter=c.lookup_from_to{off=0,heat=1},emit=b.thermostat_mode()}),a.dp_enum(2,{name="preset",emit=b.trv4Preset(),converter=c.lookup_from_to{schedule=0,holiday=1,manual=2,comfort=3,eco=4}}),a.dp_current_heating_setpoint(4,{scale=10,emit=b.heating_setpoint"C"}),a.dp_local_temperature(5,{scale=10,emit=b.temperature"C"}),a.dp_battery(6,{emit=b.battery()}),a.dp_child_lock(7,{converter=a.converter.lookup_from_to{["unlock"]=false,["lock"]=true},emit=b.trv4ChildLock()}),a.dp_holiday_temperature(21,{scale=10,emit=b.trv4HolidayTemperature()}),a.dp_comfort_temperature(24,{scale=10,emit=b.trv4ComfortTemperature()}),a.dp_eco_temperature(25,{scale=10,emit=b.trv4EcoTemperature()}),a.dp_bitmap(35,{name="battery_low",read_only=true,emit=b.trv4BatteryLow(),converter=c.from_only(f.error_or_battery_low_state)}),a.dp_frost_protection(36,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},emit=b.trv4FrostProtection()}),a.dp_boost_heating(37,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},emit=b.trv4BoostHeating()}),a.dp_scale_protection(39,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},emit=b.trv4ScaleProtection()}),a.dp_local_temperature_calibration(47,{scale=1,emit=b.trv4TempCalibration()})}d(M,g.ts0601_fingerprints{"_TZE204_pcdmj88b","_TZE284_pcdmj88b"})
local function l(e)
local R=tonumber(e)if R==nil then
return nil
end
if R==6 then
return"off"end
return"heat"
end
local function o(e)
if e=="off"then
return 6
end
if e=="heat"then
return 0
end
return nil
end
local I={profile="thermostats-thermostat-trv14",package_group="trv-2",force_time_updates=true,a.dp_system_mode(2,{from_device=l,to_device=o,emit=b.thermostat_mode()}),a.dp_enum(2,{name="preset",emit=b.trv14Preset(),converter=c.lookup_from_to{manual=0,schedule=1,eco=2,comfort=3,frostProtection=4,holiday=5,off=6}}),a.dp_running_state(3,{converter=c.lookup_from_to{heating=1,idle=0},emit=b.thermostat_operating_state()}),a.dp_current_heating_setpoint(4,{scale=10,emit=b.heating_setpoint"C"}),a.dp_local_temperature(5,{scale=10,emit=b.temperature"C"}),a.dp_battery(6,{emit=b.battery()}),a.dp_child_lock(7,{converter=a.converter.lookup_from_to{["unlock"]=false,["lock"]=true},emit=b.trv14ChildLock()}),a.dp_window_detection(14,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},emit=b.trv14WindowDetection()}),a.dp_enum(15,{name="window_open",read_only=true,emit=b.trv14WindowOpen(),converter=c.from_only(c.lookup_value{[0]="close",[1]="open"})}),a.dp_holiday_temperature(21,{scale=10,emit=b.trv14HolidayTemperature()}),a.dp_bitmap(35,{name="battery_low",read_only=true,emit=b.trv14BatteryLow(),converter=c.from_only(f.error_or_battery_low_state)}),a.dp_frost_protection(36,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},emit=b.trv14FrostProtection()}),a.dp_boost_heating(37,{emit=b.trv14BoostHeating()}),a.dp_scale_protection(39,{emit=b.trv14ScaleProtection()}),a.dp_local_temperature_calibration(47,{scale=10,emit=b.trv14TempCalibration()}),a.dp_eco_temperature(103,{scale=10,emit=b.trv14EcoTemperature()}),a.dp_comfort_temperature(104,{scale=10,emit=b.trv14ComfortTemperature()})}d(I,g.ts0601_fingerprints{"_TZE204_vjpaih9f","_TZE284_vjpaih9f"})
local function u(e)
local R,z=tonumber(e),{[0]="heat",[1]="auto",[2]="heat",[3]="heat",[4]="heat",[5]="off"}return z[R]
end
local function x(e)
local z={heat=0,auto=1,off=5}return z[e]
end
local v={profile="thermostats-thermostat-gtz10",package_group="trv-2",force_time_updates=true,time_start="1970",a.dp_system_mode(2,{from_device=u,to_device=x,emit=b.thermostat_mode()}),a.dp_enum(2,{name="preset",emit=b.gtz10Preset(),converter=c.lookup_from_to{manual=0,auto=1,holiday=2,comfort=3,eco=4,off=5}}),a.dp_running_state(49,{from_device=y,emit=b.thermostat_operating_state(),read_only=true}),a.dp_current_heating_setpoint(4,{scale=10,emit=b.heating_setpoint"C"}),a.dp_local_temperature(5,{scale=10,emit=b.temperature"C"}),a.dp_battery(6,{emit=b.battery()}),a.dp_child_lock(7,{converter=a.converter.lookup_from_to{["unlock"]=false,["lock"]=true},emit=b.gtz10ChildLock()}),a.dp_max_temperature_limit(9,{name="max_temperature",scale=10,emit=b.gtz10MaxTemperature()}),a.dp_min_temperature_limit(10,{name="min_temperature",scale=10,emit=b.gtz10MinTemperature()}),a.dp_window_detection(14,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},emit=b.gtz10WindowDetection()}),a.dp_window_open(15,{read_only=true,emit=b.gtz10WindowOpen(),
converter=c.from_only(function(e)
return e and"open"or"close"
end)
}),a.dp_open_window_temperature(16,{scale=10,emit=b.gtz10OpenWindowTemperature()}),a.dp_numeric(35,{name="error_status",read_only=true,
from_device=function(e,_,Y)return Y and Y.int_value or e end,
emit=b.gtzFault()}),a.dp_frost_protection(36,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},emit=b.gtz10FrostProtection()}),a.dp_boost_heating(37,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},emit=b.gtz10BoostHeating()}),a.dp_numeric(38,{name="boost_timeset_countdown",emit=b.gtz10BoostCountdown()}),a.dp_local_temperature_calibration(47,{scale=10,emit=b.gtz10TempCalibration()}),a.dp_binary(113,{name="switch_type",emit=b.gtz10SwitchType(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_numeric(115,{name="position",emit=b.gtz10Position()}),a.dp_enum(119,{name="screen_orientation",emit=b.gtz10ScreenOrientation(),converter=c.lookup_from_to{up=0,down=1,left=2,right=3}})}for index,H in ipairs{b.gtzMonday,b.gtzTuesday,b.gtzWednesday,b.gtzThursday,b.gtzFriday,b.gtzSaturday,b.gtzSunday}do
v[#v+1]=a.dp_raw(27+index,{name="gtz_schedule_"..index,converter=f.daily_schedule(index,4),emit=H()})end
d(v,g.ts0601_fingerprints{"_TZE200_pbo8cj0z","_TZE200_eo6xhfbo"})local q={profile="thermostats-thermostat-tr-m3z",package_group="trv-2",time_start="1970",a.dp_system_mode(101,{datatype=a.DP_TYPE_BOOL,converter=c.lookup_from_to{off=false,heat=true},emit=b.thermostat_mode()}),a.dp_enum(2,{name="preset",emit=b.trm3zPreset(),converter=c.lookup_from_to{manual=0,schedule=1,eco=2,comfort=3,frostProtection=4,holiday=5,off=6}}),a.dp_running_state(3,{converter=c.lookup_from_to{heating=1,idle=0},emit=b.thermostat_operating_state()}),a.dp_current_heating_setpoint(4,{scale=10,emit=b.heating_setpoint"C"}),a.dp_local_temperature(5,{scale=10,emit=b.temperature"C"}),a.dp_battery(6,{emit=b.battery()}),a.dp_child_lock(7,{converter=a.converter.lookup_from_to{["unlock"]=false,["lock"]=true},emit=b.trm3zChildLock()}),a.dp_window_detection(14,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},emit=b.trm3zWindowDetection()}),a.dp_enum(15,{name="window_open",read_only=true,emit=b.trm3zWindowOpen(),converter=c.from_only(c.lookup_value{[0]="close",[1]="open"})}),a.dp_holiday_temperature(21,{scale=10,emit=b.trm3zHolidayTemperature()}),a.dp_bitmap(35,{name="battery_low",read_only=true,emit=b.trm3zBatteryLow(),converter=c.from_only(f.error_or_battery_low_state)}),a.dp_bitmap(35,{name="fault_alarm",read_only=true,emit=b.trmFault()}),a.dp_frost_protection(36,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},emit=b.trm3zFrostProtection()}),a.dp_scale_protection(39,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},emit=b.trm3zScaleProtection()}),a.dp_local_temperature_calibration(47,{scale=10,emit=b.trm3zTempCalibration()}),a.dp_numeric(102,{name="temperature_accuracy",converter=c.divide_by_pair(10),emit=b.trm3zTemperatureAccuracy()}),a.dp_eco_temperature(103,{scale=10,emit=b.trm3zEcoTemperature()}),a.dp_comfort_temperature(104,{scale=10,emit=b.trm3zComfortTemperature()}),a.dp_temperature(105,{name="frost_protection_temperature",scale=10,emit=b.trm3zFrostTemperature()})}for index,H in ipairs{b.trmMonday,b.trmTuesday,b.trmWednesday,b.trmThursday,b.trmFriday,b.trmSaturday,b.trmSunday}do
q[#q+1]=a.dp_raw(27+index,{name="trm_schedule_"..index,converter=f.daily_schedule(index,6),emit=H()})end
d(q,g.ts0601_fingerprints{"_TZE204_eekpf0ft","_TZE284_eekpf0ft"})local p,t="tv02_heating_stop","tv02_preset_mode"
local function A(e,h)
local z={[0]="auto",[1]="heat",[2]="heat",[3]="heat"}local F=z[tonumber(e)]if F==nil then
return nil
end
h:set_field(t,F,{persist=false})if h:get_field(p)==true then
return"off"end
return F
end
local function B(e,h)
local O=e==true
h:set_field(p,O,{persist=false})if O then
return"off"end
return h:get_field(t)or"heat"
end
local function G(_,e)
if e=="off"then
return{{dp=107,datatype=a.DP_TYPE_BOOL,value=true}}end
if e=="auto"then
return{{dp=2,datatype=a.DP_TYPE_ENUM,value=0}}end
if e=="heat"then
return{{dp=2,datatype=a.DP_TYPE_ENUM,value=1}}end
return nil
end
local J=a.dp_current_heating_setpoint(16,{scale=10,emit=b.heating_setpoint"C"})local U={profile="thermostats-thermostat-tv02",package_group="trv-2",force_time_updates=true,named_mapping={named_mappings={
frost_protection=function(_,e)
if e=="on"then
return{{dp=10,datatype=a.DP_TYPE_BOOL,value=true}}elseif e=="off"then
return{{dp=2,datatype=a.DP_TYPE_ENUM,value=1}}end
return nil
end,system_mode=G,
current_heating_setpoint=J}},a.dp_system_mode(2,{from_device=A,emit=b.thermostat_mode(),read_only=true}),a.dp_open_window(8,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},emit=b.tv02OpenWindow()}),a.dp_frost_protection(10,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},emit=b.tv02FrostProtection()}),J,a.dp_local_temperature(24,{scale=10,emit=b.temperature"C"}),a.dp_local_temperature_calibration(27,{scale=10,emit=b.tv02TempCalibration()}),a.dp_enum(31,{name="working_day",converter=c.lookup_from_to{mon_sun=0,mon_fri_sat_sun=1,separate=2},emit=b.workingDayTv02ScheduleMode()}),a.dp_holiday_temperature(32,{scale=10,emit=b.tv02HolidayTemperature()}),a.dp_binary(35,{name="battery_low",
converter=c.from_only(function(e)
if e==false or e==0 then return"low"end
if e==true or e==1 then return"normal"end
return nil
end),
read_only=true,emit=b.tv02BatteryLow()}),a.dp_child_lock(40,{converter=a.converter.lookup_from_to{["unlock"]=false,["lock"]=true},emit=b.tv02ChildLock()}),a.dp_numeric(45,{name="error_status",read_only=true,emit=b.tv02ErrorStatus()}),a.dp_raw(46,{name="holiday_start_stop"}),a.dp_numeric(101,{name="boost_timeset_countdown",emit=b.tv02BoostCountdown()}),a.dp_open_window_temperature(102,{scale=10,emit=b.tv02OpenWindowTemperature()}),a.dp_comfort_temperature(104,{scale=10,emit=b.tv02ComfortTemperature()}),a.dp_eco_temperature(105,{scale=10,emit=b.tv02EcoTemperature()}),a.dp_raw(106,{name="schedule"}),a.dp_binary(107,{name="system_mode",from_device=B,emit=b.thermostat_mode(),read_only=true}),a.dp_raw(108,{name="schedule_monday"}),a.dp_raw(109,{name="schedule_wednesday"}),a.dp_raw(110,{name="schedule_friday"}),a.dp_raw(111,{name="schedule_sunday"}),a.dp_raw(112,{name="schedule_tuesday"}),a.dp_raw(113,{name="schedule_thursday"}),a.dp_raw(114,{name="schedule_saturday"}),a.dp_binary(115,{name="online",read_only=true,emit=b.tv02Online(),converter=c.lookup_from_to{off=false,on=true}})}d(U,g.ts0601_fingerprints{"_TZE200_sur6q7ko","_TZE200_hue3yfsn","_TZE200_e9ba97vf","_TZE200_husqqvux","_TZE200_lnbfnyxd","_TZE200_fsow0qsk","_TZE200_lllliz3p","_TZE200_mudxchsu","_TZE200_7yoranx2","_TZE200_kds0pmmv","_TZE200_py4cm3he","_TZE200_wsbfwodu","_TZE200_x9axofse","_TZE200_lhzapfg9","_TZE200_k1tumq4t"})
local function D(ac,k)
return{profile=ac,a.dp_system_mode(1,{from_device=n,to_device=s,emit=b.thermostat_mode()}),a.dp_enum(1,{name="preset",emit=k.preset,converter=c.lookup_from_to{auto=0,manual=1,off=2,on=3}}),a.dp_current_heating_setpoint(2,{scale=10,emit=b.heating_setpoint"C"}),a.dp_local_temperature(3,{scale=10,emit=b.temperature"C"}),a.dp_running_state(6,{converter=c.lookup_from_to{heating=1,idle=0},emit=b.thermostat_operating_state()}),a.dp_enum(7,{name="window",read_only=true,emit=k.window,converter=c.from_only(c.lookup_value{[0]="close",[1]="open"})}),a.dp_window_detection(8,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},emit=k.window_detection}),a.dp_child_lock(12,{converter=a.converter.lookup_from_to{["unlock"]=false,["lock"]=true},emit=k.child_lock}),a.dp_battery(13,{emit=b.battery()}),a.dp_binary(14,{name="alarm_switch",read_only=true,emit=k.alarm_switch,
converter=c.from_only(function(e)
if e==true or e==1 then return"on"end
if e==false or e==0 then return"off"end
end)
}),a.dp_min_temperature_limit(15,{name="min_temperature",scale=10,emit=k.min_temperature}),a.dp_max_temperature_limit(16,{name="max_temperature",scale=10,emit=k.max_temperature}),a.dp_local_temperature_calibration(101,{scale=10,emit=k.calibration}),a.dp_numeric(108,{name="position",read_only=true,converter=c.divide_by_pair(10),emit=k.position}),a.dp_enum(111,{name="display_brightness",emit=k.display_brightness,converter=c.lookup_from_to(k.brightness_map)}),a.dp_enum(113,{name="screen_orientation",emit=k.screen_orientation,converter=c.lookup_from_to(k.orientation_map)}),a.dp_enum(114,{name="hysteresis_mode",emit=k.hysteresis,converter=c.lookup_from_to{comfort=0,eco=1}})}
end
local r=D("thermostats-thermostat-trv601",{preset=b.trv601Preset(),window=b.trv601Window(),window_detection=b.trv601WindowDetection(),child_lock=b.trv601ChildLock(),alarm_switch=b.trv601AlarmSwitch(),min_temperature=b.trv601MinTemperature(),max_temperature=b.trv601MaxTemperature(),calibration=b.trv601TempCalibration(),position=b.trv601Position(),display_brightness=b.trv601DisplayBrightness(),brightness_map={high=0,medium=1,low=2},screen_orientation=b.trv601ScreenOrientation(),orientation_map={up=0,right=1,down=2,left=3},hysteresis=b.trv601Hysteresis()})r.package_group="trv-2"r.force_time_updates=true
d(r,g.ts0601_fingerprints{"_TZE204_rtrmfadk","_TZE204_cvcu2p6e"})local i=D("thermostats-thermostat-trv602",{preset=b.trv602Preset(),window=b.trv602Window(),window_detection=b.trv602WindowDetection(),child_lock=b.trv602ChildLock(),alarm_switch=b.trv602AlarmSwitch(),min_temperature=b.trv602MinTemperature(),max_temperature=b.trv602MaxTemperature(),calibration=b.trv602TempCalibration(),position=b.trv602Position(),display_brightness=b.trv602DisplayBrightness(),brightness_map={high=0,middle=1,low=2},screen_orientation=b.trv602ScreenOrientation(),orientation_map={up=0,down=2},hysteresis=b.trv602Hysteresis()})i.package_group="trv-2"i.force_time_updates=true
i[#i+1]=a.dp_numeric(115,{name="switch_deviation_eco",converter=c.divide_by_pair(10),emit=b.trv602SwitchDeviationEco()})d(i,g.ts0601_fingerprints{"_TZE204_9mjy74mp","_TZE200_rtrmfadk","_TZE200_9mjy74mp"})
local function S(day)
return{
from=function(e)
if type(e)~="string"or #e~=25 or e:byte(1)~=day then return nil end
local w={}for ad=2,22,4 do
local af,F=string.unpack(">I2B",e,ad)local X=af&4095
F=F>>4
local preset=F==2 and"eco"or F==3 and"comfort"if af&61440~=49152 or X>1440 or not preset then return nil end
w[#w+1]=string.format("%02d:%02d/%s",X//60,X%60,preset)end
return table.concat(w," ")
end,
to=function(e)
local w={string.char(day)}for ae in e:gmatch"%S+"do
local W,minute,preset=ae:match"^(%d%d):(%d%d)/(%a+)$"W,minute=tonumber(W),tonumber(minute)if not W or not minute or W>24 or minute>59 or(W==24 and minute~=0)then return nil end
local F=preset=="eco"and 32 or preset=="comfort"and 48
if not F then return nil end
w[#w+1]=string.pack(">I2BB",49152|(W*60+minute),F,preset=="eco"and 150 or 200)end
if #w~=7 then return nil end
return table.concat(w)
end
}
end
local j="_trv602z_time_zone_hours"
local function C(h,Z)
local aa=os.time()return a.send_time(h,aa,aa+Z*3600)
end
local m={profile="thermostats-thermostat-trv602z",package_group="trv-2",time_start="1970",
time_handler=function(h)
return C(h,h:get_field(j)or 0)
end,
protocol_writers={
trv602z_time_zone=function(h,Z)
if not C(h,Z)then return false end
h:set_field(j,Z,{persist=true})return true
end
},
runtime_start=function(h)
h:emit_component_event({id="main"},b.trv602zTimeZone()(h,h:get_field(j)or 0))
end,
a.dp_system_mode(2,{
from_device=function(e)
local z={[0]="off",[1]="auto",[2]="auto",[3]="auto",[4]="auto",[5]="heat"}return z[tonumber(e)]
end,
to_device=function(e)
local z={off=0,auto=4,heat=5}return z[e]
end,
emit=b.thermostat_mode()}),a.dp_enum(2,{name="preset",emit=b.trv602zPreset(),converter=c.lookup_from_to{off=0,antifrost=1,eco=2,comfort=3,auto=4,on=5}}),a.dp_running_state(3,{converter=c.lookup_from_to{heating=1,idle=0},emit=b.thermostat_operating_state()}),a.dp_current_heating_setpoint(4,{scale=10,emit=b.heating_setpoint"C"}),a.dp_local_temperature(5,{scale=10,emit=b.temperature"C"}),a.dp_battery(6,{emit=b.battery()}),a.dp_child_lock(7,{converter=a.converter.lookup_from_to{["unlock"]=false,["lock"]=true},emit=b.trv602zChildLock()}),a.dp_max_temperature_limit(9,{name="max_temperature",scale=10,emit=b.trv602zMaxTemperature()}),a.dp_min_temperature_limit(10,{name="min_temperature",scale=10,emit=b.trv602zMinTemperature()}),a.dp_window_detection(14,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},emit=b.trv602zWindowDetection()}),a.dp_enum(15,{name="window",read_only=true,emit=b.trv602zWindow(),converter=c.from_only(c.lookup_value{[0]="close",[1]="open"})}),a.dp_local_temperature_calibration(47,{scale=10,emit=b.trv602zTempCalibration()}),a.dp_enum(110,{name="motor_thrust",emit=b.trv602zMotorThrust(),converter=c.lookup_from_to{strong=0,middle=1,weak=2}}),a.dp_enum(111,{name="display_brightness",emit=b.trv602zDisplayBrightness(),converter=c.lookup_from_to{high=0,medium=1,low=2}}),a.dp_enum(113,{name="screen_orientation",emit=b.trv602zScreenOrientation(),converter=c.lookup_from_to{up=0,down=1}}),a.dp_numeric(114,{name="position",read_only=true,converter=c.divide_by_pair(10),emit=b.trv602zPosition()}),a.dp_numeric(118,{name="boost_timeset_countdown",emit=b.trv602zBoostCountdown()}),a.dp_comfort_temperature(119,{scale=10,emit=b.trv602zComfortTemperature()}),a.dp_eco_temperature(120,{scale=10,emit=b.trv602zEcoTemperature()}),a.dp_holiday_temperature(121,{scale=10,emit=b.trv602zHolidayTemperature()}),a.dp_frost_protection(122,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},emit=b.trv602zFrostProtection()}),a.dp_enum(127,{name="hysteresis_mode",emit=b.trv602zHysteresis(),converter=c.lookup_from_to{comfort=0,eco=1}})}for day,H in ipairs{b.trv602zMonSchedule,b.trv602zTueSchedule,b.trv602zWedSchedule,b.trv602zThuSchedule,b.trv602zFriSchedule,b.trv602zSatSchedule,b.trv602zSunSchedule}do
m[#m+1]=a.dp_raw(101+day,{name="trv602z_schedule_"..day,converter=S(day),emit=H(),suppress_optimistic_state=true})end
d(m,g.ts0601_fingerprints{"_TZE204_qyr2m29i","_TZE204_ltwbm23f","_TZE284_ltwbm23f"})local K={profile="thermostats-thermostat-battery-ar331pro",package_group="trv-2",a.dp_binary(1,{name="preheat",read_only=true,emit=b.ar331proPreheat(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_enum(2,{name="preset",emit=b.thermostatPresetAr331proSixMode(),converter=c.lookup_from_to{auto=0,manual=1,holiday=2,eco=3,comfort=4,standby=5}}),a.dp_running_state(3,{converter=c.lookup_from_to{heating=0,idle=1},emit=b.thermostat_operating_state()}),a.dp_current_heating_setpoint(4,{emit=b.heating_setpoint"C",scale=10}),a.dp_local_temperature(5,{emit=b.temperature"C",read_only=true,
from_device=function(e)
return(e>32767 and e-65536 or e)/10 end}),
a.dp_battery(6,{emit=b.battery()}),a.dp_child_lock(7,{emit=b.ar331proChildLock(),converter=c.lookup_from_to{lock=false,unlock=true}}),a.dp_window_detection(14,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},emit=b.ar331proWindowDetection()}),a.dp_enum(15,{name="window_open",read_only=true,emit=b.ar331proWindowOpen(),converter=c.from_only(c.lookup_value{[0]="open",[1]="closed"})}),a.dp_temperature(16,{name="window_temperature",scale=10,emit=b.ar331proWindowTemp()}),a.dp_numeric(18,{name="display_brightness",emit=b.ar331proDisplayBrightness()}),a.dp_numeric(35,{name="fault_code",read_only=true,emit=b.ar331proFaultCode()}),a.dp_local_temperature_calibration(47,{scale=10,emit=b.ar331proTempCalibration()}),a.dp_enum(49,{name="valve_state",read_only=true,emit=b.ar331proValveState(),converter=c.from_only(c.lookup_value{[0]="open",[1]="close"})}),a.dp_boost_heating(101,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},emit=b.ar331proBoostHeating()}),a.dp_numeric(102,{name="boost_time",converter=c.divide_by_pair(60),emit=b.ar331proBoostTime()}),a.dp_eco_temperature(103,{scale=10,emit=b.ar331proEcoTemperature()}),a.dp_comfort_temperature(104,{scale=10,emit=b.ar331proComfortTemperature()}),a.dp_numeric(105,{name="window_delay",converter=c.divide_by_pair(60),emit=b.ar331proWindowDelay()}),a.dp_temperature(107,{name="frost_protection_temperature",scale=10,emit=b.ar331proFrostTemperature()}),a.dp_numeric(108,{name="window_close_delay",converter=c.divide_by_pair(60),emit=b.ar331proWindowCloseDelay()}),a.dp_binary(109,{name="heating_cooling_mode",emit=b.ar331proHeatCoolMode(),converter=c.lookup_from_to{heat=false,cool=true}}),a.dp_binary(110,{name="battery_status",read_only=true,emit=b.ar331proBatteryStatus(),converter=c.lookup_from_to{normal=false,low=true}}),a.dp_enum(111,{datatype=a.DP_TYPE_VALUE,name="screen_orientation",emit=b.ar331proScreenOrientation(),converter=c.lookup_from_to{up=0,right=90,down=180,left=270}}),a.dp_binary(113,{name="summer_mode",emit=b.ar331proSummerMode(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_temperature(114,{name="override_temperature",scale=10,emit=b.ar331proOverrideTemperature()}),a.dp_binary(115,{name="override_active",emit=b.ar331proOverrideActive(),converter=c.lookup_from_to{off=false,on=true}})}d(K,g.ts0601_fingerprints{"_TZE284_nbv4tdaz"})return{id="ef00.thermostats.trv_2",registrations=N}
