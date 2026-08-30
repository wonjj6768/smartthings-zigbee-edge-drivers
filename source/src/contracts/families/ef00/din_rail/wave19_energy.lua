-- Wave19 energy-meter source-only candidates.
-- Frozen Zigbee2MQTT v26.99.0:
--   src/devices/moes.ts:2493-2544   (Moes ZM6LT1)
--   src/devices/nous.ts:336-410     (Nous D5Z)
--   src/devices/qa.ts:417-455       (QA QASZP)

local tuya = require "protocol.tuya"
local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local din_common = require "contracts.helpers.ef00_din_rail"
local capabilities = require "st.capabilities"

local device_definitions, register_device_definition = device_helpers.definition_registry()
local converter = tuya.converter
local emit_metric_bundle = din_common.emit_metric_bundle
local circuit_breaker_faults_converter = din_common.circuit_breaker_faults_converter
local NAMESPACE = "concertmirror08464."

local function custom(capability_id)
  return assert(emit[capability_id], "missing Wave19 energy emitter: " .. capability_id)()
end

local function latest(device, capability_id, attribute, default)
  local value = device:get_latest_state("main", NAMESPACE .. capability_id, attribute)
  if value == nil then return default end
  return value
end

local function u16be(value, offset)
  local high, low = string.byte(value, offset, offset + 1)
  if high == nil or low == nil then return nil end
  return high * 0x100 + low
end

local function u24be(value, offset)
  local high, middle, low = string.byte(value, offset, offset + 2)
  if high == nil or middle == nil or low == nil then return nil end
  return high * 0x10000 + middle * 0x100 + low
end

local phase_variant_four = converter.from_only(function(value)
  if type(value) ~= "string" or #value < 8 then return nil end
  return {
    voltage = u16be(value, 1) / 10,
    current = u24be(value, 3) / 1000,
    power = u24be(value, 6),
  }
end)

local phase_variant_five = converter.from_only(function(value)
  if type(value) ~= "string" or #value < 10 then return nil end
  return {
    voltage = u16be(value, 3) / 10,
    current = u16be(value, 6) / 1000,
    power = u16be(value, 9),
  }
end)

local ON_OFF = { ON = true, OFF = false }
local on_off_converter = converter.lookup_from_to(ON_OFF)

-- Moes ZM6LT1 ---------------------------------------------------------------

local moes_zm_six = {
  profile = "meters-wave19-moes-zm6lt1",
  package_group = "wave19-energy",
  transport_classification = "EF00_DP",
  z2m_converter_source = "meta.tuyaDatapoints",
  wire_cluster = "manuSpecificTuya",
  magic_packet = true,
  query_on_configure = true,
  query_interval_seconds = 60,
  named_datapoints = true,
  time_start = "off",
  placeholder_custom_states = false,
  datapoints = {
    tuya.dp_energy(1, {
      name = "energy",
      scale = 100,
      read_only = true,
      transaction = 1,
      emit = emit.energy(),
    }),
    tuya.dp_numeric(2, {
      name = "moes_zm_six_reverse_energy",
      read_only = true,
      transaction = 1,
      converter = converter.divide_by_pair(100),
      emit = custom("moesZmSixReverseEnergy"),
    }),
    tuya.dp_raw(6, {
      name = "phase",
      read_only = true,
      transaction = 1,
      fields = { voltage = true, current = true, power = true },
      converter = phase_variant_five,
      emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
    }),
    tuya.dp_numeric(10, {
      name = "moes_zm_six_fault",
      read_only = true,
      transaction = 1,
      emit = custom("moesZmSixFault"),
    }),
    -- Frozen Z2M decodes alarm_set_2 as raw but exposes no user item.
    tuya.dp_raw(17, {
      name = "moes_zm_six_alarm_set_two",
      read_only = true,
      transaction = 1,
    }),
    tuya.dp_binary(20, {
      name = "moes_zm_six_clear_event",
      transaction = 1,
      converter = on_off_converter,
      emit = custom("moesZmSixClearEvent"),
    }),
    tuya.dp_enum(44, {
      name = "moes_zm_six_online_state",
      read_only = true,
      transaction = 1,
      converter = converter.lookup_from_to({ offline = 0, online = 1 }),
      emit = custom("moesZmSixOnlineState"),
    }),
    tuya.dp_numeric(49, {
      name = "moes_zm_six_ac_frequency",
      read_only = true,
      transaction = 1,
      converter = converter.divide_by_pair(100),
      emit = custom("moesZmSixAcFrequency"),
    }),
    tuya.dp_numeric(51, {
      name = "moes_zm_six_active_energy",
      read_only = true,
      transaction = 1,
      converter = converter.divide_by_pair(100),
      emit = custom("moesZmSixActiveEnergy"),
    }),
    tuya.dp_numeric(101, {
      name = "moes_zm_six_countdown",
      transaction = 1,
      emit = custom("moesZmSixCountdown"),
    }),
    tuya.dp_binary(104, {
      name = "moes_zm_six_device_restart",
      write_only = true,
      transaction = 1,
      converter = on_off_converter,
      emit = custom("moesZmSixDeviceRestart"),
    }),
  },
}

