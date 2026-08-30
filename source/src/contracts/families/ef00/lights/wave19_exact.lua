-- Wave19 exact-only EF00/hybrid light candidates.
-- Frozen Zigbee2MQTT v26.99.0:
--   src/devices/avatto.ts:340-376   AVATTO ZDMS16-US-W2
--   src/devices/lidl.ts:385-393     Lidl HG06467
--   src/devices/lonsonho.ts:251-287 Lonsonho VM-Zigbee-S02-0-10V
--   src/devices/qa.ts:305-343       QA QADZ4DIN
--   src/devices/tuya.ts:6681-6762   Nova Digital TO-DM-W/B

local tuya = require "protocol.tuya"
local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"

local device_definitions, register_device_definition = device_helpers.definition_registry()
local converter = tuya.converter

local function custom(capability_id)
  return assert(emit[capability_id], "missing Wave19 light emitter: " .. capability_id)()
end

local function clamp(value, minimum, maximum)
  local number = tonumber(value)
  if number == nil then return nil end
  return math.max(minimum, math.min(maximum, number))
end

local function round(value)
  if value == nil then return nil end
  return math.floor(value + 0.5)
end

local brightness_zero_to_thousand = converter.from_to(
  function(value) return round(clamp(value, 0, 1000) / 10) end,
  function(value) return round(clamp(value, 0, 100) * 10) end
)

local POWER_BEHAVIOR = converter.lookup_from_to({ off = 0, on = 1, previous = 2 })
local ON_OFF = converter.lookup_from_to({ OFF = false, ON = true })

local function tuya_lifecycle(profile, datapoints)
  return {
    profile = profile,
    package_group = "wave19-light",
    transport_classification = "EF00_DP",
    z2m_converter_source = "meta.tuyaDatapoints",
    wire_cluster = "manuSpecificTuya",
    magic_packet = true,
    -- Frozen tuyaBase({dp = true}) keeps queryOnConfigure at its false default.
    query_on_configure = false,
    named_datapoints = true,
    time_start = "off",
    placeholder_custom_states = false,
    datapoints = datapoints,
  }
end

local function two_channel_dimmer(profile, capability_prefix, switch_type_converter)
  local min_emitter = custom(capability_prefix .. "MinBrightness")
  local max_emitter = custom(capability_prefix .. "MaxBrightness")
  local type_emitter = custom(capability_prefix .. "SwitchType")
  local countdown_emitter = custom(capability_prefix .. "Countdown")

  return tuya_lifecycle(profile, {
    tuya.dp_on_off(1, { name = "switch", component = "main", transaction = 1, emit = emit.switch() }),
    tuya.dp_numeric(2, { name = "brightness", component = "main", transaction = 1, converter = brightness_zero_to_thousand, emit = emit.level() }),
    tuya.dp_numeric(3, { name = capability_prefix .. "_min_brightness", component = "main", transaction = 1, converter = brightness_zero_to_thousand, emit = min_emitter }),
    tuya.dp_enum(4, { name = capability_prefix .. "_switch_type", component = "main", transaction = 1, converter = switch_type_converter, emit = type_emitter }),
    tuya.dp_numeric(5, { name = capability_prefix .. "_max_brightness", component = "main", transaction = 1, converter = brightness_zero_to_thousand, emit = max_emitter }),
    tuya.dp_numeric(6, { name = capability_prefix .. "_countdown", component = "main", transaction = 1, emit = countdown_emitter }),
    tuya.dp_on_off(7, { name = "switch", component = "switch2", transaction = 1, emit = emit.switch() }),
    tuya.dp_numeric(8, { name = "brightness", component = "switch2", transaction = 1, converter = brightness_zero_to_thousand, emit = emit.level() }),
    tuya.dp_numeric(9, { name = capability_prefix .. "_min_brightness", component = "switch2", transaction = 1, converter = brightness_zero_to_thousand, emit = min_emitter }),
    tuya.dp_enum(10, { name = capability_prefix .. "_switch_type", component = "switch2", transaction = 1, converter = switch_type_converter, emit = type_emitter }),
    tuya.dp_numeric(11, { name = capability_prefix .. "_max_brightness", component = "switch2", transaction = 1, converter = brightness_zero_to_thousand, emit = max_emitter }),
    tuya.dp_numeric(12, { name = capability_prefix .. "_countdown", component = "switch2", transaction = 1, emit = countdown_emitter }),
    tuya.dp_enum(14, { name = capability_prefix .. "_power_behavior", transaction = 1, converter = POWER_BEHAVIOR, emit = custom(capability_prefix .. "PowerBehavior") }),
  })
