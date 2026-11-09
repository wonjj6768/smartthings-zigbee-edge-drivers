local al,Y,n,bk,aG,j=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"runtime.gb2312",require"st.zigbee.cluster_base",require"st.zigbee.data_types"local P,h=n.definition_registry()local d,F,E,g,p,f,G,O,z,B,J,H,C,K,q,t,r,as=1796,2,1,257,1030,"concertmirror08464.",946684800,"__easyiot_zl01_timeout_seconds","__easyiot_zl01_timeout_pin","__easyiot_zl01_temp_start","__easyiot_zl01_temp_end","__easyiot_zl01_temp_user","__easyiot_zl01_temp_valid","__easyiot_zl01_temp_pin","__easyiot_24gms02_motion_coefficient","__easyiot_24gms02_hold_coefficient","__easyiot_24gms02_micro_coefficient",{easyiot24gAutoCalibrationProgress=Y.easyiot24gAutoCalibrationProgress(),easyiot24gPirDelay=Y.easyiot24gPirDelay(),easyiot24gUltrasonicOccupiedDelay=Y.easyiot24gUltrasonicOccupiedDelay(),easyiot24gUsUnoccupiedDelay=Y.easyiot24gUsUnoccupiedDelay(),easyiot24gWorkMode=Y.easyiot24gWorkMode(),easyiotIr01LastReceivedCommand=Y.easyiotIr01LastReceivedCommand(),easyiotRs232LastReceivedCommand=Y.easyiotRs232LastReceivedCommand(),easyiotRs485LastReceivedCommand=Y.easyiotRs485LastReceivedCommand(),easyiotTts01LastReceivedStatus=Y.easyiotTts01LastReceivedStatus()}






local function o(aT)
return assert(as[aT],"missing EasyIoT emitter: "..tostring(aT))
end
local function uint16_le(value)
value=math.floor(tonumber(value))return string.char(value%256,math.floor(value/256)%256)
end
local function uint32_le(value)
value=math.floor(tonumber(value))return string.char(value%256,math.floor(value/256)%256,math.floor(value/65536)%256,math.floor(value/16777216)%256)
end
local function uint16_be(value)
value=math.floor(tonumber(value))return string.char(math.floor(value/256)%256,value%256)
end
local function bc(bb,aV)
local aN,aU=0,1

