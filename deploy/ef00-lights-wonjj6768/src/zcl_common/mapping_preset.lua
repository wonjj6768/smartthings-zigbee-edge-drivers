local function n(D)
local x,E,y,C=require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.constants",require"st.utils.safe_xy_to_hsv"
local function m(f,w)
if type(f)~="table"then
f={}end
if type(w)~="table"then
return f
end
for A,e in pairs(w)do
f[A]=e
end
return f
end
local function j(f,a)
if type(f)~="table"or type(a)~="table"then
return f
end
for A,e in pairs(a)do
if f[A]==nil then
f[A]=e
end
end
return f
end
local function i(c,g)
local d={}if type(c)=="string"then
d.name=c
else
m(d,c)end
m(d,g)return d
end
local function z(e,u,t)
if e<u then
return u
end
if e>t then
return t
end
return e
end
local function o()
return{
from=function(e)
if type(e)~="number"then
return e
end
return math.floor(z(e,0,254)*100/254+0.5)
end,
to=function(e)
if type(e)~="number"then
return e
end
return math.floor(z(e,0,100)*254/100+0.5)
end
}
end
local function h(s,r,p)
return{minimum_interval=s,maximum_interval=r,reportable_change=p,read_on_configure=true}
end
local function k(...)
local v={}for _,a in ipairs{...}do
j(v,a)end
return v
end
local function l(F,B,q)
D[F]=function(c,g)
local d=i(c,g)local b,a=d.configure_reporting,q(d)
d.configure_reporting=nil
if b==false then
a.minimum_interval=nil
a.maximum_interval=nil
a.reportable_change=nil
a.physical_reportable_change=nil
a.reporting_defaults=nil
end
j(d,a)return B(d)
end
end
l("switch",D.on_off,function(g)
local b=g.configure_reporting
g.configure_reporting=nil
if b==false then
return{emit=x.switch()}end
return k({emit=x.switch()},h(0,300,nil))
end)
l("level",D.level_control,function(g)
local b=g.configure_reporting
g.configure_reporting=nil
local a={name="brightness",emit=x.level(),converter=o()}if b==false then return a end
return k(a,h(1,3600,1))
end)
end
return n
