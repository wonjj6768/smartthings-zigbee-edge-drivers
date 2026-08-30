-- Frozen Zigbee2MQTT v26.99 eWeLink 7035 smoke-alarm candidate.

local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local data_types = require "st.zigbee.data_types"

local registrations, register_device_definition = device_helpers.definition_registry()

local function alarm_1_from_device(value)
  if type(value) == "table" then
    if type(value.is_alarm1_set) == "function" then
      return value:is_alarm1_set()
    end
    value = value.value
  end

  if type(value) ~= "number" then return nil end
  return value % 2 == 1
end

local function battery_percentage_from_device(value, _, context)
  local raw_value = type(context) == "table" and context.raw_value or value
  if type(raw_value) ~= "number" or raw_value >= 0xFF then return nil end
  if type(context) == "table" then return value end
  return raw_value / 2
end

-- The frozen iasZoneAlarm extension does not configure ZoneStatus reporting;
-- this device's explicit configure hook only binds IAS Zone and reads its four
-- state attributes. Keep the common IAS enrolment/read adapter, but remove the
-- reporting cadence supplied by the common smoke preset.
local function frozen_alarm_1_mapping()
  local mapping = zcl.smoke({
    endpoint = 1,
    read_only = true,
    from_device = alarm_1_from_device,
  })
  mapping.minimum_interval = nil
  mapping.maximum_interval = nil
  mapping.reportable_change = nil
  return mapping
end

local ewelink_7035 = {
  profile = "safety-wave19-ewelink-7035",
  zcl_clusters = {
    frozen_alarm_1_mapping(),
    zcl.battery({
      endpoint = 1,
      read_only = true,
      minimum_interval = 3600,
      maximum_interval = 65000,
      reportable_change = 10,
      from_device = battery_percentage_from_device,
    }),
    zcl.cluster_attribute(0xFC11, 0x2000, {
      name = "ewelink_7035_tamper",
      endpoint = 1,
      mfg_code = 0x1286,
      data_type = data_types.Uint8,
      read_only = true,
      read_on_configure = true,
      from_device = function(value)
        if value == 0x01 then return true end
        if value == 0x00 then return false end
        return nil
      end,
      emit = emit.tamper(),
    }),
  },
  configure = function(_, device)
    -- The IAS adapter binds/enrols and reads ZoneStatus. Preserve the other
    -- three endpoint-1 IAS reads from the frozen definition as well.
    for _, attribute_id in ipairs({ 0x0000, 0x0010, 0x0011 }) do
      zcl.read_attribute(device, zcl.CLUSTER_IAS_ZONE, attribute_id, 1)
    end
  end,
}

register_device_definition(ewelink_7035, {
  device_helpers.create_fingerprint(
    "eWeLink",
    "CK-TLSR8656-Z123SE22DY-01(7035)"
  ),
})

return {
  id = "zcl.sensors.wave19_smoke",
  registrations = registrations,
}
