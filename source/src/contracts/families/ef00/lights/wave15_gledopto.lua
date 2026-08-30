-- Wave15 Gledopto GL-SPI-206P source-only candidate.
-- Frozen Zigbee2MQTT v26.99.0: src/devices/gledopto.ts:10-111,
-- 220-314 and 1243-1355.  Scene/music payloads and the extra DP61 color
-- writer are copied byte-for-byte from that definition.

local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"

local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()

local function custom(name)
  return assert(emit[name], "missing Wave15 GL-SPI emitter: " .. name)()
end

local function clamp(value, minimum, maximum)
  if value < minimum then return minimum end
  if value > maximum then return maximum end
  return value
end

local function round(value)
  return math.floor(value + 0.5)
end

local function hex_bytes(value)
  local bytes = {}
  for index = 1, #value, 2 do
    bytes[#bytes + 1] = string.char(tonumber(value:sub(index, index + 1), 16))
  end
  return table.concat(bytes)
end

local SCENE_HEX = {
  ice_land_blue = "01150a5252e000006400c16100b43000b55200c463",
  glacier_express = "01160a64646000006400925f00c660",
  sea_of_clouds = "0117035e5e6000006400382f001e5c00d545011a64",
  fireworks_at_sea = "0118026464e000006400b239010a64012d64013f64",
  firefly_night = "011a034b4be000006400e039010953",
  grass_land = "011c0a5a5ae0000052009d64008e64",
  northern_lights = "011d035252e000006400ae6400a66400c16400cc64",
  late_autumn = "011e0a5252e000006400196400225e002c5b001464000c64",
  game = "011f025f5f6000006401106400d26400ad64008b64",
  holiday = "01200a55556000006400c258013e3300ff46011d64",
  party = "01220464646000006400d75c00bc5300371e002c3f01613f",
  trend = "01230264646000006401084b00b12f00cd57",
  meditation = "01250343436000006400b735009b5400cd61",
  dating = "0126015959e000006401194701493d00cd61002664",
  valentines_day = "012a01646460000064011564010564014564012f64",
  neon_world = "01370a5a5a6000006400335800186401004500e35e00ac30",
}

local MUSIC_HEX = {
  rock = "0101000364320100006400006400786400f064003c6400b464012c64000000",
  jazz = "0101000264320100006400005000785000f050003c5000b450012c50000000",
  classic = "0101001264320100006400006400786400f064003c6400b464012c64000000",
  rolling = "0101011264320100006400006400786400f064003c6400b464012c64000000",
  energy = "0101021264320100006400006400786400f064003c6400b464012c64000000",
  spectrum = "0101031264320100006400006400786400f064003c6400b464012c64000000",
}

local SCENE_DATA, MUSIC_DATA = {}, {}
local SCENE_BY_DATA = {}
for name, hex in pairs(SCENE_HEX) do
  local data = hex_bytes(hex)
  SCENE_DATA[name] = data
  SCENE_BY_DATA[data] = name
end
for name, hex in pairs(MUSIC_HEX) do MUSIC_DATA[name] = hex_bytes(hex) end

local MUSIC_MODE_FIELD = "gl_spi_music_mode"
local MUSIC_SENSITIVITY_FIELD = "gl_spi_music_sensitivity"
local HUE_FIELD = "gl_spi_hue"
local SATURATION_FIELD = "gl_spi_saturation"

local function latest(device, field, capability_id, attribute_name, fallback)
  local value = type(device.get_field) == "function" and device:get_field(field) or nil
  if value == nil and type(device.get_latest_state) == "function" then
    value = device:get_latest_state("main", capability_id, attribute_name)
  end
  if value == nil then return fallback end
  return value
end

local function store(device, field, value)
  if type(device.set_field) == "function" then
    device:set_field(field, value, { persist = false })
  end
  return value
end

local function mode_from_raw(value, device)
  if type(value) ~= "string" or #value < 4 then return nil end
  for name, data in pairs(MUSIC_DATA) do
    if value:sub(1, 4) == data:sub(1, 4) then return store(device, MUSIC_MODE_FIELD, name) end
  end
  return nil
end

local function scene_from_raw(value)
  return type(value) == "string" and SCENE_BY_DATA[value] or nil
end

local function send_on_and_mode(device, mode)
  local switch_state = latest(device, "switch", "switch", "switch", nil)
  if switch_state ~= "on" and switch_state ~= true then
    if tuya.send_datapoint(device, 1, tuya.DP_TYPE_BOOL, true) == nil then return false end
  end
  local work_mode = latest(device, "gl_spi_work_mode", "concertmirror08464.glSpiWorkMode", "workMode", nil)
  if work_mode ~= mode then
    if tuya.send_datapoint(
      device, 2, tuya.DP_TYPE_ENUM,
      ({ white = 0, colour = 1, scene = 2, music = 3 })[mode]
    ) == nil then return false end
  end
  return true
end

local function brightness_write(device, value)
  local level = clamp(tonumber(value) or 0, 0, 100)
  if not send_on_and_mode(device, "colour") then return nil end
  return {
    dp = 3, datatype = tuya.DP_TYPE_VALUE,
    value = clamp(round(10 + level * 990 / 100), 10, 1000),
  }
end

local function color_payload(device, hue, saturation)
  local hue_value = clamp(tonumber(hue) or 0, 0, 100)
  local saturation_value = clamp(tonumber(saturation) or 0, 0, 100)
  store(device, HUE_FIELD, hue_value)
  store(device, SATURATION_FIELD, saturation_value)
  local degrees = clamp(round(hue_value * 3.6), 0, 360)
  local saturation_raw = clamp(round(saturation_value * 10), 0, 1000)
  return string.char(
    0x00, 0x01, 0x01, 0x14, 0x00,
    math.floor(degrees / 256), degrees % 256,
    math.floor(saturation_raw / 256), saturation_raw % 256,
    0x03, 0xE8
  )
end

local function color_write(device, value)
  if type(value) ~= "table" then return nil end
  local hue = value.hue
  local saturation = value.saturation
  if hue == nil or saturation == nil then return nil end
  if not send_on_and_mode(device, "colour") then return nil end
  return {
    dp = 61, datatype = tuya.DP_TYPE_RAW,
    value = color_payload(device, hue, saturation),
  }
end

local function hue_write(device, value)
  return color_write(device, {
    hue = value,
    saturation = latest(device, SATURATION_FIELD, "colorControl", "saturation", 100),
  })
end

local function saturation_write(device, value)
  return color_write(device, {
    hue = latest(device, HUE_FIELD, "colorControl", "hue", 0),
    saturation = value,
  })
end

local function music_write(device, name, value)
  local mode = latest(device, MUSIC_MODE_FIELD, "concertmirror08464.glSpiMusicMode", "musicMode", "rock")
  local sensitivity = tonumber(latest(
    device, MUSIC_SENSITIVITY_FIELD,
    "concertmirror08464.glSpiMusicSensitivity", "musicSensitivity", 50
  )) or 50
  if name == "gl_spi_music_mode" then mode = value else sensitivity = tonumber(value) or sensitivity end
  local base = MUSIC_DATA[mode]
  if base == nil then return nil end
  sensitivity = clamp(round(sensitivity), 1, 100)
  store(device, MUSIC_MODE_FIELD, mode)
  store(device, MUSIC_SENSITIVITY_FIELD, sensitivity)
  local data = base:sub(1, 5) .. string.char(sensitivity) .. base:sub(7)
  if not send_on_and_mode(device, "music") then return nil end
  return { dp = 52, datatype = tuya.DP_TYPE_RAW, value = data }
end

local sequence_values = {
  RGB = 0, RBG = 1, GRB = 2, GBR = 3, BRG = 4, BGR = 5,
  RGBW = 6, RBGW = 7, GRBW = 8, GBRW = 9, BRGW = 10, BGRW = 11,
  WRGB = 12, WRBG = 13, WGRB = 14, WGBR = 15, WBRG = 16, WBGR = 17,
}
local chip_values = {
  WS2801 = 0, LPD6803 = 1, LPD8803 = 2, WS2811 = 3, TM1814B = 4,
  TM1934A = 5, SK6812 = 6, SK9822 = 7, UCS8904B = 8, WS2805 = 9,
}

local gl_spi = {
  profile = "lights-wave15-gledopto-gl-spi-206p",
  package_group = "pixel-light",
  transport_classification = "EF00_DP",
  z2m_converter_source = "meta.tuyaDatapoints+local.toZigbee",
  wire_cluster = "manuSpecificTuya",
  magic_packet = true,
  query_on_configure = false,
  time_start = "off",
  auto_on_before_light_command = false,
  datapoints = {
    tuya.dp_on_off(1, { name = "switch", transaction = 1, emit = emit.switch() }),
    tuya.dp_enum(2, {
      name = "gl_spi_work_mode", transaction = 1,
      converter = converter.lookup_from_to({ white = 0, colour = 1, scene = 2, music = 3 }),
      emit = custom("glSpiWorkMode"),
    }),
    tuya.dp_numeric(3, {
      name = "brightness", read_only = true, transaction = 1,
      converter = converter.from_only(function(value) return clamp((tonumber(value) or 0) / 10, 0, 100) end),
      emit = emit.level(),
    }),
    tuya.dp_numeric(4, {
      name = "gl_spi_color_temp_raw", transaction = 1,
      emit = custom("glSpiColorTempRaw"),
    }),
    tuya.dp_numeric(7, { name = "gl_spi_countdown", transaction = 1, emit = custom("glSpiCountdown") }),
    tuya.dp_raw(51, {
      name = "gl_spi_scene", transaction = 1,
      converter = converter.from_to(scene_from_raw, function(value) return SCENE_DATA[value] end),
      emit = custom("glSpiScene"),
    }),
    tuya.dp_raw(52, {
      name = "gl_spi_music_mode", transaction = 1,
      converter = converter.from_to(mode_from_raw, function(value) return MUSIC_DATA[value] end),
      emit = custom("glSpiMusicMode"),
    }),
    tuya.dp_numeric(53, {
      name = "gl_spi_pixel_count", transaction = 1,
      emit = custom("glSpiPixelCount"),
    }),
    tuya.dp_enum(101, {
      name = "gl_spi_bead_sequence", transaction = 1,
      converter = converter.lookup_from_to(sequence_values), emit = custom("glSpiBeadSequence"),
    }),
    tuya.dp_enum(102, {
      name = "gl_spi_chip_type", transaction = 1,
      converter = converter.lookup_from_to(chip_values), emit = custom("glSpiChipType"),
    }),
    tuya.dp_binary(103, {
      name = "gl_spi_do_not_disturb", transaction = 1,
      converter = converter.lookup_from_to({ ON = true, OFF = false }), emit = custom("glSpiDoNotDisturb"),
    }),
  },
  named_mapping = {
    named_mappings = {
      brightness = brightness_write,
      color = color_write,
      color_hue = hue_write,
      color_saturation = saturation_write,
      gl_spi_music_mode = function(device, value) return music_write(device, "gl_spi_music_mode", value) end,
      gl_spi_music_sensitivity = function(device, value) return music_write(device, "gl_spi_music_sensitivity", value) end,
    },
  },
}

register_device_definition(gl_spi, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_8fffc3kb",
  "_TZE284_gt5al3bl",
}))

return {
  id = "ef00.lights.wave15_gledopto",
  registrations = device_definitions,
}
