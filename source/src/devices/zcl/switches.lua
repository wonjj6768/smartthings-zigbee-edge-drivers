-- 스위치/아웃렛 디바이스 정의

local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local zcl_device_helpers = require "devices.zcl.helpers"

local device_definitions, register_device_definition = device_helpers.definition_registry()

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

local function build_tuya_on_off_switch(profile, count)
  local clusters = build_switch(profile, count).zcl_clusters
  append_option_clusters(clusters,
    zcl.tuya_magic_packet(),
    zcl.tuya_power_outage_memory(),
    zcl.child_lock()
  )

  return {
    profile = profile,
    zcl_clusters = clusters,
  }
end

local function build_switch_module(profile, count)
  local clusters = build_switch(profile, count).zcl_clusters
  append_option_clusters(clusters,
    zcl.switch_type(),
    zcl.countdown_timer()
  )

  return {
    profile = profile,
    zcl_clusters = clusters,
  }
end

local function build_single_power_switch(profile)
  local clusters = zcl_device_helpers.metering_clusters({
    include_switch = true,
    include_current = true,
  })
  append_option_clusters(clusters,
    zcl.power_outage_memory(),
    zcl.switch_type()
  )

  return {
    profile = profile,
    zcl_clusters = clusters,
  }
end

local function build_relay_switch(profile, count)
  local clusters = build_switch(profile, count).zcl_clusters
  append_option_clusters(clusters,
    zcl.power_outage_memory(),
    zcl.gen_on_off_switch_type()
  )

  return {
    profile = profile,
    zcl_clusters = clusters,
  }
end

