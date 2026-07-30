-- Splits the TRV registrations into two deploy modules.
--
-- `trv.lua` shares a large block of mode/preset helpers across every family, so
-- the file itself is not split.  Instead the loaded entries are partitioned by
-- profile name so each deploy package stays under the platform size limit and
-- only carries the profiles its own entries reference.
--
-- The two groups are size partitions, not device families: `thermostats_trv_1`
-- and `thermostats_trv_2` both hold radiator valves.  The package names stay
-- neutral for that reason, and the per-driver fingerprint tables in the public
-- README are the authoritative list of which device lands where.
local entries = require "devices.ef00.thermostats.trv"

local SECOND_GROUP_PROFILES = {
  ["thermostats-thermostat-tv02"] = true,
  ["thermostats-thermostat-trv602z"] = true,
  ["thermostats-thermostat-battery-ar331pro"] = true,
  ["thermostats-thermostat-battery-ar331"] = true,
  ["thermostats-thermostat-tr-m3z"] = true,
  ["thermostats-thermostat-gtz10"] = true,
  ["thermostats-thermostat-trv14"] = true,
  ["thermostats-thermostat-trv4"] = true,
  ["thermostats-thermostat-s366"] = true,
  ["thermostats-thermostat-trv601"] = true,
  ["thermostats-thermostat-trv602"] = true,
}

local function entry_profile(entry)
  local definition = entry.definition or entry
  return definition.profile
end

local function select_entries(want_second)
  local out = {}
  for _, entry in ipairs(entries) do
    local in_second = SECOND_GROUP_PROFILES[entry_profile(entry)] == true
    if in_second == want_second then
      out[#out + 1] = entry
    end
  end
  return out
end

return {
  select_entries = select_entries,
}
