-- Wave13 AVATTO ZBS16 source-only candidate.
-- Frozen Zigbee2MQTT v26.99.0: src/devices/avatto.ts:469-530.

local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"

local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()

local function custom(name)
  return assert(emit[name], "missing Wave13 custom emitter: " .. name)()
end

local switch_on_time_values = {
  off = 0,
  ["30 minutes"] = 1,
  ["60 minutes"] = 2,
  ["90 minutes"] = 3,
  ["120 minutes"] = 4,
  on = 5,
}

local switch_event = emit.switch()
local switch_on_time_event = custom("zbsSixteenSwitchOnTime")
local function emit_switch_on_time(device, value, dp_info, context)
  local events = {}
  local setting = switch_on_time_event(device, value, dp_info, context)
  if setting ~= nil then events[#events + 1] = setting end
  local state = switch_event(device, value ~= "off", dp_info, context)
  if state ~= nil then events[#events + 1] = state end
  return #events > 0 and events or nil
end

local zbs_sixteen = {
  profile = "switches-wave13-avatto-zbs16",
  package_group = "energy",
  transport_classification = "EF00_DP",
  z2m_converter_source = "meta.tuyaDatapoints",
  wire_cluster = "manuSpecificTuya",
  magic_packet = true,
  query_on_configure = false,
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main", emit = emit.switch() }),
    tuya.dp_numeric(20, {
      name = "energy",
      read_only = true,
      converter = converter.divide_by_from_only(1000),
      emit = emit.energy(),
    }),
    tuya.dp_numeric(21, {
      name = "zbs_sixteen_current_ma",
      read_only = true,
      emit = custom("zbsSixteenCurrentMa"),
    }),
    tuya.dp_numeric(22, {
      name = "power",
      read_only = true,
      converter = converter.divide_by_from_only(10),
      emit = emit.power(),
    }),
    tuya.dp_numeric(23, {
      name = "voltage",
      read_only = true,
      converter = converter.divide_by_from_only(10),
      emit = emit.voltage(),
    }),
    tuya.dp_numeric(101, {
      name = "zbs_sixteen_ac_frequency",
      read_only = true,
      converter = converter.divide_by_from_only(10),
      emit = custom("zbsSixteenAcFrequency"),
    }),
    tuya.dp_enum(102, {
      name = "zbs_sixteen_switch_on_time",
      converter = converter.lookup_from_to(switch_on_time_values),
      emit = emit_switch_on_time,
    }),
    tuya.dp_numeric(103, {
      name = "zbs_sixteen_countdown",
      emit = custom("zbsSixteenCountdown"),
    }),
    tuya.dp_numeric(104, {
      name = "zbs_sixteen_total_on_time",
      read_only = true,
      emit = custom("zbsSixteenTotalOnTime"),
    }),
  },
}

register_device_definition(zbs_sixteen, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_udaucpdi",
}))

return {
  id = "ef00.switches.wave13.avatto",
  registrations = device_definitions,
}
