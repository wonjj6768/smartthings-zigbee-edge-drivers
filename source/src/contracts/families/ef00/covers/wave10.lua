-- Wave 10 cover candidates reviewed against frozen Zigbee2MQTT v26.99.0.
--
-- These registrations intentionally stay isolated from the global catalog and
-- fingerprint manifest until the separate family-by-family audit is complete.

local tuya = require "protocol.tuya"
local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"

local cluster_base = require "st.zigbee.cluster_base"
local data_types = require "st.zigbee.data_types"

local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()

local function reverse_enabled(device)
  return type(device) == "table"
    and type(device.preferences) == "table"
    and device.preferences.reverse == true
end

local function position_value(value, device, invert_wire, overflow_guard, apply_reverse)
  local numeric = tonumber(value)
  if numeric == nil then return nil end

  if overflow_guard and numeric > 100 then
    numeric = numeric > 150 and 0 or 100
  end
  if invert_wire then numeric = 100 - numeric end
  if apply_reverse and reverse_enabled(device) then numeric = 100 - numeric end
  return numeric
end

local function position_converter(options)
  options = options or {}
  return converter.from_to(
    function(value, device)
      return position_value(
        value,
        device,
        options.invert_wire == true,
        options.overflow_guard == true,
        options.reverse_from ~= false
      )
    end,
    function(value, device)
      local numeric = tonumber(value)
      if numeric == nil then return nil end
      if options.invert_wire == true then numeric = 100 - numeric end
      if options.reverse_to ~= false and reverse_enabled(device) then numeric = 100 - numeric end
      return numeric
    end
  )
end

local function shade_state_from_normalized_position(options)
  local pair = position_converter(options)
  return converter.from_only(function(value, device)
    local position = pair.from(value, device)
    if position == nil then return nil end
    if position <= 0 then return "closed" end
    if position >= 100 then return "open" end
    return "partially open"
  end)
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
      return ({ open = 0, stop = 1, close = 2 })[value]
    end
  )
end

local function state_converter(normal, reversed)
  return converter.from_to(
    function(value, device)
      local codes = reverse_enabled(device) and reversed or normal
      local numeric = tonumber(value)
      if numeric == codes.open then return "open" end
      if numeric == codes.stop then return "paused" end
      if numeric == codes.close then return "closed" end
      return nil
    end,
    function(value, device)
      local codes = reverse_enabled(device) and reversed or normal
      return ({ open = codes.open, stop = codes.stop, close = codes.close })[value]
    end
  )
end

local function motor_state_converter(normal, reversed)
  return converter.from_only(function(value, device)
    local codes = reverse_enabled(device) and reversed or normal
    local numeric = tonumber(value)
    if numeric == codes.opening then return "opening" end
    if numeric == codes.closing then return "closing" end
    if codes.stopped ~= nil and numeric == codes.stopped then return "stopped" end
    return nil
  end)
end

local function append_position(definition, dp, options)
  options = options or {}
  definition.datapoints[#definition.datapoints + 1] = tuya.dp_numeric(dp, {
    name = options.name or "cover_position",
    read_only = options.read_only == true,
    write_only = options.write_only == true,
    command_id = options.command_id,
    converter = position_converter(options),
    emit = emit.shade_level(),
  })
  definition.datapoints[#definition.datapoints + 1] = tuya.dp_numeric(dp, {
    name = (options.name or "cover_position") .. "_shade_state",
    read_only = true,
    converter = shade_state_from_normalized_position(options),
    emit = emit.shade_state(),
  })
end

local function append_cover_action(definition, dp, options)
  options = options or {}
  definition.datapoints[#definition.datapoints + 1] = tuya.dp_enum(dp, {
    name = options.name or "cover_state",
    read_only = options.read_only == true,
    write_only = options.write_only == true,
    command_id = options.command_id,
    converter = cover_action_converter(),
    emit = options.emit == false and nil or emit.shade_state(),
  })
end

local function append_battery(definition, dp)
  definition.datapoints[#definition.datapoints + 1] = tuya.dp_battery(dp, {
    read_only = true,
    emit = emit.battery(),
  })
end

local function base_definition(profile)
  return {
    profile = profile,
    package_group = "cover",
    transport_classification = "EF00_DP",
    z2m_converter_source = "meta.tuyaDatapoints",
    wire_cluster = "manuSpecificTuya",
    magic_packet = true,
    datapoints = {},
  }
