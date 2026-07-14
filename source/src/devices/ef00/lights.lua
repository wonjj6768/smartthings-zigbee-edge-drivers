-- 디머/조명 디바이스 정의
-- ZHA ts0601_dimmer.py + Z2M zigbee-herdsman-converters 기반 DP 그룹핑
--
-- 현재는 단일/2채널 EF00 디머/조명을 우선 지원합니다.
-- fan/light 복합형은 devices.ef00.fans에서 별도 family로 처리합니다.

local tuya = require "tuya_common"
local emit = require "emitters"
local device_helpers = require "devices.shared.helpers"
local ef00_helpers = require "devices.ef00.helpers"

local device_definitions, register_device_definition = device_helpers.definition_registry()

-- Z2M TS0601_dimmer_1_gang_1 contract, narrowed by exact hardware reports.
local dimmer_model_ts0601_la2c2uo9 = {
  profile = "lights-dimmer-options-ts0601-la2c2uo9",
  tuya.dp_on_off(1, { name = "switch", emit = emit.switch() }),
  tuya.dp_brightness(2, { name = "brightness", emit = emit.level() }),
  tuya.dp_min_brightness(3, { name = "min_brightness", value_max = 1000, emit = emit.ef00Ts0601MinimumBrightness() }),
  tuya.dp_light_type(4, { name = "light_type", emit = emit.light_type() }),
  tuya.dp_countdown(6, { name = "countdown_timer", emit = emit.countdownTsOneTenHours() }),
  tuya.dp_power_on_behavior(14, { emit = emit.power_on_behavior() }),
  tuya.dp_backlight_mode(21, { name = "la2c2uo9_backlight_mode", emit = emit.la2c2uo9BacklightMode() }),
}

register_device_definition(dimmer_model_ts0601_la2c2uo9, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_la2c2uo9",
}))

-- Z2M maps countdown to DP6, but this exact ignores it on reported hardware.
-- Keep it hidden until a DP log confirms a working mapping; do not guess an alternate DP.
local dimmer_model_ts0601_dfxkcots = {
  profile = "lights-dimmer-options-ts0601-dfxkcots",
  tuya.dp_on_off(1, { name = "switch", emit = emit.switch() }),
  tuya.dp_brightness(2, { name = "brightness", emit = emit.level() }),
  tuya.dp_min_brightness(3, { name = "min_brightness", value_max = 1000, emit = emit.ef00Ts0601MinimumBrightness() }),
  tuya.dp_light_type(4, { name = "light_type", emit = emit.light_type() }),
  tuya.dp_power_on_behavior(14, { emit = emit.power_on_behavior() }),
}

register_device_definition(dimmer_model_ts0601_dfxkcots, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_dfxkcots",
}))

-- TS0601_dimmer_1_gang_1
local dimmer_model_ts0601_dimmer_1_gang_1 = {
  profile = "lights-dimmer-options-ts0601",
  presence_capability_ranges = {
    indicator_mode = { allowed_values = ef00_helpers.capability_values({ "off", "on" }) },
  },
  tuya.dp_on_off(1, { name = "switch", emit = emit.switch() }),
  tuya.dp_brightness(2, { name = "brightness", emit = emit.level() }),
  tuya.dp_min_brightness(3, { name = "min_brightness", value_max = 1000, emit = emit.ef00Ts0601MinimumBrightness() }),
  tuya.dp_light_type(4, { name = "light_type", emit = emit.light_type() }),
  tuya.dp_max_brightness(5, { name = "max_brightness", value_max = 1000, emit = emit.ef00Ts0601MaximumBrightness() }),
  tuya.dp_countdown(6, { name = "countdown_timer", emit = emit.countdownTsOneTenHours() }),
  tuya.dp_power_on_behavior(14, { emit = emit.power_on_behavior() }),
  tuya.dp_backlight_mode_off_on(21, { name = "indicator_mode", emit = emit.indicator_mode() }),
}

register_device_definition(dimmer_model_ts0601_dimmer_1_gang_1, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_ip2akl4w",
  "_TZE200_1agwnems",
  "_TZE200_579lguh2",
  "_TZE200_vucankjx",
  "_TZE200_4mh6tyyo",
  "_TZE204_hlx9tnzb",
  "_TZE204_n9ctkb6j",
  "_TZE204_9qhuzgo0",
  "_TZE200_9cxuhakf",
  "_TZE200_a0syesf5",
  "_TZE200_3p5ydos3",
  "_TZE200_swaamsoy",
  "_TZE200_ojzhk75b",
  "_TZE200_w4cryh2i",
  "_TZE204_68utemio",
  "_TZE200_9i9dt8is",
  "_TZE200_ctq0k47x",
  "_TZE200_ebwgzdqq",
  "_TZE204_vevc4c6g",
  "_TZE200_0nauxa0p",
  "_TZE200_ykgar0ow",
  "_TZE284_m1cvyneb",
  "_TZE200_0hb4rdnp",
  "_TZE200_gne0e6mk",
  "_TZE200_itp8dt7f",
  "_TZE284_68utemio",
}))

