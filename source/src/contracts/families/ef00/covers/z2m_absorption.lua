local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"

local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()

local function window_shade_state_from_position_inverted()
  return converter.from_only(function(value)
    local number_value = tonumber(value)
    if number_value == nil then
      return nil
    end

    number_value = 100 - number_value

    if number_value <= 0 then
      return "closed"
    end

    if number_value >= 100 then
      return "open"
    end

    return "partially open"
  end)
end

local cover_state_standard = converter.lookup_from_to({
  open = 0,
  stop = 1,
  close = 2,
})

local cover_action_shade_state = converter.from_only(function(value)
  return ({
    [0] = "open",
    [1] = "partially open",
    [2] = "closed",
    [3] = "partially open",
  })[tonumber(value)]
end)

local function moes_zs_sf_reverse_enabled(device)
  return type(device) == "table"
    and type(device.preferences) == "table"
    and device.preferences.reverse == true
end

local moes_zs_sf_position = converter.from_to(
  function(value, device)
    local number_value = tonumber(value)
    if number_value == nil then return nil end
    return moes_zs_sf_reverse_enabled(device) and (100 - number_value) or number_value
  end,
  function(value, device)
    local number_value = tonumber(value)
    if number_value == nil then return nil end
    return moes_zs_sf_reverse_enabled(device) and (100 - number_value) or number_value
  end
)

local moes_zs_sf_shade_state = converter.from_only(function(value, device)
  local position = moes_zs_sf_position.from(value, device)
  if position == nil then return nil end
  if position <= 0 then return "closed" end
  if position >= 100 then return "open" end
  return "partially open"
end)

-- MOES GM25TEQ-TYZ-2/25 / Tuya GM35TEQ-TYZ-2/25 tubular motor.
-- Z2M v26.99.0 (moes.ts:1780-1796) writes inverted position on DP9 and
-- reports the same inverted position on DP8. DP11 is a writable normal/
-- reversed tubular-motor direction enum.
local cover_model_gm25teq = {
  profile = "covers-cover-gm25teq",
  tuya.dp_enum(1, {
    name = "cover_state",
    converter = cover_state_standard,
    write_only = true,
  }),
  tuya.dp_enum(1, {
    name = "cover_action_state",
    emit = emit.shade_state(),
    converter = cover_action_shade_state,
    read_only = true,
  }),
  tuya.dp_cover_position_inverted(9, { emit = emit.shade_level() }),
  tuya.dp_numeric(9, {
    name = "window_shade_state_command_position",
    emit = emit.shade_state(),
    converter = window_shade_state_from_position_inverted(),
    read_only = true,
  }),
  tuya.dp_cover_position_inverted(8, {
    name = "cover_position_state",
    emit = emit.shade_level(),
    read_only = true,
  }),
  tuya.dp_numeric(8, {
    name = "window_shade_state",
    emit = emit.shade_state(),
    converter = window_shade_state_from_position_inverted(),
    read_only = true,
  }),
  tuya.dp_numeric(11, {
    name = "motor_direction",
    emit = emit.gm25TeqMotorDirection(),
    -- ZHC 26.107 sends VALUE; older firmware also reports textual direction.
    converter = converter.from_to(function(value)
      return (value == 1 or value == "back" or value == "reversed") and "reversed" or "normal"
    end, function(value)
      return ({normal = 0, reversed = 1})[value]
    end),
  }),
  query_on_configure = false,
  time_start = "off",
}

