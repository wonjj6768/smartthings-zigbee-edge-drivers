local s,n,a,m,c,r=require"protocol.tuya",require"protocol.zcl",require"st.zigbee.data_types",require"capabilities.events.all",require"contracts.helpers.family",require"contracts.helpers.ef00_presence"local q=s.converter
local k,e=r.isolated_definition_registry(c.definition_registry)local b,g,f,h,l,j,i=57346,57345,57348,57349,57353,57354,57355






local function d(t)
local p=tonumber(t)if p==nil then return nil end
if p==0 then return 0 end
return math.floor(10 ^((p-1)/10000)+0.5)
end
local o={profile="safety-occupancy-wave11-linptech-es1",magic_packet=true,package_group="z2m-ef00-pres-hyb",named_datapoints=true,datapoints={s.dp_numeric(101,{name="linptech_es_one_fading_time",emit=m.linptechEsOneFadingTime()})},zcl_clusters={n.occupancy{ias_zone=true,read_only=true},n.cluster_attribute(n.CLUSTER_ILLUMINANCE,n.ATTR_ILLUMINANCE_MEASURED_VALUE,{name="illuminance",data_type=a.Uint16,converter=q.from_only(d),emit=m.illuminance(),read_only=true}),n.cluster_attribute(b,j,{name="linptech_es_one_target_distance",data_type=a.Uint16,emit=m.linptechEsOneTargetDistance(),read_only=true}),n.cluster_attribute(b,i,{name="linptech_es_one_motion_detection_distance",data_type=a.Uint16,write_type=a.Uint16,emit=m.linptechEsOneMotionDistance(),read_only=false}),n.cluster_attribute(b,g,{name="linptech_es_one_presence_keep_time",data_type=a.Uint16,emit=m.linptechEsOneKeepTime(),read_only=true}),n.cluster_attribute(b,f,{name="linptech_es_one_motion_detection_sensitivity",data_type=a.Uint8,write_type=a.Uint8,emit=m.linptechEsOneMotionSensitivity(),read_only=false}),n.cluster_attribute(b,h,{name="linptech_es_one_static_detection_sensitivity",data_type=a.Uint8,write_type=a.Uint8,emit=m.linptechEsOneStaticSensitivity(),read_only=false}),n.cluster_attribute(b,l,{name="linptech_es_one_led_indicator",data_type=a.Boolean,write_type=a.Boolean,converter=q.lookup_from_to{ON=true,OFF=false},emit=m.linptechEsOneLedIndicator(),read_only=false})},query_on_configure=false}e(o,{c.create_fingerprint("_TZ3218_awarhusb","TS0225"),c.create_fingerprint("_TZ3218_t9ynfz4x","TS0225"),c.create_fingerprint("_TZ3218_ewrxirng","TS0225")})n.attach_reporting_capabilities(k,{{1,"rpt-txp"}})return{id="ef00.presence.wave11.advanced",registrations=k}