end

local function exacts(model, manufacturers)
  return device_helpers.create_fingerprints(model, manufacturers)
end

-- ADCBZI01 is a hybrid contract. Frozen Z2M orders standard WindowCovering
-- setters before tuya.tz.datapoints, so DP1/2/3 are receive-only here and all
-- shade commands use cluster 0x0102. DP3 is coverPositionInverted.
local adcbzi = base_definition("covers-wave10-moes-adcbzi01")
adcbzi.wire_cluster = "closuresWindowCovering+manuSpecificTuya"
adcbzi.magic_packet = false
adcbzi.query_on_configure = true
adcbzi.zcl_clusters = {
  zcl.tuya_magic_packet(),
  zcl.cover_position({
    read_only = false,
    converter = position_converter({ invert_wire = true }),
  }),
  zcl.window_shade_state({
    read_only = true,
    converter = converter.from_only(function(value)
      local numeric = tonumber(value)
      if numeric == nil then return nil end
      if numeric <= 0 then return "open" end
      if numeric >= 100 then return "closed" end
      return "partially open"
    end),
  }),
  zcl.cover_state({ read_only = false }),
  zcl.cluster_attribute(0x0102, 0xF002, {
    name = "adcbzi_calibration",
    read_only = false,
    attribute_name = "tuyaMotorReversal",
    data_type = data_types.Enum8,
    write_type = data_types.Enum8,
    read_on_configure = true,
    converter = converter.lookup_from_to({
      stop = 0,
      calibrate = 1,
      calibrate_reverse = 2,
    }),
    emit = emit.adcbziCalibration(),
    sender = function(device, mapping, value, context)
      local raw = mapping.converter.to(value, device, context)
      if raw == nil then return false end
      local request = cluster_base.write_attribute(
        device,
        data_types.ClusterId(0x0102),
        data_types.AttributeId(0xF002),
        data_types.Enum8(raw)
      )
      if context ~= nil and context.endpoint ~= nil
        and request.address_header ~= nil and request.address_header.dest_endpoint ~= nil then
        request.address_header.dest_endpoint.value = context.endpoint
      end
      device:send(request)
      return true
    end,
  }),
}
adcbzi.datapoints[#adcbzi.datapoints + 1] = tuya.dp_numeric(1, {
  name = "adcbzi_cover_state_report",
  read_only = true,
  converter = state_converter(
    { open = 0, stop = 1, close = 2 },
    { open = 0, stop = 1, close = 2 }
  ),
  emit = emit.shade_state(),
})
append_position(adcbzi, 2, { name = "adcbzi_position_control_report", read_only = true })
append_position(adcbzi, 3, { name = "adcbzi_position_report", read_only = true, invert_wire = true })
adcbzi.datapoints[#adcbzi.datapoints + 1] = tuya.dp_numeric(7, {
  name = "adcbzi_work_state",
  read_only = true,
  converter = converter.from_only(function(value)
    return ({ [0] = "standby", [1] = "opening", [2] = "closing" })[tonumber(value)]
  end),
  emit = emit.adcbziWorkState(),
})
adcbzi.datapoints[#adcbzi.datapoints + 1] = tuya.dp_numeric(10, {
  name = "adcbzi_total_time", read_only = true, emit = emit.adcbziTotalTime(),
})
adcbzi.datapoints[#adcbzi.datapoints + 1] = tuya.dp_numeric(11, {
  name = "adcbzi_situation_set",
  converter = converter.lookup_from_to({ fully_open = 0, fully_close = 1 }),
  emit = emit.adcbziSituationSet(),
})
adcbzi.datapoints[#adcbzi.datapoints + 1] = tuya.dp_numeric(12, {
  name = "adcbzi_fault", read_only = true,
  converter = converter.from_only(function(value) return tonumber(value) == 0 and "none" or nil end),
  emit = emit.adcbziFault(),
})
append_battery(adcbzi, 13)
adcbzi.datapoints[#adcbzi.datapoints + 1] = tuya.dp_numeric(101, {
  name = "adcbzi_charging_status", read_only = true,
  converter = converter.from_only(function(value)
    return ({ [0] = "none", [1] = "uncharged", [2] = "charging", [3] = "charged" })[tonumber(value)]
  end),
  emit = emit.adcbziChargingStatus(),
})
for offset, name in ipairs({
  "adcbzi_custom_week_prog_one",
  "adcbzi_custom_week_prog_two",
  "adcbzi_custom_week_prog_three",
  "adcbzi_custom_week_prog_four",
}) do
  local emitter = ({
    emit.adcbziCustomWeekProgOne,
    emit.adcbziCustomWeekProgTwo,
    emit.adcbziCustomWeekProgThree,
    emit.adcbziCustomWeekProgFour,
  })[offset]
  adcbzi.datapoints[#adcbzi.datapoints + 1] = tuya.dp_string(102 + offset, {
    name = name,
    emit = emitter(),
  })
