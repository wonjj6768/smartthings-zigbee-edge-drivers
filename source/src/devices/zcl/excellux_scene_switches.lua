local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local emit = require "emitters"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local function battery_percent_from_voltage(voltage)
  if type(voltage) ~= "number" then
    return voltage
  end

  local percent = math.floor((((voltage - 2.0) / 1.0) * 100) + 0.5)
  if percent < 0 then
    return 0
  end
  if percent > 100 then
    return 100
  end

  return percent
end

local excellux_scene_switch = {
  profile = "buttons-button-1-battery-operation-mode-remote-action",
  advanced_remote = true,
  unprefixed_remote_actions = true,
  button_actions = { "pushed", "double", "held" },
  button_count = 1,
  zcl_initial_writes = {
    { name = "operation_mode", value = "event" },
  },
  zcl_clusters = {
    zcl.battery({ endpoint = 1, read_on_configure = true }),
    zcl.cluster_attribute(zcl.CLUSTER_POWER_CONFIGURATION, zcl.ATTR_BATTERY_VOLTAGE, {
      name = "battery_voltage",
      endpoint = 1,
      emit = emit.battery(),
      scale = 10,
      from_device = battery_percent_from_voltage,
      read_on_configure = true,
    }),
    zcl.operation_mode(),
  },
}

register_device_definition(excellux_scene_switch, {
  device_helpers.create_fingerprint("DSS0010", "Excellux"),
})

return device_definitions
