local p,as,o,U=require"protocol.zcl",require"capabilities.events.all",require"st.capabilities",require"contracts.helpers.family"local T,X,a=U.create_fingerprint,require"st.zigbee.device_management",require"st.zigbee.data_types"
local K,h=U.definition_registry()local V,G,Z,N,i,C,F,M,l,B,aa,k,x,L=32,1026,1027,1029,1030,1280,64529,4742,0,2,0,32,33,34













local function J(capability_id)
return assert(as[capability_id],"missing SONOFF emitter: "..capability_id)()
end
local function f(aH,A)
A:send(X.build_bind_request(A,V,aH.environment_info.hub_zigbee_eui,1))
end
local function E(d)
d=d or{}return p.battery{endpoint=1,minimum_interval=d.minimum_interval or 3600,maximum_interval=d.maximum_interval or 65000,reportable_change=d.reportable_change==nil and 10 or d.reportable_change,read_only=true}
end
local function P(d)
d=d or{}return p.battery_voltage{endpoint=1,minimum_interval=d.minimum_interval or 3600,maximum_interval=d.maximum_interval or 65000,reportable_change=d.reportable_change==nil and 10 or d.reportable_change,read_only=true}
end
local function m(d)
d=d or{}return p.temperature{endpoint=1,minimum_interval=d.minimum_interval or 10,maximum_interval=d.maximum_interval or 3600,reportable_change=d.reportable_change==nil and 100 or d.reportable_change,read_only=true,handler=d.handler}
end
local function H(d)
d=d or{}return p.humidity{endpoint=1,minimum_interval=d.minimum_interval or 10,maximum_interval=d.maximum_interval or 3600,reportable_change=d.reportable_change==nil and 100 or d.reportable_change,read_only=true,handler=d.handler}
end
local function c(at,capability_id,ag,ae,az,ay,aL)
return p.cluster_attribute(F,ag,{name=at,endpoint=1,emit=J(capability_id),data_type=ae,write_type=ae,scale=100,
to_device=function(b)
return type(b)=="number"and b+1e-9 or b
end,
numeric_range={minimum=az,maximum=ay,step=0.1,unit=aL},read_on_configure=true})
end
local function w(at,capability_id)
local am,ap={[0]="celsius",[1]="fahrenheit"},{celsius=0,fahrenheit=1}return p.cluster_attribute(F,7,{name=at,endpoint=1,emit=J(capability_id),data_type=a.Uint16,write_type=a.Uint16,
from_device=function(b)return am[b]end,
to_device=function(b)return ap[b]end,
read_on_configure=true})
end
local aD={profile="sonoff-snzb02p-temp-humidity",zcl_clusters={m(),H(),E(),c("sonoff_snzb02p_temperature_calibration","sonoffSnzb02pTemperatureCal",8195,a.Int16,-50,50,"C"),c("sonoff_snzb02p_humidity_calibration","sonoffSnzb02pHumidityCal",8196,a.Int16,-50,50,"%")},configure=f}h(aD,{T("eWeLink","SNZB-02P"),T("SONOFF","SNZB-02P")})local aB={profile="sonoff-snzb02d-temp-humidity-display",zcl_clusters={m(),H(),E(),c("sonoff_snzb02d_comfort_temperature_min","sonoffSnzb02dComfortTempMin",4,a.Int16,-10,60,"C"),c("sonoff_snzb02d_comfort_temperature_max","sonoffSnzb02dComfortTempMax",3,a.Int16,-10,60,"C"),c("sonoff_snzb02d_comfort_humidity_min","sonoffSnzb02dComfortHumidityMin",5,a.Uint16,5,95,"%"),c("sonoff_snzb02d_comfort_humidity_max","sonoffSnzb02dComfortHumidityMax",6,a.Uint16,5,95,"%"),w("sonoff_snzb02d_temperature_units","sonoffSnzb02dTemperatureUnits"),c("sonoff_snzb02d_temperature_calibration","sonoffSnzb02dTemperatureCal",8195,a.Int16,-50,50,"C"),c("sonoff_snzb02d_humidity_calibration","sonoffSnzb02dHumidityCal",8196,a.Int16,-50,50,"%")},configure=f}h(aB,{T("SONOFF","SNZB-02D")})local au={profile="sonoff-snzb02ld-temperature-display",zcl_clusters={m{minimum_interval=5,maximum_interval=3600,reportable_change=20},E(),w("sonoff_snzb02ld_temperature_units","sonoffSnzb02ldTemperatureUnits"),c("sonoff_snzb02ld_temperature_calibration","sonoffSnzb02ldTemperatureCal",8195,a.Int16,-50,50,"C")},configure=f}h(au,{T("SONOFF","SNZB-02LD")})local av={profile="sonoff-snzb02wd-temp-humidity-display",zcl_clusters={m{minimum_interval=5,maximum_interval=3600,reportable_change=20},H{minimum_interval=5,maximum_interval=3600,reportable_change=100},E(),P(),w("sonoff_snzb02wd_temperature_units","sonoffSnzb02wdTemperatureUnits"),c("sonoff_snzb02wd_temperature_calibration","sonoffSnzb02wdTemperatureCal",8195,a.Int16,-50,50,"C"),c("sonoff_snzb02wd_humidity_calibration","sonoffSnzb02wdHumidityCal",8196,a.Int16,-50,50,"%")},configure=f}h(av,{T("SONOFF","SNZB-02WD")})local aj={profile="sonoff-ewelink-7014-temp-humidity",zcl_clusters={m(),H(),E()}}h(aj,{T("eWeLink","CK-TLSR8656-SS5-02(7014)")})local aE={profile="sonoff-snzb03p-occupancy",zcl_clusters={p.occupancy{endpoint=1,minimum_interval=0,maximum_interval=3600,reportable_change=0,read_on_configure=true,read_only=true},p.cluster_attribute(i,k,{name="sonoff_snzb03p_motion_timeout",endpoint=1,emit=J"sonoffSnzb03pMotionTimeout",data_type=a.Uint16,write_type=a.Uint16,numeric_range={minimum=5,maximum=60,step=1,unit="s"},read_on_configure=true}),p.cluster_attribute(F,8193,{name="sonoff_snzb03p_illumination",endpoint=1,emit=J"sonoffSnzb03pIllumination",data_type=a.Uint8,mfg_code=M,
from_device=function(b)return({[0]="dim",[1]="bright"})[b]end,
read_only=true,read_on_configure=false,read_on_refresh=false}),E{maximum_interval=7200,reportable_change=2},P{maximum_interval=7200,reportable_change=100}}}h(aE,{T("eWeLink","SNZB-03P"),T("SONOFF","SNZB-03P")})local aI={profile="sonoff-mg35rz-occupancy",zcl_clusters={p.cluster_attribute(i,aa,{name="occupancy",endpoint=1,emit=as.occupancy(),data_type=a.Bitmap8,
from_device=function(b)
b=type(b)=="table"and b.value or b
if type(b)~="number"then return nil end
return b%2==1
end,
read_only=true,read_on_configure=false}),p.cluster_attribute(i,k,{name="sonoff_mg35rz_occupied_delay",endpoint=1,emit=J"sonoffMg35rzOccupiedDelay",data_type=a.Uint16,write_type=a.Uint16,numeric_range={minimum=60,maximum=65535,step=1,unit="s"},read_on_configure=true}),p.cluster_attribute(i,x,{name="sonoff_mg35rz_unoccupied_delay",endpoint=1,emit=J"sonoffMg35rzUnoccupiedDelay",data_type=a.Uint16,write_type=a.Uint16,numeric_range={minimum=0,maximum=65535,step=1,unit="s"},read_on_configure=true}),p.cluster_attribute(i,L,{name="sonoff_mg35rz_sensitivity",endpoint=1,emit=J"sonoffMg35rzSensitivity",data_type=a.Uint8,write_type=a.Uint8,
from_device=function(b)return({[1]="low",[2]="medium",[3]="high"})[b]end,
to_device=function(b)return({low=1,medium=2,high=3})[b]end,
read_on_configure=true})}}h(aI,{T("eWeLink","CK-BL702-MWS-01(7016)"),T("SONOFF","MG1_5RZ")})
local function W(aK)
return function(A,b)
A:set_field(aK,b,{persist=false})
end
end
local function ax(b,aG)
local ak=10 ^ aG
local al=b*ak
if al>=0 then
return math.floor(al+0.5)/ak
end
return math.ceil(al-0.5)/ak
end
local function n(Y,ab,capability_id)
local aq=J(capability_id)
return function(A)
local j,v=A:get_field(Y),A:get_field(ab)if type(j)~="number"or type(v)~="number"then
return nil
end
local af=0.61078*math.exp((17.27*j)/(j+237.3))local aF=(v/100)*af
local ai={aq(A,ax(af-aF,2))}if v>0 then
local aw=(17.27*j)/(j+237.7)+math.log(v/100)local ao=ax((237.7*aw)/(17.27-aw),1)ai[#ai+1]=o.dewPoint.dewpoint{value=ao,unit="C"}end
return ai
end
end
local s,z="__sonoff_snzb02m_temperature","__sonoff_snzb02m_humidity"local u=n(s,z,"sonoffSnzb02mVpd")local aC={profile="sonoff-snzb02m-environment",zcl_clusters={m{minimum_interval=5,reportable_change=20,handler=W(s)},H{minimum_interval=5,reportable_change=100,handler=W(z)},E(),p.cluster_attribute(Z,4,{name="pressure",endpoint=1,
emit=function(_,b)
return o.atmosphericPressureMeasurement.atmosphericPressure{value=b,unit="hPa"}
end,
data_type=a.Int32,scale=100,minimum_interval=5,maximum_interval=3600,reportable_change=50,read_only=true,read_on_configure=true}),c("sonoff_snzb02m_temperature_calibration","sonoffSnzb02mTemperatureCal",8195,a.Int16,-50,50,"C"),c("sonoff_snzb02m_humidity_calibration","sonoffSnzb02mHumidityCal",8196,a.Int16,-50,50,"%"),c("sonoff_snzb02m_pressure_calibration","sonoffSnzb02mPressureCal",8199,a.Int16,-200,200,"hPa"),p.cluster_attribute(G,l,{name="sonoff_snzb02m_vpd",endpoint=1,emit=u,data_type=a.Int16,scale=100,read_only=true,read_on_configure=false}),p.cluster_attribute(N,l,{name="sonoff_snzb02m_calculated_humidity_trigger",endpoint=1,emit=u,data_type=a.Uint16,scale=100,read_only=true,read_on_configure=false})},configure=f}h(aC,{T("SONOFF","SNZB-02M")})local r,y="__sonoff_snzb02b_temperature","__sonoff_snzb02b_humidity"local t=n(r,y,"sonoffSnzb02bVpd")local aA={profile="sonoff-snzb02b-environment",zcl_clusters={m{minimum_interval=5,reportable_change=20,handler=W(r)},H{minimum_interval=5,reportable_change=100,handler=W(y)},E(),c("sonoff_snzb02b_temperature_calibration","sonoffSnzb02bTemperatureCal",8195,a.Int16,-50,50,"C"),c("sonoff_snzb02b_humidity_calibration","sonoffSnzb02bHumidityCal",8196,a.Int16,-50,50,"%"),p.cluster_attribute(G,l,{name="sonoff_snzb02b_vpd",endpoint=1,emit=t,data_type=a.Int16,scale=100,read_only=true,read_on_configure=false}),p.cluster_attribute(N,l,{name="sonoff_snzb02b_calculated_humidity_trigger",endpoint=1,emit=t,data_type=a.Uint16,scale=100,read_only=true,read_on_configure=false})},configure=f}h(aA,{T("SONOFF","SNZB-02B")})
local function q(an)
local ar=an and an.body and an.body.zcl_body or nil
local I=ar and(ar.zone_status or ar.zonestatus)or nil
local b=type(I)=="table"and I.value or I
return{raw_value=b,typed_value=I}
end
local aM={profile="sonoff-ws01-rain",zcl_clusters={p.cluster_attribute(C,B,{name="rain",endpoint=1,
emit=function(_,b)
return b=="possiblePrecipitation"and o.precipitationSensor.precipitationIntensity.possiblePrecipitation()or o.precipitationSensor.precipitationIntensity.none()
end,
data_type=a.Bitmap16,
from_device=function(b)
b=type(b)=="table"and b.value or b
if type(b)~="number"then return nil end
return b%2==1 and"possiblePrecipitation"or"none"
end,
command_id=0,command_extractor=q,read_only=true,read_on_configure=false})}}h(aM,{T("eWeLink","WS01")})
local function R(A,aJ)
return p.read_configured_attributes(A,aJ.zcl_clusters)
end
local function Q(D,ah)
return p.battery{endpoint=1,minimum_interval=3600,maximum_interval=D,reportable_change=ah,read_only=true,
from_device=function(b)
if type(b)=="number"and b>=0 and b<127.5 then return b end
end
}
end
local function S(D,ah)
return p.battery_voltage{endpoint=1,minimum_interval=3600,maximum_interval=D,reportable_change=ah,read_only=true,
from_device=function(b)
if type(b)=="number"and b>=0 and b<25.5 then return b end
end
}
end
local ac={profile="sonoff-snzb02-classic-temp-humidity",magic_packet=false,zcl_clusters={p.temperature{endpoint=1,minimum_interval=30,maximum_interval=3600,reportable_change=20,read_on_configure=false,read_only=true,
from_device=function(b)
if type(b)=="number"and b>-33 and b<100 then return b end
end
},p.humidity{endpoint=1,minimum_interval=30,maximum_interval=3600,reportable_change=100,read_on_configure=false,read_only=true,
from_device=function(b)
if type(b)=="number"and b>=0 and b<=100 then return b end
end
},Q(65000,0),S(65000,0)},parent_refresh=R}h(ac,{T("SONOFF","SNZB-02"),T("SONOFF","TH01"),T("SONOFF","CK-TLSR8656-SS5-01(7014)"),T("eWeLink","TH01")})
local function O(aN)
return function(b)
b=type(b)=="table"and b.value or b
if type(b)~="number"or b<0 or b>65535 or b%1~=0 then return nil end
return math.floor(b/(2 ^ aN))%2==1
end
end
local ad={profile="sonoff-snzb04-classic-contact",magic_packet=false,zcl_clusters={p.cluster_attribute(C,B,{name="contact",endpoint=1,emit=as.contact(),data_type=a.Bitmap16,from_device=O(0),command_id=0,command_extractor=q,ias_configure_method=0,read_only=true,read_on_configure=false}),p.cluster_attribute(C,B,{name="battery_low",endpoint=1,
emit=function(_,b)
return b and o.batteryLevel.battery.critical()or o.batteryLevel.battery.normal()
end,
data_type=a.Bitmap16,from_device=O(3),command_id=0,command_extractor=q,ias_configure_method=0,read_only=true,read_on_configure=false}),Q(7200,2),S(7200,100)},parent_refresh=R}h(ad,{T("eWeLink","DS01"),T("SONOFF","SNZB-04"),T("SONOFF","DS01"),T("SONOFF","CK-TLSR8656-SS5-01(7003)")})p.attach_reporting_capabilities(K,{{1,"rpt-slf"},{2,"rpt-spr"},{3,"rpt-sxo"},{4,"rpt-swu"},{5,"rpt-lrf"},{6,"rpt-smq"},{8,"rpt-son"},{9,"rpt-scz"},{11,"rpt-sxh"},{12,"rpt-svu"}})return{id="zcl.sensors.sonoff",registrations=K}
