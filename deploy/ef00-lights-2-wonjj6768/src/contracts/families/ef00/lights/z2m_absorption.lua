local ar,c,e,g=require"st.capabilities",require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family"local ab,b=g.definition_registry()local d=c.converter
local function l(a,av,au)
if a<av then return av end
if a>au then return au end
return a
end
local function k(a)
return math.floor(a+0.5)
end
local z,n,r,h="wz5_color_hue","wz5_color_saturation","wz5_color_brightness",{minimum=2203,maximum=4000}
local function I(a,ad)
if type(a)~="string"or #a<12 then return nil end
return tonumber(a:sub(ad,ad+3),16)
end
local function Z(a,f)
local q=I(a,1)if q==nil then return nil end
local at=l(q/3.6,0,100)f:set_field(z,at,{persist=false})return at
end
local function N(a,f)
local Y=I(a,5)if Y==nil then return nil end
local t=l(Y/10,0,100)f:set_field(n,t,{persist=false})return t
end
local function B(a,f)
local Y=I(a,9)if Y==nil then return nil end
local o=l(k(Y/10),0,100)f:set_field(r,o,{persist=false})return o
end
local function C(a)
return l(k((tonumber(a)or 0)*255/1000),0,254)
end
local function G(f,aJ,ao,an,aA)
local a=f:get_field(aJ)if a==nil and type(f.get_latest_state)=="function"then
a=f:get_latest_state("main",ao,an)end
local aw=tonumber(a)if aw==nil then return aA end
return aw
end
local function R(f,at,t,o)
local q,L,ac=360,false,tonumber(at)

