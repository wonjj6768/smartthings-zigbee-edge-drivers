local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"

local M = {}

local function normalize(value)
  if value == 1 or value == "F" or value == "fahrenheit" then
    return "fahrenheit", "F", 1
  end
  if value == 0 or value == "C" or value == "celsius" then
    return "celsius", "C", 0
  end
  return nil, nil, nil
end

local function remember(device, field_name, unit)
  if unit ~= nil and device ~= nil and type(device.set_field) == "function" then
    device:set_field(field_name, unit, { persist = true })
  end
end

function M.handlers(options)
  local field_name = options.field_name
  local pending_temperature_field = field_name .. "_pending_temperature"
  local correction_field = field_name .. "_correction_pending"
  local unit_dp = options.unit_dp or 109
  local capability_id = options.capability_id
  local capability_attribute = options.capability_attribute or "temperatureUnit"
  local capability_emitter = options.capability_emitter

  local function clear(device, key)
    device:set_field(key, nil, { persist = false })
  end

  local function frame_unit(mapping_context)
    local frame = type(mapping_context) == "table" and mapping_context.frame or nil
    local datapoints = type(frame) == "table" and frame.datapoints or nil
    if type(datapoints) ~= "table" then return nil end
    for _, datapoint in ipairs(datapoints) do
      if datapoint.dp == unit_dp then
        local _, unit = normalize(datapoint.value)
        return unit
      end
    end
    return nil
  end

  local function from_device(value, device)
    local capability_value, event_unit = normalize(value)
    if capability_value == nil then return nil end
    local pending_temperature = device:get_field(pending_temperature_field)
    remember(device, field_name, event_unit)
    device:set_field(
      correction_field,
      pending_temperature ~= nil,
      { persist = false }
    )
    if not device:get_field(correction_field) then
      clear(device, pending_temperature_field)
    end
    return capability_value
  end

  local function to_device(value, device)
    local _, _, raw = normalize(value)
    if raw == nil then return nil end
    return raw
  end

  local function unit_emitter(device, value, dp_info, mapping_context)
    local _, event_unit = normalize(value)
    remember(device, field_name, event_unit)
    local unit_event = capability_emitter(device, value, dp_info, mapping_context)
    if not device:get_field(correction_field) then return unit_event end

    local pending_temperature = device:get_field(pending_temperature_field)
    clear(device, correction_field)
    clear(device, pending_temperature_field)
    if pending_temperature == nil or event_unit == nil then return unit_event end

    if unit_event == nil then
      return emit.temperature(event_unit)(device, pending_temperature)
    end
    return { unit_event, emit.temperature(event_unit)(device, pending_temperature) }
  end

  local function temperature_emitter(device, value, _, mapping_context)
    if value == nil then return nil end
    local unit = frame_unit(mapping_context)
    if unit ~= nil then
      remember(device, field_name, unit)
    else
      unit = device:get_field(field_name)
    end
    if unit == nil and type(device.get_latest_state) == "function" then
      local latest = device:get_latest_state("main", capability_id, capability_attribute)
      _, unit = normalize(latest)
      remember(device, field_name, unit)
    end
    if unit == nil then
      device:set_field(pending_temperature_field, value, { persist = false })
      return nil
    end
    clear(device, pending_temperature_field)
    return emit.temperature(unit)(device, value)
  end

  return {
    converter = tuya.converter.from_to(from_device, to_device),
    unit_emitter = unit_emitter,
    temperature_emitter = temperature_emitter,
  }
end

return M
