local shared_helpers = require "devices.shared.helpers"

local ef00_helpers = {}

function ef00_helpers.copy_options(options, overrides)
  local result = {}

  if type(options) == "table" then
    for key, value in pairs(options) do
      result[key] = value
    end
  end

  if type(overrides) == "table" then
    for key, value in pairs(overrides) do
      result[key] = value
    end
  end

  return result
end

function ef00_helpers.register_query_definition(register_device_definition, definition, fingerprints)
  local entry = ef00_helpers.copy_options(definition)
  entry.query_on_configure = true
  register_device_definition(entry, fingerprints)
end

function ef00_helpers.ts0601_fingerprints(manufacturer_names)
  return shared_helpers.create_fingerprints("TS0601", manufacturer_names)
end

function ef00_helpers.capability_range(minimum, maximum, step)
  return {
    minimum = minimum,
    maximum = maximum,
    step = step,
  }
end

function ef00_helpers.capability_values(values)
  local result = {}
  for _, value in ipairs(values or {}) do
    result[#result + 1] = value
  end
  return result
end

function ef00_helpers.merge_datapoints(...)
  local result = {}

  for index = 1, select("#", ...) do
    local datapoints = select(index, ...)
    if type(datapoints) == "table" then
      for _, datapoint in ipairs(datapoints) do
        result[#result + 1] = datapoint
      end
    end
  end

  return result
end

return ef00_helpers
