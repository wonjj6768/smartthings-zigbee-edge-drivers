-- 스위치 디바이스 정의
-- ZHA ts0601_switch.py + Z2M zigbee-herdsman-converters 기반 DP 그룹핑
--
-- 변수명 규칙: switch_{variant}
--   variant:
--     1gang ~ 8gang  순수 on/off, DP 1~N = switch channel 1~N
--     1gang_dp16     단일 스위치가 DP 16 사용
--     8gang_dp101    8구 특수형, 7/8채널이 DP 101/102 사용
--     model_*        부가 기능 포함 모델별 레이아웃
-- 현재 프로파일에 노출하지 않는 DP도 모두 유지

local tuya = require "tuya_common"
local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"

local converter = tuya.converter
local emit = require "emitters"

local device_definitions, register_device_definition = device_helpers.definition_registry()

-- Z2M multifunction switch (tuya.ts:28068) offers 7 colours; the colored
-- backlight panels (tuya.ts:2851) add warm_white and warm_yellow.
local backlight_color_converter = converter.lookup_from_to({
  red = 0,
  blue = 1,
  green = 2,
  white = 3,
  yellow = 4,
  magenta = 5,
  cyan = 6,
})
local backlight_color_warm_converter = converter.lookup_from_to({
  red = 0,
  blue = 1,
  green = 2,
  white = 3,
  yellow = 4,
  magenta = 5,
  cyan = 6,
  warmWhite = 7,
  warmYellow = 8,
})
local panel_indicator_converter = converter.lookup_from_to({
  off = 0,
  onOffStatus = 1,
  switchPosition = 2,
})
local panel_off_on_converter = converter.lookup_from_to({ off = false, on = true })
local lcd_panel_mode_converter = converter.lookup_from_to({
  switch = 0,
  scene = 1,
  smartLight = 2,
})
local pn16_switch_type_converter = converter.lookup_from_to({
  momentary = 0,
  toggle = 1,
  state = 2,
})
local pn16_switch_mode_converter = converter.lookup_from_to({ switch = 0, curtain = 1 })
local f3pro_cover_state_converter = converter.lookup_from_to({ open = 0, stop = 1, close = 2 })

local eyzee_restart_converter = converter.lookup_from_to({ off = 0, on = 1, previous = 2 })
local eyzee_indicator_converter = converter.lookup_from_to({ off = 0, on_off_status = 1, switch_position = 2 })
local eyzee_global_restart_converter = converter.lookup_from_to({ off = false, on = true })

local switch_eyzee_5gang = {
  profile = "switches-eyzee-5gang-countdown",
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
  tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
  tuya.dp_on_off(5, { name = "switch", component = "switch5" }),
  tuya.dp_countdown(7, { name = "countdown_1", emit = emit.eyzee5gCountdown1() }),
  tuya.dp_countdown(8, { name = "countdown_2", emit = emit.eyzee5gCountdown2() }),
  tuya.dp_countdown(9, { name = "countdown_3", emit = emit.eyzee5gCountdown3() }),
  tuya.dp_countdown(10, { name = "countdown_4", emit = emit.eyzee5gCountdown4() }),
  tuya.dp_countdown(11, { name = "countdown_5", emit = emit.eyzee5gCountdown5() }),
  tuya.dp_binary(14, {
    name = "eyzee_global_restart",
    emit = emit.eyzee5gGlobalRestart(),
    converter = eyzee_global_restart_converter,
  }),
  tuya.dp_enum(15, {
    name = "eyzee_indicator_mode",
    emit = emit.eyzee5gIndicatorMode(),
    converter = eyzee_indicator_converter,
  }),
  tuya.dp_enum(29, { name = "eyzee_switch1_restart", emit = emit.eyzee5gSwitch1Restart(), converter = eyzee_restart_converter }),
  tuya.dp_enum(30, { name = "eyzee_switch2_restart", emit = emit.eyzee5gSwitch2Restart(), converter = eyzee_restart_converter }),
  tuya.dp_enum(31, { name = "eyzee_switch3_restart", emit = emit.eyzee5gSwitch3Restart(), converter = eyzee_restart_converter }),
  tuya.dp_enum(32, { name = "eyzee_switch4_restart", emit = emit.eyzee5gSwitch4Restart(), converter = eyzee_restart_converter }),
  tuya.dp_enum(33, { name = "eyzee_switch5_restart", emit = emit.eyzee5gSwitch5Restart(), converter = eyzee_restart_converter }),
}

register_device_definition(switch_eyzee_5gang, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_0kihjsys",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-1. switch_1gang: 기본 1구
-- Z2M: TS0601_switch_1_gang / X711A
-- ══════════════════════════════════════════════════════════════
local switch_1gang = {
  profile = "switches-switch-1",
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
}

register_device_definition(switch_1gang, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_8vxj8khv",
  "_TZE200_oisqyl4o",
  "_TZE200_ojtqawav",
  "_TZE200_7tdtqgwv",
  "_TZE204_gbagoilo",
  "_TZE204_ojtqawav",
  "_TZE204_ptaqh9tk",
}))

register_device_definition(switch_1gang, {
  device_helpers.create_fingerprint("Shawader", "SMKG-1KNL-US/TZB-W"),
  device_helpers.create_fingerprint("Norklmes", "MKS-CM-W5"),
  device_helpers.create_fingerprint("Somgoms", "ZSQB-SMB-ZB"),
  device_helpers.create_fingerprint("Moes", "WS-EUB1-ZG"),
  device_helpers.create_fingerprint("AVATTO", "ZGB-WS-EU"),
})

-- ══════════════════════════════════════════════════════════════
-- 1-1a. switch_1gang_temperature: 1구 + 온도 센서
-- Z2M: TYONOFFTS
-- ══════════════════════════════════════════════════════════════
local switch_1gang_temperature = {
  profile = "switches-switch-1-temperature",
  datapoints = {
    tuya.dp_on_off(2, { name = "switch", component = "main" }),
    tuya.dp_temperature(27, { name = "temperature" }),
  },
  query_on_configure = true,
}

local switch_1gang_temperature_humidity_scimagic = {
  profile = "switches-switch-1-temp-humidity-scimagic",
  datapoints = {
    tuya.dp_on_off(2, { name = "switch", component = "main" }),
    tuya.dp_temperature(27, { name = "temperature", scale = 10 }),
    tuya.dp_humidity(46, { name = "humidity", scale = 1 }),
    -- Z2M (tuya.ts:23692) reads DP30 with divideBy2, DP8 as
    -- heating/dehumidify/cooling/wet and also exposes the DP41/42/47 humidity
    -- target, range and calibration that were missing here.
    tuya.dp_temperature_calibration(30, { scale = 2, emit = emit.scimagicTempCalibration() }),
    tuya.dp_temperature(29, {
      name = "temperature_range",
      scale = 10,
      emit = emit.scimagicTempRange(),
    }),
    tuya.dp_on_off(9, {
      name = "auto_work",
      emit = emit.scimagicAutoWork(),
      converter = panel_off_on_converter,
    }),
    tuya.dp_temperature(22, {
      name = "temperature_target",
      scale = 10,
      emit = emit.scimagicTempTarget(),
    }),
    tuya.dp_enum(8, {
      name = "mode",
      emit = emit.scimagicMode(),
      converter = converter.lookup_from_to({
        heating = 0,
        dehumidify = 1,
        cooling = 2,
        wet = 3,
      }),
    }),
    tuya.dp_on_off(56, {
      name = "delay",
      emit = emit.scimagicDelay(),
      converter = panel_off_on_converter,
    }),
    tuya.dp_numeric(55, { name = "delay_time", emit = emit.scimagicDelayTime() }),
    tuya.dp_numeric(41, { name = "humidity_target", emit = emit.scimagicHumidityTarget() }),
    tuya.dp_numeric(42, { name = "humidity_range", emit = emit.scimagicHumidityRange() }),
    tuya.dp_numeric(47, {
      name = "humidity_calibration",
      emit = emit.scimagicHumidityCalibration(),
    }),
  },
  query_on_configure = true,
}

register_device_definition(switch_1gang_temperature, device_helpers.create_fingerprints("TS0001", {
  "_TZE21C_dohbhb5k",
}))

