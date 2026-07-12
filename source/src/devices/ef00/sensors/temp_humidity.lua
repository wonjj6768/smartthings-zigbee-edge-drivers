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

local function pool_ph_converter()
  return converter.from_only(function(value)
    local numeric = tonumber(value)
    if numeric == nil then
      return nil
    end
    if numeric > 99 then
      return numeric / 100
    end
    return numeric / 10
  end)
end

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


-- ══════════════════════════════════════════════════════════════

-- 1-1. th_unsigned_h10: unsigned 온도 인코딩, 습도÷10

-- ZHA: _TZE200_bjawzodf

-- ══════════════════════════════════════════════════════════════

local th_unsigned_h10 = {

  tuya.dp_numeric(1, { name = "temperature", emit = emit.temperature("C"), converter = converter.tuya_unsigned_temp(10) }),

  tuya.dp_humidity(2, { emit = emit.humidity(), scale = 10 }),

  tuya.dp_battery(4, { emit = emit.battery() }),

}



register_device_definition(th_unsigned_h10, ef00_helpers.ts0601_fingerprints( {

  "_TZE200_bjawzodf",

  "_TZE200_zl1kmjqx",

  "_TZE284_9ern5sfh",

}))



-- ══════════════════════════════════════════════════════════════

-- 1-2. th_unsigned: unsigned 온도 인코딩

-- ZHA: _TZE200_bq5c8xfe

-- ══════════════════════════════════════════════════════════════

local th_unsigned = {

  tuya.dp_numeric(1, { name = "temperature", emit = emit.temperature("C"), converter = converter.tuya_unsigned_temp(10) }),

  tuya.dp_humidity(2, { emit = emit.humidity(), scale = 1 }),

  tuya.dp_battery(4, { emit = emit.battery() }),

}



register_device_definition(th_unsigned, ef00_helpers.ts0601_fingerprints( {

  "_TZE200_bq5c8xfe",

  "_TZE200_qyflbnbj",

  "_TZE204_qyflbnbj",

  "_TZE284_qyflbnbj",

  "_TZE200_44af8vyi",

}))



-- ══════════════════════════════════════════════════════════════

-- 1-3. th: 기본형

-- ZHA: _TZE200_a8sdabtg / Z2M: _TZE200_t3xd7l44

-- Z2M: ZG-227Z / ZG-227ZL family includes _TZE200_a8sdabtg, _TZE200_vs0skpuc, _TZE200_ehhrv2e3

-- ══════════════════════════════════════════════════════════════

local th = {

  tuya.dp_temperature(1, { emit = emit.temperature("C"), scale = 10 }),

  tuya.dp_humidity(2, { emit = emit.humidity(), scale = 1 }),

  tuya.dp_battery(4, { emit = emit.battery() }),

  tuya.dp_temperature_unit(9, {}),                                -- 지원필요없음

  tuya.dp_temperature_calibration(23, { emit = emit.temperatureCalibrationZg227z() }),

  tuya.dp_humidity_calibration(24, { emit = emit.humidityCalibrationZg227z() }),

}



register_sensor_definition({
  profile = "sensors-temp-humidity-battery-calibration-zg227z",
  datapoints = th,
}, ef00_helpers.ts0601_fingerprints( {

  "_TZE200_a8sdabtg",

  "_TZE200_qoy0ekbd",

  "_TZE200_znbl8dj5",

  "_TZE200_zppcgbdj",

  "_TZE200_nnrfa68v",

  "_TZE200_wtikaxzs",

  "_TZE284_wtikaxzs",

  "_TZE204_s139roas",

  "_TZE200_s1xgth2u",

  "_TZE200_t3xd7l44",

  "_TZE284_kdqrazmy",

  "_TZE200_dikkika5",

  "_TZE200_vs0skpuc",

  "_TZE200_3xfjp0ag",

  "_TZE200_ehhrv2e3",

  "_TZE200_lhqtjwax",
  "_TZE200_y8wkaq6w",

  "_TZE200_ysm4dsb1",

}))



