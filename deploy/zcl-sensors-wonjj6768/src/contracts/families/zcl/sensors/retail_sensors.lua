local b,K,h,t,a,B,E,U=require"protocol.zcl",require"contracts.helpers.family",require"capabilities.events.all",require"st.capabilities",require"st.zigbee.data_types",require"st.zigbee.device_management",require"st.zigbee.cluster_base",require"contracts.helpers.zcl_sensor_definitions"local g=K.create_fingerprint
local w,c=K.definition_registry()
local function e(ad)
return function(Y,f)
for _,ab in ipairs(ad)do
for _,O in ipairs(ab.clusters)do
f:send(B.build_bind_request(f,O,Y.environment_info.hub_zigbee_eui,ab.endpoint))end
end
end
end
local function j(m)
m.minimum_interval=nil
m.maximum_interval=nil
m.reportable_change=nil
m.read_on_configure=false
return m
end
local L,r,p={profile="safety-motion-battery-low-battery-voltage-ewelink-pending",zcl_clusters={j(b.motion()),j(b.battery_low()),b.battery{minimum_interval=3600,maximum_interval=7200},b.battery_voltage{minimum_interval=3600,maximum_interval=7200,reportable_change=100}}},{profile="safety-motion-battery-low-battery-voltage-3rms-pending",zcl_clusters={b.motion(),b.battery_low(),b.battery(),b.battery_voltage()}},{profile="safety-motion-battery-low-battery-voltage-3rsmr-pending",zcl_clusters={b.motion(),b.battery_low(),b.battery(),b.battery_voltage()}}local o={profile="safety-motion-battery-3rps-pending",zcl_clusters={b.motion(),b.battery(),b.cluster_attribute(65281,96,{name="rps_sensitivity",endpoint=1,mfg_code=5127,data_type=a.Uint8,write_type=a.Uint8,read_on_configure=true,emit=h.rpsSensitivity()}),b.cluster_attribute(65281,3,{name="rps_calibration",endpoint=1,mfg_code=5127,data_type=a.Uint8,write_type=a.Uint8,read_on_configure=true,emit=h.rpsCalibration(),
from_device=function(d)return d==1 and"Press"or nil end,
to_device=function(d)return d=="Press"and 1 or nil end
})}}local l,n={profile="safety-motion-tamper-battery-battery-low",zcl_clusters={b.motion(),b.tamper(),b.battery_low(),b.battery()}},{profile="safety-motion-illuminance",zcl_clusters={b.occupancy{emit=h.motion()},b.illuminance()}}local q={profile="safety-motion-illuminance-battery-candeo-pending",datapoints={{dp=9,datatype=4,name="candeo_motion_sensitivity",emit=h.candeoMotionSensitivity(),
from_device=function(d)return({[0]="low","medium","high"})[d]end,
to_device=function(d)return({low=0,medium=1,high=2})[d]end},
{dp=10,datatype=4,name="candeo_motion_keep_time",emit=h.candeoMotionKeepTime(),
from_device=function(d)return({[0]="10","30","60","120"})[d]end,
to_device=function(d)return({["10"]=0,["30"]=1,["60"]=2,["120"]=3})[d]end},
{dp=102,datatype=2,name="candeo_light_interval",emit=h.candeoLightInterval"min"}},zcl_clusters={b.tuya_magic_packet(),b.motion(),b.illuminance{configure_reporting=false,
converter={from=function(X)
local T=10 ^((X-1)/10000)if T<=2200 then T=-7.969192+0.0151988*T
elseif T<=2500 then T=-1069.189434+0.4950663*T
else T=78029.21628-61.73575*T+0.01223567*T*T end
return math.floor(math.max(1,T)+0.5)
end}
},b.battery()}}local J,y,M,H,C,D,V,s={profile="safety-contact-battery",zcl_clusters={b.contact(),b.battery()}},{profile="safety-contact-battery-low-battery",zcl_clusters={b.contact(),b.battery_low(),b.battery()}},{profile="safety-contact-tamper-battery-low-battery",zcl_clusters={b.contact_alarm_1_or_2(),b.tamper(),b.battery_low(),b.battery()}},{profile="safety-contact-battery-low-battery-voltage",zcl_clusters={b.contact(),b.battery_low(),b.battery(),b.battery_voltage()}},{profile="safety-contact-battery-low-battery-voltage",zcl_clusters={b.contact(),b.battery_low(),b.battery(),b.battery_voltage()}},{profile="safety-contact-battery-low-battery",zcl_clusters={b.contact(),b.battery_low(),b.battery()}},{profile="safety-water-leak-battery",zcl_clusters={b.water(),b.battery()}},U.water_battery_low_battery_sensor
local function G(f,m,d)
local X=d
if m.attribute_id==16 then X=({ON=1,OFF=0})[d]end
if type(X)~="number"or X%1~=0 or X<0 or X>255 then return false end
f:send(E.write_manufacturer_specific_attribute(f,65281,m.attribute_id,4659,a.Uint8,X):to_endpoint(1))f:send(E.read_manufacturer_specific_attribute(f,65281,m.attribute_id,4659):to_endpoint(1))return true
end
local k=b.water{endpoint=1,read_only=true,read_on_refresh=false,ias_configure_method=0}k.minimum_interval,k.maximum_interval,k.reportable_change=nil,nil,nil
k.read_on_configure=false
local A={profile="safety-water-leak-battery-low-battery-3rws18bz-pending",magic_packet=false,zcl_clusters={b.switch{endpoint=1,minimum_interval=0,maximum_interval=65000,suppress_optimistic_state=true},k,b.battery_low{endpoint=1,configure_reporting=false,read_only=true,read_on_configure=false,
read_on_refresh=false,ias_configure_method=0,emit=function(_,d)
return d and t.batteryLevel.battery.critical()or t.batteryLevel.battery.normal()
end},
b.battery{endpoint=1,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=10,
from_device=function(d,f,i)
if i.raw_value==255 then return nil end
local ac=f:get_field"third_ws_application_version"return ac and ac<=23 and i.raw_value or d
end},
b.cluster_attribute(0,1,{name="third_ws_application_version",endpoint=1,data_type=a.Uint8,
read_only=true,read_on_configure=true,emit=function(f,d)
f:set_field("third_ws_application_version",d,{persist=true})
end}),
b.cluster_attribute(65281,16,{name="third_ws_buzzer",endpoint=1,data_type=a.Uint8,write_type=a.Uint8,mfg_code=4659,read_on_configure=true,suppress_optimistic_state=true,emit=h.thirdWsBuzzer(),sender=G,
from_device=function(d)return d==1 and"ON"or"OFF"end}),
b.cluster_attribute(65281,17,{name="third_ws_buzzer_minutes",endpoint=1,data_type=a.Uint8,write_type=a.Uint8,mfg_code=4659,read_on_configure=true,suppress_optimistic_state=true,numeric_range={minimum=0,maximum=255},emit=h.thirdWsBuzzerMinutes(),sender=G})}}local P,v,x,z,u,Q,S={profile="sensors-temp-humidity-battery",zcl_clusters={b.temperature(),b.humidity(),b.battery()}},{profile="sensors-temp-humidity-battery-voltage",zcl_clusters={b.temperature(),b.humidity(),b.battery(),b.battery_voltage()}},{profile="sensors-temp-humidity-battery-voltage",zcl_clusters={b.temperature{endpoint=38},b.humidity{endpoint=38},b.battery{endpoint=38},b.battery_voltage{endpoint=38}},configure=e{{endpoint=38,clusters={1026,1029,1}}}},{profile="sensors-temp-humidity-battery-3rths-pending",zcl_clusters={b.temperature(),b.humidity(),b.battery()}},{profile="sensors-temp-humidity-battery-3rths0324-pending",advanced_remote=true,zcl_clusters={b.temperature(),b.humidity(),b.battery(),b.cluster_attribute(65281,49,{name="third_rths0324_celsius_calibration",emit=h.thirdRths0324CelsiusCal(),data_type=a.Int16,scale=100,mfg_code=5127,minimum_interval=0,maximum_interval=3600,reportable_change=100}),b.cluster_attribute(65281,50,{name="third_rths0324_humidity_calibration",emit=h.thirdRths0324HumidityCal(),data_type=a.Int16,scale=100,mfg_code=5127,minimum_interval=0,maximum_interval=3600,reportable_change=100}),b.cluster_attribute(65281,51,{name="third_rths0324_fahrenheit_calibration",emit=h.thirdRths0324FahrenheitCal(),data_type=a.Int16,scale=100,mfg_code=5127,minimum_interval=0,maximum_interval=3600,reportable_change=100})}},{profile="sensors-temp-humidity-battery",zcl_clusters={b.temperature{endpoint=1},b.humidity{endpoint=2},b.battery{endpoint=2}},configure=e{{endpoint=1,clusters={1026}},{endpoint=2,clusters={1029,1}}}},{profile="sensors-temp-humidity-battery",zcl_clusters={b.temperature{endpoint=1},b.humidity{endpoint=2},b.battery{endpoint=1}},configure=e{{endpoint=1,clusters={1026,1}},{endpoint=2,clusters={1029}}}}local F={profile="sensors-temp-humidity-battery-zg9032b",zcl_clusters={b.temperature{endpoint=1},b.humidity{endpoint=2},b.battery{endpoint=1},b.cluster_attribute(1026,4096,{name="zg9032b_temperature_compensation",endpoint=1,emit=h.zg9032bTemperatureCompensation(),data_type=a.Int8,write_type=a.Int8,mfg_code=4644,numeric_range={minimum=-5,maximum=5,step=1,unit="C"},read_on_configure=true}),b.cluster_attribute(1026,4097,{name="zg9032b_temperature_display_unit",endpoint=1,emit=h.zg9032bTemperatureDisplayUnit(),data_type=a.Enum8,write_type=a.Enum8,mfg_code=4644,
from_device=function(d)
return({[0]="celsius",[1]="fahrenheit"})[d]
end,
to_device=function(d)
return({celsius=0,fahrenheit=1})[d]
end,
read_on_configure=true}),b.cluster_attribute(1029,4096,{name="zg9032b_humidity_compensation",endpoint=2,emit=h.zg9032bHumidityCompensation(),data_type=a.Int8,write_type=a.Int8,mfg_code=4644,numeric_range={minimum=-5,maximum=5,step=1,unit="%"},read_on_configure=true})},configure=e{{endpoint=1,clusters={1026,1}},{endpoint=2,clusters={1029}}}}local I={profile="safety-smoke-temp-tamper-battery-low-battery-voltage-schneider-pending",magic_packet=false,zcl_clusters={b.smoke{minimum_interval=0,maximum_interval=65000,reportable_change=0,read_on_configure=true},b.temperature{minimum_interval=10,maximum_interval=3600,reportable_change=100},b.tamper{minimum_interval=0,maximum_interval=65000,reportable_change=0,read_on_configure=false},b.battery_low{minimum_interval=0,maximum_interval=65000,reportable_change=0,read_on_configure=false,
emit=function(_,d)
return d and t.batteryLevel.battery.critical()or t.batteryLevel.battery.normal()
end},
b.battery{minimum_interval=3600,maximum_interval=65000,reportable_change=10,
from_device=function(d,_,i)if i.raw_value~=255 then return d end end},
b.battery_voltage{minimum_interval=3600,maximum_interval=65000,reportable_change=10,
from_device=function(d,_,i)if i.raw_value~=255 then return d end end}
}}local R={profile="sensors-heiman-hs2aq-air-quality",zcl_clusters={b.temperature(),b.humidity(),b.battery(),b.cluster_attribute(1066,0,{name="pm25",emit=h.pm25(),data_type=a.Uint16,minimum_interval=0,maximum_interval=3600,reportable_change=1}),b.cluster_attribute(1067,0,{name="formaldehyde",emit=h.formaldehyde(),data_type=a.Uint16,scale=1000,minimum_interval=0,maximum_interval=3600,reportable_change=1}),b.cluster_attribute(64641,61442,{name="heiman_battery_state",emit=h.heimanHs2aqBatteryState(),data_type=a.Uint8,mfg_code=4619,
from_device=function(d)
return({[0]="not_charging",[1]="charging",[2]="charged"})[d]
end,
minimum_interval=0,maximum_interval=3600,reportable_change=1}),b.cluster_attribute(64641,61443,{name="heiman_pm10",emit=h.heimanHs2aqPm10(),data_type=a.Uint16,mfg_code=4619,minimum_interval=0,maximum_interval=3600,reportable_change=1}),b.cluster_attribute(64641,61444,{name="voc",emit=h.voc(),data_type=a.Uint16,mfg_code=4619,minimum_interval=0,maximum_interval=3600,reportable_change=1}),b.cluster_attribute(64641,61445,{name="heiman_aqi",emit=h.heimanHs2aqAqi(),data_type=a.Uint16,mfg_code=4619,minimum_interval=0,maximum_interval=3600,reportable_change=1})},
configure=function(Y,f)
for _,O in ipairs{1,10,1026,1029,1066,1067,64641}do
f:send(B.build_bind_request(f,O,Y.environment_info.hub_zigbee_eui,1))end
local ai=os.time()local W,Z=os.date("*t",ai),os.date("!*t",ai)Z.isdst=W.isdst
local af=os.difftime(os.time(W),os.time(Z))local tx
for _,ae in ipairs{{1,a.Bitmap8(3)},{0,a.UtcTime(ai-946684800)},{2,a.Int32(af)}}do
local ag=E.write_attribute(f,a.ClusterId(10),a.AttributeId(ae[1]),ae[2])if tx then tx.body.zcl_body.attr_records[#tx.body.zcl_body.attr_records+1]=ag.body.zcl_body.attr_records[1]else tx=ag end
end
f:send(tx:to_endpoint(1))
end
}local aa={profile="safety-contact-temp-battery",zcl_clusters={b.cluster_attribute(15,85,{name="contact",emit=h.contact(),data_type=a.Boolean,read_only=true,read_on_configure=true,read_on_refresh=true,
from_device=function(d)
return d==false or d==0
end
}),b.temperature{scale=10},b.cluster_attribute(b.CLUSTER_POWER_CONFIGURATION,b.ATTR_BATTERY_PERCENTAGE_REMAINING,{name="battery",emit=h.battery(),data_type=a.Uint8,scale=1,minimum_interval=300,maximum_interval=21600,reportable_change=1})}}local N={profile="safety-contact-battery",zcl_clusters={j(b.contact{endpoint=1,read_only=true,read_on_refresh=false,
from_device=function(_,_,i)
if i.command_id~=0 then return nil end
return bit32.band(i.raw_value,1)~=0
end
}),b.cluster_attribute(b.CLUSTER_POWER_CONFIGURATION,b.ATTR_BATTERY_PERCENTAGE_REMAINING,{name="battery",emit=h.battery(),data_type=a.Uint8,scale=2,
from_device=function(d,_,i)
if i.raw_value==255 then return nil end
return d
end,
minimum_interval=300,maximum_interval=21600,reportable_change=1})}}c(l,{g("LDS","ZHA-PirSensor")})c(n,{g("Leedarson","ZHA-PIRSensor")})c(L,{g("eWeLink","CK-TLSR8656-SS5-01(7002)"),g("eWeLink","MS01"),g("eWeLink","MSO1"),g("eWeLink","SNZB-03"),g("SONOFF","CK-TLSR8656-SS5-01(7002)"),g("SONOFF","MS01"),g("SONOFF","MSO1"),g("SONOFF","SNZB-03")})c(q,{g("Candeo","C-ZB-SEMO")})c(J,{g("Candeo","C-ZB-SEDC")})c(J,{g("Sunricher","HK-SENSOR-CT-A")})c(y,{g("Sunricher","HK-SENSOR-CT-MINI")})c(M,{g("Shyugj","DoorSensor-ZB3.0")})c(H,{g("eWeLink","CK-TLSR8656-SS5-01(7003)"),g("eWeLink","SNZB-04")})c(V,{g("Candeo","C-ZB-SEWA")})c(A,{g("Third Reality, Inc","3RWS18BZ"),g("THIRDREALITY","3RWS18BZ")})c(V,{g("Third Reality, Inc","3RWS0218Z")})c(s,{g("eWeLink","CK-TLSR8656-SS5-01(7019)"),g("eWeLink","SNZB-05")})c(P,{g("Candeo","C-ZB-SETE")})c(x,{g("Frient","HMSZB-120")})c(z,{g("Third Reality, Inc","3RTHS24BZ"),g("Third Reality, Inc","3RTHS0224Z")})c(u,{g("Third Reality, Inc","3RTHS0324Z")})c(Q,{g("HEIMAN","HT-EM"),g("HEIMAN","TH-EM"),g("HEIMAN","TH-T_V14")})c(S,{g("HEIMAN","HT-N"),g("HEIMAN","HT-EF-3.0"),g("HEIMAN","HS3HT-EFA-3.0")})c(F,{g("Sunricher","ZG9032B")})c(v,{g("eWeLink","CK-TLSR8656-SS5-01(7014)"),g("Zbeacon","TH01")})c(R,{g("HEIMAN","HS2AQ-EM"),g("HEIMAN","HS2AQ-EM-3.0")})c(aa,{g("TERNCY","TERNCY-DC01")})c(N,{g("Sunricher","TERNCY-DC01")})c(I,{g("Schneider Electric","755WSA"),g("Schneider Electric","W599501"),g("Schneider Electric","W599001")})c(r,{g("Third Reality, Inc","3RMS16BZ")})c(p,{g("Third Reality, Inc","3RSMR01067Z")})c(o,{g("Third Reality, Inc","3RPS01083Z")})c(C,{g("Third Reality, Inc","3RDS17BZ")})c(D,{g("Third Reality, Inc","3RDTS01056Z")})b.attach_reporting_capabilities(w,{{1,"rpt-txk"},{2,"rpt-zcl"},{3,"rpt-cep"},{4,"rpt-cgl"},{5,"rpt-cvm"},{6,"rpt-cvm"},{7,"rpt-hqa"},{8,"rpt-rab"},{9,"rpt-tku"},{10,"rpt-cxv"},{11,"rpt-zjd"},{12,"rpt-cxv"},{13,"rpt-tml"},{14,"rpt-tgdf"},{15,"rpt-sgy"},{16,"rpt-tgdf"},{17,"rpt-zkk"},{18,"rpt-tgdf"},{19,"rpt-tgdf"},{20,"rpt-zzw"},{21,"rpt-sgy"},{22,"rpt-hlk"},{23,"rpt-trc"},{24,"rpt-tcg"},{25,"rpt-zxh"},{26,"rpt-tctq"},{27,"rpt-tctq"},{28,"rpt-zjr"},{29,"rpt-tku"},{30,"rpt-hqa"}})return{id="zcl.sensors.retail_sensors",registrations=w}
