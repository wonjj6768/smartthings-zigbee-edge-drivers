local zcl = require "zcl_common"
local emit = require "emitters"
local device_helpers = require "devices.shared.helpers"
local device_definitions, register_device_definition = device_helpers.definition_registry()
local smart_valve = {
profile = "valves-valve-indicator-mode",
zcl_clusters = {
zcl.switch("valve", {
emit = emit.valve(),
from_device = function(value)
if value then
return "open"
end
return "closed"
end,
}),
zcl.indicator_mode(),
},
}
local battery_valve = {
profile = "valves-valve-battery",
zcl_clusters = {
zcl.switch("valve", {
emit = emit.valve(),
from_device = function(value)
if value then
return "open"
end
return "closed"
end,
}),
zcl.battery(),
},
}
local ts0049_countdown_valve = {
profile = "valves-valve-battery-countdown-ts0049",
zcl_clusters = {
zcl.switch("valve", {
emit = emit.valve(),
from_device = function(value)
if value then
return "open"
end
return "closed"
end,
}),
zcl.battery(),
zcl.ts0049_countdown_timer(),
},
}
local function build_valve_zone(endpoint, component)
return zcl.switch("valve", {
endpoint = endpoint,
component = component,
emit = emit.valve(),
from_device = function(value)
if value then
return "open"
end
return "closed"
end,
})
end
local multi_zone_valve = {
profile = "valves-valve-5",
zcl_clusters = {
build_valve_zone(1, "main"),
build_valve_zone(2, "valve2"),
build_valve_zone(3, "valve3"),
build_valve_zone(4, "valve4"),
build_valve_zone(5, "valve5"),
zcl.power_on_behavior(),
zcl.countdown_timer(),
},
}
register_device_definition(smart_valve, device_helpers.create_fingerprints("TS0111", {
"_TYZB01_ymcdbl3u",
}))
register_device_definition(smart_valve, device_helpers.create_fingerprints("TS011F", {
"_TZ3000_rk2yzt0u",
"_TZ3000_o4cjetlm",
}))
register_device_definition(smart_valve, device_helpers.create_fingerprints("TS0001", {
"_TZ3000_o4cjetlm",
"_TZ3000_iedbgyxt",
"_TZ3000_h3noz0a5",
"_TYZB01_4tlksk8a",
"_TZ3000_5ucujjts",
"_TZ3000_h8ngtlxy",
"_TZ3000_w0ypwa1f",
"_TZ3000_wpueorev",
"_TZ3000_cmcjbqup",
}))
register_device_definition(smart_valve, device_helpers.create_fingerprints("TS0011", {
"_TYZB01_rifa0wlb",
}))
register_device_definition(ts0049_countdown_valve, device_helpers.create_fingerprints("TS0049", {
"_TZ3000_5af5r192",
"_TZ3000_cjfmu5he",
"_TZ3000_mq4wujmp",
"_TZ3000_ogjpfoyn",
}))
register_device_definition(battery_valve, device_helpers.create_fingerprints("TS0049", {
"_TZ3000_kz1anoi8",
"_TZ3290_ixd9mvv4",
}))
register_device_definition(battery_valve, {
device_helpers.create_fingerprint("HOBEIAN", "ZG-807Z"),
device_helpers.create_fingerprint("SONOFF", "SWV-ZFE"),
device_helpers.create_fingerprint("SONOFF", "SWV-ZFU"),
device_helpers.create_fingerprint("SONOFF", "SWV-ZNU"),
})
register_device_definition(multi_zone_valve, device_helpers.create_fingerprints("TS011F", {
"_TZ3000_j0ktmul1",
}))
return device_definitions