register_device_definition(moes_zm_six, {
  device_helpers.create_fingerprint("_TZE284_2fnssffc", "TS0601"),
})

-- Nous D5Z ------------------------------------------------------------------

local function emit_direct(device, event)
  if event == nil then return end
  if type(event) == "table" and event[1] ~= nil then
    for _, item in ipairs(event) do device:emit_event(item) end
    return
  end
  device:emit_event(event)
end

local d_five_countdown_emitter = custom("nousDFiveCountdown")
local d_five_status_emitter = custom("nousDFiveStatus")

local function d_five_switch_side_effects(device, value, dp_info, mapping_context)
  local state = value and "on" or "off"
  local previous = device:get_latest_state("main", capabilities.switch.ID, "switch")

  if not value then
    emit_direct(device, capabilities.currentMeasurement.current({ value = 0, unit = "A" }))
    emit_direct(device, capabilities.powerMeter.power({ value = 0, unit = "W" }))
    emit_direct(device, d_five_status_emitter(device, "off", dp_info, mapping_context))
  end

  if previous ~= state then
    emit_direct(device, d_five_countdown_emitter(device, 0, dp_info, mapping_context))
  end
end

local function parse_threshold_records(value)
  local records = {}
  if type(value) ~= "string" then return records end
  for offset = 1, #value - 3, 4 do
    local id, enabled = string.byte(value, offset, offset + 1)
    local threshold = u16be(value, offset + 2)
    if id ~= nil and enabled ~= nil and threshold ~= nil then
      records[id] = { enabled = enabled, value = threshold }
    end
  end
  return records
end

local function round_scaled(value, scale)
  local number = tonumber(value)
  if number == nil then return nil end
  local raw = math.floor(number * (scale or 1) + 0.5)
  if raw < 0 then raw = 0 end
  if raw > 0xFFFF then raw = 0xFFFF end
  return raw
end

