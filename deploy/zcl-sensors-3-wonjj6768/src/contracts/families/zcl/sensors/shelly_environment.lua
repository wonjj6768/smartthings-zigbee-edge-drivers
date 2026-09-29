local zcl=require "protocol.zcl"
local device_helpers=require "contracts.helpers.family"
local emit=require "capabilities.events.all"
local data_types=require "st.zigbee.data_types"
local device_definitions,register_device_definition=device_helpers.definition_registry()
local function light_level(name,event_factory)
return zcl.cluster_attribute(0xFC21,0x0000,{
name=name,
endpoint=1,
data_type=data_types.Uint8,
mfg_code=0x1490,
read_only=true,
read_on_configure=true,
minimum_interval=60,
maximum_interval=900,
reportable_change=0,
emit=event_factory,
from_device=function(value)
return({[0]="dark",[1]="twilight",[2]="bright"})[value]
end,
})
end
local function light_threshold(name,attribute_id,event_factory)
return zcl.cluster_attribute(0xFC21,attribute_id,{
name=name,
endpoint=1,
data_type=data_types.Uint24,
write_type=data_types.Uint24,
mfg_code=0x1490,
read_on_configure=true,
numeric_range={minimum=0,maximum=65535,step=1,unit="lx"},
emit=event_factory,
})
end
local display={
profile="sensors-illuminance-temp-humidity-battery-shelly-display",
zcl_clusters={
zcl.temperature(),
zcl.humidity(),
light_level("shelly_blu_display_light_level",emit.shellyBluDisplayLightLevel()),
light_threshold("shelly_blu_display_dark_threshold",0x0001,emit.shellyBluDisplayDarkThreshold()),
light_threshold("shelly_blu_display_bright_threshold",0x0002,emit.shellyBluDisplayBrightThreshold()),
zcl.battery(),
},
}
local door={
profile="safety-contact-illuminance-battery-low-handle-shelly",
zcl_clusters={
zcl.contact(),
zcl.shelly_handle_position(),
zcl.battery_low(),
light_level("shelly_blu_door_light_level",emit.shellyBluDoorLightLevel()),
light_threshold("shelly_blu_door_dark_threshold",0x0001,emit.shellyBluDoorDarkThreshold()),
light_threshold("shelly_blu_door_bright_threshold",0x0002,emit.shellyBluDoorBrightThreshold()),
zcl.battery(),
},
}
local motion={
profile="safety-motion-illuminance-battery-low-battery",
zcl_clusters={
zcl.motion(),
light_level("shelly_blu_motion_light_level",emit.shellyBluMotionLightLevel()),
light_threshold("shelly_blu_motion_dark_threshold",0x0001,emit.shellyBluMotionDarkThreshold()),
light_threshold("shelly_blu_motion_bright_threshold",0x0002,emit.shellyBluMotionBrightThreshold()),
zcl.battery_low(),
zcl.battery(),
zcl.cluster_attribute(0x0500,0x0013,{
name="shelly_blu_motion_sensitivity",
endpoint=1,
data_type=data_types.Uint8,
write_type=data_types.Uint8,
read_on_configure=true,
emit=emit.shellyBluSensitivity(),
from_device=function(value)
return({"low","medium","high"})[value]
end,
to_device=function(value)
return({low=1,medium=2,high=3})[value]
end,
}),
},
}
register_device_definition(display,{
device_helpers.create_fingerprint("Shelly","BLU H&T Display ZB"),
})
register_device_definition(door,{
device_helpers.create_fingerprint("Shelly","BLU DoorWindow ZB"),
})
register_device_definition(motion,{
device_helpers.create_fingerprint("Shelly","BLU Motion ZB"),
})
return{
id="zcl.sensors.shelly_environment",
registrations=device_definitions,
}
