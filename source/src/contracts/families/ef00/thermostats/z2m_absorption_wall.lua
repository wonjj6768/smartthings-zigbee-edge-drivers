-- Current Z2M: Heat Decor HD-T1000 floor thermostat core.
-- Advanced schedule, protection, limit, calibration and child-lock DPs remain
-- deferred until their family-specific capability contracts are implemented.

local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local ef00_helpers = require "contracts.helpers.ef00"
local thermostat_metadata = require "contracts.helpers.ef00_thermostat_metadata"

local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()

local hd_t1000 = {
  profile = "thermostats-floor-hd-t1000-core",
  package_group = "wall-2",
  magic_packet = true,
  mcu_version_request_on_configure = true,
  query_on_configure = false,
  time_start = "off",
  tuya.dp_binary(1, {
    name = "system_mode",
    converter = converter.lookup_from_to({ off = false, heat = true }),
    emit = emit.thermostat_mode(),
  }),
  tuya.dp_running_state(3, {
    name = "running_state",
    read_only = true,
    converter = converter.from_only(function(value)
      return ({ [0] = "heating", [1] = "idle" })[tonumber(value)]
    end),
    emit = emit.thermostat_operating_state(),
  }),
  tuya.dp_current_heating_setpoint(16, {
    name = "current_heating_setpoint",
    scale = 10,
    emit = emit.heating_setpoint("C"),
  }),
  tuya.dp_local_temperature(24, {
    name = "local_temperature",
    scale = 10,
    read_only = true,
    emit = emit.temperature("C"),
  }),
}

thermostat_metadata.attach(hd_t1000, { "off", "heat" }, 5, 35, 0.5)
register_device_definition(hd_t1000, ef00_helpers.ts0601_fingerprints({
  "_TZE200_spyvfeti",
}))

return {
  id = "ef00.thermostats.z2m_absorption_wall",
  registrations = device_definitions,
}
