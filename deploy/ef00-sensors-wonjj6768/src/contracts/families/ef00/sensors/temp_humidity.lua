local b,c,m,f=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family",require"contracts.helpers.ef00"local a=b.converter
local Z,d=m.definition_registry()local s="pool_limit_scale"
local function C(e,H)
local T=e and e.get_field and e:get_field(s)if type(T)=="table"then
return T[H]end
return nil
end
local function R(e,H,aC)
if C(e,H)==aC or not(e and e.set_field)then
return
end
local T,ay={},e:get_field(s)if type(ay)=="table"then
for k,v in pairs(ay)do
T[k]=v
end
end
T[H]=aC
e:set_field(s,T,{persist=true})if e.log then
e.log.info(string.format("Pool meter %s limits use 1/%d units",H,aC))end
end
local function x(e,H)
return C(e,H)or(H=="cl"and C(e,"ph"))or 10
end
local function r(H,aA)
return a.from_to(function(z,e)
local q=tonumber(z)if q==nil then
return nil
end
if q>0x7FFFFFFF then
return 0
end
if q>aA*10 then
R(e,H,100)end
local az=q/x(e,H)if az>aA then
return nil
end
return az
end,function(z,e)
local q=tonumber(z)if q==nil then
return nil
end
return math.tointeger(math.floor(q*x(e,H)+0.5))
end)
end
local function S()
local aI=a.signed_number_pair(1)
return a.from_to(function(z,e,an,am)
local mv=aI.from(z,e,an,am)if mv==nil then
return nil
end
if mv<0 then
return 0
end
if mv>1200 then
return nil
end
return math.tointeger(math.floor(mv+0.5))
end,aI.to)
end
local function ab()
return a.from_only(function(z)
local q=tonumber(z)if q==nil then
return nil
end
if q>99 then
return q/100
end
return q/10
end)
end
local o,B="pool_chlorine_keepalive_timer",30*60
local l
l=function(e)
local aG=e.thread:call_with_delay(B,function()
b.send_datapoint(e,105,b.DP_TYPE_VALUE,0,b.SET_DATA,false,1)
local ah=e.thread:call_with_delay(2,function()
b.send_datapoint(e,105,b.DP_TYPE_VALUE,0,b.SET_DATA,false,0)l(e)
end,"pool chlorine backlight keepalive follow-up")
e:set_field(o,ah,{persist=false})
end,"pool chlorine backlight keepalive")
e:set_field(o,aG,{persist=false})
end
local function E(e)
if e.thread==nil or type(e.thread.call_with_delay)~="function"or
type(e.get_field)~="function"or type(e.set_field)~="function"then
return false
end
local p=e:get_field(o)if p~=nil and type(p.cancel)=="function"then
p:cancel()end
l(e)return true
end
local F,N="th_force_time_update_timer",60*60
local function j(e,aL)
if e.thread==nil or type(e.thread.call_with_delay)~="function"or
type(e.get_field)~="function"or type(e.set_field)~="function"then
return false
end
local p=e:get_field(F)if p~=nil and type(p.cancel)=="function"then
p:cancel()end
local I
I=function()
local aG=e.thread:call_with_delay(N,function()
aL:send_time(e)I()
end,"temperature sensor hourly time update")
e:set_field(F,aG,{persist=false})
end
I()return true
end
local function h(w,L)
if type(w)=="table"then
local ao={}for aS,z in pairs(w)do
ao[aS]=z
end
if ao.query_on_configure==nil then
ao.query_on_configure=true
end
d(ao,L)return
end
d({datapoints=w,query_on_configure=true},L)
end
local al={profile="sensors-temp-humidity-battery",b.dp_numeric(1,{name="temperature",emit=c.temperature"C",converter=a.tuya_unsigned_temp(10)}),b.dp_humidity(2,{emit=c.humidity(),scale=10}),b.dp_battery(4,{emit=c.battery()})}d(al,f.ts0601_fingerprints{"_TZE200_bjawzodf","_TZE200_zl1kmjqx"})local at={profile="sensors-temp-humidity-battery-unit-9ern5sfh",datapoints={b.dp_temperature(1,{emit=c.temperature"C",scale=10,read_only=true}),b.dp_humidity(2,{emit=c.humidity(),scale=10,read_only=true}),b.dp_battery(4,{emit=c.battery(),read_only=true}),b.dp_enum(9,{name="temperature_unit",emit=c.ern9TemperatureUnit(),converter=a.lookup_from_to{celsius=0,fahrenheit=1}}),b.dp_numeric(19,{name="temperature_sensitivity",read_only=true})},force_time_updates=true,time_start="off"}h(at,f.ts0601_fingerprints{"_TZE284_9ern5sfh"})local ax={profile="sensors-temp-humidity-battery",b.dp_numeric(1,{name="temperature",emit=c.temperature"C",converter=a.tuya_unsigned_temp(10)}),b.dp_humidity(2,{emit=c.humidity(),scale=1}),b.dp_battery(4,{emit=c.battery()})}d(ax,f.ts0601_fingerprints{"_TZE200_bq5c8xfe","_TZE200_44af8vyi"})local av={profile="sensors-temp-humidity-battery-state-qyfl",datapoints={b.dp_numeric(1,{name="temperature",emit=c.temperature"C",converter=a.tuya_unsigned_temp(10)}),b.dp_humidity(2,{emit=c.humidity(),scale=1}),b.dp_enum(3,{name="battery_state",emit=c.qyflBatteryState(),read_only=true,converter=a.from_only(a.lookup_value{[0]="low",[1]="middle",[2]="high"})}),b.dp_battery(4,{emit=c.battery()})}}h(av,f.ts0601_fingerprints{"_TZE200_qyflbnbj","_TZE204_qyflbnbj","_TZE284_qyflbnbj"})local u={b.dp_temperature(1,{emit=c.temperature"C",read_only=true,signed=true,converter=a.signed_number_pair(10)}),b.dp_humidity(2,{emit=c.humidity(),scale=1,read_only=true}),b.dp_battery(4,{emit=c.battery(),read_only=true}),b.dp_numeric(9,{name="temperature_unit",converter=a.lookup_from_to{celsius=0,fahrenheit=1}}),b.dp_temperature_calibration(23,{emit=c.temperatureCalibrationZg227z()}),b.dp_humidity_calibration(24,{emit=c.humidityCalibrationZg227z()})}local aF={profile="sensors-temp-humidity-battery-calibration-zg227z",datapoints=u,query_on_configure=false}d(aF,f.ts0601_fingerprints{"_TZE200_qoy0ekbd","_TZE200_znbl8dj5","_TZE200_a8sdabtg","_TZE200_dikkika5","_TZE200_vs0skpuc","_TZE200_3xfjp0ag","_TZE200_ehhrv2e3","_TZE200_lhqtjwax","_TZE200_y8wkaq6w"})local aE={profile="sensors-th-three-unit",datapoints={b.dp_temperature(1,{emit=c.temperature"C",read_only=true,signed=true,converter=a.signed_number_pair(10)}),b.dp_humidity(2,{emit=c.humidity(),scale=1,read_only=true}),b.dp_battery(4,{emit=c.battery(),read_only=true}),b.dp_enum(9,{name="th_three_display_unit",emit=c.thThreeDisplayUnit(),converter=a.lookup_from_to{celsius=0,fahrenheit=1}})},query_on_configure=true,time_start="1970",force_time_updates=true}d(aE,f.ts0601_fingerprints{"_TZE200_s1xgth2u","_TZE200_t3xd7l44","_TZE284_kdqrazmy"})local aD={profile="sensors-temp-humidity-battery-sensitivity-nous-e6",datapoints={b.dp_temperature(1,{emit=c.temperature"C",read_only=true,signed=true,converter=a.signed_number_pair(10)}),b.dp_humidity(2,{emit=c.humidity(),scale=1,read_only=true}),b.dp_battery(4,{emit=c.battery(),read_only=true}),b.dp_enum(9,{name="temperature_unit",converter=a.lookup_from_to{celsius=0,fahrenheit=1}}),b.dp_numeric(10,{name="max_temperature_alarm",signed=true,converter=a.signed_number_pair(10)}),b.dp_numeric(11,{name="min_temperature_alarm",signed=true,converter=a.signed_number_pair(10)}),b.dp_numeric(12,{name="max_humidity_alarm"}),b.dp_numeric(13,{name="min_humidity_alarm"}),b.dp_numeric(17,{name="temperature_report_interval"}),b.dp_numeric(19,{name="temperature_sensitivity",converter=a.divide_by_pair(10),emit=c.nousE6TemperatureSensitivity()}),b.dp_numeric(20,{name="humidity_sensitivity",emit=c.nousE6HumiditySensitivity()})},query_on_configure=false,bind_basic_on_configure=true,time_start="1970",runtime_start=j}d(aD,f.ts0601_fingerprints{"_TZE284_wtikaxzs","_TZE200_nnrfa68v","_TZE200_zppcgbdj","_TZE200_wtikaxzs"})local ag={profile="sensors-temp-humidity-battery",datapoints={b.dp_temperature(1,{emit=c.temperature"C",read_only=true,signed=true,converter=a.signed_number_pair(10)}),b.dp_humidity(2,{emit=c.humidity(),scale=1,read_only=true}),b.dp_battery(4,{emit=c.battery(),read_only=true}),b.dp_numeric(9,{name="temperature_unit",converter=a.lookup_from_to{celsius=0,fahrenheit=1}})},query_on_configure=false,mcu_version_request_on_configure=true}d(ag,f.ts0601_fingerprints{"_TZE204_s139roas"})local aw={profile="sensors-temp-humidity-battery-calibration-zg227z",datapoints=u,query_on_configure=true,query_on_announce=true,respond_to_mcu_version_response=true}d(aw,f.ts0601_fingerprints{"_TZE200_ysm4dsb1"})local aO={b.dp_temperature(1,{emit=c.temperature"C",read_only=true,signed=true,converter=a.signed_number_pair(10)}),b.dp_humidity(2,{emit=c.humidity(),scale=1,read_only=true}),b.dp_enum(3,{name="battery_state",emit=c.zsn03pBatteryState(),read_only=true,converter=a.lookup_from_to{low=0,medium=1,high=2}}),b.dp_temperature_unit(9,{emit=c.zsn03pTemperatureUnit(),converter=a.lookup_from_to{celsius=0,fahrenheit=1}}),b.dp_temperature_calibration(23,{emit=c.temperatureCalibrationZg227z()}),b.dp_humidity_calibration(24,{emit=c.zsn03pHumidityCalibration()})}h({profile="sensors-temp-humidity-battery-state-calibration-zsn03p",datapoints=aO,query_on_configure=false},f.ts0601_fingerprints{"_TZE284_rjjsib2d"})local X={profile="sensors-temp-battery-pool-chlorine",datapoints={b.dp_numeric(1,{name="tds",emit=c.tdsChlorineMeter(),read_only=true}),b.dp_temperature(2,{emit=c.temperature"C",scale=10,read_only=true}),b.dp_battery(7,{emit=c.battery(),read_only=true}),b.dp_numeric(10,{name="ph",emit=c.poolPhChlorineMeter(),converter=ab(),read_only=true}),b.dp_numeric(11,{name="ec",emit=c.ylPoolConductivity(),read_only=true}),b.dp_numeric(101,{name="orp",emit=c.poolOrpChlorineMeter(),read_only=true}),b.dp_numeric(102,{name="free_chlorine",converter=a.divide_by_pair(10),emit=c.freeChlorineChlorineMeter(),read_only=true}),b.dp_numeric(105,{name="backlightvalue",emit=c.ylPoolBacklight()}),b.dp_numeric(106,{name="ph_max",converter=r("ph",14),emit=c.poolPhMaxLimit"pH"}),b.dp_numeric(107,{name="ph_min",converter=r("ph",14),emit=c.poolPhMinLimit"pH"}),b.dp_numeric(108,{name="ec_max",emit=c.ylPoolEcMax"µS/cm"}),b.dp_numeric(109,{name="ec_min",emit=c.ylPoolEcMin"µS/cm"}),b.dp_numeric(110,{name="orp_max",signed=true,converter=S(),emit=c.ylPoolOrpMax"mV"}),b.dp_numeric(111,{name="orp_min",signed=true,converter=S(),emit=c.ylPoolOrpMin"mV"}),b.dp_numeric(112,{name="free_chlorine_max",converter=r("cl",4),emit=c.poolChlorineMaxLimit"mg/L"}),b.dp_numeric(113,{name="free_chlorine_min",converter=r("cl",4),emit=c.poolChlorineMinLimit"mg/L"}),b.dp_numeric(117,{name="salinity",emit=c.salinityChlorineMeter(),read_only=true})},query_on_configure=false,query_interval_seconds=10*60,query_on_announce=true,respond_to_mcu_version_response=true,runtime_start=E}d(X,f.ts0601_fingerprints{"_TZE200_d9mzkhoq","_TZE200_v1jqz5cy"})local af={profile="sensors-temp-battery-heat-water-meter",datapoints={b.dp_water_consumed(1,{read_only=true,emit=c.waterConsumedHeatMeter()}),b.dp_month_consumption(2,{name="monthly_water_consumption",raw=true,raw_bytes=4,raw_from_tail=true,read_only=true}),b.dp_daily_consumption(3,{name="daily_water_consumption",raw=true,raw_bytes=4,raw_from_tail=true,read_only=true}),b.dp_enum(4,{name="report_period",converter=a.report_period_hours()}),b.dp_numeric(5,{name="fault",read_only=true,converter=a.bitmap_flags({[1]="battery_alarm",[2]="magnetism_alarm",[4]="cover_alarm",[8]="credit_alarm",[16]="switch_gaps_alarm",[32]="meter_body_alarm",[64]="abnormal_water_alarm",[128]="arrearage_alarm",[256]="overflow_alarm",[512]="revflow_alarm",[1024]="over_pre_alarm",[2048]="empty_pip_alarm",[4096]="transduce_alarm"},"OK",", ")}),b.dp_binary(6,{name="prepayment_switch"}),b.dp_cumulative_heat(7,{name="cumulative_heat",read_only=true}),b.dp_meter_id(16,{read_only=true}),b.dp_instantaneous_flow_rate(19,{raw=true,raw_bytes=4,raw_from_tail=false,read_only=true}),b.dp_inlet_water_temperature(21,{name="temperature",read_only=true,emit=c.temperature"C"}),b.dp_outlet_water_temperature(22,{name="outlet_water_temperature",read_only=true}),b.dp_numeric(24,{name="battery_voltage",read_only=true,converter=a.from_only(a.multiply_by(10))})},query_on_configure=false}d(af,f.ts0601_fingerprints{"_TZE200_jt50ea5d"})local P={profile="sensors-water-meter-ultrasonic-ajlu4cud",datapoints={b.dp_water_consumed(1,{read_only=true,emit=c.ajlu4cudWaterConsumed()}),b.dp_month_consumption(2,{raw=true,raw_bytes=4,raw_from_tail=true,read_only=true,emit=c.ajlu4cudMonthConsumption()}),b.dp_daily_consumption(3,{raw=true,raw_bytes=4,raw_from_tail=true,read_only=true,emit=c.ajlu4cudDailyConsumption()}),b.dp_numeric(4,{name="report_period",converter=a.report_period_hours(),emit=c.ajlu4cudReportPeriod()}),b.dp_water_meter_faults(5,{read_only=true,emit=c.ajlu4cudFaults()}),b.dp_meter_id(16,{read_only=true,emit=c.ajlu4cudMeterId()}),b.dp_reverse_water_consumed(18,{raw=true,raw_bytes=4,raw_from_tail=false,read_only=true,emit=c.ajlu4cudReverseWaterConsumed()}),b.dp_flow_rate(21,{raw=true,raw_bytes=4,raw_from_tail=true,read_only=true,emit=c.ajlu4cudFlowRate()}),b.dp_temperature(22,{scale=100,read_only=true,emit=c.temperature"C"}),b.dp_battery_voltage(26,{name="battery_voltage",read_only=true})},query_on_configure=false}d(P,f.ts0601_fingerprints{"_TZE284_ajlu4cud"})
local function i(y)
local g={b.dp_temperature(1,{emit=c.temperature"C",read_only=true,signed=true,converter=a.signed_number_pair(10)}),b.dp_humidity(2,{emit=c.humidity(),scale=1,read_only=true})}if y.battery_state then
g[#g+1]=b.dp_enum(3,{name="battery_state",emit=c.cwyqwqbfBatteryState(),read_only=true,converter=a.from_only(a.lookup_value{[0]="low",[1]="medium",[2]="high"})})else
g[#g+1]=b.dp_battery(4,{emit=c.battery(),read_only=true})end
g[#g+1]=b.dp_enum(9,{name="temperature_unit",converter=a.lookup_from_to{celsius=0,fahrenheit=1}})g[#g+1]=b.dp_numeric(10,{name="max_temperature_alarm",signed=true,converter=a.signed_number_pair(10)})g[#g+1]=b.dp_numeric(11,{name="min_temperature_alarm",signed=true,converter=a.signed_number_pair(10)})g[#g+1]=b.dp_numeric(12,{name="max_humidity_alarm"})g[#g+1]=b.dp_numeric(13,{name="min_humidity_alarm"})g[#g+1]=b.dp_enum(14,{name="temperature_alarm",read_only=true,converter=y.alarm_converter})g[#g+1]=b.dp_enum(15,{name="humidity_alarm",read_only=true,converter=y.alarm_converter})if y.temperature_report_interval then
g[#g+1]=b.dp_numeric(17,{name="temperature_report_interval"})end
if y.humidity_report_interval then
g[#g+1]=b.dp_numeric(18,{name="humidity_report_interval"})end
if y.temperature_sensitivity_emit then
g[#g+1]=b.dp_numeric(19,{name="temperature_sensitivity",converter=a.divide_by_pair(10),emit=y.temperature_sensitivity_emit})end
if y.humidity_sensitivity_emit then
g[#g+1]=b.dp_numeric(20,{name="humidity_sensitivity",emit=y.humidity_sensitivity_emit})end
return g
end
local n,K=a.lookup_from_to{lower_alarm=0,upper_alarm=1,cancel=2},a.lookup_from_to{canceled=0,lower_alarm=1,upper_alarm=2}local ak={profile="sensors-temp-humidity-battery-alarm-sensitivity-th-alarm",datapoints=i{alarm_converter=n,temperature_report_interval=true,humidity_report_interval=true,temperature_sensitivity_emit=c.tempSensitivityThCToOne(),humidity_sensitivity_emit=c.humiditySensitivityThThreeTen()},query_on_configure=true,respond_to_mcu_version_response=true,time_start="1970"}d(ak,f.ts0601_fingerprints{"_TZE200_vvmbj46n","_TZE284_vvmbj46n","_TZE200_w6n8jeuu"})local ac={profile="sensors-temp-humidity-battery-state-alarm-sensitivity-cwyqwqbf",datapoints=i{battery_state=true,alarm_converter=n,temperature_report_interval=true,humidity_report_interval=true,temperature_sensitivity_emit=c.tempSensitivityThCToOne(),humidity_sensitivity_emit=c.humiditySensitivityThThreeTen()},query_on_configure=true,respond_to_mcu_version_response=true,time_start="1970"}d(ac,f.ts0601_fingerprints{"_TZE284_cwyqwqbf"})local Y={profile="sensors-temp-humidity-battery-alarm-sensitivity-nous-szt04",datapoints=i{alarm_converter=n,temperature_report_interval=true,humidity_report_interval=true,temperature_sensitivity_emit=c.nousSzT04TemperatureSensitivity(),humidity_sensitivity_emit=c.nousSzT04HumiditySensitivity()},query_on_configure=false,bind_basic_on_configure=true,time_start="1970",runtime_start=j}d(Y,f.ts0601_fingerprints{"_TZE200_lve3dvpy","_TZE200_c7emyjom","_TZE200_locansqn","_TZE200_qrztc3ev","_TZE200_snloy4rw","_TZE200_eanjj2pa","_TZE200_ydrdfkim","_TZE284_locansqn"})local M={profile="sensors-temp-humidity-battery-alarm-sensitivity-lincukoo-szt04",datapoints=i{alarm_converter=K,temperature_sensitivity_emit=c.lincukooSzt04TempSensitivity(),humidity_sensitivity_emit=c.lincukooSzt04HumiditySensitivity()},query_on_configure=false,time_start="1970",runtime_start=j}d(M,f.ts0601_fingerprints{"_TZE284_rs62zxk8","_TZE284_4dosadbh","_TZE284_mpzuabwk"})local aj={profile="sensors-temp-humidity-battery-jm-trh",datapoints=i{alarm_converter=n,temperature_report_interval=true},query_on_configure=false,bind_basic_on_configure=true,time_start="1970",runtime_start=j}d(aj,f.ts0601_fingerprints{"_TZE200_whkgqxse"})local aK={profile="sensors-temp-humidity-battery-state-unit-th2aaa",b.dp_temperature(1,{emit=c.temperature"C",scale=10,read_only=true}),b.dp_humidity(2,{emit=c.humidity(),scale=1,read_only=true}),b.dp_enum(3,{name="battery_state",emit=c.th2aaaBatteryStateV2(),read_only=true,converter=a.from_only(a.lookup_value{[0]="low",[1]="medium",[2]="high"})}),b.dp_enum(9,{name="temperature_unit",emit=c.th2aaaTemperatureUnit(),converter=a.lookup_from_to{celsius=0,fahrenheit=1}}),query_on_configure=true,query_on_announce=true,respond_to_mcu_version_response=true,time_start="1970"}d(aK,f.ts0601_fingerprints{"_TZE200_upagmta9","_TZE204_upagmta9","_TZE284_upagmta9","_TZE200_cirvgep4","_TZE204_cirvgep4","_TZE204_jygvp6fk","_TZE200_yjjdcqsq","_TZE204_yjjdcqsq","_TZE284_yjjdcqsq","_TZE200_9yapgbuv","_TZE204_9yapgbuv","_TZE284_9yapgbuv","_TZE200_utkemkbs","_TZE204_utkemkbs","_TZE284_utkemkbs","_TZE204_ksz749x8","_TZE284_ksz749x8","_TZE204_1wnh8bqp","_TZE284_1wnh8bqp","_TZE204_kwi6bbk4","_TZE204_d7lpruvi","_TZE200_d7lpruvi","_TZE284_d7lpruvi","_TZE284_hdyjyqjm"})local au={profile="sensors-temp-humidity-battery-excellux-dht",b.dp_battery(4,{emit=c.battery()}),b.dp_temperature(5,{emit=c.temperature"C",scale=100}),b.dp_numeric(101,{name="sampling_interval",emit=c.excelluxDhtSamplingInterval()}),b.dp_numeric(114,{name="temperature_calibration",emit=c.excelluxDhtTemperatureCalibration(),signed=true,converter=a.signed_number_pair(100)}),b.dp_numeric(115,{name="temperature_v0_set",emit=c.excelluxDhtTemperatureV0(),signed=true,converter=a.signed_number_pair(100)}),b.dp_numeric(116,{name="temperature_v1_set",emit=c.excelluxDhtTemperatureV1(),signed=true,converter=a.signed_number_pair(100)}),b.dp_enum(117,{name="temperature_warning",emit=c.excelluxDhtTemperatureWarning(),read_only=true,converter=a.from_only(a.lookup_value{[0]="none",[1]="low",[2]="high"})}),b.dp_humidity(118,{emit=c.humidity(),scale=100}),b.dp_numeric(119,{name="humidity_calibration",emit=c.excelluxDhtHumidityCalibration(),signed=true,converter=a.signed_number_pair(100)}),b.dp_numeric(120,{name="humidity_v0_set",emit=c.excelluxDhtHumidityV0(),converter=a.divide_by_pair(100)}),b.dp_numeric(121,{name="humidity_v1_set",emit=c.excelluxDhtHumidityV1(),converter=a.divide_by_pair(100)}),b.dp_enum(122,{name="humidity_warning",emit=c.excelluxDhtHumidityWarning(),read_only=true,converter=a.from_only(a.lookup_value{[0]="none",[1]="low",[2]="high"})})}d(au,{m.create_fingerprint("DHT0001","Excellux"),m.create_fingerprint("DHTA001","Excellux")})local ad={profile="sensors-temp-humidity-probe-excellux-full",b.dp_numeric(1,{name="probe_temperature",emit=c.excelluxProbeTemperature(),converter=a.divide_by_pair(10),read_only=true}),b.dp_battery(4,{emit=c.battery()}),b.dp_temperature(5,{emit=c.temperature"C",scale=100}),b.dp_numeric(101,{name="sampling_interval",emit=c.excelluxProbeSamplingInterval()}),b.dp_numeric(108,{name="probe_temperature_calibration",emit=c.excelluxProbeTempCalibration(),signed=true,converter=a.signed_number_pair(10)}),b.dp_numeric(109,{name="probe_temperature_v0_set",emit=c.excelluxProbeTemperatureV0(),signed=true,converter=a.signed_number_pair(10)}),b.dp_numeric(110,{name="probe_temperature_v1_set",emit=c.excelluxProbeTemperatureV1(),signed=true,converter=a.signed_number_pair(10)}),b.dp_enum(112,{name="probe_temperature_warning",emit=c.excelluxProbeTemperatureWarning(),read_only=true,converter=a.from_only(a.lookup_value{[0]="none",[1]="low",[2]="high"})}),b.dp_numeric(114,{name="temperature_calibration",emit=c.excelluxProbeAirTempCalibration(),signed=true,converter=a.signed_number_pair(100)}),b.dp_numeric(115,{name="temperature_v0_set",emit=c.excelluxProbeAirTemperatureV0(),signed=true,converter=a.signed_number_pair(100)}),b.dp_numeric(116,{name="temperature_v1_set",emit=c.excelluxProbeAirTemperatureV1(),signed=true,converter=a.signed_number_pair(100)}),b.dp_enum(117,{name="temperature_warning",emit=c.excelluxProbeAirTempWarning(),read_only=true,converter=a.from_only(a.lookup_value{[0]="none",[1]="low",[2]="high"})}),b.dp_humidity(118,{emit=c.humidity(),scale=100}),b.dp_numeric(119,{name="humidity_calibration",emit=c.excelluxProbeHumidityCalibration(),signed=true,converter=a.signed_number_pair(100)}),b.dp_numeric(120,{name="humidity_v0_set",emit=c.excelluxProbeHumidityV0(),converter=a.divide_by_pair(100)}),b.dp_numeric(121,{name="humidity_v1_set",emit=c.excelluxProbeHumidityV1(),converter=a.divide_by_pair(100)}),b.dp_enum(122,{name="humidity_warning",emit=c.excelluxProbeHumidityWarning(),read_only=true,converter=a.from_only(a.lookup_value{[0]="none",[1]="low",[2]="high"})})}d(ad,{m.create_fingerprint("NTCHT01","Excellux"),m.create_fingerprint("NTCHT02","Excellux"),m.create_fingerprint("NTCHT03","Excellux")})local O,J={profile="sensors-temp-battery",b.dp_temperature(1,{emit=c.temperature"C",scale=10}),b.dp_battery(4,{emit=c.battery()})},{b.dp_numeric(1,{name="probe_temperature",emit=c.dts1xm9ProbeTemperature(),read_only=true,signed=true,converter=a.signed_number_pair(10)}),b.dp_battery(4,{emit=c.battery(),read_only=true}),b.dp_temperature(5,{emit=c.temperature"C",read_only=true,signed=true,converter=a.signed_number_pair(100)}),b.dp_numeric(101,{name="sampling_interval",emit=c.dts1xm9SamplingInterval()}),b.dp_numeric(108,{name="probe_temperature_calibration",emit=c.dts1xm9ProbeTempCalibration(),signed=true,converter=a.signed_number_pair(10)}),b.dp_numeric(109,{name="probe_temperature_v0_set",emit=c.dts1xm9ProbeTemperatureV0(),signed=true,converter=a.signed_number_pair(10)}),b.dp_numeric(110,{name="probe_temperature_v1_set",emit=c.dts1xm9ProbeTemperatureV1(),signed=true,converter=a.signed_number_pair(10)}),b.dp_enum(112,{name="probe_temperature_warning",emit=c.dts1xm9ProbeTemperatureWarning(),read_only=true,converter=a.from_only(a.lookup_value{[0]="none",[1]="low",[2]="high"})}),b.dp_numeric(114,{name="temperature_calibration",emit=c.dts1xm9AirTemperatureCalibration(),signed=true,converter=a.signed_number_pair(100)}),b.dp_numeric(115,{name="temperature_v0_set",emit=c.dts1xm9AirTemperatureV0(),signed=true,converter=a.signed_number_pair(100)}),b.dp_numeric(116,{name="temperature_v1_set",emit=c.dts1xm9AirTemperatureV1(),signed=true,converter=a.signed_number_pair(100)}),b.dp_enum(117,{name="temperature_warning",emit=c.dts1xm9AirTemperatureWarning(),read_only=true,converter=a.from_only(a.lookup_value{[0]="none",[1]="low",[2]="high"})}),b.dp_humidity(118,{emit=c.humidity(),scale=100,read_only=true}),b.dp_numeric(119,{name="humidity_calibration",emit=c.dts1xm9HumidityCalibration(),signed=true,converter=a.signed_number_pair(100)}),b.dp_numeric(120,{name="humidity_v0_set",emit=c.dts1xm9HumidityV0(),converter=a.divide_by_pair(100)}),b.dp_numeric(121,{name="humidity_v1_set",emit=c.dts1xm9HumidityV1(),converter=a.divide_by_pair(100)}),b.dp_enum(122,{name="humidity_warning",emit=c.dts1xm9HumidityWarning(),read_only=true,converter=a.from_only(a.lookup_value{[0]="none",[1]="low",[2]="high"})}),b.dp_numeric(124,{name="tds",emit=c.dts1xm9Tds(),read_only=true}),b.dp_numeric(125,{name="tds_warning_set",emit=c.dts1xm9TdsThreshold()}),b.dp_enum(126,{name="tds_warning",emit=c.dts1xm9TdsWarning(),read_only=true,converter=a.from_only(a.lookup_value{[0]="none",[1]="high"})}),b.dp_numeric(127,{name="ec",emit=c.dts1xm9Ec(),read_only=true}),b.dp_numeric(128,{name="ec_v0_set",emit=c.dts1xm9EcV0()}),b.dp_numeric(129,{name="ec_v1_set",emit=c.dts1xm9EcV1()}),b.dp_enum(130,{name="ec_warning",emit=c.dts1xm9EcWarning(),read_only=true,converter=a.from_only(a.lookup_value{[0]="none",[1]="low",[2]="high"})}),b.dp_numeric(131,{name="salinity",emit=c.dts1xm9Salinity(),read_only=true,converter=a.divide_by_pair(10)}),b.dp_numeric(132,{name="specific_gravity",read_only=true,converter=a.divide_by_pair(1000)}),b.dp_enum(133,{name="mode",emit=c.dts1xm9Mode(),converter=a.lookup_from_to{freshwater=0,seawater=1}})}h({profile="sensors-water-quality-excellux-dts1xm9",datapoints=J,query_on_configure=false},{m.create_fingerprint("DTS1XM9","Excellux")})d(O,m.create_fingerprints("TS0201",{"_TZE200_iq4ygaai","_TZE200_01fvxamo"}))local A={}for aH=1,18 do
A[tostring(aH)]=aH
end
local function D()
local Q=c.neoNasAb02b0BatteryLow()
return function(e,z,an,ai)
local as=z=="battery_low"and"low"or"normal"return Q(e,as,an,ai)
end
end
local ap={profile="sensors-temp-humidity-alarm-neo-nas-ab02b0",query_on_configure=true,mcu_version_request_on_configure=true,b.dp_enum(101,{name="power_type",read_only=true,emit=c.all(c.neoNasAb02b0PowerType(),D()),converter=a.from_only(a.lookup_value{[0]="battery_full",[1]="battery_high",[2]="battery_medium",[3]="battery_low",[4]="usb"})}),b.dp_enum(102,{name="melody",emit=c.neoNasAb02b0AlarmMelody(),converter=a.lookup_from_to(A)}),b.dp_numeric(103,{name="duration",emit=c.neoNasAb02b0AlarmDuration()}),b.dp_alarm(104,{emit=c.alarm()}),b.dp_temperature(105,{emit=c.temperature"C",read_only=true,signed=true,converter=a.signed_number_pair(10)}),b.dp_humidity(106,{emit=c.humidity(),scale=1,read_only=true}),b.dp_numeric(107,{name="temperature_min",emit=c.neoNasAb02b0TemperatureMinimum(),signed=true,converter=a.signed_number_pair(1)}),b.dp_numeric(108,{name="temperature_max",emit=c.neoNasAb02b0TemperatureMaximum(),signed=true,converter=a.signed_number_pair(1)}),b.dp_numeric(109,{name="humidity_min",emit=c.neoNasAb02b0HumidityMinimum()}),b.dp_numeric(110,{name="humidity_max",emit=c.neoNasAb02b0HumidityMaximum()}),b.dp_binary(112,{name="unknown_112",read_only=true}),b.dp_binary(113,{name="temperature_alarm",emit=c.neoNasAb02b0TemperatureAlarm(),converter=a.lookup_from_to{off=false,on=true}}),b.dp_binary(114,{name="humidity_alarm",emit=c.neoNasAb02b0HumidityAlarm(),converter=a.lookup_from_to{off=false,on=true}}),b.dp_enum(115,{name="unknown_115",read_only=true}),b.dp_enum(116,{name="volume",emit=c.neoNasAb02b0AlarmVolume(),converter=a.lookup_from_to{low=2,medium=1,high=0}})}d(ap,f.ts0601_fingerprints{"_TZE200_d0yu2xgi"})local aJ={profile="sensors-illuminance-temp-humidity-battery",b.dp_illuminance(7,{emit=c.illuminance()}),b.dp_temperature(8,{emit=c.temperature"C",scale=10}),b.dp_humidity(9,{emit=c.humidity(),scale=1}),b.dp_battery(3,{emit=c.battery()})}d(aJ,f.ts0601_fingerprints{"_TZE200_vzqtvljm"})local aq={profile="sensors-illuminance-temp-humidity",b.dp_illuminance(2,{emit=c.illuminance()}),b.dp_temperature(6,{emit=c.temperature"C",scale=10}),b.dp_humidity(7,{emit=c.humidity(),scale=10})}d(aq,f.ts0601_fingerprints{"_TZE200_rbbx5mfq","_TZE204_rbbx5mfq"})
local function t(dp,Q,aa)
return b.dp_numeric(dp,{name=dp==1 and"temperature"or"temperature_probe",emit=Q,read_only=true,signed=true,converter=aa or a.signed_number_pair(10)})
end
local function G(Q)
return b.dp_enum(3,{name="battery_state",emit=Q,read_only=true,converter=a.lookup_from_to{low=0,medium=1,high=2}})
end
local W=a.signed_number_pair(10)
local V=a.from_to(function(z,e,_,am)
return W.from(z,e,nil,am)
end,W.to)
local aN={t(1,c.temperature"C",V),b.dp_humidity(2,{emit=c.humidity(),scale=1,read_only=true}),G(c.tzzt01BatteryState()),t(38,c.tzzt01ProbeTemperature(),V)}h({profile="sensors-temp-humidity-probe-battery-state-tzzt01",datapoints=aN,query_on_configure=false,time_start="off"},f.ts0601_fingerprints{"_TZE284_8se38w3c"})
local function ae(e)
local U=os.time()local ar=os.time(os.date("!*t",U))local aB=U+os.difftime(U,ar)local aM=b.send_time(e,U,aB)if aM then
e.thread:call_with_delay(0.5,function()
b.send_datapoint(e,17,b.DP_TYPE_BOOL,false)
end)
end
return aM==true
end
local aQ={t(1,c.temperature"C"),b.dp_humidity(2,{emit=c.humidity(),scale=1,read_only=true}),G(c.zt08BatteryState()),b.dp_enum(17,{name="time_format",emit=c.zt08TimeFormat(),read_only=true,converter=a.from_only(a.lookup_value{[0]="24h",[1]="12h"})}),t(38,c.temperatureProbe2aaa())}h({profile="sensors-temp-humidity-probe-battery-state-clock-zt08",datapoints=aQ,query_on_configure=false,time_handler=ae},f.ts0601_fingerprints{"_TZE284_hodyryli"})return{id="ef00.sensors.temp_humidity",registrations=Z}
