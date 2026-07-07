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
local soil_t10_h1 = {
tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 10 }),
tuya.dp_soil_moisture(3, { emit = emit.soil_moisture() }),
tuya.dp_temperature_unit(9, {}),                                 -- 지원필요없음
tuya.dp_battery_state(14, {}),                                   -- 프로파일 미포함
tuya.dp_battery(15, { emit = emit.battery() }),
}
register_device_definition(soil_t10_h1, ef00_helpers.ts0601_fingerprints( {
"_TZE284_aao3yzhs",
"_TZE284_nhgdf6qr",
"_TZE2841000000_nhgdf6qr",
"_TZE284_ap9owrsa",
"_TZE284_33bwcga2",
"_TZE284_wckqztdq",
"_TZE284_3urschql",
"_TZE284_tgrzpqf4",
"_TZE2841000000_tgrzpqf4",
}))
register_device_definition(soil_t10_h1, {
device_helpers.create_fingerprint("GIEX", "GX04"),
device_helpers.create_fingerprint("GIEX", "GX06"),
})
local soil_t100_h1 = {
tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 1 }),
tuya.dp_soil_moisture(3, { emit = emit.soil_moisture() }),
tuya.dp_temperature_unit(9, {}),                                 -- 지원필요없음
tuya.dp_battery_state(14, {}),                                   -- 프로파일 미포함
tuya.dp_battery(15, { emit = emit.battery() }),
}
register_device_definition(soil_t100_h1, {
device_helpers.create_fingerprint("_TZE200_myd45weu", "TS0601"),
device_helpers.create_fingerprint("_TZE204_myd45weu", "TS0601"),
device_helpers.create_fingerprint("_TZE200_ga1maeof", "TS0601"),
device_helpers.create_fingerprint("_TZE200_9cqcpkgb", "TS0601"),
device_helpers.create_fingerprint("_TZE284_myd45weu", "TS0601"),
device_helpers.create_fingerprint("_TZE200_2se8efxh", "TS0601"),
device_helpers.create_fingerprint("_TZE284_oitavov2", "TS0601"),
device_helpers.create_fingerprint("_TZE284_2nhqasjh", "TS0601"),
device_helpers.create_fingerprint("_TZE284_2se8efxh", "TS0601"),
device_helpers.create_fingerprint("Tuya", "QT-07S"),
})
local soil_t10_h1_ec = {
tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 10 }),
tuya.dp_soil_moisture(3, { emit = emit.soil_moisture() }),
tuya.dp_numeric(1, { name = "electrical_conductivity" }),
tuya.dp_enum(4, { name = "fertility", converter = converter.lookup_from_to({
normal = 0,
lower = 1,
low = 2,
middle = 3,
high = 4,
higher = 5,
}) }),                                -- 순서 의미불명 ec만 지원. (enum: normal/lower/low/middle/high/higher)
tuya.dp_battery(15, { emit = emit.battery() }),
}
register_device_definition(soil_t10_h1_ec, ef00_helpers.ts0601_fingerprints( {
"_TZE284_rqcuwlsa",
}))
local soil_t10_h1_alarm = {
tuya.dp_soil_moisture(3, { emit = emit.soil_moisture() }),
tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 10 }),
tuya.dp_battery_state(14, {}),                                   -- 프로파일 미포함
tuya.dp_battery(15, { emit = emit.battery() }),
tuya.dp_temperature_alarm(101, {}),                              -- 지원필요없음
tuya.dp_humidity_alarm(102, {}),                                 -- 지원필요없음
tuya.dp_max_temperature_alarm(103, { scale = 10 }),              -- 지원필요없음
tuya.dp_min_temperature_alarm(104, { scale = 10 }),              -- 지원필요없음
tuya.dp_max_humidity_alarm(105, {}),                             -- 지원필요없음
tuya.dp_min_humidity_alarm(106, {}),                             -- 지원필요없음
tuya.dp_numeric(107, {
name = "temperature_sensitivity",
scale = 10,
emit = emit.tempSensitivitySoilC03To1(),
}),
tuya.dp_numeric(108, { name = "humidity_sensitivity", emit = emit.humiditySensitivitySoilOneFive() }),
tuya.dp_numeric(109, { name = "schedule_periodic" }),            -- 프로파일 미포함
tuya.dp_numeric(110, { name = "temperature_f", scale = 10 }),    -- 프로파일 미포함
}
register_sensor_definition({
profile = "sensors-soil-temp-moisture-battery-alarm",
datapoints = soil_t10_h1_alarm,
}, ef00_helpers.ts0601_fingerprints( {
"_TZE284_g2e6cpnw",
"_TZE284_sgabhwa6",
"_TZE284_awepdiwi",
}))
local soil_t10_h1_illum = {
tuya.dp_enum(2, { name = "illuminance_level" }),               -- 프로파일 미포함 (enum: low-/low/nor/high/high+)
tuya.dp_soil_moisture(3, { emit = emit.soil_moisture() }),
tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 10 }),
tuya.dp_temperature_unit(9, {}),                               -- 지원필요없음
tuya.dp_battery(15, { emit = emit.battery() }),
}
register_device_definition(soil_t10_h1_illum, ef00_helpers.ts0601_fingerprints( {
"_TZE284_nt4pquef",
}))
local soil_t10_h1_air_illum = {
tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 10 }),
tuya.dp_humidity(101, { emit = emit.humidity(), scale = 1 }),  -- 공기습도 → 표준 capa
tuya.dp_soil_moisture(3, { emit = emit.soil_moisture() }),     -- 토양습도 → 커스텀 capa
tuya.dp_illuminance(102, { emit = emit.illuminance() }),
tuya.dp_enum(14, { name = "battery_state", emit = emit.battery(), converter = converter.from_only(converter.lookup_value({ [0] = 0, [1] = 50, [2] = 100 })) }),
tuya.dp_numeric(103, { name = "humidity_calibration", emit = emit.humidityCalibrationZs301z() }),
tuya.dp_report_interval(104, {}),                              -- 프로파일 미포함
}
register_sensor_definition({
profile = "sensors-soil-temp-humidity-moisture-battery-air-illum",
datapoints = soil_t10_h1_air_illum,
}, ef00_helpers.ts0601_fingerprints( {
"_TZE284_o9ofysmo",
"_TZE284_xc3vwx5a",
}))
local soil_t10_h1_air_warning = {
tuya.dp_temperature(103, { emit = emit.temperature("C"), scale = 10 }),
tuya.dp_humidity(109, { emit = emit.humidity(), scale = 1 }),  -- 공기습도 → 표준 capa
tuya.dp_soil_moisture(107, { emit = emit.soil_moisture() }),   -- 토양습도 → 커스텀 capa
tuya.dp_battery(108, { emit = emit.battery() }),
tuya.dp_water_warning(1, {}),                                  -- 지원필요없음
tuya.dp_soil_calibration(102, {}),                             -- 지원필요없음
tuya.dp_temperature_calibration(104, { emit = emit.tempCalibrationSoilWarnC2() }),
tuya.dp_humidity_calibration(105, { emit = emit.humidityCalibrationSoilWarning30() }),
tuya.dp_temperature_unit(106, {}),                             -- 지원필요없음
tuya.dp_soil_warning(110, {}),                                 -- 지원필요없음
tuya.dp_numeric(111, { name = "temperature_sampling" }),       -- 프로파일 미포함
tuya.dp_soil_sampling(112, {}),                                -- 프로파일 미포함
}
register_sensor_definition({
profile = "sensors-soil-temp-humidity-moisture-battery-warning",
datapoints = soil_t10_h1_air_warning,
}, {
device_helpers.create_fingerprint("_TZE200_wqashyqo", "TS0601"),
})
local soil_t10_h1_air_warning_legacy = {
tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 10 }),
tuya.dp_humidity(109, { emit = emit.humidity(), scale = 1 }),  -- 공기습도 → 표준 capa
tuya.dp_soil_moisture(3, { emit = emit.soil_moisture() }),     -- 토양습도 → 커스텀 capa
tuya.dp_battery(15, { emit = emit.battery() }),
tuya.dp_temperature_unit(9, {}),                               -- 지원필요없음
tuya.dp_soil_calibration(102, {}),                             -- 지원필요없음
tuya.dp_temperature_calibration(104, { emit = emit.tempCalibrationSoilWarnC2() }),
tuya.dp_humidity_calibration(105, { emit = emit.humidityCalibrationSoilWarning30() }),
tuya.dp_numeric(106, {
name = "water_shortage",
converter = converter.lookup_from_to({ on = 1, off = 0 }),
emit = emit.waterShortageSoilWarningLegacy(),
}),
tuya.dp_numeric(110, { name = "soil_warning_threshold", emit = emit.soilWarningThresholdLegacy() }),
tuya.dp_numeric(111, { name = "humidity_sampling" }),          -- 프로파일 미포함
tuya.dp_soil_sampling(112, {}),                                -- 프로파일 미포함
}
register_sensor_definition({
profile = "sensors-soil-temp-humidity-moisture-battery-warning-legacy",
datapoints = soil_t10_h1_air_warning_legacy,
}, {
device_helpers.create_fingerprint("HOBEIAN", "ZG-303Z"),
})
local soil_t10_h1_air_dry = {
tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 10 }),
tuya.dp_humidity(109, { emit = emit.humidity(), scale = 1 }),  -- 공기습도 → 표준 capa
tuya.dp_soil_moisture(3, { emit = emit.soil_moisture() }),     -- 토양습도 → 커스텀 capa
tuya.dp_battery(15, { emit = emit.battery() }),
tuya.dp_enum(106, {
name = "dry_detection",
converter = converter.lookup_from_to({ dry = 1, normal = 0 }),
emit = emit.dryDetectionSoilAirDry(),
}),
}
local soil_t10_h1_dry = {
tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 10 }),
tuya.dp_soil_moisture(3, { emit = emit.soil_moisture() }),
tuya.dp_battery(15, { emit = emit.battery() }),
tuya.dp_temperature_unit(9, {}),                                -- 지원필요없음
tuya.dp_temperature_calibration(104, { emit = emit.tempCalibrationSoilWarnC2() }),
tuya.dp_soil_calibration(102, {}),                              -- 지원필요없음
tuya.dp_soil_warning(110, {}),                                  -- 지원필요없음
tuya.dp_numeric(111, { name = "temperature_sampling" }),        -- 프로파일 미포함
tuya.dp_soil_sampling(112, {}),                                 -- 프로파일 미포함
tuya.dp_enum(106, {
name = "dry_detection",
converter = converter.lookup_from_to({ dry = 1, normal = 0 }),
emit = emit.dryDetectionSoilAirDry(),
}),
}
local soil_t10_h1_air_dry_aoyan = {
tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 10 }),
tuya.dp_humidity(109, { emit = emit.humidity(), scale = 1 }),
tuya.dp_soil_moisture(3, { emit = emit.soil_moisture() }),
tuya.dp_battery(15, { emit = emit.battery() }),
tuya.dp_temperature_unit(9, {}),                                -- 지원필요없음
tuya.dp_temperature_calibration(104, { emit = emit.tempCalibrationSoilWarnC2() }),
tuya.dp_humidity_calibration(105, { emit = emit.humidityCalibrationSoilWarning30() }),
tuya.dp_soil_calibration(102, {}),                              -- 지원필요없음
tuya.dp_soil_warning(110, {}),                                  -- 지원필요없음
tuya.dp_numeric(111, { name = "temperature_sampling" }),        -- 프로파일 미포함
tuya.dp_soil_sampling(112, {}),                                 -- 프로파일 미포함
tuya.dp_enum(106, {
name = "dry_detection",
converter = converter.lookup_from_to({ dry = 1, normal = 0 }),
emit = emit.dryDetectionSoilAirDry(),
}),
}
register_sensor_definition({
profile = "sensors-soil-temp-humidity-moisture-battery-dry",
datapoints = soil_t10_h1_air_dry,
}, ef00_helpers.ts0601_fingerprints( {
"_TZE200_npj9bug3",
"_TZE200_wrmhp6b3",
}))
register_sensor_definition({
profile = "sensors-soil-temp-humidity-moisture-battery-dry",
datapoints = soil_t10_h1_air_dry_aoyan,
}, {
{ manufacturer = "AOYAN  ", model = "AY-303Z" },
})
register_sensor_definition({
profile = "sensors-soil-temp-moisture-battery-dry",
datapoints = soil_t10_h1_dry,
}, {
{ manufacturer = "AOYAN  ", model = "AY-302Z" },
})
local soil_t10_h1_air_illum_warning = {
tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 10 }),
tuya.dp_humidity(101, { emit = emit.humidity(), scale = 1 }),  -- 공기습도 → 표준 capa
tuya.dp_soil_moisture(3, { emit = emit.soil_moisture() }),     -- 토양습도 → 커스텀 capa
tuya.dp_illuminance(102, { emit = emit.illuminance() }),
tuya.dp_enum(14, { name = "battery_state", emit = emit.battery(), converter = converter.from_only(converter.lookup_value({ [0] = 0, [1] = 50, [2] = 100 })) }),
tuya.dp_soil_sampling(103, {}),                                -- 프로파일 미포함
tuya.dp_soil_calibration(104, {}),                             -- 지원필요없음
tuya.dp_numeric(105, { name = "humidity_calibration" }),       -- 지원필요없음
tuya.dp_numeric(106, { name = "illuminance_calibration", emit = emit.illuminanceCalibrationZs300z() }),
tuya.dp_numeric(107, { name = "temperature_calibration", scale = 10 }),  -- 지원필요없음
tuya.dp_soil_warning(110, {}),                                 -- 지원필요없음
tuya.dp_water_warning(111, {}),                                -- 지원필요없음
}
register_sensor_definition({
profile = "sensors-soil-temp-humidity-moisture-illuminance-battery-warning",
datapoints = soil_t10_h1_air_illum_warning,
}, ef00_helpers.ts0601_fingerprints( {
"_TZE284_k7p2q5d9",
"_TZE284_65gzcss7",
"_TZE284_0ints6wl",
"_TZE2841000000_0ints6wl",
"_TZE284_yzr43ayq",
}))
register_sensor_definition({
profile = "sensors-soil-temp-humidity-moisture-illuminance-battery-warning",
datapoints = soil_t10_h1_air_illum_warning,
}, {
device_helpers.create_fingerprint("Arteco", "ZS-302Z"),
})
local soil_t10_h1_air_illum_fertility = {
tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 10 }),
tuya.dp_humidity(101, { emit = emit.humidity(), scale = 1 }),  -- 공기습도 → 표준 capa
tuya.dp_soil_moisture(3, { emit = emit.soil_moisture() }),     -- 토양습도 → 커스텀 capa
tuya.dp_illuminance(102, { emit = emit.illuminance() }),
tuya.dp_battery(14, { emit = emit.battery() }),
tuya.dp_soil_sampling(103, {}),                                -- 프로파일 미포함
tuya.dp_soil_calibration(104, {}),                             -- 지원필요없음
tuya.dp_numeric(105, { name = "humidity_calibration" }),       -- 지원필요없음
tuya.dp_numeric(106, { name = "illuminance_calibration", emit = emit.illuminanceCalibrationZsSf00() }),
tuya.dp_temperature_calibration(107, { emit = emit.temperatureCalibrationZsSf00() }),
tuya.dp_soil_warning(110, {}),                                 -- 지원필요없음
tuya.dp_water_warning(111, {}),                                -- 지원필요없음
tuya.dp_soil_fertility(112, { emit = emit.soil_ec() }),         -- EC값 → 커스텀 capa
tuya.dp_numeric(114, { name = "soil_fertility_warning_setting", emit = emit.soilFertilityWarningZsSf() }),
tuya.dp_soil_fertility_warning(115, {}),                       -- 지원필요없음
}
register_sensor_definition({
profile = "sensors-soil-temp-humidity-moisture-illuminance-ec-battery-fertility-zssf00",
datapoints = soil_t10_h1_air_illum_fertility,
}, {
device_helpers.create_fingerprint("A89G12C", "Arteco"),
})
local soil_t10_h1_air_illum_fertility_cal = {
tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 10 }),
tuya.dp_humidity(101, { emit = emit.humidity(), scale = 1 }),  -- 공기습도 → 표준 capa
tuya.dp_soil_moisture(3, { emit = emit.soil_moisture() }),     -- 토양습도 → 커스텀 capa
tuya.dp_illuminance(102, { emit = emit.illuminance() }),
tuya.dp_battery(15, { emit = emit.battery() }),
tuya.dp_numeric(103, { name = "report_period" }),              -- 프로파일 미포함
tuya.dp_soil_calibration(104, {}),                             -- 지원필요없음
tuya.dp_numeric(105, { name = "humidity_calibration" }),       -- 지원필요없음
tuya.dp_numeric(106, { name = "illuminance_calibration", emit = emit.illuminanceCalibrationZsSf00() }),
tuya.dp_temperature_calibration(107, { emit = emit.temperatureCalibrationZsSf00() }),
tuya.dp_soil_warning(110, {}),                                 -- 지원필요없음
tuya.dp_water_warning(111, {}),                                -- 지원필요없음
tuya.dp_soil_fertility(112, { emit = emit.soil_ec() }),         -- EC값 → 커스텀 capa
tuya.dp_soil_fertility_calibration(113, {}),                   -- 지원필요없음
tuya.dp_numeric(114, { name = "soil_fertility_set_v0" }),      -- 지원필요없음
tuya.dp_numeric(115, { name = "soil_fertility_set_v1" }),      -- 지원필요없음
tuya.dp_soil_fertility_warning(116, {}),                       -- 지원필요없음
}
register_sensor_definition({
profile = "sensors-soil-temp-humidity-moisture-illuminance-ec-battery-fertility-cal",
datapoints = soil_t10_h1_air_illum_fertility_cal,
}, ef00_helpers.ts0601_fingerprints( {
"_TZE284_hdml1aav",
"_TZE2841000000_hdml1aav",
}))
return device_definitions
