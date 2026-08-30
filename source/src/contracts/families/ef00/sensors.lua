local temp_humidity = require "contracts.families.ef00.sensors.temp_humidity"
local soil = require "contracts.families.ef00.sensors.soil"
local air_quality = require "contracts.families.ef00.sensors.air_quality"
local liquid_level = require "contracts.families.ef00.sensors.liquid_level"
local illuminance = require "contracts.families.ef00.sensors.illuminance"

local catalogs = {
  temp_humidity,
  soil,
  air_quality,
  liquid_level,
  illuminance,
}

local registrations = {}

for _, catalog in ipairs(catalogs) do
  for _, registration in ipairs(catalog.registrations) do
    registrations[#registrations + 1] = registration
  end
end

return {
  id = "ef00.sensors",
  registrations = registrations,
}
