local entries = require "devices.ef00.motion.presence"

local out = {}
for _, entry in ipairs(entries) do
  if entry.package_group == "presence-switch" then
    out[#out + 1] = entry
  end
end

return out
