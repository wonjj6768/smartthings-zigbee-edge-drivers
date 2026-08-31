local zcl=require "protocol.zcl"
local device_helpers=require "contracts.helpers.family"
local registrations,register_device_definition=device_helpers.definition_registry()
local water_tamper_battery_low_battery_sensor={
profile="safety-water-leak-tamper-battery-low-battery",
zcl_clusters={
zcl.water(),
zcl.tamper(),
zcl.battery_low(),
zcl.battery(),
},
}
register_device_definition(water_tamper_battery_low_battery_sensor,{
device_helpers.create_fingerprint(
"_TZ3000_eit7p838" .. string.char(0x20),
"TS0207"
),
})
return{
id="zcl.sensors.wave19_exact_aliases",
registrations=registrations,
}
