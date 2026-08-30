-- Wave19 exact-only Sber SBDV-00205 thermostat candidate.
-- Frozen Zigbee2MQTT v26.99.0 (df7200535e381f70023013f96791e424b6ac7b0e):
--   src/devices/sber.ts:1-225,450-1135,1290-1395,2296-2564
--   src/converters/fromZigbee.ts thermostat/temperature/UI converters
--   src/converters/toZigbee.ts thermostat writers

local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local capabilities = require "st.capabilities"
local device_management = require "st.zigbee.device_management"
local data_types = require "st.zigbee.data_types"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local NAMESPACE = "concertmirror08464."
local SBER_MFG_CODE = 0x152F
local CLUSTER_BASIC = 0x0000
local CLUSTER_DEVICE_TEMPERATURE = 0x0002
local CLUSTER_IDENTIFY = 0x0003
local CLUSTER_TEMPERATURE = 0x0402
local CLUSTER_THERMOSTAT = 0x0201
local CLUSTER_UI = 0x0204
local CLUSTER_DIAGNOSTICS = 0x0B05
local CLUSTER_SBER = 0xFCCF

local function custom(capability_id)
  return assert(emit[capability_id], "missing Wave19 Sber emitter: " .. capability_id)()
end

local function copy(options)
  local result = {}
  for key, value in pairs(options or {}) do result[key] = value end
  return result
end