local ALARM_GROUPS = {
  one = {
    dp = 17,
    shadow = "_wave19_d5z_alarm_set_one_raw",
    order = { 4, 5 },
    records = {
      [4] = {
        enabled = { capability = "nousDFiveLeakageAlarm", attribute = "leakageAlarm" },
        value = { capability = "nousDFiveLeakageThreshold", attribute = "leakageThreshold", scale = 1 },
      },
      [5] = {
        enabled = { capability = "nousDFiveTemperatureAlarm", attribute = "temperatureAlarm" },
        value = { capability = "nousDFiveTemperatureThreshold", attribute = "temperatureThreshold", scale = 1 },
      },
    },
  },
  two = {
    dp = 18,
    shadow = "_wave19_d5z_alarm_set_two_raw",
    order = { 1, 2, 3, 4, 5, 7, 8, 9 },
    records = {
      [1] = {
        enabled = { capability = "nousDFiveOverCurrentAlarm", attribute = "overCurrentAlarm" },
        value = { capability = "nousDFiveOverCurrentThreshold", attribute = "overCurrentThreshold", scale = 10 },
      },
      -- IDs 2, 5, 7, 8 and 9 are parsed by frozen threshold_5 but are not
      -- exposed by D5Z currentAndVoltageAlarm. Their bytes are shadowed and
      -- preserved if the device reports them.
      [2] = {},
      [3] = {
        enabled = { capability = "nousDFiveOverVoltageAlarm", attribute = "overVoltageAlarm" },
        value = { capability = "nousDFiveOverVoltageThreshold", attribute = "overVoltageThreshold", scale = 1 },
      },
      [4] = {
        enabled = { capability = "nousDFiveUnderVoltageAlarm", attribute = "underVoltageAlarm" },
        value = { capability = "nousDFiveUnderVoltageThreshold", attribute = "underVoltageThreshold", scale = 1 },
      },
      [5] = {}, [7] = {}, [8] = {}, [9] = {},
    },
  },
  three = {
    dp = 126,
    shadow = "_wave19_d5z_alarm_set_three_raw",
    order = { 3 },
    records = {
      [3] = {
        enabled = { capability = "nousDFiveLostFlowAlarm", attribute = "lostFlowAlarm" },
        value = { capability = "nousDFiveLostFlowThreshold", attribute = "lostFlowThreshold", scale = 10 },
      },
    },
  },
}

local function latest_alarm_value(device, item)
  if item == nil then return nil end
  return latest(device, item.capability, item.attribute, nil)
end

local function threshold_from_device(group, id, kind, value)
  local record = parse_threshold_records(value)[id]
  if record == nil then return nil end
  if kind == "enabled" then
    if record.enabled == 1 then return "ON" end
    if record.enabled == 0 then return "OFF" end
    return nil
  end
  local item = group.records[id].value
  return record.value / (item.scale or 1)
end

local function encode_threshold_group(group, id, kind, value, device)
  local records = parse_threshold_records(device:get_field(group.shadow))
  local definition = group.records[id]
  local target = records[id] or {}

  if kind == "enabled" then
    if value ~= "ON" and value ~= "OFF" then return nil end
    target.enabled = value == "ON" and 1 or 0
  else
    target.value = round_scaled(value, definition.value.scale)
  end

  if target.enabled == nil then
    local enabled = latest_alarm_value(device, definition.enabled)
    if enabled ~= nil then target.enabled = enabled == "ON" and 1 or 0 end
  end
  if target.value == nil and definition.value ~= nil then
    target.value = round_scaled(latest_alarm_value(device, definition.value), definition.value.scale)
  end
  if target.enabled == nil or (definition.value ~= nil and target.value == nil) then return nil end
  if target.value == nil then target.value = 0 end
  records[id] = target

  local bytes = {}
  for _, record_id in ipairs(group.order) do
    local record = records[record_id]
    if record ~= nil and record.enabled ~= nil and record.value ~= nil then
      bytes[#bytes + 1] = string.char(
        record_id,
        record.enabled,
        math.floor(record.value / 0x100) % 0x100,
        record.value % 0x100
      )
    end
  end
  if #bytes == 0 then return nil end
  return table.concat(bytes)
end

local function alarm_shadow(group, name)
  return tuya.dp_raw(group.dp, {
    name = name,
    field = group.shadow,
    read_only = true,
    transaction = 1,
  })
end

local function alarm_mapping(group, id, kind, name, emitter)
  return tuya.dp_raw(group.dp, {
    name = name,
    transaction = 1,
    converter = converter.from_to(
      function(value) return threshold_from_device(group, id, kind, value) end,
      function(value, device) return encode_threshold_group(group, id, kind, value, device) end
    ),
    emit = emitter,
  })
end

local INCHING_ITEMS = {
  state = { capability = "nousDFiveInchingState", attribute = "inchingState", default = "OFF" },
  minutes = { capability = "nousDFiveInchingMinutes", attribute = "inchingMinutes", default = 1 },
  seconds = { capability = "nousDFiveInchingSeconds", attribute = "inchingSeconds", default = 0 },
}

