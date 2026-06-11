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

function converter.raw()
  return passthrough
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

function converter.constant(static_value)
  return function()
    return static_value
  end
end

function converter.field_value(field_name, default_value)
  return function(value, device, context)
    if type_check(value) ~= "table" then
      log.warn(string.format("Tuya field expects table, got %s", type_check(value)))
      return nil
    end

    local field_value = value[field_name]
    if field_value ~= nil then
      return field_value
    end

    local fallback = resolve_converter_arg(default_value, device, context)
    if fallback ~= nil then
      return fallback
    end

    log.warn(string.format("Tuya field missing key: %s", tostring(field_name)))
    return nil
  end
end

function converter.invert_bool_pair()
  return converter.from_to(
    converter.invert_bool(),
    converter.invert_bool()
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

function converter.battery_state()
  return converter.lookup_from_to({
    normal = 0,
    low = 1,
  })
end

function converter.battery_state_low_medium_high()
  return converter.lookup_from_to({
    low = 0,
    medium = 1,
    high = 2,
  })
end

function converter.true_false0()
  return converter.bool_pair(0, 1)
end

function converter.true_false1()
  return converter.bool_pair(1, 0)
end

function converter.self_test_result()
  return converter.lookup_from_to({
    checking = 0,
    success = 1,
    failure = 2,
    others = 3,
  })
end

function converter.self_test_state()
  return converter.lookup_from_to({
    checking = 0,
    check_success = 1,
    check_failure = 2,
  })
end

function converter.alarm_volume()
  return converter.lookup_from_to({
    low = 0,
    medium = 1,
    high = 2,
    mute = 3,
  })
end

function converter.alarm_ringtone_melody_five()
  return converter.lookup_from_to({
    melody_1 = 0,
    melody_2 = 1,
    melody_3 = 2,
    melody_4 = 3,
    melody_5 = 4,
  })
end

function converter.gas_fault_status()
  return converter.lookup_from_to({
    none = 0,
    fault = 1,
    serious_fault = 2,
    sensor_fault = 3,
    probe_fault = 4,
    power_fault = 5,
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

function converter.alarm_state_lower_upper_cancel()
  return converter.lookup_from_to({
    lower_alarm = 0,
    upper_alarm = 1,
    cancel = 2,
  })
end

function converter.temperature_unit()
  return converter.lookup_from_to({
    C = 0,
    F = 1,
  })
end

function converter.power_on_behavior()
  return converter.lookup_from_to({
    off = 0,
    on = 1,
    previous = 2,
  })
end

function converter.power_outage_memory()
  return converter.lookup_from_to({
    off = 0,
    on = 1,
    restore = 2,
  })
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

function converter.valve_state_closed_open()
  return converter.lookup_from_to({
    close = 0,
    open = 1,
  })
end

function converter.valve_state_unknown_open_closed()
  return converter.lookup_from_to({
    unknown = 0,
    open = 1,
    close = 2,
  })
end

function converter.temperature_sensor_select_in_al_ou()
  return converter.lookup_from_to({
    IN = 0,
    AL = 1,
    OU = 2,
  })
end

function converter.temperature_sensor_select_internal_external_both()
  return converter.lookup_from_to({
    internal = 0,
    external = 1,
    both = 2,
  })
end

function converter.switch_type()
  return converter.lookup_from_to({
    momentary = 0,
    toggle = 1,
    state = 2,
  })
end

function converter.switch_type_curtain()
  return converter.lookup_from_to({
    ["flip-switch"] = 0,
    ["sync-switch"] = 1,
    ["button-switch"] = 2,
    ["button2-switch"] = 3,
  })
end

function converter.switch_type_button()
  return converter.lookup_from_to({
    release = 0,
    press = 1,
  })
end

function converter.switch_mode()
  return converter.lookup_from_to({
    switch = 0,
    scene = 1,
  })
end

function converter.backlight_mode_off_normal_inverted()
  return converter.lookup_from_to({
    off = 0,
    normal = 1,
    inverted = 2,
  })
end

function converter.backlight_mode_low_medium_high()
  return converter.lookup_from_to({
    low = 0,
    medium = 1,
    high = 2,
  })
end

function converter.indicator_mode()
  return converter.lookup_from_to({
    off = 0,
    ["off/on"] = 1,
    ["on/off"] = 2,
    on = 3,
  })
end

function converter.indicator_mode_none_relay_pos()
  return converter.lookup_from_to({
    none = 0,
    relay = 1,
    pos = 2,
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

function converter.water_warning()
  return converter.lookup_from_to({
    none = 0,
    alarm = 1,
  })
end

function converter.soil_fertility_warning()
  return converter.lookup_from_to({
    none = 0,
    alarm = 1,
  })
end

function converter.true_false(true_value)
  return converter.from_only(function(value, device, context)
    local expected = resolve_converter_arg(true_value, device, context)
    return value == expected
  end)
end

function converter.divide_by_from_only(divisor)
  return converter.from_only(converter.divide_by(divisor))
end

function converter.divide_by_with_limits(divisor, min_value, max_value)
  local from_device = converter.pipe(
    converter.divide_by(divisor),
    converter.clamp(min_value, max_value)
  )
  local to_device = converter.pipe(
    converter.clamp(min_value, max_value),
    converter.multiply_by(divisor)
  )

  return converter.from_to(from_device, to_device)
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

function converter.plus_one_pair()
  return converter.from_to(
    function(value)
      local number_value = tonumber_check(value)
      if number_value == nil then
        log.warn(string.format("Tuya plus_one_pair expects number, got %s", type_check(value)))
        return nil
      end

      return number_value + 1
    end,
    function(value)
      local number_value = tonumber_check(value)
      if number_value == nil then
        log.warn(string.format("Tuya plus_one_pair expects number, got %s", type_check(value)))
        return nil
      end

      return number_value - 1
    end
  )
end

function converter.wrap_signed(modulus, cutoff)
  return converter.from_to(
    function(value, device, context)
      local number_value = tonumber_check(value)
      local wrap_modulus = resolve_numeric_arg(modulus, device, context)
      local wrap_cutoff = resolve_numeric_arg(cutoff, device, context)
      if number_value == nil or wrap_modulus == nil or wrap_cutoff == nil then
        log.warn("Tuya wrapped_signed expects numeric input, modulus, and cutoff")
        return nil
      end

      if number_value > wrap_cutoff then
        return number_value - wrap_modulus
      end

      return number_value
    end,
    function(value, device, context)
      local number_value = tonumber_check(value)
      local wrap_modulus = resolve_numeric_arg(modulus, device, context)
      if number_value == nil or wrap_modulus == nil then
        log.warn("Tuya wrapped_signed expects numeric input and modulus")
        return nil
      end

      if number_value < 0 then
        return wrap_modulus + number_value
      end

      return number_value
    end
  )
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

function converter.invert_bool()
  return function(value)
    if type_check(value) == "boolean" then
      return not value
    end

    log.warn(string.format("Tuya invert_bool expects boolean, got %s", type_check(value)))
    return nil
  end
end

function converter.convert_temperature_unit(from_unit, to_unit)
  return function(value, device, context)
    local number_value = tonumber_check(value)
    local source_unit = resolve_converter_arg(from_unit, device, context)
    local target_unit = resolve_converter_arg(to_unit, device, context)

    if number_value == nil then
      log.warn(string.format("Tuya convert_temperature_unit expects number, got %s", type_check(value)))
      return nil
    end

    if source_unit == nil or target_unit == nil or source_unit == target_unit then
      return number_value
    end

    if source_unit == "C" and target_unit == "F" then
      return utils.c_to_f(number_value)
    end

    if source_unit == "F" and target_unit == "C" then
      return utils.f_to_c(number_value)
    end

    log.warn(string.format("Unsupported temperature unit conversion: %s -> %s", tostring(source_unit), tostring(target_unit)))
    return number_value
  end
end

function converter.signed_offset(offset, min_value, max_value)
  return function(value, device, context)
    local number_value = tonumber_check(value)
    local offset_value = resolve_numeric_arg(offset, device, context)
    if offset_value == nil and offset ~= nil then
      log.warn("Tuya signed_offset expects numeric input and offset")
      return nil
    end

    if number_value == nil then
      log.warn("Tuya signed_offset expects numeric input and offset")
      return nil
    end

    offset_value = offset_value or 0
    local result = number_value + offset_value
    local low = resolve_numeric_arg(min_value, device, context)
    local high = resolve_numeric_arg(max_value, device, context)

    if low ~= nil and result < low then
      result = low
    end
    if high ~= nil and result > high then
      result = high
    end

    return result
  end
end

function converter.phase_variant1_parser(phase)
  return function(value)
    return tuya.parse_phase_variant1(value, phase)
  end
end

function converter.phase_variant2_parser(phase, signed_power)
  return function(value)
    return tuya.parse_phase_variant2(value, phase, signed_power)
  end
end

function converter.phase_variant3_parser(phase)
  return function(value)
    return tuya.parse_phase_variant3(value, phase)
  end
end

function converter.threshold_parser()
  return function(value)
    return tuya.parse_threshold(value)
  end
end

function converter.inching_switch()
  return converter.from_to(
    function(value)
      local raw = raw_bytes(value)
      if raw == nil or string_len(raw) < 3 then
        log.warn("Tuya inching_switch expects at least 3 bytes")
        return nil
      end

      local state = string_byte(raw, 1)
      local duration = string_byte(raw, 2) * 256 + string_byte(raw, 3)
      return { state = (state ~= 0), duration = duration }
    end,
    function(value)
      if type_check(value) ~= "table" then
        log.warn("Tuya inching_switch expects table {state, duration}")
        return nil
      end

      local state = value.state and 1 or 0
      local duration = tonumber_check(value.duration) or 0
      return string_char(state, math_floor(duration / 256) % 256, duration % 256)
    end
  )
end

function converter.cover_position_inverted()
  return converter.from_to(
    function(value)
      local number_value = tonumber_check(value)
      if number_value == nil then
        log.warn("Tuya cover_position_inverted expects number")
        return nil
      end
      return 100 - number_value
    end,
    function(value)
      local number_value = tonumber_check(value)
      if number_value == nil then
        log.warn("Tuya cover_position_inverted expects number")
        return nil
      end
      return 100 - number_value
    end
  )
end

function converter.light_type()
  return converter.lookup_from_to({
    led = 0,
    incandescent = 1,
    halogen = 2,
  })
end

function converter.light_mode()
  return converter.lookup_from_to({
    normal = 0,
    on = 1,
    off = 2,
    flash = 3,
  })
end

function converter.motor_direction()
  return converter.lookup_from_to({
    normal = 0,
    reversed = 1,
  })
end

function converter.error_or_battery_low()
  return converter.from_only(function(value)
    local number_value = tonumber_check(value)
    if number_value == nil then
      return nil
    end

    if number_value == 0 then
      return { battery_low = false }
    end

    if number_value == 1 then
      return { battery_low = true }
    end

    return { error = number_value }
  end)
end

function converter.switch_mode_curtain()
  return converter.lookup_from_to({
    switch = 0,
    curtain = 1,
  })
end

function converter.color_power_on_behavior()
  return converter.lookup_from_to({
    initial = 0,
    previous = 1,
    customized = 2,
  })
end

function converter.tuya_unsigned_temp(scale)
  local divisor = scale or 10
  return converter.from_to(
    function(value)
      if value == nil then return nil end
      local v = value
      if v > 0x2000 then
        v = v - 0xFFFF
      end
      return v / divisor
    end,
    function(value)
      if value == nil then return nil end
      local raw = math_floor(value * divisor + 0.5)
      if raw < 0 then
        raw = raw + 0xFFFF
      end
      return raw
    end
  )
end

end

return load_converter
