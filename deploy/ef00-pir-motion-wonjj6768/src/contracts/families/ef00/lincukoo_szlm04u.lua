local tuya=require "protocol.tuya"
local motion_events=require "capabilities.events.motion"
local converter=tuya.converter
local szlm04u_converters={
on_off=converter.lookup_from_to({
ON=true,
OFF=false,
}),
}
local events=motion_events.lincukoo_szlm04u()
local definition={
profile="safety-motion-szlm04u-illuminance-battery",
datapoints={
tuya.dp_occupancy(1,{emit=events.motion,read_only=true}),
tuya.dp_illuminance(101,{emit=events.illuminance,read_only=true}),
tuya.dp_battery(4,{emit=events.battery,read_only=true}),
tuya.dp_binary(102,{
name="usb_power",
emit=events.usb_power,
converter=szlm04u_converters.on_off,
read_only=true,
}),
tuya.dp_binary(103,{
name="switch",
emit=events.sensor_switch,
converter=szlm04u_converters.on_off,
read_only=true,
}),
tuya.dp_numeric(104,{
name="fading_time",
emit=events.fading_time,
}),
},
query_on_configure=false,
fingerprints={
{manufacturer="_TZE284_9ovska9w",model="TS0601"},
{manufacturer="_TZE284_bquwrqh1",model="TS0601"},
},
}
local fingerprint_groups={definition.fingerprints}
return{
id="ef00.motion.lincukoo_szlm04u",
definition=definition,
fingerprint_groups=fingerprint_groups,
}
