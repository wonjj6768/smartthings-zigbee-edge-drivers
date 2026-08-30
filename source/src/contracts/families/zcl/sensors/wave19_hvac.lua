-- Wave19 PirogovX ZB-MIDEA-AC source-only candidate.
-- Frozen Zigbee2MQTT v26.99.0:
--   src/devices/pirogovx.ts:1-161
--   src/converters/fromZigbee.ts:43-149
--   src/converters/toZigbee.ts:1698-1711,1862-1879
--   src/lib/constants.ts:45-56

local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local capabilities = require "st.capabilities"
local data_types = require "st.zigbee.data_types"
local device_management = require "st.zigbee.device_management"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local CLUSTER_ANALOG_INPUT = 0x000C
local CLUSTER_THERMOSTAT = 0x0201

local ATTR_POWER = 0xF000
local ATTR_MODE = 0xF001
local ATTR_FAN_MODE = 0xF002
local ATTR_SWING_MODE = 0xF003
local ATTR_PRESET = 0xF004
local ATTR_DISPLAY = 0xF005
local ATTR_INDOOR_TEMPERATURE = 0xF006
local ATTR_OUTDOOR_TEMPERATURE = 0xF007
local ATTR_TARGET_TEMPERATURE = 0xF008
local ATTR_FIRMWARE_VERSION = 0xF009

local ATTR_THERMOSTAT_LOCAL_TEMPERATURE = 0x0000
local ATTR_THERMOSTAT_OUTDOOR_TEMPERATURE = 0x0001
local ATTR_THERMOSTAT_OCCUPIED_HEATING_SETPOINT = 0x0012
local ATTR_THERMOSTAT_SYSTEM_MODE = 0x001C

local function custom(capability_id)
  return assert(emit[capability_id], "missing Wave19 PirogovX emitter: " .. capability_id)()
end

local system_mode_emit = custom("pirogovMideaSystemMode")

local function truthy(value)
  if value == true then return true end
  local numeric = tonumber(value)
  return numeric ~= nil and numeric ~= 0
end

local function boolean_state(value)
  return truthy(value) and "ON" or "OFF"
end

local function boolean_write(value)
  return value == true or value == "ON"
end

local function power_write(value, device)
  local enabled = boolean_write(value)
  if device ~= nil and type(device.emit_event) == "function" then
    device:emit_event(system_mode_emit(device, enabled and "cool" or "off"))
  end
  return enabled
end

local function valid_physical_temperature(value)
  if type(value) ~= "number" or value < -273.15 then return nil end
  return value
end

local function heating_setpoint_write(value)
  if type(value) ~= "number" or value < 16 or value > 30 then return nil end

  -- The frozen thermostat writer first rounds value*2 to one decimal, then
  -- rounds that result to an integer before dividing by two.
  local doubled_one_decimal = math.floor((value * 20) + 0.5) / 10
  return math.floor(doubled_one_decimal + 0.5) / 2
end

local function lookup_from(values, fallback)
  return function(value)
    return values[tonumber(value)] or fallback
  end
end

local function lookup_to(values)
  return function(value)
    return values[value]
  end
end

local analog_mode_from = lookup_from({
  [0] = "off",
  [1] = "auto",
  [2] = "cool",
  [3] = "heat",
  [4] = "dry",
  [5] = "fan_only",
}, "auto")

local thermostat_mode_from = lookup_from({
  [0] = "off",
  [1] = "auto",
  [3] = "cool",
  [4] = "heat",
  [7] = "fan_only",
  [8] = "dry",
}, nil)

local thermostat_mode_to = lookup_to({
  off = 0,
  auto = 1,
  cool = 3,
  heat = 4,
  fan_only = 7,
  dry = 8,
})

local fan_mode_from = lookup_from({
  [0] = "auto",
  [1] = "low",
  [2] = "medium",
  [3] = "high",
  [4] = "quiet",
}, "auto")

local fan_mode_to = lookup_to({
  auto = 0,
  low = 1,
  medium = 2,
  high = 3,
  quiet = 4,
})

local swing_mode_from = lookup_from({
  [0] = "off",
  [1] = "horizontal",
  [2] = "vertical",
  [3] = "both",
}, "off")

local swing_mode_to = lookup_to({
  off = 0,
  horizontal = 1,
  vertical = 2,
  both = 3,
})

local preset_from = lookup_from({
  [0] = "none",
  [1] = "sleep",
  [2] = "turbo",
}, "none")

local preset_to = lookup_to({
  none = 0,
  sleep = 1,
  turbo = 2,
})

local function firmware_text(value)
  if value == nil then return nil end
  return tostring(value)
end

local function configure_pirogov(driver, device)
  for _, cluster_id in ipairs({ CLUSTER_ANALOG_INPUT, CLUSTER_THERMOSTAT }) do
    device:send(device_management.build_bind_request(
      device,
      cluster_id,
      driver.environment_info.hub_zigbee_eui,
      1
    ))
  end
end

