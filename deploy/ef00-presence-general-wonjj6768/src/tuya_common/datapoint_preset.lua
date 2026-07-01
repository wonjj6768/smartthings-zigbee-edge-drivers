local function load_datapoint_preset(tuya, shared)
  local type_check = shared.type_check
  local table_insert = shared.table_insert
  local tonumber_check = shared.tonumber_check
  local merge_options = shared.merge_options
  local copy_keys = shared.copy_keys

  local converter = tuya.converter

  local function apply_defaults(target, defaults)
    if type_check(target) ~= "table" or type_check(defaults) ~= "table" then
      return target
    end

    for key, value in pairs(defaults) do
      if target[key] == nil then
        target[key] = value
      end
    end

    return target
  end

  local function normalize_preset_options(name_or_options, options, default_name)
    local resolved = {}

    if type_check(name_or_options) == "string" then
      resolved.name = name_or_options
    else
      merge_options(resolved, name_or_options)
    end

    merge_options(resolved, options)

    if resolved.name == nil and default_name ~= nil then
      resolved.name = default_name
    end

    return resolved
  end

  local send_policy_option_keys = {
    "send_policy",
    "command_id",
    "transaction",
    "batch_key",
    "match_transaction",
    "response_dp",
    "response_dps",
    "match_response",
  }

  local function has_send_policy_options(options)
    if type_check(options) ~= "table" then
      return false
    end

    for _, key in ipairs(send_policy_option_keys) do
      if options[key] ~= nil then
        return true
      end
    end

    return false
  end

  local function apply_default_fixed_send_policy(mapping, options)
    if has_send_policy_options(options) then
      return mapping
    end

    return tuya.apply_fixed_send_policy(mapping)
  end

  local function build_scaled_numeric_preset(dp, default_name, name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options, default_name)
    local scale = resolved.scale
    if scale == nil then
      scale = 10
    end

    if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and scale ~= 1 then
      resolved.converter = converter.divide_by_pair(scale)
    end

    resolved.scale = nil
    return tuya.dp_numeric(dp, resolved)
  end

  local function build_divided_numeric_preset(dp, default_name, default_scale, name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options, default_name)
    local scale = resolved.scale
    if scale == nil then
      scale = default_scale
    end

    if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and scale ~= 1 then
      resolved.converter = converter.divide_by_pair(scale)
    end

    resolved.scale = nil
    return tuya.dp_numeric(dp, resolved)
  end

  local function build_power_numeric_preset(dp, default_name, default_scale, name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options, default_name)
    local scale = resolved.scale
    if scale == nil then
      scale = default_scale
    end

    if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil then
      local power_converter = converter.power()
      local from_device = power_converter.from
      if scale ~= 1 then
        resolved.from_device = converter.pipe(
          from_device,
          converter.divide_by(scale)
        )
      else
        resolved.converter = power_converter
      end
    end

    resolved.scale = nil
    return tuya.dp_numeric(dp, resolved)
  end

  local function build_signed_numeric_preset(dp, default_name, default_scale, name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options, default_name)
    local scale = resolved.scale
    if scale == nil then
      scale = default_scale
    end

    if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil then
      resolved.converter = converter.signed_number_pair(scale)
    end

    if resolved.signed == nil then
      resolved.signed = true
    end

    resolved.scale = nil
    return tuya.dp_numeric(dp, resolved)
  end

  local function build_raw_aware_numeric_preset(dp, default_name, default_scale, raw_defaults, name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options, default_name)
    local scale = resolved.scale
    if scale == nil then
      scale = default_scale
    end

    local wants_raw =
      resolved.datatype == tuya.DP_TYPE_RAW or
      resolved.raw == true or
      resolved.raw_bytes ~= nil or
      resolved.raw_length ~= nil or
      resolved.raw_from_tail ~= nil or
      resolved.raw_start ~= nil or
      resolved.raw_offset ~= nil

    if wants_raw and resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil then
      local raw_options = {
        bytes = resolved.raw_bytes or resolved.raw_length,
        length = resolved.raw_length,
        from_tail = resolved.raw_from_tail,
        start = resolved.raw_start,
        offset = resolved.raw_offset,
      }
      apply_defaults(raw_options, raw_defaults)
      resolved.converter = converter.raw_uint_be(scale, raw_options)
      if resolved.datatype == nil then
        resolved.datatype = tuya.DP_TYPE_RAW
      end
    elseif resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and scale ~= 1 then
      resolved.converter = converter.divide_by_pair(scale)
    end

    resolved.scale = nil
    resolved.raw = nil
    resolved.raw_bytes = nil
    resolved.raw_length = nil
    resolved.raw_from_tail = nil
    resolved.raw_start = nil
    resolved.raw_offset = nil
    return tuya.dp_numeric(dp, resolved)
  end

  local function invert_numeric_value(value, min_value, max_value)
    local number_value = tonumber_check(value)
    if number_value == nil then
      return nil
    end

    return min_value + max_value - number_value
  end

  local function build_ranged_numeric_preset(dp, default_name, defaults, name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options, default_name)
    local raw_min = resolved.raw_min
    if raw_min == nil then
      raw_min = defaults.raw_min
    end

    local raw_max = resolved.raw_max
    if raw_max == nil then
      raw_max = defaults.raw_max
    end

    local value_min = resolved.value_min
    if value_min == nil then
      value_min = defaults.value_min
    end

    local value_max = resolved.value_max
    if value_max == nil then
      value_max = defaults.value_max
    end

    local invert = resolved.invert == true or resolved.invert_position == true
    if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil then
      if invert then
        local from_scale = converter.scale(raw_min, raw_max, value_min, value_max)
        local to_scale = converter.scale(value_min, value_max, raw_min, raw_max)
        resolved.converter = converter.from_to(
          function(value, device, context)
            local scaled = from_scale(value, device, context)
            if scaled == nil then
              return nil
            end

            return invert_numeric_value(scaled, value_min, value_max)
          end,
          function(value, device, context)
            local inverted = invert_numeric_value(value, value_min, value_max)
            if inverted == nil then
              return nil
            end

            return to_scale(inverted, device, context)
          end
        )
      elseif raw_min ~= value_min or raw_max ~= value_max then
        resolved.converter = converter.scale_pair(raw_min, raw_max, value_min, value_max)
      end
    end

    resolved.raw_min = nil
    resolved.raw_max = nil
    resolved.value_min = nil
    resolved.value_max = nil
    resolved.invert = nil
    resolved.invert_position = nil

    return tuya.dp_numeric(dp, resolved)
  end

  local function phase_name(phase, fallback)
    if type_check(phase) == "string" and phase ~= "" then
      return (fallback or "phase") .. "_" .. phase
    end

    return fallback or "phase"
  end

  local function phase_fields(keys, phase)
    local fields = {}

    for _, key in ipairs(keys or {}) do
      local field_name = key
      if type_check(phase) == "string" and phase ~= "" then
        field_name = key .. "_" .. phase
      end

      fields[field_name] = true
    end

    return fields
  end

  local function build_phase_raw_preset(dp, default_name, parser_builder, field_keys, name_or_options, options)
    local explicit_name =
      type_check(name_or_options) == "string" or
      (type_check(name_or_options) == "table" and name_or_options.name ~= nil) or
      (type_check(options) == "table" and options.name ~= nil)
    local resolved = normalize_preset_options(name_or_options, options, default_name)
    local phase = resolved.phase

    if not explicit_name and resolved.name == default_name then
      resolved.name = phase_name(phase, default_name)
    end

    if resolved.read_only == nil then
      resolved.read_only = true
    end

    if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil then
      resolved.converter = parser_builder(resolved)
    end

    if resolved.field == nil and resolved.fields == nil then
      resolved.fields = phase_fields(field_keys, phase)
    end

    return tuya.dp_raw(dp, resolved)
  end

  local function build_threshold_preset(dp, name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options, "threshold")

    if resolved.read_only == nil then
      resolved.read_only = true
    end

    if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil then
      resolved.converter = converter.threshold_parser()
    end

    if resolved.field == nil and resolved.fields == nil then
      resolved.fields = {
        threshold_1 = true,
        threshold_1_protection = true,
        threshold_1_value = true,
        threshold_2 = true,
        threshold_2_protection = true,
        threshold_2_value = true,
      }
    end

    return tuya.dp_raw(dp, resolved)
  end

  local function integer_dp_list(dp_list)
    if type_check(dp_list) == "number" and dp_list % 1 == 0 and dp_list >= 0 then
      return { dp_list }
    end

    if type_check(dp_list) ~= "table" then
      return {}
    end

    local normalized = {}
    for _, dp in ipairs(dp_list) do
      if type_check(dp) == "number" and dp % 1 == 0 and dp >= 0 then
        table_insert(normalized, dp)
      end
    end

    return normalized
  end

  local function resolve_list_source(options)
    if type_check(options) ~= "table" then
      return options
    end

    local dp_list = options.dps
    if dp_list == nil then
      dp_list = options.dp_list
    end

    if dp_list == nil and options[1] ~= nil then
      dp_list = options
    end

    return dp_list
  end

  local function resolve_list_or_dp_source(options)
    local dp_list = resolve_list_source(options)
    if dp_list ~= nil then
      return dp_list
    end

    if type_check(options) ~= "table" then
      return options
    end

    return options.dp
  end

  local function phase_for_index(index, options)
    options = options or {}

    local phases = options.phases
    if type_check(phases) ~= "table" then
      phases = options.phase_names
    end

    local phase = type_check(phases) == "table" and phases[index] or nil
    if type_check(phase) == "string" and phase ~= "" then
      return phase
    end

    local phase_prefix = options.phase_prefix
    if phase_prefix == false then
      return nil
    end

    if type_check(phase_prefix) ~= "string" or phase_prefix == "" then
      phase_prefix = nil
    end

    if phase_prefix ~= nil then
      return phase_prefix .. tostring(index)
    end

    return tostring(index)
  end

  local function component_name_for_index(index, options)
    options = options or {}

    local first_is_main = options.first_is_main ~= false
    local component_prefix = options.component_prefix
    if type_check(component_prefix) ~= "string" or component_prefix == "" then
      component_prefix = "switch"
    end

    local main_component = options.main_component
    if type_check(main_component) ~= "string" or main_component == "" then
      main_component = "main"
    end

    local index_offset = options.index_offset
    if type_check(index_offset) ~= "number" or index_offset % 1 ~= 0 then
      index_offset = 0
    end

    if index == 1 and first_is_main then
      return main_component
    end

    local suffix = first_is_main and (index - 1 + index_offset) or (index + index_offset)
    if suffix < 1 then
      return options.default_component
    end

    return component_prefix .. tostring(suffix)
  end

  local function key_name_for_index(index, options, default_prefix)
    options = options or {}

    local first_is_main = options.first_is_main ~= false
    local key_prefix = options.key_prefix
    if type_check(key_prefix) ~= "string" or key_prefix == "" then
      key_prefix = default_prefix or "switch"
    end

    local main_key = options.main_key
    if type_check(main_key) ~= "string" or main_key == "" then
      main_key = key_prefix
    end

    local index_offset = options.index_offset
    if type_check(index_offset) ~= "number" or index_offset % 1 ~= 0 then
      index_offset = 0
    end

    if index == 1 and first_is_main then
      return main_key
    end

    local suffix = first_is_main and (index - 1 + index_offset) or (index + index_offset)
    if suffix < 1 then
      return options.default_key
    end

    return key_prefix .. tostring(suffix)
  end

  local function append_preset(datapoints, dp, builder, options)
    if type_check(dp) ~= "number" or dp % 1 ~= 0 or dp < 0 then
      return
    end

    table_insert(datapoints, builder(dp, options))
  end

  local function append_preset_list(target, items)
    if type_check(items) ~= "table" then
      return target
    end

    for _, item in ipairs(items) do
      table_insert(target, item)
    end

    return target
  end

  local gang_shared_option_keys = {
    "first_is_main",
    "main_component",
    "component_prefix",
    "index_offset",
    "default_component",
    "key_prefix",
    "main_key",
    "default_key",
  }

  local function is_positive_integer(value)
    return type_check(value) == "number" and value % 1 == 0 and value > 0
  end

  local function copy_parent_group_options(options, keep_direct_source)
    local resolved = {}
    if type_check(options) ~= "table" then
      return resolved
    end

    for key, value in pairs(options) do
      local keep_key = true

      if not keep_direct_source then
        if key == "dp" or key == "dps" or key == "dp_list" then
          keep_key = false
        elseif is_positive_integer(key) then
          keep_key = false
        end
      end

      if keep_key then
        resolved[key] = value
      end
    end

    return resolved
  end

  local function has_direct_source_options(options)
    if type_check(options) ~= "table" then
      return false
    end

    if options.dp ~= nil or options.dps ~= nil or options.dp_list ~= nil or options[1] ~= nil then
      return true
    end

    return false
  end

  local function clear_direct_source_options(options)
    if type_check(options) ~= "table" then
      return options
    end

    options.dp = nil
    options.dps = nil
    options.dp_list = nil

    local index = 1
    while options[index] ~= nil do
      options[index] = nil
      index = index + 1
    end

    return options
  end

  local function resolve_group_options(options, group_name, keep_direct_source)
    if type_check(options) ~= "table" then
      return {}
    end

    local grouped = options[group_name]
    if grouped == nil then
      return copy_parent_group_options(options, keep_direct_source)
    end

    local resolved = copy_parent_group_options(options, keep_direct_source)

    if type_check(grouped) == "table" then
      merge_options(resolved, grouped)
    else
      resolved.dp = grouped
    end

    return resolved
  end

  local function normalize_direct_group_options(grouped)
    if grouped == nil then
      return nil
    end

    if type_check(grouped) == "table" then
      return grouped
    end

    return { dp = grouped }
  end

  local function direct_group_options(options, group_name)
    if type_check(options) ~= "table" then
      return nil
    end

    return normalize_direct_group_options(options[group_name])
  end

  local function resolve_item_options(parent_options, group_options)
    local parent_item_options = type_check(parent_options) == "table" and parent_options.item_options or nil
    local group_item_options = type_check(group_options) == "table" and group_options.item_options or nil

    if type_check(parent_item_options) ~= "table" then
      return type_check(group_item_options) == "table" and group_item_options or nil
    end

    if type_check(group_item_options) ~= "table" then
      return parent_item_options
    end

    local resolved = {}
    merge_options(resolved, parent_item_options)
    merge_options(resolved, group_item_options)
    return resolved
  end

  local function build_gang_group_options(options, group_name, default_key_prefix, keep_direct_source)
    local resolved = {}
    local grouped = nil
    if type_check(options) == "table" then
      copy_keys(resolved, options, gang_shared_option_keys)

      grouped = options[group_name]
      if type_check(grouped) == "table" then
        merge_options(resolved, copy_parent_group_options(options, keep_direct_source))
        if keep_direct_source and has_direct_source_options(grouped) then
          clear_direct_source_options(resolved)
        end
        merge_options(resolved, grouped)
      elseif grouped ~= nil then
        merge_options(resolved, copy_parent_group_options(options, keep_direct_source))
        if keep_direct_source then
          clear_direct_source_options(resolved)
        end
        resolved.dp = grouped
      else
        merge_options(resolved, copy_parent_group_options(options, keep_direct_source))
      end
    end

    if resolved.key_prefix == nil and default_key_prefix ~= nil then
      resolved.key_prefix = default_key_prefix
    end

    resolved.item_options = resolve_item_options(options, grouped)

    return resolved
  end

  local function build_switch_config_variant_options(options, variant_group_name)
    local config_options = {}
    local direct_config_options = direct_group_options(options, "config")
    merge_options(config_options, direct_config_options)

    local variant_group = normalize_direct_group_options(config_options[variant_group_name])
    if variant_group ~= nil then
      config_options[variant_group_name] = variant_group
    else
      local source_group = normalize_direct_group_options(config_options.switch_type)
      if source_group == nil then
        source_group = direct_group_options(options, "switch_type")
      end

      if type_check(source_group) == "table" then
        config_options[variant_group_name] = source_group
      end
    end

    if variant_group_name ~= "switch_type" then
      config_options.switch_type = nil
    end

    if next(config_options) ~= nil then
      return config_options
    end

    return {}
  end

  local function build_switch_module_variant_options(options, variant_group_name)
    local resolved = {}
    if type_check(options) == "table" then
      merge_options(resolved, options)
    end

    local config_options = build_switch_config_variant_options(options, variant_group_name)
    if next(config_options) ~= nil then
      resolved.config = config_options
    end

    resolved.switch_type = nil
    return resolved
  end

  local function build_plug_variant_options(options, variant_group_name)
    local resolved = {}
    if type_check(options) == "table" then
      merge_options(resolved, options)
    end

    local switch_module_options = build_switch_module_variant_options(
      resolve_group_options(options, "switch_module"),
      variant_group_name
    )
    if next(switch_module_options) ~= nil then
      resolved.switch_module = switch_module_options
    end

    return resolved
  end

  local function append_group_preset(datapoints, options, group_name, builder)
    local group_options = resolve_group_options(options, group_name)
    append_preset(datapoints, group_options.dp, builder, group_options)
  end

  local function append_group_preset_with_defaults(datapoints, options, group_name, builder, defaults)
    local group_options = resolve_group_options(options, group_name)
    apply_defaults(group_options, defaults)
    append_preset(datapoints, group_options.dp, builder, group_options)
  end

  local function append_group_or_list_preset(datapoints, options, group_name, builder, list_builder)
    local group_options = resolve_group_options(options, group_name)
    local dp_list = resolve_list_source(group_options)

    if dp_list ~= nil and list_builder ~= nil then
      append_preset_list(datapoints, list_builder(dp_list, group_options))
      return
    end

    append_preset(datapoints, group_options.dp, builder, group_options)
  end

  local function append_gang_group_preset_list(datapoints, options, group_name, default_key_prefix, builder)
    local group_options = build_gang_group_options(options, group_name, default_key_prefix)
    append_preset_list(datapoints, builder(resolve_list_or_dp_source(group_options), group_options))
  end

  local function build_gang_datapoints(dp_list, builder, default_name, options)
    local datapoints = {}
    local resolved_dps = integer_dp_list(dp_list)
    local item_options = type_check(options) == "table" and options.item_options or nil

    for index, dp in ipairs(resolved_dps) do
      local resolved = normalize_preset_options(item_options, nil, default_name)
      if resolved.component == nil then
        resolved.component = component_name_for_index(index, options)
      end
      if resolved.key == nil and resolved.preference == nil then
        resolved.key = key_name_for_index(index, options, default_name)
      end
      if resolved.field == nil and resolved.fields == nil and resolved.key ~= nil then
        resolved.field = resolved.key
      end

      table_insert(datapoints, builder(dp, resolved))
    end

    return datapoints
  end

  local function build_phase_meter_datapoints(dp_list, builder, options)
    local datapoints = {}
    local resolved_dps = integer_dp_list(dp_list)
    local item_options = type_check(options) == "table" and options.item_options or nil

    for index, dp in ipairs(resolved_dps) do
      local resolved = normalize_preset_options(item_options, nil, nil)
      if resolved.phase == nil then
        resolved.phase = phase_for_index(index, options)
      end

      table_insert(datapoints, builder(dp, resolved))
    end

    return datapoints
  end

  local function build_single_group_datapoints(options, group_name, builder)
    local group_options = nil
    if type_check(options) == "table" then
      group_options = resolve_group_options(options, group_name, true)
    else
      group_options = { dp = options }
    end

    local datapoints = {}
    append_preset(datapoints, group_options.dp, builder, group_options)
    return datapoints
  end
  function tuya.dp_on_off(dp, name_or_options, options)
    return tuya.dp_binary(dp, normalize_preset_options(name_or_options, options, "switch"))
  end
  function tuya.dp_temperature(dp, name_or_options, options)
    return build_scaled_numeric_preset(dp, "temperature", name_or_options, options)
  end
  function tuya.dp_humidity(dp, name_or_options, options)
    return build_scaled_numeric_preset(dp, "humidity", name_or_options, options)
  end
  function tuya.dp_battery(dp, name_or_options, options)
    return build_divided_numeric_preset(dp, "battery", 1, name_or_options, options)
  end
  function tuya.dp_occupancy(dp, name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options, "occupancy")
    if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
      resolved.converter = converter.true_false0()
    end

    return tuya.dp_binary(dp, resolved)
  end
  function tuya.dp_illuminance(dp, name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options, "illuminance")
    return tuya.dp_numeric(dp, resolved)
  end
  function tuya.dp_temperature_unit(dp, name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options, "temperature_unit")
    if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
      resolved.converter = converter.temperature_unit()
    end

    return tuya.dp_enum(dp, resolved)
  end
  function tuya.dp_power_outage_memory(dp, name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options, "power_outage_memory")
    if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
      resolved.converter = converter.power_outage_memory()
    end

    return apply_default_fixed_send_policy(tuya.dp_enum(dp, resolved), resolved)
  end
  function tuya.dp_temperature_calibration(dp, name_or_options, options)
    return build_signed_numeric_preset(dp, "temperature_calibration", 10, name_or_options, options)
  end
  function tuya.dp_humidity_calibration(dp, name_or_options, options)
    return build_signed_numeric_preset(dp, "humidity_calibration", 1, name_or_options, options)
  end
  function tuya.dp_alarm_time(dp, name_or_options, options)
    return apply_default_fixed_send_policy(
      build_divided_numeric_preset(dp, "alarm_time", 1, name_or_options, options),
      normalize_preset_options(name_or_options, options, "alarm_time")
    )
  end
  function tuya.dp_alarm_volume(dp, name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options, "alarm_volume")
    if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
      resolved.converter = converter.alarm_volume()
    end

    return apply_default_fixed_send_policy(tuya.dp_enum(dp, resolved), resolved)
  end
  function tuya.dp_pir_sensitivity(dp, name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options, "sensitivity")
    if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
      resolved.converter = converter.pir_sensitivity_low_medium_high()
    end

    return apply_default_fixed_send_policy(tuya.dp_enum(dp, resolved), resolved)
  end
  function tuya.dp_keep_time(dp, name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options, "keep_time")
    if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
      resolved.converter = converter.pir_keep_time_ten_thirty_sixty_one_twenty()
    end

    return apply_default_fixed_send_policy(tuya.dp_enum(dp, resolved), resolved)
  end
  function tuya.dp_presence(dp, name_or_options, options)
    return tuya.dp_binary(dp, normalize_preset_options(name_or_options, options, "presence"))
  end
  function tuya.dp_motion_state(dp, name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options, "motion_state")
    if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
      resolved.converter = converter.motion_state()
    end

    return tuya.dp_enum(dp, resolved)
  end
  function tuya.dp_indicator(dp, name_or_options, options)
    return tuya.dp_binary(dp, normalize_preset_options(name_or_options, options, "indicator"))
  end
  function tuya.dp_fading_time(dp, name_or_options, options)
    return build_divided_numeric_preset(dp, "fading_time", 1, name_or_options, options)
  end
  function tuya.dp_illuminance_interval(dp, name_or_options, options)
    return build_divided_numeric_preset(dp, "illuminance_interval", 1, name_or_options, options)
  end
  function tuya.dp_static_detection_distance(dp, name_or_options, options)
    return build_divided_numeric_preset(dp, "static_detection_distance", 100, name_or_options, options)
  end
  function tuya.dp_static_detection_sensitivity(dp, name_or_options, options)
    return build_divided_numeric_preset(dp, "static_detection_sensitivity", 1, name_or_options, options)
  end
  function tuya.dp_motion_detection_mode(dp, name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options, "motion_detection_mode")
    if resolved.converter == nil and resolved.from_device == nil and resolved.to_device == nil and resolved.lookup == nil then
      resolved.converter = converter.motion_detection_mode()
    end

    return tuya.dp_enum(dp, resolved)
  end
  function tuya.dp_motion_detection_sensitivity(dp, name_or_options, options)
    return build_divided_numeric_preset(dp, "motion_detection_sensitivity", 1, name_or_options, options)
  end
  function tuya.dp_target_distance(dp, name_or_options, options)
    return build_divided_numeric_preset(dp, "target_distance", 100, name_or_options, options)
  end
end

return load_datapoint_preset
