local tuya = require "tuya_common"
local emit = require "emitters"
local device_helpers = require "devices.shared.helpers"
local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()
local on_off = converter.lookup_from_to({ off = false, on = true })
local indicator_status = converter.lookup_from_to({ off = 0, on_off_status = 1, switch_position = 2 })
local color = converter.lookup_from_to({
red = 0, blue = 1, green = 2, white = 3, yellow = 4,
magenta = 5, cyan = 6, warm_white = 7, warm_yellow = 8,
})
local relay_status = converter.lookup_from_to({ power_off = 0, power_on = 1, restart_memory = 2 })
local radar_config = converter.lookup_from_to({ none = 0, ["10s"] = 1, ["20s"] = 2, ["30s"] = 3, ["45s"] = 4, ["60s"] = 5 })
local switch_name = converter.from_to(
function(value)
if type(value) ~= "string" then return nil end
return value:gsub("%z+$", "")
end,
function(value)
if type(value) ~= "string" then return nil end
return value:sub(1, 12)
end
)
local zms206us4 = {
profile = "switches-screen-zms206us4",
time_start = "1970",
tuya.dp_on_off(13, { name = "switch", component = "main", emit = emit.switch() }),
tuya.dp_on_off(1, { name = "switch", component = "switch1", emit = emit.switch() }),
tuya.dp_on_off(2, { name = "switch", component = "switch2", emit = emit.switch() }),
tuya.dp_on_off(3, { name = "switch", component = "switch3", emit = emit.switch() }),
tuya.dp_on_off(4, { name = "switch", component = "switch4", emit = emit.switch() }),
tuya.dp_countdown(7, { name = "zms206_countdown", component = "switch1", emit = emit.zmsFourCountdown() }),
tuya.dp_countdown(8, { name = "zms206_countdown", component = "switch2", emit = emit.zmsFourCountdown() }),
tuya.dp_countdown(9, { name = "zms206_countdown", component = "switch3", emit = emit.zmsFourCountdown() }),
tuya.dp_countdown(10, { name = "zms206_countdown", component = "switch4", emit = emit.zmsFourCountdown() }),
tuya.dp_enum(15, { name = "zms206_indicator_status", emit = emit.zmsFourIndicatorStatus(), converter = indicator_status }),
tuya.dp_binary(16, { name = "zms206_backlight_mode", emit = emit.zmsFourBacklightMode(), converter = on_off }),
tuya.dp_enum(19, { name = "zms206_delay_off_color", emit = emit.zmsFourDelayOffColor(), converter = color }),
tuya.dp_enum(29, { name = "zms206_relay_status", component = "switch1", emit = emit.zmsFourRelayStatus(), converter = relay_status }),
tuya.dp_enum(30, { name = "zms206_relay_status", component = "switch2", emit = emit.zmsFourRelayStatus(), converter = relay_status }),
tuya.dp_enum(31, { name = "zms206_relay_status", component = "switch3", emit = emit.zmsFourRelayStatus(), converter = relay_status }),
tuya.dp_enum(32, { name = "zms206_relay_status", component = "switch4", emit = emit.zmsFourRelayStatus(), converter = relay_status }),
tuya.dp_binary(101, { name = "zms206_child_lock", emit = emit.zmsFourChildLock(), converter = on_off }),
tuya.dp_numeric(102, { name = "zms206_backlight_brightness", emit = emit.zmsFourBacklightBrightness() }),
tuya.dp_enum(103, { name = "zms206_switch_color_on", emit = emit.zmsFourSwitchColorOn(), converter = color }),
tuya.dp_enum(104, { name = "zms206_switch_color_off", emit = emit.zmsFourSwitchColorOff(), converter = color }),
tuya.dp_raw(105, { name = "zms206_switch_name", component = "switch1", emit = emit.zmsFourSwitchName(), converter = switch_name }),
tuya.dp_raw(106, { name = "zms206_switch_name", component = "switch2", emit = emit.zmsFourSwitchName(), converter = switch_name }),
tuya.dp_raw(107, { name = "zms206_switch_name", component = "switch3", emit = emit.zmsFourSwitchName(), converter = switch_name }),
tuya.dp_raw(108, { name = "zms206_switch_name", component = "switch4", emit = emit.zmsFourSwitchName(), converter = switch_name }),
tuya.dp_enum(111, { name = "zms206_radar_config", emit = emit.zmsFourRadarConfig(), converter = radar_config }),
}
register_device_definition(zms206us4, device_helpers.create_fingerprints("TS0601", {
"_TZE204_08qc13ct",
"_TZE204_wwaeqnrf",
"_TZE204_xibaabmu",
"_TZE204_y4jqpry8",
"_TZE284_wwaeqnrf",
"_TZE284_xibaabmu",
"_TZE284_y4jqpry8",
"_TZE28C1000000_y4jqpry8",
}))
return device_definitions
