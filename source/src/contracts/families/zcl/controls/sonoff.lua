-- SONOFF/eWeLink button contracts.
-- Oracle: zigbee-herdsman-converters 26.106.0, FETCH_HEAD e2aa714 (sonoff.ts).

local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local capabilities = require "st.capabilities"
local device_helpers = require "contracts.helpers.family"
local device_management = require "st.zigbee.device_management"
local data_types = require "st.zigbee.data_types"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local function snzb01p_action(_, cluster_id, command_id)
  if cluster_id ~= zcl.CLUSTER_ON_OFF then
    return nil, nil, true
  end

  local action = ({
    [0x02] = "single",
    [0x01] = "double",
    [0x00] = "long",
  })[command_id]
  return action, "main", true
end

local snzb01p = {
  profile = "sonoff-snzb01p-button",
  advanced_remote = true,
  button_count = 1,
  button_actions = { "pushed", "double", "held" },
  standard_command_action_resolver = snzb01p_action,
  standard_action_button_events = {
    single = "pushed",
    double = "double",
    long = "held",
  },
  zcl_clusters = {
    zcl.battery({
      endpoint = 1,
      minimum_interval = 3600,
      maximum_interval = 7200,
      reportable_change = 0,
      read_on_configure = true,
      read_only = true,
    }),
    zcl.battery_voltage({
      endpoint = 1,
      minimum_interval = 3600,
      maximum_interval = 7200,
      reportable_change = 0,
      read_on_configure = true,
      read_only = true,
    }),
  },
  configure = function(driver, device)
    device:send(device_management.build_bind_request(
      device,
      zcl.CLUSTER_ON_OFF,
      driver.environment_info.hub_zigbee_eui,
      1
    ))
  end,
}

register_device_definition(snzb01p, {
  device_helpers.create_fingerprint("eWeLink", "SNZB-01P"),
  -- Explicit identity authority: user-directed SONOFF Basic alias (2026-09-05).
  device_helpers.create_fingerprint("SONOFF", "SNZB-01P"),
})

local kf_action_event = emit.sonoffKfAction()
local function refresh_reported_battery(device, preset)
  -- Action attributes are notifications, so app refresh reads only battery data.
  zcl.read_configured_attributes(device, preset.zcl_clusters)
end

local function battery_value(value)
  if type(value) == "number" and value >= 0 and value < 127.5 then return value end
end

local function voltage_value(value)
  if type(value) == "number" and value >= 0 and value < 25.5 then return value end
end

local function kf_action(value, _, context)
  -- ZHC KF exposes only complete command statuses 0/1, not IAS alarm bits.
  if context.command_id ~= 0x00 then return nil end
  return ({ [0] = "off", [1] = "single" })[value]
end

local kf01 = {
  profile = "sonoff-kf-button",
  magic_packet = false,
  zcl_clusters = {
    zcl.cluster_attribute(0x0500, 0x0002, {
      name = "sonoff_kf_action",
      endpoint = 1,
      component = "main",
      data_type = data_types.Bitmap16,
      read_only = true,
      read_on_configure = false,
      ias_configure_method = 0, -- SDK CUSTOM: bind below, no automatic IAS enrollment.
      command_id = 0x00,
      command_extractor = function(zb_rx)
        local status = zb_rx.body.zcl_body.zone_status
        return type(status) == "table" and status.value or status
      end,
      from_device = kf_action,
      handler = function(device, value, context)
        local event = kf_action_event(device, value, context)
        if event then
          event.state_change = true
          device:emit_component_event(context.component, event)
        end
      end,
    }),
    zcl.battery({
      endpoint = 1, minimum_interval = 3600, maximum_interval = 7200,
      reportable_change = 2, read_on_configure = true, read_only = true,
      from_device = battery_value,
    }),
    zcl.battery_voltage({
      endpoint = 1, minimum_interval = 3600, maximum_interval = 7200,
      reportable_change = 100, read_on_configure = true, read_only = true,
      from_device = voltage_value,
    }),
  },
  configure = function(driver, device)
    device:send(device_management.build_bind_request(
      device, 0x0500, driver.environment_info.hub_zigbee_eui, 1
    ))
  end,
  parent_refresh = refresh_reported_battery,
}

-- USER_DIRECTED_SONOFF_MANUFACTURER; literal Basic identity remains unverified.
register_device_definition(kf01, {
  device_helpers.create_fingerprint("SONOFF", "KF01"),
  device_helpers.create_fingerprint("SONOFF", "KF-01"),
})

local function snzb01m_button(endpoint, component)
  return zcl.cluster_attribute(0xFC12, 0x0000, {
    name = "sonoff_snzb01m_button_" .. tostring(endpoint),
    endpoint = endpoint,
    component = component,
    data_type = data_types.Uint8,
    read_only = true,
    read_on_configure = false,
    from_device = function(value, _, context)
      if context.src_endpoint ~= endpoint then return nil end
      return ({ [1] = "pushed", [2] = "double", [3] = "held", [4] = "pushed_3x" })[value]
    end,
    handler = function(device, value, context)
      -- Action repeats must bypass scalar-state duplicate suppression.
      device:emit_component_event(context.component,
        capabilities.button.button(value, { state_change = true }))
    end,
  })
end

local snzb01m = {
  profile = "sonoff-snzb01m-button",
  magic_packet = false,
  button_count = 4,
  button_actions = { "pushed", "double", "held", "pushed_3x" },
  zcl_clusters = {
    snzb01m_button(1, "main"),
    snzb01m_button(2, "button2"),
    snzb01m_button(3, "button3"),
    snzb01m_button(4, "button4"),
    zcl.battery({
      endpoint = 1, minimum_interval = 3600, maximum_interval = 65000,
      reportable_change = 10, read_on_configure = true, read_only = true,
      from_device = battery_value,
    }),
  },
  parent_refresh = refresh_reported_battery,
}

-- USER_DIRECTED_SONOFF_MANUFACTURER; literal Basic identity remains unverified.
register_device_definition(snzb01m, {
  device_helpers.create_fingerprint("SONOFF", "SNZB-01M"),
})

return {
  id = "zcl.controls.sonoff",
  registrations = device_definitions,
}
