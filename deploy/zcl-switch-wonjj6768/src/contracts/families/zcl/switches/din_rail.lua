local g,A,b,c,n,r=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"contracts.helpers.zcl",require"st.zigbee.data_types",require"st.zigbee.device_management"local k,a=b.definition_registry()
local function i()
return c.metering_clusters{include_switch=true,include_current=true}
end
local function e(w)
return g.cluster_attribute(g.CLUSTER_ON_OFF,32769,{name="ts011f_din_indicator_mode",emit=A.ts011fDinIndicatorMode(),data_type=n.Enum8,write_type=n.Enum8,
from_device=function(value)
return({[0]="off",[1]=w and"on_off"or"off_on",[2]=w and"off_on"or"on_off"})[value]
end,
to_device=function(value)
return({off=0,off_on=w and 2 or 1,on_off=w and 1 or 2})[value]
end,
read_on_configure=true})
end
local function d(D,z,y)
return function(value,m)
local f=m:get_latest_state("main",z,y)or 0
f=math.floor((tonumber(f)or 0)+0.5)f=math.max(0,math.min(65535,f))return string.char(D,value=="on"and 1 or 0,(((((f)&0xFFFFFFFF)>>(8)))&(255)),((f)&(255)))
end
end
local j=i()c.append_clusters(j,g.tuya_magic_packet(),g.tuya_power_outage_memory(),e(true))local s={profile="din-rail-ts011f-metered",zcl_clusters=j}local q={profile="din-rail-ts011f-unmetered",zcl_clusters={c.switch_cluster(),g.tuya_magic_packet(),g.tuya_power_outage_memory(),e(true)},
configure=function(C,m)
m:send(r.build_bind_request(m,g.CLUSTER_ON_OFF,C.environment_info.hub_zigbee_eui,1))
end
}local u,v={profile="meters-power-energy-battery",zcl_clusters={g.cluster_attribute(1794,1024,{name="power",read_only=true,data_type=n.Int24,emit=A.power(),scale=1,ignore_reported_scaler=true,metering_kind="power",poll_interval=300,read_on_configure=true,minimum_interval=5,maximum_interval=300,reportable_change=1}),g.energy{scale=1000,ignore_reported_scaler=true,poll_interval=900},g.battery()}},{profile="meters-power-energy",zcl_clusters={g.power{endpoint=2},g.energy{endpoint=2,poll_interval=900}}}
local function h(B,o)
local t=i()c.append_clusters(t,g.tuya_magic_packet(),e(),g.tuya_power_outage_memory(),g.countdown_timer(),g.child_lock(),g.power_threshold(),g.power_breaker(),g.over_current_threshold{name="ts011f_din_over_current_threshold",emit=A.ts011fDinOverCurrentThreshold(),numeric_range={minimum=1,maximum=65,step=1,unit="A"}},g.over_current_breaker{to_device=d(1,"concertmirror08464.ts011fDinOverCurrentThreshold","overCurrentThreshold")},g.over_voltage_threshold{name="ts011f_din_over_voltage_threshold",emit=A.ts011fDinOverVoltageThreshold(),numeric_range={minimum=90,maximum=265,step=1,unit="V"}},g.over_voltage_breaker{
to_device=function(value,m)
local f=tonumber(m:get_latest_state("main","concertmirror08464.ts011fDinOverVoltageThreshold","overVoltageThreshold"))or 0
f=math.max(0,math.min(65535,math.floor(f+0.5)))return string.pack(">BBI2",3,value=="on"and 1 or 0,f)
end
},g.under_voltage_threshold{name="ts011f_din_under_voltage_threshold",emit=A.ts011fDinUnderVoltageThreshold(),numeric_range={minimum=75,maximum=240,step=1,unit="V"}},g.under_voltage_breaker{to_device=d(4,"concertmirror08464.ts011fDinUnderVoltageThreshold","underVoltageThreshold")})if o then
c.append_clusters(t,g.temperature(),g.temperature_threshold(),g.temperature_breaker())end
return{profile=B,zcl_clusters=t}
end
local p,l=h("din-rail-switch-power-energy-voltage-current-threshold",true),h("din-rail-switch-power-energy-voltage-current-threshold-no-temp",false)a(s,b.create_fingerprints("TS011F",{"_TZ3000_8bxrzyxz","_TZ3000_ky0fq4ho","_TZ3000_qeuvnohg","_TZ3000_6l1pjfqe","_TZ3000_2iiimqs9","_TZ3000_viqwamhn","_TZ3210_vbfp8eyv"}))a(q,{b.create_fingerprint("_TZ3000_7issjl2q","TS011F"),b.create_fingerprint("_TZ3000_gzvniqjb","TS0011")})a(u,{b.create_fingerprint("frient A/S","EMIZB-141")})a(v,{b.create_fingerprint("frient A/S","EMIZB-151")})a(p,b.create_fingerprints("TS011F",{"_TZ3000_cayepv1a","_TZ3000_lepzuhto","_TZ3000_qystbcjg","_TZ3000_zrm3oxsh","_TZ3000_zv6x8bt2","_TZ3000_yi0n4xfd","_TZ3000_3o7r0mno"}))a(l,b.create_fingerprints("TS011F",{"_TZ3000_303avxxt","_TZ3000_ibefeicf","_TZ3000_zjchz7pd"}))g.attach_reporting_capabilities(k,{{1,"rpt-tiq"},{2,"rpt-tun"},{3,"rpt-epv"},{4,"rpt-eqg"},{5,"rpt-txjg"},{6,"rpt-tonj"}})return{id="zcl.switches.din_rail",registrations=k}
