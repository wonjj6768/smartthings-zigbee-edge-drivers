local zcl=require"protocol.zcl"
local device_helpers=require"contracts.helpers.family"
local emit=require"capabilities.events.all"
local types=require"st.zigbee.data_types"
local device_management=require"st.zigbee.device_management"
local device_definitions,register_device_definition=device_helpers.definition_registry()
local function build_temp_humidity_clusters(options)
options=options or{}local humidity_scale=options.humidity_scale
local profile=options.profile
local clusters={
zcl.temperature(),humidity_scale~=nil and humidity_scale~=100 and
zcl.humidity({scale=humidity_scale})or
zcl.humidity(),zcl.battery(),}if options.battery_voltage then
clusters[#clusters+1]=zcl.battery_voltage()
end
if options.illuminance then
clusters[#clusters+1]=zcl.illuminance()
end
if options.tuya_magic then
table.insert(clusters,1,zcl.tuya_magic_packet())
end
return{
profile=profile,zcl_clusters=clusters,}
end
local function build_illuminance_battery_clusters(options)
options=options or{}local clusters={
zcl.illuminance(),zcl.battery(),}if options.tuya_magic then
table.insert(clusters,1,zcl.tuya_magic_packet())
end
return{
profile=options.profile,zcl_clusters=clusters,}
end
local temp_humidity_battery_profile="sensors-temp-humidity-battery"
local temp_humidity_battery_voltage_profile="sensors-temp-humidity-battery-voltage"
local illuminance_temp_humidity_battery_profile="sensors-illuminance-temp-humidity-battery"
local illuminance_battery_profile="sensors-illuminance-battery"
local function lcd_attribute(name,attribute,datatype,emitter,values)
local encoded={}
for raw,value in pairs(values or{})do encoded[value]=raw end
return zcl.cluster_attribute(0xE002,attribute,{
name=name,endpoint=1,data_type=datatype,write_type=datatype,read_on_configure=false,emit=emitter,
from_device=function(value)
if type(value)=="table"then value=value.value end
if values then return values[value]end
return value
end,
to_device=values and function(value)return encoded[value]end or nil,
})
end
local kctw1z=build_temp_humidity_clusters({
profile="sensors-temp-humidity-battery-voltage-kctw1z-pending",humidity_scale=10,battery_voltage=true,})kctw1z.magic_packet=false
kctw1z.query_on_configure=false
kctw1z.force_time_updates=true
for _,mapping in ipairs(kctw1z.zcl_clusters)do
mapping.minimum_interval,mapping.maximum_interval,mapping.reportable_change=nil,nil,nil
mapping.read_on_configure=mapping.cluster_id==0x0001
if mapping.attribute_id==0x0021 and mapping.cluster_id==0x0001 then
mapping.minimum_interval,mapping.maximum_interval,mapping.reportable_change=3600,65000,0
end
end
kctw1z.configure=function(driver,device)
for _,cluster in ipairs({0x0001,0x0402,0x0405})do
device:send(device_management.build_bind_request(device,cluster,driver.environment_info.hub_zigbee_eui,1))
end
end
kctw1z.zcl_clusters[#kctw1z.zcl_clusters+1]=lcd_attribute(
"kctw_display_unit",0xE00B,types.Enum8,emit.kctwDisplayUnit(),{[0]="celsius","fahrenheit"})local lcz030=build_temp_humidity_clusters({
profile="sensors-illuminance-temp-humidity-battery-lcz030-pending",illuminance=true,tuya_magic=true,})for _,spec in ipairs({
{"lcz_temp_max",0xD00A,emit.lczTempMax("C")},{"lcz_temp_min",0xD00B,emit.lczTempMin("C")},{"lcz_humidity_max",0xD00D,emit.lczHumidityMax("%")},{"lcz_humidity_min",0xD00E,emit.lczHumidityMin("%")},})do
lcz030.zcl_clusters[#lcz030.zcl_clusters+1]=lcd_attribute(spec[1],spec[2],types.Int16,spec[3])
end
for _,spec in ipairs({
{"lcz_temp_alarm",0xD006,emit.lczTempAlarm(),{[0]="below_min_temperature","over_temperature","off"}},{"lcz_humidity_alarm",0xD00F,emit.lczHumidityAlarm(),{[0]="below_min_humdity","over_humidity","off"}},})do
local mapping=lcd_attribute(spec[1],spec[2],types.Enum8,spec[3],spec[4])mapping.read_only=true
lcz030.zcl_clusters[#lcz030.zcl_clusters+1]=mapping
end
lcz030.configure=function(driver,device)
for _,cluster in ipairs({0x0000,0x0001,0x0402,0x0405,0xE002})do
device:send(device_management.build_bind_request(device,cluster,driver.environment_info.hub_zigbee_eui,1))
end
end
register_device_definition(build_temp_humidity_clusters({
profile=temp_humidity_battery_voltage_profile,battery_voltage=true,}),{
device_helpers.create_fingerprint("LINCUKOO","SZT06"),})register_device_definition(build_temp_humidity_clusters({
profile=temp_humidity_battery_voltage_profile,battery_voltage=true,tuya_magic=true,}),device_helpers.create_fingerprints("TS0201",{
"_TZ3210_alxkwn0h","_TZ3000_0s1izerx","_TZ3000_v1w2k9dd","_TZ3000_rdhukkmi","Zbeacon","_TZ3000_lqmvrwa2","_TZ3000_f2bw0b6k","_TZ3000_mxzo5rhf","_TZ3000_1twfmkcc","_TZ3000_fie1dpkm","_TZ3000_bgsigers","_TYZB01_ujfk3xd9","_TZ3000_82ptnsd4","_TZ3000_amqudjr0","_TZ3000_lbtpiody","_TZ3000_rusu2vzb","_TZ3000_zfirri2d","_TZ3000_yujem9ee",}))register_device_definition(build_temp_humidity_clusters({
profile=temp_humidity_battery_voltage_profile,battery_voltage=true,}),{
device_helpers.create_fingerprint("eWeLink","SNZB-02"),})register_device_definition(build_temp_humidity_clusters({
profile="sensors-temp-humidity-battery-legacy-pending",}),{
device_helpers.create_fingerprint("Zbeacon","TS0202"),device_helpers.create_fingerprint("Zbeacon","TS0203"),})register_device_definition(build_temp_humidity_clusters({
profile=temp_humidity_battery_profile,}),device_helpers.create_fingerprints("SNZB-02",{
"_TZ3000_utwgoauk",}))register_device_definition(build_temp_humidity_clusters({
profile=temp_humidity_battery_voltage_profile,battery_voltage=true,tuya_magic=true,}),device_helpers.create_fingerprints("TY0201",{
"_TZ3000_bjawzodf","_TZ3000_zl1kmjqx",}))register_device_definition(build_temp_humidity_clusters({
profile=temp_humidity_battery_voltage_profile,battery_voltage=true,tuya_magic=true,}),device_helpers.create_fingerprints("TS0201",{
"_TZ3000_bguser20","_TZ3000_yd2e749y","_TZ3000_6uzkisv2","_TZ3000_xr3htd96","_TZ3000_fllyghyj","_TZ3000_saiqcn0y","_TZ3000_bjawzodf",}))register_device_definition(build_temp_humidity_clusters({
profile=temp_humidity_battery_voltage_profile,battery_voltage=true,tuya_magic=true,}),device_helpers.create_fingerprints("TS0201",{
"_TZ3000_dowj6gyi","_TZ3000_8ybe88nf","_TZ3000_akqdg6g7","_TZ3000_zl1kmjqx",}))register_device_definition(build_temp_humidity_clusters({
profile=temp_humidity_battery_voltage_profile,battery_voltage=true,}),device_helpers.create_fingerprints("SM0201",{
"_TYZB01_cbiezpds","_TYZB01_zqvwka4k",}))register_device_definition(build_temp_humidity_clusters({
profile=temp_humidity_battery_profile,}),device_helpers.create_fingerprints("SM0201",{
"_TYZB01_lzrhtcxu",}))register_device_definition(build_temp_humidity_clusters({
profile=temp_humidity_battery_voltage_profile,battery_voltage=true,}),device_helpers.create_fingerprints("TS0601",{
"_TZ3000_kkerjand",}))register_device_definition(build_temp_humidity_clusters({
profile=temp_humidity_battery_voltage_profile,humidity_scale=10,battery_voltage=true,tuya_magic=true,}),device_helpers.create_fingerprints("TS0201",{
"_TZ3210_ncw88jfq","_TZ3000_ywagc4rj","_TZ3000_isw9u95y","_TZ3000_yupc0pb7",}))register_device_definition(kctw1z,device_helpers.create_fingerprints("TS0201",{
"_TZ3000_itnrsufe",}))register_device_definition(lcz030,device_helpers.create_fingerprints("TS0201",{
"_TZ3000_qaaysllp",}))register_device_definition(build_temp_humidity_clusters({
profile=illuminance_temp_humidity_battery_profile,humidity_scale=10,illuminance=true,tuya_magic=true,}),device_helpers.create_fingerprints("TS0222",{
"_TZ3000_kky16aay","_TZE204_myd45weu","_TZ3000_ceplrhnu",}))register_device_definition(build_temp_humidity_clusters({
profile=illuminance_temp_humidity_battery_profile,illuminance=true,tuya_magic=true,}),device_helpers.create_fingerprints("TS0222",{
"_TZ3000_t9qqxn70",}))register_device_definition(build_temp_humidity_clusters({
profile=illuminance_temp_humidity_battery_profile,illuminance=true,}),device_helpers.create_fingerprints("TS0222",{
"_TYZB01_ftdkanlj","_TYZB01_kvwjujy9",}))register_device_definition(build_temp_humidity_clusters({
profile=illuminance_temp_humidity_battery_profile,illuminance=true,tuya_magic=true,}),device_helpers.create_fingerprints("TS0222",{
"_TZ3000_ubuikmgo",}))register_device_definition(build_temp_humidity_clusters({
profile=illuminance_temp_humidity_battery_profile,illuminance=true,}),{
device_helpers.create_fingerprint("easyiot","ZB-LTH01"),})register_device_definition(build_temp_humidity_clusters({
profile="sensors-illuminance-temp-humidity-battery-konke-pending",illuminance=true,battery_voltage=true,}),device_helpers.create_fingerprints("TS0222",{
"_TYZB01_fi5yftwv",}))register_device_definition(build_illuminance_battery_clusters({
profile=illuminance_battery_profile,tuya_magic=true,}),device_helpers.create_fingerprints("TS0222",{
"_TZ3000_8uxxzz4b","_TZ3000_9kbbfeho","_TZ3000_l6rsaipj","_TYZB01_4mdqxxnn","_TYZB01_m6ec2pgj","_TZ3000_do6txrcw","_TZ3000_7kscdesh","_TZ3000_hy6ncvmw","_TZ3000_7y90pany","_TZ3000_j6adk9id",}))return{
id="zcl.sensors.general",registrations=device_definitions,}
