local tuya = require "tuya_common"
local device_helpers = require "devices.shared.helpers"
local emit = require "emitters"
local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()
local bool_enum_converter = converter.from_only(converter.lookup_value({
[0] = false,
[1] = true,
}))
local warning_converter = converter.from_only(converter.lookup_value({
[0] = "none",
[1] = "low",
[2] = "high",
}))
local motion_vibration_illuminance = {
profile = "safety-motion-vibration-illuminance-battery",
datapoints = {
tuya.dp_enum(1, { name = "motion", emit = emit.motion(), converter = bool_enum_converter }),
tuya.dp_binary(3, { name = "vibration", emit = emit.acceleration() }),
tuya.dp_battery(4, { emit = emit.battery() }),
tuya.dp_numeric(6, { name = "vibration_sensitivity" }),
tuya.dp_illuminance(20, { emit = emit.illuminance() }),
tuya.dp_numeric(101, { name = "sampling_interval" }),
tuya.dp_illuminance(104, { name = "illuminance_v0" }),
tuya.dp_illuminance(105, { name = "illuminance_v1" }),
tuya.dp_numeric(106, { name = "illuminance_calibration", signed = true }),
tuya.dp_enum(107, { name = "illuminance_warning", converter = warning_converter }),
},
query_on_configure = true,
}
local contact_vibration = {
profile = "safety-vibration-battery",
datapoints = {
tuya.dp_binary(3, { name = "vibration", emit = emit.acceleration() }),
tuya.dp_battery(4, { emit = emit.battery() }),
tuya.dp_numeric(6, { name = "vibration_sensitivity" }),
tuya.dp_contact(7, { emit = emit.contact(), converter = converter.invert_bool_pair() }),
},
query_on_configure = true,
}
local vibration = {
profile = "safety-acceleration-battery",
datapoints = {
tuya.dp_binary(3, { name = "vibration", emit = emit.acceleration() }),
tuya.dp_battery(4, { emit = emit.battery() }),
tuya.dp_numeric(6, { name = "vibration_sensitivity" }),
},
query_on_configure = true,
}
register_device_definition(motion_vibration_illuminance, {
device_helpers.create_fingerprint("PIRIV01", "Excellux"),
})
register_device_definition(contact_vibration, {
device_helpers.create_fingerprint("CAT0001", "Excellux"),
})
register_device_definition(vibration, {
device_helpers.create_fingerprint("VABRATE", "Excellux"),
})
return device_definitions
