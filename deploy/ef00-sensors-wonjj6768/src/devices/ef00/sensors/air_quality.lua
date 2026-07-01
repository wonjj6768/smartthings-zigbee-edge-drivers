local tuya = require "tuya_common"
local emit = require "emitters"
local device_helpers = require "devices.shared.helpers"
local ef00_helpers = require "devices.ef00.helpers"
local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()
local function register_sensor_definition(definitions_or_table, fingerprint_list)
if type(definitions_or_table) == "table" then
local entry = {}
for key, value in pairs(definitions_or_table) do
entry[key] = value
end
if entry.query_on_configure == nil then
entry.query_on_configure = true
end
register_device_definition(entry, fingerprint_list)
return
end
register_device_definition({
datapoints = definitions_or_table,
query_on_configure = true,
}, fingerprint_list)
end
local AQ_HCHO_UGM3_TO_MGM3 = 1000
local AQ_HCHO_DIV100_UGM3_TO_MGM3 = 100000
local function air_house_keeper_pm25()
return converter.from_only(function(value)
local numeric = tonumber(value)
if numeric == nil then
return nil
end
if numeric > 1000 then
return nil
end
return numeric
end)
end
local aq = {
tuya.dp_co2(2, { emit = emit.co2() }),
tuya.dp_numeric(18, { name = "temperature", emit = emit.temperature("C"), converter = converter.tuya_unsigned_temp(10) }),
tuya.dp_humidity(19, { emit = emit.humidity(), scale = 10 }),
tuya.dp_voc(21, { emit = emit.voc() }),
tuya.dp_formaldehyde(22, { emit = emit.formaldehyde(), scale = AQ_HCHO_UGM3_TO_MGM3 }),
}
register_sensor_definition(aq, ef00_helpers.ts0601_fingerprints( {
"_TZE200_8ygsuhe1",
"_TZE200_yvx5lh6k",
"_TZE200_c2fmom5z",
"_TZE204_c2fmom5z",
"_TZE204_yvx5lh6k",
}))
local aq_h1_v100_f100 = {
tuya.dp_co2(2, { emit = emit.co2() }),
tuya.dp_numeric(18, { name = "temperature", emit = emit.temperature("C"), scale = 10 }),
tuya.dp_humidity(19, { emit = emit.humidity() }),
tuya.dp_voc(21, { emit = emit.voc(), scale = 100 }),
tuya.dp_formaldehyde(22, { emit = emit.formaldehyde(), scale = AQ_HCHO_DIV100_UGM3_TO_MGM3 }),
}
register_sensor_definition(aq_h1_v100_f100, ef00_helpers.ts0601_fingerprints( {
"_TZE284_8b9zpaav",
}))
local aq_v100_f100 = {
tuya.dp_co2(2, { emit = emit.co2() }),
tuya.dp_numeric(18, { name = "temperature", emit = emit.temperature("C"), scale = 10 }),
tuya.dp_humidity(19, { emit = emit.humidity(), scale = 10 }),
tuya.dp_co2(20, { name = "co2_duplicate" }),                                                       -- 프로파일 미포함 (중복 DP)
tuya.dp_voc(21, { emit = emit.voc(), scale = 100 }),
tuya.dp_formaldehyde(22, { emit = emit.formaldehyde(), scale = AQ_HCHO_DIV100_UGM3_TO_MGM3 }),
}
register_sensor_definition(aq_v100_f100, ef00_helpers.ts0601_fingerprints( {
"_TZE284_it9utkro",
}))
local aq_pm25 = {
tuya.dp_pm25(2, { emit = emit.pm25(), converter = air_house_keeper_pm25() }),
tuya.dp_numeric(18, { name = "temperature", emit = emit.temperature("C"), converter = converter.tuya_unsigned_temp(10) }),
tuya.dp_humidity(19, { emit = emit.humidity(), scale = 10 }),
tuya.dp_formaldehyde(20, { emit = emit.formaldehyde(), scale = AQ_HCHO_UGM3_TO_MGM3 }),
tuya.dp_voc(21, { emit = emit.voc() }),
tuya.dp_co2(22, { emit = emit.co2() }),
}
register_sensor_definition(aq_pm25, ef00_helpers.ts0601_fingerprints( {
"_TZE200_dwcarsat",
"_TZE204_dwcarsat",
"_TZE200_blfcpsxz",
}))
local aq_hcho = {
tuya.dp_formaldehyde(2, { emit = emit.formaldehyde(), scale = AQ_HCHO_UGM3_TO_MGM3 }),
tuya.dp_numeric(18, { name = "temperature", emit = emit.temperature("C"), converter = converter.tuya_unsigned_temp(10) }),
tuya.dp_humidity(19, { emit = emit.humidity(), scale = 10 }),
tuya.dp_voc(21, { emit = emit.voc() }),
tuya.dp_co2(22, { emit = emit.co2() }),
}
register_sensor_definition(aq_hcho, ef00_helpers.ts0601_fingerprints( {
"_TZE200_mja3fuja",
}))
local aq_hcho_f100_v10 = {
tuya.dp_formaldehyde(2, { emit = emit.formaldehyde(), scale = AQ_HCHO_DIV100_UGM3_TO_MGM3 }),
tuya.dp_numeric(18, { name = "temperature", emit = emit.temperature("C"), converter = converter.tuya_unsigned_temp(10) }),
tuya.dp_humidity(19, { emit = emit.humidity(), scale = 10 }),
tuya.dp_voc(21, { emit = emit.voc(), scale = 10 }),
tuya.dp_co2(22, { emit = emit.co2() }),
}
register_sensor_definition(aq_hcho_f100_v10, ef00_helpers.ts0601_fingerprints( {
"_TZE200_ryfmq5rl",
}))
local aq_co2 = {
tuya.dp_co2(2, { emit = emit.co2() }),
tuya.dp_numeric(18, { name = "temperature", emit = emit.temperature("C"), converter = converter.tuya_unsigned_temp(10) }),
tuya.dp_humidity(19, { emit = emit.humidity(), scale = 10 }),
}
register_sensor_definition(aq_co2, ef00_helpers.ts0601_fingerprints( {
"_TZE200_ogkdpgy2",
"_TZE200_3ejwxpmu",
"_TZE204_3ejwxpmu",
}))
local aq_co2_only = {
tuya.dp_co2(2, { emit = emit.co2() }),
}
register_sensor_definition(aq_co2_only, ef00_helpers.ts0601_fingerprints( {
"_TZE204_ogkdpgy2",
}))
local aq_zr360_co2 = {
tuya.dp_enum(1, { name = "air_quality" }),                      -- 프로파일 미포함
tuya.dp_co2(2, { emit = emit.co2() }),
tuya.dp_enum(5, { name = "alarm_ringtone" }),                   -- 프로파일 미포함
tuya.dp_battery_state(14, {}),                                  -- 프로파일 미포함
tuya.dp_numeric(17, { name = "backlight_mode" }),               -- 프로파일 미포함
tuya.dp_temperature(18, { emit = emit.temperature("C"), scale = 1 }),
tuya.dp_humidity(19, { emit = emit.humidity(), scale = 1 }),
}
register_sensor_definition(aq_zr360_co2, ef00_helpers.ts0601_fingerprints( {
"_TZE200_pl31aqf5",
"_TZE200_xpvamyfz",
"_TZE284_xpvamyfz",
}))
register_sensor_definition(aq_zr360_co2, {
device_helpers.create_fingerprint("Nous", "E10"),
})
return device_definitions