register_device_definition(switch_1gang_temperature_humidity_scimagic, device_helpers.create_fingerprints("TS0001", {
  "_TZE21C_i2ij4rb3",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-1aa. switch_1gang_smart_temperature: 온도 기반 릴레이
-- Z2M: TS0601_smart_temperature_switch
-- ══════════════════════════════════════════════════════════════
local switch_1gang_smart_temperature = {
  profile = "switches-switch-1-temperature-roujjevx",
  datapoints = {
    tuya.dp_on_off(2, { name = "switch", component = "main" }),
    tuya.dp_countdown(4, { name = "countdown", emit = emit.rjvxCountdown() }),
    -- DP7 carries the packed weekly schedule list; it is kept internal.
    tuya.dp_raw(7, { name = "schedules" }),
    tuya.dp_enum(8, {
      name = "work_mode",
      emit = emit.rjvxWorkMode(),
      converter = converter.lookup_from_to({
        heating = 0,
        cooling = 2,
      }),
    }),
    tuya.dp_on_off(9, {
      name = "autowork",
      emit = emit.rjvxAutowork(),
      converter = converter.lookup_from_to({ off = false, on = true }),
    }),
    tuya.dp_temperature_unit(20, { emit = emit.rjvxTemperatureUnit() }),
    tuya.dp_temperature(21, {
      name = "temperature_f_setpoint",
      scale = 10,
      emit = emit.rjvxTempFSetpoint(),
    }),
    tuya.dp_temperature(22, {
      name = "temperature_c_setpoint",
      scale = 10,
      emit = emit.rjvxTempCSetpoint(),
    }),
    tuya.dp_temperature(27, { name = "temperature", scale = 10 }),
    tuya.dp_temperature(28, {
      name = "temperature_f",
      scale = 10,
      read_only = true,
      emit = emit.rjvxTemperatureF(),
    }),
    tuya.dp_temperature(29, {
      name = "temperature_range",
      scale = 10,
      emit = emit.rjvxTemperatureRange(),
    }),
    -- Z2M reads DP30 raw and documents it as always in Fahrenheit (tuya.ts:26504).
    tuya.dp_temperature_calibration(30, { scale = 1, emit = emit.rjvxTempCalibration() }),
    tuya.dp_numeric(55, { name = "cooling_delay", emit = emit.rjvxCoolingDelay() }),
    tuya.dp_on_off(56, {
      name = "cooling_delay_switch",
      emit = emit.rjvxCoolingDelaySwitch(),
      converter = converter.lookup_from_to({ off = false, on = true }),
    }),
  },
  query_on_configure = true,
}

register_device_definition(switch_1gang_smart_temperature, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_roujjevx",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-1ab. switch_model_mg_gpo04zslp: 2 socket + 1 light + master + metering
-- Z2M: MG-GPO04ZSLP
-- ══════════════════════════════════════════════════════════════
local switch_model_mg_gpo04zslp = {
  profile = "switches-switch-4-energy-voltage-current",
  datapoints = {
    tuya.dp_on_off(13, { name = "switch", component = "main" }),
    tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
    tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
    tuya.dp_on_off(1, { name = "switch", component = "switch4" }),
    tuya.dp_current(21, {}),
    tuya.dp_energy(22, { scale = 1000 }),
    tuya.dp_voltage(23, {}),
  },
  query_on_configure = true,
}

register_device_definition(switch_model_mg_gpo04zslp, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_oyti2ums",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-1b. switch_1gang_battery: battery-powered single-gang ZCL switch
-- NOTE:
--   - Currently registered to no fingerprint, so it is inert at runtime. The
--     definition is kept because whether this project should claim Fingerbot
--     hardware at all is still an open decision.
--   - Switch/battery are standard ZCL.
--   - Fingerbot pairs (_TZ3210_dse8ogfy, _TZ3210_j4pdtz9v, _TZ3210_cm9mbpr1,
--     _TZ3210_a04acm9s, _TZ3210_7vgttna6, Adaprox/TS0001_fingerbot_1) used to be
--     registered here. A separate long-standing driver, `tuya-fingerbot-v3`,
--     already implements the full Z2M contract for those devices (mode, movement
--     limits, sustain time, reverse, touch). Registering the same pairs here only
--     made the two drivers compete while exposing switch/battery alone, so they
--     are no longer claimed by this project.
-- ══════════════════════════════════════════════════════════════
local switch_1gang_battery = {
  profile = "switches-switch-1-battery",
  zcl_clusters = {
    zcl.switch(),
    zcl.battery(),
  },
}

-- ══════════════════════════════════════════════════════════════
-- 1-1c. switch_1gang_temperature_humidity: 1구 + 온습도
-- Z2M: TYZGTH1CH-D1RF
-- NOTE:
--   - Switch is handled by standard ZCL OnOff.
--   - EF00 datapoints provide temperature/humidity.
--   - Calibration/manual-mode/child-lock options are intentionally deferred.
-- ══════════════════════════════════════════════════════════════
local switch_1gang_temperature_humidity = {
  profile = "switches-switch-1-temp-humidity",
  datapoints = {
    tuya.dp_temperature(102, { name = "temperature" }),
    tuya.dp_humidity(103, { name = "humidity" }),
  },
  zcl_clusters = {
    zcl.switch(),
  },
  query_on_configure = true,
}

register_device_definition(switch_1gang_temperature_humidity, device_helpers.create_fingerprints("TS000F", {
  "_TZ3218_7fiyo3kv",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-1d. switch_4gang_temperature_humidity: 4구 + 온습도
-- Z2M: TYZGTH4CH-D1RF
-- NOTE:
--   - Switch endpoints are handled by standard ZCL OnOff.
--   - EF00 datapoints provide temperature/humidity only.
--   - Countdown / power-on-behavior2 are intentionally deferred.
-- ══════════════════════════════════════════════════════════════
local switch_4gang_temperature_humidity = {
  profile = "switches-switch-4-temp-humidity",
  datapoints = {
    tuya.dp_temperature(102, { name = "temperature" }),
    tuya.dp_humidity(103, { name = "humidity" }),
  },
  zcl_clusters = {
    zcl.switch({ endpoint = 1, component = "main" }),
    zcl.switch({ endpoint = 2, component = "switch2" }),
    zcl.switch({ endpoint = 3, component = "switch3" }),
    zcl.switch({ endpoint = 4, component = "switch4" }),
  },
  query_on_configure = true,
}

register_device_definition(switch_4gang_temperature_humidity, device_helpers.create_fingerprints("TS000F", {
  "_TZ3218_ya5d6wth",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-2. switch_2gang: 기본 2구
-- Z2M: TS0601_switch_2_gang / MG-ZG02W
-- ══════════════════════════════════════════════════════════════
local switch_2gang = {
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
}

register_device_definition(switch_2gang, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_3t91nb6k",
  "_TZE200_7deq70b8",
  "_TZE200_dhdstcqc",
  "_TZE200_ji1gn7rw",
  "_TZE200_nh9m9emk",
  "_TZE200_nkjintbl",
  "_TZE200_wvovwe9h",
  "_TZE204_3t91nb6k",
  "_TZE204_nh9m9emk",
  "_TZE204_wvovwe9h",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-3. switch_3gang: 기본 3구
-- Z2M: TS0601_switch_3_gang / MG-ZG03W
-- ══════════════════════════════════════════════════════════════
local switch_3gang = {
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
}

register_device_definition(switch_3gang, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_2imwyigp",
  "_TZE200_2hf7x9n3",
  "_TZE200_atpwqgml",
  "_TZE200_bynnczcb",
  "_TZE200_fqytfymk",
  "_TZE200_go3tvswy",
  "_TZE200_kyfqmmyl",
  "_TZE204_2imwyigp",
  "_TZE204_atpwqgml",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-4. switch_4gang: 기본 4구
-- Z2M: TS0601_switch_4_gang_1
-- ══════════════════════════════════════════════════════════════
local switch_4gang = {
  profile = "switches-switch-4",
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
  tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
}

register_device_definition(switch_4gang, device_helpers.create_fingerprints("TS0601", {
  "_TZ3000_uim07oem",
  "_TZE200_1n2kyphz",
  "_TZE200_6wi2mope",
  "_TZE200_aqnazj70",
  "_TZE200_di3tfv5b",
  "_TZE200_js3mgbjb",
  "_TZE200_mexisfik",
  "_TZE200_shkxsgis",
  "_TZE204_6wi2mope",
  "_TZE204_58of2pfn",
  "_TZE204_aagrxlbd",
  "_TZE204_f5efvtbv",
  "_TZE204_iik0pquw",
  "_TZE204_lbhh5o6z",
  "_TZE204_mexisfik",
  "_TZE204_shkxsgis",
  "_TZE284_f5efvtbv",
  "_TZE284_lbhh5o6z",
}))

register_device_definition(switch_4gang, {
  device_helpers.create_fingerprint("ZYXH", "TY-04Z"),
  device_helpers.create_fingerprint("AVATTO", "WSMD-4"),
  device_helpers.create_fingerprint("AVATTO", "ZWSMD-4"),
  device_helpers.create_fingerprint("Tuya", "MG-ZG04W"),
})

-- TS0601_4gang_7ytnacie: 4구 + colored backlight/countdown
local switch_4gang_colored_backlight = {
  profile = "switches-switch-4-colored-backlight",
  datapoints = {
    -- Z2M TS0601_4gang_7ytnacie (tuya.ts:2911): DP13 is the all-switch master,
    -- DP1~4 are the four relays, DP15 the LED indicator mode, DP102 the backlight
    -- brightness percentage and DP103/104 the 9-colour on/off backlight colours.
    tuya.dp_on_off(13, { name = "switch", component = "main" }),
    tuya.dp_on_off(1, { name = "switch", component = "switch2" }),
    tuya.dp_on_off(2, { name = "switch", component = "switch3" }),
    tuya.dp_on_off(3, { name = "switch", component = "switch4" }),
    tuya.dp_on_off(4, { name = "switch", component = "switch5" }),
    tuya.dp_countdown(7, { name = "countdown_l1", emit = emit.cb4gCountdown1() }),
    tuya.dp_countdown(8, { name = "countdown_l2", emit = emit.cb4gCountdown2() }),
    tuya.dp_countdown(9, { name = "countdown_l3", emit = emit.cb4gCountdown3() }),
    tuya.dp_countdown(10, { name = "countdown_l4", emit = emit.cb4gCountdown4() }),
    tuya.dp_power_on_behavior(14, { emit = emit.cb4gPowerOnBehavior() }),
    tuya.dp_enum(15, {
      name = "indicator_mode",
      emit = emit.cb4gIndicatorMode(),
      converter = panel_indicator_converter,
    }),
    tuya.dp_binary(16, {
      name = "backlight_switch",
      emit = emit.cb4gBacklightSwitch(),
      converter = panel_off_on_converter,
    }),
    tuya.dp_child_lock(101, {
      name = "child_lock",
      emit = emit.cb4gChildLock(),
      converter = panel_off_on_converter,
    }),
    tuya.dp_numeric(102, { name = "backlight", emit = emit.cb4gBacklight() }),
    tuya.dp_enum(103, {
      name = "on_color",
      emit = emit.cb4gOnColor(),
      converter = backlight_color_warm_converter,
    }),
    tuya.dp_enum(104, {
      name = "off_color",
      emit = emit.cb4gOffColor(),
      converter = backlight_color_warm_converter,
    }),
  },
  query_on_configure = true,
}

register_device_definition(switch_4gang_colored_backlight, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_7ytnacie",
  "_TZE204_hewlydpz",
}))

-- TS0601_3gang_rkbxtclc: 3구 + colored backlight/countdown
local switch_3gang_colored_backlight = {
  profile = "switches-switch-3-colored-backlight",
  datapoints = {
    tuya.dp_on_off(13, { name = "switch", component = "main" }),
    tuya.dp_on_off(1, { name = "switch", component = "switch2" }),
    tuya.dp_on_off(2, { name = "switch", component = "switch3" }),
    tuya.dp_on_off(3, { name = "switch", component = "switch4" }),
    tuya.dp_countdown(7, { name = "countdown_l1", emit = emit.cb3gCountdown1() }),
    tuya.dp_countdown(8, { name = "countdown_l2", emit = emit.cb3gCountdown2() }),
    tuya.dp_countdown(9, { name = "countdown_l3", emit = emit.cb3gCountdown3() }),
    tuya.dp_power_on_behavior(14, { emit = emit.cb3gPowerOnBehavior() }),
    tuya.dp_enum(15, {
      name = "indicator_mode",
      emit = emit.cb3gIndicatorMode(),
      converter = panel_indicator_converter,
    }),
    tuya.dp_binary(16, {
      name = "backlight_switch",
      emit = emit.cb3gBacklightSwitch(),
      converter = panel_off_on_converter,
    }),
    tuya.dp_child_lock(101, {
      name = "child_lock",
      emit = emit.cb3gChildLock(),
      converter = panel_off_on_converter,
    }),
    tuya.dp_numeric(102, { name = "backlight", emit = emit.cb3gBacklight() }),
    tuya.dp_enum(103, {
      name = "on_color",
      emit = emit.cb3gOnColor(),
      converter = backlight_color_warm_converter,
    }),
    tuya.dp_enum(104, {
      name = "off_color",
      emit = emit.cb3gOffColor(),
      converter = backlight_color_warm_converter,
    }),
  },
  query_on_configure = true,
}

register_device_definition(switch_3gang_colored_backlight, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_rkbxtclc",
}))

-- ZN2S-RS02E: 2구 + colored backlight/countdown
local switch_2gang_colored_backlight = {
  profile = "switches-switch-2-colored-backlight",
  datapoints = {
    tuya.dp_on_off(13, { name = "switch", component = "main" }),
    tuya.dp_on_off(1, { name = "switch", component = "switch2" }),
    tuya.dp_on_off(2, { name = "switch", component = "switch3" }),
    tuya.dp_countdown(7, { name = "countdown_l1", emit = emit.cb2gCountdown1() }),
    tuya.dp_countdown(8, { name = "countdown_l2", emit = emit.cb2gCountdown2() }),
    tuya.dp_power_on_behavior(14, { emit = emit.cb2gPowerOnBehavior() }),
    tuya.dp_enum(15, {
      name = "indicator_mode",
      emit = emit.cb2gIndicatorMode(),
      converter = panel_indicator_converter,
    }),
    tuya.dp_binary(16, {
      name = "backlight_switch",
      emit = emit.cb2gBacklightSwitch(),
      converter = panel_off_on_converter,
    }),
    tuya.dp_child_lock(101, {
      name = "child_lock",
      emit = emit.cb2gChildLock(),
      converter = panel_off_on_converter,
    }),
    tuya.dp_numeric(102, { name = "backlight", emit = emit.cb2gBacklight() }),
    tuya.dp_enum(103, {
      name = "on_color",
      emit = emit.cb2gOnColor(),
      converter = backlight_color_warm_converter,
    }),
    tuya.dp_enum(104, {
      name = "off_color",
      emit = emit.cb2gOffColor(),
      converter = backlight_color_warm_converter,
    }),
  },
  query_on_configure = true,
}

register_device_definition(switch_2gang_colored_backlight, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_zpvusbtv",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-5. switch_5gang: 기본 5구
-- Z2M: TS0601_switch_5_gang
-- ══════════════════════════════════════════════════════════════
local switch_5gang = {
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
  tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
  tuya.dp_on_off(5, { name = "switch", component = "switch5" }),
}

register_device_definition(switch_5gang, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_jwsjbxjs",
  "_TZE200_leaqthqq",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-6. switch_6gang: 기본 6구
-- Z2M: TS0601_switch_6_gang
-- ══════════════════════════════════════════════════════════════
local switch_6gang = {
  profile = "switches-switch-6",
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
  tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
  tuya.dp_on_off(5, { name = "switch", component = "switch5" }),
  tuya.dp_on_off(6, { name = "switch", component = "switch6" }),
}

register_device_definition(switch_6gang, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_9mahtqtg",
  "_TZE200_cduqh1l0",
  "_TZE204_cduqh1l0",
  "_TZE200_emxxanvi",
  "_TZE200_mwvfvw8g",
  "_TZE200_r731zlxk",
  "_TZE200_wnp4d4va",
  "_TZE204_g4au0afs",
  "_TZE204_gxbdnfrh",
  "_TZE204_l8xiyymq",
  "_TZE204_lmgrbuwf",
  "_TZE204_ncti2pro",
  "_TZE204_r731zlxk",
  "_TZE284_r731zlxk",
  "_TZE204_w1wwxoja",
  "_TZE204_wskr3up8",
  "_TZE284_g1enhdsi",
  "_TZE284_l8xiyymq",
  "_TZE284_tdhnhhiy",
  "_TZE284_zeldawjv",
}))

register_device_definition(switch_6gang, {
  device_helpers.create_fingerprint("Mercator Ikuü", "SSW06G"),
  device_helpers.create_fingerprint("Nova Digital", "NTZB-04-W-B"),
  device_helpers.create_fingerprint("Nova Digital", "SYZB-6W"),
  device_helpers.create_fingerprint("Nova Digital", "FZB-6"),
  device_helpers.create_fingerprint("Nova Digital", "SA-6"),
  device_helpers.create_fingerprint("Ekaza", "EKAT-T3074-6WZ"),
})

-- TS0601 touch panel switch family (Z2M tuya.ts:27846, 28137, 27921, 28007):
-- DP14 power_on_behavior, DP16 backlight and DP101 child lock are on/off enums.
local switch_1gang_touch_panel = {
  profile = "switches-switch-1-touch-panel",
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main" }),
    tuya.dp_power_on_behavior(14, { emit = emit.tp1gPowerOnBehavior() }),
    tuya.dp_backlight_mode_off_on(16, {
      emit = emit.tp1gBacklightMode(),
      converter = converter.lookup_from_to({ off = false, on = true }),
    }),
    tuya.dp_child_lock(101, {
      name = "child_lock",
      emit = emit.tp1gChildLock(),
      converter = converter.lookup_from_to({ off = false, on = true }),
    }),
  },
  query_on_configure = true,
}

local switch_2gang_touch_panel = {
  profile = "switches-switch-2-touch-panel",
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main" }),
    tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
    tuya.dp_power_on_behavior(14, { emit = emit.tp2gPowerOnBehavior() }),
    tuya.dp_backlight_mode_off_on(16, {
      emit = emit.tp2gBacklightMode(),
      converter = converter.lookup_from_to({ off = false, on = true }),
    }),
    tuya.dp_child_lock(101, {
      name = "child_lock",
      emit = emit.tp2gChildLock(),
      converter = converter.lookup_from_to({ off = false, on = true }),
    }),
  },
  query_on_configure = true,
}

local switch_3gang_touch_panel = {
  profile = "switches-switch-3-touch-panel",
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main" }),
    tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
    tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
    tuya.dp_power_on_behavior(14, { emit = emit.tp3gPowerOnBehavior() }),
    tuya.dp_backlight_mode_off_on(16, {
      emit = emit.tp3gBacklightMode(),
      converter = converter.lookup_from_to({ off = false, on = true }),
    }),
    tuya.dp_child_lock(101, {
      name = "child_lock",
      emit = emit.tp3gChildLock(),
      converter = converter.lookup_from_to({ off = false, on = true }),
    }),
  },
  query_on_configure = true,
}

local switch_6gang_touch_panel = {
  profile = "switches-switch-6-touch-panel",
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main" }),
    tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
    tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
    tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
    tuya.dp_on_off(5, { name = "switch", component = "switch5" }),
    tuya.dp_on_off(6, { name = "switch", component = "switch6" }),
    tuya.dp_power_on_behavior(14, { emit = emit.tp6gPowerOnBehavior() }),
    tuya.dp_backlight_mode_off_on(16, {
      emit = emit.tp6gBacklightMode(),
      converter = converter.lookup_from_to({ off = false, on = true }),
    }),
    tuya.dp_child_lock(101, {
      name = "child_lock",
      emit = emit.tp6gChildLock(),
      converter = converter.lookup_from_to({ off = false, on = true }),
    }),
  },
  query_on_configure = true,
}

local switch_1gang_stairwell = {
  profile = "switches-switch-1-stairwell",
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main" }),
    tuya.dp_child_lock(29, {
      name = "child_lock",
      emit = emit.stairwellChildLock(),
      converter = converter.lookup_from_to({ off = false, on = true }),
    }),
  },
  query_on_configure = true,
}

local switch_1gang_multifunction = {
  profile = "switches-switch-1-multifunction",
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main" }),
    -- Z2M TS0601_multifunction_switch (tuya.ts:28048): DP15 is none/relay/pos,
    -- DP102 the backlight brightness percentage and DP103/104 the 7 backlight colours.
    tuya.dp_countdown(7, { name = "countdown", emit = emit.mf1gCountdown1() }),
    tuya.dp_power_on_behavior(14, { emit = emit.mf1gPowerOnBehavior() }),
    tuya.dp_indicator_mode_none_relay_pos(15, { emit = emit.mf1gIndicatorMode() }),
    tuya.dp_backlight_mode_off_on(16, {
      emit = emit.mf1gBacklightMode(),
      converter = panel_off_on_converter,
    }),
    tuya.dp_inching_switch(19, {
      name = "inching_switch",
      emit = emit.mf1gInchingSwitch(),
      converter = panel_off_on_converter,
    }),
    tuya.dp_child_lock(101, {
      name = "child_lock",
      emit = emit.mf1gChildLock(),
      converter = panel_off_on_converter,
    }),
    tuya.dp_numeric(102, { name = "backlight_brightness", emit = emit.mf1gBacklightBrightness() }),
    tuya.dp_enum(103, {
      name = "on_color",
      emit = emit.mf1gOnColor(),
      converter = backlight_color_converter,
    }),
    tuya.dp_enum(104, {
      name = "off_color",
      emit = emit.mf1gOffColor(),
      converter = backlight_color_converter,
    }),
  },
  query_on_configure = true,
}

local switch_1gang_power_monitoring = {
  profile = "switches-switch-1-power-energy-voltage-current-apiu",
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main" }),
    -- Z2M TS0601_power_monitoring_switch (tuya.ts:28109) exposes DP7 as a
    -- 0..120 minute countdown and reads DP22/DP23 raw.
    tuya.dp_countdown(7, { name = "countdown", emit = emit.apiuCountdown() }),
    tuya.dp_energy(20, {}),
    tuya.dp_current(21, {}),
    tuya.dp_power(22, { scale = 1 }),
    tuya.dp_voltage(23, { scale = 1 }),
  },
  query_on_configure = true,
}

register_device_definition(switch_1gang_touch_panel, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_gm8h14wy",
}))

