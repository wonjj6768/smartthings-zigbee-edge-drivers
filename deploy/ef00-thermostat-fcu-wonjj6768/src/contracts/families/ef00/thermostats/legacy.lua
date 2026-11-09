local b,c,a,q,g=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family",require"contracts.helpers.ef00",require"contracts.helpers.ef00_thermostats"local d=b.converter
local p,e=a.definition_registry()
local function j(_,f)
if f~="off"and f~="heat"and f~="auto"then
return nil
end
return{{dp=101,datatype=b.DP_TYPE_BOOL,value=f~="off"},{dp=108,datatype=b.DP_TYPE_BOOL,value=f=="auto"}}
end
local m,o,u=g.power_mode_from_device,g.enum_mode_from_device,g.power_mode_write


local h={profile="thermostats-thermostat-saswell",bind_basic_on_configure=true,time_start="1970",heating_setpoint_range={minimum=5,maximum=30,step=0.5,unit="C"},named_mapping={named_mappings={system_mode=j}},b.dp_running_state(3,{converter=d.lookup_from_to{heat=1,idle=0}}),b.dp_binary(8,{name="window_detection",emit=c.saswellWindowDetection(),converter=d.lookup_from_to{off=false,on=true}}),b.dp_binary(10,{name="frost_detection",emit=c.saswellFrostDetection(),converter=d.lookup_from_to{off=false,on=true}}),b.dp_numeric(27,{name="local_temperature_calibration",emit=c.saswellTempCalibration(),converter=d.signed_number_pair(1),signed=true}),b.dp_binary(40,{name="child_lock",emit=c.saswellChildLock(),converter=d.lookup_from_to{unlock=false,lock=true}}),b.dp_local_temperature(102,{scale=10}),b.dp_current_heating_setpoint(103,{scale=10}),b.dp_binary(105,{name="battery_low",read_only=true,emit=c.saswellBatteryLow(),
converter=d.from_only(function(f)
return f and"low"or"normal"
end)
}),b.dp_binary(106,{name="away_mode",emit=c.saswellAwayMode(),converter=d.lookup_from_to{off=false,on=true}}),b.dp_binary(130,{name="anti_scaling",emit=c.saswellAntiScaling(),converter=d.lookup_from_to{off=false,on=true}}),b.dp_system_mode(101,{converter=d.lookup_from_to{heat=true,off=false}}),b.dp_binary(108,{name="saswell_schedule_enable",
from_device=function(f)
if f then
return"auto"end
return nil
end,
emit=c.thermostat_mode()})}for w,day in ipairs{{"sun",c.saswellSunSchedule()},{"mon",c.saswellMonSchedule()},{"tue",c.saswellTueSchedule()},{"wed",c.saswellWedSchedule()},{"thu",c.saswellThuSchedule()},{"fri",c.saswellFriSchedule()},{"sat",c.saswellSatSchedule()}}do
local y,z=g.saswell_schedule(w-1),"saswell_"..day[1].."_schedule"h[#h+1]=b.dp_raw(122+w,{name=z,read_only=true,converter=d.from_only(y.from),emit=day[2]})
h.named_mapping.named_mappings[z]=function(_,f)
local B=y.to(f)if B then return{dp=109,datatype=b.DP_TYPE_RAW,value=B}end
end
end
e(h,{a.create_fingerprint("_TYST11_KGbxAXL2","GbxAXL2"),a.create_fingerprint("_TYST11_zuhszj9s","uhszj9s"),a.create_fingerprint("_TYST11_c88teujp","88teujp"),a.create_fingerprint("_TYST11_yw7cahqs","w7cahqs"),a.create_fingerprint("_TYST11_caj4jz0i","aj4jz0i"),a.create_fingerprint("_TZE200_c88teujp","TS0601"),a.create_fingerprint("_TZE200_yw7cahqs","TS0601"),a.create_fingerprint("_TZE200_azqp6ssj","TS0601"),a.create_fingerprint("_TZE200_zuhszj9s","TS0601"),a.create_fingerprint("_TZE200_9gvruqf5","TS0601"),a.create_fingerprint("_TZE200_zr9c0day","TS0601"),a.create_fingerprint("_TZE200_0dvm9mva","TS0601"),a.create_fingerprint("_TZE284_0dvm9mva","TS0601"),a.create_fingerprint("_TZE200_h4cgnbzg","TS0601"),a.create_fingerprint("_TZE200_gd4rvykv","TS0601"),a.create_fingerprint("_TZE200_exfrnlow","TS0601"),a.create_fingerprint("_TZE200_9m4kmbfu","TS0601"),a.create_fingerprint("_TZE284_9m4kmbfu","TS0601"),a.create_fingerprint("_TZE200_3yp57tby","TS0601"),a.create_fingerprint("_TZE204_3yp57tby","TS0601"),a.create_fingerprint("_TZE200_7p8ugv8d","TS0601"),a.create_fingerprint("_TZE284_3yp57tby","TS0601"),a.create_fingerprint("_TZE2841000000_3yp57tby","TS0601"),a.create_fingerprint("_TZE200_3ymoslep","TS0601"),a.create_fingerprint("_TZE204_3ymoslep","TS0601"),a.create_fingerprint("_TZE284_3ymoslep","TS0601"),a.create_fingerprint("_TZE2841000000_3ymoslep","TS0601")})local v={"high_temperature","low_temperature","internal_sensor_error","external_sensor_error","battery_low","device_offline"}
local i=d.from_only(function(f)
local A=tonumber(f)if A==nil then
return nil
end
local x={}for w,z in ipairs(v)do
if A%(2 ^ w)>=2 ^(w-1)then
x[#x+1]=z
end
end
if #x==0 then
return"none"end
return table.concat(x,",")
end)
local k,l,t="etop_power_state","etop_system_mode_device",u(1,4,{heat=0,auto=2})local n={profile="thermostats-thermostat-etop",named_mapping={named_mappings={system_mode=t}},b.dp_binary(1,{name="system_mode",from_device=m(k,l,"heat"),emit=c.thermostat_mode()}),b.dp_current_heating_setpoint(2,{scale=10}),b.dp_local_temperature(3,{scale=10}),b.dp_enum(4,{name="system_mode",from_device=o(k,l,{[0]="heat",[1]="heat",[2]="auto"}),emit=c.thermostat_mode(),read_only=true}),b.dp_child_lock(7,{name="child_lock",emit=c.etopChildLock()}),b.dp_numeric(13,{name="error_status",read_only=true,converter=i,emit=c.etopErrorStatus()}),b.dp_running_state(14,{converter=d.lookup_from_to{heating=true,idle=false},emit=c.thermostat_operating_state()})}e(n,{a.create_fingerprint("_TZE200_2dpplnsn","TS0601"),a.create_fingerprint("_TZE200_wv90ladg","TS0601"),a.create_fingerprint("_TYST11_2dpplnsn","dpplnsn"),a.create_fingerprint("_TYST11_wv90ladg","v90ladg")})local s={profile="thermostats-thermostat-sas936",named_mapping={named_mappings={
system_mode=function(_,f)
if f=="heat"then
return{{dp=101,datatype=b.DP_TYPE_BOOL,value=true}}end
if f=="off"then
return{{dp=101,datatype=b.DP_TYPE_BOOL,value=false}}end
return nil
end
}},b.dp_running_state(3,{
from_device=function(f)
if type(f)=="table"then
f=f[#f]end
return(tonumber(f)or 0)==1 and"heating"or"idle"
end,
emit=c.thermostat_operating_state(),read_only=true}),b.dp_child_lock(40,{emit=c.sas936ChildLock()}),b.dp_system_mode(101,{converter=d.lookup_from_to{heat=true,off=false},emit=c.thermostat_mode()}),b.dp_local_temperature(102,{scale=10}),b.dp_current_heating_setpoint(103,{scale=10}),b.dp_binary(106,{name="temporary_leaving",emit=c.sas936TemporaryLeaving(),converter=d.lookup_from_to{off=false,on=true}})}e(s,q.ts0601_fingerprints{"_TZE284_madl8ejv"})local r={profile="thermostats-thermostat-basic-twc-r01",b.dp_enum(2,{name="pilot_wire_mode",converter=d.lookup_from_to{comfort=0,eco=1,antifrost=2,off=3,comfort_1=4,comfort_2=5},emit=c.pilotWireModeTwcR01()}),b.dp_power(11,{name="power",scale=10,emit=c.power()}),b.dp_local_temperature(16,{scale=10}),b.dp_local_temperature_calibration(19,{scale=1,emit=c.twcr01TempCalibration()}),b.dp_numeric(20,{name="fault",read_only=true,emit=c.twcr01Fault()}),b.dp_eco_mode(40,{emit=c.twcr01EcoMode()}),b.dp_open_window(110,{emit=c.twcr01OpenWindow()}),b.dp_temperature(111,{name="open_window_temperature",scale=1,emit=c.twcr01OpenWindowTemperature()}),b.dp_binary(114,{name="device_mode_type",emit=c.twcr01DeviceModeType()}),b.dp_voltage(115,{name="voltage",scale=10,emit=c.voltage()}),b.dp_current(116,{name="current",scale=10,emit=c.current()}),b.dp_energy(117,{name="energy",scale=10,emit=c.energy()}),b.dp_energy(119,{name="energy_today",scale=10,emit=c.energyTodayTwcR01()}),b.dp_energy(120,{name="energy_yesterday",scale=10,emit=c.energyYesterdayTwcR01()})}e(r,q.ts0601_fingerprints{"_TZE204_ilzkxrav"})return{id="ef00.thermostats.legacy",registrations=p}
