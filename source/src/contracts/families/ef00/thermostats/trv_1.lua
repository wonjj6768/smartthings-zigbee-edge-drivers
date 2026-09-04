local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local ef00_helpers = require "contracts.helpers.ef00"
local thermostat_metadata = require "contracts.helpers.ef00_thermostat_metadata"
local thermostat_common = require "contracts.helpers.ef00_thermostats"
local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()
local alecto_on_off = converter.lookup_from_to({ off = false, on = true })

local function error_or_battery_low_dp(error_emitter, battery_emitter)
  return tuya.dp_bitmap(35, {
    name = "error_or_battery_low",
    read_only = true,
    converter = converter.error_or_battery_low(),
    emit = thermostat_common.error_or_battery_low_emitter(error_emitter, battery_emitter),
  })
end

local gs361a_on_off = converter.lookup_from_to({ off = false, on = true })
local siterwell_gs361a = thermostat_metadata.attach({
  profile = "thermostats-siterwell-gs361a",
  package_group = "trv-1",
  tuya.dp_current_heating_setpoint(2, { scale = 10, emit = emit.heating_setpoint("C") }),
  tuya.dp_local_temperature(3, { scale = 10, emit = emit.temperature("C") }),
  tuya.dp_system_mode(4, {
    converter = converter.lookup_from_to({ off = 0, auto = 1, heat = 2 }),
    emit = emit.thermostat_mode(),
  }),
  tuya.dp_binary(7, { name = "gs361a_child_lock", emit = emit.gsHFourChildLock(), converter = gs361a_on_off }),
  tuya.dp_binary(18, { name = "gs361a_window_detection", emit = emit.gsHFourWindowDetection(), converter = gs361a_on_off }),
  tuya.dp_binary(20, { name = "gs361a_valve_detection", emit = emit.gsHFourValveDetection(), converter = gs361a_on_off }),
  tuya.dp_battery(21, { read_only = true, emit = emit.battery() }),
  tuya.dp_numeric(109, {
    name = "running_state",
    read_only = true,
    emit = emit.thermostat_operating_state(),
    converter = converter.from_only(function(value) return tonumber(value) ~= 0 and "heating" or "idle" end),
  }),
}, { "off", "auto", "heat" }, 5, 30, 0.5)

register_device_definition(siterwell_gs361a, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_04yfvweb",
  "_TZE200_2cs6g9i7",
  "_TZE200_hhrtiq0x",
  "_TZE200_jeaxp72v",
  "_TZE200_kfvq6avy",
  "_TZE200_lrznf59v",
  "_TZE200_owwdxjbx",
  "_TZE200_ps5v5jor",
  "_TZE200_zivfvd7h",
  "_TZE204_woww89ip",
}))

local alecto_smart_heat10 = {
  profile = "thermostats-alecto-smart-heat10",
  package_group = "trv-1",
  tuya.dp_current_heating_setpoint(2, { scale = 10 }),
  tuya.dp_local_temperature(3, { scale = 10 }),
  tuya.dp_system_mode(4, {
    converter = converter.lookup_from_to({ off = 0, auto = 1, heat = 2 }),
  }),
  tuya.dp_binary(7, {
    name = "alecto_child_lock",
    emit = emit.alectoSmartHeat10ChildLock(),
    converter = alecto_on_off,
  }),
  tuya.dp_binary(18, {
    name = "alecto_window_detection",
    emit = emit.alectoSmartHeat10WindowDetection(),
    converter = alecto_on_off,
  }),
  tuya.dp_battery(21, { emit = emit.battery() }),
}

register_device_definition(alecto_smart_heat10, {
  device_helpers.create_fingerprint("_TYST11_8daqwrsj", "daqwrsj"),
  device_helpers.create_fingerprint("_TZE200_8daqwrsj", "TS0601"),
})
local valve_position_to_running_state = thermostat_common.valve_position_to_running_state
local thermostat_variant1_mode_from_device = thermostat_common.variant1_mode_from_device
local thermostat_variant1_mode_to_device = thermostat_common.variant1_mode_to_device
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

-- Z2M maps the DP4 preset onto a system mode through thermostatSystemModes3
-- (legacy.ts:2487): preset 0 is the schedule (auto), 1 is manual heating and 2
-- is off.  The remaining presets have no system mode of their own.
local function classic_trv_preset_to_system_mode(value)
  local lookup = {
    [0] = "auto",
    [1] = "heat",
    [2] = "off",
  }
  return lookup[tonumber(value)]
end

local function classic_trv_system_mode_to_preset(value)
  local lookup = {
    auto = 0,
    heat = 1,
    off = 2,
  }
  return lookup[value]
end

