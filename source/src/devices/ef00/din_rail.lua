-- DIN 레일 디바이스 정의
-- ZHA + Z2M 기반 DP 그룹핑
--
-- 변수명 규칙: {category}_{variant}
--   category: din_rail
--   variant 구성 (순서):
--     1. 모델:   특정 기종 레이아웃이면 model_* 사용
--     2. 기능:   meter, threshold, fault
--   규칙:
--     - 현재 코드베이스와 일관되게 선언형 DP 리스트를 직접 작성
--     - DP 값은 ZHA/Z2M 확인값 기준으로 작성
--     - 현재 프로파일에 노출하지 않는 DP도 모두 유지

local tuya = require "tuya_common"
local emit = require "emitters"
local device_helpers = require "devices.shared.helpers"

local device_definitions, register_device_definition = device_helpers.definition_registry()
local converter = tuya.converter

local emit_voltage = emit.voltage()
local emit_current = emit.current()
local emit_power = emit.power()

local function emit_metric_bundle(options)
  options = options or {}

  return function(_, value)
    if type(value) ~= "table" then
      return nil
    end

    local events = {}

    if options.voltage and value.voltage ~= nil then
      events[#events + 1] = emit_voltage(nil, value.voltage)
    end

    if options.current and value.current ~= nil then
      events[#events + 1] = emit_current(nil, value.current)
    end

    if options.power and value.power ~= nil then
      events[#events + 1] = emit_power(nil, value.power)
    end

    if #events == 0 then
      return nil
    end

    return events
  end
end

-- Z2M circuit breaker fault bitmap (lib/tuya.ts circuitBreakerFaultList).
local CIRCUIT_BREAKER_FAULT_BITS = {
  "short_circuit",
  "surge",
  "overload",
  "leakage_current",
  "temperature",
  "fire",
  "high_power",
  "self_test",
  "over_current",
  "unbalance",
  "over_voltage",
  "under_voltage",
  "miss_phase",
  "outage",
  "magnetism",
  "credit",
  "no_balance",
}

local circuit_breaker_faults_converter = converter.from_only(function(value)
  local bitmap = tonumber(value)
  if bitmap == nil then
    return nil
  end

  local names = {}
  for index, name in ipairs(CIRCUIT_BREAKER_FAULT_BITS) do
    if bitmap % (2 ^ index) >= 2 ^ (index - 1) then
      names[#names + 1] = name
    end
  end

  if #names == 0 then
    return "none"
  end
  return table.concat(names, ",")
end)

-- Tongou breaker protection settings share this enum (lib lookup Ignore/Alarm/Trip).
local ALARM_TRIP_SETTING = { ignore = 0, alarm = 1, trip = 2 }

-- TO-Q-SA1 only offers the two-value form of the same setting enum.
local IGNORE_ALARM_SETTING = { ignore = 0, alarm = 1 }

-- TOQCB2-80 labels the same three states closed/alarm/trip.
local CLOSED_ALARM_TRIP_SETTING = { closed = 0, alarm = 1, trip = 2 }

-- Z2M Tongou breaker last-event lookup (tuya.ts:19442 and tuya.ts:19694).
local BREAKER_EVENT_LOOKUP = {
  [0] = "normal",
  [1] = "over_current_trip",
  [2] = "over_power_trip",
  [3] = "high_temp_trip",
  [4] = "over_voltage_trip",
  [5] = "under_voltage_trip",
  [6] = "over_current_alarm",
  [7] = "over_power_alarm",
  [8] = "high_temp_alarm",
  [9] = "over_voltage_alarm",
  [10] = "under_voltage_alarm",
  [11] = "remote_on",
  [12] = "remote_off",
  [13] = "manual_on",
  [14] = "manual_off",
  [15] = "leakage_trip",
  [16] = "leakage_alarm",
  [17] = "restore_default",
  [18] = "automatic_closing",
  [19] = "electricity_shortage",
  [20] = "electricity_shortage_alarm",
  [21] = "timing_switch_on",
  [22] = "timing_switch_off",
}

-- ══════════════════════════════════════════════════════════════
-- 1-1. din_rail_model_ts0601_din_1: 단일 스위치 + 계측
-- Z2M: TS0601_din_1 / ZHA: TS0601 power meter 계열
-- ══════════════════════════════════════════════════════════════
-- Z2M TS0601_din_1 (tuya.ts:10945): DP1 energy /100, DP6 phase variant 1
-- voltage and current, DP16 switch, DP101 total energy /100, DP102 produced
-- energy /100, DP103 power, DP105 AC frequency /100, DP109 reactive energy
-- /100, DP110 reactive power, DP111 power factor /10 and DP9 the circuit
-- breaker fault bitmap.  Z2M explicitly leaves DP17 and DP18 unmapped because
-- their payloads are undocumented, so they stay log-only here as well.
local din_rail_model_ts0601_din_1 = {
  profile = "din-rail-switch-power-energy-voltage-current-din1",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_phase_variant1(6, {}),
  tuya.dp_on_off(16, { name = "switch", emit = emit.switch() }),
  tuya.dp_numeric(101, {
    name = "total_energy",
    scale = 100,
    read_only = true,
    emit = emit.din1TotalEnergy(),
  }),
  tuya.dp_energy(102, { name = "produced_energy", scale = 100, emit = emit.producedEnergyDin() }),
  tuya.dp_power(103, { emit = emit.power() }),
  tuya.dp_ac_frequency(105, {
    scale = 100,
    read_only = true,
    emit = emit.din1AcFrequency(),
  }),
  tuya.dp_numeric(109, {
    name = "energy_reactive",
    scale = 100,
    read_only = true,
    emit = emit.din1EnergyReactive(),
  }),
  tuya.dp_numeric(110, { name = "power_reactive", emit = emit.reactivePowerDin1() }),
  tuya.dp_power_factor(111, {
    scale = 10,
    read_only = true,
    emit = emit.din1PowerFactor(),
  }),
  tuya.dp_numeric(9, {
    name = "faults",
    read_only = true,
    emit = emit.din1Faults(),
    converter = circuit_breaker_faults_converter,
  }),
  tuya.dp_raw(17, { name = "alarm_set_1" }),
  tuya.dp_raw(18, { name = "alarm_set_2" }),
}

register_device_definition(din_rail_model_ts0601_din_1, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_bkkmqmyo",
  "_TZE200_eaac7dkw",
  "_TZE204_bkkmqmyo",
}))

register_device_definition(din_rail_model_ts0601_din_1, {
  device_helpers.create_fingerprint("Hiking", "DDS238-2"),
  device_helpers.create_fingerprint("Tuya", "RC-MCB"),
})

-- ══════════════════════════════════════════════════════════════
-- 1-2. din_rail_model_ts0601_din_2: 단일 스위치 + 계측 + 임계값/미터ID
-- Z2M: TS0601_din_2
-- ══════════════════════════════════════════════════════════════
-- Z2M TS0601_din_2 (tuya.ts:11190): DP1 energy /100, DP6 phase variant 2,
-- DP10 fault enum, DP16 switch, DP17 threshold pair, DP18 meter ID and DP20
-- clear fault.  Z2M deliberately maps DP3, DP4, DP11 and DP21..DP24 to null
-- because the monthly/daily counters only answer on request and the frozen and
-- tariff payloads are undocumented, so those stay internal here as well.
local din_rail_model_ts0601_din_2 = {
  profile = "din-rail-switch-power-energy-voltage-current-din2",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_numeric(3, { name = "monthly_energy" }),
  tuya.dp_numeric(4, { name = "daily_energy" }),
  tuya.dp_phase_variant2(6, {}),
  tuya.dp_enum(10, {
    name = "fault",
    read_only = true,
    emit = emit.din2Fault(),
    converter = converter.from_only(converter.lookup_value({
      [0] = "clear",
      [1] = "over_current_threshold",
      [2] = "over_power_threshold",
      [4] = "over_voltage_threshold",
      [8] = "wrong_frequency_threshold",
    })),
  }),
  tuya.dp_raw(11, { name = "frozen" }),
  tuya.dp_on_off(16, { name = "switch", emit = emit.switch() }),
  -- Z2M parses DP17 but notes the write converter cannot be expressed, so it
  -- stays read-only internal until an exact payload log is available.
  tuya.dp_threshold(17, {}),
  tuya.dp_string(18, {
    name = "meter_id",
    read_only = true,
    emit = emit.din2MeterId(),
  }),
  tuya.dp_on_off(20, {
    name = "clear_fault",
    emit = emit.clearFaultDin2(),
    converter = converter.lookup_from_to({ on = true, off = false }),
  }),
  tuya.dp_numeric(21, { name = "forward_energy_t1" }),
  tuya.dp_numeric(22, { name = "forward_energy_t2" }),
  tuya.dp_numeric(23, { name = "forward_energy_t3" }),
  tuya.dp_numeric(24, { name = "forward_energy_t4" }),
}

register_device_definition(din_rail_model_ts0601_din_2, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_lsanae15",
  "_TZE204_l6llgoxq",
  "_TZE204_lsanae15",
}))

register_device_definition(din_rail_model_ts0601_din_2, {
  device_helpers.create_fingerprint("MatSee Plus", "DAC2161C"),
})

-- ══════════════════════════════════════════════════════════════
-- 1-3. din_rail_model_ts0601_din_3: 단일 스위치 + 계측 + 생산전력/역방향에너지
-- Z2M: TS0601_din_3
-- ══════════════════════════════════════════════════════════════
-- Z2M TS0601_din_3 (tuya.ts:11256) shares the din_2 layout and adds DP2
-- produced energy /100.  DP3, DP4, DP11 and DP21..DP24 are null in Z2M for the
-- same reasons as din_2, so they stay internal.
local din_rail_model_ts0601_din_3 = {
  profile = "din-rail-switch-power-energy-voltage-current-din3",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_energy(2, { name = "produced_energy", scale = 100, emit = emit.producedEnergyDin() }),
  tuya.dp_numeric(3, { name = "monthly_energy" }),
  tuya.dp_numeric(4, { name = "daily_energy" }),
  tuya.dp_phase_variant2(6, {}),
  tuya.dp_enum(10, {
    name = "fault",
    read_only = true,
    emit = emit.din3Fault(),
    converter = converter.from_only(converter.lookup_value({
      [0] = "clear",
      [1] = "over_current_threshold",
      [2] = "over_power_threshold",
      [4] = "over_voltage_threshold",
      [8] = "wrong_frequency_threshold",
    })),
  }),
  tuya.dp_raw(11, { name = "frozen" }),
  tuya.dp_on_off(16, { name = "switch", emit = emit.switch() }),
  tuya.dp_threshold(17, {}),
  tuya.dp_string(18, {
    name = "meter_id",
    read_only = true,
    emit = emit.din3MeterId(),
  }),
  tuya.dp_on_off(20, {
    name = "clear_fault",
    emit = emit.clearFaultDin3(),
    converter = converter.lookup_from_to({ on = true, off = false }),
  }),
  tuya.dp_numeric(21, { name = "forward_energy_t1" }),
  tuya.dp_numeric(22, { name = "forward_energy_t2" }),
  tuya.dp_numeric(23, { name = "forward_energy_t3" }),
  tuya.dp_numeric(24, { name = "forward_energy_t4" }),
}

register_device_definition(din_rail_model_ts0601_din_3, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_rhblgy0z",
  "_TZE204_rhblgy0z",
}))

register_device_definition(din_rail_model_ts0601_din_3, {
  device_helpers.create_fingerprint("XOCA", "DAC2161C"),
})

-- ══════════════════════════════════════════════════════════════
-- 1-4. din_rail_model_ts0601_din_legacy: 레거시 단일 스위치 + 계측
-- Z2M: TS0601_din
-- ══════════════════════════════════════════════════════════════
local din_rail_model_ts0601_din_legacy = {
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_phase_variant2(6, {}),
  tuya.dp_on_off(16, { name = "switch", emit = emit.switch() }),
}

