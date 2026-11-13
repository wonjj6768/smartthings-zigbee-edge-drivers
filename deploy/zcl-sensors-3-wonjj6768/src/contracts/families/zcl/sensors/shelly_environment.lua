local h,e,j,f=require"protocol.zcl",require"contracts.helpers.family",require"capabilities.events.all",require"st.zigbee.data_types"local i,d=e.definition_registry()
local function k(q,g)
return h.cluster_attribute(64545,0,{name=q,endpoint=1,data_type=f.Uint8,mfg_code=5264,read_only=true,read_on_configure=true,minimum_interval=60,maximum_interval=900,reportable_change=0,emit=g,
from_device=function(value)
return({[0]="dark",[1]="twilight",[2]="bright"})[value]
end
})
end
local function c(q,u,g)
return h.cluster_attribute(64545,u,{name=q,endpoint=1,data_type=f.Uint24,write_type=f.Uint24,mfg_code=5264,read_on_configure=true,emit=g,
to_device=function(value)
if type(value)~="number"or value%1~=0 or value<0 or value>65535 then return nil end
return value
end
})
end
local function s(o)
return h.battery{endpoint=o,read_only=true,read_on_configure=true,minimum_interval=3600,maximum_interval=65000,reportable_change=10,
from_device=function(value,_,t)
if t.raw_value~=255 then return value end
end}
end
local function n(q,g,o)
return h.battery_low{name=q,endpoint=o,emit=g,read_only=true,read_on_configure=true,configure_reporting=false,
converter={from=function(value)
if type(value)=="table"then value=value.value end
return(value&8)~=0 and"low"or"normal"
end}}
end
local function p(q)
return h.cluster_attribute(3,0,{name=q,endpoint=1,write_only=true,suppress_optimistic_state=true,tx_command_id=0,
to_device=function(value)
if type(value)~="number"or value%1~=0 or value<1 or value>30 then return nil end
return string.pack("<I2",value)
end})
end
local z={profile="sensors-illuminance-temp-humidity-battery-shelly-display",capability_commands={{capability_id="concertmirror08464.shellyDisplayIdentify",command_name="identify",mapping_name="shelly_display_identify",value=3},{capability_id="concertmirror08464.shellyDisplayIdentify",command_name="setIdentifyTime",argument_name="identifyTime",mapping_name="shelly_display_identify"}},zcl_clusters={h.temperature{minimum_interval=10,maximum_interval=3600,reportable_change=100},h.humidity{minimum_interval=10,maximum_interval=3600,reportable_change=100,
from_device=function(value,_,t)
if t.raw_value~=65535 then return value end
end},
k("shelly_blu_display_light_level",j.shellyBluDisplayLightLevel()),c("shelly_blu_display_dark_threshold",1,j.shellyDisplayDarkThresholdV2()),c("shelly_blu_display_bright_threshold",2,j.shellyDisplayBrightThresholdV2()),s(),p"shelly_display_identify"}}
local function m(b)
h.read_attribute(b,1280,0,1)h.read_attribute(b,1280,16,1)
end
local function l(b,x)
if x.address_header.src_endpoint.value~=1 then return false end
local y=h.get_generated_server_command(1280,0)local w=y(b,0,0):to_endpoint(1)w.body.zcl_header.seqno=x.body.zcl_header.seqno
b:send(w)
b.thread:call_with_delay(0.5,function()m(b)end,
"Shelly door enrollment readback")return true
end
local B={profile="safety-contact-illuminance-battery-low-handle-shelly",initial_custom_state_query=false,
configure=function(r,b)
b:remove_configured_attribute(1280,2)b:set_field("shelly_door_expected_cie",r.environment_info.hub_zigbee_eui)h.bind_cluster(b,1280,r.environment_info.hub_zigbee_eui,1)
end,
ias_zone_enroll_response=l,capability_commands={{capability_id="concertmirror08464.shellyDoorIdentify",command_name="setIdentifyTime",argument_name="identifyTime",mapping_name="shelly_door_identify"}},zcl_clusters={h.contact_alarm_1_or_2{endpoint=1,read_only=true,read_on_configure=true,configure_reporting=false,ias_configure_method=3},h.shelly_handle_position{endpoint=1,read_only=true,read_on_configure=true,configure_reporting=false},n("shelly_door_battery_low",j.shellyDoorBatteryLow(),1),k("shelly_blu_door_light_level",j.shellyBluDoorLightLevel()),c("shelly_blu_door_dark_threshold",1,j.shellyDoorDarkThreshold()),c("shelly_blu_door_bright_threshold",2,j.shellyDoorBrightThreshold()),s(1),p"shelly_door_identify",h.cluster_attribute(1280,0,{name="shelly_door_zone_state",endpoint=1,data_type=f.Enum8,read_only=true,
handler=function(b,value)
b:set_field("shelly_door_zone_state",value)
end
}),h.cluster_attribute(1280,16,{name="shelly_door_cie_address",endpoint=1,data_type=f.IeeeAddress,read_only=true,
handler=function(b,value)
b:set_field("shelly_door_cie_address",value)local v=b:get_field"shelly_door_expected_cie"if v~=nil then
b:set_field("shelly_door_cie_matches_hub",value==v)end
end
})}}local A={profile="safety-motion-illuminance-battery-low-battery",capability_commands={{capability_id="concertmirror08464.shellyMotionIdentify",command_name="identify",mapping_name="shelly_motion_identify",value=3},{capability_id="concertmirror08464.shellyMotionIdentify",command_name="setIdentifyTime",argument_name="identifyTime",mapping_name="shelly_motion_identify"}},
configure=function(r,b)
b:remove_configured_attribute(1280,2)h.bind_cluster(b,1280,r.environment_info.hub_zigbee_eui,1)
end,
zcl_clusters={h.motion{configure_reporting=false},k("shelly_blu_motion_light_level",j.shellyBluMotionLightLevel()),c("shelly_blu_motion_dark_threshold",1,j.shellyMotionDarkThresholdV2()),c("shelly_blu_motion_bright_threshold",2,j.shellyMotionBrightThresholdV2()),n("shelly_motion_battery_low",j.shellyMotionBatteryLow()),s(),h.cluster_attribute(1280,19,{name="shelly_blu_motion_sensitivity",endpoint=1,data_type=f.Uint8,write_type=f.Uint8,read_on_configure=true,emit=j.shellyBluSensitivity(),
from_device=function(value)
return({"low","medium","high"})[value]
end,
to_device=function(value)
return({low=1,medium=2,high=3})[value]
end
}),p"shelly_motion_identify"}}d(z,{e.create_fingerprint("Shelly","BLU H&T Display ZB")})d(B,{e.create_fingerprint("Shelly","BLU DoorWindow ZB"),e.create_fingerprint("Shelly","BLU DoorWindow Mini ZB")})d(A,{e.create_fingerprint("Shelly","BLU Motion ZB")})h.attach_reporting_capabilities(i,{{1,"rpt-bbx"},{2,"rpt-bicq"},{3,"rpt-blp"}})return{id="zcl.sensors.shelly_environment",registrations=i}
