local tuya=require"protocol.tuya"
local emit=require"capabilities.events.all"
local device_helpers=require"contracts.helpers.family"
local din_common=require"contracts.helpers.ef00_din_rail"
local converter=tuya.converter
local emit_metric_bundle=din_common.emit_metric_bundle
local device_definitions,register_device_definition=device_helpers.definition_registry()local power_meter_model_zwpm16={
profile="meters-zwpm16",package_group="meters",magic_packet=true,mcu_version_request_on_configure=true,initial_custom_state_query=false,refresh_state_query=false,placeholder_custom_states=false,tuya.dp_current(18,{
emit=emit.current(),converter=converter.divide_by_pair(1000),read_only=true,}),tuya.dp_power(19,{
emit=emit.power(),converter=converter.divide_by_pair(10),read_only=true,}),tuya.dp_voltage(20,{
emit=emit.voltage(),converter=converter.divide_by_pair(10),read_only=true,}),tuya.dp_energy(104,{
emit=emit.energy(),converter=converter.divide_by_pair(1000),read_only=true,}),tuya.dp_numeric(105,{
name="daily_energy",converter=converter.divide_by_pair(1000),read_only=true,emit=emit.zwpm16DailyEnergy(),}),query_on_configure=false,time_start="off",}register_device_definition(power_meter_model_zwpm16,device_helpers.create_fingerprints("TS0601",{
"_TZE204_goecjd1t","_TZE284_goecjd1t",}))local power_meter_model_zwpm16_2={
profile="meters-zwpm16-2",package_group="meters",tuya.dp_power(105,{
name="power_l1",component="main",emit=emit.power(),converter=converter.signed_number_pair(10),signed=true,read_only=true,}),tuya.dp_current(106,{
name="current_l1",component="main",emit=emit.current(),converter=converter.signed_number_pair(1000),signed=true,read_only=true,}),tuya.dp_voltage(107,{
name="voltage_l1",component="main",emit=emit.voltage(),converter=converter.signed_number_pair(10),signed=true,read_only=true,}),tuya.dp_energy(108,{
name="energy_l1",component="main",emit=emit.energy(),converter=converter.signed_number_pair(1000),signed=true,read_only=true,}),tuya.dp_numeric(109,{
name="daily_energy_l1",component="main",converter=converter.signed_number_pair(1000),signed=true,read_only=true,emit=emit.zwpm16TwoDailyEnergyL1(),}),tuya.dp_power(115,{
name="power_l2",component="l2",emit=emit.power(),converter=converter.signed_number_pair(10),signed=true,read_only=true,}),tuya.dp_current(116,{
name="current_l2",component="l2",emit=emit.current(),converter=converter.signed_number_pair(1000),signed=true,read_only=true,}),tuya.dp_voltage(117,{
name="voltage_l2",component="l2",emit=emit.voltage(),converter=converter.signed_number_pair(10),signed=true,read_only=true,}),tuya.dp_energy(118,{
name="energy_l2",component="l2",emit=emit.energy(),converter=converter.signed_number_pair(1000),signed=true,read_only=true,}),tuya.dp_numeric(119,{
name="daily_energy_l2",component="l2",converter=converter.signed_number_pair(1000),signed=true,read_only=true,emit=emit.zwpm16TwoDailyEnergyL2(),}),query_on_configure=false,time_start="off",}register_device_definition(power_meter_model_zwpm16_2,device_helpers.create_fingerprints("TS0601",{
"_TZE204_jrcfsaa3",}))local three_channel_bidirectional_core={
profile="meters-three-channel-bidirectional-core",package_group="meters",transport_classification="EF00_DP",z2m_converter_source="meta.tuyaDatapoints",wire_cluster="manuSpecificTuya",magic_packet=true,mcu_version_request_on_configure=true,query_on_configure=false,named_datapoints=true,time_start="off",placeholder_custom_states=false,datapoints={
tuya.dp_energy(1,{
name="energy",scale=100,read_only=true,transaction=1,emit=emit.energy(),}),tuya.dp_power(9,{
name="power",scale=10,read_only=true,transaction=1,emit=emit.power(),}),tuya.dp_on_off(16,{
name="switch",component="main",transaction=1,emit=emit.switch(),}),tuya.dp_voltage(101,{
name="voltage",scale=10,read_only=true,transaction=1,emit=emit.voltage(),}),tuya.dp_temperature(131,{
name="temperature",scale=10,read_only=true,transaction=1,emit=emit.temperature("C"),}),},}register_device_definition(three_channel_bidirectional_core,{
device_helpers.create_fingerprint("_TZE20C1000000_p3g8xiug","TS0601"),})local nous_d4z_m_core={
profile="meters-nous-d4z-m-core",package_group="meters",transport_classification="EF00_DP",z2m_converter_source="meta.tuyaDatapoints",wire_cluster="manuSpecificTuya",magic_packet=true,mcu_version_request_on_configure=true,query_on_configure=false,named_datapoints=true,time_start="off",placeholder_custom_states=false,datapoints={
tuya.dp_energy(1,{
name="energy",scale=100,read_only=true,emit=emit.energy(),}),tuya.dp_phase_variant2(6,{
phase="a",component="l1",read_only=true,emit=emit_metric_bundle({voltage=true,current=true,power=true}),}),tuya.dp_phase_variant2(7,{
phase="b",component="l2",read_only=true,emit=emit_metric_bundle({voltage=true,current=true,power=true}),}),tuya.dp_phase_variant2(8,{
phase="c",component="l3",read_only=true,emit=emit_metric_bundle({voltage=true,current=true,power=true}),}),tuya.dp_power(29,{
name="power",scale=1,read_only=true,emit=emit.power(),}),tuya.dp_energy(53,{
name="energy_a",component="l1",scale=100,read_only=true,emit=emit.energy(),}),tuya.dp_energy(54,{
name="energy_b",component="l2",scale=100,read_only=true,emit=emit.energy(),}),tuya.dp_energy(55,{
name="energy_c",component="l3",scale=100,read_only=true,emit=emit.energy(),}),},}register_device_definition(nous_d4z_m_core,device_helpers.create_fingerprints("TS0601",{
"_TZE200_agjqiu4h","_TZE204_agjqiu4h","_TZE284_agjqiu4h",}))local avatto_zot60={
profile="meters-avatto-zot60",magic_packet=true,query_on_configure=false,time_start="off",datapoints={
tuya.dp_on_off(1,{name="switch",emit=emit.switch()}),tuya.dp_numeric(9,{name="zot60_countdown",emit=emit.zot60Countdown()}),tuya.dp_energy(17,{
name="zot60_energy",scale=1000,
emit=function(device,value)
return{emit.energy()(device,value),emit.zot60Energy()(device,value)}
end,
}),tuya.dp_current(18,{scale=1000,read_only=true,emit=emit.current()}),tuya.dp_power(19,{scale=10,read_only=true,emit=emit.power()}),tuya.dp_voltage(20,{scale=10,read_only=true,emit=emit.voltage()}),tuya.dp_enum(27,{
name="zot60_power_behavior",emit=emit.zot60PowerBehavior(),converter=converter.lookup_from_to({off=0,on=1,previous=2}),}),tuya.dp_binary(101,{
name="zot60_backlight_mode",emit=emit.zot60BacklightMode(),converter=converter.lookup_from_to({ON=true,OFF=false}),}),},}register_device_definition(avatto_zot60,device_helpers.create_fingerprints("TS011F",{
"_TZ3218_pfnjjx6a","_TZ3218_fv20refe","_TZ3218_o1slgs0r",}))return{
id="ef00.din_rail.meters.z2m_absorption",registrations=device_definitions,}
