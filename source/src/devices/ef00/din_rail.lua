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

-- ══════════════════════════════════════════════════════════════
-- 1-1. din_rail_model_ts0601_din_1: 단일 스위치 + 계측
-- Z2M: TS0601_din_1 / ZHA: TS0601 power meter 계열
-- ══════════════════════════════════════════════════════════════
local din_rail_model_ts0601_din_1 = {
  profile = "din-rail-switch-power-energy-voltage-current-din1",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_phase_variant1(6, {}),
  tuya.dp_on_off(16, { name = "switch", emit = emit.switch() }),
  tuya.dp_numeric(101, { name = "total_energy", scale = 100 }),          -- 프로파일 미포함
  tuya.dp_energy(102, { name = "produced_energy", scale = 100, emit = emit.producedEnergyDin() }),
  tuya.dp_power(103, { emit = emit.power() }),
  tuya.dp_ac_frequency(105, { scale = 100 }),                            -- 프로파일 미포함
  tuya.dp_numeric(109, { name = "energy_reactive", scale = 100 }),       -- 프로파일 미포함
  tuya.dp_numeric(110, { name = "power_reactive", emit = emit.reactivePowerDin1() }),
  tuya.dp_power_factor(111, {}),                                         -- 프로파일 미포함
  tuya.dp_raw(9, { name = "fault" }),                                    -- 프로파일 미포함
  tuya.dp_raw(17, { name = "alarm_set_1" }),                             -- 프로파일 미포함
  tuya.dp_raw(18, { name = "alarm_set_2" }),                             -- 프로파일 미포함
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
local din_rail_model_ts0601_din_2 = {
  profile = "din-rail-switch-power-energy-voltage-current-din2",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_numeric(3, { name = "monthly_energy" }),                         -- 프로파일 미포함
  tuya.dp_numeric(4, { name = "daily_energy" }),                           -- 프로파일 미포함
  tuya.dp_phase_variant2(6, {}),
  tuya.dp_enum(10, { name = "fault" }),                                    -- 프로파일 미포함
  tuya.dp_raw(11, { name = "frozen" }),                                    -- 프로파일 미포함
  tuya.dp_on_off(16, { name = "switch", emit = emit.switch() }),
  tuya.dp_threshold(17, {}),                                               -- 프로파일 미포함
  tuya.dp_string(18, { name = "meter_id" }),                               -- 프로파일 미포함
  tuya.dp_on_off(20, {
    name = "clear_fault",
    emit = emit.clearFaultDin2(),
    converter = converter.lookup_from_to({ on = true, off = false }),
  }),
  tuya.dp_numeric(21, { name = "forward_energy_t1" }),                     -- 프로파일 미포함
  tuya.dp_numeric(22, { name = "forward_energy_t2" }),                     -- 프로파일 미포함
  tuya.dp_numeric(23, { name = "forward_energy_t3" }),                     -- 프로파일 미포함
  tuya.dp_numeric(24, { name = "forward_energy_t4" }),                     -- 프로파일 미포함
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
local din_rail_model_ts0601_din_3 = {
  profile = "din-rail-switch-power-energy-voltage-current-din3",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_energy(2, { name = "produced_energy", scale = 100, emit = emit.producedEnergyDin() }),
  tuya.dp_numeric(3, { name = "monthly_energy" }),                           -- 프로파일 미포함
  tuya.dp_numeric(4, { name = "daily_energy" }),                             -- 프로파일 미포함
  tuya.dp_phase_variant2(6, {}),
  tuya.dp_enum(10, { name = "fault" }),                                      -- 프로파일 미포함
  tuya.dp_raw(11, { name = "frozen" }),                                      -- 프로파일 미포함
  tuya.dp_on_off(16, { name = "switch", emit = emit.switch() }),
  tuya.dp_threshold(17, {}),                                                 -- 프로파일 미포함
  tuya.dp_string(18, { name = "meter_id" }),                                 -- 프로파일 미포함
  tuya.dp_on_off(20, {
    name = "clear_fault",
    emit = emit.clearFaultDin3(),
    converter = converter.lookup_from_to({ on = true, off = false }),
  }),
  tuya.dp_numeric(21, { name = "forward_energy_t1" }),                       -- 프로파일 미포함
  tuya.dp_numeric(22, { name = "forward_energy_t2" }),                       -- 프로파일 미포함
  tuya.dp_numeric(23, { name = "forward_energy_t3" }),                       -- 프로파일 미포함
  tuya.dp_numeric(24, { name = "forward_energy_t4" }),                       -- 프로파일 미포함
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
local din_rail_model_ts0601_din_4 = {
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_phase_variant2(6, {}),
  tuya.dp_raw(9, { name = "fault" }),                                        -- 프로파일 미포함
  tuya.dp_numeric(15, { name = "leakage" }),                                 -- 프로파일 미포함
  tuya.dp_on_off(16, { name = "switch", emit = emit.switch() }),
  tuya.dp_temperature(103, { name = "temperature", scale = 1 }),             -- 프로파일 미포함
}

register_device_definition(din_rail_model_ts0601_din_4, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_abatw3kj",
  "_TZE204_4bjixefp",
  "_TZE204_fhvdgeuh",
}))

register_device_definition(din_rail_model_ts0601_din_4, {
  device_helpers.create_fingerprint("RTX", "TS0601_RTX_DIN"),
})

-- ══════════════════════════════════════════════════════════════
-- 1-6. power_meter_model_sdm01: 3상 에너지 모니터
-- Z2M: SDM01
-- ══════════════════════════════════════════════════════════════
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
  "_TZE200_s4sa1mcx",
  "_TZE204_ugekduaj",
  "_TZE200_ugekduaj",
  "_TZE204_loejka0i",
  "_TZE284_loejka0i",
  "_TZE204_ves1ycwx",
  "_TZE284_ves1ycwx",
  "_TZE200_ves1ycwx",
  "_TZE204_v9hkz2yn",
  "_TZE284_v9hkz2yn",
  "_TZE200_v9hkz2yn",
  "_TZE204_ny94onlb",
  "_TZE200_ny94onlb",
  "_TZE284_ny94onlb",
  "_TZE204_wjk6rurm",
  "_TZE284_wjk6rurm",
  "_TZE200_wjk6rurm",
  "_TZE200_dikb3dp6",
  "_TZE204_dikb3dp6",
  "_TZE284_dikb3dp6",
  "_TZE204_s4sa1mcx",
  "_TZE284_s4sa1mcx",
}))

