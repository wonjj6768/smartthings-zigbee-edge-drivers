-- Splits the general presence registrations into two deploy modules.
--
-- `presence_general.lua` already resolves its own include window by profile name,
-- so this reuses that resolved list and partitions it to stay under the platform
-- size limit.
--
-- The split is by size, not by device family: the second group happens to collect
-- the ZG-204Z, ZY-M100, ZF24, ZD24, ZIS-01P and ZY-HPS01 profiles because they
-- are the largest contiguous set, while a ZG-204ZX profile remains in the first
-- group.  Naming a package after one of those families would misrepresent it, so
-- the packages are numbered and the public README fingerprint tables are the
-- authoritative list of which device lands where.
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
