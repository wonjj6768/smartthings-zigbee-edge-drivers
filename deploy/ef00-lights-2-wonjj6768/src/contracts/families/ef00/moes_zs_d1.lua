local tuya=require "protocol.tuya"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local converter=tuya.converter
local device_definitions,register_device_definition=device_helpers.definition_registry()
local relay_status_converter=converter.lookup_from_to({
off=0,
on=1,
memory=2,
})
local light_mode_converter=converter.lookup_from_to({
none=0,
relay=1,
pos=2,
})
local backlight_converter=converter.lookup_from_to({
OFF=false,
ON=true,
})
local definition={
profile="lights-moes-zs-d1",
query_on_configure=false,
time_start="off",
initial_custom_state_query=false,
refresh_state_query=false,
placeholder_custom_states=false,
tuya.dp_on_off(1,{
name="switch",
component="main",
emit=emit.switch(),
}),
tuya.dp_numeric(2,{
name="moes_zs_d_one_brightness_one",
component="main",
emit=emit.moesZsDOneBrightnessOne(),
}),
tuya.dp_numeric(3,{
name="moes_zs_d_one_brightness_min_one",
component="main",
emit=emit.moesZsDOneBrightnessMinOne(),
}),
tuya.dp_numeric(5,{
name="moes_zs_d_one_brightness_max_one",
component="main",
emit=emit.moesZsDOneBrightnessMaxOne(),
}),
tuya.dp_numeric(6,{
name="moes_zs_d_one_countdown_one",
component="main",
emit=emit.moesZsDOneCountdownOne(),
}),
tuya.dp_enum(14,{
name="moes_zs_d_one_relay_status",
component="main",
emit=emit.moesZsDOneRelayStatus(),
converter=relay_status_converter,
}),
tuya.dp_enum(21,{
name="moes_zs_d_one_light_mode",
component="main",
emit=emit.moesZsDOneLightMode(),
converter=light_mode_converter,
}),
tuya.dp_binary(26,{
name="moes_zs_d_one_backlight",
component="main",
emit=emit.moesZsDOneBacklight(),
converter=backlight_converter,
}),
}
register_device_definition(definition,{
{manufacturer="_TZE284_a1ovdobn",model="TS0601"},
{manufacturer="_TZE200_a1ovdobn",model="TS0601"},
})
return{
id="moes.zs_d1",
registrations=device_definitions,
}
