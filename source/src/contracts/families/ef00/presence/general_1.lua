-- presence-general-1 package-owned presence family definitions.

local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local common = require "contracts.helpers.ef00_presence"
local temperature_unit = require "contracts.helpers.temperature_unit"

local converter = tuya.converter
local device_definitions, register_device_definition = common.isolated_definition_registry(device_helpers)
local function register_presence_definition(definitions_or_table, fingerprint_list, ranges)
  return common.register_presence_definition(
    register_device_definition, definitions_or_table, fingerprint_list, ranges
  )
end
local ts0601_fingerprints = common.ts0601_fingerprints
local on_off_bool_converter = common.on_off_bool_converter
local tumble_switch_converter = converter.lookup_from_to({ on = 0, off = 1 })
local radar_scene_mir_converter = converter.lookup_from_to({
  default = 0, area = 1, toilet = 2, bedroom = 3, parlour = 4, office = 5, hotel = 6,
})

local HPS_FORCE_TIME_FIELD = "hps_force_time_update_timer"
local HPS_FORCE_TIME_INTERVAL = 60 * 60
local zg204zx_temperature_binding = temperature_unit.handlers({
  field_name = "zg204zx_temperature_unit",
  capability_id = "concertmirror08464.temperatureUnitZg204zx",
  capability_attribute = "tempUnitZgTwoFour",
  capability_emitter = emit.temperatureUnitZg204zx(),
})

local function start_hourly_hps_time_updates(device, preset)
  if device.thread == nil or type(device.thread.call_with_delay) ~= "function" or
      type(device.get_field) ~= "function" or type(device.set_field) ~= "function" then
    return false
  end
  local previous_timer = device:get_field(HPS_FORCE_TIME_FIELD)
  if previous_timer ~= nil and type(previous_timer.cancel) == "function" then previous_timer:cancel() end
  local schedule_next
  schedule_next = function()
    local timer = device.thread:call_with_delay(HPS_FORCE_TIME_INTERVAL, function()
      preset:send_time(device)
      schedule_next()
    end, "HPS hourly time update")
    device:set_field(HPS_FORCE_TIME_FIELD, timer, { persist = false })
  end
  schedule_next()
  return true
end

local raw_non_zero_converter = converter.from_only(function(value)
  local number_value = tonumber(value)
  return number_value ~= nil and number_value ~= 0
end)
local msa201_presence_converter = common.msa201_presence_converter
-- 참고:
--   이 파일의 "미구현" 표시는 세 가지로 남겨둔다.
--   1) calibration / sampling interval 같은 보조 설정
--   2) motion_state / fall_down_status 같은 read-only 진단 상태
--   3) 아직 공통 의미가 불명확한 family 전용 상태/제어
--   공통 capability 의미가 불명확한 항목은 억지로 합치지 않고 보류한다.


-- 2-1. presence_basic: 기본 존재감 (배터리 + 감도, 조도 없음)

-- Z2M: _TZE284_debczeci (TS0601_human_presence / iHseno)

-- ══════════════════════════════════════════════════════════════

local presence_basic = {
  profile = "safety-presence-basic-delay-battery",
  package_group = "presence-general-1",
  datapoints = {
    tuya.dp_presence(1, { emit = emit.presence(), read_only = true }),
    tuya.dp_battery(4, { emit = emit.battery(), read_only = true }),
    tuya.dp_enum(9, {
      name = "sensitivity",
      emit = emit.ihsenoPresenceSensitivity(),
      converter = converter.lookup_from_to({ low = 0, middle = 1, high = 2 }),
    }),
    tuya.dp_enum(10, {
      name = "delay_time",
      emit = emit.ihsenoPresenceDelayTime(),
      converter = converter.lookup_from_to({ ["15s"] = 0, ["30s"] = 1, ["60s"] = 2 }),
    }),
  },
  query_on_configure = false,
}



register_presence_definition(presence_basic, ts0601_fingerprints({

  "_TZE284_debczeci",

  "_TZE284_1lvln0x6",

  "_TZE204_debczeci",

}))

-- ══════════════════════════════════════════════════════════════

-- 2-2. presence_pir24g: PIR 24GHz (배터리 + 조도)

-- Z2M: _TZE200_juzago6i (TS0601-PIR-Sensor)

-- ══════════════════════════════════════════════════════════════

local presence_pir24g = {
  profile = "safety-presence-pir24g-dedicated-illuminance-battery",
  package_group = "presence-general-1",
  datapoints = {
    tuya.dp_presence(1, { emit = emit.presence(), read_only = true }),
    tuya.dp_battery(4, { emit = emit.battery(), read_only = true }),
    tuya.dp_illuminance(12, { emit = emit.illuminance(), read_only = true }),
    tuya.dp_numeric(101, { name = "detection_distance", emit = emit.pir24gDetectionDistance() }),
    tuya.dp_numeric(103, { name = "fading_time", emit = emit.pir24gFadingTime() }),
    tuya.dp_enum(104, {
      name = "last_time",
      emit = emit.pir24gLastTime(),
      converter = converter.lookup_from_to({ pir = 0, none = 1 }),
      read_only = true,
    }),
    tuya.dp_numeric(105, {
      name = "static_detection_sensitivity",
      emit = emit.pir24gStaticSensitivity(),
    }),
    tuya.dp_numeric(106, {
      name = "motion_detection_sensitivity",
      emit = emit.pir24gMotionSensitivity(),
    }),
  },
  query_on_configure = false,
}



