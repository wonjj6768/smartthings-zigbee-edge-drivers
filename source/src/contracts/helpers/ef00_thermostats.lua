local tuya = require "protocol.tuya"

local thermostat_common = {}

function thermostat_common.valve_position_to_running_state(value)
  local numeric = tonumber(value)
  if numeric == nil then
    return nil
  end
  if numeric > 0 then
    return "heating"
  end
  return "idle"
end

function thermostat_common.variant1_mode_from_device(value)
  local lookup = {
    [0] = "auto",
    [1] = "heat",
    [2] = "off",
    [3] = "heat",
  }
  return lookup[tonumber(value)]
end

function thermostat_common.variant1_mode_to_device(value)
  local lookup = {
    auto = 0,
    heat = 1,
    off = 2,
  }
  return lookup[value]
end

function thermostat_common.power_mode_from_device(power_field, mode_field, default_mode)
  return function(value, device)
    local is_on = value == true
    device:set_field(power_field, is_on, { persist = false })
    if not is_on then
      return "off"
    end
    return device:get_field(mode_field) or default_mode
  end
end

function thermostat_common.enum_mode_from_device(power_field, mode_field, lookup)
  return function(value, device)
    local mode = lookup[tonumber(value)]
    if mode == nil then
      return nil
    end
    device:set_field(mode_field, mode, { persist = false })
    if device:get_field(power_field) == false then
      return "off"
    end
    return mode
  end
end

function thermostat_common.power_mode_write(power_dp, mode_dp, lookup)
  return function(_, value)
    if value == "off" then
      return {
        { dp = power_dp, datatype = tuya.DP_TYPE_BOOL, value = false },
      }
    end
    local mode = lookup[value]
    if mode == nil then
      return nil
    end
    return {
      { dp = power_dp, datatype = tuya.DP_TYPE_BOOL, value = true },
      { dp = mode_dp, datatype = tuya.DP_TYPE_ENUM, value = mode },
    }
  end
end

function thermostat_common.binary_power_schedule_mode_write(power_dp, schedule_dp)
  return function(_, value)
    if value ~= "off" and value ~= "heat" and value ~= "auto" then
      return nil
    end
    return {
      { dp = power_dp, datatype = tuya.DP_TYPE_BOOL, value = value ~= "off" },
      { dp = schedule_dp, datatype = tuya.DP_TYPE_BOOL, value = value == "auto" },
    }
  end
end

function thermostat_common.true_mode_from_device(mode)
  return function(value)
    if value then
      return mode
    end
    return nil
  end
end

function thermostat_common.boolean_label_from_device(false_label, true_label)
  return function(value)
    if value then
      return true_label
    end
    return false_label
  end
end

function thermostat_common.x5h_local_temperature_from_device(value)
  local numeric = tonumber(value)
  if numeric == nil then
    return nil
  end
  if numeric >= 0x8000 then
    numeric = numeric - 0x10000 + 1
  end
  return numeric / 10
end

local function error_or_battery_low_value(value)
  local numeric = tonumber(value)
  if numeric == nil or numeric % 1 ~= 0 or numeric < 0 or numeric > 0xFFFFFFFF then
    return nil
  end
  return numeric
end

function thermostat_common.error_or_battery_low_emitter(error_emitter, battery_emitter)
  return function(device, value, ...)
    local events = {}
    if value.error ~= nil and value.error <= 0xFF then
      local error_event = error_emitter(device, value.error, ...)
      if error_event ~= nil then events[#events + 1] = error_event end
    end
    local battery_event = battery_emitter(device, value.battery_low, ...)
    if battery_event ~= nil then events[#events + 1] = battery_event end
    return events
  end
end

function thermostat_common.error_or_battery_low_state(value)
  local numeric = error_or_battery_low_value(value)
  if numeric == nil then
    return nil
  end
  return numeric == 1 and "low" or "normal"
end

return thermostat_common
