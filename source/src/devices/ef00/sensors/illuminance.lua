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

local aaeasoll_report_interval_converter = converter.lookup_from_to({
  ["5m"] = 0,
  ["10m"] = 1,
  ["15m"] = 2,
  ["20m"] = 3,
  ["30m"] = 4,
  ["1h"] = 5,
})

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
-- 4-1. illum_standalone: 독립 조도 (배터리 없음)
-- Z2M: _TZE200_yi4jtqq1 (XFY-CGQ-ZIGB)
-- ══════════════════════════════════════════════════════════════
local illum_standalone = {
  tuya.dp_enum(1, { name = "brightness_state" }),                 -- 프로파일 미포함 (enum: low/mid/high/strong)
  tuya.dp_illuminance(2, { emit = emit.illuminance() }),
}

register_device_definition(illum_standalone, ef00_helpers.ts0601_fingerprints( {
  "_TZE200_yi4jtqq1",
  "_TZE200_khx7nnka",
  "_TZE204_khx7nnka",
}))

-- ══════════════════════════════════════════════════════════════
-- 4-2. illum_battery: 독립 조도 + 배터리
-- Z2M: _TZE200_pisltm67 (S-LUX-ZB)
-- ══════════════════════════════════════════════════════════════
local illum_battery = {
  tuya.dp_enum(1, { name = "brightness_level" }),                 -- 프로파일 미포함 (enum: LOW/MEDIUM/HIGH)
  tuya.dp_illuminance(2, { emit = emit.illuminance() }),
  tuya.dp_battery(4, { emit = emit.battery() }),
}

register_device_definition(illum_battery, ef00_helpers.ts0601_fingerprints( {
  "_TZE200_pisltm67",
}))

register_device_definition(illum_battery, {
  device_helpers.create_fingerprint("_TYST11_pisltm67", "isltm67"),
})

-- ══════════════════════════════════════════════════════════════
-- 4-2a. illum_battery_report_interval_aaeasoll: 조도 + 배터리 + 보고 주기
-- Z2M: _TZE284_aaeasoll (TZE284_aaeasoll)
-- ══════════════════════════════════════════════════════════════
local illum_battery_report_interval_aaeasoll = {
  profile = "sensors-illuminance-battery-report-interval-aaeasoll",
  datapoints = {
    tuya.dp_illuminance(2, { emit = emit.illuminance() }),
    tuya.dp_battery(4, { emit = emit.battery() }),
    tuya.dp_enum(101, {
      name = "report_interval",
      emit = emit.aaeasollReportInterval(),
      converter = aaeasoll_report_interval_converter,
    }),
  },
}

register_device_definition(illum_battery_report_interval_aaeasoll, ef00_helpers.ts0601_fingerprints( {
  "_TZE284_aaeasoll",
}))


-- ══════════════════════════════════════════════════════════════
-- 4-6. pressure_temp: 기압 + 온도
-- Z2M: _TZE204_w2vunxzm
-- ══════════════════════════════════════════════════════════════
local pressure_temp = {
  profile = "sensors-pressure-temp-display",
  datapoints = {
    tuya.dp_temperature(8, { emit = emit.temperature("C"), scale = 100 }),
    tuya.dp_numeric(101, { name = "pressure", emit = emit.atmospheric_pressure(), scale = 10 }),
    tuya.dp_numeric(102, { name = "display_brightness", emit = emit.displayBrightnessPressureLevel8() }),
  },
}

register_device_definition(pressure_temp, ef00_helpers.ts0601_fingerprints( {
  "_TZE204_w2vunxzm",
}))


return device_definitions
