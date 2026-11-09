-- ZHA tuya_sensor.py + Z2M zigbee-herdsman-converters 기반 DP 그룹핑
-- 변수명 규칙: {category}_{variant}
--   category: th   (온습도: 온도+습도+배터리)
--             soil (토양: 수분+온도+배터리)
--             aq   (공기질: CO2+온도+습도+VOC+포름알데히드)
--   variant 구성 (순서):
--     1. 인코딩: unsigned (Tuya 16-bit unsigned 온도)
--     2. scale:  t=온도, h=습도/수분, v=VOC, f=포름알데히드
--     3. 기능:   알파벳순 배치
--   기능 명칭 (가독성 우선, 풀네임 사용):
--     2aaa           2AAA 배터리 enum
--     air            공기습도 (토양센서에서 soil_moisture 외 별도 humidity DP)
--     alarm          온습도 알람 DP
--     contact        접점 센서
--     co2            CO2만 지원 (aq 간소화)
--     dry            건조 감지
--     ec             전기 전도도
--     fertility      토양 비옥도
--     fertility_cal  비옥도 교정 DP
--     hcho           포름알데히드 primary (DP2=formaldehyde)
--     illum          조도
--     pm25           PM2.5 primary (DP2=PM2.5)
--     probe          외부 프로브
--     warning        물 부족 경고
--   aq base 정의: unsigned temp, humidity/10, VOC raw, formaldehyde raw, DP2=CO2

local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"

local converter = tuya.converter

local device_definitions, register_device_definition = device_helpers.definition_registry()

local function register_sensor_definition(definitions_or_table, fingerprint_list)
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


-- Z2M: _TZE204_7yyuo8sr
local liquid_level_872wz = {
  profile = "sensors-liquid-level-872wz",
  force_time_updates = true,
  time_start = "1970",
  datapoints = {
    tuya.dp_enum(1, {
      name = "liquid_state",
      emit = emit.liquid_state(),
      read_only = true,
      converter = converter.from_only(converter.lookup_value({
        [0] = "normal",
        [1] = "low",
        [2] = "high",
      })),
    }),
    tuya.dp_numeric(2, {
      name = "liquid_depth",
      emit = emit.wls872LiquidDepth(),
      read_only = true,
      converter = converter.divide_by_pair(100),
    }),
    tuya.dp_numeric(7, { name = "max_set", emit = emit.wls872MaximumPercent() }),
    tuya.dp_numeric(8, { name = "min_set", emit = emit.wls872MinimumPercent() }),
    tuya.dp_binary(9, {
      name = "silent_mode",
      emit = emit.wls872SilentMode(),
      converter = converter.lookup_from_to({ on = true, off = false }),
    }),
    tuya.dp_numeric(19, {
      name = "installation_height",
      emit = emit.wls872InstallationHeight(),
      converter = converter.divide_by_pair(100),
    }),
    tuya.dp_numeric(21, {
      name = "liquid_depth_max",
      emit = emit.wls872MaximumDepth(),
      converter = converter.divide_by_pair(100),
    }),
    tuya.dp_numeric(22, {
      name = "liquid_level_percent",
      emit = emit.liquid_level_percent(),
      read_only = true,
    }),
    tuya.dp_numeric(27, { name = "alarm_time", emit = emit.wls872AlarmDuration() }),
  },
  query_on_configure = true,
}

register_sensor_definition(liquid_level_872wz, {
  device_helpers.create_fingerprint("_TZE204_7yyuo8sr", "TS0601"),
})

local ME201_CANDIDATE_FIELD = "__me201wz_candidate"
local ME201_PENDING_FIELD = "__me201wz_pending_state"
local ME201_VALUE_TYPE = 0x02
local ME201_TRANSIENT = { persist = false }
local ME201_PERSISTENT = { persist = true }
local ME201_STATES = { [0] = "normal", [1] = "low", [2] = "high" }

local function me201_dp_value(dp_info)
  if dp_info.datatype == ME201_VALUE_TYPE then
    return dp_info.signed_value
  end
  return dp_info.value
end

