local zcl=require "protocol.zcl"
local device_helpers=require "contracts.helpers.family"
local registrations,register_device_definition=device_helpers.definition_registry()
local dimmer_light={
profile="lights-dimmer",
zcl_clusters={
zcl.switch(),
zcl.level(),
},
}
local color_cct_light={
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
register_device_definition(dimmer_light,{
device_helpers.create_fingerprint(
string.char(0x20).. "Legrand" .. string.rep(string.char(0x00),23),
string.char(0x20).. "Dimmer switch with neutral" .. string.rep(string.char(0x00),4)
),
})
register_device_definition(color_cct_light,{
device_helpers.create_fingerprint(
"eWeLi" .. string.char(0x01,0x00,0x10),
"ZB-CL01"
),
})
register_device_definition(dimmer_light,{
device_helpers.create_fingerprint(
"Paulmann lamp" .. string.char(0x20),
"Dimmable Light" .. string.char(0x20)
),
})
return{
id="zcl.lights.wave19_exact_aliases",
registrations=registrations,
}
