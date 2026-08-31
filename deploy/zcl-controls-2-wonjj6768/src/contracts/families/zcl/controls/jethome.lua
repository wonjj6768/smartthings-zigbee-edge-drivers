local zcl=require "protocol.zcl"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local device_management=require "st.zigbee.device_management"
local data_types=require "st.zigbee.data_types"
local device_definitions,register_device_definition=device_helpers.definition_registry()
local ACTIONS={
[0]="release",[1]="single",[2]="double",[3]="triple",[4]="hold",
[256]="release",[257]="single",[258]="double",[259]="triple",[260]="hold",
[512]="release",[513]="single",[514]="double",[515]="triple",[516]="hold",
[1024]="release",[1025]="single",[1026]="double",[1027]="triple",[1028]="hold",
}
local function action_mapping(endpoint)
return zcl.cluster_attribute(0x0012,0x0055,{
name="jethome_ws7_action_in" .. tostring(endpoint),
endpoint=endpoint,
component="main",
emit=assert(emit.jetHomeWs7Action,"missing JetHome WS7 action emitter")(),
data_type=data_types.SinglePrecisionFloat,
from_device=function(value)
local action=ACTIONS[value]
return action and(action .. "_in" .. tostring(endpoint))or nil
end,
})
end
local jet_home_ws7={
profile="buttons-jethome-ws7",
zcl_clusters={
zcl.battery({
endpoint=1,
minimum_interval=3600,
maximum_interval=65000,
reportable_change=0,
read_on_configure=true,
}),
zcl.battery_voltage({
endpoint=1,
minimum_interval=3600,
maximum_interval=65000,
reportable_change=0,
read_on_configure=true,
}),
action_mapping(1),
action_mapping(2),
action_mapping(3),
},
configure=function(driver,device)
device:send(device_management.build_bind_request(
device,
zcl.CLUSTER_POWER_CONFIGURATION,
driver.environment_info.hub_zigbee_eui,
1
))
end,
}
register_device_definition(jet_home_ws7,{
device_helpers.create_fingerprint("JetHome","WS7"),
})
return{
id="zcl.controls.jethome",
registrations=device_definitions,
}
