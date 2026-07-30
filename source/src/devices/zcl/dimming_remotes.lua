local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local device_management = require "st.zigbee.device_management"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local dimming_remote = {
  profile = "controllers-dimming-remote-action",
  advanced_remote = true,
  unprefixed_remote_actions = true,
  tuya_action_name = "switch_scene",
  zcl_clusters = {},
}

local function body_member_value(zb_rx, ...)
  local body = zb_rx and zb_rx.body and zb_rx.body.zcl_body or nil
  if type(body) ~= "table" then
    return nil
  end

  for _, key in ipairs({ ... }) do
    local value = body[key]
    if type(value) == "table" and value.value ~= nil then
      return value.value
    end
    if value ~= nil then
      return value
    end
  end
end

local function bind_clusters(driver, device, endpoint, cluster_ids)
  for _, cluster_id in ipairs(cluster_ids) do
    device:send(device_management.build_bind_request(
      device,
      cluster_id,
      driver.environment_info.hub_zigbee_eui,
      endpoint
    ))
  end
end

local heiman_color_dimmer = {
  profile = "controllers-dimming-battery-remote-action",
  advanced_remote = true,
  unprefixed_remote_actions = true,
  zcl_clusters = {
    zcl.battery({
      endpoint = 1,
      minimum_interval = 300,
      maximum_interval = 3600,
      reportable_change = 2,
    }),
  },
  configure = function(driver, device)
    bind_clusters(driver, device, 1, {
      zcl.CLUSTER_POWER_CONFIGURATION,
      zcl.CLUSTER_ON_OFF,
      zcl.CLUSTER_LEVEL_CONTROL,
      zcl.CLUSTER_COLOR_CONTROL,
    })
  end,
}

local function candeo_rd1p_action(zb_rx, cluster_id, command_id, source_endpoint)
  if source_endpoint ~= 2 then
    return nil, nil, true
  end

  if cluster_id == zcl.CLUSTER_ON_OFF then
    return ({
      [0x00] = "double_pressed",
      [0x01] = "pressed",
      [0x02] = "held",
      [0x03] = "released",
    })[command_id], "main", true
  end

  if cluster_id == zcl.CLUSTER_LEVEL_CONTROL then
    if command_id == 0x03 then
      return "stopped_rotating", "main", true
    end

    local direction = nil
    if command_id == 0x05 then
      direction = body_member_value(zb_rx, "move_mode", "movemode", "mode")
      if direction == 0 then
        return "started_rotating_right", "main", true
      elseif direction == 1 then
        return "started_rotating_left", "main", true
      end
    elseif command_id == 0x06 then
      direction = body_member_value(zb_rx, "step_mode", "stepmode", "mode")
      if direction == 0 then
        return "rotating_right", "main", true
      elseif direction == 1 then
        return "rotating_left", "main", true
      end
    end

    return nil, nil, true
  end

  return nil, nil, true
end

local candeo_rd1p_remote = {
  profile = "controllers-dimming-meter-remote-action",
  advanced_remote = true,
  unprefixed_remote_actions = true,
  standard_command_action_resolver = candeo_rd1p_action,
  zcl_clusters = {
    zcl.power({ endpoint = 1 }),
    zcl.voltage({ endpoint = 1 }),
    zcl.current({ endpoint = 1 }),
    zcl.energy({ endpoint = 1 }),
  },
  configure = function(driver, device)
    bind_clusters(driver, device, 2, {
      zcl.CLUSTER_ON_OFF,
      zcl.CLUSTER_LEVEL_CONTROL,
    })
  end,
}

register_device_definition(dimming_remote, device_helpers.create_fingerprints("TS1001", {
  "_TYZB01_bngwdjsr",
  "_TYZB01_hww2py6b",
  "_TZ3000_ztrfrcsu",
}))

register_device_definition(candeo_rd1p_remote, {
  device_helpers.create_fingerprint("Candeo", "C-ZB-RD1P-REM"),
})

register_device_definition(heiman_color_dimmer, {
  device_helpers.create_fingerprint("HEIMAN", "ColorDimmerSw-EM-3.0"),
})

return device_definitions
