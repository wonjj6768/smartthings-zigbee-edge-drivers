local function registrations(catalog,expected_id,module_name)
assert(type(catalog)=="table","Canonical catalog must return a table: "..module_name)for key in next,catalog do
assert(key=="id"or key=="registrations","Canonical catalog has extra key: "..module_name ..":"..tostring(key))
end
assert(catalog.id==expected_id,"Canonical catalog id mismatch: "..module_name)assert(type(catalog.registrations)=="table","Canonical catalog registrations missing: "..module_name)return catalog.registrations
end
local entries={}local catalog_1=require"contracts.families.zcl.sensors.wave19_hvac"
for _,entry in ipairs(registrations(catalog_1,"zcl.sensors.wave19_hvac","contracts.families.zcl.sensors.wave19_hvac"))do
entries[#entries+1]=entry
end
local catalog_2=require"contracts.families.zcl.thermostats.wave19_sber"
for _,entry in ipairs(registrations(catalog_2,"zcl.thermostats.wave19.sber","contracts.families.zcl.thermostats.wave19_sber"))do
entries[#entries+1]=entry
end
local catalog_3=require"contracts.families.zcl.thermostats.aqara_w500"
for _,entry in ipairs(registrations(catalog_3,"zcl.thermostats.aqara_w500","contracts.families.zcl.thermostats.aqara_w500"))do
entries[#entries+1]=entry
end
local catalog_4=require"contracts.families.zcl.thermostats.namron_edge"
for _,entry in ipairs(registrations(catalog_4,"zcl.thermostats.namron_edge","contracts.families.zcl.thermostats.namron_edge"))do
entries[#entries+1]=entry
end
return entries
