local tuya = require "protocol.tuya.contract"
local screen_switch_events = require "capabilities.events.screen_switch_z2m_absorption"
local converter = tuya.converter
local utf8_text = require "runtime.utf8_text"

local converters = {
  on_off = converter.lookup_from_to({ off = false, on = true }),
  backlight_mode = converter.lookup_from_to({ OFF = false, ON = true }),
  child_lock = converter.lookup_from_to({ UNLOCK = false, LOCK = true }),
  indicator_status = converter.lookup_from_to({ off = 0, on_off_status = 1, switch_position = 2 }),
  color = converter.lookup_from_to({
    red = 0, blue = 1, green = 2, white = 3, yellow = 4,
    magenta = 5, cyan = 6, warm_white = 7, warm_yellow = 8,
  }),
  relay_status = converter.lookup_from_to({ power_off = 0, power_on = 1, restart_memory = 2 }),
  radar_config = converter.lookup_from_to({ none = 0, ["10s"] = 1, ["20s"] = 2, ["30s"] = 3, ["45s"] = 4, ["60s"] = 5 }),
  switch_name = converter.from_to(
    function(value)
      if type(value) ~= "string" then return nil end
      local unpadded = value:gsub("%z+$", "")
      return utf8_text.truncate(unpadded, 12)
    end,
    function(value)
      return utf8_text.truncate(value, 12)
    end
  ),
}

local function fingerprints(manufacturers)
  local result = {}
  for _, manufacturer in ipairs(manufacturers) do
    result[#result + 1] = { manufacturer = manufacturer, model = "TS0601" }
  end
  return result
end

local function append_switch_datapoints(datapoints, config, events)
  if config.single_gang then
    datapoints[#datapoints + 1] = tuya.dp_on_off(1, {
      name = "switch", component = "main", emit = events.switch_main,
    })
    return
  end

  for gang = 1, config.gang_count do
    datapoints[#datapoints + 1] = tuya.dp_on_off(gang, {
      name = "switch", component = "switch" .. gang, emit = events["switch_" .. gang],
    })
  end
end

local function append_countdown_datapoints(datapoints, config, events)
  if config.single_gang then
    datapoints[#datapoints + 1] = tuya.dp_countdown(7, {
      name = config.mapping_prefix .. "_countdown", component = "main", emit = events.countdown_main,
    })
    return
  end

  for gang = 1, config.gang_count do
    datapoints[#datapoints + 1] = tuya.dp_countdown(6 + gang, {
      name = config.mapping_prefix .. "_countdown", component = "switch" .. gang,
      emit = events["countdown_" .. gang],
    })
  end
end

local function append_relay_datapoints(datapoints, config, events)
  if config.single_gang then
    datapoints[#datapoints + 1] = tuya.dp_enum(29, {
      name = config.mapping_prefix .. "_relay_status", component = "main",
      emit = events.relay_status_main, converter = converters.relay_status,
    })
    return
  end

  for gang = 1, config.gang_count do
    datapoints[#datapoints + 1] = tuya.dp_enum(28 + gang, {
      name = config.mapping_prefix .. "_relay_status", component = "switch" .. gang,
      emit = events["relay_status_" .. gang], converter = converters.relay_status,
    })
  end
end

local function append_name_datapoints(datapoints, config, events)
  if config.single_gang then
    datapoints[#datapoints + 1] = tuya.dp_raw(105, {
      name = config.mapping_prefix .. "_switch_name", component = "main",
      emit = events.switch_name_main, converter = converters.switch_name,
    })
    return
  end

  for gang = 1, config.gang_count do
    datapoints[#datapoints + 1] = tuya.dp_raw(104 + gang, {
      name = config.mapping_prefix .. "_switch_name", component = "switch" .. gang,
      emit = events["switch_name_" .. gang], converter = converters.switch_name,
    })
  end
end

