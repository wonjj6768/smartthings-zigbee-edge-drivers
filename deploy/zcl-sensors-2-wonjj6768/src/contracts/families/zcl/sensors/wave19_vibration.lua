local s,z,l,t,u,w=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"st.zigbee.data_types",require"protocol.tuya",require"st.capabilities"local m,f=l.definition_registry()local g,d,k=90,"__wave19_ts0210_vibration_timer",z.acceleration()

local function i(o)
o.minimum_interval=nil
o.maximum_interval=nil
o.reportable_change=nil
o.read_on_configure=false
return o
end
local function c(a,_,x)
local v=x and x.raw_value or nil
if type(v)=="number"and v>=255 then return nil end
return a
end
local function p(a)
if type(a)~="number"or a%1~=0 or a<0 or a>50 then
return nil
end
return a
end
local function h(b,a)
local j=b:get_field(d)if j~=nil and type(j.cancel)=="function"then
b.thread:cancel_timer(j)end
b:set_field(d,nil,{persist=false})if g==0 then return end
local y
y=b.thread:call_with_delay(g,function()
if b:get_field(d)~=y then return end
b:set_field(d,nil,{persist=false})local A=k(b,false)if A~=nil then b:emit_event(A)end
end,"wave19 TS0210 vibration clear")
b:set_field(d,y,{persist=false})
end
local B={profile="safety-wave19-tuya-ts0210-quoted",package_group="wave19-vibration",zcl_clusters={i(s.motion{emit=k,handler=h}),i(s.tamper()),i(s.battery{from_device=c}),i(s.battery_voltage{from_device=c}),s.cluster_attribute(1280,19,{name="tuya_ts0210_sensitivity",data_type=t.Uint8,write_type=t.Uint8,write_only=true,to_device=p,numeric_range={minimum=0,maximum=50,step=1}})}}f(B,{l.create_fingerprint("'_TZ32101000000_5oy7cysk'","TS0210")})
local function q(a,_,D)
if D.datatype~=u.DP_TYPE_ENUM or(a~=0 and a~=1 and a~=3)then return nil end
return a~=0
end
local function n(_,a)
return w.accelerationSensor.acceleration({value=a and"active"or"inactive"},{state_change=a==true})
end
local function e(b,a)
if a then return h(b,a)end
local j=b:get_field(d)if j~=nil and type(j.cancel)=="function"then b.thread:cancel_timer(j)end
b:set_field(d,nil,{persist=false})
end
local function r(C)
return u.dp_enum(C,{name="vibration_event_"..tostring(C),endpoint=1,read_only=true,converter=u.converter.from_only(q),handler=e,emit=n})
end
f({profile="safety-tuya-ts0210-ef00",package_group="wave19-vibration",magic_packet=true,query_on_configure=false,zcl_clusters={i(s.motion{endpoint=1,emit=n,handler=e}),i(s.tamper{endpoint=1}),s.battery{endpoint=1,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=10,from_device=c},s.battery_voltage{endpoint=1,read_only=true,configure_reporting=false,read_on_configure=true,from_device=c}},datapoints={u.dp_battery(4,{endpoint=1,emit=z.battery(),read_only=true}),r(101),r(104),u.dp_enum(105,{name="ts0210_ef00_sensitivity",endpoint=1,converter=u.converter.lookup_from_to{low=0,middle=1,high=2},emit=z.ts0210Ef00Sensitivity()})}},{l.create_fingerprint("_TZ32101000000_5oy7cysk","TS0210")})s.attach_reporting_capabilities(m,{{2,"rpt-txh"}})return{id="zcl.sensors.wave19_vibration",registrations=m}
