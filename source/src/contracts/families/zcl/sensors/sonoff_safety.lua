local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local data_types = require "st.zigbee.data_types"
local capabilities = require "st.capabilities"
local device_management = require "st.zigbee.device_management"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local SONOFF_MANUFACTURER_CODE = 0x1286
local OCCUPANCY_CLUSTER = 0x0406
local SONOFF_CLUSTER = 0xFC11
local SONOFF_ALERT_COMMAND = 0x0F
local POWER_SOURCE_MODE_FIELD = "__sonoff_safety_power_source_mode"

local function custom_emit(name)
  return assert(emit[name], "missing SONOFF Safety emitter: " .. tostring(name))()
end

local function bitmap_bit_zero(value)
  if type(value) == "table" and value.value ~= nil then
    value = value.value
  end
  if type(value) == "number" then
    return value % 2 == 1
  end
  return value == true
end

local function enum_converter(values)
  local reverse = {}
  for raw, value in pairs(values) do
    reverse[value] = raw
  end
  return {
    from = function(value)
      return values[value]
    end,
    to = function(value)
      return reverse[value]
    end,
  }
end

local function passive_ias(mapping)
  mapping.minimum_interval = nil
  mapping.maximum_interval = nil
  mapping.reportable_change = nil
  mapping.read_on_configure = false
  return mapping
end

local function battery_low_level(_, value)
  if value then
    return capabilities.batteryLevel.battery.critical()
  end
  return capabilities.batteryLevel.battery.normal()
end

local function boolean_converter()
  return {
    from = function(value)
      if value == true or value == 1 then return "on" end
      return "off"
    end,
    to = function(value)
      if value == "on" then return true end
      if value == "off" then return false end
    end,
  }
end

local function power_source_emit(_, value)
  if value == "battery" then
    return capabilities.powerSource.powerSource.battery()
  end
  if value == "dc" then
    return capabilities.powerSource.powerSource.dc()
  end
end

local function remember_power_source(device, value, context)
  if type(device) == "table" and type(device.set_field) == "function" then
    device:set_field(POWER_SOURCE_MODE_FIELD, value, { persist = false })
  end

  -- ZHC immediately asks for battery percentage after external power is
  -- detected so that a real 100% report may replace stale battery state.
  if value == "dc" and type(context) == "table" and type(context.zcl_clusters) == "table" then
    zcl.read_named_attribute(device, context.zcl_clusters, "battery", {
      endpoint = context.endpoint or 1,
    })
  end
end

local battery_emit = emit.battery()
local function snzb_09p_battery_emit(device, value, ...)
  local power_source = type(device) == "table" and type(device.get_field) == "function"
    and device:get_field(POWER_SOURCE_MODE_FIELD) or nil
  if power_source == "dc" and value ~= 100 then
    return nil
  end
  return battery_emit(device, value, ...)
end

local function sonoff_alert_sender(device, _, value, context)
  local enabled = value == true or value == "on" or value == "siren" or value == "both" or value == "strobe"
  local disabled = value == false or value == "off"
  if not enabled and not disabled then return false end

  local modes = {
    siren = { sound = "on", light = "off" },
    strobe = { sound = "off", light = "on" },
    both = { sound = "on", light = "on" },
  }
  local mode = modes[value]
  if mode ~= nil then
    local mappings = context and context.zcl_clusters or nil
    if type(mappings) ~= "table" then return false end
    local command_context = {
      component_id = context.component_id,
      endpoint = context.endpoint,
    }
    local sound_written = zcl.send_named_command(
      device, mappings, "sonoff_safety_alarm_sound_enable", mode.sound, command_context
    )
    local light_written = zcl.send_named_command(
      device, mappings, "sonoff_safety_alarm_light_enable", mode.light, command_context
    )
    if not sound_written or not light_written then return false end
  end

  -- Frozen tzLocal SNZB-09P contract: ON -> 0x00, OFF -> 0x01.  The command
  -- is deliberately not manufacturer-specific and disables default response.
  return zcl.send_raw_cluster_command(
    device,
    SONOFF_CLUSTER,
    SONOFF_ALERT_COMMAND,
    string.char(enabled and 0x00 or 0x01),
    context and context.endpoint or 1,
    nil,
    nil,
    true
  )
