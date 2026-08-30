-- ZCL 온습도 센서 정의
-- zigbee-herdsman-converters 의 Tuya TS0201/TS0222 온습도 계열을 기준으로 포팅

local zcl = require "protocol.zcl"
local device_helpers = require "contracts.helpers.family"

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

  if options.battery_voltage then
    clusters[#clusters + 1] = zcl.battery_voltage()
  end

  if options.illuminance then
    clusters[#clusters + 1] = zcl.illuminance()
  end

  if options.tuya_magic then
    table.insert(clusters, 1, zcl.tuya_magic_packet())
  end

  return {
    profile = profile,
    zcl_clusters = clusters,
  }
end

local function build_illuminance_battery_clusters(options)
  options = options or {}

  local clusters = {
    zcl.illuminance(),
    zcl.battery(),
  }
  if options.tuya_magic then
    table.insert(clusters, 1, zcl.tuya_magic_packet())
  end

  return {
    profile = options.profile,
    zcl_clusters = clusters,
  }
end

local temp_humidity_battery_profile = "sensors-temp-humidity-battery"
local temp_humidity_battery_voltage_profile = "sensors-temp-humidity-battery-voltage"
local illuminance_temp_humidity_battery_profile = "sensors-illuminance-temp-humidity-battery"
local illuminance_battery_profile = "sensors-illuminance-battery"

register_device_definition(build_temp_humidity_clusters({
  profile = temp_humidity_battery_voltage_profile,
  battery_voltage = true,
}), {
  device_helpers.create_fingerprint("LINCUKOO", "SZT06"),
})

-- TS0201 표준형
register_device_definition(build_temp_humidity_clusters({
  profile = temp_humidity_battery_voltage_profile,
  battery_voltage = true,
  tuya_magic = true,
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
  profile = temp_humidity_battery_voltage_profile,
  battery_voltage = true,
}), {
  device_helpers.create_fingerprint("eWeLink", "SNZB-02"),
})

-- Current Z2M has no exact manufacturerName + modelID contract for these
-- legacy pairs. Keep them isolated until hardware identity and cluster logs exist.
register_device_definition(build_temp_humidity_clusters({
  profile = "sensors-temp-humidity-battery-legacy-pending",
}), {
  device_helpers.create_fingerprint("Zbeacon", "TS0202"),
  device_helpers.create_fingerprint("Zbeacon", "TS0203"),
})

register_device_definition(build_temp_humidity_clusters({
  profile = temp_humidity_battery_profile,
}), device_helpers.create_fingerprints("SNZB-02", {
  "_TZ3000_utwgoauk",
}))

register_device_definition(build_temp_humidity_clusters({
  profile = temp_humidity_battery_voltage_profile,
  battery_voltage = true,
  tuya_magic = true,
}), device_helpers.create_fingerprints("TY0201", {
  "_TZ3000_bjawzodf",
  "_TZ3000_zl1kmjqx",
}))

-- TS0201 계열 파생형: WSD500A / TH02Z
register_device_definition(build_temp_humidity_clusters({
  profile = temp_humidity_battery_voltage_profile,
  battery_voltage = true,
  tuya_magic = true,
}), device_helpers.create_fingerprints("TS0201", {
  "_TZ3000_bguser20",
  "_TZ3000_yd2e749y",
  "_TZ3000_6uzkisv2",
  "_TZ3000_xr3htd96",
  "_TZ3000_fllyghyj",
  "_TZ3000_saiqcn0y",
  "_TZ3000_bjawzodf",
}))

-- TS0201 계열 파생형: IH-K009 / RSH-HS06_1
register_device_definition(build_temp_humidity_clusters({
  profile = temp_humidity_battery_voltage_profile,
  battery_voltage = true,
  tuya_magic = true,
}), device_helpers.create_fingerprints("TS0201", {
  "_TZ3000_dowj6gyi",
  "_TZ3000_8ybe88nf",
  "_TZ3000_akqdg6g7",
  "_TZ3000_zl1kmjqx",
}))

-- SM0201 LED 화면형
register_device_definition(build_temp_humidity_clusters({
  profile = temp_humidity_battery_voltage_profile,
  battery_voltage = true,
}), device_helpers.create_fingerprints("SM0201", {
  "_TYZB01_cbiezpds",
  "_TYZB01_zqvwka4k",
}))

-- Cleverio SS300 exact: Z2M exposes no battery voltage for this variant.
register_device_definition(build_temp_humidity_clusters({
  profile = temp_humidity_battery_profile,
}), device_helpers.create_fingerprints("SM0201", {
  "_TYZB01_lzrhtcxu",
}))

-- SZT06 V2.0 mini 온습도 센서
register_device_definition(build_temp_humidity_clusters({
  profile = temp_humidity_battery_voltage_profile,
  battery_voltage = true,
}), device_helpers.create_fingerprints("TS0601", {
  "_TZ3000_kkerjand",
}))

-- TS0201 humidity x10 변종
register_device_definition(build_temp_humidity_clusters({
  profile = temp_humidity_battery_voltage_profile,
  humidity_scale = 10,
  battery_voltage = true,
  tuya_magic = true,
}), device_helpers.create_fingerprints("TS0201", {
  "_TZ3210_ncw88jfq",
  "_TZ3000_ywagc4rj",
  "_TZ3000_isw9u95y",
  "_TZ3000_yupc0pb7",
}))

-- KCTW1Z LCD 화면형, humidity x10
register_device_definition(build_temp_humidity_clusters({
  profile = "sensors-temp-humidity-battery-voltage-kctw1z-pending",
  humidity_scale = 10,
  battery_voltage = true,
  tuya_magic = true,
}), device_helpers.create_fingerprints("TS0201", {
  "_TZ3000_itnrsufe",
}))

-- TS0201 계열 LCD 경보형 + 조도
register_device_definition(build_temp_humidity_clusters({
  profile = "sensors-illuminance-temp-humidity-battery-lcz030-pending",
  illuminance = true,
  tuya_magic = true,
}), device_helpers.create_fingerprints("TS0201", {
  "_TZ3000_qaaysllp",
}))

-- TS0222 온습도 + 조도, humidity x10
register_device_definition(build_temp_humidity_clusters({
  profile = illuminance_temp_humidity_battery_profile,
  humidity_scale = 10,
  illuminance = true,
  tuya_magic = true,
}), device_helpers.create_fingerprints("TS0222", {
  "_TZ3000_kky16aay",
  "_TZE204_myd45weu",
  "_TZ3000_ceplrhnu",
}))

-- TS0222 온습도 + 조도 flower sensor 변종
register_device_definition(build_temp_humidity_clusters({
  profile = illuminance_temp_humidity_battery_profile,
  illuminance = true,
  tuya_magic = true,
}), device_helpers.create_fingerprints("TS0222", {
  "_TZ3000_t9qqxn70",
}))

register_device_definition(build_temp_humidity_clusters({
  profile = illuminance_temp_humidity_battery_profile,
  illuminance = true,
}), device_helpers.create_fingerprints("TS0222", {
  "_TYZB01_ftdkanlj",
  "_TYZB01_kvwjujy9",
}))

register_device_definition(build_temp_humidity_clusters({
  profile = illuminance_temp_humidity_battery_profile,
  illuminance = true,
  tuya_magic = true,
}), device_helpers.create_fingerprints("TS0222", {
  "_TZ3000_ubuikmgo",
}))

register_device_definition(build_temp_humidity_clusters({
  profile = illuminance_temp_humidity_battery_profile,
  illuminance = true,
}), {
  device_helpers.create_fingerprint("easyiot", "ZB-LTH01"),
})

register_device_definition(build_temp_humidity_clusters({
  profile = "sensors-illuminance-temp-humidity-battery-konke-pending",
  illuminance = true,
}), device_helpers.create_fingerprints("TS0222", {
  "_TYZB01_fi5yftwv",
}))

-- TS0222 조도 + 배터리 전용 (ZG-106Z)
register_device_definition(build_illuminance_battery_clusters({
  profile = illuminance_battery_profile,
  tuya_magic = true,
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

return {
  id = "zcl.sensors.general",
  registrations = device_definitions,
}
