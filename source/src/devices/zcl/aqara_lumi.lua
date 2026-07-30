local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local capabilities = require "st.capabilities"
local emit = require "emitters"

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

local temp_humidity_lumi_basic = {
  profile = "sensors-temp-humidity-battery-voltage",
  zcl_clusters = {
    zcl.cluster_attribute(LUMI_BASIC_CLUSTER, LUMI_BASIC_ATTR, {
      name = "lumi_basic",
      emit = lumi_basic_events,
      read_only = true,
    }),
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
  profile = "sensors-illuminance-battery-voltage-lumi-pending",
  zcl_clusters = {
    zcl.illuminance(),
    zcl.battery(),
    zcl.battery_voltage(),
  },
}

local motion = {
  profile = "safety-motion-battery-voltage",
  zcl_clusters = {
    zcl.occupancy({ emit = emit.motion() }),
    zcl.cluster_attribute(LUMI_BASIC_CLUSTER, LUMI_BASIC_ATTR, {
      name = "lumi_basic",
      emit = lumi_basic_events,
      read_only = true,
    }),
  },
}

local motion_illuminance = {
  profile = "safety-motion-illuminance-battery",
  zcl_clusters = {
    zcl.motion(),
    zcl.illuminance(),
    zcl.battery(),
  },
}

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

register_device_definition(temp_humidity_lumi_basic, {
  device_helpers.create_fingerprint("LUMI", "lumi.sens"),
  device_helpers.create_fingerprint("LUMI", "lumi.sensor_ht"),
})

register_device_definition(temp_humidity_pressure, {
  device_helpers.create_fingerprint("LUMI", "lumi.sensor_ht.agl02"),
  device_helpers.create_fingerprint("LUMI", "lumi.weather"),
})

register_device_definition(illuminance, {
  device_helpers.create_fingerprint("LUMI", "lumi.sen_ill.agl01"),
  device_helpers.create_fingerprint("LUMI", "lumi.sen_ill.mgl01"),
})

register_device_definition(motion, {
  device_helpers.create_fingerprint("LUMI", "lumi.sensor_motion"),
})

register_device_definition(motion_illuminance, {
  device_helpers.create_fingerprint("LUMI", "lumi.motion.ac02"),
  device_helpers.create_fingerprint("LUMI", "lumi.motion.acn001"),
  device_helpers.create_fingerprint("LUMI", "lumi.motion.agl02"),
  device_helpers.create_fingerprint("LUMI", "lumi.sensor_motion.aq2"),
})

register_device_definition(lumi_ac01_contact, {
  device_helpers.create_fingerprint("LUMI", "lumi.magnet.ac01"),
})

register_device_definition(lumi_acn001_contact, {
  device_helpers.create_fingerprint("LUMI", "lumi.magnet.acn001"),
})

register_device_definition(lumi_agl02_contact, {
  device_helpers.create_fingerprint("LUMI", "lumi.magnet.agl02"),
})

register_device_definition(old_lumi_contact, {
  device_helpers.create_fingerprint("LUMI", "lumi.sensor_magnet"),
  device_helpers.create_fingerprint("LUMI", "lumi.sensor_magnet.aq2"),
})

register_device_definition(water_battery_low_battery_voltage, {
  device_helpers.create_fingerprint("LUMI", "lumi.flood.acn001"),
  device_helpers.create_fingerprint("LUMI", "lumi.sensor_wleak.aq1"),
})

register_device_definition(water_tamper_battery_low_battery_voltage, {
  device_helpers.create_fingerprint("LUMI", "lumi.flood.agl02"),
})

return device_definitions
