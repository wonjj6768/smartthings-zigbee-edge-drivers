local function b(d,e,module_name)
assert(type(d)=="table","Canonical catalog must return a table: "..module_name)for k in next,d do
assert(k=="id"or k=="registrations","Canonical catalog has extra key: "..module_name ..":"..tostring(k))end
assert(d.id==e,"Canonical catalog id mismatch: "..module_name)assert(type(d.registrations)=="table","Canonical catalog registrations missing: "..module_name)return d.registrations
end
local a={}local f=require"contracts.families.zcl.switches.z2m_absorption"for _,c in ipairs(b(f,"zcl.switches.z2m_absorption","contracts.families.zcl.switches.z2m_absorption"))do
a[#a+1]=c
end
local g=require"contracts.families.zcl.switches.shelly_em"for _,c in ipairs(b(g,"zcl.switches.shelly_em","contracts.families.zcl.switches.shelly_em"))do
a[#a+1]=c
end
local h=require"contracts.families.zcl.switches.wave14_sber_zcl"for _,c in ipairs(b(h,"wave14.sber.zcl_switches","contracts.families.zcl.switches.wave14_sber_zcl"))do
a[#a+1]=c
end
local i=require"contracts.families.zcl.switches.wave14_terncy_zcl"for _,c in ipairs(b(i,"wave14.terncy.zcl_switch","contracts.families.zcl.switches.wave14_terncy_zcl"))do
a[#a+1]=c
end
local j=require"contracts.families.zcl.switches.emizb132"for _,c in ipairs(b(j,"zcl.switches.emizb132","contracts.families.zcl.switches.emizb132"))do
a[#a+1]=c
end
return a
