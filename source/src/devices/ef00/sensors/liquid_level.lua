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


-- ══════════════════════════════════════════════════════════════
-- 2-12. liquid_level_basic: 수위 센서
-- Z2M: ME201WZ / 872WZ
-- ══════════════════════════════════════════════════════════════
local liquid_level_basic = {
  tuya.dp_enum(1, {
    name = "liquid_state",
    emit = emit.liquid_state(),
    converter = converter.from_only(converter.lookup_value({
      [0] = "normal",
      [1] = "low",
      [2] = "high",
    })),
  }),
  tuya.dp_numeric(2, { name = "liquid_depth", emit = emit.liquid_depth(), scale = 100 }),
  tuya.dp_numeric(22, { name = "liquid_level_percent", emit = emit.liquid_level_percent() }),
}

register_sensor_definition(liquid_level_basic, {
  device_helpers.create_fingerprint("_TZE204_7yyuo8sr", "TS0601"),
  device_helpers.create_fingerprint("_TZE284_kyyu8rbj", "TS0601"),
  device_helpers.create_fingerprint("Tuya", "872WZ"),
})

register_sensor_definition({
  profile = "sensors-liquid-level",
  datapoints = liquid_level_basic,
}, {
  device_helpers.create_fingerprint("_TZE200_lvkk0hdg", "TS0601"),
})

-- ══════════════════════════════════════════════════════════════
-- 4-2a. liquid_level_me202wz: ME202WZ 수위 센서
-- Z2M: _TZE284_mxujdmxo
-- ══════════════════════════════════════════════════════════════
local liquid_level_me202wz = {
  profile = "sensors-liquid-level",
  datapoints = {
    tuya.dp_enum(1, {
      name = "liquid_state",
      emit = emit.liquid_state(),
      converter = converter.from_only(converter.lookup_value({
        [0] = "normal",
        [1] = "low",
        [2] = "high",
      })),
    }),
    tuya.dp_numeric(2, { name = "liquid_depth", emit = emit.liquid_depth(), scale = 100 }),
    tuya.dp_numeric(5, { name = "power_level", scale = 10 }),              -- profile 미포함
    tuya.dp_numeric(7, { name = "max_set" }),                              -- profile 미포함
    tuya.dp_numeric(8, { name = "mini_set" }),                             -- profile 미포함
    tuya.dp_numeric(21, { name = "liquid_depth_max", scale = 100 }),       -- profile 미포함
    tuya.dp_numeric(22, { name = "liquid_level_percent", emit = emit.liquid_level_percent() }),
    tuya.dp_string(103, { name = "version" }),                             -- profile 미포함
  },
  query_on_configure = true,
}

register_sensor_definition(liquid_level_me202wz, {
  device_helpers.create_fingerprint("_TZE284_mxujdmxo", "TS0601"),
})


return device_definitions
