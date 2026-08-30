-- Wave19 Sunricher SR-2421-Z2D8C dynamic DALI endpoint candidate.
-- Frozen Zigbee2MQTT v26.99.0: src/devices/sunricher.ts:23-28,270-354,2070-2084.

local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local capabilities = require "st.capabilities"
local device_management = require "st.zigbee.device_management"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local DIMMABLE_DEVICE_ID = 0x0101
local COLOR_TEMPERATURE_DEVICE_ID = 0x010C
local FIRST_ENDPOINT = 1
local LAST_ENDPOINT = 8
local DIMMER_CHILD_PROFILE = "bridge-wave19-sunricher-dali-dimmer-child"
local CCT_CHILD_PROFILE = "bridge-wave19-sunricher-dali-cct-child"

local function child_key(endpoint)
  return string.format("%02X", endpoint)
end

local function child_endpoint(device)
  local key = device and device.parent_assigned_child_key
  if type(key) ~= "string" or key:match("^%x%x$") == nil then return nil end
  local endpoint = tonumber(key, 16)
  if endpoint == nil or endpoint < FIRST_ENDPOINT or endpoint > LAST_ENDPOINT then
    return nil
  end
  return endpoint
end

local function endpoint_descriptor(device, endpoint)
  return device and device.zigbee_endpoints and device.zigbee_endpoints[endpoint] or nil
end

local function endpoint_device_id(device, endpoint)
  local descriptor = endpoint_descriptor(device, endpoint)
  return descriptor and descriptor.device_id or nil
end

local function enabled_endpoint(device, endpoint)
  local device_id = endpoint_device_id(device, endpoint)
  return device_id == DIMMABLE_DEVICE_ID or device_id == COLOR_TEMPERATURE_DEVICE_ID
end

local function child_profile(device, endpoint)
  if endpoint_device_id(device, endpoint) == COLOR_TEMPERATURE_DEVICE_ID then
    return CCT_CHILD_PROFILE
  end
  return DIMMER_CHILD_PROFILE
end

local function emit_on_child(endpoint, event_factory, required_device_id)
  local key = child_key(endpoint)
  return function(device, value, context, mapping)
    local device_id = endpoint_device_id(device, endpoint)
    if not enabled_endpoint(device, endpoint) or
        (required_device_id ~= nil and device_id ~= required_device_id) then
      return nil
    end
    local child = device:get_child_by_parent_assigned_key(key)
    if child == nil then return nil end
    local event = event_factory(child, value, context, mapping)
    if event ~= nil then child:emit_event(event) end
    return nil
  end
end

local function create_child_devices(driver, device)
  if type(device.zigbee_endpoints) ~= "table" then return end

  for endpoint = FIRST_ENDPOINT, LAST_ENDPOINT do
    local key = child_key(endpoint)
    local child = device:get_child_by_parent_assigned_key(key)
    if enabled_endpoint(device, endpoint) then
      local profile = child_profile(device, endpoint)
      if child ~= nil then
        if child.profile == nil or child.profile.id ~= profile then
          child:try_update_metadata({ profile = profile })
        end
      else
        driver:try_create_device({
          type = "EDGE_CHILD",
          parent_assigned_child_key = key,
          parent_device_id = device.id,
          label = string.format("%s DALI %d", device.label, endpoint),
          profile = profile,
        })
      end
    elseif child ~= nil and type(driver.try_delete_device) == "function" then
      driver:try_delete_device(child.id)
    end
  end
end

local function is_expected_child(parent, device)
  local endpoint = child_endpoint(device)
  if endpoint == nil or not enabled_endpoint(parent, endpoint) then return false end
  local expected_profile = child_profile(parent, endpoint)
  if device.profile == nil then return false end
  if device.profile.id ~= expected_profile then
    device:try_update_metadata({ profile = expected_profile })
  end
  return true
end

local function child_runtime_start(device, _, parent)
  local endpoint = child_endpoint(device)
  if endpoint == nil or endpoint_device_id(parent, endpoint) ~= COLOR_TEMPERATURE_DEVICE_ID then
    return
  end
  device:emit_component_event(
    { id = "main" },
    capabilities.colorTemperature.colorTemperatureRange({
      value = { minimum = 2000, maximum = 6667 },
      unit = "K",
    })
  )