for _=1,8 do
if bb%2~=aV%2 then
aN=aN+aU
end
bb=math.floor(bb/2)aV=math.floor(aV/2)aU=aU*2
end
return aN
end
local function I(ag,aO,aY,value)
local an,ar={ag,aO,aY,value,0},0
for _,ay in ipairs(an)do
ar=bc(ar,ay)end
return string.char(an[1],an[2],an[3],an[4],an[5],ar)
end
local function bh(value)
local aK,W={},1
while W+1<=#value do
local ay=tonumber(string.sub(value,W,W+1),16)if ay==nil then
break
end
aK[#aK+1]=string.char(ay)W=W+2
end
return table.concat(aK)
end
local function i(c,ak,payload,e)
return al.send_raw_cluster_command(c,d,F,uint16_le(ak)..payload,e.endpoint or 1,nil,nil,true)
end
local function l(c,ag,payload,e)
return al.send_raw_cluster_command(c,g,ag,payload,e.endpoint or 1,nil,nil,true)
end
local function m(c,U,value,aX,e)
local ad=aG.write_attribute(c,j.ClusterId(p),j.AttributeId(U),aX(value))ad.body.zcl_header.frame_ctrl:set_disable_default_response()if e.endpoint~=nil and type(ad.to_endpoint)=="function"then
ad=ad:to_endpoint(e.endpoint)end
c:send(ad)return true
end
local function octet_string(value)
return string.char(#value)..value
end
local function ap(N)
local af=N and N.body and N.body.zcl_body and N.body.zcl_body.body_bytes or nil
if type(af)~="string"or #af<2 then
return nil
end
return string.sub(af,3)
end
local function aD(c,bd)
if bd~=nil then
c:emit_component_event({id="main"},bd)end
end
local function s(be)
return function(c,N)
local aj=ap(N)if aj==nil then return false end
local by=(aj:gsub(".",function(ay)
return string.format("%02x",string.byte(ay))
end))
aD(c,be(c,by))return true
end
end
al.register_cluster_command_handler(d,E,function(c,ba,N)
if type(ba.easyiot_tunnel_receiver)~="function"then
return false
end
return ba.easyiot_tunnel_receiver(c,N)
end)
local function y(ak)
return function(c,_,value,e)
if type(value)~="string"or value==""then return false end
return i(c,ak,bh(value),e)
end
end
local function au(c,_,value,e)
local aP=(value==true or value=="on")and 0 or 1
return i(c,0,I(134,1,0,aP),e)
end
local function ac(c,_,value,e)
local aQ=math.floor(tonumber(value))return i(c,0,I(134,1,2,aQ-16),e)
end
local function aA(c,_,value,e)
local encoded=({auto=0,cooling=1,dehumidification=2,air_supply=3,heating=4})[value]if encoded==nil then return false end
return i(c,0,I(134,1,1,encoded),e)
end
local function ah(c,_,value,e)
local encoded=({auto=0,low=1,medium=2,high=3,strong=4})[value]if encoded==nil then return false end
return i(c,0,I(134,1,4,encoded),e)
end
local function az(c,_,value,e)
local bl=math.floor(tonumber(value))local bu,bz=math.floor(bl/256)%256,bl%256

return i(c,0,I(128,1,bu,bz),e)
end
local function aW(c,_,value,e)
if type(value)~="string"or value==""then return false end
local encoded=bk.encode(value)local aC=string.char(253)..uint16_be(#encoded+2)..string.char(1,1)..encoded
return i(c,0,aC,e)
end
local function ae(c,_,value,e)
local bj=({["1200"]=1200,["2400"]=2400,["4800"]=4800,["9600"]=9600,["19200"]=19200,["38400"]=38400,["57600"]=57600,["115200"]=115200,["230400"]=230400,["460800"]=460800,["921600"]=921600})[tostring(value)]if bj==nil then return false end
return i(c,1,string.char(1,2,4,35)..uint32_le(bj),e)
end
local function X(c,_,value,e)
local encoded=({none=0,even=1,odd=2})[value]if encoded==nil then return false end
return i(c,1,string.char(5,2,1,48,encoded),e)
end
local function L(c,_,value,e)
local encoded=({["1"]=0,["1.5"]=1,["2"]=2})[tostring(value)]if encoded==nil then return false end
return i(c,1,string.char(9,2,1,48,encoded),e)
end
local function v(at)
return function(c,_,value)
c:set_field(at,math.floor(tonumber(value)),{persist=true})return true
end
end
local function aw(at,ai)
return function(c,_,value)
if type(value)~="string"then return false end
if ai~=nil and #value>ai then return false end
c:set_field(at,value,{persist=false})return true
end
end
local function x(at,bg,bf)
return function(c,_,value)
if type(value)~="string"or #value<1 or #value>10 or value:match"^[0-9]+$"==nil then
return false
end
local ao=tonumber(value)if ao==nil or ao<bg or ao>bf then return false end
c:set_field(at,ao,{persist=true})return true
end
end
local function A(value)
local aI=0
for _,aZ in utf8.codes(value)do
aI=aI+(aZ>=65536 and 2 or 1)end
return aI
end
local function am(c,_,value,e)
if type(value)~="string"or #value>254 then return false end
local u=string.char(A(value))..value
return l(c,1,octet_string(u),e)
end
local function S(c,_,_,e)
local bi,pin=tonumber(c:get_field(O))or 0,c:get_field(z)
if type(pin)~="string"or #pin>254 then return false end
local u=string.char(A(pin))..pin
local payload=uint32_le(bi)..octet_string(u)return l(c,3,payload,e)
end
local function aa(c,_,_,e)
local av,aH,aR,aq,pin=tonumber(c:get_field(B)),tonumber(c:get_field(J)),tonumber(c:get_field(H)),tonumber(c:get_field(C)),c:get_field(K)if av==nil or aH==nil or aR==nil or aq==nil or
type(pin)~="string"or #pin>255 then
return false
end
local payload=uint32_le(av-G)..uint32_le(aH-G)..uint16_le(aR)..string.char(math.floor(aq))..octet_string(pin)return l(c,182,payload,e)
end
local function Q(c,_,value,e)
return l(c,184,uint16_le(value),e)
end
local function R(c,_,_,e)
return l(c,185,"",e)
end
local function M(c,_,value,e)
local encoded=math.floor((tonumber(value)*10)+0.5)return i(c,1,string.char(7,6,1,32,encoded),e)
end
local function Z(c,_,value,e)
local encoded=({pirOnly=1,radarOnly=2,pirRadarAnd=3,occupied_first=4,unoccupied_first=5})[value]if encoded==nil then return false end
return m(c,65025,encoded,j.Enum8,e)
end
local function w(U)
return function(c,_,value,e)
return m(c,U,math.floor(tonumber(value)),j.Uint16,e)
end
end
local function V(c,_,_,e)
local bm,bv,bp=tonumber(c:get_field(q))or 30,tonumber(c:get_field(t))or 30,tonumber(c:get_field(r))or 30


local payload=string.char(1,6,6,76)..uint16_le(bm)..uint16_le(bv)..uint16_le(bp)return i(c,1,payload,e)
end
local function ab(c,N)
local aj=ap(N)if type(aj)~="string"or #aj<5 then return false end
if string.byte(aj,1)~=3 or string.byte(aj,2)~=6 then return false end
local aM=string.byte(aj,5)if aM>100 then return false end
aD(c,o"easyiot24gAutoCalibrationProgress"(c,aM))return true
end
local function a(aS,aT,bn,T)
T=T or{}T.name=aT
T.write_only=true
T.sender=bn
return al.cluster_attribute(aS,nil,T)
end
local bw,bs,br,bq,bx={profile="controllers-easyiot-ir01",refresh_state_query=false,easyiot_tunnel_receiver=s(o"easyiotIr01LastReceivedCommand"),zcl_clusters={a(d,"easyiot_ir01_send_command",y(0)),a(d,"switch",au),a(d,"easyiot_ir01_ac_temperature",ac,{numeric_range={minimum=16,maximum=32,step=1,unit="C"}}),a(d,"easyiot_ir01_ac_mode",aA),a(d,"easyiot_ir01_ac_wind_speed",ah),a(d,"easyiot_ir01_ac_kfid",az,{numeric_range={minimum=0,maximum=1354,step=1}})},capability_commands={{capability_id=f .."easyiotIr01SendCommand",command_name="sendCommand",argument_name="command",mapping_name="easyiot_ir01_send_command"}}},{profile="controllers-easyiot-tts01",refresh_state_query=false,easyiot_tunnel_receiver=s(o"easyiotTts01LastReceivedStatus"),zcl_clusters={a(d,"easyiot_tts01_send_tts",aW)},capability_commands={{capability_id=f .."easyiotTts01SendTts",command_name="sendTts",argument_name="text",mapping_name="easyiot_tts01_send_tts"}}},{profile="controllers-easyiot-rs485",refresh_state_query=false,easyiot_tunnel_receiver=s(o"easyiotRs485LastReceivedCommand"),zcl_clusters={a(d,"easyiot_rs485_send_command",y(0)),a(d,"easyiot_rs485_baud_rate",ae),a(d,"easyiot_rs485_parity",X),a(d,"easyiot_rs485_stop_bits",L)},capability_commands={{capability_id=f .."easyiotRs485SendCommand",command_name="sendCommand",argument_name="command",mapping_name="easyiot_rs485_send_command"}}},{profile="controllers-easyiot-rs232",refresh_state_query=false,easyiot_tunnel_receiver=s(o"easyiotRs232LastReceivedCommand"),zcl_clusters={a(d,"easyiot_rs232_send_command",y(0)),a(d,"easyiot_rs232_baud_rate",ae),a(d,"easyiot_rs232_parity",X),a(d,"easyiot_rs232_stop_bits",L)},capability_commands={{capability_id=f .."easyiotRs232SendCommand",command_name="sendCommand",argument_name="command",mapping_name="easyiot_rs232_send_command"}}},{profile="locks-easyiot-zl01",refresh_state_query=false,zcl_clusters={al.battery{minimum_interval=30,maximum_interval=1800,reportable_change=1},a(g,"easyiot_zl01_unlock_pin",am),a(g,"easyiot_zl01_timeout_seconds",x(O,0,4294967295)),a(g,"easyiot_zl01_timeout_pin",aw(z,254)),a(g,"easyiot_zl01_unlock_timeout",S),a(g,"easyiot_zl01_temp_start",x(B,946684800,5241652095)),a(g,"easyiot_zl01_temp_end",x(J,946684800,5241652095)),a(g,"easyiot_zl01_temp_user",v(H),{numeric_range={minimum=1,maximum=20,step=1}}),a(g,"easyiot_zl01_temp_valid",v(C),{numeric_range={minimum=0,maximum=255,step=1}}),a(g,"easyiot_zl01_temp_pin",aw(K,255)),a(g,"easyiot_zl01_temp_apply",aa),a(g,"easyiot_zl01_temp_clear_user",Q,{numeric_range={minimum=1,maximum=20,step=1}}),a(g,"easyiot_zl01_temp_clear_all",R)},capability_commands={{capability_id=f .."easyiotZl01UnlockPin",command_name="unlockDoor",argument_name="pin",mapping_name="easyiot_zl01_unlock_pin"},{capability_id=f .."easyiotZl01TimeoutDecimal",command_name="setTimeoutDecimal",argument_name="timeoutSeconds",mapping_name="easyiot_zl01_timeout_seconds"},{capability_id=f .."easyiotZl01TimeoutPin",command_name="setTimeoutPin",argument_name="pin",mapping_name="easyiot_zl01_timeout_pin"},{capability_id=f .."easyiotZl01UnlockTimeout",command_name="unlockWithTimeout",value=true,mapping_name="easyiot_zl01_unlock_timeout"},{capability_id=f .."easyiotZl01TempStartDecimal",command_name="setTempStartDecimal",argument_name="unixSeconds",mapping_name="easyiot_zl01_temp_start"},{capability_id=f .."easyiotZl01TempEndDecimal",command_name="setTempEndDecimal",argument_name="unixSeconds",mapping_name="easyiot_zl01_temp_end"},{capability_id=f .."easyiotZl01TempPin",command_name="setTemporaryPin",argument_name="pin",mapping_name="easyiot_zl01_temp_pin"},{capability_id=f .."easyiotZl01TempApply",command_name="applyTemporaryPin",value=true,mapping_name="easyiot_zl01_temp_apply"},{capability_id=f .."easyiotZl01TempClearAll",command_name="clearAllTemporaryPins",value=true,mapping_name="easyiot_zl01_temp_clear_all"}}}local bo={profile="safety-occupancy-easyiot-24gms02",easyiot_tunnel_receiver=ab,zcl_clusters={
(function()
local aB=al.occupancy_sensing{name="occupancy",emit=Y.occupancy(),data_type=j.Bitmap8,configure_reporting=false,read_on_configure=false,
from_device=function(value)
if type(value)=="table"then value=value.value end
return type(value)=="number"and value%2==1 or value==true
end
}aB.configure_reporting=false
aB.read_on_configure=false
return aB
end)(),
a(d,"easyiot_24g_detection_range",M,{numeric_range={minimum=0.7,maximum=10,step=0.1}}),al.cluster_attribute(p,65025,{name="easyiot_24g_work_mode",emit=o"easyiot24gWorkMode",
from_device=function(value)
return({[1]="pirOnly",[2]="radarOnly",[3]="pirRadarAnd",[4]="occupied_first",[5]="unoccupied_first"})[value]
end,
data_type=j.Enum8,write_type=j.Enum8,sender=Z}),al.cluster_attribute(p,17,{name="easyiot_24g_pir_delay",emit=o"easyiot24gPirDelay",data_type=j.Uint16,write_type=j.Uint16,numeric_range={minimum=0,maximum=65534,step=1},sender=w(17)}),al.cluster_attribute(p,32,{name="easyiot_24g_ultrasonic_occupied_delay",emit=o"easyiot24gUltrasonicOccupiedDelay",data_type=j.Uint16,write_type=j.Uint16,numeric_range={minimum=0,maximum=65534,step=1},sender=w(32)}),al.cluster_attribute(p,33,{name="easyiot_24g_ultrasonic_unoccupied_delay",emit=o"easyiot24gUsUnoccupiedDelay",data_type=j.Uint16,write_type=j.Uint16,numeric_range={minimum=0,maximum=65534,step=1},sender=w(33)}),a(d,"easyiot_24g_motion_coefficient",v(q),{numeric_range={minimum=10,maximum=200,step=1}}),a(d,"easyiot_24g_hold_coefficient",v(t),{numeric_range={minimum=10,maximum=200,step=1}}),a(d,"easyiot_24g_micro_coefficient",v(r),{numeric_range={minimum=10,maximum=200,step=1}}),a(d,"easyiot_24g_auto_calibration",V)},capability_commands={{capability_id=f .."easyiot24gAutoCalibration",command_name="startAutoCalibration",value=true,mapping_name="easyiot_24g_auto_calibration"}}}h(bw,{n.create_fingerprint("easyiot","ZB-IR01")})h(bs,{n.create_fingerprint("easyiot","ZB-TTS01")})h(br,{n.create_fingerprint("easyiot","ZB-RS485")})h(bq,{n.create_fingerprint("easyiot","ZB-RS232")})h(bx,{n.create_fingerprint("easyiot","ZB-ZL01")})h(bo,{n.create_fingerprint("easyiot","ZB-24GMS02")})al.attach_reporting_capabilities(P,{{5,"rpt-zcr"}})return{id="zcl.easyiot.absorption",registrations=P}
