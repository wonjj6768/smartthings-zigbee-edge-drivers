local tuya=require "protocol.tuya"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local converter=tuya.converter
local device_definitions,register_device_definition=device_helpers.definition_registry()
local status_converter=converter.lookup_from_to({
off=0,
on_auto=1,
button_locked=2,
on_manual_app=3,
on_manual_button=4,
})
local child_lock_converter=converter.lookup_from_to({
LOCK=true,
UNLOCK=false,
})
local refresh_converter=converter.from_to(
function()return "idle" end,
function(value)return value=="refresh" end
)
local fault_converter=converter.from_only(function(value)
return(tonumber(value)or 0)~=0
end)
local definition={
profile="valves-neo-nas-wv03b2",
time_start="2000",
initial_custom_state_query=false,
refresh_state_query=false,
placeholder_custom_states=false,
tuya.dp_on_off(1,{name="switch",emit=emit.switch()}),
tuya.dp_enum(3,{
name="neo_nas_two_status",
read_only=true,
emit=emit.neoNasTwoStatus(),
converter=status_converter,
}),
tuya.dp_numeric(5,{
name="neo_nas_two_countdown",
emit=emit.neoNasTwoCountdown(),
}),
tuya.dp_numeric(6,{
name="neo_nas_two_countdown_left",
read_only=true,
emit=emit.neoNasTwoCountdownLeft(),
}),
tuya.dp_battery(11,{read_only=true,emit=emit.battery()}),
tuya.dp_bitmap(19,{
name="fault",
read_only=true,
emit=emit.hardware_fault(),
converter=fault_converter,
}),
tuya.dp_numeric(101,{
name="neo_nas_two_on_countdown",
emit=emit.neoNasTwoOnCountdown(),
}),
tuya.dp_binary(104,{
name="neo_nas_two_child_lock",
emit=emit.neoNasTwoChildLock(),
converter=child_lock_converter,
}),
tuya.dp_numeric(106,{
name="neo_nas_two_last_duration",
read_only=true,
emit=emit.neoNasTwoLastDuration(),
}),
tuya.dp_binary(107,{
name="neo_nas_two_refresh",
emit=emit.neoNasTwoRefresh(),
converter=refresh_converter,
}),
}
register_device_definition(definition,{
{manufacturer="_TZE204_a9ojznj8",model="TS0601"},
{manufacturer="_TZE284_a9ojznj8",model="TS0601"},
})
return{
id="neo.nas_wv03b2",
registrations=device_definitions,
}
