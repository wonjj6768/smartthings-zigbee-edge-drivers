local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"

local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()
local valve_open_closed_converter = converter.lookup_from_to({
  open = true,
  closed = false,
})

-- Z2M v26.99.0: GIEX QT06_1/QT06_2.
local GIEX_JAN_2000_UTC = 946684800
local GIEX_GMT8_OFFSET = 8 * 60 * 60
local GIEX_ST_NUMERIC_MAX = 2147483647
local GIEX_QT06_TWO_MODE_FIELD = "giex_qt06_two_irrigation_mode"

local giex_mode_converter = converter.lookup_from_to({
  duration = false,
  capacity = true,
})

local function giex_local_epoch(now)
  local local_time = os.date("*t", now)
  local utc_time = os.date("!*t", now)
  local offset = os.difftime(os.time(local_time), os.time(utc_time))
  return now + offset
end

local function giex_send_time(device, now)
  local utc_time = now or os.time()
  return tuya.send_time(device, utc_time, giex_local_epoch(utc_time))
end

local function giex_time_handler(device)
  return giex_send_time(device)
end

local function giex_january_2000_local_offset()
  local local_time = os.date("*t", GIEX_JAN_2000_UTC)
  local utc_time = os.date("!*t", GIEX_JAN_2000_UTC)
  return os.difftime(os.time(local_time), os.time(utc_time))
end

local GIEX_QT06_ONE_CLOCK_DELTA = giex_january_2000_local_offset() - GIEX_GMT8_OFFSET

local function giex_qt06_one_time_from_device(value)
  if value == "--:--:--" then return value end
  local hour, minute, second = value:match("^(%d%d):(%d%d):(%d%d)$")
  local seconds = (
    tonumber(hour) * 60 * 60 + tonumber(minute) * 60 + tonumber(second) +
    GIEX_QT06_ONE_CLOCK_DELTA
  ) % (24 * 60 * 60)
  local local_hour = math.floor(seconds / (60 * 60))
  local local_minute = math.floor((seconds % (60 * 60)) / 60)
  local local_second = seconds % 60
  return string.format("%02d:%02d:%02d", local_hour, local_minute, local_second)
end

local function giex_last_duration_from_device(value)
  return value:match("^[^,]*")
end

local function giex_water_consumed_from_device(value)
  return math.min(value, GIEX_ST_NUMERIC_MAX)
end

local function giex_qt06_two_target_to_device(value, device)
  local mode = device:get_field(GIEX_QT06_TWO_MODE_FIELD)
  if mode == nil and type(device.get_latest_state) == "function" then
    mode = device:get_latest_state(
      "main",
      "concertmirror08464.giexQtTwoMode",
      "giexQtTwoMode"
    )
  end
  if value > 0 and value < 10 and mode == "duration" then return 10 end
  return value
end

local function giex_water_valve_definition(options)
  local prefix = options.mapping_prefix
  return {
    profile = options.profile,
    time_start = "1970",
    time_handler = giex_time_handler,
    force_time_updates = true,
    initial_custom_state_query = false,
    refresh_state_query = false,
    tuya.dp_binary(1, {
      name = prefix .. "irrigation_mode",
      field = options.mode_field,
      emit = options.mode_emit,
      converter = giex_mode_converter,
    }),
    tuya.dp_on_off(2, {
      name = prefix .. "state",
      emit = emit.valve(),
      converter = valve_open_closed_converter,
    }),
    tuya.dp_string(101, {
      name = prefix .. "irrigation_start_time",
      read_only = true,
      emit = options.start_time_emit,
      converter = options.time_converter,
    }),
    tuya.dp_string(102, {
      name = prefix .. "irrigation_end_time",
      read_only = true,
      emit = options.end_time_emit,
      converter = options.time_converter,
    }),
    tuya.dp_numeric(103, {
      name = prefix .. "cycle_irrigation_num_times",
      emit = options.cycle_count_emit,
    }),
    tuya.dp_numeric(104, {
      name = prefix .. "irrigation_target",
      emit = options.target_emit,
      converter = options.target_converter,
      optimistic_value = options.target_optimistic_value,
    }),
    tuya.dp_numeric(105, {
      name = prefix .. "cycle_irrigation_interval",
      emit = options.cycle_interval_emit,
    }),
    tuya.dp_numeric(106, {
      name = prefix .. "current_temperature_ignored",
      read_only = true,
    }),
    tuya.dp_battery(108, {
      name = prefix .. "battery",
      read_only = true,
      emit = emit.battery(),
    }),
    tuya.dp_numeric(111, {
      name = prefix .. "water_consumed",
      read_only = true,
      emit = options.water_consumed_emit,
      converter = converter.from_only(giex_water_consumed_from_device),
    }),
    tuya.dp_string(114, {
      name = prefix .. "last_irrigation_duration",
      read_only = true,
      emit = options.last_duration_emit,
      converter = converter.from_only(giex_last_duration_from_device),
    }),
  }
