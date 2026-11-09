local h,b=require"protocol.zcl",require"contracts.helpers.family"local d,i=b.definition_registry()local a={profile="zg204zl-ias-motion-battery",magic_packet=false,zcl_clusters={h.motion{endpoint=1,read_only=true,read_on_configure=false,
from_device=function(c)
if type(c)=="table"then c=c.value end
return bit32.band(c,1)~=0
end
},h.battery{endpoint=1,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,
from_device=function(c,_,f)
local j=f and f.raw_value or c
if j==255 then return nil end
return f and c or j/2
end
}},
parent_refresh=function(g,e)
h.read_named_attribute(g,e.zcl_clusters,"motion",{endpoint=1})h.read_named_attribute(g,e.zcl_clusters,"battery",{endpoint=1})
end
}a.zcl_clusters[1].minimum_interval=nil
a.zcl_clusters[1].maximum_interval=nil
a.zcl_clusters[1].reportable_change=nil
i(a,{b.create_fingerprint("_TZ3000_hgbahzmy","ZG-204Z")})h.attach_reporting_capabilities(d,{{1,"rpt-zsl"}})return{id="zcl.sensors.zg204zl",registrations=d}
