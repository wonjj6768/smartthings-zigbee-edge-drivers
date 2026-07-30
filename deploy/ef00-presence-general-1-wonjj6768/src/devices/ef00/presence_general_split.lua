local entries = require "devices.ef00.presence_general"
local SECOND_GROUP_PREFIXES = {
"safety-presence-zg204z",
"safety-presence-zym100",
"safety-presence-zy-hps01",
"safety-presence-zis01p",
"safety-presence-zf24",
"safety-presence-zd24",
}
local function entry_profile(entry)
local definition = entry.definition or entry
return definition.profile or ""
end
local function in_second_group(profile)
for _, prefix in ipairs(SECOND_GROUP_PREFIXES) do
if profile:sub(1, #prefix) == prefix then
return true
end
end
return false
end
local function select_entries(want_second)
local out = {}
for _, entry in ipairs(entries) do
if in_second_group(entry_profile(entry)) == want_second then
out[#out + 1] = entry
end
end
return out
end
return {
select_entries = select_entries,
}
