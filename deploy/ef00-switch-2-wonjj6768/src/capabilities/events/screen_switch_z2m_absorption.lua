local a,c=require"capabilities.events.all",{}local j,k,g,l,h={backlight_mode=a.zms206OneBacklightMode,backlight_brightness=a.zms206OneBacklightBrightness,child_lock=a.zms206OneChildLock,radar_config=a.zms206OneRadarConfig,switch_color_on=a.zms206OneSwitchColorOn,switch_color_off=a.zms206OneSwitchColorOff,indicator_status=a.zms206OneIndicatorStatus,delay_off_color=a.zms206OneDelayOffColor,switch_name=a.zms206OneSwitchName,relay_status=a.zms206OneRelayStatus,countdown=a.zms206OneCountdown},{backlight_mode=a.zms206TwoBacklightMode,backlight_brightness=a.zms206TwoBacklightBrightness,child_lock=a.zms206TwoChildLock,radar_config=a.zms206TwoRadarConfig,switch_color_on=a.zms206TwoSwitchColorOn,switch_color_off=a.zms206TwoSwitchColorOff,indicator_status=a.zms206TwoIndicatorStatus,delay_off_color=a.zms206TwoDelayOffColor,switch_name=a.zms206TwoSwitchName,relay_status=a.zms206TwoRelayStatus,countdown=a.zms206TwoCountdown},{backlight_mode=a.zms206ThreeBacklightMode,backlight_brightness=a.zms206ThreeBacklightBrightness,child_lock=a.zms206ThreeChildLock,radar_config=a.zms206ThreeRadarConfig,switch_color_on=a.zms206ThreeSwitchColorOn,switch_color_off=a.zms206ThreeSwitchColorOff,indicator_status=a.zms206ThreeIndicatorStatus,delay_off_color=a.zms206ThreeDelayOffColor,switch_name=a.zms206ThreeSwitchName,relay_status=a.zms206ThreeRelayStatus,countdown=a.zms206ThreeCountdown},{child_lock=a.zms208TwoChildLock,switch_name=a.zms208TwoSwitchName,countdown=a.zms208TwoCountdown},{child_lock=a.zms208ThreeChildLock,switch_name=a.zms208ThreeSwitchName,countdown=a.zms208ThreeCountdown}
local function f(b,e,i)
local d={switch_main=a.switch(),indicator_status=b.indicator_status(),backlight_mode=b.backlight_mode(),delay_off_color=b.delay_off_color(),child_lock=b.child_lock(),backlight_brightness=b.backlight_brightness(),switch_color_on=b.switch_color_on(),switch_color_off=b.switch_color_off(),radar_config=b.radar_config()}if i then
d.countdown_main=b.countdown()d.relay_status_main=b.relay_status()d.switch_name_main=b.switch_name()return d
end
for gang=1,e do
d["switch_"..gang]=a.switch()d["countdown_"..gang]=b.countdown()d["relay_status_"..gang]=b.relay_status()d["switch_name_"..gang]=b.switch_name()end
return d
end
local function m(b,e)
local d={switch_main=a.switch(),child_lock=b.child_lock()}for gang=1,e do
d["switch_"..gang]=a.switch()d["countdown_"..gang]=b.countdown()d["switch_name_"..gang]=b.switch_name()end
return d
end
function c.zms206us1()
return f(j,1,true)
end
function c.zms206eu2()
return f(k,2,false)
end
function c.zms206eu3()
return f(g,3,false)
end
function c.zms208us2()
return m(l,2)
end
function c.zms208us3()
return m(h,3)
end
return c