register_device_definition(switch_2gang_touch_panel, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_he9apaui",
}))

register_device_definition(switch_3gang_touch_panel, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_ccgyhbvd",
}))

register_device_definition(switch_6gang_touch_panel, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_y8ficeai",
  "_TZE284_hyssaqjk",
  "_TZE284_tokhh9pf",
}))

register_device_definition(switch_1gang_stairwell, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_fhv95pf1",
}))

register_device_definition(switch_1gang_multifunction, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_7e6v8u9f",
}))

register_device_definition(switch_1gang_power_monitoring, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_apiu8k13",
}))

-- KRC-103: 6 gang kinetic switch actuator (DP19~24)
local switch_6gang_dp19 = {
  profile = "switches-switch-6",
  datapoints = {
    tuya.dp_on_off(19, { name = "switch", component = "main" }),
    tuya.dp_on_off(20, { name = "switch", component = "switch2" }),
    tuya.dp_on_off(21, { name = "switch", component = "switch3" }),
    tuya.dp_on_off(22, { name = "switch", component = "switch4" }),
    tuya.dp_on_off(23, { name = "switch", component = "switch5" }),
    tuya.dp_on_off(24, { name = "switch", component = "switch6" }),
  },
  query_on_configure = true,
}

register_device_definition(switch_6gang_dp19, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_raz9qavg",
}))

