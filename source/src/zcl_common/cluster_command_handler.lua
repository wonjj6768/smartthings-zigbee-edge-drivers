-- ZCL cluster command 수신 핸들러
-- 매핑 메타(command_id/command_extractor) 기반 cluster command를 공통 처리합니다.

local function load_cluster_command_handler(zcl)

  local capabilities = require "st.capabilities"
  local custom_capabilities = require "core.custom_capabilities"
  local custom_capability_binding = require "core.custom_capability_binding"
  local battery_refresh = require "app.battery_refresh"
  local generated_clusters = require "st.zigbee.generated.zcl_clusters"
  local Status = require "st.zigbee.generated.types.ZclStatus"
  local data_types = require "st.zigbee.data_types"
  local messages = require "st.zigbee.messages"
  local zcl_messages = require "st.zigbee.zcl"
  local FrameCtrl = require "st.zigbee.zcl.frame_ctrl"
  local default_response = require "st.zigbee.zcl.global_commands.default_response"
  local zigbee_constants = require "st.zigbee.constants"
  local log = require "log"
  local IASACE = generated_clusters.IASACE
  local remote_action_metadata = custom_capabilities.by_emit_name.remote_action
  local security_remote_action_metadata = custom_capabilities.by_emit_name.security_remote_action

  local LAST_REMOTE_ACTION_FIELD = "__zcl_last_remote_action"
  local CLUSTER_SCENES = 0x0005
  local ARM_MODE_ACTIONS = {
    [0] = "disarm",
    [1] = "arm_day_zones",
    [2] = "arm_night_zones",
    [3] = "arm_all_zones",
    [4] = "exit_delay",
  }

  local explicit_handlers = {}
  local mapped_commands = {}
  local send_default_response

  local function extract_source_endpoint(zb_rx)
    if type(zb_rx) ~= "table" then
      return nil
    end

    local endpoint = zb_rx.address_header and
      zb_rx.address_header.src_endpoint and
      zb_rx.address_header.src_endpoint.value or nil

    return zcl.normalize_endpoint(endpoint)
  end

  local function extract_mfg_code(zb_rx)
    if type(zb_rx) ~= "table" then
      return nil
    end

    local zcl_header = zb_rx.body and zb_rx.body.zcl_header or nil
    local frame_ctrl = zcl_header and zcl_header.frame_ctrl or nil
    if frame_ctrl == nil or type(frame_ctrl.is_mfg_specific_set) ~= "function" or not frame_ctrl:is_mfg_specific_set() then
      return nil
    end

    local mfg_code = zcl_header.mfg_code and zcl_header.mfg_code.value or nil
    return type(mfg_code) == "number" and mfg_code or nil
  end

  local function is_single_button_remote(device)
    local model = type(device) == "table" and type(device.get_model) == "function" and device:get_model() or nil
    return model == "TS0041" or model == "TS0041A"
  end

  local function extract_seqno(zb_rx)
    return zb_rx and zb_rx.body and zb_rx.body.zcl_header and zb_rx.body.zcl_header.seqno and zb_rx.body.zcl_header.seqno.value or nil
  end

  local function extract_command_id(zb_rx)
    return zb_rx and zb_rx.body and zb_rx.body.zcl_header and zb_rx.body.zcl_header.cmd and zb_rx.body.zcl_header.cmd.value or nil
  end

  local function extract_body_bytes(zb_rx)
    return zb_rx and zb_rx.body and zb_rx.body.zcl_body and zb_rx.body.zcl_body.body_bytes or nil
  end

  local function supports_component_capability(device, capability_id, component_id)
    return type(device) == "table" and
      type(device.supports_capability_by_id) == "function" and
      device:supports_capability_by_id(capability_id, component_id or "main")
  end

  local function resolve_endpoint_component(device, src_endpoint, fallback_component)
    local component_id = fallback_component or "main"
    if src_endpoint ~= nil and type(device) == "table" and type(device.get_component_id_for_endpoint) == "function" then
      local resolved = device:get_component_id_for_endpoint(src_endpoint)
      if type(resolved) == "string" and resolved ~= "" then
        component_id = resolved
      end
    end
    return component_id
  end

  local function resolve_scene_component(device, preset, scene_index, src_endpoint)
    local scene_component_map = type(preset) == "table" and preset.scene_component_map or nil
    local component_id = type(scene_component_map) == "table" and (scene_component_map[scene_index] or scene_component_map[src_endpoint]) or nil
    if type(component_id) ~= "string" or component_id == "" then
      component_id = resolve_endpoint_component(device, src_endpoint, scene_index == 1 and "main" or ("button" .. tostring(scene_index)))
    end
    return component_id
  end

  local function emit_button_event(device, component_id, action_name)
    local capability_builder = capabilities.button and capabilities.button.button and capabilities.button.button[action_name] or nil
    if type(capability_builder) ~= "function" then
      return false
    end

    local target_component = component_id or "main"
    if not supports_component_capability(device, capabilities.button.ID, target_component) then
      target_component = "main"
    end
    if not supports_component_capability(device, capabilities.button.ID, target_component) then
      return false
    end

    device:emit_component_event({ id = target_component }, capability_builder({ state_change = true }))
    battery_refresh.schedule_after_button(device)
    return true
  end

  local function should_emit_remote_action(device, component_id, action, seqno)
    if type(action) ~= "string" or action == "" then
      return false
    end

    local dedupe_key = table.concat({
      tostring(component_id or "main"),
      tostring(action),
      tostring(seqno or "nil"),
    }, "|")

    local last_key = type(device) == "table" and device:get_field(LAST_REMOTE_ACTION_FIELD) or nil
    if last_key == dedupe_key then
      return false
    end

    device:set_field(LAST_REMOTE_ACTION_FIELD, dedupe_key, { persist = false })
    return true
  end

  local function emit_remote_action(device, component_id, action, seqno)
    if not should_emit_remote_action(device, component_id, action, seqno) then
      return false
    end
    return custom_capability_binding.emit_state(device, component_id, remote_action_metadata, action)
  end

  local function emit_security_remote_action(device, action, seqno)
    if not should_emit_remote_action(device, "main", action, seqno) then
      return false
    end
    return custom_capability_binding.emit_state(device, "main", security_remote_action_metadata, action)
  end

  local function extract_member_value(value)
    if type(value) == "table" and value.value ~= nil then
      return value.value
    end
    return value
  end

  local function extract_body_member(zb_rx, ...)
    local zcl_body = zb_rx and zb_rx.body and zb_rx.body.zcl_body or nil
    if type(zcl_body) ~= "table" then
      return nil
    end

    for _, key in ipairs({ ... }) do
      local candidate = zcl_body[key]
      local numeric = extract_member_value(candidate)
      if numeric ~= nil then
        return numeric
      end
    end

    return nil
  end

  local function handle_advanced_remote_action(device, preset, zb_rx, action, component_id)
    if type(preset) ~= "table" or preset.advanced_remote ~= true or type(action) ~= "string" then
      return false
    end

    emit_remote_action(device, component_id or "main", action, extract_seqno(zb_rx))
    send_default_response(device, zb_rx, extract_command_id(zb_rx) or 0)
    return true
  end

  local function handle_security_remote_action(device, preset, zb_rx, action)
    if type(preset) ~= "table" or preset.security_remote ~= true or type(action) ~= "string" then
      return false
    end

    emit_button_event(device, "main", "pushed")
    emit_security_remote_action(device, action, extract_seqno(zb_rx))
    send_default_response(device, zb_rx, extract_command_id(zb_rx) or 0)
    return true
  end

  local function handle_ias_ace_arm(device, preset, zb_rx)
    if type(preset) ~= "table" or preset.security_remote ~= true then
      return false
    end

    local arm_mode = extract_body_member(zb_rx, "armmode", "arm_mode")
    local action = ARM_MODE_ACTIONS[arm_mode]
    if type(action) ~= "string" then
      return false
    end

    return handle_security_remote_action(device, preset, zb_rx, action)
  end

  local function handle_ias_ace_emergency(device, preset, zb_rx)
    if type(preset) ~= "table" or preset.security_remote ~= true then
      return false
    end

    return handle_security_remote_action(device, preset, zb_rx, "emergency")
  end

  local function resolve_advanced_remote_component(device, preset, zb_rx)
    local src_endpoint = extract_source_endpoint(zb_rx)
    if type(preset) == "table" and preset.knob_remote == true then
      return "main"
    end

    return resolve_endpoint_component(device, src_endpoint, "main")
  end

  local function handle_advanced_remote_standard_command(device, preset, zb_rx)
    if type(preset) ~= "table" or preset.advanced_remote ~= true then
      return false
    end

    local cluster_id = zb_rx and zb_rx.address_header and zb_rx.address_header.cluster and zb_rx.address_header.cluster.value or nil
    local command_id = extract_command_id(zb_rx)
    if type(cluster_id) ~= "number" or type(command_id) ~= "number" then
      return false
    end

    local action = nil
    if cluster_id == zcl.CLUSTER_ON_OFF then
      action = ({
        [0x00] = "off",
        [0x01] = "on",
        [0x02] = "toggle",
      })[command_id]
    elseif cluster_id == zcl.CLUSTER_LEVEL_CONTROL then
      if command_id == 0x00 or command_id == 0x04 then
        action = "brightness_move_to_level"
      elseif command_id == 0x01 or command_id == 0x05 then
        local move_mode = extract_body_member(zb_rx, "move_mode", "movemode", "mode")
        if move_mode == 0 or move_mode == "up" then
          action = "brightness_move_up"
        elseif move_mode == 1 or move_mode == "down" then
          action = "brightness_move_down"
        end
      elseif command_id == 0x02 or command_id == 0x06 then
        local step_mode = extract_body_member(zb_rx, "step_mode", "stepmode", "mode")
        if step_mode == 0 or step_mode == "up" then
          action = "brightness_step_up"
        elseif step_mode == 1 or step_mode == "down" then
          action = "brightness_step_down"
        end
      elseif command_id == 0x03 or command_id == 0x07 then
        action = "brightness_stop"
      end
    elseif cluster_id == zcl.CLUSTER_COLOR_CONTROL then
      if command_id == 0x01 then
        local move_mode = extract_body_member(zb_rx, "move_mode", "movemode", "mode")
        if move_mode == 0 or move_mode == "up" then
          action = "hue_move"
        elseif move_mode == 1 or move_mode == "down" then
          action = "hue_move"
        end
      elseif command_id == 0x47 then
        action = "hue_stop"
      elseif command_id == 0x0A then
        action = "color_temperature_move"
      elseif command_id == 0x4B then
        local move_mode = extract_body_member(zb_rx, "move_mode", "movemode", "mode")
        if move_mode == 1 or move_mode == "down" then
          action = "color_temperature_move_down"
        else
          action = "color_temperature_move_up"
        end
      elseif command_id == 0x4C then
        local step_mode = extract_body_member(zb_rx, "step_mode", "stepmode", "mode")
        if step_mode == 1 or step_mode == "down" then
          action = "color_temperature_step_down"
        else
          action = "color_temperature_step_up"
        end
      end
    elseif cluster_id == CLUSTER_SCENES then
      local scene_id = extract_body_member(zb_rx, "sceneid", "scene_id")
      if command_id == 0x00 then
        action = scene_id ~= nil and ("add_" .. tostring(scene_id)) or "add"
      elseif command_id == 0x02 then
        action = scene_id ~= nil and ("remove_" .. tostring(scene_id)) or "remove"
      elseif command_id == 0x03 then
        action = "remove_all"
      elseif command_id == 0x04 then
        action = scene_id ~= nil and ("store_" .. tostring(scene_id)) or "store"
      elseif command_id == 0x05 then
        action = scene_id ~= nil and ("recall_" .. tostring(scene_id)) or "recall"
      end
    end

    if type(action) ~= "string" then
      return false
    end

    local component_id = resolve_advanced_remote_component(device, preset, zb_rx)
    local src_endpoint = extract_source_endpoint(zb_rx)
    if preset.standard_action_endpoint_suffix == true and src_endpoint ~= nil then
      action = action .. "_" .. tostring(src_endpoint)
    end

    return handle_advanced_remote_action(device, preset, zb_rx, action, component_id)
  end

  local function add_command_registration(registry, cluster_id, command_id)
    if cluster_id == nil or command_id == nil then
      return false
    end

    registry[cluster_id] = registry[cluster_id] or {}
    if registry[cluster_id][command_id] then
      return false
    end

    registry[cluster_id][command_id] = true
    return true
  end

  function send_default_response(device, zb_rx, command_id)
    if type(device) ~= "table" or type(zb_rx) ~= "table" then
      return false
    end

    local zcl_header = zb_rx.body and zb_rx.body.zcl_header or nil
    local frame_ctrl = zcl_header and zcl_header.frame_ctrl or nil
    if frame_ctrl ~= nil and type(frame_ctrl.is_disable_default_response_set) == "function" and frame_ctrl:is_disable_default_response_set() then
      return false
    end

    local cluster_id = zb_rx.address_header and zb_rx.address_header.cluster and zb_rx.address_header.cluster.value or nil
    local src_addr = zb_rx.address_header and zb_rx.address_header.src_addr and zb_rx.address_header.src_addr.value or nil
    local src_endpoint = zb_rx.address_header and zb_rx.address_header.src_endpoint and zb_rx.address_header.src_endpoint.value or nil
    local dst_endpoint = zb_rx.address_header and zb_rx.address_header.dst_endpoint and zb_rx.address_header.dst_endpoint.value or zigbee_constants.HUB.ENDPOINT
    if cluster_id == nil or src_addr == nil or src_endpoint == nil then
      return false
    end

    local response_frame_ctrl = FrameCtrl(0x00)
    if frame_ctrl ~= nil and type(frame_ctrl.get_direction) == "function" and frame_ctrl:get_direction() == 1 then
      response_frame_ctrl:set_direction()
    end
    if frame_ctrl ~= nil and type(frame_ctrl.is_mfg_specific_set) == "function" and frame_ctrl:is_mfg_specific_set() then
      response_frame_ctrl:set_mfg_specific()
    end

    local header = {
      cmd = data_types.ZCLCommandId(default_response.DEFAULT_RESPONSE_ID),
      frame_ctrl = response_frame_ctrl,
      seqno = zcl_header and zcl_header.seqno or nil,
    }
    if zcl_header and zcl_header.mfg_code ~= nil then
      header.mfg_code = zcl_header.mfg_code
    end

    local body = default_response.DefaultResponse(command_id, Status.SUCCESS)

    device:send(messages.ZigbeeMessageTx({
      address_header = messages.AddressHeader(
        zigbee_constants.HUB.ADDR,
        dst_endpoint,
        src_addr,
        src_endpoint,
        zigbee_constants.HA_PROFILE_ID,
        cluster_id
      ),
      body = zcl_messages.ZclMessageBody({
        zcl_header = zcl_messages.ZclHeader(header),
        zcl_body = body,
      }),
    }))

    return true
  end

  local function normalize_extracted_value(extracted)
    if type(extracted) == "table" and (
      extracted.raw_value ~= nil or
      extracted.typed_value ~= nil or
      extracted.attribute_id ~= nil
    ) then
      return extracted
    end

    local raw_value = type(extracted) == "table" and extracted.value or extracted
    return {
      raw_value = raw_value,
      typed_value = extracted,
    }
  end

  local function apply_command_mapping(device, zcl_clusters, cluster_id, command_id, zb_rx)
    local src_endpoint = extract_source_endpoint(zb_rx)
    local mfg_code = extract_mfg_code(zb_rx)
    local pending = {}

    local index = zcl.build_mapping_index(zcl_clusters)
    if index == nil then
      return false
    end

    local cluster_index = index.by_cluster_attribute[cluster_id]
    if cluster_index == nil then
      return false
    end

    local visited = {}
    for _, candidate in pairs(cluster_index) do
      for _, mapping in ipairs(zcl.collect_matching_entries(candidate, device, {
        zb_rx = zb_rx,
        endpoint = src_endpoint,
        src_endpoint = src_endpoint,
        command_id = command_id,
        mfg_code = mfg_code,
      })) do
        if not visited[mapping] then
          visited[mapping] = true

          local meta = zcl.mapping_meta(mapping)
          if meta ~= nil and meta.command_id == command_id and meta.command_extractor ~= nil then
            local extracted = normalize_extracted_value(meta.command_extractor(zb_rx, device, mapping))
            local target_attribute_id = extracted.attribute_id or mapping.attribute_id

            if target_attribute_id ~= nil and pending[target_attribute_id] == nil then
              pending[target_attribute_id] = extracted
            end
          end
        end
      end
    end

    local applied = false
    for attribute_id, extracted in pairs(pending) do
      if zcl.apply_attribute(device, zcl_clusters, cluster_id, attribute_id, extracted.raw_value, {
        zb_rx = zb_rx,
        endpoint = src_endpoint,
        src_endpoint = src_endpoint,
        command_id = command_id,
        mfg_code = mfg_code,
        typed_value = extracted.typed_value,
      }) then
        applied = true
      end
    end

    return applied
  end

  function zcl.register_cluster_command_handler(cluster_id, command_id, handler)
    if cluster_id == nil or command_id == nil or type(handler) ~= "function" then
      log.warn(string.format(
        "skip invalid zcl cluster command handler registration cluster=%s command=%s handler=%s",
        tostring(cluster_id),
        tostring(command_id),
        type(handler)
      ))
      return nil
    end

    explicit_handlers[cluster_id] = explicit_handlers[cluster_id] or {}
    explicit_handlers[cluster_id][command_id] = handler
    return handler
  end

  function zcl.register_cluster_commands_from_mappings(zcl_clusters)
    if type(zcl_clusters) ~= "table" then
      return zcl_clusters
    end

    for _, mapping in ipairs(zcl_clusters) do
      if type(mapping) == "table" then
        local meta = zcl.mapping_meta(mapping)
        if meta ~= nil and meta.cluster_id ~= nil and meta.command_id ~= nil and meta.command_extractor ~= nil then
          add_command_registration(mapped_commands, meta.cluster_id, meta.command_id)
        end
      end
    end

    return zcl_clusters
  end

  function zcl.build_zigbee_cluster_handlers(get_preset)
    local cluster_handlers = {}

    for cluster_id, command_map in pairs(mapped_commands) do
      cluster_handlers[cluster_id] = cluster_handlers[cluster_id] or {}

      for command_id, _ in pairs(command_map) do
        cluster_handlers[cluster_id][command_id] = function(_, device, zb_rx)
          local preset = get_preset(device)
          if preset == nil or preset.zcl_clusters == nil then
            return
          end

          apply_command_mapping(device, preset.zcl_clusters, cluster_id, command_id, zb_rx)
        end
      end
    end

    for cluster_id, command_handlers in pairs(explicit_handlers) do
      cluster_handlers[cluster_id] = cluster_handlers[cluster_id] or {}

      for command_id, handler in pairs(command_handlers) do
        cluster_handlers[cluster_id][command_id] = function(_, device, zb_rx)
          local preset = get_preset(device)
          if preset == nil or preset.zcl_clusters == nil then
            return
          end

          handler(device, preset, zb_rx)
        end
      end
    end

    return cluster_handlers
  end

  function zcl.build_zigbee_global_handlers(get_preset)
    return {
      [zcl.CLUSTER_ON_OFF] = {
        [default_response.DEFAULT_RESPONSE_ID] = function(_, device, zb_rx)
          local preset = get_preset(device)
          if preset == nil or preset.zcl_clusters == nil or not zcl.has_cluster(preset.zcl_clusters, zcl.CLUSTER_ON_OFF) then
            return
          end

          local zcl_body = zb_rx and zb_rx.body and zb_rx.body.zcl_body or nil
          local status = zcl_body and zcl_body.status and zcl_body.status.value or nil
          if status ~= Status.SUCCESS then
            return
          end
        end,
      },
    }
  end

  zcl.register_cluster_command_handler(zcl.CLUSTER_IAS_ZONE, 0x01, function(device, preset, zb_rx)
    local zcl_clusters = preset and preset.zcl_clusters or nil
    if not zcl.has_cluster(zcl_clusters, zcl.CLUSTER_IAS_ZONE) then
      return
    end

    local src_endpoint = extract_source_endpoint(zb_rx)
    if src_endpoint == nil then
      return
    end

    local zone_enroll_response = generated_clusters.IASZone.server.commands.ZoneEnrollResponse(
      device,
      generated_clusters.IASZone.types.EnrollResponseCode(0x00),
      0x00
    )

    device:send(zone_enroll_response:to_endpoint(src_endpoint))
  end)

  local function handle_tuya_on_off_action(device, preset, zb_rx)
    local zcl_body = zb_rx and zb_rx.body and zb_rx.body.zcl_body or nil
    local raw_value = nil
    local src_endpoint = extract_source_endpoint(zb_rx)
    local seqno = extract_seqno(zb_rx)
    local command_id = extract_command_id(zb_rx) or 0xFD

    if type(zcl_body) == "table" then
      if zcl_body.value ~= nil then
        raw_value = zcl_body.value.value or zcl_body.value
      elseif type(zcl_body.body_bytes) == "string" and #zcl_body.body_bytes >= 1 then
        raw_value = string.byte(zcl_body.body_bytes, 1)
      end
    end

    if type(preset) == "table" and preset.scene_switch == true then
      local scene_key = type(preset.scene_action_map) == "table" and (preset.scene_action_map[src_endpoint] or preset.scene_action_map[raw_value]) or src_endpoint or raw_value
      if scene_key ~= nil then
        local action_name_map = type(preset.scene_action_name_map) == "table" and preset.scene_action_name_map or nil
        local action = type(action_name_map) == "table" and action_name_map[scene_key] or nil
        if type(action) ~= "string" or action == "" then
          action = "scene_" .. tostring(scene_key)
        end

        local component_id = resolve_scene_component(device, preset, scene_key, src_endpoint)
        emit_button_event(device, component_id, "pushed")
        emit_remote_action(device, component_id, action, seqno)
      end

      send_default_response(device, zb_rx, command_id)
      return
    end

    if type(preset) == "table" and preset.advanced_remote == true then
      local mapped_action = type(preset.tuya_action_map) == "table" and preset.tuya_action_map[raw_value] or nil
      if type(mapped_action) ~= "string" and type(preset.tuya_action_name) == "string" then
        mapped_action = preset.tuya_action_name
      end
      if type(mapped_action) == "string" then
        local mapped_component = type(preset.tuya_action_components) == "table" and preset.tuya_action_components[raw_value] or nil
        local component_id = type(mapped_component) == "string" and mapped_component or resolve_endpoint_component(device, src_endpoint, "main")
        local button_event = type(preset.tuya_action_button_events) == "table" and preset.tuya_action_button_events[raw_value] or nil
        if type(button_event) == "string" then
          emit_button_event(device, component_id, button_event)
        end
        emit_remote_action(device, component_id, mapped_action, seqno)
        send_default_response(device, zb_rx, command_id)
        return
      end

      local base_action_map = command_id == 0xFC and {
        [0] = "rotate_right",
        [1] = "rotate_left",
      } or {
        [0] = "single",
        [1] = "double",
        [2] = "hold",
      }
      local base_action = base_action_map[raw_value]
      if base_action ~= nil then
        local component_id = resolve_endpoint_component(device, src_endpoint, "main")
        if preset.knob_remote == true then
          emit_remote_action(device, "main", base_action, seqno)
          if base_action == "single" or base_action == "double" or base_action == "hold" then
            local button_event = ({
              single = "pushed",
              double = "double",
              hold = "held",
            })[base_action]
            if button_event ~= nil then
              emit_button_event(device, component_id, button_event)
            end
          end
        else
          local button_index = type(preset.button_count) == "number" and src_endpoint or src_endpoint
          local action = base_action
          if preset.unprefixed_remote_actions ~= true then
            action = button_index ~= nil and (tostring(button_index) .. "_" .. base_action) or base_action
          end
          local button_event = ({
            single = "pushed",
            double = "double",
            hold = "held",
          })[base_action]
          if button_event ~= nil then
            emit_button_event(device, component_id, button_event)
          end
          emit_remote_action(device, component_id, action, seqno)
        end
      end

      send_default_response(device, zb_rx, command_id)
      return
    end

    local button_event = ({
      [0] = capabilities.button.button.pushed({ state_change = true }),
      [1] = capabilities.button.button.double({ state_change = true }),
      [2] = capabilities.button.button.held({ state_change = true }),
    })[raw_value]

    if button_event == nil then
      return
    end

    local component_id = "main"
    if not is_single_button_remote(device) and src_endpoint ~= nil and type(device.get_component_id_for_endpoint) == "function" then
      local resolved = device:get_component_id_for_endpoint(src_endpoint)
      if type(resolved) == "string" and resolved ~= "" then
        component_id = resolved
      end
    end

    if type(device.supports_capability_by_id) == "function" and not device:supports_capability_by_id(capabilities.button.ID, component_id) then
      component_id = "main"
    end

    device:emit_component_event({ id = component_id }, button_event)
    battery_refresh.schedule_after_button(device)
    send_default_response(device, zb_rx, command_id)
  end

  zcl.register_cluster_command_handler(zcl.CLUSTER_ON_OFF, 0xFD, function(device, preset, zb_rx)
    handle_tuya_on_off_action(device, preset, zb_rx)
  end)

  zcl.register_cluster_command_handler(zcl.CLUSTER_ON_OFF, 0xFC, function(device, preset, zb_rx)
    handle_tuya_on_off_action(device, preset, zb_rx)
  end)

  zcl.register_cluster_command_handler(zcl.CLUSTER_ON_OFF, 0x00, function(device, preset, zb_rx)
    handle_advanced_remote_standard_command(device, preset, zb_rx)
  end)

  zcl.register_cluster_command_handler(zcl.CLUSTER_ON_OFF, 0x01, function(device, preset, zb_rx)
    handle_advanced_remote_standard_command(device, preset, zb_rx)
  end)

  zcl.register_cluster_command_handler(zcl.CLUSTER_ON_OFF, 0x02, function(device, preset, zb_rx)
    handle_advanced_remote_standard_command(device, preset, zb_rx)
  end)

  for _, command_id in ipairs({ 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07 }) do
    zcl.register_cluster_command_handler(zcl.CLUSTER_LEVEL_CONTROL, command_id, function(device, preset, zb_rx)
      handle_advanced_remote_standard_command(device, preset, zb_rx)
    end)
  end

  zcl.register_cluster_command_handler(zcl.CLUSTER_COLOR_CONTROL, 0x01, function(device, preset, zb_rx)
    handle_advanced_remote_standard_command(device, preset, zb_rx)
  end)

  zcl.register_cluster_command_handler(zcl.CLUSTER_COLOR_CONTROL, 0x47, function(device, preset, zb_rx)
    handle_advanced_remote_standard_command(device, preset, zb_rx)
  end)

  zcl.register_cluster_command_handler(zcl.CLUSTER_COLOR_CONTROL, 0x0A, function(device, preset, zb_rx)
    handle_advanced_remote_standard_command(device, preset, zb_rx)
  end)

  zcl.register_cluster_command_handler(zcl.CLUSTER_COLOR_CONTROL, 0x4B, function(device, preset, zb_rx)
    handle_advanced_remote_standard_command(device, preset, zb_rx)
  end)

  zcl.register_cluster_command_handler(zcl.CLUSTER_COLOR_CONTROL, 0x4C, function(device, preset, zb_rx)
    handle_advanced_remote_standard_command(device, preset, zb_rx)
  end)

  for _, command_id in ipairs({ 0x00, 0x02, 0x03, 0x04, 0x05 }) do
    zcl.register_cluster_command_handler(CLUSTER_SCENES, command_id, function(device, preset, zb_rx)
      handle_advanced_remote_standard_command(device, preset, zb_rx)
    end)
  end

  zcl.register_cluster_command_handler(IASACE.ID, 0x00, function(device, preset, zb_rx)
    handle_ias_ace_arm(device, preset, zb_rx)
  end)

  zcl.register_cluster_command_handler(IASACE.ID, 0x02, function(device, preset, zb_rx)
    handle_ias_ace_emergency(device, preset, zb_rx)
  end)

  zcl.register_cluster_command_handler(IASACE.ID, 0x04, function(device, preset, zb_rx)
    handle_ias_ace_emergency(device, preset, zb_rx)
  end)

  for _, command_id in ipairs({ 0x00, 0x02, 0x03, 0x04, 0x05 }) do
    zcl.register_cluster_command_handler(0xED00, command_id, function(device, preset, zb_rx)
      if type(preset) ~= "table" or preset.ir_controller ~= true or zcl.handle_ir_transmit_command == nil then
        return
      end

      zcl.handle_ir_transmit_command(device, preset, zb_rx)
    end)
  end

end

return load_cluster_command_handler
