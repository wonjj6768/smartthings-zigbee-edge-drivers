local function i(z)
local A,y,u,x=require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.constants",require"st.utils.safe_xy_to_hsv"
local function g(d,t)
if type(d)~="table"then
d={}end
if type(t)~="table"then
return d
end
for v,r in pairs(t)do
d[v]=r
end
return d
end
local function f(d,a)
if type(d)~="table"or type(a)~="table"then
return d
end
for v,r in pairs(a)do
if d[v]==nil then
d[v]=r
end
end
return d
end
local function e(b,p)
local c={}if type(b)=="string"then
c.name=b
else
g(c,b)end
g(c,p)return c
end
local function j(n,m,k)
return{minimum_interval=n,maximum_interval=m,reportable_change=k,read_on_configure=true}
end
local function o(...)
local s={}for _,a in ipairs{...}do
f(s,a)end
return s
end
local function q(B,w,l)
z[B]=function(b,p)
local c=e(b,p)local h,a=c.configure_reporting,l(c)
c.configure_reporting=nil
if h==false then
a.minimum_interval=nil
a.maximum_interval=nil
a.reportable_change=nil
a.physical_reportable_change=nil
a.reporting_defaults=nil
end
f(c,a)return w(c)
end
end
q("battery",z.power_configuration_battery,function()
return o({emit=A.battery(),scale=2},j(300,21600,2))
end)
end
return i
