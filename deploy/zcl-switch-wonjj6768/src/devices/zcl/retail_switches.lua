local zcl = require "zcl_common"
local emit = require "emitters"
local device_helpers = require "devices.shared.helpers"
local zcl_device_helpers = require "devices.zcl.helpers"
local data_types = require "st.zigbee.data_types"
local capabilities = require "st.capabilities"
local device_management = require "st.zigbee.device_management"
local cluster_base = require "st.zigbee.cluster_base"
local device_definitions, register_device_definition = device_helpers.definition_registry()
local function register_aliases(definition, aliases)
register_device_definition(definition, aliases)
end
local function create_model_fingerprints(manufacturer, models)
local fingerprints = {}
for _, model in ipairs(models) do
fingerprints[#fingerprints + 1] = device_helpers.create_fingerprint(manufacturer, model)
end
return fingerprints
end
local function switch_definition(profile, endpoints)
local clusters = {}
for index, endpoint in ipairs(endpoints) do
clusters[#clusters + 1] = zcl.switch({
endpoint = endpoint,
component = index == 1 and "main" or ("switch" .. tostring(index)),
})
end
return {
profile = profile,
zcl_clusters = clusters,
configure = function(driver, device)
for _, endpoint in ipairs(endpoints) do
device:send(device_management.build_bind_request(
device,
zcl.CLUSTER_ON_OFF,
driver.environment_info.hub_zigbee_eui,
endpoint
))
end
end,
}
end
local switch_1 = switch_definition("switches-switch-1", { 1 })
local switch_2 = switch_definition("switches-switch-2", { 1, 2 })
local switch_3 = switch_definition("switches-switch-3", { 1, 2, 3 })
local heiman_switch_3 = switch_definition("switches-switch-3-device-temperature", { 1, 2, 3 })
zcl_device_helpers.append_clusters(heiman_switch_3.zcl_clusters,
zcl.cluster_attribute(0x0002, 0x0000, {
name = "device_temperature",
endpoint = 1,
emit = emit.temperature("C"),
data_type = data_types.Int16,
read_on_configure = true,
})
)
local heiman_switch_3_on_off_configure = heiman_switch_3.configure
heiman_switch_3.configure = function(driver, device)
heiman_switch_3_on_off_configure(driver, device)
device:send(device_management.build_bind_request(
device,
0x0002,
driver.environment_info.hub_zigbee_eui,
1
))
end
local switch_1_ep10 = switch_definition("switches-switch-1", { 10 })
local switch_2_ep10 = switch_definition("switches-switch-2", { 10, 11 })
local switch_3_ep10 = switch_definition("switches-switch-3", { 10, 11, 12 })
local switch_4 = switch_definition("switches-switch-4", { 1, 2, 3, 4 })
local switch_5_ep5 = switch_definition("switches-switch-5", { 1, 2, 3, 4, 5 })
local switch_5_ep5_tuya_options = switch_definition("switches-switch-5-tuya-options", { 1, 2, 3, 4, 5 })
zcl_device_helpers.append_clusters(switch_5_ep5_tuya_options.zcl_clusters,
zcl.tuya_magic_packet(),
zcl.tuya_power_outage_memory(),
zcl.child_lock()
)
local plug_1 = switch_definition("plugs-switch", { 1 })
local plug_2 = switch_definition("plugs-switch-2", { 1, 2 })
local battery_switch = {
profile = "switches-switch-1-battery",
zcl_clusters = {
zcl.switch(),
zcl.battery(),
},
}
local single_power_switch = {
profile = "switches-switch-1-power-options",
zcl_clusters = zcl_device_helpers.metering_clusters({
include_switch = true,
include_current = true,
}),
}
local dual_power_switch = {
profile = "switches-switch-2-power-options",
zcl_clusters = zcl_device_helpers.metering_clusters({
include_switch = true,
include_current = true,
}),
}
local dual_metered_switch_ep3 = switch_definition("switches-switch-2-power-options", { 1, 2 })
for _, cluster in ipairs(zcl_device_helpers.metering_clusters({
endpoint = 3,
include_switch = false,
include_current = true,
})) do
dual_metered_switch_ep3.zcl_clusters[#dual_metered_switch_ep3.zcl_clusters + 1] = cluster
end
local function candeo_power_on_behavior(endpoint, component)
return zcl.cluster_attribute(zcl.CLUSTER_ON_OFF, 0x4003, {
name = "candeo_sm30_power_on_behavior",
endpoint = endpoint,
component = component,
emit = emit.candeoSm30PowerBehavior(),
from_device = function(value)
return ({ [0] = "off", [1] = "on", [2] = "previous" })[value]
end,
to_device = function(value)
return ({ off = 0, on = 1, previous = 2 })[value]
end,
data_type = data_types.Enum8,
write_type = data_types.Enum8,
read_on_configure = true,
})
end
dual_metered_switch_ep3.profile = "switches-candeo-sm30-2g"
zcl_device_helpers.append_clusters(dual_metered_switch_ep3.zcl_clusters,
candeo_power_on_behavior(1, "main"),
candeo_power_on_behavior(2, "switch2")
)
dual_metered_switch_ep3.configure = function(driver, device)
for _, endpoint in ipairs({ 1, 2 }) do
device:send(device_management.build_bind_request(
device,
zcl.CLUSTER_ON_OFF,
driver.environment_info.hub_zigbee_eui,
endpoint
))
device:send(cluster_base.configure_reporting(
device,
data_types.ClusterId(zcl.CLUSTER_ON_OFF),
data_types.AttributeId(0x4003),
data_types.ZigbeeDataType(data_types.Enum8.ID),
0,
0xFFFF,
1
):to_endpoint(endpoint))
end
end
local metered_plug = {
profile = "plugs-switch-power-energy-voltage",
zcl_clusters = zcl_device_helpers.metering_clusters({
include_switch = true,
include_current = false,
}),
}
local SONOFF_CLUSTER = 0xFC11
local SONOFF_MFG_CODE = 0x1286
local SONOFF_CAPABILITY = "concertmirror08464.sonoffZbminir2"
local function on_off_from_device(value)
return (value == true or value == 1) and "on" or "off"
end
local function on_off_to_device(value)
return value == "on" or value == true
end
local function sonoff_boolean(attribute_id, name, emit_name, options)
options = options or {}
return zcl.cluster_attribute(SONOFF_CLUSTER, attribute_id, {
name = name,
emit = emit[emit_name](),
data_type = options.data_type or data_types.Boolean,
write_type = options.write_type or data_types.Boolean,
from_device = options.from_device or on_off_from_device,
to_device = options.to_device or on_off_to_device,
read_on_configure = true,
})
end
local function latest_sonoff_state(device, suffix, default)
local capability_id = SONOFF_CAPABILITY .. suffix
local attribute = suffix:sub(1, 1):lower() .. suffix:sub(2)
return device:get_latest_state("main", capability_id, attribute) or default
end
local function send_sonoff_inching(device, mapping, value, context)
local control = latest_sonoff_state(device, "InchingControl", "off")
local time = tonumber(latest_sonoff_state(device, "InchingTime", 0.5)) or 0.5
local mode = latest_sonoff_state(device, "InchingMode", "off")
if mapping.name == "sonoff_zbmini_r2_inching_control" then
control = value
elseif mapping.name == "sonoff_zbmini_r2_inching_time" then
time = tonumber(value) or time
elseif mapping.name == "sonoff_zbmini_r2_inching_mode" then
mode = value
end
local encoded_time = math.floor((math.max(0.5, math.min(3599.5, time)) * 2) + 0.5)
local mode_byte = (control == "on" and 0x80 or 0) + (mode == "on" and 0x01 or 0)
local bytes = { 0x01, 0x17, 0x07, 0x80, mode_byte, 0x00, encoded_time % 0x100, math.floor(encoded_time / 0x100), 0x00, 0x00 }
local checksum = 0
for _, byte in ipairs(bytes) do checksum = bit32.bxor(checksum, byte) end
bytes[#bytes + 1] = checksum
return zcl.send_raw_cluster_command(
device,
SONOFF_CLUSTER,
0x01,
string.char(table.unpack(bytes)),
context.endpoint,
nil,
SONOFF_MFG_CODE
)
end
local sonoff_zbmini_r2 = {
profile = "switches-switch-1-sonoff-zbmini-r2",
zcl_clusters = {
zcl.switch(),
zcl.cluster_attribute(zcl.CLUSTER_ON_OFF, 0x4003, {
name = "sonoff_zbmini_r2_power_on_behavior",
emit = emit.sonoffZbminir2PowerOnBehavior(),
data_type = data_types.Enum8,
write_type = data_types.Enum8,
from_device = function(value)
return ({ [0] = "off", [1] = "on", [2] = "toggle", [255] = "previous" })[value]
end,
to_device = function(value)
return ({ off = 0, on = 1, toggle = 2, previous = 255 })[value]
end,
read_on_configure = true,
}),
zcl.cluster_attribute(zcl.CLUSTER_ON_OFF, zcl.ATTR_ON_OFF, {
name = "sonoff_zbmini_r2_toggle",
emit = emit.switch(),
read_only = true,
command_id = 0x02,
command_extractor = function(_, device)
return device:get_latest_state("main", capabilities.switch.ID, "switch") ~= "on"
end,
}),
sonoff_boolean(0x0001, "sonoff_zbmini_r2_network_indicator", "sonoffZbminir2NetworkIndicator"),
sonoff_boolean(0x0012, "sonoff_zbmini_r2_turbo_mode", "sonoffZbminir2TurboMode", {
data_type = data_types.Int16,
write_type = data_types.Int16,
from_device = function(value) return value == 0x14 and "on" or "off" end,
to_device = function(value) return value == "on" and 0x14 or 0x09 end,
}),
sonoff_boolean(0x0014, "sonoff_zbmini_r2_delayed_power_on_state", "sonoffZbminir2DelayPowerState"),
zcl.cluster_attribute(SONOFF_CLUSTER, 0x0015, {
name = "sonoff_zbmini_r2_delayed_power_on_time",
emit = emit.sonoffZbminir2DelayPowerTime(),
data_type = data_types.Uint16,
write_type = data_types.Uint16,
from_device = function(value) return value / 2 end,
to_device = function(value) return value * 2 end,
numeric_range = { minimum = 0.5, maximum = 3599.5, step = 0.5, unit = "s" },
read_on_configure = true,
}),
sonoff_boolean(0x0017, "sonoff_zbmini_r2_detach_relay_mode", "sonoffZbminir2DetachRelayMode"),
zcl.cluster_attribute(SONOFF_CLUSTER, 0x0016, {
name = "sonoff_zbmini_r2_external_trigger_mode",
emit = emit.sonoffZbminir2ExtTriggerMode(),
data_type = data_types.Uint8,
write_type = data_types.Uint8,
from_device = function(value) return ({ [0] = "edge", [1] = "pulse", [2] = "following_off", [130] = "following_on" })[value] end,
to_device = function(value) return ({ edge = 0, pulse = 1, following_off = 2, following_on = 130 })[value] end,
read_on_configure = true,
}),
zcl.cluster_attribute(SONOFF_CLUSTER, nil, { name = "sonoff_zbmini_r2_inching_control", write_only = true, sender = send_sonoff_inching }),
zcl.cluster_attribute(SONOFF_CLUSTER, nil, { name = "sonoff_zbmini_r2_inching_time", write_only = true, sender = send_sonoff_inching }),
zcl.cluster_attribute(SONOFF_CLUSTER, nil, { name = "sonoff_zbmini_r2_inching_mode", write_only = true, sender = send_sonoff_inching }),
},
}
register_aliases(plug_1, {
device_helpers.create_fingerprint("Third Reality", "3RSP0186Z"),
device_helpers.create_fingerprint("Third Reality", "3RSPJ0187Z"),
device_helpers.create_fingerprint("Third Reality", "3RSPE02065Z"),
device_helpers.create_fingerprint("Third Reality", "3RSPU01080Z"),
})
register_aliases(plug_2, {
device_helpers.create_fingerprint("Third Reality", "3RWP01073Z"),
})
register_aliases(battery_switch, {
device_helpers.create_fingerprint("Third Reality, Inc", "3RSS009Z"),
device_helpers.create_fingerprint("Third Reality, Inc", "3RSS008Z"),
})
register_aliases(switch_1, {
device_helpers.create_fingerprint("Third Reality, Inc", "3RSS007Z"),
})
register_aliases(metered_plug, {
device_helpers.create_fingerprint("SONOFF", "S60ZBTPG"),
})
register_aliases(sonoff_zbmini_r2, {
device_helpers.create_fingerprint("SONOFF", "MINI-ZBD"),
device_helpers.create_fingerprint("SONOFF", "ZBMINIR2"),
})
register_aliases(dual_metered_switch_ep3, {
device_helpers.create_fingerprint("Candeo", "C-ZB-SM30-2G"),
})
register_aliases(metered_plug, {
device_helpers.create_fingerprint("Innr", "SP 242"),
device_helpers.create_fingerprint("Innr", "SP 244"),
})
register_aliases(switch_1, {
device_helpers.create_fingerprint("Candeo", "C205"),
device_helpers.create_fingerprint("IKEA", "E2006"),
})
register_aliases(switch_1, {
device_helpers.create_fingerprint("HEIMAN", "HS2SW1A-EF-3.0"),
device_helpers.create_fingerprint("HEIMAN", "HS2SW1A-EFR-3.0"),
})
register_aliases(switch_1, {
device_helpers.create_fingerprint("KlikAanKlikUit", "Built-in Switch"),
device_helpers.create_fingerprint("Oz Smart Things", "WSP403"),
device_helpers.create_fingerprint("Sibling", "Powerswitch-ZK(W)"),
device_helpers.create_fingerprint("Sunricher", "SR-ZG9101SAC-HP-SWITCH-B"),
device_helpers.create_fingerprint("BTicino", "3584C"),
device_helpers.create_fingerprint("BTicino", "3577C"),
device_helpers.create_fingerprint("BTicino", "FC80AC"),
device_helpers.create_fingerprint("BTicino", "FC80CC"),
device_helpers.create_fingerprint("BTicino", "FC80RC"),
device_helpers.create_fingerprint("BTicino", "LN4570CWI"),
device_helpers.create_fingerprint("Elko", "EKO07250"),
device_helpers.create_fingerprint("Elko", "EKO07251"),
device_helpers.create_fingerprint("Elko", "EKO07252"),
device_helpers.create_fingerprint("Elko", "EKO07253"),
device_helpers.create_fingerprint("Elko", "EKO20004"),
device_helpers.create_fingerprint("Elko", "EKO30198"),
device_helpers.create_fingerprint("Elko", "EKO30199"),
device_helpers.create_fingerprint("Gira", "2430-100"),
device_helpers.create_fingerprint("Gira", "2435-10"),
device_helpers.create_fingerprint("Jung", "ZLLHS4"),
device_helpers.create_fingerprint("Legrand", "199142"),
device_helpers.create_fingerprint("Sunricher", "SR-ZG9100A-S"),
})
register_aliases(switch_1, {
device_helpers.create_fingerprint("Schneider Electric", "1GANG/SWITCH/1"),
device_helpers.create_fingerprint("Schneider Electric", "CH10AX/SWITCH/1"),
device_helpers.create_fingerprint("Schneider Electric", "CH2AX/SWITCH/1"),
device_helpers.create_fingerprint("Schneider Electric", "NHPB/SWITCH/1"),
device_helpers.create_fingerprint("Schneider Electric", "PUCK/SWITCH/1"),
device_helpers.create_fingerprint("Schneider Electric", "U201SRY2KWZB"),
})
register_aliases(switch_1, {
device_helpers.create_fingerprint("TERNCY", "TERNCY-LS01"),
})
register_aliases(switch_1_ep10, {
device_helpers.create_fingerprint("Schneider Electric", "A3N31SR800ZB_xx_C1"),
device_helpers.create_fingerprint("Schneider Electric", "E8331SRY800ZB"),
})
register_aliases(switch_2_ep10, {
device_helpers.create_fingerprint("Schneider Electric", "A3N32SR800ZB_xx_C1"),
device_helpers.create_fingerprint("Schneider Electric", "E8332SRY800ZB"),
})
register_aliases(switch_3_ep10, {
device_helpers.create_fingerprint("Schneider Electric", "A3N33SR800ZB_xx_C1"),
device_helpers.create_fingerprint("Schneider Electric", "E8333SRY800ZB"),
})
register_aliases(switch_1, create_model_fingerprints("Sunricher", {
"ON/OFF",
"ZIGBEE-SWITCH",
"Micro Smart OnOff",
"HK-SL-RELAY-A",
}))
register_aliases(switch_2, {
device_helpers.create_fingerprint("Candeo", "C-ZB-SM205-2G"),
})
register_aliases(switch_2, {
device_helpers.create_fingerprint("HEIMAN", "HS2SW2A-EF-3.0"),
device_helpers.create_fingerprint("HEIMAN", "HS2SW2A-EFR-3.0"),
})
register_aliases(switch_2, {
device_helpers.create_fingerprint("LED-Trading", "UP-SA-9127D"),
device_helpers.create_fingerprint("Sunricher", "ON/OFF(2CH)"),
device_helpers.create_fingerprint("Sunricher", "SR-ZG9101SAC-HP-SWITCH-2CH"),
})
register_aliases(heiman_switch_3, {
device_helpers.create_fingerprint("HEIMAN", "HS2SW3A-EF-3.0"),
device_helpers.create_fingerprint("HEIMAN", "HS2SW3A-EFR-3.0"),
})
register_aliases(switch_4, {
device_helpers.create_fingerprint("Nova Digital", "TPZ-4"),
device_helpers.create_fingerprint("Tuya", "DS-111"),
device_helpers.create_fingerprint("MHCOZY", "TYWB 4ch-RF"),
device_helpers.create_fingerprint("AVATTO", "TS0004_1"),
device_helpers.create_fingerprint("AVATTO", "ZBTS60-04"),
device_helpers.create_fingerprint("RSH", "SB04-Zigbee"),
device_helpers.create_fingerprint("AVATTO", "ZWSM16-4"),
device_helpers.create_fingerprint("Moes", "ZM4LT4"),
device_helpers.create_fingerprint("iHseno", "_TZ3000_knoj8lpk"),
device_helpers.create_fingerprint("AVATTO", "ZWOT12"),
device_helpers.create_fingerprint("Coibeu", "ZB414"),
device_helpers.create_fingerprint("Nova Digital", "SA-4"),
device_helpers.create_fingerprint("Mercator Ikuü", "SSW04"),
device_helpers.create_fingerprint("OXT", "SWTZ27"),
device_helpers.create_fingerprint("TUYATEC", "GDKES-04TZXD"),
device_helpers.create_fingerprint("MakeGood", "MG-ZG04W/B/G"),
device_helpers.create_fingerprint("TERNCY", "TERNCY-WS01-S4"),
device_helpers.create_fingerprint("_TZ3210_qjvi92wz", "TS0014"),
device_helpers.create_fingerprint("_TZ3210_w3hl6rao", "TS0014"),
device_helpers.create_fingerprint("_TZ3210_z4hgsevd", "TS0014"),
device_helpers.create_fingerprint("Vizo", "VZ-221S"),
device_helpers.create_fingerprint("Vizo", "VZ-222S"),
device_helpers.create_fingerprint("Vizo", "VZ-223S"),
device_helpers.create_fingerprint("LELLKI", "WP33-EU"),
device_helpers.create_fingerprint("zunzunbee", "SSWZ8T"),
})
register_aliases(switch_5_ep5, {
device_helpers.create_fingerprint("Sunricher", "SR-ZG9023A-EU"),
})
return device_definitions
