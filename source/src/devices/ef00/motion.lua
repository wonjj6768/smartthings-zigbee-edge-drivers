local module_loader = require "devices.shared.module_loader"

return module_loader.load_modules({
  "devices.ef00.motion.pir",
  "devices.ef00.motion.presence",
})
