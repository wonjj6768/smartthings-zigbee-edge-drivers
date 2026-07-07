local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local emit = require "emitters"
local capabilities = require "st.capabilities"
local battery_refresh = require "app.battery_refresh"

local device_definitions, register_device_definition = device_helpers.definition_registry()
local CLUSTER_SCENES = 0x0005
local CLUSTER_MULTI_STATE_INPUT = 0x0012
local ATTR_PRESENT_VALUE = 0x0055

local SLACKY_ACTIONS = {
  [0] = "hold",
  [1] = "single",
  [2] = "double",
  [3] = "triple",
  [4] = "quadruple",
  [5] = "quintuple",
  [255] = "release",
}

local BUTTON_EVENT_BY_ACTION = {
  single = "pushed",
  double = "double",
  hold = "held",
}

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

local function remote_battery_cluster()
  return zcl.cluster_attribute(zcl.CLUSTER_POWER_CONFIGURATION, zcl.ATTR_BATTERY_VOLTAGE, {
    name = "battery",
    endpoint = 1,
    emit = emit.battery(),
    scale = 10,
    from_device = battery_percent_from_voltage,
    read_on_configure = true,
  })
end

local function component_for_endpoint(endpoint)
  return endpoint == 1 and "main" or ("button" .. tostring(endpoint))
end

local function emit_button_action(device, component_id, action)
  local button_action = BUTTON_EVENT_BY_ACTION[action]
  local builder = button_action and capabilities.button and capabilities.button.button[button_action] or nil
  if type(builder) ~= "function" then
    return
  end

  if type(device.supports_capability_by_id) == "function" and not device:supports_capability_by_id(capabilities.button.ID, component_id) then
    return
  end

  device:emit_component_event({ id = component_id }, builder({ state_change = true }))
  battery_refresh.schedule_after_button(device)
end

local function slacky_multistate_action_cluster(endpoint)
  local component_id = component_for_endpoint(endpoint)
  return zcl.cluster_attribute(CLUSTER_MULTI_STATE_INPUT, ATTR_PRESENT_VALUE, {
    name = "remote_action",
    endpoint = endpoint,
    component = component_id,
    emit = emit.remote_action(),
    from_device = function(value)
      local action = SLACKY_ACTIONS[value]
      if action == nil then
        return nil
      end
      return action .. "_" .. tostring(endpoint)
    end,
    handler = function(device, action)
      if type(action) ~= "string" then
        return
      end
      emit_button_action(device, component_id, action:match("^([^_]+)"))
    end,
  })
end

