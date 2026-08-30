local tuya=require "protocol.tuya"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local common=require "contracts.helpers.ef00_presence"
local converter=tuya.converter
local device_definitions,register_device_definition=common.isolated_definition_registry(device_helpers)
local function register_presence_definition(definitions_or_table,fingerprint_list,ranges)
return common.register_presence_definition(
register_device_definition,definitions_or_table,fingerprint_list,ranges
)
end
local ts0601_fingerprints=common.ts0601_fingerprints
local presence_switch_auto_channel_converter=converter.lookup_from_to({
off=0,all=1,ch1=2,ch2=3,ch3=4,ch1_2=5,ch2_3=6,ch1_3=7,
})
local presence_switch_auto_channel_long_converter=converter.lookup_from_to({
off=0,all=1,ch2=2,ch3=3,
ch1_and_ch2=4,ch2_and_ch3=5,ch1_and_ch3=6,
})
local presence_switch_trigger_channel_converter=converter.lookup_from_to({ch1=0,ch2=1,ch3=2})
local msa201_presence_converter=common.msa201_presence_converter
local presence_switch_model_zg_302zm={
profile="switches-presence-switch-3-zg302zm",
package_group="presence-switch",
named_datapoints=true,
tuya.dp_presence(1,{emit=emit.presence(),converter=converter.true_false1()}),
tuya.dp_numeric(2,{name="sensitivity",emit=emit.zg302zmSensitivity()}),
tuya.dp_numeric(4,{
name="distance",
emit=emit.zg302zmDistance(),
converter=converter.divide_by_pair(100),
}),
tuya.dp_on_off(101,{name="switch",component="main",emit=emit.switch()}),
tuya.dp_on_off(102,{name="switch",component="switch2",emit=emit.switch()}),
tuya.dp_on_off(103,{name="switch",component="switch3",emit=emit.switch()}),
tuya.dp_enum(108,{
name="trigger_switch",
emit=emit.zg302zmTriggerSwitch(),
converter=presence_switch_trigger_channel_converter,
}),
tuya.dp_on_off(111,{name="backlight",emit=emit.zg302zmBacklight()}),
tuya.dp_power_outage_memory(112,{
name="power_outage_memory",
emit=emit.zg302zmPowerOutage(),
}),
tuya.dp_enum(113,{
name="auto_on",
emit=emit.zg302zmAutoOnV2(),
converter=presence_switch_auto_channel_converter,
}),
tuya.dp_numeric(114,{name="trigger_hold",emit=emit.zg302zmTriggerHold()}),
tuya.dp_enum(115,{
name="auto_off",
emit=emit.zg302zmAutoOffV2(),
converter=presence_switch_auto_channel_converter,
}),
}
register_presence_definition(presence_switch_model_zg_302zm,ts0601_fingerprints({
"_TZE200_kccdzaeo",
"_TZE200_s7rsrtbg",
"_TZE200_tmszbtzq",
"_TZE200_bfmfhxra",
"_TZE200_ahpcyzth",
"_TZE200_kijxnb8q",
"HOBEIAN:ZG-302ZM",
}))
local presence_switch_model_zg_302zl={
profile="switches-presence-switch-3-zg302zl",
package_group="presence-switch",
named_datapoints=true,
tuya.dp_presence(101,{emit=emit.presence(),converter=converter.true_false1()}),
tuya.dp_numeric(102,{name="sensitivity",emit=emit.zg302zlSensitivity()}),
tuya.dp_on_off(1,{name="switch",component="main",emit=emit.switch()}),
tuya.dp_on_off(2,{name="switch",component="switch2",emit=emit.switch()}),
tuya.dp_on_off(3,{name="switch",component="switch3",emit=emit.switch()}),
tuya.dp_on_off(16,{name="backlight",emit=emit.zg302zlBacklight()}),
tuya.dp_power_outage_memory(14,{
name="power_outage_memory",
emit=emit.zg302zlPowerOutage(),
}),
tuya.dp_numeric(103,{name="trigger_hold",emit=emit.zg302zlTriggerHold()}),
tuya.dp_enum(104,{
name="auto_on",
emit=emit.zg302zlAutoOn(),
converter=presence_switch_auto_channel_long_converter,
}),
tuya.dp_enum(105,{
name="auto_off",
emit=emit.zg302zlAutoOff(),
converter=presence_switch_auto_channel_long_converter,
}),
}
register_presence_definition(presence_switch_model_zg_302zl,ts0601_fingerprints({
"_TZE200_khzbklyh",
"_TZE200_df04ghrb",
"_TZE200_toeldckg",
"_TZE200_cqtamhh5",
"_TZE200_xlnzk169",
"_TZE200_llvwkkde",
"HOBEIAN:ZG-302ZL",
}))
local zis03_on_off_string_converter=converter.lookup_from_to({
ON=true,
OFF=false,
})
local zis03_detection_area_converter=converter.lookup_from_to({
all=0,
left=1,
right=2,
})
local zis03_sensitivity_converter=converter.lookup_from_to({
low=0,
medium=1,
high=2,
max=3,
})
local function build_zis03_datapoints(options)
local datapoints={
tuya.dp_presence(1,{emit=emit.presence(),converter=msa201_presence_converter}),
tuya.dp_numeric(4,{name="detection_range",emit=emit.zis03DetectionRange()}),
tuya.dp_binary(102,{
name="indicator",
emit=emit.zis03Indicator(),
converter=zis03_on_off_string_converter,
}),
tuya.dp_illuminance(103,{emit=emit.illuminance()}),
tuya.dp_numeric(104,{name="fading_time",emit=emit.zis03FadingTime()}),
tuya.dp_numeric(106,{
name="compensation_coefficient",
emit=emit.zis03Compensation(),
}),
tuya.dp_on_off(107,{name="switch",component="main",emit=emit.switch()}),
tuya.dp_binary(108,{
name="radar",
emit=emit.zis03Radar(),
converter=zis03_on_off_string_converter,
}),
tuya.dp_enum(111,{
name="detection_area",
emit=emit.zis03DetectionArea(),
converter=zis03_detection_area_converter,
}),
tuya.dp_binary(112,{
name="state_reversal",
emit=emit.zis03StateReversal(),
converter=zis03_on_off_string_converter,
}),
tuya.dp_enum(113,{
name="sensitivity",
emit=emit.zis03Sensitivity(),
converter=zis03_sensitivity_converter,
}),
}
if options.detection_distance then
datapoints[#datapoints + 1]=tuya.dp_numeric(101,{
name="detection_distance",
read_only=true,
emit=emit.zis04DetectionDistance(),
})
end
return datapoints
end
local presence_switch_model_zis03={
profile="safety-presence-switch-illuminance-zis03",
package_group="presence-switch",
named_datapoints=true,
datapoints=build_zis03_datapoints({}),
}
register_presence_definition(presence_switch_model_zis03,ts0601_fingerprints({
"_TZE204_izy1g1mb",
}))
local presence_switch_model_zis04={
profile="safety-presence-switch-illuminance-zis04",
package_group="presence-switch",
named_datapoints=true,
datapoints=build_zis03_datapoints({detection_distance=true}),
}
register_presence_definition(presence_switch_model_zis04,ts0601_fingerprints({
"_TZE204_f2rflfa6",
}))
return{
id="ef00.presence.switch",
registrations=device_definitions,
}
