local function t(q)
local k,K,G,I=require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.constants",require"st.utils.safe_xy_to_hsv"
local function s(g,F)
if type(g)~="table"then
g={}end
if type(F)~="table"then
return g
end
for D,d in pairs(F)do
g[D]=d
end
return g
end
local function o(g,e)
if type(g)~="table"or type(e)~="table"then
return g
end
for D,d in pairs(e)do
if g[D]==nil then
g[D]=d
end
end
return g
end
local function n(f,m)
local h={}if type(f)=="string"then
h.name=f
else
s(h,f)end
s(h,m)return h
end
local function w(L,u,B,C)
local p={}for D,d in pairs(L)do
p[d]=D
end
if type(C)=="table"then
for J,g in pairs(C)do
if p[g]~=nil then
p[J]=p[g]end
end
end
return{
from=function(d)
local v=L[d]if v~=nil then
return v
end
if u~=nil then
return u
end
return d
end,
to=function(d)
local v=p[d]if v~=nil then
return v
end
if B~=nil then
return B
end
return d
end
}
end
local function r()
return w{[0]="off",[1]="auto",[3]="cool",[4]="heat",[5]="emergency heat"}
end
local function j()
return{
from=function(d)
local l=d
if type(d)=="table"then
if type(d.is_heat_on_set)=="function"and(d:is_heat_on_set()or(type(d.is_heat_second_stage_on_set)=="function"and d:is_heat_second_stage_on_set()))then
return"heating"end
if type(d.is_cool_on_set)=="function"and(d:is_cool_on_set()or(type(d.is_cool_second_stage_on_set)=="function"and d:is_cool_second_stage_on_set()))then
return"cooling"end
if type(d.is_fan_on_set)=="function"and(d:is_fan_on_set()or
(type(d.is_fan_second_stage_on_set)=="function"and d:is_fan_second_stage_on_set())or
(type(d.is_fan_third_stage_on_set)=="function"and d:is_fan_third_stage_on_set()))then
return"fan only"end
l=d.value
end
if type(l)~="number"then
return l
end
if(l&9)~=0 then
return"heating"end
if(l&18)~=0 then
return"cooling"end
if(l&100)~=0 then
return"fan only"end
return"idle"
end
}
end
local function a(A,z,x)
return{minimum_interval=A,maximum_interval=z,reportable_change=x,read_on_configure=true}
end
local function c(...)
local E={}for _,e in ipairs{...}do
o(E,e)end
return E
end
local function b(M,H,y)
q[M]=function(f,m)
local h=n(f,m)local i,e=h.configure_reporting,y(h)
h.configure_reporting=nil
if i==false then
e.minimum_interval=nil
e.maximum_interval=nil
e.reportable_change=nil
e.physical_reportable_change=nil
e.reporting_defaults=nil
end
o(h,e)return H(h)
end
end
b("humidity",q.relative_humidity,function()
return c({emit=k.humidity(),scale=100},a(30,300,100))
end)
b("battery",q.power_configuration_battery,function()
return c({emit=k.battery(),scale=2},a(300,21600,2))
end)
b("switch",q.on_off,function(m)
local i=m.configure_reporting
m.configure_reporting=nil
if i==false then
return{emit=k.switch()}end
return c({emit=k.switch()},a(0,300,nil))
end)
b("power",q.electrical_measurement_power,function()
return c({emit=k.power(),metering_kind="power",poll_interval=300},a(5,300,1))
end)
b("current",q.electrical_measurement_current,function()
return c({emit=k.current(),scale=1000,metering_kind="current",poll_interval=300},a(5,300,1))
end)
b("voltage",q.electrical_measurement_voltage,function()
return c({emit=k.voltage(),metering_kind="voltage",poll_interval=300},a(5,300,1))
end)
b("energy",q.simple_metering,function()
return{emit=k.energy(),read_on_configure=true,metering_kind="energy",poll_interval=900}
end)
b("local_temperature",q.thermostat_local_temperature,function()
return c({emit=k.temperature"C",scale=100},a(30,300,50))
end)
b("heating_setpoint",q.thermostat_heating_setpoint,function()
return c({name="current_heating_setpoint",emit=k.heating_setpoint"C",scale=100},a(30,300,50))
end)
b("system_mode",q.thermostat_system_mode,function()
return c({emit=k.thermostat_mode(),converter=r()},a(1,300,nil))
end)
b("cooling_setpoint",q.thermostat_cooling_setpoint,function()
return c({name="current_cooling_setpoint",emit=k.cooling_setpoint"C",scale=100},a(30,300,50))
end)
b("thermostat_operating_state",q.thermostat_running_state,function()
return c({name="thermostat_operating_state",emit=k.thermostat_operating_state(),converter=j()},a(1,300,nil))
end)
end
return t
