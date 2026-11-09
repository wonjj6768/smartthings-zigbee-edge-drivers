local zcl = require "protocol.zcl"

local zcl_device_helpers = {}

function zcl_device_helpers.duplicate_transaction(device, endpoint, sequence, field)
  if sequence == nil then return false end
  local now = require("cosock.socket").gettime() * 1000
  local endpoints = device:get_field(field) or {}
  local entries, oldest, expiry = {}, nil, math.huge
  for _, entry in ipairs(endpoints[endpoint] or {}) do
    if entry[1] == sequence and entry[2] > now then return true end
    if entry[2] > now then
      entries[#entries + 1] = entry
      if entry[2] < expiry then oldest, expiry = #entries, entry[2] end
    end
  end
  if #entries > 4 then table.remove(entries, oldest) end
  entries[#entries + 1], endpoints[endpoint] = {sequence, now + 10000}, entries
  device:set_field(field, endpoints, {persist=false})
  return false
end

function zcl_device_helpers.passive(mapping)
  mapping.minimum_interval=nil
  mapping.maximum_interval=nil
  mapping.reportable_change=nil
  mapping.read_on_configure=false
  return mapping
end

function zcl_device_helpers.identify(device, value)
  if type(value) ~= "number" or value % 1 ~= 0 or value < 1 or value > 30 then return false end
  return zcl.send_raw_cluster_command(device, 3, 0, string.pack("<I2", value), device:get_endpoint(3))
end

local function append_cluster(clusters, cluster)
  if cluster ~= nil then
    clusters[#clusters + 1] = cluster
  end
end

function zcl_device_helpers.append_clusters(clusters, ...)
  for index = 1, select("#", ...) do
    local entry = select(index, ...)

    if type(entry) == "table" and entry[1] ~= nil then
      for _, cluster in ipairs(entry) do
        append_cluster(clusters, cluster)
      end
    else
      append_cluster(clusters, entry)
    end
  end

  return clusters
end

function zcl_device_helpers.metering_clusters(options)
  options = options or {}

  local endpoint = options.endpoint
  local include_switch = options.include_switch ~= false
  local include_current = options.include_current == true
  local power_poll = options.power_poll or 300
  local voltage_poll = options.voltage_poll or 300
  local current_poll = options.current_poll or 300
  local energy_poll = options.energy_poll or 900
  local energy_scale = options.energy_scale or 100

  local clusters = {}

  if include_switch then
    append_cluster(clusters, zcl.switch({
      endpoint = endpoint,
      component = options.switch_component,
    }))
  end

  append_cluster(clusters, zcl.power({
    endpoint = endpoint,
    poll_interval = power_poll,
  }))

  append_cluster(clusters, zcl.voltage({
    endpoint = endpoint,
    poll_interval = voltage_poll,
  }))

  if include_current then
    append_cluster(clusters, zcl.current({
      endpoint = endpoint,
      poll_interval = current_poll,
      use_reported_unity_scaler = options.use_reported_unity_scaler,
    }))
  end

  append_cluster(clusters, zcl.energy({
    endpoint = endpoint,
    scale = energy_scale,
    ignore_reported_scaler = options.energy_ignore_reported_scaler,
    use_reported_unity_scaler = options.use_reported_unity_scaler,
    poll_interval = energy_poll,
  }))

  return clusters
end

function zcl_device_helpers.switch_cluster(endpoint, component)
  if endpoint == nil and component == nil then
    return zcl.switch()
  end

  return zcl.switch({
    endpoint = endpoint,
    component = component,
  })
end

local function body_member_value(zb_rx, ...)
  local body = zb_rx and zb_rx.body and zb_rx.body.zcl_body or nil
  if type(body) ~= "table" then return nil end
  for _, key in ipairs({ ... }) do
    local value = body[key]
    if type(value) == "table" and value.value ~= nil then return value.value end
    if value ~= nil then return value end
  end
end

function zcl_device_helpers.resolve_rd1p_rotary_action(zb_rx, cluster_id, command_id, source_endpoint)
  if source_endpoint ~= 2 then return nil, nil, true end
  if cluster_id == zcl.CLUSTER_ON_OFF then
    return ({
      [0x00] = "double_pressed",
      [0x01] = "pressed",
      [0x02] = "held",
      [0x03] = "released",
    })[command_id], "main", true
  end
  if cluster_id == zcl.CLUSTER_LEVEL_CONTROL then
    if command_id == 0x03 then return "stopped_rotating", "main", true end
    local direction
    if command_id == 0x05 then
      direction = body_member_value(zb_rx, "move_mode", "movemode", "mode")
      if direction == 0 then return "started_rotating_right", "main", true end
      if direction == 1 then return "started_rotating_left", "main", true end
    elseif command_id == 0x06 then
      direction = body_member_value(zb_rx, "step_mode", "stepmode", "mode")
      if direction == 0 then return "rotating_right", "main", true end
      if direction == 1 then return "rotating_left", "main", true end
    end
  end
  return nil, nil, true
end

return zcl_device_helpers
