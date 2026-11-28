local o,h=require"protocol.zcl",{_TZ3210_zxbtub8r=true,_TZ3210_cyuyd5az=true,_TZ3210_hzdhb62z=true,_TZ3210_v5yquxma=true,_TZ3210_wdexaypg=true,_TZ3210_tkkb1ym8=true}
local function r(b)
if b.model=="TS110E"then
return h[b.manufacturer]and"on_then_level"or"tuya_level"end
if b.model=="TS1101"or b.model=="TS0052"or
b.manufacturer=="_TYZB01_qezuin6k"or
b.manufacturer=="_TYZB01_v8gtiaed"then return"standard"end
end
local function n(c,_,f,j)
if type(f)~="number"or f~=f or f<0 or f>100 then return false end
local m,e,d=r{manufacturer=c:get_manufacturer(),model=c:get_model()},j.endpoint or 1,math.floor(f*254/100+0.5)
if m=="tuya_level"then
local k=j.component_id or"main"local u=c:get_latest_state(k,"switchLevel","level")if c:get_latest_state(k,"switch","switch")=="off"and
type(u)=="number"and math.abs(d-math.floor(u*254/100+0.5))<=1 then
return o.send_raw_cluster_command(c,6,1,"",e)end
local t=math.floor(f*10+0.5)return o.send_raw_cluster_command(c,8,240,string.pack("<I2I2",t,100),e)end
if m=="on_then_level"and d>1 then
if o.send_raw_cluster_command(c,6,1,"",e)==false then return false end
end
local q=math.max(0,math.min(65535,math.floor(tonumber(j.transition_time)or 0)))return o.send_raw_cluster_command(c,8,4,string.pack("<BI2BB",d,q,0,0),e)
end
local function s(l)
for _,g in ipairs(l)do
local m=r(g.fingerprints[1])if m then
local p={}for i,a in ipairs(g.zcl_clusters)do
if a.name=="brightness"then
if m=="tuya_level"then
g.zcl_clusters[i]=o.tuya_dimmer_level{endpoint=a.endpoint,component=a.component,sender=n}else
if a.attribute_id==61440 then
g.zcl_clusters[i]=o.level{endpoint=a.endpoint,component=a.component,configure_reporting=false,sender=n}else
a.sender=n
end
p[#p+1]=o.tuya_dimmer_level{name="tuya_brightness_report",endpoint=a.endpoint,component=a.component,read_only=true}end
end
end
for _,a in ipairs(p)do g.zcl_clusters[#g.zcl_clusters+1]=a end
end
end
end
return{apply=s}
