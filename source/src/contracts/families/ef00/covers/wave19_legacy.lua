-- Wave19 Novo/Somgoms legacy Tuya cover source-only candidates.
-- Frozen Zigbee2MQTT v26.99.0:
--   src/devices/novo.ts:8-16
--   src/devices/somgoms.ts:29-37
--   src/lib/legacy.ts:93-113,537-555,580-617,3529-3592,4178-4218

local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"

local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()

local function reverse_enabled(device)
  return type(device) == "table"
    and type(device.preferences) == "table"
    and device.preferences.reverse == true
end

local function position_converter()
  return converter.from_to(
    function(value, device)
      local numeric = tonumber(value)
      if numeric == nil then return nil end
      numeric = bit32.band(numeric, 0xFF)
      return reverse_enabled(device) and 100 - numeric or numeric
    end,
    function(value, device)
      local numeric = tonumber(value)
      if numeric == nil or numeric < 0 or numeric > 100 then return nil end
      return reverse_enabled(device) and 100 - numeric or numeric
    end
  )
end

local shade_level_event = emit.shade_level()
local shade_state_event = emit.shade_state()
local function emit_position(device, value, dp_info, context)
  local events = {}
  if value >= 0 and value <= 100 then
    local level = shade_level_event(device, value, dp_info, context)
    if level ~= nil then events[#events + 1] = level end
    local state_value = value == 0 and "closed" or (value == 100 and "open" or "partially open")
    local state = shade_state_event(device, state_value, dp_info, context)
    if state ~= nil then events[#events + 1] = state end
  end
  return events[1] ~= nil and events or nil
end

local function definition(profile)
  local position = position_converter()
  return {
    profile = profile,
    package_group = "wave19-cover",
    transport_classification = "CUSTOM_PAYLOAD",
    z2m_converter_source = "legacy.fz.tuya_cover+legacy.tz.tuya_cover_control",
    wire_cluster = "manuSpecificTuya",
    magic_packet = false,
    query_on_configure = false,
    time_start = "off",
    datapoints = {
      -- Frozen RX ignores DP1 because state reports are not reliable. It is
      -- retained only as the ENUM command route, using the default legacy
      -- close/open/stop table for both target manufacturers.
      tuya.dp_enum(1, {
        name = "cover_state",
        write_only = true,
        converter = converter.lookup_from_to({ open = 0, stop = 1, close = 2 }),
      }),
      tuya.dp_numeric(2, {
        name = "cover_position",
        converter = position,
        emit = emit_position,
      }),
      tuya.dp_numeric(3, {
        name = "cover_arrived",
        read_only = true,
        converter = position,
        emit = emit_position,
      }),
      -- The frozen converter parses motor speed but does not expose it.
      tuya.dp_numeric(105, { name = "motor_speed_unexposed", read_only = true }),
    },
  }
end

register_device_definition(definition("covers-wave19-legacy-tuya"), {
  device_helpers.create_fingerprint("_TZE200_swhwv3k3", "TS0601"),
})

register_device_definition(definition("covers-wave19-legacy-tuya"), {
  device_helpers.create_fingerprint("_TZE200_sbordckq", "TS0601"),
})

return {
  id = "ef00.covers.wave19_legacy",
  registrations = device_definitions,
}
