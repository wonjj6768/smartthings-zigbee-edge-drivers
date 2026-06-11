local function load_policy_helper(tuya, shared)
  local type_check = shared.type_check
  local merge_options = shared.merge_options
  local copy_table = shared.copy_table

  local string_lower = string.lower

  local send_policy_keys = {
    "command_id",
    "transaction",
    "batch_key",
    "match_transaction",
    "response_dp",
    "response_dps",
    "match_response",
  }

  local function normalize_policy_options(command_id_or_options, options)
    local resolved = {}

    if type_check(command_id_or_options) == "table" then
      merge_options(resolved, command_id_or_options)
    elseif command_id_or_options ~= nil then
      resolved.command_id = command_id_or_options
    end

    merge_options(resolved, options)
    return resolved
  end

  local function normalize_state_value(value)
    if value == true or value == 1 then
      return true
    end

    if value == false or value == 0 then
      return false
    end

    if type_check(value) == "string" then
      local lowered = string_lower(value)
      if lowered == "on" then
        return true
      end

      if lowered == "off" then
        return false
      end
    end

    return value
  end

  local function values_from_context(context)
    if type_check(context) ~= "table" then
      return nil
    end

    if type_check(context.values) == "table" then
      return context.values
    end

    return nil
  end

  local function state_matches(device, context, value, options)
    if type_check(options.current) == "function" then
      return normalize_state_value(options.current(device, context, value)) == normalize_state_value(value)
    end

    local state_field = options.state_field
    if type_check(state_field) ~= "string" or state_field == "" then
      state_field = "switch"
    end

    return normalize_state_value(device:get_field(state_field)) == normalize_state_value(value)
  end

  function tuya.build_send_policy(command_id_or_options, options)
    local resolved = normalize_policy_options(command_id_or_options, options)
    local policy = {}

    for _, key in ipairs(send_policy_keys) do
      if resolved[key] ~= nil then
        policy[key] = resolved[key]
      end
    end

    return policy
  end

  function tuya.apply_send_policy(mapping, send_policy)
    if type_check(mapping) ~= "table" or type_check(send_policy) ~= "table" then
      return mapping
    end

    if mapping[1] ~= nil and mapping.dp == nil then
      local list = {}
      for index, item in ipairs(mapping) do
        if type_check(item) == "table" then
          list[index] = tuya.apply_send_policy(item, send_policy)
        else
          list[index] = item
        end
      end
      return list
    end

    local applied = copy_table(mapping)
    for _, key in ipairs(send_policy_keys) do
      if applied[key] == nil and send_policy[key] ~= nil then
        applied[key] = send_policy[key]
      end
    end

    return applied
  end

  function tuya.build_fixed_send_policy(command_id_or_options, options)
    local resolved = normalize_policy_options(command_id_or_options, options)
    if resolved.transaction == nil then
      resolved.transaction = 1
    end
    if resolved.match_transaction == nil then
      resolved.match_transaction = true
    end

    return tuya.build_send_policy(resolved)
  end

  function tuya.apply_fixed_send_policy(mapping, command_id_or_options, options)
    return tuya.apply_send_policy(mapping, tuya.build_fixed_send_policy(command_id_or_options, options))
  end

  function tuya.build_global_send_policy(command_id_or_options, options)
    local resolved = normalize_policy_options(command_id_or_options, options)
    if resolved.match_transaction == nil then
      resolved.match_transaction = false
    end

    return tuya.build_send_policy(resolved)
  end

  function tuya.apply_global_send_policy(mapping, command_id_or_options, options)
    return tuya.apply_send_policy(mapping, tuya.build_global_send_policy(command_id_or_options, options))
  end

  function tuya.skip.state_on_and_brightness_present(options)
    options = options or {}
    local brightness_key = options.brightness_key
    if type_check(brightness_key) ~= "string" or brightness_key == "" then
      brightness_key = "brightness"
    end

    return function(device, value, item, context)
      local values = values_from_context(context)
      if values == nil or values[brightness_key] == nil then
        return false
      end

      return state_matches(device, context, value, options)
    end
  end

  function tuya.skip.state_on_and_brightness_present_only(options)
    options = options or {}
    local brightness_key = options.brightness_key
    if type_check(brightness_key) ~= "string" or brightness_key == "" then
      brightness_key = "brightness"
    end

    return function(device, value, item, context)
      local values = values_from_context(context)
      if values == nil or values[brightness_key] == nil then
        return false
      end

      return normalize_state_value(value) == true
    end
  end
end

return load_policy_helper
