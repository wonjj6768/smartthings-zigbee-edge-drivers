
local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local common = require "contracts.helpers.ef00_din_rail"

local device_definitions, register_device_definition = device_helpers.definition_registry()
local converter = tuya.converter
local emit_metric_bundle = common.emit_metric_bundle
local circuit_breaker_faults_converter = common.circuit_breaker_faults_converter
local BREAKER_EVENT_LOOKUP = common.BREAKER_EVENT_LOOKUP
local emit_voltage = emit.voltage()
local emit_current = emit.current()
local emit_power = emit.power()
local ALARM_TRIP_SETTING = { ignore = 0, alarm = 1, trip = 2 }
local CLOSED_ALARM_TRIP_SETTING = { closed = 0, alarm = 1, trip = 2 }

-- Z2M: TS0601_din_1 / ZHA: TS0601 power meter 계열
-- Z2M TS0601_din_1 (tuya.ts:10945): DP1 energy /100, DP6 phase variant 1
-- voltage and current, DP16 switch, DP101 total energy /100, DP102 produced
-- energy /100, DP103 power, DP105 AC frequency /100, DP109 reactive energy
-- /100, DP110 reactive power, DP111 power factor /10 and DP9 the circuit
-- breaker fault bitmap.  Z2M explicitly leaves DP17 and DP18 unmapped because
-- their payloads are undocumented, so they stay log-only here as well.
local din_rail_model_ts0601_din_1 = {
  profile = "din-rail-switch-power-energy-voltage-current-din1",
  package_group = "energy",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_phase_variant1(6, {
    emit = emit_metric_bundle({ voltage = true, current = true }),
  }),
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

-- Z2M: TS0601_din_2
-- Z2M TS0601_din_2 (tuya.ts:11190): DP1 energy /100, DP6 phase variant 2,
-- DP10 fault enum, DP16 switch, DP17 threshold pair, DP18 meter ID and DP20
-- clear fault.  Z2M deliberately maps DP3, DP4, DP11 and DP21..DP24 to null
-- because the monthly/daily counters only answer on request and the frozen and
-- tariff payloads are undocumented, so those stay internal here as well.
local din_rail_model_ts0601_din_2 = {
  profile = "din-rail-switch-power-energy-voltage-current-din2",
  package_group = "energy",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_numeric(3, { name = "monthly_energy" }),
  tuya.dp_numeric(4, { name = "daily_energy" }),
  tuya.dp_phase_variant2(6, {
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
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

-- Z2M: TS0601_din_3
-- Z2M TS0601_din_3 (tuya.ts:11256) shares the din_2 layout and adds DP2
-- produced energy /100.  DP3, DP4, DP11 and DP21..DP24 are null in Z2M for the
-- same reasons as din_2, so they stay internal.
local din_rail_model_ts0601_din_3 = {
  profile = "din-rail-switch-power-energy-voltage-current-din3",
  package_group = "energy",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_energy(2, { name = "produced_energy", scale = 100, emit = emit.producedEnergyDin() }),
  tuya.dp_numeric(3, { name = "monthly_energy" }),
  tuya.dp_numeric(4, { name = "daily_energy" }),
  tuya.dp_phase_variant2(6, {
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
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

-- Z2M: TS0601_din
local din_rail_model_ts0601_din_legacy = {
  package_group = "energy",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_phase_variant2(6, {
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_on_off(16, { name = "switch", emit = emit.switch() }),
}

register_device_definition(din_rail_model_ts0601_din_legacy, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_byzdayie",
  "_TZE200_ewxhg6o9",
  "_TZE200_fsb6zw01",
}))

-- Z2M: TS0601_din_4
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
  package_group = "energy",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_phase_variant2(6, {
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
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

-- Z2M SMKG-2KNL-SD (tuya.ts:25032): DP1 switch, DP17 energy /100, DP18 current
-- /100 (not /1000), DP19 power /10, DP20 voltage /10, DP47 temperature raw,
-- DP53 leakage current raw, DP41..DP45 writable thresholds and DP9 the circuit
-- breaker fault bitmap.  The definition used the default current and power
-- scales and left DP9 and the DP42..DP45 thresholds unreachable.
local din_rail_model_leakage_protector = {
  profile = "din-rail-switch-power-energy-voltage-current-leakage-protector",
  package_group = "energy",
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

-- Z2M: TS0601_rcbo / ZJSBL7-100Z
local emit_rcbo_trip = emit.zjsbl7Trip()
local din_rail_model_ts0601_rcbo = {
  profile = "din-rail-switch-power-energy-voltage-current-rcbo",
  package_group = "energy",
  capability_commands = {
    { capability_id = "concertmirror08464.zjsbl7ClearData", command_name = "clearData", mapping_name = "clear_device_data", value = true },
    { capability_id = "concertmirror08464.zjsbl7Trip", command_name = "clearTrip", mapping_name = "clear_trip", value = true },
  },
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", emit = emit.switch(),
      handler = function(device, value)
        if value == true then
          device:set_field("trip", "clear", { persist = true })
          device:emit_event(emit_rcbo_trip(device, "clear"))
        end
      end,
    }),
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
      command_id = 4,
      emit = emit.rcboPowerOnBehavior(),
      converter = converter.lookup_from_to({ off = 0, on = 1, previous = 2 }),
    }),
    tuya.dp_child_lock(29, { name = "child_lock", emit = emit.rcboChildLock(),
      converter = converter.lookup_from_to({ off = false, on = true }),
    }),
    tuya.dp_raw(101, { name = "voltage", read_only = true, converter = converter.raw_uint_be(10, { length = 2 }), emit = emit_voltage }),
    tuya.dp_raw(102, { name = "current", read_only = true, converter = converter.raw_uint_be(1000, { start = 2, length = 2 }), emit = emit_current }),
    tuya.dp_raw(103, { name = "power", read_only = true, converter = converter.raw_uint_be(10, { start = 2, length = 2 }), emit = emit_power }),
    tuya.dp_temperature(105, {
      name = "temperature",
      scale = 1,
      read_only = true,
      emit = emit.temperature(),
    }),
    tuya.dp_energy(113, { emit = emit.energy(), scale = 100, read_only = true }),
    tuya.dp_string(114, { name = "meter_number", read_only = true, emit = emit.zjsbl7MeterNumber(),
      from_device = function(value) return value:match("^%s*(.-)%s*$") end,
    }),
    tuya.dp_binary(115, { name = "clear_device_data", write_only = true, command_id = 4 }),
    tuya.dp_binary(116, { name = "trip", read_only = true, persist = true, emit = emit_rcbo_trip,
      converter = converter.from_only(converter.lookup_value({ [true] = "trip", [false] = "clear" })),
    }),
    tuya.dp_binary(116, { name = "clear_trip", write_only = true, command_id = 4 }),
    tuya.dp_raw(118, {
      name = "voltage_rms",
      read_only = true,
      converter = converter.raw_uint_be(10, { length = 2 }),
      emit = emit.zjsbl7VoltageRms(),
    }),
    tuya.dp_raw(119, {
      name = "current_average",
      read_only = true,
      converter = converter.raw_uint_be(1000, { start = 2, length = 2 }),
      emit = emit.rcboCurrentAverage(),
    }),
  },
}

for phase = 1, 3 do
  local start = 3 * phase + 2
  local read = converter.raw_uint_be(10, { start = start, length = 2 }).from
  din_rail_model_ts0601_rcbo.datapoints[#din_rail_model_ts0601_rcbo.datapoints + 1] = tuya.dp_raw(103, {
    name = "power_l" .. phase, component = "l" .. phase, read_only = true, emit = emit_power,
    from_device = function(value)
      if #value >= start + 1 then return read(value) end
    end,
  })
end

-- Name, emitter, width, conversion, writer fallback, SET min/max.
-- Fallbacks only assemble SET packets; they are never initial reported states.
for _, group in ipairs({
  { 109, {
    { "self_test_auto_days", emit.zjsbl7SelfTestAutoDays(), 1, 1, 0 },
    { "self_test_auto_hours", emit.zjsbl7SelfTestAutoHours(), 1, 1, 0 },
    { "self_test_auto", emit.zjsbl7SelfTestAuto(), 1, "flag", "off" },
    { "over_leakage_current_threshold", emit.zjsbl7OverLeakageThreshold(), 2, 1, 30, 10, 100 },
    { "over_leakage_current_trip", emit.zjsbl7OverLeakageTrip(), 1, "flag", "off", true },
    { "over_leakage_current_alarm", emit.zjsbl7OverLeakageAlarm(), 1, "flag", "off", true },
    { "self_test", emit.zjsbl7SelfTest(), 1, "test", "clear" },
  } },
  { 110, {
    { "over_voltage_threshold", emit.zjsbl7OverVoltageThreshold(), 2, 10, 280, 200, 300 },
    { "over_voltage_trip", emit.zjsbl7OverVoltageTrip(), 1, "flag", "off", true },
    { "over_voltage_alarm", emit.zjsbl7OverVoltageAlarm(), 1, "flag", "off", true },
    { "under_voltage_threshold", emit.zjsbl7UnderVoltageThreshold(), 2, 10, 150, 100, 215 },
    { "under_voltage_trip", emit.zjsbl7UnderVoltageTrip(), 1, "flag", "off", true },
    { "under_voltage_alarm", emit.zjsbl7UnderVoltageAlarm(), 1, "flag", "off", true },
  } },
  { 111, {
    { "over_current_threshold", emit.zjsbl7OverCurrentThreshold(), 3, 1000, 63, 1, 100 },
    { "over_current_trip", emit.zjsbl7OverCurrentTrip(), 1, "flag", "off", true },
    { "over_current_alarm", emit.zjsbl7OverCurrentAlarm(), 1, "flag", "off", true },
  } },
  { 112, {
    { "over_temperature_threshold", emit.zjsbl7OverTempThreshold(), 1, "signed", 80, 30, 100 },
    { "over_temperature_trip", emit.zjsbl7OverTempTrip(), 1, "flag", "off", true },
    { "over_temperature_alarm", emit.zjsbl7OverTempAlarm(), 1, "flag", "off", true },
  } },
}) do
  local dp, fields, format = group[1], group[2], ">!1"
  for _, field in ipairs(fields) do format = format .. "I" .. field[3] end
  local offset = 1
  for _, field in ipairs(fields) do
    local mode, writable = field[4], field[6] ~= nil
    local read = converter.raw_uint_be(type(mode) == "number" and mode or 1, { start = offset, length = field[3] }).from
    din_rail_model_ts0601_rcbo.datapoints[#din_rail_model_ts0601_rcbo.datapoints + 1] = tuya.dp_raw(dp, {
      name = field[1], emit = field[2], read_only = not writable,
      persist = true, command_id = 4, suppress_optimistic_state = true,
      from_device = function(value)
        value = read(value)
        if value == nil then return nil end
        if mode == "flag" then return value ~= 0 and "on" or "off" end
        if mode == "test" then return value ~= 0 and "test" or "clear" end
        if mode == "signed" and value > 127 then return 128 - value end
        return value
      end,
      to_device = writable and function(value, device)
        if mode == "flag" then
          if value ~= "on" and value ~= "off" then return nil end
        elseif type(value) ~= "number" or value % 1 ~= 0 or value < field[6] or value > field[7] then
          return nil
        end
        local values = {}
        for index, sibling in ipairs(fields) do
          local current = sibling == field and value or device:get_field(sibling[1])
          if current == nil then current = sibling[5] end
          if sibling[4] == "test" then current = 0
          elseif sibling[4] == "flag" then current = current == "on" and 1 or 0
          elseif sibling[4] == "signed" then current = current < 0 and 128 - current or current
          else current = math.floor(current * sibling[4] + 0.5) end
          values[index] = current
        end
        return string.pack(format, table.unpack(values))
      end or nil,
    })
    offset = offset + field[3]
  end
end

register_device_definition(din_rail_model_ts0601_rcbo, {
  device_helpers.create_fingerprint("_TZE200_hkdl5fmv", "TS0601"),
  device_helpers.create_fingerprint("_TZE284_hkdl5fmv", "TS0601"),
  device_helpers.create_fingerprint("HOCH", "ZJSBL7-100Z"),
  device_helpers.create_fingerprint("WDYK", "ZJSBL7-100Z"),
})

-- Z2M: TO-Q-SYS-JZT
-- Z2M TO-Q-SYS-JZT (tuya.ts:19540) is a meter, not an RCBO.  DP108 is the
-- control mode enum here, and there is no DP112 auto reclosing, DP113 restore
-- default, DP117 leakage threshold or DP143..DP145 recloser block.  DP13 and
-- DP125 are marked unknown upstream so they stay internal.
local toqjzt_phase_metrics = emit_metric_bundle({ voltage = true, current = true })
local function toqjzt_phase_events(device, value, info, context)
  if type(value) ~= "table" then return nil end
  local events = toqjzt_phase_metrics(device, value, info, context) or {}
  if value.power ~= nil then
    local power_events = emit_power(device, value.power)
    if power_events[1] ~= nil then
      for _, event in ipairs(power_events) do events[#events + 1] = event end
    else
      events[#events + 1] = power_events
    end
  end
  return #events > 0 and events or nil
end

local din_rail_model_to_q_sys_jzt = {
  profile = "din-rail-switch-power-energy-voltage-current-toqjzt",
  package_group = "energy",
  query_on_configure = true,
  respond_to_mcu_version_response = true,
  -- Use the existing host timer so a persisted user interval still takes priority.
  default_power_poll_interval_seconds = 10,
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_phase_variant2(6, {
    emit = toqjzt_phase_events,
  }),
  tuya.dp_numeric(13, { name = "test1" }),
  tuya.dp_numeric(15, { name = "leakage_current", emit = emit.leakageCurrentToqJzt() }),
  tuya.dp_on_off(16, { name = "switch", emit = emit.switch() }),
  -- Z2M uses valueConverter.raw here, so this datapoint is already in Hz.
  tuya.dp_ac_frequency(32, {
    name = "ac_frequency",
    converter = converter.signed_number_pair(1),
    read_only = true,
    emit = emit.toqjztAcFrequencyV2(),
  }),
  tuya.dp_power_factor(50, {
    name = "power_factor",
    converter = converter.signed_number_pair(1),
    read_only = true,
    emit = emit.toqjztPowerFactorV2(),
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
    converter = converter.signed_number_pair(10),
    signed = true,
    emit = emit.toqjztTemperatureThreshold(),
  }),
  tuya.dp_numeric(119, { name = "over_power_threshold", emit = emit.toqjztOverPowerThreshold() }),
  tuya.dp_numeric(125, { name = "test5" }),
  tuya.dp_temperature(131, {
    name = "temperature",
    converter = converter.signed_number_pair(10),
    signed = true,
    read_only = true,
    emit = emit.temperature(),
  }),
}

register_device_definition(din_rail_model_to_q_sys_jzt, {
  device_helpers.create_fingerprint("_TZE284_6ocnqlhn", "TS0601"),
})

-- Z2M: TOWSMR1
-- Z2M TOWSMR1 (tuya.ts:19248) is a single phase RCBO.  It shares the setting and
-- threshold datapoints with TO-Q-SYS-JZT but DP108 is the leakage protection
-- setting rather than a control mode, and it adds DP112 auto reclosing, DP113
-- restore default, DP117 leakage threshold and the DP143..DP145 reclosers.  It
-- also has no DP32 frequency or DP50 power factor.  Sharing the meter definition
-- meant writing a control mode value into the leakage protection setting.
local din_rail_model_towsmr1 = {
  profile = "din-rail-switch-power-energy-voltage-current-towsmr1",
  package_group = "energy",
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

-- The pinned getDataValue uses signed32 for VALUE/BITMAP, not Uint32.
-- Preserve Enum byte scalars; signed_number_pair alone would sign-extend Enum FF.
local function towsmr_scalar(value, _, info)
  if type(value) ~= "number" then return end
  if info and (info.datatype == 2 or info.datatype == 5) and info.length == 4 then
    return info.signed_value
  end
  return value
end

local function towsmr_numeric(dp, name, event, bounds, scale)
  scale = scale or 1
  return tuya.dp_numeric(dp, {
    name = name,
    emit = event,
    read_only = bounds == false,
    signed = dp == 118,
    from_device = function(value, device, info)
      local number = towsmr_scalar(value, device, info)
      if number ~= nil then return number / scale end
    end,
    to_device = bounds ~= false and function(value)
      if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then return end
      if bounds and (value < bounds[1] or value > bounds[2]) then return end
      -- Step is a primary expose/UI hint, not a converter grid restriction.
      -- The existing VALUE serializer rounds once after this primary scale.
      return value * scale
    end or nil,
  })
end

-- Official ST temperatureMeasurement bounds, not physical device limits.
-- Decode remains signed32 /10; unsupported standard event values are not clamped.
local towsmr_temperature = emit.temperature()
local function towsmr_temperature_event(device, value)
  if type(value) == "number" and value >= -460 and value <= 10000 then
    return towsmr_temperature(device, value)
  end
end

local towsmr_basic = require "st.zigbee.zcl.clusters".Basic
local TOWSMR_NATIVE = "towsmr1:native_sw_build_id"
local TOWSMR_APP = "towsmr1:app_version"
local TOWSMR_FIRMWARE = "towsmr1:firmware_id"
local TOWSMR_CUSTOM = "towsmr1:custom_firmware_id"
local TOWSMR_PROBE = "towsmr1:native_probe"
local TOWSMR_PERSIST = {persist = true}
local TOWSMR_TRANSIENT = {persist = false}

local function towsmr_has_native(device)
  local value = device:get_field(TOWSMR_NATIVE)
  return type(value) == "string" and value ~= ""
end

local function towsmr_version(value)
  return string.format("%d.%d.%d", value >> 6, (value & 0x30) >> 4, value & 0x0F)
end

local function towsmr_save_firmware(device, value, custom)
  device:set_field(TOWSMR_FIRMWARE, value, TOWSMR_PERSIST)
  device:set_field(TOWSMR_CUSTOM, custom, TOWSMR_PERSIST)
end

local function towsmr_finish_probe(device, pending)
  if device:get_field(TOWSMR_PROBE) ~= pending then return end
  device:set_field(TOWSMR_PROBE, nil, TOWSMR_TRANSIENT)
  if pending.timer then device.thread:cancel_timer(pending.timer) end
  if not towsmr_has_native(device) then
    -- ZHC seq=0x0002 uses herdsman UINT16 (LE), not the shared BE helper.
    return tuya.send_raw(device, 0x10, "\x02\x00")
  end
end

local function towsmr_configure(_, device)
  local previous = device:get_field(TOWSMR_PROBE)
  if previous then
    device:set_field(TOWSMR_PROBE, nil, TOWSMR_TRANSIENT)
    if previous.timer then device.thread:cancel_timer(previous.timer) end
  end
  -- Preserve the primary request order; Basic4000 is the explicit Edge
  -- replacement for the herdsman interview cache, after magic/dataQuery.
  tuya.send_magic_packet(device)
  tuya.send_state_request(device)
  if towsmr_has_native(device) then return end
  local pending = {}
  device:set_field(TOWSMR_PROBE, pending, TOWSMR_TRANSIENT)
  pending.timer = device.thread:call_with_delay(10, function()
    -- Timer may already be queued when a newer configure cancels it.
    if device:get_field(TOWSMR_PROBE) == pending then
      pending.timer = nil
      towsmr_finish_probe(device, pending)
    end
  end, "TOWSMR1 native firmware read timeout")
  local sent = pcall(device.send, device, towsmr_basic.attributes.SWBuildID:read(device))
  if not sent then towsmr_finish_probe(device, pending) end
end

local function towsmr_zigbee_message(device, rx)
  local address, message = rx.address_header, rx.body
  local header = message and message.zcl_header
  if not address or not header or address.src_endpoint.value ~= 1 then return end
  if header.frame_ctrl:is_mfg_specific_set() or not header.frame_ctrl:is_direction_set() then return end
  local cluster, command, body = address.cluster.value, header.cmd.value, message.zcl_body
  if cluster == 0 and not header.frame_ctrl:is_cluster_specific_set() then
    local pending = device:get_field(TOWSMR_PROBE)
    if (command == 1 or command == 10) and type(body.attr_records) == "table" then
      local native_record = false
      for _, record in ipairs(body.attr_records) do
        local id = record.attr_id.value
        local success = not record.status or record.status.value == 0
        local kind = record.data_type and record.data_type.value
        local value = record.data and record.data.value
        if id == 1 and success and kind == 0x20 and type(value) == "number" then
          device:set_field(TOWSMR_APP, value, TOWSMR_PERSIST)
        elseif id == 0x4000 then
          native_record = true
          if success and kind == 0x42 and type(value) == "string" and value ~= "" then
            device:set_field(TOWSMR_NATIVE, value, TOWSMR_PERSIST)
            towsmr_save_firmware(device, value, false)
          end
        end
      end
      -- An unrelated Basic record must not complete this read. An empty read
      -- response is a missing result; an actual native report is authoritative.
      if pending and ((command == 1 and (native_record or #body.attr_records == 0))
          or (native_record and towsmr_has_native(device))) then
        towsmr_finish_probe(device, pending)
      end
    elseif command == 0x0B and pending and body.cmd and body.cmd.value == 0
        and body.status and body.status.value ~= 0 then
      towsmr_finish_probe(device, pending)
    end
  elseif cluster == 0xEF00 and header.frame_ctrl:is_cluster_specific_set() and command == 0x11 then
    local payload = body.body_bytes
    if type(payload) ~= "string" or #payload ~= 3 or towsmr_has_native(device) then return end
    local app, mcu = device:get_field(TOWSMR_APP), payload:byte(3)
    if type(app) == "number" and app ~= 0 and mcu ~= 0 then
      towsmr_save_firmware(device,
        "Zigbee module: " .. towsmr_version(app) .. ", MCU module: " .. towsmr_version(mcu), true)
    end
  end
end

-- Fixed user-selected UTC offset; no host timezone or automatic DST inference.
local function towsmr_send_time(device, mode, hours)
  local utc = os.time()
  if mode == "1970" then return tuya.send_time(device, utc, utc + hours * 3600) end
  if mode == "2000" then return tuya.send_time_with_offset(device, 946684800, utc, utc + hours * 3600) end
  return false
end

local TOWSMR_ALARM = converter.lookup_from_to({ignore = 0, alarm = 1, trip = 2})
local TOWSMR_BINARY = converter.lookup_from_to({off = false, on = true})
local TOWSMR_EVENT = converter.from_only(converter.lookup_value(BREAKER_EVENT_LOOKUP))

local function towsmr_family(profile, route_prefix, events, current_max, leakage)
  local function route(name) return route_prefix .. "_" .. name end
  local time_start_field, time_zone_field = route("time_start"), route("time_zone")
  local function alarm(dp, name)
    return tuya.dp_enum(dp, {name = route(name), converter = TOWSMR_ALARM, emit = events[name]})
  end
  local function binary(dp, name)
    return tuya.dp_on_off(dp, {name = route(name), converter = TOWSMR_BINARY, emit = events[name]})
  end
  return {
    profile = profile,
    package_group = "energy",
    -- The app's single existing polling path resolves persisted override first.
    default_power_poll_interval_seconds = 10,
    configure = towsmr_configure,
    magic_packet = false,
    query_on_configure = false, -- owned by configure, exactly once
    mcu_version_request_on_configure = false,
    query_on_announce = false,
    refresh_state_query = true,
    time_start = "off",
    time_handler = function(device)
      return towsmr_send_time(device, device:get_field(time_start_field) or "off", device:get_field(time_zone_field) or 0)
    end,
    protocol_writers = {
      [route("time_start")] = function(device, mode)
        if mode ~= "off" and mode ~= "1970" and mode ~= "2000" then return false end
        if mode ~= "off" and not towsmr_send_time(device, mode, device:get_field(time_zone_field) or 0) then return false end
        device:set_field(time_start_field, mode, TOWSMR_PERSIST)
        return true
      end,
      [route("time_zone")] = function(device, hours)
        if type(hours) ~= "number" or hours ~= hours or hours < -12 or hours > 14 or hours * 4 ~= math.floor(hours * 4) then return false end
        local mode = device:get_field(time_start_field) or "off"
        if mode ~= "off" and not towsmr_send_time(device, mode, hours) then return false end
        device:set_field(time_zone_field, hours, TOWSMR_PERSIST)
        return true
      end,
    },
    -- Restore/display local time configuration only; no polling/timer/time TX.
    runtime_start = function(device)
      device:emit_component_event({id = "main"}, events.time_start(device, device:get_field(time_start_field) or "off"))
      device:emit_component_event({id = "main"}, events.time_zone(device, device:get_field(time_zone_field) or 0))
    end,
    force_time_updates = false,
    respond_to_mcu_version_response = false,
    zigbee_message_handler = towsmr_zigbee_message,
    -- Retain all 23 primary DP routes. Hidden conditional routes have no
    -- custom ID/UI; their presence is not a hardware-support certification.
    towsmr_numeric(1, "energy", emit.energy(), false, 100),
    tuya.dp_phase_variant2(6, {read_only = true, emit = emit_metric_bundle({voltage = true, current = true, power = true})}),
    towsmr_numeric(15, route("leakage_current"), events.leakage_current, false),
    tuya.dp_on_off(16, {name = "switch", emit = emit.switch()}),
    alarm(102, "over_voltage_setting"),
    alarm(103, "under_voltage_setting"),
    alarm(104, "over_current_setting"),
    alarm(105, "over_power_setting"),
    alarm(107, "temperature_setting"),
    alarm(108, "leakage_setting"),
    tuya.dp_enum(110, {name = route("event"), read_only = true, converter = TOWSMR_EVENT, emit = events.event}),
    binary(112, "auto_reclosing"),
    binary(113, "restore_default"),
    towsmr_numeric(114, route("over_current_threshold"), events.over_current_threshold, current_max and {1, current_max} or nil),
    towsmr_numeric(115, route("over_voltage_threshold"), events.over_voltage_threshold, {240, 295}),
    towsmr_numeric(116, route("under_voltage_threshold"), events.under_voltage_threshold, {145, 220}),
    towsmr_numeric(117, route("leakage_threshold"), events.leakage_threshold, leakage and {30, 100} or nil),
    towsmr_numeric(118, route("temperature_threshold"), events.temperature_threshold, {-25, 100}, 10),
    towsmr_numeric(119, route("over_power_threshold"), events.over_power_threshold, {5, 25000}),
    towsmr_numeric(131, "temperature", towsmr_temperature_event, false, 10),
    binary(143, "overcurrent_recloser"),
    binary(144, "leakage_recloser"),
    binary(145, "overpower_recloser"),
  }
end

-- Four literal event tables are assembled here; IDs are not built dynamically
-- in runtime callbacks. The four tables below use existing generated emitter factories.
local din_rail_model_towsmr1_20ac = towsmr_family("energy-towsmr1-20ac", "towsmr20ac", {
  leakage_current = emit.towsmr20AcLeakageCurrent(),
  event = emit.towsmr20AcEvent(),
  time_start = emit.towsmr20AcTimeStart(),
  time_zone = emit.towsmr20AcTimeZone(),
  over_voltage_setting = emit.towsmr20AcOverVoltageSetting(),
  over_voltage_threshold = emit.towsmr20AcOverVoltageThreshold(),
  under_voltage_setting = emit.towsmr20AcUnderVoltageSetting(),
  under_voltage_threshold = emit.towsmr20AcUnderVoltageThreshold(),
  over_current_setting = emit.towsmr20AcOverCurrentSetting(),
  over_current_threshold = emit.towsmr20AcOverCurrentThreshold(),
  over_power_setting = emit.towsmr20AcOverPowerSetting(),
  over_power_threshold = emit.towsmr20AcOverPowerThreshold(),
  temperature_setting = emit.towsmr20AcTemperatureSetting(),
  temperature_threshold = emit.towsmr20AcTemperatureThreshold(),
  leakage_setting = emit.towsmr20AcLeakageSetting(),
  leakage_threshold = emit.towsmr20AcLeakageThreshold(),
  auto_reclosing = emit.towsmr20AcAutoReclosing(),
  restore_default = emit.towsmr20AcRestoreDefault(),
  overcurrent_recloser = emit.towsmr20AcOvercurrentRecloser(),
  leakage_recloser = emit.towsmr20AcLeakageRecloser(),
  overpower_recloser = emit.towsmr20AcOverpowerRecloser(),
}, 20, true)
register_device_definition(din_rail_model_towsmr1_20ac, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_tuhfx7tf",
  "_TZE204_tuhfx7tf",
}))

local din_rail_model_towsmr1_40ac = towsmr_family("energy-towsmr1-40ac", "towsmr40ac", {
  leakage_current = emit.towsmr40AcLeakageCurrent(),
  event = emit.towsmr40AcEvent(),
  time_start = emit.towsmr40AcTimeStart(),
  time_zone = emit.towsmr40AcTimeZone(),
  over_voltage_setting = emit.towsmr40AcOverVoltageSetting(),
  over_voltage_threshold = emit.towsmr40AcOverVoltageThreshold(),
  under_voltage_setting = emit.towsmr40AcUnderVoltageSetting(),
  under_voltage_threshold = emit.towsmr40AcUnderVoltageThreshold(),
  over_current_setting = emit.towsmr40AcOverCurrentSetting(),
  over_current_threshold = emit.towsmr40AcOverCurrentThreshold(),
  over_power_setting = emit.towsmr40AcOverPowerSetting(),
  over_power_threshold = emit.towsmr40AcOverPowerThreshold(),
  temperature_setting = emit.towsmr40AcTemperatureSetting(),
  temperature_threshold = emit.towsmr40AcTemperatureThreshold(),
  leakage_setting = emit.towsmr40AcLeakageSetting(),
  leakage_threshold = emit.towsmr40AcLeakageThreshold(),
  auto_reclosing = emit.towsmr40AcAutoReclosing(),
  restore_default = emit.towsmr40AcRestoreDefault(),
  overcurrent_recloser = emit.towsmr40AcOvercurrentRecloser(),
  leakage_recloser = emit.towsmr40AcLeakageRecloser(),
  overpower_recloser = emit.towsmr40AcOverpowerRecloser(),
}, 40, true)
register_device_definition(din_rail_model_towsmr1_40ac, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_kobbcyum",
  "_TZE284_432zhuwe",
  "_TZE204_432zhuwe",
}))

local din_rail_model_towsmr1_40a = towsmr_family("energy-towsmr1-40a", "towsmr40a", {
  event = emit.towsmr40AEvent(),
  time_start = emit.towsmr40ATimeStart(),
  time_zone = emit.towsmr40ATimeZone(),
  over_voltage_setting = emit.towsmr40AOverVoltageSetting(),
  over_voltage_threshold = emit.towsmr40AOverVoltageThreshold(),
  under_voltage_setting = emit.towsmr40AUnderVoltageSetting(),
  under_voltage_threshold = emit.towsmr40AUnderVoltageThreshold(),
  over_current_setting = emit.towsmr40AOverCurrentSetting(),
  over_current_threshold = emit.towsmr40AOverCurrentThreshold(),
  over_power_setting = emit.towsmr40AOverPowerSetting(),
  over_power_threshold = emit.towsmr40AOverPowerThreshold(),
  temperature_setting = emit.towsmr40ATemperatureSetting(),
  temperature_threshold = emit.towsmr40ATemperatureThreshold(),
  auto_reclosing = emit.towsmr40AAutoReclosing(),
  restore_default = emit.towsmr40ARestoreDefault(),
  overcurrent_recloser = emit.towsmr40AOvercurrentRecloser(),
  leakage_recloser = emit.towsmr40ALeakageRecloser(),
  overpower_recloser = emit.towsmr40AOverpowerRecloser(),
}, 40, false)
register_device_definition(din_rail_model_towsmr1_40a, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_s5vuaadg",
}))

local din_rail_model_towsmr1_base = towsmr_family("energy-towsmr1-base", "towsmr1base", {
  event = emit.towsmr1BaseEvent(),
  time_start = emit.towsmr1BaseTimeStart(),
  time_zone = emit.towsmr1BaseTimeZone(),
  over_voltage_setting = emit.towsmr1BaseOverVoltageSetting(),
  over_voltage_threshold = emit.towsmr1BaseOverVoltageThreshold(),
  under_voltage_setting = emit.towsmr1BaseUnderVoltageSetting(),
  under_voltage_threshold = emit.towsmr1BaseUnderVoltageThreshold(),
  over_power_setting = emit.towsmr1BaseOverPowerSetting(),
  over_power_threshold = emit.towsmr1BaseOverPowerThreshold(),
  temperature_setting = emit.towsmr1BaseTemperatureSetting(),
  temperature_threshold = emit.towsmr1BaseTemperatureThreshold(),
  auto_reclosing = emit.towsmr1BaseAutoReclosing(),
  restore_default = emit.towsmr1BaseRestoreDefault(),
  overcurrent_recloser = emit.towsmr1BaseOvercurrentRecloser(),
  leakage_recloser = emit.towsmr1BaseLeakageRecloser(),
  overpower_recloser = emit.towsmr1BaseOverpowerRecloser(),
}, nil, false)
register_device_definition(din_rail_model_towsmr1_base, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_kobbcyum",
  "_TZE284_hecsejsb",
}))



