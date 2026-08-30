local function load_mapping_preset(zcl)
local emit=require "capabilities.events.all"
local data_types=require "st.zigbee.data_types"
local zigbee_constants=require "st.zigbee.constants"
local function merge_options(target,source)
if type(target)~="table" then
target={}
end
if type(source)~="table" then
return target
end
for key,value in pairs(source)do
target[key]=value
end
return target
end
local function apply_defaults(target,defaults)
if type(target)~="table" or type(defaults)~="table" then
return target
end
for key,value in pairs(defaults)do
if target[key]==nil then
target[key]=value
end
end
return target
end
local function optional_emit(name,...)
local factory=emit[name]
if type(factory)=="function" then
return factory(...)
end
return nil
end
local function normalize_preset_options(name_or_options,options)
local resolved={}
if type(name_or_options)=="string" then
resolved.name=name_or_options
else
merge_options(resolved,name_or_options)
end
merge_options(resolved,options)
return resolved
end
local function build_lookup_pair(map,default_from,default_to,aliases)
local reverse={}
for key,value in pairs(map)do
reverse[value]=key
end
if type(aliases)=="table" then
for alias,target in pairs(aliases)do
if reverse[target]~=nil then
reverse[alias]=reverse[target]
end
end
end
return{
from=function(value)
local mapped=map[value]
if mapped ~=nil then
return mapped
end
if default_from ~=nil then
return default_from
end
return value
end,
to=function(value)
local mapped=reverse[value]
if mapped ~=nil then
return mapped
end
if default_to ~=nil then
return default_to
end
return value
end,
}
end
local function clamp(value,min_value,max_value)
if value < min_value then
return min_value
end
if value > max_value then
return max_value
end
return value
end
local function level_percent_pair()
return{
from=function(value)
if type(value)~="number" then
return value
end
return math.floor((clamp(value,0,254)* 100 / 254)+ 0.5)
end,
to=function(value)
if type(value)~="number" then
return value
end
return math.floor((clamp(value,0,100)* 254 / 100)+ 0.5)
end,
}
end
local function illuminance_measurement_pair()
return{
from=function(value)
if type(value)~="number" then
return value
end
if value <=0 then
return 0
end
local lux=10 ^((value - 1)/ 10000)
return math.floor(lux + 0.5)
end,
to=function(value)
if type(value)~="number" then
return value
end
if value <=0 then
return 0
end
local raw=10000 *(math.log(value)/ math.log(10))+ 1
return math.floor(raw + 0.5)
end,
}
end
local function thermostat_mode_pair()
return build_lookup_pair({
[0]="off",
[1]="auto",
[3]="cool",
[4]="heat",
[5]="emergency heat",
})
end
local function fan_mode_pair()
return build_lookup_pair({
[0]="off",
[1]="low",
[2]="medium",
[3]="high",
[4]="on",
[5]="auto",
[6]="turbo",
})
end
local function thermostat_running_state_pair()
return{
from=function(value)
local numeric=value
if type(value)=="table" then
if type(value.is_heat_on_set)=="function" and(value:is_heat_on_set()or(type(value.is_heat_second_stage_on_set)=="function" and value:is_heat_second_stage_on_set()))then
return "heating"
end
if type(value.is_cool_on_set)=="function" and(value:is_cool_on_set()or(type(value.is_cool_second_stage_on_set)=="function" and value:is_cool_second_stage_on_set()))then
return "cooling"
end
if type(value.is_fan_on_set)=="function" and(
value:is_fan_on_set()or
(type(value.is_fan_second_stage_on_set)=="function" and value:is_fan_second_stage_on_set())or
(type(value.is_fan_third_stage_on_set)=="function" and value:is_fan_third_stage_on_set())
)then
return "fan only"
end
numeric=value.value
end
if type(numeric)~="number" then
return numeric
end
if bit32.band(numeric,0x0001)~=0 or bit32.band(numeric,0x0008)~=0 then
return "heating"
end
if bit32.band(numeric,0x0002)~=0 or bit32.band(numeric,0x0010)~=0 then
return "cooling"
end
if bit32.band(numeric,0x0004)~=0 or bit32.band(numeric,0x0020)~=0 or bit32.band(numeric,0x0040)~=0 then
return "fan only"
end
return "idle"
end,
}
end
local function zone_status_pair(mask)
return{
from=function(value)
if type(value)=="table" then
if mask==0x0001 then
if type(value.is_alarm1_set)=="function" and value:is_alarm1_set()then
return true
end
if type(value.is_alarm2_set)=="function" and value:is_alarm2_set()then
return true
end
elseif mask==0x0004 and type(value.is_tamper_set)=="function" then
return value:is_tamper_set()
elseif value.value ~=nil then
value=value.value
else
return value
end
end
if type(value)~="number" then
return value
end
return bit32.band(value,mask)~=0
end,
}
end
local function shelly_handle_position_pair()
return{
from=function(value)
local alarm1
local alarm2
if type(value)=="table" then
if type(value.is_alarm1_set)=="function" then alarm1=value:is_alarm1_set()end
if type(value.is_alarm2_set)=="function" then alarm2=value:is_alarm2_set()end
if alarm1==nil and value.value ~=nil then value=value.value end
end
if type(value)=="number" then
alarm1=bit32.band(value,0x0001)~=0
alarm2=bit32.band(value,0x0002)~=0
end
if alarm1==nil or alarm2==nil then return value end
if not alarm1 and not alarm2 then return "closed" end
if alarm1 and not alarm2 then return "tilted" end
return "open"
end,
}
end
local function extract_zone_status_from_command(zb_rx)
local zone_status=zb_rx and zb_rx.body and zb_rx.body.zcl_body and zb_rx.body.zcl_body.zone_status or nil
if zone_status==nil then
return nil
end
return{
raw_value=zone_status.value or zone_status,
typed_value=zone_status,
}
end
local function reporting_defaults(minimum_interval,maximum_interval,reportable_change)
return{
minimum_interval=minimum_interval,
maximum_interval=maximum_interval,
reportable_change=reportable_change,
read_on_configure=true,
}
end
local function merge_defaults(...)
local merged={}
for _,defaults in ipairs({...})do
apply_defaults(merged,defaults)
end
return merged
end
local function define_preset(name,factory,defaults_builder)
zcl[name]=function(name_or_options,options)
local resolved=normalize_preset_options(name_or_options,options)
apply_defaults(resolved,defaults_builder(resolved))
return factory(resolved)
end
end
define_preset("temperature",zcl.temperature_measurement,function()
return merge_defaults(
{
emit=emit.temperature("C"),
scale=100,
},
reporting_defaults(30,300,50)
)
end)
define_preset("humidity",zcl.relative_humidity,function()
return merge_defaults(
{
emit=emit.humidity(),
scale=100,
},
reporting_defaults(30,300,100)
)
end)
define_preset("battery",zcl.power_configuration_battery,function()
return merge_defaults(
{
emit=emit.battery(),
scale=2,
},
reporting_defaults(300,21600,2)
)
end)
define_preset("battery_voltage",zcl.power_configuration_battery_voltage,function()
return merge_defaults(
{
emit=emit.voltage(),
scale=10,
},
reporting_defaults(300,21600,1)
)
end)
define_preset("switch",zcl.on_off,function(options)
local configure_reporting=options.configure_reporting
options.configure_reporting=nil
if configure_reporting==false then
return{
emit=emit.switch(),
}
end
return merge_defaults(
{
emit=emit.switch(),
},
reporting_defaults(0,300,nil)
)
end)
zcl.tuya_magic_packet=function(name_or_options,options)
local resolved=normalize_preset_options(name_or_options,options)
apply_defaults(resolved,{
name="tuya_magic_packet",
read_only=true,
read_on_configure=true,
})
return zcl.cluster_attribute(0x0000,0xFFFE,resolved)
end
define_preset("level",zcl.level_control,function(options)
local configure_reporting=options.configure_reporting
options.configure_reporting=nil
local defaults={
name="brightness",
emit=emit.level(),
converter=level_percent_pair(),
}
if configure_reporting==false then return defaults end
return merge_defaults(defaults,reporting_defaults(1,3600,1))
end)
define_preset("illuminance",zcl.illuminance_measurement,function(options)
local configure_reporting=options.configure_reporting
options.configure_reporting=nil
if configure_reporting==false then
return{
emit=emit.illuminance(),
converter=illuminance_measurement_pair(),
read_on_configure=true,
}
end
return merge_defaults(
{
emit=emit.illuminance(),
converter=illuminance_measurement_pair(),
},
reporting_defaults(30,300,100)
)
end)
define_preset("pressure",zcl.pressure_measurement,function()
return merge_defaults(
{
emit=emit.atmospheric_pressure(),
scale=10,
},
reporting_defaults(30,300,1)
)
end)
zcl.occupancy=function(name_or_options,options)
local resolved=normalize_preset_options(name_or_options,options)
local ias_zone=resolved.ias_zone==true
resolved.ias_zone=nil
if ias_zone then
apply_defaults(resolved,merge_defaults(
{
name="occupancy",
emit=emit.occupancy(),
converter=zone_status_pair(0x0001),
ias_configure_method=zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
command_id=0x00,
command_extractor=extract_zone_status_from_command,
},
reporting_defaults(30,300,nil)
))
return zcl.ias_zone(resolved)
end
apply_defaults(resolved,merge_defaults(
{
emit=emit.occupancy(),
},
reporting_defaults(0,300,nil)
))
return zcl.occupancy_sensing(resolved)
end
define_preset("power",zcl.electrical_measurement_power,function()
return merge_defaults(
{
emit=emit.power(),
metering_kind="power",
poll_interval=300,
},
reporting_defaults(5,300,1)
)
end)
define_preset("current",zcl.electrical_measurement_current,function()
return merge_defaults(
{
emit=emit.current(),
scale=1000,
metering_kind="current",
poll_interval=300,
},
reporting_defaults(5,300,1)
)
end)
define_preset("voltage",zcl.electrical_measurement_voltage,function()
return merge_defaults(
{
emit=emit.voltage(),
metering_kind="voltage",
poll_interval=300,
},
reporting_defaults(5,300,1)
)
end)
define_preset("energy",zcl.simple_metering,function()
return{
emit=emit.energy(),
read_on_configure=true,
metering_kind="energy",
poll_interval=900,
}
end)
define_preset("local_temperature",zcl.thermostat_local_temperature,function()
return merge_defaults(
{
emit=emit.temperature("C"),
scale=100,
},
reporting_defaults(30,300,50)
)
end)
define_preset("heating_setpoint",zcl.thermostat_heating_setpoint,function()
return merge_defaults(
{
name="current_heating_setpoint",
emit=emit.heating_setpoint("C"),
scale=100,
},
reporting_defaults(30,300,50)
)
end)
define_preset("system_mode",zcl.thermostat_system_mode,function()
return merge_defaults(
{
emit=emit.thermostat_mode(),
converter=thermostat_mode_pair(),
},
reporting_defaults(1,300,nil)
)
end)
define_preset("cooling_setpoint",zcl.thermostat_cooling_setpoint,function()
return merge_defaults(
{
name="current_cooling_setpoint",
emit=emit.cooling_setpoint("C"),
scale=100,
},
reporting_defaults(30,300,50)
)
end)
define_preset("thermostat_operating_state",zcl.thermostat_running_state,function()
return merge_defaults(
{
name="thermostat_operating_state",
emit=emit.thermostat_operating_state(),
converter=thermostat_running_state_pair(),
},
reporting_defaults(1,300,nil)
)
end)
define_preset("local_temperature_calibration",zcl.thermostat_local_temperature_calibration,function()
return merge_defaults(
{
emit=emit.ecozyLocalTemperatureCalibration(),
scale=10,
},
reporting_defaults(1,300,1)
)
end)
define_preset("pi_heating_demand",zcl.thermostat_pi_heating_demand,function()
return merge_defaults(
{
emit=emit.ecozyPiHeatingDemand(),
read_only=true,
},
reporting_defaults(1,300,1)
)
end)
define_preset("fan_mode",zcl.fan_control_mode,function()
return merge_defaults(
{
name="fan_mode",
emit=emit.fan_mode(),
converter=fan_mode_pair(),
},
reporting_defaults(1,300,nil)
)
end)
define_preset("contact",zcl.ias_zone,function()
return merge_defaults(
{
name="contact",
emit=emit.contact(),
converter=zone_status_pair(0x0001),
ias_configure_method=zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
command_id=0x00,
command_extractor=extract_zone_status_from_command,
},
reporting_defaults(30,300,nil)
)
end)
define_preset("contact_alarm_1_or_2",zcl.ias_zone,function()
return merge_defaults(
{
name="contact",
emit=emit.contact(),
converter=zone_status_pair(0x0003),
ias_configure_method=zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
command_id=0x00,
command_extractor=extract_zone_status_from_command,
},
reporting_defaults(30,300,nil)
)
end)
define_preset("shelly_handle_position",zcl.ias_zone,function()
return merge_defaults(
{
name="shelly_handle_position",
emit=emit.shellyBluDoorHandlePosition(),
converter=shelly_handle_position_pair(),
ias_configure_method=zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
command_id=0x00,
command_extractor=extract_zone_status_from_command,
},
reporting_defaults(30,300,nil)
)
end)
define_preset("water",zcl.ias_zone,function()
return merge_defaults(
{
name="water",
emit=emit.water(),
converter=zone_status_pair(0x0001),
ias_configure_method=zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
command_id=0x00,
command_extractor=extract_zone_status_from_command,
},
reporting_defaults(0,300,nil)
)
end)
define_preset("water_alarm_1_or_2",zcl.ias_zone,function()
return merge_defaults(
{
name="water",
emit=emit.water(),
converter=zone_status_pair(0x0003),
ias_configure_method=zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
command_id=0x00,
command_extractor=extract_zone_status_from_command,
},
reporting_defaults(0,300,nil)
)
end)
define_preset("smoke",zcl.ias_zone,function()
return merge_defaults(
{
name="smoke",
emit=emit.smoke(),
converter=zone_status_pair(0x0001),
ias_configure_method=zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
command_id=0x00,
command_extractor=extract_zone_status_from_command,
},
reporting_defaults(0,180,nil)
)
end)
define_preset("smoke_alarm_1_or_2",zcl.ias_zone,function()
return merge_defaults(
{
name="smoke",
emit=emit.smoke(),
converter=zone_status_pair(0x0003),
ias_configure_method=zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
command_id=0x00,
command_extractor=extract_zone_status_from_command,
},
reporting_defaults(0,300,nil)
)
end)
define_preset("gas",zcl.ias_zone,function()
return merge_defaults(
{
name="gas",
emit=emit.gas(),
converter=zone_status_pair(0x0001),
ias_configure_method=zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
command_id=0x00,
command_extractor=extract_zone_status_from_command,
},
reporting_defaults(0,300,nil)
)
end)
define_preset("gas_alarm_2",zcl.ias_zone,function()
return merge_defaults(
{
name="gas",
emit=emit.gas(),
converter=zone_status_pair(0x0002),
ias_configure_method=zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
command_id=0x00,
command_extractor=extract_zone_status_from_command,
},
reporting_defaults(0,300,nil)
)
end)
define_preset("gas_alarm_1_or_2",zcl.ias_zone,function()
return merge_defaults(
{
name="gas",
emit=emit.gas(),
converter=zone_status_pair(0x0003),
ias_configure_method=zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
command_id=0x00,
command_extractor=extract_zone_status_from_command,
},
reporting_defaults(0,300,nil)
)
end)
define_preset("carbon_monoxide",zcl.ias_zone,function()
return merge_defaults(
{
name="carbon_monoxide",
emit=emit.carbon_monoxide(),
converter=zone_status_pair(0x0001),
ias_configure_method=zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
command_id=0x00,
command_extractor=extract_zone_status_from_command,
},
reporting_defaults(0,180,nil)
)
end)
define_preset("carbon_monoxide_alarm_1_or_2",zcl.ias_zone,function()
return merge_defaults(
{
name="carbon_monoxide",
emit=emit.carbon_monoxide(),
converter=zone_status_pair(0x0003),
ias_configure_method=zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
command_id=0x00,
command_extractor=extract_zone_status_from_command,
},
reporting_defaults(0,180,nil)
)
end)
define_preset("motion",zcl.ias_zone,function()
return merge_defaults(
{
name="motion",
emit=emit.motion(),
converter=zone_status_pair(0x0001),
ias_configure_method=zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
command_id=0x00,
command_extractor=extract_zone_status_from_command,
},
reporting_defaults(30,300,nil)
)
end)
define_preset("tamper",zcl.ias_zone,function()
return merge_defaults(
{
name="tamper",
emit=emit.tamper(),
converter=zone_status_pair(0x0004),
ias_configure_method=zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
command_id=0x00,
command_extractor=extract_zone_status_from_command,
},
reporting_defaults(0,300,nil)
)
end)
define_preset("battery_low",zcl.ias_zone,function()
return merge_defaults(
{
name="battery_low",
emit=optional_emit("battery_low"),
converter=zone_status_pair(0x0008),
ias_configure_method=zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
command_id=0x00,
command_extractor=extract_zone_status_from_command,
},
reporting_defaults(0,300,nil)
)
end)
define_preset("hardware_fault",zcl.ias_zone,function()
return merge_defaults(
{
name="hardware_fault",
emit=emit.hardware_fault(),
converter=zone_status_pair(0x0040),
ias_configure_method=zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
command_id=0x00,
command_extractor=extract_zone_status_from_command,
},
reporting_defaults(0,300,nil)
)
end)
define_preset("alarm",zcl.ias_zone,function()
return merge_defaults(
{
name="alarm",
emit=emit.alarm(),
converter=zone_status_pair(0x0001),
ias_configure_method=zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
command_id=0x00,
command_extractor=extract_zone_status_from_command,
},
reporting_defaults(0,300,nil)
)
end)
define_preset("alarm_1_or_2",zcl.ias_zone,function()
return merge_defaults(
{
name="alarm",
emit=emit.alarm(),
converter=zone_status_pair(0x0003),
ias_configure_method=zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
command_id=0x00,
command_extractor=extract_zone_status_from_command,
},
reporting_defaults(0,300,nil)
)
end)
end
return load_mapping_preset
