local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local zcl_device_helpers = require "devices.zcl.helpers"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local metered_plug = {
  profile = "plugs-switch-power-energy-voltage-current",
  zcl_clusters = zcl_device_helpers.metering_clusters({
    include_switch = true,
    include_current = true,
  }),
}

local dimmer_light = {
  profile = "lights-dimmer-power-voltage-current",
  zcl_clusters = {
    zcl.switch(),
    zcl.level(),
    zcl.power(),
    zcl.voltage(),
    zcl.current(),
  },
}

local water_sensor = {
  profile = "safety-water-leak-battery",
  zcl_clusters = {
    zcl.water(),
    zcl.battery(),
  },
}

local temp_humidity = {
  profile = "sensors-temp-humidity-battery",
  zcl_clusters = {
    zcl.temperature(),
    zcl.humidity(),
    zcl.battery(),
  },
}

local contact_illuminance = {
  profile = "safety-contact-illuminance-battery",
  zcl_clusters = { zcl.contact(), zcl.illuminance(), zcl.battery() },
}

local motion_illuminance = {
  profile = "safety-motion-illuminance-battery",
  zcl_clusters = { zcl.motion(), zcl.illuminance(), zcl.battery() },
}

register_device_definition(metered_plug, {
  device_helpers.create_fingerprint("Shelly", "Plug US"),
  device_helpers.create_fingerprint("Shelly", "Power Strip"),
})

register_device_definition(dimmer_light, {
  device_helpers.create_fingerprint("Shelly", "Dimmer"),
  device_helpers.create_fingerprint("Shelly", "Dimmer US"),
})

register_device_definition(water_sensor, {
  device_helpers.create_fingerprint("Shelly", "Flood"),
})

register_device_definition(temp_humidity, {
  device_helpers.create_fingerprint("Shelly", "BLU H&T Display ZB"),
  device_helpers.create_fingerprint("Shelly", "BLU H&T ZB"),
  device_helpers.create_fingerprint("Shelly", "Ecowitt WS90"),
})

register_device_definition(contact_illuminance, {
  device_helpers.create_fingerprint("Shelly", "BLU DoorWindow ZB"),
})

register_device_definition(motion_illuminance, {
  device_helpers.create_fingerprint("Shelly", "BLU Motion ZB"),
})

return device_definitions
