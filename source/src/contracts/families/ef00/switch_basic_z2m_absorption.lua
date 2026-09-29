local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"

local device_definitions, register_device_definition = device_helpers.definition_registry()
local converter = tuya.converter

local MAKEGOOD_ENERGY_FIELD = "__makegood_incremental_energy_total"

-- MakeGood DP20 is a positive energy increment in Wh/1000, not a running
-- meter. Preserve the accumulated kWh across driver restarts and seed it from
-- the last standard energyMeter state when the persisted field is absent.
local function makegood_incremental_energy_from_device(value, device)
  local raw = tonumber(value)
  if raw == nil then return nil end

  local previous = tonumber(device:get_field(MAKEGOOD_ENERGY_FIELD))
  if previous == nil and type(device.get_latest_state) == "function" then
    previous = tonumber(device:get_latest_state("main", "energyMeter", "energy"))
  end
  previous = previous or 0

  local increment = raw / 1000
  local total = previous
  if increment > 0 then
    total = math.floor((previous + increment) * 1000 + 0.5) / 1000
  end
  device:set_field(MAKEGOOD_ENERGY_FIELD, total, { persist = true })
  return total
end

-- Z2M v26.99.0 tuya.ts:8914-8942: Semicom six-switch touch panel.
-- This exact has only DP1..DP6 on/off values. It must not share the metered
-- _TZE200_8eazvzo6 definition, which additionally owns DP21..DP23.
local semicom_6switch = {
  profile = "switches-switch-6",
  package_group = "switch-basic",
  query_on_configure = false,
  tuya.dp_on_off(1, { name = "switch", component = "main" }),
  tuya.dp_on_off(2, { name = "switch", component = "switch2" }),
  tuya.dp_on_off(3, { name = "switch", component = "switch3" }),
  tuya.dp_on_off(4, { name = "switch", component = "switch4" }),
  tuya.dp_on_off(5, { name = "switch", component = "switch5" }),
  tuya.dp_on_off(6, { name = "switch", component = "switch6" }),
}

register_device_definition(semicom_6switch, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_8eazvzo6",
}))

-- Z2M 26.108.1: Unix time response is required to keep sensor reports alive.
local grxx6qek_temperature_humidity_switch = {
  profile = "switches-switch-1-temp-humidity",
  package_group = "switch-basic",
  query_on_configure = false,
  time_start = "1970",
  datapoints = {
    tuya.dp_on_off(2, {name = "switch", component = "main", suppress_optimistic_state = true}),
    tuya.dp_temperature(27, {read_only = true, scale = 10, emit = emit.temperature("C")}),
    tuya.dp_humidity(46, {read_only = true, scale = 1, emit = emit.humidity()}),
  },
}
register_device_definition(grxx6qek_temperature_humidity_switch,
  device_helpers.create_fingerprints("TS0601", {"_TZE284_grxx6qek"}))

-- Current Z2M: Zemismart ZMZ609-2 two-gang screen switch aggregate core.
local zemismart_zmz609_two_core = {
  profile = "switches-zemismart-zmz609-2-core",
  package_group = "switch-basic",
  transport_classification = "EF00_DP",
  z2m_converter_source = "meta.tuyaDatapoints",
  wire_cluster = "manuSpecificTuya",
  magic_packet = true,
  mcu_version_request_on_configure = true,
  query_on_configure = false,
  named_datapoints = true,
  time_start = "1970",
  placeholder_custom_states = false,
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main", transaction = 1, emit = emit.switch() }),
    tuya.dp_on_off(2, { name = "switch", component = "switch2", transaction = 1, emit = emit.switch() }),
    tuya.dp_energy(20, { name = "energy", scale = 1000, read_only = true, transaction = 1, emit = emit.energy() }),
    tuya.dp_current(21, { name = "current", scale = 1000, read_only = true, transaction = 1, emit = emit.current() }),
    tuya.dp_power(22, { name = "power", scale = 10, read_only = true, transaction = 1, emit = emit.power() }),
    tuya.dp_voltage(23, { name = "voltage", scale = 10, read_only = true, transaction = 1, emit = emit.voltage() }),
  },
}

