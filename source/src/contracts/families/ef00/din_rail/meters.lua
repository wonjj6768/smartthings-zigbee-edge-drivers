-- meters package-owned DIN rail family definitions.

local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local common = require "contracts.helpers.ef00_din_rail"

local device_definitions, register_device_definition = device_helpers.definition_registry()
local converter = tuya.converter
local emit_metric_bundle = common.emit_metric_bundle
local circuit_breaker_faults_converter = common.circuit_breaker_faults_converter
local BREAKER_EVENT_LOOKUP = common.BREAKER_EVENT_LOOKUP
local IGNORE_ALARM_SETTING = { ignore = 0, alarm = 1 }

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
  package_group = "meters",
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
  package_group = "meters",
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
  package_group = "meters",
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
  package_group = "meters",
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
  package_group = "meters",
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
  package_group = "meters",
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
  package_group = "meters",
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
  package_group = "meters",
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
  package_group = "meters",
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
  package_group = "meters",
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
  package_group = "meters",
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
  package_group = "meters",
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
  package_group = "meters",
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
  package_group = "meters",
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
  package_group = "meters",
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
  package_group = "meters",
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
  package_group = "meters",
  tuya.dp_power(19, { emit = emit.power(), scale = 10, read_only = true }),
  tuya.dp_voltage(20, { emit = emit.voltage(), scale = 10, read_only = true }),
  tuya.dp_current(101, { name = "current_a", component = "ct1", scale = 1000, emit = emit.current(), read_only = true }),
  tuya.dp_current(102, { name = "current_b", component = "ct2", scale = 1000, emit = emit.current(), read_only = true }),
  tuya.dp_power(103, { name = "power_a", component = "ct1", scale = 10, emit = emit.power(), read_only = true }),
  tuya.dp_power(104, { name = "power_b", component = "ct2", scale = 10, emit = emit.power(), read_only = true }),
  tuya.dp_ac_frequency(105, { name = "ac_frequency", scale = 100, emit = emit.acFrequency2ct(), read_only = true }),
  tuya.dp_energy(115, { name = "energy_a", component = "ct1", emit = emit.energy(), scale = 100, read_only = true }),
  tuya.dp_energy(117, { name = "energy_b", component = "ct2", emit = emit.energy(), scale = 100, read_only = true }),
  tuya.dp_power_factor(120, { name = "power_factor", component = "ct1", emit = emit.powerFactor2ctPercent(), read_only = true }),
  tuya.dp_power_factor(121, { name = "power_factor", component = "ct2", emit = emit.powerFactor2ctPercent(), read_only = true }),
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
  package_group = "meters",
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

-- ══════════════════════════════════════════════════════════════
-- 1-9a. power_meter_model_atms10013z3: 3상 전력계
-- Z2M: ATMS10013Z3 / ATMS100133Z
-- ══════════════════════════════════════════════════════════════
local power_meter_model_atms10013z3 = {
  profile = "meters-energy-3phase-atms10013z3",
  package_group = "meters",
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
-- 1-10f. power_meter_model_to_q_sa1: Tongou clamp energy meter
-- Z2M: TO-Q-SA1 / TOSA1-01WXJAT2A
-- ══════════════════════════════════════════════════════════════
local power_meter_model_to_q_sa1 = {
  profile = "meters-power-energy-voltage-current-toqsa1",
  package_group = "meters",
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
  package_group = "meters",
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
  package_group = "meters",
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
  package_group = "meters",
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
  package_group = "meters",
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

return {
  id = "ef00.din_rail.meters",
  registrations = device_definitions,
}
