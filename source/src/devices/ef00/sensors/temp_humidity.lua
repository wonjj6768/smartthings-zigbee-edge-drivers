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

local POOL_CHLORINE_KEEPALIVE_FIELD = "pool_chlorine_keepalive_timer"
local POOL_CHLORINE_KEEPALIVE_INTERVAL = 30 * 60

local schedule_pool_chlorine_keepalive

schedule_pool_chlorine_keepalive = function(device)
  local timer = device.thread:call_with_delay(POOL_CHLORINE_KEEPALIVE_INTERVAL, function()
    tuya.send_datapoint(device, 105, tuya.DP_TYPE_VALUE, 0, tuya.SET_DATA, false, 1)

    local follow_up_timer = device.thread:call_with_delay(2, function()
      tuya.send_datapoint(device, 105, tuya.DP_TYPE_VALUE, 0, tuya.SET_DATA, false, 0)
      schedule_pool_chlorine_keepalive(device)
    end, "pool chlorine backlight keepalive follow-up")

    device:set_field(POOL_CHLORINE_KEEPALIVE_FIELD, follow_up_timer, { persist = false })
  end, "pool chlorine backlight keepalive")

  device:set_field(POOL_CHLORINE_KEEPALIVE_FIELD, timer, { persist = false })
end

local function start_pool_chlorine_keepalive(device)
  if device.thread == nil or type(device.thread.call_with_delay) ~= "function" or
      type(device.get_field) ~= "function" or type(device.set_field) ~= "function" then
    return false
  end

  local previous_timer = device:get_field(POOL_CHLORINE_KEEPALIVE_FIELD)
  if previous_timer ~= nil and type(previous_timer.cancel) == "function" then
    previous_timer:cancel()
  end

  schedule_pool_chlorine_keepalive(device)
  return true
end

local TH_FORCE_TIME_FIELD = "th_force_time_update_timer"
local TH_FORCE_TIME_INTERVAL = 60 * 60

local function start_hourly_th_time_updates(device, preset)
  if device.thread == nil or type(device.thread.call_with_delay) ~= "function" or
      type(device.get_field) ~= "function" or type(device.set_field) ~= "function" then
    return false
  end

  local previous_timer = device:get_field(TH_FORCE_TIME_FIELD)
  if previous_timer ~= nil and type(previous_timer.cancel) == "function" then
    previous_timer:cancel()
  end

  local schedule_next
  schedule_next = function()
    local timer = device.thread:call_with_delay(TH_FORCE_TIME_INTERVAL, function()
      preset:send_time(device)
      schedule_next()
    end, "temperature sensor hourly time update")
    device:set_field(TH_FORCE_TIME_FIELD, timer, { persist = false })
  end

  schedule_next()
  return true
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

  profile = "sensors-temp-humidity-battery",

  tuya.dp_numeric(1, { name = "temperature", emit = emit.temperature("C"), converter = converter.tuya_unsigned_temp(10) }),

  tuya.dp_humidity(2, { emit = emit.humidity(), scale = 10 }),

  tuya.dp_battery(4, { emit = emit.battery() }),

}



register_device_definition(th_unsigned_h10, ef00_helpers.ts0601_fingerprints( {

  "_TZE200_bjawzodf",

  "_TZE200_zl1kmjqx",

}))

local th_9ern5sfh = {
  profile = "sensors-temp-humidity-battery-unit-9ern5sfh",
  datapoints = {
    tuya.dp_temperature(1, { emit = emit.temperature("C"), scale = 10 }),
    tuya.dp_humidity(2, { emit = emit.humidity(), scale = 10 }),
    tuya.dp_battery(4, { emit = emit.battery() }),
    tuya.dp_enum(9, {
      name = "temperature_unit",
      emit = emit.ern9TemperatureUnit(),
      converter = converter.lookup_from_to({ celsius = 0, fahrenheit = 1 }),
    }),
    tuya.dp_numeric(19, { name = "temperature_sensitivity", read_only = true }),
  },
}

register_sensor_definition(th_9ern5sfh, ef00_helpers.ts0601_fingerprints({
  "_TZE284_9ern5sfh",
}))



-- ══════════════════════════════════════════════════════════════

-- 1-2. th_unsigned: unsigned 온도 인코딩

-- ZHA: _TZE200_bq5c8xfe

-- ══════════════════════════════════════════════════════════════

local th_unsigned = {

  profile = "sensors-temp-humidity-battery",

  tuya.dp_numeric(1, { name = "temperature", emit = emit.temperature("C"), converter = converter.tuya_unsigned_temp(10) }),

  tuya.dp_humidity(2, { emit = emit.humidity(), scale = 1 }),

  tuya.dp_battery(4, { emit = emit.battery() }),

}



register_device_definition(th_unsigned, ef00_helpers.ts0601_fingerprints( {

  "_TZE200_bq5c8xfe",

  "_TZE200_44af8vyi",

}))

local th_qyflbnbj = {
  profile = "sensors-temp-humidity-battery-state-qyfl",
  datapoints = {
    tuya.dp_numeric(1, { name = "temperature", emit = emit.temperature("C"), converter = converter.tuya_unsigned_temp(10) }),
    tuya.dp_humidity(2, { emit = emit.humidity(), scale = 1 }),
    tuya.dp_enum(3, {
      name = "battery_state",
      emit = emit.qyflBatteryState(),
      read_only = true,
      converter = converter.from_only(converter.lookup_value({
        [0] = "low",
        [1] = "middle",
        [2] = "high",
      })),
    }),
    tuya.dp_battery(4, { emit = emit.battery() }),
  },
}

register_sensor_definition(th_qyflbnbj, ef00_helpers.ts0601_fingerprints({
  "_TZE200_qyflbnbj",
  "_TZE204_qyflbnbj",
  "_TZE284_qyflbnbj",
}))



-- ══════════════════════════════════════════════════════════════

-- 1-3. th: 기본형

-- ZHA: _TZE200_a8sdabtg / Z2M: _TZE200_t3xd7l44