register_device_definition(zemismart_zmz609_two_core, {
  device_helpers.create_fingerprint("_TZE284_o409r73p", "TS0601"),
  device_helpers.create_fingerprint("_TZE28C1000000_o409r73p", "TS0601"),
})

-- Current Z2M: Tuya TS0601_6gang_switch_2 relay and aggregate-meter core.
-- DP107 is a 61-byte shared indicator payload and is intentionally deferred
-- together with the other panel settings until its complete contract is added.
local tuya_6gang_switch_two_core = {
  profile = "switches-tuya-6gang-switch-2-core",
  package_group = "switch-basic",
  transport_classification = "EF00_DP",
  z2m_converter_source = "meta.tuyaDatapoints",
  wire_cluster = "manuSpecificTuya",
  magic_packet = true,
  mcu_version_request_on_configure = true,
  query_on_configure = false,
  named_datapoints = true,
  time_start = "off",
  placeholder_custom_states = false,
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main", transaction = 1, emit = emit.switch() }),
    tuya.dp_on_off(2, { name = "switch", component = "switch2", transaction = 1, emit = emit.switch() }),
    tuya.dp_on_off(3, { name = "switch", component = "switch3", transaction = 1, emit = emit.switch() }),
    tuya.dp_on_off(4, { name = "switch", component = "switch4", transaction = 1, emit = emit.switch() }),
    tuya.dp_on_off(5, { name = "switch", component = "switch5", transaction = 1, emit = emit.switch() }),
    tuya.dp_on_off(6, { name = "switch", component = "switch6", transaction = 1, emit = emit.switch() }),
    tuya.dp_energy(20, { name = "energy", scale = 100, read_only = true, transaction = 1, emit = emit.energy() }),
    tuya.dp_current(21, { name = "current", scale = 1000, read_only = true, transaction = 1, emit = emit.current() }),
    tuya.dp_power(22, { name = "power", scale = 10, read_only = true, transaction = 1, emit = emit.power() }),
    tuya.dp_voltage(23, { name = "voltage", scale = 10, read_only = true, transaction = 1, emit = emit.voltage() }),
    tuya.dp_on_off(136, { name = "switch", component = "all", transaction = 1, emit = emit.switch() }),
  },
}

register_device_definition(tuya_6gang_switch_two_core, {
  device_helpers.create_fingerprint("_TZE284_hbxadcl0", "TS0601"),
})

-- Current Z2M: MakeGood MG-GPO02Z double GPO standard core. DP20 is an
-- incremental energy counter; panel timers, backlight, lock, per-relay power
-- behavior and the 21-byte RGB payload remain deferred as one complete set.
local makegood_mg_gpo02z_core = {
  profile = "switches-makegood-mg-gpo02z-core",
  package_group = "switch-basic",
  transport_classification = "EF00_DP",
  z2m_converter_source = "meta.tuyaDatapoints",
  wire_cluster = "manuSpecificTuya",
  magic_packet = true,
  mcu_version_request_on_configure = true,
  query_on_configure = false,
  named_datapoints = true,
  time_start = "1970",
  placeholder_custom_states = false,
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main", transaction = 1, emit = emit.switch() }),
    tuya.dp_on_off(2, { name = "switch", component = "switch2", transaction = 1, emit = emit.switch() }),
    tuya.dp_energy(20, {
      name = "energy",
      read_only = true,
      transaction = 1,
      converter = converter.from_only(makegood_incremental_energy_from_device),
      emit = emit.energy(),
    }),
    tuya.dp_current(21, { name = "current", scale = 1000, read_only = true, transaction = 1, emit = emit.current() }),
    tuya.dp_power(22, { name = "power", scale = 10, read_only = true, transaction = 1, emit = emit.power() }),
    tuya.dp_voltage(23, { name = "voltage", scale = 10, read_only = true, transaction = 1, emit = emit.voltage() }),
    tuya.dp_on_off(136, { name = "switch", component = "all", transaction = 1, emit = emit.switch() }),
  },
}

