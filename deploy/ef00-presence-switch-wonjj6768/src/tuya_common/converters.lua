local function load_converter(tuya, shared)
  local utils = shared.utils
  local log = shared.log

  local math_floor = shared.math_floor
  local type_check = shared.type_check
  local tonumber_check = shared.tonumber_check
  local raw_bytes = shared.raw_bytes
  local string_byte = shared.string_byte
  local string_char = shared.string_char
  local string_len = shared.string_len
  local table_concat = shared.table_concat
  local EMPTY_TABLE = {}
  local function passthrough(value)
    return value
  end

local function resolve_converter_arg(arg, device, context)
  if type_check(arg) == "function" then
    return arg(device, context)
  end
  return arg
end

local function resolve_lookup_default(default_value, device, context)
  if type_check(default_value) == "function" then
    return default_value(device, context)
  end
  return default_value
end

local function resolve_numeric_arg(arg, device, context)
  local resolved = resolve_converter_arg(arg, device, context)
  if resolved == nil then
    return nil
  end

  return tonumber_check(resolved)
end

local function build_reverse_lookup(map)
  local reverse = {}
  for key, map_value in pairs(map) do
    reverse[map_value] = key
  end
  return reverse
end

local function resolve_lookup_map(map, device, context)
  local resolved = resolve_converter_arg(map, device, context)
  if resolved == nil then
    return EMPTY_TABLE
  end

  if type_check(resolved) ~= "table" then
    log.warn(string.format("Tuya lookup expects table map, got %s", type_check(resolved)))
    return EMPTY_TABLE
  end

  return resolved
end

local function parse_uint_be(buffer, start_index, byte_count)
  if type_check(buffer) ~= "string" then
    return nil
  end

  local start = start_index or 1
  local count = byte_count or (string_len(buffer) - start + 1)
  if start < 1 or count < 1 or (start + count - 1) > string_len(buffer) then
    return nil
  end

  local value = 0
  for index = start, start + count - 1 do
    value = (value * 256) + string_byte(buffer, index)
  end

  return value
end

local function resolve_raw_slice(buffer, options, device, context)
  local length = string_len(buffer)
  local resolved_options = type_check(options) == "table" and options or EMPTY_TABLE
  local byte_count = resolve_numeric_arg(resolved_options.bytes or resolved_options.length, device, context)
  if byte_count == nil then
    byte_count = length
  end

  byte_count = math_floor(byte_count)
  if byte_count < 1 or byte_count > length then
    log.warn("Tuya raw_uint_be requires valid byte count")
    return nil, nil
  end

  local start_index = resolve_numeric_arg(resolved_options.start, device, context)
  if start_index == nil then
    local offset = resolve_numeric_arg(resolved_options.offset, device, context)
    if offset ~= nil then
      start_index = math_floor(offset) + 1
    end
  end

  if start_index == nil then
    local from_tail = resolve_converter_arg(resolved_options.from_tail, device, context)
    if from_tail == true then
      start_index = length - byte_count + 1
    else
      start_index = 1
    end
  end

  start_index = math_floor(start_index)
  if start_index < 1 or (start_index + byte_count - 1) > length then
    log.warn("Tuya raw_uint_be slice is out of range")
    return nil, nil
  end

  return start_index, byte_count
end

