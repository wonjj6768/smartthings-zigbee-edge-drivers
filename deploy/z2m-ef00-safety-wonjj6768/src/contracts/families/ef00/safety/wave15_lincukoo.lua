local tuya=require "protocol.tuya"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local converter=tuya.converter
local device_definitions,register_device_definition=device_helpers.definition_registry()
local function custom(name)
return assert(emit[name],"missing Wave15 Lincukoo emitter: " .. name)()
end
local gas_co={
profile="safety-wave15-lincukoo-e04cf-z10t",
package_group="gas-co-sensor",
transport_classification="EF00_DP",
z2m_converter_source="meta.tuyaDatapoints",
wire_cluster="manuSpecificTuya",
magic_packet=true,
query_on_configure=false,
time_start="off",
datapoints={
tuya.dp_enum(1,{
name="gas",read_only=true,transaction=1,
converter=converter.from_only(function(value)return value==true or tonumber(value)==1 end),
emit=emit.gas(),
}),
tuya.dp_numeric(2,{
name="e_four_gas_level",read_only=true,transaction=1,
converter=converter.divide_by_pair(1000),
emit=custom("eFourGasLevel"),
}),
tuya.dp_binary(8,{
name="e_four_self_checking",transaction=1,
converter=converter.lookup_from_to({ON=true,OFF=false}),
emit=custom("eFourSelfChecking"),
}),
tuya.dp_enum(9,{
name="e_four_checking_result",read_only=true,transaction=1,
converter=converter.from_only(converter.lookup_value({
[0]="checking",[1]="check_success",[2]="check_failure",[3]="others",
})),
emit=custom("eFourCheckingResult"),
}),
tuya.dp_enum(18,{
name="carbon_monoxide",read_only=true,transaction=1,
converter=converter.from_only(function(value)return value==true or tonumber(value)==1 end),
emit=emit.carbon_monoxide(),
}),
tuya.dp_numeric(19,{
name="co",read_only=true,transaction=1,
emit=emit.carbon_monoxide_level(),
}),
tuya.dp_numeric(101,{
name="e_four_max_gas_alarm",transaction=1,
converter=converter.divide_by_pair(1000),
emit=custom("eFourMaxGasAlarm"),
}),
tuya.dp_numeric(102,{
name="e_four_max_co_alarm",transaction=1,
emit=custom("eFourMaxCoAlarm"),
}),
},
}
register_device_definition(gas_co,device_helpers.create_fingerprints("TS0601",{
"_TZE204_ra9zfiwr",
}))
return{
id="ef00.safety.wave15_lincukoo",
registrations=device_definitions,
}
