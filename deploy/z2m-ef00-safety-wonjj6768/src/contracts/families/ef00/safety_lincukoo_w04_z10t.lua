local tuya=require "protocol.tuya"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local converter=tuya.converter
local device_definitions,register_device_definition=device_helpers.definition_registry()
local alarm_status_converter=converter.from_only(converter.lookup_value({
[0]="alarm",
[1]="normal",
}))
local alarm_switch_converter=converter.lookup_from_to({
mute=0,
alarm=1,
})
local battery_state_converter=converter.from_only(converter.lookup_value({
[0]="low",
[1]="middle",
[2]="high",
}))
local ringtone_converter=converter.lookup_from_to({
ring1=0,
ring2=1,
ring3=2,
})
local water_alarm_battery_state={
profile="safety-water-lincukoo-w04-z10t-battery-state",
query_on_configure=false,
time_start="off",
initial_custom_state_query=false,
refresh_state_query=false,
placeholder_custom_states=false,
tuya.dp_numeric(1,{
name="lincukoo_w_four_alarm_status",
read_only=true,
emit=emit.lincukooWFourAlarmStatus(),
converter=alarm_status_converter,
}),
tuya.dp_enum(101,{
name="lincukoo_w_four_alarm_switch",
emit=emit.lincukooWFourAlarmSwitch(),
converter=alarm_switch_converter,
}),
tuya.dp_enum(3,{
name="lincukoo_w_four_battery_state",
read_only=true,
emit=emit.lincukooWFourBatteryState(),
converter=battery_state_converter,
}),
}
register_device_definition(water_alarm_battery_state,{
{manufacturer="_TZE284_iunyuzwe",model="TS0601"},
})
local water_alarm_battery_ringtone={
profile="safety-water-lincukoo-w04-z10t-battery-ringtone",
query_on_configure=false,
time_start="off",
initial_custom_state_query=false,
refresh_state_query=false,
placeholder_custom_states=false,
tuya.dp_numeric(1,{
name="lincukoo_w_four_alarm_status",
read_only=true,
emit=emit.lincukooWFourAlarmStatus(),
converter=alarm_status_converter,
}),
tuya.dp_enum(101,{
name="lincukoo_w_four_alarm_switch",
emit=emit.lincukooWFourAlarmSwitch(),
converter=alarm_switch_converter,
}),
tuya.dp_enum(102,{
name="lincukoo_w_four_ringtone",
emit=emit.lincukooWFourRingtone(),
converter=ringtone_converter,
}),
tuya.dp_battery(4,{
read_only=true,
emit=emit.battery(),
}),
}
register_device_definition(water_alarm_battery_ringtone,{
{manufacturer="_TZE284_vbgmewta",model="TS0601"},
})
return{
id="lincukoo.w04_z10t",
registrations=device_definitions,
}