register_presence_definition(presence_pir24g, ts0601_fingerprints({

  "_TZE200_juzago6i",

}))

-- 2-3a. presence_model_zg204zx: HOBEIAN ZG-204ZX 24GHz + T/H
-- Z2M: _TZE200_w0ap83qu
local presence_model_zg204zx = {
  profile = "safety-presence-illuminance-temp-humidity-battery-zg204zx",
  package_group = "presence-general-1",
  datapoints = {
    tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1(), read_only = true }),
    tuya.dp_numeric(123, { name = "motion_detection_sensitivity", emit = emit.motionDetectionSensitivityZg204zx() }),
    tuya.dp_static_detection_sensitivity(2, { emit = emit.staticDetectionSensitivityZg204zx() }),
    tuya.dp_static_detection_distance(4, { name = "detection_distance", emit = emit.presenceDetectionRangeZg204zx() }),
    tuya.dp_fading_time(102, { name = "fading_time", emit = emit.presenceFadingTimeZg204zx() }),
    tuya.dp_binary(103, {
      name = "anti_interference",
      emit = emit.antiInterferenceZg204zx(),
      converter = on_off_bool_converter,
    }),
    tuya.dp_humidity_calibration(104, { emit = emit.humidityCalibrationZg204zx() }),
    tuya.dp_temperature_calibration(105, { emit = emit.temperatureCalibrationZg204zx() }),
    tuya.dp_illuminance(106, { emit = emit.illuminance(), read_only = true }),
    tuya.dp_illuminance_interval(107, { emit = emit.illuminanceIntervalZg204zx() }),
    tuya.dp_binary(108, {
      name = "indicator",
      emit = emit.indicatorZg204zx(),
      converter = on_off_bool_converter,
    }),
    tuya.dp_temperature_unit(109, {
      emit = zg204zx_temperature_binding.unit_emitter,
      converter = zg204zx_temperature_binding.converter,
    }),
    tuya.dp_battery(110, { emit = emit.battery(), read_only = true }),
    tuya.dp_temperature(111, {
      emit = zg204zx_temperature_binding.temperature_emitter,
      scale = 10,
      read_only = true,
    }),
    tuya.dp_humidity(101, { emit = emit.humidity(), read_only = true }),
  },
  query_on_configure = false,
}
register_presence_definition(presence_model_zg204zx, ts0601_fingerprints({
  "_TZE200_w0ap83qu",
  -- Z2M also matches this sensor by zigbeeModel "ZG-204ZX"; units reporting that
  -- model instead of TS0601 need the pair spelled out.
  "_TZE200_w0ap83qu:ZG-204ZX",
  "HOBEIAN:ZG-204ZX",
}))

-- ══════════════════════════════════════════════════════════════

-- 2-3b. presence_model_excellux_zg301a: PIR light presence sensor

-- Z2M: C6B7KM9 / Excellux

-- ══════════════════════════════════════════════════════════════

local presence_model_excellux_zg301a = {
  profile = "safety-presence-excellux-zg301a",
  package_group = "presence-general-1",
  datapoints = {
    tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1(), read_only = true }),
    tuya.dp_binary(13, {
      name = "light_trigger",
      emit = emit.zg301aLightTrigger(),
      converter = on_off_bool_converter,
    }),
    tuya.dp_battery(14, { emit = emit.battery(), read_only = true }),
    tuya.dp_illuminance(20, { emit = emit.illuminance(), read_only = true }),
    tuya.dp_numeric(100, { name = "bright_value", emit = emit.zg301aBrightValue() }),
    tuya.dp_numeric(101, { name = "illuminance_trig", emit = emit.zg301aIlluminanceTrigger() }),
    tuya.dp_numeric(102, { name = "presence_time", emit = emit.zg301aPresenceTime() }),
    tuya.dp_numeric(103, { name = "presence_delay", emit = emit.zg301aPresenceDelay() }),
    tuya.dp_numeric(104, { name = "detection_cycle", emit = emit.zg301aDetectionCycle() }),
  },
  query_on_configure = false,
}



register_presence_definition(presence_model_excellux_zg301a, {

  device_helpers.create_fingerprint("C6B7KM9", "Excellux"),

})

-- ══════════════════════════════════════════════════════════════

-- 2-4. presence_model_mir_he200_ty: MIR-HE200-TY (AC, 조도, 낙상 감지)

-- Z2M: _TZE200_lu01t0zl (MIR-HE200-TY)

-- ══════════════════════════════════════════════════════════════

