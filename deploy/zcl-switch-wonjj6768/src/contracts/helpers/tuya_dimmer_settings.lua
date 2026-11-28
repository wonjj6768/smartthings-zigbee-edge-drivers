local r,b,e=require"protocol.zcl",require"st.zigbee.data_types",require"st.zigbee.cluster_base"
local function o(k,a,c,n)
local m=a.to_device(c)if m==nil then return false end
k:send(e.write_attribute(k,b.ClusterId(57345),b.AttributeId(a.attribute_id),b.Enum8(m)):to_endpoint(n.endpoint or 1))return true
end
local function p(d)
for _,g in ipairs(d)do
local h=g.fingerprints[1]if h.model=="TS0052"or
(h.manufacturer=="_TZ3000_j0ktmul1"and h.model=="TS011F")then
for i,a in ipairs(g.zcl_clusters)do
local name=a.name
if name=="power_on_behavior"or name=="switch_type"then
local l,f=name=="power_on_behavior"and{[0]="off","on","previous"}or{[0]="toggle","state","momentary"},{}for m,q in pairs(l)do f[q]=m end
g.zcl_clusters[i]=r.cluster_attribute(57345,name=="power_on_behavior"and 53264 or 53296,{name=name,endpoint=a.endpoint,component=a.component,emit=a.emit,data_type=b.Enum8,write_type=b.Enum8,read_on_configure=true,
from_device=function(c)return l[c]end,
to_device=function(c)return f[c]end,
sender=o})end
end
end
end
end
return{apply=p}
