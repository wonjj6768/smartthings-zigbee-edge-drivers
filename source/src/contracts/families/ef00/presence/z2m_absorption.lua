local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local common = require "contracts.helpers.ef00_presence"

local converter = tuya.converter
local device_definitions, register_device_definition = common.isolated_definition_registry(device_helpers.definition_registry)
local function register_presence_definition(definition, fingerprint_list)
  return common.register_presence_definition(
    register_device_definition, definition, fingerprint_list
  )
end
local ts0601_fingerprints = common.ts0601_fingerprints

-- Z2M v26.99.0: ZF24Pro presence/temp/humidity sensor.
local presence_model_zf24pro = {
  profile = "safety-presence-zf24pro-temp-humidity",
  package_group = "presence-general-2",
  datapoints = {
    tuya.dp_presence(1, {
      emit = emit.presence(),
      converter = converter.true_false1(),
      read_only = true,
    }),
    tuya.dp_numeric(2, {
      name = "move_sensitivity",
      emit = emit.zf24ProMoveSensitivity(),
    }),
    tuya.dp_static_detection_distance(4, {
      name = "detection_distance_max",
      emit = emit.zf24ProDetectionDistanceMax(),
    }),
    tuya.dp_target_distance(9, {
      name = "distance",
      emit = emit.zf24ProDistance(),
      read_only = true,
    }),
    tuya.dp_temperature(22, {
      emit = emit.temperature("C"),
      converter = converter.signed_number_pair(10),
      signed = true,
      read_only = true,
    }),
    tuya.dp_humidity(23, {
      emit = emit.humidity(),
      scale = 1,
      read_only = true,
    }),
    tuya.dp_numeric(101, {
      name = "presence_timeout",
      emit = emit.zf24ProPresenceTimeout(),
    }),
    tuya.dp_illuminance(102, { emit = emit.illuminance(), read_only = true }),
    tuya.dp_numeric(103, {
      name = "presence_sensitivity",
      emit = emit.zf24ProPresenceSensitivity(),
    }),
    tuya.dp_on_off(104, { name = "switch", component = "radarFunction" }),
    tuya.dp_on_off(105, { name = "switch", component = "livingRoom" }),
    tuya.dp_on_off(106, { name = "switch", component = "bedroom" }),
    tuya.dp_on_off(107, { name = "switch", component = "bathroom" }),
    tuya.dp_on_off(108, { name = "switch", component = "sleep" }),
    tuya.dp_on_off(109, { name = "switch", component = "radarSwitch" }),
    tuya.dp_temperature_calibration(110, {
      name = "temperature_correction",
      scale = 10,
      emit = emit.zf24ProTemperatureCorrection(),
    }),
    tuya.dp_humidity_calibration(111, {
      name = "humidity_correction",
      scale = 1,
      emit = emit.zf24ProHumidityCorrection(),
    }),
  },
  query_on_configure = false,
  time_start = "off",
}

register_presence_definition(presence_model_zf24pro, ts0601_fingerprints({
  "_TZE28C1000000_vosmoqsg",
  "_TZE28C1000000_ewn672ef",
}))

-- Z2M v26.99.0: Lincukoo SZLMR10 PIR/radar presence sensor.
local presence_model_szlmr10 = {
  profile = "safety-presence-szlmr10-illuminance",
  package_group = "presence-general-2",
  datapoints = {
    tuya.dp_presence(1, {
      emit = emit.presence(),
      converter = converter.true_false0(),
      read_only = true,
    }),
    tuya.dp_illuminance(20, { emit = emit.illuminance(), read_only = true }),
    tuya.dp_numeric(13, {
      name = "detection_distance",
      converter = converter.divide_by_pair(100),
      emit = emit.szlmr10DetectionDistance(),
    }),
    tuya.dp_numeric(16, {
      name = "radar_sensitivity",
      emit = emit.szlmr10RadarSensitivity(),
    }),
    tuya.dp_numeric(103, {
      name = "fading_time",
      emit = emit.szlmr10FadingTime(),
    }),
    tuya.dp_on_off(101, { name = "switch", component = "indicator" }),
    tuya.dp_on_off(102, { name = "switch", component = "radarSwitch" }),
    tuya.dp_enum(104, {
      name = "work_mode",
      emit = emit.szlmr10WorkMode(),
      converter = converter.lookup_from_to({
        pir_mode = 0,
        radar_mode = 1,
        combine_mode = 2,
      }),
    }),
  },
  query_on_configure = false,
  time_start = "off",
}

register_presence_definition(presence_model_szlmr10, ts0601_fingerprints({
  "_TZE204_sndkanfr",
  "_TZE204_bjf8qum1",
  "_TZE284_sndkanfr",
  "_TZE28C1000000_sndkanfr",
  "_TZE28C1000000_bjf8qum1",
}))

