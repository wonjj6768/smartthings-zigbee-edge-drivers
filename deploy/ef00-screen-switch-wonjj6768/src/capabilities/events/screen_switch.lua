local b,d=require"capabilities.events.all",{}local f={time_zone=b.zms206us4TimeZone,backlight_mode=b.zmsFourBacklightSetting,backlight_brightness=b.zmsFourBacklightBrightness,child_lock=b.zmsFourChildLock,radar_config=b.zmsFourRadarConfig,switch_color_on=b.zmsFourSwitchColorOn,switch_color_off=b.zmsFourSwitchColorOff,indicator_status=b.zmsFourIndicatorStatus,delay_off_color=b.zmsFourDelayOffColor,switch_name=b.zms206us4SwitchName,relay_status=b.zmsFourRelayStatus,countdown=b.zmsFourCountdown}
local function h(a,g,e)
local c={time_zone=a.time_zone(),switch_main=b.switch(),indicator_status=a.indicator_status(),backlight_mode=a.backlight_mode(),delay_off_color=a.delay_off_color(),child_lock=a.child_lock(),backlight_brightness=a.backlight_brightness(),switch_color_on=a.switch_color_on(),switch_color_off=a.switch_color_off(),radar_config=a.radar_config()}if e then
c.countdown_main=a.countdown()c.relay_status_main=a.relay_status()c.switch_name_main=a.switch_name()return c
end
for gang=1,g do
c["switch_"..gang]=b.switch()c["countdown_"..gang]=a.countdown()c["relay_status_"..gang]=a.relay_status()c["switch_name_"..gang]=a.switch_name()end
return c
end
function d.zms206us4()
return h(f,4,false)
end
return d
