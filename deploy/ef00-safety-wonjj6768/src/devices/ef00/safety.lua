local tuya = require "tuya_common"
local emit = require "emitters"
local device_helpers = require "devices.shared.helpers"
local capabilities = require "st.capabilities"
local converter = tuya.converter
local device_definitions, register_device_definition = device_helpers.definition_registry()
local siren_yxzbsl_volume_converter = converter.lookup_from_to({
low = 0,
middle = 1,
high = 2,
mute = 3,
})
local hobeian_alarm_volume_converter = siren_yxzbsl_volume_converter
local hobeian_alarm_ring_converter = converter.lookup_from_to({
mute = 0,
beep = 1,
music = 2,
})
local siren_yxzbsl_ringtone_converter = converter.lookup_from_to({
melody1 = 0,
melody2 = 1,
melody3 = 2,
melody4 = 3,
melody5 = 4,
melody6 = 5,
melody7 = 6,
melody8 = 7,
door = 8,
water = 9,
temperature = 10,
entered = 11,
left = 12,
})
local siren_za03_volume_converter = converter.lookup_from_to({
low = 0,
medium = 1,
high = 2,
mute = 3,
})
local siren_za03_ringtone_converter = converter.lookup_from_to({
ringtone_1 = 0,
ringtone_2 = 1,
ringtone_3 = 2,
ringtone_4 = 3,
ringtone_5 = 4,
ringtone_6 = 5,
ringtone_7 = 6,
ringtone_8 = 7,
ringtone_9 = 8,
ringtone_10 = 9,
ringtone_11 = 10,
ringtone_12 = 11,
ringtone_13 = 12,
ringtone_14 = 13,
ringtone_15 = 14,
ringtone_16 = 15,
ringtone_17 = 16,
ringtone_18 = 17,
ringtone_19 = 18,
ringtone_20 = 19,
ringtone_21 = 20,
ringtone_22 = 21,
ringtone_23 = 22,
ringtone_24 = 23,
ringtone_25 = 24,
ringtone_26 = 25,
ringtone_27 = 26,
ringtone_28 = 27,
ringtone_29 = 28,
ringtone_30 = 29,
ringtone_31 = 30,
ringtone_32 = 31,
})
local siren_zg229_alarm_converter = converter.from_only(function(value)
return value ~= 3
end)
local function emit_opening_state(custom_emitter)
return function(device, value)
local events = {}
local contact_value = value == "closed" and "closed" or "open"
events[#events + 1] = capabilities.contactSensor.contact(contact_value)
local custom_event = custom_emitter(device, value)
if custom_event ~= nil then
events[#events + 1] = custom_event
end
return events
end
end
local smoke = {
tuya.dp_smoke(1, { emit = emit.smoke() }),
tuya.dp_enum(14, { name = "battery_state", emit = emit.battery(), converter = converter.from_only(converter.lookup_value({ [0] = 5, [1] = 50, [2] = 100 })) }),
}
register_device_definition(smoke, device_helpers.create_fingerprints("TS0601", {
"_TZE200_ux5v4dbd",
}))
local smoke_tamper_battery_low = {
tuya.dp_smoke(1, { emit = emit.smoke() }),
tuya.dp_tamper(4, {}),                                          -- 프로파일 미포함
tuya.dp_numeric(14, { name = "battery", emit = emit.battery(), converter = converter.from_only(function(value) return value == 0 and 5 or 100 end) }),
}
register_device_definition(smoke_tamper_battery_low, device_helpers.create_fingerprints("TS0601", {
"TZE200_0zaf1cr8",
"_TZE200_0zaf1cr8",
"_TZE204_ntcy3xu1",
"_TZE284_0zaf1cr8",
}))
register_device_definition(smoke_tamper_battery_low, {
device_helpers.create_fingerprint("Nous", "E8"),
})
local smoke_tamper = {
tuya.dp_smoke(1, { emit = emit.smoke() }),
tuya.dp_tamper(4, {}),                                          -- 프로파일 미포함
tuya.dp_enum(14, { name = "battery_state", emit = emit.battery(), converter = converter.from_only(converter.lookup_value({ [0] = 5, [1] = 50, [2] = 100 })) }),
}
register_device_definition(smoke_tamper, device_helpers.create_fingerprints("TS0601", {
"_TZE200_ntcy3xu1",
}))
local smoke_battery = {
tuya.dp_smoke(1, { emit = emit.smoke() }),
tuya.dp_enum(14, { name = "battery_state" }),                   -- 프로파일 미포함
tuya.dp_battery(15, { emit = emit.battery() }),
}
register_device_definition(smoke_battery, device_helpers.create_fingerprints("TS0601", {
"_TZE200_t5p1vj8r",
"_TZE200_uebojraa",
"_TZE200_vzekyi4c",
"_TZE200_yh7aoahi",
"_TZE200_dq1mfjug",
}))
local smoke_gsks_zb = {
profile = "safety-smoke-detector-battery",
tuya.dp_smoke(1, { emit = emit.smoke() }),
tuya.dp_tamper(4, {}),                                          -- 프로파일 미포함
tuya.dp_battery(15, { emit = emit.battery() }),
}
register_device_definition(smoke_gsks_zb, device_helpers.create_fingerprints("TS0601", {
"_TZE200_qcasmfan",
}))
local siren_alarm = {
profile = "safety-alarm-battery-duration-volume-ringtone-yxzbsl",
tuya.dp_enum(5, { name = "volume", emit = emit.alarmVolumeSirenYxzbsl(), converter = siren_yxzbsl_volume_converter }),
tuya.dp_enum(6, { name = "power_type" }),                               -- profile 미포함
tuya.dp_numeric(7, { name = "duration", emit = emit.alarmDurationSirenYxzbslMinutes() }),
tuya.dp_on_off(13, { name = "alarm", emit = emit.alarm() }),
tuya.dp_battery(15, { emit = emit.battery() }),
tuya.dp_enum(21, { name = "ringtone", emit = emit.alarmRingtoneSirenYxzbsl(), converter = siren_yxzbsl_ringtone_converter }),
}
register_device_definition(siren_alarm, device_helpers.create_fingerprints("TS0601", {
"_TZE204_fncxk3ob",
"_TZE204_k7mfgaen",
"_TZE284_fncxk3ob",
}))
local siren_alarm_no_battery = {
profile = "safety-alarm-duration-volume-ringtone-za03",
tuya.dp_enum(5, { name = "volume", emit = emit.alarmVolumeSirenZa03(), converter = siren_za03_volume_converter }),
tuya.dp_numeric(7, { name = "duration", emit = emit.alarmDurationSirenZa03Seconds() }),
tuya.dp_on_off(13, { name = "alarm", emit = emit.alarm() }),
tuya.dp_enum(21, { name = "ringtone", emit = emit.alarmRingtoneSirenZa03(), converter = siren_za03_ringtone_converter }),
}
register_device_definition(siren_alarm_no_battery, device_helpers.create_fingerprints("TS0601", {
"_TZE204_hcxvyxa5",
}))
local water_leak_alarm_zg226z = {
profile = "safety-water-leak-alarm-battery-zg226z",
tuya.dp_water_leak(1, { emit = emit.water(), converter = converter.true_false0() }),
tuya.dp_on_off(101, { name = "alarm", emit = emit.alarm() }),
tuya.dp_on_off(7, { name = "muffling", emit = emit.mufflingWaterLeak() }),
tuya.dp_battery(4, { emit = emit.battery() }),
tuya.dp_numeric(102, { name = "duration", emit = emit.alarmDurationSiren() }),
tuya.dp_enum(104, { name = "alarm_volume", emit = emit.alarmVolumeHobeian(), converter = hobeian_alarm_volume_converter }),
tuya.dp_enum(103, { name = "alarm_ring", emit = emit.alarmRingHobeian(), converter = hobeian_alarm_ring_converter }),
}
register_device_definition(water_leak_alarm_zg226z, {
device_helpers.create_fingerprint("HOBEIAN", "ZG-226Z"),
})
local vibration_alarm_zg228z = {
profile = "safety-acceleration-alarm-battery-zg228z",
tuya.dp_binary(1, { name = "vibration", emit = emit.acceleration(), converter = converter.true_false1() }),
tuya.dp_enum(101, { name = "vibration_siren" }),                      -- profile 미포함
tuya.dp_enum(105, { name = "alarm" }),                                -- enum is beep/ring/stop; profile 보류
tuya.dp_on_off(102, { name = "muffling", emit = emit.mufflingSiren() }),
tuya.dp_battery(4, { emit = emit.battery() }),
tuya.dp_numeric(106, { name = "duration", emit = emit.alarmDurationSiren() }),
tuya.dp_numeric(6, { name = "sensitivity", emit = emit.vibrationSensitivityZgFifty() }),
tuya.dp_enum(103, { name = "alarm_volume", emit = emit.alarmVolumeHobeian(), converter = hobeian_alarm_volume_converter }),
tuya.dp_enum(104, { name = "alarm_ring", emit = emit.alarmRingHobeian(), converter = hobeian_alarm_ring_converter }),
}
register_device_definition(vibration_alarm_zg228z, {
device_helpers.create_fingerprint("HOBEIAN", "ZG-228Z"),
})
local siren_alarm_zg229z = {
profile = "safety-alarm-battery-zg229z",
tuya.dp_enum(1, { name = "alarm_state", emit = emit.alarm(), converter = siren_zg229_alarm_converter }),
tuya.dp_on_off(102, { name = "doorbell", emit = emit.doorbellSirenHobeian() }),
tuya.dp_on_off(16, { name = "muffling", emit = emit.mufflingSiren() }),
tuya.dp_battery(15, { emit = emit.battery() }),
tuya.dp_numeric(7, { name = "duration", emit = emit.alarmDurationSiren() }),
tuya.dp_enum(5, { name = "volume", emit = emit.alarmVolumeHobeian(), converter = hobeian_alarm_volume_converter }),
tuya.dp_enum(101, { name = "doorbell_volume", emit = emit.doorbellVolumeHobeian(), converter = hobeian_alarm_volume_converter }),
}
register_device_definition(siren_alarm_zg229z, {
device_helpers.create_fingerprint("HOBEIAN", "ZG-229Z"),
})
local smoke_model_hs2sa_1 = {
tuya.dp_smoke(1, { emit = emit.smoke() }),
tuya.dp_self_test_state(9, {}),                                 -- 지원필요없음
tuya.dp_enum(14, { name = "battery_state" }),                   -- 프로파일 미포함
tuya.dp_battery(15, { emit = emit.battery() }),
tuya.dp_silence(16, {}),                                        -- 미구현
}
register_device_definition(smoke_model_hs2sa_1, device_helpers.create_fingerprints("TS0601", {
"_TZE200_vawy74yh",
"_TZE204_ai4rqhky",
"_TZE204_vawy74yh",
"_TZE284_ai4rqhky",
"_TZE284_vawy74yh",
}))
local smoke_concentration = {
tuya.dp_smoke(1, { emit = emit.smoke() }),
tuya.dp_smoke_concentration(2, {}),                             -- 프로파일 미포함
tuya.dp_device_fault(11, {}),                                   -- 프로파일 미포함
tuya.dp_battery(15, { emit = emit.battery() }),
tuya.dp_silence(16, {}),                                        -- 미구현
tuya.dp_binary(101, { name = "test" }),                         -- 지원필요없음
}
register_device_definition(smoke_concentration, device_helpers.create_fingerprints("TS0601", {
"_TZE200_m9skfctm",
"_TZE200_rccxox8p",
"_TZE2841000000_rccxox8p",
"_TZE284_rccxox8p",
}))
local smoke_concentration_fault_alarm = {
tuya.dp_smoke(1, { emit = emit.smoke() }),
tuya.dp_smoke_concentration(2, {}),                             -- 프로파일 미포함
tuya.dp_fault_alarm(11, {}),                                    -- 프로파일 미포함
tuya.dp_enum(14, { name = "battery_state" }),                   -- 프로파일 미포함
tuya.dp_battery(15, { emit = emit.battery() }),
tuya.dp_silence(16, {}),                                        -- 미구현
tuya.dp_binary(17, { name = "self_test" }),                     -- 지원필요없음
}
register_device_definition(smoke_concentration_fault_alarm, device_helpers.create_fingerprints("TS0601", {
"_TZE200_e2bedvo9",
"_TZE200_dnz6yvl2",
"_TZE284_e2bedvo9",
}))
local smoke_tamper_alarm = {
tuya.dp_smoke(1, { emit = emit.smoke() }),
tuya.dp_tamper(4, {}),                                          -- 프로파일 미포함
tuya.dp_fault_alarm(11, {}),                                    -- 프로파일 미포함
tuya.dp_battery(15, { emit = emit.battery() }),
tuya.dp_silence(16, {}),                                        -- 미구현
tuya.dp_alarm(17, {}),                                          -- 미구현
}
register_device_definition(smoke_tamper_alarm, device_helpers.create_fingerprints("TS0601", {
"_TZE200_ytibqbra",
}))
local smoke_legacy = {
tuya.dp_smoke(1, { emit = emit.smoke() }),
tuya.dp_battery(15, { emit = emit.battery() }),
tuya.dp_silence(16, {}),                                        -- 미구현
tuya.dp_alarm(20, {}),                                          -- 미구현
}
register_device_definition(smoke_legacy, device_helpers.create_fingerprints("TS0601", {
"_TZE200_5d3vhjro",
}))
local smoke_model_r7049 = {
tuya.dp_smoke(1, { emit = emit.smoke() }),
tuya.dp_binary(8, { name = "test_alarm" }),                     -- 지원필요없음
tuya.dp_self_test_result(9, {}),                                -- 프로파일 미포함
tuya.dp_fault_alarm(11, {}),                                    -- 프로파일 미포함
tuya.dp_enum(14, { name = "battery_level", emit = emit.battery(), converter = converter.from_only(converter.lookup_value({ [0] = 5, [1] = 50, [2] = 100 })) }),
tuya.dp_silence(16, {}),                                        -- 미구현
tuya.dp_alarm(20, {}),                                          -- 미구현
}
register_device_definition(smoke_model_r7049, device_helpers.create_fingerprints("TS0601", {
"_TZE200_aycxwiau",
"_TZE200_bxdyeaa9",
"_TZE200_ft523twt",
}))
local smoke_model_smart_smoke10 = {
tuya.dp_smoke(1, { emit = emit.smoke() }),
tuya.dp_smoke_concentration(2, {}),                             -- 프로파일 미포함
tuya.dp_binary(8, { name = "self_checking" }),                  -- 지원필요없음
tuya.dp_self_test_result(9, {}),                                -- 프로파일 미포함
tuya.dp_binary(11, { name = "smoke_test" }),                    -- 지원필요없음
tuya.dp_binary(12, { name = "lifecycle" }),                     -- 프로파일 미포함
tuya.dp_enum(14, { name = "battery_state" }),                   -- 프로파일 미포함
tuya.dp_battery(15, { emit = emit.battery() }),
tuya.dp_silence(16, {}),                                        -- 미구현
}
register_device_definition(smoke_model_smart_smoke10, device_helpers.create_fingerprints("TS0601", {
"_TZE200_qtbrwrfv",
}))
local smoke_model_288wz = {
profile = "safety-smoke-detector-battery-288wz",
tuya.dp_binary(1, {
name = "smoke",
emit = emit.smoke(),
converter = converter.from_only(function(value)
return value == 0
end),
}),
tuya.dp_battery(15, { emit = emit.battery() }),
tuya.dp_silence(16, {}),                                        -- 미구현
tuya.dp_self_test_result(101, {}),                              -- 프로파일 미포함
tuya.dp_enum(102, {
name = "sensitivity",
emit = emit.sensitivitySmoke288wzEnum(),
converter = converter.lookup_from_to({
low = 0,
medium = 1,
high = 2,
}),
}),
}
register_device_definition(smoke_model_288wz, device_helpers.create_fingerprints("TS0601", {
"_TZE204_kgaxpvxr",
"_TZE284_n4ttsck2",
}))
local smoke_co = {
tuya.dp_smoke(1, { emit = emit.smoke() }),
tuya.dp_alarm_volume(5, {}),                                    -- 미구현
tuya.dp_battery(15, { emit = emit.battery() }),
tuya.dp_silence(16, {}),                                        -- 미구현
tuya.dp_alarm_switch(17, {}),                                   -- 미구현
tuya.dp_carbon_monoxide(18, { emit = emit.carbon_monoxide() }),
}
register_device_definition(smoke_co, device_helpers.create_fingerprints("TS0601", {
"_TZE284_6ycgarab",
}))
local smoke_temp_humidity = {
profile = "safety-smoke-temp-humidity-battery",
tuya.dp_smoke(1, { emit = emit.smoke() }),
tuya.dp_self_test_state(9, {}),                                 -- 프로파일 미포함
tuya.dp_enum(14, { name = "battery_state", emit = emit.battery(), converter = converter.from_only(converter.lookup_value({ [0] = 5, [1] = 50, [2] = 100 })) }),
tuya.dp_silence(16, {}),                                        -- 프로파일 미포함
tuya.dp_temperature(23, { emit = emit.temperature() }),
tuya.dp_humidity(24, { emit = emit.humidity(), scale = 1 }),
tuya.dp_string(103, { name = "version" }),                      -- 프로파일 미포함
}
register_device_definition(smoke_temp_humidity, device_helpers.create_fingerprints("TS0601", {
"_TZE284_gyzlwu5q",
}))
local gas_self_test_fault = {
profile = "safety-gas-detector-self-test",
tuya.dp_gas(1, { emit = emit.gas() }),
tuya.dp_binary(8, {
name = "self_test",
emit = emit.selfTestGas(),
converter = converter.lookup_from_to({ on = true, off = false }),
}),
tuya.dp_self_test_result(9, {}),                                -- 프로파일 미포함
tuya.dp_fault_alarm(11, {}),                                    -- 프로파일 미포함
tuya.dp_silence(16, {}),                                        -- 미구현
}
register_device_definition(gas_self_test_fault, device_helpers.create_fingerprints("TS0601", {
"_TZE200_ggev5fsl",
"_TZE200_u319yc66",
"_TZE200_kvpwq8z7",
"_TZE204_kvpwq8z7",
}))
local gas_value_alarm_time_ringtone = {
profile = "safety-gas-detector-alarm-time-ringtone",
tuya.dp_gas(1, { emit = emit.gas() }),
tuya.dp_gas_value(2, { scale = 10 }),                           -- 프로파일 미포함
tuya.dp_alarm_ringtone(6, { emit = emit.alarmMelodyGasFive() }),
tuya.dp_alarm_time(7, { emit = emit.alarmDurationGas180() }),
tuya.dp_binary(8, {
name = "self_test",
emit = emit.selfTestGas(),
converter = converter.lookup_from_to({ on = true, off = false }),
}),
tuya.dp_self_test_result(9, {}),                                -- 프로파일 미포함
tuya.dp_preheat(10, {}),                                        -- 프로파일 미포함
tuya.dp_silence(16, {}),                                        -- 미구현
}
register_device_definition(gas_value_alarm_time_ringtone, device_helpers.create_fingerprints("TS0601", {
"_TZE200_yojqa8xn",
"_TZE204_zougpkpy",
"_TZE204_chbyv06x",
"_TZE204_yojqa8xn",
"_TZE284_chbyv06x",
"_TZE28C1000000_chbyv06x",
}))
register_device_definition(gas_value_alarm_time_ringtone, {
device_helpers.create_fingerprint("DYGSM", "DY-RQ500A"),
})
local gas_self_test_result_fault = {
tuya.dp_gas(1, { emit = emit.gas() }),
tuya.dp_self_test_result(9, {}),                                -- 프로파일 미포함
tuya.dp_fault_alarm(11, {}),                                    -- 프로파일 미포함
}
register_device_definition(gas_self_test_result_fault, device_helpers.create_fingerprints("TS0601", {
"_TZE200_nus5kk3n",
}))
local gas_value_preheat_fault = {
tuya.dp_gas(1, { emit = emit.gas() }),
tuya.dp_gas_value(2, { scale = 10 }),                           -- 프로파일 미포함
tuya.dp_preheat(10, {}),                                        -- 프로파일 미포함
tuya.dp_fault_alarm(11, {}),                                    -- 프로파일 미포함
tuya.dp_alarm_switch(13, {}),                                   -- 미구현
tuya.dp_silence(16, {}),                                        -- 미구현
}
register_device_definition(gas_value_preheat_fault, device_helpers.create_fingerprints("TS0601", {
"_TZE200_mby4kbtq",
"_TZE204_mby4kbtq",
"_TZE204_uo8qcagc",
"_TZE284_uo8qcagc",
}))
local gas_model_ga01 = {
tuya.dp_gas(1, { emit = emit.gas() }),
tuya.dp_self_test_result(9, {}),                                -- 프로파일 미포함
tuya.dp_preheat(16, {}),                                        -- 프로파일 미포함
}
register_device_definition(gas_model_ga01, device_helpers.create_fingerprints("TS0601", {
"_TZE200_ioxkjvuz",
}))
local gas_model_dg03 = {
tuya.dp_gas(1, { emit = emit.gas() }),
tuya.dp_preheat(10, {}),                                        -- 프로파일 미포함
tuya.dp_gas_fault_status(11, {}),                               -- 프로파일 미포함
tuya.dp_binary(12, { name = "lifecycle" }),                     -- 프로파일 미포함
}
register_device_definition(gas_model_dg03, device_helpers.create_fingerprints("TS0601", {
"_TZE204_v6iczj35",
}))
local gas_model_zg_225z = {
profile = "safety-gas-detector-zg225z",
tuya.dp_gas(1, { emit = emit.gas() }),
tuya.dp_gas_value(2, {}),                                       -- 프로파일 미포함
tuya.dp_enum(6, { name = "ring" }),                             -- 지원필요없음
tuya.dp_enum(101, {
name = "sensitivity",
emit = emit.sensitivityGasZg225zEnum(),
converter = converter.lookup_from_to({
low = 0,
medium = 1,
high = 2,
}),
}),
}
register_device_definition(gas_model_zg_225z, {
device_helpers.create_fingerprint("_TZE200_8isdky6j", "TS0601"),
device_helpers.create_fingerprint("_TZE200_p6fuhvez", "TS0225"),
device_helpers.create_fingerprint("_TZE200_aj0oxo1i", "TS0225"),
})
local co = {
tuya.dp_carbon_monoxide(1, { emit = emit.carbon_monoxide() }),
tuya.dp_co(2, { emit = emit.carbon_monoxide_level(), scale = 100 }),
}
register_device_definition(co, device_helpers.create_fingerprints("TS0601", {
"_TZE200_7bztmfm1",
"_TZE204_7bztmfm1",
}))
local gas_carbon_monoxide = {
tuya.dp_gas(1, { emit = emit.gas() }),
tuya.dp_gas_value(2, { scale = 1000 }),                         -- 프로파일 미포함
tuya.dp_carbon_monoxide(18, { emit = emit.carbon_monoxide() }),
tuya.dp_co(19, { emit = emit.carbon_monoxide_level(), scale = 100 }),
}
register_device_definition(gas_carbon_monoxide, device_helpers.create_fingerprints("TS0601", {
"_TZE200_iuk8kupi",
"_TZE204_iuk8kupi",
"_TZE204_qaxkdgyt",
}))
local th_contact = {
tuya.dp_contact(1, { emit = emit.contact(), inverted = true }),
tuya.dp_battery(2, { emit = emit.battery() }),
tuya.dp_temperature(7, { emit = emit.temperature("C"), scale = 10 }),
tuya.dp_humidity(8, { emit = emit.humidity() }),
}
register_device_definition(th_contact, device_helpers.create_fingerprints("TS0601", {
"_TZE200_nvups4nh",
}))
register_device_definition(th_contact, {
device_helpers.create_fingerprint("Aubess", "1005005194831629"),
})
local contact_illum = {
tuya.dp_contact(1, { emit = emit.contact(), inverted = true }),
tuya.dp_battery(2, { emit = emit.battery() }),
tuya.dp_illuminance(101, { emit = emit.illuminance() }),
tuya.dp_illuminance_interval(102, {}),                          -- 프로파일 미포함
}
register_device_definition(contact_illum, device_helpers.create_fingerprints("TS0601", {
"_TZE200_pay2byax",
"_TZE200_ijey4q29",
"_TZE200_ykglasuj",
"_TZE200_kf2hbko4",
}))
local contact_basic = {
tuya.dp_contact(1, { emit = emit.contact(), inverted = true }),
tuya.dp_battery(2, { emit = emit.battery() }),
}
register_device_definition(contact_basic, device_helpers.create_fingerprints("TS0601", {
"_TZE200_kltffuzl",
"_TZE200_fwoorn8y",
"_TZE200_n8dljorx",
}))
local contact_opening_tamper = {
profile = "safety-contact-tamper-battery-opening",
tuya.dp_battery(2, { emit = emit.battery() }),
tuya.dp_tamper(16, { emit = emit.tamper() }),
tuya.dp_enum(101, {
name = "opening_state",
emit = emit_opening_state(emit.openingStateContactTamper3State()),
converter = converter.lookup_from_to({ open = 0, closed = 1, tilted = 2 }),
}),
}
register_device_definition(contact_opening_tamper, device_helpers.create_fingerprints("TS0601", {
"_TZE200_ytx9fudw",
}))
local contact_window_handle_s8 = {
profile = "safety-contact-temp-humidity-battery-s8",
tuya.dp_battery(3, { emit = emit.battery() }),
tuya.dp_temperature(8, { emit = emit.temperature("C"), scale = 10 }),
tuya.dp_humidity(101, { emit = emit.humidity() }),
tuya.dp_enum(102, { name = "alarm" }),                                  -- profile 미포함
tuya.dp_enum(103, {
name = "opening_mode",
emit = emit.contact(),
converter = converter.from_only(converter.lookup_value({ [0] = "closed", [1] = "open" })),
}),
tuya.dp_enum(104, { name = "position" }),                               -- profile 미포함
tuya.dp_enum(105, { name = "button_left" }),                            -- profile 미포함
tuya.dp_enum(106, { name = "button_right" }),                           -- profile 미포함
tuya.dp_enum(107, { name = "vacation" }),                               -- profile 미포함
tuya.dp_enum(108, {
name = "sensitivity",
emit = emit.sensitivityContactS8Enum(),
converter = converter.lookup_from_to({
off = 0,
low = 1,
medium = 2,
high = 3,
max = 4,
}),
}),
tuya.dp_enum(109, { name = "alarm_switch" }),                           -- profile 미포함
tuya.dp_numeric(110, { name = "update_frequency", emit = emit.updateFrequencyContactS8Minutes() }),
tuya.dp_enum(111, { name = "keysound" }),                               -- profile 미포함
tuya.dp_enum(112, { name = "battery_low" }),                            -- profile 미포함
tuya.dp_numeric(113, { name = "duration", emit = emit.alarmDurationContactS8Sec300() }),
tuya.dp_enum(114, { name = "handlesound" }),                            -- profile 미포함
tuya.dp_enum(120, { name = "calibrate" }),                              -- profile 미포함
}
register_device_definition(contact_window_handle_s8, device_helpers.create_fingerprints("TS0601", {
"_TZE200_j7sgd8po",
}))
local contact_senoro_win_v2 = {
profile = "safety-contact-battery-senoro-win-v2",
tuya.dp_battery(2, { emit = emit.battery() }),
tuya.dp_enum(101, {
name = "opening_state",
emit = emit_opening_state(emit.openingStateSenoroWinV23State()),
converter = converter.lookup_from_to({ open = 0, closed = 1, tilted = 2 }),
}),
tuya.dp_binary(16, { name = "alarm_state" }),                           -- profile 미포함
tuya.dp_numeric(102, { name = "vibration" }),                           -- profile 미포함
tuya.dp_binary(103, { name = "alarm_siren" }),                          -- profile 미포함
tuya.dp_binary(104, { name = "close_signal" }),                         -- profile 미포함
tuya.dp_numeric(105, { name = "transmission_power", emit = emit.txPowerSenoroWinLevel() }),
tuya.dp_numeric(106, { name = "vibration_limit", emit = emit.vibrationLimitSenoroWinV2() }),
tuya.dp_binary(107, { name = "setup_mode" }),                           -- profile 미포함
tuya.dp_binary(108, { name = "vibration_siren" }),                      -- profile 미포함
tuya.dp_numeric(109, { name = "alarm_siren_duration" }),                -- profile 미포함
tuya.dp_numeric(110, { name = "vibration_siren_duration" }),            -- profile 미포함
tuya.dp_binary(111, { name = "magnetic_status" }),                      -- profile 미포함
}
register_device_definition(contact_senoro_win_v2, device_helpers.create_fingerprints("TS0601", {
"_TZE284_6teua268",
}))
local water = {
tuya.dp_binary(101, { name = "water_leak", emit = emit.water() }),
}
register_device_definition(water, device_helpers.create_fingerprints("TS0601", {
"_TZE200_qq9mpfhw",
}))
register_device_definition(water, {
device_helpers.create_fingerprint("NEO", "NAS-WS02B0"),
})
local water_battery = {
tuya.dp_water_leak(1, { emit = emit.water() }),
tuya.dp_battery(4, { emit = emit.battery() }),
}
register_device_definition(water_battery, device_helpers.create_fingerprints("TS0601", {
"_TZE200_jthf7vb6",
}))
local water_illum_battery_model_zg_223z = {
profile = "safety-water-leak-illuminance-battery-zg223z",
tuya.dp_enum(1, {
name = "rainwater",
emit = emit.water(),
converter = converter.from_only(converter.lookup_value({
[0] = false,
[1] = true,
})),
}),
tuya.dp_numeric(2, { name = "sensitivity" }),                   -- 미구현
tuya.dp_numeric(101, { name = "illuminance_sampling", emit = emit.illuminanceSamplingZg223zMinutes() }),
tuya.dp_illuminance(102, { emit = emit.illuminance() }),
tuya.dp_battery(104, { emit = emit.battery() }),
}
register_device_definition(water_illum_battery_model_zg_223z, device_helpers.create_fingerprints("TS0601", {
"_TZE200_jsaqgakf",
"_TZE200_u6x1zyv2",
"_TZE200_2pddnnrk",
}))
register_device_definition(water_illum_battery_model_zg_223z, {
device_helpers.create_fingerprint("HOBEIAN", "ZG-223Z"),
})
local vibration = {
tuya.dp_contact(1, { emit = emit.contact(), inverted = true }),
tuya.dp_battery(3, { emit = emit.battery() }),
tuya.dp_binary(10, { name = "vibration", emit = emit.acceleration() }),
}
register_device_definition(vibration, device_helpers.create_fingerprints("TS0601", {
"_TZE200_kzm5w4iz",
}))
local vibration_model_zg_102zm = {
profile = "safety-acceleration-contact-battery-zg102zm",
tuya.dp_binary(1, { name = "vibration", emit = emit.acceleration(), converter = converter.true_false1() }),
tuya.dp_contact(101, { emit = emit.contact(), converter = converter.true_false0() }),
tuya.dp_battery(4, { emit = emit.battery() }),
tuya.dp_numeric(6, { name = "sensitivity", emit = emit.vibrationSensitivityZgFifty() }),
}
register_device_definition(vibration_model_zg_102zm, device_helpers.create_fingerprints("TS0601", {
"_TZE200_wzk0x7fq",
"_TZE200_jfw0a4aa",
}))
register_device_definition(vibration_model_zg_102zm, {
device_helpers.create_fingerprint("AOYAN", "AY02SZ"),
device_helpers.create_fingerprint("HOBEIAN", "ZG-102ZM"),
})
local vibration_model_zg_103z = {
profile = "safety-acceleration-battery-zg103z",
tuya.dp_binary(1, { name = "vibration", emit = emit.acceleration(), converter = converter.true_false1() }),
tuya.dp_binary(7, { name = "tilt", converter = converter.true_false1() }), -- 프로파일 미포함
tuya.dp_numeric(101, { name = "x" }),                           -- 프로파일 미포함
tuya.dp_numeric(102, { name = "y" }),                           -- 프로파일 미포함
tuya.dp_numeric(103, { name = "z" }),                           -- 프로파일 미포함
tuya.dp_enum(104, {
name = "sensitivity",
emit = emit.vibrationSensitivityZg103zEnum(),
converter = converter.lookup_from_to({
low = 0,
middle = 1,
high = 2,
}),
}),
tuya.dp_battery(105, { emit = emit.battery() }),
}
register_device_definition(vibration_model_zg_103z, device_helpers.create_fingerprints("TS0601", {
"_TZE200_iba1ckek",
"_TZE200_hggxgsjj",
"_TZE200_yjryxpot",
"_TZE200_afycb3cg",
}))
local vibration_model_4cqhd2ha = {
profile = "safety-acceleration-4cqhd2ha",
tuya.dp_binary(1, { name = "vibration", emit = emit.acceleration(), converter = converter.true_false1() }),
tuya.dp_numeric(101, { name = "sensitivity", emit = emit.vibrationSensitivity4cqhd2haLevel() }),
tuya.dp_binary(103, { name = "buzzer_mute" }),                  -- 프로파일 미포함
}
register_device_definition(vibration_model_4cqhd2ha, device_helpers.create_fingerprints("TS0601", {
"_TZE284_4cqhd2ha",
"_TZE200_8ply8mjj",
}))
register_device_definition(vibration_model_4cqhd2ha, {
device_helpers.create_fingerprint("Conecto", "COZIGVS"),
})
return device_definitions