register_device_definition(dimmer_model_ts0601_dimmer_1_gang_1, {
  device_helpers.create_fingerprint("Lerlink", "X706U"),
  device_helpers.create_fingerprint("Moes", "ZS-EUD_1gang"),
  device_helpers.create_fingerprint("Larkkey", "ZSTY-SM-1DMZG-EU"),
  device_helpers.create_fingerprint("Earda", "EDM-1ZAA-EU"),
  device_helpers.create_fingerprint("Earda", "EDM-1ZAB-EU"),
  device_helpers.create_fingerprint("Earda", "EDM-1ZBA-EU"),
  device_helpers.create_fingerprint("Mercator Ikuü", "SSWD01"),
  device_helpers.create_fingerprint("Moes", "ZS-USD"),
  device_helpers.create_fingerprint("Lonsonho", "EDM-1ZBB-EU"),
  device_helpers.create_fingerprint("Moes", "EDM-1ZBB-EU"),
  device_helpers.create_fingerprint("Moes", "ZS-SR-EUD-1"),
  device_helpers.create_fingerprint("Moes", "MS-105Z"),
  device_helpers.create_fingerprint("Mercator Ikuü", "SSWM-DIMZ"),
  device_helpers.create_fingerprint("Zemismart", "ZN2S-US1-SD"),
  device_helpers.create_fingerprint("Mercator Ikuü", "SSWRM-ZB"),
  device_helpers.create_fingerprint("ION Industries", "ID200W-ZIGB"),
  device_helpers.create_fingerprint("ION Industries", "90.500.090"),
  device_helpers.create_fingerprint("ION Industries", "90.500.040"),
})

-- TS0601_dimmer_1_gang_2
local dimmer_model_ts0601_dimmer_1_gang_2 = {
  tuya.dp_on_off(1, { name = "switch", emit = emit.switch() }),
  tuya.dp_brightness(3, { name = "brightness", emit = emit.level() }),
  tuya.dp_light_type(4, { name = "light_type" }),                          -- 프로파일 미포함
  tuya.dp_max_brightness(5, { name = "max_brightness" }),                  -- 프로파일 미포함
  tuya.dp_countdown(6, { name = "countdown" }),                            -- 프로파일 미포함
  tuya.dp_power_on_behavior(14, {}),                                       -- 프로파일 미포함
  tuya.dp_backlight_mode_off_on(21, { name = "backlight_mode" }),          -- 프로파일 미포함
}

register_device_definition(dimmer_model_ts0601_dimmer_1_gang_2, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_whpb9yts",
}))

-- TS0601_dimmer_1_gang_3
local dimmer_model_ts0601_dimmer_1_gang_3 = {
  tuya.dp_backlight_mode_off_on(16, { name = "backlight_mode" }),          -- 프로파일 미포함
  tuya.dp_current(21, { emit = emit.current() }),
  tuya.dp_power(22, { emit = emit.power() }),
  tuya.dp_voltage(23, { emit = emit.voltage() }),
  tuya.dp_child_lock(101, { name = "child_lock" }),                        -- 프로파일 미포함
  tuya.dp_on_off(141, { name = "switch", emit = emit.switch() }),
  tuya.dp_brightness(142, { name = "brightness", emit = emit.level() }),
}

register_device_definition(dimmer_model_ts0601_dimmer_1_gang_3, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_qzaing2g",
}))