register_device_definition(power_meter_model_sdm01, {
  device_helpers.create_fingerprint("Nous", "D4Z"),
})

-- ══════════════════════════════════════════════════════════════
-- 1-7. power_meter_model_ts0601_3_phase_clamp_meter: 3상 클램프 계량기
-- Z2M: TS0601_3_phase_clamp_meter
-- ══════════════════════════════════════════════════════════════
local power_meter_model_ts0601_3_phase_clamp_meter = {
  profile = "meters-power-energy-voltage-current-clamp3phase",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_power(9, { emit = emit.power() }),
  tuya.dp_energy(101, { name = "energy_a", scale = 1000 }),                 -- 프로파일 미포함
  tuya.dp_power_factor(102, { name = "power_factor", component = "l1", emit = emit.powerFactorClamp3PhasePercent() }),
  tuya.dp_energy(111, { name = "energy_b", scale = 1000 }),                 -- 프로파일 미포함
  tuya.dp_power_factor(112, { name = "power_factor", component = "l2", emit = emit.powerFactorClamp3PhasePercent() }),
  tuya.dp_energy(121, { name = "energy_c", scale = 1000 }),                 -- 프로파일 미포함
  tuya.dp_power_factor(122, { name = "power_factor", component = "l3", emit = emit.powerFactorClamp3PhasePercent() }),
  tuya.dp_numeric(132, { name = "ac_frequency", emit = emit.acFrequencyClamp3Phase() }),
  tuya.dp_temperature(133, { name = "temperature", scale = 10 }),           -- 프로파일 미포함
  tuya.dp_current(131, { emit = emit.current() }),
  tuya.dp_phase_variant2(6, { phase = "a" }),                               -- 프로파일 미포함
  tuya.dp_phase_variant2(7, { phase = "b" }),                               -- 프로파일 미포함
  tuya.dp_phase_variant2(8, { phase = "c" }),                               -- 프로파일 미포함
  tuya.dp_numeric(134, { name = "device_status" }),                         -- 프로파일 미포함
  tuya.dp_ac_frequency(135, { name = "ac_frequency_high_precision" }),      -- 프로파일 미포함
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
local power_meter_model_ts0601_3_phase_clamp_meter_relay = {
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_energy(2, { name = "produced_energy", scale = 100 }),             -- 프로파일 미포함
  tuya.dp_on_off(16, { name = "switch", emit = emit.switch() }),
  tuya.dp_power(9, { emit = emit.power() }),
  tuya.dp_phase_variant2(6, { phase = "a" }),                               -- 프로파일 미포함
  tuya.dp_phase_variant2(7, { phase = "b" }),                               -- 프로파일 미포함
  tuya.dp_phase_variant2(8, { phase = "c" }),                               -- 프로파일 미포함
}

register_device_definition(power_meter_model_ts0601_3_phase_clamp_meter_relay, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_x8fp01wi",
  "_TZE204_x8fp01wi",
}))

