local device_management = require "st.zigbee.device_management"
local capabilities = require "st.capabilities"
local data_types = require "st.zigbee.data_types"
local response_record = require("st.zigbee.zcl.global_commands").ReadReportingConfigurationResponse.ReportingConfigurationRecord
local deserialize_record, record_fields = response_record.deserialize, response_record.get_fields
-- API16 omits direction/attribute on negative ReadReportingConfiguration records.
response_record.deserialize = function(buf)
  local record = deserialize_record(buf)
  if record.status.value ~= 0 and not record.direction then
    record.direction = data_types.Uint8.deserialize(buf)
    record.attr_id = data_types.AttributeId.deserialize(buf)
  end
  return record
end
response_record.get_fields = function(record)
  local fields = record_fields(record)
  fields[2], fields[3] = record.direction, record.attr_id
  return fields
end
local reporting = {}
local pending_by_device = setmetatable({}, {__mode = "k"})
local pending_field = "zcl_reporting_pending"
local retry_interval = 30
local measurement_clusters = {[0x0408] = true, [0x040D] = true, [0x042A] = true, [0x042B] = true}
local items = {
  [0x0000] = {[0] = "Heartbeat"},
  [0x0001] = {[0x20] = "BattVolt", [0x21] = "Battery", [0x3E] = "BattAlarm", [0x40] = "BattTwo"},
  [0x0002] = {[0] = "DeviceTmp"}, [0x0006] = {[0] = "Switch", [0x4003] = "PowerOn"},
  [0x0008] = {[0] = "Level"}, [0x000D] = {[0x55] = "Analog"}, [0x000F] = {[0x55] = "Binary"},
  [0x0101] = {[0] = "Lock"}, [0x0102] = {[8] = "Position", [9] = "Tilt"},
  [0x0201] = {[0] = "LocalTemp", [8] = "Demand", [0x10] = "TempCal", [0x11] = "CoolSet", [0x12] = "HeatSet", [0x13] = "CoolSet", [0x14] = "HeatSet", [0x1C] = "Mode", [0x29] = "State", [0x45] = "Louver"},
  [0x0202] = {[0] = "FanMode"}, [0x0300] = {[0] = "Hue", [1] = "Sat", [7] = "ColorTemp"},
  [0x0400] = {[0] = "Light"}, [0x0402] = {[0] = "Temp"}, [0x0403] = {[0] = "Pressure", [4] = "ScalePres"},
  [0x0405] = {[0] = "Humidity"}, [0x0406] = {[0] = "Occupancy"}, [0x0408] = {[0] = "Soil"},
  [0x040C] = {[0] = "Co"}, [0x040D] = {[0] = "CoTwo"}, [0x042A] = {[0] = "PmFine"}, [0x042B] = {[0] = "Hcho"},
  [0x0500] = {[2] = "Ias"}, [0x0702] = {[0] = "Energy", [1] = "Export", [0x0400] = "Power"},
  [0x0B04] = {[0x0300] = "Frequency", [0x0304] = "TotalPwr", [0x0305] = "ReactivePwr", [0x0505] = "Voltage", [0x0508] = "Current", [0x050B] = "Power", [0x0905] = "VoltageB", [0x0A05] = "VoltageC", [0x0908] = "CurrentB", [0x0A08] = "CurrentC"},
}
local fields = {
  {"minimum_interval", "Min", "minimumInterval"},
  {"maximum_interval", "Max", "maximumInterval"},
  {"reportable_change", "Change", "reportableChange"},
}

function reporting.describe(zcl, mapping, device, cache)
  local meta = zcl.mapping_meta(mapping, cache)
  local defaults = meta.reporting_defaults or meta
  if meta.write_only or meta.cluster_id == nil or meta.attribute_id == nil or
      meta.data_type == nil or meta.mfg_code ~= nil or meta.cluster_id >= 0xFC00 or
      (defaults.minimum_interval == nil and defaults.maximum_interval == nil and
       defaults.reportable_change == nil and meta.physical_reportable_change == nil) or
      (device ~= nil and defaults.supported ~= nil and not defaults.supported(device)) or
      (zcl.get_generated_attribute(meta.cluster_id, meta.attribute_id) == nil and
       not (measurement_clusters[meta.cluster_id] and meta.attribute_id == 0) and
       not (meta.cluster_id == 0x0702 and meta.attribute_id == 1 and meta.data_type.ID == 0x25)) then
    return nil
  end
  local endpoint = type(meta.endpoint) == "number" and tostring(meta.endpoint) or "auto"
  local item = defaults.label == "Soil moisture" and "Soil" or (items[meta.cluster_id] or {})[meta.attribute_id]
  if item == nil then return nil end
  return {
    key = defaults.key or string.format("zr%04x%04x%s", meta.cluster_id, meta.attribute_id, endpoint),
    group = string.format("%04x:%04x", meta.cluster_id, meta.attribute_id),
    meta = meta,
    defaults = defaults,
    analog = not meta.data_type.is_discrete,
    item = item,
  }
