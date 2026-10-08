local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local zcl_device_helpers = require "contracts.helpers.zcl"
local device_management = require "st.zigbee.device_management"
local data_types = require "st.zigbee.data_types"
local cluster_base = require "st.zigbee.cluster_base"

local device_definitions, register_device_definition = device_helpers.definition_registry()

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

local function build_switch(profile, count)
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
    zcl_clusters = zcl.multi_switch(count),
  }
end

local function append_option_clusters(clusters, ...)
  return zcl_device_helpers.append_clusters(clusters, ...)
end

local function fixed_metering(mapping, scale)
  mapping.metering_kind = nil
  mapping.scale = scale
  return mapping
end

local function tuya_enum_mapping(name, cluster_id, attribute_id, emitter, from_values, to_values, options)
  options = options or {}
  return zcl.cluster_attribute(cluster_id, attribute_id, {
    name = name,
    endpoint = options.endpoint,
    component = options.component,
    emit = emitter,
    from_device = function(value) return from_values[type(value) == "table" and value.value or value] end,
    to_device = function(value) return to_values[value] end,
    data_type = options.data_type or data_types.Enum8,
    write_type = options.write_type or options.data_type or data_types.Enum8,
    mfg_code = options.mfg_code,
    prefer_plain_attribute_write = options.prefer_plain_attribute_write == true,
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

local NFZB_TWO_INCHING = {
  [1] = { enabled_capability = "concertmirror08464.nfzbTwoInchingEnabledOne", enabled_attribute = "nfzbTwoInchingEnabledOne", time_capability = "concertmirror08464.nfzbTwoInchingTimeOne", time_attribute = "nfzbTwoInchingTimeOne" },
  [2] = { enabled_capability = "concertmirror08464.nfzbTwoInchingEnabledTwo", enabled_attribute = "nfzbTwoInchingEnabledTwo", time_capability = "concertmirror08464.nfzbTwoInchingTimeTwo", time_attribute = "nfzbTwoInchingTimeTwo" },
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

-- Literal v26.99.0 parity: String.fromCharCode(...), then Node's UTF-8
-- Buffer.from(string), then Base64. Code units >= 0x80 therefore expand to
-- two UTF-8 bytes before Base64 encoding; this is intentionally not raw-byte
-- Base64 even though that upstream behavior is surprising.
local function encode_inching_block(state, seconds_high, seconds_low)
  local utf8_bytes = {}
  for _, code_unit in ipairs({ state, seconds_high, seconds_low }) do
    if code_unit < 0x80 then
      utf8_bytes[#utf8_bytes + 1] = code_unit
    else
      utf8_bytes[#utf8_bytes + 1] = 0xC0 + math.floor(code_unit / 0x40)
      utf8_bytes[#utf8_bytes + 1] = 0x80 + (code_unit % 0x40)
    end
  end
  return encode_base64_bytes(utf8_bytes)
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

local function decode_utf8_code_units(bytes)
  local code_units = {}
  local offset = 1
  while offset <= #bytes do
    local first = bytes[offset]
    if first < 0x80 then
      code_units[#code_units + 1] = first
      offset = offset + 1
    elseif first >= 0xC2 and first <= 0xDF then
      local second = bytes[offset + 1]
      if second ~= nil and second >= 0x80 and second <= 0xBF then
        code_units[#code_units + 1] = ((first - 0xC0) * 0x40) + (second - 0x80)
        offset = offset + 2
      else
        code_units[#code_units + 1] = 0xFFFD
        offset = offset + 1
      end
    elseif first >= 0xE0 and first <= 0xEF then
      local second = bytes[offset + 1]
      local third = bytes[offset + 2]
      local second_valid = second ~= nil and second >= 0x80 and second <= 0xBF and
        not (first == 0xE0 and second < 0xA0) and not (first == 0xED and second > 0x9F)
      if second_valid and third ~= nil and third >= 0x80 and third <= 0xBF then
        code_units[#code_units + 1] = ((first - 0xE0) * 0x1000) +
          ((second - 0x80) * 0x40) + (third - 0x80)
        offset = offset + 3
      else
        code_units[#code_units + 1] = 0xFFFD
        offset = offset + 1
      end
    else
      code_units[#code_units + 1] = 0xFFFD
      offset = offset + 1
    end
  end
  return code_units
end

local function decode_inching_blocks(value)
  if type(value) ~= "string" or (#value % 4) ~= 0 then
    return nil
  end

  local decoded = {}
  for offset = 1, #value, 4 do
    local bytes = decode_base64_chunk(value:sub(offset, offset + 3))
    if bytes == nil then return nil end
    local code_units = decode_utf8_code_units(bytes)
    local state = code_units[1]
    if state == nil then return nil end
    local channel = 1
    local channel_bits = state
    while channel_bits >= 2 do
      channel = channel + 1
      channel_bits = math.floor(channel_bits / 2)
    end
    decoded[channel] = {
      enabled = state % 2 == 1 and "enabled" or "disabled",
      time = code_units[3] == nil and (math.huge - math.huge) or
        ((code_units[2] or 0) * 256) + code_units[3],
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

local aoyan_ay301z_two = build_switch("switches-switch-2-ay301z-two", 2)
append_option_clusters(aoyan_ay301z_two.zcl_clusters,
  zcl.tuya_magic_packet(),
  zcl.switch_type({
    name = "ay301z_two_switch_type",
    endpoint = 1,
    component = "main",
    emit = emit.ay301zTwoSwitchType(),
  }),
  zcl.countdown_timer({
    name = "ay301z_two_countdown_one",
    endpoint = 1,
    component = "main",
    emit = emit.ay301zTwoCountdownOne("s"),
  }),
  zcl.countdown_timer({
    name = "ay301z_two_countdown_two",
    endpoint = 2,
    component = "switch2",
    emit = emit.ay301zTwoCountdownTwo("s"),
  })
)
aoyan_ay301z_two.configure = bind_on_off_endpoints(2)
local mli_tint_smart_switch = build_switch("switches-switch-1-mli-tint", 1)
append_option_clusters(mli_tint_smart_switch.zcl_clusters,
  zcl.cluster_attribute(zcl.CLUSTER_ON_OFF, 0x4003, {
    name = "mli_tint_power_on_behavior",
    emit = emit.mliTintPowerOnBehavior(),
    from_device = function(value)
      return ({ [0] = "off", [1] = "on", [2] = "toggle", [255] = "previous" })[value]
    end,
    to_device = function(value)
      return ({ off = 0, on = 1, toggle = 2, previous = 255 })[value]
    end,
    data_type = data_types.Enum8,
    write_type = data_types.Enum8,
    read_on_configure = true,
  })
)
mli_tint_smart_switch.configure = bind_on_off_endpoints(1)

-- Mercator SSW03G (Z2M v26.99.0, mercator.ts): three on/off endpoints,
-- implicit Tuya power-on behavior at genOnOff/0x8002, and low/medium/high
-- backlight intensity at genOnOff/0x8001.
local mercator_ssw03g = build_switch("switches-switch-3-ssw03g", 3)
append_option_clusters(mercator_ssw03g.zcl_clusters,
  zcl.tuya_magic_packet(),
  tuya_enum_mapping("ssw03g_power_on_behavior", zcl.CLUSTER_ON_OFF, 0x8002,
    emit.sswThreePowerOnBehavior(),
    { [0] = "off", [1] = "on", [2] = "previous" },
    { off = 0, on = 1, previous = 2 }),
  tuya_enum_mapping("ssw03g_backlight_mode", zcl.CLUSTER_ON_OFF, 0x8001,
    emit.sswThreeBacklightMode(),
    { [0] = "low", [1] = "medium", [2] = "high" },
    { low = 0, medium = 1, high = 2 })
)
mercator_ssw03g.configure = bind_on_off_endpoints(3)

-- Nova Digital NFZB-2 (Z2M v26.99.0, nova_digital.ts): two endpoint
-- switches plus shared outage/backlight/indicator configuration, endpoint
-- countdowns, and Tuya private-cluster inching payloads.
local nfzb2 = build_switch("switches-switch-2-nfzb2", 2)
local nfzb2_emitters = {
  [1] = {
    countdown = emit.nfzbTwoCountdownOne(),
    enabled = emit.nfzbTwoInchingEnabledOne(),
    time = emit.nfzbTwoInchingTimeOne(),
  },
  [2] = {
    countdown = emit.nfzbTwoCountdownTwo(),
    enabled = emit.nfzbTwoInchingEnabledTwo(),
    time = emit.nfzbTwoInchingTimeTwo(),
  },
}
append_option_clusters(nfzb2.zcl_clusters,
  zcl.tuya_magic_packet(),
  tuya_enum_mapping("nfzb2_power_outage_memory", zcl.CLUSTER_ON_OFF, 0x8002,
    emit.nfzbTwoPowerOutageMemory(),
    { [0] = "off", [1] = "on", [2] = "restore" },
    { off = 0, on = 1, restore = 2 }),
  tuya_enum_mapping("nfzb2_indicator_mode", zcl.CLUSTER_ON_OFF, 0x8001,
    emit.nfzbTwoIndicatorMode(),
    { [0] = "off", [1] = "off/on", [2] = "on/off", [3] = "on" },
    { off = 0, ["off/on"] = 1, ["on/off"] = 2, on = 3 }),
  tuya_enum_mapping("nfzb2_backlight_mode", zcl.CLUSTER_ON_OFF, 0x5000,
    emit.nfzbTwoBacklightMode(),
    { [0] = "OFF", [1] = "ON" },
    { OFF = 0, ON = 1 },
    { data_type = data_types.Enum8, write_type = data_types.Enum8 })
)
for endpoint = 1, 2 do
  local word = ({ "One", "Two" })[endpoint]
  local suffix = word:lower()
  local emitters = nfzb2_emitters[endpoint]
  append_option_clusters(nfzb2.zcl_clusters,
    zcl.countdown_timer({
      name = "nfzb2_countdown_" .. suffix,
      endpoint = endpoint,
      component = endpoint == 1 and "main" or "switch2",
      emit = emitters.countdown,
    }),
    nfzb_inching_mapping(endpoint, "enabled", emitters.enabled, {
      name_prefix = "nfzb2",
      contracts = NFZB_TWO_INCHING,
      enabled_values = { enabled = "ENABLE", disabled = "DISABLE" },
    }),
    nfzb_inching_mapping(endpoint, "time", emitters.time, {
      name_prefix = "nfzb2",
      contracts = NFZB_TWO_INCHING,
      enabled_values = { enabled = "ENABLE", disabled = "DISABLE" },
    })
  )
end
nfzb2.configure = bind_on_off_endpoints(2)

-- Candeo C-ZB-SSFS (Z2M v26.99.0, candeo.ts): switched fused spur
-- with fixed electrical-measurement scalers and two private OnOff attributes.
-- The device clears its temporary child lock after every regular on/off command,
-- so mirror Z2M by reading the lock attribute immediately after the command.
local candeo_ssfs_switch_delegate = zcl.switch({
  endpoint = 1,
  minimum_interval = 0,
  maximum_interval = 0xFFFF,
  reportable_change = 1,
})
local candeo_ssfs_switch = zcl.switch({
  endpoint = 1,
  minimum_interval = 0,
  maximum_interval = 0xFFFF,
  reportable_change = 1,
})
candeo_ssfs_switch.sender = function(device, _, value, context)
  local endpoint = context.endpoint or 1
  local sent = zcl.send_named_command(
    device,
    { candeo_ssfs_switch_delegate },
    "switch",
    value,
    { component_id = context.component_id, endpoint = endpoint }
  )
  if sent then
    zcl.read_attribute(device, zcl.CLUSTER_ON_OFF, 0x8000, endpoint)
  end
  return sent
end

local candeo_ssfs = {
  profile = "switches-candeo-ssfs",
  zcl_clusters = {
    candeo_ssfs_switch,
    fixed_metering(zcl.power({
      endpoint = 1,
      minimum_interval = 5,
      maximum_interval = 300,
      reportable_change = 10,
    }), 1),
    fixed_metering(zcl.voltage({
      endpoint = 1,
      minimum_interval = 5,
      maximum_interval = 600,
      reportable_change = 5,
    }), 1),
    fixed_metering(zcl.current({
      endpoint = 1,
      minimum_interval = 5,
      maximum_interval = 900,
      reportable_change = 10,
    }), 1000),
    fixed_metering(zcl.energy({
      endpoint = 1,
      minimum_interval = 5,
      maximum_interval = 1800,
      reportable_change = 50,
    }), 100),
    zcl.power_on_behavior({
      name = "candeo_ssfs_power_on_behavior",
      endpoint = 1,
      emit = emit.candeoSsfsPowerBehavior(),
      read_on_configure = true,
    }),
    zcl.child_lock({
      name = "candeo_ssfs_child_lock",
      endpoint = 1,
      emit = emit.candeoSsfsChildLock(),
      from_device = function(value)
        return (value == true or value == 1) and "LOCK" or "UNLOCK"
      end,
      to_device = function(value)
        return value == "LOCK"
      end,
      read_on_configure = true,
    }),
  },
}

-- Moes ZS-US1-LN (Z2M v26.99.0, tuya.ts): this exact TS0001 variant
-- exposes three settings that the generic TS0001 family does not have.
-- Keep the 0xE001 attributes family-specific and preserve the Enum8 wire type
-- for the OnOff-cluster backlight switch at 0x5000.
local moes_zsus1_ln = build_switch("switches-moes-zsus1-ln", 1)
append_option_clusters(moes_zsus1_ln.zcl_clusters,
  zcl.tuya_magic_packet(),
  tuya_enum_mapping("moes_zsus1_power_on_behavior", 0xE001, 0xD010,
    emit.moesZsus1PowerBehavior(),
    { [0] = "off", [1] = "on", [2] = "previous" },
    { off = 0, on = 1, previous = 2 }),
  tuya_enum_mapping("moes_zsus1_switch_type", 0xE001, 0xD030,
    emit.moesZsus1SwitchType(),
    { [0] = "toggle", [1] = "state", [2] = "momentary" },
    { toggle = 0, state = 1, momentary = 2 }),
  tuya_enum_mapping("moes_zsus1_backlight_mode", zcl.CLUSTER_ON_OFF, 0x5000,
    emit.moesZsus1BacklightMode(),
    { [0] = "off", [1] = "on" },
    { off = 0, on = 1 },
    {
      data_type = data_types.Enum8,
      write_type = data_types.Enum8,
      prefer_plain_attribute_write = true,
    })
)
moes_zsus1_ln.configure = bind_on_off_endpoints(1)

register_device_definition(mercator_ssw03g, device_helpers.create_fingerprints("TS0013", {
  "_TZ3000_khtlvdfc",
}))
register_device_definition(nfzb2, device_helpers.create_fingerprints("TS0002", {
  "_TZ3210_5ksufhqi",
}))

-- Z2M v26.99.0: AOYAN AY301Z-2CH uses endpoints 1/2 with standard OnOff and
-- per-endpoint countdown. Tuya external switch type is one global setting.
register_device_definition(aoyan_ay301z_two, {
  device_helpers.create_fingerprint("AOYAN", "AY301Z-2CH"),
})

-- Z2M v26.99.0 m.onOff() includes the standard StartUpOnOff contract.
-- Both exact identities below share that definition; Lua/YAML preserve NUL.
register_device_definition(mli_tint_smart_switch, {
  device_helpers.create_fingerprint("MLI", "tint Smart Switch"),
  device_helpers.create_fingerprint("MLI\0", "switch01\0"),
})

register_device_definition(candeo_ssfs, {
  device_helpers.create_fingerprint("Candeo", "C-ZB-SSFS"),
})

register_device_definition(moes_zsus1_ln, {
  device_helpers.create_fingerprint("_TZ3000_bzzgvet0", "TS0001"),
})

local zemismart_kes606 = build_switch("switches-zemismart-kes606", 1)
zemismart_kes606.zcl_clusters[1].maximum_interval = 65000
append_option_clusters(zemismart_kes606.zcl_clusters,
  zcl.tuya_magic_packet({ read_on_configure = false }),
  tuya_enum_mapping("kes606_power_on_behavior", 0xE001, 0xD010,
    emit.kes606PowerBehavior(),
    { [0] = "off", [1] = "on", [2] = "previous" },
    { off = 0, on = 1, previous = 2 }, { read_on_configure = false }),
  tuya_enum_mapping("kes606_indicator_mode", zcl.CLUSTER_ON_OFF, 0x8001,
    emit.kes606IndicatorMode(),
    { [0] = "off", [1] = "off/on", [2] = "on/off", [3] = "on" },
    { off = 0, ["off/on"] = 1, ["on/off"] = 2, on = 3 }, { read_on_configure = false })
)
zemismart_kes606.configure = bind_on_off_endpoints(1)
register_device_definition(zemismart_kes606, {
  device_helpers.create_fingerprint("_TZ3000_w5s3mbyn", "TS0001"),
})

local ekaza_ts0003 = {
  profile = "switches-ekaza-ts0003",
  zcl_clusters = {
    zcl.switch({endpoint = 1, component = "main", configure_reporting = false, read_on_configure = false}),
    zcl.switch({endpoint = 2, component = "switch2", configure_reporting = false, read_on_configure = false}),
    zcl.switch({endpoint = 3, component = "switch3", configure_reporting = false, read_on_configure = false}),
    zcl.tuya_magic_packet({read_on_configure = false}),
    tuya_enum_mapping("eka_ts0003_switch_type", 0xE001, 0xD030, emit.ekaTs0003SwitchType(),
      {[0] = "toggle", [1] = "state", [2] = "momentary"},
      {toggle = 0, state = 1, momentary = 2}, {mfg_code = 0x1141, read_on_configure = false}),
    tuya_enum_mapping("eka_ts0003_indicator_mode", 0x0006, 0x8001, emit.ekaTs0003IndicatorMode(),
      {[0] = "off", [1] = "off/on", [2] = "on/off", [3] = "on"},
      {off = 0, ["off/on"] = 1, ["on/off"] = 2, on = 3}, {read_on_configure = false}),
    zcl.countdown_timer({
      name = "eka_ts0003_countdown_one", endpoint = 1, component = "main",
      emit = emit.ekaTs0003CountdownOne(), read_on_configure = false,
    }),
    zcl.countdown_timer({
      name = "eka_ts0003_countdown_two", endpoint = 2, component = "switch2",
      emit = emit.ekaTs0003CountdownTwo(), read_on_configure = false,
    }),
    zcl.countdown_timer({
      name = "eka_ts0003_countdown_three", endpoint = 3, component = "switch3",
      emit = emit.ekaTs0003CountdownThree(), read_on_configure = false,
    }),
  },
  configure = bind_on_off_endpoints(3),
}
register_device_definition(ekaza_ts0003, {
  device_helpers.create_fingerprint("_TZ3000_f6pgzqob", "TS0003"),
})

local nous_b2z_switch_type = tuya_enum_mapping(
  "nous_b2z_switch_type", 0xE001, 0xD030, emit.nousB2zSwitchType(),
  {[0] = "toggle", [1] = "state", [2] = "momentary"},
  {toggle = 0, state = 1, momentary = 2}, {read_on_configure = false}
)
nous_b2z_switch_type.sender = function(device, mapping, value, context)
  local request = cluster_base.write_attribute(
    device, data_types.ClusterId(0xE001), data_types.AttributeId(0xD030),
    data_types.Enum8(mapping.to_device(value))
  )
  request.body.zcl_header.frame_ctrl:set_disable_default_response()
  device:send(request:to_endpoint(context.endpoint or 1))
  return true
end

local nous_b2z = {
  profile = "switches-nous-b2z",
  zcl_clusters = {
    zcl.switch({endpoint = 1, configure_reporting = false, read_on_configure = false}),
    zcl.electrical_measurement_power({
      endpoint = 1, emit = emit.power(), read_only = true,
      minimum_interval = 5, maximum_interval = 3600, reportable_change = 10,
      from_device = function(value, device, context)
        return zcl.scale_mapping_value(device, nil, value, {metering_kind = "power", scale = 1}, context)
      end,
    }),
    zcl.electrical_measurement_voltage({
      endpoint = 1, emit = emit.voltage(), read_only = true,
      minimum_interval = 5, maximum_interval = 3600, reportable_change = 5,
      from_device = function(value, device, context)
        return zcl.scale_mapping_value(device, nil, value, {metering_kind = "voltage", scale = 1}, context)
      end,
    }),
    zcl.electrical_measurement_current({
      endpoint = 1, emit = emit.current(), scale = 1000, read_only = true,
      minimum_interval = 5, maximum_interval = 3600, reportable_change = 50,
    }),
    zcl.simple_metering({
      endpoint = 1, emit = emit.energy(), scale = 100, read_only = true,
      minimum_interval = 5, maximum_interval = 3600, reportable_change = 257,
    }),
    zcl.tuya_magic_packet({read_on_configure = false}),
    nous_b2z_switch_type,
    tuya_enum_mapping("nous_b2z_power_outage_memory", 0x0006, 0x8002, emit.nousB2zPowerOutageMemory(),
      {[0] = "off", [1] = "on", [2] = "restore"},
      {off = 0, on = 1, restore = 2}, {read_on_configure = false}),
  },
  configure = function(driver, device)
    for _, cluster in ipairs({0x0006, 0x0B04, 0x0702}) do
      device:send(device_management.build_bind_request(device, cluster, driver.environment_info.hub_zigbee_eui, 1))
    end
  end,
  parent_refresh = function(device)
    for _, item in ipairs({{0x0006, 0}, {0x0006, 0x8002}, {0xE001, 0xD030}}) do
      zcl.read_attribute(device, item[1], item[2], 1)
    end
  end,
}
register_device_definition(nous_b2z, {
  device_helpers.create_fingerprint("_TZ3000_ahvrgyac", "TS0001"),
})

local tuya_p26_switch_type = tuya_enum_mapping(
  "tuya_p26_switch_type", 0xE001, 0xD030, emit.tuyaP26SwitchType(),
  {[0] = "toggle", [1] = "state", [2] = "momentary"},
  {toggle = 0, state = 1, momentary = 2}, {read_on_configure = false}
)
tuya_p26_switch_type.sender = nous_b2z_switch_type.sender

local tuya_p26 = {
  profile = "switches-tuya-p26",
  zcl_clusters = {
    zcl.switch({endpoint = 1, configure_reporting = false, read_on_configure = false}),
    zcl.tuya_magic_packet({read_on_configure = false}),
    tuya_enum_mapping("tuya_p26_power_behavior", 0xE001, 0xD010, emit.tuyaP26PowerBehavior(),
      {[0] = "off", [1] = "on", [2] = "previous"},
      {off = 0, on = 1, previous = 2}, {read_on_configure = false}),
    tuya_p26_switch_type,
    tuya_enum_mapping("tuya_p26_backlight_mode", 0x0006, 0x5000, emit.tuyaP26BacklightMode(),
      {[0] = "OFF", [1] = "ON"}, {OFF = 0, ON = 1}, {read_on_configure = false, prefer_plain_attribute_write = true}),
    tuya_enum_mapping("tuya_p26_indicator_mode", 0x0006, 0x8001, emit.tuyaP26IndicatorMode(),
      {[0] = "off", [1] = "off/on", [2] = "on/off", [3] = "on"},
      {off = 0, ["off/on"] = 1, ["on/off"] = 2, on = 3}, {read_on_configure = false}),
  },
  configure = bind_on_off_endpoints(1),
  parent_refresh = function(device)
    for _, item in ipairs({{0x0006, 0}, {0xE001, 0xD010}, {0xE001, 0xD030}, {0x0006, 0x5000}, {0x0006, 0x8001}}) do
      zcl.read_attribute(device, item[1], item[2], 1)
    end
  end,
}
register_device_definition(tuya_p26, {
  device_helpers.create_fingerprint("_TZ3000_p26flek3", "TS0001"),
})

local qs_s10_switch_type = tuya_enum_mapping(
  "qs_s10_switch_type", 0xE001, 0xD030, emit.qsS10SwitchType(),
  {[0] = "toggle", [1] = "state", [2] = "momentary"},
  {toggle = 0, state = 1, momentary = 2}, {read_on_configure = false}
)
qs_s10_switch_type.sender = nous_b2z_switch_type.sender

local qs_s10_three = {
  profile = "switches-qs-s10-three",
  zcl_clusters = {
    zcl.switch({endpoint = 1, component = "main", configure_reporting = false, read_on_configure = false}),
    zcl.switch({endpoint = 2, component = "switch2", configure_reporting = false, read_on_configure = false}),
    zcl.switch({endpoint = 3, component = "switch3", configure_reporting = false, read_on_configure = false}),
    zcl.tuya_magic_packet({read_on_configure = false}),
    qs_s10_switch_type,
    tuya_enum_mapping("qs_s10_power_memory", 0x0006, 0x8002, emit.qsS10PowerMemory(),
      {[0] = "off", [1] = "on", [2] = "restore"},
      {off = 0, on = 1, restore = 2}, {read_on_configure = false}),
  },
  configure = bind_on_off_endpoints(3),
}
register_device_definition(qs_s10_three, {
  device_helpers.create_fingerprint("_TZ3000_ly9apzky", "TS0003"),
})

return {
  id = "zcl.switches.z2m_absorption",
  registrations = device_definitions,
}
