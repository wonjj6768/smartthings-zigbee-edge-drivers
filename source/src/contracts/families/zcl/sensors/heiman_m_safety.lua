-- S1-M/C1-M: ZHC cff1de4731a14a84094a8568d8bbf92aa5feb0db.
-- Basic identities are the two ZHA PR5458/5457 diagnostic pairs only.
local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local helpers = require "contracts.helpers.family"
local capabilities = require "st.capabilities"
local types = require "st.zigbee.data_types"
local base = require "st.zigbee.cluster_base"
local clusters = require "st.zigbee.zcl.clusters"
local ReadAttribute = require("st.zigbee.zcl.global_commands.read_attribute").ReadAttribute

local definitions, register = helpers.definition_registry()
local PRIVATE, MANUFACTURER = 0xFC90, 0x120B

local function custom(name)
  return assert(emit[name], "Missing Heiman current metadata: " .. name)()
end

local function number(value)
  if type(value) == "table" and value.value ~= nil then return value.value end
  return value
end

local function truth(value)
  value = number(value)
  return value ~= false and value ~= 0
end

local function active(value)
  return truth(value) and "active" or "inactive"
end

local function bit(mask)
  return function(value) return (number(value) & mask) ~= 0 end
end

local function enum(labels)
  return function(value) return labels[number(value)] end
end

