local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local capabilities = require "st.capabilities"

local converter = tuya.converter
local wave12 = {}

function wave12.custom(capability_id)
  return emit[capability_id]()
end

function wave12.numeric(dp, name, capability_id, divisor, read_only, options)
  options = options or {}
  local numeric_converter = options.converter
  if numeric_converter == nil and options.signed == true then
    local signed_converter = converter.signed_number_pair(divisor or 1)
    numeric_converter = signed_converter
  elseif numeric_converter == nil and divisor ~= nil and divisor ~= 1 then
    local default_converter = converter.divide_by_pair(divisor)
    numeric_converter = default_converter
  end
  local mapping = {
    name = name,
    read_only = read_only == true,
    emit = wave12.custom(capability_id),
    converter = numeric_converter,
  }
  if options.from_device ~= nil then mapping.from_device = options.from_device end
  if options.to_device ~= nil then mapping.to_device = options.to_device end
  if options.signed ~= nil then mapping.signed = options.signed end
  return tuya.dp_numeric(dp, mapping)
end

function wave12.enum(dp, name, capability_id, values, read_only, value_datatype)
  local pair = read_only == true
    and converter.from_only(converter.lookup_value((function()
      local reverse = {}
      for label, raw in pairs(values) do reverse[raw] = label end
      return reverse
    end)()))
    or converter.lookup_from_to(values)
  local options = {
    name = name,
    read_only = read_only == true,
    converter = pair,
    emit = wave12.custom(capability_id),
  }
  if value_datatype == true then
    return tuya.dp_numeric(dp, options)
  end
  return tuya.dp_enum(dp, options)
end

function wave12.binary(dp, name, capability_id, values, read_only)
  local pair = read_only == true
    and converter.from_only(function(value)
      for label, raw in pairs(values) do
        if value == raw then return label end
      end
      return nil
    end)
    or converter.lookup_from_to(values)
  return tuya.dp_binary(dp, {
    name = name,
    read_only = read_only == true,
    converter = pair,
    emit = wave12.custom(capability_id),
  })
end

function wave12.raw(dp, name, capability_id, conversion, read_only)
  return tuya.dp_raw(dp, {
    name = name,
    converter = conversion,
    read_only = read_only == true,
    emit = wave12.custom(capability_id),
  })
end

function wave12.schedule_converter(day_number, transition_count)
  local function from_device(value)
    if type(value) ~= "string" then return nil end
    local transitions = {}
    for index = 0, transition_count - 1 do
      local offset = 2 + index * 4
      local hour, minute, high, low = string.byte(value, offset, offset + 3)
      if hour == nil or minute == nil or high == nil or low == nil then return nil end
      transitions[#transitions + 1] = string.format(
        "%02d:%02d/%.1f", hour, minute, ((high * 256) + low) / 10
      )
    end
    return table.concat(transitions, " ")
  end

  local function to_device(value)
    if type(value) ~= "string" then return nil end
    local payload = { day_number or 0 }
    local count = 0
    for transition in string.gmatch(value, "%S+") do
      local hour_text, minute_text, temperature_text = transition:match("^(%d+):(%d+)/([%d%.%-]+)$")
      local hour = tonumber(hour_text)
      local minute = tonumber(minute_text)
      local temperature = tonumber(temperature_text)
      if hour == nil or minute == nil or temperature == nil
        or hour < 0 or hour > 24 or minute < 0 or minute > 60
        or temperature < 5 or temperature > 35 then
        return nil
      end
      local encoded = math.floor(temperature * 10)
      payload[#payload + 1] = math.floor(hour)
      payload[#payload + 1] = math.floor(minute)
      payload[#payload + 1] = math.floor(encoded / 256) % 256
      payload[#payload + 1] = encoded % 256
      count = count + 1
    end
    if count ~= transition_count then return nil end
    return string.char(table.unpack(payload))
  end

  return converter.from_to(from_device, to_device)
end

function wave12.add_day_schedules(definition, prefix, capability_prefix, dp_start, transition_count, with_day_number)
  local days = {
    { "monday", "Monday" }, { "tuesday", "Tuesday" }, { "wednesday", "Wednesday" },
    { "thursday", "Thursday" }, { "friday", "Friday" }, { "saturday", "Saturday" },
    { "sunday", "Sunday" },
  }
  for index, day in ipairs(days) do
    local day_number = index
    if with_day_number == false then day_number = nil end
    definition[#definition + 1] = wave12.raw(
      dp_start + index - 1,
      prefix .. "_schedule_" .. day[1],
      capability_prefix .. "Schedule" .. day[2],
      wave12.schedule_converter(day_number, transition_count),
      false
    )
  end
end

function wave12.override_named_writer(definition, name, writer)
  local mappings = tuya.build_named_map(definition, "name")
  mappings[name] = writer
  definition.named_mapping = { named_mappings = mappings }
end

function wave12.attach_setpoint_range(definition, minimum, maximum, step)
  definition.heating_setpoint_range = {
    minimum = minimum, maximum = maximum, step = step, unit = "C",
  }
  local previous = definition.runtime_start
  definition.runtime_start = function(device)
    if previous ~= nil then previous(device) end
    device:emit_component_event(
      { id = "main" },
      capabilities.thermostatHeatingSetpoint.heatingSetpointRange({
        value = { minimum = minimum, maximum = maximum, step = step },
        unit = "C",
      })
    )
  end
end

return wave12
