-- Frozen Z2M v26.99 Wave11 presence families assigned to general package 2.

local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local common = require "contracts.helpers.ef00_presence"

local converter = tuya.converter
local registrations, register_device_definition = common.isolated_definition_registry(device_helpers)
local on_off_converter = converter.lookup_from_to({ ON = true, OFF = false })

local function register(definition, manufacturer)
  register_device_definition(definition, {
    device_helpers.create_fingerprint(manufacturer, "TS0601"),
  })
end

-- Lincukoo R12LM-Z10T, lincukoo.ts:449.
local r_twelve_z_ten = {
  profile = "safety-presence-wave11-r12lm-z10t",
  package_group = "z2m-ef00-presence",
  named_datapoints = true,
  datapoints = {
    tuya.dp_presence(1, {
      converter = converter.true_false0(), emit = emit.presence(), read_only = true,
    }),
    tuya.dp_illuminance(101, { emit = emit.illuminance(), read_only = true }),
    tuya.dp_enum(102, {
      name = "r_twelve_z_ten_work_mode",
      converter = converter.lookup_from_to({ radar_mode = 0, combine_mode = 1 }),
      emit = emit.rTwelveZTenWorkMode(),
    }),
    tuya.dp_binary(103, {
      name = "r_twelve_z_ten_radar_switch", converter = on_off_converter,
      emit = emit.rTwelveZTenRadarSwitch(),
    }),
    tuya.dp_numeric(104, {
      name = "r_twelve_z_ten_fading_time", emit = emit.rTwelveZTenFadingTime(),
    }),
    tuya.dp_numeric(106, {
      name = "r_twelve_z_ten_detection_distance",
      converter = converter.divide_by_pair(100),
      emit = emit.rTwelveZTenDetectionDistance(),
    }),
    tuya.dp_numeric(107, {
      name = "r_twelve_z_ten_radar_sensitivity",
      emit = emit.rTwelveZTenRadarSensitivity(),
    }),
    tuya.dp_enum(108, {
      name = "r_twelve_z_ten_battery_state",
      converter = converter.from_only(converter.lookup_value({
        [0] = "low", [1] = "middle", [2] = "high", [3] = "usb",
      })),
      emit = emit.rTwelveZTenBatteryState(),
      read_only = true,
    }),
  },
  query_on_configure = false,
}

register(r_twelve_z_ten, "_TZE284_hqys6frs")

-- Lincukoo R12LM-Z11T, lincukoo.ts:793.
local r_twelve_z_eleven = {
  profile = "safety-presence-wave11-r12lm-z11t",
  package_group = "z2m-ef00-presence",
  named_datapoints = true,
  datapoints = {
    tuya.dp_presence(1, {
      converter = converter.true_false0(), emit = emit.presence(), read_only = true,
    }),
    tuya.dp_enum(8, {
      name = "r_twelve_z_eleven_scan_result",
      converter = converter.from_only(converter.lookup_value({
        [0] = "normal",
        [1] = "scanning",
        [2] = "scan_success",
        [3] = "scan_failure",
        [4] = "scan_start",
      })),
      emit = emit.rTwelveZElevenScanResult(),
      read_only = true,
    }),
    tuya.dp_illuminance(101, { emit = emit.illuminance(), read_only = true }),
    tuya.dp_enum(102, {
      name = "r_twelve_z_eleven_mode",
      converter = converter.lookup_from_to({ radar_mode = 0, fusion_mode = 1 }),
      emit = emit.rTwelveZElevenMode(),
    }),
    tuya.dp_binary(103, {
      name = "r_twelve_z_eleven_radar_switch", converter = on_off_converter,
      emit = emit.rTwelveZElevenRadarSwitch(),
    }),
    tuya.dp_enum(105, {
      name = "r_twelve_z_eleven_scan_environment",
      converter = converter.lookup_from_to({ start = 0 }),
      emit = emit.rTwelveZElevenScanEnvironment(),
    }),
    tuya.dp_numeric(106, {
      name = "r_twelve_z_eleven_detection_distance",
      converter = converter.divide_by_pair(100),
      emit = emit.rTwelveZElevenDetectionDistance(),
    }),
    tuya.dp_enum(108, {
      name = "r_twelve_z_eleven_battery_state",
      converter = converter.from_only(converter.lookup_value({
        [0] = "low", [1] = "middle", [2] = "high", [3] = "USB",
      })),
      emit = emit.rTwelveZElevenBatteryState(),
      read_only = true,
    }),
    tuya.dp_binary(109, {
      name = "r_twelve_z_eleven_switch_night_light",
      converter = on_off_converter,
      emit = emit.rTwelveZElevenNightLight(),
    }),
  },
  query_on_configure = false,
}

register(r_twelve_z_eleven, "_TZE284_zzm83zpz")

return {
  id = "ef00.presence.wave11.general.2",
  registrations = registrations,
}
