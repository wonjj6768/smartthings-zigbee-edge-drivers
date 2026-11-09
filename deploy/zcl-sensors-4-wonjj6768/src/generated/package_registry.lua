local function b(d,e,module_name)
assert(type(d)=="table","Canonical catalog must return a table: "..module_name)for n in next,d do
assert(n=="id"or n=="registrations","Canonical catalog has extra key: "..module_name ..":"..tostring(n))end
assert(d.id==e,"Canonical catalog id mismatch: "..module_name)assert(type(d.registrations)=="table","Canonical catalog registrations missing: "..module_name)return d.registrations
end
local a={}local f=require"contracts.families.zcl.sensors.zigbeetlc_dual"for _,c in ipairs(b(f,"zcl.sensors.zigbeetlc_dual","contracts.families.zcl.sensors.zigbeetlc_dual"))do
a[#a+1]=c
end
local g=require"contracts.families.zcl.sensors.multir_mirsr100"for _,c in ipairs(b(g,"zcl.sensors.multir_mirsr100","contracts.families.zcl.sensors.multir_mirsr100"))do
a[#a+1]=c
end
local h=require"contracts.families.zcl.sensors.heiman_m_safety"for _,c in ipairs(b(h,"zcl.sensors.heiman_m_safety","contracts.families.zcl.sensors.heiman_m_safety"))do
a[#a+1]=c
end
local i=require"contracts.families.zcl.sensors.somfy_opening"for _,c in ipairs(b(i,"zcl.sensors.somfy_opening","contracts.families.zcl.sensors.somfy_opening"))do
a[#a+1]=c
end
local j=require"contracts.families.zcl.sensors.shelly_outdoor"for _,c in ipairs(b(j,"zcl.sensors.shelly_outdoor","contracts.families.zcl.sensors.shelly_outdoor"))do
a[#a+1]=c
end
local k=require"contracts.families.zcl.sensors.zigbeetlc_zgzv_additions"for _,c in ipairs(b(k,"zcl.sensors.zigbeetlc_zgzv_additions","contracts.families.zcl.sensors.zigbeetlc_zgzv_additions"))do
a[#a+1]=c
end
local l=require"contracts.families.zcl.sensors.contact_water_additions"for _,c in ipairs(b(l,"zcl.sensors.contact_water_additions","contracts.families.zcl.sensors.contact_water_additions"))do
a[#a+1]=c
end
local m=require"contracts.families.zcl.sensors.passive_alarm_additions"for _,c in ipairs(b(m,"zcl.sensors.passive_alarm_additions","contracts.families.zcl.sensors.passive_alarm_additions"))do
a[#a+1]=c
end
return a