register_sensor_definition({
  profile = "sensors-temp-humidity-battery-calibration-zg227z",
  datapoints = th,
}, {

  device_helpers.create_fingerprint("HOBEIAN", "ZG-227Z"),

  device_helpers.create_fingerprint("HOBEIAN", "ZG-227ZL"),

  device_helpers.create_fingerprint("KOJIMA", "KOJIMA-THS-ZG-LCD"),

  device_helpers.create_fingerprint("Tuya", "TZE200_t3xd7l44"),

})



-- ══════════════════════════════════════════════════════════════

-- 1-3a. pool_chlorine_meter: BLE-YL01 / YK-S03 / YY-1099L

-- Z2M exposes pool chemistry values; current ST surface keeps safe standard

-- temperature + battery and preserves the rest as non-profile DPs.

-- ══════════════════════════════════════════════════════════════

local th_battery_state = {

  tuya.dp_temperature(1, { emit = emit.temperature("C"), scale = 10 }),

  tuya.dp_humidity(2, { emit = emit.humidity(), scale = 1 }),

  tuya.dp_enum(3, { name = "battery_state", emit = emit.battery(), converter = converter.from_only(converter.lookup_value({ [0] = 0, [1] = 50, [2] = 100 })) }),

  tuya.dp_temperature_unit(9, {}),

  tuya.dp_temperature_calibration(23, { emit = emit.temperatureCalibrationZg227z() }),

  tuya.dp_humidity_calibration(24, { emit = emit.humidityCalibrationZg227z() }),

}

register_sensor_definition({
  profile = "sensors-temp-humidity-battery-calibration-zg227z",
  datapoints = th_battery_state,
}, ef00_helpers.ts0601_fingerprints( {

  "_TZE284_rjjsib2d",

}))

local pool_chlorine_meter = {

  profile = "sensors-temp-battery-pool-chlorine",

  datapoints = {

    tuya.dp_numeric(1, { name = "tds", emit = emit.tdsChlorineMeter() }),

    tuya.dp_temperature(2, { emit = emit.temperature("C"), scale = 10 }),

    tuya.dp_battery(7, { emit = emit.battery() }),

    tuya.dp_numeric(10, { name = "ph", emit = emit.poolPhChlorineMeter(), converter = pool_ph_converter() }),

    tuya.dp_numeric(11, { name = "ec" }),                                 -- profile 미포함

    tuya.dp_numeric(101, { name = "orp", emit = emit.poolOrpChlorineMeter() }),

    tuya.dp_numeric(102, { name = "free_chlorine", scale = 10, emit = emit.freeChlorineChlorineMeter() }),

    tuya.dp_numeric(105, { name = "backlightvalue" }),                    -- profile 미포함

    tuya.dp_numeric(117, { name = "salinity", emit = emit.salinityChlorineMeter() }),

  },

  query_on_configure = true,

}



register_device_definition(pool_chlorine_meter, ef00_helpers.ts0601_fingerprints( {

  "_TZE200_d9mzkhoq",

  "_TZE200_v1jqz5cy",

}))



register_device_definition(pool_chlorine_meter, {

  device_helpers.create_fingerprint("Tuya", "YK-S03"),

  device_helpers.create_fingerprint("Tuya", "YY-1099L"),

})



-- ══════════════════════════════════════════════════════════════

-- 1-3b. heat_water_meter: ultrasonic heat/water meter

-- Keep water/heat metering DPs hidden until a dedicated water-meter surface exists.

-- ══════════════════════════════════════════════════════════════

