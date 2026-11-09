local e,c,k,d,g=require"protocol.zcl",require"contracts.helpers.family",require"capabilities.events.all",require"st.zigbee.device_management",require"st.zigbee.data_types"local a,i=c.definition_registry()local b={profile="safety-co-detector-battery-voltage-ewelink-7037",zcl_clusters={e.carbon_monoxide{read_on_configure=true},e.cluster_attribute(1036,0,{name="ewelink_7037_carbon_monoxide_level",endpoint=1,emit=k.carbon_monoxide_level(),data_type=g.SinglePrecisionFloat,read_on_configure=true}),e.battery{endpoint=1,minimum_interval=3600,maximum_interval=7200},e.battery_voltage{endpoint=1,minimum_interval=3600,maximum_interval=7200,reportable_change=100}},
configure=function(j,h)
for _,f in ipairs{e.CLUSTER_POWER_CONFIGURATION,32,1036,1280}do
h:send(d.build_bind_request(h,f,j.environment_info.hub_zigbee_eui,1))end
end
}i(b,{c.create_fingerprint("eWeLink","CK-TLSR8656-Z123SE24DY-01(7037)")})e.attach_reporting_capabilities(a,{{1,"rpt-cnp"}})return{id="zcl.sensors.z2m_absorption_ewelink_7037",registrations=a}