local function build_zms206(config)
  local events = config.event_factory()
  local datapoints = {}

  if not config.single_gang then
    datapoints[#datapoints + 1] = tuya.dp_on_off(13, {
      name = "switch", component = "main", emit = events.switch_main,
    })
  end
  append_switch_datapoints(datapoints, config, events)
  append_countdown_datapoints(datapoints, config, events)
  if config.single_gang then
    datapoints[#datapoints + 1] = tuya.dp_on_off(13, {
      name = "switch", component = "main", emit = events.switch_main,
    })
  end
  datapoints[#datapoints + 1] = tuya.dp_enum(15, {
    name = config.mapping_prefix .. "_indicator_status", emit = events.indicator_status,
    converter = converters.indicator_status,
  })
  datapoints[#datapoints + 1] = tuya.dp_binary(16, {
    name = config.mapping_prefix .. "_backlight_mode", emit = events.backlight_mode,
    converter = config.legacy_backlight_mode and converters.on_off or converters.backlight_mode,
  })
  datapoints[#datapoints + 1] = tuya.dp_enum(19, {
    name = config.mapping_prefix .. "_delay_off_color", emit = events.delay_off_color,
    converter = converters.color,
  })
  append_relay_datapoints(datapoints, config, events)
  datapoints[#datapoints + 1] = tuya.dp_binary(101, {
    name = config.mapping_prefix .. "_child_lock", emit = events.child_lock,
    converter = config.legacy_child_lock and converters.on_off or converters.child_lock,
  })
  datapoints[#datapoints + 1] = tuya.dp_numeric(102, {
    name = config.mapping_prefix .. "_backlight_brightness", emit = events.backlight_brightness,
  })
  datapoints[#datapoints + 1] = tuya.dp_enum(103, {
    name = config.mapping_prefix .. "_switch_color_on", emit = events.switch_color_on,
    converter = converters.color,
  })
  datapoints[#datapoints + 1] = tuya.dp_enum(104, {
    name = config.mapping_prefix .. "_switch_color_off", emit = events.switch_color_off,
    converter = converters.color,
  })
  append_name_datapoints(datapoints, config, events)
  datapoints[#datapoints + 1] = tuya.dp_enum(111, {
    name = config.mapping_prefix .. "_radar_config", emit = events.radar_config,
    converter = converters.radar_config,
  })

  return {
    profile = config.profile,
    time_start = "1970",
    datapoints = datapoints,
    fingerprints = fingerprints(config.manufacturers),
  }
end

local function build_zms208(config)
  local events = config.event_factory()
  local datapoints = {
    tuya.dp_on_off(13, { name = "switch", component = "main", emit = events.switch_main }),
  }

  append_switch_datapoints(datapoints, config, events)
  append_countdown_datapoints(datapoints, config, events)
  datapoints[#datapoints + 1] = tuya.dp_binary(101, {
    name = config.mapping_prefix .. "_child_lock", emit = events.child_lock,
    converter = converters.child_lock,
  })
  append_name_datapoints(datapoints, config, events)

  return {
    profile = config.profile,
    datapoints = datapoints,
    fingerprints = fingerprints(config.manufacturers),
  }
end

local zms206us1 = build_zms206({
  profile = "switches-screen-zms206us1",
  event_factory = screen_switch_events.zms206us1,
  mapping_prefix = "zms206_one",
  gang_count = 1,
  single_gang = true,
  manufacturers = { "_TZE204_sa2ueffe", "_TZE204_zuepxzck", "_TZE284_lnyz4a6v" },
})

local zms206eu2 = build_zms206({
  profile = "switches-screen-zms206eu2",
  event_factory = screen_switch_events.zms206eu2,
  mapping_prefix = "zms206_two",
  gang_count = 2,
  manufacturers = { "_TZE284_3ctwoaip", "_TZE204_3ctwoaip", "_TZE284_dmckrsxg" },
})

local zms206eu3 = build_zms206({
  profile = "switches-screen-zms206eu3",
  event_factory = screen_switch_events.zms206eu3,
  mapping_prefix = "zms206_three",
  gang_count = 3,
  manufacturers = {
    "_TZE204_k7v0eqke", "_TZE204_iyki9kjp", "_TZE284_k7v0eqke",
    "_TZE284_e4pf6l87", "_TZE28C1000000_e4pf6l87",
  },
})

local zms208us2 = build_zms208({
  profile = "switches-screen-zms208us2",
  event_factory = screen_switch_events.zms208us2,
  mapping_prefix = "zms208_two",
  gang_count = 2,
  manufacturers = { "_TZE284_a2teqi5u" },
})

local zms208us3 = build_zms208({
  profile = "switches-screen-zms208us3",
  event_factory = screen_switch_events.zms208us3,
  mapping_prefix = "zms208_three",
  gang_count = 3,
  manufacturers = { "_TZE284_xvywzhmi", "_TZE28C1000000_xvywzhmi" },
})

local registrations = { zms206us1, zms206eu2, zms206eu3, zms208us2, zms208us3 }

return {
  id = "ef00.screen_switch.z2m_absorption",
  registrations = registrations,
}