end

local function child_parent(device)
  if type(device) ~= "table" or type(device.get_parent_device) ~= "function" then
    return nil
  end
  return device:get_parent_device()
end

local function read_initial_state(device, endpoint, color_temperature)
  zcl.read_attribute(device, 0x0006, 0x0000, endpoint)
  zcl.read_attribute(device, 0x0008, 0x0000, endpoint)
  if color_temperature then
    zcl.read_attribute(device, 0x0300, 0x0008, endpoint)
    zcl.read_attribute(device, 0x0300, 0x0007, endpoint)
  end
end

local function child_refresh(device)
  local parent = child_parent(device)
  local endpoint = child_endpoint(device)
  if endpoint == nil or not enabled_endpoint(parent, endpoint) then return end
  read_initial_state(
    device,
    endpoint,
    endpoint_device_id(parent, endpoint) == COLOR_TEMPERATURE_DEVICE_ID
  )
end

local function parent_refresh(device)
  if type(device.zigbee_endpoints) ~= "table" then return end
  for endpoint = FIRST_ENDPOINT, LAST_ENDPOINT do
    if enabled_endpoint(device, endpoint) then
      read_initial_state(
        device,
        endpoint,
        endpoint_device_id(device, endpoint) == COLOR_TEMPERATURE_DEVICE_ID
      )
    end
  end
end

local function child_command_allowed(device, name)
  local parent = child_parent(device)
  local endpoint = child_endpoint(device)
  if endpoint == nil or not enabled_endpoint(parent, endpoint) then return false end
  if name == "switch" or name == "brightness" then return true end
  return name == "color_temperature" and
    endpoint_device_id(parent, endpoint) == COLOR_TEMPERATURE_DEVICE_ID
end

local function configure(driver, device)
  local hub_eui = driver.environment_info.hub_zigbee_eui
  for endpoint = FIRST_ENDPOINT, LAST_ENDPOINT do
    if enabled_endpoint(device, endpoint) then
      for _, cluster in ipairs({ 0x0006, 0x0008 }) do
        device:send(device_management.build_bind_request(device, cluster, hub_eui, endpoint))
      end
      local color_temperature =
        endpoint_device_id(device, endpoint) == COLOR_TEMPERATURE_DEVICE_ID
      if color_temperature then
        device:send(device_management.build_bind_request(device, 0x0300, hub_eui, endpoint))
      end
      read_initial_state(device, endpoint, color_temperature)
    end
  end
end

local mappings = {}
for endpoint = FIRST_ENDPOINT, LAST_ENDPOINT do
  mappings[#mappings + 1] = zcl.switch({
    endpoint = endpoint,
    configure_reporting = false,
    emit = emit_on_child(endpoint, emit.switch()),
  })
  mappings[#mappings + 1] = zcl.level({
    endpoint = endpoint,
    configure_reporting = false,
    emit = emit_on_child(endpoint, emit.level()),
  })
  mappings[#mappings + 1] = zcl.color_temperature({
    endpoint = endpoint,
    configure_reporting = false,
    emit = emit_on_child(
      endpoint,
      emit.color_temperature(),
      COLOR_TEMPERATURE_DEVICE_ID
    ),
  })
end

local sunricher_dali = {
  profile = "bridge-wave19-sunricher-dali-parent",
  auxiliary_profiles = { DIMMER_CHILD_PROFILE, CCT_CHILD_PROFILE },
  package_group = "wave19-dali",
  transport_classification = "STANDARD_ZCL_DYNAMIC_ENDPOINT_CHILDREN",
  z2m_converter_source = "sunricherDaliController",
  wire_cluster = "OnOff 0x0006 + Level 0x0008 + optional ColorControl 0x0300",
  zcl_clusters = mappings,
  allow_child_devices = true,
  is_expected_child = is_expected_child,
  create_child_devices = create_child_devices,
  child_runtime_start = child_runtime_start,
  child_refresh = child_refresh,
  parent_refresh = parent_refresh,
  child_command_allowed = child_command_allowed,
  configure = configure,
}

register_device_definition(sunricher_dali, {
  device_helpers.create_fingerprint("Sunricher", "Light"),
})

return {
  id = "zcl.lights.wave19_dali",
  registrations = device_definitions,
}
