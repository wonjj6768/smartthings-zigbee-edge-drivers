local function b(c,e,module_name)
assert(type(c)=="table","Canonical catalog must return a table: "..module_name)for i in next,c do
assert(i=="id"or i=="registrations","Canonical catalog has extra key: "..module_name ..":"..tostring(i))end
assert(c.id==e,"Canonical catalog id mismatch: "..module_name)assert(type(c.registrations)=="table","Canonical catalog registrations missing: "..module_name)return c.registrations
end
local a={}local f=require"contracts.families.zcl.sensors.simple_sensors"for _,d in ipairs(b(f,"zcl.sensors.simple_sensors","contracts.families.zcl.sensors.simple_sensors"))do
a[#a+1]=d
end
local g=require"contracts.families.zcl.sensors.shelly_environment"for _,d in ipairs(b(g,"zcl.sensors.shelly_environment","contracts.families.zcl.sensors.shelly_environment"))do
a[#a+1]=d
end
local h=require"contracts.families.zcl.sensors.sonoff_safety"for _,d in ipairs(b(h,"zcl.sensors.sonoff_safety","contracts.families.zcl.sensors.sonoff_safety"))do
a[#a+1]=d
end
return a
