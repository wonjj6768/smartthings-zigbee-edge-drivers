local tuya=require "protocol.tuya"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local ef00_helpers=require "contracts.helpers.ef00"
local thermostat_common=require "contracts.helpers.ef00_thermostats"
local converter=tuya.converter
local device_definitions,register_device_definition=device_helpers.definition_registry()
local function saswell_system_mode_write(_,value)
if value ~="off" and value ~="heat" and value ~="auto" then
return nil
end
return{
{dp=101,datatype=tuya.DP_TYPE_BOOL,value=value ~="off"},
{dp=108,datatype=tuya.DP_TYPE_BOOL,value=value=="auto"},
}
end
local power_mode_from_device=thermostat_common.power_mode_from_device
local enum_mode_from_device=thermostat_common.enum_mode_from_device
local power_mode_write=thermostat_common.power_mode_write
local saswell_legacy={
profile="thermostats-thermostat-saswell",
bind_basic_on_configure=true,
named_mapping={
named_mappings={
system_mode=saswell_system_mode_write,
},
},
tuya.dp_running_state(3,{
converter=converter.lookup_from_to({
heat=1,
idle=0,
}),
}),
tuya.dp_binary(8,{
name="window_detection",
emit=emit.saswellWindowDetection(),
converter=converter.lookup_from_to({off=false,on=true}),
}),
tuya.dp_binary(10,{
name="frost_detection",
emit=emit.saswellFrostDetection(),
converter=converter.lookup_from_to({off=false,on=true}),
}),
tuya.dp_numeric(27,{
name="local_temperature_calibration",
emit=emit.saswellTempCalibration(),
converter=converter.signed_number_pair(1),
signed=true,
}),
tuya.dp_binary(40,{
name="child_lock",
emit=emit.saswellChildLock(),
converter=converter.lookup_from_to({unlock=false,lock=true}),
}),
tuya.dp_local_temperature(102,{scale=10}),
tuya.dp_current_heating_setpoint(103,{scale=10}),
tuya.dp_binary(105,{
name="battery_low",
read_only=true,
emit=emit.saswellBatteryLow(),
converter=converter.from_only(function(value)
return value and "low" or "normal"
end),
}),
tuya.dp_binary(106,{
name="away_mode",
emit=emit.saswellAwayMode(),
converter=converter.lookup_from_to({off=false,on=true}),
}),
tuya.dp_binary(130,{
name="anti_scaling",
emit=emit.saswellAntiScaling(),
converter=converter.lookup_from_to({off=false,on=true}),
}),
tuya.dp_system_mode(101,{
converter=converter.lookup_from_to({
heat=true,
off=false,
}),
}),
tuya.dp_binary(108,{
name="saswell_schedule_enable",
from_device=function(value)
if value then
return "auto"
end
return nil
end,
emit=emit.thermostat_mode(),
}),
}
register_device_definition(saswell_legacy,{
device_helpers.create_fingerprint("_TYST11_KGbxAXL2","GbxAXL2"),
device_helpers.create_fingerprint("_TYST11_zuhszj9s","uhszj9s"),
device_helpers.create_fingerprint("_TYST11_c88teujp","88teujp"),
device_helpers.create_fingerprint("_TYST11_yw7cahqs","w7cahqs"),
device_helpers.create_fingerprint("_TYST11_caj4jz0i","aj4jz0i"),
device_helpers.create_fingerprint("_TZE200_c88teujp","TS0601"),
device_helpers.create_fingerprint("_TZE200_yw7cahqs","TS0601"),
device_helpers.create_fingerprint("_TZE200_azqp6ssj","TS0601"),
device_helpers.create_fingerprint("_TZE200_zuhszj9s","TS0601"),
device_helpers.create_fingerprint("_TZE200_9gvruqf5","TS0601"),
device_helpers.create_fingerprint("_TZE200_zr9c0day","TS0601"),
device_helpers.create_fingerprint("_TZE200_0dvm9mva","TS0601"),
device_helpers.create_fingerprint("_TZE284_0dvm9mva","TS0601"),
device_helpers.create_fingerprint("_TZE200_h4cgnbzg","TS0601"),
device_helpers.create_fingerprint("_TZE200_gd4rvykv","TS0601"),
device_helpers.create_fingerprint("_TZE200_exfrnlow","TS0601"),
device_helpers.create_fingerprint("_TZE200_9m4kmbfu","TS0601"),
device_helpers.create_fingerprint("_TZE284_9m4kmbfu","TS0601"),
device_helpers.create_fingerprint("_TZE200_3yp57tby","TS0601"),
device_helpers.create_fingerprint("_TZE200_7p8ugv8d","TS0601"),
device_helpers.create_fingerprint("_TZE284_3yp57tby","TS0601"),
})
local ETOP_ERROR_BITS={
"high_temperature",
"low_temperature",
"internal_sensor_error",
"external_sensor_error",
"battery_low",
"device_offline",
}
local etop_error_status_converter=converter.from_only(function(value)
local bitmap=tonumber(value)
if bitmap==nil then
return nil
end
local names={}
for index,name in ipairs(ETOP_ERROR_BITS)do
if bitmap %(2 ^ index)>=2 ^(index - 1)then
names[#names + 1]=name
end
end
if #names==0 then
return "none"
end
return table.concat(names,",")
end)
local ETOP_POWER_FIELD="etop_power_state"
local ETOP_MODE_FIELD="etop_system_mode_device"
local etop_system_mode=power_mode_write(1,4,{
heat=0,
auto=2,
})
local thermostat_etop_legacy={
profile="thermostats-thermostat-etop",
named_mapping={
named_mappings={
system_mode=etop_system_mode,
},
},
tuya.dp_binary(1,{
name="system_mode",
from_device=power_mode_from_device(ETOP_POWER_FIELD,ETOP_MODE_FIELD,"heat"),
emit=emit.thermostat_mode(),
}),
tuya.dp_current_heating_setpoint(2,{scale=10}),
tuya.dp_local_temperature(3,{scale=10}),
tuya.dp_enum(4,{
name="system_mode",
from_device=enum_mode_from_device(ETOP_POWER_FIELD,ETOP_MODE_FIELD,{
[0]="heat",
[1]="heat",
[2]="auto",
}),
emit=emit.thermostat_mode(),
read_only=true,
}),
tuya.dp_child_lock(7,{name="child_lock",emit=emit.etopChildLock()}),
tuya.dp_numeric(13,{
name="error_status",
read_only=true,
converter=etop_error_status_converter,
emit=emit.etopErrorStatus(),
}),
tuya.dp_running_state(14,{
converter=converter.lookup_from_to({
heating=true,
idle=false,
}),
emit=emit.thermostat_operating_state(),
}),
}
register_device_definition(thermostat_etop_legacy,{
device_helpers.create_fingerprint("_TZE200_2dpplnsn","TS0601"),
device_helpers.create_fingerprint("_TZE200_wv90ladg","TS0601"),
device_helpers.create_fingerprint("_TYST11_2dpplnsn","dpplnsn"),
device_helpers.create_fingerprint("_TYST11_wv90ladg","v90ladg"),
})
local thermostat_sas936={
profile="thermostats-thermostat-sas936",
named_mapping={
named_mappings={
system_mode=function(_,value)
if value=="heat" then
return{{dp=101,datatype=tuya.DP_TYPE_BOOL,value=true}}
end
if value=="off" then
return{{dp=101,datatype=tuya.DP_TYPE_BOOL,value=false}}
end
return nil
end,
},
},
tuya.dp_running_state(3,{
from_device=function(value)
if type(value)=="table" then
value=value[#value]
end
return(tonumber(value)or 0)==1 and "heating" or "idle"
end,
emit=emit.thermostat_operating_state(),
read_only=true,
}),
tuya.dp_child_lock(40,{emit=emit.sas936ChildLock()}),
tuya.dp_system_mode(101,{
converter=converter.lookup_from_to({
heat=true,
off=false,
}),
emit=emit.thermostat_mode(),
}),
tuya.dp_local_temperature(102,{scale=10}),
tuya.dp_current_heating_setpoint(103,{scale=10}),
tuya.dp_binary(106,{
name="temporary_leaving",
emit=emit.sas936TemporaryLeaving(),
converter=converter.lookup_from_to({off=false,on=true}),
}),
}
register_device_definition(thermostat_sas936,ef00_helpers.ts0601_fingerprints({
"_TZE284_madl8ejv",
}))
local thermostat_twc_r01={
profile="thermostats-thermostat-basic-twc-r01",
tuya.dp_enum(2,{
name="pilot_wire_mode",
converter=converter.lookup_from_to({
comfort=0,
eco=1,
antifrost=2,
off=3,
comfort_1=4,
comfort_2=5,
}),
emit=emit.pilotWireModeTwcR01(),
}),
tuya.dp_power(11,{name="power",scale=10,emit=emit.power()}),
tuya.dp_local_temperature(16,{scale=10}),
tuya.dp_local_temperature_calibration(19,{scale=1,emit=emit.twcr01TempCalibration()}),
tuya.dp_numeric(20,{name="fault",read_only=true,emit=emit.twcr01Fault()}),
tuya.dp_eco_mode(40,{emit=emit.twcr01EcoMode()}),
tuya.dp_open_window(110,{emit=emit.twcr01OpenWindow()}),
tuya.dp_temperature(111,{
name="open_window_temperature",
scale=1,
emit=emit.twcr01OpenWindowTemperature(),
}),
tuya.dp_binary(114,{name="device_mode_type",emit=emit.twcr01DeviceModeType()}),
tuya.dp_voltage(115,{name="voltage",scale=10,emit=emit.voltage()}),
tuya.dp_current(116,{name="current",scale=10,emit=emit.current()}),
tuya.dp_energy(117,{name="energy",scale=10,emit=emit.energy()}),
tuya.dp_energy(119,{name="energy_today",scale=10,emit=emit.energyTodayTwcR01()}),
tuya.dp_energy(120,{name="energy_yesterday",scale=10,emit=emit.energyYesterdayTwcR01()}),
}
register_device_definition(thermostat_twc_r01,ef00_helpers.ts0601_fingerprints({
"_TZE204_ilzkxrav",
}))
return{
id="ef00.thermostats.legacy",
registrations=device_definitions,
}
