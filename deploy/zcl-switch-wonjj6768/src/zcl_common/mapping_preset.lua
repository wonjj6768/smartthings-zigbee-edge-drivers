local function R(p)
local N,A,az,aD=require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.constants",require"st.utils.safe_xy_to_hsv"
local function P(v,au)
if type(v)~="table"then
v={}end
if type(au)~="table"then
return v
end
for F,h in pairs(au)do
v[F]=h
end
return v
end
local function n(v,g)
if type(v)~="table"or type(g)~="table"then
return v
end
for F,h in pairs(g)do
if v[F]==nil then
v[F]=h
end
end
return v
end
local function d(ay,...)
local U=N[ay]if type(U)=="function"then
return U(...)end
return nil
end
local function f(a,c)
local e={}if type(a)=="string"then
e.name=a
else
P(e,a)end
P(e,c)return e
end
local function s(aH,S,aa,an)
local M={}for F,h in pairs(aH)do
M[h]=F
end
if type(an)=="table"then
for aF,v in pairs(an)do
if M[v]~=nil then
M[aF]=M[v]end
end
end
return{
from=function(h)
local T=aH[h]if T~=nil then
return T
end
if S~=nil then
return S
end
return h
end,
to=function(h)
local T=M[h]if T~=nil then
return T
end
if aa~=nil then
return aa
end
return h
end
}
end
local function ak(h,ai,ah)
if h<ai then
return ai
end
if h>ah then
return ah
end
return h
end
local function Q()
return s({[0]="off",[1]="off/on",[2]="on/off",[3]="on"},nil,nil,{off_on="off/on",on_off="on/off",normal="off/on",inverted="on/off"})
end
local function E()
return s({[0]="off",[1]="on",[2]="previous"},nil,nil,{restore="previous"})
end
local function J()
return s({[0]="off",[1]="on",[2]="restore"},nil,nil,{previous="restore"})
end
local function Z()
return s{[0]="toggle",[1]="state",[2]="momentary"}
end
local function G()
return s{[0]="momentary",[1]="toggle",[2]="state"}
end
local function D()
return s{[0]="off",[1]="on"}
end
local function encode_uint16_le(h)
local q=math.floor(ak(tonumber(h)or 0,0,65535)+0.5)return string.char(q&255,(q>>8)&255)
end
local function encode_uint32_be(h)
local q=math.floor(ak(tonumber(h)or 0,0,0xFFFFFFFF)+0.5)return string.char((q>>24)&255,(q>>16)&255,(q>>8)&255,q&255)
end
local function m(ao,al,g)
return function(a,c)
local e,ae=f(a,c),g.converter_factory()n(e,{name=g.name,emit=g.emit,converter=ae,
to_device=function(h)
return ae.to(h)
end,
data_type=A.Enum8,write_type=A.Enum8,attribute_name=g.attribute_name,mfg_code=g.mfg_code,read_on_configure=true})return p.cluster_attribute(ao,al,e)
end
end
local function H(I,aj,ad,aB)
if type(I)=="table"and type(I.get_latest_state)=="function"then
local as=I:get_latest_state("main",aj,ad)if as~=nil then
return as
end
end
return aB
end
local function K(x)
local i=x and x.body and x.body.zcl_body and x.body.zcl_body.body_bytes or nil
if type(i)~="string"or #i<4 then
return nil
end
local L,O={},1
while O+3<=#i do
local F=string.byte(i,O)if F==nil then
break
end
L[F]={state=string.byte(i,O+1)or 0,value=(((string.byte(i,O+2)or 0)*256)+(string.byte(i,O+3)or 0))}O=O+4
end
return L
end
local function b(ap,F,aG)
return function(x)
local ac=x and x.body and x.body.zcl_header and x.body.zcl_header.cmd and x.body.zcl_header.cmd.value or nil
if ac~=ap then
return nil
end
local L=K(x)local aq=type(L)=="table"and L[F]or nil
if type(aq)~="table"then
return nil
end
if aG=="state"then
return aq.state
end
return aq.value
end
end
local function C(x)
local i=x and x.body and x.body.zcl_body and x.body.zcl_body.body_bytes or nil
if type(i)~="string"or #i<12 then
return nil
end
local aA,ag,F=string.byte(i,3),string.byte(i,7),string.byte(i,8)if aA~=10 or F~=11 or(ag~=5 and ag~=6)then
return nil
end
local aE=((string.byte(i,9)or 0)*16777216)+
((string.byte(i,10)or 0)*65536)+
((string.byte(i,11)or 0)*256)+
(string.byte(i,12)or 0)return math.floor(aE/60+0.5)
end
local function B(F,am,ab)
local q=tonumber(ab)if type(q)~="number"then
return nil
end
q=math.floor(q+0.5)if q<0 then
q=0
elseif q>65535 then
q=65535
end
local ar=am=="on"and 1 or 0
return string.char(F,ar,(q>>8)&255,q&255)
end
local function l(F,y,w)
return function(h,I)
local ar=H(I,y,w,"off")return B(F,ar,h)
end
end
local function j(F,y,w)
return function(h,I)
local av=H(I,y,w,0)return B(F,h,av)
end
end
local function r(Y,X,V)
return{minimum_interval=Y,maximum_interval=X,reportable_change=V,read_on_configure=true}
end
local function u(...)
local at={}for _,g in ipairs{...}do
n(at,g)end
return at
end
local function t(ay,U,W)
p[ay]=function(a,c)
local e=f(a,c)local z,g=e.configure_reporting,W(e)
e.configure_reporting=nil
if z==false then
g.minimum_interval=nil
g.maximum_interval=nil
g.reportable_change=nil
g.physical_reportable_change=nil
g.reporting_defaults=nil
end
n(e,g)return U(e)
end
end
t("temperature",p.temperature_measurement,function()
return u({emit=N.temperature"C",scale=100},r(30,300,50))
end)
t("battery",p.power_configuration_battery,function()
return u({emit=N.battery(),scale=2},r(300,21600,2))
end)
t("switch",p.on_off,function(c)
local z=c.configure_reporting
c.configure_reporting=nil
if z==false then
return{emit=N.switch()}end
return u({emit=N.switch()},r(0,300,nil))
end)
p.indicator_mode=m(p.CLUSTER_ON_OFF,32769,{name="indicator_mode",emit=d"indicator_mode",attribute_name="tuyaBacklightMode",converter_factory=Q})p.power_on_behavior=m(p.CLUSTER_ON_OFF,32770,{name="power_on_behavior",emit=d"power_on_behavior",attribute_name="tuyaPowerOnBehavior",converter_factory=E})p.power_outage_memory=m(p.CLUSTER_ON_OFF,32770,{name="power_on_behavior",emit=d"power_on_behavior",attribute_name="moesStartUpOnOff",converter_factory=E})p.tuya_power_outage_memory=m(p.CLUSTER_ON_OFF,32770,{name="power_outage_memory",emit=d"power_outage_memory",attribute_name="moesStartUpOnOff",converter_factory=J})
p.child_lock=function(a,c)
local e=f(a,c)n(e,{name="child_lock",emit=d"childLock",
from_device=function(h)
return h and"on"or"off"
end,
to_device=function(h)
return h==true or h=="on"or h=="lock"or h=="LOCK"
end,
data_type=A.Boolean,write_type=A.Boolean,attribute_name="tuyaChildLock",read_on_configure=true})return p.cluster_attribute(p.CLUSTER_ON_OFF,32768,e)
end
p.tuya_magic_packet=function(a,c)
local e=f(a,c)n(e,{name="tuya_magic_packet",read_only=true,read_on_configure=true})return p.cluster_attribute(0,65534,e)
end
p.switch_type=m(57345,53296,{name="switch_type",emit=d"switch_type",attribute_name="tuyaExternalSwitchType",mfg_code=4417,converter_factory=Z})p.gen_on_off_switch_type=m(p.CLUSTER_ON_OFF,32769,{name="switch_type",emit=d"switch_type",attribute_name="tuyaExternalSwitchType",mfg_code=4417,converter_factory=G})
p.countdown_timer=function(a,c)
local e=f(a,c)n(e,{name="countdown_timer",emit=d("countdownTimerZclTwelveHours","s"),data_type=A.Uint16,write_type=A.Uint16,tx_command_id=66,
to_device=function(h)
local af=ak(tonumber(h)or 0,0,43200)return string.char(0)..encode_uint16_le(af)..encode_uint16_le(af)
end,
numeric_range={minimum=0,maximum=43200,step=1,unit="s"},attribute_name="onTime",read_on_configure=true})return p.cluster_attribute(p.CLUSTER_ON_OFF,16385,e)
end
p.ts0049_countdown_timer=function(a,c)
local e=f(a,c)n(e,{name="countdown_timer",emit=d("valveCountdownTs0049Minutes","min"),tx_command_id=254,command_id=10,command_extractor=C,
to_device=function(h)
local aC=math.floor(ak(tonumber(h)or 0,0,255)+0.5)return string.char(11)..encode_uint32_be(aC*60)
end,
numeric_range={minimum=0,maximum=255,step=1,unit="min"},attribute_name="tuyaTs0049Countdown",read_on_configure=false})return p.cluster_attribute(57345,111,e)
end
local function o(a,c,g)
local e=f(a,c)n(e,g)return p.cluster_attribute(57345,g.attribute_id,e)
end
local function k(a,c,g)
local e=f(a,c)n(e,g)return p.cluster_attribute(57345,g.attribute_id,e)
end
p.temperature_threshold=function(a,c)
return o(a,c,{name="temperature_threshold",emit=d"temperature_threshold",tx_command_id=230,command_id=230,command_extractor=b(230,5,"value"),to_device=l(5,"concertmirror08464.temperatureBreaker","temperatureBreaker"),attribute_id=61701})
end
p.temperature_breaker=function(a,c)
return k(a,c,{name="temperature_breaker",emit=d"temperature_breaker",converter=D(),tx_command_id=230,command_id=230,command_extractor=b(230,5,"state"),to_device=j(5,"concertmirror08464.temperatureThreshold","temperatureThreshold"),attribute_id=61829})
end
p.power_threshold=function(a,c)
return o(a,c,{name="power_threshold",emit=d"power_threshold",tx_command_id=230,command_id=230,command_extractor=b(230,7,"value"),to_device=l(7,"concertmirror08464.powerBreaker","powerBreaker"),attribute_id=61703})
end
p.power_breaker=function(a,c)
return k(a,c,{name="power_breaker",emit=d"power_breaker",converter=D(),tx_command_id=230,command_id=230,command_extractor=b(230,7,"state"),to_device=j(7,"concertmirror08464.powerThreshold","powerThreshold"),attribute_id=61831})
end
p.over_current_threshold=function(a,c)
return o(a,c,{name="over_current_threshold",emit=d"over_current_threshold",tx_command_id=231,command_id=231,command_extractor=b(231,1,"value"),to_device=l(1,"concertmirror08464.overCurrentBreaker","overCurrentBreaker"),attribute_id=61697})
end
p.over_current_breaker=function(a,c)
return k(a,c,{name="over_current_breaker",emit=d"over_current_breaker",converter=D(),tx_command_id=231,command_id=231,command_extractor=b(231,1,"state"),to_device=j(1,"concertmirror08464.overCurrentThreshold","overCurrentThreshold"),attribute_id=61825})
end
p.over_voltage_threshold=function(a,c)
return o(a,c,{name="over_voltage_threshold",emit=d"over_voltage_threshold",tx_command_id=231,command_id=231,command_extractor=b(231,3,"value"),to_device=l(3,"concertmirror08464.overVoltageBreaker","overVoltageBreaker"),attribute_id=61699})
end
p.over_voltage_breaker=function(a,c)
return k(a,c,{name="over_voltage_breaker",emit=d"over_voltage_breaker",converter=D(),tx_command_id=231,command_id=231,command_extractor=b(231,3,"state"),to_device=j(3,"concertmirror08464.overVoltageThreshold","overVoltageThreshold"),attribute_id=61827})
end
p.under_voltage_threshold=function(a,c)
return o(a,c,{name="under_voltage_threshold",emit=d"under_voltage_threshold",tx_command_id=231,command_id=231,command_extractor=b(231,4,"value"),to_device=l(4,"concertmirror08464.underVoltageBreaker","underVoltageBreaker"),attribute_id=61700})
end
p.under_voltage_breaker=function(a,c)
return k(a,c,{name="under_voltage_breaker",emit=d"under_voltage_breaker",converter=D(),tx_command_id=231,command_id=231,command_extractor=b(231,4,"state"),to_device=j(4,"concertmirror08464.underVoltageThreshold","underVoltageThreshold"),attribute_id=61828})
end
t("power",p.electrical_measurement_power,function()
return u({emit=N.power(),metering_kind="power",poll_interval=300},r(5,300,1))
end)
t("current",p.electrical_measurement_current,function()
return u({emit=N.current(),scale=1000,metering_kind="current",poll_interval=300},r(5,300,1))
end)
t("voltage",p.electrical_measurement_voltage,function()
return u({emit=N.voltage(),metering_kind="voltage",poll_interval=300},r(5,300,1))
end)
t("energy",p.simple_metering,function()
return{emit=N.energy(),read_on_configure=true,metering_kind="energy",poll_interval=900}
end)
end
return R
