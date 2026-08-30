-- Frozen Zigbee2MQTT v26.99 Wave19 remote/controller candidates.

local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local capabilities = require "st.capabilities"

local converter = tuya.converter
local registrations, register_device_definition = device_helpers.definition_registry()

local function button_component(index)
  if index == 1 then
    return "main"
  end
  return "button" .. tostring(index)
end

local function emit_button_action(_, value)
  local button = capabilities.button and capabilities.button.button or nil
  local builder = button and button[value] or nil
  if type(builder) ~= "function" then
    return nil
  end
  return builder({ state_change = true })
end

local function constant_button_action(value)
  return converter.from_only(converter.constant(value))
end

local function enum(values)
  return converter.lookup_from_to(values)
end

local box_erc2201 = {
  profile = "controls-wave19-box-erc2201-z",
  button_actions = { "pushed" },
  named_datapoints = true,
  magic_packet = true,
  query_on_configure = false,
  time_start = "off",
  datapoints = {
    tuya.dp_on_off(0x13, {
      name = "switch", component = "main", transaction = 1, emit = emit.switch(),
    }),
    tuya.dp_enum(0x66, {
      name = "box_erc_record_rf", transaction = 1,
      converter = enum({ record = 0 }), emit = emit.boxErcRecordRf(),
    }),
    tuya.dp_enum(0x66, {
      name = "box_erc_clear_rf", transaction = 1,
      converter = enum({ clear = 1 }), emit = emit.boxErcClearRf(),
    }),
    tuya.dp_enum(0x67, {
      name = "box_erc_rf_status", transaction = 1, read_only = true,
      converter = enum({ ok = 0, error = 1 }), emit = emit.boxErcRfStatus(),
    }),
    tuya.dp_enum(0x68, {
      name = "box_erc_record_scene", transaction = 1,
      converter = enum({
        scene_1 = 0, scene_2 = 1, scene_3 = 2, scene_4 = 3, scene_5 = 4,
        scene_6 = 5, scene_7 = 6, scene_8 = 7, scene_9 = 8, scene_10 = 9,
      }),
      emit = emit.boxErcRecordScene(),
    }),
    tuya.dp_enum(0x68, {
      name = "box_erc_clear_scene", transaction = 1,
      converter = enum({
        scene_1 = 10, scene_2 = 11, scene_3 = 12, scene_4 = 13, scene_5 = 14,
        scene_6 = 15, scene_7 = 16, scene_8 = 17, scene_9 = 18, scene_10 = 19,
      }),
      emit = emit.boxErcClearScene(),
    }),
    tuya.dp_enum(0x69, {
      name = "box_erc_rf_scene_status", transaction = 1, read_only = true,
      converter = enum({ ok = 0, error = 1 }), emit = emit.boxErcRfSceneStatus(),
    }),
  },
}

for index = 1, 10 do
  box_erc2201.datapoints[#box_erc2201.datapoints + 1] = tuya.dp_enum(index, {
    name = "box_erc_scene_" .. tostring(index),
    component = button_component(index),
    transaction = 1,
    read_only = true,
    converter = constant_button_action("pushed"),
    emit = emit_button_action,
  })
end

register_device_definition(box_erc2201, {
  device_helpers.create_fingerprint("_TZE200_lhpnrfmy", "TS0601"),
})

local function build_qa_scene_switch(options)
  local datapoints = {}
  for index, dp in ipairs(options.switch_dps) do
    datapoints[#datapoints + 1] = tuya.dp_on_off(dp, {
      name = "switch", component = button_component(index),
      transaction = 1, emit = emit.switch(),
    })
  end
  for index, dp in ipairs(options.scene_dps) do
    datapoints[#datapoints + 1] = tuya.dp_enum(dp, {
      name = options.prefix .. "_scene_" .. tostring(index),
      component = button_component(index),
      transaction = 1,
      read_only = true,
      converter = constant_button_action("pushed"),
      emit = emit_button_action,
    })
  end
  datapoints[#datapoints + 1] = tuya.dp_numeric(101, {
    name = options.prefix .. "_backlight_brightness",
    component = "main",
    transaction = 1,
    emit = options.backlight_emitter,
  })

  return {
    profile = options.profile,
    button_actions = { "pushed" },
    named_datapoints = true,
    magic_packet = true,
    query_on_configure = false,
    time_start = "off",
    datapoints = datapoints,
  }
end

local qa_qat44z6 = build_qa_scene_switch({
  profile = "controls-wave19-qa-qat44z6",
  prefix = "qa_qat_six",
  switch_dps = { 24, 25, 26, 27, 28, 29 },
  scene_dps = { 7, 8, 9, 10, 11, 12 },
  backlight_emitter = emit.qaQatSixBacklight(),
})
register_device_definition(qa_qat44z6, {
  device_helpers.create_fingerprint("_TZE284_ms97nkyy", "TS0601"),
})

