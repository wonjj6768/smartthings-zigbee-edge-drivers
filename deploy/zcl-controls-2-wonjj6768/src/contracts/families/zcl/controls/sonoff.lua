local k,D,q,b,i,m=require"protocol.zcl",require"capabilities.events.all",require"st.capabilities",require"contracts.helpers.family",require"st.zigbee.device_management",require"st.zigbee.data_types"local h,a=b.definition_registry()
local function o(_,t,u)
if t~=k.CLUSTER_ON_OFF then
return nil,nil,true
end
local A=({[2]="single",[1]="double",[0]="long"})[u]return A,"main",true
end
local z={profile="sonoff-snzb01p-button",advanced_remote=true,button_count=1,button_actions={"pushed","double","held"},standard_command_action_resolver=o,standard_action_button_events={single="pushed",double="double",long="held"},zcl_clusters={k.battery{endpoint=1,minimum_interval=3600,maximum_interval=7200,reportable_change=0,read_on_configure=true,read_only=true},k.battery_voltage{endpoint=1,minimum_interval=3600,maximum_interval=7200,reportable_change=0,read_on_configure=true,read_only=true}},
configure=function(r,d)
d:send(i.build_bind_request(d,k.CLUSTER_ON_OFF,r.environment_info.hub_zigbee_eui,1))
end
}a(z,{b.create_fingerprint("eWeLink","SNZB-01P"),b.create_fingerprint("SONOFF","SNZB-01P")})local n=D.sonoffKfAction()
local function e(d,B)
k.read_configured_attributes(d,B.zcl_clusters)
end
local function j(c)
if type(c)=="number"and c>=0 and c<127.5 then return c end
end
local function p(c)
if type(c)=="number"and c>=0 and c<25.5 then return c end
end
local function x(c,_,g)
if g.command_id~=0 then return nil end
return({[0]="off",[1]="single"})[c]
end
local E={profile="sonoff-kf-button",magic_packet=false,zcl_clusters={k.cluster_attribute(1280,2,{name="sonoff_kf_action",endpoint=1,component="main",data_type=m.Bitmap16,read_only=true,read_on_configure=false,ias_configure_method=0,command_id=0,
command_extractor=function(C)
local s=C.body.zcl_body.zone_status
return type(s)=="table"and s.value or s
end,
from_device=x,
handler=function(d,c,g)
local v=n(d,c,g)if v then
v.state_change=true
d:emit_component_event(g.component,v)end
end
}),k.battery{endpoint=1,minimum_interval=3600,maximum_interval=7200,reportable_change=2,read_on_configure=true,read_only=true,from_device=j},k.battery_voltage{endpoint=1,minimum_interval=3600,maximum_interval=7200,reportable_change=100,read_on_configure=true,read_only=true,from_device=p}},
configure=function(r,d)
d:send(i.build_bind_request(d,1280,r.environment_info.hub_zigbee_eui,1))
end,
parent_refresh=e}a(E,{b.create_fingerprint("SONOFF","KF01"),b.create_fingerprint("SONOFF","KF-01")})
local function f(l,w)
return k.cluster_attribute(64530,0,{name="sonoff_snzb01m_button_"..tostring(l),endpoint=l,component=w,data_type=m.Uint8,read_only=true,read_on_configure=false,
from_device=function(c,_,g)
if g.src_endpoint~=l then return nil end
return({[1]="pushed",[2]="double",[3]="held",[4]="pushed_3x"})[c]
end,
handler=function(d,c,g)
d:emit_component_event(g.component,q.button.button(c,{state_change=true}))
end
})
end
local y={profile="sonoff-snzb01m-button",magic_packet=false,button_count=4,button_actions={"pushed","double","held","pushed_3x"},zcl_clusters={f(1,"main"),f(2,"button2"),f(3,"button3"),f(4,"button4"),k.battery{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,read_only=true,from_device=j}},parent_refresh=e}a(y,{b.create_fingerprint("SONOFF","SNZB-01M")})k.attach_reporting_capabilities(h,{{1,"rpt-soc"},{2,"rpt-kjx"},{3,"rpt-saq"}})return{id="zcl.controls.sonoff",registrations=h}