local heat_water_meter = {

  profile = "sensors-temp-battery-heat-water-meter",

  datapoints = {

    tuya.dp_water_consumed(1, { name = "water_consumed", emit = emit.waterConsumedHeatMeter() }),

    tuya.dp_month_consumption(2, { name = "monthly_water_consumption" }),   -- profile 미포함

    tuya.dp_daily_consumption(3, { name = "daily_water_consumption" }),     -- profile 미포함

    tuya.dp_binary(6, { name = "prepayment_switch" }),                     -- profile 미포함

    tuya.dp_cumulative_heat(7, { name = "cumulative_heat" }),              -- profile 미포함

    tuya.dp_string(16, { name = "meter_id" }),                             -- profile 미포함

    tuya.dp_inlet_water_temperature(21, { name = "temperature", emit = emit.temperature("C") }),

    tuya.dp_outlet_water_temperature(22, { name = "outlet_water_temperature" }), -- profile 미포함

    tuya.dp_battery_voltage(26, { name = "battery_voltage" }),             -- profile 미포함

  },

  query_on_configure = true,

}



register_device_definition(heat_water_meter, ef00_helpers.ts0601_fingerprints( {

  "_TZE200_jt50ea5d",

}))



local ultrasonic_water_meter = {

  profile = "sensors-temp-battery",

  datapoints = {

    tuya.dp_water_consumed(1, { name = "water_consumed" }),                 -- profile 미포함

    tuya.dp_string(16, { name = "meter_id" }),                             -- profile 미포함

    tuya.dp_temperature(22, { emit = emit.temperature("C"), scale = 100 }),

    tuya.dp_battery_voltage(26, { name = "battery_voltage" }),             -- profile 미포함

  },

  query_on_configure = true,

}



register_device_definition(ultrasonic_water_meter, ef00_helpers.ts0601_fingerprints( {

  "_TZE284_ajlu4cud",

}))



-- ══════════════════════════════════════════════════════════════

-- 1-4. th_alarm: 알람 + 리포트

-- ZHA: _TZE200_lve3dvpy / Z2M: _TZE284_cwyqwqbf / _TZE200_whkgqxse (JM-TRH-ZGB-V1)

-- ══════════════════════════════════════════════════════════════

local th_alarm = {

  tuya.dp_temperature(1, { emit = emit.temperature("C"), scale = 10 }),

  tuya.dp_humidity(2, { emit = emit.humidity(), scale = 1 }),

  tuya.dp_battery_state(3, {}),                                          -- 프로파일 미포함

  tuya.dp_battery(4, { emit = emit.battery() }),

  tuya.dp_temperature_unit(9, {}),                                       -- 지원필요없음

  tuya.dp_max_temperature_alarm(10, { scale = 10 }),                     -- 지원필요없음

  tuya.dp_min_temperature_alarm(11, { scale = 10 }),                     -- 지원필요없음

  tuya.dp_max_humidity_alarm(12, {}),                                    -- 지원필요없음

  tuya.dp_min_humidity_alarm(13, {}),                                    -- 지원필요없음

  tuya.dp_temperature_alarm(14, {}),                                     -- 지원필요없음

  tuya.dp_humidity_alarm(15, {}),                                        -- 지원필요없음

  tuya.dp_report_interval(17, { name = "temperature_report_interval" }), -- 프로파일 미포함

  tuya.dp_report_interval(18, { name = "humidity_report_interval" }),    -- 프로파일 미포함

  tuya.dp_numeric(19, {
    name = "temperature_sensitivity",
    scale = 10,
    emit = emit.tempSensitivityThCToOne(),
  }),

  tuya.dp_numeric(20, { name = "humidity_sensitivity", emit = emit.humiditySensitivityThThreeTen() }),

}



register_sensor_definition({
  profile = "sensors-temp-humidity-battery-alarm-sensitivity-th-alarm",
  datapoints = th_alarm,
}, ef00_helpers.ts0601_fingerprints( {

  "_TZE200_lve3dvpy",

  "_TZE200_c7emyjom",

  "_TZE200_locansqn",

  "_TZE200_qrztc3ev",

  "_TZE200_snloy4rw",

  "_TZE200_eanjj2pa",

  "_TZE200_ydrdfkim",

  "_TZE284_locansqn",

  "_TZE200_w6n8jeuu",

  "_TZE200_vvmbj46n",

  "_TZE284_vvmbj46n",

  "_TZE284_4dosadbh",

  "_TZE284_mpzuabwk",

  "_TZE284_rs62zxk8",

  "_TZE284_cwyqwqbf",

  "_TZE200_whkgqxse",

}))