register_device_definition(power_meter_model_ts0601_3_phase_clamp_meter_relay, {
  device_helpers.create_fingerprint("Wenzhou Taiye Electric", "TAC7361C BI"),
})

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
  "_TZE200_bcusnqt8",
  "_TZE200_qhlxve78",
  "_TZE284_qhlxve78",
  "_TZE204_qhlxve78",
  "_TZE200_iwn0gpzz",
  "_TZE204_iwn0gpzz",
  "_TZE284_iwn0gpzz",
  "_TZE204_d2zfgtij",
  "_TZE284_d2zfgtij",
  "_TZE200_d2zfgtij",
}))

-- PC311-Z-TY: bidirectional 2-channel clamp meter
local power_meter_model_pc311 = {
  profile = "meters-power-energy-voltage-current-pc311",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_energy(2, { name = "energy_produced", scale = 100 }),            -- profile 미포함
  tuya.dp_power(9, { emit = emit.power() }),
  tuya.dp_current(105, { emit = emit.current(), scale = 1000 }),
  tuya.dp_voltage(106, { emit = emit.voltage(), scale = 10 }),
  tuya.dp_current(107, { name = "current_a", scale = 1000 }),              -- profile 미포함
  tuya.dp_power(108, { name = "power_a" }),                                -- profile 미포함
  tuya.dp_power_factor(109, { name = "power_factor", component = "ct1", emit = emit.powerFactorPc311Percent() }),
  tuya.dp_current(110, { name = "current_b", scale = 1000 }),              -- profile 미포함
  tuya.dp_power(111, { name = "power_b" }),                                -- profile 미포함
  tuya.dp_power_factor(112, { name = "power_factor", component = "ct2", emit = emit.powerFactorPc311Percent() }),
  tuya.dp_ac_frequency(113, { name = "ac_frequency", emit = emit.acFrequencyPc311() }),
}

register_device_definition(power_meter_model_pc311, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_rks0sgb7",
}))

