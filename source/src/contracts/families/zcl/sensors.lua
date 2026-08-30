local general = require "contracts.families.zcl.sensors.general"
local safety = require "contracts.families.zcl.sensors.safety"
local sirens = require "contracts.families.zcl.sensors.sirens"
local repeaters = require "contracts.families.zcl.sensors.repeaters"
local thermostats = require "contracts.families.zcl.sensors.thermostats"
local retail_sensors = require "contracts.families.zcl.sensors.retail_sensors"
local aqara_lumi = require "contracts.families.zcl.sensors.aqara_lumi"
local shelly_retail = require "contracts.families.zcl.sensors.shelly_retail"

local catalogs = {
  general,
  safety,
  sirens,
  repeaters,
  thermostats,
  retail_sensors,
  aqara_lumi,
  shelly_retail,
}

local registrations = {}
for _, catalog in ipairs(catalogs) do
  for _, registration in ipairs(catalog.registrations) do
    registrations[#registrations + 1] = registration
  end
end

return {
  id = "zcl.sensors",
  registrations = registrations,
}