register_sensor_definition({
  profile = "sensors-temp-humidity-battery-alarm-sensitivity-th-alarm",
  datapoints = th_alarm,
}, {

  device_helpers.create_fingerprint("ONENUO", "TH05Z"),

  device_helpers.create_fingerprint("Tuya", "TZE284_cwyqwqbf"),

})



-- ══════════════════════════════════════════════════════════════

-- 1-5. th_2aaa: 2AAA 배터리 enum

-- ZHA: _TZE200_upagmta9 / Z2M: _TZE204_d7lpruvi

-- ══════════════════════════════════════════════════════════════

local th_2aaa = {

  tuya.dp_temperature(1, { emit = emit.temperature("C"), scale = 10 }),

  tuya.dp_humidity(2, { emit = emit.humidity(), scale = 1 }),

  tuya.dp_enum(3, { name = "battery", emit = emit.battery(), converter = converter.from_only(converter.lookup_value({ [0] = 25, [1] = 50, [2] = 100 })) }),

  tuya.dp_temperature_unit(9, {}),                                       -- 지원필요없음

}



register_device_definition(th_2aaa, ef00_helpers.ts0601_fingerprints( {

  "_TZE200_upagmta9",

  "_TZE204_upagmta9",

  "_TZE284_upagmta9",

  "_TZE200_cirvgep4",

  "_TZE204_cirvgep4",

  "_TZE204_jygvp6fk",

  "_TZE200_yjjdcqsq",

  "_TZE204_yjjdcqsq",

  "_TZE284_yjjdcqsq",

  "_TZE200_9yapgbuv",

  "_TZE204_9yapgbuv",

  "_TZE284_9yapgbuv",

  "_TZE200_utkemkbs",

  "_TZE204_utkemkbs",

  "_TZE284_utkemkbs",

  "_TZE204_ksz749x8",

  "_TZE204_1wnh8bqp",

  "_TZE284_1wnh8bqp",

  "_TZE204_kwi6bbk4",

  "_TZE204_d7lpruvi",

  "_TZE200_d7lpruvi",

  "_TZE284_d7lpruvi",

  "_TZE284_hdyjyqjm",

}))



register_device_definition(th_2aaa, {

  device_helpers.create_fingerprint("Tuya", "ZTH01"),

  device_helpers.create_fingerprint("Tuya", "SZTH02"),

  device_helpers.create_fingerprint("Tuya", "ZTH02"),

  device_helpers.create_fingerprint("Tuya", "ZTH05"),

  device_helpers.create_fingerprint("Tuya", "ZTH08-E"),

  device_helpers.create_fingerprint("Tuya", "ZTH08"),

})



-- ══════════════════════════════════════════════════════════════

-- 1-5a. th_excellux: Excellux 온습도 (modelID=Excellux)

-- Z2M: DHT0001 / DHTA001

-- ══════════════════════════════════════════════════════════════

local th_excellux = {

  tuya.dp_battery(4, { emit = emit.battery() }),

  tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 100 }),

  tuya.dp_humidity(118, { emit = emit.humidity(), scale = 100 }),

}



register_device_definition(th_excellux, {

  device_helpers.create_fingerprint("DHT0001", "Excellux"),

  device_helpers.create_fingerprint("DHTA001", "Excellux"),

  device_helpers.create_fingerprint("Excellux", "DHTA001"),

})



-- ══════════════════════════════════════════════════════════════

-- 1-5b. th_excellux_probe: Excellux 온습도 + 프로브 (modelID=Excellux)

-- Z2M: NTCHT01 (ZG-105NTH)

-- ══════════════════════════════════════════════════════════════

local th_excellux_probe = {

  tuya.dp_numeric(1, { name = "temperature_probe", emit = emit.temperatureProbeExcellux(), scale = 10 }),

  tuya.dp_battery(4, { emit = emit.battery() }),

  tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 100 }),

  tuya.dp_humidity(118, { emit = emit.humidity(), scale = 100 }),

}



