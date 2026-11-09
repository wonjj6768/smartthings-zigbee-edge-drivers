local function b(d,e,module_name)
assert(type(d)=="table","Canonical catalog must return a table: "..module_name)for n in next,d do
assert(n=="id"or n=="registrations","Canonical catalog has extra key: "..module_name ..":"..tostring(n))end
assert(d.id==e,"Canonical catalog id mismatch: "..module_name)assert(type(d.registrations)=="table","Canonical catalog registrations missing: "..module_name)return d.registrations
end
local a={}local f=require"contracts.families.zcl.sensors.wave19_hvac"for _,c in ipairs(b(f,"zcl.sensors.wave19_hvac","contracts.families.zcl.sensors.wave19_hvac"))do
a[#a+1]=c
end
local g=require"contracts.families.zcl.thermostats.wave19_sber"for _,c in ipairs(b(g,"zcl.thermostats.wave19.sber","contracts.families.zcl.thermostats.wave19_sber"))do
a[#a+1]=c
end
local h=require"contracts.families.zcl.thermostats.aqara_w500"for _,c in ipairs(b(h,"zcl.thermostats.aqara_w500","contracts.families.zcl.thermostats.aqara_w500"))do
a[#a+1]=c
end
local i=require"contracts.families.zcl.thermostats.namron_edge"for _,c in ipairs(b(i,"zcl.thermostats.namron_edge","contracts.families.zcl.thermostats.namron_edge"))do
a[#a+1]=c
end
local j=require"contracts.families.zcl.thermostats.meg5779"for _,c in ipairs(b(j,"zcl.thermostats.meg5779","contracts.families.zcl.thermostats.meg5779"))do
a[#a+1]=c
end
local k=require"contracts.families.zcl.thermostats.owon_ac221"for _,c in ipairs(b(k,"zcl.thermostats.owon_ac221","contracts.families.zcl.thermostats.owon_ac221"))do
a[#a+1]=c
end
local l=require"contracts.families.zcl.thermostats.owon_ac201"for _,c in ipairs(b(l,"zcl.thermostats.owon_ac201","contracts.families.zcl.thermostats.owon_ac201"))do
a[#a+1]=c
end
local m=require"contracts.families.zcl.thermostats.nodon_irb"for _,c in ipairs(b(m,"zcl.thermostats.nodon_irb","contracts.families.zcl.thermostats.nodon_irb"))do
a[#a+1]=c
end
return a
