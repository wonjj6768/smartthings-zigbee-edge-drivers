local capabilities = require "st.capabilities"
local custom_capabilities = require "core.custom_capabilities"
local log = require "log"
local tuya = require "tuya_common"
local zcl = require "zcl_common"

local MAIN_COMPONENT = "main"
local INITIAL_CUSTOM_STATE_QUERY_KEY = "__initialCustomStateQueryRequested"
local UNKNOWN_PROFILE_TOKEN = "__unknown_profile__"
local REFRESHED_PROFILE_CAPABILITIES = {}

local numeric_definitions = custom_capabilities.numeric
local enum_definitions = custom_capabilities.enum
local text_definitions = custom_capabilities.text
local driver_message_definition = custom_capabilities.driver_message
local METADATA_GROUPS = {
  { kind = "numeric", definitions = numeric_definitions },
  { kind = "enum", definitions = enum_definitions },
  { kind = "text", definitions = text_definitions },
}
local COMMAND_GROUPS = {
  { kind = "numeric", definitions = numeric_definitions },
  { kind = "enum", definitions = enum_definitions },
}

local function device_name(device)
  if type(device) ~= "table" then
    return "device"
  end

  return device.label or device.id or "device"
end

local function profile_token(device)
  if type(device) ~= "table" then
    return UNKNOWN_PROFILE_TOKEN
  end

  local profile = device.profile
  local profile_id = type(profile) == "table" and profile.id or nil
  if type(profile_id) == "string" and profile_id ~= "" then
    return profile_id
  end

  return UNKNOWN_PROFILE_TOKEN
end

local function get_profile_refresh_state(device)
  local token = profile_token(device)
  local state = REFRESHED_PROFILE_CAPABILITIES[token]
  if state == nil then
    state = {}
    REFRESHED_PROFILE_CAPABILITIES[token] = state
  end

  return state
end

local function is_callable(value)
  if type(value) == "function" then
    return true
  end

  if type(value) ~= "table" then
    return false
  end

  local metatable = getmetatable(value)
  return type(metatable) == "table" and type(metatable.__call) == "function"
end

local function resolve_capability_attribute(capability_id, attribute_name)
  local capability = capabilities[capability_id]
  local attribute = capability and capability[attribute_name] or nil

  if not is_callable(attribute) and capability and type(capability.attributes) == "table" then
    attribute = capability.attributes[attribute_name]
  end

  return capability, attribute
end

local function profile_supports_capability(device, component_id, capability_id)
  if type(device) ~= "table" or type(capability_id) ~= "string" or capability_id == "" then
    return false
  end

  component_id = component_id or "main"
  local components = device.profile and device.profile.components or nil
  local component = type(components) == "table" and components[component_id] or nil
  local capabilities_map = component and component.capabilities or nil
  return type(capabilities_map) == "table" and capabilities_map[capability_id] ~= nil
end

local function resolve_metadata_range(definition, key, fallback)
  local metadata = custom_capabilities.by_range_key[key]

  if metadata == nil and type(fallback) == "table" then
    metadata = {
      range_key = key,
      default_range = fallback,
    }
  end

  return custom_capabilities.resolve_range(definition, metadata)
end

local function resolve_enum_values(definition, metadata)
  local range = resolve_metadata_range(definition, metadata.range_key, {
    allowed_values = metadata.supported_values,
  })
  return type(range) == "table" and range.allowed_values or metadata.supported_values
end

