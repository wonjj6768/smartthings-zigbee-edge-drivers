local device_helpers = require "devices.shared.helpers"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local dimming_remote = {
  profile = "controllers-dimming-remote-action",
  advanced_remote = true,
  unprefixed_remote_actions = true,
  tuya_action_name = "switch_scene",
  zcl_clusters = {},
}

register_device_definition(dimming_remote, device_helpers.create_fingerprints("TS1001", {
  "_TYZB01_bngwdjsr",
  "_TYZB01_hww2py6b",
  "_TZ3000_ztrfrcsu",
}))

register_device_definition(dimming_remote, {
  device_helpers.create_fingerprint("Candeo", "C-ZB-RD1P-REM"),
  device_helpers.create_fingerprint("HEIMAN", "ColorDimmerSw-EM-3.0"),
  device_helpers.create_fingerprint("RGB Genie", "ZGRC-KEY-013"),
  device_helpers.create_fingerprint("Sunricher", "SR-ZG2833PAC"),
  device_helpers.create_fingerprint("Sunricher", "SR-ZG9001K12-DIM-Z4"),
  device_helpers.create_fingerprint("Sunricher", "SR-ZG9001K2-DIM"),
  device_helpers.create_fingerprint("Sunricher", "SR-ZG9001K2-DIM2"),
  device_helpers.create_fingerprint("Sunricher", "SR-ZG9001K4-DIM2"),
  device_helpers.create_fingerprint("Sunricher", "SR-ZG9001K8-DIM"),
  device_helpers.create_fingerprint("Sunricher", "SR-ZG9001NK8-DIM"),
  device_helpers.create_fingerprint("Sunricher", "SR-ZG9023A(EU)"),
})

return device_definitions
