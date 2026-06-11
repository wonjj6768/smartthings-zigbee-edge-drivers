local component_mapping = {}

local function normalize_endpoint_value(endpoint)
  if type(endpoint) == "table" then
    endpoint = endpoint[1]
  end

  if type(endpoint) ~= "number" or endpoint % 1 ~= 0 or endpoint < 1 then
    return nil
  end

  return endpoint
end

local function sorted_profile_component_ids(device)
  local component_ids = {}
  local seen = {}

  if device and device.profile and type(device.profile.components) == "table" then
    for component_id, _ in pairs(device.profile.components) do
      if type(component_id) == "string" and component_id ~= "" and not seen[component_id] then
        seen[component_id] = true
        component_ids[#component_ids + 1] = component_id
      end
    end
  end

  table.sort(component_ids, function(left, right)
    if left == "main" then
      return right ~= "main"
    end

    if right == "main" then
      return false
    end

    return left < right
  end)

  return component_ids
end

local function sorted_device_endpoints(device)
  local endpoints = {}
  local seen = {}

  if device and type(device.zigbee_endpoints) == "table" then
    for key, endpoint_data in pairs(device.zigbee_endpoints) do
      local endpoint = normalize_endpoint_value(key)
      if endpoint == nil and type(endpoint_data) == "table" then
        endpoint = normalize_endpoint_value(endpoint_data.id)
      end

      if endpoint ~= nil and not seen[endpoint] then
        seen[endpoint] = true
        endpoints[#endpoints + 1] = endpoint
      end
    end
  end

  if not seen[1] then
    endpoints[#endpoints + 1] = 1
  end

  table.sort(endpoints)
  return endpoints
end

local function assign_component_mapping(endpoint_to_component, component_to_endpoint, endpoint, component_id)
  endpoint = normalize_endpoint_value(endpoint)
  if endpoint == nil or type(component_id) ~= "string" or component_id == "" then
    return false
  end

  endpoint_to_component[endpoint] = component_id
  component_to_endpoint[component_id] = endpoint
  return true
end

local function derive_maps_from_component_fn(device, component_fn, endpoint_to_component, component_to_endpoint)
  if type(component_fn) ~= "function" then
    return
  end

  for _, component_id in ipairs(sorted_profile_component_ids(device)) do
    local endpoint = normalize_endpoint_value(component_fn(device, component_id))
    if endpoint ~= nil then
      assign_component_mapping(endpoint_to_component, component_to_endpoint, endpoint, component_id)
    end
  end
end

local function derive_maps_from_endpoint_fn(device, endpoint_fn, endpoint_to_component, component_to_endpoint)
  if type(endpoint_fn) ~= "function" then
    return
  end

  for _, endpoint in ipairs(sorted_device_endpoints(device)) do
    local component_id = endpoint_fn(device, endpoint)
    if type(component_id) == "string" and component_id ~= "" then
      assign_component_mapping(endpoint_to_component, component_to_endpoint, endpoint, component_id)
    end
  end
end

local function build_component_maps(device, definition, explicit_component_fn, explicit_endpoint_fn)
  local explicit_endpoint_map = type(definition) == "table" and definition.component_map or nil
  local explicit_component_map = type(definition) == "table" and definition.component_to_endpoint_map or nil
  local explicit_endpoint_to_component_map = type(definition) == "table" and definition.endpoint_to_component_map or nil
  local endpoint_to_component = {}
  local component_to_endpoint = {}

  if type(explicit_endpoint_map) == "table" then
    for endpoint, component_id in pairs(explicit_endpoint_map) do
      assign_component_mapping(endpoint_to_component, component_to_endpoint, endpoint, component_id)
    end
  end

  if type(explicit_component_map) == "table" then
    for component_id, endpoint in pairs(explicit_component_map) do
      assign_component_mapping(endpoint_to_component, component_to_endpoint, endpoint, component_id)
    end
  end

  if type(explicit_endpoint_to_component_map) == "table" then
    for endpoint, component_id in pairs(explicit_endpoint_to_component_map) do
      assign_component_mapping(endpoint_to_component, component_to_endpoint, endpoint, component_id)
    end
  end

  derive_maps_from_component_fn(device, explicit_component_fn, endpoint_to_component, component_to_endpoint)
  derive_maps_from_endpoint_fn(device, explicit_endpoint_fn, endpoint_to_component, component_to_endpoint)

  local remaining_components = {}
  for _, component_id in ipairs(sorted_profile_component_ids(device)) do
    if component_to_endpoint[component_id] == nil then
      local endpoint = nil
      if component_id == "main" then
        endpoint = endpoint_to_component[1] == nil and 1 or nil
      else
        endpoint = normalize_endpoint_value(tonumber(component_id:match("(%d+)$")))
        if endpoint ~= nil and endpoint_to_component[endpoint] ~= nil then
          endpoint = nil
        end
      end

      if endpoint ~= nil then
        assign_component_mapping(endpoint_to_component, component_to_endpoint, endpoint, component_id)
      else
        remaining_components[#remaining_components + 1] = component_id
      end
    end
  end

  local remaining_endpoints = {}
  for _, endpoint in ipairs(sorted_device_endpoints(device)) do
    if endpoint_to_component[endpoint] == nil then
      remaining_endpoints[#remaining_endpoints + 1] = endpoint
    end
  end

  for index, component_id in ipairs(remaining_components) do
    local endpoint = remaining_endpoints[index]
    if endpoint == nil then
      break
    end

    assign_component_mapping(endpoint_to_component, component_to_endpoint, endpoint, component_id)
  end

  if component_to_endpoint.main == nil and endpoint_to_component[1] == nil then
    assign_component_mapping(endpoint_to_component, component_to_endpoint, 1, "main")
  elseif endpoint_to_component[1] == nil then
    endpoint_to_component[1] = "main"
  end

  return endpoint_to_component, component_to_endpoint
end

function component_mapping.sorted_profile_component_ids(device)
  return sorted_profile_component_ids(device)
end

function component_mapping.apply(device, definition)
  local explicit_component_to_endpoint = type(definition) == "table" and definition.component_to_endpoint or nil
  local explicit_endpoint_to_component = type(definition) == "table" and definition.endpoint_to_component or nil
  local component_fn = type(explicit_component_to_endpoint) == "function" and explicit_component_to_endpoint or nil
  local endpoint_fn = type(explicit_endpoint_to_component) == "function" and explicit_endpoint_to_component or nil
  local endpoint_to_component, component_to_endpoint = build_component_maps(device, definition, component_fn, endpoint_fn)

  if component_fn ~= nil then
    device:set_component_to_endpoint_fn(function(current_device, component_id)
      local endpoint = normalize_endpoint_value(component_fn(current_device, component_id))
      if endpoint ~= nil then
        return endpoint
      end

      endpoint = component_to_endpoint[component_id] or 1
      return endpoint
    end)
  else
    device:set_component_to_endpoint_fn(function(_, component_id)
      local endpoint = component_to_endpoint[component_id] or 1
      return endpoint
    end)
  end

  if endpoint_fn ~= nil then
    device:set_endpoint_to_component_fn(function(current_device, endpoint)
      local component_id = endpoint_fn(current_device, endpoint)
      if type(component_id) == "string" and component_id ~= "" then
        return component_id
      end

      return endpoint_to_component[endpoint] or "main"
    end)
  else
    device:set_endpoint_to_component_fn(function(_, endpoint)
      return endpoint_to_component[endpoint] or "main"
    end)
  end
end

return component_mapping
