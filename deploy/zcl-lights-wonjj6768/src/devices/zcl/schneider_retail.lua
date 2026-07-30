local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local device_definitions, register_device_definition = device_helpers.definition_registry()
local dimmer_light = {
profile = "lights-dimmer",
zcl_clusters = {
zcl.switch(),
zcl.level(),
},
}
register_device_definition(dimmer_light, {
device_helpers.create_fingerprint("Legrand", "Dimmer switch with neutral"),
})
return device_definitions
