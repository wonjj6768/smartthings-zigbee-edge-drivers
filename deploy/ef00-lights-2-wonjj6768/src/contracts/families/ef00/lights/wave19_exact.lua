local d,aq,o,j=require"protocol.tuya",require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family"local P,e=j.definition_registry()local g=d.converter
local function h(capability_id)
return assert(o[capability_id],"missing Wave19 light emitter: "..capability_id)()
end
local function k(c,ak,aj)
local S=tonumber(c)if S==nil then return nil end
return math.max(ak,math.min(aj,S))
end
local function l(c)
if c==nil then return nil end
return math.floor(c+0.5)
end
local a=g.from_to(
function(c)return l(k(c,0,1000)/10)end,
function(c)return l(k(c,0,100)*10)end
)local y,al=g.lookup_from_to{off=0,on=1,previous=2},g.lookup_from_to{OFF=false,ON=true}
local function z(aa,ad)
return{profile=aa,package_group="wave19-light",magic_packet=true,query_on_configure=false,named_datapoints=true,time_start="off",datapoints=ad}
end
local function C(aa,b,w)
local V,U,T,G=h(b.."MinBrightness"),h(b.."MaxBrightness"),h(b.."SwitchType"),h(b.."Countdown")return z(aa,{d.dp_on_off(1,{name="switch",component="main",transaction=1,emit=o.switch()}),d.dp_numeric(2,{name="brightness",component="main",transaction=1,converter=a,emit=o.level()}),d.dp_numeric(3,{name=b.."_min_brightness",component="main",transaction=1,converter=a,emit=V}),d.dp_enum(4,{name=b.."_switch_type",component="main",transaction=1,converter=w,emit=T}),d.dp_numeric(5,{name=b.."_max_brightness",component="main",transaction=1,converter=a,emit=U}),d.dp_numeric(6,{name=b.."_countdown",component="main",transaction=1,emit=G}),d.dp_on_off(7,{name="switch",component="switch2",transaction=1,emit=o.switch()}),d.dp_numeric(8,{name="brightness",component="switch2",transaction=1,converter=a,emit=o.level()}),d.dp_numeric(9,{name=b.."_min_brightness",component="switch2",transaction=1,converter=a,emit=V}),d.dp_enum(10,{name=b.."_switch_type",component="switch2",transaction=1,converter=w,emit=T}),d.dp_numeric(11,{name=b.."_max_brightness",component="switch2",transaction=1,converter=a,emit=U}),d.dp_numeric(12,{name=b.."_countdown",component="switch2",transaction=1,emit=G}),d.dp_enum(14,{name=b.."_power_behavior",transaction=1,converter=y,emit=h(b.."PowerBehavior")})})
end
local am=C("lights-wave19-avatto-zdms16-us-w2","avattoWTwo",g.lookup_from_to{toggle=0,state=1,momentary=2})e(am,{j.create_fingerprint("_TZE204_sdykkwsu","TS0601")})local x,m,i="wave19_lidl_hue","wave19_lidl_saturation","wave19_lidl_brightness"
local function E(c,af)
if type(c)~="string"or #c<12 then return nil end
return tonumber(c:sub(af,af+3),16)
end
local function O(c,f)
local n=E(c,1)if n==nil then return nil end
local ai=k(n/3.6,0,100)f:set_field(x,ai,{persist=false})return ai
end
local function B(c,f)
local ac=E(c,5)if ac==nil then return nil end
local J=k(ac/10,0,100)f:set_field(m,J,{persist=false})return J
end
local function s(c,f)
local ac=E(c,9)if ac==nil then return nil end
local p=l(k(ac,0,1000)/10)f:set_field(i,p,{persist=false})return p
end
local function t(c,f)
local p=l(k(c,0,1000)/10)f:set_field(i,p,{persist=false})return p
end
local function L(f,ao,capability_id,ae,ag)
local c=f:get_field(ao)if c==nil and type(f.get_latest_state)=="function"then
c=f:get_latest_state("main",capability_id,ae)end
local S=tonumber(c)if S==nil then return ag end
return S
end
local function Q(f,ai,J,p)
local F,n,ab=false,360,tonumber(ai)

