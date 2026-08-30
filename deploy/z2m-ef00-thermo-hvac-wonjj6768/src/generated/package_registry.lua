local function registrations(catalog,expected_id,module_name)
assert(type(catalog)=="table","Canonical catalog must return a table: " .. module_name)
for key in next,catalog do
assert(key=="id" or key=="registrations","Canonical catalog has extra key: " .. module_name .. ":" .. tostring(key))
end
assert(catalog.id==expected_id,"Canonical catalog id mismatch: " .. module_name)
assert(type(catalog.registrations)=="table","Canonical catalog registrations missing: " .. module_name)
return catalog.registrations
end
local entries={}
local catalog_1=require "contracts.families.ef00.thermostats.wave6a_wall"
for _,entry in ipairs(registrations(catalog_1,"ef00.thermostats.wave6a_wall","contracts.families.ef00.thermostats.wave6a_wall"))do
entries[#entries + 1]=entry
end
local catalog_2=require "contracts.families.ef00.thermostats.wave12_wall"
for _,entry in ipairs(registrations(catalog_2,"ef00.thermostats.wave12_wall","contracts.families.ef00.thermostats.wave12_wall"))do
entries[#entries + 1]=entry
end
local catalog_3=require "contracts.families.ef00.thermostats.wave12_fcu"
for _,entry in ipairs(registrations(catalog_3,"ef00.thermostats.wave12_fcu","contracts.families.ef00.thermostats.wave12_fcu"))do
entries[#entries + 1]=entry
end
return entries
