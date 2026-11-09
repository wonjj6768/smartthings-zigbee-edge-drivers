local zcl = require "protocol.zcl"
local device_helpers = require "contracts.helpers.family"
local fp = device_helpers.create_fingerprint
local capabilities = require "st.capabilities"
local emit = require "capabilities.events.all"
local data_types = require "st.zigbee.data_types"
local Reader = require("st.buf").Reader

local device_definitions, register = device_helpers.definition_registry()

local LUMI_BASIC_CLUSTER = 0x0000
local LUMI_BASIC_ATTR = 0xFF01

local function battery_percent_from_voltage(voltage_mv)
  local percent = ((voltage_mv - 2850) * 100) / 150
  if percent < 0 then
    return 0
  elseif percent > 100 then
    return 100
  end
  return math.floor(percent + 0.5)
end

local function lumi_table_value(source, key)
  if type(source) ~= "table" then
    return nil
  end
  if source[key] ~= nil then return source[key] end
  return source[tostring(key)]
end

local function lumi_tlv(fields)
  if type(fields) ~= "string" then return fields end
  local decoded, offset = {}, 1
  while offset + 1 <= #fields do
    local key, kind = fields:byte(offset, offset + 1)
    local datatype = data_types.get_data_type_by_id(kind)
    if not datatype then break end
    local reader = Reader(fields:sub(offset + 2))
    local ok, value = pcall(datatype.deserialize, reader)
    if not ok then break end
    if kind == 0x39 or kind == 0x3A then
      decoded[key] = string.unpack(kind == 0x39 and "<f" or "<d", value:_serialize())
    else
      decoded[key] = value.value
    end
    if decoded[key] == nil then decoded[key] = value end
    offset = offset + 2 + reader:tell()
  end
  return decoded
end

local function lumi_temperature(value)
  if type(value) == "number" and value > -65 and value < 65 then return value end
end

