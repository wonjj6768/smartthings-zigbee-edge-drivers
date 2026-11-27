local N,aC,R,aB,e,aa,V,K,y,I,u,aq=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.capabilities",require"st.zigbee.data_types",require"st.zigbee.cluster_base",require"st.zigbee.device_management",require"st.zigbee.messages",require"st.zigbee.zcl",require"st.zigbee.generic_body",require"st.zigbee.constants",require"log"local l,ad=R.definition_registry()local d,p,g,P,Z,j,i={},{},64529,4742,"concertmirror08464.","sonoff_ul_",{sunny=0,partly_cloudy=1,overcast=2,rain=3,snow=4,windy=5}

local function v(id)
return assert(aC[id],"Missing SNZB-02UL emitter: "..id)()
end
local function Q(id,attribute,A)
p[#p+1]={capability_id=Z..id,command_name="set"..attribute:sub(1,1):upper()..attribute:sub(2),argument_name=attribute,mapping_name=A}
end
local function F(tx)
tx.body.zcl_header.frame_ctrl:set_disable_default_response()return tx:to_endpoint(1)
end
local function aE(a,attribute)
a:send(F(aa.read_attribute(a,e.ClusterId(g),e.AttributeId(attribute))))
end
local function Y(a,attribute,b)
a:send(F(aa.write_attribute(a,e.ClusterId(g),e.AttributeId(attribute),b)))
end
local function h(id,attribute,af,J,ar,ab,w)
local A,at=j ..attribute,v(id)

local aD=w and function(b)return w[b]end or nil
local ak=N.cluster_attribute(g,af,{name=A,endpoint=1,data_type=J,write_type=J,scale=w and 1 or 100,from_device=aD,emit=at,read_on_configure=true,
sender=function(a,_,b)
local z
if w then
for U,aw in pairs(w)do if aw==b then z=U end end
elseif type(b)=="number"and b==b and b>=ar and b<=ab then
z=math.floor(b*10+0.5)*10
end
if z==nil then return false end
aq.info(string.format("SNZB-02UL setting %s=%s; waiting for device readback",attribute,tostring(b)))Y(a,af,J(z))aE(a,af)return true
end
})d[#d+1]=ak
Q(id,attribute,A)
end
local function X(a,id,attribute,b)
a:set_field(j ..attribute,b,{persist=true})a:emit_event(v(id)(a,b))
end
local function k(J,ay,payload)
return string.char(J,0,ay,#payload)..payload
end
local function x(a,ah)
local body=table.concat(ah)local bytes=string.char(1,1,0,3,#body+1,#ah)..body
local payload=string.pack("<I2BBI2",24606,72,32,#bytes)..bytes
local tx=K.ZigbeeMessageTx{address_header=K.AddressHeader(u.HUB.ADDR,u.HUB.ENDPOINT,a:get_short_address(),1,u.HA_PROFILE_ID,g),body=y.ZclMessageBody{zcl_header=y.ZclHeader{cmd=e.ZCLCommandId(2)},zcl_body=I.GenericBody(payload)}}a:send(F(tx))
end
local function n(id,attribute,as)
local A=j ..attribute
d[#d+1]=N.cluster_attribute(g,24606,{name=A,endpoint=1,write_only=true,read_on_configure=false,read_on_refresh=false,sender=as})Q(id,attribute,A)
end
local o,r=j .."measured_temperature",j .."measured_humidity"
local function L(au)
return function(a,b)a:set_field(au,b,{persist=false})end
end
local function ai(b,am)
local H=10 ^ am
return(b<0 and math.ceil(b*H-0.5)or math.floor(b*H+0.5))/H
end
local function T(a)
local f,s=a:get_field(o),a:get_field(r)if type(f)~="number"or type(s)~="number"then return end
local W=0.61078*math.exp(17.27*f/(f+237.3))local G={v"sonoffUlVpd"(a,ai(W*(1-s/100),2))}if s>0 then
local ag=17.27*f/(f+237.7)+math.log(s/100)G[#G+1]=aB.dewPoint.dewpoint{value=ai(237.7*ag/(17.27-ag),1),unit="C"}end
return G
end
d[#d+1]=N.temperature{endpoint=1,minimum_interval=5,maximum_interval=1800,reportable_change=20,read_only=true,handler=L(o)}d[#d+1]=N.humidity{endpoint=1,minimum_interval=5,maximum_interval=1800,reportable_change=100,read_only=true,handler=L(r)}d[#d+1]=N.battery{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_only=true}for _,M in ipairs{{1026,e.Int16},{1029,e.Uint16}}do
d[#d+1]=N.cluster_attribute(M[1],0,{name=j .."calculated_"..tostring(M[1]),endpoint=1,data_type=M[2],scale=100,read_only=true,read_on_configure=false,read_on_refresh=false,emit=T})end
h("sonoffUlComfortTempMin","comfortTempMin",4,e.Int16,0,50)h("sonoffUlComfortTempMax","comfortTempMax",3,e.Int16,0,50)h("sonoffUlComfortHumidityMin","comfortHumidityMin",5,e.Uint16,5,95)h("sonoffUlComfortHumidityMax","comfortHumidityMax",6,e.Uint16,5,95)h("sonoffUlTempCal","temperatureCalibration",8195,e.Int16,-50,50)h("sonoffUlHumidityCal","humidityCalibration",8196,e.Int16,-50,50)h("sonoffUlTempUnits","temperatureUnits",7,e.Uint16,nil,nil,{[0]="celsius",[1]="fahrenheit"})local t={{"sonoffUlRemoteTemp","remoteTemperature",0,-20,60,"<i2"},{"sonoffUlRemoteHumidity","remoteHumidity",1,5,95,"<I2"},{"sonoffUlRemotePressure","remotePressure",2,700,1100,"<i4"}}for _,av in ipairs(t)do
local id,attribute,O,ar,ab,ao=table.unpack(av)
n(id,attribute,function(a,_,b)
if type(b)~="number"or b~=b or b<ar or b>ab then return false end
if a:get_field(j .."remoteMode")~="disable"then
local aF=math.floor(b*100+0.5)x(a,{k(O,1,string.pack(ao,aF))})end
X(a,id,attribute,b)return true
end)
end
n("sonoffUlRemoteMode","remoteMode",function(a,_,b)
if b~="enable"and b~="disable"then return false end
if b=="disable"then
x(a,{k(0,0,""),k(1,0,""),k(2,0,"")})end
X(a,"sonoffUlRemoteMode","remoteMode",b)return true
end)
local function q(a,b,D)
local tx=aa.build_manufacturer_specific_command(a,g,20,P,string.char(0,1,b))local m=tx.body.zcl_header
if D then
m.seqno=e.Uint8(D.seqno.value)if D.frame_ctrl.value&8==0 then m.frame_ctrl:set_direction_client()end
end
a:send(F(tx))
end
n("sonoffUlWeather","weatherIcon",function(a,_,b)
local U=i[b]if U==nil then return false end
q(a,U)X(a,"sonoffUlWeather","weatherIcon",b)return true
end)
local function al(a,rx)
if rx.address_header.src_endpoint.value~=1 or rx.address_header.cluster.value~=g then return end
local m=rx.body.zcl_header
if m.cmd.value~=20 or m.frame_ctrl.value&3~=1 then return end
if m.mfg_code and m.mfg_code.value~=P then return end
local bytes=rx.body.zcl_body.body_bytes
if type(bytes)~="string"or #bytes~=9 or bytes:byte(1)~=0 then return end
local icon=a:get_field(j .."weatherIcon")if i[icon]==nil then
aq.info"SNZB-02UL weather request: no icon selected"return
end
q(a,i[icon],m)aq.info("SNZB-02UL weather request answered with saved icon: "..icon)
end
local S={}
S.sonoff_ul_weather_updates=function(a)
Y(a,20502,e.Int32(114057900))Y(a,20503,e.Int32(22543100))return true
end
p[#p+1]={capability_id=Z.."sonoffUlWeatherUpdates",command_name="enableUpdates",mapping_name="sonoff_ul_weather_updates"}ad({profile="sonoff-snzb02ul-environment",package_group="sonoff-ul",magic_packet=false,initial_custom_state_query=false,zcl_clusters=d,capability_commands=p,protocol_writers=S,zigbee_message_handler=al,
runtime_start=function(a)
for _,item in ipairs(t)do
local b=a:get_field(j ..item[2])if b~=nil then a:emit_event(v(item[1])(a,b))end
end
for _,item in ipairs{{"sonoffUlRemoteMode","remoteMode"},{"sonoffUlWeather","weatherIcon"}}do
local b=a:get_field(j ..item[2])if b~=nil then a:emit_event(v(item[1])(a,b))end
end
end,
configure=function(an,a)
for _,aj in ipairs{32,6}do
a:send(V.build_bind_request(a,aj,an.environment_info.hub_zigbee_eui,1))end
end
},{R.create_fingerprint("SONOFF","SNZB-02UL")})N.attach_reporting_capabilities(l,{{1,"rpt-sgl"}})return{id="zcl.sensors.sonoff_ul",registrations=l}
