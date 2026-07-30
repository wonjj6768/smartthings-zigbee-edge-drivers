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
function converter.to_only(to_device)
  return converter.from_to(nil, to_device)
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
function converter.raw_identifier()
  return converter.from_only(function(value)
    local buffer = raw_bytes(value)
    if buffer == nil then
      return value
    end

    local length = string_len(buffer)
    local chars = {}
    local printable = true
    for index = 1, length do
      local byte_value = string_byte(buffer, index)
      if byte_value ~= 0 then
        if byte_value < 32 or byte_value > 126 then
          printable = false
        end
        chars[#chars + 1] = string_char(byte_value)
      end
    end

    if printable and #chars > 0 then
      return table_concat(chars)
    end

    if length <= 4 then
      return parse_uint_be(buffer, 1, length)
    end

    return raw_buffer_to_hex(buffer)
  end)
end
function converter.bitmap_flags(map, empty_value, separator)
  local static_map = type_check(map) == "table" and map or nil
  local static_keys = static_map and numeric_lookup_keys(static_map) or nil

  return converter.from_only(function(value, device, context)
    local numeric_value = tonumber_check(value)
    if numeric_value == nil then
      log.warn(string.format("Tuya bitmap_flags expects number, got %s", type_check(value)))
      return nil
    end

    local resolved_map = static_map or resolve_lookup_map(map, device, context)
    local resolved_keys = static_keys or numeric_lookup_keys(resolved_map)
    local labels = {}
    local integer_value = math_floor(numeric_value)
    for _, bit in ipairs(resolved_keys) do
      if math_floor(integer_value / bit) % 2 == 1 then
        local label = resolved_map[bit] or resolved_map[tostring(bit)]
        if label ~= nil then
          labels[#labels + 1] = label
        end
      end
    end

    if #labels == 0 then
      return resolve_lookup_default(empty_value, device, context)
    end

    local resolved_separator = resolve_converter_arg(separator, device, context)
    if type_check(resolved_separator) ~= "string" then
      resolved_separator = ","
    end

    return table_concat(labels, resolved_separator)
  end)
end
function converter.report_period_hours()
  return converter.lookup_from_to({
    ["1h"] = 0,
    ["2h"] = 1,
    ["3h"] = 2,
    ["4h"] = 3,
    ["6h"] = 4,
    ["8h"] = 5,
    ["12h"] = 6,
    ["24h"] = 7,
    ["48h"] = 8,
    ["72h"] = 9,
  })
end
function converter.water_meter_faults()
  return converter.bitmap_flags({
    [1] = "battery_alarm",
    [2] = "magnetism_alarm",
    [4] = "cover_alarm",
    [8] = "credit_alarm",
    [16] = "switch_gaps_alarm",
    [32] = "meter_body_alarm",
    [64] = "abnormal_water_alarm",
    [128] = "arrearage_alarm",
    [256] = "overflow_alarm",
    [512] = "revflow_alarm",
    [1024] = "over_pre_alarm",
    [2048] = "empty_pipe_alarm",
    [4096] = "transducer_alarm",
  }, "no_alarm", ",")
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
function converter.clamp(min_value, max_value)
  return function(value, device, context)
    local number_value = tonumber_check(value)
    if number_value == nil then
      log.warn(string.format("Tuya clamp expects number, got %s", type_check(value)))
      return nil
    end

    local low = resolve_numeric_arg(min_value, device, context)
    local high = resolve_numeric_arg(max_value, device, context)

    if low ~= nil and number_value < low then
      number_value = low
    end
    if high ~= nil and number_value > high then
      number_value = high
    end

    return number_value
  end
end
function converter.round_to_step(step)
  return function(value, device, context)
    local number_value = tonumber_check(value)
    local step_value = resolve_numeric_arg(step, device, context)
    if number_value == nil or step_value == nil then
      log.warn("Tuya round_to_step expects numeric input and step")
      return nil
    end
    if step_value == 0 then
      log.warn("Tuya round_to_step step cannot be zero")
      return nil
    end

    return math_floor(number_value / step_value + 0.5) * step_value
  end
end
function converter.threshold_parser()
  return function(value)
    return tuya.parse_threshold(value)
  end
end
end

return load_converter
