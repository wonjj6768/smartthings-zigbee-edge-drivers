local shared = require "tuya_common.core"

local tuya = {}
shared.apply_constants(tuya)

require "tuya_common.message_protocol"(tuya, shared)
require "tuya_common.converters"(tuya, shared)
require "tuya_common.policy_helper"(tuya, shared)
require "tuya_common.datapoint_factory"(tuya, shared)
require "tuya_common.datapoint_preset"(tuya, shared)
require "tuya_common.datapoint_mapping"(tuya, shared)
require "tuya_common.device_runtime"(tuya, shared)
require "tuya_common.base_preset"(tuya, shared)

return tuya
