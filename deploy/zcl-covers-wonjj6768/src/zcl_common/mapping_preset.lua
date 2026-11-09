local function o(v)
local z,F,A,D=require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.constants",require"st.utils.safe_xy_to_hsv"
local function m(f,y)
if type(f)~="table"then
f={}end
if type(y)~="table"then
return f
end
for B,i in pairs(y)do
f[B]=i
end
return f
end
local function j(f,c)
if type(f)~="table"or type(c)~="table"then
return f
end
for B,i in pairs(c)do
if f[B]==nil then
f[B]=i
end
end
return f
end
local function d(a,l)
local b={}if type(a)=="string"then
b.name=a
else
m(b,a)end
m(b,l)return b
end
local function E(i,u,t)
if i<u then
return u
end
if i>t then
return t
end
return i
end
local function h()
return{
from=function(i)
if type(i)~="number"then
return i
end
local w=E(i,0,100)if w<=0 then
return"closed"end
if w>=100 then
return"open"end
return"partially open"
end
}
end
local function e(s,r,p)
return{minimum_interval=s,maximum_interval=r,reportable_change=p,read_on_configure=true}
end
local function k(...)
local x={}for _,c in ipairs{...}do
j(x,c)end
return x
end
local function g(G,C,q)
v[G]=function(a,l)
local b=d(a,l)local n,c=b.configure_reporting,q(b)
b.configure_reporting=nil
if n==false then
c.minimum_interval=nil
c.maximum_interval=nil
c.reportable_change=nil
c.physical_reportable_change=nil
c.reporting_defaults=nil
end
j(b,c)return C(b)
end
end
g("battery",v.power_configuration_battery,function()
return k({emit=z.battery(),scale=2},e(300,21600,2))
end)
v.tuya_magic_packet=function(a,l)
local b=d(a,l)j(b,{name="tuya_magic_packet",read_only=true,read_on_configure=true})return v.cluster_attribute(0,65534,b)
end
g("cover_position",v.window_covering_position,function()
return k({emit=z.shade_level()},e(0,600,1))
end)
g("cover_state",v.window_covering_position,function()
return{name="cover_state",write_only=true}
end)
g("window_shade_state",v.window_covering_position,function()
return k({name="window_shade_state",emit=z.shade_state(),converter=h()},e(0,600,1))
end)
end
return o
