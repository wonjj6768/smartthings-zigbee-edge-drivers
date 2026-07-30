local zcl = require "zcl_common"
local emit = require "emitters"
local device_helpers = require "devices.shared.helpers"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local CLUSTER_TUNNELING = 0x0704
local COMMAND_TRANSFER_DATA_TO_SERVER = 0x02
local COMMAND_TRANSFER_DATA_TO_CLIENT = 0x01
local SP1000_STATUS_ATTRIBUTE = 0xFFF0

local function sp1000_play_voice_sender(device, _, value, context)
  value = math.floor(tonumber(value))
  local payload = string.char(
    0x01, 0x00,
    0x01, 0x00, 0x02, 0x21,
    value % 0x100, math.floor(value / 0x100) % 0x100
  )
  return zcl.send_raw_cluster_command(
    device,
    CLUSTER_TUNNELING,
    COMMAND_TRANSFER_DATA_TO_SERVER,
    payload,
    context.endpoint or 1
  )
end

local function sp1000_volume_sender(device, _, value, context)
  value = math.floor(tonumber(value))
  local payload = string.char(
    0x01, 0x00,
    0x02, 0x00, 0x01, 0x20,
    value % 0x100
  )
  return zcl.send_raw_cluster_command(
    device,
    CLUSTER_TUNNELING,
    COMMAND_TRANSFER_DATA_TO_SERVER,
    payload,
    context.endpoint or 1
  )
end

local function sp1000_status_extractor(zb_rx)
  local body_bytes = zb_rx and zb_rx.body and zb_rx.body.zcl_body and zb_rx.body.zcl_body.body_bytes or nil
  if type(body_bytes) ~= "string" or #body_bytes < 7 then
    return nil
  end

  if string.byte(body_bytes, 3) ~= 0x80 or string.byte(body_bytes, 4) ~= 0x00 then
    return nil
  end

  return tostring(string.byte(body_bytes, 7))
end

local sp1000 = {
  profile = "controllers-easyiot-sp1000",
  zcl_clusters = {
    zcl.cluster_attribute(CLUSTER_TUNNELING, nil, {
      name = "easyiot_sp1000_play_voice",
      write_only = true,
      numeric_range = { minimum = 1, maximum = 999, step = 1 },
      sender = sp1000_play_voice_sender,
    }),
    zcl.cluster_attribute(CLUSTER_TUNNELING, nil, {
      name = "easyiot_sp1000_volume",
      write_only = true,
      numeric_range = { minimum = 1, maximum = 30, step = 1 },
      sender = sp1000_volume_sender,
    }),
    zcl.cluster_attribute(CLUSTER_TUNNELING, SP1000_STATUS_ATTRIBUTE, {
      name = "easyiot_sp1000_status",
      read_only = true,
      command_id = COMMAND_TRANSFER_DATA_TO_CLIENT,
      command_extractor = sp1000_status_extractor,
      emit = emit.easyiotSp1000Status(),
    }),
  },
}

local switch_4 = {
  profile = "switches-switch-4",
  zcl_clusters = zcl.multi_switch(4),
}

local switch_8 = {
  profile = "switches-switch-8",
  zcl_clusters = zcl.multi_switch(8),
}

register_device_definition(sp1000, {
  device_helpers.create_fingerprint("easyiot", "ZB-SP1000"),
})

register_device_definition(switch_4, {
  device_helpers.create_fingerprint("easyiot", "ZB-PSW04"),
})

register_device_definition(switch_8, {
  device_helpers.create_fingerprint("easyiot", "ZB-SW08"),
})

return device_definitions
