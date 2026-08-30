local zcl = require "protocol.zcl"

-- Shared only by the legacy and Z2M physical catalogs for the one mixed
-- eWeLink 7019 registration.  Returning the singleton behavior table keeps
-- profile, mapping, handler, and table identity equal in a shared Lua state.
return {
  water_battery_low_battery_sensor = {
    profile = "safety-water-leak-battery-low-battery",
    zcl_clusters = {
      zcl.water(),
      zcl.battery_low(),
      zcl.battery(),
    },
  },
}
