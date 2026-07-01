local capabilities = require "st.capabilities"
local tuya = require "tuya_common"
local emit = require "emitters"
local device_helpers = require "devices.shared.helpers"
local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()
local function emit_garage_door_contact(_, value)
if value then
return {
capabilities.contactSensor.contact.open(),
capabilities.doorControl.door.open(),
}
end
return {
capabilities.contactSensor.contact.closed(),
capabilities.doorControl.door.closed(),
}
end
local garage_door_opener = {
profile = "doors-garage-contact",
datapoints = {
tuya.dp_binary(1, { name = "door_control", write_only = true }),
tuya.dp_binary(3, {
name = "garage_door_contact",
converter = converter.invert_bool_pair(),
emit = emit_garage_door_contact,
}),
},
query_on_configure = true,
}
local garage_door_opener_countdown = {
profile = "doors-garage-contact-countdown",
datapoints = {
tuya.dp_binary(1, { name = "door_control", write_only = true }),
tuya.dp_numeric(2, { name = "countdown" }),             -- profile 미포함
tuya.dp_binary(3, {
name = "garage_door_contact",
converter = converter.invert_bool_pair(),
emit = emit_garage_door_contact,
}),
tuya.dp_numeric(4, { name = "run_time", emit = emit.garageRunTimeCountdownOpener120() }),
tuya.dp_numeric(5, { name = "open_alarm_time", emit = emit.garageOpenAlarmTimeOpenerDay() }),
tuya.dp_enum(12, {
name = "garage_status",
converter = converter.lookup_from_to({
open_time_alarm = 0,
run_time_alarm = 1,
normal = 2,
}),
emit = emit.garageStatusCountdownOpenerAlarm(),
}),
},
query_on_configure = true,
}
register_device_definition(garage_door_opener, device_helpers.create_fingerprints("TS0603", {
"_TZE608_c75zqghm",
"_TZE608_fmemczv1",
"_TZE608_xkr8gep3",
"_TZE608_lapuuoke",
}))
register_device_definition(garage_door_opener, {
device_helpers.create_fingerprint("_TZE200_wfxuhoea", "TS0601"),
device_helpers.create_fingerprint("_TZE204_wfxuhoea", "TS0601"),
device_helpers.create_fingerprint("LoraTap", "GDC311ZBQ1"),
})
register_device_definition(garage_door_opener_countdown, device_helpers.create_fingerprints("TS0601", {
"_TZE200_nklqjk62",
"_TZE204_nklqjk62",
"_TZE204_jktmrpoj",
"_TZE284_nklqjk62",
}))
register_device_definition(garage_door_opener_countdown, {
device_helpers.create_fingerprint("MatSee Plus", "PJ-ZGD01"),
device_helpers.create_fingerprint("Moes", "ZM-102-M"),
})
return device_definitions
