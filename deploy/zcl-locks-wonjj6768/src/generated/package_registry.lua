local function c(a,d,module_name)
assert(type(a)=="table","Canonical catalog must return a table: "..module_name)for h in next,a do
assert(h=="id"or h=="registrations","Canonical catalog has extra key: "..module_name ..":"..tostring(h))end
assert(a.id==d,"Canonical catalog id mismatch: "..module_name)assert(type(a.registrations)=="table","Canonical catalog registrations missing: "..module_name)return a.registrations
end
local b={}local f=require"contracts.families.zcl.controls.wave18_javis_lock"for _,e in ipairs(c(f,"zcl.controls.wave18_javis_lock","contracts.families.zcl.controls.wave18_javis_lock"))do
b[#b+1]=e
end
local g=require"contracts.families.zcl.controls.yale_yrd410"for _,e in ipairs(c(g,"zcl.controls.yale_yrd410","contracts.families.zcl.controls.yale_yrd410"))do
b[#b+1]=e
end
return b