local function lumi_basic_events(_, value)
  local data = value
  if type(data) == "table" and data.value ~= nil then
    data = data.value
  end
  if type(data) == "table" and data[65281] ~= nil then
    data = data[65281]
  elseif type(data) == "table" and data["65281"] ~= nil then
    data = data["65281"]
  end
  data = lumi_tlv(data)
  if type(data) ~= "table" then
    return nil
  end

  local events = {}
  local voltage_mv = lumi_table_value(data, 1)
  local temperature = lumi_table_value(data, 100)
  local humidity = lumi_table_value(data, 101)
  local pressure = lumi_table_value(data, 102)

  if type(voltage_mv) == "number" then
    events[#events + 1] = capabilities.battery.battery(battery_percent_from_voltage(voltage_mv))
    events[#events + 1] = capabilities.voltageMeasurement.voltage({ value = voltage_mv / 1000, unit = "V" })
  end
  if type(temperature) == "number" then
    local celsius = temperature / 100
    if celsius > -65 and celsius < 65 then
      events[#events + 1] = capabilities.temperatureMeasurement.temperature({ value = celsius, unit = "C" })
    end
  end
  if type(humidity) == "number" then
    local percent = humidity / 100
    if percent >= 0 and percent <= 100 then
      events[#events + 1] = capabilities.relativeHumidityMeasurement.humidity(percent)
    end
  end
  if type(pressure) == "number" then
    events[#events + 1] = capabilities.atmosphericPressureMeasurement.atmosphericPressure({ value = pressure / 1000, unit = "kPa" })
  end

  return events[1] ~= nil and events or nil
end

local temp_humidity_lumi_basic = {
  profile = "sensors-temp-humidity-battery-voltage",
  reporting_capability_exclusions = { ["*"] = "Z2M WSDCGQ01LM uses Lumi Basic reports/check-in; standard reporting control support is unconfirmed." },
  zcl_clusters = {
    zcl.cluster_attribute(LUMI_BASIC_CLUSTER, LUMI_BASIC_ATTR, {
      name = "lumi_basic",
      emit = lumi_basic_events,
      read_only = true,
    }),
    zcl.temperature({from_device = lumi_temperature}),
    zcl.humidity(),
    zcl.battery(),
  },
}

local temp_humidity_pressure = {
  profile = "sensors-temp-humidity-pressure-battery-voltage",
  reporting_capability_exclusions = { ["*"] = "Z2M WSDCGQ11LM uses Lumi Basic/measurement reports; standard reporting control support is unconfirmed." },
  zcl_clusters = {
    zcl.cluster_attribute(LUMI_BASIC_CLUSTER, LUMI_BASIC_ATTR, {
      name = "lumi_basic",
      emit = lumi_basic_events,
      read_only = true,
    }),
    zcl.temperature({from_device = lumi_temperature}),
    zcl.humidity(),
    zcl.pressure(),
    zcl.cluster_attribute(0x0403, 0x0014, {
      read_only = true,
      read_on_configure = true, configure_reporting = false,
      from_device = function(value, device)
        device:set_field("pressure_scale", value ~= -128 and value or nil)
      end,
    }),
    zcl.cluster_attribute(0x0403, 0x0010, {
      read_only = true, configure_reporting = false,
      from_device = function(value, device)
        local scale = device:get_field("pressure_scale")
        if scale and value ~= -32768 then return value / (10 ^ scale) / 1000 end
      end,
      emit = emit.atmospheric_pressure(),
    }),
    zcl.battery(),
    zcl.battery_voltage(),
  },
}

local illuminance = {
  profile = "sensors-illuminance-battery-voltage-lumi-pending",
  zcl_clusters = {
    zcl.illuminance(),
    zcl.battery(),
    zcl.battery_voltage(),
  },
}

local function lumi_number(value)
  return type(value) == "table" and value.value or value
end

local function lumi_motion_timer(device, timeout)
  local previous = device:get_field("__lumi_motion_timer")
  if previous then previous:cancel() end
  device:set_field("__lumi_motion_timer", nil)
  if timeout > 0 then
    device:set_field("__lumi_motion_timer", device.thread:call_with_delay(timeout, function()
      device:set_field("__lumi_motion_timer", nil)
      device:emit_event(capabilities.motionSensor.motion.inactive())
    end, "Aqara motion reset"))
  end
end

local function lumi_motion_lux(default_interval, legacy)
  return function(device, raw)
    raw = lumi_number(raw)
    local interval = device:get_field("__lumi_detection_interval") or default_interval
    local configured = tonumber(device.preferences.occupancyTimeout)
    local timeout = legacy and (configured or 90) or ((configured and configured >= interval) and configured or interval + 2)
    lumi_motion_timer(device, timeout)
    local lux = legacy and raw or (raw > 130536 and 0 or raw - 65536)
    return {capabilities.motionSensor.motion.active(), capabilities.illuminanceMeasurement.illuminance(math.max(0, lux))}
  end
end

local function lumi_motion_diagnostics(temp_emit, interval_emit, p1, restart_emit)
  return function(device, value)
    local fields = lumi_tlv(lumi_number(value))
    if type(fields) ~= "table" then return end
    local events = {}
    local voltage = lumi_number(fields[1] or fields["1"])
    if type(voltage) == "number" then
      events[#events + 1] = capabilities.battery.battery(battery_percent_from_voltage(voltage))
      events[#events + 1] = capabilities.voltageMeasurement.voltage({value = voltage / 1000, unit = "V"})
    end
    local temperature = lumi_number(fields[3] or fields["3"])
    if temp_emit and type(temperature) == "number" then events[#events + 1] = temp_emit(device, temperature) end
    local restarts = lumi_number(fields[5] or fields["5"])
    if restart_emit and type(restarts) == "number" then events[#events + 1] = restart_emit(device, restarts - 1) end
    local interval = lumi_number(fields[105] or fields["105"])
    if p1 and type(interval) == "number" then
      device:set_field("__lumi_detection_interval", interval)
      events[#events + 1] = interval_emit(device, interval)
    end
    if p1 then
      local sensitivity = ({[1] = "low", [2] = "medium", [3] = "high"})[lumi_number(fields[106] or fields["106"])]
      if sensitivity then events[#events + 1] = emit.aqP1Sensitivity()(device, sensitivity) end
      local indicator = lumi_number(fields[107] or fields["107"])
      if indicator ~= nil then events[#events + 1] = emit.aqP1Indicator()(device, indicator == 1 and "on" or "off") end
    end
    return #events > 0 and events or nil
  end
end

local function t1_ht_heartbeat(device, value)
  local fields = lumi_tlv(lumi_number(value))
  if type(fields) ~= "table" then return end
  local events = lumi_basic_events(device, {
    [1] = lumi_number(lumi_table_value(fields, 1)),
    [100] = lumi_number(lumi_table_value(fields, 100)),
    [101] = lumi_number(lumi_table_value(fields, 101)),
  }) or {}
  local temperature = lumi_number(lumi_table_value(fields, 3))
  if type(temperature) == "number" then
    events[#events + 1] = emit.t1HtDeviceTemperature("C")(device, temperature)
  end
  local outages = lumi_number(lumi_table_value(fields, 5))
  if type(outages) == "number" then
    events[#events + 1] = emit.t1HtPowerOutageCount()(device, outages - 1)
  end
  return #events > 0 and events or nil
end

local aqara_t1_ht = {
  profile = "sensors-aqara-t1-ht",
  magic_packet = false,
  parent_refresh = function(device)
    for _, attribute in ipairs({{0x0402, 0}, {0x0405, 0}, {0x0403, 0}, {1, 0x21}, {1, 0x20}}) do
      zcl.read_attribute(device, attribute[1], attribute[2], 1)
    end
  end,
  zcl_clusters = {
    zcl.cluster_attribute(0, 0xFF01, {
      name = "t1_ht_basic_heartbeat", endpoint = 1, read_only = true,
      read_on_configure = false, emit = t1_ht_heartbeat,
    }),
    zcl.cluster_attribute(0xFCC0, 0x00F7, {
      name = "t1_ht_heartbeat", endpoint = 1, read_only = true,
      read_on_configure = false, emit = t1_ht_heartbeat,
    }),
    zcl.temperature({endpoint = 1, minimum_interval = 10, maximum_interval = 3600, reportable_change = 100}),
    zcl.humidity({endpoint = 1, minimum_interval = 10, maximum_interval = 3600, reportable_change = 100}),
    zcl.pressure({endpoint = 1, scale = 1, minimum_interval = 10, maximum_interval = 3600, reportable_change = 5,
      emit = function(_, value)
        return capabilities.atmosphericPressureMeasurement.atmosphericPressure({value = value, unit = "hPa"})
      end}),
    zcl.battery({endpoint = 1, minimum_interval = 3600, maximum_interval = 65000, reportable_change = 10,
      from_device = function(value, _, context) return context.raw_value < 255 and value or nil end}),
    zcl.battery_voltage({endpoint = 1, minimum_interval = 3600, maximum_interval = 65000, reportable_change = 10,
      from_device = function(value, _, context) return context.raw_value < 255 and value or nil end,
      emit = function(_, value)
        return {capabilities.voltageMeasurement.voltage({value = value, unit = "V"}),
          capabilities.battery.battery(battery_percent_from_voltage(value * 1000))}
      end}),
  },
}

local function lumi_occupancy(device, value)
  if lumi_number(value) ~= 1 then return end
  lumi_motion_timer(device, tonumber(device.preferences.occupancyTimeout) or 90)
  return capabilities.motionSensor.motion.active()
end

local function lumi_struct_mapping(restart_emit)
  return zcl.cluster_attribute(0, 0xFF02, {
    name = "lumi_struct_battery", read_only = true, read_on_configure = false,
    emit = function(device, value)
      local elements, events = value.elements, {}
      local voltage = elements and elements[2] and lumi_number(elements[2].data)
      if type(voltage) == "number" then
        events[#events + 1] = capabilities.battery.battery(battery_percent_from_voltage(voltage))
        events[#events + 1] = capabilities.voltageMeasurement.voltage({value = voltage / 1000, unit = "V"})
      end
      local restarts = elements and elements[5] and lumi_number(elements[5].data)
      if restart_emit and type(restarts) == "number" then events[#events + 1] = restart_emit(device, restarts - 1) end
      return #events > 0 and events or nil
    end,
  })
end

local motion = {
  profile = "safety-lumi-motion",
  zcl_clusters = {
    zcl.cluster_attribute(0x0406, 0, {
      name = "lumi_occupancy", read_only = true, read_on_configure = false,
      emit = lumi_occupancy,
    }),
    zcl.cluster_attribute(LUMI_BASIC_CLUSTER, LUMI_BASIC_ATTR, {
      name = "lumi_basic", read_only = true, read_on_configure = false,
      emit = lumi_motion_diagnostics(nil, nil, nil, emit.miMotionRestarts()),
    }),
    lumi_struct_mapping(emit.miMotionRestarts()),
  },
}

local function lumi_motion_definition(profile, temp_emit, interval_emit, interval_name, default_interval, p1, restart_emit)
  local legacy = interval_emit == nil
  local definition = {profile = profile, zcl_clusters = {
    zcl.cluster_attribute(legacy and 0x0400 or 0xFCC0, legacy and 0 or 0x0112, {
      name = "lumi_motion_light", read_only = true, read_on_configure = false,
      emit = lumi_motion_lux(default_interval, legacy),
    }),
    zcl.cluster_attribute(legacy and 0x0000 or 0xFCC0, legacy and 0xFF01 or 0x00F7, {
      name = "lumi_motion_diagnostics", read_only = true, read_on_configure = false,
      emit = lumi_motion_diagnostics(temp_emit, interval_emit, p1, restart_emit),
    }),
  }}
  if legacy then
    definition.zcl_clusters[#definition.zcl_clusters + 1] = lumi_struct_mapping(restart_emit)
    definition.zcl_clusters[#definition.zcl_clusters + 1] = zcl.cluster_attribute(0x0406, 0, {
      name = "lumi_occupancy", read_only = true, read_on_configure = false,
      emit = lumi_occupancy,
    })
  else
    local battery = zcl.battery({read_on_configure = false, read_only = true})
    battery.minimum_interval, battery.maximum_interval, battery.reportable_change = nil, nil, nil
    definition.zcl_clusters[#definition.zcl_clusters + 1] = battery
    definition.zcl_clusters[#definition.zcl_clusters + 1] = zcl.cluster_attribute(0xFCC0, 0x0102, {
      name = interval_name, mfg_code = 0x115F, read_only = true, read_on_configure = true,
      emit = interval_emit, from_device = lumi_number,
      handler = function(device, value) device:set_field("__lumi_detection_interval", value) end,
    })
    definition.zcl_clusters[#definition.zcl_clusters + 1] = zcl.cluster_attribute(0x0001, 0x0020, {
      name = "lumi_battery_voltage", read_only = true, read_on_configure = true,
      emit = function(_, value)
        local raw = lumi_number(value)
        if raw == 255 then return end
        return {capabilities.battery.battery(battery_percent_from_voltage(raw * 100)),
          capabilities.voltageMeasurement.voltage({value = raw / 10, unit = "V"})}
      end,
    })
  end
  return definition
end

local motion_aq2 = lumi_motion_definition("safety-aqara-motion-m11", emit.aqM11DeviceTemp("C"), nil, nil, nil, nil, emit.aqM11Restarts())
local motion_t1 = lumi_motion_definition("safety-aqara-motion-t1", emit.aqT1DeviceTemp("C"), emit.aqT1Interval("s"), "aq_t_one_interval", 60, nil, emit.aqT1Restarts())
local motion_e1 = lumi_motion_definition("safety-aqara-motion-e1", emit.aqE1DeviceTemp("C"), emit.aqE1Interval("s"), "aq_e_one_interval", 60, nil, emit.aqE1Restarts())
local motion_p1 = lumi_motion_definition("safety-aqara-motion-p1", emit.aqP1DeviceTemp("C"), emit.aqP1Interval("s"), "aq_p_one_interval", 30, true)
motion_p1.zcl_clusters[#motion_p1.zcl_clusters + 1] = zcl.cluster_attribute(0xFCC0, 0x010C, {
  name = "aq_p_one_sensitivity", data_type = data_types.Uint8, write_type = data_types.Uint8,
  mfg_code = 0x115F, read_on_configure = true, emit = emit.aqP1Sensitivity(),
  from_device = function(value) return ({[1] = "low", [2] = "medium", [3] = "high"})[lumi_number(value)] end,
  to_device = function(value) return ({low = 1, medium = 2, high = 3})[value] end,
})
motion_p1.zcl_clusters[#motion_p1.zcl_clusters + 1] = zcl.cluster_attribute(0xFCC0, 0x0152, {
  name = "aq_p_one_indicator", data_type = data_types.Uint8, write_type = data_types.Uint8,
  mfg_code = 0x115F, read_on_configure = true, emit = emit.aqP1Indicator(),
  from_device = function(value) return lumi_number(value) == 1 and "on" or "off" end,
  to_device = function(value) return ({on = 1, off = 0})[value] end,
})

local function lumi_on_off_contact()
  return zcl.switch("contact", {
    emit = emit.contact(),
    read_only = true,
  })
end

local old_lumi_contact = {
  profile = "safety-contact-battery-voltage",
  zcl_clusters = {
    lumi_on_off_contact(),
    zcl.cluster_attribute(LUMI_BASIC_CLUSTER, LUMI_BASIC_ATTR, {
      name = "lumi_basic",
      emit = lumi_basic_events,
      read_only = true,
    }),
  },
}

local lumi_ac01_contact = {
  profile = "safety-contact-tamper-battery-voltage",
  zcl_clusters = {
    lumi_on_off_contact(),
    zcl.tamper(),
    zcl.cluster_attribute(LUMI_BASIC_CLUSTER, LUMI_BASIC_ATTR, {
      name = "lumi_basic",
      emit = lumi_basic_events,
      read_only = true,
    }),
    zcl.battery(),
    zcl.battery_voltage(),
  },
}

-- Aqara P1 attribute settings, diagnostics and action reports.
do
  local cluster_base = require "st.zigbee.cluster_base"
  local persistent, transient = {persist = true}, {persist = false}
  local prefix = "aqara_p1:"
  local interval_event = emit.aqP1IntervalV2("s")
  local distance_event = emit.aqContactP1Distance()
  local since_event = emit.aqP1NoOccupancySince("s")
  local distances = {[1] = "10mm", [2] = "20mm", [3] = "30mm"}
  local distance_values = {["10mm"] = 1, ["20mm"] = 2, ["30mm"] = 3}

  local function finite(value)
    return type(value) == "number" and value == value and value > -math.huge and value < math.huge
  end

  local function valid_set_interval(value)
    return finite(value) and value % 1 == 0 and value >= 2 and value <= 255
  end

  local function fields(value)
    local decoded = lumi_tlv(lumi_number(value))
    return type(decoded) == "table" and decoded or {}
  end

  local function accept_interval(device, value, context)
    local typed = context and context.typed_value
    if type(typed) == "table" and (typed.ID == 0x39 or typed.ID == 0x3A) then
      -- API16 FloatABC.value treats Inf/NaN and subnormals as ordinary finite
      -- exponents. Decode its unchanged carrier bytes as IEEE754 for parity.
      value = string.unpack(typed.ID == 0x39 and "<f" or "<d", typed:_serialize())
    end
    if type(value) == "table" then value = value.value end
    if type(value) == "boolean" then value = value and 1 or 0 end
    -- ZHC tags105/258 return decoded values without expose-range filtering.
    -- Finite numeric RX has no inferred minimum, maximum or integer filter.
    if not finite(value) then return end
    device:set_field("__lumi_detection_interval", value, persistent)
    return interval_event(device, value)
  end

  local function read_setting(device, attribute, disable_default_response)
    local request = cluster_base.read_manufacturer_specific_attribute(device, 0xFCC0, attribute, 0x115F):to_endpoint(1)
    if disable_default_response then request.body.zcl_header.frame_ctrl:set_disable_default_response() end
    return device:send(request) ~= false
  end

  -- No TX TSN assignment, ACK correlation, optimistic state or write queue.
  -- A real read is submitted after each valid write; only normal attribute RX
  -- can confirm state. Missing/negative/late ACKs have no state side effects.
  local function writer(device, mapping, value)
    local attribute = mapping.attribute_id
    if attribute == 0x0102 then
      if not valid_set_interval(value) then return false end
    elseif mapping.to_device then
      value = mapping.to_device(value)
      if value == nil then return false end
    else
      if type(value) ~= "string" then return false end
      value = distance_values[value:lower()]
      if value == nil then return false end
    end
    local request = cluster_base.write_manufacturer_specific_attribute(device, 0xFCC0, attribute,
      0x115F, data_types.Uint8, value):to_endpoint(1)
    local disable_default_response = mapping.name ~= "aq_contact_p_one_distance"
    if disable_default_response then request.body.zcl_header.frame_ctrl:set_disable_default_response() end
    if not pcall(device.send, device, request) then return false end
    -- A failed read cannot fabricate a setting or block the next request.
    pcall(read_setting, device, attribute, disable_default_response)
    return true
  end

  -- Accepted numeric RX is unbounded; only the command is bounded Uint8.
  motion_p1.zcl_clusters[4] = zcl.cluster_attribute(0xFCC0, 0x0102, {
    name = "aq_p_one_interval", endpoint = 1, mfg_code = 0x115F,
    write_type = data_types.Uint8, sender = writer, suppress_optimistic_state = true,
    read_on_configure = false, emit = accept_interval,
  })
  for _, index in ipairs({6, 7}) do
    motion_p1.zcl_clusters[index].read_on_configure = false
    motion_p1.zcl_clusters[index].sender = writer
    motion_p1.zcl_clusters[index].suppress_optimistic_state = true
  end
  motion_p1.configure = function(_, device)
    for _, attribute in ipairs({0x0102, 0x010C, 0x0152}) do read_setting(device, attribute, true) end
  end
  motion_p1.parent_refresh = function(device)
    zcl.read_attribute(device, 1, 0x0020, 1)
    for _, attribute in ipairs({0x0102, 0x010C, 0x0152}) do read_setting(device, attribute, true) end
  end

  local base_diagnostics = lumi_motion_diagnostics(emit.aqP1DeviceTemp("C"), nil, false)
  motion_p1.zcl_clusters[2].emit = function(device, raw)
    local decoded = fields(raw)
    local events = base_diagnostics(device, decoded) or {}
    local interval = accept_interval(device, lumi_table_value(decoded, 105))
    if interval then events[#events + 1] = interval end
    local sensitivity = ({[1] = "low", [2] = "medium", [3] = "high"})[lumi_number(lumi_table_value(decoded, 106))]
    if sensitivity then events[#events + 1] = emit.aqP1Sensitivity()(device, sensitivity) end
    local indicator = lumi_number(lumi_table_value(decoded, 107))
    if indicator ~= nil then events[#events + 1] = emit.aqP1Indicator()(device, indicator == 1 and "on" or "off") end
    return #events > 0 and events or nil
  end

  local function since_thresholds(device)
    local text = device.preferences.aqP1NoOccupancySeconds
    if text == nil or type(text) == "string" and text:match("^%s*$") then
      device:set_field(prefix .. "since_thresholds", {}, persistent)
      return {}
    end
    if type(text) ~= "string" then return device:get_field(prefix .. "since_thresholds") or {} end
    local values = {}
    for part in (text .. ","):gmatch("(.-),") do
      local value = tonumber(part)
      if not finite(value) or value < 0 then return device:get_field(prefix .. "since_thresholds") or {} end
      values[#values + 1] = value
    end
    device:set_field(prefix .. "since_thresholds", values, persistent)
    return values
  end

  -- Node setTimeout: a nonzero reset timeout below1ms or above signed32-ms
  -- becomes1ms. A computed reset timeout exactly0 means no reset timer.
  local function node_delay(seconds)
    local milliseconds = seconds * 1000
    if milliseconds < 1 or milliseconds > 2147483647 then return 0.001 end
    return math.floor(milliseconds) / 1000
  end

  motion_p1.zcl_clusters[1].emit = function(device, raw)
    local previous = device:get_field("__lumi_motion_timer")
    if previous then
      device.thread:cancel_timer(previous)
      device:set_field("__lumi_motion_timer", nil, transient)
    end
    local timers = device:get_field(prefix .. "since_timers") or {}
    for _, timer in ipairs(timers) do device.thread:cancel_timer(timer) end
    timers = {}
    device:set_field(prefix .. "since_timers", timers, transient)
    for _, value in ipairs(since_thresholds(device)) do
      timers[#timers + 1] = device.thread:call_with_delay(node_delay(value), function()
        local event = since_event(device, value)
        event.state_change = true
        device:emit_event(event)
      end, "Aqara P1 no occupancy since")
    end
    local interval = device:get_field("__lumi_detection_interval")
    if interval == nil then interval = 30 end
    local configured = tonumber(device.preferences.occupancyTimeout)
    local timeout = configured ~= nil and configured >= interval and configured or interval + 2
    if timeout ~= 0 then
      device:set_field("__lumi_motion_timer", device.thread:call_with_delay(node_delay(timeout), function()
        device:set_field("__lumi_motion_timer", nil, transient)
        device:emit_event(capabilities.motionSensor.motion.inactive())
      end, "Aqara P1 motion reset"), transient)
    end
    local number = lumi_number(raw)
    local lux = number > 130536 and 0 or number - 65536
    return {capabilities.motionSensor.motion.active(), capabilities.illuminanceMeasurement.illuminance(math.max(0, lux))}
  end

  -- Door range is a software preference pair, applied only to subsequent RX.
  local function door_voltage(device, millivolts)
    if not finite(millivolts) then return end
    local minimum, maximum = device.preferences.aqContactP1BatteryMinMv, device.preferences.aqContactP1BatteryMaxMv
    if not finite(minimum) or not finite(maximum) or minimum >= maximum then minimum, maximum = 2850, 3000 end
    local percent = math.floor(math.max(0, math.min(100, (millivolts - minimum) * 100 / (maximum - minimum))) + 0.5)
    return {capabilities.battery.battery(percent), capabilities.voltageMeasurement.voltage({value = millivolts / 1000, unit = "V"})}
  end

  local function door_diagnostics(device, value)
    local decoded = fields(value)
    local events = door_voltage(device, lumi_number(lumi_table_value(decoded, 1))) or {}
    local distance = distances[lumi_number(lumi_table_value(decoded, 159))]
    if distance then events[#events + 1] = distance_event(device, distance) end
    local tamper = lumi_number(lumi_table_value(decoded, 320))
    if tamper == 0 then events[#events + 1] = capabilities.tamperAlert.tamper.clear()
    elseif tamper == 1 then events[#events + 1] = capabilities.tamperAlert.tamper.detected() end
    return #events > 0 and events or nil
  end

  lumi_ac01_contact.profile = "safety-aqara-contact-p1"
  lumi_ac01_contact.button_actions = {"pushed"}
  lumi_ac01_contact.reporting_capability_exclusions = {
    ["*"] = "Z2M MCCGQ13LM uses native reports and check-in; configurable reporting support is unconfirmed.",
  }
  lumi_ac01_contact.zcl_clusters[#lumi_ac01_contact.zcl_clusters + 1] = zcl.contact()
  lumi_ac01_contact.zcl_clusters[5].scale = nil
  lumi_ac01_contact.zcl_clusters[5].from_device = function(_, _, context) return context.raw_value end
  lumi_ac01_contact.zcl_clusters[5].emit = function(device, value)
    value = lumi_number(value)
    if value == 255 then return end
    return door_voltage(device, value * 100)
  end
  lumi_ac01_contact.zcl_clusters[#lumi_ac01_contact.zcl_clusters + 1] = zcl.cluster_attribute(0xFCC0, 0x00F7, {
    name = "aq_contact_p_one_heartbeat", endpoint = 1, read_only = true, read_on_configure = false,
    emit = door_diagnostics,
  })
  for _, attribute in ipairs({0x0001, 0x009F, 0xFF01, 0x0140}) do
    lumi_ac01_contact.zcl_clusters[#lumi_ac01_contact.zcl_clusters + 1] = zcl.cluster_attribute(0xFCC0, attribute, {
      name = string.format("aq_contact_p_one_native_%04x", attribute), endpoint = 1,
      read_only = true, read_on_configure = false, read_on_refresh = false,
      emit = function(device, value)
        if attribute == 0xFF01 then return door_diagnostics(device, value) end
        return door_diagnostics(device, {[attribute] = lumi_number(value)})
      end,
    })
  end
  lumi_ac01_contact.zcl_clusters[#lumi_ac01_contact.zcl_clusters + 1] = zcl.cluster_attribute(0xFCC0, 0x010C, {
    name = "aq_contact_p_one_distance", endpoint = 1, mfg_code = 0x115F, write_type = data_types.Uint8,
    sender = writer, suppress_optimistic_state = true, read_on_configure = false,
    from_device = function(value) return distances[lumi_number(value)] end, emit = distance_event,
  })
  lumi_ac01_contact.zigbee_message_handler = function(device, rx)
    local header, address = rx.body and rx.body.zcl_header, rx.address_header
    if not header or address.src_endpoint.value ~= 1 or address.cluster.value ~= 0 or
        header.cmd.value ~= 10 or header.frame_ctrl:is_cluster_specific_set() or
        not header.frame_ctrl:is_direction_set() then return end
    local sequence = header.seqno and header.seqno.value
    if sequence ~= nil then
      -- cff1de47 lumiP1Action -> hasAlreadyProcessedMessage: device/EP key,
      -- exact10000ms expiry, max5 entries; cache BEFORE checking modelId.
      local now = math.floor(require("cosock.socket").gettime() * 1000)
      local recent = device:get_field(prefix .. "action_transactions") or {}
      for _, entry in ipairs(recent) do
        if entry.sequence == sequence and entry.expires > now then return end
      end
      for index = #recent, 1, -1 do if recent[index].expires <= now then table.remove(recent, index) end end
      if #recent > 4 then
        local oldest = 1
        for index = 2, #recent do if recent[index].expires < recent[oldest].expires then oldest = index end end
        table.remove(recent, oldest)
      end
      recent[#recent + 1] = {sequence = sequence, expires = now + 10000}
      device:set_field(prefix .. "action_transactions", recent, transient)
    end
    for _, record in ipairs(rx.body.zcl_body.attr_records or {}) do
      if record.attr_id.value == 5 and record.data.value == "lumi.magnet.ac01" then
        device:emit_event(capabilities.button.button.pushed({state_change = true}))
        break
      end
    end
  end
end

local lumi_acn001_contact = {
  profile = "safety-contact-battery-low-battery-voltage",
  zcl_clusters = {
    zcl.contact(),
    zcl.battery_low(),
    zcl.battery(),
    zcl.battery_voltage(),
  },
}

local lumi_agl02_contact = {
  profile = "safety-contact-battery-voltage",
  zcl_clusters = {
    zcl.contact(),
    zcl.battery(),
    zcl.battery_voltage(),
  },
}

local water_battery_low_battery_voltage = {
  profile = "safety-water-leak-battery-low-battery-voltage",
  zcl_clusters = {
    zcl.water(),
    zcl.battery_low(),
    zcl.cluster_attribute(LUMI_BASIC_CLUSTER, LUMI_BASIC_ATTR, {
      name = "lumi_basic",
      emit = lumi_basic_events,
      read_only = true,
    }),
    zcl.battery(),
    zcl.battery_voltage(),
  },
}

local water_tamper_battery_low_battery_voltage = {
  profile = "safety-water-leak-tamper-battery-low-battery-voltage",
  zcl_clusters = {
    zcl.water(),
    zcl.tamper(),
    zcl.battery_low(),
    zcl.cluster_attribute(LUMI_BASIC_CLUSTER, LUMI_BASIC_ATTR, {
      name = "lumi_basic",
      emit = lumi_basic_events,
      read_only = true,
    }),
    zcl.battery(),
    zcl.battery_voltage(),
  },
}



register(temp_humidity_lumi_basic, {
  fp("LUMI", "lumi.sens"),
  fp("LUMI", "lumi.sensor_ht"),
})

register(temp_humidity_pressure, {
  fp("LUMI", "lumi.weather"),
})

register(aqara_t1_ht, {
  fp("LUMI", "lumi.sensor_ht.agl02"),
})

register(illuminance, {
  fp("LUMI", "lumi.sen_ill.agl01"),
  fp("LUMI", "lumi.sen_ill.mgl01"),
})

register(motion, {
  fp("LUMI", "lumi.sensor_motion"),
})

register(motion_p1, {
  fp("LUMI", "lumi.motion.ac02"),
})
register(motion_e1, {
  fp("LUMI", "lumi.motion.acn001"),
})
register(motion_t1, {
  fp("LUMI", "lumi.motion.agl02"),
})
register(motion_aq2, {
  fp("LUMI", "lumi.sensor_motion.aq2"),
})

register(lumi_ac01_contact, {
  fp("LUMI", "lumi.magnet.ac01"),
})

register(lumi_acn001_contact, {
  fp("LUMI", "lumi.magnet.acn001"),
})

register(lumi_agl02_contact, {
  fp("LUMI", "lumi.magnet.agl02"),
})

register(old_lumi_contact, {
  fp("LUMI", "lumi.sensor_magnet"),
  fp("LUMI", "lumi.sensor_magnet.aq2"),
})

register(water_battery_low_battery_voltage, {
  fp("LUMI", "lumi.flood.acn001"),
  fp("LUMI", "lumi.sensor_wleak.aq1"),
})

register(water_tamper_battery_low_battery_voltage, {
  fp("LUMI", "lumi.flood.agl02"),
})

-- ZCL REPORTING CAPABILITIES BEGIN
zcl.attach_reporting_capabilities(device_definitions, {
  {1, "sensors-temp-humidity-battery-voltage", {zr00010021auto = false, zr04020000auto = false, zr04050000auto = false}},
  {2, "sensors-temp-humidity-pressure-battery-voltage", {zr00010020auto = false, zr00010021auto = false, zr04020000auto = false, zr04030000auto = false, zr04050000auto = false}},
  {3, "rpt-lno"},
  {4, "rpt-lvz"},
  {10, "safety-aqara-contact-p1", {zr00010020auto = false, zr00010021auto = false, zr00060000auto = false, zr05000002auto = false}},
  {11, "rpt-tku"},
  {12, "rpt-tvc"},
  {13, "rpt-lhf"},
  {14, "rpt-lbp"},
  {15, "rpt-ljh"},
})
-- ZCL REPORTING CAPABILITIES END

return {
  id = "zcl.sensors.aqara_lumi",
  registrations = device_definitions,
}
