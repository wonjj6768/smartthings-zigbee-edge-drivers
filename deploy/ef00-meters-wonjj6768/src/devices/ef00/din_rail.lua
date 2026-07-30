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
local ALARM_TRIP_SETTING = { ignore = 0, alarm = 1, trip = 2 }
local IGNORE_ALARM_SETTING = { ignore = 0, alarm = 1 }
local CLOSED_ALARM_TRIP_SETTING = { closed = 0, alarm = 1, trip = 2 }
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
