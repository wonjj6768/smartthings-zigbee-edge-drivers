local function load_runtime(tuya, shared)
  local log = shared.log

  local BASIC_CLUSTER = shared.BASIC_CLUSTER
  local EPOCH_2000_OFFSET = shared.EPOCH_2000_OFFSET
  local PERSIST_FALSE = shared.PERSIST_FALSE
  local CONFIG_QUEUE_FIELD = shared.CONFIG_QUEUE_FIELD
  local CONFIG_QUEUE_CALLBACK_FIELD = shared.CONFIG_QUEUE_CALLBACK_FIELD
  local QUERY_INTERVAL_TIMER_FIELD = shared.QUERY_INTERVAL_TIMER_FIELD
  local QUERY_DATA = shared.QUERY_DATA
  local SET_TIME = shared.SET_TIME
  local CONNECTION_STATUS = shared.CONNECTION_STATUS
  local REPORT_COMMANDS = shared.REPORT_COMMANDS
  local cluster_base = shared.cluster_base

  local string_byte = shared.string_byte
  local string_len = shared.string_len
  local type_check = shared.type_check
  local table_insert = shared.table_insert
  local table_remove = shared.table_remove

  local extract_payload = shared.extract_payload
  local extract_command_id = shared.extract_command_id
  local extract_transaction = shared.extract_transaction
  local prepare_mappings = shared.prepare_mappings
  local time_offset_for_start = shared.time_offset_for_start
  local ACTION_MAGIC_PACKET = "magic_packet"
  local ACTION_QUERY_STATE = "query_state"
  local ACTION_MCU_VERSION = "mcu_version"
  local ACTION_BIND_BASIC = "bind_basic"
  local ACTION_CONFIG_QUEUE = "config_queue"
  local ACTION_QUERY_TIMER = "query_timer"
  local handle_time_request_with_start_mode
  local run_configure_actions
  local send_next_config_item
  local handle_config_queue_response

local function normalize_non_negative_delay(value, default_value, label)
  local resolved = value
  if resolved == nil then
    resolved = default_value
  end

  if type_check(resolved) ~= "number" or resolved < 0 then
    log.warn(string.format("Tuya %s expects non-negative number, got %s", label, tostring(resolved)))
    return nil
  end

  return resolved
end

local function normalize_positive_interval(value, default_value, label)
  local resolved = value
  if resolved == nil then
    resolved = default_value
  end

  if type_check(resolved) ~= "number" or resolved <= 0 then
    log.warn(string.format("Tuya %s expects positive number, got %s", label, tostring(resolved)))
    return nil
  end

  return resolved
end

local function resolve_bind_target_eui(options, driver)
  local bind_target_eui = options.bind_target_eui
  if type_check(bind_target_eui) == "string" and bind_target_eui ~= "" then
    return bind_target_eui
  end

  if type_check(driver) == "table" and type_check(driver.environment_info) == "table" then
    local hub_zigbee_eui = driver.environment_info.hub_zigbee_eui
    if type_check(hub_zigbee_eui) == "string" and hub_zigbee_eui ~= "" then
      return hub_zigbee_eui
    end
  end

  return nil
end

local function merge_named_mapping_options(options)
  local merged = {}
  local nested = type_check(options.named_mapping) == "table" and options.named_mapping or nil

  if nested ~= nil then
    for key, value in pairs(nested) do
      merged[key] = value
    end
  end

  local named_keys = {
    "named_mappings",
    "named_datapoints",
    "named_key_field",
    "named_mapping_values",
    "named_mapping_names",
  }

  for _, key in ipairs(named_keys) do
    if options[key] ~= nil then
      merged[key] = options[key]
    end
  end

  return merged
end

local function send_basic_bind_request(device, bind_target_eui)
  if type_check(bind_target_eui) ~= "string" or bind_target_eui == "" then
    return false
  end

  local request = cluster_base.build_bind_request(device, BASIC_CLUSTER, bind_target_eui)
  if request == nil then
    log.warn("Tuya bind_basic_on_configure failed to build bind request")
    return false
  end

  device:send(request)
  return true
