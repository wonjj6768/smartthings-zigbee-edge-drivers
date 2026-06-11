local function load_mapping(tuya, shared)
  local log = shared.log
  local capabilities = require "st.capabilities"
  local custom_capabilities = require "core.custom_capabilities"
  local battery_refresh = require "app.battery_refresh"

  local type_check = shared.type_check
  local table_insert = shared.table_insert

  local normalize_transaction = shared.normalize_transaction
  local persist_opt = shared.persist_opt

  local mapping_list_cache = setmetatable({}, { __mode = "k" })
  local dp_index_cache = setmetatable({}, { __mode = "k" })
  local key_index_cache = setmetatable({}, { __mode = "k" })
  local prepared_mappings = setmetatable({}, { __mode = "k" })
  local MAPPING_BUCKET_TAG = "__tuya_mapping_bucket"
  local is_mapping_list
  local driver_message_definition = custom_capabilities.driver_message

local function debug_value_to_string(value)
  local value_type = type_check(value)
  if value_type == "string" then
    return value
  end

  if value_type == "number" or value_type == "boolean" then
    return tostring(value)
  end

  if value_type == "table" then
    local parts = {}
    local count = 0
    for key, item in pairs(value) do
      count = count + 1
      if count > 4 then
        parts[#parts + 1] = "..."
        break
      end
      parts[#parts + 1] = tostring(key) .. "=" .. tostring(item)
    end
    return table.concat(parts, ", ")
  end

  return tostring(value)
end

local function emit_debug_driver_message(device, mapping_context, dp_info, value)
  if type_check(device) ~= "table" then
    return
  end

  local metadata = custom_capabilities.by_emit_name[type_check(mapping_context) == "table" and mapping_context.name or nil]
  if metadata == nil or metadata.emit_name == driver_message_definition.emit_name then
    return
  end

  local capability = capabilities[driver_message_definition.capability_id]
  local attribute_fn = capability and capability[driver_message_definition.attribute_name] or nil
  if type_check(attribute_fn) ~= "function" then
    log.error(string.format(
      "[%s] Debug driver message binding missing: %s.%s",
      device.label or device.id or "device",
      driver_message_definition.capability_id or "unknown",
      driver_message_definition.attribute_name or "unknown"
    ))
    return
  end

  local label = metadata.label or metadata.emit_name or "custom state"
  local dp_label = type_check(dp_info) == "table" and type_check(dp_info.dp) == "number" and string.format("dp=%d", dp_info.dp) or "dp=?"
  local message = string.format("RX %s (%s): %s", label, dp_label, debug_value_to_string(value))
  local maximum_length = driver_message_definition.maximum_length or 512
  if #message > maximum_length then
    message = message:sub(1, maximum_length)
  end

  device:emit_event(attribute_fn({ value = message }))
end

local function warn_invalid_mapping(label)
  log.warn(string.format("Tuya %s ignored", label))
end

local function is_mapping_bucket(value)
  return type_check(value) == "table" and value[MAPPING_BUCKET_TAG] == true
end

local function append_index_entry(index, key, entry)
  if key == nil then
    return
  end

  local existing = index[key]
  if existing == nil then
    index[key] = entry
    return
  end

  if is_mapping_bucket(existing) then
    table_insert(existing, entry)
    return
  end

  index[key] = {
    [MAPPING_BUCKET_TAG] = true,
    existing,
    entry,
  }
end

local function mapping_converter(mapping)
  if type_check(mapping) ~= "table" then
    return nil
  end

  if type_check(mapping.converter) == "table" then
    return mapping.converter
  end

  return nil
end

local function mapping_name(mapping, map_key)
  if type_check(mapping) ~= "table" then
    return type_check(map_key) == "string" and map_key or nil
  end

  return mapping.key or mapping.preference or mapping.name or (type_check(map_key) == "string" and map_key or nil)
end

local function mapping_meta(mapping)
  if type_check(mapping) ~= "table" then
    return nil
  end

  local converter_pair = mapping_converter(mapping)
  return {
    from_device = type_check(mapping.from_device) == "function" and mapping.from_device or
      (converter_pair and type_check(converter_pair.from) == "function" and converter_pair.from or nil),
    to_device = type_check(mapping.to_device) == "function" and mapping.to_device or
      (converter_pair and type_check(converter_pair.to) == "function" and converter_pair.to or nil),
    read_only = mapping.read_only == true,
    write_only = mapping.write_only == true,
    field = (type_check(mapping.field) == "string" or type_check(mapping.field) == "function") and mapping.field or nil,
    fields = (type_check(mapping.fields) == "table" or type_check(mapping.fields) == "function") and mapping.fields or nil,
    handler = type_check(mapping.handler) == "function" and mapping.handler or nil,
    emit = type_check(mapping.emit) == "function" and mapping.emit or nil,
    endpoint = (type_check(mapping.endpoint) == "number" or type_check(mapping.endpoint) == "function") and mapping.endpoint or nil,
    component = (type_check(mapping.component) == "string" or type_check(mapping.component) == "function") and mapping.component or nil,
    persist = persist_opt(mapping.persist),
  }
end

local function normalize_endpoint(endpoint)
  if type_check(endpoint) ~= "number" or endpoint % 1 ~= 0 then
    return nil
  end

  return endpoint
end

local function resolve_context_component_id(device, context)
  if type_check(context) ~= "table" then
    return nil
  end

  local component_id = context.component_id or context.component
  if type_check(component_id) == "string" and component_id ~= "" then
    return component_id
  end

  local endpoint = normalize_endpoint(context.endpoint or context.src_endpoint)
  if endpoint ~= nil and type_check(device.get_component_id_for_endpoint) == "function" then
    local resolved = device:get_component_id_for_endpoint(endpoint)
    if type_check(resolved) == "string" and resolved ~= "" then
      return resolved
    end
  end

  return nil
end

local function resolve_context_endpoint(device, context)
  if type_check(context) ~= "table" then
    return nil
  end

  local endpoint = normalize_endpoint(context.endpoint or context.src_endpoint)
  if endpoint ~= nil then
    return endpoint
  end

  local component_id = context.component_id or context.component
  if type_check(component_id) == "string" and component_id ~= "" and type_check(device.get_endpoint_for_component_id) == "function" then
    local resolved = device:get_endpoint_for_component_id(component_id)
    if type_check(resolved) == "table" then
      resolved = resolved[1]
    end

    return normalize_endpoint(resolved)
  end

  return nil
end

local function resolve_mapping_endpoint(meta, device, context)
  if meta == nil then
    return nil
  end

  local endpoint = meta.endpoint
  if type_check(endpoint) == "function" then
    endpoint = endpoint(device, context, meta)
  end

  return normalize_endpoint(endpoint)
end

local function resolve_mapping_component_id(meta, device, context)
  if meta == nil then
    return nil
  end

  local component_id = meta.component
  if type_check(component_id) == "function" then
    component_id = component_id(device, context, meta)
  end

  if type_check(component_id) == "string" and component_id ~= "" then
    return component_id
  end

  return nil
end

local function build_mapping_context(device, mapping, context, value)
  local mapping_context = {
    mapping = mapping,
    value = value,
  }

  if type_check(context) == "table" then
    for key, item in pairs(context) do
      mapping_context[key] = item
    end
  end

  if mapping_context.dp == nil and type_check(mapping) == "table" then
    mapping_context.dp = mapping.dp
  end

  local meta = mapping_meta(mapping)
  local endpoint = resolve_mapping_endpoint(meta, device, mapping_context)
  if endpoint == nil then
    endpoint = resolve_context_endpoint(device, mapping_context)
  end

  local component_id = resolve_mapping_component_id(meta, device, mapping_context)
  if component_id == nil then
    if endpoint ~= nil and type_check(device.get_component_id_for_endpoint) == "function" then
      component_id = device:get_component_id_for_endpoint(endpoint)
    else
      component_id = resolve_context_component_id(device, mapping_context)
    end
  end

  mapping_context.endpoint = endpoint
  mapping_context.component_id = component_id
  mapping_context.component = component_id and device.profile and device.profile.components and device.profile.components[component_id] or nil

  return mapping_context
end

local function mapping_match_score(mapping, device, context)
  if type_check(mapping) ~= "table" then
    return 0
  end

  local meta = mapping_meta(mapping)
  local expected_endpoint = resolve_mapping_endpoint(meta, device, context)
  local expected_component_id = resolve_mapping_component_id(meta, device, context)
  local actual_endpoint = resolve_context_endpoint(device, context)
  local actual_component_id = resolve_context_component_id(device, context)

  if actual_endpoint == nil and actual_component_id ~= nil and type_check(device.get_endpoint_for_component_id) == "function" then
    actual_endpoint = resolve_context_endpoint(device, { component_id = actual_component_id })
  end

  if actual_component_id == nil and actual_endpoint ~= nil and type_check(device.get_component_id_for_endpoint) == "function" then
    actual_component_id = device:get_component_id_for_endpoint(actual_endpoint)
  end

  if expected_endpoint ~= nil then
    if actual_endpoint == nil or actual_endpoint ~= expected_endpoint then
      return -1
    end
  end

  if expected_component_id ~= nil then
    if actual_component_id == nil or actual_component_id ~= expected_component_id then
      return -1
    end
  end

  local score = 0
  if expected_endpoint ~= nil then
    score = score + 2
  end
  if expected_component_id ~= nil then
    score = score + 1
  end

  return score
end

local function select_mapping_entry(candidate, device, context)
  if candidate == nil then
    return nil
  end

  if not is_mapping_bucket(candidate) then
    if mapping_match_score(candidate, device, context) >= 0 then
      return candidate
    end
    return nil
  end

  local selected = nil
  local selected_score = -1
  for _, mapping in ipairs(candidate) do
    local score = mapping_match_score(mapping, device, context)
    if score > selected_score then
      selected = mapping
      selected_score = score
    end
  end

  return selected
end

local function resolve_field_name(field, device, context)
  local resolved = field
  if type_check(resolved) == "function" then
    resolved = resolved(device, context)
  end

  if type_check(resolved) == "string" and resolved ~= "" then
    return resolved
  end

  return nil
end

local function resolve_fields_map(fields, device, context)
  local resolved = fields
  if type_check(resolved) == "function" then
    resolved = resolved(device, context)
  end

  if type_check(resolved) == "table" then
    return resolved
  end

  return nil
end

local function emit_mapping_event(device, event, context)
  if event == nil then
    return
  end

  battery_refresh.maybe_schedule_after_event(device, event)

  if context.component ~= nil and type_check(device.emit_component_event) == "function" then
    device:emit_component_event(context.component, event)
    return
  end

  if context.endpoint ~= nil and type_check(device.emit_event_for_endpoint) == "function" then
    device:emit_event_for_endpoint(context.endpoint, event)
    return
  end

  device:emit_event(event)
end

local function extend_context(base_context, values, key)
  local context = {}

  if type_check(base_context) == "table" then
    for field, item in pairs(base_context) do
      context[field] = item
    end
  end

  if values ~= nil and context.values == nil then
    context.values = values
  end

  if key ~= nil then
    context.name = key
    context.key = key
    context.preference = key
  end

  return context
end

local function reset_mapping_indexes(mappings)
  if type_check(mappings) ~= "table" then
    return
  end

  mapping_list_cache[mappings] = nil
  dp_index_cache[mappings] = nil
  key_index_cache[mappings] = nil
end

local function build_mapping_indexes(mappings)
  if type_check(mappings) ~= "table" then
    return nil, nil
  end

  local cacheable = prepared_mappings[mappings] == true
  if cacheable then
    local dp_index = dp_index_cache[mappings]
    local key_index = key_index_cache[mappings]
    if dp_index ~= nil and key_index ~= nil then
      return dp_index, key_index
    end
  end

  local dp_index = {}
  local key_index = {}

  if is_mapping_list(mappings) then
    for _, entry in ipairs(mappings) do
      if type_check(entry) == "table" then
        local dp = entry.dp
        if type_check(dp) == "number" then
          append_index_entry(dp_index, dp, entry)
        end

        local name = mapping_name(entry)
        if type_check(name) == "string" then
          append_index_entry(key_index, name, entry)
        end
      end
    end
  else
    for map_key, entry in pairs(mappings) do
      if type_check(map_key) == "number" then
        append_index_entry(dp_index, map_key, entry)
      end

      if type_check(entry) == "table" then
        local dp = entry.dp
        if type_check(dp) == "number" then
          append_index_entry(dp_index, dp, entry)
        end

        local name = mapping_name(entry, map_key)
        if type_check(name) == "string" then
          append_index_entry(key_index, name, entry)
        end
      elseif type_check(entry) == "function" and type_check(map_key) == "string" then
        append_index_entry(key_index, map_key, entry)
      end
    end
  end

  if cacheable then
    dp_index_cache[mappings] = dp_index
    key_index_cache[mappings] = key_index
  end

  return dp_index, key_index
end

local function sanitize_send_item(item, label)
  if type_check(item) ~= "table" then
    warn_invalid_mapping(label)
    return nil
  end

  local datatype = item.datatype
  local function is_byte(value)
    return type_check(value) == "number" and value >= 0 and value <= 0xFF and value % 1 == 0
  end
  local function is_word(value)
    return type_check(value) == "number" and value >= 0 and value <= 0xFFFF and value % 1 == 0
  end

  if not is_byte(item.dp) or not is_byte(datatype) then
    warn_invalid_mapping(label)
    return nil
  end

  if item.command_id ~= nil and not is_byte(item.command_id) then
    warn_invalid_mapping(label)
    return nil
  end

  if item.transaction ~= nil and not is_word(item.transaction) then
    warn_invalid_mapping(label)
    return nil
  end

  if item.to_device ~= nil and type_check(item.to_device) ~= "function" then
    warn_invalid_mapping(label)
    return nil
  end

  local converter_pair = mapping_converter(item)
  if converter_pair ~= nil then
    if converter_pair.from ~= nil and type_check(converter_pair.from) ~= "function" then
      warn_invalid_mapping(label)
      return nil
    end

    if converter_pair.to ~= nil and type_check(converter_pair.to) ~= "function" then
      warn_invalid_mapping(label)
      return nil
    end
  end

  if item.skip ~= nil and type_check(item.skip) ~= "function" then
    warn_invalid_mapping(label)
    return nil
  end

  if item.match_response ~= nil and type_check(item.match_response) ~= "function" then
    warn_invalid_mapping(label)
    return nil
  end

  if item.match_transaction ~= nil and type_check(item.match_transaction) ~= "boolean" then
    warn_invalid_mapping(label)
    return nil
  end

  if item.response_dp ~= nil and not is_byte(item.response_dp) then
    warn_invalid_mapping(label)
    return nil
  end

  if item.response_dps ~= nil and type_check(item.response_dps) ~= "table" then
    warn_invalid_mapping(label)
    return nil
  end

  if item.response_dps ~= nil then
    for _, response_dp in ipairs(item.response_dps) do
      if not is_byte(response_dp) then
        warn_invalid_mapping(label)
        return nil
      end
    end
  end

  local meta = mapping_meta(item)
  local response_dps = item.response_dps
  if response_dps ~= nil and next(response_dps) == nil then
    response_dps = nil
  end

  return {
    dp = item.dp,
    datatype = datatype,
    value = item.value,
    command_id = item.command_id,
    transaction = normalize_transaction(item.transaction),
    signed = item.signed == true,
    to_device = meta and meta.to_device or nil,
    skip = item.skip,
    batch_key = item.batch_key,
    match_transaction = item.match_transaction ~= false,
    response_dp = item.response_dp,
    response_dps = response_dps,
    match_response = item.match_response,
  }
end

local function copy_number_list(values)
  if type_check(values) ~= "table" then
    return nil
  end

  local copied = {}
  for _, value in ipairs(values) do
    table_insert(copied, value)
  end

  return copied
end

is_mapping_list = function(mappings)
  if type_check(mappings) ~= "table" then
    return false
  end

  local cacheable = prepared_mappings[mappings] == true
  if cacheable then
    local cached = mapping_list_cache[mappings]
    if cached ~= nil then
      return cached
    end
  end

  local is_list = type_check(mappings[1]) == "table" and mappings[1].dp ~= nil
  if cacheable then
    mapping_list_cache[mappings] = is_list
  end

  return is_list
end

local function mapping_for_dp(mappings, device, context)
  if type_check(mappings) ~= "table" then
    return nil
  end

  local dp = type_check(context) == "table" and context.dp or context

  if is_mapping_list(mappings) then
    local dp_index = build_mapping_indexes(mappings)
    return select_mapping_entry(dp_index and dp_index[dp] or nil, device, context)
  end

  local direct = mappings[dp]
  if direct ~= nil then
    return select_mapping_entry(direct, device, context)
  end

  local dp_index = build_mapping_indexes(mappings)
  return select_mapping_entry(dp_index and dp_index[dp] or nil, device, context)
end

local function mapping_for_key(mappings, key, device, context)
  if type_check(mappings) ~= "table" or type_check(key) ~= "string" then
    return nil
  end

  local direct = mappings[key]
  if direct ~= nil then
    return select_mapping_entry(direct, device, context)
  end

  local _, key_index = build_mapping_indexes(mappings)
  return select_mapping_entry(key_index and key_index[key] or nil, device, context)
end

-- mapping 한 건 적용
local function apply_mapping(device, dp_info, mapping, context)
  if type_check(mapping) ~= "table" then
    return dp_info.value
  end

  local meta = mapping_meta(mapping)
  if meta == nil or meta.write_only then
    return dp_info.value
  end

  local mapping_context = build_mapping_context(device, mapping, context or dp_info, dp_info.value)
  local value = dp_info.value

  if meta.from_device then
    value = meta.from_device(value, device, dp_info, mapping_context)
  end

  if meta.field then
    local field_name = resolve_field_name(meta.field, device, mapping_context)
    if field_name ~= nil then
      device:set_field(field_name, value, meta.persist)
    end
  end

  local fields_map = resolve_fields_map(meta.fields, device, mapping_context)
  if fields_map ~= nil and type_check(value) == "table" then
    for field_name, source_key in pairs(fields_map) do
      local key = source_key == true and field_name or source_key
      if type_check(field_name) == "string" and type_check(key) == "string" and value[key] ~= nil then
        device:set_field(field_name, value[key], meta.persist)
      end
    end
  end

  if value == nil then
    return value
  end

  local name = mapping_name(mapping)
  if name == "battery" or name == "battery_voltage" then
    battery_refresh.note_report(device)
  end

  if meta.handler then
    meta.handler(device, value, dp_info, mapping_context)
  end

  if meta.emit then
    local event = meta.emit(device, value, dp_info, mapping_context)
    if event then
      if type_check(event) == "table" and event[1] ~= nil then
        for _, item in ipairs(event) do
          emit_mapping_event(device, item, mapping_context)
        end
      else
        emit_mapping_event(device, event, mapping_context)
      end
      emit_debug_driver_message(device, mapping_context, dp_info, value)
    end
  end

  return value
end

local function send_items(device, items)
  if #items == 0 then
    return nil
  end

  if #items == 1 then
    local item = items[1]
    return tuya.send_datapoint(device, item.dp, item.datatype, item.value, item.command_id, item.signed, item.transaction)
  end

  local command_id = items[1].command_id
  local transaction = items[1].transaction
  for index = 2, #items do
    if items[index].command_id ~= command_id or items[index].transaction ~= transaction then
      local last_packet_id = nil
      for _, item in ipairs(items) do
        last_packet_id = tuya.send_datapoint(device, item.dp, item.datatype, item.value, item.command_id, item.signed, item.transaction)
        if last_packet_id == nil then
          return nil
        end
      end
      return last_packet_id
    end
  end

  return tuya.send_datapoints(device, items, command_id, transaction)
end

local build_send_items

local function append_named_items(target, append_item, device, mappings, values, names, context)
  if type_check(append_item) ~= "function" then
    return target
  end

  local send_context = extend_context(context, values)

  local function append_named_value(name, value)
    local item_context = extend_context(send_context, values, name)
    local mapping = mapping_for_key(mappings, name, device, item_context)
    if mapping == nil then
      return
    end

    for _, item in ipairs(build_send_items(device, mapping, value, item_context)) do
      append_item(target, item)
    end
  end

  if type_check(names) == "table" then
    for _, name in ipairs(names) do
      local value = values and values[name]
      if value ~= nil then
        append_named_value(name, value)
      end
    end
  elseif type_check(values) == "table" then
    for name, value in pairs(values) do
      append_named_value(name, value)
    end
  end

  return target
end

-- preference/dp map에서 송신 item 생성
local function build_send_item(device, mapping, value, context)
  local item = sanitize_send_item(mapping, "send mapping")
  if not item then
    return nil
  end

  local meta = mapping_meta(mapping)
  if meta and meta.read_only then
    return nil
  end

  local mapping_context = build_mapping_context(device, mapping, context, value)

  if item.skip and item.skip(device, value, item, mapping_context) then
    return nil
  end

  local encoded = value

  if item.to_device then
    encoded = item.to_device(value, device, item, mapping_context)
  end

  return {
    dp = item.dp,
    datatype = item.datatype,
    value = encoded,
    command_id = item.command_id,
    transaction = item.transaction,
    signed = item.signed,
    batch_key = item.batch_key,
    match_transaction = item.match_transaction,
    response_dp = item.response_dp,
    response_dps = item.response_dps,
    match_response = item.match_response,
  }
end

-- converter 인자 해석

build_send_items = function(device, mapping, value, context)
  if type_check(mapping) == "function" then
    local item = mapping(device, value, context)
    local items = {}
    if item == nil then
      return items
    end

    if item[1] ~= nil then
      for _, result_item in ipairs(item) do
        local sanitized = sanitize_send_item(result_item, "send mapping result")
        if sanitized then
          table_insert(items, sanitized)
        end
      end
      return items
    end

    local sanitized = sanitize_send_item(item, "send mapping result")
    if sanitized then
      table_insert(items, sanitized)
    end
    return items
  end

  if type_check(mapping) ~= "table" then
    return {}
  end

  if mapping[1] ~= nil and mapping.dp == nil then
    local items = {}
    for _, item in ipairs(mapping) do
      local built = build_send_item(device, item, value, context)
      if built then
        table_insert(items, built)
      end
    end
    return items
  end

  local built = build_send_item(device, mapping, value, context)
  if built then
    return { built }
  end

  return {}
end

-- 공개 API


function tuya.apply_datapoint_mapping(device, dp_info, datapoints, context)
  local lookup_context = context or dp_info
  if type_check(lookup_context) ~= "table" then
    lookup_context = { dp = dp_info.dp }
  elseif lookup_context.dp == nil then
    lookup_context.dp = dp_info.dp
  end

  local mapping = mapping_for_dp(datapoints, device, lookup_context)
  if mapping == nil then
    return false
  end

  if type_check(mapping) == "function" then
    mapping(device, dp_info, lookup_context)
    return true
  end

  if type_check(mapping) ~= "table" then
    return false
  end

  if mapping[1] ~= nil then
    for _, item in ipairs(mapping) do
      apply_mapping(device, dp_info, item, lookup_context)
    end
  else
    apply_mapping(device, dp_info, mapping, lookup_context)
  end

  return true
end

-- 매핑 정의를 사용해 값 전송
function tuya.send_mapping(device, mapping, value, context)
  return send_items(device, build_send_items(device, mapping, value, context))
end

function tuya.send_named_mapping(device, mappings, name, value, context)
  local mapping = mapping_for_key(mappings, name, device, context)
  if mapping == nil then
    return nil
  end

  return tuya.send_mapping(device, mapping, value, extend_context(context, nil, name))
end

function tuya.send_named_mappings(device, mappings, values, names, context)
  local items = {}
  append_named_items(items, table_insert, device, mappings, values, names, context)

  return send_items(device, items)
end

local function append_queue_item(queue, item)
  if not item.batch_key then
    table_insert(queue, item)
    return
  end

  local last = queue[#queue]
  local grouped_item = {
    dp = item.dp,
    datatype = item.datatype,
    value = item.value,
    command_id = item.command_id,
    transaction = item.transaction,
    signed = item.signed,
  }

  if last and
     last.batch_key == item.batch_key and
     last.command_id == item.command_id and
     last.transaction == item.transaction and
     last.match_transaction == item.match_transaction and
     last.match_response == item.match_response and
     last.items then
    table_insert(last.items, grouped_item)

    if item.response_dp ~= nil then
      last.response_dps = last.response_dps or {}
      table_insert(last.response_dps, item.response_dp)
    elseif item.response_dps then
      last.response_dps = last.response_dps or {}
      for _, dp in ipairs(item.response_dps) do
        table_insert(last.response_dps, dp)
      end
    end

    return
  end

  local entry = {
    items = { grouped_item },
    command_id = item.command_id,
    batch_key = item.batch_key,
    transaction = item.transaction,
    match_transaction = item.match_transaction,
    match_response = item.match_response,
  }

  if item.response_dp ~= nil then
    entry.response_dps = { item.response_dp }
  elseif item.response_dps then
    entry.response_dps = copy_number_list(item.response_dps)
  end

  table_insert(queue, entry)
end

local function send_preference(device, preference_name, preference_map, old_prefs)
  local prefs = device.preferences or {}
  local item_context = extend_context(nil, prefs, preference_name)
  local mapping = mapping_for_key(preference_map, preference_name, device, item_context)
  local value = prefs[preference_name]
  local old_value = old_prefs and old_prefs[preference_name] or nil

  if mapping == nil or value == nil or value == old_value then
    return false
  end

  return tuya.send_mapping(device, mapping, value, item_context) ~= nil
end

local function preference_has_changed(prefs, old_prefs, name)
  if old_prefs == nil then
    return true
  end
  return prefs[name] ~= old_prefs[name]
end

-- preference map으로 큐 생성
function tuya.build_preference_config_queue(device, preference_map, preference_names, old_prefs)
  local queue = {}
  local prefs = device.preferences or {}

  local function append_item(name)
    local item_context = extend_context(nil, prefs, name)
    local mapping = mapping_for_key(preference_map, name, device, item_context)
    local value = prefs[name]
    if mapping == nil or value == nil or not preference_has_changed(prefs, old_prefs, name) then
      return
    end

    for _, item in ipairs(build_send_items(device, mapping, value, item_context)) do
      append_queue_item(queue, item)
    end
  end

  if type_check(preference_names) == "table" then
    for _, name in ipairs(preference_names) do
      append_item(name)
    end
  elseif type_check(preference_map) == "table" then
    if is_mapping_list(preference_map) then
      for _, mapping in ipairs(preference_map) do
        local name = mapping.preference or mapping.key or mapping.name
        if type_check(name) == "string" then
          append_item(name)
        end
      end
    else
      for name, _ in pairs(preference_map) do
        append_item(name)
      end
    end
  end

  return queue
end

function tuya.build_named_mapping_config_queue(device, mappings, values, names, context)
  local queue = {}
  append_named_items(queue, append_queue_item, device, mappings, values, names, context)
  return queue
end

local function build_mapping_name_map(datapoints, field, fallback_fields)
  if type_check(datapoints) ~= "table" then
    return {}
  end

  local name_map = {}
  for map_key, entry in pairs(datapoints) do
    if type_check(entry) == "function" and type_check(map_key) == "string" then
      name_map[map_key] = entry
    elseif type_check(entry) == "table" then
      local name = entry[field]

      if name == nil and type_check(fallback_fields) == "table" then
        for _, fallback_field in ipairs(fallback_fields) do
          name = entry[fallback_field]
          if name ~= nil then
            break
          end
        end
      end

      if name == nil and type_check(map_key) == "string" then
        name = map_key
      end

      if type_check(name) == "string" then
        name_map[name] = entry
      end
    end
  end

  return name_map
end

local function mapping_fallback_fields(field)
  if field == "key" then
    return { "name", "preference" }
  end

  if field == "name" then
    return { "key", "preference" }
  end

  if field == "preference" then
    return { "key", "name" }
  end

  return nil
end

function tuya.build_named_map(datapoints, key_field)
  local field = key_field or "key"
  return build_mapping_name_map(datapoints, field, mapping_fallback_fields(field))
end

function tuya.build_preference_map(datapoints, key_field)
  local field = key_field or "preference"
  return build_mapping_name_map(datapoints, field, mapping_fallback_fields(field))
end

local function prepare_mappings(mappings)
  if type_check(mappings) ~= "table" then
    return mappings
  end

  reset_mapping_indexes(mappings)
  prepared_mappings[mappings] = true
  build_mapping_indexes(mappings)
  return mappings
end

shared.prepare_mappings = prepare_mappings

-- preference map으로 설정 큐 시작
function tuya.start_preference_config_queue(device, preference_map, preference_names, old_prefs)
  local queue = tuya.build_preference_config_queue(device, preference_map, preference_names, old_prefs)
  return tuya.start_config_queue(device, queue)
end

function tuya.start_named_mapping_config_queue(device, mappings, values, names, context)
  local queue = tuya.build_named_mapping_config_queue(device, mappings, values, names, context)
  return tuya.start_config_queue(device, queue)
end

-- 변경된 preference만 전송
function tuya.send_preferences(device, preference_map, old_prefs, preference_names)
  local sent = false

  if type_check(preference_names) == "table" then
    for _, name in ipairs(preference_names) do
      if send_preference(device, name, preference_map, old_prefs) then
        sent = true
      end
    end
  elseif type_check(preference_map) == "table" then
    if is_mapping_list(preference_map) then
      for _, mapping in ipairs(preference_map) do
        local name = mapping.preference or mapping.key or mapping.name
        if type_check(name) == "string" and send_preference(device, name, preference_map, old_prefs) then
          sent = true
        end
      end
    else
      for name, _ in pairs(preference_map or {}) do
        if send_preference(device, name, preference_map, old_prefs) then
          sent = true
        end
      end
    end
  end

  return sent
end

function tuya.apply_preferences_changed(device, preference_map, old_prefs, options)
  options = options or {}

  local preference_names = type_check(options.preference_names) == "table" and options.preference_names or nil
  local queue = tuya.build_preference_config_queue(device, preference_map, preference_names, old_prefs)
  if #queue == 0 then
    return false
  end

  if options.use_queue then
    return tuya.start_config_queue(device, queue)
  end

  return tuya.send_preferences(device, preference_map, old_prefs, preference_names)
end

end

return load_mapping
