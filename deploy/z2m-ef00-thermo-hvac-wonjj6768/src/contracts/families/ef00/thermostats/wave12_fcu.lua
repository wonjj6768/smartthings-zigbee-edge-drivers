local tuya=require "protocol.tuya"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local ef00_helpers=require "contracts.helpers.ef00"
local thermostat_metadata=require "contracts.helpers.ef00_thermostat_metadata"
local wave12=require "contracts.helpers.ef00_thermostat_wave12"
local converter=tuya.converter
local device_definitions,register_device_definition=device_helpers.definition_registry()
local BAC_POWER_FIELD="__wave12_bac_power"
local BAC_MODE_FIELD="__wave12_bac_mode"
local function bac_power_from_device(value,device)
local enabled=value==true or value==1
device:set_field(BAC_POWER_FIELD,enabled,{persist=false})
if not enabled then return "off" end
return device:get_field(BAC_MODE_FIELD)or "cool"
end
local function bac_mode_from_device(value,device)
local mode=({[0]="cool",[1]="heat",[2]="fan_only"})[tonumber(value)]or "cool"
device:set_field(BAC_MODE_FIELD,mode,{persist=false})
if device:get_field(BAC_POWER_FIELD)==false then return "off" end
return mode
end
local function bac_mode_write(_,value)
if value=="off" then
return{{dp=1,datatype=tuya.DP_TYPE_BOOL,value=false}}
end
local raw=({cool=0,heat=1,fan_only=2})[value]
if raw==nil then return nil end
return{
{dp=1,datatype=tuya.DP_TYPE_BOOL,value=true},
{dp=2,datatype=tuya.DP_TYPE_ENUM,value=raw},
}
end
local bac_calibration=converter.from_to(
function(value)
local numeric=tonumber(value)
if numeric==nil then return nil end
return numeric > 0x7fffffff and numeric - 0x100000000 or numeric
end,
function(value)
local numeric=tonumber(value)
if numeric==nil then return nil end
return numeric < 0 and 0x100000000 + numeric or numeric
end
)
local bac={
profile="thermostats-wave12-tuya-bac001",
package_group="fcu",
query_on_configure=false,
time_start="1970",
force_time_updates=true,
tuya.dp_binary(1,{name="system_mode",from_device=bac_power_from_device,read_only=true,emit=emit.thermostat_mode()}),
tuya.dp_enum(2,{name="system_mode",from_device=bac_mode_from_device,read_only=true,emit=emit.thermostat_mode()}),
tuya.dp_current_heating_setpoint(16,{scale=10,emit=emit.heating_setpoint("C")}),
tuya.dp_local_temperature(24,{scale=10,read_only=true,emit=emit.temperature("C")}),
wave12.numeric(27,"tuya_bac_temp_calibration","tuyaBacTempCalibration",1,false,{converter=bac_calibration}),
tuya.dp_enum(28,{
name="fan_mode",
converter=converter.lookup_from_to({low=0,medium=1,high=2,auto=3}),
emit=emit.fan_mode(),
}),
}
wave12.override_named_writer(bac,"system_mode",bac_mode_write)
thermostat_metadata.attach(bac,{"off","cool","heat","fan_only"},5,35,0.5)
register_device_definition(bac,ef00_helpers.ts0601_fingerprints({"_TZE204_hpkusvom"}))
return{
id="ef00.thermostats.wave12_fcu",
registrations=device_definitions,
}
