local function c(a,d,module_name)
assert(type(a)=="table","Canonical catalog must return a table: "..module_name)for h in next,a do
assert(h=="id"or h=="registrations","Canonical catalog has extra key: "..module_name ..":"..tostring(h))end
assert(a.id==d,"Canonical catalog id mismatch: "..module_name)assert(type(a.registrations)=="table","Canonical catalog registrations missing: "..module_name)return a.registrations
end
local b={}local f=require"contracts.families.ef00.thermostats.fcu"for _,e in ipairs(c(f,"ef00.thermostats.fcu","contracts.families.ef00.thermostats.fcu"))do
b[#b+1]=e
end
local g=require"contracts.families.ef00.thermostats.legacy"for _,e in ipairs(c(g,"ef00.thermostats.legacy","contracts.families.ef00.thermostats.legacy"))do
b[#b+1]=e
end
return b
