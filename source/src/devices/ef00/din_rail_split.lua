-- Splits the DIN rail registrations into two deploy modules.
--
-- `din_rail.lua` shares fault-bitmap and phase converters across every family,
-- so the file stays whole and the loaded entries are partitioned instead.  The
-- natural boundary is the profile prefix: switching breakers use
-- `din-rail-switch-*` while pure meters use `meters-*`.
local entries = require "devices.ef00.din_rail"

local function entry_profile(entry)
  local definition = entry.definition or entry
  return definition.profile
end

local function select_entries(want_meters)
  local out = {}
  for _, entry in ipairs(entries) do
    local profile = entry_profile(entry) or ""
    local is_meter = profile:sub(1, 7) == "meters-"
    if is_meter == want_meters then
      out[#out + 1] = entry
    end
  end
  return out
end

return {
  select_entries = select_entries,
}
