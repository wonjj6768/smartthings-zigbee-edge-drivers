local t=require"runtime.battery_refresh"
local function q(x,O)
function x.build_named_map(S,Q)
local T={}for _,a in ipairs(S or{})do
local U=a[Q or"name"]if U~=nil then T[U]=a end
end
return T
end
local C,K,I={[x.GET_DATA]=true,[x.SET_DATA_RESPONSE]=true,[x.REPORT_STATUS]=true,[x.ACTIVE_STATUS_REPORT]=true},1,2

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
local function H(r)
local y=w(r)if y==nil then
return nil
end
local N=2 ^(#r*8)if y>=N/2 then
return y-N
end
return y
end
local function M(h,e)
if h==K then
local l=string.byte(e,1)if l==0 then return false end
if l==1 then return true end
return nil
end
if h==I then
if #e==4 then return H(e)end
return w(e)end
if O and h==4 and #e==1 then
return string.byte(e,1)end
return nil
end
local function G(f,k)
if #f<k+3 then
return nil
end
local R,B=string.byte(f,k+2)*256+string.byte(f,k+3),k+4
local v=B+R
if v-1>#f then
return nil
end
local h,e=string.byte(f,k+1),string.sub(f,B,v-1)return{dp=string.byte(f,k),datatype=h,length=R,value_bytes=e,value=M(h,e),int_value=w(e),signed_value=H(e),next_index=v}
end
function x.parse_read_only_datapoint_report(c)
local f=E(c)if type(f)~="string"or #f<2 then
return nil
end
local j,k={command_id=p(c),endpoint=s(c),status=string.byte(f,1),transaction=string.byte(f,2),payload=f,datapoints={}},3
while k<=#f do
local b=G(f,k)if b==nil then
return nil
end
b.endpoint=j.endpoint
j.datapoints[#j.datapoints+1]=b
k=b.next_index
end
return j
end
local function L(u,Y)
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
local function J(d,a,j,b)
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
local P=p(c)if C[P]~=true then
return false
end
local j=x.parse_read_only_datapoint_report(c)if j==nil then
return false
end
for _,b in ipairs(j.datapoints)do
local a=L(u,b.dp)if a~=nil then
J(d,a,j,b)end
end
return true
end
return x
end
return q
