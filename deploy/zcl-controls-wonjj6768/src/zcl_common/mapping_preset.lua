local function z(q)
local x,w,s,U=require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.constants",require"st.utils.safe_xy_to_hsv"
local function y(l,R)
if type(l)~="table"then
l={}end
if type(R)~="table"then
return l
end
for O,d in pairs(R)do
l[O]=d
end
return l
end
local function m(l,b)
if type(l)~="table"or type(b)~="table"then
return l
end
for O,d in pairs(b)do
if l[O]==nil then
l[O]=d
end
end
return l
end
local function o(T,...)
local D=x[T]if type(D)=="function"then
return D(...)end
return nil
end
local function f(a,j)
local c={}if type(a)=="string"then
c.name=a
else
y(c,a)end
y(c,j)return c
end
local function n(W,B,J,N)
local v={}for O,d in pairs(W)do
v[d]=O
end
if type(N)=="table"then
for V,l in pairs(N)do
if v[l]~=nil then
v[V]=v[l]end
end
end
return{
from=function(d)
local C=W[d]if C~=nil then
return C
end
if B~=nil then
return B
end
return d
end,
to=function(d)
local C=v[d]if C~=nil then
return C
end
if J~=nil then
return J
end
return d
end
}
end
local function u()
return n({[0]="off",[1]="on",[2]="previous"},nil,nil,{restore="previous"})
end
local function I()
return n{[0]="switch",[1]="scene"}
end
local function A()
return n{[0]="command",[1]="event"}
end
local function p(P,M,b)
return function(a,j)
local c,K=f(a,j),b.converter_factory()m(c,{name=b.name,emit=b.emit,converter=K,
to_device=function(d)
return K.to(d)
end,
data_type=w.Enum8,write_type=w.Enum8,attribute_name=b.attribute_name,mfg_code=b.mfg_code,read_on_configure=true})return q.cluster_attribute(P,M,c)
end
end
local function t(S)
return{
from=function(d)
if type(d)=="table"then
if S==1 then
if type(d.is_alarm1_set)=="function"and d:is_alarm1_set()then
return true
end
if type(d.is_alarm2_set)=="function"and d:is_alarm2_set()then
return true
end
elseif S==4 and type(d.is_tamper_set)=="function"then
return d:is_tamper_set()elseif d.value~=nil then
d=d.value
else
return d
end
end
if type(d)~="number"then
return d
end
return(d&S)~=0
end
}
end
local function k(L)
local r=L and L.body and L.body.zcl_body and L.body.zcl_body.zone_status or nil
if r==nil then
return nil
end
return{raw_value=r.value or r,typed_value=r}
end
local function e(H,G,E)
return{minimum_interval=H,maximum_interval=G,reportable_change=E,read_on_configure=true}
end
local function i(...)
local Q={}for _,b in ipairs{...}do
m(Q,b)end
return Q
end
local function g(T,D,F)
q[T]=function(a,j)
local c=f(a,j)local h,b=c.configure_reporting,F(c)
c.configure_reporting=nil
if h==false then
b.minimum_interval=nil
b.maximum_interval=nil
b.reportable_change=nil
b.physical_reportable_change=nil
b.reporting_defaults=nil
end
m(c,b)return D(c)
end
end
g("battery",q.power_configuration_battery,function()
return i({emit=x.battery(),scale=2},e(300,21600,2))
end)
g("switch",q.on_off,function(j)
local h=j.configure_reporting
j.configure_reporting=nil
if h==false then
return{emit=x.switch()}end
return i({emit=x.switch()},e(0,300,nil))
end)
q.power_on_behavior=p(q.CLUSTER_ON_OFF,32770,{name="power_on_behavior",emit=o"power_on_behavior",attribute_name="tuyaPowerOnBehavior",converter_factory=u})
q.tuya_magic_packet=function(a,j)
local c=f(a,j)m(c,{name="tuya_magic_packet",read_only=true,read_on_configure=true})return q.cluster_attribute(0,65534,c)
end
q.operation_mode=function(a,j)
local c=f(a,j)m(c,{name="operation_mode",emit=o"operation_mode",converter=A(),data_type=w.Enum8,attribute_name="tuyaOperationMode",read_on_configure=true})return q.cluster_attribute(q.CLUSTER_ON_OFF,32772,c)
end
q.switch_mode=p(57345,53248,{name="switch_mode",emit=o"switch_mode",attribute_name="tuyaSwitchMode",mfg_code=4417,converter_factory=I})
g("power",q.electrical_measurement_power,function()
return i({emit=x.power(),metering_kind="power",poll_interval=300},e(5,300,1))
end)
g("current",q.electrical_measurement_current,function()
return i({emit=x.current(),scale=1000,metering_kind="current",poll_interval=300},e(5,300,1))
end)
g("voltage",q.electrical_measurement_voltage,function()
return i({emit=x.voltage(),metering_kind="voltage",poll_interval=300},e(5,300,1))
end)
g("energy",q.simple_metering,function()
return{emit=x.energy(),read_on_configure=true,metering_kind="energy",poll_interval=900}
end)
g("tamper",q.ias_zone,function()
return i({name="tamper",emit=x.tamper(),converter=t(4),ias_configure_method=s.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=k},e(0,300,nil))
end)
g("battery_low",q.ias_zone,function(j)
local h=j.configure_reporting
j.configure_reporting=nil
local b={name="battery_low",emit=o"battery_low",converter=t(8),ias_configure_method=s.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=k,read_on_configure=true}if h==false then
return b
end
return i(b,e(0,300,nil))
end)
end
return z
