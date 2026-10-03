local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local capabilities = require "st.capabilities"
local data_types = require "st.zigbee.data_types"
local cluster_base = require "st.zigbee.cluster_base"

local device_definitions, register_device_definition = device_helpers.definition_registry()
local MFG_CODE = 0x115F

-- W500 firmware uses the low 16 float bits as beta, including on preset writes.
local function ntc_beta_to_device(beta)
  local closest, closest_high
  for high = 0x3F80, 0x47FF do
    local candidate = string.unpack(">f", string.pack(">I2I2", high, beta))
    if candidate ~= math.floor(candidate) and
        (closest == nil or math.abs(candidate - beta) < math.abs(closest - beta)) then
      closest, closest_high = candidate, high
    end
  end
  local exponent = math.floor(closest_high / 128) - 127
  local mantissa = ((closest_high % 128) * 65536 + beta) / 8388608
  return data_types.SinglePrecisionFloat(0, exponent, mantissa)
end

local function ntc_beta_from_device(value)
  if value == math.floor(value) then return value end
  return string.unpack(">I2", string.pack(">f", value), 3)
end

local function ntc_sensor_type(device, context)
  if context then
    for _, record in ipairs(context.zb_rx.body.zcl_body.attr_records or {}) do
      if record.data and record.attr_id.value == 0x0315 then
        local value = record.data.value
        device:set_field("aqw500_ntc_r25", value >= 1000 and value / 1000 or value, { persist = true })
      elseif record.data and record.attr_id.value == 0x0316 then
        device:set_field("aqw500_ntc_beta", ntc_beta_from_device(record.data.value), { persist = true })
      end
    end
  end
  local r25, beta = device:get_field("aqw500_ntc_r25"), device:get_field("aqw500_ntc_beta")
  if beta == nil or beta == 3950 then
    return ({ [10] = "ntc_10k", [50] = "ntc_50k", [100] = "ntc_100k" })[r25] or "custom"
  end
  return "custom"
end

local function ntc_r25_from_device(value, device)
  local resistance = value >= 1000 and value / 1000 or value
  device:set_field("aqw500_ntc_r25", resistance, { persist = true })
  return resistance
end

local function ntc_beta_report(value, device)
  local beta = ntc_beta_from_device(value)
  device:set_field("aqw500_ntc_beta", beta, { persist = true })
  return beta
end

local function ntc_sensor_sender(device, mapping, value)
  local r25 = ({ ntc_10k = 10, ntc_50k = 50, ntc_100k = 100 })[value]
  local beta = 3950
  if value == "custom" then
    r25, beta = device:get_field("aqw500_ntc_r25"), device:get_field("aqw500_ntc_beta")
    if r25 == nil or beta == nil then return false end
  end
  device:send(cluster_base.write_manufacturer_specific_attribute(
    device, 0xFCC0, 0x0315, MFG_CODE, data_types.Uint32, r25):to_endpoint(1))
  device:send(cluster_base.write_manufacturer_specific_attribute(
    device, 0xFCC0, 0x0316, MFG_CODE, data_types.SinglePrecisionFloat, ntc_beta_to_device(beta)):to_endpoint(1))
  device:set_field("aqw500_ntc_r25", r25, { persist = true })
  device:set_field("aqw500_ntc_beta", beta, { persist = true })
  device:emit_component_event({ id = "main" }, emit.aqW500NtcR25()(device, r25))
  device:emit_component_event({ id = "main" }, emit.aqW500NtcBeta()(device, beta))
  device:emit_component_event({ id = "main" }, emit.aqW500NtcSensorType()(device, value))
  return true
end

