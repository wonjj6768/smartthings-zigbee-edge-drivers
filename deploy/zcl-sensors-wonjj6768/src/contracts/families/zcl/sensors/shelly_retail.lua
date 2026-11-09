local j,g,I,B,x,aa=require"protocol.zcl",require"contracts.helpers.family",require"contracts.helpers.zcl",require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.device_management"local G,d=g.definition_registry()
local function o(ai,an)
return function(aQ,c)
for endpoint=1,ai do
local ab={j.CLUSTER_ON_OFF,j.CLUSTER_ELECTRICAL_MEASUREMENT,j.CLUSTER_SIMPLE_METERING}if an then table.insert(ab,2,j.CLUSTER_LEVEL_CONTROL)end
for _,aw in ipairs(ab)do
c:send(aa.build_bind_request(c,aw,aQ.environment_info.hub_zigbee_eui,endpoint))end
end
end
end
local as,R={profile="plugs-switch-power-energy-voltage-current",zcl_clusters=I.metering_clusters{include_switch=true,include_current=true,use_reported_unity_scaler=true},configure=o(1,false)},{profile="plugs-shelly-power-strip-4",zcl_clusters={},configure=o(4,false)}for endpoint=1,4 do
local F=endpoint==1 and"main"or("switch"..endpoint)for _,cluster in ipairs{j.switch{endpoint=endpoint,component=F},j.power{endpoint=endpoint,component=F},j.energy{endpoint=endpoint,component=F},j.voltage{endpoint=endpoint,component=F},j.current{endpoint=endpoint,component=F}}do
R.zcl_clusters[#R.zcl_clusters+1]=cluster
end
end
local aq,at={profile="lights-dimmer-power-voltage-current",zcl_clusters={j.switch(),j.level(),j.power(),j.voltage(),j.current(),j.energy()},configure=o(1,true)},{profile="safety-water-leak-tamper-battery-low-battery-hardware-fault-shelly",zcl_clusters={j.water(),j.tamper(),j.battery_low(),j.hardware_fault(),j.battery()}}
local function n(b,_,f)
if f.raw_value~=255 then return b end
end
local ao={profile="sensors-temp-humidity-battery-shelly-ht",capability_commands={{capability_id="concertmirror08464.shellyHtIdentify",command_name="identify",mapping_name="shelly_ht_identify",value=3},{capability_id="concertmirror08464.shellyHtIdentify",command_name="setIdentifyTime",argument_name="identifyTime",mapping_name="shelly_ht_identify"}},protocol_writers={shelly_ht_identify=I.identify},zcl_clusters={j.temperature{minimum_interval=10,maximum_interval=3600,reportable_change=100},j.humidity{minimum_interval=10,maximum_interval=3600,reportable_change=100,
from_device=function(b,_,f)
if f.raw_value~=65535 then return b end
end},
j.battery{minimum_interval=3600,maximum_interval=65000,reportable_change=10,from_device=n}}}
local function z(c,aO,J,i,ay,ac)
if aO~=0 then return true end
if J==nil then return false end
local E=c:get_latest_state("main",J,i)return not(type(E)=="number"and(ac and math.abs(E)or E)>ay)
end
local function m(aj,J,i,ay,ac)
local av=j.mapping_meta(aj,false).from_device
aj.from_device=function(b,c,f,ax)
if not z(c,f.raw_value,J,i,ay,ac)then return nil end
if av then return av(b,c,f,ax)end
return b
end
return aj
end
local function s(c,f)
local ak=f.zb_rx
local ap=ak and ak.body and ak.body.zcl_body
local e
for _,l in ipairs(ap and ap.attr_records or{})do
if l.attr_id.value==1 and(not l.status or l.status.value==0)and
l.data_type and l.data_type.value==34 and l.data then
e=l.data.value
end
end
local E=c:get_latest_state("main","concertmirror08464.shellyWs90Precipitation","precipitation")return e==0 and type(E)=="number"and E>0,e
end
local function k(b)
if b==0 then return b end
local az=math.floor(b)local af=b-az<0.5 and az or az+1
return af==0 and b<0 and-0.0 or af
end
local function al(a,D)
if a==nil or D==nil or D<=0 then return nil end
local aM=17.27*a/(237.7+a)+math.log(D/100)return k(237.7*aM/(17.27-aM)*10)/10
end
local function au(a,H)
if H==nil then return nil end
local C=6.11*math.exp(5417.753*(1/273.15-1/(273.15+H)))return k((a+0.5555*(C-10))*10)/10
end
local function ah(a,ad)
if a==nil or ad==nil then return nil end
local aE=ad*3.6
if a>10 or aE<4.8 then return k(a*10)/10 end
return k((13.12+0.6215*a-11.37*aE ^ 0.16+0.3965*a*aE ^ 0.16)*10)/10
end
local function ae(h)
local aW=h.temperature+(h.illuminance or 0)/100/100+(h.humidity or 0)/10
local aJ=aW-(h.wind_speed or 0)/2-((h.precipitation or 0)>0 and 3 or 0)return math.max(k(100/(1+math.exp(1)^(-4*((aJ-18)/24-0.5)))),0)
end
local function K(a,y,L)
if a==nil then return nil end
if y~=nil and y<a then return y end
if L~=nil and L>a then return L end
return k(a*10)/10
end
local function am(p,e,Q)
if e==nil then return nil end
local q=p.precipHistory
if q and Q-q.time<60000 then return nil end
p.precipHistory={value=e,time=Q}if not q then return 0 end
local aP,aH=Q-q.time,e-q.value
if aH<0 then return 0 end
return math.min(k(aH/(aP/3600000)*10)/10,300)
end
local function Y(p,C,Q)
local q=p.pressureHistory
if q and Q-q.time<1800000 then return nil end
p.pressureHistory={value=C,time=Q}if not q then return 0 end
return k((C-q.value)/((Q-q.time)/3600000)*10)/10
end
local function U(h)
local a,aI,ad,aA,C,ag=h.temperature,h.illuminance,h.wind_speed,h.rain_rate,h.pressure,h.pressure_trend
if aI==nil then return nil end
local Z,aF=h.rain_status==true and aA and aA>0,ad and ad>10

local aX=Z and aA>5 and aI<5000 and ad and ad>5 and
((C and C<1000)or(ag and ag<-2))if aX then return"hail"end
if Z and a and a<1 then return"snowy"end
if Z and aA>10 then return"pouring"end
if Z then return"rainy"end
if aI<10 then return aF and"windy"or"clear-night"end
if aI>40000 then return aF and"windy"or"sunny"end
if aI>10000 then return aF and"windy-variant"or"partlycloudy"end
return"cloudy"
end
local function T(p,t,Q,aR)
p.state=p.state or{}if aR then t.rain_rate=am(p,t.precipitation,Q)or 0 end
for aZ,b in pairs(t)do p.state[aZ]=b end
local h=p.state
local a,D=h.temperature,h.humidity
local H=al(a,D)local L,y=au(a,H),ah(a,h.wind_speed)if h.pressure~=nil then
local ag=Y(p,h.pressure,Q)if ag~=nil then h.pressure_trend=ag end
end
local af,aD={dew_point=H,humidex=L,heat_stress=a and D and ae(h)or nil,wind_chill=y,apparent_temperature=K(a,y,L),pressure_trend=h.pressure and h.pressure_trend or nil,weather_condition=U(h),rain_rate=aR and t.rain_rate or nil},p.lastSave==nil or Q-p.lastSave>=60000
if aD then p.lastSave=Q end
return af,aD
end
local N,S,W={dew_point=B.shellyWs90DewPoint(),wind_chill=B.shellyWs90WindChill(),humidex=B.shellyWs90Humidex(),apparent_temperature=B.shellyWs90ApparentTemp(),heat_stress=B.shellyWs90HeatStress(),rain_rate=B.shellyWs90RainRate(),pressure_trend=B.shellyWs90PressureTrend(),weather_condition=B.shellyWs90WeatherCondition()},{[1026]={[0]={"temperature",41,100}},[1029]={[0]={"humidity",33,100}},[1027]={[0]={"pressure",41,10}},[1024]={[0]={"illuminance",33,1}},[64513]={[0]={"wind_speed",33,10,65535},[4]={"wind_direction",33,10,65535},[7]={"gust_speed",33,10,65535}},[64514]={[0]={"uv_index",32,10,255}},[64515]={[0]={"rain_status",16,1},[1]={"precipitation",34,10,0xFFFFFF}}},{[1026]={"temperatureMeasurement","temperature",2,true},[1029]={"relativeHumidityMeasurement","humidity",5},[1024]={"illuminanceMeasurement","illuminance",50},[1027]={}}
local function O(c,rx,aL)
local V,ap=rx.body and rx.body.zcl_header,rx.body and rx.body.zcl_body
if V==nil then return end
if(V.frame_ctrl.value&3)~=0 or(V.cmd.value~=1 and V.cmd.value~=10)or not ap.attr_records then return end
local cluster=rx.address_header.cluster.value
local ar=S[cluster]if ar==nil then return end
local f={zb_rx=rx,src_endpoint=rx.address_header.src_endpoint.value,mfg_code=V.mfg_code and V.mfg_code.value}if cluster==64515 and s(c,f)then return end
local aO,recognized={},false
for _,l in ipairs(ap.attr_records)do
local i=l.attr_id.value
local P=ar[i]if P and(not l.status or l.status.value==0)and l.data and l.data_type and
l.data_type.value==P[2]and #j.find_mappings(aL,cluster,i,c,f)>0 then
aO[i],recognized=l.data.value,true
end
end
if not recognized then return end
local t={}for i,b in pairs(aO)do
local P,aT=ar[i],W[cluster]if aT and not z(c,b,table.unpack(aT))then return end
if b~=P[4]then
if P[1]=="rain_status"then t.rain_status=b==true or b==1
elseif P[1]=="illuminance"then t.illuminance=b>0 and k(10 ^((b-1)/10000))or 0
else t[P[1]]=b/P[3]end
end
end
if cluster==64514 and next(t)==nil then return end
local p=c:get_field"__ws90_calculated"if p==nil then
p=require"st.utils".deep_copy(c:get_field"ws90:calculated"or{})c:set_field("__ws90_calculated",p)end
local Q=math.floor(require"cosock.socket".gettime()*1000)local aS,aD=T(p,t,Q,cluster==64515)if aD then c:set_field("ws90:calculated",require"st.utils".deep_copy(p),{persist=true})end
for aY,b in pairs(aS)do
if type(b)~="number"or(b==b and b~=math.huge and b~=-math.huge)then
local aN=N[aY](c,b)if aN then c:emit_event(aN)end
end
end
end
local function r(cluster,i,M)
M.minimum_interval,M.maximum_interval=10,3600
M.reportable_change,M.read_on_configure,M.read_only=1,true,true
return j.cluster_attribute(cluster,i,M)
end
local X,A="concertmirror08464.shellyWs90Identify",{cluster=1,attribute=32,data_type=x.Uint8,minimum_interval=300,maximum_interval=21600,reportable_change=1}local u
u={profile="sensors-weather-temp-humidity-pressure-illuminance-battery-ws90",capability_commands={{capability_id=X,command_name="identify",mapping_name="shelly_ws90_identify",value=3},{capability_id=X,command_name="setIdentifyTime",argument_name="identifyTime",mapping_name="shelly_ws90_identify"}},
zigbee_message_handler=function(c,rx)
O(c,rx,u.zcl_clusters)
end,
configure=function(_,c)
c:remove_configured_attribute(1,32)if c:get_field"zcl_reporting:zr00010020auto"~=nil then
j.configure_reporting(c,A,c:get_endpoint(1),{auto_endpoint=true})end
end,
zcl_clusters={m(j.temperature{minimum_interval=10,maximum_interval=3600,reportable_change=100},"temperatureMeasurement","temperature",2,true),m(j.humidity{minimum_interval=10,maximum_interval=3600,reportable_change=100},"relativeHumidityMeasurement","humidity",5),m(j.pressure{minimum_interval=10,maximum_interval=3600,reportable_change=5,read_only=true}),m(j.illuminance{minimum_interval=10,maximum_interval=3600,reportable_change=5},"illuminanceMeasurement","illuminance",50),j.battery{minimum_interval=3600,maximum_interval=65000,reportable_change=10,from_device=n},j.battery_voltage{from_device=n,configure_reporting=false,reporting_defaults=A},r(1,64,{name="ws90_capacitor_voltage",endpoint=1,data_type=x.Uint8,scale=10,emit=B.shellyWs90CapacitorVoltage()}),r(64514,0,{name="ws90_uv_index",emit=B.shellyWs90UvIndex(),data_type=x.Uint8,scale=10,from_device=n,mfg_code=5264}),r(64515,0,{name="ws90_rain_status",emit=B.ws90RainStatus(),data_type=x.Boolean,mfg_code=5264,
from_device=function(b,c,f)
if s(c,f)then return nil end
return b and"raining"or"dry"
end
}),m(r(64515,1,{name="ws90_precipitation",emit=B.shellyWs90Precipitation(),data_type=x.Uint24,scale=10,
from_device=function(b,c,f)
local aG,e=s(c,f)if aG or(e~=nil and f.raw_value~=e)then return nil end
if f.raw_value~=0xFFFFFF then return b end
end,
mfg_code=5264}),"concertmirror08464.shellyWs90Precipitation","precipitation",0),j.cluster_attribute(3,0,{name="shelly_ws90_identify",endpoint=1,write_only=true,suppress_optimistic_state=true,tx_command_id=0,
to_device=function(b)
if type(b)~="number"or b%1~=0 or b<1 or b>30 then return nil end
return string.pack("<I2",b)
end})
}}for aU,aK in ipairs{{0,"ws90_wind_speed",B.shellyWs90WindSpeed()},{4,"ws90_wind_direction",B.ws90WindDirection()},{7,"ws90_gust_speed",B.shellyWs90GustSpeed()}}do
table.insert(u.zcl_clusters,7+aU,r(64513,aK[1],{name=aK[2],emit=aK[3],data_type=x.Uint16,scale=10,
from_device=function(b,_,f)if f.raw_value~=65535 then return b end end,
mfg_code=5264}))end
d(as,{g.create_fingerprint("Shelly","Plug US")})d(R,{g.create_fingerprint("Shelly","Power Strip")})d(aq,{g.create_fingerprint("Shelly","Dimmer"),g.create_fingerprint("Shelly","Dimmer US")})d(at,{g.create_fingerprint("Shelly","Flood"),g.create_fingerprint("Shelly","Flood S")})d(ao,{g.create_fingerprint("Shelly","BLU H&T ZB")})d(u,{g.create_fingerprint("Shelly","Ecowitt WS90")})j.attach_reporting_capabilities(G,{{1,"rpt-tcb"},{2,"rpt-pob",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree",zr000600004="SwitchFour",zr0b0405051="Voltage",zr0b0405052="VoltageTwo",zr0b0405053="VoltageThree",zr0b0405054="VoltageFour",zr0b0405081="Current",zr0b0405082="CurrentTwo",zr0b0405083="CurrentThree",zr0b0405084="CurrentFour",zr0b04050b1="Power",zr0b04050b2="PowerTwo",zr0b04050b3="PowerThree",zr0b04050b4="PowerFour"}},{3,"rpt-hll"},{4,"rpt-fwi"},{5,"rpt-bsz"},{6,"rpt-ead"}})return{id="zcl.sensors.shelly_retail",registrations=G}
