local p,t,i,a=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.zigbee.data_types"local f,s=i.definition_registry()local e,l,m,c,h,b=1030,64529,0,16,15360,8216





local function r(capability_id)
return assert(t[capability_id],"missing SONOFF presence emitter: "..capability_id)()
end
local function j(k)
k=type(k)=="table"and k.value or k
if type(k)~="number"then return nil end
return bit32.band(k,1)~=0
end
local function n(g)
g.minimum_interval=nil
g.maximum_interval=nil
g.reportable_change=nil
g.read_on_configure=false
g.read_only=true
return g
end
local d=r"sonoffSnzb03pr2DetectionDuration"local q={profile="sonoff-snzb03pr2-occupancy",zcl_clusters={n(p.cluster_attribute(e,m,{name="occupancy",endpoint=1,emit=t.occupancy(),data_type=a.Bitmap8,from_device=j})),p.illuminance{endpoint=1,configure_reporting=false,data_type=a.Uint16,read_only=true,read_on_configure=true},p.battery{endpoint=1,data_type=a.Uint8,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_only=true},p.cluster_attribute(e,c,{name="sonoff_snzb03pr2_detection_duration",endpoint=1,emit=d,data_type=a.Uint16,write_type=a.Uint16,numeric_range={minimum=5,maximum=60,step=1,unit="s"},read_on_configure=true}),p.cluster_attribute(e,h,{name="sonoff_snzb03pr2_detection_duration_raw_alias",endpoint=1,emit=d,data_type=a.Uint16,read_only=true,read_on_configure=false,read_on_refresh=false}),p.cluster_attribute(l,b,{name="sonoff_snzb03pr2_illumination_offset",endpoint=1,emit=r"sonoffSnzb03pr2IlluminationOffset",data_type=a.Int16,write_type=a.Int16,numeric_range={minimum=-1000,maximum=1000,step=1,unit="lx"},read_on_configure=true})}}s(q,{i.create_fingerprint("SONOFF","SNZB-03PR2")})p.attach_reporting_capabilities(f,{{1,"rpt-skz"}})return{id="zcl.sensors.sonoff_presence_advanced",registrations=f}
