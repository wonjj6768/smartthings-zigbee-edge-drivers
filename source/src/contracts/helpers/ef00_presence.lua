-- Helpers shared by multiple package-owned presence registries.

local tuya = require "protocol.tuya"
local ef00_helpers = require "contracts.helpers.ef00"

local converter = tuya.converter

local function isolated_definition_registry(device_helpers)
  local shared_definitions, shared_register = device_helpers.definition_registry()
  local device_definitions = {}

  local function register_device_definition(definition, fingerprints)
    local previous_count = #shared_definitions
    shared_register(definition, fingerprints)
    for index = previous_count + 1, #shared_definitions do
      device_definitions[#device_definitions + 1] = shared_definitions[index]
    end
  end

  return device_definitions, register_device_definition
end

local function register_presence_definition(register_device_definition, definitions_or_table, fingerprint_list, ranges)
  local query_on_configure = true
  if type(definitions_or_table) == "table" and definitions_or_table.query_on_configure ~= nil then
    query_on_configure = definitions_or_table.query_on_configure
  end

  if type(ranges) == "table" then
    register_device_definition({
      datapoints = definitions_or_table,
      presence_capability_ranges = ranges,
      query_on_configure = query_on_configure,
    }, fingerprint_list)
    return
  end

  if type(definitions_or_table) == "table" then
    local entry = {}
    for key, value in pairs(definitions_or_table) do
      entry[key] = value
    end
    if entry.query_on_configure == nil then
      entry.query_on_configure = true
    end
    register_device_definition(entry, fingerprint_list)
    return
  end

  register_device_definition({
    datapoints = definitions_or_table,
    query_on_configure = true,
  }, fingerprint_list)
end

local on_off_bool_converter = converter.lookup_from_to({
  on = true,
  off = false,
})

local msa201_presence_converter = converter.from_only(function(value)
  return tonumber(value) == 1
end)

return {
  isolated_definition_registry = isolated_definition_registry,
  register_presence_definition = register_presence_definition,
  ts0601_fingerprints = ef00_helpers.ts0601_fingerprints,
  on_off_bool_converter = on_off_bool_converter,
  msa201_presence_converter = msa201_presence_converter,
}
