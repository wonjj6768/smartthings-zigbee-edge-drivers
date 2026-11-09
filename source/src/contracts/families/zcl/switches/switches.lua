-- 스위치/아웃렛 디바이스 정의

local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local fps = device_helpers.create_fingerprints
local fp = device_helpers.create_fingerprint
local zcl_device_helpers = require "contracts.helpers.zcl"
local device_management = require "st.zigbee.device_management"
local data_types = require "st.zigbee.data_types"
local cluster_base = require "st.zigbee.cluster_base"

local device_definitions, register = device_helpers.definition_registry()

local function bind_on_off_endpoints(endpoint_count)
  return function(driver, device)
    for endpoint = 1, endpoint_count do
      device:send(device_management.build_bind_request(
        device,
        zcl.CLUSTER_ON_OFF,
        driver.environment_info.hub_zigbee_eui,
        endpoint
      ))
    end
  end
end

local function build_switch(profile, count, options)
  if count == 1 then
    return {
      profile = profile,
      zcl_clusters = {
        zcl_device_helpers.switch_cluster(),
      },
    }
  end

  return {
    profile = profile,
    zcl_clusters = zcl.multi_switch(count, options),
  }
end

local append_option_clusters = zcl_device_helpers.append_clusters

local function build_tuya_on_off_switch(profile, count, options)
  local clusters = build_switch(profile, count, options).zcl_clusters
  append_option_clusters(clusters,
    zcl.tuya_magic_packet(),
    zcl.tuya_power_outage_memory(),
    zcl.child_lock()
  )

  return {
    profile = profile,
    zcl_clusters = clusters,
    configure = bind_on_off_endpoints(count),
  }
end

local function build_switch_module(profile, count, options)
  local clusters = build_switch(profile, count, options).zcl_clusters
  append_option_clusters(clusters,
    zcl.tuya_magic_packet(),
    zcl.switch_type(),
    zcl.countdown_timer()
  )

  return {
    profile = profile,
    zcl_clusters = clusters,
    configure = bind_on_off_endpoints(count),
  }
end

local function tuya_power_on_behavior_2()
  return zcl.cluster_attribute(0xE001, 0xD010, {
    name = "power_on_behavior",
    emit = emit.power_on_behavior(),
    from_device = function(value)
      return ({ [0] = "off", [1] = "on", [2] = "previous" })[value]
    end,
    to_device = function(value)
      return ({ off = 0, on = 1, previous = 2 })[value]
    end,
    data_type = data_types.Enum8,
    write_type = data_types.Enum8,
    read_on_configure = true,
  })
end

local function tuya_enum_mapping(name, cluster_id, attribute_id, emitter, from_values, to_values, options)
  options = options or {}
  return zcl.cluster_attribute(cluster_id, attribute_id, {
    name = name,
    endpoint = options.endpoint,
    component = options.component,
    emit = emitter,
    from_device = function(value)
      if type(value) == "table" then value = value.value end
      return from_values[value]
    end,
    to_device = function(value) return to_values[value] end,
    data_type = options.data_type or data_types.Enum8,
    write_type = options.write_type or options.data_type or data_types.Enum8,
    mfg_code = options.mfg_code,
    read_on_configure = options.read_on_configure ~= false,
  })
end

local function latest_state(device, capability_id, attribute, default)
  return device:get_latest_state("main", capability_id, attribute) or default
end

local NFZB_INCHING = {
  [1] = { enabled_capability = "concertmirror08464.nfzb03InchingControlOne", enabled_attribute = "inchingControlOne", time_capability = "concertmirror08464.nfzb03InchingTimeOne", time_attribute = "inchingTimeOne" },
  [2] = { enabled_capability = "concertmirror08464.nfzb03InchingControlTwo", enabled_attribute = "inchingControlTwo", time_capability = "concertmirror08464.nfzb03InchingTimeTwo", time_attribute = "inchingTimeTwo" },
  [3] = { enabled_capability = "concertmirror08464.nfzb03InchingControlThree", enabled_attribute = "inchingControlThree", time_capability = "concertmirror08464.nfzb03InchingTimeThree", time_attribute = "inchingTimeThree" },
}

local NFZB03_EMITTERS = {
  [1] = {
    countdown = emit.nfzb03CountdownOne(),
    control = emit.nfzb03InchingControlOne(),
    time = emit.nfzb03InchingTimeOne(),
  },
  [2] = {
    countdown = emit.nfzb03CountdownTwo(),
    control = emit.nfzb03InchingControlTwo(),
    time = emit.nfzb03InchingTimeTwo(),
  },
  [3] = {
    countdown = emit.nfzb03CountdownThree(),
    control = emit.nfzb03InchingControlThree(),
    time = emit.nfzb03InchingTimeThree(),
  },
}