end

local function pending(device, key)
  local items = pending_by_device[device]
  local item = items and items[key]
  if item and item.expires and item.expires <= os.time() then items[key], item = nil, nil end
  return item
end

local function save_pending(device)
  local saved = {}
  for key, request in pairs(pending_by_device[device] or {}) do
    if not request.expires and not request.failed then saved[key] = request.selected end
  end
  device:set_field(pending_field, next(saved) and saved or nil, {persist = true})
end

local function reject(device, request)
  request.failed = true
  save_pending(device)
end

local function overrides(device, descriptor, include_pending)
  local request = include_pending and pending(device, descriptor.key)
  return request and not request.failed and request.selected or device:get_field("zcl_reporting:" .. descriptor.key)
end

local function emit_value(device, capability_id, attribute, value, unit)
  if value == nil or not device:supports_capability_by_id(capability_id) then return end
  local event = {value = value}
  if unit then event.unit = unit end
  device:emit_event(capabilities[capability_id][attribute](event))
end

function reporting.configuration(zcl, device, mapping, scaled_change)
  local descriptor = reporting.describe(zcl, mapping, device)
  if descriptor == nil then return nil end
  local meta = descriptor.meta
  local defaults = descriptor.defaults
  local selected = overrides(device, descriptor, true)
  if scaled_change ~= nil then
    local raw_change = type(scaled_change) == "table" and scaled_change.value or scaled_change
    device:set_field("zcl_reporting_default:" .. descriptor.key, raw_change)
    local control = device:get_field("zcl_reporting_change:" .. descriptor.key)
    if control and (selected == nil or selected.reportable_change == nil) then
      emit_value(device, control, "reportableChange", raw_change)
    end
  end
  local values = selected or {}
  local max_interval = values.maximum_interval or defaults.maximum_interval or 300
  local change = values.reportable_change
  if change == nil then
    change = defaults.reportable_change
    if meta.physical_reportable_change ~= nil then
      change = scaled_change
    end
  end
  if max_interval == 65535 then change = 0 end
  if descriptor.analog and change == nil then return nil end
  if descriptor.analog and type(change) ~= "table" then
    if meta.data_type.ID == 0x39 then
      local Reader = require "st.buf".Reader
      change = meta.data_type.deserialize(Reader(string.pack("<f", change)))
    else
      change = meta.data_type(change)
    end
  end
  return {
    cluster = meta.cluster_id, attribute = meta.attribute_id, data_type = meta.data_type,
    minimum_interval = values.minimum_interval or defaults.minimum_interval or 0,
    maximum_interval = max_interval,
    reportable_change = descriptor.analog and change or nil,
  }, selected ~= nil
end

local function active_descriptor(zcl, device, entry, mapping_index)
  local mapping = entry.zcl_clusters[mapping_index]
  local descriptor = reporting.describe(zcl, mapping, device)
  if descriptor then return descriptor end
  local original = reporting.describe(zcl, mapping)
  if original then
    for _, candidate in ipairs(entry.zcl_clusters) do
      descriptor = reporting.describe(zcl, candidate, device)
      if descriptor and descriptor.key == original.key then return descriptor end
    end
  end
end

function reporting.discard_unsupported(zcl, device)
  local changed = false
  for key, request in pairs(pending_by_device[device] or {}) do
    if not active_descriptor(zcl, device, request.entry, request.mapping_index) then
      pending_by_device[device][key] = nil
      changed = true
    end
  end
  if changed then save_pending(device) end
end

