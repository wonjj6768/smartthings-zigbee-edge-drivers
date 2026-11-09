local function S(a)
return type(a)=="table"and a.value or a
end
local function B(a,u,t)
return type(a)=="number"and a==a and a>=u and a<=t
end
local function m(a)
if not B(a,8,30)then return end
local y=a*2
local v,N=math.floor(y),string.unpack("<I8",string.pack("<d",y))local F,G=((N>>52)&2047)-1022,(N&0xFFFFFFFFFFFFF)|0x10000000000000

if G*20>=(v*20+9)*(1<<(53-F))then v=v+1 end
return v*50
end
local function n(a,_,f,c)
local W=f and f.zb_rx
local L=W and W.body and W.body.zcl_body and W.body.zcl_body.attr_records
for _,j in ipairs(L or{})do
if j.attr_id.value==c.attribute_id and j.data==f.typed_value then
if(j.status and j.status.value~=0)or not j.data_type or j.data_type.value~=c.data_type.ID then return end
a=S(a)local u,t=c.data_type.ID==41 and-32767 or 0,c.data_type.ID==41 and 32767 or 255
if B(a,u,t)and a%1==0 then return a end
return
end
end
end
local function h(U)
return function(a,b,f,c)
a=n(a,b,f,c)if a==nil then return end
a=a/100
if not U or a>=-273.15 then return a end
end
end
local J,K,Q,R,C,D={[0]="off",[1]="auto",[3]="cool",[4]="heat",[5]="emergency heat",[6]="precooling",[7]="fanonly",[8]="dryair",[9]="asleep"},{off=0,auto=1,cool=3,heat=4,fanonly=7,dryair=8},{[0]="off",[1]="low",[2]="medium",[3]="high",[4]="on",[5]="auto",[6]="smart"},{off=0,low=1,medium=2,high=3,on=4,auto=5,smart=6},{[0]="fully_closed",[1]="fully_closed",[2]="fully_open",[3]="quarter_open",[4]="half_open",[5]="three_quarters_open"},{fully_closed=1,fully_open=2,quarter_open=3,half_open=4,three_quarters_open=5}
local function w(T)
return function(a,b,f,c)return T[n(a,b,f,c)]end
end
local function A(a,b,f,c)
a=n(a,b,f,c)if a~=nil then return a~=0 end
end
local o,s,i,e,d,M=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.capabilities",require"st.zigbee.data_types",require"st.zigbee.cluster_base"local q,H=i.definition_registry()
local function p(b,I,z,Z,a)
if a==nil then return false end
local k=M.write_attribute(b,d.ClusterId(I),d.AttributeId(z),Z(a)):to_endpoint(1)k.body.zcl_header.frame_ctrl:set_disable_default_response()return pcall(b.send,b,k)
end
local x={o.cluster_attribute(513,0,{name="owon_ac201_local_temperature",endpoint=1,data_type=d.Int16,read_only=true,read_on_configure=false,read_on_refresh=true,from_device=h(true),emit=s.temperature"C",reporting_defaults={minimum_interval=60,maximum_interval=600,reportable_change=0}}),o.cluster_attribute(513,18,{name="current_heating_setpoint",endpoint=1,data_type=d.Int16,read_only=false,read_on_configure=false,read_on_refresh=true,suppress_optimistic_state=true,from_device=h(true),emit=s.heating_setpoint"C",
sender=function(b,_,a)return p(b,513,18,d.Int16,m(a))end,
reporting_defaults={minimum_interval=0,maximum_interval=3600,reportable_change=10}}),o.cluster_attribute(513,17,{name="current_cooling_setpoint",endpoint=1,data_type=d.Int16,read_only=false,read_on_configure=false,read_on_refresh=true,suppress_optimistic_state=true,from_device=h(false),emit=s.cooling_setpoint"C",
sender=function(b,_,a)return p(b,513,17,d.Int16,m(a))end
}),o.cluster_attribute(513,28,{name="system_mode",endpoint=1,data_type=d.Enum8,read_only=false,read_on_configure=false,read_on_refresh=true,suppress_optimistic_state=true,from_device=w(J),emit=s.thermostat_mode(),
sender=function(b,_,a)return p(b,513,28,d.Enum8,K[a])end,
reporting_defaults={minimum_interval=10,maximum_interval=3600}}),o.cluster_attribute(514,0,{name="owon_ac201_fan_mode",component="fan",endpoint=1,data_type=d.Enum8,read_only=false,read_on_configure=false,read_on_refresh=true,suppress_optimistic_state=true,from_device=w(Q),emit=s.value(e.airConditionerFanMode.fanMode),
sender=function(b,_,a)
if type(a)~="string"then return false end
return p(b,514,0,d.Enum8,R[a:lower()])
end,
reporting_defaults={minimum_interval=0,maximum_interval=3600}}),o.cluster_attribute(514,0,{name="switch",component="fan",endpoint=1,data_type=d.Enum8,read_only=false,read_on_configure=false,read_on_refresh=false,suppress_optimistic_state=true,from_device=A,emit=s.switch(),
sender=function(b,_,a)
if type(a)~="boolean"then return false end
return p(b,514,0,d.Enum8,a and 4 or 0)
end
}),o.cluster_attribute(513,69,{name="owon_ac201_louver_position",endpoint=1,data_type=d.Enum8,read_only=false,read_on_configure=false,read_on_refresh=true,suppress_optimistic_state=true,from_device=w(C),emit=s.owonAc201LouverPosition(),
sender=function(b,_,a)return p(b,513,69,d.Enum8,D[a])end,
reporting_defaults={minimum_interval=0,maximum_interval=3600}})}local P={profile="thermostats-owon-ac201",zcl_clusters=x,thermostat_supported_modes={"off","heat","cool","auto","dryair","fanonly"},capability_commands={{capability_id="airConditionerFanMode",command_name="setFanMode",mapping_name="owon_ac201_fan_mode",argument_name="fanMode"}},
component_to_endpoint=function()return 1 end,
endpoint_to_component=function()return"main"end,
runtime_start=function(b)
b:emit_component_event({id="main"},e.thermostatMode.supportedThermostatModes({"off","heat","cool","auto","dryair","fanonly"},{visibility={displayed=false}}))b:emit_component_event({id="main"},e.thermostatHeatingSetpoint.heatingSetpointRange{value={minimum=8,maximum=30,step=1},unit="C"})b:emit_component_event({id="main"},e.thermostatCoolingSetpoint.coolingSetpointRange{value={minimum=8,maximum=30,step=1},unit="C"})b:emit_component_event({id="fan"},e.airConditionerFanMode.supportedAcFanModes({"low","medium","high","on","auto"},{visibility={displayed=false}}))
end,
parent_refresh=function(b,l)
if l.zcl_refresh_before_read_all then l.zcl_refresh_before_read_all(b,l)end
for _,E in ipairs{{513,0},{513,18},{513,17},{513,28},{514,0},{513,69}}do
local k=M.read_attribute(b,d.ClusterId(E[1]),d.AttributeId(E[2])):to_endpoint(1)k.body.zcl_header.frame_ctrl:set_disable_default_response()b:send(k)end
end,
configure=function(O,b)
local Y=O.environment_info.hub_zigbee_eui
o.bind_cluster(b,514,Y,1)
local function g(V)
local c=x[V]local r=c.reporting_defaults
o.configure_reporting(b,{cluster=c.cluster_id,attribute=c.attribute_id,data_type=c.data_type,minimum_interval=r.minimum_interval,maximum_interval=r.maximum_interval,reportable_change=r.reportable_change},1,{disable_default_response=true})
end
g(5)o.bind_cluster(b,513,Y,1)g(2)g(2)g(1)g(4)g(7)
end
}H(P,{i.create_fingerprint("OWON","AC201")})o.attach_reporting_capabilities(q,{{1,"rpt-ars"}})return{id="zcl.thermostats.owon_ac201",registrations=q}
