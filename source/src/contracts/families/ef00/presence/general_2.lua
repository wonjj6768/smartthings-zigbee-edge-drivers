-- presence-general-2 package-owned presence family definitions.

local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local zcl = require "protocol.zcl"
local device_helpers = require "contracts.helpers.family"
local common = require "contracts.helpers.ef00_presence"
local temperature_unit = require "contracts.helpers.temperature_unit"

local converter = tuya.converter
local device_definitions, register_device_definition = common.isolated_definition_registry(device_helpers.definition_registry)
local function register_presence_definition(definitions_or_table, fingerprint_list, ranges)
  return common.register_presence_definition(
    register_device_definition, definitions_or_table, fingerprint_list, ranges
  )
end
local ts0601_fingerprints = common.ts0601_fingerprints
local on_off_bool_converter = common.on_off_bool_converter
local radar_switch_converter = on_off_bool_converter
local zis01p_on_off_converter = converter.lookup_from_to({ ON = true, OFF = false })
local motion_detection_mode_zg204zm_converter = converter.lookup_from_to({
  only_pir = 0, pir_and_radar = 1, only_radar = 2,
})
local function raw_humidity_options()
  return { emit = emit.humidity(), scale = 1 }
end

local zg204zv_temperature_binding = temperature_unit.handlers({
  field_name = "zg204zv_temperature_unit",
  capability_id = "concertmirror08464.zg204zvTemperatureUnit",
  capability_emitter = emit.zg204zvTemperatureUnit(),
})
-- ══════════════════════════════════════════════════════════════

-- 2-3. presence_model_zf24: ZF24 mmWave (AC, 조도 포함)

-- Z2M: _TZE284_pzm3wab5 (ZF24)

-- ══════════════════════════════════════════════════════════════

local presence_model_zf24 = {
  profile = "safety-presence-zf24-move-illuminance",
  package_group = "presence-general-2",
  datapoints = {
    tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1(), read_only = true }),
    tuya.dp_numeric(2, { name = "move_sensitivity", emit = emit.zf24MoveSensitivity() }),
    tuya.dp_static_detection_distance(4, {
      name = "detection_distance_max",
      emit = emit.zf24DetectionDistanceMax(),
    }),
    tuya.dp_target_distance(9, { name = "distance", read_only = true, emit = emit.zf24Distance() }),
    tuya.dp_numeric(101, { name = "presence_timeout", emit = emit.zf24PresenceTimeout() }),
    tuya.dp_illuminance(102, { emit = emit.illuminance(), read_only = true }),
    tuya.dp_numeric(103, { name = "presence_sensitivity", emit = emit.zf24PresenceSensitivity() }),
    tuya.dp_binary(104, { name = "state", emit = emit.zf24Function(), converter = on_off_bool_converter }),
    tuya.dp_binary(105, { name = "living_room", emit = emit.zf24LivingRoom(), converter = on_off_bool_converter }),
    tuya.dp_binary(106, { name = "bedroom", emit = emit.zf24Bedroom(), converter = on_off_bool_converter }),
    tuya.dp_binary(107, { name = "bathroom", emit = emit.zf24Bathroom(), converter = on_off_bool_converter }),
    tuya.dp_binary(108, { name = "sleep", emit = emit.zf24Sleep(), converter = on_off_bool_converter }),
    tuya.dp_binary(109, {
      name = "radar_switch",
      emit = emit.zf24RadarSwitch(),
      converter = radar_switch_converter,
    }),
  },
  query_on_configure = false,
}



register_presence_definition(presence_model_zf24, ts0601_fingerprints({

  "_TZE284_pzm3wab5",

  "_TZE284_twybxdzl",

  "_TZE284_hgeqeyuv",

  "_TZE28C1000000_hgeqeyuv",

  "_TZE28C1000000_pzm3wab5",

  "_TZE28C1000000_twybxdzl",

}))

-- ══════════════════════════════════════════════════════════════

-- 2-3c. presence_model_zd24: ZD24 PIR 24GHz human presence sensor

-- Z2M: _TZE284_bw4ayyeh

