local b,i,e,c,f=require"contracts.families.ef00.sensors.temp_humidity",require"contracts.families.ef00.sensors.soil",require"contracts.families.ef00.sensors.air_quality",require"contracts.families.ef00.sensors.liquid_level",require"contracts.families.ef00.sensors.illuminance"local g,a={b,i,e,c,f},{}for _,h in ipairs(g)do
for _,d in ipairs(h.registrations)do
a[#a+1]=d
end
end
return{id="ef00.sensors",registrations=a}
