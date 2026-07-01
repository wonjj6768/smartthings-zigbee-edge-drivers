local tuya = require "tuya_common"
local emit = require "emitters"
local ef00_helpers = require "devices.ef00.helpers"
local device_definitions = require "devices.ef00.motion.pir"
local lincukoo_szlm04u = {
datapoints = {
tuya.dp_occupancy(1, { emit = emit.motion() }),
tuya.dp_illuminance(101, { emit = emit.illuminance() }),
tuya.dp_battery(4, { emit = emit.battery() }),
tuya.dp_on_off(102, { name = "usb_power" }),     -- profile 미포함
tuya.dp_on_off(103, { name = "switch" }),        -- profile 미포함
tuya.dp_fading_time(104, { name = "fading_time" }), -- profile 미포함, Z2M 5..300s
},
query_on_configure = true,
fingerprints = ef00_helpers.ts0601_fingerprints({
"_TZE284_9ovska9w",
"_TZE284_bquwrqh1",
}),
}
device_definitions[#device_definitions + 1] = lincukoo_szlm04u
return device_definitions
