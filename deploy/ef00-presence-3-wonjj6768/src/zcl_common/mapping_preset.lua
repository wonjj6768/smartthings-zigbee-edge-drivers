local function s(y)
local v,H,p,G=require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.constants",require"st.utils.safe_xy_to_hsv"
local function r(m,B)
if type(m)~="table"then
m={}end
if type(B)~="table"then
return m
end
for E,c in pairs(B)do
m[E]=c
end
return m
end
local function h(m,d)
if type(m)~="table"or type(d)~="table"then
return m
end
for E,c in pairs(d)do
if m[E]==nil then
m[E]=c
end
end
return m
end
local function l(e,k)
local a={}if type(e)=="string"then
a.name=e
else
r(a,e)end
r(a,k)return a
end
local function i()
return{
from=function(c)
if type(c)~="number"then
return c
end
if c<=0 then
return 0
end
local J=10 ^((c-1)/10000)return math.floor(J+0.5)
end,
to=function(c)
if type(c)~="number"then
return c
end
if c<=0 then
return 0
end
local K=10000*(math.log(c)/math.log(10))+1
return math.floor(K+0.5)
end
}
end
local function q(D)
return{
from=function(c)
if type(c)=="table"then
if D==1 then
if type(c.is_alarm1_set)=="function"and c:is_alarm1_set()then
return true
end
if type(c.is_alarm2_set)=="function"and c:is_alarm2_set()then
return true
end
elseif D==4 and type(c.is_tamper_set)=="function"then
return c:is_tamper_set()elseif c.value~=nil then
c=c.value
else
return c
end
end
if type(c)~="number"then
return c
end
return(c&D)~=0
end
}
end
local function g(z)
local n=z and z.body and z.body.zcl_body and z.body.zcl_body.zone_status or nil
if n==nil then
return nil
end
return{raw_value=n.value or n,typed_value=n}
end
local function f(x,w,t)
return{minimum_interval=x,maximum_interval=w,reportable_change=t,read_on_configure=true}
end
local function j(...)
local A={}for _,d in ipairs{...}do
h(A,d)end
return A
end
local function o(I,F,u)
y[I]=function(e,k)
local a=l(e,k)local b,d=a.configure_reporting,u(a)
a.configure_reporting=nil
if b==false then
d.minimum_interval=nil
d.maximum_interval=nil
d.reportable_change=nil
d.physical_reportable_change=nil
d.reporting_defaults=nil
end
h(a,d)return F(a)
end
end
o("battery",y.power_configuration_battery,function()
return j({emit=v.battery(),scale=2},f(300,21600,2))
end)
o("illuminance",y.illuminance_measurement,function(k)
local b=k.configure_reporting
k.configure_reporting=nil
if b==false then
return{emit=v.illuminance(),converter=i(),read_on_configure=true}end
return j({emit=v.illuminance(),converter=i()},f(30,300,100))
end)
y.occupancy=function(e,k)
local a=l(e,k)local C,b=a.ias_zone==true,a.configure_reporting

a.ias_zone=nil
a.configure_reporting=nil
if C then
h(a,j({name="occupancy",emit=v.occupancy(),converter=q(1),ias_configure_method=p.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=g},f(30,300,nil)))return y.ias_zone(a)end
if b==false then
h(a,{emit=v.occupancy(),read_on_configure=true})return y.occupancy_sensing(a)end
h(a,j({emit=v.occupancy()},f(0,300,nil)))return y.occupancy_sensing(a)
end
o("motion",y.ias_zone,function(k)
local b=k.configure_reporting
k.configure_reporting=nil
local d={name="motion",emit=v.motion(),converter=q(1),ias_configure_method=p.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=g,read_on_configure=true}if b==false then
return d
end
return j(d,f(30,300,nil))
end)
end
return s
