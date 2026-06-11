local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local single_color_controller = {
  profile = "lights-dimmer",
  zcl_clusters = {
    zcl.switch(),
    zcl.level(),
  },
}

local dual_white_controller = {
  profile = "lights-color-temperature",
  zcl_clusters = {
    zcl.switch(),
    zcl.level(),
    zcl.color_temperature(),
  },
}

local rgb_controller = {
  profile = "lights-color",
  zcl_clusters = {
    zcl.switch(),
    zcl.level(),
    zcl.color_hue(),
    zcl.color_saturation(),
    zcl.color(),
  },
}

local rgb_cct_controller = {
  profile = "lights-color-temperature-color",
  zcl_clusters = {
    zcl.switch(),
    zcl.level(),
    zcl.color_temperature(),
    zcl.color_hue(),
    zcl.color_saturation(),
    zcl.color(),
  },
}

register_device_definition(single_color_controller, {
  device_helpers.create_fingerprint("MiBoxer", "FUT036Z"),
})

register_device_definition(dual_white_controller, {
  device_helpers.create_fingerprint("MiBoxer", "FUT035Z+"),
  device_helpers.create_fingerprint("MiBoxer", "E2-ZR"),
  device_helpers.create_fingerprint("MiBoxer", "PZ2"),
})

register_device_definition(rgb_controller, {
  device_helpers.create_fingerprint("_TZ3210_778drfdt", "TS0503B"),
  device_helpers.create_fingerprint("BTF-Lighting", "C03Z"),
  device_helpers.create_fingerprint("MiBoxer", "FUT037Z"),
})

register_device_definition(rgb_cct_controller, {
  device_helpers.create_fingerprint("MiBoxer", "E3-ZR"),
  device_helpers.create_fingerprint("MiBoxer", "SZ5"),
  device_helpers.create_fingerprint("MiBoxer", "FUT037Z+"),
  device_helpers.create_fingerprint("MiBoxer", "FUT039Z"),
  device_helpers.create_fingerprint("MiBoxer", "FUT066Z"),
  device_helpers.create_fingerprint("MiBoxer", "FUT068ZR"),
  device_helpers.create_fingerprint("MiBoxer", "FUT103ZR"),
  device_helpers.create_fingerprint("MiBoxer", "FUT105ZR"),
  device_helpers.create_fingerprint("MiBoxer", "FUT106ZR"),
  device_helpers.create_fingerprint("MiBoxer", "FUTC11ZR"),
})

return device_definitions
