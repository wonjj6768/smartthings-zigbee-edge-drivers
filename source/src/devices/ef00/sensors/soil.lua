-- 센서 디바이스 정의
-- ZHA tuya_sensor.py + Z2M zigbee-herdsman-converters 기반 DP 그룹핑
--
-- 변수명 규칙: {category}_{variant}
--   category: th   (온습도: 온도+습도+배터리)
--             soil (토양: 수분+온도+배터리)
--             aq   (공기질: CO2+온도+습도+VOC+포름알데히드)
--   variant 구성 (순서):
--     1. 인코딩: unsigned (Tuya 16-bit unsigned 온도)
--     2. scale:  t=온도, h=습도/수분, v=VOC, f=포름알데히드
--     3. 기능:   알파벳순 배치
--   기능 명칭 (가독성 우선, 풀네임 사용):
--     2aaa           2AAA 배터리 enum
--     air            공기습도 (토양센서에서 soil_moisture 외 별도 humidity DP)
--     alarm          온습도 알람 DP
--     contact        접점 센서
--     co2            CO2만 지원 (aq 간소화)
--     dry            건조 감지
--     ec             전기 전도도
--     fertility      토양 비옥도
--     fertility_cal  비옥도 교정 DP
--     hcho           포름알데히드 primary (DP2=formaldehyde)
--     illum          조도
--     pm25           PM2.5 primary (DP2=PM2.5)
--     probe          외부 프로브
--     warning        물 부족 경고
--   규칙:
--     - category 내 variant 간 차이나는 scale만 표기
--     - soil은 t, h 항상 명시
--     - 복수 차이점은 모두 표기
--     - bare 숫자 금지 (숫자 앞에 의미 문자 필수)
--     - 기능 알파벳순 배치
--     - 가독성 우선: 약어보다 풀네임 선호 (표준 약어 ec, co2, pm25, hcho, illum 유지)
--   aq base 정의: unsigned temp, humidity/10, VOC raw, formaldehyde raw, DP2=CO2

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


-- 2-1. soil_t10_h1: 온도÷10, 수분÷1

-- ZHA: _TZE284_aao3yzhs / Z2M: _TZE284_wckqztdq

-- ══════════════════════════════════════════════════════════════

local soil_t10_h1 = {

  tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 10 }),

  tuya.dp_soil_moisture(3, { emit = emit.soil_moisture() }),

  tuya.dp_enum(9, {
    name = "temperature_unit",
    emit = emit.tuyaSoilScaledTemperatureUnit(),
    converter = converter.lookup_from_to({ celsius = 0, fahrenheit = 1 }),
  }),

  tuya.dp_enum(14, {
    name = "battery_state",
    emit = emit.tuyaSoilScaledBatteryState(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "low",
      [1] = "medium",
      [2] = "high",
    })),
  }),

  tuya.dp_battery(15, { emit = emit.battery() }),

}



local soil_t10_h1_brightness = {

  tuya.dp_enum(2, {
    name = "brightness_level",
    emit = emit.tuyaSoilScaledBrightnessLevel(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "lower",
      [1] = "low",
      [2] = "normal",
      [3] = "high",
      [4] = "higher",
    })),
  }),

  tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 10 }),

  tuya.dp_soil_moisture(3, { emit = emit.soil_moisture() }),

  tuya.dp_enum(9, {
    name = "temperature_unit",
    emit = emit.tuyaSoilScaledTemperatureUnit(),
    converter = converter.lookup_from_to({ celsius = 0, fahrenheit = 1 }),
  }),

  tuya.dp_enum(14, {
    name = "battery_state",
    emit = emit.tuyaSoilScaledBatteryState(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "low",
      [1] = "medium",
      [2] = "high",
    })),
  }),

  tuya.dp_battery(15, { emit = emit.battery() }),

}



register_sensor_definition({
  profile = "sensors-soil-temp-moisture-battery-state-unit-soil-scaled",
  datapoints = soil_t10_h1,
}, ef00_helpers.ts0601_fingerprints( {

  "_TZE284_aao3yzhs",

  "_TZE284_nhgdf6qr",
  "_TZE2841000000_nhgdf6qr",

  "_TZE284_ap9owrsa",

  "_TZE284_33bwcga2",

  "_TZE284_wckqztdq",

  "_TZE284_tgrzpqf4",
  "_TZE2841000000_tgrzpqf4",

}))



