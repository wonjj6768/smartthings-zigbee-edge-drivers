local tuya=require "protocol.tuya"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local converter=tuya.converter
local device_definitions,register_device_definition=device_helpers.definition_registry()
local function custom(name)
return assert(emit[name],"missing Wave15 BOX switch emitter: " .. name)()
end
local erc_two={
profile="switches-wave15-box-erc2202z",
package_group="rf-dual-controller",
transport_classification="EF00_DP",
z2m_converter_source="modernExtend.dp*",
wire_cluster="manuSpecificTuya",
magic_packet=true,
query_on_configure=false,
time_start="off",
datapoints={
tuya.dp_on_off(19,{name="switch",component="main",transaction=1,emit=emit.switch()}),
tuya.dp_on_off(20,{name="switch",component="switch2",transaction=1,emit=emit.switch()}),
tuya.dp_enum(0x66,{
name="erc_two_record_rf",transaction=1,
converter=converter.lookup_from_to({record_l1=0,record_l2=1}),
emit=custom("ercTwoRecordRf"),
}),
tuya.dp_enum(0x66,{
name="erc_two_clear_rf",transaction=1,
converter=converter.lookup_from_to({clear_l1=2,clear_l2=3}),
emit=custom("ercTwoClearRf"),
}),
tuya.dp_enum(0x67,{
name="erc_two_rf_status",read_only=true,transaction=1,
converter=converter.from_only(converter.lookup_value({[0]="ok",[1]="error"})),
emit=custom("ercTwoRfStatus"),
}),
},
}
register_device_definition(erc_two,device_helpers.create_fingerprints("TS0601",{
"_TZE200_o7vduidq",
}))
return{
id="ef00.switches.wave15_box",
registrations=device_definitions,
}
