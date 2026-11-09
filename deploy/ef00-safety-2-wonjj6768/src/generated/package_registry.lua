local function b(d,e,module_name)
assert(type(d)=="table","Canonical catalog must return a table: "..module_name)for n in next,d do
assert(n=="id"or n=="registrations","Canonical catalog has extra key: "..module_name ..":"..tostring(n))end
assert(d.id==e,"Canonical catalog id mismatch: "..module_name)assert(type(d.registrations)=="table","Canonical catalog registrations missing: "..module_name)return d.registrations
end
local a={}local f=require"contracts.families.ef00.safety.z2m_absorption"for _,c in ipairs(b(f,"ef00.safety.z2m_absorption","contracts.families.ef00.safety.z2m_absorption"))do
a[#a+1]=c
end
local g=require"contracts.families.ef00.safety_neo_nas_ab06b2"for _,c in ipairs(b(g,"neo.nas_ab06b2","contracts.families.ef00.safety_neo_nas_ab06b2"))do
a[#a+1]=c
end
local h=require"contracts.families.ef00.safety_tuya_vibration_alarm"for _,c in ipairs(b(h,"tuya.vibration_alarm","contracts.families.ef00.safety_tuya_vibration_alarm"))do
a[#a+1]=c
end
local i=require"contracts.families.ef00.safety_neo_nas_ab02b2"for _,c in ipairs(b(i,"neo.nas_ab02b2","contracts.families.ef00.safety_neo_nas_ab02b2"))do
a[#a+1]=c
end
local j=require"contracts.families.ef00.safety_lincukoo_w04_z10t"for _,c in ipairs(b(j,"lincukoo.w04_z10t","contracts.families.ef00.safety_lincukoo_w04_z10t"))do
a[#a+1]=c
end
local k=require"contracts.families.ef00.safety_nous_e12"for _,c in ipairs(b(k,"nous.e12","contracts.families.ef00.safety_nous_e12"))do
a[#a+1]=c
end
local l=require"contracts.families.ef00.safety.wave15_lincukoo"for _,c in ipairs(b(l,"ef00.safety.wave15_lincukoo","contracts.families.ef00.safety.wave15_lincukoo"))do
a[#a+1]=c
end
local m=require"contracts.families.ef00.safety.wave16_lincukoo_siren"for _,c in ipairs(b(m,"ef00.safety.wave16_lincukoo_siren","contracts.families.ef00.safety.wave16_lincukoo_siren"))do
a[#a+1]=c
end
return a
