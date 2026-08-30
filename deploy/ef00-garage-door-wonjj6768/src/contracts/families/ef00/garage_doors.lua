local device_helpers=require "contracts.helpers.family"
local garage_door_opener=require "contracts.families.ef00.garage_door_opener"
local garage_door_opener_countdown=require "contracts.families.ef00.garage_door_opener_countdown"
local device_definitions,register_device_definition=device_helpers.definition_registry()
register_device_definition(garage_door_opener.definition,garage_door_opener.fingerprint_groups[1])
register_device_definition(garage_door_opener.definition,garage_door_opener.fingerprint_groups[2])
register_device_definition(
garage_door_opener_countdown.definition,
garage_door_opener_countdown.fingerprint_groups[1]
)
return{
id="ef00.garage_doors",
registrations=device_definitions,
}
