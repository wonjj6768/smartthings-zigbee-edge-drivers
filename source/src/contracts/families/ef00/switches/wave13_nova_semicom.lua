-- Wave13 Nova Digital TO-WK and Tuya Semicom source-only candidates.
-- Frozen Zigbee2MQTT v26.99.0: src/devices/tuya.ts:6458-6679,8834-8873.

local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"

local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()

local BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function custom(name)
  return assert(emit[name], "missing Wave13 custom emitter: " .. name)()
end

local function base64_value(character)
  local index = string.find(BASE64, character, 1, true)
  return index ~= nil and index - 1 or nil
end

local function encode_three(a, b, c)
  return table.concat({
    string.sub(BASE64, math.floor(a / 4) + 1, math.floor(a / 4) + 1),
    string.sub(BASE64, (a % 4) * 16 + math.floor(b / 16) + 1, (a % 4) * 16 + math.floor(b / 16) + 1),
    string.sub(BASE64, (b % 16) * 4 + math.floor(c / 64) + 1, (b % 16) * 4 + math.floor(c / 64) + 1),
    string.sub(BASE64, c % 64 + 1, c % 64 + 1),
  })
end

local function decode_three(block)
  if type(block) ~= "string" or #block < 4 then return nil end
  local a = base64_value(string.sub(block, 1, 1))
  local b = base64_value(string.sub(block, 2, 2))
  local c = base64_value(string.sub(block, 3, 3))
  local d = base64_value(string.sub(block, 4, 4))
  if a == nil or b == nil or c == nil or d == nil then return nil end
  return math.floor(a * 4 + b / 16),
    math.floor((b % 16) * 16 + c / 4),
    math.floor((c % 4) * 64 + d)
end

local function clamp_seconds(value)
  local numeric = tonumber(value) or 0
  if numeric < 0 then numeric = 0 end
  if numeric > 3600 then numeric = 3600 end
  return math.floor(numeric)
end

local function encode_inching(channel, value)
  local seconds = clamp_seconds(value)
  local control = seconds > 0 and 1 or 0
  if channel ~= 1 then control = control + 2 ^ (channel - 1) end
  local wire_seconds = seconds > 0 and seconds or 1
  return encode_three(control, math.floor(wire_seconds / 256), wire_seconds % 256)
end

local function nova_one_inching_converter()
  return converter.from_to(
    function(value)
      local control, high, low = decode_three(value)
      if control == nil then return 0 end
      return control == 1 and (high * 256 + low) or 0
    end,
    function(value) return encode_inching(1, value) end
  )
end

local function control_channel(control)
  if control == 0 or control == 1 then return 1 end
  local exponent = 0
  local value = control
  while value >= 2 do
    value = math.floor(value / 2)
    exponent = exponent + 1
  end
  return exponent + 1
end

local function nova_two_inching_converter(wanted_channel)
  return converter.from_to(
    function(value)
      if type(value) ~= "string" then return nil end
      local result = nil
      for offset = 1, #value, 4 do
        local control, high, low = decode_three(string.sub(value, offset, offset + 3))
        if control ~= nil and control_channel(control) == wanted_channel then
          result = control % 2 == 1 and (high * 256 + low) or 0
        end
      end
      return result
    end,
    function(value) return encode_inching(wanted_channel, value) end
  )
end

