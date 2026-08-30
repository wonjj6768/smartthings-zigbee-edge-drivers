-- Shared only by the EF00 switch-basic and switch-panel package catalogs.
local tuya = require "protocol.tuya"

return {
  panel_off_on_converter = tuya.converter.lookup_from_to({ off = false, on = true }),
}
