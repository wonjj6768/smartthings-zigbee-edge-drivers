local g,d,m,f=require"protocol.zcl",require"contracts.helpers.family",require"capabilities.events.all",require"st.zigbee.device_management"local b,c=d.definition_registry()
local function a(i)
if type(i)~="number"then
return i
end
local h=math.floor((((i-2.0)/1.0)*100)+0.5)if h<0 then
return 0
end
if h>100 then
return 100
end
return h
end
local e={profile="buttons-button-1-battery-operation-mode-remote-action",datapoints={{dp=4,datatype=2,name="battery",field="battery",emit=m.battery(),read_only=true}},advanced_remote=true,unprefixed_remote_actions=true,button_actions={"pushed","double","held"},button_count=1,zcl_initial_writes={{name="operation_mode",value="event"}},zcl_clusters={g.tuya_magic_packet(),g.battery{endpoint=1,read_on_configure=true},g.cluster_attribute(g.CLUSTER_POWER_CONFIGURATION,g.ATTR_BATTERY_VOLTAGE,{name="battery",endpoint=1,emit=m.battery(),scale=10,from_device=a,read_on_configure=true}),g.operation_mode()},
configure=function(l,k)
for _,j in ipairs{g.CLUSTER_POWER_CONFIGURATION,g.CLUSTER_ON_OFF}do
k:send(f.build_bind_request(k,j,l.environment_info.hub_zigbee_eui,1))end
end
}c(e,{d.create_fingerprint("DSS0010","Excellux")})g.attach_reporting_capabilities(b,{{1,"rpt-tnc"}})return{id="zcl.controls.excellux",registrations=b}