local function me201_frame_cache(device, context)
  local frame = context.frame
  if frame.me201wz == nil then
    -- Snapshot before any level or geometry/threshold mapping stores this frame.
    frame.me201wz = {
      state = {
        liquid_depth = device:get_field("liquid_depth"),
        liquid_level_percent = device:get_field("liquid_level_percent"),
        liquid_state = device:get_field("liquid_state"),
        installation_height = device:get_field("installation_height"),
        liquid_depth_max = device:get_field("liquid_depth_max"),
        min_set = device:get_field("min_set"),
        max_set = device:get_field("max_set"),
      },
    }
  end
  return frame.me201wz
end

local function me201_filter(device, result, state)
  local depth, percent = result.liquid_depth, result.liquid_level_percent
  local last_depth, height, depth_max = state.liquid_depth, state.installation_height, state.liquid_depth_max
  local glitch = false
  if depth ~= nil then
    if depth < 0 or (height ~= nil and depth > height) then
      glitch = true
    elseif last_depth ~= nil and math.abs(depth - last_depth) > 0.05 then
      local candidate = device:get_field(ME201_CANDIDATE_FIELD)
      local now = math.floor(require("cosock.socket").gettime() * 1000)
      if candidate ~= nil and math.abs(depth - candidate.depth) <= 0.03 then
        glitch = now - candidate.since < 43200000
      else
        device:set_field(ME201_CANDIDATE_FIELD, { depth = depth, since = now }, ME201_TRANSIENT)
        glitch = true
      end
    end
    if not glitch then
      device:set_field(ME201_CANDIDATE_FIELD, nil, ME201_TRANSIENT)
    end
  elseif percent ~= nil and last_depth ~= nil and depth_max ~= nil and depth_max ~= 0 then
    -- JavaScript's truthy depthMax excludes zero; Lua's truthiness does not.
    glitch = math.abs(percent - math.min(100, last_depth / depth_max * 100)) > 5 / depth_max
  end
  if glitch then
    result.liquid_depth, result.liquid_level_percent, result.liquid_state = nil, nil, nil
    return result
  end

  local min_set, max_set = state.min_set, state.max_set
  local level = percent
  if level == nil then level = state.liquid_level_percent end
  if min_set == nil or max_set == nil or level == nil then return result end
  local function matches(value)
    return (value == "low" and level <= min_set + 1)
      or (value == "high" and level >= max_set - 1)
      or (value == "normal" and level >= min_set - 1 and level <= max_set + 1)
  end
  if result.liquid_state ~= nil and not matches(result.liquid_state) then
    device:set_field(ME201_PENDING_FIELD, result.liquid_state, ME201_TRANSIENT)
    result.liquid_state = nil
  elseif result.liquid_state == nil and percent ~= nil then
    local pending = device:get_field(ME201_PENDING_FIELD)
    if pending ~= nil and pending ~= state.liquid_state and matches(pending) then
      result.liquid_state = pending
    end
  end
  if result.liquid_state ~= nil then
    device:set_field(ME201_PENDING_FIELD, nil, ME201_TRANSIENT)
  end
  return result
end

local function me201_level_from(_, device, _, context)
  local cache = me201_frame_cache(device, context)
  if cache.result == nil then
    local values = {}
    for _, dp_info in ipairs(context.frame.datapoints) do
      if dp_info.dp == 1 or dp_info.dp == 2 or dp_info.dp == 22 then
        values[dp_info.dp] = me201_dp_value(dp_info)
      end
    end
    local result = {}
    if values[1] ~= nil then result.liquid_state = ME201_STATES[values[1]] end
    if values[2] ~= nil then result.liquid_depth = values[2] / 100 end
    if values[22] ~= nil then result.liquid_level_percent = values[22] end
    cache.result = me201_filter(device, result, cache.state)
  end
  return cache.result
end

