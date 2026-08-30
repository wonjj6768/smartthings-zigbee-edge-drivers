local tuya=require "protocol.tuya.contract"
local garage_door_events=require "capabilities.events.garage_door"
local converter=tuya.converter
local definition={
profile="doors-garage-contact",
datapoints={
tuya.dp_binary(1,{name="door_control",write_only=true}),
tuya.dp_binary(3,{
name="garage_door_contact",
converter=converter.invert_bool_pair(),
emit=garage_door_events.garage_door_contact,
}),
},
query_on_configure=true,
}
local fingerprint_groups={
{
{manufacturer="_TZE608_c75zqghm",model="TS0603"},
{manufacturer="_TZE608_fmemczv1",model="TS0603"},
{manufacturer="_TZE608_xkr8gep3",model="TS0603"},
{manufacturer="_TZE608_lapuuoke",model="TS0603"},
},
{
{manufacturer="_TZE200_wfxuhoea",model="TS0601"},
{manufacturer="_TZE204_wfxuhoea",model="TS0601"},
{manufacturer="LoraTap",model="GDC311ZBQ1"},
},
}
return{
id="ef00.garage_door.opener",
definition=definition,
fingerprint_groups=fingerprint_groups,
}
