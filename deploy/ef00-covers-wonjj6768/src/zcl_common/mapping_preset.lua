local function l(w)
local z,A,u,y=require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.constants",require"st.utils.safe_xy_to_hsv"
local function j(d,t)
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
local function h(d,a)
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
local function g(b,q)
local c={}if type(b)=="string"then
c.name=b
else
j(c,b)end
j(c,q)return c
end
local function e(p,o,m)
return{minimum_interval=p,maximum_interval=o,reportable_change=m,read_on_configure=true}
end
local function i(...)
local s={}for _,a in ipairs{...}do
h(s,a)end
return s
end
local function f(B,x,n)
w[B]=function(b,q)
local c=g(b,q)local k,a=c.configure_reporting,n(c)
c.configure_reporting=nil
if k==false then
a.minimum_interval=nil
a.maximum_interval=nil
a.reportable_change=nil
a.physical_reportable_change=nil
a.reporting_defaults=nil
end
h(c,a)return x(c)
end
end
f("battery",w.power_configuration_battery,function()
return i({emit=z.battery(),scale=2},e(300,21600,2))
end)
f("cover_position",w.window_covering_position,function()
return i({emit=z.shade_level()},e(0,600,1))
end)
f("cover_state",w.window_covering_position,function()
return{name="cover_state",write_only=true}
end)
end
return l
