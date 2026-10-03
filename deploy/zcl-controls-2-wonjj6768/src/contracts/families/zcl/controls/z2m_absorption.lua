local zcl=require"protocol.zcl"
local device_helpers=require"contracts.helpers.family"
local zcl_device_helpers=require"contracts.helpers.zcl"
local emit=require"capabilities.events.all"
local capabilities=require"st.capabilities"
local device_management=require"st.zigbee.device_management"
local data_types=require"st.zigbee.data_types"
local cluster_base=require"st.zigbee.cluster_base"
local buf=require"st.buf"
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
down_hold=capabilities.button.button.down_hold,}
local SLACKY_ACTIONS={
[0]="hold",
[1]="single",
[2]="double",
[3]="triple",
[4]="quadruple",
[5]="quintuple",
[300]="N/A",
[255]="release",}
local BUTTON_EVENT_BY_ACTION={
single="pushed",
double="double",
hold="held",}
local function issue10_battery_percent_from_voltage(voltage)
if type(voltage)~="number"then return voltage end
local percent=math.floor((((voltage-2.0)/1.0)*100)+0.5)
if percent<0 then return 0 end
if percent>100 then return 100 end
return percent
end
local issue10_remote_3={
profile="buttons-button-3-battery",
button_actions={"pushed","double","held"},
zcl_clusters={
zcl.tuya_magic_packet(),
zcl.cluster_attribute(
zcl.CLUSTER_POWER_CONFIGURATION,
zcl.ATTR_BATTERY_PERCENTAGE_REMAINING,
{name="battery",endpoint=1,emit=emit.battery(),scale=2}),
zcl.cluster_attribute(
zcl.CLUSTER_POWER_CONFIGURATION,
zcl.ATTR_BATTERY_VOLTAGE,
{
name="battery",
endpoint=1,
emit=emit.battery(),
scale=10,
from_device=issue10_battery_percent_from_voltage,}),},}
register_device_definition(issue10_remote_3,{
device_helpers.create_fingerprint("_TZ3000_9zc1ilmb","TS0043"),})
local function component_for_endpoint(endpoint)
return endpoint==1 and"main"or("button"..tostring(endpoint))
end
local function emit_button_action(device,component_id,action)
local button_action=BUTTON_EVENT_BY_ACTION[action]
local builder=button_action and BUTTON_EVENT_BUILDERS[button_action]or nil
if type(builder)~="function"then
return
end
if type(device.supports_capability_by_id)=="function"and not device:supports_capability_by_id(capabilities.button.ID,component_id)then
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
return action.."_"..tostring(endpoint)
end,
handler=function(device,action)
if type(action)~="string"then
return
end
emit_button_action(device,component_id,action:match("^([^_]+)"))
end,
})
end
local function append_slacky_action_clusters(clusters,button_count)
for endpoint=1,button_count do
clusters[#clusters+1]=slacky_multistate_action_cluster(endpoint)
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
endpoint))
end
end
end
end
local function body_member_value(zb_rx,...)
local body=zb_rx and zb_rx.body and zb_rx.body.zcl_body or nil
if type(body)~="table"then
return nil
end
for _,key in ipairs({...})do
local value=body[key]
if type(value)=="table"and value.value~=nil then
return value.value
end
if value~=nil then
return value
end
end
return nil
end
local LINXURA_ACTIONS={
[0]={name="click",button_event="pushed"},
[2]={name="double_click",button_event="double"},
[4]={name="hold",button_event="held"},}
local function decode_linxura_zone_status(zone_status,button_count)
if type(zone_status)=="table"and zone_status.value~=nil then
zone_status=zone_status.value
end
if type(zone_status)~="number"or zone_status%1~=0 or
zone_status<1 or zone_status>(button_count*6)-1 then
return nil
end
local offset=(zone_status-1)%6
local action=LINXURA_ACTIONS[offset]
if action==nil then
return nil
end
local button_number=math.floor((zone_status-1)/6)+1
return{
action="button_"..tostring(button_number).."_"..action.name,
button_event=action.button_event,
component=button_number==1 and"main"or("button"..tostring(button_number)),}
end
local function linxura_action_mapping(button_count,has_battery)
return zcl.cluster_attribute(zcl.CLUSTER_IAS_ZONE,zcl.ATTR_ZONE_STATUS,{
name="linxura_button_action_"..tostring(button_count),
endpoint=1,
read_only=true,
command_id=0x00,
command_extractor=function(zb_rx)
return body_member_value(zb_rx,"zonestatus","zone_status")
end,
from_device=function(value)
return decode_linxura_zone_status(value,button_count)
end,
handler=function(device,decoded)
if type(decoded)~="table"then
return
end
if type(device.supports_capability_by_id)=="function"and
not device:supports_capability_by_id(capabilities.button.ID,decoded.component)then
return
end
device:emit_component_event(
{id=decoded.component},
capabilities.button.button(decoded.button_event,{state_change=true}))
if has_battery then
zcl.schedule_battery_refresh_after_button(device)
end
end,
})
end
local function configure_linxura_ias(driver,device)
device:send(device_management.build_bind_request(
device,
zcl.CLUSTER_IAS_ZONE,
driver.environment_info.hub_zigbee_eui,
1))
end
local linxura_aura_12={
profile="buttons-button-12-battery",
button_actions={"pushed","double","held"},
button_count=12,
zcl_clusters={
linxura_action_mapping(12,true),
zcl.battery({
endpoint=1,
minimum_interval=3600,
maximum_interval=0,
reportable_change=1,
read_on_configure=true,}),},
configure=configure_linxura_ias,}
local linxura_smart_4={
profile="buttons-button-4",
button_actions={"pushed","double","held"},
button_count=4,
zcl_clusters={
linxura_action_mapping(4,false),},
configure=configure_linxura_ias,}
register_device_definition(linxura_aura_12,{
device_helpers.create_fingerprint("Linxura","Aura Smart Button"),})
register_device_definition(linxura_smart_4,{
device_helpers.create_fingerprint("Linxura","Smart Controller"),})
local function component_for_button(button_number)
return button_number==1 and"main"or("button"..tostring(button_number))
end
local function slacky_three_standard_action(zb_rx,cluster_id,command_id,source_endpoint)
if type(source_endpoint)~="number"or source_endpoint<1 or source_endpoint>3 then
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
action=mode==1 and"brightness_move_down"or"brightness_move_up"
elseif command_id==0x02 or command_id==0x06 then
local mode=body_member_value(zb_rx,"step_mode","stepmode","mode")
action=mode==1 and"brightness_step_down"or"brightness_step_up"
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
action=mode==1 and"color_temperature_step_up"or"color_temperature_step_down"
elseif command_id==0x43 then
action="enhanced_move_to_hue_and_saturation"
elseif command_id==0x06 then
action="move_to_hue_and_saturation"
elseif command_id==0x02 then
local mode=body_member_value(zb_rx,"step_mode","stepmode","mode")
action=mode==1 and"color_hue_step_up"or"color_hue_step_down"
elseif command_id==0x05 then
local mode=body_member_value(zb_rx,"step_mode","stepmode","mode")
action=mode==1 and"color_saturation_step_up"or"color_saturation_step_down"
elseif command_id==0x44 then
action="color_loop_set"
elseif command_id==0x0A then
action="color_temperature_move"
elseif command_id==0x07 then
action="color_move"
elseif command_id==0x01 then
action=({[1]="hue_move",[3]="hue_down"})[
body_member_value(zb_rx,"move_mode","movemode","mode")
]or"hue_stop"
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
action=scene_id~=nil and("store_"..tostring(scene_id))or"store"
elseif command_id==0x05 then
action=scene_id~=nil and("recall_"..tostring(scene_id))or"recall"
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
read_on_configure=true,}),},}
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
[9]="scene",}
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
read_on_configure=true,})
end
local function slacky_numeric_config(name,endpoint,component,cluster_id,attribute_id,emitter,data_type)
return zcl.cluster_attribute(cluster_id,attribute_id,{
name=name,
endpoint=endpoint,
component=component,
emit=emitter,
data_type=data_type,
write_type=data_type,
read_on_configure=true,})
end
local SLACKY_THREE_EMITTERS={
[1]={
switch_action=emit.slackyThreeSwitchActionOne(),
switch_type=emit.slackyThreeSwitchTypeOne(),
scene_id=emit.slackyThreeSceneIdOne(),
group_id=emit.slackyThreeGroupIdOne(),
min_level=emit.slackyThreeMinLevelOne(),
max_level=emit.slackyThreeMaxLevelOne(),},
[2]={
switch_action=emit.slackyThreeSwitchActionTwo(),
switch_type=emit.slackyThreeSwitchTypeTwo(),
scene_id=emit.slackyThreeSceneIdTwo(),
group_id=emit.slackyThreeGroupIdTwo(),
min_level=emit.slackyThreeMinLevelTwo(),
max_level=emit.slackyThreeMaxLevelTwo(),},
[3]={
switch_action=emit.slackyThreeSwitchActionThree(),
switch_type=emit.slackyThreeSwitchTypeThree(),
scene_id=emit.slackyThreeSceneIdThree(),
group_id=emit.slackyThreeGroupIdThree(),
min_level=emit.slackyThreeMinLevelThree(),
max_level=emit.slackyThreeMaxLevelThree(),},}
for endpoint=1,3 do
local word=({"One","Two","Three"})[endpoint]
local suffix=word:lower()
local component=endpoint==1 and"main"or("button"..endpoint)
local emitters=SLACKY_THREE_EMITTERS[endpoint]
slacky_remote_3.zcl_clusters[#slacky_remote_3.zcl_clusters+1]=slacky_enum_config(
"slacky3_switch_action_"..suffix,
endpoint,
component,
0x0007,
0x0010,
emitters.switch_action,
slacky_switch_action_from,
slacky_switch_action_to)
slacky_remote_3.zcl_clusters[#slacky_remote_3.zcl_clusters+1]=slacky_enum_config(
"slacky3_switch_type_"..suffix,
endpoint,
component,
0x0007,
0xF000,
emitters.switch_type,
slacky_switch_type_from,
slacky_switch_type_to)
slacky_remote_3.zcl_clusters[#slacky_remote_3.zcl_clusters+1]=slacky_numeric_config(
"slacky3_scene_id_"..suffix,endpoint,component,0x0005,0xF000,
emitters.scene_id,data_types.Uint8)
slacky_remote_3.zcl_clusters[#slacky_remote_3.zcl_clusters+1]=slacky_numeric_config(
"slacky3_group_id_"..suffix,endpoint,component,0x0005,0xF001,
emitters.group_id,data_types.Uint16)
slacky_remote_3.zcl_clusters[#slacky_remote_3.zcl_clusters+1]=slacky_numeric_config(
"slacky3_min_level_"..suffix,endpoint,component,zcl.CLUSTER_LEVEL_CONTROL,0x0002,
emitters.min_level,data_types.Uint8)
slacky_remote_3.zcl_clusters[#slacky_remote_3.zcl_clusters+1]=slacky_numeric_config(
"slacky3_max_level_"..suffix,endpoint,component,zcl.CLUSTER_LEVEL_CONTROL,0x0003,
emitters.max_level,data_types.Uint8)
end
local slacky_command_clusters={
CLUSTER_MULTI_STATE_INPUT,
zcl.CLUSTER_ON_OFF,
zcl.CLUSTER_LEVEL_CONTROL,
zcl.CLUSTER_COLOR_CONTROL,
CLUSTER_SCENES,}
slacky_remote_3.configure=bind_clusters_endpoints(slacky_command_clusters,3)
register_device_definition(slacky_remote_3,{
device_helpers.create_fingerprint("Slacky-DIY","TS0043-z-SlD"),
device_helpers.create_fingerprint("Slacky-DIY","TS0043-M007-SlD"),})
local function bind_clusters(driver,device,endpoint,cluster_ids)
for _,cluster_id in ipairs(cluster_ids)do
device:send(device_management.build_bind_request(
device,
cluster_id,
driver.environment_info.hub_zigbee_eui,
endpoint))
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
reportable_change=10,}),
zcl.voltage({
endpoint=1,
minimum_interval=5,
maximum_interval=600,
reportable_change=500,}),
zcl.current({
endpoint=1,
minimum_interval=5,
maximum_interval=900,
reportable_change=10,}),
zcl.energy({
endpoint=1,
minimum_interval=5,
maximum_interval=1800,
reportable_change=50,}),},
configure=function(driver,device)
bind_clusters(driver,device,2,{
zcl.CLUSTER_ON_OFF,
zcl.CLUSTER_LEVEL_CONTROL,})
end,
}
register_device_definition(candeo_rd1p_remote,{
device_helpers.create_fingerprint("Candeo","C-ZB-RD1Pv2-REM"),})
local function h1_battery_events(_,value)
if type(value)=="string"then
local reader=buf.Reader(value)
while reader:remain()>1 do
local key,kind=reader:read_u8(),reader:read_u8()
local width=kind==0x10 and 1 or
(kind>=0x20 and kind<=0x2F and((kind%8)+1))or
(kind==0x39 and 4)or(kind==0x3A and 8)
if width==nil or reader:remain()<width then return nil end
if key==1 then
value=data_types.parse_data_type(kind,reader).value
break
end
reader:seek(width)
end
elseif type(value)=="table"then
value=value[1]or value["1"]
value=type(value)=="table"and value.value or value
end
if type(value)~="number"or value==0 then return nil end
local percent=math.max(0,math.min(100,((value-2850)*100)/150))
return{
capabilities.battery.battery(math.floor(percent+0.5)),
capabilities.voltageMeasurement.voltage({value=value/1000,unit="V"}),}
end
local h1_action_emitter=emit.aqH1Action()
local function h1_action_event(device,action)
local event=h1_action_emitter(device,action)
event.state_change=true
device:emit_component_event({id="main"},event)
local button_action=BUTTON_EVENT_BY_ACTION[action]
if button_action~=nil then
device:emit_component_event({id="main"},capabilities.button.button(button_action,{state_change=true}))
end
end
local function h1_rotation_value(value,_,context)
local records=context.zb_rx.body.zcl_body.attr_records or{}
for _,record in ipairs(records)do
if record.attr_id.value==0x023A then
return type(value)=="table"and value.value or value
end
end
return nil
end
local aqara_h1_knob={
profile="controllers-aqara-h1",
button_actions={"pushed","double","held"},
zcl_clusters={
zcl.cluster_attribute(0x0012,0x0055,{
name="aq_h1_action",endpoint=1,read_only=true,handler=h1_action_event,
from_device=function(value)
return({[0]="hold",[1]="single",[2]="double",[255]="release"})[value]
end,
}),
zcl.cluster_attribute(0xFCC0,0x023A,{
name="aq_h1_action",endpoint=1,read_only=true,handler=h1_action_event,
from_device=function(value)
return({[1]="start_rotating",[2]="rotation",[3]="stop_rotating"})[value&~128]
end,
}),
zcl.cluster_attribute(0xFCC0,0x023A,{
name="aq_h1_rotation_button_state",endpoint=1,read_only=true,
emit=emit.aqH1RotationButtonState(),
from_device=function(value)return(value&128)==128 and"pressed"or"released"end,
}),
zcl.cluster_attribute(0xFCC0,0x0001,{
name="aq_h1_battery_voltage",endpoint=1,read_only=true,emit=h1_battery_events,}),
zcl.cluster_attribute(0xFCC0,0x00F7,{
name="aq_h1_battery_struct",endpoint=1,read_only=true,emit=h1_battery_events,}),
zcl.cluster_attribute(0xFCC0,0xFF01,{
name="aq_h1_battery_nested",endpoint=1,read_only=true,emit=h1_battery_events,}),
zcl.cluster_attribute(0xFCC0,0x0009,{
name="aq_h1_operation_mode",endpoint=1,write_only=true,
mfg_code=0x115F,data_type=data_types.Uint8,write_type=data_types.Uint8,
emit=emit.aqH1OperationMode(),
to_device=function(value)return({event=1,command=0})[value]end,
}),
zcl.cluster_attribute(0xFCC0,0x0234,{
name="aq_h1_sensitivity",endpoint=1,
data_type=data_types.Uint16,write_type=data_types.Uint16,emit=emit.aqH1Sensitivity(),
from_device=function(value)return({[720]="low",[360]="medium",[180]="high"})[value]end,
to_device=function(value)return({low=720,medium=360,high=180})[value]end,
sender=function(device,mapping,value)
device:send(cluster_base.write_manufacturer_specific_attribute(device,0xFCC0,0x0234,
0x115F,data_types.Uint16,mapping.to_device(value)):to_endpoint(1))
end,
}),
zcl.cluster_attribute(0x0000,0xFFF0,{
name="aq_h1_prevent_reset",endpoint=1,read_only=true,
handler=function(device,value,context)
if context.zb_rx.body.zcl_header.cmd.value==0x0A and
type(value)=="string"and value:sub(1,5)==string.char(0xAA,0x10,0x05,0x41,0x87)then
device:send(cluster_base.write_manufacturer_specific_attribute(device,0x0000,0xFFF0,
0x115F,data_types.OctetString,string.char(0xAA,0x10,0x05,0x41,0x47,1,1,0x10,1)):to_endpoint(1))
end
end,
}),},
configure=function(_,device)
device:send(cluster_base.write_manufacturer_specific_attribute(device,0xFCC0,0x0009,
0x115F,data_types.Uint8,1):to_endpoint(1))
zcl.read_attribute(device,0xFCC0,0x0234,1)
end,
parent_refresh=function(device)
zcl.read_attribute(device,0xFCC0,0x0009,1,0x115F)
zcl.read_attribute(device,0xFCC0,0x0234,1,0x115F)
end,
}
for _,entry in ipairs({
{0x022E,"aq_h1_rotation_angle",emit.aqH1RotationAngle()},
{0x0230,"aq_h1_rotation_angle_speed",emit.aqH1RotationAngleSpeed()},
{0x0233,"aq_h1_rotation_percent",emit.aqH1RotationPercent()},
{0x0232,"aq_h1_rotation_percent_speed",emit.aqH1RotationPercentSpeed()},
{0x0231,"aq_h1_rotation_time",emit.aqH1RotationTime()},
})do
aqara_h1_knob.zcl_clusters[#aqara_h1_knob.zcl_clusters+1]=zcl.cluster_attribute(0xFCC0,entry[1],{
name=entry[2],endpoint=1,read_only=true,emit=entry[3],from_device=h1_rotation_value,})
end
register_device_definition(aqara_h1_knob,{
device_helpers.create_fingerprint("LUMI","lumi.remote.rkba01"),})
local STREDA_ROCKER_ACTIONS={
[1]="single_up",[2]="double_up",[3]="release_up",[4]="hold_up",
[11]="single_down",[12]="double_down",[13]="release_down",[14]="hold_down",}
local STREDA_DOORBELL_ACTIONS={[1]="single",[2]="double",[3]="release",[4]="hold"}
local function streda_button_cluster(endpoint,suffix,upper,lower,name,emitter)
local actions=lower and STREDA_ROCKER_ACTIONS or STREDA_DOORBELL_ACTIONS
return zcl.cluster_attribute(0x0012,0x0055,{
name=name,endpoint=endpoint,read_only=true,
from_device=function(value)
return actions[value]and actions[value].."_"..suffix or nil
end,
handler=function(device,action)
local event=emitter(device,action)
event.state_change=true
device:emit_component_event({id="main"},event)
local kind=action:match("^([^_]+)")
local button=({single="pushed",double="double",release="up",hold="held"})[kind]
local component=lower and action:find("_down_",1,true)and lower or upper
device:emit_component_event({id=component},BUTTON_EVENT_BUILDERS[button]({state_change=true}))
end,
})
end
local function streda_power_endpoint(device)
return device:get_endpoint(0x0001)
end
local function streda_battery_clusters()
return{
zcl.cluster_attribute(0x0001,0x0021,{
name="battery",endpoint=streda_power_endpoint,component="main",read_only=true,
data_type=data_types.Uint8,read_on_configure=true,
minimum_interval=3600,maximum_interval=65000,reportable_change=10,
emit=function(device,value)
if value<255 then return emit.battery()(device,value/2)end
end,
}),
zcl.cluster_attribute(0x0001,0x0020,{
name="battery_voltage",endpoint=streda_power_endpoint,component="main",read_only=true,
data_type=data_types.Uint8,
emit=function(device,value)
if value==255 then return nil end
local voltage=value*100
local percentage=100
if voltage<2100 then percentage=0
elseif voltage<2440 then percentage=6-(2440-voltage)*6/340
elseif voltage<2740 then percentage=18-(2740-voltage)*12/300
elseif voltage<2900 then percentage=42-(2900-voltage)*24/160
elseif voltage<3000 then percentage=100-(3000-voltage)*58/100 end
return{emit.battery()(device,math.floor(percentage+0.5)),emit.voltage()(device,value/10)}
end,
}),
zcl.cluster_attribute(0x0001,0x0035,{
name="battery_low",endpoint=streda_power_endpoint,component="main",read_only=true,
data_type=data_types.Bitmap8,
emit=function(_,value)
return value==1 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end,
}),}
end
local function streda_battery_configure(driver,device)
zcl.bind_cluster(device,0x0001,driver.environment_info.hub_zigbee_eui,streda_power_endpoint(device))
end
local function streda_battery_refresh(device)
for _,attribute in ipairs({0x0021,0x0020})do
zcl.read_attribute(device,0x0001,attribute,streda_power_endpoint(device))
end
end
local function streda_led_clusters(leds)
local clusters={}
for _,led in ipairs(leds)do
local options={endpoint=led[1],component=led[2],configure_reporting=false}
zcl_device_helpers.append_clusters(clusters,
zcl.switch(options),zcl.level({endpoint=led[1],component=led[2],configure_reporting=false}),
zcl.color_hue({endpoint=led[1],component=led[2],configure_reporting=false}),
zcl.color_saturation({endpoint=led[1],component=led[2],configure_reporting=false}),
zcl.color({endpoint=led[1],component=led[2]}))
end
return clusters
end
local function streda_mains_hooks(definition,leds,relays,dimmer)
definition.auto_on_before_light_command=false
for _,relay in ipairs(relays)do
definition.zcl_clusters[#definition.zcl_clusters+1]=zcl.switch({
endpoint=relay[1],component=relay[2],minimum_interval=0,maximum_interval=65000,})
end
definition.configure=function(driver,device)
for endpoint in pairs(device.zigbee_endpoints)do
if device:supports_server_cluster(0x0300,endpoint)then
for _,attribute in ipairs({0x400A,0x400B,0x400C})do
zcl.read_attribute(device,0x0300,attribute,endpoint)
end
end
if #relays>0 and device:supports_server_cluster(0x0006,endpoint)then
zcl.bind_cluster(device,0x0006,driver.environment_info.hub_zigbee_eui,endpoint)
zcl.read_attribute(device,0x0006,0x0000,endpoint)
end
end
end
definition.parent_refresh=function(device)
for _,led in ipairs(leds)do
zcl.read_attribute(device,0x0006,0x0000,led[1])
zcl.read_attribute(device,0x0008,0x0000,led[1])
for _,attribute in ipairs({0x0000,0x0001,0x0003,0x0004,0x0008})do
zcl.read_attribute(device,0x0300,attribute,led[1])
end
end
for _,relay in ipairs(relays)do zcl.read_attribute(device,0x0006,0x0000,relay[1])end
if dimmer then
zcl.read_attribute(device,0x0006,0x0000,3)
for _,attribute in ipairs({0x0000,0x0010,0x0012,0x0013,0x0011,0x4000,0x000F})do
zcl.read_attribute(device,0x0008,attribute,3)
end
end
end
end
local streda_bn0s={
profile="controllers-streda-bn0s",
button_actions={"pushed","double","held","up"},
component_to_endpoint_map={main=3,button1Down=3},
zcl_clusters=streda_battery_clusters(),
configure=streda_battery_configure,
parent_refresh=streda_battery_refresh,}
streda_bn0s.zcl_clusters[#streda_bn0s.zcl_clusters+1]=
streda_button_cluster(3,"button_1","main","button1Down","streda_bn0s_action",emit.stredaBn0sAction())
register_device_definition(streda_bn0s,{device_helpers.create_fingerprint("TKHTechnology","BN0-S-03/PW")})
local streda_bn0t={
profile="controllers-streda-bn0t",
button_actions={"pushed","double","held","up"},
component_to_endpoint_map={main=3,button1Down=3,button2Up=4,button2Down=4},
zcl_clusters=streda_battery_clusters(),
configure=streda_battery_configure,
parent_refresh=streda_battery_refresh,}
for index,endpoint in ipairs({3,4})do
streda_bn0t.zcl_clusters[#streda_bn0t.zcl_clusters+1]=streda_button_cluster(endpoint,
"button_"..index,index==1 and"main"or"button2Up","button"..index.."Down",
"streda_bn0t_action",emit.stredaBn0tAction())
end
register_device_definition(streda_bn0t,{device_helpers.create_fingerprint("TKHTechnology","BN0-T-03/PW")})
local streda_led1={
profile="controllers-streda-led1",zcl_clusters=streda_led_clusters({{2,"main"}}),}
streda_mains_hooks(streda_led1,{{2,"main"}},{})
register_device_definition(streda_led1,{
device_helpers.create_fingerprint("TKHTechnology","BN1-1-03/PW"),
device_helpers.create_fingerprint("TKHTechnology","BN3-110-03/PW"),})
local streda_led2={
profile="controllers-streda-led2",zcl_clusters=streda_led_clusters({{2,"main"},{4,"led2"}}),}
streda_mains_hooks(streda_led2,{{2,"main"},{4,"led2"}},{})
register_device_definition(streda_led2,{device_helpers.create_fingerprint("TKHTechnology","DF3-11R-03/PW")})
local streda_ceiling={
profile="controllers-streda-ceiling",zcl_clusters=streda_led_clusters({{2,"main"},{4,"led2"}}),}
streda_mains_hooks(streda_ceiling,{{2,"main"},{4,"led2"}},{{3,"outlet"}})
register_device_definition(streda_ceiling,{
device_helpers.create_fingerprint("TKHTechnology","BN1-C-03/PW"),
device_helpers.create_fingerprint("TKHTechnology","HN1-CW-4-03/PW"),})
local streda_sn2={
profile="controllers-streda-sn2",zcl_clusters=streda_led_clusters({{2,"main"},{4,"led2"}}),
capability_commands={
{capability_id="concertmirror08464.stredaSn2OnLevel",command_name="usePreviousOnLevel",mapping_name="streda_sn2_on_level",value="previous"},
{capability_id="concertmirror08464.stredaSn2StartupLevel",command_name="useMinimumStartupLevel",mapping_name="streda_sn2_startup_level",value="minimum"},
{capability_id="concertmirror08464.stredaSn2StartupLevel",command_name="usePreviousStartupLevel",mapping_name="streda_sn2_startup_level",value="previous"},
{capability_id="concertmirror08464.stredaSn2OnTransitionTime",command_name="disableOnTransitionTime",mapping_name="streda_sn2_on_transition_time",value="disabled"},
{capability_id="concertmirror08464.stredaSn2OffTransitionTime",command_name="disableOffTransitionTime",mapping_name="streda_sn2_off_transition_time",value="disabled"},},}
zcl_device_helpers.append_clusters(streda_sn2.zcl_clusters,
zcl.switch({endpoint=3,component="dimmer",configure_reporting=false}),
zcl.level({endpoint=3,component="dimmer",configure_reporting=false}))
for _,setting in ipairs({
{0x0012,"streda_sn2_on_transition_time",emit.stredaSn2OnTransitionTime()},
{0x0013,"streda_sn2_off_transition_time",emit.stredaSn2OffTransitionTime()},
{0x000F,"streda_sn2_execute_if_off",emit.stredaSn2ExecuteIfOff()},
{0x0011,"streda_sn2_on_level",emit.stredaSn2OnLevel()},
{0x4000,"streda_sn2_startup_level",emit.stredaSn2StartupLevel()},
{0x0010,"streda_sn2_on_off_transition_time",emit.stredaSn2OnOffTransitionTime()},
})do
local attribute=setting[1]
local seconds=attribute==0x0010 or attribute==0x0012 or attribute==0x0013
streda_sn2.zcl_clusters[#streda_sn2.zcl_clusters+1]=zcl.cluster_attribute(0x0008,attribute,{
name=setting[2],endpoint=3,component="dimmer",emit=setting[3],
data_type=seconds and data_types.Uint16 or attribute==0x000F and data_types.Bitmap8 or data_types.Uint8,
prefer_plain_attribute_write=true,
from_device=function(value)
value=type(value)=="table"and value.value or value
if attribute==0x000F then return(value&1)==1 and"on"or"off"end
return seconds and value/10 or value
end,
to_device=function(value)
if attribute==0x000F then return value=="on"and 1 or 0 end
if value=="disabled"then return 65535 end
if value=="previous"then return 255 end
if value=="minimum"then return 0 end
if seconds then return math.max(0,math.min(65535,math.floor(value*10+0.5)))end
return math.max(attribute==0x0011 and 1 or 0,math.min(255,math.floor(value+0.5)))
end,
})
end
streda_mains_hooks(streda_sn2,{{2,"main"},{4,"led2"}},{},true)
register_device_definition(streda_sn2,{device_helpers.create_fingerprint("TKHTechnology","SN2-E-03/PW")})
local streda_sn3={
profile="controllers-streda-sn3",zcl_clusters=streda_led_clusters({{2,"main"}}),
button_actions={"pushed","double","held","up"},
component_to_endpoint_map={main=2,socket=3,light=7,button1Up=4,button1Down=4,button2Up=5,button2Down=5},}
local streda_sn3k={
profile="controllers-streda-sn3k",zcl_clusters=streda_led_clusters({{2,"main"}}),
button_actions={"pushed","double","held","up"},
component_to_endpoint_map={main=2,socket=3,light=7,button1Up=4,button1Down=4,button2Up=5,button2Down=5,doorbellButton=8},}
for _,family in ipairs({
{streda_sn3,"streda_sn3",emit.stredaSn3Action(),emit.stredaSn3Doorbell()},
{streda_sn3k,"streda_sn3k",emit.stredaSn3kAction(),emit.stredaSn3kDoorbell()},
})do
local definition,prefix,action=family[1],family[2],family[3]
for index,endpoint in ipairs({4,5})do
definition.zcl_clusters[#definition.zcl_clusters+1]=streda_button_cluster(endpoint,
"button_"..index,"button"..index.."Up","button"..index.."Down",prefix.."_action",action)
end
if definition==streda_sn3k then
definition.zcl_clusters[#definition.zcl_clusters+1]=streda_button_cluster(8,
"doorbell_button","doorbellButton",nil,prefix.."_action",action)
end
definition.zcl_clusters[#definition.zcl_clusters+1]=zcl.cluster_attribute(0x0006,0xFFFF,{
name=prefix.."_doorbell",component="main",write_only=true,suppress_optimistic_state=true,
emit=family[4],sender=function(device)
device:send(zcl.get_generated_cluster(0x0006).commands.On(device):to_endpoint(6))
end,
})
streda_mains_hooks(definition,{{2,"main"}},{{3,"socket"},{7,"light"}})
end
register_device_definition(streda_sn3,{
device_helpers.create_fingerprint("TKHTechnology","SN3-1TB5-03/PW"),
device_helpers.create_fingerprint("TKHTechnology","HNB-W-1TB5-03/PW"),})
register_device_definition(streda_sn3k,{
device_helpers.create_fingerprint("TKHTechnology","SN3-1TB5K-03/PW"),
device_helpers.create_fingerprint("TKHTechnology","HNB-W-1TB5K-03/PW"),})
local R3SB22BZ_ACTIONS={
[0]="hold",[1]="single",[2]="double",[3]="triple",[4]="quadruple",[255]="release",}
local R3SB22BZ_BUTTON_ACTIONS={
hold="held",single="pushed",double="double",triple="pushed_3x",quadruple="pushed_4x",release="up",}
local third_reality_3rsb22bz={
profile="buttons-third-reality-3rsb22bz",
button_actions={"pushed","double","held","pushed_3x","pushed_4x","up"},
button_count=1,
zcl_clusters={
zcl.cluster_attribute(0x0012,0x0055,{
name="r3sb22bz_action",endpoint=1,read_only=true,
from_device=function(value)
if value==nil then return nil end
return R3SB22BZ_ACTIONS[value]or"many"
end,
handler=function(device,action)
local event=emit.r3sb22bzAction()(device,action)
event.state_change=true
device:emit_component_event({id="main"},event)
local button=R3SB22BZ_BUTTON_ACTIONS[action]
if button then
device:emit_component_event({id="main"},capabilities.button.button(button,{state_change=true}))
end
end,
}),
zcl.cluster_attribute(0x0001,0x0021,{
name="battery",endpoint=1,read_only=true,data_type=data_types.Uint8,
minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,
emit=emit.battery(),
from_device=function(value)
if value<255 then return value/2 end
end,
}),},
configure=function(driver,device)
zcl.bind_cluster(device,0x0001,driver.environment_info.hub_zigbee_eui,1)
end,
parent_refresh=function(device)
zcl.read_attribute(device,0x0001,0x0021,1)
zcl.read_attribute(device,0x0001,0x0020,1)
return true
end,
}
register_device_definition(third_reality_3rsb22bz,{
device_helpers.create_fingerprint("Third Reality, Inc","3RSB22BZ"),})
return{
id="zcl.controls.z2m_absorption",
registrations=device_definitions,}
