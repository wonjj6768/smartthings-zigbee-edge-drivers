-- 안전 디바이스 정의 (연기, 가스, CO, 누수, 진동)
-- Z2M zigbee-herdsman-converters 기반 DP 그룹핑
--
-- 변수명 규칙: {category}_{variant}
--   category: smoke (연기감지기)
--             gas   (가스감지기)
--             co    (일산화탄소감지기)
--             water (누수센서)
--             vibration (진동센서)

local tuya = require "tuya_common"
local emit = require "emitters"
local device_helpers = require "devices.shared.helpers"
local capabilities = require "st.capabilities"

local converter = tuya.converter

local device_definitions, register_device_definition = device_helpers.definition_registry()

local siren_yxzbsl_volume_converter = converter.lookup_from_to({
  low = 0,
  middle = 1,
  high = 2,
  mute = 3,
})
local hobeian_alarm_volume_converter = siren_yxzbsl_volume_converter
local hobeian_alarm_ring_converter = converter.lookup_from_to({
  mute = 0,
  beep = 1,
  music = 2,
})
local siren_yxzbsl_ringtone_converter = converter.lookup_from_to({
  melody1 = 0,
  melody2 = 1,
  melody3 = 2,
  melody4 = 3,
  melody5 = 4,
  melody6 = 5,
  melody7 = 6,
  melody8 = 7,
  door = 8,
  water = 9,
  temperature = 10,
  entered = 11,
  left = 12,
})
local siren_za03_volume_converter = converter.lookup_from_to({
  low = 0,
  medium = 1,
  high = 2,
  mute = 3,
})
local siren_za03_ringtone_converter = converter.lookup_from_to({
  ringtone_1 = 0,
  ringtone_2 = 1,
  ringtone_3 = 2,
  ringtone_4 = 3,
  ringtone_5 = 4,
  ringtone_6 = 5,
  ringtone_7 = 6,
  ringtone_8 = 7,
  ringtone_9 = 8,
  ringtone_10 = 9,
  ringtone_11 = 10,
  ringtone_12 = 11,
  ringtone_13 = 12,
  ringtone_14 = 13,
  ringtone_15 = 14,
  ringtone_16 = 15,
  ringtone_17 = 16,
  ringtone_18 = 17,
  ringtone_19 = 18,
  ringtone_20 = 19,
  ringtone_21 = 20,
  ringtone_22 = 21,
  ringtone_23 = 22,
  ringtone_24 = 23,
  ringtone_25 = 24,
  ringtone_26 = 25,
  ringtone_27 = 26,
  ringtone_28 = 27,
  ringtone_29 = 28,
  ringtone_30 = 29,
  ringtone_31 = 30,
  ringtone_32 = 31,
})
local function emit_opening_state(custom_emitter)
  return function(device, value)
    local events = {}
    local contact_value = value == "closed" and "closed" or "open"
    events[#events + 1] = capabilities.contactSensor.contact(contact_value)

    local custom_event = custom_emitter(device, value)
    if custom_event ~= nil then
      events[#events + 1] = custom_event
    end

    return events
  end
end

local function emit_smoke_state(custom_emitter)
  return function(device, value)
    local events = {
      capabilities.smokeDetector.smoke(value == "alarm" and "detected" or "clear"),
    }

    local custom_event = custom_emitter(device, value)
    if custom_event ~= nil then
      events[#events + 1] = custom_event
    end

    return events
  end
end

-- ══════════════════════════════════════════════════════════════
-- 1-1. smoke: 기본형 (battery_state enum)
-- Z2M: _TZE200_ux5v4dbd (TS0601_smoke_3)
-- ══════════════════════════════════════════════════════════════
local smoke = {
  profile = "safety-smoke-battery-state-ux5v4dbd",
  tuya.dp_smoke(1, { emit = emit.smoke() }),
  tuya.dp_enum(14, {
    name = "battery_state",
    emit = emit.ux5v4dbdSmokeBatteryState(),
    converter = converter.from_only(converter.lookup_value({ [0] = "low", [1] = "medium", [2] = "high" })),
  }),
}

register_device_definition(smoke, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_ux5v4dbd",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-2. smoke_tamper_battery_low: tamper + battery_low (bool)
-- Z2M: _TZE200_0zaf1cr8 (TS0601_smoke_1 / Nous E8)
-- ══════════════════════════════════════════════════════════════
local smoke_tamper_battery_low = {
  profile = "safety-smoke-tamper-battery-low",
  tuya.dp_smoke(1, { emit = emit.smoke() }),
  tuya.dp_tamper(4, { emit = emit.tamper() }),
  tuya.dp_battery_low(14, { emit = emit.battery_low() }),
}

register_device_definition(smoke_tamper_battery_low, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_0zaf1cr8",
  "_TZE204_ntcy3xu1",
  "_TZE284_0zaf1cr8",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-3. smoke_tamper: tamper + battery_state (enum)
-- Z2M: _TZE200_ntcy3xu1 (TS0601_smoke_6)
-- ══════════════════════════════════════════════════════════════
local smoke_tamper = {
  profile = "safety-smoke-tamper-battery-state-ntcy3xu1",
  tuya.dp_smoke(1, { emit = emit.smoke() }),
  tuya.dp_tamper(4, { emit = emit.tamper() }),
  tuya.dp_enum(14, {
    name = "battery_state",
    emit = emit.ntcy3xu1SmokeBatteryState(),
    converter = converter.from_only(converter.lookup_value({ [0] = "low", [1] = "medium", [2] = "high" })),
  }),
}

register_device_definition(smoke_tamper, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_ntcy3xu1",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-4. smoke_battery: battery_state + battery numeric
-- Z2M: _TZE200_t5p1vj8r (TS0601_smoke_4)
-- ══════════════════════════════════════════════════════════════
local smoke_battery = {
  profile = "safety-smoke-battery-state-battery-t5p1vj8r",
  tuya.dp_smoke(1, { emit = emit.smoke() }),
  tuya.dp_enum(14, {
    name = "battery_state",
    emit = emit.t5p1vj8rSmokeBatteryState(),
    converter = converter.from_only(converter.lookup_value({ [0] = "low", [1] = "medium", [2] = "high" })),
  }),
  tuya.dp_battery(15, { emit = emit.battery() }),
}

register_device_definition(smoke_battery, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_t5p1vj8r",
  "_TZE200_uebojraa",
  "_TZE200_vzekyi4c",
  "_TZE200_yh7aoahi",
  "_TZE200_dq1mfjug",
}))

-- GSKS-ZB: smoke + tamper + battery
local smoke_gsks_zb = {
  profile = "safety-smoke-tamper-battery",
  tuya.dp_smoke(1, { emit = emit.smoke() }),
  tuya.dp_tamper(4, { emit = emit.tamper() }),
  tuya.dp_battery(15, { emit = emit.battery() }),
}

register_device_definition(smoke_gsks_zb, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_qcasmfan",
}))

-- YXZBSL / ZA03 smart siren
local siren_alarm = {
  profile = "safety-alarm-battery-duration-volume-ringtone-yxzbsl",
  tuya.dp_enum(1, {
    name = "type",
    emit = emit.yxzbslAlarmType(),
    converter = converter.lookup_from_to({
      sound = 0,
      light = 1,
      sound_light = 2,
      normal = 3,
    }),
  }),
  tuya.dp_enum(5, { name = "volume", emit = emit.alarmVolumeSirenYxzbsl(), converter = siren_yxzbsl_volume_converter }),
  tuya.dp_enum(6, {
    name = "power_type",
    emit = emit.yxzbslPowerType(),
    read_only = true,
    converter = converter.from_only(function(value)
      return (value == true or value == 1) and "battery" or "cable"
    end),
  }),
  tuya.dp_numeric(7, { name = "duration", emit = emit.alarmDurationSirenYxzbslMinutes() }),
  tuya.dp_on_off(13, { name = "alarm", emit = emit.alarm() }),
  tuya.dp_enum(14, {
    name = "battery_level",
    emit = emit.yxzbslBatteryLevel(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "low",
      [1] = "middle",
      [2] = "high",
    })),
  }),
  tuya.dp_battery(15, { emit = emit.battery() }),
  tuya.dp_enum(21, { name = "ringtone", emit = emit.alarmRingtoneSirenYxzbsl(), converter = siren_yxzbsl_ringtone_converter }),
}

