local module_loader = require "devices.shared.module_loader"

return module_loader.load_modules({
  "devices.ef00.thermostats.trv",
  "devices.ef00.thermostats.wall",
  "devices.ef00.thermostats.fcu",
  "devices.ef00.thermostats.legacy",
})