end
adcbzi.datapoints[#adcbzi.datapoints + 1] = tuya.dp_illuminance(107, {
  read_only = true, emit = emit.illuminance(),
})
adcbzi.datapoints[#adcbzi.datapoints + 1] = tuya.dp_numeric(108, {
  name = "adcbzi_open_threshold", emit = emit.adcbziOpenThreshold(),
})
adcbzi.datapoints[#adcbzi.datapoints + 1] = tuya.dp_numeric(109, {
  name = "adcbzi_close_threshold", emit = emit.adcbziCloseThreshold(),
})
adcbzi.datapoints[#adcbzi.datapoints + 1] = tuya.dp_numeric(110, {
  name = "adcbzi_curtain_status", emit = emit.adcbziCurtainStatus(),
})
adcbzi.datapoints[#adcbzi.datapoints + 1] = tuya.dp_numeric(111, {
  name = "adcbzi_factory_test", read_only = true, emit = emit.adcbziFactoryTest(),
})
adcbzi.datapoints[#adcbzi.datapoints + 1] = tuya.dp_numeric(112, {
  name = "adcbzi_total_distance", read_only = true, emit = emit.adcbziTotalDistance(),
})
register_device_definition(adcbzi, exacts("TS030F", {
  "_TZ3210_sxtfesc6",
  "_TZ3210_rundhkxp",
}))

local bl82 = base_definition("covers-wave10-manhot-bl82-tyz1")
bl82.respond_to_mcu_version_response = true
append_cover_action(bl82, 1)
append_position(bl82, 2)
append_position(bl82, 3, { name = "position_report", read_only = true })
bl82.datapoints[#bl82.datapoints + 1] = tuya.dp_enum(5, {
  name = "bl_tyz_motor_direction",
  converter = converter.lookup_from_to({ normal = 0, reversed = 1 }),
  emit = emit.blTyzMotorDirection(),
})
append_battery(bl82, 13)
bl82.datapoints[#bl82.datapoints + 1] = tuya.dp_binary(6, {
  name = "bl_tyz_auto_power",
  converter = converter.lookup_from_to({ ON = true, OFF = false }),
  emit = emit.blTyzAutoPower(),
})
register_device_definition(bl82, exacts("TS0601", { "_TZE284_7qc2wlqr" }))

local zs_sr = base_definition("covers-wave10-moes-zs-sr-euc")
append_cover_action(zs_sr, 1)
-- Frozen custom converter is asymmetric: RX only applies the overflow guard,
-- while TX delegates to coverPosition.to and therefore honors invert_cover.
append_position(zs_sr, 2, { overflow_guard = true, reverse_from = false })
zs_sr.datapoints[#zs_sr.datapoints + 1] = tuya.dp_enum(3, {
  name = "zs_sr_calibration",
  converter = converter.lookup_from_to({ START = 0, END = 1 }),
  emit = emit.zsSrCalibration(),
})
zs_sr.datapoints[#zs_sr.datapoints + 1] = tuya.dp_enum(8, {
  name = "zs_sr_motor_steering",
  converter = converter.lookup_from_to({ FORWARD = 0, BACKWARD = 1 }),
  emit = emit.zsSrMotorSteering(),
})
register_device_definition(zs_sr, exacts("TS0601", { "_TZE204_srmahpwl" }))

