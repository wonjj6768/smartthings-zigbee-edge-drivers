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
local catalog_1=require "contracts.families.zcl.sensors.simple_sensors"
for _,entry in ipairs(registrations(catalog_1,"zcl.sensors.simple_sensors","contracts.families.zcl.sensors.simple_sensors"))do
entries[#entries + 1]=entry
end
local catalog_2=require "contracts.families.zcl.sensors.shelly_environment"
for _,entry in ipairs(registrations(catalog_2,"zcl.sensors.shelly_environment","contracts.families.zcl.sensors.shelly_environment"))do
entries[#entries + 1]=entry
end
local catalog_3=require "contracts.families.zcl.sensors.sonoff_safety"
for _,entry in ipairs(registrations(catalog_3,"zcl.sensors.sonoff_safety","contracts.families.zcl.sensors.sonoff_safety"))do
entries[#entries + 1]=entry
end
return entries
