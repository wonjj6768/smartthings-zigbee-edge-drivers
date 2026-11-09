local i,k,d,p,n,C=require"protocol.zcl",require"contracts.helpers.family",require"st.capabilities",require"st.zigbee.data_types",require"st.zigbee.device_management",require"capabilities.events.all"local m,b=k.definition_registry()local j,h={{mode="high",endpoint=2},{mode="low",endpoint=3},{mode="medium",endpoint=4}},{high=2,low=3,medium=4,on=4}
local function g(a,e,F)
return i.send_raw_cluster_command(a,i.CLUSTER_ON_OFF,F and 1 or 0,"",e)
end
local function q(a,v)
local e,l=h[v]or h.medium,false

for _,A in ipairs(j)do
if A.endpoint~=e then
l=g(a,A.endpoint,false)or l
end
end
return g(a,e,true)or l
end
local function w(a,_,c)
if c==false or c=="off"then
local l=false
for _,A in ipairs(j)do
l=g(a,A.endpoint,false)or l
end
return l
end
local y=a:get_latest_state("main",d.fanMode.ID,"fanMode")return q(a,y)
end
local function o(a,_,c)
return q(a,c)
end
local function u(v)
return function(a,c)
local r={id="main"}if c==true or c==1 then
a:emit_component_event(r,d.switch.switch.on())a:emit_component_event(r,d.fanMode.fanMode(v))return
end
local y=a:get_latest_state("main",d.fanMode.ID,"fanMode")if y==v then
a:emit_component_event(r,d.switch.switch.off())end
end
end
local function f(v,e,D,B)
return i.cluster_attribute(i.CLUSTER_ON_OFF,i.ATTR_ON_OFF,{name=D,component="main",endpoint=e,handler=u(v),sender=B})
end
local s={profile="fans-switch-fan-mode",zcl_clusters={i.switch{endpoint=1,component="main"},i.fan_mode{endpoint=1},i.cluster_attribute(i.CLUSTER_FAN_CONTROL,1,{name="fan_mode_sequence",endpoint=1,write_only=true,write_type=p.Enum8})},zcl_initial_writes={{name="fan_mode_sequence",value=0}},
configure=function(x,a)
for _,z in ipairs{i.CLUSTER_ON_OFF,i.CLUSTER_FAN_CONTROL}do
a:send(n.build_bind_request(a,z,x.environment_info.hub_zigbee_eui,1))end
end
}b(s,k.create_fingerprints("TS0501",{"_TZ3210_lzqq3u4r","_TZ3210_4whigl8i"}))local t={profile="fans-ts0004-backlight",component_to_endpoint_map={main=2,light=1},endpoint_to_component_map={[1]="light",[2]="main",[3]="main",[4]="main"},zcl_clusters={i.cluster_attribute(6,32769,{name="ts_fan_backlight",endpoint=1,component="light",data_type=p.Enum8,write_type=p.Enum8,read_on_configure=false,emit=C.tsFanBacklight(),
from_device=function(c)
if type(c)=="table"then c=c.value end
return({[0]="red_when_on","pink_when_on","red_on_blue_off","pink_on_blue_off"})[c]
end,
to_device=function(c)
return({red_when_on=0,pink_when_on=1,red_on_blue_off=2,pink_on_blue_off=3})[c]
end
}),i.tuya_magic_packet(),i.switch{endpoint=1,component="light"},f("high",2,"fan_mode",o),i.cluster_attribute(i.CLUSTER_ON_OFF,i.ATTR_ON_OFF,{name="switch",component="main",endpoint=2,write_only=true,sender=w}),f("low",3,"fan_speed_low"),f("medium",4,"fan_speed_medium")},
configure=function(x,a)
for e=1,4 do
a:send(n.build_bind_request(a,i.CLUSTER_ON_OFF,x.environment_info.hub_zigbee_eui,e))end
end
}b(t,k.create_fingerprints("TS0004",{"_TZ3000_ncb6mkx8"}))i.attach_reporting_capabilities(m,{{1,"rpt-tse"},{2,"rpt-tmfs"}})return{id="zcl.lights.fans",registrations=m}
