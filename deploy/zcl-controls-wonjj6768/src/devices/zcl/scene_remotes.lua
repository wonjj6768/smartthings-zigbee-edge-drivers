local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local emit = require "emitters"
local device_definitions, register_device_definition = device_helpers.definition_registry()
local function battery_percent_from_voltage(voltage)
if type(voltage) ~= "number" then
return voltage
end
local percent = math.floor((((voltage - 2.0) / 1.0) * 100) + 0.5)
if percent < 0 then
return 0
end
if percent > 100 then
return 100
end
return percent
end
local scene_remote_4 = {
profile = "buttons-button-4-battery-remote-action",
button_actions = { "pushed" },
advanced_remote = true,
button_count = 4,
tuya_action_map = {
[1] = "scene_1",
[2] = "scene_2",
[3] = "scene_3",
[4] = "scene_4",
},
tuya_action_components = {
[1] = "main",
[2] = "button2",
[3] = "button3",
[4] = "button4",
},
tuya_action_button_events = {
[1] = "pushed",
[2] = "pushed",
[3] = "pushed",
[4] = "pushed",
},
zcl_clusters = {
zcl.cluster_attribute(zcl.CLUSTER_POWER_CONFIGURATION, zcl.ATTR_BATTERY_VOLTAGE, {
name = "battery",
endpoint = 1,
emit = emit.battery(),
scale = 10,
from_device = battery_percent_from_voltage,
read_on_configure = true,
}),
},
}
register_device_definition(scene_remote_4, device_helpers.create_fingerprints("TS1002", {
"_TZ3000_etufnltx",
"_TZ3000_xwh1e22x",
"_TZ3000_zwszqdpy",
}))
register_device_definition(scene_remote_4, {
device_helpers.create_fingerprint("Candeo", "C-ZB-SR5BR"),
device_helpers.create_fingerprint("HEIMAN", "SceneSwitch-EM-3.0"),
device_helpers.create_fingerprint("MLI", "Remote Control"),
device_helpers.create_fingerprint("Sunricher", "TERNCY-DC01"),
})
return device_definitions
