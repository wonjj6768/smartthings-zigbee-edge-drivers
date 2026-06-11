local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local capabilities = require "st.capabilities"

local device_definitions, register_device_definition = device_helpers.definition_registry()

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
  return source[key] or source[tostring(key)]
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

local temp_humidity = {
  profile = "sensors-temp-humidity-battery",
  zcl_clusters = {
    zcl.temperature(),
    zcl.humidity(),
    zcl.battery(),
  },
}

local temp_humidity_pressure = {
  profile = "sensors-temp-humidity-pressure-battery-voltage",
  zcl_clusters = {
    zcl.cluster_attribute(LUMI_BASIC_CLUSTER, LUMI_BASIC_ATTR, {
      name = "lumi_basic",
      emit = lumi_basic_events,
      read_only = true,
    }),
    zcl.temperature(),
    zcl.humidity(),
    zcl.pressure(),
    zcl.battery(),
    zcl.battery_voltage(),
  },
}

local illuminance = {
  profile = "sensors-illuminance-battery",
  zcl_clusters = {
    zcl.illuminance(),
    zcl.battery(),
  },
}

local motion = {
  profile = "safety-motion-battery",
  zcl_clusters = {
    zcl.motion(),
    zcl.battery(),
  },
}

local contact = {
  profile = "safety-contact-battery",
  zcl_clusters = {
    zcl.contact(),
    zcl.battery(),
  },
}

local water = {
  profile = "safety-water-leak-battery",
  zcl_clusters = {
    zcl.water(),
    zcl.battery(),
  },
}

local dimmer_light = {
  profile = "lights-dimmer",
  zcl_clusters = {
    zcl.switch(),
    zcl.level(),
  },
}

local switch_1 = {
  profile = "switches-switch-1",
  zcl_clusters = {
    zcl.switch(),
  },
}

register_device_definition(temp_humidity, {
  device_helpers.create_fingerprint("Aqara", "AAQS-S01"),
  device_helpers.create_fingerprint("Aqara", "CM-M01"),
  device_helpers.create_fingerprint("Aqara", "CM-M01R"),
  device_helpers.create_fingerprint("Aqara", "TH-S02D"),
  device_helpers.create_fingerprint("Aqara", "ZHTZ02LM"),
  device_helpers.create_fingerprint("Xiaomi", "ZHTZ02LM"),
})

register_device_definition(temp_humidity_pressure, {
  device_helpers.create_fingerprint("LUMI", "lumi.weather"),
})

register_device_definition(illuminance, {
  device_helpers.create_fingerprint("Aqara", "RLS-K01D"),
  device_helpers.create_fingerprint("Aqara", "MZTD11LM"),
  device_helpers.create_fingerprint("Xiaomi", "YTC4040GL"),
})

register_device_definition(motion, {
  device_helpers.create_fingerprint("Aqara", "PETC1-M01"),
  device_helpers.create_fingerprint("Aqara", "MS-S02"),
  device_helpers.create_fingerprint("Aqara", "MZSD11LM"),
  device_helpers.create_fingerprint("Aqara", "MZSD12LM"),
  device_helpers.create_fingerprint("Xiaomi", "MZSD11LM"),
  device_helpers.create_fingerprint("Xiaomi", "MZSD12LM"),
})

register_device_definition(contact, {
  device_helpers.create_fingerprint("Aqara", "DCM-K01"),
  device_helpers.create_fingerprint("Aqara", "MFCZQ12LM"),
  device_helpers.create_fingerprint("Aqara", "DW-S03D"),
  device_helpers.create_fingerprint("Xiaomi", "YTC4004CN"),
  device_helpers.create_fingerprint("Xiaomi", "YTC4005CN"),
  device_helpers.create_fingerprint("Xiaomi", "YTC4006CN"),
  device_helpers.create_fingerprint("Xiaomi", "YTC4007CN"),
})

register_device_definition(water, {
  device_helpers.create_fingerprint("Aqara", "JT-BZ-03AQ/A"),
  device_helpers.create_fingerprint("Aqara", "SRSC-M01"),
  device_helpers.create_fingerprint("Xiaomi", "YTC4015CN"),
  device_helpers.create_fingerprint("Xiaomi", "YTC4016CN"),
  device_helpers.create_fingerprint("Xiaomi", "YTC4017CN"),
  device_helpers.create_fingerprint("Xiaomi", "YTC4018CN"),
})

register_device_definition(dimmer_light, {
  device_helpers.create_fingerprint("Aqara", "RSD-M01"),
  device_helpers.create_fingerprint("Aqara", "LEDLBT1-L01"),
})

register_device_definition(switch_1, {
  device_helpers.create_fingerprint("Aqara", "JY-GZ-03AQ"),
  device_helpers.create_fingerprint("Aqara", "WRS-R02"),
  device_helpers.create_fingerprint("Aqara", "WB-R02D"),
  device_helpers.create_fingerprint("Aqara", "WL-S02D"),
  device_helpers.create_fingerprint("Aqara", "WS-K08D"),
  device_helpers.create_fingerprint("Xiaomi", "MFKZQ01LM"),
  device_helpers.create_fingerprint("Xiaomi", "YTC4019RT"),
  device_helpers.create_fingerprint("Xiaomi", "YTC4020RT"),
  device_helpers.create_fingerprint("Xiaomi", "YTC4039GL"),
  device_helpers.create_fingerprint("Xiaomi", "YTC4041GL"),
  device_helpers.create_fingerprint("Xiaomi", "YTC4042GL"),
  device_helpers.create_fingerprint("Xiaomi", "YTC4043GL"),
})

return device_definitions
