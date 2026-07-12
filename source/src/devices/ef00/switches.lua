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

local backlight_color_converter = converter.lookup_from_to({
  red = 0,
  blue = 1,
  green = 2,
  white = 3,
  yellow = 4,
  magenta = 5,
  cyan = 6,
})

local eyzee_restart_converter = converter.lookup_from_to({ off = 0, on = 1, previous = 2 })
local eyzee_indicator_converter = converter.lookup_from_to({ off = 0, on_off_status = 1, switch_position = 2 })
local eyzee_global_restart_converter = converter.lookup_from_to({ off = false, on = true })

local switch_eyzee_5gang = {
  profile = "switches-eyzee-5gang",
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
  tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
  tuya.dp_on_off(5, { name = "switch", component = "switch5" }),
  tuya.dp_countdown(7, { name = "countdown_1", component = "main" }),
  tuya.dp_countdown(8, { name = "countdown_2", component = "switch2" }),
  tuya.dp_countdown(9, { name = "countdown_3", component = "switch3" }),
  tuya.dp_countdown(10, { name = "countdown_4", component = "switch4" }),
  tuya.dp_countdown(11, { name = "countdown_5", component = "switch5" }),
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
  profile = "switches-switch-1-temp-humidity",
  datapoints = {
    tuya.dp_on_off(2, { name = "switch", component = "main" }),
    tuya.dp_temperature(27, { name = "temperature", scale = 10 }),
    tuya.dp_humidity(46, { name = "humidity", scale = 1 }),
    tuya.dp_temperature_calibration(30, { scale = 2 }),           -- 프로파일 미포함
    tuya.dp_temperature(29, { name = "temperature_range", scale = 10 }), -- 프로파일 미포함
    tuya.dp_on_off(9, { name = "autowork" }),                    -- 프로파일 미포함
    tuya.dp_temperature(22, { name = "temperature_target", scale = 10 }), -- 프로파일 미포함
    tuya.dp_enum(8, {
      name = "mode",
      converter = converter.lookup_from_to({
        Heating = 0,
        Cooling = 2,
      }),
    }),                                                          -- 프로파일 미포함
    tuya.dp_on_off(56, { name = "delay" }),                      -- 프로파일 미포함
    tuya.dp_numeric(55, { name = "delay_time" }),                -- 프로파일 미포함
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
  profile = "switches-switch-1-temperature",
  datapoints = {
    tuya.dp_on_off(2, { name = "switch", component = "main" }),
    tuya.dp_countdown(4, { name = "countdown" }),                          -- profile 미포함
    tuya.dp_raw(7, { name = "schedules" }),                                -- profile 미포함
    tuya.dp_enum(8, {
      name = "work_mode",
      converter = converter.lookup_from_to({
        heating = 0,
        cooling = 2,
      }),
    }),                                                                     -- profile 미포함
    tuya.dp_on_off(9, { name = "autowork" }),                              -- profile 미포함
    tuya.dp_temperature_unit(20, {}),                                       -- profile 미포함
    tuya.dp_temperature(21, { name = "temperature_f_setpoint", scale = 10 }), -- profile 미포함
    tuya.dp_temperature(22, { name = "temperature_c_setpoint", scale = 10 }), -- profile 미포함
    tuya.dp_temperature(27, { name = "temperature", scale = 10 }),
    tuya.dp_temperature(28, { name = "temperature_f", scale = 10 }),        -- profile 미포함
    tuya.dp_temperature(29, { name = "temperature_range", scale = 10 }),    -- profile 미포함
    tuya.dp_temperature_calibration(30, { scale = 1 }),                     -- profile 미포함
    tuya.dp_numeric(55, { name = "cooling_delay" }),                       -- profile 미포함
    tuya.dp_on_off(56, { name = "cooling_delay_switch" }),                 -- profile 미포함
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
-- 1-1b. switch_1gang_battery: Fingerbot Plus
-- Z2M: TS0001_fingerbot
-- NOTE:
--   - Switch/battery are standard ZCL.
--   - EF00 option DPs (mode/lower/upper/delay/reverse/touch) are intentionally
--     deferred until we add a dedicated profile/capability surface.
-- ══════════════════════════════════════════════════════════════
local switch_1gang_battery = {
  profile = "switches-switch-1-battery",
  zcl_clusters = {
    zcl.switch(),
    zcl.battery(),
  },
}

register_device_definition(switch_1gang_battery, device_helpers.create_fingerprints("TS0001", {
  "_TZ3210_dse8ogfy",
  "_TZ3210_j4pdtz9v",
  "_TZ3210_7vgttna6",
  "_TZ3210_a04acm9s",
  "_TZ3210_cm9mbpr1",
}))

register_device_definition(switch_1gang_battery, {
  device_helpers.create_fingerprint("Adaprox", "TS0001_fingerbot_1"),
})

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
  profile = "switches-switch-4",
  datapoints = {
    tuya.dp_on_off(13, { name = "switch", component = "main" }),
    tuya.dp_on_off(1, { name = "switch", component = "switch2" }),
    tuya.dp_on_off(2, { name = "switch", component = "switch3" }),
    tuya.dp_on_off(3, { name = "switch", component = "switch4" }),
    tuya.dp_on_off(4, { name = "state_l4" }),                            -- profile 미포함
    tuya.dp_countdown(7, { name = "countdown_l1" }),                     -- profile 미포함
    tuya.dp_countdown(8, { name = "countdown_l2" }),                     -- profile 미포함
    tuya.dp_countdown(9, { name = "countdown_l3" }),                     -- profile 미포함
    tuya.dp_countdown(10, { name = "countdown_l4" }),                    -- profile 미포함
    tuya.dp_power_on_behavior(14, {}),                                   -- profile 미포함
    tuya.dp_binary(16, { name = "backlight_switch" }),                   -- profile 미포함
    tuya.dp_child_lock(101, { name = "child_lock" }),                    -- profile 미포함
    tuya.dp_raw(102, { name = "backlight" }),                            -- profile 미포함
  },
  query_on_configure = true,
}

register_device_definition(switch_4gang_colored_backlight, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_7ytnacie",
  "_TZE204_hewlydpz",
}))