-- 2CT: two-channel bidirectional meter
local power_meter_model_2ct = {
  profile = "meters-power-energy-voltage-current-2ct",
  tuya.dp_power(19, { emit = emit.power(), scale = 10 }),
  tuya.dp_voltage(20, { emit = emit.voltage(), scale = 10 }),
  tuya.dp_current(101, { name = "current_a", scale = 1000 }),              -- profile 미포함
  tuya.dp_current(102, { name = "current_b", scale = 1000 }),              -- profile 미포함
  tuya.dp_power(103, { name = "power_a", scale = 10 }),                    -- profile 미포함
  tuya.dp_power(104, { name = "power_b", scale = 10 }),                    -- profile 미포함
  tuya.dp_ac_frequency(105, { name = "ac_frequency", scale = 100, emit = emit.acFrequency2ct() }),
  tuya.dp_energy(115, { emit = emit.energy(), scale = 100 }),
  tuya.dp_energy(117, { name = "energy_b", scale = 100 }),                 -- profile 미포함
  tuya.dp_power_factor(120, { name = "power_factor", component = "ct1", emit = emit.powerFactor2ctPercent() }),
  tuya.dp_power_factor(121, { name = "power_factor", component = "ct2", emit = emit.powerFactor2ctPercent() }),
  tuya.dp_numeric(122, { name = "update_frequency", emit = emit.updateFrequency2ctSeconds60() }),
}

register_device_definition(power_meter_model_2ct, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_dhotiauw",
}))

-- PJ-1203A: compact bidirectional clamp meter
local power_meter_model_pj1203a = {
  profile = "meters-power-energy-voltage-current-pj1203a",
  tuya.dp_ac_frequency(111, { name = "ac_frequency" }),                   -- profile 미포함
  tuya.dp_voltage(112, { emit = emit.voltage() }),
  tuya.dp_numeric(129, { name = "update_frequency", emit = emit.updateFrequencyPj1203aSeconds60() }),
}

register_device_definition(power_meter_model_pj1203a, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_81yrt3lo",
  "_TZE284_81yrt3lo",
  "_TZE28C1000000_81yrt3lo",
}))

