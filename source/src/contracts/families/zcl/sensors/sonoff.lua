-- SONOFF/eWeLink environmental, occupancy, and rain sensor contracts.
-- Oracle: zigbee-herdsman-converters 26.106.0, FETCH_HEAD e2aa714 (sonoff.ts / ewelink.ts).

local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local capabilities = require "st.capabilities"
local device_helpers = require "contracts.helpers.family"
local device_management = require "st.zigbee.device_management"
local data_types = require "st.zigbee.data_types"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local CLUSTER_POWER_CONFIGURATION = 0x0001
local CLUSTER_POLL_CONTROL = 0x0020
local CLUSTER_TEMPERATURE = 0x0402
local CLUSTER_PRESSURE = 0x0403
local CLUSTER_HUMIDITY = 0x0405
local CLUSTER_OCCUPANCY = 0x0406
local CLUSTER_IAS_ZONE = 0x0500
local CLUSTER_EWELINK = 0xFC11
local COOLKIT_MANUFACTURER_CODE = 0x1286

local ATTR_MEASURED_VALUE = 0x0000
local ATTR_ZONE_STATUS = 0x0002
local ATTR_OCCUPANCY = 0x0000
local ATTR_OCCUPIED_TO_UNOCCUPIED_DELAY = 0x0020
local ATTR_UNOCCUPIED_TO_OCCUPIED_DELAY = 0x0021
local ATTR_OCCUPANCY_SENSITIVITY = 0x0022

local function custom(capability_id)
  return assert(emit[capability_id], "missing SONOFF emitter: " .. capability_id)()
end

local function bind_poll_control(driver, device)
  device:send(device_management.build_bind_request(
    device,
    CLUSTER_POLL_CONTROL,
    driver.environment_info.hub_zigbee_eui,
    1
  ))
end

local function battery(options)
  options = options or {}
  return zcl.battery({
    endpoint = 1,
    minimum_interval = options.minimum_interval or 3600,
    maximum_interval = options.maximum_interval or 65000,
    reportable_change = options.reportable_change == nil and 10 or options.reportable_change,
    read_on_configure = true,
    read_only = true,
  })
end

local function battery_voltage(options)
  options = options or {}
  return zcl.battery_voltage({
    endpoint = 1,
    minimum_interval = options.minimum_interval or 3600,
    maximum_interval = options.maximum_interval or 65000,
    reportable_change = options.reportable_change == nil and 10 or options.reportable_change,
    read_on_configure = true,
    read_only = true,
  })
end

local function temperature(options)
  options = options or {}
  return zcl.temperature({
    endpoint = 1,
    minimum_interval = options.minimum_interval or 10,
    maximum_interval = options.maximum_interval or 3600,
    reportable_change = options.reportable_change == nil and 100 or options.reportable_change,
    read_on_configure = true,
    read_only = true,
    handler = options.handler,
  })
end

local function humidity(options)
  options = options or {}
  return zcl.humidity({
    endpoint = 1,
    minimum_interval = options.minimum_interval or 10,
    maximum_interval = options.maximum_interval or 3600,
    reportable_change = options.reportable_change == nil and 100 or options.reportable_change,
    read_on_configure = true,
    read_only = true,
    handler = options.handler,
  })
end

local function numeric_setting(name, capability_id, attribute_id, data_type, minimum, maximum, unit)
  return zcl.cluster_attribute(CLUSTER_EWELINK, attribute_id, {
    name = name,
    endpoint = 1,
    emit = custom(capability_id),
    data_type = data_type,
    write_type = data_type,
    scale = 100,
    -- command_sender intentionally floors scaled values. A tiny positive
    -- epsilon prevents negative decimal steps (for example -1.1 * 100) from
    -- becoming the next lower integer because of binary floating-point noise.
    to_device = function(value)
      return type(value) == "number" and value + 1e-9 or value
    end,
    numeric_range = { minimum = minimum, maximum = maximum, step = 0.1, unit = unit },
    read_on_configure = true,
  })
end

local function temperature_units(name, capability_id)
  local from_device = { [0] = "celsius", [1] = "fahrenheit" }
  local to_device = { celsius = 0, fahrenheit = 1 }
  return zcl.cluster_attribute(CLUSTER_EWELINK, 0x0007, {
    name = name,
    endpoint = 1,
    emit = custom(capability_id),
    data_type = data_types.Uint16,
    write_type = data_types.Uint16,
    from_device = function(value) return from_device[value] end,
    to_device = function(value) return to_device[value] end,
    read_on_configure = true,
  })