-- Z2M: ZG-227Z / ZG-227ZL family includes _TZE200_a8sdabtg, _TZE200_vs0skpuc, _TZE200_ehhrv2e3

-- ══════════════════════════════════════════════════════════════

local zg227_calibration_datapoints = {
  tuya.dp_temperature(1, {
    emit = emit.temperature("C"),
    read_only = true,
    signed = true,
    converter = converter.signed_number_pair(10),
  }),
  tuya.dp_humidity(2, { emit = emit.humidity(), scale = 1, read_only = true }),
  tuya.dp_battery(4, { emit = emit.battery(), read_only = true }),
  tuya.dp_numeric(9, {
    name = "temperature_unit",
    converter = converter.lookup_from_to({ celsius = 0, fahrenheit = 1 }),
  }),
  tuya.dp_temperature_calibration(23, { emit = emit.temperatureCalibrationZg227z() }),
  tuya.dp_humidity_calibration(24, { emit = emit.humidityCalibrationZg227z() }),
}

local th_zg227zl = {
  profile = "sensors-temp-humidity-battery-calibration-zg227z",
  datapoints = zg227_calibration_datapoints,
  query_on_configure = false,
}

register_device_definition(th_zg227zl, ef00_helpers.ts0601_fingerprints({
  "_TZE200_qoy0ekbd",
  "_TZE200_znbl8dj5",
  "_TZE200_a8sdabtg",
  "_TZE200_dikkika5",
  "_TZE200_vs0skpuc",
  "_TZE200_3xfjp0ag",
  "_TZE200_ehhrv2e3",
  "_TZE200_lhqtjwax",
  "_TZE200_y8wkaq6w",
}))

local th_sensor3 = {
  profile = "sensors-temp-humidity-battery",
  datapoints = {
    tuya.dp_temperature(1, {
      emit = emit.temperature("C"),
      read_only = true,
      signed = true,
      converter = converter.signed_number_pair(10),
    }),
    tuya.dp_humidity(2, { emit = emit.humidity(), scale = 1, read_only = true }),
    tuya.dp_battery(4, { emit = emit.battery(), read_only = true }),
    tuya.dp_enum(9, {
      name = "temperature_unit",
      converter = converter.lookup_from_to({ celsius = 0, fahrenheit = 1 }),
    }),
  },
  query_on_configure = true,
  time_start = "1970",
  runtime_start = start_hourly_th_time_updates,
}

register_device_definition(th_sensor3, ef00_helpers.ts0601_fingerprints({
  "_TZE200_s1xgth2u",
  "_TZE200_t3xd7l44",
  "_TZE284_kdqrazmy",
}))

local th_nous_e6 = {
  profile = "sensors-temp-humidity-battery-sensitivity-nous-e6",
  datapoints = {
    tuya.dp_temperature(1, {
      emit = emit.temperature("C"),
      read_only = true,
      signed = true,
      converter = converter.signed_number_pair(10),
    }),
    tuya.dp_humidity(2, { emit = emit.humidity(), scale = 1, read_only = true }),
    tuya.dp_battery(4, { emit = emit.battery(), read_only = true }),
    tuya.dp_enum(9, {
      name = "temperature_unit",
      converter = converter.lookup_from_to({ celsius = 0, fahrenheit = 1 }),
    }),
    tuya.dp_numeric(10, {
      name = "max_temperature_alarm",
      signed = true,
      converter = converter.signed_number_pair(10),
    }),
    tuya.dp_numeric(11, {
      name = "min_temperature_alarm",
      signed = true,
      converter = converter.signed_number_pair(10),
    }),
    tuya.dp_numeric(12, { name = "max_humidity_alarm" }),
    tuya.dp_numeric(13, { name = "min_humidity_alarm" }),
    tuya.dp_numeric(17, { name = "temperature_report_interval" }),
    tuya.dp_numeric(19, {
      name = "temperature_sensitivity",
      converter = converter.divide_by_pair(10),
      emit = emit.nousE6TemperatureSensitivity(),
    }),
    tuya.dp_numeric(20, {
      name = "humidity_sensitivity",
      emit = emit.nousE6HumiditySensitivity(),
    }),
  },
  query_on_configure = false,
  bind_basic_on_configure = true,
  time_start = "1970",
  runtime_start = start_hourly_th_time_updates,
}

register_device_definition(th_nous_e6, ef00_helpers.ts0601_fingerprints({
  "_TZE284_wtikaxzs",
  "_TZE200_nnrfa68v",
  "_TZE200_zppcgbdj",
  "_TZE200_wtikaxzs",
}))

local th_avatto_zwsh16 = {
  profile = "sensors-temp-humidity-battery",
  datapoints = {
    tuya.dp_temperature(1, {
      emit = emit.temperature("C"),
      read_only = true,
      signed = true,
      converter = converter.signed_number_pair(10),
    }),
    tuya.dp_humidity(2, { emit = emit.humidity(), scale = 1, read_only = true }),
    tuya.dp_battery(4, { emit = emit.battery(), read_only = true }),
    tuya.dp_numeric(9, {
      name = "temperature_unit",
      converter = converter.lookup_from_to({ celsius = 0, fahrenheit = 1 }),
    }),
  },
  query_on_configure = false,
  mcu_version_request_on_configure = true,
}

register_device_definition(th_avatto_zwsh16, ef00_helpers.ts0601_fingerprints({
  "_TZE204_s139roas",
}))

local th_rsh_hs06 = {
  profile = "sensors-temp-humidity-battery-calibration-zg227z",
  datapoints = zg227_calibration_datapoints,
  query_on_configure = true,
  respond_to_mcu_version_response = true,
}

register_device_definition(th_rsh_hs06, ef00_helpers.ts0601_fingerprints({
  "_TZE200_ysm4dsb1",
}))



-- ══════════════════════════════════════════════════════════════

-- 1-3a. pool_chlorine_meter: BLE-YL01

-- Z2M exposes pool chemistry values; current ST surface keeps safe standard

-- temperature + battery and preserves the rest as non-profile DPs.

