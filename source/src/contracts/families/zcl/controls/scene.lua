local zcl = require "protocol.zcl"
local device_helpers = require "contracts.helpers.family"
local emit = require "capabilities.events.all"
local capabilities = require "st.capabilities"
-- Battery refresh is provided by the protocol facade.
local device_management = require "st.zigbee.device_management"

local device_definitions, register_device_definition = device_helpers.definition_registry()
local CANDEO_ROTARY_CLUSTER = 0xFF03
local MLI_SCENE_ATTRIBUTE = 0x4005
local CANDEO_PREVIOUS_ROTATION_FIELD = "__candeo_previous_rotation_event"
local CANDEO_PREVIOUS_DIRECTION_FIELD = "__candeo_previous_direction"
local remote_action_emitter = emit.remote_action()

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

local scene_remote_4 = {
  profile = "buttons-button-4-battery-voltage-remote-action",
  button_actions = { "pushed" },
  advanced_remote = true,
  button_count = 4,
  tuya_action_map = {
    [1] = "scene_1",
    [2] = "scene_2",
    [3] = "scene_3",
    [4] = "scene_4",
  },
  tuya_action_components = {
    [1] = "main",
    [2] = "button2",
    [3] = "button3",
    [4] = "button4",
  },
  tuya_action_button_events = {
    [1] = "pushed",
    [2] = "pushed",
    [3] = "pushed",
    [4] = "pushed",
  },
  zcl_clusters = {
    zcl.tuya_magic_packet(),
    zcl.battery(),
    zcl.cluster_attribute(zcl.CLUSTER_POWER_CONFIGURATION, zcl.ATTR_BATTERY_VOLTAGE, {
      name = "battery",
      endpoint = 1,
      emit = emit.battery(),
      scale = 10,
      from_device = battery_percent_from_voltage,
      read_on_configure = true,
    }),
    zcl.cluster_attribute(zcl.CLUSTER_POWER_CONFIGURATION, zcl.ATTR_BATTERY_VOLTAGE, {
      name = "battery_voltage",
      endpoint = 1,
      emit = emit.voltage(),
      scale = 10,
    }),
  },
  configure = function(driver, device)
    for _, cluster_id in ipairs({ zcl.CLUSTER_ON_OFF, zcl.CLUSTER_LEVEL_CONTROL }) do
      device:send(device_management.build_bind_request(
        device,
        cluster_id,
        driver.environment_info.hub_zigbee_eui,
        1
      ))
    end
  end,
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

  return nil
end

local function emit_component_event(device, component_id, event)
  if event == nil then
    return
  end

  if component_id == "main" then
    device:emit_event(event)
  else
    device:emit_component_event({ id = component_id }, event)
  end
end

local function candeo_button_component(button_number)
  return ({
    [1] = "main",
    [2] = "button2",
    [4] = "button3",
    [8] = "button4",
    [16] = "button5",
  })[button_number]
end

local function candeo_button_name(button_number)
  return ({
    [1] = "button_1",
    [2] = "button_2",
    [4] = "button_3",
    [8] = "button_4",
    [16] = "centre_button",
  })[button_number]
end

local function candeo_button_action(action_number)
  return ({
    [1] = "click",
    [2] = "double_click",
    [3] = "hold",
    [4] = "release",
  })[action_number]
end

local function candeo_button_event(action)
  return ({
    click = "pushed",
    double_click = "double",
    hold = "held",
  })[action]
end

local function append_candeo_ring_action(actions, action)
  actions[#actions + 1] = {
    action = action,
    component = "main",
  }
end

local function candeo_actions_from_payload(payload, device)
  if type(payload) ~= "table" then
    return nil
  end

  local actions = {}
  if payload.field1 == 1 then
    local component = candeo_button_component(payload.field3)
    local button_name = candeo_button_name(payload.field3)
    local action_name = candeo_button_action(payload.field4)
    if component ~= nil and button_name ~= nil and action_name ~= nil then
      actions[1] = {
        action = button_name .. "_" .. action_name,
        component = component,
        button_event = candeo_button_event(action_name),
      }
    end
  elseif payload.field1 == 3 then
    local rotation_event = ({
      [1] = "started_",
      [2] = "stopped_",
      [3] = "continued_",
    })[payload.field3]

    if rotation_event == "stopped_" then
      local previous_direction = device:get_field(CANDEO_PREVIOUS_DIRECTION_FIELD)
      if type(previous_direction) == "string" then
        append_candeo_ring_action(actions, "stopped_" .. previous_direction)
      end
      device:set_field(CANDEO_PREVIOUS_ROTATION_FIELD, "stopped_", { persist = false })
    elseif rotation_event ~= nil then
      local direction = ({
        [1] = "rotating_right",
        [2] = "rotating_left",
      })[payload.field2]

      if direction ~= nil then
        local previous_event = device:get_field(CANDEO_PREVIOUS_ROTATION_FIELD)
        local ring_clicks = type(payload.field4) == "number" and math.max(1, payload.field4) or 1
        if previous_event == "stopped_" then
          append_candeo_ring_action(actions, "started_" .. direction)
          device:set_field(CANDEO_PREVIOUS_ROTATION_FIELD, "started_", { persist = false })
          for _ = 2, ring_clicks do
            append_candeo_ring_action(actions, "continued_" .. direction)
            device:set_field(CANDEO_PREVIOUS_ROTATION_FIELD, "continued_", { persist = false })
          end
        elseif previous_event == "started_" or previous_event == "continued_" then
          for _ = 1, ring_clicks do
            append_candeo_ring_action(actions, "continued_" .. direction)
          end
          device:set_field(CANDEO_PREVIOUS_ROTATION_FIELD, "continued_", { persist = false })
        end
        device:set_field(CANDEO_PREVIOUS_DIRECTION_FIELD, direction, { persist = false })
      end
    end
  end

  return actions[1] ~= nil and actions or nil
end

local function emit_candeo_actions(device, actions)
  if type(actions) ~= "table" then
    return
  end

  for _, item in ipairs(actions) do
    local component_id = item.component or "main"
    local remote_event = remote_action_emitter(device, item.action)
    emit_component_event(device, component_id, remote_event)

    local button_builder = item.button_event and capabilities.button and capabilities.button.button[item.button_event] or nil
    if type(button_builder) == "function" then
      emit_component_event(device, component_id, button_builder({ state_change = true }))
      zcl.schedule_battery_refresh_after_button(device)
    end
  end
end

local function candeo_rotary_command()
  return zcl.cluster_attribute(CANDEO_ROTARY_CLUSTER, 0x0001, {
    name = "candeo_rotary_action",
    command_id = 0x01,
    command_extractor = function(zb_rx)
      return {
        field1 = body_member_value(zb_rx, "field1"),
        field2 = body_member_value(zb_rx, "field2"),
        field3 = body_member_value(zb_rx, "field3"),
        field4 = body_member_value(zb_rx, "field4"),
      }
    end,
    from_device = candeo_actions_from_payload,
    handler = emit_candeo_actions,
  })
end

local candeo_rotary_remote = {
  profile = "buttons-button-5-battery-remote-action",
  button_actions = { "pushed", "double", "held" },
  button_count = 5,
  zcl_clusters = {
    zcl.battery(),
    candeo_rotary_command(),
  },
  configure = function(driver, device)
    device:send(device_management.build_bind_request(
      device,
      CANDEO_ROTARY_CLUSTER,
      driver.environment_info.hub_zigbee_eui,
      1
    ))
  end,
}

local mli_remote = {
  profile = "controllers-dimming-remote-action",
  advanced_remote = true,
  accept_basic_write_attributes = true,
  button_count = 1,
  unprefixed_remote_actions = true,
  zcl_clusters = {
    zcl.cluster_attribute(0x0000, MLI_SCENE_ATTRIBUTE, {
      name = "remote_action",
      emit = emit.remote_action(),
      from_device = function(value)
        if type(value) == "number" and value >= 1 and value <= 10 then
          return "scene_" .. tostring(value)
        end
      end,
    }),
  },
}

local miboxer_fut089z = {
  profile = "controllers-zone-8-battery-voltage-remote-action",
  advanced_remote = true,
  button_count = 8,
  unprefixed_remote_actions = true,
  tuya_action_name = "switch_scene",
  group_component_map = {
    [101] = "main",
    [102] = "button2",
    [103] = "button3",
    [104] = "button4",
    [105] = "button5",
    [106] = "button6",
    [107] = "button7",
    [108] = "button8",
  },
  zcl_clusters = {
    zcl.tuya_magic_packet(),
    zcl.battery(),
    zcl.cluster_attribute(zcl.CLUSTER_POWER_CONFIGURATION, zcl.ATTR_BATTERY_VOLTAGE, {
      name = "battery",
      endpoint = 1,
      emit = emit.battery(),
      scale = 10,
      from_device = battery_percent_from_voltage,
    }),
    zcl.cluster_attribute(zcl.CLUSTER_POWER_CONFIGURATION, zcl.ATTR_BATTERY_VOLTAGE, {
      name = "battery_voltage",
      endpoint = 1,
      emit = emit.voltage(),
      scale = 10,
    }),
  },
  configure = function(driver)
    for group_id = 101, 108 do
      driver:add_hub_to_zigbee_group(group_id)
    end
  end,
}

local function emit_heiman_scene_button(device)
  device:emit_event(capabilities.button.button.pushed({ state_change = true }))
  zcl.schedule_battery_refresh_after_button(device)
end

local function heiman_scene_command(command_id, action)
  return zcl.cluster_attribute(0xFC80, 0xF000 + command_id - 0xF0, {
    name = "heiman_scene_" .. action,
    command_id = command_id,
    command_extractor = function()
      return action
    end,
    emit = emit.remote_action(),
    handler = emit_heiman_scene_button,
    mfg_code = 0x120B,
  })
end

local heiman_scene_remote = {
  profile = "buttons-heiman-scene-battery-remote-action",
  button_actions = { "pushed" },
  advanced_remote = true,
  button_count = 1,
  unprefixed_remote_actions = true,
  zcl_clusters = {
    zcl.battery(),
    heiman_scene_command(0xF0, "cinema"),
    heiman_scene_command(0xF1, "at_home"),
    heiman_scene_command(0xF2, "sleep"),
    heiman_scene_command(0xF3, "go_out"),
    heiman_scene_command(0xF4, "repast"),
  },
  configure = function(driver, device)
    device:send(device_management.build_bind_request(
      device,
      0xFC80,
      driver.environment_info.hub_zigbee_eui,
      1
    ))
  end,
}

register_device_definition(scene_remote_4, device_helpers.create_fingerprints("TS1002", {
  "_TZ3000_etufnltx",
}))

register_device_definition(candeo_rotary_remote, {
  device_helpers.create_fingerprint("Candeo", "C-ZB-SR5BR"),
})

register_device_definition(mli_remote, {
  device_helpers.create_fingerprint("MLI", "Remote Control"),
})

register_device_definition(miboxer_fut089z, device_helpers.create_fingerprints("TS1002", {
  "_TZ3000_xwh1e22x",
  "_TZ3000_zwszqdpy",
}))

register_device_definition(heiman_scene_remote, {
  device_helpers.create_fingerprint("HEIMAN", "SceneSwitch-EM-3.0"),
  device_helpers.create_fingerprint("HEIMAN", "SceneSwitch-EF-3.0"),
})

return {
  id = "zcl.controls.scene",
  registrations = device_definitions,
}
