local shared=require "tuya_common.foundation"
local internal={}
shared.apply_constants(internal)
require "tuya_common.converters"(internal,shared)
require "tuya_common.datapoint_factory"(internal,shared)
require "tuya_common.datapoint_preset"(internal,shared,nil)
return internal