-- TS0601_dimmer_4
local dimmer_model_ts0601_dimmer_2_gang = {
  profile = "lights-dimmer-2",
  tuya.dp_on_off(1, { name = "switch", component = "main", emit = emit.switch() }),
  tuya.dp_brightness(2, { name = "brightness", component = "main", emit = emit.level() }),
  tuya.dp_min_brightness(3, { name = "min_brightness", component = "main" }),           -- 프로파일 미포함
  tuya.dp_light_type(4, { name = "light_type", component = "main" }),                   -- 프로파일 미포함
  tuya.dp_max_brightness(5, { name = "max_brightness", component = "main" }),           -- 프로파일 미포함
  tuya.dp_countdown(6, { name = "countdown", component = "main" }),                     -- 프로파일 미포함
  tuya.dp_on_off(7, { name = "switch", component = "switch2", emit = emit.switch() }),
  tuya.dp_brightness(8, { name = "brightness", component = "switch2", emit = emit.level() }),
  tuya.dp_min_brightness(9, { name = "min_brightness", component = "switch2" }),        -- 프로파일 미포함
  tuya.dp_light_type(10, { name = "light_type", component = "switch2" }),               -- 프로파일 미포함
  tuya.dp_max_brightness(11, { name = "max_brightness", component = "switch2" }),       -- 프로파일 미포함
  tuya.dp_countdown(12, { name = "countdown", component = "switch2" }),                 -- 프로파일 미포함
  tuya.dp_power_on_behavior(14, {}),                                                     -- 프로파일 미포함
}

register_device_definition(dimmer_model_ts0601_dimmer_2_gang, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_bxoo2swd",
  "_TZE204_bxoo2swd",
  "_TZE200_tsxpl0d0",
  "_TZE200_fjjbhx9d",
  "_TZE200_e3oitdyu",
  "_TZE200_gwkapsoq",
  "_TZE204_zenj4lxv",
}))

register_device_definition(dimmer_model_ts0601_dimmer_2_gang, {
  device_helpers.create_fingerprint("Moes", "ZM-105B-M"),
  device_helpers.create_fingerprint("KnockautX", "FMD2C018"),
  device_helpers.create_fingerprint("Moes", "ZS-EUD_2gang"),
  device_helpers.create_fingerprint("Moes", "MS-105B"),
  device_helpers.create_fingerprint("Moes", "ZS-SR-EUD-2"),
})

-- TS0601_dimmer_3
local dimmer_model_ts0601_dimmer_3_gang = {
  profile = "lights-dimmer-3",
  tuya.dp_on_off(1, { name = "switch", component = "main", emit = emit.switch() }),
  tuya.dp_brightness(2, { name = "brightness", component = "main", emit = emit.level() }),
  tuya.dp_min_brightness(3, { name = "min_brightness", component = "main" }),           -- 프로파일 미포함
  tuya.dp_light_type(4, { name = "light_type", component = "main" }),                   -- 프로파일 미포함
  tuya.dp_max_brightness(5, { name = "max_brightness", component = "main" }),           -- 프로파일 미포함
  tuya.dp_countdown(6, { name = "countdown", component = "main" }),                     -- 프로파일 미포함
  tuya.dp_on_off(7, { name = "switch", component = "switch2", emit = emit.switch() }),
  tuya.dp_brightness(8, { name = "brightness", component = "switch2", emit = emit.level() }),
  tuya.dp_min_brightness(9, { name = "min_brightness", component = "switch2" }),        -- 프로파일 미포함
  tuya.dp_light_type(10, { name = "light_type", component = "switch2" }),               -- 프로파일 미포함
  tuya.dp_max_brightness(11, { name = "max_brightness", component = "switch2" }),       -- 프로파일 미포함
  tuya.dp_countdown(12, { name = "countdown", component = "switch2" }),                 -- 프로파일 미포함
  tuya.dp_power_on_behavior(14, {}),                                                     -- 프로파일 미포함
  tuya.dp_on_off(15, { name = "switch", component = "switch3", emit = emit.switch() }),
  tuya.dp_brightness(16, { name = "brightness", component = "switch3", emit = emit.level() }),
  tuya.dp_min_brightness(17, { name = "min_brightness", component = "switch3" }),       -- 프로파일 미포함
  tuya.dp_light_type(18, { name = "light_type", component = "switch3" }),               -- 프로파일 미포함
  tuya.dp_max_brightness(19, { name = "max_brightness", component = "switch3" }),       -- 프로파일 미포함
  tuya.dp_countdown(20, { name = "countdown", component = "switch3" }),                 -- 프로파일 미포함
  tuya.dp_backlight_mode(21, { name = "backlight_mode" }),                              -- 프로파일 미포함
  tuya.dp_enum(101, { name = "backlight_color" }),                                      -- 프로파일 미포함
  tuya.dp_numeric(103, { name = "backlight_brightness" }),                              -- 프로파일 미포함
}

register_device_definition(dimmer_model_ts0601_dimmer_3_gang, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_vm1gyrso",
  "_TZE204_1v1dxkck",
  "_TZE204_znvwzxkq",
  "_TZE284_znvwzxkq",
  "_TZE200_vizxbhco",
}))

