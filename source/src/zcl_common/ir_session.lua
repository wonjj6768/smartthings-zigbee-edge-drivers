-- Zosung/Tuya TS1201 IR learning + transmit session helper.

local function load_ir_session(zcl)

  local custom_capabilities = require "core.custom_capabilities"
  local custom_capability_binding = require "core.custom_capability_binding"
  local log = require "log"

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
  local IR_LAST_LEARNED_FIELD = "__ir_last_learned_code"
  local IR_LAST_SENT_FIELD = "__ir_last_sent_code"

  local function encode_le16(value)
    local clamped = math.max(0, math.min(0xFFFF, math.floor(value or 0)))
    return string.char(bit32.band(clamped, 0xFF))
      .. string.char(bit32.band(bit32.rshift(clamped, 8), 0xFF))
  end

  local function encode_le32(value)
    local clamped = math.max(0, math.min(0xFFFFFFFF, math.floor(value or 0)))
    return string.char(bit32.band(clamped, 0xFF))
      .. string.char(bit32.band(bit32.rshift(clamped, 8), 0xFF))
      .. string.char(bit32.band(bit32.rshift(clamped, 16), 0xFF))
      .. string.char(bit32.band(bit32.rshift(clamped, 24), 0xFF))
  end

  local function decode_le16(bytes, offset)
    offset = offset or 1
    if type(bytes) ~= "string" or #bytes < offset + 1 then
      return nil
    end

    local b1 = string.byte(bytes, offset) or 0
    local b2 = string.byte(bytes, offset + 1) or 0
    return b1 + bit32.lshift(b2, 8)
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
      bit32.lshift(b2, 8) +
      bit32.lshift(b3, 16) +
      bit32.lshift(b4, 24)
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
      local n = bit32.lshift(a, 16) + bit32.lshift(b, 8) + c

      encoded[#encoded + 1] = alphabet:sub(bit32.rshift(n, 18) + 1, bit32.rshift(n, 18) + 1)
      encoded[#encoded + 1] = alphabet:sub(bit32.band(bit32.rshift(n, 12), 0x3F) + 1, bit32.band(bit32.rshift(n, 12), 0x3F) + 1)

      if index + 1 <= length then
        encoded[#encoded + 1] = alphabet:sub(bit32.band(bit32.rshift(n, 6), 0x3F) + 1, bit32.band(bit32.rshift(n, 6), 0x3F) + 1)
      else
        encoded[#encoded + 1] = "="
      end

      if index + 2 <= length then
        encoded[#encoded + 1] = alphabet:sub(bit32.band(n, 0x3F) + 1, bit32.band(n, 0x3F) + 1)
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
    return zcl.send_raw_cluster_command(device, IR_CONTROL_CLUSTER, 0x00, '{"study":0}', get_endpoint(preset))
  end

  function zcl.stop_ir_learning(device, preset)
    if zcl.send_raw_cluster_command == nil then
      return false
    end

    device:set_field(IR_LEARNING_FIELD, false, { persist = false })
    emit_learning_state(device, "stop")
    return zcl.send_raw_cluster_command(device, IR_CONTROL_CLUSTER, 0x00, '{"study":1}', get_endpoint(preset))
  end

  function zcl.send_ir_code(device, preset, code)
    if zcl.send_raw_cluster_command == nil or type(code) ~= "string" or code == "" then
      return false
    end

    local seq = next_seq(device)
    local payload = string.format(
      '{"key_num":1,"delay":300,"key1":{"num":1,"freq":38000,"type":1,"key_code":"%s"}}',
      code
    )

    local outgoing = get_outgoing_messages(device)
    outgoing[seq] = payload
    device:set_field(IR_LAST_SENT_FIELD, code, { persist = false })
    emit_code_to_send(device, code)

    return zcl.send_raw_cluster_command(
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
    return zcl.send_raw_cluster_command(
      device,
      IR_TRANSMIT_CLUSTER,
      0x02,
      encode_le16(seq) .. encode_le32(position) .. string.char(IR_MAX_CHUNK),
      get_endpoint(preset)
    )
  end

  local function send_outgoing_chunk(device, preset, seq, position, maxlen)
    local outgoing = get_outgoing_messages(device)
    local message = outgoing[seq]
    if type(message) ~= "string" then
      log.warn(string.format("missing pending IR message for seq=%s", tostring(seq)))
      return false
    end

    local start_index = position + 1
    local last_index = math.min(#message, position + maxlen)
    local part = message:sub(start_index, last_index)
    local crc = compute_crc(part)

    return zcl.send_raw_cluster_command(
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

      zcl.send_raw_cluster_command(
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
      local maxlen = string.byte(body, 7) or IR_MAX_CHUNK
      if seq == nil or position == nil then
        return false
      end

      return send_outgoing_chunk(device, preset, seq, position, maxlen)
    end

    if command_id == 0x03 then
      local seq = decode_le16(body, 2)
      local position = decode_le32(body, 4)
      local part_length = string.byte(body, 8)
      if seq == nil or position == nil or part_length == nil then
        return false
      end

      local part = body:sub(9, 8 + part_length)
      local crc = string.byte(body, 9 + part_length) or 0
      if compute_crc(part) ~= crc then
        log.warn(string.format("IR chunk CRC mismatch seq=%s position=%s", tostring(seq), tostring(position)))
      end

      local total_length = device:get_field(IR_INCOMING_LENGTH_FIELD)
      if type(total_length) ~= "number" then
        total_length = position + #part
      end

      local updated = append_incoming_part(device, position, part, total_length)
      if position + #part < total_length then
        request_ir_chunk(device, preset, seq, position + #part)
      else
        zcl.send_raw_cluster_command(
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

      local sent = zcl.send_raw_cluster_command(
        device,
        IR_TRANSMIT_CLUSTER,
        0x05,
        encode_le16(seq) .. encode_le16(0),
        get_endpoint(preset)
      )
      if sent then
        get_outgoing_messages(device)[seq] = nil
      end
      return sent
    end

    if command_id == 0x05 then
      local learned = device:get_field(IR_INCOMING_FIELD) or ""
      local encoded = base64_encode(learned)
      device:set_field(IR_LAST_LEARNED_FIELD, encoded, { persist = false })
      device:set_field(IR_INCOMING_FIELD, nil, { persist = false })
      device:set_field(IR_INCOMING_LENGTH_FIELD, nil, { persist = false })
      emit_learned_code(device, encoded)
      zcl.stop_ir_learning(device, preset)
      return true
    end

    return false
  end

end

return load_ir_session
