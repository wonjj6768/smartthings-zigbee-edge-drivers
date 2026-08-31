local zcl=require "protocol.zcl"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local shelly=require "contracts.helpers.shelly_gen4"
local device_management=require "st.zigbee.device_management"
local data_types=require "st.zigbee.data_types"
local device_definitions,register_device_definition=device_helpers.definition_registry()
local function custom_emit(name)
return assert(emit[name],"missing Shelly Presence emitter: " .. tostring(name))()
end
local function identify_sender(device,_,value,context)
if value ~="identify" then return false end
return zcl.send_raw_cluster_command(
device,
0x0003,
0x00,
string.char(0x03,0x00),
context.endpoint or 1
)
end
local clusters={}
for endpoint=1,10 do
clusters[#clusters + 1]=zcl.occupancy({
name="shelly_presence_occupancy_" .. tostring(endpoint),
endpoint=endpoint,
component=endpoint==1 and "main" or("person" .. tostring(endpoint)),
minimum_interval=0,
maximum_interval=3600,
reportable_change=0,
read_on_configure=true,
})
end
clusters[#clusters + 1]=zcl.cluster_attribute(shelly.LIGHT_LEVEL_CLUSTER,0x0000,{
name="shelly_presence_light_level",
endpoint=1,
emit=custom_emit("shellyPresenceLightLevel"),
data_type=data_types.Uint8,
mfg_code=shelly.MANUFACTURER_CODE,
read_only=true,
from_device=function(value)
return({[0]="dark",[1]="twilight",[2]="bright"})[value]
end,
minimum_interval=60,
maximum_interval=900,
reportable_change=0,
read_on_configure=true,
})
for _,spec in ipairs({
{0x0001,"dark_threshold","shellyPresenceDarkThreshold"},
{0x0002,"bright_threshold","shellyPresenceBrightThreshold"},
})do
clusters[#clusters + 1]=zcl.cluster_attribute(shelly.LIGHT_LEVEL_CLUSTER,spec[1],{
name="shelly_presence_" .. spec[2],
endpoint=1,
emit=custom_emit(spec[3]),
data_type=data_types.Uint24,
write_type=data_types.Uint24,
mfg_code=shelly.MANUFACTURER_CODE,
read_on_configure=true,
numeric_range={minimum=0,maximum=65535,step=1,unit="lx"},
})
end
clusters[#clusters + 1]=shelly.rpc_presence_zone_delay("shelly_presence_presence_delay","presence_thr")
clusters[#clusters + 1]=shelly.rpc_presence_zone_delay("shelly_presence_absence_delay","absence_thr")
local setting_specs={
{"installation_height",{"sensor","height"}},
{"sensor_position",{"sensor","position"}},
{"sensor_flipped",{"sensor","flipped"},shelly.boolean_to_device},
{"sensitivity",{"sensor","sensitivity"},nil,"custom"},
{"radar_power",{"sensor","power"}},
{"minimum_range",{"zmin"}},
{"maximum_range",{"zmax"}},
{"tracked_objects",{"num_tracks"}},
{"led_brightness",{"leds","brightness"}},
{"night_mode",{"leds","night_mode","enable"},shelly.boolean_to_device},
{"night_mode_brightness",{"leds","night_mode","brightness"}},
{"detection_points",{"sensor","points"}},
{"velocity_threshold",{"sensor","velocity"}},
{"snr_threshold",{"sensor","snr"}},
{"maximum_velocity_difference",{"sensor","max_velocity"}},
{"motion_activation_threshold",{"sensor","state","det_act_thr"}},
{"motion_release_threshold",{"sensor","state","det_free_thr"}},
{"tracking_loss_threshold",{"sensor","state","act_free_thr"}},
{"stillness_tracking_threshold",{"sensor","state","stat_free_thr"}},
{"stillness_timeout_threshold",{"sensor","state","sleep_free_thr"}},
}
for _,spec in ipairs(setting_specs)do
clusters[#clusters + 1]=shelly.rpc_presence_setting(
"shelly_presence_" .. spec[1],
spec[2],
{to_device=spec[3],reject_value=spec[4]}
)
end
clusters[#clusters + 1]=shelly.rpc_eco_mode("shelly_presence_eco_mode")
clusters[#clusters + 1]=zcl.cluster_attribute(0x0003,nil,{
name="shelly_presence_identify",
endpoint=1,
component="main",
write_only=true,
sender=identify_sender,
})
shelly.append_wifi_mappings(clusters,"shelly_presence","shellyPresence")
local shelly_presence={
profile="sensors-shelly-presence-gen4",
zcl_clusters=clusters,
zcl_refresh_before_read_all=shelly.begin_wifi_refresh,
configure=function(driver,device)
for endpoint=1,10 do
device:send(device_management.build_bind_request(
device,
zcl.CLUSTER_OCCUPANCY_SENSING,
driver.environment_info.hub_zigbee_eui,
endpoint
))
end
device:send(device_management.build_bind_request(
device,
shelly.LIGHT_LEVEL_CLUSTER,
driver.environment_info.hub_zigbee_eui,
1
))
shelly.refresh_wifi(device)
end,
}
register_device_definition(shelly_presence,{
device_helpers.create_fingerprint("Shelly","Presence"),
})
return{
id="zcl.sensors.shelly_presence",
registrations=device_definitions,
}
