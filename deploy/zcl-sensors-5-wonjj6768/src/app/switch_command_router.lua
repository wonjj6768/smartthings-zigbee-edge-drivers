local b={}
function b.route(a)
local c,d=a.uses_zcl_on_off(a.device),a.send_named(a.device,a.command,"switch",a.value)if d then
if c then
if a.value==true and a.begin_power_poll_burst~=nil then
a.begin_power_poll_burst(a.device)end
elseif a.after_ef00_switch_command~=nil then
a.after_ef00_switch_command(a.device,a.command,a.value)end
return true
end
if not c then
return false
end
if a.value==true and a.begin_power_poll_burst~=nil then
a.begin_power_poll_burst(a.device)end
a.default_handler(a.driver,a.device,a.command)return true
end
return b
