-- Wave15 ENGO ECB62-ZB source-only candidate.
-- Frozen Zigbee2MQTT v26.99.0: src/devices/engo.ts:10-82.

local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"

local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()

local function custom(name)
  return assert(emit[name], "missing Wave15 ENGO emitter: " .. name)()
end

local ecb = {
  profile = "controls-wave15-engo-ecb62zb",
  package_group = "heating-control-box",
  transport_classification = "EF00_DP",
  z2m_converter_source = "meta.tuyaDatapoints",
  wire_cluster = "manuSpecificTuya",
  magic_packet = true,
  query_on_configure = false,
  time_start = "2000",
  datapoints = {},
}

local zone_words = { "One", "Two", "Three", "Four", "Five", "Six" }
for index, word in ipairs(zone_words) do
  ecb.datapoints[#ecb.datapoints + 1] = tuya.dp_binary(index, {
    name = "ecb_zone_" .. string.lower(word) .. "_demand",
    read_only = true,
    transaction = 1,
    converter = converter.from_only(function(value) return value and "ON" or "OFF" end),
    emit = custom("ecbZone" .. word .. "Demand"),
  })
end

ecb.datapoints[#ecb.datapoints + 1] = tuya.dp_binary(101, {
  name = "ecb_pump_state", read_only = true, transaction = 1,
  converter = converter.from_only(function(value) return value and "ON" or "OFF" end),
  emit = custom("ecbPumpState"),
})
ecb.datapoints[#ecb.datapoints + 1] = tuya.dp_binary(102, {
  name = "ecb_boiler_state", read_only = true, transaction = 1,
  converter = converter.from_only(function(value) return value and "ON" or "OFF" end),
  emit = custom("ecbBoilerState"),
})
ecb.datapoints[#ecb.datapoints + 1] = tuya.dp_binary(103, {
  name = "ecb_zone_a_demand", read_only = true, transaction = 1,
  converter = converter.from_only(function(value) return value and "ON" or "OFF" end),
  emit = custom("ecbZoneADemand"),
})
ecb.datapoints[#ecb.datapoints + 1] = tuya.dp_binary(104, {
  name = "ecb_zone_b_demand", read_only = true, transaction = 1,
  converter = converter.from_only(function(value) return value and "ON" or "OFF" end),
  emit = custom("ecbZoneBDemand"),
})

for index, word in ipairs(zone_words) do
  ecb.datapoints[#ecb.datapoints + 1] = tuya.dp_binary(104 + index, {
    name = "ecb_zone_" .. string.lower(word) .. "_linked",
    read_only = true,
    transaction = 1,
    converter = converter.from_only(function(value) return value and "ON" or "OFF" end),
    emit = custom("ecbZone" .. word .. "Linked"),
  })
end

local name_rows = {
  { 111, "a", "A" }, { 112, "b", "B" },
  { 113, "one", "One" }, { 114, "two", "Two" },
  { 115, "three", "Three" }, { 116, "four", "Four" },
  { 117, "five", "Five" }, { 118, "six", "Six" },
}
for _, row in ipairs(name_rows) do
  ecb.datapoints[#ecb.datapoints + 1] = tuya.dp_string(row[1], {
    name = "ecb_zone_" .. row[2] .. "_name",
    transaction = 1,
    emit = custom("ecbZone" .. row[3] .. "Name"),
  })
end

ecb.datapoints[#ecb.datapoints + 1] = tuya.dp_enum(119, {
  name = "ecb_pump_delay_time",
  transaction = 1,
  converter = converter.lookup_from_to({ OFF = 0, ["3_min"] = 1, ["5_min"] = 2, ["15_min"] = 3 }),
  emit = custom("ecbPumpDelay"),
})
ecb.datapoints[#ecb.datapoints + 1] = tuya.dp_numeric(120, {
  name = "voltage",
  read_only = true,
  transaction = 1,
  converter = converter.divide_by_pair(10),
  emit = emit.voltage(),
})

register_device_definition(ecb, device_helpers.create_fingerprints("TS0601", {
  "_TZE200_oahqgdig",
  "_TZE200_zaabefnt",
}))

return {
  id = "ef00.controls.wave15_engo",
  registrations = device_definitions,
}
