local function r(k,x)
local f,p,A,y,o=x.type_check,x.merge_options,x.copy_table,string.lower,{"command_id","transaction","batch_key","match_transaction","response_dp","response_dps","match_response"}




local function g(a,b)
local c={}if f(a)=="table"then
p(c,a)elseif a~=nil then
c.command_id=a
end
p(c,b)return c
end
local function e(h)
if h==true or h==1 then
return true
end
if h==false or h==0 then
return false
end
if f(h)=="string"then
local z=y(h)if z=="on"then
return true
end
if z=="off"then
return false
end
end
return h
end
local function l(i)
if f(i)~="table"then
return nil
end
if f(i.values)=="table"then
return i.values
end
return nil
end
local function v(q,i,h,b)
if f(b.current)=="function"then
return e(b.current(q,i,h))==e(h)end
local n=b.state_field
if f(n)~="string"or n==""then
n="switch"end
return e(q:get_field(n))==e(h)
end
function k.build_send_policy(a,b)
local c,B=g(a,b),{}for _,u in ipairs(o)do
if c[u]~=nil then
B[u]=c[u]end
end
return B
end
function k.apply_send_policy(j,m)
if f(j)~="table"or f(m)~="table"then
return j
end
if j[1]~=nil and j.dp==nil then
local C={}for D,w in ipairs(j)do
if f(w)=="table"then
C[D]=k.apply_send_policy(w,m)else
C[D]=w
end
end
return C
end
local t=A(j)for _,u in ipairs(o)do
if t[u]==nil and m[u]~=nil then
t[u]=m[u]end
end
return t
end
function k.build_fixed_send_policy(a,b)
local c=g(a,b)if c.transaction==nil then
c.transaction=1
end
if c.match_transaction==nil then
c.match_transaction=true
end
return k.build_send_policy(c)
end
function k.apply_fixed_send_policy(j,a,b)
return k.apply_send_policy(j,k.build_fixed_send_policy(a,b))
end
function k.build_global_send_policy(a,b)
local c=g(a,b)if c.match_transaction==nil then
c.match_transaction=false
end
return k.build_send_policy(c)
end
function k.apply_global_send_policy(j,a,b)
return k.apply_send_policy(j,k.build_global_send_policy(a,b))
end
function k.skip.state_on_and_brightness_present(b)
b=b or{}local d=b.brightness_key
if f(d)~="string"or d==""then
d="brightness"end
return function(q,h,w,i)
local s=l(i)if s==nil or s[d]==nil then
return false
end
return v(q,i,h,b)
end
end
function k.skip.state_on_and_brightness_present_only(b)
b=b or{}local d=b.brightness_key
if f(d)~="string"or d==""then
d="brightness"end
return function(q,h,w,i)
local s=l(i)if s==nil or s[d]==nil then
return false
end
return e(h)==true
end
end
end
return r
