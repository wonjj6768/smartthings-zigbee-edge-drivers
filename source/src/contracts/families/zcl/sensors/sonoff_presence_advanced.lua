-- SONOFF advanced presence sensor contracts.
-- Oracle: zigbee-herdsman-converters 26.106.0, FETCH_HEAD e2aa714 (sonoff.ts).
-- Exact identity and live attribute types/ranges:
-- https://github.com/zigpy/zha-device-handlers/pull/4714
-- https://github.com/user-attachments/files/24998829/sonoff_snzb03pr2_diagnostics.json

local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local data_types = require "st.zigbee.data_types"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local CLUSTER_OCCUPANCY = 0x0406
local CLUSTER_EWELINK = 0xFC11

local ATTR_OCCUPANCY = 0x0000
local ATTR_PIR_OCCUPIED_TO_UNOCCUPIED_DELAY = 0x0010
local ATTR_PIR_DELAY_RAW_ALIAS = 0x3C00
local ATTR_ILLUMINATION_COMPENSATION_OFFSET = 0x2018

local function custom(capability_id)
  return assert(emit[capability_id], "missing SONOFF presence emitter: " .. capability_id)()
end

local function occupancy_from_device(value)
  value = type(value) == "table" and value.value or value
  if type(value) ~= "number" then return nil end
  return bit32.band(value, 0x01) ~= 0
end

local function passive_report(mapping)
  mapping.minimum_interval = nil
  mapping.maximum_interval = nil
  mapping.reportable_change = nil
  mapping.read_on_configure = false
  mapping.read_only = true
  return mapping
end

local detection_duration_emit = custom("sonoffSnzb03pr2DetectionDuration")

-- SNZB-03PR2 is intentionally independent from SNZB-03P.  The newer device
-- uses PIR delay attribute 0x0010, reports standard illuminance, and adds the
-- signed FC11 illumination offset at 0x2018.  ZHC disables occupancy and
-- illuminance reporting configuration.  modernExtend occupancy({reporting:
-- false}) does not configure or read occupancy, while numeric illuminance with
-- STATE_GET still performs a configure-time read.  Both mappings accept the
-- device's spontaneous reports.
local snzb_03pr2 = {
  profile = "sonoff-snzb03pr2-occupancy",
  zcl_clusters = {
    passive_report(zcl.cluster_attribute(CLUSTER_OCCUPANCY, ATTR_OCCUPANCY, {
      name = "occupancy",
      endpoint = 1,
      emit = emit.occupancy(),
      data_type = data_types.Bitmap8,
      from_device = occupancy_from_device,
    })),
    zcl.illuminance({
      endpoint = 1,
      configure_reporting = false,
      data_type = data_types.Uint16,
      read_only = true,
      read_on_configure = true,
    }),
    zcl.battery({
      endpoint = 1,
      data_type = data_types.Uint8,
      minimum_interval = 3600,
      maximum_interval = 65000,
      reportable_change = 10,
      read_only = true,
      read_on_configure = true,
    }),
    zcl.cluster_attribute(CLUSTER_OCCUPANCY, ATTR_PIR_OCCUPIED_TO_UNOCCUPIED_DELAY, {
      name = "sonoff_snzb03pr2_detection_duration",
      endpoint = 1,
      emit = detection_duration_emit,
      data_type = data_types.Uint16,
      write_type = data_types.Uint16,
      numeric_range = { minimum = 5, maximum = 60, step = 1, unit = "s" },
      read_on_configure = true,
    }),
    -- This device can report the same delay through raw attribute key 15360
    -- (0x3C00).  Accept that wire form for state synchronization only; reads
    -- and writes remain on the canonical 0x0010 attribute above.
    zcl.cluster_attribute(CLUSTER_OCCUPANCY, ATTR_PIR_DELAY_RAW_ALIAS, {
      name = "sonoff_snzb03pr2_detection_duration_raw_alias",
      endpoint = 1,
      emit = detection_duration_emit,
      data_type = data_types.Uint16,
      read_only = true,
      read_on_configure = false,
    }),
    zcl.cluster_attribute(CLUSTER_EWELINK, ATTR_ILLUMINATION_COMPENSATION_OFFSET, {
      name = "sonoff_snzb03pr2_illumination_offset",
      endpoint = 1,
      emit = custom("sonoffSnzb03pr2IlluminationOffset"),
      data_type = data_types.Int16,
      write_type = data_types.Int16,
      numeric_range = { minimum = -1000, maximum = 1000, step = 1, unit = "lx" },
      -- Latest ZHC and the current ZHA PR both use a normal FC11 attribute
      -- frame for this item, with no manufacturer-specific ZCL header.
      read_on_configure = true,
    }),
  },
}

register_device_definition(snzb_03pr2, {
  device_helpers.create_fingerprint("SONOFF", "SNZB-03PR2"),
})

return {
  id = "zcl.sensors.sonoff_presence_advanced",
  registrations = device_definitions,
}
