local function b(c,e,module_name)
assert(type(c)=="table","Canonical catalog must return a table: "..module_name)for i in next,c do
assert(i=="id"or i=="registrations","Canonical catalog has extra key: "..module_name ..":"..tostring(i))end
assert(c.id==e,"Canonical catalog id mismatch: "..module_name)assert(type(c.registrations)=="table","Canonical catalog registrations missing: "..module_name)return c.registrations
end
local a={}local f=require"contracts.families.ef00.sensors.z2m_absorption"for _,d in ipairs(b(f,"ef00.sensors.z2m_absorption","contracts.families.ef00.sensors.z2m_absorption"))do
a[#a+1]=d
end
local g=require"contracts.families.ef00.sensors.wave16_excellux"for _,d in ipairs(b(g,"ef00.sensors.wave16_excellux","contracts.families.ef00.sensors.wave16_excellux"))do
a[#a+1]=d
end
local h=require"contracts.families.ef00.sensors.wave16_lincukoo_air"for _,d in ipairs(b(h,"ef00.sensors.wave16_lincukoo_air","contracts.families.ef00.sensors.wave16_lincukoo_air"))do
a[#a+1]=d
end
return a
