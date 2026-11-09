local b,c,p,e=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family",require"contracts.helpers.ef00"local d=b.converter
local m,i=p.definition_registry()
local function a(h,j)
if type(h)=="table"then
local r={}for z,v in pairs(h)do
r[z]=v
end
if r.query_on_configure==nil then
r.query_on_configure=true
end
i(r,j)return
end
i({datapoints=h,query_on_configure=true},j)
end
local g,f=1000,100000

local function k()
return d.from_only(function(v)
local q=tonumber(v)if q==nil then
return nil
end
if q>1000 then
return nil
end
return q
end)
end
local A={profile="sensors-aq-co2-temp-humidity-voc-formaldehyde",b.dp_co2(2,{emit=c.co2()}),b.dp_numeric(18,{name="temperature",emit=c.temperature"C",converter=d.tuya_unsigned_temp(10)}),b.dp_humidity(19,{emit=c.humidity(),scale=10}),b.dp_voc(21,{emit=c.voc()}),b.dp_formaldehyde(22,{emit=c.formaldehyde(),scale=g})}a(A,e.ts0601_fingerprints{"_TZE200_8ygsuhe1","_TZE200_yvx5lh6k","_TZE200_c2fmom5z","_TZE204_c2fmom5z","_TZE204_yvx5lh6k"})local o={profile="sensors-aq-co2-temp-humidity-voc-formaldehyde",b.dp_co2(2,{emit=c.co2()}),b.dp_numeric(18,{name="temperature",emit=c.temperature"C",converter=d.divide_by_pair(10)}),b.dp_humidity(19,{emit=c.humidity(),scale=1}),b.dp_voc(21,{emit=c.voc(),scale=100}),b.dp_formaldehyde(22,{emit=c.formaldehyde(),scale=f})}a(o,e.ts0601_fingerprints{"_TZE284_8b9zpaav"})local s={profile="sensors-aq-co2-temp-humidity-voc-formaldehyde",b.dp_co2(2,{emit=c.co2()}),b.dp_numeric(18,{name="temperature",emit=c.temperature"C",converter=d.divide_by_pair(10)}),b.dp_humidity(19,{emit=c.humidity(),scale=10}),b.dp_co2(20,{name="co2_duplicate",emit=c.co2()}),b.dp_voc(21,{emit=c.voc(),scale=100}),b.dp_formaldehyde(22,{emit=c.formaldehyde(),scale=f})}a(s,e.ts0601_fingerprints{"_TZE284_it9utkro"})local x={profile="sensors-aq-pm25-co2-temp-humidity-voc-formaldehyde",b.dp_pm25(2,{emit=c.pm25(),converter=k()}),b.dp_numeric(18,{name="temperature",emit=c.temperature"C",converter=d.tuya_unsigned_temp(10)}),b.dp_humidity(19,{emit=c.humidity(),scale=10}),b.dp_formaldehyde(20,{emit=c.formaldehyde(),scale=g}),b.dp_voc(21,{emit=c.voc()}),b.dp_co2(22,{emit=c.co2()})}a(x,e.ts0601_fingerprints{"_TZE200_dwcarsat","_TZE204_dwcarsat"})local l={profile="sensors-aq-pm25-co2-temp-humidity-voc-formaldehyde",b.dp_pm25(2,{emit=c.pm25()}),b.dp_numeric(18,{name="temperature",emit=c.temperature"C",converter=d.tuya_unsigned_temp(10)}),b.dp_humidity(19,{emit=c.humidity(),scale=10}),b.dp_formaldehyde(20,{emit=c.formaldehyde(),scale=g}),b.dp_voc(21,{emit=c.voc()}),b.dp_co2(22,{emit=c.co2()})}a(l,e.ts0601_fingerprints{"_TZE200_blfcpsxz"})local w={profile="sensors-aq-co2-temp-humidity-voc-formaldehyde",b.dp_formaldehyde(2,{emit=c.formaldehyde(),scale=g}),b.dp_numeric(18,{name="temperature",emit=c.temperature"C",converter=d.tuya_unsigned_temp(10)}),b.dp_humidity(19,{emit=c.humidity(),scale=10}),b.dp_voc(21,{emit=c.voc()}),b.dp_co2(22,{emit=c.co2()})}a(w,e.ts0601_fingerprints{"_TZE200_mja3fuja"})local n={profile="sensors-aq-co2-temp-humidity-voc-formaldehyde",b.dp_formaldehyde(2,{emit=c.formaldehyde(),scale=f}),b.dp_numeric(18,{name="temperature",emit=c.temperature"C",converter=d.tuya_unsigned_temp(10)}),b.dp_humidity(19,{emit=c.humidity(),scale=10}),b.dp_voc(21,{emit=c.voc(),scale=10}),b.dp_co2(22,{emit=c.co2()})}a(n,e.ts0601_fingerprints{"_TZE200_ryfmq5rl"})local y={profile="sensors-aq-co2-temp-humidity",b.dp_co2(2,{emit=c.co2()}),b.dp_numeric(18,{name="temperature",emit=c.temperature"C",converter=d.tuya_unsigned_temp(10)}),b.dp_humidity(19,{emit=c.humidity(),scale=10})}a(y,e.ts0601_fingerprints{"_TZE200_ogkdpgy2","_TZE200_3ejwxpmu","_TZE204_3ejwxpmu"})local u={profile="sensors-aq-co2",b.dp_co2(2,{emit=c.co2()})}a(u,e.ts0601_fingerprints{"_TZE204_ogkdpgy2"})local t={profile="sensors-aq-zr360cdb-co2-temp-humidity",query_on_configure=false,b.dp_enum(1,{name="air_quality",read_only=true,emit=c.zr360cdbAirQuality(),converter=d.from_only(d.lookup_value{[0]="excellent",[1]="moderate",[2]="poor"})}),b.dp_co2(2,{emit=c.co2(),read_only=true}),b.dp_enum(5,{name="alarm_ringtone",emit=c.zr360cdbAlarmRingtone(),converter=d.lookup_from_to{melody_1=0,melody_2=1,OFF=2}}),b.dp_numeric(14,{name="battery_state",read_only=true,emit=c.zr360cdbBatteryState(),converter=d.from_only(d.lookup_value{[0]="low",[1]="medium",[2]="high"})}),b.dp_numeric(17,{name="backlight_mode",emit=c.zr360cdbBacklightMode()}),b.dp_numeric(18,{name="temperature",read_only=true,emit=c.temperature"C",converter=d.signed_number_pair(1)}),b.dp_humidity(19,{emit=c.humidity(),scale=1,read_only=true})}a(t,e.ts0601_fingerprints{"_TZE200_pl31aqf5","_TZE200_xpvamyfz","_TZE284_xpvamyfz"})return{id="ef00.sensors.air_quality",registrations=m}
