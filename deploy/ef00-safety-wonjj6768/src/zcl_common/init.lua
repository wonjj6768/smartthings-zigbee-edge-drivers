
local cluster_base = require "st.zigbee.cluster_base"
local data_types = require "st.zigbee.data_types"
local zcl = {}
zcl.CLUSTER_ON_OFF = 0x0006
zcl.CLUSTER_POWER_CONFIGURATION = 0x0001
zcl.ATTR_ON_OFF = 0x0000
zcl.ATTR_BATTERY_VOLTAGE = 0x0020
zcl.ATTR_BATTERY_PERCENTAGE_REMAINING = 0x0021
function zcl.cluster_attribute(cluster_id, attribute_id, options)
  local mapping = options or {}
  mapping.protocol = "zcl"
  mapping.cluster_id = cluster_id
  mapping.attribute_id = attribute_id
  return mapping
end
function zcl.switch(options)
  local mapping = zcl.cluster_attribute(zcl.CLUSTER_ON_OFF, zcl.ATTR_ON_OFF, options or {})
  if mapping.name == nil then mapping.name = "switch" end
  return mapping
end
function zcl.battery(options)
  local mapping = zcl.cluster_attribute(zcl.CLUSTER_POWER_CONFIGURATION, zcl.ATTR_BATTERY_PERCENTAGE_REMAINING, options or {})
  if mapping.name == nil then mapping.name = "battery" end
  return mapping
end
function zcl.register_attributes_from_mappings(value) return value end
function zcl.register_cluster_commands_from_mappings(value) return value end
function zcl.prepare_mappings(value) return value end
function zcl.has_cluster(...) return false end
function zcl.build_zigbee_cluster_handlers(_) return {} end
function zcl.build_zigbee_global_handlers(_) return {} end
function zcl.build_zigbee_attr_handlers(_) return {} end
function zcl.start_configuration(...) return false end
function zcl.start_runtime(...) return false end
function zcl.send_named_command(...) return false end
function zcl.read_named_attribute(...) return false end
function zcl.read_all_attributes(...) return false end
function zcl.read_attribute(device, cluster_id, attribute_id, endpoint)
  local request = cluster_base.read_attribute(device, data_types.ClusterId(cluster_id), data_types.AttributeId(attribute_id))
  if endpoint ~= nil and type(request.to_endpoint) == "function" then
    request = request:to_endpoint(endpoint)
  end
  device:send(request)
  return true
end
return zcl