local function append(definition, mapping)
  definition.datapoints[#definition.datapoints + 1] = mapping
end

local function build_nova(profile, capability_prefix, mapping_prefix, channels)
  local definition = {
    profile = profile,
    package_group = "switch-panel",
    transport_classification = "CUSTOM_PAYLOAD",
    z2m_converter_source = "meta.tuyaDatapoints+convLocal.novaDigitalToWk*",
    wire_cluster = "manuSpecificTuya",
    magic_packet = true,
    query_on_configure = false,
    time_start = "1970",
    datapoints = {},
  }

  local words = { "One", "Two", "Three" }
  local lower_words = { "one", "two", "three" }
  for index = 1, channels do
    append(definition, tuya.dp_on_off(index, {
      name = "switch",
      component = index == 1 and "main" or ("switch" .. tostring(index)),
      emit = emit.switch(),
    }))
  end
  for index = 1, channels do
    append(definition, tuya.dp_numeric(index + 6, {
      name = mapping_prefix .. "_countdown_" .. lower_words[index],
      emit = custom(capability_prefix .. "Countdown" .. words[index]),
    }))
  end
  append(definition, tuya.dp_enum(14, {
    name = mapping_prefix .. "_power_on_behavior",
    converter = converter.lookup_from_to({ off = 0, on = 1, previous = 2 }),
    emit = custom(capability_prefix .. "PowerOnBehavior"),
  }))
  append(definition, tuya.dp_enum(15, {
    name = mapping_prefix .. "_indicator_mode",
    converter = converter.lookup_from_to({ none = 0, relay = 1, pos = 2 }),
    emit = custom(capability_prefix .. "IndicatorMode"),
  }))
  append(definition, tuya.dp_binary(16, {
    name = mapping_prefix .. "_backlight_switch",
    converter = converter.lookup_from_to({ ON = true, OFF = false }),
    emit = custom(capability_prefix .. "BacklightSwitch"),
  }))

  if channels == 2 then
    append(definition, tuya.dp_string(19, {
      name = mapping_prefix .. "_inching_one",
      converter = nova_one_inching_converter(),
      emit = custom(capability_prefix .. "InchingOne"),
    }))
  else
    for index = 1, 2 do
      append(definition, tuya.dp_string(19, {
        name = mapping_prefix .. "_inching_" .. lower_words[index],
        converter = nova_two_inching_converter(index),
        emit = custom(capability_prefix .. "Inching" .. words[index]),
      }))
    end
  end

  append(definition, tuya.dp_numeric(20, {
    name = "energy", read_only = true,
    converter = converter.divide_by_from_only(1000), emit = emit.energy(),
  }))
  append(definition, tuya.dp_numeric(21, {
    name = "current", read_only = true,
    converter = converter.divide_by_from_only(1000), emit = emit.current(),
  }))
  append(definition, tuya.dp_numeric(22, {
    name = "power", read_only = true,
    converter = converter.divide_by_from_only(10), emit = emit.power(),
  }))
  append(definition, tuya.dp_numeric(23, {
    name = "voltage", read_only = true,
    converter = converter.divide_by_from_only(10), emit = emit.voltage(),
  }))
  append(definition, tuya.dp_binary(101, {
    name = mapping_prefix .. "_induction",
    converter = converter.lookup_from_to({ ON = true, OFF = false }),
    emit = custom(capability_prefix .. "Induction"),
  }))
  append(definition, tuya.dp_enum(102, {
    name = mapping_prefix .. "_vibration",
    converter = converter.lookup_from_to({ off = 0, low = 1, medium = 2, high = 3 }),
    emit = custom(capability_prefix .. "Vibration"),
  }))
  return definition
end

local nova_one = build_nova(
  "switches-wave13-nova-to-wk-one", "novaOne", "nova_one", 2
)
register_device_definition(nova_one, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_3xnyj4ga",
}))

local nova_two = build_nova(
  "switches-wave13-nova-to-wk-two", "novaTwo", "nova_two", 3
)
register_device_definition(nova_two, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_exfilann",
}))

local function reverse_enabled(device)
  return type(device) == "table"
    and type(device.preferences) == "table"
    and device.preferences.reverse == true
end

local function cover_position_converter()
  return converter.from_to(
    function(value, device)
      local numeric = tonumber(value)
      if numeric == nil then return nil end
      return reverse_enabled(device) and 100 - numeric or numeric
    end,
    function(value, device)
      local numeric = tonumber(value)
      if numeric == nil then return nil end
      return reverse_enabled(device) and 100 - numeric or numeric
    end
  )
end

local function cover_action_converter()
  return converter.from_to(
    function(value)
      return ({
        [0] = "open",
        [1] = "paused",
        [2] = "closed",
        [3] = "partially open",
      })[tonumber(value)]
    end,
    function(value)
      return ({ open = 0, stop = 1, pause = 1, close = 2 })[value]
    end
  )
end

local shade_level_event = emit.shade_level()
local shade_state_event = emit.shade_state()
local function emit_cover_position(device, value, dp_info, context)
  local events = {}
  local level = shade_level_event(device, value, dp_info, context)
  if level ~= nil then events[#events + 1] = level end
  local state_value = value <= 0 and "closed" or (value >= 100 and "open" or "partially open")
  local state = shade_state_event(device, state_value, dp_info, context)
  if state ~= nil then events[#events + 1] = state end
  return #events > 0 and events or nil
end

local semicom = {
  profile = "switches-wave13-tuya-semicom-two-two",
  package_group = "switch-panel",
  transport_classification = "EF00_DP",
  z2m_converter_source = "meta.tuyaDatapoints",
  wire_cluster = "manuSpecificTuya",
  magic_packet = true,
  query_on_configure = false,
  datapoints = {
    tuya.dp_on_off(101, { name = "switch", component = "main", emit = emit.switch() }),
    tuya.dp_on_off(102, { name = "switch", component = "switch2", emit = emit.switch() }),
    tuya.dp_enum(1, {
      name = "cover_state", component = "cover1",
      converter = cover_action_converter(), emit = emit.shade_state(),
    }),
    tuya.dp_numeric(2, {
      name = "cover_position", component = "cover1",
      converter = cover_position_converter(), emit = emit_cover_position,
    }),
    tuya.dp_enum(4, {
      name = "cover_state", component = "cover2",
      converter = cover_action_converter(), emit = emit.shade_state(),
    }),
    tuya.dp_numeric(5, {
      name = "cover_position", component = "cover2",
      converter = cover_position_converter(), emit = emit_cover_position,
    }),
  },
}
register_device_definition(semicom, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_rgeapp2c",
}))

return {
  id = "ef00.switches.wave13.nova_semicom",
  registrations = device_definitions,
}
