local i,d,h,f=require"protocol.zcl",require"contracts.helpers.family",require"capabilities.events.all",require"st.zigbee.data_types"local g,c=d.definition_registry()
local function j(n,e)
return i.cluster_attribute(64545,0,{name=n,endpoint=1,data_type=f.Uint8,mfg_code=5264,read_only=true,read_on_configure=true,minimum_interval=60,maximum_interval=900,reportable_change=0,emit=e,
from_device=function(a)
return({[0]="dark",[1]="twilight",[2]="bright"})[a]
end
})
end
local function b(n,r,e)
return i.cluster_attribute(64545,r,{name=n,endpoint=1,data_type=f.Uint24,write_type=f.Uint24,mfg_code=5264,read_on_configure=true,emit=e,
to_device=function(a)
if type(a)~="number"or a%1~=0 or a<0 or a>65535 then return nil end
return a
end
})
end
local function p(l)
return i.battery{endpoint=l,read_only=true,read_on_configure=true,minimum_interval=3600,maximum_interval=65000,reportable_change=10,
from_device=function(a,_,q)
if q.raw_value~=255 then return a end
end}
end
local function k(n,e,l)
return i.battery_low{name=n,endpoint=l,emit=e,read_only=true,read_on_configure=true,configure_reporting=false,
converter={from=function(a)
if type(a)=="table"then a=a.value end
return(a&8)~=0 and"low"or"normal"
end}}
end
local function m(n)
return i.cluster_attribute(3,0,{name=n,endpoint=1,write_only=true,suppress_optimistic_state=true,tx_command_id=0,
to_device=function(a)
if type(a)~="number"or a%1~=0 or a<1 or a>30 then return nil end
return string.pack("<I2",a)
end})
end
local t={profile="sensors-illuminance-temp-humidity-battery-shelly-display",capability_commands={{capability_id="concertmirror08464.shellyDisplayIdentify",command_name="identify",mapping_name="shelly_display_identify",value=3},{capability_id="concertmirror08464.shellyDisplayIdentify",command_name="setIdentifyTime",argument_name="identifyTime",mapping_name="shelly_display_identify"}},zcl_clusters={i.temperature{minimum_interval=10,maximum_interval=3600,reportable_change=100},i.humidity{minimum_interval=10,maximum_interval=3600,reportable_change=100,
from_device=function(a,_,q)
if q.raw_value~=65535 then return a end
end},
j("shelly_blu_display_light_level",h.shellyBluDisplayLightLevel()),b("shelly_blu_display_dark_threshold",1,h.shellyDisplayDarkThresholdV2()),b("shelly_blu_display_bright_threshold",2,h.shellyDisplayBrightThresholdV2()),p(),m"shelly_display_identify"}}local v={profile="safety-contact-illuminance-battery-low-handle-shelly",initial_custom_state_query=false,
configure=function(s,o)
i.bind_cluster(o,1280,s.environment_info.hub_zigbee_eui,1)
end,
capability_commands={{capability_id="concertmirror08464.shellyDoorIdentify",command_name="setIdentifyTime",argument_name="identifyTime",mapping_name="shelly_door_identify"}},zcl_clusters={i.contact_alarm_1_or_2{endpoint=1,read_only=true,read_on_configure=true,configure_reporting=false},i.shelly_handle_position{endpoint=1,read_only=true,read_on_configure=true,configure_reporting=false},k("shelly_door_battery_low",h.shellyDoorBatteryLow(),1),j("shelly_blu_door_light_level",h.shellyBluDoorLightLevel()),b("shelly_blu_door_dark_threshold",1,h.shellyDoorDarkThreshold()),b("shelly_blu_door_bright_threshold",2,h.shellyDoorBrightThreshold()),p(1),m"shelly_door_identify"}}local u={profile="safety-motion-illuminance-battery-low-battery",capability_commands={{capability_id="concertmirror08464.shellyMotionIdentify",command_name="identify",mapping_name="shelly_motion_identify",value=3},{capability_id="concertmirror08464.shellyMotionIdentify",command_name="setIdentifyTime",argument_name="identifyTime",mapping_name="shelly_motion_identify"}},
configure=function(s,o)
o:remove_configured_attribute(1280,2)i.bind_cluster(o,1280,s.environment_info.hub_zigbee_eui,1)
end,
zcl_clusters={i.motion{configure_reporting=false},j("shelly_blu_motion_light_level",h.shellyBluMotionLightLevel()),b("shelly_blu_motion_dark_threshold",1,h.shellyMotionDarkThresholdV2()),b("shelly_blu_motion_bright_threshold",2,h.shellyMotionBrightThresholdV2()),k("shelly_motion_battery_low",h.shellyMotionBatteryLow()),p(),i.cluster_attribute(1280,19,{name="shelly_blu_motion_sensitivity",endpoint=1,data_type=f.Uint8,write_type=f.Uint8,read_on_configure=true,emit=h.shellyBluSensitivity(),
from_device=function(a)
return({"low","medium","high"})[a]
end,
to_device=function(a)
return({low=1,medium=2,high=3})[a]
end
}),m"shelly_motion_identify"}}c(t,{d.create_fingerprint("Shelly","BLU H&T Display ZB")})c(v,{d.create_fingerprint("Shelly","BLU DoorWindow ZB"),d.create_fingerprint("Shelly","BLU DoorWindow Mini ZB")})c(u,{d.create_fingerprint("Shelly","BLU Motion ZB")})i.attach_reporting_capabilities(g,{{1,"rpt-bbx"},{2,"rpt-bicq"},{3,"rpt-blp"}})return{id="zcl.sensors.shelly_environment",registrations=g}
