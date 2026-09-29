local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"

local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()

-- Z2M v26.99.0: Spacetronik ZB-DG02.
local gas_model_zb_dg02 = {
  profile = "safety-gas-detector-spacetronik-zb-dg02",
  query_on_configure = false,
  time_start = "off",
  tuya.dp_enum(1, {
    name = "gas",
    emit = emit.gas(),
    read_only = true,
    converter = converter.from_only(function(value)
      return type(value) == "number" and value == 0
    end),
  }),
}

register_device_definition(gas_model_zb_dg02, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_uc0iv1hb",
}))

-- Z2M v26.99.0: Nous E9.
local gas_model_nous_e9 = {
  profile = "safety-gas-nous-e9",
  query_on_configure = false,
  time_start = "off",
  initial_custom_state_query = false,
  refresh_state_query = false,
  tuya.dp_enum(1, {
    name = "gas",
    emit = emit.gas(),
    read_only = true,
    converter = converter.from_only(function(value)
      return type(value) == "number" and value == 0
    end),
  }),
  tuya.dp_binary(10, {
    name = "nous_e9_warming_up",
    emit = emit.nousE9WarmingUp(),
    read_only = true,
    converter = converter.from_only(function(value)
      return value == true and "on" or "off"
    end),
  }),
  tuya.dp_bitmap(11, {
    name = "fault",
    emit = emit.hardware_fault(),
    read_only = true,
    converter = converter.from_only(function(value)
      return (tonumber(value) or 0) ~= 0
    end),
  }),
  tuya.dp_binary(12, {
    name = "nous_e9_end_of_life",
    emit = emit.nousE9EndOfLife(),
    read_only = true,
    converter = converter.from_only(function(value)
      return value == false and "on" or "off"
    end),
  }),
}

register_device_definition(gas_model_nous_e9, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_qvxrkeif",
}))

-- Z2M v26.99.0: Moes ZC-HM / Heiman HS-720ES.
local co_model_moes_zc_hm = {
  profile = "safety-co-moes-zc-hm",
  query_on_configure = false,
  time_start = "off",
  initial_custom_state_query = false,
  refresh_state_query = false,
  tuya.dp_numeric(1, {
    name = "carbon_monoxide",
    emit = emit.carbon_monoxide(),
    read_only = true,
    converter = converter.from_only(function(value)
      return type(value) == "number" and value == 0
    end),
  }),
  tuya.dp_numeric(2, {
    name = "co",
    emit = emit.carbon_monoxide_level(),
    read_only = true,
  }),
  tuya.dp_numeric(9, {
    name = "moes_zc_hm_self_test_result",
    emit = emit.moesZcHmSelfTestResult(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "checking",
      [1] = "success",
      [2] = "failure",
      [3] = "others",
    })),
  }),
  tuya.dp_battery(15, {
    emit = emit.battery(),
    read_only = true,
  }),
  tuya.dp_binary(16, {
    name = "moes_zc_hm_silence",
    emit = emit.moesZcHmSilence(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
}

register_device_definition(co_model_moes_zc_hm, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_hr0tdd47",
  "_TZE200_rjxqso4a",
  "_TZE284_rjxqso4a",
}))

-- Z2M v26.99.0: Nous E13.
local water_model_nous_e13 = {
  profile = "safety-water-nous-e13",
  query_on_configure = false,
  time_start = "off",
  initial_custom_state_query = false,
  refresh_state_query = false,
  tuya.dp_numeric(1, {
    name = "water",
    emit = emit.water(),
    read_only = true,
    converter = converter.from_only(function(value)
      return type(value) == "number" and value == 1
    end),
  }),
  tuya.dp_battery(4, {
    emit = emit.battery(),
    read_only = true,
  }),
  tuya.dp_enum(101, {
    name = "nous_e13_alarm_mode",
    emit = emit.nousE13AlarmMode(),
    converter = converter.lookup_from_to({
      water_presence = 0,
      water_absence = 1,
    }),
  }),
  tuya.dp_numeric(102, {
    name = "nous_e13_water_leak_alarm",
    emit = emit.nousE13WaterLeakAlarm(),
    read_only = true,
    converter = converter.from_only(function(value)
      return type(value) == "number" and value == 1 and "detected" or "clear"
    end),
  }),
  tuya.dp_enum(103, {
    name = "nous_e13_ringtone",
    emit = emit.nousE13Ringtone(),
    converter = converter.lookup_from_to({
      muted = 0,
      tone_1 = 1,
      tone_2 = 2,
      tone_3 = 3,
    }),
  }),
}

