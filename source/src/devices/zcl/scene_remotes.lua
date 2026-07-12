local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local emit = require "emitters"
local capabilities = require "st.capabilities"
local battery_refresh = require "app.battery_refresh"

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

local scene_remote_4 = {
  profile = "buttons-button-4-battery-remote-action",
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
    zcl.cluster_attribute(zcl.CLUSTER_POWER_CONFIGURATION, zcl.ATTR_BATTERY_VOLTAGE, {
      name = "battery",
      endpoint = 1,
      emit = emit.battery(),
      scale = 10,
      from_device = battery_percent_from_voltage,
      read_on_configure = true,
    }),
  },
}

local function emit_heiman_scene_button(device)
  device:emit_event(capabilities.button.button.pushed({ state_change = true }))
  battery_refresh.schedule_after_button(device)
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
}

register_device_definition(scene_remote_4, device_helpers.create_fingerprints("TS1002", {
  "_TZ3000_etufnltx",
  "_TZ3000_xwh1e22x",
  "_TZ3000_zwszqdpy",
}))

register_device_definition(scene_remote_4, {
  device_helpers.create_fingerprint("Candeo", "C-ZB-SR5BR"),
  device_helpers.create_fingerprint("MLI", "Remote Control"),
})

register_device_definition(heiman_scene_remote, {
  device_helpers.create_fingerprint("HEIMAN", "SceneSwitch-EM-3.0"),
  device_helpers.create_fingerprint("HEIMAN", "SceneSwitch-EF-3.0"),
})

return device_definitions
