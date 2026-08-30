local emit = require "capabilities.events.all"

local screen_switch_events = {}











































local zms206_four = {
  backlight_mode = emit.zmsFourBacklightSetting,
  backlight_brightness = emit.zmsFourBacklightBrightness,
  child_lock = emit.zmsFourChildLock,
  radar_config = emit.zmsFourRadarConfig,
  switch_color_on = emit.zmsFourSwitchColorOn,
  switch_color_off = emit.zmsFourSwitchColorOff,
  indicator_status = emit.zmsFourIndicatorStatus,
  delay_off_color = emit.zmsFourDelayOffColor,
  switch_name = emit.zmsFourSwitchName,
  relay_status = emit.zmsFourRelayStatus,
  countdown = emit.zmsFourCountdown,
}













local function zms206(factories, gang_count, single_gang)
  local events = {
    switch_main = emit.switch(),
    indicator_status = factories.indicator_status(),
    backlight_mode = factories.backlight_mode(),
    delay_off_color = factories.delay_off_color(),
    child_lock = factories.child_lock(),
    backlight_brightness = factories.backlight_brightness(),
    switch_color_on = factories.switch_color_on(),
    switch_color_off = factories.switch_color_off(),
    radar_config = factories.radar_config(),
  }

  if single_gang then
    events.countdown_main = factories.countdown()
    events.relay_status_main = factories.relay_status()
    events.switch_name_main = factories.switch_name()
    return events
  end

  for gang = 1, gang_count do
    events["switch_" .. gang] = emit.switch()
    events["countdown_" .. gang] = factories.countdown()
    events["relay_status_" .. gang] = factories.relay_status()
    events["switch_name_" .. gang] = factories.switch_name()
  end

  return events
end




























function screen_switch_events.zms206us4()
  return zms206(zms206_four, 4, false)
end









return screen_switch_events
