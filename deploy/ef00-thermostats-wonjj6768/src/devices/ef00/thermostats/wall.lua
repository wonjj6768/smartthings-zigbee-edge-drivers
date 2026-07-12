local tuya = require "tuya_common"
local emit = require "emitters"
local device_helpers = require "devices.shared.helpers"
local ef00_helpers = require "devices.ef00.helpers"
local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()
local BAC003_POWER_FIELD = "bac003_power_state"
local BAC003_MODE_FIELD = "bac003_system_mode_device"
local XZ_AKT101_POWER_FIELD = "xz_akt101_power_state"
local XZ_AKT101_MODE_FIELD = "xz_akt101_system_mode_device"
local HY08WE_POWER_FIELD = "hy08we_power_state"
local HY08WE_MODE_FIELD = "hy08we_system_mode_device"
local ETOP_POWER_FIELD = "etop_power_state"
local ETOP_MODE_FIELD = "etop_system_mode_device"
local TYBAC_POWER_FIELD = "tybac_power_state"
local TYBAC_MODE_FIELD = "tybac_system_mode_device"
local HHST_POWER_FIELD = "hhst_power_state"
local HHST_MODE_FIELD = "hhst_system_mode_device"
local TV02_HEATING_STOP_FIELD = "tv02_heating_stop"
local TV02_PRESET_MODE_FIELD = "tv02_preset_mode"
local function valve_position_to_running_state(value)
local numeric = tonumber(value)
if numeric == nil then
return nil
end
if numeric > 0 then
return "heating"
end
return "idle"
end
local function thermostat_variant1_mode_from_device(value)
local numeric = tonumber(value)
local lookup = {
[0] = "auto",
[1] = "heat",
[2] = "off",
[3] = "heat",
}
return lookup[numeric]
end
local function thermostat_variant1_mode_to_device(value)
local lookup = {
auto = 0,
heat = 1,
off = 2,
}
return lookup[value]
end
local function thermostat_variant3_running_state(value)
local numeric = tonumber(value)
if numeric == nil then
return nil
end
if numeric == 0 then
return "heating"
end
return "idle"
end
local function thermostat_variant14_mode_from_preset(value)
local numeric = tonumber(value)
if numeric == nil then
return nil
end
if numeric == 6 then
return "off"
end
return "heat"
end
local function thermostat_variant14_mode_to_preset(value)
if value == "off" then
return 6
end
if value == "heat" then
return 0
end
return nil
end
local function thermostat_gtz10_mode_from_device(value)
local numeric = tonumber(value)
local lookup = {
[0] = "heat",
[1] = "auto",
[2] = "heat",
[3] = "heat",
[4] = "heat",
[5] = "off",
}
return lookup[numeric]
end
local function thermostat_gtz10_mode_to_device(value)
local lookup = {
heat = 0,
auto = 1,
off = 5,
}
return lookup[value]
end
local function saswell_system_mode_write(_, value)
if value ~= "off" and value ~= "heat" and value ~= "auto" then
return nil
end
return {
{ dp = 101, datatype = tuya.DP_TYPE_BOOL, value = value ~= "off" },
{ dp = 108, datatype = tuya.DP_TYPE_BOOL, value = value == "auto" },
}
end
local function bac003_state_from_device(value, device)
local is_on = value == true
device:set_field(BAC003_POWER_FIELD, is_on, { persist = false })
if not is_on then
return "off"
end
return device:get_field(BAC003_MODE_FIELD) or "cool"
end
local function bac003_mode_from_device(value, device)
local lookup = {
[0] = "cool",
[1] = "heat",
[2] = "fanonly",
}
local mode = lookup[tonumber(value)]
if mode == nil then
return nil
end
device:set_field(BAC003_MODE_FIELD, mode, { persist = false })
if device:get_field(BAC003_POWER_FIELD) == false then
return "off"
end
return mode
end
local function bac003_system_mode_write(_, value)
local mode_lookup = {
cool = 0,
heat = 1,
fanonly = 2,
}
if value == "off" then
return {
{ dp = 1, datatype = tuya.DP_TYPE_BOOL, value = false },
}
end
local mode = mode_lookup[value]
if mode == nil then
return nil
end
return {
{ dp = 1, datatype = tuya.DP_TYPE_BOOL, value = true },
{ dp = 2, datatype = tuya.DP_TYPE_ENUM, value = mode },
}
end
local function tv02_preset_mode_from_device(value, device)
local lookup = {
[0] = "auto",
[1] = "heat",
[2] = "heat",
[3] = "heat",
}
local mode = lookup[tonumber(value)]
if mode == nil then
return nil
end
device:set_field(TV02_PRESET_MODE_FIELD, mode, { persist = false })
if device:get_field(TV02_HEATING_STOP_FIELD) == true then
return "off"
end
return mode
end
local function tv02_system_mode_from_device(value, device)
local heating_stop = value == true
device:set_field(TV02_HEATING_STOP_FIELD, heating_stop, { persist = false })
if heating_stop then
return "off"
end
return device:get_field(TV02_PRESET_MODE_FIELD) or "heat"
end
local function tv02_system_mode_write(_, value)
if value == "off" then
return {
{ dp = 107, datatype = tuya.DP_TYPE_BOOL, value = true },
}
end
if value == "auto" then
return {
{ dp = 2, datatype = tuya.DP_TYPE_ENUM, value = 0 },
}
end
if value == "heat" then
return {
{ dp = 2, datatype = tuya.DP_TYPE_ENUM, value = 1 },
}
end
return nil
end
local function xz_akt101_state_from_device(value, device)
local is_on = value == true
device:set_field(XZ_AKT101_POWER_FIELD, is_on, { persist = false })
if not is_on then
return "off"
end
return device:get_field(XZ_AKT101_MODE_FIELD) or "cool"
end
local function xz_akt101_mode_from_device(value, device)
local lookup = {
[0] = "cool",
[1] = "heat",
[2] = "fanonly",
}
local mode = lookup[tonumber(value)]
if mode == nil then
return nil
end
device:set_field(XZ_AKT101_MODE_FIELD, mode, { persist = false })
if device:get_field(XZ_AKT101_POWER_FIELD) == false then
return "off"
end
return mode
end
local function xz_akt101_system_mode_write(_, value)
local mode_lookup = {
cool = 0,
heat = 1,
fanonly = 2,
fan_only = 2,
}
if value == "off" then
return {
{ dp = 1, datatype = tuya.DP_TYPE_BOOL, value = false },
}
end
local mode = mode_lookup[value]
if mode == nil then
return nil
end
return {
{ dp = 1, datatype = tuya.DP_TYPE_BOOL, value = true },
{ dp = 2, datatype = tuya.DP_TYPE_ENUM, value = mode },
}
end
local function hy08we_state_from_device(value, device)
local is_on = value == true
device:set_field(HY08WE_POWER_FIELD, is_on, { persist = false })
if not is_on then
return "off"
end
return device:get_field(HY08WE_MODE_FIELD) or "heat"
end
local function hy08we_mode_from_device(value, device)
local lookup = {
[0] = "heat",
[1] = "auto",
[2] = "heat",
}
local mode = lookup[tonumber(value)]
if mode == nil then
return nil
end
device:set_field(HY08WE_MODE_FIELD, mode, { persist = false })
if device:get_field(HY08WE_POWER_FIELD) == false then
return "off"
end
return mode
end
local function hy08we_system_mode_write(_, value)
if value == "off" then
return {
{ dp = 125, datatype = tuya.DP_TYPE_BOOL, value = false },
}
end
local mode_lookup = {
heat = 0,
auto = 1,
}
local mode = mode_lookup[value]
if mode == nil then
return nil
end
return {
{ dp = 125, datatype = tuya.DP_TYPE_BOOL, value = true },
{ dp = 128, datatype = tuya.DP_TYPE_ENUM, value = mode },
}
end
local function power_mode_from_device(power_field, mode_field, default_mode)
return function(value, device)
local is_on = value == true
device:set_field(power_field, is_on, { persist = false })
if not is_on then
return "off"
end
return device:get_field(mode_field) or default_mode
end
end
local function enum_mode_from_device(power_field, mode_field, lookup)
return function(value, device)
local mode = lookup[tonumber(value)]
if mode == nil then
return nil
end
device:set_field(mode_field, mode, { persist = false })
if device:get_field(power_field) == false then
return "off"
end
return mode
end
end
local function power_mode_write(power_dp, mode_dp, lookup)
return function(_, value)
if value == "off" then
return {
{ dp = power_dp, datatype = tuya.DP_TYPE_BOOL, value = false },
}
end
local mode = lookup[value]
if mode == nil then
return nil
end
return {
{ dp = power_dp, datatype = tuya.DP_TYPE_BOOL, value = true },
{ dp = mode_dp, datatype = tuya.DP_TYPE_ENUM, value = mode },
}
end
end
local function x5h_local_temperature_from_device(value)
local numeric = tonumber(value)
if numeric == nil then
return nil
end
if numeric >= 0x8000 then
numeric = numeric - 0x10000 + 1
end
return numeric / 10
end
local bool_heat_off = converter.lookup_from_to({
heat = true,
off = false,
})
local enum_heat_idle_bool = converter.lookup_from_to({
heating = true,
idle = false,
})
local enum_heat_idle_inverted = converter.lookup_from_to({
heating = 0,
idle = 1,
})
local thermostat_zwt198 = {
profile = "thermostats-thermostat",
tuya.dp_binary(1, {
name = "system_mode",
converter = converter.lookup_from_to({
heat = true,
off = false,
}),
emit = emit.thermostat_mode(),
}),
tuya.dp_current_heating_setpoint(2, { scale = 10 }),
tuya.dp_local_temperature(3, { scale = 10 }),
tuya.dp_running_state(101, {
converter = converter.lookup_from_to({
heating = 1,
idle = 0,
}),
emit = emit.thermostat_operating_state(),
}),
}
register_device_definition(thermostat_zwt198, ef00_helpers.ts0601_fingerprints( {
"_TZE200_viy9ihs7",
"_TZE204_lzriup1j",
"_TZE204_xnbkhhdr",
"_TZE284_xnbkhhdr",
"_TZE204_oh8y8pv8",
"_TZE204_gops3slb",
"_TZE284_gops3slb",
"_TZE284_zjhoqbrd",
"_TZE204_zjhoqbrd",
"_TZE284_aaeaifez",
"_TZE204_aaeaifez",
"_TZE28C1000000_aaeaifez",
}))
register_device_definition(thermostat_zwt198, {
device_helpers.create_fingerprint("AVATTO", "WT-100-BH"),
})
local thermostat_zwt07 = {
profile = "thermostats-thermostat-zwt07",
tuya.dp_binary(1, {
name = "system_mode",
converter = converter.lookup_from_to({
heat = true,
off = false,
}),
emit = emit.thermostat_mode(),
}),
tuya.dp_enum(2, {
name = "preset",
emit = emit.thermostatPresetZwt07Program(),
converter = converter.lookup_from_to({
program = 0,
manual = 1,
}),
}),
tuya.dp_binary(10, { name = "frost_protection" }),
tuya.dp_current_heating_setpoint(16, { scale = 10 }),
tuya.dp_local_temperature(24, { scale = 10 }),
tuya.dp_running_state(36, {
converter = converter.lookup_from_to({
idle = 0,
heating = 1,
}),
emit = emit.thermostat_operating_state(),
}),
}
register_device_definition(thermostat_zwt07, ef00_helpers.ts0601_fingerprints( {
"_TZE200_g9a3awaj",
}))
local hy08we_setpoint = tuya.dp_current_heating_setpoint(126, {
scale = 10,
emit = emit.heating_setpoint("C"),
})
local thermostat_hy08we = {
profile = "thermostats-thermostat",
named_mapping = {
named_mappings = {
system_mode = hy08we_system_mode_write,
current_heating_setpoint = hy08we_setpoint,
},
},
tuya.dp_binary(102, {
name = "running_state",
converter = converter.lookup_from_to({
heating = true,
idle = false,
}),
emit = emit.thermostat_operating_state(),
}),
tuya.dp_temperature(103, { name = "external_temperature", scale = 10 }), -- profile 미포함
tuya.dp_child_lock(129, {}),
tuya.dp_binary(125, {
name = "state",
from_device = hy08we_state_from_device,
emit = emit.thermostat_mode(),
read_only = true,
}),
hy08we_setpoint,
tuya.dp_local_temperature(127, { scale = 10 }),
tuya.dp_system_mode(128, {
from_device = hy08we_mode_from_device,
emit = emit.thermostat_mode(),
read_only = true,
}),
}
register_device_definition(thermostat_hy08we, ef00_helpers.ts0601_fingerprints( {
"_TZE200_znzs7yaw",
}))
local thermostat_tervix = {
profile = "thermostats-thermostat-tervix",
tuya.dp_system_mode(1, {
converter = converter.lookup_from_to({
off = 0,
heat = 1,
}),
}),
tuya.dp_enum(2, {
name = "preset",
emit = emit.thermostatPresetTervixProgram(),
converter = converter.lookup_from_to({
manual = 0,
program = 1,
}),
}),
tuya.dp_running_state(3, {
converter = converter.lookup_from_to({
idle = 0,
heating = 1,
}),
emit = emit.thermostat_operating_state(),
}),
tuya.dp_binary(8, {
name = "window_detection",
converter = converter.lookup_from_to({ on = true, off = false }),
emit = emit.windowDetectionTervix(),
}),
tuya.dp_frost_protection(10, {}),                                       -- profile 미포함
tuya.dp_current_heating_setpoint(16, { scale = 10 }),
tuya.dp_max_temperature_limit(19, { scale = 10 }),                      -- profile 미포함
tuya.dp_local_temperature(24, { scale = 10 }),
tuya.dp_binary(25, { name = "window_state" }),                          -- profile 미포함
tuya.dp_local_temperature_calibration(27, { scale = 1 }),
tuya.dp_humidity(34, {}),                                               -- profile 미포함
tuya.dp_child_lock(40, {}),
tuya.dp_enum(43, {
name = "temperature_sensor_select",
converter = converter.lookup_from_to({
["in"] = 0,
out = 1,
}),
emit = emit.tempSensorSelectTervixInOut(),
}),
tuya.dp_raw(48, { name = "week_schedule" }),                            -- profile 미포함
tuya.dp_enum(58, { name = "run_mode" }),                                -- profile 미포함
tuya.dp_enum(61, { name = "week_program_periods" }),                    -- profile 미포함
tuya.dp_numeric(101, { name = "switch_sensitivity", scale = 10 }),      -- profile 미포함
tuya.dp_temperature(102, { name = "floor_temp_protection", scale = 10 }), -- profile 미포함
tuya.dp_temperature(103, { name = "floor_low_protection", scale = 10 }), -- profile 미포함
tuya.dp_numeric(104, { name = "window_open_detection_time" }),          -- profile 미포함
tuya.dp_numeric(105, { name = "window_open_detection_temp" }),          -- profile 미포함
tuya.dp_numeric(106, { name = "window_open_delay_time" }),              -- profile 미포함
tuya.dp_binary(107, { name = "humidity_control" }),                     -- profile 미포함
tuya.dp_numeric(108, { name = "upper_humidity_limit" }),                -- profile 미포함
}
register_device_definition(thermostat_tervix, ef00_helpers.ts0601_fingerprints( {
"_TZE284_6kijc7nd",
"_TZE204_6kijc7nd",
}))
local thermostat_x5h = {
profile = "thermostats-thermostat-x5h",
tuya.dp_binary(1, {
name = "system_mode",
converter = converter.lookup_from_to({
heat = true,
off = false,
}),
emit = emit.thermostat_mode(),
}),
tuya.dp_enum(2, {
name = "preset",
emit = emit.thermostatPresetX5hProgram(),
converter = converter.lookup_from_to({
manual = 0,
program = 1,
}),
}),
tuya.dp_running_state(3, {
converter = converter.lookup_from_to({
heating = true,
idle = false,
}),
emit = emit.thermostat_operating_state(),
}),
tuya.dp_binary(7, { name = "sound" }),                                 -- profile 미포함
tuya.dp_frost_protection(10, {}),                                      -- profile 미포함
tuya.dp_current_heating_setpoint(16, { scale = 10 }),
tuya.dp_max_temperature_limit(19, { name = "upper_temp" }),            -- profile 미포함
tuya.dp_numeric(24, {
name = "local_temperature",
from_device = x5h_local_temperature_from_device,
emit = emit.temperature("C"),
}),
tuya.dp_local_temperature_calibration(27, { scale = 10 }),
tuya.dp_raw(30, { name = "schedule" }),                                -- profile 미포함
tuya.dp_enum(31, {
name = "working_day",
converter = converter.lookup_from_to({
mon_fri = 0,
mon_sat = 1,
all_days = 2,
}),
emit = emit.workingDayX5h(),
}),
tuya.dp_binary(39, { name = "factory_reset" }),                        -- profile 미포함
tuya.dp_child_lock(40, {}),
tuya.dp_enum(43, {
name = "temperature_sensor_select",
converter = converter.lookup_from_to({
internal = 0,
external = 1,
both = 2,
}),
emit = emit.temperatureSensorSelectX5hThree(),
}),
tuya.dp_raw(45, { name = "fault_alarm" }),                             -- profile 미포함
tuya.dp_deadzone_temperature(101, { scale = 10, emit = emit.tempDeltaXhCToNinetyFive() }),
tuya.dp_temperature(102, { name = "heating_temp_limit" }),             -- profile 미포함
tuya.dp_binary(103, { name = "output_reverse" }),                      -- profile 미포함
tuya.dp_enum(104, { name = "brightness_state" }),                      -- profile 미포함
}
register_device_definition(thermostat_x5h, ef00_helpers.ts0601_fingerprints( {
"_TZE200_2ekuz3dz",
}))
register_device_definition(thermostat_x5h, {
device_helpers.create_fingerprint("Beok", "TGR85-ZB"),
device_helpers.create_fingerprint("AVATTO", "ZWT-100-16A"),
})
local thermostat_thermosphere = {
profile = "thermostats-thermostat-basic",
tuya.dp_binary(1, {
name = "system_mode",
converter = converter.lookup_from_to({
auto = true,
off = false,
}),
emit = emit.thermostat_mode(),
}),
tuya.dp_current_heating_setpoint(2, { scale = 10 }),
tuya.dp_local_temperature(38, { scale = 10 }),
}
register_device_definition(thermostat_thermosphere, ef00_helpers.ts0601_fingerprints( {
"_TZE200_ha0vwoew",
}))
local bac003_setpoint = tuya.dp_current_heating_setpoint(16, {
scale = 1,
emit = emit.heating_setpoint("C"),
})
local bac003_fan_mode = tuya.dp_fan_mode(28, {
converter = converter.lookup_from_to({
low = 0,
medium = 1,
high = 2,
auto = 3,
}),
emit = emit.fan_mode(),
})
local thermostat_floor = {
profile = "thermostats-thermostat-floor",
tuya.dp_binary(1, {
name = "system_mode",
converter = converter.lookup_from_to({
heat = true,
off = false,
}),
emit = emit.thermostat_mode(),
}),
tuya.dp_enum(2, {
name = "preset",
emit = emit.thermostatPresetFloorManualAuto(),
converter = converter.lookup_from_to({
manual = 0,
auto = 1,
}),
}),
tuya.dp_current_heating_setpoint(16, { scale = 10 }),
tuya.dp_temperature(24, { name = "device_temperature", scale = 10 }),    -- profile 미포함
tuya.dp_local_temperature_calibration(27, { scale = 10 }),
tuya.dp_running_state(36, {
converter = converter.lookup_from_to({
heating = 0,
idle = 1,
}),
emit = emit.thermostat_operating_state(),
}),
tuya.dp_child_lock(40, {}),
tuya.dp_local_temperature(102, { scale = 10 }),
tuya.dp_deadzone_temperature(103, { scale = 1 }),                       -- profile 미포함
tuya.dp_raw(101, { name = "schedule_sunday" }),                         -- profile 미포함
tuya.dp_raw(105, { name = "schedule_saturday" }),                       -- profile 미포함
tuya.dp_raw(106, { name = "schedule_friday" }),                         -- profile 미포함
tuya.dp_raw(107, { name = "schedule_thursday" }),                       -- profile 미포함
tuya.dp_raw(108, { name = "schedule_wednesday" }),                      -- profile 미포함
tuya.dp_raw(109, { name = "schedule_tuesday" }),                        -- profile 미포함
tuya.dp_raw(110, { name = "schedule_monday" }),                         -- profile 미포함
}
register_device_definition(thermostat_floor, ef00_helpers.ts0601_fingerprints( {
"_TZE200_edl8pz1k",
"_TZE204_edl8pz1k",
"_TZE204_6a4vxfnv",
"_TZE200_spyvfeti",
}))
register_device_definition(thermostat_floor, {
device_helpers.create_fingerprint("ELECTSMART", "EST-120Z"),
})
local thermostat_bot_r9v = {
profile = "thermostats-thermostat-battery",
tuya.dp_binary(1, {
name = "system_mode",
converter = converter.lookup_from_to({
heat = true,
off = false,
}),
emit = emit.thermostat_mode(),
}),
tuya.dp_enum(2, {
name = "preset",
converter = converter.lookup_from_to({
auto = 0,
heat = 1,
eco = 2,
}),
}),
tuya.dp_frost_protection(10, {}),                                      -- profile 미포함
tuya.dp_current_heating_setpoint(16, { scale = 10 }),
tuya.dp_min_temperature_limit(18, { scale = 10 }),                     -- profile 미포함
tuya.dp_max_temperature_limit(19, { scale = 10 }),                     -- profile 미포함
tuya.dp_local_temperature(24, { scale = 10 }),
tuya.dp_running_state(36, {
converter = converter.lookup_from_to({
idle = false,
heating = true,
}),
emit = emit.thermostat_operating_state(),
}),
tuya.dp_child_lock(40, {}),
tuya.dp_raw(65, { name = "schedule_monday" }),                         -- profile 미포함
tuya.dp_raw(66, { name = "schedule_tuesday" }),                        -- profile 미포함
tuya.dp_raw(67, { name = "schedule_wednesday" }),                      -- profile 미포함
tuya.dp_raw(68, { name = "schedule_thursday" }),                       -- profile 미포함
tuya.dp_raw(69, { name = "schedule_friday" }),                         -- profile 미포함
tuya.dp_raw(70, { name = "schedule_saturday" }),                       -- profile 미포함
tuya.dp_raw(71, { name = "schedule_sunday" }),                         -- profile 미포함
tuya.dp_battery(107, { emit = emit.battery() }),
tuya.dp_local_temperature_calibration(109, { scale = 10 }),
tuya.dp_deadzone_temperature(112, { scale = 10 }),                      -- profile 미포함
tuya.dp_eco_temperature(116, { scale = 10 }),                           -- profile 미포함
}
register_device_definition(thermostat_bot_r9v, ef00_helpers.ts0601_fingerprints( {
"_TZE204_wc2w9t1s",
}))
local thermostat_bot_r15w = {
profile = "thermostats-thermostat-battery-bot-r15w",
tuya.dp_binary(1, {
name = "system_mode",
converter = converter.lookup_from_to({
heat = true,
off = false,
}),
emit = emit.thermostat_mode(),
}),
tuya.dp_current_heating_setpoint(2, { scale = 10 }),
tuya.dp_local_temperature(3, { scale = 10 }),
tuya.dp_enum(4, {
name = "preset",
converter = converter.lookup_from_to({
heat = 0,
auto = 1,
mixed = 2,
away = 3,
}),
}),
tuya.dp_child_lock(9, {}),
tuya.dp_max_temperature_limit(15, { scale = 10 }),                      -- profile 미포함
tuya.dp_local_temperature_calibration(19, { scale = 10 }),
tuya.dp_running_state(101, {
converter = converter.lookup_from_to({
idle = 0,
heating = 1,
}),
emit = emit.thermostat_operating_state(),
}),
tuya.dp_frost_protection(102, {}),                                      -- profile 미포함
tuya.dp_binary(103, { name = "factory_reset" }),                       -- profile 미포함
tuya.dp_deadzone_temperature(107, { name = "temperature_delta", scale = 10, emit = emit.tempDeltaBotRToTen() }),
tuya.dp_battery(113, { emit = emit.battery() }),
}
register_device_definition(thermostat_bot_r15w, ef00_helpers.ts0601_fingerprints( {
"_TZE284_agcxaw3f",
}))
local thermostat_te_1z = {
profile = "thermostats-thermostat",
tuya.dp_local_temperature(16, { scale = 10 }),
tuya.dp_current_heating_setpoint(50, { scale = 10 }),
tuya.dp_running_state(102, {
converter = converter.lookup_from_to({
idle = false,
heating = true,
}),
emit = emit.thermostat_operating_state(),
}),
tuya.dp_temperature(103, { name = "temperature_sensor", scale = 10 }),  -- profile 미포함
tuya.dp_binary(106, { name = "high_temperature_protection_state" }),    -- profile 미포함
tuya.dp_binary(107, { name = "low_temperature_protection_state" }),     -- profile 미포함
tuya.dp_local_temperature_calibration(109, { scale = 10 }),
tuya.dp_numeric(110, { name = "temperature_return_difference" }),       -- profile 미포함
tuya.dp_deadzone_temperature(111, { scale = 1 }),                       -- profile 미포함
tuya.dp_temperature(112, { name = "high_temperature_protection_setting" }), -- profile 미포함
tuya.dp_temperature(113, { name = "low_temperature_protection_setting" }), -- profile 미포함
tuya.dp_max_temperature_limit(114, { name = "max_temperature" }),       -- profile 미포함
tuya.dp_enum(116, { name = "sensor_mode" }),                            -- profile 미포함
tuya.dp_binary(125, {
name = "system_mode",
converter = converter.lookup_from_to({
heat = true,
off = false,
}),
emit = emit.thermostat_mode(),
}),
tuya.dp_enum(128, {
name = "preset",
converter = converter.lookup_from_to({
auto = 1,
heat = 0,
mixed = 3,
}),
}),
tuya.dp_child_lock(129, {}),
tuya.dp_raw(130, { name = "error_status" }),                            -- profile 미포함
}
register_device_definition(thermostat_te_1z, ef00_helpers.ts0601_fingerprints( {
"_TZE284_khah2lkr",
}))
local thermostat_pilot_wire = {
profile = "thermostats-thermostat-pilot-wire-no-operating",
tuya.dp_binary(1, {
name = "system_mode",
converter = converter.lookup_from_to({
heat = true,
off = false,
}),
emit = emit.thermostat_mode(),
}),
tuya.dp_enum(2, {
name = "preset",
converter = converter.lookup_from_to({
comfort = 0,
eco = 1,
antifrost = 2,
off = 3,
comfort_1 = 4,
comfort_2 = 5,
program = 6,
manual = 7,
}),
}),
tuya.dp_power(11, { name = "power", scale = 10 }),                      -- profile 미포함
tuya.dp_local_temperature(16, { scale = 10 }),
tuya.dp_enum(17, { name = "window" }),                                  -- profile 미포함
tuya.dp_local_temperature_calibration(19, { scale = 10 }),
tuya.dp_raw(20, { name = "fault" }),                                    -- profile 미포함
tuya.dp_binary(29, {
name = "window_detection",
converter = converter.lookup_from_to({ on = true, off = false }),
emit = emit.windowDetectionPilotWire(),
}),
tuya.dp_child_lock(39, {}),                                             -- profile 미포함
tuya.dp_current_heating_setpoint(50, { scale = 10 }),
tuya.dp_voltage(101, { name = "voltage", scale = 10 }),                 -- profile 미포함
tuya.dp_current(102, { name = "current", scale = 1000 }),               -- profile 미포함
tuya.dp_numeric(103, { name = "temperature_sensibility", scale = 10 }), -- profile 미포함
tuya.dp_energy(104, { name = "energy_today", scale = 10, emit = emit.energyTodayPilotWire() }),
tuya.dp_energy(105, { name = "energy_yesterday", scale = 10, emit = emit.energyYesterdayPilotWire() }),
tuya.dp_enum(106, { name = "device_mode_type" }),                       -- profile 미포함
tuya.dp_energy(107, { name = "energy", scale = 10 }),                   -- profile 미포함
}
register_device_definition(thermostat_pilot_wire, ef00_helpers.ts0601_fingerprints( {
"_TZE204_0hcjew5p",
"_TZE204_3regm3h6",
"_TZE204_6vwfjkcj",
"_TZE204_ouy7vpm1",
"_TZE284_3regm3h6",
"_TZE204_3q3maeoo",
"_TZE204_d6i25bwg",
}))
register_device_definition(thermostat_pilot_wire, {
device_helpers.create_fingerprint("THALEOS", "TH-P1Z"),
device_helpers.create_fingerprint("RKHK", "TH-P0Z"),
device_helpers.create_fingerprint("MAZDA", "MZTE1Z"),
})
local thermostat_pro_900z = {
profile = "thermostats-thermostat-pro900z",
tuya.dp_binary(1, {
name = "system_mode",
converter = converter.lookup_from_to({
off = false,
heat = true,
}),
emit = emit.thermostat_mode(),
}),
tuya.dp_enum(2, {
name = "preset",
converter = converter.lookup_from_to({
auto = 0,
heat = 1,
}),
}),
tuya.dp_current_heating_setpoint(16, { scale = 10 }),
tuya.dp_max_temperature_limit(19, { name = "max_temperature", scale = 10 }), -- profile 미포함
tuya.dp_local_temperature(24, { scale = 10 }),
tuya.dp_min_temperature_limit(26, { name = "min_temperature", scale = 10 }), -- profile 미포함
tuya.dp_local_temperature_calibration(27, { scale = 1 }),
tuya.dp_binary(28, { name = "factory_reset" }),                            -- profile 미포함
tuya.dp_running_state(36, {
converter = converter.lookup_from_to({
heat = 0,
idle = 1,
}),
emit = emit.thermostat_operating_state(),
}),
tuya.dp_child_lock(39, {}),
tuya.dp_binary(40, { name = "eco_mode" }),                                 -- profile 미포함
tuya.dp_temperature_sensor_select_internal_external_both(43, {
converter = converter.lookup_from_to({
["IN"] = 0,
["OU"] = 2,
["AL"] = 1,
}),
}),
tuya.dp_raw(101, { name = "schedule_monday" }),                            -- profile 미포함
tuya.dp_temperature(102, { name = "external_temperature_input", scale = 10 }), -- profile 미포함
tuya.dp_deadzone_temperature(103, { scale = 1 }),                           -- profile 미포함
tuya.dp_max_temperature_limit(104, { scale = 10 }),                         -- profile 미포함
tuya.dp_raw(105, { name = "schedule_tuesday" }),                           -- profile 미포함
tuya.dp_raw(106, { name = "schedule_wednesday" }),                         -- profile 미포함
tuya.dp_raw(107, { name = "schedule_thursday" }),                          -- profile 미포함
tuya.dp_raw(108, { name = "schedule_friday" }),                            -- profile 미포함
tuya.dp_raw(109, { name = "schedule_saturday" }),                          -- profile 미포함
tuya.dp_raw(110, { name = "schedule_sunday" }),                            -- profile 미포함
tuya.dp_min_temperature_limit(111, { scale = 10 }),                         -- profile 미포함
tuya.dp_eco_temperature(112, { scale = 10 }),                               -- profile 미포함
tuya.dp_numeric(113, { name = "brightness" }),                             -- profile 미포함
tuya.dp_numeric(114, { name = "display_brightness", emit = emit.displayBrightnessPro900zLevel8() }),
}
register_device_definition(thermostat_pro_900z, ef00_helpers.ts0601_fingerprints( {
"_TZE204_tagezcph",
}))
local tv02_setpoint = tuya.dp_current_heating_setpoint(16, {
scale = 10,
emit = emit.heating_setpoint("C"),
})
return device_definitions
