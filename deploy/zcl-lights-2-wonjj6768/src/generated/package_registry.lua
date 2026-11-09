local function b(d,e,module_name)
assert(type(d)=="table","Canonical catalog must return a table: "..module_name)for k in next,d do
assert(k=="id"or k=="registrations","Canonical catalog has extra key: "..module_name ..":"..tostring(k))end
assert(d.id==e,"Canonical catalog id mismatch: "..module_name)assert(type(d.registrations)=="table","Canonical catalog registrations missing: "..module_name)return d.registrations
end
local a={}local f=require"contracts.families.zcl.lights.z2m_absorption"for _,c in ipairs(b(f,"zcl.lights.z2m_absorption","contracts.families.zcl.lights.z2m_absorption"))do
a[#a+1]=c
end
local g=require"contracts.families.zcl.lights.shelly_dimmer"for _,c in ipairs(b(g,"zcl.lights.shelly_dimmer","contracts.families.zcl.lights.shelly_dimmer"))do
a[#a+1]=c
end
local h=require"contracts.families.zcl.lights.wave19_exact_aliases"for _,c in ipairs(b(h,"zcl.lights.wave19_exact_aliases","contracts.families.zcl.lights.wave19_exact_aliases"))do
a[#a+1]=c
end
local i=require"contracts.families.zcl.lights.wave19_exact"for _,c in ipairs(b(i,"zcl.lights.wave19.exact","contracts.families.zcl.lights.wave19_exact"))do
a[#a+1]=c
end
local j=require"contracts.families.zcl.lights.philips_flux"for _,c in ipairs(b(j,"zcl.lights.philips_flux","contracts.families.zcl.lights.philips_flux"))do
a[#a+1]=c
end
return a
