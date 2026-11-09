local b,c,D,h,f=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family",require"contracts.helpers.ef00",require"contracts.helpers.ef00_thermostat_metadata"local a=b.converter
local y,e=D.definition_registry()
local function d(L)
local function F(g)
if type(g)~="string"or #g<17 then
return nil
end
local t={}for U=0,3 do
local O=2+U*4
local z,r,S,V=string.byte(g,O,O+3)if z==nil or r==nil or S==nil or V==nil then
return nil
end
t[#t+1]=string.format("%02d:%02d/%.1f",z,r,((S*256)+V)/10)end
return table.concat(t," ")
end
local function P(g)
if type(g)~="string"then
return nil
end
local i,K={L},0
for M in string.gmatch(g,"%S+")do
local N,G,A=M:match"^(%d+):(%d+)/([%d%.%-]+)$"local z,r,n=tonumber(N),tonumber(G),tonumber(A)if z==nil or r==nil or n==nil
or z<0 or z>24 or r<0 or r>60
or n<5 or n>35 then
return nil
end
local m=math.floor(n*10)i[#i+1]=math.floor(z)i[#i+1]=math.floor(r)i[#i+1]=math.floor(m/256)%256
i[#i+1]=m%256
K=K+1
end
if K~=4 then
return nil
end
return string.char(table.unpack(i))
end
return a.from_to(F,P)
end
local j="__wave6a_futurehome_energy"
local function l(g,o)
local J=tonumber(g)if J==nil then
return nil
end
local C,E=J/100,tonumber(o:get_field(j))or 0

if C<E and C~=0 then
return E
end
o:set_field(j,C,{persist=true})return C
end
local B={profile="thermostats-wave6a-futurehome",package_group="wall",query_on_configure=false,time_start="2000",b.dp_system_mode(1,{name="system_mode",converter=a.lookup_from_to{off=false,heat=true},emit=c.thermostat_mode()}),b.dp_enum(2,{name="futurehome_preset",converter=a.lookup_from_to{user=0,home=1,away=2,auto=3},emit=c.fhThermostatPreset()}),b.dp_current_heating_setpoint(16,{name="current_heating_setpoint",scale=1,emit=c.heating_setpoint"C"}),b.dp_local_temperature(24,{name="local_temperature",scale=1,read_only=true,emit=c.temperature"C"}),b.dp_local_temperature_calibration(28,{name="futurehome_temp_calibration",scale=1,emit=c.fhThermostatTempCalibration()}),b.dp_child_lock(30,{name="futurehome_child_lock",converter=a.lookup_from_to{LOCK=true,UNLOCK=false},emit=c.fhThermostatChildLock()}),b.dp_numeric(101,{name="futurehome_floor_temperature",read_only=true,emit=c.fhThermostatFloorTemperature()}),b.dp_enum(102,{name="futurehome_sensor",converter=a.lookup_from_to{air_sensor=0,floor_sensor=1,max_guard=2},emit=c.fhThermostatSensor()}),b.dp_numeric(103,{name="futurehome_hysteresis",emit=c.fhThermostatHysteresis()}),b.dp_running_state(104,{name="running_state",read_only=true,converter=a.lookup_from_to{idle=false,heating=true},emit=c.thermostat_operating_state()}),b.dp_binary(106,{name="futurehome_window_detection",converter=a.lookup_from_to{ON=true,OFF=false},emit=c.fhThermostatWindowDetection()}),b.dp_numeric(107,{name="futurehome_max_guard_temp",emit=c.fhThermostatMaxGuardTemp()}),b.dp_numeric(123,{name="energy",read_only=true,from_device=l,emit=c.energy()})}f.attach(B,{"off","heat"},5,35,1)e(B,h.ts0601_fingerprints{"_TZE204_e5hpkc6d","_TZE200_4hbx5cvx","_TZE200_e5hpkc6d"})local s,u="__wave6a_e40_power","__wave6a_e40_mode"
local function v(g,o)
local H=g==true or g==1
o:set_field(s,H,{persist=false})if not H then
return"off"end
return o:get_field(u)or"heat"
end
local function x(g,o)
local T=({[0]="heat",[1]="cool"})[tonumber(g)]or"heat"o:set_field(u,T,{persist=false})if o:get_field(s)==false then
return"off"end
return T
end
local function w(_,g)
if g=="off"then
return{{dp=1,datatype=b.DP_TYPE_BOOL,value=false}}end
local I=({heat=0,cool=1})[g]if I==nil then
return nil
end
return{{dp=1,datatype=b.DP_TYPE_BOOL,value=true},{dp=2,datatype=b.DP_TYPE_ENUM,value=I}}
end
local Q={profile="thermostats-wave6a-engo-e40",package_group="wall",query_on_configure=false,time_start="1970",force_time_updates=true,b.dp_binary(1,{name="system_mode",from_device=v,read_only=true,emit=c.thermostat_mode()}),b.dp_enum(2,{name="system_mode",from_device=x,read_only=true,emit=c.thermostat_mode()}),b.dp_running_state(3,{name="running_state",read_only=true,converter=a.from_only(a.lookup_value{[0]="idle",[2]="heating",[3]="cooling",[4]="idle"}),emit=c.thermostat_operating_state()}),b.dp_current_heating_setpoint(16,{scale=10,emit=c.heating_setpoint"C"}),b.dp_numeric(19,{name="engo_e40_max_temperature",converter=a.divide_by_pair(10),emit=c.engoEFortyMaxTemperature()}),b.dp_local_temperature(24,{scale=10,read_only=true,emit=c.temperature"C"}),b.dp_numeric(26,{name="engo_e40_min_temperature",converter=a.divide_by_pair(10),emit=c.engoEFortyMinTemperature()}),b.dp_local_temperature_calibration(27,{name="engo_e40_temp_calibration",scale=10,emit=c.engoEFortyTempCalibration()}),b.dp_battery(35,{read_only=true,emit=c.battery()}),b.dp_child_lock(40,{name="engo_e40_child_lock",converter=a.lookup_from_to{LOCK=true,UNLOCK=false},emit=c.engoEFortyChildLock()}),b.dp_enum(43,{name="engo_e40_sensor_choose",converter=a.lookup_from_to{internal=0,all=1,external=2},emit=c.engoEFortySensorChoose()}),b.dp_numeric(44,{name="engo_e40_backlight",emit=c.engoEFortyBacklight()}),b.dp_enum(45,{name="engo_e40_comfort_floor",converter=a.lookup_from_to{OFF=0,LEVEL1=1,LEVEL2=2,LEVEL3=3,LEVEL4=4,LEVEL5=5},emit=c.engoEFortyComfortFloor()}),b.dp_enum(58,{name="engo_e40_preset",converter=a.lookup_from_to{manual=0,schedule=1,frost=3},emit=c.engoEFortyPreset()}),b.dp_enum(101,{name="engo_e40_control_algorithm",converter=a.lookup_from_to{TPI_UFH=0,TPI_RAD=1,TPI_ELE=2,HIS_02=3,HIS_04=4,HIS_06=5,HIS_08=6,HIS_10=7,HIS_20=8,HIS_30=9,HIS_40=10},emit=c.engoEFortyControlAlgorithm()}),b.dp_numeric(102,{name="engo_e40_delta_algorithm",converter=a.divide_by_pair(10),emit=c.engoEFortyDeltaAlgorithm()}),b.dp_enum(103,{name="engo_e40_device_pair_state",read_only=true,converter=a.from_only(a.lookup_value{[0]="none",[1]="commutation_center",[2]="trv"}),emit=c.engoEFortyDevicePairState()}),b.dp_binary(105,{name="engo_e40_temp_control_locked",converter=a.lookup_from_to{ON=true,OFF=false},emit=c.engoEFortyTempControlLocked()}),b.dp_numeric(106,{name="engo_e40_frost_set",converter=a.divide_by_pair(10),emit=c.engoEFortyFrostSet()}),b.dp_enum(107,{name="engo_e40_valve_protection",converter=a.lookup_from_to{off=0,on=1,anti_stop=2},emit=c.engoEFortyValveProtection()}),b.dp_enum(108,{name="engo_e40_relay_mode",converter=a.lookup_from_to{NO=0,NC=1,OFF=2},emit=c.engoEFortyRelayMode()}),b.dp_raw(109,{name="engo_e40_schedule_monday",converter=d(1),emit=c.engoEFortyScheduleMonday()}),b.dp_raw(110,{name="engo_e40_schedule_tuesday",converter=d(2),emit=c.engoEFortyScheduleTuesday()}),b.dp_raw(111,{name="engo_e40_schedule_wednesday",converter=d(3),emit=c.engoEFortyScheduleWednesday()}),b.dp_raw(112,{name="engo_e40_schedule_thursday",converter=d(4),emit=c.engoEFortyScheduleThursday()}),b.dp_raw(113,{name="engo_e40_schedule_friday",converter=d(5),emit=c.engoEFortyScheduleFriday()}),b.dp_raw(114,{name="engo_e40_schedule_saturday",converter=d(6),emit=c.engoEFortyScheduleSaturday()}),b.dp_raw(115,{name="engo_e40_schedule_sunday",converter=d(7),emit=c.engoEFortyScheduleSunday()}),b.dp_enum(120,{name="engo_e40_sensor_error",read_only=true,converter=a.from_only(a.lookup_value{[0]="normal",[1]="E1",[2]="E2"}),emit=c.engoEFortySensorError()}),b.dp_numeric(136,{name="engo_e40_latest_firmware",converter=a.divide_by_pair(10),read_only=true,emit=c.engoEFortyLatestFirmware()}),b.dp_numeric(137,{name="engo_e40_current_firmware",read_only=true,emit=c.engoEFortyCurrentFirmware()})}local p=b.build_named_map(Q,"name")p.system_mode=w
Q.named_mapping={named_mappings=p}f.attach(Q,{"off","heat","cool"},5,45,0.5)e(Q,h.ts0601_fingerprints{"_TZE204_lnxdk2ch","_TZE204_glk6viwg"})local R={profile="thermostats-wave6a-engo-eone230w",package_group="wall",query_on_configure=true,time_start="1970",b.dp_on_off(1,{name="switch",emit=c.switch()}),b.dp_system_mode(2,{name="system_mode",converter=a.lookup_from_to{heat=0,cool=1},emit=c.thermostat_mode()}),b.dp_running_state(3,{name="running_state",read_only=true,converter=a.from_only(a.lookup_value{[1]="heating",[2]="idle"}),emit=c.thermostat_operating_state()}),b.dp_current_heating_setpoint(16,{scale=10,emit=c.heating_setpoint"C"}),b.dp_numeric(19,{name="engo_eone_max_temperature",converter=a.divide_by_pair(10),emit=c.engoEoneMaxTemperature()}),b.dp_local_temperature(24,{scale=10,read_only=true,emit=c.temperature"C"}),b.dp_numeric(26,{name="engo_eone_min_temperature",converter=a.divide_by_pair(10),emit=c.engoEoneMinTemperature()}),b.dp_local_temperature_calibration(27,{name="engo_eone_temp_calibration",scale=10,emit=c.engoEoneTempCalibration()}),b.dp_numeric(32,{name="engo_eone_holiday_temperature",converter=a.divide_by_pair(10),emit=c.engoEoneHolidayTemperature()}),b.dp_numeric(33,{name="engo_eone_holiday_days",emit=c.engoEoneHolidayDays()}),b.dp_numeric(34,{name="humidity",read_only=true,emit=c.humidity()}),b.dp_child_lock(40,{name="engo_eone_child_lock",converter=a.lookup_from_to{LOCK=true,UNLOCK=false},emit=c.engoEoneChildLock()}),b.dp_enum(43,{name="engo_eone_sensor_choose",converter=a.lookup_from_to{internal=0,floor_temp=1,external=2,external_on_off=3},emit=c.engoEoneSensorChoose()}),b.dp_numeric(44,{name="engo_eone_backlight",emit=c.engoEoneBacklight()}),b.dp_enum(58,{name="engo_eone_preset",converter=a.lookup_from_to{manual=0,schedule=1,holiday=2,frost=5},emit=c.engoEonePreset()}),b.dp_enum(101,{name="engo_eone_control_algorithm",converter=a.lookup_from_to{TPI_UFH=0,TPI_RAD=1,TPI_ELE=2,HIS_02=3,HIS_04=4,HIS_06=5,HIS_08=6,HIS_10=7,HIS_20=8,HIS_30=9,HIS_40=10},emit=c.engoEoneControlAlgorithm()}),b.dp_numeric(102,{name="engo_eone_max_floor_heating",converter=a.divide_by_pair(10),emit=c.engoEoneMaxFloorHeating()}),b.dp_numeric(103,{name="engo_eone_min_floor_heating",converter=a.divide_by_pair(10),emit=c.engoEoneMinFloorHeating()}),b.dp_numeric(104,{name="engo_eone_max_floor_cooling",converter=a.divide_by_pair(10),emit=c.engoEoneMaxFloorCooling()}),b.dp_numeric(105,{name="engo_eone_min_floor_cooling",converter=a.divide_by_pair(10),emit=c.engoEoneMinFloorCooling()}),b.dp_numeric(106,{name="engo_eone_frost_set",converter=a.divide_by_pair(10),emit=c.engoEoneFrostSet()}),b.dp_enum(108,{name="engo_eone_relay_mode",converter=a.lookup_from_to{NO=0,NC=1,OFF=2},emit=c.engoEoneRelayMode()}),b.dp_raw(109,{name="engo_eone_schedule_monday",converter=d(1),emit=c.engoEoneScheduleMonday()}),b.dp_raw(110,{name="engo_eone_schedule_tuesday",converter=d(2),emit=c.engoEoneScheduleTuesday()}),b.dp_raw(111,{name="engo_eone_schedule_wednesday",converter=d(3),emit=c.engoEoneScheduleWednesday()}),b.dp_raw(112,{name="engo_eone_schedule_thursday",converter=d(4),emit=c.engoEoneScheduleThursday()}),b.dp_raw(113,{name="engo_eone_schedule_friday",converter=d(5),emit=c.engoEoneScheduleFriday()}),b.dp_raw(114,{name="engo_eone_schedule_saturday",converter=d(6),emit=c.engoEoneScheduleSaturday()}),b.dp_raw(115,{name="engo_eone_schedule_sunday",converter=d(7),emit=c.engoEoneScheduleSunday()}),b.dp_numeric(116,{name="engo_eone_floor_temperature",converter=a.divide_by_pair(10),read_only=true,emit=c.engoEoneFloorTemperature()}),b.dp_enum(117,{name="engo_eone_temp_resolution",converter=a.lookup_from_to{one=0,five=1},emit=c.engoEoneTempResolution()}),b.dp_enum(118,{name="engo_eone_comfort_floor",converter=a.lookup_from_to{OFF=0,LEVEL1=1,LEVEL2=2,LEVEL3=3,LEVEL4=4,LEVEL5=5},emit=c.engoEoneComfortFloor()}),b.dp_enum(120,{name="engo_eone_sensor_error",read_only=true,converter=a.from_only(a.lookup_value{[0]="normal",[1]="E1",[2]="E2"}),emit=c.engoEoneSensorError()}),b.dp_enum(122,{name="engo_eone_valve_protection",converter=a.lookup_from_to{off=0,on=1,anti_stop=2},emit=c.engoEoneValveProtection()})}f.attach(R,{"heat","cool"},5,45,0.5)e(R,h.ts0601_fingerprints{"_TZE204_ca3i8m8p","_TZE200_awnadkan"})local q={profile="thermostats-sauna-ae5503-core",package_group="wall",magic_packet=true,mcu_version_request_on_configure=true,query_on_configure=false,time_start="1970",b.dp_binary(1,{name="system_mode",converter=a.lookup_from_to{off=false,heat=true},emit=c.thermostat_mode()}),b.dp_current_heating_setpoint(16,{name="current_heating_setpoint",scale=1,emit=c.heating_setpoint"C"}),b.dp_local_temperature(24,{name="local_temperature",scale=1,read_only=true,emit=c.temperature"C"})}f.attach(q,{"off","heat"},0,120,1)e(q,h.ts0601_fingerprints{"_TZE204_eaasry7v"})local k={profile="thermostats-radiator-wsek35um-core",package_group="wall",magic_packet=true,mcu_version_request_on_configure=true,query_on_configure=false,time_start="1970",b.dp_current_heating_setpoint(4,{name="current_heating_setpoint",scale=10,emit=c.heating_setpoint"C"}),b.dp_local_temperature(5,{name="local_temperature",scale=10,read_only=true,emit=c.temperature"C"})}f.attach_setpoint_only(k,5,30,0.5)e(k,h.ts0601_fingerprints{"_TZE204_wsek35um"})return{id="ef00.thermostats.wave6a_wall",registrations=y}