if ab~=nil then
n=ab*3.6
F=true
else
local W=L(f,x,"colorControl","hue",0)if W~=0 then n=W*3.6 end
end
if F and n>=360 then n=359 end
n=l(k(n,0,F and 359 or 360))local K,r=tonumber(J),1000
if K~=nil then
r=l(k(K,0,100)*10)else
local I=L(f,m,"colorControl","saturation",0)if I~=0 then
r=l(k(I,0,100)*10)end
end
local u,q=tonumber(p),1000
if u~=nil and u~=0 then
q=l(k(u,0,100)*10)else
local H=L(f,i,"switchLevel","level",0)if H~=0 then
q=l(k(H,0,100)*10)end
end
f:set_field(x,n/3.6,{persist=false})f:set_field(m,r/10,{persist=false})f:set_field(i,q/10,{persist=false})return string.format("%04x%04x%04x",n,r,q)
end
local function M(_,c)
return{{dp=2,datatype=d.DP_TYPE_ENUM,value=0},{dp=3,datatype=d.DP_TYPE_VALUE,value=l(k(c,0,100)*10)}}
end
local function v(f,c)
if type(c)~="table"then return nil end
return{{dp=2,datatype=d.DP_TYPE_ENUM,value=1},{dp=5,datatype=d.DP_TYPE_STRING,value=Q(f,c.hue,c.saturation,c.brightness)}}
end
local function Z(f,c)
return v(f,{hue=c})
end
local function N(f,c)
return v(f,{saturation=c})
end
local X={d.dp_on_off(1,{name="switch",read_only=true,transaction=1,emit=o.switch()}),d.dp_enum(2,{name="lidl_change_mode",read_only=true,transaction=1}),d.dp_numeric(3,{name="lidl_brightness_report",read_only=true,transaction=1,converter=g.from_only(t),emit=o.level()}),d.dp_string(5,{name="lidl_hue_report",read_only=true,transaction=1,converter=g.from_only(O),emit=o.color_hue()}),d.dp_string(5,{name="lidl_saturation_report",read_only=true,transaction=1,converter=g.from_only(B),emit=o.color_saturation()}),d.dp_string(5,{name="lidl_color_brightness_report",read_only=true,transaction=1,converter=g.from_only(s),emit=o.level()}),d.dp_string(6,{name="lidl_effect_payload",read_only=true,transaction=1})}local ap={profile="lights-wave19-lidl-hg06467",package_group="wave19-light",magic_packet=false,query_on_configure=false,time_start="off",auto_connection_status=false,initial_custom_state_query=false,refresh_state_query=false,auto_on_before_light_command=false,datapoints=X,named_mapping={named_mappings={brightness=M,color=v,color_hue=Z,color_saturation=N}},zcl_clusters={aq.switch{endpoint=1,read_only=false,configure_reporting=false,read_on_configure=false}}}e(ap,{j.create_fingerprint("_TZE200_s8gkrkxk","TS0601")})local ah=C("lights-wave19-lonsonho-vm-s02-010v","lonsonhoVmTwo",g.lookup_from_to{momentary=0,toggle=1,state=2})e(ah,{j.create_fingerprint("_TZE600_wxq8dpha\0","TS0603")})local qa=z("lights-wave19-qa-qadz4din",{d.dp_on_off(1,{name="switch",component="main",transaction=1,emit=o.switch()}),d.dp_numeric(2,{name="brightness",component="main",transaction=1,converter=a,emit=o.level()}),d.dp_numeric(3,{name="qaQadzFour_min_brightness",component="main",transaction=1,converter=a,emit=h"qaQadzFourMinBrightness"}),d.dp_on_off(7,{name="switch",component="switch2",transaction=1,emit=o.switch()}),d.dp_numeric(8,{name="brightness",component="switch2",transaction=1,converter=a,emit=o.level()}),d.dp_numeric(9,{name="qaQadzFour_min_brightness",component="switch2",transaction=1,converter=a,emit=h"qaQadzFourMinBrightness"}),d.dp_enum(14,{name="qaQadzFour_power_behavior",transaction=1,converter=y,emit=h"qaQadzFourPowerBehavior"}),d.dp_on_off(15,{name="switch",component="switch3",transaction=1,emit=o.switch()}),d.dp_numeric(16,{name="brightness",component="switch3",transaction=1,converter=a,emit=o.level()}),d.dp_numeric(17,{name="qaQadzFour_min_brightness",component="switch3",transaction=1,converter=a,emit=h"qaQadzFourMinBrightness"}),d.dp_on_off(101,{name="switch",component="switch4",transaction=1,emit=o.switch()}),d.dp_numeric(102,{name="brightness",component="switch4",transaction=1,converter=a,emit=o.level()}),d.dp_numeric(103,{name="qaQadzFour_min_brightness",component="switch4",transaction=1,converter=a,emit=h"qaQadzFourMinBrightness"}),d.dp_enum(105,{name="qaQadzFour_dimming_speed",transaction=1,converter=g.lookup_from_to{slow=0,middle=1,fast=2},emit=h"qaQadzFourDimmingSpeed"}),d.dp_enum(106,{name="qaQadzFour_switch_type",transaction=1,converter=g.lookup_from_to{momentary=0,toggle=1},emit=h"qaQadzFourSwitchType"})})e(qa,{j.create_fingerprint("_TZE284_nthhgkd6","TS0601")})local Y=g.from_to(
function(c)
local ac=k(c,10,1000)local A=l((ac-10)*254/990)return l(A*100/254)
end,
function(c)
local A=l(k(c,0,100)*254/100)return l(10+A*990/254)
end
)local R=g.from_to(
function(c)return l(k(c,10,1000)/10)end,
function(c)return l(k(c,1,100)*10)end
)local an=z("lights-wave19-nova-topazio",{d.dp_on_off(1,{name="switch",transaction=1,emit=o.switch()}),d.dp_numeric(2,{name="brightness",transaction=1,converter=Y,emit=o.level()}),d.dp_numeric(3,{name="novaTopazio_min_brightness",transaction=1,converter=R,emit=h"novaTopazioMinBrightness"}),d.dp_enum(4,{name="novaTopazio_light_type",transaction=1,converter=g.lookup_from_to{led=0,incandescent=1,halogen=2},emit=h"novaTopazioLightType"}),d.dp_numeric(5,{name="novaTopazio_max_brightness",transaction=1,converter=R,emit=h"novaTopazioMaxBrightness"}),d.dp_numeric(6,{name="novaTopazio_countdown",transaction=1,emit=h"novaTopazioCountdown"}),d.dp_enum(14,{name="novaTopazio_power_behavior",transaction=1,converter=y,emit=h"novaTopazioPowerBehavior"}),d.dp_enum(21,{name="novaTopazio_indicator_mode",transaction=1,converter=g.lookup_from_to{none=0,relay=1,pos=2},emit=h"novaTopazioIndicatorMode"}),d.dp_binary(26,{name="novaTopazio_backlight",transaction=1,converter=al,emit=h"novaTopazioBacklight"})})an.time_start="1970"e(an,{j.create_fingerprint("_TZE284_5yah8qx4","TS0601")})return{id="ef00.lights.wave19.exact",registrations=P}
