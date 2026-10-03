local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local capabilities = require "st.capabilities"
local data_types = require "st.zigbee.data_types"
local cluster_base = require "st.zigbee.cluster_base"

local device_definitions, register_device_definition = device_helpers.definition_registry()
local SENSOR_MODES = { [0] = "air", "floor", "air_floor", "external", "external_floor", "floor_percent", "regulator" }
local SCREEN_TIMES = { [0] = "always_on", "10s", "30s", "60s" }
local PROGRAM_MODES = { [0] = "setpoint", [1] = "schedule", [4] = "eco" }

local function scalar(value)
  if type(value) == "table" then return value.value end
  return value
end

local function read_edge(device, attribute)
  device:send(cluster_base.read_attribute(
    device, data_types.ClusterId(0x0201), data_types.AttributeId(attribute)):to_endpoint(1))
end

-- This firmware requires a default response and, for some settings, a prior read.
local function write_edge(device, attribute, typed_value, read_before, read_after)
  if read_before then read_edge(device, attribute) end
  local request = cluster_base.write_attribute(
    device, data_types.ClusterId(0x0201), data_types.AttributeId(attribute), typed_value):to_endpoint(1)
  request.body.zcl_header.frame_ctrl:unset_disable_default_response()
  device:send(request)
  if read_after then
    device.thread:call_with_delay(1, function()
      for _, attr in ipairs(read_after) do read_edge(device, attr) end
    end)
  end
end

local function sync_edge_time(device, read_before)
  local local_unix = os.time() + (device:get_field("nam_edge_time_zone") or 0) * 3600
  write_edge(device, 0x800B, data_types.Uint32(local_unix), read_before)
  write_edge(device, 0x800A, data_types.Boolean(false), read_before)
  read_edge(device, 0x800B)
  return true
end

local function remember_mode(device, name, value, context)
  if context then
    for _, record in ipairs(context.zb_rx.body.zcl_body.attr_records or {}) do
      if record.data then
        local attr, raw = record.attr_id.value, scalar(record.data)
        local item, state
        if attr == 0x001C then item, state = "system_mode", ({ [0] = "off", [3] = "cool", [4] = "heat" })[raw]
        elseif attr == 0x0025 then item, state = "programming_operation_mode", PROGRAM_MODES[raw]
        elseif attr == 0x8001 then item, state = "frost", (raw == true or raw == 1) and "ON" or "OFF"
        elseif attr == 0x8004 then item, state = "sensor_mode", SENSOR_MODES[raw]
        elseif attr == 0x801F then item, state = "vacation_mode", (raw == true or raw == 1) and "ON" or "OFF"
        elseif attr == 0x8023 then item, state = "countdown_set", raw * 5 end
        if item and state ~= nil then device:set_field("nam_edge_" .. item, state, { persist = true }) end
      end
    end
  end
  if value == nil then return nil end
  device:set_field("nam_edge_" .. name, value, { persist = true })
  local mode = "manual"
  if device:get_field("nam_edge_frost") == "ON" then mode = "frost"
  elseif device:get_field("nam_edge_vacation_mode") == "ON" then mode = "holiday"
  elseif device:get_field("nam_edge_sensor_mode") == "regulator" then mode = "regulator"
  elseif (device:get_field("nam_edge_countdown_set") or 0) > 0 then mode = "countdown"
  elseif device:get_field("nam_edge_programming_operation_mode") == "schedule" then mode = "schedule"
  elseif device:get_field("nam_edge_programming_operation_mode") == "eco" then mode = "eco" end
  device:emit_component_event({ id = "main" }, emit.namEdgeThermostatMode()(device, mode))
  return value
end

