-- Current Z2M 8e3b01c: Tuya TS0001 Fingerbot Plus.
--
-- The actuator itself uses the standard OnOff cluster. Tuya EF00 carries the
-- battery and the six settings that Z2M exposes. DP109 program data remains
-- internal because upstream does not expose a public contract for it.

local tuya = require "protocol.tuya"
local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"

local converter = tuya.converter
local registrations, register_device_definition = device_helpers.definition_registry()

local function custom(capability_id)
  return assert(emit[capability_id], "missing Fingerbot Plus emitter: " .. capability_id)()
end

local definition = {
  profile = "controls-tuya-fingerbot-plus",
  package_group = "finger-robot",
  transport_classification = "HYBRID_ZCL_EF00",
  z2m_converter_source = "fz.on_off + tz.on_off + meta.tuyaDatapoints",
  wire_cluster = "genOnOff+manuSpecificTuya",
  magic_packet = true,
  query_on_configure = false,
  time_start = "off",
  datapoints = {
    tuya.dp_enum(101, {
      name = "tuya_fingerbot_mode",
      converter = converter.lookup_from_to({ click = 0, switch = 1, program = 2 }),
      emit = custom("tuyaFingerbotMode"),
    }),
    tuya.dp_numeric(102, {
      name = "tuya_fingerbot_lower_limit",
      emit = custom("tuyaFingerbotLowerLimit"),
    }),
    tuya.dp_numeric(103, {
      name = "tuya_fingerbot_delay",
      emit = custom("tuyaFingerbotDelay"),
    }),
    tuya.dp_enum(104, {
      name = "tuya_fingerbot_reverse",
      converter = converter.lookup_from_to({ ON = 1, OFF = 0 }),
      emit = custom("tuyaFingerbotReverse"),
    }),
    tuya.dp_battery(105, {
      name = "battery",
      read_only = true,
      emit = emit.battery(),
    }),
    tuya.dp_numeric(106, {
      name = "tuya_fingerbot_upper_limit",
      emit = custom("tuyaFingerbotUpperLimit"),
    }),
    tuya.dp_binary(107, {
      name = "tuya_fingerbot_touch",
      converter = converter.lookup_from_to({ ON = true, OFF = false }),
      emit = custom("tuyaFingerbotTouch"),
    }),
  },
  zcl_clusters = {
    zcl.switch({ read_only = false, emit = emit.switch() }),
  },
}

register_device_definition(definition, device_helpers.create_fingerprints("TS0001", {
  "_TZ3210_dse8ogfy",
  "_TZ3210_j4pdtz9v",
  "_TZ3210_7vgttna6",
  "_TZ3210_a04acm9s",
  "_TZ3210_cm9mbpr1",
}))

return {
  id = "ef00.controls.tuya_fingerbot_plus",
  registrations = registrations,
}
