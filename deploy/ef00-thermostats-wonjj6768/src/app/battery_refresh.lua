local capabilities = require "st.capabilities"
local battery_refresh = {}
local BATTERY_REFRESH_INTERVAL = 24 * 60 * 60
local LAST_BATTERY_REPORT_FIELD = "__battery_refresh_last_report_at"
local LAST_BATTERY_REQUEST_FIELD = "__battery_refresh_last_request_at"
local BATTERY_REFRESH_TIMER_FIELD = "__battery_refresh_timer"
local requester = nil
local function now()
return os.time()
end
local function cancel_timer(device)
local timer = device:get_field(BATTERY_REFRESH_TIMER_FIELD)
if timer ~= nil and type(timer.cancel) == "function" then
pcall(function()
timer:cancel()
end)
end
device:set_field(BATTERY_REFRESH_TIMER_FIELD, nil, { persist = false })
end
function battery_refresh.set_requester(callback)
requester = callback
end
function battery_refresh.has_battery(device)
if type(device) ~= "table" then
return false
end
if type(device.supports_capability_by_id) == "function" and device:supports_capability_by_id(capabilities.battery.ID, "main") then
return true
end
local components = device.profile and device.profile.components or nil
if type(components) ~= "table" then
return false
end
for component_id, _ in pairs(components) do
if type(component_id) == "string"
and type(device.supports_capability_by_id) == "function"
and device:supports_capability_by_id(capabilities.battery.ID, component_id) then
return true
end
end
return false
end
function battery_refresh.note_report(device)
if type(device) == "table" and type(device.set_field) == "function" then
device:set_field(LAST_BATTERY_REPORT_FIELD, now(), { persist = true })
end
end
function battery_refresh.should_request(device)
if type(requester) ~= "function" or not battery_refresh.has_battery(device) then
return false
end
local current = now()
local last_report = device:get_field(LAST_BATTERY_REPORT_FIELD)
if type(last_report) == "number" and current - last_report < BATTERY_REFRESH_INTERVAL then
return false
end
local last_request = device:get_field(LAST_BATTERY_REQUEST_FIELD)
if type(last_request) == "number" and current - last_request < BATTERY_REFRESH_INTERVAL then
return false
end
return true
end
function battery_refresh.request_if_due(device)
if not battery_refresh.should_request(device) then
return false
end
device:set_field(LAST_BATTERY_REQUEST_FIELD, now(), { persist = true })
return requester(device)
end
function battery_refresh.schedule_after_button(device)
if type(device) ~= "table" or device.thread == nil or type(device.thread.call_with_delay) ~= "function" then
return false
end
if not battery_refresh.should_request(device) then
return false
end
device:set_field(LAST_BATTERY_REQUEST_FIELD, now(), { persist = true })
device.thread:call_with_delay(1, function()
if type(requester) == "function" and battery_refresh.has_battery(device) then
requester(device)
end
end, "battery read after button")
return true
end
function battery_refresh.maybe_schedule_after_event(device, event)
local capability_id = event and event.capability and event.capability.ID or nil
local attribute_name = event and event.attribute and event.attribute.NAME or nil
if capability_id == capabilities.button.ID and attribute_name == "button" then
return battery_refresh.schedule_after_button(device)
end
return false
end
function battery_refresh.start_daily(device)
if type(device) ~= "table" or device.thread == nil or type(device.thread.call_on_schedule) ~= "function" then
return false
end
if not battery_refresh.has_battery(device) then
cancel_timer(device)
return false
end
cancel_timer(device)
local timer = device.thread:call_on_schedule(BATTERY_REFRESH_INTERVAL, function()
battery_refresh.request_if_due(device)
end, "battery voltage daily read")
device:set_field(BATTERY_REFRESH_TIMER_FIELD, timer, { persist = false })
return timer ~= nil
end
return battery_refresh