local ctl_mini = {
  profile = "safety-presence-ctl-mini",
  package_group = "presence-general-2",
  magic_packet = true,
  mcu_version_request_on_configure = true,
  query_on_configure = false,
  query_on_announce = false,
  time_start = "off",
  datapoints = {
    tuya.dp_presence(1, {converter=converter.true_false1(),emit=emit.presence(),read_only=true}),
    tuya.dp_illuminance(101, {emit=emit.illuminance(),read_only=true}),
    tuya.dp_numeric(102, {name="ctl_mini_illuminance_high",emit=emit.ctlMiniIlluminanceHigh()}),
    tuya.dp_numeric(103, {name="ctl_mini_illuminance_low",emit=emit.ctlMiniIlluminanceLow()}),
    tuya.dp_numeric(104, {name="ctl_mini_presence_timeout",emit=emit.ctlMiniPresenceTimeout()}),
    tuya.dp_on_off(105, {name="switch"}),
    tuya.dp_enum(106, {name="ctl_mini_light_linkage",emit=emit.ctlMiniLightLinkage(),converter=converter.lookup_from_to({ON=0,OFF=1})}),
    tuya.dp_enum(107, {name="ctl_mini_illuminance_linkage",emit=emit.ctlMiniIlluminanceLinkage(),converter=converter.lookup_from_to({ON=0,OFF=1})}),
    tuya.dp_enum(108, {name="ctl_mini_breathing_indicator",emit=emit.ctlMiniBreathingIndicator(),converter=converter.lookup_from_to({ON=0,OFF=1})}),
    tuya.dp_enum(109, {name="ctl_mini_detection_method",emit=emit.ctlMiniDetectionMethod(),converter=converter.lookup_from_to({presence=0,motion=1})}),
    tuya.dp_enum(110, {name="ctl_mini_sensitivity",emit=emit.ctlMiniSensitivity(),converter=converter.lookup_from_to({LL=0,L=1,M=2,H=3,HH=4})}),
    tuya.dp_enum(111, {
      name="ctl_mini_program_function",read_only=true,emit=emit.ctlMiniProgramFunction(),
      converter=converter.lookup_from_to({
        null=0,no_one_1min=1,no_one_3min=2,no_one_5min=3,no_one_10min=4,
        no_one_15min=5,no_one_30min=6,no_one_1hour=7,no_one_2hour=8,no_one_4hour=9,
        no_one_8hour=10,no_one_12hour=11,no_one_24hour=12,presence_1min=13,
        presence_3min=14,presence_5min=15,presence_10min=16,presence_15min=17,
        presence_30min=18,presence_1hour=19,presence_2hour=20,presence_4hour=21,
        presence_8hour=22,presence_12hour=23,presence_24hour=24,
      }),
    }),
    tuya.dp_enum(112, {name="ctl_mini_installation_mode",emit=emit.ctlMiniInstallationMode(),converter=converter.lookup_from_to({ceiling=0,wall=1})}),
    tuya.dp_numeric(113, {name="ctl_mini_installation_height",emit=emit.ctlMiniInstallationHeight(),converter=converter.divide_by_pair(10)}),
    tuya.dp_numeric(114, {name="ctl_mini_detection_radius",emit=emit.ctlMiniDetectionRadius(),converter=converter.divide_by_pair(10)}),
    tuya.dp_enum(115, {name="ctl_mini_environment_learning",emit=emit.ctlMiniEnvironmentLearning(),converter=converter.lookup_from_to({none=0,light=1,medium=2,deep=3,disable=4})}),
    tuya.dp_enum(116, {
      name="ctl_mini_manual_annotation",emit=emit.ctlMiniManualAnnotation(),
      converter=converter.lookup_from_to({null=0,no_one_last_1h=1,no_one_last_2h=2,no_one_last_4h=3,no_one_last_8h=4,no_one_last_12h=5,no_one_last_24h=6}),
    }),
    tuya.dp_enum(117, {
      name="ctl_mini_sensor_power",emit=emit.ctlMiniSensorPower(),
      converter=converter.lookup_from_to({on=0,off=1,off_10s_restart=2,off_30s_restart=3,off_60s_restart=4,
        pause_upload=5,pause_upload_10s=6,pause_upload_30s=7,pause_upload_60s=8,pause_upload_3min=9,
        pause_upload_5min=10,pause_upload_10min=11,pause_upload_15min=12,pause_upload_30min=13,pause_upload_1hour=14}),
    }),
    tuya.dp_enum(118, {
      name="ctl_mini_system_setting",emit=emit.ctlMiniSystemSetting(),
      converter=converter.lookup_from_to({none=0,identify_start=1,identify_stop=2,check_start=3,check_stop=4,restore_factory=5,state_flip_report=6}),
    }),
    tuya.dp_string(119, {
      name="ctl_mini_system_info",read_only=true,emit=emit.ctlMiniSystemInfo(),
      from_device=function(value) return value:gsub("%z", ""):match("^%s*(.-)%s*$") end,
    }),
    tuya.dp_numeric(120, {name="ctl_mini_detection_range",emit=emit.ctlMiniDetectionRange(),converter=converter.divide_by_pair(10)}),
  },
}
register_presence_definition(ctl_mini, ts0601_fingerprints({"_TZE284_5qfrnbqs"}))

