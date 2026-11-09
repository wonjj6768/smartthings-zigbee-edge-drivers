local f,i,b,l=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.zigbee.device_management"local h,a=b.definition_registry()
local function e(o)
return function(u,r)
for m=1,o do
r:send(l.build_bind_request(r,f.CLUSTER_ON_OFF,u.environment_info.hub_zigbee_eui,m))end
end
end
local function encode_uint32_be(c)
return string.char(math.floor(c/16777216)%256,math.floor(c/65536)%256,math.floor(c/256)%256,c%256)
end
local g={profile="valves-valve-indicator-mode",zcl_clusters={f.switch("valve",{emit=i.valve(),
from_device=function(c)
if c then
return"open"end
return"closed"
end
}),f.indicator_mode(),f.tuya_magic_packet()},configure=e(1)}local k={profile="valves-valve-battery",zcl_clusters={f.switch("valve",{emit=i.valve(),
from_device=function(c)
if c then
return"open"end
return"closed"
end
}),f.battery()}}local p={profile="valves-lyai14-minimal",datapoints={{dp=1,datatype=1,name="valve_report",read_only=true,
from_device=function(c)return c and"open"or"closed"end,emit=i.valve()},
{dp=101,datatype=4,name="lyai_rain_state",read_only=true,
from_device=function(c)return({[0]="rain",[1]="no_rain"})[c]end,emit=i.lyaiRainState()},
{dp=102,datatype=1,name="lyai_rain_enabled",read_only=false,
from_device=function(c)return c and"on"or"off"end,
to_device=function(c)return({on=true,off=false})[c]end,emit=i.lyaiRainEnabled()},
{dp=103,datatype=4,name="lyai_charge_state",read_only=true,
from_device=function(c)return({[0]="no_charge",[1]="charging",[2]="charged"})[c]end,emit=i.lyaiChargeState()}
},zcl_clusters={f.tuya_magic_packet(),f.switch("valve",{emit=i.valve(),
from_device=function(c)
if c then
return"open"end
return"closed"
end
}),f.battery()}}local j={profile="valves-haozee-hz-wt02",zcl_clusters={f.switch("valve",{emit=i.valve(),
from_device=function(c)
if c then
return"open"end
return"closed"
end
}),f.battery(),f.ts0049_countdown_timer{name="haozee_hz_wt02_water_countdown",emit=i.haozeeHzWt02WaterCountdown(),
to_device=function(c)
local t=math.floor(tonumber(c)+0.5)return string.char(11)..encode_uint32_be(t*60)
end,
numeric_range={minimum=1,maximum=1440,step=1,unit="min"}}}}
local function d(m,q)
return f.switch("valve",{endpoint=m,component=q,emit=i.valve(),
from_device=function(c)
if c then
return"open"end
return"closed"
end
})
end
local n={profile="valves-valve-5",zcl_clusters={d(1,"main"),d(2,"valve2"),d(3,"valve3"),d(4,"valve4"),d(5,"valve5"),f.tuya_magic_packet(),f.power_on_behavior(),f.child_lock(),f.countdown_timer()},configure=e(5)}a(g,b.create_fingerprints("TS0111",{"_TYZB01_ymcdbl3u"}))a(g,b.create_fingerprints("TS011F",{"_TZ3000_rk2yzt0u","_TZ3000_o4cjetlm"}))a(g,b.create_fingerprints("TS0001",{"_TZ3000_o4cjetlm","_TZ3000_iedbgyxt","_TZ3000_h3noz0a5","_TYZB01_4tlksk8a","_TZ3000_5ucujjts","_TZ3000_h8ngtlxy","_TZ3000_w0ypwa1f","_TZ3000_wpueorev","_TZ3000_cmcjbqup"}))a(g,b.create_fingerprints("TS0011",{"_TYZB01_rifa0wlb"}))a(k,b.create_fingerprints("TS0049",{"_TZ3000_5af5r192","_TZ3000_cjfmu5he","_TZ3000_mq4wujmp","_TZ3000_ogjpfoyn"}))a(k,{b.create_fingerprint("UHome","TWV")})a(j,b.create_fingerprints("TS0049",{"_TZ3000_kz1anoi8"}))a(p,b.create_fingerprints("TS0049",{"_TZ3290_ixd9mvv4"}))a(n,b.create_fingerprints("TS011F",{"_TZ3000_j0ktmul1"}))f.attach_reporting_capabilities(h,{{1,"rpt-tlw"},{2,"rpt-tlw"},{3,"rpt-tlw"},{4,"rpt-tlw"},{5,"rpt-tuf"},{6,"rpt-tuf"},{7,"rpt-taq"},{8,"rpt-tgd"},{9,"rpt-tgm",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree",zr000600004="SwitchFour",zr000600005="SwitchFive"}}})return{id="zcl.switches.valves",registrations=h}