-- ══════════════════════════════════════════════════════════════




























































































































local presence_model_zd24 = {

  profile = "safety-presence-zd24-illuminance-battery",
  package_group = "presence-general-2",

  datapoints = {

    tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),

    -- Z2M ZD24 (tuya.ts:14896) reads DP4 raw; the value is already in metres.
    tuya.dp_numeric(4, { name = "distance", read_only = true, emit = emit.zd24Distance() }),

    tuya.dp_enum(11, {
      name = "motion_state",
      read_only = true,
      emit = emit.zd24MotionState(),
      converter = converter.from_only(converter.lookup_value({
        [0] = "none",
        [1] = "static",
        [2] = "small",
        [3] = "large",
      })),
    }),

    tuya.dp_numeric(12, { name = "fading_time", emit = emit.zd24FadingTime() }),

    tuya.dp_numeric(15, {
      name = "motion_detection_sensitivity",
      emit = emit.zd24MotionSensitivity(),
    }),

    tuya.dp_numeric(16, {
      name = "static_detection_sensitivity",
      emit = emit.zd24StaticSensitivity(),
    }),

    tuya.dp_illuminance(20, { emit = emit.illuminance() }),

    tuya.dp_battery(81, { emit = emit.battery() }),

    tuya.dp_on_off(101, {
      name = "init",
      emit = emit.zd24Init(),
      converter = on_off_bool_converter,
    }),

    -- Z2M maps DP102 with valueConverter.raw, so the wire value is the enum index.
    tuya.dp_enum(102, {
      name = "motion_detection_mode",
      emit = emit.zd24MotionDetectionMode(),
      converter = converter.lookup_from_to({
        pir_and_radar = 0,
        only_radar = 1,
        pir_or_radar = 2,
      }),
    }),

  },

  query_on_configure = true,

}



register_presence_definition(presence_model_zd24, device_helpers.create_fingerprints("TS0601", {

  "_TZE284_bw4ayyeh",

  "_TZE2841000000_bw4ayyeh",

}))

-- ══════════════════════════════════════════════════════════════

-- 2-5. presence_model_zy_m100_l: ZY-M100-L (AC, 조도, 레거시)

-- Z2M: _TZE200_ikvncluo (TS0601_smart_human_presence_sensor_1)

-- ══════════════════════════════════════════════════════════════

local presence_model_zy_m100_l = {
  profile = "safety-presence-zym100l-fixed-illuminance",
  package_group = "presence-general-2",

  tuya.dp_presence(1, { emit = emit.presence() }),

  tuya.dp_numeric(2, { name = "presence_sensitivity", emit = emit.presenceSensitivityZym100l() }),

  tuya.dp_numeric(3, { name = "minimum_range", scale = 100, emit = emit.minimumRangeZym100l() }),

  tuya.dp_numeric(4, { name = "presence_detection_range", scale = 100, emit = emit.presenceDetectionRangeZym100l() }),

  -- Z2M exposes DP6 as a read-only six-value diagnostic result
  -- (legacy.ts tuyaHPSCheckingResult), not a writable on/off switch.
  tuya.dp_enum(6, {
    name = "self_test",
    read_only = true,
    emit = emit.zym100lSelfTest(),
    converter = converter.from_only(converter.lookup_value({
      [0] = "checking",
      [1] = "check_success",
      [2] = "check_failure",
      [3] = "others",
      [4] = "comm_fault",
      [5] = "radar_fault",
    })),
  }),

  tuya.dp_numeric(9, { name = "presence_target_distance", scale = 100, emit = emit.presenceTargetDistanceZym100l() }),

  tuya.dp_numeric(101, { name = "detection_delay", scale = 10, emit = emit.detectionDelayZym100l() }),

  tuya.dp_numeric(102, { name = "presence_fading_time", scale = 10, emit = emit.presenceFadingTimeZym100l() }),

  tuya.dp_illuminance(104, { emit = emit.illuminance() }),

}