local function bits(labels)
  return function(value)
    local found = {}
    for index, label in ipairs(labels) do
      if (number(value) & (1 << (index - 1))) ~= 0 then found[#found + 1] = label end
    end
    return #found > 0 and table.concat(found, " | ") or "normal"
  end
end

local function flags(tx, disable)
  if disable then tx.body.zcl_header.frame_ctrl:set_disable_default_response()
  else tx.body.zcl_header.frame_ctrl:unset_disable_default_response() end
  return tx
end

local function read(device, cluster, ids, endpoint, manufacturer, disable)
  local tx = manufacturer and base.read_manufacturer_specific_attribute(device, cluster, ids[1], manufacturer)
    or base.read_attribute(device, types.ClusterId(cluster), types.AttributeId(ids[1]))
  tx.body.zcl_body = ReadAttribute(ids)
  device:send(flags(tx:to_endpoint(endpoint or device:get_endpoint(cluster)), disable ~= false))
end

local function finite(value, minimum, maximum)
  return type(value) == "number" and value == value and value >= minimum and value <= maximum
end

local function passive(mapping)
  mapping.minimum_interval, mapping.maximum_interval, mapping.reportable_change = nil, nil, nil
  mapping.read_on_configure, mapping.read_on_refresh = false, false
  return mapping
end

local function reporting(device, cluster, attribute, kind, minimum, maximum, change, endpoint)
  zcl.configure_reporting(device, {cluster = cluster, attribute = attribute, data_type = kind,
    minimum_interval = minimum, maximum_interval = maximum, reportable_change = change}, endpoint, {auto_endpoint = true})
end

local function supported_endpoints(device, cluster)
  local endpoints = {}
  for _, endpoint in pairs(device.zigbee_endpoints or {}) do
    if device:supports_server_cluster(cluster, endpoint.id) then endpoints[#endpoints + 1] = endpoint.id end
  end
  table.sort(endpoints)
  return endpoints
end

local function create_family(smoke, stem, route, profile)
  local mappings, commands, writers = {}, {}, {}
  local function add(cluster, attribute, name, emitter, conversion, kind, options)
    options = options or {}
    options.name, options.emit, options.from_device = name, emitter, conversion
    options.data_type = kind
    options.read_on_configure, options.read_on_refresh = false, false
    if options.read_only == nil then options.read_only = true end
    if cluster == PRIVATE then options.mfg_code, options.endpoint = MANUFACTURER, 1 end
    local mapping = zcl.cluster_attribute(cluster, attribute, options)
    mappings[#mappings + 1] = mapping
    return mapping
  end
  local function state(id, item, suffix, conversion, kind)
    return add(PRIVATE, id, route .. item, custom(stem .. suffix), conversion, kind)
  end
  local function command(capability, name, mapping, argument, value)
    commands[#commands + 1] = {capability_id = capability, command_name = name,
      mapping_name = mapping, argument_name = argument, value = value}
  end
  local function writable(id, item, suffix, conversion, kind, encode, disable, optimistic)
    local emitter = suffix and custom(stem .. suffix) or nil
    local mapping = add(PRIVATE, id, route .. item, emitter, conversion, kind, {read_only = false})
    mapping.sender = function(device, _, value)
      local encoded = encode(value)
      if encoded == nil then return false end
      local tx = base.write_manufacturer_specific_attribute(device, PRIVATE, id, MANUFACTURER, kind, encoded)
      device:send(flags(tx:to_endpoint(1), disable))
      if optimistic then
        -- Match primary SET return state; no synthetic report or device acknowledgement.
        local event = emitter(device, value)
        if event then device:emit_event(event) end
      end
      return true
    end
    return mapping
  end

  local battery = add(1, 0x21, route .. "battery", custom(stem .. "BatteryPercent"), function(value)
    value = number(value)
    if value < 255 then return value / 2 end
  end, types.Uint8)
  battery.reporting_defaults = {minimum_interval = 3600, maximum_interval = 65000, reportable_change = 10}
  local temperature = add(0x0402, 0, route .. "temperature", emit.temperature(), function(value)
    return number(value) / 100
  end, types.Int16)
  temperature.reporting_defaults = {minimum_interval = 10, maximum_interval = 3600, reportable_change = smoke and 200 or 100}
  if smoke then
    local humidity = add(0x0405, 0, route .. "humidity", custom(stem .. "Humidity"), function(value)
      return number(value) / 100
    end, types.Uint16)
    humidity.reporting_defaults = {minimum_interval = 10, maximum_interval = 3600, reportable_change = 500,
      supported = function(device) return #supported_endpoints(device, 0x0405) > 0 end}
  else
    local co = add(0x040C, 0, route .. "co", custom(stem .. "CoPpm"), function(value, _, context)
      -- API16 retains IEEE bytes even where FloatABC.value mishandles subnormals/nonfinite.
      local typed = context and context.typed_value
      if type(typed) == "table" and typed.ID == 0x39 then value = string.unpack("<f", typed:_serialize()) end
      if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then return end
      return math.floor(value / 0.000001 + 0.5)
    end, types.SinglePrecisionFloat)
    co.reporting_defaults = {minimum_interval = 1, maximum_interval = 14400, reportable_change = 0.00001,
      supported = function(device) return #supported_endpoints(device, 0x040C) > 0 end}
  end

  local alarm = smoke and zcl.smoke({name = route .. "smoke"}) or zcl.carbon_monoxide({name = route .. "carbon_monoxide"})
  mappings[#mappings + 1] = passive(alarm) -- bit0 only, no ZoneStatus reporting.
  mappings[#mappings + 1] = passive(zcl.battery_low({name = route .. "battery_low", emit = function(_, value)
    return value and capabilities.batteryLevel.battery.critical() or capabilities.batteryLevel.battery.normal()
  end}))
  mappings[#mappings + 1] = passive(zcl.smoke({name = route .. "test", from_device = function(value)
    return bit(0x100)(value) and "active" or "inactive"
  end, emit = custom(stem .. "TestState")}))

  state(0x0013, "alarm_state", "AlarmState", enum({[0] = "normal", "prealarm", smoke and "alarmed" or "warning_alarm", "critical_alarm"}), types.Enum8)
  state(0x0002, "fault_state", "FaultState", bits({"fault", "open_circuit_fault", "short_circuit_fault", "pollution_fault"}), types.Uint16)
  state(0x0009, "muted", "MuteState", bits({"muted", "alarm_muted", "fault_muted", "low_battery_muted", "endoflife_muted", "warning_muted"}), types.Bitmap16)
  state(0x1007, "interconnectable", "Interconnectable", active, types.Uint8)
  state(0x1007, "link_available", "LinkState", enum({[0] = "inactive", "smoke_active", "co_active", "gas_active", "heat_active"}), types.Uint8)
  for _, row in ipairs({{0x001B, "reported_packages", "ReportedCount"}, {0x001A, "rejoin_count", "RejoinCount"}, {0x0019, "reboot_count", "RebootCount"}}) do
    state(row[1], row[2], row[3], number, types.Uint16)
  end
  if smoke then
    state(0x0016, "smoke_level", "SmokeLevel", function(value) return number(value) / 100 end, types.Uint8)
    state(0x0018, "smoke_unit", "SmokeUnit", enum({[0] = "dB/m", [1] = "%ft OBS"}), types.Uint8)
    state(0x0017, "chamber_contamination", "ChamberState", enum({[0] = "normal", "light_contamination", "medium_contamination", "critical_contamination"}), types.Uint8)
  else
    state(0x0006, "endoflife", "LifeState", enum({[0] = "normal", "expires_soon", "expired"}), types.Enum8)
    state(0x0000, "preheating", "PreheatState", enum({[0] = "normal", "preheating"}), types.Enum8)
  end

  local mute = writable(0x0008, "temporary_mute", nil, function(value) return truth(value) and "muted" or "unmuted" end,
    types.Uint8, function(value)
      if value == "muted" then return 1 elseif value == "unmuted" then return 0 end
    end, false, false)
  mute.emit = function(_, value) return capabilities.audioMute.mute(value) end
  command("audioMute", "setMute", mute.name, "state")
  command("audioMute", "mute", mute.name, nil, "muted")
  command("audioMute", "unmute", mute.name, nil, "unmuted")
  local heartbeat = writable(0x1004, "heartbeat_indicator", nil, truth, types.Uint8, function(value)
    if type(value) == "boolean" then return value and 1 or 0 end
  end, false, false)
  -- app.switch_command_router selects the canonical name 'switch'.
  heartbeat.name, heartbeat.component, heartbeat.emit = "switch", "heartbeat", emit.switch()

  local sirens = {stop = 0, smoke_siren = 1, co_siren = 2}
  local siren = writable(0x0012, "siren_for_automation_only", "SirenMode", enum({[0] = "stop", "smoke_siren", "co_siren"}),
    types.Enum8, function(value) return sirens[value] end, true, true)
  command("concertmirror08464." .. stem .. "SirenMode", "setSirenMode", siren.name, "sirenMode")
  local function offset(id, item, suffix, attribute)
    local mapping = writable(id, item, suffix, function(value) return number(value) / 100 end,
      types.Int16, function(value)
      if finite(value, -15, 15) then return math.modf(value * 100) end
    end, true, true)
    command("concertmirror08464." .. stem .. suffix, "set" .. attribute:sub(1, 1):upper() .. attribute:sub(2), mapping.name, attribute)
  end
  offset(0x100D, "temperature_offset", "TempOffset", "tempOffset")
  if smoke then
    offset(0x1012, "humidity_offset", "HumidityOffset", "humidityOffset")
    local shield = writable(0x002D, "shielding_sensor_detection", "ShieldingTime", number, types.Uint16, function(value)
      if finite(value, 0, 20) then return math.modf(value) end
    end, true, true)
    command("concertmirror08464." .. stem .. "ShieldingTime", "setShieldingTime", shield.name, "shieldingTime")
  end

  writers[route .. "identify"] = function(device, duration)
    if duration == nil then duration = 3 end
    if not finite(duration, 1, 30) or duration % 1 ~= 0 then return false end
    device:send(clusters.Identify.server.commands.Identify(device, duration):to_endpoint(1))
    return true
  end
  command("concertmirror08464." .. stem .. "Identify", "identify", route .. "identify", "duration")
  local warning_modes = {stop = 0, burglar = 1, fire = 2, emergency = 3, police_panic = 4, fire_panic = 5, emergency_panic = 6}
  local warning_levels = {low = 0, medium = 1, high = 2, very_high = 3}
  local warning_fields = {mode = true, level = true, strobe = true, duration = true, strobeDutyCycle = true, strobeLevel = true}
  writers[route .. "warning"] = function(device, options)
    if options == nil then options = {} elseif options == "stop" then options = {mode = "stop"} end
    if type(options) ~= "table" then return false end
    for key in pairs(options) do if not warning_fields[key] then return false end end
    local mode = warning_modes[options.mode or "emergency"]
    local level = warning_levels[options.level or "medium"]
    local strobe_level = warning_levels[options.strobeLevel or "medium"]
    local strobe, duration, duty = options.strobe, options.duration, options.strobeDutyCycle
    if strobe == nil then strobe = true end
    if duration == nil then duration = 10 end
    if duty == nil then duty = 0 end
    -- Herdsman command parameter max100 is checked before Buffer's Uint8 truncation.
    if mode == nil or level == nil or strobe_level == nil or type(strobe) ~= "boolean" or
        not finite(duration, 0, 65535) or not finite(duty, 0, 10) then return false end
    local info = (mode << 4) | (strobe and 4 or 0) | level
    local tx = clusters.IASWD.server.commands.StartWarning(device, info, math.modf(duration), math.modf(duty * 10), strobe_level)
    device:send(flags(tx:to_endpoint(1), false))
    return true
  end
  command("concertmirror08464." .. stem .. "WarningV2", "warning", route .. "warning", "warning")
  command("concertmirror08464." .. stem .. "WarningV2", "stop", route .. "warning", nil, "stop")
  writers[route .. "trigger_selftest"] = function(device, _, command_value)
    if command_value.component ~= "selfTest" then return false end
    device:send(clusters.IASZone.server.commands.InitiateTestMode(device, 1, 1):to_endpoint(1))
    return true
  end
  command("momentary", "push", route .. "trigger_selftest", nil, "test")

  local extension_private = smoke and {0x0013, 0x0016, 0x0018, 0x0017, 0x1007, 0x1007, 0x002D, 0x100D, 0x1012, 0x001B, 0x001A, 0x0019}
    or {0x0006, 0x0013, 0x0000, 0x1007, 0x100D, 0x1007, 0x001B, 0x001A, 0x0019}
  local parent_private = smoke and {0x0002, 0x0008, 0x0009, 0x0013, 0x1004, 0x1007, 0x0016, 0x0017, 0x0018, 0x0019, 0x001A, 0x001B}
    or {0x0002, 0x0008, 0x0009, 0x1004, 0x1007, 0x100D, 0x0006, 0x0013, 0x0000, 0x0019, 0x001A, 0x001B}

  return {
    profile = profile, zcl_clusters = mappings, protocol_writers = writers, capability_commands = commands,
    -- Heartbeat/self-test are logical components; all SETs use EP1, measurement RX belongs to main.
    component_to_endpoint = function() return 1 end,
    endpoint_to_component = function() return "main" end,
    -- These hooks add no timers or announce queries. Generic SDK attributes parse each reported datatype.
    configure = function(driver, device)
      local hub = driver.environment_info.hub_zigbee_eui
      zcl.bind_cluster(device, 1, hub, 1)
      zcl.bind_cluster(device, PRIVATE, hub, 1)
      reporting(device, 1, 0x21, types.Uint8, 3600, 65000, 0, 1)
      read(device, 1, {0x21}, 1)
      read(device, 0x0500, {2, 0, 0x10, 0x11}, 1)
      read(device, 0x0402, {0}, 1)
      if not smoke then read(device, 0x040C, {0}, 1) end
      read(device, PRIVATE, parent_private, 1, MANUFACTURER)
      if smoke then
        read(device, PRIVATE, {0x1012, 0x100D, 0x002D}, 1, MANUFACTURER)
        -- Explicit primary query remains even if the observed descriptor lacks EP2.
        read(device, 0x0405, {0}, 2)
      end
      for _, row in ipairs({{1, 0x21, types.Uint8, 3600, 65000, 10},
        {0x0402, 0, types.Int16, 10, 3600, smoke and 200 or 100},
        {smoke and 0x0405 or 0x040C, 0, smoke and types.Uint16 or types.SinglePrecisionFloat,
          smoke and 10 or 1, smoke and 3600 or 14400, smoke and 500 or 0.00001}}) do
        -- Extension reporting visits advertised endpoints only; absent clusters stay unproven.
        for _, endpoint in ipairs(supported_endpoints(device, row[1])) do
          zcl.bind_cluster(device, row[1], hub, endpoint)
          reporting(device, row[1], row[2], row[3], row[4], row[5], row[6], endpoint)
          read(device, row[1], {row[2]}, endpoint)
        end
      end
      for _, id in ipairs(extension_private) do read(device, PRIVATE, {id}, nil, MANUFACTURER) end
    end,
    parent_refresh = function(device, preset)
      if preset.zcl_refresh_before_read_all then preset.zcl_refresh_before_read_all(device, preset) end
      -- Primary battery GET has two queries; voltage is not an exposed item.
      read(device, 1, {0x21})
      read(device, 1, {0x20})
      read(device, 0x0402, {0})
      read(device, smoke and 0x0405 or 0x040C, {0})
      local false_flags = {[0x0002] = true, [0x0009] = true, [0x0008] = true, [0x1004] = true, [0x1007] = true}
      for _, id in ipairs(parent_private) do
        read(device, PRIVATE, {id}, nil, MANUFACTURER, not false_flags[id])
      end
      -- Link enum and interconnectable boolean share1007, with different helper headers.
      read(device, PRIVATE, {0x1007}, nil, MANUFACTURER, true)
      read(device, PRIVATE, {0x0012}, nil, MANUFACTURER, true)
      if smoke then
        read(device, PRIVATE, {0x002D}, nil, MANUFACTURER, true)
        read(device, PRIVATE, {0x100D}, nil, MANUFACTURER, true)
        read(device, PRIVATE, {0x1012}, nil, MANUFACTURER, true)
      end
    end,
  }
end

local s1_m = create_family(true, "hmS1M", "hm_s1_m_", "safety-heiman-s1-m")
local c1_m = create_family(false, "hmC1M", "hm_c1_m_", "safety-heiman-c1-m")
register(s1_m, {helpers.create_fingerprint("0x120B", "S1-M")})
register(c1_m, {helpers.create_fingerprint("0x120B", "C1-M")})

-- ZCL REPORTING CAPABILITIES BEGIN
zcl.attach_reporting_capabilities(definitions, {
  {1, "rpt-srn"},
  {2, "rpt-cgx"},
})
-- ZCL REPORTING CAPABILITIES END

return {id = "zcl.sensors.heiman_m_safety", registrations = definitions,}
