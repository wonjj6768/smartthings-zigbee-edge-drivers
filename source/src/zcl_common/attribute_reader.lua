-- ZCL attribute read transport.
--
-- This module is deliberately independent from command_sender. Receive-only
-- packages need initial/configuration reads, but must not carry any writable
-- command registry that can be restored by requiring another module.

local function load_attribute_reader(zcl)
  local cluster_base = require "st.zigbee.cluster_base"
  local data_types = require "st.zigbee.data_types"

  local function send_request(device, request, endpoint, profile_id)
    if endpoint ~= nil and type(request.to_endpoint) == "function" then
      request = request:to_endpoint(endpoint)
    end
    if profile_id ~= nil and request.address_header and request.address_header.profile then
      request.address_header.profile.value = profile_id
    end
    device:send(request)
    return true
  end

  local function read_manufacturer_specific_attribute(device, cluster_id, attribute_id, mfg_code, endpoint, profile_id)
    return send_request(
      device,
      cluster_base.read_manufacturer_specific_attribute(
        device,
        cluster_id,
        attribute_id,
        mfg_code
      ),
      endpoint,
      profile_id
    )
  end

  local function read_generated_attribute(device, attribute_def, endpoint)
    return send_request(device, attribute_def:read(device), endpoint)
  end

  local function read_plain_attribute(device, cluster_id, attribute_id, endpoint)
    return send_request(
      device,
      cluster_base.read_attribute(device, data_types.ClusterId(cluster_id), data_types.AttributeId(attribute_id)),
      endpoint
    )
  end

  local function build_or_reuse_mapping_context(device, mapping, context, value)
    if type(context) == "table" and context.mapping == mapping then
      return context
    end

    return zcl.build_mapping_context(device, mapping, context, value)
  end

  local function read_mapping_attribute(device, mapping, context)
    local meta = zcl.mapping_meta(mapping)
    if meta == nil or meta.cluster_id == nil or meta.attribute_id == nil then
      return false
    end

    local mapping_context = build_or_reuse_mapping_context(device, mapping, context, nil)

    if meta.mfg_code ~= nil then
      return read_manufacturer_specific_attribute(
        device,
        meta.cluster_id,
        meta.attribute_id,
        meta.mfg_code,
        mapping_context.endpoint,
        meta.profile_id
      )
    end

    if meta.attribute_def ~= nil and type(meta.attribute_def.read) == "function" then
      return read_generated_attribute(device, meta.attribute_def, mapping_context.endpoint)
    end

    return read_plain_attribute(device, meta.cluster_id, meta.attribute_id, mapping_context.endpoint)
  end

  --- Read a specific cluster attribute.
  ---@param device table SmartThings device object
  ---@param cluster_id number cluster ID
  ---@param attribute_id number attribute ID
  ---@param endpoint number|nil target endpoint
  ---@param mfg_code number|nil manufacturer code
  function zcl.read_attribute(device, cluster_id, attribute_id, endpoint, mfg_code)
    if mfg_code ~= nil then
      return read_manufacturer_specific_attribute(device, cluster_id, attribute_id, mfg_code, endpoint)
    end

    local attribute_def = zcl.get_generated_attribute and zcl.get_generated_attribute(cluster_id, attribute_id) or nil
    if attribute_def ~= nil then
      return read_generated_attribute(device, attribute_def, endpoint)
    end

    return read_plain_attribute(device, cluster_id, attribute_id, endpoint)
  end

  function zcl.read_mapping(device, mapping, context)
    return read_mapping_attribute(device, mapping, context)
  end

  function zcl.read_named_attribute(device, zcl_clusters, name, context)
    local mapping = zcl.find_mapping_by_name(zcl_clusters, name, device, context)
    if mapping == nil then
      return false
    end

    local meta = zcl.mapping_meta(mapping)
    if meta == nil or meta.write_only then
      return false
    end

    return read_mapping_attribute(device, mapping, zcl.build_mapping_context(device, mapping, context, nil))
  end

  --- Read every readable attribute declared by zcl_clusters.
  ---@param device table SmartThings device object
  ---@param zcl_clusters table ZCL mapping list
  function zcl.read_all_attributes(device, zcl_clusters)
    if zcl_clusters == nil then
      return
    end

    local seen = {}

    for _, mapping in ipairs(zcl_clusters) do
      local meta = type(mapping) == "table" and zcl.mapping_meta(mapping) or nil
      if meta ~= nil and not meta.write_only and meta.cluster_id ~= nil and meta.attribute_id ~= nil then
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
          read_mapping_attribute(device, mapping, mapping_context)
        end
      end
    end
  end

  -- command_sender reuses the same endpoint-aware transport after installing
  -- these read-only exports. The helper itself is not added to the public table.
  return send_request, build_or_reuse_mapping_context
end

return load_attribute_reader
