-- Wave16 Lincukoo air-quality monitor source-only candidates.
-- Frozen Zigbee2MQTT v26.99.0: src/devices/lincukoo.ts:492-651.

local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local function custom(capability_id)
  return assert(emit[capability_id], "missing Wave16 Lincukoo air emitter: " .. capability_id)()
end

local function options(name, event, read_only)
  return {
    name = name,
    emit = event,
    read_only = read_only == true,
    transaction = 1,
  }
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

local function value_enum(dp, name, capability_id, values, read_only)
  local mapping = options(name, custom(capability_id), read_only)
  mapping.converter = tuya.converter.lookup_from_to(values)
  return tuya.dp_numeric(dp, mapping)
end

local function enum(dp, name, capability_id, values, read_only)
  local mapping = options(name, custom(capability_id), read_only)
  mapping.converter = tuya.converter.lookup_from_to(values)
  return tuya.dp_enum(dp, mapping)
end

local function binary(dp, name, capability_id, read_only)
  local mapping = options(name, custom(capability_id), read_only)
  mapping.converter = tuya.converter.lookup_from_to({ ON = true, OFF = false })
  return tuya.dp_binary(dp, mapping)
end

local function definition(profile)
  return {
    profile = profile,
    package_group = "air-quality-sensor",
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

local temperature_units = { celsius = 0, fahrenheit = 1 }

local e_zero_two_c = definition("sensors-wave16-lincukoo-e02c-z10t")
e_zero_two_c.force_time_updates = true
e_zero_two_c.time_start = "1970"
add(e_zero_two_c, standard_numeric(2, "temperature", emit.temperature("C"), 10, true))
add(e_zero_two_c, standard_numeric(3, "humidity", emit.humidity(), 1, false))
add(e_zero_two_c, standard_numeric(4, "co2", emit.co2(), 1, false))
add(e_zero_two_c, standard_numeric(22, "battery", emit.battery(), 1, false))
add(e_zero_two_c, enum(102, "e_zero_two_c_temperature_unit", "eZeroTwoCTemperatureUnit", temperature_units, false))
add(e_zero_two_c, binary(101, "e_zero_two_c_alarm_switch", "eZeroTwoCAlarmSwitch", false))
-- Frozen lookup produces a plain JS number, so this exposed enum is Tuya VALUE.
add(e_zero_two_c, value_enum(103, "e_zero_two_c_charge_status", "eZeroTwoCChargeStatus", {
  none = 0,
  charging = 1,
}, true))
add(e_zero_two_c, enum(104, "e_zero_two_c_reset_co_two", "eZeroTwoCResetCoTwo", {
  reset_co2 = 0,
}, false))
add(e_zero_two_c, enum(105, "e_zero_two_c_screen_sleep", "eZeroTwoCScreenSleep", {
  after_30s = 0,
  after_1minute = 1,
  after_2minutes = 2,
  after_5minutes = 3,
  after_10minutes = 4,
  never_sleep = 5,
}, false))
add(e_zero_two_c, numeric(106, "e_zero_two_c_co_two_alarm_value", "eZeroTwoCCoTwoAlarmValue", 1, false, false))
add(e_zero_two_c, binary(107, "e_zero_two_c_co_two_alarm", "eZeroTwoCCoTwoAlarm", true))

register_device_definition(e_zero_two_c, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_hyt4iucb",
}))

local ezc_zero_four = definition("sensors-wave16-lincukoo-ezc04")
add(ezc_zero_four, value_enum(1, "ezc_zero_four_co_two_state", "ezcZeroFourCoTwoState", {
  alarm = 0,
  normal = 1,
}, true))
add(ezc_zero_four, standard_numeric(2, "co2", emit.co2(), 1, false))
add(ezc_zero_four, enum(6, "ezc_zero_four_alarm_ringtone", "ezcZeroFourAlarmRingtone", {
  ringtone_0 = 0,
  ringtone_1 = 1,
  ringtone_2 = 2,
  ringtone_3 = 3,
}, false))
add(ezc_zero_four, standard_numeric(18, "temperature", emit.temperature("C"), 10, true))
add(ezc_zero_four, standard_numeric(19, "humidity", emit.humidity(), 1, false))
add(ezc_zero_four, numeric(26, "ezc_zero_four_co_two_alarm_value", "ezcZeroFourCoTwoAlarmValue", 1, false, false))
add(ezc_zero_four, enum(31, "ezc_zero_four_temperature_unit", "ezcZeroFourTemperatureUnit", temperature_units, false))
add(ezc_zero_four, enum(101, "ezc_zero_four_reset_co_two", "ezcZeroFourResetCoTwo", {
  reset_co2 = 0,
}, false))

register_device_definition(ezc_zero_four, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_isvlaage",
}))

local ezcp_zero_four = definition("sensors-wave16-lincukoo-ezcp04")
add(ezcp_zero_four, value_enum(1, "ezcp_zero_four_alarm_state", "ezcpZeroFourAlarmState", {
  normal = 0,
  alarm_co2 = 1,
  alarm_pm25 = 2,
}, true))
add(ezcp_zero_four, standard_numeric(2, "co2", emit.co2(), 1, false))
add(ezcp_zero_four, enum(6, "ezcp_zero_four_alarm_ringtone", "ezcpZeroFourAlarmRingtone", {
  mute = 0,
  ringtone_1 = 1,
  ringtone_2 = 2,
  ringtone_3 = 3,
}, false))
add(ezcp_zero_four, standard_numeric(18, "temperature", emit.temperature("C"), 10, true))
add(ezcp_zero_four, standard_numeric(19, "humidity", emit.humidity(), 1, false))
add(ezcp_zero_four, numeric(26, "ezcp_zero_four_co_two_alarm_value", "ezcpZeroFourCoTwoAlarmValue", 1, false, false))
add(ezcp_zero_four, enum(31, "ezcp_zero_four_temperature_unit", "ezcpZeroFourTemperatureUnit", temperature_units, false))
add(ezcp_zero_four, standard_numeric(20, "pm25", emit.pm25(), 1, false))
add(ezcp_zero_four, numeric(101, "ezcp_zero_four_pm_two_five_alarm_value", "ezcpZeroFourPm25AlarmValue", 1, false, false))

register_device_definition(ezcp_zero_four, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_fpwtjlfh",
}))

return {
  id = "ef00.sensors.wave16_lincukoo_air",
  registrations = device_definitions,
}
