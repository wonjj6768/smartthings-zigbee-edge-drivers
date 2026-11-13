local function o(y)
local t,B,w,A=require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.constants",require"st.utils.safe_xy_to_hsv"
local function n(g,v)
if type(g)~="table"then
g={}end
if type(v)~="table"then
return g
end
for x,h in pairs(v)do
g[x]=h
end
return g
end
local function m(g,a)
if type(g)~="table"or type(a)~="table"then
return g
end
for x,h in pairs(a)do
if g[x]==nil then
g[x]=h
end
end
return g
end
local function l(b,k)
local c={}if type(b)=="string"then
c.name=b
else
n(c,b)end
n(c,k)return c
end
local function d()
return{
from=function(h)
if type(h)~="number"then
return h
end
if h<=0 then
return 0
end
local D=10 ^((h-1)/10000)return math.floor(D+0.5)
end,
to=function(h)
if type(h)~="number"then
return h
end
if h<=0 then
return 0
end
local E=10000*(math.log(h)/math.log(10))+1
return math.floor(E+0.5)
end
}
end
local function f(s,r,p)
return{minimum_interval=s,maximum_interval=r,reportable_change=p,read_on_configure=true}
end
local function i(...)
local u={}for _,a in ipairs{...}do
m(u,a)end
return u
end
local function j(C,z,q)
y[C]=function(b,k)
local c=l(b,k)local e,a=c.configure_reporting,q(c)
c.configure_reporting=nil
if e==false then
a.minimum_interval=nil
a.maximum_interval=nil
a.reportable_change=nil
a.physical_reportable_change=nil
a.reporting_defaults=nil
end
m(c,a)return z(c)
end
end
j("temperature",y.temperature_measurement,function()
return i({emit=t.temperature"C",scale=100},f(30,300,50))
end)
j("humidity",y.relative_humidity,function()
return i({emit=t.humidity(),scale=100},f(30,300,100))
end)
j("illuminance",y.illuminance_measurement,function(k)
local e=k.configure_reporting
k.configure_reporting=nil
if e==false then
return{emit=t.illuminance(),converter=d(),read_on_configure=true}end
return i({emit=t.illuminance(),converter=d()},f(30,300,100))
end)
end
return o
