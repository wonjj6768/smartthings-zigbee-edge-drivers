local f,z,b,c,m,q=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"contracts.helpers.zcl",require"st.zigbee.data_types",require"st.zigbee.device_management"local k,a=b.definition_registry()
local function h()
return c.metering_clusters{include_switch=true,include_current=true}
end
local function e()
return f.cluster_attribute(f.CLUSTER_ON_OFF,32769,{name="ts011f_din_indicator_mode",emit=z.ts011fDinIndicatorMode(),data_type=m.Enum8,write_type=m.Enum8,
from_device=function(value)
return({[0]="off",[1]="off_on",[2]="on_off"})[value]
end,
to_device=function(value)
return({off=0,off_on=1,on_off=2})[value]
end,
read_on_configure=true})
end
local function d(C,x,w)
return function(value,v)
local i=v:get_latest_state("main",x,w)or 0
i=math.floor((tonumber(i)or 0)+0.5)i=math.max(0,math.min(65535,i))return string.char(C,value=="on"and 1 or 0,bit32.band(bit32.rshift(i,8),255),bit32.band(i,255))
end
end
local j=h()c.append_clusters(j,f.tuya_magic_packet(),f.tuya_power_outage_memory(),e())local r={profile="din-rail-ts011f-metered",zcl_clusters=j}local p={profile="din-rail-ts011f-unmetered",zcl_clusters={c.switch_cluster(),f.tuya_magic_packet(),f.tuya_power_outage_memory(),e()},
configure=function(B,v)
v:send(q.build_bind_request(v,f.CLUSTER_ON_OFF,B.environment_info.hub_zigbee_eui,1))
end
}local t,u={profile="meters-power-energy-battery",zcl_clusters={f.cluster_attribute(1794,1024,{name="power",read_only=true,data_type=m.Int24,emit=z.power(),scale=1,ignore_reported_scaler=true,metering_kind="power",poll_interval=300,read_on_configure=true,minimum_interval=5,maximum_interval=300,reportable_change=1}),f.energy{scale=1000,ignore_reported_scaler=true,poll_interval=900},f.battery()}},{profile="meters-power-energy",zcl_clusters={f.power{endpoint=2},f.energy{endpoint=2,poll_interval=900}}}
local function g(A,n)
local s=h()c.append_clusters(s,f.tuya_magic_packet(),e(),f.tuya_power_outage_memory(),f.countdown_timer(),f.child_lock(),f.power_threshold(),f.power_breaker(),f.over_current_threshold{name="ts011f_din_over_current_threshold",emit=z.ts011fDinOverCurrentThreshold(),numeric_range={minimum=1,maximum=65,step=1,unit="A"}},f.over_current_breaker{to_device=d(1,"concertmirror08464.ts011fDinOverCurrentThreshold","overCurrentThreshold")},f.over_voltage_threshold(),f.over_voltage_breaker(),f.under_voltage_threshold{name="ts011f_din_under_voltage_threshold",emit=z.ts011fDinUnderVoltageThreshold(),numeric_range={minimum=75,maximum=240,step=1,unit="V"}},f.under_voltage_breaker{to_device=d(4,"concertmirror08464.ts011fDinUnderVoltageThreshold","underVoltageThreshold")})if n then
c.append_clusters(s,f.temperature(),f.temperature_threshold(),f.temperature_breaker())end
return{profile=A,zcl_clusters=s}
end
local o,l=g("din-rail-switch-power-energy-voltage-current-threshold",true),g("din-rail-switch-power-energy-voltage-current-threshold-no-temp",false)a(r,b.create_fingerprints("TS011F",{"_TZ3000_8bxrzyxz","_TZ3000_ky0fq4ho","_TZ3000_qeuvnohg","_TZ3000_6l1pjfqe","_TZ3000_2iiimqs9","_TZ3000_viqwamhn","_TZ3210_vbfp8eyv"}))a(p,{b.create_fingerprint("_TZ3000_7issjl2q","TS011F"),b.create_fingerprint("_TZ3000_gzvniqjb","TS0011")})a(t,{b.create_fingerprint("frient A/S","EMIZB-141")})a(u,{b.create_fingerprint("frient A/S","EMIZB-151")})a(o,b.create_fingerprints("TS011F",{"_TZ3000_cayepv1a","_TZ3000_lepzuhto","_TZ3000_qystbcjg","_TZ3000_zrm3oxsh","_TZ3000_zv6x8bt2","_TZ3000_yi0n4xfd","_TZ3000_3o7r0mno"}))a(l,b.create_fingerprints("TS011F",{"_TZ3000_303avxxt","_TZ3000_ibefeicf","_TZ3000_zjchz7pd"}))f.attach_reporting_capabilities(k,{{1,"rpt-tiq"},{2,"rpt-tun"},{3,"rpt-epv"},{4,"rpt-eqg"},{5,"rpt-txj"},{6,"rpt-ton"}})return{id="zcl.switches.din_rail",registrations=k}