local presence_model_mir_he200_ty = {
  profile = "safety-presence-mirhe200-illuminance-fall",
  package_group = "presence-general-1",

  tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),

  tuya.dp_numeric(2, { name = "radar_sensitivity", emit = emit.mirhe200RadarSensitivity() }),

  tuya.dp_occupancy(102, { emit = emit.occupancy(), converter = converter.true_false1() }),

  tuya.dp_illuminance(103, { emit = emit.illuminance() }),

  tuya.dp_enum(105, {
    name = "tumble_switch",
    emit = emit.mirhe200TumbleSwitch(),
    converter = tumble_switch_converter,
  }),

  tuya.dp_numeric(106, { name = "tumble_alarm_time", emit = emit.mirhe200TumbleAlarmTime() }),

  tuya.dp_enum(112, {
    name = "radar_scene",
    emit = emit.mirhe200RadarScene(),
    converter = radar_scene_mir_converter,
  }),

  tuya.dp_enum(114, {
    name = "motion_direction",
    read_only = true,
    emit = emit.mirhe200MotionDirection(),
    converter = converter.from_only(converter.lookup_value({
      [0] = "standing_still",
      [1] = "moving_forward",
      [2] = "moving_backward",
    })),
  }),

  tuya.dp_numeric(115, { name = "motion_speed", read_only = true, emit = emit.mirhe200MotionSpeed() }),

  tuya.dp_enum(116, {
    name = "fall_down_status",
    read_only = true,
    emit = emit.mirhe200FallDownStatus(),
    converter = converter.from_only(converter.lookup_value({
      [0] = "none",
      [1] = "maybe_fall",
      [2] = "fall",
    })),
  }),

  tuya.dp_numeric(117, {
    name = "static_dwell_alarm",
    read_only = true,
    emit = emit.mirhe200StaticDwellAlarm(),
  }),

  tuya.dp_numeric(118, { name = "fall_sensitivity", emit = emit.mirhe200FallSensitivity() }),

}



register_presence_definition(presence_model_mir_he200_ty, ts0601_fingerprints({

  "_TZE200_lu01t0zl",

  "_TZE200_vrfecyku",

  "_TZE200_ypprdwsl",

  "_TZE200_jkbljri7",

  "_TZE204_bvfld3xc",

}))

-- ══════════════════════════════════════════════════════════════

-- 2-6. presence_model_y1_in: Y1_IN (AC, 조도)

-- Z2M: _TZE204_bmdsp6bs (Y1_IN)

-- ══════════════════════════════════════════════════════════════

local presence_model_y1_in = {

  profile = "safety-presence-y1in-dedicated-illuminance",
  package_group = "presence-general-1",

  datapoints = {

  tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1(), read_only = true }),

  tuya.dp_fading_time(102, { emit = emit.y1inFadingTime() }),

  tuya.dp_illuminance(103, { emit = emit.illuminance(), read_only = true }),

  tuya.dp_numeric(110, { name = "keep_sensitivity", emit = emit.y1inKeepSensitivity() }),

  tuya.dp_numeric(114, { name = "trigger_sensitivity", emit = emit.y1inTriggerSensitivity() }),

  tuya.dp_numeric(182, {
    name = "target_distance",
    converter = converter.divide_by_pair(10),
    emit = emit.y1inTargetDistance(),
    read_only = true,
  }),

  },

  query_on_configure = false,

}



register_device_definition(presence_model_y1_in, ts0601_fingerprints({

  "_TZE204_bmdsp6bs",

}))

-- ══════════════════════════════════════════════════════════════

-- 2-9. presence_model_wz_m100: WZ-M100 (AC, 조도 DP103)

-- Z2M: _TZE204_laokfqwu (WZ-M100)

-- ══════════════════════════════════════════════════════════════

local presence_model_wz_m100 = {

  profile = "safety-presence-wzm100-range-delay-illuminance",
  package_group = "presence-general-1",

  datapoints = {

  tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1(), read_only = true }),

  tuya.dp_numeric(2, { name = "sensitivity", emit = emit.wzM100Sensitivity() }),

  tuya.dp_numeric(3, {
    name = "minimum_range",
    converter = converter.divide_by_pair(100),
    emit = emit.wzM100MinimumRange(),
  }),

  tuya.dp_numeric(4, {
    name = "maximum_range",
    converter = converter.divide_by_pair(100),
    emit = emit.wzM100MaximumRange(),
  }),

  tuya.dp_numeric(9, {
    name = "target_distance",
    converter = converter.divide_by_pair(100),
    emit = emit.wzM100TargetDistance(),
    read_only = true,
  }),

  tuya.dp_illuminance(103, { emit = emit.illuminance(), read_only = true }),

  tuya.dp_numeric(104, { name = "interval_time", emit = emit.wzM100IntervalTime() }),

  tuya.dp_numeric(105, {
    name = "detection_delay",
    converter = converter.divide_by_pair(10),
    emit = emit.wzM100DetectionDelay(),
  }),

  tuya.dp_numeric(106, {
    name = "fading_time",
    converter = converter.divide_by_pair(10),
    emit = emit.wzM100FadingTime(),
  }),

  },

  query_on_configure = false,

}



