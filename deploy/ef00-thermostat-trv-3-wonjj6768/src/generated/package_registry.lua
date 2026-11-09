local function b(d,e,module_name)
assert(type(d)=="table","Canonical catalog must return a table: "..module_name)for m in next,d do
assert(m=="id"or m=="registrations","Canonical catalog has extra key: "..module_name ..":"..tostring(m))end
assert(d.id==e,"Canonical catalog id mismatch: "..module_name)assert(type(d.registrations)=="table","Canonical catalog registrations missing: "..module_name)return d.registrations
end
local a={}local f=require"contracts.families.ef00.thermostats.wave6a_trv"for _,c in ipairs(b(f,"ef00.thermostats.wave6a_trv","contracts.families.ef00.thermostats.wave6a_trv"))do
a[#a+1]=c
end
local g=require"contracts.families.ef00.thermostats.wave9_mazda"for _,c in ipairs(b(g,"ef00.thermostats.wave9_mazda","contracts.families.ef00.thermostats.wave9_mazda"))do
a[#a+1]=c
end
local h=require"contracts.families.ef00.thermostats.wave9_legacy"for _,c in ipairs(b(h,"ef00.thermostats.wave9_legacy","contracts.families.ef00.thermostats.wave9_legacy"))do
a[#a+1]=c
end
local i=require"contracts.families.ef00.thermostats.wave12_trv"for _,c in ipairs(b(i,"ef00.thermostats.wave12_trv","contracts.families.ef00.thermostats.wave12_trv"))do
a[#a+1]=c
end
local j=require"contracts.families.ef00.thermostats.wave19_exact_aliases"for _,c in ipairs(b(j,"ef00.thermostats.wave19_exact_aliases","contracts.families.ef00.thermostats.wave19_exact_aliases"))do
a[#a+1]=c
end
local k=require"contracts.families.ef00.thermostats.wave15_trv"for _,c in ipairs(b(k,"ef00.thermostats.wave15_trv","contracts.families.ef00.thermostats.wave15_trv"))do
a[#a+1]=c
end
local l=require"contracts.families.ef00.thermostats.wave19_exact"for _,c in ipairs(b(l,"ef00.thermostats.wave19.exact","contracts.families.ef00.thermostats.wave19_exact"))do
a[#a+1]=c
end
return a