local function inching_from_device(kind, value)
  if type(value) ~= "string" or #value < 3 then return nil end
  if kind == "state" then return string.byte(value, 1) == 1 and "ON" or "OFF" end
  local total = u16be(value, 2)
  if kind == "minutes" then return math.floor(total / 60) end
  return total % 60
end

local function inching_to_device(kind, value, device)
  local state = latest(device, INCHING_ITEMS.state.capability, INCHING_ITEMS.state.attribute, INCHING_ITEMS.state.default)
  local minutes = latest(device, INCHING_ITEMS.minutes.capability, INCHING_ITEMS.minutes.attribute, INCHING_ITEMS.minutes.default)
  local seconds = latest(device, INCHING_ITEMS.seconds.capability, INCHING_ITEMS.seconds.attribute, INCHING_ITEMS.seconds.default)
  if kind == "state" then state = value end
  if kind == "minutes" then minutes = value end
  if kind == "seconds" then seconds = value end

  local total = math.max(1, (tonumber(minutes) or 0) * 60 + (tonumber(seconds) or 0))
  if total > 65535 then total = 65535 end
  total = math.floor(total + 0.5)
  return string.char(state == "ON" and 1 or 0, math.floor(total / 0x100), total % 0x100)
end

local function inching_mapping(kind, name, emitter)
  return tuya.dp_raw(109, {
    name = name,
    transaction = 1,
    converter = converter.from_to(
      function(value) return inching_from_device(kind, value) end,
      function(value, device) return inching_to_device(kind, value, device) end
    ),
    emit = emitter,
  })
end

