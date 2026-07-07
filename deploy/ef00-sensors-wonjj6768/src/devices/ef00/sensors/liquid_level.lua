local tuya = require "tuya_common"
local emit = require "emitters"
local device_helpers = require "devices.shared.helpers"
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
local liquid_level_basic = {
tuya.dp_enum(1, {
name = "liquid_state",
emit = emit.liquid_state(),
converter = converter.from_only(converter.lookup_value({
[0] = "normal",
[1] = "low",
[2] = "high",
})),
}),
tuya.dp_numeric(2, { name = "liquid_depth", emit = emit.liquid_depth(), scale = 100 }),
tuya.dp_numeric(22, { name = "liquid_level_percent", emit = emit.liquid_level_percent() }),
}
register_sensor_definition(liquid_level_basic, {
device_helpers.create_fingerprint("_TZE204_7yyuo8sr", "TS0601"),
device_helpers.create_fingerprint("_TZE284_kyyu8rbj", "TS0601"),
device_helpers.create_fingerprint("Tuya", "872WZ"),
})
register_sensor_definition({
profile = "sensors-liquid-level",
datapoints = liquid_level_basic,
}, {
device_helpers.create_fingerprint("_TZE200_lvkk0hdg", "TS0601"),
})
local liquid_level_me202wz = {
profile = "sensors-liquid-level",
datapoints = {
tuya.dp_enum(1, {
name = "liquid_state",
emit = emit.liquid_state(),
converter = converter.from_only(converter.lookup_value({
[0] = "normal",
[1] = "low",
[2] = "high",
})),
}),
tuya.dp_numeric(2, { name = "liquid_depth", emit = emit.liquid_depth(), scale = 100 }),
tuya.dp_numeric(5, { name = "power_level", scale = 10 }),              -- profile 미포함
tuya.dp_numeric(7, { name = "max_set" }),                              -- profile 미포함
tuya.dp_numeric(8, { name = "mini_set" }),                             -- profile 미포함
tuya.dp_numeric(21, { name = "liquid_depth_max", scale = 100 }),       -- profile 미포함
tuya.dp_numeric(22, { name = "liquid_level_percent", emit = emit.liquid_level_percent() }),
tuya.dp_string(103, { name = "version" }),                             -- profile 미포함
},
query_on_configure = true,
}
register_sensor_definition(liquid_level_me202wz, {
device_helpers.create_fingerprint("_TZE284_mxujdmxo", "TS0601"),
device_helpers.create_fingerprint("Tuya", "ME202WZ"),
})
return device_definitions
