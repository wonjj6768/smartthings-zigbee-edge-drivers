-- ZCL component/endpoint authoring helper
-- 멀티채널 기기 정의 반복을 줄이기 위한 유틸입니다.

local function load_component_helper(zcl)

  local function copy_table(source)
    local copied = {}
    if type(source) ~= "table" then
      return copied
    end

    for key, value in pairs(source) do
      copied[key] = value
    end

    return copied
  end

  local function normalize_endpoints(endpoints_or_count)
    if type(endpoints_or_count) == "number" and endpoints_or_count % 1 == 0 and endpoints_or_count > 0 then
      local endpoints = {}
      for endpoint = 1, endpoints_or_count do
        endpoints[#endpoints + 1] = endpoint
      end
      return endpoints
    end

    if type(endpoints_or_count) == "table" then
      local endpoints = {}
      for _, endpoint in ipairs(endpoints_or_count) do
        if type(endpoint) == "number" and endpoint % 1 == 0 and endpoint > 0 then
          endpoints[#endpoints + 1] = endpoint
        end
      end
      return endpoints
    end

    return { 1 }
  end

  function zcl.build_component_by_endpoint(endpoint_map, default_component)
    return function(_, _, context)
      local endpoint = context and (context.endpoint or context.src_endpoint) or nil
      if type(endpoint_map) ~= "table" or endpoint == nil then
        return default_component
      end

      local component = endpoint_map[endpoint]
      if type(component) == "string" and component ~= "" then
        return component
      end

      return default_component
    end
  end

  function zcl.build_component_suffix(prefix, options)
    options = options or {}

    local component_prefix = type(prefix) == "string" and prefix ~= "" and prefix or "switch"
    local main_endpoint = type(options.main_endpoint) == "number" and options.main_endpoint or 1
    local main_component = type(options.main_component) == "string" and options.main_component ~= "" and options.main_component or "main"
    local default_component = options.default_component
    local index_offset = type(options.index_offset) == "number" and options.index_offset or 0

    return function(_, _, context)
      local endpoint = context and (context.endpoint or context.src_endpoint) or nil
      if type(endpoint) ~= "number" then
        return default_component
      end

      if endpoint == main_endpoint then
        return main_component
      end

      local suffix = endpoint - main_endpoint + index_offset
      if suffix < 1 then
        return default_component
      end

      return component_prefix .. tostring(suffix)
    end
  end

  local function build_multichannel(factory, endpoints_or_count, options)
    local endpoints = normalize_endpoints(endpoints_or_count)
    local base_options = copy_table(options)
    local component_builder = base_options.component

    if component_builder == nil then
      component_builder = zcl.build_component_suffix(base_options.component_prefix or "switch", base_options)
    end

    base_options.component_prefix = nil
    base_options.main_component = nil
    base_options.main_endpoint = nil
    base_options.default_component = nil
    base_options.index_offset = nil
    base_options.component = nil

    local mappings = {}
    for _, endpoint in ipairs(endpoints) do
      local mapping_options = copy_table(base_options)
      mapping_options.endpoint = endpoint
      mapping_options.component = component_builder
      mappings[#mappings + 1] = factory(mapping_options)
    end

    return mappings
  end

  function zcl.multi_switch(endpoints_or_count, options)
    return build_multichannel(zcl.switch, endpoints_or_count, options)
  end

  function zcl.multi_level(endpoints_or_count, options)
    return build_multichannel(zcl.level, endpoints_or_count, options)
  end

end

return load_component_helper
