local function b(c,e,module_name)
assert(type(c)=="table","Canonical catalog must return a table: "..module_name)for j in next,c do
assert(j=="id"or j=="registrations","Canonical catalog has extra key: "..module_name ..":"..tostring(j))end
assert(c.id==e,"Canonical catalog id mismatch: "..module_name)assert(type(c.registrations)=="table","Canonical catalog registrations missing: "..module_name)return c.registrations
end
local a={}local f=require"contracts.families.ef00.thermostats.wave6a_wall"for _,d in ipairs(b(f,"ef00.thermostats.wave6a_wall","contracts.families.ef00.thermostats.wave6a_wall"))do
a[#a+1]=d
end
local g=require"contracts.families.ef00.thermostats.wave12_wall"for _,d in ipairs(b(g,"ef00.thermostats.wave12_wall","contracts.families.ef00.thermostats.wave12_wall"))do
a[#a+1]=d
end
local h=require"contracts.families.ef00.thermostats.wave12_fcu"for _,d in ipairs(b(h,"ef00.thermostats.wave12_fcu","contracts.families.ef00.thermostats.wave12_fcu"))do
a[#a+1]=d
end
local i=require"contracts.families.ef00.thermostats.z2m_absorption_wall"for _,d in ipairs(b(i,"ef00.thermostats.z2m_absorption_wall","contracts.families.ef00.thermostats.z2m_absorption_wall"))do
a[#a+1]=d
end
return a
