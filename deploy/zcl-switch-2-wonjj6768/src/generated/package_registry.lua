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
local catalog_1=require "contracts.families.zcl.switches.z2m_absorption"
for _,entry in ipairs(registrations(catalog_1,"zcl.switches.z2m_absorption","contracts.families.zcl.switches.z2m_absorption"))do
entries[#entries + 1]=entry
end
local catalog_2=require "contracts.families.zcl.switches.shelly_em"
for _,entry in ipairs(registrations(catalog_2,"zcl.switches.shelly_em","contracts.families.zcl.switches.shelly_em"))do
entries[#entries + 1]=entry
end
local catalog_3=require "contracts.families.zcl.switches.wave14_sber_zcl"
for _,entry in ipairs(registrations(catalog_3,"wave14.sber.zcl_switches","contracts.families.zcl.switches.wave14_sber_zcl"))do
entries[#entries + 1]=entry
end
local catalog_4=require "contracts.families.zcl.switches.wave14_terncy_zcl"
for _,entry in ipairs(registrations(catalog_4,"wave14.terncy.zcl_switch","contracts.families.zcl.switches.wave14_terncy_zcl"))do
entries[#entries + 1]=entry
end
return entries
