local k,o,d,e,h=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.zigbee.device_management",require"st.zigbee.data_types"local b,c=d.definition_registry()local l={[0]="release",[1]="single",[2]="double",[3]="triple",[4]="hold",[256]="release",[257]="single",[258]="double",[259]="triple",[260]="hold",[512]="release",[513]="single",[514]="double",[515]="triple",[516]="hold",[1024]="release",[1025]="single",[1026]="double",[1027]="triple",[1028]="hold"}
local function a(f)
return k.cluster_attribute(18,85,{name="jethome_ws7_action_in"..tostring(f),endpoint=f,component="main",emit=assert(o.jetHomeWs7Action,"missing JetHome WS7 action emitter")(),data_type=h.SinglePrecisionFloat,
from_device=function(n)
local i=l[n]return i and(i.."_in"..tostring(f))or nil
end
})
end
local g={profile="buttons-jethome-ws7",zcl_clusters={k.battery{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true},k.battery_voltage{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true},a(1),a(2),a(3)},
configure=function(m,j)
j:send(e.build_bind_request(j,k.CLUSTER_POWER_CONFIGURATION,m.environment_info.hub_zigbee_eui,1))
end
}c(g,{d.create_fingerprint("JetHome","WS7")})k.attach_reporting_capabilities(b,{{1,"rpt-wik"}})return{id="zcl.controls.jethome",registrations=b}
