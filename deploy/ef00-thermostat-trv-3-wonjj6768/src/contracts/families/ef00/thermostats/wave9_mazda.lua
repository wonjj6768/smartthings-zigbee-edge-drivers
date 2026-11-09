local b,d,u,v,n=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family",require"contracts.helpers.ef00",require"contracts.helpers.ef00_thermostat_metadata"local c=b.converter
local o,i=u.definition_registry()
local function a(z)
local function w(e)
if type(e)~="string"or #e<25 then
return nil
end
local l={}for G=0,5 do
local C=2+G*4
local r,j,F,H=string.byte(e,C,C+3)if r==nil or j==nil or F==nil or H==nil then
return nil
end
l[#l+1]=string.format("%02d:%02d/%.1f",r,j,((F*256)+H)/10)end
return table.concat(l," ")
end
local function D(e)
if type(e)~="string"then
return nil
end
local f,y={z},0
for A in string.gmatch(e,"%S+")do
local B,x,t=
A:match"^(%d+):(%d+)/([%d%.%-]+)$"local r,j,h=tonumber(B),tonumber(x),tonumber(t)if r==nil or j==nil or h==nil
or r<0 or r>24 or j<0 or j>60
or h<5 or h>35 then
return nil
end
local g=math.floor(h*10)f[#f+1]=math.floor(r)f[#f+1]=math.floor(j)f[#f+1]=math.floor(g/256)%256
f[#f+1]=g%256
y=y+1
end
if y~=6 then
return nil
end
return string.char(table.unpack(f))
end
return c.from_to(w,D)
end
local function k(e)
local q=tonumber(e)if q==6 then
return"off"end
if q~=nil and q>=0 and q<=5 then
return"heat"end
return nil
end
local function m(e)
return({heat=0,off=6})[e]
end
local function p(e)
return({[0]="none",[1]="schedule",[2]="eco",[3]="comfort",[4]="frost_protection",[5]="holiday",[6]="none"})[tonumber(e)]
end
local function s(e)
return({none=0,schedule=1,eco=2,comfort=3,frost_protection=4,holiday=5})[e]
end
local E={profile="thermostats-wave9-mazda-tr-m2z",package_group="trv-2",query_on_configure=false,time_start="2000",b.dp_system_mode(2,{name="system_mode",converter=c.from_to(k,m),emit=d.thermostat_mode()}),b.dp_enum(2,{name="mazda_mtwo_preset",converter=c.from_to(p,s),emit=d.mazdaMtwoPreset()}),b.dp_numeric(3,{name="running_state",read_only=true,converter=c.lookup_from_to{heating=1,idle=0},emit=d.thermostat_operating_state()}),b.dp_current_heating_setpoint(4,{scale=10,emit=d.heating_setpoint"C"}),b.dp_local_temperature(5,{scale=10,read_only=true,emit=d.temperature"C"}),b.dp_battery(6,{read_only=true,emit=d.battery()}),b.dp_child_lock(7,{name="mazda_mtwo_child_lock",converter=c.lookup_from_to{LOCK=true,UNLOCK=false},emit=d.mazdaMtwoChildLock()}),b.dp_binary(14,{name="mazda_mtwo_window_detection",converter=c.lookup_from_to{ON=true,OFF=false},emit=d.mazdaMtwoWindowDetection()}),b.dp_enum(15,{name="mazda_mtwo_window_open",read_only=true,
converter=c.from_only(function(e)
return tonumber(e)==0 and"open"or"closed"
end),
emit=d.mazdaMtwoWindowOpen()}),b.dp_holiday_temperature(21,{name="mazda_mtwo_holiday_temperature",scale=10,emit=d.mazdaMtwoHolidayTemperature()}),b.dp_raw(28,{name="mazda_mtwo_schedule_monday",converter=a(1),emit=d.mazdaMtwoScheduleMonday()}),b.dp_raw(29,{name="mazda_mtwo_schedule_tuesday",converter=a(2),emit=d.mazdaMtwoScheduleTuesday()}),b.dp_raw(30,{name="mazda_mtwo_schedule_wednesday",converter=a(3),emit=d.mazdaMtwoScheduleWednesday()}),b.dp_raw(31,{name="mazda_mtwo_schedule_thursday",converter=a(4),emit=d.mazdaMtwoScheduleThursday()}),b.dp_raw(32,{name="mazda_mtwo_schedule_friday",converter=a(5),emit=d.mazdaMtwoScheduleFriday()}),b.dp_raw(33,{name="mazda_mtwo_schedule_saturday",converter=a(6),emit=d.mazdaMtwoScheduleSaturday()}),b.dp_raw(34,{name="mazda_mtwo_schedule_sunday",converter=a(7),emit=d.mazdaMtwoScheduleSunday()}),b.dp_binary(35,{name="mazda_mtwo_alarm_switch",read_only=true,converter=c.lookup_from_to{ON=true,OFF=false},emit=d.mazdaMtwoAlarmSwitch()}),b.dp_binary(36,{name="mazda_mtwo_frost_protection",converter=c.lookup_from_to{ON=true,OFF=false},emit=d.mazdaMtwoFrostProtection()}),b.dp_local_temperature_calibration(47,{name="mazda_mtwo_temp_calibration",scale=10,emit=d.mazdaMtwoTempCalibration()}),b.dp_numeric(102,{name="mazda_mtwo_temperature_sensitivity",converter=c.divide_by_pair(10),emit=d.mazdaMtwoTemperatureSensitivity()}),b.dp_eco_temperature(103,{name="mazda_mtwo_eco_temperature",scale=10,emit=d.mazdaMtwoEcoTemperature()}),b.dp_comfort_temperature(104,{name="mazda_mtwo_comfort_temperature",scale=10,emit=d.mazdaMtwoComfortTemperature()})}n.attach(E,{"off","heat"},5,35,0.5)i(E,v.ts0601_fingerprints{"_TZE284_k6rdmisz","_TZE204_k6rdmisz"})return{id="ef00.thermostats.wave9_mazda",registrations=o}
