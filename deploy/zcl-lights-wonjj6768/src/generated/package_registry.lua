local function c(a,d,module_name)
assert(type(a)=="table","Canonical catalog must return a table: "..module_name)for f in next,a do
assert(f=="id"or f=="registrations","Canonical catalog has extra key: "..module_name ..":"..tostring(f))end
assert(a.id==d,"Canonical catalog id mismatch: "..module_name)assert(type(a.registrations)=="table","Canonical catalog registrations missing: "..module_name)return a.registrations
end
local b={}local e=require"contracts.families.zcl.lights"for _,h in ipairs(c(e,"zcl.lights","contracts.families.zcl.lights"))do
b[#b+1]=h
end
return b
