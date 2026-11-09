local f,e,i,b,h=require"contracts.families.zcl.switches.switches",require"contracts.families.zcl.switches.din_rail",require"contracts.families.zcl.switches.valves",require"contracts.families.zcl.switches.retail_switches",require"contracts.families.zcl.switches.easyiot"local d,a={f,e,i,b,h},{}for _,g in ipairs(d)do
for _,c in ipairs(g.registrations)do
a[#a+1]=c
end
end
return{id="zcl.switches",registrations=a}