register_sensor_definition({
  profile = "sensors-soil-temp-moisture-battery-state-unit-brightness-soil-scaled",
  datapoints = soil_t10_h1_brightness,
}, ef00_helpers.ts0601_fingerprints({
  "_TZE284_3urschql",
}))



-- ══════════════════════════════════════════════════════════════

-- 2-2. soil_t100_h1: 온도 raw, 수분÷1

-- ZHA: _TZE200_myd45weu / Z2M: _TZE284_oitavov2

-- ══════════════════════════════════════════════════════════════

local soil_t100_h1 = {

  tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 1 }),

  tuya.dp_soil_moisture(3, { emit = emit.soil_moisture() }),

  tuya.dp_enum(9, {
    name = "temperature_unit",
    emit = emit.tuyaSoilRawTemperatureUnit(),
    converter = converter.lookup_from_to({ celsius = 0, fahrenheit = 1 }),
  }),

  tuya.dp_enum(14, {
    name = "battery_state",
    emit = emit.tuyaSoilRawBatteryState(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "low",
      [1] = "medium",
      [2] = "high",
    })),
  }),

  tuya.dp_battery(15, { emit = emit.battery() }),

}



register_sensor_definition({
  profile = "sensors-soil-temp-moisture-battery-state-unit-soil-raw",
  datapoints = soil_t100_h1,
}, {

  device_helpers.create_fingerprint("_TZE200_myd45weu", "TS0601"),

  device_helpers.create_fingerprint("_TZE204_myd45weu", "TS0601"),

  device_helpers.create_fingerprint("_TZE200_ga1maeof", "TS0601"),

  device_helpers.create_fingerprint("_TZE200_9cqcpkgb", "TS0601"),

  device_helpers.create_fingerprint("_TZE284_myd45weu", "TS0601"),

  device_helpers.create_fingerprint("_TZE200_2se8efxh", "TS0601"),

  device_helpers.create_fingerprint("_TZE284_oitavov2", "TS0601"),

  device_helpers.create_fingerprint("_TZE284_2nhqasjh", "TS0601"),

  device_helpers.create_fingerprint("_TZE284_2se8efxh", "TS0601"),

})



-- ══════════════════════════════════════════════════════════════

-- 2-3. soil_t10_h1_ec: 전기 전도도 + 비옥도

-- ZHA: _TZE284_rqcuwlsa / Z2M: NAS-STH02B2

-- ══════════════════════════════════════════════════════════════

local soil_t10_h1_ec = {

  tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 10, read_only = true }),

  tuya.dp_soil_moisture(3, { emit = emit.soil_moisture(), read_only = true }),

  tuya.dp_numeric(1, {
    name = "electrical_conductivity",
    emit = emit.soil_ec(),
    read_only = true,
  }),

  tuya.dp_enum(4, {
    name = "fertility",
    emit = emit.neoSth02Fertility(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "normal",
      [1] = "lower",
      [2] = "low",
      [3] = "middle",
      [4] = "high",
      [5] = "higher",
    })),
  }),

  tuya.dp_enum(14, {
    name = "battery_state",
    emit = emit.neoSth02BatteryState(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "low",
      [1] = "medium",
      [2] = "high",
    })),
  }),

  tuya.dp_battery(15, { emit = emit.battery(), read_only = true }),

  tuya.dp_temperature_alarm(101, {
    emit = emit.neoSth02TemperatureAlarm(),
    read_only = true,
  }),

  tuya.dp_humidity_alarm(102, {
    emit = emit.neoSth02HumidityAlarm(),
    read_only = true,
  }),

  tuya.dp_max_temperature_alarm(103, {
    scale = 10,
    emit = emit.neoSth02MaximumTemperature(),
  }),

  tuya.dp_min_temperature_alarm(104, {
    scale = 10,
    emit = emit.neoSth02MinimumTemperature(),
  }),

  tuya.dp_max_humidity_alarm(105, { emit = emit.neoSth02MaximumHumidity() }),

  tuya.dp_min_humidity_alarm(106, { emit = emit.neoSth02MinimumHumidity() }),

  tuya.dp_numeric(107, {
    name = "temperature_sensitivity",
    converter = converter.divide_by_pair(10),
    emit = emit.tempSensitivitySoilC03To1(),
  }),

  tuya.dp_numeric(108, {
    name = "humidity_sensitivity",
    emit = emit.humiditySensitivitySoilOneFive(),
  }),

  tuya.dp_numeric(109, {
    name = "schedule_periodic",
    emit = emit.neoSth02ReportPeriod(),
  }),

  tuya.dp_numeric(110, {
    name = "temperature_f",
    converter = converter.divide_by_pair(10),
    emit = emit.neoSth02TemperatureF(),
    read_only = true,
  }),

}