local function append(target, mapping)
  target[#target + 1] = mapping
  return mapping
end

local function mapping(cluster, attribute, name, capability_id, data_type, options)
  local config = copy(options)
  config.name = name
  config.emit = custom(capability_id)
  config.data_type = data_type
  config.write_type = config.write_type or data_type
  config.endpoint = config.endpoint or 1
  return zcl.cluster_attribute(cluster, attribute, config)
end

local function manufacturer_mapping(cluster, attribute, name, capability_id, data_type, options)
  local config = copy(options)
  config.mfg_code = SBER_MFG_CODE
  return mapping(cluster, attribute, name, capability_id, data_type, config)
end

local function sber_mapping(attribute, name, capability_id, data_type, options)
  return manufacturer_mapping(CLUSTER_SBER, attribute, name, capability_id, data_type, options)
end

local function active_bit(mask)
  return function(value)
    return bit32.band(tonumber(value) or 0, mask) ~= 0 and "active" or "clear"
  end
end

local function lookup(from)
  local to = {}
  for raw, value in pairs(from) do to[value] = raw end
  return function(value) return from[tonumber(value)] end,
    function(value) return to[value] end
end

local function round_half(value)
  local numeric = tonumber(value)
  if numeric == nil then return nil end
  return math.floor(numeric * 2 + 0.5) / 2
end

local function clamp(value, minimum, maximum)
  local numeric = tonumber(value)
  if numeric == nil then return nil end
  return math.max(minimum, math.min(maximum, numeric))
end

local function u16le(value)
  local numeric = math.floor(tonumber(value) or 0)
  if numeric < 0 then numeric = numeric + 0x10000 end
  return string.char(numeric % 0x100, math.floor(numeric / 0x100) % 0x100)
end

local function read(device, cluster, attribute, mfg_code)
  zcl.read_attribute(device, cluster, attribute, 1, mfg_code)
end

local function read_many(device, cluster, attributes, mfg_code)
  for _, attribute in ipairs(attributes) do read(device, cluster, attribute, mfg_code) end
end

local function bind(device, hub_eui, clusters)
  for _, cluster in ipairs(clusters) do
    device:send(device_management.build_bind_request(device, cluster, hub_eui, 1))
  end
end

local function identify_sender(device, _, _, context)
  return zcl.send_raw_cluster_command(
    device, CLUSTER_IDENTIFY, 0x00, u16le(3), context.endpoint or 1, nil, nil, false
  )
end

local function clear_schedule_sender(device, _, _, context)
  return zcl.send_raw_cluster_command(
    device, CLUSTER_THERMOSTAT, 0x03, "", context.endpoint or 1, nil, nil, false
  )
end

local DAYS = {
  { "Sunday", "sunday", 0x01 },
  { "Monday", "monday", 0x02 },
  { "Tuesday", "tuesday", 0x04 },
  { "Wednesday", "wednesday", 0x08 },
  { "Thursday", "thursday", 0x10 },
  { "Friday", "friday", 0x20 },
  { "Saturday", "saturday", 0x40 },
}

local function query_weekly_schedule(device, endpoint)
  for _, day in ipairs(DAYS) do
    zcl.send_raw_cluster_command(
      device, CLUSTER_THERMOSTAT, 0x02, string.char(day[3], 0x01),
      endpoint or 1, nil, nil, true
    )
  end
end

local function split_words(value)
  local result = {}
  for token in string.gmatch(value, "%S+") do result[#result + 1] = token end
  table.sort(result)
  return result
end

local function parse_transition(token)
  local hour, minute, temperature = token:match("^(%d%d):(%d%d)/(%d+%.?%d*)$")
  hour, minute, temperature = tonumber(hour), tonumber(minute), tonumber(temperature)
  if hour == nil or minute == nil or temperature == nil or hour > 23 or minute > 59
    or temperature < 1 or temperature > 50 or temperature * 2 % 1 ~= 0 then
    return nil
  end
  return hour * 60 + minute, math.floor(temperature * 100 + 0.5)
end

local function weekly_sender(day_mask)
  return function(device, _, value, context)
    if type(value) ~= "string" then return false end
    local transitions = value == "" and {} or split_words(value)
    if #transitions > 10 then return false end
    local fields = { string.char(#transitions, day_mask, 0x01) }
    for _, token in ipairs(transitions) do
      local minutes, setpoint = parse_transition(token)
      if minutes == nil then return false end
      fields[#fields + 1] = u16le(minutes)
      fields[#fields + 1] = u16le(setpoint)
    end
    local endpoint = context.endpoint or 1
    local sent = zcl.send_raw_cluster_command(
      device, CLUSTER_THERMOSTAT, 0x01, table.concat(fields), endpoint, nil, nil, false
    )
    if sent then query_weekly_schedule(device, endpoint) end
    return sent
  end
end

local function weekly_response(day_mask)
  return function(zb_rx)
    local zcl_body = zb_rx and zb_rx.body and zb_rx.body.zcl_body or nil
    local function scalar(value)
      if type(value) == "table" and value.value ~= nil then return tonumber(value.value) end
      return tonumber(value)
    end
    local transitions = {}

    -- SmartThings decodes this standard command into typed named fields.
    local count = zcl_body and scalar(zcl_body.number_of_transitions) or nil
    local day = zcl_body and scalar(zcl_body.day_of_week) or nil
    local mode = zcl_body and scalar(zcl_body.mode) or nil
    local parsed = zcl_body and zcl_body.transitions_list or nil
    if count ~= nil and day ~= nil and mode ~= nil and type(parsed) == "table" then
      if count % 1 ~= 0 or count < 0 or count > 10 or bit32.band(day, day_mask) == 0
        or bit32.band(mode, 0x01) == 0 or count > #parsed then return nil end
      for index = 1, count do
        local transition = parsed[index]
        local minutes = transition and scalar(transition.transition_time) or nil
        local setpoint = transition and scalar(transition.heat_set_point) or nil
        if minutes == nil or minutes % 1 ~= 0 or minutes < 0 or minutes > 1439
          or setpoint == nil or setpoint < 100 or setpoint > 5000 then return nil end
        transitions[#transitions + 1] = string.format(
          "%02d:%02d/%g", math.floor(minutes / 60), minutes % 60, setpoint / 100
        )
      end
    else
      -- Retain a raw-body fallback for runtimes which have not decoded command 0x00.
      local body = zcl_body and zcl_body.body_bytes or nil
      if type(body) ~= "string" or #body < 3 or bit32.band(string.byte(body, 2), day_mask) == 0 then return nil end
      count = string.byte(body, 1)
      mode = string.byte(body, 3)
      if count > 10 or bit32.band(mode, 0x01) == 0 or #body < 3 + count * 4 then return nil end
      for index = 0, count - 1 do
        local offset = 4 + index * 4
        local minutes = string.byte(body, offset) + string.byte(body, offset + 1) * 0x100
        local setpoint = string.byte(body, offset + 2) + string.byte(body, offset + 3) * 0x100
        if setpoint >= 0x8000 then setpoint = setpoint - 0x10000 end
        if minutes > 1439 or setpoint < 100 or setpoint > 5000 then return nil end
        transitions[#transitions + 1] = string.format(
          "%02d:%02d/%g", math.floor(minutes / 60), minutes % 60, setpoint / 100
        )
      end
    end
    table.sort(transitions)
    return table.concat(transitions, " ")
  end
end

local mappings = {}
local commands = {}

-- Definition-local alarm and status converters.
for _, item in ipairs({
  { 0x3001, "emergency_overcurrent", "EmergencyOvercurrent", 0x04, CLUSTER_SBER },
  { 0x3001, "emergency_overheat", "EmergencyOverheat", 0x08, CLUSTER_SBER },
  { 0x3001, "emergency_no_load", "EmergencyNoLoad", 0x10, CLUSTER_SBER },
}) do
  append(mappings, sber_mapping(
    item[1], "sber_therm_" .. item[2], "sberTherm" .. item[3], data_types.Bitmap16,
    { read_only = true, from_device = active_bit(item[4]), read_on_configure = false }
  ))
end

for _, item in ipairs({
  { 0x4102, "sensor_error_remote_disconnected", "RemoteDisconnected", 0x01 },
  { 0x4102, "sensor_error_local_disconnected", "SensorLocalDisconnected", 0x02 },
  { 0x4102, "sensor_error_short_circuit", "SensorShortCircuit", 0x04 },
  { 0x4103, "status_heat_inefficient", "HeatInefficient", 0x01 },
  { 0x4103, "status_antifrost", "Antifrost", 0x02 },
  { 0x4103, "status_invalid_time", "InvalidTime", 0x08 },
}) do
  append(mappings, manufacturer_mapping(
    CLUSTER_THERMOSTAT, item[1], "sber_therm_" .. item[2],
    "sberTherm" .. item[3], data_types.Bitmap16,
    { read_only = true, from_device = active_bit(item[4]), read_on_configure = false }
  ))
end

local keypad_from, keypad_to = lookup({ [0] = "unlock", [1] = "lock1" })
append(mappings, mapping(CLUSTER_UI, 0x0001, "sber_therm_keypad_lockout", "sberThermKeypadLockout", data_types.Enum8, {
  from_device = keypad_from, to_device = keypad_to, numeric_range = nil, read_on_configure = false,
}))

-- Standard thermostat features plus exact family-specific companions.
append(mappings, zcl.cluster_attribute(CLUSTER_THERMOSTAT, 0x0012, {
  name = "current_heating_setpoint", endpoint = 1,
  emit = emit.heating_setpoint("C"), data_type = data_types.Int16, write_type = data_types.Int16,
  scale = 100, to_device = round_half,
  numeric_range = { minimum = 1, maximum = 50, step = 0.5, unit = "C" },
  read_on_configure = false,
}))
append(mappings, zcl.cluster_attribute(CLUSTER_THERMOSTAT, 0x0000, {
  name = "local_temperature", endpoint = 1, read_only = true,
  emit = emit.temperature("C"), data_type = data_types.Int16, scale = 100,
  read_on_configure = false,
}))
local system_from, system_to = lookup({ [0] = "off", [4] = "heat", [9] = "asleep" })
append(mappings, zcl.cluster_attribute(CLUSTER_THERMOSTAT, 0x001C, {
  name = "system_mode", endpoint = 1, emit = emit.thermostat_mode(),
  data_type = data_types.Enum8, write_type = data_types.Enum8,
  from_device = system_from, to_device = system_to, read_on_configure = false,
}))
append(mappings, zcl.cluster_attribute(CLUSTER_THERMOSTAT, 0x0029, {
  name = "thermostat_operating_state", endpoint = 1, read_only = true,
  emit = emit.thermostat_operating_state(), data_type = data_types.Bitmap16,
  from_device = function(value) return bit32.band(tonumber(value) or 0, 0x01) ~= 0 and "heating" or "idle" end,
  read_on_configure = false,
}))
append(mappings, mapping(CLUSTER_THERMOSTAT, 0x0010, "sber_therm_local_calibration", "sberThermLocalCalibration", data_types.Int8, {
  scale = 10, numeric_range = { minimum = -2.5, maximum = 2.5, step = 0.1, unit = "C" },
  read_on_configure = false,
}))
local control_from, control_to = lookup({ [2] = "heating_only" })
append(mappings, mapping(CLUSTER_THERMOSTAT, 0x001B, "sber_therm_control_sequence", "sberThermControlSequence", data_types.Enum8, {
  from_device = control_from, to_device = control_to, read_on_configure = false,
}))
local running_mode_from = function(value) return ({ [0] = "off", [4] = "heat" })[tonumber(value)] end
append(mappings, mapping(CLUSTER_THERMOSTAT, 0x001E, "sber_therm_running_mode", "sberThermRunningMode", data_types.Enum8, {
  read_only = true, from_device = running_mode_from, read_on_configure = false,
}))
local programming_from, programming_to = lookup({ [0] = "setpoint", [1] = "schedule" })
append(mappings, mapping(CLUSTER_THERMOSTAT, 0x0025, "sber_therm_programming_mode", "sberThermProgrammingMode", data_types.Bitmap8, {
  from_device = programming_from, to_device = programming_to, read_on_configure = false,
}))

append(mappings, mapping(CLUSTER_THERMOSTAT, 0x0003, "sber_therm_abs_min_heat_limit", "sberThermAbsMinHeatLimit", data_types.Int16, {
  read_only = true, scale = 100, read_on_configure = false,
}))
append(mappings, mapping(CLUSTER_THERMOSTAT, 0x0004, "sber_therm_abs_max_heat_limit", "sberThermAbsMaxHeatLimit", data_types.Int16, {
  read_only = true, scale = 100, read_on_configure = false,
}))
append(mappings, mapping(CLUSTER_THERMOSTAT, 0x0015, "sber_therm_min_heat_limit", "sberThermMinHeatLimit", data_types.Int16, {
  scale = 100, to_device = round_half,
  numeric_range = { minimum = 1, maximum = 35, step = 0.5, unit = "C" }, read_on_configure = false,
}))
append(mappings, mapping(CLUSTER_THERMOSTAT, 0x0016, "sber_therm_max_heat_limit", "sberThermMaxHeatLimit", data_types.Int16, {
  scale = 100, to_device = round_half,
  numeric_range = { minimum = 5, maximum = 50, step = 0.5, unit = "C" }, read_on_configure = false,
}))

append(mappings, zcl.cluster_attribute(CLUSTER_THERMOSTAT, nil, {
  name = "sber_therm_clear_schedule", endpoint = 1, write_only = true, sender = clear_schedule_sender,
}))
commands[#commands + 1] = {
  capability_id = NAMESPACE .. "sberThermClearSchedule", command_name = "clear",
  value = true, mapping_name = "sber_therm_clear_schedule",
}

for index, day in ipairs(DAYS) do
  local name = "sber_therm_" .. day[2] .. "_schedule"
  append(mappings, zcl.cluster_attribute(CLUSTER_THERMOSTAT, 0xF200 + index, {
    name = name, endpoint = 1, emit = custom("sberTherm" .. day[1] .. "Schedule"),
    read_only = false, data_type = data_types.CharString, write_type = data_types.CharString,
    sender = weekly_sender(day[3]), command_id = 0x00,
    command_extractor = weekly_response(day[3]), read_on_configure = false,
  }))
end

-- Manufacturer thermostat attributes.
for _, field in ipairs({
  { 0x40F0, "min_local_temperature", "MinLocalTemperature", data_types.Int16, 100, 1, 35, 0.01, "C" },
  { 0x40F1, "max_local_temperature", "MaxLocalTemperature", data_types.Int16, 100, 5, 50, 0.01, "C" },
  { 0x4019, "heating_hysteresis", "HeatingHysteresis", data_types.Int8, 10, 1, 10, 0.1, "C" },
  { 0x4001, "remote_temperature", "RemoteTemperature", data_types.Int16, 100, -273.15, 327.67, 0.01, "C" },
  { 0x4002, "remote_calibration", "RemoteCalibration", data_types.Int8, 10, -12.8, 12.7, 0.1, "C" },
  { 0x4203, "remote_sensor_timeout", "RemoteSensorTimeout", data_types.Uint16, 1, 1, 65535, 1, "s" },
}) do
  append(mappings, manufacturer_mapping(
    CLUSTER_THERMOSTAT, field[1], "sber_therm_" .. field[2],
    "sberTherm" .. field[3], field[4], {
      scale = field[5], numeric_range = {
        minimum = field[6], maximum = field[7], step = field[8], unit = field[9],
      }, read_on_configure = true,
    }
  ))
end

local sensor_type_from, sensor_type_to = lookup({
  [0] = "4p7K", [1] = "6p8K", [2] = "10K", [3] = "12K",
  [4] = "15K", [5] = "33K", [6] = "47K",
})
append(mappings, manufacturer_mapping(CLUSTER_THERMOSTAT, 0x4101, "sber_therm_sensor_type", "sberThermSensorType", data_types.Enum8, {
  from_device = sensor_type_from, to_device = sensor_type_to, read_on_configure = true,
}))
local sensor_mode_from, sensor_mode_to = lookup({ [0] = "local", [1] = "remote", [2] = "both" })
append(mappings, manufacturer_mapping(CLUSTER_THERMOSTAT, 0x4003, "sber_therm_sensor_mode", "sberThermSensorMode", data_types.Enum8, {
  from_device = sensor_mode_from, to_device = sensor_mode_to, read_on_configure = true,
}))
local output_mode_from, output_mode_to = lookup({ [0] = "normal", [1] = "inverted" })
append(mappings, manufacturer_mapping(CLUSTER_THERMOSTAT, 0x4100, "sber_therm_output_mode", "sberThermOutputMode", data_types.Enum8, {
  from_device = output_mode_from, to_device = output_mode_to, read_on_configure = true,
}))

-- Device/wired temperature and Sber electricity meter.
append(mappings, mapping(CLUSTER_DEVICE_TEMPERATURE, 0x0000, "sber_therm_device_temperature", "sberThermDeviceTemperature", data_types.Int16, {
  read_only = true, read_on_configure = false,
}))
append(mappings, mapping(CLUSTER_TEMPERATURE, 0x0000, "sber_therm_wired_temperature", "sberThermWiredTemperature", data_types.Int16, {
  read_only = true, scale = 100, minimum_interval = 10, maximum_interval = 3600,
  reportable_change = 100, read_on_configure = false,
}))
append(mappings, zcl.cluster_attribute(CLUSTER_SBER, 0x4001, {
  name = "voltage", endpoint = 1, read_only = true, mfg_code = SBER_MFG_CODE,
  data_type = data_types.Uint32, from_device = function(value) return value / 1000 end,
  emit = emit.voltage(), read_on_configure = false,
}))
append(mappings, zcl.cluster_attribute(CLUSTER_SBER, 0x4002, {
  name = "current", endpoint = 1, read_only = true, mfg_code = SBER_MFG_CODE,
  data_type = data_types.Uint32, from_device = function(value) return value / 1000 end,
  emit = emit.current(), read_on_configure = false,
}))
append(mappings, zcl.cluster_attribute(CLUSTER_SBER, 0x4003, {
  name = "power", endpoint = 1, read_only = true, mfg_code = SBER_MFG_CODE,
  data_type = data_types.Int32, from_device = function(value) return value / 1000 end,
  emit = emit.power(), read_on_configure = false,
}))

append(mappings, sber_mapping(0x3013, "sber_therm_upper_current_threshold", "sberThermUpperCurrentThreshold", data_types.Uint32, {
  numeric_range = { minimum = 100, maximum = 16000, step = 100, unit = "mA" }, read_on_configure = false,
}))
append(mappings, sber_mapping(0x3014, "sber_therm_temperature_threshold", "sberThermTemperatureThreshold", data_types.Int16, {
  numeric_range = { minimum = -200, maximum = 200, step = 1, unit = "C" }, read_on_configure = false,
}))

append(mappings, manufacturer_mapping(CLUSTER_UI, 0x2001, "sber_therm_brightness_operations", "sberThermBrightnessOperations", data_types.Uint16, {
  numeric_range = { minimum = 0, maximum = 1000, step = 1 }, read_on_configure = true,
}))
append(mappings, manufacturer_mapping(CLUSTER_UI, 0x2002, "sber_therm_brightness_steady", "sberThermBrightnessSteady", data_types.Uint16, {
  numeric_range = { minimum = 0, maximum = 1000, step = 1 }, read_on_configure = true,
}))

append(mappings, zcl.cluster_attribute(CLUSTER_IDENTIFY, nil, {
  name = "sber_therm_identify", endpoint = 1, write_only = true, sender = identify_sender,
}))
commands[#commands + 1] = {
  capability_id = NAMESPACE .. "sberThermIdentify", command_name = "identify",
  value = true, mapping_name = "sber_therm_identify",
}

append(mappings, sber_mapping(0x5001, "sber_therm_rtc_unavailable", "sberThermRtcUnavailable", data_types.Bitmap16, {
  read_only = true, from_device = active_bit(0x01), read_on_configure = false,
}))
append(mappings, sber_mapping(0x5001, "sber_therm_rtc_data_not_vaild", "sberThermRtcDataNotVaild", data_types.Bitmap16, {
  read_only = true, from_device = active_bit(0x02), read_on_configure = false,
}))
append(mappings, mapping(CLUSTER_BASIC, 0x000D, "sber_therm_serial_number", "sberThermSerialNumber", data_types.CharString, {
  read_only = true, from_device = function(value) return tostring(value) end, read_on_configure = false,
}))

for _, field in ipairs({
  { 0x0000, "resets_count", "ResetsCount", data_types.Uint16, nil },
  { 0x1001, "uptime", "Uptime", data_types.Uint32, SBER_MFG_CODE },
  { 0x1002, "button_clicks_one", "ButtonClicksOne", data_types.Uint32, SBER_MFG_CODE },
  { 0x1003, "button_clicks_two", "ButtonClicksTwo", data_types.Uint32, SBER_MFG_CODE },
  { 0x1004, "button_clicks_three", "ButtonClicksThree", data_types.Uint32, SBER_MFG_CODE },
  { 0x1005, "relay_switches_one", "RelaySwitchesOne", data_types.Uint32, SBER_MFG_CODE },
}) do
  append(mappings, mapping(
    CLUSTER_DIAGNOSTICS, field[1], "sber_therm_" .. field[2],
    "sberTherm" .. field[3], field[4], {
      read_only = true, mfg_code = field[5], read_on_configure = false,
    }
  ))
end

local function configure(driver, device)
  read(device, CLUSTER_BASIC, 0x000D)
  read_many(device, CLUSTER_SBER, { 0x4001, 0x4002, 0x4003, 0x3001, 0x3013, 0x3014 }, SBER_MFG_CODE)
  read(device, CLUSTER_DEVICE_TEMPERATURE, 0x0000)
  read(device, CLUSTER_TEMPERATURE, 0x0000)
  read_many(device, CLUSTER_THERMOSTAT, {
    0x0012, 0x0000, 0x0010, 0x0003, 0x0004, 0x0015, 0x0016, 0x001B, 0x001C, 0x001E,
  })
  read_many(device, CLUSTER_THERMOSTAT, { 0x0020, 0x0021, 0x0022, 0x0025, 0x0029 })
  read_many(device, CLUSTER_THERMOSTAT, { 0x4001, 0x4002, 0x4019, 0x40F0, 0x40F1, 0x4102, 0x4103 }, SBER_MFG_CODE)
  read(device, CLUSTER_THERMOSTAT, 0x4203, SBER_MFG_CODE)
  read(device, CLUSTER_UI, 0x0001)
  read_many(device, CLUSTER_UI, { 0x2001, 0x2002 }, SBER_MFG_CODE)
  read(device, CLUSTER_SBER, 0x5001, SBER_MFG_CODE)
  query_weekly_schedule(device, 1)
  bind(device, driver.environment_info.hub_zigbee_eui, {
    CLUSTER_DEVICE_TEMPERATURE, CLUSTER_TEMPERATURE, CLUSTER_THERMOSTAT, CLUSTER_UI, CLUSTER_SBER,
  })
  bind(device, driver.environment_info.hub_zigbee_eui, { CLUSTER_DIAGNOSTICS })
end

local sber = {
  profile = "thermostats-wave19-sber-sbdv-00205",
  package_group = "wave19-thermostat-zcl",
  transport_classification = "ZCL_CUSTOM_ATTRIBUTE_COMMAND",
  z2m_converter_source = "sdevices fz/tz + thermostat/UI/weekly schedule converters",
  wire_cluster = "standard ZCL + Sber 0xFCCF/0x152F",
  zcl_clusters = mappings,
  capability_commands = commands,
  placeholder_custom_states = false,
  thermostat_supported_modes = { "off", "heat", "asleep" },
  heating_setpoint_range = { minimum = 1, maximum = 50, step = 0.5, unit = "C" },
  configure = configure,
}

sber.runtime_start = function(device)
  device:emit_component_event(
    { id = "main" },
    capabilities.thermostatMode.supportedThermostatModes(
      sber.thermostat_supported_modes, { visibility = { displayed = false } }
    )
  )
  device:emit_component_event(
    { id = "main" },
    capabilities.thermostatHeatingSetpoint.heatingSetpointRange({
      value = {
        minimum = sber.heating_setpoint_range.minimum,
        maximum = sber.heating_setpoint_range.maximum,
        step = sber.heating_setpoint_range.step,
      },
      unit = sber.heating_setpoint_range.unit,
    })
  )
end

register_device_definition(sber, {
  device_helpers.create_fingerprint("SDevices", "SBDV-00205"),
})

return {
  id = "zcl.thermostats.wave19.sber",
  registrations = device_definitions,
}
