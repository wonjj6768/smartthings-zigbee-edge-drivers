local capabilities = require "st.capabilities"

local emit = require "capabilities.events.all"

-- Keep this function at the original family source line so Lua's stripped
-- bytecode retains the established runtime identity. The semantic source-token
-- contract is path-independent, while Lua still encodes a nested function's
-- definition lines in string.dump output. These six source lines preserve that
-- identity as the contact event moves into its root capability event module.
-- Package compaction removes the comments without changing deployed behavior.
local function emit_garage_door_contact(_, value)
  if value then
    return {
      capabilities.contactSensor.contact.open(),
      capabilities.doorControl.door.open(),
    }
  end

  return {
    capabilities.contactSensor.contact.closed(),
    capabilities.doorControl.door.closed(),
  }
end

return {
  garage_door_contact = emit_garage_door_contact,
  countdown = emit.garageOpenerCountdown(),
  run_time = emit.garageRunTimeCountdownOpener120(),
  open_alarm_time = emit.garageOpenAlarmTimeOpenerDay(),
  status = emit.garageStatusCountdownOpenerAlarm(),
}
