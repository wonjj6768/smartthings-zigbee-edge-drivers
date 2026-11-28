local function n(B)
local x,D,r,C=require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.constants",require"st.utils.safe_xy_to_hsv"
local function l(d,w)
if type(d)~="table"then
d={}end
if type(w)~="table"then
return d
end
for A,a in pairs(w)do
d[A]=a
end
return d
end
local function e(d,k)
if type(d)~="table"or type(k)~="table"then
return d
end
for A,a in pairs(k)do
if d[A]==nil then
d[A]=a
end
end
return d
end
local function i(c,t)
local b={}if type(c)=="string"then
b.name=c
else
l(b,c)end
l(b,t)return b
end
local function s(z)
return{
from=function(a)
if type(a)=="table"then
if z==1 then
if type(a.is_alarm1_set)=="function"and a:is_alarm1_set()then
return true
end
if type(a.is_alarm2_set)=="function"and a:is_alarm2_set()then
return true
end
elseif z==4 and type(a.is_tamper_set)=="function"then
return a:is_tamper_set()elseif a.value~=nil then
a=a.value
else
return a
end
end
if type(a)~="number"then
return a
end
return(a&z)~=0
end
}
end
local function f(u)
local g=u and u.body and u.body.zcl_body and u.body.zcl_body.zone_status or nil
if g==nil then
return nil
end
return{raw_value=g.value or g,typed_value=g}
end
local function h(q,p,o)
return{minimum_interval=q,maximum_interval=p,reportable_change=o,read_on_configure=true}
end
local function j(...)
local v={}for _,k in ipairs{...}do
e(v,k)end
return v
end
B.occupancy=function(c,t)
local b=i(c,t)local y,m=b.ias_zone==true,b.configure_reporting

b.ias_zone=nil
b.configure_reporting=nil
if y then
e(b,j({name="occupancy",emit=x.occupancy(),converter=s(1),ias_configure_method=r.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=f},h(30,300,nil)))return B.ias_zone(b)end
if m==false then
e(b,{emit=x.occupancy(),
converter={from=function(a)return a==true or(type(a)=="number"and(a&1)~=0)end},
read_on_configure=true})return B.occupancy_sensing(b)end
e(b,j({emit=x.occupancy(),
converter={from=function(a)return a==true or(type(a)=="number"and(a&1)~=0)end}
},h(0,300,nil)))return B.occupancy_sensing(b)
end
end
return n
