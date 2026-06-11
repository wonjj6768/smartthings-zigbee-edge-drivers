local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local zcl_device_helpers = require "devices.zcl.helpers"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local function create_model_fingerprints(manufacturer, models)
  local fingerprints = {}
  for _, model in ipairs(models) do
    fingerprints[#fingerprints + 1] = device_helpers.create_fingerprint(manufacturer, model)
  end
  return fingerprints
end

local function build_plug(profile, clusters)
  return {
    profile = profile,
    zcl_clusters = clusters,
  }
end

local function build_metered_strip(profile, endpoints)
  local clusters = {}

  for index, endpoint in ipairs(endpoints) do
    clusters[#clusters + 1] = zcl.switch({
      endpoint = endpoint,
      component = index == 1 and "main" or ("switch" .. tostring(index)),
    })
  end

  zcl_device_helpers.append_clusters(clusters,
    zcl_device_helpers.metering_clusters({
      endpoint = endpoints[1],
      include_switch = false,
      include_current = true,
    }),
    zcl.power_on_behavior()
  )

  return build_plug(profile, clusters)
end

local function build_metering_clusters(include_current)
  return zcl_device_helpers.metering_clusters({
    include_switch = true,
    include_current = include_current,
  })
end

local switch_only_plug = build_plug("plugs-switch", {
  zcl.switch(),
})

local dual_usb_socket = build_plug("plugs-switch-2", {
  zcl.switch({
    endpoint = 1,
    component = "main",
  }),
  zcl.switch({
    endpoint = 7,
    component = "switch2",
  }),
})

local metered_plug = build_plug("plugs-switch-power-energy-voltage", build_metering_clusters(false))

local metered_plug_current = build_plug("plugs-switch-power-energy-voltage-current", build_metering_clusters(true))
local metered_strip_three = build_metered_strip("plugs-switch-3-power-energy-voltage-current", { 1, 2, 3 })

local five_switch_plug = {
  profile = "plugs-switch-5",
  zcl_clusters = zcl.multi_switch({ 1, 2, 3, 4, 7 }),
}

register_device_definition(switch_only_plug, device_helpers.create_fingerprints("TS011F", {
  "_TZ3000_oiymh3qu",
  "_TZ3000_uyrhiafs",
}))

register_device_definition(switch_only_plug, device_helpers.create_fingerprints("TS0101", {
  "_TZ3000_br3laukf",
  "_TZ3000_pnzfdr9y",
  "_TYZB01_ijihzffk",
  "_TZ3210_eymunffl",
  "_TZ3210_tfxwxklq",
  "_TZ3210_2dfy6tol",
}))

register_device_definition(switch_only_plug, {
  device_helpers.create_fingerprint("LoraTap", "RR400ZB"),
  device_helpers.create_fingerprint("LoraTap", "SP400ZB"),
  device_helpers.create_fingerprint("Larkkey", "PS080"),
  device_helpers.create_fingerprint("Mercator Ikuü", "SPBS01G"),
  device_helpers.create_fingerprint("Mercator Ikuü", "SISW01"),
})

register_device_definition(dual_usb_socket, device_helpers.create_fingerprints("TS0108", {
  "_TYZB01_7yidyqxd",
}))

register_device_definition(dual_usb_socket, {
  device_helpers.create_fingerprint("Larkkey", "PS580"),
})

register_device_definition(switch_only_plug, device_helpers.create_fingerprints("TS011F", {
  "_TZ3000_wxtp7c5y",
  "_TYZB01_mtunwanm",
}))

register_device_definition(switch_only_plug, device_helpers.create_fingerprints("TS011F", {
  "_TZ3000_hyfvrar3",
  "_TZ3000_v1pdxuqq",
  "_TZ3000_8a833yls",
  "_TZ3000_bfn1w0mm",
  "_TZ3000_nzkqcvvs",
  "_TZ3000_rtcrrvia",
  "_TZ3000_ysiog9xi",
  "_TZ3000_o1jzcxou",
  "_TZ3210_nhqka112",
}))

register_device_definition(switch_only_plug, device_helpers.create_fingerprints("TS011F", {
  "_TZ3000_8fdayfch",
  "_TZ3000_1hwjutgo",
  "_TZ3000_lnggrqqi",
  "_TZ3000_tvuarksa",
}))

register_device_definition(switch_only_plug, device_helpers.create_fingerprints("TS011F", {
  "_TZ3000_00mk2xzy",
  "_TZ3000_plyvnuf5",
  "_TZ3000_wamqdr3f",
  "_TZ3000_b1q8kwmh",
}))

