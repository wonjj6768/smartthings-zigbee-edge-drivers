local tuya = require "tuya_common"
local emit = require "emitters"
local device_helpers = require "devices.shared.helpers"
local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()
local valve_open_closed_converter = converter.lookup_from_to({
open = true,
closed = false,
})
local naswv03b_status = converter.lookup_from_to({
off = 0,
on_auto = 1,
button_locked = 2,
on_manual_app = 3,
on_manual_button = 4,
})
local naswv03b_on_off = converter.lookup_from_to({ off = false, on = true })
local naswv03b_trigger = function(value) return value == true and "refresh" or nil end
local naswv03b_reset_from = function(value) return value == true and "reset" or nil end
local naswv03b_fault_from = function(value) return tonumber(value) ~= 0 and "fault" or "normal" end
local function naswv03b_definition(profile, unit_kind, include_on_countdown)
local suffix = unit_kind == "liters" and "Liters" or "Gallons"
local definition = {
profile = profile,
time_start = "2000",
tuya.dp_on_off(1, { name = "switch", emit = emit.switch() }),
tuya.dp_enum(3, { name = "naswv03b_status", read_only = true, emit = emit.nasThreeStatus(), converter = naswv03b_status }),
tuya.dp_numeric(5, { name = "naswv03b_countdown", emit = emit.nasThreeCountdown() }),
tuya.dp_numeric(6, { name = "naswv03b_countdown_left", read_only = true, emit = emit.nasThreeCountdownLeft() }),
tuya.dp_numeric(9, { name = "naswv03b_water_current", read_only = true, emit = emit["nasThreeCurrent" .. suffix](), converter = converter.divide_by_pair(1000) }),
tuya.dp_battery(11, { read_only = true, emit = emit.battery() }),
tuya.dp_numeric(15, { name = "naswv03b_water_total", read_only = true, emit = emit["nasThreeTotal" .. suffix](), converter = converter.divide_by_pair(1000) }),
tuya.dp_bitmap(19, { name = "naswv03b_fault", read_only = true, emit = emit.nasThreeFault(), converter = converter.from_only(naswv03b_fault_from) }),
tuya.dp_binary(101, { name = "naswv03b_water_total_reset", emit = emit.nasThreeWaterTotalReset(), converter = converter.from_to(naswv03b_reset_from, function(value) return value == "reset" end) }),
tuya.dp_numeric(102, { name = "naswv03b_quantitative_watering", emit = emit["nasThreeQuantitative" .. suffix]() }),
tuya.dp_binary(103, { name = "naswv03b_flow_switch", emit = emit.nasThreeFlowSwitch(), converter = naswv03b_on_off }),
tuya.dp_binary(104, { name = "naswv03b_child_lock", emit = emit.nasThreeChildLock(), converter = naswv03b_on_off }),
tuya.dp_numeric(105, { name = "naswv03b_surplus_flow", read_only = true, emit = emit["nasThreeSurplus" .. suffix]() }),
tuya.dp_numeric(106, { name = "naswv03b_single_watering_duration", read_only = true, emit = emit.nasThreeSingleWateringDuration() }),
tuya.dp_binary(107, { name = "naswv03b_refresh", emit = emit.nasThreeRefresh(), converter = converter.from_to(naswv03b_trigger, function(value) return value == "refresh" end) }),
tuya.dp_numeric(108, { name = "naswv03b_single_watering_amount", read_only = true, emit = emit["nasThreeSingleAmount" .. suffix]() }),
}
if include_on_countdown then
definition[#definition + 1] = tuya.dp_numeric(109, { name = "naswv03b_on_with_countdown", emit = emit.nasThreeOnWithCountdown() })
end
return definition
end
local naswv03b_gallons = naswv03b_definition("valves-nas-wv03b-gallons", "gallons", true)
register_device_definition(naswv03b_gallons, device_helpers.create_fingerprints("TS0601", {
"_TZE204_nnhwcvbk", "_TZE284_nnhwcvbk",
"_TZE204_rzrrjkz2", "_TZE284_rzrrjkz2",
"_TZE204_uab532m0", "_TZE284_uab532m0",
}))
local naswv03b_gallons_no_on = naswv03b_definition("valves-nas-wv03b-gallons-no-on-countdown", "gallons", false)
register_device_definition(naswv03b_gallons_no_on, device_helpers.create_fingerprints("TS0601", {
"_TZE204_4fblxpma", "_TZE284_4fblxpma",
}))
local naswv03b_liters = naswv03b_definition("valves-nas-wv03b-liters", "liters", true)
register_device_definition(naswv03b_liters, device_helpers.create_fingerprints("TS0601", {
"_TZE204_z7a2jmyy", "_TZE284_z7a2jmyy",
}))
local battery_valve = {
profile = "valves-valve-battery-state-zpv01",
tuya.dp_on_off(1, {
name = "valve",
emit = emit.valve(),
converter = valve_open_closed_converter,
}),
tuya.dp_enum(8, {
name = "valve_state",
read_only = true,
emit = emit.zpv01ValveState(),
converter = converter.lookup_from_to({
unknown = 0,
open = 1,
closed = 2,
}),
}),
tuya.dp_battery(101, { read_only = true, emit = emit.battery() }),
}
register_device_definition(battery_valve, device_helpers.create_fingerprints("TS0601", {
"_TZE204_dsagrkvg",
"_TZE284_zm8zpwas",
"_TZE284_sdvbnmj5",
}))
local frankever_valve = {
profile = "valves-valve-threshold-timer-fkv02",
tuya.dp_on_off(1, {
name = "valve",
emit = emit.valve(),
converter = valve_open_closed_converter,
}),
tuya.dp_numeric(9, {
name = "timer",
emit = emit.fkv02Timer(),
converter = converter.divide_by_pair(60),
}),
tuya.dp_numeric(101, {
name = "threshold",
emit = emit.fkv02Threshold(),
converter = converter.to_only(converter.pipe(
converter.clamp(0, 100),
converter.round_to_step(10)
)),
}),
}
register_device_definition(frankever_valve, device_helpers.create_fingerprints("TS0601", {
"_TZE200_wt9agwf3",
"_TZE200_5uodvhgc",
"_TZE200_1n2zev06",
}))
local position_valve = {
profile = "valves-valve-position-hbnfokum",
tuya.dp_on_off(1, {
name = "valve",
emit = emit.valve(),
converter = valve_open_closed_converter,
}),
tuya.dp_numeric(101, { name = "position", emit = emit.valvePositionHbnfokum() }),
tuya.dp_numeric(102, { name = "position_current", read_only = true, emit = emit.valveCurrentPositionHbnfokum() }),
}
register_device_definition(position_valve, device_helpers.create_fingerprints("TS0601", {
"_TZE200_hbnfokum",
}))
local zvg1_valve = {
profile = "valves-valve-battery-timer-zvg1",
tuya.dp_on_off(1, {
name = "valve",
emit = emit.valve(),
converter = valve_open_closed_converter,
}),
tuya.dp_numeric(5, {
name = "water_consumed",
read_only = true,
emit = emit.zvg1WaterConsumed(),
converter = converter.divide_by_from_only(33.8140226),
}),
tuya.dp_battery(7, { read_only = true, emit = emit.battery() }),
tuya.dp_enum(10, {
name = "weather_delay",
emit = emit.zvg1WeatherDelay(),
converter = converter.lookup_from_to({
disabled = 0,
["24h"] = 1,
["48h"] = 2,
["72h"] = 3,
}),
}),
tuya.dp_numeric(11, {
name = "timer",
emit = emit.zvg1Timer(),
converter = converter.divide_by_pair(60),
}),
tuya.dp_numeric(11, {
name = "timer_time_left",
read_only = true,
emit = emit.zvg1TimerTimeLeft(),
converter = converter.divide_by_from_only(60),
}),
tuya.dp_enum(12, {
name = "timer_state",
read_only = true,
emit = emit.zvg1TimerState(),
converter = converter.from_only(converter.lookup_value({
[0] = "disabled",
[1] = "active",
}, "enabled")),
}),
tuya.dp_numeric(15, {
name = "last_valve_open_duration",
read_only = true,
emit = emit.zvg1LastValveDuration(),
converter = converter.divide_by_from_only(60),
}),
}
register_device_definition(zvg1_valve, device_helpers.create_fingerprints("TS0601", {
"_TZE200_akjefhj5",
"_TZE200_2wg5qrjy",
"_TZE200_81isopgh",
"_TZE204_qtnjuoae",
"_TZE284_qtnjuoae",
"_TZE284_xuflgcnz",
}))
local irrigation_zvl_pro = {
profile = "valves-valve-battery-countdown-zvl-pro",
tuya.dp_on_off(1, {
name = "valve",
emit = emit.valve(),
converter = valve_open_closed_converter,
}),
tuya.dp_raw(4, { name = "fault", read_only = true }),
tuya.dp_numeric(5, { name = "water_once", read_only = true, emit = emit.zvlProWaterOnce() }),
tuya.dp_battery(7, { read_only = true, emit = emit.battery() }),
tuya.dp_numeric(11, { name = "countdown", emit = emit.zvlProCountdown() }),
tuya.dp_enum(12, {
name = "work_state",
read_only = true,
emit = emit.zvlProWorkState(),
converter = converter.lookup_from_to({
auto = 0,
manual = 1,
idle = 2,
}),
}),
}
register_device_definition(irrigation_zvl_pro, device_helpers.create_fingerprints("TS0601", {
"_TZE200_fphxkxue",
}))
local gx03_valve_state_converter = converter.lookup_from_to({
manual = 0,
auto = 1,
closed = 2,
})
local gx03_valve = {
profile = "valves-valve-2-battery-timer-gx03",
tuya.dp_on_off(1, {
name = "valve",
component = "main",
emit = emit.valve(),
converter = valve_open_closed_converter,
}),
tuya.dp_on_off(2, {
name = "valve",
component = "valve2",
emit = emit.valve(),
converter = valve_open_closed_converter,
}),
tuya.dp_numeric(13, { name = "timer", component = "main", emit = emit.gx03Timer() }),
tuya.dp_numeric(14, { name = "timer", component = "valve2", emit = emit.gx03Timer() }),
tuya.dp_numeric(25, {
name = "last_duration",
component = "main",
read_only = true,
emit = emit.gx03LastDuration(),
}),
tuya.dp_numeric(26, {
name = "last_duration",
component = "valve2",
read_only = true,
emit = emit.gx03LastDuration(),
}),
tuya.dp_battery(59, { read_only = true, emit = emit.battery() }),
tuya.dp_enum(104, {
name = "valve_state",
component = "main",
emit = emit.gx03ValveState(),
converter = gx03_valve_state_converter,
read_only = true,
}),
tuya.dp_enum(105, {
name = "valve_state",
component = "valve2",
emit = emit.gx03ValveState(),
converter = gx03_valve_state_converter,
read_only = true,
}),
}
register_device_definition(gx03_valve, device_helpers.create_fingerprints("TS0601", {
"_TZE284_8zizsafo",
"_TZE284_iilebqoo",
}))
local dual_water_switch_status_converter = converter.lookup_from_to({
manual = 0,
auto = 1,
idle = 2,
})
local dual_water_switch = {
profile = "valves-valve-2-battery-status",
tuya.dp_on_off(1, {
name = "valve",
component = "main",
emit = emit.valve(),
converter = valve_open_closed_converter,
}),
tuya.dp_on_off(2, {
name = "valve",
component = "valve2",
emit = emit.valve(),
converter = valve_open_closed_converter,
}),
tuya.dp_numeric(13, { name = "countdown", component = "main", emit = emit.waterSwitchCountdown() }),
tuya.dp_numeric(14, { name = "countdown", component = "valve2", emit = emit.waterSwitchCountdown() }),
tuya.dp_numeric(25, {
name = "valve_duration",
component = "main",
read_only = true,
emit = emit.waterSwitchDuration(),
}),
tuya.dp_numeric(26, {
name = "valve_duration",
component = "valve2",
read_only = true,
emit = emit.waterSwitchDuration(),
}),
tuya.dp_battery(59, { read_only = true, emit = emit.battery() }),
tuya.dp_enum(104, {
name = "valve_status",
component = "main",
emit = emit.valveStatusDualIrrigationMode(),
converter = dual_water_switch_status_converter,
read_only = true,
}),
tuya.dp_enum(105, {
name = "valve_status",
component = "valve2",
emit = emit.valveStatusDualIrrigationMode(),
converter = dual_water_switch_status_converter,
read_only = true,
}),
}
register_device_definition(dual_water_switch, device_helpers.create_fingerprints("TS0601", {
"_TZE284_eaet5qt5",
"_TZE284_fhvpaltk",
}))
local ultrasonic_water_meter_valve = {
profile = "valves-valve-ultrasonic-meter",
tuya.dp_numeric(1, {
name = "water_consumed",
read_only = true,
emit = emit.vuwtqx0tWaterConsumed(),
}),
tuya.dp_month_consumption(2, {
raw = true,
raw_bytes = 4,
raw_from_tail = true,
scale = 1,
read_only = true,
emit = emit.vuwtqx0tMonthConsumption(),
}),
tuya.dp_daily_consumption(3, {
raw = true,
raw_bytes = 4,
raw_from_tail = true,
scale = 1,
read_only = true,
emit = emit.vuwtqx0tDailyConsumption(),
}),
tuya.dp_numeric(4, {
name = "report_period",
converter = converter.report_period_hours(),
emit = emit.vuwtqx0tReportPeriod(),
}),
tuya.dp_water_meter_faults(5, { read_only = true, emit = emit.vuwtqx0tFaults() }),
tuya.dp_on_off(13, {
name = "valve",
emit = emit.valve(),
converter = valve_open_closed_converter,
}),
tuya.dp_on_off(14, {
name = "auto_clean",
emit = emit.autoCleanUltrasonicValve(),
converter = converter.lookup_from_to({
on = true,
off = false,
}),
}),
tuya.dp_meter_id(16, { read_only = true, emit = emit.vuwtqx0tMeterId() }),
tuya.dp_reverse_water_consumed(18, {
raw = true,
raw_bytes = 4,
read_only = true,
emit = emit.vuwtqx0tReverseConsumed(),
}),
tuya.dp_flow_rate(21, {
raw = true,
raw_bytes = 4,
scale = 1,
read_only = true,
emit = emit.vuwtqx0tFlowRate(),
}),
tuya.dp_temperature(22, { name = "temperature", scale = 100, read_only = true, emit = emit.temperature("C") }),
tuya.dp_battery_voltage(26, { name = "battery_voltage", read_only = true, emit = emit.batteryVoltage() }),
}
register_device_definition(ultrasonic_water_meter_valve, device_helpers.create_fingerprints("TS0601", {
"_TZE200_vuwtqx0t",
"_TZE284_vuwtqx0t",
}))
return device_definitions