register_device_definition(presence_model_wz_m100, ts0601_fingerprints({

  "_TZE204_laokfqwu",

}))

-- ══════════════════════════════════════════════════════════════

-- 2-10. presence_hps: 레거시 (AC, 조도 없음)

-- Z2M: _TZE200_0u3bj3rc (TS0601_human_presence_sensor)

-- ══════════════════════════════════════════════════════════════

local presence_hps = {

  profile = "safety-presence-hps-duration-led",
  package_group = "presence-general-1",

  time_start = "1970",

  runtime_start = start_hourly_hps_time_updates,

  datapoints = {

  tuya.dp_presence(1, {
    emit = emit.presence(),
    converter = converter.true_false1(),
    read_only = true,
  }),

  tuya.dp_numeric(101, {
    name = "duration_of_attendance",
    emit = emit.hpsAttendanceDuration(),
    read_only = true,
  }),

  tuya.dp_numeric(102, {
    name = "duration_of_absence",
    emit = emit.hpsAbsenceDuration(),
    read_only = true,
  }),

  tuya.dp_binary(103, {
    name = "led_state",
    emit = emit.hpsLedState(),
    converter = on_off_bool_converter,
  }),

  },

  query_on_configure = false,

}



register_device_definition(presence_hps, ts0601_fingerprints({

  "_TZE200_0u3bj3rc",

  "_TZE200_v6ossqfy",

  "_TZE200_mx6u6l4y",

}))

-- ══════════════════════════════════════════════════════════════

-- 2-11f. presence_model_gnpflcoq: TS0601_TZE284_gnpflcoq (배터리 + 조도 + 온습도)

-- Z2M: _TZE284_gnpflcoq

-- ══════════════════════════════════════════════════════════════

local presence_model_gnpflcoq = {

  profile = "safety-presence-gnpflcoq-illuminance-temp-humidity-battery",
  package_group = "presence-general-1",

  datapoints = {

  tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false0(), read_only = true }),

  tuya.dp_numeric(2, { name = "sensitivity", emit = emit.presenceSensitivityGnpflcoq() }),

  tuya.dp_battery(4, { emit = emit.battery(), read_only = true }),

  tuya.dp_temperature(7, { emit = emit.temperature("C"), scale = 10, read_only = true }),

  tuya.dp_humidity(8, { emit = emit.humidity(), scale = 1, read_only = true }),

  tuya.dp_illuminance(11, { emit = emit.illuminance(), read_only = true }),

  tuya.dp_fading_time(102, { name = "fading_time", emit = emit.presenceFadingTimeGnpflcoq() }),

  },

  query_on_configure = false,

}



register_device_definition(presence_model_gnpflcoq, ts0601_fingerprints({

  "_TZE284_gnpflcoq",

}))

-- ══════════════════════════════════════════════════════════════

-- 1-24. pir_model_sp02_zb001: SP02-ZB001 PIR + tamper

-- Z2M: _TZE200_mgxy2d9f

-- ══════════════════════════════════════════════════════════════

local pir_model_sp02_zb001 = {

  profile = "safety-motion-tamper-battery",
  package_group = "presence-general-1",

  datapoints = {

    tuya.dp_occupancy(1, { emit = emit.motion(), converter = converter.true_false0() }),

    tuya.dp_battery(4, { emit = emit.battery() }),

    tuya.dp_binary(5, { name = "tamper", emit = emit.tamper(), converter = raw_non_zero_converter }),

  },

  query_on_configure = true,

}



register_device_definition(pir_model_sp02_zb001, ts0601_fingerprints({

  "_TZE200_mgxy2d9f",

}))

-- ══════════════════════════════════════════════════════════════

-- 2-25. presence_model_msa201z: MSA201Z 24GHz presence sensor

-- Z2M: _TZE284_ajuasrmx / _TZE200_hyhl5y36 / _TZE284_ozf4e02o

-- ══════════════════════════════════════════════════════════════

