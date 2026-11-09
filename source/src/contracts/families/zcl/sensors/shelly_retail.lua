local zcl = require "protocol.zcl"
local device_helpers = require "contracts.helpers.family"
local zcl_device_helpers = require "contracts.helpers.zcl"
local emit = require "capabilities.events.all"
local data_types = require "st.zigbee.data_types"
local device_management = require "st.zigbee.device_management"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local function bind_metered_endpoints(endpoint_count, include_level)
  return function(driver, device)
    for endpoint = 1, endpoint_count do
      local cluster_ids = {
        zcl.CLUSTER_ON_OFF,
        zcl.CLUSTER_ELECTRICAL_MEASUREMENT,
        zcl.CLUSTER_SIMPLE_METERING,
      }
      if include_level then table.insert(cluster_ids, 2, zcl.CLUSTER_LEVEL_CONTROL) end
      for _, cluster_id in ipairs(cluster_ids) do
        device:send(device_management.build_bind_request(
          device,
          cluster_id,
          driver.environment_info.hub_zigbee_eui,
          endpoint
        ))
      end
    end
  end
end

local metered_plug = {
  profile = "plugs-switch-power-energy-voltage-current",
  zcl_clusters = zcl_device_helpers.metering_clusters({
    include_switch = true,
    include_current = true,
    use_reported_unity_scaler = true,
  }),
  configure = bind_metered_endpoints(1, false),
}

