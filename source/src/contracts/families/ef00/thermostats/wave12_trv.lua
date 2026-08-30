local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local ef00_helpers = require "contracts.helpers.ef00"
local thermostat_metadata = require "contracts.helpers.ef00_thermostat_metadata"
local wave12 = require "contracts.helpers.ef00_thermostat_wave12"

local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()

local avatto = {
  profile = "thermostats-wave12-avatto-trv60",
  package_group = "trv",
  query_on_configure = false,
  time_start = "1970",
  force_time_updates = true,
  wave12.enum(2, "avatto_trv_mode", "avattoTrvSixtyMode", { auto = 0, manual = 1 }),
  wave12.enum(3, "avatto_trv_work_state", "avattoTrvSixtyWorkState", { opened = 0, closed = 1 }),
  tuya.dp_local_temperature(5, { scale = 10, read_only = true, emit = emit.temperature("C") }),
  tuya.dp_battery(6, { read_only = true, emit = emit.battery() }),
  wave12.binary(7, "avatto_trv_child_lock", "avattoTrvSixtyChildLock", { LOCK = true, UNLOCK = false }),
  wave12.binary(14, "avatto_trv_window_detection", "avattoTrvSixtyWindowDetection", { ON = true, OFF = false }),
  wave12.numeric(35, "avatto_trv_fault", "avattoTrvSixtyFault", 1, true),
  wave12.binary(36, "avatto_trv_frost_protection", "avattoTrvSixtyFrostProtection", { ON = true, OFF = false }),
  wave12.binary(36, "avatto_trv_scale_protection", "avattoTrvSixtyScaleProtection", { ON = true, OFF = false }),
  wave12.numeric(47, "avatto_trv_temp_calibration", "avattoTrvSixtyTempCalibration", 10, false, { signed = true }),
  wave12.numeric(101, "avatto_trv_valve_volume", "avattoTrvSixtyValveVolume", 1, true),
  tuya.dp_numeric(102, { name = "humidity", read_only = true, emit = emit.humidity() }),
  wave12.binary(103, "avatto_trv_door_sensor_one", "avattoTrvSixtyDoorSensorOne", { ON = true, OFF = false }, true),
  wave12.binary(106, "avatto_trv_door_sensor_two", "avattoTrvSixtyDoorSensorTwo", { ON = true, OFF = false }, true),
  wave12.binary(107, "avatto_trv_door_sensor_three", "avattoTrvSixtyDoorSensorThree", { ON = true, OFF = false }, true),
  wave12.numeric(109, "avatto_trv_out_temperature", "avattoTrvSixtyOutTemperature", 10, true),
  wave12.enum(117, "avatto_trv_screen_orientation", "avattoTrvSixtyScreenOrientation", { normal = 0, inverted = 1 }),
  tuya.dp_current_heating_setpoint(123, { scale = 10, emit = emit.heating_setpoint("C") }),
}
wave12.add_day_schedules(avatto, "avatto_trv", "avattoTrvSixty", 28, 4, true)
wave12.attach_setpoint_range(avatto, 5, 35, 0.5)
register_device_definition(avatto, ef00_helpers.ts0601_fingerprints({ "_TZE284_ty5neqqo" }))

local function essentials_battery(value)
  local numeric = tonumber(value)
  if numeric == nil then return nil end
  if numeric > 130 then return 100 end
  if numeric < 70 then return 0 end
  return math.floor(((numeric - 70) * 1.7) * 10 + 0.5) / 10
end

local function essentials_away(value)
  if type(value) ~= "string" or #value < 8 then return nil end
  local year, month, day, hour, minute, temperature, days_high, days_low = string.byte(value, 1, 8)
  return string.format(
    "%04d-%02d-%02d %02d:%02d/%.1f/%d",
    year + 2000, month, day, hour, minute, temperature / 2, days_high * 256 + days_low
  )
end