register_sensor_definition({
  profile = "sensors-temp-humidity-probe-excellux-battery",
  datapoints = th_excellux_probe,
}, {

  device_helpers.create_fingerprint("NTCHT01", "Excellux"),
  device_helpers.create_fingerprint("NTCHT02", "Excellux"),
  device_helpers.create_fingerprint("NTCHT03", "Excellux"),
  device_helpers.create_fingerprint("Excellux", "ZG-106NTH"),
  device_helpers.create_fingerprint("Excellux", "EZ-L01NTH"),

})



-- ══════════════════════════════════════════════════════════════

-- 1-5c. th_temperature_battery: 온도 + 배터리 전용 (TS0201 non-TS)

-- Z2M: THS317-ET-TY

-- ══════════════════════════════════════════════════════════════

local th_temperature_battery = {

  tuya.dp_temperature(1, { emit = emit.temperature("C"), scale = 10 }),

  tuya.dp_battery(4, { emit = emit.battery() }),

}



local th_excellux_water_quality = {

  tuya.dp_numeric(1, { name = "temperature_probe", emit = emit.temperatureProbeExcellux(), scale = 10 }),

  tuya.dp_battery(4, { emit = emit.battery() }),

  tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 100 }),

  tuya.dp_numeric(101, { name = "sampling_interval" }),                  -- profile 미포함

  tuya.dp_temperature_calibration(108, { name = "probe_temperature_calibration", scale = 10 }), -- profile 미포함

  tuya.dp_numeric(109, { name = "probe_temperature_v0_set", scale = 10 }), -- profile 미포함

  tuya.dp_numeric(110, { name = "probe_temperature_v1_set", scale = 10 }), -- profile 미포함

  tuya.dp_enum(112, { name = "probe_temperature_warning" }),             -- profile 미포함

  tuya.dp_temperature_calibration(114, { name = "temperature_calibration", scale = 100 }), -- profile 미포함

  tuya.dp_numeric(115, { name = "temperature_v0_set", scale = 100 }),    -- profile 미포함

  tuya.dp_numeric(116, { name = "temperature_v1_set", scale = 100 }),    -- profile 미포함

  tuya.dp_enum(117, { name = "temperature_warning" }),                   -- profile 미포함

  tuya.dp_humidity(118, { emit = emit.humidity(), scale = 100 }),

  tuya.dp_humidity_calibration(119, { name = "humidity_calibration", scale = 100 }), -- profile 미포함

  tuya.dp_numeric(120, { name = "humidity_v0_set", scale = 100 }),       -- profile 미포함

  tuya.dp_numeric(121, { name = "humidity_v1_set", scale = 100 }),       -- profile 미포함

  tuya.dp_enum(122, { name = "humidity_warning" }),                      -- profile 미포함

  tuya.dp_numeric(124, { name = "tds" }),                                -- profile 미포함

  tuya.dp_numeric(125, { name = "tds_warning_set" }),                    -- profile 미포함

  tuya.dp_enum(126, { name = "tds_warning" }),                           -- profile 미포함

  tuya.dp_numeric(127, { name = "ec" }),                                 -- profile 미포함

  tuya.dp_numeric(128, { name = "ec_v0_set" }),                          -- profile 미포함

  tuya.dp_numeric(129, { name = "ec_v1_set" }),                          -- profile 미포함

  tuya.dp_enum(130, { name = "ec_warning" }),                            -- profile 미포함

  tuya.dp_numeric(131, { name = "salinity", scale = 10 }),               -- profile 미포함

  tuya.dp_numeric(132, { name = "specific_gravity", scale = 1000 }),     -- profile 미포함

  tuya.dp_enum(133, { name = "mode" }),                                  -- profile 미포함

}

register_sensor_definition({
  profile = "sensors-temp-humidity-probe-excellux-battery",
  datapoints = th_excellux_water_quality,
}, {

  device_helpers.create_fingerprint("DTS1XM9", "Excellux"),

})


