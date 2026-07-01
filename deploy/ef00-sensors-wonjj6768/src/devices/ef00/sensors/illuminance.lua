local tuya = require "tuya_common"
local emit = require "emitters"
local device_helpers = require "devices.shared.helpers"
local ef00_helpers = require "devices.ef00.helpers"
local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()
local function register_sensor_definition(definitions_or_table, fingerprint_list)
if type(definitions_or_table) == "table" then
local entry = {}
for key, value in pairs(definitions_or_table) do
entry[key] = value
end
if entry.query_on_configure == nil then
entry.query_on_configure = true
end
register_device_definition(entry, fingerprint_list)
return
end
register_device_definition({
datapoints = definitions_or_table,
query_on_configure = true,
}, fingerprint_list)
end
local illum_standalone = {
tuya.dp_enum(1, { name = "brightness_state" }),                 -- 프로파일 미포함 (enum: low/mid/high/strong)
tuya.dp_illuminance(2, { emit = emit.illuminance() }),
}
register_device_definition(illum_standalone, ef00_helpers.ts0601_fingerprints( {
"_TZE200_yi4jtqq1",
"_TZE200_khx7nnka",
"_TZE204_khx7nnka",
}))
local illum_battery = {
tuya.dp_enum(1, { name = "brightness_level" }),                 -- 프로파일 미포함 (enum: LOW/MEDIUM/HIGH)
tuya.dp_illuminance(2, { emit = emit.illuminance() }),
tuya.dp_battery(4, { emit = emit.battery() }),
}
register_device_definition(illum_battery, ef00_helpers.ts0601_fingerprints( {
"_TZE200_pisltm67",
}))
register_device_definition(illum_battery, {
device_helpers.create_fingerprint("_TYST11_pisltm67", "isltm67"),
})
local pressure_temp = {
profile = "sensors-pressure-temp-display",
datapoints = {
tuya.dp_temperature(8, { emit = emit.temperature("C"), scale = 100 }),
tuya.dp_numeric(101, { name = "pressure", emit = emit.atmospheric_pressure(), scale = 10 }),
tuya.dp_numeric(102, { name = "display_brightness", emit = emit.displayBrightnessPressureLevel8() }),
},
}
register_device_definition(pressure_temp, ef00_helpers.ts0601_fingerprints( {
"_TZE204_w2vunxzm",
}))
return device_definitions
