local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local emit = require "emitters"
local device_definitions, register_device_definition = device_helpers.definition_registry()
local function battery_percent_from_voltage(voltage)
if type(voltage) ~= "number" then
return voltage
end
local percent = math.floor((((voltage - 2.0) / 1.0) * 100) + 0.5)
if percent < 0 then
return 0
end
if percent > 100 then
return 100
end
return percent
end
local function remote_battery_cluster()
return zcl.cluster_attribute(zcl.CLUSTER_POWER_CONFIGURATION, zcl.ATTR_BATTERY_VOLTAGE, {
name = "battery",
endpoint = 1,
emit = emit.battery(),
scale = 10,
from_device = battery_percent_from_voltage,
read_on_configure = true,
})
end
local function build_security_remote(profile)
return {
profile = profile,
security_remote = true,
button_actions = { "pushed" },
zcl_clusters = {
remote_battery_cluster(),
},
}
end
local sos_remote = build_security_remote("security-remotes-sos-battery")
local action_remote = build_security_remote("security-remotes-action-battery")
register_device_definition(sos_remote, device_helpers.create_fingerprints("TS0215A_sos", {
"_TZ3000_4fsgukof",
"_TZ3000_4fsgukof:TS0215A",
"_TZ3000_wr2ucaj9",
"_TZ3000_wr2ucaj9:TS0215A",
"_TZ3000_zsh6uat3",
"_TZ3000_zsh6uat3:TS0215A",
"_TZ3000_tj4pwzzm",
"_TZ3000_tj4pwzzm:TS0215A",
"_TZ3000_2izubafb",
"_TZ3000_2izubafb:TS0215A",
"_TZ3000_pkfazisv",
"_TZ3000_pkfazisv:TS0215A",
"_TZ3000_0dumfk2z",
"_TZ3000_0dumfk2z:TS0215A",
"_TZ3000_ssp0maqm",
"_TZ3000_ssp0maqm:TS0215A",
"_TZ3000_p3fph1go",
"_TZ3000_p3fph1go:TS0215A",
"_TZ3000_9r5jaajv",
"_TZ3000_9r5jaajv:TS0215A",
"_TZ3000_nxdziqzc",
"_TZ3000_nxdziqzc:TS0215A",
"_TZ3000_irwuzilv",
"_TZ3000_irwuzilv:TS0215A",
}))
register_device_definition(sos_remote, {
device_helpers.create_fingerprint("Tuya", "BT400B"),
device_helpers.create_fingerprint("Woox", "R7052"),
device_helpers.create_fingerprint("Nedis", "ZBPB10BK"),
})
register_device_definition(sos_remote, {
device_helpers.create_fingerprint("HEIMAN", "SOS-EF-3.0"),
device_helpers.create_fingerprint("HEIMAN", "SOS-EM"),
})
register_device_definition(action_remote, device_helpers.create_fingerprints("TS0215A_remote", {
"_TZ3000_p6ju8myv",
"_TZ3000_p6ju8myv:TS0215A",
"_TZ3000_0zrccfgx",
"_TZ3000_0zrccfgx:TS0215A",
"_TZ3000_fsiepnrh",
"_TZ3000_fsiepnrh:TS0215A",
"_TZ3000_ug1vtuzn",
"_TZ3000_ug1vtuzn:TS0215A",
"_TZ3000_eo3dttwe",
"_TZ3000_eo3dttwe:TS0215A",
"_TZ3000_jwcixnrz",
"_TZ3000_jwcixnrz:TS0215A",
"_TZ3000_u2bbagu4",
"_TZ3000_u2bbagu4:TS0215A",
"_TZ3000_8utxxtzr",
"_TZ3000_8utxxtzr:TS0215A",
}))
register_device_definition(action_remote, {
device_helpers.create_fingerprint("HEIMAN", "RC-EF-3.0"),
device_helpers.create_fingerprint("HEIMAN", "RC-EM"),
device_helpers.create_fingerprint("HEIMAN", "RC-N"),
device_helpers.create_fingerprint("Woox", "R7054"),
device_helpers.create_fingerprint("Nedis", "ZBRC10WT"),
})
return device_definitions
