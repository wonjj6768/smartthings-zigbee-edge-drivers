-- Wave16 Excellux environmental sensor source-only candidates.
-- Frozen Zigbee2MQTT v26.99.0: src/devices/tuya.ts:29669-30161.

local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local function custom(capability_id)
  return assert(emit[capability_id], "missing Wave16 Excellux emitter: " .. capability_id)()
end

local function options(name, event, read_only)
  return {
    name = name,
    emit = event,
    read_only = read_only == true,
    transaction = 1,
  }
end

local function numeric(dp, name, capability_id, scale, read_only, signed)
  local mapping = options(name, custom(capability_id), read_only)
  if signed then
    mapping.signed = true
    mapping.converter = tuya.converter.signed_number_pair(scale or 1)
  elseif scale ~= nil and scale ~= 1 then
    mapping.converter = tuya.converter.divide_by_pair(scale)
  end
  return tuya.dp_numeric(dp, mapping)
end

local function standard_numeric(dp, name, event, scale, signed)
  local mapping = options(name, event, true)
  if signed then
    mapping.signed = true
    mapping.converter = tuya.converter.signed_number_pair(scale or 1)
  elseif scale ~= nil and scale ~= 1 then
    mapping.converter = tuya.converter.divide_by_pair(scale)
  end
  return tuya.dp_numeric(dp, mapping)
end

local function enum(dp, name, capability_id, values, read_only)
  local mapping = options(name, custom(capability_id), read_only)
  mapping.converter = tuya.converter.lookup_from_to(values)
  return tuya.dp_enum(dp, mapping)
end

local function definition(profile, package_group)
  return {
    profile = profile,
    package_group = package_group,
    transport_classification = "EF00_DP",
    z2m_converter_source = "meta.tuyaDatapoints",
    wire_cluster = "manuSpecificTuya",
    magic_packet = true,
    query_on_configure = false,
    time_start = "off",
    datapoints = {},
  }
end