local classic_trv = {
  profile = "thermostats-thermostat-classic-trv",
  package_group = "trv-1",
  force_time_updates = true,
  tuya.dp_current_heating_setpoint(2, { scale = 10 }),
  tuya.dp_local_temperature(3, { scale = 10 }),
  -- Z2M TS0601_thermostat (tuya.ts:8570) drives this family through
  -- legacy.fz.tuya_thermostat (legacy.ts:2405).  DP4 is the preset, which also
  -- maps onto a system mode, DP106 is the force mode and DP109 carries both the
  -- valve position and the derived running state.  Treating DP106 as the system
  -- mode meant writing a force value where the mode belongs.
  tuya.dp_enum(4, {
    name = "preset",
    emit = emit.classicTrvPreset(),
    converter = converter.lookup_from_to({
      schedule = 0,
      manual = 1,
      boost = 2,
      complex = 3,
      comfort = 4,
      eco = 5,
      away = 6,
    }),
  }),
  tuya.dp_system_mode(4, {
    from_device = classic_trv_preset_to_system_mode,
    to_device = classic_trv_system_mode_to_preset,
  }),
  tuya.dp_binary(7, {
    name = "child_lock",
    emit = emit.classicTrvChildLock(),
    converter = converter.lookup_from_to({ unlock = false, lock = true }),
  }),
  tuya.dp_binary(20, {
    name = "valve_detection",
    emit = emit.classicTrvValveDetection(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_battery(21, {}),                                                -- 프로파일 미포함
  tuya.dp_local_temperature_calibration(44, {
    scale = 10,
    emit = emit.classicTrvTempCalibration(),
  }),
  tuya.dp_numeric(102, { name = "min_temperature", emit = emit.classicTrvMinTemperature() }),
  tuya.dp_numeric(103, { name = "max_temperature", emit = emit.classicTrvMaxTemperature() }),
  -- DP104 packs an on/off flag plus a temperature and a minute count in one
  -- frame, so only the flag is safe to expose.
  tuya.dp_raw(104, {
    name = "window_detection",
    emit = emit.classicTrvWindowDetection(),
    converter = converter.from_only(function(value)
      local buffer = tostring(value)
      if #buffer < 1 then
        return nil
      end
      return string.byte(buffer, 1) ~= 0 and "on" or "off"
    end),
  }),
  tuya.dp_numeric(105, { name = "boost_time", emit = emit.classicTrvBoostTime() }),
  tuya.dp_enum(106, {
    name = "force",
    emit = emit.classicTrvForce(),
    converter = converter.lookup_from_to({ normal = 0, open = 1, close = 2 }),
  }),
  tuya.dp_numeric(107, { name = "comfort_temperature", emit = emit.classicTrvComfortTemperature() }),
  tuya.dp_numeric(108, { name = "eco_temperature", emit = emit.classicTrvEcoTemperature() }),
  tuya.dp_numeric(109, { name = "position", read_only = true, emit = emit.classicTrvPosition() }),
  tuya.dp_running_state(109, {
    from_device = valve_position_to_running_state,
  }),
  tuya.dp_binary(110, {
    name = "battery_low",
    read_only = true,
    emit = emit.classicTrvBatteryLow(),
    converter = converter.from_only(function(value)
      return value and "low" or "normal"
    end),
  }),
  tuya.dp_enum(111, {
    name = "week",
    emit = emit.classicTrvWeek(),
    converter = converter.lookup_from_to({ ["5_2"] = 0, ["6_1"] = 1, ["7"] = 2 }),
  }),
  tuya.dp_raw(112, { name = "schedule_workday" }),                        -- 프로파일 미포함
  tuya.dp_raw(113, { name = "schedule_holiday" }),                        -- 프로파일 미포함
  tuya.dp_numeric(114, { name = "away_temperature", emit = emit.classicTrvAwayTemperature() }),
  tuya.dp_binary(115, {
    name = "window_open",
    read_only = true,
    emit = emit.classicTrvWindowOpen(),
    converter = converter.from_only(function(value)
      return value and "open" or "closed"
    end),
  }),
  tuya.dp_binary(116, {
    name = "auto_lock",
    emit = emit.classicTrvAutoLock(),
    converter = converter.lookup_from_to({ manual = false, auto = true }),
  }),
  tuya.dp_numeric(117, { name = "away_days", emit = emit.classicTrvAwayDays() }),
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
-- Z2M lists HY368, HY369RT, 378RT, TVR01, 07732B, 07732L, Heat M30, P5630S and
-- the THALEOS HY368 as whiteLabel retail names for the exacts above
-- (tuya.ts:8573).  They are sales labels, not interviewed manufacturer/model
-- pairs, so they are not registered as fingerprints.
local thermostat_hy607w = {
  profile = "thermostats-thermostat-hy607w",
  package_group = "trv-1",
  -- Z2M HY607W-3A (tuya.ts:23923) exposes DP125 as a plain ON/OFF switch, the
  -- setpoint as occupied_heating_setpoint on DP50 and the mode on DP128, whose
  -- payload may arrive as a one-byte array.
  tuya.dp_local_temperature(16, { scale = 10, emit = emit.temperature("C") }),
  tuya.dp_current_heating_setpoint(50, {
    name = "occupied_heating_setpoint",
    scale = 10,
    emit = emit.heating_setpoint("C"),
  }),
  tuya.dp_on_off(125, { name = "switch", emit = emit.switch() }),
  tuya.dp_binary(102, {
    name = "running_state",
    read_only = true,
    converter = enum_heat_idle_bool,
    emit = emit.thermostat_operating_state(),
  }),
  tuya.dp_enum(128, {
    name = "mode_state",
    emit = emit.hy607wModeState(),
    from_device = function(value)
      if type(value) == "table" then
        value = value[1]
      end
      local lookup = { [0] = "manual", [1] = "auto", [3] = "tempOverride" }
      return lookup[tonumber(value)]
    end,
    to_device = function(value)
      local lookup = { manual = 0, auto = 1, tempOverride = 3 }
      return lookup[value]
    end,
  }),
}
register_device_definition(thermostat_hy607w, ef00_helpers.ts0601_fingerprints( {
  "_TZE200_khah2lkr",
}))
local thermostat_zg_wk_da = {
  profile = "thermostats-thermostat-zg-wk-da",
  package_group = "trv-1",
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
  tuya.dp_child_lock(9, { name = "child_lock", emit = emit.zgwkdaChildLock() }),
  -- Z2M ZG-WK-DA-Wh-Zigbee (tuya.ts:22915) reads DP19 with divideBy(1), i.e. raw.
  tuya.dp_local_temperature_calibration(19, { scale = 1, emit = emit.zgwkdaTempCalibration() }),
  tuya.dp_enum(102, {
    name = "running_state",
    converter = enum_heat_idle_inverted,
    emit = emit.thermostat_operating_state(),
  }),
}
register_device_definition(thermostat_zg_wk_da, ef00_helpers.ts0601_fingerprints( {
  "_TZE204_atdqo4nj",
}))
local thermostat_tgm50 = {
  profile = "thermostats-thermostat-tgm50",
  package_group = "trv-1",
  respond_to_mcu_version_response = true,
  tuya.dp_binary(1, { name = "system_mode", converter = bool_heat_off }),
  tuya.dp_current_heating_setpoint(2, { scale = 10 }),
  tuya.dp_local_temperature(3, { scale = 10 }),
  tuya.dp_child_lock(9, { name = "child_lock", emit = emit.tgm50ChildLock() }),
  tuya.dp_max_temperature_limit(15, { scale = 10, emit = emit.tgm50MaxTemperatureLimit() }),
  tuya.dp_local_temperature_calibration(19, { scale = 10, emit = emit.tgm50TempCalibration() }),
  tuya.dp_enum(4, {
    name = "preset",
    emit = emit.tgm50Preset(),
    converter = converter.lookup_from_to({ manual = 0, auto = 1, eco = 3 }),
  }),
  tuya.dp_running_state(101, {
    converter = converter.lookup_from_to({ idle = 0, heating = 1 }),
    emit = emit.thermostat_operating_state(),
  }),
  tuya.dp_frost_protection(102, { emit = emit.tgm50FrostProtection() }),
  tuya.dp_binary(103, {
    name = "factory_reset",
    emit = emit.tgm50FactoryReset(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_temperature_sensor_select_internal_external_both(106, {
    name = "sensor",
    emit = emit.tgm50Sensor(),
  }),
  tuya.dp_temperature(107, { name = "temperature_delta", scale = 10, emit = emit.tempDeltaTgmCToTen() }),
  tuya.dp_enum(110, {
    name = "backlight_mode",
    emit = emit.tgm50BacklightMode(),
    converter = converter.lookup_from_to({ off = 0, alwaysLow = 1, alwaysMid = 2, alwaysHigh = 3 }),
  }),
}
register_device_definition(thermostat_tgm50, ef00_helpers.ts0601_fingerprints( {
  "_TZE204_cvub6xbb",
  "_TZE284_cvub6xbb",
  "_TZE204_mwomyz5n",
}))
local thermostat_po_thco = {
  profile = "thermostats-thermostat-tbgecldg",
  package_group = "trv-1",
  time_start = "2000",
  tuya.dp_system_mode(1, { converter = converter.lookup_from_to({ auto = 0, heat = 1, off = 2 }) }),
  -- Z2M _TZE204_tbgecldg (tuya.ts:8820) drives every setpoint through divideBy2
  -- and exposes DP2 as an auto/manual/holiday preset.
  tuya.dp_enum(2, {
    name = "preset",
    emit = emit.tbgePreset(),
    converter = converter.lookup_from_to({ auto = 0, manual = 1, holiday = 2 }),
  }),
  tuya.dp_current_heating_setpoint(16, { scale = 2 }),
  tuya.dp_local_temperature(24, { scale = 10 }),
  tuya.dp_child_lock(30, { name = "child_lock", emit = emit.tbgeChildLock() }),
  tuya.dp_battery(34, { emit = emit.battery(), converter = converter.from_only(function(value) return math.max(0, math.min(100, (tonumber(value) or 50) - 50)) end) }),
  tuya.dp_comfort_temperature(101, { scale = 2, emit = emit.tbgeComfortTemperature() }),
  tuya.dp_eco_temperature(102, { scale = 2, emit = emit.tbgeEcoTemperature() }),
  tuya.dp_holiday_temperature(103, { scale = 2, emit = emit.tbgeHolidayTemperature() }),
  tuya.dp_local_temperature_calibration(104, { scale = 10, emit = emit.tbgeLocalTempCalibration() }),
  tuya.dp_current_heating_setpoint(105, {
    name = "auto_temperature",
    scale = 2,
    emit = emit.tbgeAutoTemperature(),
  }),
  tuya.dp_boost_heating(106, { emit = emit.tbgeBoostHeating() }),
  tuya.dp_window_open(107, { read_only = true, emit = emit.tbgeWindowOpenStatus() }),
  tuya.dp_open_window_temperature(116, { scale = 2, emit = emit.tbgeOpenWindowTemperature() }),
  tuya.dp_open_window_time(117, { emit = emit.tbgeOpenWindowTime() }),
  tuya.dp_boost_time(118, { emit = emit.tbgeBoostTime() }),
}
register_device_definition(thermostat_po_thco, ef00_helpers.ts0601_fingerprints( {
  "_TZE204_tbgecldg",
  "_TZE284_tbgecldg",
  "_TZE200_tbgecldg",
}))
local thermostat_bab_1413 = {
  profile = "thermostats-thermostat-g2ki0ejr",
  package_group = "trv-1",
  tuya.dp_system_mode(1, { converter = converter.lookup_from_to({ auto = 0, heat = 1, off = 2 }) }),
  -- Z2M _TZE204_g2ki0ejr (tuya.ts:8727) exposes DP2 as an
  -- auto/holiday/manual/comfort preset and derives the running state, the system
  -- mode and a valve label from DP49.
  tuya.dp_enum(2, {
    name = "preset",
    emit = emit.g2kiPreset(),
    converter = converter.lookup_from_to({ auto = 0, holiday = 1, manual = 2, comfort = 3 }),
  }),
  tuya.dp_current_heating_setpoint(4, { scale = 10 }),
  tuya.dp_local_temperature(5, { scale = 10 }),
  tuya.dp_battery(6, { emit = emit.battery() }),
  tuya.dp_child_lock(7, { name = "child_lock", emit = emit.g2kiChildLock() }),
  tuya.dp_max_temperature_limit(9, { scale = 10, emit = emit.g2kiMaxTemperatureLimit() }),
  tuya.dp_min_temperature_limit(10, { scale = 10, emit = emit.g2kiMinTemperatureLimit() }),
  tuya.dp_window_detection(14, { emit = emit.g2kiWindowDetection() }),
  tuya.dp_open_window_temperature(16, { scale = 10, emit = emit.g2kiOpenWindowTemperature() }),
  tuya.dp_open_window_time(17, { emit = emit.g2kiOpenWindowTime() }),
  tuya.dp_binary(19, { name = "factory_reset", emit = emit.g2kiFactoryReset() }),
  tuya.dp_holiday_temperature(21, { scale = 1, emit = emit.g2kiHolidayTemperature() }),
  tuya.dp_comfort_temperature(24, { scale = 10, emit = emit.g2kiComfortTemperature() }),
  tuya.dp_eco_temperature(25, { scale = 10, emit = emit.g2kiEcoTemperature() }),
  tuya.dp_frost_protection(36, { emit = emit.g2kiFrostProtection() }),
  tuya.dp_valve_state(49, { emit = emit.g2kiValveState() }),
}
register_device_definition(thermostat_bab_1413, ef00_helpers.ts0601_fingerprints( {
  "_TZE204_g2ki0ejr",
}))
local thermostat_variant6 = {
  profile = "thermostats-thermostat-cgr0rhza",
  package_group = "trv-1",
  force_time_updates = true,
  -- Z2M _TZE284_cgr0rhza (tuya.ts:22658) exposes DP2 as a six-value preset and
  -- reads DP47 raw rather than /10.
  tuya.dp_enum(2, {
    name = "preset",
    emit = emit.cgr0Preset(),
    converter = converter.lookup_from_to({
      manual = 0,
      schedule = 1,
      eco = 2,
      comfort = 3,
      antifrost = 4,
      off = 5,
    }),
  }),
  tuya.dp_current_heating_setpoint(4, { scale = 10 }),
  tuya.dp_local_temperature(5, { scale = 10 }),
  tuya.dp_battery(6, { emit = emit.battery() }),
  tuya.dp_child_lock(7, { name = "child_lock", emit = emit.cgr0ChildLock() }),
  tuya.dp_window_detection(8, { emit = emit.cgr0WindowDetection() }),
  tuya.dp_open_window(14, { emit = emit.cgr0OpenWindow() }),
  tuya.dp_holiday_temperature(21, { scale = 1, emit = emit.cgr0HolidayTemperature() }),
  tuya.dp_comfort_temperature(24, { scale = 10, emit = emit.cgr0ComfortTemperature() }),
  tuya.dp_eco_temperature(25, { scale = 10, emit = emit.cgr0EcoTemperature() }),
  error_or_battery_low_dp(emit.cgr0FaultAlarm(), emit.cgr0BatteryLow()),
  tuya.dp_frost_protection(36, { emit = emit.cgr0FrostProtection() }),
  tuya.dp_scale_protection(39, { emit = emit.cgr0ScaleProtection() }),
  tuya.dp_local_temperature_calibration(47, { scale = 1, emit = emit.cgr0LocalTempCalibration() }),
  tuya.dp_valve_state(49, { emit = emit.cgr0ValveState() }),
  tuya.dp_boost_heating(101, { emit = emit.cgr0BoostHeating() }),
  tuya.dp_boost_time(102, { emit = emit.cgr0BoostTime() }),
}
register_device_definition(thermostat_variant6, ef00_helpers.ts0601_fingerprints( {
  "_TZE284_cgr0rhza",
}))
-- Z2M lists _TZE284_ymldrmzx as TRV603-WZ (tuya.ts:10205), a different model:
-- DP15 is the window-open state rather than DP14, DP113 is the system mode with
-- inverted polarity, calibration sits on DP114 and it adds screen orientation,
-- an antifrost setpoint, a fault code and a holiday time window.
local thermostat_trv603_wz = {
  profile = "thermostats-thermostat-trv603wz",
  package_group = "trv-1",
  force_time_updates = true,
  tuya.dp_enum(2, {
    name = "preset",
    emit = emit.trv603wzPreset(),
    converter = converter.lookup_from_to({ schedule = 0, holiday = 1, manual = 2 }),
  }),
  tuya.dp_current_heating_setpoint(4, { scale = 10 }),
  tuya.dp_local_temperature(5, { scale = 10 }),
  tuya.dp_battery(6, { emit = emit.battery() }),
  tuya.dp_child_lock(7, { name = "child_lock", emit = emit.trv603wzChildLock() }),
  tuya.dp_window_detection(14, { emit = emit.trv603wzWindowDetection() }),
  tuya.dp_binary(15, {
    name = "window_open",
    read_only = true,
    emit = emit.trv603wzWindowOpen(),
    converter = converter.from_only(function(value)
      return value and "open" or "closed"
    end),
  }),
  tuya.dp_holiday_temperature(21, { scale = 10, emit = emit.trv603wzHolidayTemperature() }),
  tuya.dp_frost_protection(36, { emit = emit.trv603wzFrostProtection() }),
  tuya.dp_binary(39, {
    name = "anti_scale",
    emit = emit.trv603wzAntiScale(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  -- Z2M keeps DP47 before DP114 and its generic writer selects the first
  -- matching property, so DP47 is the TX route while both DPs are RX aliases.
  tuya.dp_local_temperature_calibration(47, { scale = 10, emit = emit.trv603wzLocalTempCalibration() }),
  tuya.dp_valve_state(49, { name = "valve_status", emit = emit.trv603wzValveStatus() }),
  tuya.dp_boost_heating(101, { emit = emit.trv603wzBoostHeating() }),
  tuya.dp_boost_time(102, { emit = emit.trv603wzBoostTime() }),
  tuya.dp_raw(103, { name = "schedule_monday" }),                          -- 프로파일 미포함
  tuya.dp_raw(104, { name = "schedule_tuesday" }),                         -- 프로파일 미포함
  tuya.dp_raw(105, { name = "schedule_wednesday" }),                       -- 프로파일 미포함
  tuya.dp_raw(106, { name = "schedule_thursday" }),                        -- 프로파일 미포함
  tuya.dp_raw(107, { name = "schedule_friday" }),                          -- 프로파일 미포함
  tuya.dp_raw(108, { name = "schedule_saturday" }),                        -- 프로파일 미포함
  tuya.dp_raw(109, { name = "schedule_sunday" }),                          -- 프로파일 미포함
  tuya.dp_raw(110, { name = "holiday_time" }),                             -- 프로파일 미포함
  tuya.dp_enum(111, {
    name = "screen_orientation",
    emit = emit.trv603wzScreenOrientation(),
    converter = converter.lookup_from_to({ up = 0, right = 1, down = 2, left = 3 }),
  }),
  tuya.dp_temperature(112, {
    name = "antifrost_temperature",
    scale = 10,
    emit = emit.trv603wzAntifrostTemperature(),
  }),
  tuya.dp_system_mode(113, {
    converter = converter.lookup_from_to({ auto = false, off = true }),
  }),
  tuya.dp_local_temperature_calibration(114, {
    scale = 10,
    emit = emit.trv603wzLocalTempCalibration(),
  }),
  tuya.dp_numeric(115, { name = "programming_mode", emit = emit.trv603wzProgrammingMode() }),
  tuya.dp_eco_temperature(116, { scale = 10, emit = emit.trv603wzEcoTemperature() }),
  tuya.dp_comfort_temperature(117, { scale = 10, emit = emit.trv603wzComfortTemperature() }),
  tuya.dp_numeric(118, {
    name = "fault_code",
    read_only = true,
    emit = emit.trv603wzFaultCode(),
  }),
}
register_device_definition(thermostat_trv603_wz, ef00_helpers.ts0601_fingerprints( {
  "_TZE284_ymldrmzx",
}))
local thermostat_zht_002 = {
  profile = "thermostats-thermostat-zht002",
  package_group = "trv-1",
  time_start = "2000",
  tuya.dp_binary(1, { name = "system_mode", converter = bool_heat_off }),
  tuya.dp_enum(2, {
    name = "programming_mode",
    emit = emit.zht002ProgrammingMode(),
    converter = converter.lookup_from_to({ auto = 0, manual = 1 }),
  }),
  tuya.dp_local_temperature(16, { scale = 10 }),
  -- Z2M reads DP18, DP34, DP50, DP101 and DP102 raw (tuya.ts:10155) and DP19
  -- through localTemperatureCalibration, so none of them are divided by ten.
  tuya.dp_min_temperature_limit(18, {
    name = "min_temperature",
    scale = 1,
    emit = emit.zht002MinTemperature(),
  }),
  tuya.dp_local_temperature_calibration(19, { scale = 1, emit = emit.zht002TempCalibration() }),
  tuya.dp_enum(23, {
    name = "working_day",
    emit = emit.zht002WorkingDay(),
    converter = converter.lookup_from_to({ disabled = 0, fiveTwo = 1, sixOne = 2, seven = 3 }),
  }),
  tuya.dp_temperature_sensor_select(32, {
    name = "sensor",
    emit = emit.zht002Sensor(),
    converter = converter.lookup_from_to({ ["in"] = 0, ou = 1, al = 2 }),
  }),
  tuya.dp_max_temperature_limit(34, {
    name = "max_temperature",
    scale = 1,
    emit = emit.zht002MaxTemperature(),
  }),
  tuya.dp_child_lock(39, { name = "child_lock", emit = emit.zht002ChildLock() }),
  tuya.dp_eco_mode(40, { emit = emit.zht002EcoMode() }),
  tuya.dp_valve_state(47, {
    read_only = true,
    emit = emit.zht002ValveState(),
    converter = converter.from_only(converter.lookup_value({
      [0] = "closed",
      [1] = "open",
    })),
  }),
  tuya.dp_current_heating_setpoint(50, { scale = 1 }),
  tuya.dp_max_temperature_limit(101, {
    name = "max_temperature_limit",
    scale = 1,
    emit = emit.maxTempLimitZhtCToSeventy(),
  }),
  tuya.dp_deadzone_temperature(102, { scale = 1, emit = emit.zht002DeadzoneTemperature() }),
}
register_device_definition(thermostat_zht_002, ef00_helpers.ts0601_fingerprints( {
  "_TZE204_xalsoe3m",
}))
local thermostat_variant1 = {
  profile = "thermostats-thermostat-trv1",
  package_group = "trv-1",
  force_time_updates = true,
  tuya.dp_system_mode(1, {
    from_device = thermostat_variant1_mode_from_device,
    to_device = thermostat_variant1_mode_to_device,
    emit = emit.thermostat_mode(),
  }),
  -- Z2M TS0601_thermostat_1 (tuya.ts:9720) packs system mode and preset into DP1:
  -- raw 0 = auto preset / auto mode, 1 = manual preset / auto mode, 2 = off, 3 = on
  -- preset with heat mode.  Writes use auto=1, off=2, heat=3 for the mode.
  tuya.dp_enum(1, {
    name = "preset",
    emit = emit.trv1Preset(),
    converter = converter.lookup_from_to({ auto = 0, manual = 1, off = 2, on = 3 }),
  }),
  tuya.dp_current_heating_setpoint(2, { scale = 10 }),
  tuya.dp_local_temperature(3, { scale = 10 }),
  tuya.dp_boost_heating(4, { emit = emit.trv1BoostHeating() }),
  tuya.dp_numeric(5, { name = "boost_time", emit = emit.trv1BoostTime() }),
  tuya.dp_running_state(6, {
    converter = converter.lookup_from_to({
      heating = 1,
      idle = 0,
    }),
    emit = emit.thermostat_operating_state(),
  }),
  tuya.dp_enum(7, {
    name = "window",
    read_only = true,
    emit = emit.trv1Window(),
    converter = converter.from_only(converter.lookup_value({
      [0] = "close",
      [1] = "open",
    })),
  }),
  tuya.dp_window_detection(8, { emit = emit.trv1WindowDetection() }),
  tuya.dp_child_lock(12, { emit = emit.trv1ChildLock() }),
  tuya.dp_battery(13, { emit = emit.battery() }),
  tuya.dp_binary(14, {
    name = "alarm_switch",
    read_only = true,
    emit = emit.trv1AlarmSwitch(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_min_temperature_limit(15, {
    name = "min_temperature",
    scale = 10,
    emit = emit.trv1MinTemperature(),
  }),
  tuya.dp_max_temperature_limit(16, {
    name = "max_temperature",
    scale = 10,
    emit = emit.trv1MaxTemperature(),
  }),
  tuya.dp_local_temperature_calibration(101, { scale = 10, emit = emit.trv1TempCalibration() }),
  tuya.dp_numeric(102, {
    name = "position",
    read_only = true,
    converter = converter.divide_by_pair(10),
    emit = emit.trv1Position(),
  }),
  tuya.dp_enum(116, {
    name = "screen_orientation",
    emit = emit.trv1ScreenOrientation(),
    converter = converter.lookup_from_to({ up = 0, down = 2 }),
  }),
  tuya.dp_enum(152, {
    name = "display_brightness",
    emit = emit.trv1DisplayBrightness(),
    converter = converter.lookup_from_to({ high = 0, middle = 1, low = 2 }),
  }),
  tuya.dp_enum(153, {
    name = "hysteresis_mode",
    emit = emit.trv1Hysteresis(),
    converter = converter.lookup_from_to({ comfort = 0, eco = 1 }),
  }),
  tuya.dp_numeric(154, {
    name = "switch_deviation_eco",
    converter = converter.divide_by_pair(10),
    emit = emit.trv1SwitchDeviationEco(),
  }),
}
register_device_definition(thermostat_variant1, ef00_helpers.ts0601_fingerprints( {
  "_TZE200_a4bpgplm",
  "_TZE200_bvrlmajk",
  "_TZE200_dv8abrrz",
  "_TZE200_z1tyspqw",
}))
-- Z2M lists id3 GTZ06 (_TZE200_z1tyspqw) and AVATTO TRV07 (_TZE200_bvrlmajk) as
-- whiteLabel retail names for the exacts above (tuya.ts:9662), not as interviewed
-- manufacturer/model pairs.
local thermostat_variant3 = {
  profile = "thermostats-thermostat-trv06",
  package_group = "trv-1",
  time_start = "2000",
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
  -- Z2M TS0601_thermostat_3 (tuya.ts:9303) also exposes DP7 child lock, DP35
  -- error / battery-low, DP36 frost protection, DP39 scale protection, DP47
  -- calibration and DP101 valve position.  DP28..DP34 are packed weekly
  -- schedule frames, so they stay unexposed.
  tuya.dp_binary(7, {
    name = "child_lock",
    emit = emit.trv06ChildLock(),
    converter = converter.lookup_from_to({ unlock = false, lock = true }),
  }),
  tuya.dp_raw(28, { name = "schedule_monday" }),                          -- 프로파일 미포함
  tuya.dp_raw(29, { name = "schedule_tuesday" }),                         -- 프로파일 미포함
  tuya.dp_raw(30, { name = "schedule_wednesday" }),                       -- 프로파일 미포함
  tuya.dp_raw(31, { name = "schedule_thursday" }),                        -- 프로파일 미포함
  tuya.dp_raw(32, { name = "schedule_friday" }),                          -- 프로파일 미포함
  tuya.dp_raw(33, { name = "schedule_saturday" }),                        -- 프로파일 미포함
  tuya.dp_raw(34, { name = "schedule_sunday" }),                          -- 프로파일 미포함
  -- Z2M errorOrBatteryLow always publishes the raw error bitmap and marks the
  -- battery low only when the raw value is exactly 1.
  error_or_battery_low_dp(emit.trv06Error(), emit.trv06BatteryLow()),
  tuya.dp_binary(36, {
    name = "frost_protection",
    emit = emit.trv06FrostProtection(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_binary(39, {
    name = "scale_protection",
    emit = emit.trv06ScaleProtection(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_local_temperature_calibration(47, {
    scale = 1,
    emit = emit.trv06TempCalibration(),
  }),
  tuya.dp_numeric(101, {
    name = "pi_heating_demand",
    read_only = true,
    emit = emit.trv06PiHeatingDemand(),
  }),
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
-- Z2M lists ME167, ME168_1, TRV06_1, AVATTO_TRV06, TRV06-AT and Eco-4160 as
-- whiteLabel retail names attached to the exacts above (tuya.ts:9232), not as
-- interviewed manufacturer/model pairs.  Registering them as fingerprints would
-- claim pairs no device reports, so they are not registered.
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
local thermostat_thaleos_thah202001 = {
  profile = "thermostats-thermostat-thah202001",
  package_group = "trv-1",
  force_time_updates = true,
  tuya.dp_system_mode(2, {
    from_device = thaleos_thah202001_mode_from_device,
    to_device = thaleos_thah202001_mode_to_device,
  }),
  -- Z2M _TZE204_m5r5nlxc (tuya.ts:9447) packs the system mode and the preset
  -- into DP2: values 0..3 are presets under a heat mode and 4 means off.
  tuya.dp_enum(2, {
    name = "preset",
    emit = emit.thahPreset(),
    converter = converter.lookup_from_to({ manual = 0, eco = 1, away = 2, holiday = 3 }),
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
  tuya.dp_binary(14, {
    name = "window_detection",
    emit = emit.thahWindowDetection(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_enum(15, {
    name = "window_open",
    read_only = true,
    emit = emit.thahWindowOpen(),
    converter = converter.from_only(converter.lookup_value({
      [0] = "open",
      [1] = "close",
    })),
  }),
  tuya.dp_holiday_temperature(21, { scale = 10, emit = emit.thahHolidayTemperature() }),
  tuya.dp_eco_temperature(24, { scale = 10, emit = emit.thahEcoTemperature() }),
  tuya.dp_numeric(25, {
    name = "away_temperature",
    scale = 10,
    emit = emit.thahAwayTemperature(),
  }),
  error_or_battery_low_dp(emit.thahErrorStatus(), emit.thahBatteryLow()),
  tuya.dp_binary(36, {
    name = "frost_protection",
    emit = emit.thahFrostProtection(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_binary(39, {
    name = "scale_protection",
    emit = emit.thahScaleProtection(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_local_temperature_calibration(47, { scale = 10, emit = emit.thahLocalTempCalibration() }),
  tuya.dp_numeric(101, {
    name = "operating_time",
    scale = 10,
    read_only = true,
    emit = emit.thahOperatingTime(),
  }),
  tuya.dp_numeric(102, {
    name = "scale_protection_remaining_time",
    scale = 10,
    read_only = true,
    emit = emit.thahScaleRemainingTime(),
  }),
}
register_device_definition(thermostat_thaleos_thah202001, ef00_helpers.ts0601_fingerprints( {
  "_TZE204_m5r5nlxc",
}))
local thermostat_variant5 = {
  profile = "thermostats-thermostat-trv06b",
  package_group = "trv-1",
  time_start = "2000",
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
  -- Z2M TS0601_thermostat_5 (tuya.ts:9555) shares the datapoint numbers with
  -- TS0601_thermostat_3 but rotates the weekly schedule day order, so it keeps a
  -- separate family and its own capability ids.
  tuya.dp_binary(7, {
    name = "child_lock",
    emit = emit.trv06bChildLock(),
    converter = converter.lookup_from_to({ unlock = false, lock = true }),
  }),
  tuya.dp_raw(28, { name = "schedule_wednesday" }),                       -- 프로파일 미포함
  tuya.dp_raw(29, { name = "schedule_thursday" }),                        -- 프로파일 미포함
  tuya.dp_raw(30, { name = "schedule_friday" }),                          -- 프로파일 미포함
  tuya.dp_raw(31, { name = "schedule_saturday" }),                        -- 프로파일 미포함
  tuya.dp_raw(32, { name = "schedule_sunday" }),                          -- 프로파일 미포함
  tuya.dp_raw(33, { name = "schedule_monday" }),                          -- 프로파일 미포함
  tuya.dp_raw(34, { name = "schedule_tuesday" }),                         -- 프로파일 미포함
  error_or_battery_low_dp(emit.trv06bError(), emit.trv06bBatteryLow()),
  tuya.dp_binary(36, {
    name = "frost_protection",
    emit = emit.trv06bFrostProtection(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_binary(39, {
    name = "scale_protection",
    emit = emit.trv06bScaleProtection(),
    converter = converter.lookup_from_to({ off = false, on = true }),
  }),
  tuya.dp_local_temperature_calibration(47, {
    scale = 1,
    emit = emit.trv06bTempCalibration(),
  }),
  tuya.dp_numeric(101, {
    name = "pi_heating_demand",
    read_only = true,
    emit = emit.trv06bPiHeatingDemand(),
  }),
}
register_device_definition(thermostat_variant5, ef00_helpers.ts0601_fingerprints( {
  "_TZE200_p3dbf6qs",
  "_TZE200_hvaxb2tc",
}))
-- ME167_1 and TRV06_1b are Z2M whiteLabel retail names (tuya.ts:9521), not
-- interviewed pairs, so they are not registered as fingerprints.
return {
  id = "ef00.thermostats.trv_1",
  registrations = device_definitions,
}