-- ══════════════════════════════════════════════════════════════

local zsn03p = {

  tuya.dp_temperature(1, {
    emit = emit.temperature("C"),
    read_only = true,
    signed = true,
    converter = converter.signed_number_pair(10),
  }),

  tuya.dp_humidity(2, { emit = emit.humidity(), scale = 1, read_only = true }),

  tuya.dp_enum(3, {
    name = "battery_state",
    emit = emit.zsn03pBatteryState(),
    read_only = true,
    converter = converter.lookup_from_to({ low = 0, medium = 1, high = 2 }),
  }),

  tuya.dp_temperature_unit(9, {
    emit = emit.zsn03pTemperatureUnit(),
    converter = converter.lookup_from_to({ celsius = 0, fahrenheit = 1 }),
  }),

  tuya.dp_temperature_calibration(23, { emit = emit.temperatureCalibrationZg227z() }),

  tuya.dp_humidity_calibration(24, { emit = emit.zsn03pHumidityCalibration() }),

}

register_sensor_definition({
  profile = "sensors-temp-humidity-battery-state-calibration-zsn03p",
  datapoints = zsn03p,
  query_on_configure = false,
}, ef00_helpers.ts0601_fingerprints( {

  "_TZE284_rjjsib2d",

}))

local pool_chlorine_meter = {

  profile = "sensors-temp-battery-pool-chlorine",

  datapoints = {

    tuya.dp_numeric(1, { name = "tds", emit = emit.tdsChlorineMeter(), read_only = true }),

    tuya.dp_temperature(2, { emit = emit.temperature("C"), scale = 10, read_only = true }),

    tuya.dp_battery(7, { emit = emit.battery(), read_only = true }),

    tuya.dp_numeric(10, {
      name = "ph",
      emit = emit.poolPhChlorineMeter(),
      converter = pool_ph_converter(),
      read_only = true,
    }),

    tuya.dp_numeric(11, { name = "ec", read_only = true }),              -- profile 미포함

    tuya.dp_numeric(101, { name = "orp", emit = emit.poolOrpChlorineMeter(), read_only = true }),

    tuya.dp_numeric(102, {
      name = "free_chlorine",
      converter = converter.divide_by_pair(10),
      emit = emit.freeChlorineChlorineMeter(),
      read_only = true,
    }),

    tuya.dp_numeric(105, { name = "backlightvalue" }),                    -- profile 미포함

    tuya.dp_numeric(106, { name = "ph_max" }),                            -- profile 미포함

    tuya.dp_numeric(107, { name = "ph_min" }),                            -- profile 미포함

    tuya.dp_numeric(108, { name = "ec_max" }),                            -- profile 미포함

    tuya.dp_numeric(109, { name = "ec_min" }),                            -- profile 미포함

    tuya.dp_numeric(110, { name = "orp_max" }),                           -- profile 미포함

    tuya.dp_numeric(111, { name = "orp_min" }),                           -- profile 미포함

    tuya.dp_numeric(112, { name = "free_chlorine_max" }),                 -- profile 미포함

    tuya.dp_numeric(113, { name = "free_chlorine_min" }),                 -- profile 미포함

    tuya.dp_numeric(117, { name = "salinity", emit = emit.salinityChlorineMeter(), read_only = true }),

  },

  query_on_configure = false,
  query_interval_seconds = 10 * 60,
  respond_to_mcu_version_response = true,
  runtime_start = start_pool_chlorine_keepalive,

}



register_device_definition(pool_chlorine_meter, ef00_helpers.ts0601_fingerprints( {

  "_TZE200_d9mzkhoq",

  "_TZE200_v1jqz5cy",

}))



-- ══════════════════════════════════════════════════════════════

-- 1-3b. heat_water_meter: ultrasonic heat/water meter

-- Keep water/heat metering DPs hidden until a dedicated water-meter surface exists.

-- ══════════════════════════════════════════════════════════════

local heat_water_meter = {

  profile = "sensors-temp-battery-heat-water-meter",

  datapoints = {

    tuya.dp_water_consumed(1, {
      read_only = true,
      emit = emit.waterConsumedHeatMeter(),
    }),

    tuya.dp_month_consumption(2, {
      name = "monthly_water_consumption",
      raw = true,
      raw_bytes = 4,
      raw_from_tail = true,
      read_only = true,
    }),                                                                    -- profile 미포함

    tuya.dp_daily_consumption(3, {
      name = "daily_water_consumption",
      raw = true,
      raw_bytes = 4,
      raw_from_tail = true,
      read_only = true,
    }),                                                                    -- profile 미포함

    tuya.dp_enum(4, {
      name = "report_period",
      converter = converter.report_period_hours(),
    }),                                                                    -- profile 미포함

    tuya.dp_numeric(5, {
      name = "fault",
      read_only = true,
      converter = converter.bitmap_flags({
        [1] = "battery_alarm",
        [2] = "magnetism_alarm",
        [4] = "cover_alarm",
        [8] = "credit_alarm",
        [16] = "switch_gaps_alarm",
        [32] = "meter_body_alarm",
        [64] = "abnormal_water_alarm",
        [128] = "arrearage_alarm",
        [256] = "overflow_alarm",
        [512] = "revflow_alarm",
        [1024] = "over_pre_alarm",
        [2048] = "empty_pip_alarm",
        [4096] = "transduce_alarm",
      }, "OK", ", "),
    }),                                                                    -- profile 미포함

    tuya.dp_binary(6, { name = "prepayment_switch" }),                     -- profile 미포함

    tuya.dp_cumulative_heat(7, { name = "cumulative_heat", read_only = true }), -- profile 미포함

    tuya.dp_meter_id(16, { read_only = true }),                             -- profile 미포함

    tuya.dp_instantaneous_flow_rate(19, {
      raw = true,
      raw_bytes = 4,
      raw_from_tail = false,
      read_only = true,
    }),                                                                    -- profile 미포함

    tuya.dp_inlet_water_temperature(21, {
      name = "temperature",
      read_only = true,
      emit = emit.temperature("C"),
    }),

    tuya.dp_outlet_water_temperature(22, {
      name = "outlet_water_temperature",
      read_only = true,
    }),                                                                    -- profile 미포함

    tuya.dp_numeric(24, {
      name = "battery_voltage",
      read_only = true,
      converter = converter.from_only(converter.multiply_by(10)),
    }),                                                                    -- profile 미포함

  },

  query_on_configure = false,

}



