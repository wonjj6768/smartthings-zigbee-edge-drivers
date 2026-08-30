local tuya=require "protocol.tuya"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local ef00_helpers=require "contracts.helpers.ef00"
local thermostat_metadata=require "contracts.helpers.ef00_thermostat_metadata"
local converter=tuya.converter
local device_definitions,register_device_definition=device_helpers.definition_registry()
local function schedule_converter(day_number,transition_count)
local function from_device(value)
if type(value)~="string" or #value < 1 + transition_count * 4 then
return nil
end
local transitions={}
for index=0,transition_count - 1 do
local offset=2 + index * 4
local hour,minute,high,low=string.byte(value,offset,offset + 3)
if hour==nil or minute==nil or high==nil or low==nil then
return nil
end
transitions[#transitions + 1]=string.format(
"%02d:%02d/%.1f",
hour,
minute,
((high * 256)+ low)/ 10
)
end
return table.concat(transitions," ")
end
local function to_device(value)
if type(value)~="string" then
return nil
end
local payload={day_number}
local count=0
for transition in string.gmatch(value,"%S+")do
local hour_text,minute_text,temperature_text=transition:match("^(%d+):(%d+)/([%d%.%-]+)$")
local hour=tonumber(hour_text)
local minute=tonumber(minute_text)
local temperature=tonumber(temperature_text)
if hour==nil or minute==nil or temperature==nil
or hour < 0 or hour > 24 or minute < 0 or minute > 60
or temperature < 5 or temperature > 35 then
return nil
end
local encoded_temperature=math.floor(temperature * 10)
payload[#payload + 1]=math.floor(hour)
payload[#payload + 1]=math.floor(minute)
payload[#payload + 1]=math.floor(encoded_temperature / 256)% 256
payload[#payload + 1]=encoded_temperature % 256
count=count + 1
end
if count ~=transition_count then
return nil
end
return string.char(table.unpack(payload))
end
return converter.from_to(from_device,to_device)
end
local function me168_preset_from(value)
return({
[0]="none",
[1]="none",
[2]="none",
[3]="eco",
[4]="comfort",
[5]="boost",
})[tonumber(value)]
end
local function me168_preset_to(value)
return({none=1,eco=3,comfort=4,boost=5})[value]
end
local me168={
profile="thermostats-wave6a-avatto-me168",
package_group="trv-2",
query_on_configure=false,
time_start="2000",
tuya.dp_system_mode(2,{
name="system_mode",
converter=converter.lookup_from_to({auto=0,heat=1,off=2}),
emit=emit.thermostat_mode(),
}),
tuya.dp_enum(2,{
name="me168_preset",
converter=converter.from_to(me168_preset_from,me168_preset_to),
emit=emit.meOneSixEightPreset(),
}),
tuya.dp_enum(2,{
name="me168_running_mode",
read_only=true,
converter=converter.from_only(converter.lookup_value({
[0]="auto",
[1]="manual",
[2]="off",
[3]="eco",
[4]="comfort",
[5]="boost",
})),
emit=emit.meOneSixEightRunningMode(),
}),
tuya.dp_running_state(3,{
name="running_state",
read_only=true,
converter=converter.lookup_from_to({heating=0,idle=1}),
emit=emit.thermostat_operating_state(),
}),
tuya.dp_current_heating_setpoint(4,{
name="current_heating_setpoint",
scale=10,
emit=emit.heating_setpoint("C"),
}),
tuya.dp_local_temperature(5,{
name="local_temperature",
scale=10,
read_only=true,
emit=emit.temperature("C"),
}),
tuya.dp_battery(6,{name="battery",read_only=true,emit=emit.battery()}),
tuya.dp_child_lock(7,{
name="me168_child_lock",
converter=converter.lookup_from_to({LOCK=true,UNLOCK=false}),
emit=emit.meOneSixEightChildLock(),
}),
tuya.dp_binary(14,{
name="me168_window_detection",
converter=converter.lookup_from_to({ON=true,OFF=false}),
emit=emit.meOneSixEightWindowDetection(),
}),
tuya.dp_enum(15,{
name="me168_window_open",
read_only=true,
converter=converter.from_only(function(value)
return tonumber(value)==0 and "open" or "closed"
end),
emit=emit.meOneSixEightWindowOpen(),
}),
tuya.dp_raw(28,{name="me168_schedule_monday",converter=schedule_converter(1,6),emit=emit.meOneSixEightScheduleMonday()}),
tuya.dp_raw(29,{name="me168_schedule_tuesday",converter=schedule_converter(2,6),emit=emit.meOneSixEightScheduleTuesday()}),
tuya.dp_raw(30,{name="me168_schedule_wednesday",converter=schedule_converter(3,6),emit=emit.meOneSixEightScheduleWednesday()}),
tuya.dp_raw(31,{name="me168_schedule_thursday",converter=schedule_converter(4,6),emit=emit.meOneSixEightScheduleThursday()}),
tuya.dp_raw(32,{name="me168_schedule_friday",converter=schedule_converter(5,6),emit=emit.meOneSixEightScheduleFriday()}),
tuya.dp_raw(33,{name="me168_schedule_saturday",converter=schedule_converter(6,6),emit=emit.meOneSixEightScheduleSaturday()}),
tuya.dp_raw(34,{name="me168_schedule_sunday",converter=schedule_converter(7,6),emit=emit.meOneSixEightScheduleSunday()}),
tuya.dp_bitmap(35,{
name="me168_error",
read_only=true,
converter=converter.from_only(function(value)return tonumber(value)end),
emit=emit.meOneSixEightError(),
}),
tuya.dp_binary(36,{
name="me168_frost_protection",
converter=converter.lookup_from_to({ON=true,OFF=false}),
emit=emit.meOneSixEightFrostProtection(),
}),
tuya.dp_binary(39,{
name="me168_scale_protection",
converter=converter.lookup_from_to({ON=true,OFF=false}),
emit=emit.meOneSixEightScaleProtection(),
}),
tuya.dp_local_temperature_calibration(47,{
name="me168_temp_calibration",
scale=1,
emit=emit.meOneSixEightTempCalibration(),
}),
tuya.dp_comfort_temperature(101,{
name="me168_comfort_temperature",
scale=10,
emit=emit.meOneSixEightComfortTemperature(),
}),
tuya.dp_numeric(103,{name="me168_boost_time",emit=emit.meOneSixEightBoostTime()}),
tuya.dp_numeric(104,{
name="me168_boost_countdown",
read_only=true,
emit=emit.meOneSixEightBoostCountdown(),
}),
tuya.dp_eco_temperature(105,{
name="me168_eco_temperature",
scale=10,
emit=emit.meOneSixEightEcoTemperature(),
}),
}
thermostat_metadata.attach(me168,{"off","heat","auto"},4,35,1)
register_device_definition(me168,ef00_helpers.ts0601_fingerprints({
"_TZE200_ybsqljjg",
"_TZE200_cxakecfo",
"_TZE200_4aijvczq",
"_TZE200_r5ksy7qo",
}))
local trv26={
profile="thermostats-wave6a-avatto-trv26",
package_group="trv-2",
query_on_configure=false,
time_start="2000",
force_time_updates=true,
respond_to_mcu_version_response=true,
tuya.dp_enum(2,{
name="trv26_preset",
converter=converter.lookup_from_to({
manual=0,
auto=1,
eco=2,
comfort=3,
antifrost=4,
holiday=5,
}),
emit=emit.trvTwoSixPreset(),
}),
tuya.dp_running_state(3,{
name="running_state",
read_only=true,
converter=converter.lookup_from_to({idle=1,heating=0}),
emit=emit.thermostat_operating_state(),
}),
tuya.dp_current_heating_setpoint(4,{scale=10,emit=emit.heating_setpoint("C")}),
tuya.dp_local_temperature(5,{scale=10,read_only=true,emit=emit.temperature("C")}),
tuya.dp_battery(6,{read_only=true,emit=emit.battery()}),
tuya.dp_child_lock(7,{
name="trv26_child_lock",
converter=converter.lookup_from_to({LOCK=true,UNLOCK=false}),
emit=emit.trvTwoSixChildLock(),
}),
tuya.dp_max_temperature_limit(9,{
name="trv26_max_temp_limit",
scale=10,
emit=emit.trvTwoSixMaxTempLimit(),
}),
tuya.dp_min_temperature_limit(10,{
name="trv26_min_temp_limit",
scale=10,
emit=emit.trvTwoSixMinTempLimit(),
}),
tuya.dp_binary(14,{
name="trv26_window_detection",
converter=converter.lookup_from_to({on=true,off=false}),
emit=emit.trvTwoSixWindowDetection(),
}),
tuya.dp_open_window_temperature(16,{
name="trv26_open_window_temp",
scale=10,
emit=emit.trvTwoSixOpenWindowTemp(),
}),
tuya.dp_raw(18,{
name="trv26_schedule_tuesday",
converter=schedule_converter(2,4),
emit=emit.trvTwoSixScheduleTuesday(),
}),
tuya.dp_binary(19,{
name="trv26_factory_reset",
converter=converter.lookup_from_to({ON=true,OFF=false}),
emit=emit.trvTwoSixFactoryReset(),
}),
tuya.dp_raw(20,{
name="trv26_schedule_thursday",
converter=schedule_converter(4,4),
emit=emit.trvTwoSixScheduleThursday(),
}),
tuya.dp_holiday_temperature(21,{
name="trv26_holiday_temperature",
scale=1,
emit=emit.trvTwoSixHolidayTemperature(),
}),
tuya.dp_raw(22,{
name="trv26_schedule_saturday",
converter=schedule_converter(6,4),
emit=emit.trvTwoSixScheduleSaturday(),
}),
tuya.dp_raw(23,{
name="trv26_schedule_sunday",
converter=schedule_converter(7,4),
emit=emit.trvTwoSixScheduleSunday(),
}),
tuya.dp_comfort_temperature(24,{
name="trv26_comfort_temperature",
scale=10,
emit=emit.trvTwoSixComfortTemperature(),
}),
tuya.dp_eco_temperature(25,{
name="trv26_eco_temperature",
scale=10,
emit=emit.trvTwoSixEcoTemperature(),
}),
tuya.dp_numeric(35,{
name="trv26_error_status",
read_only=true,
emit=emit.trvTwoSixErrorStatus(),
}),
tuya.dp_binary(36,{
name="trv26_frost_protection",
converter=converter.lookup_from_to({on=true,off=false}),
emit=emit.trvTwoSixFrostProtection(),
}),
tuya.dp_local_temperature_calibration(47,{
name="trv26_temp_calibration",
scale=10,
emit=emit.trvTwoSixTempCalibration(),
}),
tuya.dp_system_mode(49,{
name="system_mode",
converter=converter.lookup_from_to({off=0,heat=1}),
emit=emit.thermostat_mode(),
}),
tuya.dp_numeric(101,{
name="trv26_uptime",
converter=converter.divide_by_pair(10),
read_only=true,
emit=emit.trvTwoSixUptime(),
}),
tuya.dp_numeric(102,{
name="trv26_descale_countdown",
converter=converter.divide_by_pair(10),
read_only=true,
emit=emit.trvTwoSixDescaleCountdown(),
}),
}
thermostat_metadata.attach(trv26,{"off","heat"},5,35,0.5)
register_device_definition(trv26,ef00_helpers.ts0601_fingerprints({
"_TZE204_xdtnpp1a",
"_TZE284_xdtnpp1a",
}))
local nedis={
profile="thermostats-wave6a-nedis-zbhtr20wt",
package_group="trv-2",
query_on_configure=false,
time_start="1970",
tuya.dp_running_state(3,{
name="running_state",
read_only=true,
converter=converter.lookup_from_to({heating=1,idle=0}),
emit=emit.thermostat_operating_state(),
}),
tuya.dp_binary(8,{
name="nedis_open_window",
converter=converter.lookup_from_to({ON=true,OFF=false}),
emit=emit.nedisHtrOpenWindow(),
}),
tuya.dp_binary(10,{
name="nedis_frost_protection",
converter=converter.lookup_from_to({ON=true,OFF=false}),
emit=emit.nedisHtrFrostProtection(),
}),
tuya.dp_local_temperature_calibration(27,{
name="nedis_temp_calibration",
scale=1,
emit=emit.nedisHtrTempCalibration(),
}),
tuya.dp_child_lock(40,{
name="nedis_child_lock",
converter=converter.lookup_from_to({LOCK=true,UNLOCK=false}),
emit=emit.nedisHtrChildLock(),
}),
tuya.dp_system_mode(101,{
name="system_mode",
converter=converter.lookup_from_to({heat=true,off=false}),
emit=emit.thermostat_mode(),
}),
tuya.dp_local_temperature(102,{scale=10,read_only=true,emit=emit.temperature("C")}),
tuya.dp_current_heating_setpoint(103,{scale=10,emit=emit.heating_setpoint("C")}),
tuya.dp_binary(106,{
name="nedis_leave_home",
converter=converter.lookup_from_to({ON=true,OFF=false}),
emit=emit.nedisHtrLeaveHome(),
}),
tuya.dp_binary(108,{
name="nedis_schedule_mode",
converter=converter.lookup_from_to({ON=true,OFF=false}),
emit=emit.nedisHtrScheduleMode(),
}),
}
thermostat_metadata.attach(nedis,{"off","heat"},5,30,0.5)
register_device_definition(nedis,ef00_helpers.ts0601_fingerprints({
"_TZE200_ne4pikwm",
"_TZE284_ne4pikwm",
"_TZE284_hcs66axl",
}))
return{
id="ef00.thermostats.wave6a_trv",
registrations=device_definitions,
}