-- SMKG-2KNL-SD smart leakage protector
local din_rail_model_leakage_protector = {
  profile = "din-rail-switch-power-energy-voltage-current-leakage-protector",
  query_on_configure = true,
  named_datapoints = true,
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main", emit = emit.switch() }),
    tuya.dp_energy(17, { emit = emit.energy() }),
    tuya.dp_current(18, { emit = emit.current() }),
    tuya.dp_power(19, { emit = emit.power() }),
    tuya.dp_voltage(20, { emit = emit.voltage() }),
    tuya.dp_raw(9, { name = "fault_code" }),                                -- profile 미포함
    tuya.dp_numeric(41, { name = "leakage_threshold", emit = emit.leakageThresholdProtector100ma() }),
    tuya.dp_numeric(42, { name = "over_voltage_threshold" }),                -- profile 미포함
    tuya.dp_numeric(43, { name = "under_voltage_threshold" }),               -- profile 미포함
    tuya.dp_numeric(44, { name = "over_current_threshold" }),                -- profile 미포함
    tuya.dp_numeric(45, { name = "temp_threshold" }),                        -- profile 미포함
    tuya.dp_temperature(47, { name = "temperature" }),                       -- profile 미포함
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
  profile = "meters-power-energy-atms10013z3",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_phase_variant2(6, { phase = "a" }),                               -- 프로파일 미포함
  tuya.dp_phase_variant2(7, { phase = "b" }),                               -- 프로파일 미포함
  tuya.dp_phase_variant2(8, { phase = "c" }),                               -- 프로파일 미포함
  tuya.dp_energy(23, { name = "produced_energy", scale = 100 }),            -- 프로파일 미포함
  tuya.dp_energy(24, { name = "total_energy", scale = 100 }),               -- 프로파일 미포함
  tuya.dp_power(29, { emit = emit.power(), scale = 1 }),
  tuya.dp_numeric(30, { name = "power_reactive", emit = emit.reactivePowerAtms10013z3() }),
  tuya.dp_power_factor(50, {}),                                             -- 프로파일 미포함
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
    tuya.dp_numeric(9, { name = "countdown_timer" }),                      -- 프로파일 미포함
    tuya.dp_enum(26, { name = "fault" }),                                  -- 프로파일 미포함
    tuya.dp_power_on_behavior(27, {}),                                      -- 프로파일 미포함
    tuya.dp_child_lock(29, { name = "child_lock" }),                       -- 프로파일 미포함
    tuya.dp_raw(101, { name = "voltage", converter = converter.raw_uint_be(10, { length = 2 }), emit = emit_voltage }),
    tuya.dp_raw(102, { name = "current", converter = converter.raw_uint_be(1000, { start = 2, length = 2 }), emit = emit_current }),
    tuya.dp_raw(103, { name = "power", converter = converter.raw_uint_be(10, { start = 2, length = 2 }), emit = emit_power }),
    tuya.dp_temperature(105, { name = "temperature", scale = 1 }),          -- 프로파일 미포함
    tuya.dp_raw(110, { name = "voltage_threshold" }),                      -- 프로파일 미포함
    tuya.dp_numeric(111, { name = "current_threshold", emit = emit.currentThresholdRcbo63a() }),
    tuya.dp_raw(112, { name = "temperature_threshold" }),                  -- 프로파일 미포함
    tuya.dp_energy(113, { emit = emit.energy(), scale = 100 }),
    tuya.dp_string(114, { name = "meter_number" }),                        -- 프로파일 미포함
    tuya.dp_on_off(115, { name = "clear_energy", emit = emit.clearEnergyRcbo(), converter = converter.lookup_from_to({ on = true, off = false }) }),
    tuya.dp_binary(116, { name = "trip_test", emit = emit.tripTestRcboTripClear(), converter = converter.lookup_from_to({ trip = true, clear = false }) }),
    tuya.dp_raw(118, { name = "voltage_rms", converter = converter.raw_uint_be(10, { length = 2 }) }), -- 프로파일 미포함
    tuya.dp_raw(119, { name = "current_average", converter = converter.raw_uint_be(1000, { start = 2, length = 2 }) }), -- 프로파일 미포함
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
  tuya.dp_ac_frequency(32, {}),                                            -- 프로파일 미포함
  tuya.dp_power_factor(50, {}),                                            -- 프로파일 미포함
  tuya.dp_enum(102, { name = "over_voltage_setting" }),                    -- 프로파일 미포함
  tuya.dp_enum(103, { name = "under_voltage_setting" }),                   -- 프로파일 미포함
  tuya.dp_enum(104, { name = "over_current_setting" }),                    -- 프로파일 미포함
  tuya.dp_enum(105, { name = "over_power_setting" }),                      -- 프로파일 미포함
  tuya.dp_enum(107, { name = "temperature_setting" }),                     -- 프로파일 미포함
  tuya.dp_enum(108, { name = "leakage_setting" }),                         -- 프로파일 미포함
  tuya.dp_enum(110, { name = "event" }),                                   -- 프로파일 미포함
  tuya.dp_numeric(114, { name = "over_current_threshold" }),               -- 프로파일 미포함
  tuya.dp_numeric(115, { name = "over_voltage_threshold" }),               -- 프로파일 미포함
  tuya.dp_numeric(116, { name = "under_voltage_threshold" }),              -- 프로파일 미포함
  tuya.dp_temperature(118, { name = "temperature_threshold", scale = 10 }), -- 프로파일 미포함
  tuya.dp_numeric(119, { name = "over_power_threshold" }),                 -- 프로파일 미포함
  tuya.dp_numeric(125, { name = "test5" }),                                -- 프로파일 미포함
  tuya.dp_temperature(131, { name = "temperature", scale = 10 }),          -- 프로파일 미포함
}

register_device_definition(din_rail_model_to_q_sys_jzt, {
  device_helpers.create_fingerprint("_TZE284_6ocnqlhn", "TS0601"),
})

-- ══════════════════════════════════════════════════════════════
-- 1-10aa. din_rail_model_towsmr1: Tongou TOWSMR1 RCBO
-- Z2M: TOWSMR1
-- ══════════════════════════════════════════════════════════════
register_device_definition(din_rail_model_to_q_sys_jzt, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_kobbcyum",
  "_TZE284_kobbcyum",
  "_TZE284_hecsejsb",
  "_TZE284_432zhuwe",
  "_TZE204_432zhuwe",
  "_TZE284_s5vuaadg",
  "_TZE284_tuhfx7tf",
  "_TZE204_tuhfx7tf",
}))