register_presence_definition(presence_model_zy_m100_l, ts0601_fingerprints({

  "_TZE200_ikvncluo",

  "_TZE200_lyetpprm",

  "_TZE200_jva8ink8",

  "_TZE204_xpq2rzhq",

  "_TZE200_holel4dk",

  "_TZE200_xpq2rzhq",

  "_TZE200_wukb7rhc",

  "_TZE204_xsm7l9xa",

  "_TZE204_ztc6ggyl",

  "_TZE200_ztc6ggyl",

  "_TZE200_sgpeacqp",

  "_TZE204_fwondbzy",

  "_TZE284_fwondbzy",

  "_TZE284_xpq2rzhq",

}))



register_presence_definition(presence_model_zy_m100_l, {

  device_helpers.create_fingerprint("Tuya", "ZY-M100-L"),

  device_helpers.create_fingerprint("Moes", "ZSS-QY-HP"),

})

-- ══════════════════════════════════════════════════════════════

-- 2-7. presence_model_zy_m100_s_1: ZY-M100-S_1 (AC, 조도 DP104)

-- Z2M: _TZE204_sxm7l9xa (ZY-M100-S_1)

-- ══════════════════════════════════════════════════════════════

local presence_model_zy_m100_s_1 = {
  profile = "safety-presence-zym100s1-range-illuminance",
  package_group = "presence-general-2",

  tuya.dp_illuminance(104, { emit = emit.illuminance() }),

  tuya.dp_presence(105, { emit = emit.presence(), converter = converter.true_false1() }),

  tuya.dp_numeric(106, { name = "radar_sensitivity", emit = emit.zym100s1RadarSensitivity() }),

  tuya.dp_numeric(107, { name = "maximum_range", scale = 100, emit = emit.zym100s1MaximumRange() }),

  tuya.dp_numeric(108, { name = "minimum_range", scale = 100, emit = emit.zym100s1MinimumRange() }),

  tuya.dp_numeric(109, {
    name = "target_distance",
    scale = 100,
    read_only = true,
    emit = emit.zym100s1TargetDistance(),
  }),

  tuya.dp_numeric(110, { name = "fading_time", scale = 10, emit = emit.zym100s1FadingTime() }),

  tuya.dp_numeric(111, { name = "detection_delay", scale = 10, emit = emit.zym100s1DetectionDelay() }),

}



register_presence_definition(presence_model_zy_m100_s_1, ts0601_fingerprints({

  "_TZE204_sxm7l9xa",

  "_TZE204_e5m9c5hl",

}))



register_presence_definition(presence_model_zy_m100_s_1, {

  device_helpers.create_fingerprint("Wenzhi", "WZ-M100-W"),

})

-- ══════════════════════════════════════════════════════════════

-- 2-8. presence_model_zy_m100_s_2: ZY-M100-S_2 (AC, 조도 DP104)

-- Z2M: _TZE204_qasjif9e (ZY-M100-S_2)

-- ══════════════════════════════════════════════════════════════

local presence_model_zy_m100_s_2 = {
  profile = "safety-presence-zym100s2-range-illuminance",
  package_group = "presence-general-2",

  tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),

  tuya.dp_numeric(2, { name = "radar_sensitivity", emit = emit.zym100s2RadarSensitivity() }),

  tuya.dp_numeric(3, { name = "minimum_range", scale = 100, emit = emit.zym100s2MinimumRange() }),

  tuya.dp_numeric(4, { name = "maximum_range", scale = 100, emit = emit.zym100s2MaximumRange() }),

  tuya.dp_numeric(9, {
    name = "target_distance",
    scale = 100,
    read_only = true,
    emit = emit.zym100s2TargetDistance(),
  }),

  tuya.dp_numeric(101, { name = "detection_delay", scale = 10, emit = emit.zym100s2DetectionDelay() }),

  tuya.dp_numeric(102, { name = "fading_time", scale = 10, emit = emit.zym100s2FadingTime() }),

  tuya.dp_illuminance(104, { emit = emit.illuminance() }),

}



register_presence_definition(presence_model_zy_m100_s_2, ts0601_fingerprints({

  "_TZE204_qasjif9e",

  "_TZE200_qasjif9e",

  "_TZE204_ztqnh5cg",

  "_TZE204_iadro9bf",

}))



