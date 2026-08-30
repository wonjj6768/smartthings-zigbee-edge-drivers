local tuya=require "protocol.tuya"
local motion_events=require "capabilities.events.motion"
local converter=tuya.converter
local events=motion_events.aoyan_ay_204z()
local ay204z_converters={
sensitivity=converter.lookup_from_to({
low=0,
medium=1,
high=2,
}),
keep_time=converter.lookup_from_to({
["10"]=0,
["30"]=1,
["60"]=2,
["120"]=3,
}),
}
local definition={
profile="safety-motion-ay204z-battery",
datapoints={
tuya.dp_occupancy(1,{
emit=events.motion,
converter=converter.true_false0(),
read_only=true,
}),
tuya.dp_battery(4,{emit=events.battery,read_only=true}),
tuya.dp_enum(9,{
name="sensitivity",
emit=events.sensitivity,
converter=ay204z_converters.sensitivity,
}),
tuya.dp_enum(10,{
name="keep_time",
emit=events.keep_time,
converter=ay204z_converters.keep_time,
}),
},
query_on_configure=false,
fingerprints={
{manufacturer="AOYAN",model="AY-204Z"},
{manufacturer="AOYAN ",model="AY-204Z"},
{manufacturer="AOYAN  ",model="AY-204Z"},
},
}
local fingerprint_groups={definition.fingerprints}
return{
id="ef00.motion.aoyan_ay_204z",
definition=definition,
fingerprint_groups=fingerprint_groups,
}
