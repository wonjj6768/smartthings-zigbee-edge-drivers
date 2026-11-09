local c,i,h,e,b=require"contracts.families.zcl.sensors.z2m_absorption_ewelink_7037",require"contracts.families.zcl.sensors.z2m_absorption_water",require"contracts.families.zcl.sensors.z2m_absorption_heiwa",require"contracts.families.zcl.sensors.linknlink",require"contracts.families.zcl.sensors.shelly_presence"local f,a={c,i,h,e,b},{}for _,g in ipairs(f)do
for _,d in ipairs(g.registrations)do
a[#a+1]=d
end
end
return{id="zcl.sensors.z2m_absorption",registrations=a}