local presence_model_msa201z = {

  profile = "safety-presence-msa201-illuminance",
  package_group = "presence-general-1",

  datapoints = {

    tuya.dp_enum(1, { name = "presence", emit = emit.presence(), converter = msa201_presence_converter }),

    tuya.dp_numeric(2, { name = "trigger_distance", scale = 10, emit = emit.msa201zTriggerDistance() }),

    tuya.dp_illuminance(101, { emit = emit.illuminance() }),

    tuya.dp_numeric(102, { name = "lux_difference_value" }),              -- profile 미포함

    tuya.dp_enum(103, { name = "ai_self_learning" }),                     -- profile 미포함

    tuya.dp_enum(104, { name = "factory_reset" }),                        -- profile 미포함

    tuya.dp_enum(105, { name = "fast_setting" }),                         -- profile 미포함

    tuya.dp_numeric(106, { name = "hold_delay_time", emit = emit.msa201zHoldDelayTime() }),

    tuya.dp_indicator(107, {
      emit = emit.msa201zIndicator(),
      converter = on_off_bool_converter,
    }),

    tuya.dp_enum(108, { name = "current_status" }),                       -- profile 미포함

    tuya.dp_binary(109, { name = "enable_sensor" }),                      -- profile 미포함

    tuya.dp_enum(110, {
      name = "sensitivity",
      emit = emit.msa201zSensitivity(),
      converter = converter.lookup_from_to({ low = 0, medium = 1, high = 2 }),
    }),

    tuya.dp_binary(112, { name = "status_flip" }),                        -- profile 미포함

    tuya.dp_raw(113, { name = "interference_positions" }),                -- profile 미포함

    tuya.dp_numeric(114, {
      name = "forbidden_area",
      scale = 10,
      emit = emit.msa201zForbiddenArea(),
    }),

    tuya.dp_numeric(115, { name = "daylight_threshold" }),                -- profile 미포함

    tuya.dp_enum(116, {
      name = "sensor_mode",
      emit = emit.msa201zSensorMode(),
      converter = converter.lookup_from_to({ presence = 0, motion = 1 }),
    }),

    tuya.dp_binary(117, { name = "single_mode" }),                        -- profile 미포함

    tuya.dp_binary(118, { name = "find_device" }),                        -- profile 미포함

    tuya.dp_enum(119, { name = "lux_mode" }),                             -- profile 미포함

    tuya.dp_enum(120, { name = "lux_report_mode" }),                      -- profile 미포함

    tuya.dp_numeric(121, { name = "lux_difference_threshold" }),          -- profile 미포함

    tuya.dp_numeric(122, { name = "lux_timed_interval" }),                -- profile 미포함

    tuya.dp_binary(123, { name = "absence_circling_report" }),            -- profile 미포함

    tuya.dp_numeric(124, { name = "absence_circling_interval" }),         -- profile 미포함

    tuya.dp_enum(125, { name = "home_environment" }),                     -- profile 미포함

  },

  query_on_configure = true,

}



register_device_definition(presence_model_msa201z, ts0601_fingerprints({

  "_TZE284_ajuasrmx",

  "_TZE200_hyhl5y36",

  "_TZE284_ozf4e02o",

}))

-- ══════════════════════════════════════════════════════════════

-- 2-26. presence_model_szr07u: SZR07U 24GHz radar

-- Z2M: _TZE204_muvkrjr5

-- ══════════════════════════════════════════════════════════════

local presence_model_szr07u = {

  profile = "safety-presence-szr07u-range-delay",
  package_group = "presence-general-1",

  datapoints = {

    tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),

    tuya.dp_numeric(13, { name = "detection_range", scale = 100, emit = emit.szr07uDetectionRange() }),

    tuya.dp_numeric(16, { name = "radar_sensitivity", emit = emit.szr07uRadarSensitivity() }),

    -- Z2M reads DP19 with valueConverter.raw, so the value is already in cm.
    tuya.dp_numeric(19, {
      name = "target_distance",
      read_only = true,
      emit = emit.szr07uTargetDistance(),
    }),

    tuya.dp_indicator(101, {
      emit = emit.szr07uIndicator(),
      converter = on_off_bool_converter,
    }),

    tuya.dp_raw(102, { name = "presence_notification_toggle" }),          -- profile 미포함

    tuya.dp_numeric(103, { name = "fading_time", emit = emit.szr07uFadingTime() }),

  },

  query_on_configure = true,

}



register_device_definition(presence_model_szr07u, ts0601_fingerprints({

  "_TZE204_muvkrjr5",

}))



-- ══════════════════════════════════════════════════════════════

-- 2-27. presence_model_mtd285_zb: MTD285-ZB 24GHz mmWave

-- ══════════════════════════════════════════════════════════════

local presence_model_mtd285_zb_presence_converter = converter.from_only(function(value)
  local numeric_value = tonumber(value)
  return numeric_value ~= nil and numeric_value ~= 0
end)

-- Z2M derives two values from DP1 (tuya.ts:18498): the boolean presence flag and
-- a three-state label.  The label needs its own read-only capability.
local presence_model_mtd285_zb_state_converter = converter.from_only(function(value)
  local numeric_value = tonumber(value)
  if numeric_value == nil or numeric_value == 0 then
    return "none"
  end
  if numeric_value == 1 then
    return "presence"
  end
  return "move"
end)

