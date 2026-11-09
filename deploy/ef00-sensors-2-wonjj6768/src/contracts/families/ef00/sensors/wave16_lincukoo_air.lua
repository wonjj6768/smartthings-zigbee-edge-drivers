local m,l,j=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family"local s,g=j.definition_registry()
local function v(capability_id)
return assert(l[capability_id],"missing Wave16 Lincukoo air emitter: "..capability_id)()
end
local function p(o,z,h)
return{name=o,emit=z,read_only=h==true,transaction=1}
end
local function a(y,o,z,n,w)
local d=p(o,z,true)if w then
d.signed=true
d.converter=m.converter.signed_number_pair(n or 1)elseif n~=nil and n~=1 then
d.converter=m.converter.divide_by_pair(n)end
return m.dp_numeric(y,d)
end
local function u(y,o,capability_id,n,h,w)
local d=p(o,v(capability_id),h)if w then
d.signed=true
d.converter=m.converter.signed_number_pair(n or 1)elseif n~=nil and n~=1 then
d.converter=m.converter.divide_by_pair(n)end
return m.dp_numeric(y,d)
end
local function r(y,o,capability_id,x,h)
local d=p(o,v(capability_id),h)d.converter=m.converter.lookup_from_to(x)return m.dp_numeric(y,d)
end
local function t(y,o,capability_id,x,h)
local d=p(o,v(capability_id),h)d.converter=m.converter.lookup_from_to(x)return m.dp_enum(y,d)
end
local function A(y,o,capability_id,h)
local d=p(o,v(capability_id),h)d.converter=m.converter.lookup_from_to{ON=true,OFF=false}return m.dp_binary(y,d)
end
local function q(C)
return{profile=C,package_group="air-quality-sensor",magic_packet=true,query_on_configure=false,time_start="off",datapoints={}}
end
local function i(B,d)
B.datapoints[#B.datapoints+1]=d
end
local k,b={celsius=0,fahrenheit=1},q"sensors-wave16-lincukoo-e02c-z10t"b.force_time_updates=true
b.time_start="1970"i(b,a(2,"temperature",l.temperature"C",10,true))i(b,a(3,"humidity",l.humidity(),1,false))i(b,a(4,"co2",l.co2(),1,false))i(b,a(22,"battery",l.battery(),1,false))i(b,t(102,"e_zero_two_c_temperature_unit","eZeroTwoCTemperatureUnit",k,false))i(b,A(101,"e_zero_two_c_alarm_switch","eZeroTwoCAlarmSwitch",false))i(b,r(103,"e_zero_two_c_charge_status","eZeroTwoCChargeStatus",{none=0,charging=1},true))i(b,t(104,"e_zero_two_c_reset_co_two","eZeroTwoCResetCoTwo",{reset_co2=0},false))i(b,t(105,"e_zero_two_c_screen_sleep","eZeroTwoCScreenSleep",{after_30s=0,after_1minute=1,after_2minutes=2,after_5minutes=3,after_10minutes=4,never_sleep=5},false))i(b,u(106,"e_zero_two_c_co_two_alarm_value","eZeroTwoCCoTwoAlarmValue",1,false,false))i(b,A(107,"e_zero_two_c_co_two_alarm","eZeroTwoCCoTwoAlarm",true))g(b,j.create_fingerprints("TS0601",{"_TZE204_hyt4iucb","_TZE28C1000000_hyt4iucb"}))local f=q"sensors-wave16-lincukoo-ezc04"i(f,r(1,"ezc_zero_four_co_two_state","ezcZeroFourCoTwoState",{alarm=0,normal=1},true))i(f,a(2,"co2",l.co2(),1,false))i(f,t(6,"ezc_zero_four_alarm_ringtone","ezcZeroFourAlarmRingtone",{ringtone_0=0,ringtone_1=1,ringtone_2=2,ringtone_3=3},false))i(f,a(18,"temperature",l.temperature"C",10,true))i(f,a(19,"humidity",l.humidity(),1,false))i(f,u(26,"ezc_zero_four_co_two_alarm_value","ezcZeroFourCoTwoAlarmValue",1,false,false))i(f,t(31,"ezc_zero_four_temperature_unit","ezcZeroFourTemperatureUnit",k,false))i(f,t(101,"ezc_zero_four_reset_co_two","ezcZeroFourResetCoTwo",{reset_co2=0},false))g(f,j.create_fingerprints("TS0601",{"_TZE204_isvlaage","_TZE28C1000000_isvlaage"}))local c=q"sensors-wave16-lincukoo-ezcp04"i(c,r(1,"ezcp_zero_four_alarm_state","ezcpZeroFourAlarmState",{normal=0,alarm_co2=1,alarm_pm25=2},true))i(c,a(2,"co2",l.co2(),1,false))i(c,t(6,"ezcp_zero_four_alarm_ringtone","ezcpZeroFourAlarmRingtone",{mute=0,ringtone_1=1,ringtone_2=2,ringtone_3=3},false))i(c,a(18,"temperature",l.temperature"C",10,true))i(c,a(19,"humidity",l.humidity(),1,false))i(c,u(26,"ezcp_zero_four_co_two_alarm_value","ezcpZeroFourCoTwoAlarmValue",1,false,false))i(c,t(31,"ezcp_zero_four_temperature_unit","ezcpZeroFourTemperatureUnit",k,false))i(c,a(20,"pm25",l.pm25(),1,false))i(c,u(101,"ezcp_zero_four_pm_two_five_alarm_value","ezcpZeroFourPm25AlarmValue",1,false,false))g(c,j.create_fingerprints("TS0601",{"_TZE204_fpwtjlfh","_TZE28C1000000_fpwtjlfh"}))return{id="ef00.sensors.wave16_lincukoo_air",registrations=s}
