-- Wave18 Immax 07505L and DAEWOO WKE502Z source-only keypad candidates.
-- Frozen Zigbee2MQTT v26.99.0:
--   src/devices/immax.ts:405-442
--   src/devices/daewoo.ts:8-179

local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local capabilities = require "st.capabilities"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local DAEWOO_ACK_FRAME_FIELD = "__wave18_daewoo_ack_frame"

local function custom(capability_id)
  return assert(emit[capability_id], "missing Wave18 keypad emitter: " .. capability_id)()
end

local function custom_action(capability_id)
  local emitter = custom(capability_id)
  return function(...)
    local event = emitter(...)
    if event ~= nil then event.state_change = true end
    return event
  end
end

local function text_value(value)
  if type(value) == "string" then
    return value
  end
  if type(value) == "number" then
    return tostring(value)
  end
  return nil
end

local function emit_component(device, component_id, event)
  if event ~= nil then
    device:emit_component_event({ id = component_id }, event)
  end
end

local function local_iso_timestamp()
  local value = os.date("%Y-%m-%dT%H:%M:%S.000%z")
  if value:match("[+-]%d%d%d%d$") then
    return value:sub(1, -3) .. ":" .. value:sub(-2)
  end
  return value
end

local immax_action_emit = custom_action("immaxKeypadAction")

local immax = {
  profile = "controls-wave18-immax-07505l",
  package_group = "wave18-keypad",
  transport_classification = "EF00_DP",
  z2m_converter_source = "meta.tuyaDatapoints",
  wire_cluster = "manuSpecificTuya",
  magic_packet = true,
  query_on_configure = false,
  time_start = "off",
  datapoints = {
    tuya.dp_numeric(3, {
      name = "battery", read_only = true, transaction = 1,
      emit = emit.battery(),
    }),
    -- valueConverter.trueFalse1 is deliberately numeric-1 strict. The frozen
    -- declaration does not constrain whether the incoming number is VALUE,
    -- ENUM, or BITMAP, so the RX mapping remains datatype-agnostic.
    tuya.dp_raw(24, {
      name = "tamper", read_only = true, transaction = 1,
      converter = tuya.converter.from_only(function(value) return value == 1 end),
      emit = emit.tamper(),
    }),
    tuya.dp_raw(26, {
      name = "immax_keypad_action", read_only = true, transaction = 1,
      converter = tuya.converter.from_only(tuya.converter.constant("disarm")),
      emit = immax_action_emit,
    }),
    tuya.dp_raw(27, {
      name = "immax_keypad_action", read_only = true, transaction = 1,
      converter = tuya.converter.from_only(tuya.converter.constant("arm_away")),
      emit = immax_action_emit,
    }),
    tuya.dp_raw(28, {
      name = "immax_keypad_action", read_only = true, transaction = 1,
      converter = tuya.converter.from_only(tuya.converter.constant("arm_home")),
      emit = immax_action_emit,
    }),
    tuya.dp_raw(29, {
      name = "immax_keypad_action", read_only = true, transaction = 1,
      converter = tuya.converter.from_only(tuya.converter.constant("sos")),
      emit = immax_action_emit,
    }),
    tuya.dp_string(108, {
      name = "immax_keypad_admin_code", read_only = true, transaction = 1,
      converter = tuya.converter.from_only(text_value), emit = custom("immaxKeypadAdminCode"),
    }),
    tuya.dp_string(109, {
      name = "immax_keypad_last_added_user_code", read_only = true, transaction = 1,
      converter = tuya.converter.from_only(text_value), emit = custom("immaxKeypadLastAddedUserCode"),
    }),
    tuya.dp_numeric(103, {
      name = "immax_keypad_arm_delay_time", transaction = 1,
      emit = custom("immaxKeypadArmDelayTime"),
    }),
    tuya.dp_binary(104, {
      name = "immax_keypad_beep_sound_enabled", transaction = 1,
      converter = tuya.converter.lookup_from_to({ ON = true, OFF = false }),
      emit = custom("immaxKeypadBeepSoundEnabled"),
    }),
    tuya.dp_binary(105, {
      name = "immax_keypad_quick_home_enabled", transaction = 1,
      converter = tuya.converter.lookup_from_to({ ON = true, OFF = false }),
      emit = custom("immaxKeypadQuickHomeEnabled"),
    }),
    tuya.dp_binary(106, {
      name = "immax_keypad_quick_disarm_enabled", transaction = 1,
      converter = tuya.converter.lookup_from_to({ ON = true, OFF = false }),
      emit = custom("immaxKeypadQuickDisarmEnabled"),
    }),
    tuya.dp_binary(107, {
      name = "immax_keypad_quick_arm_enabled", transaction = 1,
      converter = tuya.converter.lookup_from_to({ ON = true, OFF = false }),
      emit = custom("immaxKeypadQuickArmEnabled"),
    }),
    tuya.dp_binary(111, {
      name = "immax_keypad_arm_delay_beep_sound", transaction = 1,
      converter = tuya.converter.lookup_from_to({ ON = true, OFF = false }),
      emit = custom("immaxKeypadArmDelayBeepSound"),
    }),
    tuya.dp_string(112, {
      name = "immax_keypad_user_id", read_only = true, transaction = 1,
      converter = tuya.converter.from_only(text_value), emit = custom("immaxKeypadUserId"),
    }),
  },
}

