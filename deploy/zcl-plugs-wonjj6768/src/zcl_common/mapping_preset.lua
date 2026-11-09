local function v(p)
local B,l,S,U=require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.constants",require"st.utils.safe_xy_to_hsv"
local function t(i,P)
if type(i)~="table"then
i={}end
if type(P)~="table"then
return i
end
for L,c in pairs(P)do
i[L]=c
end
return i
end
local function g(i,d)
if type(i)~="table"or type(d)~="table"then
return i
end
for L,c in pairs(d)do
if i[L]==nil then
i[L]=c
end
end
return i
end
local function n(R,...)
local y=B[R]if type(y)=="function"then
return y(...)end
return nil
end
local function e(a,f)
local b={}if type(a)=="string"then
b.name=a
else
t(b,a)end
t(b,f)return b
end
local function q(W,w,E,K)
local s={}for L,c in pairs(W)do
s[c]=L
end
if type(K)=="table"then
for V,i in pairs(K)do
if s[i]~=nil then
s[V]=s[i]end
end
end
return{
from=function(c)
local x=W[c]if x~=nil then
return x
end
if w~=nil then
return w
end
return c
end,
to=function(c)
local x=s[c]if x~=nil then
return x
end
if E~=nil then
return E
end
return c
end
}
end
local function T(c,I,H)
if c<I then
return I
end
if c>H then
return H
end
return c
end
local function u()
return q({[0]="off",[1]="off/on",[2]="on/off",[3]="on"},nil,nil,{off_on="off/on",on_off="on/off",normal="off/on",inverted="on/off"})
end
local function r()
return q({[0]="off",[1]="on",[2]="restore"},nil,nil,{previous="restore"})
end
local function encode_uint16_le(c)
local M=math.floor(T(tonumber(c)or 0,0,65535)+0.5)return string.char(M&255,(M>>8)&255)
end
local function o(N,J,d)
return function(a,f)
local b,F=e(a,f),d.converter_factory()g(b,{name=d.name,emit=d.emit,converter=F,
to_device=function(c)
return F.to(c)
end,
data_type=l.Enum8,write_type=l.Enum8,attribute_name=d.attribute_name,mfg_code=d.mfg_code,read_on_configure=true})return p.cluster_attribute(N,J,b)
end
end
local function h(D,C,z)
return{minimum_interval=D,maximum_interval=C,reportable_change=z,read_on_configure=true}
end
local function m(...)
local O={}for _,d in ipairs{...}do
g(O,d)end
return O
end
local function j(R,y,A)
p[R]=function(a,f)
local b=e(a,f)local k,d=b.configure_reporting,A(b)
b.configure_reporting=nil
if k==false then
d.minimum_interval=nil
d.maximum_interval=nil
d.reportable_change=nil
d.physical_reportable_change=nil
d.reporting_defaults=nil
end
g(b,d)return y(b)
end
end
j("switch",p.on_off,function(f)
local k=f.configure_reporting
f.configure_reporting=nil
if k==false then
return{emit=B.switch()}end
return m({emit=B.switch()},h(0,300,nil))
end)
p.indicator_mode=o(p.CLUSTER_ON_OFF,32769,{name="indicator_mode",emit=n"indicator_mode",attribute_name="tuyaBacklightMode",converter_factory=u})p.tuya_power_outage_memory=o(p.CLUSTER_ON_OFF,32770,{name="power_outage_memory",emit=n"power_outage_memory",attribute_name="moesStartUpOnOff",converter_factory=r})
p.child_lock=function(a,f)
local b=e(a,f)g(b,{name="child_lock",emit=n"childLock",
from_device=function(c)
return c and"on"or"off"
end,
to_device=function(c)
return c==true or c=="on"or c=="lock"or c=="LOCK"
end,
data_type=l.Boolean,write_type=l.Boolean,attribute_name="tuyaChildLock",read_on_configure=true})return p.cluster_attribute(p.CLUSTER_ON_OFF,32768,b)
end
p.tuya_magic_packet=function(a,f)
local b=e(a,f)g(b,{name="tuya_magic_packet",read_only=true,read_on_configure=true})return p.cluster_attribute(0,65534,b)
end
p.countdown_timer=function(a,f)
local b=e(a,f)g(b,{name="countdown_timer",emit=n("countdownTimerZclTwelveHours","s"),data_type=l.Uint16,write_type=l.Uint16,tx_command_id=66,
to_device=function(c)
local G=T(tonumber(c)or 0,0,43200)return string.char(0)..encode_uint16_le(G)..encode_uint16_le(G)
end,
numeric_range={minimum=0,maximum=43200,step=1,unit="s"},attribute_name="onTime",read_on_configure=true})return p.cluster_attribute(p.CLUSTER_ON_OFF,16385,b)
end
j("power",p.electrical_measurement_power,function()
return m({emit=B.power(),metering_kind="power",poll_interval=300},h(5,300,1))
end)
j("current",p.electrical_measurement_current,function()
return m({emit=B.current(),scale=1000,metering_kind="current",poll_interval=300},h(5,300,1))
end)
j("voltage",p.electrical_measurement_voltage,function()
return m({emit=B.voltage(),metering_kind="voltage",poll_interval=300},h(5,300,1))
end)
j("energy",p.simple_metering,function()
return{emit=B.energy(),read_on_configure=true,metering_kind="energy",poll_interval=900}
end)
end
return v