register_sensor_definition({
  profile = "sensors-soil-neo-sth02b2",
  datapoints = soil_t10_h1_ec,
}, ef00_helpers.ts0601_fingerprints( {

  "_TZE284_rqcuwlsa",

  "_TZE284_awepdiwi",

}))



-- ══════════════════════════════════════════════════════════════

-- 2-4. soil_t10_h1_alarm: 알람 (DPs 101-110)

-- Z2M: _TZE284_g2e6cpnw (TS0601_soil_2)

-- ══════════════════════════════════════════════════════════════

local soil_t10_h1_alarm = {

  tuya.dp_soil_moisture(3, { emit = emit.soil_moisture(), read_only = true }),

  tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 10, read_only = true }),

  tuya.dp_enum(14, {
    name = "battery_state",
    emit = emit.soil2BatteryState(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "low",
      [1] = "medium",
      [2] = "high",
    })),
  }),

  tuya.dp_battery(15, { emit = emit.battery(), read_only = true }),

  tuya.dp_temperature_alarm(101, {
    emit = emit.soil2TemperatureAlarm(),
    read_only = true,
  }),

  tuya.dp_humidity_alarm(102, {
    emit = emit.soil2HumidityAlarm(),
    read_only = true,
  }),

  tuya.dp_max_temperature_alarm(103, {
    scale = 10,
    emit = emit.soil2MaximumTemperature(),
  }),

  tuya.dp_min_temperature_alarm(104, {
    scale = 10,
    emit = emit.soil2MinimumTemperature(),
  }),

  tuya.dp_max_humidity_alarm(105, { emit = emit.soil2MaximumHumidity() }),

  tuya.dp_min_humidity_alarm(106, { emit = emit.soil2MinimumHumidity() }),

  tuya.dp_numeric(107, {
    name = "temperature_sensitivity",
    converter = converter.divide_by_pair(10),
    emit = emit.tempSensitivitySoilC03To1(),
  }),

  tuya.dp_numeric(108, { name = "humidity_sensitivity", emit = emit.humiditySensitivitySoilOneFive() }),

  tuya.dp_numeric(109, {
    name = "schedule_periodic",
    emit = emit.soil2ReportPeriod(),
  }),

  tuya.dp_numeric(110, {
    name = "temperature_f",
    converter = converter.divide_by_pair(10),
    emit = emit.soil2TemperatureF(),
    read_only = true,
  }),

}



register_sensor_definition({
  profile = "sensors-soil-ts0601-soil2",
  datapoints = soil_t10_h1_alarm,
}, ef00_helpers.ts0601_fingerprints( {

  "_TZE284_g2e6cpnw",

  "_TZE284_sgabhwa6",

}))



-- ══════════════════════════════════════════════════════════════

-- 2-5. soil_t10_h1_illum: 조도레벨 enum

-- Z2M: _TZE284_nt4pquef (SGS02Z)

-- ══════════════════════════════════════════════════════════════

local soil_t10_h1_illum = {

  tuya.dp_enum(2, {
    name = "illuminance_level",
    emit = emit.sgs02zIlluminanceLevel(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "low-",
      [1] = "low",
      [2] = "nor",
      [3] = "high",
      [4] = "high+",
    })),
  }),

  tuya.dp_soil_moisture(3, { emit = emit.soil_moisture() }),

  tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 10 }),

  tuya.dp_enum(9, {
    name = "temperature_unit",
    emit = emit.sgs02zTemperatureUnit(),
    converter = converter.lookup_from_to({ celsius = 0, fahrenheit = 1 }),
  }),

  tuya.dp_battery(15, { emit = emit.battery() }),

}



register_sensor_definition({
  profile = "sensors-soil-temp-moisture-battery-unit-illuminance-sgs02z",
  datapoints = soil_t10_h1_illum,
}, ef00_helpers.ts0601_fingerprints( {

  "_TZE284_nt4pquef",

}))



-- ══════════════════════════════════════════════════════════════

-- 2-6. soil_t10_h1_air_illum: 공기습도 + 조도

-- Z2M: _TZE284_o9ofysmo (ZS-301Z, Arteco)

-- ══════════════════════════════════════════════════════════════

