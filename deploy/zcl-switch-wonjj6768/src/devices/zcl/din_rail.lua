local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local zcl_device_helpers = require "devices.zcl.helpers"
local device_definitions, register_device_definition = device_helpers.definition_registry()
local function build_metering_clusters()
return zcl_device_helpers.metering_clusters({
include_switch = true,
include_current = true,
})
end
local metered_din_relay = {
profile = "din-rail-switch-power-energy-voltage-current",
zcl_clusters = build_metering_clusters(),
}
local frient_emizb_141 = {
profile = "meters-power-energy",
zcl_clusters = {
zcl.power({ scale = 1000 }),
zcl.energy({ scale = 1000, poll_interval = 900 }),
},
}
local frient_emizb_151 = {
profile = "meters-power-energy",
zcl_clusters = {
zcl.power({ endpoint = 2 }),
zcl.energy({ endpoint = 2, poll_interval = 900 }),
},
}
local function build_threshold_din_relay(profile, include_temperature)
local clusters = build_metering_clusters()
zcl_device_helpers.append_clusters(clusters,
zcl.indicator_mode(),
zcl.power_outage_memory(),
zcl.countdown_timer(),
zcl.power_threshold(),
zcl.power_breaker(),
zcl.over_current_threshold(),
zcl.over_current_breaker(),
zcl.over_voltage_threshold(),
zcl.over_voltage_breaker(),
zcl.under_voltage_threshold(),
zcl.under_voltage_breaker()
)
if include_temperature then
zcl_device_helpers.append_clusters(clusters,
zcl.temperature(),
zcl.temperature_threshold(),
zcl.temperature_breaker()
)
end
return {
profile = profile,
zcl_clusters = clusters,
}
end
local threshold_din_relay = build_threshold_din_relay("din-rail-switch-power-energy-voltage-current-threshold", true)
local threshold_din_relay_no_temp = build_threshold_din_relay("din-rail-switch-power-energy-voltage-current-threshold-no-temp", false)
register_device_definition(metered_din_relay, device_helpers.create_fingerprints("TS011F", {
"_TZ3000_8bxrzyxz",
"_TZ3000_ky0fq4ho",
"_TZ3000_qeuvnohg",
"_TZ3000_6l1pjfqe",
"_TZ3000_2iiimqs9",
"_TZ3000_viqwamhn",
"_TZ3210_vbfp8eyv",
}))
register_device_definition(frient_emizb_141, {
device_helpers.create_fingerprint("frient A/S", "EMIZB-141"),
})
register_device_definition(frient_emizb_151, {
device_helpers.create_fingerprint("frient A/S", "EMIZB-151"),
})
register_device_definition(threshold_din_relay, device_helpers.create_fingerprints("TS011F_with_threshold", {
"_TZ3000_cayepv1a",
"_TZ3000_lepzuhto",
"_TZ3000_qystbcjg",
"_TZ3000_zrm3oxsh",
"_TZ3000_zv6x8bt2",
"_TZ3000_yi0n4xfd",
}))
register_device_definition(threshold_din_relay_no_temp, device_helpers.create_fingerprints("TS011F_with_threshold", {
"_TZ3000_303avxxt",
"_TZ3000_ibefeicf",
"_TZ3000_zjchz7pd",
}))
register_device_definition(threshold_din_relay_no_temp, {
device_helpers.create_fingerprint("Immax", "07573L"),
})
return device_definitions