end

local function append_queue_items(target, items)
  if type_check(target) ~= "table" or type_check(items) ~= "table" then
    return target
  end

  for _, item in ipairs(items) do
    table_insert(target, item)
  end

  return target
end

local function schedule_next_configure_action(device, actions, step_delay, cursor)
  if actions[cursor + 1] then
    device.thread:call_with_delay(step_delay, function()
      run_configure_actions(device, actions, step_delay, cursor + 1)
    end)
  end
end

handle_time_request_with_start_mode = function(device, message, time_start, utc_time, local_time)
  if time_start == "off" then
    return false
  end

  local offset = time_offset_for_start(time_start)
  if offset ~= 0 then
    return tuya.apply_time_request_with_offset(device, message, offset, utc_time, local_time)
  end

  return tuya.apply_time_request(device, message, utc_time, local_time)
end

run_configure_actions = function(device, actions, step_delay, index)
  local cursor = index or 1
  local action = actions[cursor]
  if not action then
    return false
  end

  if action.kind == ACTION_MAGIC_PACKET then
    tuya.send_magic_packet(device)
  elseif action.kind == ACTION_QUERY_STATE then
    tuya.send_state_request(device, action.command_id)
  elseif action.kind == ACTION_MCU_VERSION then
    tuya.send_mcu_version_request(device)
  elseif action.kind == ACTION_BIND_BASIC then
    send_basic_bind_request(device, action.bind_target_eui)
  elseif action.kind == ACTION_CONFIG_QUEUE then
    return tuya.start_config_queue(device, action.queue, {
      on_complete = function(success)
        if success then
          schedule_next_configure_action(device, actions, step_delay, cursor)
        end
      end,
    })
  elseif action.kind == ACTION_QUERY_TIMER then
    tuya.start_query_timer(device, action.interval_seconds, action.command_id)
  end

  schedule_next_configure_action(device, actions, step_delay, cursor)

  return true
end

function tuya.apply_announce(device, options)
  options = options or {}
  if not options.query_on_announce then
    return false
  end

  local delay = normalize_non_negative_delay(options.announce_delay, 0.5, "announce_delay")
  if delay == nil then
    return false
  end

  device.thread:call_with_delay(delay, function()
    tuya.send_state_request(device, options.query_command_id)
  end)
  return true
end

function tuya.stop_query_timer(device)
  local timer = device:get_field(QUERY_INTERVAL_TIMER_FIELD)
  if timer and timer.cancel then
    pcall(function()
      timer:cancel()
    end)
  end

  device:set_field(QUERY_INTERVAL_TIMER_FIELD, nil, PERSIST_FALSE)
  return true
end

function tuya.start_query_timer(device, interval_seconds, command_id)
  local seconds = normalize_positive_interval(interval_seconds, nil, "query_interval_seconds")
  if seconds == nil then
    return false
  end

  tuya.stop_query_timer(device)

  local timer = nil
  timer = device.thread:call_with_delay(seconds, function()
    tuya.send_state_request(device, command_id)
    tuya.start_query_timer(device, seconds, command_id)
  end)

  device:set_field(QUERY_INTERVAL_TIMER_FIELD, timer, PERSIST_FALSE)
  return true
end

