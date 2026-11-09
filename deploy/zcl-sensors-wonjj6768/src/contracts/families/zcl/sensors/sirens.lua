local k,C,c,e,s=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.zigbee.data_types",require"st.zigbee.device_management"local j,a=c.definition_registry()local b,d,f=1282,0,2


local function w(g,v,u)
if g<v then
return v
end
if g>u then
return u
end
return g
end
local function m(g,l,q,p,y)
if type(g)~="number"then
return nil
end
if l==q then
return p
end
local D=(g-l)/(q-l)return p+((y-p)*D)
end
local function h(g)
if type(g)~="number"then
return g
end
local r=m(g,100,10,0,100)if r==nil then
return nil
end
return math.floor(w(r,0,100)+0.5)
end
local function i(g)
if type(g)~="number"then
return g
end
local r=m(w(g,0,100),0,100,100,10)if r==nil then
return nil
end
return math.floor(w(r,10,100)+0.5)
end
local A,o,n={profile="safety-alarm-battery-volume",zcl_clusters={k.alarm(),k.battery(),k.cluster_attribute(b,f,{name="volume",emit=C.audio_volume(),from_device=h,to_device=i,data_type=e.Uint8,write_type=e.Uint8,read_on_configure=true})}},{profile="safety-alarm-volume",zcl_clusters={k.alarm(),k.cluster_attribute(b,f,{name="volume",emit=C.audio_volume(),from_device=h,to_device=i,data_type=e.Uint8,write_type=e.Uint8,read_on_configure=true})}},{profile="safety-alarm-battery",zcl_clusters={k.alarm(),k.battery(),k.cluster_attribute(b,d,{name="max_duration",data_type=e.Uint16,write_type=e.Uint16,read_on_configure=true})}}local t={profile="safety-siren-frient-sirzb112",zcl_clusters={k.switch{endpoint=43,component="main"},k.alarm_1_or_2{endpoint=43},k.tamper{endpoint=43},k.battery_low{endpoint=43},k.battery{endpoint=43},k.cluster_attribute(b,d,{name="max_duration",endpoint=43,data_type=e.Uint16,write_type=e.Uint16,read_on_configure=true})},
configure=function(B,z)
for _,x in ipairs{k.CLUSTER_ON_OFF,k.CLUSTER_POWER_CONFIGURATION}do
z:send(s.build_bind_request(z,x,B.environment_info.hub_zigbee_eui,43))end
end
}a(A,c.create_fingerprints("TS0219",{"_TYZB01_bwsijaty","_TYZB01_rs7ff6o7","_TYZB01_ynsiasng"}))a(o,c.create_fingerprints("TS0219",{"_TZ3000_vdfwjopk"}))a(n,c.create_fingerprints("TS0216",{"_TYZB01_4obovpbi","_TYZB01_8scntis1","_TYZB01_sbpc1zrb"}))a(n,{c.create_fingerprint("AduroSmart Eria","Smart Siren"),c.create_fingerprint("Heiman","WarningDevice")})a(t,{c.create_fingerprint("frient A/S","SIRZB-112")})k.attach_reporting_capabilities(j,{{1,"rpt-tbv"},{2,"rpt-tkjy"},{3,"rpt-tiuv"},{4,"rpt-tiuv"},{5,"rpt-swk"}})return{id="zcl.sensors.sirens",registrations=j}