local soil_t10_h1_air_illum = {

  tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 10, read_only = true }),

  tuya.dp_humidity(101, { emit = emit.humidity(), scale = 1, read_only = true }),  -- 공기습도 → 표준 capa

  tuya.dp_soil_moisture(3, { emit = emit.soil_moisture(), read_only = true }),     -- 토양습도 → 커스텀 capa

  tuya.dp_illuminance(102, { emit = emit.illuminance(), read_only = true }),

  tuya.dp_enum(14, {
    name = "battery_state",
    emit = emit.zs301BatteryState(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "low",
      [1] = "middle",
      [2] = "high",
    })),
  }),

  tuya.dp_numeric(103, { name = "humidity_calibration", emit = emit.humidityCalibrationZs301z() }),

  tuya.dp_report_interval(104, { emit = emit.zs301ReportInterval() }),

}



register_sensor_definition({
  profile = "sensors-soil-temp-humidity-moisture-battery-air-illum",
  datapoints = soil_t10_h1_air_illum,
}, ef00_helpers.ts0601_fingerprints( {

  "_TZE284_o9ofysmo",

  "_TZE284_xc3vwx5a",

}))



-- ══════════════════════════════════════════════════════════════

-- 2-7. soil_t10_h1_air_warning: 공기습도 + 물부족경고 (리맵 DP)

-- Z2M: _TZE200_wqashyqo (ZG-303Z)

-- ══════════════════════════════════════════════════════════════

local soil_t10_h1_air_warning = {

  tuya.dp_temperature(103, { emit = emit.temperature("C"), scale = 10, read_only = true }),

  tuya.dp_humidity(109, { emit = emit.humidity(), scale = 1, read_only = true }),  -- 공기습도 → 표준 capa

  tuya.dp_soil_moisture(107, { emit = emit.soil_moisture(), read_only = true }),   -- 토양습도 → 커스텀 capa

  tuya.dp_battery(108, { emit = emit.battery(), read_only = true }),

  tuya.dp_water_warning(1, {
    emit = emit.zg303WaterWarning(),
    read_only = true,
  }),

  tuya.dp_soil_calibration(102, { emit = emit.zg303SoilCalibration() }),

  tuya.dp_temperature_calibration(104, { emit = emit.tempCalibrationSoilWarnC2() }),

  tuya.dp_humidity_calibration(105, { emit = emit.humidityCalibrationSoilWarning30() }),

  tuya.dp_temperature_unit(106, {
    emit = emit.zg303TemperatureUnit(),
    converter = converter.lookup_from_to({ celsius = 0, fahrenheit = 1 }),
  }),

  tuya.dp_soil_warning(110, { emit = emit.zg303SoilWarning() }),

  tuya.dp_temperature_sampling(111, { emit = emit.zg303TemperatureSampling() }),

  tuya.dp_soil_sampling(112, { emit = emit.zg303SoilSampling() }),

}



register_sensor_definition({
  profile = "sensors-soil-temp-humidity-moisture-battery-warning",
  datapoints = soil_t10_h1_air_warning,
}, {

  device_helpers.create_fingerprint("_TZE200_wqashyqo", "TS0601"),

})



-- ══════════════════════════════════════════════════════════════

-- 2-7a. soil_t10_h1_air_warning_legacy: HOBEIAN ZG-303Z

-- 실기기 기준 DP3/5/15 + DP109 조합

-- ══════════════════════════════════════════════════════════════

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



-- ══════════════════════════════════════════════════════════════

-- 2-8. soil_t10_h1_air_dry: 공기습도 + 건조감지

-- Z2M: _TZE200_npj9bug3 (CS-201Z, COOLO)

-- ══════════════════════════════════════════════════════════════

local soil_t10_h1_air_dry = {

  tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 10, read_only = true }),

  tuya.dp_humidity(109, { emit = emit.humidity(), scale = 1, read_only = true }),

  tuya.dp_soil_moisture(3, { emit = emit.soil_moisture(), read_only = true }),

  tuya.dp_battery(15, { emit = emit.battery(), read_only = true }),

  tuya.dp_enum(106, {
    name = "dry",
    converter = converter.from_only(converter.lookup_value({ [0] = "normal", [1] = "dry" })),
    emit = emit.cs201zDryState(),
    read_only = true,
  }),

  tuya.dp_temperature_unit(9, {
    emit = emit.cs201zTemperatureUnit(),
    converter = converter.lookup_from_to({ celsius = 0, fahrenheit = 1 }),
  }),

  tuya.dp_temperature_calibration(104, { emit = emit.tempCalibrationSoilWarnC2() }),

  tuya.dp_humidity_calibration(105, { emit = emit.humidityCalibrationSoilWarning30() }),

  tuya.dp_soil_calibration(102, { emit = emit.cs201zSoilCalibration() }),

  tuya.dp_temperature_sampling(111, { emit = emit.cs201zTemperatureSampling() }),

  tuya.dp_soil_sampling(112, { emit = emit.cs201zSoilSampling() }),

  tuya.dp_soil_warning(110, { emit = emit.soilWarningThresholdLegacy() }),

}

