local function load_fans() local tuya = require "protocol.tuya"
  local emit = require "capabilities.events.all"
  local device_helpers = require "contracts.helpers.family"

  local converter = tuya.converter
  local device_definitions, register_device_definition = device_helpers.definition_registry()

  local function percent(value)
    local n = tonumber(value)
    if n == nil then return nil end
    if n < 0 then return 0 end
    if n > 100 then return 100 end
    return math.floor(n + 0.5)
  end

  -- Z2M exposes DP101 as minimum/medium/maximum. SmartThings uses
  -- low/medium/high and also sends "on" as a high-speed alias. Keep the write
  -- alias, but make the read direction explicit so raw 2 cannot depend on Lua's
  -- table iteration order.
  local three_speed_fan_mode = converter.from_to(
    function(value)
      if value == 0 then return "low" end
      if value == 1 then return "medium" end
      if value == 2 then return "high" end
      return nil
    end,
    function(value)
      if value == "low" then return 0 end
      if value == "medium" then return 1 end
      if value == "high" or value == "on" then return 2 end
      return nil
    end
  )

  local five_speed_fan_mode = converter.from_to(
    function(value)
      if value <= 1 then return "low" end
      if value == 2 then return "medium" end
      return "high"
    end,
    function(value)
      if value == "low" then return 0 end
      if value == "medium" then return 2 end
      if value == "high" or value == "on" then return 4 end
      return nil
    end
  )

  local zero_based_five_speed = converter.from_to(
    function(value)
      local n = tonumber(value) or 0
      if n <= 0 then return "low" end
      if n == 1 then return "low" end
      if n == 2 then return "medium" end
      return "high"
    end,
    function(value)
      if value == "low" then return 1 end
      if value == "medium" then return 2 end
      if value == "high" or value == "on" then return 4 end
      return nil
    end
  )

  local stepped_level = converter.from_to(
    function(value)
      if value <= 300 then return 20 end
      if value <= 410 then return 40 end
      if value <= 520 then return 60 end
      if value <= 650 then return 80 end
      return 100
    end,
    function(value)
      local level = percent(value)
      if level == nil then return nil end
      if level <= 20 then return 300 end
      if level <= 40 then return 410 end
      if level <= 60 then return 520 end
      if level <= 80 then return 650 end
      return 1000
    end
  )

  local coarse_light_level = converter.from_to(
    function(value)
      if value <= 300 then return 10 end
      if value <= 410 then return 30 end
      if value <= 520 then return 50 end
      if value <= 650 then return 70 end
      return 100
    end,
    function(value)
      local level = percent(value)
      if level == nil then return nil end
      if level <= 10 then return 300 end
      if level <= 30 then return 410 end
      if level <= 50 then return 520 end
      if level <= 70 then return 650 end
      return 1000
    end
  )

  local percentage_level = converter.from_to(percent, percent)

  -- Z2M TS0601_fan_and_light_switch (tuya.ts:15326): DP1 fan state, DP101 fan
  -- speed minimum/medium/maximum, DP11 power-on behavior OFF/ON and DP5 the
  -- light switch.  Power-on behavior was parsed but never exposed.
  local fan_and_light_switch = {
    profile = "fans-fan-light-switch",
    tuya.dp_on_off(1, { name = "switch", component = "main", emit = emit.switch() }),
    tuya.dp_fan_mode(101, { component = "main", emit = emit.fan_mode(), converter = three_speed_fan_mode }),
    tuya.dp_power_on_behavior(11, { emit = emit.fanLightHmqzPowerOnBehavior() }),
    tuya.dp_on_off(5, { name = "switch", component = "light", emit = emit.switch() }),
  }

  -- Z2M TS0601_fan_switch (tuya.ts:15287) exposes fan_speed as a 1..5 numeric
  -- backed by enum wire values 0..4, a 0..43200 s max-on countdown and an
  -- off/on power-on behavior.  The shared three-step fan mode collapsed five
  -- speeds into low/medium/high and hid both settings.
  local fan_switch_r32_speed = converter.from_to(
    function(value)
      local n = tonumber(value)
      if n == nil then return nil end
      return n + 1
    end,
    function(value)
      local n = tonumber(value)
      if n == nil then return nil end
      if n < 1 then n = 1 end
      if n > 5 then n = 5 end
      return n - 1
    end
  )

  local fan_switch_5_speed = {
    profile = "fans-switch-fan-speed-r32ctezx",
    tuya.dp_on_off(1, { name = "switch", component = "main", emit = emit.switch() }),
    tuya.dp_countdown(2, { name = "countdown", emit = emit.fanSwitchR32Countdown() }),
    tuya.dp_enum(3, {
      name = "fan_speed",
      emit = emit.fanSwitchR32FanSpeed(),
      converter = fan_switch_r32_speed,
    }),
    tuya.dp_power_on_behavior(11, { emit = emit.fanSwitchR32PowerOnBehavior() }),
  }

  register_device_definition(fan_switch_5_speed, device_helpers.create_fingerprints("TS0601", {
    "_TZE200_r32ctezx",
    "_TZE204_r32ctezx",
    "_TZE28C1000000_z5jz7wpo",
  }))

  register_device_definition(fan_and_light_switch, device_helpers.create_fingerprints("TS0601", {
    "_TZE200_hmqzfqml",
    "_TZE200_qanl25yu",
  }))

  register_device_definition(fan_and_light_switch, {
    device_helpers.create_fingerprint("Liwokit", "Fan+Light-01"),
    device_helpers.create_fingerprint("Lerlink", "T2-Z67/T2-W67"),
  })

  -- Z2M TS0601_fan_5_levels_and_light_switch (tuya.ts:15406) exposes fan_speed
  -- as a 1..5 numeric on DP3 rather than a three-step mode, so this family gets
  -- its own profile and speed capability instead of sharing the fan-mode one.
  local fan_5_levels_and_light_switch = {
    profile = "fans-fan-speed-light-switch-lawxy9e2",
    tuya.dp_on_off(1, { name = "switch", component = "main", emit = emit.switch() }),
    tuya.dp_enum(3, {
      name = "fan_speed",
      emit = emit.fanLightLawxFanSpeed(),
      converter = fan_switch_r32_speed,
    }),
    tuya.dp_power_on_behavior(11, { emit = emit.fanLightHmqzPowerOnBehavior() }),
    tuya.dp_on_off(5, { name = "switch", component = "light", emit = emit.switch() }),
  }

  register_device_definition(fan_5_levels_and_light_switch, device_helpers.create_fingerprints("TS0601", {
    "_TZE200_lawxy9e2",
    "_TZE204_lawxy9e2",
  }))

  -- Z2M TS0601_fan_dimmer_and_light_switch (tuya.ts:15363): DP1 fan state,
  -- DP4 fan speed percent, DP5 light switch, DP11 power-on behavior
  -- off/on/previous, DP12 indicator off / off-on / on, DP13 backlight,
  -- DP104 child lock and DP105 minimum speed percent.  Only the fan level and
  -- both switches were exposed before.
  local fan_dimmer_and_light_switch = {
    profile = "fans-fan-level-light-switch",
    tuya.dp_on_off(1, { name = "switch", component = "main", emit = emit.switch() }),
    tuya.dp_numeric(4, { name = "brightness", component = "main", emit = emit.level(), converter = percentage_level }),
    tuya.dp_on_off(5, { name = "switch", component = "light", emit = emit.switch() }),
    tuya.dp_power_on_behavior(11, { emit = emit.fanDimmerBqlPowerOnBehavior() }),
    tuya.dp_indicator_mode(12, {
      name = "indicator_mode",
      emit = emit.fanDimmerBqlIndicator(),
      -- Z2M maps only three values here, so the shared four-value indicator
      -- converter would send an out-of-range enum.
      converter = converter.lookup_from_to({
        off = 0,
        off_on = 1,
        on = 2,
      }),
    }),
    tuya.dp_on_off(13, {
      name = "backlight",
      emit = emit.fanDimmerBqlBacklight(),
      converter = converter.lookup_from_to({ off = false, on = true }),
    }),
    tuya.dp_child_lock(104, {
      name = "child_lock",
      emit = emit.fanDimmerBqlChildLock(),
      converter = converter.lookup_from_to({ off = false, on = true }),
    }),
    tuya.dp_numeric(105, {
      name = "minimum_speed",
      emit = emit.fanDimmerBqlMinimumSpeed(),
      converter = percentage_level,
    }),
  }

  register_device_definition(fan_dimmer_and_light_switch, device_helpers.create_fingerprints("TS0601", {
    "_TZE204_bql5khqx",
    "_TZE204_2jnoy8dj",
  }))

  register_device_definition(fan_dimmer_and_light_switch, {
    device_helpers.create_fingerprint("Coswall", "X99-G-kbFan-1g-ZG-LN-11"),
    device_helpers.create_fingerprint("Zemismart", "ZN2S-RS1E-FL / ZN2S-US1U-FL"),
  })

  local fan_5_levels_and_light_5_levels = {
    profile = "fans-fan-level-light-dimmer",
    tuya.dp_on_off(1, { name = "switch", component = "main", emit = emit.switch() }),
    tuya.dp_numeric(6, { name = "brightness", component = "main", emit = emit.level(), converter = stepped_level }),
    tuya.dp_on_off(104, { name = "switch", component = "light", emit = emit.switch() }),
    tuya.dp_numeric(105, { name = "brightness", component = "light", emit = emit.level(), converter = coarse_light_level }),
  }

  register_device_definition(fan_5_levels_and_light_5_levels, device_helpers.create_fingerprints("TS0601", {
    "_TZE284_ikul00sx",
  }))

  -- Z2M ceiling fan control module _TZE284_z5jz7wpo (tuya.ts:24063): DP1 state,
  -- DP2 countdown expressed in hours (device stores seconds, 0.25..12 h in 15
  -- minute steps), DP3 five speed steps, DP11 power-on behavior off/on/restore
  -- and DP12 light mode none/relay/pos.  The countdown, power-on behavior and
  -- light mode were parsed but never exposed, and the countdown helper reported
  -- raw seconds instead of hours.
  local ceiling_countdown_hours = converter.from_to(
    function(value)
      local seconds = tonumber(value)
      if seconds == nil then return nil end
      return math.floor(seconds / 3600 * 100 + 0.5) / 100
    end,
    function(value)
      local hours = tonumber(value)
      if hours == nil then return nil end
      local seconds = math.floor(hours * 3600 + 0.5)
      if seconds > 43200 then return 43200 end
      return seconds
    end
  )

  local fan_ceiling_module = {
    profile = "fans-switch-fan-mode-ceiling-z5jz7wpo",
    tuya.dp_on_off(1, { name = "switch", component = "main", emit = emit.switch() }),
    tuya.dp_countdown(2, {
      name = "countdown_hours",
      emit = emit.fanCeilingZ5jzCountdownHours(),
      converter = ceiling_countdown_hours,
    }),
    tuya.dp_fan_mode(3, { component = "main", emit = emit.fan_mode(), converter = zero_based_five_speed }),
    tuya.dp_power_on_behavior(11, { emit = emit.fanCeilingZ5jzPowerOnBehavior() }),
    tuya.dp_enum(12, {
      name = "light_mode",
      emit = emit.fanCeilingZ5jzLightMode(),
      converter = converter.lookup_from_to({ none = 0, relay = 1, pos = 2 }),
    }),
  }

  register_device_definition(fan_ceiling_module, device_helpers.create_fingerprints("TS0601", {
    "_TZE284_z5jz7wpo",
  }))

  return device_definitions end

