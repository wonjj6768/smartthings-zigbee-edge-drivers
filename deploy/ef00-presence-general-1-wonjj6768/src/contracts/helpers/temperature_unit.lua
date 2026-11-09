local F,z,M=require"protocol.tuya",require"capabilities.events.all",{}
local function i(f)
if f==1 or f=="F"or f=="fahrenheit"then
return"fahrenheit","F",1
end
if f==0 or f=="C"or f=="celsius"then
return"celsius","C",0
end
return nil,nil,nil
end
local function o(a,e,unit)
if unit~=nil and a~=nil and type(a.set_field)=="function"then
a:set_field(e,unit,{persist=true})end
end
function M.handlers(m)
local e=m.field_name
local b,g,C,t,n,q=e .."_pending_temperature",e .."_correction_pending",m.unit_dp or 109,m.capability_id,m.capability_attribute or"temperatureUnit",m.capability_emitter


local function u(a,H)
a:set_field(H,nil,{persist=false})
end
local function x(d)
local A=type(d)=="table"and d.frame or nil
local r=type(A)=="table"and A.datapoints or nil
if type(r)~="table"then return nil end
for _,s in ipairs(r)do
if s.dp==C then
local _,unit=i(s.value)return unit
end
end
return nil
end
local function w(f,a)
local l,h=i(f)if l==nil then return nil end
local c=a:get_field(b)o(a,e,h)a:set_field(g,c~=nil,{persist=false})if not a:get_field(g)then
u(a,b)end
return l
end
local function y(f,a)
local _,_,E=i(f)if E==nil then return nil end
return E
end
local function v(a,f,B,d)
local _,h=i(f)o(a,e,h)local k=q(a,f,B,d)if not a:get_field(g)then return k end
local c=a:get_field(b)u(a,g)u(a,b)if c==nil or h==nil then return k end
if k==nil then
return z.temperature(h)(a,c)end
return{k,z.temperature(h)(a,c)}
end
local function p(a,f,_,d)
if f==nil then return nil end
local unit=x(d)if unit~=nil then
o(a,e,unit)else
unit=a:get_field(e)end
if unit==nil and type(a.get_latest_state)=="function"then
local D=a:get_latest_state("main",t,n)_,unit=i(D)o(a,e,unit)end
if unit==nil then
a:set_field(b,f,{persist=false})return nil
end
u(a,b)return z.temperature(unit)(a,f)
end
return{converter=F.converter.from_to(w,y),unit_emitter=v,temperature_emitter=p}
end
return M
