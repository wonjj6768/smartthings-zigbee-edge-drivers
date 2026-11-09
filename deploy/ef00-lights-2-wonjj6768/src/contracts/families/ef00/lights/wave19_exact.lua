local d,aq,p,j=require"protocol.tuya",require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family"local P,e=j.definition_registry()local g=d.converter
local function h(capability_id)
return assert(p[capability_id],"missing Wave19 light emitter: "..capability_id)()
end
local function k(c,ak,aj)
local T=tonumber(c)if T==nil then return nil end
return math.max(ak,math.min(aj,T))
end
local function l(c)
if c==nil then return nil end
return math.floor(c+0.5)
end
local a=g.from_to(
function(c)return l(k(c,0,1000)/10)end,
function(c)return l(k(c,0,100)*10)end
)local z,al=g.lookup_from_to{off=0,on=1,previous=2},g.lookup_from_to{OFF=false,ON=true}
local function A(ab,ad)
return{profile=ab,package_group="wave19-light",magic_packet=true,query_on_configure=false,named_datapoints=true,time_start="off",datapoints=ad}
end
local function D(ab,b,x)
local W,V,U,H=h(b.."MinBrightness"),h(b.."MaxBrightness"),h(b.."SwitchType"),h(b.."Countdown")return A(ab,{d.dp_on_off(1,{name="switch",component="main",transaction=1,emit=p.switch()}),d.dp_numeric(2,{name="brightness",component="main",transaction=1,converter=a,emit=p.level()}),d.dp_numeric(3,{name=b.."_min_brightness",component="main",transaction=1,converter=a,emit=W}),d.dp_enum(4,{name=b.."_switch_type",component="main",transaction=1,converter=x,emit=U}),d.dp_numeric(5,{name=b.."_max_brightness",component="main",transaction=1,converter=a,emit=V}),d.dp_numeric(6,{name=b.."_countdown",component="main",transaction=1,emit=H}),d.dp_on_off(7,{name="switch",component="switch2",transaction=1,emit=p.switch()}),d.dp_numeric(8,{name="brightness",component="switch2",transaction=1,converter=a,emit=p.level()}),d.dp_numeric(9,{name=b.."_min_brightness",component="switch2",transaction=1,converter=a,emit=W}),d.dp_enum(10,{name=b.."_switch_type",component="switch2",transaction=1,converter=x,emit=U}),d.dp_numeric(11,{name=b.."_max_brightness",component="switch2",transaction=1,converter=a,emit=V}),d.dp_numeric(12,{name=b.."_countdown",component="switch2",transaction=1,emit=H}),d.dp_enum(14,{name=b.."_power_behavior",transaction=1,converter=z,emit=h(b.."PowerBehavior")})})
end
local am=D("lights-wave19-avatto-zdms16-us-w2","avattoWTwo",g.lookup_from_to{toggle=0,state=1,momentary=2})e(am,{j.create_fingerprint("_TZE204_sdykkwsu","TS0601")})local y,m,i="wave19_lidl_hue","wave19_lidl_saturation","wave19_lidl_brightness"
local function F(c,af)
if type(c)~="string"or #c<12 then return nil end
return tonumber(c:sub(af,af+3),16)
end
local function O(c,f)
local n=F(c,1)if n==nil then return nil end
local ai=k(n/3.6,0,100)f:set_field(y,ai,{persist=false})return ai
end
local function C(c,f)
local ac=F(c,5)if ac==nil then return nil end
local K=k(ac/10,0,100)f:set_field(m,K,{persist=false})return K
end
local function s(c,f)
local ac=F(c,9)if ac==nil then return nil end
local o=l(k(ac,0,1000)/10)f:set_field(i,o,{persist=false})return o
end
local function t(c,f)
local o=l(k(c,0,1000)/10)f:set_field(i,o,{persist=false})return o
end
local function L(f,ao,capability_id,ae,ag)
local c=f:get_field(ao)if c==nil and type(f.get_latest_state)=="function"then
c=f:get_latest_state("main",capability_id,ae)end
local T=tonumber(c)if T==nil then return ag end
return T
end
local function R(f,ai,K,o)
local G,n,Q=false,360,tonumber(ai)