local function edge_setting_sender(device, mapping, value, context)
  local meta = zcl.mapping_meta(mapping)
  local attr = meta.attribute_id
  if attr == 0x8004 and value == "regulator" and device:get_field("nam_edge_system_mode") == "cool" then return false end
  if attr == 0x8023 and device:get_field("nam_edge_system_mode") == "cool" then return false end
  local encoded = value
  if meta.to_device then encoded = meta.to_device(value, device, context, mapping) end
  if encoded == nil then return false end
  local before = attr == 0x8000 or attr == 0x8001 or attr == 0x8004 or attr == 0x8005 or
    attr == 0x801F or attr == 0x8020 or attr == 0x8021 or attr == 0x8022 or attr == 0x8023 or attr == 0x8029
  local after = attr == 0x8004 and { 0x8004, 0x801D, 0x8007 } or
    (attr == 0x8005 or attr == 0x8029) and { attr } or nil
  write_edge(device, attr, meta.data_type(encoded), before, after)
  if attr == 0x8001 then remember_mode(device, "frost", value)
  elseif attr == 0x8004 then remember_mode(device, "sensor_mode", value)
  elseif attr == 0x801F then remember_mode(device, "vacation_mode", value)
  elseif attr == 0x8023 then
    remember_mode(device, "countdown_set", value)
    device:emit_component_event({ id = "main" }, emit.namEdgeCountdownLeft()(device, value))
  end
  return true
end

local function date_from_device(value)
  if value == 0 then return nil end
  local date = string.format("%06d", value)
  return "20" .. date:sub(1, 2) .. "-" .. date:sub(3, 4) .. "-" .. date:sub(5, 6)
end

local function date_to_device(value)
  local year, month, day = value:match("^20(%d%d)%-(%d%d)%-(%d%d)$")
  if year == nil then return nil end
  return tonumber(year .. month .. day)
end

