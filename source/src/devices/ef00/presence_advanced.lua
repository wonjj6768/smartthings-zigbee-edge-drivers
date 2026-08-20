local entries = require "devices.ef00.motion.presence"

local out = {}
for _, entry in ipairs(entries) do
  if entry.package_group == "presence-advanced" then
    if type(entry.datapoints) == "table" and type(entry.datapoints.datapoints) == "table" then
      local normalized = {}
      for key, value in pairs(entry) do
        normalized[key] = value
      end
      normalized.datapoints = entry.datapoints.datapoints
      normalized.query_on_configure = entry.datapoints.query_on_configure
      out[#out + 1] = normalized
    else
      out[#out + 1] = entry
    end
  end
end

return out
