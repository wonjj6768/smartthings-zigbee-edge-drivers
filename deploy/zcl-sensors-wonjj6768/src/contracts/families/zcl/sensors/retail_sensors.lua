local zcl=require "protocol.zcl"
local device_helpers=require "contracts.helpers.family"
local emit=require "capabilities.events.all"
local data_types=require "st.zigbee.data_types"
local device_management=require "st.zigbee.device_management"
local shared_definitions=require "contracts.helpers.zcl_sensor_definitions"
local fp=device_helpers.create_fingerprint
local device_definitions,register_device_definition=device_helpers.definition_registry()
local function register_aliases(definition,aliases)
register_device_definition(definition,aliases)
end
local function bind_clusters_by_endpoint(bindings)
return function(driver,device)
for _,binding in ipairs(bindings)do
for _,cluster_id in ipairs(binding.clusters)do
device:send(device_management.build_bind_request(
device,
cluster_id,
driver.environment_info.hub_zigbee_eui,
binding.endpoint
))
end
end
end
end
local function notification_only_ias(mapping)
mapping.minimum_interval=nil
mapping.maximum_interval=nil
mapping.reportable_change=nil
mapping.read_on_configure=false
return mapping
end
local motion_sensor={
profile="safety-motion-battery",
zcl_clusters={
zcl.motion(),
zcl.battery(),
},
}
local motion_battery_low_battery_voltage_sensor={
profile="safety-motion-battery-low-battery-voltage",
zcl_clusters={
zcl.motion(),
zcl.battery_low(),
zcl.battery(),
zcl.battery_voltage(),
},
}
local ewelink_motion_sensor={
profile="safety-motion-battery-low-battery-voltage-ewelink-pending",
zcl_clusters={
notification_only_ias(zcl.motion()),
notification_only_ias(zcl.battery_low()),
zcl.battery({
minimum_interval=3600,
maximum_interval=7200,
reportable_change=2,
read_on_configure=true,
}),
zcl.battery_voltage({
minimum_interval=3600,
maximum_interval=7200,
reportable_change=100,
read_on_configure=true,
}),
},
}
local third_reality_3rms_motion_sensor={
profile="safety-motion-battery-low-battery-voltage-3rms-pending",
zcl_clusters={
zcl.motion(),
zcl.battery_low(),
zcl.battery(),
zcl.battery_voltage(),
},
}
local third_reality_3rsmr_motion_sensor={
profile="safety-motion-battery-low-battery-voltage-3rsmr-pending",
zcl_clusters={
zcl.motion(),
zcl.battery_low(),
zcl.battery(),
zcl.battery_voltage(),
},
}
local third_reality_3rps_presence_sensor={
profile="safety-motion-battery-3rps-pending",
zcl_clusters={
zcl.motion(),
zcl.battery(),
},
}
local motion_tamper_battery_low_battery_sensor={
profile="safety-motion-tamper-battery-battery-low",
zcl_clusters={
zcl.motion(),
zcl.tamper(),
zcl.battery_low(),
zcl.battery(),
},
}
local occupancy_motion_illuminance_sensor={
profile="safety-motion-illuminance",
zcl_clusters={
zcl.occupancy({emit=emit.motion()}),
zcl.illuminance(),
},
}
local motion_illuminance_sensor={
profile="safety-motion-illuminance-battery",
zcl_clusters={
zcl.motion(),
zcl.illuminance(),
zcl.battery(),
},
}
local candeo_motion_illuminance_sensor={
profile="safety-motion-illuminance-battery-candeo-pending",
zcl_clusters={
zcl.tuya_magic_packet(),
zcl.motion(),
zcl.illuminance(),
zcl.battery(),
},
}
local contact_sensor={
profile="safety-contact-battery",
zcl_clusters={
zcl.contact(),
zcl.battery(),
},
}
local contact_battery_low_sensor={
profile="safety-contact-battery-low-battery",
zcl_clusters={
zcl.contact(),
zcl.battery_low(),
zcl.battery(),
},
}
local shyugj_contact_sensor={
profile="safety-contact-tamper-battery-low-battery",
zcl_clusters={
zcl.contact_alarm_1_or_2(),
zcl.tamper(),
zcl.battery_low(),
zcl.battery(),
},
}
local ewelink_contact_sensor={
profile="safety-contact-battery-low-battery-voltage",
zcl_clusters={
zcl.contact(),
zcl.battery_low(),
zcl.battery(),
zcl.battery_voltage(),
},
}
local third_reality_door_sensor={
profile="safety-contact-battery-low-battery-voltage",
zcl_clusters={
zcl.contact(),
zcl.battery_low(),
zcl.battery(),
zcl.battery_voltage(),
},
}
local third_reality_tilt_sensor={
profile="safety-contact-battery-low-battery",
zcl_clusters={
zcl.contact(),
zcl.battery_low(),
zcl.battery(),
},
}
local water_sensor={
profile="safety-water-leak-battery",
zcl_clusters={
zcl.water(),
zcl.battery(),
},
}
local water_battery_low_battery_sensor=shared_definitions.water_battery_low_battery_sensor
local third_reality_water_sensor_pending={
profile="safety-water-leak-battery-low-battery-3rws18bz-pending",
zcl_clusters={
zcl.water(),
zcl.battery_low(),
zcl.battery(),
},
}
local temp_humidity_sensor={
profile="sensors-temp-humidity-battery",
zcl_clusters={
zcl.temperature(),
zcl.humidity(),
zcl.battery(),
},
}
local temp_humidity_voltage_sensor={
profile="sensors-temp-humidity-battery-voltage",
zcl_clusters={
zcl.temperature(),
zcl.humidity(),
zcl.battery(),
zcl.battery_voltage(),
},
}
local frient_temp_humidity_sensor={
profile="sensors-temp-humidity-battery-voltage",
zcl_clusters={
zcl.temperature({endpoint=38}),
zcl.humidity({endpoint=38}),
zcl.battery({endpoint=38}),
zcl.battery_voltage({endpoint=38}),
},
configure=bind_clusters_by_endpoint({
{endpoint=38,clusters={0x0402,0x0405,0x0001}},
}),
}
local third_reality_3rths_sensor={
profile="sensors-temp-humidity-battery-3rths-pending",
zcl_clusters={
zcl.temperature(),
zcl.humidity(),
zcl.battery(),
},
}
local third_reality_3rths0324_sensor={
profile="sensors-temp-humidity-battery-3rths0324-pending",
advanced_remote=true,
zcl_clusters={
zcl.temperature(),
zcl.humidity(),
zcl.battery(),
zcl.cluster_attribute(0xFF01,0x0031,{
name="third_rths0324_celsius_calibration",
emit=emit.thirdRths0324CelsiusCal(),
data_type=data_types.Int16,
scale=100,
mfg_code=0x1407,
minimum_interval=0,
maximum_interval=3600,
reportable_change=100,
}),
zcl.cluster_attribute(0xFF01,0x0032,{
name="third_rths0324_humidity_calibration",
emit=emit.thirdRths0324HumidityCal(),
data_type=data_types.Int16,
scale=100,
mfg_code=0x1407,
minimum_interval=0,
maximum_interval=3600,
reportable_change=100,
}),
zcl.cluster_attribute(0xFF01,0x0033,{
name="third_rths0324_fahrenheit_calibration",
emit=emit.thirdRths0324FahrenheitCal(),
data_type=data_types.Int16,
scale=100,
mfg_code=0x1407,
minimum_interval=0,
maximum_interval=3600,
reportable_change=100,
}),
},
}
local heiman_ht_em_sensor={
profile="sensors-temp-humidity-battery",
zcl_clusters={
zcl.temperature({endpoint=1}),
zcl.humidity({endpoint=2}),
zcl.battery({endpoint=2}),
},
configure=bind_clusters_by_endpoint({
{endpoint=1,clusters={0x0402}},
{endpoint=2,clusters={0x0405,0x0001}},
}),
}
local heiman_ht_n_sensor={
profile="sensors-temp-humidity-battery",
zcl_clusters={
zcl.temperature({endpoint=1}),
zcl.humidity({endpoint=2}),
zcl.battery({endpoint=1}),
},
configure=bind_clusters_by_endpoint({
{endpoint=1,clusters={0x0402,0x0001}},
{endpoint=2,clusters={0x0405}},
}),
}
local sunricher_zg9032b_sensor={
profile="sensors-temp-humidity-battery-zg9032b",
zcl_clusters={
zcl.temperature({endpoint=1}),
zcl.humidity({endpoint=2}),
zcl.battery({endpoint=1}),
zcl.cluster_attribute(0x0402,0x1000,{
name="zg9032b_temperature_compensation",
endpoint=1,
emit=emit.zg9032bTemperatureCompensation(),
data_type=data_types.Int8,
write_type=data_types.Int8,
mfg_code=0x1224,
numeric_range={minimum=-5,maximum=5,step=1,unit="C"},
read_on_configure=true,
}),
zcl.cluster_attribute(0x0402,0x1001,{
name="zg9032b_temperature_display_unit",
endpoint=1,
emit=emit.zg9032bTemperatureDisplayUnit(),
data_type=data_types.Enum8,
write_type=data_types.Enum8,
mfg_code=0x1224,
from_device=function(value)
return({[0]="celsius",[1]="fahrenheit"})[value]
end,
to_device=function(value)
return({celsius=0,fahrenheit=1})[value]
end,
read_on_configure=true,
}),
zcl.cluster_attribute(0x0405,0x1000,{
name="zg9032b_humidity_compensation",
endpoint=2,
emit=emit.zg9032bHumidityCompensation(),
data_type=data_types.Int8,
write_type=data_types.Int8,
mfg_code=0x1224,
numeric_range={minimum=-5,maximum=5,step=1,unit="%"},
read_on_configure=true,
}),
},
configure=bind_clusters_by_endpoint({
{endpoint=1,clusters={0x0402,0x0001}},
{endpoint=2,clusters={0x0405}},
}),
}
local smoke_sensor={
profile="safety-smoke-detector-battery",
zcl_clusters={
zcl.smoke(),
zcl.battery(),
},
}
local schneider_smoke_sensor={
profile="safety-smoke-temp-tamper-battery-low-battery-voltage-schneider-pending",
zcl_clusters={
zcl.smoke(),
zcl.temperature(),
zcl.tamper(),
zcl.battery_low(),
zcl.battery(),
zcl.battery_voltage(),
},
}
local illuminance_sensor={
profile="sensors-illuminance-battery",
zcl_clusters={
zcl.illuminance(),
zcl.battery(),
},
}
local heiman_air_quality={
profile="sensors-heiman-hs2aq-air-quality",
zcl_clusters={
zcl.temperature(),
zcl.humidity(),
zcl.battery(),
zcl.cluster_attribute(0x042A,0x0000,{
name="pm25",
emit=emit.pm25(),
data_type=data_types.Uint16,
minimum_interval=0,
maximum_interval=3600,
reportable_change=1,
}),
zcl.cluster_attribute(0x042B,0x0000,{
name="formaldehyde",
emit=emit.formaldehyde(),
data_type=data_types.Uint16,
scale=1000,
minimum_interval=0,
maximum_interval=3600,
reportable_change=1,
}),
zcl.cluster_attribute(0xFC81,0xF002,{
name="heiman_battery_state",
emit=emit.heimanHs2aqBatteryState(),
data_type=data_types.Uint8,
mfg_code=0x120B,
from_device=function(value)
return({[0]="not_charging",[1]="charging",[2]="charged"})[value]
end,
minimum_interval=0,
maximum_interval=3600,
reportable_change=1,
}),
zcl.cluster_attribute(0xFC81,0xF003,{
name="heiman_pm10",
emit=emit.heimanHs2aqPm10(),
data_type=data_types.Uint16,
mfg_code=0x120B,
minimum_interval=0,
maximum_interval=3600,
reportable_change=1,
}),
zcl.cluster_attribute(0xFC81,0xF004,{
name="voc",
emit=emit.voc(),
data_type=data_types.Uint16,
mfg_code=0x120B,
minimum_interval=0,
maximum_interval=3600,
reportable_change=1,
}),
zcl.cluster_attribute(0xFC81,0xF005,{
name="heiman_aqi",
emit=emit.heimanHs2aqAqi(),
data_type=data_types.Uint16,
mfg_code=0x120B,
minimum_interval=0,
maximum_interval=3600,
reportable_change=1,
}),
},
configure=function(driver,device)
for _,cluster_id in ipairs({0x0001,0x000A,0x0402,0x0405,0x042A,0x042B,0xFC81})do
device:send(device_management.build_bind_request(
device,
cluster_id,
driver.environment_info.hub_zigbee_eui,
1
))
end
end,
}
local terncy_dc01={
profile="safety-contact-temp-battery",
zcl_clusters={
zcl.cluster_attribute(0x000F,0x0055,{
name="contact",
emit=emit.contact(),
data_type=data_types.SinglePrecisionFloat,
from_device=function(value)
return value==0
end,
minimum_interval=0,
maximum_interval=300,
reportable_change=1,
}),
zcl.temperature({scale=10}),
zcl.cluster_attribute(zcl.CLUSTER_POWER_CONFIGURATION,zcl.ATTR_BATTERY_PERCENTAGE_REMAINING,{
name="battery",
emit=emit.battery(),
data_type=data_types.Uint8,
scale=1,
minimum_interval=300,
maximum_interval=21600,
reportable_change=1,
}),
},
}
local sunricher_terncy_dc01={
profile="safety-contact-battery",
zcl_clusters={
zcl.cluster_attribute(0x000F,0x0055,{
name="contact",
emit=emit.contact(),
data_type=data_types.SinglePrecisionFloat,
from_device=function(value)
return value==0
end,
minimum_interval=0,
maximum_interval=300,
reportable_change=1,
}),
zcl.cluster_attribute(zcl.CLUSTER_POWER_CONFIGURATION,zcl.ATTR_BATTERY_PERCENTAGE_REMAINING,{
name="battery",
emit=emit.battery(),
data_type=data_types.Uint8,
scale=1,
minimum_interval=300,
maximum_interval=21600,
reportable_change=1,
}),
},
}
register_aliases(motion_tamper_battery_low_battery_sensor,{
fp("LDS","ZHA-PirSensor"),
})
register_aliases(occupancy_motion_illuminance_sensor,{
fp("Leedarson","ZHA-PIRSensor"),
})
register_aliases(ewelink_motion_sensor,{
fp("eWeLink","CK-TLSR8656-SS5-01(7002)"),
fp("eWeLink","MS01"),
fp("eWeLink","MSO1"),
fp("eWeLink","SNZB-03"),
fp("SONOFF","CK-TLSR8656-SS5-01(7002)"),
fp("SONOFF","MS01"),
fp("SONOFF","MSO1"),
fp("SONOFF","SNZB-03"),
})
register_aliases(candeo_motion_illuminance_sensor,{
fp("Candeo","C-ZB-SEMO"),
})
register_aliases(contact_sensor,{
fp("Candeo","C-ZB-SEDC"),
})
register_aliases(contact_sensor,{
fp("Sunricher","HK-SENSOR-CT-A"),
})
register_aliases(contact_battery_low_sensor,{
fp("Sunricher","HK-SENSOR-CT-MINI"),
})
register_aliases(shyugj_contact_sensor,{
fp("Shyugj","DoorSensor-ZB3.0"),
})
register_aliases(ewelink_contact_sensor,{
fp("eWeLink","CK-TLSR8656-SS5-01(7003)"),
fp("eWeLink","SNZB-04"),
})
register_aliases(water_sensor,{
fp("Candeo","C-ZB-SEWA"),
})
register_aliases(third_reality_water_sensor_pending,{
fp("Third Reality, Inc","3RWS18BZ"),
})
register_aliases(water_sensor,{
fp("Third Reality, Inc","3RWS0218Z"),
})
register_aliases(water_battery_low_battery_sensor,{
fp("eWeLink","CK-TLSR8656-SS5-01(7019)"),
fp("eWeLink","SNZB-05"),
})
register_aliases(temp_humidity_sensor,{
fp("Candeo","C-ZB-SETE"),
})
register_aliases(frient_temp_humidity_sensor,{
fp("Frient","HMSZB-120"),
})
register_aliases(third_reality_3rths_sensor,{
fp("Third Reality, Inc","3RTHS24BZ"),
fp("Third Reality, Inc","3RTHS0224Z"),
})
register_aliases(third_reality_3rths0324_sensor,{
fp("Third Reality, Inc","3RTHS0324Z"),
})
register_aliases(heiman_ht_em_sensor,{
fp("HEIMAN","HT-EM"),
fp("HEIMAN","TH-EM"),
fp("HEIMAN","TH-T_V14"),
})
register_aliases(heiman_ht_n_sensor,{
fp("HEIMAN","HT-N"),
fp("HEIMAN","HT-EF-3.0"),
fp("HEIMAN","HS3HT-EFA-3.0"),
})
register_aliases(sunricher_zg9032b_sensor,{
fp("Sunricher","ZG9032B"),
})
register_aliases(temp_humidity_voltage_sensor,{
fp("eWeLink","CK-TLSR8656-SS5-01(7014)"),
fp("Zbeacon","TH01"),
})
register_aliases(heiman_air_quality,{
fp("HEIMAN","HS2AQ-EM"),
fp("HEIMAN","HS2AQ-EM-3.0"),
})
register_aliases(terncy_dc01,{
fp("TERNCY","TERNCY-DC01"),
})
register_aliases(sunricher_terncy_dc01,{
fp("Sunricher","TERNCY-DC01"),
})
register_aliases(schneider_smoke_sensor,{
fp("Schneider Electric","755WSA"),
fp("Schneider Electric","W599501"),
})
register_aliases(third_reality_3rms_motion_sensor,{
fp("Third Reality, Inc","3RMS16BZ"),
})
register_aliases(third_reality_3rsmr_motion_sensor,{
fp("Third Reality, Inc","3RSMR01067Z"),
})
register_aliases(third_reality_3rps_presence_sensor,{
fp("Third Reality, Inc","3RPS01083Z"),
})
register_aliases(third_reality_door_sensor,{
fp("Third Reality, Inc","3RDS17BZ"),
})
register_aliases(third_reality_tilt_sensor,{
fp("Third Reality, Inc","3RDTS01056Z"),
})
return{
id="zcl.sensors.retail_sensors",
registrations=device_definitions,
}
