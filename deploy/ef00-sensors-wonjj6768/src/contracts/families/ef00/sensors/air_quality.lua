local tuya=require "protocol.tuya"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local ef00_helpers=require "contracts.helpers.ef00"
local converter=tuya.converter
local device_definitions,register_device_definition=device_helpers.definition_registry()
local function register_sensor_definition(definitions_or_table,fingerprint_list)
if type(definitions_or_table)=="table" then
local entry={}
for key,value in pairs(definitions_or_table)do
entry[key]=value
end
if entry.query_on_configure==nil then
entry.query_on_configure=true
end
register_device_definition(entry,fingerprint_list)
return
end
register_device_definition({
datapoints=definitions_or_table,
query_on_configure=true,
},fingerprint_list)
end
local AQ_HCHO_UGM3_TO_MGM3=1000
local AQ_HCHO_DIV100_UGM3_TO_MGM3=100000
local function air_house_keeper_pm25()
return converter.from_only(function(value)
local numeric=tonumber(value)
if numeric==nil then
return nil
end
if numeric > 1000 then
return nil
end
return numeric
end)
end
local aq={
profile="sensors-aq-co2-temp-humidity-voc-formaldehyde",
tuya.dp_co2(2,{emit=emit.co2()}),
tuya.dp_numeric(18,{name="temperature",emit=emit.temperature("C"),converter=converter.tuya_unsigned_temp(10)}),
tuya.dp_humidity(19,{emit=emit.humidity(),scale=10}),
tuya.dp_voc(21,{emit=emit.voc()}),
tuya.dp_formaldehyde(22,{emit=emit.formaldehyde(),scale=AQ_HCHO_UGM3_TO_MGM3}),
}
register_sensor_definition(aq,ef00_helpers.ts0601_fingerprints({
"_TZE200_8ygsuhe1",
"_TZE200_yvx5lh6k",
"_TZE200_c2fmom5z",
"_TZE204_c2fmom5z",
"_TZE204_yvx5lh6k",
}))
local aq_h1_v100_f100={
profile="sensors-aq-co2-temp-humidity-voc-formaldehyde",
tuya.dp_co2(2,{emit=emit.co2()}),
tuya.dp_numeric(18,{
name="temperature",
emit=emit.temperature("C"),
converter=converter.divide_by_pair(10),
}),
tuya.dp_humidity(19,{emit=emit.humidity(),scale=1}),
tuya.dp_voc(21,{emit=emit.voc(),scale=100}),
tuya.dp_formaldehyde(22,{emit=emit.formaldehyde(),scale=AQ_HCHO_DIV100_UGM3_TO_MGM3}),
}
register_sensor_definition(aq_h1_v100_f100,ef00_helpers.ts0601_fingerprints({
"_TZE284_8b9zpaav",
}))
local aq_v100_f100={
profile="sensors-aq-co2-temp-humidity-voc-formaldehyde",
tuya.dp_co2(2,{emit=emit.co2()}),
tuya.dp_numeric(18,{
name="temperature",
emit=emit.temperature("C"),
converter=converter.divide_by_pair(10),
}),
tuya.dp_humidity(19,{emit=emit.humidity(),scale=10}),
tuya.dp_co2(20,{name="co2_duplicate",emit=emit.co2()}),
tuya.dp_voc(21,{emit=emit.voc(),scale=100}),
tuya.dp_formaldehyde(22,{emit=emit.formaldehyde(),scale=AQ_HCHO_DIV100_UGM3_TO_MGM3}),
}
register_sensor_definition(aq_v100_f100,ef00_helpers.ts0601_fingerprints({
"_TZE284_it9utkro",
}))
local aq_pm25={
profile="sensors-aq-pm25-co2-temp-humidity-voc-formaldehyde",
tuya.dp_pm25(2,{emit=emit.pm25(),converter=air_house_keeper_pm25()}),
tuya.dp_numeric(18,{name="temperature",emit=emit.temperature("C"),converter=converter.tuya_unsigned_temp(10)}),
tuya.dp_humidity(19,{emit=emit.humidity(),scale=10}),
tuya.dp_formaldehyde(20,{emit=emit.formaldehyde(),scale=AQ_HCHO_UGM3_TO_MGM3}),
tuya.dp_voc(21,{emit=emit.voc()}),
tuya.dp_co2(22,{emit=emit.co2()}),
}
register_sensor_definition(aq_pm25,ef00_helpers.ts0601_fingerprints({
"_TZE200_dwcarsat",
"_TZE204_dwcarsat",
}))
local aq_pm25_unfiltered={
profile="sensors-aq-pm25-co2-temp-humidity-voc-formaldehyde",
tuya.dp_pm25(2,{emit=emit.pm25()}),
tuya.dp_numeric(18,{
name="temperature",
emit=emit.temperature("C"),
converter=converter.tuya_unsigned_temp(10),
}),
tuya.dp_humidity(19,{emit=emit.humidity(),scale=10}),
tuya.dp_formaldehyde(20,{emit=emit.formaldehyde(),scale=AQ_HCHO_UGM3_TO_MGM3}),
tuya.dp_voc(21,{emit=emit.voc()}),
tuya.dp_co2(22,{emit=emit.co2()}),
}
register_sensor_definition(aq_pm25_unfiltered,ef00_helpers.ts0601_fingerprints({
"_TZE200_blfcpsxz",
}))
local aq_hcho={
profile="sensors-aq-co2-temp-humidity-voc-formaldehyde",
tuya.dp_formaldehyde(2,{emit=emit.formaldehyde(),scale=AQ_HCHO_UGM3_TO_MGM3}),
tuya.dp_numeric(18,{name="temperature",emit=emit.temperature("C"),converter=converter.tuya_unsigned_temp(10)}),
tuya.dp_humidity(19,{emit=emit.humidity(),scale=10}),
tuya.dp_voc(21,{emit=emit.voc()}),
tuya.dp_co2(22,{emit=emit.co2()}),
}
register_sensor_definition(aq_hcho,ef00_helpers.ts0601_fingerprints({
"_TZE200_mja3fuja",
}))
local aq_hcho_f100_v10={
profile="sensors-aq-co2-temp-humidity-voc-formaldehyde",
tuya.dp_formaldehyde(2,{emit=emit.formaldehyde(),scale=AQ_HCHO_DIV100_UGM3_TO_MGM3}),
tuya.dp_numeric(18,{name="temperature",emit=emit.temperature("C"),converter=converter.tuya_unsigned_temp(10)}),
tuya.dp_humidity(19,{emit=emit.humidity(),scale=10}),
tuya.dp_voc(21,{emit=emit.voc(),scale=10}),
tuya.dp_co2(22,{emit=emit.co2()}),
}
register_sensor_definition(aq_hcho_f100_v10,ef00_helpers.ts0601_fingerprints({
"_TZE200_ryfmq5rl",
}))
local aq_co2={
profile="sensors-aq-co2-temp-humidity",
tuya.dp_co2(2,{emit=emit.co2()}),
tuya.dp_numeric(18,{name="temperature",emit=emit.temperature("C"),converter=converter.tuya_unsigned_temp(10)}),
tuya.dp_humidity(19,{emit=emit.humidity(),scale=10}),
}
register_sensor_definition(aq_co2,ef00_helpers.ts0601_fingerprints({
"_TZE200_ogkdpgy2",
"_TZE200_3ejwxpmu",
"_TZE204_3ejwxpmu",
}))
local aq_co2_only={
profile="sensors-aq-co2",
tuya.dp_co2(2,{emit=emit.co2()}),
}
register_sensor_definition(aq_co2_only,ef00_helpers.ts0601_fingerprints({
"_TZE204_ogkdpgy2",
}))
local aq_zr360_co2={
profile="sensors-aq-zr360cdb-co2-temp-humidity",
query_on_configure=false,
tuya.dp_enum(1,{
name="air_quality",
read_only=true,
emit=emit.zr360cdbAirQuality(),
converter=converter.from_only(converter.lookup_value({
[0]="excellent",
[1]="moderate",
[2]="poor",
})),
}),
tuya.dp_co2(2,{emit=emit.co2(),read_only=true}),
tuya.dp_enum(5,{
name="alarm_ringtone",
emit=emit.zr360cdbAlarmRingtone(),
converter=converter.lookup_from_to({
melody_1=0,
melody_2=1,
OFF=2,
}),
}),
tuya.dp_numeric(14,{
name="battery_state",
read_only=true,
emit=emit.zr360cdbBatteryState(),
converter=converter.from_only(converter.lookup_value({
[0]="low",
[1]="medium",
[2]="high",
})),
}),
tuya.dp_numeric(17,{
name="backlight_mode",
emit=emit.zr360cdbBacklightMode(),
}),
tuya.dp_numeric(18,{
name="temperature",
read_only=true,
emit=emit.temperature("C"),
converter=converter.signed_number_pair(1),
}),
tuya.dp_humidity(19,{emit=emit.humidity(),scale=1,read_only=true}),
}
register_sensor_definition(aq_zr360_co2,ef00_helpers.ts0601_fingerprints({
"_TZE200_pl31aqf5",
"_TZE200_xpvamyfz",
"_TZE284_xpvamyfz",
}))
return{
id="ef00.sensors.air_quality",
registrations=device_definitions,
}