local d_five = {
  profile = "meters-wave19-nous-d5z",
  package_group = "wave19-energy",
  transport_classification = "EF00_DP",
  z2m_converter_source = "meta.tuyaDatapoints",
  wire_cluster = "manuSpecificTuya",
  magic_packet = true,
  query_on_configure = true,
  named_datapoints = true,
  time_start = "off",
  placeholder_custom_states = false,
  datapoints = {
    tuya.dp_energy(1, { name = "energy", scale = 100, read_only = true, transaction = 1, emit = emit.energy() }),
    tuya.dp_raw(6, {
      name = "phase",
      read_only = true,
      transaction = 1,
      fields = { voltage = true, current = true, power = true },
      converter = phase_variant_four,
      emit = emit_metric_bundle({ voltage = true, current = true, power = true }),
    }),
    tuya.dp_numeric(9, {
      name = "nous_d_five_faults",
      read_only = true,
      transaction = 1,
      converter = circuit_breaker_faults_converter,
      emit = custom("nousDFiveFaults"),
    }),
    tuya.dp_binary(11, {
      name = "nous_d_five_prepayment",
      transaction = 1,
      converter = on_off_converter,
      emit = custom("nousDFivePrepayment"),
    }),
    tuya.dp_binary(12, {
      name = "nous_d_five_energy_balance_reset",
      transaction = 1,
      converter = converter.from_to(
        function() return "idle" end,
        function(value) if value == "RESET" then return false end end
      ),
      emit = custom("nousDFiveEnergyBalanceReset"),
    }),
    tuya.dp_numeric(13, {
      name = "nous_d_five_energy_balance",
      read_only = true,
      transaction = 1,
      converter = converter.divide_by_pair(100),
      emit = custom("nousDFiveEnergyBalance"),
    }),
    tuya.dp_numeric(14, {
      name = "nous_d_five_energy_balance_add",
      transaction = 1,
      converter = converter.from_to(
        function() return 0 end,
        function(value) return math.floor((tonumber(value) or 0) * 100 + 0.5) end
      ),
      emit = custom("nousDFiveEnergyBalanceAdd"),
    }),
    tuya.dp_numeric(15, {
      name = "nous_d_five_leakage_current",
      read_only = true,
      transaction = 1,
      emit = custom("nousDFiveLeakageCurrent"),
    }),
    tuya.dp_on_off(16, {
      name = "switch",
      component = "main",
      transaction = 1,
      handler = d_five_switch_side_effects,
      emit = emit.switch(),
    }),
    alarm_shadow(ALARM_GROUPS.one, "nous_d_five_alarm_set_one_raw"),
    alarm_mapping(ALARM_GROUPS.one, 4, "enabled", "nous_d_five_leakage_alarm", custom("nousDFiveLeakageAlarm")),
    alarm_mapping(ALARM_GROUPS.one, 4, "value", "nous_d_five_leakage_threshold", custom("nousDFiveLeakageThreshold")),
    alarm_mapping(ALARM_GROUPS.one, 5, "enabled", "nous_d_five_temperature_alarm", custom("nousDFiveTemperatureAlarm")),
    alarm_mapping(ALARM_GROUPS.one, 5, "value", "nous_d_five_temperature_threshold", custom("nousDFiveTemperatureThreshold")),
    alarm_shadow(ALARM_GROUPS.two, "nous_d_five_alarm_set_two_raw"),
    alarm_mapping(ALARM_GROUPS.two, 1, "enabled", "nous_d_five_over_current_alarm", custom("nousDFiveOverCurrentAlarm")),
    alarm_mapping(ALARM_GROUPS.two, 1, "value", "nous_d_five_over_current_threshold", custom("nousDFiveOverCurrentThreshold")),
    alarm_mapping(ALARM_GROUPS.two, 3, "enabled", "nous_d_five_over_voltage_alarm", custom("nousDFiveOverVoltageAlarm")),
    alarm_mapping(ALARM_GROUPS.two, 3, "value", "nous_d_five_over_voltage_threshold", custom("nousDFiveOverVoltageThreshold")),
    alarm_mapping(ALARM_GROUPS.two, 4, "enabled", "nous_d_five_under_voltage_alarm", custom("nousDFiveUnderVoltageAlarm")),
    alarm_mapping(ALARM_GROUPS.two, 4, "value", "nous_d_five_under_voltage_threshold", custom("nousDFiveUnderVoltageThreshold")),
    tuya.dp_numeric(102, { name = "nous_d_five_reclosing_count", transaction = 1, emit = custom("nousDFiveReclosingCount") }),
    tuya.dp_temperature(103, { name = "temperature", scale = 1, read_only = true, transaction = 1, emit = emit.temperature("C") }),
    tuya.dp_binary(104, { name = "nous_d_five_reclosing", transaction = 1, converter = on_off_converter, emit = custom("nousDFiveReclosing") }),
    tuya.dp_numeric(105, { name = "nous_d_five_countdown", transaction = 1, emit = d_five_countdown_emitter }),
    tuya.dp_raw(106, { name = "nous_d_five_cycle_schedule", read_only = true, transaction = 1 }),
    tuya.dp_numeric(107, { name = "nous_d_five_reclosing_delay", transaction = 1, emit = custom("nousDFiveReclosingDelay") }),
    tuya.dp_numeric(108, { name = "nous_d_five_random_timing", read_only = true, transaction = 1 }),
    inching_mapping("state", "nous_d_five_inching_state", custom("nousDFiveInchingState")),
    inching_mapping("minutes", "nous_d_five_inching_minutes", custom("nousDFiveInchingMinutes")),
    inching_mapping("seconds", "nous_d_five_inching_seconds", custom("nousDFiveInchingSeconds")),
    tuya.dp_energy(110, {
      name = "nous_d_five_produced_energy",
      scale = 100,
      read_only = true,
      transaction = 1,
      emit = custom("nousDFiveProducedEnergy"),
    }),
    tuya.dp_numeric(119, { name = "nous_d_five_power_on_delay", read_only = true, transaction = 1 }),
    tuya.dp_numeric(124, { name = "nous_d_five_over_current_time", transaction = 1, emit = custom("nousDFiveOverCurrentTime") }),
    tuya.dp_numeric(125, { name = "nous_d_five_lost_flow_time", transaction = 1, emit = custom("nousDFiveLostFlowTime") }),
    alarm_shadow(ALARM_GROUPS.three, "nous_d_five_alarm_set_three_raw"),
    alarm_mapping(ALARM_GROUPS.three, 3, "enabled", "nous_d_five_lost_flow_alarm", custom("nousDFiveLostFlowAlarm")),
    alarm_mapping(ALARM_GROUPS.three, 3, "value", "nous_d_five_lost_flow_threshold", custom("nousDFiveLostFlowThreshold")),
    tuya.dp_enum(127, {
      name = "nous_d_five_status",
      read_only = true,
      transaction = 1,
      converter = converter.lookup_from_to({ off = 0, consumption = 1, production = 2 }),
      emit = custom("nousDFiveStatus"),
    }),
    tuya.dp_enum(134, {
      name = "nous_d_five_power_on_behavior",
      transaction = 1,
      converter = converter.lookup_from_to({ off = 0, on = 1, previous = 2 }),
      emit = custom("nousDFivePowerOnBehavior"),
    }),
  },
}