-- MOES ZS-SF-EUC-WH-MS. Z2M v26.99.0 moes.ts:494-508 exposes the
-- DP1 coverAction enum and DP2 coverPosition, including the software
-- invert_cover option. SmartThings' built-in reverse preference implements
-- that option only for position, matching Z2M.
local cover_model_moes_zs_sf_euc_wh_ms = {
  profile = "covers-cover-moes-zs-sf-euc-wh-ms",
  query_on_configure = false,
  time_start = "off",
  tuya.dp_enum(3, {
    name = "moes_sf_calibration", emit = emit.moesSfCalibration(),
    converter = converter.lookup_from_to({start = 0, ["end"] = 1}),
  }),
  tuya.dp_binary(7, {
    name = "moes_sf_backlight", emit = emit.moesSfBacklight(),
    converter = converter.lookup_from_to({on = true, off = false}),
  }),
  tuya.dp_enum(8, {
    name = "moes_sf_direction", emit = emit.moesSfDirection(),
    converter = converter.lookup_from_to({normal = 0, reversed = 1}),
  }),
  tuya.dp_numeric(10, {
    name = "moes_sf_travel_time", emit = emit.moesSfTravelTime(),
  }),
  tuya.dp_enum(1, {
    name = "cover_state",
    converter = cover_state_standard,
    write_only = true,
  }),
  tuya.dp_enum(1, {
    name = "cover_action_state",
    emit = emit.shade_state(),
    converter = cover_action_shade_state,
    read_only = true,
  }),
  tuya.dp_cover_position(2, {
    name = "cover_position",
    emit = emit.shade_level(),
    converter = moes_zs_sf_position,
  }),
  tuya.dp_numeric(2, {
    name = "window_shade_state",
    emit = emit.shade_state(),
    converter = moes_zs_sf_shade_state,
    read_only = true,
  }),
}

register_device_definition(cover_model_gm25teq, device_helpers.create_fingerprints("TS0601", {
  "_TZE204_xtrnjaoz",
  "_TZE200_xtrnjaoz",
  "_TZE284_8whfphjv",
}))

register_device_definition(cover_model_moes_zs_sf_euc_wh_ms, device_helpers.create_fingerprints("TS0601", {
  "_TZE284_upt8lzi0",
  "_TZE28C1000000_i8sdouy0",
}))

-- Current Z2M: Nova Digital ZCMR-1 roller blind motor standard core.
local cover_model_nova_zcmr_one_core = {
  profile = "covers-nova-zcmr1-core",
  package_group = "covers",
  transport_classification = "EF00_DP",
  z2m_converter_source = "meta.tuyaDatapoints",
  wire_cluster = "manuSpecificTuya",
  magic_packet = true,
  mcu_version_request_on_configure = true,
  query_on_configure = true,
  named_datapoints = true,
  time_start = "off",
  placeholder_custom_states = false,
  datapoints = {
    tuya.dp_enum(1, {
      name = "cover_state",
      converter = cover_state_standard,
      write_only = true,
      transaction = 1,
    }),
    tuya.dp_enum(1, {
      name = "cover_action_state",
      converter = cover_action_shade_state,
      read_only = true,
      transaction = 1,
      emit = emit.shade_state(),
    }),
    tuya.dp_cover_position(2, {
      name = "cover_position",
      transaction = 1,
      emit = emit.shade_level(),
    }),
    tuya.dp_numeric(2, {
      name = "cover_position_shade_state",
      converter = converter.from_only(function(value)
        if value <= 0 then return "closed" end
        if value >= 100 then return "open" end
        return "partially open"
      end),
      read_only = true,
      transaction = 1,
      emit = emit.shade_state(),
    }),
    tuya.dp_cover_position(3, {
      name = "cover_position_report",
      read_only = true,
      transaction = 1,
      emit = emit.shade_level(),
    }),
    tuya.dp_numeric(3, {
      name = "cover_position_report_shade_state",
      converter = converter.from_only(function(value)
        if value <= 0 then return "closed" end
        if value >= 100 then return "open" end
        return "partially open"
      end),
      read_only = true,
      transaction = 1,
      emit = emit.shade_state(),
    }),
  },
}

register_device_definition(cover_model_nova_zcmr_one_core, {
  device_helpers.create_fingerprint("_TZE204_dqy15zxy", "TS0601"),
})

return {
  id = "ef00.covers.z2m_absorption",
  registrations = device_definitions,
}