register_device_definition(siren_alarm, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_fncxk3ob",
  "_TZE204_k7mfgaen",
  "_TZE284_fncxk3ob",
}))

local siren_alarm_no_battery = {
  profile = "safety-alarm-duration-volume-ringtone-za03",
  tuya.dp_enum(5, { name = "volume", emit = emit.alarmVolumeSirenZa03(), converter = siren_za03_volume_converter }),
  tuya.dp_numeric(7, { name = "duration", emit = emit.alarmDurationSirenZa03Seconds() }),
  tuya.dp_on_off(13, { name = "alarm", emit = emit.alarm() }),
  tuya.dp_enum(21, { name = "ringtone", emit = emit.alarmRingtoneSirenZa03(), converter = siren_za03_ringtone_converter }),
}

register_device_definition(siren_alarm_no_battery, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_hcxvyxa5",
}))

-- HOBEIAN ZG-226Z: water leak alarm
local water_leak_alarm_zg226z = {
  profile = "safety-water-leak-alarm-battery-zg226z",
  tuya.dp_water_leak(1, { emit = emit.water(), converter = converter.true_false0() }),
  tuya.dp_on_off(101, { name = "alarm", emit = emit.alarm() }),
  tuya.dp_on_off(7, { name = "muffling", emit = emit.mufflingWaterLeak() }),
  tuya.dp_battery(4, { emit = emit.battery() }),
  tuya.dp_numeric(102, { name = "duration", emit = emit.alarmDurationSiren() }),
  tuya.dp_enum(104, { name = "alarm_volume", emit = emit.alarmVolumeHobeian(), converter = hobeian_alarm_volume_converter }),
  tuya.dp_enum(103, { name = "alarm_ring", emit = emit.alarmRingHobeian(), converter = hobeian_alarm_ring_converter }),
}

register_device_definition(water_leak_alarm_zg226z, {
  device_helpers.create_fingerprint("HOBEIAN", "ZG-226Z"),
})

-- HOBEIAN ZG-228Z: vibration alarm
local vibration_alarm_zg228z = {
  profile = "safety-acceleration-alarm-battery-zg228z",
  tuya.dp_enum(1, { name = "vibration", emit = emit.acceleration(), converter = converter.true_false1() }),
  tuya.dp_enum(101, {
    name = "vibration_siren",
    emit = emit.zg228zVibrationSiren(),
    converter = converter.lookup_from_to({ off = 0, on = 1 }),
  }),
  tuya.dp_enum(105, {
    name = "alarm",
    emit = emit.zg228zAlarmMode(),
    converter = converter.lookup_from_to({ beep = 0, ring = 1, stop = 2 }),
  }),
  tuya.dp_on_off(102, { name = "muffling", emit = emit.mufflingSiren() }),
  tuya.dp_battery(4, { emit = emit.battery() }),
  tuya.dp_numeric(106, { name = "duration", emit = emit.alarmDurationSiren() }),
  tuya.dp_numeric(6, { name = "sensitivity", emit = emit.vibrationSensitivityZgFifty() }),
  tuya.dp_enum(103, { name = "alarm_volume", emit = emit.alarmVolumeHobeian(), converter = hobeian_alarm_volume_converter }),
  tuya.dp_enum(104, { name = "alarm_ring", emit = emit.alarmRingHobeian(), converter = hobeian_alarm_ring_converter }),
}

register_device_definition(vibration_alarm_zg228z, {
  device_helpers.create_fingerprint("HOBEIAN", "ZG-228Z"),
})

-- HOBEIAN ZG-229Z: smart light & sound siren
local siren_alarm_zg229z = {
  profile = "safety-alarm-battery-zg229z",
  tuya.dp_enum(1, {
    name = "alarm",
    emit = emit.zg229zAlarmMode(),
    converter = converter.lookup_from_to({
      alarm_sound = 0,
      alarm_light = 1,
      alarm_sound_light = 2,
      normal = 3,
    }),
  }),
  tuya.dp_on_off(102, { name = "doorbell", emit = emit.doorbellSirenHobeian() }),
  tuya.dp_on_off(16, { name = "muffling", emit = emit.mufflingSiren() }),
  tuya.dp_battery(15, { emit = emit.battery() }),
  tuya.dp_numeric(7, { name = "duration", emit = emit.alarmDurationSiren() }),
  tuya.dp_enum(5, { name = "volume", emit = emit.alarmVolumeHobeian(), converter = hobeian_alarm_volume_converter }),
  tuya.dp_enum(101, { name = "doorbell_volume", emit = emit.doorbellVolumeHobeian(), converter = hobeian_alarm_volume_converter }),
}

register_device_definition(siren_alarm_zg229z, {
  device_helpers.create_fingerprint("HOBEIAN", "ZG-229Z"),
})