register_device_definition(d_five, {
  device_helpers.create_fingerprint("_TZE204_t9ffmdin", "TS0601"),
})

-- QA QASZP ------------------------------------------------------------------

local qa_qaszp = {
  profile = "meters-wave19-qa-qaszp",
  package_group = "wave19-energy",
  transport_classification = "HYBRID_ZCL_EF00",
  z2m_converter_source = "fromZigbee electrical_measurement/metering + meta.tuyaDatapoints",
  wire_cluster = "manuSpecificTuya + ElectricalMeasurement + SimpleMetering",
  magic_packet = true,
  query_on_configure = false,
  named_datapoints = true,
  time_start = "off",
  placeholder_custom_states = false,
  datapoints = {
    tuya.dp_energy(17, { name = "energy", scale = 1000, read_only = true, command_id = tuya.SEND_DATA, transaction = 1, emit = emit.energy() }),
    tuya.dp_current(18, { name = "current", scale = 1000, read_only = true, command_id = tuya.SEND_DATA, transaction = 1, emit = emit.current() }),
    tuya.dp_numeric(19, {
      name = "power",
      read_only = true,
      command_id = tuya.SEND_DATA,
      transaction = 1,
      converter = converter.divide_by_pair(10),
      emit = emit.power(),
    }),
    tuya.dp_voltage(20, { name = "voltage", scale = 10, read_only = true, command_id = tuya.SEND_DATA, transaction = 1, emit = emit.voltage() }),
    tuya.dp_numeric(101, {
      name = "qa_qaszp_reactive_power_threshold",
      command_id = tuya.SEND_DATA,
      transaction = 1,
      converter = converter.divide_by_pair(10),
      emit = custom("qaQaszpReactivePowerThreshold"),
    }),
    tuya.dp_numeric(102, {
      name = "qa_qaszp_max_effective_power",
      command_id = tuya.SEND_DATA,
      transaction = 1,
      converter = converter.divide_by_pair(10),
      emit = custom("qaQaszpMaxEffectivePower"),
    }),
    tuya.dp_binary(104, {
      name = "qa_qaszp_status_report",
      command_id = tuya.SEND_DATA,
      transaction = 1,
      converter = on_off_converter,
      emit = custom("qaQaszpStatusReport"),
    }),
    tuya.dp_binary(105, {
      name = "qa_qaszp_switch_status",
      read_only = true,
      command_id = tuya.SEND_DATA,
      transaction = 1,
      converter = on_off_converter,
      emit = custom("qaQaszpSwitchStatus"),
    }),
  },
  zcl_clusters = {
    zcl.voltage({ endpoint = 1, read_only = true, configure_reporting = false, read_on_configure = false, poll_interval = 60 }),
    zcl.current({ endpoint = 1, read_only = true, configure_reporting = false, read_on_configure = false, poll_interval = 60 }),
    zcl.power({ endpoint = 1, read_only = true, configure_reporting = false, read_on_configure = false, poll_interval = 60 }),
    -- electricityMeasurementPoll() does not request SimpleMetering; retain only
    -- the frozen fromZigbee report path for energy.
    zcl.energy({ endpoint = 1, read_only = true, configure_reporting = false, read_on_configure = false, poll_interval = 0 }),
  },
}

register_device_definition(qa_qaszp, {
  device_helpers.create_fingerprint("_TZ3218_kwht8j5m", "TS011F"),
})

return {
  id = "ef00.din_rail.wave19_energy",
  registrations = device_definitions,
}
