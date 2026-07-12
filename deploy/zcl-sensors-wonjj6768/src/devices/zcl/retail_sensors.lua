local zcl = require "zcl_common"
local device_helpers = require "devices.shared.helpers"
local emit = require "emitters"
local data_types = require "st.zigbee.data_types"
local device_definitions, register_device_definition = device_helpers.definition_registry()
local function register_aliases(definition, aliases)
register_device_definition(definition, aliases)
end
local motion_sensor = {
profile = "safety-motion-battery",
zcl_clusters = {
zcl.motion(),
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
local contact_sensor = {
profile = "safety-contact-battery",
zcl_clusters = {
zcl.contact(),
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
local temp_humidity_sensor = {
profile = "sensors-temp-humidity-battery",
zcl_clusters = {
zcl.temperature(),
zcl.humidity(),
zcl.battery(),
},
}
local smoke_sensor = {
profile = "safety-smoke-detector-battery",
zcl_clusters = {
zcl.smoke(),
zcl.battery(),
},
}
local smoke_temp_humidity_sensor = {
profile = "safety-smoke-temp-humidity-battery",
zcl_clusters = {
zcl.smoke(),
zcl.temperature(),
zcl.humidity(),
zcl.battery(),
},
}
local illuminance_sensor = {
profile = "sensors-illuminance-battery",
zcl_clusters = {
zcl.illuminance(),
zcl.battery(),
},
}
local heiman_air_quality = {
profile = "sensors-heiman-hs2aq-air-quality",
zcl_clusters = {
zcl.temperature(),
zcl.humidity(),
zcl.battery(),
zcl.cluster_attribute(0x042A, 0x0000, {
name = "pm25",
emit = emit.pm25(),
data_type = data_types.Uint16,
minimum_interval = 0,
maximum_interval = 3600,
reportable_change = 1,
}),
zcl.cluster_attribute(0x042B, 0x0000, {
name = "formaldehyde",
emit = emit.formaldehyde(),
data_type = data_types.Uint16,
scale = 1000,
minimum_interval = 0,
maximum_interval = 3600,
reportable_change = 1,
}),
zcl.cluster_attribute(0xFC81, 0xF002, {
name = "heiman_battery_state",
emit = emit.heimanHs2aqBatteryState(),
data_type = data_types.Uint8,
mfg_code = 0x120B,
from_device = function(value)
return ({ [0] = "not_charging", [1] = "charging", [2] = "charged" })[value]
end,
minimum_interval = 0,
maximum_interval = 3600,
reportable_change = 1,
}),
zcl.cluster_attribute(0xFC81, 0xF003, {
name = "heiman_pm10",
emit = emit.heimanHs2aqPm10(),
data_type = data_types.Uint16,
mfg_code = 0x120B,
minimum_interval = 0,
maximum_interval = 3600,
reportable_change = 1,
}),
zcl.cluster_attribute(0xFC81, 0xF004, {
name = "voc",
emit = emit.voc(),
data_type = data_types.Uint16,
mfg_code = 0x120B,
minimum_interval = 0,
maximum_interval = 3600,
reportable_change = 1,
}),
zcl.cluster_attribute(0xFC81, 0xF005, {
name = "heiman_aqi",
emit = emit.heimanHs2aqAqi(),
data_type = data_types.Uint16,
mfg_code = 0x120B,
minimum_interval = 0,
maximum_interval = 3600,
reportable_change = 1,
}),
},
}
local terncy_dc01 = {
profile = "safety-contact-temp-battery",
zcl_clusters = {
zcl.cluster_attribute(0x000F, 0x0055, {
name = "contact",
emit = emit.contact(),
data_type = data_types.SinglePrecisionFloat,
from_device = function(value)
return value == 0
end,
minimum_interval = 0,
maximum_interval = 300,
reportable_change = 1,
}),
zcl.temperature({ scale = 10 }),
zcl.cluster_attribute(zcl.CLUSTER_POWER_CONFIGURATION, zcl.ATTR_BATTERY_PERCENTAGE_REMAINING, {
name = "battery",
emit = emit.battery(),
data_type = data_types.Uint8,
scale = 1,
minimum_interval = 300,
maximum_interval = 21600,
reportable_change = 1,
}),
},
}
register_aliases(motion_sensor, {
device_helpers.create_fingerprint("Samotech", "SM301Z"),
})
register_aliases(motion_sensor, {
device_helpers.create_fingerprint("Evology", "PAT04-A"),
device_helpers.create_fingerprint("LDS", "ZHA-PirSensor"),
device_helpers.create_fingerprint("Leedarson", "ZHA-PIRSensor"),
})
register_aliases(motion_sensor, {
device_helpers.create_fingerprint("EGLO", "99106"),
})
register_aliases(motion_sensor, {
device_helpers.create_fingerprint("Blaupunkt", "PSM-S1"),
device_helpers.create_fingerprint("Frient", "MOSZB-153"),
device_helpers.create_fingerprint("Frient", "KEPZB-110"),
device_helpers.create_fingerprint("KnockautX", "FMS2C017"),
device_helpers.create_fingerprint("Piri", "HSIO18008"),
})
register_aliases(motion_sensor, {
device_helpers.create_fingerprint("eWeLink", "CK-TLSR8656-SS5-01(7002)"),
device_helpers.create_fingerprint("eWeLink", "RHK09"),
device_helpers.create_fingerprint("eWeLink", "SQ510A"),
})
register_aliases(motion_illuminance_sensor, {
device_helpers.create_fingerprint("Candeo", "C-ZB-SEMO"),
})
register_aliases(contact_sensor, {
device_helpers.create_fingerprint("Candeo", "C-ZB-SEDC"),
})
register_aliases(contact_sensor, {
device_helpers.create_fingerprint("Sunricher", "HK-SENSOR-CT-A"),
})
register_aliases(contact_sensor, {
device_helpers.create_fingerprint("Shyugj", "DoorSensor-ZB3.0"),
device_helpers.create_fingerprint("SDevices", "SBDV-00196"),
device_helpers.create_fingerprint("SDevices", "SBDV-00199"),
device_helpers.create_fingerprint("SDevices", "SBDV-00202"),
device_helpers.create_fingerprint("SDevices", "SBDV-00205"),
device_helpers.create_fingerprint("Tuya", "WL-19DWZ"),
})
register_aliases(contact_sensor, {
device_helpers.create_fingerprint("eWeLink", "CK-TLSR8656-SS5-01(7003)"),
device_helpers.create_fingerprint("eWeLink", "RHK06"),
device_helpers.create_fingerprint("eWeLink", "SNZB-04"),
device_helpers.create_fingerprint("zbeacon", "DS01"),
})
register_aliases(water_sensor, {
device_helpers.create_fingerprint("Candeo", "C-ZB-SEWA"),
})
register_aliases(water_sensor, {
device_helpers.create_fingerprint("Third Reality, Inc", "3RWS18BZ"),
device_helpers.create_fingerprint("Third Reality, Inc", "3RWS0218Z"),
})
register_aliases(water_sensor, {
device_helpers.create_fingerprint("eWeLink", "CK-TLSR8656-SS5-01(7019)"),
})
register_aliases(temp_humidity_sensor, {
device_helpers.create_fingerprint("Candeo", "C-ZB-SETE"),
})
register_aliases(temp_humidity_sensor, {
device_helpers.create_fingerprint("Frient", "HMSZB-120"),
})
register_aliases(temp_humidity_sensor, {
device_helpers.create_fingerprint("Third Reality, Inc", "3RTHS24BZ"),
device_helpers.create_fingerprint("Third Reality, Inc", "3RTHS0324Z"),
device_helpers.create_fingerprint("Third Reality, Inc", "3RTHS0224Z"),
})
register_aliases(temp_humidity_sensor, {
device_helpers.create_fingerprint("HEIMAN", "HT-EM"),
device_helpers.create_fingerprint("HEIMAN", "TH-EM"),
device_helpers.create_fingerprint("HEIMAN", "TH-T_V14"),
device_helpers.create_fingerprint("HEIMAN", "HT-N"),
device_helpers.create_fingerprint("HEIMAN", "HT-EF-3.0"),
device_helpers.create_fingerprint("HEIMAN", "HS3HT-EFA-3.0"),
})
register_aliases(temp_humidity_sensor, {
device_helpers.create_fingerprint("Sunricher", "ZG9032B"),
})
register_aliases(temp_humidity_sensor, {
device_helpers.create_fingerprint("EFK", "is-thpl-zb"),
device_helpers.create_fingerprint("Futurehome", "Co020"),
device_helpers.create_fingerprint("Heiman", "HS-720ES"),
device_helpers.create_fingerprint("Momax", "SL12S"),
device_helpers.create_fingerprint("Nous", "L14"),
device_helpers.create_fingerprint("Tuya", "TH01Z"),
})
register_aliases(temp_humidity_sensor, {
device_helpers.create_fingerprint("eWeLink", "CK-TLSR8656-SS5-01(7014)"),
device_helpers.create_fingerprint("eWeLink", "RHK08"),
device_helpers.create_fingerprint("Zbeacon", "TH01"),
})
register_aliases(smoke_sensor, {
device_helpers.create_fingerprint("AduroSmart Eria", "Smart Siren"),
device_helpers.create_fingerprint("Fireangel", "Alarm_SD_Device"),
device_helpers.create_fingerprint("Cavius", "2103"),
device_helpers.create_fingerprint("Frient", "94430"),
device_helpers.create_fingerprint("Frient", "94431"),
device_helpers.create_fingerprint("HEIMAN", "HS2AQ-EF-3.0"),
device_helpers.create_fingerprint("Popp", "701721"),
device_helpers.create_fingerprint("Trust", "SmokeSensor-EM"),
})
register_aliases(heiman_air_quality, {
device_helpers.create_fingerprint("HEIMAN", "HS2AQ-EM"),
device_helpers.create_fingerprint("HEIMAN", "HS2AQ-EM-3.0"),
})
register_aliases(terncy_dc01, {
device_helpers.create_fingerprint("Sunricher", "TERNCY-DC01"),
device_helpers.create_fingerprint("TERNCY", "TERNCY-DC01"),
})
register_aliases(smoke_temp_humidity_sensor, {
device_helpers.create_fingerprint("Schneider Electric", "755WSA"),
device_helpers.create_fingerprint("Schneider Electric", "W599501"),
})
register_aliases(illuminance_sensor, {
device_helpers.create_fingerprint("Moes", "ZSS-QT-LS-C"),
})
register_aliases(motion_sensor, {
device_helpers.create_fingerprint("Third Reality, Inc", "3RMS16BZ"),
device_helpers.create_fingerprint("Third Reality, Inc", "3RPS01083Z"),
device_helpers.create_fingerprint("Third Reality, Inc", "3RSMR01067Z"),
})
register_aliases(contact_sensor, {
device_helpers.create_fingerprint("Third Reality, Inc", "3RDS17BZ"),
device_helpers.create_fingerprint("Third Reality, Inc", "3RDTS01056Z"),
})
return device_definitions
