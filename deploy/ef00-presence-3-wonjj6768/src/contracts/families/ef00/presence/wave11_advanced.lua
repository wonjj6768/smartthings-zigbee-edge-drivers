local tuya=require "protocol.tuya"
local zcl=require "protocol.zcl"
local data_types=require "st.zigbee.data_types"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local common=require "contracts.helpers.ef00_presence"
local converter=tuya.converter
local registrations,register_device_definition=common.isolated_definition_registry(device_helpers)
local CLUSTER_TUYA_TWO=0xE002
local ATTR_PRESENCE_KEEP_TIME=0xE001
local ATTR_MOTION_SENSITIVITY=0xE004
local ATTR_STATIC_SENSITIVITY=0xE005
local ATTR_LED_INDICATOR=0xE009
local ATTR_TARGET_DISTANCE=0xE00A
local ATTR_MOTION_DISTANCE=0xE00B
local function illuminance_from_measured_value(value)
local numeric=tonumber(value)
if numeric==nil then return nil end
if numeric==0 then return 0 end
return math.floor(10 ^((numeric - 1)/ 10000)+ 0.5)
end
local linptech_es_one={
profile="safety-occupancy-wave11-linptech-es1",
package_group="z2m-ef00-pres-hyb",
named_datapoints=true,
datapoints={
tuya.dp_numeric(101,{
name="linptech_es_one_fading_time",
emit=emit.linptechEsOneFadingTime(),
}),
},
zcl_clusters={
zcl.occupancy({ias_zone=true,read_only=true}),
zcl.cluster_attribute(zcl.CLUSTER_ILLUMINANCE,zcl.ATTR_ILLUMINANCE_MEASURED_VALUE,{
name="illuminance",
data_type=data_types.Uint16,
converter=converter.from_only(illuminance_from_measured_value),
emit=emit.illuminance(),
read_only=true,
}),
zcl.cluster_attribute(CLUSTER_TUYA_TWO,ATTR_TARGET_DISTANCE,{
name="linptech_es_one_target_distance",
data_type=data_types.Uint16,
emit=emit.linptechEsOneTargetDistance(),
read_only=true,
}),
zcl.cluster_attribute(CLUSTER_TUYA_TWO,ATTR_MOTION_DISTANCE,{
name="linptech_es_one_motion_detection_distance",
data_type=data_types.Uint16,
write_type=data_types.Uint16,
emit=emit.linptechEsOneMotionDistance(),
read_only=false,
}),
zcl.cluster_attribute(CLUSTER_TUYA_TWO,ATTR_PRESENCE_KEEP_TIME,{
name="linptech_es_one_presence_keep_time",
data_type=data_types.Uint16,
emit=emit.linptechEsOneKeepTime(),
read_only=true,
}),
zcl.cluster_attribute(CLUSTER_TUYA_TWO,ATTR_MOTION_SENSITIVITY,{
name="linptech_es_one_motion_detection_sensitivity",
data_type=data_types.Uint8,
write_type=data_types.Uint8,
emit=emit.linptechEsOneMotionSensitivity(),
read_only=false,
}),
zcl.cluster_attribute(CLUSTER_TUYA_TWO,ATTR_STATIC_SENSITIVITY,{
name="linptech_es_one_static_detection_sensitivity",
data_type=data_types.Uint8,
write_type=data_types.Uint8,
emit=emit.linptechEsOneStaticSensitivity(),
read_only=false,
}),
zcl.cluster_attribute(CLUSTER_TUYA_TWO,ATTR_LED_INDICATOR,{
name="linptech_es_one_led_indicator",
data_type=data_types.Boolean,
write_type=data_types.Boolean,
converter=converter.lookup_from_to({ON=true,OFF=false}),
emit=emit.linptechEsOneLedIndicator(),
read_only=false,
}),
},
query_on_configure=false,
}
register_device_definition(linptech_es_one,{
device_helpers.create_fingerprint("_TZ3218_awarhusb","TS0225"),
device_helpers.create_fingerprint("_TZ3218_t9ynfz4x","TS0225"),
device_helpers.create_fingerprint("_TZ3218_ewrxirng","TS0225"),
})
return{
id="ef00.presence.wave11.advanced",
registrations=registrations,
}
