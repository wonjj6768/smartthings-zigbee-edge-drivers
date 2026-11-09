local n,aF,B,c,R,ab=require"protocol.tuya",require"protocol.zcl",require"contracts.helpers.family",require"capabilities.events.all",require"contracts.helpers.ef00_switches",require"st.capabilities"local r=n.converter
local K,s=B.definition_registry()do
local Q,U,I,aG,ag,aD,ap,ad="m9pro.group_settings","m9pro.weather_inputs",{sunny=100,heavy_rain=101,cloudy=102,sandstorm=103,light_snow=104,snow=105,freezing_fog=106,rainstorm=107,shower=108,dust=109,spit=112,sleet=113,yin=114,freezing_rain=115,rain=118,fog=121,heavy_shower=123,heavy_snow=124,heavy_downpour=125,blizzard=126,hailstone=127,snow_shower=130,haze=140,thunder_shower=143},r.lookup_from_to{switch=0,scene=1,smart_light=2,curtain=3},r.lookup_from_to{switch=0,scene=1,smart_light=2,curtain=3,thermostat=4},r.lookup_from_to{motion=0,on_press=1,on=2},r.lookup_from_to{off=0,on=1,previous=2},r.lookup_from_to{switch_1=0,switch_2=1,switch_3=2,switch_4=3,switch_5=4,switch_6=5,switch_7=6,switch_8=7,switch_9=8}
local function ax(a)
if type(a)~="string"or not utf8.len(a)then return nil end
local k,Y={},0
for _,W in utf8.codes(a)do
if Y==8 then break end
local aE=W>65535 and 2 or 1
if Y+aE>8 then
k[#k+1]=utf8.char(65533)break
end
k[#k+1]=utf8.char(W)Y=Y+aE
end
return(table.concat(k):gsub(".",function(aa)return string.format("%04x",aa:byte())end))
end
local function ak(a)
if type(a)~="string"then return nil end
local ai={}for index=1,#a,4 do
local aI=a:sub(index,index+3):gsub("^%s*([+-]?)0[xX]","%1")local aH,aA=aI:match"^%s*([+-]?)(%x+)"local ac=tonumber(aA or"",16)or 0
if aH=="-"then ac=-ac end
ai[#ai+1]=string.char(ac&255)end
local o,V=table.concat(ai),{}local index=o:sub(1,3)=="\239\187\191"and 4 or 1
while index<=#o do
local v,M,aC,ao=o:byte(index),1,128,191
if v>=194 and v<=223 then M=2
elseif v>=224 and v<=239 then
M=3
if v==224 then aC=160 elseif v==237 then ao=159 end
elseif v>=240 and v<=244 then
M=4
if v==240 then aC=144 elseif v==244 then ao=143 end
end
local O,as=1,v<128 or M>1
for offset=1,M-1 do
local aa,aw,av=o:byte(index+offset),offset==1 and aC or 128,offset==1 and ao or 191
if not aa or aa<aw or aa>av then as=false;break end
O=O+1
end
V[#V+1]=as and o:sub(index,index+M-1)or utf8.char(65533)index=index+O
end
return table.concat(V)
end
local E={to=ax,from=ak}
local function q(d,j,a)
if a==nil then return end
local aq=j(d,a)if aq then d:emit_component_event({id="main"},aq)end
end
local function N(d)
local f=d:get_field(Q)if not f then return end
for channel=1,4 do
local l=f.values["l"..channel]if l then d.driver:add_hub_to_zigbee_group(l)end
end
end
local function X(d,af)
local f,ae=d:get_field(Q),nil
if not f then return nil end
for _,channel in ipairs(f.order)do
if f.values[channel]==af then ae=channel end
end
return ae
end
local function ah(d,channel,a,j)
if type(a)~="number"or a%1~=0 or a<1 or a>10000 then return false end
local P,f=d:get_field(Q),{values={},order={}}if P then
for H,l in pairs(P.values)do f.values[H]=l end
for _,H in ipairs(P.order)do f.order[#f.order+1]=H end
end
if f.values[channel]==nil then f.order[#f.order+1]=channel end
f.values[channel]=a
local Z={}for index=1,4 do
local l=f.values["l"..index]if l then Z[#Z+1]=string.pack("<I2B",l,index)end
end
d.driver:add_hub_to_zigbee_group(a)if not aF.send_raw_cluster_command(d,4,240,string.char(#Z)..table.concat(Z),1,"server",nil,true)then return false end
d:set_field(Q,f,{persist=true})q(d,j,a)return true
end
local function ar(a)
if type(a)~="number"or a~=a or a<-32768 or a>32767 then return nil end
local at=math.modf(a)return at
end
local function w(F,u,p)
if u<3 then return nil end
local k={string.char(17,0,18,u,19,p and 1 or 0)}for aB,x in ipairs{"temperature","humidity","condition"}do
k[#k+1]=string.char(aB)for day=p and 0 or 1,u do
local a=F[x .."_"..day]if aB==3 then
k[#k+1]=string.char(a==nil and 0 or I[a])else
k[#k+1]=string.pack(">i2",ar(a==nil and 0 or a))end
end
end
k[#k+1]="\0"k[#k+1]=string.rep("\0",u-3)return table.concat(k)
end
local function J(d,H,x,a,j)
if x=="condition"then
if I[a]==nil then return false end
else
if ar(a)==nil then return false end
if H=="temperature_1"and(a<-65 or a>99)then return false end
end
local F={}for y,aK in pairs(d:get_field(U)or{})do F[y]=aK end
F[H]=a
if not n.send_raw(d,97,w(F,3,true))then return false end
d:set_field(U,F,{persist=true})if j then q(d,j,a)end
return true
end
local function T(m)
if not m or #m<6 then return nil end
local index,D=5,m:byte(5)while D and D~=18 and D~=19 do
index=index+1
D=m:byte(index)end
if not D then return nil end
index=index+1
local u=0
if D==18 then
u=m:byte(index)index=index+2
end
local p=m:byte(index)if u==nil or p==nil then return nil end
return u,p~=0
end
local function G(t)
if type(t.body_bytes)=="string"then return t.body_bytes end
if type(t.serialize)=="function"then return t:serialize()end
end
local h={mode_l1=c.m9proModeOne(),mode_l2=c.m9proModeTwo(),mode_l3=c.m9proModeThree(),mode_l4=c.m9proModeFour(),show_weather=c.m9proShowWeather(),show_screen=c.m9proScreen(),power_on_behavior=c.m9proPowerMemory(),power_on_behavior_l1=c.m9proPowerOne(),power_on_behavior_l2=c.m9proPowerTwo(),power_on_behavior_l3=c.m9proPowerThree(),power_on_behavior_l4=c.m9proPowerFour(),backlight=c.m9proBacklight(),scene_switch=c.m9proScene(),name_l1=c.m9proSwitchOneName{allow_empty=true},name_l2=c.m9proSwitchTwoName{allow_empty=true},name_l3=c.m9proSwitchThreeName{allow_empty=true},name_l4=c.m9proSwitchFourName{allow_empty=true},scene_name_l1=c.m9proSceneOneName{allow_empty=true},scene_name_l2=c.m9proSceneTwoName{allow_empty=true},scene_name_l3=c.m9proSceneThreeName{allow_empty=true},scene_name_l4=c.m9proSceneFourName{allow_empty=true},dimmer_name_l1=c.m9proDimmerOneName{allow_empty=true},dimmer_name_l2=c.m9proDimmerTwoName{allow_empty=true},dimmer_name_l3=c.m9proDimmerThreeName{allow_empty=true},dimmer_name_l4=c.m9proDimmerFourName{allow_empty=true},curtain_name_l1=c.m9proCurtainOneName{allow_empty=true},curtain_name_l2=c.m9proCurtainTwoName{allow_empty=true},curtain_name_l3=c.m9proCurtainThreeName{allow_empty=true},curtain_name_l4=c.m9proCurtainFourName{allow_empty=true},curtain_switch_l1=c.m9proCurtainOne(),curtain_switch_l2=c.m9proCurtainTwo(),curtain_switch_l3=c.m9proCurtainThree(),curtain_switch_l4=c.m9proCurtainFour(),dimmer_switch_l1=c.m9proDimmerOne(),dimmer_switch_l2=c.m9proDimmerTwo(),dimmer_switch_l3=c.m9proDimmerThree(),dimmer_switch_l4=c.m9proDimmerFour(),thermostat=c.m9proThermostat(),thermostat_name=c.m9proThermostatName{allow_empty=true},brightness_l1=c.m9proBrightnessOne(),color_temp_l1=c.m9proColorTempOne(),brightness_l2=c.m9proBrightnessTwo(),color_temp_l2=c.m9proColorTempTwo(),brightness_l3=c.m9proBrightnessThree(),color_temp_l3=c.m9proColorTempThree(),brightness_l4=c.m9proBrightnessFour(),color_temp_l4=c.m9proColorTempFour(),current_heating_setpoint=c.m9proSetpoint(),fan_mode=c.m9proFan(),group_id_l1=c.m9proGroupOne(),group_id_l2=c.m9proGroupTwo(),group_id_l3=c.m9proGroupThree(),group_id_l4=c.m9proGroupFour(),temperature_1=c.m9proWeatherTemp(),condition_1=c.m9proWeatherCondition()}local i={profile="switches-m9pro",package_group="switch-panel",datapoints={},zcl_clusters={},protocol_writers={},magic_packet=true,query_on_configure=false,query_on_announce=false,initial_custom_state_query=false,refresh_state_query=false,post_switch_state_query=false,force_time_updates=false,time_start="1970",mcu_version_request_on_configure=false,button_actions={"pushed"},
component_to_endpoint=function()return 1 end,
endpoint_to_component=function()return"main"end,
runtime_start=N,
configure=function(_,d)N(d)end
}local b=i.datapoints
for index,dp in ipairs{1,2,3,4,17}do
b[#b+1]=n.dp_enum(dp,{name="action_"..(index==5 and 0 or index),component=index==1 and"main"or"button"..index,read_only=true,
from_device=function()return"pushed"end,
emit=function(_,a)return ab.button.button(a,{state_change=true})end
})end
for channel=1,4 do
b[#b+1]=n.dp_enum(17+channel,{name="mode_l"..channel,converter=channel==4 and ag or aG,emit=h["mode_l"..channel]})end
for channel=1,4 do
b[#b+1]=n.dp_on_off(23+channel,{name="switch",component=channel==1 and"main"or"switch"..channel})end
b[#b+1]=n.dp_binary(36,{name="show_weather",converter=R.panel_off_on_converter,emit=h["show_weather"]})b[#b+1]=n.dp_enum(37,{name="show_screen",converter=aD,emit=h["show_screen"]})for channel=0,4 do
local y=channel==0 and"power_on_behavior"or"power_on_behavior_l"..channel
b[#b+1]=n.dp_enum(38+channel,{name=y,converter=ap,emit=h[y]})end
b[#b+1]=n.dp_binary(101,{name="backlight",converter=R.panel_off_on_converter,emit=h["backlight"]})b[#b+1]=n.dp_enum(102,{name="scene_switch",converter=ad,emit=h["scene_switch"]})for _,l in ipairs{{103,"name"},{107,"scene_name"},{111,"dimmer_name"},{115,"curtain_name"}}do
for channel=1,4 do
local y=l[2].."_l"..channel
b[#b+1]=n.dp_string(l[1]+channel-1,{name=y,converter=E,emit=h[y]})end
end
for _,l in ipairs{{119,"curtain_switch"},{123,"dimmer_switch"}}do
for channel=1,4 do
local y=l[2].."_l"..channel
b[#b+1]=n.dp_binary(l[1]+channel-1,{name=y,converter=R.panel_off_on_converter,emit=h[y]})end
end
b[#b+1]=n.dp_binary(127,{name="thermostat",converter=R.panel_off_on_converter,emit=h["thermostat"]})b[#b+1]=n.dp_string(128,{name="thermostat_name",converter=E,emit=h["thermostat_name"]})for _,C in ipairs(b)do
C.suppress_optimistic_state=true
if not C.read_only then
C.command_id,C.transaction,C.match_transaction=0,256,false
end
end
for channel=1,4 do
local logical="l"..channel
local j=h["group_id_"..logical]i.zcl_clusters[#i.zcl_clusters+1]=aF.cluster_attribute(4,nil,{name="group_id_"..logical,endpoint=1,read_only=false,write_only=true,emit=j,suppress_optimistic_state=true,
sender=function(d,_,a)return ah(d,logical,a,j)end
})end
for _,x in ipairs{"temperature","condition"}do
local H,j=x .."_1",h[x .."_1"]i.zcl_clusters[#i.zcl_clusters+1]=aF.cluster_attribute(61184,nil,{name=H,endpoint=1,read_only=false,write_only=true,emit=j,suppress_optimistic_state=true,
sender=function(d,_,a)return J(d,H,x,a,j)end
})end
for _,x in ipairs{"temperature","humidity","condition"}do
for day=0,3 do
local H,an=x .."_"..day,x
i.protocol_writers[H]=function(d,a)
return J(d,H,an,a)
end
end
end
i.zigbee_message_handler=function(d,rx)
local L,aj=rx.address_header,rx.body and rx.body.zcl_header
if not L or not aj or L.src_endpoint.value~=1 or not aj.frame_ctrl:is_cluster_specific_set()then return end
local z,A=L.cluster.value,aj.cmd.value
if z==61184 and A==0 then
local am=n.parse_datapoint_report(rx)local S=am and am.datapoints[1]if not S then return end
local o=S.value_bytes
if S.dp==1 then
q(d,h["thermostat"],o:byte(1)and o:byte(1)~=0 and"on"or"off")elseif S.dp==2 then
q(d,h["current_heating_setpoint"],o:byte(4))elseif S.dp==5 then
q(d,h["fan_mode"],o:byte(1))end
elseif z==61184 and A==96 then
local u,p=T(G(rx.body.zcl_body))local m=u~=nil and w(d:get_field(U)or{},u,p)or nil
if m then n.send_raw(d,97,m)end
elseif(z==8 and(A==0 or A==4))or(z==768 and A==10)then
local channel=X(d,L.dest_addr.value)if not channel then return end
local t,a=rx.body.zcl_body,nil
if z==8 then
a=t.level and t.level.value
local o=a==nil and G(t)or nil
if o and #o>=3 then a=o:byte(1)end
q(d,h["brightness_"..channel],a)else
a=t.color_temperature_mireds and t.color_temperature_mireds.value
local o=a==nil and G(t)or nil
if o and #o>=4 then a=string.unpack("<I2",o)end
q(d,h["color_temp_"..channel],a)end
end
end
s(i,B.create_fingerprints("TS0601",{"_TZE284_iwyqtclw"}))end
return{id="ef00.switch.panel.m9pro",registrations=K}
