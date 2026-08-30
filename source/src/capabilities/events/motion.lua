local emit = require "capabilities.events.all"

local function aoyan_ay_204z()
  return {
    motion = emit.motion(),
    battery = emit.battery(),
    sensitivity = emit.ay204zSensitivity(),
    keep_time = emit.ay204zKeepTime(),
  }
end

local function lincukoo_szlm04u()
  return {
    motion = emit.motion(),
    illuminance = emit.illuminance(),
    battery = emit.battery(),
    usb_power = emit.szlm04uUsbPower(),
    sensor_switch = emit.szlm04uSensorSwitch(),
    fading_time = emit.szlm04uFadingTime(),
  }
end

return {
  aoyan_ay_204z = aoyan_ay_204z,
  lincukoo_szlm04u = lincukoo_szlm04u,
}