end

-- AVATTO -------------------------------------------------------------------

local avatto = two_channel_dimmer(
  "lights-wave19-avatto-zdms16-us-w2",
  "avattoWTwo",
  converter.lookup_from_to({ toggle = 0, state = 1, momentary = 2 })
)

register_device_definition(avatto, {
  device_helpers.create_fingerprint("_TZE204_sdykkwsu", "TS0601"),
})

-- Lidl HG06467 -------------------------------------------------------------
-- This frozen legacy definition uses standard genOnOff for the switch and
-- EF00 DP2/3/5/6 only for white/color/effect data. Effect DP6 is deliberately
-- decoded as a hidden raw item because the frozen expose omits effect.

local LIDL_HUE_FIELD = "wave19_lidl_hue"
local LIDL_SATURATION_FIELD = "wave19_lidl_saturation"
local LIDL_BRIGHTNESS_FIELD = "wave19_lidl_brightness"

local function lidl_hex_part(value, offset)
  if type(value) ~= "string" or #value < 12 then return nil end
  return tonumber(value:sub(offset, offset + 3), 16)
end

local function lidl_hue_from_device(value, device)
  local degrees = lidl_hex_part(value, 1)
  if degrees == nil then return nil end
  local hue = clamp(degrees / 3.6, 0, 100)
  device:set_field(LIDL_HUE_FIELD, hue, { persist = false })
  return hue
end

local function lidl_saturation_from_device(value, device)
  local raw = lidl_hex_part(value, 5)
  if raw == nil then return nil end
  local saturation = clamp(raw / 10, 0, 100)
  device:set_field(LIDL_SATURATION_FIELD, saturation, { persist = false })
  return saturation
end

local function lidl_color_brightness_from_device(value, device)
  local raw = lidl_hex_part(value, 9)
  if raw == nil then return nil end
  local brightness = round(clamp(raw, 0, 1000) / 10)
  device:set_field(LIDL_BRIGHTNESS_FIELD, brightness, { persist = false })
  return brightness
end

local function lidl_white_brightness_from_device(value, device)
  local brightness = round(clamp(value, 0, 1000) / 10)
  device:set_field(LIDL_BRIGHTNESS_FIELD, brightness, { persist = false })
  return brightness
end

local function lidl_latest(device, field, capability_id, attribute, fallback)
  local value = device:get_field(field)
  if value == nil and type(device.get_latest_state) == "function" then
    value = device:get_latest_state("main", capability_id, attribute)
  end
  local number = tonumber(value)
  if number == nil then return fallback end
  return number
end

local function lidl_color_payload(device, hue, saturation, brightness)
  -- Frozen fillInHSB uses JavaScript truthiness. Zero hue/saturation falls
  -- back to reported state, or to its 360/1000 defaults when state is zero.
  local requested_hue = false
  local degrees = 360
  local hue_value = tonumber(hue)
  if hue_value ~= nil and hue_value ~= 0 then
    degrees = hue_value * 3.6
    requested_hue = true
  else
    local latest_hue = lidl_latest(device, LIDL_HUE_FIELD, "colorControl", "hue", 0)
    if latest_hue ~= 0 then degrees = latest_hue * 3.6 end
  end
  if requested_hue and degrees >= 360 then degrees = 359 end
  degrees = round(clamp(degrees, 0, requested_hue and 359 or 360))

  local saturation_value = tonumber(saturation)
  local saturation_raw = 1000
  if saturation_value ~= nil and saturation_value ~= 0 then
    saturation_raw = round(clamp(saturation_value, 0, 100) * 10)
  else
    local latest_saturation = lidl_latest(
      device, LIDL_SATURATION_FIELD, "colorControl", "saturation", 0
    )
    if latest_saturation ~= 0 then
      saturation_raw = round(clamp(latest_saturation, 0, 100) * 10)
    end
  end

  local brightness_value = tonumber(brightness)
  local brightness_raw = 1000
  if brightness_value ~= nil and brightness_value ~= 0 then
    brightness_raw = round(clamp(brightness_value, 0, 100) * 10)
  else
    local latest_brightness = lidl_latest(
      device, LIDL_BRIGHTNESS_FIELD, "switchLevel", "level", 0
    )
    if latest_brightness ~= 0 then
      brightness_raw = round(clamp(latest_brightness, 0, 100) * 10)
    end
  end

  device:set_field(LIDL_HUE_FIELD, degrees / 3.6, { persist = false })
  device:set_field(LIDL_SATURATION_FIELD, saturation_raw / 10, { persist = false })
  device:set_field(LIDL_BRIGHTNESS_FIELD, brightness_raw / 10, { persist = false })
  return string.format("%04x%04x%04x", degrees, saturation_raw, brightness_raw)