local pirogov = {
  profile = "thermostats-wave19-pirogov-zb-midea-ac",
  package_group = "wave19-hvac",
  transport_classification = "CUSTOM_PAYLOAD",
  z2m_converter_source = "fzLocal.acAnalog + fz.thermostat / tzLocal + thermostat writers",
  wire_cluster = "0x000C attrs 0xF000-0xF009 + 0x0201",
  configure = configure_pirogov,
  zcl_clusters = {
    zcl.cluster_attribute(CLUSTER_ANALOG_INPUT, ATTR_POWER, {
      name = "pirogov_midea_power",
      emit = custom("pirogovMideaPower"),
      data_type = data_types.Boolean,
      write_type = data_types.Boolean,
      from_device = boolean_state,
      to_device = power_write,
      endpoint = 1,
    }),
    zcl.cluster_attribute(CLUSTER_THERMOSTAT, ATTR_THERMOSTAT_SYSTEM_MODE, {
      name = "pirogov_midea_system_mode",
      emit = custom("pirogovMideaSystemMode"),
      data_type = data_types.Enum8,
      write_type = data_types.Enum8,
      from_device = thermostat_mode_from,
      to_device = thermostat_mode_to,
      endpoint = 1,
    }),
    zcl.cluster_attribute(CLUSTER_ANALOG_INPUT, ATTR_MODE, {
      name = "pirogov_midea_analog_system_mode_report",
      emit = custom("pirogovMideaSystemMode"),
      from_device = analog_mode_from,
      endpoint = 1,
      read_only = true,
    }),
    zcl.cluster_attribute(CLUSTER_ANALOG_INPUT, ATTR_FAN_MODE, {
      name = "pirogov_midea_fan_mode",
      emit = custom("pirogovMideaFanMode"),
      data_type = data_types.Uint8,
      write_type = data_types.Uint8,
      from_device = fan_mode_from,
      to_device = fan_mode_to,
      endpoint = 1,
    }),
    zcl.cluster_attribute(CLUSTER_ANALOG_INPUT, ATTR_SWING_MODE, {
      name = "pirogov_midea_swing_mode",
      emit = custom("pirogovMideaSwingMode"),
      data_type = data_types.Uint8,
      write_type = data_types.Uint8,
      from_device = swing_mode_from,
      to_device = swing_mode_to,
      endpoint = 1,
    }),
    zcl.cluster_attribute(CLUSTER_ANALOG_INPUT, ATTR_PRESET, {
      name = "pirogov_midea_preset",
      emit = custom("pirogovMideaPreset"),
      data_type = data_types.Uint8,
      write_type = data_types.Uint8,
      from_device = preset_from,
      to_device = preset_to,
      endpoint = 1,
    }),
    zcl.cluster_attribute(CLUSTER_ANALOG_INPUT, ATTR_DISPLAY, {
      name = "pirogov_midea_display",
      emit = custom("pirogovMideaDisplay"),
      data_type = data_types.Boolean,
      write_type = data_types.Boolean,
      from_device = boolean_state,
      to_device = boolean_write,
      endpoint = 1,
    }),
    zcl.cluster_attribute(CLUSTER_THERMOSTAT, ATTR_THERMOSTAT_LOCAL_TEMPERATURE, {
      name = "pirogov_midea_standard_local_temperature_report",
      emit = emit.temperature("C"),
      data_type = data_types.Int16,
      scale = 100,
      from_device = valid_physical_temperature,
      endpoint = 1,
      read_only = true,
    }),
    zcl.cluster_attribute(CLUSTER_ANALOG_INPUT, ATTR_INDOOR_TEMPERATURE, {
      name = "pirogov_midea_analog_local_temperature_report",
      emit = emit.temperature("C"),
      endpoint = 1,
      read_only = true,
    }),
    zcl.cluster_attribute(CLUSTER_THERMOSTAT, ATTR_THERMOSTAT_OUTDOOR_TEMPERATURE, {
      name = "pirogov_midea_outdoor_temperature",
      emit = custom("pirogovMideaOutdoorTemperature"),
      data_type = data_types.Int16,
      scale = 100,
      from_device = valid_physical_temperature,
      endpoint = 1,
      read_only = true,
    }),
    zcl.cluster_attribute(CLUSTER_ANALOG_INPUT, ATTR_OUTDOOR_TEMPERATURE, {
      name = "pirogov_midea_analog_outdoor_temperature_report",
      emit = custom("pirogovMideaOutdoorTemperature"),
      endpoint = 1,
      read_only = true,
    }),
    zcl.cluster_attribute(CLUSTER_THERMOSTAT, ATTR_THERMOSTAT_OCCUPIED_HEATING_SETPOINT, {
      name = "current_heating_setpoint",
      emit = emit.heating_setpoint("C"),
      data_type = data_types.Int16,
      write_type = data_types.Int16,
      scale = 100,
      from_device = valid_physical_temperature,
      to_device = heating_setpoint_write,
      endpoint = 1,
    }),
    zcl.cluster_attribute(CLUSTER_ANALOG_INPUT, ATTR_TARGET_TEMPERATURE, {
      name = "pirogov_midea_analog_target_temperature_report",
      emit = emit.heating_setpoint("C"),
      endpoint = 1,
      read_only = true,
    }),
    zcl.cluster_attribute(CLUSTER_ANALOG_INPUT, ATTR_FIRMWARE_VERSION, {
      name = "pirogov_midea_firmware_version",
      emit = custom("pirogovMideaFirmwareVersion"),
      from_device = firmware_text,
      endpoint = 1,
      read_only = true,
    }),
  },
}

pirogov.heating_setpoint_range = {
  minimum = 16,
  maximum = 30,
  step = 1,
  unit = "C",
}

pirogov.runtime_start = function(device)
  device:emit_component_event(
    { id = "main" },
    capabilities.thermostatHeatingSetpoint.heatingSetpointRange({
      value = {
        minimum = pirogov.heating_setpoint_range.minimum,
        maximum = pirogov.heating_setpoint_range.maximum,
        step = pirogov.heating_setpoint_range.step,
      },
      unit = pirogov.heating_setpoint_range.unit,
    })
  )
end

register_device_definition(pirogov, {
  device_helpers.create_fingerprint("PirogovX", "ZB-MIDEA-AC"),
})

return {
  id = "zcl.sensors.wave19_hvac",
  registrations = device_definitions,
}