local power_strip = {
  profile = "plugs-shelly-power-strip-4",
  zcl_clusters = {},
  configure = bind_metered_endpoints(4, false),
}
for endpoint = 1, 4 do
  local component = endpoint == 1 and "main" or ("switch" .. endpoint)
  for _, cluster in ipairs({
    zcl.switch({ endpoint = endpoint, component = component }),
    zcl.power({ endpoint = endpoint, component = component }),
    zcl.energy({ endpoint = endpoint, component = component }),
    zcl.voltage({ endpoint = endpoint, component = component }),
    zcl.current({ endpoint = endpoint, component = component }),
  }) do
    power_strip.zcl_clusters[#power_strip.zcl_clusters + 1] = cluster
  end
end

local dimmer_light = {
  profile = "lights-dimmer-power-voltage-current",
  zcl_clusters = {
    zcl.switch(),
    zcl.level(),
    zcl.power(),
    zcl.voltage(),
    zcl.current(),
    zcl.energy(),
  },
  configure = bind_metered_endpoints(1, true),
}

local water_sensor = {
  profile = "safety-water-leak-tamper-battery-low-battery-hardware-fault-shelly",
  zcl_clusters = {
    zcl.water(),
    zcl.tamper(),
    zcl.battery_low(),
    zcl.hardware_fault(),
    zcl.battery(),
  },
}

local function battery_uint8_value(value, _, context)
  if context.raw_value ~= 0xFF then return value end
end

local temp_humidity = {
  profile = "sensors-temp-humidity-battery-shelly-ht",
  capability_commands = {
    {capability_id="concertmirror08464.shellyHtIdentify", command_name="identify",
      mapping_name="shelly_ht_identify", value=3},
    {capability_id="concertmirror08464.shellyHtIdentify", command_name="setIdentifyTime",
      argument_name="identifyTime", mapping_name="shelly_ht_identify"},
  },
  protocol_writers = {
    shelly_ht_identify = zcl_device_helpers.identify,
  },
  zcl_clusters = {
    zcl.temperature({minimum_interval=10, maximum_interval=3600, reportable_change=100}),
    zcl.humidity({minimum_interval=10, maximum_interval=3600, reportable_change=100,
      from_device=function(value, _, context)
        if context.raw_value ~= 0xFFFF then return value end
      end}),
    zcl.battery({minimum_interval=3600, maximum_interval=65000, reportable_change=10,
      from_device=battery_uint8_value}),
  },
}

local function ws90_zero_value_allowed(device, raw, capability, attribute, limit, absolute)
  if raw ~= 0 then return true end
  if capability == nil then return false end
  local previous = device:get_latest_state("main", capability, attribute)
  return not (type(previous) == "number" and (absolute and math.abs(previous) or previous) > limit)
end

local function ws90_zero_filter(mapping, capability, attribute, limit, absolute)
  local convert = zcl.mapping_meta(mapping, false).from_device
  mapping.from_device = function(value, device, context, definition)
    if not ws90_zero_value_allowed(device, context.raw_value, capability, attribute, limit, absolute) then return nil end
    if convert then return convert(value, device, context, definition) end
    return value
  end
  return mapping
end

local function ws90_zero_rain_frame(device, context)
  local message = context.zb_rx
  local body = message and message.body and message.body.zcl_body
  local precipitation
  for _, record in ipairs(body and body.attr_records or {}) do
    if record.attr_id.value == 1 and (not record.status or record.status.value == 0) and
        record.data_type and record.data_type.value == 0x22 and record.data then
      precipitation = record.data.value
    end
  end
  local previous = device:get_latest_state("main", "concertmirror08464.shellyWs90Precipitation", "precipitation")
  return precipitation == 0 and type(previous) == "number" and previous > 0, precipitation
end

-- WS90 CALCULATED PURE START
local function ws90_round(value)
  if value == 0 then return value end
  local lower = math.floor(value)
  local result = value - lower < 0.5 and lower or lower + 1
  return result == 0 and value < 0 and -0.0 or result
end

local function ws90_dew_point(temperature, humidity)
  if temperature == nil or humidity == nil or humidity <= 0 then return nil end
  local alpha = 17.27 * temperature / (237.7 + temperature) + math.log(humidity / 100)
  return ws90_round(237.7 * alpha / (17.27 - alpha) * 10) / 10
end

local function ws90_humidex(temperature, dew_point)
  if dew_point == nil then return nil end
  local pressure = 6.11 * math.exp(5417.753 * (1 / 273.15 - 1 / (273.15 + dew_point)))
  return ws90_round((temperature + 0.5555 * (pressure - 10)) * 10) / 10
end

local function ws90_wind_chill(temperature, wind)
  if temperature == nil or wind == nil then return nil end
  local speed = wind * 3.6
  if temperature > 10 or speed < 4.8 then return ws90_round(temperature * 10) / 10 end
  return ws90_round((13.12 + 0.6215 * temperature - 11.37 * speed ^ 0.16 + 0.3965 * temperature * speed ^ 0.16) * 10) / 10
end

local function ws90_heat_stress(state)
  local base = state.temperature + (state.illuminance or 0) / 100 / 100 + (state.humidity or 0) / 10
  local adjusted = base - (state.wind_speed or 0) / 2 - ((state.precipitation or 0) > 0 and 3 or 0)
  return math.max(ws90_round(100 / (1 + math.exp(1) ^ (-4 * ((adjusted - 18) / 24 - 0.5)))), 0)
end

local function ws90_apparent_temperature(temperature, wind_chill, humidex)
  if temperature == nil then return nil end
  if wind_chill ~= nil and wind_chill < temperature then return wind_chill end
  if humidex ~= nil and humidex > temperature then return humidex end
  return ws90_round(temperature * 10) / 10
end

local function ws90_rain_rate(meta, precipitation, now)
  if precipitation == nil then return nil end
  local history = meta.precipHistory
  if history and now - history.time < 60000 then return nil end
  meta.precipHistory = {value=precipitation, time=now}
  if not history then return 0 end
  local elapsed, change = now - history.time, precipitation - history.value
  if change < 0 then return 0 end
  return math.min(ws90_round(change / (elapsed / 3600000) * 10) / 10, 300)
end

local function ws90_pressure_trend(meta, pressure, now)
  local history = meta.pressureHistory
  if history and now - history.time < 1800000 then return nil end
  meta.pressureHistory = {value=pressure, time=now}
  if not history then return 0 end
  return ws90_round((pressure - history.value) / ((now - history.time) / 3600000) * 10) / 10
end

local function ws90_weather_condition(state)
  local temperature, lux, wind, rate, pressure, trend = state.temperature, state.illuminance,
    state.wind_speed, state.rain_rate, state.pressure, state.pressure_trend
  if lux == nil then return nil end
  local raining = state.rain_status == true and rate and rate > 0
  local windy = wind and wind > 10
  local hail = raining and rate > 5 and lux < 5000 and wind and wind > 5 and
    ((pressure and pressure < 1000) or (trend and trend < -2))
  if hail then return "hail" end
  if raining and temperature and temperature < 1 then return "snowy" end
  if raining and rate > 10 then return "pouring" end
  if raining then return "rainy" end
  if lux < 10 then return windy and "windy" or "clear-night" end
  if lux > 40000 then return windy and "windy" or "sunny" end
  if lux > 10000 then return windy and "windy-variant" or "partlycloudy" end
  return "cloudy"
end

local function ws90_update_calculated(meta, payload, now, rain)
  meta.state = meta.state or {}
  if rain then payload.rain_rate = ws90_rain_rate(meta, payload.precipitation, now) or 0 end
  for key, value in pairs(payload) do meta.state[key] = value end
  local state = meta.state
  local temperature, humidity = state.temperature, state.humidity
  local dew_point = ws90_dew_point(temperature, humidity)
  local humidex = ws90_humidex(temperature, dew_point)
  local wind_chill = ws90_wind_chill(temperature, state.wind_speed)
  if state.pressure ~= nil then
    local trend = ws90_pressure_trend(meta, state.pressure, now)
    if trend ~= nil then state.pressure_trend = trend end
  end
  local result = {
    dew_point = dew_point,
    humidex = humidex,
    heat_stress = temperature and humidity and ws90_heat_stress(state) or nil,
    wind_chill = wind_chill,
    apparent_temperature = ws90_apparent_temperature(temperature, wind_chill, humidex),
    pressure_trend = state.pressure and state.pressure_trend or nil,
    weather_condition = ws90_weather_condition(state),
    rain_rate = rain and payload.rain_rate or nil,
  }
  local save = meta.lastSave == nil or now - meta.lastSave >= 60000
  if save then meta.lastSave = now end
  return result, save
end
-- WS90 CALCULATED PURE END

local ws90_calculated_emitters = {
  dew_point = emit.shellyWs90DewPoint(),
  wind_chill = emit.shellyWs90WindChill(),
  humidex = emit.shellyWs90Humidex(),
  apparent_temperature = emit.shellyWs90ApparentTemp(),
  heat_stress = emit.shellyWs90HeatStress(),
  rain_rate = emit.shellyWs90RainRate(),
  pressure_trend = emit.shellyWs90PressureTrend(),
  weather_condition = emit.shellyWs90WeatherCondition(),
}
local ws90_calculated_inputs = {
  [0x0402] = {[0]={"temperature",0x29,100}},
  [0x0405] = {[0]={"humidity",0x21,100}},
  [0x0403] = {[0]={"pressure",0x29,10}}, -- shelly.ts1856: preserve literal raw/10, labelled hPa by primary.
  [0x0400] = {[0]={"illuminance",0x21,1}},
  [0xFC01] = {[0]={"wind_speed",0x21,10,0xFFFF}, [4]={"wind_direction",0x21,10,0xFFFF}, [7]={"gust_speed",0x21,10,0xFFFF}},
  [0xFC02] = {[0]={"uv_index",0x20,10,0xFF}},
  [0xFC03] = {[0]={"rain_status",0x10,1}, [1]={"precipitation",0x22,10,0xFFFFFF}},
}
local ws90_calculated_zero = {
  [0x0402] = {"temperatureMeasurement","temperature",2,true},
  [0x0405] = {"relativeHumidityMeasurement","humidity",5},
  [0x0400] = {"illuminanceMeasurement","illuminance",50},
  [0x0403] = {},
}

local function ws90_calculated_receive(device, rx, mappings)
  local header, body = rx.body and rx.body.zcl_header, rx.body and rx.body.zcl_body
  if header == nil then return end
  if (header.frame_ctrl.value & 3) ~= 0 or (header.cmd.value ~= 1 and header.cmd.value ~= 0x0A) or not body.attr_records then return end
  local cluster = rx.address_header.cluster.value
  local inputs = ws90_calculated_inputs[cluster]
  if inputs == nil then return end
  local context = {zb_rx=rx, src_endpoint=rx.address_header.src_endpoint.value, mfg_code=header.mfg_code and header.mfg_code.value}
  if cluster == 0xFC03 and ws90_zero_rain_frame(device, context) then return end
  local raw, recognized = {}, false
  for _, record in ipairs(body.attr_records) do
    local attribute = record.attr_id.value
    local input = inputs[attribute]
    if input and (not record.status or record.status.value == 0) and record.data and record.data_type and
        record.data_type.value == input[2] and #zcl.find_mappings(mappings, cluster, attribute, device, context) > 0 then
      raw[attribute], recognized = record.data.value, true
    end
  end
  if not recognized then return end
  local payload = {}
  for attribute, value in pairs(raw) do
    local input = inputs[attribute]
    local zero = ws90_calculated_zero[cluster]
    if zero and not ws90_zero_value_allowed(device, value, table.unpack(zero)) then return end
    if value ~= input[4] then
      if input[1] == "rain_status" then payload.rain_status = value == true or value == 1
      elseif input[1] == "illuminance" then payload.illuminance = value > 0 and ws90_round(10 ^ ((value - 1) / 10000)) or 0
      else payload[input[1]] = value / input[3] end
    end
  end
  if cluster == 0xFC02 and next(payload) == nil then return end
  local meta = device:get_field("__ws90_calculated")
  if meta == nil then
    meta = require("st.utils").deep_copy(device:get_field("ws90:calculated") or {})
    device:set_field("__ws90_calculated", meta)
  end
  local now = math.floor(require("cosock.socket").gettime() * 1000)
  local values, save = ws90_update_calculated(meta, payload, now, cluster == 0xFC03)
  if save then device:set_field("ws90:calculated", require("st.utils").deep_copy(meta), {persist=true}) end
  for name, value in pairs(values) do
    if type(value) ~= "number" or (value == value and value ~= math.huge and value ~= -math.huge) then
      local event = ws90_calculated_emitters[name](device, value)
      if event then device:emit_event(event) end
    end
  end
end


local function ws90_attribute(cluster, attribute, options)
  options.minimum_interval, options.maximum_interval = 10, 3600
  options.reportable_change, options.read_on_configure, options.read_only = 1, true, true
  return zcl.cluster_attribute(cluster, attribute, options)
end

local ws90_identify = "concertmirror08464.shellyWs90Identify"
local ws90_voltage_reporting = {
  cluster=1, attribute=0x0020, data_type=data_types.Uint8,
  minimum_interval=300, maximum_interval=21600, reportable_change=1,
}
local weather_station
weather_station = {
  profile = "sensors-weather-temp-humidity-pressure-illuminance-battery-ws90",
  capability_commands = {
    {capability_id=ws90_identify, command_name="identify",
      mapping_name="shelly_ws90_identify", value=3},
    {capability_id=ws90_identify, command_name="setIdentifyTime",
      argument_name="identifyTime", mapping_name="shelly_ws90_identify"},
  },
  zigbee_message_handler = function(device, rx)
    ws90_calculated_receive(device, rx, weather_station.zcl_clusters)
  end,
  configure = function(_, device)
    device:remove_configured_attribute(1, 0x0020)
    if device:get_field("zcl_reporting:zr00010020auto") ~= nil then
      zcl.configure_reporting(device, ws90_voltage_reporting, device:get_endpoint(1), {auto_endpoint=true})
    end
  end,
  zcl_clusters = {
    ws90_zero_filter(zcl.temperature({minimum_interval=10,maximum_interval=3600,reportable_change=100}), "temperatureMeasurement", "temperature", 2, true),
    ws90_zero_filter(zcl.humidity({minimum_interval=10,maximum_interval=3600,reportable_change=100}), "relativeHumidityMeasurement", "humidity", 5),
    ws90_zero_filter(zcl.pressure({minimum_interval=10,maximum_interval=3600,reportable_change=5,read_only=true})),
    ws90_zero_filter(zcl.illuminance({minimum_interval=10,maximum_interval=3600,reportable_change=5}), "illuminanceMeasurement", "illuminance", 50),
    zcl.battery({minimum_interval=3600,maximum_interval=65000,reportable_change=10,from_device=battery_uint8_value}),
    zcl.battery_voltage({from_device=battery_uint8_value, configure_reporting=false,
      reporting_defaults=ws90_voltage_reporting}),
    ws90_attribute(1,0x0040,{
      name="ws90_capacitor_voltage",endpoint=1,data_type=data_types.Uint8,scale=10,
      emit=emit.shellyWs90CapacitorVoltage(),
    }),
    ws90_attribute(0xFC02, 0x0000, {
      name = "ws90_uv_index",
      emit = emit.shellyWs90UvIndex(),
      data_type = data_types.Uint8,
      scale = 10,
      from_device = battery_uint8_value,
      mfg_code = 0x1490,
    }),
    ws90_attribute(0xFC03, 0x0000, {
      name = "ws90_rain_status",
      emit = emit.ws90RainStatus(),
      data_type = data_types.Boolean,
      mfg_code = 0x1490,
      from_device = function(value, device, context)
        if ws90_zero_rain_frame(device, context) then return nil end
        return value and "raining" or "dry"
      end,
    }),
    ws90_zero_filter(ws90_attribute(0xFC03, 0x0001, {
      name = "ws90_precipitation",
      emit = emit.shellyWs90Precipitation(),
      data_type = data_types.Uint24,
      scale = 10,
      from_device = function(value, device, context)
        local zero_frame, precipitation = ws90_zero_rain_frame(device, context)
        if zero_frame or (precipitation ~= nil and context.raw_value ~= precipitation) then return nil end
        if context.raw_value ~= 0xFFFFFF then return value end
      end,
      mfg_code = 0x1490,
    }), "concertmirror08464.shellyWs90Precipitation", "precipitation", 0),
    zcl.cluster_attribute(0x0003, 0, {name="shelly_ws90_identify", endpoint=1,
      write_only=true, suppress_optimistic_state=true, tx_command_id=0,
      to_device=function(value)
        if type(value) ~= "number" or value % 1 ~= 0 or value < 1 or value > 30 then return nil end
        return string.pack("<I2", value)
      end}),
  },
}

for index, item in ipairs({
  {0x0000, "ws90_wind_speed", emit.shellyWs90WindSpeed()},
  {0x0004, "ws90_wind_direction", emit.ws90WindDirection()},
  {0x0007, "ws90_gust_speed", emit.shellyWs90GustSpeed()},
}) do
  table.insert(weather_station.zcl_clusters, 7 + index, ws90_attribute(0xFC01, item[1], {
    name = item[2],
    emit = item[3],
    data_type = data_types.Uint16,
    scale = 10,
    from_device = function(value, _, context) if context.raw_value ~= 0xFFFF then return value end end,
    mfg_code = 0x1490,
  }))
end

register_device_definition(metered_plug, {
  device_helpers.create_fingerprint("Shelly", "Plug US"),
})

register_device_definition(power_strip, {
  device_helpers.create_fingerprint("Shelly", "Power Strip"),
})

register_device_definition(dimmer_light, {
  device_helpers.create_fingerprint("Shelly", "Dimmer"),
  device_helpers.create_fingerprint("Shelly", "Dimmer US"),
})

register_device_definition(water_sensor, {
  device_helpers.create_fingerprint("Shelly", "Flood"),
  device_helpers.create_fingerprint("Shelly", "Flood S"),
})

register_device_definition(temp_humidity, {
  device_helpers.create_fingerprint("Shelly", "BLU H&T ZB"),
})

register_device_definition(weather_station, {
  device_helpers.create_fingerprint("Shelly", "Ecowitt WS90"),
})

-- ZCL REPORTING CAPABILITIES BEGIN
zcl.attach_reporting_capabilities(device_definitions, {
  {1, "rpt-tcb"},
  {2, "rpt-pob", {zr000600001 = "Switch", zr000600002 = "SwitchTwo", zr000600003 = "SwitchThree", zr000600004 = "SwitchFour", zr0b0405051 = "Voltage", zr0b0405052 = "VoltageTwo", zr0b0405053 = "VoltageThree", zr0b0405054 = "VoltageFour", zr0b0405081 = "Current", zr0b0405082 = "CurrentTwo", zr0b0405083 = "CurrentThree", zr0b0405084 = "CurrentFour", zr0b04050b1 = "Power", zr0b04050b2 = "PowerTwo", zr0b04050b3 = "PowerThree", zr0b04050b4 = "PowerFour"}},
  {3, "rpt-hll"},
  {4, "rpt-fwi"},
  {5, "rpt-bsz"},
  {6, "rpt-ead"},
})
-- ZCL REPORTING CAPABILITIES END

return {
  id = "zcl.sensors.shelly_retail",
  registrations = device_definitions,
}
