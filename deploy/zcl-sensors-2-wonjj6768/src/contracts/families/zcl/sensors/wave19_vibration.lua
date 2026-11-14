local s,v,d,o=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.zigbee.data_types"local m,g=d.definition_registry()local a,b,c=90,"__wave19_ts0210_vibration_timer",v.acceleration()

local function h(k)
k.minimum_interval=nil
k.maximum_interval=nil
k.reportable_change=nil
k.read_on_configure=false
return k
end
local function f(j,_,q)
local p=q and q.raw_value or nil
if type(p)=="number"and p>=255 then return nil end
return j
end
local function l(j)
if type(j)~="number"or j%1~=0 or j<0 or j>50 then
return nil
end
return j
end
local function i(e,j)
local n=e:get_field(b)if n~=nil and type(n.cancel)=="function"then
n:cancel()end
e:set_field(b,nil,{persist=false})if a==0 then return end
local r
r=e.thread:call_with_delay(a,function()
if e:get_field(b)~=r then return end
e:set_field(b,nil,{persist=false})local t=c(e,false)if t~=nil then e:emit_event(t)end
end,"wave19 TS0210 vibration clear")
e:set_field(b,r,{persist=false})
end
local u={profile="safety-wave19-tuya-ts0210-quoted",package_group="wave19-vibration",zcl_clusters={h(s.motion{emit=c,handler=i}),h(s.tamper()),h(s.battery{from_device=f}),h(s.battery_voltage{from_device=f}),s.cluster_attribute(1280,19,{name="tuya_ts0210_sensitivity",data_type=o.Uint8,write_type=o.Uint8,write_only=true,to_device=l,numeric_range={minimum=0,maximum=50,step=1}})}}g(u,{d.create_fingerprint("'_TZ32101000000_5oy7cysk'","TS0210"),d.create_fingerprint("_TZ32101000000_5oy7cysk","TS0210")})return{id="zcl.sensors.wave19_vibration",registrations=m}