if Q~=nil and Q~=0 then
n=Q*3.6
G=true
else
local X=L(f,y,"colorControl","hue",0)if X~=0 then n=X*3.6 end
end
if G and n>=360 then n=359 end
n=l(k(n,0,G and 359 or 360))local w,r=tonumber(K),1000
if w~=nil and w~=0 then
r=l(k(w,0,100)*10)else
local J=L(f,m,"colorControl","saturation",0)if J~=0 then
r=l(k(J,0,100)*10)end
end
local u,q=tonumber(o),1000
if u~=nil and u~=0 then
q=l(k(u,0,100)*10)else
local I=L(f,i,"switchLevel","level",0)if I~=0 then
q=l(k(I,0,100)*10)end
end
f:set_field(y,n/3.6,{persist=false})f:set_field(m,r/10,{persist=false})f:set_field(i,q/10,{persist=false})return string.format("%04x%04x%04x",n,r,q)
end
local function M(_,c)
return{{dp=2,datatype=d.DP_TYPE_ENUM,value=0},{dp=3,datatype=d.DP_TYPE_VALUE,value=l(k(c,0,100)*10)}}
end
local function v(f,c)
if type(c)~="table"then return nil end
return{{dp=2,datatype=d.DP_TYPE_ENUM,value=1},{dp=5,datatype=d.DP_TYPE_STRING,value=R(f,c.hue,c.saturation,c.brightness)}}
end
local function aa(f,c)
return v(f,{hue=c})
end
local function N(f,c)
return v(f,{saturation=c})
end
local Y={d.dp_enum(2,{name="lidl_change_mode",read_only=true,transaction=1}),d.dp_numeric(3,{name="lidl_brightness_report",read_only=true,transaction=1,converter=g.from_only(t),emit=p.level()}),d.dp_string(5,{name="lidl_hue_report",read_only=true,transaction=1,converter=g.from_only(O),emit=p.color_hue()}),d.dp_string(5,{name="lidl_saturation_report",read_only=true,transaction=1,converter=g.from_only(C),emit=p.color_saturation()}),d.dp_string(5,{name="lidl_color_brightness_report",read_only=true,transaction=1,converter=g.from_only(s),emit=p.level()}),d.dp_string(6,{name="lidl_effect_payload",read_only=true,transaction=1})}local ap={profile="lights-wave19-lidl-hg06467",package_group="wave19-light",magic_packet=false,query_on_configure=false,time_start="off",auto_connection_status=false,initial_custom_state_query=false,refresh_state_query=false,auto_on_before_light_command=false,datapoints=Y,named_mapping={named_mappings={brightness=M,color=v,color_hue=aa,color_saturation=N}},zcl_clusters={aq.switch{endpoint=1,read_only=false,configure_reporting=false,read_on_configure=false}}}e(ap,{j.create_fingerprint("_TZE200_s8gkrkxk","TS0601")})local ah=D("lights-wave19-lonsonho-vm-s02-010v","lonsonhoVmTwo",g.lookup_from_to{momentary=0,toggle=1,state=2})e(ah,{j.create_fingerprint("_TZE600_wxq8dpha\0","TS0603")})local qa=A("lights-wave19-qa-qadz4din",{d.dp_on_off(1,{name="switch",component="main",transaction=1,emit=p.switch()}),d.dp_numeric(2,{name="brightness",component="main",transaction=1,converter=a,emit=p.level()}),d.dp_numeric(3,{name="qaQadzFour_min_brightness",component="main",transaction=1,converter=a,emit=h"qaQadzFourMinBrightness"}),d.dp_on_off(7,{name="switch",component="switch2",transaction=1,emit=p.switch()}),d.dp_numeric(8,{name="brightness",component="switch2",transaction=1,converter=a,emit=p.level()}),d.dp_numeric(9,{name="qaQadzFour_min_brightness",component="switch2",transaction=1,converter=a,emit=h"qaQadzFourMinBrightness"}),d.dp_enum(14,{name="qaQadzFour_power_behavior",transaction=1,converter=z,emit=h"qaQadzFourPowerBehavior"}),d.dp_on_off(15,{name="switch",component="switch3",transaction=1,emit=p.switch()}),d.dp_numeric(16,{name="brightness",component="switch3",transaction=1,converter=a,emit=p.level()}),d.dp_numeric(17,{name="qaQadzFour_min_brightness",component="switch3",transaction=1,converter=a,emit=h"qaQadzFourMinBrightness"}),d.dp_on_off(101,{name="switch",component="switch4",transaction=1,emit=p.switch()}),d.dp_numeric(102,{name="brightness",component="switch4",transaction=1,converter=a,emit=p.level()}),d.dp_numeric(103,{name="qaQadzFour_min_brightness",component="switch4",transaction=1,converter=a,emit=h"qaQadzFourMinBrightness"}),d.dp_enum(105,{name="qaQadzFour_dimming_speed",transaction=1,converter=g.lookup_from_to{slow=0,middle=1,fast=2},emit=h"qaQadzFourDimmingSpeed"}),d.dp_enum(106,{name="qaQadzFour_switch_type",transaction=1,converter=g.lookup_from_to{momentary=0,toggle=1},emit=h"qaQadzFourSwitchType"})})e(qa,{j.create_fingerprint("_TZE284_nthhgkd6","TS0601")})local Z=g.from_to(
function(c)
local ac=k(c,10,1000)local B=l((ac-10)*254/990)return l(B*100/254)
end,
function(c)
local B=l(k(c,0,100)*254/100)return l(10+B*990/254)
end
)local S=g.from_to(
function(c)return l(k(c,10,1000)/10)end,
function(c)return l(k(c,1,100)*10)end
)local an=A("lights-wave19-nova-topazio",{d.dp_on_off(1,{name="switch",transaction=1,emit=p.switch()}),d.dp_numeric(2,{name="brightness",transaction=1,converter=Z,emit=p.level()}),d.dp_numeric(3,{name="novaTopazio_min_brightness",transaction=1,converter=S,emit=h"novaTopazioMinBrightness"}),d.dp_enum(4,{name="novaTopazio_light_type",transaction=1,converter=g.lookup_from_to{led=0,incandescent=1,halogen=2},emit=h"novaTopazioLightType"}),d.dp_numeric(5,{name="novaTopazio_max_brightness",transaction=1,converter=S,emit=h"novaTopazioMaxBrightness"}),d.dp_numeric(6,{name="novaTopazio_countdown",transaction=1,emit=h"novaTopazioCountdown"}),d.dp_enum(14,{name="novaTopazio_power_behavior",transaction=1,converter=z,emit=h"novaTopazioPowerBehavior"}),d.dp_enum(21,{name="novaTopazio_indicator_mode",transaction=1,converter=g.lookup_from_to{none=0,relay=1,pos=2},emit=h"novaTopazioIndicatorMode"}),d.dp_binary(26,{name="novaTopazio_backlight",transaction=1,converter=al,emit=h"novaTopazioBacklight"})})an.time_start="1970"e(an,{j.create_fingerprint("_TZE284_5yah8qx4","TS0601")})return{id="ef00.lights.wave19.exact",registrations=P}
