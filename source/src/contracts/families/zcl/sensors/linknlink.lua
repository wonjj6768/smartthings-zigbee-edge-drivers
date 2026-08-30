local zcl = require "protocol.zcl"
local device_helpers = require "contracts.helpers.family"
local device_management = require "st.zigbee.device_management"

local device_definitions, register_device_definition = device_helpers.definition_registry()

-- Z2M v26.99.0 modernExtend commandsOnOff/commandsLevelCtrl contract.
-- Returning handled=true prevents the shared resolver from changing these names.
local function resolve_action(zb_rx, cluster_id, command_id)
  if cluster_id == zcl.CLUSTER_ON_OFF then
    local action = ({ [0x00] = "off", [0x01] = "on", [0x02] = "toggle", [0x40] = "off" })[command_id]
    return action, "main", action ~= nil
  end

  if cluster_id ~= zcl.CLUSTER_LEVEL_CONTROL then return nil, nil, false end
  if command_id == 0x00 or command_id == 0x04 then
    return "brightness_move_to_level", "main", true
  end

  local body = zb_rx and zb_rx.body and zb_rx.body.zcl_body or nil
  if command_id == 0x01 or command_id == 0x05 then
    local mode = body and (body.move_mode or body.movemode or body.mode) or nil
    mode = type(mode) == "table" and mode.value or mode
    if mode == 0 then return "brightness_move_up", "main", true end
    if mode == 1 then return "brightness_move_down", "main", true end
    return nil, nil, true
  end
  if command_id == 0x02 or command_id == 0x06 then
    local mode = body and (body.step_mode or body.stepmode or body.mode) or nil
    mode = type(mode) == "table" and mode.value or mode
    if mode == 0 then return "brightness_step_up", "main", true end
    if mode == 1 then return "brightness_step_down", "main", true end
    return nil, nil, true
  end
  if command_id == 0x03 or command_id == 0x07 then
    return "brightness_stop", "main", true
  end
  return nil, nil, false
end

local emotion_air = {
  profile = "sensors-linknlink-emotion-air",
  advanced_remote = true,
  unprefixed_remote_actions = true,
  remote_action_emit_name = "linknLinkEmotionAirAction",
  standard_action_metadata_emit_names = {
    action_group = "linknLinkEmotionAirActionGroup",
    action_level = "linknLinkEmotionAirActionLevel",
    action_transition_time = "linknAirActionTransition",
    action_rate = "linknLinkEmotionAirActionRate",
    action_step_size = "linknAirActionStepSize",
  },
  standard_command_action_resolver = resolve_action,
  zcl_clusters = {
    zcl.temperature({
      minimum_interval = 10,
      maximum_interval = 3600,
      reportable_change = 100,
      read_on_configure = true,
    }),
    zcl.humidity({
      minimum_interval = 10,
      maximum_interval = 3600,
      reportable_change = 100,
      read_on_configure = true,
    }),
    zcl.illuminance({
      minimum_interval = 10,
      maximum_interval = 3600,
      reportable_change = 5,
      read_on_configure = true,
    }),
    zcl.occupancy({
      minimum_interval = 0,
      maximum_interval = 3600,
      reportable_change = 0,
      read_on_configure = true,
    }),
    zcl.battery({
      minimum_interval = 3600,
      maximum_interval = 65000,
      reportable_change = 10,
      read_on_configure = true,
    }),
  },
  configure = function(driver, device)
    for _, cluster_id in ipairs({
      zcl.CLUSTER_ON_OFF,
      zcl.CLUSTER_LEVEL_CONTROL,
    }) do
      device:send(device_management.build_bind_request(
        device,
        cluster_id,
        driver.environment_info.hub_zigbee_eui,
        1
      ))
    end
  end,
}

register_device_definition(emotion_air, {
  device_helpers.create_fingerprint("LinknLink", "eMotion Air"),
})

return {
  id = "zcl.sensors.linknlink",
  registrations = device_definitions,
}
