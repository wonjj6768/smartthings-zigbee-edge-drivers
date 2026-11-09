local function b(d,e,module_name)
assert(type(d)=="table","Canonical catalog must return a table: "..module_name)for m in next,d do
assert(m=="id"or m=="registrations","Canonical catalog has extra key: "..module_name ..":"..tostring(m))end
assert(d.id==e,"Canonical catalog id mismatch: "..module_name)assert(type(d.registrations)=="table","Canonical catalog registrations missing: "..module_name)return d.registrations
end
local a={}local f=require"contracts.families.ef00.presence.z2m_absorption"for _,c in ipairs(b(f,"ef00.presence.z2m_absorption","contracts.families.ef00.presence.z2m_absorption"))do
a[#a+1]=c
end
local g=require"contracts.families.ef00.presence.wave11_general_1"for _,c in ipairs(b(g,"ef00.presence.wave11.general.1","contracts.families.ef00.presence.wave11_general_1"))do
a[#a+1]=c
end
local h=require"contracts.families.ef00.presence.wave11_general_2"for _,c in ipairs(b(h,"ef00.presence.wave11.general.2","contracts.families.ef00.presence.wave11_general_2"))do
a[#a+1]=c
end
local i=require"contracts.families.ef00.presence.wave11_switch"for _,c in ipairs(b(i,"ef00.presence.wave11.switch","contracts.families.ef00.presence.wave11_switch"))do
a[#a+1]=c
end
local j=require"contracts.families.ef00.presence.wave11_advanced"for _,c in ipairs(b(j,"ef00.presence.wave11.advanced","contracts.families.ef00.presence.wave11_advanced"))do
a[#a+1]=c
end
local k=require"contracts.families.ef00.presence.wave19_sensors"for _,c in ipairs(b(k,"ef00.presence.wave19.sensors","contracts.families.ef00.presence.wave19_sensors"))do
a[#a+1]=c
end
local l=require"contracts.families.ef00.presence.simple_sensors"for _,c in ipairs(b(l,"ef00.presence.simple_sensors","contracts.families.ef00.presence.simple_sensors"))do
a[#a+1]=c
end
return a