local function add(entry, mapping)
  entry.datapoints[#entry.datapoints + 1] = mapping
end

local none_low_high = { none = 0, low = 1, high = 2 }

local airprs_one = definition("sensors-wave16-excellux-airprs1", "environment-sensor")
add(airprs_one, standard_numeric(4, "battery", emit.battery(), 1, false))
add(airprs_one, standard_numeric(5, "temperature", emit.temperature("C"), 100, true))
add(airprs_one, standard_numeric(20, "illuminance", emit.illuminance(), 1, false))
add(airprs_one, numeric(101, "airprs_one_sampling_interval", "airprsOneSamplingInterval", 1, false, false))
add(airprs_one, numeric(104, "airprs_one_illuminance_v_zero", "airprsOneIlluminanceVZero", 1, false, false))
add(airprs_one, numeric(105, "airprs_one_illuminance_v_one", "airprsOneIlluminanceVOne", 1, false, false))
add(airprs_one, numeric(106, "airprs_one_illuminance_calibration", "airprsOneIlluminanceCalibration", 1, false, true))
add(airprs_one, enum(107, "airprs_one_illuminance_warning", "airprsOneIlluminanceWarning", none_low_high, true))
add(airprs_one, numeric(108, "airprs_one_uv", "airprsOneUv", 1, true, false))
add(airprs_one, numeric(109, "airprs_one_uv_level", "airprsOneUvLevel", 10, true, false))
add(airprs_one, numeric(110, "airprs_one_uv_calibration", "airprsOneUvCalibration", 10, false, true))
add(airprs_one, enum(111, "airprs_one_uv_warning", "airprsOneUvWarning", {
  Low = 0,
  Moderate = 1,
  High = 2,
  ["Very High"] = 3,
  Extreme = 4,
}, true))
add(airprs_one, numeric(114, "airprs_one_temperature_calibration", "airprsOneTemperatureCalibration", 100, false, true))
add(airprs_one, numeric(115, "airprs_one_temperature_v_zero", "airprsOneTemperatureVZero", 100, false, true))
add(airprs_one, numeric(116, "airprs_one_temperature_v_one", "airprsOneTemperatureVOne", 100, false, true))
add(airprs_one, enum(117, "airprs_one_temperature_warning", "airprsOneTemperatureWarning", none_low_high, true))
-- Frozen exposes hPa as raw/100. The shared standard emitter emits kPa, so
-- raw/1000 preserves the same physical pressure without a unit mismatch.
add(airprs_one, standard_numeric(124, "pressure", emit.atmospheric_pressure(), 1000, false))
add(airprs_one, numeric(125, "airprs_one_pressure_calibration", "airprsOnePressureCalibration", 100, false, true))
add(airprs_one, numeric(126, "airprs_one_pressure_v_zero", "airprsOnePressureVZero", 100, false, false))
add(airprs_one, numeric(127, "airprs_one_pressure_v_one", "airprsOnePressureVOne", 100, false, false))
add(airprs_one, enum(128, "airprs_one_pressure_warning", "airprsOnePressureWarning", none_low_high, true))
add(airprs_one, enum(129, "airprs_one_pressure_trend", "airprsOnePressureTrend", {
  normal = 0,
  rise = 1,
  fall = 2,
}, true))

register_device_definition(airprs_one, device_helpers.create_fingerprints("Excellux", {
  "AIRPRS1",
}))

local function build_soil(profile, prefix, capability_prefix, include_fertility)
  local entry = definition(profile, "soil-sensor")
  local function cap(suffix)
    return capability_prefix .. suffix
  end
  local function name(suffix)
    return prefix .. suffix
  end

  add(entry, numeric(1, name("probe_temperature"), cap("ProbeTemperature"), 10, true, true))
  add(entry, standard_numeric(4, "battery", emit.battery(), 1, false))
  add(entry, standard_numeric(5, "temperature", emit.temperature("C"), 100, true))
  add(entry, numeric(101, name("sampling_interval"), cap("SamplingInterval"), 1, false, false))
  add(entry, standard_numeric(118, "humidity", emit.humidity(), 100, false))
  add(entry, numeric(108, name("probe_temperature_calibration"), cap("ProbeTemperatureCalibration"), 10, false, true))
  add(entry, numeric(109, name("probe_temperature_v_zero"), cap("ProbeTemperatureVZero"), 10, false, true))
  add(entry, numeric(110, name("probe_temperature_v_one"), cap("ProbeTemperatureVOne"), 10, false, true))
  add(entry, enum(112, name("probe_temperature_warning"), cap("ProbeTemperatureWarning"), none_low_high, true))
  add(entry, numeric(114, name("temperature_calibration"), cap("TemperatureCalibration"), 100, false, true))
  add(entry, numeric(115, name("temperature_v_zero"), cap("TemperatureVZero"), 100, false, true))
  add(entry, numeric(116, name("temperature_v_one"), cap("TemperatureVOne"), 100, false, true))
  add(entry, enum(117, name("temperature_warning"), cap("TemperatureWarning"), none_low_high, true))
  add(entry, numeric(119, name("humidity_calibration"), cap("HumidityCalibration"), 100, false, true))
  add(entry, numeric(120, name("humidity_v_zero"), cap("HumidityVZero"), 100, false, false))
  add(entry, numeric(121, name("humidity_v_one"), cap("HumidityVOne"), 100, false, false))
  add(entry, enum(122, name("humidity_warning"), cap("HumidityWarning"), none_low_high, true))

  if include_fertility then
    add(entry, numeric(124, name("fertility"), cap("Fertility"), 1, true, false))
    add(entry, numeric(125, name("fertility_v_zero"), cap("FertilityVZero"), 1, false, false))
    add(entry, numeric(126, name("fertility_v_one"), cap("FertilityVOne"), 1, false, false))
    add(entry, enum(127, name("fertility_warning"), cap("FertilityWarning"), none_low_high, true))
    add(entry, numeric(128, name("fertility_calibration"), cap("FertilityCalibration"), 1000, false, false))
  end

  add(entry, numeric(3, name("moisture"), cap("Moisture"), 1, true, false))
  add(entry, numeric(129, name("moisture_v_zero"), cap("MoistureVZero"), 1, false, false))
  add(entry, numeric(130, name("moisture_v_one"), cap("MoistureVOne"), 1, false, false))
  add(entry, numeric(131, name("moisture_calibration"), cap("MoistureCalibration"), 100, false, false))
  add(entry, enum(132, name("moisture_warning"), cap("MoistureWarning"), none_low_high, true))
  return entry
end

local ez_five_hundred_fl = build_soil(
  "sensors-wave16-excellux-ez500fl",
  "ez_fl_",
  "ezFl",
  true
)
register_device_definition(ez_five_hundred_fl, device_helpers.create_fingerprints("Excellux", {
  "EZ500FL",
}))

local ez_five_hundred_fs = build_soil(
  "sensors-wave16-excellux-ez500fs",
  "ez_fs_",
  "ezFs",
  false
)
register_device_definition(ez_five_hundred_fs, device_helpers.create_fingerprints("Excellux", {
  "EZ500FS",
}))

return {
  id = "ef00.sensors.wave16_excellux",
  registrations = device_definitions,
}
