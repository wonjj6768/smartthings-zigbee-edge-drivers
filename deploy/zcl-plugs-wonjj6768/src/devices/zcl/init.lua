local module_loader = require "devices.shared.module_loader"
local modules = require "devices.zcl.modules"

return module_loader.load_modules(modules.all)
