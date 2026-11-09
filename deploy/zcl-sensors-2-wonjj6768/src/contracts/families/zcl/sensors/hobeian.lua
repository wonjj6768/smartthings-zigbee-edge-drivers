local h,f,d,g=require"protocol.zcl",require"contracts.helpers.family",require"st.capabilities",require"st.zigbee.data_types"local j,n=f.definition_registry()
local function e(u)
return function(c)
if type(c)=="table"then c=c.value end
if type(c)~="number"then return nil end
return bit32.band(c,u)~=0
end
end
local function b(i)
i.minimum_interval=nil
i.maximum_interval=nil
i.reportable_change=nil
i.read_on_configure=false
return i
end
local function a(_,c)
if c then return d.batteryLevel.battery.critical()end
return d.batteryLevel.battery.normal()
end
local function k(c,_,l)
local r=l and l.raw_value or c
if type(r)~="number"or r>=255 then return nil end
return l and c or r/2
end
local t={profile="hobeian-zg222z-water-leak",additional_zcl_profiles={7539},magic_packet=false,zcl_clusters={b(h.water{endpoint=1,read_only=true,from_device=e(1)}),b(h.tamper{endpoint=1,read_only=true,from_device=e(4)}),b(h.battery_low{endpoint=1,read_only=true,from_device=e(8),emit=a}),h.battery{endpoint=1,read_only=true,from_device=k,minimum_interval=3600,maximum_interval=65000,reportable_change=0},h.cluster_attribute(1,62,{name="battery_alarm_state",endpoint=1,data_type=g.Bitmap32,read_only=true,read_on_configure=false,from_device=e(15744015),emit=a})},
parent_refresh=function(m,q)
h.read_named_attribute(m,q.zcl_clusters,"battery",{endpoint=1})
end
}n(t,{f.create_fingerprint("HOBEIAN","ZG-222Z")})local s={profile="hobeian-zg102z-contact",zcl_clusters={b(h.contact{endpoint=1,read_only=true}),b(h.tamper{endpoint=1,read_only=true}),b(h.battery_low{endpoint=1,read_only=true,emit=a}),h.cluster_attribute(1,33,{name="battery_percentage_reporting",endpoint=1,data_type=g.Uint8,read_only=true,read_on_configure=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,
from_device=function()return nil end
}),h.cluster_attribute(1,32,{name="battery_voltage",endpoint=1,data_type=g.Uint8,read_only=true,read_on_configure=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,
emit=function(_,c)
if c==255 then return nil end
local o=math.floor(math.max(0,math.min(100,235-370000/(c*100+1)))+0.5)return{d.battery.battery(o),d.voltageMeasurement.voltage{value=c/10,unit="V"}}
end
}),h.cluster_attribute(1,62,{name="battery_alarm_state",endpoint=1,data_type=g.Bitmap32,read_only=true,from_device=e(15744015),emit=a})},
configure=function(p,m)
h.bind_cluster(m,1,p.environment_info.hub_zigbee_eui,1)
end,
parent_refresh=function()end
}n(s,{f.create_fingerprint("HOBEIAN","ZG-102Z")})h.attach_reporting_capabilities(j,{{1,"rpt-zmq"},{2,"rpt-zpd"}})return{id="zcl.sensors.hobeian",registrations=j}
