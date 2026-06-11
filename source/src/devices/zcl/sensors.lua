-- ZCL 온습도 센서 정의
-- zigbee-herdsman-converters 의 Tuya TS0201/TS0222 온습도 계열을 기준으로 포팅

local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local function build_temp_humidity_clusters(options)
  options = options or {}

  local humidity_scale = options.humidity_scale
  local profile = options.profile
  local clusters = {
    zcl.temperature(),
    humidity_scale ~= nil and humidity_scale ~= 100 and
      zcl.humidity({ scale = humidity_scale }) or
      zcl.humidity(),
    zcl.battery(),
  }

  if options.illuminance then
    clusters[#clusters + 1] = zcl.illuminance()
  end

  return {
    profile = profile,
    zcl_clusters = clusters,
  }
end

local function build_illuminance_battery_clusters(options)
  options = options or {}

  return {
    profile = options.profile,
    zcl_clusters = {
      zcl.illuminance(),
      zcl.battery(),
    },
  }
end

local temp_humidity_battery_profile = "sensors-temp-humidity-battery"
local illuminance_temp_humidity_battery_profile = "sensors-illuminance-temp-humidity-battery"
local illuminance_battery_profile = "sensors-illuminance-battery"

-- TS0201 표준형
register_device_definition(build_temp_humidity_clusters({
  profile = temp_humidity_battery_profile,
}), device_helpers.create_fingerprints("TS0201", {
  "_TZ3210_alxkwn0h",
  "_TZ3000_0s1izerx",
  "_TZ3000_v1w2k9dd",
  "_TZ3000_rdhukkmi",
  "Zbeacon",
  "_TZ3000_lqmvrwa2",
  "_TZ3000_f2bw0b6k",
  "_TZ3000_mxzo5rhf",
  "_TZ3000_1twfmkcc",
  "_TZ3000_fie1dpkm",
  "_TZ3000_bgsigers",
  "_TYZB01_ujfk3xd9",
  "_TZ3000_82ptnsd4",
  "_TZ3000_amqudjr0",
  "_TZ3000_lbtpiody",
  "_TZ3000_rusu2vzb",
  "_TZ3000_zfirri2d",
  "_TZ3000_yujem9ee",
}))

register_device_definition(build_temp_humidity_clusters({
  profile = temp_humidity_battery_profile,
}), {
  device_helpers.create_fingerprint("Zbeacon", "TS0202"),
  device_helpers.create_fingerprint("Zbeacon", "TS0203"),
  device_helpers.create_fingerprint("eWeLink", "SNZB-02"),
  device_helpers.create_fingerprint("BlitzWolf", "BW-IS4"),
  device_helpers.create_fingerprint("Danfoss", "014G2480"),
  device_helpers.create_fingerprint("Nedis", "ZBSC10WT"),
  device_helpers.create_fingerprint("Tuya", "TS0201_1"),
  device_helpers.create_fingerprint("Tuya", "ZTH01/ZTH02"),
  device_helpers.create_fingerprint("Tuya", "ZY-ZTH02"),
  device_helpers.create_fingerprint("SEDEA", "eTH730"),
  device_helpers.create_fingerprint("Moes", "ZSS-S01-TH"),
  device_helpers.create_fingerprint("Tuya", "HS09"),
  device_helpers.create_fingerprint("Tuya", "ZTH05_1"),
  device_helpers.create_fingerprint("Tuya", "TS0201_2"),
})

register_device_definition(build_temp_humidity_clusters({
  profile = temp_humidity_battery_profile,
}), device_helpers.create_fingerprints("SNZB-02", {
  "_TZ3000_utwgoauk",
}))

register_device_definition(build_temp_humidity_clusters({
  profile = temp_humidity_battery_profile,
}), device_helpers.create_fingerprints("TY0201", {
  "_TZ3000_bjawzodf",
  "_TZ3000_zl1kmjqx",
}))

-- TS0201 계열 파생형: WSD500A / TH02Z
register_device_definition(build_temp_humidity_clusters({
  profile = temp_humidity_battery_profile,
}), device_helpers.create_fingerprints("TS0201", {
  "_TZ3000_bguser20",
  "_TZ3000_yd2e749y",
  "_TZ3000_6uzkisv2",
  "_TZ3000_xr3htd96",
  "_TZ3000_fllyghyj",
  "_TZ3000_saiqcn0y",
  "_TZ3000_bjawzodf",
}))

register_device_definition(build_temp_humidity_clusters({
  profile = temp_humidity_battery_profile,
}), {
  device_helpers.create_fingerprint("Tuya", "TH02Z"),
})

-- TS0201 계열 파생형: IH-K009 / RSH-HS06_1
register_device_definition(build_temp_humidity_clusters({
  profile = temp_humidity_battery_profile,
}), device_helpers.create_fingerprints("TS0201", {
  "_TZ3000_dowj6gyi",
  "_TZ3000_8ybe88nf",
  "_TZ3000_akqdg6g7",
  "_TZ3000_zl1kmjqx",
}))

register_device_definition(build_temp_humidity_clusters({
  profile = temp_humidity_battery_profile,
}), {
  device_helpers.create_fingerprint("Tuya", "RSH-HS06_1"),
})

-- SM0201 LED 화면형
register_device_definition(build_temp_humidity_clusters({
  profile = temp_humidity_battery_profile,
}), device_helpers.create_fingerprints("SM0201", {
  "_TYZB01_cbiezpds",
  "_TYZB01_zqvwka4k",
  "_TYZB01_lzrhtcxu",
}))

-- SZT06 V2.0 mini 온습도 센서
register_device_definition(build_temp_humidity_clusters({
  profile = temp_humidity_battery_profile,
}), device_helpers.create_fingerprints("TS0601", {
  "_TZ3000_kkerjand",
}))

-- TS0201 humidity x10 변종
register_device_definition(build_temp_humidity_clusters({
  profile = temp_humidity_battery_profile,
  humidity_scale = 10,
}), device_helpers.create_fingerprints("TS0201", {
  "_TZ3210_ncw88jfq",
  "_TZ3000_ywagc4rj",
  "_TZ3000_isw9u95y",
  "_TZ3000_yupc0pb7",
}))

register_device_definition(build_temp_humidity_clusters({
  profile = temp_humidity_battery_profile,
  humidity_scale = 10,
}), {
  device_helpers.create_fingerprint("Tuya", "TH09Z"),
})

-- KCTW1Z LCD 화면형, humidity x10
register_device_definition(build_temp_humidity_clusters({
  profile = temp_humidity_battery_profile,
  humidity_scale = 10,
}), device_helpers.create_fingerprints("TS0201", {
  "_TZ3000_itnrsufe",
}))

-- TS0201 계열 LCD 경보형 + 조도
register_device_definition(build_temp_humidity_clusters({
  profile = illuminance_temp_humidity_battery_profile,
  illuminance = true,
}), device_helpers.create_fingerprints("TS0201", {
  "_TZ3000_qaaysllp",
}))

-- TS0222 온습도 + 조도, humidity x10
register_device_definition(build_temp_humidity_clusters({
  profile = illuminance_temp_humidity_battery_profile,
  humidity_scale = 10,
  illuminance = true,
}), device_helpers.create_fingerprints("TS0222", {
  "_TZ3000_kky16aay",
  "_TZE204_myd45weu",
  "_TZ3000_ceplrhnu",
}))

-- TS0222 온습도 + 조도 flower sensor 변종
register_device_definition(build_temp_humidity_clusters({
  profile = illuminance_temp_humidity_battery_profile,
  illuminance = true,
}), device_helpers.create_fingerprints("TS0222", {
  "_TZ3000_t9qqxn70",
  "_TYZB01_fi5yftwv",
  "_TYZB01_ftdkanlj",
  "_TYZB01_kvwjujy9",
}))

-- TS0222 조도 + 배터리 전용 (ZG-106Z)
register_device_definition(build_illuminance_battery_clusters({
  profile = illuminance_battery_profile,
}), {
  device_helpers.create_fingerprint("HOBEIAN", "ZG-106Z"),
})

-- TS0222 조도 + 배터리 전용 (일반 light sensor)
register_device_definition(build_illuminance_battery_clusters({
  profile = illuminance_battery_profile,
}), device_helpers.create_fingerprints("TS0222", {
  "_TZ3000_8uxxzz4b",
  "_TZ3000_9kbbfeho",
  "_TZ3000_l6rsaipj",
  "_TYZB01_4mdqxxnn",
  "_TYZB01_m6ec2pgj",
  "_TZ3000_do6txrcw",
  "_TZ3000_7kscdesh",
  "_TZ3000_hy6ncvmw",
  "_TZ3000_7y90pany",
  "_TZ3000_j6adk9id",
}))

return device_definitions
