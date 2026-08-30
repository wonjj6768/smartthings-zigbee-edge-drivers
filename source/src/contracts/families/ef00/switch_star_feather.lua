-- Moes SFL02-Z-1..4 star-feather smart switches.
-- Frozen reference: Zigbee2MQTT v26.99.0, src/devices/moes.ts:540-841.
local tuya = require "protocol.tuya"
local device_helpers = require "contracts.helpers.family"
local emit = require "capabilities.events.all"
local capabilities = require "st.capabilities"

local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()

local NUMBER_WORDS = { "One", "Two", "Three", "Four" }

local power_on_behavior_converter = converter.lookup_from_to({
  off = 0,
  on = 1,
  previous = 2,
})
local indicator_status_converter = converter.lookup_from_to({
  off = 0,
  relay = 1,
  invert = 2,
})
local vibration_mode_converter = converter.lookup_from_to({
  ["Gear 0"] = 0,
  ["Gear 1"] = 1,
  ["Gear 2"] = 2,
  ["Gear 3"] = 3,
})
local scene_action_converter = converter.from_only(converter.constant("pushed"))

local function emit_scene_action(_, value)
  if value == "pushed" then
    return capabilities.button.button.pushed({ state_change = true })
  end
end

local function gang_component(gang)
  if gang == 1 then return "main" end
  return "switch" .. tostring(gang)
end

local function mapping_name(family_word, item, gang_word)
  local name = "sfl_" .. family_word:lower() .. "_" .. item
  if gang_word ~= nil then
    name = name .. "_" .. gang_word:lower()
  end
  return name
end

local function custom_emitter(family_word, item, gang_word)
  local capability_id = "sfl" .. family_word .. item .. (gang_word or "")
  return emit[capability_id]()
end

local function build_star_feather_family(family_word, gang_count, profile)
  local definition = {
    profile = profile,
    package_group = "switch-panel",
    button_actions = { "pushed" },
    query_on_configure = false,
    time_start = "1970",
    datapoints = {},
  }

  for gang = 1, gang_count do
    local gang_word = NUMBER_WORDS[gang]
    local component = gang_component(gang)
    local mode_switch = "switch_" .. tostring(gang)
    local mode_scene = "scene_" .. tostring(gang)

    definition.datapoints[#definition.datapoints + 1] = tuya.dp_enum(gang, {
      name = "scene_action_" .. tostring(gang),
      component = component,
      read_only = true,
      converter = scene_action_converter,
      emit = emit_scene_action,
    })
    definition.datapoints[#definition.datapoints + 1] = tuya.dp_enum(17 + gang, {
      name = mapping_name(family_word, "mode", gang_word),
      component = component,
      converter = converter.lookup_from_to({
        [mode_switch] = 0,
        [mode_scene] = 1,
      }),
      emit = custom_emitter(family_word, "Mode", gang_word),
    })
    definition.datapoints[#definition.datapoints + 1] = tuya.dp_on_off(23 + gang, {
      name = "switch",
      component = component,
    })
    definition.datapoints[#definition.datapoints + 1] = tuya.dp_countdown(29 + gang, {
      name = mapping_name(family_word, "countdown", gang_word),
      component = component,
      emit = custom_emitter(family_word, "Countdown", gang_word),
    })
    definition.datapoints[#definition.datapoints + 1] = tuya.dp_countdown(104 + gang, {
      name = mapping_name(family_word, "momentary", gang_word),
      component = component,
      emit = custom_emitter(family_word, "Momentary", gang_word),
    })
  end

  definition.datapoints[#definition.datapoints + 1] = tuya.dp_on_off(36, {
    name = "switch",
    component = "backlight",
  })
  definition.datapoints[#definition.datapoints + 1] = tuya.dp_enum(37, {
    name = mapping_name(family_word, "indicator_status"),
    converter = indicator_status_converter,
    emit = custom_emitter(family_word, "IndicatorStatus"),
  })
  definition.datapoints[#definition.datapoints + 1] = tuya.dp_enum(38, {
    name = mapping_name(family_word, "power_on_behavior"),
    converter = power_on_behavior_converter,
    emit = custom_emitter(family_word, "PowerOnBehavior"),
  })
  definition.datapoints[#definition.datapoints + 1] = tuya.dp_on_off(103, {
    name = "switch",
    component = "induction",
  })
  definition.datapoints[#definition.datapoints + 1] = tuya.dp_enum(104, {
    name = mapping_name(family_word, "vibration_mode"),
    converter = vibration_mode_converter,
    emit = custom_emitter(family_word, "VibrationMode"),
  })

  return definition
end

local moes_sfl02_z1 = build_star_feather_family("One", 1, "switches-moes-sfl02-z1")
register_device_definition(moes_sfl02_z1, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_stvgmdjz",
  "_TZE200_ydkqbmpt",
  "_TZE200_z3u99qxt",
}))

local moes_sfl02_z2 = build_star_feather_family("Two", 2, "switches-moes-sfl02-z2")
register_device_definition(moes_sfl02_z2, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_uenof8jd",
  "_TZE200_tzyy0rtq",
  "_TZE200_hktk6hze",
}))

local moes_sfl02_z3 = build_star_feather_family("Three", 3, "switches-moes-sfl02-z3")
register_device_definition(moes_sfl02_z3, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_rd8cdssd",
  "_TZE200_wv9ukqca",
  "_TZE200_zo0cfekv",
}))

local moes_sfl02_z4 = build_star_feather_family("Four", 4, "switches-moes-sfl02-z4")
register_device_definition(moes_sfl02_z4, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_dq8bu0pt",
  "_TZE200_hmabvy81",
  "_TZE200_9dhenr94",
}))

return {
  id = "ef00.switch.star_feather",
  registrations = device_definitions,
}
