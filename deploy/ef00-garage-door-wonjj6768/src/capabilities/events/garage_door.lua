local capabilities=require "st.capabilities"
local emit=require "capabilities.events.all"
local function emit_garage_door_contact(_,value)
if value then
return{
capabilities.contactSensor.contact.open(),
capabilities.doorControl.door.open(),
}
end
return{
capabilities.contactSensor.contact.closed(),
capabilities.doorControl.door.closed(),
}
end
return{
garage_door_contact=emit_garage_door_contact,
countdown=emit.garageOpenerCountdown(),
run_time=emit.garageRunTimeCountdownOpener120(),
open_alarm_time=emit.garageOpenAlarmTimeOpenerDay(),
status=emit.garageStatusCountdownOpenerAlarm(),
}