-- TS0601_3gang_rkbxtclc: 3구 + colored backlight/countdown
local switch_3gang_colored_backlight = {
  profile = "switches-switch-3",
  datapoints = {
    tuya.dp_on_off(13, { name = "switch", component = "main" }),
    tuya.dp_on_off(1, { name = "switch", component = "switch2" }),
    tuya.dp_on_off(2, { name = "switch", component = "switch3" }),
    tuya.dp_on_off(3, { name = "state_l3" }),                            -- profile 미포함
    tuya.dp_countdown(7, { name = "countdown_l1" }),                     -- profile 미포함
    tuya.dp_countdown(8, { name = "countdown_l2" }),                     -- profile 미포함
    tuya.dp_countdown(9, { name = "countdown_l3" }),                     -- profile 미포함
    tuya.dp_power_on_behavior(14, {}),                                   -- profile 미포함
    tuya.dp_binary(16, { name = "backlight_switch" }),                   -- profile 미포함
    tuya.dp_child_lock(101, { name = "child_lock" }),                    -- profile 미포함
    tuya.dp_raw(102, { name = "backlight" }),                            -- profile 미포함
  },
  query_on_configure = true,
}

register_device_definition(switch_3gang_colored_backlight, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_rkbxtclc",
}))

-- ZN2S-RS02E: 2구 + colored backlight/countdown
local switch_2gang_colored_backlight = {
  profile = "switches-switch-2",
  datapoints = {
    tuya.dp_on_off(13, { name = "switch", component = "main" }),
    tuya.dp_on_off(1, { name = "switch", component = "switch2" }),
    tuya.dp_on_off(2, { name = "state_l2" }),                            -- profile 미포함
    tuya.dp_countdown(7, { name = "countdown_l1" }),                     -- profile 미포함
    tuya.dp_countdown(8, { name = "countdown_l2" }),                     -- profile 미포함
    tuya.dp_power_on_behavior(14, {}),                                   -- profile 미포함
    tuya.dp_binary(16, { name = "backlight_switch" }),                   -- profile 미포함
    tuya.dp_child_lock(101, { name = "child_lock" }),                    -- profile 미포함
    tuya.dp_raw(102, { name = "backlight" }),                            -- profile 미포함
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

-- TS0601 touch panel switch family: relay channels plus hidden backlight/lock options.
local switch_1gang_touch_panel = {
  profile = "switches-switch-1",
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main" }),
    tuya.dp_power_on_behavior(14, {}),                                   -- profile 미포함
    tuya.dp_backlight_mode_off_on(16, {}),                                -- profile 미포함
    tuya.dp_child_lock(101, { name = "child_lock" }),                     -- profile 미포함
  },
  query_on_configure = true,
}

local switch_2gang_touch_panel = {
  profile = "switches-switch-2",
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main" }),
    tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
    tuya.dp_power_on_behavior(14, {}),                                   -- profile 미포함
    tuya.dp_backlight_mode_off_on(16, {}),                                -- profile 미포함
    tuya.dp_child_lock(101, { name = "child_lock" }),                     -- profile 미포함
  },
  query_on_configure = true,
}

