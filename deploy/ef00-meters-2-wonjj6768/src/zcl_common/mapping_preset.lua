local function l(v)
local r,A,w,z=require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.constants",require"st.utils.safe_xy_to_hsv"
local function j(e,u)
if type(e)~="table"then
e={}end
if type(u)~="table"then
return e
end
for x,s in pairs(u)do
e[x]=s
end
return e
end
local function i(e,a)
if type(e)~="table"or type(a)~="table"then
return e
end
for x,s in pairs(a)do
if e[x]==nil then
e[x]=s
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
local function g(...)
local t={}for _,a in ipairs{...}do
i(t,a)end
return t
end
local function f(B,y,n)
v[B]=function(b,q)
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
f("power",v.electrical_measurement_power,function()
return g({emit=r.power(),metering_kind="power",poll_interval=300},d(5,300,1))
end)
f("current",v.electrical_measurement_current,function()
return g({emit=r.current(),scale=1000,metering_kind="current",poll_interval=300},d(5,300,1))
end)
f("voltage",v.electrical_measurement_voltage,function()
return g({emit=r.voltage(),metering_kind="voltage",poll_interval=300},d(5,300,1))
end)
f("energy",v.simple_metering,function()
return{emit=r.energy(),read_on_configure=true,metering_kind="energy",poll_interval=900}
end)
end
return l
