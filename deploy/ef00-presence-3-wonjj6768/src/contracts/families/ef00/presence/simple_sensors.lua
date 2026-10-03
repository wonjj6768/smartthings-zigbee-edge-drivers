local tuya=require"protocol.tuya"
local emit=require"capabilities.events.all"
local device_helpers=require"contracts.helpers.family"
local registrations,register_device_definition=device_helpers.definition_registry()
local mowe_mw836p_core={
profile="safety-presence-mw836p-core",
magic_packet=true,
query_on_configure=true,
query_on_announce=true,
announce_delay=0,
time_start="off",
datapoints={
tuya.dp_enum(1,{name="presence",endpoint=1,read_only=true,
converter=tuya.converter.from_only(function(value)return value==1 end),emit=emit.presence()}),
tuya.dp_illuminance(103,{endpoint=1,read_only=true,emit=emit.illuminance()}),},}
register_device_definition(mowe_mw836p_core,{
device_helpers.create_fingerprint("_TZE284_mexuq6lm","TS0601"),})
return{
id="ef00.presence.simple_sensors",
registrations=registrations,}
