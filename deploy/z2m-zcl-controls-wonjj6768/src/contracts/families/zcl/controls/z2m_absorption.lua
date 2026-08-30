local zcl=require "protocol.zcl"
local device_helpers=require "contracts.helpers.family"
local zcl_device_helpers=require "contracts.helpers.zcl"
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
local function slacky_three_standard_action(zb_rx,cluster_id,command_id,source_endpoint)
if type(source_endpoint)~="number" or source_endpoint < 1 or source_endpoint > 3 then
return nil,nil,true
end
local action=nil
if cluster_id==zcl.CLUSTER_ON_OFF then
action=({
[0x00]="off",
[0x01]="on",
[0x02]="toggle",
[0x40]="off",
})[command_id]
elseif cluster_id==zcl.CLUSTER_LEVEL_CONTROL then
if command_id==0x00 or command_id==0x04 then
action="brightness_move_to_level"
elseif command_id==0x01 or command_id==0x05 then
local mode=body_member_value(zb_rx,"move_mode","movemode","mode")
action=mode==1 and "brightness_move_down" or "brightness_move_up"
elseif command_id==0x02 or command_id==0x06 then
local mode=body_member_value(zb_rx,"step_mode","stepmode","mode")
action=mode==1 and "brightness_step_down" or "brightness_step_up"
elseif command_id==0x03 or command_id==0x07 then
action="brightness_stop"
end
elseif cluster_id==zcl.CLUSTER_COLOR_CONTROL then
if command_id==0x4B then
action=({
[0]="color_temperature_move_stop",
[1]="color_temperature_move_up",
[3]="color_temperature_move_down",
})[body_member_value(zb_rx,"move_mode","movemode","mode")]
elseif command_id==0x47 then
action="stop_move_step"
elseif command_id==0x4C then
local mode=body_member_value(zb_rx,"step_mode","stepmode","mode")
action=mode==1 and "color_temperature_step_up" or "color_temperature_step_down"
elseif command_id==0x43 then
action="enhanced_move_to_hue_and_saturation"
elseif command_id==0x06 then
action="move_to_hue_and_saturation"
elseif command_id==0x02 then
local mode=body_member_value(zb_rx,"step_mode","stepmode","mode")
action=mode==1 and "color_hue_step_up" or "color_hue_step_down"
elseif command_id==0x05 then
local mode=body_member_value(zb_rx,"step_mode","stepmode","mode")
action=mode==1 and "color_saturation_step_up" or "color_saturation_step_down"
elseif command_id==0x44 then
action="color_loop_set"
elseif command_id==0x0A then
action="color_temperature_move"
elseif command_id==0x07 then
action="color_move"
elseif command_id==0x01 then
action=({[1]="hue_move",[3]="hue_down"})[
body_member_value(zb_rx,"move_mode","movemode","mode")
]or "hue_stop"
elseif command_id==0x03 then
action="move_to_saturation"
elseif command_id==0x00 then
action="move_to_hue"
end
elseif cluster_id==CLUSTER_SCENES then
local scene_id=body_member_value(zb_rx,"sceneid","scene_id")
if command_id==0x00 then
action="add"
elseif command_id==0x02 then
action="remove"
elseif command_id==0x03 then
action="remove_all"
elseif command_id==0x04 then
action=scene_id ~=nil and("store_" .. tostring(scene_id))or "store"
elseif command_id==0x05 then
action=scene_id ~=nil and("recall_" .. tostring(scene_id))or "recall"
end
end
return action,component_for_endpoint(source_endpoint),true
end
local slacky_remote_3={
profile="buttons-button-3-battery-remote-action-slacky",
button_actions={"pushed","double","held"},
advanced_remote=true,
button_count=3,
standard_action_endpoint_suffix=true,
standard_command_action_resolver=slacky_three_standard_action,
zcl_clusters={
zcl.battery({
endpoint=1,
minimum_interval=3600,
maximum_interval=14400,
reportable_change=0,
read_on_configure=true,
}),
},
}
append_slacky_action_clusters(slacky_remote_3.zcl_clusters,3)
local slacky_switch_action_from={[0]="off",[1]="on",[2]="toggle"}
local slacky_switch_action_to={off=0,on=1,toggle=2}
local slacky_switch_type_from={
[0]="toggle",
[1]="momentary",
[2]="multifunction",
[3]="brightness_level",
[4]="brightness_level_up",
[5]="brightness_level_down",
[6]="move_to_color_temperature",
[7]="move_to_color_temperature_up",
[8]="move_to_color_temperature_down",
[9]="scene",
}
local slacky_switch_type_to={}
for raw,value in pairs(slacky_switch_type_from)do slacky_switch_type_to[value]=raw end
local function slacky_enum_config(name,endpoint,component,cluster_id,attribute_id,emitter,from_values,to_values)
return zcl.cluster_attribute(cluster_id,attribute_id,{
name=name,
endpoint=endpoint,
component=component,
emit=emitter,
from_device=function(value)return from_values[value]end,
to_device=function(value)return to_values[value]end,
data_type=data_types.Enum8,
write_type=data_types.Enum8,
read_on_configure=true,
})
end
local function slacky_numeric_config(name,endpoint,component,cluster_id,attribute_id,emitter,data_type)
return zcl.cluster_attribute(cluster_id,attribute_id,{
name=name,
endpoint=endpoint,
component=component,
emit=emitter,
data_type=data_type,
write_type=data_type,
read_on_configure=true,
})
end
local SLACKY_THREE_EMITTERS={
[1]={
switch_action=emit.slackyThreeSwitchActionOne(),
switch_type=emit.slackyThreeSwitchTypeOne(),
scene_id=emit.slackyThreeSceneIdOne(),
group_id=emit.slackyThreeGroupIdOne(),
min_level=emit.slackyThreeMinLevelOne(),
max_level=emit.slackyThreeMaxLevelOne(),
},
[2]={
switch_action=emit.slackyThreeSwitchActionTwo(),
switch_type=emit.slackyThreeSwitchTypeTwo(),
scene_id=emit.slackyThreeSceneIdTwo(),
group_id=emit.slackyThreeGroupIdTwo(),
min_level=emit.slackyThreeMinLevelTwo(),
max_level=emit.slackyThreeMaxLevelTwo(),
},
[3]={
switch_action=emit.slackyThreeSwitchActionThree(),
switch_type=emit.slackyThreeSwitchTypeThree(),
scene_id=emit.slackyThreeSceneIdThree(),
group_id=emit.slackyThreeGroupIdThree(),
min_level=emit.slackyThreeMinLevelThree(),
max_level=emit.slackyThreeMaxLevelThree(),
},
}
for endpoint=1,3 do
local word=({"One","Two","Three"})[endpoint]
local suffix=word:lower()
local component=endpoint==1 and "main" or("button" .. endpoint)
local emitters=SLACKY_THREE_EMITTERS[endpoint]
slacky_remote_3.zcl_clusters[#slacky_remote_3.zcl_clusters + 1]=slacky_enum_config(
"slacky3_switch_action_" .. suffix,
endpoint,
component,
0x0007,
0x0010,
emitters.switch_action,
slacky_switch_action_from,
slacky_switch_action_to
)
slacky_remote_3.zcl_clusters[#slacky_remote_3.zcl_clusters + 1]=slacky_enum_config(
"slacky3_switch_type_" .. suffix,
endpoint,
component,
0x0007,
0xF000,
emitters.switch_type,
slacky_switch_type_from,
slacky_switch_type_to
)
slacky_remote_3.zcl_clusters[#slacky_remote_3.zcl_clusters + 1]=slacky_numeric_config(
"slacky3_scene_id_" .. suffix,endpoint,component,0x0005,0xF000,
emitters.scene_id,data_types.Uint8
)
slacky_remote_3.zcl_clusters[#slacky_remote_3.zcl_clusters + 1]=slacky_numeric_config(
"slacky3_group_id_" .. suffix,endpoint,component,0x0005,0xF001,
emitters.group_id,data_types.Uint16
)
slacky_remote_3.zcl_clusters[#slacky_remote_3.zcl_clusters + 1]=slacky_numeric_config(
"slacky3_min_level_" .. suffix,endpoint,component,zcl.CLUSTER_LEVEL_CONTROL,0x0002,
emitters.min_level,data_types.Uint8
)
slacky_remote_3.zcl_clusters[#slacky_remote_3.zcl_clusters + 1]=slacky_numeric_config(
"slacky3_max_level_" .. suffix,endpoint,component,zcl.CLUSTER_LEVEL_CONTROL,0x0003,
emitters.max_level,data_types.Uint8
)
end
local slacky_command_clusters={
CLUSTER_MULTI_STATE_INPUT,
zcl.CLUSTER_ON_OFF,
zcl.CLUSTER_LEVEL_CONTROL,
zcl.CLUSTER_COLOR_CONTROL,
CLUSTER_SCENES,
}
slacky_remote_3.configure=bind_clusters_endpoints(slacky_command_clusters,3)
register_device_definition(slacky_remote_3,{
device_helpers.create_fingerprint("Slacky-DIY","TS0043-z-SlD"),
device_helpers.create_fingerprint("Slacky-DIY","TS0043-M007-SlD"),
})
local function bind_clusters(driver,device,endpoint,cluster_ids)
for _,cluster_id in ipairs(cluster_ids)do
device:send(device_management.build_bind_request(
device,
cluster_id,
driver.environment_info.hub_zigbee_eui,
endpoint
))
end
end
local candeo_rd1p_remote={
profile="controllers-candeo-rd1p-rem",
advanced_remote=true,
unprefixed_remote_actions=true,
remote_action_emit_name="candeoRd1pRemAction",
standard_command_action_resolver=zcl_device_helpers.resolve_rd1p_rotary_action,
zcl_clusters={
zcl.power({
endpoint=1,
minimum_interval=5,
maximum_interval=300,
reportable_change=10,
}),
zcl.voltage({
endpoint=1,
minimum_interval=5,
maximum_interval=600,
reportable_change=500,
}),
zcl.current({
endpoint=1,
minimum_interval=5,
maximum_interval=900,
reportable_change=10,
}),
zcl.energy({
endpoint=1,
minimum_interval=5,
maximum_interval=1800,
reportable_change=50,
}),
},
configure=function(driver,device)
bind_clusters(driver,device,2,{
zcl.CLUSTER_ON_OFF,
zcl.CLUSTER_LEVEL_CONTROL,
})
end,
}
register_device_definition(candeo_rd1p_remote,{
device_helpers.create_fingerprint("Candeo","C-ZB-RD1Pv2-REM"),
})
return{
id="zcl.controls.z2m_absorption",
registrations=device_definitions,
}
