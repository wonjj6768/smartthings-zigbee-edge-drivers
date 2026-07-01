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
local thermostat_bac003 = {
profile = "thermostats-fcu-thermostat-no-operating",
named_mapping = {
named_mappings = {
system_mode = bac003_system_mode_write,
current_heating_setpoint = bac003_setpoint,
fan_mode = bac003_fan_mode,
},
},
tuya.dp_binary(1, {
name = "state",
from_device = bac003_state_from_device,
emit = emit.thermostat_mode(),
}),
tuya.dp_system_mode(2, {
from_device = bac003_mode_from_device,
emit = emit.thermostat_mode(),
read_only = true,
}),
tuya.dp_binary(4, { name = "preset" }),
bac003_setpoint,
tuya.dp_numeric(19, { name = "max_temperature" }),
tuya.dp_local_temperature(24, {
scale = 10,
emit = emit.temperature("C"),
}),
tuya.dp_deadzone_temperature(26, { scale = 1 }),
tuya.dp_local_temperature_calibration(27, { scale = 1 }),
bac003_fan_mode,
tuya.dp_child_lock(40, {}),
}
register_device_definition(thermostat_bac003, ef00_helpers.ts0601_fingerprints( {
"_TZE200_dzuqwsyg",
"_TZE204_dzuqwsyg",
}))
register_device_definition(thermostat_bac003, {
device_helpers.create_fingerprint("Tuya", "BAC-003"),
})
local l2_fan_mode = tuya.dp_fan_mode(49, {
converter = converter.lookup_from_to({
auto = 0,
high = 1,
medium = 2,
low = 3,
}),
emit = emit.fan_mode(),
})
local thermostat_l2_t_f_mf = {
profile = "thermostats-fcu-thermostat-l2-t-f-mf",
tuya.dp_on_off(1, { name = "state" }),                                  -- profile 미포함
tuya.dp_system_mode(2, {
converter = converter.lookup_from_to({
cool = 0,
heat = 1,
fanonly = 2,
}),
emit = emit.thermostat_mode(),
}),
tuya.dp_local_temperature(16, { scale = 10, emit = emit.temperature("C") }),
tuya.dp_min_temperature_limit(18, { scale = 10 }),                       -- profile 미포함
tuya.dp_max_temperature_limit(34, { scale = 10 }),                       -- profile 미포함
tuya.dp_child_lock(39, {}),
l2_fan_mode,
tuya.dp_current_heating_setpoint(50, { scale = 10 }),
tuya.dp_numeric(101, { name = "display_brightness", emit = emit.screenBrightnessL2TFMfLevel9() }),
tuya.dp_local_temperature_calibration(102, { scale = 1 }),
tuya.dp_deadzone_temperature(104, { scale = 10 }),                       -- profile 미포함
tuya.dp_eco_temperature(107, { name = "eco_temperature_heating" }),      -- profile 미포함
tuya.dp_eco_temperature(109, { name = "eco_temperature_cooling" }),      -- profile 미포함
}
register_device_definition(thermostat_l2_t_f_mf, ef00_helpers.ts0601_fingerprints( {
"_TZE284_4vbj3fxh",
}))
local ac_fan_mode = converter.lookup_from_to({
low = 0,
medium = 1,
high = 2,
auto = 3,
})
local ac_system_mode = converter.lookup_from_to({
cool = 0,
dryair = 1,
fanonly = 2,
})
local thermostat_aetz01_ac = {
profile = "thermostats-fcu-thermostat-no-operating",
tuya.dp_on_off(1, { name = "state" }),                                  -- profile 미포함
tuya.dp_current_heating_setpoint(2, { scale = 1 }),
tuya.dp_local_temperature(3, { scale = 1 }),
tuya.dp_system_mode(4, { converter = ac_system_mode }),
tuya.dp_fan_mode(5, { converter = ac_fan_mode, emit = emit.fan_mode() }),
tuya.dp_binary(25, { name = "sleep" }),                                 -- profile 미포함
tuya.dp_binary(30, { name = "swing_mode" }),                            -- profile 미포함
tuya.dp_binary(102, { name = "turbo" }),                                -- profile 미포함
tuya.dp_binary(103, { name = "quiet" }),                                -- profile 미포함
tuya.dp_power(116, { name = "power" }),                                 -- profile 미포함
tuya.dp_energy(117, { name = "energy" }),                               -- profile 미포함
}
register_device_definition(thermostat_aetz01_ac, ef00_helpers.ts0601_fingerprints( {
"_TZE200_snfdqllf",
}))
local thermostat_acmelec_vrv = {
profile = "thermostats-thermostat-mode-setpoint",
tuya.dp_binary(1, { name = "system_mode", converter = bool_heat_off }),
tuya.dp_current_heating_setpoint(16, { scale = 1 }),
tuya.dp_child_lock(40, { name = "child_lock" }),                        -- profile 미포함
}
register_device_definition(thermostat_acmelec_vrv, ef00_helpers.ts0601_fingerprints( {
"_TZE200_wem3gxyx",
"_TZE204_mul9abs3",
"_TZE284_mul9abs3",
}))
local xz_akt101_setpoint = tuya.dp_current_heating_setpoint(16, {
scale = 10,
emit = emit.heating_setpoint("C"),
})
local xz_akt101_fan_mode = tuya.dp_fan_mode(28, {
converter = converter.lookup_from_to({
low = 0,
medium = 1,
high = 2,
auto = 3,
}),
emit = emit.fan_mode(),
})
local thermostat_xz_akt101 = {
profile = "thermostats-fcu-thermostat-no-operating",
named_mapping = {
named_mappings = {
system_mode = xz_akt101_system_mode_write,
current_heating_setpoint = xz_akt101_setpoint,
fan_mode = xz_akt101_fan_mode,
},
},
tuya.dp_binary(1, {
name = "air_switch",
from_device = xz_akt101_state_from_device,
emit = emit.thermostat_mode(),
}),
tuya.dp_system_mode(2, {
from_device = xz_akt101_mode_from_device,
emit = emit.thermostat_mode(),
read_only = true,
}),
xz_akt101_setpoint,
tuya.dp_local_temperature(24, {
scale = 10,
emit = emit.temperature("C"),
}),
xz_akt101_fan_mode,
tuya.dp_child_lock(40, {}),
tuya.dp_numeric(101, {
name = "boost_time",
scale = 10,
}),
}
register_device_definition(thermostat_xz_akt101, ef00_helpers.ts0601_fingerprints( {
"_TZE200_1drr8tab",
}))
local thermostat_tybac006 = {
profile = "thermostats-fcu-thermostat-tybac006",
named_mapping = {
named_mappings = {
system_mode = power_mode_write(1, 2, {
cool = 0,
heat = 1,
fanonly = 2,
fan_only = 2,
}),
current_heating_setpoint = tybac_setpoint,
fan_mode = tybac_fan_mode,
},
},
tuya.dp_binary(1, {
name = "state",
from_device = power_mode_from_device(TYBAC_POWER_FIELD, TYBAC_MODE_FIELD, "cool"),
emit = emit.thermostat_mode(),
}),
tuya.dp_system_mode(2, {
from_device = enum_mode_from_device(TYBAC_POWER_FIELD, TYBAC_MODE_FIELD, {
[0] = "cool",
[1] = "heat",
[2] = "fanonly",
}),
emit = emit.thermostat_mode(),
read_only = true,
}),
tuya.dp_eco_mode(4, {}),                                               -- profile 미포함
tybac_setpoint,
tuya.dp_max_temperature_limit(19, { scale = 10, emit = emit.maxTempLimitTybacCToThirty() }),
tuya.dp_local_temperature(24, { scale = 10, emit = emit.temperature("C") }),
tuya.dp_min_temperature_limit(26, { scale = 10, emit = emit.minTempLimitTybacCToThirty() }),
tuya.dp_local_temperature_calibration(27, { scale = 1 }),              -- profile 미포함
tybac_fan_mode,
tuya.dp_binary(36, { name = "valve" }),                                -- profile 미포함
tuya.dp_child_lock(40, {}),                                            -- profile 미포함
tuya.dp_binary(101, {
name = "manual_mode",
converter = converter.lookup_from_to({ on = true, off = false }),
emit = emit.manualModeTybac006(),
}),
tuya.dp_deadzone_temperature(103, { scale = 1 }),                      -- profile 미포함
tuya.dp_min_temperature_limit(104, { name = "min_temperature_limit", scale = 10, emit = emit.minTempLimitTybacCToThirty() }),
tuya.dp_max_temperature_limit(105, { name = "max_temperature_limit", scale = 10, emit = emit.maxTempLimitTybacCToThirty() }),
}
register_device_definition(thermostat_tybac006, ef00_helpers.ts0601_fingerprints( {
"_TZE204_mpbki2zm",
}))
local hhst_fan_mode = tuya.dp_fan_mode(28, {
converter = converter.lookup_from_to({
auto = 0,
high = 1,
medium = 2,
low = 3,
off = 4,
}),
emit = emit.fan_mode(),
})
local hhst_setpoint = tuya.dp_current_heating_setpoint(16, {
scale = 10,
emit = emit.heating_setpoint("C"),
})
local thermostat_hhst001 = {
profile = "thermostats-fcu-thermostat-hhst001",
named_mapping = {
named_mappings = {
system_mode = power_mode_write(1, 2, {
cool = 0,
heat = 1,
fanonly = 2,
fan_only = 2,
}),
current_heating_setpoint = hhst_setpoint,
fan_mode = hhst_fan_mode,
},
},
tuya.dp_binary(1, {
name = "state",
from_device = power_mode_from_device(HHST_POWER_FIELD, HHST_MODE_FIELD, "cool"),
emit = emit.thermostat_mode(),
}),
tuya.dp_system_mode(2, {
from_device = enum_mode_from_device(HHST_POWER_FIELD, HHST_MODE_FIELD, {
[0] = "cool",
[1] = "heat",
[2] = "fanonly",
}),
emit = emit.thermostat_mode(),
read_only = true,
}),
hhst_setpoint,
tuya.dp_max_temperature_limit(19, { scale = 10 }),                     -- profile 미포함
tuya.dp_temperature(21, { name = "local_temperature_f" }),             -- profile 미포함
tuya.dp_local_temperature(24, { scale = 10, emit = emit.temperature("C") }),
tuya.dp_min_temperature_limit(26, { scale = 10 }),                     -- profile 미포함
hhst_fan_mode,
tuya.dp_child_lock(40, {}),                                            -- profile 미포함
tuya.dp_temperature_unit(46, {}),                                      -- profile 미포함
tuya.dp_binary(101, {
name = "manual_mode",
converter = converter.lookup_from_to({ auto = 0, manual = 1, temporary = 2 }),
emit = emit.manualModeHhstAutoManualTemp(),
}),
tuya.dp_local_temperature_calibration(102, { scale = 1 }),             -- profile 미포함
tuya.dp_deadzone_temperature(104, { scale = 1 }),                      -- profile 미포함
tuya.dp_humidity(113, {}),                                             -- profile 미포함
}
register_device_definition(thermostat_hhst001, ef00_helpers.ts0601_fingerprints( {
"_TZE204_q12rv9gj",
}))
return device_definitions
