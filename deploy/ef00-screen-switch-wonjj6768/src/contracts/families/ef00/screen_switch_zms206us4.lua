local f,O,r=require"protocol.tuya",require"protocol.zcl",require"capabilities.events.screen_switch"local g,w=f.converter,require"runtime.utf8_text"

local function o(e,u)
local P=os.time()return f.send_time(e,P,P+u*3600)
end
local function l(j,M)
if w.length(j)==nil then return nil end
local m,v={},0
for _,A in utf8.codes(j)do
local H=A>65535 and 2 or 1
if M then
if H==2 then
m[#m+1]=string.char((55296+((A-65536)>>10))%256)if v+1<12 then m[#m+1]=string.char((56320+(A-65536)%1024)%256)end
else
m[#m+1]=string.char(A%256)end
else
m[#m+1]=utf8.char(v+H>12 and 65533 or A)end
v=v+H
if v>=12 then break end
end
return table.concat(m)
end
local function h(I,e,L)
local J=I.body.zcl_header
local F=J.frame_ctrl
if F:get_direction()~=1 or F:is_mfg_specific_set()or
I.body.zcl_body.body_bytes~=""then return end
local E=J.seqno.value
if e:get_field"zms206_last_default_response_sequence"==E then return end
if O.send_default_response(e,I,L.command_id)then
e:set_field("zms206_last_default_response_sequence",E,{persist=false})end
end
local d={on_off=g.lookup_from_to{off=false,on=true},backlight_mode=g.lookup_from_to{OFF=false,ON=true},child_lock=g.lookup_from_to{UNLOCK=false,LOCK=true},indicator_status=g.lookup_from_to{off=0,on_off_status=1,switch_position=2},color=g.lookup_from_to{red=0,blue=1,green=2,white=3,yellow=4,magenta=5,cyan=6,warm_white=7,warm_yellow=8},relay_status=g.lookup_from_to{power_off=0,power_on=1,restart_memory=2},radar_config=g.lookup_from_to{none=0,["10s"]=1,["20s"]=2,["30s"]=3,["45s"]=4,["60s"]=5},switch_name=g.from_to(
function(j)
if w.length(j)==nil then return nil end
return j
end,
function(j)
return l(j,false)
end
),cycle_schedule=g.from_to(
function(j)
if type(j)~="string"then return nil end
local N={}for K=1,#j do N[K]=utf8.char(j:byte(K))end
return table.concat(N)
end,
function(j)return l(j,true)end
)}
local function B(y)
local D={}for _,C in ipairs(y)do
D[#D+1]={manufacturer=C,model="TS0601"}end
return D
end
local function n(a,b,c)
if b.single_gang then
a[#a+1]=f.dp_on_off(1,{name="switch",component="main",emit=c.switch_main})return
end
for gang=1,b.gang_count do
a[#a+1]=f.dp_on_off(gang,{name="switch",component="switch"..gang,emit=c["switch_"..gang]})end
end
local function k(a,b,c)
if b.single_gang then
a[#a+1]=f.dp_countdown(7,{name=b.mapping_prefix.."_countdown",component="main",emit=c.countdown_main})return
end
for gang=1,b.gang_count do
a[#a+1]=f.dp_countdown(6+gang,{name=b.mapping_prefix.."_countdown",component="switch"..gang,emit=c["countdown_"..gang]})end
end
local function p(a,b,c)
if b.single_gang then
a[#a+1]=f.dp_enum(29,{name=b.mapping_prefix.."_relay_status",component="main",emit=c.relay_status_main,converter=d.relay_status})return
end
for gang=1,b.gang_count do
a[#a+1]=f.dp_enum(28+gang,{name=b.mapping_prefix.."_relay_status",component="switch"..gang,emit=c["relay_status_"..gang],converter=d.relay_status})end
end
local function q(a,b,c)
if b.single_gang then
a[#a+1]=f.dp_raw(105,{name=b.mapping_prefix.."_switch_name",component="main",emit=c.switch_name_main,converter=d.switch_name,suppress_optimistic_state=true})return
end
for gang=1,b.gang_count do
a[#a+1]=f.dp_raw(104+gang,{name=b.mapping_prefix.."_switch_name",component="switch"..gang,emit=c["switch_name_"..gang],converter=d.switch_name,suppress_optimistic_state=true})end
end
local function z(b)
local c,a=b.event_factory(),{}if not b.single_gang then
a[#a+1]=f.dp_on_off(13,{name="switch",component="main",emit=c.switch_main})end
n(a,b,c)k(a,b,c)if b.single_gang then
a[#a+1]=f.dp_on_off(13,{name="switch",component="main",emit=c.switch_main})end
a[#a+1]=f.dp_enum(15,{name=b.mapping_prefix.."_indicator_status",emit=c.indicator_status,converter=d.indicator_status})a[#a+1]=f.dp_numeric(14,{name=b.mapping_prefix.."_relay_status_raw"})a[#a+1]=f.dp_numeric(24,{name=b.mapping_prefix.."_test_bit"})a[#a+1]=f.dp_raw(201,{name=b.mapping_prefix.."_cycle_schedule",converter=d.cycle_schedule})a[#a+1]=f.dp_binary(16,{name=b.mapping_prefix.."_backlight_mode",emit=c.backlight_mode,converter=b.legacy_backlight_mode and d.on_off or d.backlight_mode})a[#a+1]=f.dp_enum(19,{name=b.mapping_prefix.."_delay_off_color",emit=c.delay_off_color,converter=d.color})p(a,b,c)a[#a+1]=f.dp_binary(101,{name=b.mapping_prefix.."_child_lock",emit=c.child_lock,converter=b.legacy_child_lock and d.on_off or d.child_lock})a[#a+1]=f.dp_numeric(102,{name=b.mapping_prefix.."_backlight_brightness",emit=c.backlight_brightness})a[#a+1]=f.dp_enum(103,{name=b.mapping_prefix.."_switch_color_on",emit=c.switch_color_on,converter=d.color})a[#a+1]=f.dp_enum(104,{name=b.mapping_prefix.."_switch_color_off",emit=c.switch_color_off,converter=d.color})q(a,b,c)a[#a+1]=f.dp_enum(111,{name=b.mapping_prefix.."_radar_config",emit=c.radar_config,converter=d.radar_config})return{profile=b.profile,time_start="1970",
time_handler=function(e)
return o(e,e:get_field"zms206_time_zone"or 0)
end,
protocol_writers={
zms206_time_zone=function(e,u)
if not o(e,u)then return false end
e:set_field("zms206_time_zone",u,{persist=true})return true
end
},
runtime_start=function(e)
e:emit_component_event({id="main"},c.time_zone(e,e:get_field"zms206_time_zone"or 0))
end,
magic_packet=true,mcu_version_request_on_configure=true,query_on_configure=false,query_on_announce=false,initial_custom_state_query=false,refresh_state_query=false,zcl_clusters={O.cluster_attribute(57344,nil,{command_id=208,command_extractor=h,endpoint=1,read_only=true}),O.cluster_attribute(57344,nil,{command_id=210,command_extractor=h,endpoint=1,read_only=true})},datapoints=a,fingerprints=B(b.manufacturers)}
end
local x=z{profile="switches-screen-zms206us4",event_factory=r.zms206us4,mapping_prefix="zms206",gang_count=4,legacy_child_lock=true,legacy_backlight_mode=false,manufacturers={"_TZE204_08qc13ct","_TZE204_wwaeqnrf","_TZE204_xibaabmu","_TZE204_y4jqpry8","_TZE284_wwaeqnrf","_TZE284_xibaabmu","_TZE284_y4jqpry8","_TZE28C1000000_xibaabmu","_TZE28C1000000_y4jqpry8","_TZE28C1000000_pmbxyf97"}}local s,i={x},{}for _,G in ipairs(s)do
i[#i+1]=G.fingerprints
end
return{id="ef00.screen_switch.zms206us4",definition=x,definitions=s,fingerprint_groups=i}
