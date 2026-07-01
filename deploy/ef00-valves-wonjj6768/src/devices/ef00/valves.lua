local tuya = require "tuya_common"
local emit = require "emitters"
local device_helpers = require "devices.shared.helpers"
local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()
local battery_valve = {
profile = "valves-valve-battery",
tuya.dp_on_off(1, {
name = "valve",
emit = emit.valve(),
converter = converter.lookup_from_to({
open = true,
closed = false,
}),
}),
tuya.dp_battery(101, {}),
}
register_device_definition(battery_valve, device_helpers.create_fingerprints("TS0601", {
"_TZE204_dsagrkvg",
"_TZE284_zm8zpwas",
}))
local plain_valve = {
profile = "valves-valve",
tuya.dp_on_off(1, {
name = "valve",
emit = emit.valve(),
converter = converter.lookup_from_to({
open = true,
closed = false,
}),
}),
}
register_device_definition(plain_valve, device_helpers.create_fingerprints("TS0601", {
"_TZE200_wt9agwf3",
"_TZE200_5uodvhgc",
"_TZE200_1n2zev06",
}))
local position_valve = {
profile = "valves-valve-position-hbnfokum",
tuya.dp_on_off(1, {
name = "valve",
emit = emit.valve(),
converter = converter.lookup_from_to({
open = true,
closed = false,
}),
}),
tuya.dp_numeric(101, { name = "position", emit = emit.valvePositionHbnfokum() }),
tuya.dp_numeric(102, { name = "position_current", read_only = true, emit = emit.valveCurrentPositionHbnfokum() }),
}
register_device_definition(position_valve, device_helpers.create_fingerprints("TS0601", {
"_TZE200_hbnfokum",
}))
local irrigation_battery_valve = {
profile = "valves-valve-battery",
tuya.dp_on_off(1, {
name = "valve",
emit = emit.valve(),
converter = converter.lookup_from_to({
open = true,
closed = false,
}),
}),
tuya.dp_battery(7, {}),
}
register_device_definition(irrigation_battery_valve, device_helpers.create_fingerprints("TS0601", {
"_TZE200_akjefhj5",
"_TZE200_2wg5qrjy",
"_TZE200_81isopgh",
}))
local zvl_pro_valve_state = converter.lookup_from_to({
open = true,
closed = false,
})
local irrigation_zvl_pro = {
profile = "valves-valve-battery",
tuya.dp_on_off(1, {
name = "valve",
emit = emit.valve(),
converter = zvl_pro_valve_state,
}),
tuya.dp_raw(4, { name = "fault" }),                         -- 프로파일 미포함
tuya.dp_numeric(5, { name = "water_once" }),                 -- 프로파일 미포함
tuya.dp_battery(7, { emit = emit.battery() }),
tuya.dp_numeric(11, { name = "countdown" }),                 -- 프로파일 미포함
tuya.dp_enum(12, { name = "work_state" }),                   -- 프로파일 미포함
}
register_device_definition(irrigation_zvl_pro, device_helpers.create_fingerprints("TS0601", {
"_TZE200_fphxkxue",
}))
local gx03_valve_state = converter.lookup_from_to({
open = true,
closed = false,
})
local gx03_valve_status = converter.lookup_from_to({
manual = 0,
auto = 1,
idle = 2,
})
local dual_irrigation_battery_valve = {
profile = "valves-valve-2-battery-status",
tuya.dp_on_off(1, {
name = "valve",
component = "main",
emit = emit.valve(),
converter = gx03_valve_state,
}),
tuya.dp_on_off(2, {
name = "valve",
component = "valve2",
emit = emit.valve(),
converter = gx03_valve_state,
}),
tuya.dp_numeric(13, { name = "countdown", component = "main" }), -- 프로파일 미포함
tuya.dp_numeric(14, { name = "countdown", component = "valve2" }), -- 프로파일 미포함
tuya.dp_battery(59, { emit = emit.battery() }),
tuya.dp_enum(104, {
name = "valve_status",
component = "main",
emit = emit.valveStatusDualIrrigationMode(),
converter = gx03_valve_status,
read_only = true,
}),
tuya.dp_enum(105, {
name = "valve_status",
component = "valve2",
emit = emit.valveStatusDualIrrigationMode(),
converter = gx03_valve_status,
read_only = true,
}),
}
register_device_definition(dual_irrigation_battery_valve, device_helpers.create_fingerprints("TS0601", {
"_TZE284_8zizsafo",
"_TZE284_eaet5qt5",
"_TZE284_fhvpaltk",
"_TZE284_iilebqoo",
}))
register_device_definition(dual_irrigation_battery_valve, {
device_helpers.create_fingerprint("Nova Digital", "ZVL-DUAL"),
})
local ultrasonic_water_meter_valve = {
profile = "valves-valve-ultrasonic-meter",
tuya.dp_numeric(1, { name = "water_consumed", emit = emit.waterConsumedUltrasonicLiters() }),
tuya.dp_on_off(13, {
name = "valve",
emit = emit.valve(),
converter = converter.lookup_from_to({
open = true,
closed = false,
}),
}),
tuya.dp_on_off(14, {
name = "auto_clean",
emit = emit.autoCleanUltrasonicValve(),
converter = converter.lookup_from_to({
on = true,
off = false,
}),
}),
tuya.dp_string(16, { name = "meter_id", emit = emit.meterId() }),
tuya.dp_temperature(22, { name = "temperature", scale = 100, emit = emit.temperature("C") }),
tuya.dp_battery_voltage(26, { name = "battery_voltage", emit = emit.batteryVoltage() }),
}
register_device_definition(ultrasonic_water_meter_valve, device_helpers.create_fingerprints("TS0601", {
"_TZE200_vuwtqx0t",
"_TZE284_vuwtqx0t",
}))
return device_definitions