-- ══════════════════════════════════════════════════════════════
-- 1-5. smoke_model_hs2sa_1: self_test + battery_state + battery + silence
-- Z2M: _TZE284_ai4rqhky (HS2SA-1 / Heiman)
-- ══════════════════════════════════════════════════════════════
local smoke_model_hs2sa_1 = {
  profile = "safety-smoke-battery-state-battery-self-test-silence-hs2sa",
  tuya.dp_smoke(1, { emit = emit.smoke() }),
  tuya.dp_enum(9, {
    name = "self_test",
    emit = emit.hs2saSelfTest(),
    converter = converter.from_only(converter.lookup_value({
      [0] = "checking",
      [1] = "check_success",
      [2] = "check_failure",
    })),
  }),
  tuya.dp_enum(14, {
    name = "battery_state",
    emit = emit.hs2saBatteryState(),
    converter = converter.from_only(converter.lookup_value({ [0] = "low", [1] = "medium", [2] = "high" })),
  }),
  tuya.dp_battery(15, { emit = emit.battery() }),
  tuya.dp_silence(16, { emit = emit.hs2saSilence() }),
}

register_device_definition(smoke_model_hs2sa_1, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_vawy74yh",
  "_TZE204_ai4rqhky",
  "_TZE204_vawy74yh",
  "_TZE284_ai4rqhky",
  "_TZE284_vawy74yh",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-6. smoke_concentration: smoke_concentration + device_fault + battery
-- Z2M: _TZE200_m9skfctm (PA-44Z)
-- ══════════════════════════════════════════════════════════════
local smoke_concentration = {
  profile = "safety-smoke-battery-concentration-fault-silence-test-pa44z",
  tuya.dp_smoke(1, { emit = emit.smoke() }),
  tuya.dp_smoke_concentration(2, { emit = emit.pa44zSmokeConcentration() }),
  tuya.dp_binary(11, {
    name = "device_fault",
    emit = emit.pa44zDeviceFault(),
    converter = converter.from_only(function(value)
      return (value == true or value == 1) and "fault" or "clear"
    end),
  }),
  tuya.dp_battery(15, { emit = emit.battery() }),
  tuya.dp_binary(16, {
    name = "silence",
    emit = emit.pa44zSilence(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_binary(101, {
    name = "test",
    emit = emit.pa44zTest(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
}

register_device_definition(smoke_concentration, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_m9skfctm",
  "_TZE200_rccxox8p",
  "_TZE2841000000_rccxox8p",
  "_TZE284_rccxox8p",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-7. smoke_concentration_fault_alarm: concentration + fault + battery_state + battery
-- Z2M: _TZE200_e2bedvo9 (ZSS-QY-SSD-A-EN)
-- ══════════════════════════════════════════════════════════════
local smoke_concentration_fault_alarm = {
  profile = "safety-smoke-battery-concentration-fault-state-silence-test-zss",
  tuya.dp_smoke(1, { emit = emit.smoke() }),
  tuya.dp_smoke_concentration(2, { emit = emit.zssSmokeConcentration() }),
  tuya.dp_binary(11, {
    name = "fault_alarm",
    emit = emit.zssFaultAlarm(),
    converter = converter.from_only(function(value)
      return (value == true or value == 1) and "fault" or "clear"
    end),
  }),
  tuya.dp_enum(14, {
    name = "battery_state",
    emit = emit.zssBatteryState(),
    converter = converter.from_only(converter.lookup_value({ [0] = "low", [1] = "medium", [2] = "high" })),
  }),
  tuya.dp_battery(15, { emit = emit.battery() }),
  tuya.dp_binary(16, {
    name = "silence",
    emit = emit.zssSilence(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_binary(17, {
    name = "self_test",
    emit = emit.zssSelfTest(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
}

register_device_definition(smoke_concentration_fault_alarm, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_e2bedvo9",
  "_TZE200_dnz6yvl2",
  "_TZE284_e2bedvo9",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-8. smoke_tamper_alarm: tamper + fault_alarm + battery + alarm
-- Z2M: _TZE200_ytibqbra (TS0601_smoke_5)
-- ══════════════════════════════════════════════════════════════
local smoke_tamper_alarm = {
  profile = "safety-smoke-tamper-battery-fault-silence-alarm-ytibqbra",
  tuya.dp_smoke(1, { emit = emit.smoke() }),
  tuya.dp_tamper(4, { emit = emit.tamper() }),
  tuya.dp_binary(11, {
    name = "fault_alarm",
    emit = emit.ytibqbraFaultAlarm(),
    converter = converter.from_only(function(value)
      return (value == true or value == 1) and "fault" or "clear"
    end),
  }),
  tuya.dp_battery(15, { emit = emit.battery() }),
  tuya.dp_binary(16, {
    name = "silence",
    emit = emit.ytibqbraSilence(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_binary(17, {
    name = "alarm_switch",
    emit = emit.ytibqbraAlarmSwitch(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
}

register_device_definition(smoke_tamper_alarm, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_ytibqbra",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-9. smoke_legacy: legacy (inverted smoke + alarm)
-- Z2M: _TZE200_5d3vhjro (SA12IZL)
-- ══════════════════════════════════════════════════════════════
local smoke_legacy = {
  profile = "safety-smoke-battery-silence-alarm-sa12izl",
  tuya.dp_smoke(1, { emit = emit.smoke() }),
  tuya.dp_battery(15, { emit = emit.battery() }),
  tuya.dp_binary(16, {
    name = "silence_siren",
    emit = emit.sa12izlSilenceSiren(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_enum(20, {
    name = "alarm",
    emit = emit.sa12izlAlarm(),
    converter = converter.lookup_from_to({ off = 1, on = 0 }),
  }),
}

register_device_definition(smoke_legacy, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_5d3vhjro",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-10. smoke_model_r7049: Woox (battery enum + alarm)
-- Z2M: _TZE200_aycxwiau (R7049)
-- ══════════════════════════════════════════════════════════════
local smoke_model_r7049 = {
  profile = "safety-smoke-test-result-battery-fault-silence-alarm-r7049",
  tuya.dp_smoke(1, { emit = emit.smoke() }),
  tuya.dp_binary(8, {
    name = "test_alarm",
    emit = emit.r7049TestAlarm(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_enum(9, {
    name = "test_alarm_result",
    emit = emit.r7049TestAlarmResult(),
    converter = converter.from_only(converter.lookup_value({
      [0] = "checking",
      [1] = "check_success",
      [2] = "check_failure",
      [3] = "others",
    })),
  }),
  tuya.dp_binary(11, {
    name = "fault_alarm",
    emit = emit.r7049FaultAlarm(),
    converter = converter.from_only(function(value)
      return (value == true or value == 1) and "fault" or "clear"
    end),
  }),
  tuya.dp_enum(14, {
    name = "battery_level",
    emit = emit.r7049BatteryLevel(),
    converter = converter.from_only(converter.lookup_value({
      [0] = "low",
      [1] = "middle",
      [2] = "high",
    })),
  }),
  tuya.dp_binary(16, {
    name = "silence_siren",
    emit = emit.r7049SilenceSiren(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_enum(20, {
    name = "alarm",
    emit = emit.r7049Alarm(),
    converter = converter.lookup_from_to({ off = 1, on = 0 }),
  }),
}

register_device_definition(smoke_model_r7049, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_aycxwiau",
  "_TZE200_bxdyeaa9",
  "_TZE200_ft523twt",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-11. smoke_model_smart_smoke10: Alecto (smoke_state enum)
-- Z2M: _TZE200_qtbrwrfv (SMART-SMOKE10)
-- ══════════════════════════════════════════════════════════════
local smoke_model_smart_smoke10 = {
  profile = "safety-smoke-value-self-check-result-lifecycle-battery-silence-alecto",
  tuya.dp_smoke(1, { emit = emit.smoke() }),
  tuya.dp_numeric(2, {
    name = "smoke_value",
    emit = emit.alectoSmoke10SmokeValue(),
  }),
  tuya.dp_binary(8, {
    name = "self_checking",
    emit = emit.alectoSmoke10SelfChecking(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_enum(9, {
    name = "checking_result",
    emit = emit.alectoSmoke10CheckingResult(),
    converter = converter.from_only(converter.lookup_value({
      [0] = "checking",
      [1] = "check_success",
      [2] = "check_failure",
      [3] = "others",
    })),
  }),
  tuya.dp_binary(11, { name = "smoke_test" }),                    -- Z2M converter-only; expose 없음
  tuya.dp_binary(12, {
    name = "lifecycle",
    emit = emit.alectoSmoke10Lifecycle(),
    converter = converter.from_only(converter.lookup_value({
      [false] = "inactive",
      [true] = "active",
      [0] = "inactive",
      [1] = "active",
    })),
  }),
  tuya.dp_enum(14, {
    name = "battery_state",
    emit = emit.alectoSmoke10BatteryState(),
    converter = converter.from_only(converter.lookup_value({
      [0] = "low",
      [1] = "middle",
      [2] = "high",
    })),
  }),
  tuya.dp_battery(15, { emit = emit.battery() }),
  tuya.dp_binary(16, {
    name = "silence",
    emit = emit.alectoSmoke10Silence(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
}

register_device_definition(smoke_model_smart_smoke10, {
  device_helpers.create_fingerprint("_TZE200_qtbrwrfv", "TS0601"),
  { manufacturer = "_TYST11_qtbrwrfv", model = "tbrwrfv" .. string.char(0) },
})

-- ══════════════════════════════════════════════════════════════
-- 1-12. smoke_model_288wz: ONENUO 288WZ
-- Z2M: _TZE204_kgaxpvxr / _TZE284_n4ttsck2 (288WZ)
-- ══════════════════════════════════════════════════════════════
local smoke_model_288wz = {
  profile = "safety-smoke-detector-battery-288wz",
  tuya.dp_enum(1, {
    name = "smoke_state",
    emit = emit_smoke_state(emit.onenuo288wzSmokeState()),
    converter = converter.from_only(converter.lookup_value({
      [0] = "alarm",
      [1] = "normal",
      [2] = "detecting",
      [3] = "unknown",
    })),
  }),
  tuya.dp_battery(15, { emit = emit.battery() }),
  tuya.dp_binary(16, {
    name = "silence",
    emit = emit.onenuo288wzSilence(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_binary(101, {
    name = "self_test_result",
    emit = emit.onenuo288wzSelfTestResult(),
    converter = converter.from_only(converter.lookup_value({
      [false] = "failure",
      [true] = "success",
      [0] = "failure",
      [1] = "success",
    })),
  }),
  tuya.dp_enum(102, {
    name = "sensitivity",
    emit = emit.sensitivitySmoke288wzEnum(),
    converter = converter.lookup_from_to({
      low = 0,
      medium = 1,
      high = 2,
    }),
  }),
}

register_device_definition(smoke_model_288wz, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_kgaxpvxr",
  "_TZE284_n4ttsck2",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-13. smoke_co: 연기 + CO 복합
-- Z2M: _TZE284_6ycgarab (TS0601_smoke_co)
-- ══════════════════════════════════════════════════════════════
local smoke_co = {
  profile = "safety-smoke-co-battery-state-volume-silence-alarm-smokeco",
  tuya.dp_enum(1, {
    name = "smoke_state",
    emit = emit_smoke_state(emit.smokeCoSmokeState()),
    converter = converter.from_only(converter.lookup_value({
      [0] = "alarm",
      [1] = "none",
      [2] = "detecting",
      [3] = "unknown",
    })),
  }),
  tuya.dp_enum(5, {
    name = "alarm_volume",
    emit = emit.smokeCoAlarmVolume(),
    converter = converter.lookup_from_to({
      low = 0,
      medium = 1,
      high = 2,
      mute = 3,
    }),
  }),
  tuya.dp_battery(15, { emit = emit.battery() }),
  tuya.dp_binary(16, {
    name = "silence",
    emit = emit.smokeCoSilence(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_binary(17, {
    name = "alarm_switch",
    emit = emit.smokeCoAlarmSwitch(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_carbon_monoxide(18, { emit = emit.carbon_monoxide() }),
}

register_device_definition(smoke_co, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_6ycgarab",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-14. smoke_temp_humidity: 연기 + 온도 + 습도
-- Z2M: _TZE284_gyzlwu5q (228WZH)
-- ══════════════════════════════════════════════════════════════
local smoke_temp_humidity = {
  profile = "safety-smoke-temp-humidity-battery",
  tuya.dp_smoke(1, { emit = emit.smoke() }),
  tuya.dp_enum(9, {
    name = "self_test",
    emit = emit.smoke228wzhSelfTest(),
    converter = converter.from_only(converter.lookup_value({
      [0] = "checking",
      [1] = "check_success",
      [2] = "check_failure",
    })),
  }),
  tuya.dp_enum(14, {
    name = "battery_state",
    emit = emit.smoke228wzhBatteryState(),
    converter = converter.from_only(converter.lookup_value({
      [0] = "low",
      [1] = "middle",
      [2] = "high",
    })),
  }),
  tuya.dp_binary(16, {
    name = "silence",
    emit = emit.smoke228wzhSilence(),
    converter = converter.lookup_from_to({ on = true }),
  }),
  tuya.dp_temperature(23, { emit = emit.temperature(), scale = 10 }),
  tuya.dp_humidity(24, { emit = emit.humidity(), scale = 1 }),
  tuya.dp_string(103, {
    name = "version",
    emit = emit.smoke228wzhVersion(),
    read_only = true,
  }),
}

register_device_definition(smoke_temp_humidity, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_gyzlwu5q",
}))

-- ══════════════════════════════════════════════════════════════
-- 2-1. gas_self_test_fault: 기본 가스 (self_test + fault)
-- Z2M: _TZE200_ggev5fsl (TS0601_gas_sensor_1)
-- ══════════════════════════════════════════════════════════════
local gas_self_test_fault = {
  profile = "safety-gas-detector-self-test",
  tuya.dp_gas(1, { emit = emit.gas() }),
  tuya.dp_binary(8, {
    name = "self_test",
    emit = emit.selfTestGas(),
    converter = converter.lookup_from_to({ on = true, off = false }),
  }),
  tuya.dp_enum(9, {
    name = "self_test_result",
    emit = emit.gasSensor1SelfTestResult(),
    converter = converter.from_only(converter.lookup_value({
      [0] = "checking",
      [1] = "success",
      [2] = "failure",
      [3] = "others",
    })),
  }),
  tuya.dp_binary(11, {
    name = "fault_alarm",
    emit = emit.gasSensor1FaultAlarm(),
    converter = converter.from_only(function(value)
      return (value == true or value == 1) and "fault" or "clear"
    end),
  }),
  tuya.dp_binary(16, {
    name = "silence",
    emit = emit.gasSensor1Silence(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
}

register_device_definition(gas_self_test_fault, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_ggev5fsl",
  "_TZE200_u319yc66",
  "_TZE200_kvpwq8z7",
  "_TZE204_kvpwq8z7",
}))

-- ══════════════════════════════════════════════════════════════
-- 2-2. gas_value_alarm_time_ringtone: 가스 농도 + 알람 시간/벨소리
-- Z2M: _TZE200_yojqa8xn (TS0601_gas_sensor_2)
-- ══════════════════════════════════════════════════════════════
local gas_value_alarm_time_ringtone = {
  profile = "safety-gas-detector-alarm-time-ringtone",
  tuya.dp_enum(1, {
    name = "gas",
    emit = emit.gas(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = true,
      [1] = false,
    })),
  }),
  tuya.dp_numeric(2, {
    name = "gas_value",
    emit = emit.gasSensor2GasValue(),
    read_only = true,
    converter = converter.divide_by_from_only(10),
  }),
  tuya.dp_alarm_ringtone(6, { emit = emit.alarmMelodyGasFive() }),
  tuya.dp_alarm_time(7, { emit = emit.alarmDurationGas180() }),
  tuya.dp_binary(8, {
    name = "self_test",
    emit = emit.selfTestGas(),
    converter = converter.lookup_from_to({ on = true, off = false }),
  }),
  tuya.dp_enum(9, {
    name = "self_test_result",
    emit = emit.gasSensor2SelfTestResult(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "checking",
      [1] = "success",
      [2] = "failure",
      [3] = "others",
    })),
  }),
  tuya.dp_binary(10, {
    name = "preheat",
    emit = emit.gasSensor2Preheat(),
    read_only = true,
    converter = converter.from_only(function(value)
      return value and "on" or "off"
    end),
  }),
  tuya.dp_binary(16, {
    name = "silence",
    emit = emit.gasSensor2Silence(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
}

register_device_definition(gas_value_alarm_time_ringtone, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_yojqa8xn",
  "_TZE204_zougpkpy",
  "_TZE204_chbyv06x",
  "_TZE204_yojqa8xn",
  "_TZE284_chbyv06x",
  "_TZE28C1000000_chbyv06x",
}))

-- ══════════════════════════════════════════════════════════════
-- 2-3. gas_self_test_result_fault: 최소 가스 (self_test_result + fault)
-- Z2M: _TZE200_nus5kk3n (TS0601_gas_sensor_3)
-- ══════════════════════════════════════════════════════════════
local gas_self_test_result_fault = {
  profile = "safety-gas-detector-self-test-result-fault-gas3",
  tuya.dp_gas(1, { emit = emit.gas() }),
  tuya.dp_enum(9, {
    name = "self_test_result",
    emit = emit.gasSensor3SelfTestResult(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "checking",
      [1] = "success",
      [2] = "failure",
      [3] = "others",
    })),
  }),
  tuya.dp_binary(11, {
    name = "fault_alarm",
    emit = emit.gasSensor3FaultAlarm(),
    read_only = true,
    converter = converter.from_only(function(value)
      return (value == true or value == 1) and "fault" or "clear"
    end),
  }),
}

register_device_definition(gas_self_test_result_fault, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_nus5kk3n",
}))

-- ══════════════════════════════════════════════════════════════
-- 2-4. gas_value_preheat_fault: 가스 농도 + preheat + fault
-- Z2M: _TZE200_mby4kbtq (TS0601_gas_sensor_4)
-- ══════════════════════════════════════════════════════════════
local gas_value_preheat_fault = {
  profile = "safety-gas-detector-value-preheat-fault-alarm-silence-gas4",
  tuya.dp_gas(1, { emit = emit.gas() }),
  tuya.dp_numeric(2, {
    name = "gas_value",
    emit = emit.gasSensor4GasValue(),
    read_only = true,
    converter = converter.divide_by_from_only(10),
  }),
  tuya.dp_binary(10, {
    name = "preheat",
    emit = emit.gasSensor4Preheat(),
    read_only = true,
    converter = converter.from_only(function(value)
      return value and "on" or "off"
    end),
  }),
  tuya.dp_binary(11, {
    name = "fault_alarm",
    emit = emit.gasSensor4FaultAlarm(),
    read_only = true,
    converter = converter.from_only(function(value)
      return (value == true or value == 1) and "fault" or "clear"
    end),
  }),
  tuya.dp_binary(13, {
    name = "alarm_switch",
    emit = emit.gasSensor4AlarmSwitch(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_binary(16, {
    name = "silence",
    emit = emit.gasSensor4Silence(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
}

register_device_definition(gas_value_preheat_fault, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_mby4kbtq",
  "_TZE204_mby4kbtq",
  "_TZE204_uo8qcagc",
  "_TZE284_uo8qcagc",
}))

-- ══════════════════════════════════════════════════════════════
-- 2-5. gas_model_ga01: Meian (self_test_result + preheat)
-- Z2M: _TZE200_ioxkjvuz (GA01)
-- ══════════════════════════════════════════════════════════════
local gas_model_ga01 = {
  profile = "safety-gas-detector-self-test-result-preheat-ga01",
  tuya.dp_gas(1, { emit = emit.gas() }),
  tuya.dp_enum(9, {
    name = "self_test_result",
    emit = emit.ga01SelfTestResult(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "checking",
      [1] = "success",
      [2] = "failure",
      [3] = "others",
    })),
  }),
  tuya.dp_binary(16, {
    name = "preheat",
    emit = emit.ga01Preheat(),
    read_only = true,
    converter = converter.from_only(function(value)
      return value and "on" or "off"
    end),
  }),
}

register_device_definition(gas_model_ga01, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_ioxkjvuz",
}))

-- ══════════════════════════════════════════════════════════════
-- 2-6. gas_model_dg03: Spacetronik (fault enum)
-- Z2M: _TZE204_v6iczj35 (ZB-DG03)
-- ══════════════════════════════════════════════════════════════
local gas_model_dg03 = {
  profile = "safety-gas-detector-preheat-fault-lifecycle-dg03",
  query_on_configure = true,
  tuya.dp_enum(1, {
    name = "gas",
    emit = emit.gas(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = true,
      [1] = false,
    })),
  }),
  tuya.dp_binary(10, {
    name = "preheat",
    emit = emit.dg03Preheat(),
    read_only = true,
    converter = converter.from_only(function(value)
      return (value == true or value == 1) and "on" or "off"
    end),
  }),
  tuya.dp_enum(11, {
    name = "fault",
    emit = emit.dg03Fault(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "none",
      [1] = "fault",
      [2] = "serious_fault",
      [3] = "sensor_fault",
      [4] = "probe_fault",
      [5] = "power_fault",
    })),
  }),
  tuya.dp_binary(12, {
    name = "lifecycle",
    emit = emit.dg03Lifecycle(),
    read_only = true,
    converter = converter.from_only(function(value)
      local active = type(value) == "boolean" and value or value == 0
      return active and "on" or "off"
    end),
  }),
}

register_device_definition(gas_model_dg03, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_v6iczj35",
}))

-- ══════════════════════════════════════════════════════════════
-- 2-7. gas_model_zg_225z: 가스 농도 (ppm) + sensitivity
-- Z2M: _TZE200_8isdky6j / _TZE200_p6fuhvez / _TZE200_aj0oxo1i
-- ══════════════════════════════════════════════════════════════
local gas_model_zg_225z = {
  profile = "safety-gas-detector-zg225z",
  tuya.dp_gas(1, { emit = emit.gas() }),
  tuya.dp_numeric(2, {
    name = "gas_value",
    emit = emit.zg225zGasValue(),
    read_only = true,
  }),
  tuya.dp_enum(6, {
    name = "ring",
    emit = emit.zg225zRing(),
    converter = converter.lookup_from_to({
      ring1 = 0,
      ring2 = 1,
    }),
  }),
  tuya.dp_enum(101, {
    name = "sensitivity",
    emit = emit.sensitivityGasZg225zEnum(),
    converter = converter.lookup_from_to({
      low = 0,
      medium = 1,
      high = 2,
    }),
  }),
}

register_device_definition(gas_model_zg_225z, {
  device_helpers.create_fingerprint("_TZE200_8isdky6j", "TS0601"),
  device_helpers.create_fingerprint("_TZE200_p6fuhvez", "TS0225"),
  device_helpers.create_fingerprint("_TZE200_aj0oxo1i", "TS0225"),
})

-- ══════════════════════════════════════════════════════════════
-- 3-1. co: CO 감지기 (CO 농도 포함)
-- Z2M: _TZE200_7bztmfm1 (DCR-CO)
-- ══════════════════════════════════════════════════════════════
local co = {
  profile = "safety-co-detector",
  tuya.dp_carbon_monoxide(1, { emit = emit.carbon_monoxide() }),
  tuya.dp_co(2, { emit = emit.carbon_monoxide_level(), scale = 100 }),
}

register_device_definition(co, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_7bztmfm1",
  "_TZE204_7bztmfm1",
}))

-- ══════════════════════════════════════════════════════════════
-- 3-2. gas_carbon_monoxide: CO + 가스 복합
-- Z2M: _TZE200_iuk8kupi (DCR-RQJ)
-- ══════════════════════════════════════════════════════════════
local gas_carbon_monoxide = {
  profile = "safety-gas-co-detector",
  tuya.dp_enum(1, {
    name = "gas",
    emit = emit.gas(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({ [0] = true, [1] = false })),
  }),
  tuya.dp_numeric(2, {
    name = "gas_value",
    emit = emit.dcrRqjGasValue(),
    read_only = true,
    converter = converter.divide_by_from_only(1000),
  }),
  tuya.dp_enum(18, {
    name = "carbon_monoxide",
    emit = emit.carbon_monoxide(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({ [0] = true, [1] = false })),
  }),
  tuya.dp_co(19, { emit = emit.carbon_monoxide_level(), scale = 100 }),
}

register_device_definition(gas_carbon_monoxide, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_iuk8kupi",
  "_TZE204_iuk8kupi",
}))

local gas_carbon_monoxide_jkd816 = {
  profile = "safety-gas-co-detector-jkd816",
  tuya.dp_binary(1, {
    name = "gas",
    emit = emit.gas(),
    read_only = true,
    converter = converter.from_only(function(value)
      return value == true or value == 1
    end),
  }),
  tuya.dp_numeric(2, {
    name = "gas_value",
    emit = emit.jkd816GasValue(),
    read_only = true,
  }),
  tuya.dp_enum(9, {
    name = "self_test",
    emit = emit.jkd816SelfTest(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "checking",
      [1] = "check_success",
      [2] = "check_failure",
      [3] = "others",
    })),
  }),
  tuya.dp_enum(11, {
    name = "fault",
    emit = emit.jkd816Fault(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "none",
      [1] = "fault",
      [2] = "serious_fault",
      [3] = "sensor_fault",
      [4] = "probe_fault",
      [5] = "power_fault",
    })),
  }),
  tuya.dp_binary(16, {
    name = "silence",
    emit = emit.jkd816Silence(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_binary(18, {
    name = "carbon_monoxide",
    emit = emit.carbon_monoxide(),
    read_only = true,
    converter = converter.from_only(function(value)
      return value == true or value == 1
    end),
  }),
  tuya.dp_numeric(19, {
    name = "co",
    emit = emit.carbon_monoxide_level(),
    read_only = true,
  }),
}

register_device_definition(gas_carbon_monoxide_jkd816, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_qaxkdgyt",
}))

-- ══════════════════════════════════════════════════════════════
-- 4-1. th_contact: 접점 + 온습도
-- Z2M: _TZE200_nvups4nh (contact_th_sensor)
-- ══════════════════════════════════════════════════════════════
local th_contact = {
  profile = "safety-contact-temp-humidity-battery",
  tuya.dp_contact(1, { emit = emit.contact(), inverted = true }),
  tuya.dp_battery(2, { emit = emit.battery() }),
  tuya.dp_temperature(7, { emit = emit.temperature("C"), scale = 10 }),
  tuya.dp_humidity(8, { emit = emit.humidity() }),
}

register_device_definition(th_contact, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_nvups4nh",
}))

-- ══════════════════════════════════════════════════════════════
-- 4-2. contact_illum: 독립 접점 + 조도 + 배터리
-- Z2M: _TZE200_pay2byax (ZG-102ZL)
-- ══════════════════════════════════════════════════════════════
local contact_illum = {
  profile = "safety-contact-illuminance-battery",
  tuya.dp_contact(1, { emit = emit.contact(), inverted = true }),
  tuya.dp_battery(2, { emit = emit.battery() }),
  tuya.dp_illuminance(101, { emit = emit.illuminance() }),
  tuya.dp_numeric(102, {
    name = "illuminance_interval",
    emit = emit.zg102zlIlluminanceInterval(),
  }),
}

register_device_definition(contact_illum, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_pay2byax",
  "_TZE200_ijey4q29",
  "_TZE200_ykglasuj",
  "_TZE200_kf2hbko4",
}))

-- ══════════════════════════════════════════════════════════════
-- 4-3. contact_basic: 독립 접점 + 배터리
-- Z2M: _TZE200_kltffuzl (TM001-ZA/TM081)
-- ══════════════════════════════════════════════════════════════
local contact_basic = {
  profile = "safety-contact-battery",
  tuya.dp_contact(1, { emit = emit.contact(), inverted = true }),
  tuya.dp_battery(2, { emit = emit.battery() }),
}

register_device_definition(contact_basic, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_kltffuzl",
  "_TZE200_fwoorn8y",
  "_TZE200_n8dljorx",
}))

-- ══════════════════════════════════════════════════════════════
-- 4-4. contact_opening_tamper: opening_state + 배터리 + tamper
-- ZHA: _TZE200_ytx9fudw / Z2M: Senoro.Win
-- ══════════════════════════════════════════════════════════════
local contact_opening_tamper = {
  profile = "safety-contact-alarm-battery-opening-senoro",
  tuya.dp_battery(2, { emit = emit.battery() }),
  tuya.dp_binary(16, {
    name = "alarm",
    emit = emit.senoroWinAlarm(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_enum(101, {
    name = "opening_state",
    emit = emit_opening_state(emit.openingStateContactTamper3State()),
    converter = converter.lookup_from_to({ open = 0, closed = 1, tilted = 2 }),
  }),
}

register_device_definition(contact_opening_tamper, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_ytx9fudw",
}))

-- S8 premium window handle
local contact_window_handle_s8 = {
  profile = "safety-contact-temp-humidity-battery-s8",
  tuya.dp_battery(3, { emit = emit.battery() }),
  tuya.dp_temperature(8, { emit = emit.temperature("C"), scale = 10 }),
  tuya.dp_humidity(101, { emit = emit.humidity() }),
  tuya.dp_enum(102, {
    name = "alarm",
    emit = emit.s8AlarmState(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({ [0] = "idle", [1] = "alarm" })),
  }),
  tuya.dp_enum(103, {
    name = "opening_mode",
    emit = emit.s8OpeningMode(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({ [0] = "closed", [1] = "tilted" })),
  }),
  tuya.dp_enum(104, {
    name = "position",
    emit = emit.s8HandlePosition(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({ [1] = "up", [2] = "down", [3] = "right", [4] = "left" })),
  }),
  tuya.dp_enum(105, {
    name = "button_left",
    emit = emit.s8LeftButton(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({ [0] = "released", [1] = "pressed" })),
  }),
  tuya.dp_enum(106, {
    name = "button_right",
    emit = emit.s8RightButton(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({ [0] = "released", [1] = "pressed" })),
  }),
  tuya.dp_enum(107, {
    name = "vacation",
    emit = emit.s8VacationMode(),
    converter = converter.lookup_from_to({ off = 0, on = 1 }),
  }),
  tuya.dp_enum(108, {
    name = "sensitivity",
    emit = emit.sensitivityContactS8Enum(),
    converter = converter.lookup_from_to({
      off = 0,
      low = 1,
      medium = 2,
      high = 3,
      max = 4,
    }),
  }),
  tuya.dp_enum(109, {
    name = "alarm_switch",
    emit = emit.s8AlarmSwitch(),
    converter = converter.lookup_from_to({ off = 0, on = 1 }),
  }),
  tuya.dp_numeric(110, { name = "update_frequency", emit = emit.updateFrequencyContactS8Minutes() }),
  tuya.dp_enum(111, {
    name = "keysound",
    emit = emit.s8KeySound(),
    converter = converter.lookup_from_to({ off = 0, on = 1 }),
  }),
  tuya.dp_enum(112, {
    name = "battery_low",
    emit = emit.battery_low(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({ [0] = true, [1] = false })),
  }),
  tuya.dp_numeric(113, { name = "duration", emit = emit.alarmDurationContactS8Sec300() }),
  tuya.dp_enum(114, {
    name = "handlesound",
    emit = emit.s8HandleSound(),
    converter = converter.lookup_from_to({ off = 0, on = 1 }),
  }),
  tuya.dp_enum(120, {
    name = "calibrate",
    emit = emit.s8Calibrate(),
    converter = converter.lookup_from_to({ clear = 0, execute = 1 }),
  }),
}

register_device_definition(contact_window_handle_s8, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_j7sgd8po",
}))

-- Senoro.Win v2: 3-state window sensor
local contact_senoro_win_v2 = {
  profile = "safety-contact-battery-senoro-win-v2",
  tuya.dp_battery(2, { emit = emit.battery() }),
  tuya.dp_enum(101, {
    name = "opening_state",
    emit = emit_opening_state(emit.openingStateSenoroWinV23State()),
    converter = converter.lookup_from_to({ open = 0, closed = 1, tilted = 2 }),
  }),
  tuya.dp_binary(16, {
    name = "alarm_state",
    emit = emit.senoroWinV2AlarmState(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_numeric(102, {
    name = "vibration",
    emit = emit.senoroWinV2Vibration(),
    read_only = true,
  }),
  tuya.dp_binary(103, {
    name = "alarm_siren",
    emit = emit.senoroWinV2AlarmSiren(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_binary(104, {
    name = "close_signal",
    emit = emit.senoroWinV2CloseSignal(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_numeric(105, { name = "transmission_power", emit = emit.txPowerSenoroWinLevel() }),
  tuya.dp_numeric(106, { name = "vibration_limit", emit = emit.vibrationLimitSenoroWinV2() }),
  tuya.dp_binary(107, {
    name = "setup_mode",
    emit = emit.senoroWinV2SetupMode(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_binary(108, {
    name = "vibration_siren",
    emit = emit.senoroWinV2VibrationSiren(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_numeric(109, { name = "alarm_siren_duration", emit = emit.senoroWinV2AlarmSirenDuration() }),
  tuya.dp_numeric(110, { name = "vibration_siren_duration", emit = emit.senoroV2VibrationSirenTime() }),
  tuya.dp_binary(111, {
    name = "magnetic_status",
    emit = emit.senoroWinV2MagneticStatus(),
    read_only = true,
    converter = converter.from_only(function(value)
      return (value == true or value == 1) and "on" or "off"
    end),
  }),
}

register_device_definition(contact_senoro_win_v2, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_6teua268",
}))

-- ══════════════════════════════════════════════════════════════
-- 5-1. water: 누수 (배터리 없음)
-- Z2M: _TZE200_qq9mpfhw (TS0601_water_sensor / NEO NAS-WS02B0)
-- ══════════════════════════════════════════════════════════════
local water = {
  profile = "safety-water-leak",
  tuya.dp_binary(101, { name = "water_leak", emit = emit.water() }),
}

register_device_definition(water, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_qq9mpfhw",
}))

-- ══════════════════════════════════════════════════════════════
-- 5-2. water_battery: 누수 + 배터리
-- Z2M: _TZE200_jthf7vb6 (WLS-100z)
-- ══════════════════════════════════════════════════════════════
local water_battery = {
  profile = "safety-water-leak-battery",
  bind_basic_on_configure = true,
  tuya.dp_water_leak(1, { emit = emit.water() }),
  tuya.dp_battery(4, { emit = emit.battery() }),
}

register_device_definition(water_battery, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_jthf7vb6",
}))

-- ══════════════════════════════════════════════════════════════
-- 5-3. water_illum_battery_model_zg_223z: ZG-223Z (비 감지 + 조도 + 배터리)
-- Z2M: _TZE200_jsaqgakf / _TZE200_u6x1zyv2 / _TZE200_2pddnnrk
-- ══════════════════════════════════════════════════════════════
local water_illum_battery_model_zg_223z = {
  profile = "safety-water-leak-illuminance-battery-zg223z",
  tuya.dp_enum(1, {
    name = "rainwater",
    emit = emit.water(),
    converter = converter.from_only(converter.lookup_value({
      [0] = false,
      [1] = true,
    })),
  }),
  tuya.dp_numeric(2, {
    name = "sensitivity",
    emit = emit.zg223zSensitivity(),
  }),
  tuya.dp_numeric(101, { name = "illuminance_sampling", emit = emit.illuminanceSamplingZg223zMinutes() }),
  tuya.dp_illuminance(102, { emit = emit.illuminance() }),
  tuya.dp_battery(104, { emit = emit.battery() }),
}

register_device_definition(water_illum_battery_model_zg_223z, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_jsaqgakf",
  "_TZE200_u6x1zyv2",
  "_TZE200_2pddnnrk",
}))

register_device_definition(water_illum_battery_model_zg_223z, {
  device_helpers.create_fingerprint("HOBEIAN", "ZG-223Z"),
})

-- ══════════════════════════════════════════════════════════════
-- 6-1. vibration: 진동 + 접점 + 배터리
-- Z2M: _TZE200_kzm5w4iz (TS0601_vibration_sensor)
-- ══════════════════════════════════════════════════════════════
local vibration = {
  profile = "safety-acceleration-contact-battery",
  tuya.dp_contact(1, { emit = emit.contact(), inverted = true }),
  tuya.dp_battery(3, { emit = emit.battery() }),
  tuya.dp_binary(10, { name = "vibration", emit = emit.acceleration() }),
}

register_device_definition(vibration, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_kzm5w4iz",
}))

-- ══════════════════════════════════════════════════════════════
-- 6-2. vibration_model_zg_102zm: ZG-102ZM
-- Z2M: _TZE200_wzk0x7fq / _TZE200_jfw0a4aa
-- ══════════════════════════════════════════════════════════════
local vibration_model_zg_102zm = {
  profile = "safety-acceleration-contact-battery-zg102zm",
  tuya.dp_binary(1, { name = "vibration", emit = emit.acceleration(), converter = converter.true_false1() }),
  tuya.dp_contact(101, { emit = emit.contact(), converter = converter.true_false0() }),
  tuya.dp_battery(4, { emit = emit.battery() }),
  tuya.dp_numeric(6, { name = "sensitivity", emit = emit.vibrationSensitivityZgFifty() }),
}

register_device_definition(vibration_model_zg_102zm, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_wzk0x7fq",
  "_TZE200_jfw0a4aa",
}))

register_device_definition(vibration_model_zg_102zm, {
  device_helpers.create_fingerprint("AOYAN", "AY02SZ"),
})

-- ══════════════════════════════════════════════════════════════
-- 6-3. vibration_model_zg_103z: ZG-103Z
-- Z2M: _TZE200_iba1ckek / _TZE200_hggxgsjj / _TZE200_yjryxpot / _TZE200_afycb3cg
-- ══════════════════════════════════════════════════════════════
local vibration_model_zg_103z = {
  profile = "safety-acceleration-battery-zg103z",
  tuya.dp_enum(1, { name = "vibration", emit = emit.acceleration(), converter = converter.true_false1() }),
  tuya.dp_enum(7, {
    name = "tilt",
    emit = emit.zg103zTilt(),
    converter = converter.from_only(converter.lookup_value({
      [0] = "clear",
      [1] = "detected",
    })),
  }),
  tuya.dp_numeric(101, { name = "x", emit = emit.zg103zXCoordinate() }),
  tuya.dp_numeric(102, { name = "y", emit = emit.zg103zYCoordinate() }),
  tuya.dp_numeric(103, { name = "z", emit = emit.zg103zZCoordinate() }),
  tuya.dp_enum(104, {
    name = "sensitivity",
    emit = emit.vibrationSensitivityZg103zEnum(),
    converter = converter.lookup_from_to({
      low = 0,
      middle = 1,
      high = 2,
    }),
  }),
  tuya.dp_battery(105, { emit = emit.battery() }),
}

register_device_definition(vibration_model_zg_103z, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_iba1ckek",
  "_TZE200_hggxgsjj",
  "_TZE200_yjryxpot",
  "_TZE200_afycb3cg",
}))

-- ══════════════════════════════════════════════════════════════
-- 6-4. vibration_model_4cqhd2ha: 진동 + 감도 + buzzer mute
-- Z2M: _TZE284_4cqhd2ha / _TZE200_8ply8mjj
-- ══════════════════════════════════════════════════════════════
local vibration_model_4cqhd2ha = {
  profile = "safety-acceleration-4cqhd2ha",
  tuya.dp_binary(1, { name = "vibration", emit = emit.acceleration(), converter = converter.true_false1() }),
  tuya.dp_numeric(101, { name = "sensitivity", emit = emit.vibrationSensitivity4cqhd2haLevel() }),
  tuya.dp_binary(103, {
    name = "buzzer_mute",
    emit = emit.vibration4cqBuzzerMute(),
    read_only = true,
    converter = converter.from_only(function(value)
      return (value == true or value == 1 or value == "ON") and "on" or "off"
    end),
  }),
}

register_device_definition(vibration_model_4cqhd2ha, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_4cqhd2ha",
  "_TZE200_8ply8mjj",
}))

return device_definitions