end

local function bind_sonoff_cluster(driver, device)
  device:send(device_management.build_bind_request(
    device,
    SONOFF_CLUSTER,
    driver.environment_info.hub_zigbee_eui,
    1
  ))
end

local function read_snzb_04pr2_tamper(_, device)
  -- ZHC performs this GET with manufacturer code 0x1286, while actual-device
  -- reports are plain ZCL frames.  Keep the read header exact and leave the
  -- receive mapping unqualified so both the real plain report and reply match.
  zcl.read_attribute(device, SONOFF_CLUSTER, 0x2000, 1, SONOFF_MANUFACTURER_CODE)
end

-- Primary interview evidence (bridge/devices Basic identity):
-- https://github.com/Koenkk/zigbee-herdsman-converters/files/13872345/z2m_log.txt
-- "manufacturer":"SONOFF","model_id":"SNZB-06P"
-- ZHC 26.106.0 (e2aa714; unchanged from 26.105): reporting is deliberately
-- disabled for Occupancy 0x0000.
-- Only the two writable Occupancy settings are read during configuration;
-- SONOFF illumination is report-only because a GET is not supported.
local snzb_06p = {
  profile = "sonoff-safety-occupancy-06p",
  zcl_clusters = {
    zcl.occupancy_sensing({
      name = "occupancy",
      emit = emit.occupancy(),
      from_device = bitmap_bit_zero,
      read_only = true,
      read_on_configure = false,
    }),
    zcl.cluster_attribute(OCCUPANCY_CLUSTER, 0x0020, {
      name = "sonoff_safety_occupancy_timeout",
      emit = custom_emit("sonoffSafetyOccupancyTimeout"),
      data_type = data_types.Uint16,
      write_type = data_types.Uint16,
      numeric_range = { minimum = 15, maximum = 65535, step = 1, unit = "s" },
      read_on_configure = true,
    }),
    zcl.cluster_attribute(OCCUPANCY_CLUSTER, 0x0022, {
      name = "sonoff_safety_occupancy_sensitivity",
      emit = custom_emit("sonoffSafetyOccupancySensitivity"),
      converter = enum_converter({ [1] = "low", [2] = "medium", [3] = "high" }),
      data_type = data_types.Uint8,
      write_type = data_types.Uint8,
      read_on_configure = true,
    }),
    zcl.cluster_attribute(SONOFF_CLUSTER, 0x2001, {
      name = "sonoff_safety_illumination",
      emit = custom_emit("sonoffSafetyIllumination"),
      converter = enum_converter({ [0] = "dim", [1] = "bright" }),
      data_type = data_types.Uint8,
      mfg_code = SONOFF_MANUFACTURER_CODE,
      read_only = true,
      read_on_configure = false,
    }),
  },
}

-- Actual-device identity: https://github.com/home-assistant/core/issues/175186
-- {"manufacturer":"SONOFF","model":"SNZB-05P","logical_type":"EndDevice"}
-- Independent Z2M contract/endpoint evidence:
-- https://github.com/Koenkk/zigbee2mqtt/issues/32200
-- https://github.com/Koenkk/zigbee2mqtt/issues/32231
-- ZHC 26.106.0 (e2aa714; unchanged from 26.105): IAS alarm_1 is water leak;
-- IAS bit 3 is battery_low.
-- IAS zone status is notification/report driven; only battery percentage is
-- bound, configured and read (3600/65000/change 10) during setup.
local snzb_05p = {
  profile = "sonoff-safety-water-05p",
  zcl_clusters = {
    passive_ias(zcl.water()),
    passive_ias(zcl.battery_low({ emit = battery_low_level })),
    zcl.battery({
      minimum_interval = 3600,
      maximum_interval = 65000,
      reportable_change = 10,
      read_on_configure = true,
    }),
  },
}

