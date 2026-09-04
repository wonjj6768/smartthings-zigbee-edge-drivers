local tuya=require "protocol.tuya"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local thermostat_common=require "contracts.helpers.ef00_thermostats"
local converter=tuya.converter
local registrations,register_device_definition=device_helpers.definition_registry()
local nul=string.char(0x00)
local alecto_on_off=converter.lookup_from_to({off=false,on=true})
local alecto_smart_heat10={
profile="thermostats-alecto-smart-heat10",
package_group="trv-1",
tuya.dp_current_heating_setpoint(2,{scale=10}),
tuya.dp_local_temperature(3,{scale=10}),
tuya.dp_system_mode(4,{
converter=converter.lookup_from_to({off=0,auto=1,heat=2}),
}),
tuya.dp_binary(7,{
name="alecto_child_lock",
emit=emit.alectoSmartHeat10ChildLock(),
converter=alecto_on_off,
}),
tuya.dp_binary(18,{
name="alecto_window_detection",
emit=emit.alectoSmartHeat10WindowDetection(),
converter=alecto_on_off,
}),
tuya.dp_battery(21,{emit=emit.battery()}),
}
register_device_definition(alecto_smart_heat10,{
device_helpers.create_fingerprint("_TYST11_8daqwrsj","daqwrsj" .. nul),
})
local saswell_legacy={
profile="thermostats-thermostat-saswell",
bind_basic_on_configure=true,
named_mapping={
named_mappings={
system_mode=thermostat_common.binary_power_schedule_mode_write(101,108),
},
},
tuya.dp_running_state(3,{
converter=converter.lookup_from_to({heat=1,idle=0}),
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
converter=converter.from_only(
thermostat_common.boolean_label_from_device("normal","low")
),
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
converter=converter.lookup_from_to({heat=true,off=false}),
}),
tuya.dp_binary(108,{
name="saswell_schedule_enable",
from_device=thermostat_common.true_mode_from_device("auto"),
emit=emit.thermostat_mode(),
}),
}
register_device_definition(saswell_legacy,{
device_helpers.create_fingerprint("_TYST11_KGbxAXL2","GbxAXL2" .. nul),
device_helpers.create_fingerprint("_TYST11_c88teujp","88teujp" .. nul),
device_helpers.create_fingerprint("_TYST11_caj4jz0i","aj4jz0i" .. nul),
device_helpers.create_fingerprint("_TYST11_yw7cahqs","w7cahqs" .. nul),
device_helpers.create_fingerprint("_TYST11_zuhszj9s","uhszj9s" .. nul),
})
local etop_power_field="etop_power_state"
local etop_mode_field="etop_system_mode_device"
local thermostat_etop_legacy={
profile="thermostats-thermostat-etop",
named_mapping={
named_mappings={
system_mode=thermostat_common.power_mode_write(1,4,{
heat=0,
auto=2,
}),
},
},
tuya.dp_binary(1,{
name="system_mode",
from_device=thermostat_common.power_mode_from_device(
etop_power_field,etop_mode_field,"heat"
),
emit=emit.thermostat_mode(),
}),
tuya.dp_current_heating_setpoint(2,{scale=10}),
tuya.dp_local_temperature(3,{scale=10}),
tuya.dp_enum(4,{
name="system_mode",
from_device=thermostat_common.enum_mode_from_device(
etop_power_field,etop_mode_field,{
[0]="heat",
[1]="heat",
[2]="auto",
}
),
emit=emit.thermostat_mode(),
read_only=true,
}),
tuya.dp_child_lock(7,{name="child_lock",emit=emit.etopChildLock()}),
tuya.dp_numeric(13,{
name="error_status",
read_only=true,
converter=converter.bitmap_flags({
[1]="high_temperature",
[2]="low_temperature",
[4]="internal_sensor_error",
[8]="external_sensor_error",
[16]="battery_low",
[32]="device_offline",
},"none"),
emit=emit.etopErrorStatus(),
}),
tuya.dp_running_state(14,{
converter=converter.lookup_from_to({heating=true,idle=false}),
emit=emit.thermostat_operating_state(),
}),
}
register_device_definition(thermostat_etop_legacy,{
device_helpers.create_fingerprint("_TYST11_wv90ladg","v90ladg" .. nul),
})
register_device_definition(thermostat_etop_legacy,{
device_helpers.create_fingerprint("_TYST11_2dpplnsn","dpplnsn" .. nul),
})
return{
id="ef00.thermostats.wave19_exact_aliases",
registrations=registrations,
}
