local t,q,l=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family"local p,i=l.definition_registry()
local function D(capability_id)
return assert(q[capability_id],"missing Wave16 Excellux emitter: "..capability_id)()
end
local function y(e,C,m)
return{name=e,emit=C,read_only=m==true,transaction=1}
end
local function b(E,e,capability_id,n,m,B)
local h=y(e,D(capability_id),m)if B then
h.signed=true
h.converter=t.converter.signed_number_pair(n or 1)elseif n~=nil and n~=1 then
h.converter=t.converter.divide_by_pair(n)end
return t.dp_numeric(E,h)
end
local function f(E,e,C,n,B)
local h=y(e,C,true)if B then
h.signed=true
h.converter=t.converter.signed_number_pair(n or 1)elseif n~=nil and n~=1 then
h.converter=t.converter.divide_by_pair(n)end
return t.dp_numeric(E,h)
end
local function o(E,e,capability_id,H,m)
local h=y(e,D(capability_id),m)h.converter=t.converter.lookup_from_to(H)return t.dp_enum(E,h)
end
local function x(z,A)
return{profile=z,package_group=A,magic_packet=true,query_on_configure=false,time_start="off",datapoints={}}
end
local function d(c,h)
c.datapoints[#c.datapoints+1]=h
end
local g,a={none=0,low=1,high=2},x("sensors-wave16-excellux-airprs1","environment-sensor")d(a,f(4,"battery",q.battery(),1,false))d(a,f(5,"temperature",q.temperature"C",100,true))d(a,f(20,"illuminance",q.illuminance(),1,false))d(a,b(101,"airprs_one_sampling_interval","airprsOneSamplingInterval",1,false,false))d(a,b(104,"airprs_one_illuminance_v_zero","airprsOneIlluminanceVZero",1,false,false))d(a,b(105,"airprs_one_illuminance_v_one","airprsOneIlluminanceVOne",1,false,false))d(a,b(106,"airprs_one_illuminance_calibration","airprsOneIlluminanceCalibration",1,false,true))d(a,o(107,"airprs_one_illuminance_warning","airprsOneIlluminanceWarning",g,true))d(a,b(108,"airprs_one_uv","airprsOneUv",1,true,false))d(a,b(109,"airprs_one_uv_level","airprsOneUvLevel",10,true,false))d(a,b(110,"airprs_one_uv_calibration","airprsOneUvCalibration",10,false,true))d(a,o(111,"airprs_one_uv_warning","airprsOneUvWarning",{Low=0,Moderate=1,High=2,["Very High"]=3,Extreme=4},true))d(a,b(114,"airprs_one_temperature_calibration","airprsOneTemperatureCalibration",100,false,true))d(a,b(115,"airprs_one_temperature_v_zero","airprsOneTemperatureVZero",100,false,true))d(a,b(116,"airprs_one_temperature_v_one","airprsOneTemperatureVOne",100,false,true))d(a,o(117,"airprs_one_temperature_warning","airprsOneTemperatureWarning",g,true))d(a,f(124,"pressure",q.atmospheric_pressure(),1000,false))d(a,b(125,"airprs_one_pressure_calibration","airprsOnePressureCalibration",100,false,true))d(a,b(126,"airprs_one_pressure_v_zero","airprsOnePressureVZero",100,false,false))d(a,b(127,"airprs_one_pressure_v_one","airprsOnePressureVOne",100,false,false))d(a,o(128,"airprs_one_pressure_warning","airprsOnePressureWarning",g,true))d(a,o(129,"airprs_one_pressure_trend","airprsOnePressureTrend",{normal=0,rise=1,fall=2},true))i(a,l.create_fingerprints("Excellux",{"AIRPRS1"}))
local function w(z,F,u,v)
local c=x(z,"soil-sensor")
local function k(suffix)
return u..suffix
end
local function e(suffix)
return F..suffix
end
d(c,b(1,e"probe_temperature",k"ProbeTemperature",10,true,true))d(c,f(4,"battery",q.battery(),1,false))d(c,f(5,"temperature",q.temperature"C",100,true))d(c,b(101,e"sampling_interval",k"SamplingInterval",1,false,false))d(c,f(118,"humidity",q.humidity(),100,false))d(c,b(108,e"probe_temperature_calibration",k"ProbeTemperatureCalibration",10,false,true))d(c,b(109,e"probe_temperature_v_zero",k"ProbeTemperatureVZero",10,false,true))d(c,b(110,e"probe_temperature_v_one",k"ProbeTemperatureVOne",10,false,true))d(c,o(112,e"probe_temperature_warning",k"ProbeTemperatureWarning",g,true))d(c,b(114,e"temperature_calibration",k"TemperatureCalibration",100,false,true))d(c,b(115,e"temperature_v_zero",k"TemperatureVZero",100,false,true))d(c,b(116,e"temperature_v_one",k"TemperatureVOne",100,false,true))d(c,o(117,e"temperature_warning",k"TemperatureWarning",g,true))d(c,b(119,e"humidity_calibration",k"HumidityCalibration",100,false,true))d(c,b(120,e"humidity_v_zero",k"HumidityVZero",100,false,false))d(c,b(121,e"humidity_v_one",k"HumidityVOne",100,false,false))d(c,o(122,e"humidity_warning",k"HumidityWarning",g,true))if v then
d(c,b(124,e"fertility",k"Fertility",1,true,false))d(c,b(125,e"fertility_v_zero",k"FertilityVZero",1,false,false))d(c,b(126,e"fertility_v_one",k"FertilityVOne",1,false,false))d(c,o(127,e"fertility_warning",k"FertilityWarning",g,true))d(c,b(128,e"fertility_calibration",k"FertilityCalibration",1000,false,false))end
d(c,b(3,e"moisture",k"Moisture",1,true,false))d(c,b(129,e"moisture_v_zero",k"MoistureVZero",1,false,false))d(c,b(130,e"moisture_v_one",k"MoistureVOne",1,false,false))d(c,b(131,e"moisture_calibration",k"MoistureCalibration",100,false,false))d(c,o(132,e"moisture_warning",k"MoistureWarning",g,true))return c
end
local r=w("sensors-wave16-excellux-ez500fl","ez_fl_","ezFl",true)i(r,l.create_fingerprints("Excellux",{"EZ500FL"}))local s=w("sensors-wave16-excellux-ez500fs","ez_fs_","ezFs",false)i(s,l.create_fingerprints("Excellux",{"EZ500FS"}))return{id="ef00.sensors.wave16_excellux",registrations=p}
