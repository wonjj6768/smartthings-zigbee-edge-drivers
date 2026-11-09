local function b(c,e,module_name)
assert(type(c)=="table","Canonical catalog must return a table: "..module_name)for j in next,c do
assert(j=="id"or j=="registrations","Canonical catalog has extra key: "..module_name ..":"..tostring(j))end
assert(c.id==e,"Canonical catalog id mismatch: "..module_name)assert(type(c.registrations)=="table","Canonical catalog registrations missing: "..module_name)return c.registrations
end
local a={}local f=require"contracts.families.zcl.controls.z2m_absorption"for _,d in ipairs(b(f,"zcl.controls.z2m_absorption","contracts.families.zcl.controls.z2m_absorption"))do
a[#a+1]=d
end
local g=require"contracts.families.zcl.controls.jethome"for _,d in ipairs(b(g,"zcl.controls.jethome","contracts.families.zcl.controls.jethome"))do
a[#a+1]=d
end
local h=require"contracts.families.zcl.controls.sonoff"for _,d in ipairs(b(h,"zcl.controls.sonoff","contracts.families.zcl.controls.sonoff"))do
a[#a+1]=d
end
local i=require"contracts.families.zcl.controls.ikea_e1766"for _,d in ipairs(b(i,"zcl.controls.ikea_e1766","contracts.families.zcl.controls.ikea_e1766"))do
a[#a+1]=d
end
return a