local function round_to_step(value, minimum, step)
  if type(step) ~= "number" or step <= 0 then
    return value
  end

  local base = type(minimum) == "number" and minimum or 0
  local rounded = math.floor(((value - base) / step) + 0.5)
  local adjusted = base + (rounded * step)
  local decimals = tostring(step):match("%.(%d+)")

  if decimals ~= nil then
    adjusted = tonumber(string.format("%." .. tostring(#decimals) .. "f", adjusted))
  end

  return adjusted
end

local function snap_to_allowed_values(value, allowed_values)
  if type(allowed_values) ~= "table" or #allowed_values == 0 then
    return value
  end

  local best = nil
  local best_distance = nil
  for _, candidate in ipairs(allowed_values) do
    if type(candidate) == "number" then
      local distance = math.abs(candidate - value)
      if best == nil or distance < best_distance then
        best = candidate
        best_distance = distance
      end
    end
  end

  return best or value
end

local function normalize_custom_numeric_value(raw_value, minimum, maximum, step, allowed_values)
  if type(raw_value) ~= "number" then
    return nil, false
  end

  local value = raw_value
  if type(minimum) == "number" and value < minimum then
    value = minimum
  end
  if type(maximum) == "number" and value > maximum then
    value = maximum
  end

  value = round_to_step(value, minimum, step)
  value = snap_to_allowed_values(value, allowed_values)
  return value, value ~= raw_value
end

local function normalize_custom_enum_value(raw_value, allowed_values)
  if type(raw_value) ~= "string" or raw_value == "" then
    return nil
  end

  if type(allowed_values) ~= "table" or allowed_values[1] == nil then
    return raw_value
  end

  for _, candidate in ipairs(allowed_values) do
    if raw_value == candidate then
      return raw_value
    end
  end

  return nil
end

local function resolve_numeric_event_unit(metadata, range)
  if type(range) == "table" and type(range.unit) == "string" and range.unit ~= "" then
    return range.unit
  end

  if type(metadata) == "table" then
    if type(metadata.event_unit) == "string" and metadata.event_unit ~= "" then
      return metadata.event_unit
    end

    local default_range = metadata.default_range
    if type(default_range) == "table" and type(default_range.unit) == "string" and default_range.unit ~= "" then
      return default_range.unit
    end
  end

  return nil
end

local function emit_event(device, component_id, event)
  component_id = component_id or MAIN_COMPONENT
  if component_id == MAIN_COMPONENT then
    device:emit_event(event)
  else
    device:emit_component_event({ id = component_id }, event)
  end
end

local function for_each_definition_group(callback)
  for _, group in ipairs(METADATA_GROUPS) do
    callback(group.definitions, group.kind)
  end
end

local function for_each_supported_metadata(device, definitions, component_id, callback)
  component_id = component_id or MAIN_COMPONENT
  for _, metadata in ipairs(definitions) do
    if profile_supports_capability(device, component_id, metadata.capability_id) then
      callback(metadata, component_id)
    end
  end
end

local function apply_numeric_metadata_bounds(metadata, minimum, maximum)
  if type(metadata) ~= "table" then
    return minimum, maximum
  end

  if type(metadata.event_minimum) == "number" and (type(minimum) ~= "number" or minimum < metadata.event_minimum) then
    minimum = metadata.event_minimum
  end

  if type(metadata.event_maximum) == "number" and (type(maximum) ~= "number" or maximum > metadata.event_maximum) then
    maximum = metadata.event_maximum
  end

  if type(minimum) == "number" and type(maximum) == "number" and minimum > maximum then
    minimum = maximum
  end

  return minimum, maximum
end

local function schedule_device_task(device, delay_s, label, callback)
  if type(callback) ~= "function" then
    return false
  end

  if device ~= nil and device.thread ~= nil and type(device.thread.call_with_delay) == "function" then
    device.thread:call_with_delay(delay_s, callback, label)
    return true
  end

  return false
end

local function create(options)
  local get_preset = assert(options and options.get_preset, "custom capability runtime requires get_preset")
  local send = assert(options and options.send, "custom capability runtime requires send")
  local resolve_definition = assert(options and options.resolve_definition, "custom capability runtime requires resolve_definition")

  -- Binding and state helpers

  local function log_missing_custom_binding(device, metadata, reason)
    if type(device) ~= "table" or type(metadata) ~= "table" then
      return
    end

    local key = string.format("__custom_driver_missing__:%s:%s", metadata.capability_id or "unknown", reason or "unknown")
    if device.get_field ~= nil and device.set_field ~= nil and device:get_field(key) then
      return
    end

    if device.set_field ~= nil then
      device:set_field(key, true, { persist = false })
    end

    log.error(string.format(
      "[%s] Custom capability driver binding missing (%s): %s.%s",
      device_name(device),
      reason or "unknown",
      metadata.capability_id or "unknown",
      metadata.attribute_name or "unknown"
    ))
  end

  local function resolve_attribute_binding(device, metadata, attribute_name, log_missing)
    local capability, attribute = resolve_capability_attribute(metadata.capability_id, attribute_name)
    if is_callable(attribute) then
      return attribute
    end

    if log_missing then
      if capability == nil then
        log_missing_custom_binding(device, metadata, "capability")
      else
        log_missing_custom_binding(device, metadata, "attribute")
      end
    end

    return nil
  end

  local function resolve_numeric_range(device, definition, metadata, component_id, fallback)
    local mapping_range = nil
    local preset = get_preset(device)
    if preset ~= nil and type(preset.zcl_clusters) == "table" and type(metadata.mapping_name) == "string" and metadata.mapping_name ~= "" then
      local mapping = zcl.find_mapping_by_name(preset.zcl_clusters, metadata.mapping_name, device, {
        component_id = component_id or MAIN_COMPONENT,
      })
      if type(mapping) == "table" and type(mapping.numeric_range) == "table" then
        mapping_range = mapping.numeric_range
      end
    end

    local range = resolve_metadata_range(definition, metadata.range_key, fallback or mapping_range or metadata.default_range)
    if type(range) ~= "table" then
      return nil
    end

    range.minimum, range.maximum = apply_numeric_metadata_bounds(metadata, range.minimum, range.maximum)
    return range
  end

  local function is_latest_state_missing(device, component_id, metadata)
    return device:get_latest_state(component_id, metadata.capability_id, metadata.attribute_name) == nil
  end

  -- Event emitters

  local function emit_driver_message(device, message)
    if type(message) ~= "string" or message == "" then
      return
    end

    if not profile_supports_capability(device, MAIN_COMPONENT, driver_message_definition.capability_id) then
      return
    end

    local attribute = resolve_attribute_binding(
      device,
      driver_message_definition,
      driver_message_definition.attribute_name,
      true
    )
    if attribute == nil then
      return
    end

    local maximum_length = driver_message_definition.maximum_length or 512
    local normalized = #message > maximum_length and message:sub(1, maximum_length) or message
    log.info(string.format("[%s] Driver message emit requested: %s", device_name(device), normalized))
    emit_event(device, MAIN_COMPONENT, attribute({ value = normalized }))
  end

  local function emit_custom_numeric_state(device, component_id, metadata, value, unit)
    if type(metadata) ~= "table" or type(metadata.attribute_name) ~= "string" or value == nil then
      return
    end

    local attribute = resolve_attribute_binding(device, metadata, metadata.attribute_name, true)
    if attribute == nil then
      return
    end

    local payload = unit ~= nil and { value = value, unit = unit } or { value = value }
    log.info(string.format("[%s] Custom numeric emit requested: %s=%s", device_name(device), metadata.capability_id, tostring(value)))
    emit_event(device, component_id, attribute(payload))
  end

  local function emit_custom_enum_state(device, component_id, metadata, value)
    if type(metadata) ~= "table" or type(metadata.attribute_name) ~= "string" or type(value) ~= "string" or value == "" then
      return
    end

    local attribute = resolve_attribute_binding(device, metadata, metadata.attribute_name, true)
    if attribute == nil then
      return
    end

    log.info(string.format("[%s] Custom enum emit requested: %s=%s", device_name(device), metadata.capability_id, tostring(value)))
    emit_event(device, component_id, attribute({ value = value }))
  end

  -- Metadata and diagnostics

  local function refresh_profile_definitions(device)
    if type(device) ~= "table" then
      return
    end

  local refresh_state = get_profile_refresh_state(device)
    if refresh_state.__complete == true then
      return
    end

    local seen = {}
    local incomplete_refresh = false

    local function refresh(capability_id)
      if type(capability_id) ~= "string" or capability_id == "" or seen[capability_id] then
        return
      end
      if not profile_supports_capability(device, MAIN_COMPONENT, capability_id) then
        return
      end
      if refresh_state[capability_id] == true then
        return
      end

      seen[capability_id] = true
      local ok, err = pcall(capabilities.get_capability_definition, capability_id, 1, true)
      if not ok then
        incomplete_refresh = true
        log.warn(string.format("[%s] Failed to refresh capability definition for %s: %s", device_name(device), capability_id, tostring(err)))
        return
      end

      refresh_state[capability_id] = true
    end

    for_each_definition_group(function(definitions)
      for _, metadata in ipairs(definitions) do
        refresh(metadata.capability_id)
      end
    end)

    refresh(driver_message_definition.capability_id)

    if not incomplete_refresh then
      refresh_state.__complete = true
    end
  end

  local function emit_numeric_metadata(device, definition)
    for_each_supported_metadata(device, numeric_definitions, MAIN_COMPONENT, function(metadata)
      local range = resolve_numeric_range(device, definition, metadata, MAIN_COMPONENT)
      local range_attribute = resolve_attribute_binding(device, metadata, metadata.range_attribute_name, false)

      if range ~= nil and range_attribute ~= nil then
        local payload = {
          value = {
            minimum = range.minimum,
            maximum = range.maximum,
            step = range.step,
          },
        }

        if range.unit ~= nil then
          payload.unit = range.unit
        end

        emit_event(device, MAIN_COMPONENT, range_attribute(payload))
      end
    end)
  end

  local function emit_enum_metadata(device, definition)
    for_each_supported_metadata(device, enum_definitions, MAIN_COMPONENT, function(metadata)
      local attribute = resolve_attribute_binding(device, metadata, metadata.supported_attribute_name, false)
      local allowed_values = resolve_enum_values(definition, metadata)

      if attribute ~= nil and type(allowed_values) == "table" and allowed_values[1] ~= nil then
        emit_event(device, MAIN_COMPONENT, attribute({ value = allowed_values }))
      end
    end)
  end

  local function emit_placeholder_states(device, definition)
    for_each_supported_metadata(device, numeric_definitions, MAIN_COMPONENT, function(metadata)
      if is_latest_state_missing(device, MAIN_COMPONENT, metadata) then
        local range = resolve_numeric_range(device, definition, metadata, MAIN_COMPONENT)
        if type(range) == "table" and range.minimum ~= nil then
          emit_custom_numeric_state(device, MAIN_COMPONENT, metadata, range.minimum, range.unit)
        end
      end
    end)

    for_each_supported_metadata(device, enum_definitions, MAIN_COMPONENT, function(metadata)
      local latest = device:get_latest_state(MAIN_COMPONENT, metadata.capability_id, metadata.attribute_name)
      if latest == nil then
        local allowed_values = resolve_enum_values(definition, metadata)
        if type(allowed_values) == "table" and allowed_values[1] ~= nil then
          emit_custom_enum_state(device, MAIN_COMPONENT, metadata, allowed_values[1])
        end
      end
    end)
  end

  local function diagnose_bindings(device)
    if type(device) ~= "table" then
      return
    end

    local function inspect_metadata(metadata, component_id)
      component_id = component_id or MAIN_COMPONENT
      if not profile_supports_capability(device, component_id, metadata.capability_id) then
        return
      end

      local attribute = resolve_attribute_binding(device, metadata, metadata.attribute_name, true)
      if attribute == nil then
        return
      end

      log.info(string.format(
        "[%s] Custom capability ready: %s.%s",
        device_name(device),
        metadata.capability_id,
        metadata.attribute_name
      ))
    end

    for_each_definition_group(function(definitions)
      for _, metadata in ipairs(definitions) do
        inspect_metadata(metadata)
      end
    end)

    inspect_metadata(driver_message_definition)
  end

  -- Initial state helpers

  local function has_missing_state_in_group(device, definitions)
    for _, metadata in ipairs(definitions) do
      if profile_supports_capability(device, MAIN_COMPONENT, metadata.capability_id)
        and is_latest_state_missing(device, MAIN_COMPONENT, metadata) then
        return true
      end
    end

    return false
  end

  local function device_has_missing_custom_state(device)
    for _, group in ipairs(METADATA_GROUPS) do
      if has_missing_state_in_group(device, group.definitions) then
        return true
      end
    end
    return false
  end

  local function maybe_request_initial_custom_state(device, preset)
    if preset == nil or preset.datapoints == nil then
      return
    end
    if not device_has_missing_custom_state(device) then
      return
    end
    if device:get_field(INITIAL_CUSTOM_STATE_QUERY_KEY) then
      return
    end

    device:set_field(INITIAL_CUSTOM_STATE_QUERY_KEY, true, { persist = false })
    emit_driver_message(device, "Initial custom state query requested.")

    if schedule_device_task(device, 2, "initial custom state query", function()
      preset:send_state_request(device)
      emit_driver_message(device, "Initial custom state query sent.")
    end) then
      return
    end

    preset:send_state_request(device)
    emit_driver_message(device, "Initial custom state query sent.")
  end

  -- Mapping support and rollback helpers

  local function preset_supports_named_mapping(device, component_id, mapping_name)
    if type(mapping_name) ~= "string" or mapping_name == "" then
      return false
    end

    local preset = get_preset(device)
    if preset == nil then
      return false
    end

    local named_mappings = preset.named_mappings or preset.datapoints
    if type(named_mappings) == "table" then
      if named_mappings[mapping_name] ~= nil then
        return true
      end

      local named_map = preset.named_mappings_by_name
      if named_map == nil then
        named_map = tuya.build_named_map(named_mappings, "name")
        preset.named_mappings_by_name = named_map
      end

      if type(named_map) == "table" and named_map[mapping_name] ~= nil then
        return true
      end
    end

    if type(preset.zcl_clusters) == "table" then
      local mapping = zcl.find_mapping_by_name(preset.zcl_clusters, mapping_name, device, {
        component_id = component_id or "main",
      })
      if mapping ~= nil then
        return true
      end
    end

    return false
  end

  local function emit_numeric_zero_rollback(device, component_id, metadata, range)
    component_id = component_id or MAIN_COMPONENT
    emit_custom_numeric_state(device, component_id, metadata, 0, resolve_numeric_event_unit(metadata, range))

    schedule_device_task(device, 1, string.format("unsupported numeric rollback %s", tostring(metadata.capability_id or "unknown")), function()
      emit_custom_numeric_state(device, component_id, metadata, 0, resolve_numeric_event_unit(metadata, range))
    end)
  end

  local function rollback_numeric_capability(device, component_id, metadata, range, message)
    emit_numeric_zero_rollback(device, component_id, metadata, range)
    if type(message) == "string" and message ~= "" then
      emit_driver_message(device, message)
    end
  end

  local function reject_numeric_command(device, component_id, metadata, range, reason)
    rollback_numeric_capability(
      device,
      component_id,
      metadata,
      range,
      string.format("%s %s", metadata.label, reason)
    )
  end

  -- Command handlers

  local function register_numeric_handler(handlers, metadata)
    handlers[metadata.capability_id] = handlers[metadata.capability_id] or {}

    handlers[metadata.capability_id][metadata.command_name] = function(_, device, command)
      local component_id = command.component or MAIN_COMPONENT
      if not preset_supports_named_mapping(device, component_id, metadata.mapping_name) then
        reject_numeric_command(device, component_id, metadata, metadata.default_range, "is not supported by this device. Reverted to 0.")
        return
      end

      local raw_value = command.args and command.args[metadata.argument_name] or nil
      local definition = resolve_definition(device)
      local range = resolve_numeric_range(device, definition, metadata, component_id)
      local normalized, adjusted = normalize_custom_numeric_value(
        raw_value,
        range and range.minimum or nil,
        range and range.maximum or nil,
        range and range.step or nil,
        range and range.allowed_values or nil
      )

      if normalized == nil then
        reject_numeric_command(device, component_id, metadata, range, "value is invalid. Reverted to 0.")
        return
      end

      if adjusted then
        emit_driver_message(device, string.format("%s adjusted from %s to %s.", metadata.label, tostring(raw_value), tostring(normalized)))
      end

      local send_ok, handled = pcall(send, device, command, metadata.mapping_name, normalized)
      if not send_ok then
        reject_numeric_command(device, component_id, metadata, range, "command failed. Reverted to 0.")
        log.error(string.format("[%s] Failed to send %s: %s", device_name(device), metadata.capability_id, tostring(handled)))
        return
      end

      if not handled then
        reject_numeric_command(device, component_id, metadata, range, "is not supported by this device. Reverted to 0.")
        return
      end

      emit_custom_numeric_state(device, component_id, metadata, normalized, resolve_numeric_event_unit(metadata, range))
    end
  end

  local function register_enum_handler(handlers, metadata)
    handlers[metadata.capability_id] = handlers[metadata.capability_id] or {}

    handlers[metadata.capability_id][metadata.command_name] = function(_, device, command)
      local definition = resolve_definition(device)
      local raw_value = command.args and command.args[metadata.argument_name] or nil
      local allowed_values = resolve_enum_values(definition, metadata)
      local normalized = normalize_custom_enum_value(raw_value, allowed_values)

      if normalized == nil then
        local supported_label = type(allowed_values) == "table" and table.concat(allowed_values, ", ") or "none"
        emit_driver_message(device, string.format("%s value is invalid. Supported values: %s.", metadata.label, supported_label))
        return
      end

      local send_ok, handled = pcall(send, device, command, metadata.mapping_name, normalized)
      if not send_ok then
        emit_driver_message(device, string.format("%s command failed. No change applied.", metadata.label))
        log.error(string.format("[%s] Failed to send %s: %s", device_name(device), metadata.capability_id, tostring(handled)))
        return
      end

      if not handled then
        emit_driver_message(device, string.format("%s is not supported by this device. No change applied.", metadata.label))
        return
      end

      emit_custom_enum_state(device, command.component, metadata, normalized)
    end
  end

  local function register_handlers(handlers)
    for _, group in ipairs(COMMAND_GROUPS) do
      local definitions = group.definitions
      local kind = group.kind
      for _, metadata in ipairs(definitions) do
        if type(metadata.command_name) == "string" and metadata.command_name ~= "" then
          if kind == "numeric" then
            register_numeric_handler(handlers, metadata)
          else
            register_enum_handler(handlers, metadata)
          end
        end
      end
    end
  end

  return {
    diagnose_bindings = diagnose_bindings,
    emit_driver_message = emit_driver_message,
    emit_enum_metadata = emit_enum_metadata,
    emit_numeric_metadata = emit_numeric_metadata,
    emit_placeholder_states = emit_placeholder_states,
    maybe_request_initial_custom_state = maybe_request_initial_custom_state,
    refresh_definitions = refresh_profile_definitions,
    register_handlers = register_handlers,
  }
end

return {
  create = create,
}
