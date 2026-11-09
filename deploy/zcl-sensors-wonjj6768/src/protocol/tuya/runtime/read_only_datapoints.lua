local t=require"runtime.battery_refresh"
local function q(x,N)
function x.build_named_map(S,P)
local T={}for _,a in ipairs(S or{})do
local U=a[P or"name"]if U~=nil then T[U]=a end
end
return T
end
local C,J,H={[x.GET_DATA]=true,[x.SET_DATA_RESPONSE]=true,[x.REPORT_STATUS]=true,[x.ACTIVE_STATUS_REPORT]=true},1,2

local function E(c)
if type(c)=="string"then
return c
end
if type(c)~="table"then
return nil
end
return c.body and c.body.zcl_body and c.body.zcl_body.body_bytes or nil
end
local function p(c)
if type(c)~="table"then
return nil
end
return c.body and c.body.zcl_header and
c.body.zcl_header.cmd and c.body.zcl_header.cmd.value or nil
end
local function s(c)
if type(c)~="table"then
return nil
end
local n=c.address_header and c.address_header.src_endpoint and
c.address_header.src_endpoint.value or nil
return type(n)=="number"and n or nil
end
local function w(r)
if type(r)~="string"or #r<1 then
return nil
end
local l=0
for V=1,#r do
l=l*256+string.byte(r,V)end
return l
end
local function L(h,f)
if h==J then
local l=string.byte(f,1)if l==0 then return false end
if l==1 then return true end
return nil
end
if h==H then
return w(f)end
if N and h==4 and #f==1 then
return string.byte(f,1)end
return nil
end
local function R(r)
local y=w(r)if y==nil then
return nil
end
local M=2 ^(#r*8)if y>=M/2 then
return y-M
end
return y
end
local function G(e,k)
if #e<k+3 then
return nil
end
local Q,B=string.byte(e,k+2)*256+string.byte(e,k+3),k+4
local v=B+Q
if v-1>#e then
return nil
end
local h,f=string.byte(e,k+1),string.sub(e,B,v-1)return{dp=string.byte(e,k),datatype=h,length=Q,value_bytes=f,value=L(h,f),int_value=w(f),signed_value=R(f),next_index=v}
end
function x.parse_read_only_datapoint_report(c)
local e=E(c)if type(e)~="string"or #e<2 then
return nil
end
local j,k={command_id=p(c),endpoint=s(c),status=string.byte(e,1),transaction=string.byte(e,2),payload=e,datapoints={}},3
while k<=#e do
local b=G(e,k)if b==nil then
return nil
end
b.endpoint=j.endpoint
j.datapoints[#j.datapoints+1]=b
k=b.next_index
end
return j
end
local function K(u,Y)
for _,a in ipairs(u or{})do
if a.dp==Y and a.write_only~=true then
return a
end
end
return nil
end
local function F(d,a,j,b)
local n,g=b.endpoint or j.endpoint,a.component

if g==nil and n~=nil and type(d.get_component_id_for_endpoint)=="function"then
g=d:get_component_id_for_endpoint(n)end
return{mapping=a,value=b.value,dp=b.dp,frame=j,endpoint=n,component_id=g,component=g and d.profile and d.profile.components and
d.profile.components[g]or nil}
end
local function D(d,o,i)
if not o then
return
end
t.maybe_schedule_after_event(d,o)if i.component~=nil and type(d.emit_component_event)=="function"then
d:emit_component_event(i.component,o)elseif i.endpoint~=nil and type(d.emit_event_for_endpoint)=="function"then
d:emit_event_for_endpoint(i.endpoint,o)else
d:emit_event(o)end
end
local function I(d,a,j,b)
local m=a.datatype==b.datatype
for _,h in ipairs(a.receive_datatypes or{})do
m=m or h==b.datatype
end
if not m or b.value==nil then
return
end
local i,z=F(d,a,j,b),type(a.converter)=="table"and a.converter or nil
local A=type(a.from_device)=="function"and a.from_device or
(z and type(z.from)=="function"and z.from or nil)local l=b.value
if A~=nil then
l=A(l,d,b,i)end
if type(a.field)=="string"and a.field~=""then
d:set_field(a.field,l,{persist=a.persist==true})end
if l==nil then
return
end
if a.name=="battery"or a.name=="battery_voltage"then
t.note_report(d)end
if type(a.emit)=="function"then
local o=a.emit(d,l,b,i)if type(o)=="table"and o[1]~=nil then
for _,W in ipairs(o)do
D(d,W,i)end
else
D(d,o,i)end
end
end
function x.apply_read_only_datapoints(d,c,u)
local O=p(c)if C[O]~=true then
return false
end
local j=x.parse_read_only_datapoint_report(c)if j==nil then
return false
end
for _,b in ipairs(j.datapoints)do
local a=K(u,b.dp)if a~=nil then
I(d,a,j,b)end
end
return true
end
return x
end
return q
