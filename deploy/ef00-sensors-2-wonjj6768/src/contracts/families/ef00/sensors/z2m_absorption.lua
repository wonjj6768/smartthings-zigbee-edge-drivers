local tuya=require"protocol.tuya"
local emit=require"capabilities.events.all"
local device_helpers=require"contracts.helpers.family"
local ef00_helpers=require"contracts.helpers.ef00"
local converter=tuya.converter
local device_definitions,register_device_definition=device_helpers.definition_registry()
local function register_sensor_definition(definition,fingerprint_list)
local entry={}for key,value in pairs(definition)do
entry[key]=value
end
if entry.query_on_configure==nil then
entry.query_on_configure=true
end
register_device_definition(entry,fingerprint_list)
end
local alarm_lower_upper_cancel=converter.lookup_from_to({
lower_alarm=0,upper_alarm=1,cancel=2,})local th_alarm_onenuo_th05z={
profile="sensors-temp-humidity-battery-alarm-onenuo-th05z",datapoints={
tuya.dp_temperature(1,{
emit=emit.temperature("C"),read_only=true,signed=true,converter=converter.signed_number_pair(10),}),tuya.dp_humidity(2,{emit=emit.humidity(),scale=1,read_only=true}),tuya.dp_battery(4,{emit=emit.battery(),read_only=true}),tuya.dp_enum(9,{
name="temperature_unit",emit=emit.th05zTemperatureUnit(),converter=converter.lookup_from_to({celsius=0,fahrenheit=1}),}),tuya.dp_numeric(10,{
name="max_temperature_alarm",emit=emit.th05zMaxTempAlarm(),signed=true,converter=converter.signed_number_pair(10),}),tuya.dp_numeric(11,{
name="min_temperature_alarm",emit=emit.th05zMinTempAlarm(),signed=true,converter=converter.signed_number_pair(10),}),tuya.dp_numeric(12,{name="max_humidity_alarm",emit=emit.th05zMaxHumidityAlarm()}),tuya.dp_numeric(13,{name="min_humidity_alarm",emit=emit.th05zMinHumidityAlarm()}),tuya.dp_enum(14,{
name="temperature_alarm",emit=emit.th05zTemperatureAlarm(),read_only=true,converter=alarm_lower_upper_cancel,}),tuya.dp_enum(15,{
name="humidity_alarm",emit=emit.th05zHumidityAlarm(),read_only=true,converter=alarm_lower_upper_cancel,}),tuya.dp_numeric(17,{
name="temperature_report_interval",emit=emit.th05zTempReportPeriod(),}),tuya.dp_numeric(19,{
name="temperature_sensitivity",emit=emit.th05zTempSensitivity(),converter=converter.divide_by_pair(10),}),tuya.dp_numeric(20,{
name="humidity_sensitivity",emit=emit.th05zHumiditySensitivity(),}),tuya.dp_temperature_calibration(23,{emit=emit.th05zTempCalibration()}),tuya.dp_humidity_calibration(24,{emit=emit.th05zHumidityCalibration()}),},query_on_configure=true,query_on_announce=false,respond_to_mcu_version_response=true,time_start="1970",}register_device_definition(th_alarm_onenuo_th05z,ef00_helpers.ts0601_fingerprints({
"_TZE2841000000_qf5mzewi",}))local aq_co2_temperature_humidity_pkpfn9hc={
profile="sensors-aq-co2-temp-humidity",query_on_configure=true,query_on_announce=true,tuya.dp_co2(2,{emit=emit.co2(),read_only=true}),tuya.dp_temperature(18,{
name="temperature",scale=10,read_only=true,emit=emit.temperature("C"),}),tuya.dp_humidity(19,{emit=emit.humidity(),scale=1,read_only=true}),}register_sensor_definition(aq_co2_temperature_humidity_pkpfn9hc,ef00_helpers.ts0601_fingerprints({
"_TZE204_pkpfn9hc",}))local onenuo_qf5mzewi_core={
profile="sensors-onenuo-th05-core",query_on_configure=true,query_on_announce=true,time_start="1970",datapoints={
tuya.dp_temperature(1,{read_only=true,emit=emit.temperature("C")}),tuya.dp_humidity(2,{read_only=true,scale=1,emit=emit.humidity()}),tuya.dp_battery(4,{read_only=true,emit=emit.battery()}),},}register_device_definition(onenuo_qf5mzewi_core,ef00_helpers.ts0601_fingerprints({"_TZE284_qf5mzewi"}))local lincukoo_szt04_long_core={
profile="sensors-lincukoo-szt04-long-core",query_on_configure=false,time_start="1970",force_time_updates=true,datapoints={
tuya.dp_temperature(1,{read_only=true,scale=10,emit=emit.temperature("C")}),tuya.dp_humidity(2,{read_only=true,scale=1,emit=emit.humidity()}),tuya.dp_battery(4,{read_only=true,emit=emit.battery()}),},}register_device_definition(lincukoo_szt04_long_core,ef00_helpers.ts0601_fingerprints({
"_TZE2841000000_rs62zxk8","_TZE2841000000_4dosadbh","_TZE2841000000_mpzuabwk",}))local hobeian_zg227_core={
profile="sensors-hobeian-zg227-core",query_on_configure=false,query_on_announce=false,time_start="off",datapoints={
tuya.dp_temperature(1,{read_only=true,signed=true,converter=converter.signed_number_pair(10),emit=emit.temperature("C")}),tuya.dp_humidity(2,{read_only=true,scale=1,emit=emit.humidity()}),tuya.dp_battery(4,{read_only=true,emit=emit.battery()}),},}register_device_definition(hobeian_zg227_core,{
device_helpers.create_fingerprint("HOBEIAN","ZG-227Z"),device_helpers.create_fingerprint("HOBEIAN","ZG-227ZL"),})local blitzwolf_bw_is3_core={
profile="safety-motion-blitzwolf-bwis3-core",magic_packet=false,query_on_configure=false,datapoints={
tuya.dp_enum(3,{
name="motion",read_only=true,receive_datatypes={0,1,2,3,5},
from_device=function(_,device,dp,context)
local frame=context.frame
if frame.command_id~=2 or frame.datapoints[1]~=dp then return nil end
return true
end,
emit=function(device,value)
local previous=device:get_field("__bwis3_core_timer")
if previous then previous:cancel()end
device:set_field("__bwis3_core_timer",device.thread:call_with_delay(90,function()
device:set_field("__bwis3_core_timer",nil)device:emit_event(emit.motion()(device,false))
end,"Motion reset"))
return emit.motion()(device,value)
end,
}),},}register_device_definition(blitzwolf_bw_is3_core,{
device_helpers.create_fingerprint("_TYST11_i5j6ifxj","5j6ifxj"),device_helpers.create_fingerprint("_TYST11_i5j6ifxj","5j6ifxj\0"),})local dak2k10o_air_core={
profile="sensors-dak2k10o-air-core",magic_packet=true,query_on_configure=false,datapoints={
tuya.dp_co2(2,{emit=emit.co2(),read_only=true}),tuya.dp_temperature(18,{emit=emit.temperature("C"),scale=10,read_only=true}),tuya.dp_humidity(19,{emit=emit.humidity(),scale=10,read_only=true}),tuya.dp_voc(21,{emit=emit.voc("ppb"),read_only=true}),tuya.dp_formaldehyde(22,{emit=emit.formaldehyde("mg/m^3"),scale=1000,read_only=true}),},}register_device_definition(dak2k10o_air_core,{
device_helpers.create_fingerprint("_TZE204_dak2k10o","TS0601"),})local capabilities=require"st.capabilities"
local zy_n1_noise_states={
"noise","no_noise","noise_2min","noise_5min","no_noise_2min","no_noise_5min","no_noise_10min","noise_normal","noise_normal_2min","noise_normal_5min",}local zy_n1={
profile="sensors-tuya-zyn1",magic_packet=true,mcu_version_request_on_configure=true,query_on_configure=true,query_on_announce=false,time_start="off",datapoints={
tuya.dp_numeric(1,{name="zy_n1_noise_level",read_only=true,emit=emit.zyN1NoiseLevel()}),tuya.dp_enum(8,{
name="zy_n1_noise_status",read_only=true,emit=emit.zyN1NoiseStatus(),converter=converter.lookup_from_to({no_noise=0,noise_normal=1,noise=2}),}),tuya.dp_enum(13,{
name="zy_n1_report_mode",emit=emit.zyN1ReportMode(),converter=converter.lookup_from_to({collect_noise_floor=0,realtime=1,threshold=2}),}),tuya.dp_numeric(16,{name="zy_n1_noise_lower_limit",emit=emit.zyN1NoiseLowerLimit()}),tuya.dp_numeric(18,{name="zy_n1_collect_time",emit=emit.zyN1CollectTime()}),tuya.dp_numeric(20,{name="zy_n1_noise_upper_limit",emit=emit.zyN1NoiseUpperLimit()}),tuya.dp_numeric(22,{name="zy_n1_noise_hold_time",emit=emit.zyN1NoiseHoldTime()}),tuya.dp_binary(23,{
name="zy_n1_indicator",emit=emit.zyN1Indicator(),converter=converter.lookup_from_to({ON=true,OFF=false}),}),tuya.dp_enum(101,{
name="zy_n1_noise_state",read_only=true,
emit=function(device,value)
return{
capabilities.soundSensor.sound((value==0 or value==2 or value==3)and"detected"or"not detected"),emit.zyN1NoiseState()(device,zy_n1_noise_states[value+1]),}
end,
}),tuya.dp_enum(102,{
name="zy_n1_report_threshold",emit=emit.zyN1ReportThreshold(),converter=converter.lookup_from_to({["1_db"]=0,["3_db"]=1,["5_db"]=2,["10_db"]=3,["20_db"]=4,no_report=5}),}),tuya.dp_numeric(103,{name="zy_n1_noise_delay",emit=emit.zyN1NoiseDelay()}),},}register_device_definition(zy_n1,{
device_helpers.create_fingerprint("_TZE204_r6kfl9ta","TS0601"),})return{
id="ef00.sensors.z2m_absorption",registrations=device_definitions,}