local function load_lights()
  -- 디머/조명 디바이스 정의
  -- ZHA ts0601_dimmer.py + Z2M zigbee-herdsman-converters 기반 DP 그룹핑
  --
  -- 현재는 단일/2채널 EF00 디머/조명을 우선 지원합니다.
  -- fan/light 복합형은 이 catalog의 fan registration group에서 처리합니다.

  local capabilities = require "st.capabilities"
  local tuya = require "protocol.tuya"
  local emit = require "capabilities.events.all"
  local device_helpers = require "contracts.helpers.family"
  local ef00_helpers = require "contracts.helpers.ef00"

  local device_definitions, register_device_definition = device_helpers.definition_registry()
  local converter = tuya.converter

  local OA1ODMGA_HUE_FIELD = "oa1odmga_color_hue"
  local OA1ODMGA_SATURATION_FIELD = "oa1odmga_color_saturation"
  local OA1ODMGA_BRIGHTNESS_FIELD = "oa1odmga_color_brightness"
  local OA1ODMGA_COLOR_TEMPERATURE_RANGE = { minimum = 2000, maximum = 6536 }

  local function clamp(value, minimum, maximum)
    if value < minimum then return minimum end
    if value > maximum then return maximum end
    return value
  end

  local function round(value)
    return math.floor(value + 0.5)
  end

  local function oa1odmga_color_part(value, offset)
    if type(value) ~= "string" or #value < 12 then
      return nil
    end
    return tonumber(value:sub(offset, offset + 3), 16)
  end

  local function oa1odmga_hue_from_device(value, device)
    local degrees = oa1odmga_color_part(value, 1)
    if degrees == nil then return nil end
    local hue = clamp(degrees / 3.6, 0, 100)
    device:set_field(OA1ODMGA_HUE_FIELD, hue, { persist = false })
    return hue
  end

  local function oa1odmga_saturation_from_device(value, device)
    local raw = oa1odmga_color_part(value, 5)
    if raw == nil then return nil end
    local saturation = clamp(raw / 10, 0, 100)
    device:set_field(OA1ODMGA_SATURATION_FIELD, saturation, { persist = false })
    return saturation
  end

  local function oa1odmga_brightness_pair()
    return converter.from_to(
      function(value, device)
        local brightness = clamp((tonumber(value) or 0) * 100 / 254, 0, 100)
        device:set_field(OA1ODMGA_BRIGHTNESS_FIELD, brightness, { persist = false })
        return brightness
      end,
      function(value, device)
        local brightness = clamp(tonumber(value) or 0, 0, 100)
        device:set_field(OA1ODMGA_BRIGHTNESS_FIELD, brightness, { persist = false })
        return round(brightness * 254 / 100)
      end
    )
  end

  local function oa1odmga_color_temperature_pair()
    return converter.from_to(
      function(value)
        local mired = tonumber(value)
        if mired == nil or mired <= 0 then return nil end
        return round(1000000 / mired)
      end,
      function(value)
        local kelvin = tonumber(value)
        if kelvin == nil or kelvin <= 0 then return nil end
        return clamp(round(1000000 / kelvin), 153, 500)
      end
    )
  end

  local function oa1odmga_latest(device, field, capability_id, attribute_name, fallback)
    local value = device:get_field(field)
    if value == nil and type(device.get_latest_state) == "function" then
      value = device:get_latest_state("main", capability_id, attribute_name)
    end
    return tonumber(value) or fallback
  end

  local function oa1odmga_color_payload(device, hue, saturation)
    hue = clamp(tonumber(hue) or 0, 0, 100)
    saturation = clamp(tonumber(saturation) or 0, 0, 100)
    local brightness = clamp(oa1odmga_latest(
      device, OA1ODMGA_BRIGHTNESS_FIELD, "switchLevel", "level", 100
    ), 0, 100)

    device:set_field(OA1ODMGA_HUE_FIELD, hue, { persist = false })
    device:set_field(OA1ODMGA_SATURATION_FIELD, saturation, { persist = false })

    return string.format("%04x%04x%04x", round(hue * 3.6), round(saturation * 10), round(brightness * 10))
  end

  local function oa1odmga_color_write(device, value)
    if type(value) ~= "table" then return nil end
    local hue = value.hue
    local saturation = value.saturation
    if hue == nil or saturation == nil then return nil end
    return {
      { dp = 2, datatype = tuya.DP_TYPE_ENUM, value = 1 },
      { dp = 5, datatype = tuya.DP_TYPE_STRING, value = oa1odmga_color_payload(device, hue, saturation) },
    }
  end

  local function oa1odmga_hue_write(device, value)
    local saturation = oa1odmga_latest(
      device, OA1ODMGA_SATURATION_FIELD, "colorControl", "saturation", 100
    )
    return oa1odmga_color_write(device, { hue = value, saturation = saturation })
  end

  local function oa1odmga_saturation_write(device, value)
    local hue = oa1odmga_latest(device, OA1ODMGA_HUE_FIELD, "colorControl", "hue", 0)
    return oa1odmga_color_write(device, { hue = hue, saturation = value })
  end

  local oa1odmga_color_temperature_converter = oa1odmga_color_temperature_pair()

  local function oa1odmga_color_temperature_write(_, value)
    local encoded = oa1odmga_color_temperature_converter.to(value)
    if encoded == nil then return nil end
    return {
      { dp = 2, datatype = tuya.DP_TYPE_ENUM, value = 0 },
      { dp = 4, datatype = tuya.DP_TYPE_VALUE, value = encoded },
    }
  end

  -- Z2M issue #32498 external definition, reported fully working for
  -- _TZE284_oa1odmga: DP1 state, DP2 white/colour work mode, DP3 brightness
  -- 0..254, DP4 color temperature in mireds and DP5 12-hex-digit HSV data.
  local oa1odmga_switch = tuya.dp_on_off(1, { name = "switch", emit = emit.switch() })
  local oa1odmga_brightness = tuya.dp_numeric(3, {
    name = "brightness",
    emit = emit.level(),
    converter = oa1odmga_brightness_pair(),
  })
  local oa1odmga_color_temperature = tuya.dp_numeric(4, {
    name = "oa1odmga_color_temperature_report",
    read_only = true,
    emit = emit.color_temperature(),
    converter = converter.from_only(oa1odmga_color_temperature_converter.from),
  })
  local oa1odmga_hue = tuya.dp_string(5, {
    name = "oa1odmga_color_hue_report",
    read_only = true,
    emit = emit.color_hue(),
    converter = converter.from_only(oa1odmga_hue_from_device),
  })
  local oa1odmga_saturation = tuya.dp_string(5, {
    name = "oa1odmga_color_saturation_report",
    read_only = true,
    emit = emit.color_saturation(),
    converter = converter.from_only(oa1odmga_saturation_from_device),
  })

  local light_model_oa1odmga = {
    profile = "lights-color-temperature-color",
    color_temperature_range = OA1ODMGA_COLOR_TEMPERATURE_RANGE,
    named_mapping = {
      named_mappings = {
        switch = oa1odmga_switch,
        brightness = oa1odmga_brightness,
        color_temperature = oa1odmga_color_temperature_write,
        color = oa1odmga_color_write,
        color_hue = oa1odmga_hue_write,
        color_saturation = oa1odmga_saturation_write,
      },
    },
    datapoints = {
      oa1odmga_switch,
      tuya.dp_enum(2, { name = "oa1odmga_work_mode", read_only = true }),
      oa1odmga_brightness,
      oa1odmga_color_temperature,
      oa1odmga_hue,
      oa1odmga_saturation,
    },
    runtime_start = function(device)
      device:emit_component_event(
        { id = "main" },
        capabilities.colorTemperature.colorTemperatureRange({
          value = OA1ODMGA_COLOR_TEMPERATURE_RANGE,
          unit = "K",
        })
      )
      return true
    end,
  }

  register_device_definition(light_model_oa1odmga, device_helpers.create_fingerprints("TS0601", {
    "_TZE284_oa1odmga",
  }))




































































































































































































































































































































  -- AVATTO ZDMS16 reports all brightness fields as raw 0..254. Z2M first
  -- maps those values to its 0..1000 light scale; SmartThings uses 0..100%.
  -- Z2M scale0_254to0_1000 maps exposed 0..254 to Tuya raw 0..1000.
  -- SmartThings exposes level as 0..100, so this contract must convert the
  -- wire range directly instead of treating 254 as the Tuya raw maximum.
  local zdms16_brightness = converter.scale_pair(0, 1000, 0, 100)
  local zdms16_switch_type = converter.lookup_from_to({
    toggle = 0,
    state = 1,
    momentary = 2,
  })

  -- Z2M TS0601_dimmer_1_gang_1 contract, narrowed by exact hardware reports.
  local dimmer_model_ts0601_la2c2uo9 = {
    profile = "lights-dimmer-options-ts0601-la2c2uo9",
    tuya.dp_on_off(1, { name = "switch", emit = emit.switch() }),
    tuya.dp_brightness(2, { name = "brightness", emit = emit.level() }),
    tuya.dp_min_brightness(3, { name = "min_brightness", value_max = 1000, emit = emit.ef00Ts0601MinimumBrightness() }),
    tuya.dp_light_type(4, { name = "light_type", emit = emit.light_type() }),
    tuya.dp_countdown(6, { name = "countdown_timer", emit = emit.countdownTsOneTenHours() }),
    tuya.dp_power_on_behavior(14, { emit = emit.power_on_behavior() }),
    tuya.dp_backlight_mode(21, { name = "la2c2uo9_backlight_mode", emit = emit.la2c2uo9BacklightMode() }),
  }

  register_device_definition(dimmer_model_ts0601_la2c2uo9, device_helpers.create_fingerprints("TS0601", {
    "_TZE200_la2c2uo9",
  }))

  -- Z2M TS0601_dimmer_1_gang_1 contract for _TZE200_dfxkcots.
  -- Countdown is DP6 VALUE in seconds (0..43200); do not substitute an inferred DP.
  local dimmer_model_ts0601_dfxkcots = {
    profile = "lights-dimmer-options-ts0601-dfxkcots",
    tuya.dp_on_off(1, { name = "switch", emit = emit.switch() }),
    tuya.dp_brightness(2, { name = "brightness", emit = emit.level() }),
    tuya.dp_min_brightness(3, { name = "min_brightness", value_max = 1000, emit = emit.ef00Ts0601MinimumBrightness() }),
    tuya.dp_light_type(4, { name = "light_type", emit = emit.light_type() }),
    tuya.dp_countdown(6, { name = "countdown_timer", emit = emit.countdownTsOneTenHours() }),
    tuya.dp_power_on_behavior(14, { emit = emit.power_on_behavior() }),
  }

  register_device_definition(dimmer_model_ts0601_dfxkcots, device_helpers.create_fingerprints("TS0601", {
    "_TZE200_dfxkcots",
  }))

  -- TS0601_dimmer_1_gang_1
  local dimmer_model_ts0601_dimmer_1_gang_1 = {
    profile = "lights-dimmer-options-ts0601",
    presence_capability_ranges = {
      indicator_mode = { allowed_values = ef00_helpers.capability_values({ "off", "on" }) },
    },
    tuya.dp_on_off(1, { name = "switch", emit = emit.switch() }),
    tuya.dp_brightness(2, { name = "brightness", emit = emit.level() }),
    tuya.dp_min_brightness(3, { name = "min_brightness", value_max = 1000, emit = emit.ef00Ts0601MinimumBrightness() }),
    tuya.dp_light_type(4, { name = "light_type", emit = emit.light_type() }),
    tuya.dp_max_brightness(5, { name = "max_brightness", value_max = 1000, emit = emit.ef00Ts0601MaximumBrightness() }),
    tuya.dp_countdown(6, { name = "countdown_timer", emit = emit.countdownTsOneTenHours() }),
    tuya.dp_power_on_behavior(14, { emit = emit.power_on_behavior() }),
    tuya.dp_backlight_mode_off_on(21, { name = "indicator_mode", emit = emit.indicator_mode() }),
  }

  register_device_definition(dimmer_model_ts0601_dimmer_1_gang_1, device_helpers.create_fingerprints("TS0601", {
    "_TZE200_ip2akl4w",
    "_TZE200_1agwnems",
    "_TZE200_579lguh2",
    "_TZE200_vucankjx",
    "_TZE200_4mh6tyyo",
    "_TZE204_hlx9tnzb",
    "_TZE204_n9ctkb6j",
    "_TZE204_9qhuzgo0",
    "_TZE200_9cxuhakf",
    "_TZE200_a0syesf5",
    "_TZE200_3p5ydos3",
    "_TZE200_swaamsoy",
    "_TZE200_ojzhk75b",
    "_TZE200_w4cryh2i",
    "_TZE204_68utemio",
    "_TZE200_9i9dt8is",
    "_TZE200_ctq0k47x",
    "_TZE200_ebwgzdqq",
    "_TZE204_vevc4c6g",
    "_TZE200_0nauxa0p",
    "_TZE200_ykgar0ow",
    "_TZE284_m1cvyneb",
    "_TZE200_0hb4rdnp",
    "_TZE200_gne0e6mk",
    "_TZE200_itp8dt7f",
    "_TZE284_68utemio",
    "_TZE28C1000000_68utemio",
  }))

  register_device_definition(dimmer_model_ts0601_dimmer_1_gang_1, {
    device_helpers.create_fingerprint("Lerlink", "X706U"),
    device_helpers.create_fingerprint("Moes", "ZS-EUD_1gang"),
    device_helpers.create_fingerprint("Larkkey", "ZSTY-SM-1DMZG-EU"),
    device_helpers.create_fingerprint("Earda", "EDM-1ZAA-EU"),
    device_helpers.create_fingerprint("Earda", "EDM-1ZAB-EU"),
    device_helpers.create_fingerprint("Earda", "EDM-1ZBA-EU"),
    device_helpers.create_fingerprint("Mercator Ikuü", "SSWD01"),
    device_helpers.create_fingerprint("Moes", "ZS-USD"),
    device_helpers.create_fingerprint("Lonsonho", "EDM-1ZBB-EU"),
    device_helpers.create_fingerprint("Moes", "EDM-1ZBB-EU"),
    device_helpers.create_fingerprint("Moes", "ZS-SR-EUD-1"),
    device_helpers.create_fingerprint("Moes", "MS-105Z"),
    device_helpers.create_fingerprint("Mercator Ikuü", "SSWM-DIMZ"),
    device_helpers.create_fingerprint("Zemismart", "ZN2S-US1-SD"),
    device_helpers.create_fingerprint("Mercator Ikuü", "SSWRM-ZB"),
    device_helpers.create_fingerprint("ION Industries", "ID200W-ZIGB"),
    device_helpers.create_fingerprint("ION Industries", "90.500.090"),
    device_helpers.create_fingerprint("ION Industries", "90.500.040"),
  })

  -- Z2M AVATTO ZDMS16-1 contract (avatto.ts): DP1 state, DP2 brightness,
  -- DP3/DP5 minimum/maximum brightness, DP4 switch type, DP6 countdown and
  -- DP14 power-on behavior. All option capabilities are family-specific.
  local avatto_zdms16_1 = {
    profile = "lights-dimmer-zdms16-1",
    tuya.dp_on_off(1, { name = "switch", emit = emit.switch() }),
    tuya.dp_numeric(2, { name = "brightness", emit = emit.level(), converter = zdms16_brightness }),
    tuya.dp_numeric(3, { name = "zdms161_minimum_brightness", emit = emit.zdmsOneMinimumBrightness(), converter = zdms16_brightness }),
    tuya.dp_enum(4, { name = "zdms161_switch_type", emit = emit.zdmsOneSwitchType(), converter = zdms16_switch_type }),
    tuya.dp_numeric(5, { name = "zdms161_maximum_brightness", emit = emit.zdmsOneMaximumBrightness(), converter = zdms16_brightness }),
    tuya.dp_countdown(6, { name = "zdms161_countdown", emit = emit.zdmsOneCountdown() }),
    tuya.dp_power_on_behavior(14, { name = "zdms161_power_on_behavior", emit = emit.zdmsOnePowerOnBehavior() }),
  }

  register_device_definition(avatto_zdms16_1, device_helpers.create_fingerprints("TS0601", {
    "_TZE204_2cyb66xl",
    "_TZE204_5cuocqty",
    "_TZE204_huu3td85",
    "_TZE204_nqqylykc",
    "_TZE204_tgdnh7pw",
    "_TZE284_huu3td85",
    "_TZE284_nqqylykc",

  }))

  -- Z2M AVATTO ZDMS16-2 contract: the second channel repeats DP1..DP6 at
  -- DP7..DP12 and both channels share the DP14 power-on behavior.
  local avatto_zdms16_2 = {
    profile = "lights-dimmer-2-zdms16-2",
    tuya.dp_on_off(1, { name = "switch", component = "main", emit = emit.switch() }),
    tuya.dp_numeric(2, { name = "brightness", component = "main", emit = emit.level(), converter = zdms16_brightness }),
    tuya.dp_numeric(3, { name = "zdms162_minimum_brightness", component = "main", emit = emit.zdmsTwoMinimumBrightness(), converter = zdms16_brightness }),
    tuya.dp_enum(4, { name = "zdms162_switch_type", component = "main", emit = emit.zdmsTwoSwitchType(), converter = zdms16_switch_type }),
    tuya.dp_numeric(5, { name = "zdms162_maximum_brightness", component = "main", emit = emit.zdmsTwoMaximumBrightness(), converter = zdms16_brightness }),
    tuya.dp_countdown(6, { name = "zdms162_countdown", component = "main", emit = emit.zdmsTwoCountdown() }),
    tuya.dp_on_off(7, { name = "switch", component = "switch2", emit = emit.switch() }),
    tuya.dp_numeric(8, { name = "brightness", component = "switch2", emit = emit.level(), converter = zdms16_brightness }),
    tuya.dp_numeric(9, { name = "zdms162_minimum_brightness", component = "switch2", emit = emit.zdmsTwoMinimumBrightness(), converter = zdms16_brightness }),
    tuya.dp_enum(10, { name = "zdms162_switch_type", component = "switch2", emit = emit.zdmsTwoSwitchType(), converter = zdms16_switch_type }),
    tuya.dp_numeric(11, { name = "zdms162_maximum_brightness", component = "switch2", emit = emit.zdmsTwoMaximumBrightness(), converter = zdms16_brightness }),
    tuya.dp_countdown(12, { name = "zdms162_countdown", component = "switch2", emit = emit.zdmsTwoCountdown() }),
    tuya.dp_power_on_behavior(14, { name = "zdms162_power_on_behavior", emit = emit.zdmsTwoPowerOnBehavior() }),
  }

  register_device_definition(avatto_zdms16_2, device_helpers.create_fingerprints("TS0601", {
    "_TZE204_fjms2pi9",
    "_TZE204_jtbgusdc",
    "_TZE204_o9gyszw2",
    "_TZE284_fjms2pi9",
    "_TZE284_jtbgusdc",
    "_TZE28C1000000_jtbgusdc",
  }))

  -- Z2M TS0601_dimmer_1_gang_2 (tuya.ts:5033)
  -- Brightness is DP3 on this exact, not DP2.  DP4 light type, DP5 max
  -- brightness, DP6 countdown seconds, DP14 power-on behavior and DP21
  -- backlight mode off/normal/inverted were all parsed but never exposed.
  local dimmer_model_ts0601_dimmer_1_gang_2 = {
    profile = "lights-dimmer-whpb9yts",
    tuya.dp_on_off(1, { name = "switch", emit = emit.switch() }),
    tuya.dp_brightness(3, { name = "brightness", emit = emit.level() }),
    tuya.dp_light_type(4, { name = "light_type", emit = emit.whpb9ytsLightType() }),
    tuya.dp_max_brightness(5, {
      name = "max_brightness",
      value_max = 1000,
      emit = emit.whpb9ytsMaxBrightness(),
    }),
    tuya.dp_countdown(6, { name = "countdown", emit = emit.whpb9ytsCountdown() }),
    tuya.dp_power_on_behavior(14, { emit = emit.whpb9ytsPowerOnBehavior() }),
    tuya.dp_backlight_mode(21, { name = "backlight_mode", emit = emit.whpb9ytsBacklightMode() }),
  }

  register_device_definition(dimmer_model_ts0601_dimmer_1_gang_2, device_helpers.create_fingerprints("TS0601", {
    "_TZE200_whpb9yts",
  }))

  -- Z2M TS0601_dimmer_1_gang_3 (tuya.ts:5058)
  -- This exact keeps switch/brightness on DP141/DP142 and adds metering:
  -- DP16 backlight off/on, DP21 current /1000, DP22 power /10, DP23 voltage /10
  -- and DP101 child lock.  Z2M keeps DP143/DP144 commented out because the
  -- device does not answer them, so they stay unexposed here as well.
  local dimmer_model_ts0601_dimmer_1_gang_3 = {
    profile = "lights-dimmer-qzaing2g",
    tuya.dp_backlight_mode_off_on(16, {
      name = "backlight_mode",
      emit = emit.qzaing2gBacklightMode(),
    }),
    tuya.dp_current(21, { emit = emit.current() }),
    tuya.dp_power(22, { emit = emit.power() }),
    tuya.dp_voltage(23, { emit = emit.voltage() }),
    tuya.dp_child_lock(101, { name = "child_lock", emit = emit.qzaing2gChildLock() }),
    tuya.dp_on_off(141, { name = "switch", emit = emit.switch() }),
    tuya.dp_brightness(142, { name = "brightness", emit = emit.level() }),
  }

  register_device_definition(dimmer_model_ts0601_dimmer_1_gang_3, device_helpers.create_fingerprints("TS0601", {
    "_TZE200_qzaing2g",
  }))

  local dimmer_model_ts0601_dimmer_2_gang = {
    profile = "lights-dimmer-2",
    tuya.dp_on_off(1, { name = "switch", component = "main", emit = emit.switch() }),
    tuya.dp_brightness(2, { name = "brightness", component = "main", emit = emit.level() }),
    tuya.dp_min_brightness(3, {
      name = "min_brightness",
      component = "main",
      value_max = 1000,
      emit = emit.dimmer2gMinBrightnessCh1(),
    }),
    tuya.dp_light_type(4, {
      name = "light_type",
      component = "main",
      emit = emit.dimmer2gLightTypeCh1(),
    }),
    tuya.dp_max_brightness(5, {
      name = "max_brightness",
      component = "main",
      value_max = 1000,
      emit = emit.dimmer2gMaxBrightnessCh1(),
    }),
    tuya.dp_countdown(6, {
      name = "countdown",
      component = "main",
      emit = emit.dimmer2gCountdownCh1(),
    }),
    tuya.dp_on_off(7, { name = "switch", component = "switch2", emit = emit.switch() }),
    tuya.dp_brightness(8, { name = "brightness", component = "switch2", emit = emit.level() }),
    tuya.dp_min_brightness(9, {
      name = "min_brightness",
      component = "switch2",
      value_max = 1000,
      emit = emit.dimmer2gMinBrightnessCh2(),
    }),
    tuya.dp_light_type(10, {
      name = "light_type",
      component = "switch2",
      emit = emit.dimmer2gLightTypeCh2(),
    }),
    tuya.dp_max_brightness(11, {
      name = "max_brightness",
      component = "switch2",
      value_max = 1000,
      emit = emit.dimmer2gMaxBrightnessCh2(),
    }),
    tuya.dp_countdown(12, {
      name = "countdown",
      component = "switch2",
      emit = emit.dimmer2gCountdownCh2(),
    }),
    tuya.dp_power_on_behavior(14, { emit = emit.dimmer2gPowerOnBehavior() }),
  }

  register_device_definition(dimmer_model_ts0601_dimmer_2_gang, device_helpers.create_fingerprints("TS0601", {
    "_TZE200_bxoo2swd",
    "_TZE204_bxoo2swd",
    "_TZE200_tsxpl0d0",
    "_TZE200_fjjbhx9d",
    "_TZE200_e3oitdyu",
    "_TZE200_gwkapsoq",
    "_TZE204_zenj4lxv",
  }))

  register_device_definition(dimmer_model_ts0601_dimmer_2_gang, device_helpers.create_fingerprints("TS110E", {
    "_TZE200_ubgdwsnr",
  }))

  register_device_definition(dimmer_model_ts0601_dimmer_2_gang, {
    device_helpers.create_fingerprint("Moes", "ZM-105B-M"),
    device_helpers.create_fingerprint("KnockautX", "FMD2C018"),
    device_helpers.create_fingerprint("Moes", "ZS-EUD_2gang"),
    device_helpers.create_fingerprint("Moes", "MS-105B"),
    device_helpers.create_fingerprint("Moes", "ZS-SR-EUD-2"),
  })

  -- TS0601_dimmer_3
  local dimmer_model_ts0601_dimmer_3_gang = {
    profile = "lights-dimmer-3",
    tuya.dp_on_off(1, { name = "switch", component = "main", emit = emit.switch() }),
    tuya.dp_brightness(2, { name = "brightness", component = "main", emit = emit.level() }),
    tuya.dp_min_brightness(3, {
      name = "min_brightness",
      component = "main",
      value_max = 1000,
      emit = emit.dimmer3gMinBrightnessCh1(),
    }),
    tuya.dp_light_type(4, {
      name = "light_type",
      component = "main",
      emit = emit.dimmer3gLightTypeCh1(),
    }),
    tuya.dp_max_brightness(5, {
      name = "max_brightness",
      component = "main",
      value_max = 1000,
      emit = emit.dimmer3gMaxBrightnessCh1(),
    }),
    tuya.dp_countdown(6, {
      name = "countdown",
      component = "main",
      emit = emit.dimmer3gCountdownCh1(),
    }),
    tuya.dp_on_off(7, { name = "switch", component = "switch2", emit = emit.switch() }),
    tuya.dp_brightness(8, { name = "brightness", component = "switch2", emit = emit.level() }),
    tuya.dp_min_brightness(9, {
      name = "min_brightness",
      component = "switch2",
      value_max = 1000,
      emit = emit.dimmer3gMinBrightnessCh2(),
    }),
    tuya.dp_light_type(10, {
      name = "light_type",
      component = "switch2",
      emit = emit.dimmer3gLightTypeCh2(),
    }),
    tuya.dp_max_brightness(11, {
      name = "max_brightness",
      component = "switch2",
      value_max = 1000,
      emit = emit.dimmer3gMaxBrightnessCh2(),
    }),
    tuya.dp_countdown(12, {
      name = "countdown",
      component = "switch2",
      emit = emit.dimmer3gCountdownCh2(),
    }),
    tuya.dp_power_on_behavior(14, { emit = emit.dimmer3gPowerOnBehavior() }),
    tuya.dp_on_off(15, { name = "switch", component = "switch3", emit = emit.switch() }),
    tuya.dp_brightness(16, { name = "brightness", component = "switch3", emit = emit.level() }),
    tuya.dp_min_brightness(17, {
      name = "min_brightness",
      component = "switch3",
      value_max = 1000,
      emit = emit.dimmer3gMinBrightnessCh3(),
    }),
    tuya.dp_light_type(18, {
      name = "light_type",
      component = "switch3",
      emit = emit.dimmer3gLightTypeCh3(),
    }),
    tuya.dp_max_brightness(19, {
      name = "max_brightness",
      component = "switch3",
      value_max = 1000,
      emit = emit.dimmer3gMaxBrightnessCh3(),
    }),
    tuya.dp_countdown(20, {
      name = "countdown",
      component = "switch3",
      emit = emit.dimmer3gCountdownCh3(),
    }),
    tuya.dp_backlight_mode(21, {
      name = "backlight_mode",
      emit = emit.dimmer3gBacklightMode(),
    }),
    tuya.dp_enum(101, {
      name = "backlight_color",
      emit = emit.dimmer3gBacklightColor(),
      converter = converter.lookup_from_to({
        red = 0,
        blue = 1,
        green = 2,
        white = 3,
        yellow = 4,
        magenta = 5,
        cyan = 6,
        warm_white = 7,
      }),
    }),
    tuya.dp_numeric(103, {
      name = "backlight_brightness",
      emit = emit.dimmer3gBacklightBrightness(),
    }),
  }

  register_device_definition(dimmer_model_ts0601_dimmer_3_gang, device_helpers.create_fingerprints("TS0601", {
    "_TZE200_vm1gyrso",
    "_TZE204_1v1dxkck",
    "_TZE204_znvwzxkq",
    "_TZE284_znvwzxkq",
    "_TZE200_vizxbhco",
  }))

  register_device_definition(dimmer_model_ts0601_dimmer_3_gang, {
    device_helpers.create_fingerprint("Moes", "ZS-EUD_3gang"),
    device_helpers.create_fingerprint("Moes", "ZS-SR-EUD-3"),
    device_helpers.create_fingerprint("Zemismart", "ZN2S-RS3E-DH"),
  })

  -- Z2M TS0601_dimmer_5 (tuya.ts:5280)
  -- DP1 state, DP2 brightness, DP3/DP5 min/max brightness, DP4 light type,
  -- DP6 countdown, DP14 power-on behavior off/on/previous and DP57 switch type
  -- toggle/state/momentary.  Everything except state and brightness was hidden.
  local dimmer_model_ts0601_dimmer_1_gang_switch_type = {
    profile = "lights-dimmer-dcnsggvz",
    tuya.dp_on_off(1, { name = "switch", emit = emit.switch() }),
    tuya.dp_brightness(2, { name = "brightness", emit = emit.level() }),
    tuya.dp_min_brightness(3, {
      name = "min_brightness",
      value_max = 1000,
      emit = emit.dcnsggvzMinBrightness(),
    }),
    tuya.dp_light_type(4, { name = "light_type", emit = emit.dcnsggvzLightType() }),
    tuya.dp_max_brightness(5, {
      name = "max_brightness",
      value_max = 1000,
      emit = emit.dcnsggvzMaxBrightness(),
    }),
    tuya.dp_countdown(6, { name = "countdown", emit = emit.dcnsggvzCountdown() }),
    tuya.dp_power_on_behavior(14, { emit = emit.dcnsggvzPowerOnBehavior() }),
    tuya.dp_switch_type(57, { emit = emit.dcnsggvzSwitchType() }),
  }

  register_device_definition(dimmer_model_ts0601_dimmer_1_gang_switch_type, device_helpers.create_fingerprints("TS0601", {
    "_TZE204_dcnsggvz",
    "_TZE200_dcnsggv",
    "_TZE200_dcnsggvz",
  }))

  -- Z2M TS0601_dimmer_knob (tuya.ts:5332)
  -- DP1 state, DP2 brightness, DP3 min brightness, DP4 light type and DP21
  -- indicator mode none/relay/pos.  This exact has no max brightness DP.
  local dimmer_model_ts0601_dimmer_knob = {
    profile = "lights-dimmer-knob-p0gzbqct",
    tuya.dp_on_off(1, { name = "switch", emit = emit.switch() }),
    tuya.dp_brightness(2, { name = "brightness", emit = emit.level() }),
    tuya.dp_min_brightness(3, {
      name = "min_brightness",
      value_max = 1000,
      emit = emit.p0gzbqctMinBrightness(),
    }),
    tuya.dp_light_type(4, { name = "light_type", emit = emit.p0gzbqctLightType() }),
    tuya.dp_indicator_mode_none_relay_pos(21, {
      name = "indicator_mode",
      emit = emit.p0gzbqctIndicatorMode(),
    }),
  }

  register_device_definition(dimmer_model_ts0601_dimmer_knob, device_helpers.create_fingerprints("TS0601", {
    "_TZE200_p0gzbqct",
  }))

  -- TS0601_knob_dimmer_switch: dimmer knob with two light channels
  local dimmer_model_ts0601_knob_dimmer_switch = {
    profile = "lights-color-temperature",
    tuya.dp_on_off(102, { name = "switch", emit = emit.switch() }),
    tuya.dp_brightness(103, { name = "brightness", emit = emit.level(), scale = 1000 }),
    tuya.dp_color_temperature(107, { name = "color_temperature", emit = emit.color_temperature(), scale = 1000 }),
    tuya.dp_enum(105, { name = "adjustment_mode" }),                       -- profile 미포함
    tuya.dp_power_on_behavior(106, {}),                                    -- profile 미포함
    tuya.dp_enum(111, { name = "action_1" }),                              -- profile 미포함
    tuya.dp_enum(112, { name = "action_2" }),                              -- profile 미포함
    tuya.dp_on_off(121, { name = "state_l1" }),                            -- profile 미포함
    tuya.dp_on_off(122, { name = "state_l2" }),                            -- profile 미포함
    tuya.dp_switch_mode(131, { name = "switch_mode_l1" }),                 -- profile 미포함
    tuya.dp_switch_mode(132, { name = "switch_mode_l2" }),                 -- profile 미포함
    tuya.dp_enum(141, { name = "mode" }),                                  -- profile 미포함
  }

  register_device_definition(dimmer_model_ts0601_knob_dimmer_switch, device_helpers.create_fingerprints("TS0601", {
    "_TZE200_tgeqdjgk",
    "_TZE284_tgeqdjgk",
  }))

  -- Z2M TS0601_light (tuya.ts:17750)
  -- DP1 state, DP2 power-on behavior and DP3 brightness scale 0..1000.
  local light_model_ts0601_light = {
    profile = "lights-dimmer-ts0601-light",
    tuya.dp_on_off(1, { name = "switch", emit = emit.switch() }),
    tuya.dp_power_on_behavior(2, { emit = emit.ts0601LightPowerOnBehavior() }),
    tuya.dp_brightness(3, { name = "brightness", emit = emit.level() }),
  }

  register_device_definition(light_model_ts0601_light, device_helpers.create_fingerprints("TS0601", {
    "_TZE200_86nbew0j",
    "_TZE200_io0zdqh1",
    "_TZE200_drs6j6m5",
    "_TZE204_drs6j6m5",
    "_TZE200_ywe90lt0",
    "_TZE200_qyss8gjy",
  }))
























  return device_definitions
end

local registrations = {}

local function append_registrations(source)
  for _, registration in ipairs(source) do
    registrations[#registrations + 1] = registration
  end
end

append_registrations(load_fans())
append_registrations(load_lights())

return {
  id = "ef00.lights",
  registrations = registrations,
}
