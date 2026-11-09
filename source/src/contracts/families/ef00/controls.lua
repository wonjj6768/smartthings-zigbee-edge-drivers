local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local capabilities = require "st.capabilities"
local zcl = require "protocol.zcl"
local is_callable = require("runtime.capability_support").is_callable

local converter = tuya.converter

local device_definitions, register_device_definition = device_helpers.definition_registry()

local action_converter = converter.from_only(converter.lookup_value({
  [0] = "pushed",
  [1] = "double",
  [2] = "held",
}))

local on_off_enum_converter = converter.lookup_from_to({
  on = 1,
  off = 0,
})

local cube_action_converter = converter.from_only(converter.lookup_value({
  [false] = "pushed",
  [0] = "pushed",
}))

local function emit_button_action(_, value)
  local button = capabilities.button and capabilities.button.button or nil
  local event_builder = button and button[value] or nil
  if not is_callable(event_builder) then
    return nil
  end

  return event_builder({ state_change = true })
end

local function emit_sos_action(device, value)
  if value ~= "emergency" then
    return nil
  end

  local events = {}
  local button_event = emit_button_action(device, "pushed")
  if button_event ~= nil then
    events[#events + 1] = button_event
  end

  local security_action_event = emit.security_remote_action()(device, value)
  if security_action_event ~= nil then
    events[#events + 1] = security_action_event
  end

  return events
end

local scene_remote_2 = {
  profile = "buttons-button-2-battery",
  button_actions = { "pushed", "double", "held" },
  datapoints = {
    tuya.dp_enum(1, {
      name = "button_1_action",
      component = "main",
      converter = action_converter,
      emit = emit_button_action,
    }),
    tuya.dp_enum(2, {
      name = "button_2_action",
      component = "button2",
      converter = action_converter,
      emit = emit_button_action,
    }),
    tuya.dp_battery(10, { emit = emit.battery() }),
  },
  query_on_configure = true,
}

local scene_remote_6 = {
  profile = "buttons-button-6-battery",
  button_actions = { "pushed", "double", "held" },
  datapoints = {
    tuya.dp_enum(1, {
      name = "button_1_action",
      component = "main",
      converter = action_converter,
      emit = emit_button_action,
    }),
    tuya.dp_enum(2, {
      name = "button_2_action",
      component = "button2",
      converter = action_converter,
      emit = emit_button_action,
    }),
    tuya.dp_enum(3, {
      name = "button_3_action",
      component = "button3",
      converter = action_converter,
      emit = emit_button_action,
    }),
    tuya.dp_enum(4, {
      name = "button_4_action",
      component = "button4",
      converter = action_converter,
      emit = emit_button_action,
    }),
    tuya.dp_enum(5, {
      name = "button_5_action",
      component = "button5",
      converter = action_converter,
      emit = emit_button_action,
    }),
    tuya.dp_enum(6, {
      name = "button_6_action",
      component = "button6",
      converter = action_converter,
      emit = emit_button_action,
    }),
    tuya.dp_battery(10, { emit = emit.battery() }),
  },
  query_on_configure = true,
}

local scene_remote_18 = {
  profile = "buttons-button-18",
  button_actions = { "pushed" },
  datapoints = {
    tuya.dp_enum(1, { name = "button_1_action", component = "main", converter = converter.from_only(converter.lookup_value({ [0] = "pushed" })), emit = emit_button_action }),
    tuya.dp_enum(2, { name = "button_2_action", component = "button2", converter = converter.from_only(converter.lookup_value({ [0] = "pushed" })), emit = emit_button_action }),
    tuya.dp_enum(3, { name = "button_3_action", component = "button3", converter = converter.from_only(converter.lookup_value({ [0] = "pushed" })), emit = emit_button_action }),
    tuya.dp_enum(4, { name = "button_4_action", component = "button4", converter = converter.from_only(converter.lookup_value({ [0] = "pushed" })), emit = emit_button_action }),
    tuya.dp_enum(5, { name = "button_5_action", component = "button5", converter = converter.from_only(converter.lookup_value({ [0] = "pushed" })), emit = emit_button_action }),
    tuya.dp_enum(6, { name = "button_6_action", component = "button6", converter = converter.from_only(converter.lookup_value({ [0] = "pushed" })), emit = emit_button_action }),
    tuya.dp_enum(7, { name = "button_7_action", component = "button7", converter = converter.from_only(converter.lookup_value({ [0] = "pushed" })), emit = emit_button_action }),
    tuya.dp_enum(8, { name = "button_8_action", component = "button8", converter = converter.from_only(converter.lookup_value({ [0] = "pushed" })), emit = emit_button_action }),
    tuya.dp_enum(9, { name = "button_9_action", component = "button9", converter = converter.from_only(converter.lookup_value({ [0] = "pushed" })), emit = emit_button_action }),
    tuya.dp_enum(10, { name = "button_10_action", component = "button10", converter = converter.from_only(converter.lookup_value({ [0] = "pushed" })), emit = emit_button_action }),
    tuya.dp_enum(11, { name = "button_11_action", component = "button11", converter = converter.from_only(converter.lookup_value({ [0] = "pushed" })), emit = emit_button_action }),
    tuya.dp_enum(12, { name = "button_12_action", component = "button12", converter = converter.from_only(converter.lookup_value({ [0] = "pushed" })), emit = emit_button_action }),
    tuya.dp_enum(13, { name = "button_13_action", component = "button13", converter = converter.from_only(converter.lookup_value({ [0] = "pushed" })), emit = emit_button_action }),
    tuya.dp_enum(14, { name = "button_14_action", component = "button14", converter = converter.from_only(converter.lookup_value({ [0] = "pushed" })), emit = emit_button_action }),
    tuya.dp_enum(15, { name = "button_15_action", component = "button15", converter = converter.from_only(converter.lookup_value({ [0] = "pushed" })), emit = emit_button_action }),
    tuya.dp_enum(16, { name = "button_16_action", component = "button16", converter = converter.from_only(converter.lookup_value({ [0] = "pushed" })), emit = emit_button_action }),
    tuya.dp_enum(101, { name = "button_17_action", component = "button17", converter = converter.from_only(converter.lookup_value({ [0] = "pushed" })), emit = emit_button_action }),
    tuya.dp_enum(102, { name = "button_18_action", component = "button18", converter = converter.from_only(converter.lookup_value({ [0] = "pushed" })), emit = emit_button_action }),
  },
  query_on_configure = true,
}

local foria_scene_remote_4 = {
  profile = "buttons-button-4-foria-options",
  button_actions = { "pushed" },
  datapoints = {
    tuya.dp_enum(1, {
      name = "button_1_action",
      component = "main",
      converter = converter.from_only(converter.lookup_value({ [0] = "pushed" })),
      emit = emit_button_action,
    }),
    tuya.dp_enum(2, {
      name = "button_2_action",
      component = "button2",
      converter = converter.from_only(converter.lookup_value({ [0] = "pushed" })),
      emit = emit_button_action,
    }),
    tuya.dp_enum(3, {
      name = "button_3_action",
      component = "button3",
      converter = converter.from_only(converter.lookup_value({ [0] = "pushed" })),
      emit = emit_button_action,
    }),
    tuya.dp_enum(4, {
      name = "button_4_action",
      component = "button4",
      converter = converter.from_only(converter.lookup_value({ [0] = "pushed" })),
      emit = emit_button_action,
    }),
    tuya.dp_enum(0x69, {
      name = "foria_scene_backlight",
      converter = on_off_enum_converter,
      emit = emit.foriaSceneBacklight(),
    }),
    tuya.dp_enum(0x6A, {
      name = "foria_scene_illumination_detection",
      converter = on_off_enum_converter,
      emit = emit.foriaSceneIlluminationDetection(),
    }),
    tuya.dp_enum(0x6B, {
      name = "foria_scene_approach_detection",
      converter = on_off_enum_converter,
      emit = emit.foriaSceneApproachDetection(),
    }),
    tuya.dp_enum(0x6C, {
      name = "foria_scene_vibration",
      converter = on_off_enum_converter,
      emit = emit.foriaSceneVibration(),
    }),
  },
  query_on_configure = true,
}

local scene_knob_action_converter = converter.from_only(converter.constant("pushed"))
local scene_knob_4 = {
  profile = "buttons-button-4",
  button_actions = { "pushed" },
  datapoints = {
    tuya.dp_enum(1, { name = "button_1_action", component = "main", converter = scene_knob_action_converter, emit = emit_button_action }),
    tuya.dp_enum(2, { name = "button_2_action", component = "button2", converter = scene_knob_action_converter, emit = emit_button_action }),
    tuya.dp_enum(3, { name = "button_3_action", component = "button3", converter = scene_knob_action_converter, emit = emit_button_action }),
    tuya.dp_enum(4, { name = "button_4_action", component = "button4", converter = scene_knob_action_converter, emit = emit_button_action }),
    tuya.dp_raw(52, { name = "binding_confirmation" }),
    tuya.dp_raw(102, { name = "binding_config" }),
  },
  query_on_configure = false,
  time_start = "off",
}

local scene_cube_6 = {
  profile = "buttons-button-6-battery",
  button_actions = { "pushed" },
  datapoints = {
    tuya.dp_binary(1, { name = "side_1", component = "main", converter = cube_action_converter, emit = emit_button_action }),
    tuya.dp_binary(2, { name = "side_2", component = "button2", converter = cube_action_converter, emit = emit_button_action }),
    tuya.dp_binary(3, { name = "side_3", component = "button3", converter = cube_action_converter, emit = emit_button_action }),
    tuya.dp_binary(4, { name = "side_4", component = "button4", converter = cube_action_converter, emit = emit_button_action }),
    tuya.dp_binary(5, { name = "knock", component = "button5", converter = cube_action_converter, emit = emit_button_action }),
    tuya.dp_binary(6, { name = "shake", component = "button6", converter = cube_action_converter, emit = emit_button_action }),
    tuya.dp_battery(10, { emit = emit.battery() }),
  },
  query_on_configure = true,
}

local sos_remote = {
  profile = "security-remotes-sos-battery",
  button_actions = { "pushed" },
  datapoints = {
    tuya.dp_enum(23, {
      name = "security_remote_action",
      converter = converter.from_only(function()
        return "emergency"
      end),
      emit = emit_sos_action,
    }),
    tuya.dp_battery(3, { emit = emit.battery() }),
  },
  query_on_configure = true,
}

local zg101z_sos_remote = {
  profile = "security-remotes-sos-battery-low",
  button_actions = { "pushed" },
  datapoints = {
    tuya.dp_enum(26, {
      name = "sos_action",
      converter = converter.from_only(function()
        return "emergency"
      end),
      emit = emit_sos_action,
    }),
    tuya.dp_enum(29, {
      name = "emergency_action",
      converter = converter.from_only(function()
        return "emergency"
      end),
      emit = emit_sos_action,
    }),
  },
  zcl_clusters = {
    zcl.battery_low({ read_only = true, emit = function(_, low)
      return low and capabilities.batteryLevel.battery.critical() or capabilities.batteryLevel.battery.normal()
    end }),
  },
  query_on_configure = true,
}

register_device_definition(scene_remote_2, device_helpers.create_fingerprints("TS0021", {
  "_TZ3210_3ulg9kpo",
}))

register_device_definition(scene_remote_6, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_2m38mh6k",
}))

