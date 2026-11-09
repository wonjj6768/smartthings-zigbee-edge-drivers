local function m(G)
local H,F,t,E=require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.constants",require"st.utils.safe_xy_to_hsv"
local function l(f,A)
if type(f)~="table"then
f={}end
if type(A)~="table"then
return f
end
for D,b in pairs(A)do
f[D]=b
end
return f
end
local function k(f,a)
if type(f)~="table"or type(a)~="table"then
return f
end
for D,b in pairs(a)do
if f[D]==nil then
f[D]=b
end
end
return f
end
local function x(C,...)
local o=H[C]if type(o)=="function"then
return o(...)end
return nil
end
local function j(c,i)
local d={}if type(c)=="string"then
d.name=c
else
l(d,c)end
l(d,i)return d
end
local function u(B)
return{
from=function(b)
if type(b)=="table"then
if B==1 then
if type(b.is_alarm1_set)=="function"and b:is_alarm1_set()then
return true
end
if type(b.is_alarm2_set)=="function"and b:is_alarm2_set()then
return true
end
elseif B==4 and type(b.is_tamper_set)=="function"then
return b:is_tamper_set()elseif b.value~=nil then
b=b.value
else
return b
end
end
if type(b)~="number"then
return b
end
return(b&B)~=0
end
}
end
local function g(y)
local h=y and y.body and y.body.zcl_body and y.body.zcl_body.zone_status or nil
if h==nil then
return nil
end
return{raw_value=h.value or h,typed_value=h}
end
local function n(s,r,p)
return{minimum_interval=s,maximum_interval=r,reportable_change=p,read_on_configure=true}
end
local function v(...)
local z={}for _,a in ipairs{...}do
k(z,a)end
return z
end
local function w(C,o,q)
G[C]=function(c,i)
local d=j(c,i)local e,a=d.configure_reporting,q(d)
d.configure_reporting=nil
if e==false then
a.minimum_interval=nil
a.maximum_interval=nil
a.reportable_change=nil
a.physical_reportable_change=nil
a.reporting_defaults=nil
end
k(d,a)return o(d)
end
end
w("battery_low",G.ias_zone,function(i)
local e=i.configure_reporting
i.configure_reporting=nil
local a={name="battery_low",emit=x"battery_low",converter=u(8),ias_configure_method=t.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=g,read_on_configure=true}if e==false then
return a
end
return v(a,n(0,300,nil))
end)
end
return m
