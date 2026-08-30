local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local ef00_helpers = require "contracts.helpers.ef00"
local thermostat_metadata = require "contracts.helpers.ef00_thermostat_metadata"

local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()

local function schedule_converter(day_number)
  local function from_device(value)
    if type(value) ~= "string" or #value < 17 then
      return nil
    end
    local transitions = {}
    for index = 0, 3 do
      local offset = 2 + index * 4
      local hour, minute, high, low = string.byte(value, offset, offset + 3)
      if hour == nil or minute == nil or high == nil or low == nil then
        return nil
      end
      transitions[#transitions + 1] = string.format(
        "%02d:%02d/%.1f",
        hour,
        minute,
        ((high * 256) + low) / 10
      )
    end
    return table.concat(transitions, " ")
  end

  local function to_device(value)
    if type(value) ~= "string" then
      return nil
    end
    local payload = { day_number }
    local count = 0
    for transition in string.gmatch(value, "%S+") do
      local hour_text, minute_text, temperature_text = transition:match("^(%d+):(%d+)/([%d%.%-]+)$")
      local hour = tonumber(hour_text)
      local minute = tonumber(minute_text)
      local temperature = tonumber(temperature_text)
      if hour == nil or minute == nil or temperature == nil
        or hour < 0 or hour > 24 or minute < 0 or minute > 60
        or temperature < 5 or temperature > 35 then
        return nil
      end
      local encoded_temperature = math.floor(temperature * 10)
      payload[#payload + 1] = math.floor(hour)
      payload[#payload + 1] = math.floor(minute)
      payload[#payload + 1] = math.floor(encoded_temperature / 256) % 256
      payload[#payload + 1] = encoded_temperature % 256
      count = count + 1
    end
    if count ~= 4 then
      return nil
    end
    return string.char(table.unpack(payload))
  end

  return converter.from_to(from_device, to_device)
end

local FUTUREHOME_ENERGY_FIELD = "__wave6a_futurehome_energy"
local function futurehome_energy_from_device(value, device)
  local numeric = tonumber(value)
  if numeric == nil then
    return nil
  end
  local scaled = numeric / 100
  local previous = tonumber(device:get_field(FUTUREHOME_ENERGY_FIELD)) or 0
  if scaled < previous and scaled ~= 0 then
    return previous
  end
  device:set_field(FUTUREHOME_ENERGY_FIELD, scaled, { persist = true })
  return scaled
end

local futurehome = {
  profile = "thermostats-wave6a-futurehome",
  package_group = "wall",
  query_on_configure = false,
  time_start = "2000",
  tuya.dp_system_mode(1, {
    name = "system_mode",
    converter = converter.lookup_from_to({ off = false, heat = true }),
    emit = emit.thermostat_mode(),
  }),
  tuya.dp_enum(2, {
    name = "futurehome_preset",
    converter = converter.lookup_from_to({ user = 0, home = 1, away = 2, auto = 3 }),
    emit = emit.fhThermostatPreset(),
  }),
  tuya.dp_current_heating_setpoint(16, {
    name = "current_heating_setpoint",
    scale = 1,
    emit = emit.heating_setpoint("C"),
  }),
  tuya.dp_local_temperature(24, {
    name = "local_temperature",
    scale = 1,
    read_only = true,
    emit = emit.temperature("C"),
  }),
  tuya.dp_local_temperature_calibration(28, {
    name = "futurehome_temp_calibration",
    scale = 1,
    emit = emit.fhThermostatTempCalibration(),
  }),
  tuya.dp_child_lock(30, {
    name = "futurehome_child_lock",
    converter = converter.lookup_from_to({ LOCK = true, UNLOCK = false }),
    emit = emit.fhThermostatChildLock(),
  }),
  tuya.dp_numeric(101, {
    name = "futurehome_floor_temperature",
    read_only = true,
    emit = emit.fhThermostatFloorTemperature(),
  }),
  tuya.dp_enum(102, {
    name = "futurehome_sensor",
    converter = converter.lookup_from_to({ air_sensor = 0, floor_sensor = 1, max_guard = 2 }),
    emit = emit.fhThermostatSensor(),
  }),
  tuya.dp_numeric(103, {
    name = "futurehome_hysteresis",
    emit = emit.fhThermostatHysteresis(),
  }),
  tuya.dp_running_state(104, {
    name = "running_state",
    read_only = true,
    converter = converter.lookup_from_to({ idle = false, heating = true }),
    emit = emit.thermostat_operating_state(),
  }),
  tuya.dp_binary(106, {
    name = "futurehome_window_detection",
    converter = converter.lookup_from_to({ ON = true, OFF = false }),
    emit = emit.fhThermostatWindowDetection(),
  }),
  tuya.dp_numeric(107, {
    name = "futurehome_max_guard_temp",
    emit = emit.fhThermostatMaxGuardTemp(),
  }),
  tuya.dp_numeric(123, {
    name = "energy",
    read_only = true,
    from_device = futurehome_energy_from_device,
    emit = emit.energy(),
  }),
}
thermostat_metadata.attach(futurehome, { "off", "heat" }, 5, 35, 1)
register_device_definition(futurehome, ef00_helpers.ts0601_fingerprints({
  "_TZE204_e5hpkc6d",
  "_TZE200_4hbx5cvx",
  "_TZE200_e5hpkc6d",
}))

local E40_POWER_FIELD = "__wave6a_e40_power"
local E40_MODE_FIELD = "__wave6a_e40_mode"

local function e40_power_from_device(value, device)
  local enabled = value == true or value == 1
  device:set_field(E40_POWER_FIELD, enabled, { persist = false })
  if not enabled then
    return "off"
  end
  return device:get_field(E40_MODE_FIELD) or "heat"
end

local function e40_mode_from_device(value, device)
  local mode = ({ [0] = "heat", [1] = "cool" })[tonumber(value)] or "heat"
  device:set_field(E40_MODE_FIELD, mode, { persist = false })
  if device:get_field(E40_POWER_FIELD) == false then
    return "off"
  end
  return mode
end

local function e40_system_mode_write(_, value)
  if value == "off" then
    return { { dp = 1, datatype = tuya.DP_TYPE_BOOL, value = false } }
  end
  local encoded = ({ heat = 0, cool = 1 })[value]
  if encoded == nil then
    return nil
  end
  return {
    { dp = 1, datatype = tuya.DP_TYPE_BOOL, value = true },
    { dp = 2, datatype = tuya.DP_TYPE_ENUM, value = encoded },
  }
end

local e40 = {
  profile = "thermostats-wave6a-engo-e40",
  package_group = "wall",
  query_on_configure = false,
  time_start = "1970",
  force_time_updates = true,
  tuya.dp_binary(1, {
    name = "system_mode",
    from_device = e40_power_from_device,
    read_only = true,
    emit = emit.thermostat_mode(),
  }),
  tuya.dp_enum(2, {
    name = "system_mode",
    from_device = e40_mode_from_device,
    read_only = true,
    emit = emit.thermostat_mode(),
  }),
  tuya.dp_running_state(3, {
    name = "running_state",
    read_only = true,
    converter = converter.from_only(converter.lookup_value({
      [0] = "idle",
      [2] = "heating",
      [3] = "cooling",
      [4] = "idle",
    })),
    emit = emit.thermostat_operating_state(),
  }),
  tuya.dp_current_heating_setpoint(16, { scale = 10, emit = emit.heating_setpoint("C") }),
  tuya.dp_numeric(19, {
    name = "engo_e40_max_temperature",
    converter = converter.divide_by_pair(10),
    emit = emit.engoEFortyMaxTemperature(),
  }),
  tuya.dp_local_temperature(24, { scale = 10, read_only = true, emit = emit.temperature("C") }),
  tuya.dp_numeric(26, {
    name = "engo_e40_min_temperature",
    converter = converter.divide_by_pair(10),
    emit = emit.engoEFortyMinTemperature(),
  }),
  tuya.dp_local_temperature_calibration(27, {
    name = "engo_e40_temp_calibration",
    scale = 10,
    emit = emit.engoEFortyTempCalibration(),
  }),
  tuya.dp_battery(35, { read_only = true, emit = emit.battery() }),
  tuya.dp_child_lock(40, {
    name = "engo_e40_child_lock",
    converter = converter.lookup_from_to({ LOCK = true, UNLOCK = false }),
    emit = emit.engoEFortyChildLock(),
  }),
  tuya.dp_enum(43, {
    name = "engo_e40_sensor_choose",
    converter = converter.lookup_from_to({ internal = 0, all = 1, external = 2 }),
    emit = emit.engoEFortySensorChoose(),
  }),
  tuya.dp_numeric(44, { name = "engo_e40_backlight", emit = emit.engoEFortyBacklight() }),
  tuya.dp_enum(45, {
    name = "engo_e40_comfort_floor",
    converter = converter.lookup_from_to({ OFF = 0, LEVEL1 = 1, LEVEL2 = 2, LEVEL3 = 3, LEVEL4 = 4, LEVEL5 = 5 }),
    emit = emit.engoEFortyComfortFloor(),
  }),
  tuya.dp_enum(58, {
    name = "engo_e40_preset",
    converter = converter.lookup_from_to({ manual = 0, schedule = 1, frost = 3 }),
    emit = emit.engoEFortyPreset(),
  }),
  tuya.dp_enum(101, {
    name = "engo_e40_control_algorithm",
    converter = converter.lookup_from_to({
      TPI_UFH = 0, TPI_RAD = 1, TPI_ELE = 2, HIS_02 = 3, HIS_04 = 4,
      HIS_06 = 5, HIS_08 = 6, HIS_10 = 7, HIS_20 = 8, HIS_30 = 9, HIS_40 = 10,
    }),
    emit = emit.engoEFortyControlAlgorithm(),
  }),
  tuya.dp_numeric(102, {
    name = "engo_e40_delta_algorithm",
    converter = converter.divide_by_pair(10),
    emit = emit.engoEFortyDeltaAlgorithm(),
  }),
  tuya.dp_enum(103, {
    name = "engo_e40_device_pair_state",
    read_only = true,
    converter = converter.from_only(converter.lookup_value({ [0] = "none", [1] = "commutation_center", [2] = "trv" })),
    emit = emit.engoEFortyDevicePairState(),
  }),
  tuya.dp_binary(105, {
    name = "engo_e40_temp_control_locked",
    converter = converter.lookup_from_to({ ON = true, OFF = false }),
    emit = emit.engoEFortyTempControlLocked(),
  }),
  tuya.dp_numeric(106, {
    name = "engo_e40_frost_set",
    converter = converter.divide_by_pair(10),
    emit = emit.engoEFortyFrostSet(),
  }),
  tuya.dp_enum(107, {
    name = "engo_e40_valve_protection",
    converter = converter.lookup_from_to({ off = 0, on = 1, anti_stop = 2 }),
    emit = emit.engoEFortyValveProtection(),
  }),
  tuya.dp_enum(108, {
    name = "engo_e40_relay_mode",
    converter = converter.lookup_from_to({ NO = 0, NC = 1, OFF = 2 }),
    emit = emit.engoEFortyRelayMode(),
  }),
  tuya.dp_raw(109, { name = "engo_e40_schedule_monday", converter = schedule_converter(1), emit = emit.engoEFortyScheduleMonday() }),
  tuya.dp_raw(110, { name = "engo_e40_schedule_tuesday", converter = schedule_converter(2), emit = emit.engoEFortyScheduleTuesday() }),
  tuya.dp_raw(111, { name = "engo_e40_schedule_wednesday", converter = schedule_converter(3), emit = emit.engoEFortyScheduleWednesday() }),
  tuya.dp_raw(112, { name = "engo_e40_schedule_thursday", converter = schedule_converter(4), emit = emit.engoEFortyScheduleThursday() }),
  tuya.dp_raw(113, { name = "engo_e40_schedule_friday", converter = schedule_converter(5), emit = emit.engoEFortyScheduleFriday() }),
  tuya.dp_raw(114, { name = "engo_e40_schedule_saturday", converter = schedule_converter(6), emit = emit.engoEFortyScheduleSaturday() }),
  tuya.dp_raw(115, { name = "engo_e40_schedule_sunday", converter = schedule_converter(7), emit = emit.engoEFortyScheduleSunday() }),
  tuya.dp_enum(120, {
    name = "engo_e40_sensor_error",
    read_only = true,
    converter = converter.from_only(converter.lookup_value({ [0] = "normal", [1] = "E1", [2] = "E2" })),
    emit = emit.engoEFortySensorError(),
  }),
  tuya.dp_numeric(136, {
    name = "engo_e40_latest_firmware",
    converter = converter.divide_by_pair(10),
    read_only = true,
    emit = emit.engoEFortyLatestFirmware(),
  }),
  tuya.dp_numeric(137, {
    name = "engo_e40_current_firmware",
    read_only = true,
    emit = emit.engoEFortyCurrentFirmware(),
  }),
}
local e40_named_mappings = tuya.build_named_map(e40, "name")
e40_named_mappings.system_mode = e40_system_mode_write
e40.named_mapping = { named_mappings = e40_named_mappings }
thermostat_metadata.attach(e40, { "off", "heat", "cool" }, 5, 45, 0.5)
register_device_definition(e40, ef00_helpers.ts0601_fingerprints({
  "_TZE204_lnxdk2ch",
  "_TZE204_glk6viwg",
}))

local eone = {
  profile = "thermostats-wave6a-engo-eone230w",
  package_group = "wall",
  query_on_configure = true,
  time_start = "2000",
  tuya.dp_on_off(1, { name = "switch", emit = emit.switch() }),
  tuya.dp_system_mode(2, {
    name = "system_mode",
    converter = converter.lookup_from_to({ heat = 0, cool = 1 }),
    emit = emit.thermostat_mode(),
  }),
  tuya.dp_running_state(3, {
    name = "running_state",
    read_only = true,
    converter = converter.from_only(converter.lookup_value({ [1] = "heating", [2] = "idle" })),
    emit = emit.thermostat_operating_state(),
  }),
  tuya.dp_current_heating_setpoint(16, { scale = 10, emit = emit.heating_setpoint("C") }),
  tuya.dp_numeric(19, {
    name = "engo_eone_max_temperature",
    converter = converter.divide_by_pair(10),
    emit = emit.engoEoneMaxTemperature(),
  }),
  tuya.dp_local_temperature(24, { scale = 10, read_only = true, emit = emit.temperature("C") }),
  tuya.dp_numeric(26, {
    name = "engo_eone_min_temperature",
    converter = converter.divide_by_pair(10),
    emit = emit.engoEoneMinTemperature(),
  }),
  tuya.dp_local_temperature_calibration(27, {
    name = "engo_eone_temp_calibration",
    scale = 10,
    emit = emit.engoEoneTempCalibration(),
  }),
  tuya.dp_numeric(32, {
    name = "engo_eone_holiday_temperature",
    converter = converter.divide_by_pair(10),
    emit = emit.engoEoneHolidayTemperature(),
  }),
  tuya.dp_numeric(33, { name = "engo_eone_holiday_days", emit = emit.engoEoneHolidayDays() }),
  tuya.dp_numeric(34, { name = "humidity", read_only = true, emit = emit.humidity() }),
  tuya.dp_child_lock(40, {
    name = "engo_eone_child_lock",
    converter = converter.lookup_from_to({ LOCK = true, UNLOCK = false }),
    emit = emit.engoEoneChildLock(),
  }),
  tuya.dp_enum(43, {
    name = "engo_eone_sensor_choose",
    converter = converter.lookup_from_to({ internal = 0, floor_temp = 1, external = 2, external_on_off = 3 }),
    emit = emit.engoEoneSensorChoose(),
  }),
  tuya.dp_numeric(44, { name = "engo_eone_backlight", emit = emit.engoEoneBacklight() }),
  tuya.dp_enum(58, {
    name = "engo_eone_preset",
    converter = converter.lookup_from_to({ manual = 0, schedule = 1, holiday = 2, frost = 5 }),
    emit = emit.engoEonePreset(),
  }),
  tuya.dp_enum(101, {
    name = "engo_eone_control_algorithm",
    converter = converter.lookup_from_to({
      TPI_UFH = 0, TPI_RAD = 1, TPI_ELE = 2, HIS_02 = 3, HIS_04 = 4,
      HIS_06 = 5, HIS_08 = 6, HIS_10 = 7, HIS_20 = 8, HIS_30 = 9, HIS_40 = 10,
    }),
    emit = emit.engoEoneControlAlgorithm(),
  }),
  tuya.dp_numeric(102, {
    name = "engo_eone_max_floor_heating",
    converter = converter.divide_by_pair(10),
    emit = emit.engoEoneMaxFloorHeating(),
  }),
  tuya.dp_numeric(103, {
    name = "engo_eone_min_floor_heating",
    converter = converter.divide_by_pair(10),
    emit = emit.engoEoneMinFloorHeating(),
  }),
  tuya.dp_numeric(104, {
    name = "engo_eone_max_floor_cooling",
    converter = converter.divide_by_pair(10),
    emit = emit.engoEoneMaxFloorCooling(),
  }),
  tuya.dp_numeric(105, {
    name = "engo_eone_min_floor_cooling",
    converter = converter.divide_by_pair(10),
    emit = emit.engoEoneMinFloorCooling(),
  }),
  tuya.dp_numeric(106, {
    name = "engo_eone_frost_set",
    converter = converter.divide_by_pair(10),
    emit = emit.engoEoneFrostSet(),
  }),
  tuya.dp_enum(108, {
    name = "engo_eone_relay_mode",
    converter = converter.lookup_from_to({ NO = 0, NC = 1, OFF = 2 }),
    emit = emit.engoEoneRelayMode(),
  }),
  tuya.dp_raw(109, { name = "engo_eone_schedule_monday", converter = schedule_converter(1), emit = emit.engoEoneScheduleMonday() }),
  tuya.dp_raw(110, { name = "engo_eone_schedule_tuesday", converter = schedule_converter(2), emit = emit.engoEoneScheduleTuesday() }),
  tuya.dp_raw(111, { name = "engo_eone_schedule_wednesday", converter = schedule_converter(3), emit = emit.engoEoneScheduleWednesday() }),
  tuya.dp_raw(112, { name = "engo_eone_schedule_thursday", converter = schedule_converter(4), emit = emit.engoEoneScheduleThursday() }),
  tuya.dp_raw(113, { name = "engo_eone_schedule_friday", converter = schedule_converter(5), emit = emit.engoEoneScheduleFriday() }),
  tuya.dp_raw(114, { name = "engo_eone_schedule_saturday", converter = schedule_converter(6), emit = emit.engoEoneScheduleSaturday() }),
  tuya.dp_raw(115, { name = "engo_eone_schedule_sunday", converter = schedule_converter(7), emit = emit.engoEoneScheduleSunday() }),
  tuya.dp_numeric(116, {
    name = "engo_eone_floor_temperature",
    converter = converter.divide_by_pair(10),
    read_only = true,
    emit = emit.engoEoneFloorTemperature(),
  }),
  tuya.dp_enum(117, {
    name = "engo_eone_temp_resolution",
    converter = converter.lookup_from_to({ one = 0, five = 1 }),
    emit = emit.engoEoneTempResolution(),
  }),
  tuya.dp_enum(118, {
    name = "engo_eone_comfort_floor",
    converter = converter.lookup_from_to({ OFF = 0, LEVEL1 = 1, LEVEL2 = 2, LEVEL3 = 3, LEVEL4 = 4, LEVEL5 = 5 }),
    emit = emit.engoEoneComfortFloor(),
  }),
  tuya.dp_enum(120, {
    name = "engo_eone_sensor_error",
    read_only = true,
    converter = converter.from_only(converter.lookup_value({ [0] = "normal", [1] = "E1", [2] = "E2" })),
    emit = emit.engoEoneSensorError(),
  }),
  tuya.dp_enum(122, {
    name = "engo_eone_valve_protection",
    converter = converter.lookup_from_to({ off = 0, on = 1, anti_stop = 2 }),
    emit = emit.engoEoneValveProtection(),
  }),
}
thermostat_metadata.attach(eone, { "heat", "cool" }, 5, 45, 0.5)
register_device_definition(eone, ef00_helpers.ts0601_fingerprints({
  "_TZE204_ca3i8m8p",
  "_TZE200_awnadkan",
}))

return {
  id = "ef00.thermostats.wave6a_wall",
  registrations = device_definitions,
}
