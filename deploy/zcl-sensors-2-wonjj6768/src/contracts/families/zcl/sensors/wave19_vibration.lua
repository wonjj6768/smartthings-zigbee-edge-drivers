local s,v,j,o=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.zigbee.data_types"local m,f=j.definition_registry()local a,b,c=90,"__wave19_ts0210_vibration_timer",v.acceleration()

local function g(k)
k.minimum_interval=nil
k.maximum_interval=nil
k.reportable_change=nil
k.read_on_configure=false
return k
end
local function e(i,_,q)
local p=q and q.raw_value or nil
if type(p)=="number"and p>=255 then return nil end
return i
end
local function l(i)
if type(i)~="number"or i%1~=0 or i<0 or i>50 then
return nil
end
return i
end
local function h(d,i)
local n=d:get_field(b)if n~=nil and type(n.cancel)=="function"then
n:cancel()end
d:set_field(b,nil,{persist=false})if a==0 then return end
local r
r=d.thread:call_with_delay(a,function()
if d:get_field(b)~=r then return end
d:set_field(b,nil,{persist=false})local t=c(d,false)if t~=nil then d:emit_event(t)end
end,"wave19 TS0210 vibration clear")
d:set_field(b,r,{persist=false})
end
local u={profile="safety-wave19-tuya-ts0210-quoted",package_group="wave19-vibration",zcl_clusters={g(s.motion{emit=c,handler=h}),g(s.tamper()),g(s.battery{from_device=e}),g(s.battery_voltage{from_device=e}),s.cluster_attribute(1280,19,{name="tuya_ts0210_sensitivity",data_type=o.Uint8,write_type=o.Uint8,write_only=true,to_device=l,numeric_range={minimum=0,maximum=50,step=1}})}}f(u,{j.create_fingerprint("'_TZ32101000000_5oy7cysk'","TS0210")})return{id="zcl.sensors.wave19_vibration",registrations=m}
