local capabilities = require "st.capabilities"
local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local thermostat_metadata = require "contracts.helpers.ef00_thermostat_metadata"

local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()

local function ts0601_fingerprints(manufacturers)
  return device_helpers.create_fingerprints("TS0601", manufacturers)
end

local function attach_heating_setpoint_range(definition, minimum, maximum, step)
  definition.heating_setpoint_range = {
    minimum = minimum,
    maximum = maximum,
    step = step,
    unit = "C",
  }
  definition.runtime_start = function(device)
    device:emit_component_event(
      { id = "main" },
      capabilities.thermostatHeatingSetpoint.heatingSetpointRange({
        value = { minimum = minimum, maximum = maximum, step = step },
        unit = "C",
      })
    )
  end
end

local function round_positive(value)
  local numeric = tonumber(value)
  if numeric == nil then
    return nil
  end
  return math.floor(numeric + 0.5)
end

local function split_double_space(value)
  local items = {}
  local start_index = 1
  while true do
    local separator = string.find(value, "  ", start_index, true)
    if separator == nil then
      items[#items + 1] = string.sub(value, start_index)
      break
    end
    items[#items + 1] = string.sub(value, start_index, separator - 1)
    start_index = separator + 2
  end
  return items
end

-- JavaScript Number.parseInt compatibility for the frozen Moes schedule
-- setter. It accepts the emitted degree suffix as well as bare integer or
-- decimal text, and truncates at the first non-digit.
local function parse_js_integer(value)
  if type(value) ~= "string" then
    return nil
  end
  local sign, digits = value:match("^%s*([%+%-]?)(%d+)")
  if digits == nil then
    return nil
  end
  local numeric = tonumber(digits)
  if sign == "-" then
    numeric = -numeric
  end
  return numeric
end

-- Frozen legacy moesS schedule: 12 triples [hour, minute, temperature*2].
-- RX can display half degrees; TX uses parseInt and therefore truncates them.
local function moes_programming_converter()
  local function from_device(value)
    if type(value) ~= "string" or #value < 36 then
      return nil
    end
    local items = {}
    for index = 0, 11 do
      local offset = 1 + index * 3
      local hour, minute, encoded_temperature = string.byte(value, offset, offset + 2)
      if hour == nil or minute == nil or encoded_temperature == nil then
        return nil
      end
      local temperature = encoded_temperature / 2
      local temperature_text = temperature % 1 == 0 and tostring(math.floor(temperature))
        or string.format("%.1f", temperature)
      items[#items + 1] = string.format("%02d:%02d/%s°C", hour, minute, temperature_text)
    end
    return table.concat(items, "  ")
  end

  local function to_device(value)
    if type(value) ~= "string" then
      return nil
    end
    local items = split_double_space(value)
    if #items < 12 then
      return nil
    end

    local payload = {}
    for index = 1, 12 do
      local item = items[index]
      local time_text, temperature_text = item:match("^([^/]*)/([^/]*)")
      local hour_text, minute_text
      if time_text ~= nil then
        hour_text, minute_text = time_text:match("^([^:]*):([^:]*)")
      end
      local hour = parse_js_integer(hour_text)
      local minute = parse_js_integer(minute_text)
      local temperature = parse_js_integer(temperature_text)
      if hour == nil or minute == nil or temperature == nil then
        return nil
      end
      if hour < 0 or hour >= 24 or minute < 0 or minute >= 60
        or temperature < 5 or temperature >= 35 then
        return nil
      end
      payload[#payload + 1] = math.floor(hour)
      payload[#payload + 1] = math.floor(minute)
      payload[#payload + 1] = temperature * 2
    end
    return string.char(table.unpack(payload))
  end

  return converter.from_to(from_device, to_device)
end

local MOES_LOCAL_TEMPERATURE_FIELD = "__wave9_moes_local_temperature"
local MOES_TEMPERATURE_CALIBRATION_FIELD = "__wave9_moes_temperature_calibration"
local moes_temperature_calibration_converter = converter.signed_number_pair(1)
local moes_temperature_calibration_event = emit.moesBrtTempCalibration()
local moes_temperature_event = emit.temperature("C")

local function latest_numeric_state(device, field, capability_id, attribute_name)
  local value = device:get_field(field)
  if value == nil and type(device.get_latest_state) == "function" then
    value = device:get_latest_state("main", capability_id, attribute_name)
  end
  return tonumber(value)
end

local function moes_local_temperature_from_device(value, device)
  local numeric = tonumber(value)
  if numeric == nil then
    return nil
  end
  local temperature = numeric / 10
  device:set_field(MOES_LOCAL_TEMPERATURE_FIELD, temperature, { persist = false })
  return temperature
end

local function moes_temperature_calibration_from_device(value, device, dp_info, mapping_context)
  local calibration = moes_temperature_calibration_converter.from(value, device, dp_info, mapping_context)
  if calibration == nil then
    return nil
  end

  local previous = latest_numeric_state(
    device,
    MOES_TEMPERATURE_CALIBRATION_FIELD,
    "concertmirror08464.moesBrtTempCalibration",
    "tempCalibration"
  )
  local temperature = latest_numeric_state(
    device,
    MOES_LOCAL_TEMPERATURE_FIELD,
    "temperatureMeasurement",
    "temperature"
  )
  if previous ~= nil and temperature ~= nil and type(mapping_context) == "table" then
    mapping_context.moes_adjusted_temperature = temperature + calibration - previous
  end

  device:set_field(MOES_TEMPERATURE_CALIBRATION_FIELD, calibration, { persist = false })
  return calibration
end

local function moes_temperature_calibration_emitter(device, value, dp_info, mapping_context)
  local events = {}
  local calibration_event = moes_temperature_calibration_event(device, value, dp_info, mapping_context)
  if calibration_event ~= nil then
    events[#events + 1] = calibration_event
  end

  local adjusted = type(mapping_context) == "table" and mapping_context.moes_adjusted_temperature or nil
  if adjusted ~= nil then
    device:set_field(MOES_LOCAL_TEMPERATURE_FIELD, adjusted, { persist = false })
    local temperature_event = moes_temperature_event(device, adjusted, dp_info, mapping_context)
    if temperature_event ~= nil then
      events[#events + 1] = temperature_event
    end
  end

  return #events > 0 and events or nil
end

local moes = {
  profile = "thermostats-wave9-moes-brt100",
  package_group = "trv",
  transport_classification = "CUSTOM_PAYLOAD",
  z2m_converter_source = "legacy.moesS_thermostat",
  wire_cluster = "manuSpecificTuya",
  query_on_configure = false,
  time_start = "1970",
  force_time_updates = true,
  ota_disabled_reason = "Frozen Z2M records that the available OTA bricks this device",
  tuya.dp_enum(1, {
    name = "moes_brt_preset",
    converter = converter.lookup_from_to({
      programming = 0,
      manual = 1,
      temporary_manual = 2,
      holiday = 3,
    }),
    emit = emit.moesBrtPreset(),
  }),
  tuya.dp_current_heating_setpoint(2, {
    scale = 1,
    to_device = round_positive,
    emit = emit.heating_setpoint("C"),
  }),
  tuya.dp_local_temperature(3, {
    from_device = moes_local_temperature_from_device,
    read_only = true,
    emit = emit.temperature("C"),
  }),
  tuya.dp_binary(4, {
    name = "moes_brt_boost_heating",
    converter = converter.lookup_from_to({ ON = true, OFF = false }),
    emit = emit.moesBrtBoostHeating(),
  }),
  tuya.dp_numeric(5, {
    name = "moes_brt_boost_countdown",
    read_only = true,
    emit = emit.moesBrtBoostCountdown(),
  }),
  tuya.dp_binary(7, {
    name = "running_state",
    read_only = true,
    converter = converter.from_only(function(value)
      return (value == true or value == 1) and "idle" or "heating"
    end),
    emit = emit.thermostat_operating_state(),
  }),
  tuya.dp_binary(7, {
    name = "moes_brt_valve_state",
    read_only = true,
    converter = converter.from_only(function(value)
      return (value == true or value == 1) and "CLOSED" or "OPEN"
    end),
    emit = emit.moesBrtValveState(),
  }),
  tuya.dp_binary(8, {
    name = "moes_brt_window_detection",
    converter = converter.lookup_from_to({ ON = true, OFF = false }),
    emit = emit.moesBrtWindowDetection(),
  }),
  tuya.dp_binary(9, {
    name = "moes_brt_window",
    read_only = true,
    converter = converter.from_only(function(value)
      return (value == true or value == 1) and "CLOSED" or "OPEN"
    end),
    emit = emit.moesBrtWindow(),
  }),
  tuya.dp_child_lock(13, {
    name = "moes_brt_child_lock",
    converter = converter.lookup_from_to({ LOCK = true, UNLOCK = false }),
    emit = emit.moesBrtChildLock(),
  }),
  tuya.dp_battery(14, { read_only = true, emit = emit.battery() }),
  tuya.dp_raw(101, {
    name = "moes_brt_programming_mode",
    converter = moes_programming_converter(),
    emit = emit.moesBrtProgrammingMode(),
  }),
  tuya.dp_numeric(103, {
    name = "moes_brt_boost_time_setting",
    emit = emit.moesBrtBoostTimeSetting(),
  }),
  tuya.dp_numeric(104, {
    name = "moes_brt_position",
    read_only = true,
    emit = emit.moesBrtPosition(),
  }),
  tuya.dp_local_temperature_calibration(105, {
    name = "moes_brt_temp_calibration",
    converter = moes_temperature_calibration_converter,
    from_device = moes_temperature_calibration_from_device,
    emit = moes_temperature_calibration_emitter,
  }),
  tuya.dp_binary(106, {
    name = "moes_brt_eco_mode",
    converter = converter.lookup_from_to({ ON = true, OFF = false }),
    emit = emit.moesBrtEcoMode(),
  }),
  tuya.dp_numeric(107, {
    name = "moes_brt_eco_temperature",
    to_device = round_positive,
    emit = emit.moesBrtEcoTemperature(),
  }),
  tuya.dp_numeric(108, {
    name = "moes_brt_max_temperature",
    to_device = round_positive,
    emit = emit.moesBrtMaxTemperature(),
  }),
  tuya.dp_numeric(109, {
    name = "moes_brt_min_temperature",
    to_device = round_positive,
    emit = emit.moesBrtMinTemperature(),
  }),
}
attach_heating_setpoint_range(moes, 0, 35, 1)
register_device_definition(moes, ts0601_fingerprints({
  "_TZE200_b6wax7g0",
  "_TZE200_qsoecqlk",
  "_TZE200_6y7kyjga",
}))

local LIDL_SETPOINT_FIELD = "__wave9_lidl_setpoint_raw"

local function clamp_lidl_setpoint_raw(value)
  local numeric = tonumber(value)
  if numeric == nil then
    return nil
  end
  local raw = math.floor(numeric * 2 + 0.5)
  if raw <= 0 then
    return 1
  end
  if raw >= 60 then
    return 59
  end
  return raw
end

local function lidl_setpoint_from_device(value, device)
  local raw = tonumber(value)
  if raw == nil then
    return nil
  end
  if raw > 0 and raw < 60 then
    device:set_field(LIDL_SETPOINT_FIELD, raw, { persist = false })
  end
  return raw / 2
end

local function lidl_setpoint_to_device(value, device)
  local raw = clamp_lidl_setpoint_raw(value)
  if raw ~= nil then
    device:set_field(LIDL_SETPOINT_FIELD, raw, { persist = false })
  end
  return raw
end

local function lidl_half_degree_clamped_converter()
  return converter.from_to(
    function(value)
      local numeric = tonumber(value)
      return numeric ~= nil and numeric / 2 or nil
    end,
    clamp_lidl_setpoint_raw
  )
end

local function lidl_calibration_converter()
  return converter.from_to(
    function(value)
      local numeric = tonumber(value)
      if numeric == nil then
        return nil
      end
      if numeric > 55 then
        numeric = numeric - 0x100000000
      end
      return numeric / 10
    end,
    function(value)
      local numeric = tonumber(value)
      if numeric == nil then
        return nil
      end
      -- dp_local_temperature_calibration marks VALUE mappings as signed. Keep
      -- the converter result signed so build_datapoint performs two's-complement
      -- encoding exactly once (for example -1 C -> -10 -> FF FF FF F6).
      return numeric * 10
    end
  )
end

local function lidl_system_mode_write(device, value)
  if value == "off" then
    return {
      { dp = 2, datatype = tuya.DP_TYPE_ENUM, value = 1 },
      { dp = 16, datatype = tuya.DP_TYPE_VALUE, value = 0 },
    }
  end
  if value == "auto" then
    return { { dp = 2, datatype = tuya.DP_TYPE_ENUM, value = 0 } }
  end
  if value == "heat" then
    return {
      { dp = 2, datatype = tuya.DP_TYPE_ENUM, value = 1 },
      { dp = 16, datatype = tuya.DP_TYPE_VALUE, value = device:get_field(LIDL_SETPOINT_FIELD) or 43 },
    }
  end
  return nil
end

local function lidl_preset_write(device, value)
  if value == "boost" then
    return {
      { dp = 2, datatype = tuya.DP_TYPE_ENUM, value = 1 },
      { dp = 16, datatype = tuya.DP_TYPE_VALUE, value = 60 },
    }
  end
  local encoded = ({ schedule = 0, manual = 1, holiday = 2 })[value]
  if encoded == nil then
    return nil
  end
  local frames = { { dp = 2, datatype = tuya.DP_TYPE_ENUM, value = encoded } }
  if value == "manual" then
    frames[#frames + 1] = {
      dp = 16,
      datatype = tuya.DP_TYPE_VALUE,
      value = device:get_field(LIDL_SETPOINT_FIELD) or 43,
    }
  end
  return frames
end

local function lidl_away_converter()
  local function from_device(value)
    if type(value) ~= "string" or #value < 8 then
      return nil
    end
    local year, month, day, hour, minute, temperature_raw, days_high, days_low =
      string.byte(value, 1, 8)
    return string.format(
      "%02d-%02d-%02d %02d:%02d/%.1f/%d",
      year, month, day, hour, minute, temperature_raw / 2,
      days_high * 256 + days_low
    )
  end

  local function to_device(value)
    if type(value) ~= "string" then
      return nil
    end
    local year, month, day, hour, minute, temperature, days =
      value:match("^(%d+)%-(%d+)%-(%d+) (%d+):(%d+)/([%d%.%-]+)/(%d+)$")
    year, month, day = tonumber(year), tonumber(month), tonumber(day)
    hour, minute = tonumber(hour), tonumber(minute)
    temperature, days = tonumber(temperature), tonumber(days)
    if year == nil or month == nil or day == nil or hour == nil or minute == nil
      or temperature == nil or days == nil then
      return nil
    end

    if year < 17 or year > 99 then
      year = 17
    else
      year = math.floor(year + 0.5)
    end
    if month < 1 or month > 12 then
      month = 1
    else
      month = math.floor(month + 0.5)
    end
    -- Frozen Z2M computes daysInMonth before populating result, so only the
    -- lower-bound fallback is effective. Buffer.from masks the final byte.
    day = day < 1 and 1 or math.floor(day + 0.5) % 256
    if hour < 0 or hour > 23 then
      hour = 0
    else
      hour = math.floor(hour + 0.5)
    end
    if minute < 0 or minute > 59 then
      minute = 0
    else
      minute = math.floor(minute + 0.5)
    end
    if temperature < 0.5 or temperature > 29.5 then
      temperature = 17
    end
    if days < 1 or days > 9999 then
      days = 1
    end
    local temperature_raw = math.floor(temperature * 2 + 0.5)
    days = math.floor(days + 0.5)
    return string.char(
      year, month, day, hour, minute, temperature_raw,
      math.floor(days / 256) % 256, days % 256
    )
  end

  return converter.from_to(from_device, to_device)
end

-- Frozen Lidl day frame: day byte, eight [temp*2, quarter] pairs, then temp9*2
-- (18 bytes total).
local function lidl_schedule_converter(day_number)
  local function from_device(value)
    if type(value) ~= "string" or #value < 18 then
      return nil
    end
    local items = {}
    for index = 1, 9 do
      local temperature_raw = string.byte(value, 2 + (index - 1) * 2)
      if temperature_raw == nil then
        return nil
      end
      if index < 9 then
        local quarter = string.byte(value, 3 + (index - 1) * 2)
        if quarter == nil then
          return nil
        end
        local hour = math.floor(quarter / 4)
        local minute = (quarter % 4) * 15
        items[#items + 1] = string.format("%02d:%02d/%.1f", hour, minute, temperature_raw / 2)
      else
        items[#items + 1] = string.format("END/%.1f", temperature_raw / 2)
      end
    end
    return table.concat(items, " ")
  end

  local function to_device(value)
    if type(value) ~= "string" then
      return nil
    end
    local items = {}
    for item in string.gmatch(value, "%S+") do
      items[#items + 1] = item
    end
    if #items ~= 9 then
      return nil
    end

    local payload = { day_number }
    for index, item in ipairs(items) do
      local temperature
      if index < 9 then
        local hour_text, minute_text, temperature_text =
          item:match("^(%d+):(%d+)/([%d%.%-]+)$")
        local hour = tonumber(hour_text)
        local minute = tonumber(minute_text)
        temperature = tonumber(temperature_text)
        if hour == nil or minute == nil or temperature == nil
          or hour < 0 or hour > 24
          or (minute ~= 0 and minute ~= 15 and minute ~= 30 and minute ~= 45) then
          return nil
        end
        if temperature < 0.5 or temperature > 29.5 then
          temperature = 17
        end
        payload[#payload + 1] = math.floor(temperature * 2 + 0.5)
        local quarter = hour * 4 + minute / 15
        if quarter < 1 then quarter = 1 end
        if quarter > 96 then quarter = 96 end
        payload[#payload + 1] = math.floor(quarter + 0.5)
      else
        local temperature_text = item:match("^END/([%d%.%-]+)$")
        temperature = tonumber(temperature_text)
        if temperature == nil then
          return nil
        end
        if temperature < 0.5 or temperature > 29.5 then
          temperature = 17
        end
        payload[#payload + 1] = math.floor(temperature * 2 + 0.5)
      end
    end
    return string.char(table.unpack(payload))
  end

  return converter.from_to(from_device, to_device)
end

local function named_mapping_overlay(datapoints, overrides)
  local mappings = tuya.build_named_map(datapoints, "name")
  for name, mapping in pairs(overrides) do
    mappings[name] = mapping
  end
  return mappings
end

local lidl = {
  profile = "thermostats-wave9-lidl-368308",
  package_group = "trv",
  transport_classification = "CUSTOM_PAYLOAD",
  z2m_converter_source = "legacy.zs_thermostat",
  wire_cluster = "manuSpecificTuya",
  query_on_configure = false,
  time_start = "1970",
  force_time_updates = true,
  bind_basic_on_configure = true,
  tuya.dp_system_mode(2, {
    name = "system_mode",
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "auto", [1] = "heat", [2] = "auto",
    })),
    emit = emit.thermostat_mode(),
  }),
  tuya.dp_enum(2, {
    name = "lidl_trv_preset",
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "schedule", [1] = "manual", [2] = "holiday",
    })),
    emit = emit.lidlTrvPreset(),
  }),
  tuya.dp_enum(2, {
    name = "lidl_trv_away_mode",
    read_only = true,
    converter = converter.from_only(function(value)
      return tonumber(value) == 2 and "ON" or "OFF"
    end),
    emit = emit.lidlTrvAwayMode(),
  }),
  tuya.dp_current_heating_setpoint(16, {
    from_device = lidl_setpoint_from_device,
    to_device = lidl_setpoint_to_device,
    emit = emit.heating_setpoint("C"),
  }),
  tuya.dp_numeric(16, {
    name = "system_mode_setpoint_sentinel",
    read_only = true,
    from_device = function(value)
      local numeric = tonumber(value)
      if numeric == 0 then return "off" end
      if numeric == 60 then return "heat" end
      return nil
    end,
    emit = emit.thermostat_mode(),
  }),
  tuya.dp_numeric(16, {
    name = "lidl_trv_preset_setpoint_sentinel",
    read_only = true,
    from_device = function(value)
      return tonumber(value) == 60 and "boost" or nil
    end,
    emit = emit.lidlTrvPreset(),
  }),
  tuya.dp_local_temperature(24, { scale = 10, read_only = true, emit = emit.temperature("C") }),
  tuya.dp_numeric(35, {
    name = "lidl_trv_battery_voltage",
    read_only = true,
    converter = converter.from_only(converter.multiply_by(10)),
    emit = emit.lidlTrvBatteryVoltage(),
  }),
  tuya.dp_child_lock(40, {
    name = "lidl_trv_child_lock",
    converter = converter.lookup_from_to({ LOCK = true, UNLOCK = false }),
    emit = emit.lidlTrvChildLock(),
  }),
  tuya.dp_numeric(101, {
    name = "lidl_trv_comfort_temperature",
    converter = converter.divide_by_pair(2),
    emit = emit.lidlTrvComfortTemperature(),
  }),
  tuya.dp_numeric(102, {
    name = "lidl_trv_eco_temperature",
    converter = converter.divide_by_pair(2),
    emit = emit.lidlTrvEcoTemperature(),
  }),
  tuya.dp_raw(103, {
    name = "lidl_trv_away_setting",
    converter = lidl_away_converter(),
    emit = emit.lidlTrvAwaySetting(),
  }),
  tuya.dp_local_temperature_calibration(104, {
    name = "lidl_trv_temp_calibration",
    converter = lidl_calibration_converter(),
    emit = emit.lidlTrvTempCalibration(),
  }),
  tuya.dp_numeric(105, {
    name = "lidl_trv_auto_setpoint",
    converter = lidl_half_degree_clamped_converter(),
    emit = emit.lidlTrvAutoSetpoint(),
  }),
  -- DP106/107 are explicitly unknown in frozen Z2M and stay unexposed.
  tuya.dp_raw(109, { name = "lidl_trv_schedule_monday", converter = lidl_schedule_converter(1), emit = emit.lidlTrvScheduleMonday() }),
  tuya.dp_raw(110, { name = "lidl_trv_schedule_tuesday", converter = lidl_schedule_converter(2), emit = emit.lidlTrvScheduleTuesday() }),
  tuya.dp_raw(111, { name = "lidl_trv_schedule_wednesday", converter = lidl_schedule_converter(3), emit = emit.lidlTrvScheduleWednesday() }),
  tuya.dp_raw(112, { name = "lidl_trv_schedule_thursday", converter = lidl_schedule_converter(4), emit = emit.lidlTrvScheduleThursday() }),
  tuya.dp_raw(113, { name = "lidl_trv_schedule_friday", converter = lidl_schedule_converter(5), emit = emit.lidlTrvScheduleFriday() }),
  tuya.dp_raw(114, { name = "lidl_trv_schedule_saturday", converter = lidl_schedule_converter(6), emit = emit.lidlTrvScheduleSaturday() }),
  tuya.dp_raw(115, { name = "lidl_trv_schedule_sunday", converter = lidl_schedule_converter(7), emit = emit.lidlTrvScheduleSunday() }),
  tuya.dp_numeric(116, {
    name = "lidl_trv_window_temperature",
    converter = lidl_half_degree_clamped_converter(),
    emit = emit.lidlTrvWindowTemperature(),
  }),
  tuya.dp_numeric(117, {
    name = "lidl_trv_window_time",
    emit = emit.lidlTrvWindowTime(),
  }),
}
lidl.named_mapping = {
  -- The two legacy multi-frame writers override their read-only RX mappings,
  -- while every ordinary writable datapoint remains available to commands.
  named_mappings = named_mapping_overlay(lidl, {
    system_mode = lidl_system_mode_write,
    lidl_trv_preset = lidl_preset_write,
  }),
}
thermostat_metadata.attach(lidl, { "off", "heat", "auto" }, 0.5, 29.5, 0.5)
register_device_definition(lidl, ts0601_fingerprints({
  "_TZE200_chyvmhay",
  "_TZE200_uiyqstza",
}))

local evanell = {
  profile = "thermostats-wave9-evanell-ez200",
  package_group = "trv",
  transport_classification = "CUSTOM_PAYLOAD",
  z2m_converter_source = "legacy.evanell_thermostat",
  wire_cluster = "manuSpecificTuya",
  query_on_configure = false,
  time_start = "2000",
  bind_basic_on_configure = true,
  tuya.dp_system_mode(2, {
    name = "system_mode",
    converter = converter.lookup_from_to({ auto = 0, heat = 2, off = 3 }),
    emit = emit.thermostat_mode(),
  }),
  tuya.dp_current_heating_setpoint(4, { scale = 10, emit = emit.heating_setpoint("C") }),
  tuya.dp_local_temperature(5, { scale = 10, read_only = true, emit = emit.temperature("C") }),
  tuya.dp_battery(6, { read_only = true, emit = emit.battery() }),
  tuya.dp_child_lock(8, {
    name = "evanell_ez_child_lock",
    converter = converter.lookup_from_to({ LOCK = true, UNLOCK = false }),
    emit = emit.evanellEzChildLock(),
  }),
}
thermostat_metadata.attach(evanell, { "off", "heat", "auto" }, 5, 30, 0.5)
register_device_definition(evanell, ts0601_fingerprints({
  "_TZE200_dmfguuli",
  "_TZE200_rxypyjkw",
}))

return {
  id = "ef00.thermostats.wave9_legacy",
  registrations = device_definitions,
}
