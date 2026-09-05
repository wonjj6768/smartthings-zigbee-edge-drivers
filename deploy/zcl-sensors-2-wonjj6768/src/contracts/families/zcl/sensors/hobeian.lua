local zcl=require "protocol.zcl"
local device_helpers=require "contracts.helpers.family"
local capabilities=require "st.capabilities"
local data_types=require "st.zigbee.data_types"
local registrations,register_device_definition=device_helpers.definition_registry()
local function status_bit(mask)
return function(value)
if type(value)=="table" then value=value.value end
if type(value)~="number" then return nil end
return bit32.band(value,mask)~=0
end
end
local function passive_ias(mapping)
mapping.minimum_interval=nil
mapping.maximum_interval=nil
mapping.reportable_change=nil
mapping.read_on_configure=false
return mapping
end
local function battery_low_emit(_,value)
if value then return capabilities.batteryLevel.battery.critical()end
return capabilities.batteryLevel.battery.normal()
end
local function battery_percentage(value,_,context)
local raw=context and context.raw_value or value
if type(raw)~="number" or raw >=0xFF then return nil end
return context and value or raw / 2
end
local zg222z={
profile="hobeian-zg222z-water-leak",
additional_zcl_profiles={0x1D73},
magic_packet=false,
zcl_clusters={
passive_ias(zcl.water({
endpoint=1,read_only=true,from_device=status_bit(0x0001),
})),
passive_ias(zcl.tamper({
endpoint=1,read_only=true,from_device=status_bit(0x0004),
})),
passive_ias(zcl.battery_low({
endpoint=1,read_only=true,from_device=status_bit(0x0008),
emit=battery_low_emit,
})),
zcl.battery({
endpoint=1,read_only=true,from_device=battery_percentage,
minimum_interval=3600,maximum_interval=65000,
reportable_change=0,read_on_configure=true,
}),
zcl.cluster_attribute(0x0001,0x003E,{
name="battery_alarm_state",endpoint=1,
data_type=data_types.Bitmap32,read_only=true,read_on_configure=false,
from_device=status_bit(0x00F03C0F),emit=battery_low_emit,
}),
},
parent_refresh=function(device,preset)
zcl.read_named_attribute(device,preset.zcl_clusters,"battery",{endpoint=1})
end,
}
register_device_definition(zg222z,{
device_helpers.create_fingerprint("HOBEIAN","ZG-222Z"),
})
return{
id="zcl.sensors.hobeian",
registrations=registrations,
}
