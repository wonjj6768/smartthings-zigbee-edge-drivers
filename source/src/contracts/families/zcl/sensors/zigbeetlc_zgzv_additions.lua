local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local fp = device_helpers.create_fingerprint
local data_types = require "st.zigbee.data_types"

local device_definitions, register = device_helpers.definition_registry()

local function core_battery_value(value, _, context)
  if context and context.raw_value == 0xFF then return nil end
  return value
end

local function core_battery(options)
  options.from_device = options.from_device or core_battery_value
  return zcl.battery(options)
end

local zigbeetlc_zgzv = {
  profile = "safety-motion-zigbeetlc-zg204zv",
  advanced_remote = true,
  remote_action_emit_name = "zgZvAction",
  capability_commands = {
    {capability_id="concertmirror08464.zgZvIdentify", command_name="setIdentifyTime",
      argument_name="identifyTime", mapping_name="zgzv_identify"},
  },
  zcl_clusters = {
    zcl.cluster_attribute(0x0003, 0, {name="zgzv_identify", endpoint=1,
      write_only=true, suppress_optimistic_state=true, tx_command_id=0,
      to_device=function(value)
        if type(value) ~= "number" or value % 1 ~= 0 or value < 1 or value > 30 then return nil end
        return string.pack("<I2", value)
      end}),
    zcl.occupancy({endpoint=1, emit=emit.motion(), minimum_interval=0, maximum_interval=3600,
      reportable_change=0, from_device=function(value)
        if type(value) == "table" then value = value.value end
        return (value & 1) ~= 0
      end}),
    zcl.illuminance({endpoint=1, minimum_interval=10, maximum_interval=3600, reportable_change=5}),
    core_battery({endpoint=1, minimum_interval=3600, maximum_interval=65000, reportable_change=10}),
    zcl.power_configuration_battery_voltage({name="battery_voltage", endpoint=1, emit=emit.voltage(),
      scale=10, read_only=true, read_on_configure=true, from_device=core_battery_value}),
    zcl.on_off({endpoint=1, emit=emit.switch(), minimum_interval=0, maximum_interval=3600, reportable_change=0}),
    zcl.cluster_attribute(0x0406, 0x0010, {name="zgzv_hold_time", endpoint=1,
      data_type=data_types.Uint16, read_only=false, read_on_configure=true, emit=emit.zgZvHoldTime()}),
    zcl.cluster_attribute(0x0406, 0x0012, {name="zgzv_motion_sensitivity", endpoint=1,
      data_type=data_types.Uint8, read_only=false, read_on_configure=true, emit=emit.zgZvMotionSensitivity()}),
    zcl.cluster_attribute(0x0006, 0x4003, {name="zgzv_power_on_behavior", endpoint=1,
      data_type=data_types.Enum8, read_only=false, read_on_configure=true, emit=emit.zgZvPowerOnBehavior(),
      from_device=function(value)
        if type(value) == "table" then value = value.value end
        return ({[0]="off",[1]="on",[2]="toggle",[255]="previous"})[value]
      end,
      to_device=function(value) return ({off=0,on=1,toggle=2,previous=255})[value] end}),
  },
}
register(zigbeetlc_zgzv, {
  fp("Sonoff", "ZG-204ZV1-z"),
  fp("Sonoff", "ZG-204ZV2-z"),
})


local zigbeetlc_zgzv_th = {
  profile = "safety-motion-zigbeetlc-zg204zv-th",
  advanced_remote = true,
  remote_action_emit_name = "zgZvThAction",
  capability_commands = {
    {capability_id="concertmirror08464.zgZvThIdentify", command_name="setIdentifyTime",
      argument_name="identifyTime", mapping_name="zgzv_th_identify"},
  },
  zcl_clusters = {
    zcl.cluster_attribute(0x0003, 0, {name="zgzv_th_identify", endpoint=1,
      write_only=true, suppress_optimistic_state=true, tx_command_id=0,
      to_device=function(value)
        if type(value) ~= "number" or value % 1 ~= 0 or value < 1 or value > 30 then return nil end
        return string.pack("<I2", value)
      end}),
    zcl.occupancy({endpoint=1, emit=emit.motion(), minimum_interval=0, maximum_interval=3600,
      reportable_change=0, from_device=function(value)
        if type(value) == "table" then value = value.value end
        return (value & 1) ~= 0
      end}),
    zcl.illuminance({endpoint=1, minimum_interval=10, maximum_interval=3600, reportable_change=5}),
    core_battery({endpoint=1, minimum_interval=3600, maximum_interval=65000, reportable_change=10}),
    zcl.power_configuration_battery_voltage({name="battery_voltage", endpoint=1, emit=emit.voltage(),
      scale=10, read_only=true, read_on_configure=true, from_device=core_battery_value}),
    zcl.on_off({endpoint=1, emit=emit.switch(), minimum_interval=0, maximum_interval=3600, reportable_change=0}),
    zcl.cluster_attribute(0x0406, 0x0010, {name="zgzv_th_hold_time", endpoint=1,
      data_type=data_types.Uint16, read_only=false, read_on_configure=true, emit=emit.zgZvThHoldTime()}),
    zcl.cluster_attribute(0x0406, 0x0012, {name="zgzv_th_motion_sensitivity", endpoint=1,
      data_type=data_types.Uint8, read_only=false, read_on_configure=true, emit=emit.zgZvThMotionSensitivity()}),
    zcl.cluster_attribute(0x0006, 0x4003, {name="zgzv_th_power_on_behavior", endpoint=1,
      data_type=data_types.Enum8, read_only=false, read_on_configure=true, emit=emit.zgZvThPowerOnBehavior(),
      from_device=function(value)
        if type(value) == "table" then value = value.value end
        return ({[0]="off",[1]="on",[2]="toggle",[255]="previous"})[value]
      end,
      to_device=function(value) return ({off=0,on=1,toggle=2,previous=255})[value] end}),
    zcl.temperature({endpoint=1, minimum_interval=10, maximum_interval=3600, reportable_change=10}),
    zcl.humidity({endpoint=1, minimum_interval=10, maximum_interval=3600, reportable_change=100}),
  },
}
register(zigbeetlc_zgzv_th, {
  fp("Sonoff", "ZG-204ZV-z"),
  fp("Sonoff", "ZG-204ZV2-TH-z"),
})

-- ZCL REPORTING CAPABILITIES BEGIN
zcl.attach_reporting_capabilities(device_definitions, {
  {1, "rpt-zsq"},
  {2, "rpt-zeg"},
})
-- ZCL REPORTING CAPABILITIES END

return {
  id = "zcl.sensors.zigbeetlc_zgzv_additions",
  registrations = device_definitions,
}
