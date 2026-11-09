local function b(c,e,module_name)
assert(type(c)=="table","Canonical catalog must return a table: "..module_name)for i in next,c do
assert(i=="id"or i=="registrations","Canonical catalog has extra key: "..module_name ..":"..tostring(i))end
assert(c.id==e,"Canonical catalog id mismatch: "..module_name)assert(type(c.registrations)=="table","Canonical catalog registrations missing: "..module_name)return c.registrations
end
local a={}local f=require"contracts.families.zcl.covers.z2m_absorption"for _,d in ipairs(b(f,"zcl.covers.z2m_absorption","contracts.families.zcl.covers.z2m_absorption"))do
a[#a+1]=d
end
local g=require"contracts.families.zcl.covers.md_gate"for _,d in ipairs(b(g,"zcl.covers.md_gate","contracts.families.zcl.covers.md_gate"))do
a[#a+1]=d
end
local h=require"contracts.families.zcl.covers.somfy_tilt_lift"for _,d in ipairs(b(h,"zcl.covers.somfy_tilt_lift","contracts.families.zcl.covers.somfy_tilt_lift"))do
a[#a+1]=d
end
return a