local function me201_level_emitter(state_emit, depth_emit, percent_emit)
  return function(device, result, _, context)
    local cache = me201_frame_cache(device, context)
    if cache.emitted then return end
    cache.emitted = true
    local events = {}
    if result.liquid_state ~= nil then
      device:set_field("liquid_state", result.liquid_state, ME201_PERSISTENT)
      events[#events + 1] = state_emit(device, result.liquid_state)
    end
    if result.liquid_depth ~= nil then
      device:set_field("liquid_depth", result.liquid_depth, ME201_PERSISTENT)
      events[#events + 1] = depth_emit(device, result.liquid_depth)
    end
    if result.liquid_level_percent ~= nil then
      device:set_field("liquid_level_percent", result.liquid_level_percent, ME201_PERSISTENT)
      events[#events + 1] = percent_emit(device, result.liquid_level_percent)
    end
    if #events > 0 then return events end
  end
end

local function me201_numeric_setting(dp, name, event_emit, minimum, maximum, scale)
  local function encode(value)
    if type(value) ~= "number" or value ~= value or value < minimum or value > maximum then return end
    if scale == 1 and value % 1 ~= 0 then return end
    local scaled = value * scale
    local encoded = math.floor(scaled + 0.5)
    -- Only SET grid validation tolerates multiplication noise, not the filter.
    if math.abs(scaled - encoded) > 0.0000001 then return end
    return encoded
  end
  return tuya.dp_numeric(dp, {
    name = name,
    emit = event_emit,
    persist = true,
    from_device = function(_, device, dp_info, context)
      me201_frame_cache(device, context)
      return me201_dp_value(dp_info) / scale
    end,
    to_device = encode,
    optimistic_value = function(value, device)
      local encoded = encode(value)
      if encoded == nil then return end
      local actual = encoded / scale
      device:set_field(name, actual, ME201_PERSISTENT)
      return actual
    end,
  })
end

local function me201_voltage_from(_, _, dp_info)
  return me201_dp_value(dp_info) / 10
end

local me201_emit_level = me201_level_emitter(
  emit.me201LiquidState(), emit.me201DepthV2(), emit.me201LevelPercent()
)
local me202_emit_level = me201_level_emitter(
  emit.me202LiquidState(), emit.me202DepthV2(), emit.me202LevelPercent()
)

-- Z2M: _TZE284_kyyu8rbj
local liquid_level_me201wz = {
  profile = "sensors-liquid-level-me201wz",
  force_time_updates = true,
  time_start = "off",
  datapoints = {
    tuya.dp_enum(1, {
      name = "liquid_state",
      field = false,
      emit = me201_emit_level,
      read_only = true,
      from_device = me201_level_from,
    }),
    tuya.dp_numeric(2, {
      name = "liquid_depth",
      field = false,
      emit = me201_emit_level,
      read_only = true,
      from_device = me201_level_from,
    }),
    tuya.dp_numeric(5, {
      name = "voltage",
      emit = emit.voltage(),
      read_only = true,
      from_device = me201_voltage_from,
    }),
    me201_numeric_setting(7, "max_set", emit.me201MaximumPercentV2(), 0, 100, 1),
    me201_numeric_setting(8, "min_set", emit.me201MinimumPercentV2(), 0, 100, 1),
    me201_numeric_setting(19, "installation_height", emit.me201InstallationHeightV2(), 0.1, 5, 100),
    me201_numeric_setting(21, "liquid_depth_max", emit.me201MaximumDepthV2(), 0.1, 5, 100),
    tuya.dp_numeric(22, {
      name = "liquid_level_percent",
      field = false,
      emit = me201_emit_level,
      read_only = true,
      from_device = me201_level_from,
    }),
    tuya.dp_binary(24, {
      name = "relay_switch",
      emit = emit.me201RelaySwitch(),
      converter = converter.lookup_from_to({ on = true, off = false }),
    }),
    tuya.dp_binary(101, {
      name = "pump_mode",
      emit = emit.me201PumpMode(),
      converter = converter.lookup_from_to({ supply = true, drainage = false }),
    }),
    tuya.dp_binary(102, {
      name = "pump_control",
      emit = emit.me201PumpControl(),
      converter = converter.lookup_from_to({ auto = true, manual = false }),
    }),
    tuya.dp_string(103, { name = "version", emit = emit.me201Version(), read_only = true }),
  },
  query_on_configure = true,
}

register_sensor_definition(liquid_level_me201wz, {
  device_helpers.create_fingerprint("_TZE284_kyyu8rbj", "TS0601"),
})

-- Z2M: _TZE200_lvkk0hdg
local liquid_level_tlc2206 = {
  profile = "sensors-liquid-level-tlc2206",
  force_time_updates = true,
  time_start = "1970",
  datapoints = {
    tuya.dp_enum(1, {
      name = "liquid_state",
      emit = emit.liquid_state(),
      read_only = true,
      converter = converter.from_only(converter.lookup_value({
        [0] = "normal",
        [1] = "low",
        [2] = "high",
      })),
    }),
    tuya.dp_numeric(2, {
      name = "liquid_depth",
      emit = emit.tlc2206LiquidDepth(),
      read_only = true,
      converter = converter.divide_by_pair(100),
    }),
    tuya.dp_numeric(7, { name = "max_set", emit = emit.tlc2206MaximumPercent() }),
    tuya.dp_numeric(8, { name = "min_set", emit = emit.tlc2206MinimumPercent() }),
    tuya.dp_numeric(19, {
      name = "installation_height",
      emit = emit.tlc2206InstallationHeight(),
      converter = converter.divide_by_pair(1000),
    }),
    tuya.dp_numeric(21, {
      name = "liquid_depth_max",
      emit = emit.tlc2206MaximumDepth(),
      converter = converter.divide_by_pair(1000),
    }),
    tuya.dp_numeric(22, {
      name = "liquid_level_percent",
      emit = emit.liquid_level_percent(),
      read_only = true,
    }),
  },
  query_on_configure = true,
}

register_sensor_definition(liquid_level_tlc2206, {
  device_helpers.create_fingerprint("_TZE200_lvkk0hdg", "TS0601"),
})

-- Z2M: _TZE284_mxujdmxo
local liquid_level_me202wz = {
  profile = "sensors-liquid-level-me202wz",
  force_time_updates = true,
  time_start = "off",
  datapoints = {
    tuya.dp_enum(1, {
      name = "liquid_state",
      field = false,
      emit = me202_emit_level,
      read_only = true,
      from_device = me201_level_from,
    }),
    tuya.dp_numeric(2, {
      name = "liquid_depth",
      field = false,
      emit = me202_emit_level,
      read_only = true,
      from_device = me201_level_from,
    }),
    tuya.dp_numeric(5, {
      name = "voltage",
      emit = emit.voltage(),
      read_only = true,
      from_device = me201_voltage_from,
    }),
    me201_numeric_setting(7, "max_set", emit.me202MaximumPercentV2(), 0, 100, 1),
    me201_numeric_setting(8, "min_set", emit.me202MinimumPercentV2(), 0, 100, 1),
    me201_numeric_setting(21, "liquid_depth_max", emit.me202MaximumDepthV2(), 0.1, 10, 100),
    tuya.dp_numeric(22, {
      name = "liquid_level_percent",
      field = false,
      emit = me202_emit_level,
      read_only = true,
      from_device = me201_level_from,
    }),
    tuya.dp_binary(24, {
      name = "relay_switch",
      emit = emit.me202RelaySwitch(),
      converter = converter.lookup_from_to({ on = true, off = false }),
    }),
    tuya.dp_binary(101, {
      name = "pump_mode",
      emit = emit.me202PumpMode(),
      converter = converter.lookup_from_to({ supply = true, drainage = false }),
    }),
    tuya.dp_binary(102, {
      name = "pump_control",
      emit = emit.me202PumpControl(),
      converter = converter.lookup_from_to({ auto = true, manual = false }),
    }),
    tuya.dp_string(103, { name = "version", emit = emit.me202Version(), read_only = true }),
  },
  query_on_configure = true,
}

register_sensor_definition(liquid_level_me202wz, {
  device_helpers.create_fingerprint("_TZE284_mxujdmxo", "TS0601"),
})


return {
  id = "ef00.sensors.liquid_level",
  registrations = device_definitions,
}