register_device_definition(th_temperature_battery, device_helpers.create_fingerprints("TS0201", {

  "_TZE200_iq4ygaai",

  "_TZE200_01fvxamo",

}))





-- ══════════════════════════════════════════════════════════════

-- 1-6. th_alarm_neo: NAS-AB02B0 (온습도 + 전원상태)

-- Z2M: _TZE200_d0yu2xgi (NAS-AB02B0)

-- 참고: 전용 알람/멜로디/볼륨 설정은 미구현

-- ══════════════════════════════════════════════════════════════

local th_alarm_neo = {

  tuya.dp_numeric(101, {

    name = "power_type",

    emit = emit.battery(),

    converter = converter.from_only(converter.lookup_value({

      [0] = 100,

      [1] = 75,

      [2] = 50,

      [3] = 5,

      [4] = 100,

    })),

  }),

  tuya.dp_temperature(105, { emit = emit.temperature("C"), scale = 10 }),

  tuya.dp_humidity(106, { emit = emit.humidity(), scale = 1 }),

}



register_device_definition(th_alarm_neo, ef00_helpers.ts0601_fingerprints( {

  "_TZE200_d0yu2xgi",

}))



-- ══════════════════════════════════════════════════════════════

-- 1-7. th_illum: 조도 + 온도 + 습도 + 배터리

-- Z2M: _TZE200_vzqtvljm (illum_th_sensor_1)

-- ══════════════════════════════════════════════════════════════

local th_illum = {

  tuya.dp_illuminance(7, { emit = emit.illuminance() }),

  tuya.dp_temperature(8, { emit = emit.temperature("C"), scale = 10 }),

  tuya.dp_humidity(9, { emit = emit.humidity(), scale = 1 }),

  tuya.dp_battery(3, { emit = emit.battery() }),

}



register_device_definition(th_illum, ef00_helpers.ts0601_fingerprints( {

  "_TZE200_vzqtvljm",

}))



-- ══════════════════════════════════════════════════════════════

-- 1-8. th_illum_h10: 조도 + 온도 + 습도÷10 (배터리 없음)

-- Z2M: _TZE200_rbbx5mfq (illum_th_sensor_2)

-- ══════════════════════════════════════════════════════════════

local th_illum_h10 = {

  tuya.dp_illuminance(2, { emit = emit.illuminance() }),

  tuya.dp_temperature(6, { emit = emit.temperature("C"), scale = 10 }),

  tuya.dp_humidity(7, { emit = emit.humidity(), scale = 10 }),

}



register_device_definition(th_illum_h10, ef00_helpers.ts0601_fingerprints( {

  "_TZE200_rbbx5mfq",

  "_TZE204_rbbx5mfq",

}))



-- ══════════════════════════════════════════════════════════════

-- 1-9. th_2aaa_probe: 2AAA + 외부 프로브

-- Z2M: _TZE284_8se38w3c (TZ-ZT01_GA4) / _TZE284_hodyryli (ZY-ZTH03PRO)

-- ══════════════════════════════════════════════════════════════

local th_2aaa_probe = {

  tuya.dp_temperature(1, { emit = emit.temperature("C"), scale = 10 }),

  tuya.dp_humidity(2, { emit = emit.humidity(), scale = 1 }),

  tuya.dp_enum(3, { name = "battery_state", emit = emit.battery(), converter = converter.from_only(converter.lookup_value({ [0] = 0, [1] = 50, [2] = 100 })) }),

  tuya.dp_numeric(38, { name = "temperature_probe", emit = emit.temperatureProbe2aaa(), scale = 10 }),

}



register_sensor_definition({
  profile = "sensors-temp-humidity-probe-2aaa-battery",
  datapoints = th_2aaa_probe,
}, ef00_helpers.ts0601_fingerprints( {

  "_TZE284_8se38w3c",

  "_TZE284_hodyryli",

}))



-- ══════════════════════════════════════════════════════════════

return device_definitions
