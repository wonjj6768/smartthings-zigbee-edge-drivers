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
local function thaleos_thah202001_mode_from_device(value)
if tonumber(value) == 4 then
return "off"
end
return "heat"
end
local function thaleos_thah202001_mode_to_device(value)
if value == "off" then
return 4
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
local classic_trv = {
profile = "thermostats-thermostat",
tuya.dp_current_heating_setpoint(2, { scale = 10 }),
tuya.dp_local_temperature(3, { scale = 10 }),
tuya.dp_system_mode(106, {
converter = converter.lookup_from_to({
auto = 0,
heat = 1,
off = 2,
}),
}),
tuya.dp_running_state(109, {
from_device = valve_position_to_running_state,
}),
}
register_device_definition(classic_trv, ef00_helpers.ts0601_fingerprints( {
"_TZE200_ckud7u2l",
"_TZE200_ywdxldoj",
"_TZE200_do5qy8zo",
"_TZE200_cwnjrr72",
"_TZE200_pvvbommb",
"_TZE200_9sfg7gm0",
"_TZE200_2atgpdho",
"_TZE200_znlqjmih",
"_TZE284_znlqjmih",
"_TZE200_8thwkzxl",
"_TZE200_4eeyebrt",
"_TZE200_8whxpsiw",
"_TZE200_7fqkphoq",
"_TZE200_rufdtfyv",
"_TZE200_lpwgshtl",
"_TZE200_rk1wojce",
"_TZE200_rndg81sf",
"_TZE200_qjp4ynvi",
"_TZE200_xby0s3ta",
"_TZE200_cpmgn2cf",
}))
register_device_definition(classic_trv, {
device_helpers.create_fingerprint("Immax", "07732B"),
device_helpers.create_fingerprint("Immax", "07732L"),
device_helpers.create_fingerprint("Moes", "HY368"),
device_helpers.create_fingerprint("Moes", "HY369RT"),
device_helpers.create_fingerprint("SHOJZJ", "378RT"),
device_helpers.create_fingerprint("Silvercrest", "TVR01"),
device_helpers.create_fingerprint("Evolveo", "Heat M30"),
device_helpers.create_fingerprint("Emos", "P5630S"),
device_helpers.create_fingerprint("THALEOS", "HY368"),
})
local thermostat_hy607w = {
profile = "thermostats-thermostat",
tuya.dp_local_temperature(16, { scale = 10 }),
tuya.dp_current_heating_setpoint(50, { scale = 10 }),
tuya.dp_binary(125, { name = "system_mode", converter = bool_heat_off }),
tuya.dp_binary(102, { name = "running_state", converter = enum_heat_idle_bool }),
}
register_device_definition(thermostat_hy607w, ef00_helpers.ts0601_fingerprints( {
"_TZE200_khah2lkr",
}))
local thermostat_zg_wk_da = {
profile = "thermostats-thermostat-zg-wk-da",
tuya.dp_binary(1, { name = "system_mode", converter = bool_heat_off }),
tuya.dp_current_heating_setpoint(2, { scale = 10 }),
tuya.dp_local_temperature(3, { scale = 10 }),
tuya.dp_enum(4, {
name = "preset",
emit = emit.thermostatPresetZgWkDaAuto(),
converter = converter.lookup_from_to({
manual = 0,
auto = 1,
}),
}),
tuya.dp_child_lock(9, { name = "child_lock" }),                        -- profile 미포함
tuya.dp_local_temperature_calibration(19, { scale = 1 }),              -- profile 미포함
tuya.dp_enum(102, { name = "running_state", converter = enum_heat_idle_inverted }),
}
register_device_definition(thermostat_zg_wk_da, ef00_helpers.ts0601_fingerprints( {
"_TZE204_atdqo4nj",
}))
local thermostat_tgm50 = {
profile = "thermostats-thermostat-tgm50",
tuya.dp_binary(1, { name = "system_mode", converter = bool_heat_off }),
tuya.dp_current_heating_setpoint(2, { scale = 10 }),
tuya.dp_local_temperature(3, { scale = 10 }),
tuya.dp_child_lock(9, { name = "child_lock" }),                        -- profile 미포함
tuya.dp_max_temperature_limit(15, { scale = 10 }),                     -- profile 미포함
tuya.dp_local_temperature_calibration(19, { scale = 10 }),             -- profile 미포함
tuya.dp_frost_protection(102, {}),                                     -- profile 미포함
tuya.dp_binary(103, { name = "factory_reset" }),                       -- profile 미포함
tuya.dp_temperature(107, { name = "temperature_delta", scale = 10, emit = emit.tempDeltaTgmCToTen() }),
}
register_device_definition(thermostat_tgm50, ef00_helpers.ts0601_fingerprints( {
"_TZE204_cvub6xbb",
"_TZE284_cvub6xbb",
"_TZE204_mwomyz5n",
}))
local thermostat_po_thco = {
profile = "thermostats-thermostat-battery-no-operating",
tuya.dp_system_mode(1, { converter = converter.lookup_from_to({ auto = 0, heat = 1, off = 2 }) }),
tuya.dp_current_heating_setpoint(16, { scale = 2 }),
tuya.dp_local_temperature(24, { scale = 10 }),
tuya.dp_child_lock(30, { name = "child_lock" }),                       -- profile 미포함
tuya.dp_battery(34, { emit = emit.battery(), converter = converter.from_only(function(value) return math.max(0, math.min(100, (tonumber(value) or 50) - 50)) end) }),
tuya.dp_comfort_temperature(101, { scale = 2 }),                       -- profile 미포함
tuya.dp_eco_temperature(102, { scale = 2 }),                           -- profile 미포함
tuya.dp_holiday_temperature(103, { scale = 2 }),                       -- profile 미포함
tuya.dp_local_temperature_calibration(104, { scale = 10 }),            -- profile 미포함
tuya.dp_current_heating_setpoint(105, { name = "auto_temperature", scale = 2 }), -- profile 미포함
tuya.dp_boost_heating(106, {}),                                        -- profile 미포함
tuya.dp_open_window(107, {}),                                          -- profile 미포함
tuya.dp_open_window_temperature(116, { scale = 2 }),                   -- profile 미포함
tuya.dp_open_window_time(117, {}),                                     -- profile 미포함
tuya.dp_boost_time(118, {}),                                          -- profile 미포함
}
register_device_definition(thermostat_po_thco, ef00_helpers.ts0601_fingerprints( {
"_TZE204_tbgecldg",
"_TZE284_tbgecldg",
"_TZE200_tbgecldg",
}))
local thermostat_bab_1413 = {
profile = "thermostats-thermostat-battery-no-operating",
tuya.dp_system_mode(1, { converter = converter.lookup_from_to({ auto = 0, heat = 1, off = 2 }) }),
tuya.dp_current_heating_setpoint(4, { scale = 10 }),
tuya.dp_local_temperature(5, { scale = 10 }),
tuya.dp_battery(6, { emit = emit.battery() }),
tuya.dp_child_lock(7, { name = "child_lock" }),                        -- profile 미포함
tuya.dp_max_temperature_limit(9, { scale = 10 }),                      -- profile 미포함
tuya.dp_min_temperature_limit(10, { scale = 10 }),                     -- profile 미포함
tuya.dp_window_detection(14, {}),                                      -- profile 미포함
tuya.dp_open_window_temperature(16, { scale = 10 }),                   -- profile 미포함
tuya.dp_open_window_time(17, {}),                                      -- profile 미포함
tuya.dp_binary(19, { name = "factory_reset" }),                        -- profile 미포함
tuya.dp_holiday_temperature(21, { scale = 1 }),                        -- profile 미포함
tuya.dp_comfort_temperature(24, { scale = 10 }),                       -- profile 미포함
tuya.dp_eco_temperature(25, { scale = 10 }),                           -- profile 미포함
tuya.dp_frost_protection(36, {}),                                      -- profile 미포함
tuya.dp_valve_state(49, {}),                                           -- profile 미포함
}
register_device_definition(thermostat_bab_1413, ef00_helpers.ts0601_fingerprints( {
"_TZE204_g2ki0ejr",
}))
local thermostat_variant6 = {
profile = "thermostats-thermostat-battery-setpoint-temp",
tuya.dp_current_heating_setpoint(4, { scale = 10 }),
tuya.dp_local_temperature(5, { scale = 10 }),
tuya.dp_battery(6, { emit = emit.battery() }),
tuya.dp_child_lock(7, { name = "child_lock" }),                        -- profile 미포함
tuya.dp_window_detection(8, {}),                                       -- profile 미포함
tuya.dp_open_window(14, {}),                                           -- profile 미포함
tuya.dp_holiday_temperature(21, { scale = 1 }),                        -- profile 미포함
tuya.dp_comfort_temperature(24, { scale = 10 }),                       -- profile 미포함
tuya.dp_eco_temperature(25, { scale = 10 }),                           -- profile 미포함
tuya.dp_frost_protection(36, {}),                                      -- profile 미포함
tuya.dp_scale_protection(39, {}),                                      -- profile 미포함
tuya.dp_local_temperature_calibration(47, { scale = 10 }),             -- profile 미포함
tuya.dp_valve_state(49, {}),                                           -- profile 미포함
tuya.dp_boost_heating(101, {}),                                        -- profile 미포함
tuya.dp_boost_time(102, {}),                                          -- profile 미포함
}
register_device_definition(thermostat_variant6, ef00_helpers.ts0601_fingerprints( {
"_TZE284_cgr0rhza",
"_TZE284_ymldrmzx",
}))
local thermostat_trv603_minimal = {
profile = "thermostats-thermostat-battery-operating",
tuya.dp_enum(2, { name = "preset" }),                                  -- profile 미포함
tuya.dp_running_state(3, { converter = converter.lookup_from_to({ heating = 1, idle = 0 }) }),
tuya.dp_battery(6, { emit = emit.battery() }),
tuya.dp_child_lock(7, { name = "child_lock" }),                        -- profile 미포함
}
register_device_definition(thermostat_trv603_minimal, ef00_helpers.ts0601_fingerprints( {
"_TZE284_noixx2uz",
}))
local thermostat_zht_002 = {
profile = "thermostats-thermostat-zht002",
tuya.dp_binary(1, { name = "system_mode", converter = bool_heat_off }),
tuya.dp_local_temperature(16, { scale = 10 }),
tuya.dp_min_temperature_limit(18, { scale = 10 }),                     -- profile 미포함
tuya.dp_local_temperature_calibration(19, { scale = 10 }),             -- profile 미포함
tuya.dp_max_temperature_limit(34, { scale = 10 }),                     -- profile 미포함
tuya.dp_child_lock(39, { name = "child_lock" }),                       -- profile 미포함
tuya.dp_eco_mode(40, {}),                                              -- profile 미포함
tuya.dp_current_heating_setpoint(50, { scale = 10 }),
tuya.dp_enum(68, { name = "programming_mode" }),                       -- profile 미포함
tuya.dp_max_temperature_limit(101, { name = "max_temperature_limit", scale = 10, emit = emit.maxTempLimitZhtCToSeventy() }),
tuya.dp_deadzone_temperature(102, { scale = 10 }),                     -- profile 미포함
}
register_device_definition(thermostat_zht_002, ef00_helpers.ts0601_fingerprints( {
"_TZE204_xalsoe3m",
}))
local thermostat_variant1 = {
profile = "thermostats-thermostat",
tuya.dp_system_mode(1, {
from_device = thermostat_variant1_mode_from_device,
to_device = thermostat_variant1_mode_to_device,
}),
tuya.dp_current_heating_setpoint(2, { scale = 10 }),
tuya.dp_local_temperature(3, { scale = 10 }),
tuya.dp_running_state(6, {
converter = converter.lookup_from_to({
heating = 1,
idle = 0,
}),
}),
tuya.dp_battery(13, {}),
}
register_device_definition(thermostat_variant1, ef00_helpers.ts0601_fingerprints( {
"_TZE200_a4bpgplm",
"_TZE200_bvrlmajk",
"_TZE200_dv8abrrz",
"_TZE200_z1tyspqw",
}))
register_device_definition(thermostat_variant1, {
device_helpers.create_fingerprint("id3", "GTZ06"),
})
register_device_definition(thermostat_variant1, {
device_helpers.create_fingerprint("AVATTO", "TRV07"),
})
local thermostat_variant3 = {
profile = "thermostats-thermostat",
tuya.dp_system_mode(2, {
converter = converter.lookup_from_to({
auto = 0,
heat = 1,
off = 2,
}),
}),
tuya.dp_running_state(3, {
from_device = thermostat_variant3_running_state,
}),
tuya.dp_current_heating_setpoint(4, { scale = 10 }),
tuya.dp_local_temperature(5, { scale = 10 }),
}
register_device_definition(thermostat_variant3, ef00_helpers.ts0601_fingerprints( {
"_TZE200_bvu2wnxz",
"_TZE200_6rdj8dzm",
"_TZE200_9xfjixap",
"_TZE200_jkfbph7l",
"_TZE200_rxntag7i",
"_TZE200_4utwozi2",
"_TZE200_yqgbrdyo",
"_TZE284_p3dbf6qs",
"_TZE200_rxq4iti9",
"_TZE204_ogx8u5z6",
"_TZE200_4utwoz2",
"_TZE284_ogx8u5z6",
"_TZE284_o3x45p96",
"_TZE284_c6wv4xyo",
"_TZE204_o3x45p96",
"_TZE200_ow09xlxm",
"_TZE284_rv6iuyxb",
"_TZE200_rv6iuyxb",
"_TZE200_suxywabt",
"_TZE200_d3z1ukqw",
}))
register_device_definition(thermostat_variant3, {
device_helpers.create_fingerprint("AVATTO", "ME167"),
device_helpers.create_fingerprint("AVATTO", "ME168_1"),
device_helpers.create_fingerprint("AVATTO", "AVATTO_TRV06"),
device_helpers.create_fingerprint("AVATTO", "TRV06_1"),
device_helpers.create_fingerprint("EARU", "TRV06"),
device_helpers.create_fingerprint("THALEOS", "TRV06-AT"),
device_helpers.create_fingerprint("Echos", "Eco-4160"),
})
local thermostat_thaleos_thah202001 = {
profile = "thermostats-thermostat-battery",
tuya.dp_system_mode(2, {
from_device = thaleos_thah202001_mode_from_device,
to_device = thaleos_thah202001_mode_to_device,
}),
tuya.dp_running_state(3, {
converter = converter.lookup_from_to({
heating = 0,
idle = 1,
}),
}),
tuya.dp_current_heating_setpoint(4, { scale = 10 }),
tuya.dp_local_temperature(5, { scale = 10 }),
tuya.dp_battery(6, {}),
tuya.dp_binary(14, { name = "window_detection" }),                     -- profile 미포함
tuya.dp_enum(15, { name = "window_open" }),                            -- profile 미포함
tuya.dp_holiday_temperature(21, { scale = 10 }),                       -- profile 미포함
tuya.dp_eco_temperature(24, { scale = 10 }),                            -- profile 미포함
tuya.dp_numeric(25, { name = "away_temperature", scale = 10 }),        -- profile 미포함
tuya.dp_raw(35, { name = "error_or_battery_low" }),                    -- profile 미포함
tuya.dp_binary(36, { name = "frost_protection" }),                     -- profile 미포함
tuya.dp_binary(39, { name = "scale_protection" }),                     -- profile 미포함
tuya.dp_local_temperature_calibration(47, { scale = 10 }),             -- profile 미포함
tuya.dp_numeric(101, { name = "operating_time", scale = 10 }),         -- profile 미포함
tuya.dp_numeric(102, { name = "scale_protection_remaining_time", scale = 10 }), -- profile 미포함
}
register_device_definition(thermostat_thaleos_thah202001, ef00_helpers.ts0601_fingerprints( {
"_TZE204_m5r5nlxc",
}))
local thermostat_variant5 = {
profile = "thermostats-thermostat",
tuya.dp_system_mode(2, {
converter = converter.lookup_from_to({
auto = 0,
heat = 1,
off = 2,
}),
}),
tuya.dp_running_state(3, {
from_device = thermostat_variant3_running_state,
}),
tuya.dp_current_heating_setpoint(4, { scale = 10 }),
tuya.dp_local_temperature(5, { scale = 10 }),
}
register_device_definition(thermostat_variant5, ef00_helpers.ts0601_fingerprints( {
"_TZE200_p3dbf6qs",
"_TZE200_hvaxb2tc",
}))
register_device_definition(thermostat_variant5, {
device_helpers.create_fingerprint("AVATTO", "ME167_1"),
device_helpers.create_fingerprint("AVATTO", "TRV06_1b"),
})
local thermostat_variant2 = {
profile = "thermostats-thermostat-basic",
tuya.dp_system_mode(1, {
converter = converter.lookup_from_to({
heat = true,
off = false,
}),
}),
tuya.dp_current_heating_setpoint(16, { scale = 10 }),
tuya.dp_local_temperature(24, { scale = 10 }),
}
register_device_definition(thermostat_variant2, ef00_helpers.ts0601_fingerprints( {
"_TZE200_0hg58wyk",
}))
register_device_definition(thermostat_variant2, {
device_helpers.create_fingerprint("S366", "Cloud Even"),
})
local thermostat_variant4 = {
profile = "thermostats-thermostat-battery-no-operating",
tuya.dp_system_mode(49, {
converter = converter.lookup_from_to({
off = 0,
heat = 1,
}),
}),
tuya.dp_current_heating_setpoint(4, { scale = 10 }),
tuya.dp_local_temperature(5, { scale = 10 }),
tuya.dp_battery(6, {}),
}
register_device_definition(thermostat_variant4, ef00_helpers.ts0601_fingerprints( {
"_TZE204_pcdmj88b",
"_TZE284_pcdmj88b",
}))
local thermostat_variant14 = {
profile = "thermostats-thermostat-battery",
tuya.dp_system_mode(2, {
from_device = thermostat_variant14_mode_from_preset,
to_device = thermostat_variant14_mode_to_preset,
}),
tuya.dp_running_state(3, {
converter = converter.lookup_from_to({
heat = 1,
idle = 0,
}),
}),
tuya.dp_current_heating_setpoint(4, { scale = 10 }),
tuya.dp_local_temperature(5, { scale = 10 }),
tuya.dp_battery(6, {}),
}
register_device_definition(thermostat_variant14, ef00_helpers.ts0601_fingerprints( {
"_TZE204_vjpaih9f",
"_TZE284_vjpaih9f",
}))
local thermostat_gtz10 = {
profile = "thermostats-thermostat-battery",
tuya.dp_system_mode(2, {
from_device = thermostat_gtz10_mode_from_device,
to_device = thermostat_gtz10_mode_to_device,
}),
tuya.dp_running_state(49, {
from_device = valve_position_to_running_state,
}),
tuya.dp_current_heating_setpoint(4, { scale = 10 }),
tuya.dp_local_temperature(5, { scale = 10 }),
tuya.dp_battery(6, {}),
}
register_device_definition(thermostat_gtz10, ef00_helpers.ts0601_fingerprints( {
"_TZE200_pbo8cj0z",
"_TZE200_eo6xhfbo",
}))
local thermostat_tr_m3z = {
profile = "thermostats-thermostat-battery",
tuya.dp_system_mode(101, {
converter = converter.lookup_from_to({
off = false,
heat = true,
}),
}),
tuya.dp_running_state(3, {
converter = converter.lookup_from_to({
heat = 1,
idle = 0,
}),
}),
tuya.dp_current_heating_setpoint(4, { scale = 10 }),
tuya.dp_local_temperature(5, { scale = 10 }),
tuya.dp_battery(6, {}),
}
register_device_definition(thermostat_tr_m3z, ef00_helpers.ts0601_fingerprints( {
"_TZE204_eekpf0ft",
"_TZE284_eekpf0ft",
}))
local thermostat_tv02 = {
profile = "thermostats-thermostat-tv02",
named_mapping = {
named_mappings = {
system_mode = tv02_system_mode_write,
current_heating_setpoint = tv02_setpoint,
},
},
tuya.dp_system_mode(2, {
from_device = tv02_preset_mode_from_device,
emit = emit.thermostat_mode(),
read_only = true,
}),
tuya.dp_open_window(8, {}),
tuya.dp_frost_protection(10, {}),
tv02_setpoint,
tuya.dp_local_temperature(24, {
scale = 10,
emit = emit.temperature("C"),
}),
tuya.dp_local_temperature_calibration(27, { scale = 10 }),
tuya.dp_enum(31, {
name = "working_day",
converter = converter.lookup_from_to({
mon_sun = 0,
mon_fri_sat_sun = 1,
separate = 2,
}),
emit = emit.workingDayTv02ScheduleMode(),
}),
tuya.dp_holiday_temperature(32, { scale = 10 }),
tuya.dp_binary(35, {
name = "battery_low",
converter = converter.bool_pair(false, true),
}),
tuya.dp_child_lock(40, {}),
tuya.dp_raw(45, { name = "error_status" }),
tuya.dp_raw(46, { name = "holiday_start_stop" }),
tuya.dp_numeric(101, { name = "boost_timeset_countdown" }),
tuya.dp_open_window_temperature(102, { scale = 10 }),
tuya.dp_comfort_temperature(104, { scale = 10 }),
tuya.dp_eco_temperature(105, { scale = 10 }),
tuya.dp_raw(106, { name = "schedule" }),
tuya.dp_binary(107, {
name = "system_mode",
from_device = tv02_system_mode_from_device,
emit = emit.thermostat_mode(),
read_only = true,
}),
tuya.dp_raw(108, { name = "schedule_monday" }),
tuya.dp_raw(109, { name = "schedule_wednesday" }),
tuya.dp_raw(110, { name = "schedule_friday" }),
tuya.dp_raw(111, { name = "schedule_sunday" }),
tuya.dp_raw(112, { name = "schedule_tuesday" }),
tuya.dp_raw(113, { name = "schedule_thursday" }),
tuya.dp_raw(114, { name = "schedule_saturday" }),
tuya.dp_binary(115, { name = "online" }),
}
register_device_definition(thermostat_tv02, ef00_helpers.ts0601_fingerprints( {
"_TZE200_sur6q7ko",
"_TZE200_hue3yfsn",
"_TZE200_e9ba97vf",
"_TZE200_husqqvux",
"_TZE200_lnbfnyxd",
"_TZE200_fsow0qsk",
"_TZE200_lllliz3p",
"_TZE200_mudxchsu",
"_TZE200_7yoranx2",
"_TZE200_kds0pmmv",
"_TZE200_py4cm3he",
"_TZE200_wsbfwodu",
"_TZE200_x9axofse",
"_TZE200_lhzapfg9",
"_TZE200_k1tumq4t",
}))
register_device_definition(thermostat_tv02, {
device_helpers.create_fingerprint("Moes", "TV01-ZB"),
device_helpers.create_fingerprint("AVATTO", "TRV06-1"),
device_helpers.create_fingerprint("Tesla Smart", "TSL-TRV-TV01ZG"),
device_helpers.create_fingerprint("Tesla Smart", "TSL-TRV-TV05ZG"),
device_helpers.create_fingerprint("Unknown/id3.pl", "GTZ08"),
device_helpers.create_fingerprint("Moes", "ZTRV-ZX-TV01-MS"),
device_helpers.create_fingerprint("AlecoAir", "HA-08_THERMO"),
device_helpers.create_fingerprint("GIEX", "TV06"),
device_helpers.create_fingerprint("Moes", "ZTRV-ZX-TV02"),
device_helpers.create_fingerprint("EKF", "ETT-8"),
})
local thermostat_trv60x = {
profile = "thermostats-thermostat-battery",
tuya.dp_system_mode(1, {
from_device = thermostat_variant1_mode_from_device,
to_device = thermostat_variant1_mode_to_device,
}),
tuya.dp_current_heating_setpoint(2, { scale = 10 }),
tuya.dp_local_temperature(3, { scale = 10 }),
tuya.dp_running_state(6, {
converter = converter.lookup_from_to({
heating = 1,
idle = 0,
}),
}),
tuya.dp_battery(13, {}),
}
register_device_definition(thermostat_trv60x, ef00_helpers.ts0601_fingerprints( {
"_TZE204_rtrmfadk",
"_TZE204_cvcu2p6e",
"_TZE204_9mjy74mp",
"_TZE200_rtrmfadk",
"_TZE200_9mjy74mp",
"_TZE204_qyr2m29i",
"_TZE204_ltwbm23f",
"_TZE284_ltwbm23f",
}))
register_device_definition(thermostat_trv60x, {
device_helpers.create_fingerprint("Sber", "SBDV-00185"),
device_helpers.create_fingerprint("Moes", "TRV801"),
device_helpers.create_fingerprint("Moes", "TRV801_1"),
device_helpers.create_fingerprint("Moes", "TRV801Z"),
})
local thermostat_ar331pro = {
profile = "thermostats-thermostat-battery-ar331pro",
tuya.dp_enum(2, {
name = "preset",
emit = emit.thermostatPresetAr331proSixMode(),
converter = converter.lookup_from_to({
auto = 0,
manual = 1,
holiday = 2,
eco = 3,
comfort = 4,
standby = 5,
}),
}),
tuya.dp_running_state(3, {
converter = converter.lookup_from_to({
heating = 0,
idle = 1,
}),
emit = emit.thermostat_operating_state(),
}),
tuya.dp_current_heating_setpoint(4, { scale = 10 }),
tuya.dp_local_temperature(5, { scale = 10 }),
tuya.dp_battery(6, { emit = emit.battery() }),
tuya.dp_child_lock(7, {
emit = emit.childLock(),
converter = converter.lookup_from_to({
on = false,
off = true,
}),
}),
tuya.dp_local_temperature_calibration(47, { scale = 10 }),
tuya.dp_binary(49, { name = "valve_state" }),                         -- profile 미포함
tuya.dp_eco_temperature(103, { scale = 10 }),                          -- profile 미포함
}
register_device_definition(thermostat_ar331pro, ef00_helpers.ts0601_fingerprints( {
"_TZE284_nbv4tdaz",
}))
return device_definitions
