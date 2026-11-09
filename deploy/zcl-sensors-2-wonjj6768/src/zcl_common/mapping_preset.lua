local function u(r)
local q,J,j,I=require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.constants",require"st.utils.safe_xy_to_hsv"
local function t(p,D)
if type(p)~="table"then
p={}end
if type(D)~="table"then
return p
end
for H,h in pairs(D)do
p[H]=h
end
return p
end
local function m(p,i)
if type(p)~="table"or type(i)~="table"then
return p
end
for H,h in pairs(i)do
if p[H]==nil then
p[H]=h
end
end
return p
end
local function A(G,...)
local v=q[G]if type(v)=="function"then
return v(...)end
return nil
end
local function n(g,l)
local d={}if type(g)=="string"then
d.name=g
else
t(d,g)end
t(d,l)return d
end
local function o()
return{
from=function(h)
if type(h)~="number"then
return h
end
if h<=0 then
return 0
end
local K=10 ^((h-1)/10000)return math.floor(K+0.5)
end,
to=function(h)
if type(h)~="number"then
return h
end
if h<=0 then
return 0
end
local L=10000*(math.log(h)/math.log(10))+1
return math.floor(L+0.5)
end
}
end
local function k(F)
return{
from=function(h)
if type(h)=="table"then
if F==1 then
if type(h.is_alarm1_set)=="function"and h:is_alarm1_set()then
return true
end
if type(h.is_alarm2_set)=="function"and h:is_alarm2_set()then
return true
end
elseif F==4 and type(h.is_tamper_set)=="function"then
return h:is_tamper_set()elseif h.value~=nil then
h=h.value
else
return h
end
end
if type(h)~="number"then
return h
end
return(h&F)~=0
end
}
end
local function a(B)
local s=B and B.body and B.body.zcl_body and B.body.zcl_body.zone_status or nil
if s==nil then
return nil
end
return{raw_value=s.value or s,typed_value=s}
end
local function b(z,y,w)
return{minimum_interval=z,maximum_interval=y,reportable_change=w,read_on_configure=true}
end
local function c(...)
local C={}for _,i in ipairs{...}do
m(C,i)end
return C
end
local function f(G,v,x)
r[G]=function(g,l)
local d=n(g,l)local e,i=d.configure_reporting,x(d)
d.configure_reporting=nil
if e==false then
i.minimum_interval=nil
i.maximum_interval=nil
i.reportable_change=nil
i.physical_reportable_change=nil
i.reporting_defaults=nil
end
m(d,i)return v(d)
end
end
f("temperature",r.temperature_measurement,function()
return c({emit=q.temperature"C",scale=100},b(30,300,50))
end)
f("humidity",r.relative_humidity,function()
return c({emit=q.humidity(),scale=100},b(30,300,100))
end)
f("battery",r.power_configuration_battery,function()
return c({emit=q.battery(),scale=2},b(300,21600,2))
end)
f("battery_voltage",r.power_configuration_battery_voltage,function()
return c({emit=q.voltage(),scale=10},b(300,21600,1))
end)
r.tuya_magic_packet=function(g,l)
local d=n(g,l)m(d,{name="tuya_magic_packet",read_only=true,read_on_configure=true})return r.cluster_attribute(0,65534,d)
end
f("illuminance",r.illuminance_measurement,function(l)
local e=l.configure_reporting
l.configure_reporting=nil
if e==false then
return{emit=q.illuminance(),converter=o(),read_on_configure=true}end
return c({emit=q.illuminance(),converter=o()},b(30,300,100))
end)
r.occupancy=function(g,l)
local d=n(g,l)local E,e=d.ias_zone==true,d.configure_reporting

d.ias_zone=nil
d.configure_reporting=nil
if E then
m(d,c({name="occupancy",emit=q.occupancy(),converter=k(1),ias_configure_method=j.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=a},b(30,300,nil)))return r.ias_zone(d)end
if e==false then
m(d,{emit=q.occupancy(),read_on_configure=true})return r.occupancy_sensing(d)end
m(d,c({emit=q.occupancy()},b(0,300,nil)))return r.occupancy_sensing(d)
end
f("contact",r.ias_zone,function()
return c({name="contact",emit=q.contact(),converter=k(1),ias_configure_method=j.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=a},b(30,300,nil))
end)
f("water",r.ias_zone,function()
return c({name="water",emit=q.water(),converter=k(1),ias_configure_method=j.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=a},b(0,300,nil))
end)
f("smoke",r.ias_zone,function()
return c({name="smoke",emit=q.smoke(),converter=k(1),ias_configure_method=j.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=a},b(0,180,nil))
end)
f("carbon_monoxide",r.ias_zone,function()
return c({name="carbon_monoxide",emit=q.carbon_monoxide(),converter=k(1),ias_configure_method=j.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=a},b(0,180,nil))
end)
f("motion",r.ias_zone,function(l)
local e=l.configure_reporting
l.configure_reporting=nil
local i={name="motion",emit=q.motion(),converter=k(1),ias_configure_method=j.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=a,read_on_configure=true}if e==false then
return i
end
return c(i,b(30,300,nil))
end)
f("tamper",r.ias_zone,function()
return c({name="tamper",emit=q.tamper(),converter=k(4),ias_configure_method=j.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=a},b(0,300,nil))
end)
f("battery_low",r.ias_zone,function(l)
local e=l.configure_reporting
l.configure_reporting=nil
local i={name="battery_low",emit=A"battery_low",converter=k(8),ias_configure_method=j.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=a,read_on_configure=true}if e==false then
return i
end
return c(i,b(0,300,nil))
end)
end
return u
