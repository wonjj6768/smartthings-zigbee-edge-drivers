local tuya=require"protocol.tuya"
local emit=require"capabilities.events.all"
local device_helpers=require"contracts.helpers.family"
local registrations,register_device_definition=device_helpers.definition_registry()local oxt_four={
profile="switches-oxt-four",magic_packet=true,mcu_version_request_on_configure=true,query_on_configure=false,query_on_announce=false,initial_custom_state_query=false,refresh_state_query=false,time_start="off",placeholder_custom_states=false,component_to_endpoint_map={main=1,switch2=1,switch3=1,switch4=1},endpoint_to_component_map={[1]="main"},datapoints={},}for index,word in ipairs({"One","Two","Three","Four"})do
local component=index==1 and"main"or"switch"..index
local suffix=word:lower()oxt_four.datapoints[#oxt_four.datapoints+1]=tuya.dp_on_off(index,{
name="switch",component=component,endpoint=1,emit=emit.switch(),})oxt_four.datapoints[#oxt_four.datapoints+1]=tuya.dp_numeric(index+6,{
name="oxt4_countdown_"..suffix,component=component,endpoint=1,emit=emit["oxt4Channel"..word .."Countdown"](),})oxt_four.datapoints[#oxt_four.datapoints+1]=tuya.dp_numeric(index+13,{
name="oxt4_power_on_behavior_"..suffix,component=component,endpoint=1,converter=tuya.converter.lookup_from_to({off=0,on=1,previous=2}),emit=emit["oxt4Channel"..word .."PowerOnBehavior"](),})
end
register_device_definition(oxt_four,{
device_helpers.create_fingerprint("_TZE28C1000000_f5efvtbv","TS0601"),device_helpers.create_fingerprint("_TZE204_m9dzckna","TS0601"),})return{
id="ef00.switch.oxt4",registrations=registrations,}