local soil_t10_h1_dry = {

  tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 10, read_only = true }),

  tuya.dp_soil_moisture(3, { emit = emit.soil_moisture(), read_only = true }),

  tuya.dp_battery(15, { emit = emit.battery(), read_only = true }),

  tuya.dp_temperature_unit(9, {
    emit = emit.ay302zTemperatureUnit(),
    converter = converter.lookup_from_to({ celsius = 0, fahrenheit = 1 }),
  }),

  tuya.dp_temperature_calibration(104, { emit = emit.tempCalibrationSoilWarnC2() }),

  tuya.dp_soil_calibration(102, { emit = emit.ay302zSoilCalibration() }),

  tuya.dp_soil_warning(110, { emit = emit.soilWarningThresholdLegacy() }),

  tuya.dp_temperature_sampling(111, { emit = emit.ay302zTemperatureSampling() }),

  tuya.dp_soil_sampling(112, { emit = emit.ay302zSoilSampling() }),

  tuya.dp_enum(106, {
    name = "dry",
    converter = converter.from_only(converter.lookup_value({ [0] = "normal", [1] = "dry" })),
    emit = emit.ay302zDryState(),
    read_only = true,
  }),

}

register_sensor_definition({
  profile = "sensors-soil-temp-humidity-moisture-battery-dry",
  datapoints = soil_t10_h1_air_dry,
}, {

  device_helpers.create_fingerprint("_TZE200_npj9bug3", "TS0601"),

  device_helpers.create_fingerprint("_TZE200_wrmhp6b3", "TS0601"),

  { manufacturer = "AOYAN  ", model = "AY-303Z" },

})

register_sensor_definition({
  profile = "sensors-soil-temp-moisture-battery-dry",
  datapoints = soil_t10_h1_dry,
}, {

  { manufacturer = "AOYAN  ", model = "AY-302Z" },

})



-- ══════════════════════════════════════════════════════════════

-- 2-9. soil_t10_h1_air_illum_warning: 공기습도 + 조도 + 물부족경고

-- Z2M: _TZE284_k7p2q5d9 (ZS-300Z, Arteco)

-- ══════════════════════════════════════════════════════════════

local soil_t10_h1_air_illum_warning = {

  tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 10, read_only = true }),

  tuya.dp_humidity(101, { emit = emit.humidity(), scale = 1, read_only = true }),

  tuya.dp_soil_moisture(3, { emit = emit.soil_moisture(), read_only = true }),

  tuya.dp_illuminance(102, { emit = emit.illuminance(), read_only = true }),

  tuya.dp_enum(14, {
    name = "battery_state",
    emit = emit.zs300zBatteryState(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "low",
      [1] = "middle",
      [2] = "high",
    })),
  }),

  tuya.dp_soil_sampling(103, { emit = emit.zs300zSoilSampling() }),

  tuya.dp_soil_calibration(104, { emit = emit.zs300zSoilCalibration() }),

  tuya.dp_humidity_calibration(105, { emit = emit.humidityCalibrationZs301z() }),

  tuya.dp_numeric(106, { name = "illuminance_calibration", emit = emit.illuminanceCalibrationZs300z() }),

  tuya.dp_temperature_calibration(107, { emit = emit.tempCalibrationSoilWarnC2() }),

  tuya.dp_soil_warning(110, { emit = emit.soilWarningThresholdLegacy() }),

  tuya.dp_water_warning(111, { emit = emit.zs300zWaterWarning(), read_only = true }),

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



-- ══════════════════════════════════════════════════════════════

-- 2-10. soil_t10_h1_air_illum_fertility: 공기습도 + 조도 + 비옥도

-- Z2M: A89G12C/Arteco (ZS-SF00) -- 비표준 핑거프린트 (model="Arteco", manufacturer="A89G12C")

-- ══════════════════════════════════════════════════════════════

