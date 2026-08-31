local tuya=require "protocol.tuya"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local device_definitions,register_device_definition=device_helpers.definition_registry()
local converter=tuya.converter
local function custom(capability_id)
return assert(emit[capability_id],"missing Wave19 WETEN emitter: " .. capability_id)()
end
local function enum(dp,name,capability_id,lookup)
return tuya.dp_enum(dp,{
name=name,
converter=converter.lookup_from_to(lookup),
emit=custom(capability_id),
transaction=1,
skip=function(_,value)return lookup[value]==nil end,
})
end
local function binary(dp,name,capability_id,true_value,false_value)
local lookup={[true_value]=true,[false_value]=false}
return tuya.dp_binary(dp,{
name=name,
converter=converter.lookup_from_to(lookup),
emit=custom(capability_id),
transaction=1,
skip=function(_,value)return lookup[value]==nil end,
})
end
local weten_pci={
profile="bridges-wave19-weten-pci-e",
package_group="wave19-bridge",
transport_classification="EF00_DP",
z2m_converter_source="meta.tuyaDatapoints",
wire_cluster="manuSpecificTuya DP1/101..106",
magic_packet=true,
query_on_configure=false,
named_datapoints=true,
time_start="off",
placeholder_custom_states=false,
datapoints={
tuya.dp_on_off(1,{name="switch",emit=emit.switch(),transaction=1}),
enum(101,"weten_pci_restart_mode","wetenPciRestartMode",{
restart=0,
["force restart"]=1,
["–"]=2,
}),
enum(102,"weten_pci_rf_remote_control","wetenPciRfRemoteControl",{
ON=0,
OFF=1,
}),
binary(103,"weten_pci_rf_pairing","wetenPciRfPairing","ON","OFF"),
binary(104,"weten_pci_buzzer_feedback","wetenPciBuzzerFeedback","ON","OFF"),
enum(105,"weten_pci_power_on_behavior","wetenPciPowerOnBehavior",{
off=0,
on=1,
}),
binary(106,"weten_pci_child_lock","wetenPciChildLock","LOCK","UNLOCK"),
},
}
register_device_definition(weten_pci,{
device_helpers.create_fingerprint("_TZE204_6fk3gewc","TS0601"),
device_helpers.create_fingerprint("_TZE284_6fk3gewc","TS0601"),
})
return{
id="ef00.bridges.wave19",
registrations=device_definitions,
}