end

local snzb02p = {
  profile = "sonoff-snzb02p-temp-humidity",
  zcl_clusters = {
    temperature(),
    humidity(),
    battery(),
    numeric_setting(
      "sonoff_snzb02p_temperature_calibration",
      "sonoffSnzb02pTemperatureCal",
      0x2003,
      data_types.Int16,
      -50,
      50,
      "C"
    ),
    numeric_setting(
      "sonoff_snzb02p_humidity_calibration",
      "sonoffSnzb02pHumidityCal",
      0x2004,
      data_types.Int16,
      -50,
      50,
      "%"
    ),
  },
  configure = bind_poll_control,
}

register_device_definition(snzb02p, {
  device_helpers.create_fingerprint("eWeLink", "SNZB-02P"),
  -- Explicit identity authority: user-directed SONOFF Basic alias (2026-09-05).
  device_helpers.create_fingerprint("SONOFF", "SNZB-02P"),
})

local snzb02d = {
  profile = "sonoff-snzb02d-temp-humidity-display",
  zcl_clusters = {
    temperature(),
    humidity(),
    battery(),
    numeric_setting(
      "sonoff_snzb02d_comfort_temperature_min",
      "sonoffSnzb02dComfortTempMin",
      0x0004,
      data_types.Int16,
      -10,
      60,
      "C"
    ),
    numeric_setting(
      "sonoff_snzb02d_comfort_temperature_max",
      "sonoffSnzb02dComfortTempMax",
      0x0003,
      data_types.Int16,
      -10,
      60,
      "C"
    ),
    numeric_setting(
      "sonoff_snzb02d_comfort_humidity_min",
      "sonoffSnzb02dComfortHumidityMin",
      0x0005,
      data_types.Uint16,
      5,
      95,
      "%"
    ),
    numeric_setting(
      "sonoff_snzb02d_comfort_humidity_max",
      "sonoffSnzb02dComfortHumidityMax",
      0x0006,
      data_types.Uint16,
      5,
      95,
      "%"
    ),
    temperature_units("sonoff_snzb02d_temperature_units", "sonoffSnzb02dTemperatureUnits"),
    numeric_setting(
      "sonoff_snzb02d_temperature_calibration",
      "sonoffSnzb02dTemperatureCal",
      0x2003,
      data_types.Int16,
      -50,
      50,
      "C"
    ),
    numeric_setting(
      "sonoff_snzb02d_humidity_calibration",
      "sonoffSnzb02dHumidityCal",
      0x2004,
      data_types.Int16,
      -50,
      50,
      "%"
    ),
  },
  configure = bind_poll_control,
}

register_device_definition(snzb02d, {
  device_helpers.create_fingerprint("SONOFF", "SNZB-02D"),
})

local snzb02ld = {
  profile = "sonoff-snzb02ld-temperature-display",
  zcl_clusters = {
    temperature(),
    battery(),
    temperature_units("sonoff_snzb02ld_temperature_units", "sonoffSnzb02ldTemperatureUnits"),
    numeric_setting(
      "sonoff_snzb02ld_temperature_calibration",
      "sonoffSnzb02ldTemperatureCal",
      0x2003,
      data_types.Int16,
      -50,
      50,
      "C"
    ),
  },
  configure = bind_poll_control,
}

register_device_definition(snzb02ld, {
  device_helpers.create_fingerprint("SONOFF", "SNZB-02LD"),
})

local snzb02wd = {
  profile = "sonoff-snzb02wd-temp-humidity-display",
  zcl_clusters = {
    temperature(),
    humidity(),
    battery(),
    battery_voltage(),
    temperature_units("sonoff_snzb02wd_temperature_units", "sonoffSnzb02wdTemperatureUnits"),
    numeric_setting(
      "sonoff_snzb02wd_temperature_calibration",
      "sonoffSnzb02wdTemperatureCal",
      0x2003,
      data_types.Int16,
      -50,
      50,
      "C"
    ),
    numeric_setting(
      "sonoff_snzb02wd_humidity_calibration",
      "sonoffSnzb02wdHumidityCal",
      0x2004,
      data_types.Int16,
      -50,
      50,
      "%"
    ),
  },
  configure = bind_poll_control,
}