function tuya.start_configuration(device, options, driver)
  options = options or {}

  local actions = {}
  local step_delay = normalize_non_negative_delay(options.step_delay, 1, "step_delay")
  local initial_delay = normalize_non_negative_delay(options.initial_delay, 0, "initial_delay")
  if step_delay == nil or initial_delay == nil then
    return false
  end

  local named_mapping_options = merge_named_mapping_options(options)
  local preference_map = options.preference_map
  local preference_names = type_check(options.preference_names) == "table" and options.preference_names or nil
  local named_mappings = named_mapping_options.named_mappings
  local named_mapping_values = type_check(named_mapping_options.named_mapping_values) == "table" and named_mapping_options.named_mapping_values or nil
  local named_mapping_names = type_check(named_mapping_options.named_mapping_names) == "table" and named_mapping_options.named_mapping_names or nil
  local bind_target_eui = resolve_bind_target_eui(options, driver)
  local config_queue = {}

  if preference_map == nil and options.preference_datapoints then
    local preference_datapoints = options.preference_datapoints
    if preference_datapoints == true then
      preference_datapoints = options.datapoints
    end

    if preference_datapoints ~= nil then
      preference_map = tuya.build_preference_map(
        preference_datapoints,
        options.preference_key_field
      )
    end
  end

  if preference_map ~= nil then
    prepare_mappings(preference_map)
  end

  if named_mappings == nil and named_mapping_options.named_datapoints then
    local named_datapoints = named_mapping_options.named_datapoints
    if named_datapoints == true then
      named_datapoints = options.datapoints
    end

    if named_datapoints ~= nil then
      if named_mapping_options.named_key_field ~= nil then
        named_mappings = tuya.build_named_map(named_datapoints, named_mapping_options.named_key_field)
      else
        named_mappings = named_datapoints
      end
    end
  end

  if named_mappings == nil and (named_mapping_values ~= nil or named_mapping_names ~= nil) and options.datapoints ~= nil then
    if named_mapping_options.named_key_field ~= nil then
      named_mappings = tuya.build_named_map(options.datapoints, named_mapping_options.named_key_field)
    else
      named_mappings = options.datapoints
    end
  end

  if named_mappings ~= nil then
    prepare_mappings(named_mappings)
  end

  if options.magic_packet ~= false then
    table_insert(actions, { kind = ACTION_MAGIC_PACKET })
  end

  if options.query_on_configure then
    table_insert(actions, {
      kind = ACTION_QUERY_STATE,
      command_id = options.query_command_id,
    })
  end

  if options.mcu_version_request_on_configure then
    table_insert(actions, { kind = ACTION_MCU_VERSION })
  end

  if options.bind_basic_on_configure then
    if bind_target_eui ~= nil then
      table_insert(actions, {
        kind = ACTION_BIND_BASIC,
        bind_target_eui = bind_target_eui,
      })
    else
      log.warn("Tuya bind_basic_on_configure requires bind_target_eui or driver.environment_info.hub_zigbee_eui")
    end
  end

  if preference_map ~= nil then
    append_queue_items(
      config_queue,
      tuya.build_preference_config_queue(device, preference_map, preference_names)
    )
  end

  if named_mappings ~= nil and named_mapping_values ~= nil then
    append_queue_items(
      config_queue,
      tuya.build_named_mapping_config_queue(device, named_mappings, named_mapping_values, named_mapping_names)
    )
  end

  if #config_queue > 0 then
    table_insert(actions, {
      kind = ACTION_CONFIG_QUEUE,
      queue = config_queue,
    })
  end

  if options.query_interval_seconds then
    table_insert(actions, {
      kind = ACTION_QUERY_TIMER,
      interval_seconds = options.query_interval_seconds,
      command_id = options.query_command_id,
    })
  end

  if #actions == 0 then
    return false
  end

  if initial_delay > 0 then
    device.thread:call_with_delay(initial_delay, function()
      run_configure_actions(device, actions, step_delay, 1)
    end)
    return true
  end

  return run_configure_actions(device, actions, step_delay, 1)
end

local function handle_time_command(device, message, handlers)
  if handlers.auto_time == false then
    return false
  end

  local time_offset = handlers.time_offset
  if time_offset then
    return tuya.apply_time_request_with_offset(device, message, time_offset, handlers.utc_time, handlers.local_time)
  end

  if handlers.time_start then
    return handle_time_request_with_start_mode(device, message, handlers.time_start, handlers.utc_time, handlers.local_time)
  end

  return tuya.apply_time_request(device, message, handlers.utc_time, handlers.local_time)
