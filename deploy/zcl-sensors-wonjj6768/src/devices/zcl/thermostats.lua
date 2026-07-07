local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local device_definitions, register_device_definition = device_helpers.definition_registry()
local function build_thermostat(profile, options)
options = options or {}
local clusters = {
zcl.local_temperature(),
zcl.heating_setpoint(),
zcl.system_mode(),
zcl.thermostat_operating_state(),
}
if options.cooling == true then
clusters[#clusters + 1] = zcl.cooling_setpoint()
end
if options.fan == true then
clusters[#clusters + 1] = zcl.fan_mode()
end
if options.battery == true then
clusters[#clusters + 1] = zcl.battery()
end
if options.humidity == true then
clusters[#clusters + 1] = zcl.humidity()
end
if options.power == true then
clusters[#clusters + 1] = zcl.power()
end
if options.energy == true then
clusters[#clusters + 1] = zcl.energy()
end
if options.current == true then
clusters[#clusters + 1] = zcl.current()
end
return {
profile = profile,
zcl_clusters = clusters,
}
end
local thermostat = build_thermostat("thermostats-thermostat")
local thermostat_battery = build_thermostat("thermostats-thermostat-battery", { battery = true })
local namron_edge_thermostat = build_thermostat("thermostats-thermostat-humidity-power-energy-current", {
humidity = true,
power = true,
energy = true,
current = true,
})
local fcu_thermostat = build_thermostat("thermostats-fcu-thermostat", { cooling = true, fan = true })
register_device_definition(thermostat_battery, {
device_helpers.create_fingerprint("Appartme", "APRM-04-001"),
device_helpers.create_fingerprint("Brennenstuhl", "HT CZ 01"),
device_helpers.create_fingerprint("Essentials", "120112"),
device_helpers.create_fingerprint("Eurotronic", "SPZB0001"),
device_helpers.create_fingerprint("Ferguson", "TH-T_V14"),
device_helpers.create_fingerprint("Hama", "00176592"),
device_helpers.create_fingerprint("HiHome", "WZB-TRVL"),
device_helpers.create_fingerprint("Maginon", "WT-1"),
device_helpers.create_fingerprint("Nedis", "ZBHTR10WT"),
device_helpers.create_fingerprint("RTX", "ZB-RT1"),
device_helpers.create_fingerprint("Royal Thermo", "RTE 77.001B"),
device_helpers.create_fingerprint("SETTI+", "TRV001"),
device_helpers.create_fingerprint("TCP Smart", "TBUWTRV"),
device_helpers.create_fingerprint("Tesla Smart", "TSL-TRV-GS361A"),
device_helpers.create_fingerprint("Tuya", "GTZ02"),
device_helpers.create_fingerprint("UHome", "TWV"),
})
register_device_definition(thermostat_battery, {
device_helpers.create_fingerprint("Elko", "EKO09738"),
device_helpers.create_fingerprint("LINCUKOO", "SZT06"),
device_helpers.create_fingerprint("LK", "545D6306"),
device_helpers.create_fingerprint("Lincukoo", "G94E"),
device_helpers.create_fingerprint("Lincukoo", "V04-Z20T"),
device_helpers.create_fingerprint("Lincukoo", "V06-Z10T"),
device_helpers.create_fingerprint("Lincukoo", "W10-Z10T"),
device_helpers.create_fingerprint("Moes", "BHT-002/BHT-006"),
device_helpers.create_fingerprint("Schneider Electric", "CCTFR6700"),
device_helpers.create_fingerprint("Schneider Electric", "CCTFR6710"),
device_helpers.create_fingerprint("Sygonix", "SY-6811314"),
device_helpers.create_fingerprint("Unitec", "30946"),
device_helpers.create_fingerprint("Vimar", "03906"),
device_helpers.create_fingerprint("Weten", "Tuya PRO"),
device_helpers.create_fingerprint("Yandex", "YNDX-00520"),
device_helpers.create_fingerprint("Yandex", "YNDX-00521"),
device_helpers.create_fingerprint("Yandex", "YNDX-00522"),
device_helpers.create_fingerprint("Yandex", "YNDX-00523"),
device_helpers.create_fingerprint("Yandex", "YNDX-00524"),
device_helpers.create_fingerprint("Zemismart", "SDM01-3Z1"),
device_helpers.create_fingerprint("Zemismart", "SDM02-2Z1"),
device_helpers.create_fingerprint("Zemismart", "SPM01-1Z2"),
device_helpers.create_fingerprint("computime", "PUMM01102"),
})
register_device_definition(thermostat_battery, {
device_helpers.create_fingerprint("Danfoss", "014G2463"),
device_helpers.create_fingerprint("Danfoss", "0x0042"),
device_helpers.create_fingerprint("Danfoss", "0x0200"),
device_helpers.create_fingerprint("Danfoss", "0x0210"),
device_helpers.create_fingerprint("Danfoss", "0x0211"),
device_helpers.create_fingerprint("Danfoss", "0x8020"),
device_helpers.create_fingerprint("Danfoss", "0x8021"),
device_helpers.create_fingerprint("Danfoss", "0x8030"),
device_helpers.create_fingerprint("Danfoss", "0x8031"),
device_helpers.create_fingerprint("Danfoss", "0x8034"),
device_helpers.create_fingerprint("Danfoss", "0x8035"),
device_helpers.create_fingerprint("Danfoss", "0x8040"),
device_helpers.create_fingerprint("Danfoss", "0x8041"),
})
register_device_definition(thermostat, {
device_helpers.create_fingerprint("Centralite", "3157100"),
device_helpers.create_fingerprint("Centralite", "3157100-E"),
device_helpers.create_fingerprint("Danfoss", "devi_f"),
device_helpers.create_fingerprint("Schneider Electric", "Thermostat"),
device_helpers.create_fingerprint("Sinopé", "TH1320ZB-04"),
})
register_device_definition(namron_edge_thermostat, {
device_helpers.create_fingerprint("Namron", "4566702"),
device_helpers.create_fingerprint("Namron", "4566703"),
device_helpers.create_fingerprint("Namron", "4512783"),
device_helpers.create_fingerprint("Namron", "4512784"),
})
register_device_definition(fcu_thermostat, {
device_helpers.create_fingerprint("Hive", "SLR2d"),
device_helpers.create_fingerprint("Hive", "UK7004240"),
device_helpers.create_fingerprint("Salus Controls", "FC600NH"),
})
return device_definitions
