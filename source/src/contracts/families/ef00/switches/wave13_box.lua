-- Wave13 BOX EWS1154-Z source-only candidate.
-- Frozen Zigbee2MQTT v26.99.0: src/devices/box.ts:258-336.

local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"

local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()

local function custom(name)
  return assert(emit[name], "missing Wave13 custom emitter: " .. name)()
end

local scenes = {}
for index = 1, 10 do scenes["scene_" .. tostring(index)] = index - 1 end

local clear_scenes = {}
for index = 1, 10 do clear_scenes["scene_" .. tostring(index)] = index + 9 end

local ews = {
  profile = "switches-wave13-box-ews1154z",
  package_group = "switch-panel",
  transport_classification = "EF00_DP",
  z2m_converter_source = "modernExtend.dp*",
  wire_cluster = "manuSpecificTuya",
  magic_packet = true,
  query_on_configure = false,
  datapoints = {
    tuya.dp_on_off(0x13, { name = "switch", component = "main", emit = emit.switch() }),
    tuya.dp_enum(0x66, {
      name = "box_ews_record_rf",
      converter = converter.lookup_from_to({ record = 0 }),
      emit = custom("boxEwsRecordRf"),
    }),
    tuya.dp_enum(0x66, {
      name = "box_ews_clear_rf",
      converter = converter.lookup_from_to({ clear = 1 }),
      emit = custom("boxEwsClearRf"),
    }),
    tuya.dp_enum(0x67, {
      name = "box_ews_rf_status",
      read_only = true,
      converter = converter.lookup_from_to({ ok = 0, error = 1 }),
      emit = custom("boxEwsRfStatus"),
    }),
    tuya.dp_enum(0x68, {
      name = "box_ews_record_scene",
      converter = converter.lookup_from_to(scenes),
      emit = custom("boxEwsRecordScene"),
    }),
    tuya.dp_enum(0x68, {
      name = "box_ews_clear_scene",
      converter = converter.lookup_from_to(clear_scenes),
      emit = custom("boxEwsClearScene"),
    }),
    tuya.dp_enum(0x69, {
      name = "box_ews_rf_scene_status",
      read_only = true,
      converter = converter.lookup_from_to({ ok = 0, error = 1 }),
      emit = custom("boxEwsRfSceneStatus"),
    }),
  },
}

for index = 1, 10 do
  ews.datapoints[#ews.datapoints + 1] = tuya.dp_enum(index, {
    name = "box_ews_scene_action",
    read_only = true,
    converter = converter.from_only(function(value)
      return tonumber(value) == 0 and ("scene_" .. tostring(index)) or nil
    end),
    emit = custom("boxEwsSceneAction"),
  })
end

register_device_definition(ews, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_yp5tsi3y",
}))

return {
  id = "ef00.switches.wave13.box",
  registrations = device_definitions,
}
