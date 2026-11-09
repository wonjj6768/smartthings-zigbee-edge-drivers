local function z(n)
local j,Y,f,W=require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.constants",require"st.utils.safe_xy_to_hsv"
local function y(q,R)
if type(q)~="table"then
q={}end
if type(R)~="table"then
return q
end
for P,e in pairs(R)do
q[P]=e
end
return q
end
local function o(q,k)
if type(q)~="table"or type(k)~="table"then
return q
end
for P,e in pairs(k)do
if q[P]==nil then
q[P]=e
end
end
return q
end
local function M(U,...)
local D=j[U]if type(D)=="function"then
return D(...)end
return nil
end
local function p(m,l)
local i={}if type(m)=="string"then
i.name=m
else
y(i,m)end
y(i,l)return i
end
local function u(Z,A,I,O)
local w={}for P,e in pairs(Z)do
w[e]=P
end
if type(O)=="table"then
for X,q in pairs(O)do
if w[q]~=nil then
w[X]=w[q]end
end
end
return{
from=function(e)
local C=Z[e]if C~=nil then
return C
end
if A~=nil then
return A
end
return e
end,
to=function(e)
local C=w[e]if C~=nil then
return C
end
if I~=nil then
return I
end
return e
end
}
end
local function V(e,K,J)
if e<K then
return K
end
if e>J then
return J
end
return e
end
local function B()
return{
from=function(e)
if type(e)~="number"then
return e
end
return math.floor(V(e,0,254)*100/254+0.5)
end,
to=function(e)
if type(e)~="number"then
return e
end
return math.floor(V(e,0,100)*254/100+0.5)
end
}
end
local function r()
return{
from=function(e)
if type(e)~="number"then
return e
end
if e<=0 then
return 0
end
local aa=10 ^((e-1)/10000)return math.floor(aa+0.5)
end,
to=function(e)
if type(e)~="number"then
return e
end
if e<=0 then
return 0
end
local ab=10000*(math.log(e)/math.log(10))+1
return math.floor(ab+0.5)
end
}
end
local function x()
return u{[0]="off",[1]="auto",[3]="cool",[4]="heat",[5]="emergency heat"}
end
local function L()
return u{[0]="off",[1]="low",[2]="medium",[3]="high",[4]="on",[5]="auto",[6]="turbo"}
end
local function s()
return{
from=function(e)
local v=e
if type(e)=="table"then
if type(e.is_heat_on_set)=="function"and(e:is_heat_on_set()or(type(e.is_heat_second_stage_on_set)=="function"and e:is_heat_second_stage_on_set()))then
return"heating"end
if type(e.is_cool_on_set)=="function"and(e:is_cool_on_set()or(type(e.is_cool_second_stage_on_set)=="function"and e:is_cool_second_stage_on_set()))then
return"cooling"end
if type(e.is_fan_on_set)=="function"and(e:is_fan_on_set()or
(type(e.is_fan_second_stage_on_set)=="function"and e:is_fan_second_stage_on_set())or
(type(e.is_fan_third_stage_on_set)=="function"and e:is_fan_third_stage_on_set()))then
return"fan only"end
v=e.value
end
if type(v)~="number"then
return v
end
if(v&9)~=0 then
return"heating"end
if(v&18)~=0 then
return"cooling"end
if(v&100)~=0 then
return"fan only"end
return"idle"
end
}
end
local function g(T)
return{
from=function(e)
if type(e)=="table"then
if T==1 then
if type(e.is_alarm1_set)=="function"and e:is_alarm1_set()then
return true
end
if type(e.is_alarm2_set)=="function"and e:is_alarm2_set()then
return true
end
elseif T==4 and type(e.is_tamper_set)=="function"then
return e:is_tamper_set()elseif e.value~=nil then
e=e.value
else
return e
end
end
if type(e)~="number"then
return e
end
return(e&T)~=0
end
}
end
local function b(N)
local t=N and N.body and N.body.zcl_body and N.body.zcl_body.zone_status or nil
if t==nil then
return nil
end
return{raw_value=t.value or t,typed_value=t}
end
local function a(H,G,E)
return{minimum_interval=H,maximum_interval=G,reportable_change=E,read_on_configure=true}
end
local function c(...)
local Q={}for _,k in ipairs{...}do
o(Q,k)end
return Q
end
local function d(U,D,F)
n[U]=function(m,l)
local i=p(m,l)local h,k=i.configure_reporting,F(i)
i.configure_reporting=nil
if h==false then
k.minimum_interval=nil
k.maximum_interval=nil
k.reportable_change=nil
k.physical_reportable_change=nil
k.reporting_defaults=nil
end
o(i,k)return D(i)
end
end
d("temperature",n.temperature_measurement,function()
return c({emit=j.temperature"C",scale=100},a(30,300,50))
end)
d("humidity",n.relative_humidity,function()
return c({emit=j.humidity(),scale=100},a(30,300,100))
end)
d("battery",n.power_configuration_battery,function()
return c({emit=j.battery(),scale=2},a(300,21600,2))
end)
d("battery_voltage",n.power_configuration_battery_voltage,function()
return c({emit=j.voltage(),scale=10},a(300,21600,1))
end)
d("switch",n.on_off,function(l)
local h=l.configure_reporting
l.configure_reporting=nil
if h==false then
return{emit=j.switch()}end
return c({emit=j.switch()},a(0,300,nil))
end)
n.tuya_magic_packet=function(m,l)
local i=p(m,l)o(i,{name="tuya_magic_packet",read_only=true,read_on_configure=true})return n.cluster_attribute(0,65534,i)
end
d("level",n.level_control,function(l)
local h=l.configure_reporting
l.configure_reporting=nil
local k={name="brightness",emit=j.level(),converter=B()}if h==false then return k end
return c(k,a(1,3600,1))
end)
d("illuminance",n.illuminance_measurement,function(l)
local h=l.configure_reporting
l.configure_reporting=nil
if h==false then
return{emit=j.illuminance(),converter=r(),read_on_configure=true}end
return c({emit=j.illuminance(),converter=r()},a(30,300,100))
end)
d("pressure",n.pressure_measurement,function()
return c({emit=j.atmospheric_pressure(),scale=10},a(30,300,1))
end)
n.occupancy=function(m,l)
local i=p(m,l)local S,h=i.ias_zone==true,i.configure_reporting

