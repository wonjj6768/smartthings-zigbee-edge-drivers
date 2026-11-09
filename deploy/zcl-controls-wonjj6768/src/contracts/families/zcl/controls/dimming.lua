local f,b,j,k=require"protocol.zcl",require"contracts.helpers.family",require"contracts.helpers.zcl",require"st.zigbee.device_management"local c,a=b.definition_registry()local l={profile="controllers-dimming-remote-action",advanced_remote=true,unprefixed_remote_actions=true,tuya_action_name="switch_scene",zcl_clusters={}}
local function e(i,d,o,m)
for _,n in ipairs(m)do
d:send(k.build_bind_request(d,n,i.environment_info.hub_zigbee_eui,o))end
end
local g={profile="controllers-dimming-battery-remote-action",advanced_remote=true,unprefixed_remote_actions=true,zcl_clusters={f.battery{endpoint=1,minimum_interval=300,maximum_interval=3600,reportable_change=2}},
configure=function(i,d)
e(i,d,1,{f.CLUSTER_POWER_CONFIGURATION,f.CLUSTER_ON_OFF,f.CLUSTER_LEVEL_CONTROL,f.CLUSTER_COLOR_CONTROL})
end
}local h={profile="controllers-candeo-rd1p-rem",advanced_remote=true,unprefixed_remote_actions=true,remote_action_emit_name="candeoRd1pRemAction",standard_command_action_resolver=j.resolve_rd1p_rotary_action,zcl_clusters={f.power{endpoint=1,minimum_interval=5,maximum_interval=300,reportable_change=10},f.voltage{endpoint=1,minimum_interval=5,maximum_interval=600,reportable_change=500},f.current{endpoint=1,minimum_interval=5,maximum_interval=900,reportable_change=10},f.energy{endpoint=1,minimum_interval=5,maximum_interval=1800,reportable_change=50}},
configure=function(i,d)
e(i,d,2,{f.CLUSTER_ON_OFF,f.CLUSTER_LEVEL_CONTROL})
end
}a(l,b.create_fingerprints("TS1001",{"_TYZB01_bngwdjsr","_TYZB01_hww2py6b","_TZ3000_ztrfrcsu"}))a(h,{b.create_fingerprint("Candeo","C-ZB-RD1P-REM")})a(g,{b.create_fingerprint("HEIMAN","ColorDimmerSw-EM-3.0")})f.attach_reporting_capabilities(c,{{2,"rpt-cwf"},{3,"rpt-cbo"}})return{id="zcl.controls.dimming",registrations=c}
