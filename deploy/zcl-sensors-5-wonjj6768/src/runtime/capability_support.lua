local b={}
function b.is_callable(m)
if type(m)=="function"then
return true
end
if type(m)~="table"then
return false
end
local l=getmetatable(m)return type(l)=="table"and type(l.__call)=="function"
end
local function g(d)
if type(d)~="table"then
return nil
end
local h=d.profile
if type(h)~="table"and type(d.st_store)=="table"then
h=d.st_store.profile
end
return type(h)=="table"and h.components or nil
end
local function e(f,a)
local i=type(f)=="table"and f.capabilities or nil
if type(i)~="table"then
return false
end
if i[a]~=nil then
return true
end
for _,j in pairs(i)do
if type(j)=="table"and j.id==a then
return true
end
end
return false
end
function b.supports(d,a,c)
if type(d)~="table"or type(a)~="string"or a==""then
return false
end
c=c or"main"if type(d.supports_capability_by_id)=="function"then
return d:supports_capability_by_id(a,c)end
local k=g(d)local f=type(k)=="table"and k[c]or nil
return e(f,a)
end
return b
