local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local device_definitions, register_device_definition = device_helpers.definition_registry()
local switch_1 = {
profile = "switches-switch-1",
zcl_clusters = {
zcl.switch(),
},
}
local switch_4 = {
profile = "switches-switch-4",
zcl_clusters = zcl.multi_switch(4),
}
local switch_8 = {
profile = "switches-switch-8",
zcl_clusters = zcl.multi_switch(8),
}
local temp_humidity = {
profile = "sensors-temp-humidity-battery",
zcl_clusters = {
zcl.temperature(),
zcl.humidity(),
zcl.battery(),
},
}
register_device_definition(switch_1, {
device_helpers.create_fingerprint("easyiot", "ZB-SP1000"),
})
register_device_definition(switch_4, {
device_helpers.create_fingerprint("easyiot", "ZB-PSW04"),
})
register_device_definition(switch_8, {
device_helpers.create_fingerprint("easyiot", "ZB-SW08"),
})
register_device_definition(temp_humidity, {
device_helpers.create_fingerprint("easyiot", "ZB-TTS01"),
})
return device_definitions
