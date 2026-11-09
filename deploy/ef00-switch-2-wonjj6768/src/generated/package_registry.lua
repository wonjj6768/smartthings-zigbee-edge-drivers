local function b(d,e,module_name)
assert(type(d)=="table","Canonical catalog must return a table: "..module_name)for q in next,d do
assert(q=="id"or q=="registrations","Canonical catalog has extra key: "..module_name ..":"..tostring(q))end
assert(d.id==e,"Canonical catalog id mismatch: "..module_name)assert(type(d.registrations)=="table","Canonical catalog registrations missing: "..module_name)return d.registrations
end
local a={}local h=require"contracts.families.ef00.switch_basic_z2m_absorption"for _,c in ipairs(b(h,"ef00.switch.basic.z2m_absorption","contracts.families.ef00.switch_basic_z2m_absorption"))do
a[#a+1]=c
end
local i=require"contracts.families.ef00.switch_panel_z2m_absorption"for _,c in ipairs(b(i,"ef00.switch.panel.z2m_absorption","contracts.families.ef00.switch_panel_z2m_absorption"))do
a[#a+1]=c
end
local j=require"contracts.families.ef00.switch_star_feather"for _,c in ipairs(b(j,"ef00.switch.star_feather","contracts.families.ef00.switch_star_feather"))do
a[#a+1]=c
end
local k=require"contracts.families.ef00.screen_switch_z2m_absorption"for _,c in ipairs(b(k,"ef00.screen_switch.z2m_absorption","contracts.families.ef00.screen_switch_z2m_absorption"))do
a[#a+1]=c
end
local l=require"contracts.families.ef00.switches.wave13_avatto"for _,c in ipairs(b(l,"ef00.switches.wave13.avatto","contracts.families.ef00.switches.wave13_avatto"))do
a[#a+1]=c
end
local m=require"contracts.families.ef00.switches.wave13_box"for _,c in ipairs(b(m,"ef00.switches.wave13.box","contracts.families.ef00.switches.wave13_box"))do
a[#a+1]=c
end
local n=require"contracts.families.ef00.switches.wave13_manhot"for _,c in ipairs(b(n,"ef00.switches.wave13.manhot","contracts.families.ef00.switches.wave13_manhot"))do
a[#a+1]=c
end
local o=require"contracts.families.ef00.switches.wave13_nova_semicom"for _,c in ipairs(b(o,"ef00.switches.wave13.nova_semicom","contracts.families.ef00.switches.wave13_nova_semicom"))do
a[#a+1]=c
end
local p=require"contracts.families.ef00.switches.wave14_qa"for _,c in ipairs(b(p,"wave14.qa.legacy_switches","contracts.families.ef00.switches.wave14_qa"))do
a[#a+1]=c
end
local f=require"contracts.families.ef00.switches.wave15_box"for _,c in ipairs(b(f,"ef00.switches.wave15_box","contracts.families.ef00.switches.wave15_box"))do
a[#a+1]=c
end
local g=require"contracts.families.ef00.switches.oxt"for _,c in ipairs(b(g,"ef00.switch.oxt4","contracts.families.ef00.switches.oxt"))do
a[#a+1]=c
end
return a