end

local function lidl_brightness_write(_, value)
  return {
    { dp = 2, datatype = tuya.DP_TYPE_ENUM, value = 0 },
    { dp = 3, datatype = tuya.DP_TYPE_VALUE, value = round(clamp(value, 0, 100) * 10) },
  }
end

local function lidl_color_write(device, value)
  if type(value) ~= "table" then return nil end
  return {
    { dp = 2, datatype = tuya.DP_TYPE_ENUM, value = 1 },
    { dp = 5, datatype = tuya.DP_TYPE_STRING, value = lidl_color_payload(device, value.hue, value.saturation, value.brightness) },
  }
end

local function lidl_hue_write(device, value)
  return lidl_color_write(device, { hue = value })
end

local function lidl_saturation_write(device, value)
  return lidl_color_write(device, { saturation = value })
end

local lidl_datapoints = {
  tuya.dp_enum(2, { name = "lidl_change_mode", read_only = true, transaction = 1 }),
  tuya.dp_numeric(3, { name = "lidl_brightness_report", read_only = true, transaction = 1, converter = converter.from_only(lidl_white_brightness_from_device), emit = emit.level() }),
  tuya.dp_string(5, { name = "lidl_hue_report", read_only = true, transaction = 1, converter = converter.from_only(lidl_hue_from_device), emit = emit.color_hue() }),
  tuya.dp_string(5, { name = "lidl_saturation_report", read_only = true, transaction = 1, converter = converter.from_only(lidl_saturation_from_device), emit = emit.color_saturation() }),
  tuya.dp_string(5, { name = "lidl_color_brightness_report", read_only = true, transaction = 1, converter = converter.from_only(lidl_color_brightness_from_device), emit = emit.level() }),
  tuya.dp_string(6, { name = "lidl_effect_payload", read_only = true, transaction = 1 }),
}

local lidl = {
  profile = "lights-wave19-lidl-hg06467",
  package_group = "wave19-light",
  transport_classification = "HYBRID_ZCL_EF00",
  z2m_converter_source = "legacy.silvercrest_smart_led_string",
  wire_cluster = "genOnOff + manuSpecificTuya",
  magic_packet = false,
  query_on_configure = false,
  time_start = "off",
  auto_connection_status = false,
  initial_custom_state_query = false,
  refresh_state_query = false,
  auto_on_before_light_command = false,
  datapoints = lidl_datapoints,
  named_mapping = {
    named_mappings = {
      brightness = lidl_brightness_write,
      color = lidl_color_write,
      color_hue = lidl_hue_write,
      color_saturation = lidl_saturation_write,
    },
  },
  zcl_clusters = {
    zcl.switch({
      endpoint = 1,
      read_only = false,
      configure_reporting = false,
      read_on_configure = false,
    }),
  },
}

register_device_definition(lidl, {
  device_helpers.create_fingerprint("_TZE200_s8gkrkxk", "TS0601"),
})

-- Lonsonho ---------------------------------------------------------------

local lonsonho = two_channel_dimmer(
  "lights-wave19-lonsonho-vm-s02-010v",
  "lonsonhoVmTwo",
  converter.lookup_from_to({ momentary = 0, toggle = 1, state = 2 })
)

register_device_definition(lonsonho, {
  -- The trailing NUL is part of the manufacturerName fingerprint.
  device_helpers.create_fingerprint("_TZE600_wxq8dpha\0", "TS0603"),
})

-- QA QADZ4DIN --------------------------------------------------------------

