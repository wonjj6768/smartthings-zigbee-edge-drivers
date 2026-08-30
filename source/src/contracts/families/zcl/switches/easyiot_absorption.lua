local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local gb2312 = require "runtime.gb2312"
local cluster_base = require "st.zigbee.cluster_base"
local data_types = require "st.zigbee.data_types"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local CLUSTER_TUNNELING = 0x0704
local COMMAND_TRANSFER_DATA_TO_SERVER = 0x02
local COMMAND_TRANSFER_DATA_TO_CLIENT = 0x01
local CLUSTER_DOOR_LOCK = 0x0101
local CLUSTER_OCCUPANCY = 0x0406
local CAPABILITY_NAMESPACE = "concertmirror08464."
local UNIX_SECONDS_AT_2000 = 946684800

local ZL01_TIMEOUT_FIELD = "__easyiot_zl01_timeout_seconds"
local ZL01_TIMEOUT_PIN_FIELD = "__easyiot_zl01_timeout_pin"
local ZL01_TEMP_START_FIELD = "__easyiot_zl01_temp_start"
local ZL01_TEMP_END_FIELD = "__easyiot_zl01_temp_end"
local ZL01_TEMP_USER_FIELD = "__easyiot_zl01_temp_user"
local ZL01_TEMP_VALID_FIELD = "__easyiot_zl01_temp_valid"
local ZL01_TEMP_PIN_FIELD = "__easyiot_zl01_temp_pin"
local GMS02_MOTION_COEFFICIENT_FIELD = "__easyiot_24gms02_motion_coefficient"
local GMS02_HOLD_COEFFICIENT_FIELD = "__easyiot_24gms02_hold_coefficient"
local GMS02_MICRO_COEFFICIENT_FIELD = "__easyiot_24gms02_micro_coefficient"

local CUSTOM_EMITTERS = {
  easyiot24gAutoCalibrationProgress = emit.easyiot24gAutoCalibrationProgress(),
  easyiot24gPirDelay = emit.easyiot24gPirDelay(),
  easyiot24gUltrasonicOccupiedDelay = emit.easyiot24gUltrasonicOccupiedDelay(),
  easyiot24gUsUnoccupiedDelay = emit.easyiot24gUsUnoccupiedDelay(),
  easyiot24gWorkMode = emit.easyiot24gWorkMode(),
  easyiotIr01LastReceivedCommand = emit.easyiotIr01LastReceivedCommand(),
  easyiotRs232LastReceivedCommand = emit.easyiotRs232LastReceivedCommand(),
  easyiotRs485LastReceivedCommand = emit.easyiotRs485LastReceivedCommand(),
  easyiotTts01LastReceivedStatus = emit.easyiotTts01LastReceivedStatus(),
}

local function custom_emit(name)
  return assert(CUSTOM_EMITTERS[name], "missing EasyIoT emitter: " .. tostring(name))
end

local function uint16_le(value)
  value = math.floor(tonumber(value))
  return string.char(value % 0x100, math.floor(value / 0x100) % 0x100)
end

local function uint32_le(value)
  value = math.floor(tonumber(value))
  return string.char(
    value % 0x100,
    math.floor(value / 0x100) % 0x100,
    math.floor(value / 0x10000) % 0x100,
    math.floor(value / 0x1000000) % 0x100
  )
end

local function uint16_be(value)
  value = math.floor(tonumber(value))
  return string.char(math.floor(value / 0x100) % 0x100, value % 0x100)
end

local function xor_byte(left, right)
  local result = 0
  local place = 1
  for _ = 1, 8 do
    if left % 2 ~= right % 2 then
      result = result + place
    end
    left = math.floor(left / 2)
    right = math.floor(right / 2)
    place = place * 2
  end
  return result
end

local function ac_command(command_id, device_type, button_id, value)
  local bytes = { command_id, device_type, button_id, value, 0x00 }
  local checksum = 0
  for _, byte in ipairs(bytes) do
    checksum = xor_byte(checksum, byte)
  end
  return string.char(bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], checksum)
end