register_device_definition(din_rail_model_towsmr1, {
  device_helpers.create_fingerprint("Tongou", "TOWSMR1-40A-AC"),
  device_helpers.create_fingerprint("Tongou", "TOWSMR1-40A-A"),
  device_helpers.create_fingerprint("Tongou", "TOWSMR1-20A-AC"),
})

-- Z2M: ZBN-JT-63
local din_rail_model_zbn_jt_63 = {
  profile = "din-rail-switch-power-energy-voltage-current-zbnjt63",
  package_group = "energy",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_numeric(3, { name = "monthly_energy" }),
  tuya.dp_numeric(4, { name = "daily_energy" }),
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

-- Z2M: DDS238-1-Z1
local din_rail_model_dds238_1_z1 = {
  profile = "din-rail-switch-power-energy-voltage-current",
  package_group = "energy",
  tuya.dp_on_off(1, { name = "switch", emit = emit.switch() }),
  tuya.dp_energy(17, { emit = emit.energy(), scale = 100 }),
  tuya.dp_current(18, { emit = emit.current(), scale = 1000 }),
  tuya.dp_power(19, { emit = emit.power(), scale = 10 }),
  tuya.dp_voltage(20, { emit = emit.voltage(), scale = 10 }),
}

register_device_definition(din_rail_model_dds238_1_z1, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_byzdayie",
}))

