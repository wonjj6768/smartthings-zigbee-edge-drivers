local tuya=require "protocol.tuya"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local ef00_helpers=require "contracts.helpers.ef00"
local converter=tuya.converter
local device_definitions,register_device_definition=device_helpers.definition_registry()
local function register_sensor_definition(definition,fingerprint_list)
local entry={}
for key,value in pairs(definition)do
entry[key]=value
end
if entry.query_on_configure==nil then
entry.query_on_configure=true
end
register_device_definition(entry,fingerprint_list)
end
local alarm_lower_upper_cancel=converter.lookup_from_to({
lower_alarm=0,
upper_alarm=1,
cancel=2,
})
local th_alarm_onenuo_th05z={
profile="sensors-temp-humidity-battery-alarm-onenuo-th05z",
datapoints={
tuya.dp_temperature(1,{
emit=emit.temperature("C"),
read_only=true,
signed=true,
converter=converter.signed_number_pair(10),
}),
tuya.dp_humidity(2,{emit=emit.humidity(),scale=1,read_only=true}),
tuya.dp_battery(4,{emit=emit.battery(),read_only=true}),
tuya.dp_enum(9,{
name="temperature_unit",
emit=emit.th05zTemperatureUnit(),
converter=converter.lookup_from_to({celsius=0,fahrenheit=1}),
}),
tuya.dp_numeric(10,{
name="max_temperature_alarm",
emit=emit.th05zMaxTempAlarm(),
signed=true,
converter=converter.signed_number_pair(10),
}),
tuya.dp_numeric(11,{
name="min_temperature_alarm",
emit=emit.th05zMinTempAlarm(),
signed=true,
converter=converter.signed_number_pair(10),
}),
tuya.dp_numeric(12,{name="max_humidity_alarm",emit=emit.th05zMaxHumidityAlarm()}),
tuya.dp_numeric(13,{name="min_humidity_alarm",emit=emit.th05zMinHumidityAlarm()}),
tuya.dp_enum(14,{
name="temperature_alarm",
emit=emit.th05zTemperatureAlarm(),
read_only=true,
converter=alarm_lower_upper_cancel,
}),
tuya.dp_enum(15,{
name="humidity_alarm",
emit=emit.th05zHumidityAlarm(),
read_only=true,
converter=alarm_lower_upper_cancel,
}),
tuya.dp_numeric(17,{
name="temperature_report_interval",
emit=emit.th05zTempReportPeriod(),
}),
tuya.dp_numeric(19,{
name="temperature_sensitivity",
emit=emit.th05zTempSensitivity(),
converter=converter.divide_by_pair(10),
}),
tuya.dp_numeric(20,{
name="humidity_sensitivity",
emit=emit.th05zHumiditySensitivity(),
}),
tuya.dp_temperature_calibration(23,{emit=emit.th05zTempCalibration()}),
tuya.dp_humidity_calibration(24,{emit=emit.th05zHumidityCalibration()}),
},
query_on_configure=true,
query_on_announce=true,
respond_to_mcu_version_response=true,
time_start="1970",
}
register_device_definition(th_alarm_onenuo_th05z,ef00_helpers.ts0601_fingerprints({
"_TZE2841000000_qf5mzewi",
}))
local aq_co2_temperature_humidity_pkpfn9hc={
profile="sensors-aq-co2-temp-humidity",
query_on_configure=true,
query_on_announce=true,
tuya.dp_co2(2,{emit=emit.co2(),read_only=true}),
tuya.dp_temperature(18,{
name="temperature",
scale=10,
read_only=true,
emit=emit.temperature("C"),
}),
tuya.dp_humidity(19,{emit=emit.humidity(),scale=1,read_only=true}),
}
register_sensor_definition(aq_co2_temperature_humidity_pkpfn9hc,ef00_helpers.ts0601_fingerprints({
"_TZE204_pkpfn9hc",
}))
return{
id="ef00.sensors.z2m_absorption",
registrations=device_definitions,
}
