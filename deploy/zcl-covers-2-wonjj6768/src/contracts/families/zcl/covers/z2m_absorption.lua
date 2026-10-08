local zcl=require"protocol.zcl"
local emit=require"capabilities.events.all"
local device_helpers=require"contracts.helpers.family"
local data_types=require"st.zigbee.data_types"
local cluster_base=require"st.zigbee.cluster_base"
local registrations,register=device_helpers.definition_registry()local somfy_glydea2={
profile="covers-somfy-glydea2",zcl_clusters={
zcl.cover_position({
endpoint=1,component="main",minimum_interval=1,maximum_interval=65000,reportable_change=1,converter={
from=function(value)return value>=0 and value<=100 and 100-value or nil end,
to=function(value)return 100-value end,
},}),zcl.window_shade_state({
endpoint=1,component="main",configure_reporting=false,read_on_configure=false,
converter={from=function(value)
if value<0 or value>100 then return nil end
return value==0 and"open"or value==100 and"closed"or"partially open"
end},
}),zcl.cover_state({endpoint=1,component="main"}),zcl.battery({
endpoint=232,component="main",minimum_interval=3600,maximum_interval=65000,reportable_change=10,}),},
configure=function(driver,device)
local hub_eui=driver.environment_info.hub_zigbee_eui
zcl.bind_cluster(device,0x0102,hub_eui,1)zcl.bind_cluster(device,0x0001,hub_eui,232)
end,
}register(somfy_glydea2,{
device_helpers.create_fingerprint("SOMFY","Glydea 2 Ultra WF Curtain"),})
local function allesin_identify_sender(device,_,value,context)
local seconds=value or 3
if type(seconds)~="number"or seconds<1 or seconds>30 or seconds%1~=0 then return false end
return zcl.send_raw_cluster_command(device,0x0003,0x00,string.char(seconds,0),context.endpoint or 1)
end
local allesin_cover={
profile="covers-allesin-roller-shade",zcl_clusters={
zcl.cover_position({
endpoint=1,component="main",minimum_interval=1,maximum_interval=65000,reportable_change=1,converter={
from=function(value)return value>=0 and value<=100 and 100-value or nil end,
to=function(value)return 100-value end,
},}),zcl.window_shade_state({
endpoint=1,component="main",configure_reporting=false,read_on_configure=false,
converter={from=function(value)
if value<0 or value>100 then return nil end
return value==0 and"open"or value==100 and"closed"or"partially open"
end},
}),zcl.cover_state({endpoint=1,component="main"}),zcl.battery({
endpoint=1,component="main",scale=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,
converter={from=function(value)return value<255 and value or nil end},
}),zcl.cluster_attribute(0x0003,nil,{
name="allesin_identify",endpoint=1,component="main",write_only=true,sender=allesin_identify_sender,}),},capability_commands={
{capability_id="concertmirror08464.allesinIdentify",command_name="identify",argument_name="seconds",mapping_name="allesin_identify"},},
configure=function(driver,device)
local hub_eui=driver.environment_info.hub_zigbee_eui
zcl.bind_cluster(device,0x0102,hub_eui,1)zcl.bind_cluster(device,0x0001,hub_eui,1)
end,
}register(allesin_cover,{
device_helpers.create_fingerprint("Aubor","TLSR82xx"),})
local function zm108m_enum(name,cluster,attribute,emitter,values,read_only)
local reverse={}
for raw,value in pairs(values)do reverse[value]=raw end
local mapping=zcl.cluster_attribute(cluster,attribute,{
name=name,endpoint=1,component="main",emit=emitter,data_type=data_types.Enum8,write_type=data_types.Enum8,read_only=read_only,read_on_configure=false,converter={
from=function(value)
if type(value)=="table"then value=value.value end
return values[value]
end,
to=function(value)return reverse[value]end,
},})if not read_only then
mapping.sender=function(device,_,value,context)
local request=cluster_base.write_attribute(
device,data_types.ClusterId(cluster),data_types.AttributeId(attribute),data_types.Enum8(reverse[value]))
if cluster==0xE001 then request.body.zcl_header.frame_ctrl:set_disable_default_response()end
device:send(request:to_endpoint(context.endpoint or 1))return true
end
end
return mapping
end
local zm108m_switch_type=zm108m_enum(
"zm108m_switch_type",0xE001,0xD030,emit.zm108mSwitchType(),{[0]="flip-switch",[1]="sync-switch",[2]="button-switch",[3]="button2-switch"})
local function zm108m_position(value,device)
if value<0 or value>100 then return nil end
return device.preferences.invertCover==true and 100-value or value
end
local moes_zm108m={
profile="covers-moes-zm108m",zcl_clusters={
zcl.tuya_magic_packet({read_on_configure=false}),zcl.cluster_attribute(0x0102,8,{
name="cover_position",endpoint=1,data_type=data_types.Uint8,emit=emit.shade_level(),read_on_configure=false,converter={from=zm108m_position,to=zm108m_position},}),zcl.cluster_attribute(0x0102,8,{
name="window_shade_state",endpoint=1,data_type=data_types.Uint8,emit=emit.shade_state(),read_only=true,read_on_configure=false,
converter={from=function(value,device)
local position=zm108m_position(value,device)
if position==nil then return nil end
return position==0 and"closed"or position==100 and"open"or"partially open"
end},
}),zcl.cover_state({endpoint=1}),zm108m_enum("zm108m_moving",0x0102,0xF000,emit.zm108mMoving(),{[0]="UP",[1]="STOP",[2]="DOWN"},true),zm108m_enum("zm108m_motor_reversal",0x0102,0xF002,emit.zm108mMotorReversal(),{[0]="OFF",[1]="ON"}),zm108m_enum("zm108m_calibration",0x0102,0xF001,emit.zm108mCalibration(),{[0]="ON",[1]="OFF"}),zcl.cluster_attribute(0x0102,0xF003,{
name="zm108m_calibration_time",endpoint=1,read_only=true,read_on_configure=false,data_type=data_types.Uint16,scale=10,emit=emit.zm108mCalibrationTime(),}),zm108m_enum("zm108m_indicator_mode",6,0x8001,emit.zm108mIndicatorMode(),{[0]="off",[1]="off/on",[2]="on/off",[3]="on"}),zm108m_enum("zm108m_backlight_mode",6,0x5000,emit.zm108mBacklightMode(),{[0]="OFF",[1]="ON"}),zm108m_switch_type,},
parent_refresh=function(device)
for _,item in ipairs({{0x0102,8},{0x0102,0xF000},{0x0102,0xF001},{0x0102,0xF002},{0x0102,0xF003},{6,0x8001},{6,0x5000},{0xE001,0xD030}})do
zcl.read_attribute(device,item[1],item[2],1)
end
return true
end,
}register(moes_zm108m,{
device_helpers.create_fingerprint("_TZ3210_mldzab8w","TS130F"),})return{
id="zcl.covers.z2m_absorption",registrations=registrations,}