local presence_model_mtd285_zb_gate_converter = converter.lookup_from_to({ disable = 0, enable = 1 })
local presence_model_mtd285_zb_debug_converter = converter.lookup_from_to({ off = 0, on = 1 })
local presence_model_mtd285_zb_led_converter = converter.lookup_from_to({ silence = 0, status = 1 })
local presence_model_mtd285_zb_judge_converter = converter.lookup_from_to({
  large_move = 0,
  small_move = 1,
  custom_move = 2,
})
local presence_model_mtd285_zb_noise_converter = converter.lookup_from_to({ start = 0, ongoing = 1, complete = 2 })
local presence_model_mtd285_zb_start_converter = converter.lookup_from_to({ start = 0 })
local presence_model_mtd285_zb_control_converter = converter.lookup_from_to({
  no_action = 0,
  restart = 1,
  reset_param = 2,
})
local presence_model_mtd285_zb_sensitivity_converter = converter.lookup_from_to({
  high = 0,
  medium = 1,
  low = 2,
  custom = 3,
})
local presence_model_mtd285_zb_scene_converter = converter.lookup_from_to({
  custom = 0,
  toilet = 1,
  kitchen = 2,
  corridor = 3,
  bedroom = 4,
  living_room = 5,
  meeting_room = 6,
})

local presence_model_mtd285_zb = {

  profile = "safety-presence-mtd285-illuminance",
  package_group = "presence-general-1",

  datapoints = {

    tuya.dp_numeric(1, {
      name = "presence",
      emit = emit.presence(),
      converter = presence_model_mtd285_zb_presence_converter,
      read_only = true,
    }),

    tuya.dp_numeric(1, {
      name = "state",
      emit = emit.mtd285State(),
      converter = presence_model_mtd285_zb_state_converter,
      read_only = true,
    }),

    tuya.dp_numeric(3, { name = "min_distance", emit = emit.mtd285MinDistance(), converter = converter.divide_by_pair(10) }),

    tuya.dp_numeric(4, { name = "max_distance", emit = emit.mtd285MaxDistance(), converter = converter.divide_by_pair(10) }),

    tuya.dp_numeric(9, {
      name = "target_distance", emit = emit.mtd285TargetDistance(),
      converter = converter.divide_by_pair(10),
      read_only = true,
    }),

    tuya.dp_enum(101, { name = "gate_enable_01", emit = emit.mtd285GateEnable01(), converter = presence_model_mtd285_zb_gate_converter }),
    tuya.dp_enum(102, { name = "gate_enable_02", emit = emit.mtd285GateEnable02(), converter = presence_model_mtd285_zb_gate_converter }),
    tuya.dp_enum(103, { name = "gate_enable_03", emit = emit.mtd285GateEnable03(), converter = presence_model_mtd285_zb_gate_converter }),
    tuya.dp_enum(104, { name = "gate_enable_04", emit = emit.mtd285GateEnable04(), converter = presence_model_mtd285_zb_gate_converter }),
    tuya.dp_enum(105, { name = "gate_enable_05", emit = emit.mtd285GateEnable05(), converter = presence_model_mtd285_zb_gate_converter }),
    tuya.dp_enum(106, { name = "gate_enable_06", emit = emit.mtd285GateEnable06(), converter = presence_model_mtd285_zb_gate_converter }),
    tuya.dp_enum(107, { name = "gate_enable_07", emit = emit.mtd285GateEnable07(), converter = presence_model_mtd285_zb_gate_converter }),
    tuya.dp_enum(108, { name = "gate_enable_08", emit = emit.mtd285GateEnable08(), converter = presence_model_mtd285_zb_gate_converter }),
    tuya.dp_enum(109, { name = "gate_enable_09", emit = emit.mtd285GateEnable09(), converter = presence_model_mtd285_zb_gate_converter }),
    tuya.dp_enum(110, { name = "gate_enable_10", emit = emit.mtd285GateEnable10(), converter = presence_model_mtd285_zb_gate_converter }),
    tuya.dp_enum(111, { name = "gate_enable_11", emit = emit.mtd285GateEnable11(), converter = presence_model_mtd285_zb_gate_converter }),

    tuya.dp_numeric(112, { name = "configuration_gate", emit = emit.mtd285ConfigurationGate() }),

    tuya.dp_numeric(113, { name = "move_threshold", emit = emit.mtd285MoveThreshold() }),

    tuya.dp_numeric(114, { name = "presence_threshold", emit = emit.mtd285PresenceThreshold() }),

    tuya.dp_numeric(115, { name = "nearest_target_gate", emit = emit.mtd285NearestTargetGate(), read_only = true }),

    tuya.dp_numeric(116, { name = "target_countdown", emit = emit.mtd285TargetCountdown(), read_only = true }),

    tuya.dp_numeric(117, {
      name = "target_velocity", emit = emit.mtd285TargetVelocity(),
      converter = converter.signed_number_pair(100),
      read_only = true,
    }),

    tuya.dp_enum(118, { name = "debug_switch", emit = emit.mtd285DebugSwitch(), converter = presence_model_mtd285_zb_debug_converter }),

    tuya.dp_enum(119, { name = "led_mode", emit = emit.mtd285LedMode(), converter = presence_model_mtd285_zb_led_converter }),

    tuya.dp_numeric(120, { name = "delay_time", emit = emit.mtd285DelayTime() }),

    tuya.dp_numeric(121, { name = "block_time", emit = emit.mtd285BlockTime(), converter = converter.divide_by_pair(10) }),

    tuya.dp_enum(122, { name = "judge_logic", emit = emit.mtd285JudgeLogic(), converter = presence_model_mtd285_zb_judge_converter }),

    tuya.dp_enum(123, {
      name = "noise_collect_status", emit = emit.mtd285NoiseCollectStatus(),
      converter = presence_model_mtd285_zb_noise_converter,
      read_only = true,
    }),

    tuya.dp_enum(123, {
      name = "start_noise_collect",
      converter = presence_model_mtd285_zb_start_converter,
      write_only = true,
    }),

    tuya.dp_enum(124, { name = "device_control", emit = emit.mtd285DeviceControl(), converter = presence_model_mtd285_zb_control_converter }),

    tuya.dp_illuminance(125, { emit = emit.illuminance(), read_only = true }),

    tuya.dp_enum(126, {
      name = "presence_sensitivity", emit = emit.mtd285PresenceSensitivity(),
      converter = presence_model_mtd285_zb_sensitivity_converter,
    }),

    tuya.dp_enum(127, {
      name = "move_sensitivity", emit = emit.mtd285MoveSensitivity(),
      converter = presence_model_mtd285_zb_sensitivity_converter,
    }),

    tuya.dp_enum(128, { name = "scene_mode", emit = emit.mtd285SceneMode(), converter = presence_model_mtd285_zb_scene_converter }),

    tuya.dp_enum(129, { name = "illuminance_report", emit = emit.mtd285IlluminanceReport(), converter = presence_model_mtd285_zb_debug_converter }),
    tuya.dp_enum(130, { name = "move_detect", emit = emit.mtd285MoveDetect(), converter = presence_model_mtd285_zb_debug_converter }),
    tuya.dp_enum(131, { name = "distance_report", emit = emit.mtd285DistanceReport(), converter = presence_model_mtd285_zb_debug_converter }),
    tuya.dp_enum(132, { name = "speed_report", emit = emit.mtd285SpeedReport(), converter = presence_model_mtd285_zb_debug_converter }),

  },

  query_on_configure = false,

}



