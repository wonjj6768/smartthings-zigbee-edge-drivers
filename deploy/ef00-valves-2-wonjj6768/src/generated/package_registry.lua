local function b(c,e,module_name)
assert(type(c)=="table","Canonical catalog must return a table: "..module_name)for j in next,c do
assert(j=="id"or j=="registrations","Canonical catalog has extra key: "..module_name ..":"..tostring(j))end
assert(c.id==e,"Canonical catalog id mismatch: "..module_name)assert(type(c.registrations)=="table","Canonical catalog registrations missing: "..module_name)return c.registrations
end
local a={}local f=require"contracts.families.ef00.valves.z2m_absorption"for _,d in ipairs(b(f,"ef00.valves.z2m_absorption","contracts.families.ef00.valves.z2m_absorption"))do
a[#a+1]=d
end
local g=require"contracts.families.ef00.valves.neo_nas_wv03b2"for _,d in ipairs(b(g,"neo.nas_wv03b2","contracts.families.ef00.valves.neo_nas_wv03b2"))do
a[#a+1]=d
end
local h=require"contracts.families.ef00.valves.qoto_qt05m"for _,d in ipairs(b(h,"qoto.qt_05m","contracts.families.ef00.valves.qoto_qt05m"))do
a[#a+1]=d
end
local i=require"contracts.families.ef00.valves.wave19"for _,d in ipairs(b(i,"ef00.valves.wave19","contracts.families.ef00.valves.wave19"))do
a[#a+1]=d
end
return a