local aqara_w500 = {
  profile = "thermostats-aqara-w500",
  thermostat_supported_modes = { "off", "heat" },
  heating_setpoint_range = { minimum = 5, maximum = 40, step = 0.5, unit = "C" },
  runtime_start = function(device)
    device:emit_component_event({ id = "main" }, capabilities.thermostatMode.supportedThermostatModes({ "off", "heat" }))
    device:emit_component_event({ id = "main" }, capabilities.thermostatHeatingSetpoint.heatingSetpointRange({
      value = { minimum = 5, maximum = 40, step = 0.5 }, unit = "C",
    }))
  end,
  zcl_clusters = {
    zcl.local_temperature({ endpoint = 1, read_only = true, minimum_interval = 0, maximum_interval = 3600, reportable_change = 10 }),
    zcl.thermostat_heating_setpoint({
      name = "current_heating_setpoint", endpoint = 1, scale = 100,
      emit = emit.heating_setpoint("C"), read_on_configure = false,
      to_device = function(value) return math.max(5, math.min(40, math.floor(value * 2 + 0.5) / 2)) end,
    }),
    zcl.system_mode({ endpoint = 1, minimum_interval = 0, maximum_interval = 3600,
      from_device = function(value)
        value = type(value) == "table" and value.value or value
        return ({ [0] = "off", [4] = "heat" })[value]
      end,
      to_device = function(value) return ({ off = 0, heat = 4 })[value] end,
    }),
    zcl.thermostat_operating_state({ endpoint = 1, read_only = true, minimum_interval = 0, maximum_interval = 3600 }),
    zcl.relative_humidity({ endpoint = 1, read_only = true, scale = 100,
      emit = emit.humidity(), read_on_configure = true }),
    zcl.cluster_attribute(0x0B04, 0x050B, {
      name = "power", endpoint = 1, data_type = data_types.Int16, scale = 1,
      emit = emit.power(), read_only = true, read_on_configure = true,
      minimum_interval = 10, maximum_interval = 65000, reportable_change = 5,
    }),
    zcl.cluster_attribute(0x0702, 0x0000, {
      name = "energy", endpoint = 1, data_type = data_types.Uint48, scale = 1000,
      emit = emit.energy(), read_only = true, read_on_configure = true,
      minimum_interval = 10, maximum_interval = 65000, reportable_change = 100,
    }),
    zcl.cluster_attribute(0x0201, 0x0010, {
      name = "aqw500_temperature_calibration", endpoint = 1, data_type = data_types.Int8,
      emit = emit.aqW500TemperatureCalibration(), read_on_configure = true,
      from_device = function(value) return value / 10 end,
      to_device = function(value) return math.floor(value * 10 + 0.5) end,
    }),
    zcl.cluster_attribute(0x0201, 0x0023, {
      name = "aqw500_setpoint_hold", endpoint = 1, data_type = data_types.Enum8,
      emit = emit.aqW500SetpointHold(), read_on_configure = false,
      from_device = function(value)
        value = type(value) == "table" and value.value or value
        return ({ [0] = "disabled", [1] = "enabled" })[value]
      end,
      to_device = function(value) return ({ disabled = 0, enabled = 1 })[value] end,
    }),
    zcl.cluster_attribute(0x0201, 0x0024, {
      name = "aqw500_hold_duration", endpoint = 1, data_type = data_types.Uint16,
      emit = emit.aqW500HoldDuration(), read_on_configure = true,
    }),
    zcl.cluster_attribute(0x0201, 0x0015, {
      name = "aqw500_min_heat_setpoint", endpoint = 1, data_type = data_types.Int16,
      emit = emit.aqW500MinHeatSetpoint(), read_on_configure = true,
      from_device = function(value) return value / 100 end,
      to_device = function(value) return math.floor(value * 100 + 0.5) end,
    }),
    zcl.cluster_attribute(0x0201, 0x0016, {
      name = "aqw500_max_heat_setpoint", endpoint = 1, data_type = data_types.Int16,
      emit = emit.aqW500MaxHeatSetpoint(), read_on_configure = true,
      from_device = function(value) return value / 100 end,
      to_device = function(value) return math.floor(value * 100 + 0.5) end,
    }),
    zcl.cluster_attribute(0xFCC0, 0x0311, {
      name = "aqw500_preset", endpoint = 1, mfg_code = MFG_CODE, data_type = data_types.Uint8,
      emit = emit.aqW500Preset(), read_on_configure = true,
      from_device = function(value) return ({ [1] = "home", [2] = "away", [3] = "sleep", [5] = "vacation", [6] = "evening", [8] = "manual" })[value] end,
      to_device = function(value) return ({ home = 1, away = 2, sleep = 3, vacation = 5, evening = 6, manual = 8 })[value] end,
    }),
    zcl.cluster_attribute(0xFCC0, 0x0310, {
      name = "aqw500_work_state", endpoint = 1, mfg_code = MFG_CODE, data_type = data_types.Uint8,
      emit = emit.aqW500WorkState(), read_only = true, read_on_configure = true,
      from_device = function(value) return ({ [0] = "working", [2] = "idle" })[value] end,
    }),
    zcl.cluster_attribute(0xFCC0, 0x0280, {
      name = "aqw500_sensor_source", endpoint = 1, mfg_code = MFG_CODE, data_type = data_types.Uint8,
      emit = emit.aqW500SensorSource(), read_on_configure = true,
      from_device = function(value) return ({ [0] = "internal", [1] = "external", [2] = "ntc" })[value] end,
      to_device = function(value) return ({ internal = 0, external = 1, ntc = 2 })[value] end,
    }),
    zcl.cluster_attribute(0xFCC0, 0x0315, {
      name = "aqw500_ntc_sensor_type", endpoint = 1, mfg_code = MFG_CODE, data_type = data_types.Uint32,
      write_only = true, suppress_optimistic_state = true, sender = ntc_sensor_sender,
    }),
    zcl.cluster_attribute(0xFCC0, 0x0315, {
      name = "aqw500_ntc_r25", endpoint = 1, mfg_code = MFG_CODE, data_type = data_types.Uint32,
      from_device = ntc_r25_from_device,
      to_device = function(value, device)
        device:set_field("aqw500_ntc_r25", value, { persist = true })
        device:emit_component_event({ id = "main" }, emit.aqW500NtcSensorType()(device, ntc_sensor_type(device)))
        return value
      end,
      emit = function(device, value, context)
        return { emit.aqW500NtcR25()(device, value), emit.aqW500NtcSensorType()(device, ntc_sensor_type(device, context)) }
      end,
    }),
    zcl.cluster_attribute(0xFCC0, 0x0316, {
      name = "aqw500_ntc_beta", endpoint = 1, mfg_code = MFG_CODE, data_type = data_types.SinglePrecisionFloat,
      from_device = ntc_beta_report,
      to_device = function(value, device)
        device:set_field("aqw500_ntc_beta", value, { persist = true })
        device:emit_component_event({ id = "main" }, emit.aqW500NtcSensorType()(device, ntc_sensor_type(device)))
        return ntc_beta_to_device(value)
      end,
      emit = function(device, value, context)
        return { emit.aqW500NtcBeta()(device, value), emit.aqW500NtcSensorType()(device, ntc_sensor_type(device, context)) }
      end,
    }),
    zcl.cluster_attribute(0xFCC0, 0x0273, {
      name = "aqw500_window_detection", endpoint = 1, mfg_code = MFG_CODE, data_type = data_types.Uint8,
      emit = emit.aqW500WindowDetection(), read_on_configure = true,
      from_device = function(value) return ({ [0] = "OFF", [1] = "ON" })[value] end,
      to_device = function(value) return ({ OFF = 0, ON = 1 })[value] end,
    }),
    zcl.cluster_attribute(0xFCC0, 0x0201, {
      name = "aqw500_power_outage_memory", endpoint = 1, mfg_code = MFG_CODE, data_type = data_types.Boolean,
      emit = emit.aqW500PowerOutageMemory(), read_on_configure = true,
      from_device = function(value) return value and "enabled" or "disabled" end,
      to_device = function(value) return value == "enabled" end,
    }),
    zcl.cluster_attribute(0xFCC0, 0x0277, {
      name = "aqw500_child_lock", endpoint = 1, mfg_code = MFG_CODE, data_type = data_types.Uint8,
      emit = emit.aqW500ChildLock(), read_on_configure = true,
      from_device = function(value) return ({ [0] = "UNLOCK", [1] = "LOCK" })[value] end,
      to_device = function(value) return ({ UNLOCK = 0, LOCK = 1 })[value] end,
    }),
    zcl.cluster_attribute(0xFCC0, 0x030C, {
      name = "aqw500_hysteresis", endpoint = 1, mfg_code = MFG_CODE, data_type = data_types.Uint8,
      emit = emit.aqW500Hysteresis(), read_on_configure = true,
      from_device = function(value) return value / 10 end,
      to_device = function(value) return math.floor(value * 10 + 0.5) end,
    }),
    zcl.cluster_attribute(0x0003, 0xFFFF, {
      name = "aqw500_identify", endpoint = 1, write_only = true, suppress_optimistic_state = true,
      tx_command_id = 0, to_device = function() return string.char(3, 0) end,
    }),
  },
  configure = function(driver, device)
    for _, cluster in ipairs({ 0x0201, 0x0B04, 0x0702 }) do
      zcl.bind_cluster(device, cluster, driver.environment_info.hub_zigbee_eui, 1)
    end
  end,
}

register_device_definition(aqara_w500, {
  device_helpers.create_fingerprint("Aqara", "lumi.airrtc.aeu001"),
})

return {
  id = "zcl.thermostats.aqara_w500",
  registrations = device_definitions,
}