local essentials = {
  profile = "thermostats-wave12-essentials-trv",
  package_group = "trv",
  query_on_configure = false,
  time_start = "1970",
  tuya.dp_system_mode(2, {
    name = "system_mode",
    converter = converter.lookup_from_to({ auto = 0, heat = 1, off = 2 }),
    emit = emit.thermostat_mode(),
  }),
  tuya.dp_current_heating_setpoint(16, { scale = 2, emit = emit.heating_setpoint("C") }),
  tuya.dp_local_temperature(24, { scale = 10, read_only = true, emit = emit.temperature("C") }),
  wave12.binary(30, "essentials_trv_child_lock", "essentialsTrvChildLock", { LOCK = true, UNLOCK = false }),
  tuya.dp_battery(34, { read_only = true, from_device = essentials_battery, emit = emit.battery() }),
  wave12.numeric(101, "essentials_trv_comfort_temperature", "essentialsTrvComfortTemperature", 10, false),
  wave12.numeric(102, "essentials_trv_eco_temperature", "essentialsTrvEcoTemperature", 10, false),
  wave12.raw(103, "essentials_trv_away_setting", "essentialsTrvAwaySetting", converter.from_only(essentials_away), true),
  wave12.numeric(104, "essentials_trv_temp_calibration", "essentialsTrvTempCalibration", 10, false, { signed = true }),
  wave12.binary(107, "essentials_trv_window_open", "essentialsTrvWindowOpen", { YES = true, NO = false }, true),
  wave12.numeric(116, "essentials_trv_window_temperature", "essentialsTrvWindowTemperature", 2, false),
  wave12.numeric(117, "essentials_trv_window_time", "essentialsTrvWindowTime", 1, false),
}
thermostat_metadata.attach(essentials, { "auto", "heat", "off" }, 0.5, 29.5, 0.5)
register_device_definition(essentials, ef00_helpers.ts0601_fingerprints({ "_TZE200_i48qyn9s" }))

local function sh_battery(value)
  local numeric = tonumber(value)
  if numeric == nil then return nil end
  local percent = numeric - 50
  if percent < 0 then return 0 end
  if percent > 100 then return 100 end
  return percent
end

local sh4 = {
  profile = "thermostats-wave12-moes-sh4",
  package_group = "trv",
  query_on_configure = false,
  time_start = "1970",
  force_time_updates = true,
  wave12.enum(2, "moes_sh_preset", "moesShFourPreset", { auto = 0, manual = 1, holiday = 2 }),
  tuya.dp_current_heating_setpoint(16, { scale = 2, emit = emit.heating_setpoint("C") }),
  tuya.dp_local_temperature(24, { scale = 10, read_only = true, emit = emit.temperature("C") }),
  wave12.binary(30, "moes_sh_child_lock", "moesShFourChildLock", { LOCK = true, UNLOCK = false }),
  tuya.dp_battery(34, { read_only = true, from_device = sh_battery, emit = emit.battery() }),
  wave12.numeric(45, "moes_sh_error_status", "moesShFourErrorStatus", 1, true),
  wave12.numeric(101, "moes_sh_comfort_temperature", "moesShFourComfortTemperature", 2, false),
  wave12.numeric(102, "moes_sh_eco_temperature", "moesShFourEcoTemperature", 2, false),
  wave12.numeric(104, "moes_sh_temp_calibration", "moesShFourTempCalibration", 10, false, { signed = true }),
  wave12.numeric(105, "moes_sh_auto_override", "moesShFourAutoOverride", 2, false),
  wave12.binary(106, "moes_sh_boost_heating", "moesShFourBoostHeating", { ON = true, OFF = false }),
  wave12.binary(107, "moes_sh_window_detection", "moesShFourWindowDetection", { ON = true, OFF = false }),
  wave12.numeric(116, "moes_sh_window_temperature", "moesShFourWindowTemperature", 2, false),
  wave12.numeric(117, "moes_sh_window_time", "moesShFourWindowTime", 1, false),
  wave12.numeric(118, "moes_sh_boost_countdown", "moesShFourBoostCountdown", 1, true),
  wave12.binary(120, "moes_sh_online", "moesShFourOnline", { ON = true, OFF = false }),
}
wave12.attach_setpoint_range(sh4, 0, 30, 0.5)
register_device_definition(sh4, ef00_helpers.ts0601_fingerprints({ "_TZE200_fhn3negr" }))

