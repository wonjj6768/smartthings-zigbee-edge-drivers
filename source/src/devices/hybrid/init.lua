local protocol_modules = {
  "devices.hybrid.switches",
  "devices.hybrid.sensors",
  "devices.hybrid.plugs",
  "devices.hybrid.covers",
  "devices.hybrid.lights",
  "devices.hybrid.thermostats",
}

local entries = {}

for _, module_name in ipairs(protocol_modules) do
  local module_entries = require(module_name)
  for _, entry in ipairs(module_entries) do
    entries[#entries + 1] = entry
  end
end

return entries
