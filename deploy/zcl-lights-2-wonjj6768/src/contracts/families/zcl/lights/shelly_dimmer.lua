local b,z,g,u,n,i=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"contracts.helpers.shelly_gen4",require"st.zigbee.device_management",require"st.zigbee.data_types"local d,e=g.definition_registry()
local function q(l,_,c,w)
local p=({blink=0,breathe=1,okay=2,channel_change=11,finish_effect=254,stop_effect=255})[c]if p==nil then return false end
local B=b.send_raw_cluster_command(l,3,64,string.char(p,0),w.endpoint or 1)return B
end
local function o(m,...)
local x=m and m.body and m.body.zcl_body or nil
if type(x)~="table"then return nil end
for A=1,select("#",...)do
local c=x[select(A,...)]if c~=nil then
return type(c)=="table"and c.value or c
end
end
return nil
end
local function j(m,h,a,f)
if h==b.CLUSTER_ON_OFF and(f==2 or f==3 or f==4)then
local k=({[0]="off",[1]="on",[2]="toggle",[64]="off"})[a]return k,"main",k~=nil
end
if h==b.CLUSTER_LEVEL_CONTROL and f==4 then
if a==0 or a==4 then
return"brightness_move_to_level","main",true
elseif a==1 or a==5 then
local t=o(m,"move_mode","movemode","mode")if t==0 then return"brightness_move_up","main",true end
if t==1 then return"brightness_move_down","main",true end
return nil,nil,true
elseif a==2 or a==6 then
local t=o(m,"step_mode","stepmode","mode")if t==0 then return"brightness_step_up","main",true end
if t==1 then return"brightness_step_down","main",true end
return nil,nil,true
elseif a==3 or a==7 then
return"brightness_stop","main",true
end
end
if h==b.CLUSTER_WINDOW_COVERING and f==4 then
local k=({[0]="open",[1]="close",[2]="stop"})[a]return k,"main",k~=nil
end
return nil,nil,false
end
local s={b.switch{endpoint=1,configure_reporting=false},b.level{endpoint=1,configure_reporting=false},b.power{endpoint=1,minimum_interval=10,maximum_interval=65000,physical_reportable_change=5,read_on_configure=true},b.voltage{endpoint=1,minimum_interval=10,maximum_interval=65000,physical_reportable_change=5,read_on_configure=true},b.current{endpoint=1,minimum_interval=10,maximum_interval=65000,physical_reportable_change=0.05,read_on_configure=true},b.energy{endpoint=1,minimum_interval=10,maximum_interval=65000,physical_reportable_change=0.1,read_on_configure=true},b.cluster_attribute(b.CLUSTER_ON_OFF,16387,{name="shelly_dimmer_power_on_behavior",endpoint=1,emit=z.shellyDimmerPowerOnBehavior(),
from_device=function(c)
return({[0]="off",[1]="on",[2]="toggle",[255]="previous"})[c]
end,
to_device=function(c)
return({off=0,on=1,toggle=2,previous=255})[c]
end,
data_type=i.Enum8,write_type=i.Enum8}),b.cluster_attribute(3,65535,{name="shelly_dimmer_effect",endpoint=1,emit=z.shellyDimmerEffect(),data_type=i.Enum8,write_only=true,sender=q})}u.append_wifi_mappings(s,"shelly_dimmer","shellyDimmer")local r={profile="lights-shelly-dimmer-gen4",advanced_remote=true,unprefixed_remote_actions=true,remote_action_emit_name="shellyDimmerAction",standard_action_metadata_emit_names={action_group="shellyDimmerActionGroup",action_level="shellyDimmerActionLevel",action_transition_time="shellyDimmerActionTransition",action_rate="shellyDimmerActionRate",action_step_size="shellyDimmerActionStepSize"},standard_action_endpoint_suffix=true,standard_command_action_resolver=j,zcl_clusters=s,zcl_refresh_before_read_all=u.begin_wifi_refresh,
configure=function(y,l)
for _,v in ipairs{{1,b.CLUSTER_ELECTRICAL_MEASUREMENT},{1,b.CLUSTER_SIMPLE_METERING},{2,b.CLUSTER_ON_OFF},{3,b.CLUSTER_ON_OFF},{4,b.CLUSTER_ON_OFF},{4,b.CLUSTER_LEVEL_CONTROL},{4,b.CLUSTER_WINDOW_COVERING}}do
l:send(n.build_bind_request(l,v[2],y.environment_info.hub_zigbee_eui,v[1]))end
u.refresh_wifi(l)
end
}e(r,{g.create_fingerprint("Shelly","Dimmer 0-1/10")})b.attach_reporting_capabilities(d,{{1,"rpt-dwy"}})return{id="zcl.lights.shelly_dimmer",registrations=d}
