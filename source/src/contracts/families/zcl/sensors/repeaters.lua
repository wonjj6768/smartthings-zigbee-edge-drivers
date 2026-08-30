local device_helpers = require "contracts.helpers.family"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local repeater = {
  profile = "network-repeater",
}

register_device_definition(repeater, device_helpers.create_fingerprints("TS0207", {
  "_TZ3000_5k5vh43t",
  "_TZ3000_gszjt2xx",
  "_TZ3000_kxlmv9ag",
  "_TZ3000_m0vaazab",
  "_TZ3000_misw04hq",
  "_TZ3000_n0lphcok",
  "_TZ3000_nkkl7uzv",
  "_TZ3000_nlsszmzl",
  "_TZ3000_r80pzsb9",
  "_TZ3000_sgpbz53b",
  "_TZ3000_shopg9ss",
  "_TZ3000_ufttklsz",
  "_TZ3000_hgm6k8ku",
  "_TZ3000_mmzmkkd4",
  "_TZ3000_piuensvr",
  "_TZ3000_wlquqiiz",
  "_TZ3000_wmlc9p9z",
}))

register_device_definition(repeater, device_helpers.create_fingerprints("TS0001", {
  "_TZ3000_gdsvhfao",
  "_TZ3000_n0lphcok",
  "_TZ3000_trdx8uxs",
  "_TZ3000_wn65ixz9",
}))

register_device_definition(repeater, {
  device_helpers.create_fingerprint("Aeotec", "ZGA008"),
  device_helpers.create_fingerprint("eWeLink", "CK-BL702-ROUTER-01(7018)"),
  device_helpers.create_fingerprint("Espressif", "ZigbeeRangeExtender"),
  device_helpers.create_fingerprint("NabuCasa", "SkyConnect"),
  device_helpers.create_fingerprint("NabuCasa", "ZBT-2"),
  device_helpers.create_fingerprint("SMLIGHT", "SLZB-06M"),
  device_helpers.create_fingerprint("SMLIGHT", "SLZB-06MG24"),
  device_helpers.create_fingerprint("SMLIGHT", "SLZB-06MG26"),
  device_helpers.create_fingerprint("SMLIGHT", "SLZB-06MG26U"),
  device_helpers.create_fingerprint("SMLIGHT", "SLZB-07"),
  device_helpers.create_fingerprint("SMLIGHT", "SLZB-07MG24"),
  device_helpers.create_fingerprint("Inswift", "ZBM-MG24"),
  device_helpers.create_fingerprint("SONOFF", "DONGLE-E"),
  device_helpers.create_fingerprint("SONOFF", "Dongle-LMG21"),
  device_helpers.create_fingerprint("SONOFF", "Dongle-M"),
  device_helpers.create_fingerprint("SONOFF", "Dongle-PMG24"),
  device_helpers.create_fingerprint("SparkFun", "MGM240P"),
  device_helpers.create_fingerprint("TubesZB", "BM24"),
  device_helpers.create_fingerprint("TubesZB", "MGM24"),
  device_helpers.create_fingerprint("easyiot", "ZB-GW04"),
  device_helpers.create_fingerprint("easyiot", "ZB-GW04-1v1"),
  device_helpers.create_fingerprint("easyiot", "ZB-GW04-1v2"),
})

return {
  id = "zcl.sensors.repeaters",
  registrations = device_definitions,
}
