-- Receive/read/configure-only ZCL facade for EF00-owned hybrid packages.

local zcl = require "protocol.zcl.stub_base"()

require "zcl_common.generated_helper"(zcl)
require "zcl_common.cluster_mapping"(zcl)
require "zcl_common.mapping_preset"(zcl)
require "zcl_common.component_helper"(zcl)
require "zcl_common.runtime"(zcl)
function zcl.handle_internal_attribute(...) return false end
require "zcl_common.attribute_handler"(zcl)
require "zcl_common.attribute_reader"(zcl)

-- Preserve the caller-visible command API while keeping every TX/registry
-- route closed. command_sender.lua is intentionally not required.
function zcl.send_named_command(...) return false end
function zcl.send_raw_cluster_command(...) return false end
function zcl.register_sender(...) return nil end
function zcl.get_sender(...) return nil end

require "zcl_common.cluster_command_handler"(zcl)
require "zcl_common.configuration"(zcl)

return zcl
