local zcl = require "zcl_common"
local emit = require "emitters"
local device_helpers = require "devices.shared.helpers"
local data_types = require "st.zigbee.data_types"
local device_management = require "st.zigbee.device_management"
local device_definitions, register_device_definition = device_helpers.definition_registry()
local IAS_WARNING_DEVICE_CLUSTER = 0x0502
local IAS_WARNING_MAX_DURATION_ATTRIBUTE = 0x0000
local IAS_WARNING_VOLUME_ATTRIBUTE = 0x0002
local function clamp(value, minimum, maximum)
if value < minimum then
return minimum
end
if value > maximum then
return maximum
end
return value
end
local function map_number_range(value, from_minimum, from_maximum, to_minimum, to_maximum)
if type(value) ~= "number" then
return nil
end
if from_minimum == from_maximum then
return to_minimum
end
local ratio = (value - from_minimum) / (from_maximum - from_minimum)
return to_minimum + ((to_maximum - to_minimum) * ratio)
end
local function siren_volume_from_device(value)
if type(value) ~= "number" then
return value
end
local mapped = map_number_range(value, 100, 10, 0, 100)
if mapped == nil then
return nil
end
return math.floor(clamp(mapped, 0, 100) + 0.5)
end
local function siren_volume_to_device(value)
if type(value) ~= "number" then
return value
end
local mapped = map_number_range(clamp(value, 0, 100), 0, 100, 100, 10)
if mapped == nil then
return nil
end
return math.floor(clamp(mapped, 10, 100) + 0.5)
end
local ias_siren = {
profile = "safety-alarm-battery-volume",
zcl_clusters = {
zcl.alarm(),
zcl.battery(),
zcl.cluster_attribute(IAS_WARNING_DEVICE_CLUSTER, IAS_WARNING_VOLUME_ATTRIBUTE, {
name = "volume",
emit = emit.audio_volume(),
from_device = siren_volume_from_device,
to_device = siren_volume_to_device,
data_type = data_types.Uint8,
write_type = data_types.Uint8,
read_on_configure = true,
}),
},
}
local ias_siren_no_battery = {
profile = "safety-alarm-volume",
zcl_clusters = {
zcl.alarm(),
zcl.cluster_attribute(IAS_WARNING_DEVICE_CLUSTER, IAS_WARNING_VOLUME_ATTRIBUTE, {
name = "volume",
emit = emit.audio_volume(),
from_device = siren_volume_from_device,
to_device = siren_volume_to_device,
data_type = data_types.Uint8,
write_type = data_types.Uint8,
read_on_configure = true,
}),
},
}
local ias_siren_basic = {
profile = "safety-alarm-battery",
zcl_clusters = {
zcl.alarm(),
zcl.battery(),
zcl.cluster_attribute(IAS_WARNING_DEVICE_CLUSTER, IAS_WARNING_MAX_DURATION_ATTRIBUTE, {
name = "max_duration",
data_type = data_types.Uint16,
write_type = data_types.Uint16,
read_on_configure = true,
}),
},
}
local frient_sirzb112 = {
profile = "safety-siren-frient-sirzb112",
zcl_clusters = {
zcl.switch({ endpoint = 43 }),
zcl.alarm_1_or_2({ endpoint = 43 }),
zcl.tamper({ endpoint = 43 }),
zcl.battery_low({ endpoint = 43 }),
zcl.battery({ endpoint = 43 }),
zcl.cluster_attribute(IAS_WARNING_DEVICE_CLUSTER, IAS_WARNING_MAX_DURATION_ATTRIBUTE, {
name = "max_duration",
endpoint = 43,
data_type = data_types.Uint16,
write_type = data_types.Uint16,
read_on_configure = true,
}),
},
configure = function(driver, device)
for _, cluster_id in ipairs({ zcl.CLUSTER_ON_OFF, zcl.CLUSTER_POWER_CONFIGURATION }) do
device:send(device_management.build_bind_request(
device,
cluster_id,
driver.environment_info.hub_zigbee_eui,
43
))
end
end,
}
register_device_definition(ias_siren, device_helpers.create_fingerprints("TS0219", {
"_TYZB01_bwsijaty",
"_TYZB01_rs7ff6o7",
"_TYZB01_ynsiasng",
}))
register_device_definition(ias_siren_no_battery, device_helpers.create_fingerprints("TS0219", {
"_TZ3000_vdfwjopk",
}))
register_device_definition(ias_siren_basic, device_helpers.create_fingerprints("TS0216", {
"_TYZB01_4obovpbi",
"_TYZB01_8scntis1",
"_TYZB01_sbpc1zrb",
}))
register_device_definition(ias_siren_basic, {
device_helpers.create_fingerprint("AduroSmart Eria", "Smart Siren"),
device_helpers.create_fingerprint("Heiman", "WarningDevice"),
})
register_device_definition(frient_sirzb112, {
device_helpers.create_fingerprint("frient A/S", "SIRZB-112"),
})
return device_definitions
