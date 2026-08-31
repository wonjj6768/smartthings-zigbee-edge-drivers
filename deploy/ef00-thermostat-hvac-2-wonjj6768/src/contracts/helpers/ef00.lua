local shared_helpers=require "contracts.helpers.family"
local ef00_helpers={}
function ef00_helpers.ts0601_fingerprints(manufacturer_names)
return shared_helpers.create_fingerprints("TS0601",manufacturer_names)
end
function ef00_helpers.capability_values(values)
local result={}
for _,value in ipairs(values or{})do
result[#result + 1]=value
end
return result
end
return ef00_helpers
