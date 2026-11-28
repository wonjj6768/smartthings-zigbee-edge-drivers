local a,b,j,i,t,p=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family",require"contracts.helpers.ef00",require"contracts.helpers.ef00_thermostat_metadata",require"contracts.helpers.ef00_thermostats"local c=a.converter
local ak,d=j.definition_registry()local aB,aj,aa,aC=c.lookup_from_to{off=false,on=true},c.lookup_from_to{hold=0,program=1},c.lookup_from_to{program=0,hold=1},c.lookup_from_to{IN=0,AL=1,OU=2}
local function u(value)
local m=tonumber(value)if m==nil then return nil end
if m>=32768 then m=m-65535 end
return m
end
local function U(value)
local m=tonumber(value)if m==nil then return nil end
return m>4000 and(m-4096)or m
end
local function ab(value)
local m=tonumber(value)if m==nil then return nil end
return m<0 and(4096+m)or m
end
local function af(value)
if type(value)~="string"or #value<36 then return nil end
local aL={}for aK=0,11 do
local aM=aK*3
local ad,B,aE=string.byte(value,aM+1,aM+3)if ad==nil or B==nil or aE==nil then return nil end
local temperature=aE/2
local aT=string.format("%02d:%02d/%.1f",ad,B,temperature):gsub("%.0$","")aL[#aL+1]=aT
end
return table.concat(aL," ")
end
local function ao(value)
if type(value)~="string"then return nil end
local z={}for ad,B,temperature in value:gmatch"(%d+):(%d+)/([%d%.]+)"do
ad,B,temperature=tonumber(ad),tonumber(B),tonumber(temperature)if ad==nil or ad<0 or ad>23 or B==nil or B<0 or B>59 or
temperature==nil or temperature<5 or temperature>35 then
return nil
end
local aE=math.floor((temperature*2)+0.5)if math.abs((aE/2)-temperature)>0.001 then return nil end
z[#z+1]=ad
z[#z+1]=B
z[#z+1]=aE
end
if #z~=36 then return nil end
return string.char(table.unpack(z))
end
local function ae(_,value)
if value~="hold"and value~="program"then return nil end
return{{dp=2,datatype=a.DP_TYPE_ENUM,value=value=="hold"and 0 or 1},{dp=3,datatype=a.DP_TYPE_ENUM,value=value=="program"and 0 or 1}}
end
local function Z(l,s)
if l==10 and s==10 then
return c.divide_by_pair(10)elseif l==10 then
return c.from_to(function(value)
local aN=u(value)return aN==nil and nil or aN/10
end,function(value)return tonumber(value)and tonumber(value)*10 or nil end)
else
return c.from_to(u,function(value)return tonumber(value)end)
end
end
local function k(aO,az,l,s,as,aD)
local aw=Z(l,s)local N={profile=aO,time_start="1970",named_mapping={named_mappings={bht002_preset=ae}},a.dp_binary(1,{name="system_mode",converter=c.lookup_from_to{off=false,heat=true},emit=b.thermostat_mode()}),a.dp_enum(2,{name="bht002_preset",read_only=true,converter=aj,emit=b.bhtPreset()}),a.dp_enum(3,{name="bht002_preset",read_only=true,converter=aa,emit=b.bhtPreset()}),a.dp_current_heating_setpoint(16,{scale=az,emit=b.heating_setpoint"C"}),a.dp_numeric(18,{name="bht002_maximum_temperature_limit",emit=b.bhtMaximumTemperatureLimit(),converter=c.divide_by_pair(s)}),a.dp_numeric(20,{name="bht002_deadzone_temperature",emit=b.bhtDeadzoneTemperature(),converter=c.divide_by_pair(s)}),a.dp_numeric(24,{name="local_temperature",read_only=true,emit=b.temperature"C",converter=aw}),a.dp_numeric(26,{name="bht002_minimum_temperature_limit",emit=b.bhtMinimumTemperatureLimit(),converter=c.divide_by_pair(s)}),a.dp_numeric(27,{name="bht002_temperature_calibration",emit=as,converter=c.from_to(U,ab)}),
a.dp_binary(36,{name="running_state",read_only=true,emit=b.thermostat_operating_state(),converter=c.from_only(function(value)return value==true and"idle"or"heating"end)}),
a.dp_binary(40,{name="bht002_child_lock",emit=b.bhtChildLock(),converter=aB}),a.dp_enum(43,{name="bht002_temperature_sensor",emit=b.bhtTemperatureSensor(),converter=aC}),a.dp_raw(101,{name="bht002_program",emit=b.bhtProgram(),converter=c.from_to(af,ao)})}return t.attach(N,{"off","heat"},5,90,aD)
end
local aH=k("thermostats-bht002-fine",1,10,1,b.bhtTemperatureCalibrationFine(),1)d(aH,j.create_fingerprints("TS0601",{"_TZE200_u9bfwha0","_TZE204_u9bfwha0"}))local I=k("thermostats-bht002-fine",1,1,1,b.bhtTemperatureCalibrationFine(),1)d(I,j.create_fingerprints("TS0601",{"_TZE200_ztvwu4nk","_TZE200_ye5jkfsb","_TZE284_ye5jkfsb"}))local H=k("thermostats-bht002-fine",10,10,10,b.bhtTemperatureCalibrationFine(),1)d(H,j.create_fingerprints("TS0601",{"_TZE200_5toc8efa"}))local aI=k("thermostats-bht002-half",10,10,10,b.bhtTemperatureCalibrationFine(),0.5)d(aI,j.create_fingerprints("TS0601",{"_TZE204_5toc8efa"}))local r,o=k("thermostats-bht002-whole",1,10,1,b.bhtTemperatureCalibrationWhole(),1),"_bht002_time_zone_hours"
local function P(g,C)
local aG=os.time()return a.send_time(g,aG,aG+C*3600)
end
r.force_time_updates=true
r.time_handler=function(g)
return P(g,g:get_field(o)or 0)
end
r.protocol_writers={
bht002_time_zone=function(g,C)
if not P(g,C)then return false end
g:set_field(o,C,{persist=true})return true
end
}local J=r.runtime_start
r.runtime_start=function(g)
J(g)g:emit_component_event({id="main"},b.bht002TimeZone()(g,g:get_field(o)or 0))
end
d(r,j.create_fingerprints("TS0601",{"_TZE204_aoclfnxz"}))local ay=k("thermostats-bht002-fine",1,10,1,b.bhtTemperatureCalibrationFine(),1)d(ay,j.create_fingerprints("TS0601",{"_TZE200_aoclfnxz"}))local q={profile="thermostats-thermostat-zwt198",a.dp_binary(1,{name="system_mode",converter=c.lookup_from_to{heat=true,off=false},emit=b.thermostat_mode()}),a.dp_current_heating_setpoint(2,{emit=b.heating_setpoint"C",scale=10}),a.dp_local_temperature(3,{emit=b.temperature"C",scale=10}),a.dp_enum(4,{name="preset",emit=b.zwt198Preset(),converter=c.lookup_from_to{auto=0,manual=1,temporaryManual=2}}),a.dp_child_lock(9,{converter=a.converter.lookup_from_to{["unlock"]=false,["lock"]=true},emit=b.zwt198ChildLock()}),a.dp_numeric(11,{name="fault_alarm",read_only=true,emit=b.zwt198FaultAlarm()}),a.dp_max_temperature_limit(15,{scale=10,emit=b.zwt198MaxTemperatureLimit()}),a.dp_local_temperature_calibration(19,{scale=10,emit=b.zwt198TempCalibration()}),a.dp_running_state(101,{converter=c.lookup_from_to{heating=1,idle=0},emit=b.thermostat_operating_state()}),a.dp_frost_protection(102,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},emit=b.zwt198FrostProtection()}),a.dp_binary(103,{name="factory_reset",emit=b.zwt198FactoryReset(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_enum(104,{name="working_day",emit=b.zwt198WorkingDay(),converter=c.lookup_from_to{disabled=0,fiveTwo=1,sixOne=2,seven=3}}),a.dp_temperature_sensor_select_internal_external_both(106,{name="sensor",emit=b.zwt198Sensor()}),a.dp_deadzone_temperature(107,{scale=10,emit=b.zwt198DeadzoneTemperature()}),a.dp_enum(110,{name="backlight_mode",emit=b.zwt198BacklightMode(),converter=c.lookup_from_to{off=0,low=1,medium=2,high=3}})}d(q,i.ts0601_fingerprints{"_TZE204_xnbkhhdr","_TZE284_xnbkhhdr","_TZE204_oh8y8pv8","_TZE284_gops3slb","_TZE284_zjhoqbrd","_TZE204_zjhoqbrd"})d(q,{j.create_fingerprint("AVATTO","WT-100-BH")})
local function T(N,dp,aJ)
local E={}for aP,value in pairs(N)do
E[aP]=value
end
for aK,y in ipairs(N)do
if y.dp==dp then
E[aK]=aJ
end
end
return E
end
local x=T(q,4,a.dp_enum(4,{name="preset",emit=b.zwt198Preset(),converter=c.lookup_from_to{manual=0,auto=1,temporaryManual=2}}))d(x,i.ts0601_fingerprints{"_TZE204_lzriup1j","_TZE204_gops3slb"})local w=T(q,104,a.dp_enum(104,{name="working_day",emit=b.zwt198WorkingDay(),converter=c.lookup_from_to{disabled=0,sixOne=1,fiveTwo=2,seven=3}}))d(w,i.ts0601_fingerprints{"_TZE200_viy9ihs7"})local ar={profile="thermostats-thermostat-zwt100",force_time_updates=true,a.dp_on_off(1,{name="state",emit=b.switch()}),a.dp_current_heating_setpoint(2,{emit=b.heating_setpoint"C",scale=10}),a.dp_local_temperature(3,{emit=b.temperature"C",scale=10}),a.dp_enum(4,{name="mode",emit=b.zwt100Mode(),converter=c.lookup_from_to{manual=0,program=1,temporary=2}}),a.dp_child_lock(9,{converter=a.converter.lookup_from_to{["unlock"]=false,["lock"]=true},emit=b.zwt100ChildLock()}),a.dp_numeric(11,{name="fault",read_only=true,emit=b.zwt100Fault()}),a.dp_max_temperature_limit(15,{name="upper_temperature_limit",scale=10,emit=b.zwt100UpperTempLimit()}),a.dp_local_temperature_calibration(19,{scale=10,emit=b.zwt100TempCalibration()}),a.dp_running_state(101,{converter=c.lookup_from_to{idle=0,heating=1},emit=b.thermostat_operating_state()}),a.dp_frost_protection(102,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},emit=b.zwt100FrostProtection()}),a.dp_binary(103,{name="reset",emit=b.zwt100Reset(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_enum(104,{name="work_days",emit=b.zwt100WorkDays(),converter=c.lookup_from_to{programmingOff=0,twoDayWeekend=1,singleDayOff=2,noRest=3}}),a.dp_binary(105,{name="sound",emit=b.zwt100Sound(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_enum(106,{name="sensor_selection",emit=b.zwt100SensorSelection(),converter=c.lookup_from_to{["in"]=0,out=1,all=2}}),a.dp_numeric(107,{name="temperature_variation",converter=c.divide_by_pair(10),emit=b.zwt100TempVariation()}),a.dp_numeric(108,{name="sensor_temperature_limit",emit=b.zwt100SensorTempLimit()}),a.dp_enum(110,{name="backlight",emit=b.zwt100Backlight(),converter=c.lookup_from_to{off=0,micro=1,medium=2,high=3}}),a.dp_binary(111,{name="direction_mode",emit=b.zwt100DirectionMode(),converter=c.lookup_from_to{off=false,on=true}})}d(ar,i.ts0601_fingerprints{"_TZE204_aaeaifez","_TZE284_aaeaifez","_TZE28C1000000_aaeaifez"})local av={profile="thermostats-thermostat-zwt07",a.dp_binary(1,{name="system_mode",converter=c.lookup_from_to{heat=true,off=false},emit=b.thermostat_mode()}),a.dp_enum(2,{name="preset",emit=b.thermostatPresetZwt07Program(),converter=c.lookup_from_to{program=0,manual=1}}),a.dp_binary(10,{name="frost_protection",emit=b.zwt07FrostProtection(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_current_heating_setpoint(16,{emit=b.heating_setpoint"C",scale=10}),a.dp_local_temperature(24,{emit=b.temperature"C",scale=10}),a.dp_running_state(36,{converter=c.lookup_from_to{idle=0,heating=1},emit=b.thermostat_operating_state()})}d(av,i.ts0601_fingerprints{"_TZE200_g9a3awaj"})local D,L="hy08we_power_state","hy08we_system_mode_device"local Q,V,R,Y=p.power_mode_from_device(D,L,"heat"),p.enum_mode_from_device(D,L,{[0]="heat",[1]="auto",[2]="heat"}),p.power_mode_write(125,128,{heat=0,auto=1}),a.dp_current_heating_setpoint(126,{scale=10,emit=b.heating_setpoint"C"})local ap={profile="thermostats-thermostat-hy08we",time_start="2000",named_mapping={named_mappings={system_mode=R,current_heating_setpoint=Y}},a.dp_binary(102,{name="running_state",converter=c.lookup_from_to{heating=true,idle=false},emit=b.thermostat_operating_state()}),a.dp_temperature(103,{name="external_temperature",scale=10,read_only=true,emit=b.hy08weExternalTemperature()}),a.dp_numeric(104,{name="away_preset_days",emit=b.hy08weAwayDays()}),a.dp_numeric(105,{name="away_preset_temperature",emit=b.hy08weAwayTemperature()}),a.dp_binary(106,{name="max_temperature_protection",emit=b.hy08weMaxTempProtection(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_binary(107,{name="min_temperature_protection",emit=b.hy08weMinTempProtection(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_local_temperature_calibration(109,{scale=10,read_only=true}),a.dp_numeric(110,{name="hysteresis",converter=c.divide_by_pair(10),emit=b.hy08weHysteresis()}),a.dp_numeric(111,{name="hysteresis_for_protection",emit=b.hy08weProtectionHysteresis()}),a.dp_numeric(112,{name="max_temperature_for_protection",emit=b.hy08weProtectionMaxTemp()}),a.dp_numeric(113,{name="min_temperature_for_protection",emit=b.hy08weProtectionMinTemp()}),a.dp_numeric(114,{name="max_temperature",emit=b.hy08weMaxTemperature()}),a.dp_numeric(115,{name="min_temperature",emit=b.hy08weMinTemperature()}),a.dp_enum(116,{name="sensor_type",emit=b.hy08weSensorType(),converter=c.lookup_from_to{internal=0,external=1,both=2}}),a.dp_enum(117,{name="power_on_behavior",emit=b.hy08wePowerOnBehavior(),converter=c.lookup_from_to{restore=0,off=1,on=2}}),a.dp_enum(118,{name="week_format",emit=b.hy08weWeekFormat(),converter=c.lookup_from_to{fiveTwo=0,sixOne=1,seven=2}}),a.dp_child_lock(129,{converter=a.converter.lookup_from_to{["unlock"]=false,["lock"]=true},emit=b.hy08weChildLock()}),a.dp_numeric(130,{name="alarm",read_only=true,emit=b.hy08weAlarm(),
converter=c.from_only(function(value)
return(tonumber(value)or 0)>0 and"detected"or"clear"
end)
}),a.dp_binary(125,{name="state",from_device=Q,emit=b.thermostat_mode(),read_only=true}),Y,a.dp_local_temperature(127,{emit=b.temperature"C",scale=10}),a.dp_system_mode(128,{from_device=V,emit=b.thermostat_mode(),read_only=true})}d(ap,i.ts0601_fingerprints{"_TZE200_znzs7yaw"})local ag,at=b.thermostatPresetTervixProgram(),b.tervixMode()local aq={profile="thermostats-thermostat-tervix",a.dp_binary(1,{name="system_mode",emit=b.thermostat_mode(),converter=c.lookup_from_to{off=false,heat=true}}),a.dp_enum(2,{name="preset",
emit=function(g,value)
return{ag(g,value),at(g,value)}
end,
converter=c.lookup_from_to{manual=0,program=1}}),a.dp_running_state(3,{converter=c.lookup_from_to{idle=0,heating=1},emit=b.thermostat_operating_state()}),a.dp_enum(3,{name="working_status",read_only=true,emit=b.tervixWorkingStatus(),converter=c.from_only(c.lookup_value{[0]="keeping_warm",[1]="working"})}),a.dp_binary(8,{name="window_check",converter=c.lookup_from_to{on=true,off=false},emit=b.tervixWindowCheck()}),a.dp_frost_protection(10,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},emit=b.tervixFrostProtection()}),a.dp_current_heating_setpoint(16,{emit=b.heating_setpoint"C",scale=10}),a.dp_max_temperature_limit(19,{name="upper_temp",scale=10,emit=b.tervixUpperTemp()}),a.dp_local_temperature(24,{emit=b.temperature"C",scale=10}),a.dp_binary(25,{name="window_state",read_only=true,emit=b.tervixWindowState(),
converter=c.from_only(function(value)
return value and"open"or"close"
end)
}),a.dp_local_temperature_calibration(27,{scale=1,name="temperature_correction",emit=b.tervixTempCorrection()}),a.dp_humidity(34,{scale=1,emit=b.humidity()}),a.dp_binary(39,{name="factory_reset",emit=b.tervixFactoryReset(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_child_lock(40,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},emit=b.tervixChildLock()}),a.dp_enum(43,{datatype=a.DP_TYPE_VALUE,name="sensor_choose",converter=c.lookup_from_to{["in"]=0,out=1},emit=b.tervixSensorChoose()}),a.dp_raw(48,{name="week_schedule"}),a.dp_enum(58,{datatype=a.DP_TYPE_VALUE,name="run_mode",emit=b.tervixRunMode(),converter=c.lookup_from_to{heat_mode=1,cool_mode=2}}),a.dp_enum(61,{name="week_program_periods",read_only=true,emit=b.tervixWeekProgramPeriods(),
converter=c.from_only(function()
return"periods_4"
end)
}),a.dp_numeric(101,{name="switch_sensitivity",scale=10,emit=b.tervixSwitchSensitivity()}),a.dp_temperature(102,{name="floor_temp_protection",scale=10,emit=b.tervixFloorTempProtection()}),a.dp_temperature(103,{name="floor_low_protection",scale=10,emit=b.tervixFloorLowProtection()}),a.dp_numeric(104,{name="window_open_detection_time",emit=b.tervixWindowDetectTime()}),a.dp_numeric(105,{name="window_open_detection_temp",emit=b.tervixWindowDetectTemp()}),a.dp_numeric(106,{name="window_open_delay_time",emit=b.tervixWindowDelayTime()}),a.dp_binary(107,{name="humidity_control",emit=b.tervixHumidityControl(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_numeric(108,{name="upper_humidity_limit",emit=b.tervixUpperHumidityLimit()})}d(aq,i.ts0601_fingerprints{"_TZE284_6kijc7nd","_TZE204_6kijc7nd"})local aA={profile="thermostats-thermostat-x5h",time_start="2000",a.dp_binary(1,{name="system_mode",converter=c.lookup_from_to{heat=true,off=false},emit=b.thermostat_mode()}),a.dp_enum(2,{name="preset",emit=b.thermostatPresetX5hProgram(),converter=c.lookup_from_to{manual=0,program=1}}),a.dp_running_state(3,{converter=c.lookup_from_to{heating=true,idle=false},emit=b.thermostat_operating_state()}),a.dp_binary(7,{name="sound",emit=b.x5hSound(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_frost_protection(10,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},emit=b.x5hFrostProtection()}),a.dp_current_heating_setpoint(16,{emit=b.heating_setpoint"C",scale=10}),a.dp_max_temperature_limit(19,{name="upper_temp",scale=1,emit=b.x5hUpperTemp()}),a.dp_numeric(24,{name="local_temperature",from_device=p.x5h_local_temperature_from_device,emit=b.temperature"C"}),a.dp_local_temperature_calibration(27,{scale=10,emit=b.x5hTempCalibration()}),a.dp_raw(30,{name="schedule"}),a.dp_enum(31,{name="working_day",converter=c.lookup_from_to{mon_fri=0,mon_sat=1,all_days=2},emit=b.workingDayX5h()}),a.dp_binary(39,{name="factory_reset",emit=b.x5hFactoryReset(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_child_lock(40,{converter=a.converter.lookup_from_to{["unlock"]=false,["lock"]=true},emit=b.x5hChildLock()}),a.dp_enum(43,{name="temperature_sensor_select",converter=c.lookup_from_to{internal=0,external=1,both=2},emit=b.temperatureSensorSelectX5hThree()}),a.dp_numeric(45,{name="fault_alarm",read_only=true,emit=b.x5hFaultAlarm()}),a.dp_deadzone_temperature(101,{scale=10,emit=b.tempDeltaXhCToNinetyFive()}),a.dp_temperature(102,{name="heating_temp_limit",scale=1,emit=b.x5hHeatingTempLimit()}),a.dp_binary(103,{name="output_reverse",emit=b.x5hOutputReverse(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_enum(104,{name="brightness_state",emit=b.x5hBrightnessState(),converter=c.lookup_from_to{off=0,low=1,medium=2,high=3}})}d(aA,i.ts0601_fingerprints{"_TZE200_2ekuz3dz"})local W={profile="thermostats-thermostat-thermosphere",a.dp_binary(1,{name="system_mode",converter=c.lookup_from_to{auto=true,off=false},emit=b.thermostat_mode()}),a.dp_current_heating_setpoint(2,{emit=b.heating_setpoint"C",scale=10}),a.dp_enum(4,{name="boost",emit=b.tsphereBoost(),converter=c.lookup_from_to{off=1,on=2}}),a.dp_binary(18,{name="open_window_active",emit=b.tsphereOpenWindowActive(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_binary(37,{name="adaptive_start",emit=b.tsphereAdaptiveStart(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_local_temperature(38,{scale=10,emit=b.temperature"C"}),a.dp_max_temperature_limit(39,{scale=10,emit=b.tsphereMaxTemperatureLimit()}),a.dp_numeric(40,{name="open_window_sensing_time",emit=b.tsphereOpenWindowSensingTime()}),a.dp_numeric(41,{name="holiday_days",emit=b.tsphereHolidayDays()}),a.dp_holiday_temperature(42,{scale=10,emit=b.tsphereHolidayTemperature()}),a.dp_enum(43,{name="sensor_mode",emit=b.tsphereSensorMode(),converter=c.lookup_from_to{room=0,floor=1,roomWithFloorLimit=2}}),a.dp_numeric(45,{name="open_window_drop_limit",converter=c.divide_by_pair(10),emit=b.tsphereOpenWindowDropLimit()}),a.dp_numeric(47,{name="open_window_off_time",emit=b.tsphereOpenWindowOffTime()}),a.dp_numeric(50,{name="power_rating",emit=b.tspherePowerRating()}),a.dp_binary(52,{name="frost_protection",emit=b.tsphereFrostProtection(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_min_temperature_limit(53,{scale=10,emit=b.tsphereMinTemperatureLimit()}),a.dp_numeric(54,{name="switch_delay",emit=b.tsphereSwitchDelay()}),a.dp_numeric(55,{name="display_brightness",emit=b.tsphereDisplayBrightness()})}d(W,i.ts0601_fingerprints{"_TZE200_ha0vwoew"})local S={profile="thermostats-thermostat-floor",a.dp_binary(1,{name="system_mode",converter=c.lookup_from_to{heat=true,off=false},emit=b.thermostat_mode()}),a.dp_enum(2,{name="preset",emit=b.thermostatPresetFloorManualAuto(),converter=c.lookup_from_to{auto=0,manual=1}}),a.dp_current_heating_setpoint(16,{emit=b.heating_setpoint"C",scale=10}),a.dp_temperature(24,{name="device_temperature",scale=10,read_only=true,emit=b.floorDeviceTemperature()}),a.dp_local_temperature_calibration(27,{scale=1,read_only=true}),a.dp_running_state(36,{converter=c.lookup_from_to{heating=0,idle=1},emit=b.thermostat_operating_state()}),a.dp_child_lock(40,{converter=a.converter.lookup_from_to{["unlock"]=false,["lock"]=true},emit=b.floorChildLock()}),a.dp_local_temperature(102,{emit=b.temperature"C",scale=10}),a.dp_deadzone_temperature(103,{scale=1,emit=b.floorDeadzoneTemperature()}),a.dp_raw(101,{name="schedule_sunday"}),a.dp_raw(105,{name="schedule_saturday"}),a.dp_raw(106,{name="schedule_friday"}),a.dp_raw(107,{name="schedule_thursday"}),a.dp_raw(108,{name="schedule_wednesday"}),a.dp_raw(109,{name="schedule_tuesday"}),a.dp_raw(110,{name="schedule_monday"})}d(S,i.ts0601_fingerprints{"_TZE200_edl8pz1k","_TZE204_edl8pz1k"})local A,K="floor006_sensor","floor006_external_temperature"
local function F(g,aQ)
local aR=aQ==2 and K or"device_temperature"return g:get_field(aR)
end
local function n(g,value)
g:set_field("local_temperature",value,{persist=false})return b.temperature"C"(g,value)
end
local e={profile="thermostats-thermostat-floor-006",time_start="1970",presence_capability_ranges={floorSixDeadzoneTemperature={minimum=0.5,maximum=5,step=0.5,unit="C"}}}for _,y in ipairs(S)do
if y.dp==40 then
e[#e+1]=a.dp_child_lock(39,{converter=c.lookup_from_to{lock=true,unlock=false},emit=b.floorSixChildLock()})elseif y.dp==103 then
e[#e+1]=a.dp_deadzone_temperature(103,{scale=10,emit=b.floorSixDeadzoneTemperature()})elseif y.dp~=102 then
local E={}for aP,value in pairs(y)do E[aP]=value end
if y.name=="preset"then E.emit=b.floorSixPreset()end
if y.name=="device_temperature"then E.emit=b.floorSixDeviceTemperature()end
e[#e+1]=E
end
end
e[#e+1]=a.dp_local_temperature(24,{read_only=true,field=false,
from_device=function(value,g)
if g:get_field(A)~=2 then return value/10 end
end,
emit=n})e[#e+1]=a.dp_local_temperature(102,{name=K,scale=10,read_only=true})e[#e+1]=a.dp_local_temperature(102,{read_only=true,field=false,
from_device=function(value,g)
if g:get_field(A)==2 then return value/10 end
end,
emit=n})e[#e+1]=a.dp_enum(43,{name=A,read_only=true,persist=true,
from_device=function(value)
if value==0 or value==1 or value==2 then return value end
end,
emit=function(g,value)
local temperature=F(g,value)if temperature~=nil then
return n(g,temperature)end
end
})t.attach(e,{"off","heat"},5,35,0.5)d(e,i.ts0601_fingerprints{"_TZE204_6a4vxfnv"})local an={profile="thermostats-thermostat-bot-r9v",a.dp_binary(1,{name="system_mode",converter=c.lookup_from_to{heat=true,off=false},emit=b.thermostat_mode()}),a.dp_enum(2,{name="preset",emit=b.botr9vPreset(),converter=c.lookup_from_to{auto=0,manual=1,eco=2}}),a.dp_frost_protection(10,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},name="frost",emit=b.botr9vFrost()}),a.dp_current_heating_setpoint(16,{emit=b.heating_setpoint"C",scale=10}),a.dp_min_temperature_limit(18,{scale=10,emit=b.botr9vMinTemperatureLimit()}),a.dp_max_temperature_limit(19,{scale=10,emit=b.botr9vMaxTemperatureLimit()}),a.dp_local_temperature(24,{emit=b.temperature"C",scale=10}),a.dp_running_state(36,{converter=c.lookup_from_to{idle=false,heating=true},emit=b.thermostat_operating_state()}),a.dp_binary(36,{name="valve_state",read_only=true,emit=b.botr9vValveState(),
converter=c.from_only(function(value)
return value and"open"or"close"
end)
}),a.dp_child_lock(40,{converter=a.converter.lookup_from_to{["unlock"]=false,["lock"]=true},emit=b.botr9vChildLock()}),a.dp_raw(65,{name="schedule_monday"}),a.dp_raw(66,{name="schedule_tuesday"}),a.dp_raw(67,{name="schedule_wednesday"}),a.dp_raw(68,{name="schedule_thursday"}),a.dp_raw(69,{name="schedule_friday"}),a.dp_raw(70,{name="schedule_saturday"}),a.dp_raw(71,{name="schedule_sunday"}),a.dp_battery(107,{emit=b.battery()}),a.dp_local_temperature_calibration(109,{scale=10,emit=b.botr9vTempCalibration()}),a.dp_deadzone_temperature(112,{scale=10,emit=b.botr9vDeadzoneTemperature()}),a.dp_eco_temperature(116,{scale=10,emit=b.botr9vEcoTemperature()})}d(an,i.ts0601_fingerprints{"_TZE204_wc2w9t1s"})local ah={profile="thermostats-thermostat-battery-bot-r15w",respond_to_mcu_version_response=true,a.dp_binary(1,{name="system_mode",converter=c.lookup_from_to{heat=true,off=false},emit=b.thermostat_mode()}),a.dp_current_heating_setpoint(2,{emit=b.heating_setpoint"C",scale=10}),a.dp_local_temperature(3,{emit=b.temperature"C",scale=10}),a.dp_enum(4,{name="preset",emit=b.botr15wPreset2(),converter=c.lookup_from_to{manual=0,auto=1,mixed=2,away=3}}),a.dp_child_lock(9,{converter=a.converter.lookup_from_to{["unlock"]=false,["lock"]=true},emit=b.botr15wChildLock()}),a.dp_max_temperature_limit(15,{scale=10,emit=b.botr15wMaxTemperatureLimit()}),a.dp_local_temperature_calibration(19,{scale=10,emit=b.botr15wTempCalibration()}),a.dp_running_state(101,{converter=c.lookup_from_to{idle=0,heating=1},emit=b.thermostat_operating_state()}),a.dp_frost_protection(102,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},emit=b.botr15wFrostProtection()}),a.dp_binary(103,{name="factory_reset",emit=b.botr15wFactoryReset(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_deadzone_temperature(107,{name="temperature_delta",scale=10,emit=b.tempDeltaBotRToTen()}),a.dp_battery(113,{emit=b.battery()})}d(ah,i.ts0601_fingerprints{"_TZE284_agcxaw3f"})local au={profile="thermostats-thermostat-khah2lkr",time_start="2000",a.dp_local_temperature(16,{emit=b.temperature"C",scale=10}),a.dp_current_heating_setpoint(50,{emit=b.heating_setpoint"C",scale=10}),a.dp_running_state(102,{converter=c.lookup_from_to{idle=false,heating=true},emit=b.thermostat_operating_state()}),a.dp_temperature(103,{name="temperature_sensor",scale=10,read_only=true,emit=b.khahTemperatureSensor()}),a.dp_binary(106,{name="high_temperature_protection_state",emit=b.khahHighTempProtection(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_binary(107,{name="low_temperature_protection_state",emit=b.khahLowTempProtection(),converter=c.lookup_from_to{off=false,on=true}}),a.dp_local_temperature_calibration(109,{scale=10,emit=b.khahLocalTempCalibration()}),a.dp_numeric(110,{name="temperature_return_difference",emit=b.khahReturnDifference()}),a.dp_deadzone_temperature(111,{scale=1,emit=b.khahDeadzoneTemperature()}),a.dp_temperature(112,{name="high_temperature_protection_setting",scale=1,emit=b.khahHighTempSetting()}),a.dp_temperature(113,{name="low_temperature_protection_setting",scale=1,emit=b.khahLowTempSetting()}),a.dp_max_temperature_limit(114,{name="max_temperature",scale=1,emit=b.khahMaxTemperature()}),a.dp_enum(116,{datatype=a.DP_TYPE_VALUE,name="sensor_mode",emit=b.khahSensorMode(),converter=c.lookup_from_to{["in"]=0,ou=1,al=2}}),a.dp_binary(125,{name="system_mode",converter=c.lookup_from_to{heat=true,off=false},emit=b.thermostat_mode()}),a.dp_enum(128,{datatype=a.DP_TYPE_VALUE,name="preset",emit=b.khahPreset(),converter=c.lookup_from_to{manual=0,auto=1,mixed=3}}),a.dp_child_lock(129,{converter=a.converter.lookup_from_to{["unlock"]=false,["lock"]=true},emit=b.khahChildLock()}),a.dp_numeric(130,{name="error_status",read_only=true,emit=b.khahErrorStatus()})}d(au,i.ts0601_fingerprints{"_TZE284_khah2lkr"})local ac={profile="thermostats-thermostat-pilot-wire-no-operating",a.dp_binary(1,{name="system_mode",converter=c.lookup_from_to{heat=true,off=false},emit=b.thermostat_mode()}),a.dp_enum(2,{name="preset",emit=b.pilotWirePreset(),converter=c.lookup_from_to{comfort=0,eco=1,antifrost=2,off=3,comfort_1=4,comfort_2=5,program=6,manual=7}}),a.dp_power(11,{name="power",scale=10,emit=b.power()}),a.dp_local_temperature(16,{emit=b.temperature"C",scale=10}),a.dp_enum(17,{name="window",read_only=true,emit=b.pilotWireWindow(),converter=c.from_only(c.lookup_value{[0]="close",[1]="open"})}),a.dp_local_temperature_calibration(19,{scale=1,emit=b.pilotWireTempCalibration()}),a.dp_numeric(20,{name="fault",read_only=true,emit=b.pilotWireFault()}),a.dp_binary(29,{name="window_detection",converter=c.lookup_from_to{on=true,off=false},emit=b.windowDetectionPilotWire()}),a.dp_child_lock(39,{converter=a.converter.lookup_from_to{["unlock"]=false,["lock"]=true},emit=b.pilotWireChildLock()}),a.dp_current_heating_setpoint(50,{emit=b.heating_setpoint"C",scale=10}),a.dp_voltage(101,{name="voltage",scale=10,emit=b.voltage()}),a.dp_current(102,{name="current",scale=1000,emit=b.current()}),a.dp_numeric(103,{name="temperature_sensibility",scale=10,emit=b.pilotWireTempSensibility()}),a.dp_energy(104,{name="energy_today",scale=10,emit=b.energyTodayPilotWire()}),a.dp_energy(105,{name="energy_yesterday",scale=10,emit=b.energyYesterdayPilotWire()}),a.dp_enum(106,{name="device_mode_type",emit=b.pilotWireDeviceModeType(),converter=c.lookup_from_to{four=0,six=1,switch=2}}),a.dp_energy(107,{name="energy",scale=10,emit=b.energy()})}d(ac,i.ts0601_fingerprints{"_TZE204_0hcjew5p","_TZE204_3regm3h6","_TZE204_6vwfjkcj","_TZE204_ouy7vpm1","_TZE284_3regm3h6"})local X,O="poboco_virtual_heating_setpoint","poboco_mode_switching"
local function G(g,temperature)
if temperature==0 then return 5 end
if temperature<16 then return 4 end
if temperature>=19 then return 0 end
if g:get_field(O)==1 then
if temperature==17 then return 2 end
if temperature==18 then return 1 end
end
return 3
end
local function v(g,aS)
if a.send_datapoint(g,2,a.DP_TYPE_ENUM,1,a.SET_DATA,false,1)==nil then return false end
return a.send_datapoint(g,127,a.DP_TYPE_ENUM,aS,a.SET_DATA,false,1)~=nil
end
local function ax(g,value)
if type(value)~="number"or value%1~=0 or value<0 or value>20 then return false end
if not v(g,G(g,value))then return false end
g:set_field(X,value,{persist=true})g:emit_event(b.heating_setpoint"C"(g,value))g:emit_event(b.thermostat_mode()(g,value==0 and"off"or"heat"))return true
end
local function am(g,value)
local aF
if value=="auto"then
aF=a.send_datapoint(g,2,a.DP_TYPE_ENUM,0,a.SET_DATA,false,1)~=nil
elseif value=="off"then
aF=v(g,5)elseif value=="heat"then
local temperature=g:get_field(X)or g:get_latest_state("main","thermostatHeatingSetpoint","heatingSetpoint")or 20
aF=v(g,G(g,temperature))else
return false
end
if aF then g:emit_event(b.thermostat_mode()(g,value))end
return aF
end
local M={profile="thermostats-thermostat-po-boco-elec",time_start="1970",protocol_writers={system_mode=am,current_heating_setpoint=ax},presence_capability_ranges={poBocoTempCalibration={minimum=-5.5,maximum=5.5,step=0.5,unit="C"}},a.dp_enum(2,{name="preset",converter=c.lookup_from_to{auto=0,manual=1,holiday=2},emit=b.poBocoPreset()}),a.dp_humidity(8,{scale=1,read_only=true,emit=b.humidity()}),a.dp_energy(11,{scale=1,read_only=true,emit=b.energy()}),a.dp_local_temperature(16,{scale=10,read_only=true,emit=b.temperature"C"}),a.dp_child_lock(39,{converter=a.converter.lookup_from_to{unlock=false,lock=true},emit=b.poBocoChildLock()}),a.dp_local_temperature_calibration(101,{scale=10,emit=b.poBocoTempCalibration()}),a.dp_binary(138,{name="window_detection",converter=c.lookup_from_to{on=true,off=false},emit=b.poBocoWindowDetection()}),a.dp_enum(144,{name=O,read_only=true})}t.attach(M,{"off","heat","auto"},0,20,1)d(M,i.ts0601_fingerprints{"_TZE204_3q3maeoo","_TZE204_d6i25bwg"})local ai={profile="thermostats-thermostat-pro900z",time_start="2000",a.dp_binary(1,{name="system_mode",converter=c.lookup_from_to{off=false,heat=true},emit=b.thermostat_mode()}),a.dp_enum(2,{name="preset",emit=b.pro900zPreset(),converter=c.lookup_from_to{auto=0,manual=1}}),a.dp_current_heating_setpoint(16,{emit=b.heating_setpoint"C",scale=10}),a.dp_max_temperature_limit(19,{name="max_temperature",emit=b.pro900zMaxTemperature(),scale=10}),a.dp_local_temperature(24,{emit=b.temperature"C",scale=10}),a.dp_min_temperature_limit(26,{name="min_temperature",emit=b.pro900zMinTemperature(),scale=10}),a.dp_local_temperature_calibration(27,{scale=1,emit=b.pro900zLocalTempCalibration()}),a.dp_binary(28,{converter=a.converter.lookup_from_to{["factory_reset"]=true},name="factory_reset",emit=b.pro900zFactoryReset()}),a.dp_running_state(36,{converter=c.lookup_from_to{heating=0,idle=1},emit=b.thermostat_operating_state()}),a.dp_child_lock(39,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},emit=b.pro900zChildLock()}),a.dp_binary(40,{converter=a.converter.lookup_from_to{["off"]=false,["on"]=true},name="eco_mode",emit=b.pro900zEcoMode()}),a.dp_temperature_sensor_select_internal_external_both(43,{name="sensor",emit=b.pro900zSensor(),converter=c.lookup_from_to{["in"]=0,al=1,ou=2}}),a.dp_raw(101,{name="schedule_monday"}),a.dp_temperature(102,{name="external_temperature_input",emit=b.pro900zExternalTemperature(),scale=10}),a.dp_deadzone_temperature(103,{scale=1,emit=b.pro900zDeadzoneTemperature()}),a.dp_max_temperature_limit(104,{name="max_temperature_limit",scale=10,emit=b.pro900zMaxTemperatureLimit()}),a.dp_raw(105,{name="schedule_tuesday"}),a.dp_raw(106,{name="schedule_wednesday"}),a.dp_raw(107,{name="schedule_thursday"}),a.dp_raw(108,{name="schedule_friday"}),a.dp_raw(109,{name="schedule_saturday"}),a.dp_raw(110,{name="schedule_sunday"}),a.dp_min_temperature_limit(111,{name="min_temperature_limit",scale=10,emit=b.pro900zMinTemperatureLimit()}),a.dp_eco_temperature(112,{scale=10,emit=b.pro900zEcoTemperature()}),a.dp_numeric(113,{name="brightness",emit=b.pro900zBrightness()}),a.dp_numeric(114,{name="display_brightness",emit=b.displayBrightnessPro900zLevel8()})}d(ai,i.ts0601_fingerprints{"_TZE204_tagezcph"})return{id="ef00.thermostats.wall",registrations=ak}
