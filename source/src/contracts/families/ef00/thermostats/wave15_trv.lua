-- Wave15 Moes ZTRV-S01 source-only candidate.
-- Frozen Zigbee2MQTT v26.99.0: src/devices/moes.ts:843-925.

local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local thermostat_wave = require "contracts.helpers.ef00_thermostat_wave12"

local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()

local function custom(name)
  return assert(emit[name], "missing Wave15 ZTRV emitter: " .. name)()
end

local function custom_numeric(dp, name, capability, divisor, options)
  options = options or {}
  return tuya.dp_numeric(dp, {
    name = name,
    read_only = options.read_only == true,
    signed = options.signed == true,
    transaction = 1,
    -- Tuya VALUE reports are decoded as unsigned in dp_info.value and expose
    -- their two's-complement interpretation separately as signed_value.
    converter = options.signed == true
      and converter.signed_number_pair(divisor or 1)
      or (divisor ~= nil and divisor ~= 1 and converter.divide_by_pair(divisor) or nil),
    emit = custom(capability),
  })
end

local ztrv = {
  profile = "thermostats-wave15-moes-ztrv-s01",
  package_group = "trv",
  transport_classification = "EF00_DP",
  z2m_converter_source = "meta.tuyaDatapoints",
  wire_cluster = "manuSpecificTuya",
  magic_packet = true,
  query_on_configure = false,
  time_start = "2000",
  datapoints = {
    tuya.dp_enum(2, {
      name = "ztrv_preset", transaction = 1,
      -- Frozen expose omits converter code 4 (holiday); fail closed until a
      -- real report establishes whether that hidden state is reachable.
      converter = converter.lookup_from_to({ auto = 0, manual = 1, off = 2, on = 3 }),
      emit = custom("ztrvPreset"),
    }),
    tuya.dp_numeric(3, {
      name = "running_state", read_only = true, transaction = 1,
      converter = converter.from_only(function(value)
        return ({ [0] = "heating", [1] = "idle" })[tonumber(value)]
      end),
      emit = emit.thermostat_operating_state(),
    }),
    tuya.dp_battery(6, { name = "battery", read_only = true, transaction = 1, emit = emit.battery() }),
    tuya.dp_binary(7, {
      name = "ztrv_child_lock", transaction = 1,
      converter = converter.lookup_from_to({ LOCK = true, UNLOCK = false }),
      emit = custom("ztrvChildLock"),
    }),
    custom_numeric(9, "ztrv_max_temperature", "ztrvMaxTemperature", 10),
    custom_numeric(10, "ztrv_min_temperature", "ztrvMinTemperature", 10),
    tuya.dp_binary(14, {
      name = "ztrv_window_detection", transaction = 1,
      converter = converter.lookup_from_to({ ON = true, OFF = false }),
      emit = custom("ztrvWindowDetection"),
    }),
    tuya.dp_enum(15, {
      name = "ztrv_window_state", read_only = true, transaction = 1,
      converter = converter.from_only(converter.lookup_value({ [0] = "CLOSED", [1] = "OPENED" })),
      emit = custom("ztrvWindowState"),
    }),
  },
}

local days = {
  { "monday", "Monday" }, { "tuesday", "Tuesday" }, { "wednesday", "Wednesday" },
  { "thursday", "Thursday" }, { "friday", "Friday" }, { "saturday", "Saturday" },
  { "sunday", "Sunday" },
}
for index, day in ipairs(days) do
  ztrv.datapoints[#ztrv.datapoints + 1] = tuya.dp_raw(27 + index, {
    name = "ztrv_schedule_" .. day[1],
    transaction = 1,
    converter = thermostat_wave.schedule_converter(index, 4),
    emit = custom("ztrvSchedule" .. day[2]),
  })
end

ztrv.datapoints[#ztrv.datapoints + 1] = tuya.dp_binary(36, {
  name = "ztrv_frost_protection", transaction = 1,
  converter = converter.lookup_from_to({ ON = true, OFF = false }),
  emit = custom("ztrvFrostProtection"),
})
ztrv.datapoints[#ztrv.datapoints + 1] = custom_numeric(
  47, "ztrv_temp_calibration", "ztrvTempCalibration", 10, { signed = true }
)
ztrv.datapoints[#ztrv.datapoints + 1] = custom_numeric(
  102, "ztrv_valve_position", "ztrvValvePosition", 1, { read_only = true }
)
ztrv.datapoints[#ztrv.datapoints + 1] = tuya.dp_enum(103, {
  name = "ztrv_screen_orientation", transaction = 1,
  converter = converter.lookup_from_to({ ["0"] = 0, ["1"] = 1 }),
  emit = custom("ztrvScreenOrientation"),
})
ztrv.datapoints[#ztrv.datapoints + 1] = custom_numeric(
  105, "ztrv_eco_temperature", "ztrvEcoTemperature", 10
)
ztrv.datapoints[#ztrv.datapoints + 1] = tuya.dp_binary(106, {
  name = "ztrv_eco_mode", transaction = 1,
  converter = converter.lookup_from_to({ ON = true, OFF = false }),
  emit = custom("ztrvEcoMode"),
})
ztrv.datapoints[#ztrv.datapoints + 1] = tuya.dp_numeric(108, {
  name = "current_heating_setpoint", transaction = 1,
  converter = converter.divide_by_pair(10),
  emit = emit.heating_setpoint("C"),
})
ztrv.datapoints[#ztrv.datapoints + 1] = tuya.dp_numeric(109, {
  name = "local_temperature", read_only = true, transaction = 1,
  converter = converter.divide_by_pair(10),
  emit = emit.temperature("C"),
})

thermostat_wave.attach_setpoint_range(ztrv, 5, 35, 0.5)
register_device_definition(ztrv, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_ivdc0kwl",
}))

return {
  id = "ef00.thermostats.wave15_trv",
  registrations = device_definitions,
}