register_device_definition(dimmer_model_ts0601_dimmer_3_gang, {
  device_helpers.create_fingerprint("Moes", "ZS-EUD_3gang"),
  device_helpers.create_fingerprint("Moes", "ZS-SR-EUD-3"),
  device_helpers.create_fingerprint("Zemismart", "ZN2S-RS3E-DH"),
})

-- TS0601_dimmer_5
local dimmer_model_ts0601_dimmer_1_gang_switch_type = {
  tuya.dp_on_off(1, { name = "switch", emit = emit.switch() }),
  tuya.dp_brightness(2, { name = "brightness", emit = emit.level() }),
  tuya.dp_min_brightness(3, { name = "min_brightness" }),                  -- 프로파일 미포함
  tuya.dp_light_type(4, { name = "light_type" }),                          -- 프로파일 미포함
  tuya.dp_max_brightness(5, { name = "max_brightness" }),                  -- 프로파일 미포함
  tuya.dp_countdown(6, { name = "countdown" }),                            -- 프로파일 미포함
  tuya.dp_power_on_behavior(14, {}),                                       -- 프로파일 미포함
  tuya.dp_switch_type(57, {}),                                             -- 프로파일 미포함
}

register_device_definition(dimmer_model_ts0601_dimmer_1_gang_switch_type, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_dcnsggvz",
  "_TZE200_dcnsggv",
  "_TZE200_dcnsggvz",
}))

register_device_definition(dimmer_model_ts0601_dimmer_1_gang_switch_type, {
  device_helpers.create_fingerprint("Moes", "MS-105-M"),
})

-- TS0601_dimmer_knob
local dimmer_model_ts0601_dimmer_knob = {
  tuya.dp_on_off(1, { name = "switch", emit = emit.switch() }),
  tuya.dp_brightness(2, { name = "brightness", emit = emit.level() }),
  tuya.dp_min_brightness(3, { name = "min_brightness" }),                  -- 프로파일 미포함
  tuya.dp_light_type(4, { name = "light_type" }),                          -- 프로파일 미포함
  tuya.dp_indicator_mode_none_relay_pos(21, { name = "indicator_mode" }),  -- 프로파일 미포함
}

register_device_definition(dimmer_model_ts0601_dimmer_knob, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_p0gzbqct",
}))

register_device_definition(dimmer_model_ts0601_dimmer_knob, {
  device_helpers.create_fingerprint("Moes", "WS-SY-EURD"),
  device_helpers.create_fingerprint("Moes", "WS-SY-EURD-WH-MS"),
})

-- TS0601_knob_dimmer_switch: dimmer knob with two light channels
local dimmer_model_ts0601_knob_dimmer_switch = {
  profile = "lights-color-temperature",
  tuya.dp_on_off(102, { name = "switch", emit = emit.switch() }),
  tuya.dp_brightness(103, { name = "brightness", emit = emit.level(), scale = 1000 }),
  tuya.dp_color_temperature(107, { name = "color_temperature", emit = emit.color_temperature(), scale = 1000 }),
  tuya.dp_enum(105, { name = "adjustment_mode" }),                       -- profile 미포함
  tuya.dp_power_on_behavior(106, {}),                                    -- profile 미포함
  tuya.dp_enum(111, { name = "action_1" }),                              -- profile 미포함
  tuya.dp_enum(112, { name = "action_2" }),                              -- profile 미포함
  tuya.dp_on_off(121, { name = "state_l1" }),                            -- profile 미포함
  tuya.dp_on_off(122, { name = "state_l2" }),                            -- profile 미포함
  tuya.dp_switch_mode(131, { name = "switch_mode_l1" }),                 -- profile 미포함
  tuya.dp_switch_mode(132, { name = "switch_mode_l2" }),                 -- profile 미포함
  tuya.dp_enum(141, { name = "mode" }),                                  -- profile 미포함
}

register_device_definition(dimmer_model_ts0601_knob_dimmer_switch, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_tgeqdjgk",
  "_TZE284_tgeqdjgk",
}))

-- TS0601_light
local light_model_ts0601_light = {
  tuya.dp_on_off(1, { name = "switch", emit = emit.switch() }),
  tuya.dp_power_on_behavior(2, {}),                                        -- 프로파일 미포함
  tuya.dp_brightness(3, { name = "brightness", emit = emit.level() }),
}

register_device_definition(light_model_ts0601_light, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_86nbew0j",
  "_TZE200_io0zdqh1",
  "_TZE200_drs6j6m5",
  "_TZE204_drs6j6m5",
  "_TZE200_ywe90lt0",
  "_TZE200_qyss8gjy",
}))

return device_definitions