register_presence_definition(presence_model_zy_m100_s_2, {

  device_helpers.create_fingerprint("iHseno", "TY_24G_Sensor_V2"),

})

-- Z2M ZY-M100-S_2 (tuya.ts:13894) branches on manufacturerName: _TZE284_iadro9bf
-- reports presence with trueFalse0 instead of trueFalse1 and puts illuminance on
-- DP12 rather than DP104, so it cannot share the definition above.
local presence_model_zy_m100_s_2_iadro9bf = {
  profile = "safety-presence-zym100s2-range-illuminance",
  package_group = "presence-general-2",

  tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false0() }),

  tuya.dp_numeric(2, { name = "radar_sensitivity", emit = emit.zym100s2RadarSensitivity() }),

  tuya.dp_numeric(3, { name = "minimum_range", scale = 100, emit = emit.zym100s2MinimumRange() }),

  tuya.dp_numeric(4, { name = "maximum_range", scale = 100, emit = emit.zym100s2MaximumRange() }),

  tuya.dp_numeric(9, {
    name = "target_distance",
    scale = 100,
    read_only = true,
    emit = emit.zym100s2TargetDistance(),
  }),

  tuya.dp_illuminance(12, { emit = emit.illuminance() }),

  tuya.dp_numeric(101, { name = "detection_delay", scale = 10, emit = emit.zym100s2DetectionDelay() }),

  tuya.dp_numeric(102, { name = "fading_time", scale = 10, emit = emit.zym100s2FadingTime() }),

}

register_presence_definition(presence_model_zy_m100_s_2_iadro9bf, ts0601_fingerprints({

  "_TZE284_iadro9bf",

}))

-- ══════════════════════════════════════════════════════════════

-- 2-10a. presence_model_zy_hps01: ZY_HPS01 5.8GHz mmWave

-- ══════════════════════════════════════════════════════════════

local presence_model_zy_hps01 = {

  tuya.dp_illuminance(12, { emit = emit.illuminance() }),

  -- Z2M ZY_HPS01 (tuya.ts:22335-22404) reports DP101 as occupancy, and every range
  -- datapoint is a raw centimetre value rather than a /100 metre reading.
  tuya.dp_occupancy(101, { emit = emit.occupancy(), converter = converter.true_false0() }),

  tuya.dp_numeric(104, { name = "presence_timeout", emit = emit.zyhps01PresenceTimeout() }),

  tuya.dp_numeric(105, { name = "move_sensitivity", emit = emit.zyhps01MoveSensitivity() }),

  tuya.dp_numeric(107, { name = "breath_sensitivity", emit = emit.zyhps01BreathSensitivity() }),

  tuya.dp_numeric(109, { name = "move_maximum_range", emit = emit.zyhps01MoveMaximumRange() }),

  tuya.dp_numeric(110, { name = "move_minimum_range", emit = emit.zyhps01MoveMinimumRange() }),

  tuya.dp_numeric(111, { name = "breath_maximum_range", emit = emit.zyhps01BreathMaximumRange() }),

  tuya.dp_numeric(112, { name = "breath_minimum_range", emit = emit.zyhps01BreathMinimumRange() }),

}



local presence_model_zy_hps01_entry = {

  profile = "safety-presence-zy-hps01-illuminance",
  package_group = "presence-general-2",

  datapoints = presence_model_zy_hps01,

  query_on_configure = true,

}



register_device_definition(presence_model_zy_hps01_entry, ts0601_fingerprints({

  "_TZE204_ex3rcdha",

  "_TZE204_lbbg34rj",

}))



register_device_definition(presence_model_zy_hps01_entry, {

  device_helpers.create_fingerprint("Nova Digital", "ZTS-MM"),

})

-- ══════════════════════════════════════════════════════════════

-- 2-11. presence_model_zg_204zm: ZG-204ZM (배터리 + 조도 + PIR/레이더 모드)

-- Z2M: _TZE200_kb5noeto (ZG-204ZM)

