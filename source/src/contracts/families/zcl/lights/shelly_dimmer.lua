local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local shelly = require "contracts.helpers.shelly_gen4"
local device_management = require "st.zigbee.device_management"
local data_types = require "st.zigbee.data_types"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local function effect_sender(device, _, value, context)
  local effect_id = ({
    blink = 0,
    breathe = 1,
    okay = 2,
    channel_change = 11,
    finish_effect = 254,
    stop_effect = 255,
  })[value]
  if effect_id == nil then return false end

  local sent = zcl.send_raw_cluster_command(
    device,
    0x0003,
    0x40,
    string.char(effect_id, 0),
    context.endpoint or 1
  )
  return sent
end

local function body_value(zb_rx, ...)
  local body = zb_rx and zb_rx.body and zb_rx.body.zcl_body or nil
  if type(body) ~= "table" then return nil end
  for index = 1, select("#", ...) do
    local value = body[select(index, ...)]
    if value ~= nil then
      return type(value) == "table" and value.value or value
    end
  end
  return nil
end

local function resolve_input_action(zb_rx, cluster_id, command_id, endpoint)
  if cluster_id == zcl.CLUSTER_ON_OFF and (endpoint == 2 or endpoint == 3 or endpoint == 4) then
    local action = ({ [0x00] = "off", [0x01] = "on", [0x02] = "toggle", [0x40] = "off" })[command_id]
    return action, "main", action ~= nil
  end

  if cluster_id == zcl.CLUSTER_LEVEL_CONTROL and endpoint == 4 then
    if command_id == 0x00 or command_id == 0x04 then
      return "brightness_move_to_level", "main", true
    elseif command_id == 0x01 or command_id == 0x05 then
      local mode = body_value(zb_rx, "move_mode", "movemode", "mode")
      if mode == 0 then return "brightness_move_up", "main", true end
      if mode == 1 then return "brightness_move_down", "main", true end
      return nil, nil, true
    elseif command_id == 0x02 or command_id == 0x06 then
      local mode = body_value(zb_rx, "step_mode", "stepmode", "mode")
      if mode == 0 then return "brightness_step_up", "main", true end
      if mode == 1 then return "brightness_step_down", "main", true end
      return nil, nil, true
    elseif command_id == 0x03 or command_id == 0x07 then
      return "brightness_stop", "main", true
    end
  end

  if cluster_id == zcl.CLUSTER_WINDOW_COVERING and endpoint == 4 then
    local action = ({ [0x00] = "open", [0x01] = "close", [0x02] = "stop" })[command_id]
    return action, "main", action ~= nil
  end

  return nil, nil, false
end

local clusters = {
  zcl.switch({ endpoint = 1, configure_reporting = false }),
  zcl.level({ endpoint = 1, configure_reporting = false }),
  zcl.power({ endpoint = 1, minimum_interval = 10, maximum_interval = 65000, physical_reportable_change = 5, read_on_configure = true }),
  zcl.voltage({ endpoint = 1, minimum_interval = 10, maximum_interval = 65000, physical_reportable_change = 5, read_on_configure = true }),
  zcl.current({ endpoint = 1, minimum_interval = 10, maximum_interval = 65000, physical_reportable_change = 0.05, read_on_configure = true }),
  zcl.energy({ endpoint = 1, minimum_interval = 10, maximum_interval = 65000, physical_reportable_change = 0.1, read_on_configure = true }),
  zcl.cluster_attribute(zcl.CLUSTER_ON_OFF, 0x4003, {
    name = "shelly_dimmer_power_on_behavior",
    endpoint = 1,
    emit = emit.shellyDimmerPowerOnBehavior(),
    from_device = function(value)
      return ({ [0] = "off", [1] = "on", [2] = "toggle", [255] = "previous" })[value]
    end,
    to_device = function(value)
      return ({ off = 0, on = 1, toggle = 2, previous = 255 })[value]
    end,
    data_type = data_types.Enum8,
    write_type = data_types.Enum8,
  }),
  zcl.cluster_attribute(0x0003, 0xFFFF, {
    name = "shelly_dimmer_effect",
    endpoint = 1,
    emit = emit.shellyDimmerEffect(),
    data_type = data_types.Enum8,
    write_only = true,
    sender = effect_sender,
  }),
}

shelly.append_wifi_mappings(clusters, "shelly_dimmer", "shellyDimmer")

local shelly_dimmer = {
  profile = "lights-shelly-dimmer-gen4",
  advanced_remote = true,
  unprefixed_remote_actions = true,
  remote_action_emit_name = "shellyDimmerAction",
  standard_action_metadata_emit_names = {
    action_group = "shellyDimmerActionGroup",
    action_level = "shellyDimmerActionLevel",
    action_transition_time = "shellyDimmerActionTransition",
    action_rate = "shellyDimmerActionRate",
    action_step_size = "shellyDimmerActionStepSize",
  },
  standard_action_endpoint_suffix = true,
  standard_command_action_resolver = resolve_input_action,
  zcl_clusters = clusters,
  zcl_refresh_before_read_all = shelly.begin_wifi_refresh,
  configure = function(driver, device)
    for _, binding in ipairs({
      { 1, zcl.CLUSTER_ELECTRICAL_MEASUREMENT },
      { 1, zcl.CLUSTER_SIMPLE_METERING },
      { 2, zcl.CLUSTER_ON_OFF },
      { 3, zcl.CLUSTER_ON_OFF },
      { 4, zcl.CLUSTER_ON_OFF },
      { 4, zcl.CLUSTER_LEVEL_CONTROL },
      { 4, zcl.CLUSTER_WINDOW_COVERING },
    }) do
      device:send(device_management.build_bind_request(
        device,
        binding[2],
        driver.environment_info.hub_zigbee_eui,
        binding[1]
      ))
    end
    shelly.refresh_wifi(device)
  end,
}

register_device_definition(shelly_dimmer, {
  device_helpers.create_fingerprint("Shelly", "Dimmer 0-1/10"),
})

return {
  id = "zcl.lights.shelly_dimmer",
  registrations = device_definitions,
}
