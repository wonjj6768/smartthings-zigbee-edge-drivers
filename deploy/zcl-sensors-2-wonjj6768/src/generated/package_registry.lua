local function b(d,e,module_name)
assert(type(d)=="table","Canonical catalog must return a table: "..module_name)for o in next,d do
assert(o=="id"or o=="registrations","Canonical catalog has extra key: "..module_name ..":"..tostring(o))end
assert(d.id==e,"Canonical catalog id mismatch: "..module_name)assert(type(d.registrations)=="table","Canonical catalog registrations missing: "..module_name)return d.registrations
end
local a={}local f=require"contracts.families.zcl.sensors.z2m_absorption"for _,c in ipairs(b(f,"zcl.sensors.z2m_absorption","contracts.families.zcl.sensors.z2m_absorption"))do
a[#a+1]=c
end
local g=require"contracts.families.zcl.sensors.wave19_exact_aliases"for _,c in ipairs(b(g,"zcl.sensors.wave19_exact_aliases","contracts.families.zcl.sensors.wave19_exact_aliases"))do
a[#a+1]=c
end
local h=require"contracts.families.zcl.sensors.wave19_environment"for _,c in ipairs(b(h,"zcl.sensors.wave19_environment","contracts.families.zcl.sensors.wave19_environment"))do
a[#a+1]=c
end
local i=require"contracts.families.zcl.sensors.wave19_smoke"for _,c in ipairs(b(i,"zcl.sensors.wave19_smoke","contracts.families.zcl.sensors.wave19_smoke"))do
a[#a+1]=c
end
local j=require"contracts.families.zcl.sensors.wave19_vibration"for _,c in ipairs(b(j,"zcl.sensors.wave19_vibration","contracts.families.zcl.sensors.wave19_vibration"))do
a[#a+1]=c
end
local k=require"contracts.families.zcl.sensors.sonoff"for _,c in ipairs(b(k,"zcl.sensors.sonoff","contracts.families.zcl.sensors.sonoff"))do
a[#a+1]=c
end
local l=require"contracts.families.zcl.sensors.sonoff_presence_advanced"for _,c in ipairs(b(l,"zcl.sensors.sonoff_presence_advanced","contracts.families.zcl.sensors.sonoff_presence_advanced"))do
a[#a+1]=c
end
local m=require"contracts.families.zcl.sensors.hobeian"for _,c in ipairs(b(m,"zcl.sensors.hobeian","contracts.families.zcl.sensors.hobeian"))do
a[#a+1]=c
end
local n=require"contracts.families.zcl.sensors.zg204zl"for _,c in ipairs(b(n,"zcl.sensors.zg204zl","contracts.families.zcl.sensors.zg204zl"))do
a[#a+1]=c
end
return a
