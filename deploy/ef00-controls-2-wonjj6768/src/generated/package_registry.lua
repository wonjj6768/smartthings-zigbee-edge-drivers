local function b(d,e,module_name)
assert(type(d)=="table","Canonical catalog must return a table: "..module_name)for k in next,d do
assert(k=="id"or k=="registrations","Canonical catalog has extra key: "..module_name ..":"..tostring(k))end
assert(d.id==e,"Canonical catalog id mismatch: "..module_name)assert(type(d.registrations)=="table","Canonical catalog registrations missing: "..module_name)return d.registrations
end
local a={}local f=require"contracts.families.ef00.controls.wave15_engo"for _,c in ipairs(b(f,"ef00.controls.wave15_engo","contracts.families.ef00.controls.wave15_engo"))do
a[#a+1]=c
end
local g=require"contracts.families.ef00.controls.wave17_fingerbot"for _,c in ipairs(b(g,"ef00.controls.wave17_fingerbot","contracts.families.ef00.controls.wave17_fingerbot"))do
a[#a+1]=c
end
local h=require"contracts.families.ef00.controls.tuya_fingerbot_plus"for _,c in ipairs(b(h,"ef00.controls.tuya_fingerbot_plus","contracts.families.ef00.controls.tuya_fingerbot_plus"))do
a[#a+1]=c
end
local i=require"contracts.families.ef00.controls.wave18_keypads"for _,c in ipairs(b(i,"ef00.controls.wave18_keypads","contracts.families.ef00.controls.wave18_keypads"))do
a[#a+1]=c
end
local j=require"contracts.families.ef00.controls.wave19_remotes"for _,c in ipairs(b(j,"ef00.controls.wave19.remotes","contracts.families.ef00.controls.wave19_remotes"))do
a[#a+1]=c
end
return a
