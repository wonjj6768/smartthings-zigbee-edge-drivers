-- SONOFF/eWeLink button contracts.
-- Oracle: zigbee-herdsman-converters 26.106.0, FETCH_HEAD e2aa714 (sonoff.ts).

local zcl = require "protocol.zcl"
local device_helpers = require "contracts.helpers.family"
local device_management = require "st.zigbee.device_management"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local function snzb01p_action(_, cluster_id, command_id)
  if cluster_id ~= zcl.CLUSTER_ON_OFF then
    return nil, nil, true
  end

  local action = ({
    [0x02] = "single",
    [0x01] = "double",
    [0x00] = "long",
  })[command_id]
  return action, "main", true
end

local snzb01p = {
  profile = "sonoff-snzb01p-button",
  advanced_remote = true,
  button_count = 1,
  button_actions = { "pushed", "double", "held" },
  standard_command_action_resolver = snzb01p_action,
  standard_action_button_events = {
    single = "pushed",
    double = "double",
    long = "held",
  },
  zcl_clusters = {
    zcl.battery({
      endpoint = 1,
      minimum_interval = 3600,
      maximum_interval = 7200,
      reportable_change = 0,
      read_on_configure = true,
      read_only = true,
    }),
    zcl.battery_voltage({
      endpoint = 1,
      minimum_interval = 3600,
      maximum_interval = 7200,
      reportable_change = 0,
      read_on_configure = true,
      read_only = true,
    }),
  },
  configure = function(driver, device)
    device:send(device_management.build_bind_request(
      device,
      zcl.CLUSTER_ON_OFF,
      driver.environment_info.hub_zigbee_eui,
      1
    ))
  end,
}

register_device_definition(snzb01p, {
  device_helpers.create_fingerprint("eWeLink", "SNZB-01P"),
  -- Explicit identity authority: user-directed SONOFF Basic alias (2026-09-05).
  device_helpers.create_fingerprint("SONOFF", "SNZB-01P"),
})

return {
  id = "zcl.controls.sonoff",
  registrations = device_definitions,
}