local qa = tuya_lifecycle("lights-wave19-qa-qadz4din", {
  tuya.dp_on_off(1, { name = "switch", component = "main", transaction = 1, emit = emit.switch() }),
  tuya.dp_numeric(2, { name = "brightness", component = "main", transaction = 1, converter = brightness_zero_to_thousand, emit = emit.level() }),
  tuya.dp_numeric(3, { name = "qaQadzFour_min_brightness", component = "main", transaction = 1, converter = brightness_zero_to_thousand, emit = custom("qaQadzFourMinBrightness") }),
  tuya.dp_on_off(7, { name = "switch", component = "switch2", transaction = 1, emit = emit.switch() }),
  tuya.dp_numeric(8, { name = "brightness", component = "switch2", transaction = 1, converter = brightness_zero_to_thousand, emit = emit.level() }),
  tuya.dp_numeric(9, { name = "qaQadzFour_min_brightness", component = "switch2", transaction = 1, converter = brightness_zero_to_thousand, emit = custom("qaQadzFourMinBrightness") }),
  tuya.dp_enum(14, { name = "qaQadzFour_power_behavior", transaction = 1, converter = POWER_BEHAVIOR, emit = custom("qaQadzFourPowerBehavior") }),
  tuya.dp_on_off(15, { name = "switch", component = "switch3", transaction = 1, emit = emit.switch() }),
  tuya.dp_numeric(16, { name = "brightness", component = "switch3", transaction = 1, converter = brightness_zero_to_thousand, emit = emit.level() }),
  tuya.dp_numeric(17, { name = "qaQadzFour_min_brightness", component = "switch3", transaction = 1, converter = brightness_zero_to_thousand, emit = custom("qaQadzFourMinBrightness") }),
  tuya.dp_on_off(101, { name = "switch", component = "switch4", transaction = 1, emit = emit.switch() }),
  tuya.dp_numeric(102, { name = "brightness", component = "switch4", transaction = 1, converter = brightness_zero_to_thousand, emit = emit.level() }),
  tuya.dp_numeric(103, { name = "qaQadzFour_min_brightness", component = "switch4", transaction = 1, converter = brightness_zero_to_thousand, emit = custom("qaQadzFourMinBrightness") }),
  tuya.dp_enum(105, { name = "qaQadzFour_dimming_speed", transaction = 1, converter = converter.lookup_from_to({ slow = 0, middle = 1, fast = 2 }), emit = custom("qaQadzFourDimmingSpeed") }),
  -- Frozen exposes only momentary/toggle even though switchType can decode raw 2.
  tuya.dp_enum(106, { name = "qaQadzFour_switch_type", transaction = 1, converter = converter.lookup_from_to({ momentary = 0, toggle = 1 }), emit = custom("qaQadzFourSwitchType") }),
})

register_device_definition(qa, {
  device_helpers.create_fingerprint("_TZE284_nthhgkd6", "TS0601"),
})

-- Nova Digital Topazio ------------------------------------------------------

local nova_brightness = converter.from_to(
  function(value)
    local raw = clamp(value, 10, 1000)
    local z2m_brightness = round((raw - 10) * 254 / 990)
    return round(z2m_brightness * 100 / 254)
  end,
  function(value)
    local z2m_brightness = round(clamp(value, 0, 100) * 254 / 100)
    return round(10 + z2m_brightness * 990 / 254)
  end
)

local nova_percent = converter.from_to(
  function(value) return round(clamp(value, 10, 1000) / 10) end,
  function(value) return round(clamp(value, 1, 100) * 10) end
)

local nova = tuya_lifecycle("lights-wave19-nova-topazio", {
  tuya.dp_on_off(1, { name = "switch", transaction = 1, emit = emit.switch() }),
  tuya.dp_numeric(2, { name = "brightness", transaction = 1, converter = nova_brightness, emit = emit.level() }),
  tuya.dp_numeric(3, { name = "novaTopazio_min_brightness", transaction = 1, converter = nova_percent, emit = custom("novaTopazioMinBrightness") }),
  tuya.dp_enum(4, { name = "novaTopazio_light_type", transaction = 1, converter = converter.lookup_from_to({ led = 0, incandescent = 1, halogen = 2 }), emit = custom("novaTopazioLightType") }),
  tuya.dp_numeric(5, { name = "novaTopazio_max_brightness", transaction = 1, converter = nova_percent, emit = custom("novaTopazioMaxBrightness") }),
  tuya.dp_numeric(6, { name = "novaTopazio_countdown", transaction = 1, emit = custom("novaTopazioCountdown") }),
  tuya.dp_enum(14, { name = "novaTopazio_power_behavior", transaction = 1, converter = POWER_BEHAVIOR, emit = custom("novaTopazioPowerBehavior") }),
  tuya.dp_enum(21, { name = "novaTopazio_indicator_mode", transaction = 1, converter = converter.lookup_from_to({ none = 0, relay = 1, pos = 2 }), emit = custom("novaTopazioIndicatorMode") }),
  tuya.dp_binary(26, { name = "novaTopazio_backlight", transaction = 1, converter = ON_OFF, emit = custom("novaTopazioBacklight") }),
})
nova.time_start = "1970"

register_device_definition(nova, {
  device_helpers.create_fingerprint("_TZE284_5yah8qx4", "TS0601"),
})

return {
  id = "ef00.lights.wave19.exact",
  registrations = device_definitions,
}
