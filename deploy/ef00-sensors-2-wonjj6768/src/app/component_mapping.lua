local t={}
local function g(c)
if type(c)=="table"then
c=c[1]end
if type(c)~="number"or c%1~=0 or c<1 then
return nil
end
return c
end
local function l(f)
if f and type(f.get_endpoint)=="function"then
return g(f:get_endpoint())or 1
end
return 1
end
local function i(f)
local u,G={},{}if f and f.profile and type(f.profile.components)=="table"then
for b,_ in pairs(f.profile.components)do
if type(b)=="string"and b~=""and not G[b]then
G[b]=true
u[#u+1]=b
end
end
end
table.sort(u,function(I,H)
if I=="main"then
return H~="main"end
if H=="main"then
return false
end
return I<H
end)
return u
end
local function s(f)
local w,G={},{}if f and type(f.zigbee_endpoints)=="table"then
for L,E in pairs(f.zigbee_endpoints)do
local c=g(L)if c==nil and type(E)=="table"then
c=g(E.id)end
if c~=nil and not G[c]then
G[c]=true
w[#w+1]=c
end
end
end
if #w==0 then
w[1]=l(f)end
table.sort(w)return w
end
local function e(a,d,c,b)
c=g(c)if c==nil or type(b)~="string"or b==""then
return false
end
a[c]=b
d[b]=c
return true
end
local function y(f,o,a,d)
if type(o)~="function"then
return
end
for _,b in ipairs(i(f))do
local c=g(o(f,b))if c~=nil then
e(a,d,c,b)end
end
end
local function A(f,q,a,d)
if type(q)~="function"then
return
end
for _,c in ipairs(s(f))do
local b=q(f,c)if type(b)=="string"and b~=""then
e(a,d,c,b)end
end
end
local function C(f,h,B,D)
local x,j,k,a,d=type(h)=="table"and h.component_map or nil,type(h)=="table"and h.component_to_endpoint_map or nil,type(h)=="table"and h.endpoint_to_component_map or nil,{},{}


if type(x)=="table"then
for c,b in pairs(x)do
e(a,d,c,b)end
end
if type(j)=="table"then
for b,c in pairs(j)do
e(a,d,c,b)end
end
if type(k)=="table"then
for c,b in pairs(k)do
e(a,d,c,b)end
end
if type(h)=="table"and type(h.zcl_clusters)=="table"then
for _,F in ipairs(h.zcl_clusters)do
if type(F)=="table"then
e(a,d,F.endpoint,F.component)end
end
end
y(f,B,a,d)A(f,D,a,d)if type(j)=="table"then
for b,c in pairs(j)do
c=g(c)if c~=nil then d[b]=c end
end
end
local p={}for _,b in ipairs(i(f))do
if d[b]==nil then
local c
if b=="main"then
local v=l(f)c=a[v]==nil and v or nil
else
c=g(tonumber(b:match"(%d+)$"))if c~=nil and a[c]~=nil then
c=nil
end
end
if c~=nil then
e(a,d,c,b)else
p[#p+1]=b
end
end
end
local r={}for _,c in ipairs(s(f))do
if a[c]==nil then
r[#r+1]=c
end
end
for J,b in ipairs(p)do
local c=r[J]if c==nil then
break
end
e(a,d,c,b)end
local v=l(f)if d.main==nil and a[v]==nil then
e(a,d,v,"main")elseif a[v]==nil then
a[v]="main"end
return a,d
end
function t.sorted_profile_component_ids(f)
return i(f)
end
function t.apply(f,h)
local m,n=type(h)=="table"and h.component_to_endpoint or nil,type(h)=="table"and h.endpoint_to_component or nil

local o,q=type(m)=="function"and m or nil,type(n)=="function"and n or nil

local a,d=C(f,h,o,q)if o~=nil then
f:set_component_to_endpoint_fn(function(z,b)
local c=g(o(z,b))if c~=nil then
return c
end
c=d[b]or l(f)return c
end)
else
f:set_component_to_endpoint_fn(function(_,b)
local c=d[b]or l(f)return c
end)
end
if q~=nil then
f:set_endpoint_to_component_fn(function(z,c)
local b=q(z,c)if type(b)=="string"and b~=""then
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
return t
