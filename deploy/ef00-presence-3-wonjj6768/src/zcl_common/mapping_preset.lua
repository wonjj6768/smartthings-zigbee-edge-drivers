local function s(y)
local v,H,p,G=require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.constants",require"st.utils.safe_xy_to_hsv"
local function r(m,B)
if type(m)~="table"then
m={}end
if type(B)~="table"then
return m
end
for E,a in pairs(B)do
m[E]=a
end
return m
end
local function h(m,d)
if type(m)~="table"or type(d)~="table"then
return m
end
for E,a in pairs(d)do
if m[E]==nil then
m[E]=a
end
end
return m
end
local function l(e,k)
local b={}if type(e)=="string"then
b.name=e
else
r(b,e)end
r(b,k)return b
end
local function i()
return{
from=function(a)
if type(a)~="number"then
return a
end
if a<=0 then
return 0
end
local J=10 ^((a-1)/10000)return math.floor(J+0.5)
end,
to=function(a)
if type(a)~="number"then
return a
end
if a<=0 then
return 0
end
local K=10000*(math.log(a)/math.log(10))+1
return math.floor(K+0.5)
end
}
end
local function q(D)
return{
from=function(a)
if type(a)=="table"then
if D==1 then
if type(a.is_alarm1_set)=="function"and a:is_alarm1_set()then
return true
end
if type(a.is_alarm2_set)=="function"and a:is_alarm2_set()then
return true
end
elseif D==4 and type(a.is_tamper_set)=="function"then
return a:is_tamper_set()elseif a.value~=nil then
a=a.value
else
return a
end
end
if type(a)~="number"then
return a
end
return(a&D)~=0
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
local b=l(e,k)local c,d=b.configure_reporting,u(b)
b.configure_reporting=nil
if c==false then
d.minimum_interval=nil
d.maximum_interval=nil
d.reportable_change=nil
d.physical_reportable_change=nil
d.reporting_defaults=nil
end
h(b,d)return F(b)
end
end
o("battery",y.power_configuration_battery,function()
return j({emit=v.battery(),scale=2},f(300,21600,2))
end)
o("illuminance",y.illuminance_measurement,function(k)
local c=k.configure_reporting
k.configure_reporting=nil
if c==false then
return{emit=v.illuminance(),converter=i(),read_on_configure=true}end
return j({emit=v.illuminance(),converter=i()},f(30,300,100))
end)
y.occupancy=function(e,k)
local b=l(e,k)local C,c=b.ias_zone==true,b.configure_reporting

b.ias_zone=nil
b.configure_reporting=nil
if C then
h(b,j({name="occupancy",emit=v.occupancy(),converter=q(1),ias_configure_method=p.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=g},f(30,300,nil)))return y.ias_zone(b)end
if c==false then
h(b,{emit=v.occupancy(),
converter={from=function(a)return a==true or(type(a)=="number"and(a&1)~=0)end},
read_on_configure=true})return y.occupancy_sensing(b)end
h(b,j({emit=v.occupancy(),
converter={from=function(a)return a==true or(type(a)=="number"and(a&1)~=0)end}
},f(0,300,nil)))return y.occupancy_sensing(b)
end
o("motion",y.ias_zone,function(k)
local c=k.configure_reporting
k.configure_reporting=nil
local d={name="motion",emit=v.motion(),converter=q(1),ias_configure_method=p.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=g,read_on_configure=true}if c==false then
return d
end
return j(d,f(30,300,nil))
end)
end
return s