-- Actual-device identity: https://github.com/home-assistant/core/issues/175186
-- confirms {"manufacturer":"eWeLink","model":"SNZB-04P"}. Explicit user
-- identity authority also admits SONOFF/SNZB-04P on this identical contract.
-- ZHC ewelinkBattery() uses deliberately slow 3600/7200 reporting.
local snzb_04p = {
  profile = "sonoff-safety-contact-04p",
  zcl_clusters = {
    passive_ias(zcl.contact()),
    passive_ias(zcl.battery_low({ emit = battery_low_level })),
    zcl.cluster_attribute(SONOFF_CLUSTER, 0x2000, {
      name = "sonoff_safety_tamper",
      emit = emit.tamper(),
      from_device = function(value)
        return value == true or value == 1
      end,
      data_type = data_types.Uint8,
      mfg_code = SONOFF_MANUFACTURER_CODE,
      read_only = true,
      read_on_configure = true,
    }),
    zcl.battery({
      minimum_interval = 3600,
      maximum_interval = 7200,
      reportable_change = 2,
      read_on_configure = true,
    }),
    zcl.battery_voltage({
      minimum_interval = 3600,
      maximum_interval = 7200,
      reportable_change = 100,
      read_on_configure = true,
    }),
  },
}

-- Actual-device diagnostics and live Report Attributes frames:
-- https://github.com/zigpy/zha-device-handlers/pull/5131
-- {"manufacturer":"SONOFF","model":"SNZB-04PR2"}
-- FC11/0x2000 is UInt8 and reports with manufacturer_code=None. ZHC 26.106.0
-- (e2aa714) retains a manufacturer-specific GET, battery percentage reporting at
-- 3600/7200/change 2, and voltage GET without voltage reporting configuration.
local snzb_04pr2 = {
  profile = "sonoff-safety-contact-04p",
  zcl_clusters = {
    passive_ias(zcl.contact()),
    passive_ias(zcl.battery_low({ emit = battery_low_level })),
    zcl.cluster_attribute(SONOFF_CLUSTER, 0x2000, {
      name = "sonoff_safety_tamper",
      emit = emit.tamper(),
      from_device = function(value)
        return value == true or value == 1
      end,
      data_type = data_types.Uint8,
      read_only = true,
      read_on_configure = false,
    }),
    zcl.battery({
      minimum_interval = 3600,
      maximum_interval = 7200,
      reportable_change = 2,
      read_on_configure = true,
    }),
    zcl.power_configuration_battery_voltage({
      name = "battery_voltage",
      emit = emit.voltage(),
      scale = 10,
      read_only = true,
      read_on_configure = true,
    }),
  },
  configure = read_snzb_04pr2_tamper,
}

