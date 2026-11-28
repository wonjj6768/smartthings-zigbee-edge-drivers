local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local types = require "st.zigbee.data_types"

local function apply(registrations)
  for _, entry in ipairs(registrations) do
    local fp = entry.fingerprints[1]
    if fp.model == "TS1101" or fp.model == "TS0052" or
        fp.manufacturer == "_TYZB01_qezuin6k" or fp.manufacturer == "_TYZB01_v8gtiaed" then
      for i, mapping in ipairs(entry.zcl_clusters) do
        if mapping.name == "min_brightness" then
          entry.zcl_clusters[i] = zcl.cluster_attribute(8, 0xFC00, {
            name = "min_brightness", endpoint = mapping.endpoint, component = mapping.component,
            data_type = types.Uint16, write_type = types.Uint16, read_on_configure = true,
            emit = emit.minimumBrightnessTsOneTenMax(),
            numeric_range = {minimum = 1, maximum = 255, step = 1},
            from_device = function(value) return math.floor(value / 256) % 256 end,
            to_device = function(value)
              if type(value) ~= "number" or value % 1 ~= 0 or value < 1 or value > 255 then return nil end
              return value * 256 + 255
            end,
          })
        end
      end
    end
  end
end

return {apply = apply}