local switch_3gang_touch_panel = {
  profile = "switches-switch-3",
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main" }),
    tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
    tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
    tuya.dp_power_on_behavior(14, {}),                                   -- profile 미포함
    tuya.dp_backlight_mode_off_on(16, {}),                                -- profile 미포함
    tuya.dp_child_lock(101, { name = "child_lock" }),                     -- profile 미포함
  },
  query_on_configure = true,
}

local switch_6gang_touch_panel = {
  profile = "switches-switch-6",
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main" }),
    tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
    tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
    tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
    tuya.dp_on_off(5, { name = "switch", component = "switch5" }),
    tuya.dp_on_off(6, { name = "switch", component = "switch6" }),
    tuya.dp_power_on_behavior(14, {}),                                   -- profile 미포함
    tuya.dp_backlight_mode_off_on(16, {}),                                -- profile 미포함
    tuya.dp_child_lock(101, { name = "child_lock" }),                     -- profile 미포함
  },
  query_on_configure = true,
}

local switch_1gang_stairwell = {
  profile = "switches-switch-1",
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main" }),
    tuya.dp_child_lock(29, { name = "child_lock" }),                      -- profile 미포함
  },
  query_on_configure = true,
}

local switch_1gang_multifunction = {
  profile = "switches-switch-1",
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main" }),
    tuya.dp_countdown(7, { name = "countdown" }),                         -- profile 미포함
    tuya.dp_power_on_behavior(14, {}),                                    -- profile 미포함
    tuya.dp_indicator_mode_none_relay_pos(15, {}),                        -- profile 미포함
    tuya.dp_backlight_mode_off_on(16, {}),                                -- profile 미포함
    tuya.dp_inching_switch(19, { name = "inching_switch" }),              -- profile 미포함
    tuya.dp_child_lock(101, { name = "child_lock" }),                     -- profile 미포함
    tuya.dp_numeric(102, { name = "backlight_brightness" }),              -- profile 미포함
    tuya.dp_enum(103, { name = "on_color", converter = backlight_color_converter }), -- profile 미포함
    tuya.dp_enum(104, { name = "off_color", converter = backlight_color_converter }), -- profile 미포함
  },
  query_on_configure = true,
}

