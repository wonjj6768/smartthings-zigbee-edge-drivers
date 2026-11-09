-- Z2M zigbee-herdsman-converters 기반 DP 그룹핑

local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local ef00_helpers = require "contracts.helpers.ef00"

local converter = tuya.converter
local zg204zl_sensitivity_converter = converter.lookup_from_to({
  low = 0,
  medium = 1,
  high = 2,
})
local zg204zl_keep_time_converter = converter.lookup_from_to({
  ["10"] = 0,
  ["30"] = 1,
  ["60"] = 2,
  ["120"] = 3,
})
local tre6haif_sensitivity_converter = converter.lookup_from_to({
  high = 0,
  low = 1,
})
local tre6haif_alarm_mode_converter = converter.lookup_from_to({
  arm = 0,
  silent = 1,
  disarm = 2,
})
local auin8mzr_v_sensitivity_converter = converter.lookup_from_to({
  speed_priority = 0,
  normal_priority = 1,
  accuracy_priority = 2,
})
local auin8mzr_o_sensitivity_converter = converter.lookup_from_to({
  sensitive = 0,
  normal = 1,
  cautious = 2,
})
local auin8mzr_mode_converter = converter.lookup_from_to({
  general_model = 0,
  temporaty_stay = 1,
  basic_detection = 2,
  sensor_test = 3,
})
local auin8mzr_led_status_converter = converter.lookup_from_to({
  ON = 0,
  OFF = 1,
})
local seq9cm6u_sensitivity_converter = converter.lookup_from_to({
  low = 0,
  middle = 1,
  high = 2,
})
local seq9cm6u_work_state_converter = converter.from_only(converter.lookup_value({
  [0] = "presence",
  [1] = "none",
  [2] = "presence_5min",
  [3] = "presence_30min",
  [4] = "none_5min",
  [5] = "none_30min",
}))

local device_definitions, register_device_definition = device_helpers.definition_registry()

local function copy_options(options)
  local resolved = {}
  if type(options) == "table" then
    for key, value in pairs(options) do
      resolved[key] = value
    end
  end
  return resolved
end

local function presence_options(options, name, emitter)
  local resolved = copy_options(options)
  resolved.name = resolved.name or name
  resolved.emit = resolved.emit or emitter
  return resolved
end

local function options_has_custom_converter(options)
  return options.converter ~= nil or options.from_device ~= nil or options.to_device ~= nil or options.lookup ~= nil
end

local function build_presence_dp(preset_fn, name, emitter_factory, default_converter)
  return function(dp, options)
    local resolved = presence_options(options, name, emitter_factory())
    if default_converter ~= nil and not options_has_custom_converter(resolved) then
      resolved.converter = default_converter
    end
    return preset_fn(dp, resolved)
  end
end

local dp_presence_delay_cap = build_presence_dp(tuya.dp_numeric, "presence_delay", emit.presence_delay)
local dp_presence_time_cap = build_presence_dp(tuya.dp_numeric, "presence_time", emit.presence_time)

local function capability_range(minimum, maximum, step, unit)
  local range = {
    minimum = minimum,
    maximum = maximum,
    step = step,
  }

  if type(unit) == "string" and unit ~= "" then
    range.unit = unit
  end

  return range
end


local ts0601_fingerprints = ef00_helpers.ts0601_fingerprints








-- Z2M: _TZE200_f1pvdgoh (TS0601_pir)


local pir = {
  profile = "safety-motion-pir-illuminance-battery",
  datapoints = {
    tuya.dp_occupancy(1, { emit = emit.motion(), read_only = true }),
    tuya.dp_battery(4, { emit = emit.battery(), read_only = true }),
    tuya.dp_illuminance(101, { emit = emit.illuminance(), read_only = true }),
  },
  query_on_configure = false,
  respond_to_mcu_version_response = true,
}

local pir_fingerprints = ts0601_fingerprints({
  "_TZE200_f1pvdgoh",
  "_TZE200_me6wtiqs",
})
pir_fingerprints[#pir_fingerprints + 1] = {
  manufacturer = "_TZE200_f1pvdgoh",
  model = string.char(0) .. "B",
}
register_device_definition(pir, pir_fingerprints)





-- Z2M: _TZE200_ghynnvos


