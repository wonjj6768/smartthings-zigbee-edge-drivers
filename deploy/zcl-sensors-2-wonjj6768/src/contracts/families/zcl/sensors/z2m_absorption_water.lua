local device_helpers=require "contracts.helpers.family"
local shared_definitions=require "contracts.helpers.zcl_sensor_definitions"
local device_definitions,register_device_definition=device_helpers.definition_registry()
register_device_definition(shared_definitions.water_battery_low_battery_sensor,{
device_helpers.create_fingerprint("eWeLink","CK-TLSR8656-Z23SE11HW-01(7019)"),
})
return{
id="zcl.sensors.z2m_absorption_water",
registrations=device_definitions,
}
