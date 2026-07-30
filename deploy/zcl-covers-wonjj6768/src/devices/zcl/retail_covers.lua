local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local device_definitions, register_device_definition = device_helpers.definition_registry()
local function standard_cover_position_converter()
return {
from = function(value)
if type(value) ~= "number" then
return value
end
return 100 - math.max(0, math.min(100, value))
end,
to = function(value)
if type(value) ~= "number" then
return value
end
return 100 - math.max(0, math.min(100, value))
end,
}
end
local function standard_window_shade_state_converter()
return {
from = function(value)
if type(value) ~= "number" then
return value
end
if value <= 0 then
return "open"
end
if value >= 100 then
return "closed"
end
return "partially open"
end,
}
end
local cover = {
profile = "covers-cover",
zcl_clusters = {
zcl.cover_position(),
zcl.window_shade_state(),
zcl.cover_state(),
},
}
local cover_battery = {
profile = "covers-cover-battery",
zcl_clusters = {
zcl.cover_position({ converter = standard_cover_position_converter() }),
zcl.window_shade_state({ converter = standard_window_shade_state_converter() }),
zcl.cover_state(),
zcl.battery(),
},
}
register_device_definition({
profile = "covers-cover-battery",
zcl_clusters = {
zcl.cover_position(),
zcl.window_shade_state(),
zcl.cover_state(),
zcl.battery(),
},
}, {
device_helpers.create_fingerprint("eWeLink", "AM25C-1-25-ES-E-Z"),
device_helpers.create_fingerprint("eWeLink", "CK-MG22-Z310EE07DOOYA-01(7015)"),
device_helpers.create_fingerprint("eWeLink", "MYDY25Z-1"),
device_helpers.create_fingerprint("eWeLink", "ZM25-EAZ"),
})
register_device_definition(cover, {
device_helpers.create_fingerprint("Sunricher", "HK-ZCC-A"),
})
register_device_definition(cover_battery, {
device_helpers.create_fingerprint("Third Reality, Inc", "TRZB3"),
})
register_device_definition(cover_battery, {
device_helpers.create_fingerprint("Third Reality, Inc", "3RSB015BZ"),
device_helpers.create_fingerprint("Third Reality, Inc", "3RSB02015Z"),
})
return device_definitions
