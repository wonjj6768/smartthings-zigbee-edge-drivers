local tuya = require "tuya_common"
local emit = require "emitters"
local device_helpers = require "devices.shared.helpers"
local ef00_helpers = require "devices.ef00.helpers"
local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()
local BAC003_POWER_FIELD = "bac003_power_state"
local BAC003_MODE_FIELD = "bac003_system_mode_device"
local XZ_AKT101_POWER_FIELD = "xz_akt101_power_state"
local XZ_AKT101_MODE_FIELD = "xz_akt101_system_mode_device"
local HY08WE_POWER_FIELD = "hy08we_power_state"
local HY08WE_MODE_FIELD = "hy08we_system_mode_device"
local ETOP_POWER_FIELD = "etop_power_state"
local ETOP_MODE_FIELD = "etop_system_mode_device"
local TYBAC_POWER_FIELD = "tybac_power_state"
local TYBAC_MODE_FIELD = "tybac_system_mode_device"
local HHST_POWER_FIELD = "hhst_power_state"
local HHST_MODE_FIELD = "hhst_system_mode_device"
local TV02_HEATING_STOP_FIELD = "tv02_heating_stop"
local TV02_PRESET_MODE_FIELD = "tv02_preset_mode"
local function valve_position_to_running_state(value)
  local numeric = tonumber(value)
  if numeric == nil then
    return nil
  end
  if numeric > 0 then
    return "heating"
  end
  return "idle"
end
local function thermostat_variant1_mode_from_device(value)
  local numeric = tonumber(value)
  local lookup = {
    [0] = "auto",
    [1] = "heat",
    [2] = "off",
    [3] = "heat",
  }
  return lookup[numeric]
end
local function thermostat_variant1_mode_to_device(value)
  local lookup = {
    auto = 0,
    heat = 1,
    off = 2,
  }
  return lookup[value]
end
local function thermostat_variant3_running_state(value)
  local numeric = tonumber(value)
  if numeric == nil then
    return nil
  end
  if numeric == 0 then
    return "heating"
  end
  return "idle"
end
local function thermostat_variant14_mode_from_preset(value)
  local numeric = tonumber(value)
  if numeric == nil then
    return nil
  end
  if numeric == 6 then
    return "off"
  end
  return "heat"
end
local function thermostat_variant14_mode_to_preset(value)
  if value == "off" then
    return 6
  end
  if value == "heat" then
    return 0
  end
  return nil
end
local function thermostat_gtz10_mode_from_device(value)
  local numeric = tonumber(value)
  local lookup = {
    [0] = "heat",
    [1] = "auto",
    [2] = "heat",
    [3] = "heat",
    [4] = "heat",
    [5] = "off",
  }
  return lookup[numeric]
end
local function thermostat_gtz10_mode_to_device(value)
  local lookup = {
    heat = 0,
    auto = 1,
    off = 5,
  }
  return lookup[value]
end
local function saswell_system_mode_write(_, value)
  if value ~= "off" and value ~= "heat" and value ~= "auto" then
    return nil
  end
  return {
    { dp = 101, datatype = tuya.DP_TYPE_BOOL, value = value ~= "off" },
    { dp = 108, datatype = tuya.DP_TYPE_BOOL, value = value == "auto" },
  }
end
local function bac003_state_from_device(value, device)
  local is_on = value == true
  device:set_field(BAC003_POWER_FIELD, is_on, { persist = false })
  if not is_on then
    return "off"
  end
  return device:get_field(BAC003_MODE_FIELD) or "cool"
end
local function bac003_mode_from_device(value, device)
  local lookup = {
    [0] = "cool",
    [1] = "heat",
    [2] = "fanonly",
  }
  local mode = lookup[tonumber(value)]
  if mode == nil then
    return nil
  end
  device:set_field(BAC003_MODE_FIELD, mode, { persist = false })
  if device:get_field(BAC003_POWER_FIELD) == false then
    return "off"
  end
  return mode
end
local function bac003_system_mode_write(_, value)
  local mode_lookup = {
    cool = 0,
    heat = 1,
    fanonly = 2,
  }
  if value == "off" then
    return {
      { dp = 1, datatype = tuya.DP_TYPE_BOOL, value = false },
    }
  end
  local mode = mode_lookup[value]
  if mode == nil then
    return nil
  end
  return {
    { dp = 1, datatype = tuya.DP_TYPE_BOOL, value = true },
    { dp = 2, datatype = tuya.DP_TYPE_ENUM, value = mode },
  }
