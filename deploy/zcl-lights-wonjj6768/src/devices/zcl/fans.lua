local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local capabilities = require "st.capabilities"
local data_types = require "st.zigbee.data_types"
local device_definitions, register_device_definition = device_helpers.definition_registry()
local FAN_SPEED_ENDPOINTS = {
{ mode = "high", endpoint = 2 },
{ mode = "low", endpoint = 3 },
{ mode = "medium", endpoint = 4 },
}
local FAN_ENDPOINT_BY_MODE = {
high = 2,
low = 3,
medium = 4,
on = 4,
}
local function send_fan_endpoint(device, endpoint, on)
return zcl.send_raw_cluster_command(device, zcl.CLUSTER_ON_OFF, on and 0x01 or 0x00, "", endpoint)
end
local function send_fan_mode(device, mode)
local endpoint = FAN_ENDPOINT_BY_MODE[mode] or FAN_ENDPOINT_BY_MODE.medium
local handled = false
for _, item in ipairs(FAN_SPEED_ENDPOINTS) do
if item.endpoint ~= endpoint then
handled = send_fan_endpoint(device, item.endpoint, false) or handled
end
end
return send_fan_endpoint(device, endpoint, true) or handled
end
local function send_fan_power(device, _, value)
if value == false or value == "off" then
local handled = false
for _, item in ipairs(FAN_SPEED_ENDPOINTS) do
handled = send_fan_endpoint(device, item.endpoint, false) or handled
end
return handled
end
local latest = device:get_latest_state("main", capabilities.fanMode.ID, "fanMode")
return send_fan_mode(device, latest)
end
local function send_fan_mode_command(device, _, value)
return send_fan_mode(device, value)
end
local function emit_fan_speed(mode)
return function(device, value)
local component = { id = "main" }
if value == true or value == 1 then
device:emit_component_event(component, capabilities.switch.switch.on())
device:emit_component_event(component, capabilities.fanMode.fanMode(mode))
return
end
local latest = device:get_latest_state("main", capabilities.fanMode.ID, "fanMode")
if latest == mode then
device:emit_component_event(component, capabilities.switch.switch.off())
end
end
end
local function fan_speed_mapping(mode, endpoint, name, sender)
return zcl.cluster_attribute(zcl.CLUSTER_ON_OFF, zcl.ATTR_ON_OFF, {
name = name,
component = "main",
endpoint = endpoint,
handler = emit_fan_speed(mode),
sender = sender,
})
end
local ac_fan_controller = {
profile = "fans-switch-fan-mode",
zcl_clusters = {
zcl.switch({ endpoint = 1, component = "main" }),
zcl.fan_mode({ endpoint = 1 }),
zcl.cluster_attribute(zcl.CLUSTER_FAN_CONTROL, 0x0001, {
name = "fan_mode_sequence",
endpoint = 1,
write_only = true,
write_type = data_types.Enum8,
}),
},
zcl_initial_writes = {
{ name = "fan_mode_sequence", value = 0 },
},
}
register_device_definition(ac_fan_controller, device_helpers.create_fingerprints("TS0501", {
"_TZ3210_lzqq3u4r",
"_TZ3210_4whigl8i",
}))
local fan_light_switch = {
profile = "fans-fan-light-switch",
component_to_endpoint_map = {
main = 2,
light = 1,
},
endpoint_to_component_map = {
[1] = "light",
[2] = "main",
[3] = "main",
[4] = "main",
},
zcl_clusters = {
zcl.switch({ endpoint = 1, component = "light" }),
fan_speed_mapping("high", 2, "fan_mode", send_fan_mode_command),
zcl.cluster_attribute(zcl.CLUSTER_ON_OFF, zcl.ATTR_ON_OFF, {
name = "switch",
component = "main",
endpoint = 2,
write_only = true,
sender = send_fan_power,
}),
fan_speed_mapping("low", 3, "fan_speed_low"),
fan_speed_mapping("medium", 4, "fan_speed_medium"),
},
}
register_device_definition(fan_light_switch, device_helpers.create_fingerprints("TS0004", {
"_TZ3000_ncb6mkx8",
}))
return device_definitions