register_device_definition(immax, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_moycceze",
  "_TZE200_n9clpsht",
  "_TZE200_nyvavzbj",
}))

local daewoo_emit = {
  action = custom_action("daewooWkeAction"),
  arm_mode = custom("daewooWkeArmMode"),
  armed = custom("daewooWkeArmed"),
  user_id = custom("daewooWkeUserId"),
  user_last_seen = custom("daewooWkeUserLastSeen"),
  last_added_user_code = custom("daewooWkeLastAddedUserCode"),
  admin_code = custom("daewooWkeAdminCode"),
  arm_delay_time = custom("daewooWkeArmDelayTime"),
}

local function daewoo_emit_timestamp(device)
  emit_component(device, "main", daewoo_emit.user_last_seen(device, local_iso_timestamp()))
end

local function acknowledge_arm_frame(device, mapping_context)
  local frame = mapping_context and mapping_context.frame or nil
  if frame ~= nil and device:get_field(DAEWOO_ACK_FRAME_FIELD) == frame then
    return
  end
  if frame ~= nil then
    device:set_field(DAEWOO_ACK_FRAME_FIELD, frame, { persist = false })
  end
  tuya.send_datapoint(device, 23, tuya.DP_TYPE_BOOL, true, tuya.SET_DATA, false, 1)
end

local function daewoo_action_handler(action)
  return function(device, _, _, mapping_context)
    if action == "arm_away" or action == "arm_home" then
      acknowledge_arm_frame(device, mapping_context)
      emit_component(device, "main", daewoo_emit.armed(device, "true"))
    elseif action == "sos" then
      emit_component(device, "main", capabilities.panicAlarm.panicAlarm.panic())
    elseif action == "disarm" then
      emit_component(device, "main", capabilities.panicAlarm.panicAlarm.clear())
    end
    daewoo_emit_timestamp(device)
  end
end

local function daewoo_user_handler(device)
  daewoo_emit_timestamp(device)
end

local DAEWOO_VOLATILE_COMPONENTS = {
  { 104, "concertmirror08464.daewooWkeBeepSoundEnabled", "beepSoundEnabled" },
  { 105, "concertmirror08464.daewooWkeQuickHomeEnabled", "quickHomeEnabled" },
  { 106, "concertmirror08464.daewooWkeQuickDisarmEnabled", "quickDisarmEnabled" },
  { 107, "concertmirror08464.daewooWkeQuickArmEnabled", "quickArmEnabled" },
  { 110, "concertmirror08464.daewooWkeQuickSosEnabled", "quickSosEnabled" },
}

local function daewoo_announce(device)
  tuya.send_datapoint(device, 101, tuya.DP_TYPE_BOOL, true, tuya.SET_DATA, false, 1)
  for _, row in ipairs(DAEWOO_VOLATILE_COMPONENTS) do
    local state = device:get_latest_state("main", row[2], row[3])
    if state == "ON" or state == "OFF" then
      tuya.send_datapoint(device, row[1], tuya.DP_TYPE_BOOL, state == "ON", tuya.SET_DATA, false, 1)
    end
  end
  return true
end

local function daewoo_configure(_, device)
  -- Frozen definition configure runs before the tuyaBase extension configure:
  -- explicit magic -> hub-mode BOOL -> extension magic.
  tuya.send_magic_packet(device)
  tuya.send_datapoint(device, 101, tuya.DP_TYPE_BOOL, true, tuya.SET_DATA, false, 1)
end

