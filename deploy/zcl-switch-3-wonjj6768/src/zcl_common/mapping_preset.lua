local function m(s)
local r,A,w,z=require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.constants",require"st.utils.safe_xy_to_hsv"
local function l(g,v)
if type(g)~="table"then
g={}end
if type(v)~="table"then
return g
end
for x,t in pairs(v)do
g[x]=t
end
return g
end
local function k(g,a)
if type(g)~="table"or type(a)~="table"then
return g
end
for x,t in pairs(a)do
if g[x]==nil then
g[x]=t
end
end
return g
end
local function j(b,i)
local d={}if type(b)=="string"then
d.name=b
else
l(d,b)end
l(d,i)return d
end
local function c(q,p,n)
return{minimum_interval=q,maximum_interval=p,reportable_change=n,read_on_configure=true}
end
local function h(...)
local u={}for _,a in ipairs{...}do
k(u,a)end
return u
end
local function e(B,y,o)
s[B]=function(b,i)
local d=j(b,i)local f,a=d.configure_reporting,o(d)
d.configure_reporting=nil
if f==false then
a.minimum_interval=nil
a.maximum_interval=nil
a.reportable_change=nil
a.physical_reportable_change=nil
a.reporting_defaults=nil
end
k(d,a)return y(d)
end
end
e("switch",s.on_off,function(i)
local f=i.configure_reporting
i.configure_reporting=nil
if f==false then
return{emit=r.switch()}end
return h({emit=r.switch()},c(0,300,nil))
end)
e("power",s.electrical_measurement_power,function()
return h({emit=r.power(),metering_kind="power",poll_interval=300},c(5,300,1))
end)
e("current",s.electrical_measurement_current,function()
return h({emit=r.current(),scale=1000,metering_kind="current",poll_interval=300},c(5,300,1))
end)
e("voltage",s.electrical_measurement_voltage,function()
return h({emit=r.voltage(),metering_kind="voltage",poll_interval=300},c(5,300,1))
end)
e("energy",s.simple_metering,function()
return{emit=r.energy(),read_on_configure=true,metering_kind="energy",poll_interval=900}
end)
end
return m
