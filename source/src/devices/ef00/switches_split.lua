-- Splits the EF00 switch registrations into two deploy modules.
--
-- `switches.lua` shares the backlight colour, indicator and panel converters
-- across families, so the file stays whole and the loaded entries are
-- partitioned by profile name.  The panel-style families (touch panel, colored
-- backlight, ZTS-EU, ZS-TYG3-SM, scene and LCD panels) carry the large per-channel
-- capability sets, so they move to the second package.
local entries = require "devices.ef00.switches"

local SECOND_GROUP_MARKERS = {
  "touch-panel",
  "colored-backlight",
  "zts-eu",
  "tyg3-sm",
  "m9-sl",
  "f3-pro",
  "lcd-panel",
  "to6",
  "pn16",
  "adlblwab",
  "eyzee",
  "multifunction",
  "stairwell",
  "backlight-hewlydpz",
}

local function entry_profile(entry)
  local definition = entry.definition or entry
  return definition.profile or ""
end

local function in_second_group(profile)
  for _, marker in ipairs(SECOND_GROUP_MARKERS) do
    if profile:find(marker, 1, true) ~= nil then
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