local zc_lp = base_definition("covers-wave10-moes-zc-lp01")
zc_lp.datapoints[#zc_lp.datapoints + 1] = tuya.dp_numeric(102, {
  name = "cover_state",
  command_id = tuya.SEND_DATA,
  converter = state_converter(
    { open = 0, stop = 2, close = 1 },
    { open = 1, stop = 2, close = 0 }
  ),
  emit = emit.shade_state(),
})
append_position(zc_lp, 104, { command_id = tuya.SEND_DATA })
append_battery(zc_lp, 4)
zc_lp.datapoints[#zc_lp.datapoints + 1] = tuya.dp_numeric(105, {
  name = "zc_lp_charging", read_only = true,
  converter = converter.from_only(function(value)
    return tonumber(value) == 1 and "charging" or "not_charging"
  end),
  emit = emit.zcLpCharging(),
})
zc_lp.datapoints[#zc_lp.datapoints + 1] = tuya.dp_numeric(106, {
  name = "zc_lp_automatic_mode", command_id = tuya.SEND_DATA,
  converter = converter.lookup_from_to({ ON = 1, OFF = 0 }),
  emit = emit.zcLpAutomaticMode(),
})
zc_lp.datapoints[#zc_lp.datapoints + 1] = tuya.dp_enum(110, {
  name = "zc_lp_slow_mode", command_id = tuya.SEND_DATA,
  converter = converter.lookup_from_to({ ON = 1, OFF = 0 }),
  emit = emit.zcLpSlowMode(),
})
zc_lp.datapoints[#zc_lp.datapoints + 1] = tuya.dp_numeric(112, {
  name = "zc_lp_button_position", command_id = tuya.SEND_DATA,
  converter = converter.lookup_from_to({ UP = 1, DOWN = 0 }),
  emit = emit.zcLpButtonPosition(),
})
register_device_definition(zc_lp, exacts("TS0601", { "_TZ3210_5rta89nj" }))

local fwjz = base_definition("covers-wave10-moes-fwjzceh18a001")
append_cover_action(fwjz, 1)
append_position(fwjz, 9)
append_position(fwjz, 8, { name = "position_report", read_only = true })
fwjz.datapoints[#fwjz.datapoints + 1] = tuya.dp_enum(11, {
  name = "fwjz_motor_direction",
  converter = converter.lookup_from_to({ normal = 0, reversed = 1 }),
  emit = emit.fwjzMotorDirection(),
})
fwjz.datapoints[#fwjz.datapoints + 1] = tuya.dp_raw(13, {
  name = "battery", read_only = true,
  converter = converter.from_only(function(value)
    if type(value) ~= "string" or #value < 4 then return nil end
    local a, b, c, d = string.byte(value, 1, 4)
    return (((a * 256) + b) * 256 + c) * 256 + d
  end),
  emit = emit.battery(),
})
fwjz.datapoints[#fwjz.datapoints + 1] = tuya.dp_enum(16, {
  name = "fwjz_cover_limit",
  converter = converter.lookup_from_to({
    set_up = 0,
    set_down = 1,
    delete_up = 2,
    delete_down = 3,
    delete_both = 4,
  }),
  emit = emit.fwjzCoverLimit(),
})
register_device_definition(fwjz, exacts("TS0601", { "_TZE284_qoi1aqxg" }))

