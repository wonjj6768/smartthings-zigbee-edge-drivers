local function w(p)
local m,M,g,L=require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.constants",require"st.utils.safe_xy_to_hsv"
local function v(r,G)
if type(r)~="table"then
r={}end
if type(G)~="table"then
return r
end
for K,f in pairs(G)do
r[K]=f
end
return r
end
local function n(r,j)
if type(r)~="table"or type(j)~="table"then
return r
end
for K,f in pairs(j)do
if r[K]==nil then
r[K]=f
end
end
return r
end
local function D(J,...)
local y=m[J]if type(y)=="function"then
return y(...)end
return nil
end
local function q(l,k)
local h={}if type(l)=="string"then
h.name=l
else
v(h,l)end
v(h,k)return h
end
local function o()
return{
from=function(f)
if type(f)~="number"then
return f
end
if f<=0 then
return 0
end
local N=10 ^((f-1)/10000)return math.floor(N+0.5)
end,
to=function(f)
if type(f)~="number"then
return f
end
if f<=0 then
return 0
end
local O=10000*(math.log(f)/math.log(10))+1
return math.floor(O+0.5)
end
}
end
local function i(I)
return{
from=function(f)
if type(f)=="table"then
if I==1 then
if type(f.is_alarm1_set)=="function"and f:is_alarm1_set()then
return true
end
if type(f.is_alarm2_set)=="function"and f:is_alarm2_set()then
return true
end
elseif I==4 and type(f.is_tamper_set)=="function"then
return f:is_tamper_set()elseif f.value~=nil then
f=f.value
else
return f
end
end
if type(f)~="number"then
return f
end
return(f&I)~=0
end
}
end
local function t()
return{
from=function(f)
local u
local x
if type(f)=="table"then
if type(f.is_alarm1_set)=="function"then u=f:is_alarm1_set()end
if type(f.is_alarm2_set)=="function"then x=f:is_alarm2_set()end
if u==nil and f.value~=nil then f=f.value end
end
if type(f)=="number"then
u=(f&1)~=0
x=(f&2)~=0
end
if u==nil or x==nil then return f end
if not u and not x then return"closed"end
if u and not x then return"tilted"end
return"open"
end
}
end
local function b(E)
local s=E and E.body and E.body.zcl_body and E.body.zcl_body.zone_status or nil
if s==nil then
return nil
end
return{raw_value=s.value or s,typed_value=s}
end
local function a(C,B,z)
return{minimum_interval=C,maximum_interval=B,reportable_change=z,read_on_configure=true}
end
local function c(...)
local F={}for _,j in ipairs{...}do
n(F,j)end
return F
end
local function d(J,y,A)
p[J]=function(l,k)
local h=q(l,k)local e,j=h.configure_reporting,A(h)
h.configure_reporting=nil
if e==false then
j.minimum_interval=nil
j.maximum_interval=nil
j.reportable_change=nil
j.physical_reportable_change=nil
j.reporting_defaults=nil
end
n(h,j)return y(h)
end
end
d("temperature",p.temperature_measurement,function()
return c({emit=m.temperature"C",scale=100},a(30,300,50))
end)
d("humidity",p.relative_humidity,function()
return c({emit=m.humidity(),scale=100},a(30,300,100))
end)
d("battery",p.power_configuration_battery,function()
return c({emit=m.battery(),scale=2},a(300,21600,2))
end)
d("battery_voltage",p.power_configuration_battery_voltage,function()
return c({emit=m.voltage(),scale=10},a(300,21600,1))
end)
d("switch",p.on_off,function(k)
local e=k.configure_reporting
k.configure_reporting=nil
if e==false then
return{emit=m.switch()}end
return c({emit=m.switch()},a(0,300,nil))
end)
d("illuminance",p.illuminance_measurement,function(k)
local e=k.configure_reporting
k.configure_reporting=nil
if e==false then
return{emit=m.illuminance(),converter=o(),read_on_configure=true}end
return c({emit=m.illuminance(),converter=o()},a(30,300,100))
end)
p.occupancy=function(l,k)
local h=q(l,k)local H,e=h.ias_zone==true,h.configure_reporting

h.ias_zone=nil
h.configure_reporting=nil
if H then
n(h,c({name="occupancy",emit=m.occupancy(),converter=i(1),ias_configure_method=g.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b},a(30,300,nil)))return p.ias_zone(h)end
if e==false then
n(h,{emit=m.occupancy(),read_on_configure=true})return p.occupancy_sensing(h)end
n(h,c({emit=m.occupancy()},a(0,300,nil)))return p.occupancy_sensing(h)
end
d("power",p.electrical_measurement_power,function()
return c({emit=m.power(),metering_kind="power",poll_interval=300},a(5,300,1))
end)
d("current",p.electrical_measurement_current,function()
return c({emit=m.current(),scale=1000,metering_kind="current",poll_interval=300},a(5,300,1))
end)
d("voltage",p.electrical_measurement_voltage,function()
return c({emit=m.voltage(),metering_kind="voltage",poll_interval=300},a(5,300,1))
end)
d("energy",p.simple_metering,function()
return{emit=m.energy(),read_on_configure=true,metering_kind="energy",poll_interval=900}
end)
d("contact",p.ias_zone,function()
return c({name="contact",emit=m.contact(),converter=i(1),ias_configure_method=g.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b},a(30,300,nil))
end)
d("contact_alarm_1_or_2",p.ias_zone,function()
return c({name="contact",emit=m.contact(),converter=i(3),ias_configure_method=g.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b},a(30,300,nil))
end)
d("shelly_handle_position",p.ias_zone,function(k)
return c({name="shelly_handle_position",emit=k.emit or m.shellyBluDoorHandlePosition(),converter=t(),ias_configure_method=g.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b},a(30,300,nil))
end)
d("water",p.ias_zone,function()
return c({name="water",emit=m.water(),converter=i(1),ias_configure_method=g.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b},a(0,300,nil))
end)
d("smoke",p.ias_zone,function()
return c({name="smoke",emit=m.smoke(),converter=i(1),ias_configure_method=g.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b},a(0,180,nil))
end)
d("carbon_monoxide",p.ias_zone,function()
return c({name="carbon_monoxide",emit=m.carbon_monoxide(),converter=i(1),ias_configure_method=g.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b},a(0,180,nil))
end)
d("motion",p.ias_zone,function(k)
local e=k.configure_reporting
k.configure_reporting=nil
local j={name="motion",emit=m.motion(),converter=i(1),ias_configure_method=g.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b,read_on_configure=true}if e==false then
return j
end
return c(j,a(30,300,nil))
end)
d("tamper",p.ias_zone,function()
return c({name="tamper",emit=m.tamper(),converter=i(4),ias_configure_method=g.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b},a(0,300,nil))
end)
d("battery_low",p.ias_zone,function(k)
local e=k.configure_reporting
k.configure_reporting=nil
local j={name="battery_low",emit=D"battery_low",converter=i(8),ias_configure_method=g.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b,read_on_configure=true}if e==false then
return j
end
return c(j,a(0,300,nil))
end)
d("alarm",p.ias_zone,function()
return c({name="alarm",emit=m.alarm(),converter=i(1),ias_configure_method=g.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b},a(0,300,nil))
end)
end
return w