local function build_dual_power_switch(profile)
  local clusters = {
    zcl_device_helpers.switch_cluster(1),
    zcl_device_helpers.switch_cluster(2, "switch2"),
  }

  local metering_clusters = zcl_device_helpers.metering_clusters({
    endpoint = 1,
    include_switch = false,
    include_current = true,
  })

  append_option_clusters(clusters,
    metering_clusters,
    zcl.power_outage_memory(),
    zcl.switch_type()
  )

  return {
    profile = profile,
    zcl_clusters = clusters,
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

local single_switch = build_switch("switches-switch-1", 1)
local single_power_switch = build_single_power_switch("switches-switch-1-power-options")
local dual_switch = build_switch("switches-switch-2", 2)
local dual_power_switch = build_dual_power_switch("switches-switch-2-power-options")
local triple_switch = build_switch("switches-switch-3", 3)
local quad_switch = build_switch("switches-switch-4", 4)
local quint_switch = build_switch("switches-switch-5", 5)
local quint_tuya_switch = build_tuya_on_off_switch("switches-switch-5-tuya-options", 5)
local six_switch = build_switch("switches-switch-6-basic", 6)
local wall_switch_module = build_switch_module("switches-switch-1-countdown-switch-type", 1)
local dual_switch_module = build_switch_module("switches-switch-2-countdown-switch-type", 2)
local triple_switch_module = build_switch_module("switches-switch-3-countdown-switch-type", 3)
local relay_1_poweron_switch_type = build_relay_switch("switches-switch-1-poweron-switch-type", 1)
local relay_2_poweron_switch_type = build_relay_switch("switches-switch-2-poweron-switch-type", 2)

register_device_definition(single_power_switch, device_helpers.create_fingerprints("TS0001", {
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
}))

register_device_definition(single_power_switch, {
  device_helpers.create_fingerprint("Nous", "B2Z"),
  device_helpers.create_fingerprint("Nous", "B5Z"),
  device_helpers.create_fingerprint("Nous", "L6Z"),
})

register_device_definition(dual_power_switch, device_helpers.create_fingerprints("TS0002", {
  "_TZ3000_aaifmpuq",
  "_TZ3000_irrmjcgi",
  "_TZ3000_huvxrx4i",
  "_TZ3000_pxfjrzyj",
}))

register_device_definition(dual_power_switch, {
  device_helpers.create_fingerprint("Nous", "B3Z"),
})

register_device_definition(single_power_switch, device_helpers.create_fingerprints("TS000F", {
  "_TZ3000_xkap8wtb",
}))

register_device_definition(single_switch, device_helpers.create_fingerprints("SM0001", {
  "_TZ3000_jcqs2mrv",
}))

register_device_definition(single_switch, device_helpers.create_fingerprints("TS0001", {
  "_TZ3000_bezfthwc",
}))

register_device_definition(wall_switch_module, device_helpers.create_fingerprints("TS0001", {
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

register_device_definition(single_switch, device_helpers.create_fingerprints("TS0001", {
  "_TZ3000_8n7lqbm0",
  "_TZ3000_ctftgjwb",
  "_TZ3000_g8n1n7lg",
  "_TZ3000_udl7uyd2",
  "_TZ3000_bmqxalil",
  "_TZ3000_w1tcofu8",
  "_TZ3000_ma3mhpx2",
  "_TZ3000_wijoqjk1",
  "_TZ3000_5rpu3r0d",
}))

register_device_definition(single_switch, device_helpers.create_fingerprints("TS0001", {
  "_TZ3000_tqlv4ug4",
  "_TZ3210_tqlv4ug4",
  "_TZ3000_gjrubzje",
  "_TZ3000_tygpxwqa",
  "_TZ3000_4rbqgcuv",
  "_TZ3000_veu2v775",
  "_TZ3000_prits6g4",
  "_TZ3000_xfxpoxe0",
  "_TZ3210_9hbau615",
  "_TZ3000_afgzktgb",
  "_TZ3000_qamj2vnn",
  "_TZ3000_n6fqajob",
}))

register_device_definition(single_switch, device_helpers.create_fingerprints("TS0001", {
  "_TZ3000_myaaknbq",
  "_TZ3000_cpozgbrx",
  "_TZ3000_drc9tuqb",
  "_TZ3000_gbshwgag",
  "_TZ3000_blhvsaqf",
  "_TZ3000_pgq7ormg",
  "_TZ3000_qvmiyxuk",
  "_TZ3000_65ajyxua",
  "_TZ3000_qq9ahj6z",
  "_TZ3210_fhx7lk3d",
  "_TYZB01_4vgantdz",
  "_TYZB01_reyozfcg",
  "_TZ3000_6axxqqi2",
  "_TZ3000_dov0a3p1",
  "_TZ3000_gtdswg8k",
  "_TZ3000_majwnphg",
  "_TZ3000_qh6qjuan",
  "_TZ3000_t3s9qmmg",
  "_TZ3000_ehgouyvu",
  "_TZ3000_wrhhi5h2",
  "_TZ3000_zw7yf6yk",
}))

register_device_definition(single_switch, device_helpers.create_fingerprints("TS0011", {
  "_TZ3000_uaa34g7v",
  "_TZ3000_l8fsgo6p",
  "_TZ3000_gzvniqjb",
  "_TZ3000_abjodzas",
  "_TZ3000_hbxsdd6k",
  "_TZ3000_hhiodade",
}))

register_device_definition(single_switch, {
  device_helpers.create_fingerprint("Nous", "B1Z"),
  device_helpers.create_fingerprint("Nous", "B6Z"),
  device_helpers.create_fingerprint("Nous", "LZ3"),
  device_helpers.create_fingerprint("AVATTO", "ZWSM16-DC-1"),
})

register_device_definition(wall_switch_module, device_helpers.create_fingerprints("TS0011", {
  "_TZ3000_qmi1cfuq",
  "_TZ3000_txpirhfq",
  "_TZ3000_ji4araar",
  "_TZ3000_tw4ztbp4",
}))

register_device_definition(wall_switch_module, {
  device_helpers.create_fingerprint("AVATTO", "1gang N-ZLWSM01"),
  device_helpers.create_fingerprint("SMATRUL", "TMZ02L-16A-W"),
  device_helpers.create_fingerprint("Aubess", "TMZ02L-16A-B"),
  device_helpers.create_fingerprint("HOMMYN", "RLZBNN01"),
})

register_device_definition(single_switch, device_helpers.create_fingerprints("TS011F", {
  "_TZ3000_twqctvna",
  "_TZ3000_7issjl2q",
  "_TZ3000_bkfe0bab",
  "_TZ3000_zmy1waw6",
}))

register_device_definition(single_power_switch, device_helpers.create_fingerprints("TS011F", {
  "_TZ3000_z6fgd73r",
}))

register_device_definition(wall_switch_module, device_helpers.create_fingerprints("TS000F", {
  "_TZ3000_hktqahrq",
  "_TZ3000_m9af2l6g",
  "_TZ3000_mx3vgyea",
  "_TZ3000_skueekg3",
  "_TZ3000_dlhhrhs8",
  "_TZ3000_fdxihpp7",
}))

register_device_definition(wall_switch_module, {
  device_helpers.create_fingerprint("HOBEIAN", "ZG-301Z"),
  device_helpers.create_fingerprint("Aubess", "WHD02"),
  device_helpers.create_fingerprint("_TZ3000_hktqahrq", "WHD02"),
  device_helpers.create_fingerprint("Tuya", "iHSW02"),
  device_helpers.create_fingerprint("Tuya", "QS-zigbee-S08-16A-RF"),
})

register_device_definition(single_switch, device_helpers.create_fingerprints("TS000F", {
  "_TZ3000_hdc8bbha",
  "_TZ3218_hdc8bbha",
  "_TZ3210_a2erlvb8",
  "_TZ3210_hjxqqofs",
}))

register_device_definition(relay_1_poweron_switch_type, device_helpers.create_fingerprints("TS000F", {
  "_TZ3218_n0jsuogs",
}))

register_device_definition(metered_dual_plug, device_helpers.create_fingerprints("TS011F", {
  "_TZ3000_bep7ccew",
  "_TZ3000_gazjngjl",
  "_TZ3000_rqbjepe8",
  "_TZ3000_uwkja6z1",
  "_TZ3000_jak16dll",
  "_TZ3000_dd8wwzcy",
  "_TZ3210_bep7ccew",
  "_TZ3210_qlmnxmac",
  "_TZ3210_raqjcxo5",
  "_TZ3210_7jnk7l3k",
  "_TZ3210_yvxjawlt",
  "_TZ3210_pfbzs1an",
}))

register_device_definition(metered_dual_plug, {
  device_helpers.create_fingerprint("LUMI", "lumi.plug.acn005"),
  device_helpers.create_fingerprint("LUMI", "lumi.plug.sacn03"),
  device_helpers.create_fingerprint("Nous", "A4Z"),
})

register_device_definition(single_switch, {
  device_helpers.create_fingerprint("LUMI", "lumi.ctrl_ln1"),
  device_helpers.create_fingerprint("LUMI", "lumi.ctrl_ln1.aq1"),
  device_helpers.create_fingerprint("LUMI", "lumi.ctrl_neutral1"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.acn029"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.acn048"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.acn056"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.acn061"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.b1laus01"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.b1lacn01"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.b1nacn01"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.b1nacn02"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.b1naus01"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.b1lc04"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.b1nc01"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.l0acn1"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.l0agl1"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.l1acn1"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.l1aeu1"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.n0acn2"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.n0agl1"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.n1acn1"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.n1aeu1"),
})

register_device_definition(dual_switch, {
  device_helpers.create_fingerprint("LUMI", "lumi.ctrl_ln2"),
  device_helpers.create_fingerprint("LUMI", "lumi.ctrl_ln2.aq1"),
  device_helpers.create_fingerprint("LUMI", "lumi.ctrl_neutral2"),
  device_helpers.create_fingerprint("LUMI", "lumi.relay.c2acn01"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.acn030"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.acn047"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.acn049"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.acn057"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.b2laus01"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.b2lacn01"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.b2nacn01"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.b2nacn02"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.b2naus01"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.b2lc04"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.b2nc01"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.l2acn1"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.l2aeu1"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.n2acn1"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.n2aeu1"),
})

register_device_definition(triple_switch, {
  device_helpers.create_fingerprint("LUMI", "lumi.switch.acn031"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.acn040"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.acn054"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.acn055"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.acn058"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.acn059"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.b3l01"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.b3n01"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.l3acn1"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.l3acn3"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.n3acn1"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.n3acn3"),
  device_helpers.create_fingerprint("LUMI", "lumi.switch.n4acn4"),
})

register_device_definition(dual_switch, device_helpers.create_fingerprints("TS011F", {
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

register_device_definition(dual_switch, {
  device_helpers.create_fingerprint("HOBEIAN", "ZG-305Z"),
})

register_device_definition(dual_switch, device_helpers.create_fingerprints("TS000F", {
  "_TZ3000_m8f3z8ju",
}))

register_device_definition(relay_2_poweron_switch_type, device_helpers.create_fingerprints("TS000F", {
  "_TZ3218_sgbsg6mr",
}))

register_device_definition(dual_switch, device_helpers.create_fingerprints("TS0002", {
  "_TZ3000_01gpyda5",
  "_TZ3000_bvrlqyj7",
  "_TZ3000_7ed9cqgi",
  "_TZ3000_zmy4lslw",
  "_TZ3000_ruxexjfz",
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
  "_TZ3000_h1ipgkwn",
  "_TZ3000_tas0zemd",
  "_TZ3000_gkesadus",
  "_TZ3000_rfjctviq",
  "_TZ3000_yxmafzmd",
  "_TZ3210_a2erlvb8",
  "_TZ3210_pdnwpnz5",
  "_TYZB01_digziiav",
  "_TYZB01_zsl6z0pw",
  "_TYZB01_uqkphoed",
}))

register_device_definition(dual_switch, {
  device_helpers.create_fingerprint("HOBEIAN", "ZG-301Z-2CH"),
  device_helpers.create_fingerprint("Nous", "L13Z"),
})

register_device_definition(dual_switch, {
  device_helpers.create_fingerprint("Homeetec", "37022463-1"),
  device_helpers.create_fingerprint("RoomsAI", "37022463-2"),
})

register_device_definition(dual_switch, device_helpers.create_fingerprints("TS0012", {
  "_TZ3000_biakwrag",
  "_TZ3000_18ejxno0",
}))

register_device_definition(dual_switch, device_helpers.create_fingerprints("TS0003", {
  "_TYZB01_digziiav",
  "_TYZB01_zsl6z0pw",
  "_TYZB01_uqkphoed",
}))

register_device_definition(dual_switch, device_helpers.create_fingerprints("TS0002", {
  "_TZ3000_iwtv2jwo",
  "_TZ3210_6smingw0",
}))

register_device_definition(dual_switch, {
  device_helpers.create_fingerprint("Somfy", "ON/OFF (2CH)"),
  device_helpers.create_fingerprint("Sunricher", "ON/OFF (2CH)"),
})

register_device_definition(dual_switch_module, device_helpers.create_fingerprints("TS0012", {
  "_TZ3000_jl7qyupf",
  "_TZ3000_nPGIPl5D",
  "_TZ3000_kpatq5pq",
  "_TZ3000_ljhbw1c9",
  "_TZ3000_4zf0crgo",
}))

register_device_definition(dual_switch_module, {
  device_helpers.create_fingerprint("AVATTO", "2gang N-ZLWSM01"),
  device_helpers.create_fingerprint("AVATTO", "LZWSM16-2"),
})

register_device_definition(triple_switch, device_helpers.create_fingerprints("TS0003", {
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
  "_TZ3000_fawk5xjv",
  "_TZ3000_bvij6kod",
  "_TZ3000_aracgljk",
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

register_device_definition(triple_switch_module, device_helpers.create_fingerprints("TS0013_switch_module", {
  "_TZ3000_ypgri8yz:TS0013",
  "_TZ3000_sznawwyw:TS0013",
  "_TZ3000_avotanj3:TS0013",
  "_TZ3000_t7ugva7q:TS0013",
}))

register_device_definition(triple_switch_module, {
  device_helpers.create_fingerprint("AVATTO", "3gang N-ZLWSM01"),
  device_helpers.create_fingerprint("AVATTO", "LZWSM16-3"),
  device_helpers.create_fingerprint("Girier", "ZB08"),
})

register_device_definition(triple_switch, {
  device_helpers.create_fingerprint("HOBEIAN", "ZG-301Z-3CH"),
  device_helpers.create_fingerprint("BSEED", "TS0003"),
})

register_device_definition(triple_switch, {
  device_helpers.create_fingerprint("Homeetec", "37022474_1"),
  device_helpers.create_fingerprint("RoomsAI", "37022474_2"),
})

register_device_definition(single_switch, device_helpers.create_fingerprints("TS0003", {
  "_TYZB01_aneiicmq",
  "_TYZB01_ncutbjdi",
  "_TYZB01_u9kkqh5o",
}))

register_device_definition(quad_switch, device_helpers.create_fingerprints("TS0004", {
  "_TZ3000_ltt60asa",
  "_TZ3000_mmkbptmx",
  "_TZ3000_liygxtcq",
  "_TZ3000_mdj7kra9",
  "_TZ3000_u3oupgdy",
  "_TZ3000_imaccztn",
  "_TZ3000_a37eix1s",
  "_TZ3000_iymfxdis",
  "_TZ3000_nivavasg",
  "_TZ3000_gexniqbq",
  "_TZ3000_r9e2w7dn",
  "_TZ3000_5ajpkyq6",
  "_TZ3000_knoj8lpk",
  "_TZ3000_3n2minvf",
  "_TZ3000_tyg4yiat",
  "_TZ3210_iymfxdis",
  "_TZ3210_imaccztn",
  "_TZ3000_nsa76jai",
  "_TZ3000_wwtnshol",
  "_TZ3210_wts1g2oh",
}))

register_device_definition(six_switch, device_helpers.create_fingerprints("TS0006", {
  "_TZ3000_cvis4qmw",
}))

register_device_definition(six_switch, {
  device_helpers.create_fingerprint("AVATTO", "TS0006_1"),
})

register_device_definition(quad_switch, device_helpers.create_fingerprints("TS011F", {
  "_TZ3000_3zofvcaa",
  "_TZ3000_pvlvoxvt",
  "_TZ3000_lqb7lcq9",
  "_TZ3210_lqb7lcq9",
  "_TZ3210_urjf5u18",
  "_TZ3210_8n4dn1ne",
  "_TZ3000_qiutut5y",
}))

register_device_definition(quad_switch, {
  device_helpers.create_fingerprint("Nova Digital", "SA-WK"),
})

register_device_definition(triple_switch, device_helpers.create_fingerprints("TS011F", {
  "_TZ3000_wzauvbcs",
  "_TZ3000_oznonj5q",
  "_TZ3000_1obwwnmq",
  "_TZ3000_4uf3d0ax",
  "_TZ3000_vzopcetz",
  "_TZ3000_vmpbygs5",
  "_TZ3000_dlug3kbc",
  "_TZ3000_9tg32trw",
}))

register_device_definition(triple_switch, {
  device_helpers.create_fingerprint("Mifra", "KS-604S"),
})

register_device_definition(quint_switch, device_helpers.create_fingerprints("TS011F", {
  "_TZ3000_air9m6af",
  "_TZ3000_9djocypn",
  "_TZ3000_bppxj3sf",
  "_TZ3000_in5s3wn1",
  "_TZ3000_wbloefbf",
}))

register_device_definition(quint_tuya_switch, device_helpers.create_fingerprints("TS011F", {
  "_TZ3000_cfnprab5",
  "_TZ3000_o005nuxx",
  "_TZ3000_gdyjfvgm",
  "_TZ3000_pl5v1yyy",
  "_TZ3000_djgzdba9",
}))

return device_definitions
