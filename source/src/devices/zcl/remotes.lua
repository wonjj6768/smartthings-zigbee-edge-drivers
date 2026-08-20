-- 버튼/리모컨 디바이스 정의

local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local emit = require "emitters"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local function battery_percent_from_voltage(voltage)
  if type(voltage) ~= "number" then
    return voltage
  end

  local percent = math.floor((((voltage - 2.0) / 1.0) * 100) + 0.5)
  if percent < 0 then
    return 0
  end
  if percent > 100 then
    return 100
  end

  return percent
end

local function passive_battery_clusters()
  return {
    zcl.cluster_attribute(zcl.CLUSTER_POWER_CONFIGURATION, zcl.ATTR_BATTERY_PERCENTAGE_REMAINING, {
      name = "battery",
      endpoint = 1,
      emit = emit.battery(),
      scale = 2,
    }),
    zcl.cluster_attribute(zcl.CLUSTER_POWER_CONFIGURATION, zcl.ATTR_BATTERY_VOLTAGE, {
      name = "battery",
      endpoint = 1,
      emit = emit.battery(),
      scale = 10,
      from_device = battery_percent_from_voltage,
    }),
  }
end

local function passive_battery_voltage_cluster()
  return zcl.cluster_attribute(zcl.CLUSTER_POWER_CONFIGURATION, zcl.ATTR_BATTERY_VOLTAGE, {
    name = "battery_voltage",
    endpoint = 1,
    emit = emit.voltage(),
    scale = 10,
  })
end

