local j,k,l,g,e,b,f,c=require"contracts.families.zcl.sensors.general",require"contracts.families.zcl.sensors.safety",require"contracts.families.zcl.sensors.sirens",require"contracts.families.zcl.sensors.repeaters",require"contracts.families.zcl.sensors.thermostats",require"contracts.families.zcl.sensors.retail_sensors",require"contracts.families.zcl.sensors.aqara_lumi",require"contracts.families.zcl.sensors.shelly_retail"local h,a={j,k,l,g,e,b,f,c},{}for _,i in ipairs(h)do
for _,d in ipairs(i.registrations)do
a[#a+1]=d
end
end
return{id="zcl.sensors",registrations=a}