local namron_edge = {
  profile = "thermostats-namron-edge",
  thermostat_supported_modes = { "off", "heat", "cool" },
  heating_setpoint_range = { minimum = 5, maximum = 35, step = 0.5, unit = "C" },
  cooling_setpoint_range = { minimum = 10, maximum = 40, step = 0.5, unit = "C" },
  runtime_start = function(device)
    device:emit_component_event({ id = "main" }, capabilities.thermostatMode.supportedThermostatModes({ "off", "heat", "cool" }))
    device:emit_component_event({ id = "main" }, capabilities.thermostatHeatingSetpoint.heatingSetpointRange({
      value = { minimum = 5, maximum = 35, step = 0.5 }, unit = "C",
    }))
    device:emit_component_event({ id = "main" }, capabilities.thermostatCoolingSetpoint.coolingSetpointRange({
      value = { minimum = 10, maximum = 40, step = 0.5 }, unit = "C",
    }))
    device:emit_component_event({ id = "main" }, emit.namEdgeTimeZone()(device, device:get_field("nam_edge_time_zone") or 0))
  end,
  protocol_writers = {
    nam_edge_time_zone = function(device, offset)
      device:set_field("nam_edge_time_zone", offset, { persist = true })
      return sync_edge_time(device, true)
    end,
  },
  zcl_clusters = {
    zcl.switch({ endpoint = 1, configure_reporting = true, minimum_interval = 0, maximum_interval = 65000 }),
    zcl.local_temperature({ endpoint = 1, read_only = true, minimum_interval = 10, maximum_interval = 300, reportable_change = 10 }),
    zcl.heating_setpoint({ endpoint = 1, minimum_interval = 10, maximum_interval = 300, reportable_change = 50,
      to_device = function(value) return math.max(5, math.min(35, math.floor(value * 2 + 0.5) / 2)) end,
    }),
    zcl.cooling_setpoint({ endpoint = 1, minimum_interval = 10, maximum_interval = 300, reportable_change = 50,
      to_device = function(value) return math.max(10, math.min(40, math.floor(value * 2 + 0.5) / 2)) end,
    }),
    zcl.thermostat_system_mode({ endpoint = 1, name = "system_mode", emit = emit.thermostat_mode(), read_on_configure = true,
      from_device = function(value, device, context)
        return remember_mode(device, "system_mode", ({ [0] = "off", [3] = "cool", [4] = "heat" })[scalar(value)], context)
      end,
      sender = function(device, mapping, value)
        if value == "cool" and device:get_field("nam_edge_sensor_mode") == "regulator" then return false end
        local raw = ({ off = 0, cool = 3, heat = 4 })[value]
        if raw == nil then return false end
        write_edge(device, 0x001C, data_types.Enum8(raw))
        remember_mode(device, "system_mode", value)
        return true
      end,
    }),
    zcl.thermostat_running_state({ endpoint = 1, name = "thermostat_operating_state", read_only = true, read_on_configure = true,
      emit = emit.thermostat_operating_state(),
      from_device = function(value) return ({ [0] = "idle", [1] = "heating", [2] = "cooling" })[scalar(value)] end,
    }),
    zcl.humidity({ endpoint = 1, read_only = true, minimum_interval = 10, maximum_interval = 300, reportable_change = 100 }),
    zcl.cluster_attribute(0x0B04, 0x050B, { endpoint = 1, name = "power", emit = emit.power(), data_type = data_types.Int16,
      metering_kind = "power", scale = 1, read_only = true, read_on_configure = true }),
    zcl.cluster_attribute(0x0B04, 0x0508, { endpoint = 1, name = "current", emit = emit.current(), data_type = data_types.Uint16,
      metering_kind = "current", scale = 1, read_only = true, read_on_configure = true }),
    zcl.cluster_attribute(0x0702, 0x0000, { endpoint = 1, name = "energy", emit = emit.energy(), data_type = data_types.Uint48,
      metering_kind = "energy", scale = 1, read_only = true, read_on_configure = true }),
    zcl.cluster_attribute(0x0201, 0x0010, {
      endpoint = 1, name = "nam_edge_temperature_calibration", emit = emit.namEdgeTemperatureCalibration(),
      data_type = data_types.Int8, read_on_configure = true,
      from_device = function(value) return value / 10 end,
      to_device = function(value) return math.floor(value * 10 + 0.5) end,
    }),
    zcl.cluster_attribute(0x0201, 0x0008, {
      endpoint = 1, name = "nam_edge_pi_heating_demand", emit = emit.namEdgePiHeatingDemand(),
      data_type = data_types.Uint8, read_only = true, read_on_configure = true,
      from_device = function(value) return value * 100 / 255 end,
    }),
    zcl.cluster_attribute(0x0201, 0x0025, {
      endpoint = 1, name = "nam_edge_programming_operation_mode", emit = emit.namEdgeProgrammingOperationMode(),
      data_type = data_types.Bitmap8, read_on_configure = true,
      from_device = function(value, device, context) return remember_mode(device, "programming_operation_mode", PROGRAM_MODES[scalar(value)], context) end,
      sender = function(device, mapping, value)
        if value ~= "eco" then zcl.send_raw_cluster_command(device, 0x0201, 0x08, string.char(0), 1) end
        write_edge(device, 0x801F, data_types.Boolean(false), true)
        remember_mode(device, "vacation_mode", "OFF")
        if value == "eco" then zcl.send_raw_cluster_command(device, 0x0201, 0x08, string.char(1), 1)
        else zcl.send_raw_cluster_command(device, 0x0201, 0x07, string.char(value == "schedule" and 1 or 0), 1) end
        remember_mode(device, "programming_operation_mode", value)
        return true
      end,
    }),
    zcl.cluster_attribute(0x0201, 0x8000, {
      endpoint = 1, name = "nam_edge_window_open_check", emit = emit.namEdgeWindowOpenCheck(),
      data_type = data_types.Boolean, read_on_configure = true, sender = edge_setting_sender,
      from_device = function(value) return (value == true or value == 1) and "ON" or "OFF" end,
      to_device = function(value) return value == "ON" end,
    }),
    zcl.cluster_attribute(0x0201, 0x8001, {
      endpoint = 1, name = "nam_edge_frost", emit = emit.namEdgeFrost(),
      data_type = data_types.Boolean, read_on_configure = true, sender = edge_setting_sender,
      from_device = function(value, device, context) return remember_mode(device, "frost", (value == true or value == 1) and "ON" or "OFF", context) end,
      to_device = function(value) return value == "ON" end,
    }),
    zcl.cluster_attribute(0x0201, 0x8002, {
      endpoint = 1, name = "nam_edge_window_state", emit = emit.namEdgeWindowState(),
      data_type = data_types.Boolean, read_on_configure = true, read_only = true,
      from_device = function(value) return (value == true or value == 1) and "open" or "closed" end,
    }),
    zcl.cluster_attribute(0x0201, 0x8004, {
      endpoint = 1, name = "nam_edge_sensor_mode", emit = emit.namEdgeSensorMode(),
      data_type = data_types.Enum8, read_on_configure = true, sender = edge_setting_sender,
      from_device = function(value, device, context) return remember_mode(device, "sensor_mode", SENSOR_MODES[scalar(value)], context) end,
      to_device = function(value) for raw, name in pairs(SENSOR_MODES) do if value == name then return raw end end end,
    }),
    zcl.cluster_attribute(0x0201, 0x8005, {
      endpoint = 1, name = "nam_edge_panel_brightness", emit = emit.namEdgePanelBrightness(),
      data_type = data_types.Uint8, read_on_configure = true, sender = edge_setting_sender,
    }),
    zcl.cluster_attribute(0x0201, 0x8006, {
      endpoint = 1, name = "nam_edge_fault", emit = emit.namEdgeFault(),
      data_type = data_types.Bitmap32, read_on_configure = true, read_only = true,
      from_device = function(value)
        local bits = {}
        local raw = scalar(value)
        for bit = 0, 31 do if bit32.band(raw, 2 ^ bit) ~= 0 then bits[#bits + 1] = tostring(bit) end end
        return #bits > 0 and table.concat(bits, ",") or "none"
      end,
    }),
    zcl.cluster_attribute(0x0201, 0x8007, {
      endpoint = 1, name = "nam_edge_regulator_cycle", emit = emit.namEdgeRegulatorCycle(),
      data_type = data_types.Uint8, read_on_configure = true, sender = edge_setting_sender,
    }),
    zcl.cluster_attribute(0x0201, 0x800A, {
      endpoint = 1, name = "nam_edge_auto_time_pending", data_type = data_types.Boolean, read_only = true, read_on_configure = true,
      handler = function(device, value) if value == true or value == 1 then sync_edge_time(device, false) end end,
    }),
    zcl.cluster_attribute(0x0201, 0x800B, {
      endpoint = 1, name = "nam_edge_clock_last_synced", emit = emit.namEdgeClockLastSynced(),
      data_type = data_types.Uint32, read_only = true, read_on_configure = true,
      from_device = function(value) return os.date("!%Y-%m-%d %H:%M:%S", value) end,
    }),
    zcl.cluster_attribute(0x0201, 0x8013, {
      endpoint = 1, name = "nam_edge_holiday_temp_set", emit = emit.namEdgeHolidayTempSet(),
      data_type = data_types.Int16, read_on_configure = true, sender = edge_setting_sender,
      from_device = function(value) return value / 100 end,
      to_device = function(value) return math.floor(value * 100 + 0.5) end,
    }),
    zcl.cluster_attribute(0x0201, 0x801B, {
      endpoint = 1, name = "nam_edge_holiday_temp_set_f", emit = emit.namEdgeHolidayTempSetF(),
      data_type = data_types.Int16, read_on_configure = true, sender = edge_setting_sender,
      from_device = function(value) return value / 100 end,
      to_device = function(value) return math.floor(value * 100 + 0.5) end,
    }),
    zcl.cluster_attribute(0x0201, 0x801D, {
      endpoint = 1, name = "nam_edge_regulator_percentage", emit = emit.namEdgeRegulatorPercentage(),
      data_type = data_types.Int16, read_on_configure = true, sender = edge_setting_sender,
    }),
    zcl.cluster_attribute(0x0201, 0x801F, {
      endpoint = 1, name = "nam_edge_vacation_mode", emit = emit.namEdgeVacationMode(),
      data_type = data_types.Boolean, read_on_configure = true, sender = edge_setting_sender,
      from_device = function(value, device, context) return remember_mode(device, "vacation_mode", (value == true or value == 1) and "ON" or "OFF", context) end,
      to_device = function(value) return value == "ON" end,
    }),
    zcl.cluster_attribute(0x0201, 0x8020, {
      endpoint = 1, name = "nam_edge_vacation_start", emit = emit.namEdgeVacationStart(),
      data_type = data_types.Uint32, read_on_configure = true, sender = edge_setting_sender,
      from_device = date_from_device, to_device = date_to_device,
    }),
    zcl.cluster_attribute(0x0201, 0x8021, {
      endpoint = 1, name = "nam_edge_vacation_end", emit = emit.namEdgeVacationEnd(),
      data_type = data_types.Uint32, read_on_configure = true, sender = edge_setting_sender,
      from_device = date_from_device, to_device = date_to_device,
    }),
    zcl.cluster_attribute(0x0201, 0x8022, {
      endpoint = 1, name = "nam_edge_auto_time", emit = emit.namEdgeAutoTime(),
      data_type = data_types.Boolean, read_on_configure = true, sender = edge_setting_sender,
      from_device = function(value) return (value == true or value == 1) and "ON" or "OFF" end,
      to_device = function(value) return value == "ON" end,
    }),
    zcl.cluster_attribute(0x0201, 0x8023, {
      endpoint = 1, name = "nam_edge_countdown_set", emit = emit.namEdgeCountdownSet(),
      data_type = data_types.Enum8, read_on_configure = true, sender = edge_setting_sender,
      from_device = function(value, device, context) return remember_mode(device, "countdown_set", scalar(value) * 5, context) end,
      to_device = function(value) return value / 5 end,
    }),
    zcl.cluster_attribute(0x0201, 0x8024, {
      endpoint = 1, name = "nam_edge_countdown_left", emit = emit.namEdgeCountdownLeft(),
      read_on_configure = true, read_only = true,
    }),
    zcl.cluster_attribute(0x0201, 0x8025, {
      endpoint = 1, name = "nam_edge_max_heat_temp", emit = emit.namEdgeMaxHeatTemp(),
      data_type = data_types.Int16, read_on_configure = true, sender = edge_setting_sender,
      from_device = function(value) return value / 10 end,
      to_device = function(value) return math.floor(value * 10 + 0.5) end,
    }),
    zcl.cluster_attribute(0x0201, 0x8026, {
      endpoint = 1, name = "nam_edge_max_heat_temp_f", emit = emit.namEdgeMaxHeatTempF(),
      data_type = data_types.Int16, read_on_configure = true, sender = edge_setting_sender,
      from_device = function(value) return value / 10 end,
      to_device = function(value) return math.floor(value * 10 + 0.5) end,
    }),
    zcl.cluster_attribute(0x0201, 0x8027, {
      endpoint = 1, name = "nam_edge_min_cool_temp", emit = emit.namEdgeMinCoolTemp(),
      data_type = data_types.Int16, read_on_configure = true, sender = edge_setting_sender,
      from_device = function(value) return value / 10 end,
      to_device = function(value) return math.floor(value * 10 + 0.5) end,
    }),
    zcl.cluster_attribute(0x0201, 0x8028, {
      endpoint = 1, name = "nam_edge_min_cool_temp_f", emit = emit.namEdgeMinCoolTempF(),
      data_type = data_types.Int16, read_on_configure = true, sender = edge_setting_sender,
      from_device = function(value) return value / 10 end,
      to_device = function(value) return math.floor(value * 10 + 0.5) end,
    }),
    zcl.cluster_attribute(0x0201, 0x8029, {
      endpoint = 1, name = "nam_edge_screen_on_time", emit = emit.namEdgeScreenOnTime(),
      data_type = data_types.Enum8, read_on_configure = true, sender = edge_setting_sender,
      from_device = function(value) return SCREEN_TIMES[scalar(value)] end,
      to_device = function(value) for raw, name in pairs(SCREEN_TIMES) do if value == name then return raw end end end,
    }),
    zcl.cluster_attribute(0x0201, 0xFFFF, {
      endpoint = 1, name = "nam_edge_sync_time", write_only = true, suppress_optimistic_state = true,
      sender = function(device) return sync_edge_time(device, true) end,
    }),
    zcl.cluster_attribute(0x0204, 0x0000, {
      endpoint = 1, name = "nam_edge_temperature_display_mode", emit = emit.namEdgeTemperatureDisplayMode(),
      data_type = data_types.Enum8, read_on_configure = true,
      from_device = function(value) return ({ [0] = "celsius", [1] = "fahrenheit" })[scalar(value)] end,
      to_device = function(value) return ({ celsius = 0, fahrenheit = 1 })[value] end,
    }),
    zcl.cluster_attribute(0x0204, 0x0001, {
      endpoint = 1, name = "nam_edge_keypad_lockout", emit = emit.namEdgeKeypadLockout(),
      data_type = data_types.Enum8, read_on_configure = true,
      from_device = function(value) return ({ [0] = "UNLOCK", [1] = "LOCK" })[scalar(value)] end,
      to_device = function(value) return ({ UNLOCK = 0, LOCK = 1 })[value] end,
    }),
    zcl.cluster_attribute(0x0000, 0x4000, {
      endpoint = 1, name = "nam_edge_firmware_version", emit = emit.namEdgeFirmwareVersion(),
      data_type = data_types.CharString, read_on_configure = true, read_only = true,
    }),
    zcl.cluster_attribute(0x0000, 0x0006, {
      endpoint = 1, name = "nam_edge_firmware_date", emit = emit.namEdgeFirmwareDate(),
      data_type = data_types.CharString, read_on_configure = true, read_only = true,
    }),
    zcl.cluster_attribute(0x0201, 0x0015, { endpoint = 1, name = "nam_edge_min_heat_setpoint_limit", emit = emit.namEdgeMinHeatSetpointLimit(),
      read_only = true, from_device = function(value) return value >= -27315 and value / 100 or nil end }),
    zcl.cluster_attribute(0x0201, 0x0016, { endpoint = 1, name = "nam_edge_max_heat_setpoint_limit", emit = emit.namEdgeMaxHeatSetpointLimit(),
      read_only = true, from_device = function(value) return value >= -27315 and value / 100 or nil end }),
    zcl.cluster_attribute(0x0201, 0x0017, { endpoint = 1, name = "nam_edge_min_cool_setpoint_limit", emit = emit.namEdgeMinCoolSetpointLimit(),
      read_only = true, from_device = function(value) return value >= -27315 and value / 100 or nil end }),
    zcl.cluster_attribute(0x0201, 0x0018, { endpoint = 1, name = "nam_edge_max_cool_setpoint_limit", emit = emit.namEdgeMaxCoolSetpointLimit(),
      read_only = true, from_device = function(value) return value >= -27315 and value / 100 or nil end }),
    zcl.cluster_attribute(0x0201, 0x800C, { endpoint = 1, name = "nam_edge_min_heat_setpoint_limit_f", emit = emit.namEdgeMinHeatSetpointLimitF(),
      read_only = true, read_on_configure = true, from_device = function(value) return value / 100 end }),
    zcl.cluster_attribute(0x0201, 0x800D, { endpoint = 1, name = "nam_edge_max_heat_setpoint_limit_f", emit = emit.namEdgeMaxHeatSetpointLimitF(),
      read_only = true, read_on_configure = true, from_device = function(value) return value / 100 end }),
    zcl.cluster_attribute(0x0201, 0x800E, { endpoint = 1, name = "nam_edge_min_cool_setpoint_limit_f", emit = emit.namEdgeMinCoolSetpointLimitF(),
      read_only = true, read_on_configure = true, from_device = function(value) return value / 100 end }),
    zcl.cluster_attribute(0x0201, 0x800F, { endpoint = 1, name = "nam_edge_max_cool_setpoint_limit_f", emit = emit.namEdgeMaxCoolSetpointLimitF(),
      read_only = true, read_on_configure = true, from_device = function(value) return value / 100 end }),
    zcl.cluster_attribute(0x0201, 0x8010, { endpoint = 1, name = "nam_edge_occupied_cooling_setpoint_f", emit = emit.namEdgeOccupiedCoolingSetpointF(),
      read_only = true, read_on_configure = true, from_device = function(value) return value / 100 end }),
    zcl.cluster_attribute(0x0201, 0x8011, { endpoint = 1, name = "nam_edge_occupied_heating_setpoint_f", emit = emit.namEdgeOccupiedHeatingSetpointF(),
      read_only = true, read_on_configure = true, from_device = function(value) return value / 100 end }),
    zcl.cluster_attribute(0x0201, 0x8012, { endpoint = 1, name = "nam_edge_local_temperature_f", emit = emit.namEdgeLocalTemperatureF(),
      read_only = true, read_on_configure = true, from_device = function(value) return value / 100 end }),
  },
  configure = function(driver, device)
    for _, cluster in ipairs({ 0x0006, 0x000A, 0x0201, 0x0204, 0x0405, 0x0702, 0x0B04 }) do
      zcl.bind_cluster(device, cluster, driver.environment_info.hub_zigbee_eui, 1)
    end
    for _, attr in ipairs({ 0x0003, 0x0004, 0x0005, 0x0006 }) do read_edge(device, attr) end
  end,
}

register_device_definition(namron_edge, {
  device_helpers.create_fingerprint("Namron AS", "4566702"),
  device_helpers.create_fingerprint("Namron AS", "4512783"),
})

return {
  id = "zcl.thermostats.namron_edge",
  registrations = device_definitions,
}