local soil_t10_h1_air_illum_fertility = {

  tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 10, read_only = true }),

  tuya.dp_humidity(101, { emit = emit.humidity(), scale = 1, read_only = true }),

  tuya.dp_soil_moisture(3, { emit = emit.soil_moisture(), read_only = true }),

  tuya.dp_illuminance(102, { emit = emit.illuminance(), read_only = true }),

  tuya.dp_battery(14, { emit = emit.battery(), read_only = true }),

  tuya.dp_soil_sampling(103, { emit = emit.zsSf00SoilSampling() }),

  tuya.dp_soil_calibration(104, { emit = emit.zsSf00SoilCalibration() }),

  tuya.dp_humidity_calibration(105, { emit = emit.humidityCalibrationZs301z() }),

  tuya.dp_numeric(106, { name = "illuminance_calibration", emit = emit.illuminanceCalibrationZsSf00() }),

  tuya.dp_temperature_calibration(107, { emit = emit.temperatureCalibrationZsSf00() }),

  tuya.dp_soil_warning(110, { emit = emit.soilWarningThresholdLegacy() }),

  tuya.dp_water_warning(111, { emit = emit.zsSf00WaterWarning(), read_only = true }),

  tuya.dp_soil_fertility(112, { emit = emit.zsSf00SoilFertility(), read_only = true }),

  tuya.dp_numeric(114, { name = "soil_fertility_warning_setting", emit = emit.soilFertilityWarningZsSf() }),

  tuya.dp_soil_fertility_warning(115, { emit = emit.zsSf00FertilityWarning(), read_only = true }),

}



register_sensor_definition({
  profile = "sensors-soil-temp-humidity-moisture-illuminance-ec-battery-fertility-zssf00",
  datapoints = soil_t10_h1_air_illum_fertility,
}, {

  device_helpers.create_fingerprint("A89G12C", "Arteco"),

})



-- ══════════════════════════════════════════════════════════════

-- 2-11. soil_t10_h1_air_illum_fertility_cal: 공기습도 + 조도 + 비옥도 + 비옥도교정

-- Z2M: _TZE284_hdml1aav (ZS-300TF, Excellux)

-- ══════════════════════════════════════════════════════════════

local soil_t10_h1_air_illum_fertility_cal = {

  tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 10, read_only = true }),

  tuya.dp_humidity(101, { emit = emit.humidity(), scale = 1, read_only = true }),

  tuya.dp_soil_moisture(3, { emit = emit.soil_moisture(), read_only = true }),

  tuya.dp_illuminance(102, { emit = emit.illuminance(), read_only = true }),

  tuya.dp_battery(15, { emit = emit.battery(), read_only = true }),

  tuya.dp_numeric(103, { name = "report_period", emit = emit.zs300tfReportPeriod() }),

  tuya.dp_soil_calibration(104, { emit = emit.zs300tfSoilCalibration() }),

  tuya.dp_humidity_calibration(105, { emit = emit.humidityCalibrationZs301z() }),

  tuya.dp_numeric(106, { name = "illuminance_calibration", emit = emit.illuminanceCalibrationZsSf00() }),

  tuya.dp_temperature_calibration(107, { emit = emit.temperatureCalibrationZsSf00() }),

  tuya.dp_soil_warning(110, { emit = emit.soilWarningThresholdLegacy() }),

  tuya.dp_water_warning(111, { emit = emit.zs300tfWaterWarning(), read_only = true }),

  tuya.dp_soil_fertility(112, { emit = emit.zs300tfSoilFertility(), read_only = true }),

  tuya.dp_soil_fertility_calibration(113, { emit = emit.zs300tfFertilityCalibration() }),

  tuya.dp_numeric(114, { name = "soil_fertility_set_v0", emit = emit.zs300tfFertilityLowThreshold() }),

  tuya.dp_numeric(115, { name = "soil_fertility_set_v1", emit = emit.zs300tfFertilityHighThreshold() }),

  tuya.dp_soil_fertility_warning(116, {
    emit = emit.zs300tfFertilityWarning(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "none",
      [1] = "low",
      [2] = "high",
    })),
  }),

}



register_sensor_definition({
  profile = "sensors-soil-temp-humidity-moisture-illuminance-ec-battery-fertility-cal",
  datapoints = soil_t10_h1_air_illum_fertility_cal,
}, ef00_helpers.ts0601_fingerprints( {

  "_TZE284_hdml1aav",
  "_TZE2841000000_hdml1aav",

}))



return device_definitions
