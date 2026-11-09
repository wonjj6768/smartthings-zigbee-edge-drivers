local c,a=require"contracts.helpers.family",{}
function a.ts0601_fingerprints(b)
return c.create_fingerprints("TS0601",b)
end
function a.capability_values(e)
local d={}for _,f in ipairs(e or{})do
d[#d+1]=f
end
return d
end
return a
