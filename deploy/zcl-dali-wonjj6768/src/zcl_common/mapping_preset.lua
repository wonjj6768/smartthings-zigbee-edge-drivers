local function p(D)
local x,G,A,F=require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.constants",require"st.utils.safe_xy_to_hsv"
local function o(h,z)
if type(h)~="table"then
h={}end
if type(z)~="table"then
return h
end
for C,c in pairs(z)do
h[C]=c
end
return h
end
local function n(h,b)
if type(h)~="table"or type(b)~="table"then
return h
end
for C,c in pairs(b)do
if h[C]==nil then
h[C]=c
end
end
return h
end
local function l(e,d)
local f={}if type(e)=="string"then
f.name=e
else
o(f,e)end
o(f,d)return f
end
local function B(c,w,v)
if c<w then
return w
end
if c>v then
return v
end
return c
end
local function q()
return{
from=function(c)
if type(c)~="number"then
return c
end
return math.floor(B(c,0,254)*100/254+0.5)
end,
to=function(c)
if type(c)~="number"then
return c
end
return math.floor(B(c,0,100)*254/100+0.5)
end
}
end
local function m()
local i=1000000
return{
from=function(c)
if type(c)~="number"or c<=0 then
return c
end
return math.floor(i/c+0.5)
end,
to=function(c)
if type(c)~="number"or c<=0 then
return c
end
return math.floor(i/c+0.5)
end
}
end
local function g(u,t,r)
return{minimum_interval=u,maximum_interval=t,reportable_change=r,read_on_configure=true}
end
local function j(...)
local y={}for _,b in ipairs{...}do
n(y,b)end
return y
end
local function k(H,E,s)
D[H]=function(e,d)
local f=l(e,d)local a,b=f.configure_reporting,s(f)
f.configure_reporting=nil
if a==false then
b.minimum_interval=nil
b.maximum_interval=nil
b.reportable_change=nil
b.physical_reportable_change=nil
b.reporting_defaults=nil
end
n(f,b)return E(f)
end
end
k("switch",D.on_off,function(d)
local a=d.configure_reporting
d.configure_reporting=nil
if a==false then
return{emit=x.switch()}end
return j({emit=x.switch()},g(0,300,nil))
end)
k("level",D.level_control,function(d)
local a=d.configure_reporting
d.configure_reporting=nil
local b={name="brightness",emit=x.level(),converter=q()}if a==false then return b end
return j(b,g(1,3600,1))
end)
k("color_temperature",D.color_control_temperature,function(d)
local a=d.configure_reporting
d.configure_reporting=nil
local b={name="color_temperature",emit=x.color_temperature(),converter=m(),tx_command_id=10}if a==false then return b end
return j(b,g(1,300,1))
end)
end
return p
