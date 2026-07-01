local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local emit = require "emitters"
local device_definitions, register_device_definition = device_helpers.definition_registry()
local function copy_list(items)
local copied = {}
for _, item in ipairs(items or {}) do
copied[#copied + 1] = item
end
return copied
end
local function build_single_dimmer(profile, options)
options = options or {}
local countdown_mapping = options.countdown_step == 30
and zcl.ts110e_countdown_timer({ emit = emit.countdownTsOneTenHalfMinute("s") })
or zcl.ts110e_countdown_timer()
return {
profile = profile,
zcl_clusters = {
zcl.switch(),
zcl.tuya_dimmer_level(),
zcl.power_on_behavior(),
zcl.ts110e_switch_type({ write_only = true }),
countdown_mapping,
zcl.ts110e_min_brightness(),
zcl.ts110e_max_brightness(),
zcl.light_type(),
},
}
end
local function build_basic_single_dimmer(profile)
return {
profile = profile,
zcl_clusters = {
zcl.switch(),
zcl.tuya_dimmer_level(),
},
}
end
local function build_basic_dual_dimmer(profile)
local zcl_clusters = copy_list(zcl.multi_switch(2, { component_prefix = "switch" }))
for _, cluster in ipairs(zcl.multi_level(2, { component_prefix = "switch" })) do
zcl_clusters[#zcl_clusters + 1] = cluster
end
return {
profile = profile,
zcl_clusters = zcl_clusters,
}
end
local function build_dual_dimmer(profile)
local zcl_clusters = copy_list(zcl.multi_switch(2, { component_prefix = "switch" }))
for _, cluster in ipairs(zcl.multi_level(2, { component_prefix = "switch" })) do
zcl_clusters[#zcl_clusters + 1] = cluster
end
zcl_clusters[#zcl_clusters + 1] = zcl.power_on_behavior()
zcl_clusters[#zcl_clusters + 1] = zcl.ts110e_switch_type({ write_only = true })
zcl_clusters[#zcl_clusters + 1] = zcl.ts110e_countdown_timer()
zcl_clusters[#zcl_clusters + 1] = zcl.ts110e_min_brightness()
zcl_clusters[#zcl_clusters + 1] = zcl.ts110e_max_brightness()
zcl_clusters[#zcl_clusters + 1] = zcl.light_type()
return {
profile = profile,
zcl_clusters = zcl_clusters,
}
end
local basic_single_dimmer = build_basic_single_dimmer("lights-dimmer")
local basic_dual_dimmer = build_basic_dual_dimmer("lights-dimmer-2")
local single_dimmer = build_single_dimmer("lights-dimmer-options-ts110")
local single_dimmer_countdown30 = build_single_dimmer("lights-dimmer-options-ts110-countdown30", { countdown_step = 30 })
local dual_dimmer = build_dual_dimmer("lights-dimmer-2-options-ts110")
register_device_definition(basic_single_dimmer, device_helpers.create_fingerprints("TS110F", {
"_TZ3000_estfrmup",
"_TZ3000_ktuoyvt5",
"_TZ3210_lfbz816s",
"_TZ3210_ebbfkvoy",
"_TYZB01_qezuin6k",
"_TYZB01_v8gtiaed",
"_TZ3000_92chsky7",
}))
register_device_definition(basic_dual_dimmer, device_helpers.create_fingerprints("TS110F", {
"_TZ3000_hexqj6ls",
}))
register_device_definition(basic_single_dimmer, {
device_helpers.create_fingerprint("Lonsonho", "QS-Zigbee-D02-TRIAC-L"),
})
register_device_definition(single_dimmer_countdown30, {
device_helpers.create_fingerprint("Lonsonho", "QS-Zigbee-D02-TRIAC-LN_1"),
})
register_device_definition(single_dimmer, {
device_helpers.create_fingerprint("Lonsonho", "QS-Zigbee-D02-TRIAC-L_1"),
})
register_device_definition(single_dimmer, device_helpers.create_fingerprints("TS110E_1gang_1", {
"_TZ3210_zxbtub8r",
"_TZ3210_zxbtub8r:TS110E",
"_TZ3210_cyuyd5az",
"_TZ3210_cyuyd5az:TS110E",
}))
register_device_definition(single_dimmer_countdown30, device_helpers.create_fingerprints("TS110E_1gang_2", {
"_TZ3210_ngqk6jia",
"_TZ3210_ngqk6jia:TS110E",
}))
register_device_definition(single_dimmer, device_helpers.create_fingerprints("TS110E_1gang_2", {
"_TZ3210_weaqkhab",
"_TZ3210_weaqkhab:TS110E",
"_TZ3210_k1msuvg6",
"_TZ3210_k1msuvg6:TS110E",
}))
register_device_definition(single_dimmer, device_helpers.create_fingerprints("TS110E", {
"_TZ3210_hzdhb62z",
"_TZ3210_ysfo0wla",
"_TZ3210_v5yquxma",
"_TZE200_ubgdwsnr",
"_TZ3210_guijtl8k",
"_TZ3210_hquixjeg",
"_TZ3000_xfs39dbf:TS1101",
}))
register_device_definition(dual_dimmer, device_helpers.create_fingerprints("TS110E_2gang_1", {
"_TZ3210_wdexaypg",
"_TZ3210_wdexaypg:TS110E",
}))
register_device_definition(dual_dimmer, device_helpers.create_fingerprints("TS110E_2gang_2", {
"_TZ3210_pagajpog",
"_TZ3210_pagajpog:TS110E",
"_TZ3210_4ubylghk",
"_TZ3210_4ubylghk:TS110E",
"_TZ3210_vfwhhldz",
"_TZ3210_vfwhhldz:TS110E",
"_TZ3210_3mpwqzuu",
"_TZ3210_3mpwqzuu:TS110E",
"_TZ3210_mt5xjoy6",
"_TZ3210_mt5xjoy6:TS110E",
"_TZ3210_tkkb1ym8",
"_TZ3210_tkkb1ym8:TS110E",
"_TZ3000_7ysdnebc:TS1101",
"_TZ3000_zjtxnoft:TS0052",
"_TZ3000_kvwrdf47:TS0052",
"_TZ3000_sfibawtr:TS0052",
}))
register_device_definition(dual_dimmer, {
device_helpers.create_fingerprint("Nedis", "ZBWD20RD"),
})
return device_definitions
