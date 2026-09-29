local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local data_types = require "st.zigbee.data_types"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local emit_battery = emit.battery()
local emit_voltage = emit.voltage()

local function unwrap(value)
  if type(value) == "table" then return value.value end
  return value
end

local function divide_by(divisor)
  return function(value)
    value = tonumber(unwrap(value))
    if value == nil then return nil end
    return value / divisor
  end
end

local function emit_battery_bundle(_, voltage)
  local battery
  if voltage >= 6.0 then battery = 100
  elseif voltage >= 5.9 then battery = 75
  elseif voltage >= 5.8 then battery = 50
  elseif voltage >= 5.7 then battery = 25
  else battery = 0 end

  return {
    emit_battery(nil, battery),
    emit_voltage(nil, voltage),
  }
end

-- Current Z2M: Heiwa HPZERAD-V1 environment core on thermostat endpoint 25.
-- Thermostat/profile/display configuration attributes remain deferred; this
-- family claims only the independently useful readonly sensor surface.
local hpzerad_v1_environment_core = {
  profile = "sensors-heiwa-hpzerad-v1-core",
  package_group = "z2m-zcl-sensors",
  zcl_clusters = {
    zcl.cluster_attribute(0x0201, 0x0420, {
      name = "heiwa_display_temperature",
      endpoint = 25,
      component = "main",
      data_type = data_types.Int16,
      read_only = true,
      read_on_configure = true,
      minimum_interval = 0,
      maximum_interval = 3600,
      reportable_change = 1,
      from_device = divide_by(10),
      emit = emit.temperature("C"),
    }),
    zcl.cluster_attribute(0x0201, 0x0422, {
      name = "heiwa_humidity",
      endpoint = 25,
      component = "main",
      data_type = data_types.Uint8,
      read_only = true,
      read_on_configure = true,
      minimum_interval = 10,
      maximum_interval = 3600,
      reportable_change = 1,
      from_device = function(value) return tonumber(unwrap(value)) end,
      emit = emit.humidity(),
    }),
    zcl.cluster_attribute(0x0201, 0x0424, {
      name = "heiwa_co2",
      endpoint = 25,
      component = "main",
      data_type = data_types.Uint16,
      read_only = true,
      read_on_configure = true,
      from_device = function(value) return tonumber(unwrap(value)) end,
      emit = emit.co2(),
    }),
    zcl.cluster_attribute(0x0201, 0x040F, {
      name = "heiwa_battery_voltage",
      endpoint = 25,
      component = "main",
      data_type = data_types.Uint16,
      read_only = true,
      read_on_configure = true,
      from_device = divide_by(100),
      emit = emit_battery_bundle,
    }),
  },
}

register_device_definition(hpzerad_v1_environment_core, {
  device_helpers.create_fingerprint("Eurevia", "Thermostat_RF_Model_00000000000"),
})

return {
  id = "zcl.sensors.z2m_absorption_heiwa",
  registrations = device_definitions,
}
