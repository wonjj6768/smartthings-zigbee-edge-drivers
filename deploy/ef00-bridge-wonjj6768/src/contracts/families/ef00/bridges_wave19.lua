local j,p,b=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family"local d,c=b.definition_registry()local f=j.converter
local function l(capability_id)
return assert(p[capability_id],"missing Wave19 WETEN emitter: "..capability_id)()
end
local function n(q,o,capability_id,e)
return j.dp_enum(q,{name=o,converter=f.lookup_from_to(e),emit=l(capability_id),transaction=1,
skip=function(_,k)return e[k]==nil end
})
end
local function g(q,o,capability_id,i,h)
local e={[i]=true,[h]=false}return j.dp_binary(q,{name=o,converter=f.lookup_from_to(e),emit=l(capability_id),transaction=1,
skip=function(_,k)return e[k]==nil end
})
end
local m={profile="bridges-wave19-weten-pci-e",package_group="wave19-bridge",magic_packet=true,query_on_configure=false,named_datapoints=true,time_start="off",datapoints={j.dp_on_off(1,{name="switch",emit=p.switch(),transaction=1}),n(101,"weten_pci_restart_mode","wetenPciRestartMode",{restart=0,["force restart"]=1,["–"]=2}),n(102,"weten_pci_rf_remote_control","wetenPciRfRemoteControl",{ON=0,OFF=1}),g(103,"weten_pci_rf_pairing","wetenPciRfPairing","ON","OFF"),g(104,"weten_pci_buzzer_feedback","wetenPciBuzzerFeedback","ON","OFF"),n(105,"weten_pci_power_on_behavior","wetenPciPowerOnBehavior",{off=0,on=1}),g(106,"weten_pci_child_lock","wetenPciChildLock","LOCK","UNLOCK")}}c(m,{b.create_fingerprint("_TZE204_6fk3gewc","TS0601"),b.create_fingerprint("_TZE284_6fk3gewc","TS0601"),b.create_fingerprint("_TZE28C1000000_6fk3gewc","TS0601")})return{id="ef00.bridges.wave19",registrations=d}