local hs208z = {
  profile = "safety-presence-hs208z",
  magic_packet = true,
  mcu_version_request_on_configure = false,
  query_on_configure = false,
  query_on_announce = false,
  initial_custom_state_query = false,
  refresh_state_query = false,
  time_start = "off",
  datapoints = {
    tuya.dp_enum(1, {name="presence",read_only=true,receive_datatypes={4,2},emit=emit.presence(),converter=converter.true_false0()}),
    tuya.dp_numeric(3, {name="hs208z_battery_state",read_only=true,receive_datatypes={2,4},emit=emit.hs208zBatteryState(),converter=converter.lookup_from_to({low=0,middle=1,high=2})}),
    tuya.dp_battery(4, {read_only=true,emit=emit.battery()}),
    tuya.dp_numeric(9, {name="hs208z_pir_sensitivity",receive_datatypes={2,4},emit=emit.hs208zPirSensitivity(),converter=converter.lookup_from_to({low=0,middle=1,high=2})}),
    tuya.dp_illuminance(11, {read_only=true,emit=emit.illuminance()}),
    tuya.dp_numeric(12, {name="hs208z_pir_delay",emit=emit.hs208zPirDelay()}),
    tuya.dp_numeric(101, {name="hs208z_light_sensor_time",emit=emit.hs208zLightSensorTime()}),
    tuya.dp_binary(102, {name="vibration",read_only=true,receive_datatypes={1,2},emit=emit.acceleration(),converter=converter.from_only(function(value) return value==true or value==1 end)}),
    tuya.dp_numeric(103, {name="hs208z_detection_distance",emit=emit.hs208zDetectionDistance()}),
    tuya.dp_numeric(104, {name="hs208z_static_sensitivity",emit=emit.hs208zStaticSensitivity()}),
    tuya.dp_numeric(105, {name="hs208z_motion_state",read_only=true,receive_datatypes={2,4},emit=emit.hs208zMotionState(),converter=converter.lookup_from_to({none=0,move=1,["Micro-move"]=2,static=3})}),
    tuya.dp_numeric(106, {name="hs208z_temperature_calibration",signed=true,emit=emit.hs208zTemperatureCalibration(),converter=converter.signed_number_pair(10)}),
    tuya.dp_binary(107, {name="hs208z_indicator",emit=emit.hs208zIndicator(),converter=converter.lookup_from_to({ON=true,OFF=false})}),
    tuya.dp_numeric(108, {name="hs208z_humidity_calibration",signed=true,emit=emit.hs208zHumidityCalibration(),converter=converter.signed_number_pair(1)}),
    tuya.dp_enum(109, {name="hs208z_temperature_unit",emit=emit.hs208zTemperatureUnit(),converter=converter.lookup_from_to({celsius=0,fahrenheit=1})}),
    tuya.dp_temperature(110, {read_only=true,emit=emit.temperature(),converter=converter.signed_number_pair(10)}),
    tuya.dp_numeric(111, {name="humidity",read_only=true,emit=emit.humidity()}),
    tuya.dp_numeric(112, {name="hs208z_vibration_sensitivity",emit=emit.hs208zVibrationSensitivity()}),
    tuya.dp_numeric(113, {name="hs208z_vibration_delay",emit=emit.hs208zVibrationDelay()}),
    tuya.dp_enum(122, {name="hs208z_motion_detection_mode",emit=emit.hs208zMotionDetectionMode(),converter=converter.lookup_from_to({pir_and_radar=0,pir_or_radar=1,only_radar=2})}),
    tuya.dp_numeric(123, {name="hs208z_detection_sensitivity",emit=emit.hs208zDetectionSensitivity()}),
  },
}
register_presence_definition(hs208z, {
  device_helpers.create_fingerprint("_TZD200_sjjp9bti", "TS0202"),
})

return {
  id = "ef00.presence.z2m_absorption",
  registrations = device_definitions,
}
