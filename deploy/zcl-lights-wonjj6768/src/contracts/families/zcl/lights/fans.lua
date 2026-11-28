local j,l,b,q,o,D=require"protocol.zcl",require"contracts.helpers.family",require"st.capabilities",require"st.zigbee.data_types",require"st.zigbee.device_management",require"capabilities.events.all"local n,e=l.definition_registry()local k,i={{mode="high",endpoint=2},{mode="low",endpoint=3},{mode="medium",endpoint=4}},{high=2,low=3,medium=4,on=4}
local function h(a,f,G)
return j.send_raw_cluster_command(a,j.CLUSTER_ON_OFF,G and 1 or 0,"",f)
end
local function r(a,v)
local f,m=i[v]or i.medium,false

for _,B in ipairs(k)do
if B.endpoint~=f then
m=h(a,B.endpoint,false)or m
end
end
return h(a,f,true)or m
end
local function w(a,_,d)
if d==false or d=="off"then
local m=false
for _,B in ipairs(k)do
m=h(a,B.endpoint,false)or m
end
return m
end
local y=a:get_latest_state("main",b.fanMode.ID,"fanMode")return r(a,y)
end
local function p(a,_,d)
return r(a,d)
end
local function u(v)
return function(a,d)
local s={id="main"}if d==true or d==1 then
a:emit_component_event(s,b.switch.switch.on())a:emit_component_event(s,b.fanMode.fanMode(v))return
end
local y=a:get_latest_state("main",b.fanMode.ID,"fanMode")if y==v then
a:emit_component_event(s,b.switch.switch.off())end
end
end
local function g(v,f,E,C)
return j.cluster_attribute(j.CLUSTER_ON_OFF,j.ATTR_ON_OFF,{name=E,component="main",endpoint=f,handler=u(v),sender=C})
end
local c={profile="fans-switch-fan-mode",zcl_clusters={j.switch{endpoint=1,component="main"},j.fan_mode{endpoint=1},j.cluster_attribute(j.CLUSTER_FAN_CONTROL,1,{name="fan_mode_sequence",endpoint=1,write_only=true,write_type=q.Enum8})},zcl_initial_writes={{name="fan_mode_sequence",value=0}},
configure=function(x,a)
for _,A in ipairs{j.CLUSTER_ON_OFF,j.CLUSTER_FAN_CONTROL}do
a:send(o.build_bind_request(a,A,x.environment_info.hub_zigbee_eui,1))end
end
}for _,z in ipairs(c.zcl_clusters)do
if z.name=="fan_mode"then
z.emit=function(_,d)
return b.airConditionerFanMode.fanMode(d)
end
end
end
c.capability_commands={{capability_id="airConditionerFanMode",command_name="setFanMode",mapping_name="fan_mode",argument_name="fanMode"}}
c.runtime_start=function(a)
a:emit_component_event({id="main"},b.airConditionerFanMode.supportedAcFanModes({"off","low","medium","high","on"},{visibility={displayed=false}}))
end
e(c,l.create_fingerprints("TS0501",{"_TZ3210_lzqq3u4r","_TZ3210_4whigl8i"}))local t={profile="fans-ts0004-backlight",component_to_endpoint_map={main=2,light=1},endpoint_to_component_map={[1]="light",[2]="main",[3]="main",[4]="main"},zcl_clusters={j.cluster_attribute(6,32769,{name="ts_fan_backlight",endpoint=1,component="light",data_type=q.Enum8,write_type=q.Enum8,read_on_configure=false,emit=D.tsFanBacklight(),
from_device=function(d)
if type(d)=="table"then d=d.value end
return({[0]="red_when_on","pink_when_on","red_on_blue_off","pink_on_blue_off"})[d]
end,
to_device=function(d)
return({red_when_on=0,pink_when_on=1,red_on_blue_off=2,pink_on_blue_off=3})[d]
end
}),j.tuya_magic_packet(),j.switch{endpoint=1,component="light"},g("high",2,"fan_mode",p),j.cluster_attribute(j.CLUSTER_ON_OFF,j.ATTR_ON_OFF,{name="switch",component="main",endpoint=2,write_only=true,sender=w}),g("low",3,"fan_speed_low"),g("medium",4,"fan_speed_medium")},
configure=function(x,a)
for f=1,4 do
a:send(o.build_bind_request(a,j.CLUSTER_ON_OFF,x.environment_info.hub_zigbee_eui,f))end
end
}e(t,l.create_fingerprints("TS0004",{"_TZ3000_ncb6mkx8"}))j.attach_reporting_capabilities(n,{{1,"rpt-tsee"},{2,"rpt-tmfs"}})return{id="zcl.lights.fans",registrations=n}