-- ══════════════════════════════════════════════════════════════

local presence_model_zg_204zm = {
  profile = "safety-presence-zg204zm-illuminance-battery",
  package_group = "presence-general-2",

  tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),

  tuya.dp_static_detection_sensitivity(2, { emit = emit.zg204zmStaticSensitivity() }),

  tuya.dp_static_detection_distance(4, {
    name = "static_detection_distance",
    emit = emit.zg204zmStaticDistance(),
  }),

  tuya.dp_motion_state(101, {
    read_only = true,
    emit = emit.zg204zmMotionState(),
    converter = converter.from_only(converter.lookup_value({
      [0] = "none",
      [1] = "large",
      [2] = "small",
      [3] = "static",
    })),
  }),

  tuya.dp_fading_time(102, { emit = emit.zg204zmFadingTime() }),

  tuya.dp_illuminance(106, { emit = emit.illuminance() }),

  tuya.dp_indicator(107, {
    emit = emit.zg204zmIndicator(),
    converter = on_off_bool_converter,
  }),

  tuya.dp_battery(121, { emit = emit.battery() }),

  tuya.dp_motion_detection_mode(122, {
    emit = emit.zg204zmMotionDetectionMode(),
    converter = motion_detection_mode_zg204zm_converter,
  }),

  tuya.dp_motion_detection_sensitivity(123, { emit = emit.zg204zmMotionSensitivity() }),

}

-- Z2M notes this model reports illuminance over the standard ZCL cluster in
-- addition to DP106 (Koenkk/zigbee-herdsman-converters#10897), so both paths
-- feed the same capability.
presence_model_zg_204zm.zcl_clusters = {
  zcl.illuminance({ configure_reporting = false, read_only = true }),
}



register_presence_definition(presence_model_zg_204zm, {

  device_helpers.create_fingerprint("AOYAN", "AY205Z"),

  device_helpers.create_fingerprint("_TZE200_2aaelwxk", "TS0601"),

  device_helpers.create_fingerprint("_TZE200_kb5noeto", "TS0601"),

  device_helpers.create_fingerprint("_TZE200_tyffvoij", "TS0601"),

  device_helpers.create_fingerprint("_TZE200_yflzeeqj", "TS0601"),

})

-- ══════════════════════════════════════════════════════════════

-- 2-11a. presence_model_zg_204zk: ZG-204ZK (배터리 + 조도)

-- Z2M: _TZE200_ka8l86iu / _TZE200_zbfmvj13

-- ══════════════════════════════════════════════════════════════

local presence_model_zg_204zk = {
  profile = "safety-presence-zg204zk-battery",
  package_group = "presence-general-2",

  tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),

  tuya.dp_static_detection_sensitivity(2, { emit = emit.zg204zkStaticSensitivity() }),

  tuya.dp_static_detection_distance(4, {
    name = "detection_distance",
    emit = emit.zg204zkDetectionDistance(),
  }),

  tuya.dp_fading_time(102, { emit = emit.zg204zkFadingTime() }),

  -- Z2M ZG-204ZK has no illuminance expose, so DP106 stays internal.
  tuya.dp_illuminance(106, {}),

  tuya.dp_indicator(107, {
    emit = emit.zg204zkIndicator(),
    converter = on_off_bool_converter,
  }),

  tuya.dp_battery(121, { emit = emit.battery() }),

  tuya.dp_binary(122, {
    name = "anti_interference",
    emit = emit.zg204zkAntiInterference(),
    converter = on_off_bool_converter,
  }),

  tuya.dp_motion_detection_sensitivity(123, { emit = emit.zg204zkMotionSensitivity() }),

}



register_presence_definition(presence_model_zg_204zk, {

  device_helpers.create_fingerprint("_TZE200_ka8l86iu", "TS0601"),

  device_helpers.create_fingerprint("_TZE200_zbfmvj13", "TS0601"),

  device_helpers.create_fingerprint("HOBEIAN", "ZG-204ZK"),

})

-- ══════════════════════════════════════════════════════════════