local switch_1gang_power_monitoring = {
  profile = "switches-switch-1-power-energy-voltage-current",
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main" }),
    tuya.dp_countdown(7, { name = "countdown" }),                         -- profile 미포함
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

-- TO-6 W/B: 6 relay outputs are DP24~29; scene/config DPs stay hidden.
local switch_6gang_dp24_scene_panel = {
  profile = "switches-switch-6",
  datapoints = {
    tuya.dp_enum(1, { name = "action_l1" }),                             -- profile 미포함
    tuya.dp_enum(2, { name = "action_l2" }),                             -- profile 미포함
    tuya.dp_enum(3, { name = "action_l3" }),                             -- profile 미포함
    tuya.dp_enum(4, { name = "action_l4" }),                             -- profile 미포함
    tuya.dp_enum(5, { name = "action_l5" }),                             -- profile 미포함
    tuya.dp_enum(6, { name = "action_l6" }),                             -- profile 미포함
    tuya.dp_enum(18, { name = "mode_l1" }),                              -- profile 미포함
    tuya.dp_enum(19, { name = "mode_l2" }),                              -- profile 미포함
    tuya.dp_enum(20, { name = "mode_l3" }),                              -- profile 미포함
    tuya.dp_enum(21, { name = "mode_l4" }),                              -- profile 미포함
    tuya.dp_enum(22, { name = "mode_l5" }),                              -- profile 미포함
    tuya.dp_enum(23, { name = "mode_l6" }),                              -- profile 미포함
    tuya.dp_on_off(24, { name = "switch", component = "main" }),
    tuya.dp_on_off(25, { name = "switch", component = "switch2" }),
    tuya.dp_on_off(26, { name = "switch", component = "switch3" }),
    tuya.dp_on_off(27, { name = "switch", component = "switch4" }),
    tuya.dp_on_off(28, { name = "switch", component = "switch5" }),
    tuya.dp_on_off(29, { name = "switch", component = "switch6" }),
    tuya.dp_countdown(30, { name = "countdown_l1" }),                    -- profile 미포함
    tuya.dp_countdown(31, { name = "countdown_l2" }),                    -- profile 미포함
    tuya.dp_countdown(32, { name = "countdown_l3" }),                    -- profile 미포함
    tuya.dp_countdown(33, { name = "countdown_l4" }),                    -- profile 미포함
    tuya.dp_countdown(34, { name = "countdown_l5" }),                    -- profile 미포함
    tuya.dp_countdown(35, { name = "countdown_l6" }),                    -- profile 미포함
    tuya.dp_backlight_mode_off_on(36, {}),                               -- profile 미포함
    tuya.dp_indicator_mode_none_relay_pos(37, { name = "indicator_status" }), -- profile 미포함
    tuya.dp_power_on_behavior(38, {}),                                   -- profile 미포함
    tuya.dp_binary(103, { name = "induction" }),                         -- profile 미포함
    tuya.dp_enum(104, { name = "vibration_gear" }),                      -- profile 미포함
    tuya.dp_countdown(105, { name = "inching_l1" }),                     -- profile 미포함
    tuya.dp_countdown(106, { name = "inching_l2" }),                     -- profile 미포함
    tuya.dp_countdown(107, { name = "inching_l3" }),                     -- profile 미포함
    tuya.dp_countdown(108, { name = "inching_l4" }),                     -- profile 미포함
    tuya.dp_countdown(109, { name = "inching_l5" }),                     -- profile 미포함
    tuya.dp_countdown(110, { name = "inching_l6" }),                     -- profile 미포함
  },
  query_on_configure = true,
}

register_device_definition(switch_6gang_dp24_scene_panel, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_rqhnxkqu",
}))