register_device_definition(snzb02wd, {
  device_helpers.create_fingerprint("SONOFF", "SNZB-02WD"),
})

local ewelink_7014 = {
  profile = "sonoff-ewelink-7014-temp-humidity",
  zcl_clusters = {
    temperature(),
    humidity(),
    battery(),
  },
}

register_device_definition(ewelink_7014, {
  device_helpers.create_fingerprint("eWeLink", "CK-TLSR8656-SS5-02(7014)"),
})

local snzb03p = {
  profile = "sonoff-snzb03p-occupancy",
  zcl_clusters = {
    zcl.occupancy({
      endpoint = 1,
      minimum_interval = 0,
      maximum_interval = 3600,
      reportable_change = 0,
      read_on_configure = true,
      read_only = true,
    }),
    zcl.cluster_attribute(CLUSTER_OCCUPANCY, ATTR_OCCUPIED_TO_UNOCCUPIED_DELAY, {
      name = "sonoff_snzb03p_motion_timeout",
      endpoint = 1,
      emit = custom("sonoffSnzb03pMotionTimeout"),
      data_type = data_types.Uint16,
      write_type = data_types.Uint16,
      numeric_range = { minimum = 5, maximum = 60, step = 1, unit = "s" },
      read_on_configure = true,
    }),
    zcl.cluster_attribute(CLUSTER_EWELINK, 0x2001, {
      name = "sonoff_snzb03p_illumination",
      endpoint = 1,
      emit = custom("sonoffSnzb03pIllumination"),
      data_type = data_types.Uint8,
      mfg_code = COOLKIT_MANUFACTURER_CODE,
      from_device = function(value) return ({ [0] = "dim", [1] = "bright" })[value] end,
      read_only = true,
      read_on_configure = false,
    }),
    battery({ maximum_interval = 7200, reportable_change = 2 }),
    battery_voltage({ maximum_interval = 7200, reportable_change = 100 }),
  },
}

register_device_definition(snzb03p, {
  device_helpers.create_fingerprint("eWeLink", "SNZB-03P"),
  -- Explicit identity authority: user-directed SONOFF Basic alias (2026-09-05).
  device_helpers.create_fingerprint("SONOFF", "SNZB-03P"),
})

local mg35rz = {
  profile = "sonoff-mg35rz-occupancy",
  zcl_clusters = {
    -- Upstream intentionally leaves occupancy reporting/configuration disabled.
    zcl.cluster_attribute(CLUSTER_OCCUPANCY, ATTR_OCCUPANCY, {
      name = "occupancy",
      endpoint = 1,
      emit = emit.occupancy(),
      data_type = data_types.Bitmap8,
      from_device = function(value)
        value = type(value) == "table" and value.value or value
        if type(value) ~= "number" then return nil end
        return value % 2 == 1
      end,
      read_only = true,
      read_on_configure = false,
    }),
    zcl.cluster_attribute(CLUSTER_OCCUPANCY, ATTR_OCCUPIED_TO_UNOCCUPIED_DELAY, {
      name = "sonoff_mg35rz_occupied_delay",
      endpoint = 1,
      emit = custom("sonoffMg35rzOccupiedDelay"),
      data_type = data_types.Uint16,
      write_type = data_types.Uint16,
      numeric_range = { minimum = 60, maximum = 65535, step = 1, unit = "s" },
      read_on_configure = true,
    }),
    zcl.cluster_attribute(CLUSTER_OCCUPANCY, ATTR_UNOCCUPIED_TO_OCCUPIED_DELAY, {
      name = "sonoff_mg35rz_unoccupied_delay",
      endpoint = 1,
      emit = custom("sonoffMg35rzUnoccupiedDelay"),
      data_type = data_types.Uint16,
      write_type = data_types.Uint16,
      numeric_range = { minimum = 0, maximum = 65535, step = 1, unit = "s" },
      read_on_configure = true,
    }),
    zcl.cluster_attribute(CLUSTER_OCCUPANCY, ATTR_OCCUPANCY_SENSITIVITY, {
      name = "sonoff_mg35rz_sensitivity",
      endpoint = 1,
      emit = custom("sonoffMg35rzSensitivity"),
      data_type = data_types.Uint8,
      write_type = data_types.Uint8,
      from_device = function(value) return ({ [1] = "low", [2] = "medium", [3] = "high" })[value] end,
      to_device = function(value) return ({ low = 1, medium = 2, high = 3 })[value] end,
      read_on_configure = true,
    }),
  },
}

