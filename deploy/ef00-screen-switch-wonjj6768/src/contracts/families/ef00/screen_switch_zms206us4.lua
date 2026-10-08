local tuya=require"protocol.tuya"
local zcl=require"protocol.zcl"
local screen_switch_events=require"capabilities.events.screen_switch"
local converter=tuya.converter
local utf8_text=require"runtime.utf8_text"
local function send_screen_time(device,offset)
local utc=os.time()return tuya.send_time(device,utc,utc+offset*3600)
end
local function encode_screen_text(value,latin1)
if utf8_text.length(value)==nil then return nil end
local bytes,units={},0
for _,code in utf8.codes(value)do
local width=code>0xFFFF and 2 or 1
if latin1 then
if width==2 then
bytes[#bytes+1]=string.char((0xD800+((code-0x10000)>>10))%256)
if units+1<12 then bytes[#bytes+1]=string.char((0xDC00+(code-0x10000)%1024)%256)end
else
bytes[#bytes+1]=string.char(code%256)
end
else
bytes[#bytes+1]=utf8.char(units+width>12 and 0xFFFD or code)
end
units=units+width
if units>=12 then break end
end
return table.concat(bytes)
end
local function acknowledge_screen_report(zb_rx,device,mapping)
local header=zb_rx.body.zcl_header
local control=header.frame_ctrl
if control:get_direction()~=1 or control:is_mfg_specific_set()or
zb_rx.body.zcl_body.body_bytes~=""then return end
local sequence=header.seqno.value
if device:get_field("zms206_last_default_response_sequence")==sequence then return end
if zcl.send_default_response(device,zb_rx,mapping.command_id)then
device:set_field("zms206_last_default_response_sequence",sequence,{persist=false})
end
end
local converters={
on_off=converter.lookup_from_to({off=false,on=true}),backlight_mode=converter.lookup_from_to({OFF=false,ON=true}),child_lock=converter.lookup_from_to({UNLOCK=false,LOCK=true}),indicator_status=converter.lookup_from_to({off=0,on_off_status=1,switch_position=2}),color=converter.lookup_from_to({
red=0,blue=1,green=2,white=3,yellow=4,magenta=5,cyan=6,warm_white=7,warm_yellow=8,}),relay_status=converter.lookup_from_to({power_off=0,power_on=1,restart_memory=2}),radar_config=converter.lookup_from_to({none=0,["10s"]=1,["20s"]=2,["30s"]=3,["45s"]=4,["60s"]=5}),switch_name=converter.from_to(
function(value)
if utf8_text.length(value)==nil then return nil end
return value
end,
function(value)
return encode_screen_text(value,false)
end
),cycle_schedule=converter.from_to(
function(value)
if type(value)~="string"then return nil end
local text={}
for index=1,#value do text[index]=utf8.char(value:byte(index))end
return table.concat(text)
end,
function(value)return encode_screen_text(value,true)end
),}
local function fingerprints(manufacturers)
local result={}for _,manufacturer in ipairs(manufacturers)do
result[#result+1]={manufacturer=manufacturer,model="TS0601"}
end
return result
end
local function append_switch_datapoints(datapoints,config,events)
if config.single_gang then
datapoints[#datapoints+1]=tuya.dp_on_off(1,{
name="switch",component="main",emit=events.switch_main,})return
end
for gang=1,config.gang_count do
datapoints[#datapoints+1]=tuya.dp_on_off(gang,{
name="switch",component="switch"..gang,emit=events["switch_"..gang],})
end
end
local function append_countdown_datapoints(datapoints,config,events)
if config.single_gang then
datapoints[#datapoints+1]=tuya.dp_countdown(7,{
name=config.mapping_prefix.."_countdown",component="main",emit=events.countdown_main,})return
end
for gang=1,config.gang_count do
datapoints[#datapoints+1]=tuya.dp_countdown(6+gang,{
name=config.mapping_prefix.."_countdown",component="switch"..gang,emit=events["countdown_"..gang],})
end
end
local function append_relay_datapoints(datapoints,config,events)
if config.single_gang then
datapoints[#datapoints+1]=tuya.dp_enum(29,{
name=config.mapping_prefix.."_relay_status",component="main",emit=events.relay_status_main,converter=converters.relay_status,})return
end
for gang=1,config.gang_count do
datapoints[#datapoints+1]=tuya.dp_enum(28+gang,{
name=config.mapping_prefix.."_relay_status",component="switch"..gang,emit=events["relay_status_"..gang],converter=converters.relay_status,})
end
end
local function append_name_datapoints(datapoints,config,events)
if config.single_gang then
datapoints[#datapoints+1]=tuya.dp_raw(105,{
name=config.mapping_prefix.."_switch_name",component="main",emit=events.switch_name_main,converter=converters.switch_name,suppress_optimistic_state=true,})return
end
for gang=1,config.gang_count do
datapoints[#datapoints+1]=tuya.dp_raw(104+gang,{
name=config.mapping_prefix.."_switch_name",component="switch"..gang,emit=events["switch_name_"..gang],converter=converters.switch_name,suppress_optimistic_state=true,})
end
end
local function build_zms206(config)
local events=config.event_factory()local datapoints={}if not config.single_gang then
datapoints[#datapoints+1]=tuya.dp_on_off(13,{
name="switch",component="main",emit=events.switch_main,})
end
append_switch_datapoints(datapoints,config,events)append_countdown_datapoints(datapoints,config,events)if config.single_gang then
datapoints[#datapoints+1]=tuya.dp_on_off(13,{
name="switch",component="main",emit=events.switch_main,})
end
datapoints[#datapoints+1]=tuya.dp_enum(15,{
name=config.mapping_prefix.."_indicator_status",emit=events.indicator_status,converter=converters.indicator_status,})datapoints[#datapoints+1]=tuya.dp_numeric(14,{name=config.mapping_prefix.."_relay_status_raw"})datapoints[#datapoints+1]=tuya.dp_numeric(24,{name=config.mapping_prefix.."_test_bit"})datapoints[#datapoints+1]=tuya.dp_raw(201,{
name=config.mapping_prefix.."_cycle_schedule",converter=converters.cycle_schedule,})datapoints[#datapoints+1]=tuya.dp_binary(16,{
name=config.mapping_prefix.."_backlight_mode",emit=events.backlight_mode,converter=config.legacy_backlight_mode and converters.on_off or converters.backlight_mode,})datapoints[#datapoints+1]=tuya.dp_enum(19,{
name=config.mapping_prefix.."_delay_off_color",emit=events.delay_off_color,converter=converters.color,})append_relay_datapoints(datapoints,config,events)datapoints[#datapoints+1]=tuya.dp_binary(101,{
name=config.mapping_prefix.."_child_lock",emit=events.child_lock,converter=config.legacy_child_lock and converters.on_off or converters.child_lock,})datapoints[#datapoints+1]=tuya.dp_numeric(102,{
name=config.mapping_prefix.."_backlight_brightness",emit=events.backlight_brightness,})datapoints[#datapoints+1]=tuya.dp_enum(103,{
name=config.mapping_prefix.."_switch_color_on",emit=events.switch_color_on,converter=converters.color,})datapoints[#datapoints+1]=tuya.dp_enum(104,{
name=config.mapping_prefix.."_switch_color_off",emit=events.switch_color_off,converter=converters.color,})append_name_datapoints(datapoints,config,events)datapoints[#datapoints+1]=tuya.dp_enum(111,{
name=config.mapping_prefix.."_radar_config",emit=events.radar_config,converter=converters.radar_config,})return{
profile=config.profile,time_start="1970",
time_handler=function(device)
return send_screen_time(device,device:get_field("zms206_time_zone")or 0)
end,
protocol_writers={
zms206_time_zone=function(device,offset)
if not send_screen_time(device,offset)then return false end
device:set_field("zms206_time_zone",offset,{persist=true})return true
end,
},
runtime_start=function(device)
device:emit_component_event({id="main"},events.time_zone(device,device:get_field("zms206_time_zone")or 0))
end,
magic_packet=true,mcu_version_request_on_configure=true,query_on_configure=false,query_on_announce=false,initial_custom_state_query=false,refresh_state_query=false,zcl_clusters={
zcl.cluster_attribute(0xE000,nil,{
command_id=0xD0,command_extractor=acknowledge_screen_report,endpoint=1,read_only=true,}),zcl.cluster_attribute(0xE000,nil,{
command_id=0xD2,command_extractor=acknowledge_screen_report,endpoint=1,read_only=true,}),},datapoints=datapoints,fingerprints=fingerprints(config.manufacturers),}
end
local zms206us4=build_zms206({
profile="switches-screen-zms206us4",event_factory=screen_switch_events.zms206us4,mapping_prefix="zms206",gang_count=4,legacy_child_lock=true,legacy_backlight_mode=false,manufacturers={
"_TZE204_08qc13ct","_TZE204_wwaeqnrf","_TZE204_xibaabmu","_TZE204_y4jqpry8","_TZE284_wwaeqnrf","_TZE284_xibaabmu","_TZE284_y4jqpry8","_TZE28C1000000_xibaabmu","_TZE28C1000000_y4jqpry8","_TZE28C1000000_pmbxyf97",},})local definitions={zms206us4}local fingerprint_groups={}for _,definition in ipairs(definitions)do
fingerprint_groups[#fingerprint_groups+1]=definition.fingerprints
end
return{
id="ef00.screen_switch.zms206us4",definition=zms206us4,definitions=definitions,fingerprint_groups=fingerprint_groups,}