register_device_definition(presence_model_mtd285_zb, ts0601_fingerprints({

  "_TZE284_aai5grix",

  "_TZE204_aai5grix",

}))

-- ══════════════════════════════════════════════════════════════

-- 2-28. presence_model_pj3201a: PJ3201A human presence sensor

-- ══════════════════════════════════════════════════════════════

local presence_model_pj3201a = {

  profile = "safety-presence-pj3201a-illuminance",
  package_group = "presence-general-1",

  datapoints = {

    tuya.dp_presence(104, { emit = emit.presence(), converter = converter.true_false1() }),

    tuya.dp_occupancy(112, { name = "occupancy", emit = emit.motion(), converter = converter.true_false0() }),

    tuya.dp_numeric(9, {
      name = "closest_target_distance",
      scale = 100,
      read_only = true,
      emit = emit.pj3201aClosestTargetDistance(),
    }),

    tuya.dp_numeric(101, { name = "movement_timeout", emit = emit.pj3201aMovementTimeout() }),

    tuya.dp_numeric(102, { name = "idle_timeout", emit = emit.pj3201aIdleTimeout() }),

    tuya.dp_illuminance(103, { emit = emit.illuminance(), scale = 10 }),

    tuya.dp_numeric(105, {
      name = "far_movement_sensitivity",
      emit = emit.pj3201aFarMovementSensitivity(),
    }),

    tuya.dp_numeric(110, {
      name = "near_movement_sensitivity",
      emit = emit.pj3201aNearMovementSensitivity(),
    }),

    tuya.dp_numeric(109, {
      name = "near_presence_sensitivity",
      emit = emit.pj3201aNearPresenceSensitivity(),
    }),

    tuya.dp_numeric(111, {
      name = "far_presence_sensitivity",
      emit = emit.pj3201aFarPresenceSensitivity(),
    }),

    tuya.dp_numeric(3, {
      name = "closest_detection_distance",
      scale = 100,
      emit = emit.pj3201aClosestDetectionDistance(),
    }),

    tuya.dp_numeric(4, {
      name = "largest_movement_detection_distance",
      scale = 100,
      emit = emit.pj3201aLargestMovementDistance(),
    }),

    tuya.dp_numeric(108, {
      name = "largest_presence_detection_distance",
      scale = 100,
      emit = emit.pj3201aLargestPresenceDistance(),
    }),

    -- Z2M maps DP106/DP107 with an inverted lookup: ON is wire false.
    tuya.dp_enum(106, {
      name = "restore_factory",
      emit = emit.pj3201aRestoreFactory(),
      converter = converter.lookup_from_to({ on = false, off = true }),
    }),

    tuya.dp_enum(107, {
      name = "led_indicator",
      emit = emit.pj3201aLedIndicator(),
      converter = converter.lookup_from_to({ on = false, off = true }),
    }),

  },

  query_on_configure = true,

}



register_device_definition(presence_model_pj3201a, ts0601_fingerprints({

  "_TZE204_eaulras5",

}))

-- ══════════════════════════════════════════════════════════════