local pir_no_battery = {
  profile = "safety-motion-pir-illuminance",
  datapoints = {
    tuya.dp_occupancy(1, { emit = emit.motion(), read_only = true }),
    tuya.dp_illuminance(101, { emit = emit.illuminance(), read_only = true }),
  },
  query_on_configure = false,
  respond_to_mcu_version_response = true,
}

register_device_definition(pir_no_battery, ts0601_fingerprints({
  "_TZE200_ghynnvos",
}))





-- Z2M: _TZE200_3towulqd (ZG-204ZL)


local pir_model_zg_204zl = {
  profile = "safety-motion-zg204zl-keep-illuminance-battery",
  datapoints = {
    tuya.dp_occupancy(1, { emit = emit.motion(), read_only = true }),
    tuya.dp_battery(4, { emit = emit.battery(), read_only = true }),
    tuya.dp_enum(9, {
      name = "sensitivity",
      emit = emit.zg204zlSensitivity(),
      converter = zg204zl_sensitivity_converter,
    }),
    tuya.dp_enum(10, {
      name = "keep_time",
      emit = emit.zg204zlKeepTime(),
      converter = zg204zl_keep_time_converter,
    }),
    tuya.dp_illuminance(12, { emit = emit.illuminance(), read_only = true }),
    tuya.dp_numeric(102, {
      name = "illuminance_interval",
      emit = emit.zg204zlIlluminanceInterval(),
    }),
  },
  query_on_configure = false,
}

register_device_definition(pir_model_zg_204zl, ts0601_fingerprints({

  "_TZE200_3towulqd",

  "_TZE200_1ibpyhdc",

  "_TZE200_bh3n6gk8",

  "_TZE200_ttcovulf",

  "_TZE200_gjldowol",

  "_TZE200_jxyhl4eq",

  "_TZE200_qxyh4r7g",

  "_TZE200_na5qlzow",

}))





-- Z2M: _TZE200_s6hzw8g2


local pir_model_zg_204zl_illuminance_dp101 = {
  profile = "safety-motion-zg204zl-keep-illuminance-battery",
  datapoints = {
    tuya.dp_occupancy(1, { emit = emit.motion(), read_only = true }),
    tuya.dp_battery(4, { emit = emit.battery(), read_only = true }),
    tuya.dp_enum(9, {
      name = "sensitivity",
      emit = emit.zg204zlSensitivity(),
      converter = zg204zl_sensitivity_converter,
    }),
    tuya.dp_enum(10, {
      name = "keep_time",
      emit = emit.zg204zlKeepTime(),
      converter = zg204zl_keep_time_converter,
    }),
    tuya.dp_illuminance(101, { emit = emit.illuminance(), read_only = true }),
    tuya.dp_numeric(102, {
      name = "illuminance_interval",
      emit = emit.zg204zlIlluminanceInterval(),
    }),
  },
  query_on_configure = false,
}

register_device_definition(pir_model_zg_204zl_illuminance_dp101, ts0601_fingerprints({

  "_TZE200_s6hzw8g2",

}))





-- Z2M: _TZE200_ppuj1vem (ZPIR-10) / _TZE200_oc7xqqbs (HY-SZLUMPIR)


local pir_model_zpir_10_datapoints = {
  tuya.dp_occupancy(1, { emit = emit.motion(), read_only = true }),
  tuya.dp_battery(4, { emit = emit.battery(), read_only = true }),
  tuya.dp_illuminance(101, { emit = emit.illuminance(), read_only = true }),
}

register_device_definition({
  profile = "safety-motion-zpir10-illuminance-battery",
  datapoints = pir_model_zpir_10_datapoints,
  query_on_configure = false,
}, ts0601_fingerprints({
  "_TZE200_ppuj1vem",
}))

register_device_definition({
  profile = "safety-motion-zpir10-illuminance-battery",
  datapoints = pir_model_zpir_10_datapoints,
  query_on_configure = false,
  respond_to_mcu_version_response = true,
}, ts0601_fingerprints({
  "_TZE200_oc7xqqbs",
}))





-- Z2M: _TZE284_tre6haif (TS0601_pir_solar)

-- Z2M 기준 DP9은 pir_sensitivity {high=0, low=1} 2단계만 지원한다.
-- family 전용 enum capability로 그대로 노출한다.