local function emit_settings(zcl, device, entry)
  for _, item in ipairs(entry.reporting_settings) do
    local descriptor = active_descriptor(zcl, device, entry, item.mapping_index)
    if descriptor then
      local selected = overrides(device, descriptor) or {}
      for index, field in ipairs(fields) do
        local capability_id = item.capabilities[index]
        if capability_id then
          local value = selected[field[1]] or descriptor.defaults[field[1]]
          if value == nil and index == 3 then
            value = device:get_field("zcl_reporting_default:" .. descriptor.key)
          end
          if type(value) == "table" then value = value.value end
          if index == 3 then device:set_field("zcl_reporting_change:" .. descriptor.key, capability_id) end
          emit_value(device, capability_id, field[3], value, index < 3 and "s")
        end
      end
    end
  end
end

local function restore_pending(zcl, device, entry)
  local saved = device:get_field(pending_field) or {}
  pending_by_device[device] = pending_by_device[device] or {}
  for _, item in ipairs(entry.reporting_settings) do
    if saved[item.key] and not pending(device, item.key) and
        active_descriptor(zcl, device, entry, item.mapping_index) then
      pending_by_device[device][item.key] = {selected = saved[item.key], entry = entry,
        mapping_index = item.mapping_index, targets = {}}
    end
  end
end

-- Family defaults are queued once for an exact device; explicit user settings win.
function reporting.queue_defaults(zcl, device, entry, values)
  restore_pending(zcl, device, entry)
  for _, item in ipairs(entry.reporting_settings) do
    if values[item.key] and not pending(device, item.key) and
        device:get_field("zcl_reporting:" .. item.key) == nil and
        active_descriptor(zcl, device, entry, item.mapping_index) then
      pending_by_device[device][item.key] = {selected = values[item.key], entry = entry,
        mapping_index = item.mapping_index, targets = {}, verify_first = true}
    end
  end
  save_pending(device)
end

local function send_pending(zcl, device, key, request)
  local descriptor = active_descriptor(zcl, device, request.entry, request.mapping_index)
  if not descriptor then return end
  request.targets = {}
  local groups = {[descriptor.group] = {[key] = true}}
  local sent, needs_scaler = pcall(reporting.send, zcl, device, request.entry.zcl_clusters, groups, false)
  if not sent then pending_by_device[device][key] = nil; save_pending(device); return false end
  if needs_scaler and zcl.read_metering_scalers then
    zcl.read_metering_scalers(device, request.entry.zcl_clusters)
  end
  return true
end

function reporting.on_rx(zcl, device, rx)
  if rx.address_header.profile.value == 0 then
    if rx.address_header.cluster.value ~= 0x0013 then return end
  else
    local header = rx.body.zcl_header
    if not header.frame_ctrl:is_cluster_specific_set() and header.cmd.value ~= 0x0A then return end
  end
  reporting.discard_unsupported(zcl, device)
  for key, request in pairs(pending_by_device[device] or {}) do
    if not request.expires and not request.failed and (request.last_retry == nil or os.time() - request.last_retry >= retry_interval) then
      request.last_retry = os.time()
      send_pending(zcl, device, key, request)
    end
  end
end

function reporting.set(zcl, device, entry, mapping_index, field, value)
  local descriptor = active_descriptor(zcl, device, entry, mapping_index)
  if descriptor == nil or type(value) ~= "number" or value ~= value or value < 0 then return false end
  local data_type = descriptor.meta.data_type
  local floating = field == "reportable_change" and data_type.ID == 0x39
  local maximum = field == "minimum_interval" and 65534 or 65535
  if field == "reportable_change" then
    if not descriptor.analog then return false end
    local signed = data_type.ID >= 0x28 and data_type.ID <= 0x2F
    maximum = floating and 3.4028234663852886e38 or (2 ^ (8 * data_type.byte_length - (signed and 1 or 0)) - 1)
  end
  if value > maximum or (not floating and value % 1 ~= 0) then return false end
  local selected = {}
  for key, prior in pairs(overrides(device, descriptor, true) or {}) do selected[key] = prior end
  selected[field] = value
  local minimum = selected.minimum_interval or descriptor.defaults.minimum_interval or 0
  local max_interval = selected.maximum_interval or descriptor.defaults.maximum_interval or 300
  if max_interval ~= 0 and max_interval ~= 65535 and minimum > max_interval then return false end
  if field == "reportable_change" and max_interval == 65535 then return false end
  pending_by_device[device] = pending_by_device[device] or {}
  pending_by_device[device][descriptor.key] = {selected = selected, entry = entry, mapping_index = mapping_index,
    targets = {}, expires = not device:supports_capability_by_id(capabilities.battery.ID) and os.time() + 30 or nil}
  save_pending(device)
  return send_pending(zcl, device, descriptor.key, pending(device, descriptor.key))
