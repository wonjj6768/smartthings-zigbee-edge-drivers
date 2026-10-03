local zcl=require"protocol.zcl"
local device_helpers=require"contracts.helpers.family"
local registrations,register_device_definition=device_helpers.definition_registry()
local zg204zl_ias={
profile="zg204zl-ias-motion-battery",
magic_packet=false,
zcl_clusters={
zcl.motion({
endpoint=1,read_only=true,read_on_configure=false,
from_device=function(value)
if type(value)=="table"then value=value.value end
return bit32.band(value,0x0001)~=0
end,
}),
zcl.battery({
endpoint=1,read_only=true,
minimum_interval=3600,maximum_interval=65000,reportable_change=0,
read_on_configure=true,
from_device=function(value,_,context)
local raw=context and context.raw_value or value
if raw==0xFF then return nil end
return context and value or raw/2
end,
}),},
parent_refresh=function(device,definition)
zcl.read_named_attribute(device,definition.zcl_clusters,"motion",{endpoint=1})
zcl.read_named_attribute(device,definition.zcl_clusters,"battery",{endpoint=1})
end,
}
zg204zl_ias.zcl_clusters[1].minimum_interval=nil
zg204zl_ias.zcl_clusters[1].maximum_interval=nil
zg204zl_ias.zcl_clusters[1].reportable_change=nil
register_device_definition(zg204zl_ias,{device_helpers.create_fingerprint("_TZ3000_hgbahzmy","ZG-204Z")})
return{id="zcl.sensors.zg204zl",registrations=registrations,}
