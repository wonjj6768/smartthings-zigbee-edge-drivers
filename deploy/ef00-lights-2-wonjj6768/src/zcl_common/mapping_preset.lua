local function j(A)
local y,z,u,x=require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.constants",require"st.utils.safe_xy_to_hsv"
local function i(e,t)
if type(e)~="table"then
e={}end
if type(t)~="table"then
return e
end
for v,r in pairs(t)do
e[v]=r
end
return e
end
local function h(e,a)
if type(e)~="table"or type(a)~="table"then
return e
end
for v,r in pairs(a)do
if e[v]==nil then
e[v]=r
end
end
return e
end
local function g(b,f)
local c={}if type(b)=="string"then
c.name=b
else
i(c,b)end
i(c,f)return c
end
local function k(o,n,l)
return{minimum_interval=o,maximum_interval=n,reportable_change=l,read_on_configure=true}
end
local function p(...)
local s={}for _,a in ipairs{...}do
h(s,a)end
return s
end
local function q(B,w,m)
A[B]=function(b,f)
local c=g(b,f)local d,a=c.configure_reporting,m(c)
c.configure_reporting=nil
if d==false then
a.minimum_interval=nil
a.maximum_interval=nil
a.reportable_change=nil
a.physical_reportable_change=nil
a.reporting_defaults=nil
end
h(c,a)return w(c)
end
end
q("switch",A.on_off,function(f)
local d=f.configure_reporting
f.configure_reporting=nil
if d==false then
return{emit=y.switch()}end
return p({emit=y.switch()},k(0,300,nil))
end)
end
return j
