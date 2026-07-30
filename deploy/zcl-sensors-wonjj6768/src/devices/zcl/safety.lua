local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local emit = require "emitters"
local device_management = require "st.zigbee.device_management"
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
local contact_tamper_battery_low_battery_sensor = {
profile = "safety-contact-tamper-battery-low-battery",
zcl_clusters = {
zcl.contact(),
zcl.tamper(),
zcl.battery_low(),
zcl.battery(),
},
}
local contact_battery_low_battery_sensor = {
profile = "safety-contact-battery-low-battery",
zcl_clusters = {
zcl.contact(),
zcl.battery_low(),
zcl.battery(),
},
}
local contact_battery_voltage_sensor = {
profile = "safety-contact-battery-voltage",
zcl_clusters = {
zcl.contact(),
zcl.battery(),
zcl.battery_voltage(),
},
}
local contact_tamper_battery_voltage_sensor = {
profile = "safety-contact-tamper-battery-voltage",
zcl_clusters = {
zcl.contact(),
zcl.tamper(),
zcl.battery(),
zcl.battery_voltage(),
},
}
local contact_battery_low_battery_voltage_sensor = {
profile = "safety-contact-battery-low-battery-voltage",
zcl_clusters = {
zcl.contact(),
zcl.battery_low(),
zcl.battery(),
zcl.battery_voltage(),
},
}
local contact_tamper_battery_low_battery_voltage_sensor = {
profile = "safety-contact-tamper-battery-low-battery-voltage",
zcl_clusters = {
zcl.contact(),
zcl.tamper(),
zcl.battery_low(),
zcl.battery(),
zcl.battery_voltage(),
},
}
local contact_tamper_battery_low_sensor = {
profile = "safety-contact-tamper-battery-low",
zcl_clusters = {
zcl.contact(),
zcl.tamper(),
zcl.battery_low(),
},
}
local tuya_scene_contact_sensor = {
profile = "safety-contact-tamper-battery-low-battery-tuya-scene-pending",
zcl_clusters = {
zcl.tuya_magic_packet(),
zcl.contact(),
zcl.tamper(),
zcl.battery_low(),
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
local contact_temp_battery_low_sensor = {
profile = "safety-contact-temp-battery-low-battery",
zcl_clusters = {
zcl.contact(),
zcl.temperature(),
zcl.battery_low(),
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
local motion_battery_low_sensor = {
profile = "safety-motion-battery-low",
zcl_clusters = {
zcl.motion(),
zcl.battery_low(),
},
}
local motion_battery_low_battery_voltage_sensor = {
profile = "safety-motion-battery-low-battery-voltage",
zcl_clusters = {
zcl.motion(),
zcl.battery_low(),
zcl.battery(),
zcl.battery_voltage(),
},
}
local motion_tamper_battery_low_battery_voltage_sensor = {
profile = "safety-motion-tamper-battery-low-battery-voltage",
zcl_clusters = {
zcl.motion(),
zcl.tamper(),
zcl.battery_low(),
zcl.battery(),
zcl.battery_voltage(),
},
}
local ih012_rt01_motion_sensor = {
profile = "safety-motion-battery-low-battery-voltage-ih012-pending",
zcl_clusters = {
zcl.motion(),
zcl.battery_low(),
zcl.battery(),
zcl.battery_voltage(),
},
}
local ih012_rt02_motion_sensor = {
profile = "safety-motion-tamper-battery-low-battery-voltage-ih012-pending",
zcl_clusters = {
zcl.motion(),
zcl.tamper(),
zcl.battery_low(),
zcl.battery(),
zcl.battery_voltage(),
},
}
local motion_battery_voltage_sensor = {
profile = "safety-motion-battery-voltage",
zcl_clusters = {
zcl.motion(),
zcl.battery(),
zcl.battery_voltage(),
},
}
local zm35hq_motion_sensor = {
profile = "safety-motion-battery-low-battery",
zcl_clusters = {
zcl.tuya_magic_packet(),
zcl.motion(),
zcl.battery_low(),
zcl.battery(),
},
}
local c3007_pressure_emit = emit.c3007Pressure()
local c3007_pressure_sensor = {
profile = "safety-c3007-pressure-battery-low-battery-voltage",
zcl_clusters = {
zcl.motion({
name = "pressure",
emit = function(device, active)
return c3007_pressure_emit(device, active and "detected" or "clear")
end,
}),
zcl.battery_low(),
zcl.battery(),
zcl.battery_voltage(),
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
local whd02_motion_sensor = {
profile = "safety-motion-tamper-battery-battery-low",
zcl_clusters = {
zcl.motion(),
zcl.tamper(),
zcl.battery(),
zcl.battery_low(),
},
configure = function(driver, device)
device:send(device_management.build_bind_request(
device,
zcl.CLUSTER_POWER_CONFIGURATION,
driver.environment_info.hub_zigbee_eui,
1
))
end,
}
local motion_tamper_battery_low_sensor = {
profile = "safety-motion-tamper-battery-low",
zcl_clusters = {
zcl.motion(),
zcl.tamper(),
zcl.battery_low(),
},
}
local motion_illuminance_tamper_battery_low_battery_sensor = {
profile = "safety-motion-illuminance-tamper-battery-low-battery",
zcl_clusters = {
zcl.motion(),
zcl.illuminance(),
zcl.tamper(),
zcl.battery_low(),
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
local tuya_motion_illuminance_sensor = {
profile = "safety-motion-illuminance-tamper-battery-low-battery",
zcl_clusters = {
zcl.tuya_magic_packet(),
zcl.motion(),
zcl.illuminance(),
zcl.tamper(),
zcl.battery_low(),
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
local sunricher_4in1_sensor = {
profile = "safety-motion-illuminance-temp-humidity-battery",
zcl_clusters = {
zcl.occupancy(),
zcl.illuminance(),
zcl.temperature(),
zcl.humidity(),
zcl.battery({ scale = 1 }),
},
configure = function(driver, device)
for _, cluster_id in ipairs({ 0x0001, 0x0400, 0x0402, 0x0405, 0x0406 }) do
device:send(device_management.build_bind_request(
device,
cluster_id,
driver.environment_info.hub_zigbee_eui,
1
))
end
end,
}
local namron_4512771_multisensor = {
profile = "safety-motion-illuminance-temp-humidity-battery",
zcl_clusters = {
zcl.motion(),
zcl.illuminance(),
zcl.temperature_measurement({
endpoint = 3,
emit = emit.temperature("C"),
scale = 100,
}),
zcl.relative_humidity({
endpoint = 4,
emit = emit.humidity(),
scale = 100,
}),
zcl.power_configuration_battery({
endpoint = 1,
emit = emit.battery(),
scale = 2,
}),
},
configure = function(driver, device)
device:send(device_management.build_bind_request(
device,
zcl.CLUSTER_TEMPERATURE,
driver.environment_info.hub_zigbee_eui,
3
))
device:send(device_management.build_bind_request(
device,
zcl.CLUSTER_RELATIVE_HUMIDITY,
driver.environment_info.hub_zigbee_eui,
4
))
end,
}
local water_sensor = {
profile = "safety-water-leak-battery",
zcl_clusters = {
zcl.water(),
zcl.battery(),
},
}
local water_battery_low_battery_sensor = {
profile = "safety-water-leak-battery-low-battery",
zcl_clusters = {
zcl.water(),
zcl.battery_low(),
zcl.battery(),
},
}
local water_tamper_battery_low_battery_sensor = {
profile = "safety-water-leak-tamper-battery-low-battery",
zcl_clusters = {
zcl.water(),
zcl.tamper(),
zcl.battery_low(),
zcl.battery(),
},
}
local water_alarm12_tamper_battery_low_battery_sensor = {
profile = "safety-water-leak-tamper-battery-low-battery",
zcl_clusters = {
zcl.water_alarm_1_or_2(),
zcl.tamper(),
zcl.battery_low(),
zcl.battery(),
},
}
local water_temp_battery_low_battery_sensor = {
profile = "safety-water-leak-temp-battery-low-battery",
zcl_clusters = {
zcl.water(),
zcl.temperature(),
zcl.battery_low(),
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
local sunricher_water_temp_sensor = {
profile = "safety-water-temp-tamper-battery-low-battery",
zcl_clusters = {
zcl.water_alarm_1_or_2(),
zcl.temperature(),
zcl.tamper(),
zcl.battery_low(),
zcl.battery(),
},
}
local solar_rain_sensor = {
profile = "safety-rain-battery-rb-srain01",
datapoints = {
{ dp = 4, datatype = 0x02, name = "battery", field = "battery", emit = emit.battery(), read_only = true },
{ dp = 101, datatype = 0x02, name = "illuminance_raw", field = "illuminance_raw", emit = emit.rbSrain01IlluminanceRaw(), read_only = true },
{ dp = 102, datatype = 0x02, name = "illuminance_average_20min", field = "illuminance_average_20min", emit = emit.rbSrain01IlluminanceAverage20min(), read_only = true },
{ dp = 103, datatype = 0x02, name = "illuminance_maximum_today", field = "illuminance_maximum_today", emit = emit.rbSrain01IlluminanceMaximumToday(), read_only = true },
{
dp = 104,
datatype = 0x01,
name = "cleaning_reminder",
field = "cleaning_reminder",
emit = emit.rbSrain01CleaningReminder(),
from_device = function(value) return value and "needsCleaning" or "clear" end,
read_only = true,
},
{ dp = 105, datatype = 0x02, name = "rain_intensity", field = "rain_intensity", emit = emit.rbSrain01RainIntensity(), read_only = true },
},
zcl_clusters = {
zcl.water(),
zcl.battery(),
},
}
local vibration_sensor = {
profile = "safety-acceleration-battery",
zcl_clusters = { zcl.motion({ emit = require("emitters").acceleration() }), zcl.battery() },
}
local tuya_vibration_sensor = {
profile = "safety-acceleration-battery-tuya-pending",
zcl_clusters = { zcl.motion({ emit = require("emitters").acceleration() }), zcl.battery() },
}
local heiman_vibration_sensor = {
profile = "safety-acceleration-tamper-battery-low-battery",
zcl_clusters = {
zcl.motion({ emit = require("emitters").acceleration() }),
zcl.tamper(),
zcl.battery_low(),
zcl.battery(),
},
}
local third_reality_vibration_sensor = {
profile = "safety-acceleration-battery-third-reality-pending",
zcl_clusters = { zcl.motion({ emit = require("emitters").acceleration() }), zcl.battery() },
}
local smoke_sensor = {
profile = "safety-smoke-detector-battery",
zcl_clusters = {
zcl.smoke(),
zcl.battery(),
},
}
local smoke_battery_low_battery_sensor = {
profile = "safety-smoke-battery-low-battery",
zcl_clusters = {
zcl.smoke(),
zcl.battery_low(),
zcl.battery(),
},
}
local tuya_smoke_sensor = {
profile = "safety-smoke-tamper-battery",
zcl_clusters = {
zcl.smoke(),
zcl.tamper(),
zcl.battery(),
},
}
local sunricher_smoke_sensor = {
profile = "safety-smoke-tamper-battery-low-battery",
zcl_clusters = {
zcl.smoke_alarm_1_or_2(),
zcl.tamper(),
zcl.battery_low(),
zcl.battery(),
},
}
local heiman_plus_smoke_sensor = {
profile = "safety-smoke-temp-battery-low-battery-heiman-pending",
zcl_clusters = {
zcl.smoke(),
zcl.temperature(),
zcl.battery_low(),
zcl.battery(),
},
}
local fireangel_co_sensor = {
profile = "safety-co-detector-tamper-battery-low",
zcl_clusters = {
zcl.carbon_monoxide(),
zcl.tamper(),
zcl.battery_low(),
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
local gas_tamper_alarm2_battery_low_sensor = {
profile = "safety-gas-detector-tamper-battery-low",
zcl_clusters = {
zcl.gas_alarm_2(),
zcl.tamper(),
zcl.battery_low(),
},
}
local gas_tamper_alarm12_battery_low_sensor = {
profile = "safety-gas-detector-tamper-battery-low",
zcl_clusters = {
zcl.gas_alarm_1_or_2(),
zcl.tamper(),
zcl.battery_low(),
},
}
local co_sensor = {
profile = "safety-co-detector-battery-low-battery",
zcl_clusters = {
zcl.carbon_monoxide(),
zcl.battery_low(),
zcl.battery(),
},
}
local co_alarm12_sensor = {
profile = "safety-co-detector-tamper-battery-low-battery",
zcl_clusters = {
zcl.carbon_monoxide_alarm_1_or_2(),
zcl.tamper(),
zcl.battery_low(),
zcl.battery(),
},
}
register_device_definition(contact_tamper_battery_low_battery_voltage_sensor, {
device_helpers.create_fingerprint("_TZ3000_qrldbmfn", "TS0203"),
{ manufacturer = "AOYAN  ", model = "AY-101Z" },
})
register_device_definition(contact_tamper_battery_low_battery_voltage_sensor, device_helpers.create_fingerprints("TS0203", {
"_TZ3000_7d8yme6f",
"_TZ3000_8yhypbo7",
"_TZ3000_decxrtwa",
"_TZ3000_rid8lzvo",
"_TZ3000_udyjylt7",
"_TZ3000_v7chgqso",
"_TYZB01_epni2jgy",
"_TZ3000_wbrlnkm9",
}))
register_device_definition(contact_tamper_battery_voltage_sensor, device_helpers.create_fingerprints("TS0203", {
"_TZ3000_26fmupbb",
"_TZ3000_oxslv1c9",
"_TZ3000_osu834un",
}))
register_device_definition(contact_battery_low_battery_voltage_sensor, device_helpers.create_fingerprints("TS0203", {
"_TZ3000_2mbfxlzr",
"_TZ3000_4ugnzsli",
"_TZ3000_996rpfy6",
"_TZ3000_bpkijo14",
"_TZ3000_gntwytxo",
"_TZ3000_n2egfsli",
"_TZ3000_rcuyhwe3",
"_TZ3000_t3vvhrmh",
"_TZ3000_yfekcy3n",
}))
register_device_definition(contact_battery_voltage_sensor, device_helpers.create_fingerprints("TS0203", {
"_TZ3000_timx9ivq",
}))
register_device_definition(whd02_motion_sensor, device_helpers.create_fingerprints("TY0202", {
"_TZ1800_fcdjzz3s",
}))
register_device_definition(tuya_scene_contact_sensor, device_helpers.create_fingerprints("TS0203", {
"_TZ3210_jowhpxop",
}))
register_device_definition(contact_temp_battery_low_sensor, {
device_helpers.create_fingerprint("frient A/S", "WISZB-131"),
})
register_device_definition(c3007_pressure_sensor, device_helpers.create_fingerprints("TS0203", {
"_TZ3000_pjb1ua0m",
}))
register_device_definition(tuya_motion_illuminance_sensor, device_helpers.create_fingerprints("TS0202", {
"_TYZB01_vwqnz1sn",
}))
register_device_definition(motion_battery_low_battery_voltage_sensor, device_helpers.create_fingerprints("TS0202", {
"_TYZB01_jytabjkb",
"_TZ3000_lltemgsf",
"_TYZB01_5nr7ncpl",
"_TZ3000_mg4dy6z6",
"_TZ3000_bsvqrxru",
}))
register_device_definition(motion_tamper_battery_low_battery_voltage_sensor, device_helpers.create_fingerprints("TS0202", {
"_TZ3000_hktqahrq",
"_TZ3040_wqmtjsyk",
"_TZ3000_otvn3lne",
"_TZ3000_h4wnrtck",
"_TZ3040_bb6xaihh",
"_TZ3000_qomxlryd",
"_TZ3000_jmrgyl7o",
"_TZ3000_lf56vpxj",
}))
register_device_definition(motion_battery_low_battery_voltage_sensor, device_helpers.create_fingerprints("TS0202", {
"_TZ3000_nss8amz9",
}))
register_device_definition(zm35hq_motion_sensor, device_helpers.create_fingerprints("TS0202", {
"_TZ3040_fwxuzcf4",
"_TZ3040_msl6wxk9",
}))
register_device_definition(ih012_rt01_motion_sensor, device_helpers.create_fingerprints("TS0202", {
"_TZ3000_mcxw5ehu",
"_TZ3000_6ygjfyll",
"_TZ3040_6ygjfyll",
"_TZ3000_msl6wxk9",
}))
register_device_definition(ih012_rt02_motion_sensor, device_helpers.create_fingerprints("TS0202", {
"_TZ3000_o4mkahkc",
}))
register_device_definition(motion_tamper_battery_low_battery_voltage_sensor, device_helpers.create_fingerprints("TS0202", {
"_TYZB01_qjqgmqxr",
}))
register_device_definition(motion_battery_low_sensor, device_helpers.create_fingerprints("TS0202", {
"_TZ3000_mwd3c2at",
}))
register_device_definition(motion_sensor, {
device_helpers.create_fingerprint("TUYATEC-smmlguju", "RH3040"),
})
register_device_definition(motion_battery_voltage_sensor, device_helpers.create_fingerprints("TS0202", {
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
register_device_definition(sunricher_4in1_sensor, {
device_helpers.create_fingerprint("Sunricher", "HK-SENSOR-4IN1-A"),
})
register_device_definition(namron_4512771_multisensor, {
device_helpers.create_fingerprint("Namron", "4512771"),
})
register_device_definition(contact_tamper_battery_low_battery_sensor, {
device_helpers.create_fingerprint("TUYATEC-ktge2vqt", "RH3001"),
})
register_device_definition(contact_tamper_sensor, device_helpers.create_fingerprints("TY0203", {
"_TZ1800_ejwkn2h2",
"_TZ1800_ho6i0zk9",
}))
register_device_definition(motion_battery_low_battery_voltage_sensor, device_helpers.create_fingerprints("SM0202", {
"_TYZB01_z2umiwvq",
"_TYZB01_yr95mpib",
"_TYZB01_2jzbhomb",
}))
register_device_definition(motion_sensor, {
device_helpers.create_fingerprint("HEIMAN", "PIRILLSensor-EF-3.0"),
})
register_device_definition(motion_tamper_battery_low_sensor, {
device_helpers.create_fingerprint("HEIMAN", "PIRSensor-N"),
device_helpers.create_fingerprint("HEIMAN", "PIRSensor-N-3.0"),
device_helpers.create_fingerprint("HEIMAN", "PIRSensor-EM"),
device_helpers.create_fingerprint("HEIMAN", "PIRSensor-EF-3.0"),
device_helpers.create_fingerprint("HEIMAN", "PIR_TPV13"),
device_helpers.create_fingerprint("HEIMAN", "PIR_TPV16"),
device_helpers.create_fingerprint("HEIMAN", "TY0202"),
})
register_device_definition(motion_illuminance_tamper_battery_low_battery_sensor, {
device_helpers.create_fingerprint("HEIMAN", "HS9MS-E"),
})
register_device_definition(whd02_motion_sensor, {
device_helpers.create_fingerprint("HEIMAN", "PIR_TPV12"),
})
register_device_definition(whd02_motion_sensor, {
device_helpers.create_fingerprint("_TZ3000_hktqahrq", "WHD02"),
})
register_device_definition(water_tamper_battery_low_battery_sensor, device_helpers.create_fingerprints("TS0207", {
"_TZ3000_kyb656no",
"_TZ3000_abaplimj",
"_TZ3000_mqiev3jk",
"_TZ3000_ocjlo4ea",
"_TYZB01_sqmd19i1",
"_TZ3000_t6jriawg",
"_TZ3000_awvmkayh",
"_TZ3000_0s9gukzt",
"_TZ3000_c8bqthpo",
"_TZ3000_eit7p838",
}))
register_device_definition(water_battery_low_battery_sensor, device_helpers.create_fingerprints("TS0207", {
"_TZ3000_kstbkt6a",
"_TZ3000_k4ej3ww2",
"_TZ3000_upgcbody",
"_TYZB01_ttvdudvx",
"_TZ3000_mugyhz0q",
}))
register_device_definition(water_tamper_battery_low_battery_sensor, {
device_helpers.create_fingerprint("AOYAN", "AY222Z"),
{ manufacturer = "AOYAN  ", model = "AY222Z" },
})
register_device_definition(water_tamper_battery_low_battery_sensor, {
device_helpers.create_fingerprint("HEIMAN", "WaterSensor-N"),
device_helpers.create_fingerprint("HEIMAN", "WaterSensor-EM"),
device_helpers.create_fingerprint("HEIMAN", "WaterSensor-N-3.0"),
device_helpers.create_fingerprint("HEIMAN", "WaterSensor-EF-3.0"),
device_helpers.create_fingerprint("HEIMAN", "WATER_TPV13"),
device_helpers.create_fingerprint("HEIMAN", "TY0207"),
})
register_device_definition(water_temp_battery_low_battery_sensor, {
device_helpers.create_fingerprint("HEIMAN", "WaterSensor2-EF-3.0"),
})
register_device_definition(water_alarm12_tamper_battery_low_battery_sensor, {
device_helpers.create_fingerprint("Sunricher", "HK-SENSOR-WT1"),
})
register_device_definition(sunricher_water_temp_sensor, {
device_helpers.create_fingerprint("Sunricher", "HK-SENSOR-WT2"),
})
register_device_definition(solar_rain_sensor, device_helpers.create_fingerprints("TS0207", {
"_TZ3210_p68kms0l",
"_TZ3210_tgvtvdoc",
}))
register_device_definition(tuya_vibration_sensor, {
device_helpers.create_fingerprint("_TZ3210_kjafhwd2", "TS0210"),
device_helpers.create_fingerprint("_TYZB01_821siati", "TS0210"),
device_helpers.create_fingerprint("_TZ3000_lzdjjfss", "TS0210"),
})
register_device_definition(heiman_vibration_sensor, {
device_helpers.create_fingerprint("HEIMAN", "Vibration-EF-3.0"),
device_helpers.create_fingerprint("HEIMAN", "Vibration-EF_3.0"),
device_helpers.create_fingerprint("HEIMAN", "Vibration-N"),
})
register_device_definition(third_reality_vibration_sensor, {
device_helpers.create_fingerprint("Third Reality, Inc", "3RVS01031Z"),
})
register_device_definition(tuya_smoke_sensor, device_helpers.create_fingerprints("TS0205", {
"_TZ3210_up3pngle",
"_TYZB01_wqcac7lo",
}))
register_device_definition(smoke_battery_low_battery_sensor, {
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
device_helpers.create_fingerprint("HEIMAN", "Smokesensor-EF2-3.0"),
device_helpers.create_fingerprint("Trust", "SmokeSensor-EM"),
})
register_device_definition(heiman_plus_smoke_sensor, {
device_helpers.create_fingerprint("HEIMAN", "HS1SA-EF-3.0"),
device_helpers.create_fingerprint("HEIMAN", "HS1SA-E-PLUS"),
})
register_device_definition(sunricher_smoke_sensor, {
device_helpers.create_fingerprint("Sunricher", "HK-SENSOR-SMO"),
})
register_device_definition(fireangel_co_sensor, {
device_helpers.create_fingerprint("Fireangel", "Alarm_SD_Device"),
})
register_device_definition(gas_tamper_sensor, device_helpers.create_fingerprints("TS0204", {
"_TYZB01_0w3d5uw3",
}))
register_device_definition(gas_tamper_alarm12_battery_low_sensor, device_helpers.create_fingerprints("SM0212", {
"_TZ3000_45y4bdjb",
}))
register_device_definition(gas_tamper_battery_low_sensor, {
device_helpers.create_fingerprint("HEIMAN", "GASSensor-EN"),
device_helpers.create_fingerprint("HEIMAN", "HY0022"),
device_helpers.create_fingerprint("HEIMAN", "RH3070"),
device_helpers.create_fingerprint("HEIMAN", "GASSensor-EM"),
device_helpers.create_fingerprint("HEIMAN", "358e4e3e03c644709905034dae81433e"),
})
register_device_definition(gas_tamper_alarm2_battery_low_sensor, {
device_helpers.create_fingerprint("HEIMAN", "GASSensor-N"),
device_helpers.create_fingerprint("HEIMAN", "GASSensor-N-3.0"),
device_helpers.create_fingerprint("HEIMAN", "d90d7c61c44d468a8e906ca0841e0a0c"),
device_helpers.create_fingerprint("HEIMAN", "GAS_V15"),
device_helpers.create_fingerprint("HEIMAN", "GASSensor-EFR-3.0"),
device_helpers.create_fingerprint("HEIMAN", "GASSensor-EF-3.0"),
})
register_device_definition(gas_tamper_alarm12_battery_low_sensor, {
device_helpers.create_fingerprint("Sunricher", "HK-SENSOR-GAS"),
})
register_device_definition(contact_tamper_battery_low_battery_sensor, {
device_helpers.create_fingerprint("HEIMAN", "DoorSensor-N"),
device_helpers.create_fingerprint("HEIMAN", "DoorSensor-N-3.0"),
device_helpers.create_fingerprint("HEIMAN", "D1-EF2-3.0"),
device_helpers.create_fingerprint("HEIMAN", "DoorSensor-EM"),
device_helpers.create_fingerprint("HEIMAN", "DoorSensor-EF-3.0"),
})
register_device_definition(contact_battery_low_battery_sensor, {
device_helpers.create_fingerprint("HEIMAN", "HS8DS-EF2-3.0"),
})
register_device_definition(contact_tamper_battery_low_sensor, {
device_helpers.create_fingerprint("HEIMAN", "DOOR_TPV13"),
device_helpers.create_fingerprint("HEIMAN", "DOOR_TPV12"),
})
register_device_definition(co_sensor, {
device_helpers.create_fingerprint("_TYZB01_wpmo3ja3", "TS0212"),
device_helpers.create_fingerprint("HEIMAN", "COSensor-EM"),
device_helpers.create_fingerprint("HEIMAN", "COSensor-N"),
device_helpers.create_fingerprint("HEIMAN", "COSensor-EF-3.0"),
})
register_device_definition(co_alarm12_sensor, {
device_helpers.create_fingerprint("Sunricher", "HK-SENSOR-CO"),
})
return device_definitions