-- 2-11b. presence_model_zg_204ze: ZG-204ZE (배터리 + 조도)

-- Z2M: ZG-204ZE / _TZE200_cq8lu23i / _TZE200_4pm4pekt

-- ══════════════════════════════════════════════════════════════

local presence_model_zg_204ze = {
  profile = "safety-presence-zg204ze-illuminance-battery",
  package_group = "presence-general-2",

  tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),

  tuya.dp_motion_detection_sensitivity(2, { emit = emit.zg204zeMotionSensitivity() }),

  tuya.dp_fading_time(102, { emit = emit.zg204zeFadingTime() }),

  tuya.dp_illuminance(106, { emit = emit.illuminance() }),

  tuya.dp_illuminance_interval(107, { emit = emit.zg204zeIlluminanceInterval() }),

  tuya.dp_indicator(108, {
    emit = emit.zg204zeIndicator(),
    converter = on_off_bool_converter,
  }),

  tuya.dp_battery(110, { emit = emit.battery() }),

}



register_presence_definition(presence_model_zg_204ze, {

  device_helpers.create_fingerprint("ZG-204ZE", "CK-BL702-MWS-01(7016)"),

  device_helpers.create_fingerprint("_TZE200_cq8lu23i", "TS0601"),

  device_helpers.create_fingerprint("_TZE200_4pm4pekt", "TS0601"),

  -- Z2M lists _TZE200_y8jijhba under ZG-204ZE (tuya.ts:24769), not ZG-204ZV.
  device_helpers.create_fingerprint("_TZE200_y8jijhba", "TS0601"),

  device_helpers.create_fingerprint("HOBEIAN", "ZG-204ZE"),

})

-- ══════════════════════════════════════════════════════════════

-- 2-11c. presence_model_zg_204zv: ZG-204ZV (배터리 + 조도 + 온습도)

-- Z2M: _TZE200_uli8wasj / _TZE200_grgol3xp / _TZE200_rhgsbacq / _TZE200_y8jijhba

-- ══════════════════════════════════════════════════════════════

local presence_model_zg_204zv = {
  profile = "safety-presence-zg204zv-illuminance-temp-humidity-battery",
  package_group = "presence-general-2",

  tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),

  tuya.dp_motion_detection_sensitivity(2, { emit = emit.zg204zvMotionSensitivity() }),

  tuya.dp_humidity(101, raw_humidity_options()),

  tuya.dp_fading_time(102, { emit = emit.zg204zvFadingTime() }),

  tuya.dp_humidity_calibration(104, { emit = emit.zg204zvHumidityCalibration() }),

  tuya.dp_temperature_calibration(105, { emit = emit.zg204zvTemperatureCalibration() }),

  tuya.dp_illuminance(106, { emit = emit.illuminance() }),

  tuya.dp_illuminance_interval(107, { emit = emit.zg204zvIlluminanceInterval() }),

  tuya.dp_indicator(108, {
    emit = emit.zg204zvIndicator(),
    converter = on_off_bool_converter,
  }),

  tuya.dp_temperature_unit(109, {
    emit = zg204zv_temperature_binding.unit_emitter,
    converter = zg204zv_temperature_binding.converter,
  }),

  tuya.dp_battery(110, { emit = emit.battery() }),

  tuya.dp_temperature(111, {
    emit = zg204zv_temperature_binding.temperature_emitter,
    read_only = true,
  }),

}



local presence_model_zg_204zv_fingerprints = ts0601_fingerprints({

  "_TZE200_uli8wasj",

  "_TZE200_grgol3xp",

  "_TZE200_rhgsbacq",

  "HOBEIAN:ZG-204ZV",

})

-- Z2M AY204T is a white-label of ZG-204ZV. Keep the two trailing spaces in
-- the manufacturer string; create_fingerprints() must not normalize it.
presence_model_zg_204zv_fingerprints[#presence_model_zg_204zv_fingerprints + 1] = {
  manufacturer = "AOYAN  ",
  model = "AY204T",
}
register_presence_definition(presence_model_zg_204zv, presence_model_zg_204zv_fingerprints)

