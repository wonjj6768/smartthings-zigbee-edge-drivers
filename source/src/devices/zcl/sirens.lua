local zcl = require "zcl_common"
local emit = require "emitters"
local device_helpers = require "devices.shared.helpers"
local data_types = require "st.zigbee.data_types"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local IAS_WARNING_DEVICE_CLUSTER = 0x0502
local IAS_WARNING_MAX_DURATION_ATTRIBUTE = 0x0000
local IAS_WARNING_VOLUME_ATTRIBUTE = 0x0002

local function clamp(value, minimum, maximum)
  if value < minimum then
    return minimum
  end

  if value > maximum then
    return maximum
  end

  return value
end

local function map_number_range(value, from_minimum, from_maximum, to_minimum, to_maximum)
  if type(value) ~= "number" then
    return nil
  end

  if from_minimum == from_maximum then
    return to_minimum
  end

  local ratio = (value - from_minimum) / (from_maximum - from_minimum)
  return to_minimum + ((to_maximum - to_minimum) * ratio)
end

local function siren_volume_from_device(value)
  if type(value) ~= "number" then
    return value
  end

  local mapped = map_number_range(value, 100, 10, 0, 100)
  if mapped == nil then
    return nil
  end

  return math.floor(clamp(mapped, 0, 100) + 0.5)
end

local function siren_volume_to_device(value)
  if type(value) ~= "number" then
    return value
  end

  local mapped = map_number_range(clamp(value, 0, 100), 0, 100, 100, 10)
  if mapped == nil then
    return nil
  end

  return math.floor(clamp(mapped, 10, 100) + 0.5)
end

local ias_siren = {
  profile = "safety-alarm-battery-volume",
  zcl_clusters = {
    zcl.alarm(),
    zcl.battery(),
    zcl.cluster_attribute(IAS_WARNING_DEVICE_CLUSTER, IAS_WARNING_VOLUME_ATTRIBUTE, {
      name = "volume",
      emit = emit.audio_volume(),
      from_device = siren_volume_from_device,
      to_device = siren_volume_to_device,
      data_type = data_types.Uint8,
      write_type = data_types.Uint8,
      read_on_configure = true,
    }),
  },
}

local ias_siren_basic = {
  profile = "safety-alarm-battery",
  zcl_clusters = {
    zcl.alarm(),
    zcl.battery(),
    zcl.cluster_attribute(IAS_WARNING_DEVICE_CLUSTER, IAS_WARNING_MAX_DURATION_ATTRIBUTE, {
      name = "max_duration",
      data_type = data_types.Uint16,
      write_type = data_types.Uint16,
      read_on_configure = true,
    }),
  },
}

register_device_definition(ias_siren, device_helpers.create_fingerprints("TS0219", {
  "_TYZB01_bwsijaty",
  "_TYZB01_rs7ff6o7",
  "_TYZB01_ynsiasng",
  "_TZ3000_vdfwjopk",
}))

register_device_definition(ias_siren_basic, device_helpers.create_fingerprints("TS0216", {
  "_TYZB01_4obovpbi",
  "_TYZB01_8scntis1",
  "_TYZB01_sbpc1zrb",
}))

register_device_definition(ias_siren_basic, {
  device_helpers.create_fingerprint("Hejhome", "GKZ-SA141"),
})

return device_definitions
