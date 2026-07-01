local entries = require "devices.ef00.motion.presence"
local include = {
[27] = true,
[28] = true,
[29] = true,
[30] = true,
}
local out = {}
for index, entry in ipairs(entries) do
if include[index] then
out[#out + 1] = entry
end
end
return out