-- ══════════════════════════════════════════════════════════════

-- 2-11d. presence_model_zg_204zh: ZG-204ZH (배터리 + 조도 + 온습도 + 상태)

-- Z2M: _TZE200_vuqzj1ej / _TZE200_hdih4foa

-- ══════════════════════════════════════════════════════════════

local presence_model_zg_204zh = {
  profile = "safety-presence-zg204zh-illuminance-temp-humidity-battery",
  package_group = "presence-general-2",

  tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),

  tuya.dp_static_detection_sensitivity(2, { emit = emit.zg204zhStaticSensitivity() }),

  tuya.dp_numeric(4, {
    name = "static_detection_distance",
    scale = 100,
    emit = emit.zg204zhStaticDistance(),
  }),

  tuya.dp_humidity(101, raw_humidity_options()),

  tuya.dp_fading_time(102, { emit = emit.zg204zhFadingTime() }),

  tuya.dp_enum(103, {
    name = "motion_state",
    read_only = true,
    emit = emit.zg204zhMotionState(),
    converter = converter.from_only(converter.lookup_value({
      [0] = "none",
      [1] = "large",
      [2] = "small",
      [3] = "static",
    })),
  }),

  tuya.dp_humidity_calibration(104, { emit = emit.zg204zhHumidityCalibration() }),

  tuya.dp_temperature_calibration(105, { emit = emit.zg204zhTemperatureCalibration() }),

  tuya.dp_illuminance(106, { emit = emit.illuminance() }),

  tuya.dp_illuminance_interval(107, { emit = emit.zg204zhIlluminanceInterval() }),

  tuya.dp_indicator(108, {
    emit = emit.zg204zhIndicator(),
    converter = on_off_bool_converter,
  }),

  tuya.dp_temperature_unit(109, { emit = emit.zg204zhTemperatureUnit() }),

  tuya.dp_battery(110, { emit = emit.battery() }),

  tuya.dp_temperature(111, { emit = emit.temperature() }),

  tuya.dp_motion_detection_mode(112, { emit = emit.zg204zhMotionDetectionMode() }),

  tuya.dp_motion_detection_sensitivity(123, { emit = emit.zg204zhMotionSensitivity() }),

}



register_presence_definition(presence_model_zg_204zh, ts0601_fingerprints({

  "_TZE200_vuqzj1ej",

  "_TZE200_hdih4foa",

  "AOYAN:AY208Z",

  "HOBEIAN:ZG-204ZH",

}))

-- ══════════════════════════════════════════════════════════════

-- 2-11e. presence_model_zg_204zq: ZG-204ZQ (배터리 + 조도 + 온습도)

-- Z2M: _TZE200_p9zbdqgs

-- ══════════════════════════════════════════════════════════════

local presence_model_zg_204zq = {

  profile = "safety-presence-zg204zq-illuminance-temp-humidity-battery",
  package_group = "presence-general-2",

  datapoints = {

  tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1(), read_only = true }),

  tuya.dp_humidity(101, { emit = emit.humidity(), scale = 1, read_only = true }),

  tuya.dp_fading_time(102, { emit = emit.zg204zqFadingTime() }),

  tuya.dp_humidity_calibration(104, { emit = emit.zg204zqHumidityCalibration() }),

  tuya.dp_temperature_calibration(105, { emit = emit.zg204zqTemperatureCalibration() }),

  tuya.dp_illuminance(106, { emit = emit.illuminance(), read_only = true }),

  tuya.dp_illuminance_interval(107, { emit = emit.zg204zqIlluminanceInterval() }),

  tuya.dp_indicator(108, { emit = emit.zg204zqIndicator(), converter = on_off_bool_converter }),

  tuya.dp_temperature_unit(109, {
    emit = emit.zg204zqTemperatureUnit(),
    converter = converter.lookup_from_to({ celsius = 0, fahrenheit = 1 }),
  }),

  tuya.dp_battery(110, { emit = emit.battery(), read_only = true }),

  tuya.dp_temperature(111, {
    emit = emit.temperature("C"),
    converter = converter.signed_number_pair(10),
    signed = true,
    read_only = true,
  }),

  },

  query_on_configure = false,

}



