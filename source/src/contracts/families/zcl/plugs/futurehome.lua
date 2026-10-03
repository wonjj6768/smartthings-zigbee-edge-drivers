local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local data_types = require "st.zigbee.data_types"
local cluster_base = require "st.zigbee.cluster_base"

local device_definitions, register_device_definition = device_helpers.definition_registry()
local MFG_CODE = 0x133D
local STATUS = { [0] = "plugged_out", "off", "plugged_in_charging", "plugged_in_paused", "plugged_in", "stopped" }

local function setting_sender(device, mapping, value)
  local meta = zcl.mapping_meta(mapping)
  local encoded = meta.to_device and meta.to_device(value) or value
  if meta.data_type == data_types.SinglePrecisionFloat then
    local exponent = math.floor(math.log(encoded, 2))
    encoded = data_types.SinglePrecisionFloat(0, exponent, encoded / 2 ^ exponent - 1)
  else
    encoded = meta.data_type(encoded)
  end
  device:send(cluster_base.write_manufacturer_specific_attribute(
    device, meta.cluster_id, meta.attribute_id, MFG_CODE, meta.data_type, encoded):to_endpoint(1))
  return true
end

local function emit_status(value, device)
  local charging, connected = value == 2, value ~= 0
  local timestamp = os.date("!%Y-%m-%dT%H:%M:%S+00:00", os.time())
  local events = {
    emit.fhChargeStatus()(device, STATUS[value]),
    emit.fhChargeIsCharging()(device, charging and "true" or "false"),
    emit.fhChargeIsPlugConnected()(device, connected and "true" or "false"),
  }
  if charging and device:get_field("fh_charge_is_charging") ~= true then
    events[#events + 1] = emit.fhChargeChargingStartDatetime()(device, timestamp)
    events[#events + 1] = emit.fhChargeChargingEndDatetime()(device, "-")
  elseif not charging and device:get_field("fh_charge_is_charging") == true then
    events[#events + 1] = emit.fhChargeChargingEndDatetime()(device, timestamp)
  end
  if connected and device:get_field("fh_charge_is_connected") ~= true then
    events[#events + 1] = emit.fhChargeConnectedStartDatetime()(device, timestamp)
    events[#events + 1] = emit.fhChargeConnectedEndDatetime()(device, "-")
  elseif not connected and device:get_field("fh_charge_is_connected") == true then
    events[#events + 1] = emit.fhChargeConnectedEndDatetime()(device, timestamp)
  end
  device:set_field("fh_charge_is_charging", charging, { persist = true })
  device:set_field("fh_charge_is_connected", connected, { persist = true })
  return events
end

local function session_events(device, value, context, mapping)
  local attribute = zcl.mapping_meta(mapping).attribute_id
  for _, record in ipairs(context.zb_rx.body.zcl_body.attr_records or {}) do
    local attr = record.attr_id.value
    if attr >= 0xEF01 and attr <= 0xEF04 and record.data then
      device:set_field("fh_charge_session_" .. attr, record.data.value, { persist = true })
    end
  end
  device:set_field("fh_charge_session_" .. attribute, value, { persist = true })
  local events = {}
  local start_energy = device:get_field("fh_charge_session_" .. 0xEF03)
  local now_energy = device:get_field("fh_charge_session_" .. 0xEF04)
  if start_energy ~= nil then events[#events + 1] = emit.fhChargeEnergyMeterStart()(device, start_energy / 1000) end
  if now_energy ~= nil then events[#events + 1] = emit.fhChargeEnergyMeterNow()(device, now_energy / 1000) end
  if start_energy ~= nil and now_energy ~= nil then
    events[#events + 1] = emit.fhChargeSessionEnergy()(device, (now_energy - start_energy) / 1000)
  end
  local start_time = device:get_field("fh_charge_session_" .. 0xEF01)
  local end_time = device:get_field("fh_charge_session_" .. 0xEF02)
  if start_time ~= nil and end_time ~= nil then
    events[#events + 1] = emit.fhChargeChargingDuration()(device, end_time - start_time)
  end
  return events
end

local futurehome_charge = {
  profile = "plugs-futurehome-charge",
  zcl_clusters = {
    zcl.cluster_attribute(0x001B, 0xEF09, {
      name = "fh_charge_status", endpoint = 1, mfg_code = MFG_CODE, data_type = data_types.Uint8,
      read_only = true, read_on_configure = true, minimum_interval = 5, maximum_interval = 3600, reportable_change = 1,
      emit = function(device, value) return emit_status(value, device) end,
    }),
    zcl.cluster_attribute(0x000D, 0x0055, {
      name = "fh_charge_setpoint_charging_current", endpoint = 1,
      data_type = data_types.SinglePrecisionFloat, sender = setting_sender,
      emit = emit.fhChargeSetpointChargingCurrent(), read_on_configure = true,
      minimum_interval = 10, maximum_interval = 3600, reportable_change = data_types.SinglePrecisionFloat(0, 0, 0),
    }),
    zcl.cluster_attribute(0x000D, 0x0041, {
      name = "fh_charge_charging_current_limit", endpoint = 1,
      data_type = data_types.SinglePrecisionFloat, sender = setting_sender,
      emit = emit.fhChargeChargingCurrentLimit(), read_on_configure = true,
    }),
    zcl.cluster_attribute(0x001B, 0xEF0C, {
      name = "fh_charge_auto_charge", endpoint = 1, mfg_code = MFG_CODE, data_type = data_types.Uint8,
      emit = emit.fhChargeAutoCharge(), read_on_configure = true, sender = setting_sender,
      from_device = function(value) return value == 1 and "ON" or "OFF" end,
      to_device = function(value) return value == "ON" and 1 or 0 end,
    }),
    zcl.cluster_attribute(0x0101, 0x0025, {
      name = "fh_charge_plug_locked_permanently", endpoint = 1, data_type = data_types.Enum8,
      emit = emit.fhChargePlugLockedPermanently(), read_on_configure = true, sender = setting_sender,
      from_device = function(value) return (type(value) == "table" and value.value or value) == 2 and "LOCK" or "UNLOCK" end,
      to_device = function(value) return value == "LOCK" and 2 or 0 end,
    }),
    zcl.cluster_attribute(0x0101, 0x0000, {
      name = "fh_charge_plug_lock_state", endpoint = 1, data_type = data_types.Enum8,
      read_only = true, read_on_configure = true, emit = emit.fhChargePlugLockState(),
      from_device = function(value) return (type(value) == "table" and value.value or value) == 2 and "unlocked" or "locked" end,
    }),
    zcl.cluster_attribute(0x0101, 0xFFFF, {
      name = "fh_charge_force_unlock", endpoint = 1, write_only = true, suppress_optimistic_state = true,
      tx_command_id = 1, to_device = function() return string.char(0) end,
    }),
    zcl.cluster_attribute(0x0B04, 0x0304, {
      name = "power", endpoint = 1, emit = emit.power(), data_type = data_types.Int32,
      read_only = true, read_on_configure = true, minimum_interval = 5, maximum_interval = 3600, reportable_change = 1,
    }),
    zcl.cluster_attribute(0x0702, 0x0000, {
      name = "energy", endpoint = 1, emit = emit.energy(), data_type = data_types.Uint48,
      read_only = true, read_on_configure = true, scale = 1000, ignore_reported_scaler = true,
      minimum_interval = 60, maximum_interval = 65000, reportable_change = 1,
    }),
  },
  configure = function(driver, device)
    for _, cluster in ipairs({ 0x001B, 0x000D, 0x0B04, 0x0702 }) do
      zcl.bind_cluster(device, cluster, driver.environment_info.hub_zigbee_eui, 1)
    end
  end,
  parent_refresh = function(device, definition)
    for _, mapping in ipairs(definition.zcl_clusters) do
      local meta = zcl.mapping_meta(mapping)
      if not meta.write_only and (meta.attribute_id < 0xEF01 or meta.attribute_id == 0xEF09 or meta.attribute_id == 0xEF0C) then
        if meta.cluster_id == 0x000D or meta.cluster_id == 0x0101 and meta.attribute_id == 0x0025 then
          device:send(cluster_base.read_manufacturer_specific_attribute(
            device, meta.cluster_id, meta.attribute_id, MFG_CODE):to_endpoint(1))
        else
          zcl.read_mapping(device, mapping)
        end
      end
    end
  end,
}

for _, item in ipairs({ { "start", 1 }, { "stop", 2 }, { "pause", 3 } }) do
  futurehome_charge.zcl_clusters[#futurehome_charge.zcl_clusters + 1] = zcl.cluster_attribute(0x001B, 0xFFFC + item[2], {
    name = "fh_charge_charging_" .. item[1], endpoint = 1, write_only = true, suppress_optimistic_state = true,
    sender = function(device)
      zcl.send_raw_cluster_command(device, 0x001B, 0, string.char(item[2]), 1)
      zcl.send_raw_cluster_command(device, 0x001B, 1, "", 1)
      return true
    end,
  })
end

for _, attribute in ipairs({ 0xEF01, 0xEF02, 0xEF03, 0xEF04 }) do
  futurehome_charge.zcl_clusters[#futurehome_charge.zcl_clusters + 1] = zcl.cluster_attribute(0x001B, attribute, {
    name = "fh_charge_session_" .. attribute, endpoint = 1, mfg_code = MFG_CODE, data_type = data_types.Uint32,
    read_only = true, minimum_interval = (attribute == 0xEF01 or attribute == 0xEF03) and 60 or 5,
    maximum_interval = 3600, reportable_change = 1, emit = session_events,
  })
end

for _, item in ipairs({
  { 0x0505, "voltage", "voltage", emit.voltage(), 60 },
  { 0x0905, "fh_charge_voltage_phase_b", "voltage", emit.fhChargeVoltagePhaseB(), 60 },
  { 0x0A05, "fh_charge_voltage_phase_c", "voltage", emit.fhChargeVoltagePhaseC(), 60 },
  { 0x0508, "current", "current", emit.current(), 10 },
  { 0x0908, "fh_charge_current_phase_b", "current", emit.fhChargeCurrentPhaseB(), 10 },
  { 0x0A08, "fh_charge_current_phase_c", "current", emit.fhChargeCurrentPhaseC(), 10 },
}) do
  futurehome_charge.zcl_clusters[#futurehome_charge.zcl_clusters + 1] = zcl.cluster_attribute(0x0B04, item[1], {
    name = item[2], endpoint = 1, metering_kind = item[3], emit = item[4], data_type = data_types.Uint16,
    read_only = true, read_on_configure = true, minimum_interval = item[5], maximum_interval = 65000,
    physical_reportable_change = item[3] == "current" and 0.05 or nil,
    reportable_change = item[3] == "voltage" and 1 or nil,
  })
end

register_device_definition(futurehome_charge, { device_helpers.create_fingerprint("Futurehome", "Charge") })

return {
  id = "zcl.plugs.futurehome",
  registrations = device_definitions,
}
