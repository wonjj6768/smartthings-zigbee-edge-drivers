-- EF00 relay and metered-switch families owned by the switch-basic package.
local tuya = require "protocol.tuya"
local zcl = require "protocol.zcl"
local device_helpers = require "contracts.helpers.family"
local emit = require "capabilities.events.all"
local common = require "contracts.helpers.ef00_switches"

local converter = tuya.converter
local panel_off_on_converter = common.panel_off_on_converter
local device_definitions, register_device_definition = device_helpers.definition_registry()


-- ══════════════════════════════════════════════════════════════
-- 1-1. switch_1gang: 기본 1구
-- Z2M: TS0601_switch_1_gang / X711A
-- ══════════════════════════════════════════════════════════════
local switch_1gang = {
  profile = "switches-switch-1",
  package_group = "switch-basic",
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
  package_group = "switch-basic",
  datapoints = {
    tuya.dp_on_off(2, { name = "switch", component = "main" }),
    tuya.dp_temperature(27, { name = "temperature" }),
  },
  query_on_configure = true,
}

local switch_1gang_temperature_humidity_scimagic = {
  profile = "switches-switch-1-temp-humidity-scimagic",
  package_group = "switch-basic",
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
  package_group = "switch-basic",
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
  package_group = "switch-basic",
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
  package_group = "switch-basic",
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
  package_group = "switch-basic",
  datapoints = {
    tuya.dp_temperature(102, { name = "temperature" }),
    tuya.dp_humidity(103, { name = "humidity" }),
  },
  zcl_clusters = {
    zcl.switch({ read_only = false }),
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
  package_group = "switch-basic",
  datapoints = {
    tuya.dp_temperature(102, { name = "temperature" }),
    tuya.dp_humidity(103, { name = "humidity" }),
  },
  zcl_clusters = {
    zcl.switch({ endpoint = 1, component = "main", read_only = false }),
    zcl.switch({ endpoint = 2, component = "switch2", read_only = false }),
    zcl.switch({ endpoint = 3, component = "switch3", read_only = false }),
    zcl.switch({ endpoint = 4, component = "switch4", read_only = false }),
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
  package_group = "switch-basic",
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
  package_group = "switch-basic",
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
  package_group = "switch-basic",
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

-- ══════════════════════════════════════════════════════════════
-- 1-5. switch_5gang: 기본 5구
-- Z2M: TS0601_switch_5_gang
-- ══════════════════════════════════════════════════════════════
local switch_5gang = {
  package_group = "switch-basic",
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
  package_group = "switch-basic",
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

local switch_1gang_power_monitoring = {
  profile = "switches-switch-1-power-energy-voltage-current-apiu",
  package_group = "switch-basic",
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

register_device_definition(switch_1gang_power_monitoring, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_apiu8k13",
}))

-- KRC-103: 6 gang kinetic switch actuator (DP19~24)
local switch_6gang_dp19 = {
  profile = "switches-switch-6",
  package_group = "switch-basic",
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

-- DS-1450WN: 2 plug + USB-A/USB-C metered outlet
local switch_4gang_metered_usb = {
  profile = "switches-switch-4-energy-voltage-current-usb",
  package_group = "switch-basic",
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
  package_group = "switch-basic",
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
-- 1-16. switch_1gang_model_mg_zg01w: 1구 + countdown + power meter + backlight + power_on_behavior
-- Z2M: MG-ZG01W
-- ══════════════════════════════════════════════════════════════
local switch_1gang_model_mg_zg01w = {
  profile = "switches-switch-1-power-voltage-current-mg-zg01w",
  package_group = "switch-basic",
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
  package_group = "switch-basic",
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
  package_group = "switch-basic",
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
-- 1-22. switch_24gang: 기본 24구 (7~24채널이 DP 101~118)
-- Z2M: ZYXH_switch_24
-- ══════════════════════════════════════════════════════════════
local switch_24gang = {
  package_group = "switch-basic",
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
  package_group = "switch-basic",
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
-- 1-24. switch_1gang_dp16: 단일 스위치가 DP 16 사용
-- Z2M: R3 Smart Switch
-- ══════════════════════════════════════════════════════════════
local switch_1gang_dp16 = {
  package_group = "switch-basic",
  tuya.dp_on_off(16, { name = "switch", component = "main" }),
}

register_device_definition(switch_1gang_dp16, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_hiith90n",
}))

return {
  id = "ef00.switch.basic",
  registrations = device_definitions,
}
