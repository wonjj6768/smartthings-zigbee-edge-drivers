local r={}
local function g(c)
if type(c)=="table"then
c=c[1]end
if type(c)~="number"or c%1~=0 or c<1 then
return nil
end
return c
end
local function i(f)
local t,E={},{}if f and f.profile and type(f.profile.components)=="table"then
for b,_ in pairs(f.profile.components)do
if type(b)=="string"and b~=""and not E[b]then
E[b]=true
t[#t+1]=b
end
end
end
table.sort(t,function(G,F)
if G=="main"then
return F~="main"end
if F=="main"then
return false
end
return G<F
end)
return t
end
local function q(f)
local u,E={},{}if f and type(f.zigbee_endpoints)=="table"then
for J,C in pairs(f.zigbee_endpoints)do
local c=g(J)if c==nil and type(C)=="table"then
c=g(C.id)end
if c~=nil and not E[c]then
E[c]=true
u[#u+1]=c
end
end
end
if not E[1]then
u[#u+1]=1
end
table.sort(u)return u
end
local function e(a,d,c,b)
c=g(c)if c==nil or type(b)~="string"or b==""then
return false
end
a[c]=b
d[b]=c
return true
end
local function w(f,m,a,d)
if type(m)~="function"then
return
end
for _,b in ipairs(i(f))do
local c=g(m(f,b))if c~=nil then
e(a,d,c,b)end
end
end
local function y(f,o,a,d)
if type(o)~="function"then
return
end
for _,c in ipairs(q(f))do
local b=o(f,c)if type(b)=="string"and b~=""then
e(a,d,c,b)end
end
end
local function A(f,h,z,B)
local v,s,j,a,d=type(h)=="table"and h.component_map or nil,type(h)=="table"and h.component_to_endpoint_map or nil,type(h)=="table"and h.endpoint_to_component_map or nil,{},{}


if type(v)=="table"then
for c,b in pairs(v)do
e(a,d,c,b)end
end
if type(s)=="table"then
for b,c in pairs(s)do
e(a,d,c,b)end
end
if type(j)=="table"then
for c,b in pairs(j)do
e(a,d,c,b)end
end
if type(h)=="table"and type(h.zcl_clusters)=="table"then
for _,D in ipairs(h.zcl_clusters)do
if type(D)=="table"then
e(a,d,D.endpoint,D.component)end
end
end
w(f,z,a,d)y(f,B,a,d)local n={}for _,b in ipairs(i(f))do
if d[b]==nil then
local c
if b=="main"then
c=a[1]==nil and 1 or nil
else
c=g(tonumber(b:match"(%d+)$"))if c~=nil and a[c]~=nil then
c=nil
end
end
if c~=nil then
e(a,d,c,b)else
n[#n+1]=b
end
end
end
local p={}for _,c in ipairs(q(f))do
if a[c]==nil then
p[#p+1]=c
end
end
for H,b in ipairs(n)do
local c=p[H]if c==nil then
break
end
e(a,d,c,b)end
if d.main==nil and a[1]==nil then
e(a,d,1,"main")elseif a[1]==nil then
a[1]="main"end
return a,d
end
function r.sorted_profile_component_ids(f)
return i(f)
end
function r.apply(f,h)
local k,l=type(h)=="table"and h.component_to_endpoint or nil,type(h)=="table"and h.endpoint_to_component or nil

local m,o=type(k)=="function"and k or nil,type(l)=="function"and l or nil

local a,d=A(f,h,m,o)if m~=nil then
f:set_component_to_endpoint_fn(function(x,b)
local c=g(m(x,b))if c~=nil then
return c
end
c=d[b]or 1
return c
end)
else
f:set_component_to_endpoint_fn(function(_,b)
local c=d[b]or 1
return c
end)
end
if o~=nil then
f:set_endpoint_to_component_fn(function(x,c)
local b=o(x,c)if type(b)=="string"and b~=""then
return b
end
return a[c]or"main"
end)
else
f:set_endpoint_to_component_fn(function(_,c)
return a[c]or"main"
end)
end
end
return r
