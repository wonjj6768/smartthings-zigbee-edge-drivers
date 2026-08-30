local capabilities = require "st.capabilities"

local energy_reset = {}

local OFFSET_FIELD_PREFIX = "__energy_meter_offset:"
local RAW_FIELD_PREFIX = "__energy_meter_raw:"

local function normalized_component_id(component_id)
  if type(component_id) == "string" and component_id ~= "" then
    return component_id
  end

  return "main"
end

local function offset_field(component_id)
  return OFFSET_FIELD_PREFIX .. normalized_component_id(component_id)
end

local function raw_field(component_id)
  return RAW_FIELD_PREFIX .. normalized_component_id(component_id)
end

local function current_offset(device, component_id)
  local offset = device:get_field(offset_field(component_id))
  if type(offset) == "number" then
    return offset
  end

  return 0
end

function energy_reset.apply_report(device, raw_value, component_id)
  if type(raw_value) ~= "number"
    or type(device) ~= "table"
    or type(device.get_field) ~= "function"
    or type(device.set_field) ~= "function" then
    return raw_value
  end

  component_id = normalized_component_id(component_id)
  device:set_field(raw_field(component_id), raw_value, { persist = false })

  local offset = current_offset(device, component_id)
  if raw_value < offset then
    device:set_field(offset_field(component_id), 0, { persist = true })
    return raw_value
  end

  return raw_value - offset
end

function energy_reset.handle_reset(_, device, command)
  local component_id = normalized_component_id(command and command.component)
  local offset = current_offset(device, component_id)
  local latest_raw = device:get_field(raw_field(component_id))

  if type(latest_raw) == "number" then
    offset = latest_raw
  else
    local latest_value = device:get_latest_state(
      component_id,
      capabilities.energyMeter.ID,
      capabilities.energyMeter.energy.NAME,
      0
    )
    if type(latest_value) == "number" then
      offset = offset + latest_value
    end
  end

  device:set_field(offset_field(component_id), offset, { persist = true })
  device:emit_component_event(
    { id = component_id },
    capabilities.energyMeter.energy({ value = 0.0, unit = "kWh" })
  )
end

return energy_reset
