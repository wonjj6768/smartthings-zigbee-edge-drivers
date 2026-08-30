local tuya = require "protocol.tuya"
local device_helpers = require "contracts.helpers.family"
local emit = require "capabilities.events.all"
local capabilities = require "st.capabilities"

local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()

-- Z2M v26.99.0: Orztech 1/2/3/4/6-gang touch wall switches
-- (orztech.ts:18-159). Every exposed item is an independent on/off DP, so the
-- standard switch capability is lossless when each DP owns its own component.
-- tuyaBase({dp = true}) does not query state unless explicitly requested.
local function switch_component(index)
  if index == 1 then return "main" end
  return "switch" .. tostring(index)
end

local function build_orztech_touch_switch(profile, relay_count)
  local definition = {
    profile = profile,
    package_group = "switch-panel",
    datapoints = {},
    query_on_configure = false,
  }

  for dp = 1, relay_count do
    definition.datapoints[#definition.datapoints + 1] = tuya.dp_on_off(dp, {
      name = "switch",
      component = switch_component(dp),
    })
  end

  local control_dps = { 13, 16, 101 }
  if relay_count > 1 then control_dps[#control_dps + 1] = 102 end
  for _, dp in ipairs(control_dps) do
    definition.datapoints[#definition.datapoints + 1] = tuya.dp_on_off(dp, {
      name = "switch",
      component = switch_component(#definition.datapoints + 1),
    })
  end

  return definition
end

local orztech_touch_1gang = build_orztech_touch_switch("switches-switch-4", 1)
register_device_definition(orztech_touch_1gang, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_b0ihkhxh",
}))

local orztech_touch_2gang = build_orztech_touch_switch("switches-switch-6", 2)
register_device_definition(orztech_touch_2gang, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_htj3hcpl",
}))

local orztech_touch_3gang = build_orztech_touch_switch("switches-switch-7", 3)
register_device_definition(orztech_touch_3gang, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_pcg0rykt",
}))

local orztech_touch_4gang = build_orztech_touch_switch("switches-switch-8", 4)
register_device_definition(orztech_touch_4gang, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_7a5ob7xq",
  "_TZE284_7a5ob7xq",
}))

local orztech_touch_6gang = build_orztech_touch_switch("switches-switch-10", 6)
register_device_definition(orztech_touch_6gang, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_xo3vpoah",
}))

-- QA QAT42Z1B. Z2M v26.99.0 qa.ts:344-362 maps BOOL DP24 to the relay,
-- any DP5 report to the single scene_1 action, and VALUE DP101 to the writable
-- 0..99% backlight brightness. SmartThings represents the single scene event
-- as a pushed button event.
local function emit_qat42z1b_scene_action()
  return capabilities.button.button.pushed({ state_change = true })
end

local qat42z1b_scene_switch = {
  profile = "switches-switch-1-scene-qa-qat42z1b",
  package_group = "switch-panel",
  button_actions = { "pushed" },
  query_on_configure = false,
  time_start = "off",
  datapoints = {
    tuya.dp_on_off(24, { name = "switch", component = "main", emit = emit.switch() }),
    tuya.dp_enum(5, {
      name = "scene_action",
      component = "main",
      read_only = true,
      converter = converter.from_only(converter.constant("pushed")),
      emit = emit_qat42z1b_scene_action,
    }),
    tuya.dp_numeric(101, {
      name = "qat42z1b_backlight_brightness",
      component = "main",
      emit = emit.qatOneBacklightBrightness(),
    }),
  },
}

register_device_definition(qat42z1b_scene_switch, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_nzns7udm",
}))

return {
  id = "ef00.switch.panel.z2m_absorption",
  registrations = device_definitions,
}
