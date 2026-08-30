local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local cluster_base = require "st.zigbee.cluster_base"
local data_types = require "st.zigbee.data_types"

local shelly = {}

shelly.MANUFACTURER_CODE = 0x1490
shelly.PROFILE_ID = 0xC001
shelly.ENDPOINT = 239
shelly.RPC_CLUSTER = 0xFC01
shelly.WIFI_CLUSTER = 0xFC02
shelly.LIGHT_LEVEL_CLUSTER = 0xFC21

local FULL_WIFI_SSID_FIELD = "_shelly_gen4_full_wifi_ssid"

local WIFI_ATTRIBUTES = {
  status = { id = 0x0000, data_type = data_types.CharString },
  ip = { id = 0x0001, data_type = data_types.CharString },
  action_code = { id = 0x0002, data_type = data_types.Uint8 },
  dhcp = { id = 0x0003, data_type = data_types.Boolean },
  enabled = { id = 0x0004, data_type = data_types.Boolean },
  ssid = { id = 0x0005, data_type = data_types.CharString },
  password = { id = 0x0006, data_type = data_types.CharString },
  static_ip = { id = 0x0007, data_type = data_types.CharString },
  net_mask = { id = 0x0008, data_type = data_types.CharString },
  gateway = { id = 0x0009, data_type = data_types.CharString },
  name_server = { id = 0x000A, data_type = data_types.CharString },
}

local function custom_emit(name)
  return assert(emit[name], "missing custom capability emitter: " .. tostring(name))()
end

local function shelly_request(request, endpoint)
  endpoint = endpoint or shelly.ENDPOINT
  if type(request.to_endpoint) == "function" then
    request = request:to_endpoint(endpoint)
  end
  if request.address_header and request.address_header.profile then
    request.address_header.profile.value = shelly.PROFILE_ID
  end
  return request
end

local function send_request(device, request, endpoint)
  device:send(shelly_request(request, endpoint))
  return true
end

local function write_attribute(device, cluster_id, attribute_id, data_type, value, endpoint)
  return send_request(device, cluster_base.write_manufacturer_specific_attribute(
    device,
    cluster_id,
    attribute_id,
    shelly.MANUFACTURER_CODE,
    data_type,
    value
  ), endpoint)
end

local function read_attribute(device, cluster_id, attribute_id, endpoint)
  return send_request(device, cluster_base.read_manufacturer_specific_attribute(
    device,
    cluster_id,
    attribute_id,
    shelly.MANUFACTURER_CODE
  ), endpoint)
end

local function boolean_from_device(value)
  local enabled = value == true or value == 1
  return enabled and "true" or "false"
end

local function boolean_to_device(value)
  if value == "true" or value == true or value == 1 then return true end
  if value == "false" or value == false or value == 0 then return false end
  return nil
end

local function normalize_text(value)
  if type(value) ~= "string" or value == "" then return nil end
  return value
end

local function diagnostic_text_from_device(value)
  if type(value) ~= "string" then return nil end
  return value
end

local function get_known_full_wifi_ssid(device)
  if type(device) ~= "table" or type(device.get_field) ~= "function" then
    return nil
  end

  local value = device:get_field(FULL_WIFI_SSID_FIELD)
  return normalize_text(value)
end

local function cache_full_wifi_ssid(device, value)
  value = normalize_text(value)
  if value == nil or type(device) ~= "table" or type(device.set_field) ~= "function" then
    return false
  end

  if get_known_full_wifi_ssid(device) ~= value then
    device:set_field(FULL_WIFI_SSID_FIELD, value, { persist = true })
  end
  return true
end

