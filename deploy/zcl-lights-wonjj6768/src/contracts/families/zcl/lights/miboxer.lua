local zcl=require "protocol.zcl"
local device_helpers=require "contracts.helpers.family"
local device_definitions,register_device_definition=device_helpers.definition_registry()
local single_color_controller={
profile="lights-dimmer",
zcl_clusters={
zcl.switch(),
zcl.level(),
},
}
local dual_white_controller={
profile="lights-color-temperature",
zcl_clusters={
zcl.switch(),
zcl.level(),
zcl.color_temperature(),
},
}
local rgb_controller={
profile="lights-color",
zcl_clusters={
zcl.switch(),
zcl.level(),
zcl.color_hue(),
zcl.color_saturation(),
zcl.color(),
},
}
local rgb_cct_controller={
profile="lights-color-temperature-color",
zcl_clusters={
zcl.switch(),
zcl.level(),
zcl.color_temperature(),
zcl.color_hue(),
zcl.color_saturation(),
zcl.color(),
},
}
register_device_definition(rgb_controller,{
device_helpers.create_fingerprint("_TZ3210_778drfdt","TS0503B"),
})
return{
id="zcl.lights.miboxer",
registrations=device_definitions,
}
