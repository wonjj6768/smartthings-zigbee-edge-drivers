-- ZCL 매핑 런타임 유틸리티
-- endpoint/component 해석, 매핑 메타, 인덱스 캐시를 공통 제공합니다.

local function load_runtime(zcl)

  local MAPPING_BUCKET_TAG = "__zcl_mapping_bucket"
  local meta_cache = setmetatable({}, { __mode = "k" })
  local index_cache = setmetatable({}, { __mode = "k" })
  local prepared_mappings = setmetatable({}, { __mode = "k" })

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

  local function normalize_endpoint(endpoint)
    if type(endpoint) ~= "number" or endpoint % 1 ~= 0 then
      return nil
    end

    return endpoint
  end

  local function resolve_context_component_id(device, context)
    if type(context) ~= "table" then
      return nil
    end

    local component_id = context.component_id or context.component
    if type(component_id) == "string" and component_id ~= "" then
      return component_id
    end

    local endpoint = normalize_endpoint(context.endpoint or context.src_endpoint)
    if endpoint ~= nil and type(device.get_component_id_for_endpoint) == "function" then
      local resolved = device:get_component_id_for_endpoint(endpoint)
      if type(resolved) == "string" and resolved ~= "" then
        return resolved
      end
    end

    return nil
  end

  local function resolve_context_endpoint(device, context)
    if type(context) ~= "table" then
      return nil
    end

    local endpoint = normalize_endpoint(context.endpoint or context.src_endpoint)
    if endpoint ~= nil then
      return endpoint
    end

    local component_id = context.component_id or context.component
    if type(component_id) == "string" and component_id ~= "" and type(device.get_endpoint_for_component_id) == "function" then
      local resolved = device:get_endpoint_for_component_id(component_id)
      if type(resolved) == "table" then
        resolved = resolved[1]
      end

      return normalize_endpoint(resolved)
    end

    return nil
  end

  local function build_mapping_meta(mapping)
    local cached = meta_cache[mapping]
    if cached ~= nil then
      return cached
    end

    local converter = type(mapping.converter) == "table" and mapping.converter or nil
    local custom_from_device = type(mapping.from_device) == "function" and mapping.from_device or nil
    local converter_from_device = converter and type(converter.from) == "function" and converter.from or nil
    local prefer_typed_value = mapping.prefer_typed_value == true or
      (converter and converter.prefer_typed_value == true) or
      false
    local configured_data_type = is_callable_type(mapping.data_type) and mapping.data_type or nil
    local configured_write_type = is_callable_type(mapping.write_type) and mapping.write_type or configured_data_type
    local attribute_def = nil
    if mapping.cluster_id ~= nil and mapping.attribute_id ~= nil and zcl.get_generated_attribute ~= nil then
      attribute_def = zcl.get_generated_attribute(mapping.cluster_id, mapping.attribute_id)
    end

    if attribute_def == nil and mapping.cluster_id ~= nil and mapping.attribute_id ~= nil and zcl.build_dynamic_attribute ~= nil then
      local dynamic_base_type = configured_data_type or configured_write_type
      if dynamic_base_type ~= nil then
        attribute_def = zcl.build_dynamic_attribute(
          mapping.cluster_id,
          mapping.attribute_id,
          dynamic_base_type,
          mapping.read_only ~= true,
          mapping.attribute_name,
          mapping.complex_type == true
        )
      end
    end

    local meta = {
      from_device = custom_from_device or converter_from_device,
      custom_from_device = custom_from_device ~= nil,
      converter_from_device = converter_from_device ~= nil,
      prefer_typed_value = prefer_typed_value,
      to_device = type(mapping.to_device) == "function" and mapping.to_device or
        (converter and type(converter.to) == "function" and converter.to or nil),
      emit = type(mapping.emit) == "function" and mapping.emit or nil,
      handler = type(mapping.handler) == "function" and mapping.handler or nil,
      sender = type(mapping.sender) == "function" and mapping.sender or nil,
      command_id = type(mapping.command_id) == "number" and mapping.command_id or nil,
      command_extractor = type(mapping.command_extractor) == "function" and mapping.command_extractor or nil,
      tx_command_id = type(mapping.tx_command_id) == "number" and mapping.tx_command_id or nil,
      tx_command_direction = mapping.tx_command_direction == "client" and "client" or "server",
      endpoint = (type(mapping.endpoint) == "number" or type(mapping.endpoint) == "function") and mapping.endpoint or nil,
      component = (type(mapping.component) == "string" or type(mapping.component) == "function") and mapping.component or nil,
      read_only = mapping.read_only == true,
      write_only = mapping.write_only == true,
      minimum_interval = mapping.minimum_interval,
      maximum_interval = mapping.maximum_interval,
      reportable_change = mapping.reportable_change,
      read_on_configure = mapping.read_on_configure == true,
      poll_interval = type(mapping.poll_interval) == "number" and mapping.poll_interval or nil,
      ias_configure_method = mapping.ias_configure_method,
      mfg_code = type(mapping.mfg_code) == "number" and mapping.mfg_code or nil,
      metering_kind = type(mapping.metering_kind) == "string" and mapping.metering_kind or nil,
      scale = type(mapping.scale) == "number" and mapping.scale or nil,
      attribute_def = attribute_def,
      data_type = configured_data_type or
        (attribute_def and attribute_def.base_type or nil),
      write_type = configured_write_type or
        (attribute_def and attribute_def.base_type or nil),
      name = mapping.name,
      cluster_id = mapping.cluster_id,
      attribute_id = mapping.attribute_id,
    }

    meta_cache[mapping] = meta
    return meta
  end

  local function resolve_mapping_endpoint(device, mapping, context)
    local meta = build_mapping_meta(mapping)
    local endpoint = meta.endpoint
    if type(endpoint) == "function" then
      endpoint = endpoint(device, mapping, context)
    end

    return normalize_endpoint(endpoint)
  end

  local function resolve_mapping_component_id(device, mapping, context)
    local meta = build_mapping_meta(mapping)
    local component_id = meta.component
    if type(component_id) == "function" then
      component_id = component_id(device, mapping, context)
    end

    if type(component_id) == "string" and component_id ~= "" then
      return component_id
    end

    return nil
  end

  local function build_mapping_context(device, mapping, context, value)
    local mapping_context = {
      mapping = mapping,
      value = value,
    }

    if type(context) == "table" then
      for key, item in pairs(context) do
        mapping_context[key] = item
      end
    end

    if mapping_context.cluster_id == nil and type(mapping) == "table" then
      mapping_context.cluster_id = mapping.cluster_id
    end

    if mapping_context.attribute_id == nil and type(mapping) == "table" then
      mapping_context.attribute_id = mapping.attribute_id
    end

    local endpoint = resolve_mapping_endpoint(device, mapping, mapping_context)
    if endpoint == nil then
      endpoint = resolve_context_endpoint(device, mapping_context)
    end

    local component_id = resolve_mapping_component_id(device, mapping, mapping_context)
    if component_id == nil then
      if endpoint ~= nil and type(device.get_component_id_for_endpoint) == "function" then
        component_id = device:get_component_id_for_endpoint(endpoint)
      else
        component_id = resolve_context_component_id(device, mapping_context)
      end
    end

    mapping_context.endpoint = endpoint
    mapping_context.component_id = component_id
    mapping_context.component = component_id and device.profile and device.profile.components and device.profile.components[component_id] or nil

    return mapping_context
  end

  local function mapping_match_score(mapping, device, context)
    if type(mapping) ~= "table" or device == nil then
      return 0
    end

    local expected_endpoint = resolve_mapping_endpoint(device, mapping, context)
    local expected_component_id = resolve_mapping_component_id(device, mapping, context)
    local expected_mfg_code = build_mapping_meta(mapping).mfg_code
    local actual_endpoint = resolve_context_endpoint(device, context)
    local actual_component_id = resolve_context_component_id(device, context)
    local actual_mfg_code = type(context) == "table" and context.mfg_code or nil

    if actual_endpoint == nil and actual_component_id ~= nil then
      actual_endpoint = resolve_context_endpoint(device, { component_id = actual_component_id })
    end

    if actual_component_id == nil and actual_endpoint ~= nil and type(device.get_component_id_for_endpoint) == "function" then
      actual_component_id = device:get_component_id_for_endpoint(actual_endpoint)
    end

    if expected_endpoint ~= nil and actual_endpoint ~= expected_endpoint then
      return -1
    end

    if expected_component_id ~= nil and actual_component_id ~= expected_component_id then
      return -1
    end

    local strict_mfg_match = type(context) == "table" and (
      context.mfg_code ~= nil or
      context.zb_rx ~= nil or
      context.command_id ~= nil
    )

    if strict_mfg_match and expected_mfg_code ~= nil and actual_mfg_code ~= expected_mfg_code then
      return -1
    end

    local score = 0
    if expected_endpoint ~= nil then
      score = score + 2
    end
    if expected_component_id ~= nil then
      score = score + 1
    end
    if strict_mfg_match and expected_mfg_code ~= nil then
      score = score + 4
    end

    return score
  end

  local function is_mapping_bucket(candidate)
    return type(candidate) == "table" and candidate[MAPPING_BUCKET_TAG] == true
  end

  local function add_index_entry(index, key, mapping)
    local current = index[key]
    if current == nil then
      index[key] = mapping
      return
    end

    if is_mapping_bucket(current) then
      current[#current + 1] = mapping
      return
    end

    index[key] = {
      [MAPPING_BUCKET_TAG] = true,
      current,
      mapping,
    }
  end

  local function select_mapping_entry(candidate, device, context)
    if candidate == nil then
      return nil
    end

    if not is_mapping_bucket(candidate) then
      if device == nil or mapping_match_score(candidate, device, context) >= 0 then
        return candidate
      end
      return nil
    end

    if device == nil then
      return candidate[1]
    end

    local selected = nil
    local selected_score = -1

    for _, mapping in ipairs(candidate) do
      local score = mapping_match_score(mapping, device, context)
      if score > selected_score then
        selected = mapping
        selected_score = score
      end
    end

    return selected
  end

  local function collect_matching_entries(candidate, device, context)
    if candidate == nil then
      return {}
    end

    if not is_mapping_bucket(candidate) then
      if device == nil or mapping_match_score(candidate, device, context) >= 0 then
        return { candidate }
      end

      return {}
    end

    local selected = {}
    local selected_score = nil
    for _, mapping in ipairs(candidate) do
      local score = device == nil and 0 or mapping_match_score(mapping, device, context)
      if score >= 0 then
        if selected_score == nil or score > selected_score then
          selected = { mapping }
          selected_score = score
        elseif score == selected_score then
          selected[#selected + 1] = mapping
        end
      end
    end

    return selected
  end

  local function build_mapping_index(zcl_clusters)
    if zcl_clusters == nil then
      return nil
    end

    local cached = index_cache[zcl_clusters]
    if cached ~= nil then
      return cached
    end

    local by_cluster_attribute = {}
    local by_name = {}
    local cluster_ids = {}
    local seen_clusters = {}

    for _, mapping in ipairs(zcl_clusters) do
      if type(mapping) == "table" then
        local cluster_id = mapping.cluster_id
        local attribute_id = mapping.attribute_id

        if cluster_id ~= nil and attribute_id ~= nil then
          by_cluster_attribute[cluster_id] = by_cluster_attribute[cluster_id] or {}
          add_index_entry(by_cluster_attribute[cluster_id], attribute_id, mapping)

          if not seen_clusters[cluster_id] then
            seen_clusters[cluster_id] = true
            cluster_ids[#cluster_ids + 1] = cluster_id
          end
        end

        if mapping.name ~= nil then
          add_index_entry(by_name, mapping.name, mapping)
        end
      end
    end

    local index = {
      by_cluster_attribute = by_cluster_attribute,
      by_name = by_name,
      cluster_ids = cluster_ids,
    }

    index_cache[zcl_clusters] = index
    return index
  end

  function zcl.normalize_endpoint(endpoint)
    return normalize_endpoint(endpoint)
  end

  function zcl.mapping_meta(mapping)
    if type(mapping) ~= "table" then
      return nil
    end

    return build_mapping_meta(mapping)
  end

  function zcl.resolve_context_component_id(device, context)
    return resolve_context_component_id(device, context)
  end

  function zcl.resolve_context_endpoint(device, context)
    return resolve_context_endpoint(device, context)
  end

  function zcl.resolve_mapping_endpoint(device, mapping, context)
    return resolve_mapping_endpoint(device, mapping, context)
  end

  function zcl.resolve_mapping_component_id(device, mapping, context)
    return resolve_mapping_component_id(device, mapping, context)
  end

  function zcl.build_mapping_context(device, mapping, context, value)
    return build_mapping_context(device, mapping, context, value)
  end

  function zcl.select_mapping_entry(candidate, device, context)
    return select_mapping_entry(candidate, device, context)
  end

  function zcl.collect_matching_entries(candidate, device, context)
    return collect_matching_entries(candidate, device, context)
  end

  function zcl.build_mapping_index(zcl_clusters)
    return build_mapping_index(zcl_clusters)
  end

  function zcl.prepare_mappings(zcl_clusters)
    if type(zcl_clusters) ~= "table" then
      return zcl_clusters
    end

    if not prepared_mappings[zcl_clusters] then
      prepared_mappings[zcl_clusters] = true
      build_mapping_index(zcl_clusters)
    end

    return zcl_clusters
  end

  function zcl.find_mapping(zcl_clusters, cluster_id, attribute_id, device, context)
    local index = build_mapping_index(zcl_clusters)
    if index == nil then
      return nil
    end

    local cluster_index = index.by_cluster_attribute[cluster_id]
    if cluster_index == nil then
      return nil
    end

    return select_mapping_entry(cluster_index[attribute_id], device, context)
  end

  function zcl.find_mappings(zcl_clusters, cluster_id, attribute_id, device, context)
    local index = build_mapping_index(zcl_clusters)
    if index == nil then
      return {}
    end

    local cluster_index = index.by_cluster_attribute[cluster_id]
    if cluster_index == nil then
      return {}
    end

    return collect_matching_entries(cluster_index[attribute_id], device, context)
  end

  function zcl.find_mapping_by_name(zcl_clusters, name, device, context)
    if zcl_clusters == nil or name == nil then
      return nil
    end

    local index = build_mapping_index(zcl_clusters)
    if index == nil then
      return nil
    end

    return select_mapping_entry(index.by_name[name], device, context)
  end

  function zcl.has_cluster(zcl_clusters, cluster_id)
    if zcl_clusters == nil then
      return false
    end

    local index = build_mapping_index(zcl_clusters)
    return index ~= nil and index.by_cluster_attribute[cluster_id] ~= nil
  end

  function zcl.get_cluster_ids(zcl_clusters)
    if zcl_clusters == nil then
      return {}
    end

    local index = build_mapping_index(zcl_clusters)
    if index == nil then
      return {}
    end

    local ids = {}
    for _, cluster_id in ipairs(index.cluster_ids) do
      ids[#ids + 1] = cluster_id
    end

    return ids
  end

end

return load_runtime