register_device_definition(din_rail_model_to_q_sys_jzt, {
  device_helpers.create_fingerprint("Tongou", "TOWSMR1-40A-AC"),
  device_helpers.create_fingerprint("Tongou", "TOWSMR1-40A-A"),
  device_helpers.create_fingerprint("Tongou", "TOWSMR1-20A-AC"),
})

-- ══════════════════════════════════════════════════════════════
-- 1-10b. din_rail_model_zbn_jt_63: 전력 모니터링 DIN 스위치
-- Z2M: ZBN-JT-63
-- ══════════════════════════════════════════════════════════════
local din_rail_model_zbn_jt_63 = {
  profile = "din-rail-switch-power-energy-voltage-current",
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
  tuya.dp_enum(10, { name = "fault" }),                                    -- 프로파일 미포함
  tuya.dp_on_off(16, { name = "switch", emit = emit.switch() }),
  tuya.dp_raw(18, { name = "meter_id" }),                                  -- 프로파일 미포함
  tuya.dp_power_outage_memory(23, {}),                                     -- 프로파일 미포함
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
local din_rail_model_rmdzb_1pnl63 = {
  profile = "din-rail-switch-power-energy-voltage-current",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_phase_variant2(6, {
    emit = emit_metric_bundle({
      voltage = true,
      current = true,
      power = true,
    }),
  }),
  tuya.dp_enum(9, { name = "fault" }),                                    -- 프로파일 미포함
  tuya.dp_on_off(16, { name = "switch", emit = emit.switch() }),
  tuya.dp_threshold(17, {}),                                               -- 프로파일 미포함
  tuya.dp_threshold(18, {}),                                               -- 프로파일 미포함
  tuya.dp_temperature(103, { name = "temperature", scale = 1 }),           -- 프로파일 미포함
}

register_device_definition(din_rail_model_rmdzb_1pnl63, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_wbhaespm",
  "_TZE204_m64smti7",
  "_TZE204_wbhaespm",
  "_TZE284_wbhaespm",
}))

register_device_definition(din_rail_model_rmdzb_1pnl63, {
  device_helpers.create_fingerprint("TNCE", "RMDZB-1PNL63"),
  device_helpers.create_fingerprint("SUTON", "STB3L-125/ZJ"),
})

-- ══════════════════════════════════════════════════════════════
-- 1-10e. din_rail_model_toqcb2_80: Tongou 3-phase smart circuit breaker
-- Z2M: TOQCB2-80
-- ══════════════════════════════════════════════════════════════
local din_rail_model_toqcb2_80 = {
  profile = "din-rail-switch-power-energy-voltage-current-toqcb2",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_phase_variant2(6, {
    emit = emit_metric_bundle({
      voltage = true,
      current = true,
      power = true,
    }),
  }),
  tuya.dp_phase_variant2(7, { phase = "b" }),                             -- 프로파일 미포함
  tuya.dp_phase_variant2(8, { phase = "c" }),                             -- 프로파일 미포함
  tuya.dp_on_off(16, { name = "switch", emit = emit.switch() }),
  tuya.dp_on_off(112, {
    name = "clear_fault",
    emit = emit.clearFaultBreaker(),
    converter = converter.lookup_from_to({ on = true, off = false }),
  }),
  tuya.dp_numeric(113, { name = "factory_reset" }),                       -- 프로파일 미포함
  tuya.dp_numeric(114, { name = "current_threshold", emit = emit.currentThresholdToqcb2A63() }),
  tuya.dp_numeric(115, { name = "over_voltage_threshold" }),              -- 프로파일 미포함
  tuya.dp_numeric(116, { name = "under_voltage_threshold" }),             -- 프로파일 미포함
  tuya.dp_temperature(118, { name = "temperature_threshold", scale = 10 }), -- 프로파일 미포함
  tuya.dp_numeric(119, { name = "over_power_threshold" }),                -- 프로파일 미포함
  tuya.dp_temperature(131, { name = "temperature", scale = 10 }),         -- 프로파일 미포함
}

