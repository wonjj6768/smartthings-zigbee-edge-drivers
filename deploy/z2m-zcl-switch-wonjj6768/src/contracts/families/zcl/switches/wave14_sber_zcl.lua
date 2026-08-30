local zcl=require "protocol.zcl"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local capabilities=require "st.capabilities"
local device_management=require "st.zigbee.device_management"
local cluster_base=require "st.zigbee.cluster_base"
local data_types=require "st.zigbee.data_types"
local device_definitions,register_device_definition=device_helpers.definition_registry()
local CAPABILITY_NAMESPACE="concertmirror08464."
local SBER_MFG_CODE=0x152F
local CLUSTER_BASIC=0x0000
local CLUSTER_DEVICE_TEMPERATURE=0x0002
local CLUSTER_IDENTIFY=0x0003
local CLUSTER_ON_OFF=0x0006
local CLUSTER_MULTISTATE_INPUT=0x0012
local CLUSTER_WINDOW_COVERING=0x0102
local CLUSTER_DIAGNOSTICS=0x0B05
local CLUSTER_SBER=0xFCCF
local ATTR_SERIAL_NUMBER=0x000D
local ATTR_DEVICE_ENABLED=0x0012
local ATTR_ON_OFF=0x0000
local ATTR_STARTUP_ON_OFF=0x4003
local ATTR_RELAY_DECOUPLE=0x10DC
local ATTR_PRESENT_VALUE=0x0055
local ATTR_CURRENT_POSITION=0x0008
local ATTR_WINDOW_COVERING_MODE=0x0017
local ATTR_ALLOW_DOUBLE_CLICK=0x1002
local ATTR_CHILD_LOCK=0x1003
local ATTR_LED_ON_ENABLE=0x2001
local ATTR_LED_ON_HUE=0x2002
local ATTR_LED_ON_SATURATION=0x2003
local ATTR_LED_ON_BRIGHTNESS=0x2004
local ATTR_LED_OFF_ENABLE=0x2005
local ATTR_LED_OFF_HUE=0x2006
local ATTR_LED_OFF_SATURATION=0x2007
local ATTR_LED_OFF_BRIGHTNESS=0x2008
local ATTR_LED_INDICATION_TYPE=0x2009
local ATTR_EMERGENCY_STATE=0x3001
local ATTR_EMERGENCY_RECOVERY=0x3002
local ATTR_UPPER_VOLTAGE_THRESHOLD=0x3011
local ATTR_LOWER_VOLTAGE_THRESHOLD=0x3012
local ATTR_UPPER_CURRENT_THRESHOLD=0x3013
local ATTR_UPPER_TEMPERATURE_THRESHOLD=0x3014
local ATTR_RMS_VOLTAGE_MV=0x4001
local ATTR_RMS_CURRENT_MA=0x4002
local ATTR_ACTIVE_POWER_MW=0x4003
local ATTR_POWER_PROFILE=0x4100
local ATTR_NEUTRAL_PRESENCE=0x4101
local ATTR_DIAGNOSTIC_RESETS=0x0000
local ATTR_DIAGNOSTIC_UPTIME=0x1001
local ATTR_DIAGNOSTIC_BUTTON_ONE=0x1002
local ATTR_DIAGNOSTIC_BUTTON_TWO=0x1003
local ATTR_DIAGNOSTIC_BUTTON_THREE=0x1004
local ATTR_DIAGNOSTIC_RELAY_ONE=0x1005
local ATTR_DIAGNOSTIC_RELAY_TWO=0x1006
local ATTR_CALIBRATION_TIME=0x1001
local ATTR_BUTTONS_MODE=0x1002
local ATTR_MOTOR_TIMEOUT=0x1003
local function custom(capability_id)
return assert(emit[capability_id],"missing Wave14 Sber emitter: " .. capability_id)()
end
local function append(target,mapping)
if mapping.read_only==nil then mapping.read_only=false end
target[#target + 1]=mapping
return mapping
end
local function copy_options(options)
local copied={}
for key,value in pairs(options or{})do copied[key]=value end
return copied
end
local function copy_command_context(context)
local copied={}
for key,value in pairs(context or{})do
if key ~="mapping" then copied[key]=value end
end
return copied
end
local function guard_dynamic_mappings(target,first_index,last_index,branch,allowed)
for index=first_index,last_index do
local mapping=target[index]
mapping.sber_dynamic_branch=branch
local original_emit=mapping.emit
if type(original_emit)=="function" then
mapping.emit=function(device,value,context,current_mapping)
if not allowed(device)then return nil end
return original_emit(device,value,context,current_mapping)
end
end
local original_handler=mapping.handler
if type(original_handler)=="function" then
mapping.handler=function(device,value,context,current_mapping)
if not allowed(device)then return nil end
return original_handler(device,value,context,current_mapping)
end
end
if mapping.read_only ~=true then
local delegate=copy_options(mapping)
local delegate_list={delegate}
mapping.sender=function(device,_,value,context)
if not allowed(device)then
return delegate.name=="switch"
end
return zcl.send_named_command(
device,
delegate_list,
delegate.name,
value,
copy_command_context(context)
)
end
end
end
end
local function custom_mapping(cluster_id,attribute_id,name,capability_id,data_type,options)
local config=copy_options(options)
config.name=name
config.emit=custom(capability_id)
config.data_type=data_type
config.write_type=config.write_type or data_type
return zcl.cluster_attribute(cluster_id,attribute_id,config)
end
local function sber_mapping(attribute_id,name,capability_id,data_type,options)
local config=copy_options(options)
config.mfg_code=SBER_MFG_CODE
return custom_mapping(CLUSTER_SBER,attribute_id,name,capability_id,data_type,config)
end
local function bool_to_on_off(value)
return(value==true or value==1)and "ON" or "OFF"
end
local function on_off_to_bool(value)
return value==true or value=="ON" or value=="on"
end
local function uint16_le(value)
value=math.max(0,math.min(0xFFFF,math.floor(tonumber(value)or 0)))
return string.char(value % 0x100,math.floor(value / 0x100)% 0x100)
end
local function window_attribute_sender(device,mapping,value,context)
local encoded=value
if type(mapping.to_device)=="function" then
encoded=mapping.to_device(value,device,context,mapping)
end
if type(encoded)=="number" then encoded=math.floor(encoded + 0.5)end
if encoded==nil then return false end
local request
if mapping.mfg_code ~=nil then
request=cluster_base.write_manufacturer_specific_attribute(
device,
mapping.cluster_id,
mapping.attribute_id,
mapping.mfg_code,
mapping.write_type,
encoded
)
else
request=cluster_base.write_attribute(
device,
data_types.ClusterId(mapping.cluster_id),
data_types.AttributeId(mapping.attribute_id),
mapping.write_type(encoded)
)
end
if context.endpoint ~=nil and type(request.to_endpoint)=="function" then
request=request:to_endpoint(context.endpoint)
end
device:send(request)
return true
end
local function identify_sender(default_seconds)
return function(device,_,_,context)
return zcl.send_raw_cluster_command(
device,
CLUSTER_IDENTIFY,
0x00,
uint16_le(default_seconds),
context.endpoint,
nil,
nil,
false
)
end
end
local function cover_state_sender(device,_,value,context)
local command_id=({open=0x00,close=0x01,stop=0x02})[value]
if command_id==nil then return false end
return zcl.send_raw_cluster_command(
device,
CLUSTER_WINDOW_COVERING,
command_id,
"",
context.endpoint,
nil,
nil,
false
)
end
local function cover_position_sender(device,_,value,context)
local position=math.max(0,math.min(100,math.floor(tonumber(value)+ 0.5)))
local zigbee_position=100 - position
return zcl.send_raw_cluster_command(
device,
CLUSTER_WINDOW_COVERING,
0x05,
string.char(zigbee_position),
context.endpoint,
nil,
nil,
false
)
end
local function button_event_emitter()
return function(_,value)
local action=({[0]="held",[1]="pushed",[2]="double"})[value]
if action==nil then return nil end
local event=capabilities.button.button(action)
event.state_change=true
return event
end
end
local function bind(device,hub_eui,endpoint,clusters)
for _,cluster_id in ipairs(clusters)do
device:send(device_management.build_bind_request(
device,
cluster_id,
hub_eui,
endpoint
))
end
end
local function read(device,endpoint,cluster_id,attribute_id,mfg_code)
zcl.read_attribute(device,cluster_id,attribute_id,endpoint,mfg_code)
end
local function read_many(device,endpoint,cluster_id,attributes,mfg_code)
for _,attribute_id in ipairs(attributes)do
read(device,endpoint,cluster_id,attribute_id,mfg_code)
end
end
local LED_FIELDS={
{ATTR_LED_ON_ENABLE,"LedOnEnabled","led_on_enabled",data_types.Boolean,bool_to_on_off,on_off_to_bool,0,1,nil},
{ATTR_LED_ON_HUE,"LedOnHue","led_on_hue",data_types.Uint16,nil,nil,0,359,"°"},
{ATTR_LED_ON_SATURATION,"LedOnSaturation","led_on_saturation",data_types.Uint8,nil,nil,0,254,nil},
{ATTR_LED_ON_BRIGHTNESS,"LedOnBrightness","led_on_brightness",data_types.Uint8,nil,nil,1,254,nil},
{ATTR_LED_OFF_ENABLE,"LedOffEnabled","led_off_enabled",data_types.Boolean,bool_to_on_off,on_off_to_bool,0,1,nil},
{ATTR_LED_OFF_HUE,"LedOffHue","led_off_hue",data_types.Uint16,nil,nil,0,359,"°"},
{ATTR_LED_OFF_SATURATION,"LedOffSaturation","led_off_saturation",data_types.Uint8,nil,nil,0,254,nil},
{ATTR_LED_OFF_BRIGHTNESS,"LedOffBrightness","led_off_brightness",data_types.Uint8,nil,nil,1,254,nil},
}
local function add_led_mappings(target,mapping_prefix,capability_prefix,endpoint,component,off_only)
for index,field in ipairs(LED_FIELDS)do
if not off_only or index >=5 then
append(target,sber_mapping(
field[1],
mapping_prefix .. "_" .. field[3],
capability_prefix .. field[2],
field[4],
{
endpoint=endpoint,
component=component,
from_device=field[5],
to_device=field[6],
numeric_range=field[7]and{
minimum=field[7],maximum=field[8],step=1,unit=field[9],
}or nil,
}
))
end
end
end
local function add_allow_double_click(target,mapping_prefix,capability_prefix,endpoint,component)
append(target,sber_mapping(
ATTR_ALLOW_DOUBLE_CLICK,
mapping_prefix .. "_allow_double_click",
capability_prefix .. "AllowDoubleClick",
data_types.Boolean,
{
endpoint=endpoint,
component=component,
from_device=bool_to_on_off,
to_device=on_off_to_bool,
}
))
end
local function add_power_on_behavior(target,mapping_prefix,capability_prefix,endpoint,component)
append(target,custom_mapping(
CLUSTER_ON_OFF,
ATTR_STARTUP_ON_OFF,
mapping_prefix .. "_power_on_behavior",
capability_prefix .. "PowerOnBehavior",
data_types.Enum8,
{
endpoint=endpoint,
component=component,
from_device=function(value)
return({[0]="off",[1]="on",[2]="toggle",[255]="previous"})[value]
end,
to_device=function(value)
return({off=0,on=1,toggle=2,previous=255})[value]
end,
}
))
end
local function add_relay_mode(target,mapping_prefix,capability_prefix,endpoint,component)
append(target,custom_mapping(
CLUSTER_ON_OFF,
ATTR_RELAY_DECOUPLE,
mapping_prefix .. "_relay_mode",
capability_prefix .. "RelayMode",
data_types.Boolean,
{
endpoint=endpoint,
component=component,
mfg_code=SBER_MFG_CODE,
from_device=function(value)return(value==true or value==1)and "decoupled" or "control_relay" end,
to_device=function(value)return value=="decoupled" end,
}
))
end
local function add_identify(target,commands,mapping_prefix,capability_prefix,endpoint,component,default_seconds)
local mapping_name=mapping_prefix .. "_identify"
append(target,zcl.cluster_attribute(CLUSTER_IDENTIFY,nil,{
name=mapping_name,
endpoint=endpoint,
component=component,
write_only=true,
sender=identify_sender(default_seconds),
}))
commands[#commands + 1]={
capability_id=CAPABILITY_NAMESPACE .. capability_prefix .. "Identify",
command_name="identify",
value=true,
mapping_name=mapping_name,
}
end
local function add_button_action(target,endpoint,component)
append(target,zcl.cluster_attribute(CLUSTER_MULTISTATE_INPUT,ATTR_PRESENT_VALUE,{
name="button_action",
endpoint=endpoint,
component=component,
read_only=true,
data_type=data_types.SinglePrecisionFloat,
emit=button_event_emitter(),
}))
end
local DIAGNOSTIC_FIELDS={
{ATTR_DIAGNOSTIC_RESETS,"ResetsCount","resets_count",data_types.Uint16,false},
{ATTR_DIAGNOSTIC_UPTIME,"Uptime","uptime",data_types.Uint32,true},
{ATTR_DIAGNOSTIC_BUTTON_ONE,"ButtonClicksOne","button_clicks_one",data_types.Uint32,true},
{ATTR_DIAGNOSTIC_BUTTON_TWO,"ButtonClicksTwo","button_clicks_two",data_types.Uint32,true},
{ATTR_DIAGNOSTIC_BUTTON_THREE,"ButtonClicksThree","button_clicks_three",data_types.Uint32,true},
{ATTR_DIAGNOSTIC_RELAY_ONE,"RelaySwitchesOne","relay_switches_one",data_types.Uint32,true},
{ATTR_DIAGNOSTIC_RELAY_TWO,"RelaySwitchesTwo","relay_switches_two",data_types.Uint32,true},
}
local function add_shared_mappings(target,mapping_prefix,capability_prefix,endpoint,component,buttons,relays,extras)
append(target,sber_mapping(
ATTR_CHILD_LOCK,
mapping_prefix .. "_child_lock",
capability_prefix .. "ChildLock",
data_types.Boolean,
{
endpoint=endpoint,
component=component,
from_device=bool_to_on_off,
to_device=on_off_to_bool,
}
))
append(target,custom_mapping(
CLUSTER_BASIC,
ATTR_SERIAL_NUMBER,
mapping_prefix .. "_serial_number",
capability_prefix .. "SerialNumber",
data_types.CharString,
{
endpoint=endpoint,
component=component,
read_only=true,
from_device=function(value)return tostring(value)end,
}
))
for index,field in ipairs(DIAGNOSTIC_FIELDS)do
local include=index <=2 or(index >=3 and index <=2 + buttons)or
(index >=6 and index <=5 + relays)
if include then
append(target,custom_mapping(
CLUSTER_DIAGNOSTICS,
field[1],
mapping_prefix .. "_" .. field[3],
capability_prefix .. field[2],
field[4],
{
endpoint=endpoint,
component=component,
read_only=true,
mfg_code=field[5]and SBER_MFG_CODE or nil,
}
))
end
end
if extras then
append(target,sber_mapping(
ATTR_NEUTRAL_PRESENCE,
mapping_prefix .. "_neutral_presence",
capability_prefix .. "NeutralPresence",
data_types.Enum8,
{
endpoint=endpoint,
component=component,
read_only=true,
from_device=function(value)return value==1 and "YES" or "NO" end,
}
))
append(target,sber_mapping(
ATTR_POWER_PROFILE,
mapping_prefix .. "_power_profile",
capability_prefix .. "PowerProfile",
data_types.Enum8,
{
endpoint=endpoint,
component=component,
from_device=function(value)
return({
[0]="quick",[1]="af_250",[2]="af_500",[3]="af_750",
[4]="af_1000",[5]="af_1250",[6]="af_1750",[7]="af_2000",
[254]="af_fallback",
})[value]
end,
to_device=function(value)
return({
quick=0,af_250=1,af_500=2,af_750=3,
af_1000=4,af_1250=5,af_1750=6,af_2000=7,
af_fallback=254,
})[value]
end,
}
))
append(target,sber_mapping(
ATTR_LED_INDICATION_TYPE,
mapping_prefix .. "_led_indication_type",
capability_prefix .. "LedIndicationType",
data_types.Enum8,
{
endpoint=endpoint,
component=component,
from_device=function(value)return({[0]="continuous",[1]="flashes"})[value]end,
to_device=function(value)return({continuous=0,flashes=1})[value]end,
}
))
end
end
local function configure_single(model,extras)
return function(driver,device)
read_many(device,1,CLUSTER_ON_OFF,{ATTR_ON_OFF,ATTR_STARTUP_ON_OFF})
read(device,1,CLUSTER_ON_OFF,ATTR_RELAY_DECOUPLE,SBER_MFG_CODE)
read(device,1,CLUSTER_BASIC,ATTR_SERIAL_NUMBER)
read_many(device,1,CLUSTER_SBER,{
ATTR_LED_ON_ENABLE,ATTR_LED_ON_HUE,ATTR_LED_ON_SATURATION,ATTR_LED_ON_BRIGHTNESS,
ATTR_LED_OFF_ENABLE,ATTR_LED_OFF_HUE,ATTR_LED_OFF_SATURATION,ATTR_LED_OFF_BRIGHTNESS,
},SBER_MFG_CODE)
read(device,1,CLUSTER_SBER,ATTR_ALLOW_DOUBLE_CLICK,SBER_MFG_CODE)
read(device,1,CLUSTER_SBER,ATTR_CHILD_LOCK,SBER_MFG_CODE)
if extras then
read_many(device,1,CLUSTER_SBER,{
ATTR_NEUTRAL_PRESENCE,ATTR_POWER_PROFILE,ATTR_LED_INDICATION_TYPE,
},SBER_MFG_CODE)
end
bind(device,driver.environment_info.hub_zigbee_eui,1,{
CLUSTER_ON_OFF,CLUSTER_MULTISTATE_INPUT,
})
bind(device,driver.environment_info.hub_zigbee_eui,1,{CLUSTER_DIAGNOSTICS})
end
end
local function single_definition(model,profile,extras)
local mapping_prefix="sber_" .. model
local capability_prefix="sber" .. model
local mappings={}
local commands={}
append(mappings,zcl.switch({endpoint=1,component="main",configure_reporting=false,read_on_configure=false}))
add_allow_double_click(mappings,mapping_prefix,capability_prefix,1,"main")
add_led_mappings(mappings,mapping_prefix,capability_prefix,1,"main",false)
add_identify(mappings,commands,mapping_prefix,capability_prefix,1,"main",3)
add_power_on_behavior(mappings,mapping_prefix,capability_prefix,1,"main")
add_relay_mode(mappings,mapping_prefix,capability_prefix,1,"main")
add_button_action(mappings,1,"main")
add_shared_mappings(mappings,mapping_prefix,capability_prefix,1,"main",2,1,extras)
return{
profile=profile,
package_group="wave14-switch",
transport_classification="ZCL_CUSTOM_ATTRIBUTE_COMMAND",
z2m_converter_source="sdevicesExtend + local sdevices converters",
wire_cluster="manuSpecificSDevices(0xFCCF) and standard ZCL",
zcl_clusters=mappings,
capability_commands=commands,
button_actions={"pushed","held","double"},
placeholder_custom_states=false,
configure=configure_single(model,extras),
}
end
local function read_dynamic_branch(device,cover_enabled,extras)
local endpoint=cover_enabled and 3 or 1
if cover_enabled then
read(device,3,CLUSTER_BASIC,ATTR_SERIAL_NUMBER)
read_many(device,3,CLUSTER_WINDOW_COVERING,{
ATTR_CURRENT_POSITION,ATTR_WINDOW_COVERING_MODE,
})
read_many(device,3,CLUSTER_WINDOW_COVERING,{
ATTR_CALIBRATION_TIME,ATTR_BUTTONS_MODE,ATTR_MOTOR_TIMEOUT,
},SBER_MFG_CODE)
read_many(device,3,CLUSTER_SBER,{
ATTR_LED_OFF_ENABLE,ATTR_LED_OFF_HUE,ATTR_LED_OFF_SATURATION,ATTR_LED_OFF_BRIGHTNESS,
},SBER_MFG_CODE)
read(device,3,CLUSTER_SBER,ATTR_CHILD_LOCK,SBER_MFG_CODE)
else
read(device,1,CLUSTER_BASIC,ATTR_SERIAL_NUMBER)
for switch_endpoint=1,2 do
read_many(device,switch_endpoint,CLUSTER_ON_OFF,{ATTR_ON_OFF,ATTR_STARTUP_ON_OFF})
read(device,switch_endpoint,CLUSTER_ON_OFF,ATTR_RELAY_DECOUPLE,SBER_MFG_CODE)
read_many(device,switch_endpoint,CLUSTER_SBER,{
ATTR_ALLOW_DOUBLE_CLICK,
ATTR_LED_ON_ENABLE,ATTR_LED_ON_HUE,ATTR_LED_ON_SATURATION,ATTR_LED_ON_BRIGHTNESS,
ATTR_LED_OFF_ENABLE,ATTR_LED_OFF_HUE,ATTR_LED_OFF_SATURATION,ATTR_LED_OFF_BRIGHTNESS,
},SBER_MFG_CODE)
end
read(device,1,CLUSTER_SBER,ATTR_CHILD_LOCK,SBER_MFG_CODE)
end
if extras then
read_many(device,endpoint,CLUSTER_SBER,{
ATTR_NEUTRAL_PRESENCE,ATTR_POWER_PROFILE,ATTR_LED_INDICATION_TYPE,
},SBER_MFG_CODE)
end
end
local function bind_dynamic_branch(device,hub_eui,cover_enabled)
if hub_eui==nil then return end
if cover_enabled then
bind(device,hub_eui,3,{CLUSTER_WINDOW_COVERING})
bind(device,hub_eui,3,{CLUSTER_SBER})
bind(device,hub_eui,3,{CLUSTER_DIAGNOSTICS})
return
end
for switch_endpoint=1,2 do
bind(device,hub_eui,switch_endpoint,{CLUSTER_ON_OFF,CLUSTER_MULTISTATE_INPUT})
end
bind(device,hub_eui,1,{CLUSTER_SBER})
bind(device,hub_eui,1,{CLUSTER_DIAGNOSTICS})
end
local function configure_dynamic_branch(device,hub_eui,cover_enabled,extras)
read_dynamic_branch(device,cover_enabled,extras)
bind_dynamic_branch(device,hub_eui,cover_enabled)
end
local function dynamic_definition(model,profile,extras)
local mapping_prefix="sber_" .. model
local capability_prefix="sber" .. model
local switch_profile=profile
local cover_profile=profile .. "-cover"
local mode_field="__wave14_sber_" .. model .. "_cover_enabled"
local pending_field="__wave14_sber_" .. model .. "_mode_pending"
local timer_field="__wave14_sber_" .. model .. "_mode_timer"
local hub_field="__wave14_sber_" .. model .. "_hub_eui"
local probe_action_field="__wave14_sber_" .. model .. "_probe_action"
local profile_reconfigure_field="__wave14_sber_" .. model .. "_profile_reconfigure"
local mappings={}
local commands={}
local function branch_allowed(device,cover_enabled)
local active_profile=cover_enabled and cover_profile or switch_profile
return device:get_field(pending_field)~=true and
device:get_field(mode_field)==cover_enabled and
device.profile ~=nil and device.profile.id==active_profile
end
local function apply_mode_profile(device,cover_enabled,force,suppress_reconfigure)
local wanted=cover_enabled and cover_profile or switch_profile
local current=device.profile and device.profile.id or nil
if force or current ~=wanted then
if suppress_reconfigure then
device:set_field(profile_reconfigure_field,wanted)
end
device:try_update_metadata({profile=wanted})
return true
end
return false
end
local function cancel_mode_timer(device)
local timer=device:get_field(timer_field)
if timer ~=nil and device.thread ~=nil and type(device.thread.cancel_timer)=="function" then
device.thread:cancel_timer(timer)
end
device:set_field(timer_field,nil)
end
local switch_mapping_start=#mappings + 1
for channel=1,2 do
local word=channel==1 and "One" or "Two"
local component=channel==1 and "main" or "switch2"
local ep_prefix=mapping_prefix .. "_" .. string.lower(word)
local cap_prefix=capability_prefix .. word
append(mappings,zcl.switch({endpoint=channel,component=component,configure_reporting=false,read_on_configure=false}))
add_power_on_behavior(mappings,ep_prefix,cap_prefix,channel,component)
add_relay_mode(mappings,ep_prefix,cap_prefix,channel,component)
add_allow_double_click(mappings,ep_prefix,cap_prefix,channel,component)
add_identify(mappings,commands,ep_prefix,cap_prefix,channel,component,30)
add_led_mappings(mappings,ep_prefix,cap_prefix,channel,component,false)
add_button_action(mappings,channel,component)
end
guard_dynamic_mappings(
mappings,
switch_mapping_start,
#mappings,
"switch",
function(device)return branch_allowed(device,false)end
)
local cover_mapping_start=#mappings + 1
append(mappings,zcl.cluster_attribute(CLUSTER_WINDOW_COVERING,ATTR_CURRENT_POSITION,{
name="cover_position",
endpoint=3,
component="cover",
data_type=data_types.Uint8,
from_device=function(value)return 100 - value end,
emit=emit.shade_level(),
sender=cover_position_sender,
}))
append(mappings,zcl.cluster_attribute(CLUSTER_WINDOW_COVERING,ATTR_CURRENT_POSITION,{
name=mapping_prefix .. "_cover_state_rx",
endpoint=3,
component="cover",
read_only=true,
data_type=data_types.Uint8,
from_device=function(value)return value==100 and "closed" or "open" end,
emit=emit.shade_state(),
}))
append(mappings,zcl.cluster_attribute(CLUSTER_WINDOW_COVERING,nil,{
name="cover_state",
endpoint=3,
component="cover",
write_only=true,
sender=cover_state_sender,
}))
append(mappings,custom_mapping(
CLUSTER_WINDOW_COVERING,
ATTR_WINDOW_COVERING_MODE,
mapping_prefix .. "_cover_mode",
capability_prefix .. "CoverMode",
data_types.Bitmap8,
{
endpoint=3,
component="cover",
sender=window_attribute_sender,
from_device=function(value)return value % 2==1 and "reversed" or "normal" end,
to_device=function(value)return value=="reversed" and 1 or 0 end,
}
))
append(mappings,custom_mapping(
CLUSTER_WINDOW_COVERING,
ATTR_CALIBRATION_TIME,
mapping_prefix .. "_calibration_time",
capability_prefix .. "CalibrationTime",
data_types.Uint16,
{
endpoint=3,
component="cover",
mfg_code=SBER_MFG_CODE,
sender=window_attribute_sender,
from_device=function(value)return value * 0.1 end,
to_device=function(value)return value * 10 end,
numeric_range={minimum=0,maximum=3600,step=0.1,unit="s"},
}
))
append(mappings,custom_mapping(
CLUSTER_WINDOW_COVERING,
ATTR_MOTOR_TIMEOUT,
mapping_prefix .. "_motor_timeout",
capability_prefix .. "MotorTimeout",
data_types.Uint16,
{
endpoint=3,
component="cover",
mfg_code=SBER_MFG_CODE,
sender=window_attribute_sender,
numeric_range={minimum=0,maximum=3600,step=1,unit="s"},
}
))
append(mappings,custom_mapping(
CLUSTER_WINDOW_COVERING,
ATTR_BUTTONS_MODE,
mapping_prefix .. "_buttons_mode",
capability_prefix .. "ButtonsMode",
data_types.Enum8,
{
endpoint=3,
component="cover",
mfg_code=SBER_MFG_CODE,
sender=window_attribute_sender,
from_device=function(value)return value==1 and "inverted" or "normal" end,
to_device=function(value)return value=="inverted" and 1 or 0 end,
}
))
add_identify(mappings,commands,mapping_prefix .. "_cover",capability_prefix .. "Cover",3,"cover",30)
add_led_mappings(mappings,mapping_prefix .. "_cover",capability_prefix .. "Cover",3,"cover",true)
guard_dynamic_mappings(
mappings,
cover_mapping_start,
#mappings,
"cover",
function(device)return branch_allowed(device,true)end
)
local switch_shared_start=#mappings + 1
add_shared_mappings(mappings,mapping_prefix,capability_prefix,1,"main",3,2,extras)
guard_dynamic_mappings(
mappings,
switch_shared_start,
#mappings,
"switch",
function(device)return branch_allowed(device,false)end
)
local cover_shared_start=#mappings + 1
add_shared_mappings(mappings,mapping_prefix,capability_prefix,3,"cover",3,2,extras)
guard_dynamic_mappings(
mappings,
cover_shared_start,
#mappings,
"cover",
function(device)return branch_allowed(device,true)end
)
local function mode_handler(device,value)
local previous_mode=device:get_field(mode_field)
local action=device:get_field(probe_action_field)or "configure"
local cover_enabled=value==true or value==1
device:set_field(mode_field,cover_enabled,{persist=true})
device:set_field(probe_action_field,nil)
cancel_mode_timer(device)
local profile_changed=apply_mode_profile(device,cover_enabled,false,true)
if profile_changed then
device:set_field(pending_field,true)
return
end
device:set_field(pending_field,false)
if action=="refresh" and previous_mode==cover_enabled then
read_dynamic_branch(device,cover_enabled,extras)
else
configure_dynamic_branch(device,device:get_field(hub_field),cover_enabled,extras)
end
end
append(mappings,zcl.cluster_attribute(CLUSTER_BASIC,ATTR_DEVICE_ENABLED,{
name=mapping_prefix .. "_window_covering_enabled",
endpoint=3,
component="cover",
read_only=true,
data_type=data_types.Boolean,
handler=mode_handler,
}))
local function probe_dynamic_mode(device,hub_eui,action)
if hub_eui ~=nil then device:set_field(hub_field,hub_eui)end
device:set_field(pending_field,true)
device:set_field(probe_action_field,action)
cancel_mode_timer(device)
read(device,3,CLUSTER_BASIC,ATTR_DEVICE_ENABLED)
if device.thread ~=nil and type(device.thread.call_with_delay)=="function" then
local timer
timer=device.thread:call_with_delay(3,function()
if device:get_field(pending_field)==true and device:get_field(timer_field)==timer then
local retained_mode=device:get_field(mode_field)
if type(retained_mode)~="boolean" then
retained_mode=false
device:set_field(mode_field,retained_mode,{persist=true})
end
device:set_field(timer_field,nil)
device:set_field(probe_action_field,nil)
local profile_changed=apply_mode_profile(device,retained_mode,false,true)
if profile_changed then
device:set_field(pending_field,true)
return
end
device:set_field(pending_field,false)
if action=="refresh" then
read_dynamic_branch(device,retained_mode,extras)
else
configure_dynamic_branch(device,hub_eui,retained_mode,extras)
end
end
end,"wave14 Sber mode fallback " .. model)
device:set_field(timer_field,timer)
end
end
local function configure(driver,device)
local expected_profile=device:get_field(profile_reconfigure_field)
if expected_profile ~=nil and device.profile ~=nil and device.profile.id==expected_profile then
device:set_field(profile_reconfigure_field,nil)
local selected_mode=device:get_field(mode_field)
if type(selected_mode)=="boolean" then
device:set_field(pending_field,false)
local hub_eui=driver.environment_info.hub_zigbee_eui
if hub_eui ~=nil then device:set_field(hub_field,hub_eui)end
configure_dynamic_branch(device,hub_eui or device:get_field(hub_field),selected_mode,extras)
end
return
end
probe_dynamic_mode(device,driver.environment_info.hub_zigbee_eui,"configure")
end
local function parent_refresh(device,_,driver)
local hub_eui=driver ~=nil and driver.environment_info ~=nil and
driver.environment_info.hub_zigbee_eui or device:get_field(hub_field)
probe_dynamic_mode(device,hub_eui,"refresh")
end
local function runtime_start(device)
local persisted_mode=device:get_field(mode_field)
if type(persisted_mode)=="boolean" then
if apply_mode_profile(device,persisted_mode,false,true)then
device:set_field(pending_field,true)
end
end
end
return{
profile=switch_profile,
auxiliary_profiles={cover_profile},
sber_switch_profile=switch_profile,
sber_cover_profile=cover_profile,
sber_mode_field=mode_field,
sber_pending_field=pending_field,
valid_parent_profiles={[switch_profile]=true,[cover_profile]=true},
package_group="wave14-switch",
transport_classification="ZCL_DYNAMIC_SWITCH_OR_COVER",
z2m_converter_source="local sdevices fz/tz + dynamic exposes(device.meta.window_covering_enabled)",
wire_cluster="standard ZCL + Sber 0xFCCF/0x152F",
zcl_clusters=mappings,
capability_commands=commands,
button_actions={"pushed","held","double"},
component_to_endpoint_map={main=1,switch2=2,cover=3},
endpoint_to_component_map={[1]="main",[2]="switch2",[3]="cover"},
placeholder_custom_states=false,
runtime_start=runtime_start,
configure=configure,
parent_refresh=parent_refresh,
}
end
local function socket_definition()
local mapping_prefix="sber_202"
local capability_prefix="sber202"
local mappings={}
local commands={}
append(mappings,zcl.switch({endpoint=1,component="main",configure_reporting=false,read_on_configure=false}))
add_identify(mappings,commands,mapping_prefix,capability_prefix,1,"main",3)
add_power_on_behavior(mappings,mapping_prefix,capability_prefix,1,"main")
add_shared_mappings(mappings,mapping_prefix,capability_prefix,1,"main",1,1,false)
add_led_mappings(mappings,mapping_prefix,capability_prefix,1,"main",false)
for _,item in ipairs({
{"EmergencyOvervoltage","emergency_overvoltage",0x01},
{"EmergencyUndervoltage","emergency_undervoltage",0x02},
{"EmergencyOvercurrent","emergency_overcurrent",0x04},
{"EmergencyOverheat","emergency_overheat",0x08},
})do
append(mappings,sber_mapping(
ATTR_EMERGENCY_STATE,
mapping_prefix .. "_" .. item[2],
capability_prefix .. item[1],
data_types.Bitmap16,
{
endpoint=1,
component="main",
read_only=true,
from_device=function(value)return bit32.band(value,item[3])~=0 and "active" or "clear" end,
}
))
end
append(mappings,zcl.cluster_attribute(
CLUSTER_DEVICE_TEMPERATURE,
0x0000,
{
name="device_temperature",
endpoint=1,
component="main",
read_only=true,
data_type=data_types.Int16,
emit=emit.temperature("C"),
}
))
append(mappings,zcl.cluster_attribute(CLUSTER_SBER,ATTR_RMS_VOLTAGE_MV,{
name="voltage",endpoint=1,component="main",read_only=true,
mfg_code=SBER_MFG_CODE,data_type=data_types.Uint32,
from_device=function(value)return value * 0.001 end,emit=emit.voltage(),
}))
append(mappings,zcl.cluster_attribute(CLUSTER_SBER,ATTR_RMS_CURRENT_MA,{
name="current",endpoint=1,component="main",read_only=true,
mfg_code=SBER_MFG_CODE,data_type=data_types.Uint32,
from_device=function(value)return value * 0.001 end,emit=emit.current(),
}))
append(mappings,zcl.cluster_attribute(CLUSTER_SBER,ATTR_ACTIVE_POWER_MW,{
name="power",endpoint=1,component="main",read_only=true,
mfg_code=SBER_MFG_CODE,data_type=data_types.Int32,
from_device=function(value)return value * 0.001 end,emit=emit.power(),
}))
append(mappings,sber_mapping(
ATTR_EMERGENCY_RECOVERY,
mapping_prefix .. "_emergency_recovery",
capability_prefix .. "EmergencyRecovery",
data_types.Bitmap16,
{
endpoint=1,component="main",
from_device=function(value)return({[0]="disabled",[1]="voltage_is_good"})[value]end,
to_device=function(value)return({disabled=0,voltage_is_good=1})[value]end,
}
))
local thresholds={
{ATTR_UPPER_VOLTAGE_THRESHOLD,"UpperVoltageThreshold","upper_voltage_threshold",data_types.Uint32,230000,260000,1000,"mV"},
{ATTR_LOWER_VOLTAGE_THRESHOLD,"LowerVoltageThreshold","lower_voltage_threshold",data_types.Uint32,100000,230000,1000,"mV"},
{ATTR_UPPER_CURRENT_THRESHOLD,"UpperCurrentThreshold","upper_current_threshold",data_types.Uint32,100,16000,100,"mA"},
{ATTR_UPPER_TEMPERATURE_THRESHOLD,"TemperatureThreshold","temperature_threshold",data_types.Int16,-200,200,1,"°C"},
}
for _,field in ipairs(thresholds)do
append(mappings,sber_mapping(
field[1],mapping_prefix .. "_" .. field[3],capability_prefix .. field[2],field[4],
{
endpoint=1,component="main",
numeric_range={minimum=field[5],maximum=field[6],step=field[7],unit=field[8]},
}
))
end
local function configure(driver,device)
read(device,1,CLUSTER_BASIC,ATTR_SERIAL_NUMBER)
read(device,1,CLUSTER_DEVICE_TEMPERATURE,0x0000)
read_many(device,1,CLUSTER_ON_OFF,{ATTR_ON_OFF,ATTR_STARTUP_ON_OFF})
read_many(device,1,CLUSTER_SBER,{
ATTR_CHILD_LOCK,ATTR_EMERGENCY_RECOVERY,
ATTR_RMS_VOLTAGE_MV,ATTR_RMS_CURRENT_MA,ATTR_ACTIVE_POWER_MW,
},SBER_MFG_CODE)
read_many(device,1,CLUSTER_SBER,{
ATTR_LED_ON_ENABLE,ATTR_LED_ON_HUE,ATTR_LED_ON_SATURATION,ATTR_LED_ON_BRIGHTNESS,
ATTR_LED_OFF_ENABLE,ATTR_LED_OFF_HUE,ATTR_LED_OFF_SATURATION,ATTR_LED_OFF_BRIGHTNESS,
},SBER_MFG_CODE)
read_many(device,1,CLUSTER_SBER,{
ATTR_UPPER_VOLTAGE_THRESHOLD,ATTR_LOWER_VOLTAGE_THRESHOLD,
ATTR_UPPER_CURRENT_THRESHOLD,ATTR_UPPER_TEMPERATURE_THRESHOLD,
},SBER_MFG_CODE)
bind(device,driver.environment_info.hub_zigbee_eui,1,{
CLUSTER_ON_OFF,CLUSTER_DEVICE_TEMPERATURE,CLUSTER_SBER,
})
bind(device,driver.environment_info.hub_zigbee_eui,1,{CLUSTER_DIAGNOSTICS})
end
return{
profile="switches-wave14-sber-sbdv-00202",
package_group="wave14-switch",
transport_classification="ZCL_CUSTOM_ATTRIBUTE_COMMAND",
z2m_converter_source="sdevices.fz.emergency_shutoff_state + sdevicesExtend",
wire_cluster="standard ZCL + Sber 0xFCCF/0x152F",
zcl_clusters=mappings,
capability_commands=commands,
placeholder_custom_states=false,
configure=configure,
}
end
local sber_196=single_definition("196","switches-wave14-sber-sbdv-00196",false)
local sber_197=single_definition("197","switches-wave14-sber-sbdv-00197",true)
local sber_199=dynamic_definition("199","switches-wave14-sber-sbdv-00199",false)
local sber_200=dynamic_definition("200","switches-wave14-sber-sbdv-00200",true)
local sber_202=socket_definition()
register_device_definition(sber_196,{device_helpers.create_fingerprint("SDevices","SBDV-00196")})
register_device_definition(sber_197,{device_helpers.create_fingerprint("SDevices","SBDV-00197")})
register_device_definition(sber_199,{device_helpers.create_fingerprint("SDevices","SBDV-00199")})
register_device_definition(sber_200,{device_helpers.create_fingerprint("SDevices","SBDV-00200")})
register_device_definition(sber_202,{device_helpers.create_fingerprint("SDevices","SBDV-00202")})
return{
id="wave14.sber.zcl_switches",
registrations=device_definitions,
}