register_device_definition(heat_water_meter, ef00_helpers.ts0601_fingerprints( {

  "_TZE200_jt50ea5d",

}))



local ultrasonic_water_meter = {

  profile = "sensors-water-meter-ultrasonic-ajlu4cud",

  datapoints = {

    tuya.dp_water_consumed(1, {
      read_only = true,
      emit = emit.ajlu4cudWaterConsumed(),
    }),

    tuya.dp_month_consumption(2, {
      raw = true,
      raw_bytes = 4,
      raw_from_tail = true,
      read_only = true,
      emit = emit.ajlu4cudMonthConsumption(),
    }),

    tuya.dp_daily_consumption(3, {
      raw = true,
      raw_bytes = 4,
      raw_from_tail = true,
      read_only = true,
      emit = emit.ajlu4cudDailyConsumption(),
    }),

    -- Z2M lookup returns a plain number, so writes use Tuya VALUE rather than ENUM.
    tuya.dp_numeric(4, {
      name = "report_period",
      converter = converter.report_period_hours(),
      emit = emit.ajlu4cudReportPeriod(),
    }),

    tuya.dp_water_meter_faults(5, {
      read_only = true,
      emit = emit.ajlu4cudFaults(),
    }),

    tuya.dp_meter_id(16, {
      read_only = true,
      emit = emit.ajlu4cudMeterId(),
    }),

    tuya.dp_reverse_water_consumed(18, {
      raw = true,
      raw_bytes = 4,
      raw_from_tail = false,
      read_only = true,
      emit = emit.ajlu4cudReverseWaterConsumed(),
    }),

    tuya.dp_flow_rate(21, {
      raw = true,
      raw_bytes = 4,
      raw_from_tail = true,
      read_only = true,
      emit = emit.ajlu4cudFlowRate(),
    }),

    tuya.dp_temperature(22, {
      scale = 100,
      read_only = true,
      emit = emit.temperature("C"),
    }),

    -- Z2M currently divides this value by 100 but labels it mV. Keep the
    -- datapoint observable in debug logs without exposing a misleading unit.
    tuya.dp_battery_voltage(26, { name = "battery_voltage", read_only = true }),

  },

  query_on_configure = false,

}



register_device_definition(ultrasonic_water_meter, ef00_helpers.ts0601_fingerprints( {

  "_TZE284_ajlu4cud",

}))



-- ══════════════════════════════════════════════════════════════

-- 1-4. th_alarm: 알람 + 리포트

-- ZHA: _TZE200_lve3dvpy / Z2M: _TZE284_cwyqwqbf / _TZE200_whkgqxse (JM-TRH-ZGB-V1)

-- ══════════════════════════════════════════════════════════════

local function build_th_alarm_datapoints(options)
  local datapoints = {
    tuya.dp_temperature(1, {
      emit = emit.temperature("C"),
      read_only = true,
      signed = true,
      converter = converter.signed_number_pair(10),
    }),
    tuya.dp_humidity(2, { emit = emit.humidity(), scale = 1, read_only = true }),
  }

  if options.battery_state then
    datapoints[#datapoints + 1] = tuya.dp_enum(3, {
      name = "battery_state",
      emit = emit.cwyqwqbfBatteryState(),
      read_only = true,
      converter = converter.from_only(converter.lookup_value({
        [0] = "low",
        [1] = "medium",
        [2] = "high",
      })),
    })
  else
    datapoints[#datapoints + 1] = tuya.dp_battery(4, { emit = emit.battery(), read_only = true })
  end

  datapoints[#datapoints + 1] = tuya.dp_enum(9, {
    name = "temperature_unit",
    converter = converter.lookup_from_to({ celsius = 0, fahrenheit = 1 }),
  })
  datapoints[#datapoints + 1] = tuya.dp_numeric(10, {
    name = "max_temperature_alarm",
    signed = true,
    converter = converter.signed_number_pair(10),
  })
  datapoints[#datapoints + 1] = tuya.dp_numeric(11, {
    name = "min_temperature_alarm",
    signed = true,
    converter = converter.signed_number_pair(10),
  })
  datapoints[#datapoints + 1] = tuya.dp_numeric(12, { name = "max_humidity_alarm" })
  datapoints[#datapoints + 1] = tuya.dp_numeric(13, { name = "min_humidity_alarm" })
  datapoints[#datapoints + 1] = tuya.dp_enum(14, {
    name = "temperature_alarm",
    read_only = true,
    converter = options.alarm_converter,
  })
  datapoints[#datapoints + 1] = tuya.dp_enum(15, {
    name = "humidity_alarm",
    read_only = true,
    converter = options.alarm_converter,
  })

  if options.temperature_report_interval then
    datapoints[#datapoints + 1] = tuya.dp_numeric(17, { name = "temperature_report_interval" })
  end
  if options.humidity_report_interval then
    datapoints[#datapoints + 1] = tuya.dp_numeric(18, { name = "humidity_report_interval" })
  end
  if options.temperature_sensitivity_emit then
    datapoints[#datapoints + 1] = tuya.dp_numeric(19, {
      name = "temperature_sensitivity",
      converter = converter.divide_by_pair(10),
      emit = options.temperature_sensitivity_emit,
    })
  end
  if options.humidity_sensitivity_emit then
    datapoints[#datapoints + 1] = tuya.dp_numeric(20, {
      name = "humidity_sensitivity",
      emit = options.humidity_sensitivity_emit,
    })
  end

  return datapoints
end

