local a={}
function a.start_runtime(...)return false end
function a.emit_power_polling_state(...)return false end
function a.set_power_poll_interval(...)return false end
function a.begin_power_poll_burst(...)return false end
require"zcl_common.generated_helper"(a)require"zcl_common.cluster_mapping"(a)require"zcl_common.mapping_preset"(a)require"zcl_common.component_helper"(a)require"zcl_common.runtime"(a)
function a.handle_internal_attribute(...)return false end
require"zcl_common.attribute_handler"(a)require"zcl_common.command_sender"(a)require"zcl_common.cluster_command_handler"(a)require"zcl_common.configuration"(a)return a
