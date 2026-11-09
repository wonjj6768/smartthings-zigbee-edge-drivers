local a=require"capabilities.events.all"
local function c()
return{motion=a.motion(),battery=a.battery(),sensitivity=a.ay204zSensitivity(),keep_time=a.ay204zKeepTime()}
end
local function b()
return{motion=a.motion(),illuminance=a.illuminance(),battery=a.battery(),usb_power=a.szlm04uUsbPower(),sensor_switch=a.szlm04uSensorSwitch(),fading_time=a.szlm04uFadingTime()}
end
return{aoyan_ay_204z=c,lincukoo_szlm04u=b}
