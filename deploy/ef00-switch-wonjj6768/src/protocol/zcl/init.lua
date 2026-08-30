local zcl=require "protocol.zcl.stub_base"()
require "zcl_common.generated_helper"(zcl)
require "zcl_common.cluster_mapping"(zcl)
require "zcl_common.mapping_preset"(zcl)
require "zcl_common.component_helper"(zcl)
require "zcl_common.runtime"(zcl)
function zcl.handle_internal_attribute(...)return false end
require "zcl_common.attribute_handler"(zcl)
require "zcl_common.command_sender"(zcl)
require "zcl_common.cluster_command_handler"(zcl)
require "zcl_common.configuration"(zcl)
return zcl
