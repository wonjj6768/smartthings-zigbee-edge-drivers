local tuya=require"protocol.tuya"
local emit=require"capabilities.events.all"
local device_helpers=require"contracts.helpers.family"
local zcl=require"protocol.zcl"
local converter=tuya.converter
local device_definitions,register_device_definition=device_helpers.definition_registry()
local function window_shade_state_from_position_inverted()
return converter.from_only(function(value)
local number_value=tonumber(value)
if number_value==nil then
return nil
end
number_value=100-number_value
if number_value<=0 then
return"closed"
end
if number_value>=100 then
return"open"
end
return"partially open"
end)
end
local cover_state_standard=converter.lookup_from_to({
open=0,
stop=1,
close=2,})
local cover_action_shade_state=converter.from_only(function(value)
return({
[0]="open",
[1]="partially open",
[2]="closed",
[3]="partially open",
})[tonumber(value)]
end)
local function moes_zs_sf_reverse_enabled(device)
return type(device)=="table"
and type(device.preferences)=="table"
and device.preferences.reverse==true
end
local moes_zs_sf_position=converter.from_to(
function(value,device)
local number_value=tonumber(value)
if number_value==nil then return nil end
return moes_zs_sf_reverse_enabled(device)and(100-number_value)or number_value
end,
function(value,device)
local number_value=tonumber(value)
if number_value==nil then return nil end
return moes_zs_sf_reverse_enabled(device)and(100-number_value)or number_value
end
)
local moes_zs_sf_shade_state=converter.from_only(function(value,device)
local position=moes_zs_sf_position.from(value,device)
if position==nil then return nil end
if position<=0 then return"closed"end
if position>=100 then return"open"end
return"partially open"
end)
local cover_model_gm25teq={
profile="covers-cover-gm25teq",
tuya.dp_enum(1,{
name="cover_state",
converter=cover_state_standard,
write_only=true,}),
tuya.dp_enum(1,{
name="cover_action_state",
emit=emit.shade_state(),
converter=cover_action_shade_state,
read_only=true,}),
tuya.dp_cover_position_inverted(9,{emit=emit.shade_level()}),
tuya.dp_numeric(9,{
name="window_shade_state_command_position",
emit=emit.shade_state(),
converter=window_shade_state_from_position_inverted(),
read_only=true,}),
tuya.dp_cover_position_inverted(8,{
name="cover_position_state",
emit=emit.shade_level(),
read_only=true,}),
tuya.dp_numeric(8,{
name="window_shade_state",
emit=emit.shade_state(),
converter=window_shade_state_from_position_inverted(),
read_only=true,}),
tuya.dp_numeric(11,{
name="motor_direction",
emit=emit.gm25TeqMotorDirection(),
converter=converter.from_to(function(value)
return(value==1 or value=="back"or value=="reversed")and"reversed"or"normal"
end,function(value)
return({normal=0,reversed=1})[value]
end),
}),
query_on_configure=false,
time_start="off",}
local cover_model_moes_zs_sf_euc_wh_ms={
profile="covers-cover-moes-zs-sf-euc-wh-ms",
query_on_configure=false,
time_start="off",
tuya.dp_enum(3,{
name="moes_sf_calibration",emit=emit.moesSfCalibration(),
converter=converter.lookup_from_to({start=0,["end"]=1}),
}),
tuya.dp_binary(7,{
name="moes_sf_backlight",emit=emit.moesSfBacklight(),
converter=converter.lookup_from_to({on=true,off=false}),}),
tuya.dp_enum(8,{
name="moes_sf_direction",emit=emit.moesSfDirection(),
converter=converter.lookup_from_to({normal=0,reversed=1}),}),
tuya.dp_numeric(10,{
name="moes_sf_travel_time",emit=emit.moesSfTravelTime(),}),
tuya.dp_enum(1,{
name="cover_state",
converter=cover_state_standard,
write_only=true,}),
tuya.dp_enum(1,{
name="cover_action_state",
emit=emit.shade_state(),
converter=cover_action_shade_state,
read_only=true,}),
tuya.dp_cover_position(2,{
name="cover_position",
emit=emit.shade_level(),
converter=moes_zs_sf_position,}),
tuya.dp_numeric(2,{
name="window_shade_state",
emit=emit.shade_state(),
converter=moes_zs_sf_shade_state,
read_only=true,}),}
register_device_definition(cover_model_gm25teq,device_helpers.create_fingerprints("TS0601",{
"_TZE204_xtrnjaoz",
"_TZE200_xtrnjaoz",
"_TZE284_8whfphjv",}))
register_device_definition(cover_model_moes_zs_sf_euc_wh_ms,device_helpers.create_fingerprints("TS0601",{
"_TZE284_upt8lzi0",
"_TZE28C1000000_i8sdouy0",}))
local cover_model_nova_zcmr_one_core={
profile="covers-nova-zcmr1-core",
package_group="covers",
transport_classification="EF00_DP",
z2m_converter_source="meta.tuyaDatapoints",
wire_cluster="manuSpecificTuya",
magic_packet=true,
mcu_version_request_on_configure=true,
query_on_configure=true,
named_datapoints=true,
time_start="off",
placeholder_custom_states=false,
datapoints={
tuya.dp_enum(1,{
name="cover_state",
converter=cover_state_standard,
write_only=true,
transaction=1,}),
tuya.dp_enum(1,{
name="cover_action_state",
converter=cover_action_shade_state,
read_only=true,
transaction=1,
emit=emit.shade_state(),}),
tuya.dp_cover_position(2,{
name="cover_position",
transaction=1,
emit=emit.shade_level(),}),
tuya.dp_numeric(2,{
name="cover_position_shade_state",
converter=converter.from_only(function(value)
if value<=0 then return"closed"end
if value>=100 then return"open"end
return"partially open"
end),
read_only=true,
transaction=1,
emit=emit.shade_state(),}),
tuya.dp_cover_position(3,{
name="cover_position_report",
read_only=true,
transaction=1,
emit=emit.shade_level(),}),
tuya.dp_numeric(3,{
name="cover_position_report_shade_state",
converter=converter.from_only(function(value)
if value<=0 then return"closed"end
if value>=100 then return"open"end
return"partially open"
end),
read_only=true,
transaction=1,
emit=emit.shade_state(),}),},}
register_device_definition(cover_model_nova_zcmr_one_core,{
device_helpers.create_fingerprint("_TZE204_dqy15zxy","TS0601"),})
local limited_cover_switch={
profile="covers-tuya-limited-switch",
magic_packet=true,
mcu_version_request_on_configure=true,
query_on_configure=false,
query_on_announce=false,
time_start="off",
datapoints={
tuya.dp_enum(1,{name="cover_state",converter=cover_state_standard,write_only=true}),
tuya.dp_enum(1,{name="cover_action_state",converter=cover_action_shade_state,emit=emit.shade_state(),read_only=true}),
tuya.dp_on_off(7,{name="switch",component="main"}),
tuya.dp_enum(8,{
name="limited_cover_motor_direction",emit=emit.limitedCoverMotorDirection(),
receive_datatypes={4,3},
converter=converter.lookup_from_to({normal=0,reversed=1}),
from_device=function(value)
if type(value)=="string"then return value=="back"and"reversed"or"normal"end
return({[0]="normal",[1]="reversed"})[value]
end,
}),},}
register_device_definition(limited_cover_switch,{
device_helpers.create_fingerprint("_TZE204_pxbjch8m","TS0601"),})
local tubular_motor_direction=converter.from_to(function(value)
if type(value)=="string"then return value=="back"and"reversed"or"normal"end
return({[0]="normal",[1]="reversed"})[value]
end,function(value)
return({normal=0,reversed=1})[value]
end)
local cover5_px={
profile="covers-tuya-cover5-px",
magic_packet=true,
mcu_version_request_on_configure=true,
query_on_configure=false,
query_on_announce=false,
initial_custom_states=false,
refresh_state=false,
refresh_state_query=false,
time_start="off",
datapoints={
tuya.dp_enum(1,{name="cover_state",converter=cover_state_standard,write_only=true}),
tuya.dp_enum(1,{
name="cover_action_state",emit=emit.shade_state(),read_only=true,
converter=converter.from_only(function(value)
return({[0]="open",[1]="partially open",[2]="closed"})[value]
end),
}),
tuya.dp_cover_position(2,{emit=emit.shade_level(),converter=moes_zs_sf_position}),
tuya.dp_numeric(2,{name="window_shade_state",emit=emit.shade_state(),converter=moes_zs_sf_shade_state,read_only=true}),
tuya.dp_enum(3,{
name="cover5_px_calibration",emit=emit.cover5PxCalibration(),
converter=converter.lookup_from_to({START=0,END=1}),}),
tuya.dp_binary(7,{
name="cover5_px_backlight",emit=emit.cover5PxBacklight(),
converter=converter.lookup_from_to({ON=true,OFF=false}),}),
tuya.dp_enum(8,{
name="cover5_px_motor_direction",emit=emit.cover5PxMotorDirection(),
converter=tubular_motor_direction,receive_datatypes={4,3},}),
tuya.dp_binary(103,{
name="cover5_px_child_lock",emit=emit.cover5PxChildLock(),
converter=converter.lookup_from_to({ON=true,OFF=false}),}),},}
register_device_definition(cover5_px,{
device_helpers.create_fingerprint("_TZE284_pxwixtky","TS0601"),})
local cover14_position_state=converter.from_only(function(value)
if value<=0 then return"closed"end
if value>=100 then return"open"end
return"partially open"
end)
local cover14_a0={
profile="covers-tuya-cover14-a0",
magic_packet=true,
mcu_version_request_on_configure=true,
query_on_configure=false,
query_on_announce=false,
initial_custom_states=false,
refresh_state=false,
refresh_state_query=false,
time_start="off",
datapoints={
tuya.dp_enum(1,{name="cover_state",converter=cover_state_standard,write_only=true}),
tuya.dp_enum(1,{name="cover_action_state",converter=cover_action_shade_state,emit=emit.shade_state(),read_only=true}),
tuya.dp_cover_position(2,{emit=emit.shade_level()}),
tuya.dp_numeric(2,{name="window_shade_state",emit=emit.shade_state(),converter=cover14_position_state,read_only=true}),
tuya.dp_cover_position(3,{name="cover_position_report",emit=emit.shade_level(),read_only=true}),
tuya.dp_numeric(3,{name="window_shade_state_report",emit=emit.shade_state(),converter=cover14_position_state,read_only=true}),
tuya.dp_enum(5,{
name="cover14_a0_motor_direction",emit=emit.cover14A0MotorDirection(),
converter=tubular_motor_direction,receive_datatypes={4,3},}),
tuya.dp_enum(7,{
name="cover14_a0_motor_state",emit=emit.cover14A0MotorState(),read_only=true,
converter=converter.lookup_from_to({opening=0,closing=1,stopped=2}),}),
tuya.dp_numeric(10,{name="cover14_a0_total_time",emit=emit.cover14A0TotalTime(),read_only=true}),
tuya.dp_enum(11,{
name="cover14_a0_situation_set",emit=emit.cover14A0SituationSet(),
converter=converter.lookup_from_to({fully_close=0,fully_open=1}),}),
tuya.dp_numeric(19,{name="cover14_a0_favorite_position",emit=emit.cover14A0FavoritePosition()}),},}
register_device_definition(cover14_a0,{
device_helpers.create_fingerprint("_TZE284_a0hirjnh","TS0601"),})
local fwjz_16eb={
profile="covers-moes-fwjz-16eb",
magic_packet=true,
mcu_version_request_on_configure=true,
query_on_configure=false,
query_on_announce=false,
initial_custom_states=false,
refresh_state=false,
refresh_state_query=false,
time_start="off",
datapoints={
tuya.dp_enum(1,{name="cover_state",converter=cover_state_standard,write_only=true}),
tuya.dp_enum(1,{name="cover_action_state",converter=cover_action_shade_state,emit=emit.shade_state(),read_only=true}),
tuya.dp_cover_position(9,{emit=emit.shade_level(),converter=moes_zs_sf_position}),
tuya.dp_numeric(9,{name="window_shade_state",emit=emit.shade_state(),converter=moes_zs_sf_shade_state,read_only=true}),
tuya.dp_cover_position(8,{name="cover_position_report",emit=emit.shade_level(),converter=moes_zs_sf_position,read_only=true}),
tuya.dp_numeric(8,{name="window_shade_state_report",emit=emit.shade_state(),converter=moes_zs_sf_shade_state,read_only=true}),
tuya.dp_enum(11,{
name="fwjz_16eb_motor_direction",emit=emit.fwjz16ebMotorDirection(),
converter=tubular_motor_direction,receive_datatypes={4,3},}),
tuya.dp_raw(13,{
name="battery",read_only=true,receive_datatypes={0,2},emit=emit.battery(),
from_device=function(value)
if type(value)=="number"then return value end
if type(value)=="string"and #value>=4 then return string.unpack(">I4",value)end
end,
}),
tuya.dp_enum(16,{
name="fwjz_16eb_cover_limit",emit=emit.fwjz16ebCoverLimit(),
converter=converter.lookup_from_to({set_up=0,set_down=1,delete_up=2,delete_down=3}),}),},
zcl_clusters={
zcl.cluster_attribute(0x0001,0x0021,{
name="battery",endpoint=1,read_only=true,scale=2,emit=emit.battery(),}),},}
register_device_definition(fwjz_16eb,{
device_helpers.create_fingerprint("_TZE2841000000_u68q868h","TS0601"),})
return{
id="ef00.covers.z2m_absorption",
registrations=device_definitions,}
