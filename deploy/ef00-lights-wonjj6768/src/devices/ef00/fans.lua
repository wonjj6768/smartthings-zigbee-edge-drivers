local tuya = require "tuya_common"
local emit = require "emitters"
local device_helpers = require "devices.shared.helpers"
local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()
local function percent(value)
local n = tonumber(value)
if n == nil then return nil end
if n < 0 then return 0 end
if n > 100 then return 100 end
return math.floor(n + 0.5)
end
local three_speed_fan_mode = converter.lookup_from_to({
low = 0,
medium = 1,
high = 2,
on = 2,
})
local five_speed_fan_mode = converter.from_to(
function(value)
if value <= 1 then return "low" end
if value == 2 then return "medium" end
return "high"
end,
function(value)
if value == "low" then return 0 end
if value == "medium" then return 2 end
if value == "high" or value == "on" then return 4 end
return nil
end
)
local zero_based_five_speed = converter.from_to(
function(value)
local n = tonumber(value) or 0
if n <= 0 then return "low" end
if n == 1 then return "low" end
if n == 2 then return "medium" end
return "high"
end,
function(value)
if value == "low" then return 1 end
if value == "medium" then return 2 end
if value == "high" or value == "on" then return 4 end
return nil
end
)
local stepped_level = converter.from_to(
function(value)
if value <= 300 then return 20 end
if value <= 410 then return 40 end
if value <= 520 then return 60 end
if value <= 650 then return 80 end
return 100
end,
function(value)
local level = percent(value)
if level == nil then return nil end
if level <= 20 then return 300 end
if level <= 40 then return 410 end
if level <= 60 then return 520 end
if level <= 80 then return 650 end
return 1000
end
)
local coarse_light_level = converter.from_to(
function(value)
if value <= 300 then return 10 end
if value <= 410 then return 30 end
if value <= 520 then return 50 end
if value <= 650 then return 70 end
return 100
end,
function(value)
local level = percent(value)
if level == nil then return nil end
if level <= 10 then return 300 end
if level <= 30 then return 410 end
if level <= 50 then return 520 end
if level <= 70 then return 650 end
return 1000
end
)
local percentage_level = converter.from_to(percent, percent)
local fan_and_light_switch = {
profile = "fans-fan-light-switch",
tuya.dp_on_off(1, { name = "switch", component = "main", emit = emit.switch() }),
tuya.dp_fan_mode(101, { component = "main", emit = emit.fan_mode(), converter = three_speed_fan_mode }),
tuya.dp_power_on_behavior(11, {}),                                      -- profile 미포함
tuya.dp_on_off(5, { name = "switch", component = "light", emit = emit.switch() }),
}
local fan_switch_5_speed = {
profile = "fans-switch-fan-mode-ef00",
tuya.dp_on_off(1, { name = "switch", component = "main", emit = emit.switch() }),
tuya.dp_countdown(2, { name = "countdown" }),                           -- profile 미포함
tuya.dp_fan_mode(3, { component = "main", emit = emit.fan_mode(), converter = five_speed_fan_mode }),
tuya.dp_power_on_behavior(11, {}),                                      -- profile 미포함
}
register_device_definition(fan_switch_5_speed, device_helpers.create_fingerprints("TS0601", {
"_TZE200_r32ctezx",
"_TZE204_r32ctezx",
}))
register_device_definition(fan_and_light_switch, device_helpers.create_fingerprints("TS0601", {
"_TZE200_hmqzfqml",
"_TZE200_qanl25yu",
}))
register_device_definition(fan_and_light_switch, {
device_helpers.create_fingerprint("Liwokit", "Fan+Light-01"),
device_helpers.create_fingerprint("Lerlink", "T2-Z67/T2-W67"),
})
local fan_5_levels_and_light_switch = {
profile = "fans-fan-light-switch",
tuya.dp_on_off(1, { name = "switch", component = "main", emit = emit.switch() }),
tuya.dp_fan_mode(3, { component = "main", emit = emit.fan_mode(), converter = five_speed_fan_mode }),
tuya.dp_power_on_behavior(11, {}),                                      -- profile 미포함
tuya.dp_on_off(5, { name = "switch", component = "light", emit = emit.switch() }),
}
register_device_definition(fan_5_levels_and_light_switch, device_helpers.create_fingerprints("TS0601", {
"_TZE200_lawxy9e2",
"_TZE204_lawxy9e2",
}))
local fan_dimmer_and_light_switch = {
profile = "fans-fan-level-light-switch",
tuya.dp_on_off(1, { name = "switch", component = "main", emit = emit.switch() }),
tuya.dp_numeric(4, { name = "brightness", component = "main", emit = emit.level(), converter = percentage_level }),
tuya.dp_on_off(5, { name = "switch", component = "light", emit = emit.switch() }),
tuya.dp_power_on_behavior(11, {}),                                      -- profile 미포함
tuya.dp_indicator_mode(12, { name = "indicator_mode" }),                -- profile 미포함
tuya.dp_on_off(13, { name = "backlight" }),                             -- profile 미포함
tuya.dp_child_lock(104, { name = "child_lock" }),                       -- profile 미포함
tuya.dp_numeric(105, { name = "minimum_speed", converter = percentage_level }),
}
register_device_definition(fan_dimmer_and_light_switch, device_helpers.create_fingerprints("TS0601", {
"_TZE204_bql5khqx",
"_TZE204_2jnoy8dj",
}))
register_device_definition(fan_dimmer_and_light_switch, {
device_helpers.create_fingerprint("Coswall", "X99-G-kbFan-1g-ZG-LN-11"),
device_helpers.create_fingerprint("Zemismart", "ZN2S-RS1E-FL / ZN2S-US1U-FL"),
})
local fan_5_levels_and_light_5_levels = {
profile = "fans-fan-level-light-dimmer",
tuya.dp_on_off(1, { name = "switch", component = "main", emit = emit.switch() }),
tuya.dp_numeric(6, { name = "brightness", component = "main", emit = emit.level(), converter = stepped_level }),
tuya.dp_on_off(104, { name = "switch", component = "light", emit = emit.switch() }),
tuya.dp_numeric(105, { name = "brightness", component = "light", emit = emit.level(), converter = coarse_light_level }),
}
register_device_definition(fan_5_levels_and_light_5_levels, device_helpers.create_fingerprints("TS0601", {
"_TZE284_ikul00sx",
}))
local fan_ceiling_module = {
profile = "fans-switch-fan-mode-ef00",
tuya.dp_on_off(1, { name = "switch", component = "main", emit = emit.switch() }),
tuya.dp_countdown(2, { name = "countdown_hours" }),                    -- profile 미포함
tuya.dp_fan_mode(3, { component = "main", emit = emit.fan_mode(), converter = zero_based_five_speed }),
tuya.dp_power_on_behavior(11, {}),                                      -- profile 미포함
tuya.dp_enum(12, { name = "light_mode" }),                              -- profile 미포함
}
register_device_definition(fan_ceiling_module, device_helpers.create_fingerprints("TS0601", {
"_TZE284_z5jz7wpo",
}))
return device_definitions