register_device_definition(scene_remote_18, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_dhke3p9w",
  "_TZE284_dhke3p9w",
}))

register_device_definition(foria_scene_remote_4, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_mfamvsdb",
}))

register_device_definition(scene_knob_4, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_nj7sfid2",
}))

register_device_definition(scene_cube_6, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_5ys44kzo",
}))

register_device_definition(sos_remote, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_2baujqot",
}))

register_device_definition(zg101z_sos_remote, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_nojsjtj2",
  "_TZE200_vrcfo4i0",
}))

local zrf01 = {
  profile = "controllers-zrf01",
  magic_packet = true, query_on_configure = false, named_datapoints = true,
  datapoints = {
    tuya.dp_binary(117, { name = "zrf01_learning_mode", emit = emit.zrf01LearningMode(),
      converter = converter.lookup_from_to({ on = true, off = false }) }),
    tuya.dp_binary(118, { name = "zrf01_packet_mode", emit = emit.zrf01PacketMode(),
      converter = converter.lookup_from_to({ on = true, off = false }) }),
    tuya.dp_illuminance(119, { name = "illuminance", read_only = true, emit = emit.illuminance() }),
  },
}
for slot, item in ipairs({
  { "zrf01_code_1", emit.zrf01Code1(), "zrf01_transmit_1", emit.zrf01Transmit1() },
  { "zrf01_code_2", emit.zrf01Code2(), "zrf01_transmit_2", emit.zrf01Transmit2() },
  { "zrf01_code_3", emit.zrf01Code3(), "zrf01_transmit_3", emit.zrf01Transmit3() },
  { "zrf01_code_4", emit.zrf01Code4(), "zrf01_transmit_4", emit.zrf01Transmit4() },
  { "zrf01_code_5", emit.zrf01Code5(), "zrf01_transmit_5", emit.zrf01Transmit5() },
  { "zrf01_code_6", emit.zrf01Code6(), "zrf01_transmit_6", emit.zrf01Transmit6() },
  { "zrf01_code_7", emit.zrf01Code7(), "zrf01_transmit_7", emit.zrf01Transmit7() },
  { "zrf01_code_8", emit.zrf01Code8(), "zrf01_transmit_8", emit.zrf01Transmit8() },
}) do
  zrf01.datapoints[#zrf01.datapoints + 1] = tuya.dp_enum(100 + slot, {
    name = item[1], emit = item[2], converter = converter.lookup_from_to({ Learn = 0, Delete = 2, Saved = 1 }),
  })
  zrf01.datapoints[#zrf01.datapoints + 1] = tuya.dp_enum(108 + slot, {
    name = item[3], emit = item[4], converter = converter.lookup_from_to({ Transmit = 0 }),
    write_only = true, suppress_optimistic_state = true,
  })
end
register_device_definition(zrf01, device_helpers.create_fingerprints("TS0601", { "_TZE284_tdg4ckyh" }))

-- ZCL REPORTING CAPABILITIES BEGIN
zcl.attach_reporting_capabilities(device_definitions, {
  {8, "rpt-til"},
})
-- ZCL REPORTING CAPABILITIES END

return {
  id = "ef00.controls",
  registrations = device_definitions,
}