local function raw_buffer_to_hex(buffer)
  local parts = {}
  for index = 1, string_len(buffer) do
    parts[#parts + 1] = string.format("%02X", string_byte(buffer, index))
  end

  return table_concat(parts)
end

local function numeric_lookup_keys(map)
  local keys = {}
  for key, _ in pairs(map or EMPTY_TABLE) do
    local numeric_key = tonumber_check(key)
    if numeric_key ~= nil then
      keys[#keys + 1] = math_floor(numeric_key)
    end
  end

  table.sort(keys)
  return keys
end

-- converter helpers
local converter = tuya.converter
function converter.pipe(...)
  local steps = { ... }
  if #steps == 1 and type_check(steps[1]) == "table" then
    steps = steps[1]
  end

  return function(value, device, context)
    local current = value
    for _, step in ipairs(steps) do
      current = step(current, device, context)
    end
    return current
  end
end
function converter.from_to(from_device, to_device)
  local pair = {}

  if type_check(from_device) == "function" then
    pair.from = from_device
  end

  if type_check(to_device) == "function" then
    pair.to = to_device
  end

  return pair
end
function converter.from_only(from_device)
  return converter.from_to(from_device, nil)
end
function converter.to_bool(true_value, false_value)
  return function(value)
    if type_check(value) == "boolean" then
      return value
    end

    if value == true_value then
      return true
    end

    if value == false_value then
      return false
    end

    log.warn(string.format("Tuya to_bool expected %s or %s, got %s", tostring(true_value), tostring(false_value), tostring(value)))
    return nil
  end
end
function converter.bool_pair(true_value, false_value)
  return converter.from_to(
    converter.to_bool(true_value, false_value),
    function(value)
      if value == true then
        return true_value
      end

      if value == false then
        return false_value
      end

      log.warn(string.format("Tuya bool_pair expected boolean, got %s", type_check(value)))
      return nil
    end
  )
end
function converter.lookup_from_to(map, default_value)
  local static_map = type_check(map) == "table" and map or nil
  local static_reverse = static_map and build_reverse_lookup(static_map) or nil

  return converter.from_to(
    function(value, device, context)
      local resolved_map = static_map or resolve_lookup_map(map, device, context)
      local reverse = static_reverse or build_reverse_lookup(resolved_map)

      local mapped = reverse[value]
      if mapped ~= nil then
        return mapped
      end

      local fallback = resolve_lookup_default(default_value, device, context)
      if fallback ~= nil then
        return fallback
      end

      log.warn(string.format("Tuya lookup_from_to missing value: %s", tostring(value)))
      return nil
    end,
    converter.lookup_value(map, default_value)
  )
end
function converter.lookup_value(map, default_value)
  local static_map = type_check(map) == "table" and map or nil

  return function(value, device, context)
    local resolved_map = static_map or resolve_lookup_map(map, device, context)
    local mapped = resolved_map[value]
    if mapped ~= nil then
      return mapped
    end

    local fallback = resolve_lookup_default(default_value, device, context)
    if fallback ~= nil then
      return fallback
    end

    log.warn(string.format("Tuya lookup missing key: %s", tostring(value)))
    return nil
  end
end
function converter.raw_uint_be(divisor, options)
  local static_options = type_check(options) == "table" and options or nil

  return converter.from_only(function(value, device, context)
    local buffer = raw_bytes(value)
    if buffer == nil then
      log.warn(string.format("Tuya raw_uint_be expects bytes, got %s", type_check(value)))
      return nil
    end

    local start_index, byte_count = resolve_raw_slice(buffer, static_options, device, context)
    if start_index == nil then
      return nil
    end

    local parsed = parse_uint_be(buffer, start_index, byte_count)
    if parsed == nil then
      log.warn("Tuya raw_uint_be failed to parse payload")
      return nil
    end

    local div = resolve_numeric_arg(divisor, device, context)
    if div == nil then
      div = 1
    end

    if div == 0 then
      log.warn("Tuya raw_uint_be divisor cannot be zero")
      return nil
    end

    return parsed / div
  end)
end
function converter.true_false0()
  return converter.bool_pair(0, 1)
end
function converter.true_false1()
  return converter.bool_pair(1, 0)
end
function converter.alarm_volume()
  return converter.lookup_from_to({
    low = 0,
    medium = 1,
    high = 2,
    mute = 3,
  })
end
function converter.pir_sensitivity_low_medium_high()
  return converter.lookup_from_to({
    low = 0,
    medium = 1,
    high = 2,
  })
end
function converter.pir_keep_time_ten_thirty_sixty_one_twenty()
  return converter.lookup_from_to({
    ["10"] = 0,
    ["30"] = 1,
    ["60"] = 2,
    ["120"] = 3,
  })
end
function converter.temperature_unit()
  return converter.lookup_from_to({
    C = 0,
    F = 1,
  })
end
function converter.power_outage_memory()
  return converter.lookup_from_to({
    off = 0,
    on = 1,
    restore = 2,
  })
end
function converter.motion_state()
  return converter.lookup_from_to({
    none = 0,
    large = 1,
    small = 2,
    static = 3,
  })
end
function converter.motion_detection_mode()
  return converter.lookup_from_to({
    pir_and_radar = 0,
    pir_or_radar = 1,
    only_radar = 2,
  })
end
function converter.divide_by_from_only(divisor)
  return converter.from_only(converter.divide_by(divisor))
end
function converter.power()
  return converter.from_only(function(value)
    local number_value = tonumber_check(value)
    if number_value == nil then
      log.warn(string.format("Tuya power expects number, got %s", type_check(value)))
      return nil
    end

    if number_value > 0x0FFFFFFF then
      return (0x1999999C - number_value) * -1
    end

    return number_value
  end)
end
function converter.scale(in_min, in_max, out_min, out_max)
  return function(value)
    local number_value = tonumber_check(value)
    local input_min = tonumber_check(in_min)
    local input_max = tonumber_check(in_max)
    local output_min = tonumber_check(out_min)
    local output_max = tonumber_check(out_max)
    if number_value == nil then
      log.warn(string.format("Tuya scale expects number, got %s", type_check(value)))
      return nil
    end

    if input_min == nil or input_max == nil or output_min == nil or output_max == nil then
      log.warn("Tuya scale expects numeric ranges")
      return nil
    end

    if input_max == input_min then
      log.warn("Tuya scale input range cannot be zero")
      return nil
    end

    return ((number_value - input_min) * (output_max - output_min) / (input_max - input_min)) + output_min
  end
end
function converter.scale_pair(in_min, in_max, out_min, out_max)
  return converter.from_to(
    converter.scale(in_min, in_max, out_min, out_max),
    converter.scale(out_min, out_max, in_min, in_max)
  )
end
function converter.divide_by(divisor)
  return function(value, device, context)
    local number_value = tonumber_check(value)
    local div = resolve_numeric_arg(divisor, device, context)
    if number_value == nil or div == nil then
      log.warn("Tuya divide_by expects numeric input and divisor")
      return nil
    end
    if div == 0 then
      log.warn("Tuya divide_by divisor cannot be zero")
      return nil
    end
    return number_value / div
  end
end
function converter.divide_by_pair(divisor)
  return converter.from_to(
    converter.divide_by(divisor),
    converter.multiply_by(divisor)
  )
end
function converter.signed_number_pair(scale)
  return converter.from_to(
    function(value, device, dp_info, context)
      local signed_value = nil
      if type_check(dp_info) == "table" and tonumber_check(dp_info.signed_value) ~= nil then
        signed_value = tonumber_check(dp_info.signed_value)
      else
        signed_value = tonumber_check(value)
        if signed_value ~= nil and signed_value > 0x7FFFFFFF then
          signed_value = signed_value - 0x100000000
        end
      end

      if signed_value == nil then
        log.warn(string.format("Tuya signed_number_pair expects number, got %s", type_check(value)))
        return nil
      end

      local divisor = resolve_numeric_arg(scale, device, context)
      if divisor == nil then
        divisor = 1
      end

      if divisor == 0 then
        log.warn("Tuya signed_number_pair scale cannot be zero")
        return nil
      end

      return signed_value / divisor
    end,
    function(value, device, context)
      local number_value = tonumber_check(value)
      if number_value == nil then
        log.warn(string.format("Tuya signed_number_pair expects number, got %s", type_check(value)))
        return nil
      end

      local multiplier = resolve_numeric_arg(scale, device, context)
      if multiplier == nil then
        multiplier = 1
      end

      if multiplier == 0 then
        log.warn("Tuya signed_number_pair scale cannot be zero")
        return nil
      end

      return number_value * multiplier
    end
  )
end
function converter.multiply_by(multiplier)
  return function(value, device, context)
    local number_value = tonumber_check(value)
    local factor = resolve_numeric_arg(multiplier, device, context)
    if number_value == nil or factor == nil then
      log.warn("Tuya multiply_by expects numeric input and multiplier")
      return nil
    end
    return number_value * factor
  end
end
function converter.threshold_parser()
  return function(value)
    return tuya.parse_threshold(value)
  end
end
end

return load_converter