local qa_qat42z2b = build_qa_scene_switch({
  profile = "controls-wave19-qa-qat42z2b",
  prefix = "qa_qat_two",
  switch_dps = { 24, 25 },
  scene_dps = { 5, 6 },
  backlight_emitter = emit.qaQatTwoBacklight(),
})
register_device_definition(qa_qat42z2b, {
  device_helpers.create_fingerprint("_TZE284_1aqlsquf", "TS0601"),
})

local qa_qat42z3b = build_qa_scene_switch({
  profile = "controls-wave19-qa-qat42z3b",
  prefix = "qa_qat_three",
  switch_dps = { 24, 25, 26 },
  scene_dps = { 5, 6, 7 },
  backlight_emitter = emit.qaQatThreeBacklight(),
})
register_device_definition(qa_qat42z3b, {
  device_helpers.create_fingerprint("_TZE284_pgxndxp4", "TS0601"),
})

local tuya_presence_switch = {
  profile = "controls-wave19-tuya-presence-switch",
  named_datapoints = true,
  magic_packet = true,
  query_on_configure = false,
  time_start = "off",
  datapoints = {
    tuya.dp_on_off(1, {
      name = "switch", component = "main", transaction = 1, emit = emit.switch(),
    }),
    tuya.dp_numeric(7, {
      name = "tuya_ps_1_countdown", transaction = 1, emit = emit.tuyaPsOneCountdown(),
    }),
    tuya.dp_enum(14, {
      name = "tuya_ps_1_relay_status", transaction = 1,
      converter = enum({ off = 0, on = 1, memory = 2 }), emit = emit.tuyaPsOneRelayStatus(),
    }),
    tuya.dp_enum(15, {
      name = "tuya_ps_1_light_mode", transaction = 1,
      converter = enum({ relay = 0, none = 1, pos = 2 }), emit = emit.tuyaPsOneLightMode(),
    }),
    tuya.dp_presence(101, {
      datatype = tuya.DP_TYPE_ENUM,
      transaction = 1,
      converter = converter.true_false1(),
      emit = emit.presence(),
      read_only = true,
    }),
    tuya.dp_numeric(102, {
      name = "tuya_ps_1_delays_time", transaction = 1, emit = emit.tuyaPsOneDelaysTime(),
    }),
    tuya.dp_enum(103, {
      name = "tuya_ps_1_turn_on_light_for_person", transaction = 1,
      converter = enum({ none = 0, all = 1 }), emit = emit.tuyaPsOneTurnOnPerson(),
    }),
    tuya.dp_numeric(104, {
      name = "tuya_ps_1_sensitivity", transaction = 1, emit = emit.tuyaPsOneSensitivity(),
    }),
    tuya.dp_enum(105, {
      name = "tuya_ps_1_turn_off_light_for_person", transaction = 1,
      converter = enum({ none = 0, all = 1 }), emit = emit.tuyaPsOneTurnOffPerson(),
    }),
  },
}
register_device_definition(tuya_presence_switch, {
  device_helpers.create_fingerprint("_TZE28C1000000_jlbsptkl", "TS0601"),
})

local zemismart_action_lookup = {
  [0] = "pushed",
  [1] = "double",
  [2] = "held",
}

local function is_first_frame_datapoint(dp_info, context)
  local frame = type(context) == "table" and context.frame or nil
  local datapoints = type(frame) == "table" and frame.datapoints or nil
  return type(datapoints) ~= "table" or datapoints[1] == dp_info
end

local zemismart_action_converter = converter.from_only(function(value, _, dp_info, context)
  if not is_first_frame_datapoint(dp_info, context) then
    return nil
  end
  return zemismart_action_lookup[value]
end)

local zemismart_battery_converter = converter.from_only(function(value, _, dp_info, context)
  if not is_first_frame_datapoint(dp_info, context) then
    return nil
  end
  return value
end)

local zemismart_zm_rm02 = {
  profile = "controls-wave19-zemismart-zm-rm02",
  button_actions = { "pushed", "double", "held" },
  magic_packet = true,
  query_on_configure = false,
  time_start = "off",
  datapoints = {},
}
for index = 1, 6 do
  zemismart_zm_rm02.datapoints[#zemismart_zm_rm02.datapoints + 1] = tuya.dp_enum(index, {
    name = "zemismart_zm_rm02_button_" .. tostring(index),
    component = button_component(index),
    transaction = 1,
    read_only = true,
    converter = zemismart_action_converter,
    emit = emit_button_action,
  })
end
zemismart_zm_rm02.datapoints[#zemismart_zm_rm02.datapoints + 1] = tuya.dp_numeric(10, {
  name = "battery", transaction = 1, read_only = true,
  converter = zemismart_battery_converter, emit = emit.battery(),
})

register_device_definition(zemismart_zm_rm02, {
  device_helpers.create_fingerprint("_TZE200_zqtiam4u", "TS0601"),
})

return {
  id = "ef00.controls.wave19.remotes",
  registrations = registrations,
}
