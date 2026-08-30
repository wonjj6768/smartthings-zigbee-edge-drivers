local tuya=require "protocol.tuya"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local ef00_helpers=require "contracts.helpers.ef00"
local thermostat_metadata=require "contracts.helpers.ef00_thermostat_metadata"
local converter=tuya.converter
local device_definitions,register_device_definition=device_helpers.definition_registry()
local function schedule_converter(day_number)
local function from_device(value)
if type(value)~="string" or #value < 25 then
return nil
end
local transitions={}
for index=0,5 do
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
local hour_text,minute_text,temperature_text=
transition:match("^(%d+):(%d+)/([%d%.%-]+)$")
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
if count ~=6 then
return nil
end
return string.char(table.unpack(payload))
end
return converter.from_to(from_device,to_device)
end
local function system_mode_from_device(value)
local numeric=tonumber(value)
if numeric==6 then
return "off"
end
if numeric ~=nil and numeric >=0 and numeric <=5 then
return "heat"
end
return nil
end
local function system_mode_to_device(value)
return({heat=0,off=6})[value]
end
local function preset_from_device(value)
return({
[0]="none",
[1]="schedule",
[2]="eco",
[3]="comfort",
[4]="frost_protection",
[5]="holiday",
[6]="none",
})[tonumber(value)]
end
local function preset_to_device(value)
return({
none=0,
schedule=1,
eco=2,
comfort=3,
frost_protection=4,
holiday=5,
})[value]
end
local mazda={
profile="thermostats-wave9-mazda-tr-m2z",
package_group="trv-2",
transport_classification="EF00_DP",
z2m_converter_source="meta.tuyaDatapoints",
wire_cluster="manuSpecificTuya",
query_on_configure=false,
time_start="2000",
tuya.dp_system_mode(2,{
name="system_mode",
converter=converter.from_to(system_mode_from_device,system_mode_to_device),
emit=emit.thermostat_mode(),
}),
tuya.dp_enum(2,{
name="mazda_mtwo_preset",
converter=converter.from_to(preset_from_device,preset_to_device),
emit=emit.mazdaMtwoPreset(),
}),
tuya.dp_numeric(3,{
name="running_state",
read_only=true,
converter=converter.lookup_from_to({heating=1,idle=0}),
emit=emit.thermostat_operating_state(),
}),
tuya.dp_current_heating_setpoint(4,{scale=10,emit=emit.heating_setpoint("C")}),
tuya.dp_local_temperature(5,{scale=10,read_only=true,emit=emit.temperature("C")}),
tuya.dp_battery(6,{read_only=true,emit=emit.battery()}),
tuya.dp_child_lock(7,{
name="mazda_mtwo_child_lock",
converter=converter.lookup_from_to({LOCK=true,UNLOCK=false}),
emit=emit.mazdaMtwoChildLock(),
}),
tuya.dp_binary(14,{
name="mazda_mtwo_window_detection",
converter=converter.lookup_from_to({ON=true,OFF=false}),
emit=emit.mazdaMtwoWindowDetection(),
}),
tuya.dp_enum(15,{
name="mazda_mtwo_window_open",
read_only=true,
converter=converter.from_only(function(value)
return tonumber(value)==0 and "open" or "closed"
end),
emit=emit.mazdaMtwoWindowOpen(),
}),
tuya.dp_holiday_temperature(21,{
name="mazda_mtwo_holiday_temperature",
scale=10,
emit=emit.mazdaMtwoHolidayTemperature(),
}),
tuya.dp_raw(28,{name="mazda_mtwo_schedule_monday",converter=schedule_converter(1),emit=emit.mazdaMtwoScheduleMonday()}),
tuya.dp_raw(29,{name="mazda_mtwo_schedule_tuesday",converter=schedule_converter(2),emit=emit.mazdaMtwoScheduleTuesday()}),
tuya.dp_raw(30,{name="mazda_mtwo_schedule_wednesday",converter=schedule_converter(3),emit=emit.mazdaMtwoScheduleWednesday()}),
tuya.dp_raw(31,{name="mazda_mtwo_schedule_thursday",converter=schedule_converter(4),emit=emit.mazdaMtwoScheduleThursday()}),
tuya.dp_raw(32,{name="mazda_mtwo_schedule_friday",converter=schedule_converter(5),emit=emit.mazdaMtwoScheduleFriday()}),
tuya.dp_raw(33,{name="mazda_mtwo_schedule_saturday",converter=schedule_converter(6),emit=emit.mazdaMtwoScheduleSaturday()}),
tuya.dp_raw(34,{name="mazda_mtwo_schedule_sunday",converter=schedule_converter(7),emit=emit.mazdaMtwoScheduleSunday()}),
tuya.dp_binary(35,{
name="mazda_mtwo_alarm_switch",
read_only=true,
converter=converter.lookup_from_to({ON=true,OFF=false}),
emit=emit.mazdaMtwoAlarmSwitch(),
}),
tuya.dp_binary(36,{
name="mazda_mtwo_frost_protection",
converter=converter.lookup_from_to({ON=true,OFF=false}),
emit=emit.mazdaMtwoFrostProtection(),
}),
tuya.dp_local_temperature_calibration(47,{
name="mazda_mtwo_temp_calibration",
scale=10,
emit=emit.mazdaMtwoTempCalibration(),
}),
tuya.dp_numeric(102,{
name="mazda_mtwo_temperature_sensitivity",
converter=converter.divide_by_pair(10),
emit=emit.mazdaMtwoTemperatureSensitivity(),
}),
tuya.dp_eco_temperature(103,{
name="mazda_mtwo_eco_temperature",
scale=10,
emit=emit.mazdaMtwoEcoTemperature(),
}),
tuya.dp_comfort_temperature(104,{
name="mazda_mtwo_comfort_temperature",
scale=10,
emit=emit.mazdaMtwoComfortTemperature(),
}),
}
thermostat_metadata.attach(mazda,{"off","heat"},5,35,0.5)
register_device_definition(mazda,ef00_helpers.ts0601_fingerprints({
"_TZE284_k6rdmisz",
"_TZE204_k6rdmisz",
}))
return{
id="ef00.thermostats.wave9_mazda",
registrations=device_definitions,
}