register_device_definition(din_rail_model_ts0601_din_legacy, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_byzdayie",
  "_TZE200_ewxhg6o9",
  "_TZE200_fsb6zw01",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-5. din_rail_model_ts0601_din_4: 단일 스위치 + 계측 + 누설/온도
-- Z2M: TS0601_din_4
-- ══════════════════════════════════════════════════════════════
-- Z2M TS0601_din_4 (tuya.ts:21123): DP1 energy /100, DP6 phase A voltage and
-- current, DP9 circuit breaker fault bitmap, DP12 clear energy, DP15 leakage
-- current in mA, DP16 switch, DP102 reclosing tries 0..30, DP103 temperature,
-- DP104 auto reclosing, DP105 timer 0..86400 s, DP127 status standby/active
-- and DP134 power-on behavior.  DP12, DP102, DP104, DP105, DP127 and DP134
-- were missing entirely and DP9, DP15, DP103 were parsed but never exposed.
-- Z2M's own converter keeps DP11, DP14, DP106..DP109, DP119, DP124 and DP125
-- commented out as unexposed, so they stay unmapped here too.
local din_rail_model_ts0601_din_4 = {
  profile = "din-rail-switch-power-energy-voltage-current-din4",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_phase_variant2(6, {}),
  tuya.dp_numeric(9, {
    name = "faults",
    read_only = true,
    emit = emit.din4Faults(),
    converter = circuit_breaker_faults_converter,
  }),
  tuya.dp_binary(12, {
    name = "clear_energy",
    emit = emit.din4ClearEnergy(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_numeric(15, {
    name = "leakage",
    read_only = true,
    emit = emit.din4Leakage(),
  }),
  tuya.dp_on_off(16, { name = "switch", emit = emit.switch() }),
  tuya.dp_numeric(102, {
    name = "reclosing_allowed_times",
    emit = emit.din4ReclosingTimes(),
  }),
  tuya.dp_temperature(103, {
    name = "temperature",
    scale = 1,
    read_only = true,
    emit = emit.din4Temperature(),
  }),
  tuya.dp_binary(104, {
    name = "reclosing_enable",
    emit = emit.din4ReclosingEnable(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_numeric(105, { name = "timer", emit = emit.din4Timer() }),
  tuya.dp_enum(127, {
    name = "status",
    read_only = true,
    emit = emit.din4Status(),
    converter = converter.from_only(converter.lookup_value({
      [0] = "standby",
      [1] = "active",
    })),
  }),
  tuya.dp_power_on_behavior(134, { emit = emit.din4PowerOnBehavior() }),
}

register_device_definition(din_rail_model_ts0601_din_4, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_abatw3kj",
  "_TZE204_4bjixefp",
  "_TZE204_fhvdgeuh",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-6. power_meter_model_sdm01: 3상 에너지 모니터
-- Z2M: SDM01 (tuya.ts:16535)
-- ══════════════════════════════════════════════════════════════
-- Only the ugekduaj exacts use this datapoint map: DP1 forward energy /100,
-- DP2 reverse energy /100, DP15 total power factor, DP101 AC frequency /100,
-- DP102..DP110 per-phase voltage/current/power, DP111 total power,
-- DP112..DP117 per-phase forward and reverse energy and DP118..DP120 per-phase
-- power factor.  Z2M marks this definition incomplete, and DP18 data report
-- duration needs a 32-byte settings frame, so it stays unexposed.
local power_meter_model_sdm01 = {
  profile = "meters-power-energy-voltage-current-sdm01",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_energy(2, { name = "produced_energy", scale = 100 }),              -- 프로파일 미포함
  tuya.dp_power_factor(15, { name = "power_factor", emit = emit.powerFactorSdm01Percent() }),
  tuya.dp_ac_frequency(101, { name = "ac_frequency", emit = emit.acFrequencySdm01() }),
  tuya.dp_voltage(102, { name = "voltage_a", emit = emit.voltage() }),
  tuya.dp_current(103, { name = "current_a", emit = emit.current() }),
  tuya.dp_power(104, { name = "power_a" }),                                  -- 프로파일 미포함
  tuya.dp_voltage(105, { name = "voltage_b" }),                              -- 프로파일 미포함
  tuya.dp_current(106, { name = "current_b" }),                              -- 프로파일 미포함
  tuya.dp_power(107, { name = "power_b" }),                                  -- 프로파일 미포함
  tuya.dp_voltage(108, { name = "voltage_c" }),                              -- 프로파일 미포함
  tuya.dp_current(109, { name = "current_c" }),                              -- 프로파일 미포함
  tuya.dp_power(110, { name = "power_c" }),                                  -- 프로파일 미포함
  tuya.dp_power(111, { emit = emit.power() }),
  tuya.dp_energy(112, { name = "energy_a", scale = 100 }),                   -- 프로파일 미포함
  tuya.dp_energy(113, { name = "produced_energy_a", scale = 100 }),          -- 프로파일 미포함
  tuya.dp_energy(114, { name = "energy_b", scale = 100 }),                   -- 프로파일 미포함
  tuya.dp_energy(115, { name = "produced_energy_b", scale = 100 }),          -- 프로파일 미포함
  tuya.dp_energy(116, { name = "energy_c", scale = 100 }),                   -- 프로파일 미포함
  tuya.dp_energy(117, { name = "produced_energy_c", scale = 100 }),          -- 프로파일 미포함
  tuya.dp_power_factor(118, { name = "power_factor_a" }),                    -- 프로파일 미포함
  tuya.dp_power_factor(119, { name = "power_factor_b" }),                    -- 프로파일 미포함
  tuya.dp_power_factor(120, { name = "power_factor_c" }),                    -- 프로파일 미포함
}

register_device_definition(power_meter_model_sdm01, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_ugekduaj",
  "_TZE200_ugekduaj",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-6a. power_meter_model_spm02: 3상 에너지 모니터 (phase X/Y/Z)
-- Z2M: SPM02 (tuya.ts:16058)
-- ══════════════════════════════════════════════════════════════
-- This exact does not share the SDM01 datapoint map at all.  Z2M reports the
-- three phases through DP6, DP7 and DP8 phase-variant-2 payloads and exposes
-- only total forward energy DP1 and total reverse energy DP2.  There is no
-- DP15 power factor, no DP101 frequency and no DP102..DP120 block, so keeping
-- these exacts on the SDM01 definition made the driver read datapoints the
-- device never sends.  Z2M leaves the DP9 bitmap unmapped as unknown.
local power_meter_model_spm02 = {
  profile = "meters-energy-3phase-spm02",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_energy(2, {
    name = "produced_energy",
    scale = 100,
    read_only = true,
    emit = emit.spm02ProducedEnergy(),
  }),
  tuya.dp_phase_variant2(6, {
    phase = "x",
    component = "l1",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_phase_variant2(7, {
    phase = "y",
    component = "l2",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_phase_variant2(8, {
    phase = "z",
    component = "l3",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
}

register_device_definition(power_meter_model_spm02, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_ves1ycwx",
  "_TZE204_ves1ycwx",
  "_TZE284_ves1ycwx",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-6b. power_meter_model_nous_d4z: Nous D4Z 3상 에너지 모니터
-- Z2M: Nous D4Z (nous.ts:257)
-- ══════════════════════════════════════════════════════════════
-- `Nous / D4Z` is a real interviewed model, not a Tuya whiteLabel row, and the
-- exacts _TZE204_loejka0i / _TZE284_loejka0i belong to it.  The datapoint map
-- matches SDM01 for DP1, DP2, DP15, DP101..DP120 but adds DP9 circuit breaker
-- faults and DP16 energy reset.  Z2M comments out DP6..DP8 as duplicate
-- measurements, and DP17/DP18 need multi-byte threshold frames, so those stay
-- unexposed.
local power_meter_model_nous_d4z = {
  profile = "meters-energy-3phase-nous-d4z",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_energy(2, {
    name = "produced_energy",
    scale = 100,
    read_only = true,
    emit = emit.nousD4zProducedEnergy(),
  }),
  tuya.dp_numeric(9, {
    name = "faults",
    read_only = true,
    emit = emit.nousD4zFaults(),
    converter = circuit_breaker_faults_converter,
  }),
  tuya.dp_power_factor(15, {
    name = "power_factor",
    read_only = true,
    emit = emit.nousD4zPowerFactor(),
  }),
  tuya.dp_on_off(16, {
    name = "energy_reset",
    emit = emit.nousD4zEnergyReset(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_raw(17, { name = "alarm_set_1" }),
  tuya.dp_raw(18, { name = "alarm_set_2" }),
  tuya.dp_ac_frequency(101, {
    name = "ac_frequency",
    read_only = true,
    emit = emit.nousD4zAcFrequency(),
  }),
  tuya.dp_voltage(102, { name = "voltage_a", component = "l1", emit = emit.voltage() }),
  tuya.dp_current(103, { name = "current_a", component = "l1", emit = emit.current() }),
  tuya.dp_power(104, { name = "power_a", component = "l1", emit = emit.power() }),
  tuya.dp_voltage(105, { name = "voltage_b", component = "l2", emit = emit.voltage() }),
  tuya.dp_current(106, { name = "current_b", component = "l2", emit = emit.current() }),
  tuya.dp_power(107, { name = "power_b", component = "l2", emit = emit.power() }),
  tuya.dp_voltage(108, { name = "voltage_c", component = "l3", emit = emit.voltage() }),
  tuya.dp_current(109, { name = "current_c", component = "l3", emit = emit.current() }),
  tuya.dp_power(110, { name = "power_c", component = "l3", emit = emit.power() }),
  tuya.dp_power(111, { emit = emit.power() }),
  tuya.dp_energy(112, { name = "energy_a", scale = 100, component = "l1", emit = emit.energy() }),
  tuya.dp_energy(113, { name = "energy_produced_a", scale = 100 }),
  tuya.dp_energy(114, { name = "energy_b", scale = 100, component = "l2", emit = emit.energy() }),
  tuya.dp_energy(115, { name = "energy_produced_b", scale = 100 }),
  tuya.dp_energy(116, { name = "energy_c", scale = 100, component = "l3", emit = emit.energy() }),
  tuya.dp_energy(117, { name = "energy_produced_c", scale = 100 }),
  tuya.dp_power_factor(118, { name = "power_factor_a" }),
  tuya.dp_power_factor(119, { name = "power_factor_b" }),
  tuya.dp_power_factor(120, { name = "power_factor_c" }),
}

register_device_definition(power_meter_model_nous_d4z, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_loejka0i",
  "_TZE284_loejka0i",
}))

register_device_definition(power_meter_model_nous_d4z, {
  device_helpers.create_fingerprint("Nous", "D4Z"),
})

-- ══════════════════════════════════════════════════════════════
-- 1-6c. power_meter_model_spm02v2: 3상 에너지 모니터
-- Z2M: SPM02V2 (tuya.ts:16165)
-- ══════════════════════════════════════════════════════════════
-- Same DP1/DP2/DP15/DP101..DP111 head as SDM01 but this exact has no
-- per-phase energy or per-phase power factor block (DP112..DP120), so those
-- datapoints are not mapped.  Z2M keeps DP6..DP8 commented out.
local power_meter_model_spm02v2 = {
  profile = "meters-energy-3phase-spm02v2",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_energy(2, {
    name = "produced_energy",
    scale = 100,
    read_only = true,
    emit = emit.spm02v2ProducedEnergy(),
  }),
  tuya.dp_power_factor(15, {
    name = "power_factor",
    read_only = true,
    emit = emit.spm02v2PowerFactor(),
  }),
  tuya.dp_ac_frequency(101, {
    name = "ac_frequency",
    read_only = true,
    emit = emit.spm02v2AcFrequency(),
  }),
  tuya.dp_voltage(102, { name = "voltage_a", component = "l1", emit = emit.voltage() }),
  tuya.dp_current(103, { name = "current_a", component = "l1", emit = emit.current() }),
  tuya.dp_power(104, { name = "power_a", component = "l1", emit = emit.power() }),
  tuya.dp_voltage(105, { name = "voltage_b", component = "l2", emit = emit.voltage() }),
  tuya.dp_current(106, { name = "current_b", component = "l2", emit = emit.current() }),
  tuya.dp_power(107, { name = "power_b", component = "l2", emit = emit.power() }),
  tuya.dp_voltage(108, { name = "voltage_c", component = "l3", emit = emit.voltage() }),
  tuya.dp_current(109, { name = "current_c", component = "l3", emit = emit.current() }),
  tuya.dp_power(110, { name = "power_c", component = "l3", emit = emit.power() }),
  tuya.dp_power(111, { emit = emit.power() }),
}

register_device_definition(power_meter_model_spm02v2, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_v9hkz2yn",
  "_TZE204_v9hkz2yn",
  "_TZE284_v9hkz2yn",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-6d. power_meter_model_spm02v25: 3상 에너지 모니터
-- Z2M: SPM02V2.5 (tuya.ts:16377)
-- ══════════════════════════════════════════════════════════════
-- This generation moved the totals onto different datapoints: reverse energy is
-- DP23, total power is DP29, AC frequency is DP32 and total power factor is
-- DP50.  Reading DP2/DP15/DP101 as the SDM01 definition did would target
-- datapoints this exact never reports.  DP18 data report duration needs a
-- 32-byte settings frame, so it stays unexposed.
local power_meter_model_spm02v25 = {
  profile = "meters-energy-3phase-spm02v25",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_energy(23, {
    name = "produced_energy",
    scale = 100,
    read_only = true,
    emit = emit.spm02v25ProducedEnergy(),
  }),
  tuya.dp_power(29, { emit = emit.power() }),
  tuya.dp_ac_frequency(32, {
    name = "ac_frequency",
    read_only = true,
    emit = emit.spm02v25AcFrequency(),
  }),
  tuya.dp_power_factor(50, {
    name = "power_factor",
    read_only = true,
    emit = emit.spm02v25PowerFactor(),
  }),
  tuya.dp_voltage(102, { name = "voltage_a", component = "l1", emit = emit.voltage() }),
  tuya.dp_current(103, { name = "current_a", component = "l1", emit = emit.current() }),
  tuya.dp_power(104, { name = "power_a", component = "l1", emit = emit.power() }),
  tuya.dp_voltage(105, { name = "voltage_b", component = "l2", emit = emit.voltage() }),
  tuya.dp_current(106, { name = "current_b", component = "l2", emit = emit.current() }),
  tuya.dp_power(107, { name = "power_b", component = "l2", emit = emit.power() }),
  tuya.dp_voltage(108, { name = "voltage_c", component = "l3", emit = emit.voltage() }),
  tuya.dp_current(109, { name = "current_c", component = "l3", emit = emit.current() }),
  tuya.dp_power(110, { name = "power_c", component = "l3", emit = emit.power() }),
}

register_device_definition(power_meter_model_spm02v25, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_ny94onlb",
  "_TZE204_ny94onlb",
  "_TZE284_ny94onlb",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-6e. power_meter_model_spm02v3: 3상 에너지 모니터
-- Z2M: SPM02V3 (tuya.ts:16467)
-- ══════════════════════════════════════════════════════════════
-- Totals sit on the SPM02V2.5 datapoints (DP1/DP23/DP29/DP32/DP50) but the
-- per-phase block is spread over DP103..DP128 in blocks of nine: voltage,
-- current and power first, then power factor, forward energy and reverse
-- energy.  DP102 is a writable report interval.
local power_meter_model_spm02v3 = {
  profile = "meters-energy-3phase-spm02v3",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_energy(23, {
    name = "produced_energy",
    scale = 100,
    read_only = true,
    emit = emit.spm02v3ProducedEnergy(),
  }),
  tuya.dp_power(29, { emit = emit.power() }),
  tuya.dp_ac_frequency(32, {
    name = "ac_frequency",
    read_only = true,
    emit = emit.spm02v3AcFrequency(),
  }),
  tuya.dp_power_factor(50, {
    name = "power_factor",
    read_only = true,
    emit = emit.spm02v3PowerFactor(),
  }),
  tuya.dp_numeric(102, { name = "update_frequency", emit = emit.spm02v3UpdateFrequency() }),
  tuya.dp_voltage(103, { name = "voltage_a", component = "l1", emit = emit.voltage() }),
  tuya.dp_current(104, { name = "current_a", component = "l1", emit = emit.current() }),
  tuya.dp_power(105, { name = "power_a", component = "l1", emit = emit.power() }),
  tuya.dp_power_factor(108, { name = "power_factor_a" }),                     -- 프로파일 미포함
  tuya.dp_energy(109, { name = "energy_a", scale = 100, component = "l1", emit = emit.energy() }),
  tuya.dp_energy(110, { name = "energy_produced_a", scale = 100 }),           -- 프로파일 미포함
  tuya.dp_voltage(112, { name = "voltage_b", component = "l2", emit = emit.voltage() }),
  tuya.dp_current(113, { name = "current_b", component = "l2", emit = emit.current() }),
  tuya.dp_power(114, { name = "power_b", component = "l2", emit = emit.power() }),
  tuya.dp_power_factor(117, { name = "power_factor_b" }),                     -- 프로파일 미포함
  tuya.dp_energy(118, { name = "energy_b", scale = 100, component = "l2", emit = emit.energy() }),
  tuya.dp_energy(119, { name = "energy_produced_b", scale = 100 }),           -- 프로파일 미포함
  tuya.dp_voltage(121, { name = "voltage_c", component = "l3", emit = emit.voltage() }),
  tuya.dp_current(122, { name = "current_c", component = "l3", emit = emit.current() }),
  tuya.dp_power(123, { name = "power_c", component = "l3", emit = emit.power() }),
  tuya.dp_power_factor(126, { name = "power_factor_c" }),                     -- 프로파일 미포함
  tuya.dp_energy(127, { name = "energy_c", scale = 100, component = "l3", emit = emit.energy() }),
  tuya.dp_energy(128, { name = "energy_produced_c", scale = 100 }),           -- 프로파일 미포함
}

register_device_definition(power_meter_model_spm02v3, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_dikb3dp6",
  "_TZE204_dikb3dp6",
  "_TZE284_dikb3dp6",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-6f. power_meter_model_spm02v1gt: 3상 에너지 모니터 (grid-tie)
-- Z2M: SPM02V1-GT (tuya.ts:16804)
-- ══════════════════════════════════════════════════════════════
-- Grid-tie generation: totals on DP1/DP23/DP29/DP32/DP50, per-phase voltage,
-- current and power back on the DP6/DP7/DP8 phase-variant-2 frames, per-phase
-- forward energy on DP53..DP55, reverse energy on DP57..DP59 and per-phase
-- power factor on DP108/DP117/DP126.  DP101 locates the device and DP102 is a
-- writable report interval with a 30 s floor.
local power_meter_model_spm02v1gt = {
  profile = "meters-energy-3phase-spm02v1gt",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_energy(23, {
    name = "produced_energy",
    scale = 100,
    read_only = true,
    emit = emit.spm02v1gtProducedEnergy(),
  }),
  tuya.dp_phase_variant2(6, {
    phase = "a",
    component = "l1",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_phase_variant2(7, {
    phase = "b",
    component = "l2",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_phase_variant2(8, {
    phase = "c",
    component = "l3",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_power(29, { emit = emit.power() }),
  tuya.dp_ac_frequency(32, {
    name = "ac_frequency",
    read_only = true,
    emit = emit.spm02v1gtAcFrequency(),
  }),
  tuya.dp_power_factor(50, {
    name = "power_factor",
    read_only = true,
    emit = emit.spm02v1gtPowerFactor(),
  }),
  tuya.dp_energy(53, { name = "energy_a", scale = 100, component = "l1", emit = emit.energy() }),
  tuya.dp_energy(54, { name = "energy_b", scale = 100, component = "l2", emit = emit.energy() }),
  tuya.dp_energy(55, { name = "energy_c", scale = 100, component = "l3", emit = emit.energy() }),
  tuya.dp_energy(57, { name = "energy_produced_a", scale = 100 }),            -- 프로파일 미포함
  tuya.dp_energy(58, { name = "energy_produced_b", scale = 100 }),            -- 프로파일 미포함
  tuya.dp_energy(59, { name = "energy_produced_c", scale = 100 }),            -- 프로파일 미포함
  tuya.dp_on_off(101, {
    name = "device_locating",
    emit = emit.spm02v1gtDeviceLocating(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_numeric(102, { name = "update_frequency", emit = emit.spm02v1gtUpdateFrequency() }),
  tuya.dp_power_factor(108, { name = "power_factor_a" }),                     -- 프로파일 미포함
  tuya.dp_power_factor(117, { name = "power_factor_b" }),                     -- 프로파일 미포함
  tuya.dp_power_factor(126, { name = "power_factor_c" }),                     -- 프로파일 미포함
}

register_device_definition(power_meter_model_spm02v1gt, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_wjk6rurm",
  "_TZE204_wjk6rurm",
  "_TZE284_wjk6rurm",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-6g. power_meter_model_sdm01v1gt: 3상 에너지 모니터 (grid-tie)
-- Z2M: SDM01V1-GT (tuya.ts:16868)
-- ══════════════════════════════════════════════════════════════
-- Same datapoint map as SPM02V1-GT.  The only functional difference in Z2M is
-- the DP102 report interval floor, which drops from 30 s to 5 s, so this stays
-- a separate family with its own fixed-range capability.
local power_meter_model_sdm01v1gt = {
  profile = "meters-energy-3phase-sdm01v1gt",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_energy(23, {
    name = "produced_energy",
    scale = 100,
    read_only = true,
    emit = emit.sdm01v1gtProducedEnergy(),
  }),
  tuya.dp_phase_variant2(6, {
    phase = "a",
    component = "l1",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_phase_variant2(7, {
    phase = "b",
    component = "l2",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_phase_variant2(8, {
    phase = "c",
    component = "l3",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_power(29, { emit = emit.power() }),
  tuya.dp_ac_frequency(32, {
    name = "ac_frequency",
    read_only = true,
    emit = emit.sdm01v1gtAcFrequency(),
  }),
  tuya.dp_power_factor(50, {
    name = "power_factor",
    read_only = true,
    emit = emit.sdm01v1gtPowerFactor(),
  }),
  tuya.dp_energy(53, { name = "energy_a", scale = 100, component = "l1", emit = emit.energy() }),
  tuya.dp_energy(54, { name = "energy_b", scale = 100, component = "l2", emit = emit.energy() }),
  tuya.dp_energy(55, { name = "energy_c", scale = 100, component = "l3", emit = emit.energy() }),
  tuya.dp_energy(57, { name = "energy_produced_a", scale = 100 }),            -- 프로파일 미포함
  tuya.dp_energy(58, { name = "energy_produced_b", scale = 100 }),            -- 프로파일 미포함
  tuya.dp_energy(59, { name = "energy_produced_c", scale = 100 }),            -- 프로파일 미포함
  tuya.dp_on_off(101, {
    name = "device_locating",
    emit = emit.sdm01v1gtDeviceLocating(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_numeric(102, { name = "update_frequency", emit = emit.sdm01v1gtUpdateFrequency() }),
  tuya.dp_power_factor(108, { name = "power_factor_a" }),                     -- 프로파일 미포함
  tuya.dp_power_factor(117, { name = "power_factor_b" }),                     -- 프로파일 미포함
  tuya.dp_power_factor(126, { name = "power_factor_c" }),                     -- 프로파일 미포함
}

register_device_definition(power_meter_model_sdm01v1gt, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_s4sa1mcx",
  "_TZE204_s4sa1mcx",
  "_TZE284_s4sa1mcx",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-7. power_meter_model_ts0601_3_phase_clamp_meter: 3상 클램프 계량기
-- Z2M: TS0601_3_phase_clamp_meter
-- ══════════════════════════════════════════════════════════════
-- Z2M TS0601_3_phase_clamp_meter (tuya.ts:15086) reports phase voltage, current
-- and power through the DP6/DP7/DP8 phase-variant-2 frames and per-phase energy
-- on DP101/DP111/DP121 with a /1000 scale.  Those phase frames and energies were
-- parsed but not reachable, so the meter only showed totals.  DP132 uses
-- valueConverter.raw so it is already in Hz, and DP135 is the /100 high
-- precision variant that only appears on applicationVersion 132 and later.
local power_meter_model_ts0601_3_phase_clamp_meter = {
  profile = "meters-power-energy-voltage-current-clamp3phase",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_power(9, { emit = emit.power() }),
  tuya.dp_energy(101, { name = "energy_a", component = "l1", scale = 1000, emit = emit.energy() }),
  tuya.dp_power_factor(102, { name = "power_factor", component = "l1", emit = emit.powerFactorClamp3PhasePercent() }),
  tuya.dp_energy(111, { name = "energy_b", component = "l2", scale = 1000, emit = emit.energy() }),
  tuya.dp_power_factor(112, { name = "power_factor", component = "l2", emit = emit.powerFactorClamp3PhasePercent() }),
  tuya.dp_energy(121, { name = "energy_c", component = "l3", scale = 1000, emit = emit.energy() }),
  tuya.dp_power_factor(122, { name = "power_factor", component = "l3", emit = emit.powerFactorClamp3PhasePercent() }),
  tuya.dp_numeric(132, { name = "ac_frequency", emit = emit.acFrequencyClamp3Phase() }),
  tuya.dp_temperature(133, {
    name = "temperature",
    scale = 10,
    read_only = true,
    emit = emit.temperature(),
  }),
  tuya.dp_current(131, { emit = emit.current() }),
  tuya.dp_phase_variant2(6, {
    phase = "a",
    component = "l1",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_phase_variant2(7, {
    phase = "b",
    component = "l2",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_phase_variant2(8, {
    phase = "c",
    component = "l3",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_numeric(134, { name = "device_status" }),                         -- 프로파일 미포함
  tuya.dp_ac_frequency(135, {
    name = "ac_frequency_high_precision",
    read_only = true,
    emit = emit.clamp3PhaseAcFreqHighPrecision(),
  }),
}

register_device_definition(power_meter_model_ts0601_3_phase_clamp_meter, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_nslr42tt",
}))

register_device_definition(power_meter_model_ts0601_3_phase_clamp_meter, {
  device_helpers.create_fingerprint("MatSee Plus", "PC321-Z-TY"),
  device_helpers.create_fingerprint("OWON", "PC321-Z-TY"),
})

-- ══════════════════════════════════════════════════════════════
-- 1-8. power_meter_model_ts0601_3_phase_clamp_meter_relay: 3상 클램프 계량 릴레이
-- Z2M: TS0601_3_phase_clamp_meter_relay
-- ══════════════════════════════════════════════════════════════
-- Z2M TS0601_3_phase_clamp_meter_relay (tuya.ts:15148): DP16 switch, DP1 total
-- energy /100, DP2 produced energy /100, DP9 total power and DP6/DP7/DP8
-- carrying voltage, current and power for phases A, B and C.  Only the total
-- energy, power and switch plus phase A were exposed before, so the produced
-- energy and phases B and C are now on their own components.
local power_meter_model_ts0601_3_phase_clamp_meter_relay = {
  profile = "meters-switch-power-energy-clamp3phase-relay",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_energy(2, {
    name = "produced_energy",
    scale = 100,
    read_only = true,
    emit = emit.clamp3RelayProducedEnergy(),
  }),
  tuya.dp_on_off(16, { name = "switch", emit = emit.switch() }),
  tuya.dp_power(9, { emit = emit.power() }),
  tuya.dp_phase_variant2(6, {
    phase = "a",
    component = "l1",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_phase_variant2(7, {
    phase = "b",
    component = "l2",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_phase_variant2(8, {
    phase = "c",
    component = "l3",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
}

register_device_definition(power_meter_model_ts0601_3_phase_clamp_meter_relay, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_x8fp01wi",
  "_TZE204_x8fp01wi",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-9. power_meter_model_ts0601_bidirectional_energy_meter: 양방향 에너지 미터
-- Z2M: TS0601_bidirectional_energy meter
-- ══════════════════════════════════════════════════════════════
local power_meter_model_ts0601_bidirectional_energy_meter = {
  profile = "meters-power-energy-voltage-current-bidirectional",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_energy(2, { name = "produced_energy", scale = 100, emit = emit.producedEnergyBidirectionalMeter() }),
  tuya.dp_phase_variant3(6, {
    emit = emit_metric_bundle({
      voltage = true,
      current = true,
      power = true,
    }),
  }),
  tuya.dp_enum(102, { name = "energy_flow" }),                              -- 프로파일 미포함
}

register_device_definition(power_meter_model_ts0601_bidirectional_energy_meter, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_ac0fhfiq",
  "_TZE284_ac0fhfiq",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-9a. power_meter_model_spm01: 1P+N 에너지 모니터
-- Z2M: SPM01 (tuya.ts:16034)
-- ══════════════════════════════════════════════════════════════
-- SPM01 has no DP102 energy flow enum, so it does not belong on the
-- bidirectional definition.  Z2M reports only DP1 forward energy, DP2 reverse
-- energy and the DP6 phaseVariant4 frame, whose byte layout matches the local
-- phase_variant3 parser (2-byte voltage /10, 3-byte current /1000, 3-byte
-- power).  DP9 is an unknown bitmap and stays unexposed.
local power_meter_model_spm01 = {
  profile = "meters-energy-1phase-spm01",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_energy(2, {
    name = "produced_energy",
    scale = 100,
    read_only = true,
    emit = emit.spm01ProducedEnergy(),
  }),
  tuya.dp_phase_variant3(6, {
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
}

register_device_definition(power_meter_model_spm01, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_bcusnqt8",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-9b. power_meter_model_spm01v2: 1P+N 에너지 모니터
-- Z2M: SPM01V2 (tuya.ts:16089)
-- ══════════════════════════════════════════════════════════════
-- This generation does not use DP6 at all: Z2M has that mapping commented out
-- and reads voltage, current and power from separate DP102/DP103/DP104 scalars,
-- with power factor on DP15 and AC frequency on DP101.  Reading DP6 as the
-- bidirectional definition did produced nothing.  DP18 needs a 24-byte settings
-- frame and DP16 clear energy is commented out upstream, so both stay internal.
local power_meter_model_spm01v2 = {
  profile = "meters-energy-1phase-spm01v2",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_energy(2, {
    name = "produced_energy",
    scale = 100,
    read_only = true,
    emit = emit.spm01v2ProducedEnergy(),
  }),
  tuya.dp_power_factor(15, {
    name = "power_factor",
    read_only = true,
    emit = emit.spm01v2PowerFactor(),
  }),
  tuya.dp_raw(18, { name = "data_report_duration" }),                       -- 프로파일 미포함
  tuya.dp_ac_frequency(101, {
    name = "ac_frequency",
    read_only = true,
    emit = emit.spm01v2AcFrequency(),
  }),
  tuya.dp_voltage(102, { emit = emit.voltage() }),
  tuya.dp_current(103, { emit = emit.current() }),
  tuya.dp_power(104, { emit = emit.power() }),
}

register_device_definition(power_meter_model_spm01v2, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_qhlxve78",
  "_TZE204_qhlxve78",
  "_TZE284_qhlxve78",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-9c. power_meter_model_spm01v25: 1P+N 에너지 모니터
-- Z2M: SPM01V2.5 (tuya.ts:16303)
-- ══════════════════════════════════════════════════════════════
-- Same scalar voltage/current/power block as SPM01V2 but the totals moved:
-- reverse energy is DP23, AC frequency is DP32 and power factor is DP50.
local power_meter_model_spm01v25 = {
  profile = "meters-energy-1phase-spm01v25",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_raw(18, { name = "data_report_duration" }),                       -- 프로파일 미포함
  tuya.dp_energy(23, {
    name = "produced_energy",
    scale = 100,
    read_only = true,
    emit = emit.spm01v25ProducedEnergy(),
  }),
  tuya.dp_ac_frequency(32, {
    name = "ac_frequency",
    read_only = true,
    emit = emit.spm01v25AcFrequency(),
  }),
  tuya.dp_power_factor(50, {
    name = "power_factor",
    read_only = true,
    emit = emit.spm01v25PowerFactor(),
  }),
  tuya.dp_voltage(102, { emit = emit.voltage() }),
  tuya.dp_current(103, { emit = emit.current() }),
  tuya.dp_power(104, { emit = emit.power() }),
}

register_device_definition(power_meter_model_spm01v25, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_iwn0gpzz",
  "_TZE204_iwn0gpzz",
  "_TZE284_iwn0gpzz",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-9d. power_meter_model_spm01v1gt: 1P+N 에너지 모니터 (grid-tie)
-- Z2M: SPM01V1-GT (tuya.ts:16767)
-- ══════════════════════════════════════════════════════════════
-- Grid-tie single phase: DP1/DP23 totals, DP6 phaseVariant3 metrics, DP32
-- frequency, DP50 power factor, DP101 device locating and DP102 report
-- interval.  The bidirectional definition read DP2 and DP102 as energy flow,
-- neither of which this model reports.
local power_meter_model_spm01v1gt = {
  profile = "meters-energy-1phase-spm01v1gt",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_energy(23, {
    name = "produced_energy",
    scale = 100,
    read_only = true,
    emit = emit.spm01v1gtProducedEnergy(),
  }),
  tuya.dp_phase_variant3(6, {
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_ac_frequency(32, {
    name = "ac_frequency",
    read_only = true,
    emit = emit.spm01v1gtAcFrequency(),
  }),
  tuya.dp_power_factor(50, {
    name = "power_factor",
    read_only = true,
    emit = emit.spm01v1gtPowerFactor(),
  }),
  tuya.dp_on_off(101, {
    name = "device_locating",
    emit = emit.spm01v1gtDeviceLocating(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_numeric(102, { name = "update_frequency", emit = emit.spm01v1gtUpdateFrequency() }),
}

register_device_definition(power_meter_model_spm01v1gt, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_d2zfgtij",
  "_TZE204_d2zfgtij",
  "_TZE284_d2zfgtij",
}))

-- PC311-Z-TY: bidirectional 2-channel clamp meter
-- Z2M PC311-Z-TY (tuya.ts:18653) also reports per-channel forward energy on
-- DP101/DP103 and reverse energy on DP102/DP104, which were missing from the
-- definition entirely, and the DP107..DP111 channel current and power were
-- parsed but unreachable.  DP113 uses valueConverter.raw so the frequency is
-- already in Hz.
local power_meter_model_pc311 = {
  profile = "meters-power-energy-voltage-current-pc311",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_energy(2, {
    name = "energy_produced",
    scale = 100,
    read_only = true,
    emit = emit.pc311ProducedEnergy(),
  }),
  tuya.dp_power(9, { emit = emit.power() }),
  tuya.dp_energy(101, { name = "energy_a", component = "ct1", scale = 100, emit = emit.energy() }),
  tuya.dp_energy(103, { name = "energy_b", component = "ct2", scale = 100, emit = emit.energy() }),
  tuya.dp_energy(102, {
    name = "energy_produced_a",
    component = "ct1",
    scale = 100,
    read_only = true,
    emit = emit.pc311ProducedEnergy(),
  }),
  tuya.dp_energy(104, {
    name = "energy_produced_b",
    component = "ct2",
    scale = 100,
    read_only = true,
    emit = emit.pc311ProducedEnergy(),
  }),
  tuya.dp_current(105, { emit = emit.current(), scale = 1000 }),
  tuya.dp_voltage(106, { emit = emit.voltage(), scale = 10 }),
  tuya.dp_current(107, { name = "current_a", component = "ct1", scale = 1000, emit = emit.current() }),
  tuya.dp_power(108, { name = "power_a", component = "ct1", emit = emit.power() }),
  tuya.dp_power_factor(109, { name = "power_factor", component = "ct1", emit = emit.powerFactorPc311Percent() }),
  tuya.dp_current(110, { name = "current_b", component = "ct2", scale = 1000, emit = emit.current() }),
  tuya.dp_power(111, { name = "power_b", component = "ct2", emit = emit.power() }),
  tuya.dp_power_factor(112, { name = "power_factor", component = "ct2", emit = emit.powerFactorPc311Percent() }),
  tuya.dp_ac_frequency(113, { name = "ac_frequency", emit = emit.acFrequencyPc311() }),
}

register_device_definition(power_meter_model_pc311, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_rks0sgb7",
}))

-- 2CT: two-channel bidirectional meter
-- Z2M 2CT (tuya.ts:16209) exposes both clamp channels plus six calibration
-- factors.  DP101..DP104 and DP115/DP117 were parsed but unreachable, and the
-- DP123..DP131 calibration block was not mapped at all.  Note DP131 is
-- calibration power B here, not a current reading.
local power_meter_model_2ct = {
  profile = "meters-power-energy-voltage-current-2ct",
  tuya.dp_power(19, { emit = emit.power(), scale = 10 }),
  tuya.dp_voltage(20, { emit = emit.voltage(), scale = 10 }),
  tuya.dp_current(101, { name = "current_a", component = "ct1", scale = 1000, emit = emit.current() }),
  tuya.dp_current(102, { name = "current_b", component = "ct2", scale = 1000, emit = emit.current() }),
  tuya.dp_power(103, { name = "power_a", component = "ct1", scale = 10, emit = emit.power() }),
  tuya.dp_power(104, { name = "power_b", component = "ct2", scale = 10, emit = emit.power() }),
  tuya.dp_ac_frequency(105, { name = "ac_frequency", scale = 100, emit = emit.acFrequency2ct() }),
  tuya.dp_energy(115, { name = "energy_a", component = "ct1", emit = emit.energy(), scale = 100 }),
  tuya.dp_energy(117, { name = "energy_b", component = "ct2", emit = emit.energy(), scale = 100 }),
  tuya.dp_power_factor(120, { name = "power_factor", component = "ct1", emit = emit.powerFactor2ctPercent() }),
  tuya.dp_power_factor(121, { name = "power_factor", component = "ct2", emit = emit.powerFactor2ctPercent() }),
  tuya.dp_numeric(122, { name = "update_frequency", emit = emit.updateFrequency2ctSeconds60() }),
  tuya.dp_numeric(123, {
    name = "calibration_voltage",
    emit = emit.twoCtCalibrationVoltage(),
    converter = converter.divide_by_pair(1000),
  }),
  tuya.dp_numeric(124, {
    name = "calibration_ac_frequency",
    emit = emit.twoCtCalibrationAcFrequency(),
    converter = converter.divide_by_pair(1000),
  }),
  tuya.dp_numeric(125, {
    name = "calibration_current_a",
    emit = emit.twoCtCalibrationCurrentA(),
    converter = converter.divide_by_pair(1000),
  }),
  tuya.dp_numeric(126, {
    name = "calibration_power_a",
    emit = emit.twoCtCalibrationPowerA(),
    converter = converter.divide_by_pair(1000),
  }),
  tuya.dp_numeric(130, {
    name = "calibration_current_b",
    emit = emit.twoCtCalibrationCurrentB(),
    converter = converter.divide_by_pair(1000),
  }),
  tuya.dp_numeric(131, {
    name = "calibration_power_b",
    emit = emit.twoCtCalibrationPowerB(),
    converter = converter.divide_by_pair(1000),
  }),
}

register_device_definition(power_meter_model_2ct, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_dhotiauw",
}))

-- PJ-1203A: compact bidirectional clamp meter
-- Z2M PJ-1203A (tuya.ts:18574) routes every channel datapoint through stateful
-- private converters, but the scales are unambiguous: DP101/DP105 power /10,
-- DP113/DP114 current /1000, DP110/DP121 power factor raw percent, DP106..DP109
-- forward and reverse energy /100.  Only DP111, DP112 and DP129 were mapped, so
-- both measurement channels were invisible.  DP102/DP104 only carry the sign of
-- the matching power value and DP115 is documented as broken upstream, so they
-- stay internal.
local power_meter_model_pj1203a = {
  profile = "meters-power-energy-voltage-current-pj1203a",
  tuya.dp_ac_frequency(111, {
    name = "ac_frequency",
    read_only = true,
    emit = emit.pj1203aAcFrequency(),
  }),
  tuya.dp_voltage(112, { emit = emit.voltage() }),
  tuya.dp_power(101, { name = "power_a", component = "ct1", scale = 10, emit = emit.power() }),
  tuya.dp_power(105, { name = "power_b", component = "ct2", scale = 10, emit = emit.power() }),
  tuya.dp_current(113, { name = "current_a", component = "ct1", scale = 1000, emit = emit.current() }),
  tuya.dp_current(114, { name = "current_b", component = "ct2", scale = 1000, emit = emit.current() }),
  tuya.dp_power_factor(110, {
    name = "power_factor_a",
    component = "ct1",
    read_only = true,
    emit = emit.pj1203aPowerFactor(),
  }),
  tuya.dp_power_factor(121, {
    name = "power_factor_b",
    component = "ct2",
    read_only = true,
    emit = emit.pj1203aPowerFactor(),
  }),
  tuya.dp_energy(106, { name = "energy_a", component = "ct1", scale = 100, emit = emit.energy() }),
  tuya.dp_energy(108, { name = "energy_b", component = "ct2", scale = 100, emit = emit.energy() }),
  tuya.dp_energy(107, {
    name = "energy_produced_a",
    component = "ct1",
    scale = 100,
    read_only = true,
    emit = emit.pj1203aProducedEnergy(),
  }),
  tuya.dp_energy(109, {
    name = "energy_produced_b",
    component = "ct2",
    scale = 100,
    read_only = true,
    emit = emit.pj1203aProducedEnergy(),
  }),
  tuya.dp_numeric(102, { name = "energy_flow_a" }),                       -- profile 미포함
  tuya.dp_numeric(104, { name = "energy_flow_b" }),                       -- profile 미포함
  tuya.dp_power(115, { name = "power_ab" }),                              -- profile 미포함
  tuya.dp_numeric(129, { name = "update_frequency", emit = emit.updateFrequencyPj1203aSeconds60() }),
}

register_device_definition(power_meter_model_pj1203a, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_81yrt3lo",
  "_TZE284_81yrt3lo",
  "_TZE28C1000000_81yrt3lo",
}))

-- SMKG-2KNL-SD smart leakage protector
-- Z2M SMKG-2KNL-SD (tuya.ts:25032): DP1 switch, DP17 energy /100, DP18 current
-- /100 (not /1000), DP19 power /10, DP20 voltage /10, DP47 temperature raw,
-- DP53 leakage current raw, DP41..DP45 writable thresholds and DP9 the circuit
-- breaker fault bitmap.  The definition used the default current and power
-- scales and left DP9 and the DP42..DP45 thresholds unreachable.
local din_rail_model_leakage_protector = {
  profile = "din-rail-switch-power-energy-voltage-current-leakage-protector",
  query_on_configure = true,
  named_datapoints = true,
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main", emit = emit.switch() }),
    tuya.dp_energy(17, { emit = emit.energy(), scale = 100 }),
    tuya.dp_current(18, { emit = emit.current(), scale = 100 }),
    tuya.dp_power(19, { emit = emit.power(), scale = 10 }),
    tuya.dp_voltage(20, { emit = emit.voltage(), scale = 10 }),
    tuya.dp_numeric(9, {
      name = "faults",
      read_only = true,
      emit = emit.smkg2knlFaults(),
      converter = circuit_breaker_faults_converter,
    }),
    tuya.dp_numeric(41, { name = "leakage_threshold", emit = emit.leakageThresholdProtector100ma() }),
    tuya.dp_numeric(42, { name = "over_voltage_threshold", emit = emit.smkg2knlOverVoltageThreshold() }),
    tuya.dp_numeric(43, { name = "under_voltage_threshold", emit = emit.smkg2knlUnderVoltageThreshold() }),
    tuya.dp_numeric(44, { name = "over_current_threshold", emit = emit.smkg2knlOverCurrentThreshold() }),
    tuya.dp_numeric(45, { name = "temperature_threshold", emit = emit.smkg2knlTemperatureThreshold() }),
    tuya.dp_temperature(47, {
      name = "temperature",
      scale = 1,
      read_only = true,
      emit = emit.temperature(),
    }),
    tuya.dp_numeric(53, { name = "leakage_current", emit = emit.leakageCurrentProtector() }),
  },
}

register_device_definition(din_rail_model_leakage_protector, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_5m4nchbm",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-9a. power_meter_model_atms10013z3: 3상 전력계
-- Z2M: ATMS10013Z3 / ATMS100133Z
-- ══════════════════════════════════════════════════════════════
local power_meter_model_atms10013z3 = {
  profile = "meters-energy-3phase-atms10013z3",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_phase_variant2(6, {
    phase = "a",
    component = "l1",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_phase_variant2(7, {
    phase = "b",
    component = "l2",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_phase_variant2(8, {
    phase = "c",
    component = "l3",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_energy(23, {
    name = "produced_energy",
    scale = 100,
    read_only = true,
    emit = emit.atms10013z3ProducedEnergy(),
  }),
  tuya.dp_energy(24, {
    name = "total_energy",
    scale = 100,
    read_only = true,
    emit = emit.atms10013z3TotalEnergy(),
  }),
  tuya.dp_power(29, { emit = emit.power(), scale = 1 }),
  tuya.dp_numeric(30, { name = "power_reactive", emit = emit.reactivePowerAtms10013z3() }),
  tuya.dp_power_factor(50, {
    name = "power_factor",
    read_only = true,
    emit = emit.atms10013z3PowerFactor(),
  }),
}

register_device_definition(power_meter_model_atms10013z3, {
  device_helpers.create_fingerprint("_TZE284_a14rjslz", "TS0601"),
  device_helpers.create_fingerprint("Ourtop", "ATMS100133Z"),
})

-- ══════════════════════════════════════════════════════════════
-- 1-10. din_rail_model_ts0601_rcbo: RCBO + 계측
-- Z2M: TS0601_rcbo / ZJSBL7-100Z
-- ══════════════════════════════════════════════════════════════
local din_rail_model_ts0601_rcbo = {
  profile = "din-rail-switch-power-energy-voltage-current-rcbo",
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", emit = emit.switch() }),
    tuya.dp_numeric(9, { name = "countdown_timer", emit = emit.rcboCountdownTimer() }),
    tuya.dp_enum(26, {
      name = "alarm",
      read_only = true,
      emit = emit.rcboAlarm(),
      converter = converter.from_only(converter.lookup_value({
        [0] = "clear",
        [1] = "over_voltage_threshold",
        [2] = "under_voltage_threshold",
        [4] = "over_current_threshold",
        [8] = "over_temperature_threshold",
        [10] = "over_leakage_current_threshold",
        [16] = "trip_test",
        [128] = "safety_lock",
      })),
    }),
    tuya.dp_power_on_behavior(27, {
      name = "power_on_behavior",
      emit = emit.rcboPowerOnBehavior(),
      converter = converter.lookup_from_to({ off = 0, on = 1, previous = 2 }),
    }),
    tuya.dp_child_lock(29, { name = "child_lock", emit = emit.rcboChildLock() }),
    tuya.dp_raw(101, { name = "voltage", converter = converter.raw_uint_be(10, { length = 2 }), emit = emit_voltage }),
    tuya.dp_raw(102, { name = "current", converter = converter.raw_uint_be(1000, { start = 2, length = 2 }), emit = emit_current }),
    tuya.dp_raw(103, { name = "power", converter = converter.raw_uint_be(10, { start = 2, length = 2 }), emit = emit_power }),
    tuya.dp_temperature(105, {
      name = "temperature",
      scale = 1,
      read_only = true,
      emit = emit.temperature(),
    }),
    tuya.dp_raw(110, { name = "voltage_threshold" }),                      -- 프로파일 미포함
    tuya.dp_numeric(111, { name = "current_threshold", emit = emit.currentThresholdRcbo63a() }),
    tuya.dp_raw(112, { name = "temperature_threshold" }),                  -- 프로파일 미포함
    tuya.dp_energy(113, { emit = emit.energy(), scale = 100 }),
    tuya.dp_string(114, { name = "meter_number", read_only = true, emit = emit.rcboMeterNumber() }),
    tuya.dp_on_off(115, { name = "clear_energy", emit = emit.clearEnergyRcbo(), converter = converter.lookup_from_to({ on = true, off = false }) }),
    tuya.dp_binary(116, { name = "trip_test", emit = emit.tripTestRcboTripClear(), converter = converter.lookup_from_to({ trip = true, clear = false }) }),
    tuya.dp_raw(118, {
      name = "voltage_rms",
      converter = converter.raw_uint_be(10, { length = 2 }),
      emit = emit.rcboVoltageRms(),
    }),
    tuya.dp_raw(119, {
      name = "current_average",
      converter = converter.raw_uint_be(1000, { start = 2, length = 2 }),
      emit = emit.rcboCurrentAverage(),
    }),
  },
}

register_device_definition(din_rail_model_ts0601_rcbo, {
  device_helpers.create_fingerprint("_TZE200_hkdl5fmv", "TS0601"),
  device_helpers.create_fingerprint("HOCH", "ZJSBL7-100Z"),
  device_helpers.create_fingerprint("WDYK", "ZJSBL7-100Z"),
})

-- ══════════════════════════════════════════════════════════════
-- 1-10a. din_rail_model_to_q_sys_jzt: 단상 스마트 미터 + RCBO 이벤트
-- Z2M: TO-Q-SYS-JZT
-- ══════════════════════════════════════════════════════════════
-- Z2M TO-Q-SYS-JZT (tuya.ts:19540) is a meter, not an RCBO.  DP108 is the
-- control mode enum here, and there is no DP112 auto reclosing, DP113 restore
-- default, DP117 leakage threshold or DP143..DP145 recloser block.  DP13 and
-- DP125 are marked unknown upstream so they stay internal.
local din_rail_model_to_q_sys_jzt = {
  profile = "din-rail-switch-power-energy-voltage-current-toqjzt",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_phase_variant2(6, {
    emit = emit_metric_bundle({
      voltage = true,
      current = true,
      power = true,
    }),
  }),
  tuya.dp_numeric(13, { name = "test1" }),                                -- 프로파일 미포함
  tuya.dp_numeric(15, { name = "leakage_current", emit = emit.leakageCurrentToqJzt() }),
  tuya.dp_on_off(16, { name = "switch", emit = emit.switch() }),
  -- Z2M uses valueConverter.raw here, so this datapoint is already in Hz.
  tuya.dp_ac_frequency(32, {
    name = "ac_frequency",
    scale = 1,
    read_only = true,
    emit = emit.toqjztAcFrequency(),
  }),
  tuya.dp_power_factor(50, {
    name = "power_factor",
    read_only = true,
    emit = emit.toqjztPowerFactor(),
  }),
  tuya.dp_enum(102, {
    name = "over_voltage_setting",
    emit = emit.toqjztOverVoltageSetting(),
    converter = converter.lookup_from_to(ALARM_TRIP_SETTING),
  }),
  tuya.dp_enum(103, {
    name = "under_voltage_setting",
    emit = emit.toqjztUnderVoltageSetting(),
    converter = converter.lookup_from_to(ALARM_TRIP_SETTING),
  }),
  tuya.dp_enum(104, {
    name = "over_current_setting",
    emit = emit.toqjztOverCurrentSetting(),
    converter = converter.lookup_from_to(ALARM_TRIP_SETTING),
  }),
  tuya.dp_enum(105, {
    name = "over_power_setting",
    emit = emit.toqjztOverPowerSetting(),
    converter = converter.lookup_from_to(ALARM_TRIP_SETTING),
  }),
  tuya.dp_enum(107, {
    name = "temperature_setting",
    emit = emit.toqjztTemperatureSetting(),
    converter = converter.lookup_from_to(ALARM_TRIP_SETTING),
  }),
  tuya.dp_enum(108, {
    name = "control_mode",
    emit = emit.toqjztControlMode(),
    converter = converter.lookup_from_to({
      local_lock = 0,
      local_mode = 1,
      remote_mode = 2,
      full_control = 3,
    }),
  }),
  tuya.dp_enum(110, {
    name = "event",
    read_only = true,
    emit = emit.toqjztEvent(),
    converter = converter.from_only(converter.lookup_value(BREAKER_EVENT_LOOKUP)),
  }),
  tuya.dp_numeric(114, { name = "over_current_threshold", emit = emit.toqjztOverCurrentThreshold() }),
  tuya.dp_numeric(115, { name = "over_voltage_threshold", emit = emit.toqjztOverVoltageThreshold() }),
  tuya.dp_numeric(116, { name = "under_voltage_threshold", emit = emit.toqjztUnderVoltageThreshold() }),
  tuya.dp_temperature(118, {
    name = "temperature_threshold",
    scale = 10,
    emit = emit.toqjztTemperatureThreshold(),
  }),
  tuya.dp_numeric(119, { name = "over_power_threshold", emit = emit.toqjztOverPowerThreshold() }),
  tuya.dp_numeric(125, { name = "test5" }),                                -- 프로파일 미포함
  tuya.dp_temperature(131, {
    name = "temperature",
    scale = 10,
    read_only = true,
    emit = emit.temperature(),
  }),
}

register_device_definition(din_rail_model_to_q_sys_jzt, {
  device_helpers.create_fingerprint("_TZE284_6ocnqlhn", "TS0601"),
})

-- ══════════════════════════════════════════════════════════════
-- 1-10aa. din_rail_model_towsmr1: Tongou TOWSMR1 RCBO
-- Z2M: TOWSMR1
-- ══════════════════════════════════════════════════════════════
-- Z2M TOWSMR1 (tuya.ts:19248) is a single phase RCBO.  It shares the setting and
-- threshold datapoints with TO-Q-SYS-JZT but DP108 is the leakage protection
-- setting rather than a control mode, and it adds DP112 auto reclosing, DP113
-- restore default, DP117 leakage threshold and the DP143..DP145 reclosers.  It
-- also has no DP32 frequency or DP50 power factor.  Sharing the meter definition
-- meant writing a control mode value into the leakage protection setting.
local din_rail_model_towsmr1 = {
  profile = "din-rail-switch-power-energy-voltage-current-towsmr1",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_phase_variant2(6, {
    emit = emit_metric_bundle({
      voltage = true,
      current = true,
      power = true,
    }),
  }),
  tuya.dp_numeric(15, { name = "leakage_current", read_only = true, emit = emit.towsmr1LeakageCurrent() }),
  tuya.dp_on_off(16, { name = "switch", emit = emit.switch() }),
  tuya.dp_enum(102, {
    name = "over_voltage_setting",
    emit = emit.towsmr1OverVoltageSetting(),
    converter = converter.lookup_from_to(ALARM_TRIP_SETTING),
  }),
  tuya.dp_enum(103, {
    name = "under_voltage_setting",
    emit = emit.towsmr1UnderVoltageSetting(),
    converter = converter.lookup_from_to(ALARM_TRIP_SETTING),
  }),
  tuya.dp_enum(104, {
    name = "over_current_setting",
    emit = emit.towsmr1OverCurrentSetting(),
    converter = converter.lookup_from_to(ALARM_TRIP_SETTING),
  }),
  tuya.dp_enum(105, {
    name = "over_power_setting",
    emit = emit.towsmr1OverPowerSetting(),
    converter = converter.lookup_from_to(ALARM_TRIP_SETTING),
  }),
  tuya.dp_enum(107, {
    name = "temperature_setting",
    emit = emit.towsmr1TemperatureSetting(),
    converter = converter.lookup_from_to(ALARM_TRIP_SETTING),
  }),
  tuya.dp_enum(108, {
    name = "leakage_setting",
    emit = emit.towsmr1LeakageSetting(),
    converter = converter.lookup_from_to(ALARM_TRIP_SETTING),
  }),
  tuya.dp_enum(110, {
    name = "event",
    read_only = true,
    emit = emit.towsmr1Event(),
    converter = converter.from_only(converter.lookup_value(BREAKER_EVENT_LOOKUP)),
  }),
  tuya.dp_on_off(112, {
    name = "auto_reclosing",
    emit = emit.towsmr1AutoReclosing(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_on_off(113, {
    name = "restore_default",
    emit = emit.towsmr1RestoreDefault(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_numeric(114, { name = "over_current_threshold", emit = emit.towsmr1OverCurrentThreshold() }),
  tuya.dp_numeric(115, { name = "over_voltage_threshold", emit = emit.towsmr1OverVoltageThreshold() }),
  tuya.dp_numeric(116, { name = "under_voltage_threshold", emit = emit.towsmr1UnderVoltageThreshold() }),
  tuya.dp_numeric(117, { name = "leakage_threshold", emit = emit.towsmr1LeakageThreshold() }),
  tuya.dp_temperature(118, {
    name = "temperature_threshold",
    scale = 10,
    emit = emit.towsmr1TemperatureThreshold(),
  }),
  tuya.dp_numeric(119, { name = "over_power_threshold", emit = emit.towsmr1OverPowerThreshold() }),
  tuya.dp_temperature(131, {
    name = "temperature",
    scale = 10,
    read_only = true,
    emit = emit.temperature(),
  }),
  tuya.dp_on_off(143, {
    name = "overcurrent_recloser",
    emit = emit.towsmr1OvercurrentRecloser(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_on_off(144, {
    name = "leakage_recloser",
    emit = emit.towsmr1LeakageRecloser(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_on_off(145, {
    name = "overpower_recloser",
    emit = emit.towsmr1OverpowerRecloser(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
}

register_device_definition(din_rail_model_towsmr1, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_kobbcyum",
  "_TZE284_kobbcyum",
  "_TZE284_hecsejsb",
  "_TZE284_432zhuwe",
  "_TZE204_432zhuwe",
  "_TZE284_s5vuaadg",
  "_TZE284_tuhfx7tf",
  "_TZE204_tuhfx7tf",
}))

register_device_definition(din_rail_model_towsmr1, {
  device_helpers.create_fingerprint("Tongou", "TOWSMR1-40A-AC"),
  device_helpers.create_fingerprint("Tongou", "TOWSMR1-40A-A"),
  device_helpers.create_fingerprint("Tongou", "TOWSMR1-20A-AC"),
})

-- ══════════════════════════════════════════════════════════════
-- 1-10b. din_rail_model_zbn_jt_63: 전력 모니터링 DIN 스위치
-- Z2M: ZBN-JT-63
-- ══════════════════════════════════════════════════════════════
local din_rail_model_zbn_jt_63 = {
  profile = "din-rail-switch-power-energy-voltage-current-zbnjt63",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_numeric(3, { name = "monthly_energy" }),                        -- 프로파일 미포함
  tuya.dp_numeric(4, { name = "daily_energy" }),                          -- 프로파일 미포함
  tuya.dp_phase_variant3(6, {
    emit = emit_metric_bundle({
      voltage = true,
      current = true,
      power = true,
    }),
  }),
  tuya.dp_enum(10, {
    name = "fault",
    read_only = true,
    emit = emit.zbnjt63Fault(),
    converter = converter.from_only(converter.lookup_value({
      [0] = "clear",
      [1] = "ov_cr",
      [2] = "unbalance_alarm",
      [4] = "ov_vol",
      [8] = "undervoltage_alarm",
      [16] = "miss_phase_alarm",
      [32] = "outage_alarm",
      [64] = "magnetism_alarm",
      [128] = "terminal_alarm",
      [256] = "cover_alarm",
      [512] = "credit_alarm",
      [1024] = "no_balance_alarm",
      [2048] = "battery_alarm",
      [4096] = "meter_hardware_alarm",
    })),
  }),
  tuya.dp_on_off(16, { name = "switch", emit = emit.switch() }),
  tuya.dp_raw(18, {
    name = "meter_id",
    read_only = true,
    emit = emit.zbnjt63MeterId(),
    converter = converter.raw_identifier(),
  }),
  tuya.dp_power_outage_memory(23, {
    name = "power_outage_memory",
    emit = emit.zbnjt63PowerOutageMemory(),
    converter = converter.lookup_from_to({ on = 0, off = 1, restore = 2 }),
  }),
}

register_device_definition(din_rail_model_zbn_jt_63, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_jcwbwckh",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-10c. din_rail_model_dds238_1_z1: 단상 DIN 에너지 미터 + 스위치
-- Z2M: DDS238-1-Z1
-- ══════════════════════════════════════════════════════════════
local din_rail_model_dds238_1_z1 = {
  profile = "din-rail-switch-power-energy-voltage-current",
  tuya.dp_on_off(1, { name = "switch", emit = emit.switch() }),
  tuya.dp_energy(17, { emit = emit.energy(), scale = 100 }),
  tuya.dp_current(18, { emit = emit.current(), scale = 1000 }),
  tuya.dp_power(19, { emit = emit.power(), scale = 10 }),
  tuya.dp_voltage(20, { emit = emit.voltage(), scale = 10 }),
}

register_device_definition(din_rail_model_dds238_1_z1, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_byzdayie",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-10d. din_rail_model_rmdzb_1pnl63: 단상 DIN 에너지 미터 + 스위치
-- Z2M: RMDZB-1PNL63
-- ══════════════════════════════════════════════════════════════
-- Z2M RMDZB-1PNL63 (tuya.ts:10991) is single phase: DP1 energy /100, DP6
-- phaseVariant2 phase A only, DP9 circuit breaker fault bitmap, DP16 switch and
-- DP103 temperature as a raw degree value.  DP17/DP18 carry packed threshold
-- frames Z2M can only write through multi-byte raw payloads, and DP11..DP14,
-- DP105 and DP106 are explicitly marked unknown, so those stay internal.
local din_rail_model_rmdzb_1pnl63 = {
  profile = "din-rail-switch-power-energy-voltage-current-rmdzb1pnl63",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_phase_variant2(6, {
    emit = emit_metric_bundle({
      voltage = true,
      current = true,
      power = true,
    }),
  }),
  tuya.dp_numeric(9, {
    name = "faults",
    read_only = true,
    emit = emit.rmdzb1pnl63Faults(),
    converter = circuit_breaker_faults_converter,
  }),
  tuya.dp_on_off(16, { name = "switch", emit = emit.switch() }),
  tuya.dp_threshold(17, {}),                                               -- 프로파일 미포함
  tuya.dp_threshold(18, {}),                                               -- 프로파일 미포함
  tuya.dp_temperature(103, {
    name = "temperature",
    scale = 1,
    read_only = true,
    emit = emit.temperature(),
  }),
}

register_device_definition(din_rail_model_rmdzb_1pnl63, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_m64smti7",
}))

register_device_definition(din_rail_model_rmdzb_1pnl63, {
  device_helpers.create_fingerprint("TNCE", "RMDZB-1PNL63"),
})

-- ══════════════════════════════════════════════════════════════
-- 1-10d-0. din_rail_model_stb3l_125_zj: 3상 DIN RCBO 에너지 미터
-- Z2M: STB3L-125-ZJ (tuya.ts:11070)
-- ══════════════════════════════════════════════════════════════
-- The wbhaespm exacts are a different model from RMDZB-1PNL63: they report all
-- three phases through DP6/DP7/DP8, put temperature on DP102 with a /10 scale
-- instead of DP103 raw, and add the DP21 leakage self test.  Sharing the single
-- phase definition meant phases B and C were dropped and the temperature was
-- read from a datapoint this model never sends.
local din_rail_model_stb3l_125_zj = {
  profile = "din-rail-switch-power-energy-3phase-stb3l125zj",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_phase_variant2(6, {
    phase = "a",
    component = "l1",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_phase_variant2(7, {
    phase = "b",
    component = "l2",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_phase_variant2(8, {
    phase = "c",
    component = "l3",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_numeric(9, {
    name = "faults",
    read_only = true,
    emit = emit.stb3l125zjFaults(),
    converter = circuit_breaker_faults_converter,
  }),
  tuya.dp_on_off(16, { name = "switch", emit = emit.switch() }),
  tuya.dp_threshold(17, {}),                                               -- 프로파일 미포함
  tuya.dp_threshold(18, {}),                                               -- 프로파일 미포함
  tuya.dp_on_off(21, {
    name = "leakage_test",
    emit = emit.stb3l125zjLeakageTest(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_temperature(102, {
    name = "temperature",
    scale = 10,
    read_only = true,
    emit = emit.temperature(),
  }),
}

register_device_definition(din_rail_model_stb3l_125_zj, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_wbhaespm",
  "_TZE204_wbhaespm",
  "_TZE284_wbhaespm",
}))

register_device_definition(din_rail_model_stb3l_125_zj, {
  device_helpers.create_fingerprint("SUTON", "STB3L-125/ZJ"),
})

-- ══════════════════════════════════════════════════════════════
-- 1-10d-1. din_rail_model_zbn_dj_63: smart circuit breaker
-- Z2M: ZBN-DJ-63
-- ══════════════════════════════════════════════════════════════
-- Z2M ZBN-DJ-63 (tuya.ts:1824) exposes far more than the shared DIN profile
-- could reach: prepayment, recharge, reclosing, leakage and timer settings all
-- live on plain scalar datapoints.  Only DP1/DP6/DP16 were visible before, so
-- the definition now emits every scalar datapoint Z2M documents.  DP17/DP18 are
-- packed threshold frames and DP106 cycle time has no documented unit, so those
-- stay internal.
local din_rail_model_zbn_dj_63 = {
  profile = "din-rail-switch-power-energy-voltage-current-zbndj63",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_phase_variant2(6, {
    emit = emit_metric_bundle({
      voltage = true,
      current = true,
      power = true,
    }),
  }),
  tuya.dp_enum(9, {
    name = "faults",
    read_only = true,
    emit = emit.zbndj63Faults(),
    converter = converter.from_only(converter.lookup_value({
      [0] = "clear",
      [1] = "short_circuit_alarm",
      [2] = "surge_alarm",
      [4] = "overload_alarm",
      [8] = "leakagecurr_alarm",
      [16] = "temp_dif_fault",
      [32] = "fire_alarm",
      [64] = "high_power_alarm",
      [128] = "self_test_alarm",
      [256] = "ov_cr",
      [512] = "unbalance_alarm",
      [1024] = "ov_vol",
      [2048] = "undervoltage_alarm",
      [4096] = "miss_phase_alarm",
      [8192] = "outage_alarm",
      [16384] = "magnetism_alarm",
      [32768] = "credit_alarm",
      [65536] = "no_balance_alarm",
    })),
  }),
  tuya.dp_on_off(11, {
    name = "switch_prepayment",
    emit = emit.zbndj63SwitchPrepayment(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_on_off(12, {
    name = "clear_energy",
    emit = emit.zbndj63ClearEnergy(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_energy(13, {
    name = "balance_energy",
    scale = 100,
    read_only = true,
    emit = emit.zbndj63BalanceEnergy(),
  }),
  tuya.dp_energy(14, { name = "charge_energy", scale = 100, emit = emit.zbndj63ChargeEnergy() }),
  tuya.dp_numeric(15, {
    name = "leakage_current",
    read_only = true,
    emit = emit.zbndj63LeakageCurrent(),
  }),
  tuya.dp_on_off(16, { name = "switch", emit = emit.switch() }),
  tuya.dp_threshold(17, {}),                                              -- profile 미포함
  tuya.dp_threshold(18, {}),                                              -- profile 미포함
  tuya.dp_numeric(102, { name = "recover_count", emit = emit.zbndj63RecoverCount() }),
  tuya.dp_temperature(103, {
    name = "temperature",
    scale = 1,
    read_only = true,
    emit = emit.zbndj63Temperature(),
  }),
  tuya.dp_on_off(104, {
    name = "recover_enable",
    emit = emit.zbndj63RecoverEnable(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_numeric(105, { name = "countdown", emit = emit.zbndj63Countdown() }),
  tuya.dp_numeric(107, { name = "leakage_delay", emit = emit.zbndj63LeakageDelay() }),
  tuya.dp_energy(110, {
    name = "reverse_energy",
    scale = 100,
    read_only = true,
    emit = emit.zbndj63ReverseEnergy(),
  }),
  tuya.dp_numeric(119, { name = "power_on_delay", emit = emit.zbndj63PowerOnDelay() }),
  tuya.dp_numeric(124, { name = "alarm_over_current_count" }),           -- profile 미포함
  tuya.dp_numeric(125, { name = "alarm_low_current_count" }),            -- profile 미포함
  tuya.dp_numeric(127, { name = "status" }),                             -- profile 미포함
  tuya.dp_power_on_behavior(134, {
    name = "relay_power_on_state",
    emit = emit.zbndj63RelayPowerOnState(),
    converter = converter.lookup_from_to({
      off = 0,
      on = 1,
      restore = 2,
    }),
  }),
}

register_device_definition(din_rail_model_zbn_dj_63, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_lb0fsvba",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-10e. din_rail_model_toqcb2_80: Tongou 3-phase smart circuit breaker
-- Z2M: TOQCB2-80
-- ══════════════════════════════════════════════════════════════
local din_rail_model_toqcb2_80 = {
  profile = "din-rail-switch-power-energy-voltage-current-toqcb2",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_phase_variant2(6, {
    phase = "a",
    component = "l1",
    emit = emit_metric_bundle({
      voltage = true,
      current = true,
      power = true,
    }),
  }),
  tuya.dp_phase_variant2(7, {
    phase = "b",
    component = "l2",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_phase_variant2(8, {
    phase = "c",
    component = "l3",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_on_off(16, { name = "switch", emit = emit.switch() }),
  tuya.dp_enum(102, {
    name = "over_voltage_setting",
    emit = emit.toqcb2OverVoltageSetting(),
    converter = converter.lookup_from_to(CLOSED_ALARM_TRIP_SETTING),
  }),
  tuya.dp_enum(103, {
    name = "under_voltage_setting",
    emit = emit.toqcb2UnderVoltageSetting(),
    converter = converter.lookup_from_to(CLOSED_ALARM_TRIP_SETTING),
  }),
  tuya.dp_enum(104, {
    name = "over_current_setting",
    emit = emit.toqcb2OverCurrentSetting(),
    converter = converter.lookup_from_to(CLOSED_ALARM_TRIP_SETTING),
  }),
  tuya.dp_enum(105, {
    name = "over_power_setting",
    emit = emit.toqcb2OverPowerSetting(),
    converter = converter.lookup_from_to(CLOSED_ALARM_TRIP_SETTING),
  }),
  tuya.dp_enum(107, {
    name = "temperature_setting",
    emit = emit.toqcb2TemperatureSetting(),
    converter = converter.lookup_from_to(CLOSED_ALARM_TRIP_SETTING),
  }),
  tuya.dp_enum(110, {
    name = "last_event",
    read_only = true,
    emit = emit.toqcb2LastEvent(),
    converter = converter.from_only(converter.lookup_value({
      [0] = "normal",
      [1] = "trip_over_current",
      [2] = "trip_over_power",
      [3] = "trip_over_temperature",
      [4] = "trip_voltage_1",
      [5] = "trip_voltage_2",
      [6] = "alarm_over_current",
      [7] = "alarm_over_power",
      [8] = "alarm_over_temperature",
      [9] = "alarm_voltage_1",
      [10] = "alarm_voltage_2",
      [11] = "remote_on",
      [12] = "remote_off",
      [13] = "manual_on",
      [14] = "manual_off",
      [15] = "value_15",
      [16] = "value_16",
      [17] = "factory_reset",
    })),
  }),
  tuya.dp_on_off(112, {
    name = "clear_fault",
    emit = emit.clearFaultBreaker(),
    converter = converter.lookup_from_to({ on = true, off = false }),
  }),
  tuya.dp_on_off(113, {
    name = "factory_reset",
    emit = emit.toqcb2FactoryReset(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_numeric(114, { name = "current_threshold", emit = emit.currentThresholdToqcb2A63() }),
  tuya.dp_numeric(115, { name = "over_voltage_threshold", emit = emit.toqcb2OverVoltageThreshold() }),
  tuya.dp_numeric(116, { name = "under_voltage_threshold", emit = emit.toqcb2UnderVoltageThreshold() }),
  tuya.dp_temperature(118, {
    name = "temperature_threshold",
    scale = 10,
    emit = emit.toqcb2TemperatureThreshold(),
  }),
  tuya.dp_numeric(119, { name = "over_power_threshold", emit = emit.toqcb2OverPowerThreshold() }),
  tuya.dp_temperature(131, {
    name = "temperature",
    scale = 10,
    read_only = true,
    emit = emit.temperature(),
  }),
}

register_device_definition(din_rail_model_toqcb2_80, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_q22avxbv",
  "_TZE204_q22avxbv",
  "_TZE204_mrffaamu",
  "_TZE204_tzreobvu",
  "_TZE284_mrffaamu",
  "_TZE284_tzreobvu",
  "_TZE284_9xstqowh",
  "_TZE284_kv1nvirl",
}))

register_device_definition(din_rail_model_toqcb2_80, {
  device_helpers.create_fingerprint("Tongou", "TOQCB2-80-2P"),
})

-- ══════════════════════════════════════════════════════════════
-- 1-10f. power_meter_model_to_q_sa1: Tongou clamp energy meter
-- Z2M: TO-Q-SA1 / TOSA1-01WXJAT2A
-- ══════════════════════════════════════════════════════════════
local power_meter_model_to_q_sa1 = {
  profile = "meters-power-energy-voltage-current-toqsa1",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_phase_variant2(6, {
    emit = emit_metric_bundle({
      voltage = true,
      current = true,
      power = true,
    }),
  }),
  tuya.dp_numeric(13, { name = "test1" }),                                 -- 프로파일 미포함
  tuya.dp_ac_frequency(32, {
    name = "ac_frequency",
    read_only = true,
    emit = emit.toqsa1AcFrequency(),
  }),
  tuya.dp_power_factor(50, {
    name = "power_factor",
    read_only = true,
    emit = emit.toqsa1PowerFactor(),
  }),
  tuya.dp_enum(102, {
    name = "over_voltage_setting",
    emit = emit.toqsa1OverVoltageSetting(),
    converter = converter.lookup_from_to(IGNORE_ALARM_SETTING),
  }),
  tuya.dp_enum(103, {
    name = "under_voltage_setting",
    emit = emit.toqsa1UnderVoltageSetting(),
    converter = converter.lookup_from_to(IGNORE_ALARM_SETTING),
  }),
  tuya.dp_enum(104, {
    name = "over_current_setting",
    emit = emit.toqsa1OverCurrentSetting(),
    converter = converter.lookup_from_to(IGNORE_ALARM_SETTING),
  }),
  tuya.dp_enum(105, {
    name = "over_power_setting",
    emit = emit.toqsa1OverPowerSetting(),
    converter = converter.lookup_from_to(IGNORE_ALARM_SETTING),
  }),
  tuya.dp_enum(107, {
    name = "temperature_setting",
    emit = emit.toqsa1TemperatureSetting(),
    converter = converter.lookup_from_to(IGNORE_ALARM_SETTING),
  }),
  -- Z2M puts the last-event enum on DP110, not DP113.
  tuya.dp_enum(110, {
    name = "event",
    read_only = true,
    emit = emit.toqsa1Event(),
    converter = converter.from_only(converter.lookup_value(BREAKER_EVENT_LOOKUP)),
  }),
  tuya.dp_numeric(114, { name = "over_current_threshold", emit = emit.toqsa1OverCurrentThreshold() }),
  tuya.dp_numeric(115, { name = "over_voltage_threshold", emit = emit.toqsa1OverVoltageThreshold() }),
  tuya.dp_numeric(116, { name = "under_voltage_threshold", emit = emit.toqsa1UnderVoltageThreshold() }),
  tuya.dp_temperature(118, {
    name = "temperature_threshold",
    scale = 10,
    emit = emit.toqsa1TemperatureThreshold(),
  }),
  tuya.dp_numeric(119, { name = "over_power_threshold", emit = emit.toqsa1OverPowerThreshold() }),
  tuya.dp_numeric(125, { name = "forward_electricity" }),                  -- 프로파일 미포함
  tuya.dp_temperature(131, {
    name = "temperature",
    scale = 10,
    read_only = true,
    emit = emit.temperature(),
  }),
}

register_device_definition(power_meter_model_to_q_sa1, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_4hdbt6rn",
  "_TZE284_pglpvdar",
}))

register_device_definition(power_meter_model_to_q_sa1, {
  device_helpers.create_fingerprint("Tongou", "TOSA1-01WXJAT2A"),
})

-- ══════════════════════════════════════════════════════════════
-- 1-11. power_meter_model_pj_mgw1203: 단상 클램프 미터
-- Z2M: PJ-MGW1203 / PJ-1203-W
-- ══════════════════════════════════════════════════════════════
local power_meter_model_pj_mgw1203 = {
  profile = "meters-power-energy-voltage-current",
  tuya.dp_current(18, { emit = emit.current(), scale = 1000 }),
  tuya.dp_power(19, { emit = emit.power(), scale = 10 }),
  tuya.dp_voltage(20, { emit = emit.voltage(), scale = 10 }),
  tuya.dp_energy(101, { emit = emit.energy(), scale = 1000 }),
}

register_device_definition(power_meter_model_pj_mgw1203, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_cjbofhxw",
  "_TZE284_cjbofhxw",
}))

register_device_definition(power_meter_model_pj_mgw1203, {
  device_helpers.create_fingerprint("Tuya", "PJ-1203-W"),
})

-- ══════════════════════════════════════════════════════════════
-- 1-12. power_meter_model_sdm02v1: 2P+N 에너지 모니터
-- Z2M: SDM02V1
-- ══════════════════════════════════════════════════════════════
local power_meter_model_sdm02v1 = {
  profile = "meters-power-energy-2phase-sdm02v1",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_energy(23, { name = "produced_energy", scale = 100 }),            -- 프로파일 미포함
  tuya.dp_power(29, { emit = emit.power(), scale = 1 }),
  tuya.dp_ac_frequency(32, {}),                                            -- 프로파일 미포함
  tuya.dp_power_factor(50, {}),                                            -- 프로파일 미포함
  tuya.dp_numeric(102, { name = "update_frequency", emit = emit.updateFrequencySdm02v1Seconds3600() }),
  tuya.dp_voltage(103, { name = "voltage_l1", component = "l1", emit = emit.voltage() }),
  tuya.dp_current(104, { name = "current_l1", component = "l1", emit = emit.current() }),
  tuya.dp_power(105, { name = "power_l1", component = "l1", emit = emit.power(), scale = 1 }),
  tuya.dp_power_factor(108, { name = "power_factor_l1" }),                 -- 프로파일 미포함
  tuya.dp_energy(109, { name = "energy_l1", component = "l1", emit = emit.energy(), scale = 100 }),
  tuya.dp_energy(110, { name = "energy_produced_l1", scale = 100 }),       -- 프로파일 미포함
  tuya.dp_voltage(112, { name = "voltage_l2", component = "l2", emit = emit.voltage() }),
  tuya.dp_current(113, { name = "current_l2", component = "l2", emit = emit.current() }),
  tuya.dp_power(114, { name = "power_l2", component = "l2", emit = emit.power(), scale = 1 }),
  tuya.dp_power_factor(117, { name = "power_factor_l2" }),                 -- 프로파일 미포함
  tuya.dp_energy(118, { name = "energy_l2", component = "l2", emit = emit.energy(), scale = 100 }),
  tuya.dp_energy(119, { name = "energy_produced_l2", scale = 100 }),       -- 프로파일 미포함
}

register_device_definition(power_meter_model_sdm02v1, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_78ioiaml",
  "_TZE284_78ioiaml",
  "_TZE200_78ioiaml",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-12a. power_meter_model_sdm02v1gt: 2P+N 에너지 모니터 (grid-tie)
-- Z2M: SDM02V1-GT (tuya.ts:16933)
-- ══════════════════════════════════════════════════════════════
-- The x8diwkqb exacts are a different generation from SDM02V1: they carry the
-- per-line voltage, current and power in DP6/DP7 phase-variant-2 frames instead
-- of DP103..DP114, put line energy on DP53/DP57 and produced energy on
-- DP54/DP58, and add the DP101 device locating command.  Sharing the SDM02V1
-- definition meant reading datapoints this model never reports.
local power_meter_model_sdm02v1gt = {
  profile = "meters-energy-2phase-sdm02v1gt",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_energy(23, {
    name = "produced_energy",
    scale = 100,
    read_only = true,
    emit = emit.sdm02v1gtProducedEnergy(),
  }),
  tuya.dp_phase_variant2(6, {
    phase = "l1",
    component = "l1",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_phase_variant2(7, {
    phase = "l2",
    component = "l2",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_power(29, { emit = emit.power() }),
  tuya.dp_ac_frequency(32, {
    name = "ac_frequency",
    read_only = true,
    emit = emit.sdm02v1gtAcFrequency(),
  }),
  tuya.dp_power_factor(50, {
    name = "power_factor",
    read_only = true,
    emit = emit.sdm02v1gtPowerFactor(),
  }),
  tuya.dp_energy(53, { name = "energy_l1", scale = 100, component = "l1", emit = emit.energy() }),
  tuya.dp_energy(54, { name = "energy_produced_l1", scale = 100 }),         -- 프로파일 미포함
  tuya.dp_energy(57, { name = "energy_l2", scale = 100, component = "l2", emit = emit.energy() }),
  tuya.dp_energy(58, { name = "energy_produced_l2", scale = 100 }),         -- 프로파일 미포함
  tuya.dp_on_off(101, {
    name = "device_locating",
    emit = emit.sdm02v1gtDeviceLocating(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_numeric(102, { name = "update_frequency", emit = emit.sdm02v1gtUpdateFrequency() }),
  tuya.dp_power_factor(108, { name = "power_factor_l1" }),                  -- 프로파일 미포함
  tuya.dp_power_factor(117, { name = "power_factor_l2" }),                  -- 프로파일 미포함
}

register_device_definition(power_meter_model_sdm02v1gt, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_x8diwkqb",
  "_TZE204_x8diwkqb",
  "_TZE284_x8diwkqb",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-13. power_meter_model_sdm01v15: 3P+N 에너지 모니터 변형
-- Z2M: SDM01V1.5
-- ══════════════════════════════════════════════════════════════
-- Z2M SDM01V1.5 (tuya.ts:16645) has the same datapoint map as SPM02V3: totals
-- on DP1/23/29/32/50, DP102 report interval and three phase blocks nine
-- datapoints apart.  Phase B (DP112..DP119) was missing entirely and phase C
-- stopped at DP123, so two thirds of the per-phase data never reached the app.
local power_meter_model_sdm01v15 = {
  profile = "meters-energy-3phase-sdm01v15",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_energy(23, {
    name = "produced_energy",
    scale = 100,
    read_only = true,
    emit = emit.sdm01v15ProducedEnergy(),
  }),
  tuya.dp_power(29, { emit = emit.power(), scale = 1 }),
  tuya.dp_ac_frequency(32, {
    name = "ac_frequency",
    read_only = true,
    emit = emit.sdm01v15AcFrequency(),
  }),
  tuya.dp_power_factor(50, {
    name = "power_factor",
    read_only = true,
    emit = emit.sdm01v15PowerFactor(),
  }),
  tuya.dp_numeric(102, { name = "update_frequency", emit = emit.sdm01v15UpdateFrequency() }),
  tuya.dp_voltage(103, { name = "voltage_a", component = "l1", emit = emit.voltage(), scale = 10 }),
  tuya.dp_current(104, { name = "current_a", component = "l1", emit = emit.current(), scale = 1000 }),
  tuya.dp_power(105, { name = "power_a", component = "l1", emit = emit.power(), scale = 1 }),
  tuya.dp_power_factor(108, { name = "power_factor_a" }),                  -- 프로파일 미포함
  tuya.dp_energy(109, { name = "energy_a", scale = 100, component = "l1", emit = emit.energy() }),
  tuya.dp_energy(110, { name = "energy_produced_a", scale = 100 }),        -- 프로파일 미포함
  tuya.dp_voltage(112, { name = "voltage_b", component = "l2", emit = emit.voltage(), scale = 10 }),
  tuya.dp_current(113, { name = "current_b", component = "l2", emit = emit.current(), scale = 1000 }),
  tuya.dp_power(114, { name = "power_b", component = "l2", emit = emit.power(), scale = 1 }),
  tuya.dp_power_factor(117, { name = "power_factor_b" }),                  -- 프로파일 미포함
  tuya.dp_energy(118, { name = "energy_b", scale = 100, component = "l2", emit = emit.energy() }),
  tuya.dp_energy(119, { name = "energy_produced_b", scale = 100 }),        -- 프로파일 미포함
  tuya.dp_voltage(121, { name = "voltage_c", component = "l3", emit = emit.voltage(), scale = 10 }),
  tuya.dp_current(122, { name = "current_c", component = "l3", emit = emit.current(), scale = 1000 }),
  tuya.dp_power(123, { name = "power_c", component = "l3", emit = emit.power(), scale = 1 }),
  tuya.dp_power_factor(126, { name = "power_factor_c" }),                  -- 프로파일 미포함
  tuya.dp_energy(127, { name = "energy_c", scale = 100, component = "l3", emit = emit.energy() }),
  tuya.dp_energy(128, { name = "energy_produced_c", scale = 100 }),        -- 프로파일 미포함
}

register_device_definition(power_meter_model_sdm01v15, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_gomuk3dc",
  "_TZE284_gomuk3dc",
  "_TZE200_gomuk3dc",
}))

return device_definitions




