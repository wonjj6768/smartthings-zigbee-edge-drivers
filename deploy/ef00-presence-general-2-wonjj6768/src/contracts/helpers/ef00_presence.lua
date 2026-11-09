local v,p=require"protocol.tuya",require"contracts.helpers.ef00"local n=v.converter
local function f(k)
local d,l=k()local c={}
local function b(r,q)
local m=#d
l(r,q)for u=m+1,#d do
c[#c+1]=d[u]end
end
return c,b
end
local function g(b,a,e,t)
local h=true
if type(a)=="table"and a.query_on_configure~=nil then
h=a.query_on_configure
end
if type(t)=="table"then
b({datapoints=a,presence_capability_ranges=t,query_on_configure=h},e)return
end
if type(a)=="table"then
local o={}for w,s in pairs(a)do
o[w]=s
end
if o.query_on_configure==nil then
o.query_on_configure=true
end
b(o,e)return
end
b({datapoints=a,query_on_configure=true},e)
end
local j=n.lookup_from_to{on=true,off=false}
local i=n.from_only(function(s)
return tonumber(s)==1
end)
return{isolated_definition_registry=f,register_presence_definition=g,ts0601_fingerprints=p.ts0601_fingerprints,on_off_bool_converter=j,msa201_presence_converter=i}