register_device_definition(presence_model_zg_204zq, ts0601_fingerprints({

  "_TZE200_p9zbdqgs",

}))

-- ══════════════════════════════════════════════════════════════

-- 2-24. presence_model_zis_01p: ZIS-01P dual-tech PIR + radar

-- Z2M: _TZE284_vceqncho / _TZE284_who1jxwd

-- ══════════════════════════════════════════════════════════════

local presence_model_zis_01p = {

  profile = "safety-presence-zis01p-illuminance-battery",
  package_group = "presence-general-2",

  datapoints = {

    tuya.dp_occupancy(1, {
      emit = emit.motion(),
      converter = converter.true_false1(),
      read_only = true,
    }),

    tuya.dp_numeric(101, { name = "radar_delay", read_only = true }),

    tuya.dp_numeric(102, {
      name = "presence_distance",
      emit = emit.zis01pPresenceDistance(),
    }),

    tuya.dp_numeric(103, {
      name = "presence_sensitivity",
      emit = emit.zis01pPresenceSensitivity(),
    }),

    tuya.dp_binary(104, {
      name = "radar_switch",
      emit = emit.zis01pRadarSwitch(),
      converter = zis01p_on_off_converter,
    }),

    tuya.dp_numeric(105, {
      name = "pir_sensitivity",
      emit = emit.zis01pPirSensitivity(),
    }),

    tuya.dp_numeric(106, {
      name = "delay_time",
      emit = emit.zis01pDelayTime(),
    }),

    tuya.dp_binary(107, {
      name = "led_switch",
      emit = emit.zis01pLedSwitch(),
      converter = zis01p_on_off_converter,
    }),

    tuya.dp_illuminance(108, { emit = emit.illuminance(), read_only = true }),

    tuya.dp_battery(109, { emit = emit.battery(), read_only = true }),

    tuya.dp_numeric(160, { name = "pir_threshold", emit = emit.zis01pPirThreshold() }),

    tuya.dp_numeric(161, { name = "pir_trigger_pulses", read_only = true }),

    tuya.dp_numeric(162, { name = "pir_trigger_time", read_only = true }),

    tuya.dp_numeric(163, { name = "pir_lock_time", read_only = true }),

    tuya.dp_numeric(164, { name = "radar_threshold", emit = emit.zis01pRadarThreshold() }),

    tuya.dp_numeric(165, { name = "radar_distance_door_test", read_only = true }),

  },

  query_on_configure = false,

}



register_device_definition(presence_model_zis_01p, ts0601_fingerprints({

  "_TZE284_vceqncho",

  "_TZE284_who1jxwd",

}))

-- Z2M lists AOYAN AY-204ZX as a ZG-204ZK whiteLabel.
register_device_definition({
  profile = "safety-presence-zg204zk-battery",
  package_group = "presence-general-2",
  datapoints = {
    tuya.dp_presence(1, { emit = emit.presence(), converter = converter.true_false1() }),
    tuya.dp_static_detection_sensitivity(2, { emit = emit.zg204zkStaticSensitivity() }),
    tuya.dp_static_detection_distance(4, {
      name = "detection_distance", emit = emit.zg204zkDetectionDistance(),
    }),
    tuya.dp_fading_time(102, { emit = emit.zg204zkFadingTime() }),
    tuya.dp_indicator(107, { emit = emit.zg204zkIndicator(), converter = on_off_bool_converter }),
    tuya.dp_battery(121, { emit = emit.battery() }),
    tuya.dp_binary(122, {
      name = "anti_interference", emit = emit.zg204zkAntiInterference(),
      converter = on_off_bool_converter,
    }),
    tuya.dp_motion_detection_sensitivity(123, { emit = emit.zg204zkMotionSensitivity() }),
  },
  query_on_configure = true,
}, { device_helpers.create_fingerprint("AOYAN", "AY-204ZX") })

return {
  id = "ef00.presence.general.2",
  registrations = device_definitions,
}