local function wifi_ssid_from_device(value, device)
  local reported = normalize_text(value)
  if reported == nil then return nil end

  local known = get_known_full_wifi_ssid(device)
  if known ~= nil and known:sub(1, #reported) == reported then
    return known
  end

  if known == nil or #reported > #known then
    cache_full_wifi_ssid(device, reported)
  end
  return reported
end

local function wifi_sender(attribute, allow_empty)
  return function(device, _, value)
    local encoded = value
    if attribute.data_type == data_types.Boolean then
      encoded = boolean_to_device(value)
    elseif attribute.data_type == data_types.CharString then
      if type(value) ~= "string" or (value == "" and not allow_empty) then
        encoded = nil
      end
    end
    if encoded == nil then return false end

    write_attribute(device, shelly.WIFI_CLUSTER, attribute.id, attribute.data_type, encoded)
    write_attribute(device, shelly.WIFI_CLUSTER, WIFI_ATTRIBUTES.action_code.id, data_types.Uint8, 1)
    if attribute.id == WIFI_ATTRIBUTES.ssid.id then
      cache_full_wifi_ssid(device, encoded)
    end
    return true
  end
end

local function wifi_mapping(name, emit_name, attribute_name, writable, options)
  options = options or {}
  local attribute = assert(WIFI_ATTRIBUTES[attribute_name], "unknown Shelly Wi-Fi attribute: " .. tostring(attribute_name))
  local mapping = zcl.cluster_attribute(shelly.WIFI_CLUSTER, attribute.id, {
    name = name,
    endpoint = shelly.ENDPOINT,
    emit = custom_emit(emit_name),
    data_type = attribute.data_type,
    write_type = attribute.data_type,
    mfg_code = shelly.MANUFACTURER_CODE,
    profile_id = shelly.PROFILE_ID,
    read_only = writable ~= true,
    sender = writable == true and wifi_sender(attribute, options.allow_empty == true) or nil,
    from_device = attribute_name == "ssid" and wifi_ssid_from_device or
      ((attribute_name == "status" or attribute_name == "ip") and diagnostic_text_from_device or
        (attribute.data_type == data_types.Boolean and boolean_from_device or normalize_text)),
  })
  if options.suppress_optimistic_state == true then
    mapping.suppress_optimistic_state = true
  end
  if options.write_only == true then
    mapping.write_only = true
  end
  return mapping
end

function shelly.append_wifi_mappings(clusters, prefix, emit_prefix)
  local specs = {
    { "wifi_status", "WifiStatus", "status", false },
    { "ip_address", "IpAddress", "ip", false },
    { "dhcp_enabled", "DhcpEnabled", "dhcp", false },
    { "wifi_enabled", "WifiEnabled", "enabled", true },
    { "wifi_ssid", "WifiSsid", "ssid", true },
    { "wifi_password", "WifiPassword", "password", true, true, true },
    { "static_ip", "StaticIp", "static_ip", true, false, false, true },
    { "net_mask", "NetMask", "net_mask", true, false, false, true },
    { "gateway", "Gateway", "gateway", true, false, false, true },
    { "name_server", "NameServer", "name_server", true, false, false, true },
  }

  for _, spec in ipairs(specs) do
    clusters[#clusters + 1] = wifi_mapping(
      prefix .. "_" .. spec[1],
      emit_prefix .. spec[2],
      spec[3],
      spec[4],
      {
        suppress_optimistic_state = spec[5] == true,
        write_only = spec[6] == true,
        allow_empty = spec[7] == true,
      }
    )
  end
  return clusters
end

function shelly.refresh_wifi(device)
  shelly.begin_wifi_refresh(device)
  for _, name in ipairs({
    "status", "ip", "enabled", "dhcp", "ssid", "static_ip", "net_mask", "gateway", "name_server",
  }) do
    local attribute = WIFI_ATTRIBUTES[name]
    read_attribute(device, shelly.WIFI_CLUSTER, attribute.id)
  end
  return true
end

function shelly.begin_wifi_refresh(device)
  return write_attribute(device, shelly.WIFI_CLUSTER, WIFI_ATTRIBUTES.action_code.id, data_types.Uint8, 0)
end

function shelly.get_known_full_wifi_ssid(device)
  return get_known_full_wifi_ssid(device)
end

local function json_scalar(value)
  if type(value) == "boolean" then return value and "true" or "false" end
  if type(value) == "number" then return tostring(value) end
  if type(value) ~= "string" then return nil end
  return '"' .. value:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\b', '\\b')
    :gsub('\f', '\\f'):gsub('\n', '\\n'):gsub('\r', '\\r'):gsub('\t', '\\t') .. '"'
end

local function nested_json(path, value)
  local encoded = json_scalar(value)
  if encoded == nil then return nil end
  for index = #path, 1, -1 do
    encoded = '{"' .. path[index] .. '":' .. encoded .. '}'
  end
  return encoded
end

local function rpc_message(method, params_json)
  return '{"id":1,"method":"' .. method .. '","params":' .. params_json .. '}'
end

function shelly.send_rpc_message(device, message)
  if type(message) ~= "string" or message == "" then return false end
  write_attribute(device, shelly.RPC_CLUSTER, 0x0001, data_types.Uint32, #message)
  for offset = 1, #message, 40 do
    write_attribute(device, shelly.RPC_CLUSTER, 0x0000, data_types.CharString, message:sub(offset, offset + 39))
  end
  return true
end

local function command_only_mapping(name, sender)
  return {
    protocol = "zcl",
    cluster_id = shelly.RPC_CLUSTER,
    name = name,
    endpoint = shelly.ENDPOINT,
    mfg_code = shelly.MANUFACTURER_CODE,
    write_only = true,
    sender = sender,
  }
end

function shelly.rpc_presence_setting(name, path, options)
  options = options or {}
  return command_only_mapping(name, function(device, _, value)
    if options.reject_value ~= nil and value == options.reject_value then return false end
    if type(options.to_device) == "function" then value = options.to_device(value) end
    local config = nested_json(path, value)
    if config == nil then return false end
    return shelly.send_rpc_message(device, rpc_message("Presence.SetConfig", '{"config":' .. config .. '}'))
  end)
end

function shelly.rpc_presence_zone_delay(name, field)
  return command_only_mapping(name, function(device, _, value)
    value = tonumber(value)
    if value == nil then return false end
    value = math.max(0, math.min(3600, math.floor(value + 0.5)))
    local params = '{"id":200,"config":{"' .. field .. '":' .. tostring(value) .. '}}'
    return shelly.send_rpc_message(device, rpc_message("PresenceZone.SetConfig", params))
  end)
end

function shelly.rpc_eco_mode(name)
  return command_only_mapping(name, function(device, _, value)
    value = boolean_to_device(value)
    if value == nil then return false end
    local params = '{"config":{"device":{"eco_mode":' .. (value and "true" or "false") .. '}}}'
    return shelly.send_rpc_message(device, rpc_message("Sys.SetConfig", params))
  end)
end

function shelly.boolean_from_device(value)
  return boolean_from_device(value)
end

function shelly.boolean_to_device(value)
  return boolean_to_device(value)
end

return shelly