local daewoo = {
  profile = "controls-wave18-daewoo-wke502z",
  package_group = "wave18-keypad",
  transport_classification = "EF00_DP_ACK_ANNOUNCE_RESTORE",
  z2m_converter_source = "meta.tuyaDatapoints + local fzAck + configure + onEvent",
  wire_cluster = "manuSpecificTuya",
  magic_packet = true,
  query_on_configure = false,
  time_start = "off",
  configure = daewoo_configure,
  announce_handler = daewoo_announce,
  datapoints = {
    -- Frozen rows split DP23 by direction: RX reports armed, TX writes VALUE
    -- 1/0 even though the physical field is described as a bool.
    tuya.dp_numeric(23, {
      name = "daewoo_wke_armed_report", read_only = true, transaction = 1,
      converter = tuya.converter.from_only(function(value)
        return (value == true or value == 1) and "true" or "false"
      end),
      emit = daewoo_emit.armed,
    }),
    tuya.dp_numeric(23, {
      name = "daewoo_wke_armed", write_only = true, transaction = 1,
      converter = tuya.converter.to_only(function(value) return value == "true" and 1 or 0 end),
    }),
    tuya.dp_numeric(3, {
      name = "battery", read_only = true, transaction = 1, emit = emit.battery(),
    }),
    tuya.dp_raw(24, {
      name = "tamper", read_only = true, transaction = 1,
      converter = tuya.converter.from_only(function(value) return value == true or value == 1 end),
      emit = emit.tamper(),
    }),
    tuya.dp_enum(25, {
      name = "daewoo_wke_arm_mode", read_only = true, transaction = 1,
      converter = tuya.converter.from_only(function(value) return tostring(value) end),
      emit = daewoo_emit.arm_mode,
    }),
    tuya.dp_raw(26, {
      name = "daewoo_wke_action", read_only = true, transaction = 1,
      converter = tuya.converter.from_only(tuya.converter.constant("disarm")),
      handler = daewoo_action_handler("disarm"), emit = daewoo_emit.action,
    }),
    tuya.dp_raw(27, {
      name = "daewoo_wke_action", read_only = true, transaction = 1,
      converter = tuya.converter.from_only(tuya.converter.constant("arm_away")),
      handler = daewoo_action_handler("arm_away"), emit = daewoo_emit.action,
    }),
    tuya.dp_raw(28, {
      name = "daewoo_wke_action", read_only = true, transaction = 1,
      converter = tuya.converter.from_only(tuya.converter.constant("arm_home")),
      handler = daewoo_action_handler("arm_home"), emit = daewoo_emit.action,
    }),
    tuya.dp_raw(29, {
      name = "daewoo_wke_action", read_only = true, transaction = 1,
      converter = tuya.converter.from_only(tuya.converter.constant("sos")),
      handler = daewoo_action_handler("sos"), emit = daewoo_emit.action,
    }),
    tuya.dp_numeric(103, {
      name = "daewoo_wke_arm_delay_time", transaction = 1,
      emit = daewoo_emit.arm_delay_time,
    }),
    tuya.dp_binary(104, {
      name = "daewoo_wke_beep_sound_enabled", transaction = 1,
      converter = tuya.converter.lookup_from_to({ ON = true, OFF = false }),
      emit = custom("daewooWkeBeepSoundEnabled"),
    }),
    tuya.dp_binary(105, {
      name = "daewoo_wke_quick_home_enabled", transaction = 1,
      converter = tuya.converter.lookup_from_to({ ON = true, OFF = false }),
      emit = custom("daewooWkeQuickHomeEnabled"),
    }),
    tuya.dp_binary(106, {
      name = "daewoo_wke_quick_disarm_enabled", transaction = 1,
      converter = tuya.converter.lookup_from_to({ ON = true, OFF = false }),
      emit = custom("daewooWkeQuickDisarmEnabled"),
    }),
    tuya.dp_binary(107, {
      name = "daewoo_wke_quick_arm_enabled", transaction = 1,
      converter = tuya.converter.lookup_from_to({ ON = true, OFF = false }),
      emit = custom("daewooWkeQuickArmEnabled"),
    }),
    tuya.dp_string(108, {
      name = "daewoo_wke_admin_code", transaction = 1,
      converter = tuya.converter.from_to(text_value, function(value) return value end),
      emit = daewoo_emit.admin_code,
    }),
    tuya.dp_string(109, {
      name = "daewoo_wke_last_added_user_code", read_only = true, transaction = 1,
      converter = tuya.converter.from_only(text_value), emit = daewoo_emit.last_added_user_code,
    }),
    tuya.dp_binary(110, {
      name = "daewoo_wke_quick_sos_enabled", transaction = 1,
      converter = tuya.converter.lookup_from_to({ ON = true, OFF = false }),
      emit = custom("daewooWkeQuickSosEnabled"),
    }),
    tuya.dp_binary(111, {
      name = "daewoo_wke_arm_delay_beep_sound", transaction = 1,
      converter = tuya.converter.lookup_from_to({ ON = true, OFF = false }),
      emit = custom("daewooWkeArmDelayBeepSound"),
    }),
    tuya.dp_numeric(112, {
      name = "daewoo_wke_user_id", read_only = true, transaction = 1,
      converter = tuya.converter.from_only(function(value) return tostring(value) end),
      handler = daewoo_user_handler, emit = daewoo_emit.user_id,
    }),
    tuya.dp_binary(101, {
      name = "daewoo_hub_mode", write_only = true, transaction = 1,
    }),
  },
}

register_device_definition(daewoo, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_rt5dklro",
}))

return {
  id = "ef00.controls.wave18_keypads",
  registrations = device_definitions,
}