-- M9-zigbee-SL: 8 channel mixed switch/scene/presence panel
local switch_8gang_m9_motion_scene = {
  profile = "switches-switch-8",
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main" }),
    tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
    tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
    tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
    tuya.dp_on_off(5, { name = "switch", component = "switch5" }),
    tuya.dp_on_off(6, { name = "switch", component = "switch6" }),
    tuya.dp_on_off(112, { name = "switch", component = "switch7" }),
    tuya.dp_on_off(113, { name = "switch", component = "switch8" }),
    tuya.dp_binary(16, { name = "backlight_mode" }),                     -- profile 미포함
    tuya.dp_enum(29, { name = "power_on_behavior_l1" }),                 -- profile 미포함
    tuya.dp_enum(30, { name = "power_on_behavior_l2" }),                 -- profile 미포함
    tuya.dp_enum(31, { name = "power_on_behavior_l3" }),                 -- profile 미포함
    tuya.dp_enum(32, { name = "power_on_behavior_l4" }),                 -- profile 미포함
    tuya.dp_enum(33, { name = "power_on_behavior_l5" }),                 -- profile 미포함
    tuya.dp_enum(34, { name = "power_on_behavior_l6" }),                 -- profile 미포함
    tuya.dp_numeric(105, { name = "presence" }),                         -- profile 미포함
    tuya.dp_numeric(106, { name = "delay" }),                            -- profile 미포함
  },
  query_on_configure = true,
}

register_device_definition(switch_8gang_m9_motion_scene, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_nvodulvi",
  "_TZE284_nvodulvi",
}))

-- M9-zigbee-SL-2: 4 relay + scene/presence panel
local switch_4gang_m9_scene = {
  profile = "switches-switch-4",
  datapoints = {
    tuya.dp_on_off(24, { name = "switch", component = "main" }),
    tuya.dp_on_off(25, { name = "switch", component = "switch2" }),
    tuya.dp_on_off(26, { name = "switch", component = "switch3" }),
    tuya.dp_on_off(27, { name = "switch", component = "switch4" }),
    tuya.dp_enum(18, { name = "switch_mode_l1" }),                       -- profile 미포함
    tuya.dp_enum(19, { name = "switch_mode_l2" }),                       -- profile 미포함
    tuya.dp_enum(20, { name = "switch_mode_l3" }),                       -- profile 미포함
    tuya.dp_enum(21, { name = "switch_mode_l4" }),                       -- profile 미포함
    tuya.dp_enum(36, { name = "backlight_mode" }),                       -- profile 미포함
    tuya.dp_enum(38, { name = "power_on_behavior_l0" }),                 -- profile 미포함
    tuya.dp_enum(39, { name = "power_on_behavior_l1" }),                 -- profile 미포함
    tuya.dp_enum(40, { name = "power_on_behavior_l2" }),                 -- profile 미포함
    tuya.dp_enum(41, { name = "power_on_behavior_l3" }),                 -- profile 미포함
    tuya.dp_enum(42, { name = "power_on_behavior_l4" }),                 -- profile 미포함
    tuya.dp_numeric(101, { name = "presence" }),                         -- profile 미포함
    tuya.dp_numeric(102, { name = "delay" }),                            -- profile 미포함
  },
  query_on_configure = true,
}

register_device_definition(switch_4gang_m9_scene, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_yrwmnya3",
}))

-- F3-Pro / M8Pro smart panels: expose relay surface, keep scene/light/cover metadata hidden.
local switch_4gang_smart_panel = {
  profile = "switches-switch-4",
  datapoints = {
    tuya.dp_on_off(121, { name = "switch", component = "main" }),
    tuya.dp_on_off(122, { name = "switch", component = "switch2" }),
    tuya.dp_on_off(123, { name = "switch", component = "switch3" }),
    tuya.dp_on_off(124, { name = "switch", component = "switch4" }),
    tuya.dp_light(102, { name = "led_bright_l1" }),                      -- profile 미포함
    tuya.dp_light(103, { name = "led_bright_l2" }),                      -- profile 미포함
    tuya.dp_light(105, { name = "led_bright_l3" }),                      -- profile 미포함
    tuya.dp_light(107, { name = "led_bright_l4" }),                      -- profile 미포함
    tuya.dp_cover_position(113, { name = "cover_position_l1" }),         -- profile 미포함
    tuya.dp_cover_position(114, { name = "cover_position_l2" }),         -- profile 미포함
    tuya.dp_cover_position(115, { name = "cover_position_l3" }),         -- profile 미포함
    tuya.dp_cover_position(116, { name = "cover_position_l4" }),         -- profile 미포함
  },
  query_on_configure = true,
}