register_device_definition(mg35rz, {
  device_helpers.create_fingerprint("eWeLink", "CK-BL702-MWS-01(7016)"),
  -- Explicit identity authority: user-directed SONOFF Basic exact (2026-09-05).
  device_helpers.create_fingerprint("SONOFF", "MG1_5RZ"),
})

local function remember(field)
  return function(device, value)
    device:set_field(field, value, { persist = false })
  end
end

local function round(value, digits)
  local factor = 10 ^ digits
  local scaled = value * factor
  if scaled >= 0 then
    return math.floor(scaled + 0.5) / factor
  end
  return math.ceil(scaled - 0.5) / factor
end

local function calculated_environment_events(temperature_field, humidity_field, capability_id)
  local vpd_event = custom(capability_id)
  return function(device)
    local temperature_value = device:get_field(temperature_field)
    local humidity_value = device:get_field(humidity_field)
    if type(temperature_value) ~= "number" or type(humidity_value) ~= "number" then
      return nil
    end

    local saturated = 0.61078 * math.exp((17.27 * temperature_value) / (temperature_value + 237.3))
    local actual = (humidity_value / 100) * saturated
    local events = { vpd_event(device, round(saturated - actual, 2)) }

    if humidity_value > 0 then
      local alpha = (17.27 * temperature_value) / (temperature_value + 237.7) + math.log(humidity_value / 100)
      local dew_point = round((237.7 * alpha) / (17.27 - alpha), 1)
      events[#events + 1] = capabilities.dewPoint.dewpoint({ value = dew_point, unit = "C" })
    end

    return events
  end
end

local SNZB02M_TEMPERATURE_FIELD = "__sonoff_snzb02m_temperature"
local SNZB02M_HUMIDITY_FIELD = "__sonoff_snzb02m_humidity"
local snzb02m_calculated_events = calculated_environment_events(
  SNZB02M_TEMPERATURE_FIELD,
  SNZB02M_HUMIDITY_FIELD,
  "sonoffSnzb02mVpd"
)

local snzb02m = {
  profile = "sonoff-snzb02m-environment",
  zcl_clusters = {
    temperature({
      minimum_interval = 5,
      reportable_change = 20,
      handler = remember(SNZB02M_TEMPERATURE_FIELD),
    }),
    humidity({
      minimum_interval = 5,
      reportable_change = 100,
      handler = remember(SNZB02M_HUMIDITY_FIELD),
    }),
    battery(),
    zcl.cluster_attribute(CLUSTER_PRESSURE, 0x0004, {
      name = "pressure",
      endpoint = 1,
      emit = function(_, value)
        return capabilities.atmosphericPressureMeasurement.atmosphericPressure({ value = value, unit = "hPa" })
      end,
      data_type = data_types.Int32,
      scale = 100,
      mfg_code = COOLKIT_MANUFACTURER_CODE,
      read_only = true,
      read_on_configure = true,
    }),
    numeric_setting(
      "sonoff_snzb02m_temperature_calibration",
      "sonoffSnzb02mTemperatureCal",
      0x2003,
      data_types.Int16,
      -50,
      50,
      "C"
    ),
    numeric_setting(
      "sonoff_snzb02m_humidity_calibration",
      "sonoffSnzb02mHumidityCal",
      0x2004,
      data_types.Int16,
      -50,
      50,
      "%"
    ),
    numeric_setting(
      "sonoff_snzb02m_pressure_calibration",
      "sonoffSnzb02mPressureCal",
      0x2007,
      data_types.Int16,
      -200,
      200,
      "hPa"
    ),
    -- These two passive mappings recalculate on either source report without
    -- adding configure/report/read traffic beyond the upstream contract.
    zcl.cluster_attribute(CLUSTER_TEMPERATURE, ATTR_MEASURED_VALUE, {
      name = "sonoff_snzb02m_vpd",
      endpoint = 1,
      emit = snzb02m_calculated_events,
      data_type = data_types.Int16,
      scale = 100,
      read_only = true,
      read_on_configure = false,
    }),
    zcl.cluster_attribute(CLUSTER_HUMIDITY, ATTR_MEASURED_VALUE, {
      name = "sonoff_snzb02m_calculated_humidity_trigger",
      endpoint = 1,
      emit = snzb02m_calculated_events,
      data_type = data_types.Uint16,
      scale = 100,
      read_only = true,
      read_on_configure = false,
    }),
  },
  configure = bind_poll_control,
}

register_device_definition(snzb02m, {
  device_helpers.create_fingerprint("SONOFF", "SNZB-02M"),
})

local SNZB02B_TEMPERATURE_FIELD = "__sonoff_snzb02b_temperature"
local SNZB02B_HUMIDITY_FIELD = "__sonoff_snzb02b_humidity"
local snzb02b_calculated_events = calculated_environment_events(
  SNZB02B_TEMPERATURE_FIELD,
  SNZB02B_HUMIDITY_FIELD,
  "sonoffSnzb02bVpd"
)

local snzb02b = {
  profile = "sonoff-snzb02b-environment",
  zcl_clusters = {
    temperature({
      minimum_interval = 5,
      reportable_change = 20,
      handler = remember(SNZB02B_TEMPERATURE_FIELD),
    }),
    humidity({
      minimum_interval = 5,
      reportable_change = 100,
      handler = remember(SNZB02B_HUMIDITY_FIELD),
    }),
    battery(),
    numeric_setting(
      "sonoff_snzb02b_temperature_calibration",
      "sonoffSnzb02bTemperatureCal",
      0x2003,
      data_types.Int16,
      -50,
      50,
      "C"
    ),
    numeric_setting(
      "sonoff_snzb02b_humidity_calibration",
      "sonoffSnzb02bHumidityCal",
      0x2004,
      data_types.Int16,
      -50,
      50,
      "%"
    ),
    zcl.cluster_attribute(CLUSTER_TEMPERATURE, ATTR_MEASURED_VALUE, {
      name = "sonoff_snzb02b_vpd",
      endpoint = 1,
      emit = snzb02b_calculated_events,
      data_type = data_types.Int16,
      scale = 100,
      read_only = true,
      read_on_configure = false,
    }),
    zcl.cluster_attribute(CLUSTER_HUMIDITY, ATTR_MEASURED_VALUE, {
      name = "sonoff_snzb02b_calculated_humidity_trigger",
      endpoint = 1,
      emit = snzb02b_calculated_events,
      data_type = data_types.Uint16,
      scale = 100,
      read_only = true,
      read_on_configure = false,
    }),
  },
  configure = bind_poll_control,
}

register_device_definition(snzb02b, {
  device_helpers.create_fingerprint("SONOFF", "SNZB-02B"),
})

local function extract_zone_status(zb_rx)
  local body = zb_rx and zb_rx.body and zb_rx.body.zcl_body or nil
  local zone_status = body and (body.zone_status or body.zonestatus) or nil
  local value = type(zone_status) == "table" and zone_status.value or zone_status
  return { raw_value = value, typed_value = zone_status }
end

local ws01 = {
  profile = "sonoff-ws01-rain",
  zcl_clusters = {
    zcl.cluster_attribute(CLUSTER_IAS_ZONE, ATTR_ZONE_STATUS, {
      name = "rain",
      endpoint = 1,
      emit = function(_, value)
        return value == "possiblePrecipitation"
          and capabilities.precipitationSensor.precipitationIntensity.possiblePrecipitation()
          or capabilities.precipitationSensor.precipitationIntensity.none()
      end,
      data_type = data_types.Bitmap16,
      from_device = function(value)
        value = type(value) == "table" and value.value or value
        if type(value) ~= "number" then return nil end
        return value % 2 == 1 and "possiblePrecipitation" or "none"
      end,
      command_id = 0x00,
      command_extractor = extract_zone_status,
      read_only = true,
      read_on_configure = false,
    }),
  },
}

register_device_definition(ws01, {
  device_helpers.create_fingerprint("eWeLink", "WS01"),
})

-- Classic models have different reporting and GET contracts from the P/D series.
-- SONOFF manufacturer is user-directed; Basic identity remains hardware-unverified.
local function classic_refresh(device, preset)
  return zcl.read_configured_attributes(device, preset.zcl_clusters)
end

local function classic_battery(maximum_interval, change)
  return zcl.battery({
    endpoint = 1,
    minimum_interval = 3600,
    maximum_interval = maximum_interval,
    reportable_change = change,
    read_on_configure = true,
    read_only = true,
    from_device = function(value)
      -- Conversion runs after /2. ZHC ignores the Uint8 unknown sentinel 255.
      if type(value) == "number" and value >= 0 and value < 127.5 then return value end
    end,
  })
end

local function classic_voltage(maximum_interval, change)
  return zcl.battery_voltage({
    endpoint = 1,
    minimum_interval = 3600,
    maximum_interval = maximum_interval,
    reportable_change = change,
    read_on_configure = true,
    read_only = true,
    from_device = function(value)
      -- ZHC mV is represented by the standard SmartThings V attribute (/10).
      if type(value) == "number" and value >= 0 and value < 25.5 then return value end
    end,
  })
end

local snzb02_classic = {
  profile = "sonoff-snzb02-classic-temp-humidity",
  magic_packet = false,
  zcl_clusters = {
    zcl.temperature({
      endpoint = 1,
      minimum_interval = 30,
      maximum_interval = 3600,
      reportable_change = 20,
      read_on_configure = false,
      read_only = true,
      from_device = function(value)
        if type(value) == "number" and value > -33 and value < 100 then return value end
      end,
    }),
    zcl.humidity({
      endpoint = 1,
      minimum_interval = 30,
      maximum_interval = 3600,
      reportable_change = 100,
      read_on_configure = false,
      read_only = true,
      from_device = function(value)
        if type(value) == "number" and value >= 0 and value <= 100 then return value end
      end,
    }),
    classic_battery(65000, 0),
    classic_voltage(65000, 0),
  },
  parent_refresh = classic_refresh,
}

register_device_definition(snzb02_classic, {
  device_helpers.create_fingerprint("SONOFF", "SNZB-02"),
  device_helpers.create_fingerprint("SONOFF", "TH01"),
  device_helpers.create_fingerprint("SONOFF", "CK-TLSR8656-SS5-01(7014)"),
})

local function classic_zone_bit(bit)
  return function(value)
    value = type(value) == "table" and value.value or value
    if type(value) ~= "number" or value < 0 or value > 65535 or value % 1 ~= 0 then return nil end
    return math.floor(value / (2 ^ bit)) % 2 == 1
  end
end

local snzb04_classic = {
  profile = "sonoff-snzb04-classic-contact",
  magic_packet = false,
  zcl_clusters = {
    zcl.cluster_attribute(CLUSTER_IAS_ZONE, ATTR_ZONE_STATUS, {
      name = "contact",
      endpoint = 1,
      emit = emit.contact(),
      data_type = data_types.Bitmap16,
      from_device = classic_zone_bit(0),
      command_id = 0x00,
      command_extractor = extract_zone_status,
      ias_configure_method = 0, -- SDK CUSTOM: no invented CIE write/enroll or IAS bind.
      read_only = true,
      read_on_configure = false,
    }),
    zcl.cluster_attribute(CLUSTER_IAS_ZONE, ATTR_ZONE_STATUS, {
      name = "battery_low",
      endpoint = 1,
      emit = function(_, value)
        return value and capabilities.batteryLevel.battery.critical()
          or capabilities.batteryLevel.battery.normal()
      end,
      data_type = data_types.Bitmap16,
      from_device = classic_zone_bit(3),
      command_id = 0x00,
      command_extractor = extract_zone_status,
      ias_configure_method = 0,
      read_only = true,
      read_on_configure = false,
    }),
    classic_battery(7200, 2),
    classic_voltage(7200, 100),
  },
  parent_refresh = classic_refresh,
}

register_device_definition(snzb04_classic, {
  device_helpers.create_fingerprint("SONOFF", "SNZB-04"),
  device_helpers.create_fingerprint("SONOFF", "DS01"),
  device_helpers.create_fingerprint("SONOFF", "CK-TLSR8656-SS5-01(7003)"),
})

return {
  id = "zcl.sensors.sonoff",
  registrations = device_definitions,
}