local function append_slacky_action_clusters(clusters, button_count)
  for endpoint = 1, button_count do
    clusters[#clusters + 1] = slacky_multistate_action_cluster(endpoint)
  end
end

local function build_advanced_remote(profile, button_count, extra)
  local definition = {
    profile = profile,
    button_actions = options and options.button_actions or { "pushed", "double", "held" },
    advanced_remote = true,
    button_count = button_count,
    zcl_clusters = {
      zcl.tuya_magic_packet(),
      remote_battery_cluster(),
      zcl.operation_mode(),
    },
  }

  for key, value in pairs(extra or {}) do
    definition[key] = value
  end

  return definition
end

local function build_standard_action_remote(profile, button_count, options)
  local definition = {
    profile = profile,
    button_actions = { "pushed", "double", "held" },
    advanced_remote = true,
    button_count = button_count,
    standard_action_endpoint_suffix = options and options.standard_action_endpoint_suffix == true,
    zcl_clusters = {
      zcl.tuya_magic_packet(),
      remote_battery_cluster(),
    },
  }

  if options and options.slacky_multistate == true then
    append_slacky_action_clusters(definition.zcl_clusters, button_count)
  end

  return definition
end

local remote_1 = build_advanced_remote("buttons-button-1-battery-operation-mode-remote-action", 1, {
  unprefixed_remote_actions = true,
})
local remote_4 = build_advanced_remote("buttons-button-4-battery-operation-mode-remote-action", 4)
local remote_6 = build_advanced_remote("buttons-button-6-battery-operation-mode-remote-action", 6)
local knob_remote = build_advanced_remote("buttons-button-1-battery-operation-mode-remote-action", 1, {
  knob_remote = true,
})
local standard_action_remote_1 = build_standard_action_remote("buttons-button-1-battery-remote-action", 1, {
  button_actions = { "pushed", "double" },
})
local slacky_remote_1 = build_standard_action_remote("buttons-button-1-battery-remote-action", 1, {
  slacky_multistate = true,
  standard_action_endpoint_suffix = true,
})
local slacky_remote_2 = build_standard_action_remote("buttons-button-2-battery-remote-action", 2, {
  slacky_multistate = true,
  standard_action_endpoint_suffix = true,
})
local slacky_remote_4 = build_standard_action_remote("buttons-button-4-battery-remote-action", 4, {
  slacky_multistate = true,
  standard_action_endpoint_suffix = true,
})

register_device_definition(remote_4, device_helpers.create_fingerprints("TS004F", {
  "_TZ3000_g9g2xnch",
  "_TZ3000_pcqjmcud",
  "_TZ3000_nuombroo",
  "_TZ3000_xabckq1v",
  "_TZ3000_czuyt8lz",
  "_TZ3000_0ht8dnxj",
  "_TZ3000_b3mgfu0d",
  "_TZ3000_11pg3ima",
  "_TZ3000_et7afzxz",
  "_TZ3000_pftj0i7z",
}))

register_device_definition(remote_4, {
  device_helpers.create_fingerprint("Moes", "TS004F"),
  device_helpers.create_fingerprint("Moes", "TS004F_1"),
  device_helpers.create_fingerprint("Zemismart", "ZMR4"),
})

register_device_definition(remote_6, device_helpers.create_fingerprints("TS004F", {
  "_TZ3000_r0o2dahu",
}))

register_device_definition(remote_1, device_helpers.create_fingerprints("TS004F", {
  "_TZ3000_kjfzuycl",
  "_TZ3000_ja5osu5g",
  "_TZ3000_egvb1p2g",
  "_TZ3000_lrfvzq1e",
  "_TZ3000_kaflzta4",
  "_TZ3000_wc3gjyp3",
}))

register_device_definition(standard_action_remote_1, device_helpers.create_fingerprints("TS004F", {
  "_TZ3000_rco1yzb1",
}))

register_device_definition(slacky_remote_1, {
  device_helpers.create_fingerprint("Slacky-DIY", "TS0041-M001-SlD"),
  device_helpers.create_fingerprint("Slacky-DIY", "TS0041-M002-SlD"),
  device_helpers.create_fingerprint("Slacky-DIY", "TS0041-M005-SlD"),
})

register_device_definition(slacky_remote_2, {
  device_helpers.create_fingerprint("Slacky-DIY", "TS0042-z-SlD"),
  device_helpers.create_fingerprint("Slacky-DIY", "TS0042-M003-SlD"),
})

register_device_definition(slacky_remote_4, {
  device_helpers.create_fingerprint("Slacky-DIY", "TS0044-z-SlD"),
  device_helpers.create_fingerprint("Slacky-DIY", "TS0044-M004-SlD"),
})

register_device_definition(knob_remote, device_helpers.create_fingerprints("TS004F", {
  "_TZ3000_qja6nq5z",
  "_TZ3000_1fqpj6qz",
  "_TZ3000_402vrq2i",
  "_TZ3000_4fjiwweb",
  "_TZ3000_uri7ongn",
  "_TZ3000_ixla93vd",
  "_TZ3000_csflgqj2",
  "_TZ3000_abrsvsou",
  "_TZ3000_gwkzibhs",
  "_TZ3000_ugi8ky6u",
}))

register_device_definition(knob_remote, {
  device_helpers.create_fingerprint("Immax", "07768L"),
  device_helpers.create_fingerprint("Moes", "ZG-101ZD"),
  device_helpers.create_fingerprint("Moes", "SYT-ZB01"),
  device_helpers.create_fingerprint("Tuya", "ZG-101Z_D_1"),
})

return device_definitions