local function build_tech(prefix, capability_prefix, profile, transitions, include_scale)
  local definition = {
    profile = profile,
    package_group = "trv",
    query_on_configure = false,
    time_start = "1970",
    force_time_updates = true,
    wave12.enum(2, prefix .. "_preset", capability_prefix .. "Preset", {
      manual = 0, schedule = 1, eco = 2, comfort = 3, antifrost = 4, holiday = 5,
    }),
    tuya.dp_running_state(3, {
      name = "running_state", read_only = true,
      converter = converter.from_only(converter.lookup_value({ [0] = "idle", [1] = "heating" })),
      emit = emit.thermostat_operating_state(),
    }),
    tuya.dp_current_heating_setpoint(4, { scale = 10, emit = emit.heating_setpoint("C") }),
    tuya.dp_local_temperature(5, { scale = 10, read_only = true, emit = emit.temperature("C") }),
    tuya.dp_battery(6, { read_only = true, emit = emit.battery() }),
    wave12.binary(7, prefix .. "_child_lock", capability_prefix .. "ChildLock", { LOCK = true, UNLOCK = false }),
    wave12.binary(14, prefix .. "_window_detection", capability_prefix .. "WindowDetection", { ON = true, OFF = false }),
    wave12.binary(15, prefix .. "_window_open", capability_prefix .. "WindowOpen", { ON = true, OFF = false }, true),
    wave12.numeric(21, prefix .. "_holiday_temperature", capability_prefix .. "HolidayTemperature", 10, false),
    wave12.binary(36, prefix .. "_frost_protection", capability_prefix .. "FrostProtection", { ON = true, OFF = false }),
    wave12.numeric(47, prefix .. "_temp_calibration", capability_prefix .. "TempCalibration", 10, false, { signed = true }),
    tuya.dp_binary(101, {
      name = "system_mode",
      converter = converter.lookup_from_to({ heat = true, off = false }),
      emit = emit.thermostat_mode(),
    }),
    wave12.numeric(102, prefix .. "_temperature_sensitivity", capability_prefix .. "TemperatureSensitivity", 10, false),
    wave12.numeric(103, prefix .. "_eco_temperature", capability_prefix .. "EcoTemperature", 10, false),
    wave12.numeric(104, prefix .. "_comfort_temperature", capability_prefix .. "ComfortTemperature", 10, false),
    wave12.numeric(105, prefix .. "_min_limit", capability_prefix .. "MinLimit", 10, false),
  }
  if include_scale then
    definition[#definition + 1] = wave12.binary(39, prefix .. "_scale_protection", capability_prefix .. "ScaleProtection", { ON = true, OFF = false })
  end
  wave12.add_day_schedules(definition, prefix, capability_prefix, 28, transitions, true)
  thermostat_metadata.attach(definition, { "heat", "off" }, 5, 35, 0.5)
  return definition
end

local tech_vone = build_tech("tech_vone", "techVone", "thermostats-wave12-tech-v1", 4, false)
register_device_definition(tech_vone, ef00_helpers.ts0601_fingerprints({ "_TZE204_r7brscr6" }))

local tech_vtwo = build_tech("tech_vtwo", "techVtwo", "thermostats-wave12-tech-v2", 6, true)
register_device_definition(tech_vtwo, ef00_helpers.ts0601_fingerprints({ "_TZE204_p1qrtljn" }))

return {
  id = "ef00.thermostats.wave12_trv",
  registrations = device_definitions,
}
