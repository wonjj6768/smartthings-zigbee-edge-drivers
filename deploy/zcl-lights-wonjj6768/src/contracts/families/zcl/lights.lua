local h,f,g,j,i,k,c=require"contracts.families.zcl.lights.lights",require"contracts.families.zcl.lights.dimmers",require"contracts.families.zcl.lights.miboxer",require"contracts.families.zcl.lights.fans",require"contracts.families.zcl.lights.retail",require"contracts.families.zcl.lights.ikea",require"contracts.families.zcl.lights.schneider"local d,a={h,f,g,j,i,k,c},{}for _,e in ipairs(d)do
for _,b in ipairs(e.registrations)do
a[#a+1]=b
end
end
return{id="zcl.lights",registrations=a}