-- TO-6 W/B (Z2M tuya.ts:6074): 6 relay outputs are DP24~29.  DP1~6 report the
-- scene button that was pressed, DP18~23 pick switch or scene per button, DP30~35
-- are per-channel countdowns and DP105~110 per-channel inching durations.
local switch_6gang_dp24_scene_panel = {
  profile = "switches-switch-6-to6",
  datapoints = {
    -- DP1~6 are momentary scene reports with a single enum value; SmartThings has
    -- no matching stateless capability for a wall panel switch, so they stay
    -- internal like the Z2M `action` expose.
    tuya.dp_enum(1, { name = "action_l1" }),
    tuya.dp_enum(2, { name = "action_l2" }),
    tuya.dp_enum(3, { name = "action_l3" }),
    tuya.dp_enum(4, { name = "action_l4" }),
    tuya.dp_enum(5, { name = "action_l5" }),
    tuya.dp_enum(6, { name = "action_l6" }),
    tuya.dp_enum(18, {
      name = "mode_l1",
      emit = emit.to6Mode1(),
      converter = converter.lookup_from_to({ switch = 0, scene = 1 }),
    }),
    tuya.dp_enum(19, {
      name = "mode_l2",
      emit = emit.to6Mode2(),
      converter = converter.lookup_from_to({ switch = 0, scene = 1 }),
    }),
    tuya.dp_enum(20, {
      name = "mode_l3",
      emit = emit.to6Mode3(),
      converter = converter.lookup_from_to({ switch = 0, scene = 1 }),
    }),
    tuya.dp_enum(21, {
      name = "mode_l4",
      emit = emit.to6Mode4(),
      converter = converter.lookup_from_to({ switch = 0, scene = 1 }),
    }),
    tuya.dp_enum(22, {
      name = "mode_l5",
      emit = emit.to6Mode5(),
      converter = converter.lookup_from_to({ switch = 0, scene = 1 }),
    }),
    tuya.dp_enum(23, {
      name = "mode_l6",
      emit = emit.to6Mode6(),
      converter = converter.lookup_from_to({ switch = 0, scene = 1 }),
    }),
    tuya.dp_on_off(24, { name = "switch", component = "main" }),
    tuya.dp_on_off(25, { name = "switch", component = "switch2" }),
    tuya.dp_on_off(26, { name = "switch", component = "switch3" }),
    tuya.dp_on_off(27, { name = "switch", component = "switch4" }),
    tuya.dp_on_off(28, { name = "switch", component = "switch5" }),
    tuya.dp_on_off(29, { name = "switch", component = "switch6" }),
    tuya.dp_countdown(30, { name = "countdown_l1", emit = emit.to6Countdown1() }),
    tuya.dp_countdown(31, { name = "countdown_l2", emit = emit.to6Countdown2() }),
    tuya.dp_countdown(32, { name = "countdown_l3", emit = emit.to6Countdown3() }),
    tuya.dp_countdown(33, { name = "countdown_l4", emit = emit.to6Countdown4() }),
    tuya.dp_countdown(34, { name = "countdown_l5", emit = emit.to6Countdown5() }),
    tuya.dp_countdown(35, { name = "countdown_l6", emit = emit.to6Countdown6() }),
    tuya.dp_backlight_mode_off_on(36, {
      emit = emit.to6BacklightMode(),
      converter = converter.lookup_from_to({ off = false, on = true }),
    }),
    -- Z2M reads DP37 as off/relay/invert (tuya.ts:6108), not none/relay/pos.
    tuya.dp_enum(37, {
      name = "indicator_status",
      emit = emit.to6IndicatorStatus(),
      converter = converter.lookup_from_to({ off = 0, relay = 1, invert = 2 }),
    }),
    tuya.dp_power_on_behavior(38, { emit = emit.to6PowerOnBehavior() }),
    tuya.dp_binary(103, {
      name = "induction",
      emit = emit.to6Induction(),
      converter = converter.lookup_from_to({ off = false, on = true }),
    }),
    tuya.dp_enum(104, {
      name = "vibration_gear",
      emit = emit.to6VibrationGear(),
      converter = converter.lookup_from_to({ off = 0, low = 1, medium = 2, high = 3 }),
    }),
    tuya.dp_countdown(105, { name = "inching_l1", emit = emit.to6Inching1() }),
    tuya.dp_countdown(106, { name = "inching_l2", emit = emit.to6Inching2() }),
    tuya.dp_countdown(107, { name = "inching_l3", emit = emit.to6Inching3() }),
    tuya.dp_countdown(108, { name = "inching_l4", emit = emit.to6Inching4() }),
    tuya.dp_countdown(109, { name = "inching_l5", emit = emit.to6Inching5() }),
    tuya.dp_countdown(110, { name = "inching_l6", emit = emit.to6Inching6() }),
  },
  query_on_configure = true,
}

