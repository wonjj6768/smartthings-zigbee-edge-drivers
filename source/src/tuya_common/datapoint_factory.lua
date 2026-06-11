local function load_datapoint_factory(tuya, shared)
  local type_check = shared.type_check
  local copy_keys = shared.copy_keys
  local merge_options = shared.merge_options

  local converter = tuya.converter

  local passthrough_mapping_keys = {
    "name",
    "key",
    "preference",
    "field",
    "fields",
    "emit",
    "handler",
    "endpoint",
    "component",
    "persist",
    "read_only",
    "write_only",
    "command_id",
    "transaction",
    "signed",
    "batch_key",
    "match_transaction",
    "response_dp",
    "response_dps",
    "match_response",
    "skip",
    "value",
    "converter",
    "from_device",
    "to_device",
  }
  local send_policy_keys = {
    "command_id",
    "transaction",
    "batch_key",
    "match_transaction",
    "response_dp",
    "response_dps",
    "match_response",
  }

  local function is_converter_pair(value)
    return type_check(value) == "table" and (type_check(value.from) == "function" or type_check(value.to) == "function")
  end

  local function normalize_factory_args(name_or_options, converter_or_options, options)
    local resolved_name = nil
    local resolved_converter = nil
    local resolved_options = {}

    if type_check(name_or_options) == "string" then
      resolved_name = name_or_options
    else
      merge_options(resolved_options, name_or_options)
    end

    if type_check(converter_or_options) == "function" then
      resolved_options.from_device = converter_or_options
    elseif is_converter_pair(converter_or_options) then
      resolved_converter = converter_or_options
    else
      merge_options(resolved_options, converter_or_options)
    end

    merge_options(resolved_options, options)

    if is_converter_pair(resolved_options.converter) then
      resolved_converter = resolved_options.converter
    end

    return resolved_name, resolved_converter, resolved_options
  end

  local function build_factory_mapping(dp, default_datatype, name_or_options, converter_or_options, options)
    local resolved_name, resolved_converter, resolved_options =
      normalize_factory_args(name_or_options, converter_or_options, options)

    local mapping = {
      dp = dp,
      datatype = resolved_options.datatype or default_datatype,
    }

    copy_keys(mapping, resolved_options, passthrough_mapping_keys)

    if type_check(resolved_options.send_policy) == "table" then
      for _, key in ipairs(send_policy_keys) do
        if mapping[key] == nil and resolved_options.send_policy[key] ~= nil then
          mapping[key] = resolved_options.send_policy[key]
        end
      end
    end

    if mapping.name == nil and resolved_name ~= nil then
      mapping.name = resolved_name
    end

    local default_field_name = mapping.name or mapping.key
    if mapping.field == nil and mapping.fields == nil and default_field_name ~= nil then
      mapping.field = default_field_name
    end

    if resolved_converter ~= nil and mapping.converter == nil and mapping.from_device == nil and mapping.to_device == nil then
      mapping.converter = resolved_converter
    end

    return mapping, resolved_options
  end

  local function normalize_context_endpoint(context)
    if type_check(context) ~= "table" then
      return nil
    end

    local endpoint = context.endpoint or context.src_endpoint
    if endpoint == nil and type_check(context.dp_info) == "table" then
      endpoint = context.dp_info.endpoint
    end

    if type_check(endpoint) ~= "number" or endpoint % 1 ~= 0 or endpoint < 1 then
      return nil
    end

    return endpoint
  end

  local function normalize_context_dp(context)
    if type_check(context) ~= "table" then
      return nil
    end

    local dp = context.dp
    if dp == nil and type_check(context.mapping) == "table" then
      dp = context.mapping.dp
    end

    if type_check(dp) ~= "number" or dp % 1 ~= 0 or dp < 0 then
      return nil
    end

    return dp
  end

  function tuya.dp_binary(dp, name_or_options, converter_or_options, options)
    local mapping, resolved_options = build_factory_mapping(dp, tuya.DP_TYPE_BOOL, name_or_options, converter_or_options, options)

    if mapping.converter == nil and mapping.from_device == nil and mapping.to_device == nil then
      local true_value = resolved_options.true_value
      local false_value = resolved_options.false_value
      if true_value ~= nil or false_value ~= nil then
        mapping.converter = converter.bool_pair(true_value == nil and true or true_value, false_value == nil and false or false_value)
      end
    end

    return mapping
  end

  function tuya.dp_raw(dp, name_or_options, converter_or_options, options)
    local mapping = build_factory_mapping(dp, tuya.DP_TYPE_RAW, name_or_options, converter_or_options, options)
    return mapping
  end

  function tuya.dp_numeric(dp, name_or_options, converter_or_options, options)
    local mapping = build_factory_mapping(dp, tuya.DP_TYPE_VALUE, name_or_options, converter_or_options, options)
    return mapping
  end

  function tuya.dp_string(dp, name_or_options, converter_or_options, options)
    local mapping = build_factory_mapping(dp, tuya.DP_TYPE_STRING, name_or_options, converter_or_options, options)
    return mapping
  end

  function tuya.dp_enum(dp, name_or_options, converter_or_options, options)
    local mapping, resolved_options = build_factory_mapping(dp, tuya.DP_TYPE_ENUM, name_or_options, converter_or_options, options)

    if mapping.converter == nil and mapping.from_device == nil and mapping.to_device == nil and resolved_options.lookup ~= nil then
      mapping.converter = converter.lookup_from_to(resolved_options.lookup)
    end

    return mapping
  end

  function tuya.dp_bitmap(dp, name_or_options, converter_or_options, options)
    local mapping = build_factory_mapping(dp, tuya.DP_TYPE_BITMAP, name_or_options, converter_or_options, options)
    return mapping
  end

  function tuya.dp_light(dp, name_or_options, converter_or_options, options)
    local mapping, resolved_options = build_factory_mapping(dp, tuya.DP_TYPE_VALUE, name_or_options, converter_or_options, options)

    if mapping.converter == nil and mapping.from_device == nil and mapping.to_device == nil then
      local raw_min = resolved_options.raw_min or 0
      local raw_max = resolved_options.raw_max or 1000
      local value_min = resolved_options.value_min or 0
      local value_max = resolved_options.value_max or 100
      mapping.converter = converter.scale_pair(raw_min, raw_max, value_min, value_max)
    end

    return mapping
  end

  function tuya.build_component_by_endpoint(endpoint_map, default_component)
    return function(device, context)
      local endpoint = normalize_context_endpoint(context)
      if endpoint == nil or type_check(endpoint_map) ~= "table" then
        return default_component
      end

      local component_id = endpoint_map[endpoint]
      if type_check(component_id) == "string" and component_id ~= "" then
        return component_id
      end

      return default_component
    end
  end

  function tuya.build_component_by_dp(dp_map, default_component)
    return function(device, context)
      local dp = normalize_context_dp(context)
      if dp == nil or type_check(dp_map) ~= "table" then
        return default_component
      end

      local component_id = dp_map[dp]
      if type_check(component_id) == "string" and component_id ~= "" then
        return component_id
      end

      return default_component
    end
  end

  function tuya.build_component_suffix(component_prefix, options)
    options = options or {}

    local prefix = component_prefix
    if type_check(prefix) ~= "string" or prefix == "" then
      prefix = "switch"
    end

    local main_endpoint = options.main_endpoint
    if type_check(main_endpoint) ~= "number" or main_endpoint % 1 ~= 0 or main_endpoint < 1 then
      main_endpoint = 1
    end

    local main_component = options.main_component
    if type_check(main_component) ~= "string" or main_component == "" then
      main_component = "main"
    end

    local index_offset = options.index_offset
    if type_check(index_offset) ~= "number" or index_offset % 1 ~= 0 then
      index_offset = 0
    end

    local default_component = options.default_component

    return function(device, context)
      local endpoint = normalize_context_endpoint(context)
      if endpoint == nil then
        return default_component
      end

      if endpoint == main_endpoint then
        return main_component
      end

      local suffix = endpoint - main_endpoint + index_offset
      if suffix < 1 then
        return default_component
      end

      return prefix .. tostring(suffix)
    end
  end

  function tuya.build_component_suffix_by_dp(dp_list, options)
    options = options or {}

    local prefix = options.component_prefix
    if type_check(prefix) ~= "string" or prefix == "" then
      prefix = "switch"
    end

    local main_component = options.main_component
    if type_check(main_component) ~= "string" or main_component == "" then
      main_component = "main"
    end

    local default_component = options.default_component
    local index_offset = options.index_offset
    if type_check(index_offset) ~= "number" or index_offset % 1 ~= 0 then
      index_offset = 0
    end

    local first_is_main = options.first_is_main ~= false
    local component_map = {}

    if type_check(dp_list) == "table" then
      for index, dp in ipairs(dp_list) do
        if type_check(dp) == "number" and dp % 1 == 0 and dp >= 0 then
          if index == 1 and first_is_main then
            component_map[dp] = main_component
          else
            local suffix = first_is_main and (index - 1 + index_offset) or (index + index_offset)
            if suffix >= 1 then
              component_map[dp] = prefix .. tostring(suffix)
            end
          end
        end
      end
    end

    return tuya.build_component_by_dp(component_map, default_component)
  end
end

return load_datapoint_factory
