local tuya = require "tuya_common"
local emit = require "emitters"
local device_helpers = require "devices.shared.helpers"
local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()
local function window_shade_state_from_position()
return converter.from_only(function(value)
local number_value = tonumber(value)
if number_value == nil then
return nil
end
if number_value <= 0 then
return "closed"
end
if number_value >= 100 then
return "open"
end
return "partially open"
end)
end
local function window_shade_state_from_position_inverted()
return converter.from_only(function(value)
local number_value = tonumber(value)
if number_value == nil then
return nil
end
number_value = 100 - number_value
if number_value <= 0 then
return "closed"
end
if number_value >= 100 then
return "open"
end
return "partially open"
end)
end
local cover_state_standard = converter.lookup_from_to({
open = 0,
stop = 1,
close = 2,
})
local cover_state_open_close_stop = converter.lookup_from_to({
open = 0,
close = 1,
stop = 2,
})
local cover_state_reversed = converter.lookup_from_to({
open = 2,
stop = 1,
close = 0,
})
local cover_state_open_close_stop_reversed = converter.lookup_from_to({
open = 1,
close = 0,
stop = 2,
})
local cover_state_alt_controls = converter.lookup_from_to({
open = 2,
stop = 0,
close = 1,
})
local cover_with_1_switch = {
profile = "covers-cover-switch-1",
tuya.dp_enum(1, {
name = "cover_state",
converter = cover_state_standard,
write_only = true,
}),
tuya.dp_cover_position(2, { emit = emit.shade_level() }),
tuya.dp_numeric(2, {
name = "window_shade_state",
emit = emit.shade_state(),
converter = window_shade_state_from_position(),
read_only = true,
}),
tuya.dp_on_off(101, {
name = "switch",
component = "switch2",
}),
}
local cover_with_2_switch = {
profile = "covers-cover-switch-2",
tuya.dp_enum(1, {
name = "cover_state",
converter = cover_state_standard,
write_only = true,
}),
tuya.dp_cover_position(2, { emit = emit.shade_level() }),
tuya.dp_numeric(2, {
name = "window_shade_state",
emit = emit.shade_state(),
converter = window_shade_state_from_position(),
read_only = true,
}),
tuya.dp_on_off(101, {
name = "switch",
component = "switch2",
}),
tuya.dp_on_off(102, {
name = "switch",
component = "switch3",
}),
}
local cover_switch_2_touch_panel = {
profile = "covers-cover-switch-2",
datapoints = {
tuya.dp_enum(1, {
name = "cover_state",
converter = cover_state_standard,
write_only = true,
}),
tuya.dp_cover_position(2, { emit = emit.shade_level() }),
tuya.dp_numeric(2, {
name = "window_shade_state",
emit = emit.shade_state(),
converter = window_shade_state_from_position(),
read_only = true,
}),
tuya.dp_enum(3, {
name = "calibration",
converter = converter.lookup_from_to({
START = 0,
END = 1,
}),
}),                                                                 -- profile 미포함
tuya.dp_backlight_mode_off_on(7, {}),                                -- profile 미포함
tuya.dp_enum(8, {
name = "motor_steering",
converter = converter.lookup_from_to({
FORWARD = 0,
BACKWARD = 1,
}),
}),                                                                 -- profile 미포함
tuya.dp_child_lock(102, { name = "child_lock" }),                    -- profile 미포함
tuya.dp_on_off(108, { name = "switch", component = "switch2" }),
tuya.dp_on_off(107, { name = "switch", component = "switch3" }),
},
query_on_configure = true,
}
local cover_core = {
tuya.dp_enum(1, {
name = "cover_state",
converter = cover_state_standard,
write_only = true,
}),
tuya.dp_cover_position(2, { emit = emit.shade_level() }),
tuya.dp_numeric(2, {
name = "window_shade_state",
emit = emit.shade_state(),
converter = window_shade_state_from_position(),
read_only = true,
}),
}
local cover_core_position_reversed = {
tuya.dp_enum(1, {
name = "cover_state",
converter = cover_state_standard,
write_only = true,
}),
tuya.dp_cover_position_inverted(2, { emit = emit.shade_level() }),
tuya.dp_numeric(2, {
name = "window_shade_state",
emit = emit.shade_state(),
converter = window_shade_state_from_position_inverted(),
read_only = true,
}),
}
local cover_core_reversed_position_alt = {
tuya.dp_enum(1, {
name = "cover_state",
converter = cover_state_standard,
write_only = true,
}),
tuya.dp_cover_position_inverted(8, { emit = emit.shade_level() }),
tuya.dp_numeric(8, {
name = "window_shade_state",
emit = emit.shade_state(),
converter = window_shade_state_from_position_inverted(),
read_only = true,
}),
}
local cover_core_alt_dp = {
tuya.dp_enum(2, {
name = "cover_state",
converter = cover_state_standard,
write_only = true,
}),
tuya.dp_cover_position(7, { emit = emit.shade_level() }),
tuya.dp_numeric(7, {
name = "window_shade_state",
emit = emit.shade_state(),
converter = window_shade_state_from_position(),
read_only = true,
}),
}
local cover_core_alt_position_8 = {
tuya.dp_enum(1, {
name = "cover_state",
converter = cover_state_standard,
write_only = true,
}),
tuya.dp_cover_position(8, { emit = emit.shade_level() }),
tuya.dp_numeric(8, {
name = "window_shade_state",
emit = emit.shade_state(),
converter = window_shade_state_from_position(),
read_only = true,
}),
}
local cover_model_zsm01 = {
profile = "covers-cover",
tuya.dp_enum(1, {
name = "cover_state",
converter = cover_state_standard,
write_only = true,
}),
tuya.dp_cover_position(9, { write_only = true }),
tuya.dp_numeric(8, {
name = "cover_position_state",
emit = emit.shade_level(),
read_only = true,
}),
tuya.dp_numeric(8, {
name = "window_shade_state",
emit = emit.shade_state(),
converter = window_shade_state_from_position(),
read_only = true,
}),
tuya.dp_enum(11, { name = "control_back_mode" }),                       -- profile 미포함
tuya.dp_cover_position(19, { name = "position_best" }),                  -- profile 미포함
tuya.dp_enum(20, { name = "click_control" }),                            -- profile 미포함
}
local cover_core_alt_controls = {
tuya.dp_enum(1, {
name = "cover_state",
converter = cover_state_alt_controls,
write_only = true,
}),
tuya.dp_cover_position(2, { emit = emit.shade_level() }),
tuya.dp_numeric(2, {
name = "window_shade_state",
emit = emit.shade_state(),
converter = window_shade_state_from_position(),
read_only = true,
}),
}
local cover_zb_sm = {
profile = "covers-cover-zb-sm",
tuya.dp_enum(1, {
name = "cover_state",
converter = cover_state_standard,
write_only = true,
}),
tuya.dp_cover_position(2, { emit = emit.shade_level() }),
tuya.dp_numeric(2, {
name = "window_shade_state",
emit = emit.shade_state(),
converter = window_shade_state_from_position(),
read_only = true,
}),
tuya.dp_numeric(3, { name = "arrived_position" }),                      -- profile 미포함
tuya.dp_enum(5, {
name = "motor_direction",
emit = emit.motorDirectionZbSmNormalRev(),
converter = converter.lookup_from_to({ normal = 0, reversed = 1 }),
}),
tuya.dp_numeric(10, { name = "cycle_time" }),                           -- profile 미포함
tuya.dp_enum(101, { name = "motor_type" }),                             -- profile 미포함
tuya.dp_numeric(102, { name = "cycle_count" }),                         -- profile 미포함
tuya.dp_enum(103, { name = "bottom_limit" }),                           -- profile 미포함
tuya.dp_enum(104, { name = "top_limit" }),                              -- profile 미포함
tuya.dp_numeric(109, { name = "active_power" }),                        -- profile 미포함
tuya.dp_cover_position(115, { name = "favorite_position", emit = emit.favoritePositionZbSm() }),
tuya.dp_enum(121, { name = "motor_state" }),                            -- profile 미포함
}
local cover_core_reversed = {
tuya.dp_enum(1, {
name = "cover_state",
converter = cover_state_reversed,
write_only = true,
}),
tuya.dp_cover_position(2, { emit = emit.shade_level() }),
tuya.dp_numeric(2, {
name = "window_shade_state",
emit = emit.shade_state(),
converter = window_shade_state_from_position(),
read_only = true,
}),
}
local cover_core_am02 = {
tuya.dp_enum(1, {
name = "cover_state",
converter = cover_state_standard,
write_only = true,
}),
tuya.dp_cover_position(2, {
write_only = true,
}),
tuya.dp_numeric(3, {
name = "cover_position_state",
emit = emit.shade_level(),
read_only = true,
}),
tuya.dp_numeric(3, {
name = "window_shade_state",
emit = emit.shade_state(),
converter = window_shade_state_from_position(),
read_only = true,
}),
}
local cover_core_pims3028 = {
profile = "covers-cover-pims3028",
tuya.dp_enum(1, {
name = "cover_state",
converter = converter.lookup_from_to({
open = 0,
stop = 1,
close = 2,
lock = 3,
unlock = 4,
}),
write_only = true,
}),
tuya.dp_cover_position(2, { emit = emit.shade_level() }),
tuya.dp_numeric(2, {
name = "window_shade_state",
emit = emit.shade_state(),
converter = window_shade_state_from_position(),
read_only = true,
}),
tuya.dp_cover_position_inverted(3, { name = "position_inverted" }),      -- profile 미포함
tuya.dp_enum(4, { name = "mode" }),                                      -- profile 미포함
tuya.dp_enum(5, { name = "control_back" }),                              -- profile 미포함
tuya.dp_binary(6, { name = "auto_power" }),                              -- profile 미포함
tuya.dp_enum(7, {
name = "work_state",
emit = emit.coverWorkPimsActual(),
converter = converter.from_only(converter.lookup_value({
[0] = "opening",
[1] = "closing",
[2] = "value_123",
})),
}),
tuya.dp_numeric(10, { name = "time_total" }),                            -- profile 미포함
tuya.dp_enum(11, { name = "situation_set" }),                            -- profile 미포함
tuya.dp_binary(12, { name = "fault" }),                                  -- profile 미포함
tuya.dp_enum(16, { name = "border" }),                                   -- profile 미포함
tuya.dp_cover_position(19, { name = "position_best" }),                  -- profile 미포함
tuya.dp_numeric(21, { name = "angle_horizontal" }),                      -- profile 미포함
tuya.dp_enum(101, {
name = "calibration",
emit = emit.coverCalibrationPims3028StartEnd(),
converter = converter.lookup_from_to({
start = 0,
["end"] = 1,
}),
}),
tuya.dp_numeric(102, { name = "quick_calibration" }),                    -- profile 미포함
tuya.dp_binary(103, { name = "best_position_trigger" }),                 -- profile 미포함
tuya.dp_enum(104, { name = "reset" }),                                   -- profile 미포함
}
local cover_rm28_le = {
profile = "covers-cover-battery-rm28-le",
tuya.dp_enum(1, {
name = "cover_state",
converter = cover_state_standard,
write_only = true,
}),
tuya.dp_cover_position(2, { emit = emit.shade_level() }),
tuya.dp_numeric(2, {
name = "window_shade_state",
emit = emit.shade_state(),
converter = window_shade_state_from_position(),
read_only = true,
}),
tuya.dp_numeric(3, { name = "position_report", emit = emit.coverPositionReportRm28Le() }),
tuya.dp_enum(5, {
name = "reverse_direction",
converter = converter.lookup_from_to({
forward = 0,
back = 1,
}),
}),                                                                       -- profile 미포함
tuya.dp_enum(7, {
name = "work_state",
emit = emit.coverWorkRmOpeningClosing(),
converter = converter.from_only(converter.lookup_value({
[0] = "closing",
[1] = "opening",
})),
}),
tuya.dp_binary(12, { name = "motor_fault" }),                            -- profile 미포함
tuya.dp_battery(13, { emit = emit.battery() }),
tuya.dp_enum(16, { name = "border" }),                                   -- profile 미포함
tuya.dp_enum(20, { name = "click_control" }),                            -- profile 미포함
}
local cover_model_zm79e_dt = {
profile = "covers-cover-zm79e-dt",
tuya.dp_enum(1, {
name = "cover_state",
converter = cover_state_reversed,
write_only = true,
}),
tuya.dp_cover_position_inverted(2, { emit = emit.shade_level() }),
tuya.dp_numeric(2, {
name = "window_shade_state",
emit = emit.shade_state(),
converter = window_shade_state_from_position_inverted(),
read_only = true,
}),
tuya.dp_cover_position_inverted(3, { name = "position_report", emit = emit.coverPositionReportZm79eDt() }),
tuya.dp_enum(4, { name = "opening_mode" }),                              -- profile 미포함
tuya.dp_enum(7, {
name = "work_state",
emit = emit.coverWorkStateZm79eDtLearning(),
converter = converter.from_only(converter.lookup_value({
[0] = "standby",
[1] = "success",
[2] = "learning",
})),
}),
tuya.dp_enum(101, {
name = "motor_direction",
emit = emit.motorDirectionZm79eDtLeftRight(),
converter = converter.lookup_from_to({
left = 0,
right = 1,
}),
}),
tuya.dp_enum(102, { name = "set_upper_limit" }),                         -- profile 미포함
tuya.dp_enum(107, { name = "factory_reset" }),                           -- profile 미포함
}
local cover_model_bx82_tyz1 = {
profile = "covers-cover-bx82-tyz1",
tuya.dp_enum(1, {
name = "cover_state",
converter = cover_state_reversed,
write_only = true,
}),
tuya.dp_cover_position(2, { emit = emit.shade_level() }),
tuya.dp_numeric(2, {
name = "window_shade_state",
emit = emit.shade_state(),
converter = window_shade_state_from_position(),
read_only = true,
}),
tuya.dp_numeric(3, { name = "position_report", emit = emit.coverPositionReportBx82Tyz1() }),
tuya.dp_enum(5, {
name = "motor_direction",
emit = emit.motorDirectionBxTyzNormalRev(),
converter = converter.lookup_from_to({ normal = 0, reversed = 1 }),
}),
}
local cover_model_mb60l = {
profile = "covers-cover-battery-mb60l",
tuya.dp_enum(1, {
name = "cover_state",
converter = cover_state_standard,
write_only = true,
}),
tuya.dp_cover_position_inverted(9, { emit = emit.shade_level() }),
tuya.dp_numeric(9, {
name = "window_shade_state",
emit = emit.shade_state(),
converter = window_shade_state_from_position_inverted(),
read_only = true,
}),
tuya.dp_enum(11, {
name = "motor_direction",
emit = emit.motorDirectionMbNormalRev(),
converter = converter.lookup_from_to({ normal = 0, reversed = 1 }),
}),
tuya.dp_battery(13, { emit = emit.battery() }),
tuya.dp_enum(16, { name = "set_limits" }),                               -- profile 미포함
tuya.dp_binary(108, {
name = "tilt_mode",
emit = emit.tiltModeMb60l(),
converter = converter.lookup_from_to({ on = true, off = false }),
}),
tuya.dp_binary(109, { name = "child_lock" }),                            -- profile 미포함
}
local cover_epj_zb = {
profile = "covers-cover-battery-epj-zb",
tuya.dp_enum(102, {
name = "cover_state",
converter = cover_state_open_close_stop,
command_id = tuya.SEND_DATA,
write_only = true,
}),
tuya.dp_cover_position(104, {
command_id = tuya.SEND_DATA,
emit = emit.shade_level(),
}),
tuya.dp_numeric(104, {
name = "window_shade_state",
emit = emit.shade_state(),
converter = window_shade_state_from_position(),
read_only = true,
}),
tuya.dp_battery(4, { emit = emit.battery() }),
tuya.dp_binary(105, { name = "charge_state" }),
tuya.dp_enum(106, {
name = "manual_mode",
emit = emit.manualModeEpjZbEnableDisable(),
converter = converter.lookup_from_to({
enable = 0,
disable = 1,
}),
}),
tuya.dp_enum(107, {
name = "fault",
converter = converter.lookup_from_to({
Normal = 0,
None = 1,
Fault = 2,
}),
}),
tuya.dp_numeric(108, { name = "countdown" }),
tuya.dp_enum(109, {
name = "motor_direction",
emit = emit.motorDirectionEpjZbSide(),
converter = converter.lookup_from_to({
right_side = 0,
left_side = 1,
}),
}),
tuya.dp_enum(110, {
name = "mode",
converter = converter.lookup_from_to({
Disable = 0,
Enable = 1,
}),
}),
tuya.dp_enum(112, {
name = "fixed_window_sash",
converter = converter.lookup_from_to({
Down = 0,
Up = 1,
}),
}),
tuya.dp_enum(114, {
name = "window_detection",
emit = emit.windowDetectionEpjZbState(),
converter = converter.lookup_from_to({
opened = 0,
closed = 1,
pending = 2,
}),
}),
}
local ts0301_cover_single = {
profile = "covers-cover",
tuya.dp_enum(1, {
name = "cover_state",
converter = cover_state_standard,
write_only = true,
}),
tuya.dp_cover_position(2, {
write_only = true,
}),
tuya.dp_numeric(3, {
name = "cover_position_state",
emit = emit.shade_level(),
read_only = true,
}),
tuya.dp_numeric(3, {
name = "window_shade_state",
emit = emit.shade_state(),
converter = window_shade_state_from_position(),
read_only = true,
}),
}
local ts0301_cover_dual_rail = {
profile = "covers-cover-2",
tuya.dp_enum(109, {
name = "cover_state",
component = "main",
converter = cover_state_open_close_stop,
write_only = true,
}),
tuya.dp_cover_position_inverted(101, {
component = "main",
write_only = true,
}),
tuya.dp_numeric(102, {
name = "cover_position_state",
component = "main",
emit = emit.shade_level(),
converter = converter.cover_position_inverted(),
read_only = true,
}),
tuya.dp_numeric(102, {
name = "window_shade_state",
component = "main",
emit = emit.shade_state(),
converter = window_shade_state_from_position_inverted(),
read_only = true,
}),
tuya.dp_enum(1, {
name = "cover_state",
component = "shade2",
converter = cover_state_open_close_stop_reversed,
write_only = true,
}),
tuya.dp_cover_position(2, {
component = "shade2",
write_only = true,
}),
tuya.dp_numeric(3, {
name = "cover_position_state",
component = "shade2",
emit = emit.shade_level(),
read_only = true,
}),
tuya.dp_numeric(3, {
name = "window_shade_state",
component = "shade2",
emit = emit.shade_state(),
converter = window_shade_state_from_position(),
read_only = true,
}),
}
register_device_definition(cover_core, device_helpers.create_fingerprints("TS0601", {
"_TZE200_bqcqqjpb",
"_TZE200_gaj531w3",
"_TZE284_gaj531w3",
"_TZE200_en3wvcbx",
"_TZE200_g5wdnuow",
"_TZE200_udank5zs",
"_TZE200_nv6nxo0c",
"_TZE200_3ylew7b4",
"_TZE200_llm0epxg",
"_TZE200_n1aauwb4",
"_TZE200_bjzrowv2",
"_TZE204_bjzrowv2",
"_TZE284_bjzrowv2",
"_TZE204_guvc7pdy",
"_TZE204_57hjqelq",
"_TZE204_vvvtcehj",
"_TZE200_axgvo9jh",
"_TZE200_zxxfv8wi",
"_TZE204_lh3arisb",
"_TZE204_zuq5xxib",
"_TZE200_nueqqe6k",
"_TZE200_1fuxihti",
"_TZE204_1fuxihti",
"_TZE284_1fuxihti",
"_TZE200_5zbp6j0u",
"_TZE200_nkoabg8w",
"_TZE200_4vobcgd3",
"_TZE284_4vobcgd3",
"_TZE200_pk0sfzvr",
"_TZE200_m6lwazh9",
"_TZE200_swlgvdlh",
"_TZE200_fdtjuw7u",
"_TZE200_rmymn92d",
"_TZE200_feolm6rk",
"_TZE200_tvrvdj6o",
"_TZE200_b2u1drdv",
"_TZE200_ol5jlkkr",
"_TZE204_a2jcoyuk",
"_TZE200_yia0p3tr",
"_TZE200_rsj5pu8y",
"_TZE200_yrugsphv",
"_TZE204_yrugsphv",
"_TZE200_odlldrxx",
"_TZE204_odlldrxx",
"_TZE200_7shyddj3",
"_TZE284_udank5zs",
"_TZE284_b7kbnl6q",
"_TZE204_wzre8hu2",
"_TZE204_dpqsvdbi",
"_TZE204_ic7jtutb",
"_TZE204_m1wl5fvq",
"_TZE204_nladmfvf",
"_TZE204_tgl8i2np",
"_TZE200_2jwrgrro",
}))
register_device_definition(cover_core, {
device_helpers.create_fingerprint("HOBEIAN", "ZG-301Z-MOTO"),
{ manufacturer = "_TYST11_fzo2pocs", model = "zo2pocs" .. string.char(0) },
{ manufacturer = "_TYST11_udank5zs", model = "dank5zs" .. string.char(0) },
})
register_device_definition({
profile = "covers-cover",
datapoints = cover_core,
}, device_helpers.create_fingerprints("TS0601", {
"_TZE200_1fuxihti",
"_TZE204_1fuxihti",
"_TZE284_1fuxihti",
"_TZE200_5zbp6j0u",
"_TZE200_nkoabg8w",
"_TZE200_4vobcgd3",
"_TZE284_4vobcgd3",
"_TZE200_pk0sfzvr",
"_TZE200_m6lwazh9",
"_TZE200_swlgvdlh",
"_TZE200_fdtjuw7u",
"_TZE200_rmymn92d",
"_TZE200_feolm6rk",
"_TZE200_tvrvdj6o",
"_TZE200_b2u1drdv",
"_TZE200_ol5jlkkr",
}))
register_device_definition(cover_core, {
device_helpers.create_fingerprint("Yushun", "YS-MT750"),
device_helpers.create_fingerprint("Yushun", "YS-MT750L"),
device_helpers.create_fingerprint("Zemismart", "ZM79E-DT"),
device_helpers.create_fingerprint("Binthen", "BCM100D"),
device_helpers.create_fingerprint("Binthen", "CV01A"),
device_helpers.create_fingerprint("Zemismart", "M515EGB"),
device_helpers.create_fingerprint("Oz Smart Things", "ZM85EL-1Z"),
device_helpers.create_fingerprint("Tuya", "M515EGZT"),
device_helpers.create_fingerprint("Tuya", "DT82LEMA-1.2N"),
device_helpers.create_fingerprint("Tuya", "ZD82TN"),
device_helpers.create_fingerprint("Larkkey", "ZSTY-SM-1SRZG-EU"),
device_helpers.create_fingerprint("Zemismart", "AM43"),
device_helpers.create_fingerprint("A-OK", "AM25"),
device_helpers.create_fingerprint("Alutech", "AM/R-Sm"),
device_helpers.create_fingerprint("Roximo", "CRTZ01"),
device_helpers.create_fingerprint("Quoya", "AT8510-TY"),
device_helpers.create_fingerprint("Somgoms", "ZSTY-SM-1DMZG-US-W_1"),
device_helpers.create_fingerprint("HUARUI", "CMD900LE"),
device_helpers.create_fingerprint("Novato", "WPK"),
device_helpers.create_fingerprint("Zemismart", "ZMS1-TYZ"),
})
register_device_definition(cover_core, device_helpers.create_fingerprints("TS0601", {
"_TZE200_eegnwoyw",
}))
register_device_definition(cover_core, device_helpers.create_fingerprints("TS0105", {
"_TZE600_ogyg1y6b",
}))
register_device_definition(cover_core, device_helpers.create_fingerprints("TS0601", {
"_TZE200_68nvbio9",
"_TZE200_pw7mji0l",
"_TZE200_cf1sl3tj",
"_TZE200_nw1r9hp6",
"_TZE200_9p5xmj5r",
"_TZE200_eevqq1uv",
"_TZE204_ejh6owwz",
"_TZE200_ba69l9ol",
"_TZE200_68nvbi09",
"_TZE200_vexa5o82",
"_TZE200_sfqyhvpv",
}))
register_device_definition(cover_core, {
device_helpers.create_fingerprint("Zemismart", "ZM16EL-03/33"),
device_helpers.create_fingerprint("Zemismart", "ZM25EL"),
device_helpers.create_fingerprint("Zemismart", "ZM85EL-2Z"),
device_helpers.create_fingerprint("Hiladuo", "B09M3R35GC"),
device_helpers.create_fingerprint("Tuya", "MYQ-RM25-1.3/25-BZ"),
device_helpers.create_fingerprint("Shaman", "25EB-1/30-TYZ"),
})
register_device_definition(cover_core, device_helpers.create_fingerprints("TS0601", {
"_TZE200_zah67ekd",
"_TZE200_icka1clh",
}))
register_device_definition(cover_core, {
device_helpers.create_fingerprint("Moes", "AM43-0.45/40-ES-EB"),
})
register_device_definition(cover_core, device_helpers.create_fingerprints("TS0601", {
"_TZE200_5sbebbzs",
"_TZE200_hsgrhjpf",
"_TZE200_ergbiejo",
"_TZE200_nhyj64w2",
"_TZE200_127x7wnl",
"_TZE204_5slehgeo",
"_TZE284_5slehgeo",
"_TZE200_fctwhugx",
"_TZE200_p6vz3wzt",
"_TZE204_p6vz3wzt",
"_TZE284_uqfph8ah",
"_TZE284_waa352qv",
}))
register_device_definition(cover_core, {
device_helpers.create_fingerprint("Homeetec", "37022483"),
})
register_device_definition(cover_core_position_reversed, device_helpers.create_fingerprints("TS0601", {
"_TZE200_cpbo62rn",
"_TZE200_libht6ua",
"_TZE284_libht6ua",
}))
register_device_definition(cover_core, device_helpers.create_fingerprints("TS0601", {
"_TZE200_zvo63cmo",
}))
register_device_definition(cover_core_position_reversed, device_helpers.create_fingerprints("TS0601", {
"_TZE204_r0jdjrvi",
"_TZE200_r0jdjrvi",
"_TZE200_g5xqosu7",
"_TZE204_g5xqosu7",
"_TZE200_fzo2pocs",
"_TZE284_fzo2pocs",
"_TZE200_9vpe3fl1",
"_TZE28C1000000_alh14edn",
}))
register_device_definition(cover_core_position_reversed, {
device_helpers.create_fingerprint("Tuya", "TS0601_alh14edn"),
})
register_device_definition(cover_core, device_helpers.create_fingerprints("TS0601", {
"_TZE200_7eue9vhc",
"_TZE200_bv1jcqqu",
"_TZE200_wehza30a",
}))
register_device_definition(cover_core, device_helpers.create_fingerprints("TS0601", {
"_TZE200_p2qzzazi",
}))
register_device_definition(cover_core_position_reversed, device_helpers.create_fingerprints("TS0601", {
"_TZE204_xu4a5rhj",
"_TZE200_xu4a5rhj",
"_TZE204_q9xty0ad",
}))
register_device_definition(cover_core, device_helpers.create_fingerprints("TS0601", {
"_TZE200_1vxgqfba",
"_TZE200_wdfurkoa",
"_TZE200_sq6affpe",
"_TZE284_wdfurkoa",
"_TZE284_6fopvb6v",
}))
register_device_definition(cover_core, device_helpers.create_fingerprints("TS0601", {
"_TZE200_gubdgai2",
"_TZE200_vdiuwbkq",
}))
register_device_definition(cover_core, device_helpers.create_fingerprints("TS0601", {
"_TZE200_yenbr4om",
"_TZE204_bdblidq3",
"_TZE200_bdblidq3",
}))
register_device_definition(cover_core, device_helpers.create_fingerprints("TS0601", {
"_TZE200_mlglxwp3",
}))
register_device_definition(cover_core_alt_dp, device_helpers.create_fingerprints("TS0601", {
"_TZE200_a8z0g46u",
"_TZE204_a8z0g46u",
}))
register_device_definition(cover_core_alt_position_8, device_helpers.create_fingerprints("TS0601", {
"_TZE284_3mzb0sdz",
}))
register_device_definition(cover_model_zsm01, device_helpers.create_fingerprints("TS0601", {
"_TZE284_zofmmt9s",
}))
register_device_definition(cover_core_position_reversed, device_helpers.create_fingerprints("TS0601", {
"_TZE200_2odrmqwq",
"_TZE200_hojryzzd",
}))
register_device_definition(cover_core_reversed, device_helpers.create_fingerprints("TS0601", {
"_TZE200_clm4gdw4",
"_TZE200_2vfxweng",
"_TZE200_gnw1rril",
"_TZE204_ycke4deo",
"_TZE284_koxaopnk",
"_TZE284_clm4gdw4",
}))
register_device_definition(cover_core_reversed, device_helpers.create_fingerprints("TS0601", {
"_TZE200_cowvfni3",
}))
register_device_definition(cover_core_alt_controls, device_helpers.create_fingerprints("TS0601", {
"_TZE200_rddyvrci",
}))
register_device_definition(cover_core_reversed_position_alt, device_helpers.create_fingerprints("TS0601", {
"_TZE284_r3szw0xr",
}))
register_device_definition(cover_core_position_reversed, device_helpers.create_fingerprints("TS0601", {
"_TZE200_wmcdj3aq",
"_TZE200_xuzcvlku",
"_TZE200_xaabybja",
"_TZE200_zuz7f94z",
"_TZE200_3i3exuay",
"_TZE200_nogaemzt",
"_TZE200_dng9fn0k",
"_TZE200_zpzndjez",
}))
register_device_definition(cover_with_1_switch, device_helpers.create_fingerprints("TS0601", {
"_TZE200_jhkttplm",
}))
register_device_definition(cover_with_1_switch, {
device_helpers.create_fingerprint("Homeetec", "37022493"),
})
register_device_definition(cover_with_2_switch, device_helpers.create_fingerprints("TS0601", {
"_TZE200_5nldle7w",
}))
register_device_definition(cover_with_2_switch, {
device_helpers.create_fingerprint("Homeetec", "37022173"),
})
register_device_definition(cover_switch_2_touch_panel, device_helpers.create_fingerprints("TS0601", {
"_TZE204_trwaxi57",
}))
register_device_definition(cover_core_am02, device_helpers.create_fingerprints("TS0601", {
"_TZE200_iossyxra",
"_TZE200_cxu0jkjk",
}))
register_device_definition(cover_core_pims3028, device_helpers.create_fingerprints("TS0601", {
"_TZE200_eqpaxqdv",
}))
register_device_definition(cover_rm28_le, device_helpers.create_fingerprints("TS0601", {
"_TZE200_fodv6bkr",
}))
register_device_definition(cover_epj_zb, {
device_helpers.create_fingerprint("_TZ3210_emqmwtym", "TS0601"),
})
register_device_definition(cover_model_zm79e_dt, device_helpers.create_fingerprints("TS0601", {
"_TZE200_ax8a8ahx",
}))
register_device_definition(cover_model_bx82_tyz1, device_helpers.create_fingerprints("TS0601", {
"_TZE204_2rvvqjoa",
}))
register_device_definition(cover_model_mb60l, device_helpers.create_fingerprints("TS0601", {
"_TZE284_2gi1hy8s",
}))
register_device_definition(cover_zb_sm, device_helpers.create_fingerprints("TS0601", {
"_TZE200_zyrdrmno",
"_TZE200_osmxri8y",
}))
register_device_definition(ts0301_cover_single, device_helpers.create_fingerprints("TS0301", {
"_TZE210_m6lwazh9",
"_TZE200_eatmkx5j",
}))
register_device_definition(ts0301_cover_single, {
device_helpers.create_fingerprint("Yoolax", "Day-Night Shade"),
})
register_device_definition(ts0301_cover_dual_rail, device_helpers.create_fingerprints("TS0301", {
"_TZE210_inpjmc0h",
"_TZE210_yqwse3h5",
}))
return device_definitions
