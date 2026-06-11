-- ZCL 계량형 scaler/polling helper
-- SimpleMetering / ElectricalMeasurement 의 multiplier/divisor 와 polling 을 공통 처리합니다.

local function load_metering(zcl)

  local capabilities = require "st.capabilities"
  local custom_capabilities = require "core.custom_capabilities"
  local zigbee_constants = require "st.zigbee.constants"

  local POWER_POLL_INTERVAL_METADATA = custom_capabilities.by_emit_name.power_poll_interval
  local LAST_POWER_RESPONSE_TIME_METADATA = custom_capabilities.by_emit_name.last_power_response_time
  local POWER_POLL_INTERVAL_FIELD = "_zcl_power_poll_interval_seconds"
  local LAST_POWER_RESPONSE_AT_FIELD = "_zcl_last_power_response_at"
  local SWITCH_STATE_FIELD = "_zcl_switch_state"
  local POWER_POLL_INTERVAL_DEFAULT_RANGE = POWER_POLL_INTERVAL_METADATA and POWER_POLL_INTERVAL_METADATA.default_range or {}
  local POWER_POLL_INTERVAL_MIN = POWER_POLL_INTERVAL_DEFAULT_RANGE.minimum or 5
  local POWER_POLL_INTERVAL_MAX = POWER_POLL_INTERVAL_DEFAULT_RANGE.maximum or 3600
  local POWER_POLL_INTERVAL_STEP = POWER_POLL_INTERVAL_DEFAULT_RANGE.step or 5
  local POWER_POLL_INTERVAL_UNIT = POWER_POLL_INTERVAL_DEFAULT_RANGE.unit or "s"
  local LAST_POWER_RESPONSE_WAITING_TEXT = "--"
  local OFF_STATE_POLL_INTERVAL = 3600
  local ON_STATE_CONFIRM_POLL_DELAYS = { 1, 3, 10, 30 }
  local OFF_STATE_CONFIRM_POLL_DELAYS = { 1, 3 }

  local metering_specs = {}
  local poll_timers = setmetatable({}, { __mode = "k" })

  local function normalize_numeric(value)
    if type(value) == "table" then
      value = value.value
    end

    if type(value) ~= "number" then
      return nil
    end

    return value
  end

  local function normalize_endpoint(endpoint)
    return zcl.normalize_endpoint(endpoint) or 1
  end

  local function normalize_integer(value)
    if type(value) == "table" then
      value = value.value
    end

    if type(value) == "string" and value ~= "" then
      local parsed = tonumber(value)
      if parsed ~= nil then
        value = parsed
      end
    end

    if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
      return nil
    end

    return math.floor(value + 0.5)
  end

  local function clamp_power_poll_interval(value)
    value = normalize_integer(value)
    if value == nil then
      return nil
    end

    if value < POWER_POLL_INTERVAL_MIN then
      value = POWER_POLL_INTERVAL_MIN
    elseif value > POWER_POLL_INTERVAL_MAX then
      value = POWER_POLL_INTERVAL_MAX
    end

    value = math.floor((value / POWER_POLL_INTERVAL_STEP) + 0.5) * POWER_POLL_INTERVAL_STEP

    if value < POWER_POLL_INTERVAL_MIN then
      value = POWER_POLL_INTERVAL_MIN
    elseif value > POWER_POLL_INTERVAL_MAX then
      value = POWER_POLL_INTERVAL_MAX
    end

    return value
  end

  local function supports_main_capability(device, capability)
    if capability == nil or type(device) ~= "table" then
      return false
    end

    local components = device.profile and device.profile.components or nil
    local main = type(components) == "table" and components.main or nil
    local capabilities_map = main and main.capabilities or nil
    if type(capabilities_map) == "table" and capabilities_map[capability.ID] ~= nil then
      return true
    end

    return type(device.supports_capability_by_id) == "function" and
      device:supports_capability_by_id(capability.ID, "main")
  end

  local function emit_main_event(device, event)
    if event == nil then
      return false
    end

    if type(device.emit_component_event) == "function" then
      device:emit_component_event({ id = "main" }, event)
      return true
    end

    if type(device.emit_event) == "function" then
      device:emit_event(event)
      return true
    end

    return false
  end

  local function is_callable(value)
    if type(value) == "function" then
      return true
    end

    if type(value) ~= "table" then
      return false
    end

    local metatable = getmetatable(value)
    return type(metatable) == "table" and type(metatable.__call) == "function"
  end

  local function resolve_capability_attribute(metadata, attribute_name)
    if type(metadata) ~= "table" or type(attribute_name) ~= "string" or attribute_name == "" then
      return nil, nil
    end

    local capability = capabilities[metadata.capability_id]
    local attribute = capability and capability[attribute_name] or nil

    if not is_callable(attribute) and capability and type(capability.attributes) == "table" then
      attribute = capability.attributes[attribute_name]
    end

    if not is_callable(attribute) then
      attribute = nil
    end

    return capability, attribute
  end

  local function format_power_response_time(epoch)
    if type(epoch) ~= "number" or epoch <= 0 then
      return LAST_POWER_RESPONSE_WAITING_TEXT
    end

    return os.date("%Y-%m-%d %H:%M:%S", epoch)
  end

  local function select_primary_power_mapping(device, zcl_clusters)
    if type(zcl_clusters) ~= "table" then
      return nil
    end

    local first_match = nil

    for _, mapping in ipairs(zcl_clusters) do
      if type(mapping) == "table" then
        local meta = zcl.mapping_meta(mapping)
        if meta ~= nil and meta.metering_kind == "power" and not meta.write_only then
          local context = zcl.build_mapping_context(device, mapping, nil)
          local candidate = {
            mapping = mapping,
            meta = meta,
            context = context,
          }

          if context.component_id == "main" then
            return candidate
          end

          if first_match == nil then
            first_match = candidate
          end
        end
      end
    end

    return first_match
  end

  local function default_power_poll_interval(device, zcl_clusters)
    local entry = select_primary_power_mapping(device, zcl_clusters)
    if entry == nil then
      return nil
    end

    return clamp_power_poll_interval(entry.meta.poll_interval)
  end

  local function resolved_power_poll_interval(device, zcl_clusters)
    local override = clamp_power_poll_interval(device:get_field(POWER_POLL_INTERVAL_FIELD))
    if override ~= nil then
      return override
    end

    return default_power_poll_interval(device, zcl_clusters)
  end

  local function current_time_epoch()
    local epoch = os.time()
    if type(epoch) == "number" then
      return epoch
    end

    return nil
  end

  local function normalize_switch_state(value)
    if value == true or value == "on" then
      return "on"
    end

    if value == false or value == "off" then
      return "off"
    end

    return nil
  end

  local function switch_state_value(device)
    local state = normalize_switch_state(device:get_field(SWITCH_STATE_FIELD))
    if state ~= nil then
      return state
    end

    local latest = normalize_switch_state(type(device.get_latest_state) == "function" and
      device:get_latest_state("main", capabilities.switch.ID, "switch") or nil)
    if latest ~= nil then
      return latest
    end

    return nil
  end

  local function switch_aware_polling_enabled(device)
    return supports_main_capability(device, capabilities.switch)
  end

  local function read_metering_mappings_once(device, zcl_clusters)
    if type(zcl_clusters) ~= "table" then
      return false
    end

    local read_count = 0
    local seen = {}

    for _, mapping in ipairs(zcl_clusters) do
      if type(mapping) == "table" then
        local meta = zcl.mapping_meta(mapping)
        if meta ~= nil and meta.metering_kind ~= nil and not meta.write_only then
          local mapping_context = zcl.build_mapping_context(device, mapping, nil)
          local key = string.format(
            "%04X:%04X:%s:%s",
            meta.cluster_id or 0,
            meta.attribute_id or 0,
            tostring(mapping_context.endpoint),
            tostring(meta.mfg_code)
          )

          if not seen[key] then
            seen[key] = true
            zcl.read_mapping(device, mapping, mapping_context)
            read_count = read_count + 1
          end
        end
      end
    end

    return read_count > 0
  end

  local function schedule_state_confirm_polls(device, zcl_clusters, expected_state, delays, timer_name)
    if type(zcl_clusters) ~= "table" or device.thread == nil or type(device.thread.call_with_delay) ~= "function" then
      return false
    end

    if type(delays) ~= "table" then
      return false
    end

    local scheduled = false
    local timers = poll_timers[device]
    if type(timers) ~= "table" then
      timers = {}
      poll_timers[device] = timers
    end

    for _, delay in ipairs(delays) do
      if type(delay) == "number" and delay > 0 then
        local timer = device.thread:call_with_delay(delay, function()
          if switch_state_value(device) == expected_state then
            read_metering_mappings_once(device, zcl_clusters)
          end
        end, timer_name)

        if timer ~= nil then
          timers[#timers + 1] = timer
          scheduled = true
        end
      end
    end

    return scheduled
  end

  local function effective_poll_interval(device, zcl_clusters, meta)
    if meta == nil then
      return nil
    end

    local poll_interval = meta.poll_interval
    if meta.metering_kind == "power" then
      poll_interval = resolved_power_poll_interval(device, zcl_clusters)
    end

    if type(poll_interval) ~= "number" or poll_interval <= 0 then
      return poll_interval
    end

    if not switch_aware_polling_enabled(device) or meta.metering_kind == nil then
      return poll_interval
    end

    if switch_state_value(device) == "off" and meta.metering_kind ~= "voltage" then
      return OFF_STATE_POLL_INTERVAL
    end

    return poll_interval
  end

  local function emit_power_poll_interval_state(device, zcl_clusters)
    local interval = resolved_power_poll_interval(device, zcl_clusters)
    local capability, attribute = resolve_capability_attribute(
      POWER_POLL_INTERVAL_METADATA,
      POWER_POLL_INTERVAL_METADATA and POWER_POLL_INTERVAL_METADATA.attribute_name or nil
    )
    if interval == nil or attribute == nil or not supports_main_capability(device, capability) then
      return false
    end

    local _, range_attribute = resolve_capability_attribute(
      POWER_POLL_INTERVAL_METADATA,
      POWER_POLL_INTERVAL_METADATA and POWER_POLL_INTERVAL_METADATA.range_attribute_name or nil
    )

    if range_attribute ~= nil then
      emit_main_event(device, range_attribute({
        value = {
          minimum = POWER_POLL_INTERVAL_MIN,
          maximum = POWER_POLL_INTERVAL_MAX,
          step = POWER_POLL_INTERVAL_STEP,
        },
        unit = POWER_POLL_INTERVAL_UNIT,
      }))
    end

    emit_main_event(device, attribute({
      value = interval,
      unit = POWER_POLL_INTERVAL_UNIT,
    }))

    return true
  end

  local function emit_last_power_response_state(device)
    local capability, attribute = resolve_capability_attribute(
      LAST_POWER_RESPONSE_TIME_METADATA,
      LAST_POWER_RESPONSE_TIME_METADATA and LAST_POWER_RESPONSE_TIME_METADATA.attribute_name or nil
    )
    if attribute == nil or not supports_main_capability(device, capability) then
      return false
    end

    emit_main_event(device, attribute({
      value = format_power_response_time(device:get_field(LAST_POWER_RESPONSE_AT_FIELD)),
    }))

    return true
  end

  local function field_key(kind, field_name, endpoint)
    return string.format("_zcl_metering:%s:%s:%d", tostring(kind), tostring(field_name), normalize_endpoint(endpoint))
  end

  local function build_spec(kind, cluster_name, multiplier_name, divisor_name, multiplier_store_key, divisor_store_key)
    local cluster_id = zcl.get_generated_cluster_id(cluster_name)
    local multiplier = zcl.get_generated_attribute_by_name(cluster_name, multiplier_name)
    local divisor = zcl.get_generated_attribute_by_name(cluster_name, divisor_name)
    if cluster_id == nil or multiplier == nil or divisor == nil then
      return nil
    end

    return {
      kind = kind,
      cluster_id = cluster_id,
      multiplier_attribute_id = multiplier.ID,
      divisor_attribute_id = divisor.ID,
      multiplier_store_key = multiplier_store_key,
      divisor_store_key = divisor_store_key,
    }
  end

  local function set_scaler(device, spec, field_name, value, endpoint)
    local numeric = normalize_numeric(value)
    if numeric == nil then
      return false
    end

    device:set_field(field_key(spec.kind, field_name, endpoint), numeric, { persist = true })

    if normalize_endpoint(endpoint) == 1 then
      if field_name == "multiplier" and spec.multiplier_store_key ~= nil then
        device:set_field(spec.multiplier_store_key, numeric, { persist = true })
      elseif field_name == "divisor" and spec.divisor_store_key ~= nil then
        device:set_field(spec.divisor_store_key, numeric, { persist = true })
      end
    end

    return true
  end

  local function get_scaler(device, spec, field_name, endpoint)
    endpoint = normalize_endpoint(endpoint)

    local numeric = device:get_field(field_key(spec.kind, field_name, endpoint))
    if type(numeric) == "number" then
      return numeric
    end

    if endpoint == 1 then
      local compatibility_key = field_name == "multiplier" and spec.multiplier_store_key or spec.divisor_store_key
      if compatibility_key ~= nil then
        numeric = device:get_field(compatibility_key)
        if type(numeric) == "number" then
          return numeric
        end
      end
    end

    return nil
  end

  local function read_scaler(device, spec, attribute_id, endpoint)
    if zcl.read_attribute == nil then
      return false
    end

    return zcl.read_attribute(device, spec.cluster_id, attribute_id, endpoint)
  end

  local function cancel_poll_timers(device)
    local timers = poll_timers[device]
    if type(timers) ~= "table" or device.thread == nil or type(device.thread.cancel_timer) ~= "function" then
      poll_timers[device] = nil
      return
    end

    for _, timer in ipairs(timers) do
      if timer ~= nil then
        device.thread:cancel_timer(timer)
      end
    end

    poll_timers[device] = nil
  end

  local function ensure_metering_specs()
    if next(metering_specs) ~= nil then
      return
    end

    metering_specs.energy = build_spec(
      "energy",
      "SimpleMetering",
      "Multiplier",
      "Divisor",
      zigbee_constants.SIMPLE_METERING_MULTIPLIER_KEY,
      zigbee_constants.SIMPLE_METERING_DIVISOR_KEY
    )
    metering_specs.power = build_spec(
      "power",
      "ElectricalMeasurement",
      "ACPowerMultiplier",
      "ACPowerDivisor",
      zigbee_constants.ELECTRICAL_MEASUREMENT_MULTIPLIER_KEY,
      zigbee_constants.ELECTRICAL_MEASUREMENT_DIVISOR_KEY
    )
    metering_specs.voltage = build_spec(
      "voltage",
      "ElectricalMeasurement",
      "ACVoltageMultiplier",
      "ACVoltageDivisor"
    )
    metering_specs.current = build_spec(
      "current",
      "ElectricalMeasurement",
      "ACCurrentMultiplier",
      "ACCurrentDivisor"
    )

    for _, spec in pairs(metering_specs) do
      if spec ~= nil then
        zcl.register_attribute(spec.cluster_id, spec.multiplier_attribute_id)
        zcl.register_attribute(spec.cluster_id, spec.divisor_attribute_id)
      end
    end
  end

  function zcl.handle_internal_attribute(device, cluster_id, attribute_id, raw_value, attribute_info)
    ensure_metering_specs()

    local endpoint = type(attribute_info) == "table" and (attribute_info.endpoint or attribute_info.src_endpoint) or nil
    for _, spec in pairs(metering_specs) do
      if spec ~= nil and cluster_id == spec.cluster_id then
        if attribute_id == spec.multiplier_attribute_id then
          return set_scaler(device, spec, "multiplier", raw_value, endpoint)
        end

        if attribute_id == spec.divisor_attribute_id then
          return set_scaler(device, spec, "divisor", raw_value, endpoint)
        end
      end
    end

    return false
  end

  function zcl.scale_mapping_value(device, mapping, raw_value, meta, mapping_context)
    if raw_value == nil or meta == nil then
      return raw_value
    end

    local spec = meta.metering_kind and metering_specs[meta.metering_kind] or nil
    if spec ~= nil and type(raw_value) == "number" then
      local endpoint = mapping_context and mapping_context.endpoint or nil
      local multiplier = get_scaler(device, spec, "multiplier", endpoint) or 1
      local divisor = get_scaler(device, spec, "divisor", endpoint) or 1
      if divisor == 0 then
        divisor = 1
      end

      if multiplier ~= 1 or divisor ~= 1 then
        return raw_value * multiplier / divisor
      end
    end

    if meta.scale == nil or meta.scale == 1 then
      return raw_value
    end

    if type(raw_value) == "number" and type(meta.scale) == "number" and meta.scale ~= 0 then
      return raw_value / meta.scale
    end

    return raw_value
  end

  function zcl.read_metering_scalers(device, zcl_clusters)
    ensure_metering_specs()

    if type(zcl_clusters) ~= "table" then
      return false
    end

    local sent = false
    local seen = {}

    for _, mapping in ipairs(zcl_clusters) do
      if type(mapping) == "table" then
        local meta = zcl.mapping_meta(mapping)
        local spec = meta and meta.metering_kind and metering_specs[meta.metering_kind] or nil
        if spec ~= nil then
          local mapping_context = zcl.build_mapping_context(device, mapping, nil)
          local endpoint = normalize_endpoint(mapping_context.endpoint)

          local multiplier_key = string.format("%04X:%04X:%d", spec.cluster_id, spec.multiplier_attribute_id, endpoint)
          if not seen[multiplier_key] then
            seen[multiplier_key] = true
            sent = read_scaler(device, spec, spec.multiplier_attribute_id, endpoint) or sent
          end

          local divisor_key = string.format("%04X:%04X:%d", spec.cluster_id, spec.divisor_attribute_id, endpoint)
          if not seen[divisor_key] then
            seen[divisor_key] = true
            sent = read_scaler(device, spec, spec.divisor_attribute_id, endpoint) or sent
          end
        end
      end
    end

    return sent
  end

  function zcl.emit_power_polling_state(device, zcl_clusters)
    local emitted = false

    emitted = emit_power_poll_interval_state(device, zcl_clusters) or emitted
    emitted = emit_last_power_response_state(device) or emitted

    return emitted
  end

  function zcl.set_power_poll_interval(device, zcl_clusters, value)
    if default_power_poll_interval(device, zcl_clusters) == nil then
      return false
    end

    local interval = clamp_power_poll_interval(value)
    if interval == nil then
      return false
    end

    device:set_field(POWER_POLL_INTERVAL_FIELD, interval, { persist = true })
    zcl.start_runtime(device, zcl_clusters)
    zcl.emit_power_polling_state(device, zcl_clusters)

    return true
  end

  function zcl.handle_metering_value(device, _, value, meta)
    if meta == nil or meta.metering_kind ~= "power" or type(value) ~= "number" then
      return false
    end

    local epoch = os.time()
    if type(epoch) ~= "number" then
      return false
    end

    device:set_field(LAST_POWER_RESPONSE_AT_FIELD, epoch, { persist = true })
    emit_last_power_response_state(device)

    return true
  end

  function zcl.begin_power_poll_burst(device, zcl_clusters)
    if not switch_aware_polling_enabled(device) then
      return false
    end

    device:set_field(SWITCH_STATE_FIELD, "on", { persist = false })

    if type(zcl_clusters) == "table" then
      zcl.start_runtime(device, zcl_clusters)
      schedule_state_confirm_polls(device, zcl_clusters, "on", ON_STATE_CONFIRM_POLL_DELAYS, "zcl on-state confirm poll")
    end

    return true
  end

  function zcl.handle_switch_state(device, zcl_clusters, value)
    value = normalize_switch_state(value)
    if not switch_aware_polling_enabled(device) or value == nil then
      return false
    end

    local previous = switch_state_value(device)
    device:set_field(SWITCH_STATE_FIELD, value, { persist = false })

    if value == "on" and previous ~= "on" then
      return zcl.begin_power_poll_burst(device, zcl_clusters)
    end

    if value == "off" and previous ~= "off" then
      if type(zcl_clusters) == "table" then
        zcl.start_runtime(device, zcl_clusters)
        schedule_state_confirm_polls(device, zcl_clusters, "off", OFF_STATE_CONFIRM_POLL_DELAYS, "zcl off-state confirm poll")
      end
      return true
    end

    return false
  end

  function zcl.start_runtime(device, zcl_clusters)
    cancel_poll_timers(device)

    if type(zcl_clusters) ~= "table" or device.thread == nil or type(device.thread.call_on_schedule) ~= "function" then
      return false
    end

    local timers = {}
    local seen = {}

    for _, mapping in ipairs(zcl_clusters) do
      if type(mapping) == "table" then
        local meta = zcl.mapping_meta(mapping)
        local poll_interval = effective_poll_interval(device, zcl_clusters, meta)

        if meta ~= nil and type(poll_interval) == "number" and poll_interval > 0 and not meta.write_only then
          local mapping_context = zcl.build_mapping_context(device, mapping, nil)
          local key = string.format(
            "%04X:%04X:%s:%s",
            meta.cluster_id or 0,
            meta.attribute_id or 0,
            tostring(mapping_context.endpoint),
            tostring(meta.mfg_code)
          )

          if not seen[key] then
            seen[key] = true
            local timer = device.thread:call_on_schedule(poll_interval, function()
              zcl.read_mapping(device, mapping, zcl.build_mapping_context(device, mapping, nil))
            end, string.format("zcl metering poll %s", tostring(meta.name or key)))

            if timer ~= nil then
              timers[#timers + 1] = timer
            end
          end
        end
      end
    end

    poll_timers[device] = timers
    return #timers > 0
  end

  function zcl.stop_runtime(device)
    cancel_poll_timers(device)
  end

  ensure_metering_specs()
end

return load_metering