register_device_definition(switch_4gang_smart_panel, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_7zazvlyn",
  "_TZE284_idn2htgu",
}))

local switch_4gang_lcd_panel = {
  profile = "switches-switch-4",
  datapoints = {
    tuya.dp_on_off(24, { name = "switch", component = "main" }),
    tuya.dp_on_off(25, { name = "switch", component = "switch2" }),
    tuya.dp_on_off(26, { name = "switch", component = "switch3" }),
    tuya.dp_on_off(27, { name = "switch", component = "switch4" }),
    tuya.dp_enum(18, { name = "mode_l1" }),                              -- profile 미포함
    tuya.dp_enum(19, { name = "mode_l2" }),                              -- profile 미포함
    tuya.dp_enum(20, { name = "mode_l3" }),                              -- profile 미포함
    tuya.dp_enum(21, { name = "mode_l4" }),                              -- profile 미포함
    tuya.dp_enum(36, { name = "backlight_switch" }),                     -- profile 미포함
    tuya.dp_enum(37, { name = "indicator_switch" }),                     -- profile 미포함
  },
  query_on_configure = true,
}

register_device_definition(switch_4gang_lcd_panel, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_atuj3i0w",
  "_TZE284_iwyqtclw",
}))

-- DS-1450WN: 2 plug + USB-A/USB-C metered outlet
local switch_4gang_metered_usb = {
  profile = "switches-switch-4-energy-voltage-current",
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main" }),
    tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
    tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
    tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
    tuya.dp_countdown(7, { name = "countdown_usb_a" }),                  -- profile 미포함
    tuya.dp_countdown(8, { name = "countdown_usb_c" }),                  -- profile 미포함
    tuya.dp_countdown(9, { name = "countdown_plug_1" }),                 -- profile 미포함
    tuya.dp_countdown(10, { name = "countdown_plug_2" }),                -- profile 미포함
    tuya.dp_enum(14, { name = "relay_status" }),                         -- profile 미포함
    tuya.dp_binary(16, { name = "switch_backlight" }),                   -- profile 미포함
    tuya.dp_current(21, {}),
    tuya.dp_power(22, {}),
    tuya.dp_voltage(23, {}),
    tuya.dp_energy(105, { name = "produced_energy" }),                   -- profile 미포함
    tuya.dp_child_lock(106, { name = "child_lock" }),                    -- profile 미포함
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
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_power_on_behavior(14, {}),                                                              -- 프로파일 미포함
  tuya.dp_enum(15, { name = "indicate_light", converter = converter.lookup_from_to({ off = 0, switch = 1, position = 2, freeze = 3 }) }), -- 프로파일 미포함
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
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_power_on_behavior(14, {}),                                                              -- 프로파일 미포함
  tuya.dp_enum(15, { name = "indicate_light", converter = converter.lookup_from_to({ off = 0, switch = 1, position = 2, freeze = 3 }) }), -- 프로파일 미포함
}

