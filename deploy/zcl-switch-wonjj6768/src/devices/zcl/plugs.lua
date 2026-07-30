local zcl = require "zcl_common"
local emit = require "emitters"
local device_helpers = require "devices.shared.helpers"
local zcl_device_helpers = require "devices.zcl.helpers"
local data_types = require "st.zigbee.data_types"
local device_management = require "st.zigbee.device_management"
local OnOff = require("st.zigbee.zcl.clusters").OnOff
local zigbee_constants = require "st.zigbee.constants"
local device_definitions, register_device_definition = device_helpers.definition_registry()
local function create_model_fingerprints(manufacturer, models)
local fingerprints = {}
for _, model in ipairs(models) do
fingerprints[#fingerprints + 1] = device_helpers.create_fingerprint(manufacturer, model)
end
return fingerprints
end
local function build_plug(profile, clusters)
return {
profile = profile,
zcl_clusters = clusters,
}
end
local function bind_on_off_endpoints(endpoints, configure_reporting)
return function(driver, device)
for _, endpoint in ipairs(endpoints) do
device:send(device_management.build_bind_request(
device,
zcl.CLUSTER_ON_OFF,
driver.environment_info.hub_zigbee_eui,
endpoint
))
if configure_reporting then
device:send(OnOff.attributes.OnOff:configure_reporting(device, 0, 3600):to_endpoint(endpoint))
end
end
end
end
local function build_metered_strip(profile, endpoints, options)
options = options or {}
local clusters = {}
for index, endpoint in ipairs(endpoints) do
clusters[#clusters + 1] = zcl.switch({
endpoint = endpoint,
component = index == 1 and "main" or ("switch" .. tostring(index)),
})
end
zcl_device_helpers.append_clusters(clusters,
zcl_device_helpers.metering_clusters({
endpoint = endpoints[1],
include_switch = false,
include_current = true,
energy_scale = 100,
})
)
if options.tuya_magic then
zcl_device_helpers.append_clusters(clusters, zcl.tuya_magic_packet())
end
if options.power_outage_memory then
zcl_device_helpers.append_clusters(clusters, zcl.tuya_power_outage_memory())
end
local definition = build_plug(profile, clusters)
if options.bind_on_off then
definition.configure = bind_on_off_endpoints(endpoints, options.configure_on_off_reporting)
end
return definition
end
local function build_metering_clusters(include_current)
return zcl_device_helpers.metering_clusters({
include_switch = true,
include_current = include_current,
})
end
local switch_only_plug = build_plug("plugs-switch", {
zcl.switch(),
})
local tuya_switch_only_plug = build_plug("plugs-switch", {
zcl.switch(),
zcl.tuya_magic_packet(),
})
tuya_switch_only_plug.configure = bind_on_off_endpoints({ 1 }, true)
local lidl_hg06337_plug = build_plug("plugs-lidl-hg06337", {
zcl.switch({ endpoint = 11 }),
zcl.tuya_magic_packet(),
zcl.indicator_mode({ endpoint = 11 }),
})
lidl_hg06337_plug.configure = bind_on_off_endpoints({ 11 }, true)
local tuya_wall_outlet = build_plug("plugs-switch-child-lock", {
zcl.switch(),
zcl.tuya_magic_packet(),
zcl.child_lock(),
})
tuya_wall_outlet.configure = bind_on_off_endpoints({ 1 }, true)
local tuya_option_plug = build_plug("plugs-switch-tuya-options", {
zcl.switch(),
zcl.tuya_magic_packet(),
zcl.tuya_power_outage_memory(),
zcl.indicator_mode(),
zcl.child_lock(),
zcl.countdown_timer(),
})
tuya_option_plug.configure = bind_on_off_endpoints({ 1 }, true)
local zemismart_zmo606_20a = build_plug("plugs-zemismart-zmo606-20a", {
zcl.switch(),
zcl.tuya_magic_packet(),
zcl.indicator_mode(),
zcl.child_lock(),
zcl.countdown_timer(),
})
zemismart_zmo606_20a.configure = bind_on_off_endpoints({ 1 }, true)
local function bacchus_zone_state(value)
if type(value) == "table" and type(value.is_alarm1_set) == "function" and type(value.is_alarm2_set) == "function" then
return {
water = value:is_alarm1_set(),
tank = value:is_alarm2_set() and "full" or "normal",
}
end
if type(value) == "table" and value.value ~= nil then
value = value.value
end
if type(value) ~= "number" then
return nil
end
return {
water = value % 2 == 1,
tank = math.floor(value / 2) % 2 == 1 and "full" or "normal",
}
end
local function bacchus_zone_status(zb_rx)
local body = zb_rx and zb_rx.body and zb_rx.body.zcl_body or nil
local zone_status = body and (body.zone_status or body.zonestatus) or nil
if zone_status == nil then
return nil
end
return {
raw_value = type(zone_status) == "table" and zone_status.value or zone_status,
typed_value = zone_status,
}
end
local bacchus_water_station_clusters = {}
for endpoint = 1, 5 do
bacchus_water_station_clusters[#bacchus_water_station_clusters + 1] = zcl.switch({
endpoint = endpoint,
component = endpoint == 1 and "main" or ("switch" .. tostring(endpoint)),
})
end
for endpoint = 1, 3 do
bacchus_water_station_clusters[#bacchus_water_station_clusters + 1] = zcl.cluster_attribute(zcl.CLUSTER_ON_OFF, 0xF003, {
name = "bacchus_pump_duration",
endpoint = endpoint,
component = endpoint == 1 and "main" or ("switch" .. tostring(endpoint)),
emit = emit.bacchusPumpDuration(),
data_type = data_types.Uint16,
write_type = data_types.Uint16,
numeric_range = { minimum = 0, maximum = 600, step = 1 },
read_on_configure = true,
})
end
bacchus_water_station_clusters[#bacchus_water_station_clusters + 1] = zcl.cluster_attribute(zcl.CLUSTER_ON_OFF, 0xF005, {
name = "bacchus_beeper_on_leak",
endpoint = 1,
component = "main",
emit = emit.bacchusBeeperOnLeak(),
from_device = function(value) return value and "on" or "off" end,
to_device = function(value) return value == "on" end,
data_type = data_types.Boolean,
write_type = data_types.Boolean,
read_on_configure = true,
})
local bacchus_water_emitter = emit.water()
local bacchus_tank_full_emitter = emit.bacchusTankFull()
bacchus_water_station_clusters[#bacchus_water_station_clusters + 1] = zcl.ias_zone({
name = "bacchus_tank_full",
endpoint = 6,
component = "tank",
emit = function(device, value)
return bacchus_water_emitter(device, value.water)
end,
handler = function(device, value)
local event = bacchus_tank_full_emitter(device, value.tank)
if event ~= nil then
device:emit_component_event({ id = "tank" }, event)
end
end,
from_device = bacchus_zone_state,
prefer_typed_value = true,
ias_configure_method = zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
command_id = 0x00,
command_extractor = bacchus_zone_status,
})
local bacchus_water_station = build_plug("plugs-bacchus-water-station", bacchus_water_station_clusters)
bacchus_water_station.configure = function(driver, device)
bind_on_off_endpoints({ 1, 2, 3, 4, 5 }, true)(driver, device)
device:send(device_management.build_bind_request(
device,
zcl.CLUSTER_IAS_ZONE,
driver.environment_info.hub_zigbee_eui,
6
))
end
local dual_usb_socket = build_plug("plugs-switch-2", {
zcl.switch({
endpoint = 1,
component = "main",
}),
zcl.switch({
endpoint = 7,
component = "switch2",
}),
zcl.tuya_magic_packet(),
})
dual_usb_socket.configure = bind_on_off_endpoints({ 1, 7 })
local metered_plug = build_plug("plugs-switch-power-energy-voltage", build_metering_clusters(false))
local metered_plug_current = build_plug("plugs-switch-power-energy-voltage-current", build_metering_clusters(true))
local tuya_metered_plug_core = build_plug("plugs-switch-power-energy-voltage-current", {
zcl.switch(),
zcl.power(),
zcl.energy({ scale = 100 }),
zcl.voltage(),
zcl.current(),
zcl.tuya_magic_packet(),
})
tuya_metered_plug_core.configure = function(driver, device)
for _, cluster_id in ipairs({ zcl.CLUSTER_ON_OFF, 0x0B04, 0x0702 }) do
device:send(device_management.build_bind_request(
device,
cluster_id,
driver.environment_info.hub_zigbee_eui,
1
))
end
end
local standard_power_measurement_switch = build_plug("plugs-switch-power-voltage-current", {
zcl.switch(),
zcl.power(),
zcl.voltage(),
zcl.current(),
})
standard_power_measurement_switch.configure = function(driver, device)
for _, cluster_id in ipairs({ zcl.CLUSTER_ON_OFF, 0x0B04 }) do
device:send(device_management.build_bind_request(
device,
cluster_id,
driver.environment_info.hub_zigbee_eui,
1
))
end
end
local switch_power_energy = build_plug("switch-power-energy", {
zcl.switch(),
zcl.power(),
zcl.energy(),
})
local smart_cable_power_energy = build_plug("switches-switch-1-power-energy-voltage-current",
zcl_device_helpers.metering_clusters({
endpoint = 2,
include_current = true,
})
)
local wp30_power_strip = build_metered_strip("plugs-wp30-power-strip", { 1, 2, 3 }, {
tuya_magic = true,
power_outage_memory = true,
bind_on_off = true,
configure_on_off_reporting = true,
})
local function lookup_from_device(values)
return function(value)
return values[value]
end
end
local function lookup_to_device(values)
return function(value)
return values[value]
end
end
local function a11z_enum_mapping(name, endpoint, component, cluster_id, attribute_id, emitter, from_values, to_values)
return zcl.cluster_attribute(cluster_id, attribute_id, {
name = name,
endpoint = endpoint,
component = component,
emit = emitter,
from_device = lookup_from_device(from_values),
to_device = lookup_to_device(to_values),
data_type = data_types.Enum8,
write_type = data_types.Enum8,
read_on_configure = true,
})
end
local function a11z_identify_sender(device, _, value, context)
if value ~= "identify" then
return false
end
return zcl.send_raw_cluster_command(
device,
0x0003,
0x00,
string.char(0x03, 0x00),
context.endpoint or 1
)
end
local a11z_power_strip = build_metered_strip("plugs-nous-a11z", { 1, 2, 3 })
zcl_device_helpers.append_clusters(a11z_power_strip.zcl_clusters, zcl.tuya_magic_packet())
for index, endpoint in ipairs({ 1, 2, 3 }) do
local component = index == 1 and "main" or ("switch" .. tostring(index))
zcl_device_helpers.append_clusters(a11z_power_strip.zcl_clusters,
a11z_enum_mapping(
"nous_a11z_power_on_behavior",
endpoint,
component,
0xE001,
0xD010,
emit.nousA11zPowerBehavior(),
{ [0] = "off", [1] = "on", [2] = "previous" },
{ off = 0, on = 1, previous = 2 }
),
zcl.countdown_timer({
name = "nous_a11z_countdown",
endpoint = endpoint,
component = component,
emit = emit.nousA11zCountdown(),
})
)
end
zcl_device_helpers.append_clusters(a11z_power_strip.zcl_clusters,
a11z_enum_mapping(
"nous_a11z_indicator_mode",
1,
"main",
zcl.CLUSTER_ON_OFF,
0x8001,
emit.nousA11zIndicatorMode(),
{ [0] = "off", [1] = "off_on", [2] = "on_off", [3] = "on" },
{ off = 0, off_on = 1, on_off = 2, on = 3 }
),
zcl.cluster_attribute(zcl.CLUSTER_ON_OFF, 0x8000, {
name = "nous_a11z_child_lock",
endpoint = 1,
component = "main",
emit = emit.nousA11zChildLock(),
from_device = function(value) return value and "on" or "off" end,
to_device = function(value) return value == "on" end,
data_type = data_types.Boolean,
write_type = data_types.Boolean,
read_on_configure = true,
}),
a11z_enum_mapping(
"nous_a11z_switch_type",
1,
"main",
0xE001,
0xD030,
emit.nousA11zSwitchType(),
{ [0] = "release", [1] = "press" },
{ release = 0, press = 1 }
),
zcl.cluster_attribute(0x0003, nil, {
name = "nous_a11z_identify",
endpoint = 1,
component = "main",
write_only = true,
enum_values = { "identify" },
sender = a11z_identify_sender,
})
)
local five_switch_plug = {
profile = "plugs-switch-5",
zcl_clusters = zcl.multi_switch({ 1, 2, 3, 4, 7 }),
}
register_device_definition(tuya_switch_only_plug, device_helpers.create_fingerprints("TS011F", {
"_TZ3000_oiymh3qu",
}))
register_device_definition(tuya_switch_only_plug, device_helpers.create_fingerprints("TS0101", {
"_TZ3000_br3laukf",
"_TZ3000_pnzfdr9y",
"_TYZB01_ijihzffk",
}))
register_device_definition(switch_only_plug, device_helpers.create_fingerprints("TS0101", {
"_TZ3210_eymunffl",
"_TZ3210_tfxwxklq",
"_TZ3210_2dfy6tol",
}))
register_device_definition(dual_usb_socket, device_helpers.create_fingerprints("TS0108", {
"_TYZB01_7yidyqxd",
}))
register_device_definition(tuya_wall_outlet, device_helpers.create_fingerprints("TS011F", {
"_TZ3000_wxtp7c5y",
"_TYZB01_mtunwanm",
}))
register_device_definition(tuya_option_plug, device_helpers.create_fingerprints("TS011F", {
"_TZ3000_hyfvrar3",
"_TZ3000_v1pdxuqq",
"_TZ3000_8a833yls",
"_TZ3000_bfn1w0mm",
"_TZ3000_nzkqcvvs",
"_TZ3000_rtcrrvia",
"_TZ3000_ysiog9xi",
"_TZ3000_o1jzcxou",
"_TZ3210_nhqka112",
"_TZ3000_uyrhiafs",
}))
register_device_definition(tuya_switch_only_plug, device_helpers.create_fingerprints("TS011F", {
"_TZ3000_8fdayfch",
"_TZ3000_1hwjutgo",
"_TZ3000_lnggrqqi",
"_TZ3000_tvuarksa",
}))
register_device_definition(lidl_hg06337_plug, device_helpers.create_fingerprints("TS011F", {
"_TZ3000_00mk2xzy",
"_TZ3000_upjrsxh1",
"_TZ3000_plyvnuf5",
"_TZ3000_wamqdr3f",
}))
register_device_definition(zemismart_zmo606_20a, device_helpers.create_fingerprints("TS011F", {
"_TZ3000_b1q8kwmh",
}))
register_device_definition(bacchus_water_station, {
device_helpers.create_fingerprint("Bacchus", "Water_Station"),
device_helpers.create_fingerprint("Bacchus", "Water_Station.Modkam"),
})
register_device_definition(tuya_metered_plug_core, device_helpers.create_fingerprints("TS011F", {
"_TZ3000_ko6v90pg",
"_TZ3008_1a8m8wd6",
"_TZ3008_reatplte",
"_TZ3210_2putqrmw",
"_TZ3210_2uollq9d",
"_TZ3210_4ux0ondb",
"_TZ3210_zifx0xoj",
"_TZ3000_4ux0ondb",
"_TZ3000_b28wrpvx",
"_TZ3000_2uollq9d",
"_TZ3000_cehuw1lw",
"_TZ3000_9ni6xxld",
"_TZ3210_5ct6e7ye",
"_TZ3000_2putqrmw",
"_TZ3000_ksw8qtmt",
"_TZ3000_yujkchbz",
"_TZ3000_ss98ec5d",
"_TZ3000_okaz9tjs",
"_TZ3000_y4ona9me",
"_TZ3000_266azbg3",
"_TZ3000_3ias4w4o",
"_TZ3210_ddigca5n",
"_TZ3000_ww6drja5",
"_TZ3210_rwmitwj4",
"Zbeacon",
"_TZ3000_gjnozsaz",
"_TZ3000_cicwjqth",
"_TZ3210_jlf1nepw",
"_TZ3000_cjrngdr3",
"_TZ3210_cjrngdr3",
"_TZ3000_amdymr7l",
"_TZ3000_zloso4jk",
"_TZ3210_w0qqde0g",
}))
register_device_definition(tuya_metered_plug_core, {
{ manufacturer = "AOYAN  ", model = "TS011F" },
})
register_device_definition(metered_plug, {
device_helpers.create_fingerprint("LUMI", "lumi.ctrl_86plug"),
device_helpers.create_fingerprint("LUMI", "lumi.ctrl_86plug.aq1"),
device_helpers.create_fingerprint("LUMI", "lumi.plug"),
device_helpers.create_fingerprint("LUMI", "lumi.plug.aq1"),
device_helpers.create_fingerprint("LUMI", "lumi.plug.mitw01"),
})
register_device_definition(metered_plug_current, {
device_helpers.create_fingerprint("LUMI", "lumi.plug.aeu001"),
device_helpers.create_fingerprint("LUMI", "lumi.plug.macn01"),
device_helpers.create_fingerprint("LUMI", "lumi.plug.maeu01"),
device_helpers.create_fingerprint("LUMI", "lumi.plug.maus01"),
device_helpers.create_fingerprint("LUMI", "lumi.plug.mmeu01"),
device_helpers.create_fingerprint("LUMI", "lumi.plug.sacn02"),
})
register_device_definition(smart_cable_power_energy, {
device_helpers.create_fingerprint("frient A/S", "SMRZB-153"),
})
register_device_definition(switch_power_energy, {
device_helpers.create_fingerprint("Schneider Electric", "SMARTPLUG/1"),
})
register_device_definition(tuya_metered_plug_core, device_helpers.create_fingerprints("TS011F", {
"_TZ3000_3uimvkn6",
"_TZ3000_j1v25l17",
"_TZ3000_ynmowqk2",
"_TZ3000_0yxeawjt",
}))
register_device_definition(standard_power_measurement_switch, {
device_helpers.create_fingerprint("AduroSmart ERIA", "ONOFF_METER_RELAY"),
device_helpers.create_fingerprint("HEIMAN", "SmartPlug-N"),
})
register_device_definition(switch_only_plug, {
device_helpers.create_fingerprint("Third Reality, Inc", "3RSP019BZ"),
})
register_device_definition(metered_plug_current, {
device_helpers.create_fingerprint("Third Reality, Inc", "3RSP02028BZ"),
device_helpers.create_fingerprint("Third Reality, Inc", "3RSPE01044BZ"),
})
register_device_definition(metered_plug_current, {
device_helpers.create_fingerprint("HEIMAN", "SmartPlug"),
device_helpers.create_fingerprint("HEIMAN", "SmartPlug-EF-3.0"),
})
register_device_definition(switch_only_plug, create_model_fingerprints("LEDVANCE", {
"Outdoor Plug",
"PLUG COMPACT EU T",
"PLUG OUTDOOR EU T",
"Plug Value",
}))
register_device_definition(metered_plug_current, create_model_fingerprints("LEDVANCE", {
"PLUG COMPACT OUTDOOR EU EM T",
"PLUG COMPACT EU EM T",
}))
register_device_definition(switch_only_plug, create_model_fingerprints("OSRAM", {
"Plug 01",
"Plug Z3",
}))
register_device_definition(wp30_power_strip, device_helpers.create_fingerprints("TS011F", {
"_TZ3000_c7nc9w3c",
"_TZ3210_c7nc9w3c",
}))
register_device_definition(a11z_power_strip, device_helpers.create_fingerprints("TS011F", {
"_TZ3210_6cmeijtd",
}))
return device_definitions
