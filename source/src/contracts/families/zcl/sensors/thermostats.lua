local zcl = require "protocol.zcl"
local device_helpers = require "contracts.helpers.family"
local fp = device_helpers.create_fingerprint
local capabilities = require "st.capabilities"

local device_definitions, register = device_helpers.definition_registry()

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
local salus_fcu_thermostat = build_thermostat("thermostats-fcu-thermostat", { endpoint = 9, component = "main", fan = true })
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

register(thermostat_battery, {
  fp("Eurotronic", "SPZB0001"),
})

register(thermostat_battery, {
  fp("Danfoss", "0x0042"),
  fp("Danfoss", "0x0200"),
  fp("Danfoss", "0x0210"),
  fp("Danfoss", "0x0211"),
  fp("Danfoss", "0x8020"),
  fp("Danfoss", "0x8021"),
  fp("Danfoss", "0x8030"),
  fp("Danfoss", "0x8031"),
  fp("Danfoss", "0x8034"),
  fp("Danfoss", "0x8035"),
  fp("Danfoss", "0x8040"),
  fp("Danfoss", "0x8041"),
})

register(centralite_thermostat, {
  fp("Centralite", "3157100"),
  fp("Centralite", "3157100-E"),
})

register(thermostat, {
  fp("Danfoss", "devi_f"),
  fp("Sinopé", "TH1320ZB-04"),
  fp("computime", "PUMM01102"),
})

register(schneider_room_thermostat, {
  fp("Schneider Electric", "Thermostat"),
})

register(ecozy_thermostat, {
  fp("eCozy", "Thermostat"),
})

register(schneider_heating_thermostat, {
  fp("Schneider Electric", "CCTFR6700"),
  fp("Schneider Electric", "CCTFR6710"),
})

register(namron_edge_thermostat, {
  fp("Namron", "4566702"),
  fp("Namron", "4566703"),
  fp("Namron", "4512783"),
  fp("Namron", "4512784"),
})

register(hive_dual_thermostat, {
  fp("Hive", "SLR2d"),
})

register(salus_fcu_thermostat, {
  fp("Salus Controls", "FC600NH"),
})

-- ZCL REPORTING CAPABILITIES BEGIN
zcl.attach_reporting_capabilities(device_definitions, {
  {1, "rpt-sxb"},
  {2, "rpt-sxb"},
  {3, "rpt-zjo"},
  {4, "rpt-dsh"},
  {5, "rpt-tza"},
  {6, "rpt-tpd"},
  {7, "rpt-cfc"},
  {8, "rpt-zdh"},
  {9, "rpt-suw", {zr020100005 = "LocalTemp", zr020100006 = "LocalTempTwo", zr020100125 = "HeatSet", zr020100126 = "HeatSetTwo", zr0201001c5 = "Mode", zr0201001c6 = "ModeTwo", zr020100295 = "State", zr020100296 = "StateTwo"}},
  {10, "rpt-fsr"},
})
-- ZCL REPORTING CAPABILITIES END

return {
  id = "zcl.sensors.thermostats",
  registrations = device_definitions,
}
