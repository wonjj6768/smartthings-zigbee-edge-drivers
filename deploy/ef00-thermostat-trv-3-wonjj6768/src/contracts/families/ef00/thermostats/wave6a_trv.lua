local b,c,v,j,f=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family",require"contracts.helpers.ef00",require"contracts.helpers.ef00_thermostat_metadata"local a=b.converter
local q,e=v.definition_registry()
local function d(z,i)
local function w(g)
if type(g)~="string"or #g<1+i*4 then
return nil
end
local p={}for I=0,i-1 do
local C=2+I*4
local s,n,H,J=string.byte(g,C,C+3)if s==nil or n==nil or H==nil or J==nil then
return nil
end
p[#p+1]=string.format("%02d:%02d/%.1f",s,n,((H*256)+J)/10)end
return table.concat(p," ")
end
local function D(g)
if type(g)~="string"then
return nil
end
local h,y={z},0
for A in string.gmatch(g,"%S+")do
local B,x,t=A:match"^(%d+):(%d+)/([%d%.%-]+)$"local s,n,m=tonumber(B),tonumber(x),tonumber(t)if s==nil or n==nil or m==nil
or s<0 or s>24 or n<0 or n>60
or m<5 or m>35 then
return nil
end
local k=math.floor(m*10)h[#h+1]=math.floor(s)h[#h+1]=math.floor(n)h[#h+1]=math.floor(k/256)%256
h[#h+1]=k%256
y=y+1
end
if y~=i then
return nil
end
return string.char(table.unpack(h))
end
return a.from_to(w,D)
end
local function r(g)
return({[0]="none",[1]="none",[2]="none",[3]="eco",[4]="comfort",[5]="boost"})[tonumber(g)]
end
local function u(g)
return({none=1,eco=3,comfort=4,boost=5})[g]
end
local E={profile="thermostats-wave6a-avatto-me168",package_group="trv-2",query_on_configure=false,time_start="2000",b.dp_system_mode(2,{name="system_mode",converter=a.lookup_from_to{auto=0,heat=1,off=2},emit=c.thermostat_mode()}),b.dp_enum(2,{name="me168_preset",converter=a.from_to(r,u),emit=c.meOneSixEightPreset()}),b.dp_enum(2,{name="me168_running_mode",read_only=true,converter=a.from_only(a.lookup_value{[0]="auto",[1]="manual",[2]="off",[3]="eco",[4]="comfort",[5]="boost"}),emit=c.meOneSixEightRunningMode()}),b.dp_running_state(3,{name="running_state",read_only=true,converter=a.lookup_from_to{heating=0,idle=1},emit=c.thermostat_operating_state()}),b.dp_current_heating_setpoint(4,{name="current_heating_setpoint",scale=10,emit=c.heating_setpoint"C"}),b.dp_local_temperature(5,{name="local_temperature",scale=10,read_only=true,emit=c.temperature"C"}),b.dp_battery(6,{name="battery",read_only=true,emit=c.battery()}),b.dp_child_lock(7,{name="me168_child_lock",converter=a.lookup_from_to{LOCK=true,UNLOCK=false},emit=c.meOneSixEightChildLock()}),b.dp_binary(14,{name="me168_window_detection",converter=a.lookup_from_to{ON=true,OFF=false},emit=c.meOneSixEightWindowDetection()}),b.dp_enum(15,{name="me168_window_open",read_only=true,
converter=a.from_only(function(g)
return tonumber(g)==0 and"open"or"closed"
end),
emit=c.meOneSixEightWindowOpen()}),b.dp_raw(28,{name="me168_schedule_monday",converter=d(1,6),emit=c.meOneSixEightScheduleMonday()}),b.dp_raw(29,{name="me168_schedule_tuesday",converter=d(2,6),emit=c.meOneSixEightScheduleTuesday()}),b.dp_raw(30,{name="me168_schedule_wednesday",converter=d(3,6),emit=c.meOneSixEightScheduleWednesday()}),b.dp_raw(31,{name="me168_schedule_thursday",converter=d(4,6),emit=c.meOneSixEightScheduleThursday()}),b.dp_raw(32,{name="me168_schedule_friday",converter=d(5,6),emit=c.meOneSixEightScheduleFriday()}),b.dp_raw(33,{name="me168_schedule_saturday",converter=d(6,6),emit=c.meOneSixEightScheduleSaturday()}),b.dp_raw(34,{name="me168_schedule_sunday",converter=d(7,6),emit=c.meOneSixEightScheduleSunday()}),b.dp_bitmap(35,{name="me168_error",read_only=true,
converter=a.from_only(function(g)return tonumber(g)end),
emit=c.meOneSixEightError()}),b.dp_binary(36,{name="me168_frost_protection",converter=a.lookup_from_to{ON=true,OFF=false},emit=c.meOneSixEightFrostProtection()}),b.dp_binary(39,{name="me168_scale_protection",converter=a.lookup_from_to{ON=true,OFF=false},emit=c.meOneSixEightScaleProtection()}),b.dp_local_temperature_calibration(47,{name="me168_temp_calibration",scale=1,emit=c.meOneSixEightTempCalibration()}),b.dp_comfort_temperature(101,{name="me168_comfort_temperature",scale=10,emit=c.meOneSixEightComfortTemperature()}),b.dp_numeric(103,{name="me168_boost_time",emit=c.meOneSixEightBoostTime()}),b.dp_numeric(104,{name="me168_boost_countdown",read_only=true,emit=c.meOneSixEightBoostCountdown()}),b.dp_eco_temperature(105,{name="me168_eco_temperature",scale=10,emit=c.meOneSixEightEcoTemperature()})}f.attach(E,{"off","heat","auto"},4,35,1)e(E,j.ts0601_fingerprints{"_TZE200_ybsqljjg","_TZE200_cxakecfo","_TZE200_4aijvczq","_TZE200_r5ksy7qo"})local G={profile="thermostats-wave6a-avatto-trv26",package_group="trv-2",query_on_configure=false,time_start="2000",force_time_updates=true,respond_to_mcu_version_response=true,b.dp_enum(2,{name="trv26_preset",converter=a.lookup_from_to{manual=0,auto=1,eco=2,comfort=3,antifrost=4,holiday=5},emit=c.trvTwoSixPreset()}),b.dp_running_state(3,{name="running_state",read_only=true,converter=a.lookup_from_to{idle=1,heating=0},emit=c.thermostat_operating_state()}),b.dp_current_heating_setpoint(4,{scale=10,emit=c.heating_setpoint"C"}),b.dp_local_temperature(5,{scale=10,read_only=true,emit=c.temperature"C"}),b.dp_battery(6,{read_only=true,emit=c.battery()}),b.dp_child_lock(7,{name="trv26_child_lock",converter=a.lookup_from_to{LOCK=true,UNLOCK=false},emit=c.trvTwoSixChildLock()}),b.dp_max_temperature_limit(9,{name="trv26_max_temp_limit",scale=10,emit=c.trvTwoSixMaxTempLimit()}),b.dp_min_temperature_limit(10,{name="trv26_min_temp_limit",scale=10,emit=c.trvTwoSixMinTempLimit()}),b.dp_binary(14,{name="trv26_window_detection",converter=a.lookup_from_to{on=true,off=false},emit=c.trvTwoSixWindowDetection()}),b.dp_open_window_temperature(16,{name="trv26_open_window_temp",scale=10,emit=c.trvTwoSixOpenWindowTemp()}),b.dp_raw(18,{name="trv26_schedule_tuesday",converter=d(2,4),emit=c.trvTwoSixScheduleTuesday()}),b.dp_binary(19,{name="trv26_factory_reset",converter=a.lookup_from_to{ON=true,OFF=false},emit=c.trvTwoSixFactoryReset()}),b.dp_raw(20,{name="trv26_schedule_thursday",converter=d(4,4),emit=c.trvTwoSixScheduleThursday()}),b.dp_holiday_temperature(21,{name="trv26_holiday_temperature",scale=1,emit=c.trvTwoSixHolidayTemperature()}),b.dp_raw(22,{name="trv26_schedule_saturday",converter=d(6,4),emit=c.trvTwoSixScheduleSaturday()}),b.dp_raw(23,{name="trv26_schedule_sunday",converter=d(7,4),emit=c.trvTwoSixScheduleSunday()}),b.dp_comfort_temperature(24,{name="trv26_comfort_temperature",scale=10,emit=c.trvTwoSixComfortTemperature()}),b.dp_eco_temperature(25,{name="trv26_eco_temperature",scale=10,emit=c.trvTwoSixEcoTemperature()}),b.dp_numeric(35,{name="trv26_error_status",read_only=true,emit=c.trvTwoSixErrorStatus()}),b.dp_binary(36,{name="trv26_frost_protection",converter=a.lookup_from_to{on=true,off=false},emit=c.trvTwoSixFrostProtection()}),b.dp_local_temperature_calibration(47,{name="trv26_temp_calibration",scale=10,emit=c.trvTwoSixTempCalibration()}),b.dp_system_mode(49,{name="system_mode",converter=a.lookup_from_to{off=0,heat=1},emit=c.thermostat_mode()}),b.dp_numeric(101,{name="trv26_uptime",converter=a.divide_by_pair(10),read_only=true,emit=c.trvTwoSixUptime()}),b.dp_numeric(102,{name="trv26_descale_countdown",converter=a.divide_by_pair(10),read_only=true,emit=c.trvTwoSixDescaleCountdown()})}f.attach(G,{"off","heat"},5,35,0.5)e(G,j.ts0601_fingerprints{"_TZE204_xdtnpp1a","_TZE284_xdtnpp1a"})local F={profile="thermostats-wave6a-nedis-zbhtr20wt",package_group="trv-2",query_on_configure=false,time_start="1970",b.dp_running_state(3,{name="running_state",read_only=true,converter=a.lookup_from_to{heating=1,idle=0},emit=c.thermostat_operating_state()}),b.dp_binary(8,{name="nedis_open_window",converter=a.lookup_from_to{ON=true,OFF=false},emit=c.nedisHtrOpenWindow()}),b.dp_binary(10,{name="nedis_frost_protection",converter=a.lookup_from_to{ON=true,OFF=false},emit=c.nedisHtrFrostProtection()}),b.dp_local_temperature_calibration(27,{name="nedis_temp_calibration",scale=1,emit=c.nedisHtrTempCalibration()}),b.dp_child_lock(40,{name="nedis_child_lock",converter=a.lookup_from_to{LOCK=true,UNLOCK=false},emit=c.nedisHtrChildLock()}),b.dp_system_mode(101,{name="system_mode",converter=a.lookup_from_to{heat=true,off=false},emit=c.thermostat_mode()}),b.dp_local_temperature(102,{scale=10,read_only=true,emit=c.temperature"C"}),b.dp_current_heating_setpoint(103,{scale=10,emit=c.heating_setpoint"C"}),b.dp_binary(106,{name="nedis_leave_home",converter=a.lookup_from_to{ON=true,OFF=false},emit=c.nedisHtrLeaveHome()}),b.dp_binary(108,{name="nedis_schedule_mode",converter=a.lookup_from_to{ON=true,OFF=false},emit=c.nedisHtrScheduleMode()})}f.attach(F,{"off","heat"},5,30,0.5)e(F,j.ts0601_fingerprints{"_TZE200_ne4pikwm","_TZE284_ne4pikwm","_TZE284_hcs66axl"})local o={profile="thermostats-radiator-cbe-1443zk-core",package_group="trv-2",magic_packet=true,mcu_version_request_on_configure=true,query_on_configure=false,time_start="2000",force_time_updates=true,b.dp_running_state(3,{name="running_state",read_only=true,converter=a.lookup_from_to{idle=1,heating=0},emit=c.thermostat_operating_state()}),b.dp_current_heating_setpoint(4,{name="current_heating_setpoint",
from_device=function(g)
local l=tonumber(g)if l==nil or l==-1 or l==0xffffffff then return nil end
return l/10
end,
to_device=function(g)
local l=tonumber(g)if l==nil then return nil end
return math.floor(l*10+0.5)
end,
emit=c.heating_setpoint"C"}),b.dp_local_temperature(5,{name="local_temperature",scale=10,read_only=true,emit=c.temperature"C"}),b.dp_battery(6,{name="battery",read_only=true,emit=c.battery()})}f.attach_setpoint_only(o,5,35,0.5)e(o,j.ts0601_fingerprints{"_TZE284_16m4bgsv"})return{id="ef00.thermostats.wave6a_trv",registrations=q}