register_device_definition(switch_6gang_dp24_scene_panel, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_rqhnxkqu",
}))

-- M9-zigbee-SL: 8 channel mixed switch/scene/presence panel
local switch_8gang_m9_motion_scene = {
  profile = "switches-switch-8-m9-sl",
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main" }),
    tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
    tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
    tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
    tuya.dp_on_off(5, { name = "switch", component = "switch5" }),
    tuya.dp_on_off(6, { name = "switch", component = "switch6" }),
    tuya.dp_on_off(112, { name = "switch", component = "switch7" }),
    tuya.dp_on_off(113, { name = "switch", component = "switch8" }),
    tuya.dp_binary(16, {
      name = "backlight_mode",
      emit = emit.m98gBacklightMode(),
      converter = panel_off_on_converter,
    }),
    tuya.dp_power_on_behavior(29, {
      name = "power_on_behavior_l1",
      emit = emit.m98gPowerOnBehavior1(),
    }),
    tuya.dp_power_on_behavior(30, {
      name = "power_on_behavior_l2",
      emit = emit.m98gPowerOnBehavior2(),
    }),
    tuya.dp_power_on_behavior(31, {
      name = "power_on_behavior_l3",
      emit = emit.m98gPowerOnBehavior3(),
    }),
    tuya.dp_power_on_behavior(32, {
      name = "power_on_behavior_l4",
      emit = emit.m98gPowerOnBehavior4(),
    }),
    tuya.dp_power_on_behavior(33, {
      name = "power_on_behavior_l5",
      emit = emit.m98gPowerOnBehavior5(),
    }),
    tuya.dp_power_on_behavior(34, {
      name = "power_on_behavior_l6",
      emit = emit.m98gPowerOnBehavior6(),
    }),
    tuya.dp_presence(105, { emit = emit.presence() }),
    tuya.dp_numeric(106, { name = "delay", emit = emit.m98gDelay() }),
  },
  query_on_configure = true,
}

register_device_definition(switch_8gang_m9_motion_scene, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_nvodulvi",
  "_TZE284_nvodulvi",
}))

-- M9-zigbee-SL-2: 4 relay + scene/presence panel
local switch_4gang_m9_scene = {
  profile = "switches-switch-4-m9-sl",
  datapoints = {
    tuya.dp_on_off(24, { name = "switch", component = "main" }),
    tuya.dp_on_off(25, { name = "switch", component = "switch2" }),
    tuya.dp_on_off(26, { name = "switch", component = "switch3" }),
    tuya.dp_on_off(27, { name = "switch", component = "switch4" }),
    -- Z2M M9-zigbee-SL-2 (tuya.ts:17634).  DP18~21 use switchMode(switch 0/scene 1),
    -- DP36 is an on/off backlight and DP38~42 are the global plus per-channel
    -- power-on behaviours.  DP1~8 and DP17 are momentary scene reports kept
    -- internal, matching the Z2M `action` expose.
    tuya.dp_enum(18, {
      name = "switch_mode_l1",
      emit = emit.m9slSwitchMode1(),
      converter = converter.lookup_from_to({ switch = 0, scene = 1 }),
    }),
    tuya.dp_enum(19, {
      name = "switch_mode_l2",
      emit = emit.m9slSwitchMode2(),
      converter = converter.lookup_from_to({ switch = 0, scene = 1 }),
    }),
    tuya.dp_enum(20, {
      name = "switch_mode_l3",
      emit = emit.m9slSwitchMode3(),
      converter = converter.lookup_from_to({ switch = 0, scene = 1 }),
    }),
    tuya.dp_enum(21, {
      name = "switch_mode_l4",
      emit = emit.m9slSwitchMode4(),
      converter = converter.lookup_from_to({ switch = 0, scene = 1 }),
    }),
    tuya.dp_binary(36, {
      name = "backlight_mode",
      emit = emit.m9slBacklightMode(),
      converter = converter.lookup_from_to({ off = false, on = true }),
    }),
    tuya.dp_power_on_behavior(38, {
      name = "power_on_behavior_l0",
      emit = emit.m9slPowerOnBehavior0(),
    }),
    tuya.dp_power_on_behavior(39, {
      name = "power_on_behavior_l1",
      emit = emit.m9slPowerOnBehavior1(),
    }),
    tuya.dp_power_on_behavior(40, {
      name = "power_on_behavior_l2",
      emit = emit.m9slPowerOnBehavior2(),
    }),
    tuya.dp_power_on_behavior(41, {
      name = "power_on_behavior_l3",
      emit = emit.m9slPowerOnBehavior3(),
    }),
    tuya.dp_power_on_behavior(42, {
      name = "power_on_behavior_l4",
      emit = emit.m9slPowerOnBehavior4(),
    }),
    tuya.dp_presence(101, { emit = emit.presence() }),
    tuya.dp_numeric(102, { name = "delay", emit = emit.m9slDelay() }),
  },
  query_on_configure = true,
}

register_device_definition(switch_4gang_m9_scene, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_yrwmnya3",
}))

-- F3-Pro smart panel (Z2M tuya.ts:24973): DP121~124 are the relays, DP102/103/105/107
-- the dimmer brightness, DP109~112 the dimmer warmth, DP117~120 the dimmer switches,
-- DP113~116 the cover positions, DP133~136 the cover open/stop/close command and
-- DP149 the panel screen.  The DP1~8 scene actions and the DP125~148 name strings
-- stay internal, matching the Z2M `action` and text exposes.
local switch_4gang_smart_panel = {
  profile = "switches-switch-4-f3-pro",
  datapoints = {
    tuya.dp_on_off(121, { name = "switch", component = "main" }),
    tuya.dp_on_off(122, { name = "switch", component = "switch2" }),
    tuya.dp_on_off(123, { name = "switch", component = "switch3" }),
    tuya.dp_on_off(124, { name = "switch", component = "switch4" }),
    tuya.dp_numeric(102, { name = "led_bright_l1", emit = emit.f3proLedBright1() }),
    tuya.dp_numeric(103, { name = "led_bright_l2", emit = emit.f3proLedBright2() }),
    tuya.dp_numeric(105, { name = "led_bright_l3", emit = emit.f3proLedBright3() }),
    tuya.dp_numeric(107, { name = "led_bright_l4", emit = emit.f3proLedBright4() }),
    tuya.dp_numeric(109, { name = "led_warm_l1", emit = emit.f3proLedWarm1() }),
    tuya.dp_numeric(110, { name = "led_warm_l2", emit = emit.f3proLedWarm2() }),
    tuya.dp_numeric(111, { name = "led_warm_l3", emit = emit.f3proLedWarm3() }),
    tuya.dp_numeric(112, { name = "led_warm_l4", emit = emit.f3proLedWarm4() }),
    tuya.dp_numeric(113, { name = "cover_position_l1", emit = emit.f3proCoverPosition1() }),
    tuya.dp_numeric(114, { name = "cover_position_l2", emit = emit.f3proCoverPosition2() }),
    tuya.dp_numeric(115, { name = "cover_position_l3", emit = emit.f3proCoverPosition3() }),
    tuya.dp_numeric(116, { name = "cover_position_l4", emit = emit.f3proCoverPosition4() }),
    tuya.dp_binary(117, {
      name = "led_switch_l1",
      emit = emit.f3proLedSwitch1(),
      converter = panel_off_on_converter,
    }),
    tuya.dp_binary(118, {
      name = "led_switch_l2",
      emit = emit.f3proLedSwitch2(),
      converter = panel_off_on_converter,
    }),
    tuya.dp_binary(119, {
      name = "led_switch_l3",
      emit = emit.f3proLedSwitch3(),
      converter = panel_off_on_converter,
    }),
    tuya.dp_binary(120, {
      name = "led_switch_l4",
      emit = emit.f3proLedSwitch4(),
      converter = panel_off_on_converter,
    }),
    tuya.dp_enum(133, {
      name = "cover_state_l1",
      emit = emit.f3proCoverState1(),
      converter = f3pro_cover_state_converter,
    }),
    tuya.dp_enum(134, {
      name = "cover_state_l2",
      emit = emit.f3proCoverState2(),
      converter = f3pro_cover_state_converter,
    }),
    tuya.dp_enum(135, {
      name = "cover_state_l3",
      emit = emit.f3proCoverState3(),
      converter = f3pro_cover_state_converter,
    }),
    tuya.dp_enum(136, {
      name = "cover_state_l4",
      emit = emit.f3proCoverState4(),
      converter = f3pro_cover_state_converter,
    }),
    tuya.dp_binary(149, {
      name = "backlight_switch",
      emit = emit.f3proBacklightSwitch(),
      converter = panel_off_on_converter,
    }),
  },
  query_on_configure = true,
}

