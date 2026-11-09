local a,c=require"st.capabilities",require"capabilities.events.all"
local function b(_,d)
if d then
return{a.contactSensor.contact.closed(),a.doorControl.door.closed()}end
return{a.contactSensor.contact.open(),a.doorControl.door.open()}
end
return{garage_door_contact=b,countdown=c.garageOpenerCountdown(),run_time=c.garageRunTimeCountdownOpener120(),open_alarm_time=c.garageOpenAlarmTimeOpenerDay(),status=c.garageStatusCountdownOpenerAlarm()}
