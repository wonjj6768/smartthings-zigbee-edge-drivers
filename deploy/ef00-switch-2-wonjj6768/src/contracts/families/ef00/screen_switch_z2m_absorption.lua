local f,e=require"protocol.tuya.contract",require"capabilities.events.screen_switch_z2m_absorption"local h,p=f.converter,require"runtime.utf8_text"
local d={on_off=h.lookup_from_to{off=false,on=true},backlight_mode=h.lookup_from_to{OFF=false,ON=true},child_lock=h.lookup_from_to{UNLOCK=false,LOCK=true},indicator_status=h.lookup_from_to{off=0,on_off_status=1,switch_position=2},color=h.lookup_from_to{red=0,blue=1,green=2,white=3,yellow=4,magenta=5,cyan=6,warm_white=7,warm_yellow=8},relay_status=h.lookup_from_to{power_off=0,power_on=1,restart_memory=2},radar_config=h.lookup_from_to{none=0,["10s"]=1,["20s"]=2,["30s"]=3,["45s"]=4,["60s"]=5},switch_name=h.from_to(
function(s)
if type(s)~="string"then return nil end
local A=s:gsub("%z+$","")return p.truncate(A,12)
end,
function(s)
return p.truncate(s,12)
end
)}
local function n(q)
local u={}for _,t in ipairs(q)do
u[#u+1]={manufacturer=t,model="TS0601"}end
return u
end
local function i(a,b,c)
if b.single_gang then
a[#a+1]=f.dp_on_off(1,{name="switch",component="main",emit=c.switch_main})return
end
for gang=1,b.gang_count do
a[#a+1]=f.dp_on_off(gang,{name="switch",component="switch"..gang,emit=c["switch_"..gang]})end
end
local function g(a,b,c)
if b.single_gang then
a[#a+1]=f.dp_countdown(7,{name=b.mapping_prefix.."_countdown",component="main",emit=c.countdown_main})return
end
for gang=1,b.gang_count do
a[#a+1]=f.dp_countdown(6+gang,{name=b.mapping_prefix.."_countdown",component="switch"..gang,emit=c["countdown_"..gang]})end
end
local function l(a,b,c)
if b.single_gang then
a[#a+1]=f.dp_enum(29,{name=b.mapping_prefix.."_relay_status",component="main",emit=c.relay_status_main,converter=d.relay_status})return
end
for gang=1,b.gang_count do
a[#a+1]=f.dp_enum(28+gang,{name=b.mapping_prefix.."_relay_status",component="switch"..gang,emit=c["relay_status_"..gang],converter=d.relay_status})end
end
local function j(a,b,c)
if b.single_gang then
a[#a+1]=f.dp_raw(105,{name=b.mapping_prefix.."_switch_name",component="main",emit=c.switch_name_main,converter=d.switch_name})return
end
for gang=1,b.gang_count do
a[#a+1]=f.dp_raw(104+gang,{name=b.mapping_prefix.."_switch_name",component="switch"..gang,emit=c["switch_name_"..gang],converter=d.switch_name})end
end
local function k(b)
local c,a=b.event_factory(),{}if not b.single_gang then
a[#a+1]=f.dp_on_off(13,{name="switch",component="main",emit=c.switch_main})end
i(a,b,c)g(a,b,c)if b.single_gang then
a[#a+1]=f.dp_on_off(13,{name="switch",component="main",emit=c.switch_main})end
a[#a+1]=f.dp_enum(15,{name=b.mapping_prefix.."_indicator_status",emit=c.indicator_status,converter=d.indicator_status})a[#a+1]=f.dp_binary(16,{name=b.mapping_prefix.."_backlight_mode",emit=c.backlight_mode,converter=b.legacy_backlight_mode and d.on_off or d.backlight_mode})a[#a+1]=f.dp_enum(19,{name=b.mapping_prefix.."_delay_off_color",emit=c.delay_off_color,converter=d.color})l(a,b,c)a[#a+1]=f.dp_binary(101,{name=b.mapping_prefix.."_child_lock",emit=c.child_lock,converter=b.legacy_child_lock and d.on_off or d.child_lock})a[#a+1]=f.dp_numeric(102,{name=b.mapping_prefix.."_backlight_brightness",emit=c.backlight_brightness})a[#a+1]=f.dp_enum(103,{name=b.mapping_prefix.."_switch_color_on",emit=c.switch_color_on,converter=d.color})a[#a+1]=f.dp_enum(104,{name=b.mapping_prefix.."_switch_color_off",emit=c.switch_color_off,converter=d.color})j(a,b,c)a[#a+1]=f.dp_enum(111,{name=b.mapping_prefix.."_radar_config",emit=c.radar_config,converter=d.radar_config})return{profile=b.profile,time_start="1970",datapoints=a,fingerprints=n(b.manufacturers)}
end
local function m(b)
local c=b.event_factory()local a={f.dp_on_off(13,{name="switch",component="main",emit=c.switch_main})}i(a,b,c)g(a,b,c)a[#a+1]=f.dp_binary(101,{name=b.mapping_prefix.."_child_lock",emit=c.child_lock,converter=d.child_lock})j(a,b,c)return{profile=b.profile,datapoints=a,fingerprints=n(b.manufacturers)}
end
local x,v,w,y,z=k{profile="switches-screen-zms206us1",event_factory=e.zms206us1,mapping_prefix="zms206_one",gang_count=1,single_gang=true,manufacturers={"_TZE204_sa2ueffe","_TZE204_zuepxzck","_TZE284_lnyz4a6v"}},k{profile="switches-screen-zms206eu2",event_factory=e.zms206eu2,mapping_prefix="zms206_two",gang_count=2,manufacturers={"_TZE284_3ctwoaip","_TZE204_3ctwoaip","_TZE284_dmckrsxg","_TZE28C1000000_dmckrsxg"}},k{profile="switches-screen-zms206eu3",event_factory=e.zms206eu3,mapping_prefix="zms206_three",gang_count=3,manufacturers={"_TZE204_k7v0eqke","_TZE204_iyki9kjp","_TZE284_k7v0eqke","_TZE284_e4pf6l87","_TZE28C1000000_e4pf6l87"}},m{profile="switches-screen-zms208us2",event_factory=e.zms208us2,mapping_prefix="zms208_two",gang_count=2,manufacturers={"_TZE284_a2teqi5u","_TZE28C1000000_a2teqi5u"}},m{profile="switches-screen-zms208us3",event_factory=e.zms208us3,mapping_prefix="zms208_three",gang_count=3,manufacturers={"_TZE284_xvywzhmi","_TZE28C1000000_xvywzhmi"}}local r={x,v,w,y,z}return{id="ef00.screen_switch.z2m_absorption",registrations=r}
