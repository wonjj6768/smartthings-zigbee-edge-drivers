local v,a=require"protocol.tuya",{}
function a.valve_position_to_running_state(b)
local e=tonumber(b)if e==nil then
return nil
end
if e>0 then
return"heating"end
return"idle"
end
function a.variant1_mode_from_device(b)
local j={[0]="auto",[1]="heat",[2]="off",[3]="heat"}return j[tonumber(b)]
end
function a.variant1_mode_to_device(b)
local j={auto=0,heat=1,off=2}return j[b]
end
function a.power_mode_from_device(k,l,t)
return function(b,h)
local C=b==true
h:set_field(k,C,{persist=false})if not C then
return"off"end
return h:get_field(l)or t
end
end
function a.enum_mode_from_device(k,l,j)
return function(b,h)
local p=j[tonumber(b)]if p==nil then
return nil
end
h:set_field(l,p,{persist=false})if h:get_field(k)==false then
return"off"end
return p
end
end
function a.power_mode_write(m,D,j)
return function(_,b)
if b=="off"then
return{{dp=m,datatype=v.DP_TYPE_BOOL,value=false}}end
local p=j[b]if p==nil then
return nil
end
return{{dp=m,datatype=v.DP_TYPE_BOOL,value=true},{dp=D,datatype=v.DP_TYPE_ENUM,value=p}}
end
end
function a.binary_power_schedule_mode_write(m,x)
return function(_,b)
if b~="off"and b~="heat"and b~="auto"then
return nil
end
return{{dp=m,datatype=v.DP_TYPE_BOOL,value=b~="off"},{dp=x,datatype=v.DP_TYPE_BOOL,value=b=="auto"}}
end
end
function a.true_mode_from_device(p)
return function(b)
if b then
return p
end
return nil
end
end
function a.boolean_label_from_device(w,B)
return function(b)
if b then
return B
end
return w
end
end
function a.x5h_local_temperature_from_device(b)
local e=tonumber(b)if e==nil then
return nil
end
if e>=32768 then
e=e-65536+1
end
return e/10
end
local function i(b)
local e=tonumber(b)if e==nil or e%1~=0 or e<0 or e>0xFFFFFFFF then
return nil
end
return e
end
function a.error_or_battery_low_emitter(s,r)
return function(h,b,...)
local o={}if b.error~=nil and b.error<=255 then
local q=s(h,b.error,...)if q~=nil then o[#o+1]=q end
end
local n=r(h,b.battery_low,...)if n~=nil then o[#o+1]=n end
return o
end
end
function a.error_or_battery_low_state(b)
local e=i(b)if e==nil then
return nil
end
return e==1 and"low"or"normal"
end
function a.daily_schedule(E,z)
return{
from=function(b)
if type(b)~="string"or #b<1+z*4 then return nil end
local d={}for A=0,z-1 do
local g,f,temperature=string.unpack(">BBI2",b,2+A*4)d[#d+1]=string.format("%02d:%02d/%.1f",g,f,temperature/10)end
return table.concat(d," ")
end,
to=function(b)
if type(b)~="string"then return nil end
local d={string.char(E)}for u in b:gmatch"%S+"do
local g,f,temperature=u:match"^(%d+):(%d+)/(%d+%.?%d*)$"g,f,temperature=tonumber(g),tonumber(f),tonumber(temperature)if not g or not f or not temperature then return nil end
temperature=math.floor(temperature*10)if g>24 or f>60 or temperature<50 or temperature>350 then return nil end
d[#d+1]=string.pack(">BBI2",g,f,temperature)end
if #d~=z+1 then return nil end
return table.concat(d)
end
}
end
function a.saswell_schedule(E)
return{
from=function(b)
if type(b)~="string"or #b~=17 then return nil end
local d={}for A=0,3 do
local y,temperature=string.unpack(">I2I2",b,2+A*4)d[#d+1]=string.format("%02d:%02d/%.1f",y//60,y%60,temperature/10)end
return table.concat(d," ")
end,
to=function(b)
local d={}for u in b:gmatch"%S+"do
local g,f,temperature=u:match"^(%d%d?):(%d%d)/(%d+%.?%d*)$"g,f,temperature=tonumber(g),tonumber(f),tonumber(temperature)if not g or not f or not temperature or g>23 or f>59 or temperature>6553.5 then return nil end
d[#d+1]=string.pack(">I2I2",g*60+f,math.floor(temperature*10))end
if #d<1 or #d>4 then return nil end
while #d<4 do d[#d+1]=d[#d]end
return string.char(1<<E,4)..table.concat(d)
end
}
end
return a
