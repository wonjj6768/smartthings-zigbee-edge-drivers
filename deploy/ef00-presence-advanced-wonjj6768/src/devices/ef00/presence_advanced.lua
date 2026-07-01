local entries = require "devices.ef00.motion.presence"
local include = {
[31] = true,
[32] = true,
[33] = true,
[34] = true,
[35] = true,
[36] = true,
[37] = true,
[38] = true,
[39] = true,
[40] = true,
[41] = true,
[42] = true,
[43] = true,
[44] = true,
}
local out = {}
for index, entry in ipairs(entries) do
if include[index] then
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
