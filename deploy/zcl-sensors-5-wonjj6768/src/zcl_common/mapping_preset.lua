local function l(x)
local u,A,v,z=require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.constants",require"st.utils.safe_xy_to_hsv"
local function j(e,t)
if type(e)~="table"then
e={}end
if type(t)~="table"then
return e
end
for w,r in pairs(t)do
e[w]=r
end
return e
end
local function i(e,a)
if type(e)~="table"or type(a)~="table"then
return e
end
for w,r in pairs(a)do
if e[w]==nil then
e[w]=r
end
end
return e
end
local function h(b,q)
local c={}if type(b)=="string"then
c.name=b
else
j(c,b)end
j(c,q)return c
end
local function d(p,o,m)
return{minimum_interval=p,maximum_interval=o,reportable_change=m,read_on_configure=true}
end
local function f(...)
local s={}for _,a in ipairs{...}do
i(s,a)end
return s
end
local function g(B,y,n)
x[B]=function(b,q)
local c=h(b,q)local k,a=c.configure_reporting,n(c)
c.configure_reporting=nil
if k==false then
a.minimum_interval=nil
a.maximum_interval=nil
a.reportable_change=nil
a.physical_reportable_change=nil
a.reporting_defaults=nil
end
i(c,a)return y(c)
end
end
g("temperature",x.temperature_measurement,function()
return f({emit=u.temperature"C",scale=100},d(30,300,50))
end)
g("humidity",x.relative_humidity,function()
return f({emit=u.humidity(),scale=100},d(30,300,100))
end)
g("battery",x.power_configuration_battery,function()
return f({emit=u.battery(),scale=2},d(300,21600,2))
end)
end
return l
