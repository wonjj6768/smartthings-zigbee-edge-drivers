local tuya=require "protocol.tuya.contract"
local garage_door_events=require "capabilities.events.garage_door"
local converter=tuya.converter
local definition={
profile="doors-garage-contact-countdown",
datapoints={
tuya.dp_binary(1,{name="door_control",write_only=true}),
tuya.dp_numeric(2,{name="countdown",emit=garage_door_events.countdown}),
tuya.dp_binary(3,{
name="garage_door_contact",
converter=converter.invert_bool_pair(),
emit=garage_door_events.garage_door_contact,
}),
tuya.dp_numeric(4,{name="run_time",emit=garage_door_events.run_time}),
tuya.dp_numeric(5,{name="open_alarm_time",emit=garage_door_events.open_alarm_time}),
tuya.dp_enum(12,{
name="garage_status",
converter=converter.lookup_from_to({
open_time_alarm=0,
run_time_alarm=1,
normal=2,
}),
emit=garage_door_events.status,
}),
},
query_on_configure=true,
}
local fingerprint_groups={
{
{manufacturer="_TZE200_nklqjk62",model="TS0601"},
{manufacturer="_TZE204_nklqjk62",model="TS0601"},
{manufacturer="_TZE204_jktmrpoj",model="TS0601"},
{manufacturer="_TZE284_nklqjk62",model="TS0601"},
},
}
return{
id="ef00.garage_door.opener_countdown",
definition=definition,
fingerprint_groups=fingerprint_groups,
}