-- 2-29. presence_model_nas_ps09b2: NEO NAS-PS09B2 radar presence

-- ══════════════════════════════════════════════════════════════

local presence_model_nas_ps09b2 = {

  profile = "safety-motion-nas-ps09b2",
  package_group = "presence-general-1",

  datapoints = {

    tuya.dp_occupancy(1, {
      emit = emit.motion(),
      converter = converter.true_false1(),
      read_only = true,
    }),

    tuya.dp_enum(11, {
      name = "human_motion_state",
      emit = emit.nasps09b2MotionState(),
      converter = converter.lookup_from_to({ none = 0, small = 1, large = 2 }),
      read_only = true,
    }),

    tuya.dp_numeric(12, { name = "departure_delay", emit = emit.nasps09b2DepartureDelay() }),

    tuya.dp_numeric(13, { name = "radar_range", emit = emit.nasps09b2RadarRange() }),

    tuya.dp_numeric(15, { name = "radar_sensitivity", emit = emit.nasps09b2RadarSensitivity() }),

    tuya.dp_numeric(16, { name = "presence_sensitivity", emit = emit.nasps09b2PresenceSensitivity() }),

    tuya.dp_numeric(19, {
      name = "dis_current",
      read_only = true,
      emit = emit.nasps09b2DisCurrent(),
    }),

  },

  query_on_configure = false,

}



register_device_definition(presence_model_nas_ps09b2, ts0601_fingerprints({

  "_TZE204_kyhbrfyl",

}))

-- ══════════════════════════════════════════════════════════════

-- 2-30. presence_model_rtsc11r: 5.8G presence sensor with relay

-- ══════════════════════════════════════════════════════════════

local presence_model_rtsc11r = {

  profile = "safety-presence-rtsc11r-illuminance",
  package_group = "presence-general-1",

  datapoints = {

    tuya.dp_presence(1, {
      emit = emit.presence(),
      converter = converter.true_false1(),
      read_only = true,
    }),

    tuya.dp_numeric(12, {
      name = "detection_delay",
      converter = converter.divide_by_pair(10),
      emit = emit.rtsc11rDetectionDelay(),
    }),

    -- Z2M reads DP19 raw, so the value is already in centimetres.
    tuya.dp_numeric(19, {
      name = "detection_distance",
      read_only = true,
      emit = emit.rtsc11rDetectionDistance(),
    }),

    tuya.dp_illuminance(20, { emit = emit.illuminance(), read_only = true }),

    tuya.dp_numeric(101, {
      name = "sensitivity",
      converter = converter.divide_by_pair(10),
      emit = emit.rtsc11rSensitivity(),
    }),

    tuya.dp_numeric(102, { name = "keep_time", emit = emit.rtsc11rKeepTime() }),

    tuya.dp_numeric(111, {
      name = "minimum_range",
      converter = converter.divide_by_pair(100),
      emit = emit.rtsc11rMinimumRange(),
    }),

    tuya.dp_numeric(112, {
      name = "maximum_range",
      converter = converter.divide_by_pair(100),
      emit = emit.rtsc11rMaximumRange(),
    }),

  },

  query_on_configure = false,

}



register_device_definition(presence_model_rtsc11r, ts0601_fingerprints({

  "_TZE204_mhxn2jso",

}))

-- ══════════════════════════════════════════════════════════════

-- 2-31. presence_model_rd24g01: 24GHz presence sensor

-- ══════════════════════════════════════════════════════════════

local presence_model_rd24g01 = {

  profile = "safety-presence-rd24g01-range",
  package_group = "presence-general-1",

  datapoints = {

    -- Z2M RD24G01 (tuya.ts:23480) exposes DP1 as a three-state enum rather than
    -- a boolean presence flag, and the definition was missing it entirely.
    tuya.dp_enum(1, {
      name = "presence_state",
      read_only = true,
      emit = emit.rd24g01PresenceState(),
      converter = converter.from_only(converter.lookup_value({
        [0] = "none",
        [1] = "motion",
        [2] = "stationary",
      })),
    }),

    tuya.dp_numeric(3, {
      name = "near_detection",
      scale = 100,
      emit = emit.rd24g01NearDetection(),
    }),

    tuya.dp_numeric(4, {
      name = "far_detection",
      scale = 100,
      emit = emit.rd24g01FarDetection(),
    }),

    tuya.dp_numeric(9, {
      name = "target_distance_closest",
      scale = 100,
      read_only = true,
      emit = emit.rd24g01TargetDistanceClosest(),
    }),

    tuya.dp_numeric(101, {
      name = "static_sensitivity",
      emit = emit.rd24g01StaticSensitivity(),
    }),

    tuya.dp_numeric(102, {
      name = "motion_sensitivity",
      emit = emit.rd24g01MotionSensitivity(),
    }),

  },

  query_on_configure = true,

}



register_device_definition(presence_model_rd24g01, ts0601_fingerprints({

  "_TZE204_no6qtgtl",

}))

return {
  id = "ef00.presence.general.1",
  registrations = device_definitions,
}
