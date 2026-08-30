local zcl=require "protocol.zcl"
local device_helpers=require "contracts.helpers.family"
local zcl_device_helpers=require "contracts.helpers.zcl"
local device_management=require "st.zigbee.device_management"
local device_definitions,register_device_definition=device_helpers.definition_registry()
local dimming_remote={
profile="controllers-dimming-remote-action",
advanced_remote=true,
unprefixed_remote_actions=true,
tuya_action_name="switch_scene",
zcl_clusters={},
}
local function bind_clusters(driver,device,endpoint,cluster_ids)
for _,cluster_id in ipairs(cluster_ids)do
device:send(device_management.build_bind_request(
device,
cluster_id,
driver.environment_info.hub_zigbee_eui,
endpoint
))
end
end
local heiman_color_dimmer={
profile="controllers-dimming-battery-remote-action",
advanced_remote=true,
unprefixed_remote_actions=true,
zcl_clusters={
zcl.battery({
endpoint=1,
minimum_interval=300,
maximum_interval=3600,
reportable_change=2,
}),
},
configure=function(driver,device)
bind_clusters(driver,device,1,{
zcl.CLUSTER_POWER_CONFIGURATION,
zcl.CLUSTER_ON_OFF,
zcl.CLUSTER_LEVEL_CONTROL,
zcl.CLUSTER_COLOR_CONTROL,
})
end,
}
local candeo_rd1p_remote={
profile="controllers-candeo-rd1p-rem",
advanced_remote=true,
unprefixed_remote_actions=true,
remote_action_emit_name="candeoRd1pRemAction",
standard_command_action_resolver=zcl_device_helpers.resolve_rd1p_rotary_action,
zcl_clusters={
zcl.power({
endpoint=1,
minimum_interval=5,
maximum_interval=300,
reportable_change=10,
}),
zcl.voltage({
endpoint=1,
minimum_interval=5,
maximum_interval=600,
reportable_change=500,
}),
zcl.current({
endpoint=1,
minimum_interval=5,
maximum_interval=900,
reportable_change=10,
}),
zcl.energy({
endpoint=1,
minimum_interval=5,
maximum_interval=1800,
reportable_change=50,
}),
},
configure=function(driver,device)
bind_clusters(driver,device,2,{
zcl.CLUSTER_ON_OFF,
zcl.CLUSTER_LEVEL_CONTROL,
})
end,
}
register_device_definition(dimming_remote,device_helpers.create_fingerprints("TS1001",{
"_TYZB01_bngwdjsr",
"_TYZB01_hww2py6b",
"_TZ3000_ztrfrcsu",
}))
register_device_definition(candeo_rd1p_remote,{
device_helpers.create_fingerprint("Candeo","C-ZB-RD1P-REM"),
})
register_device_definition(heiman_color_dimmer,{
device_helpers.create_fingerprint("HEIMAN","ColorDimmerSw-EM-3.0"),
})
return{
id="zcl.controls.dimming",
registrations=device_definitions,
}
