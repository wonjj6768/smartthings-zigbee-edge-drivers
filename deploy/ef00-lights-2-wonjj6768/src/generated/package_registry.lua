local function b(d,e,module_name)
assert(type(d)=="table","Canonical catalog must return a table: "..module_name)for l in next,d do
assert(l=="id"or l=="registrations","Canonical catalog has extra key: "..module_name ..":"..tostring(l))end
assert(d.id==e,"Canonical catalog id mismatch: "..module_name)assert(type(d.registrations)=="table","Canonical catalog registrations missing: "..module_name)return d.registrations
end
local a={}local f=require"contracts.families.ef00.lights.z2m_absorption"for _,c in ipairs(b(f,"ef00.lights.z2m_absorption","contracts.families.ef00.lights.z2m_absorption"))do
a[#a+1]=c
end
local g=require"contracts.families.ef00.moes_zs_d1"for _,c in ipairs(b(g,"moes.zs_d1","contracts.families.ef00.moes_zs_d1"))do
a[#a+1]=c
end
local h=require"contracts.families.ef00.moes_zs_d2"for _,c in ipairs(b(h,"moes.zs_d2","contracts.families.ef00.moes_zs_d2"))do
a[#a+1]=c
end
local i=require"contracts.families.ef00.moes_zs_d3"for _,c in ipairs(b(i,"moes.zs_d3","contracts.families.ef00.moes_zs_d3"))do
a[#a+1]=c
end
local j=require"contracts.families.ef00.lights.wave15_gledopto"for _,c in ipairs(b(j,"ef00.lights.wave15_gledopto","contracts.families.ef00.lights.wave15_gledopto"))do
a[#a+1]=c
end
local k=require"contracts.families.ef00.lights.wave19_exact"for _,c in ipairs(b(k,"ef00.lights.wave19.exact","contracts.families.ef00.lights.wave19_exact"))do
a[#a+1]=c
end
return a
