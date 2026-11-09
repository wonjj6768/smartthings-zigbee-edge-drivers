
local function load_ir_session(zcl)

  local custom_capabilities = require "runtime.capability_metadata"
  local custom_capability_binding = require "runtime.capability_binding"
  local log = require "log"
  local json = {}
  require("st.json").configure(json, {use_native = false})

  local learn_ir_code_metadata = custom_capabilities.by_emit_name.learn_ir_code
  local learned_ir_code_metadata = custom_capabilities.by_emit_name.learned_ir_code
  local ir_code_to_send_metadata = custom_capabilities.by_emit_name.ir_code_to_send

  local IR_CONTROL_CLUSTER = 0xE004
  local IR_TRANSMIT_CLUSTER = 0xED00
  local IR_ENDPOINT = 1
  local IR_MAX_CHUNK = 0x38

  local IR_LEARNING_FIELD = "__ir_learning"
  local IR_NEXT_SEQ_FIELD = "__ir_next_seq"
  local IR_OUTGOING_FIELD = "__ir_outgoing_messages"
  local IR_INCOMING_FIELD = "__ir_incoming_bytes"
  local IR_INCOMING_LENGTH_FIELD = "__ir_incoming_length"
  local IR_INCOMING_SEQ_FIELD = "__ir_incoming_seq"
  local IR_INCOMING_POSITION_FIELD = "__ir_incoming_position"
  local IR_LAST_LEARNED_FIELD = "__ir_last_learned_code"
  local IR_LAST_SENT_FIELD = "__ir_last_sent_code"

  local function encode_le16(value)
    local clamped = math.max(0, math.min(0xFFFF, math.floor(value or 0)))
    return string.pack("<I2", clamped)
  end

  local function encode_le32(value)
    local clamped = math.max(0, math.min(0xFFFFFFFF, math.floor(value or 0)))
    return string.pack("<I4", clamped)
  end

  local function decode_le16(bytes, offset)
    offset = offset or 1
    if type(bytes) ~= "string" or #bytes < offset + 1 then
      return nil
    end

    local b1 = string.byte(bytes, offset) or 0
    local b2 = string.byte(bytes, offset + 1) or 0
    return b1 + (b2 << 8)
  end

  local function decode_le32(bytes, offset)
    offset = offset or 1
    if type(bytes) ~= "string" or #bytes < offset + 3 then
      return nil
    end

    local b1 = string.byte(bytes, offset) or 0
    local b2 = string.byte(bytes, offset + 1) or 0
    local b3 = string.byte(bytes, offset + 2) or 0
    local b4 = string.byte(bytes, offset + 3) or 0

    return b1 +
      (b2 << 8) +
      (b3 << 16) +
      (b4 << 24)
  end

  local function compute_crc(payload)
    if type(payload) ~= "string" then
      return 0
    end

    local crc = 0
    for index = 1, #payload do
      crc = (crc + (string.byte(payload, index) or 0)) % 0x100
    end
    return crc
  end

  local function base64_encode(data)
    if type(data) ~= "string" or data == "" then
      return ""
    end

    local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local encoded = {}
    local length = #data
    local index = 1

    while index <= length do
      local a = string.byte(data, index) or 0
      local b = string.byte(data, index + 1) or 0
      local c = string.byte(data, index + 2) or 0
      local n = (a << 16) + (b << 8) + c

      encoded[#encoded + 1] = alphabet:sub((n >> 18) + 1, (n >> 18) + 1)
      encoded[#encoded + 1] = alphabet:sub(((n >> 12) & 0x3F) + 1, ((n >> 12) & 0x3F) + 1)

      if index + 1 <= length then
        encoded[#encoded + 1] = alphabet:sub(((n >> 6) & 0x3F) + 1, ((n >> 6) & 0x3F) + 1)
      else
        encoded[#encoded + 1] = "="
      end

      if index + 2 <= length then
        encoded[#encoded + 1] = alphabet:sub((n & 0x3F) + 1, (n & 0x3F) + 1)
      else
        encoded[#encoded + 1] = "="
      end

      index = index + 3
    end

    return table.concat(encoded)
  end

  local function get_endpoint(preset)
    return type(preset) == "table" and type(preset.ir_endpoint) == "number" and preset.ir_endpoint or IR_ENDPOINT
  end

  local function send_ir_command(device, cluster, command, payload, endpoint)
    return zcl.send_raw_cluster_command(device, cluster, command, payload, endpoint, nil, nil, true)
  end

  local function default(value, fallback)
    if value == nil or value == json.null then return fallback end
    return value
  end

  local json_order = {keyorder = {"key_num", "delay", "key1", "num", "freq", "type", "key_code"}}

  local function key_message(code, options)
    options = options or {}
    return json.encode({key_num = 1, delay = default(options.delay, 300), key1 = {
      num = default(options.num, 1), freq = default(options.freq, 38000),
      type = default(options.type, 1), key_code = code,
    }}, json_order)
  end

  local function timings_message(options)
    local timings = options.timings
    if #timings == 0 then return end
    local modulation = default(options.modulation, 38000)
    if type(modulation) ~= "number" or modulation <= 30000 then return end
    local bytes = {}
    for _, value in ipairs(timings) do
      if value == json.null then value = 0
      elseif type(value) == "boolean" then value = value and 1 or 0
      elseif type(value) == "string" and value:match("^%s*$") then value = 0 end
      value = tonumber(value)
      if value == nil or value ~= value or math.abs(value) == math.huge then return end
      value = math.floor(math.abs(value))
      if value > 0xFFFF then return end
      bytes[#bytes + 1] = string.pack("<I2", value)
    end
    local raw, compressed = table.concat(bytes), {}
    for offset = 1, #raw, 32 do
      local part = raw:sub(offset, offset + 31)
      compressed[#compressed + 1] = string.char(#part - 1) .. part
    end
    return key_message(base64_encode(table.concat(compressed)), {
      num = 1 + default(options.repeat_count, 0), freq = modulation,
    })
  end

  local function normalize_ir_message(code)
    local trimmed = code:match("^%s*(.-)%s*$")
    if trimmed == "" then return end
    if trimmed:sub(1, 1) == "{" and trimmed:sub(-1) == "}" then
      local decoded, position, err = json.decode(trimmed, 1, json.null)
      if not err and type(decoded) == "table" and trimmed:sub(position):match("^%s*$") then
        local timings_meta = type(decoded.timings) == "table" and getmetatable(decoded.timings)
        if timings_meta and timings_meta.__jsontype == "array" then
          local ok, payload = pcall(timings_message, decoded)
          if ok and payload then return payload end
        elseif decoded.key_num ~= nil and decoded.key1 ~= nil then
          return json.encode(decoded, json_order)
        elseif decoded.key_code ~= nil then
          return key_message(decoded.key_code, decoded)
        end
      end
    end
    return key_message(trimmed)
  end

  local function clear_incoming(device)
    for _, field in ipairs({IR_INCOMING_FIELD, IR_INCOMING_LENGTH_FIELD, IR_INCOMING_SEQ_FIELD, IR_INCOMING_POSITION_FIELD}) do
      device:set_field(field, nil, {persist = false})
    end
  end

  local function get_outgoing_messages(device)
    local messages = type(device) == "table" and device:get_field(IR_OUTGOING_FIELD) or nil
    if type(messages) ~= "table" then
      messages = {}
      device:set_field(IR_OUTGOING_FIELD, messages, { persist = false })
    end
    return messages
  end

  local function next_seq(device)
    local seq = type(device) == "table" and device:get_field(IR_NEXT_SEQ_FIELD) or 0
    if type(seq) ~= "number" then
      seq = 0
    end
    seq = (seq + 1) % 0x10000
    device:set_field(IR_NEXT_SEQ_FIELD, seq, { persist = false })
    return seq
  end

  local function emit_learning_state(device, state)
    custom_capability_binding.emit_state(device, "main", learn_ir_code_metadata, state)
  end

  local function emit_learned_code(device, code)
    custom_capability_binding.emit_state(device, "main", learned_ir_code_metadata, code or "")
  end

  local function emit_code_to_send(device, code)
    custom_capability_binding.emit_state(device, "main", ir_code_to_send_metadata, code or "")
  end

  function zcl.emit_ir_state(device, preset)
    if type(preset) ~= "table" or preset.ir_controller ~= true then
      return
    end

    local learning = device:get_field(IR_LEARNING_FIELD) == true
    emit_learning_state(device, learning and "start" or "stop")
    emit_learned_code(device, device:get_field(IR_LAST_LEARNED_FIELD) or "")
    emit_code_to_send(device, device:get_field(IR_LAST_SENT_FIELD) or "")
  end

  function zcl.start_ir_learning(device, preset)
    if zcl.send_raw_cluster_command == nil then
      return false
    end

    device:set_field(IR_LEARNING_FIELD, true, { persist = false })
    emit_learning_state(device, "start")
    return send_ir_command(device, IR_CONTROL_CLUSTER, 0x00, '{"study":0}', get_endpoint(preset))
  end

  function zcl.stop_ir_learning(device, preset)
    if zcl.send_raw_cluster_command == nil then
      return false
    end

    device:set_field(IR_LEARNING_FIELD, false, { persist = false })
    emit_learning_state(device, "stop")
    return send_ir_command(device, IR_CONTROL_CLUSTER, 0x00, '{"study":1}', get_endpoint(preset))
  end

  function zcl.send_ir_code(device, preset, code)
    if zcl.send_raw_cluster_command == nil or type(code) ~= "string" or code == "" then
      return false
    end

    local payload = normalize_ir_message(code)
    if payload == nil then return false end
    local seq = next_seq(device)
    clear_incoming(device)
    device:set_field(IR_OUTGOING_FIELD, {[seq] = payload}, {persist = false})
    device:set_field(IR_LAST_SENT_FIELD, code, { persist = false })
    emit_code_to_send(device, code)

    return send_ir_command(
      device,
      IR_TRANSMIT_CLUSTER,
      0x00,
      encode_le16(seq) ..
      encode_le32(#payload) ..
      encode_le32(0) ..
      encode_le16(IR_CONTROL_CLUSTER) ..
      string.char(0x01) ..
      string.char(0x02) ..
      encode_le16(0),
      get_endpoint(preset)
    )
  end

  local function request_ir_chunk(device, preset, seq, position)
    return send_ir_command(
      device,
      IR_TRANSMIT_CLUSTER,
      0x02,
      encode_le16(seq) .. encode_le32(position) .. string.char(IR_MAX_CHUNK),
      get_endpoint(preset)
    )
  end

  local function send_outgoing_chunk(device, preset, seq, position)
    local outgoing = get_outgoing_messages(device)
    local message = outgoing[seq]
    if type(message) ~= "string" then
      log.warn(string.format("missing pending IR message for seq=%s", tostring(seq)))
      return false
    end

    local start_index = position + 1
    local last_index = math.min(#message, position + 0x32)
    local part = message:sub(start_index, last_index)
    local crc = compute_crc(part)

    return send_ir_command(
      device,
      IR_TRANSMIT_CLUSTER,
      0x03,
      string.char(0x00) ..
      encode_le16(seq) ..
      encode_le32(position) ..
      string.char(#part) ..
      part ..
      string.char(crc),
      get_endpoint(preset)
    )
  end

  local function append_incoming_part(device, position, part, total_length)
    local current = device:get_field(IR_INCOMING_FIELD)
    if type(current) ~= "string" then
      current = string.rep("\0", total_length)
    elseif #current < total_length then
      current = current .. string.rep("\0", total_length - #current)
    end

    local prefix = position > 0 and current:sub(1, position) or ""
    local suffix_start = position + #part + 1
    local suffix = suffix_start <= #current and current:sub(suffix_start) or ""
    local updated = prefix .. part .. suffix
    device:set_field(IR_INCOMING_FIELD, updated, { persist = false })
    return updated
  end

  function zcl.handle_ir_transmit_command(device, preset, zb_rx)
    if zcl.send_raw_cluster_command == nil then
      return false
    end

    local command_id = zb_rx and zb_rx.body and zb_rx.body.zcl_header and zb_rx.body.zcl_header.cmd and zb_rx.body.zcl_header.cmd.value or nil
    local body = zb_rx and zb_rx.body and zb_rx.body.zcl_body and zb_rx.body.zcl_body.body_bytes or nil
    if type(command_id) ~= "number" or type(body) ~= "string" then
      return false
    end

    if command_id == 0x00 then
      local seq = decode_le16(body, 1)
      local length = decode_le32(body, 3)
      local unk1 = decode_le32(body, 7) or 0
      local cluster_id = decode_le16(body, 11) or IR_CONTROL_CLUSTER
      local unk2 = string.byte(body, 13) or 0
      local cmd = string.byte(body, 14) or 0
      local unk3 = decode_le16(body, 15) or 0
      if seq == nil or length == nil then
        return false
      end

      device:set_field(IR_INCOMING_FIELD, "", { persist = false })
      device:set_field(IR_INCOMING_LENGTH_FIELD, length, { persist = false })
      device:set_field(IR_INCOMING_SEQ_FIELD, seq, { persist = false })
      device:set_field(IR_INCOMING_POSITION_FIELD, 0, { persist = false })
      device:set_field(IR_OUTGOING_FIELD, {}, { persist = false })

      send_ir_command(
        device,
        IR_TRANSMIT_CLUSTER,
        0x01,
        string.char(0x00) ..
        encode_le16(seq) ..
        encode_le32(length) ..
        encode_le32(unk1) ..
        encode_le16(cluster_id) ..
        string.char(unk2) ..
        string.char(cmd) ..
        encode_le16(unk3),
        get_endpoint(preset)
      )
      request_ir_chunk(device, preset, seq, 0)
      return true
    end

    if command_id == 0x02 then
      local seq = decode_le16(body, 1)
      local position = decode_le32(body, 3)
      if seq == nil or position == nil or #body < 7 then
        return false
      end

      return send_outgoing_chunk(device, preset, seq, position)
    end

    if command_id == 0x03 then
      local seq = decode_le16(body, 2)
      local position = decode_le32(body, 4)
      local part_length = string.byte(body, 8)
      if seq == nil or position == nil or part_length == nil or #body < 9 + part_length then
        return false
      end
      if device:get_field(IR_INCOMING_SEQ_FIELD) ~= seq or device:get_field(IR_INCOMING_POSITION_FIELD) ~= position then return false end

      local part = body:sub(9, 8 + part_length)
      local crc = string.byte(body, 9 + part_length) or 0
      if compute_crc(part) ~= crc then
        log.warn(string.format("IR chunk CRC mismatch seq=%s position=%s", tostring(seq), tostring(position)))
        return false
      end

      local total_length = device:get_field(IR_INCOMING_LENGTH_FIELD)
      if type(total_length) ~= "number" then return false end
      part = part:sub(1, math.max(0, total_length - position))

      local updated = append_incoming_part(device, position, part, total_length)
      device:set_field(IR_INCOMING_POSITION_FIELD, position + #part, {persist = false})
      if position + #part < total_length then
        request_ir_chunk(device, preset, seq, position + #part)
      else
        send_ir_command(
          device,
          IR_TRANSMIT_CLUSTER,
          0x04,
          string.char(0x00) .. encode_le16(seq) .. encode_le16(0),
          get_endpoint(preset)
        )
        device:set_field(IR_INCOMING_FIELD, updated:sub(1, total_length), { persist = false })
      end
      return true
    end

    if command_id == 0x04 then
      local seq = decode_le16(body, 2)
      if seq == nil then
        return false
      end

      local sent = send_ir_command(
        device,
        IR_TRANSMIT_CLUSTER,
        0x05,
        encode_le16(seq) .. encode_le16(0),
        get_endpoint(preset)
      )
      if sent then
        get_outgoing_messages(device)[seq] = nil
        if device:get_field(IR_INCOMING_SEQ_FIELD) == seq then clear_incoming(device) end
      end
      return sent
    end

    if command_id == 0x05 then
      local seq = decode_le16(body, 1)
      if seq == nil or device:get_field(IR_INCOMING_SEQ_FIELD) ~= seq then return false end
      local learned = device:get_field(IR_INCOMING_FIELD) or ""
      local length = device:get_field(IR_INCOMING_LENGTH_FIELD)
      if #learned < length then learned = learned .. string.rep("\0", length - #learned) end
      local encoded = base64_encode(learned)
      device:set_field(IR_LAST_LEARNED_FIELD, encoded, { persist = false })
      clear_incoming(device)
      emit_learned_code(device, encoded)
      zcl.stop_ir_learning(device, preset)
      return true
    end

    return false
  end

end

return load_ir_session
