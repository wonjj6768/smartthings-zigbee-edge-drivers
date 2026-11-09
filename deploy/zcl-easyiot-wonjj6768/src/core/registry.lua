local i,f=require"generated.package_registry",{}local a
local function c(g)
local j={}if type(g)~="table"then
return j
end
for m,l in pairs(g)do
if m~="fingerprints"then
j[m]=l
end
end
return j
end
local function e()
if a then
return a
end
a={}for _,g in ipairs(i)do
for _,n in ipairs(g.fingerprints)do
local b,h=n.manufacturer,n.model

if h~=nil and b~=nil then
a[b]=a[b]or{}a[b][h]=c(g)end
end
end
return a
end
function f.find(b,h)
local k=e()local d=k[b]if d and d[h]then
return d[h]end
return nil
end
function f.all()
return e()
end
return f