local BASE64_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function encode_base64_bytes(bytes)
  local encoded = {}
  for offset = 1, #bytes, 3 do
    local first = bytes[offset]
    local second = bytes[offset + 1]
    local third = bytes[offset + 2]
    local first_index = math.floor(first / 4)
    local second_index = ((first % 4) * 16) + math.floor((second or 0) / 16)
    local third_index = (((second or 0) % 16) * 4) + math.floor((third or 0) / 64)
    local fourth_index = (third or 0) % 64
    encoded[#encoded + 1] = BASE64_ALPHABET:sub(first_index + 1, first_index + 1)
    encoded[#encoded + 1] = BASE64_ALPHABET:sub(second_index + 1, second_index + 1)
    encoded[#encoded + 1] = second and BASE64_ALPHABET:sub(third_index + 1, third_index + 1) or "="
    encoded[#encoded + 1] = third and BASE64_ALPHABET:sub(fourth_index + 1, fourth_index + 1) or "="
  end
  return table.concat(encoded)
end

local function encode_inching_block(state, seconds_high, seconds_low)
  return encode_base64_bytes({ state, seconds_high, seconds_low })
end

local function base64_value(character)
  local offset = BASE64_ALPHABET:find(character, 1, true)
  return offset and (offset - 1) or nil
end

local function decode_base64_chunk(chunk)
  if type(chunk) ~= "string" or #chunk ~= 4 then return nil end
  local first = base64_value(chunk:sub(1, 1))
  local second = base64_value(chunk:sub(2, 2))
  local third_char = chunk:sub(3, 3)
  local fourth_char = chunk:sub(4, 4)
  local third = third_char == "=" and 0 or base64_value(third_char)
  local fourth = fourth_char == "=" and 0 or base64_value(fourth_char)
  if first == nil or second == nil or third == nil or fourth == nil then return nil end
  local bytes = {
    (first * 4) + math.floor(second / 16),
  }
  if third_char ~= "=" then
    bytes[#bytes + 1] = ((second % 16) * 16) + math.floor(third / 4)
  end
  if fourth_char ~= "=" then
    bytes[#bytes + 1] = ((third % 4) * 64) + fourth
  end
  return bytes
end

local function decode_inching_blocks(value)
  if type(value) ~= "string" or (#value % 4) ~= 0 then
    return nil
  end

  local decoded = {}
  for offset = 1, #value, 4 do
    local bytes = decode_base64_chunk(value:sub(offset, offset + 3))
    if bytes == nil or #bytes ~= 3 then return nil end
    local state = bytes[1]
    local channel = 1
    local channel_bits = state
    while channel_bits >= 2 do
      channel = channel + 1
      channel_bits = math.floor(channel_bits / 2)
    end
    decoded[channel] = {
      enabled = state % 2 == 1 and "enabled" or "disabled",
      time = (bytes[2] * 256) + bytes[3],
    }
  end
  return decoded
end

local function nfzb_inching_from_device(value, _device, _mapping_context, mapping)
  local decoded = decode_inching_blocks(value)
  local channel = decoded and decoded[mapping.inching_channel] or nil
  if channel == nil then return nil end
  if mapping.inching_kind == "enabled" and mapping.inching_enabled_values ~= nil then
    return channel.enabled == "enabled" and mapping.inching_enabled_values.enabled or
      mapping.inching_enabled_values.disabled
  end
  return channel[mapping.inching_kind]
end

local function nfzb_inching_sender(device, mapping, value)
  local channel = mapping.inching_channel
  local contract = mapping.inching_contract or NFZB_INCHING[channel]
  local disabled_value = mapping.inching_enabled_values and mapping.inching_enabled_values.disabled or "disabled"
  local enabled = latest_state(device, contract.enabled_capability, contract.enabled_attribute, disabled_value)
  local seconds = tonumber(latest_state(device, contract.time_capability, contract.time_attribute, 1)) or 1
  if mapping.inching_kind == "enabled" then enabled = value end
  if mapping.inching_kind == "time" then seconds = tonumber(value) or seconds end
  seconds = math.max(1, math.min(65535, math.floor(seconds + 0.5)))
  local enabled_value = mapping.inching_enabled_values and mapping.inching_enabled_values.enabled or "enabled"
  local state = enabled == enabled_value and 1 or 0
  if channel > 1 then state = state + (2 ^ (channel - 1)) end
  local seconds_high = math.floor(seconds / 256)
  local seconds_low = seconds % 256
  return zcl.send_raw_cluster_command(
    device,
    0xE000,
    0xFB,
    encode_inching_block(state, seconds_high, seconds_low),
    1
  )
end

local function nfzb_inching_mapping(channel, kind, emitter, options)
  options = options or {}
  local names = {
    enabled = (options.name_prefix or "nfzb03") .. "_inching_enabled_" .. ({ "one", "two", "three" })[channel],
    time = (options.name_prefix or "nfzb03") .. "_inching_time_" .. ({ "one", "two", "three" })[channel],
  }
  local mapping = zcl.cluster_attribute(0xE000, 0xD003, {
    name = names[kind],
    emit = emitter,
    from_device = nfzb_inching_from_device,
    data_type = data_types.CharString,
    read_on_configure = false,
    sender = nfzb_inching_sender,
  })
  mapping.inching_channel = channel
  mapping.inching_kind = kind
  mapping.inching_contract = options.contracts and options.contracts[channel] or nil
  mapping.inching_enabled_values = options.enabled_values
  return mapping
end

local lellki_wp33_power_on_behavior_emit = emit.lellkiWp33PowerOnBehavior()

local function lellki_wp33_power_on_behavior()
  local mapping = tuya_power_on_behavior_2()
  mapping.name = "lellki_wp33_power_on_behavior"
  mapping.emit = lellki_wp33_power_on_behavior_emit
  return mapping
end

local function build_tuya_single_switch_options(profile, options)
  options = options or {}
  local clusters = build_switch("switches-switch-1", 1).zcl_clusters
  append_option_clusters(clusters, zcl.tuya_magic_packet())
  if options.power_outage_memory then append_option_clusters(clusters, zcl.tuya_power_outage_memory()) end
  if options.power_on_behavior_2 then append_option_clusters(clusters, tuya_power_on_behavior_2()) end
  if options.switch_type then append_option_clusters(clusters, zcl.switch_type()) end
  if options.gen_on_off_switch_type then append_option_clusters(clusters, zcl.gen_on_off_switch_type()) end
  if options.countdown then append_option_clusters(clusters, zcl.countdown_timer()) end
  if options.indicator_mode then append_option_clusters(clusters, zcl.indicator_mode()) end

  return {
    profile = profile,
    zcl_clusters = clusters,
    configure = bind_on_off_endpoints(1),
  }
end

local function build_single_power_switch(profile, include_switch_type)
  local clusters = zcl_device_helpers.metering_clusters({
    include_switch = true,
    include_current = true,
    energy_scale = 100,
  })
  append_option_clusters(clusters,
    zcl.power_outage_memory(),
    zcl.tuya_magic_packet()
  )
  if include_switch_type ~= false then append_option_clusters(clusters, zcl.switch_type()) end

  return {
    profile = profile,
    zcl_clusters = clusters,
    configure = function(driver, device)
      for _, cluster_id in ipairs({ zcl.CLUSTER_ON_OFF, 0x0B04, 0x0702 }) do
        device:send(device_management.build_bind_request(
          device,
          cluster_id,
          driver.environment_info.hub_zigbee_eui,
          1
        ))
      end
    end,
  }
end

local function build_relay_switch(profile, count)
  local clusters = build_switch(profile, count).zcl_clusters
  append_option_clusters(clusters,
    zcl.tuya_magic_packet(),
    zcl.power_outage_memory(),
    zcl.gen_on_off_switch_type()
  )

  return {
    profile = profile,
    zcl_clusters = clusters,
    configure = bind_on_off_endpoints(count),
  }
end

local function build_dual_power_switch(profile)
  local clusters = {
    zcl_device_helpers.switch_cluster(1),
    zcl_device_helpers.switch_cluster(2, "switch2"),
  }

  append_option_clusters(clusters,
    zcl.power({endpoint=1,component="main",minimum_interval=5,maximum_interval=3600,reportable_change=10,poll_interval=300}),
    zcl.voltage({endpoint=1,component="main",minimum_interval=5,maximum_interval=3600,reportable_change=5,poll_interval=300}),
    zcl.current({endpoint=1,component="main",scale=1000,ignore_reported_scaler=true,minimum_interval=5,maximum_interval=3600,reportable_change=50,poll_interval=300}),
    zcl.energy({endpoint=1,component="main",scale=100,ignore_reported_scaler=true,minimum_interval=5,maximum_interval=3600,reportable_change=257,poll_interval=900}),
    zcl.tuya_magic_packet(),
    zcl.tuya_power_outage_memory({endpoint=1,name="nous_b3z_power_behavior",emit=emit.nousB3zPowerBehavior()}),
    zcl.switch_type({endpoint=1,name="nous_b3z_switch_type",emit=emit.nousB3zSwitchType(),
      sender=function(device,mapping,value)
        local request=cluster_base.write_attribute(device,data_types.ClusterId(0xE001),
          data_types.AttributeId(0xD030),data_types.Enum8(mapping.converter.to(value)))
        request.body.zcl_header.frame_ctrl:set_disable_default_response()
        device:send(request:to_endpoint(1));return true
      end}),
    zcl.countdown_timer({endpoint=1,component="main",name="nous_b3z_countdown1",emit=emit.nousB3zCountdown1()}),
    zcl.countdown_timer({endpoint=2,component="switch2",name="nous_b3z_countdown2",emit=emit.nousB3zCountdown2()})
  )

  return {
    profile = profile,
    zcl_clusters = clusters,
    component_to_endpoint_map = {main=1,switch2=2},
    configure = function(driver,device)
      for _,cluster in ipairs({6,0x0B04,0x0702}) do
        zcl.bind_cluster(device,cluster,driver.environment_info.hub_zigbee_eui,1)
      end
      zcl.bind_cluster(device,6,driver.environment_info.hub_zigbee_eui,2)
    end,
  }
end

local metered_dual_plug = {
  profile = "plugs-switch-2-power-energy-voltage",
  zcl_clusters = {
    zcl_device_helpers.switch_cluster(1),
    zcl_device_helpers.switch_cluster(2, "switch2"),
  },
}

append_option_clusters(metered_dual_plug.zcl_clusters,
  zcl_device_helpers.metering_clusters({
    endpoint = 1,
    include_switch = false,
    include_current = false,
  })
)

local function bind_dual_metered_plug(driver, device)
  for _, cluster_id in ipairs({ zcl.CLUSTER_ON_OFF, 0x0B04, 0x0702 }) do
    device:send(device_management.build_bind_request(
      device,
      cluster_id,
      driver.environment_info.hub_zigbee_eui,
      1
    ))
  end
  device:send(device_management.build_bind_request(
    device,
    zcl.CLUSTER_ON_OFF,
    driver.environment_info.hub_zigbee_eui,
    2
  ))
end

local function build_tuya_dual_metered_plug(profile, options)
  options = options or {}
  local clusters = {
    zcl_device_helpers.switch_cluster(1),
    zcl_device_helpers.switch_cluster(2, "switch2"),
  }
  append_option_clusters(clusters,
    zcl_device_helpers.metering_clusters({
      endpoint = 1,
      include_switch = false,
      include_current = true,
      energy_scale = 100,
      energy_ignore_reported_scaler = options.energy_ignore_reported_scaler,
      use_reported_unity_scaler = options.use_reported_unity_scaler,
    }),
    zcl.tuya_magic_packet()
  )
  if options.outage_memory then append_option_clusters(clusters, zcl.tuya_power_outage_memory()) end
  if options.indicator_mode then append_option_clusters(clusters, zcl.indicator_mode()) end
  if options.child_lock then append_option_clusters(clusters, zcl.child_lock()) end
  if options.countdown then append_option_clusters(clusters, zcl.countdown_timer()) end
  return {
    profile = profile,
    zcl_clusters = clusters,
    configure = bind_dual_metered_plug,
  }
end

local tuya_dual_metered = build_tuya_dual_metered_plug("plugs-dual-metered", {
  use_reported_unity_scaler = true,
})
local tuya_dual_metered_outage = build_tuya_dual_metered_plug("plugs-dual-metered-outage", {
  outage_memory = true,
})
-- Mercator Ikuu SPP02GIP: its reported SimpleMetering multiplier/divisor is
-- bogus, so energy always uses the fixed /100 scale (matches Zigbee2MQTT).
local mercator_spp02gip = build_tuya_dual_metered_plug("plugs-mercator-spp02gip", {
  outage_memory = true,
  energy_ignore_reported_scaler = true,
})
local mercator_spp04g = {
  profile = "plugs-mercator-spp04g",
  component_to_endpoint_map = { main = 1, switch2 = 2 },
  zcl_clusters = {
    zcl.switch({ endpoint = 1, component = "main", maximum_interval = 3600 }),
    zcl.switch({ endpoint = 2, component = "switch2", maximum_interval = 3600 }),
    zcl.power({ endpoint = 1, minimum_interval = 5, maximum_interval = 3600, reportable_change = 1, poll_interval = 300 }),
    zcl.voltage({ endpoint = 1, minimum_interval = 5, maximum_interval = 3600, reportable_change = 5, poll_interval = 300 }),
    zcl.current({ endpoint = 1, scale = 1000, ignore_reported_scaler = true,
      minimum_interval = 5, maximum_interval = 3600, reportable_change = 50, poll_interval = 300 }),
    zcl.energy({ endpoint = 1, scale = 100, ignore_reported_scaler = true, poll_interval = 900 }),
    zcl.tuya_magic_packet(),
    zcl.tuya_power_outage_memory({ endpoint = 1, name = "spp04_power_behavior", emit = emit.spp04PowerBehavior() }),
  },
  configure = bind_dual_metered_plug,
}
local tuya_dual_metered_outage_indicator = build_tuya_dual_metered_plug("plugs-dual-metered-outage-indicator", {
  outage_memory = true,
  indicator_mode = true,
  use_reported_unity_scaler = true,
})
local tuya_dual_metered_outage_indicator_lock = build_tuya_dual_metered_plug("plugs-dual-metered-outage-indicator-lock", {
  outage_memory = true,
  indicator_mode = true,
  child_lock = true,
})
local tuya_dual_metered_full_options = build_tuya_dual_metered_plug("plugs-dual-metered-full-options", {
  outage_memory = true,
  indicator_mode = true,
  child_lock = true,
  countdown = true,
})
local zemismart_dual_outlet = build_switch("plugs-dual-outage", 2)
append_option_clusters(zemismart_dual_outlet.zcl_clusters,
  zcl.tuya_magic_packet(),
  zcl.tuya_power_outage_memory()
)
zemismart_dual_outlet.configure = bind_on_off_endpoints(2)

local single_switch = build_switch("switches-switch-1", 1)
local function is_lumi_model(device, model)
  return device:get_manufacturer() == "LUMI" and device:get_model() == model
end

single_switch.component_to_endpoint = function(device)
  if is_lumi_model(device, "lumi.ctrl_neutral1") then return 2 end
end
single_switch.zcl_clusters[1].endpoint = function(device)
  if is_lumi_model(device, "lumi.ctrl_neutral1") then return 2 end
end
local single_switch_receive = single_switch.zcl_clusters[1].from_device
  or (single_switch.zcl_clusters[1].converter or {}).from
single_switch.zcl_clusters[1].from_device = function(value, device, context, mapping)
  local model = device:get_model()
  if device:get_manufacturer() == "LUMI" and
      (model == "lumi.ctrl_ln1" or model == "lumi.ctrl_ln1.aq1" or model == "lumi.ctrl_neutral1") and
      (context.endpoint == 4 or context.endpoint == 5 or context.endpoint == 6) then
    return nil
  end
  if single_switch_receive then return single_switch_receive(value, device, context, mapping) end
  return value
end
local tuya_single_switch = build_switch("switches-switch-1", 1)
append_option_clusters(tuya_single_switch.zcl_clusters, zcl.tuya_magic_packet())
tuya_single_switch.configure = bind_on_off_endpoints(1)
local single_power_switch = build_single_power_switch("switches-switch-1-power-options")
local single_power_outage_switch = build_single_power_switch("switches-switch-1-power-outage", false)
local bound_dual_switch = build_switch("switches-switch-2", 2)
bound_dual_switch.component_to_endpoint = function(device, component)
  if is_lumi_model(device, "lumi.ctrl_neutral2") then return component == "main" and 2 or 3 end
end
bound_dual_switch.endpoint_to_component = function(device, endpoint)
  if is_lumi_model(device, "lumi.ctrl_neutral2") then
    if endpoint == 2 then return "main" end
    if endpoint == 3 then return "switch2" end
  end
end
for _, mapping in ipairs(bound_dual_switch.zcl_clusters) do
  local endpoint, component = mapping.endpoint, mapping.component
  mapping.reporting_defaults = {
    key = string.format("zr%04x%04x%d", mapping.cluster_id, mapping.attribute_id, endpoint),
    minimum_interval = mapping.minimum_interval,
    maximum_interval = mapping.maximum_interval,
    reportable_change = mapping.reportable_change,
  }
  mapping.endpoint = function(device)
    return is_lumi_model(device, "lumi.ctrl_neutral2") and endpoint + 1 or endpoint
  end
  mapping.component = function(device, current, context)
    if is_lumi_model(device, "lumi.ctrl_neutral2") then return endpoint == 1 and "main" or "switch2" end
    return component(device, current, context)
  end
end
local configure_bound_dual = bind_on_off_endpoints(2)
bound_dual_switch.configure = function(driver, device)
  if not is_lumi_model(device, "lumi.ctrl_neutral2") then return configure_bound_dual(driver, device) end
  for endpoint = 2, 3 do zcl.bind_cluster(device, zcl.CLUSTER_ON_OFF, driver.environment_info.hub_zigbee_eui, endpoint) end
end
-- This profile numbers its second channel switch2, not switch1.
local tuya_dual_switch = build_switch("switches-switch-2", 2, { index_offset = 1 })
tuya_dual_switch.time_start = "off"
append_option_clusters(tuya_dual_switch.zcl_clusters, zcl.tuya_magic_packet())
tuya_dual_switch.configure = bind_on_off_endpoints(2)
local ts0002_rux = build_switch("switches-ts0002-rux", 2, { index_offset = 1 })
append_option_clusters(ts0002_rux.zcl_clusters,
  zcl.tuya_magic_packet(),
  tuya_enum_mapping("ts0002_rux_power_outage_memory", zcl.CLUSTER_ON_OFF, 0x8002,
    emit.ts0002RuxPowerOutageMemory(), { [0] = "off", [1] = "on", [2] = "restore" }, { off = 0, on = 1, restore = 2 }),
  tuya_enum_mapping("ts0002_rux_switch_type", 0xE001, 0xD030,
    emit.ts0002RuxSwitchType(), { [0] = "toggle", [1] = "state", [2] = "momentary" }, { toggle = 0, state = 1, momentary = 2 })
)
ts0002_rux.configure = bind_on_off_endpoints(2)
local dual_power_switch = build_dual_power_switch("switches-nous-b3z")
local bound_triple_switch = build_switch("switches-switch-3", 3, { index_offset = 1 })
bound_triple_switch.configure = bind_on_off_endpoints(3)
local tuya_triple_switch = build_switch("switches-switch-3", 3, { index_offset = 1 })
append_option_clusters(tuya_triple_switch.zcl_clusters, zcl.tuya_magic_packet())
tuya_triple_switch.configure = bind_on_off_endpoints(3)
local quad_switch = build_switch("switches-switch-4", 4, { index_offset = 1 })
quad_switch.configure = bind_on_off_endpoints(4)
local tuya_quad_reporting_switch = build_switch("switches-switch-4", 4, { index_offset = 1 })
append_option_clusters(tuya_quad_reporting_switch.zcl_clusters, zcl.tuya_magic_packet())
tuya_quad_reporting_switch.configure = bind_on_off_endpoints(4)
local tuya_quad_bind_only_switch = {
  profile = "switches-switch-4",
  zcl_clusters = zcl.multi_switch(4, { configure_reporting = false, index_offset = 1 }),
  configure = bind_on_off_endpoints(4),
}
append_option_clusters(tuya_quad_bind_only_switch.zcl_clusters, zcl.tuya_magic_packet())
local tuya_quad_magic_only_switch = {
  profile = "switches-switch-4",
  zcl_clusters = zcl.multi_switch(4, { configure_reporting = false, index_offset = 1 }),
}
append_option_clusters(tuya_quad_magic_only_switch.zcl_clusters, zcl.tuya_magic_packet())
local quint_tuya_switch = build_tuya_on_off_switch("switches-switch-5-tuya-options", 5, { index_offset = 1 })
local lellki_wp33_switch = build_switch("switches-lellki-wp33-5", 5, { index_offset = 1 })
append_option_clusters(lellki_wp33_switch.zcl_clusters,
  zcl.tuya_magic_packet(),
  lellki_wp33_power_on_behavior()
)
local six_switch = build_switch("switches-switch-6-basic", 6, { index_offset = 1 })
append_option_clusters(six_switch.zcl_clusters, zcl.tuya_magic_packet())
six_switch.configure = bind_on_off_endpoints(6)
local wall_switch_module = build_switch_module("switches-switch-1-countdown-switch-type", 1)
local dual_switch_module = build_switch_module("switches-switch-2-countdown-switch-type", 2)
local triple_switch_module = build_switch_module("switches-switch-3-countdown-switch-type", 3, { index_offset = 1 })








































local relay_1_poweron_switch_type = build_relay_switch("switches-switch-1-poweron-switch-type", 1)
local relay_2_poweron_switch_type = build_relay_switch("switches-switch-2-poweron-switch-type", 2)
local bound_single_switch = build_switch("switches-switch-1", 1)
bound_single_switch.configure = bind_on_off_endpoints(1)
local tuya_single_countdown = build_tuya_single_switch_options("switches-switch-1-countdown", {
  countdown = true,
})
local tuya_single_switch_type = build_tuya_single_switch_options("switches-switch-1-switch-type", {
  switch_type = true,
})
local tuya_single_outage_switch_type = build_tuya_single_switch_options("switches-switch-1-outage-switch-type", {
  power_outage_memory = true,
  switch_type = true,
})
local tuya_single_outage_gen_switch_type = build_tuya_single_switch_options("switches-switch-1-outage-switch-type", {
  power_outage_memory = true,
  gen_on_off_switch_type = true,
})
local tuya_single_module_options = build_tuya_single_switch_options("switches-switch-1-module-options", {
  power_outage_memory = true,
  switch_type = true,
  countdown = true,
  indicator_mode = true,
})
local tuya_single_countdown_switch_type_indicator = build_tuya_single_switch_options(
  "switches-switch-1-countdown-switch-type-indicator",
  { switch_type = true, countdown = true, indicator_mode = true }
)
local tuya_single_countdown_indicator = build_tuya_single_switch_options(
  "switches-switch-1-countdown-indicator",
  { countdown = true, indicator_mode = true }
)
local tuya_single_poweron_indicator = build_tuya_single_switch_options(
  "switches-switch-1-poweron-indicator",
  { power_on_behavior_2 = true, indicator_mode = true }
)
local tuya_single_poweron = build_tuya_single_switch_options(
  "switches-switch-1-poweron",
  { power_on_behavior_2 = true }
)
local tuya_single_poweron_countdown = build_tuya_single_switch_options(
  "switches-switch-1-poweron-countdown",
  { power_on_behavior_2 = true, countdown = true }
)
local tuya_single_poweron_countdown_switch_type_indicator = build_tuya_single_switch_options(
  "switches-switch-1-poweron-countdown-switch-type-indicator",
  { power_on_behavior_2 = true, switch_type = true, countdown = true, indicator_mode = true }
)

local ts0001_bbeb = build_switch("switches-switch-1-ts0001-bbeb", 1)
append_option_clusters(ts0001_bbeb.zcl_clusters,
  zcl.tuya_magic_packet(),
  tuya_enum_mapping("ts0001_bbeb_power_on_behavior", 0xE001, 0xD010,
    emit.ts0001BbebPowerOnBehavior(), { [0] = "off", [1] = "on", [2] = "previous" }, { off = 0, on = 1, previous = 2 }),
  tuya_enum_mapping("ts0001_bbeb_backlight_mode", zcl.CLUSTER_ON_OFF, 0x5000,
    emit.ts0001BbebBacklightMode(), { [0] = "off", [1] = "on", [false] = "off", [true] = "on" }, { off = false, on = true },
    { data_type = data_types.Boolean }),
  tuya_enum_mapping("ts0001_bbeb_indicator_mode", zcl.CLUSTER_ON_OFF, 0x8001,
    emit.ts0001BbebIndicatorPattern(), { [0] = "off", [1] = "off/on", [2] = "on/off", [3] = "on" }, { off = 0, ["off/on"] = 1, ["on/off"] = 2, on = 3 })
)
ts0001_bbeb.configure = bind_on_off_endpoints(1)

local ts0003_module2 = build_switch("switches-switch-3-ts0003-module2", 3, { index_offset = 1 })
local ts0003_module2_countdown_emitters = {
  emit.ts0003Module2CountdownOne(),
  emit.ts0003Module2CountdownTwo(),
  emit.ts0003Module2CountdownThree(),
}
append_option_clusters(ts0003_module2.zcl_clusters,
  zcl.tuya_magic_packet(),
  tuya_enum_mapping("ts0003_module2_switch_type", 0xE001, 0xD030,
    emit.ts0003Module2SwitchType(), { [0] = "toggle", [1] = "state", [2] = "momentary" }, { toggle = 0, state = 1, momentary = 2 }, { mfg_code = 0x1141 }),
  tuya_enum_mapping("ts0003_module2_indicator_mode", zcl.CLUSTER_ON_OFF, 0x8001,
    emit.ts0003Module2IndicatorMode(), { [0] = "off", [1] = "off_on", [2] = "on_off", [3] = "on" }, { off = 0, off_on = 1, on_off = 2, on = 3 })
)
for endpoint = 1, 3 do
  local word = ({ "One", "Two", "Three" })[endpoint]
  append_option_clusters(ts0003_module2.zcl_clusters, zcl.countdown_timer({
    name = "ts0003_module2_countdown_" .. word:lower(), endpoint = endpoint,
    component = endpoint == 1 and "main" or ("switch" .. endpoint), emit = ts0003_module2_countdown_emitters[endpoint],
  }))
end
ts0003_module2.configure = bind_on_off_endpoints(3)

local nfzb03 = build_switch("switches-switch-3-nfzb03", 3, { index_offset = 1 })
append_option_clusters(nfzb03.zcl_clusters,
  zcl.tuya_magic_packet(),
  tuya_enum_mapping("nfzb03_power_outage_memory", zcl.CLUSTER_ON_OFF, 0x8002,
    emit.nfzb03PowerOutageMemory(), { [0] = "off", [1] = "on", [2] = "restore" }, { off = 0, on = 1, restore = 2 }),
  tuya_enum_mapping("nfzb03_switch_type", 0xE001, 0xD030,
    emit.nfzb03SwitchType(), { [0] = "toggle", [1] = "state", [2] = "momentary" }, { toggle = 0, state = 1, momentary = 2 }, { mfg_code = 0x1141 }),
  tuya_enum_mapping("nfzb03_indicator_mode", zcl.CLUSTER_ON_OFF, 0x8001,
    emit.nfzb03IndicatorMode(), { [0] = "off", [1] = "off_on", [2] = "on_off", [3] = "on" }, { off = 0, off_on = 1, on_off = 2, on = 3 }),
  tuya_enum_mapping("nfzb03_backlight_mode", zcl.CLUSTER_ON_OFF, 0x5000,
    emit.nfzb03BacklightMode(), { [0] = "off", [1] = "on", [false] = "off", [true] = "on" }, { off = false, on = true }, { data_type = data_types.Boolean })
)
for endpoint = 1, 3 do
  local word = ({ "One", "Two", "Three" })[endpoint]
  local emitters = NFZB03_EMITTERS[endpoint]
  append_option_clusters(nfzb03.zcl_clusters,
    zcl.countdown_timer({ name = "nfzb03_countdown_" .. word:lower(), endpoint = endpoint,
      component = endpoint == 1 and "main" or ("switch" .. endpoint), emit = emitters.countdown }),
    nfzb_inching_mapping(endpoint, "enabled", emitters.control, {
      enabled_values = { enabled = "ENABLE", disabled = "DISABLE" },
    }),
    nfzb_inching_mapping(endpoint, "time", emitters.time, {
      enabled_values = { enabled = "ENABLE", disabled = "DISABLE" },
    })
  )
end
nfzb03.configure = bind_on_off_endpoints(3)











































































register(ts0001_bbeb, fps("TS0001", { "_TZ3000_bbebkwjk" }))
register(ts0003_module2, fps("TS0003", { "_TZ3000_bu47m8pv" }))
register(nfzb03, fps("TS0003", {
  "_TZ3000_fawk5xjv", "_TZ3000_bvij6kod", "_TZ3000_aracgljk", "_TZ3210_fawk5xjv",
}))







register(single_power_switch, fps("TS0001", {
  "_TZ3000_xkap8wtb",
  "_TZ3000_qnejhcsu",
  "_TZ3000_x3ewpzyr",
  "_TZ3000_mkhkxx1p",
  "_TZ3000_tgddllx4",
  "_TZ3000_kqvb5akv",
  "_TZ3000_q8r0bbvy",
  "_TZ3000_g92baclx",
  "_TZ3000_qlai3277",
  "_TZ3000_qaabwu5c",
  "_TZ3000_qorepo2x",
  "_TZ3000_ikuxinvo",
  "_TZ3000_hzlsaltw",
  "_TZ3000_jsfzkftc",
  "_TZ3000_0ghwhypc",
  "_TZ3000_1adss9de",
  "_TZ3000_x8mbwtsz",
  "_TZ3000_iktiy8ue",
  "_TZ3000_zojh9vz7",
  "_TZ3000_gsat0axs",
  "_TZ3000_olo5jhjk",
}))

register(dual_power_switch, fps("TS0002", {
  "_TZ3000_aaifmpuq",
  "_TZ3000_irrmjcgi",
  "_TZ3000_huvxrx4i",
  "_TZ3000_pxfjrzyj",
  "_TZ3000_hopb2kjm",
}))

register(single_power_switch, fps("TS000F", {
  "_TZ3000_xkap8wtb",
}))

register(tuya_single_switch, fps("SM0001", {
  "_TZ3000_jcqs2mrv",
}))

register(bound_single_switch, fps("TS0001", {
  "_TZ3000_bezfthwc",
}))

register(wall_switch_module, fps("TS0001", {
  "_TZ3000_hktqahrq",
  "_TZ3000_q6a3tepg",
  "_TZ3000_skueekg3",
  "_TZ3000_npzfdcof",
  "_TZ3000_5ng23zjs",
  "_TZ3000_rmjr4ufz",
  "_TZ3000_v7gnj3ad",
  "_TZ3000_3a9beq8a",
  "_TZ3000_ark8nv4y",
  "_TZ3000_mx3vgyea",
  "_TZ3000_fdxihpp7",
  "_TZ3000_qsp2pwtf",
  "_TZ3000_kycczpw8",
  "_TZ3000_46t1rvdu",
  "_TZ3000_bhcpnvud",
  "_TZ3000_i9oy2rdq",
}))

register(tuya_single_switch, fps("TS0001", {
  "_TZ3000_8n7lqbm0",
  "_TZ3000_cb3aangp",
  "_TZ3000_ctftgjwb",
  "_TZ3000_g8n1n7lg",
  "_TZ3000_udl7uyd2",
}))

register(tuya_single_poweron, fps("TS0001", {
  "_TZ3000_bmqxalil",
  "_TZ3000_w1tcofu8",
  "_TZ3000_ma3mhpx2",
  "_TZ3000_wijoqjk1",
}))

register(tuya_single_poweron_countdown_switch_type_indicator, fps("TS0001", {
  "_TZ3000_5rpu3r0d",
}))

register(tuya_single_module_options, fps("TS0001", {
  "_TZ3000_tqlv4ug4",
  "_TZ3210_tqlv4ug4",
  "_TZ3000_gjrubzje",
  "_TZ3000_tygpxwqa",
  "_TZ3000_4rbqgcuv",
  "_TZ3000_veu2v775",
  "_TZ3000_prits6g4",
  "_TZ3210_9hbau615",
  "_TZ3000_afgzktgb",
  "_TZ3000_qamj2vnn",
  "_TZ3000_n6fqajob",
}))

register(tuya_single_outage_switch_type, fps("TS0001", {
  "_TZ3000_xfxpoxe0",
}))

register(tuya_single_countdown_indicator, fps("TS0001", {
  "_TZ3000_myaaknbq",
  "_TZ3000_cpozgbrx",
  "_TZ3000_drc9tuqb",
}))

register(tuya_single_poweron_indicator, fps("TS0001", {
  "_TZ3000_gbshwgag",
  "_TZ3000_blhvsaqf",
  "_TZ3000_65ajyxua",
  "_TZ3000_qq9ahj6z",
}))

register(tuya_single_countdown_switch_type_indicator, fps("TS0001", {
  "_TZ3000_pgq7ormg",
}))

register(tuya_single_poweron_countdown, fps("TS0001", {
  "_TZ3000_qvmiyxuk",
}))

register(tuya_single_countdown, fps("TS0001", {
  "_TZ3210_fhx7lk3d",
}))

register(bound_single_switch, fps("TS0001", {
  "_TYZB01_4vgantdz",
  "_TYZB01_reyozfcg",
  "_TZ3000_wrhhi5h2",
}))

register(tuya_single_switch_type, fps("TS0001", {
  "_TZ3000_6axxqqi2",
  "_TZ3000_gtdswg8k",
  "_TZ3000_majwnphg",
  "_TZ3000_qh6qjuan",
  "_TZ3000_zw7yf6yk",
}))

register(tuya_single_switch, fps("TS0001", {
  "_TZ3000_dov0a3p1",
  "_TZ3000_t3s9qmmg",
  "_TZ3000_ehgouyvu",
}))

register(tuya_single_switch, fps("TS0011", {
  "_TZ3000_uaa34g7v",
  "_TZ3000_l8fsgo6p",
  "_TZ3000_abjodzas",
  "_TZ3000_hhiodade",
}))

register(wall_switch_module, fps("TS0011", {
  "_TZ3000_hbxsdd6k",
}))

register(wall_switch_module, fps("TS0011", {
  "_TZ3000_qmi1cfuq",
  "_TZ3000_txpirhfq",
  "_TZ3000_ji4araar",
  "_TZ3000_tw4ztbp4",
}))

register(bound_single_switch, fps("TS011F", {
  "_TZ3000_twqctvna",
}))

register(tuya_single_switch, {
  fp("_TYZB01_iuepbmpv", "TS0121"),
  fp("_TZ3000_bkfe0bab", "TS011F"),
  fp("_TZ3000_zmy1waw6", "TS011F"),
})

register(single_power_outage_switch, fps("TS011F", {
  "_TZ3000_z6fgd73r",
}))

register(wall_switch_module, fps("TS000F", {
  "_TZ3000_hktqahrq",
  "_TZ3000_m9af2l6g",
  "_TZ3000_mx3vgyea",
  "_TZ3000_skueekg3",
  "_TZ3000_dlhhrhs8",
  "_TZ3000_fdxihpp7",
}))

register(tuya_single_switch, fps("TS000F", {
  "_TZ3210_a2erlvb8",
}))

register(single_switch, {
  { manufacturer = "_TZ3210_hjxqqofs" .. string.char(0), model = "TS000F" },
})

register(tuya_single_switch_type, fps("TS000F", {
  "_TZ3000_hdc8bbha",
}))

register(tuya_single_outage_gen_switch_type, fps("TS000F", {
  "_TZ3218_hdc8bbha",
}))

register(relay_1_poweron_switch_type, fps("TS000F", {
  "_TZ3218_n0jsuogs",
}))

register(tuya_dual_metered, fps("TS011F", {
  "_TZ3000_bep7ccew",
}))

register(mercator_spp02gip, fps("TS011F", {
  "_TZ3210_7jnk7l3k",
}))

register(tuya_dual_metered_outage, fps("TS011F", {
  "_TZ3210_raqjcxo5",
  "_TZ3210_pfbzs1an",
}))

register(mercator_spp04g, {
  fp("_TZ3210_yvxjawlt", "TS011F"),
})

register(tuya_dual_metered_outage_indicator, fps("TS011F", {
  "_TZ3000_dd8wwzcy",
}))

register(tuya_dual_metered_outage_indicator_lock, fps("TS011F", {
  "_TZ3000_jak16dll",
  "_TZ3000_rqbjepe8",
  "_TZ3000_uwkja6z1",
}))

register(tuya_dual_metered_full_options, fps("TS011F", {
  "_TZ3210_bep7ccew",
  "_TZ3210_qlmnxmac",
}))

register(zemismart_dual_outlet, fps("TS011F", {
  "_TZ3000_gazjngjl",
}))

register(metered_dual_plug, {
  fp("LUMI", "lumi.plug.acn005"),
  fp("LUMI", "lumi.plug.sacn03"),
})

register(single_switch, {
  fp("Aqara", "lumi.switch.acn048"),
  fp("LUMI", "lumi.ctrl_ln1"),
  fp("LUMI", "lumi.ctrl_ln1.aq1"),
  fp("LUMI", "lumi.ctrl_neutral1"),
  fp("LUMI", "lumi.switch.acn029"),
  fp("LUMI", "lumi.switch.acn048"),
  fp("LUMI", "lumi.switch.acn056"),
  fp("LUMI", "lumi.switch.acn061"),
  fp("LUMI", "lumi.switch.b1laus01"),
  fp("LUMI", "lumi.switch.b1lacn01"),
  fp("LUMI", "lumi.switch.b1nacn01"),
  fp("LUMI", "lumi.switch.b1nacn02"),
  fp("LUMI", "lumi.switch.b1naus01"),
  fp("LUMI", "lumi.switch.b1lc04"),
  fp("LUMI", "lumi.switch.b1nc01"),
  fp("LUMI", "lumi.switch.l0acn1"),
  fp("LUMI", "lumi.switch.l0agl1"),
  fp("LUMI", "lumi.switch.l1acn1"),
  fp("LUMI", "lumi.switch.l1aeu1"),
  fp("LUMI", "lumi.switch.n0acn2"),
  fp("LUMI", "lumi.switch.n0agl1"),
  fp("LUMI", "lumi.switch.n1acn1"),
  fp("LUMI", "lumi.switch.n1aeu1"),
})

register(bound_dual_switch, {
  fp("Aqara", "lumi.switch.acn047"),
  fp("Aqara", "lumi.switch.acn049"),
  fp("Aqara", "lumi.switch.acn057"),
  fp("LUMI", "lumi.ctrl_ln2"),
  fp("LUMI", "lumi.ctrl_ln2.aq1"),
  fp("LUMI", "lumi.ctrl_neutral2"),
  fp("LUMI", "lumi.relay.c2acn01"),
  fp("LUMI", "lumi.switch.acn030"),
  fp("LUMI", "lumi.switch.acn047"),
  fp("LUMI", "lumi.switch.acn049"),
  fp("LUMI", "lumi.switch.acn057"),
  fp("LUMI", "lumi.switch.b2laus01"),
  fp("LUMI", "lumi.switch.b2lacn01"),
  fp("LUMI", "lumi.switch.b2nacn01"),
  fp("LUMI", "lumi.switch.b2nacn02"),
  fp("LUMI", "lumi.switch.b2naus01"),
  fp("LUMI", "lumi.switch.b2lc04"),
  fp("LUMI", "lumi.switch.b2nc01"),
  fp("LUMI", "lumi.switch.l2acn1"),
  fp("LUMI", "lumi.switch.l2aeu1"),
  fp("LUMI", "lumi.switch.n2acn1"),
  fp("LUMI", "lumi.switch.n2aeu1"),
})

register(bound_triple_switch, {
  fp("Aqara", "lumi.switch.acn055"),
  fp("Aqara", "lumi.switch.acn059"),
  fp("LUMI", "lumi.switch.acn031"),
  fp("LUMI", "lumi.switch.acn040"),
  fp("LUMI", "lumi.switch.acn054"),
  fp("LUMI", "lumi.switch.acn055"),
  fp("LUMI", "lumi.switch.acn058"),
  fp("LUMI", "lumi.switch.acn059"),
  fp("LUMI", "lumi.switch.b3l01"),
  fp("LUMI", "lumi.switch.b3n01"),
  fp("LUMI", "lumi.switch.l3acn1"),
  fp("LUMI", "lumi.switch.l3acn3"),
  fp("LUMI", "lumi.switch.n3acn1"),
  fp("LUMI", "lumi.switch.n3acn3"),
  fp("LUMI", "lumi.switch.n4acn4"),
})

register(tuya_dual_switch, fps("TS011F", {
  "_TZ3000_46vasa5h",
  "_TZ3000_mvn6jl7x",
  "_TZ3000_raviyuvk",
  "_TYZB01_hlla45kx",
  "_TZ3000_92qd4sqa",
  "_TZ3000_zwaadvus",
  "_TZ3000_k6fvknrr",
  "_TZ3000_6s5dc9lx",
  "_TZ3000_helyqdvs",
  "_TZ3000_rgpqqmbj",
  "_TZ3000_8nyaanzb",
  "_TZ3000_iy2c3n6p",
  "_TZ3000_qlmnxmac",
  "_TZ3000_sgb0xhwn",
  "_TZ3210_ph1joc22",
  "_TZ3210_sgb0xhwn",
  "_TZ3000_iv6ph5tr",
  "_TZ3000_pmz6mjyu",
  "_TZ3000_rul9yxcc",
  "_TZ3000_mlswgkc3",
  "_TZ3000_v4mevirn",
  "_TZ3000_zigisuyh",
  "_TZ3000_xeumnff9",
  "_TZ3000_2xlvlnez",
  "_TZ3000_cymsnfvf",
  "_TZ3210_2uk4z8ce",
}))

register(tuya_dual_switch, {
  fp("HOBEIAN", "ZG-305Z"),
})

register(tuya_dual_switch, fps("TS000F", {
  "_TZ3000_m8f3z8ju",
}))

register(relay_2_poweron_switch_type, fps("TS000F", {
  "_TZ3218_sgbsg6mr",
}))

register(ts0002_rux, fps("TS0002", {
  "_TZ3000_ruxexjfz",
}))

register(tuya_dual_switch, fps("TS0002", {
  "_TZ3000_01gpyda5",
  "_TZ3000_bvrlqyj7",
  "_TZ3000_7ed9cqgi",
  "_TZ3000_zmy4lslw",
  "_TZ3000_4xfqlgqo",
  "_TZ3000_hojntt34",
  "_TZ3000_eei0ubpy",
  "_TZ3000_qaa59zqd",
  "_TZ3000_lmlsduws",
  "_TZ3000_fbjdkph9",
  "_TZ3000_zbfya6h0",
  "_TZ3000_hznzbl0x",
  "_TZ3000_fisb3ajo",
  "_TZ3000_5gey1ohx",
  "_TZ3000_mtnpt6ws",
  "_TZ3000_mufwv0ry",
  "_TZ3000_54hjn4vs",
  "_TZ3000_aa5t61rh",
  "_TZ3000_in5qxhtt",
  "_TZ3000_ogpla3lh",
  "_TZ3000_i9w5mehz",
  "_TZ3000_dershnvx",
  "_TZ3000_ywubfuvt",
  "_TZ3000_wnzoyohq",
  "_TZ3000_5ksufhqi",
  "_TZ3210_nuenzetq",
  "_TZ3000_zxrfobzw",
  "_TZ3000_criiahcg",
  "_TZ3000_lugaswf8",
  "_TZ3000_nuenzetq",
  "_TZ3000_ruldv5dt",
  "_TZ3000_gkesadus",
  "_TZ3000_rfjctviq",
  "_TZ3000_yxmafzmd",
  "_TZ3210_a2erlvb8",
  "_TZ3210_pdnwpnz5",
}))

register(tuya_dual_switch, {
  fp("HOBEIAN", "ZG-301Z-2CH"),
})

register(tuya_dual_switch, fps("TS0012", {
  "_TZ3000_biakwrag",
  "_TZ3000_18ejxno0",
}))

register(bound_dual_switch, fps("TS0003", {
  "_TYZB01_digziiav",
  "_TYZB01_zsl6z0pw",
  "_TYZB01_uqkphoed",
}))

register(bound_dual_switch, fps("TS0002", {
  "_TYZB01_digziiav",
  "_TYZB01_zsl6z0pw",
  "_TYZB01_uqkphoed",
  "_TZ3000_iwtv2jwo",
  "_TZ3000_h1ipgkwn",
  "_TZ3000_tas0zemd",
}))

register(tuya_dual_switch, fps("TS0002", {
  "_TZ3210_6smingw0",
}))

register(bound_dual_switch, {
  fp("Somfy", "ON/OFF (2CH)"),
  fp("Sunricher", "ON/OFF (2CH)"),
})














register(dual_switch_module, fps("TS0012", {
  "_TZ3000_jl7qyupf",
  "_TZ3000_nPGIPl5D",
  "_TZ3000_kpatq5pq",
  "_TZ3000_ljhbw1c9",
  "_TZ3000_4zf0crgo",
}))

register(tuya_triple_switch, fps("TS0003", {
  "_TZ3000_vjhcenzo",
  "_TZ3000_f09j9qjb",
  "_TZ3000_rhkfbfcv",
  "_TZ3000_empogkya",
  "_TZ3000_lubfc1t5",
  "_TZ3000_lsunm46z",
  "_TZ3000_v4l4b0lp",
  "_TZ3000_uilitwsy",
  "_TZ3000_66fekqhh",
  "_TZ3000_ok0ggpk7",
  "_TZ3210_ok0ggpk7",
  "_TZ3000_aknpkt02",
  "_TZ3210_aksyshpw",
  "_TZ3000_nwidmc4n",
  "_TZ3000_pfc7i3kt",
  "_TZ3000_dyzkbcip",
  "_TZ3000_ouwfc1qj",
  "_TZ3000_eqsair32",
  "_TZ3000_4o16jdca",
  "_TZ3000_odzoiovu",
  "_TZ3000_hbic3ka3",
  "_TZ3000_lvhy15ix",
  "_TZ3000_mhhxxjrs",
  "_TZ3000_iv4eq7eh",
  "_TZ3000_mzcp0of6",
  "_TZ3000_pf7swkqp",
  "_TZ3000_ju82pu2b",
  "_TZ3000_vsasbzkf",
  "_TZ3000_nnwehhst",
  "_TZ3000_mw1pqqqt",
  "_TZ3000_pv4puuxi",
  "_TZ3000_avky2mvc",
  "_TZ3000_785olaiq",
  "_TZ3000_qxcnwv26",
  "_TZ3000_g9chy2ib",
  "_TZ3000_0q5fjqgw",
  "_TZ3000_pmsxmttq",
  "_TZ3000_zeuulson",
  "_TZ33000_d9yfgzur",
}))

register(triple_switch_module, fps("TS0013", {
  "_TZ3000_ypgri8yz",
  "_TZ3000_sznawwyw",
  "_TZ3000_avotanj3",
  "_TZ3000_t7ugva7q",
}))

register(tuya_triple_switch, {
  fp("HOBEIAN", "ZG-301Z-3CH"),
})

register(bound_single_switch, fps("TS0003", {
  "_TYZB01_aneiicmq",
  "_TYZB01_ncutbjdi",
  "_TYZB01_u9kkqh5o",
}))

register(tuya_quad_bind_only_switch, fps("TS0004", {
  "_TZ3000_ltt60asa",
  "_TZ3000_mmkbptmx",
  "_TZ3000_liygxtcq",
  "_TZ3000_mdj7kra9",
  "_TZ3000_u3oupgdy",
  "_TZ3000_imaccztn",
  "_TZ3000_iymfxdis",
  "_TZ3000_nivavasg",
  "_TZ3000_gexniqbq",
  "_TZ3000_r9e2w7dn",
  "_TZ3000_5ajpkyq6",
  "_TZ3000_knoj8lpk",
  "_TZ3000_3n2minvf",
  "_TZ3000_tyg4yiat",
  "_TZ3210_imaccztn",
  "_TZ3210_wts1g2oh",
}))

register(tuya_quad_reporting_switch, {
  fp("_TZ3210_iymfxdis", "TS0004"),
})

register(tuya_quad_magic_only_switch, fps("TS0004", {
  "_TZ3000_a37eix1s",
  "_TZ3000_nsa76jai",
  "_TZ3000_wwtnshol",
}))

register(six_switch, fps("TS0006", {
  "_TZ3000_cvis4qmw",
}))

register(tuya_quad_reporting_switch, fps("TS011F", {
  "_TZ3000_3zofvcaa",
  "_TZ3000_pvlvoxvt",
  "_TZ3000_lqb7lcq9",
  "_TZ3210_lqb7lcq9",
  "_TZ3210_urjf5u18",
  "_TZ3210_8n4dn1ne",
}))

register(quad_switch, {
  fp("_TZ3000_qiutut5y", "TS011F"),
})

register(tuya_triple_switch, fps("TS011F", {
  "_TZ3000_wzauvbcs",
  "_TZ3000_oznonj5q",
  "_TZ3000_1obwwnmq",
  "_TZ3000_4uf3d0ax",
  "_TZ3000_vzopcetz",
  "_TZ3000_vmpbygs5",
  "_TZ3000_dlug3kbc",
  "_TZ3000_9tg32trw",
}))

register(lellki_wp33_switch, fps("TS011F", {
  "_TZ3000_air9m6af",
  "_TZ3000_9djocypn",
  "_TZ3000_bppxj3sf",
}))

register(quint_tuya_switch, fps("TS011F", {
  "_TZ3000_in5s3wn1",
  "_TZ3000_wbloefbf",
}))

register(quint_tuya_switch, fps("TS011F", {
  "_TZ3000_cfnprab5",
  "_TZ3000_o005nuxx",
  "_TZ3000_gdyjfvgm",
  "_TZ3000_pl5v1yyy",
  "_TZ3000_djgzdba9",
}))

-- ZCL REPORTING CAPABILITIES BEGIN
zcl.attach_reporting_capabilities(device_definitions, {
  {1, "rpt-tuj"},
  {2, "rpt-tkg", {zr000600001 = "Switch", zr000600002 = "SwitchTwo", zr000600003 = "SwitchThree"}},
  {3, "rpt-tcm", {zr000600001 = "Switch", zr000600002 = "SwitchTwo", zr000600003 = "SwitchThree"}},
  {4, "rpt-tzt"},
  {5, "rpt-tkp", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {6, "rpt-tzt"},
  {7, "rpt-sit"},
  {8, "rpt-sit"},
  {9, "rpt-tss"},
  {10, "rpt-sit"},
  {11, "rpt-tbx"},
  {12, "rpt-tpl"},
  {13, "rpt-tmp"},
  {14, "rpt-tks"},
  {15, "rpt-tet"},
  {16, "rpt-tlp"},
  {17, "rpt-tma"},
  {18, "rpt-tce"},
  {19, "rpt-twp"},
  {20, "rpt-sit"},
  {21, "rpt-tlc"},
  {22, "rpt-sit"},
  {23, "rpt-sit"},
  {24, "rpt-tss"},
  {25, "rpt-tss"},
  {26, "rpt-sit"},
  {27, "rpt-sit"},
  {28, "rpt-txu"},
  {29, "rpt-tss"},
  {30, "rpt-sit"},
  {31, "rpt-sit"},
  {32, "rpt-tlc"},
  {33, "rpt-tks"},
  {34, "rpt-tpe"},
  {35, "rpt-tye", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {36, "rpt-too", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {37, "rpt-too", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {38, "rpt-tve", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {39, "rpt-tfo", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {40, "rpt-tzz", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {41, "rpt-tum", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {42, "rpt-tev", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {43, "rpt-lvk", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {44, "rpt-sit"},
  {45, "rpt-lpm", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {46, "rpt-lek", {zr000600001 = "Switch", zr000600002 = "SwitchTwo", zr000600003 = "SwitchThree"}},
  {47, "rpt-lpm", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {48, "rpt-lpm", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {49, "rpt-lpm", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {50, "rpt-tsl", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {51, "rpt-tqv", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {52, "rpt-lpm", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {53, "rpt-lpm", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {54, "rpt-lpm", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {55, "rpt-lpm", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {56, "rpt-lpm", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {57, "rpt-lpm", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {58, "rpt-lpm", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {59, "rpt-tkw", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {60, "rpt-lek", {zr000600001 = "Switch", zr000600002 = "SwitchTwo", zr000600003 = "SwitchThree"}},
  {61, "rpt-tiu", {zr000600001 = "Switch", zr000600002 = "SwitchTwo", zr000600003 = "SwitchThree"}},
  {62, "rpt-lek", {zr000600001 = "Switch", zr000600002 = "SwitchTwo", zr000600003 = "SwitchThree"}},
  {63, "rpt-sit"},
  {65, "rpt-tmr", {zr000600001 = "Switch", zr000600002 = "SwitchTwo", zr000600003 = "SwitchThree", zr000600004 = "SwitchFour"}},
  {67, "rpt-tqvv", {zr000600001 = "Switch", zr000600002 = "SwitchTwo", zr000600003 = "SwitchThree", zr000600004 = "SwitchFour", zr000600005 = "SwitchFive", zr000600006 = "SwitchSix"}},
  {68, "rpt-tmr", {zr000600001 = "Switch", zr000600002 = "SwitchTwo", zr000600003 = "SwitchThree", zr000600004 = "SwitchFour"}},
  {69, "rpt-tmr", {zr000600001 = "Switch", zr000600002 = "SwitchTwo", zr000600003 = "SwitchThree", zr000600004 = "SwitchFour"}},
  {70, "rpt-lek", {zr000600001 = "Switch", zr000600002 = "SwitchTwo", zr000600003 = "SwitchThree"}},
  {71, "rpt-tsh", {zr000600001 = "Switch", zr000600002 = "SwitchTwo", zr000600003 = "SwitchThree", zr000600004 = "SwitchFour", zr000600005 = "SwitchFive"}},
  {72, "rpt-tfx", {zr000600001 = "Switch", zr000600002 = "SwitchTwo", zr000600003 = "SwitchThree", zr000600004 = "SwitchFour", zr000600005 = "SwitchFive"}},
  {73, "rpt-tfx", {zr000600001 = "Switch", zr000600002 = "SwitchTwo", zr000600003 = "SwitchThree", zr000600004 = "SwitchFour", zr000600005 = "SwitchFive"}},
})
-- ZCL REPORTING CAPABILITIES END

return {
  id = "zcl.switches.switches",
  registrations = device_definitions,
}
