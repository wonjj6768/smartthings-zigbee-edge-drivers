local tuya = require "tuya_common"
local emit = require "emitters"
local device_helpers = require "devices.shared.helpers"
local capabilities = require "st.capabilities"
local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()
local action_converter = converter.from_only(converter.lookup_value({
[0] = "pushed",
[1] = "double",
[2] = "held",
}))
local function emit_button_action(_, value)
local button = capabilities.button and capabilities.button.button or nil
local event_builder = button and button[value] or nil
if type(event_builder) ~= "function" then
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
profile = "buttons-button-4",
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
tuya.dp_enum(0x69, { name = "backlight" }),       -- profile 미포함
tuya.dp_enum(0x6A, { name = "illumination" }),    -- profile 미포함
tuya.dp_enum(0x6B, { name = "approach" }),        -- profile 미포함
tuya.dp_enum(0x6C, { name = "vibration" }),       -- profile 미포함
},
query_on_configure = true,
}
local scene_knob_4 = {
profile = "buttons-button-4",
button_actions = { "pushed", "double", "held" },
datapoints = {
tuya.dp_enum(1, { name = "button_1_action", component = "main", converter = action_converter, emit = emit_button_action }),
tuya.dp_enum(2, { name = "button_2_action", component = "button2", converter = action_converter, emit = emit_button_action }),
tuya.dp_enum(3, { name = "button_3_action", component = "button3", converter = action_converter, emit = emit_button_action }),
tuya.dp_enum(4, { name = "button_4_action", component = "button4", converter = action_converter, emit = emit_button_action }),
tuya.dp_raw(52, { name = "binding_confirmation" }),                  -- profile 미포함
tuya.dp_raw(102, { name = "binding_config" }),                       -- profile 미포함
},
query_on_configure = true,
}
local scene_cube_6 = {
profile = "buttons-button-6-battery",
button_actions = { "pushed" },
datapoints = {
tuya.dp_binary(1, { name = "side_1", component = "main", converter = converter.from_only(function() return "pushed" end), emit = emit_button_action }),
tuya.dp_binary(2, { name = "side_2", component = "button2", converter = converter.from_only(function() return "pushed" end), emit = emit_button_action }),
tuya.dp_binary(3, { name = "side_3", component = "button3", converter = converter.from_only(function() return "pushed" end), emit = emit_button_action }),
tuya.dp_binary(4, { name = "side_4", component = "button4", converter = converter.from_only(function() return "pushed" end), emit = emit_button_action }),
tuya.dp_binary(5, { name = "knock", component = "button5", converter = converter.from_only(function() return "pushed" end), emit = emit_button_action }),
tuya.dp_binary(6, { name = "shake", component = "button6", converter = converter.from_only(function() return "pushed" end), emit = emit_button_action }),
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
profile = "security-remotes-sos-battery",
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
query_on_configure = true,
}
register_device_definition(scene_remote_2, device_helpers.create_fingerprints("TS0021", {
"_TZ3210_3ulg9kpo",
}))
register_device_definition(scene_remote_6, device_helpers.create_fingerprints("TS0601", {
"_TZE200_2m38mh6k",
}))
register_device_definition(scene_remote_6, {
device_helpers.create_fingerprint("LoraTap", "SS9600ZB"),
})
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
return device_definitions