-- Actual-device Zigbee structure (Basic 0x0004/0x0005 and FC11 inventory):
-- https://github.com/sprut/Hub/issues/4945
-- ManufacturerName=SONOFF, ModelIdentifier=SNZB-09P, manufacturer code 0x1286.
-- ZHC 26.106.0 (e2aa714) uses a custom FC11 alert command, not IAS WD
-- StartWarning. It binds FC11, reads all GET-capable settings, configures only
-- battery reporting,
-- and filters non-100 battery reports while external power is active.
local snzb_09p = {
  profile = "sonoff-safety-siren-09p",
  sonoff_safety_snzb_09p = true,
  -- SmartThings alarm exposes siren/strobe/both separately.  Preserve ZHC's
  -- binary alert command while setting the device's sound/light attributes so
  -- each official command has the requested physical effect.
  alarm_command_modes = true,
  zcl_clusters = {
    zcl.cluster_attribute(SONOFF_CLUSTER, nil, {
      name = "alarm",
      endpoint = 1,
      write_only = true,
      sender = sonoff_alert_sender,
    }),
    zcl.cluster_attribute(SONOFF_CLUSTER, 0x0024, {
      name = "sonoff_safety_power_source",
      emit = power_source_emit,
      converter = enum_converter({ [0] = "battery", [1] = "dc" }),
      handler = remember_power_source,
      data_type = data_types.Enum8,
      read_only = true,
      read_on_configure = true,
    }),
    zcl.battery({
      emit = snzb_09p_battery_emit,
      minimum_interval = 3600,
      maximum_interval = 65000,
      reportable_change = 10,
      read_only = true,
      read_on_configure = true,
    }),
    zcl.cluster_attribute(SONOFF_CLUSTER, 0x2026, {
      name = "sonoff_safety_alarm_sound_enable",
      emit = custom_emit("sonoffSafetyAlarmSoundEnable"),
      converter = boolean_converter(),
      data_type = data_types.Boolean,
      write_type = data_types.Boolean,
      mfg_code = SONOFF_MANUFACTURER_CODE,
      read_on_configure = true,
    }),
    zcl.cluster_attribute(SONOFF_CLUSTER, 0x2022, {
      name = "sonoff_safety_alarm_light_enable",
      emit = custom_emit("sonoffSafetyAlarmLightEnable"),
      converter = boolean_converter(),
      data_type = data_types.Boolean,
      write_type = data_types.Boolean,
      mfg_code = SONOFF_MANUFACTURER_CODE,
      read_on_configure = true,
    }),
    zcl.cluster_attribute(SONOFF_CLUSTER, 0x2000, {
      name = "sonoff_safety_tamper",
      emit = emit.tamper(),
      from_device = function(value) return value == true or value == 1 end,
      data_type = data_types.Uint8,
      mfg_code = SONOFF_MANUFACTURER_CODE,
      read_only = true,
      read_on_configure = true,
    }),
    zcl.cluster_attribute(SONOFF_CLUSTER, 0x2023, {
      name = "sonoff_safety_alarm_sound_type",
      emit = custom_emit("sonoffSafetyAlarmSoundType"),
      converter = enum_converter({
        [0x00] = "siren_classic",
        [0x01] = "siren_steady",
        [0x03] = "siren_rising",
        [0x05] = "siren_warning",
        [0x06] = "siren_rapid",
        [0x08] = "siren_emergency",
        [0x02] = "tone_chirp",
        [0x04] = "tone_hi_lo",
        [0x07] = "tone_intermittent",
        [0x09] = "tone_pulse",
      }),
      data_type = data_types.Enum8,
      write_type = data_types.Enum8,
      read_on_configure = true,
    }),
    zcl.cluster_attribute(SONOFF_CLUSTER, 0x2024, {
      name = "sonoff_safety_alarm_volume",
      emit = custom_emit("sonoffSafetyAlarmVolume"),
      converter = enum_converter({ [0] = "low", [1] = "medium", [2] = "high", [3] = "max" }),
      data_type = data_types.Enum8,
      write_type = data_types.Enum8,
      read_on_configure = true,
    }),
    zcl.cluster_attribute(SONOFF_CLUSTER, 0x2025, {
      name = "sonoff_safety_alarm_duration",
      emit = custom_emit("sonoffSafetyAlarmDuration"),
      data_type = data_types.Uint16,
      write_type = data_types.Uint16,
      numeric_range = { minimum = 1, maximum = 900, step = 1, unit = "s" },
      read_on_configure = true,
    }),
  },
  configure = bind_sonoff_cluster,
}

zcl.register_cluster_command_handler(SONOFF_CLUSTER, SONOFF_ALERT_COMMAND, function(device, preset, zb_rx)
  if preset.sonoff_safety_snzb_09p ~= true then return false end
  local body = zb_rx and zb_rx.body and zb_rx.body.zcl_body or nil
  local payload = type(body) == "table" and body.body_bytes or nil
  if type(payload) ~= "string" or #payload < 2 or string.byte(payload, 1) ~= 0x04 then
    return false
  end

  local alarm_type = string.byte(payload, 2)
  local event
  if alarm_type == 0 then
    event = capabilities.alarm.alarm.off()
  elseif alarm_type == 1 or alarm_type == 2 then
    event = capabilities.alarm.alarm.siren()
  else
    return false
  end
  device:emit_component_event({ id = "main" }, event)
  return true
end)

register_device_definition(snzb_06p, {
  device_helpers.create_fingerprint("SONOFF", "SNZB-06P"),
})

register_device_definition(snzb_05p, {
  device_helpers.create_fingerprint("SONOFF", "SNZB-05P"),
})

register_device_definition(snzb_04p, {
  device_helpers.create_fingerprint("eWeLink", "SNZB-04P"),
  device_helpers.create_fingerprint("SONOFF", "SNZB-04P"),
})

register_device_definition(snzb_04pr2, {
  device_helpers.create_fingerprint("SONOFF", "SNZB-04PR2"),
})

register_device_definition(snzb_09p, {
  device_helpers.create_fingerprint("SONOFF", "SNZB-09P"),
})

return {
  id = "zcl.sensors.sonoff_safety",
  registrations = device_definitions,
}
