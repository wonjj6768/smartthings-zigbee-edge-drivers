local i,m,e,c,a=require"protocol.zcl",require"capabilities.events.all",require"st.capabilities",require"contracts.helpers.family",require"contracts.helpers.zcl"local d,j=c.definition_registry()local f=a.passive
local l={profile="safety-somfy-opening",magic_packet=false,initial_custom_state_query=false,protocol_writers={somfy_open_identify=a.identify},capability_commands={{capability_id="concertmirror08464.somfyOpenIdentify",command_name="identify",mapping_name="somfy_open_identify",value=3},{capability_id="concertmirror08464.somfyOpenIdentify",command_name="setIdentifyTime",argument_name="identifyTime",mapping_name="somfy_open_identify"}},
parent_refresh=function(h)
for _,g in ipairs{33,32}do
pcall(i.read_attribute,h,1,g,h:get_endpoint(1))end
end,
zcl_clusters={f(i.occupancy{name="somfy_open_alarm",ias_zone=true,component="main",
emit=m.somfyOpenAlarm(),from_device=function(b)
if type(b)=="table"then b=b.value end
return(b&1)~=0 and"active"or"inactive"
end}),
f(i.battery_low{component="main",emit=function(_,b)
return b and e.batteryLevel.battery.critical()or e.batteryLevel.battery.normal()
end}),
i.battery{component="main",minimum_interval=3600,maximum_interval=65000,reportable_change=10,
from_device=function(b,_,k)if k.raw_value~=255 then return b end end}
}}j(l,{c.create_fingerprint("SOMFY","1811680")})i.attach_reporting_capabilities(d,{{1,"rpt-zxa"}})return{id="zcl.sensors.somfy_opening",registrations=d}
