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
device_helpers.create_fingerprint("ELKO", "EKO06984"),
device_helpers.create_fingerprint("ELKO", "EKO06985"),
device_helpers.create_fingerprint("ELKO", "EKO06986"),
device_helpers.create_fingerprint("Elko", "EKO06988"),
device_helpers.create_fingerprint("Elko", "EKO06989"),
device_helpers.create_fingerprint("Elko", "EKO06990"),
device_helpers.create_fingerprint("Elko", "EKO06991"),
device_helpers.create_fingerprint("Elko", "EKO07090"),
device_helpers.create_fingerprint("Elko", "EKO07117"),
device_helpers.create_fingerprint("Elko", "EKO07144"),
device_helpers.create_fingerprint("Elko", "EKO07278"),
device_helpers.create_fingerprint("Elko", "EKO07279"),
device_helpers.create_fingerprint("Elko", "EKO07280"),
device_helpers.create_fingerprint("Elko", "EKO07281"),
device_helpers.create_fingerprint("Exxact", "WDE002962"),
device_helpers.create_fingerprint("Exxact", "WDE003962"),
device_helpers.create_fingerprint("Jung", "ZLLA5004M"),
device_helpers.create_fingerprint("Jung", "ZLLCD5004M"),
device_helpers.create_fingerprint("Jung", "ZLLLS5004M"),
device_helpers.create_fingerprint("Legrand", "Dimmer switch with neutral"),
device_helpers.create_fingerprint("Schneider", "WDE002961"),
device_helpers.create_fingerprint("Schneider", "WDE003961"),
device_helpers.create_fingerprint("Schneider", "WDE004961"),
})
return device_definitions