register_device_definition(makegood_mg_gpo02z_core, {
  device_helpers.create_fingerprint("_TZE200_lq0ffndf", "TS0601"),
})

-- Current Z2M: MakeGood MG-AU03 double GPO plus light relay standard core.
-- It shares the incremental meter wire contract with MG-GPO02Z but has a
-- third relay and a 31-byte RGB payload, which remains deferred with settings.
local makegood_mg_au03_core = {
  profile = "switches-makegood-mg-au03-core",
  package_group = "switch-basic",
  transport_classification = "EF00_DP",
  z2m_converter_source = "meta.tuyaDatapoints",
  wire_cluster = "manuSpecificTuya",
  magic_packet = true,
  mcu_version_request_on_configure = true,
  query_on_configure = false,
  named_datapoints = true,
  time_start = "1970",
  placeholder_custom_states = false,
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main", transaction = 1, emit = emit.switch() }),
    tuya.dp_on_off(2, { name = "switch", component = "switch2", transaction = 1, emit = emit.switch() }),
    tuya.dp_on_off(3, { name = "switch", component = "switch3", transaction = 1, emit = emit.switch() }),
    tuya.dp_energy(20, {
      name = "energy",
      read_only = true,
      transaction = 1,
      converter = converter.from_only(makegood_incremental_energy_from_device),
      emit = emit.energy(),
    }),
    tuya.dp_current(21, { name = "current", scale = 1000, read_only = true, transaction = 1, emit = emit.current() }),
    tuya.dp_power(22, { name = "power", scale = 10, read_only = true, transaction = 1, emit = emit.power() }),
    tuya.dp_voltage(23, { name = "voltage", scale = 10, read_only = true, transaction = 1, emit = emit.voltage() }),
    tuya.dp_on_off(136, { name = "switch", component = "all", transaction = 1, emit = emit.switch() }),
  },
}

register_device_definition(makegood_mg_au03_core, {
  device_helpers.create_fingerprint("_TZE200_4jvmbiph", "TS0601"),
})

-- Current Z2M: Tuya/EyZEE MG-AU03GPOZLP-XX double GPO standard core.
-- This _TZE284 contract reports a running DP20 total and therefore must stay
-- separate from MakeGood _TZE200_lq0ffndf's incremental-energy definition.
local tuya_mg_au03gpozlp_core = {
  profile = "switches-tuya-mg-au03gpozlp-core",
  package_group = "switch-basic",
  transport_classification = "EF00_DP",
  z2m_converter_source = "meta.tuyaDatapoints",
  wire_cluster = "manuSpecificTuya",
  magic_packet = true,
  mcu_version_request_on_configure = true,
  query_on_configure = false,
  named_datapoints = true,
  time_start = "off",
  placeholder_custom_states = false,
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main", transaction = 1, emit = emit.switch() }),
    tuya.dp_on_off(2, { name = "switch", component = "switch2", transaction = 1, emit = emit.switch() }),
    tuya.dp_energy(20, { name = "energy", scale = 1000, read_only = true, transaction = 1, emit = emit.energy() }),
    tuya.dp_current(21, { name = "current", scale = 1000, read_only = true, transaction = 1, emit = emit.current() }),
    tuya.dp_power(22, { name = "power", scale = 10, read_only = true, transaction = 1, emit = emit.power() }),
    tuya.dp_voltage(23, { name = "voltage", scale = 10, read_only = true, transaction = 1, emit = emit.voltage() }),
  },
}

register_device_definition(tuya_mg_au03gpozlp_core, {
  device_helpers.create_fingerprint("_TZE284_lq0ffndf", "TS0601"),
})

return {
  id = "ef00.switch.basic.z2m_absorption",
  registrations = device_definitions,
}
