local f,g,j,l=require"st.capabilities",{},"__energy_meter_offset:","__energy_meter_raw:"
local function normalized_component_id(a)
if type(a)=="string"and a~=""then
return a
end
return"main"
end
local function h(a)
return j..normalized_component_id(a)
end
local function n(a)
return l..normalized_component_id(a)
end
local function i(b,a)
local d=b:get_field(h(a))if type(d)=="number"then
return d
end
return 0
end
function g.apply_report(b,e,a)
if type(e)~="number"or type(b)~="table"or type(b.get_field)~="function"or type(b.set_field)~="function"then
return e
end
a=normalized_component_id(a)b:set_field(n(a),e,{persist=false})local d=i(b,a)if e<d then
b:set_field(h(a),0,{persist=true})return e
end
return e-d
end
function g.handle_reset(_,b,o)
local a=normalized_component_id(o and o.component)local d,m=i(b,a),b:get_field(n(a))if type(m)=="number"then
d=m
else
local k=b:get_latest_state(a,f.energyMeter.ID,f.energyMeter.energy.NAME,0)if type(k)=="number"then
d=d+k
end
end
b:set_field(h(a),d,{persist=true})b:emit_component_event({id=a},f.energyMeter.energy{value=0.0,unit="kWh"})
end
return g
