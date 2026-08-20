local switch_command_router = {}
function switch_command_router.route(options)
local is_zcl = options.uses_zcl_on_off(options.device)
local handled = options.send_named(options.device, options.command, "switch", options.value)
if handled then
if is_zcl then
if options.value == true and options.begin_power_poll_burst ~= nil then
options.begin_power_poll_burst(options.device)
end
elseif options.after_ef00_switch_command ~= nil then
options.after_ef00_switch_command(options.device, options.command, options.value)
end
return true
end
if not is_zcl then
return false
end
if options.value == true and options.begin_power_poll_burst ~= nil then
options.begin_power_poll_burst(options.device)
end
options.default_handler(options.driver, options.device, options.command)
return true
end
return switch_command_router
