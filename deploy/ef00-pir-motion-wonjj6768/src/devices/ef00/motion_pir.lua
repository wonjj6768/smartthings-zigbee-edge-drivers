local tuya = require "tuya_common"
local emit = require "emitters"
local ef00_helpers = require "devices.ef00.helpers"
local converter = tuya.converter
local szlm04u_on_off_converter = converter.lookup_from_to({
ON = true,
OFF = false,
})
local ay204z_sensitivity_converter = converter.lookup_from_to({
low = 0,
medium = 1,
high = 2,
})
local ay204z_keep_time_converter = converter.lookup_from_to({
["10"] = 0,
["30"] = 1,
["60"] = 2,
["120"] = 3,
})
local device_definitions = require "devices.ef00.motion.pir"
local lincukoo_szlm04u = {
profile = "safety-motion-szlm04u-illuminance-battery",
datapoints = {
tuya.dp_occupancy(1, { emit = emit.motion(), read_only = true }),
tuya.dp_illuminance(101, { emit = emit.illuminance(), read_only = true }),
tuya.dp_battery(4, { emit = emit.battery(), read_only = true }),
tuya.dp_binary(102, {
name = "usb_power",
emit = emit.szlm04uUsbPower(),
converter = szlm04u_on_off_converter,
read_only = true,
}),
tuya.dp_binary(103, {
name = "switch",
emit = emit.szlm04uSensorSwitch(),
converter = szlm04u_on_off_converter,
read_only = true,
}),
tuya.dp_numeric(104, {
name = "fading_time",
emit = emit.szlm04uFadingTime(),
}),
},
query_on_configure = false,
fingerprints = ef00_helpers.ts0601_fingerprints({
"_TZE284_9ovska9w",
"_TZE284_bquwrqh1",
}),
}
device_definitions[#device_definitions + 1] = lincukoo_szlm04u
local aoyan_ay_204z = {
profile = "safety-motion-ay204z-battery",
datapoints = {
tuya.dp_occupancy(1, {
emit = emit.motion(),
converter = converter.true_false0(),
read_only = true,
}),
tuya.dp_battery(4, { emit = emit.battery(), read_only = true }),
tuya.dp_enum(9, {
name = "sensitivity",
emit = emit.ay204zSensitivity(),
converter = ay204z_sensitivity_converter,
}),
tuya.dp_enum(10, {
name = "keep_time",
emit = emit.ay204zKeepTime(),
converter = ay204z_keep_time_converter,
}),
},
query_on_configure = false,
fingerprints = {
{ manufacturer = "AOYAN", model = "AY-204Z" },
{ manufacturer = "AOYAN ", model = "AY-204Z" },
{ manufacturer = "AOYAN  ", model = "AY-204Z" },
},
}
device_definitions[#device_definitions + 1] = aoyan_ay_204z
return device_definitions
