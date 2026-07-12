local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local device_definitions, register_device_definition = device_helpers.definition_registry()
local contact_sensor = {
profile = "safety-contact-battery",
zcl_clusters = {
zcl.contact(),
zcl.battery(),
},
}
local contact_tamper_sensor = {
profile = "safety-contact-tamper-battery",
zcl_clusters = {
zcl.contact(),
zcl.tamper(),
zcl.battery(),
},
}
local contact_temp_sensor = {
profile = "safety-contact-temp-battery",
zcl_clusters = {
zcl.contact(),
zcl.temperature(),
zcl.battery(),
},
}
local motion_sensor = {
profile = "safety-motion-battery",
zcl_clusters = {
zcl.motion(),
zcl.battery(),
},
}
local motion_tamper_sensor = {
profile = "safety-motion-tamper-battery",
zcl_clusters = {
zcl.motion(),
zcl.tamper(),
zcl.battery(),
},
}
local motion_illuminance_sensor = {
profile = "safety-motion-illuminance-battery",
zcl_clusters = {
zcl.motion(),
zcl.illuminance(),
zcl.battery(),
},
}
local motion_illuminance_temp_humidity_tamper_sensor = {
profile = "safety-motion-illuminance-temp-humidity-tamper-battery",
zcl_clusters = {
zcl.motion(),
zcl.illuminance(),
zcl.temperature(),
zcl.humidity(),
zcl.tamper(),
zcl.battery(),
},
}
local motion_illuminance_temp_humidity_sensor = {
profile = "safety-motion-illuminance-temp-humidity-battery",
zcl_clusters = {
zcl.motion(),
zcl.illuminance(),
zcl.temperature(),
zcl.humidity(),
zcl.battery(),
},
}
local water_sensor = {
profile = "safety-water-leak-battery",
zcl_clusters = {
zcl.water(),
zcl.battery(),
},
}
local water_temp_sensor = {
profile = "safety-water-leak-temp-battery",
zcl_clusters = {
zcl.water(),
zcl.temperature(),
zcl.battery(),
},
}
local solar_rain_sensor = {
profile = "safety-water-leak-battery",
zcl_clusters = {
zcl.water(),
zcl.battery(),
},
}
local vibration_sensor = {
profile = "safety-acceleration-battery",
zcl_clusters = { zcl.motion({ emit = require("emitters").acceleration() }), zcl.battery() },
}
local smoke_sensor = {
profile = "safety-smoke-detector-battery",
zcl_clusters = {
zcl.smoke(),
zcl.battery(),
},
}
local gas_tamper_sensor = {
profile = "safety-gas-detector-tamper",
zcl_clusters = {
zcl.gas(),
zcl.tamper(),
},
}
local gas_tamper_battery_low_sensor = {
profile = "safety-gas-detector-tamper-battery-low",
zcl_clusters = {
zcl.gas(),
zcl.tamper(),
zcl.battery_low(),
},
}
local co_sensor = {
profile = "safety-co-detector-battery",
zcl_clusters = {
zcl.carbon_monoxide(),
zcl.battery(),
},
}
register_device_definition(contact_sensor, {
device_helpers.create_fingerprint("_TZ3000_qrldbmfn", "TS0203"),
device_helpers.create_fingerprint("_TZ1800_fcdjzz3s", "TY0202"),
device_helpers.create_fingerprint("HOBEIAN", "ZG-102ZA"),
device_helpers.create_fingerprint("Tesla Smart", "TSL-SEN-DOOR"),
device_helpers.create_fingerprint("Cleverio", "SS100"),
device_helpers.create_fingerprint("CR Smart Home", "TS0203"),
device_helpers.create_fingerprint("Niceboy", "ORBIS Windows & Door Sensor"),
device_helpers.create_fingerprint("Tuya", "iH-F001"),
device_helpers.create_fingerprint("Tuya", "ZD06"),
device_helpers.create_fingerprint("Tuya", "ZD08"),
device_helpers.create_fingerprint("Tuya", "MC500A"),
device_helpers.create_fingerprint("Tuya", "19DZT"),
device_helpers.create_fingerprint("Tuya", "DS04"),
device_helpers.create_fingerprint("Moes", "ZSS-JM-GWM-C-MS"),
device_helpers.create_fingerprint("Moes", "ZSS-S01-GWM-C-MS"),
device_helpers.create_fingerprint("Moes", "ZSS-X-GWM-C"),
device_helpers.create_fingerprint("Luminea", "ZX-5232"),
device_helpers.create_fingerprint("QA", "QASD1"),
device_helpers.create_fingerprint("Nous", "E3"),
device_helpers.create_fingerprint("Woox", "R7047"),
device_helpers.create_fingerprint("Wing", "WZDA1"),
device_helpers.create_fingerprint("AOYAN", "AY-101Z"),
{ manufacturer = "AOYAN  ", model = "AY-101Z" },
})
register_device_definition(contact_sensor, device_helpers.create_fingerprints("TS0203", {
"_TZ3000_26fmupbb",
"_TZ3000_2mbfxlzr",
"_TZ3000_4ugnzsli",
"_TZ3000_7d8yme6f",
"_TZ3000_8yhypbo7",
"_TZ3000_996rpfy6",
"_TZ3000_bpkijo14",
"_TZ3000_decxrtwa",
"_TZ3000_gntwytxo",
"_TZ3000_n2egfsli",
"_TZ3000_osu834un",
"_TZ3000_oxslv1c9",
"_TZ3000_rcuyhwe3",
"_TZ3000_rid8lzvo",
"_TZ3000_t3vvhrmh",
"_TZ3000_timx9ivq",
"_TZ3000_udyjylt7",
"_TZ3000_v7chgqso",
"_TZ3000_yfekcy3n",
"_TYZB01_epni2jgy",
"_TZ3000_wbrlnkm9",
}))
register_device_definition(contact_tamper_sensor, device_helpers.create_fingerprints("TS0203", {
"_TZ3210_jowhpxop",
}))
register_device_definition(contact_tamper_sensor, {
device_helpers.create_fingerprint("Linkoze", "LKDSZ001"),
})
register_device_definition(contact_temp_sensor, {
device_helpers.create_fingerprint("frient A/S", "WISZB-131"),
})
register_device_definition(motion_sensor, device_helpers.create_fingerprints("TS0203", {
"_TZ3000_pjb1ua0m",
}))
register_device_definition(motion_illuminance_sensor, device_helpers.create_fingerprints("TS0202", {
"_TYZB01_vwqnz1sn",
}))
register_device_definition(motion_sensor, device_helpers.create_fingerprints("TS0202", {
"_TYZB01_jytabjkb",
"_TZ3000_lltemgsf",
"_TYZB01_5nr7ncpl",
"_TZ3000_mg4dy6z6",
"_TZ3000_bsvqrxru",
}))
register_device_definition(motion_sensor, device_helpers.create_fingerprints("TS0202", {
"_TZ3000_hktqahrq",
"_TZ3040_wqmtjsyk",
"_TZ3000_otvn3lne",
"_TZ3000_h4wnrtck",
"_TZ3040_bb6xaihh",
"_TZ3000_qomxlryd",
"_TZ3000_jmrgyl7o",
"_TZ3000_lf56vpxj",
"_TZ3000_nss8amz9",
}))
register_device_definition(motion_sensor, device_helpers.create_fingerprints("TS0202", {
"_TZ3040_fwxuzcf4",
"_TZ3040_msl6wxk9",
"_TZ3000_mcxw5ehu",
"_TZ3000_6ygjfyll",
"_TZ3040_6ygjfyll",
"_TZ3000_msl6wxk9",
"_TZ3000_o4mkahkc",
"_TYZB01_qjqgmqxr",
"_TZ3000_mwd3c2at",
}))
register_device_definition(motion_sensor, {
device_helpers.create_fingerprint("TUYATEC-smmlguju", "RH3040"),
device_helpers.create_fingerprint("HOBEIAN", "ZG-204Z"),
device_helpers.create_fingerprint("Niceboy", "ORBIS Motion Sensor"),
device_helpers.create_fingerprint("Nedis", "ZBSM10WT"),
device_helpers.create_fingerprint("Tesla Smart", "TS0202"),
device_helpers.create_fingerprint("Mercator Ikuü", "SMA02P"),
device_helpers.create_fingerprint("Tuya", "TY-ZPR06"),
device_helpers.create_fingerprint("MiBoxer", "PIR1-ZB"),
device_helpers.create_fingerprint("Tuya", "ZMS01"),
device_helpers.create_fingerprint("Nous", "E2"),
device_helpers.create_fingerprint("Tuya", "809WZT"),
device_helpers.create_fingerprint("Luminea", "ZX-5311"),
device_helpers.create_fingerprint("Tuya", "ZP01"),
device_helpers.create_fingerprint("Tuya", "HW500A"),
device_helpers.create_fingerprint("Aubess", "40ZH-O"),
device_helpers.create_fingerprint("Tuya", "ZMS-102"),
device_helpers.create_fingerprint("Linkoze", "LKMSZ001"),
})
register_device_definition(motion_sensor, device_helpers.create_fingerprints("TS0202", {
"_TZ3210_cwamkvua",
}))
register_device_definition(motion_illuminance_temp_humidity_tamper_sensor, device_helpers.create_fingerprints("TS0202", {
"_TZ3210_0aqbrnts",
"_TZ3210_jijr1sss",
"_TZ3210_m3mxv66l",
"_TZ3210_oekbi7o4",
"_TZ3210_ohvnwamm",
"_TZ3210_rxqls8v0",
"_TZ3210_wuhzzfqg",
"_TZ3210_zmy9hjay",
}))
register_device_definition(motion_illuminance_temp_humidity_sensor, {
device_helpers.create_fingerprint("Sunricher", "HK-SENSOR-4IN1-A"),
})
register_device_definition(contact_tamper_sensor, {
device_helpers.create_fingerprint("TUYATEC-ktge2vqt", "RH3001"),
device_helpers.create_fingerprint("BlitzWolf", "BW-IS2"),
})
register_device_definition(contact_tamper_sensor, device_helpers.create_fingerprints("TY0203", {
"_TZ1800_ejwkn2h2",
"_TZ1800_ho6i0zk9",
}))
register_device_definition(motion_sensor, device_helpers.create_fingerprints("SM0202", {
"_TYZB01_z2umiwvq",
"_TYZB01_yr95mpib",
"_TYZB01_2jzbhomb",
}))
register_device_definition(motion_sensor, {
device_helpers.create_fingerprint("Cleverio", "SS200"),
device_helpers.create_fingerprint("Marmitek", "SM0202_1"),
})
register_device_definition(motion_sensor, {
device_helpers.create_fingerprint("HEIMAN", "PIRILLSensor-EF-3.0"),
})
register_device_definition(motion_tamper_sensor, {
device_helpers.create_fingerprint("HEIMAN", "PIRSensor-N"),
device_helpers.create_fingerprint("HEIMAN", "PIRSensor-N-3.0"),
device_helpers.create_fingerprint("HEIMAN", "PIRSensor-EM"),
device_helpers.create_fingerprint("HEIMAN", "PIRSensor-EF-3.0"),
device_helpers.create_fingerprint("HEIMAN", "PIR_TPV13"),
device_helpers.create_fingerprint("HEIMAN", "PIR_TPV16"),
device_helpers.create_fingerprint("HEIMAN", "TY0202"),
device_helpers.create_fingerprint("HEIMAN", "HS9MS-E"),
device_helpers.create_fingerprint("HEIMAN", "PIR_TPV12"),
})
register_device_definition(water_sensor, device_helpers.create_fingerprints("TS0207", {
"_TZ3000_kyb656no",
"_TZ3000_kstbkt6a",
"_TZ3000_k4ej3ww2",
"_TZ3000_abaplimj",
"_TZ3000_mqiev3jk",
"_TZ3000_ocjlo4ea",
"_TZ3000_upgcbody",
"_TYZB01_sqmd19i1",
"_TYZB01_ttvdudvx",
"_TZ3000_t6jriawg",
"_TZ3000_mugyhz0q",
"_TZ3000_awvmkayh",
"_TZ3000_0s9gukzt",
"_TZ3000_c8bqthpo",
"_TZ3000_eit7p838",
}))
register_device_definition(water_sensor, {
device_helpers.create_fingerprint("Nous", "E4"),
})
register_device_definition(water_sensor, {
device_helpers.create_fingerprint("HOBEIAN", "ZG-222Z"),
device_helpers.create_fingerprint("HOBEIAN", "ZG-222ZA"),
device_helpers.create_fingerprint("_TYZB01_wpmo3ja3", "TS0212"),
device_helpers.create_fingerprint("CR Smart Home", "TS0207"),
device_helpers.create_fingerprint("Niceboy", "ORBIS Water Sensor"),
device_helpers.create_fingerprint("Meian", "SW02"),
device_helpers.create_fingerprint("Aubess", "IH-K665"),
device_helpers.create_fingerprint("Tuya", "_TZ3000_mqiev3jk"),
device_helpers.create_fingerprint("Tuya", "TS0207_water_leak_detector_1"),
device_helpers.create_fingerprint("Tuya", "TS0207_water_leak_detector_3"),
device_helpers.create_fingerprint("Moes", "ZSS-QY-WL-C-MS"),
device_helpers.create_fingerprint("Tuya", "899WZ"),
device_helpers.create_fingerprint("AOYAN", "AY222Z"),
{ manufacturer = "AOYAN  ", model = "AY222Z" },
})
register_device_definition(water_sensor, {
device_helpers.create_fingerprint("HEIMAN", "WaterSensor-N"),
device_helpers.create_fingerprint("HEIMAN", "WaterSensor-EM"),
device_helpers.create_fingerprint("HEIMAN", "WaterSensor-N-3.0"),
device_helpers.create_fingerprint("HEIMAN", "WaterSensor-EF-3.0"),
device_helpers.create_fingerprint("HEIMAN", "WATER_TPV13"),
device_helpers.create_fingerprint("HEIMAN", "TY0207"),
device_helpers.create_fingerprint("HEIMAN", "WaterSensor2-EF-3.0"),
})
register_device_definition(water_sensor, {
device_helpers.create_fingerprint("Sunricher", "HK-SENSOR-WT1"),
})
register_device_definition(water_temp_sensor, {
device_helpers.create_fingerprint("Sunricher", "HK-SENSOR-WT2"),
})
register_device_definition(solar_rain_sensor, device_helpers.create_fingerprints("TS0207", {
"_TZ3210_p68kms0l",
"_TZ3210_tgvtvdoc",
}))
register_device_definition(vibration_sensor, {
device_helpers.create_fingerprint("Niceboy", "ORBIS Vibration Sensor"),
device_helpers.create_fingerprint("iHseno", "_TZ3000_lzdjjfss"),
device_helpers.create_fingerprint("ONENUO", "TS0210_5oy7cysk"),
device_helpers.create_fingerprint("_TZ3210_kjafhwd2", "TS0210"),
device_helpers.create_fingerprint("_TYZB01_821siati", "TS0210"),
device_helpers.create_fingerprint("_TZ3000_lzdjjfss", "TS0210"),
device_helpers.create_fingerprint("EKAZA", "EKVZ-T1016"),
})
register_device_definition(vibration_sensor, {
device_helpers.create_fingerprint("HEIMAN", "Vibration-EF-3.0"),
device_helpers.create_fingerprint("HEIMAN", "Vibration-EF_3.0"),
device_helpers.create_fingerprint("HEIMAN", "Vibration-N"),
})
register_device_definition(vibration_sensor, {
device_helpers.create_fingerprint("Third Reality, Inc", "3RVS01031Z"),
})
register_device_definition(smoke_sensor, device_helpers.create_fingerprints("TS0205", {
"_TZ3210_up3pngle",
"_TYZB01_wqcac7lo",
}))
register_device_definition(smoke_sensor, {
device_helpers.create_fingerprint("Tesla Smart", "TSL-SEN-SMOKE"),
device_helpers.create_fingerprint("Nedis", "ZBDS10WT"),
device_helpers.create_fingerprint("Tuya", "TS0205_smoke_2"),
})
register_device_definition(smoke_sensor, {
device_helpers.create_fingerprint("HEIMAN", "SMOK_V16"),
device_helpers.create_fingerprint("HEIMAN", "SMOK_V15"),
device_helpers.create_fingerprint("HEIMAN", "b5db59bfd81e4f1f95dc57fdbba17931"),
device_helpers.create_fingerprint("HEIMAN", "98293058552c49f38ad0748541ee96ba"),
device_helpers.create_fingerprint("HEIMAN", "SMOK_YDLV10"),
device_helpers.create_fingerprint("HEIMAN", "FB56-SMF02HM1.4"),
device_helpers.create_fingerprint("HEIMAN", "SmokeSensor-N-3.0"),
device_helpers.create_fingerprint("HEIMAN", "319fa36e7384414a9ea62cba8f6e7626"),
device_helpers.create_fingerprint("HEIMAN", "c3442b4ac59b4ba1a83119d938f283ab"),
device_helpers.create_fingerprint("HEIMAN", "SmokeSensor-EF-3.0"),
device_helpers.create_fingerprint("HEIMAN", "SMOK_HV14"),
device_helpers.create_fingerprint("HEIMAN", "SMOK_YDLV10N"),
device_helpers.create_fingerprint("HEIMAN", "SmokeSensor-N"),
device_helpers.create_fingerprint("HEIMAN", "SmokeSensor-EM"),
device_helpers.create_fingerprint("HEIMAN", "HS2SA-EF-3.0"),
device_helpers.create_fingerprint("HEIMAN", "HS15A-M"),
device_helpers.create_fingerprint("HEIMAN", "HS1SA-EF-3.0"),
device_helpers.create_fingerprint("HEIMAN", "HS1SA-E-PLUS"),
device_helpers.create_fingerprint("HEIMAN", "Smokesensor-EF2-3.0"),
})
register_device_definition(smoke_sensor, {
device_helpers.create_fingerprint("Sunricher", "HK-SENSOR-SMO"),
})
register_device_definition(gas_tamper_sensor, device_helpers.create_fingerprints("TS0204", {
"_TYZB01_0w3d5uw3",
}))
register_device_definition(gas_tamper_sensor, {
device_helpers.create_fingerprint("Tesla Smart", "TSL-SEN-GAS"),
})
register_device_definition(gas_tamper_battery_low_sensor, device_helpers.create_fingerprints("SM0212", {
"_TZ3000_45y4bdjb",
}))
register_device_definition(gas_tamper_battery_low_sensor, {
device_helpers.create_fingerprint("HEIMAN", "GASSensor-N"),
device_helpers.create_fingerprint("HEIMAN", "GASSensor-N-3.0"),
device_helpers.create_fingerprint("HEIMAN", "d90d7c61c44d468a8e906ca0841e0a0c"),
device_helpers.create_fingerprint("HEIMAN", "GASSensor-EN"),
device_helpers.create_fingerprint("HEIMAN", "HY0022"),
device_helpers.create_fingerprint("HEIMAN", "RH3070"),
device_helpers.create_fingerprint("HEIMAN", "GAS_V15"),
device_helpers.create_fingerprint("HEIMAN", "GASSensor-EM"),
device_helpers.create_fingerprint("HEIMAN", "358e4e3e03c644709905034dae81433e"),
device_helpers.create_fingerprint("HEIMAN", "GASSensor-EFR-3.0"),
device_helpers.create_fingerprint("HEIMAN", "GASSensor-EF-3.0"),
})
register_device_definition(gas_tamper_battery_low_sensor, {
device_helpers.create_fingerprint("Sunricher", "HK-SENSOR-GAS"),
})
register_device_definition(contact_tamper_sensor, {
device_helpers.create_fingerprint("HEIMAN", "DoorSensor-N"),
device_helpers.create_fingerprint("HEIMAN", "DoorSensor-N-3.0"),
device_helpers.create_fingerprint("HEIMAN", "HS8DS-EF2-3.0"),
device_helpers.create_fingerprint("HEIMAN", "D1-EF2-3.0"),
device_helpers.create_fingerprint("HEIMAN", "DoorSensor-EM"),
device_helpers.create_fingerprint("HEIMAN", "DoorSensor-EF-3.0"),
device_helpers.create_fingerprint("HEIMAN", "DOOR_TPV13"),
device_helpers.create_fingerprint("HEIMAN", "DOOR_TPV12"),
})
register_device_definition(contact_sensor, {
device_helpers.create_fingerprint("Sunricher", "HK-SENSOR-CT-MINI"),
})
register_device_definition(co_sensor, {
device_helpers.create_fingerprint("HEIMAN", "COSensor-EM"),
device_helpers.create_fingerprint("HEIMAN", "COSensor-N"),
device_helpers.create_fingerprint("HEIMAN", "COSensor-EF-3.0"),
})
register_device_definition(co_sensor, {
device_helpers.create_fingerprint("Sunricher", "HK-SENSOR-CO"),
})
return device_definitions
