-- Minimal Tuya EF00 receive-only runtime for ZCL-owned hybrid packages.
--
-- This leaf intentionally owns no transmit/configuration behavior.  It consumes
-- the actual device-definition mappings so converter, field, and emit function
-- identities remain the same as the canonical full Tuya runtime.

local battery_refresh = require "runtime.battery_refresh"

local function load_read_only_datapoints(tuya)
  local REPORT_COMMANDS = {
    [tuya.GET_DATA] = true,
    [tuya.SET_DATA_RESPONSE] = true,
    [tuya.REPORT_STATUS] = true,
    [tuya.ACTIVE_STATUS_REPORT] = true,
  }

  local DP_TYPE_BOOL = 0x01
  local DP_TYPE_VALUE = 0x02

  local function extract_payload(message)
    if type(message) == "string" then
      return message
    end
    if type(message) ~= "table" then
      return nil
    end
    return message.body and message.body.zcl_body and message.body.zcl_body.body_bytes or nil
  end

  local function extract_command_id(message)
    if type(message) ~= "table" then
      return nil
    end
    return message.body and message.body.zcl_header and
      message.body.zcl_header.cmd and message.body.zcl_header.cmd.value or nil
  end

  local function extract_source_endpoint(message)
    if type(message) ~= "table" then
      return nil
    end
    local endpoint = message.address_header and message.address_header.src_endpoint and
      message.address_header.src_endpoint.value or nil
    return type(endpoint) == "number" and endpoint or nil
  end

  local function parse_uint(buffer)
    if type(buffer) ~= "string" or #buffer < 1 then
      return nil
    end
    local value = 0
    for index = 1, #buffer do
      value = value * 256 + string.byte(buffer, index)
    end
    return value
  end

  local function parse_value(datatype, value_bytes)
    if datatype == DP_TYPE_BOOL then
      local value = string.byte(value_bytes, 1)
      if value == 0 then return false end
      if value == 1 then return true end
      return nil
    end
    if datatype == DP_TYPE_VALUE then
      return parse_uint(value_bytes)
    end
    return nil
  end

  local function parse_int(buffer)
    local unsigned = parse_uint(buffer)
    if unsigned == nil then
      return nil
    end
    local maximum = 2 ^ (#buffer * 8)
    if unsigned >= maximum / 2 then
      return unsigned - maximum
    end
    return unsigned
  end

  local function parse_datapoint(payload, cursor)
    if #payload < cursor + 3 then
      return nil
    end

    local length = string.byte(payload, cursor + 2) * 256 + string.byte(payload, cursor + 3)
    local value_start = cursor + 4
    local next_index = value_start + length
    if next_index - 1 > #payload then
      return nil
    end

    local datatype = string.byte(payload, cursor + 1)
    local value_bytes = string.sub(payload, value_start, next_index - 1)
    return {
      dp = string.byte(payload, cursor),
      datatype = datatype,
      length = length,
      value_bytes = value_bytes,
      value = parse_value(datatype, value_bytes),
      int_value = parse_uint(value_bytes),
      signed_value = parse_int(value_bytes),
      next_index = next_index,
    }
  end

  function tuya.parse_read_only_datapoint_report(message)
    local payload = extract_payload(message)
    if type(payload) ~= "string" or #payload < 2 then
      return nil
    end

    local frame = {
      command_id = extract_command_id(message),
      endpoint = extract_source_endpoint(message),
      status = string.byte(payload, 1),
      transaction = string.byte(payload, 2),
      payload = payload,
      datapoints = {},
    }

    -- Validate the complete frame before applying any mapping.  A malformed
    -- trailing DP must not leave earlier values partially emitted.
    local cursor = 3
    while cursor <= #payload do
      local datapoint = parse_datapoint(payload, cursor)
      if datapoint == nil then
        return nil
      end
      datapoint.endpoint = frame.endpoint
      frame.datapoints[#frame.datapoints + 1] = datapoint
      cursor = datapoint.next_index
    end
    return frame
  end

  local function find_mapping(datapoints, dp)
    for _, mapping in ipairs(datapoints or {}) do
      if mapping.dp == dp then
        return mapping
      end
    end
    return nil
  end

  local function mapping_context(device, mapping, frame, datapoint)
    local endpoint = datapoint.endpoint or frame.endpoint
    local component_id = nil
    if endpoint ~= nil and type(device.get_component_id_for_endpoint) == "function" then
      component_id = device:get_component_id_for_endpoint(endpoint)
    end
    return {
      mapping = mapping,
      value = datapoint.value,
      dp = datapoint.dp,
      frame = frame,
      endpoint = endpoint,
      component_id = component_id,
      component = component_id and device.profile and device.profile.components and
        device.profile.components[component_id] or nil,
    }
  end

  local function emit_event(device, event, context)
    if not event then
      return
    end
    battery_refresh.maybe_schedule_after_event(device, event)
    if context.component ~= nil and type(device.emit_component_event) == "function" then
      device:emit_component_event(context.component, event)
    elseif context.endpoint ~= nil and type(device.emit_event_for_endpoint) == "function" then
      device:emit_event_for_endpoint(context.endpoint, event)
    else
      device:emit_event(event)
    end
  end

  local function apply_mapping(device, mapping, frame, datapoint)
    -- A DP number alone is not enough to trust a report.  Keep malformed or
    -- contract-mismatched wire values from reaching converters, cached fields,
    -- or capability emitters.
    if mapping.datatype ~= datapoint.datatype or datapoint.value == nil then
      return
    end

    local context = mapping_context(device, mapping, frame, datapoint)
    local converter = type(mapping.converter) == "table" and mapping.converter or nil
    local from_device = type(mapping.from_device) == "function" and mapping.from_device or
      (converter and type(converter.from) == "function" and converter.from or nil)
    local value = datapoint.value
    if from_device ~= nil then
      value = from_device(value, device, datapoint, context)
    end

    if type(mapping.field) == "string" and mapping.field ~= "" then
      device:set_field(mapping.field, value, { persist = mapping.persist == true })
    end
    if value == nil then
      return
    end

    if mapping.name == "battery" or mapping.name == "battery_voltage" then
      battery_refresh.note_report(device)
    end
    if type(mapping.emit) == "function" then
      local event = mapping.emit(device, value, datapoint, context)
      if type(event) == "table" and event[1] ~= nil then
        for _, item in ipairs(event) do
          emit_event(device, item, context)
        end
      else
        emit_event(device, event, context)
      end
    end
  end

  function tuya.apply_read_only_datapoints(device, message, datapoints)
    local command_id = extract_command_id(message)
    if REPORT_COMMANDS[command_id] ~= true then
      return false
    end

    local frame = tuya.parse_read_only_datapoint_report(message)
    if frame == nil then
      return false
    end

    for _, datapoint in ipairs(frame.datapoints) do
      local mapping = find_mapping(datapoints, datapoint.dp)
      if mapping ~= nil then
        apply_mapping(device, mapping, frame, datapoint)
      end
    end
    return true
  end

  return tuya
end

return load_read_only_datapoints
