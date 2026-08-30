local switches = require "contracts.families.zcl.switches.switches"
local din_rail = require "contracts.families.zcl.switches.din_rail"
local valves = require "contracts.families.zcl.switches.valves"
local retail_switches = require "contracts.families.zcl.switches.retail_switches"
local easyiot = require "contracts.families.zcl.switches.easyiot"


local catalogs = {
  switches,
  din_rail,
  valves,
  retail_switches,
  easyiot,

}

local registrations = {}

for _, catalog in ipairs(catalogs) do
  for _, registration in ipairs(catalog.registrations) do
    registrations[#registrations + 1] = registration
  end
end

return {
  id = "zcl.switches",
  registrations = registrations,
}