end
local function tv02_preset_mode_from_device(value, device)
  local lookup = {
    [0] = "auto",
    [1] = "heat",
    [2] = "heat",
    [3] = "heat",
  }
  local mode = lookup[tonumber(value)]
  if mode == nil then
    return nil
  end
  device:set_field(TV02_PRESET_MODE_FIELD, mode, { persist = false })
  if device:get_field(TV02_HEATING_STOP_FIELD) == true then
    return "off"
  end
  return mode
end
local function tv02_system_mode_from_device(value, device)
  local heating_stop = value == true
  device:set_field(TV02_HEATING_STOP_FIELD, heating_stop, { persist = false })
  if heating_stop then
    return "off"
  end
  return device:get_field(TV02_PRESET_MODE_FIELD) or "heat"
end
local function tv02_system_mode_write(_, value)
  if value == "off" then
    return {
      { dp = 107, datatype = tuya.DP_TYPE_BOOL, value = true },
    }
  end
  if value == "auto" then
    return {
      { dp = 2, datatype = tuya.DP_TYPE_ENUM, value = 0 },
    }
  end
  if value == "heat" then
    return {
      { dp = 2, datatype = tuya.DP_TYPE_ENUM, value = 1 },
    }
  end
  return nil
end
local function xz_akt101_state_from_device(value, device)
  local is_on = value == true
  device:set_field(XZ_AKT101_POWER_FIELD, is_on, { persist = false })
  if not is_on then
    return "off"
  end
  return device:get_field(XZ_AKT101_MODE_FIELD) or "cool"
end
local function xz_akt101_mode_from_device(value, device)
  local lookup = {
    [0] = "cool",
    [1] = "heat",
    [2] = "fanonly",
  }
  local mode = lookup[tonumber(value)]
  if mode == nil then
    return nil
  end
  device:set_field(XZ_AKT101_MODE_FIELD, mode, { persist = false })
  if device:get_field(XZ_AKT101_POWER_FIELD) == false then
    return "off"
  end
  return mode
end
local function xz_akt101_system_mode_write(_, value)
  local mode_lookup = {
    cool = 0,
    heat = 1,
    fanonly = 2,
    fan_only = 2,
  }
  if value == "off" then
    return {
      { dp = 1, datatype = tuya.DP_TYPE_BOOL, value = false },
    }
  end
  local mode = mode_lookup[value]
  if mode == nil then
    return nil
  end
  return {
    { dp = 1, datatype = tuya.DP_TYPE_BOOL, value = true },
    { dp = 2, datatype = tuya.DP_TYPE_ENUM, value = mode },
  }
end
local function hy08we_state_from_device(value, device)
  local is_on = value == true
  device:set_field(HY08WE_POWER_FIELD, is_on, { persist = false })
  if not is_on then
    return "off"
  end
  return device:get_field(HY08WE_MODE_FIELD) or "heat"
end
local function hy08we_mode_from_device(value, device)
  local lookup = {
    [0] = "heat",
    [1] = "auto",
    [2] = "heat",
  }
  local mode = lookup[tonumber(value)]
  if mode == nil then
    return nil
  end
  device:set_field(HY08WE_MODE_FIELD, mode, { persist = false })
  if device:get_field(HY08WE_POWER_FIELD) == false then
    return "off"
  end
  return mode
end
local function hy08we_system_mode_write(_, value)
  if value == "off" then
    return {
      { dp = 125, datatype = tuya.DP_TYPE_BOOL, value = false },
    }
  end
  local mode_lookup = {
    heat = 0,
    auto = 1,
  }
  local mode = mode_lookup[value]
  if mode == nil then
    return nil
  end
  return {
    { dp = 125, datatype = tuya.DP_TYPE_BOOL, value = true },
    { dp = 128, datatype = tuya.DP_TYPE_ENUM, value = mode },
  }
end
local function power_mode_from_device(power_field, mode_field, default_mode)
  return function(value, device)
    local is_on = value == true
    device:set_field(power_field, is_on, { persist = false })
    if not is_on then
      return "off"
    end
    return device:get_field(mode_field) or default_mode
  end