local alarm_lower_upper_cancel = converter.lookup_from_to({
  lower_alarm = 0,
  upper_alarm = 1,
  cancel = 2,
})
local alarm_cancel_lower_upper = converter.lookup_from_to({
  canceled = 0,
  lower_alarm = 1,
  upper_alarm = 2,
})

local th_alarm_zth05z = {
  profile = "sensors-temp-humidity-battery-alarm-sensitivity-th-alarm",
  datapoints = build_th_alarm_datapoints({
    alarm_converter = alarm_lower_upper_cancel,
    temperature_report_interval = true,
    humidity_report_interval = true,
    temperature_sensitivity_emit = emit.tempSensitivityThCToOne(),
    humidity_sensitivity_emit = emit.humiditySensitivityThThreeTen(),
  }),
  query_on_configure = true,
  respond_to_mcu_version_response = true,
  time_start = "1970",
}

register_device_definition(th_alarm_zth05z, ef00_helpers.ts0601_fingerprints({
  "_TZE200_vvmbj46n",
  "_TZE284_vvmbj46n",
  "_TZE200_w6n8jeuu",
}))

local th_alarm_cwyqwqbf = {
  profile = "sensors-temp-humidity-battery-state-alarm-sensitivity-cwyqwqbf",
  datapoints = build_th_alarm_datapoints({
    battery_state = true,
    alarm_converter = alarm_lower_upper_cancel,
    temperature_report_interval = true,
    humidity_report_interval = true,
    temperature_sensitivity_emit = emit.tempSensitivityThCToOne(),
    humidity_sensitivity_emit = emit.humiditySensitivityThThreeTen(),
  }),
  query_on_configure = true,
  respond_to_mcu_version_response = true,
  time_start = "1970",
}

register_device_definition(th_alarm_cwyqwqbf, ef00_helpers.ts0601_fingerprints({
  "_TZE284_cwyqwqbf",
}))

local th_alarm_nous_szt04 = {
  profile = "sensors-temp-humidity-battery-alarm-sensitivity-nous-szt04",
  datapoints = build_th_alarm_datapoints({
    alarm_converter = alarm_lower_upper_cancel,
    temperature_report_interval = true,
    humidity_report_interval = true,
    temperature_sensitivity_emit = emit.nousSzT04TemperatureSensitivity(),
    humidity_sensitivity_emit = emit.nousSzT04HumiditySensitivity(),
  }),
  query_on_configure = false,
  bind_basic_on_configure = true,
  time_start = "1970",
  runtime_start = start_hourly_th_time_updates,
}

register_device_definition(th_alarm_nous_szt04, ef00_helpers.ts0601_fingerprints({
  "_TZE200_lve3dvpy",
  "_TZE200_c7emyjom",
  "_TZE200_locansqn",
  "_TZE200_qrztc3ev",
  "_TZE200_snloy4rw",
  "_TZE200_eanjj2pa",
  "_TZE200_ydrdfkim",
  "_TZE284_locansqn",
}))

local th_alarm_lincukoo_szt04 = {
  profile = "sensors-temp-humidity-battery-alarm-sensitivity-lincukoo-szt04",
  datapoints = build_th_alarm_datapoints({
    alarm_converter = alarm_cancel_lower_upper,
    temperature_sensitivity_emit = emit.lincukooSzt04TempSensitivity(),
    humidity_sensitivity_emit = emit.lincukooSzt04HumiditySensitivity(),
  }),
  query_on_configure = false,
  time_start = "1970",
  runtime_start = start_hourly_th_time_updates,
}

register_device_definition(th_alarm_lincukoo_szt04, ef00_helpers.ts0601_fingerprints({
  "_TZE284_rs62zxk8",
  "_TZE284_4dosadbh",
  "_TZE284_mpzuabwk",
}))

local th_alarm_jm_trh = {
  profile = "sensors-temp-humidity-battery-jm-trh",
  datapoints = build_th_alarm_datapoints({
    alarm_converter = alarm_lower_upper_cancel,
    temperature_report_interval = true,
  }),
  query_on_configure = false,
  bind_basic_on_configure = true,
  time_start = "1970",
  runtime_start = start_hourly_th_time_updates,
}

register_device_definition(th_alarm_jm_trh, ef00_helpers.ts0601_fingerprints({
  "_TZE200_whkgqxse",
}))



-- ══════════════════════════════════════════════════════════════

-- 1-5. th_2aaa: 2AAA 배터리 enum

-- ZHA: _TZE200_upagmta9 / Z2M: _TZE204_d7lpruvi

-- ══════════════════════════════════════════════════════════════

local th_2aaa = {

  profile = "sensors-temp-humidity-battery-state-unit-th2aaa",

  tuya.dp_temperature(1, { emit = emit.temperature("C"), scale = 10 }),

  tuya.dp_humidity(2, { emit = emit.humidity(), scale = 1 }),

  tuya.dp_enum(3, {
    name = "battery_state",
    emit = emit.th2aaaBatteryState(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "low",
      [1] = "middle",
      [2] = "high",
    })),
  }),

  tuya.dp_enum(9, {
    name = "temperature_unit",
    emit = emit.th2aaaTemperatureUnit(),
    converter = converter.lookup_from_to({ celsius = 0, fahrenheit = 1 }),
  }),

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

  "_TZE284_ksz749x8",

  "_TZE204_1wnh8bqp",

  "_TZE284_1wnh8bqp",

  "_TZE204_kwi6bbk4",

  "_TZE204_d7lpruvi",

  "_TZE200_d7lpruvi",

  "_TZE284_d7lpruvi",

  "_TZE284_hdyjyqjm",

}))



-- ══════════════════════════════════════════════════════════════

-- 1-5a. th_excellux: Excellux 온습도 (modelID=Excellux)

-- Z2M: DHT0001 / DHTA001

-- ══════════════════════════════════════════════════════════════