end

local function handle_connection_status_command(device, message, handlers)
  if handlers.auto_connection_status == false then
    return false
  end

  return tuya.apply_connection_status_request(device, message, handlers.connection_status_bytes)
end

local function handle_report_message(device, message, handlers, datapoints, command_id)
  local frame = tuya.parse_datapoint_report(message)
  if not frame then
    log.warn(string.format("Failed to parse Tuya report for command 0x%02X", command_id))
    return false
  end

  if handlers.config_queue ~= false then
    handle_config_queue_response(device, message, handlers.queue_delay, frame)
  end

  for _, dp_info in ipairs(frame.datapoints) do
    if datapoints then
      tuya.apply_datapoint_mapping(device, dp_info, datapoints, {
        frame = frame,
        endpoint = dp_info.endpoint or frame.endpoint,
      })
    end
  end

  return true
end

-- Tuya 메시지 공통 디스패처
function tuya.apply_message(device, message, handlers)
  handlers = handlers or {}
  local datapoints = handlers.datapoints

  local command_id = extract_command_id(message)
  if not command_id then
    return false
  end

  if command_id == SET_TIME then
    if handle_time_command(device, message, handlers) then
      return true
    end
  end

  if command_id == CONNECTION_STATUS then
    if handle_connection_status_command(device, message, handlers) then
      return true
    end
  end

  if REPORT_COMMANDS[command_id] == true then
    return handle_report_message(device, message, handlers, datapoints, command_id)
  end

  return false
end

local function transaction_matches(expected, actual)
  if expected == nil or actual == nil then
    return false
  end

  if expected == actual then
    return true
  end

  return (expected % 0x100) == actual
end

local function collect_response_dps(payload, frame)
  local responded_dps = {}

  if frame and frame.datapoints and #frame.datapoints > 0 then
    for _, dp_info in ipairs(frame.datapoints) do
      responded_dps[dp_info.dp] = true
    end
    return responded_dps
  end

  if payload then
    local dp_info = tuya.parse_datapoint(payload, 3)
    if dp_info ~= nil then
      responded_dps[dp_info.dp] = true
    end
  end

  return responded_dps
end

local function response_contains_dp(responded_dps, dp)
  return dp ~= nil and responded_dps[dp] == true
end

local function build_expected_response_dps(current)
  local expected_dps = {}

  local function append_dp(dp)
    if type_check(dp) == "number" then
      expected_dps[dp] = true
    end
  end

  if current.response_dp ~= nil then
    append_dp(current.response_dp)
    return expected_dps
  end

  if type_check(current.response_dps) == "table" then
    for _, dp in ipairs(current.response_dps) do
      append_dp(dp)
    end

    if next(expected_dps) ~= nil then
      return expected_dps
    end
  end

  if current.dp ~= nil then
    append_dp(current.dp)
    return expected_dps
  end

  if type_check(current.items) == "table" then
    for _, item in ipairs(current.items) do
      if type_check(item) == "table" then
        append_dp(item.dp)
      end
    end
  end

  return expected_dps
end

local function response_matches_expected_dps(current, responded_dps)
  local expected_dps = current.expected_response_dps
  if type_check(expected_dps) ~= "table" then
    expected_dps = build_expected_response_dps(current)
    current.expected_response_dps = expected_dps
  end

  if next(expected_dps) == nil then
    return false
  end

  local matched_dps = current.matched_response_dps
  if type_check(matched_dps) ~= "table" then
    matched_dps = {}
    current.matched_response_dps = matched_dps
  end

  local matched_any = false
  for dp, _ in pairs(responded_dps) do
    if response_contains_dp(expected_dps, dp) then
      matched_dps[dp] = true
      matched_any = true
    end
  end

  if not matched_any then
    return false
  end

  for dp, _ in pairs(expected_dps) do
    if not response_contains_dp(matched_dps, dp) then
      return false
    end
  end

  return true