-- Z2M: RMDZB-1PNL63
-- Z2M RMDZB-1PNL63 (tuya.ts:10991) is single phase: DP1 energy /100, DP6
-- phaseVariant2 phase A only, DP9 circuit breaker fault bitmap, DP16 switch and
-- DP103 temperature as a raw degree value.  DP17/DP18 carry packed threshold
-- frames Z2M can only write through multi-byte raw payloads, and DP11..DP14,
-- DP105 and DP106 are explicitly marked unknown, so those stay internal.
local din_rail_model_rmdzb_1pnl63 = {
  profile = "din-rail-switch-power-energy-voltage-current-rmdzb1pnl63",
  package_group = "energy",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_phase_variant2(6, {
    signed_power = true,
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
  tuya.dp_threshold(17, {}),
  tuya.dp_threshold(18, {}),
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

-- Z2M: STB3L-125-ZJ (tuya.ts:11070)
-- The wbhaespm exacts are a different model from RMDZB-1PNL63: they report all
-- three phases through DP6/DP7/DP8, put temperature on DP102 with a /10 scale
-- instead of DP103 raw, and add the DP21 leakage self test.  Sharing the single
-- phase definition meant phases B and C were dropped and the temperature was
-- read from a datapoint this model never sends.
local din_rail_model_stb3l_125_zj = {
  profile = "din-rail-switch-power-energy-3phase-stb3l125zj",
  package_group = "energy",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_phase_variant2(6, {
    signed_power = true,
    phase = "a",
    component = "l1",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_phase_variant2(7, {
    signed_power = true,
    phase = "b",
    component = "l2",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_phase_variant2(8, {
    signed_power = true,
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
  tuya.dp_threshold(17, {}),
  tuya.dp_threshold(18, {}),
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

-- Z2M: ZBN-DJ-63
-- Z2M ZBN-DJ-63 (tuya.ts:1824) exposes far more than the shared DIN profile
-- could reach: prepayment, recharge, reclosing, leakage and timer settings all
-- live on plain scalar datapoints.  Only DP1/DP6/DP16 were visible before, so
-- the definition now emits every scalar datapoint Z2M documents.  DP17/DP18 are
-- packed threshold frames and DP106 cycle time has no documented unit, so those
-- stay internal.
local din_rail_model_zbn_dj_63 = {
  profile = "din-rail-switch-power-energy-voltage-current-zbndj63",
  package_group = "energy",
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
  tuya.dp_threshold(17, {}),
  tuya.dp_threshold(18, {}),
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
  tuya.dp_numeric(124, { name = "alarm_over_current_count" }),
  tuya.dp_numeric(125, { name = "alarm_low_current_count" }),
  tuya.dp_numeric(127, { name = "status" }),
  -- Z2M's plain numeric lookup sends VALUE, not Tuya ENUM.
  tuya.dp_numeric(134, {
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

-- Z2M: TOQCB2-80
local din_rail_model_toqcb2_80 = {
  profile = "din-rail-switch-power-energy-voltage-current-toqcb2",
  package_group = "energy",
  tuya.dp_energy(1, { emit = emit.energy(), scale = 100 }),
  tuya.dp_phase_variant2(6, {
    signed_power = true,
    phase = "a",
    component = "l1",
    emit = emit_metric_bundle({
      voltage = true,
      current = true,
      power = true,
    }),
  }),
  tuya.dp_phase_variant2(7, {
    signed_power = true,
    phase = "b",
    component = "l2",
    emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
  }),
  tuya.dp_phase_variant2(8, {
    signed_power = true,
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
  "_TZE284_lyqazpe6",
  "_TZE204_lyqazpe6",
}))

register_device_definition(din_rail_model_toqcb2_80, {
  device_helpers.create_fingerprint("Tongou", "TOQCB2-80-2P"),
})

return {
  id = "ef00.din_rail.energy",
  registrations = device_definitions,
}
