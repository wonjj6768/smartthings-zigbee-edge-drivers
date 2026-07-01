local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local device_definitions, register_device_definition = device_helpers.definition_registry()
local cover = {
profile = "covers-cover",
zcl_clusters = {
zcl.cover_position(),
zcl.window_shade_state(),
zcl.cover_state(),
},
}
local cover_battery = {
profile = "covers-cover-battery",
zcl_clusters = {
zcl.cover_position(),
zcl.window_shade_state(),
zcl.cover_state(),
zcl.battery(),
},
}
register_device_definition(cover, {
device_helpers.create_fingerprint("BSEED", "EC-GL86ZPCRS31"),
device_helpers.create_fingerprint("Danor", "SK-Z802C-US"),
device_helpers.create_fingerprint("Girier", "ME168_Girier"),
device_helpers.create_fingerprint("Zemismart", "ZN-LC1E"),
device_helpers.create_fingerprint("Girier", "TS130F_GIRIER"),
device_helpers.create_fingerprint("Girier", "TS130F_GIRIER_DUAL"),
device_helpers.create_fingerprint("Zemismart", "TS130F_ZEMISMART"),
device_helpers.create_fingerprint("Zemismart", "ZM25R3"),
device_helpers.create_fingerprint("QA", "QACZ1"),
})
register_device_definition(cover, {
device_helpers.create_fingerprint("eWeLink", "AM25C-1-25-ES-E-Z"),
device_helpers.create_fingerprint("eWeLink", "CK-MG22-Z310EE07DOOYA-01(7015)"),
device_helpers.create_fingerprint("eWeLink", "MYDY25Z-1"),
device_helpers.create_fingerprint("eWeLink", "ZM25-EAZ"),
})
register_device_definition(cover, {
device_helpers.create_fingerprint("Moes", "ZTS-EUB1"),
device_helpers.create_fingerprint("Sunricher", "SR-ZG9080A"),
device_helpers.create_fingerprint("Tuya", "GM35TEQ-TYZ-2/25"),
})
register_device_definition(cover, {
device_helpers.create_fingerprint("Sunricher", "HK-ZCC-A"),
})
register_device_definition(cover, {
device_helpers.create_fingerprint("Third Reality, Inc", "TRZB3"),
})
register_device_definition(cover_battery, {
device_helpers.create_fingerprint("Third Reality, Inc", "3RSB015BZ"),
device_helpers.create_fingerprint("Third Reality, Inc", "3RSB02015Z"),
})
return device_definitions