end

local function config_response_matches(current, response, payload, frame)
  if current.match_response then
    return current.match_response(response, payload, current, frame) == true
  end

  if current.match_transaction and current.packet_id ~= nil then
    local response_transaction = extract_transaction(response)
    if not transaction_matches(current.packet_id, response_transaction) then
      return false
    end
  end

  local responded_dps = collect_response_dps(payload, frame)
  if next(responded_dps) == nil then
    return current.match_transaction and current.packet_id ~= nil
  end

  return response_matches_expected_dps(current, responded_dps)
end

local function clear_config_queue(device)
  device:set_field(CONFIG_QUEUE_FIELD, nil, PERSIST_FALSE)
  device:set_field(CONFIG_QUEUE_CALLBACK_FIELD, nil, PERSIST_FALSE)
end

local function resolve_queue_callback(options)
  if type_check(options) == "function" then
    return options
  end

  if type_check(options) == "table" and type_check(options.on_complete) == "function" then
    return options.on_complete
  end

  return nil
end

local function finish_config_queue(device, success)
  local callback = device:get_field(CONFIG_QUEUE_CALLBACK_FIELD)
  clear_config_queue(device)

  if type_check(callback) == "function" then
    local ok, err = pcall(callback, success == true)
    if not ok then
      log.warn(string.format("Tuya config queue callback failed: %s", tostring(err)))
    end
  end

  return success == true
end

local function send_next_config_item_or_clear(device)
  if send_next_config_item(device) then
    return true
  end

  return finish_config_queue(device, false)
end

-- 설정 큐 시작: tuya.start_config_queue(device, queue)
function tuya.start_config_queue(device, queue, options)
  local items = queue or {}
  local callback = resolve_queue_callback(options)

  if #items == 0 then
    clear_config_queue(device)
    if type_check(callback) == "function" then
      pcall(callback, false)
    end
    return false
  end

  device:set_field(CONFIG_QUEUE_FIELD, items, PERSIST_FALSE)
  device:set_field(CONFIG_QUEUE_CALLBACK_FIELD, callback, PERSIST_FALSE)
  return send_next_config_item_or_clear(device)
end

-- 설정 큐 다음 항목 전송
send_next_config_item = function(device)
  local queue = device:get_field(CONFIG_QUEUE_FIELD)
  if not queue or #queue == 0 then
    return false
  end

  local item = queue[1]
  local command_id = item.command_id

  if item.items then
    local packet_id = tuya.send_datapoints(device, item.items, command_id, item.transaction)
    if packet_id ~= nil then
      item.packet_id = packet_id
      return true
    end
    return false
  end

  local packet_id = tuya.send_datapoint(device, item.dp, item.datatype, item.value, command_id, item.signed, item.transaction)
  if packet_id ~= nil then
    item.packet_id = packet_id
    return true
  end

  return false
end

-- 설정 응답 처리 후 다음 큐 진행
handle_config_queue_response = function(device, response, delay, frame)
  local payload = extract_payload(response)
  local queue = device:get_field(CONFIG_QUEUE_FIELD)

  if not payload or not queue or #queue == 0 then
    return false
  end

  frame = frame or tuya.parse_datapoint_report(response)

  local current = queue[1]
  if not config_response_matches(current, response, payload, frame) then
    return false
  end

  table_remove(queue, 1)

  if #queue == 0 then
    return finish_config_queue(device, true)
  end

  local response_delay = normalize_non_negative_delay(delay, 0.5, "config_queue_delay")
  if response_delay == nil then
    return finish_config_queue(device, false)
  end

  device.thread:call_with_delay(response_delay, function()
    send_next_config_item_or_clear(device)
  end)

  return true
end
end

return load_runtime
