local tuya=require "protocol.tuya"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local device_definitions,register_device_definition=device_helpers.definition_registry()
local definition={
profile="valves-qoto-qt05m",
magic_packet=false,
query_on_configure=false,
time_start="off",
auto_connection_status=false,
initial_custom_state_query=false,
refresh_state_query=false,
placeholder_custom_states=false,
tuya.dp_numeric(3,{
name="qoto_qt_five_water_flow",
read_only=true,
emit=emit.qotoQtFiveWaterFlow(),
}),
tuya.dp_numeric(107,{
name="qoto_qt_five_last_duration",
read_only=true,
emit=emit.qotoQtFiveLastDuration(),
}),
tuya.dp_numeric(101,{
name="qoto_qt_five_remaining_time",
read_only=true,
emit=emit.qotoQtFiveRemainingTime(),
}),
tuya.dp_numeric(102,{
name="qoto_qt_five_valve_state",
emit=emit.qotoQtFiveValveState(),
}),
tuya.dp_numeric(2,{
name="qoto_qt_five_valve_auto_state",
emit=emit.all(
emit.qotoQtFiveValveAutoState(),
emit.qotoQtFiveValveState()
),
}),
tuya.dp_numeric(11,{
name="qoto_qt_five_shutdown_timer",
emit=emit.qotoQtFiveShutdownTimer(),
}),
tuya.dp_battery(110,{
read_only=true,
emit=emit.battery(),
}),
}
register_device_definition(definition,{
{manufacturer="_TZE200_arge1ptm",model="TS0601"},
{manufacturer="_TZE200_anv5ujhv",model="TS0601"},
{manufacturer="_TZE200_xlppj4f5",model="TS0601"},
})
return{
id="qoto.qt_05m",
registrations=device_definitions,
}