end

local function read_config(device, cluster, attribute, endpoint)
  local read = require "st.zigbee.zcl.global_commands.read_reporting_configuration"
  local tx = device_management.attr_refresh(device, cluster, attribute):to_endpoint(endpoint)
  tx.body.zcl_body = read.ReadReportingConfiguration({read.ReadReportingConfigurationAttributeRecord(0, attribute)})
  tx.body.zcl_header.cmd.value = 8
  return tx
end

function reporting.send_config(device, key, config, endpoint)
  local tx = device_management.attr_config(device, config):to_endpoint(endpoint)
  local request = key and pending(device, key)
  if request and not request.failed then
    request.targets[config.cluster .. ":" .. endpoint] = {wire = tx.body.zcl_body:_serialize()}
    if request.verify_first then tx = read_config(device, config.cluster, config.attribute, endpoint) end
  end
  device:send(tx)
end

function reporting.global_handlers(zcl, handlers)
  local function response(_, device, rx)
    local cluster, endpoint = rx.address_header.cluster.value, rx.address_header.src_endpoint.value
    local command, body = rx.body.zcl_header.cmd.value, rx.body.zcl_body
    local address = cluster .. ":" .. endpoint
    reporting.discard_unsupported(zcl, device)
    for key in pairs(pending_by_device[device] or {}) do
      local request = pending(device, key)
      local target = request and request.targets[address]
      if target then
        local attribute = string.unpack("<I2", target.wire, 2)
        if command == 7 then
          local status = body.global_status and body.global_status.value
          for _, record in ipairs(body.config_records or {}) do
            if record.direction.value == 0 and record.attr_id.value == attribute then status = record.status.value end
          end
          if status ~= nil and status ~= 0 then reject(device, request) end
          local tx = read_config(device, cluster, attribute, endpoint)
          if not pcall(device.send, device, tx) then
            pending_by_device[device][key] = nil
            save_pending(device)
          end
        elseif command == 11 then
          if (body.cmd.value == 6 or body.cmd.value == 8) and body.status.value ~= 0 then reject(device, request) end
        else
          for _, record in ipairs(body.read_reporting_records) do
            if getmetatable(record) == response_record and record.direction.value == 0 and record.attr_id.value == attribute then
              -- Error records are shorter; only success can match the full configure record.
              if record:_serialize():sub(2) == target.wire then
                request.targets[address] = nil
                if not next(request.targets) then
                  device:set_field("zcl_reporting:" .. key, request.selected, {persist = true})
                  device:remove_configured_attribute(cluster, attribute)
                  pending_by_device[device][key] = nil
                  save_pending(device)
                  emit_settings(zcl, device, request.entry)
                end
              elseif request.verify_first and (record.status.value == 0 or record.status.value == 0x8B) then
                request.verify_first = nil
                send_pending(zcl, device, key, request)
              elseif record.status.value ~= 0 then
                reject(device, request)
              end
            end
          end
        end
      end
    end
  end
  for cluster in pairs(items) do
    handlers[cluster] = handlers[cluster] or {}
    for _, command in ipairs({7, 9, 11}) do
      local previous = handlers[cluster][command]
      if previous ~= nil then
        handlers[cluster][command] = function(...)
          local result = previous(...)
          response(...)
          return result
        end
      else
        handlers[cluster][command] = response
      end
    end
  end
  return handlers
end

