local zcl=require"protocol.zcl"
local emit=require"capabilities.events.all"
local capabilities=require"st.capabilities"
local data_types=require"st.zigbee.data_types"
local device_management=require"st.zigbee.device_management"
local clusters=require"st.zigbee.zcl.clusters"
local cluster_base=require"st.zigbee.cluster_base"
local device_helpers=require"contracts.helpers.family"
local device_definitions,register_device_definition=device_helpers.definition_registry()
local function passive(mapping)
mapping.minimum_interval=nil
mapping.maximum_interval=nil
mapping.reportable_change=nil
mapping.read_on_configure=false
return mapping
end
local function battery_value(value,_,context)
if context.raw_value==255 then return nil end
return value
end
local adurosmart_81910_core={
profile="safety-contact-temp-humidity-battery",magic_packet=false,
parent_refresh=function(device)
zcl.read_attribute(device,0x0402,0,1)zcl.read_attribute(device,0x0405,0,1)zcl.read_attribute(device,1,0x21,1)
end,
zcl_clusters={
passive(zcl.contact({endpoint=1})),zcl.temperature({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=true}),zcl.humidity({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=true}),zcl.battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=2,read_on_configure=true,from_device=battery_value}),},
configure=function(driver,device)
device:send(device_management.build_bind_request(
device,0x0500,driver.environment_info.hub_zigbee_eui,1))
end,
}register_device_definition(adurosmart_81910_core,{
device_helpers.create_fingerprint("AduroSmart ERIA","CSW_81909"),device_helpers.create_fingerprint("ERIA","CSW_81909"),device_helpers.create_fingerprint("AduroSmart Eria","CSW_81909"),})local trust_zcts808_core={
profile="safety-contact-trust808",magic_packet=false,
parent_refresh=function(device)
zcl.read_attribute(device,1,0x21,1)
end,
zcl_clusters={
passive(zcl.contact({endpoint=1,from_device=function(value)
if type(value)=="table"then
if type(value.is_alarm1_set)=="function"then return value:is_alarm1_set()end
value=value.value
end
if type(value)~="number"then return nil end
return(value&1)~=0
end})),
passive(zcl.tamper({endpoint=1})),passive(zcl.battery_low({endpoint=1,name="trust808_battery_low",emit=emit.trust808BatteryLow()})),zcl.battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,from_device=battery_value}),},}register_device_definition(trust_zcts808_core,{
device_helpers.create_fingerprint("Trust International B.V.","CSW_ADUROLIGHT"),device_helpers.create_fingerprint("Trust International B.V.\0","CSW_ADUROLIGHT"),device_helpers.create_fingerprint("ADUROLIGHT","CSW_ADUROLIGHT"),})local rtitek_sthzb_core={
profile="sensors-rtitek-sthzb-core",magic_packet=false,zcl_clusters={
zcl.cluster_attribute(0x0402,0,{name="temperature",endpoint=1,data_type=data_types.Int16,scale=100,read_only=true,read_on_configure=true,emit=emit.temperature()}),zcl.cluster_attribute(0x0405,0,{name="humidity",endpoint=1,data_type=data_types.Uint16,scale=100,read_only=true,read_on_configure=true,emit=emit.humidity()}),zcl.cluster_attribute(1,0x21,{name="battery",endpoint=1,data_type=data_types.Uint8,scale=2,read_only=true,read_on_configure=true,from_device=battery_value,emit=emit.battery()}),},
configure=function(_,device)zcl.read_attribute(device,1,0x20,1)end,
parent_refresh=function(device)
zcl.read_attribute(device,0x0402,0,1)zcl.read_attribute(device,0x0405,0,1)zcl.read_attribute(device,1,0x21,1)zcl.read_attribute(device,1,0x20,1)
end,
}register_device_definition(rtitek_sthzb_core,{
device_helpers.create_fingerprint("Rti-Tek","STHZB"),})local ezviz_cst10c_core={
profile="safety-water-ezviz-cst10c-core",magic_packet=false,zcl_clusters={
passive(zcl.water({endpoint=1,from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end})),
passive(zcl.tamper({endpoint=1})),
passive(zcl.battery_low({endpoint=1,emit=function(_,value)
return value and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end})),
zcl.battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,from_device=battery_value}),},
parent_refresh=function(device)
zcl.read_attribute(device,1,0x21,1)zcl.read_attribute(device,1,0x20,1)
end,
}register_device_definition(ezviz_cst10c_core,{
device_helpers.create_fingerprint("EZVIZ","CS-T10C-A0-BG"),device_helpers.create_fingerprint("EZVIZ","CS-T10C-A0-BG\000\000\000\000"),})local owon_ocp305_core={
profile="safety-presence-owon-ocp305-core",magic_packet=false,zcl_clusters={
zcl.cluster_attribute(0x0406,0,{name="owon_ocp305_presence",endpoint=1,data_type=data_types.Bitmap8,read_only=true,read_on_configure=true,minimum_interval=0,maximum_interval=3600,reportable_change=0,
from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end,emit=emit.presence()}),
},}register_device_definition(owon_ocp305_core,{
device_helpers.create_fingerprint("OWON","OCP305"),})local multir_he300_core={
profile="safety-presence-multir-he300-core",magic_packet=false,
parent_refresh=function(device)
zcl.read_attribute(device,0x0400,0,1)
end,
zcl_clusters={
passive(zcl.occupancy({name="multir_he300_presence",endpoint=1,emit=emit.presence(),
from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&0x03)~=0
end})),
zcl.illuminance({name="multir_he300_illuminance",endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=5,read_on_configure=true}),},}register_device_definition(multir_he300_core,{
device_helpers.create_fingerprint("MultIR","HE300_ZB"),})local zigbeetlc_zg303z_core={
profile="sensors-zigbeetlc-zg303z-core",magic_packet=false,zcl_clusters={
zcl.temperature({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=10,read_on_configure=true}),zcl.humidity({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=true}),zcl.cluster_attribute(0x0405,0,{name="zg303z_soil_moisture",endpoint=2,component="main",data_type=data_types.Uint16,scale=100,read_only=true,read_on_configure=true,minimum_interval=10,maximum_interval=3600,reportable_change=100,
from_device=function(value,_,context)if context.raw_value~=65535 then return value end end,
emit=emit.zg303zSoilMoisture()}),zcl.battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,from_device=battery_value}),passive(zcl.battery_voltage({endpoint=1,from_device=battery_value})),},}register_device_definition(zigbeetlc_zg303z_core,{
device_helpers.create_fingerprint("Sonoff","ZG-303Z-z"),})local ekaza_ts0225_core={
profile="safety-presence-ekaza-ts0225-core",magic_packet=true,query_on_configure=false,query_on_announce=false,time_start="off",
parent_refresh=function()end,
zcl_clusters={
passive(zcl.motion({name="ekaza_presence",endpoint=1,emit=emit.presence()})),},
configure=function(_,device)
zcl.read_attribute(device,0x0500,0x0002,1)
end,
}register_device_definition(ekaza_ts0225_core,{
device_helpers.create_fingerprint("_TZ3210_eep3fewj","TS0225"),})local smartthings_tagv4_core={
profile="sensors-smartthings-tagv4-core",magic_packet=false,parent_refresh=function()end,
zcl_clusters={
zcl.cluster_attribute(0x000F,0x0055,{name="tagv4_heartbeat",endpoint=1,data_type=data_types.Boolean,read_only=true,read_on_configure=false,minimum_interval=10,maximum_interval=60,reportable_change=true,
emit=function(device)
local key="tagv4_presence_timer";local old=device:get_field(key)
if old then old:cancel()end
device:set_field(key,device.thread:call_with_delay(100,function()
device:set_field(key,nil);device:emit_event(emit.presence()(device,false))
end,"Tagv4 absent"))
return emit.presence()(device,true)
end}),
zcl.cluster_attribute(1,0x20,{name="tagv4_voltage",endpoint=1,data_type=data_types.Uint8,read_only=true,read_on_configure=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,
emit=function(_,value)
if value==255 then return end
return{capabilities.voltageMeasurement.voltage({value=value/10,unit="V"}),capabilities.battery.battery(math.max(0,math.min(100,(value-25)*20)))}
end}),
zcl.cluster_attribute(1,0x3E,{name="tagv4_battery_alarm",endpoint=1,data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=function(_,value)
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end}),
},}register_device_definition(smartthings_tagv4_core,{
device_helpers.create_fingerprint("SmartThings","tagv4"),})
local function aqara_gas_heartbeat(device,value)
local fields=type(value)=="table"and value.value or value
if fields==nil then fields=value end
if type(fields)=="string"then
local decoded,offset={},1
while offset+1<=#fields do
local key,kind=fields:byte(offset,offset+1)local width=kind>=0x20 and kind<=0x2F and((kind%8)+1)or kind==0x10 and 1
if not width or offset+1+width>#fields then break end
decoded[key]=string.unpack("<"..(kind>=0x28 and"i"or"I")..width,fields,offset+2)offset=offset+2+width
end
fields=decoded
end
if type(fields)~="table"then return end
local alarm=fields[160]or fields["160"]
if alarm~=nil then return emit.gas()(device,alarm==1)end
end
local aqara_gas_acn02_core={
profile="safety-aqara-gas-acn02-core",magic_packet=false,zcl_clusters={
zcl.cluster_attribute(0xFCC0,0x013A,{name="aqara_gas_alarm",endpoint=1,mfg_code=0x115F,data_type=data_types.Uint8,
read_only=true,read_on_configure=true,from_device=function(value)return value==1 end,emit=emit.gas()}),
zcl.cluster_attribute(0xFCC0,0x00F7,{name="aqara_gas_heartbeat",endpoint=1,read_only=true,read_on_configure=false,emit=aqara_gas_heartbeat}),},
configure=function(_,device)
device:send(cluster_base.write_manufacturer_specific_attribute(device,0xFCC0,0x014B,0x115F,data_types.Uint8,1):to_endpoint(1))
end,
parent_refresh=function(device)
device:send(cluster_base.read_manufacturer_specific_attribute(device,0xFCC0,0x013A,0x115F):to_endpoint(1))
end,
}register_device_definition(aqara_gas_acn02_core,{
device_helpers.create_fingerprint("LUMI","lumi.sensor_gas.acn02"),})local frient_heszb120_core={
profile="safety-frient-heszb120-core",magic_packet=false,zcl_clusters={
zcl.smoke({endpoint=35,component="main",minimum_interval=0,maximum_interval=65000,reportable_change=0,read_on_configure=true,
from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end,emit=function(_,value)
return value and capabilities.temperatureAlarm.temperatureAlarm.heat()or capabilities.temperatureAlarm.temperatureAlarm.cleared()
end}),
passive(zcl.battery_low({endpoint=35,component="main",emit=function(_,value)
return value and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end})),
zcl.temperature({endpoint=38,component="main",minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=true}),passive(zcl.battery({endpoint=35,component="main",from_device=battery_value})),zcl.cluster_attribute(1,0x20,{name="heszb120_voltage",endpoint=35,component="main",data_type=data_types.Uint8,read_only=true,read_on_configure=true,minimum_interval=3600,maximum_interval=65000,reportable_change=10,
emit=function(_,value)
if value==255 then return end
return{capabilities.voltageMeasurement.voltage({value=value/10,unit="V"}),capabilities.battery.battery(math.max(0,math.min(100,(value-25)*20)))}
end}),
},
parent_refresh=function(device)
device:send(clusters.TemperatureMeasurement.attributes.MeasuredValue:read(device):to_endpoint(38))device:send(clusters.PowerConfiguration.attributes.BatteryPercentageRemaining:read(device):to_endpoint(35))device:send(clusters.PowerConfiguration.attributes.BatteryVoltage:read(device):to_endpoint(35))
end,
}register_device_definition(frient_heszb120_core,{
device_helpers.create_fingerprint("frient A/S","HESZB-120"),})local tuya_ts0210_vibration_core={
profile="safety-tuya-ts0210-vibration-core",magic_packet=false,parent_refresh=function()end,
zcl_clusters={
passive(zcl.motion({endpoint=1,from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end,handler=function(device,_,context)
if context.command_id~=0 then return end
local key="ts0210_core_clear_timer"
local old=device:get_field(key)
if old then old:cancel()end
device:set_field(key,device.thread:call_with_delay(90,function()
device:set_field(key,nil)device:emit_event(emit.acceleration()(device,false))
end,"TS0210 clear"))
end,emit=function(device,value,context)
if context.command_id==0 then return emit.acceleration()(device,value)end
end})),
passive(zcl.tamper({endpoint=1,emit=function(device,value,context)
if context.command_id==0 then return emit.tamper()(device,value)end
end})),
passive(zcl.battery_low({endpoint=1,emit=function(_,value,context)
if context.command_id==0 then return value and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()end
end})),
passive(zcl.battery({endpoint=1,from_device=battery_value})),passive(zcl.battery_voltage({endpoint=1,from_device=battery_value})),zcl.cluster_attribute(1,0x3E,{name="ts0210_core_battery_alarm",endpoint=1,data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=function(_,value)
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end}),
},}register_device_definition(tuya_ts0210_vibration_core,{
device_helpers.create_fingerprint("_TYZB01_3zv6oleo","TS0210"),device_helpers.create_fingerprint("_TZ3000_bmfw9ykl","TS0210"),device_helpers.create_fingerprint("_TZ3000_fkxmyics","TS0210"),device_helpers.create_fingerprint("_TZ3000_jqge2fjx","TS0210"),device_helpers.create_fingerprint("_TZ3000_lqpt3mvr","TS0210"),})local visonic_gb540_core={
profile="safety-visonic-gb540-core",magic_packet=false,parent_refresh=function()end,
zcl_clusters={
passive(zcl.motion({endpoint=1,from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end,emit=function(device,value,context)
if context.command_id==0 then return emit.acceleration()(device,value)end
end})),
passive(zcl.tamper({endpoint=1,emit=function(device,value,context)
if context.command_id==0 then return emit.tamper()(device,value)end
end})),
passive(zcl.battery_low({endpoint=1,emit=function(_,value,context)
if context.command_id==0 then return value and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()end
end})),
},}register_device_definition(visonic_gb540_core,{
device_helpers.create_fingerprint("Visonic","GB-540"),})local lumi_natgas_core={
profile="safety-lumi-natgas-core",magic_packet=false,parent_refresh=function()end,
zcl_clusters={
passive(zcl.gas({endpoint=1,from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end,emit=function(device,value,context)
if context.command_id==0 then return emit.gas()(device,value)end
end})),
passive(zcl.tamper({endpoint=1,emit=function(device,value,context)
if context.command_id==0 then return emit.tamper()(device,value)end
end})),
passive(zcl.battery_low({endpoint=1,emit=function(_,value,context)
if context.command_id==0 then return value and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()end
end})),
},}register_device_definition(lumi_natgas_core,{
device_helpers.create_fingerprint("LUMI","lumi.sensor_natgas"),})local tuya_ts0204_gas_core={
profile="safety-tuya-ts0204-gas-core",magic_packet=false,parent_refresh=function()end,
zcl_clusters={
passive(zcl.gas({endpoint=1,from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end,emit=function(device,value,context)
if context.command_id==0 then return emit.gas()(device,value)end
end})),
passive(zcl.tamper({endpoint=1,emit=function(device,value,context)
if context.command_id==0 then return emit.tamper()(device,value)end
end})),
passive(zcl.battery_low({endpoint=1,emit=function(_,value,context)
if context.command_id==0 then return value and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()end
end})),
},}register_device_definition(tuya_ts0204_gas_core,{
device_helpers.create_fingerprint("_TYZB01_18pkine6","TS0204"),device_helpers.create_fingerprint("_TYZB01_mfccmeio","TS0204"),})local feibit_sga01zb_core={
profile="safety-feibit-sga01zb-core",magic_packet=false,parent_refresh=function()end,
zcl_clusters={
passive(zcl.gas_alarm_2({endpoint=1,emit=function(device,value,context)
if context.command_id==0 then return emit.gas()(device,value)end
end})),
passive(zcl.tamper({endpoint=1,emit=function(device,value,context)
if context.command_id==0 then return emit.tamper()(device,value)end
end})),
passive(zcl.battery_low({endpoint=1,emit=function(_,value,context)
if context.command_id==0 then return value and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()end
end})),
},}register_device_definition(feibit_sga01zb_core,{
device_helpers.create_fingerprint("feibit","FNB56-GAS05FB1.4"),})local trust_co_em_core={
profile="safety-trust-co-em-core",magic_packet=false,parent_refresh=function()end,
zcl_clusters={
passive(zcl.carbon_monoxide({endpoint=1,from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end,emit=function(device,value,context)
if context.command_id==0 then return emit.carbon_monoxide()(device,value)end
end})),
passive(zcl.tamper({endpoint=1,emit=function(device,value,context)
if context.command_id==0 then return emit.tamper()(device,value)end
end})),
passive(zcl.battery_low({endpoint=1,emit=function(_,value,context)
if context.command_id==0 then return value and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()end
end})),
zcl.battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,from_device=battery_value}),passive(zcl.battery_voltage({endpoint=1,from_device=battery_value})),zcl.cluster_attribute(1,0x3E,{name="trust_co_battery_alarm",endpoint=1,data_type=data_types.Bitmap32,read_only=true,read_on_configure=false,
emit=function(_,value)
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end}),
},}register_device_definition(trust_co_em_core,{
device_helpers.create_fingerprint("Trust","COSensor-EM"),})local feibit_sca01zb_core={
profile="safety-feibit-sca01zb-core",magic_packet=false,parent_refresh=function()end,
zcl_clusters={
passive(zcl.carbon_monoxide({endpoint=1,from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end,emit=function(device,value,context)
if context.command_id==0 then return emit.carbon_monoxide()(device,value)end
end})),
passive(zcl.tamper({endpoint=1,emit=function(device,value,context)
if context.command_id==0 then return emit.tamper()(device,value)end
end})),
passive(zcl.battery_low({endpoint=1,emit=function(_,value,context)
if context.command_id==0 then return value and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()end
end})),
zcl.battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,from_device=battery_value}),passive(zcl.battery_voltage({endpoint=1,from_device=battery_value})),zcl.cluster_attribute(1,0x3E,{name="feibit_co_battery_alarm",endpoint=1,data_type=data_types.Bitmap32,read_only=true,read_on_configure=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,
emit=function(_,value)
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end}),
},}register_device_definition(feibit_sca01zb_core,{
device_helpers.create_fingerprint("feibit","FNB56-COS06FB1.7"),device_helpers.create_fingerprint("Heiman","1ccaa94c49a84abaa9e38687913947ba"),})local owon_pir313p_core={
profile="safety-motion-owon-pir313p-core",magic_packet=false,zcl_clusters={
passive(zcl.occupancy({endpoint=1,ias_zone=true,emit=emit.motion(),
from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end})),
passive(zcl.tamper({endpoint=1})),
passive(zcl.battery_low({endpoint=1,emit=function(_,value)
return value and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end})),
zcl.battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,from_device=battery_value}),},}register_device_definition(owon_pir313p_core,{
device_helpers.create_fingerprint("OWON","PIR313-P"),})local tis_ed6xx_core={
profile="safety-motion-tis-ed6xx-core",magic_packet=false,
parent_refresh=function(device)
zcl.read_attribute(device,1,0x21,1)zcl.read_attribute(device,1,0x20,1)
end,
zcl_clusters={
passive(zcl.occupancy({endpoint=1,ias_zone=true,emit=emit.motion(),
from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end})),
passive(zcl.tamper({endpoint=1})),
passive(zcl.battery_low({endpoint=1,emit=function(_,value)
return value and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end})),
zcl.battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,from_device=battery_value}),},}register_device_definition(tis_ed6xx_core,{
device_helpers.create_fingerprint("JHL","ED6XX"),})local owon_pir313e_core={
profile="safety-motion-owon-pir313e-core",magic_packet=false,
configure=function(_,device)
for endpoint in pairs(device.zigbee_endpoints)do
if device:supports_server_cluster(0x0400,endpoint)then
zcl.read_attribute(device,0x0400,0,endpoint)
end
end
end,
zcl_clusters={
passive(zcl.occupancy({endpoint=1,ias_zone=true,emit=emit.motion(),
from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end})),
passive(zcl.tamper({endpoint=1})),
passive(zcl.battery_low({endpoint=1,emit=function(_,value)
return value and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end})),
zcl.battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,from_device=battery_value}),zcl.temperature({endpoint=2,component="main",minimum_interval=60,maximum_interval=3600,reportable_change=50,read_on_configure=false}),zcl.humidity({endpoint=2,component="main",minimum_interval=60,maximum_interval=3600,reportable_change=100,read_on_configure=false}),zcl.illuminance({component="main",minimum_interval=300,maximum_interval=3600,reportable_change=100,read_on_configure=false}),},}register_device_definition(owon_pir313e_core,{
device_helpers.create_fingerprint("OWON","PIR313-E"),})local owon_pir323pth_core={
profile="safety-motion-owon-pir323pth-core",magic_packet=false,
configure=function(driver,device)
device:send(device_management.build_bind_request(device,0x0402,driver.environment_info.hub_zigbee_eui,2))device:send(device_management.build_bind_request(device,0x0405,driver.environment_info.hub_zigbee_eui,2))
end,
zcl_clusters={
passive(zcl.occupancy({endpoint=1,ias_zone=true,emit=emit.motion(),
from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end})),
passive(zcl.battery_low({endpoint=1,emit=function(_,value)
return value and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end})),
passive(zcl.temperature({endpoint=2,component="main"})),passive(zcl.humidity({endpoint=2,component="main"})),},}register_device_definition(owon_pir323pth_core,{
device_helpers.create_fingerprint("OWON","PIR323-PTH"),})local lds_pfmot001_core={
profile="safety-motion-lds-pfmot001-core",magic_packet=false,zcl_clusters={
passive(zcl.occupancy({endpoint=1,ias_zone=true,emit=emit.motion(),
from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end})),
passive(zcl.tamper({endpoint=1})),
passive(zcl.battery_low({endpoint=1,emit=function(_,value)
return value and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end})),
zcl.battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,from_device=battery_value}),},}register_device_definition(lds_pfmot001_core,{
device_helpers.create_fingerprint("LDS","PFMOT001"),})local owon_ths317_core={
profile="sensors-owon-ths317-core",magic_packet=false,zcl_clusters={
zcl.temperature({endpoint=2,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=false}),zcl.humidity({endpoint=2,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=false}),zcl.battery({endpoint=2,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,from_device=battery_value}),zcl.battery_voltage({endpoint=2,minimum_interval=3600,maximum_interval=65000,reportable_change=0,
read_on_configure=true,from_device=function()return nil end}),
},}register_device_definition(owon_ths317_core,{
device_helpers.create_fingerprint("OWON","THS317"),})
local function motion_mapping(notification_only)
return passive(zcl.occupancy({endpoint=1,ias_zone=true,
from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end,
emit=function(device,value,context)
if not notification_only or context.command_id==0 then return emit.motion()(device,value)end
end,
}))
end
local function low_mapping(notification_only)
return passive(zcl.battery_low({endpoint=1,emit=function(_,value,context)
if not notification_only or context.command_id==0 then
return value and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end
end}))
end
local function immax_motion_clusters()
return{
motion_mapping(true),low_mapping(true),
passive(zcl.tamper({endpoint=1,emit=function(device,value,context)
if context.command_id==0 then return emit.tamper()(device,value)end
end})),
passive(zcl.battery({endpoint=1,from_device=battery_value})),zcl.cluster_attribute(1,0x3E,{name="immax_battery_alarm",endpoint=1,data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=function(_,value)
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end}),
}
end
local immax_motion_core={
profile="safety-motion-immax-core",magic_packet=false,zcl_clusters=immax_motion_clusters(),}register_device_definition(immax_motion_core,{
device_helpers.create_fingerprint("IMMAX","Motion-Sensor-ZB3.0"),})local leedarson_s0000_core={
profile="safety-motion-leedarson-s0000-core",magic_packet=false,zcl_clusters={motion_mapping(true),passive(zcl.battery({endpoint=1,from_device=battery_value}))},}register_device_definition(leedarson_s0000_core,{
device_helpers.create_fingerprint("Leedarson","ZB-MotionSensor-S0000"),})local somfy_motion_core={
profile="safety-motion-somfy-core",magic_packet=false,zcl_clusters={
motion_mapping(false),low_mapping(false),zcl.battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,from_device=battery_value}),},}register_device_definition(somfy_motion_core,{
device_helpers.create_fingerprint("SOMFY","1811681"),})local orvibo_st30_core={
profile="sensors-orvibo-st30-core",magic_packet=false,zcl_clusters={
zcl.temperature({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=true}),zcl.humidity({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=true}),zcl.battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,from_device=battery_value}),},}register_device_definition(orvibo_st30_core,{
device_helpers.create_fingerprint("ORVIBO","898ca74409a740b28d5841661e72268d"),device_helpers.create_fingerprint("ORVIBO","50938c4c3c0b4049923cd5afbc151bde"),})local immax_four_core={
profile="sensors-immax-four-core",magic_packet=false,zcl_clusters=immax_motion_clusters(),}table.insert(immax_four_core.zcl_clusters,zcl.temperature({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=false}))table.insert(immax_four_core.zcl_clusters,zcl.humidity({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=false}))table.insert(immax_four_core.zcl_clusters,zcl.illuminance({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=5,read_on_configure=true}))register_device_definition(immax_four_core,{
device_helpers.create_fingerprint("IMMAX","4in1-Sensor-ZB3.0"),})
local function occupancy_mapping()
return zcl.occupancy({endpoint=1,emit=emit.motion(),minimum_interval=0,maximum_interval=3600,
reportable_change=0,read_on_configure=true,from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end})
end
local sunricher_dim_pir_core={
profile="sensors-sunricher-dim-pir-core",magic_packet=false,
parent_refresh=function(device)
zcl.read_attribute(device,0x0406,0,2)zcl.read_attribute(device,0x0400,0,3)
end,
zcl_clusters={
zcl.occupancy({endpoint=2,component="main",emit=emit.motion(),minimum_interval=0,maximum_interval=3600,
reportable_change=0,read_on_configure=true,from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end}),
zcl.illuminance({endpoint=3,component="main",minimum_interval=10,maximum_interval=3600,reportable_change=5,read_on_configure=true}),},}register_device_definition(sunricher_dim_pir_core,{
device_helpers.create_fingerprint("Sunricher","HK-DIM-PIR"),})local sunricher_presence_core={
profile="sensors-sunricher-presence-core",magic_packet=false,zcl_clusters={
occupancy_mapping(),zcl.cluster_attribute(0x0400,0,{name="sunricher_presence_lux",endpoint=1,data_type=data_types.Uint16,read_only=true,emit=emit.illuminance(),minimum_interval=10,maximum_interval=3600,reportable_change=5,read_on_configure=true}),},}register_device_definition(sunricher_presence_core,{
device_helpers.create_fingerprint("Sunricher","HK-SENSOR-PRE"),})local heiman_hs2fd_presence_core={
profile="sensors-heiman-hs2fd-presence-core",magic_packet=false,
parent_refresh=function()end,
zcl_clusters={
zcl.cluster_attribute(0x0406,0,{name="heiman_hs2fd_occupancy",endpoint=1,data_type=data_types.Bitmap8,read_only=true,read_on_configure=false,minimum_interval=0,maximum_interval=3600,reportable_change=0,
from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end,emit=emit.motion()}),
},}register_device_definition(heiman_hs2fd_presence_core,{
device_helpers.create_fingerprint("HEIMAN","HS2FD-EF1-3.0"),})local heiman_hs8os_core={
profile="sensors-heiman-hs8os-core",magic_packet=false,zcl_clusters={
occupancy_mapping(),zcl.cluster_attribute(0x0400,0,{name="heiman_hs8os_lux",endpoint=1,data_type=data_types.Uint16,read_only=true,emit=emit.illuminance(),read_on_configure=true}),},
configure=function(driver,device)
device:send(device_management.build_bind_request(device,0x0400,driver.environment_info.hub_zigbee_eui,1))
end,
}register_device_definition(heiman_hs8os_core,{
device_helpers.create_fingerprint("HEIMAN","HS8OS-EF1-3.0"),})local robb_presence_core={
profile="sensors-robb-presence-core",magic_packet=false,zcl_clusters={
occupancy_mapping(),passive(zcl.tamper({endpoint=1})),low_mapping(false),zcl.temperature({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=true}),zcl.humidity({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=true}),zcl.illuminance({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=5,read_on_configure=true}),zcl.battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,from_device=battery_value}),},}register_device_definition(robb_presence_core,{
device_helpers.create_fingerprint("ROBB smarrt","ROB_200-070-0"),})local climax_rs23_core={
profile="sensors-climax-rs23-core",magic_packet=false,zcl_clusters={
zcl.temperature({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=false}),passive(zcl.humidity({endpoint=1})),},
configure=function(driver,device)
device:send(device_management.build_bind_request(device,0x0405,driver.environment_info.hub_zigbee_eui,1))
end,
}register_device_definition(climax_rs23_core,{
device_helpers.create_fingerprint("Climax Technology Co.","RS_00.00.02.06TC"),})local climax_smoke_core={
profile="safety-smoke-climax-core",magic_packet=false,zcl_clusters={
passive(zcl.smoke({endpoint=1,from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end})),
passive(zcl.tamper({endpoint=1})),low_mapping(false),passive(zcl.battery({endpoint=1,from_device=battery_value})),zcl.cluster_attribute(1,0x3E,{name="climax_battery_alarm",endpoint=1,data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=function(_,value)
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end}),
},}register_device_definition(climax_smoke_core,{
device_helpers.create_fingerprint("Climax Technology Co.","SD8SC_00.00.03.12TC"),})
local function imou_motion_mapping()
local mapping=motion_mapping(false)
mapping.emit=function(device,value)
local previous=device:get_field("__imou_motion_timer")
if previous then previous:cancel()end
device:set_field("__imou_motion_timer",device.thread:call_with_delay(90,function()
device:set_field("__imou_motion_timer",nil)device:emit_event(capabilities.motionSensor.motion.inactive())
end,"Motion reset"))
return emit.motion()(device,value)
end
return mapping
end
local imou_zp1_core={
profile="safety-motion-imou-zp1-core",magic_packet=false,zcl_clusters={
imou_motion_mapping(),passive(zcl.tamper({endpoint=1})),low_mapping(false),zcl.battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,from_device=battery_value}),},}register_device_definition(imou_zp1_core,{
device_helpers.create_fingerprint("MultIR","ZP1-EN"),})
local function battery_3v2100(value)
if value==255 then return nil end
local voltage=value*100
local percent=100
if voltage<2100 then percent=0
elseif voltage<2440 then percent=6-(2440-voltage)*6/340
elseif voltage<2740 then percent=18-(2740-voltage)*12/300
elseif voltage<2900 then percent=42-(2900-voltage)*24/160
elseif voltage<3000 then percent=100-(3000-voltage)*58/100 end
return math.floor(percent+0.5)
end
local function iris_contact_clusters(tamper)
local rows={
passive(zcl.contact({endpoint=1,emit=function(device,value,context)
if context.command_id==0 then return emit.contact()(device,value)end
end})),
low_mapping(true),zcl.temperature({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=false}),zcl.cluster_attribute(1,0x20,{name="iris_contact_battery",endpoint=1,data_type=data_types.Uint8,read_only=true,read_on_configure=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,from_device=battery_3v2100,emit=emit.battery()}),zcl.cluster_attribute(1,0x3E,{name="iris_contact_battery_alarm",endpoint=1,data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=function(_,value)
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end}),
}
if tamper then rows[#rows+1]=passive(zcl.tamper({endpoint=1,emit=function(device,value,context)
if context.command_id==0 then return emit.tamper()(device,value)end
end}))end
return rows
end
local iris_1116_core={
profile="sensors-iris-1116-core",magic_packet=false,zcl_clusters=iris_contact_clusters(true),}register_device_definition(iris_1116_core,{
device_helpers.create_fingerprint("iMagic by GreatStar","1116-S"),})local iris_3320_core={
profile="sensors-iris-3320-core",magic_packet=false,zcl_clusters=iris_contact_clusters(false),}register_device_definition(iris_3320_core,{
device_helpers.create_fingerprint("iMagic by GreatStar","3320-L"),})local konke_smoke_core={
profile="safety-smoke-konke-core",magic_packet=false,zcl_clusters={
passive(zcl.smoke({endpoint=1,from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end})),low_mapping(false),
},}register_device_definition(konke_smoke_core,{
device_helpers.create_fingerprint("Konke","3AFE010104020028"),device_helpers.create_fingerprint("iHorn","LH05121"),})local lifecontrol_motion_core={
profile="safety-motion-lifecontrol-core",magic_packet=false,zcl_clusters={
motion_mapping(false),passive(zcl.tamper({endpoint=1})),low_mapping(false),passive(zcl.battery({endpoint=1,scale=1,from_device=battery_value})),},}register_device_definition(lifecontrol_motion_core,{
device_helpers.create_fingerprint("Nexturn","Motion_Sensor"),})local gs_motion_core={
profile="safety-motion-gs-smhm-core",magic_packet=false,zcl_clusters={
motion_mapping(false),passive(zcl.tamper({endpoint=1})),low_mapping(false),zcl.battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,
read_on_configure=true,from_device=function(value,_,context)
local body=context.zb_rx.body.zcl_body
local voltage=type(body.get_attribute_data)=="function"and body:get_attribute_data(0x20)
if type(voltage)=="table"then voltage=voltage.value end
if type(voltage)=="number"and voltage<255 then return nil end
return battery_value(value,nil,context)
end}),
zcl.cluster_attribute(1,0x20,{name="gs_motion_voltage",endpoint=1,data_type=data_types.Uint8,
read_only=true,read_on_configure=false,emit=function(_,value)
if value==255 then return nil end
return{capabilities.battery.battery(math.floor(math.max(0,math.min(100,(value-25)*20))+0.5)),capabilities.voltageMeasurement.voltage({value=value/10,unit="V"})}
end}),
},}register_device_definition(gs_motion_core,{
device_helpers.create_fingerprint("GS","SMHM-I1"),})local slacky_lcd_core={
profile="sensors-slacky-lcd-core",magic_packet=false,zcl_clusters={
zcl.temperature({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=10,read_on_configure=true}),zcl.humidity({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=10,read_on_configure=true}),zcl.battery({endpoint=1,minimum_interval=3600,maximum_interval=21600,reportable_change=0,read_on_configure=true,from_device=battery_value}),zcl.battery_voltage({endpoint=1,minimum_interval=3600,maximum_interval=21600,reportable_change=0,read_on_configure=true,from_device=battery_value}),},}register_device_definition(slacky_lcd_core,{
device_helpers.create_fingerprint("Slacky-DIY","TS0201-z2C-SlD"),})
local function datek_occupancy_mapping()
local mapping=occupancy_mapping()mapping.read_on_configure=false
return mapping
end
local datek_motion_core={
profile="sensors-datek-motion-core",magic_packet=false,zcl_clusters={
datek_occupancy_mapping(),motion_mapping(false),low_mapping(false),zcl.temperature({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=false}),zcl.illuminance({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=5,read_on_configure=true}),zcl.cluster_attribute(1,0x3E,{name="datek_battery_alarm",endpoint=1,data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=function(_,value)
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end}),
},
configure=function(driver,device)
device:send(device_management.build_bind_request(device,0x0500,driver.environment_info.hub_zigbee_eui,1))
for _,attribute in ipairs({0x0010,0x0000,0x0011})do zcl.read_attribute(device,0x0500,attribute,1)end
end,
}register_device_definition(datek_motion_core,{
device_helpers.create_fingerprint("Datek","Motion Sensor"),})local schneider_w564100_core={
profile="sensors-schneider-w564100-core",magic_packet=false,zcl_clusters={
passive(zcl.occupancy({endpoint=20,ias_zone=true,emit=emit.motion(),from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&2)~=0
end})),
zcl.temperature({endpoint=20,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=true}),zcl.cluster_attribute(0x0400,0,{name="schneider_w564100_lux",endpoint=20,data_type=data_types.Uint16,read_only=true,emit=emit.illuminance(),minimum_interval=10,maximum_interval=3600,reportable_change=5,read_on_configure=true}),},}register_device_definition(schneider_w564100_core,{
device_helpers.create_fingerprint("Schneider Electric","W564100"),})local niko_motion_core={
profile="safety-motion-niko-core",magic_packet=false,zcl_clusters={
motion_mapping(true),low_mapping(true),zcl.cluster_attribute(1,0x20,{name="niko_motion_battery",endpoint=1,data_type=data_types.Uint8,read_only=true,read_on_configure=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,from_device=battery_3v2100,emit=emit.battery()}),zcl.cluster_attribute(1,0x3E,{name="niko_motion_battery_alarm",endpoint=1,data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=function(_,value)
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end}),
},}register_device_definition(niko_motion_core,{
device_helpers.create_fingerprint("Niko NV","Connectable motion sensor,Zigbee"),})local multir_sm200_core={
profile="safety-smoke-multir-sm200-core",magic_packet=false,zcl_clusters={
passive(zcl.smoke({endpoint=1,from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end})),
passive(zcl.tamper({endpoint=1})),low_mapping(false),zcl.battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,from_device=battery_value}),},}register_device_definition(multir_sm200_core,{
device_helpers.create_fingerprint("MultIR","MIR-SM200"),})local hzc_s093th_core={
profile="sensors-hzc-s093th-core",magic_packet=false,zcl_clusters={
passive(zcl.temperature({endpoint=1})),
passive(zcl.humidity({endpoint=1,from_device=function(value)
if value>=0 and value<=100 then return value end
end})),
},}register_device_definition(hzc_s093th_core,{
device_helpers.create_fingerprint("Shyugj","TempAndHumSensor-ZB3.0"),})local slacky_smoke_core={
profile="safety-smoke-slacky-core",magic_packet=false,zcl_clusters={
passive(zcl.smoke({endpoint=1,from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end})),
passive(zcl.tamper({endpoint=1})),low_mapping(false),zcl.battery({endpoint=1,minimum_interval=3600,maximum_interval=21600,reportable_change=0,read_on_configure=true,from_device=battery_value}),zcl.battery_voltage({endpoint=1,minimum_interval=3600,maximum_interval=21600,reportable_change=0,read_on_configure=true,from_device=battery_value}),},}register_device_definition(slacky_smoke_core,{
device_helpers.create_fingerprint("Slacky-DIY","Smoke_Sensor_TLSR8258"),})local imou_ztm1_core={
profile="sensors-imou-ztm1-core",magic_packet=false,zcl_clusters={},
configure=function(driver,device)
device:send(device_management.build_bind_request(device,1,driver.environment_info.hub_zigbee_eui,1))device:send(clusters.PowerConfiguration.attributes.BatteryPercentageRemaining:configure_reporting(device,3600,65000,10):to_endpoint(1))zcl.read_attribute(device,1,0x21,1)
end,
}for _,endpoint in ipairs({1,2})do
for _,mapping in ipairs({
zcl.temperature({endpoint=endpoint,component="main",minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=true}),zcl.humidity({endpoint=endpoint,component="main",minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=true}),passive(zcl.battery({endpoint=endpoint,component="main",from_device=battery_value})),
})do imou_ztm1_core.zcl_clusters[#imou_ztm1_core.zcl_clusters+1]=mapping end
end
register_device_definition(imou_ztm1_core,{
device_helpers.create_fingerprint("MultIR","ZTM1-EN"),})local casaia_probe_core={
profile="sensors-casaia-probe-core",magic_packet=false,zcl_clusters={
zcl.temperature({endpoint=3,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=false}),zcl.cluster_attribute(1,0x20,{name="casaia_probe_battery",endpoint=3,data_type=data_types.Uint8,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,
from_device=function(value)
if value==255 then return nil end
return math.max(0,math.min(100,(value*100-2500)/5))
end,emit=emit.battery()}),
zcl.cluster_attribute(1,0x21,{name="casaia_probe_percentage_config",endpoint=3,data_type=data_types.Uint8,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true}),zcl.cluster_attribute(1,0x3E,{name="casaia_probe_battery_alarm",endpoint=3,data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=function(_,value)
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end}),
},}register_device_definition(casaia_probe_core,{
device_helpers.create_fingerprint("CASAIA","CTHS317ET"),})local pushok_soil_core={
profile="sensors-pushok-soil-core",magic_packet=false,zcl_clusters={
zcl.cluster_attribute(0x0402,0,{name="pushok_soil_temperature",endpoint=1,data_type=data_types.Int16,scale=100,read_only=true,read_on_configure=true,emit=emit.temperature()}),zcl.cluster_attribute(0x0405,0,{name="pushok_soil_moisture",endpoint=1,data_type=data_types.Uint16,scale=100,read_only=true,read_on_configure=true,emit=emit.humidity()}),passive(zcl.battery({endpoint=1,from_device=battery_value})),passive(zcl.battery_voltage({endpoint=1,from_device=battery_value})),},}register_device_definition(pushok_soil_core,{
device_helpers.create_fingerprint("PushOk Hardware","POK002"),device_helpers.create_fingerprint("PushOk Hardware","POK007"),})local pushok_contact_th_core={
profile="sensors-pushok-contact-th-core",magic_packet=false,zcl_clusters={
zcl.cluster_attribute(0x000F,0x0055,{name="pushok_contact",endpoint=1,data_type=data_types.Boolean,
read_only=true,read_on_configure=true,emit=function(_,value)
return(value==1 or value==true)and capabilities.contactSensor.contact.closed()or capabilities.contactSensor.contact.open()
end}),
zcl.cluster_attribute(0x0402,0,{name="pushok_contact_temperature",endpoint=1,data_type=data_types.Int16,scale=100,read_only=true,read_on_configure=true,emit=emit.temperature()}),passive(zcl.humidity({endpoint=1})),passive(zcl.battery({endpoint=1,from_device=battery_value})),passive(zcl.battery_voltage({endpoint=1,from_device=battery_value})),},}register_device_definition(pushok_contact_th_core,{
device_helpers.create_fingerprint("PushOk Hardware","POK010"),})local tapestry_thpz1_core={
profile="sensors-tapestry-thpz1-core",magic_packet=false,
configure=function(driver,device)
device:send(device_management.build_bind_request(device,0x0402,driver.environment_info.hub_zigbee_eui,1))device:send(device_management.build_bind_request(device,0x0405,driver.environment_info.hub_zigbee_eui,1))
end,
zcl_clusters={
zcl.cluster_attribute(0x0406,0,{name="tapestry_occupancy",endpoint=1,data_type=data_types.Bitmap8,read_only=true,minimum_interval=1,maximum_interval=600,read_on_configure=false,
from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end,emit=emit.motion()}),
passive(zcl.temperature({endpoint=1})),passive(zcl.humidity({endpoint=1})),},}register_device_definition(tapestry_thpz1_core,{
device_helpers.create_fingerprint("Tapestry","THPZ1"),})
local function tradfri_battery(device,raw)
local version=device:get_field("__tradfri_core_version")or""
local major,minor,patch,suffix=version:match("^[v= ]*(%d+)%.(%d+)%.(%d+)(.*)$")local old=false
if major and(suffix==""or suffix:sub(1,1)=="-"or suffix:sub(1,1)=="+")then
major,minor,patch=tonumber(major),tonumber(minor),tonumber(patch)old=major<2 or(major==2 and(minor<4 or(minor==4 and patch==0 and suffix:sub(1,1)=="-")))
end
return emit.battery()(device,old and raw or raw/2)
end
local ikea_tradfri_motion_core={
profile="safety-motion-ikea-tradfri-core",magic_packet=false,zcl_clusters={
zcl.cluster_attribute(6,0x42,{name="tradfri_timed_motion",endpoint=1,read_only=true,read_on_configure=false,
command_id=0x42,command_extractor=function(rx)
return rx.body.zcl_body
end,
emit=function(device,body,context)
if context.command_id~=0x42 then return nil end
local control=body.on_off_control.value
local timeout=body.on_time.value/10
local previous=device:get_field("__tradfri_core_timer")
if(control&1)~=0 and not previous then return nil end
if previous then previous:cancel()end
device:set_field("__tradfri_core_timer",nil)if timeout~=0 then
device:set_field("__tradfri_core_timer",device.thread:call_with_delay(timeout,function()
device:set_field("__tradfri_core_timer",nil)device:emit_event(capabilities.motionSensor.motion.inactive())
end,"Motion reset"))
end
return capabilities.motionSensor.motion.active()
end}),
zcl.cluster_attribute(1,0x21,{name="tradfri_battery",endpoint=1,data_type=data_types.Uint8,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,
emit=function(device,raw)
if raw==255 then return nil end
device:set_field("__tradfri_core_battery",raw)return tradfri_battery(device,raw)
end}),
zcl.cluster_attribute(0,0x4000,{name="tradfri_software_build",endpoint=1,data_type=data_types.CharString,
read_only=true,read_on_configure=true,emit=function(device,version)
device:set_field("__tradfri_core_version",version,{persist=true})local raw=device:get_field("__tradfri_core_battery")
if raw~=nil then return tradfri_battery(device,raw)end
end}),
},}register_device_definition(ikea_tradfri_motion_core,{
device_helpers.create_fingerprint("IKEA of Sweden","TRADFRI motion sensor"),})local halo_wx_core={
profile="safety-smoke-co-halo-wx-core",magic_packet=false,
configure=function(driver,device)
for _,endpoint in ipairs({1,3})do
device:send(device_management.build_bind_request(device,0x0500,driver.environment_info.hub_zigbee_eui,endpoint))zcl.read_attribute(device,0x0500,2,endpoint)
end
for endpoint in pairs(device.zigbee_endpoints)do
for _,cluster in ipairs({0x0402,0x0405})do
if device:supports_server_cluster(cluster,endpoint)then zcl.read_attribute(device,cluster,0,endpoint)end
end
end
end,
zcl_clusters={
passive(zcl.smoke({endpoint=1})),passive(zcl.tamper({endpoint=1})),
passive(zcl.battery_low({endpoint=1,emit=function(_,value)
return value and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end})),
passive(zcl.carbon_monoxide({endpoint=3,component="main"})),zcl.battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,from_device=battery_value}),zcl.battery_voltage({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,from_device=battery_value}),zcl.temperature({component="main",minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=false}),zcl.humidity({component="main",minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=false}),},}register_device_definition(halo_wx_core,{
device_helpers.create_fingerprint("HaloSmartLabs","haloWX"),})local nexelec_openr_core={
profile="sensors-nexelec-openr-core",magic_packet=false,
configure=function(_,device)
for endpoint in pairs(device.zigbee_endpoints)do
for _,spec in ipairs({{0x0402,0},{0x0405,0},{0x040D,0},{1,0x21}})do
if device:supports_server_cluster(spec[1],endpoint)then zcl.read_attribute(device,spec[1],spec[2],endpoint)end
end
end
end,
zcl_clusters={
zcl.temperature({component="main",minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=false}),zcl.humidity({component="main",minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=false}),zcl.cluster_attribute(0x040D,0,{name="nexelec_co2",component="main",data_type=data_types.SinglePrecisionFloat,read_only=true,read_on_configure=false,minimum_interval=10,maximum_interval=3600,reportable_change=data_types.SinglePrecisionFloat(0,-15,0x51B717/0x800000),
from_device=function(value)
if type(value)=="table"then value=value.value end
return math.floor(value*1000000+0.5)
end,emit=emit.co2(),
}),zcl.battery({component="main",minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=false,from_device=battery_value}),},}register_device_definition(nexelec_openr_core,{
device_helpers.create_fingerprint("Nexelec","Air Quality Sensor Nexelec"),})local viessmann_7963223_core={
profile="sensors-viessmann-7963223-core",magic_packet=false,zcl_clusters={
passive(zcl.temperature({endpoint=1})),passive(zcl.humidity({endpoint=1})),passive(zcl.battery({endpoint=1,from_device=battery_value})),},}register_device_definition(viessmann_7963223_core,{
device_helpers.create_fingerprint("Viessmann","7963223"),})local titan_tpzrco2ht_core={
profile="sensors-titan-tpzrco2ht-core",magic_packet=false,
configure=function(driver,device)
for _,cluster in ipairs({1,0x0402,0x040D})do
device:send(device_management.build_bind_request(device,cluster,driver.environment_info.hub_zigbee_eui,1))
end
zcl.read_attribute(device,1,0x20,1)device:send(device_management.build_bind_request(device,0x0405,driver.environment_info.hub_zigbee_eui,2))
end,
zcl_clusters={
passive(zcl.temperature({endpoint=1})),passive(zcl.humidity({endpoint=2,component="main"})),zcl.cluster_attribute(0x040D,0,{name="titan_co2",endpoint=1,data_type=data_types.SinglePrecisionFloat,
read_only=true,read_on_configure=false,from_device=function(value)
if type(value)=="table"then value=value.value end
return math.floor(value*1000000)
end,emit=emit.co2(),
}),passive(zcl.battery_voltage({component="main",from_device=battery_value})),zcl.cluster_attribute(1,0x3E,{name="titan_battery_alarm",component="main",data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=function(_,value)
if type(value)=="table"then value=value.value end
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end,
}),},}register_device_definition(titan_tpzrco2ht_core,{
device_helpers.create_fingerprint("Titan Products Ltd","TPZRCO2HT-Z3"),})local sihas_osm300z_core={
profile="safety-motion-sihas-osm300z-core",magic_packet=false,
configure=function(driver,device)
local endpoint=device:get_endpoint(1)device:send(device_management.build_bind_request(device,1,driver.environment_info.hub_zigbee_eui,endpoint))device:send(clusters.PowerConfiguration.attributes.BatteryVoltage:configure_reporting(device,3600,65000,10):to_endpoint(endpoint))zcl.read_attribute(device,1,0x20,endpoint)for ep in pairs(device.zigbee_endpoints)do
if device:supports_server_cluster(0x0406,ep)then zcl.read_attribute(device,0x0406,0,ep)end
end
end,
zcl_clusters={
zcl.occupancy({component="main",minimum_interval=0,maximum_interval=3600,reportable_change=0,read_on_configure=false,
emit=emit.motion(),from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end,
}),zcl.cluster_attribute(1,0x20,{name="sihas_osm_voltage",component="main",data_type=data_types.Uint8,
read_only=true,read_on_configure=false,emit=function(_,value)
if value==255 then return nil end
return{capabilities.battery.battery(math.floor(math.max(0,math.min(100,(value-21)*100/9))+0.5)),capabilities.voltageMeasurement.voltage({value=value/10,unit="V"})}
end,
}),
passive(zcl.battery({component="main",from_device=function(value,_,context)
local body=context.zb_rx.body.zcl_body
local voltage=type(body.get_attribute_data)=="function"and body:get_attribute_data(0x20)
if type(voltage)=="table"then voltage=voltage.value end
if type(voltage)=="number"and voltage<255 then return nil end
return battery_value(value,nil,context)
end})),
},}register_device_definition(sihas_osm300z_core,{
device_helpers.create_fingerprint("ShinaSystem","OSM-300Z"),})local sylvania_contact_temperature_core={
profile="sensors-sylvania-contact-temperature-core",magic_packet=false,zcl_clusters={
passive(zcl.contact({endpoint=1,emit=function(device,value,context)
if context.command_id==0 then return emit.contact()(device,value)end
end})),
passive(zcl.tamper({endpoint=1,emit=function(device,value,context)
if context.command_id==0 then return emit.tamper()(device,value)end
end})),
low_mapping(true),zcl.temperature({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=false}),zcl.cluster_attribute(1,0x20,{name="sylvania_contact_battery",endpoint=1,data_type=data_types.Uint8,read_only=true,read_on_configure=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,
from_device=function(value)
if value==255 then return nil end
return math.floor(math.max(0,math.min(100,(value-25)*100/3))+0.5)
end,emit=emit.battery(),
}),},}register_device_definition(sylvania_contact_temperature_core,{
device_helpers.create_fingerprint("CentraLite","Contact Sensor-A"),})local thirdreality_3rms26z_core={
profile="safety-motion-thirdreality-gen2-core",magic_packet=false,
configure=function(driver,device)
local endpoint=device:get_endpoint(1)device:send(device_management.build_bind_request(device,1,driver.environment_info.hub_zigbee_eui,endpoint))device:send(clusters.PowerConfiguration.attributes.BatteryPercentageRemaining:configure_reporting(device,3600,65000,10):to_endpoint(endpoint))zcl.read_attribute(device,1,0x21,endpoint)for ep in pairs(device.zigbee_endpoints)do
for _,spec in ipairs({{0x0500,2},{0x0400,0}})do
if device:supports_server_cluster(spec[1],ep)then zcl.read_attribute(device,spec[1],spec[2],ep)end
end
end
end,
zcl_clusters={
zcl.occupancy({component="main",ias_zone=true,emit=emit.motion(),minimum_interval=0,maximum_interval=65000,reportable_change=0,read_on_configure=false,
from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end,
}),passive(zcl.tamper({component="main"})),passive(zcl.battery({component="main",from_device=battery_value})),zcl.illuminance({component="main",minimum_interval=10,maximum_interval=3600,reportable_change=5,read_on_configure=false}),},}register_device_definition(thirdreality_3rms26z_core,{
device_helpers.create_fingerprint("Third Reality, Inc","3RMS26Z"),})local sihas_usm300z_core={
profile="sensors-sihas-usm300z-core",magic_packet=false,
configure=function(_,device)
for ep in pairs(device.zigbee_endpoints)do
if device:supports_server_cluster(0x0400,ep)then zcl.read_attribute(device,0x0400,0,ep)end
end
end,
zcl_clusters={
zcl.temperature({endpoint=1,minimum_interval=20,maximum_interval=300,reportable_change=10,read_on_configure=false}),zcl.humidity({endpoint=1,minimum_interval=20,maximum_interval=300,reportable_change=40,read_on_configure=false}),zcl.occupancy({endpoint=1,minimum_interval=1,maximum_interval=600,reportable_change=1,read_on_configure=false,
emit=emit.motion(),from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end,
}),zcl.cluster_attribute(1,0x20,{name="sihas_usm_voltage",endpoint=1,data_type=data_types.Uint8,read_only=true,read_on_configure=true,minimum_interval=30,maximum_interval=21600,reportable_change=1,
emit=function(_,value)
local percent=battery_3v2100(value)
if percent==nil then return nil end
return{capabilities.battery.battery(percent),capabilities.voltageMeasurement.voltage({value=value/10,unit="V"})}
end,
}),zcl.illuminance({component="main",minimum_interval=10,maximum_interval=3600,reportable_change=5,
read_on_configure=false,from_device=function(value)return value end}),
},}register_device_definition(sihas_usm300z_core,{
device_helpers.create_fingerprint("ShinaSystem","USM-300Z"),})local thirdreality_3raq1096z_core={
profile="sensors-thirdreality-air-core",magic_packet=false,
configure=function(_,device)
for endpoint in pairs(device.zigbee_endpoints)do
for _,cluster in ipairs({0x0402,0x0405,0x040D})do
if device:supports_server_cluster(cluster,endpoint)then zcl.read_attribute(device,cluster,0,endpoint)end
end
end
end,
zcl_clusters={
zcl.temperature({component="main",minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=false}),zcl.humidity({component="main",minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=false}),zcl.cluster_attribute(0x040D,0,{name="thirdreality_co2",component="main",data_type=data_types.SinglePrecisionFloat,read_only=true,read_on_configure=false,minimum_interval=10,maximum_interval=3600,reportable_change=data_types.SinglePrecisionFloat(0,-15,0x51B717/0x800000),
from_device=function(value)
if type(value)=="table"then value=value.value end
return math.floor(value*1000000+0.5)
end,emit=emit.co2(),
}),},}register_device_definition(thirdreality_3raq1096z_core,{
device_helpers.create_fingerprint("Third Reality, Inc","3RAQ1096Z"),})local adeo_pirth_v3_core={
profile="sensors-adeo-pirth-v3-core",magic_packet=false,
configure=function(driver,device)
local endpoint=device:get_endpoint(1)device:send(device_management.build_bind_request(device,1,driver.environment_info.hub_zigbee_eui,endpoint))device:send(clusters.PowerConfiguration.attributes.BatteryPercentageRemaining:configure_reporting(device,3600,65000,10):to_endpoint(endpoint))zcl.read_attribute(device,1,0x21,endpoint)for ep in pairs(device.zigbee_endpoints)do
for _,spec in ipairs({{0x0500,2},{0x0400,0},{0x0402,0},{0x0405,0}})do
if device:supports_server_cluster(spec[1],ep)then zcl.read_attribute(device,spec[1],spec[2],ep)end
end
end
end,
zcl_clusters={
zcl.occupancy({component="main",ias_zone=true,emit=emit.motion(),minimum_interval=0,maximum_interval=65000,reportable_change=0,read_on_configure=false,
from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end,
}),passive(zcl.tamper({component="main"})),
passive(zcl.battery_low({component="main",emit=function(_,value)
return value and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end})),
passive(zcl.battery({component="main",from_device=battery_value})),zcl.illuminance({component="main",minimum_interval=10,maximum_interval=3600,reportable_change=5,read_on_configure=false}),zcl.temperature({component="main",minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=false}),zcl.humidity({component="main",minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=false}),},}register_device_definition(adeo_pirth_v3_core,{
device_helpers.create_fingerprint("ADEO","ZB-SMART-PIRTH-V3"),})local multir_mir_ir100_core={
profile="safety-motion-multir-ir100-core",magic_packet=false,
configure=function(driver,device)
local endpoint=device:get_endpoint(1)device:send(device_management.build_bind_request(device,1,driver.environment_info.hub_zigbee_eui,endpoint))device:send(clusters.PowerConfiguration.attributes.BatteryPercentageRemaining:configure_reporting(device,3600,65000,10):to_endpoint(endpoint))zcl.read_attribute(device,1,0x21,endpoint)for ep in pairs(device.zigbee_endpoints)do
for _,spec in ipairs({{0x0500,2},{0x0400,0}})do
if device:supports_server_cluster(spec[1],ep)then zcl.read_attribute(device,spec[1],spec[2],ep)end
end
end
end,
zcl_clusters={
zcl.occupancy({component="main",ias_zone=true,emit=emit.motion(),minimum_interval=0,maximum_interval=65000,reportable_change=0,read_on_configure=false,
from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end,
}),passive(zcl.tamper({component="main"})),
passive(zcl.battery_low({component="main",emit=function(_,value)
return value and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end})),
passive(zcl.battery({component="main",from_device=battery_value})),zcl.illuminance({component="main",minimum_interval=10,maximum_interval=3600,reportable_change=5,read_on_configure=false}),},}register_device_definition(multir_mir_ir100_core,{
device_helpers.create_fingerprint("MultIR","MIR-IR100"),})local leedarson_pirth_v1_core={
profile="sensors-leedarson-pirth-v1-core",magic_packet=false,
configure=function(_,device)
for ep in pairs(device.zigbee_endpoints)do
if device:supports_server_cluster(0x0400,ep)then zcl.read_attribute(device,0x0400,0,ep)end
end
end,
zcl_clusters={
passive(zcl.occupancy({component="main",ias_zone=true,
from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end,
emit=function(device,value,context)
if context.command_id==0 then return emit.motion()(device,value)end
end,
})),
passive(zcl.tamper({component="main",emit=function(device,value,context)
if context.command_id==0 then return emit.tamper()(device,value)end
end})),
passive(zcl.battery_low({component="main",emit=function(_,value,context)
if context.command_id==0 then
return value and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end
end})),
passive(zcl.temperature({component="main"})),passive(zcl.humidity({component="main"})),passive(zcl.battery({component="main",from_device=battery_value})),passive(zcl.battery_voltage({component="main",from_device=battery_value})),zcl.cluster_attribute(1,0x3E,{name="leedarson_pirth_battery_alarm",component="main",data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=function(_,value)
if type(value)=="table"then value=value.value end
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end,
}),zcl.illuminance({component="main",minimum_interval=10,maximum_interval=3600,reportable_change=5,read_on_configure=false}),},}register_device_definition(leedarson_pirth_v1_core,{
device_helpers.create_fingerprint("Leedarson","ZB-SMART-PIRTH-V1"),})local konke_kkbsj01w_core={
profile="safety-motion-konke-kkbsj01w-core",magic_packet=false,zcl_clusters={
passive(zcl.occupancy({component="main",ias_zone=true,
from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end,
emit=function(device,value,context)
if context.command_id~=0 then return nil end
local key="__konke_motion_timer_"..context.src_endpoint
local previous=device:get_field(key)
if previous then previous:cancel()end
device:set_field(key,device.thread:call_with_delay(90,function()
device:set_field(key,nil)device:emit_event(capabilities.motionSensor.motion.inactive())
end,"Motion reset"))
return emit.motion()(device,value)
end,
})),
passive(zcl.tamper({component="main",emit=function(device,value,context)
if context.command_id==0 then return emit.tamper()(device,value)end
end})),
passive(zcl.battery_low({component="main",emit=function(_,value,context)
if context.command_id==0 then
return value and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end
end})),
passive(zcl.battery({component="main",from_device=battery_value})),passive(zcl.battery_voltage({component="main",from_device=battery_value})),zcl.cluster_attribute(1,0x3E,{name="konke_kkbs_battery_alarm",component="main",data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=function(_,value)
if type(value)=="table"then value=value.value end
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end,
}),},}register_device_definition(konke_kkbsj01w_core,{
device_helpers.create_fingerprint("Konke","3AFE07010402100D"),device_helpers.create_fingerprint("Konke","3AFE08010402100D"),})local efekta_eon213z_core={
profile="sensors-efekta-eon213z-core",magic_packet=false,zcl_clusters={
zcl.temperature({endpoint=1,minimum_interval=0,maximum_interval=21600,reportable_change=0,read_on_configure=true}),zcl.humidity({endpoint=1,minimum_interval=0,maximum_interval=21600,reportable_change=0,read_on_configure=true}),zcl.battery({endpoint=1,minimum_interval=0,maximum_interval=21600,reportable_change=0,read_on_configure=true,from_device=battery_value}),passive(zcl.battery_voltage({endpoint=1,from_device=battery_value})),},}register_device_definition(efekta_eon213z_core,{
device_helpers.create_fingerprint("efektalab.com","EFEKTA_eON213z"),})local efekta_thp_core={
profile="sensors-efekta-thp-core",magic_packet=false,zcl_clusters={
zcl.temperature({endpoint=1,minimum_interval=0,maximum_interval=21600,reportable_change=0,read_on_configure=true}),zcl.humidity({endpoint=1,minimum_interval=0,maximum_interval=21600,reportable_change=0,read_on_configure=true}),zcl.pressure({endpoint=1,minimum_interval=0,maximum_interval=21600,reportable_change=0,read_on_configure=true}),zcl.battery({endpoint=1,minimum_interval=0,maximum_interval=21600,reportable_change=0,read_on_configure=true,from_device=battery_value}),passive(zcl.battery_voltage({endpoint=1,from_device=battery_value})),},}register_device_definition(efekta_thp_core,{
device_helpers.create_fingerprint("EfektaLab","EFEKTA_THP"),})local efekta_t1_ntc10k_core={
profile="sensors-efekta-t1-ntc10k-core",magic_packet=false,
parent_refresh=function(device)zcl.read_attribute(device,1,0x21,1)end,
zcl_clusters={
zcl.temperature({endpoint=1,minimum_interval=30,maximum_interval=1800,reportable_change=10,read_on_configure=false}),zcl.battery({endpoint=1,minimum_interval=10,maximum_interval=600,reportable_change=1,read_on_configure=true,from_device=battery_value}),zcl.cluster_attribute(1,0x3E,{name="efekta_ntc10k_battery_alarm",endpoint=1,data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=function(_,value)
if type(value)=="table"then value=value.value end
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end,
}),},}register_device_definition(efekta_t1_ntc10k_core,{
device_helpers.create_fingerprint("EfektaLab","EFEKTA_T1_NTC10K"),device_helpers.create_fingerprint("EfektaLab_for_Zigbee-Shop.ru","EFEKTA_T1_NTC10K"),})local efekta_t1_pow_ntc10k_core={
profile="sensors-efekta-t1-pow-ntc10k-core",magic_packet=false,
parent_refresh=function(device)
zcl.read_attribute(device,1,0x21,1)zcl.read_attribute(device,1,0,1)
end,
zcl_clusters={
zcl.temperature({endpoint=1,minimum_interval=30,maximum_interval=1800,reportable_change=10,read_on_configure=false}),zcl.battery({endpoint=1,minimum_interval=10,maximum_interval=600,reportable_change=1,read_on_configure=true,from_device=battery_value}),zcl.cluster_attribute(1,0x3E,{name="efekta_pow_ntc10k_battery_alarm",endpoint=1,data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=function(_,value)
if type(value)=="table"then value=value.value end
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end,
}),zcl.cluster_attribute(1,0,{name="efekta_pow_ntc10k_mains_voltage",endpoint=1,data_type=data_types.Uint16,read_only=true,read_on_configure=true,scale=10,emit=emit.voltage(),}),},}register_device_definition(efekta_t1_pow_ntc10k_core,{
device_helpers.create_fingerprint("EfektaLab","EFEKTA_T1_POW_NTC10K"),device_helpers.create_fingerprint("EfektaLab_for_Zigbee-Shop.ru","EFEKTA_T1_POW_NTC10K"),})local efekta_th_duo_standard_core={
profile="sensors-efekta-th-duo-standard-core",magic_packet=false,
parent_refresh=function(device)
zcl.read_attribute(device,1,0x21,1)zcl.read_attribute(device,1,0x20,1)
end,
zcl_clusters={
zcl.temperature({endpoint=1,component="main",minimum_interval=30,maximum_interval=1800,reportable_change=10,read_on_configure=false}),zcl.humidity({endpoint=1,component="main",minimum_interval=30,maximum_interval=1800,reportable_change=10,read_on_configure=false}),zcl.temperature({endpoint=2,component="external",minimum_interval=30,maximum_interval=1800,reportable_change=10,read_on_configure=false}),zcl.humidity({endpoint=2,component="external",minimum_interval=30,maximum_interval=1800,reportable_change=10,read_on_configure=false}),zcl.battery({endpoint=1,component="main",minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true,from_device=battery_value}),zcl.battery_voltage({endpoint=1,component="main",minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true,from_device=battery_value}),zcl.cluster_attribute(1,0x3E,{name="efekta_th_duo_standard_battery_alarm",endpoint=1,component="main",data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=function(_,value)
if type(value)=="table"then value=value.value end
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end,
}),},}register_device_definition(efekta_th_duo_standard_core,{
device_helpers.create_fingerprint("EfektaLab","EFEKTA_TH_DUO"),device_helpers.create_fingerprint("EfektaLab_for_Zigbee-Shop.ru","EFEKTA_TH_DUO"),})local sonoff_snzb02_efekta_core={
profile="sensors-sonoff-snzb02-efekta-core",magic_packet=false,zcl_clusters={
zcl.temperature({endpoint=1,minimum_interval=30,maximum_interval=1800,reportable_change=10,read_on_configure=true}),zcl.humidity({endpoint=1,minimum_interval=120,maximum_interval=3600,reportable_change=25,read_on_configure=true}),zcl.battery({endpoint=1,minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true,from_device=battery_value}),passive(zcl.battery_voltage({endpoint=1,from_device=battery_value})),},}register_device_definition(sonoff_snzb02_efekta_core,{
device_helpers.create_fingerprint("EfektaLab_for_you","SNZB-02_EFEKTA"),})local heiman_hs8mis_core={
profile="sensors-heiman-hs8mis-core",magic_packet=false,
configure=function(driver,device)
device:send(device_management.build_bind_request(device,0x0400,driver.environment_info.hub_zigbee_eui,1))zcl.read_attribute(device,0x0400,0,1)
end,
zcl_clusters={
zcl.occupancy({endpoint=1,minimum_interval=0,maximum_interval=3600,reportable_change=0,read_on_configure=true,
emit=emit.motion(),from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end,
}),
passive(zcl.illuminance({endpoint=1,from_device=function(value)return value end})),
},}register_device_definition(heiman_hs8mis_core,{
device_helpers.create_fingerprint("HEIMAN","HS8MIS-EF1-3.0"),})local lifecontrol_mclh08_core={
profile="sensors-lifecontrol-mclh08-core",magic_packet=false,
parent_refresh=function(device)zcl.read_attribute(device,1,0x21,1)end,
zcl_clusters={
passive(zcl.temperature({endpoint=1,scale=1,from_device=function(value)
return(value<-1000 and(-(value+32767)*5)/3 or value)/100
end})),
zcl.cluster_attribute(0x0402,1,{name="lifecontrol_voc_humidity",endpoint=1,data_type=data_types.Int16,read_only=true,read_on_configure=false,scale=100,emit=emit.humidity(),}),passive(zcl.battery({endpoint=1,scale=1,from_device=battery_value})),},}register_device_definition(lifecontrol_mclh08_core,{
device_helpers.create_fingerprint("Nexturn","VOC_Sensor"),})local feibit_sbm01zb_core={
profile="safety-motion-feibit-sbm01zb-core",magic_packet=false,zcl_clusters={
motion_mapping(true),
passive(zcl.tamper({endpoint=1,emit=function(device,value,context)
if context.command_id==0 then return emit.tamper()(device,value)end
end})),
low_mapping(true),zcl.battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,from_device=battery_value}),passive(zcl.battery_voltage({endpoint=1,from_device=battery_value})),zcl.cluster_attribute(1,0x3E,{name="feibit_sbm01_battery_alarm",endpoint=1,data_type=data_types.Bitmap32,read_only=true,read_on_configure=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,
emit=function(_,value)
if type(value)=="table"then value=value.value end
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end,
}),},}register_device_definition(feibit_sbm01zb_core,{
device_helpers.create_fingerprint("Feibit Inc co.","FB56-BOT02HM1.2"),device_helpers.create_fingerprint("Feibit Inc co.","FNB56-BOT06FB2.3"),device_helpers.create_fingerprint("Feibit Inc co.","FNB56-BOT06FB2.8"),})local bacchus_presence26_core={
profile="sensors-bacchus-presence26-core",magic_packet=false,zcl_clusters={
zcl.occupancy({endpoint=1,minimum_interval=0,maximum_interval=3600,reportable_change=0,read_on_configure=true,
emit=emit.motion(),from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end,
}),zcl.illuminance({endpoint=1,minimum_interval=0,maximum_interval=3600,reportable_change=0,read_on_configure=true}),},}register_device_definition(bacchus_presence26_core,{
device_helpers.create_fingerprint("Bacchus","Presence_Sensor_v2.6"),})local bacchus_presence2_core={
profile="sensors-bacchus-presence2-core",magic_packet=false,
configure=function(driver,device)
device:send(device_management.build_bind_request(device,0x0406,driver.environment_info.hub_zigbee_eui,1))device:send(clusters.OccupancySensing.attributes.Occupancy:configure_reporting(device,0,3600,0):to_endpoint(1))zcl.read_attribute(device,0x0406,0,1)
end,
zcl_clusters={
passive(zcl.occupancy({endpoint=1,emit=emit.motion(),from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end})),
zcl.illuminance({endpoint=1,minimum_interval=0,maximum_interval=3600,reportable_change=0,read_on_configure=true}),},}register_device_definition(bacchus_presence2_core,{
device_helpers.create_fingerprint("Bacchus","Presence_Sensor_v2"),})local diyruz_airsense_core={
profile="sensors-diyruz-airsense-core",magic_packet=false,
configure=function(driver,device)
for _,spec in ipairs({{0x0402,data_types.Int16},{0x0405,data_types.Uint16},{0x040D,data_types.SinglePrecisionFloat}})do
device:send(device_management.build_bind_request(device,spec[1],driver.environment_info.hub_zigbee_eui,1))local change=spec[1]==0x040D and data_types.SinglePrecisionFloat(0,-127,0)or 0
device:send(cluster_base.configure_reporting(device,data_types.ClusterId(spec[1]),data_types.AttributeId(0),data_types.ZigbeeDataType(spec[2].ID),0,3600,change):to_endpoint(1))
end
end,
zcl_clusters={
passive(zcl.temperature({endpoint=1})),passive(zcl.humidity({endpoint=1})),zcl.cluster_attribute(0x040D,0,{name="diyruz_airsense_co2",endpoint=1,data_type=data_types.SinglePrecisionFloat,
read_only=true,read_on_configure=false,from_device=function(value)
if type(value)=="table"then value=value.value end
return math.floor(value*1000000)
end,emit=emit.co2(),
}),},}register_device_definition(diyruz_airsense_core,{
device_helpers.create_fingerprint("modkam.ru","DIYRuZ_AirSense"),})local efekta_eth_pow_core={
profile="sensors-efekta-eth-pow-core",magic_packet=false,
parent_refresh=function(device)zcl.read_attribute(device,1,0x21,1)end,
zcl_clusters={
passive(zcl.temperature({endpoint=1})),passive(zcl.humidity({endpoint=1})),passive(zcl.battery({endpoint=1,from_device=battery_value})),zcl.cluster_attribute(1,0,{name="efekta_eth_pow_mains_voltage",endpoint=1,data_type=data_types.Uint16,read_only=true,read_on_configure=false,scale=10,emit=emit.voltage(),}),zcl.cluster_attribute(1,0x3E,{name="efekta_eth_pow_battery_alarm",endpoint=1,data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=function(_,value)
if type(value)=="table"then value=value.value end
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end,
}),},}register_device_definition(efekta_eth_pow_core,{
device_helpers.create_fingerprint("EfektaLab","EFEKTA_eTH_POW_E_LR"),device_helpers.create_fingerprint("EfektaLab","EFEKTA_eTH_POW_R_LR"),})local wirenboard_msw4_official_core={
profile="sensors-wirenboard-msw4-official-core",magic_packet=false,
configure=function(_,device)
for _,cluster in ipairs({0x0402,0x0405,0x0400,0x040D})do
if device:supports_server_cluster(cluster,1)then zcl.read_attribute(device,cluster,0,1)end
end
end,
zcl_clusters={
passive(zcl.temperature({endpoint=1})),passive(zcl.humidity({endpoint=1})),passive(zcl.illuminance({endpoint=1})),
passive(zcl.occupancy({endpoint=1,emit=emit.motion(),from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end})),
zcl.cluster_attribute(0x040D,0,{name="wirenboard_msw4_co2",endpoint=1,data_type=data_types.SinglePrecisionFloat,
read_only=true,read_on_configure=false,from_device=function(value)
if type(value)=="table"then value=value.value end
return math.floor(value*1000000+0.5)
end,emit=emit.co2(),
}),},}register_device_definition(wirenboard_msw4_official_core,{
device_helpers.create_fingerprint("Wiren Board","WB-MSW-ZIGBEE v.4"),})
local function slacky_co2_mapping()
return zcl.cluster_attribute(0x040D,0,{name="slacky_co2",endpoint=1,data_type=data_types.SinglePrecisionFloat,read_only=true,read_on_configure=true,minimum_interval=10,maximum_interval=300,reportable_change=data_types.SinglePrecisionFloat(0,-20,0x0637BD/0x800000),
from_device=function(value)
if type(value)=="table"then value=value.value end
return math.floor(value*1000000+0.5)
end,emit=emit.co2(),
})
end
local slacky_co2_r01_core={
profile="sensors-slacky-co2-r01-core",magic_packet=false,zcl_clusters={slacky_co2_mapping()},}register_device_definition(slacky_co2_r01_core,{
device_helpers.create_fingerprint("Slacky-DIY","Tuya_CO2Sensor_r01"),})local slacky_co2_r02_core={
profile="sensors-slacky-co2-r02-core",magic_packet=false,zcl_clusters={
slacky_co2_mapping(),zcl.temperature({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=true}),zcl.humidity({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=true}),},}register_device_definition(slacky_co2_r02_core,{
device_helpers.create_fingerprint("Slacky-DIY","Tuya_CO2Sensor_r02"),})
local function w100_battery(_,value)
if type(value)=="table"then value=value.value end
if type(value)=="number"then return capabilities.battery.battery(value)end
end
local aqara_w100_core={
profile="sensors-aqara-w100-core",magic_packet=false,
parent_refresh=function(device)
zcl.read_attribute(device,0x0402,0,1)zcl.read_attribute(device,0x0405,0,1)
end,
zcl_clusters={
zcl.temperature({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=true}),zcl.humidity({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=true}),zcl.cluster_attribute(0xFCC0,102,{name="aqara_w100_battery",endpoint=1,data_type=data_types.Uint8,read_only=true,read_on_configure=false,emit=w100_battery,}),zcl.cluster_attribute(0xFCC0,0x00F7,{name="aqara_w100_diagnostics",endpoint=1,
read_only=true,read_on_configure=false,emit=function(device,value)
if type(value)=="table"and value.value~=nil then value=value.value end
if type(value)=="table"then return w100_battery(device,value[102]or value["102"])end
if type(value)~="string"then return end
local offset=1
while offset+1<=#value do
local key,kind=value:byte(offset,offset+1)local width=kind>=0x20 and kind<=0x2F and((kind%8)+1)or kind==0x10 and 1
if not width or offset+1+width>#value then return end
if key==102 then
return w100_battery(device,string.unpack("<"..(kind>=0x28 and"i"or"I")..width,value,offset+2))
end
offset=offset+2+width
end
end,
}),},}register_device_definition(aqara_w100_core,{
device_helpers.create_fingerprint("Aqara","lumi.sensor_ht.agl001"),})local frient_wiszb120_core={
profile="sensors-frient-wiszb120-core",magic_packet=false,
parent_refresh=function(device)
zcl.read_attribute(device,0x0402,0,38)zcl.read_attribute(device,1,0x21,35)zcl.read_attribute(device,1,0x20,35)
end,
zcl_clusters={
passive(zcl.contact({endpoint=35,emit=function(device,value,context)
if context.command_id==0 then return emit.contact()(device,value)end
end})),
passive(zcl.tamper({endpoint=35,emit=function(device,value,context)
if context.command_id==0 then return emit.tamper()(device,value)end
end})),
passive(zcl.battery_low({endpoint=35,emit=function(_,value,context)
if context.command_id==0 then
return value and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end
end})),
zcl.temperature({endpoint=38,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=true}),zcl.battery({endpoint=35,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,from_device=battery_value}),zcl.battery_voltage({endpoint=35,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,from_device=battery_value}),},}register_device_definition(frient_wiszb120_core,{
device_helpers.create_fingerprint("frient A/S","WISZB-120"),})
local function smartthings_multi_core_clusters(reports,battery_curve)
return{
passive(zcl.contact({endpoint=1,emit=function(device,value,context)
if reports or context.command_id==0 then return emit.contact()(device,value)end
end})),
passive(zcl.tamper({endpoint=1,emit=function(device,value,context)
if reports or context.command_id==0 then return emit.tamper()(device,value)end
end})),
low_mapping(not reports),zcl.temperature({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=false}),zcl.cluster_attribute(1,0x20,{name="smartthings_multi_voltage",endpoint=1,data_type=data_types.Uint8,read_only=true,read_on_configure=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,
emit=function(_,value)
if value==255 then return end
return{capabilities.battery.battery(battery_curve(value)),capabilities.voltageMeasurement.voltage({value=value/10,unit="V"})}
end,
}),zcl.cluster_attribute(1,0x3E,{name="smartthings_multi_battery_alarm",endpoint=1,data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=function(_,value)
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end,
}),}
end
local smartthings_3321s_core={
profile="sensors-smartthings-3321s-core",magic_packet=false,zcl_clusters=smartthings_multi_core_clusters(true,battery_3v2100),}register_device_definition(smartthings_3321s_core,{
device_helpers.create_fingerprint("CentraLite","3321-S"),})local smartthings_multiv4_core={
profile="sensors-smartthings-multiv4-core",magic_packet=false,
zcl_clusters=smartthings_multi_core_clusters(false,function(value)
return math.floor(math.max(0,math.min(100,235-370000/(value*100+1)))+0.5)
end),
}register_device_definition(smartthings_multiv4_core,{
device_helpers.create_fingerprint("SmartThings","multiv4"),})local heiman_hs8mis86_core={
profile="sensors-heiman-hs8mis86-core",magic_packet=false,
configure=function(driver,device)
device:send(device_management.build_bind_request(device,0x0400,driver.environment_info.hub_zigbee_eui,1))zcl.read_attribute(device,0x0400,0,1)
end,
zcl_clusters={
zcl.occupancy({endpoint=1,minimum_interval=0,maximum_interval=3600,reportable_change=0,read_on_configure=true,
emit=emit.motion(),from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end,
}),
passive(zcl.illuminance({endpoint=1,from_device=function(value)return value end})),
},}register_device_definition(heiman_hs8mis86_core,{
device_helpers.create_fingerprint("HEIMAN","HS8MIS-86-EF1-3.0"),})local third_reality_soil_gen2_core={
profile="sensors-thirdreality-soil-gen2-core",magic_packet=false,zcl_clusters={
zcl.temperature({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=true}),zcl.battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,from_device=battery_value}),zcl.cluster_attribute(0x0408,0,{name="third_reality_soil_gen2",endpoint=1,data_type=data_types.Uint16,read_only=true,read_on_configure=true,minimum_interval=10,maximum_interval=3600,reportable_change=100,scale=100,emit=emit.humidity()}),},}register_device_definition(third_reality_soil_gen2_core,{
device_helpers.create_fingerprint("Third Reality, Inc","3RSM0347Z"),})
local function third_reality_soil_cluster(device)
return device:supports_server_cluster(0x0408)and 0x0408 or 0x0405
end
local third_reality_soil_core={
profile="sensors-thirdreality-soil-core",magic_packet=false,
configure=function(driver,device)
local cluster=third_reality_soil_cluster(device)local endpoint=device:get_endpoint(cluster)device:send(device_management.build_bind_request(device,cluster,driver.environment_info.hub_zigbee_eui,endpoint))device:send(cluster_base.configure_reporting(device,data_types.ClusterId(cluster),data_types.AttributeId(0),data_types.ZigbeeDataType(data_types.Uint16.ID),data_types.Uint16(10),data_types.Uint16(3600),data_types.Uint16(100)):to_endpoint(endpoint))
end,
parent_refresh=function(device)
local cluster=third_reality_soil_cluster(device)zcl.read_attribute(device,cluster,0,device:get_endpoint(cluster))zcl.read_attribute(device,0x0402,0,1)zcl.read_attribute(device,1,0x21,1)
end,
zcl_clusters={
zcl.temperature({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=true}),zcl.battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,from_device=battery_value}),zcl.cluster_attribute(0x0408,0,{name="third_reality_soil",data_type=data_types.Uint16,read_only=true,read_on_configure=false,scale=100,emit=emit.humidity()}),zcl.cluster_attribute(0x0405,0,{name="third_reality_soil_legacy",data_type=data_types.Uint16,read_only=true,read_on_configure=false,scale=100,
from_device=function(value,device)
if not device:supports_server_cluster(0x0408)then return value end
end,emit=emit.humidity()}),
},}register_device_definition(third_reality_soil_core,{
device_helpers.create_fingerprint("Third Reality, Inc","3RSM0147Z"),})local efekta_aq_smart_core={
profile="sensors-efekta-aq-smart-core",magic_packet=false,
parent_refresh=function()end,
zcl_clusters={
zcl.temperature({endpoint=1,minimum_interval=30,maximum_interval=1800,reportable_change=10,read_on_configure=false}),zcl.humidity({endpoint=1,minimum_interval=30,maximum_interval=1800,reportable_change=10,read_on_configure=false}),zcl.cluster_attribute(0x040D,0,{name="aq_smart_co2",endpoint=1,data_type=data_types.SinglePrecisionFloat,read_only=true,read_on_configure=false,minimum_interval=10,maximum_interval=600,reportable_change=data_types.SinglePrecisionFloat(0,-20,0x0637BD/0x800000),
from_device=function(value)return math.floor(value*1000000+0.5)end,emit=emit.co2()}),
},}register_device_definition(efekta_aq_smart_core,{
device_helpers.create_fingerprint("EfektaLab","EFEKTA_AQ_Smart_Monitor"),})local efekta_aqs2c_core={
profile="sensors-efekta-aqs2c-core",magic_packet=false,
parent_refresh=function()end,
zcl_clusters={
passive(zcl.temperature({endpoint=3})),passive(zcl.humidity({endpoint=3})),passive(zcl.illuminance({endpoint=2})),zcl.cluster_attribute(0x040D,0,{name="aqs2c_co2",endpoint=2,data_type=data_types.SinglePrecisionFloat,read_only=true,read_on_configure=false,
from_device=function(value)return math.floor(value*1000000+0.5)end,emit=emit.co2()}),
zcl.cluster_attribute(0x042A,0,{name="aqs2c_pm25",endpoint=1,data_type=data_types.SinglePrecisionFloat,read_only=true,read_on_configure=false,
from_device=function(value)return math.floor(value+0.5)end,emit=emit.pm25()}),
},}register_device_definition(efekta_aqs2c_core,{
device_helpers.create_fingerprint("EfektaLab","EFEKTA_Air_Quality_Station_2c"),})
local function fp300_battery(device,value)
if type(value)=="table"and value.value~=nil then value=value.value end
if type(value)=="string"then
local fields,offset={},1
while offset+1<=#value do
local key,kind=value:byte(offset,offset+1)local width=kind>=0x20 and kind<=0x2F and((kind%8)+1)or kind==0x10 and 1
if not width or offset+1+width>#value then return end
fields[key]=string.unpack("<"..(kind>=0x28 and"i"or"I")..width,value,offset+2)offset=offset+2+width
end
value=fields
end
if type(value)~="table"then return end
device:set_field("fp300_battery_received",os.time(),{persist=false})local events={}for _,item in ipairs({{23,"voltage"},{24,"battery"}})do
local v=value[item[1]]or value[tostring(item[1])]
if type(v)=="table"then v=v.value end
if type(v)=="number"then
events[#events+1]=item[2]=="voltage"and capabilities.voltageMeasurement.voltage({value=v/1000,unit="V"})or capabilities.battery.battery(v)
end
end
return #events>0 and events or nil
end
local aqara_fp300_core={
profile="sensors-aqara-fp300-core",magic_packet=false,
runtime_start=function(device)
if device:get_field("fp300_battery_timer")or not device.thread then return end
device:set_field("fp300_battery_timer",device.thread:call_on_schedule(3600,function()
if os.time()-(device:get_field("fp300_battery_received")or 0)>=14400 then
zcl.read_attribute(device,0xFCC0,0xF7,1,0x115F)
end
end,"FP300 battery freshness"),{persist=false})
end,
parent_refresh=function(device)
for _,attribute in ipairs({0x142,0x14D,0xF7})do zcl.read_attribute(device,0xFCC0,attribute,1,0x115F)end
for _,cluster in ipairs({0x0402,0x0405,0x0400})do zcl.read_attribute(device,cluster,0,1)end
end,
zcl_clusters={
zcl.cluster_attribute(0xFCC0,0x142,{name="fp300_presence",endpoint=1,mfg_code=0x115F,data_type=data_types.Uint8,read_only=true,read_on_configure=true,minimum_interval=0,maximum_interval=3600,reportable_change=1,
from_device=function(value)return value==1 end,emit=emit.presence()}),
zcl.cluster_attribute(0xFCC0,0x14D,{name="fp300_pir",endpoint=1,mfg_code=0x115F,data_type=data_types.Uint8,read_only=true,read_on_configure=true,minimum_interval=0,maximum_interval=3600,reportable_change=1,
from_device=function(value)return value==1 end,emit=emit.motion()}),
zcl.temperature({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=true}),zcl.humidity({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=true}),zcl.illuminance({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=5,read_on_configure=true}),zcl.cluster_attribute(0xFCC0,0xF7,{name="fp300_battery",endpoint=1,mfg_code=0x115F,read_only=true,read_on_configure=true,emit=fp300_battery}),zcl.cluster_attribute(0xFCC0,23,{name="fp300_voltage",endpoint=1,mfg_code=0x115F,data_type=data_types.Uint16,read_only=true,read_on_configure=false,scale=1000,emit=emit.voltage()}),zcl.cluster_attribute(0xFCC0,24,{name="fp300_percentage",endpoint=1,mfg_code=0x115F,data_type=data_types.Uint8,read_only=true,read_on_configure=false,emit=emit.battery()}),zcl.cluster_attribute(0xFCC0,0xFC,{name="fp300_paired",endpoint=1,mfg_code=0x115F,data_type=data_types.Boolean,
read_only=true,read_on_configure=false,handler=function(device,value,context)
if type(value)=="table"then value=value.value end
if value==false and context.zb_rx.body.zcl_header.cmd.value==0x0A then
device:send(cluster_base.write_manufacturer_specific_attribute(device,0xFCC0,0xFC,0x115F,data_types.Boolean,true):to_endpoint(1))
end
end}),
},}register_device_definition(aqara_fp300_core,{
device_helpers.create_fingerprint("Aqara","lumi.sensor_occupy.agl8"),})local samjin_multi_core={
profile="sensors-samjin-multi-core",magic_packet=false,
configure=function(_,device)
device:send(clusters.PollControl.attributes.CheckInInterval:write(device,14400):to_endpoint(1))
end,
zcl_clusters={
passive(zcl.contact({endpoint=1,emit=function(device,value,context)
if context.command_id==0 then return emit.contact()(device,value)end
end})),
passive(zcl.tamper({endpoint=1,emit=function(device,value,context)
if context.command_id==0 then return emit.tamper()(device,value)end
end})),
low_mapping(true),zcl.temperature({endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=false}),zcl.battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,from_device=battery_value}),passive(zcl.battery_voltage({endpoint=1,from_device=battery_value})),zcl.cluster_attribute(1,0x3E,{name="samjin_multi_battery_alarm",endpoint=1,data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=function(_,value)
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end,
}),},}register_device_definition(samjin_multi_core,{
device_helpers.create_fingerprint("Samjin","multi"),})
local function bosch_bsd2_default_sensitivity(device)
if device:get_field("bosch_bsd2_default_queued")then return end
device:send(clusters.IASZone.attributes.CurrentZoneSensitivityLevel:write(device,0):to_endpoint(1))device:set_field("bosch_bsd2_default_queued",true,{persist=false})
end
local bosch_bsd2_core={
profile="sensors-bosch-bsd2-core",magic_packet=false,runtime_start=bosch_bsd2_default_sensitivity,
configure=function(_,device)bosch_bsd2_default_sensitivity(device)end,
zcl_clusters={
zcl.smoke({endpoint=1,minimum_interval=0,maximum_interval=65000,reportable_change=0,read_on_configure=true,
from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&1)~=0
end,
}),zcl.battery({endpoint=1,minimum_interval=0,maximum_interval=65000,reportable_change=1,read_on_configure=true,from_device=battery_value}),zcl.cluster_attribute(1,0x3E,{name="bosch_bsd2_battery_alarm",endpoint=1,data_type=data_types.Bitmap32,read_only=true,read_on_configure=true,minimum_interval=0,maximum_interval=65000,
emit=function(_,value)
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end,
}),},}register_device_definition(bosch_bsd2_core,{
device_helpers.create_fingerprint("BOSCH","RBSH-SD-ZB-EU"),})local airsense_reloaded_core={
profile="sensors-airsense-reloaded-core",magic_packet=false,
parent_refresh=function(device)
for _,cluster in ipairs({0x0402,0x0405,0x0403,0x040D})do zcl.read_attribute(device,cluster,0,1)end
end,
zcl_clusters={
zcl.temperature({endpoint=1,minimum_interval=20,maximum_interval=1200,reportable_change=15,read_on_configure=true}),zcl.humidity({endpoint=1,minimum_interval=20,maximum_interval=1200,reportable_change=15,read_on_configure=true}),zcl.cluster_attribute(0x0403,0,{name="airsense_reloaded_pressure",endpoint=1,data_type=data_types.Int16,read_only=true,read_on_configure=true,minimum_interval=60,maximum_interval=1800,reportable_change=1,scale=10,emit=emit.atmospheric_pressure()}),zcl.cluster_attribute(0x040D,0,{name="airsense_reloaded_co2",endpoint=1,data_type=data_types.SinglePrecisionFloat,read_only=true,read_on_configure=true,minimum_interval=20,maximum_interval=600,reportable_change=data_types.SinglePrecisionFloat(0,-20,0x0637BD/0x800000),
from_device=function(value)return math.floor(value*1000000+0.5)end,emit=emit.co2()}),
},}register_device_definition(airsense_reloaded_core,{
device_helpers.create_fingerprint("EfektaLab","DIYRuZ_AirSense_Reloaded"),})
local function efekta_pws_soil_cluster(device)
return device:supports_server_cluster(0x0408,1)and 0x0408 or 0x0405
end
local efekta_pws_core={
profile="sensors-efekta-pws-core",magic_packet=false,
configure=function(driver,device)
local cluster=efekta_pws_soil_cluster(device)device:send(device_management.build_bind_request(device,cluster,driver.environment_info.hub_zigbee_eui,1))device:send(cluster_base.configure_reporting(device,data_types.ClusterId(cluster),data_types.AttributeId(0),data_types.ZigbeeDataType(data_types.Uint16.ID),data_types.Uint16(0),data_types.Uint16(21600),data_types.Uint16(0)):to_endpoint(1))zcl.read_attribute(device,cluster,0,1)
end,
parent_refresh=function(device)
zcl.read_attribute(device,efekta_pws_soil_cluster(device),0,1)zcl.read_attribute(device,0x0402,0,1)zcl.read_attribute(device,1,0x21,1)zcl.read_attribute(device,1,0x20,1)
end,
zcl_clusters={
zcl.temperature({endpoint=1,minimum_interval=0,maximum_interval=21600,reportable_change=0,read_on_configure=true}),zcl.battery({endpoint=1,minimum_interval=0,maximum_interval=21600,reportable_change=0,read_on_configure=true,from_device=battery_value}),passive(zcl.battery_voltage({endpoint=1,from_device=battery_value})),zcl.cluster_attribute(0x0408,0,{name="efekta_pws_soil",endpoint=1,data_type=data_types.Uint16,
read_only=true,read_on_configure=false,scale=100,emit=function(device,value)
if efekta_pws_soil_cluster(device)==0x0408 then return emit.humidity()(device,value)end
end}),
zcl.cluster_attribute(0x0405,0,{name="efekta_pws_soil_zha",endpoint=1,data_type=data_types.Uint16,
read_only=true,read_on_configure=false,scale=100,emit=function(device,value)
if efekta_pws_soil_cluster(device)==0x0405 then return emit.humidity()(device,value)end
end}),
},}register_device_definition(efekta_pws_core,{
device_helpers.create_fingerprint("efektalab.ru","EFEKTA_PWS"),})
local function gwa1513_endpoint(cluster)
return function(device)return device:get_endpoint(cluster)end
end
local develco_gwa1513_core={
profile="sensors-develco-gwa1513-core",magic_packet=false,
parent_refresh=function(device)
zcl.read_attribute(device,0x0402,0,device:get_endpoint(0x0402))zcl.read_attribute(device,1,0x21,device:get_endpoint(1))zcl.read_attribute(device,1,0x20,device:get_endpoint(1))
end,
zcl_clusters={
passive(zcl.contact({endpoint=gwa1513_endpoint(0x0500),component="main",emit=function(device,value,context)
if context.command_id==0 then return emit.contact()(device,value)end
end})),
passive(zcl.tamper({endpoint=gwa1513_endpoint(0x0500),component="main",emit=function(device,value,context)
if context.command_id==0 then return emit.tamper()(device,value)end
end})),
passive(zcl.battery_low({endpoint=gwa1513_endpoint(0x0500),component="main",emit=function(_,value,context)
if context.command_id==0 then return value and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()end
end})),
zcl.temperature({endpoint=gwa1513_endpoint(0x0402),component="main",minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=true}),passive(zcl.battery({endpoint=gwa1513_endpoint(1),component="main",from_device=battery_value})),zcl.cluster_attribute(1,0x20,{name="gwa1513_voltage",endpoint=gwa1513_endpoint(1),component="main",data_type=data_types.Uint8,read_only=true,read_on_configure=true,minimum_interval=3600,maximum_interval=65000,reportable_change=10,
emit=function(device,value)
if value==255 then return nil end
return{emit.battery()(device,math.max(0,math.min(100,(value*100-2500)/5))),emit.voltage()(device,value/10)}
end}),
},}register_device_definition(develco_gwa1513_core,{
device_helpers.create_fingerprint("Develco Products A/S","GWA1513_WindowSensor"),})local frient_wiszb138_core={
profile="sensors-frient-wiszb138-core",magic_packet=false,
parent_refresh=function(device)
zcl.read_attribute(device,0x0402,0,38)zcl.read_attribute(device,1,0x21,35)zcl.read_attribute(device,1,0x20,35)
end,
zcl_clusters={
passive(zcl.contact({endpoint=35,emit=function(device,value,context)
if context.command_id==0 then return emit.contact()(device,value)end
end})),
passive(zcl.tamper({endpoint=35,emit=function(device,value,context)
if context.command_id==0 then return emit.tamper()(device,value)end
end})),
passive(zcl.battery_low({endpoint=35,emit=function(_,value,context)
if context.command_id==0 then return value and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()end
end})),
zcl.temperature({endpoint=38,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=true}),passive(zcl.battery({endpoint=35,from_device=battery_value})),zcl.cluster_attribute(1,0x20,{name="wiszb138_voltage",endpoint=35,data_type=data_types.Uint8,read_only=true,read_on_configure=true,minimum_interval=3600,maximum_interval=65000,reportable_change=10,
emit=function(device,value)
if value==255 then return nil end
return{emit.battery()(device,math.max(0,math.min(100,(value*100-2500)/5))),emit.voltage()(device,value/10)}
end}),
},}register_device_definition(frient_wiszb138_core,{
device_helpers.create_fingerprint("frient A/S","WISZB-138"),})local multir_mir_ir100e_core={
profile="sensors-multir-ir100e-core",magic_packet=false,
parent_refresh=function(device)
zcl.read_attribute(device,1,0x21,1)zcl.read_attribute(device,1,0x20,1)
end,
zcl_clusters={
passive(zcl.motion({endpoint=1})),passive(zcl.tamper({endpoint=1})),low_mapping(false),zcl.battery({endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,from_device=battery_value}),passive(zcl.battery_voltage({endpoint=1,from_device=battery_value})),},}register_device_definition(multir_mir_ir100e_core,{
device_helpers.create_fingerprint("MultIR","MIR-IR100-E"),device_helpers.create_fingerprint("MultiIR","MIR-IR100-E"),})local efekta_pws_max_core={
profile="sensors-efekta-pws-max-core",magic_packet=false,
parent_refresh=function(device)
for _,cluster in ipairs({0x0402,0x0405,0x0400,0x0408})do zcl.read_attribute(device,cluster,0,1)end
zcl.read_attribute(device,1,0x21,1)zcl.read_attribute(device,1,0x20,1)
end,
zcl_clusters={
zcl.temperature({endpoint=1,component="main",minimum_interval=0,maximum_interval=21600,reportable_change=0,read_on_configure=true}),zcl.humidity({endpoint=1,component="main",minimum_interval=0,maximum_interval=21600,reportable_change=0,read_on_configure=true}),zcl.illuminance({endpoint=1,component="main",minimum_interval=0,maximum_interval=21600,reportable_change=0,read_on_configure=true}),zcl.cluster_attribute(0x0408,0,{name="pws_max_soil",endpoint=1,component="soil",data_type=data_types.Uint16,read_only=true,read_on_configure=true,minimum_interval=0,maximum_interval=21600,reportable_change=0,
from_device=function(value)return value/100 end,emit=emit.humidity()}),
zcl.battery({endpoint=1,component="main",minimum_interval=0,maximum_interval=21600,reportable_change=0,read_on_configure=true,from_device=battery_value}),passive(zcl.battery_voltage({endpoint=1,component="main",from_device=battery_value})),},}register_device_definition(efekta_pws_max_core,{
device_helpers.create_fingerprint("EFEKTA_FOR_BELOUSOV.A","EFEKTA_PWS_Max"),})local develco_wiszb137_core={
profile="sensors-develco-wiszb137-core",magic_packet=false,
parent_refresh=function(device)
zcl.read_attribute(device,0x0402,0,38)zcl.read_attribute(device,1,0x21,45)zcl.read_attribute(device,1,0x20,45)
end,
zcl_clusters={
passive(zcl.motion({endpoint=45})),passive(zcl.motion({name="wiszb137_vibration",endpoint=45,
from_device=function(value)
if type(value)=="table"then value=value.value end
return(value&2)~=0
end,emit=emit.acceleration()})),
passive(zcl.tamper({endpoint=45})),
passive(zcl.battery_low({endpoint=45,emit=function(_,value)
return value and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end})),
zcl.temperature({endpoint=38,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=true}),passive(zcl.battery({endpoint=45,from_device=battery_value})),zcl.cluster_attribute(1,0x20,{name="wiszb137_voltage",endpoint=45,data_type=data_types.Uint8,read_only=true,read_on_configure=true,minimum_interval=3600,maximum_interval=65000,reportable_change=10,
emit=function(device,value)
if value==255 then return nil end
return{emit.battery()(device,battery_3v2100(value)),emit.voltage()(device,value/10)}
end}),
},}register_device_definition(develco_wiszb137_core,{
device_helpers.create_fingerprint("frient A/S","WISZB-137"),device_helpers.create_fingerprint("Develco Products A/S","WISZB-137"),})local tuya_ts020c_core={
profile="sensors-tuya-ts020c-core",magic_packet=true,query_on_configure=true,query_on_announce=true,announce_delay=0,time_start="off",
parent_refresh=function()end,
{dp=1,datatype=4,name="occupancy",field="occupancy",read_only=true,
from_device=function(value)return value==0 end,emit=emit.motion()},
{dp=4,datatype=2,name="battery",field="battery",read_only=true,emit=emit.battery()},{dp=12,datatype=2,name="illuminance",field="illuminance",read_only=true,emit=emit.illuminance()},zcl_clusters={
passive(zcl.motion({endpoint=1,emit=function(device,value,context)
if context.command_id==0 then return emit.motion()(device,value)end
end})),
passive(zcl.tamper({endpoint=1,emit=function(device,value,context)
if context.command_id==0 then return emit.tamper()(device,value)end
end})),
passive(zcl.battery_low({endpoint=1,emit=function(_,value,context)
if context.command_id==0 then
return value and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end
end})),
passive(zcl.battery({endpoint=1,from_device=battery_value})),passive(zcl.battery_voltage({endpoint=1,from_device=battery_value})),zcl.cluster_attribute(1,0x3E,{name="ts020c_battery_alarm",endpoint=1,data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=function(_,value)
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end}),
zcl.cluster_attribute(0xE002,0xE001,{name="ts020c_lux",endpoint=1,read_only=true,read_on_configure=false,
emit=function(device,value,context)
if context.zb_rx.body.zcl_header.cmd.value==0x0A then return emit.illuminance()(device,value)end
end}),
},}register_device_definition(tuya_ts020c_core,{
device_helpers.create_fingerprint("_TZ3040_wc6kfjtc","TS020C"),})local efekta_pixel_air2_core={
profile="sensors-efekta-pixel-air2-core",magic_packet=false,
parent_refresh=function()end,
zcl_clusters={
zcl.temperature({endpoint=2,component="main",minimum_interval=30,maximum_interval=1800,reportable_change=10,read_on_configure=false}),zcl.humidity({endpoint=2,component="main",minimum_interval=30,maximum_interval=1800,reportable_change=10,read_on_configure=false}),zcl.cluster_attribute(0x040D,0,{name="pixel_air2_co2",endpoint=1,component="main",data_type=data_types.SinglePrecisionFloat,read_only=true,read_on_configure=false,minimum_interval=10,maximum_interval=600,reportable_change=data_types.SinglePrecisionFloat(0,-20,0x0637BD/0x800000),
from_device=function(value)return math.floor(value*1000000+0.5)end,emit=emit.co2()}),
},}register_device_definition(efekta_pixel_air2_core,{
device_helpers.create_fingerprint("EfektaLab for you","EFEKTA_Pixel_Open_Air_II"),})local efekta_iaqs2_core={
profile="sensors-efekta-iaqs2-core",magic_packet=false,
parent_refresh=function()end,
zcl_clusters={
zcl.temperature({endpoint=1,component="main",minimum_interval=30,maximum_interval=1800,reportable_change=10,read_on_configure=false}),zcl.humidity({endpoint=1,component="main",minimum_interval=30,maximum_interval=1800,reportable_change=10,read_on_configure=false}),zcl.temperature({endpoint=2,component="external",minimum_interval=30,maximum_interval=1800,reportable_change=10,read_on_configure=false}),zcl.humidity({endpoint=2,component="external",minimum_interval=30,maximum_interval=1800,reportable_change=10,read_on_configure=false}),zcl.illuminance({endpoint=2,component="external",minimum_interval=0,maximum_interval=300,reportable_change=0,read_on_configure=false}),zcl.cluster_attribute(0x0403,0,{name="iaqs2_pressure",endpoint=2,component="external",data_type=data_types.Int16,read_only=true,read_on_configure=false,minimum_interval=30,maximum_interval=1800,reportable_change=1,
from_device=function(value)return value/10 end,emit=emit.atmospheric_pressure()}),
zcl.cluster_attribute(0x040D,0,{name="iaqs2_co2",endpoint=1,component="main",data_type=data_types.SinglePrecisionFloat,read_only=true,read_on_configure=false,minimum_interval=10,maximum_interval=600,reportable_change=data_types.SinglePrecisionFloat(0,-20,0x0637BD/0x800000),
from_device=function(value)return math.floor(value*1000000+0.5)end,emit=emit.co2()}),
},}register_device_definition(efekta_iaqs2_core,{
device_helpers.create_fingerprint("EfektaLab","EFEKTA_iAQ_S_II"),})local efekta_iaq3_core={
profile="sensors-efekta-iaq3-core",magic_packet=false,
parent_refresh=function()end,
zcl_clusters={
zcl.temperature({endpoint=1,component="main",minimum_interval=30,maximum_interval=1800,reportable_change=10,read_on_configure=false}),zcl.humidity({endpoint=1,component="main",minimum_interval=30,maximum_interval=1800,reportable_change=10,read_on_configure=false}),zcl.temperature({endpoint=2,component="external",minimum_interval=30,maximum_interval=1800,reportable_change=10,read_on_configure=false}),zcl.humidity({endpoint=2,component="external",minimum_interval=30,maximum_interval=1800,reportable_change=10,read_on_configure=false}),zcl.illuminance({endpoint=2,component="external",minimum_interval=0,maximum_interval=300,reportable_change=0,read_on_configure=false}),zcl.cluster_attribute(0x040D,0,{name="iaq3_co2",endpoint=1,component="main",data_type=data_types.SinglePrecisionFloat,read_only=true,read_on_configure=false,minimum_interval=10,maximum_interval=600,reportable_change=data_types.SinglePrecisionFloat(0,-20,0x0637BD/0x800000),
from_device=function(value)return math.floor(value*1000000+0.5)end,emit=emit.co2()}),
},}register_device_definition(efekta_iaq3_core,{
device_helpers.create_fingerprint("EfektaLab","EFEKTA_iAQ3"),})local efekta_eflora_core={
profile="sensors-efekta-eflora-core",magic_packet=false,
parent_refresh=function(device)
zcl.read_attribute(device,1,0x21,1)zcl.read_attribute(device,1,0x20,1)
end,
zcl_clusters={
zcl.temperature({endpoint=1,component="main",minimum_interval=120,maximum_interval=3600,reportable_change=25,read_on_configure=false}),zcl.humidity({endpoint=1,component="main",minimum_interval=300,maximum_interval=3600,reportable_change=50,read_on_configure=false}),zcl.illuminance({endpoint=1,component="main",minimum_interval=120,maximum_interval=3600,reportable_change=25,read_on_configure=false}),zcl.cluster_attribute(0x0408,0,{name="eflora_base_soil",endpoint=1,component="soil",data_type=data_types.Uint16,minimum_interval=600,maximum_interval=7200,reportable_change=100,read_only=true,read_on_configure=false,scale=100,emit=emit.humidity()}),zcl.battery({endpoint=1,component="main",minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true,from_device=battery_value}),zcl.battery_voltage({endpoint=1,component="main",minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true,from_device=battery_value}),zcl.cluster_attribute(1,0x3E,{name="eflora_base_battery_alarm",endpoint=1,component="main",data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=function(_,value)
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end}),
},}register_device_definition(efekta_eflora_core,{
device_helpers.create_fingerprint("EfektaLab","EFEKTA_eFlora"),})local efekta_zflora_pro_core={
profile="sensors-efekta-zflora-pro-core",magic_packet=false,
parent_refresh=function(device)
zcl.read_attribute(device,1,0x21,1)zcl.read_attribute(device,1,0x20,1)
end,
zcl_clusters={
zcl.temperature({endpoint=1,component="main",minimum_interval=120,maximum_interval=3600,reportable_change=25,read_on_configure=false}),zcl.humidity({endpoint=1,component="main",minimum_interval=300,maximum_interval=3600,reportable_change=50,read_on_configure=false}),zcl.illuminance({endpoint=1,component="main",minimum_interval=120,maximum_interval=3600,reportable_change=25,read_on_configure=false}),zcl.cluster_attribute(0x0408,0,{name="zflora_pro_soil",endpoint=1,component="soil",data_type=data_types.Uint16,minimum_interval=600,maximum_interval=7200,reportable_change=100,read_only=true,read_on_configure=false,scale=100,emit=emit.humidity()}),zcl.battery({endpoint=1,component="main",minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true,from_device=battery_value}),zcl.battery_voltage({endpoint=1,component="main",minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true,from_device=battery_value}),zcl.cluster_attribute(1,0x3E,{name="zflora_pro_battery_alarm",endpoint=1,component="main",data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=function(_,value)
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end}),
},}register_device_definition(efekta_zflora_pro_core,{
device_helpers.create_fingerprint("EfektaLab","zFlora_Pro"),device_helpers.create_fingerprint("EfektaLab","zFlora_S_Max"),device_helpers.create_fingerprint("EfektaLab_for_Zigbee-Shop.ru","zFlora_S_Max"),})local efekta_zflora_s_core={
profile="sensors-efekta-zflora-s-core",magic_packet=false,
parent_refresh=function(device)
zcl.read_attribute(device,1,0x21,1)zcl.read_attribute(device,1,0x20,1)
end,
zcl_clusters={
zcl.temperature({endpoint=1,component="main",minimum_interval=120,maximum_interval=3600,reportable_change=25,read_on_configure=false}),zcl.humidity({endpoint=1,component="main",minimum_interval=300,maximum_interval=3600,reportable_change=50,read_on_configure=false}),zcl.cluster_attribute(0x0408,0,{name="zflora_s_soil",endpoint=1,component="soil",data_type=data_types.Uint16,minimum_interval=600,maximum_interval=7200,reportable_change=100,read_only=true,read_on_configure=false,scale=100,emit=emit.humidity()}),zcl.battery({endpoint=1,component="main",minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true,from_device=battery_value}),zcl.battery_voltage({endpoint=1,component="main",minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true,from_device=battery_value}),zcl.cluster_attribute(1,0x3E,{name="zflora_s_battery_alarm",endpoint=1,component="main",data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=function(_,value)
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end}),
},}register_device_definition(efekta_zflora_s_core,{
device_helpers.create_fingerprint("EfektaLab","zFlora_S"),})local efekta_zflora_promax_core={
profile="sensors-efekta-zflora-promax-core",magic_packet=false,
parent_refresh=function(device)
zcl.read_attribute(device,1,0x21,1)zcl.read_attribute(device,1,0x20,1)
end,
zcl_clusters={
zcl.temperature({endpoint=1,component="main",minimum_interval=120,maximum_interval=3600,reportable_change=25,read_on_configure=false}),zcl.humidity({endpoint=1,component="main",minimum_interval=300,maximum_interval=3600,reportable_change=50,read_on_configure=false}),zcl.illuminance({endpoint=1,component="main",minimum_interval=120,maximum_interval=3600,reportable_change=25,read_on_configure=false}),zcl.cluster_attribute(0x0408,0,{name="zflora_promax_soil",endpoint=1,component="soil",data_type=data_types.Uint16,minimum_interval=600,maximum_interval=7200,reportable_change=100,read_only=true,read_on_configure=false,scale=100,emit=emit.humidity()}),zcl.battery({endpoint=1,component="main",minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true,from_device=battery_value}),zcl.battery_voltage({endpoint=1,component="main",minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true,from_device=battery_value}),zcl.cluster_attribute(1,0x3E,{name="zflora_promax_battery_alarm",endpoint=1,component="main",data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=function(_,value)
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end}),
},}register_device_definition(efekta_zflora_promax_core,{
device_helpers.create_fingerprint("EfektaLab","zFlora_ProMax"),})local efekta_eflora_pro_core={
profile="sensors-efekta-eflora-pro-core",magic_packet=false,
parent_refresh=function(device)
zcl.read_attribute(device,1,0x21,1)zcl.read_attribute(device,1,0x20,1)
end,
zcl_clusters={
zcl.temperature({endpoint=2,component="main",minimum_interval=120,maximum_interval=3600,reportable_change=25,read_on_configure=false}),zcl.humidity({endpoint=2,component="main",minimum_interval=300,maximum_interval=3600,reportable_change=50,read_on_configure=false}),zcl.illuminance({endpoint=2,component="main",minimum_interval=120,maximum_interval=3600,reportable_change=25,read_on_configure=false}),zcl.cluster_attribute(0x0408,0,{name="eflora_pro_soil",endpoint=3,component="soil",data_type=data_types.Uint16,minimum_interval=600,maximum_interval=7200,reportable_change=100,read_only=true,read_on_configure=false,scale=100,emit=emit.humidity()}),zcl.battery({endpoint=1,component="main",minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true,from_device=battery_value}),zcl.battery_voltage({endpoint=1,component="main",minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true,from_device=battery_value}),zcl.cluster_attribute(1,0x3E,{name="eflora_pro_battery_alarm",endpoint=1,component="main",data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=function(_,value)
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end}),
},}register_device_definition(efekta_eflora_pro_core,{
device_helpers.create_fingerprint("EfektaLab","EFEKTA_eFlora_Pro"),})local efekta_eflora_max_core={
profile="sensors-efekta-eflora-max-core",magic_packet=false,
parent_refresh=function(device)
zcl.read_attribute(device,1,0x21,1)zcl.read_attribute(device,1,0x20,1)
end,
zcl_clusters={
zcl.temperature({endpoint=2,component="main",minimum_interval=120,maximum_interval=3600,reportable_change=25,read_on_configure=false}),zcl.humidity({endpoint=2,component="main",minimum_interval=300,maximum_interval=3600,reportable_change=50,read_on_configure=false}),zcl.illuminance({endpoint=2,component="main",minimum_interval=120,maximum_interval=3600,reportable_change=25,read_on_configure=false}),zcl.cluster_attribute(0x0408,0,{name="eflora_soil",endpoint=3,component="soil",data_type=data_types.Uint16,minimum_interval=600,maximum_interval=7200,reportable_change=100,read_only=true,read_on_configure=false,scale=100,emit=emit.humidity()}),zcl.battery({endpoint=1,component="main",minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true,from_device=battery_value}),zcl.battery_voltage({endpoint=1,component="main",minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true,from_device=battery_value}),zcl.cluster_attribute(1,0x3E,{name="eflora_battery_alarm",endpoint=1,component="main",data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=function(_,value)
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end}),
},}register_device_definition(efekta_eflora_max_core,{
device_helpers.create_fingerprint("EfektaLab","EFEKTA_eFlora_Max_Pro"),})local efekta_zflora_x_max_core={
profile="sensors-efekta-zflora-x-max-core",magic_packet=false,
parent_refresh=function(device)
zcl.read_attribute(device,1,0x21,1)zcl.read_attribute(device,1,0x20,1)
end,
zcl_clusters={
passive(zcl.temperature({endpoint=1})),passive(zcl.illuminance({endpoint=1})),zcl.cluster_attribute(0x0408,0,{name="zflora_x_max_soil",endpoint=1,data_type=data_types.Uint16,read_only=true,read_on_configure=false,scale=100,emit=emit.humidity()}),zcl.cluster_attribute(1,0x21,{name="zflora_x_max_battery",endpoint=1,data_type=data_types.Uint8,read_only=true,read_on_configure=true,scale=2,from_device=battery_value,emit=emit.battery()}),},}register_device_definition(efekta_zflora_x_max_core,{
device_helpers.create_fingerprint("EfektaLab","zFlora_X_Max"),})local efekta_eair_core={
profile="sensors-efekta-eair-core",magic_packet=false,
parent_refresh=function(device)
zcl.read_attribute(device,1,0x21,1)zcl.read_attribute(device,1,0x20,1)
end,
zcl_clusters={
zcl.cluster_attribute(0x040D,0,{name="eair_co2",endpoint=1,data_type=data_types.SinglePrecisionFloat,read_only=true,read_on_configure=false,
from_device=function(value)return math.floor(value*1000000+0.5)end,emit=emit.co2()}),
zcl.cluster_attribute(1,0x21,{name="eair_battery",endpoint=1,data_type=data_types.Uint8,read_only=true,read_on_configure=true,scale=2,from_device=battery_value,emit=emit.battery()}),zcl.cluster_attribute(1,0x3E,{name="eair_battery_alarm",endpoint=1,data_type=data_types.Bitmap32,
read_only=true,read_on_configure=false,emit=function(_,value)
return(value&0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical()or capabilities.batteryLevel.battery.normal()
end}),
},}register_device_definition(efekta_eair_core,{
device_helpers.create_fingerprint("EfektaLab","EFEKTA_eAir_Monitor"),})local aircube_common_core={
profile="sensors-aircube-common-core",magic_packet=false,
parent_refresh=function(device)
zcl.read_attribute(device,0x0402,0,10)zcl.read_attribute(device,0x0405,0,10)zcl.read_attribute(device,0xFC01,0,10)zcl.read_attribute(device,0xFC01,1,10)zcl.read_attribute(device,0xFC01,2,10)
end,
zcl_clusters={
zcl.temperature({endpoint=10,minimum_interval=10,maximum_interval=60,reportable_change=50,read_on_configure=true}),zcl.humidity({endpoint=10,minimum_interval=10,maximum_interval=60,reportable_change=100,read_on_configure=true}),zcl.cluster_attribute(0xFC01,0,{name="aircube_equivalent_co2",endpoint=10,data_type=data_types.Uint16,read_only=true,read_on_configure=true,minimum_interval=10,maximum_interval=60,reportable_change=50,emit=emit.airCubeEquivalentCo2()}),zcl.cluster_attribute(0xFC01,1,{name="voc",endpoint=10,data_type=data_types.Uint16,read_only=true,read_on_configure=true,minimum_interval=10,maximum_interval=60,reportable_change=10,emit=emit.voc("ppb")}),zcl.cluster_attribute(0xFC01,2,{name="aircube_voc_level",endpoint=10,data_type=data_types.Uint16,read_only=true,read_on_configure=true,minimum_interval=10,maximum_interval=60,reportable_change=5,emit=emit.airCubeVocLevel()}),},}register_device_definition(aircube_common_core,{
device_helpers.create_fingerprint("StuckAtPrototype","AirCube"),})local nodieby_nd01_motion_core={
profile="safety-motion-nodieby-nd01-core",magic_packet=false,
parent_refresh=function(device)
zcl.read_attribute(device,0x0500,2,1)
end,
configure=function(_,device)
zcl.read_attribute(device,0x0500,2,1)
end,
zcl_clusters={
passive(zcl.occupancy({endpoint=1,ias_zone=true,read_only=true,emit=emit.motion(),
from_device=function(value)
if type(value)=="table"then value=value.value end
if type(value)~="number"then return nil end
return(value&1)~=0
end})),
},}register_device_definition(nodieby_nd01_motion_core,{
device_helpers.create_fingerprint("NoDieby","ND-01"),})return{
id="zcl.sensors.simple_sensors",registrations=device_definitions,}
