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
local catalog_1=require "contracts.families.zcl.sensors.z2m_absorption"
for _,entry in ipairs(registrations(catalog_1,"zcl.sensors.z2m_absorption","contracts.families.zcl.sensors.z2m_absorption"))do
entries[#entries + 1]=entry
end
local catalog_2=require "contracts.families.zcl.sensors.wave19_exact_aliases"
for _,entry in ipairs(registrations(catalog_2,"zcl.sensors.wave19_exact_aliases","contracts.families.zcl.sensors.wave19_exact_aliases"))do
entries[#entries + 1]=entry
end
local catalog_3=require "contracts.families.zcl.sensors.wave19_environment"
for _,entry in ipairs(registrations(catalog_3,"zcl.sensors.wave19_environment","contracts.families.zcl.sensors.wave19_environment"))do
entries[#entries + 1]=entry
end
local catalog_4=require "contracts.families.zcl.sensors.wave19_smoke"
for _,entry in ipairs(registrations(catalog_4,"zcl.sensors.wave19_smoke","contracts.families.zcl.sensors.wave19_smoke"))do
entries[#entries + 1]=entry
end
local catalog_5=require "contracts.families.zcl.sensors.wave19_vibration"
for _,entry in ipairs(registrations(catalog_5,"zcl.sensors.wave19_vibration","contracts.families.zcl.sensors.wave19_vibration"))do
entries[#entries + 1]=entry
end
return entries
