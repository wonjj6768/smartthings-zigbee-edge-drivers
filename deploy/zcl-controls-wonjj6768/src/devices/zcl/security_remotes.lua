local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local emit = require "emitters"
local device_management = require "st.zigbee.device_management"
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
local function remote_battery_voltage_cluster()
return zcl.cluster_attribute(zcl.CLUSTER_POWER_CONFIGURATION, zcl.ATTR_BATTERY_VOLTAGE, {
name = "battery",
endpoint = 1,
emit = emit.battery(),
scale = 10,
from_device = battery_percent_from_voltage,
read_on_configure = true,
})
end
local function bind_clusters(cluster_ids)
return function(driver, device)
for _, cluster_id in ipairs(cluster_ids) do
device:send(device_management.build_bind_request(
device,
cluster_id,
driver.environment_info.hub_zigbee_eui,
1
))
end
end
end
local function build_security_remote(profile, options)
local mappings = {
zcl.battery({ endpoint = 1, read_on_configure = true }),
}
if options and options.battery_voltage then
mappings[#mappings + 1] = remote_battery_voltage_cluster()
end
return {
profile = profile,
security_remote = true,
button_actions = { "pushed" },
zcl_clusters = mappings,
configure = bind_clusters(options and options.bind_clusters or { zcl.CLUSTER_POWER_CONFIGURATION }),
}
end
local tuya_bind_clusters = {
zcl.CLUSTER_POWER_CONFIGURATION,
0x000A,
0x0000,
0x0501,
zcl.CLUSTER_IAS_ZONE,
}
local sos_remote = build_security_remote("security-remotes-sos-battery", {
battery_voltage = true,
bind_clusters = tuya_bind_clusters,
})
local sos_voltage_mapping = zcl.cluster_attribute(zcl.CLUSTER_POWER_CONFIGURATION, zcl.ATTR_BATTERY_VOLTAGE, {
name = "battery_voltage",
endpoint = 1,
emit = emit.voltage(),
scale = 10,
})
sos_remote.profile = "security-remotes-sos-battery-voltage"
sos_remote.zcl_clusters[#sos_remote.zcl_clusters + 1] = sos_voltage_mapping
local action_remote = build_security_remote("security-remotes-action-battery", {
battery_voltage = true,
bind_clusters = tuya_bind_clusters,
})
local heiman_sos_remote = {
profile = "buttons-button-1-battery-remote-action",
advanced_remote = true,
button_actions = { "pushed", "double", "held" },
ias_zone_action_map = {
[0] = "off",
[1] = "single",
[2] = "double",
[3] = "hold",
},
standard_action_button_events = {
single = "pushed",
double = "double",
hold = "held",
},
zcl_clusters = {
zcl.battery({ endpoint = 1, read_on_configure = true }),
},
configure = bind_clusters({ zcl.CLUSTER_POWER_CONFIGURATION }),
}
local heiman_action_remote = build_security_remote("security-remotes-action-battery", {
bind_clusters = { zcl.CLUSTER_POWER_CONFIGURATION },
})
local heiman_partial_action_remote = build_security_remote("security-remotes-heiman-partial-action-battery", {
bind_clusters = { zcl.CLUSTER_POWER_CONFIGURATION },
})
heiman_partial_action_remote.security_remote_action_emit_name = "heiman_rc_partial_security_action"
heiman_partial_action_remote.arm_mode_action_map = {
[0] = "disarm",
[1] = "arm_partial_zones",
[3] = "arm_all_zones",
}
register_device_definition(sos_remote, device_helpers.create_fingerprints("TS0215A", {
"_TZ3000_4fsgukof",
"_TZ3000_wr2ucaj9",
"_TZ3000_zsh6uat3",
"_TZ3000_tj4pwzzm",
"_TZ3000_2izubafb",
"_TZ3000_pkfazisv",
"_TZ3000_0dumfk2z",
"_TZ3000_ssp0maqm",
"_TZ3000_p3fph1go",
"_TZ3000_9r5jaajv",
"_TZ3000_nxdziqzc",
"_TZ3000_irwuzilv",
}))
register_device_definition(heiman_sos_remote, {
device_helpers.create_fingerprint("HEIMAN", "SOS-EF-3.0"),
device_helpers.create_fingerprint("HEIMAN", "SOS-EM"),
})
register_device_definition(action_remote, device_helpers.create_fingerprints("TS0215A", {
"_TZ3000_p6ju8myv",
"_TZ3000_0zrccfgx",
"_TZ3000_fsiepnrh",
"_TZ3000_ug1vtuzn",
"_TZ3000_eo3dttwe",
"_TZ3000_jwcixnrz",
"_TZ3000_u2bbagu4",
"_TZ3000_8utxxtzr",
}))
register_device_definition(heiman_action_remote, {
device_helpers.create_fingerprint("HEIMAN", "RC-EF-3.0"),
})
register_device_definition(heiman_partial_action_remote, {
device_helpers.create_fingerprint("HEIMAN", "RC-EM"),
device_helpers.create_fingerprint("HEIMAN", "RC-N"),
})
return device_definitions