end
local function enum_mode_from_device(power_field, mode_field, lookup)
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
local function power_mode_write(power_dp, mode_dp, lookup)
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
local function x5h_local_temperature_from_device(value)
  local numeric = tonumber(value)
  if numeric == nil then
    return nil
  end
  if numeric >= 0x8000 then
    numeric = numeric - 0x10000 + 1
  end
  return numeric / 10
end
local bool_heat_off = converter.lookup_from_to({
  heat = true,
  off = false,
})
local enum_heat_idle_bool = converter.lookup_from_to({
  heating = true,
  idle = false,
})
local enum_heat_idle_inverted = converter.lookup_from_to({
  heating = 0,
  idle = 1,
})

local saswell_legacy = {
  profile = "thermostats-thermostat",
  named_mapping = {
    named_mappings = {
      system_mode = saswell_system_mode_write,
    },
  },
  tuya.dp_running_state(3, {
    converter = converter.lookup_from_to({
      heat = 1,
      idle = 0,
    }),
  }),
  tuya.dp_local_temperature(102, { scale = 10 }),
  tuya.dp_current_heating_setpoint(103, { scale = 10 }),
  tuya.dp_system_mode(101, {
    converter = converter.lookup_from_to({
      heat = true,
      off = false,
    }),
  }),
  tuya.dp_binary(108, {
    name = "saswell_schedule_enable",
    from_device = function(value)
      if value then
        return "auto"
      end
      return nil
    end,
    emit = emit.thermostat_mode(),
  }),
}
register_device_definition(saswell_legacy, {
  device_helpers.create_fingerprint("_TYST11_KGbxAXL2", "GbxAXL2"),
  device_helpers.create_fingerprint("_TYST11_zuhszj9s", "uhszj9s"),
  device_helpers.create_fingerprint("_TYST11_c88teujp", "88teujp"),
  device_helpers.create_fingerprint("_TYST11_yw7cahqs", "w7cahqs"),
  device_helpers.create_fingerprint("_TYST11_caj4jz0i", "aj4jz0i"),
  device_helpers.create_fingerprint("_TZE200_c88teujp", "TS0601"),
  device_helpers.create_fingerprint("_TZE200_yw7cahqs", "TS0601"),
  device_helpers.create_fingerprint("_TZE200_azqp6ssj", "TS0601"),
  device_helpers.create_fingerprint("_TZE200_zuhszj9s", "TS0601"),
  device_helpers.create_fingerprint("_TZE200_9gvruqf5", "TS0601"),
  device_helpers.create_fingerprint("_TZE200_zr9c0day", "TS0601"),
  device_helpers.create_fingerprint("_TZE200_0dvm9mva", "TS0601"),
  device_helpers.create_fingerprint("_TZE284_0dvm9mva", "TS0601"),
  device_helpers.create_fingerprint("_TZE200_h4cgnbzg", "TS0601"),
  device_helpers.create_fingerprint("_TZE200_gd4rvykv", "TS0601"),
  device_helpers.create_fingerprint("_TZE200_exfrnlow", "TS0601"),
  device_helpers.create_fingerprint("_TZE200_9m4kmbfu", "TS0601"),
  device_helpers.create_fingerprint("_TZE284_9m4kmbfu", "TS0601"),
  device_helpers.create_fingerprint("_TZE200_3yp57tby", "TS0601"),
  device_helpers.create_fingerprint("_TZE200_7p8ugv8d", "TS0601"),
  device_helpers.create_fingerprint("_TZE284_3yp57tby", "TS0601"),
})
local etop_system_mode = power_mode_write(1, 4, {
  heat = 0,
  auto = 2,
})
local thermostat_etop_legacy = {
  profile = "thermostats-thermostat",
  named_mapping = {
    named_mappings = {
      system_mode = etop_system_mode,
    },
  },
  tuya.dp_binary(1, {
    name = "system_mode",
    from_device = power_mode_from_device(ETOP_POWER_FIELD, ETOP_MODE_FIELD, "heat"),
    emit = emit.thermostat_mode(),
  }),
  tuya.dp_current_heating_setpoint(2, { scale = 10 }),
  tuya.dp_local_temperature(3, { scale = 10 }),
  tuya.dp_enum(4, {
    name = "system_mode",
    from_device = enum_mode_from_device(ETOP_POWER_FIELD, ETOP_MODE_FIELD, {
      [0] = "heat",
      [1] = "heat",
      [2] = "auto",
    }),
    emit = emit.thermostat_mode(),
    read_only = true,
  }),
  tuya.dp_child_lock(7, { name = "child_lock" }),                        -- profile 미포함
  tuya.dp_raw(13, { name = "error_status" }),                            -- profile 미포함
  tuya.dp_running_state(14, {
    converter = converter.lookup_from_to({
      heating = true,
      idle = false,
    }),
    emit = emit.thermostat_operating_state(),
  }),
}
register_device_definition(thermostat_etop_legacy, {
  device_helpers.create_fingerprint("_TZE200_2dpplnsn", "TS0601"),
  device_helpers.create_fingerprint("_TZE200_wv90ladg", "TS0601"),
  device_helpers.create_fingerprint("_TYST11_2dpplnsn", "dpplnsn"),
  device_helpers.create_fingerprint("_TYST11_wv90ladg", "v90ladg"),
})
local tybac_fan_mode = tuya.dp_fan_mode(28, {
  converter = converter.lookup_from_to({
    low = 0,
    medium = 1,
    high = 2,
    auto = 3,
  }),
  emit = emit.fan_mode(),
})
local tybac_setpoint = tuya.dp_current_heating_setpoint(16, {
  scale = 10,
  emit = emit.heating_setpoint("C"),
})