local pir_solar = {
  profile = "safety-motion-pir-solar-battery",
  datapoints = {
    tuya.dp_occupancy(1, { emit = emit.motion(), read_only = true }),
    tuya.dp_battery(4, { emit = emit.battery(), read_only = true }),
    tuya.dp_numeric(9, {
      name = "pir_sensitivity",
      emit = emit.tre6haifPirSensitivity(),
      converter = tre6haif_sensitivity_converter,
    }),
    tuya.dp_numeric(101, {
      name = "alarm_time",
      emit = emit.tre6haifAlarmTime(),
    }),
    tuya.dp_enum(102, {
      name = "alarm_mode",
      emit = emit.tre6haifAlarmMode(),
      converter = tre6haif_alarm_mode_converter,
    }),
  },
  query_on_configure = false,
}

register_device_definition(pir_solar, ts0601_fingerprints({
  "_TZE284_tre6haif",
}))





-- Z2M: _TZE200_auin8mzr (TS0601_motion_sensor)


local pir_legacy = {
  profile = "safety-motion-legacy-illuminance",
  datapoints = {
    tuya.dp_occupancy(1, {
      emit = emit.motion(),
      converter = converter.true_false1(),
      read_only = true,
    }),
    tuya.dp_enum(101, {
      name = "v_sensitivity",
      emit = emit.auin8mzrVSensitivity(),
      converter = auin8mzr_v_sensitivity_converter,
    }),
    tuya.dp_enum(102, {
      name = "o_sensitivity",
      emit = emit.auin8mzrOSensitivity(),
      converter = auin8mzr_o_sensitivity_converter,
    }),
    tuya.dp_numeric(103, {
      name = "vacancy_delay",
      emit = emit.auin8mzrVacancyDelay(),
    }),
    tuya.dp_enum(104, {
      name = "mode",
      emit = emit.auin8mzrMode(),
      converter = auin8mzr_mode_converter,
    }),
    tuya.dp_numeric(105, {
      name = "vacant_confirm_time",
      emit = emit.auin8mzrVacantConfirmTime(),
      read_only = true,
    }),
    tuya.dp_numeric(106, {
      name = "reference_luminance",
      emit = emit.auin8mzrReferenceLuminance(),
      read_only = true,
    }),
    tuya.dp_numeric(107, {
      name = "light_on_luminance_prefer",
      emit = emit.auin8mzrLightOnLuminance(),
    }),
    tuya.dp_numeric(108, {
      name = "light_off_luminance_prefer",
      emit = emit.auin8mzrLightOffLuminance(),
    }),
    tuya.dp_numeric(109, {
      name = "luminance_level",
      emit = emit.auin8mzrLuminanceLevel(),
      read_only = true,
    }),
    tuya.dp_enum(110, {
      name = "led_status",
      emit = emit.auin8mzrLedStatus(),
      converter = auin8mzr_led_status_converter,
    }),
  },
  magic_packet = false,
  query_on_configure = false,
}

register_device_definition(pir_legacy, ts0601_fingerprints({

  "_TZE200_auin8mzr",

}))





-- Z2M: _TZE200_seq9cm6u (TS0601_bed_presence_sensor)


local pir_bed = {
  profile = "safety-motion-bed-time-illuminance-battery",
  datapoints = {
    tuya.dp_occupancy(1, { emit = emit.motion(), read_only = true }),
    tuya.dp_battery(4, { emit = emit.battery(), read_only = true }),
    tuya.dp_enum(9, {
      name = "sensitivity",
      emit = emit.seq9cm6uSensitivity(),
      converter = seq9cm6u_sensitivity_converter,
    }),
    tuya.dp_illuminance(12, { emit = emit.illuminance(), read_only = true }),
    tuya.dp_numeric(101, {
      name = "interval_time",
      emit = emit.seq9cm6uIntervalTime(),
    }),
    dp_presence_delay_cap(102),
    dp_presence_time_cap(103),
    tuya.dp_enum(104, {
      name = "work_state",
      emit = emit.seq9cm6uWorkState(),
      converter = seq9cm6u_work_state_converter,
      read_only = true,
    }),
  },
  presence_capability_ranges = {
    presence_delay = capability_range(0, 3600, 1, "s"),
    presence_time = capability_range(0, 3600, 1, "s"),
  },
  query_on_configure = false,
}

register_device_definition(pir_bed, ts0601_fingerprints({

  "_TZE200_seq9cm6u",

}))




return {
  id = "ef00.motion.pir",
  registrations = device_definitions,
}
