local s,l,o,z,H,w,h,i=require"st.capabilities",require"runtime.capability_metadata",require"runtime.capability_support",require"runtime.utf8_text",require"log",{},"main",{}
local function B(c)
if type(c)~="table"then
return"device"end
return c.label or c.id or"device"
end
local u=o.is_callable
local function g(c,d,b)
return o.supports(c,d,b or h)
end
local function D(c,b,F)
b=b or h
if b==h then
c:emit_event(F)else
c:emit_component_event({id=b},F)end
end
local function q(e)
if type(e)=="table"then
return e
end
if type(e)~="string"or e==""then
return nil
end
return l.by_emit_name[e]or l.by_capability_id[e]
end
local function p(d)
if type(d)~="string"or d==""then
return false
end
if i[d]==true then
return true
end
local J,I=pcall(s.get_capability_definition,d,1,true)if not J then
H.warn(string.format("Failed to refresh capability definition for %s: %s",d,tostring(I)))return false
end
i[d]=true
return true
end
local function t(a,r)
if type(a)~="table"then
return nil,nil
end
p(a.capability_id)local f=s[a.capability_id]local j=f and f[r]or nil
if not u(j)and f and type(f.attributes)=="table"then
j=f.attributes[r]end
return f,j
end
local function m(c,a,E)
if type(c)~="table"or type(a)~="table"then
return
end
local G=string.format("__custom_binding_missing__:%s:%s",a.capability_id or"unknown",E or"unknown")if type(c.get_field)=="function"and c:get_field(G)then
return
end
if type(c.set_field)=="function"then
c:set_field(G,true,{persist=false})end
H.warn(string.format("[%s] Custom capability binding missing (%s): %s.%s",B(c),E or"unknown",a.capability_id or"unknown",a.attribute_name or"unknown"))
end
local function A(a,k,n)
n=n or{}if a.kind=="numeric"then
local C,y={value=k},n.unit
if type(y)~="string"or y==""then
y=a.event_unit or(a.default_range and a.default_range.unit or nil)end
if type(y)=="string"and y~=""then
C.unit=y
end
return C
end
return{value=k}
end
function w.supports(c,e,b)
local a=q(e)return a~=nil and g(c,a.capability_id,b)
end
function w.emit_state(c,b,e,k,n)
local a=q(e)if a==nil or k==nil then
return false
end
b=b or h
if not g(c,a.capability_id,b)then
return false
end
if a.kind=="enum"and(type(k)~="string"or k=="")then
return false
end
if a.kind=="text"then
local v=z.length(k)if v==nil then
return false
end
if type(a.maximum_length)=="number"then
k=z.truncate(k,a.maximum_length)if k==nil then
return false
end
end
end
local f,j=t(a,a.attribute_name)if not u(j)then
if f==nil then
m(c,a,"capability")else
m(c,a,"attribute")end
return false
end
local x=n and{state_change=n.state_change}or nil
D(c,b,j(A(a,k,n),x))return true
end
return w
