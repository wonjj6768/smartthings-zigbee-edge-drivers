local zcl=require "protocol.zcl"
local device_helpers=require "contracts.helpers.family"
local emit=require "capabilities.events.all"
local capabilities=require "st.capabilities"
local device_management=require "st.zigbee.device_management"
local data_types=require "st.zigbee.data_types"
local device_definitions,register_device_definition=device_helpers.definition_registry()
local CLUSTER_SCENES=0x0005
local CLUSTER_MULTI_STATE_INPUT=0x0012
local CLUSTER_NAMRON_PRIVATE_E004=0xE004
local ATTR_PRESENT_VALUE=0x0055
local NAMRON_SIMPLIFY_PENDING_PRESS_FIELD="__namron_simplify_pending_press"
local BUTTON_EVENT_BUILDERS={
pushed=capabilities.button.button.pushed,
double=capabilities.button.button.double,
held=capabilities.button.button.held,
up=capabilities.button.button.up,
down=capabilities.button.button.down,
up_hold=capabilities.button.button.up_hold,
down_hold=capabilities.button.button.down_hold,
}
local SLACKY_ACTIONS={
[0]="hold",
[1]="single",
[2]="double",
[3]="triple",
[4]="quadruple",
[5]="quintuple",
[300]="N/A",
[255]="release",
}
local BUTTON_EVENT_BY_ACTION={
single="pushed",
double="double",
hold="held",
}
local function battery_percent_from_voltage(voltage)
if type(voltage)~="number" then
return voltage
end
local percent=math.floor((((voltage - 2.0)/ 1.0)* 100)+ 0.5)
if percent < 0 then
return 0
end
if percent > 100 then
return 100
end
return percent
end
local function remote_battery_cluster()
return zcl.cluster_attribute(zcl.CLUSTER_POWER_CONFIGURATION,zcl.ATTR_BATTERY_VOLTAGE,{
name="battery",
endpoint=1,
emit=emit.battery(),
scale=10,
from_device=battery_percent_from_voltage,
read_on_configure=true,
})
end
local function passive_battery_voltage_cluster()
return zcl.cluster_attribute(zcl.CLUSTER_POWER_CONFIGURATION,zcl.ATTR_BATTERY_VOLTAGE,{
name="battery_voltage",
endpoint=1,
emit=emit.voltage(),
scale=10,
})
end
local function ewelink_battery_voltage_cluster()
return zcl.cluster_attribute(zcl.CLUSTER_POWER_CONFIGURATION,zcl.ATTR_BATTERY_VOLTAGE,{
name="battery_voltage",
endpoint=1,
emit=emit.voltage(),
scale=10,
data_type=data_types.Uint8,
minimum_interval=3600,
maximum_interval=7200,
reportable_change=100,
read_on_configure=true,
read_only=true,
})
end
local function component_for_endpoint(endpoint)
return endpoint==1 and "main" or("button" .. tostring(endpoint))
end
local function emit_button_action(device,component_id,action)
local button_action=BUTTON_EVENT_BY_ACTION[action]
local builder=button_action and BUTTON_EVENT_BUILDERS[button_action]or nil
if type(builder)~="function" then
return
end
if type(device.supports_capability_by_id)=="function" and not device:supports_capability_by_id(capabilities.button.ID,component_id)then
return
end
device:emit_component_event({id=component_id},builder({state_change=true}))
zcl.schedule_battery_refresh_after_button(device)
end
local function slacky_multistate_action_cluster(endpoint)
local component_id=component_for_endpoint(endpoint)
return zcl.cluster_attribute(CLUSTER_MULTI_STATE_INPUT,ATTR_PRESENT_VALUE,{
name="remote_action",
endpoint=endpoint,
component=component_id,
emit=emit.remote_action(),
from_device=function(value)
local action=SLACKY_ACTIONS[value]
if action==nil then
return nil
end
return action .. "_" .. tostring(endpoint)
end,
handler=function(device,action)
if type(action)~="string" then
return
end
emit_button_action(device,component_id,action:match("^([^_]+)"))
end,
})
end
local function append_slacky_action_clusters(clusters,button_count)
for endpoint=1,button_count do
clusters[#clusters + 1]=slacky_multistate_action_cluster(endpoint)
end
end
local function bind_clusters_endpoints(cluster_ids,endpoint_count)
return function(driver,device)
for endpoint=1,endpoint_count do
for _,cluster_id in ipairs(cluster_ids)do
device:send(device_management.build_bind_request(
device,
cluster_id,
driver.environment_info.hub_zigbee_eui,
endpoint
))
end
end
end
end
local function bind_on_off_endpoints(endpoint_count)
return bind_clusters_endpoints({zcl.CLUSTER_ON_OFF},endpoint_count)
end
local function body_member_value(zb_rx,...)
local body=zb_rx and zb_rx.body and zb_rx.body.zcl_body or nil
if type(body)~="table" then
return nil
end
for _,key in ipairs({...})do
local value=body[key]
if type(value)=="table" and value.value ~=nil then
return value.value
end
if value ~=nil then
return value
end
end
return nil
end
local function component_for_button(button_number)
return button_number==1 and "main" or("button" .. tostring(button_number))
end
local function ewelink_button_action(_,cluster_id,command_id)
if cluster_id ~=zcl.CLUSTER_ON_OFF then
return nil,nil,true
end
local action=({
[0x02]="single",
[0x01]="double",
[0x00]="long",
})[command_id]
return action,"main",true
end
local function namron_4512772_action(zb_rx,cluster_id,command_id,source_endpoint)
if type(source_endpoint)~="number" or source_endpoint < 1 or source_endpoint > 4 then
return nil,nil,true
end
local action=nil
if cluster_id==zcl.CLUSTER_ON_OFF then
action=({
[0x01]="on",
[0x00]="off",
})[command_id]
elseif cluster_id==zcl.CLUSTER_LEVEL_CONTROL then
if command_id==0x01 or command_id==0x05 then
local move_mode=body_member_value(zb_rx,"move_mode","movemode","mode")
action=move_mode==0 and "brightness_move_up" or move_mode==1 and "brightness_move_down" or nil
elseif command_id==0x03 or command_id==0x07 then
action="brightness_stop"
end
end
if action==nil then
return nil,nil,true
end
return action .. "_l" .. tostring(source_endpoint),component_for_button(source_endpoint),true
end
local function namron_4512793_action(zb_rx,cluster_id,command_id,source_endpoint,device)
if cluster_id ~=CLUSTER_NAMRON_PRIVATE_E004 or command_id ~=0x00 or source_endpoint ~=1 then
return nil,nil,true
end
local body=zb_rx and zb_rx.body and zb_rx.body.zcl_body or nil
local body_bytes=type(body)=="table" and body.body_bytes or nil
if type(body_bytes)~="string" or #body_bytes < 2 then
return nil,nil,true
end
local physical_button=string.byte(body_bytes,#body_bytes - 1)
local raw_action=string.byte(body_bytes,#body_bytes)
if physical_button==nil or physical_button < 1 or physical_button > 6 then
return nil,nil,true
end
local rocker=math.floor((physical_button + 1)/ 2)
local direction=physical_button % 2==1 and "up" or "down"
local component_id=component_for_button(rocker)
if raw_action==0 then
if type(device)=="table" and type(device.set_field)=="function" then
device:set_field(NAMRON_SIMPLIFY_PENDING_PRESS_FIELD,physical_button,{persist=false})
end
return direction .. "_press",component_id,true
end
if raw_action==1 then
local pending_press=type(device)=="table" and type(device.get_field)=="function" and
device:get_field(NAMRON_SIMPLIFY_PENDING_PRESS_FIELD)or nil
if pending_press==physical_button and type(device)=="table" and type(device.set_field)=="function" then
device:set_field(NAMRON_SIMPLIFY_PENDING_PRESS_FIELD,nil,{persist=false})
end
if pending_press==physical_button then
return nil,component_id,true
end
if pending_press ~=nil then
if type(device)=="table" and type(device.set_field)=="function" then
device:set_field(NAMRON_SIMPLIFY_PENDING_PRESS_FIELD,nil,{persist=false})
end
return nil,component_id,true
end
return direction .. "_press",component_id,true
end
if raw_action==2 then
if type(device)=="table" and type(device.set_field)=="function" then
device:set_field(NAMRON_SIMPLIFY_PENDING_PRESS_FIELD,nil,{persist=false})
end
return direction .. "_hold",component_id,true
end
return nil,component_id,true
end
local function shelly_button_tough_action(_,cluster_id,command_id,source_endpoint)
local endpoint_action={
[1]="single",
[2]="double",
[3]="triple",
}
if cluster_id==zcl.CLUSTER_ON_OFF and command_id==0x02 then
return endpoint_action[source_endpoint],"main",true
end
if cluster_id==CLUSTER_SCENES and command_id==0x05 then
local action=endpoint_action[source_endpoint]
return action and(action .. "_long")or nil,"main",true
end
return nil,nil,true
end
local function shelly_four_button_action(zb_rx,cluster_id,command_id,source_endpoint)
local button_number=nil
local action_suffix=nil
if cluster_id==zcl.CLUSTER_ON_OFF then
if command_id==0x01 then
button_number=source_endpoint==1 and 1 or source_endpoint==2 and 3 or nil
elseif command_id==0x00 then
button_number=source_endpoint==1 and 2 or source_endpoint==2 and 4 or nil
elseif command_id==0x02 and source_endpoint ~=nil and source_endpoint >=1 and source_endpoint <=4 then
button_number=source_endpoint
end
action_suffix="single"
elseif cluster_id==zcl.CLUSTER_LEVEL_CONTROL and(command_id==0x02 or command_id==0x06)then
local step_mode=body_member_value(zb_rx,"step_mode","stepmode","mode")
if source_endpoint==1 then
button_number=step_mode==0 and 1 or step_mode==1 and 2 or nil
elseif source_endpoint==2 then
button_number=step_mode==0 and 3 or step_mode==1 and 4 or nil
end
action_suffix="hold"
elseif cluster_id==CLUSTER_SCENES and command_id==0x05 then
local scene_id=body_member_value(zb_rx,"sceneid","scene_id")
if source_endpoint ~=nil and source_endpoint >=1 and source_endpoint <=4 then
button_number=source_endpoint
end
action_suffix=({
[1]="double",
[2]="triple",
[11]="single_long",
[12]="double_long",
[13]="triple_long",
})[scene_id]
end
if button_number==nil or action_suffix==nil then
return nil,nil,true
end
return tostring(button_number).. "_" .. action_suffix,component_for_button(button_number),true
end
local function shelly_one_input_action(zb_rx,cluster_id,command_id,source_endpoint)
if source_endpoint ~=2 then
return nil,nil,true
end
if cluster_id==zcl.CLUSTER_ON_OFF then
return({
[0x01]="input_1_on",
[0x00]="input_1_off",
[0x02]="input_1_toggle",
})[command_id],"main",true
end
if cluster_id==CLUSTER_SCENES and command_id==0x05 then
local scene_id=body_member_value(zb_rx,"sceneid","scene_id")
return({
[1]="input_1_single",
[2]="input_1_double",
[3]="input_1_triple",
[4]="input_1_hold",
[5]="input_1_toggle",
[11]="input_1_hold",
})[scene_id],"main",true
end
return nil,nil,true
end
local function build_advanced_remote(profile,button_count,extra)
local definition={
profile=profile,
button_actions=extra and extra.button_actions or{"pushed","double","held"},
advanced_remote=true,
button_count=button_count,
zcl_initial_writes={
{name="operation_mode",value="event"},
},
zcl_clusters={
zcl.tuya_magic_packet(),
zcl.battery(),
remote_battery_cluster(),
zcl.operation_mode(),
},
}
for key,value in pairs(extra or{})do
definition[key]=value
end
return definition
end
local function build_standard_action_remote(profile,button_count,options)
local definition={
profile=profile,
button_actions=options and options.button_actions or{"pushed","double","held"},
advanced_remote=true,
button_count=button_count,
standard_action_endpoint_suffix=options and options.standard_action_endpoint_suffix==true,
zcl_clusters={
zcl.tuya_magic_packet(),
zcl.battery(),
remote_battery_cluster(),
},
}
if options and options.slacky_multistate==true then
append_slacky_action_clusters(definition.zcl_clusters,button_count)
end
return definition
end
local remote_1=build_advanced_remote("buttons-button-1-battery-operation-mode-remote-action",1,{
unprefixed_remote_actions=true,
})
local remote_4=build_advanced_remote("buttons-button-4-battery-voltage-operation-mode-remote-action",4)
remote_4.zcl_clusters[#remote_4.zcl_clusters + 1]=passive_battery_voltage_cluster()
local remote_6=build_advanced_remote("buttons-button-6-battery-operation-mode-remote-action",6)
local ysr_mini_z=build_advanced_remote("buttons-button-4-battery-operation-mode-remote-action",4)
local knob_remote=build_advanced_remote("buttons-button-1-battery-operation-mode-remote-action",1,{
knob_remote=true,
})
local standard_action_remote_1=build_standard_action_remote("buttons-button-1-battery-remote-action",1,{
button_actions={"pushed","double"},
})
local slacky_remote_1=build_standard_action_remote("buttons-button-1-battery-remote-action",1,{
slacky_multistate=true,
standard_action_endpoint_suffix=true,
})
local slacky_remote_2=build_standard_action_remote("buttons-button-2-battery-remote-action",2,{
slacky_multistate=true,
standard_action_endpoint_suffix=true,
})
local slacky_remote_4=build_standard_action_remote("buttons-button-4-battery-remote-action",4,{
slacky_multistate=true,
standard_action_endpoint_suffix=true,
})
local shelly_remote_control=build_standard_action_remote("buttons-button-4-battery-remote-action",4,{
button_actions={"up","down","up_hold","down_hold"},
})
local shelly_button_tough=build_standard_action_remote("buttons-button-1-battery-remote-action",1,{
button_actions={"pushed","double","pushed_3x","held"},
})
local shelly_four_button=build_standard_action_remote("buttons-button-4-battery-remote-action",4,{
button_actions={"pushed","double","pushed_3x","held"},
})
local shelly_one_input={
profile="buttons-shelly-one-input",
advanced_remote=true,
button_count=1,
button_actions={"pushed","double","pushed_3x","held"},
unprefixed_remote_actions=true,
standard_command_action_resolver=shelly_one_input_action,
standard_action_button_events={
input_1_single="pushed",
input_1_double="double",
input_1_triple="pushed_3x",
input_1_hold="held",
},
zcl_clusters={
zcl.cluster_attribute(0x0007,0x0000,{
name="shelly_one_switch_type",
endpoint=2,
emit=emit.shellyOneSwitchType(),
from_device=function(value)return({[0]="toggle",[1]="momentary"})[value]end,
to_device=function(value)return({toggle=0,momentary=1})[value]end,
data_type=data_types.Enum8,
write_type=data_types.Enum8,
read_on_configure=true,
}),
},
}
shelly_one_input.configure=function(driver,device)
for _,cluster_id in ipairs({zcl.CLUSTER_ON_OFF,CLUSTER_SCENES})do
device:send(device_management.build_bind_request(
device,
cluster_id,
driver.environment_info.hub_zigbee_eui,
2
))
end
end
local ewelink_button=build_standard_action_remote("buttons-ewelink-button-1-battery-voltage-remote-action",1,{
button_actions={"pushed","double","held"},
})
local namron_4512772=build_standard_action_remote("buttons-button-4-battery-remote-action",4,{
button_actions={"up","down","up_hold","down_hold"},
})
local namron_4512793=build_standard_action_remote("buttons-button-3-battery",3,{
button_actions={"up","down","up_hold","down_hold"},
})
remote_1.configure=bind_on_off_endpoints(1)
remote_4.configure=bind_on_off_endpoints(4)
remote_6.configure=bind_on_off_endpoints(6)
ysr_mini_z.configure=bind_on_off_endpoints(1)
knob_remote.configure=bind_on_off_endpoints(1)
standard_action_remote_1.configure=bind_on_off_endpoints(1)
local slacky_command_clusters={
CLUSTER_MULTI_STATE_INPUT,
zcl.CLUSTER_ON_OFF,
zcl.CLUSTER_LEVEL_CONTROL,
zcl.CLUSTER_COLOR_CONTROL,
CLUSTER_SCENES,
}
slacky_remote_1.configure=bind_clusters_endpoints(slacky_command_clusters,1)
slacky_remote_2.configure=bind_clusters_endpoints(slacky_command_clusters,2)
slacky_remote_4.configure=bind_clusters_endpoints(slacky_command_clusters,4)
shelly_button_tough.zcl_clusters={zcl.battery()}
shelly_button_tough.standard_command_action_resolver=shelly_button_tough_action
shelly_button_tough.standard_action_button_events={
single="pushed",
double="double",
triple="pushed_3x",
single_long="held",
}
shelly_button_tough.configure=bind_clusters_endpoints({
zcl.CLUSTER_ON_OFF,
CLUSTER_SCENES,
},3)
shelly_four_button.zcl_clusters={zcl.battery()}
shelly_four_button.standard_command_action_resolver=shelly_four_button_action
shelly_four_button.standard_action_button_events={
["1_single"]="pushed",
["2_single"]="pushed",
["3_single"]="pushed",
["4_single"]="pushed",
["1_double"]="double",
["2_double"]="double",
["3_double"]="double",
["4_double"]="double",
["1_triple"]="pushed_3x",
["2_triple"]="pushed_3x",
["3_triple"]="pushed_3x",
["4_triple"]="pushed_3x",
["1_hold"]="held",
["2_hold"]="held",
["3_hold"]="held",
["4_hold"]="held",
["1_single_long"]="held",
["2_single_long"]="held",
["3_single_long"]="held",
["4_single_long"]="held",
}
shelly_four_button.configure=bind_clusters_endpoints({
zcl.CLUSTER_ON_OFF,
zcl.CLUSTER_LEVEL_CONTROL,
CLUSTER_SCENES,
},4)
ewelink_button.zcl_clusters={
zcl.battery({
endpoint=1,
minimum_interval=3600,
maximum_interval=7200,
reportable_change=2,
}),
ewelink_battery_voltage_cluster(),
}
ewelink_button.standard_command_action_resolver=ewelink_button_action
ewelink_button.standard_action_button_events={
single="pushed",
double="double",
long="held",
}
ewelink_button.configure=bind_on_off_endpoints(1)
namron_4512772.zcl_clusters={
zcl.cluster_attribute(zcl.CLUSTER_POWER_CONFIGURATION,zcl.ATTR_BATTERY_PERCENTAGE_REMAINING,{
name="battery",
endpoint=1,
emit=emit.battery(),
scale=2,
}),
}
namron_4512772.standard_command_action_resolver=namron_4512772_action
namron_4512772.standard_action_button_events={
on_l1="up",
on_l2="up",
on_l3="up",
on_l4="up",
off_l1="down",
off_l2="down",
off_l3="down",
off_l4="down",
brightness_move_up_l1="up_hold",
brightness_move_up_l2="up_hold",
brightness_move_up_l3="up_hold",
brightness_move_up_l4="up_hold",
brightness_move_down_l1="down_hold",
brightness_move_down_l2="down_hold",
brightness_move_down_l3="down_hold",
brightness_move_down_l4="down_hold",
}
namron_4512793.zcl_clusters={
zcl.cluster_attribute(zcl.CLUSTER_POWER_CONFIGURATION,zcl.ATTR_BATTERY_PERCENTAGE_REMAINING,{
name="battery",
endpoint=1,
emit=emit.battery(),
scale=2,
}),
}
namron_4512793.standard_command_action_resolver=namron_4512793_action
namron_4512793.standard_action_button_events={
up_press="up",
down_press="down",
up_hold="up_hold",
down_hold="down_hold",
}
zcl.register_cluster_command_handler(CLUSTER_NAMRON_PRIVATE_E004,0x00,function(device,preset,zb_rx)
if preset ~=namron_4512793 then
return
end
local action,component_id=namron_4512793_action(
zb_rx,
CLUSTER_NAMRON_PRIVATE_E004,
0x00,
1,
device
)
local button_value=action and namron_4512793.standard_action_button_events[action]or nil
local builder=button_value and BUTTON_EVENT_BUILDERS[button_value]or nil
if type(builder)~="function" then
return
end
if type(device.supports_capability_by_id)=="function" and
not device:supports_capability_by_id(capabilities.button.ID,component_id)then
return
end
device:emit_component_event({id=component_id},builder({state_change=true}))
zcl.schedule_battery_refresh_after_button(device)
end)
shelly_remote_control.zcl_clusters={
zcl.battery(),
}
shelly_remote_control.group_component_map={
[0]="main",
[1]="button2",
[2]="button3",
[3]="button4",
}
shelly_remote_control.standard_action_button_events={
on="up",
off="down",
brightness_step_up="up_hold",
brightness_step_down="down_hold",
}
shelly_remote_control.configure=function(driver,device)
device:send(device_management.build_bind_request(
device,
zcl.CLUSTER_ON_OFF,
driver.environment_info.hub_zigbee_eui
))
device:send(device_management.build_bind_request(
device,
zcl.CLUSTER_LEVEL_CONTROL,
driver.environment_info.hub_zigbee_eui
))
for group_id=0,3 do
driver:add_hub_to_zigbee_group(group_id)
end
end
register_device_definition(ysr_mini_z,device_helpers.create_fingerprints("TS004F",{
"_TZ3000_g9g2xnch",
"_TZ3000_pcqjmcud",
}))
register_device_definition(remote_4,device_helpers.create_fingerprints("TS004F",{
"_TZ3000_nuombroo",
"_TZ3000_xabckq1v",
"_TZ3000_czuyt8lz",
"_TZ3000_0ht8dnxj",
"_TZ3000_b3mgfu0d",
"_TZ3000_11pg3ima",
"_TZ3000_et7afzxz",
"_TZ3000_pftj0i7z",
"_TZ3000_xffhmvhv",
}))
register_device_definition(remote_6,device_helpers.create_fingerprints("TS004F",{
"_TZ3000_r0o2dahu",
}))
register_device_definition(remote_1,device_helpers.create_fingerprints("TS004F",{
"_TZ3000_kjfzuycl",
"_TZ3000_ja5osu5g",
"_TZ3000_egvb1p2g",
"_TZ3000_lrfvzq1e",
"_TZ3000_kaflzta4",
"_TZ3000_wc3gjyp3",
"HOBEIAN:ZG-101ZL",
}))
register_device_definition(standard_action_remote_1,device_helpers.create_fingerprints("TS004F",{
"_TZ3000_rco1yzb1",
}))
register_device_definition(slacky_remote_1,{
device_helpers.create_fingerprint("Slacky-DIY","TS0041-M001-SlD"),
device_helpers.create_fingerprint("Slacky-DIY","TS0041-M002-SlD"),
device_helpers.create_fingerprint("Slacky-DIY","TS0041-M005-SlD"),
})
register_device_definition(slacky_remote_2,{
device_helpers.create_fingerprint("Slacky-DIY","TS0042-z-SlD"),
device_helpers.create_fingerprint("Slacky-DIY","TS0042-M003-SlD"),
device_helpers.create_fingerprint("Slacky-DIY","TS0042-M006-SlD"),
})
register_device_definition(slacky_remote_4,{
device_helpers.create_fingerprint("Slacky-DIY","TS0044-z-SlD"),
device_helpers.create_fingerprint("Slacky-DIY","TS0044-M004-SlD"),
})
register_device_definition(shelly_remote_control,{
device_helpers.create_fingerprint("Shelly","BLU Remote Control ZB"),
})
register_device_definition(shelly_button_tough,{
device_helpers.create_fingerprint("Shelly","BLU Button Tough 1 ZB"),
})
register_device_definition(shelly_four_button,{
device_helpers.create_fingerprint("Shelly","BLU RC Button 4 ZB"),
})
register_device_definition(shelly_one_input,{
device_helpers.create_fingerprint("Shelly","1"),
})
register_device_definition(ewelink_button,{
device_helpers.create_fingerprint("eWeLink","CK-TLSR8656-SS5-01(7000)"),
device_helpers.create_fingerprint("eWeLink","WB-01"),
device_helpers.create_fingerprint("eWeLink","SNZB-01"),
device_helpers.create_fingerprint("SONOFF","CK-TLSR8656-SS5-01(7000)"),
device_helpers.create_fingerprint("SONOFF","WB01"),
device_helpers.create_fingerprint("SONOFF","WB-01"),
device_helpers.create_fingerprint("SONOFF","SNZB-01"),
})
register_device_definition(namron_4512772,{
device_helpers.create_fingerprint("Namron","4512772"),
})
register_device_definition(namron_4512793,{
device_helpers.create_fingerprint("Namron AS","4512793"),
})
register_device_definition(knob_remote,device_helpers.create_fingerprints("TS004F",{
"_TZ3000_qja6nq5z",
"_TZ3000_1fqpj6qz",
"_TZ3000_402vrq2i",
"_TZ3000_4fjiwweb",
"_TZ3000_uri7ongn",
"_TZ3000_ixla93vd",
"_TZ3000_csflgqj2",
"_TZ3000_abrsvsou",
"_TZ3000_gwkzibhs",
"_TZ3000_ugi8ky6u",
}))
return{
id="zcl.controls.advanced",
registrations=device_definitions,
}
