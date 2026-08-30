-- Wave13 Manhot MH03 OLED switch source-only candidates.
-- Frozen Zigbee2MQTT v26.99.0: src/devices/manhot.ts:34-758.

local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"

local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()

local WORDS = {
  "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight",
}
local LOWER_WORDS = {
  "one", "two", "three", "four", "five", "six", "seven", "eight",
}
local COLORS = {
  red = 0,
  orange = 1,
  green = 2,
  cyan = 3,
  blue = 4,
  purple = 5,
  magenta = 6,
  cold_white = 7,
  warm_yellow = 8,
}

local function custom(name)
  return assert(emit[name], "missing Wave13 custom emitter: " .. name)()
end

local function state_dp(index)
  return index <= 6 and index or index + 107
end

local function countdown_dp(index)
  return index <= 6 and index + 6 or index + 109
end

local function component(index)
  return index == 1 and "main" or ("switch" .. tostring(index))
end

local function append(definition, mapping)
  definition.datapoints[#definition.datapoints + 1] = mapping
end

local function build_mh(profile, capability_prefix, mapping_prefix, gangs)
  local definition = {
    profile = profile,
    package_group = "screen-switch",
    transport_classification = "EF00_DP",
    z2m_converter_source = "meta.tuyaDatapoints",
    wire_cluster = "manuSpecificTuya",
    magic_packet = true,
    query_on_configure = false,
    respond_to_mcu_version_response = true,
    datapoints = {},
  }

  for index = 1, gangs do
    append(definition, tuya.dp_on_off(state_dp(index), {
      name = "switch",
      component = component(index),
      emit = emit.switch(),
    }))
  end

  for index = 1, gangs do
    append(definition, tuya.dp_numeric(countdown_dp(index), {
      name = mapping_prefix .. "_countdown_" .. LOWER_WORDS[index],
      emit = custom(capability_prefix .. "Countdown" .. WORDS[index]),
    }))
  end

  append(definition, tuya.dp_enum(14, {
    name = mapping_prefix .. "_relay_status",
    converter = converter.lookup_from_to({ off = 0, on = 1, memory = 2 }),
    emit = custom(capability_prefix .. "RelayStatus"),
  }))
  append(definition, tuya.dp_enum(15, {
    name = mapping_prefix .. "_light_mode",
    converter = converter.lookup_from_to({ none = 0, relay = 1, pos = 2 }),
    emit = custom(capability_prefix .. "LightMode"),
  }))
  append(definition, tuya.dp_binary(16, {
    name = mapping_prefix .. "_backlight_switch",
    converter = converter.lookup_from_to({ ON = true, OFF = false }),
    emit = custom(capability_prefix .. "BacklightSwitch"),
  }))
  append(definition, tuya.dp_numeric(101, {
    name = mapping_prefix .. "_backlight_lightness",
    emit = custom(capability_prefix .. "BacklightLightness"),
  }))
  append(definition, tuya.dp_enum(102, {
    name = mapping_prefix .. "_on_color",
    converter = converter.lookup_from_to(COLORS),
    emit = custom(capability_prefix .. "OnColor"),
  }))
  append(definition, tuya.dp_enum(103, {
    name = mapping_prefix .. "_off_color",
    converter = converter.lookup_from_to(COLORS),
    emit = custom(capability_prefix .. "OffColor"),
  }))
  append(definition, tuya.dp_numeric(104, {
    name = mapping_prefix .. "_displayoff_delay",
    emit = custom(capability_prefix .. "DisplayOffDelay"),
  }))
  append(definition, tuya.dp_binary(105, {
    name = mapping_prefix .. "_child_lock",
    converter = converter.lookup_from_to({ ON = true, OFF = false }),
    emit = custom(capability_prefix .. "ChildLock"),
  }))

  for index = 1, gangs do
    append(definition, tuya.dp_string(105 + index, {
      name = mapping_prefix .. "_switch_name_" .. LOWER_WORDS[index],
      emit = custom(capability_prefix .. "SwitchName" .. WORDS[index]),
    }))
  end

  if gangs > 1 then
    local press_values = { disable = 0 }
    for index = 1, gangs do press_values["press_switch_" .. tostring(index)] = index end
    append(definition, tuya.dp_enum(118, {
      name = mapping_prefix .. "_press_on_function",
      converter = converter.lookup_from_to(press_values),
      emit = custom(capability_prefix .. "PressOnFunction"),
    }))
    append(definition, tuya.dp_enum(119, {
      name = mapping_prefix .. "_press_off_function",
      converter = converter.lookup_from_to(press_values),
      emit = custom(capability_prefix .. "PressOffFunction"),
    }))
  end

  return definition
end

local definitions = {
  {
    build_mh("switches-wave13-manhot-mh03-1", "mhOne", "mh_one", 1),
    "_TZE284_ncc7uahd",
  },
  {
    build_mh("switches-wave13-manhot-mh03-2", "mhTwo", "mh_two", 2),
    "_TZE284_dnhhp8ew",
  },
  {
    build_mh("switches-wave13-manhot-mh03-3", "mhThree", "mh_three", 3),
    "_TZE284_59dz7ioi",
  },
  {
    build_mh("switches-wave13-manhot-mh03-4", "mhFour", "mh_four", 4),
    "_TZE284_esnu2jxv",
  },
  {
    build_mh("switches-wave13-manhot-mh03-6", "mhSix", "mh_six", 6),
    "_TZE284_zykra2yj",
  },
  {
    build_mh("switches-wave13-manhot-mh03-8", "mhEight", "mh_eight", 8),
    "_TZE284_hwv3by9k",
  },
}

for _, item in ipairs(definitions) do
  register_device_definition(item[1], device_helpers.create_fingerprints("TS0601", { item[2] }))
end

return {
  id = "ef00.switches.wave13.manhot",
  registrations = device_definitions,
}
