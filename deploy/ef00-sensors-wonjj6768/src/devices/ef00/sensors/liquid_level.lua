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
local liquid_level_872wz = {
profile = "sensors-liquid-level-872wz",
datapoints = {
tuya.dp_enum(1, {
name = "liquid_state",
emit = emit.liquid_state(),
read_only = true,
converter = converter.from_only(converter.lookup_value({
[0] = "normal",
[1] = "low",
[2] = "high",
})),
}),
tuya.dp_numeric(2, {
name = "liquid_depth",
emit = emit.wls872LiquidDepth(),
read_only = true,
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(7, { name = "max_set", emit = emit.wls872MaximumPercent() }),
tuya.dp_numeric(8, { name = "min_set", emit = emit.wls872MinimumPercent() }),
tuya.dp_binary(9, {
name = "silent_mode",
emit = emit.wls872SilentMode(),
converter = converter.lookup_from_to({ on = true, off = false }),
}),
tuya.dp_numeric(19, {
name = "installation_height",
emit = emit.wls872InstallationHeight(),
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(21, {
name = "liquid_depth_max",
emit = emit.wls872MaximumDepth(),
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(22, {
name = "liquid_level_percent",
emit = emit.liquid_level_percent(),
read_only = true,
}),
tuya.dp_numeric(27, { name = "alarm_time", emit = emit.wls872AlarmDuration() }),
},
query_on_configure = true,
}
register_sensor_definition(liquid_level_872wz, {
device_helpers.create_fingerprint("_TZE204_7yyuo8sr", "TS0601"),
})
local liquid_level_me201wz = {
profile = "sensors-liquid-level-me201wz",
datapoints = {
tuya.dp_enum(1, {
name = "liquid_state",
emit = emit.liquid_state(),
read_only = true,
converter = converter.from_only(converter.lookup_value({
[0] = "normal",
[1] = "low",
[2] = "high",
})),
}),
tuya.dp_numeric(2, {
name = "liquid_depth",
emit = emit.me201LiquidDepth(),
read_only = true,
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(5, {
name = "voltage",
emit = emit.voltage(),
read_only = true,
converter = converter.divide_by_pair(10),
}),
tuya.dp_numeric(7, { name = "max_set", emit = emit.me201MaximumPercent() }),
tuya.dp_numeric(8, { name = "min_set", emit = emit.me201MinimumPercent() }),
tuya.dp_numeric(19, {
name = "installation_height",
emit = emit.me201InstallationHeight(),
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(21, {
name = "liquid_depth_max",
emit = emit.me201MaximumDepth(),
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(22, {
name = "liquid_level_percent",
emit = emit.liquid_level_percent(),
read_only = true,
}),
tuya.dp_binary(24, {
name = "relay_switch",
emit = emit.me201RelaySwitch(),
converter = converter.lookup_from_to({ on = true, off = false }),
}),
tuya.dp_binary(101, {
name = "pump_mode",
emit = emit.me201PumpMode(),
converter = converter.lookup_from_to({ supply = true, drainage = false }),
}),
tuya.dp_binary(102, {
name = "pump_control",
emit = emit.me201PumpControl(),
converter = converter.lookup_from_to({ auto = true, manual = false }),
}),
tuya.dp_string(103, { name = "version", emit = emit.me201Version(), read_only = true }),
},
query_on_configure = true,
}
register_sensor_definition(liquid_level_me201wz, {
device_helpers.create_fingerprint("_TZE284_kyyu8rbj", "TS0601"),
})
local liquid_level_tlc2206 = {
profile = "sensors-liquid-level-tlc2206",
datapoints = {
tuya.dp_enum(1, {
name = "liquid_state",
emit = emit.liquid_state(),
read_only = true,
converter = converter.from_only(converter.lookup_value({
[0] = "normal",
[1] = "low",
[2] = "high",
})),
}),
tuya.dp_numeric(2, {
name = "liquid_depth",
emit = emit.tlc2206LiquidDepth(),
read_only = true,
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(7, { name = "max_set", emit = emit.tlc2206MaximumPercent() }),
tuya.dp_numeric(8, { name = "min_set", emit = emit.tlc2206MinimumPercent() }),
tuya.dp_numeric(19, {
name = "installation_height",
emit = emit.tlc2206InstallationHeight(),
converter = converter.divide_by_pair(1000),
}),
tuya.dp_numeric(21, {
name = "liquid_depth_max",
emit = emit.tlc2206MaximumDepth(),
converter = converter.divide_by_pair(1000),
}),
tuya.dp_numeric(22, {
name = "liquid_level_percent",
emit = emit.liquid_level_percent(),
read_only = true,
}),
},
query_on_configure = true,
}
register_sensor_definition(liquid_level_tlc2206, {
device_helpers.create_fingerprint("_TZE200_lvkk0hdg", "TS0601"),
})
local liquid_level_me202wz = {
profile = "sensors-liquid-level-me202wz",
datapoints = {
tuya.dp_enum(1, {
name = "liquid_state",
emit = emit.liquid_state(),
read_only = true,
converter = converter.from_only(converter.lookup_value({
[0] = "normal",
[1] = "low",
[2] = "high",
})),
}),
tuya.dp_numeric(2, {
name = "liquid_depth",
emit = emit.me202LiquidDepth(),
read_only = true,
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(5, {
name = "voltage",
emit = emit.voltage(),
read_only = true,
converter = converter.divide_by_pair(10),
}),
tuya.dp_numeric(7, { name = "max_set", emit = emit.me202MaximumPercent() }),
tuya.dp_numeric(8, { name = "min_set", emit = emit.me202MinimumPercent() }),
tuya.dp_numeric(21, {
name = "liquid_depth_max",
emit = emit.me202MaximumDepth(),
converter = converter.divide_by_pair(100),
}),
tuya.dp_numeric(22, {
name = "liquid_level_percent",
emit = emit.liquid_level_percent(),
read_only = true,
}),
tuya.dp_binary(24, {
name = "relay_switch",
emit = emit.me202RelaySwitch(),
converter = converter.lookup_from_to({ on = true, off = false }),
}),
tuya.dp_binary(101, {
name = "pump_mode",
emit = emit.me202PumpMode(),
converter = converter.lookup_from_to({ supply = true, drainage = false }),
}),
tuya.dp_binary(102, {
name = "pump_control",
emit = emit.me202PumpControl(),
converter = converter.lookup_from_to({ auto = true, manual = false }),
}),
tuya.dp_string(103, { name = "version", emit = emit.me202Version(), read_only = true }),
},
query_on_configure = true,
}
register_sensor_definition(liquid_level_me202wz, {
device_helpers.create_fingerprint("_TZE284_mxujdmxo", "TS0601"),
})
return device_definitions