local th_excellux = {

  profile = "sensors-temp-humidity-battery-excellux-dht",

  tuya.dp_battery(4, { emit = emit.battery() }),

  tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 100 }),

  tuya.dp_numeric(101, {
    name = "sampling_interval",
    emit = emit.excelluxDhtSamplingInterval(),
  }),

  tuya.dp_numeric(114, {
    name = "temperature_calibration",
    emit = emit.excelluxDhtTemperatureCalibration(),
    signed = true,
    converter = converter.signed_number_pair(100),
  }),

  tuya.dp_numeric(115, {
    name = "temperature_v0_set",
    emit = emit.excelluxDhtTemperatureV0(),
    signed = true,
    converter = converter.signed_number_pair(100),
  }),

  tuya.dp_numeric(116, {
    name = "temperature_v1_set",
    emit = emit.excelluxDhtTemperatureV1(),
    signed = true,
    converter = converter.signed_number_pair(100),
  }),

  tuya.dp_enum(117, {
    name = "temperature_warning",
    emit = emit.excelluxDhtTemperatureWarning(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "none",
      [1] = "low",
      [2] = "high",
    })),
  }),

  tuya.dp_humidity(118, { emit = emit.humidity(), scale = 100 }),

  tuya.dp_numeric(119, {
    name = "humidity_calibration",
    emit = emit.excelluxDhtHumidityCalibration(),
    signed = true,
    converter = converter.signed_number_pair(100),
  }),

  tuya.dp_numeric(120, {
    name = "humidity_v0_set",
    emit = emit.excelluxDhtHumidityV0(),
    converter = converter.divide_by_pair(100),
  }),

  tuya.dp_numeric(121, {
    name = "humidity_v1_set",
    emit = emit.excelluxDhtHumidityV1(),
    converter = converter.divide_by_pair(100),
  }),

  tuya.dp_enum(122, {
    name = "humidity_warning",
    emit = emit.excelluxDhtHumidityWarning(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "none",
      [1] = "low",
      [2] = "high",
    })),
  }),

}



register_device_definition(th_excellux, {

  device_helpers.create_fingerprint("DHT0001", "Excellux"),

  device_helpers.create_fingerprint("DHTA001", "Excellux"),

})



-- ══════════════════════════════════════════════════════════════

-- 1-5b. th_excellux_probe: Excellux 온습도 + 프로브 (modelID=Excellux)

-- Z2M: NTCHT01 (ZG-105NTH)

-- ══════════════════════════════════════════════════════════════

local th_excellux_probe = {

  profile = "sensors-temp-humidity-probe-excellux-full",

  tuya.dp_numeric(1, {
    name = "probe_temperature",
    emit = emit.excelluxProbeTemperature(),
    converter = converter.divide_by_pair(10),
    read_only = true,
  }),

  tuya.dp_battery(4, { emit = emit.battery() }),

  tuya.dp_temperature(5, { emit = emit.temperature("C"), scale = 100 }),

  tuya.dp_numeric(101, {
    name = "sampling_interval",
    emit = emit.excelluxProbeSamplingInterval(),
  }),

  tuya.dp_numeric(108, {
    name = "probe_temperature_calibration",
    emit = emit.excelluxProbeTempCalibration(),
    signed = true,
    converter = converter.signed_number_pair(10),
  }),

  tuya.dp_numeric(109, {
    name = "probe_temperature_v0_set",
    emit = emit.excelluxProbeTemperatureV0(),
    signed = true,
    converter = converter.signed_number_pair(10),
  }),

  tuya.dp_numeric(110, {
    name = "probe_temperature_v1_set",
    emit = emit.excelluxProbeTemperatureV1(),
    signed = true,
    converter = converter.signed_number_pair(10),
  }),

  tuya.dp_enum(112, {
    name = "probe_temperature_warning",
    emit = emit.excelluxProbeTemperatureWarning(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "none",
      [1] = "low",
      [2] = "high",
    })),
  }),

  tuya.dp_numeric(114, {
    name = "temperature_calibration",
    emit = emit.excelluxProbeAirTempCalibration(),
    signed = true,
    converter = converter.signed_number_pair(100),
  }),

  tuya.dp_numeric(115, {
    name = "temperature_v0_set",
    emit = emit.excelluxProbeAirTemperatureV0(),
    signed = true,
    converter = converter.signed_number_pair(100),
  }),

  tuya.dp_numeric(116, {
    name = "temperature_v1_set",
    emit = emit.excelluxProbeAirTemperatureV1(),
    signed = true,
    converter = converter.signed_number_pair(100),
  }),

  tuya.dp_enum(117, {
    name = "temperature_warning",
    emit = emit.excelluxProbeAirTempWarning(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "none",
      [1] = "low",
      [2] = "high",
    })),
  }),

  tuya.dp_humidity(118, { emit = emit.humidity(), scale = 100 }),

  tuya.dp_numeric(119, {
    name = "humidity_calibration",
    emit = emit.excelluxProbeHumidityCalibration(),
    signed = true,
    converter = converter.signed_number_pair(100),
  }),

  tuya.dp_numeric(120, {
    name = "humidity_v0_set",
    emit = emit.excelluxProbeHumidityV0(),
    converter = converter.divide_by_pair(100),
  }),

  tuya.dp_numeric(121, {
    name = "humidity_v1_set",
    emit = emit.excelluxProbeHumidityV1(),
    converter = converter.divide_by_pair(100),
  }),

  tuya.dp_enum(122, {
    name = "humidity_warning",
    emit = emit.excelluxProbeHumidityWarning(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "none",
      [1] = "low",
      [2] = "high",
    })),
  }),

}



register_device_definition(th_excellux_probe, {

  device_helpers.create_fingerprint("NTCHT01", "Excellux"),
  device_helpers.create_fingerprint("NTCHT02", "Excellux"),
  device_helpers.create_fingerprint("NTCHT03", "Excellux"),

})



-- ══════════════════════════════════════════════════════════════

-- 1-5c. th_temperature_battery: 온도 + 배터리 전용 (TS0201 non-TS)

-- Z2M: THS317-ET-TY

-- ══════════════════════════════════════════════════════════════

local th_temperature_battery = {

  profile = "sensors-temp-battery",

  tuya.dp_temperature(1, { emit = emit.temperature("C"), scale = 10 }),

  tuya.dp_battery(4, { emit = emit.battery() }),

}



