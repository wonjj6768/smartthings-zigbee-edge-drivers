local entries = require "devices.ef00.motion.presence"
local include = {
[1] = true,
[2] = true,
[3] = true,
[4] = true,
[5] = true,
[6] = true,
[7] = true,
[8] = true,
[9] = true,
[10] = true,
[11] = true,
[12] = true,
[13] = true,
[14] = true,
[15] = true,
[16] = true,
[17] = true,
[18] = true,
[19] = true,
[20] = true,
[21] = true,
[22] = true,
[23] = true,
[24] = true,
[25] = true,
[26] = true,
[45] = true,
[46] = true,
[47] = true,
[48] = true,
[49] = true,
[50] = true,
[51] = true,
[52] = true,
[53] = true,
[54] = true,
}
local out = {}
for index, entry in ipairs(entries) do
if include[index] then
out[#out + 1] = entry
end
end
return out
