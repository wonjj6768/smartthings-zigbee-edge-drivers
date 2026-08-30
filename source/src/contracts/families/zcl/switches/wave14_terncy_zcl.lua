-- Wave14 TERNCY-WS07-D3 source-only candidate.  The parent Wave14 package is
-- EF00-owned for the QA devices, but this registration is exact custom ZCL:
-- manufacturer 0x1228, cluster 0xFCCC, plus three standard OnOff endpoints.
-- Frozen Zigbee2MQTT v26.99.0: src/devices/terncy.ts:13-470,821-879.

local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local cluster_base = require "st.zigbee.cluster_base"
local data_types = require "st.zigbee.data_types"
local device_management = require "st.zigbee.device_management"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local XIAOYAN_MFG_CODE = 0x1228
local CLUSTER_ADURO_SMART = 0xFCCC
local CLUSTER_ON_OFF = 0x0006
local ATTR_ON_OFF = 0x0000
local ATTR_STARTUP_ON_OFF = 0x4003
local ATTR_BUTTON_LED_POLARITY = 0x001F
local SOURCE_ENDPOINT_LED_WRITE = 110

local action_emit = assert(emit.terncyWs07Action, "missing Terncy WS07 action emitter")()
local duration_emit = assert(emit.terncyWs07ActionDuration, "missing Terncy WS07 duration emitter")()
local power_behavior_emits = {
  assert(emit.terncyWs07PowerOnBehaviorOne, "missing Terncy WS07 power behavior emitter 1")(),
  assert(emit.terncyWs07PowerOnBehaviorTwo, "missing Terncy WS07 power behavior emitter 2")(),
  assert(emit.terncyWs07PowerOnBehaviorThree, "missing Terncy WS07 power behavior emitter 3")(),
}

local CLICK_ACTIONS = {
  [1] = "single",
  [2] = "double",
  [3] = "triple",
  [4] = "quadruple",
  [5] = "5_click",
  [6] = "6_click",
  [7] = "7_click",
}

local function emit_main(device, event)
  if event ~= nil then
    device:emit_component_event({ id = "main" }, event)
  end
end

local function source_endpoint(zb_rx)
  return zb_rx and zb_rx.address_header and zb_rx.address_header.src_endpoint and
    zb_rx.address_header.src_endpoint.value or nil
end

local function manufacturer_code(zb_rx)
  local header = zb_rx and zb_rx.body and zb_rx.body.zcl_header or nil
  local code = header and header.mfg_code and header.mfg_code.value or nil
  return code
end

local function is_ws07_action_header(zb_rx)
  local header = zb_rx and zb_rx.body and zb_rx.body.zcl_header or nil
  local frame_ctrl = header and header.frame_ctrl or nil
  -- Frozen fzLocal.ws07_action accepts only raw header 0D 28 12.  The
  -- transaction sequence and command are decoded separately by Edge, so the
  -- remaining equivalent gate is frame-control 0x0D plus manufacturer 0x1228.
  return frame_ctrl ~= nil and frame_ctrl.value == 0x0D and
    manufacturer_code(zb_rx) == XIAOYAN_MFG_CODE
end

local function body_bytes(zb_rx)
  local body = zb_rx and zb_rx.body and zb_rx.body.zcl_body or nil
  return body and body.body_bytes or nil
end

local function endpoint_name(endpoint)
  return ({ [1] = "l1", [2] = "l2", [3] = "l3" })[endpoint]
end

zcl.register_cluster_command_handler(CLUSTER_ADURO_SMART, 0x00, function(device, preset, zb_rx)
  if preset.terncy_ws07 ~= true or not is_ws07_action_header(zb_rx) then
    return false
  end
  local endpoint = endpoint_name(source_endpoint(zb_rx))
  local payload = body_bytes(zb_rx)
  if endpoint == nil or type(payload) ~= "string" or #payload < 2 then return false end
  local action = CLICK_ACTIONS[string.byte(payload, 2)]
  if action == nil then return false end
  emit_main(device, action_emit(device, action .. "_" .. endpoint))
  return true
end)

zcl.register_cluster_command_handler(CLUSTER_ADURO_SMART, 0x29, function(device, preset, zb_rx)
  if preset.terncy_ws07 ~= true or not is_ws07_action_header(zb_rx) then
    return false
  end
  local endpoint = endpoint_name(source_endpoint(zb_rx))
  local payload = body_bytes(zb_rx)
  if endpoint == nil or type(payload) ~= "string" or #payload < 4 then return false end
  local event_code = string.byte(payload, 1)
  local action = ({ [0x02] = "hold", [0x08] = "release" })[event_code]
  if action == nil then return false end
  local duration = string.byte(payload, 3) + string.byte(payload, 4) * 0x100
  emit_main(device, action_emit(device, action .. "_" .. endpoint))
  emit_main(device, duration_emit(device, duration))
  return true
end)

