-- ZCL configure/read helper
-- reporting 설정과 초기 read 요청을 매핑 정의에서 공통 처리합니다.

local function load_configuration(zcl)

  local zigbee_constants = require "st.zigbee.constants"
  local BASIC_CLUSTER = 0x0000
  local BASIC_MAGIC_ATTRIBUTES = { 0x0004, 0x0000, 0x0001, 0x0005, 0x0007, 0xFFFE }

  local function is_callable_type(value)
    if type(value) == "function" then
      return true
    end

    if type(value) ~= "table" then
      return false
    end

    local metatable = getmetatable(value)
    return type(metatable) == "table" and type(metatable.__call) == "function"
  end

  local function normalize_reportable_change(data_type, reportable_change)
    if reportable_change == nil then
      return nil
    end

    if type(reportable_change) == "function" then
      return reportable_change
    end

    if is_callable_type(data_type) then
      return data_type(reportable_change)
    end

    return reportable_change
  end

  local function build_configured_attribute(meta)
    local has_reporting = meta.minimum_interval ~= nil or
      meta.maximum_interval ~= nil or
      meta.reportable_change ~= nil

    if not has_reporting or meta.write_only then
      return nil
    end

    if meta.cluster_id == nil or meta.attribute_id == nil or meta.data_type == nil then
      return nil
    end

    return {
      cluster = meta.cluster_id,
      attribute = meta.attribute_id,
      minimum_interval = meta.minimum_interval or 0,
      maximum_interval = meta.maximum_interval or 300,
      data_type = meta.data_type,
      reportable_change = normalize_reportable_change(meta.data_type, meta.reportable_change),
      mfg_code = meta.mfg_code,
    }
  end

  function zcl.build_configured_attributes(zcl_clusters)
    if type(zcl_clusters) ~= "table" then
      return {}
    end

    local configured = {}
    local seen = {}

    for _, mapping in ipairs(zcl_clusters) do
      if type(mapping) == "table" then
        local meta = zcl.mapping_meta(mapping)
        local item = meta and build_configured_attribute(meta) or nil
        if item ~= nil then
          local key = string.format("%04X:%04X", item.cluster, item.attribute)
          local existing_index = seen[key]
          if existing_index == nil then
            seen[key] = #configured + 1
            configured[#configured + 1] = item
          elseif configured[existing_index].mfg_code == nil and item.mfg_code ~= nil then
            configured[existing_index] = item
          end
        end
      end
    end

    return configured
  end

  function zcl.read_configured_attributes(device, zcl_clusters)
    if type(zcl_clusters) ~= "table" then
      return false
    end

    local sent = false
    local seen = {}

    for _, mapping in ipairs(zcl_clusters) do
      if type(mapping) == "table" then
        local meta = zcl.mapping_meta(mapping)
        if meta ~= nil and meta.read_on_configure and not meta.write_only then
          local mapping_context = zcl.build_mapping_context(device, mapping, nil)
          local key = string.format(
            "%04X:%04X:%s:%s",
            meta.cluster_id,
            meta.attribute_id,
            tostring(mapping_context.endpoint),
            tostring(meta.mfg_code)
          )
          if not seen[key] then
            seen[key] = true
            zcl.read_mapping(device, mapping, mapping_context)
            sent = true
          end
        end
      end
    end

    return sent
  end

  local function read_tuya_magic_packet(device, zcl_clusters)
    if type(zcl_clusters) ~= "table" then
      return false
    end

    local sent = false
    local seen = {}

    for _, mapping in ipairs(zcl_clusters) do
      local meta = type(mapping) == "table" and zcl.mapping_meta(mapping) or nil
      if meta ~= nil and meta.name == "tuya_magic_packet" then
        local mapping_context = zcl.build_mapping_context(device, mapping, nil)
        local endpoint = mapping_context and mapping_context.endpoint or nil
        local key = tostring(endpoint or "main")

        if not seen[key] then
          seen[key] = true
          for _, attribute_id in ipairs(BASIC_MAGIC_ATTRIBUTES) do
            zcl.read_attribute(device, BASIC_CLUSTER, attribute_id, endpoint)
          end
          sent = true
        end
      end
    end

    return sent
  end

  function zcl.start_configuration(device, zcl_clusters)
    if type(zcl_clusters) ~= "table" then
      return false
    end

    local ias_configure_method = nil
    for _, mapping in ipairs(zcl_clusters) do
      if type(mapping) == "table" then
        local meta = zcl.mapping_meta(mapping)
        if meta ~= nil and meta.cluster_id == zcl.CLUSTER_IAS_ZONE then
          ias_configure_method = meta.ias_configure_method or zigbee_constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE
          break
        end
      end
    end

    if ias_configure_method ~= nil and type(device.set_ias_zone_config_method) == "function" then
      device:set_ias_zone_config_method(ias_configure_method)
    end

    local configured = zcl.build_configured_attributes(zcl_clusters)
    if #configured > 0 and type(device.add_configured_attribute) == "function" then
      for _, item in ipairs(configured) do
        device:add_configured_attribute(item)
      end
    end

    local magic_read_any = read_tuya_magic_packet(device, zcl_clusters)
    local scaler_read_any = zcl.read_metering_scalers and zcl.read_metering_scalers(device, zcl_clusters) or false

    local should_configure = #configured > 0 or ias_configure_method ~= nil
    local configured_any = false
    if should_configure and type(device.configure) == "function" then
      device:configure()
      configured_any = true
    end

    local read_any = zcl.read_configured_attributes(device, zcl_clusters)
    local runtime_any = zcl.start_runtime and zcl.start_runtime(device, zcl_clusters) or false
    return configured_any or magic_read_any or scaler_read_any or read_any or runtime_any
  end

end

return load_configuration
