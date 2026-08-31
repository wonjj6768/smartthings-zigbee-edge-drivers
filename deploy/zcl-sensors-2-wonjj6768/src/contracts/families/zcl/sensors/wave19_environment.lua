local zcl=require "protocol.zcl"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local data_types=require "st.zigbee.data_types"
local capabilities=require "st.capabilities"
local device_management=require "st.zigbee.device_management"
local cluster_base=require "st.zigbee.cluster_base"
local device_definitions,register_device_definition=device_helpers.definition_registry()
local CLUSTER_POWER_CONFIGURATION=0x0001
local CLUSTER_TIME=0x000A
local CLUSTER_PM25=0x042A
local CLUSTER_FORMALDEHYDE=0x042B
local CLUSTER_HEIMAN_AIR_QUALITY=0xFC81
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
zcl.temperature({
minimum_interval=10,
maximum_interval=3600,
reportable_change=100,
}),
zcl.humidity({
minimum_interval=10,
maximum_interval=3600,
reportable_change=100,
}),
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
device_helpers.create_fingerprint("HEIMAN","HS2AQ-EF-3.0"),
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
capabilities.battery.battery(percentage),
capabilities.voltageMeasurement.voltage({value=voltage_mv / 1000,unit="V"}),
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
zcl.temperature({
minimum_interval=10,
maximum_interval=3600,
reportable_change=100,
}),
zcl.humidity({
minimum_interval=10,
maximum_interval=3600,
reportable_change=100,
}),
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
device_helpers.create_fingerprint("PLAID SYSTEMS","PS-SPRZMS-SLP3"),
})
return{
id="zcl.sensors.wave19_environment",
registrations=device_definitions,
}
