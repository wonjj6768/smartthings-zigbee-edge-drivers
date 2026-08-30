-- Wave18 JAVIS JS-SLK2-ZB source-only exact lock candidate.
-- Frozen Zigbee2MQTT v26.99.0: src/devices/javis.ts:12-65.

local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local data_types = require "st.zigbee.data_types"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local BASIC_CLUSTER = 0x0000
local JAVIS_REPORT_ATTRIBUTE = 16896
local TIMER_FIELD = "__wave18_javis_lock_timer"
local ACTION_USER_FIELD = "__wave18_javis_action_user"
local ACTION_SOURCE_FIELD = "__wave18_javis_action_source"
local ACTION_SOURCE_NAME_FIELD = "__wave18_javis_action_source_name"

local SOURCE_NAMES = {
  [0] = "pairing",
  [1] = "keypad",
  [2] = "rfid_card_unlock",
  [3] = "touch_unlock",
}

local javis_action_emitter_base = assert(emit.javisSlkAction, "missing Wave18 JAVIS action emitter")()
local function javis_action_emitter(...)
  local event = javis_action_emitter_base(...)
  if event ~= nil then event.state_change = true end
  return event
end

local javis_state_emitter = assert(emit.javisSlkState, "missing Wave18 JAVIS state emitter")()

local function javis_report_from_device(value, device)
  if type(value) ~= "string" then
    return nil
  end
  -- Z2M converts the UTF-8 string to bytes and reads zero-based offsets 3/5.
  -- Lua strings already contain the UTF-8 bytes, hence one-based offsets 4/6.
  local user = string.byte(value, 4)
  local source = string.byte(value, 6)
  device:set_field(ACTION_USER_FIELD, user, { persist = false })
  device:set_field(ACTION_SOURCE_FIELD, source, { persist = false })
  device:set_field(ACTION_SOURCE_NAME_FIELD, SOURCE_NAMES[source], { persist = false })
  return "unlock"
end

local function schedule_delayed_lock(device, _, mapping_context)
  local endpoint = type(mapping_context) == "table" and mapping_context.endpoint or "unknown"
  local endpoint_timers = device:get_field(TIMER_FIELD)
  if type(endpoint_timers) ~= "table" then endpoint_timers = {} end
  local previous = endpoint_timers[endpoint]
  if previous ~= nil and type(previous.cancel) == "function" then
    previous:cancel()
  end
  local timer
  timer = device.thread:call_with_delay(2, function()
    -- clearTimeout() in the frozen converter guarantees a replaced callback
    -- cannot publish. Keep the same invariant even in deterministic harnesses
    -- that can invoke a cancelled callback directly.
    local active_timers = device:get_field(TIMER_FIELD)
    if type(active_timers) ~= "table" or active_timers[endpoint] ~= timer then return end

    -- Frozen javis.ts publishes both observable values after two seconds.
    -- They remain two read-only, one-item custom capabilities; using standard
    -- lock would invent an unlock state and commands that the source lacks.
    local action_event = javis_action_emitter(device, "lock")
    if action_event ~= nil then device:emit_event(action_event) end
    local state_event = javis_state_emitter(device, "LOCK")
    if state_event ~= nil then device:emit_event(state_event) end
  end, "wave18 javis delayed lock")
  endpoint_timers[endpoint] = timer
  device:set_field(TIMER_FIELD, endpoint_timers, { persist = false })
end

local javis = {
  profile = "locks-wave18-javis-js-slk2-zb",
  package_group = "wave18-javis-lock",
  transport_classification = "ZCL_BASIC_CUSTOM_ATTRIBUTE_RX",
  z2m_converter_source = "local fzLocal.javis_lock_report + fz.battery",
  wire_cluster = "genBasic(0x0000) + genPowerCfg(0x0001)",
  zcl_clusters = {
    zcl.cluster_attribute(BASIC_CLUSTER, JAVIS_REPORT_ATTRIBUTE, {
      name = "javis_unlock_report",
      read_only = true,
      from_device = javis_report_from_device,
      handler = schedule_delayed_lock,
      emit = javis_action_emitter,
    }),
    -- Use the raw mapping instead of zcl.battery(), whose shared preset adds
    -- reporting configuration absent from frozen fz.battery-only definition.
    zcl.cluster_attribute(0x0001, 0x0021, {
      name = "battery",
      component = "main",
      data_type = data_types.Uint8,
      read_only = true,
      scale = 2,
      emit = emit.battery(),
    }),
  },
}

register_device_definition(javis, {
  { manufacturer = "Lmiot", model = "doorlock_5001" },
  { manufacturer = "Vensi", model = "E321V000A03" },
})

return {
  id = "zcl.controls.wave18_javis_lock",
  registrations = device_definitions,
}
