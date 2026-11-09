local k,d,l,g,h,f,j,b,m=require"contracts.families.zcl.controls.remotes",require"contracts.families.zcl.controls.advanced",require"contracts.families.zcl.controls.scene",require"contracts.families.zcl.controls.excellux",require"contracts.families.zcl.controls.security",require"contracts.families.zcl.controls.doorbell",require"contracts.families.zcl.controls.dimming",require"contracts.families.zcl.controls.scene_switches",require"contracts.families.zcl.controls.ir"local e,a={k,d,l,g,h,f,j,b,m},{}for _,i in ipairs(e)do
for _,c in ipairs(i.registrations)do
a[#a+1]=c
end
end
return{id="zcl.controls",registrations=a}
