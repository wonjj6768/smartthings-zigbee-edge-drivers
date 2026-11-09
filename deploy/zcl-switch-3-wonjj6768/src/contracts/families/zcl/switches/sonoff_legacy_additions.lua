local t,w,g=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family"local v,k,h,m,s=g.create_fingerprint,require"contracts.helpers.zcl",require"st.zigbee.data_types",require"st.zigbee.device_management",require"st.zigbee.generic_body"
local f,i=g.definition_registry()
local function j(c,e,u)
local x=u.zb_rx
if x and k.duplicate_transaction(e,u.endpoint,x.body.zcl_header.seqno.value,"__sonoff_legacy_transactions")then return end
return c==1 or c==true
end
local d={t.switch{endpoint=1,configure_reporting=false,read_on_configure=false,suppress_optimistic_state=true,from_device=j}}local b={
sonoff_legacy_toggle=function(e)
return t.send_raw_cluster_command(e,6,2,"",1)
end
}local a={{capability_id="momentary",command_name="push",mapping_name="sonoff_legacy_toggle"}}local n={profile="switches-sonoff-basiczbr3",zcl_clusters=d,protocol_writers=b,capability_commands=a}local p={profile="plugs-sonoff-s31zb",zcl_clusters=d,protocol_writers=b,capability_commands=a,
configure=function(r,e)
t.bind_cluster(e,6,r.environment_info.hub_zigbee_eui,1)
end
}i(n,{v("SONOFF","BASICZBR3")})i(p,{v("SONOFF","S31 Lite zb")})local q={profile="switches-sonoff-zbmini",zcl_clusters={t.switch{endpoint=1,minimum_interval=0,maximum_interval=65000,
suppress_optimistic_state=true,from_device=function(c)return c==true or c==1 end}},
protocol_writers=b,capability_commands=a}i(q,{v("SONOFF","01MINIZB")})local o={profile="switches-sonoff-minil2",zcl_clusters={t.switch{endpoint=1,minimum_interval=0,maximum_interval=65000,
suppress_optimistic_state=true,from_device=function(c)return c==true or c==1 end},
t.cluster_attribute(6,16387,{name="sonoff_minil2_power_on_behavior",endpoint=1,emit=w.sonoffMinil2PowerBehavior(),data_type=h.Enum8,write_type=h.Enum8,
from_device=function(c)
c=type(c)=="table"and c.value or c
return({[0]="off",[1]="on",[2]="toggle",[255]="previous"})[c]
end,
to_device=function(c)
return({off=0,on=1,toggle=2,previous=255})[c]
end,
read_on_configure=true,suppress_optimistic_state=true})},protocol_writers=b,capability_commands=a,
configure=function(r,e)
local l=m.build_bind_request(e,32,r.environment_info.hub_zigbee_eui,1)l.address_header.cluster=h.ClusterId(34)l.body.zdo_body=s.GenericBody(l.body.zdo_body:_serialize())e:send(l)
end
}i(o,{v("SONOFF","ZBMINIL2")})t.attach_reporting_capabilities(f,{{3,"rpt-zpi"},{4,"rpt-zqj"}})return{id="zcl.switches.sonoff_legacy_additions",registrations=f}