if ac~=nil and ac~=0 then
q=ac*3.6
L=true
else
local al=G(f,z,"colorControl","hue",0)if al~=0 then q=al*3.6 end
end
if L and q>=360 then q=359 end
q=l(k(q),0,L and 359 or 360)local u,A=1000,tonumber(t)
if A~=nil and A~=0 then
u=k(l(A,0,100)*10)else
local Q=G(f,n,"colorControl","saturation",0)if Q~=0 then
u=k(l(Q,0,100)*10)end
end
local s,T=1000,tonumber(o)
if T~=nil then
s=k(l(T,0,100)*10)else
local P=G(f,r,"switchLevel","level",nil)if P~=nil then
s=k(l(P,0,100)*10)end
end
f:set_field(z,q/3.6,{persist=false})f:set_field(n,u/10,{persist=false})f:set_field(r,s/10,{persist=false})return string.format("%04x%04x%04x",q,u,s)
end
local function O(_,a)
local o=l(tonumber(a)or 0,0,254)return{{dp=2,datatype=c.DP_TYPE_ENUM,value=0},{dp=3,datatype=c.DP_TYPE_VALUE,value=k(o*1000/255)}}
end
local function H(_,a)
local o=l(tonumber(a)or 0,0,100)return{{dp=2,datatype=c.DP_TYPE_ENUM,value=0},{dp=3,datatype=c.DP_TYPE_VALUE,value=k(o*10)}}
end
local function F(f,a)
if type(a)~="table"then return nil end
return{{dp=2,datatype=c.DP_TYPE_ENUM,value=1},{dp=5,datatype=c.DP_TYPE_STRING,value=R(f,a.hue,a.saturation,a.brightness)}}
end
local function M(f,a)
return{{dp=2,datatype=c.DP_TYPE_ENUM,value=1},{dp=5,datatype=c.DP_TYPE_STRING,value=R(f,nil,nil,a)}}
end
local function ap(f,a)
return F(f,{hue=a,saturation=G(f,n,"colorControl","saturation",100)})
end
local function X(f,a)
return F(f,{hue=G(f,z,"colorControl","hue",0),saturation=a})
end
local function y(a)
local Y=l(tonumber(a)or 0,0,1000)local aq=k(454+Y*(250-454)/1000)if aq<=0 then return nil end
return k(1000000/aq)
end
local function J(_,a)
local aI=l(tonumber(a)or h.minimum,h.minimum,h.maximum)local aq=l(k(1000000/aI),250,454)local Y=k((454-aq)*1000/(454-250))return{{dp=2,datatype=c.DP_TYPE_ENUM,value=0},{dp=4,datatype=c.DP_TYPE_VALUE,value=Y}}
end
local function v(f)
f:emit_component_event({id="main"},ar.colorTemperature.colorTemperatureRange{value=h,unit="K"})return true
end
local function p(D)
local V=c.dp_on_off(1,{name="switch",emit=e.switch(),transaction=1})local j,i={switch=V},{V,c.dp_enum(2,{name="wz5_work_mode",read_only=true})}if D.separate_white then
j.brightness=M
j[D.white_mapping_name]=O
i[#i+1]=c.dp_numeric(3,{name=D.white_mapping_name,read_only=true,emit=D.white_emitter,converter=d.from_only(C)})else
j.brightness=H
i[#i+1]=c.dp_numeric(3,{name="brightness",read_only=true,emit=e.level(),
converter=d.from_only(function(a)
return l(k((tonumber(a)or 0)/10),0,100)
end)
})end
if D.color_temperature then
j.color_temperature=J
i[#i+1]=c.dp_numeric(4,{name="wz5_color_temperature_report",read_only=true,emit=e.color_temperature(),converter=d.from_only(y)})end
if D.color then
j.color=F
j.color_hue=ap
j.color_saturation=X
i[#i+1]=c.dp_string(5,{name="wz5_color_hue_report",read_only=true,emit=e.color_hue(),converter=d.from_only(Z)})i[#i+1]=c.dp_string(5,{name="wz5_color_saturation_report",read_only=true,emit=e.color_saturation(),converter=d.from_only(N)})i[#i+1]=c.dp_string(5,{name="wz5_color_brightness_report",read_only=true,emit=e.level(),converter=d.from_only(B)})end
local as={profile=D.profile,magic_packet=false,query_on_configure=false,time_start="off",auto_connection_status=false,initial_custom_state_query=false,refresh_state_query=false,auto_on_before_light_command=false,named_mapping={named_mappings=j},datapoints=i}if D.color_temperature then
as.color_temperature_range=h
as.runtime_start=v
end
return as
end
local aG=p{profile="lights-dimmer-skydance-wz5-dim"}b(aG,g.create_fingerprints("TS0601",{"_TZE200_6qoazbre","_TZE200_fcooykb4"}))local aF=p{profile="lights-color-temperature-skydance-wz5-cct",color_temperature=true}b(aF,g.create_fingerprints("TS0601",{"_TZE200_2gtsuokt","_TZE200_gz3n0tzf","_TZE200_na98lvjp","_TZE200_nthosjmx"}))local aH=p{profile="lights-color-skydance-wz5-rgb",color=true}b(aH,g.create_fingerprints("TS0601",{"_TZE200_9hghastn","_TZE200_9mt3kgn0"}))local aB=p{profile="lights-color-skydance-wz5-rgbw",color=true,separate_white=true,white_mapping_name="wz5_rgbw_white_brightness",white_emitter=e.wz5RgbwWhiteBrightness()}b(aB,g.create_fingerprints("TS0601",{"_TZE200_3thxjahu","_TZE200_g9jdneiu"}))local ay=p{profile="lights-color-temperature-color-skydance-wz5-rgbcct",color=true,color_temperature=true,separate_white=true,white_mapping_name="wz5_rgbcct_white_brightness",white_emitter=e.wz5RgbcctWhiteBrightness()}b(ay,g.create_fingerprints("TS0601",{"_TZE200_aa9awrng","_TZE200_mde0utnv","_TZE204_zhiqbr7l"}))local x,ah=d.scale_pair(0,1000,0,100),d.lookup_from_to{toggle=0,state=1,momentary=2}local ak={profile="lights-dimmer-zdms16-1",mcu_version_request_on_configure=true,c.dp_on_off(1,{name="switch",emit=e.switch()}),c.dp_numeric(2,{name="brightness",emit=e.level(),converter=x}),c.dp_numeric(3,{name="zdms161_minimum_brightness",emit=e.zdmsOneMinimumBrightness(),converter=x}),c.dp_enum(4,{name="zdms161_switch_type",emit=e.zdmsOneSwitchType(),converter=ah}),c.dp_numeric(5,{name="zdms161_maximum_brightness",emit=e.zdmsOneMaximumBrightness(),converter=x}),c.dp_countdown(6,{name="zdms161_countdown",emit=e.zdmsOneCountdown()}),c.dp_power_on_behavior(14,{name="zdms161_power_on_behavior",emit=e.zdmsOnePowerOnBehavior()})}b(ak,g.create_fingerprints("TS0601",{"_TZE28C1000000_nqqylykc","_TZE28C1000000_huu3td85"}))
local W=d.from_only(function(a)
return l(k((tonumber(a)or 0)/10),0,100)
end)
local function K(_,a)
local aC=l(k(tonumber(a)or 0),0,100)if aC<=0 then
return{{dp=141,datatype=c.DP_TYPE_BOOL,value=false,transaction=1}}end
return{{dp=141,datatype=c.DP_TYPE_BOOL,value=true,transaction=1},{dp=142,datatype=c.DP_TYPE_VALUE,value=aC*10,transaction=2}}
end
local az={profile="lights-dimmer-power-voltage-current-core",magic_packet=true,mcu_version_request_on_configure=true,query_on_configure=false,time_start="off",named_mapping={named_mappings={brightness=K}},datapoints={c.dp_on_off(141,{name="switch",emit=e.switch()}),c.dp_numeric(142,{name="brightness",read_only=true,emit=e.level(),converter=W}),c.dp_current(21,{name="current",scale=1000,read_only=true,emit=e.current()}),c.dp_power(22,{name="power",scale=10,read_only=true,emit=e.power()}),c.dp_voltage(23,{name="voltage",scale=10,read_only=true,emit=e.voltage()})}}b(az,g.create_fingerprints("TS0601",{"_TZE284_da26abzz"}))local m=d.from_to(
function(a)return k(a*254/1000)end,
function(a)return k(a*1000/254)end
)local ai=d.scale_pair(0,1000,0,100)local am={profile="lights-dimmer-moes-sfd02-core",magic_packet=true,mcu_version_request_on_configure=true,query_on_configure=false,query_on_announce=false,refresh_state_query=false,time_start="off",c.dp_on_off(1,{name="switch",emit=e.switch(),skip=c.skip.state_on_and_brightness_present()}),c.dp_numeric(2,{name="brightness",emit=e.level(),converter=ai}),c.dp_numeric(3,{name="moes_sfd02_min_brightness",emit=e.moesSfd02MinBrightness(),converter=m}),c.dp_numeric(5,{name="moes_sfd02_max_brightness",emit=e.moesSfd02MaxBrightness(),converter=m}),c.dp_numeric(4,{name="moes_sfd02_light_type",emit=e.moesSfd02LightType(),receive_datatypes={2,4},converter=d.lookup_from_to{led=0,incandescent=1,halogen=2}}),c.dp_countdown(6,{name="moes_sfd02_countdown",emit=e.moesSfd02Countdown()}),c.dp_numeric(14,{name="moes_sfd02_power_behavior",emit=e.moesSfd02PowerBehavior(),receive_datatypes={2,4},converter=d.lookup_from_to{off=0,on=1,previous=2}}),c.dp_enum(21,{name="moes_sfd02_backlight_mode",emit=e.moesSfd02BacklightMode(),converter=d.lookup_from_to{off=0,normal=1,inverted=2}}),c.dp_binary(26,{name="moes_sfd02_induction_mode",emit=e.moesSfd02InductionMode(),converter=d.lookup_from_to{ON=true,OFF=false}}),c.dp_enum(101,{name="moes_sfd02_indicator_status",emit=e.moesSfd02IndicatorStatus(),converter=d.lookup_from_to{off=0,relay=1,invert=2}}),c.dp_enum(102,{name="moes_sfd02_vibration_mode",emit=e.moesSfd02VibrationMode(),converter=d.lookup_from_to{["Gear 0"]=0,["Gear 1"]=1,["Gear 2"]=2,["Gear 3"]=3}})}b(am,g.create_fingerprints("TS0601",{"_TZE284_t88bjhfu","_TZE284_z98viqa6"}))local af=d.from_to(
function(a)
return l(k((tonumber(a)or 0)*100/1000),0,100)
end,
function(a)
return l(k((tonumber(a)or 0)*1000/100),0,1000)
end
)local E={profile="lights-dimmer-mercator-siswd11-zb",query_on_configure=false,time_start="off",c.dp_on_off(1,{name="switch",emit=e.switch()}),c.dp_numeric(2,{name="brightness",emit=e.level(),converter=af})}b(E,g.create_fingerprints("TS0601",{"_TZE200_jowqowye"}))local aj={profile="lights-stair-ms032z-core",magic_packet=true,mcu_version_request_on_configure=true,query_on_configure=true,query_on_announce=true,time_start="off",datapoints={c.dp_on_off(1,{name="switch",emit=e.switch()}),c.dp_numeric(127,{name="brightness",emit=e.level()}),c.dp_occupancy(128,{name="motion_up",component="motionUp",read_only=true,emit=e.motion()}),c.dp_occupancy(129,{name="motion_down",component="motionDown",read_only=true,emit=e.motion()})}}b(aj,g.create_fingerprints("TS0601",{"_TZE284_rovbuqdo"}))local ae=d.from_to(
function(a)return k(a/10)end,
function(a)return k(a*10)end
)local aE={profile="lights-qa-qadz1lr",magic_packet=true,mcu_version_request_on_configure=true,query_on_configure=false,query_on_announce=false,time_start="off",datapoints={c.dp_on_off(1,{name="switch",emit=e.switch(),skip=c.skip.state_on_and_brightness_present()}),c.dp_numeric(2,{name="brightness",emit=e.level(),converter=ae}),c.dp_numeric(3,{name="qadz1lr_min_brightness",emit=e.qadz1lrMinBrightness(),converter=m}),c.dp_numeric(5,{name="qadz1lr_max_brightness",emit=e.qadz1lrMaxBrightness(),converter=m}),c.dp_countdown(6,{name="qadz1lr_countdown",emit=e.qadz1lrCountdown()}),c.dp_enum(14,{name="qadz1lr_power_on_behavior",emit=e.qadz1lrPowerBehavior(),converter=d.lookup_from_to{off=0,on=1,previous=2}}),c.dp_enum(101,{name="qadz1lr_switch_type",emit=e.qadz1lrSwitchType(),converter=d.lookup_from_to{toggle=0,momentary=1}}),c.dp_numeric(102,{name="qadz1lr_dimming_time",emit=e.qadz1lrDimmingTime()})}}b(aE,g.create_fingerprints("TS0601",{"_TZE28C1000000_brx4eku5"}))
local function U(a,ad,aD)
if type(a)~="string"or #a~=12 then return nil end
local Y=tonumber(a:sub(ad,ad+3),16)return Y and Y/aD or nil
end
local function w(f,a,S)
local aa=S and S.component_id or"main"local at,t=a.hue or f:get_latest_state(aa,"colorControl","hue")or 0,a.saturation or f:get_latest_state(aa,"colorControl","saturation")or 100

return{dp=aa=="fallingDot"and 113 or 5,datatype=c.DP_TYPE_STRING,value=string.format("%04x%04x03e8",k(l(at,0,100)*3.6),k(l(t,0,100)*10))}
end
local ag={profile="lights-sp107e",named_datapoints=true,magic_packet=true,query_on_configure=true,auto_on_before_light_command=false,datapoints={c.dp_on_off(1,{name="switch",emit=e.switch()}),c.dp_numeric(106,{name="brightness",emit=e.level()}),c.dp_numeric(101,{name="sp107_segment_count",emit=e.sp107SegmentCount()}),c.dp_numeric(102,{name="sp107_segment_pixels",emit=e.sp107SegmentPixels()}),c.dp_enum(103,{name="sp107_rgb_order",emit=e.sp107RgbOrder(),converter=d.lookup_from_to{RGB=0,RBG=1,GRB=2,GBR=3,BRG=4,BGR=5}}),c.dp_enum(104,{name="sp107_mode",emit=e.sp107Mode(),converter=d.lookup_from_to{solid=1,effects=2,music_strip=3,music_screen=4}}),c.dp_numeric(107,{name="sp107_speed",emit=e.sp107Speed()}),c.dp_numeric(108,{name="sp107_effect",emit=e.sp107Effect()}),c.dp_numeric(109,{name="sp107_strip_pattern",emit=e.sp107StripPattern()}),c.dp_numeric(110,{name="sp107_sensitivity",emit=e.sp107Sensitivity()}),c.dp_enum(112,{name="sp107_led_chip",emit=e.sp107LedChip(),converter=d.lookup_from_to{WS2811=0,DMX512=1,FW1935=2,APA102=3,SC6803=4,WS2801=5,UCS1903=6,TM1812=7,TM1814=8,SK6812=9}}),c.dp_numeric(114,{name="sp107_screen_pattern",emit=e.sp107ScreenPattern()})},named_mapping={named_mappings={color=w,
color_hue=function(f,a,S)return w(f,{hue=a},S)end,
color_saturation=function(f,a,S)return w(f,{saturation=a},S)end
}}}for _,ax in ipairs{{5,"main"},{113,"fallingDot"}}do
ag.datapoints[#ag.datapoints+1]=c.dp_string(ax[1],{name="color_hue",component=ax[2],read_only=true,
converter=d.from_only(function(a)return U(a,1,3.6)end),emit=e.color_hue()
})ag.datapoints[#ag.datapoints+1]=c.dp_string(ax[1],{name="color_saturation",component=ax[2],read_only=true,
converter=d.from_only(function(a)return U(a,5,10)end),emit=e.color_saturation()
})end
b(ag,g.create_fingerprints("TS0601",{"_TZE204_zajeikkt"}))return{id="ef00.lights.z2m_absorption",registrations=ab}
