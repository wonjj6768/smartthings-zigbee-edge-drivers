local tuya=require"protocol.tuya"
local emit=require"capabilities.events.all"
local device_helpers=require"contracts.helpers.family"
local device_definitions,register_device_definition=device_helpers.definition_registry()
local converter=tuya.converter
local MAKEGOOD_ENERGY_FIELD="__makegood_incremental_energy_total"
local function makegood_incremental_energy_from_device(value,device)
local raw=tonumber(value)
if raw==nil then return nil end
local previous=tonumber(device:get_field(MAKEGOOD_ENERGY_FIELD))
if previous==nil and type(device.get_latest_state)=="function"then
previous=tonumber(device:get_latest_state("main","energyMeter","energy"))
end
previous=previous or 0
local increment=raw/1000
local total=previous
if increment>0 then
total=math.floor((previous+increment)*1000+0.5)/1000
end
device:set_field(MAKEGOOD_ENERGY_FIELD,total,{persist=true})
return total
end
local semicom_6switch={
profile="switches-switch-6",
package_group="switch-basic",
query_on_configure=false,
tuya.dp_on_off(1,{name="switch",component="main"}),
tuya.dp_on_off(2,{name="switch",component="switch2"}),
tuya.dp_on_off(3,{name="switch",component="switch3"}),
tuya.dp_on_off(4,{name="switch",component="switch4"}),
tuya.dp_on_off(5,{name="switch",component="switch5"}),
tuya.dp_on_off(6,{name="switch",component="switch6"}),}
register_device_definition(semicom_6switch,device_helpers.create_fingerprints("TS0601",{
"_TZE204_8eazvzo6",}))
local grxx6qek_temperature_humidity_switch={
profile="switches-switch-1-temp-humidity",
package_group="switch-basic",
query_on_configure=false,
time_start="1970",
datapoints={
tuya.dp_on_off(2,{name="switch",component="main",suppress_optimistic_state=true}),
tuya.dp_temperature(27,{read_only=true,scale=10,emit=emit.temperature("C")}),
tuya.dp_humidity(46,{read_only=true,scale=1,emit=emit.humidity()}),},}
register_device_definition(grxx6qek_temperature_humidity_switch,
device_helpers.create_fingerprints("TS0601",{"_TZE284_grxx6qek"}))
local zemismart_zmz609_two_core={
profile="switches-zemismart-zmz609-2-core",
package_group="switch-basic",
transport_classification="EF00_DP",
z2m_converter_source="meta.tuyaDatapoints",
wire_cluster="manuSpecificTuya",
magic_packet=true,
mcu_version_request_on_configure=true,
query_on_configure=false,
named_datapoints=true,
time_start="1970",
placeholder_custom_states=false,
datapoints={
tuya.dp_on_off(1,{name="switch",component="main",transaction=1,emit=emit.switch()}),
tuya.dp_on_off(2,{name="switch",component="switch2",transaction=1,emit=emit.switch()}),
tuya.dp_energy(20,{name="energy",scale=1000,read_only=true,transaction=1,emit=emit.energy()}),
tuya.dp_current(21,{name="current",scale=1000,read_only=true,transaction=1,emit=emit.current()}),
tuya.dp_power(22,{name="power",scale=10,read_only=true,transaction=1,emit=emit.power()}),
tuya.dp_voltage(23,{name="voltage",scale=10,read_only=true,transaction=1,emit=emit.voltage()}),},}
register_device_definition(zemismart_zmz609_two_core,{
device_helpers.create_fingerprint("_TZE284_o409r73p","TS0601"),
device_helpers.create_fingerprint("_TZE28C1000000_o409r73p","TS0601"),})
local tuya_6gang_switch_two_core={
profile="switches-tuya-6gang-switch-2-core",
package_group="switch-basic",
transport_classification="EF00_DP",
z2m_converter_source="meta.tuyaDatapoints",
wire_cluster="manuSpecificTuya",
magic_packet=true,
mcu_version_request_on_configure=true,
query_on_configure=false,
named_datapoints=true,
time_start="off",
placeholder_custom_states=false,
datapoints={
tuya.dp_on_off(1,{name="switch",component="main",transaction=1,emit=emit.switch()}),
tuya.dp_on_off(2,{name="switch",component="switch2",transaction=1,emit=emit.switch()}),
tuya.dp_on_off(3,{name="switch",component="switch3",transaction=1,emit=emit.switch()}),
tuya.dp_on_off(4,{name="switch",component="switch4",transaction=1,emit=emit.switch()}),
tuya.dp_on_off(5,{name="switch",component="switch5",transaction=1,emit=emit.switch()}),
tuya.dp_on_off(6,{name="switch",component="switch6",transaction=1,emit=emit.switch()}),
tuya.dp_energy(20,{name="energy",scale=100,read_only=true,transaction=1,emit=emit.energy()}),
tuya.dp_current(21,{name="current",scale=1000,read_only=true,transaction=1,emit=emit.current()}),
tuya.dp_power(22,{name="power",scale=10,read_only=true,transaction=1,emit=emit.power()}),
tuya.dp_voltage(23,{name="voltage",scale=10,read_only=true,transaction=1,emit=emit.voltage()}),
tuya.dp_on_off(136,{name="switch",component="all",transaction=1,emit=emit.switch()}),},}
register_device_definition(tuya_6gang_switch_two_core,{
device_helpers.create_fingerprint("_TZE284_hbxadcl0","TS0601"),})
local makegood_mg_gpo02z_core={
profile="switches-makegood-mg-gpo02z-core",
package_group="switch-basic",
transport_classification="EF00_DP",
z2m_converter_source="meta.tuyaDatapoints",
wire_cluster="manuSpecificTuya",
magic_packet=true,
mcu_version_request_on_configure=true,
query_on_configure=false,
named_datapoints=true,
time_start="1970",
placeholder_custom_states=false,
datapoints={
tuya.dp_on_off(1,{name="switch",component="main",transaction=1,emit=emit.switch()}),
tuya.dp_on_off(2,{name="switch",component="switch2",transaction=1,emit=emit.switch()}),
tuya.dp_energy(20,{
name="energy",
read_only=true,
transaction=1,
converter=converter.from_only(makegood_incremental_energy_from_device),
emit=emit.energy(),}),
tuya.dp_current(21,{name="current",scale=1000,read_only=true,transaction=1,emit=emit.current()}),
tuya.dp_power(22,{name="power",scale=10,read_only=true,transaction=1,emit=emit.power()}),
tuya.dp_voltage(23,{name="voltage",scale=10,read_only=true,transaction=1,emit=emit.voltage()}),
tuya.dp_on_off(136,{name="switch",component="all",transaction=1,emit=emit.switch()}),},}
register_device_definition(makegood_mg_gpo02z_core,{
device_helpers.create_fingerprint("_TZE200_lq0ffndf","TS0601"),})
local makegood_mg_au03_core={
profile="switches-makegood-mg-au03-core",
package_group="switch-basic",
transport_classification="EF00_DP",
z2m_converter_source="meta.tuyaDatapoints",
wire_cluster="manuSpecificTuya",
magic_packet=true,
mcu_version_request_on_configure=true,
query_on_configure=false,
named_datapoints=true,
time_start="1970",
placeholder_custom_states=false,
datapoints={
tuya.dp_on_off(1,{name="switch",component="main",transaction=1,emit=emit.switch()}),
tuya.dp_on_off(2,{name="switch",component="switch2",transaction=1,emit=emit.switch()}),
tuya.dp_on_off(3,{name="switch",component="switch3",transaction=1,emit=emit.switch()}),
tuya.dp_energy(20,{
name="energy",
read_only=true,
transaction=1,
converter=converter.from_only(makegood_incremental_energy_from_device),
emit=emit.energy(),}),
tuya.dp_current(21,{name="current",scale=1000,read_only=true,transaction=1,emit=emit.current()}),
tuya.dp_power(22,{name="power",scale=10,read_only=true,transaction=1,emit=emit.power()}),
tuya.dp_voltage(23,{name="voltage",scale=10,read_only=true,transaction=1,emit=emit.voltage()}),
tuya.dp_on_off(136,{name="switch",component="all",transaction=1,emit=emit.switch()}),},}
register_device_definition(makegood_mg_au03_core,{
device_helpers.create_fingerprint("_TZE200_4jvmbiph","TS0601"),})
local tuya_mg_au03gpozlp_core={
profile="switches-tuya-mg-au03gpozlp-core",
package_group="switch-basic",
transport_classification="EF00_DP",
z2m_converter_source="meta.tuyaDatapoints",
wire_cluster="manuSpecificTuya",
magic_packet=true,
mcu_version_request_on_configure=true,
query_on_configure=false,
named_datapoints=true,
time_start="off",
placeholder_custom_states=false,
datapoints={
tuya.dp_on_off(1,{name="switch",component="main",transaction=1,emit=emit.switch()}),
tuya.dp_on_off(2,{name="switch",component="switch2",transaction=1,emit=emit.switch()}),
tuya.dp_energy(20,{name="energy",scale=1000,read_only=true,transaction=1,emit=emit.energy()}),
tuya.dp_current(21,{name="current",scale=1000,read_only=true,transaction=1,emit=emit.current()}),
tuya.dp_power(22,{name="power",scale=10,read_only=true,transaction=1,emit=emit.power()}),
tuya.dp_voltage(23,{name="voltage",scale=10,read_only=true,transaction=1,emit=emit.voltage()}),},}
register_device_definition(tuya_mg_au03gpozlp_core,{
device_helpers.create_fingerprint("_TZE284_lq0ffndf","TS0601"),})
local tervix_x10={
profile="switches-tervix-x10",
package_group="switch-basic",
magic_packet=true,
mcu_version_request_on_configure=true,
query_on_configure=true,
query_on_announce=true,
announce_delay=0,
time_start="off",
placeholder_custom_states=false,
datapoints={
tuya.dp_on_off(33,{name="switch",component="main",suppress_optimistic_state=true}),
tuya.dp_on_off(101,{name="switch",component="zone1",suppress_optimistic_state=true}),
tuya.dp_on_off(102,{name="switch",component="zone2",suppress_optimistic_state=true}),
tuya.dp_on_off(103,{name="switch",component="zone3",suppress_optimistic_state=true}),
tuya.dp_on_off(104,{name="switch",component="zone4",suppress_optimistic_state=true}),
tuya.dp_on_off(105,{name="switch",component="zone5",suppress_optimistic_state=true}),
tuya.dp_on_off(106,{name="switch",component="zone6",suppress_optimistic_state=true}),
tuya.dp_on_off(107,{name="switch",component="zone7",suppress_optimistic_state=true}),
tuya.dp_on_off(108,{name="switch",component="zone8",suppress_optimistic_state=true}),
tuya.dp_enum(109,{
name="tervix_x10_pump",read_only=true,emit=emit.tervixX10Pump(),
converter=converter.from_only(function(value)return(value==1 or value==true)and"ON"or"OFF"end),
}),
tuya.dp_enum(110,{
name="tervix_x10_boiler",read_only=true,emit=emit.tervixX10Boiler(),
converter=converter.from_only(function(value)return(value==1 or value==true)and"ON"or"OFF"end),
}),
tuya.dp_enum(111,{
name="tervix_x10_system_mode",emit=emit.tervixX10SystemMode(),
converter=converter.from_to(
function(value)return(value==1 or value==true)and"heat"or"cool"end,
function(value)return value=="heat"and 1 or 0 end
),}),},}
register_device_definition(tervix_x10,{
device_helpers.create_fingerprint("_TZE284_rfpyqax9","TS0601"),
device_helpers.create_fingerprint("_TZE204_rfpyqax9","TS0601"),})
local automaton_ch8z={
profile="switches-automaton-ch8z",
magic_packet=true,
mcu_version_request_on_configure=true,
query_on_configure=true,
query_on_announce=true,
announce_delay=0,
time_start="off",
datapoints={
tuya.dp_on_off(1,{name="switch",component="main",emit=emit.switch()}),
tuya.dp_on_off(2,{name="switch",component="switch2",emit=emit.switch()}),
tuya.dp_on_off(3,{name="switch",component="switch3",emit=emit.switch()}),
tuya.dp_on_off(4,{name="switch",component="switch4",emit=emit.switch()}),
tuya.dp_on_off(5,{name="switch",component="switch5",emit=emit.switch()}),
tuya.dp_on_off(6,{name="switch",component="switch6",emit=emit.switch()}),
tuya.dp_on_off(7,{name="switch",component="switch7",emit=emit.switch()}),
tuya.dp_on_off(8,{name="switch",component="switch8",emit=emit.switch()}),
tuya.dp_numeric(9,{name="ch8z_countdown_one",component="main",emit=emit.ch8zCountdownOne()}),
tuya.dp_numeric(10,{name="ch8z_countdown_two",component="switch2",emit=emit.ch8zCountdownTwo()}),
tuya.dp_numeric(11,{name="ch8z_countdown_three",component="switch3",emit=emit.ch8zCountdownThree()}),
tuya.dp_numeric(12,{name="ch8z_countdown_four",component="switch4",emit=emit.ch8zCountdownFour()}),
tuya.dp_numeric(13,{name="ch8z_countdown_five",component="switch5",emit=emit.ch8zCountdownFive()}),
tuya.dp_numeric(14,{name="ch8z_countdown_six",component="switch6",emit=emit.ch8zCountdownSix()}),
tuya.dp_numeric(15,{name="ch8z_countdown_seven",component="switch7",emit=emit.ch8zCountdownSeven()}),
tuya.dp_numeric(16,{name="ch8z_countdown_eight",component="switch8",emit=emit.ch8zCountdownEight()}),
tuya.dp_enum(27,{
name="ch8z_power_behavior",emit=emit.ch8zPowerBehavior(),
converter=converter.lookup_from_to({off=0,on=1,previous=2}),}),
tuya.dp_binary(29,{
name="ch8z_child_lock",emit=emit.ch8zChildLock(),
converter=converter.lookup_from_to({LOCK=true,UNLOCK=false}),}),},}
register_device_definition(automaton_ch8z,{
device_helpers.create_fingerprint("_TZE284_1oft6qso","TS0601"),})
return{
id="ef00.switch.basic.z2m_absorption",
registrations=device_definitions,}
