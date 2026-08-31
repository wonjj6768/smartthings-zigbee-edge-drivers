local emit=require "capabilities.events.all"
local screen_switch_events={}
local zms206_one={
backlight_mode=emit.zms206OneBacklightMode,
backlight_brightness=emit.zms206OneBacklightBrightness,
child_lock=emit.zms206OneChildLock,
radar_config=emit.zms206OneRadarConfig,
switch_color_on=emit.zms206OneSwitchColorOn,
switch_color_off=emit.zms206OneSwitchColorOff,
indicator_status=emit.zms206OneIndicatorStatus,
delay_off_color=emit.zms206OneDelayOffColor,
switch_name=emit.zms206OneSwitchName,
relay_status=emit.zms206OneRelayStatus,
countdown=emit.zms206OneCountdown,
}
local zms206_two={
backlight_mode=emit.zms206TwoBacklightMode,
backlight_brightness=emit.zms206TwoBacklightBrightness,
child_lock=emit.zms206TwoChildLock,
radar_config=emit.zms206TwoRadarConfig,
switch_color_on=emit.zms206TwoSwitchColorOn,
switch_color_off=emit.zms206TwoSwitchColorOff,
indicator_status=emit.zms206TwoIndicatorStatus,
delay_off_color=emit.zms206TwoDelayOffColor,
switch_name=emit.zms206TwoSwitchName,
relay_status=emit.zms206TwoRelayStatus,
countdown=emit.zms206TwoCountdown,
}
local zms206_three={
backlight_mode=emit.zms206ThreeBacklightMode,
backlight_brightness=emit.zms206ThreeBacklightBrightness,
child_lock=emit.zms206ThreeChildLock,
radar_config=emit.zms206ThreeRadarConfig,
switch_color_on=emit.zms206ThreeSwitchColorOn,
switch_color_off=emit.zms206ThreeSwitchColorOff,
indicator_status=emit.zms206ThreeIndicatorStatus,
delay_off_color=emit.zms206ThreeDelayOffColor,
switch_name=emit.zms206ThreeSwitchName,
relay_status=emit.zms206ThreeRelayStatus,
countdown=emit.zms206ThreeCountdown,
}
local zms208_two={
child_lock=emit.zms208TwoChildLock,
switch_name=emit.zms208TwoSwitchName,
countdown=emit.zms208TwoCountdown,
}
local zms208_three={
child_lock=emit.zms208ThreeChildLock,
switch_name=emit.zms208ThreeSwitchName,
countdown=emit.zms208ThreeCountdown,
}
local function zms206(factories,gang_count,single_gang)
local events={
switch_main=emit.switch(),
indicator_status=factories.indicator_status(),
backlight_mode=factories.backlight_mode(),
delay_off_color=factories.delay_off_color(),
child_lock=factories.child_lock(),
backlight_brightness=factories.backlight_brightness(),
switch_color_on=factories.switch_color_on(),
switch_color_off=factories.switch_color_off(),
radar_config=factories.radar_config(),
}
if single_gang then
events.countdown_main=factories.countdown()
events.relay_status_main=factories.relay_status()
events.switch_name_main=factories.switch_name()
return events
end
for gang=1,gang_count do
events["switch_" .. gang]=emit.switch()
events["countdown_" .. gang]=factories.countdown()
events["relay_status_" .. gang]=factories.relay_status()
events["switch_name_" .. gang]=factories.switch_name()
end
return events
end
local function zms208(factories,gang_count)
local events={
switch_main=emit.switch(),
child_lock=factories.child_lock(),
}
for gang=1,gang_count do
events["switch_" .. gang]=emit.switch()
events["countdown_" .. gang]=factories.countdown()
events["switch_name_" .. gang]=factories.switch_name()
end
return events
end
function screen_switch_events.zms206us1()
return zms206(zms206_one,1,true)
end
function screen_switch_events.zms206eu2()
return zms206(zms206_two,2,false)
end
function screen_switch_events.zms206eu3()
return zms206(zms206_three,3,false)
end
function screen_switch_events.zms208us2()
return zms208(zms208_two,2)
end
function screen_switch_events.zms208us3()
return zms208(zms208_three,3)
end
return screen_switch_events
