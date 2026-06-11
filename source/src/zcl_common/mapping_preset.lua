-- ZCL capability 중심 프리셋
-- 자주 쓰는 cluster/attribute 조합에 emit/converter/scale 기본값을 제공합니다.

local function load_mapping_preset(zcl)

  local emit = require "emitters"
  local data_types = require "st.zigbee.data_types"
  local zigbee_constants = require "st.zigbee.constants"

  local function merge_options(target, source)
    if type(target) ~= "table" then
      target = {}
    end

    if type(source) ~= "table" then
      return target
    end

    for key, value in pairs(source) do
      target[key] = value
    end

    return target
  end

  local function apply_defaults(target, defaults)
    if type(target) ~= "table" or type(defaults) ~= "table" then
      return target
    end

    for key, value in pairs(defaults) do
      if target[key] == nil then
        target[key] = value
      end
    end

    return target
  end

  local function optional_emit(name, ...)
    local factory = emit[name]
    if type(factory) == "function" then
      return factory(...)
    end
    return nil
  end

  local function normalize_preset_options(name_or_options, options)
    local resolved = {}

    if type(name_or_options) == "string" then
      resolved.name = name_or_options
    else
      merge_options(resolved, name_or_options)
    end

    merge_options(resolved, options)
    return resolved
  end

  local function build_lookup_pair(map, default_from, default_to, aliases)
    local reverse = {}
    for key, value in pairs(map) do
      reverse[value] = key
    end

    if type(aliases) == "table" then
      for alias, target in pairs(aliases) do
        if reverse[target] ~= nil then
          reverse[alias] = reverse[target]
        end
      end
    end

    return {
      from = function(value)
        local mapped = map[value]
        if mapped ~= nil then
          return mapped
        end

        if default_from ~= nil then
          return default_from
        end

        return value
      end,
      to = function(value)
        local mapped = reverse[value]
        if mapped ~= nil then
          return mapped
        end

        if default_to ~= nil then
          return default_to
        end

        return value
      end,
    }
  end

  local function clamp(value, min_value, max_value)
    if value < min_value then
      return min_value
    end

    if value > max_value then
      return max_value
    end

    return value
  end

  local function level_percent_pair()
    return {
      from = function(value)
        if type(value) ~= "number" then
          return value
        end

        return math.floor((clamp(value, 0, 254) * 100 / 254) + 0.5)
      end,
      to = function(value)
        if type(value) ~= "number" then
          return value
        end

        return math.floor((clamp(value, 0, 100) * 254 / 100) + 0.5)
      end,
    }
  end

  local function percent_254_pair()
    return {
      from = function(value)
        if type(value) ~= "number" then
          return value
        end

        return math.floor((clamp(value, 0, 254) * 100 / 254) + 0.5)
      end,
      to = function(value)
        if type(value) ~= "number" then
          return value
        end

        return math.floor((clamp(value, 0, 100) * 254 / 100) + 0.5)
      end,
    }
  end

  local function illuminance_measurement_pair()
    return {
      from = function(value)
        if type(value) ~= "number" then
          return value
        end

        if value <= 0 then
          return 0
        end

        local lux = math.pow(10, (value - 1) / 10000)
        return math.floor(lux + 0.5)
      end,
      to = function(value)
        if type(value) ~= "number" then
          return value
        end

        if value <= 0 then
          return 0
        end

        local raw = 10000 * (math.log(value) / math.log(10)) + 1
        return math.floor(raw + 0.5)
      end,
    }
  end

  local function thermostat_mode_pair()
    return build_lookup_pair({
      [0] = "off",
      [1] = "auto",
      [3] = "cool",
      [4] = "heat",
      [5] = "emergency heat",
    })
  end

  local function fan_mode_pair()
    return build_lookup_pair({
      [0]="off",
      [1]="low",
      [2]="medium",
      [3]="high",
      [4]="on",
      [5]="auto",
      [6]="turbo",
    })
  end

  local function indicator_mode_pair()
    return build_lookup_pair({
      [0] = "off",
      [1] = "off/on",
      [2] = "on/off",
      [3] = "on",
    }, nil, nil, {
      off_on = "off/on",
      on_off = "on/off",
      normal = "off/on",
      inverted = "on/off",
    })
  end

  local function power_on_behavior_pair()
    return build_lookup_pair({
      [0] = "off",
      [1] = "on",
      [2] = "previous",
    }, nil, nil, {
      restore = "previous",
    })
  end

  local function power_outage_memory_pair()
    return build_lookup_pair({
      [0] = "off",
      [1] = "on",
      [2] = "restore",
    }, nil, nil, {
      previous = "restore",
    })
  end

  local function switch_type_pair()
    return build_lookup_pair({
      [0] = "toggle",
      [1] = "state",
      [2] = "momentary",
    })
  end

  local function gen_on_off_switch_type_pair()
    return build_lookup_pair({
      [0] = "momentary",
      [1] = "toggle",
      [2] = "state",
    })
  end

  local function ts110e_switch_type_pair()
    return build_lookup_pair({
      [0] = "momentary",
      [1] = "toggle",
      [2] = "state",
    })
  end

  local function switch_mode_pair()
    return build_lookup_pair({
      [0] = "switch",
      [1] = "scene",
    })
  end

  local function operation_mode_pair()
    return build_lookup_pair({
      [0] = "command",
      [1] = "event",
    })
  end

  local function light_type_pair()
    return build_lookup_pair({
      [0] = "led",
      [1] = "incandescent",
      [2] = "halogen",
    })
  end

  local function on_off_pair()
    return build_lookup_pair({
      [0] = "off",
      [1] = "on",
    })
  end

  local function encode_uint16_le(value)
    local numeric = math.floor(clamp(tonumber(value) or 0, 0, 0xFFFF) + 0.5)
    return string.char(bit32.band(numeric, 0xFF)) ..
      string.char(bit32.rshift(bit32.band(numeric, 0xFF00), 8))
  end

  local function encode_uint32_le(value)
    local numeric = math.floor(clamp(tonumber(value) or 0, 0, 0xFFFFFFFF) + 0.5)
    return string.char(bit32.band(numeric, 0xFF)) ..
      string.char(bit32.rshift(bit32.band(numeric, 0xFF00), 8)) ..
      string.char(bit32.rshift(bit32.band(numeric, 0xFF0000), 16)) ..
      string.char(bit32.rshift(bit32.band(numeric, 0xFF000000), 24))
  end

  local function ts110e_brightness_limit_pair()
    return {
      from = function(value)
        if type(value) ~= "number" then
          return value
        end

        return math.floor(((clamp(value, 0, 1000) * 254) / 1000) + 1 + 0.5)
      end,
      to = function(value)
        if type(value) ~= "number" then
          return value
        end

        return math.floor((((clamp(value, 1, 255) - 1) * 1000) / 254) + 0.5)
      end,
    }
  end

  local function define_enum_attribute(cluster_id, attribute_id, defaults)
    return function(name_or_options, options)
      local resolved = normalize_preset_options(name_or_options, options)
      local converter = defaults.converter_factory()

      apply_defaults(resolved, {
        name = defaults.name,
        emit = defaults.emit,
        converter = converter,
        to_device = function(value)
          return converter.to(value)
        end,
        data_type = data_types.Enum8,
        write_type = data_types.Enum8,
        attribute_name = defaults.attribute_name,
        mfg_code = defaults.mfg_code,
        read_on_configure = true,
      })

      return zcl.cluster_attribute(cluster_id, attribute_id, resolved)
    end
  end

  local function read_latest_state(device, capability_id, attribute_name, default)
    if type(device) == "table" and type(device.get_latest_state) == "function" then
      local latest = device:get_latest_state("main", capability_id, attribute_name)
      if latest ~= nil then
        return latest
      end
    end

    return default
  end

  local function parse_threshold_entries(zb_rx)
    local body_bytes = zb_rx and zb_rx.body and zb_rx.body.zcl_body and zb_rx.body.zcl_body.body_bytes or nil
    if type(body_bytes) ~= "string" or #body_bytes < 4 then
      return nil
    end

    local entries = {}
    local index = 1
    while index + 3 <= #body_bytes do
      local key = string.byte(body_bytes, index)
      if key == nil then
        break
      end

      entries[key] = {
        state = string.byte(body_bytes, index + 1) or 0,
        value = (((string.byte(body_bytes, index + 2) or 0) * 256) + (string.byte(body_bytes, index + 3) or 0)),
      }
      index = index + 4
    end

    return entries
  end

  local function threshold_command_extractor(command_id, key, field)
    return function(zb_rx)
      local actual_command = zb_rx and zb_rx.body and zb_rx.body.zcl_header and zb_rx.body.zcl_header.cmd and zb_rx.body.zcl_header.cmd.value or nil
      if actual_command ~= command_id then
        return nil
      end

      local entries = parse_threshold_entries(zb_rx)
      local entry = type(entries) == "table" and entries[key] or nil
      if type(entry) ~= "table" then
        return nil
      end

      if field == "state" then
        return entry.state
      end

      return entry.value
    end
  end

  local function build_threshold_payload(key, state_value, threshold_value)
    local numeric = tonumber(threshold_value)
    if type(numeric) ~= "number" then
      return nil
    end

    numeric = math.floor(numeric + 0.5)
    if numeric < 0 then
      numeric = 0
    elseif numeric > 0xFFFF then
      numeric = 0xFFFF
    end

    local state = state_value == "on" and 1 or 0
    return string.char(
      key,
      state,
      bit32.band(bit32.rshift(numeric, 8), 0xFF),
      bit32.band(numeric, 0xFF)
    )
  end

  local function threshold_value_to_device(key, sibling_capability_id, sibling_attribute_name)
    return function(value, device)
      local state = read_latest_state(device, sibling_capability_id, sibling_attribute_name, "off")
      return build_threshold_payload(key, state, value)
    end
  end

  local function threshold_breaker_to_device(key, sibling_capability_id, sibling_attribute_name)
    return function(value, device)
      local threshold = read_latest_state(device, sibling_capability_id, sibling_attribute_name, 0)
      return build_threshold_payload(key, value, threshold)
    end
  end

  local function thermostat_running_state_pair()
    return {
      from = function(value)
        local numeric = value
        if type(value) == "table" then
          if type(value.is_heat_on_set) == "function" and (value:is_heat_on_set() or (type(value.is_heat_second_stage_on_set) == "function" and value:is_heat_second_stage_on_set())) then
            return "heating"
          end
          if type(value.is_cool_on_set) == "function" and (value:is_cool_on_set() or (type(value.is_cool_second_stage_on_set) == "function" and value:is_cool_second_stage_on_set())) then
            return "cooling"
          end
          if type(value.is_fan_on_set) == "function" and (
            value:is_fan_on_set() or
            (type(value.is_fan_second_stage_on_set) == "function" and value:is_fan_second_stage_on_set()) or
            (type(value.is_fan_third_stage_on_set) == "function" and value:is_fan_third_stage_on_set())
          ) then
            return "fan only"
          end
          numeric = value.value
        end

        if type(numeric) ~= "number" then
          return numeric
        end

        if bit32.band(numeric, 0x0001) ~= 0 or bit32.band(numeric, 0x0008) ~= 0 then
          return "heating"
        end
        if bit32.band(numeric, 0x0002) ~= 0 or bit32.band(numeric, 0x0010) ~= 0 then
          return "cooling"
        end
        if bit32.band(numeric, 0x0004) ~= 0 or bit32.band(numeric, 0x0020) ~= 0 or bit32.band(numeric, 0x0040) ~= 0 then
          return "fan only"
        end

        return "idle"
      end,
    }
  end

  local function color_temperature_pair()
    local conversion_constant = 1000000
    return {
      from = function(value)
        if type(value) ~= "number" or value <= 0 then
          return value
        end

        return math.floor((conversion_constant / value) + 0.5)
      end,
      to = function(value)
        if type(value) ~= "number" or value <= 0 then
          return value
        end

        return math.floor((conversion_constant / value) + 0.5)
      end,
    }
  end

  local function window_shade_state_from_position()
    return {
      from = function(value)
        if type(value) ~= "number" then
          return value
        end

        local clamped = clamp(value, 0, 100)
        if clamped <= 0 then
          return "closed"
        end
        if clamped >= 100 then
          return "open"
        end

        return "partially open"
      end,
    }
  end

  local function zone_status_pair(mask)
    return {
      from = function(value)
        if type(value) == "table" then
          if mask == 0x0001 then
            if type(value.is_alarm1_set) == "function" and value:is_alarm1_set() then
              return true
            end
            if type(value.is_alarm2_set) == "function" and value:is_alarm2_set() then
              return true
            end
          elseif mask == 0x0004 and type(value.is_tamper_set) == "function" then
            return value:is_tamper_set()
          elseif value.value ~= nil then
            value = value.value
          else
            return value
          end
        end

        if type(value) ~= "number" then
          return value
        end

        return bit32.band(value, mask) ~= 0
      end,
    }
  end

  local function extract_zone_status_from_command(zb_rx)
    local zone_status = zb_rx and zb_rx.body and zb_rx.body.zcl_body and zb_rx.body.zcl_body.zone_status or nil
    if zone_status == nil then
      return nil
    end

    return {
      raw_value = zone_status.value or zone_status,
      typed_value = zone_status,
    }
  end

  local function reporting_defaults(minimum_interval, maximum_interval, reportable_change)
    return {
      minimum_interval = minimum_interval,
      maximum_interval = maximum_interval,
      reportable_change = reportable_change,
      read_on_configure = true,
    }
  end

  local function merge_defaults(...)
    local merged = {}
    for _, defaults in ipairs({ ... }) do
      apply_defaults(merged, defaults)
    end
    return merged
  end

  local function define_preset(name, factory, defaults_builder)
    zcl[name] = function(name_or_options, options)
      local resolved = normalize_preset_options(name_or_options, options)
      apply_defaults(resolved, defaults_builder())
      return factory(resolved)
    end
  end

  define_preset("temperature", zcl.temperature_measurement, function()
    return merge_defaults(
      {
        emit = emit.temperature("C"),
        scale = 100,
      },
      reporting_defaults(30, 300, 50)
    )
  end)

  define_preset("humidity", zcl.relative_humidity, function()
    return merge_defaults(
      {
        emit = emit.humidity(),
        scale = 100,
      },
      reporting_defaults(30, 300, 100)
    )
  end)

  define_preset("battery", zcl.power_configuration_battery, function()
    return merge_defaults(
      {
        emit = emit.battery(),
        scale = 2,
      },
      reporting_defaults(300, 21600, 2)
    )
  end)

  define_preset("battery_voltage", zcl.power_configuration_battery_voltage, function()
    return merge_defaults(
      {
        emit = emit.voltage(),
        scale = 10,
      },
      reporting_defaults(300, 21600, 1)
    )
  end)

  define_preset("switch", zcl.on_off, function()
    return merge_defaults(
      {
        emit = emit.switch(),
      },
      reporting_defaults(0, 300, nil)
    )
  end)

  zcl.indicator_mode = define_enum_attribute(zcl.CLUSTER_ON_OFF, 0x8001, {
    name = "indicator_mode",
    emit = optional_emit("indicator_mode"),
    attribute_name = "tuyaBacklightMode",
    converter_factory = indicator_mode_pair,
  })

  zcl.power_on_behavior = define_enum_attribute(zcl.CLUSTER_ON_OFF, 0x8002, {
    name = "power_on_behavior",
    emit = optional_emit("power_on_behavior"),
    attribute_name = "tuyaPowerOnBehavior",
    converter_factory = power_on_behavior_pair,
  })

  zcl.power_outage_memory = define_enum_attribute(zcl.CLUSTER_ON_OFF, 0x8002, {
    name = "power_on_behavior",
    emit = optional_emit("power_on_behavior"),
    attribute_name = "moesStartUpOnOff",
    converter_factory = power_on_behavior_pair,
  })

  zcl.tuya_power_outage_memory = define_enum_attribute(zcl.CLUSTER_ON_OFF, 0x8002, {
    name = "power_outage_memory",
    emit = optional_emit("power_outage_memory"),
    attribute_name = "moesStartUpOnOff",
    converter_factory = power_outage_memory_pair,
  })

  zcl.child_lock = function(name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options)

    apply_defaults(resolved, {
      name = "child_lock",
      emit = optional_emit("childLock"),
      from_device = function(value)
        return value and "on" or "off"
      end,
      to_device = function(value)
        return value == true or value == "on" or value == "lock" or value == "LOCK"
      end,
      data_type = data_types.Boolean,
      write_type = data_types.Boolean,
      attribute_name = "tuyaChildLock",
      read_on_configure = true,
    })

    return zcl.cluster_attribute(zcl.CLUSTER_ON_OFF, 0x8000, resolved)
  end

  zcl.tuya_magic_packet = function(name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options)

    apply_defaults(resolved, {
      name = "tuya_magic_packet",
      read_only = true,
      read_on_configure = true,
    })

    return zcl.cluster_attribute(0x0000, 0xFFFE, resolved)
  end

  zcl.operation_mode = function(name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options)
    apply_defaults(resolved, {
      name = "operation_mode",
      emit = optional_emit("operation_mode"),
      converter = operation_mode_pair(),
      data_type = data_types.Enum8,
      attribute_name = "tuyaOperationMode",
      read_on_configure = true,
    })

    return zcl.cluster_attribute(zcl.CLUSTER_ON_OFF, 0x8004, resolved)
  end

  zcl.switch_mode = define_enum_attribute(0xE001, 0xD000, {
    name = "switch_mode",
    emit = optional_emit("switch_mode"),
    attribute_name = "tuyaSwitchMode",
    mfg_code = 0x1141,
    converter_factory = switch_mode_pair,
  })

  zcl.switch_type = define_enum_attribute(0xE001, 0xD030, {
    name = "switch_type",
    emit = optional_emit("switch_type"),
    attribute_name = "tuyaExternalSwitchType",
    mfg_code = 0x1141,
    converter_factory = switch_type_pair,
  })

  zcl.gen_on_off_switch_type = define_enum_attribute(zcl.CLUSTER_ON_OFF, 0x8001, {
    name = "switch_type",
    emit = optional_emit("switch_type"),
    attribute_name = "tuyaExternalSwitchType",
    mfg_code = 0x1141,
    converter_factory = gen_on_off_switch_type_pair,
  })

  zcl.countdown_timer = function(name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options)
    apply_defaults(resolved, {
      name = "countdown_timer",
      emit = optional_emit("countdownTimerZclTwelveHours", "s"),
      data_type = data_types.Uint16,
      write_type = data_types.Uint16,
      tx_command_id = 0x42,
      to_device = function(value)
        local countdown = clamp(tonumber(value) or 0, 0, 43200)
        return string.char(0x00) .. encode_uint16_le(countdown) .. encode_uint16_le(countdown)
      end,
      numeric_range = {
        minimum = 0,
        maximum = 43200,
        step = 1,
        unit = "s",
      },
      attribute_name = "onTime",
      read_on_configure = true,
    })

    return zcl.cluster_attribute(zcl.CLUSTER_ON_OFF, 0x4001, resolved)
  end

  zcl.ts110e_countdown_timer = function(name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options)
    local countdown_emit = resolved.emit or optional_emit("countdownTsOneTenHours", "s")
    apply_defaults(resolved, {
      name = "countdown_timer",
      emit = countdown_emit,
      data_type = data_types.Uint32,
      tx_command_id = 0xF0,
      to_device = function(value)
        return encode_uint32_le(clamp(tonumber(value) or 0, 0, 43200))
      end,
      numeric_range = {
        minimum = 0,
        maximum = 43200,
        step = 1,
        unit = "s",
      },
      attribute_name = "tuyaCountdown",
      read_on_configure = true,
    })

    return zcl.cluster_attribute(zcl.CLUSTER_ON_OFF, 0x4001, resolved)
  end

  local function threshold_value_mapping(name_or_options, options, defaults)
    local resolved = normalize_preset_options(name_or_options, options)
    apply_defaults(resolved, defaults)
    return zcl.cluster_attribute(0xE001, defaults.attribute_id, resolved)
  end

  local function threshold_breaker_mapping(name_or_options, options, defaults)
    local resolved = normalize_preset_options(name_or_options, options)
    apply_defaults(resolved, defaults)
    return zcl.cluster_attribute(0xE001, defaults.attribute_id, resolved)
  end

  zcl.temperature_threshold = function(name_or_options, options)
    return threshold_value_mapping(name_or_options, options, {
      name = "temperature_threshold",
      emit = optional_emit("temperature_threshold"),
      tx_command_id = 0xE6,
      command_id = 0xE6,
      command_extractor = threshold_command_extractor(0xE6, 0x05, "value"),
      to_device = threshold_value_to_device(0x05, "concertmirror08464.temperatureBreaker", "temperatureBreaker"),
      attribute_id = 0xF105,
    })
  end

  zcl.temperature_breaker = function(name_or_options, options)
    return threshold_breaker_mapping(name_or_options, options, {
      name = "temperature_breaker",
      emit = optional_emit("temperature_breaker"),
      converter = on_off_pair(),
      tx_command_id = 0xE6,
      command_id = 0xE6,
      command_extractor = threshold_command_extractor(0xE6, 0x05, "state"),
      to_device = threshold_breaker_to_device(0x05, "concertmirror08464.temperatureThreshold", "temperatureThreshold"),
      attribute_id = 0xF185,
    })
  end

  zcl.power_threshold = function(name_or_options, options)
    return threshold_value_mapping(name_or_options, options, {
      name = "power_threshold",
      emit = optional_emit("power_threshold"),
      tx_command_id = 0xE6,
      command_id = 0xE6,
      command_extractor = threshold_command_extractor(0xE6, 0x07, "value"),
      to_device = threshold_value_to_device(0x07, "concertmirror08464.powerBreaker", "powerBreaker"),
      attribute_id = 0xF107,
    })
  end

  zcl.power_breaker = function(name_or_options, options)
    return threshold_breaker_mapping(name_or_options, options, {
      name = "power_breaker",
      emit = optional_emit("power_breaker"),
      converter = on_off_pair(),
      tx_command_id = 0xE6,
      command_id = 0xE6,
      command_extractor = threshold_command_extractor(0xE6, 0x07, "state"),
      to_device = threshold_breaker_to_device(0x07, "concertmirror08464.powerThreshold", "powerThreshold"),
      attribute_id = 0xF187,
    })
  end

  zcl.over_current_threshold = function(name_or_options, options)
    return threshold_value_mapping(name_or_options, options, {
      name = "over_current_threshold",
      emit = optional_emit("over_current_threshold"),
      tx_command_id = 0xE7,
      command_id = 0xE7,
      command_extractor = threshold_command_extractor(0xE7, 0x01, "value"),
      to_device = threshold_value_to_device(0x01, "concertmirror08464.overCurrentBreaker", "overCurrentBreaker"),
      attribute_id = 0xF101,
    })
  end

  zcl.over_current_breaker = function(name_or_options, options)
    return threshold_breaker_mapping(name_or_options, options, {
      name = "over_current_breaker",
      emit = optional_emit("over_current_breaker"),
      converter = on_off_pair(),
      tx_command_id = 0xE7,
      command_id = 0xE7,
      command_extractor = threshold_command_extractor(0xE7, 0x01, "state"),
      to_device = threshold_breaker_to_device(0x01, "concertmirror08464.overCurrentThreshold", "overCurrentThreshold"),
      attribute_id = 0xF181,
    })
  end

  zcl.over_voltage_threshold = function(name_or_options, options)
    return threshold_value_mapping(name_or_options, options, {
      name = "over_voltage_threshold",
      emit = optional_emit("over_voltage_threshold"),
      tx_command_id = 0xE7,
      command_id = 0xE7,
      command_extractor = threshold_command_extractor(0xE7, 0x03, "value"),
      to_device = threshold_value_to_device(0x03, "concertmirror08464.overVoltageBreaker", "overVoltageBreaker"),
      attribute_id = 0xF103,
    })
  end

  zcl.over_voltage_breaker = function(name_or_options, options)
    return threshold_breaker_mapping(name_or_options, options, {
      name = "over_voltage_breaker",
      emit = optional_emit("over_voltage_breaker"),
      converter = on_off_pair(),
      tx_command_id = 0xE7,
      command_id = 0xE7,
      command_extractor = threshold_command_extractor(0xE7, 0x03, "state"),
      to_device = threshold_breaker_to_device(0x03, "concertmirror08464.overVoltageThreshold", "overVoltageThreshold"),
      attribute_id = 0xF183,
    })
  end

  zcl.under_voltage_threshold = function(name_or_options, options)
    return threshold_value_mapping(name_or_options, options, {
      name = "under_voltage_threshold",
      emit = optional_emit("under_voltage_threshold"),
      tx_command_id = 0xE7,
      command_id = 0xE7,
      command_extractor = threshold_command_extractor(0xE7, 0x04, "value"),
      to_device = threshold_value_to_device(0x04, "concertmirror08464.underVoltageBreaker", "underVoltageBreaker"),
      attribute_id = 0xF104,
    })
  end

  zcl.under_voltage_breaker = function(name_or_options, options)
    return threshold_breaker_mapping(name_or_options, options, {
      name = "under_voltage_breaker",
      emit = optional_emit("under_voltage_breaker"),
      converter = on_off_pair(),
      tx_command_id = 0xE7,
      command_id = 0xE7,
      command_extractor = threshold_command_extractor(0xE7, 0x04, "state"),
      to_device = threshold_breaker_to_device(0x04, "concertmirror08464.underVoltageThreshold", "underVoltageThreshold"),
      attribute_id = 0xF184,
    })
  end

  define_preset("level", zcl.level_control, function()
    return merge_defaults(
      {
        name = "brightness",
        emit = emit.level(),
        converter = level_percent_pair(),
      },
      reporting_defaults(1, 3600, 1)
    )
  end)

  zcl.tuya_dimmer_level = function(name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options)
    apply_defaults(resolved, {
      name = "brightness",
      emit = emit.level(),
      data_type = data_types.Uint16,
      write_type = data_types.Uint16,
      attribute_name = "tuyaCurrentLevel",
      from_device = function(value)
        if type(value) ~= "number" then
          return value
        end

        local clamped = clamp(value, 10, 1000)
        return math.floor((((clamped - 10) * 100) / 990) + 0.5)
      end,
      to_device = function(value)
        if type(value) ~= "number" then
          return value
        end

        local percent = clamp(value, 0, 100)
        return math.floor((10 + ((percent * 990) / 100)) + 0.5)
      end,
      read_on_configure = true,
    })

    return zcl.cluster_attribute(zcl.CLUSTER_LEVEL_CONTROL, 0xF000, resolved)
  end

  define_preset("illuminance", zcl.illuminance_measurement, function()
    return merge_defaults(
      {
        emit = emit.illuminance(),
        converter = illuminance_measurement_pair(),
      },
      reporting_defaults(30, 300, 100)
    )
  end)

  define_preset("pressure", zcl.pressure_measurement, function()
    return merge_defaults(
      {
        emit = emit.atmospheric_pressure(),
      },
      reporting_defaults(30, 300, 1)
    )
  end)

  define_preset("occupancy", zcl.occupancy_sensing, function()
    return merge_defaults(
      {
        emit = emit.occupancy(),
      },
      reporting_defaults(0, 300, nil)
    )
  end)

  define_preset("power", zcl.electrical_measurement_power, function()
    return merge_defaults(
      {
        emit = emit.power(),
        metering_kind = "power",
      },
      reporting_defaults(5, 300, 1)
    )
  end)

  define_preset("current", zcl.electrical_measurement_current, function()
    return merge_defaults(
      {
        emit = emit.current(),
        scale = 1000,
        metering_kind = "current",
      },
      reporting_defaults(5, 300, 1)
    )
  end)

  define_preset("voltage", zcl.electrical_measurement_voltage, function()
    return merge_defaults(
      {
        emit = emit.voltage(),
        metering_kind = "voltage",
      },
      reporting_defaults(5, 300, 1)
    )
  end)

  define_preset("energy", zcl.simple_metering, function()
    return {
      emit = emit.energy(),
      read_on_configure = true,
      metering_kind = "energy",
    }
  end)

  define_preset("local_temperature", zcl.thermostat_local_temperature, function()
    return merge_defaults(
      {
        emit = emit.temperature("C"),
        scale = 100,
      },
      reporting_defaults(30, 300, 50)
    )
  end)

  define_preset("heating_setpoint", zcl.thermostat_heating_setpoint, function()
    return merge_defaults(
      {
        name = "current_heating_setpoint",
        emit = emit.heating_setpoint("C"),
        scale = 100,
      },
      reporting_defaults(30, 300, 50)
    )
  end)

  define_preset("system_mode", zcl.thermostat_system_mode, function()
    return merge_defaults(
      {
        emit = emit.thermostat_mode(),
        converter = thermostat_mode_pair(),
      },
      reporting_defaults(1, 300, nil)
    )
  end)

  define_preset("cooling_setpoint", zcl.thermostat_cooling_setpoint, function()
    return merge_defaults(
      {
        name = "current_cooling_setpoint",
        emit = emit.cooling_setpoint("C"),
        scale = 100,
      },
      reporting_defaults(30, 300, 50)
    )
  end)

  define_preset("thermostat_operating_state", zcl.thermostat_running_state, function()
    return merge_defaults(
      {
        name = "thermostat_operating_state",
        emit = emit.thermostat_operating_state(),
        converter = thermostat_running_state_pair(),
      },
      reporting_defaults(1, 300, nil)
    )
  end)

  define_preset("fan_mode", zcl.fan_control_mode, function()
    return merge_defaults(
      {
        name = "fan_mode",
        emit = emit.fan_mode(),
        converter = fan_mode_pair(),
      },
      reporting_defaults(1, 300, nil)
    )
  end)

  define_preset("cover_position", zcl.window_covering_position, function()
    return merge_defaults(
      {
        emit = emit.shade_level(),
      },
      reporting_defaults(0, 600, 1)
    )
  end)

  define_preset("cover_state", zcl.window_covering_position, function()
    return {
      name = "cover_state",
      write_only = true,
    }
  end)

  define_preset("cover_tilt", zcl.window_covering_tilt, function()
    return merge_defaults(
      {
        name = "cover_tilt",
        emit = emit.shade_tilt_level(),
        tx_command_id = 0x08,
      },
      reporting_defaults(0, 600, 1)
    )
  end)

  define_preset("window_shade_state", zcl.window_covering_position, function()
    return merge_defaults(
      {
        name = "window_shade_state",
        emit = emit.shade_state(),
        converter = window_shade_state_from_position(),
      },
      reporting_defaults(0, 600, 1)
    )
  end)

  define_preset("color_temperature", zcl.color_control_temperature, function()
    return merge_defaults(
      {
        name = "color_temperature",
        emit = emit.color_temperature(),
        converter = color_temperature_pair(),
        tx_command_id = 0x0A,
      },
      reporting_defaults(1, 300, 1)
    )
  end)

  zcl.min_brightness = function(name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options)
    apply_defaults(resolved, {
      name = "min_brightness",
      emit = optional_emit("minBrightnessZclThousand"),
      data_type = data_types.Uint16,
      write_type = data_types.Uint16,
      attribute_name = "tuyaMinBrightness",
      read_on_configure = true,
    })

    return zcl.cluster_attribute(zcl.CLUSTER_LEVEL_CONTROL, 0xFC03, resolved)
  end

  zcl.max_brightness = function(name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options)
    apply_defaults(resolved, {
      name = "max_brightness",
      emit = optional_emit("maxBrightnessZclThousand"),
      data_type = data_types.Uint16,
      write_type = data_types.Uint16,
      attribute_name = "tuyaMaxBrightness",
      read_on_configure = true,
    })

    return zcl.cluster_attribute(zcl.CLUSTER_LEVEL_CONTROL, 0xFC04, resolved)
  end

  zcl.ts110e_min_brightness = function(name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options)
    apply_defaults(resolved, {
      name = "min_brightness",
      emit = optional_emit("minimumBrightnessTsOneTenMax"),
      converter = ts110e_brightness_limit_pair(),
      data_type = data_types.Uint16,
      write_type = data_types.Uint16,
      attribute_name = "tuyaMinBrightness",
      read_on_configure = true,
    })

    return zcl.cluster_attribute(zcl.CLUSTER_LEVEL_CONTROL, 0xFC03, resolved)
  end

  zcl.ts110e_max_brightness = function(name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options)
    apply_defaults(resolved, {
      name = "max_brightness",
      emit = optional_emit("maxBrightnessTsOneTenMax"),
      converter = ts110e_brightness_limit_pair(),
      data_type = data_types.Uint16,
      write_type = data_types.Uint16,
      attribute_name = "tuyaMaxBrightness",
      read_on_configure = true,
    })

    return zcl.cluster_attribute(zcl.CLUSTER_LEVEL_CONTROL, 0xFC04, resolved)
  end

  zcl.ts110e_switch_type = function(name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options)
    apply_defaults(resolved, {
      name = "switch_type",
      emit = optional_emit("switch_type"),
      converter = ts110e_switch_type_pair(),
      data_type = data_types.Enum8,
      write_type = data_types.Enum8,
      attribute_name = "tuyaSwitchType",
      read_on_configure = true,
    })

    return zcl.cluster_attribute(zcl.CLUSTER_LEVEL_CONTROL, 0xFC02, resolved)
  end

  zcl.light_type = function(name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options)
    apply_defaults(resolved, {
      name = "light_type",
      emit = optional_emit("light_type"),
      converter = light_type_pair(),
      data_type = data_types.Enum8,
      attribute_name = "tuyaLightType",
      read_on_configure = true,
    })

    return zcl.cluster_attribute(zcl.CLUSTER_LEVEL_CONTROL, 0xFC02, resolved)
  end

  define_preset("color_hue", zcl.color_control_hue, function()
    return merge_defaults(
      {
        name = "color_hue",
        emit = emit.color_hue(),
        converter = percent_254_pair(),
        tx_command_id = 0x00,
        to_device = function(value)
          local encoded = percent_254_pair().to(value)
          return { encoded, 0x00, 0x0000, 0x00, 0x00 }
        end,
      },
      reporting_defaults(1, 300, 1)
    )
  end)

  define_preset("color_saturation", zcl.color_control_saturation, function()
    return merge_defaults(
      {
        name = "color_saturation",
        emit = emit.color_saturation(),
        converter = percent_254_pair(),
        tx_command_id = 0x03,
        to_device = function(value)
          local encoded = percent_254_pair().to(value)
          return { encoded, 0x0000, 0x00, 0x00 }
        end,
      },
      reporting_defaults(1, 300, 1)
    )
  end)

  zcl.color = function(name_or_options, options)
    local resolved = normalize_preset_options(name_or_options, options)
    apply_defaults(resolved, {
      name = "color",
      cluster_id = zcl.CLUSTER_COLOR_CONTROL,
      attribute_id = zcl.ATTR_CURRENT_HUE,
      write_only = true,
      tx_command_id = 0x06,
      to_device = function(value)
        if type(value) ~= "table" then
          return value
        end

        local hue = percent_254_pair().to(value.hue)
        local saturation = percent_254_pair().to(value.saturation)
        if type(hue) ~= "number" or type(saturation) ~= "number" then
          return nil
        end

        return { hue, saturation, 0x0000, 0x00, 0x00 }
      end,
    })
    return zcl.cluster_attribute(resolved.cluster_id, resolved.attribute_id, resolved)
  end

  define_preset("contact", zcl.ias_zone, function()
    return merge_defaults(
      {
        name = "contact",
        emit = emit.contact(),
        converter = zone_status_pair(0x0001),
        ias_configure_method = zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
        command_id = 0x00,
        command_extractor = extract_zone_status_from_command,
      },
      reporting_defaults(30, 300, nil)
    )
  end)

  define_preset("water", zcl.ias_zone, function()
    return merge_defaults(
      {
        name = "water",
        emit = emit.water(),
        converter = zone_status_pair(0x0001),
        ias_configure_method = zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
        command_id = 0x00,
        command_extractor = extract_zone_status_from_command,
      },
      reporting_defaults(0, 300, nil)
    )
  end)

  define_preset("smoke", zcl.ias_zone, function()
    return merge_defaults(
      {
        name = "smoke",
        emit = emit.smoke(),
        converter = zone_status_pair(0x0001),
        ias_configure_method = zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
        command_id = 0x00,
        command_extractor = extract_zone_status_from_command,
      },
      reporting_defaults(0, 180, nil)
    )
  end)

  define_preset("gas", zcl.ias_zone, function()
    return merge_defaults(
      {
        name = "gas",
        emit = emit.gas(),
        converter = zone_status_pair(0x0001),
        ias_configure_method = zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
        command_id = 0x00,
        command_extractor = extract_zone_status_from_command,
      },
      reporting_defaults(0, 300, nil)
    )
  end)

  define_preset("carbon_monoxide", zcl.ias_zone, function()
    return merge_defaults(
      {
        name = "carbon_monoxide",
        emit = emit.carbon_monoxide(),
        converter = zone_status_pair(0x0001),
        ias_configure_method = zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
        command_id = 0x00,
        command_extractor = extract_zone_status_from_command,
      },
      reporting_defaults(0, 180, nil)
    )
  end)

  define_preset("motion", zcl.ias_zone, function()
    return merge_defaults(
      {
        name = "motion",
        emit = emit.motion(),
        converter = zone_status_pair(0x0001),
        ias_configure_method = zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
        command_id = 0x00,
        command_extractor = extract_zone_status_from_command,
      },
      reporting_defaults(30, 300, nil)
    )
  end)

  define_preset("tamper", zcl.ias_zone, function()
    return merge_defaults(
      {
        name = "tamper",
        emit = emit.tamper(),
        converter = zone_status_pair(0x0004),
        ias_configure_method = zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
        command_id = 0x00,
        command_extractor = extract_zone_status_from_command,
      },
      reporting_defaults(0, 300, nil)
    )
  end)

  define_preset("battery_low", zcl.ias_zone, function()
    return merge_defaults(
      {
        name = "battery_low",
        emit = optional_emit("battery_low"),
        converter = zone_status_pair(0x0008),
        ias_configure_method = zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
        command_id = 0x00,
        command_extractor = extract_zone_status_from_command,
      },
      reporting_defaults(0, 300, nil)
    )
  end)

  define_preset("alarm", zcl.ias_zone, function()
    return merge_defaults(
      {
        name = "alarm",
        emit = emit.alarm(),
        converter = zone_status_pair(0x0001),
        ias_configure_method = zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
        command_id = 0x00,
        command_extractor = extract_zone_status_from_command,
      },
      reporting_defaults(0, 300, nil)
    )
  end)

end

return load_mapping_preset
