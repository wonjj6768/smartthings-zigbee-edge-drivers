local tuya=require "protocol.tuya"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local device_definitions,register_device_definition=device_helpers.definition_registry()
local function custom(capability_id)
return assert(emit[capability_id],"missing Wave16 Lincukoo siren emitter: " .. capability_id)()
end
local function options(name,capability_id)
return{
name=name,
emit=custom(capability_id),
transaction=1,
}
end
local function value_enum(dp,name,capability_id,values)
local mapping=options(name,capability_id)
mapping.converter=tuya.converter.lookup_from_to(values)
return tuya.dp_numeric(dp,mapping)
end
local function enum(dp,name,capability_id,values)
local mapping=options(name,capability_id)
mapping.converter=tuya.converter.lookup_from_to(values)
return tuya.dp_enum(dp,mapping)
end
local a_zero_eight={
profile="safety-wave16-lincukoo-a08-z10t",
package_group="siren",
transport_classification="EF00_DP",
z2m_converter_source="meta.tuyaDatapoints",
wire_cluster="manuSpecificTuya",
magic_packet=true,
query_on_configure=false,
time_start="off",
datapoints={},
}
local function add(mapping)
a_zero_eight.datapoints[#a_zero_eight.datapoints + 1]=mapping
end
add(value_enum(1,"a_zero_eight_alarm_state","aZeroEightAlarmState",{
alarm_sound=0,
alarm_light=1,
alarm_sound_light=2,
normal=3,
}))
add(enum(5,"a_zero_eight_alarm_volume","aZeroEightAlarmVolume",{
low=0,
middle=1,
high=2,
mute=3,
}))
add(tuya.dp_numeric(7,{
name="a_zero_eight_alarm_time",
emit=custom("aZeroEightAlarmTime"),
transaction=1,
}))
local mute=options("a_zero_eight_mute","aZeroEightMute")
mute.converter=tuya.converter.lookup_from_to({ON=true,OFF=false})
add(tuya.dp_binary(16,mute))
local ringtones={}
for index=1,27 do
ringtones["ringtone_" .. index]=index - 1
end
add(enum(21,"a_zero_eight_alarm_ringtone","aZeroEightAlarmRingtone",ringtones))
register_device_definition(a_zero_eight,device_helpers.create_fingerprints("TS0601",{
"_TZE204_l4daccga",
}))
return{
id="ef00.safety.wave16_lincukoo_siren",
registrations=device_definitions,
}
