local zcl=require "protocol.zcl"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local fp=device_helpers.create_fingerprint
local data_types=require "st.zigbee.data_types"
local caps=require "st.capabilities"
local device_management=require "st.zigbee.device_management"
local cluster_base=require "st.zigbee.cluster_base"
local buf=require "st.buf"
local device_definitions,register_device_definition=device_helpers.definition_registry()
local CLUSTER_POWER_CONFIGURATION=0x0001
local CLUSTER_TIME=0x000A
local CLUSTER_PM25=0x042A
local CLUSTER_FORMALDEHYDE=0x042B
local CLUSTER_HEIMAN_AIR_QUALITY=0xFC81
local function temp_report(minimum,maximum,change,endpoint,read_on_configure)
return zcl.temperature({endpoint=endpoint,minimum_interval=minimum,maximum_interval=maximum,reportable_change=change,read_on_configure=read_on_configure})
end
local function hum_report(minimum,maximum,change,endpoint,read_on_configure)
return zcl.humidity({endpoint=endpoint,minimum_interval=minimum,maximum_interval=maximum,reportable_change=change,read_on_configure=read_on_configure})
end
local function standard_temp(endpoint,read_on_configure)
return zcl.temperature({endpoint=endpoint or 1,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=read_on_configure})
end
local function standard_hum(endpoint,read_on_configure)
return zcl.humidity({endpoint=endpoint,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=read_on_configure})
end
local function custom(capability_id)
return assert(emit[capability_id],"missing Wave19 environment emitter: " .. capability_id)()
end
local function local_timezone_offset(now)
local local_time=os.date("*t",now)
local utc_time=os.date("!*t",now)
local_time.isdst=false
utc_time.isdst=false
return math.floor(os.difftime(os.time(local_time),os.time(utc_time)))
end
local function send_time_write(device,attribute_id,typed_value)
local request=cluster_base.write_attribute(
device,
data_types.ClusterId(CLUSTER_TIME),
data_types.AttributeId(attribute_id),
typed_value
)
if type(request.to_endpoint)=="function" then request=request:to_endpoint(1)end
device:send(request)
end
local function configure_heiman(driver,device)
device:send(device_management.build_bind_request(
device,
CLUSTER_TIME,
driver.environment_info.hub_zigbee_eui,
1
))
local unix_time=os.time()
local zigbee_time=math.max(0,unix_time - 946684800)
send_time_write(device,0x0001,data_types.Bitmap8(3))
send_time_write(device,0x0000,data_types.Uint32(zigbee_time))
send_time_write(device,0x0002,data_types.Int32(local_timezone_offset(unix_time)))
end
local heiman={
profile="sensors-wave19-heiman-hs2aq-ef-three",
package_group="wave19-environment",
transport_classification="CUSTOM_PAYLOAD",
z2m_converter_source="standard ZCL + heimanSpecificAirQuality short cluster",
wire_cluster="0x0001/0x000A/0x0402/0x0405/0x042A/0x042B/0xFC81",
zcl_clusters={
temp_report(10,3600,100,nil,nil),
hum_report(10,3600,100,nil,nil),
zcl.battery({
minimum_interval=3600,
maximum_interval=65000,
reportable_change=10,
}),
zcl.cluster_attribute(CLUSTER_PM25,0x0000,{
name="pm25",
emit=emit.pm25(),
data_type=data_types.Uint16,
minimum_interval=0,
maximum_interval=3600,
reportable_change=1,
read_on_configure=true,
read_only=true,
}),
zcl.cluster_attribute(CLUSTER_FORMALDEHYDE,0x0000,{
name="formaldehyde",
emit=emit.formaldehyde(),
data_type=data_types.Uint16,
scale=1000,
minimum_interval=0,
maximum_interval=3600,
reportable_change=1,
read_on_configure=true,
read_only=true,
}),
zcl.cluster_attribute(CLUSTER_HEIMAN_AIR_QUALITY,0xF002,{
name="heiman_ef_three_charging_status",
emit=custom("heimanEfThreeChargingStatus"),
data_type=data_types.Uint8,
from_device=function(value)
return({[0]="NotCharged",[1]="Charging",[2]="FullyCharged"})[tonumber(value)]
end,
minimum_interval=0,
maximum_interval=3600,
reportable_change=1,
read_on_configure=true,
read_only=true,
}),
zcl.cluster_attribute(CLUSTER_HEIMAN_AIR_QUALITY,0xF003,{
name="heiman_ef_three_pm_ten",
emit=custom("heimanEfThreePmTen"),
data_type=data_types.Uint16,
minimum_interval=0,
maximum_interval=3600,
reportable_change=1,
read_on_configure=true,
read_only=true,
}),
zcl.cluster_attribute(CLUSTER_HEIMAN_AIR_QUALITY,0xF005,{
name="heiman_ef_three_aqi",
emit=custom("heimanEfThreeAqi"),
data_type=data_types.Uint16,
minimum_interval=0,
maximum_interval=3600,
reportable_change=1,
read_on_configure=true,
read_only=true,
}),
},
configure=configure_heiman,
}
register_device_definition(heiman,{
fp("HEIMAN","HS2AQ-EF-3.0"),
})
local function clamp(value,minimum,maximum)
if value < minimum then return minimum end
if value > maximum then return maximum end
return value
end
local function plaid_battery_events(_,value)
local voltage_mv=tonumber(value)
if voltage_mv==nil then return nil end
local percentage=math.floor((((clamp(voltage_mv,2500,3000)- 2500)/ 500)* 100)+ 0.5)
return{
caps.battery.battery(percentage),
caps.voltageMeasurement.voltage({value=voltage_mv / 1000,unit="V"}),
}
end
local function configure_plaid(driver,device)
device:send(device_management.build_bind_request(
device,
CLUSTER_POWER_CONFIGURATION,
driver.environment_info.hub_zigbee_eui,
1
))
end
local plaid={
profile="sensors-wave19-plaid-spruce",
package_group="wave19-environment",
transport_classification="CUSTOM_PAYLOAD",
z2m_converter_source="fz.temperature+fz.humidity+fzLocal.plaid_battery",
wire_cluster="0x0402/0x0405/0x0001 attr 0x0000",
zcl_clusters={
temp_report(10,3600,100,nil,nil),
hum_report(10,3600,100,nil,nil),
zcl.cluster_attribute(CLUSTER_POWER_CONFIGURATION,0x0000,{
name="plaid_mains_voltage_battery",
emit=plaid_battery_events,
data_type=data_types.Uint16,
read_only=true,
}),
},
configure=configure_plaid,
}
register_device_definition(plaid,{
fp("PLAID SYSTEMS","PS-SPRZMS-SLP3"),
})
local function core_battery_value(value,_,context)
if context and context.raw_value==0xFF then return nil end
return value
end
local function voltage_preferred_battery(value,_,context)
local body=context.zb_rx.body.zcl_body
local voltage=type(body.get_attribute_data)=="function" and body:get_attribute_data(0x20)
if type(voltage)=="table" then voltage=voltage.value end
if type(voltage)=="number" and voltage<255 then return end
if context.raw_value~=255 then return value end
end
local function core_battery(options)
options.from_device=options.from_device or core_battery_value
return zcl.battery(options)
end
local function core_voltage(options)
options.from_device=options.from_device or core_battery_value
return zcl.battery_voltage(options)
end
local function zigbeetlc_th_clusters(temperature_change,humidity_change)
return{
zcl.temperature({minimum_interval=10,maximum_interval=3600,reportable_change=temperature_change}),
zcl.humidity({minimum_interval=10,maximum_interval=3600,reportable_change=humidity_change}),
core_battery({minimum_interval=3600,maximum_interval=65000,reportable_change=10}),
zcl.power_configuration_battery_voltage({name="battery_voltage",emit=emit.voltage(),
scale=10,read_only=true,read_on_configure=false,from_device=core_battery_value}),
}
end
local zigbeetlc_th05_core={
profile="sensors-zigbeetlc-th05-core",
zcl_clusters=zigbeetlc_th_clusters(10,100),
}
register_device_definition(zigbeetlc_th05_core,{
fp("Tuya","TH05-z"),
fp("Xiaomi","LYWSD03MMC-z"),
fp("Xiaomi","MJWSD06MMC-z"),
fp("MiaoMiaoCe","MHO-C122-z"),
fp("MiaoMiaoCe","MHO-C401-z"),
fp("MiaoMiaoCe","MHO-C401N-z"),
fp("Qingping","CGG1-z"),
fp("Qingping","CGG1N-z"),
fp("Xiaomi","LYWSD03MMC-bz"),
fp("Xiaomi","MJWSD06MMC-bz"),
fp("MiaoMiaoCe","MHO-C122-bz"),
fp("MiaoMiaoCe","MHO-C401-bz"),
fp("MiaoMiaoCe","MHO-C401N-bz"),
fp("Qingping","CGG1-bz"),
fp("Qingping","CGG1N-bz"),
})
local zigbeetlc_display_core={
profile="sensors-zigbeetlc-display-core",
zcl_clusters=zigbeetlc_th_clusters(10,100),
}
register_device_definition(zigbeetlc_display_core,{
fp("Qingping","CGDK2-z"),
fp("Qingping","CGDK2-bz"),
fp("Tuya","LKTMZL02-z"),
})
local zigbeetlc_basic_core={
profile="sensors-zigbeetlc-basic-core",
zcl_clusters=zigbeetlc_th_clusters(10,100),
}
register_device_definition(zigbeetlc_basic_core,{
fp("Tuya","TS0201-z"),
fp("Wing","TS0201-z"),
fp("Tuya","TH03Z-z"),
fp("Tuya","ZTH01-z"),
fp("Tuya","ZTH02-z"),
fp("Tuya","ZY-ZTH02-z"),
fp("Tuya","TS0201-bz"),
fp("Tuya","TH03Z-bz"),
fp("Tuya","ZTH01-bz"),
fp("Tuya","ZTH02-bz"),
})
local zigbeetlc_zg227_core={
profile="sensors-zigbeetlc-zg227-core",
zcl_clusters=zigbeetlc_th_clusters(100,100),
}
register_device_definition(zigbeetlc_zg227_core,{
fp("Tuya","ZG-227Z-z"),
})
local zigbeetlc_zbeacon_core={
profile="sensors-zigbeetlc-zbeacon-core",
zcl_clusters=zigbeetlc_th_clusters(10,50),
}
register_device_definition(zigbeetlc_zbeacon_core,{
fp("ZBeacon","MC-z"),
fp("ZBeacon","TH01-z"),
fp("ZBeacon","TH01-2-z"),
})
local zigbeetlc_ts202pir1_core={
profile="safety-motion-battery-voltage",
zcl_clusters={
zcl.occupancy({emit=emit.motion(),minimum_interval=0,maximum_interval=3600,reportable_change=0,
from_device=function(value)
if type(value)=="table" then value=value.value end
return(value & 1)~=0
end}),
core_battery({minimum_interval=3600,maximum_interval=65000,reportable_change=10}),
zcl.power_configuration_battery_voltage({name="battery_voltage",emit=emit.voltage(),
scale=10,read_only=true,read_on_configure=true,from_device=core_battery_value}),
},
}
register_device_definition(zigbeetlc_ts202pir1_core,{
fp("Tuya","TS202PIR1-z"),
})
local function battery_2500_3000_percent(value)
if value==255 then return nil end
return math.floor(math.max(0,math.min(100,(value-25)*20))+0.5)
end
local function battery_2500_3000_mapping(name,endpoint,read_on_configure)
return zcl.cluster_attribute(1,0x20,{
name=name or "battery_voltage_percent",endpoint=endpoint or 1,data_type=data_types.Uint8,read_only=true,
minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=read_on_configure,
from_device=battery_2500_3000_percent,emit=emit.battery(),
})
end
local function linear_voltage_events(_,value)
if value==255 then return end
return{caps.battery.battery(battery_2500_3000_percent(value)),caps.voltageMeasurement.voltage({value=value/10,unit="V"})}
end
local function core_battery_alarm(_,value)
return(value & 0xF03C0F)~=0 and caps.batteryLevel.battery.critical()or caps.batteryLevel.battery.normal()
end
local function low_battery_event(_,value)
return value and caps.batteryLevel.battery.critical()or caps.batteryLevel.battery.normal()
end
local function notification(mapping,emitter)
mapping.minimum_interval=nil
mapping.maximum_interval=nil
mapping.reportable_change=nil
mapping.read_on_configure=false
mapping.emit=function(device,value,context)
if context.command_id==0 then return emitter(device,value)end
end
return mapping
end
local function radion_clusters()
return{
notification(zcl.motion({endpoint=1,from_device=function(value)
if type(value)=="table" then value=value.value end
return(value&1)~=0
end}),emit.motion()),
notification(zcl.tamper({endpoint=1}),emit.tamper()),
notification(zcl.battery_low({endpoint=1}),low_battery_event),
standard_temp(1,false),
zcl.illuminance({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=5,read_on_configure=true}),
zcl.cluster_attribute(1,0x20,{name="radion_voltage",endpoint=1,data_type=data_types.Uint8,read_only=true,
minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,
emit=linear_voltage_events}),
zcl.cluster_attribute(1,0x3E,{name="radion_battery_alarm",endpoint=1,data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=core_battery_alarm}),
}
end
local function radion_refresh(device)zcl.read_attribute(device,0x0400,0,1)end
local bosch_radion_core={
profile="safety-motion-bosch-radion-core",
parent_refresh=radion_refresh,
zcl_clusters=radion_clusters(),
}
register_device_definition(bosch_radion_core,{
fp("BOSCH","RFDL-ZB-MS"),
fp("BOSCH","RFDL-ZB"),
fp("BOSCH","RFDL-ZB-EU"),
fp("BOSCH","RFDL-ZB-H"),
fp("BOSCH","RFDL-ZB-K"),
fp("BOSCH","RFDL-ZB-CHI"),
fp("BOSCH","RFDL-ZB-ES"),
fp("BOSCH","RFPR-ZB"),
fp("BOSCH","RFPR-ZB-EU"),
fp("BOSCH","RFPR-ZB-CHI"),
fp("BOSCH","RFPR-ZB-ES"),
fp("BOSCH","RFPR-ZB-MS"),
})
local function hmszb_battery_events(_,value)
if value==0xFF then return nil end
local percent=math.floor(math.max(0,math.min(100,(value-25)*100/7))+0.5)
return{
caps.battery.battery(percent),
caps.voltageMeasurement.voltage({value=value/10,unit="V"}),
}
end
local develco_hmszb_core={
profile="sensors-hmszb-core",
zcl_clusters={
standard_temp(38),
standard_hum(38,nil),
zcl.cluster_attribute(0x0001,0x0020,{
name="hmszb_battery_voltage",endpoint=38,data_type=data_types.Uint8,read_only=true,
minimum_interval=3600,maximum_interval=65000,reportable_change=10,
emit=hmszb_battery_events,
}),
},
}
register_device_definition(develco_hmszb_core,{
fp("Develco Products A/S","HMSZB-110"),
fp("Develco Products A/S","HMSZB-120"),
fp("frient A/S","HMSZB-110"),
fp("frient A/S","HMSZB-120"),
})
local function moszb_motion_mapping()
local mapping=zcl.occupancy({ias_zone=true,endpoint=35,read_only=true,emit=emit.motion()})
mapping.minimum_interval=nil
mapping.maximum_interval=nil
mapping.reportable_change=nil
return mapping
end
local function moszb_battery_events(_,value)
if type(value)=="table" then value=value.value end
return linear_voltage_events(nil,value)
end
local develco_moszb130_core={
profile="safety-motion-moszb130-core",
zcl_clusters={moszb_motion_mapping()},
}
register_device_definition(develco_moszb130_core,{
fp("Develco Products A/S","MOSZB-130"),
})
local develco_moszb141_core={
profile="safety-motion-moszb141-core",
zcl_clusters={moszb_motion_mapping()},
}
register_device_definition(develco_moszb141_core,{
fp("Develco Products A/S","MOSZB-141"),
fp("frient A/S","MOSZB-141"),
})
local develco_moszb140_core={
profile="safety-motion-moszb140-core",
parent_refresh=function(device)
zcl.read_attribute(device,0x0402,0,38)
zcl.read_attribute(device,0x0400,0,39)
zcl.read_attribute(device,1,0x20,35)
end,
zcl_clusters={
notification(zcl.motion({endpoint=35}),emit.motion()),
notification(zcl.tamper({endpoint=35}),emit.tamper()),
notification(zcl.battery_low({endpoint=35}),low_battery_event),
temp_report(60,3600,100,38,true),
zcl.illuminance({endpoint=39,minimum_interval=300,maximum_interval=3600,reportable_change=100,read_on_configure=true}),
zcl.cluster_attribute(0x0001,0x0020,{
name="moszb_battery_voltage",endpoint=35,data_type=data_types.Uint8,read_only=true,
minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,emit=moszb_battery_events,
}),
},
}
register_device_definition(develco_moszb140_core,{
fp("Develco Products A/S","MOSZB-140"),
fp("frient A/S","MOSZB-140"),
fp("Develco Products A/S","GWA1511_MotionSensor"),
})
local frient_moszb153_core={
profile="safety-motion-moszb153-core",
zcl_clusters={
zcl.occupancy({endpoint=35,ias_zone=true,emit=emit.motion(),read_on_configure=true,
minimum_interval=0,maximum_interval=65000,reportable_change=0}),
standard_temp(38),
zcl.illuminance({endpoint=39,component="main",minimum_interval=60,maximum_interval=3600,reportable_change=500,read_on_configure=true}),
zcl.cluster_attribute(0x0001,0x0020,{
name="moszb_battery_voltage",endpoint=35,data_type=data_types.Uint8,read_only=true,
minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,emit=moszb_battery_events,
}),
zcl.cluster_attribute(1,0x21,{
name="moszb153_battery_percentage",endpoint=35,data_type=data_types.Uint8,read_only=true,read_on_configure=false,scale=2,
from_device=voltage_preferred_battery,emit=emit.battery(),
}),
},
}
register_device_definition(frient_moszb153_core,{
fp("frient A/S","MOSZB-153"),
fp("Develco Products A/S","MOSZB-153"),
})
local function centralite_motion_mapping()
local mapping=zcl.occupancy({ias_zone=true,endpoint=1,read_only=true,emit=emit.motion(),
from_device=function(value)
if type(value)=="table" then value=value.value end
return(value & 2)~=0
end})
mapping.minimum_interval=nil
mapping.maximum_interval=nil
mapping.reportable_change=nil
return mapping
end
local function centralite_battery_events(_,value)
if value==0xFF then return nil end
return{
caps.battery.battery(math.floor(math.max(0,math.min(100,(value-21)*100/9))+0.5)),
caps.voltageMeasurement.voltage({value=value/10,unit="V"}),
}
end
local centralite_motion_a_core={
profile="safety-motion-centralite-a-core",
zcl_clusters={
centralite_motion_mapping(),
standard_temp(),
zcl.cluster_attribute(0x0001,0x0020,{
name="centralite_battery_voltage",endpoint=1,data_type=data_types.Uint8,read_only=true,
minimum_interval=3600,maximum_interval=65000,reportable_change=0,emit=centralite_battery_events,
}),
},
}
register_device_definition(centralite_motion_a_core,{
fp("CentraLite","Motion Sensor-A"),
})
local function owon_ths317_endpoint(device)
return device.zigbee_endpoints and device.zigbee_endpoints[3]and 3 or 1
end
local function owon_temperature_from_device(value,_,context)
local raw=context and context.raw_value or value
if raw >=32767 then return nil end
return context and value or raw / 100
end
local function owon_battery_from_device(value,_,context)
local raw=context and context.raw_value or value
if raw >=255 then return nil end
return context and value or raw / 2
end
local function owon_voltage_from_device(value,_,context)
local raw=context and context.raw_value or value
if raw >=255 then return nil end
return context and value or raw / 10
end
local owon_ths317_et={
profile="sensors-owon-ths317-et",
zcl_clusters={
zcl.temperature({endpoint=owon_ths317_endpoint,minimum_interval=10,maximum_interval=3600,
reportable_change=100,from_device=owon_temperature_from_device}),
core_battery({endpoint=owon_ths317_endpoint,minimum_interval=3600,maximum_interval=65000,
reportable_change=0,from_device=owon_battery_from_device}),
core_voltage({endpoint=owon_ths317_endpoint,minimum_interval=3600,maximum_interval=65000,
reportable_change=0,from_device=owon_voltage_from_device}),
},
}
register_device_definition(owon_ths317_et,{
fp("OWON","THS317-ET"),
})
local devbis_lywsd03mmc_core={
profile="sensors-devbis-lywsd03mmc-core",
configure=function(driver,device)
for _,spec in ipairs({{0x0402,0,data_types.Int16,10,300,10},
{0x0405,0,data_types.Uint16,10,300,50},{1,0x21,data_types.Uint8,3600,65000,10}})do
if not device:supports_server_cluster(spec[1],1)then
device:send(device_management.build_bind_request(device,spec[1],driver.environment_info.hub_zigbee_eui,1):to_endpoint(1))
device:send(device_management.attr_config(device,{
cluster=spec[1],attribute=spec[2],data_type=spec[3],minimum_interval=spec[4],
maximum_interval=spec[5],reportable_change=spec[3](spec[6]),
}):to_endpoint(1))
end
end
end,
zcl_clusters={
temp_report(10,300,10,1,nil),
hum_report(10,300,50,1,nil),
core_battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10}),
},
}
register_device_definition(devbis_lywsd03mmc_core,{
fp("Xiaomi","LYWSD03MMC"),
})
local zigbeetlc_zg204zl_core={
profile="safety-motion-zg204zl-z-core",
zcl_clusters={
zcl.occupancy({endpoint=1,emit=emit.motion(),minimum_interval=0,maximum_interval=3600,
reportable_change=0,from_device=function(value)
if type(value)=="table" then value=value.value end
return(value & 1)~=0
end}),
zcl.illuminance({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=5}),
core_battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10}),
},
}
register_device_definition(zigbeetlc_zg204zl_core,{
fp("Sonoff","ZG-204ZL-z"),
})
local nodon_stph_core={
profile="sensors-nodon-stph-core",
zcl_clusters={
standard_temp(),
standard_hum(1,nil),
core_battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10}),
},
}
register_device_definition(nodon_stph_core,{
fp("NodOn","STPH-4-1-00"),
})
local function without_reporting(mapping)
mapping.minimum_interval=nil
mapping.maximum_interval=nil
mapping.reportable_change=nil
return mapping
end
local function passive_battery(endpoint)
return without_reporting(core_battery({endpoint=endpoint,read_on_configure=false}))
end
local function passive_voltage(endpoint)
return without_reporting(core_voltage({endpoint=endpoint,read_on_configure=false}))
end
local function typed_battery_alarm(device,value)
if type(value)=="table" then value=value.value end
return core_battery_alarm(device,value)
end
local function refresh_mains_battery(device)
local endpoint=device:get_endpoint(1)
zcl.read_attribute(device,1,0x21,endpoint)
zcl.read_attribute(device,1,0,endpoint)
end
local namron_4512765_core={
profile="sensors-namron-4512765-core",
zcl_clusters={
without_reporting(zcl.temperature({endpoint=1})),
without_reporting(zcl.humidity({endpoint=1})),
without_reporting(core_battery({endpoint=1})),
},
}
register_device_definition(namron_4512765_core,{
fp("Namron AS","4512765"),
})
local namron_4512763_core={
profile="safety-motion-namron-4512763-core",
zcl_clusters={
notification(zcl.motion({endpoint=1}),emit.motion()),
notification(zcl.tamper({endpoint=1}),emit.tamper()),
notification(zcl.battery_low({endpoint=1}),low_battery_event),
core_battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10}),
without_reporting(core_voltage({endpoint=1})),
},
}
register_device_definition(namron_4512763_core,{
fp("Namron AS","4512763"),
})
local openlumi_router_temperature_core={
profile="sensors-openlumi-router-temperature-core",
magic_packet=false,
zcl_clusters={
zcl.cluster_attribute(0x0002,0x0000,{
name="openlumi_device_temperature",
endpoint=1,
data_type=data_types.Int16,
read_only=true,
read_on_configure=true,
minimum_interval=300,
maximum_interval=3600,
reportable_change=1,
emit=emit.temperature("C"),
}),
},
}
register_device_definition(openlumi_router_temperature_core,{
fp("OpenLumi","openlumi.gw_router.dgnwg05lm"),
fp("OpenLumi","openlumi.gw_router.zhwg11lm"),
})
local salus_ss909zb_core={
profile="sensors-salus-ss909zb-core",
zcl_clusters={
standard_temp(9,false),
battery_2500_3000_mapping("ss909zb_battery",9,true),
},
}
register_device_definition(salus_ss909zb_core,{
fp("Computime","SS909ZB"),
fp("Computime","PS600"),
})
local centralite_3310_core={
profile="sensors-centralite-3310-core",
parent_refresh=function()end,
zcl_clusters={
standard_temp(1,false),
zcl.cluster_attribute(0xFC45,0x0000,{
name="centralite_humidity",endpoint=1,mfg_code=0x104E,data_type=data_types.Uint16,
read_only=true,read_on_configure=false,scale=100,emit=emit.humidity(),
minimum_interval=10,maximum_interval=3600,reportable_change=10,
}),
zcl.cluster_attribute(1,0x20,{name="centralite_3310_voltage",endpoint=1,data_type=data_types.Uint8,read_only=true,
minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,
emit=linear_voltage_events}),
zcl.cluster_attribute(1,0x3E,{name="centralite_3310_alarm",endpoint=1,data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=core_battery_alarm}),
},
}
register_device_definition(centralite_3310_core,{
fp("CentraLite","3310-G"),
fp("CentraLite","3310-S"),
fp("SmartThings","3310-S"),
})
local feibit_battery=without_reporting(battery_2500_3000_mapping())
feibit_battery.read_on_configure=false
local feibit_sth01_core={
profile="sensors-feibit-sth01-core",magic_packet=false,
zcl_clusters={
without_reporting(zcl.temperature({endpoint=1,read_on_configure=false})),
without_reporting(zcl.humidity({endpoint=1,read_on_configure=false})),
feibit_battery,
},
}
register_device_definition(feibit_sth01_core,{
fp("fei","FNB54-THM17ML1.1"),
fp("Feibit Inc co.","FNB54-THM17ML1.1"),
fp("Feibit Inc co.","FB56-THM12HM1.2"),
fp("Feibit Inc co.","FNB56-THM14FB2.4"),
fp("Feibit Inc co.","FNB56-THM14FB2.5"),
})
local centralite_3328_core={
profile="safety-motion-centralite-3328-core",
zcl_clusters={
centralite_motion_mapping(),
standard_temp(),
},
}
register_device_definition(centralite_3328_core,{
fp("CentraLite","3328-G"),
})
local function iris_3326_battery(value)
if value==0xFF then return nil end
local voltage=value * 100
local percent=100
if voltage < 2100 then percent=0
elseif voltage < 2440 then percent=6 -(2440-voltage)*6/340
elseif voltage < 2740 then percent=18 -(2740-voltage)*12/300
elseif voltage < 2900 then percent=42 -(2900-voltage)*24/160
elseif voltage < 3000 then percent=100 -(3000-voltage)*58/100 end
return math.floor(percent+0.5)
end
local function iris_motion_clusters(battery_name,alarm_name)
return{
notification(zcl.motion({endpoint=1,from_device=function(value)
if type(value)=="table" then value=value.value end
return(value&2)~=0
end}),emit.motion()),
notification(zcl.tamper({endpoint=1}),emit.tamper()),
notification(zcl.battery_low({endpoint=1}),low_battery_event),
standard_temp(1,false),
zcl.cluster_attribute(1,0x20,{
name=battery_name,endpoint=1,data_type=data_types.Uint8,read_only=true,
minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,
emit=function(_,value)
if value==255 then return end
return{caps.battery.battery(iris_3326_battery(value)),caps.voltageMeasurement.voltage({value=value/10,unit="V"})}
end,
}),
zcl.cluster_attribute(1,0x3E,{name=alarm_name,endpoint=1,data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=core_battery_alarm}),
}
end
local iris_3326_core={
profile="safety-motion-iris-3326-core",
parent_refresh=function()end,
zcl_clusters=iris_motion_clusters("iris_battery","iris_alarm"),
}
register_device_definition(iris_3326_core,{
fp("CentraLite","3326-L"),
fp("iMagic by GreatStar","3326-L"),
})
local sihas_tsm300_core={
profile="sensors-sihas-tsm300-core",magic_packet=false,
zcl_clusters={
temp_report(30,300,30,1,false),
hum_report(30,3600,50,1,false),
zcl.cluster_attribute(1,0x20,{
name="sihas_tsm_battery_voltage",endpoint=1,data_type=data_types.Uint8,read_only=true,read_on_configure=true,
minimum_interval=30,maximum_interval=21600,reportable_change=1,
emit=function(_,value)
local percent=iris_3326_battery(value)
if percent==nil then return nil end
return{caps.battery.battery(percent),caps.voltageMeasurement.voltage({value=value/10,unit="V"})}
end,
}),
},
}
register_device_definition(sihas_tsm300_core,{
fp("ShinaSystem","TSM-300Z"),
})
local konke_th_core={
profile="sensors-konke-th-core",
zcl_clusters={
standard_temp(),
without_reporting(zcl.humidity({endpoint=1})),
battery_2500_3000_mapping(),
},
}
register_device_definition(konke_th_core,{
fp("Konke","3AFE140103020000"),
fp("Konke","3AFE220103020000"),
})
local ikea_vallhorn_core={
profile="safety-motion-ikea-vallhorn-core",
zcl_clusters={
zcl.occupancy({endpoint=2,emit=emit.motion(),minimum_interval=0,maximum_interval=3600,
reportable_change=0,from_device=function(value)
if type(value)=="table" then value=value.value end
return(value & 1)~=0
end}),
zcl.illuminance({endpoint=3,minimum_interval=10,maximum_interval=3600,reportable_change=5}),
core_battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10}),
core_voltage({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10}),
},
}
register_device_definition(ikea_vallhorn_core,{
fp("IKEA of Sweden","VALLHORN Wireless Motion Sensor"),
})
local function ias_notification_motion(endpoint,timed,mask)
return without_reporting(zcl.occupancy({endpoint=endpoint,ias_zone=true,read_only=true,
read_on_configure=false,from_device=function(value,_,context)
if not context or context.command_id ~=0 then return nil end
if type(value)=="table" then value=value.value end
return(value &(mask or 1))~=0
end,emit=function(device,active)
if timed then
local previous=device:get_field("__core_ias_motion_timer")
if previous then previous:cancel()end
device:set_field("__core_ias_motion_timer",device.thread:call_with_delay(90,function()
device:set_field("__core_ias_motion_timer",nil)
device:emit_event(caps.motionSensor.motion.inactive())
end,"Motion reset"))
end
return caps.motionSensor.motion(active and "active" or "inactive")
end,
}))
end
local function notification_low_core(endpoint,any_endpoint)
return without_reporting(zcl.battery_low({endpoint=not any_endpoint and(endpoint or 1)or nil,read_on_configure=false,
emit=function(_,value,context)
if context.command_id==0 then
return value and caps.batteryLevel.battery.critical()or caps.batteryLevel.battery.normal()
end
end,
}))
end
local tuya_sm0202_core={
profile="safety-motion-tuya-sm0202-core",magic_packet=false,
zcl_clusters={
ias_notification_motion(1,true),
notification_low_core(),
core_battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true}),
passive_voltage(1),
},
}
register_device_definition(tuya_sm0202_core,{
fp("_TYZB01_u6uejz21","SM0202"),
})
local bitron_av2010_22_core={
profile="safety-motion-bitron-av2010-22-core",magic_packet=false,
zcl_clusters={
ias_notification_motion(1,true),
without_reporting(zcl.tamper({endpoint=1,read_on_configure=false,
emit=function(device,tampered,context)
if context.command_id==0 then return emit.tamper()(device,tampered)end
end,
})),
notification_low_core(),
},
}
register_device_definition(bitron_av2010_22_core,{
fp("SMaBiT","902010/22"),
fp("SMaBiT","AV2010/22"),
fp("Bitron Home","902010/22"),
fp("Bitron Home","AV2010/22"),
fp("Bitron Video","902010/22"),
fp("Bitron Video","AV2010/22"),
fp("Bitron Video","IR_00.00.03.12TC"),
fp("SMaBiT","902010/22B"),
fp("SMaBiT","AV2010/22B"),
fp("Bitron Home","902010/22B"),
fp("Bitron Home","AV2010/22B"),
fp("Bitron Video","902010/22B"),
fp("Bitron Video","AV2010/22B"),
})
local bitron_av2010_14_core={
profile="safety-motion-bitron-av2010-14-core",magic_packet=false,
zcl_clusters={
ias_notification_motion(1,true),
notification_low_core(),
},
}
register_device_definition(bitron_av2010_14_core,{
fp("SMaBiT","902010/14"),
fp("SMaBiT","AV2010/14"),
fp("Bitron Home","902010/14"),
fp("Bitron Home","AV2010/14"),
fp("Bitron Video","902010/14"),
fp("Bitron Video","AV2010/14"),
fp("SMaBiT","902010/22A"),
fp("SMaBiT","AV2010/22A"),
fp("Bitron Home","902010/22A"),
fp("Bitron Home","AV2010/22A"),
fp("Bitron Video","902010/22A"),
fp("Bitron Video","AV2010/22A"),
})
local smartthings_motionv4_core={
profile="safety-motion-smartthings-v4-core",magic_packet=false,
zcl_clusters={
without_reporting(zcl.occupancy({endpoint=1,ias_zone=true,read_on_configure=false,emit=emit.motion(),
from_device=function(value)
if type(value)=="table" then value=value.value end
return(value & 3)~=0
end,
})),
without_reporting(zcl.tamper({endpoint=1,read_on_configure=false})),
standard_temp(1,false),
zcl.cluster_attribute(1,0x20,{
name="smartthings_v4_battery",endpoint=1,data_type=data_types.Uint8,read_only=true,read_on_configure=true,
minimum_interval=3600,maximum_interval=65000,reportable_change=0,
from_device=function(value)
if value==255 then return nil end
return math.floor(math.max(0,math.min(100,235-370000/(value*100+1)))+0.5)
end,
emit=emit.battery(),
}),
},
}
register_device_definition(smartthings_motionv4_core,{
fp("SmartThings","motionv4"),
})
local function notification_tamper_core(endpoint,any_endpoint)
return without_reporting(zcl.tamper({endpoint=not any_endpoint and(endpoint or 1)or nil,read_on_configure=false,
emit=function(device,value,context)
if context.command_id==0 then return emit.tamper()(device,value)end
end,
}))
end
local sercomm_pir02_core={
profile="safety-motion-sercomm-pir02-core",magic_packet=false,
zcl_clusters={
ias_notification_motion(1,false),
notification_tamper_core(),
notification_low_core(),
core_battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,
from_device=function()return nil end,
}),
zcl.cluster_attribute(1,0x20,{
name="sercomm_pir02_battery",endpoint=1,data_type=data_types.Uint8,read_only=true,read_on_configure=false,
from_device=iris_3326_battery,emit=emit.battery(),
}),
zcl.cluster_attribute(1,0x3E,{
name="sercomm_pir02_battery_alarm",endpoint=1,data_type=data_types.Bitmap32,read_only=true,read_on_configure=false,
emit=core_battery_alarm,
}),
},
}
register_device_definition(sercomm_pir02_core,{
fp("Sercomm Corp.","SZ-PIR02"),
fp("Sercomm Corp.","SZ-PIR02_SF"),
})
local sercomm_pir04_core={
profile="safety-motion-sercomm-pir04-core",magic_packet=false,
zcl_clusters={
ias_notification_motion(1,false),
notification_tamper_core(),
standard_temp(1,false),
zcl.illuminance({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=5,read_on_configure=true}),
zcl.cluster_attribute(1,0x20,{
name="sercomm_pir04_battery_voltage",endpoint=1,data_type=data_types.Uint8,read_only=true,read_on_configure=true,
minimum_interval=3600,maximum_interval=65000,reportable_change=0,
emit=function(_,value)
if value==255 then return nil end
local percent=math.floor(math.max(0,math.min(100,(value-25)*100/7))+0.5)
return{caps.battery.battery(percent),caps.voltageMeasurement.voltage({value=value/10,unit="V"})}
end,
}),
},
}
register_device_definition(sercomm_pir04_core,{
fp("Sercomm Corp.","SZ-PIR04N"),
fp("Sercomm Corp.","SZ-PIR04N_EU"),
})
local bosch_isw_core={
profile="safety-motion-bosch-isw-core",
zcl_clusters={
ias_notification_motion(5,false),
notification_tamper_core(5),
notification_low_core(5),
standard_temp(5,false),
battery_2500_3000_mapping("isw_battery",5,true),
},
}
register_device_definition(bosch_isw_core,{
fp("Bosch","ISW-ZPR1-WP13"),
fp("BOSCH","ISW-ZPR1-WP13"),
})
local hive_mot003_core={
profile="safety-motion-hive-mot003-core",
zcl_clusters={
ias_notification_motion(6,true),
standard_temp(6),
core_battery({endpoint=6,minimum_interval=3600,maximum_interval=65000,reportable_change=0}),
},
}
register_device_definition(hive_mot003_core,{
fp("HiveHome.com","MOT003"),
})
local konke_motion_core={
profile="safety-motion-konke-core",
zcl_clusters={
ias_notification_motion(1,true),
without_reporting(battery_2500_3000_mapping()),
},
}
register_device_definition(konke_motion_core,{
fp("Konke","3AFE14010402000D"),
fp("Konke","3AFE27010402000D"),
fp("Konke","3AFE28010402000D"),
})
local centralite_3305_core={
profile="safety-motion-centralite-3305-core",
parent_refresh=function()end,
zcl_clusters={
ias_notification_motion(1,false,2),
notification_tamper_core(),
notification_low_core(),
standard_temp(1,false),
zcl.cluster_attribute(1,0x20,{name="centralite_3305_voltage",endpoint=1,data_type=data_types.Uint8,read_only=true,
minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,
emit=linear_voltage_events}),
zcl.cluster_attribute(1,0x3E,{name="centralite_3305_alarm",endpoint=1,data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=core_battery_alarm}),
},
}
register_device_definition(centralite_3305_core,{
fp("CentraLite","3305-S"),
fp("CentraLite","3305"),
fp("SmartThings","3305-S"),
fp("SmartThings","3305"),
})
local centralite_3325_core={
profile="safety-motion-centralite-3325-core",
parent_refresh=function()end,
zcl_clusters=iris_motion_clusters("centralite_3325_battery","centralite_3325_alarm"),
}
register_device_definition(centralite_3325_core,{
fp("CentraLite","3325-S"),
fp("SmartThings","3325-S"),
})
local smartthings_motionv5_core={
profile="safety-motion-smartthings-v5-core",
zcl_clusters={
ias_notification_motion(1,false),
standard_temp(),
battery_2500_3000_mapping(),
},
}
register_device_definition(smartthings_motionv5_core,{
fp("SmartThings","motionv5"),
})
local keen_home_th_core={
profile="sensors-keen-home-th-core",
zcl_clusters={
without_reporting(zcl.temperature({endpoint=1,read_on_configure=false,from_device=function(value)
if value > -65 and value < 65 then return value end
end})),
without_reporting(zcl.humidity({endpoint=1,read_on_configure=false})),
zcl.cluster_attribute(1,0x20,{
name="keen_battery",endpoint=1,data_type=data_types.Uint8,read_only=true,read_on_configure=false,
from_device=iris_3326_battery,emit=emit.battery(),
}),
passive_voltage(1),
zcl.cluster_attribute(1,0x3E,{name="keen_battery_alarm",endpoint=1,data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=core_battery_alarm}),
},
}
register_device_definition(keen_home_th_core,{
fp("LUMI","RS-THP-MP-1.0"),
fp("Keen Home Inc","RS-THP-MP-1.0"),
})
local linkind_motion_core={
profile="safety-motion-linkind-core",
zcl_clusters={
ias_notification_motion(1,false),
core_battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0}),
},
}
register_device_definition(linkind_motion_core,{
fp("lk","ZB-MotionSensor-D0003"),
})
local trust_zpir_core={
profile="safety-motion-trust-zpir-core",
zcl_clusters={
ias_notification_motion(1,false,2),
notification_tamper_core(),
notification_low_core(),
core_battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true}),
},
}
register_device_definition(trust_zpir_core,{
fp("ADUROLIGHT","VMS_ADUROLIGHT"),
fp("Trust International B.V.","VMS_ADUROLIGHT"),
fp("AduroSmart Eria","VMS_ADUROLIGHT"),
})
local livingwise_motion_core={
profile="safety-motion-livingwise-core",
zcl_clusters={
ias_notification_motion(1,true),
passive_battery(1),
passive_voltage(1),
},
}
register_device_definition(livingwise_motion_core,{
fp("ORVIBO","895a2d80097f4ae2b2d40500d5e03dcc"),
fp("中性","700ae5aab3414ec09c1872efe7b8755a"),
})
local function hue_motion_core_clusters()
return{
zcl.occupancy({endpoint=2,emit=emit.motion(),minimum_interval=0,maximum_interval=3600,
reportable_change=0,from_device=function(value)
if type(value)=="table" then value=value.value end
return(value & 1)~=0
end}),
standard_temp(2),
zcl.illuminance({endpoint=2,minimum_interval=10,maximum_interval=3600,reportable_change=5}),
core_battery({endpoint=2,minimum_interval=3600,maximum_interval=65000,reportable_change=0}),
}
end
local hue_sml001_core={
profile="safety-motion-hue-sml001-core",
zcl_clusters=hue_motion_core_clusters(),
}
register_device_definition(hue_sml001_core,{
fp("Philips","SML001"),
})
local hue_sml002_core={
profile="safety-motion-hue-sml002-core",
zcl_clusters=hue_motion_core_clusters(),
}
register_device_definition(hue_sml002_core,{
fp("Philips","SML002"),
})
local function hue_current_clusters()
local rows=hue_motion_core_clusters()
rows[1].read_on_configure=false
rows[2].read_on_configure=false
rows[3].read_on_configure=true
rows[4].read_on_configure=true
rows[5]=passive_voltage(2)
rows[6]=zcl.cluster_attribute(1,0x3E,{name="hue_battery_alarm",endpoint=2,data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=core_battery_alarm})
return rows
end
local function hue_current_refresh(device)zcl.read_attribute(device,0x0400,0,2)end
local hue_sml003_core={
profile="safety-motion-hue-sml003-core",
parent_refresh=hue_current_refresh,
zcl_clusters=hue_current_clusters(),
}
register_device_definition(hue_sml003_core,{
fp("Signify Netherlands B.V.","SML003"),
fp("Philips","SML003"),
})
local hue_sml004_core={
profile="safety-motion-hue-sml004-core",
parent_refresh=hue_current_refresh,
zcl_clusters=hue_current_clusters(),
}
register_device_definition(hue_sml004_core,{
fp("Signify Netherlands B.V.","SML004"),
fp("Philips","SML004"),
})
local adeo_ldsenk10_core={
profile="safety-motion-adeo-ldsenk10-core",
zcl_clusters={ias_notification_motion(1,false)},
}
register_device_definition(adeo_ldsenk10_core,{
fp("ADEO","LDSENK10"),
})
local function standard_presence_core_clusters(configure_reporting)
local reporting_options=configure_reporting==false and{
configure_reporting=false,
read_on_configure=true,
}or{
minimum_interval=0,
maximum_interval=3600,
reportable_change=0,
}
local illuminance_options=configure_reporting==false and{
endpoint=1,
configure_reporting=false,
read_on_configure=true,
}or{
endpoint=1,
minimum_interval=10,
maximum_interval=3600,
reportable_change=5,
}
return{
zcl.occupancy({endpoint=1,emit=emit.presence(),
configure_reporting=reporting_options.configure_reporting,
read_on_configure=reporting_options.read_on_configure,
minimum_interval=reporting_options.minimum_interval,
maximum_interval=reporting_options.maximum_interval,
reportable_change=reporting_options.reportable_change,
from_device=function(value)
if type(value)=="table" then value=value.value end
return(value & 1)~=0
end}),
zcl.illuminance(illuminance_options),
}
end
local sonoff_snzb06p24_core={
profile="safety-presence-sonoff-snzb06p24-core",
zcl_clusters=standard_presence_core_clusters(false),
configure=function(driver,device)
for _,cluster in ipairs({0x0001,0x0500})do
device:send(device_management.build_bind_request(
device,cluster,driver.environment_info.hub_zigbee_eui,1):to_endpoint(1))
end
end,
}
register_device_definition(sonoff_snzb06p24_core,{
fp("SONOFF","SNZB-06P24"),
})
local third_reality_r3_core={
profile="safety-presence-third-reality-r3-core",
zcl_clusters=standard_presence_core_clusters(),
}
register_device_definition(third_reality_r3_core,{
fp("Third Reality, Inc","3RPL01084Z"),
})
local function orvibo_th_core_clusters()
return{
standard_temp(1,false),
standard_hum(2,false),
battery_2500_3000_mapping(nil,2,true),
core_battery({endpoint=2,minimum_interval=3600,maximum_interval=65000,reportable_change=0,
read_on_configure=true,from_device=function()return nil end}),
}
end
local orvibo_st20_core={
profile="sensors-orvibo-st20-core",
zcl_clusters=orvibo_th_core_clusters(),
}
register_device_definition(orvibo_st20_core,{
fp("Heiman","b467083cfc864f5e826459e5d8ea6079"),
fp("ORVIBO","b467083cfc864f5e826459e5d8ea6079"),
})
local orvibo_st21_core={
profile="sensors-orvibo-st21-core",
zcl_clusters=orvibo_th_core_clusters(),
}
register_device_definition(orvibo_st21_core,{
fp("HEIMAN","888a434f3cfc47f29ec4a3a03e9fc442"),
fp("ORVIBO","888a434f3cfc47f29ec4a3a03e9fc442"),
})
local imagic_1117_core={
profile="safety-motion-imagic-1117-core",
zcl_clusters={
ias_notification_motion(1,false,2),
standard_temp(),
standard_hum(1,nil),
zcl.cluster_attribute(1,0x20,{
name="imagic_battery",endpoint=1,data_type=data_types.Uint8,read_only=true,
minimum_interval=3600,maximum_interval=65000,reportable_change=10,
from_device=iris_3326_battery,emit=emit.battery(),
}),
core_voltage({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10}),
core_battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10}),
},
}
register_device_definition(imagic_1117_core,{
fp("iMagic by GreatStar","1117-S"),
})
local aurora_motion51_core={
profile="safety-motion-aurora-51-core",
zcl_clusters={
ias_notification_motion(1,false),
zcl.illuminance({minimum_interval=10,maximum_interval=3600,reportable_change=5}),
},
}
register_device_definition(aurora_motion51_core,{
fp("Aurora","MotionSensor51AU"),
})
local sengled_e1m_core={
profile="safety-motion-sengled-e1m-core",
zcl_clusters={
without_reporting(zcl.occupancy({endpoint=1,ias_zone=true,emit=emit.motion(),
from_device=function(value)
if type(value)=="table" then value=value.value end
return(value & 1)~=0
end})),
core_battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10}),
},
}
register_device_definition(sengled_e1m_core,{
fp("sengled","E1M-G7H"),
})
local samjin_motion_core={
profile="safety-motion-samjin-core",
parent_refresh=function()end,
zcl_clusters={
ias_notification_motion(1,false),
notification_tamper_core(),
notification_low_core(),
standard_temp(1,false),
zcl.cluster_attribute(1,0x20,{name="samjin_motion_voltage",endpoint=1,data_type=data_types.Uint8,read_only=true,
minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,emit=linear_voltage_events}),
zcl.cluster_attribute(1,0x3E,{name="samjin_motion_alarm",endpoint=1,data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=core_battery_alarm}),
},
}
register_device_definition(samjin_motion_core,{
fp("Samjin","motion"),
fp("SmartThings","motion"),
})
local thirdreality_3rms_core={
profile="safety-motion-thirdreality-3rms-core",
zcl_clusters={
ias_notification_motion(1,false),
without_reporting(core_battery({endpoint=1,read_on_configure=true})),
passive_voltage(1),
},
}
register_device_definition(thirdreality_3rms_core,{
fp("THIRDREALITY","3RMS16BZ"),
})
local function efekta_th_lr_core_clusters()
return{
temp_report(30,1800,10,nil,false),
hum_report(30,1800,10,nil,false),
core_battery({minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true}),
core_voltage({minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true}),
}
end
local efekta_th_v1_lr_core={
profile="sensors-efekta-th-v1-lr-core",magic_packet=false,
zcl_clusters=efekta_th_lr_core_clusters(),
}
register_device_definition(efekta_th_v1_lr_core,{
fp("EfektaLab","EFEKTA_TH_v1_LR"),
})
local efekta_th_v2_lr_core={
profile="sensors-efekta-th-v2-lr-core",magic_packet=false,
zcl_clusters=efekta_th_lr_core_clusters(),
}
register_device_definition(efekta_th_v2_lr_core,{
fp("EfektaLab","EFEKTA_TH_v2_LR"),
fp("EfektaLab_for_Zigbee-Shop.ru","EFEKTA_TH_v2_LR"),
})
local efekta_th_pow_r_core={
profile="sensors-efekta-th-pow-r-core",magic_packet=false,
parent_refresh=refresh_mains_battery,
zcl_clusters={
temp_report(0,300,0,nil,false),
hum_report(0,300,0,nil,false),
core_battery({minimum_interval=10,maximum_interval=600,reportable_change=1,read_on_configure=true}),
zcl.cluster_attribute(1,0,{
name="efekta_th_pow_mains_voltage",data_type=data_types.Uint16,
scale=10,read_only=true,read_on_configure=true,
emit=emit.voltage(),
}),
zcl.cluster_attribute(1,0x3E,{name="efekta_th_pow_battery_alarm",data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=core_battery_alarm}),
},
}
register_device_definition(efekta_th_pow_r_core,{
fp("EfektaLab_for_Zigbee-Shop.ru","EFEKTA_TH_POW_R"),
fp("EfektaLab","EFEKTA_TH_POW_R"),
fp("EfektaLab","EFEKTA_TH_POW_E"),
fp("EfektaLab_for_Zigbee-Shop.ru","EFEKTA_TH_POW_E"),
})
local efekta_t1_v2_lr_core={
profile="sensors-efekta-t1-v2-lr-core",magic_packet=false,
zcl_clusters={
temp_report(30,1800,10,nil,false),
core_battery({minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true}),
core_voltage({minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true}),
},
}
register_device_definition(efekta_t1_v2_lr_core,{
fp("EfektaLab","EFEKTA_T1_v2_LR"),
fp("EfektaLab_for_Zigbee-Shop.ru","EFEKTA_T1_v2_LR"),
})
local efekta_t1_max_e_core={
profile="sensors-efekta-t1-max-e-core",magic_packet=false,
parent_refresh=refresh_mains_battery,
zcl_clusters={
temp_report(0,300,0,nil,false),
core_battery({minimum_interval=10,maximum_interval=600,reportable_change=1,read_on_configure=true}),
zcl.cluster_attribute(1,0,{
name="efekta_t1_max_mains_voltage",data_type=data_types.Uint16,
scale=10,read_only=true,read_on_configure=true,emit=emit.voltage(),
}),
zcl.cluster_attribute(1,0x3E,{name="efekta_t1_max_battery_alarm",data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=core_battery_alarm}),
},
}
register_device_definition(efekta_t1_max_e_core,{
fp("EfektaLab","EFEKTA_T1_MAX_E"),
fp("EfektaLab","EFEKTA_T1_MAX_R"),
})
local efekta_eth102z_core={
profile="sensors-efekta-eth102z-core",magic_packet=false,
zcl_clusters=efekta_th_lr_core_clusters(),
}
register_device_definition(efekta_eth102z_core,{
fp("efektalab.com","EFEKTA_eTH102z"),
})
local efekta_eon29wz_core={
profile="sensors-efekta-eon29wz-core",magic_packet=false,
zcl_clusters={
temp_report(0,21600,0,nil,true),
hum_report(0,21600,0,nil,true),
zcl.illuminance({minimum_interval=0,maximum_interval=21600,reportable_change=0,read_on_configure=true}),
core_battery({minimum_interval=0,maximum_interval=21600,reportable_change=0,read_on_configure=true}),
passive_voltage(),
},
}
register_device_definition(efekta_eon29wz_core,{
fp("EfektaLab","EFEKTA_eON29wz"),
})
local ikea_vindstyrka_core={
profile="sensors-ikea-vindstyrka-core",magic_packet=false,
zcl_clusters={
temp_report(10,3600,100,nil,true),
standard_hum(nil,true),
zcl.cluster_attribute(0x042A,0,{
name="ikea_vindstyrka_pm25",data_type=data_types.SinglePrecisionFloat,
minimum_interval=60,maximum_interval=120,reportable_change=data_types.SinglePrecisionFloat(0,1,0),
read_only=true,read_on_configure=true,
from_device=function(value)
if type(value)=="table" then value=value.value end
return math.floor(math.max(0,value)+0.5)
end,
emit=emit.pm25(),
}),
},
}
register_device_definition(ikea_vindstyrka_core,{
fp("IKEA of Sweden","VINDSTYRKA"),
})
local miamiaoce_mho_c401n_core={
profile="sensors-miamiaoce-mho-c401n-core",magic_packet=false,
zcl_clusters={
temp_report(10,300,10,1,true),
hum_report(10,300,50,1,true),
core_battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true}),
},
}
register_device_definition(miamiaoce_mho_c401n_core,{
fp("MiaMiaoCe","MHO-C401N"),
})
local zigbeetlc_mho_c401n_core={
profile="sensors-zigbeetlc-mho-c401n-core",magic_packet=false,
zcl_clusters={
temp_report(10,3600,10,1,true),
standard_hum(1,true),
core_battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true}),
passive_voltage(1),
},
}
register_device_definition(zigbeetlc_mho_c401n_core,{
fp("MiaMiaoCe","MHO-C401N-z"),
})
local sonoff_snzb02dr2_core={
profile="sensors-sonoff-snzb02dr2-core",magic_packet=false,
zcl_clusters={
temp_report(10,3600,100,nil,true),
standard_hum(nil,true),
core_battery({minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true}),
core_voltage({minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true}),
},
configure=function(driver,device)
local endpoint=device:get_endpoint(0x0020)
device:send(device_management.build_bind_request(device,0x0020,
driver.environment_info.hub_zigbee_eui,endpoint):to_endpoint(endpoint))
end,
}
register_device_definition(sonoff_snzb02dr2_core,{
fp("SONOFF","SNZB-02DR2"),
})
local efekta_th_duo_core={
profile="sensors-efekta-th-duo-core",magic_packet=false,
parent_refresh=function(device)
zcl.read_attribute(device,1,0x21,1)
zcl.read_attribute(device,1,0x20,1)
end,
zcl_clusters={
zcl.temperature({endpoint=1,component="main",minimum_interval=30,maximum_interval=1800,reportable_change=10,read_on_configure=false}),
zcl.humidity({endpoint=1,component="main",minimum_interval=30,maximum_interval=1800,reportable_change=10,read_on_configure=false}),
zcl.temperature({endpoint=2,component="external",minimum_interval=30,maximum_interval=1800,reportable_change=10,read_on_configure=false}),
zcl.humidity({endpoint=2,component="external",minimum_interval=30,maximum_interval=1800,reportable_change=10,read_on_configure=false}),
core_battery({endpoint=1,component="main",minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true}),
core_voltage({endpoint=1,component="main",minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true}),
zcl.cluster_attribute(1,0x003E,{
name="efekta_th_duo_battery_alarm",endpoint=1,component="main",data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,
emit=typed_battery_alarm,
}),
},
}
register_device_definition(efekta_th_duo_core,{
fp("EfektaLab","EFEKTA_TH_DUO_LR"),
})
local efekta_t1_y_core={
profile="sensors-efekta-t1-y-core",magic_packet=false,
parent_refresh=function(device)
zcl.read_attribute(device,1,0x21,device:get_endpoint(1))
zcl.read_attribute(device,1,0x20,device:get_endpoint(1))
end,
zcl_clusters={
without_reporting(zcl.temperature({read_on_configure=false})),
passive_battery(),
passive_voltage(),
zcl.cluster_attribute(1,0x003E,{
name="efekta_t1_y_battery_alarm",data_type=data_types.Bitmap32,read_only=true,read_on_configure=false,
emit=typed_battery_alarm,
}),
},
}
register_device_definition(efekta_t1_y_core,{
fp("EfektaLab","EFEKTA_T1_Y"),
fp("EfektaLab","EFEKTA_T1_Y_LR"),
})
local efekta_t1_v2_core={
profile="sensors-efekta-t1-v2-core",magic_packet=false,
parent_refresh=function(device)
zcl.read_attribute(device,1,0x21,1)
zcl.read_attribute(device,1,0x20,1)
end,
zcl_clusters={
temp_report(30,1800,10,1,false),
core_battery({endpoint=1,minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true}),
core_voltage({endpoint=1,minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true}),
zcl.cluster_attribute(1,0x003E,{
name="efekta_t1_v2_battery_alarm",endpoint=1,data_type=data_types.Bitmap32,read_only=true,read_on_configure=false,
emit=core_battery_alarm,
}),
},
}
register_device_definition(efekta_t1_v2_core,{
fp("EfektaLab","EFEKTA_T1_v2"),
})
local gs_sthm_i1h_core={
profile="sensors-gs-sthm-i1h-core",magic_packet=false,
zcl_clusters={
temp_report(10,3600,100,nil,true),
standard_hum(nil,true),
core_battery({minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,
from_device=voltage_preferred_battery,
}),
zcl.cluster_attribute(1,0x20,{
name="gs_sthm_battery_voltage",data_type=data_types.Uint8,read_only=true,read_on_configure=false,
emit=moszb_battery_events,
}),
},
}
register_device_definition(gs_sthm_i1h_core,{
fp("GS","STHM-I1H"),
})
local pushok_pok005_core={
profile="sensors-pushok-pok005-core",magic_packet=false,
zcl_clusters={
without_reporting(zcl.temperature({read_on_configure=true})),
without_reporting(zcl.humidity({read_on_configure=true})),
passive_battery(),
passive_voltage(),
},
}
register_device_definition(pushok_pok005_core,{
fp("PushOk Hardware","POK005"),
})
local slacky_ts0201_core={
profile="sensors-slacky-ts0201-core",magic_packet=false,
zcl_clusters={
temp_report(10,3600,10,nil,true),
hum_report(10,3600,10,nil,true),
core_battery({minimum_interval=3600,maximum_interval=21600,reportable_change=0,read_on_configure=true}),
core_voltage({minimum_interval=3600,maximum_interval=21600,reportable_change=0,read_on_configure=true}),
},
}
register_device_definition(slacky_ts0201_core,{
fp("Slacky-DIY","TS0201-z-SlD"),
fp("Slacky-DIY","TS0201-z21-SlD"),
fp("Slacky-DIY","TS0201-z22-SlD"),
fp("Slacky-DIY","TS0201-z23-SlD"),
fp("Slacky-DIY","TS0201-z24-SlD"),
fp("Slacky-DIY","TS0201-z28-SlD"),
})
local yandex_00528_core={
profile="safety-motion-yandex-00528-core",magic_packet=false,
zcl_clusters={
zcl.occupancy({emit=emit.motion(),minimum_interval=0,maximum_interval=3600,
reportable_change=0,read_on_configure=true,from_device=function(value)
if type(value)=="table" then value=value.value end
return(value & 1)~=0
end}),
zcl.illuminance({minimum_interval=10,maximum_interval=3600,reportable_change=5,read_on_configure=true}),
core_battery({minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true}),
passive_voltage(),
},
}
register_device_definition(yandex_00528_core,{
fp("Yandex","YNDX-00528"),
})
local yandex_00529_core={
profile="sensors-yandex-00529-core",magic_packet=false,
zcl_clusters={
temp_report(10,3600,100,nil,true),
standard_hum(nil,true),
core_battery({minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true}),
passive_voltage(),
},
}
register_device_definition(yandex_00529_core,{
fp("Yandex","YNDX-00529"),
})
local function pushok_extended_temperature(value,_,context)
local body=context and context.zb_rx and context.zb_rx.body and context.zb_rx.body.zcl_body
if body and type(body.get_attribute_data)=="function" then
local extension=body:get_attribute_data(0xF001)
if extension~=nil then
if type(extension)=="table" then extension=extension.value end
value=value+extension/10
end
end
return value
end
local pushok_extended_probe_core={
profile="sensors-pushok-extended-probe-core",magic_packet=false,
zcl_clusters={
without_reporting(zcl.temperature({read_on_configure=false,from_device=pushok_extended_temperature})),
passive_battery(),
passive_voltage(),
},
}
register_device_definition(pushok_extended_probe_core,{
fp("PushOk Hardware","POK014"),
fp("PushOk Hardware","POK015"),
})
local kmpcil_res005_core={
profile="sensors-kmpcil-res005-core",magic_packet=false,
zcl_clusters={
standard_temp(8,false),
standard_hum(8,false),
core_battery({endpoint=8,minimum_interval=1,maximum_interval=120,reportable_change=1,read_on_configure=false}),
without_reporting(core_voltage({endpoint=8,read_on_configure=false})),
zcl.cluster_attribute(0x000F,0x0055,{
name="kmpcil_res005_motion",endpoint=8,data_type=data_types.Boolean,
read_only=true,read_on_configure=false,
minimum_interval=0,maximum_interval=30,reportable_change=true,
from_device=function(value)
if type(value)=="table" then value=value.value end
return value==1 or value==true
end,
emit=emit.motion(),
}),
zcl.illuminance({minimum_interval=10,maximum_interval=3600,reportable_change=5}),
},
configure=function(_,device)
for _,spec in ipairs({{81,data_types.Boolean,true},{257,data_types.Uint32,25}})do
local request=cluster_base.write_attribute(device,data_types.ClusterId(0x000F),
data_types.AttributeId(spec[1]),spec[2](spec[3]))
request.body.zcl_header.frame_ctrl:set_disable_default_response()
device:send(request:to_endpoint(8))
end
end,
}
register_device_definition(kmpcil_res005_core,{
fp("KMPCIL","RES005"),
})
local schneider_cct593011_core={
profile="sensors-schneider-cct593011-core",magic_packet=false,
zcl_clusters={
standard_temp(1,false),
standard_hum(1,false),
core_battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true}),
passive_voltage(1),
},
}
register_device_definition(schneider_cct593011_core,{
fp("Schneider Electric","CCT593011_AS"),
})
local schneider_cct595011_core={
profile="safety-motion-schneider-cct595011-core",magic_packet=false,
zcl_clusters={
without_reporting(zcl.occupancy({ias_zone=true,read_on_configure=false,emit=emit.motion(),
from_device=function(value)
if type(value)=="table" then value=value.value end
return(value & 2)~=0
end})),
without_reporting(zcl.battery_low({read_on_configure=false,
emit=function(_,low)
return low and caps.batteryLevel.battery.critical()or caps.batteryLevel.battery.normal()
end})),
core_battery({minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true}),
zcl.illuminance({minimum_interval=10,maximum_interval=3600,reportable_change=5}),
},
}
register_device_definition(schneider_cct595011_core,{
fp("Schneider Electric","CCT595011_AS"),
})
local hobeian_zg204z_core={
profile="safety-motion-hobeian-zg204z-core",magic_packet=false,
zcl_clusters={
without_reporting(zcl.occupancy({endpoint=1,ias_zone=true,read_on_configure=false,emit=emit.motion(),
from_device=function(value)
if type(value)=="table" then value=value.value end
return(value & 1)~=0
end})),
without_reporting(zcl.battery_low({endpoint=1,read_on_configure=false,
emit=function(_,low)
return low and caps.batteryLevel.battery.critical()or caps.batteryLevel.battery.normal()
end})),
core_battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true}),
core_voltage({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true}),
},
}
register_device_definition(hobeian_zg204z_core,{
fp("HOBEIAN","ZG-204Z"),
})
local aqara_fp1e_core={
profile="safety-presence-aqara-fp1e-core",magic_packet=false,
zcl_clusters={
zcl.cluster_attribute(0xFCC0,0x0142,{
name="aqara_fp1e_presence",endpoint=1,mfg_code=0x115F,data_type=data_types.Uint8,
read_only=true,read_on_configure=true,
from_device=function(value)
if type(value)=="table" then value=value.value end
return value==1
end,
emit=emit.presence(),
}),
},
}
register_device_definition(aqara_fp1e_core,{
fp("aqara","lumi.sensor_occupy.agl1"),
})
local tcl_ms01_core={
profile="safety-motion-tcl-ms01-core",magic_packet=false,
zcl_clusters={
without_reporting(zcl.occupancy({endpoint=1,ias_zone=true,read_on_configure=false,emit=emit.motion(),
from_device=function(value)
if type(value)=="table" then value=value.value end
return(value & 1)~=0
end})),
without_reporting(zcl.battery_low({endpoint=1,read_on_configure=false,
emit=function(_,low)
return low and caps.batteryLevel.battery.critical()or caps.batteryLevel.battery.normal()
end})),
core_battery({endpoint=1,minimum_interval=3600,maximum_interval=7200,reportable_change=2,read_on_configure=true}),
core_voltage({endpoint=1,minimum_interval=3600,maximum_interval=7200,reportable_change=100,read_on_configure=true}),
},
}
register_device_definition(tcl_ms01_core,{
fp("TCL","MS01"),
})
local orvibo_sn10zw_core={
profile="safety-motion-orvibo-sn10zw-core",magic_packet=false,
zcl_clusters={
ias_notification_motion(nil,true),
notification_tamper_core(nil,true),
notification_low_core(nil,true),
passive_battery(),
passive_voltage(),
zcl.cluster_attribute(1,0x3E,{name="orvibo_sn10_battery_alarm",data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=core_battery_alarm}),
},
}
register_device_definition(orvibo_sn10zw_core,{
fp("欧瑞","585fdfb8c2304119a2432e9845cf2623"),
fp("ORVIBO","131c854783bc45c9b2ac58088d09571c"),
fp("ORVIBO","b2e57a0f606546cd879a1a54790827d6"),
})
local function ts0201_core_battery_value(value,_,context)
if context and context.raw_value==255 then return nil end
local rx=context and context.zb_rx
local body=rx and rx.body and rx.body.zcl_body
if body and type(body.get_attribute_data)=="function" then
local percentage=body:get_attribute_data(0x21)
local voltage=body:get_attribute_data(0x20)
percentage=type(percentage)=="table" and percentage.value or percentage
voltage=type(voltage)=="table" and voltage.value or voltage
if percentage==200 and type(voltage)=="number" and voltage<30 then return nil end
end
return value
end
local function ts0201_core_clusters(humidity_scale)
return{
zcl.tuya_magic_packet({endpoint=1}),
without_reporting(zcl.temperature({read_on_configure=false})),
without_reporting(zcl.humidity({scale=humidity_scale,read_on_configure=false,
from_device=function(value)if value>=0 and value<=100 then return value end end})),
without_reporting(core_battery({read_on_configure=false,from_device=ts0201_core_battery_value})),
without_reporting(core_voltage({read_on_configure=false,from_device=ts0201_core_battery_value})),
}
end
local tuya_ts0201_standard_core={
profile="sensors-tuya-ts0201-standard-core",
zcl_clusters=ts0201_core_clusters(100),
}
register_device_definition(tuya_ts0201_standard_core,{
fp("_TZ2000_a476raq2","TS0201"),
fp("_TZ3000_i8jfiezr","TS0201"),
fp("_TYZB01_a476raq2","TS0201"),
fp("_TZ3000_nau60otv","TS0201"),
fp("_TZ2000_hjsgdkfl","TS0201"),
fp("_TZ3000_kchagk8y","TS0201"),
fp("_TZ2000_lxvycln5","TS0201"),
fp("_TZ3210_qkj7rujp","TS0201"),
fp("_TZ3000_cx6atb9s","TS0201"),
fp("_TZ3000_1o6x1bl0","TS0201"),
fp("_TZ2000_zrl0mqre","TS0201"),
fp("xn0","TY0201"),
fp("_TZ3210_huzkzqyk","TS0201"),
fp("_TZ3000_acklt5lf","TS0201"),
fp("_TZ3000_vira43zx","TS0201"),
fp("_TZ3000_unw0hpdv","TS0201"),
fp("_TZ3000_fejbrqvb","TS0201"),
fp("_TZ3000_lfa05ajd","TS0201"),
fp("_TZ3000_8fwzalxx","TS0201"),
fp("_TZ3000_vfpt3wk4","TS0201"),
fp("_TZ2000_zsfvulde","TS0201"),
fp("Wing","TS0201"),
fp("AoYan  ","TS0201"),
fp("_TZ3000_utwgoauk","TS0201"),
fp("_TZ3000_qzvaivin","TS0201"),
fp("_TZ3000_z1jcca2g","TS0201"),
fp("_TZ3210_k3qngb7u","TS0201"),
})
local tuya_ty0201_ncw_core={
profile="sensors-tuya-ty0201-ncw-core",
zcl_clusters=ts0201_core_clusters(10),
}
register_device_definition(tuya_ty0201_ncw_core,{
fp("_TZ3210_ncw88jfq","TY0201"),
})
local tuyatec_rh3052_core={
profile="sensors-tuyatec-rh3052-core",magic_packet=false,
zcl_clusters={
without_reporting(zcl.temperature({read_on_configure=false})),
without_reporting(zcl.humidity({read_on_configure=false})),
passive_battery(),
passive_voltage(),
},
}
register_device_definition(tuyatec_rh3052_core,{
fp("TUYATEC-prhs1rsd","RH3052"),
fp("TUYATEC-jigsujrv","RH3052"),
fp("TUYATEC-yg5dcbfu","RH3052"),
fp("TUYATEC-gqhxixyk","RH3052"),
fp("TUYATEC-4yn5mbem","RH3052"),
fp("TUYATEC-ef6iwyfl","RH3052"),
fp("TUYATEC-HaoiuWzy","RH3052"),
fp("TUYATEC-vmgh3fxd","RH3052"),
fp("TUYATEC-ehyenwmu","RH3052"),
fp("TUYATEC-lqyucvyd","RH3052"),
})
local visonic_mp841_core={
profile="safety-motion-visonic-mp841-core",magic_packet=false,
zcl_clusters={ias_notification_motion(nil,false)},
}
register_device_definition(visonic_mp841_core,{
fp("Visonic","MP-841"),
})
local dawon_th110_core={
profile="sensors-dawon-th110-core",magic_packet=false,
zcl_clusters={
standard_temp(1,true),
standard_hum(1,true),
core_battery({endpoint=1,scale=1,minimum_interval=30,maximum_interval=21600,reportable_change=1,read_on_configure=true}),
core_voltage({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,
from_device=function()return nil end}),
},
}
register_device_definition(dawon_th110_core,{
fp("DAWON_DNS","ZB30C2"),
})
local swann_motion_core={
profile="safety-motion-swann-core",magic_packet=false,
zcl_clusters={
ias_notification_motion(1,false),
notification_tamper_core(),
notification_low_core(),
},
}
register_device_definition(swann_motion_core,{
fp("SWANN","SWO-MOS1PA"),
})
local visonic_mp840_core={
profile="safety-motion-visonic-mp840-core",magic_packet=false,
zcl_clusters={
ias_notification_motion(1,false),
notification_tamper_core(),
notification_low_core(),
without_reporting(zcl.temperature({endpoint=1,read_on_configure=false})),
zcl.cluster_attribute(1,0x20,{
name="visonic_mp840_battery_voltage",endpoint=1,data_type=data_types.Uint8,read_only=true,read_on_configure=false,
emit=moszb_battery_events,
}),
zcl.cluster_attribute(1,0x3E,{
name="visonic_mp840_battery_alarm",endpoint=1,data_type=data_types.Bitmap32,read_only=true,read_on_configure=false,
emit=core_battery_alarm,
}),
},
}
register_device_definition(visonic_mp840_core,{
fp("Visonic","MP-840"),
})
local universal_xhs1_core={
profile="safety-motion-universal-xhs1-core",magic_packet=false,
zcl_clusters={
ias_notification_motion(1,false),
notification_tamper_core(),
notification_low_core(),
standard_temp(),
zcl.cluster_attribute(1,0x20,{
name="universal_xhs1_battery",endpoint=1,data_type=data_types.Uint8,read_only=true,
minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,
emit=function(_,value)
if type(value)=="table" then value=value.value end
if value==255 then return end
return{caps.battery.battery(iris_3326_battery(value)),
caps.voltageMeasurement.voltage({value=value/10,unit="V"})}
end,
}),
},
}
register_device_definition(universal_xhs1_core,{
fp("Universal Electronics Inc","URC4470BC0-X-R"),
})
local function uint32_le(value)
return string.char(
value & 0xFF,
(value >> 8)& 0xFF,
(value >> 16)& 0xFF,
(value >> 24)& 0xFF
)
end
local function configure_universal_xhs2_poll_control(device)
zcl.send_raw_cluster_command(device,0x0020,0x02,uint32_le(24),1)
local request=cluster_base.write_attribute(
device,
data_types.ClusterId(0x0020),
data_types.AttributeId(0x0000),
data_types.Uint32(13200)
)
device:send(request:to_endpoint(1))
return true
end
local universal_xhs2_core={
profile="safety-contact-universal-xhs2-core",magic_packet=false,
announce_handler=configure_universal_xhs2_poll_control,
configure=function(_,device)
configure_universal_xhs2_poll_control(device)
end,
zcl_clusters={
without_reporting(zcl.contact({endpoint=1,read_on_configure=false,
emit=function(device,value,context)
if context.command_id==0 then return emit.contact()(device,value)end
end,
})),
notification_tamper_core(),
notification_low_core(),
standard_temp(),
zcl.cluster_attribute(1,0x20,{
name="universal_xhs2_battery",endpoint=1,data_type=data_types.Uint8,read_only=true,
minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,
emit=function(_,value)
if type(value)=="table" then value=value.value end
if value==255 then return end
return{caps.battery.battery(iris_3326_battery(value)),
caps.voltageMeasurement.voltage({value=value/10,unit="V"})}
end,
}),
},
}
register_device_definition(universal_xhs2_core,{
fp("Universal Electronics Inc","URC4460BC0-X-R"),
})
local namron_4512770_core={
profile="safety-motion-namron-4512770-core",magic_packet=false,
zcl_clusters={
ias_notification_motion(nil,false),
without_reporting(zcl.temperature({endpoint=3,read_on_configure=false})),
without_reporting(zcl.humidity({endpoint=4,read_on_configure=false})),
passive_battery(),
passive_voltage(),
zcl.illuminance({minimum_interval=10,maximum_interval=3600,reportable_change=5}),
},
configure=function(driver,device)
device:send(device_management.build_bind_request(device,0x0402,driver.environment_info.hub_zigbee_eui,3))
device:send(device_management.build_bind_request(device,0x0405,driver.environment_info.hub_zigbee_eui,4))
end,
}
register_device_definition(namron_4512770_core,{
fp("NAMRON AS","4512770"),
fp("NAMRON AS","4512771"),
fp("Namron AS","4512770"),
fp("Namron AS","4512771"),
})
local tuya_ts0202_core={
profile="safety-motion-tuya-ts0202-core",magic_packet=false,
zcl_clusters={
without_reporting(zcl.occupancy({endpoint=1,ias_zone=true,read_on_configure=false,emit=emit.motion(),
from_device=function(value)
if type(value)=="table" then value=value.value end
return(value & 1)~=0
end})),
core_battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true}),
core_voltage({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true}),
},
}
register_device_definition(tuya_ts0202_core,{
fp("_TZ3000_mmtwjmaq","TS0202"),
fp("_TZ3000_kmh5qpmb","TS0202"),
fp("_TZ3000_0b0c7d6h","TS0202"),
fp("_TZ3000_hgu1dlak","TS0202"),
fp("_TZ3000_tiwq83wk","TS0202"),
fp("_TZ3000_y56pgpgs","TS0202"),
fp("_TZ3000_k5wwrk7a","TS0202"),
fp("_TZ3000_c8ozah8n","TS0202"),
fp("_TYZB01_hqbdru35","TS0202"),
fp("_TYZB01_dl7cejts","TS0202"),
})
local tuyatec_rh3040_core={
profile="safety-motion-tuyatec-rh3040-core",magic_packet=false,
zcl_clusters={
ias_notification_motion(nil,false),
passive_battery(),
passive_voltage(),
},
}
register_device_definition(tuyatec_rh3040_core,{
fp("TUYATEC-zn9wyqtr","RH3040"),
fp("TUYATEC-bd5faf9p","RH3040"),
fp("TUYATEC-b3ov3nor","RH3040"),
fp("TUYATEC-2gn2zf9e","RH3040"),
fp("TUYATEC-b5g40alm","RH3040"),
fp("TUYATEC-kpz6r4qx","RH3040"),
fp("TUYATEC-dxnohkpd","RH3040"),
fp("TUYATEC-zw6hxafz","RH3040"),
fp("TUYATEC-deetibst","RH3040"),
fp("TUYATEC-kmfarmcu","RH3040"),
fp("TUYATEC-53o41joc","RH3040"),
})
local function nyce_motion_core_clusters(battery_scale)
local battery=passive_battery()
battery.scale=battery_scale
return{
ias_notification_motion(nil,false,2),
without_reporting(zcl.occupancy({read_on_configure=false,emit=emit.motion(),
from_device=function(value)
if type(value)=="table" then value=value.value end
return(value & 1)~=0
end})),
without_reporting(zcl.temperature({read_on_configure=false})),
without_reporting(zcl.humidity({read_on_configure=false})),
battery,
passive_voltage(),
}
end
local nyce_3041_core={
profile="safety-motion-nyce-3041-core",magic_packet=false,
zcl_clusters=nyce_motion_core_clusters(1),
}
register_device_definition(nyce_3041_core,{
fp("NYCE","3041"),
})
local nyce_3043_core={
profile="safety-motion-nyce-3043-core",magic_packet=false,
zcl_clusters=nyce_motion_core_clusters(2),
}
register_device_definition(nyce_3043_core,{
fp("NYCE","3043"),
})
local nyce_3045_core={
profile="safety-motion-nyce-3045-core",magic_packet=false,
zcl_clusters=nyce_motion_core_clusters(1),
}
register_device_definition(nyce_3045_core,{
fp("NYCE","3045"),
})
local bosch_radion_notification_core={
profile="safety-motion-bosch-radion-notification-core",
parent_refresh=radion_refresh,
zcl_clusters=radion_clusters(),
}
register_device_definition(bosch_radion_notification_core,{
fp("Bosch","RFPR-ZB"),
fp("Bosch","RFDL-ZB-MS"),
fp("Bosch","RFPR-ZB-MS"),
})
local function aqara_high_precision_battery(_,millivolts)
return{
caps.battery.battery(math.max(0,math.min(100,math.floor((millivolts-2850)*100/150+0.5)))),
caps.voltageMeasurement.voltage({value=millivolts/1000,unit="V"}),
}
end
local aqara_high_precision_core={
profile="safety-motion-aqara-high-precision-core",
magic_packet=false,
zcl_clusters={
zcl.cluster_attribute(0x0406,0,{
name="aqara_high_precision_motion",endpoint=1,read_only=true,read_on_configure=false,
emit=function(device,value)
if type(value)=="table" then value=value.value end
if value~=1 then return end
local previous=device:get_field("__aqara_high_precision_timer")
if previous then previous:cancel()end
local interval=device:get_field("__aqara_high_precision_interval")or 60
device:set_field("__aqara_high_precision_timer",device.thread:call_with_delay(interval+2,function()
device:set_field("__aqara_high_precision_timer",nil)
device:emit_event(caps.motionSensor.motion.inactive())
end,"Aqara high precision motion reset"))
return caps.motionSensor.motion.active()
end,
}),
zcl.cluster_attribute(0xFCC0,0x0102,{
name="aqara_high_precision_interval",endpoint=1,mfg_code=0x115F,
read_only=true,read_on_configure=true,
handler=function(device,value)
if type(value)=="table" then value=value.value end
device:set_field("__aqara_high_precision_interval",value)
end,
}),
zcl.cluster_attribute(0x0001,0x0020,{
name="aqara_high_precision_voltage",endpoint=1,data_type=data_types.Uint8,
read_only=true,read_on_configure=true,
emit=function(device,value)
if type(value)=="table" then value=value.value end
if value~=255 then return aqara_high_precision_battery(device,value*100)end
end,
}),
zcl.cluster_attribute(0xFCC0,0x00F7,{
name="aqara_high_precision_diagnostics",endpoint=1,read_only=true,read_on_configure=false,
emit=function(device,value)
if type(value)=="table" and value.value~=nil then value=value.value end
if type(value)=="string" then
local decoded,offset={},1
while offset+1<=#value do
local key,kind=value:byte(offset,offset+1)
local width=kind>=0x20 and kind<=0x2F and((kind%8)+1)or kind==0x10 and 1
if not width or offset+1+width>#value then break end
decoded[key]=string.unpack("<"..(kind>=0x28 and "i" or "I")..width,value,offset+2)
offset=offset+2+width
end
value=decoded
end
if type(value)~="table" then return end
local voltage=value[1]or value["1"]
if type(voltage)=="table" then voltage=voltage.value end
if type(voltage)=="number" then return aqara_high_precision_battery(device,voltage)end
end,
}),
},
}
register_device_definition(aqara_high_precision_core,{
fp("LUMI","lumi.motion.agl04"),
})
local develco_aqszb110_core={
profile="sensors-frient-aqszb110-core",magic_packet=false,
zcl_clusters={
standard_temp(38,true),
standard_hum(38,true),
zcl.cluster_attribute(1,0x20,{
name="aqszb110_battery_voltage",endpoint=38,data_type=data_types.Uint8,read_only=true,
minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,
emit=function(_,value)
if type(value)=="table" then value=value.value end
if value==255 then return end
return{
caps.battery.battery(battery_2500_3000_percent(value)),
caps.voltageMeasurement.voltage({value=value/10,unit="V"}),
value<=25 and caps.batteryLevel.battery.critical()or caps.batteryLevel.battery.normal(),
}
end,
}),
without_reporting(core_battery({endpoint=38,read_on_configure=false,
from_device=function(value,_,context)
local body=context.zb_rx.body.zcl_body
local voltage=type(body.get_attribute_data)=="function" and body:get_attribute_data(0x20)
if type(voltage)=="table" then voltage=voltage.value end
if type(voltage)=="number" and voltage<255 then return end
if type(value)=="table" then value=value.value end
if context.raw_value~=255 then return value end
end,
})),
},
}
register_device_definition(develco_aqszb110_core,{
fp("frient A/S","AQSZB-110"),
})
local function aqara_tlv_field(value,field)
if type(value)=="table" and value.value~=nil then value=value.value end
if type(value)=="string" then
local reader=buf.Reader(value)
local result
while reader:remain()>=2 do
local key,kind=reader:read_u8(),reader:read_u8()
local ok,decoded=pcall(data_types.parse_data_type,kind,reader)
if not ok then break end
if key==field then result=decoded.value end
end
return result
end
if type(value)~="table" then return end
local result=value[field]or value[tostring(field)]
if type(result)=="table" then result=result.value end
return result
end
local function aqara_fp310_battery(device,value)
local voltage=aqara_tlv_field(value,23)
if type(voltage)=="number" then return aqara_high_precision_battery(device,voltage)end
end
local aqara_fp310_core={
profile="safety-presence-aqara-fp310-core",magic_packet=false,
parent_refresh=function(device)
zcl.read_attribute(device,0xFCC0,0x0142,1,0x115F)
for _,cluster in ipairs({0x0402,0x0405,0x0400})do zcl.read_attribute(device,cluster,0,1)end
end,
zcl_clusters={
zcl.cluster_attribute(0xFCC0,0x0142,{
name="aqara_fp310_presence",endpoint=1,mfg_code=0x115F,data_type=data_types.Uint8,
read_only=true,read_on_configure=true,
from_device=function(value)
if type(value)=="table" then value=value.value end
return value==1
end,
emit=emit.presence(),
}),
standard_temp(1,true),
standard_hum(1,true),
zcl.illuminance({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=5,read_on_configure=true}),
zcl.cluster_attribute(0xFCC0,0x00F7,{
name="aqara_fp310_battery",endpoint=1,mfg_code=0x115F,
read_only=true,read_on_configure=false,emit=aqara_fp310_battery,
}),
zcl.cluster_attribute(0xFCC0,0x00FC,{
name="aqara_fp310_paired",endpoint=1,mfg_code=0x115F,data_type=data_types.Boolean,
read_only=true,read_on_configure=false,
handler=function(device,value,context)
if type(value)=="table" then value=value.value end
if value==false and context.zb_rx.body.zcl_header.cmd.value==0x0A then
device:send(cluster_base.write_manufacturer_specific_attribute(
device,0xFCC0,0x00FC,0x115F,data_types.Boolean,true):to_endpoint(1))
end
end,
}),
},
}
register_device_definition(aqara_fp310_core,{
fp("Aqara","lumi.sensor_occupy.acn1"),
})
local function aqara_fp1_presence(value)
if type(value)=="table" then value=value.value end
if value==0 then return false end
if value==1 then return true end
end
local aqara_fp1_core={
profile="safety-presence-aqara-fp1-core",magic_packet=false,
parent_refresh=function(device)zcl.read_attribute(device,0xFCC0,0x0142,1,0x115F)end,
zcl_clusters={
zcl.cluster_attribute(0xFCC0,0x0142,{
name="aqara_fp1_presence",endpoint=1,mfg_code=0x115F,data_type=data_types.Uint8,
read_only=true,read_on_configure=true,from_device=aqara_fp1_presence,emit=emit.presence(),
}),
zcl.cluster_attribute(0xFCC0,0x00F7,{
name="aqara_fp1_heartbeat_presence",endpoint=1,mfg_code=0x115F,
read_only=true,read_on_configure=false,
from_device=function(value)return aqara_fp1_presence(aqara_tlv_field(value,101))end,
emit=emit.presence(),
}),
},
}
register_device_definition(aqara_fp1_core,{
fp("aqara","lumi.motion.ac01"),
})
return{
id="zcl.sensors.wave19_environment",
registrations=device_definitions,
}
