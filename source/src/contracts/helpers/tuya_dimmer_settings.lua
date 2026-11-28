local zcl = require "protocol.zcl"
local types = require "st.zigbee.data_types"
local cluster_base = require "st.zigbee.cluster_base"

local function sender(device, mapping, value, context)
  local raw = mapping.to_device(value)
  if raw == nil then return false end
  device:send(cluster_base.write_attribute(device, types.ClusterId(0xE001),
    types.AttributeId(mapping.attribute_id), types.Enum8(raw)):to_endpoint(context.endpoint or 1))
  return true
end

local function apply(registrations)
  for _, entry in ipairs(registrations) do
    local first = entry.fingerprints[1]
    if first.model == "TS0052" or
      (first.manufacturer == "_TZ3000_j0ktmul1" and first.model == "TS011F") then
      for i, mapping in ipairs(entry.zcl_clusters) do
        local name = mapping.name
        if name == "power_on_behavior" or name == "switch_type" then
          local lookup = name == "power_on_behavior" and {[0] = "off", "on", "previous"}
            or {[0] = "toggle", "state", "momentary"}
          local reverse = {}
          for raw, state in pairs(lookup) do reverse[state] = raw end
          entry.zcl_clusters[i] = zcl.cluster_attribute(0xE001, name == "power_on_behavior" and 0xD010 or 0xD030, {
            name = name, endpoint = mapping.endpoint, component = mapping.component, emit = mapping.emit,
            data_type = types.Enum8, write_type = types.Enum8, read_on_configure = true,
            from_device = function(value) return lookup[value] end,
            to_device = function(value) return reverse[value] end,
            sender = sender,
          })
        end
      end
    end
  end
end

return {apply = apply}