register_device_definition(switch_4gang_smart_panel, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_7zazvlyn",
  "_TZE284_idn2htgu",
}))

local switch_4gang_lcd_panel = {
  profile = "switches-switch-4-lcd-panel",
  datapoints = {
    tuya.dp_on_off(24, { name = "switch", component = "main" }),
    tuya.dp_on_off(25, { name = "switch", component = "switch2" }),
    tuya.dp_on_off(26, { name = "switch", component = "switch3" }),
    tuya.dp_on_off(27, { name = "switch", component = "switch4" }),
    -- Z2M M8Pro (tuya.ts:13764): DP18~21 pick switch/scene/smart_light per button,
    -- DP36 is the backlight switch, DP37 the indicator mode and DP101 the panel
    -- backlight.  DP1~4 scene actions and DP103~110 name strings stay internal.
    tuya.dp_enum(18, {
      name = "mode_l1",
      emit = emit.lcd4gMode1(),
      converter = lcd_panel_mode_converter,
    }),
    tuya.dp_enum(19, {
      name = "mode_l2",
      emit = emit.lcd4gMode2(),
      converter = lcd_panel_mode_converter,
    }),
    tuya.dp_enum(20, {
      name = "mode_l3",
      emit = emit.lcd4gMode3(),
      converter = lcd_panel_mode_converter,
    }),
    tuya.dp_enum(21, {
      name = "mode_l4",
      emit = emit.lcd4gMode4(),
      converter = lcd_panel_mode_converter,
    }),
    tuya.dp_binary(36, {
      name = "backlight_switch",
      emit = emit.lcd4gBacklightSwitch(),
      converter = panel_off_on_converter,
    }),
    tuya.dp_enum(37, {
      name = "indicator_switch",
      emit = emit.lcd4gIndicatorSwitch(),
      converter = converter.lookup_from_to({ status = 0, switchPosition = 1, off = 2 }),
    }),
    tuya.dp_binary(101, {
      name = "backlight",
      emit = emit.lcd4gBacklight(),
      converter = panel_off_on_converter,
    }),
  },
  query_on_configure = true,
}

register_device_definition(switch_4gang_lcd_panel, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_atuj3i0w",
  "_TZE284_iwyqtclw",
}))

-- DS-1450WN: 2 plug + USB-A/USB-C metered outlet
local switch_4gang_metered_usb = {
  profile = "switches-switch-4-energy-voltage-current-usb",
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main" }),
    tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
    tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
    tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
    tuya.dp_countdown(7, { name = "countdown_usb_a", emit = emit.usb4gCountdownUsba() }),
    tuya.dp_countdown(8, { name = "countdown_usb_c", emit = emit.usb4gCountdownUsbc() }),
    tuya.dp_countdown(9, { name = "countdown_plug_1", emit = emit.usb4gCountdownPlugOne() }),
    tuya.dp_countdown(10, { name = "countdown_plug_2", emit = emit.usb4gCountdownPlugTwo() }),
    tuya.dp_power_on_behavior(14, { name = "relay_status", emit = emit.usb4gRelayStatus() }),
    tuya.dp_binary(16, {
      name = "switch_backlight",
      emit = emit.usb4gBacklight(),
      converter = panel_off_on_converter,
    }),
    tuya.dp_current(21, {}),
    tuya.dp_power(22, {}),
    tuya.dp_voltage(23, {}),
    tuya.dp_energy(105, { name = "produced_energy", emit = emit.usb4gProducedEnergy() }),
    tuya.dp_child_lock(106, {
      name = "child_lock",
      emit = emit.usb4gChildLock(),
      converter = panel_off_on_converter,
    }),
  },
  query_on_configure = true,
}

register_device_definition(switch_4gang_metered_usb, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_mvtclclq",
  "_TZE284_mvtclclq",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-6a. switch_6gang_power: 6구 + 전류/전력/전압
-- Z2M: SWS6TZ-WHITE
-- ══════════════════════════════════════════════════════════════
local switch_6gang_power = {
  profile = "switches-switch-6-power-voltage-current",
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main" }),
    tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
    tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
    tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
    tuya.dp_on_off(5, { name = "switch", component = "switch5" }),
    tuya.dp_on_off(6, { name = "switch", component = "switch6" }),
    tuya.dp_current(21, {}),
    tuya.dp_power(22, {}),
    tuya.dp_voltage(23, {}),
  },
  query_on_configure = true,
}