end

local giex_qt06_one = giex_water_valve_definition({
  profile = "valves-giex-qt06-one",
  mapping_prefix = "giex_qt06_one_",
  mode_field = "giex_qt06_one_irrigation_mode",
  mode_emit = emit.giexQtOneMode(),
  target_emit = emit.giexQtOneTarget(),
  cycle_count_emit = emit.giexQtOneCycleCount(),
  cycle_interval_emit = emit.giexQtOneCycleInterval(),
  start_time_emit = emit.giexQtOneStartTime(),
  end_time_emit = emit.giexQtOneEndTime(),
  last_duration_emit = emit.giexQtOneLastDuration(),
  water_consumed_emit = emit.giexQtOneWaterConsumed(),
  time_converter = converter.from_only(giex_qt06_one_time_from_device),
})

register_device_definition(giex_qt06_one, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_sh1btabb",
}))

local giex_qt06_two = giex_water_valve_definition({
  profile = "valves-giex-qt06-two",
  mapping_prefix = "giex_qt06_two_",
  mode_field = GIEX_QT06_TWO_MODE_FIELD,
  mode_emit = emit.giexQtTwoMode(),
  target_emit = emit.giexQtTwoTarget(),
  cycle_count_emit = emit.giexQtTwoCycleCount(),
  cycle_interval_emit = emit.giexQtTwoCycleInterval(),
  start_time_emit = emit.giexQtTwoStartTime(),
  end_time_emit = emit.giexQtTwoEndTime(),
  last_duration_emit = emit.giexQtTwoLastDuration(),
  water_consumed_emit = emit.giexQtTwoWaterConsumed(),
  target_converter = converter.to_only(giex_qt06_two_target_to_device),
  target_optimistic_value = giex_qt06_two_target_to_device,
})

register_device_definition(giex_qt06_two, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_a7sghmms",
  "_TZE204_a7sghmms",
  "_TZE204_7ytb3h8u",
  "_TZE200_7ytb3h8u",
  "_TZE284_7ytb3h8u",
}))

-- Z2M v26.99.0: IOTPerfect PF-PM02D-TYZ water/gas valve.
local pf_pm02d_fault_converter = converter.from_only(function(value)
  return value ~= 0
end)

local iotperfect_pf_pm02d = {
  profile = "valves-iotperfect-pf-pm02d",
  query_on_configure = true,
  tuya.dp_on_off(1, { name = "switch", emit = emit.switch() }),
  tuya.dp_bitmap(26, {
    name = "fault",
    read_only = true,
    emit = emit.hardware_fault(),
    converter = pf_pm02d_fault_converter,
  }),
}

register_device_definition(iotperfect_pf_pm02d, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_vrjkcam9",
  "_TZE200_d0ypnbvn",
  "_TZE204_v5xjyphj",
  "_TZE204_d0ypnbvn",
  "_TZE284_v5xjyphj",
  "_TZE284_d0ypnbvn",
}))

return {
  id = "ef00.valves.z2m_absorption",
  registrations = device_definitions,
}
