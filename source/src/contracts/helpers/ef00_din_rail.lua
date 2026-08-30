-- Shared DIN rail converters used by both package-owned registries.

local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"

local converter = tuya.converter
local emit_voltage = emit.voltage()
local emit_current = emit.current()
local emit_power = emit.power()

local function is_metric_field(field_name, metric)
  return type(field_name) == "string" and
    (field_name == metric or field_name:sub(1, #metric + 1) == metric .. "_")
end

local function metric_value(value, metric, mapping_context)
  local mapping = type(mapping_context) == "table" and mapping_context.mapping or nil
  local fields = type(mapping) == "table" and mapping.fields or nil

  if type(fields) == "table" then
    for field_name, source_key in pairs(fields) do
      local key = source_key == true and field_name or source_key
      if type(key) == "string" and
         (is_metric_field(field_name, metric) or is_metric_field(key, metric)) and
         value[key] ~= nil then
        return value[key]
      end
    end
  end

  return value[metric]
end

local function emit_metric_bundle(options)
  options = options or {}

  return function(_, value, _, mapping_context)
    if type(value) ~= "table" then
      return nil
    end

    local events = {}
    local voltage = metric_value(value, "voltage", mapping_context)
    local current = metric_value(value, "current", mapping_context)
    local power = metric_value(value, "power", mapping_context)

    if options.voltage and voltage ~= nil then
      events[#events + 1] = emit_voltage(nil, voltage)
    end

    if options.current and current ~= nil then
      events[#events + 1] = emit_current(nil, current)
    end

    if options.power and power ~= nil then
      events[#events + 1] = emit_power(nil, power)
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

return {
  emit_metric_bundle = emit_metric_bundle,
  circuit_breaker_faults_converter = circuit_breaker_faults_converter,
  BREAKER_EVENT_LOOKUP = BREAKER_EVENT_LOOKUP,
}