local function raw_hex(value)
  local output = {}
  local position = 1
  while position + 1 <= #value do
    local byte = tonumber(string.sub(value, position, position + 1), 16)
    if byte == nil then
      break
    end
    output[#output + 1] = string.char(byte)
    position = position + 2
  end
  return table.concat(output)
end

local function send_tunnel(device, tunnel_id, payload, context)
  return zcl.send_raw_cluster_command(
    device,
    CLUSTER_TUNNELING,
    COMMAND_TRANSFER_DATA_TO_SERVER,
    uint16_le(tunnel_id) .. payload,
    context.endpoint or 1,
    nil,
    nil,
    true
  )
end

local function send_door_lock_command(device, command_id, payload, context)
  return zcl.send_raw_cluster_command(
    device,
    CLUSTER_DOOR_LOCK,
    command_id,
    payload,
    context.endpoint or 1,
    nil,
    nil,
    true
  )
end

local function write_attribute_without_default_response(device, attribute_id, value, value_type, context)
  local request = cluster_base.write_attribute(
    device,
    data_types.ClusterId(CLUSTER_OCCUPANCY),
    data_types.AttributeId(attribute_id),
    value_type(value)
  )
  request.body.zcl_header.frame_ctrl:set_disable_default_response()
  if context.endpoint ~= nil and type(request.to_endpoint) == "function" then
    request = request:to_endpoint(context.endpoint)
  end
  device:send(request)
  return true
end

local function octet_string(value)
  return string.char(#value) .. value
end

local function tunnel_data(zb_rx)
  local body_bytes = zb_rx and zb_rx.body and zb_rx.body.zcl_body and zb_rx.body.zcl_body.body_bytes or nil
  if type(body_bytes) ~= "string" or #body_bytes < 2 then
    return nil
  end
  return string.sub(body_bytes, 3)
end

local function emit_main(device, event)
  if event ~= nil then
    device:emit_component_event({ id = "main" }, event)
  end
end

local function receive_hex_state(emitter)
  return function(device, zb_rx)
    local data = tunnel_data(zb_rx)
    if data == nil then return false end
    local hex = (data:gsub(".", function(byte)
      return string.format("%02x", string.byte(byte))
    end))
    emit_main(device, emitter(device, hex))
    return true
  end
end

zcl.register_cluster_command_handler(CLUSTER_TUNNELING, COMMAND_TRANSFER_DATA_TO_CLIENT, function(device, preset, zb_rx)
  if type(preset.easyiot_tunnel_receiver) ~= "function" then
    return false
  end
  return preset.easyiot_tunnel_receiver(device, zb_rx)
end)

local function raw_tunnel_sender(tunnel_id)
  return function(device, _, value, context)
    if type(value) ~= "string" or value == "" then return false end
    return send_tunnel(device, tunnel_id, raw_hex(value), context)
  end
end

local function ir_power_sender(device, _, value, context)
  local power_value = (value == true or value == "on") and 0x00 or 0x01
  return send_tunnel(device, 0x0000, ac_command(0x86, 0x01, 0x00, power_value), context)
end

local function ir_temperature_sender(device, _, value, context)
  local temperature = math.floor(tonumber(value))
  return send_tunnel(device, 0x0000, ac_command(0x86, 0x01, 0x02, temperature - 16), context)
end

local function ir_mode_sender(device, _, value, context)
  local encoded = ({
    auto = 0x00,
    cooling = 0x01,
    dehumidification = 0x02,
    air_supply = 0x03,
    heating = 0x04,
  })[value]
  if encoded == nil then return false end
  return send_tunnel(device, 0x0000, ac_command(0x86, 0x01, 0x01, encoded), context)
end

local function ir_wind_speed_sender(device, _, value, context)
  local encoded = ({ auto = 0x00, low = 0x01, medium = 0x02, high = 0x03, strong = 0x04 })[value]
  if encoded == nil then return false end
  return send_tunnel(device, 0x0000, ac_command(0x86, 0x01, 0x04, encoded), context)
end

local function ir_kfid_sender(device, _, value, context)
  local kfid = math.floor(tonumber(value))
  local high = math.floor(kfid / 0x100) % 0x100
  local low = kfid % 0x100
  return send_tunnel(device, 0x0000, ac_command(0x80, 0x01, high, low), context)
end

local function tts_sender(device, _, value, context)
  if type(value) ~= "string" or value == "" then return false end
  local encoded = gb2312.encode(value)
  local protocol_frame = string.char(0xFD)
    .. uint16_be(#encoded + 2)
    .. string.char(0x01, 0x01)
    .. encoded
  return send_tunnel(device, 0x0000, protocol_frame, context)
end

local function rs_baud_sender(device, _, value, context)
  local baud = ({
    ["1200"] = 1200,
    ["2400"] = 2400,
    ["4800"] = 4800,
    ["9600"] = 9600,
    ["19200"] = 19200,
    ["38400"] = 38400,
    ["57600"] = 57600,
    ["115200"] = 115200,
    ["230400"] = 230400,
    ["460800"] = 460800,
    ["921600"] = 921600,
  })[tostring(value)]
  if baud == nil then return false end
  return send_tunnel(device, 0x0001, string.char(0x01, 0x02, 0x04, 0x23) .. uint32_le(baud), context)
end

local function rs_parity_sender(device, _, value, context)
  local encoded = ({ none = 0x00, even = 0x01, odd = 0x02 })[value]
  if encoded == nil then return false end
  return send_tunnel(device, 0x0001, string.char(0x05, 0x02, 0x01, 0x30, encoded), context)
end

local function rs_stop_bits_sender(device, _, value, context)
  local encoded = ({ ["1"] = 0x00, ["1.5"] = 0x01, ["2"] = 0x02 })[tostring(value)]
  if encoded == nil then return false end
  return send_tunnel(device, 0x0001, string.char(0x09, 0x02, 0x01, 0x30, encoded), context)
end

local function store_numeric(field)
  return function(device, _, value)
    device:set_field(field, math.floor(tonumber(value)), { persist = true })
    return true
  end
end

local function store_text(field, maximum_bytes)
  return function(device, _, value)
    if type(value) ~= "string" then return false end
    if maximum_bytes ~= nil and #value > maximum_bytes then return false end
    device:set_field(field, value, { persist = false })
    return true
  end
end

local function store_uint_decimal(field, minimum, maximum)
  return function(device, _, value)
    if type(value) ~= "string" or #value < 1 or #value > 10 or value:match("^[0-9]+$") == nil then
      return false
    end
    local numeric = tonumber(value)
    if numeric == nil or numeric < minimum or numeric > maximum then return false end
    device:set_field(field, numeric, { persist = true })
    return true
  end
end

-- JavaScript's string.length counts UTF-16 code units. The frozen Z2M
-- converter places that count in the inner PIN-length byte, while the outer
-- OCTET_STR length continues to count the encoded UTF-8 bytes.
local function utf16_code_unit_length(value)
  local length = 0
  for _, codepoint in utf8.codes(value) do
    length = length + (codepoint >= 0x10000 and 2 or 1)
  end
  return length
end

local function zl01_unlock_sender(device, _, value, context)
  if type(value) ~= "string" or #value > 254 then return false end
  local pin_with_inner_length = string.char(utf16_code_unit_length(value)) .. value
  return send_door_lock_command(device, 0x01, octet_string(pin_with_inner_length), context)
end

local function zl01_unlock_timeout_sender(device, _, _, context)
  local timeout = tonumber(device:get_field(ZL01_TIMEOUT_FIELD)) or 0
  local pin = device:get_field(ZL01_TIMEOUT_PIN_FIELD)
  if type(pin) ~= "string" or #pin > 254 then return false end
  local pin_with_inner_length = string.char(utf16_code_unit_length(pin)) .. pin
  local payload = uint32_le(timeout) .. octet_string(pin_with_inner_length)
  return send_door_lock_command(device, 0x03, payload, context)
end

local function zl01_temp_apply_sender(device, _, _, context)
  local start_time = tonumber(device:get_field(ZL01_TEMP_START_FIELD))
  local end_time = tonumber(device:get_field(ZL01_TEMP_END_FIELD))
  local user_id = tonumber(device:get_field(ZL01_TEMP_USER_FIELD))
  local valid_times = tonumber(device:get_field(ZL01_TEMP_VALID_FIELD))
  local pin = device:get_field(ZL01_TEMP_PIN_FIELD)
  if start_time == nil or end_time == nil or user_id == nil or valid_times == nil or
      type(pin) ~= "string" or #pin > 255 then
    return false
  end
  local payload = uint32_le(start_time - UNIX_SECONDS_AT_2000)
    .. uint32_le(end_time - UNIX_SECONDS_AT_2000)
    .. uint16_le(user_id)
    .. string.char(math.floor(valid_times))
    .. octet_string(pin)
  return send_door_lock_command(device, 0xB6, payload, context)
end

local function zl01_temp_clear_user_sender(device, _, value, context)
  return send_door_lock_command(device, 0xB8, uint16_le(value), context)
end

local function zl01_temp_clear_all_sender(device, _, _, context)
  return send_door_lock_command(device, 0xB9, "", context)
end

local function gms02_detection_range_sender(device, _, value, context)
  local encoded = math.floor((tonumber(value) * 10) + 0.5)
  return send_tunnel(device, 0x0001, string.char(0x07, 0x06, 0x01, 0x20, encoded), context)
end

local function gms02_work_mode_sender(device, _, value, context)
  local encoded = ({
    pirOnly = 1,
    radarOnly = 2,
    pirRadarAnd = 3,
    occupied_first = 4,
    unoccupied_first = 5,
  })[value]
  if encoded == nil then return false end
  return write_attribute_without_default_response(device, 0xFE01, encoded, data_types.Enum8, context)
end

local function gms02_delay_sender(attribute_id)
  return function(device, _, value, context)
    return write_attribute_without_default_response(
      device,
      attribute_id,
      math.floor(tonumber(value)),
      data_types.Uint16,
      context
    )
  end
end

local function gms02_calibration_sender(device, _, _, context)
  local motion = tonumber(device:get_field(GMS02_MOTION_COEFFICIENT_FIELD)) or 30
  local hold = tonumber(device:get_field(GMS02_HOLD_COEFFICIENT_FIELD)) or 30
  local micro = tonumber(device:get_field(GMS02_MICRO_COEFFICIENT_FIELD)) or 30
  local payload = string.char(0x01, 0x06, 0x06, 0x4C)
    .. uint16_le(motion)
    .. uint16_le(hold)
    .. uint16_le(micro)
  return send_tunnel(device, 0x0001, payload, context)
end

local function gms02_tunnel_receiver(device, zb_rx)
  local data = tunnel_data(zb_rx)
  if type(data) ~= "string" or #data < 5 then return false end
  if string.byte(data, 1) ~= 0x03 or string.byte(data, 2) ~= 0x06 then return false end
  local progress = string.byte(data, 5)
  if progress > 100 then return false end
  emit_main(device, custom_emit("easyiot24gAutoCalibrationProgress")(device, progress))
  return true
end

local function command_mapping(cluster_id, name, sender, options)
  options = options or {}
  options.name = name
  options.write_only = true
  options.sender = sender
  return zcl.cluster_attribute(cluster_id, nil, options)
end

local ir01 = {
  profile = "controllers-easyiot-ir01",
  refresh_state_query = false,
  easyiot_tunnel_receiver = receive_hex_state(custom_emit("easyiotIr01LastReceivedCommand")),
  zcl_clusters = {
    command_mapping(CLUSTER_TUNNELING, "easyiot_ir01_send_command", raw_tunnel_sender(0x0000)),
    command_mapping(CLUSTER_TUNNELING, "switch", ir_power_sender),
    command_mapping(CLUSTER_TUNNELING, "easyiot_ir01_ac_temperature", ir_temperature_sender, {
      numeric_range = { minimum = 16, maximum = 32, step = 1, unit = "C" },
    }),
    command_mapping(CLUSTER_TUNNELING, "easyiot_ir01_ac_mode", ir_mode_sender),
    command_mapping(CLUSTER_TUNNELING, "easyiot_ir01_ac_wind_speed", ir_wind_speed_sender),
    command_mapping(CLUSTER_TUNNELING, "easyiot_ir01_ac_kfid", ir_kfid_sender, {
      numeric_range = { minimum = 0, maximum = 1354, step = 1 },
    }),
  },
  capability_commands = {
    {
      capability_id = CAPABILITY_NAMESPACE .. "easyiotIr01SendCommand",
      command_name = "sendCommand",
      argument_name = "command",
      mapping_name = "easyiot_ir01_send_command",
    },
  },
}

local tts01 = {
  profile = "controllers-easyiot-tts01",
  refresh_state_query = false,
  easyiot_tunnel_receiver = receive_hex_state(custom_emit("easyiotTts01LastReceivedStatus")),
  zcl_clusters = {
    command_mapping(CLUSTER_TUNNELING, "easyiot_tts01_send_tts", tts_sender),
  },
  capability_commands = {
    {
      capability_id = CAPABILITY_NAMESPACE .. "easyiotTts01SendTts",
      command_name = "sendTts",
      argument_name = "text",
      mapping_name = "easyiot_tts01_send_tts",
    },
  },
}

local rs485 = {
  profile = "controllers-easyiot-rs485",
  refresh_state_query = false,
  easyiot_tunnel_receiver = receive_hex_state(custom_emit("easyiotRs485LastReceivedCommand")),
  zcl_clusters = {
    command_mapping(CLUSTER_TUNNELING, "easyiot_rs485_send_command", raw_tunnel_sender(0x0000)),
    command_mapping(CLUSTER_TUNNELING, "easyiot_rs485_baud_rate", rs_baud_sender),
    command_mapping(CLUSTER_TUNNELING, "easyiot_rs485_parity", rs_parity_sender),
    command_mapping(CLUSTER_TUNNELING, "easyiot_rs485_stop_bits", rs_stop_bits_sender),
  },
  capability_commands = {
    {
      capability_id = CAPABILITY_NAMESPACE .. "easyiotRs485SendCommand",
      command_name = "sendCommand",
      argument_name = "command",
      mapping_name = "easyiot_rs485_send_command",
    },
  },
}

local rs232 = {
  profile = "controllers-easyiot-rs232",
  refresh_state_query = false,
  easyiot_tunnel_receiver = receive_hex_state(custom_emit("easyiotRs232LastReceivedCommand")),
  zcl_clusters = {
    command_mapping(CLUSTER_TUNNELING, "easyiot_rs232_send_command", raw_tunnel_sender(0x0000)),
    command_mapping(CLUSTER_TUNNELING, "easyiot_rs232_baud_rate", rs_baud_sender),
    command_mapping(CLUSTER_TUNNELING, "easyiot_rs232_parity", rs_parity_sender),
    command_mapping(CLUSTER_TUNNELING, "easyiot_rs232_stop_bits", rs_stop_bits_sender),
  },
  capability_commands = {
    {
      capability_id = CAPABILITY_NAMESPACE .. "easyiotRs232SendCommand",
      command_name = "sendCommand",
      argument_name = "command",
      mapping_name = "easyiot_rs232_send_command",
    },
  },
}

local zl01 = {
  profile = "locks-easyiot-zl01",
  refresh_state_query = false,
  zcl_clusters = {
    zcl.battery({ minimum_interval = 30, maximum_interval = 1800, reportable_change = 1 }),
    command_mapping(CLUSTER_DOOR_LOCK, "easyiot_zl01_unlock_pin", zl01_unlock_sender),
    command_mapping(
      CLUSTER_DOOR_LOCK,
      "easyiot_zl01_timeout_seconds",
      store_uint_decimal(ZL01_TIMEOUT_FIELD, 0, 4294967295)
    ),
    command_mapping(CLUSTER_DOOR_LOCK, "easyiot_zl01_timeout_pin", store_text(ZL01_TIMEOUT_PIN_FIELD, 254)),
    command_mapping(CLUSTER_DOOR_LOCK, "easyiot_zl01_unlock_timeout", zl01_unlock_timeout_sender),
    command_mapping(
      CLUSTER_DOOR_LOCK,
      "easyiot_zl01_temp_start",
      store_uint_decimal(ZL01_TEMP_START_FIELD, 946684800, 5241652095)
    ),
    command_mapping(
      CLUSTER_DOOR_LOCK,
      "easyiot_zl01_temp_end",
      store_uint_decimal(ZL01_TEMP_END_FIELD, 946684800, 5241652095)
    ),
    command_mapping(CLUSTER_DOOR_LOCK, "easyiot_zl01_temp_user", store_numeric(ZL01_TEMP_USER_FIELD), {
      numeric_range = { minimum = 1, maximum = 20, step = 1 },
    }),
    command_mapping(CLUSTER_DOOR_LOCK, "easyiot_zl01_temp_valid", store_numeric(ZL01_TEMP_VALID_FIELD), {
      numeric_range = { minimum = 0, maximum = 255, step = 1 },
    }),
    command_mapping(CLUSTER_DOOR_LOCK, "easyiot_zl01_temp_pin", store_text(ZL01_TEMP_PIN_FIELD, 255)),
    command_mapping(CLUSTER_DOOR_LOCK, "easyiot_zl01_temp_apply", zl01_temp_apply_sender),
    command_mapping(CLUSTER_DOOR_LOCK, "easyiot_zl01_temp_clear_user", zl01_temp_clear_user_sender, {
      numeric_range = { minimum = 1, maximum = 20, step = 1 },
    }),
    command_mapping(CLUSTER_DOOR_LOCK, "easyiot_zl01_temp_clear_all", zl01_temp_clear_all_sender),
  },
  capability_commands = {
    {
      capability_id = CAPABILITY_NAMESPACE .. "easyiotZl01UnlockPin",
      command_name = "unlockDoor",
      argument_name = "pin",
      mapping_name = "easyiot_zl01_unlock_pin",
    },
    {
      capability_id = CAPABILITY_NAMESPACE .. "easyiotZl01TimeoutDecimal",
      command_name = "setTimeoutDecimal",
      argument_name = "timeoutSeconds",
      mapping_name = "easyiot_zl01_timeout_seconds",
    },
    {
      capability_id = CAPABILITY_NAMESPACE .. "easyiotZl01TimeoutPin",
      command_name = "setTimeoutPin",
      argument_name = "pin",
      mapping_name = "easyiot_zl01_timeout_pin",
    },
    {
      capability_id = CAPABILITY_NAMESPACE .. "easyiotZl01UnlockTimeout",
      command_name = "unlockWithTimeout",
      value = true,
      mapping_name = "easyiot_zl01_unlock_timeout",
    },
    {
      capability_id = CAPABILITY_NAMESPACE .. "easyiotZl01TempStartDecimal",
      command_name = "setTempStartDecimal",
      argument_name = "unixSeconds",
      mapping_name = "easyiot_zl01_temp_start",
    },
    {
      capability_id = CAPABILITY_NAMESPACE .. "easyiotZl01TempEndDecimal",
      command_name = "setTempEndDecimal",
      argument_name = "unixSeconds",
      mapping_name = "easyiot_zl01_temp_end",
    },
    {
      capability_id = CAPABILITY_NAMESPACE .. "easyiotZl01TempPin",
      command_name = "setTemporaryPin",
      argument_name = "pin",
      mapping_name = "easyiot_zl01_temp_pin",
    },
    {
      capability_id = CAPABILITY_NAMESPACE .. "easyiotZl01TempApply",
      command_name = "applyTemporaryPin",
      value = true,
      mapping_name = "easyiot_zl01_temp_apply",
    },
    {
      capability_id = CAPABILITY_NAMESPACE .. "easyiotZl01TempClearAll",
      command_name = "clearAllTemporaryPins",
      value = true,
      mapping_name = "easyiot_zl01_temp_clear_all",
    },
  },
}

local gms02 = {
  profile = "safety-occupancy-easyiot-24gms02",
  easyiot_tunnel_receiver = gms02_tunnel_receiver,
  zcl_clusters = {
    (function()
      local mapping = zcl.occupancy_sensing({
        name = "occupancy",
        emit = emit.occupancy(),
        data_type = data_types.Bitmap8,
        configure_reporting = false,
        read_on_configure = false,
        from_device = function(value)
          return type(value) == "number" and value % 2 == 1 or value == true
        end,
      })
      -- cluster_attribute intentionally copies only protocol metadata. Keep
      -- this explicit marker on the realized mapping as an audit invariant.
      mapping.configure_reporting = false
      mapping.read_on_configure = false
      return mapping
    end)(),
    command_mapping(CLUSTER_TUNNELING, "easyiot_24g_detection_range", gms02_detection_range_sender, {
      numeric_range = { minimum = 0.7, maximum = 10, step = 0.1 },
    }),
    zcl.cluster_attribute(CLUSTER_OCCUPANCY, 0xFE01, {
      name = "easyiot_24g_work_mode",
      emit = custom_emit("easyiot24gWorkMode"),
      from_device = function(value)
        return ({
          [1] = "pirOnly",
          [2] = "radarOnly",
          [3] = "pirRadarAnd",
          [4] = "occupied_first",
          [5] = "unoccupied_first",
        })[value]
      end,
      data_type = data_types.Enum8,
      write_type = data_types.Enum8,
      sender = gms02_work_mode_sender,
    }),
    zcl.cluster_attribute(CLUSTER_OCCUPANCY, 0x0011, {
      name = "easyiot_24g_pir_delay",
      emit = custom_emit("easyiot24gPirDelay"),
      data_type = data_types.Uint16,
      write_type = data_types.Uint16,
      numeric_range = { minimum = 0, maximum = 65534, step = 1 },
      sender = gms02_delay_sender(0x0011),
    }),
    zcl.cluster_attribute(CLUSTER_OCCUPANCY, 0x0020, {
      name = "easyiot_24g_ultrasonic_occupied_delay",
      emit = custom_emit("easyiot24gUltrasonicOccupiedDelay"),
      data_type = data_types.Uint16,
      write_type = data_types.Uint16,
      numeric_range = { minimum = 0, maximum = 65534, step = 1 },
      sender = gms02_delay_sender(0x0020),
    }),
    zcl.cluster_attribute(CLUSTER_OCCUPANCY, 0x0021, {
      name = "easyiot_24g_ultrasonic_unoccupied_delay",
      emit = custom_emit("easyiot24gUsUnoccupiedDelay"),
      data_type = data_types.Uint16,
      write_type = data_types.Uint16,
      numeric_range = { minimum = 0, maximum = 65534, step = 1 },
      sender = gms02_delay_sender(0x0021),
    }),
    command_mapping(
      CLUSTER_TUNNELING,
      "easyiot_24g_motion_coefficient",
      store_numeric(GMS02_MOTION_COEFFICIENT_FIELD),
      { numeric_range = { minimum = 10, maximum = 200, step = 1 } }
    ),
    command_mapping(
      CLUSTER_TUNNELING,
      "easyiot_24g_hold_coefficient",
      store_numeric(GMS02_HOLD_COEFFICIENT_FIELD),
      { numeric_range = { minimum = 10, maximum = 200, step = 1 } }
    ),
    command_mapping(
      CLUSTER_TUNNELING,
      "easyiot_24g_micro_coefficient",
      store_numeric(GMS02_MICRO_COEFFICIENT_FIELD),
      { numeric_range = { minimum = 10, maximum = 200, step = 1 } }
    ),
    command_mapping(CLUSTER_TUNNELING, "easyiot_24g_auto_calibration", gms02_calibration_sender),
  },
  capability_commands = {
    {
      capability_id = CAPABILITY_NAMESPACE .. "easyiot24gAutoCalibration",
      command_name = "startAutoCalibration",
      value = true,
      mapping_name = "easyiot_24g_auto_calibration",
    },
  },
}

register_device_definition(ir01, {
  device_helpers.create_fingerprint("easyiot", "ZB-IR01"),
})

register_device_definition(tts01, {
  device_helpers.create_fingerprint("easyiot", "ZB-TTS01"),
})

register_device_definition(rs485, {
  device_helpers.create_fingerprint("easyiot", "ZB-RS485"),
})

register_device_definition(rs232, {
  device_helpers.create_fingerprint("easyiot", "ZB-RS232"),
})

register_device_definition(zl01, {
  device_helpers.create_fingerprint("easyiot", "ZB-ZL01"),
})

register_device_definition(gms02, {
  device_helpers.create_fingerprint("easyiot", "ZB-24GMS02"),
})

return {
  id = "zcl.easyiot.absorption",
  registrations = device_definitions,
}
