local function l(B)
local z,A,v,y=require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.constants",require"st.utils.safe_xy_to_hsv"
local function k(f,u)
if type(f)~="table"then
f={}end
if type(u)~="table"then
return f
end
for w,g in pairs(u)do
f[w]=g
end
return f
end
local function j(f,a)
if type(f)~="table"or type(a)~="table"then
return f
end
for w,g in pairs(a)do
if f[w]==nil then
f[w]=g
end
end
return f
end
local function i(b,h)
local c={}if type(b)=="string"then
c.name=b
else
k(c,b)end
k(c,h)return c
end
local function d()
return{
from=function(g)
if type(g)~="number"then
return g
end
if g<=0 then
return 0
end
local D=10 ^((g-1)/10000)return math.floor(D+0.5)
end,
to=function(g)
if type(g)~="number"then
return g
end
if g<=0 then
return 0
end
local E=10000*(math.log(g)/math.log(10))+1
return math.floor(E+0.5)
end
}
end
local function m(q,p,n)
return{minimum_interval=q,maximum_interval=p,reportable_change=n,read_on_configure=true}
end
local function r(...)
local t={}for _,a in ipairs{...}do
j(t,a)end
return t
end
local function s(C,x,o)
B[C]=function(b,h)
local c=i(b,h)local e,a=c.configure_reporting,o(c)
c.configure_reporting=nil
if e==false then
a.minimum_interval=nil
a.maximum_interval=nil
a.reportable_change=nil
a.physical_reportable_change=nil
a.reporting_defaults=nil
end
j(c,a)return x(c)
end
end
s("illuminance",B.illuminance_measurement,function(h)
local e=h.configure_reporting
h.configure_reporting=nil
if e==false then
return{emit=z.illuminance(),converter=d(),read_on_configure=true}end
return r({emit=z.illuminance(),converter=d()},m(30,300,100))
end)
end
return l