register_device_definition(switch_6gang_power, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_8eazvzo6",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-7. switch_model_zts_eu_1gang: Moes 터치 1구 + indicate_light + power_on_behavior
-- Z2M: ZTS-EU_1gang
-- ══════════════════════════════════════════════════════════════
local switch_model_zts_eu_1gang = {
  profile = "switches-switch-1-zts-eu",
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_power_on_behavior(14, { emit = emit.zts1gPowerOnBehavior() }),
  tuya.dp_enum(15, {
    name = "indicate_light",
    emit = emit.zts1gIndicateLight(),
    converter = converter.lookup_from_to({ off = 0, switch = 1, position = 2, freeze = 3 }),
  }),
}

register_device_definition(switch_model_zts_eu_1gang, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_amp6tsvy",
  "_TZE200_tviaymwx",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-8. switch_model_zts_eu_2gang: Moes 터치 2구 + indicate_light + power_on_behavior
-- Z2M: ZTS-EU_2gang
-- ══════════════════════════════════════════════════════════════
local switch_model_zts_eu_2gang = {
  profile = "switches-switch-2-zts-eu",
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_power_on_behavior(14, { emit = emit.zts2gPowerOnBehavior() }),
  tuya.dp_enum(15, {
    name = "indicate_light",
    emit = emit.zts2gIndicateLight(),
    converter = converter.lookup_from_to({ off = 0, switch = 1, position = 2, freeze = 3 }),
  }),
}

register_device_definition(switch_model_zts_eu_2gang, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_g1ib5ldv",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-9. switch_model_zts_eu_3gang: Moes 터치 3구 + indicate_light + power_on_behavior
-- Z2M: ZTS-EU_3gang
-- ══════════════════════════════════════════════════════════════
local switch_model_zts_eu_3gang = {
  profile = "switches-switch-3-zts-eu",
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
  tuya.dp_power_on_behavior(14, { emit = emit.zts3gPowerOnBehavior() }),
  tuya.dp_enum(15, {
    name = "indicate_light",
    emit = emit.zts3gIndicateLight(),
    converter = converter.lookup_from_to({ off = 0, switch = 1, position = 2, freeze = 3 }),
  }),
}

register_device_definition(switch_model_zts_eu_3gang, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_tz32mtza",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-10. switch_model_zts_eu_4gang: Moes 터치 4구 + indicate_light + power_on_behavior
-- Z2M: ZTS-EU_4gang
-- ══════════════════════════════════════════════════════════════
local switch_model_zts_eu_4gang = {
  profile = "switches-switch-4-zts-eu",
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
  tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
  tuya.dp_power_on_behavior(14, { emit = emit.zts4gPowerOnBehavior() }),
  tuya.dp_enum(15, {
    name = "indicate_light",
    emit = emit.zts4gIndicateLight(),
    converter = converter.lookup_from_to({ off = 0, switch = 1, position = 2, freeze = 3 }),
  }),
}

register_device_definition(switch_model_zts_eu_4gang, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_1ozguk6x",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-11. switch_model_zs_tyg3_sm_21z: 2구 + all state + countdown + backlight + power_on_behavior
-- Z2M: ZS-TYG3-SM-21Z
-- ══════════════════════════════════════════════════════════════
local switch_model_zs_tyg3_sm_21z = {
  profile = "switches-switch-2-tyg3-sm",
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_countdown(7, { name = "countdown_l1", emit = emit.tyg21zCountdown1() }),
  tuya.dp_countdown(8, { name = "countdown_l2", emit = emit.tyg21zCountdown2() }),
  tuya.dp_on_off(13, { name = "switch", component = "switch3" }),
  tuya.dp_power_on_behavior(14, { emit = emit.tyg21zPowerOnBehavior() }),
  tuya.dp_backlight_mode_off_on(16, {
    emit = emit.tyg21zBacklightMode(),
    converter = panel_off_on_converter,
  }),
}

register_device_definition(switch_model_zs_tyg3_sm_21z, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_wunufsil",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-12. switch_model_zs_tyg3_sm_31z: 3구 + all state + countdown + backlight + power_on_behavior
-- Z2M: ZS-TYG3-SM-31Z
-- ══════════════════════════════════════════════════════════════
local switch_model_zs_tyg3_sm_31z = {
  profile = "switches-switch-3-tyg3-sm",
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
  tuya.dp_countdown(7, { name = "countdown_l1", emit = emit.tyg31zCountdown1() }),
  tuya.dp_countdown(8, { name = "countdown_l2", emit = emit.tyg31zCountdown2() }),
  tuya.dp_countdown(9, { name = "countdown_l3", emit = emit.tyg31zCountdown3() }),
  tuya.dp_on_off(13, { name = "switch", component = "switch4" }),
  tuya.dp_power_on_behavior(14, { emit = emit.tyg31zPowerOnBehavior() }),
  tuya.dp_backlight_mode_off_on(16, {
    emit = emit.tyg31zBacklightMode(),
    converter = panel_off_on_converter,
  }),
}

register_device_definition(switch_model_zs_tyg3_sm_31z, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_vhy3iakz",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-13. switch_model_zs_tyg3_sm_41z: 4구 + all state + countdown + backlight + power_on_behavior
-- Z2M: ZS-TYG3-SM-41Z
-- ══════════════════════════════════════════════════════════════
local switch_model_zs_tyg3_sm_41z = {
  profile = "switches-switch-4-tyg3-sm",
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
  tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
  tuya.dp_countdown(7, { name = "countdown_l1", emit = emit.tyg41zCountdown1() }),
  tuya.dp_countdown(8, { name = "countdown_l2", emit = emit.tyg41zCountdown2() }),
  tuya.dp_countdown(9, { name = "countdown_l3", emit = emit.tyg41zCountdown3() }),
  tuya.dp_countdown(10, { name = "countdown_l4", emit = emit.tyg41zCountdown4() }),
  tuya.dp_on_off(13, { name = "switch", component = "switch5" }),
  tuya.dp_power_on_behavior(14, { emit = emit.tyg41zPowerOnBehavior() }),
  tuya.dp_backlight_mode_off_on(16, {
    emit = emit.tyg41zBacklightMode(),
    converter = panel_off_on_converter,
  }),
}

register_device_definition(switch_model_zs_tyg3_sm_41z, device_helpers.create_fingerprints("TS0601", {
  "TZE204_unsxl4ir",
  "_TZE200_k6jhsr0q",
  "_TZE204_unsxl4ir",
}))

register_device_definition(switch_model_zs_tyg3_sm_41z, {
  device_helpers.create_fingerprint("Nova Digital", "FZB-4"),
})

-- ══════════════════════════════════════════════════════════════
-- 1-14. switch_model_zs_tyg3_sm_61z: 4구 + 2 scene + all state + countdown + backlight + power_on_behavior
-- Z2M: ZS-TYG3-SM-61Z
-- ══════════════════════════════════════════════════════════════
local switch_model_zs_tyg3_sm_61z = {
  profile = "switches-switch-6-tyg3-sm",
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
  tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
  tuya.dp_on_off(5, { name = "switch", component = "switch5" }),
  tuya.dp_on_off(6, { name = "switch", component = "switch6" }),
  tuya.dp_countdown(7, { name = "countdown_l1", emit = emit.tyg61zCountdown1() }),
  tuya.dp_countdown(8, { name = "countdown_l2", emit = emit.tyg61zCountdown2() }),
  tuya.dp_countdown(9, { name = "countdown_l3", emit = emit.tyg61zCountdown3() }),
  tuya.dp_countdown(10, { name = "countdown_l4", emit = emit.tyg61zCountdown4() }),
  tuya.dp_countdown(11, { name = "countdown_l5", emit = emit.tyg61zCountdown5() }),
  tuya.dp_countdown(12, { name = "countdown_l6", emit = emit.tyg61zCountdown6() }),
  tuya.dp_on_off(13, { name = "switch", component = "switch7" }),
  tuya.dp_power_on_behavior(14, { emit = emit.tyg61zPowerOnBehavior() }),
  tuya.dp_backlight_mode_off_on(16, {
    emit = emit.tyg61zBacklightMode(),
    converter = panel_off_on_converter,
  }),
}

register_device_definition(switch_model_zs_tyg3_sm_61z, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_0j5jma9b",
  "_TZE200_h2rctifa",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-15. switch_model_ts0601_switch_4_gang_2: 4구 + backlight
-- Z2M: TS0601_switch_4_gang_2
-- ══════════════════════════════════════════════════════════════
local switch_model_ts0601_switch_4_gang_2 = {
  profile = "switches-switch-4-backlight-hewlydpz",
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
  tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
  tuya.dp_backlight_mode_off_on(7, {
    emit = emit.hewlydpzBacklightMode(),
    converter = panel_off_on_converter,
  }),
}

register_device_definition(switch_model_ts0601_switch_4_gang_2, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_hewlydpz",
}))

register_device_definition(switch_model_ts0601_switch_4_gang_2, {
  device_helpers.create_fingerprint("Homeetec", "37022714"),
})

-- ══════════════════════════════════════════════════════════════
-- 1-16. switch_1gang_model_mg_zg01w: 1구 + countdown + power meter + backlight + power_on_behavior
-- Z2M: MG-ZG01W
-- ══════════════════════════════════════════════════════════════
local switch_1gang_model_mg_zg01w = {
  profile = "switches-switch-1-power-voltage-current-mg-zg01w",
  -- Z2M MG-ZG01W (tuya.ts:6170): DP21 current /1000, DP22 power /10, DP23 voltage /10.
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_countdown(7, { name = "countdown", emit = emit.mgzgCountdown1() }),
  tuya.dp_power_on_behavior(14, { emit = emit.mgzgPowerOnBehavior() }),
  tuya.dp_backlight_mode_off_on(16, {
    emit = emit.mgzgBacklightMode(),
    converter = panel_off_on_converter,
  }),
  tuya.dp_current(21, { emit = emit.current() }),
  tuya.dp_power(22, { emit = emit.power() }),
  tuya.dp_voltage(23, { emit = emit.voltage() }),
}

register_device_definition(switch_1gang_model_mg_zg01w, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_gbagoilo",
  "_TZE284_xnwxmj8z",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-17. switch_7gang: 기본 7구
-- 현재 등록된 제조사 없음
-- ══════════════════════════════════════════════════════════════
local switch_7gang = {
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
  tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
  tuya.dp_on_off(5, { name = "switch", component = "switch5" }),
  tuya.dp_on_off(6, { name = "switch", component = "switch6" }),
  tuya.dp_on_off(7, { name = "switch", component = "switch7" }),
}

-- ══════════════════════════════════════════════════════════════
-- 1-18. switch_8gang: 기본 8구
-- 현재 등록된 제조사 없음
-- ══════════════════════════════════════════════════════════════
local switch_8gang = {
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
  tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
  tuya.dp_on_off(5, { name = "switch", component = "switch5" }),
  tuya.dp_on_off(6, { name = "switch", component = "switch6" }),
  tuya.dp_on_off(7, { name = "switch", component = "switch7" }),
  tuya.dp_on_off(8, { name = "switch", component = "switch8" }),
}

-- ══════════════════════════════════════════════════════════════
-- 1-19. switch_10gang: 기본 10구 (7~10채널이 DP 101~104)
-- Z2M: TS0601_switch_10
-- ══════════════════════════════════════════════════════════════
local switch_10gang = {
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
  tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
  tuya.dp_on_off(5, { name = "switch", component = "switch5" }),
  tuya.dp_on_off(6, { name = "switch", component = "switch6" }),
  tuya.dp_on_off(101, { name = "switch", component = "switch7" }),
  tuya.dp_on_off(102, { name = "switch", component = "switch8" }),
  tuya.dp_on_off(103, { name = "switch", component = "switch9" }),
  tuya.dp_on_off(104, { name = "switch", component = "switch10" }),
}

register_device_definition(switch_10gang, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_7sjncirf",
  "TZE204_7sjncirf",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-20. switch_12gang: 기본 12구 (7~12채널이 DP 101~106)
-- Z2M: TS0601_switch_12
-- ══════════════════════════════════════════════════════════════
local switch_12gang = {
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
  tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
  tuya.dp_on_off(5, { name = "switch", component = "switch5" }),
  tuya.dp_on_off(6, { name = "switch", component = "switch6" }),
  tuya.dp_on_off(101, { name = "switch", component = "switch7" }),
  tuya.dp_on_off(102, { name = "switch", component = "switch8" }),
  tuya.dp_on_off(103, { name = "switch", component = "switch9" }),
  tuya.dp_on_off(104, { name = "switch", component = "switch10" }),
  tuya.dp_on_off(105, { name = "switch", component = "switch11" }),
  tuya.dp_on_off(106, { name = "switch", component = "switch12" }),
}

register_device_definition(switch_12gang, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_dqolcpcp",
  "_TZE284_dqolcpcp",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-21. switch_16gang_pn16: PN16 16구 컨트롤러
-- Z2M: PN16
-- ══════════════════════════════════════════════════════════════
local switch_16gang_pn16 = {
  profile = "switches-switch-16-pn16",
  -- Z2M PN16 (tuya.ts:20826): DP1 is the all-channel master, DP118/119 pick the
  -- momentary/toggle/state switch type per bank and DP120~122 the switch/curtain
  -- mode for the paired channels.
  tuya.dp_on_off(1, { name = "switch", component = "switch17" }),
  tuya.dp_on_off(101, { name = "switch", component = "main" }),
  tuya.dp_on_off(102, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(103, { name = "switch", component = "switch3" }),
  tuya.dp_on_off(104, { name = "switch", component = "switch4" }),
  tuya.dp_on_off(105, { name = "switch", component = "switch5" }),
  tuya.dp_on_off(106, { name = "switch", component = "switch6" }),
  tuya.dp_on_off(107, { name = "switch", component = "switch7" }),
  tuya.dp_on_off(108, { name = "switch", component = "switch8" }),
  tuya.dp_on_off(109, { name = "switch", component = "switch9" }),
  tuya.dp_on_off(110, { name = "switch", component = "switch10" }),
  tuya.dp_on_off(111, { name = "switch", component = "switch11" }),
  tuya.dp_on_off(112, { name = "switch", component = "switch12" }),
  tuya.dp_on_off(113, { name = "switch", component = "switch13" }),
  tuya.dp_on_off(114, { name = "switch", component = "switch14" }),
  tuya.dp_on_off(115, { name = "switch", component = "switch15" }),
  tuya.dp_on_off(116, { name = "switch", component = "switch16" }),
  tuya.dp_power_on_behavior(117, { emit = emit.pn16PowerOnBehavior() }),
  tuya.dp_enum(118, {
    name = "switch_type_l1_l8",
    emit = emit.pn16SwitchTypeOneToEight(),
    converter = pn16_switch_type_converter,
  }),
  tuya.dp_enum(119, {
    name = "switch_type_l9_l16",
    emit = emit.pn16SwitchTypeNineToSixteen(),
    converter = pn16_switch_type_converter,
  }),
  tuya.dp_enum(120, {
    name = "switch_mode_l11_l12",
    emit = emit.pn16SwitchModeElevenTwelve(),
    converter = pn16_switch_mode_converter,
  }),
  tuya.dp_enum(121, {
    name = "switch_mode_l13_l14",
    emit = emit.pn16SwitchModeThirteenFourteen(),
    converter = pn16_switch_mode_converter,
  }),
  tuya.dp_enum(122, {
    name = "switch_mode_l15_l16",
    emit = emit.pn16SwitchModeFifteenSixteen(),
    converter = pn16_switch_mode_converter,
  }),
}

register_device_definition(switch_16gang_pn16, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_zqq3cipq",
  "_TZE284_zqq3cipq",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-22. switch_24gang: 기본 24구 (7~24채널이 DP 101~118)
-- Z2M: ZYXH_switch_24
-- ══════════════════════════════════════════════════════════════
local switch_24gang = {
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
  tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
  tuya.dp_on_off(5, { name = "switch", component = "switch5" }),
  tuya.dp_on_off(6, { name = "switch", component = "switch6" }),
  tuya.dp_on_off(101, { name = "switch", component = "switch7" }),
  tuya.dp_on_off(102, { name = "switch", component = "switch8" }),
  tuya.dp_on_off(103, { name = "switch", component = "switch9" }),
  tuya.dp_on_off(104, { name = "switch", component = "switch10" }),
  tuya.dp_on_off(105, { name = "switch", component = "switch11" }),
  tuya.dp_on_off(106, { name = "switch", component = "switch12" }),
  tuya.dp_on_off(107, { name = "switch", component = "switch13" }),
  tuya.dp_on_off(108, { name = "switch", component = "switch14" }),
  tuya.dp_on_off(109, { name = "switch", component = "switch15" }),
  tuya.dp_on_off(110, { name = "switch", component = "switch16" }),
  tuya.dp_on_off(111, { name = "switch", component = "switch17" }),
  tuya.dp_on_off(112, { name = "switch", component = "switch18" }),
  tuya.dp_on_off(113, { name = "switch", component = "switch19" }),
  tuya.dp_on_off(114, { name = "switch", component = "switch20" }),
  tuya.dp_on_off(115, { name = "switch", component = "switch21" }),
  tuya.dp_on_off(116, { name = "switch", component = "switch22" }),
  tuya.dp_on_off(117, { name = "switch", component = "switch23" }),
  tuya.dp_on_off(118, { name = "switch", component = "switch24" }),
}

register_device_definition(switch_24gang, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_vmcgja59",
  "_TZE284_vmcgja59",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-22. switch_8gang_dp101: 8구 특수형 (7/8채널이 DP 101/102)
-- Z2M: TS0601_switch_8
-- ══════════════════════════════════════════════════════════════
local switch_8gang_dp101 = {
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
  tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
  tuya.dp_on_off(5, { name = "switch", component = "switch5" }),
  tuya.dp_on_off(6, { name = "switch", component = "switch6" }),
  tuya.dp_on_off(101, { name = "switch", component = "switch7" }),
  tuya.dp_on_off(102, { name = "switch", component = "switch8" }),
}

register_device_definition(switch_8gang_dp101, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_vmcgja59",
  "_TZE200_wktrysab",
  "_TZE204_72bewjky",
  "_TZE204_ad2jkxwh",
  "_TZE204_dvosyycn",
  "_TZE204_nvxorhcj",
  "_TZE204_tdhnhhiy",
  "_TZE284_kow4ok3t",
  "_TZE204_wktrysab",
  "_TZE284_dvosyycn",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-23. switch_model_ts0601_switch_8_2: 8구 + countdown + power_on_behavior
-- Z2M: TS0601_switch_8_2
-- ══════════════════════════════════════════════════════════════
local switch_model_ts0601_switch_8_2 = {
  profile = "switches-switch-8-adlblwab",
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
  tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
  tuya.dp_on_off(5, { name = "switch", component = "switch5" }),
  tuya.dp_on_off(6, { name = "switch", component = "switch6" }),
  tuya.dp_on_off(7, { name = "switch", component = "switch7" }),
  tuya.dp_on_off(8, { name = "switch", component = "switch8" }),
  tuya.dp_countdown(9, { name = "countdown_l1", emit = emit.sw82Countdown1() }),
  tuya.dp_countdown(10, { name = "countdown_l2", emit = emit.sw82Countdown2() }),
  tuya.dp_countdown(11, { name = "countdown_l3", emit = emit.sw82Countdown3() }),
  tuya.dp_countdown(12, { name = "countdown_l4", emit = emit.sw82Countdown4() }),
  tuya.dp_countdown(13, { name = "countdown_l5", emit = emit.sw82Countdown5() }),
  tuya.dp_countdown(14, { name = "countdown_l6", emit = emit.sw82Countdown6() }),
  tuya.dp_countdown(15, { name = "countdown_l7", emit = emit.sw82Countdown7() }),
  tuya.dp_countdown(16, { name = "countdown_l8", emit = emit.sw82Countdown8() }),
  tuya.dp_power_on_behavior(27, { emit = emit.sw82PowerOnBehavior() }),
}

register_device_definition(switch_model_ts0601_switch_8_2, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_adlblwab",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-24. switch_1gang_dp16: 단일 스위치가 DP 16 사용
-- Z2M: R3 Smart Switch
-- ══════════════════════════════════════════════════════════════
local switch_1gang_dp16 = {
  tuya.dp_on_off(16, { name = "switch", component = "main" }),
}

register_device_definition(switch_1gang_dp16, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_hiith90n",
}))

return device_definitions
