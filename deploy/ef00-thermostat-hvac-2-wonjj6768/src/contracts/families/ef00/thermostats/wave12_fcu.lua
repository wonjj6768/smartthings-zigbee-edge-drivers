local d,k,w,s,f,A=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family",require"contracts.helpers.ef00",require"contracts.helpers.ef00_thermostat_metadata",require"contracts.helpers.ef00_thermostat_wave12"local q=d.converter
local r,b=w.definition_registry()local j,m="__wave12_bac_power","__wave12_bac_mode"
local function n(a,c)
local o=a==true or a==1
c:set_field(j,o,{persist=false})if not o then return"off"end
return c:get_field(m)or"cool"
end
local function p(a,c)
local z=({[0]="cool",[1]="heat",[2]="fanonly"})[tonumber(a)]or"cool"c:set_field(m,z,{persist=false})if c:get_field(j)==false then return"off"end
return z
end
local function v(_,a)
if a=="off"then
return{{dp=1,datatype=d.DP_TYPE_BOOL,value=false}}end
local C=({cool=0,heat=1,fanonly=2})[a]if C==nil then return nil end
return{{dp=1,datatype=d.DP_TYPE_BOOL,value=true},{dp=2,datatype=d.DP_TYPE_ENUM,value=C}}
end
local u=q.from_to(
function(a)
local e=tonumber(a)if e==nil then return nil end
return e>0x7fffffff and e-4294967296 or e
end,
function(a)
local e=tonumber(a)if e==nil then return nil end
return e<0 and 4294967296+e or e
end
)local D={profile="thermostats-wave12-tuya-bac001",package_group="fcu",query_on_configure=false,time_start="1970",force_time_updates=true,d.dp_binary(1,{name="system_mode",from_device=n,read_only=true,emit=k.thermostat_mode()}),d.dp_enum(2,{name="system_mode",from_device=p,read_only=true,emit=k.thermostat_mode()}),d.dp_current_heating_setpoint(16,{scale=10,emit=k.heating_setpoint"C"}),d.dp_local_temperature(24,{scale=10,read_only=true,emit=k.temperature"C"}),A.numeric(27,"tuya_bac_temp_calibration","tuyaBacTempCalibration",1,false,{converter=u}),d.dp_enum(28,{name="fan_mode",converter=q.lookup_from_to{low=0,medium=1,high=2,auto=3},emit=k.fan_mode()})}A.override_named_writer(D,"system_mode",v)f.attach(D,{"off","cool","heat","fanonly"},5,35,0.5)b(D,s.ts0601_fingerprints{"_TZE204_hpkusvom"})local g,h="__wave255_gluon_power","__wave255_gluon_mode"
local function i(a,c)
local o=a==true or a==1
c:set_field(g,o,{persist=false})if not o then return"off"end
return c:get_field(h)or"cool"
end
local function l(a,c)
local z=({[0]="cool",[1]="heat",[2]="fanonly"})[tonumber(a)]if z==nil then return nil end
c:set_field(h,z,{persist=false})if c:get_field(g)==false then return"off"end
return z
end
local function t(_,a)
if a=="off"then
return{{dp=1,datatype=d.DP_TYPE_BOOL,value=false}}end
local C=({cool=0,heat=1,fanonly=2,fan_only=2})[a]if C==nil then return nil end
return{{dp=1,datatype=d.DP_TYPE_BOOL,value=true},{dp=2,datatype=d.DP_TYPE_ENUM,value=C}}
end
local y,x=d.dp_current_heating_setpoint(16,{name="current_heating_setpoint",scale=1,emit=k.heating_setpoint"C"}),d.dp_fan_mode(49,{name="fan_mode",converter=q.lookup_from_to{low=0,medium=1,high=2,auto=3},emit=k.fan_mode()})local B={profile="thermostats-fcu-gluon-st001-core",package_group="fcu",magic_packet=true,mcu_version_request_on_configure=true,query_on_configure=false,time_start="1970",force_time_updates=true,d.dp_binary(1,{name="state",from_device=i,read_only=true,emit=k.thermostat_mode()}),d.dp_enum(2,{name="system_mode",from_device=l,read_only=true,emit=k.thermostat_mode()}),y,d.dp_local_temperature(24,{name="local_temperature",scale=10,read_only=true,emit=k.temperature"C"}),x}A.override_named_writer(B,"system_mode",t)f.attach(B,{"off","cool","heat","fanonly"},5,35,1)b(B,s.ts0601_fingerprints{"_TZE200_d2nady2a","_TZE204_d2nady2a"})return{id="ef00.thermostats.wave12_fcu",registrations=r}