local thermostat_sas936 = {
  profile = "thermostats-thermostat",
  named_mapping = {
    named_mappings = {
      system_mode = function(_, value)
        if value == "heat" then
          return { { dp = 101, datatype = tuya.DP_TYPE_BOOL, value = true } }
        end
        if value == "off" then
          return { { dp = 101, datatype = tuya.DP_TYPE_BOOL, value = false } }
        end
        return nil
      end,
    },
  },
  tuya.dp_running_state(3, {
    converter = converter.lookup_from_to({
      heating = 1,
      idle = 0,
    }),
    emit = emit.thermostat_operating_state(),
  }),
  tuya.dp_child_lock(40, {}),                                            -- profile 미포함
  tuya.dp_system_mode(101, {
    converter = converter.lookup_from_to({
      heat = true,
      off = false,
    }),
    emit = emit.thermostat_mode(),
  }),
  tuya.dp_local_temperature(102, { scale = 10 }),
  tuya.dp_current_heating_setpoint(103, { scale = 10 }),
  tuya.dp_binary(106, { name = "temporary_leaving" }),                   -- profile 미포함
}
register_device_definition(thermostat_sas936, ef00_helpers.ts0601_fingerprints( {
  "_TZE284_madl8ejv",
}))
local thermostat_twc_r01 = {
  profile = "thermostats-thermostat-basic-twc-r01",
  tuya.dp_enum(2, {
    name = "pilot_wire_mode",
    converter = converter.lookup_from_to({
      comfort = 0,
      eco = 1,
      antifrost = 2,
      off = 3,
      comfort_1 = 4,
      comfort_2 = 5,
    }),
    emit = emit.pilotWireModeTwcR01(),
  }),
  tuya.dp_power(11, { name = "power", scale = 10 }),                     -- profile 미포함
  tuya.dp_local_temperature(16, { scale = 10 }),
  tuya.dp_local_temperature_calibration(19, { scale = 10 }),             -- profile 미포함
  tuya.dp_raw(20, { name = "fault" }),                                   -- profile 미포함
  tuya.dp_eco_mode(40, {}),                                              -- profile 미포함
  tuya.dp_binary(110, { name = "open_window" }),                         -- profile 미포함
  tuya.dp_temperature(111, { name = "open_window_temperature" }),        -- profile 미포함
  tuya.dp_binary(114, { name = "device_mode_type" }),                    -- profile 미포함
  tuya.dp_voltage(115, { name = "voltage", scale = 10 }),                -- profile 미포함
  tuya.dp_current(116, { name = "current", scale = 10 }),                -- profile 미포함
  tuya.dp_energy(117, { name = "energy", scale = 10 }),                  -- profile 미포함
  tuya.dp_energy(119, { name = "energy_today", scale = 10, emit = emit.energyTodayTwcR01() }),
  tuya.dp_energy(120, { name = "energy_yesterday", scale = 10, emit = emit.energyYesterdayTwcR01() }),
}
register_device_definition(thermostat_twc_r01, ef00_helpers.ts0601_fingerprints( {
  "_TZE204_ilzkxrav",
}))

return device_definitions