local th_excellux_water_quality = {

  tuya.dp_numeric(1, {
    name = "probe_temperature",
    emit = emit.dts1xm9ProbeTemperature(),
    read_only = true,
    signed = true,
    converter = converter.signed_number_pair(10),
  }),

  tuya.dp_battery(4, { emit = emit.battery(), read_only = true }),

  tuya.dp_temperature(5, {
    emit = emit.temperature("C"),
    read_only = true,
    signed = true,
    converter = converter.signed_number_pair(100),
  }),

  tuya.dp_numeric(101, { name = "sampling_interval", emit = emit.dts1xm9SamplingInterval() }),

  tuya.dp_numeric(108, {
    name = "probe_temperature_calibration",
    emit = emit.dts1xm9ProbeTempCalibration(),
    signed = true,
    converter = converter.signed_number_pair(10),
  }),

  tuya.dp_numeric(109, {
    name = "probe_temperature_v0_set",
    emit = emit.dts1xm9ProbeTemperatureV0(),
    signed = true,
    converter = converter.signed_number_pair(10),
  }),

  tuya.dp_numeric(110, {
    name = "probe_temperature_v1_set",
    emit = emit.dts1xm9ProbeTemperatureV1(),
    signed = true,
    converter = converter.signed_number_pair(10),
  }),

  tuya.dp_enum(112, {
    name = "probe_temperature_warning",
    emit = emit.dts1xm9ProbeTemperatureWarning(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "none",
      [1] = "low",
      [2] = "high",
    })),
  }),

  tuya.dp_numeric(114, {
    name = "temperature_calibration",
    emit = emit.dts1xm9AirTemperatureCalibration(),
    signed = true,
    converter = converter.signed_number_pair(100),
  }),

  tuya.dp_numeric(115, {
    name = "temperature_v0_set",
    emit = emit.dts1xm9AirTemperatureV0(),
    signed = true,
    converter = converter.signed_number_pair(100),
  }),

  tuya.dp_numeric(116, {
    name = "temperature_v1_set",
    emit = emit.dts1xm9AirTemperatureV1(),
    signed = true,
    converter = converter.signed_number_pair(100),
  }),

  tuya.dp_enum(117, {
    name = "temperature_warning",
    emit = emit.dts1xm9AirTemperatureWarning(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "none",
      [1] = "low",
      [2] = "high",
    })),
  }),

  tuya.dp_humidity(118, { emit = emit.humidity(), scale = 100, read_only = true }),

  tuya.dp_numeric(119, {
    name = "humidity_calibration",
    emit = emit.dts1xm9HumidityCalibration(),
    signed = true,
    converter = converter.signed_number_pair(100),
  }),

  tuya.dp_numeric(120, {
    name = "humidity_v0_set",
    emit = emit.dts1xm9HumidityV0(),
    converter = converter.divide_by_pair(100),
  }),

  tuya.dp_numeric(121, {
    name = "humidity_v1_set",
    emit = emit.dts1xm9HumidityV1(),
    converter = converter.divide_by_pair(100),
  }),

  tuya.dp_enum(122, {
    name = "humidity_warning",
    emit = emit.dts1xm9HumidityWarning(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "none",
      [1] = "low",
      [2] = "high",
    })),
  }),

  tuya.dp_numeric(124, { name = "tds", emit = emit.dts1xm9Tds(), read_only = true }),

  tuya.dp_numeric(125, { name = "tds_warning_set", emit = emit.dts1xm9TdsThreshold() }),

  tuya.dp_enum(126, {
    name = "tds_warning",
    emit = emit.dts1xm9TdsWarning(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "none",
      [1] = "high",
    })),
  }),

  tuya.dp_numeric(127, { name = "ec", emit = emit.dts1xm9Ec(), read_only = true }),

  tuya.dp_numeric(128, { name = "ec_v0_set", emit = emit.dts1xm9EcV0() }),

  tuya.dp_numeric(129, { name = "ec_v1_set", emit = emit.dts1xm9EcV1() }),

  tuya.dp_enum(130, {
    name = "ec_warning",
    emit = emit.dts1xm9EcWarning(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "none",
      [1] = "low",
      [2] = "high",
    })),
  }),

  tuya.dp_numeric(131, {
    name = "salinity",
    emit = emit.dts1xm9Salinity(),
    read_only = true,
    converter = converter.divide_by_pair(10),
  }),

  -- PENDING: Z2M exposes 1000..1100 but divides DP132 by 1000. Keep the
  -- wire mapping read-only and hidden until the intended public range is confirmed.
  tuya.dp_numeric(132, {
    name = "specific_gravity",
    read_only = true,
    converter = converter.divide_by_pair(1000),
  }),

  tuya.dp_enum(133, {
    name = "mode",
    emit = emit.dts1xm9Mode(),
    converter = converter.lookup_from_to({ freshwater = 0, seawater = 1 }),
  }),

}

