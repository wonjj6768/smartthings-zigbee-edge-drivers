local g,d,p,q=require"protocol.zcl",require"contracts.helpers.family",require"capabilities.events.all",require"st.zigbee.data_types"local b,c=d.definition_registry()
local function k(e)
return g.battery{endpoint=e,read_only=true,read_on_configure=true,minimum_interval=3600,maximum_interval=65000,reportable_change=10,
from_device=function(a,_,l)
if l.raw_value~=255 then return a end
end}
end
local function h(j,f,e)
return g.battery_low{name=j,endpoint=e,emit=f,read_only=true,read_on_configure=true,configure_reporting=false,
converter={from=function(a)
if type(a)=="table"then a=a.value end
return(a&8)~=0 and"low"or"normal"
end}}
end
local function i(j)
return g.cluster_attribute(3,0,{name=j,endpoint=1,write_only=true,suppress_optimistic_state=true,tx_command_id=0,
to_device=function(a)
if type(a)~="number"or a%1~=0 or a<1 or a>30 then return nil end
return string.pack("<I2",a)
end})
end
local m={profile="safety-contact-battery-shelly-outdoor",
configure=function(o,n)
g.bind_cluster(n,1280,o.environment_info.hub_zigbee_eui,1)
end,
capability_commands={{capability_id="concertmirror08464.sbdw302Identify",command_name="setIdentifyTime",argument_name="identifyTime",mapping_name="sbdw302_identify"}},zcl_clusters={g.contact_alarm_1_or_2{endpoint=1,read_only=true,read_on_configure=true,configure_reporting=false},g.shelly_handle_position{name="sbdw302_handle_position",endpoint=1,emit=p.sbdw302HandlePosition(),read_only=true,read_on_configure=true,configure_reporting=false},h("sbdw302_battery_low",p.sbdw302BatteryLow(),1),k(1),i"sbdw302_identify"}}c(m,{d.create_fingerprint("Shelly","BLU DoorWindow Outdoor ZB")})g.attach_reporting_capabilities(b,{{1,"rpt-blz"}})return{id="zcl.sensors.shelly_outdoor",registrations=b}