register_device_definition(din_rail_model_toqcb2_80, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_q22avxbv",
  "_TZE204_q22avxbv",
  "_TZE204_mrffaamu",
  "_TZE204_tzreobvu",
  "_TZE284_mrffaamu",
  "_TZE284_tzreobvu",
  "_TZE284_9xstqowh",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-10f. power_meter_model_to_q_sa1: Tongou clamp energy meter
-- Z2M: TO-Q-SA1 / TOSA1-01WXJAT2A
-- ══════════════════════════════════════════════════════════════
local power_meter_model_to_q_sa1 = {
  profile = "meters-power-energy-voltage-current",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_phase_variant2(6, {
    emit = emit_metric_bundle({
      voltage = true,
      current = true,
      power = true,
    }),
  }),
  tuya.dp_ac_frequency(32, {}),                                            -- 프로파일 미포함
  tuya.dp_power_factor(50, {}),                                            -- 프로파일 미포함
  tuya.dp_enum(113, { name = "event" }),                                   -- 프로파일 미포함
  tuya.dp_numeric(114, { name = "over_current_threshold" }),               -- 프로파일 미포함
  tuya.dp_numeric(115, { name = "over_voltage_threshold" }),               -- 프로파일 미포함
  tuya.dp_numeric(116, { name = "under_voltage_threshold" }),              -- 프로파일 미포함
  tuya.dp_numeric(118, { name = "temperature_threshold" }),                -- 프로파일 미포함
  tuya.dp_numeric(119, { name = "over_power_threshold" }),                 -- 프로파일 미포함
  tuya.dp_temperature(131, { name = "temperature", scale = 10 }),          -- 프로파일 미포함
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
  "_TZE200_x8diwkqb",
  "_TZE204_78ioiaml",
  "_TZE204_x8diwkqb",
  "_TZE284_78ioiaml",
  "_TZE200_78ioiaml",
  "_TZE284_x8diwkqb",
}))

-- ══════════════════════════════════════════════════════════════
-- 1-13. power_meter_model_sdm01v15: 3P+N 에너지 모니터 변형
-- Z2M: SDM01V1.5
-- ══════════════════════════════════════════════════════════════
local power_meter_model_sdm01v15 = {
  profile = "meters-power-energy-voltage-current",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_energy(23, { name = "produced_energy", scale = 100 }),           -- 프로파일 미포함
  tuya.dp_power(29, { emit = emit.power(), scale = 1 }),
  tuya.dp_ac_frequency(32, {}),                                            -- 프로파일 미포함
  tuya.dp_power_factor(50, {}),                                            -- 프로파일 미포함
  tuya.dp_numeric(102, { name = "update_frequency" }),                     -- 프로파일 미포함
  tuya.dp_voltage(103, { emit = emit.voltage(), scale = 10 }),
  tuya.dp_current(104, { emit = emit.current(), scale = 1000 }),
  tuya.dp_power(105, { name = "power_a", scale = 1 }),                     -- 프로파일 미포함
  tuya.dp_power_factor(108, { name = "power_factor_a" }),                  -- 프로파일 미포함
  tuya.dp_energy(109, { name = "energy_a", scale = 100 }),                 -- 프로파일 미포함
  tuya.dp_energy(110, { name = "energy_produced_a", scale = 100 }),        -- 프로파일 미포함
  tuya.dp_voltage(121, { name = "voltage_c", scale = 10 }),                -- 프로파일 미포함
  tuya.dp_current(122, { name = "current_c", scale = 1000 }),              -- 프로파일 미포함
  tuya.dp_power(123, { name = "power_c", scale = 1 }),                     -- 프로파일 미포함
}

register_device_definition(power_meter_model_sdm01v15, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_gomuk3dc",
  "_TZE284_gomuk3dc",
  "_TZE200_gomuk3dc",
}))

return device_definitions




