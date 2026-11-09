local o,t,h,b,f,i=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"contracts.helpers.shelly_gen4",require"st.zigbee.device_management",require"st.zigbee.data_types"local d,e=h.definition_registry()
local function j(s)
return assert(t[s],"missing Shelly Presence emitter: "..tostring(s))()
end
local function k(g,_,p,r)
if p~="identify"then return false end
return o.send_raw_cluster_command(g,3,0,string.char(3,0),r.endpoint or 1)
end
local a={}for c=1,10 do
a[#a+1]=o.occupancy{name="shelly_presence_occupancy_"..tostring(c),endpoint=c,component=c==1 and"main"or("person"..tostring(c)),minimum_interval=0,maximum_interval=3600,reportable_change=0,read_on_configure=true}end
a[#a+1]=o.cluster_attribute(b.LIGHT_LEVEL_CLUSTER,0,{name="shelly_presence_light_level",endpoint=1,emit=j"shellyPresenceLightLevel",data_type=i.Uint8,mfg_code=b.MANUFACTURER_CODE,read_only=true,
from_device=function(p)
return({[0]="dark",[1]="twilight",[2]="bright"})[p]
end,
minimum_interval=60,maximum_interval=900,reportable_change=0,read_on_configure=true})for _,spec in ipairs{{1,"dark_threshold","shellyPresenceDarkThreshold"},{2,"bright_threshold","shellyPresenceBrightThreshold"}}do
a[#a+1]=o.cluster_attribute(b.LIGHT_LEVEL_CLUSTER,spec[1],{name="shelly_presence_"..spec[2],endpoint=1,emit=j(spec[3]),data_type=i.Uint24,write_type=i.Uint24,mfg_code=b.MANUFACTURER_CODE,read_on_configure=true,numeric_range={minimum=0,maximum=65535,step=1,unit="lx"}})end
a[#a+1]=b.rpc_presence_zone_delay("shelly_presence_presence_delay","presence_thr")a[#a+1]=b.rpc_presence_zone_delay("shelly_presence_absence_delay","absence_thr")local n={{"installation_height",{"sensor","height"}},{"sensor_position",{"sensor","position"}},{"sensor_flipped",{"sensor","flipped"},b.boolean_to_device},{"sensitivity",{"sensor","sensitivity"},nil,"custom"},{"radar_power",{"sensor","power"}},{"minimum_range",{"zmin"}},{"maximum_range",{"zmax"}},{"tracked_objects",{"num_tracks"}},{"led_brightness",{"leds","brightness"}},{"night_mode",{"leds","night_mode","enable"},b.boolean_to_device},{"night_mode_brightness",{"leds","night_mode","brightness"}},{"detection_points",{"sensor","points"}},{"velocity_threshold",{"sensor","velocity"}},{"snr_threshold",{"sensor","snr"}},{"maximum_velocity_difference",{"sensor","max_velocity"}},{"motion_activation_threshold",{"sensor","state","det_act_thr"}},{"motion_release_threshold",{"sensor","state","det_free_thr"}},{"tracking_loss_threshold",{"sensor","state","act_free_thr"}},{"stillness_tracking_threshold",{"sensor","state","stat_free_thr"}},{"stillness_timeout_threshold",{"sensor","state","sleep_free_thr"}}}for _,spec in ipairs(n)do
a[#a+1]=b.rpc_presence_setting("shelly_presence_"..spec[1],spec[2],{to_device=spec[3],reject_value=spec[4]})end
a[#a+1]=b.rpc_eco_mode"shelly_presence_eco_mode"a[#a+1]=o.cluster_attribute(3,nil,{name="shelly_presence_identify",endpoint=1,component="main",write_only=true,sender=k})b.append_wifi_mappings(a,"shelly_presence","shellyPresence")local l={profile="sensors-shelly-presence-gen4",zcl_clusters=a,zcl_refresh_before_read_all=b.begin_wifi_refresh,
configure=function(q,g)
for c=1,10 do
g:send(f.build_bind_request(g,o.CLUSTER_OCCUPANCY_SENSING,q.environment_info.hub_zigbee_eui,c))end
g:send(f.build_bind_request(g,b.LIGHT_LEVEL_CLUSTER,q.environment_info.hub_zigbee_eui,1))b.refresh_wifi(g)
end
}e(l,{h.create_fingerprint("Shelly","Presence")})o.attach_reporting_capabilities(d,{{1,"rpt-plx",{zr040600001="Occupancy",zr0406000010="OccupancyTen",zr040600002="OccupancyTwo",zr040600003="OccupancyThree",zr040600004="OccupancyFour",zr040600005="OccupancyFive",zr040600006="OccupancySix",zr040600007="OccupancySeven",zr040600008="OccupancyEight",zr040600009="OccupancyNine"}}})return{id="zcl.sensors.shelly_presence",registrations=d}