function reporting.attach(zcl, registrations, bindings)
  for _, binding in ipairs(bindings) do
    local entry = registrations[binding[1]]
    local previous_start, previous_refresh = entry.runtime_start, entry.zcl_refresh_before_read_all
    local writers, commands = {}, {}
    for key, writer in pairs(entry.protocol_writers or {}) do writers[key] = writer end
    for _, command in ipairs(entry.capability_commands or {}) do commands[#commands + 1] = command end
    entry.protocol_writers, entry.capability_commands, entry.reporting_settings = writers, commands, {}
    local settings = {zcl_clusters = entry.zcl_clusters, reporting_settings = entry.reporting_settings}
    entry.profile = binding[2]
    local seen = {}
    for mapping_index, mapping in ipairs(entry.zcl_clusters or {}) do
      local descriptor = reporting.describe(zcl, mapping, nil, false)
      if descriptor and not seen[descriptor.key] then
        seen[descriptor.key] = true
        local logical_item = binding[3] and binding[3][descriptor.key]
        if logical_item == nil then logical_item = descriptor.item end
        if logical_item ~= false then
          local item = {mapping_index = mapping_index, key = descriptor.key, capabilities = {}}
          entry.reporting_settings[#entry.reporting_settings + 1] = item
          for index, field in ipairs(fields) do
            if index < 3 or descriptor.analog then
              local short_id = "zcl" .. logical_item .. "Report" .. field[2] ..
                (index == 3 and string.format("%02x", descriptor.meta.data_type.ID) or "")
              local capability_id = "concertmirror08464." .. short_id
              local command_name = "set" .. field[3]:sub(1, 1):upper() .. field[3]:sub(2)
              local mapping_name = "zcl_reporting_" .. short_id
              item.capabilities[index] = capability_id
              commands[#commands + 1] = {capability_id = capability_id, command_name = command_name,
                argument_name = field[3], mapping_name = mapping_name, attribute_name = field[3]}
              writers[mapping_name] = function(device, value)
                return reporting.set(zcl, device, settings, mapping_index, field[1], value)
              end
            end
          end
        end
      end
    end
    entry.runtime_start = function(device, ...)
      local result
      if previous_start then result = previous_start(device, ...) end
      restore_pending(zcl, device, settings)
      emit_settings(zcl, device, settings)
      return result
    end
    entry.zcl_refresh_before_read_all = function(device, ...)
      local result
      if previous_refresh then result = previous_refresh(device, ...) end
      emit_settings(zcl, device, settings)
      return result
    end
  end
end

function reporting.groups(zcl, device, mappings)
  local groups = {}
  for _, mapping in ipairs(mappings or {}) do
    local descriptor = reporting.describe(zcl, mapping, device)
    if descriptor ~= nil then
      if overrides(device, descriptor, true) ~= nil then
        groups[descriptor.group] = true
      end
    end
  end
  return groups
end

function reporting.send(zcl, device, mappings, groups, bind)
  local records, indexes, bindings, needs_scaler = {}, {}, {}, false
  for _, mapping in ipairs(mappings or {}) do
    local descriptor = reporting.describe(zcl, mapping, device)
    local selected = descriptor and groups[descriptor.group]
    if descriptor ~= nil and selected and (selected == true or selected[descriptor.key]) and
        not (bind and descriptor.meta.reporting_defaults ~= nil) then
      local meta = descriptor.meta
      local context = zcl.build_mapping_context(device, mapping)
      local endpoints = {}
      if meta.reporting_defaults and meta.reporting_defaults.all_endpoints then
        for _, endpoint in pairs(device.zigbee_endpoints or {}) do
          if device:supports_server_cluster(meta.cluster_id, endpoint.id) then endpoints[#endpoints + 1] = endpoint.id end
        end
        table.sort(endpoints)
      elseif context.endpoint ~= nil then
        endpoints[1] = context.endpoint
      elseif meta.reporting_defaults ~= nil then
        endpoints[1] = device:get_endpoint(meta.cluster_id)
      else
        for _, endpoint in ipairs(device.zigbee_endpoints or {}) do
          if device:supports_server_cluster(meta.cluster_id, endpoint.id) then endpoints[#endpoints + 1] = endpoint.id end
        end
        if #endpoints == 0 then endpoints[1] = device:get_endpoint(meta.cluster_id) end
      end
      local config = reporting.configuration(zcl, device, mapping)
      if config == nil then needs_scaler = meta.physical_reportable_change ~= nil or needs_scaler end
      for _, endpoint in ipairs(endpoints) do
        local key = descriptor.group .. ":" .. endpoint
        local index = indexes[key]
        local record = {config = config, endpoint = endpoint, explicit = meta.endpoint ~= nil, key = descriptor.key}
        if index == nil then
          indexes[key] = #records + 1
          records[#records + 1] = record
        elseif record.explicit and not records[index].explicit then
          records[index] = record
        end
      end
    end
  end
  for _, record in ipairs(records) do
    local config, endpoint = record.config, record.endpoint
    if config ~= nil then
      local key = config.cluster .. ":" .. endpoint
      if bind and not bindings[key] then
        zcl.bind_cluster(device, config.cluster, device.driver.environment_info.hub_zigbee_eui, endpoint)
        bindings[key] = true
      end
      reporting.send_config(device, record.key, config, endpoint)
    end
  end
  return needs_scaler
end

return reporting
