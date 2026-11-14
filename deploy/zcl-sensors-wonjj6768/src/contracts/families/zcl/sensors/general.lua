local t,d,v,C,q=require"protocol.zcl",require"contracts.helpers.family",require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.device_management"local h,b=d.definition_registry()
local function a(g)
g=g or{}local m,F=g.humidity_scale,g.profile

local j={t.temperature(),m~=nil and m~=100 and
t.humidity{scale=m}or
t.humidity(),t.battery()}if g.battery_voltage then
j[#j+1]=t.battery_voltage()end
if g.illuminance then
j[#j+1]=t.illuminance()end
if g.tuya_magic then
table.insert(j,1,t.tuya_magic_packet())end
return{profile=F,zcl_clusters=j}
end
local function k(g)
g=g or{}local j={t.illuminance(),t.battery()}if g.tuya_magic then
table.insert(j,1,t.tuya_magic_packet())end
return{profile=g.profile,zcl_clusters=j}
end
local i,c,e,n="sensors-temp-humidity-battery","sensors-temp-humidity-battery-voltage","sensors-illuminance-temp-humidity-battery","sensors-illuminance-battery"
local function p(G,D,z,E,x)
local B={}for H,r in pairs(x or{})do B[r]=H end
return t.cluster_attribute(57346,D,{name=G,endpoint=1,data_type=z,write_type=z,read_on_configure=false,emit=E,
from_device=function(r)
if type(r)=="table"then r=r.value end
if x then return x[r]end
return r
end,
to_device=x and function(r)return B[r]end or nil
})
end
local o=a{profile="sensors-temp-humidity-battery-voltage-kctw1z-pending",humidity_scale=10,battery_voltage=true}o.magic_packet=false
o.query_on_configure=false
o.force_time_updates=true
for _,f in ipairs(o.zcl_clusters)do
f.minimum_interval,f.maximum_interval,f.reportable_change=nil,nil,nil
f.read_on_configure=f.cluster_id==1
if f.attribute_id==33 and f.cluster_id==1 then
f.minimum_interval,f.maximum_interval,f.reportable_change=3600,65000,0
end
end
o.configure=function(A,l)
for _,y in ipairs{1,1026,1029}do
l:send(q.build_bind_request(l,y,A.environment_info.hub_zigbee_eui,1))end
end
o.zcl_clusters[#o.zcl_clusters+1]=p("kctw_display_unit",57355,C.Enum8,v.kctwDisplayUnit(),{[0]="celsius","fahrenheit"})local s=a{profile="sensors-illuminance-temp-humidity-battery-lcz030-pending",illuminance=true,tuya_magic=true}for _,u in ipairs{{"lcz_temp_max",53258,v.lczTempMax"C"},{"lcz_temp_min",53259,v.lczTempMin"C"},{"lcz_humidity_max",53261,v.lczHumidityMax"%"},{"lcz_humidity_min",53262,v.lczHumidityMin"%"}}do
s.zcl_clusters[#s.zcl_clusters+1]=p(u[1],u[2],C.Int16,u[3])end
for _,u in ipairs{{"lcz_temp_alarm",53254,v.lczTempAlarm(),{[0]="below_min_temperature","over_temperature","off"}},{"lcz_humidity_alarm",53263,v.lczHumidityAlarm(),{[0]="below_min_humdity","over_humidity","off"}}}do
local f=p(u[1],u[2],C.Enum8,u[3],u[4])f.read_only=true
s.zcl_clusters[#s.zcl_clusters+1]=f
end
s.configure=function(A,l)
for _,y in ipairs{0,1,1026,1029,57346}do
l:send(q.build_bind_request(l,y,A.environment_info.hub_zigbee_eui,1))end
end
b(a{profile=c,battery_voltage=true},{d.create_fingerprint("LINCUKOO","SZT06")})local w=a{profile=c,battery_voltage=true,tuya_magic=true}
w.runtime_start=function(l)
if l:get_manufacturer()=="_TZ3000_f2bw0b6k"and l:get_model()=="TS0201"then
t.queue_reporting_defaults(l,w,{zr04020000auto={maximum_interval=3600},zr04050000auto={maximum_interval=3600},zr00010021auto={maximum_interval=21600},zr00010020auto={maximum_interval=21600}})end
end
b(w,d.create_fingerprints("TS0201",{"_TZ3210_alxkwn0h","_TZ3000_0s1izerx","_TZ3000_v1w2k9dd","_TZ3000_rdhukkmi","Zbeacon","_TZ3000_lqmvrwa2","_TZ3000_f2bw0b6k","_TZ3000_mxzo5rhf","_TZ3000_1twfmkcc","_TZ3000_fie1dpkm","_TZ3000_bgsigers","_TYZB01_ujfk3xd9","_TZ3000_82ptnsd4","_TZ3000_amqudjr0","_TZ3000_lbtpiody","_TZ3000_rusu2vzb","_TZ3000_zfirri2d","_TZ3000_yujem9ee"}))w=h[#h]b(a{profile=c,battery_voltage=true},{d.create_fingerprint("eWeLink","SNZB-02")})b(a{profile="sensors-temp-humidity-battery-legacy-pending"},{d.create_fingerprint("Zbeacon","TS0202"),d.create_fingerprint("Zbeacon","TS0203")})b(a{profile=i},d.create_fingerprints("SNZB-02",{"_TZ3000_utwgoauk"}))b(a{profile=c,battery_voltage=true,tuya_magic=true},d.create_fingerprints("TY0201",{"_TZ3000_bjawzodf","_TZ3000_zl1kmjqx"}))b(a{profile=c,battery_voltage=true,tuya_magic=true},d.create_fingerprints("TS0201",{"_TZ3000_bguser20","_TZ3000_yd2e749y","_TZ3000_6uzkisv2","_TZ3000_xr3htd96","_TZ3000_fllyghyj","_TZ3000_saiqcn0y","_TZ3000_bjawzodf"}))b(a{profile=c,battery_voltage=true,tuya_magic=true},d.create_fingerprints("TS0201",{"_TZ3000_dowj6gyi","_TZ3000_8ybe88nf","_TZ3000_akqdg6g7","_TZ3000_zl1kmjqx"}))b(a{profile=c,battery_voltage=true},d.create_fingerprints("SM0201",{"_TYZB01_cbiezpds","_TYZB01_zqvwka4k"}))b(a{profile=i},d.create_fingerprints("SM0201",{"_TYZB01_lzrhtcxu"}))b(a{profile=c,battery_voltage=true},d.create_fingerprints("TS0601",{"_TZ3000_kkerjand"}))b(a{profile=c,humidity_scale=10,battery_voltage=true,tuya_magic=true},d.create_fingerprints("TS0201",{"_TZ3210_ncw88jfq","_TZ3000_ywagc4rj","_TZ3000_isw9u95y","_TZ3000_yupc0pb7"}))b(o,d.create_fingerprints("TS0201",{"_TZ3000_itnrsufe"}))b(s,d.create_fingerprints("TS0201",{"_TZ3000_qaaysllp"}))b(a{profile=e,humidity_scale=10,illuminance=true,tuya_magic=true},d.create_fingerprints("TS0222",{"_TZ3000_kky16aay","_TZE204_myd45weu","_TZ3000_ceplrhnu"}))b(a{profile=e,illuminance=true,tuya_magic=true},d.create_fingerprints("TS0222",{"_TZ3000_t9qqxn70"}))b(a{profile=e,illuminance=true},d.create_fingerprints("TS0222",{"_TYZB01_ftdkanlj","_TYZB01_kvwjujy9"}))b(a{profile=e,illuminance=true,tuya_magic=true},d.create_fingerprints("TS0222",{"_TZ3000_ubuikmgo"}))b(a{profile=e,illuminance=true},{d.create_fingerprint("easyiot","ZB-LTH01")})b(a{profile="sensors-illuminance-temp-humidity-battery-konke-pending",illuminance=true,battery_voltage=true},d.create_fingerprints("TS0222",{"_TYZB01_fi5yftwv"}))b(k{profile=n,tuya_magic=true},d.create_fingerprints("TS0222",{"_TZ3000_8uxxzz4b","_TZ3000_9kbbfeho","_TZ3000_l6rsaipj","_TYZB01_4mdqxxnn","_TYZB01_m6ec2pgj","_TZ3000_do6txrcw","_TZ3000_7kscdesh","_TZ3000_hy6ncvmw","_TZ3000_7y90pany","_TZ3000_j6adk9id"}))t.attach_reporting_capabilities(h,{{1,"rpt-sgy"},{2,"rpt-sgy"},{3,"rpt-sgy"},{4,"rpt-tgdf"},{5,"rpt-tgdf"},{6,"rpt-sgy"},{7,"rpt-sgy"},{8,"rpt-sgy"},{9,"rpt-sgy"},{10,"rpt-tgdf"},{11,"rpt-sgy"},{12,"rpt-sgy"},{13,"rpt-thw"},{14,"rpt-tkh"},{15,"rpt-tfe"},{16,"rpt-tfe"},{17,"rpt-tfe"},{18,"rpt-tfe"},{19,"rpt-tfe"},{20,"rpt-tlna"},{21,"rpt-tuh"}})return{id="zcl.sensors.general",registrations=h}
