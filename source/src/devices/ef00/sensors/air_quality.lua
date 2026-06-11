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


local AQ_HCHO_UGM3_TO_MGM3 = 1000

local AQ_HCHO_DIV100_UGM3_TO_MGM3 = 100000



local function air_house_keeper_pm25()

  return converter.from_only(function(value)

    local numeric = tonumber(value)

    if numeric == nil then

      return nil

    end



    -- Z2M ignores out-of-range PM2.5 spikes for _TZE200/_TZE204_dwcarsat.

    if numeric > 1000 then

      return nil

    end



    return numeric

  end)

end



-- ══════════════════════════════════════════════════════════════

-- 3-1. aq: 기본형 (legacy CO2)

-- Z2M: _TZE200_8ygsuhe1 (TS0601_air_quality)

-- ══════════════════════════════════════════════════════════════

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



-- ══════════════════════════════════════════════════════════════

-- 3-2. aq_h1_v100_f100: Airbox modern (습도 raw, VOC÷100, HCHO÷100)

-- Z2M: _TZE284_8b9zpaav (TS0601_airbox)

-- ══════════════════════════════════════════════════════════════

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



-- ══════════════════════════════════════════════════════════════

-- 3-3. aq_v100_f100: PM2.5 Airbox (VOC÷100, HCHO÷100)

-- Z2M: _TZE284_it9utkro (PM2.5_airbox)

-- ══════════════════════════════════════════════════════════════

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



-- ══════════════════════════════════════════════════════════════

-- 3-4. aq_pm25: House Keeper (DP2=PM2.5, DP layout 상이)

-- Z2M: _TZE200_dwcarsat (smart_air_house_keeper)

-- ══════════════════════════════════════════════════════════════

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



-- ══════════════════════════════════════════════════════════════

-- 3-5. aq_hcho: 포름알데히드 primary (DP2=HCHO)

-- Z2M: _TZE200_mja3fuja

-- ══════════════════════════════════════════════════════════════

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



-- ══════════════════════════════════════════════════════════════

-- 3-6. aq_hcho_f100_v10: 포름알데히드 primary, HCHO÷100 + VOC÷10

-- Z2M: _TZE200_ryfmq5rl

-- ══════════════════════════════════════════════════════════════

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



-- ══════════════════════════════════════════════════════════════

-- 3-7. aq_co2: CO2 + 온습도만

-- Z2M: _TZE200_ogkdpgy2 (th_co2_sensor)

-- ══════════════════════════════════════════════════════════════

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



-- ══════════════════════════════════════════════════════════════

-- 3-7a. aq_co2_only: CO2만 지원

-- Z2M: _TZE204_ogkdpgy2 (TS0601_co2_sensor)

-- ══════════════════════════════════════════════════════════════

local aq_co2_only = {

  tuya.dp_co2(2, { emit = emit.co2() }),

}



register_sensor_definition(aq_co2_only, ef00_helpers.ts0601_fingerprints( {

  "_TZE204_ogkdpgy2",

}))



-- ══════════════════════════════════════════════════════════════

-- 3-8. aq_zr360_co2: Zorro Alert ZR360CDB / Nous E10

-- ══════════════════════════════════════════════════════════════

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