i.ias_zone=nil
i.configure_reporting=nil
if S then
o(i,c({name="occupancy",emit=j.occupancy(),converter=g(1),ias_configure_method=f.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b},a(30,300,nil)))return n.ias_zone(i)end
if h==false then
o(i,{emit=j.occupancy(),read_on_configure=true})return n.occupancy_sensing(i)end
o(i,c({emit=j.occupancy()},a(0,300,nil)))return n.occupancy_sensing(i)
end
d("power",n.electrical_measurement_power,function()
return c({emit=j.power(),metering_kind="power",poll_interval=300},a(5,300,1))
end)
d("current",n.electrical_measurement_current,function()
return c({emit=j.current(),scale=1000,metering_kind="current",poll_interval=300},a(5,300,1))
end)
d("voltage",n.electrical_measurement_voltage,function()
return c({emit=j.voltage(),metering_kind="voltage",poll_interval=300},a(5,300,1))
end)
d("energy",n.simple_metering,function()
return{emit=j.energy(),read_on_configure=true,metering_kind="energy",poll_interval=900}
end)
d("local_temperature",n.thermostat_local_temperature,function()
return c({emit=j.temperature"C",scale=100},a(30,300,50))
end)
d("heating_setpoint",n.thermostat_heating_setpoint,function()
return c({name="current_heating_setpoint",emit=j.heating_setpoint"C",scale=100},a(30,300,50))
end)
d("system_mode",n.thermostat_system_mode,function()
return c({emit=j.thermostat_mode(),converter=x()},a(1,300,nil))
end)
d("cooling_setpoint",n.thermostat_cooling_setpoint,function()
return c({name="current_cooling_setpoint",emit=j.cooling_setpoint"C",scale=100},a(30,300,50))
end)
d("thermostat_operating_state",n.thermostat_running_state,function()
return c({name="thermostat_operating_state",emit=j.thermostat_operating_state(),converter=s()},a(1,300,nil))
end)
d("local_temperature_calibration",n.thermostat_local_temperature_calibration,function()
return c({emit=j.ecozyLocalTemperatureCalibration(),scale=10},a(1,300,1))
end)
d("pi_heating_demand",n.thermostat_pi_heating_demand,function()
return c({emit=j.ecozyPiHeatingDemand(),read_only=true},a(1,300,1))
end)
d("fan_mode",n.fan_control_mode,function()
return c({name="fan_mode",emit=j.fan_mode(),converter=L()},a(1,300,nil))
end)
d("contact",n.ias_zone,function()
return c({name="contact",emit=j.contact(),converter=g(1),ias_configure_method=f.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b},a(30,300,nil))
end)
d("contact_alarm_1_or_2",n.ias_zone,function()
return c({name="contact",emit=j.contact(),converter=g(3),ias_configure_method=f.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b},a(30,300,nil))
end)
d("water",n.ias_zone,function()
return c({name="water",emit=j.water(),converter=g(1),ias_configure_method=f.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b},a(0,300,nil))
end)
d("water_alarm_1_or_2",n.ias_zone,function()
return c({name="water",emit=j.water(),converter=g(3),ias_configure_method=f.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b},a(0,300,nil))
end)
d("smoke",n.ias_zone,function()
return c({name="smoke",emit=j.smoke(),converter=g(1),ias_configure_method=f.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b},a(0,180,nil))
end)
d("smoke_alarm_1_or_2",n.ias_zone,function()
return c({name="smoke",emit=j.smoke(),converter=g(3),ias_configure_method=f.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b},a(0,300,nil))
end)
d("gas",n.ias_zone,function()
return c({name="gas",emit=j.gas(),converter=g(1),ias_configure_method=f.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b},a(0,300,nil))
end)
d("gas_alarm_2",n.ias_zone,function()
return c({name="gas",emit=j.gas(),converter=g(2),ias_configure_method=f.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b},a(0,300,nil))
end)
d("gas_alarm_1_or_2",n.ias_zone,function()
return c({name="gas",emit=j.gas(),converter=g(3),ias_configure_method=f.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b},a(0,300,nil))
end)
d("carbon_monoxide",n.ias_zone,function()
return c({name="carbon_monoxide",emit=j.carbon_monoxide(),converter=g(1),ias_configure_method=f.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b},a(0,180,nil))
end)
d("carbon_monoxide_alarm_1_or_2",n.ias_zone,function()
return c({name="carbon_monoxide",emit=j.carbon_monoxide(),converter=g(3),ias_configure_method=f.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b},a(0,180,nil))
end)
d("motion",n.ias_zone,function(l)
local h=l.configure_reporting
l.configure_reporting=nil
local k={name="motion",emit=j.motion(),converter=g(1),ias_configure_method=f.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b,read_on_configure=true}if h==false then
return k
end
return c(k,a(30,300,nil))
end)
d("tamper",n.ias_zone,function()
return c({name="tamper",emit=j.tamper(),converter=g(4),ias_configure_method=f.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b},a(0,300,nil))
end)
d("battery_low",n.ias_zone,function(l)
local h=l.configure_reporting
l.configure_reporting=nil
local k={name="battery_low",emit=M"battery_low",converter=g(8),ias_configure_method=f.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b,read_on_configure=true}if h==false then
return k
end
return c(k,a(0,300,nil))
end)
d("hardware_fault",n.ias_zone,function()
return c({name="hardware_fault",emit=j.hardware_fault(),converter=g(64),ias_configure_method=f.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b},a(0,300,nil))
end)
d("alarm",n.ias_zone,function()
return c({name="alarm",emit=j.alarm(),converter=g(1),ias_configure_method=f.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b},a(0,300,nil))
end)
d("alarm_1_or_2",n.ias_zone,function()
return c({name="alarm",emit=j.alarm(),converter=g(3),ias_configure_method=f.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=b},a(0,300,nil))
end)
end
return z