local function command_sender(command_id, lookup)
  return function(device, _, value, context)
    local encoded = lookup[value]
    if encoded == nil then return false end
    return zcl.send_raw_cluster_command(
      device,
      CLUSTER_ADURO_SMART,
      command_id,
      string.char(encoded),
      context.endpoint,
      nil,
      XIAOYAN_MFG_CODE,
      false
    )
  end
end

local function led_feedback_sender(device, _, value, context)
  local encoded = ({ positive = 0, negative = 1 })[value]
  if encoded == nil then return false end
  local request = cluster_base.write_manufacturer_specific_attribute(
    device,
    CLUSTER_ADURO_SMART,
    ATTR_BUTTON_LED_POLARITY,
    XIAOYAN_MFG_CODE,
    data_types.Uint8,
    encoded
  )
  if context.endpoint ~= nil and type(request.to_endpoint) == "function" then
    request = request:to_endpoint(context.endpoint)
  end
  if type(request.from_endpoint) == "function" then
    request = request:from_endpoint(SOURCE_ENDPOINT_LED_WRITE)
  else
    request.address_header.src_endpoint = data_types.Uint8(SOURCE_ENDPOINT_LED_WRITE)
  end
  device:send(request)
  return true
end

local function config_mapping(name, endpoint, component, sender)
  local mapping = zcl.cluster_attribute(CLUSTER_ADURO_SMART, nil, {
    name = name,
    endpoint = endpoint,
    component = component,
    read_only = false,
    write_only = true,
    sender = sender,
  })
  return mapping
end

local mappings = {}
for endpoint = 1, 3 do
  local word = ({ "One", "Two", "Three" })[endpoint]
  local component = endpoint == 1 and "main" or ("switch" .. tostring(endpoint))
  mappings[#mappings + 1] = zcl.switch({
    endpoint = endpoint,
    component = component,
    read_only = false,
    configure_reporting = false,
    read_on_configure = false,
  })
  mappings[#mappings + 1] = zcl.cluster_attribute(CLUSTER_ON_OFF, ATTR_STARTUP_ON_OFF, {
    name = "terncy_ws07_power_on_behavior_" .. string.lower(word),
    endpoint = endpoint,
    component = component,
    read_only = false,
    data_type = data_types.Enum8,
    write_type = data_types.Enum8,
    emit = power_behavior_emits[endpoint],
    from_device = function(value)
      return ({ [0] = "off", [1] = "on", [2] = "toggle", [255] = "previous" })[value]
    end,
    to_device = function(value)
      return ({ off = 0, on = 1, toggle = 2, previous = 255 })[value]
    end,
  })
  mappings[#mappings + 1] = config_mapping(
    "terncy_ws07_operation_mode_" .. string.lower(word),
    endpoint,
    component,
    command_sender(0x1D, { control_relay = 0, wireless = 1 })
  )
  mappings[#mappings + 1] = config_mapping(
    "terncy_ws07_wireless_led_status_" .. string.lower(word),
    endpoint,
    component,
    command_sender(0x1F, { off = 0, on = 1 })
  )
  mappings[#mappings + 1] = config_mapping(
    "terncy_ws07_led_feedback_mode_" .. string.lower(word),
    endpoint,
    component,
    led_feedback_sender
  )
end

local function configure(driver, device)
  for endpoint = 1, 3 do
    device:send(device_management.build_bind_request(
      device,
      CLUSTER_ON_OFF,
      driver.environment_info.hub_zigbee_eui,
      endpoint
    ))
    for _, item in ipairs({
      { ATTR_ON_OFF, data_types.Boolean },
      { ATTR_STARTUP_ON_OFF, data_types.Enum8 },
    }) do
      device:send(cluster_base.configure_reporting(
        device,
        data_types.ClusterId(CLUSTER_ON_OFF),
        data_types.AttributeId(item[1]),
        data_types.ZigbeeDataType(item[2].ID),
        0,
        65000,
        1
      ):to_endpoint(endpoint))
      zcl.read_attribute(device, CLUSTER_ON_OFF, item[1], endpoint)
    end
  end
end

local terncy_ws07 = {
  profile = "switches-wave14-terncy-ws07-d3",
  package_group = "wave14-switch",
  transport_classification = "ZCL_CUSTOM_COMMAND_RAW_ACTION",
  z2m_converter_source = "fzLocal.ws07_action + tzLocal.ws07_*",
  wire_cluster = "0xFCCC/0x1228 + genOnOff endpoints 1..3",
  terncy_ws07 = true,
  zcl_clusters = mappings,
  component_to_endpoint_map = { main = 1, switch2 = 2, switch3 = 3 },
  endpoint_to_component_map = { [1] = "main", [2] = "switch2", [3] = "switch3" },
  placeholder_custom_states = false,
  configure = configure,
}

register_device_definition(terncy_ws07, {
  device_helpers.create_fingerprint("Xiaoyan", "TERNCY-WS07-D3"),
})

return {
  id = "wave14.terncy.zcl_switch",
  registrations = device_definitions,
}