register_device_definition(metered_plug, device_helpers.create_fingerprints("TS011F", {
  "_TZ3000_4ux0ondb",
  "_TZ3000_b28wrpvx",
  "_TZ3000_2uollq9d",
  "_TZ3000_cehuw1lw",
  "_TZ3210_5ct6e7ye",
  "_TZ3000_2putqrmw",
  "_TZ3000_ksw8qtmt",
  "_TZ3000_yujkchbz",
  "_TZ3000_ss98ec5d",
  "_TZ3000_okaz9tjs",
  "_TZ3000_y4ona9me",
  "_TZ3000_266azbg3",
  "_TZ3000_3ias4w4o",
  "_TZ3210_ddigca5n",
  "_TZ3000_ww6drja5",
  "_TZ3210_rwmitwj4",
  "Zbeacon",
  "_TZ3000_gjnozsaz",
  "_TZ3000_cicwjqth",
  "_TZ3210_jlf1nepw",
  "_TZ3000_cjrngdr3",
  "_TZ3210_cjrngdr3",
  "_TZ3000_amdymr7l",
  "_TZ3000_zloso4jk",
  "_TZ3210_w0qqde0g",
}))

register_device_definition(metered_plug, {
  device_helpers.create_fingerprint("VIKEFON", "TS011F"),
  device_helpers.create_fingerprint("NEO Coolcam", "PLUG-001SPB2"),
  device_helpers.create_fingerprint("NEO", "PLUG-001SPB2"),
  device_helpers.create_fingerprint("LELLKI", "TS011F_plug"),
  device_helpers.create_fingerprint("BlitzWolf", "BW-SHP15"),
  device_helpers.create_fingerprint("BlitzWolf", "BW-SHP13"),
  device_helpers.create_fingerprint("MatSee Plus", "PJ-ZSW01"),
  device_helpers.create_fingerprint("MODEMIX", "MOD037"),
  device_helpers.create_fingerprint("MODEMIX", "MOD048"),
  device_helpers.create_fingerprint("Coswall", "CS-AJ-DE2U-ZG-11"),
  device_helpers.create_fingerprint("Aubess", "TS011F_plug_1"),
  device_helpers.create_fingerprint("AOYAN", "TS011F_AOYAN"),
  device_helpers.create_fingerprint("Nous", "A1Z"),
  device_helpers.create_fingerprint("Nous", "A6Z"),
  device_helpers.create_fingerprint("Nous", "A6Z_polling"),
  device_helpers.create_fingerprint("Nous", "A9Z"),
  device_helpers.create_fingerprint("Nous", "A10Z"),
  device_helpers.create_fingerprint("Moes", "Moes_plug"),
  device_helpers.create_fingerprint("Moes", "ZK-EU"),
  device_helpers.create_fingerprint("Elivco", "LSPA9"),
  device_helpers.create_fingerprint("PSMART", "T440"),
  device_helpers.create_fingerprint("Girier", "JR-ZPM01"),
  device_helpers.create_fingerprint("Nous", "A7Z"),
  device_helpers.create_fingerprint("Haozee", "HT-SP-ZB-01"),
  device_helpers.create_fingerprint("GreenSun", "HSC-ZW-EU"),
  device_helpers.create_fingerprint("MatSee Plus", "PJ-MINI-ZSW01"),
  device_helpers.create_fingerprint("Nedis", "ZBPO130FWT"),
  device_helpers.create_fingerprint("NEO", "NAS-WR01B"),
})

register_device_definition(metered_plug, device_helpers.create_fingerprints("TS011F", {
  "_TZ3000_3uimvkn6",
  "_TZ3000_j1v25l17",
  "_TZ3000_ynmowqk2",
  "_TZ3000_0yxeawjt",
}))

register_device_definition(metered_plug_current, device_helpers.create_fingerprints("TS0121", {
  "_TYZB01_iuepbmpv",
  "Connecte:4500990",
  "Connecte:4500991",
  "Connecte:4500992",
  "Connecte:4500993",
}))

register_device_definition(switch_only_plug, {
  device_helpers.create_fingerprint("Third Reality, Inc", "3RSP019BZ"),
})

register_device_definition(metered_plug_current, {
  device_helpers.create_fingerprint("Third Reality, Inc", "3RSP02028BZ"),
  device_helpers.create_fingerprint("Third Reality, Inc", "3RSPE01044BZ"),
})

register_device_definition(metered_plug_current, {
  device_helpers.create_fingerprint("HEIMAN", "SmartPlug"),
  device_helpers.create_fingerprint("HEIMAN", "SmartPlug-EF-3.0"),
})

register_device_definition(switch_only_plug, create_model_fingerprints("LEDVANCE", {
  "Outdoor Plug",
  "PLUG COMPACT EU T",
  "PLUG OUTDOOR EU T",
  "Plug Value",
}))

register_device_definition(metered_plug_current, create_model_fingerprints("LEDVANCE", {
  "PLUG COMPACT OUTDOOR EU EM T",
  "PLUG COMPACT EU EM T",
}))

register_device_definition(switch_only_plug, create_model_fingerprints("OSRAM", {
  "Plug 01",
  "Plug Z3",
}))

register_device_definition(metered_strip_three, device_helpers.create_fingerprints("TS011F", {
  "_TZ3000_c7nc9w3c",
  "_TZ3210_c7nc9w3c",
  "_TZ3210_6cmeijtd",
}))

return device_definitions