register_device_definition(switch_model_zts_eu_2gang, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_g1ib5ldv",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-9. switch_model_zts_eu_3gang: Moes 터치 3구 + indicate_light + power_on_behavior
-- Z2M: ZTS-EU_3gang
-- ══════════════════════════════════════════════════════════════
local switch_model_zts_eu_3gang = {
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
  tuya.dp_power_on_behavior(14, {}),                                                              -- 프로파일 미포함
  tuya.dp_enum(15, { name = "indicate_light", converter = converter.lookup_from_to({ off = 0, switch = 1, position = 2, freeze = 3 }) }), -- 프로파일 미포함
}

register_device_definition(switch_model_zts_eu_3gang, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_tz32mtza",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-10. switch_model_zts_eu_4gang: Moes 터치 4구 + indicate_light + power_on_behavior
-- Z2M: ZTS-EU_4gang
-- ══════════════════════════════════════════════════════════════
local switch_model_zts_eu_4gang = {
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
  tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
  tuya.dp_power_on_behavior(14, {}),                                                              -- 프로파일 미포함
  tuya.dp_enum(15, { name = "indicate_light", converter = converter.lookup_from_to({ off = 0, switch = 1, position = 2, freeze = 3 }) }), -- 프로파일 미포함
}

register_device_definition(switch_model_zts_eu_4gang, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_1ozguk6x",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-11. switch_model_zs_tyg3_sm_21z: 2구 + all state + countdown + backlight + power_on_behavior
-- Z2M: ZS-TYG3-SM-21Z
-- ══════════════════════════════════════════════════════════════
local switch_model_zs_tyg3_sm_21z = {
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_countdown(7, { name = "countdown", component = "main" }),       -- 프로파일 미포함
  tuya.dp_countdown(8, { name = "countdown", component = "switch2" }),    -- 프로파일 미포함
  tuya.dp_on_off(13, { name = "state" }),                                  -- 프로파일 미포함
  tuya.dp_power_on_behavior(14, {}),                                       -- 프로파일 미포함
  tuya.dp_backlight_mode_off_on(16, {}),                                   -- 프로파일 미포함
}

register_device_definition(switch_model_zs_tyg3_sm_21z, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_wunufsil",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-12. switch_model_zs_tyg3_sm_31z: 3구 + all state + countdown + backlight + power_on_behavior
-- Z2M: ZS-TYG3-SM-31Z
-- ══════════════════════════════════════════════════════════════
local switch_model_zs_tyg3_sm_31z = {
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
  tuya.dp_countdown(7, { name = "countdown", component = "main" }),       -- 프로파일 미포함
  tuya.dp_countdown(8, { name = "countdown", component = "switch2" }),    -- 프로파일 미포함
  tuya.dp_countdown(9, { name = "countdown", component = "switch3" }),    -- 프로파일 미포함
  tuya.dp_on_off(13, { name = "state" }),                                  -- 프로파일 미포함
  tuya.dp_power_on_behavior(14, {}),                                       -- 프로파일 미포함
  tuya.dp_backlight_mode_off_on(16, {}),                                   -- 프로파일 미포함
}

register_device_definition(switch_model_zs_tyg3_sm_31z, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_vhy3iakz",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-13. switch_model_zs_tyg3_sm_41z: 4구 + all state + countdown + backlight + power_on_behavior
-- Z2M: ZS-TYG3-SM-41Z
-- ══════════════════════════════════════════════════════════════
local switch_model_zs_tyg3_sm_41z = {
  profile = "switches-switch-4",
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
  tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
  tuya.dp_countdown(7, { name = "countdown", component = "main" }),       -- 프로파일 미포함
  tuya.dp_countdown(8, { name = "countdown", component = "switch2" }),    -- 프로파일 미포함
  tuya.dp_countdown(9, { name = "countdown", component = "switch3" }),    -- 프로파일 미포함
  tuya.dp_countdown(10, { name = "countdown", component = "switch4" }),   -- 프로파일 미포함
  tuya.dp_on_off(13, { name = "state" }),                                  -- 프로파일 미포함
  tuya.dp_power_on_behavior(14, {}),                                       -- 프로파일 미포함
  tuya.dp_backlight_mode_off_on(16, {}),                                   -- 프로파일 미포함
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
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
  tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
  tuya.dp_on_off(5, { name = "switch", component = "switch5" }),          -- 프로파일 미포함
  tuya.dp_on_off(6, { name = "switch", component = "switch6" }),          -- 프로파일 미포함
  tuya.dp_countdown(7, { name = "countdown", component = "main" }),       -- 프로파일 미포함
  tuya.dp_countdown(8, { name = "countdown", component = "switch2" }),    -- 프로파일 미포함
  tuya.dp_countdown(9, { name = "countdown", component = "switch3" }),    -- 프로파일 미포함
  tuya.dp_countdown(10, { name = "countdown", component = "switch4" }),   -- 프로파일 미포함
  tuya.dp_countdown(11, { name = "countdown", component = "switch5" }),   -- 프로파일 미포함
  tuya.dp_countdown(12, { name = "countdown", component = "switch6" }),   -- 프로파일 미포함
  tuya.dp_on_off(13, { name = "state" }),                                  -- 프로파일 미포함
  tuya.dp_power_on_behavior(14, {}),                                       -- 프로파일 미포함
  tuya.dp_backlight_mode_off_on(16, {}),                                   -- 프로파일 미포함
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
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
  tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
  tuya.dp_backlight_mode_off_on(7, {}),                                   -- 프로파일 미포함
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
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_countdown(7, { name = "countdown", component = "main" }),       -- 프로파일 미포함
  tuya.dp_power_on_behavior(14, {}),                                       -- 프로파일 미포함
  tuya.dp_backlight_mode_off_on(16, {}),                                   -- 프로파일 미포함
  tuya.dp_current(21, {}),                                                 -- 프로파일 미포함
  tuya.dp_power(22, {}),                                                   -- 프로파일 미포함
  tuya.dp_voltage(23, {}),                                                 -- 프로파일 미포함
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
  profile = "switches-switch-16",
  tuya.dp_on_off(1, { name = "switch_all" }),                            -- profile 미포함
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
  tuya.dp_power_on_behavior(117, {}),                                     -- profile 미포함
  tuya.dp_enum(118, { name = "switch_type_l1_l8" }),                     -- profile 미포함
  tuya.dp_enum(119, { name = "switch_type_l9_l16" }),                    -- profile 미포함
  tuya.dp_enum(120, { name = "switch_mode_l11_l12" }),                   -- profile 미포함
  tuya.dp_enum(121, { name = "switch_mode_l13_l14" }),                   -- profile 미포함
  tuya.dp_enum(122, { name = "switch_mode_l15_l16" }),                   -- profile 미포함
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
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
  tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
  tuya.dp_on_off(5, { name = "switch", component = "switch5" }),
  tuya.dp_on_off(6, { name = "switch", component = "switch6" }),
  tuya.dp_on_off(7, { name = "switch", component = "switch7" }),
  tuya.dp_on_off(8, { name = "switch", component = "switch8" }),
  tuya.dp_countdown(9, { name = "countdown", component = "main" }),       -- 프로파일 미포함
  tuya.dp_countdown(10, { name = "countdown", component = "switch2" }),   -- 프로파일 미포함
  tuya.dp_countdown(11, { name = "countdown", component = "switch3" }),   -- 프로파일 미포함
  tuya.dp_countdown(12, { name = "countdown", component = "switch4" }),   -- 프로파일 미포함
  tuya.dp_countdown(13, { name = "countdown", component = "switch5" }),   -- 프로파일 미포함
  tuya.dp_countdown(14, { name = "countdown", component = "switch6" }),   -- 프로파일 미포함
  tuya.dp_countdown(15, { name = "countdown", component = "switch7" }),   -- 프로파일 미포함
  tuya.dp_countdown(16, { name = "countdown", component = "switch8" }),   -- 프로파일 미포함
  tuya.dp_power_on_behavior(27, {}),                                       -- 프로파일 미포함
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




