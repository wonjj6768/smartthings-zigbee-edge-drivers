local module_loader = require "devices.shared.module_loader"
return module_loader.load_modules({
"devices.ef00.sensors.temp_humidity",
"devices.ef00.sensors.soil",
"devices.ef00.sensors.air_quality",
"devices.ef00.sensors.liquid_level",
"devices.ef00.sensors.illuminance",
})
