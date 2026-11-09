-- Current Z2M 8e3b01c: Tuya TS0001 Fingerbot Plus.
-- The actuator itself uses the standard OnOff cluster. Tuya EF00 carries the
-- battery and the six settings that Z2M exposes. DP109 program data remains
-- internal because upstream does not expose a public contract for it.

local tuya = require "protocol.tuya"
local zcl = require "protocol.zcl"
local switch_defaults = require "st.zigbee.defaults.switch_defaults"
local log = require "log"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"

local converter = tuya.converter
local registrations, register_device_definition = device_helpers.definition_registry()

local function custom(capability_id)
  return assert(emit[capability_id], "missing Fingerbot Plus emitter: " .. capability_id)()
end

local actuator_switch_event = emit.switch()

local function send_actuator(device, _, value, context)
  local command = value and "on" or "off"
  log.info("Fingerbot SDK Lua " .. command .. "; native handling disabled")
  switch_defaults[command](nil, device, {
    component = context.component_id or "main",
    capability = "switch",
    command = command,
  }, false)
  return true
end

local actuator = zcl.switch({ read_only = false, emit = actuator_switch_event, sender = send_actuator })

local function handle_actuator_response(device, message)
  local address = message.address_header
  if address.profile.value ~= 0x0104 or address.cluster.value ~= 0x0006 or address.src_endpoint.value ~= 1 then
    return
  end
  local header = message.body.zcl_header
  local control = header.frame_ctrl
  if control:is_cluster_specific_set() or control:is_mfg_specific_set() or control:get_direction() ~= 1
      or header.cmd.value ~= 0x0B then
    return
  end
  switch_defaults.default_response_handler(nil, device, message, false)
end

local definition = {
  profile = "controls-tuya-fingerbot-plus",
  package_group = "finger-robot",
  -- Keep automatic configuration off for this battery actuator; explicit
  -- switch, refresh and EF00 setting commands retain their existing paths.
  magic_packet = false,
  zcl_configure = false,
  query_on_configure = false,
  refresh_state_query = false,
  initial_custom_state_query = false,
  time_start = "off",
  zigbee_message_handler = handle_actuator_response,
  runtime_start = function(device, preset)
    device:remove_configured_attribute(0x0006, 0x0000)
    device:remove_monitored_attribute(0x0006, 0x0000)
    if not device:supports_capability_by_id("concertmirror08464.tuyaFingerbotUpperLimitV2", "main") then
      device:try_update_metadata({ profile = preset.profile })
    end
  end,
  -- Z2M seq=1 is 01 00; the common transaction encoder uses big-endian.
  datapoints = {
    tuya.dp_enum(101, {
      name = "tuya_fingerbot_mode",
      command_id = tuya.SEND_DATA, transaction = 0x0100,
      converter = converter.lookup_from_to({ click = 0, switch = 1, program = 2 }),
      emit = custom("tuyaFingerbotMode"),
    }),
    tuya.dp_numeric(102, {
      name = "tuya_fingerbot_lower_limit",
      command_id = tuya.SEND_DATA, transaction = 0x0100,
      emit = custom("tuyaFingerbotLowerLimit"),
    }),
    tuya.dp_numeric(103, {
      name = "tuya_fingerbot_delay",
      command_id = tuya.SEND_DATA, transaction = 0x0100,
      emit = custom("tuyaFingerbotDelay"),
    }),
    tuya.dp_enum(104, {
      name = "tuya_fingerbot_reverse",
      command_id = tuya.SEND_DATA, transaction = 0x0100,
      converter = converter.lookup_from_to({ ON = 1, OFF = 0 }),
      emit = custom("tuyaFingerbotReverse"),
    }),
    tuya.dp_battery(105, {
      name = "battery",
      read_only = true,
      emit = emit.battery(),
    }),
    tuya.dp_numeric(106, {
      name = "tuya_fingerbot_upper_limit",
      command_id = tuya.SEND_DATA, transaction = 0x0100,
      emit = custom("tuyaFingerbotUpperLimitV2"),
    }),
    tuya.dp_binary(107, {
      name = "tuya_fingerbot_touch",
      command_id = tuya.SEND_DATA, transaction = 0x0100,
      converter = converter.lookup_from_to({ ON = true, OFF = false }),
      emit = custom("tuyaFingerbotTouch"),
    }),
  },
  zcl_clusters = {
    actuator,
  },
}

register_device_definition(definition, device_helpers.create_fingerprints("TS0001", {
  "_TZ3210_dse8ogfy",
  "_TZ3210_j4pdtz9v",
  "_TZ3210_7vgttna6",
  "_TZ3210_a04acm9s",
  "_TZ3210_cm9mbpr1",
}))

-- ZCL REPORTING CAPABILITIES BEGIN
zcl.attach_reporting_capabilities(registrations, {
  {1, "rpt-txr"},
})
-- ZCL REPORTING CAPABILITIES END

return {
  id = "ef00.controls.tuya_fingerbot_plus",
  registrations = registrations,
}