register_device_definition(water_model_nous_e13, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_1di7ujzp",
}))

-- Z2M v26.99.0: Lincukoo SZW08.
local water_model_lincukoo_szw08 = {
  profile = "safety-water-lincukoo-szw08",
  query_on_configure = false,
  time_start = "off",
  initial_custom_state_query = false,
  refresh_state_query = false,
  tuya.dp_battery(4, {
    emit = emit.battery(),
    read_only = true,
  }),
  tuya.dp_numeric(102, {
    name = "lincukoo_szw08_alarm_status",
    emit = emit.lincukooSzw08AlarmStatus(),
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "normal",
      [1] = "alarm",
    })),
  }),
  tuya.dp_enum(103, {
    name = "lincukoo_szw08_alarm_ringtone",
    emit = emit.lincukooSzw08Ringtone(),
    converter = converter.lookup_from_to({
      mute = 0,
      ring1 = 1,
      ring2 = 2,
      ring3 = 3,
    }),
  }),
  tuya.dp_enum(101, {
    name = "lincukoo_szw08_mode",
    emit = emit.lincukooSzw08Mode(),
    converter = converter.lookup_from_to({
      leakage = 0,
      shortage = 1,
    }),
  }),
}

register_device_definition(water_model_lincukoo_szw08, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_ajhu0zqb",
  "_TZE2841000000_ajhu0zqb",
}))

-- Z2M v26.108.0: Immax 07519L / NEO smart water leak sensor.
-- The contributor-tested contract is DP1 enum 0=wet/1=dry, DP4 raw battery,
-- DP101 enum silent mode ON=0/OFF=1 and DP102 enum tone_1=0..tone_3=2.
local water_model_immax_07519l = {
  profile = "safety-water-leak-battery-immax-07519l",
  query_on_configure = false,
  time_start = "off",
  initial_custom_state_query = false,
  refresh_state_query = false,
  tuya.dp_enum(1, {
    name = "water_leak",
    emit = emit.water(),
    converter = converter.true_false0(),
    read_only = true,
  }),
  tuya.dp_battery(4, {
    emit = emit.battery(),
    read_only = true,
  }),
  tuya.dp_enum(101, {
    name = "immax_07519l_silent_mode",
    emit = emit.immax07519lSilentMode(),
    converter = converter.lookup_from_to({
      ON = 0,
      OFF = 1,
    }),
  }),
  tuya.dp_enum(102, {
    name = "immax_07519l_ringtone",
    emit = emit.immax07519lRingtone(),
    converter = converter.lookup_from_to({
      tone_1 = 0,
      tone_2 = 1,
      tone_3 = 2,
    }),
  }),
}

register_device_definition(water_model_immax_07519l, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_rhocfd6y",
}))

-- ZHC 8fbd03b (2026-09-16): Moes MG-BJQ002 plug-in siren.
-- Keep the first pass on the two standard SmartThings surfaces: alarm mode
-- (DP1) and night-light power (DP22).  Volume, duration, ringtone and RGB
-- light mode stay deferred until their family-specific controls are audited.
local siren_model_moes_mg_bjq002_core = {
  profile = "safety-siren-moes-mg-bjq002-core",
  query_on_configure = false,
  time_start = "off",
  initial_custom_state_query = false,
  refresh_state_query = false,
  alarm_command_modes = true,
  tuya.dp_enum(1, {
    name = "alarm",
    emit = emit.alarm(),
    converter = converter.lookup_from_to({
      siren = 0,
      strobe = 1,
      both = 2,
      off = 3,
    }),
  }),
  tuya.dp_on_off(22, {
    name = "switch",
    emit = emit.switch(),
  }),
}

register_device_definition(siren_model_moes_mg_bjq002_core, device_helpers.create_fingerprints("TS0601", {
  "_TZE20C_tjz9ad5g",
}))

return {
  id = "ef00.safety.z2m_absorption",
  registrations = device_definitions,
}
