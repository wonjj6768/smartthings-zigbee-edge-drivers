local zcl = require "zcl_common"
local emit = require "emitters"
local device_helpers = require "devices.shared.helpers"
local zcl_device_helpers = require "devices.zcl.helpers"
local data_types = require "st.zigbee.data_types"
local device_management = require "st.zigbee.device_management"
local device_definitions, register_device_definition = device_helpers.definition_registry()
local function build_metering_clusters()
return zcl_device_helpers.metering_clusters({
include_switch = true,
include_current = true,
})
end
local function ts011f_din_indicator_mode()
return zcl.cluster_attribute(zcl.CLUSTER_ON_OFF, 0x8001, {
name = "ts011f_din_indicator_mode",
emit = emit.ts011fDinIndicatorMode(),
data_type = data_types.Enum8,
write_type = data_types.Enum8,
from_device = function(value)
return ({ [0] = "off", [1] = "off_on", [2] = "on_off" })[value]
end,
to_device = function(value)
return ({ off = 0, off_on = 1, on_off = 2 })[value]
end,
read_on_configure = true,
})
end
local function ts011f_threshold_breaker_to_device(key, capability_id, attribute_name)
return function(value, device)
local threshold = device:get_latest_state("main", capability_id, attribute_name) or 0
threshold = math.floor((tonumber(threshold) or 0) + 0.5)
threshold = math.max(0, math.min(0xFFFF, threshold))
return string.char(
key,
value == "on" and 1 or 0,
bit32.band(bit32.rshift(threshold, 8), 0xFF),
bit32.band(threshold, 0xFF)
)
end
end
local metered_din_clusters = build_metering_clusters()
zcl_device_helpers.append_clusters(metered_din_clusters,
zcl.tuya_magic_packet(),
zcl.tuya_power_outage_memory(),
ts011f_din_indicator_mode()
)
local metered_din_relay = {
profile = "din-rail-ts011f-metered",
zcl_clusters = metered_din_clusters,
}
local unmetered_din_relay = {
profile = "din-rail-ts011f-unmetered",
zcl_clusters = {
zcl_device_helpers.switch_cluster(),
zcl.tuya_magic_packet(),
zcl.tuya_power_outage_memory(),
ts011f_din_indicator_mode(),
},
configure = function(driver, device)
device:send(device_management.build_bind_request(
device,
zcl.CLUSTER_ON_OFF,
driver.environment_info.hub_zigbee_eui,
1
))
end,
}
local frient_emizb_141 = {
profile = "meters-power-energy-battery",
zcl_clusters = {
zcl.power({ scale = 1000 }),
zcl.energy({ scale = 1000, poll_interval = 900 }),
zcl.battery(),
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
zcl.tuya_magic_packet(),
ts011f_din_indicator_mode(),
zcl.tuya_power_outage_memory(),
zcl.countdown_timer(),
zcl.child_lock(),
zcl.power_threshold(),
zcl.power_breaker(),
zcl.over_current_threshold({
name = "ts011f_din_over_current_threshold",
emit = emit.ts011fDinOverCurrentThreshold(),
numeric_range = { minimum = 1, maximum = 65, step = 1, unit = "A" },
}),
zcl.over_current_breaker({
to_device = ts011f_threshold_breaker_to_device(
0x01,
"concertmirror08464.ts011fDinOverCurrentThreshold",
"overCurrentThreshold"
),
}),
zcl.over_voltage_threshold(),
zcl.over_voltage_breaker(),
zcl.under_voltage_threshold({
name = "ts011f_din_under_voltage_threshold",
emit = emit.ts011fDinUnderVoltageThreshold(),
numeric_range = { minimum = 75, maximum = 240, step = 1, unit = "V" },
}),
zcl.under_voltage_breaker({
to_device = ts011f_threshold_breaker_to_device(
0x04,
"concertmirror08464.ts011fDinUnderVoltageThreshold",
"underVoltageThreshold"
),
})
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
register_device_definition(unmetered_din_relay, {
device_helpers.create_fingerprint("_TZ3000_7issjl2q", "TS011F"),
device_helpers.create_fingerprint("_TZ3000_gzvniqjb", "TS0011"),
})
register_device_definition(frient_emizb_141, {
device_helpers.create_fingerprint("frient A/S", "EMIZB-141"),
})
register_device_definition(frient_emizb_151, {
device_helpers.create_fingerprint("frient A/S", "EMIZB-151"),
})
register_device_definition(threshold_din_relay, device_helpers.create_fingerprints("TS011F", {
"_TZ3000_cayepv1a",
"_TZ3000_lepzuhto",
"_TZ3000_qystbcjg",
"_TZ3000_zrm3oxsh",
"_TZ3000_zv6x8bt2",
"_TZ3000_yi0n4xfd",
}))
register_device_definition(threshold_din_relay_no_temp, device_helpers.create_fingerprints("TS011F", {
"_TZ3000_303avxxt",
"_TZ3000_ibefeicf",
"_TZ3000_zjchz7pd",
}))
return device_definitions
