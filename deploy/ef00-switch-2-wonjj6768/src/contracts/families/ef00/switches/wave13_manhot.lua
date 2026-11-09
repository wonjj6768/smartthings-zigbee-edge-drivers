local h,v,l=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family"local f=h.converter
local m,j=l.definition_registry()local WORDS,LOWER_WORDS,r={"One","Two","Three","Four","Five","Six","Seven","Eight"},{"one","two","three","four","five","six","seven","eight"},{red=0,orange=1,green=2,cyan=3,blue=4,purple=5,magenta=6,cold_white=7,warm_yellow=8}
local function g(name)
return assert(v[name],"missing Wave13 custom emitter: "..name)()
end
local function s(d)
return d<=6 and d or d+107
end
local function p(d)
return d<=6 and d+6 or d+109
end
local function o(d)
return d==1 and"main"or("switch"..tostring(d))
end
local function e(b,t)
b.datapoints[#b.datapoints+1]=t
end
local function i(u,a,c,n)
local b={profile=u,package_group="screen-switch",magic_packet=true,query_on_configure=false,respond_to_mcu_version_response=true,datapoints={},component_to_endpoint_map={},endpoint_to_component_map={[1]="main"}}for d=1,n do
b.component_to_endpoint_map[o(d)]=1
e(b,h.dp_on_off(s(d),{name="switch",component=o(d),endpoint=1,emit=v.switch()}))end
for d=1,n do
e(b,h.dp_numeric(p(d),{name=c.."_countdown_"..LOWER_WORDS[d],emit=g(a.."Countdown"..WORDS[d])}))end
e(b,h.dp_enum(14,{name=c.."_relay_status",converter=f.lookup_from_to{off=0,on=1,memory=2},emit=g(a.."RelayStatus")}))e(b,h.dp_enum(15,{name=c.."_light_mode",converter=f.lookup_from_to{none=0,relay=1,pos=2},emit=g(a.."LightMode")}))e(b,h.dp_binary(16,{name=c.."_backlight_switch",converter=f.lookup_from_to{ON=true,OFF=false},emit=g(a.."BacklightSwitch")}))e(b,h.dp_numeric(101,{name=c.."_backlight_lightness",emit=g(a.."BacklightLightness")}))e(b,h.dp_enum(102,{name=c.."_on_color",converter=f.lookup_from_to(r),emit=g(a.."OnColor")}))e(b,h.dp_enum(103,{name=c.."_off_color",converter=f.lookup_from_to(r),emit=g(a.."OffColor")}))e(b,h.dp_numeric(104,{name=c.."_displayoff_delay",emit=g(a.."DisplayOffDelay")}))e(b,h.dp_binary(105,{name=c.."_child_lock",converter=f.lookup_from_to{ON=true,OFF=false},emit=g(a.."ChildLock")}))for d=1,n do
e(b,h.dp_string(105+d,{name=c.."_switch_name_"..LOWER_WORDS[d],emit=g(a.."SwitchName"..WORDS[d])}))end
if n>1 then
local k={disable=0}for d=1,n do k["press_switch_"..tostring(d)]=d end
e(b,h.dp_enum(118,{name=c.."_press_on_function",converter=f.lookup_from_to(k),emit=g(a.."PressOnFunction")}))e(b,h.dp_enum(119,{name=c.."_press_off_function",converter=f.lookup_from_to(k),emit=g(a.."PressOffFunction")}))end
return b
end
local q={{i("switches-wave13-manhot-mh03-1","mhOne","mh_one",1),{"_TZE284_ncc7uahd","_TZE28C1000000_ncc7uahd"}},{i("switches-wave13-manhot-mh03-2","mhTwo","mh_two",2),{"_TZE284_dnhhp8ew","_TZE28C1000000_dnhhp8ew"}},{i("switches-wave13-manhot-mh03-3","mhThree","mh_three",3),{"_TZE284_59dz7ioi","_TZE28C1000000_59dz7ioi"}},{i("switches-wave13-manhot-mh03-4","mhFour","mh_four",4),{"_TZE284_esnu2jxv","_TZE28C1000000_esnu2jxv"}},{i("switches-wave13-manhot-mh03-6","mhSix","mh_six",6),{"_TZE284_zykra2yj","_TZE28C1000000_zykra2yj","_TZE284_wkvfb2ld","_TZE28C1000000_wkvfb2ld"}},{i("switches-wave13-manhot-mh03-8","mhEight","mh_eight",8),{"_TZE284_hwv3by9k","_TZE28C1000000_hwv3by9k","_TZE284_4ngwn2pj","_TZE28C1000000_4ngwn2pj"}}}for _,w in ipairs(q)do
j(w[1],l.create_fingerprints("TS0601",w[2]))end
return{id="ef00.switches.wave13.manhot",registrations=m}
