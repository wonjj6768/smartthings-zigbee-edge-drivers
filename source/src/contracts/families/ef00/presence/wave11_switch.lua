-- Frozen Z2M v26.99 Wave11 two/three-gang presence-switch families.

local tuya = require "protocol.tuya"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local common = require "contracts.helpers.ef00_presence"

local converter = tuya.converter
local registrations, register_device_definition = common.isolated_definition_registry(device_helpers.definition_registry)

local function enum_converter(values)
  return converter.lookup_from_to(values)
end

local function build_switch_family(options)
  local datapoints = {
    tuya.dp_on_off(1, { name = "switch", component = "main", emit = emit.switch() }),
    tuya.dp_on_off(2, { name = "switch", component = "switch2", emit = emit.switch() }),
  }
  if options.gang_count == 3 then
    datapoints[#datapoints + 1] = tuya.dp_on_off(3, {
      name = "switch", component = "switch3", emit = emit.switch(),
    })
  end

  datapoints[#datapoints + 1] = tuya.dp_numeric(7, {
    name = options.prefix .. "_countdown_1", emit = options.emitters.countdown_one,
  })
  datapoints[#datapoints + 1] = tuya.dp_numeric(8, {
    name = options.prefix .. "_countdown_2", emit = options.emitters.countdown_two,
  })
  if options.gang_count == 3 then
    datapoints[#datapoints + 1] = tuya.dp_numeric(9, {
      name = options.prefix .. "_countdown_3", emit = options.emitters.countdown_three,
    })
  end

  datapoints[#datapoints + 1] = tuya.dp_enum(14, {
    name = options.prefix .. "_relay_status",
    converter = enum_converter({ off = 0, on = 1, memory = 2 }),
    emit = options.emitters.relay_status,
  })
  datapoints[#datapoints + 1] = tuya.dp_enum(15, {
    name = options.prefix .. "_light_mode",
    converter = enum_converter({ relay = 0, none = 1, pos = 2 }),
    emit = options.emitters.light_mode,
  })
  datapoints[#datapoints + 1] = tuya.dp_presence(101, {
    datatype = tuya.DP_TYPE_ENUM,
    converter = converter.true_false1(),
    emit = emit.presence(),
    read_only = true,
  })
  datapoints[#datapoints + 1] = tuya.dp_numeric(102, {
    name = options.prefix .. "_delays_time", emit = options.emitters.delays_time,
  })
  datapoints[#datapoints + 1] = tuya.dp_enum(103, {
    name = options.prefix .. "_turn_on_light_for_person",
    converter = enum_converter(options.turn_on),
    emit = options.emitters.turn_on,
  })
  datapoints[#datapoints + 1] = tuya.dp_numeric(104, {
    name = options.prefix .. "_sensitivity", emit = options.emitters.sensitivity,
  })
  datapoints[#datapoints + 1] = tuya.dp_enum(105, {
    name = options.prefix .. "_turn_off_light_for_person",
    converter = enum_converter(options.turn_off),
    emit = options.emitters.turn_off,
  })

  return {
    profile = options.profile,
    package_group = "z2m-ef00-presence",
    named_datapoints = true,
    datapoints = datapoints,
    query_on_configure = false,
  }
end

local two_gang = build_switch_family({
  profile = "switches-presence-wave11-tuya-2gang",
  prefix = "tuya_ps_2",
  gang_count = 2,
  turn_on = { none = 0, all = 1, on_ch1 = 2, on_ch2 = 3 },
  turn_off = { none = 0, all = 1, off_ch1 = 2, off_ch2 = 3 },
  emitters = {
    countdown_one = emit.tuyaPsTwoCountdownOne(),
    countdown_two = emit.tuyaPsTwoCountdownTwo(),
    relay_status = emit.tuyaPsTwoRelayStatus(),
    light_mode = emit.tuyaPsTwoLightMode(),
    delays_time = emit.tuyaPsTwoDelaysTime(),
    sensitivity = emit.tuyaPsTwoSensitivity(),
    turn_on = emit.tuyaPsTwoTurnOnPerson(),
    turn_off = emit.tuyaPsTwoTurnOffPerson(),
  },
})

register_device_definition(two_gang, {
  device_helpers.create_fingerprint("_TZE28C1000000_jaunkx9g", "TS0601"),
})

local three_gang = build_switch_family({
  profile = "switches-presence-wave11-tuya-3gang",
  prefix = "tuya_ps_3",
  gang_count = 3,
  turn_on = {
    none = 0, all = 1, on_ch1 = 2, on_ch2 = 3, on_ch3 = 4,
    on_1_2ch = 5, on_2_3ch = 6, on_1_3ch = 7,
  },
  turn_off = {
    none = 0, all = 1, off_ch1 = 2, off_ch2 = 3, off_ch3 = 4,
    off_1_2ch = 5, off_2_3ch = 6, off_1_3ch = 7,
  },
  emitters = {
    countdown_one = emit.tuyaPsThreeCountdownOne(),
    countdown_two = emit.tuyaPsThreeCountdownTwo(),
    countdown_three = emit.tuyaPsThreeCountdownThree(),
    relay_status = emit.tuyaPsThreeRelayStatus(),
    light_mode = emit.tuyaPsThreeLightMode(),
    delays_time = emit.tuyaPsThreeDelaysTime(),
    sensitivity = emit.tuyaPsThreeSensitivity(),
    turn_on = emit.tuyaPsThreeTurnOnPerson(),
    turn_off = emit.tuyaPsThreeTurnOffPerson(),
  },
})

register_device_definition(three_gang, {
  device_helpers.create_fingerprint("_TZE28C1000000_usmqzgdm", "TS0601"),
})

return {
  id = "ef00.presence.wave11.switch",
  registrations = registrations,
}