register_sensor_definition({
  profile = "sensors-water-quality-excellux-dts1xm9",
  datapoints = th_excellux_water_quality,
  query_on_configure = false,
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

-- ══════════════════════════════════════════════════════════════

local neo_alarm_melody_lookup = {}
for melody = 1, 18 do
  neo_alarm_melody_lookup[tostring(melody)] = melody
end

local function neo_battery_low_from_power_type()
  local emitter = emit.neoNasAb02b0BatteryLow()
  return function(device, value, dp_info, mapping_context)
    local battery_low = value == "battery_low" and "low" or "normal"
    return emitter(device, battery_low, dp_info, mapping_context)
  end
end

local th_alarm_neo = {

  profile = "sensors-temp-humidity-alarm-neo-nas-ab02b0",
  query_on_configure = true,
  mcu_version_request_on_configure = true,

  tuya.dp_enum(101, {
    name = "power_type",
    read_only = true,
    emit = emit.all(emit.neoNasAb02b0PowerType(), neo_battery_low_from_power_type()),
    converter = converter.from_only(converter.lookup_value({
      [0] = "battery_full",
      [1] = "battery_high",
      [2] = "battery_medium",
      [3] = "battery_low",
      [4] = "usb",
    })),
  }),

  tuya.dp_enum(102, {
    name = "melody",
    emit = emit.neoNasAb02b0AlarmMelody(),
    converter = converter.lookup_from_to(neo_alarm_melody_lookup),
  }),

  tuya.dp_numeric(103, {
    name = "duration",
    emit = emit.neoNasAb02b0AlarmDuration(),
  }),

  tuya.dp_alarm(104, { emit = emit.alarm() }),

  tuya.dp_temperature(105, {
    emit = emit.temperature("C"),
    read_only = true,
    signed = true,
    converter = converter.signed_number_pair(10),
  }),

  tuya.dp_humidity(106, { emit = emit.humidity(), scale = 1, read_only = true }),

  tuya.dp_numeric(107, {
    name = "temperature_min",
    emit = emit.neoNasAb02b0TemperatureMinimum(),
    signed = true,
    converter = converter.signed_number_pair(1),
  }),

  tuya.dp_numeric(108, {
    name = "temperature_max",
    emit = emit.neoNasAb02b0TemperatureMaximum(),
    signed = true,
    converter = converter.signed_number_pair(1),
  }),

  tuya.dp_numeric(109, {
    name = "humidity_min",
    emit = emit.neoNasAb02b0HumidityMinimum(),
  }),

  tuya.dp_numeric(110, {
    name = "humidity_max",
    emit = emit.neoNasAb02b0HumidityMaximum(),
  }),

  tuya.dp_binary(112, { name = "unknown_112", read_only = true }),

  tuya.dp_binary(113, {
    name = "temperature_alarm",
    emit = emit.neoNasAb02b0TemperatureAlarm(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),

  tuya.dp_binary(114, {
    name = "humidity_alarm",
    emit = emit.neoNasAb02b0HumidityAlarm(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),

  tuya.dp_enum(115, { name = "unknown_115", read_only = true }),

  tuya.dp_enum(116, {
    name = "volume",
    emit = emit.neoNasAb02b0AlarmVolume(),
    converter = converter.lookup_from_to({ low = 2, medium = 1, high = 0 }),
  }),

}



register_device_definition(th_alarm_neo, ef00_helpers.ts0601_fingerprints( {

  "_TZE200_d0yu2xgi",

}))



-- ══════════════════════════════════════════════════════════════

-- 1-7. th_illum: 조도 + 온도 + 습도 + 배터리

-- Z2M: _TZE200_vzqtvljm (illum_th_sensor_1)

-- ══════════════════════════════════════════════════════════════

local th_illum = {

  profile = "sensors-illuminance-temp-humidity-battery",

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

  profile = "sensors-illuminance-temp-humidity",

  tuya.dp_illuminance(2, { emit = emit.illuminance() }),

  tuya.dp_temperature(6, { emit = emit.temperature("C"), scale = 10 }),

  tuya.dp_humidity(7, { emit = emit.humidity(), scale = 10 }),

}



register_device_definition(th_illum_h10, ef00_helpers.ts0601_fingerprints( {

  "_TZE200_rbbx5mfq",

  "_TZE204_rbbx5mfq",

}))



-- ══════════════════════════════════════════════════════════════

-- 1-9. TZ-ZT01_GA4 / ZT08: 2AAA + 외부 프로브

-- Z2M: _TZE284_8se38w3c (TZ-ZT01_GA4) / _TZE284_hodyryli (ZY-ZTH03PRO)

-- ══════════════════════════════════════════════════════════════

local function probe_temperature(dp, emitter)
  return tuya.dp_numeric(dp, {
    name = dp == 1 and "temperature" or "temperature_probe",
    emit = emitter,
    read_only = true,
    signed = true,
    converter = converter.signed_number_pair(10),
  })
end

local function probe_battery_state(emitter)
  return tuya.dp_enum(3, {
    name = "battery_state",
    emit = emitter,
    read_only = true,
    converter = converter.lookup_from_to({ low = 0, medium = 1, high = 2 }),
  })
end

local tzzt01 = {
  probe_temperature(1, emit.temperature("C")),
  tuya.dp_humidity(2, { emit = emit.humidity(), scale = 1, read_only = true }),
  probe_battery_state(emit.tzzt01BatteryState()),
  probe_temperature(38, emit.temperatureProbe2aaa()),
}

register_sensor_definition({
  profile = "sensors-temp-humidity-probe-battery-state-tzzt01",
  datapoints = tzzt01,
  query_on_configure = false,
}, ef00_helpers.ts0601_fingerprints({
  "_TZE284_8se38w3c",
}))

local function zt08_time_handler(device)
  local utc_time = os.time()
  local utc_as_local = os.time(os.date("!*t", utc_time))
  local local_time = utc_time + os.difftime(utc_time, utc_as_local)
  local sent = tuya.send_time(device, utc_time, local_time)

  if sent then
    device.thread:call_with_delay(0.5, function()
      tuya.send_datapoint(device, 17, tuya.DP_TYPE_BOOL, false)
    end)
  end

  return sent == true
end

local zt08 = {
  probe_temperature(1, emit.temperature("C")),
  tuya.dp_humidity(2, { emit = emit.humidity(), scale = 1, read_only = true }),
  probe_battery_state(emit.zt08BatteryState()),
  tuya.dp_enum(17, {
    name = "time_format",
    emit = emit.zt08TimeFormat(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "24h",
      [1] = "12h",
    })),
  }),
  probe_temperature(38, emit.temperatureProbe2aaa()),
}

register_sensor_definition({
  profile = "sensors-temp-humidity-probe-battery-state-clock-zt08",
  datapoints = zt08,
  query_on_configure = false,
  time_handler = zt08_time_handler,
}, ef00_helpers.ts0601_fingerprints({
  "_TZE284_hodyryli",
}))



-- ══════════════════════════════════════════════════════════════

return device_definitions
