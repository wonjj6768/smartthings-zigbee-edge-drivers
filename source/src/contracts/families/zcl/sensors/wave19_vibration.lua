-- Frozen Zigbee2MQTT v26.99.0:
--   src/devices/tuya.ts:1271-1279,13933-13960
--   src/converters/fromZigbee.ts:1084-1115

local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local data_types = require "st.zigbee.data_types"
local tuya = require "protocol.tuya"
local capabilities = require "st.capabilities"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local VIBRATION_TIMEOUT_SECONDS = 90
local TIMER_FIELD = "__wave19_ts0210_vibration_timer"
local acceleration_emitter = emit.acceleration()

-- This frozen definition has no configure hook. Keep the common IAS enrolment
-- adapter, but do not invent attribute reporting or configure-time reads for
-- the passive IAS/Power Configuration converters.
local function passive_rx(mapping)
  mapping.minimum_interval = nil
  mapping.maximum_interval = nil
  mapping.reportable_change = nil
  mapping.read_on_configure = false
  return mapping
end

local function reject_zcl_unknown(value, _, context)
  local raw_value = context and context.raw_value or nil
  if type(raw_value) == "number" and raw_value >= 0xFF then return nil end
  return value
end

local function sensitivity_to_device(value)
  if type(value) ~= "number" or value % 1 ~= 0 or value < 0 or value > 50 then
    return nil
  end
  return value
end

local function schedule_vibration_clear(device, value)
  local previous = device:get_field(TIMER_FIELD)
  if previous ~= nil and type(previous.cancel) == "function" then
    previous:cancel()
  end
  device:set_field(TIMER_FIELD, nil, { persist = false })

  -- This is the frozen converter's default vibration_timeout. It is a driver
  -- option, not a device attribute, so it must not become a custom capability.
  if VIBRATION_TIMEOUT_SECONDS == 0 then return end

  local timer
  timer = device.thread:call_with_delay(VIBRATION_TIMEOUT_SECONDS, function()
    if device:get_field(TIMER_FIELD) ~= timer then return end
    device:set_field(TIMER_FIELD, nil, { persist = false })
    local event = acceleration_emitter(device, false)
    if event ~= nil then device:emit_event(event) end
  end, "wave19 TS0210 vibration clear")
  device:set_field(TIMER_FIELD, timer, { persist = false })
end

local ts0210 = {
  profile = "safety-wave19-tuya-ts0210-quoted",
  package_group = "wave19-vibration",
  zcl_clusters = {
    passive_rx(zcl.motion({
      emit = acceleration_emitter,
      handler = schedule_vibration_clear,
    })),
    passive_rx(zcl.tamper()),
    passive_rx(zcl.battery({ from_device = reject_zcl_unknown })),
    passive_rx(zcl.battery_voltage({ from_device = reject_zcl_unknown })),
    zcl.cluster_attribute(0x0500, 0x0013, {
      name = "tuya_ts0210_sensitivity",
      data_type = data_types.Uint8,
      write_type = data_types.Uint8,
      write_only = true,
      to_device = sensitivity_to_device,
      numeric_range = {
        minimum = 0,
        maximum = 50,
        step = 1,
      },
    }),
  },
}

register_device_definition(ts0210, {
  -- The two apostrophes are literal Basic-cluster bytes in frozen Z2M. Do not
  -- normalize them away and do not add a model-only fallback.
  device_helpers.create_fingerprint("'_TZ32101000000_5oy7cysk'", "TS0210"),
})

-- #55's unquoted device is an EF00 variant, not the frozen IAS-only alias.
-- Hubitat 355d1d6 and ZHA #4908 report DP104 enum vibration and DP4 battery.
-- A second captured firmware uses DP101 ENUM for vibration; DP101 VALUE is
-- an axis reading on the first firmware and must never trigger acceleration.
local function vibration_from_device(value, _, dp)
  if dp.datatype ~= tuya.DP_TYPE_ENUM or (value ~= 0 and value ~= 1 and value ~= 3) then return nil end
  return value ~= 0
end

local function vibration_event(_, value)
  return capabilities.accelerationSensor.acceleration({ value = value and "active" or "inactive" },
    { state_change = value == true })
end

local function schedule_ef00_vibration_clear(device, value)
  if value then return schedule_vibration_clear(device, value) end
  local previous = device:get_field(TIMER_FIELD)
  if previous ~= nil and type(previous.cancel) == "function" then previous:cancel() end
  device:set_field(TIMER_FIELD, nil, { persist = false })
end

local function vibration_dp(id)
  return tuya.dp_enum(id, {
    name = "vibration_event_" .. tostring(id), endpoint = 1, read_only = true,
    converter = tuya.converter.from_only(vibration_from_device),
    handler = schedule_ef00_vibration_clear, emit = vibration_event,
  })
end

register_device_definition({
  profile = "safety-tuya-ts0210-ef00",
  package_group = "wave19-vibration",
  magic_packet = true,
  query_on_configure = false,
  zcl_clusters = {
    passive_rx(zcl.motion({ endpoint = 1, emit = vibration_event, handler = schedule_ef00_vibration_clear })),
    passive_rx(zcl.tamper({ endpoint = 1 })),
    zcl.battery({ endpoint = 1, read_only = true, minimum_interval = 3600,
      maximum_interval = 65000, reportable_change = 10, from_device = reject_zcl_unknown }),
    zcl.battery_voltage({ endpoint = 1, read_only = true, configure_reporting = false,
      read_on_configure = true, from_device = reject_zcl_unknown }),
  },
  datapoints = {
    tuya.dp_battery(4, { endpoint = 1, emit = emit.battery(), read_only = true }),
    vibration_dp(101),
    vibration_dp(104),
    -- DP10 has conflicting unverified reports. This is the independently
    -- implemented DP105 enum contract; do not send the old IAS numeric write.
    tuya.dp_enum(105, { name = "ts0210_ef00_sensitivity", endpoint = 1,
      converter = tuya.converter.lookup_from_to({ low = 0, middle = 1, high = 2 }),
      emit = emit.ts0210Ef00Sensitivity() }),
  },
}, { device_helpers.create_fingerprint("_TZ32101000000_5oy7cysk", "TS0210") })

-- ZCL REPORTING CAPABILITIES BEGIN
zcl.attach_reporting_capabilities(device_definitions, {
  {2, "rpt-txh"},
})
-- ZCL REPORTING CAPABILITIES END

return {
  id = "zcl.sensors.wave19_vibration",
  registrations = device_definitions,
}