local ts_cover_two = base_definition("covers-wave10-tuya-ts0301-cover-two")
append_cover_action(ts_cover_two, 1)
ts_cover_two.datapoints[#ts_cover_two.datapoints + 1] = tuya.dp_enum(3, {
  name = "ts_cover_two_motor_state", read_only = true,
  converter = motor_state_converter(
    { opening = 0, closing = 1, stopped = 2 },
    { opening = 0, closing = 1, stopped = 2 }
  ),
  emit = emit.tsCoverTwoMotorState(),
})
ts_cover_two.datapoints[#ts_cover_two.datapoints + 1] = tuya.dp_enum(7, {
  name = "ts_cover_two_slow_mode",
  converter = converter.lookup_from_to({ ON = 1, OFF = 0 }),
  emit = emit.tsCoverTwoSlowMode(),
})
append_position(ts_cover_two, 9)
append_position(ts_cover_two, 8, { name = "position_report", read_only = true })
ts_cover_two.datapoints[#ts_cover_two.datapoints + 1] = tuya.dp_enum(11, {
  name = "ts_cover_two_motor_direction",
  converter = converter.lookup_from_to({ normal = 0, reversed = 1 }),
  emit = emit.tsCoverTwoMotorDirection(),
})
append_battery(ts_cover_two, 13)
ts_cover_two.datapoints[#ts_cover_two.datapoints + 1] = tuya.dp_enum(15, {
  name = "ts_cover_two_cover_type",
  converter = converter.lookup_from_to({
    roman_pole = 0,
    roller_blind = 1,
    canopy_curtain = 2,
    roman_blind = 3,
    honeycomb_curtain = 4,
  }),
  emit = emit.tsCoverTwoCoverType(),
})
ts_cover_two.datapoints[#ts_cover_two.datapoints + 1] = tuya.dp_enum(16, {
  name = "ts_cover_two_cover_limit",
  converter = converter.lookup_from_to({
    set_up = 0,
    set_down = 1,
    delete_up = 2,
    delete_down = 3,
    delete_both = 4,
  }),
  emit = emit.tsCoverTwoCoverLimit(),
})
ts_cover_two.datapoints[#ts_cover_two.datapoints + 1] = tuya.dp_numeric(19, {
  name = "ts_cover_two_favorite_position",
  emit = emit.tsCoverTwoFavoritePosition(),
})
ts_cover_two.datapoints[#ts_cover_two.datapoints + 1] = tuya.dp_enum(20, {
  name = "ts_cover_two_click_control",
  converter = converter.lookup_from_to({ up = 0, down = 1 }),
  emit = emit.tsCoverTwoClickControl(),
})
register_device_definition(ts_cover_two, exacts("TS0301", { "_TZE210_xgzzuerd" }))

local x7726 = base_definition("covers-wave10-xenon-x7726")
append_cover_action(x7726, 1)
append_position(x7726, 2)
append_position(x7726, 3, { name = "position_report", read_only = true })
x7726.datapoints[#x7726.datapoints + 1] = tuya.dp_enum(102, {
  name = "x_seven_calibration",
  converter = converter.lookup_from_to({ start = 0, finish = 1 }),
  emit = emit.xSevenCalibration(),
})
x7726.datapoints[#x7726.datapoints + 1] = tuya.dp_numeric(103, {
  name = "temperature", read_only = true, emit = emit.temperature("C"),
})
register_device_definition(x7726, exacts("TS0601", { "_TZE284_hbjwgkdh" }))

local zn_usc = base_definition("covers-wave10-zemismart-zn-usc1u-ht")
append_cover_action(zn_usc, 1)
append_position(zn_usc, 2)
zn_usc.datapoints[#zn_usc.datapoints + 1] = tuya.dp_enum(8, {
  name = "zn_usc_motor_steering",
  converter = converter.lookup_from_to({ FORWARD = 0, BACKWARD = 1 }),
  emit = emit.znUscMotorSteering(),
})
zn_usc.datapoints[#zn_usc.datapoints + 1] = tuya.dp_numeric(10, {
  name = "zn_usc_calibration_time", emit = emit.znUscCalibrationTime(),
})
register_device_definition(zn_usc, exacts("TS0601", { "_TZE204_mpg22jc1" }))

local zmp_one = base_definition("covers-wave10-zemismart-zmp1")
zmp_one.datapoints[#zmp_one.datapoints + 1] = tuya.dp_enum(1, {
  name = "cover_state",
  converter = state_converter(
    { open = 0, stop = 1, close = 2 },
    { open = 2, stop = 1, close = 0 }
  ),
  emit = emit.shade_state(),
})
append_position(zmp_one, 2)
append_position(zmp_one, 3, { name = "position_report", read_only = true })
zmp_one.datapoints[#zmp_one.datapoints + 1] = tuya.dp_enum(5, {
  name = "zmp_one_motor_direction",
  converter = converter.lookup_from_to({ normal = 0, reversed = 1 }),
  emit = emit.zmpOneMotorDirection(),
})
zmp_one.datapoints[#zmp_one.datapoints + 1] = tuya.dp_enum(7, {
  name = "zmp_one_motor_state", read_only = true,
  converter = motor_state_converter(
    { opening = 0, closing = 1 },
    { opening = 1, closing = 0 }
  ),
  emit = emit.zmpOneMotorState(),
})
append_battery(zmp_one, 13)
register_device_definition(zmp_one, exacts("TS0601", { "_TZE284_6hrnp30w" }))

return {
  id = "ef00.covers.wave10",
  registrations = device_definitions,
}
