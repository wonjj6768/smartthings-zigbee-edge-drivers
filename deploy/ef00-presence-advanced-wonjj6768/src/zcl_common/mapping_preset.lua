local function n(B)
local x,D,r,C=require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.constants",require"st.utils.safe_xy_to_hsv"
local function l(d,w)
if type(d)~="table"then
d={}end
if type(w)~="table"then
return d
end
for A,b in pairs(w)do
d[A]=b
end
return d
end
local function e(d,k)
if type(d)~="table"or type(k)~="table"then
return d
end
for A,b in pairs(k)do
if d[A]==nil then
d[A]=b
end
end
return d
end
local function i(c,t)
local a={}if type(c)=="string"then
a.name=c
else
l(a,c)end
l(a,t)return a
end
local function s(z)
return{
from=function(b)
if type(b)=="table"then
if z==1 then
if type(b.is_alarm1_set)=="function"and b:is_alarm1_set()then
return true
end
if type(b.is_alarm2_set)=="function"and b:is_alarm2_set()then
return true
end
elseif z==4 and type(b.is_tamper_set)=="function"then
return b:is_tamper_set()elseif b.value~=nil then
b=b.value
else
return b
end
end
if type(b)~="number"then
return b
end
return(b&z)~=0
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
local a=i(c,t)local y,m=a.ias_zone==true,a.configure_reporting

a.ias_zone=nil
a.configure_reporting=nil
if y then
e(a,j({name="occupancy",emit=x.occupancy(),converter=s(1),ias_configure_method=r.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,command_id=0,command_extractor=f},h(30,300,nil)))return B.ias_zone(a)end
if m==false then
e(a,{emit=x.occupancy(),read_on_configure=true})return B.occupancy_sensing(a)end
e(a,j({emit=x.occupancy()},h(0,300,nil)))return B.occupancy_sensing(a)
end
end
return n
