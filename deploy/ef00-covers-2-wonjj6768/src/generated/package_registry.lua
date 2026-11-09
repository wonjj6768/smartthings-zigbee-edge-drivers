local function b(c,e,module_name)
assert(type(c)=="table","Canonical catalog must return a table: "..module_name)for j in next,c do
assert(j=="id"or j=="registrations","Canonical catalog has extra key: "..module_name ..":"..tostring(j))end
assert(c.id==e,"Canonical catalog id mismatch: "..module_name)assert(type(c.registrations)=="table","Canonical catalog registrations missing: "..module_name)return c.registrations
end
local a={}local f=require"contracts.families.ef00.covers.z2m_absorption"for _,d in ipairs(b(f,"ef00.covers.z2m_absorption","contracts.families.ef00.covers.z2m_absorption"))do
a[#a+1]=d
end
local g=require"contracts.families.ef00.covers.wave10"for _,d in ipairs(b(g,"ef00.covers.wave10","contracts.families.ef00.covers.wave10"))do
a[#a+1]=d
end
local h=require"contracts.families.ef00.covers.wave15"for _,d in ipairs(b(h,"ef00.covers.wave15","contracts.families.ef00.covers.wave15"))do
a[#a+1]=d
end
local i=require"contracts.families.ef00.covers.wave19_legacy"for _,d in ipairs(b(i,"ef00.covers.wave19_legacy","contracts.families.ef00.covers.wave19_legacy"))do
a[#a+1]=d
end
return a
