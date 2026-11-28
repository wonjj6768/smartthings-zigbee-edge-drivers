local j,h,e=require"protocol.zcl",require"capabilities.events.all",require"st.zigbee.data_types"
local function f(c)
for _,d in ipairs(c)do
local g=d.fingerprints[1]if g.model=="TS1101"or g.model=="TS0052"or
g.manufacturer=="_TYZB01_qezuin6k"or g.manufacturer=="_TYZB01_v8gtiaed"then
for i,b in ipairs(d.zcl_clusters)do
if b.name=="min_brightness"then
d.zcl_clusters[i]=j.cluster_attribute(8,64512,{name="min_brightness",endpoint=b.endpoint,component=b.component,data_type=e.Uint16,write_type=e.Uint16,read_on_configure=true,emit=h.minimumBrightnessTsOneTenMax(),numeric_range={minimum=1,maximum=255,step=1},
from_device=function(a)return math.floor(a/256)%256 end,
to_device=function(a)
if type(a)~="number"or a%1~=0 or a<1 or a>255 then return nil end
return a*256+255
end
})end
end
end
end
end
return{apply=f}
