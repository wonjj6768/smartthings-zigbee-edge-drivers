local tuya=require "protocol.tuya"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local capabilities=require "st.capabilities"
local device_definitions,register_device_definition=device_helpers.definition_registry()
local function custom(capability_id)
return assert(emit[capability_id],"missing Wave17 CZF02 emitter: " .. capability_id)()
end
local switch_states_emitter=custom("lincukooCzfSwitchStates")
local function reset_switch_states(device,_,dp_info,mapping_context)
local event=switch_states_emitter(device,"idle",dp_info,mapping_context)
if event ~=nil then
device:emit_event(event)
end
end
local function switch_states_to_device(value,device)
if value ~="SWITCH" then
return nil
end
local state=device:get_latest_state("main",capabilities.switch.ID,"switch")
if state=="on" then
return false
end
if state=="off" then
return true
end
return nil
end
local czf_zero_two={
profile="controls-wave17-lincukoo-czf02",
package_group="finger-robot",
transport_classification="EF00_DP",
z2m_converter_source="meta.tuyaDatapoints",
wire_cluster="manuSpecificTuya",
magic_packet=true,
query_on_configure=true,
time_start="off",
datapoints={
tuya.dp_on_off(1,{
name="switch",
component="main",
transaction=1,
handler=reset_switch_states,
emit=emit.switch(),
}),
tuya.dp_enum(2,{
name="lincukoo_czf_mode",
transaction=1,
converter=tuya.converter.lookup_from_to({button=0,switch=1}),
emit=custom("lincukooCzfMode"),
}),
tuya.dp_numeric(3,{
name="lincukoo_czf_button_hold_duration",
transaction=1,
converter=tuya.converter.divide_by_pair(10),
emit=custom("lincukooCzfButtonHoldDuration"),
}),
tuya.dp_numeric(5,{
name="lincukoo_czf_arm_end_position",
transaction=1,
emit=custom("lincukooCzfArmEndPosition"),
}),
tuya.dp_numeric(6,{
name="lincukoo_czf_arm_start_position",
transaction=1,
emit=custom("lincukooCzfArmStartPosition"),
}),
tuya.dp_battery(8,{
name="battery",
read_only=true,
transaction=1,
emit=emit.battery(),
}),
tuya.dp_binary(101,{
name="lincukoo_czf_auto_adjustment",
transaction=1,
converter=tuya.converter.from_to(
function()return "idle" end,
function(value)return value=="START" end
),
emit=custom("lincukooCzfAutoAdjustment"),
}),
tuya.dp_binary(102,{
name="lincukoo_czf_switch_states",
transaction=1,
converter=tuya.converter.from_to(
function()return "idle" end,
switch_states_to_device
),
emit=switch_states_emitter,
}),
},
}
register_device_definition(czf_zero_two,device_helpers.create_fingerprints("TS0601",{
"_TZE284_gw05grph",
"_TZE284_chcnj5st",
"_TZE284_pislt0wa",
}))
return{
id="ef00.controls.wave17_fingerbot",
registrations=device_definitions,
}
