local zcl = require "protocol.zcl"
local types = require "st.zigbee.data_types"
local cluster_base = require "st.zigbee.cluster_base"
local M = {}
local STATES, CORRECTION = "__nous_b4z_moves", "__nous_b4z_position"
local function affected(device)
  return device:get_manufacturer() == "_TZ3000_yruungrl" and device:get_model() == "TS130F"
end

function M.apply(definition)
  for _, mapping in ipairs(definition.zcl_clusters) do
    if mapping.name == "cover_position" or mapping.name == "window_shade_state" then
      local original = mapping.from_device or (mapping.converter and mapping.converter.from)
      mapping.from_device = function(value, device, context, current)
        local correction = affected(device) and device:get_field(CORRECTION)
        if correction and correction.endpoint == context.endpoint then value = correction.value end
        if original then return original(value, device, context, current) end
        return value
      end
    end
    if mapping.name == "cover_position" then
      local sender = mapping.sender or zcl.get_sender(mapping.cluster_id, mapping.attribute_id)
      mapping.sender = function(device, current, value, context)
        if affected(device) and type(value) == "number" then
          local previous = device:get_latest_state("main", "windowShadeLevel", "shadeLevel")
          if type(previous) == "number" then
            local states = device:get_field(STATES) or {}
            states[context.endpoint] = {start = previous, target = value}
            device:set_field(STATES, states, {persist = false})
          end
        end
        return sender(device, current, value, context)
      end
    end
  end
  definition.zigbee_message_handler = function(device, rx)
    if not affected(device) then return end
    device:set_field(CORRECTION, nil, {persist = false})
    local header = rx.body.zcl_header
    if rx.address_header.cluster.value ~= 0x0102 or not header
        or (header.cmd.value ~= 0x0A and header.cmd.value ~= 0x01)
        or header.frame_ctrl:is_cluster_specific_set() then return end
    local position, moving
    for _, record in ipairs(rx.body.zcl_body.attr_records or {}) do
      if record.data then
        if record.attr_id.value == 8 then position = record.data.value end
        if record.attr_id.value == 0xF000 then moving = record.data.value end
      end
    end
    if type(position) ~= "number" or position < 0 or position > 100 or moving == nil then return end
    local endpoint = rx.address_header.src_endpoint.value
    local states = device:get_field(STATES) or {}
    local previous = states[endpoint]
    if moving ~= 1 then
      if not previous or previous.target == nil or position == previous.target then
        states[endpoint] = {
          start = previous and previous.start or device:get_latest_state("main", "windowShadeLevel", "shadeLevel"),
          target = previous and previous.target, position = position,
        }
      end
    else
      states[endpoint] = nil
      if previous and type(previous.position) == "number"
          and position == previous.start and position ~= previous.position then
        device:set_field(CORRECTION, {endpoint = endpoint, value = previous.position}, {persist = false})
        local request = cluster_base.write_attribute(device, types.ClusterId(0x0102), types.AttributeId(8), types.Uint8(previous.position))
        pcall(device.send, device, request:to_endpoint(endpoint))
      end
    end
    device:set_field(STATES, states, {persist = false})
  end
end

return M
