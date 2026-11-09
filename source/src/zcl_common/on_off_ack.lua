local on_off_ack = {}
local FIELD = "__zcl_pending_on_off"

function on_off_ack.get(device, endpoint)
  if type(device.get_field) ~= "function" then return nil end
  local pending = device:get_field(FIELD)
  return pending and pending[endpoint] or nil
end

function on_off_ack.clear(device, endpoint)
  if endpoint == nil or type(device.get_field) ~= "function" then return end
  local pending = device:get_field(FIELD)
  if pending ~= nil then
    pending[endpoint] = nil
    device:set_field(FIELD, next(pending) and pending or nil, { persist = false })
  end
end

function on_off_ack.remember(device, on_off, context, request)
  if type(device.get_field) ~= "function" or type(device.set_field) ~= "function" then return end
  local mapping = context and context.mapping
  if mapping == nil or mapping.name ~= "switch" or mapping.write_only == true or mapping.mfg_code ~= nil then return end
  local address = request.address_header
  local endpoint = address and address.dest_endpoint and address.dest_endpoint.value or context.endpoint
  if endpoint == nil then return end
  local pending = device:get_field(FIELD) or {}
  pending[endpoint] = {
    mapping = mapping,
    command = on_off and 1 or 0,
    profile = address and address.profile and address.profile.value,
  }
  device:set_field(FIELD, pending, { persist = false })
end

return on_off_ack
