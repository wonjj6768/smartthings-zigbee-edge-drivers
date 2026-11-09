local c,l,g,A,J,n,d,Q,P=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"contracts.helpers.zcl",require"st.zigbee.device_management",require"st.capabilities",require"st.zigbee.data_types",require"st.zigbee.cluster_base",require"st.zigbee.zcl.global_commands.read_attribute"local z,m=g.definition_registry()local C={"AduroSmart ERIA","ERIA","AduroSmart Eria"}
local function p(ae)
local E={}for _,ah in ipairs(ae)do
for _,T in ipairs(C)do
E[#E+1]=g.create_fingerprint(T,ah)end
end
return E
end
local function r(O,af)
local f
f={profile=O,color_temperature_range={minimum=math.floor((1000000/500)+0.5),maximum=math.floor((1000000/153)+0.5)},zcl_clusters={c.switch{endpoint=1,configure_reporting=false},c.level{endpoint=1,configure_reporting=false},c.color_temperature{endpoint=1,configure_reporting=false}},
runtime_start=function(b)
b:emit_component_event({id="main"},n.colorTemperature.colorTemperatureRange{value=f.color_temperature_range,unit="K"})return true
end
}if af then
f.zcl_clusters[#f.zcl_clusters+1]=
c.color_hue{endpoint=1,configure_reporting=false}f.zcl_clusters[#f.zcl_clusters+1]=
c.color_saturation{endpoint=1,configure_reporting=false}f.zcl_clusters[#f.zcl_clusters+1]=c.color{endpoint=1}end
return f
end
local D,G=r("lights-color-temperature",false),r("lights-color-temperature-color",true)
local function x(value,ad,ac)
value=tonumber(value)if value==nil then return nil end
return math.max(ad,math.min(ac,math.floor(value+0.5)))
end
local function i(value)
value=tonumber(value)if value==nil then return nil end
return value/10
end
local function j(value)
if value=="disabled"then return 65535 end
value=tonumber(value)if value==nil then return nil end
if value>=6553.5 then return 65535 end
return math.max(0,math.min(65534,math.floor((value*10)+0.5)))
end
local K={profile="lights-candeo-rd1p-dpm",capability_commands={{capability_id="concertmirror08464.candeoRd1pDpmOnLevel",command_name="usePreviousOnLevel",mapping_name="candeo_rd1p_dpm_on_level",value="previous"},{capability_id="concertmirror08464.candeoRd1pDpmStartupLevel",command_name="useMinimumStartupLevel",mapping_name="candeo_rd1p_dpm_startup_level",value="minimum"},{capability_id="concertmirror08464.candeoRd1pDpmStartupLevel",command_name="usePreviousStartupLevel",mapping_name="candeo_rd1p_dpm_startup_level",value="previous"},{capability_id="concertmirror08464.candeoRd1pDpmOnTransitionTime",command_name="disableOnTransitionTime",mapping_name="candeo_rd1p_dpm_on_transition_time",value="disabled"},{capability_id="concertmirror08464.candeoRd1pDpmOffTransitionTime",command_name="disableOffTransitionTime",mapping_name="candeo_rd1p_dpm_off_transition_time",value="disabled"}},advanced_remote=true,unprefixed_remote_actions=true,remote_action_emit_name="candeoRd1pDpmAction",standard_command_action_resolver=A.resolve_rd1p_rotary_action,zcl_clusters={c.switch{endpoint=1,minimum_interval=0,maximum_interval=65000},c.level{endpoint=1,minimum_interval=1,maximum_interval=3600,reportable_change=1},c.power{endpoint=1,minimum_interval=5,maximum_interval=300,reportable_change=10},c.voltage{endpoint=1,minimum_interval=5,maximum_interval=600,reportable_change=500},c.current{endpoint=1,minimum_interval=5,maximum_interval=900,reportable_change=10},c.energy{endpoint=1,minimum_interval=5,maximum_interval=1800,reportable_change=50},c.cluster_attribute(c.CLUSTER_ON_OFF,16387,{name="candeo_rd1p_dpm_power_on_behavior",emit=l.candeoRd1pDpmPowerBehavior(),endpoint=1,
from_device=function(value)
return({[0]="off",[1]="on",[2]="toggle",[255]="previous"})[value]
end,
to_device=function(value)
return({off=0,on=1,toggle=2,previous=255})[value]
end,
data_type=d.Enum8,write_type=d.Enum8,read_on_configure=true}),c.cluster_attribute(c.CLUSTER_LEVEL_CONTROL,17,{name="candeo_rd1p_dpm_on_level",emit=l.candeoRd1pDpmOnLevel(),endpoint=1,
from_device=function(value)return x(value,0,255)end,
to_device=function(value)
if value=="previous"then return 255 end
return x(value,1,255)
end,
numeric_range={minimum=0,maximum=255,step=1},data_type=d.Uint8,write_type=d.Uint8,read_on_configure=true}),c.cluster_attribute(c.CLUSTER_LEVEL_CONTROL,16384,{name="candeo_rd1p_dpm_startup_level",emit=l.candeoRd1pDpmStartupLevel(),endpoint=1,
from_device=function(value)return x(value,0,255)end,
to_device=function(value)
if value=="minimum"then return 0 end
if value=="previous"then return 255 end
return x(value,0,255)
end,
numeric_range={minimum=0,maximum=255,step=1},data_type=d.Uint8,write_type=d.Uint8,read_on_configure=true}),c.cluster_attribute(c.CLUSTER_LEVEL_CONTROL,18,{name="candeo_rd1p_dpm_on_transition_time",emit=l.candeoRd1pDpmOnTransitionTime(),endpoint=1,from_device=i,to_device=j,numeric_range={minimum=0,maximum=6553.5,step=0.1,unit="s"},data_type=d.Uint16,write_type=d.Uint16,read_on_configure=true}),c.cluster_attribute(c.CLUSTER_LEVEL_CONTROL,19,{name="candeo_rd1p_dpm_off_transition_time",emit=l.candeoRd1pDpmOffTransitionTime(),endpoint=1,from_device=i,to_device=j,numeric_range={minimum=0,maximum=6553.5,step=0.1,unit="s"},data_type=d.Uint16,write_type=d.Uint16,read_on_configure=true})},
configure=function(R,b)
for _,V in ipairs{{endpoint=1,cluster_id=c.CLUSTER_ON_OFF},{endpoint=1,cluster_id=c.CLUSTER_LEVEL_CONTROL},{endpoint=1,cluster_id=c.CLUSTER_ELECTRICAL_MEASUREMENT},{endpoint=1,cluster_id=c.CLUSTER_SIMPLE_METERING},{endpoint=2,cluster_id=c.CLUSTER_ON_OFF},{endpoint=2,cluster_id=c.CLUSTER_LEVEL_CONTROL}}do
b:send(J.build_bind_request(b,V.cluster_id,R.environment_info.hub_zigbee_eui,V.endpoint))end
end
}local o
o={profile="lights-paulmann-rgbww",auto_on_before_light_command=false,capability_commands={{capability_id="concertmirror08464.paulmannRgbwwStartupCct",command_name="restorePaulmannRgbwwPreviousCct",mapping_name="paulmann_rgbww_startup_color_temperature",value=65535}},color_temperature_range={minimum=math.floor((1000000/454)+0.5),maximum=math.floor((1000000/153)+0.5)},zcl_clusters={c.switch{configure_reporting=false},c.level{configure_reporting=false},c.color_temperature{configure_reporting=false,
to_device=function(value)return math.max(153,math.min(454,math.floor(1000000/value+0.5)))end
},c.color_hue{configure_reporting=false},c.color_saturation{configure_reporting=false},c.color(),c.cluster_attribute(c.CLUSTER_ON_OFF,16387,{name="paulmann_rgbww_power_on_behavior",emit=l.paulmannRgbwwPowerOnBehavior(),
from_device=function(value)
value=type(value)=="table"and value.value or value
return({[0]="off",[1]="on",[2]="toggle",[255]="previous"})[value]
end,
to_device=function(value)
return({off=0,on=1,toggle=2,previous=255})[value]
end,
data_type=d.Enum8,write_type=d.Enum8}),c.cluster_attribute(c.CLUSTER_COLOR_CONTROL,16400,{name="paulmann_rgbww_startup_color_temperature",emit=l.paulmannRgbwwStartupCct(),
from_device=function(value)return value end,
to_device=function(value)
value=tonumber(value)if value==65535 then return value end
if value==nil then return nil end
return math.max(153,math.min(454,math.floor(value+0.5)))
end,
data_type=d.Uint16,write_type=d.Uint16}),c.cluster_attribute(3,65535,{name="paulmann_rgbww_effect",emit=l.paulmannRgbwwEffect(),write_only=true,sender=c.send_light_effect})},
configure=function(_,b)
for _,y in ipairs{16394,16395,16396}do
c.read_mapping(b,c.cluster_attribute(768,y,{endpoint=1}))end
end,
runtime_start=function(b)
b:emit_component_event({id="main"},n.colorTemperature.colorTemperatureRange{value=o.color_temperature_range,unit="K"})return true
end
}A.append_clusters(o.zcl_clusters,c.color_xy{endpoint=1})local H
H={profile="lights-color-temperature-color",color_temperature_range={minimum=math.floor((1000000/500)+0.5),maximum=math.floor((1000000/153)+0.5)},zcl_clusters={c.switch{endpoint=1},c.level{endpoint=1},c.color_temperature{endpoint=1},c.color_hue{endpoint=1},c.color_saturation{endpoint=1},c.color{endpoint=1},c.cluster_attribute(0,1,{name="hejhome_z26_app_version_keepalive",endpoint=1,read_only=true,data_type=d.Uint8,read_on_configure=true,poll_interval=120})},
runtime_start=function(b)
b:emit_component_event({id="main"},n.colorTemperature.colorTemperatureRange{value=H.color_temperature_range,unit="K"})return true
end
}
local function q(b,I,value,h)
if I.name=="luumr_g9_do_not_disturb"then
return c.send_raw_cluster_command(b,768,250,string.char(value=="enabled"and 1 or 0),h.endpoint or 1)end
local t=({blink=0,breathe=1,okay=2,channel_change=11,finish_effect=254,stop_effect=255})[value]return c.send_raw_cluster_command(b,3,64,string.char(t,0),h.endpoint or 1)
end
local Z={profile="lights-luumr-g9",auto_on_before_light_command=false,color_temperature_range={minimum=2000,maximum=6536},zcl_clusters={c.tuya_magic_packet{read_on_configure=false},c.switch{endpoint=1,minimum_interval=0,maximum_interval=65000},c.level{endpoint=1,minimum_interval=5,maximum_interval=65000,reportable_change=1},c.color_temperature{endpoint=1,minimum_interval=10,maximum_interval=65000,reportable_change=1,
to_device=function(value)return math.max(153,math.min(500,math.floor(1000000/value+0.5)))end
},c.cluster_attribute(8,61440,{name="luumr_g9_tuya_brightness",endpoint=1,data_type=d.Uint16,read_only=true,emit=l.level(),
from_device=function(value)return math.floor(value/10+0.5)end
}),c.cluster_attribute(3,65535,{name="luumr_g9_effect",endpoint=1,write_only=true,suppress_optimistic_state=true,emit=l.luumrG9Effect(),sender=q}),c.cluster_attribute(768,65534,{name="luumr_g9_do_not_disturb",endpoint=1,write_only=true,emit=l.luumrG9DoNotDisturb(),sender=q})},
configure=function(R,b)
local ab=R.environment_info.hub_zigbee_eui
for _,aa in ipairs{6,8,768}do c.bind_cluster(b,aa,ab,1)end
for _,y in ipairs{16394,16395,16396}do c.read_attribute(b,768,y,1)end
end,
runtime_start=function(b)
b:emit_component_event({id="main"},n.colorTemperature.colorTemperatureRange{value={minimum=2000,maximum=6536},unit="K"})return true
end,
parent_refresh=function(b)
for _,S in ipairs{{6,0},{8,0},{768,7}}do c.read_attribute(b,S[1],S[2],1)end
return true
end
}
local function k(b,I,value,h)
if I.name:sub(-7)=="_effect"then
local s=h.endpoint or 1
if value=="colorloop"or value=="stop_colorloop"then
local U=c.send_raw_cluster_command(b,768,1,string.char(value=="colorloop"and 1 or 0,value=="colorloop"and 17 or 1,0,0),s)if value=="stop_colorloop"and U~=false then
b.thread:call_with_delay(0.1,function()
c.read_attribute(b,768,0,s)c.read_attribute(b,768,8,s)
end)
end
return U
end
local t=({blink=0,breathe=1,okay=2,channel_change=11,finish_effect=254,stop_effect=255})[value]return c.send_raw_cluster_command(b,3,64,string.char(t,0),s)end
if I.name:find("_do_not_disturb",1,true)then
return c.send_raw_cluster_command(b,768,250,string.char(value=="enabled"and 1 or 0),h.endpoint or 1)end
local ai=({initial=0,previous=1,customized=2})[value]return c.send_raw_cluster_command(b,768,249,string.char(0,ai)..string.rep("\0",10),h.endpoint or 1)
end
local function u(O,F,B)
local f={profile=O,auto_on_before_light_command=false,initial_custom_state_query=false,zcl_clusters={c.switch{endpoint=1,configure_reporting=false},c.level{endpoint=1,configure_reporting=false},c.color_hue{endpoint=1,configure_reporting=false},c.color_saturation{endpoint=1,configure_reporting=false},c.color{endpoint=1},c.cluster_attribute(8,61440,{name=F.."_tuya_brightness",endpoint=1,data_type=d.Uint16,read_only=true,
emit=l.level(),from_device=function(value)return math.floor(value/10+0.5)end
}),c.cluster_attribute(3,65535,{name=F.."_effect",endpoint=1,write_only=true,suppress_optimistic_state=true,emit=l[F.."Effect"](),sender=k}),c.cluster_attribute(768,65534,{name=F.."_do_not_disturb",endpoint=1,write_only=true,emit=l[F.."DoNotDisturb"](),sender=k}),c.cluster_attribute(768,65533,{name=F.."_color_power_on_behavior",endpoint=1,write_only=true,emit=l[F.."ColorPowerOnBehavior"](),sender=k})},
configure=function(_,b)
for _,y in ipairs{16394,16395,16396}do c.read_attribute(b,768,y,1)end
end,
parent_refresh=function(b)
for _,S in ipairs{{6,0},{8,0},{768,0},{768,1},{768,8}}do
c.read_attribute(b,S[1],S[2],1)end
if B then c.read_attribute(b,768,7,1)end
return true
end
}if B then
f.color_temperature_range={minimum=2000,maximum=6536}f.zcl_clusters[#f.zcl_clusters+1]=c.color_temperature{endpoint=1,configure_reporting=false,
to_device=function(value)return math.max(153,math.min(500,math.floor(1000000/value+0.5)))end
}
f.runtime_start=function(b)
b:emit_component_event({id="main"},n.colorTemperature.colorTemperatureRange{value={minimum=2000,maximum=6536},unit="K"})return true
end
end
return f
end
local M,L=u("lights-tuya-ts0505b-hs","ts0505bHs",true),u("lights-tuya-ts0503b-hs","ts0503bHs",false)
local function e(b)
return b:get_endpoint(8)
end
local function v(value,b)
b:set_field("_ecodo_brightness",value)return math.floor(math.max(0,math.min(254,value))*100/254+0.5)
end
local w={profile="lights-ecodo-repeater",component_to_endpoint=e,auto_on_before_light_command=false,initial_custom_state_query=false,capability_commands={},protocol_writers={
brightness=function(b,value,N)
if type(value)~="number"or value%1~=0 or value<0 or value>100 then return false end
local ag,aj=math.floor(value*254/100+0.5),math.max(0,math.min(65535,math.floor(tonumber(N.args.rate)or 0)))local U=c.send_raw_cluster_command(b,8,4,string.pack("<BI2BB",ag,aj,0,0),e(b))if U~=false then
b:emit_component_event({id=N.component or"main"},l.level()(b,value))b:emit_component_event({id=N.component or"main"},l.switch()(b,value>0))end
return U~=false
end
},zcl_clusters={c.switch{endpoint=e,configure_reporting=false,read_on_configure=false},c.cluster_attribute(8,0,{name="ecodo_standard_brightness",endpoint=e,data_type=d.Uint8,read_only=true,read_on_configure=false,emit=l.level(),from_device=v}),c.cluster_attribute(8,61440,{name="ecodo_tuya_brightness",endpoint=e,data_type=d.Uint16,read_only=true,read_on_configure=false,read_on_refresh=false,emit=l.level(),
from_device=function(value,b)
return v(math.floor(value*255/1000+0.5),b)
end
}),{name="ecodo_do_not_disturb",cluster_id=768,endpoint=e,write_only=true,emit=l.ecodoRepeaterDoNotDisturb(),
sender=function(b,_,value,h)
if value~="enabled"and value~="disabled"then return false end
return c.send_raw_cluster_command(b,768,250,string.char(value=="enabled"and 1 or 0),h.endpoint)
end
},{name="ecodo_effect",cluster_id=3,endpoint=e,write_only=true,suppress_optimistic_state=true,
sender=function(b,_,value,h)
local t=({blink=0,breathe=1,okay=2,channel_change=11,finish_effect=254,stop_effect=255})[value]if t==nil then return false end
return c.send_raw_cluster_command(b,3,64,string.char(t,0),h.endpoint)
end
},c.cluster_attribute(768,16394,{name="ecodo_color_capabilities",data_type=d.Bitmap16,read_only=true,read_on_configure=false,read_on_refresh=false,
handler=function(b,_,h)
local X=h.zb_rx and h.zb_rx.body and h.zb_rx.body.zcl_header
if X and X.cmd.value==1 then
local W=Q.read_attribute(b,d.ClusterId(768),d.AttributeId(16395))W.body.zcl_body=P.ReadAttribute{d.AttributeId(16395),d.AttributeId(16396)}b:send(W:to_endpoint(h.endpoint))end
end
})},
configure=function(_,b)
for _,s in pairs(b.zigbee_endpoints)do
if b:supports_server_cluster(768,s.id)then
c.read_attribute(b,768,16394,s.id)end
end
end
}for _,t in ipairs{{"blink","blink"},{"breathe","breathe"},{"okay","okay"},{"channelChange","channel_change"},{"finishEffect","finish_effect"},{"stopEffect","stop_effect"}}do
w.capability_commands[#w.capability_commands+1]={capability_id="concertmirror08464.ecodoRepeaterEffect",command_name=t[1],mapping_name="ecodo_effect",value=t[2]}end
m(K,{g.create_fingerprint("Candeo","C-ZB-RD1Pv2-DPM")})m(o,{g.create_fingerprint("Paulmann Licht GmbH","RGBWW")})m(H,{g.create_fingerprint("_TZ3210_cnicaghm","TS0505B")})m(D,p{"AD-DL4CT3001","AD-DL4CTW3001","AD-DL6CT3001","AD-DL6CTW3001","AD-FLMCT3001"})m(G,p{"AD-DL4RGBW3001","AD-DL6RGBW3001","AD-GU10RGB3001","AD-GU10RGBW3001"})m(Z,{g.create_fingerprint("_TZ3210_tqwyiitv","TS0502B")})m(M,{g.create_fingerprint("_TZ3210_ffuna0nr","TS0505B")})m(L,{g.create_fingerprint("_TZ3210_rbixajyp","TS0503B"),g.create_fingerprint("_TZ3210_w7ge4ldo","TS0503B")})m(w,{g.create_fingerprint("_TZ3210_cmnwaylf","TS0501B")})c.attach_reporting_capabilities(z,{{1,"rpt-cxt"},{3,"rpt-tkj"},{6,"rpt-tcn"}})return{id="zcl.lights.z2m_absorption",registrations=z}
