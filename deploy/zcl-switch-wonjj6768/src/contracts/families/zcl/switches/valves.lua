local g,i,b,m,k=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.zigbee.device_management",require"contracts.helpers.tuya_dimmer_settings"local e,a=b.definition_registry()
local function f(p)
return function(v,s)
for n=1,p do
s:send(m.build_bind_request(s,g.CLUSTER_ON_OFF,v.environment_info.hub_zigbee_eui,n))end
end
end
local function encode_uint32_be(c)
return string.char(math.floor(c/16777216)%256,math.floor(c/65536)%256,math.floor(c/256)%256,c%256)
end
local h={profile="valves-valve-indicator-mode",zcl_clusters={g.switch("valve",{emit=i.valve(),
from_device=function(c)
if c then
return"open"end
return"closed"
end
}),g.indicator_mode(),g.tuya_magic_packet()},configure=f(1)}local l={profile="valves-valve-battery",zcl_clusters={g.switch("valve",{emit=i.valve(),
from_device=function(c)
if c then
return"open"end
return"closed"
end
}),g.battery()}}local q={profile="valves-lyai14-minimal",datapoints={{dp=1,datatype=1,name="valve_report",read_only=true,
from_device=function(c)return c and"open"or"closed"end,emit=i.valve()},
{dp=101,datatype=4,name="lyai_rain_state",read_only=true,
from_device=function(c)return({[0]="rain",[1]="no_rain"})[c]end,emit=i.lyaiRainState()},
{dp=102,datatype=1,name="lyai_rain_enabled",read_only=false,
from_device=function(c)return c and"on"or"off"end,
to_device=function(c)return({on=true,off=false})[c]end,emit=i.lyaiRainEnabled()},
{dp=103,datatype=4,name="lyai_charge_state",read_only=true,
from_device=function(c)return({[0]="no_charge",[1]="charging",[2]="charged"})[c]end,emit=i.lyaiChargeState()}
},zcl_clusters={g.tuya_magic_packet(),g.switch("valve",{emit=i.valve(),
from_device=function(c)
if c then
return"open"end
return"closed"
end
}),g.battery()}}local j={profile="valves-haozee-hz-wt02",zcl_clusters={g.switch("valve",{emit=i.valve(),
from_device=function(c)
if c then
return"open"end
return"closed"
end
}),g.battery(),g.ts0049_countdown_timer{name="haozee_hz_wt02_water_countdown",emit=i.haozeeHzWt02WaterCountdown(),
to_device=function(c)
local u=math.floor(tonumber(c)+0.5)return string.char(11)..encode_uint32_be(u*60)
end,
numeric_range={minimum=1,maximum=1440,step=1,unit="min"}}}}
local function d(n,r)
return g.switch("valve",{endpoint=n,component=r,emit=i.valve(),
from_device=function(c)
if c then
return"open"end
return"closed"
end
})
end
local o={profile="valves-valve-5",zcl_clusters={d(1,"main"),d(2,"valve2"),d(3,"valve3"),d(4,"valve4"),d(5,"valve5"),g.tuya_magic_packet(),g.power_on_behavior(),g.child_lock(),g.countdown_timer()},configure=f(5)}a(h,b.create_fingerprints("TS0111",{"_TYZB01_ymcdbl3u"}))a(h,b.create_fingerprints("TS011F",{"_TZ3000_rk2yzt0u","_TZ3000_o4cjetlm"}))a(h,b.create_fingerprints("TS0001",{"_TZ3000_o4cjetlm","_TZ3000_iedbgyxt","_TZ3000_h3noz0a5","_TYZB01_4tlksk8a","_TZ3000_5ucujjts","_TZ3000_h8ngtlxy","_TZ3000_w0ypwa1f","_TZ3000_wpueorev","_TZ3000_cmcjbqup"}))a(h,b.create_fingerprints("TS0011",{"_TYZB01_rifa0wlb"}))a(l,b.create_fingerprints("TS0049",{"_TZ3000_5af5r192","_TZ3000_cjfmu5he","_TZ3000_mq4wujmp","_TZ3000_ogjpfoyn"}))a(l,{b.create_fingerprint("UHome","TWV")})a(j,b.create_fingerprints("TS0049",{"_TZ3000_kz1anoi8"}))a(q,b.create_fingerprints("TS0049",{"_TZ3290_ixd9mvv4"}))a(o,b.create_fingerprints("TS011F",{"_TZ3000_j0ktmul1"}))k.apply(e)g.attach_reporting_capabilities(e,{{1,"rpt-tlw"},{2,"rpt-tlw"},{3,"rpt-tlw"},{4,"rpt-tlw"},{5,"rpt-tuf"},{6,"rpt-tuf"},{7,"rpt-taq"},{8,"rpt-tgd"},{9,"rpt-tgm",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree",zr000600004="SwitchFour",zr000600005="SwitchFive"}}})return{id="zcl.switches.valves",registrations=e}
