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

local beca_bvrf_l001 = {
  profile="thermostats-beca-bvrf-l001",
  package_group="wall-2",
  magic_packet=true,
  mcu_version_request_on_configure=true,
  query_on_configure=false,
  query_on_announce=false,
  time_start="off",
  datapoints={
    tuya.dp_on_off(1,{name="switch",emit=emit.switch()}),
    tuya.dp_enum(2,{
      name="system_mode",emit=emit.thermostat_mode(),
      converter=converter.lookup_from_to({cool=0,heat=1,fanonly=2,dryair=3}),
    }),
    tuya.dp_current_heating_setpoint(16,{
      emit=emit.heating_setpoint("C"),
      converter=converter.from_to(function(value) return value/10 end,
      function(value)
        if type(value)=="number" and value%1==0 and value>=16 and value<=32 then return value*10 end
      end),
    }),
    tuya.dp_local_temperature(24,{read_only=true,scale=10,emit=emit.temperature("C")}),
    tuya.dp_binary(40,{
      name="bvrf_l001_child_lock",emit=emit.bvrfL001ChildLock(),
      converter=converter.lookup_from_to({LOCK=true,UNLOCK=false}),
    }),
    tuya.dp_enum(49,{
      name="bvrf_l001_fan_mode",emit=emit.bvrfL001FanMode(),
      converter=converter.lookup_from_to({auto=0,low=1,medium=2,high=3}),
    }),
  },
}
thermostat_metadata.attach(beca_bvrf_l001,{"cool","heat","fanonly","dryair"},16,32,1)
register_device_definition(beca_bvrf_l001,ef00_helpers.ts0601_fingerprints({"_TZE204_6ewjlefg"}))

return {
  id = "ef00.thermostats.z2m_absorption_wall",
  registrations = device_definitions,
}