local function build_remote_definition(profile, include_voltage)
  local battery_clusters = passive_battery_clusters()
  local definition = {
    profile = profile,
    button_actions = { "pushed", "double", "held" },
    zcl_clusters = {
      zcl.tuya_magic_packet(),
      battery_clusters[1],
      battery_clusters[2],
    },
  }

  if include_voltage == true then
    definition.zcl_clusters[#definition.zcl_clusters + 1] = passive_battery_voltage_cluster()
  end

  return definition
end

local remote_1 = build_remote_definition("buttons-button-1-battery")
local remote_1_voltage = build_remote_definition("buttons-button-1-battery-voltage", true)
local remote_1_double_only_voltage = build_remote_definition("buttons-button-1-battery-voltage", true)
local remote_2 = build_remote_definition("buttons-button-2-battery")
local remote_3 = build_remote_definition("buttons-button-3-battery")
local remote_4_voltage = build_remote_definition("buttons-button-4-battery-voltage", true)
local remote_5 = build_remote_definition("buttons-button-5-battery")
local remote_6 = build_remote_definition("buttons-button-6-battery")

remote_1_double_only_voltage.button_actions = { "pushed", "double" }

register_device_definition(remote_1, device_helpers.create_fingerprints("TS0041", {
  "_TZ3000_mrpevh8p",
  "_TZ3000_5bpeda8u",
  "_TZ3000_b4awzgct",
  "_TZ3000_qgwcxxws",
  "_TZ3000_6km7djcm",
  "_TZ3000_4upl1fcj",
  "_TZ3000_filhl5b7",
  "_TZ3000_axpdxqgu",
  "_TZ3000_yj6k7vfo",
}))

register_device_definition(remote_1, device_helpers.create_fingerprints("TS0041", {
  "_TZ3000_rsqqkdxv",
  "_TZ3000_22ugzkme",
  "_TZ3000_kxaow5ki",
  "_TZ3000_adndolvx",
  "_TZ3000_piyhhake",
  "_TZ3400_keyjqthh",
  "_TZ3000_an5rjiwd",
  "_TZ3400_tk3s5tyg",
  "_TZ3000_tk3s5tyg",
  "_TZ3000_xrqsdxq6",
  "_TZ3000_peszejy7",
  "_TZ3000_vn88ezar",
  "_TZ3000_kccru4oi",
}))

register_device_definition(remote_1_voltage, device_helpers.create_fingerprints("TS0041A", {
  "_TYZB01_4qw4rl1u",
  "_TYZB01_1xktopx6",
}))

register_device_definition(remote_1, device_helpers.create_fingerprints("TS0041A", {
  "_TYZB01_ub7urdza",
}))

register_device_definition(remote_1, device_helpers.create_fingerprints("TS004F", {
  "_TZ3000_krwtzhfd",
}))

register_device_definition(remote_1_double_only_voltage, device_helpers.create_fingerprints("TS0041", {
  "_TZ3000_fa9mlvja",
}))

register_device_definition(remote_2, device_helpers.create_fingerprints("TS0042", {
  "_TZ3000_dfgbtub0",
  "_TZ3000_5e235jpa",
  "_TZ3000_cllghx1k",
}))

register_device_definition(remote_2, device_helpers.create_fingerprints("TS0042", {
  "_TZ3000_kt7obmnn",
  "_TZ3000_adkvzooy",
  "_TZ3000_fkvaniuu",
  "_TZ3000_t8hzpgnd",
  "_TZ3000_tzvbimpq",
  "_TZ3000_i3rjdrwu",
  "_TYZB02_keyjhapk",
  "_TZ3400_keyjhapk",
  "_TZ3000_h1c2eamp",
  "_TZ3000_owgcnkrh",
  "_TZ3000_v8jvcwsx",
  "_TZ3000_xr7itfxq",
  "_TZ3000_1yyjhvwd",
}))

register_device_definition(remote_3, device_helpers.create_fingerprints("TS0043", {
  "_TZ3000_gbm10jnj",
  "_TZ3000_1kmurvlx",
  "_TZ3000_9zc1limb",
}))

register_device_definition(remote_3, device_helpers.create_fingerprints("TS0043", {
  "_TZ3000_sj7jbgks",
  "_TZ3000_vm5gcsdq",
  "_TZ3000_mutfmn4u",
  "_TZ3000_ngsph3oj",
  "_TZ3000_famkxci2",
  "_TYZB02_key8kk7r",
  "_TZ3000_w8jwkczz",
  "_TZ3400_key8kk7r",
  "_TZ3000_qzjcsmar",
  "_TZ3000_bi6lpsew",
  "_TZ3000_imnwsek2",
  "_TZ3000_rrjr1q0u",
  "_TZ3000_w4thianr",
  "_TZ3000_a7ouggvs",
  "_TZ3000_yw5tvzsk",
}))

register_device_definition(remote_4_voltage, device_helpers.create_fingerprints("TS0044", {
  "_TZ3000_a4xycprs",
  "_TZ3000_dziaict4",
  "_TZ3000_j61x9rxn",
  "_TZ3000_mh9px7cq",
  "_TZ3000_5tqxpine",
  "_TZ3000_u3nv1jwk",
  "_TZ3000_bgtzm4ny",
  "_TZ3000_kfu8zapd",
  "_TZ3000_ee8nrt2l",
  "_TZ3000_xwuveizv",
}))

register_device_definition(remote_4_voltage, device_helpers.create_fingerprints("TS0044", {
  "_TZ3000_g7eeean4",
  "_TZ3000_j70oanab",
  "_TZ3000_zgyzgdua",
  "_TZ3000_9orwkl3t",
  "_TZ3000_pd9mpyh4",
  "_TZ3000_wbfgbpxq",
  "_TZ3000_ufhtxr59",
  "_TZ3000_wkai4ga5",
  "_TZ3000_abci1hiu",
  "_TZ3000_vp6clf9d",
  "_TZ3000_dku2cfsc",
  "_TYZB01_cnlmkhbk",
  "_TZ3000_uaa99arv",
  "_TZ3000_laeia8fo",
  "_TZ3000_1hypixdr",
}))

register_device_definition(remote_5, device_helpers.create_fingerprints("TS0045", {
  "_TZ3000_qfhhb5y4",
}))

register_device_definition(remote_6, device_helpers.create_fingerprints("TS0046", {
  "_TZ3000_iszegwpd",
  "_TZ3000_nrfkrgf4",
}))

return device_definitions
