local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local capabilities = require "st.capabilities"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local function build_thermostat(profile, options)
  options = options or {}
  local function mapping_options()
    return {
      endpoint = options.endpoint,
      component = options.component,
    }
  end
  local clusters = {
    options.temperature_measurement == true and zcl.temperature(mapping_options()) or zcl.local_temperature(mapping_options()),
    zcl.heating_setpoint(mapping_options()),
    zcl.thermostat_operating_state(mapping_options()),
  }

  if options.system_mode ~= false then
    clusters[#clusters + 1] = zcl.system_mode(mapping_options())
  end

  if options.cooling == true then
    clusters[#clusters + 1] = zcl.cooling_setpoint(mapping_options())
  end

  if options.fan == true then
    clusters[#clusters + 1] = zcl.fan_mode(mapping_options())
  end

  if options.battery == true then
    clusters[#clusters + 1] = zcl.battery({
      endpoint = options.endpoint,
      component = options.component,
      scale = options.battery_scale,
    })
  end

  if options.battery_voltage == true then
    clusters[#clusters + 1] = zcl.battery_voltage(mapping_options())
  end

  if options.humidity == true then
    clusters[#clusters + 1] = zcl.humidity(mapping_options())
  end

  if options.power == true then
    clusters[#clusters + 1] = zcl.power()
  end

  if options.energy == true then
    clusters[#clusters + 1] = zcl.energy()
  end

  if options.current == true then
    clusters[#clusters + 1] = zcl.current()
  end

  return {
    profile = profile,
    zcl_clusters = clusters,
  }
end

local thermostat = build_thermostat("thermostats-thermostat")
local thermostat_battery = build_thermostat("thermostats-thermostat-battery", { battery = true })
local centralite_thermostat = build_thermostat("thermostats-centralite-thermostat", {
  battery = true,
  cooling = true,
  fan = true,
})
local schneider_room_thermostat = build_thermostat("thermostats-schneider-room-thermostat-pending", {
  battery = true,
  battery_scale = 1,
  battery_voltage = true,
  humidity = true,
  system_mode = false,
  temperature_measurement = true,
})
local ecozy_thermostat = build_thermostat("thermostats-ecozy-thermostat", {
  battery = true,
  endpoint = 3,
})
ecozy_thermostat.thermostat_supported_modes = { "off", "auto", "heat" }
ecozy_thermostat.heating_setpoint_range = { minimum = 7, maximum = 30, step = 1, unit = "C" }
ecozy_thermostat.runtime_start = function(device)
  device:emit_component_event(
    { id = "main" },
    capabilities.thermostatMode.supportedThermostatModes(
      ecozy_thermostat.thermostat_supported_modes,
      { visibility = { displayed = false } }
    )
  )
  device:emit_component_event(
    { id = "main" },
    capabilities.thermostatHeatingSetpoint.heatingSetpointRange({
      value = {
        minimum = ecozy_thermostat.heating_setpoint_range.minimum,
        maximum = ecozy_thermostat.heating_setpoint_range.maximum,
        step = ecozy_thermostat.heating_setpoint_range.step,
      },
      unit = ecozy_thermostat.heating_setpoint_range.unit,
    })
  )
end
ecozy_thermostat.zcl_clusters[#ecozy_thermostat.zcl_clusters + 1] = zcl.local_temperature_calibration({ endpoint = 3 })
ecozy_thermostat.zcl_clusters[#ecozy_thermostat.zcl_clusters + 1] = zcl.pi_heating_demand({ endpoint = 3 })
local namron_edge_thermostat = build_thermostat("thermostats-thermostat-humidity-power-energy-current", {
  humidity = true,
  power = true,
  energy = true,
  current = true,
})
local schneider_heating_thermostat = {
  profile = "thermostats-schneider-heating-power-energy-pending",
  zcl_clusters = {
    zcl.local_temperature({ endpoint = 1 }),
    zcl.heating_setpoint({ endpoint = 1 }),
    zcl.thermostat_operating_state({ endpoint = 1 }),
    zcl.system_mode({ endpoint = 1 }),
    zcl.power({ endpoint = 2 }),
    zcl.energy({ endpoint = 2 }),
  },
}
local salus_fcu_thermostat = build_thermostat("thermostats-fcu-thermostat", { endpoint = 9, fan = true })
local hive_dual_thermostat = {
  profile = "thermostats-hive-dual-thermostat-pending",
  zcl_clusters = {},
}
for _, endpoint in ipairs({ 5, 6 }) do
  local component = endpoint == 5 and "main" or "water"
  for _, mapping in ipairs(build_thermostat("unused", {
    endpoint = endpoint,
    component = component,
  }).zcl_clusters) do
    hive_dual_thermostat.zcl_clusters[#hive_dual_thermostat.zcl_clusters + 1] = mapping
  end
end

register_device_definition(thermostat_battery, {
  device_helpers.create_fingerprint("Eurotronic", "SPZB0001"),
})

register_device_definition(thermostat_battery, {
  device_helpers.create_fingerprint("Danfoss", "0x0042"),
  device_helpers.create_fingerprint("Danfoss", "0x0200"),
  device_helpers.create_fingerprint("Danfoss", "0x0210"),
  device_helpers.create_fingerprint("Danfoss", "0x0211"),
  device_helpers.create_fingerprint("Danfoss", "0x8020"),
  device_helpers.create_fingerprint("Danfoss", "0x8021"),
  device_helpers.create_fingerprint("Danfoss", "0x8030"),
  device_helpers.create_fingerprint("Danfoss", "0x8031"),
  device_helpers.create_fingerprint("Danfoss", "0x8034"),
  device_helpers.create_fingerprint("Danfoss", "0x8035"),
  device_helpers.create_fingerprint("Danfoss", "0x8040"),
  device_helpers.create_fingerprint("Danfoss", "0x8041"),
})

register_device_definition(centralite_thermostat, {
  device_helpers.create_fingerprint("Centralite", "3157100"),
  device_helpers.create_fingerprint("Centralite", "3157100-E"),
})

register_device_definition(thermostat, {
  device_helpers.create_fingerprint("Danfoss", "devi_f"),
  device_helpers.create_fingerprint("Sinopé", "TH1320ZB-04"),
  device_helpers.create_fingerprint("computime", "PUMM01102"),
})

register_device_definition(schneider_room_thermostat, {
  device_helpers.create_fingerprint("Schneider Electric", "Thermostat"),
})

register_device_definition(ecozy_thermostat, {
  device_helpers.create_fingerprint("eCozy", "Thermostat"),
})

register_device_definition(schneider_heating_thermostat, {
  device_helpers.create_fingerprint("Schneider Electric", "CCTFR6700"),
  device_helpers.create_fingerprint("Schneider Electric", "CCTFR6710"),
})

register_device_definition(namron_edge_thermostat, {
  device_helpers.create_fingerprint("Namron", "4566702"),
  device_helpers.create_fingerprint("Namron", "4566703"),
  device_helpers.create_fingerprint("Namron", "4512783"),
  device_helpers.create_fingerprint("Namron", "4512784"),
})

register_device_definition(hive_dual_thermostat, {
  device_helpers.create_fingerprint("Hive", "SLR2d"),
})

register_device_definition(salus_fcu_thermostat, {
  device_helpers.create_fingerprint("Salus Controls", "FC600NH"),
})

return device_definitions
