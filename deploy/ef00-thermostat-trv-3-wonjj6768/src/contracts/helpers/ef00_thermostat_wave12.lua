local x,ac,B=require"protocol.tuya",require"capabilities.events.all",require"st.capabilities"local g,c=x.converter,{}

function c.custom(a)
return ac[a]()
end
function c.numeric(P,n,a,q,f,e)
e=e or{}local b=e.converter
if b==nil and e.signed==true then
local v=g.signed_number_pair(q or 1)b=v
elseif b==nil and q~=nil and q~=1 then
local t=g.divide_by_pair(q)b=t
end
local r={name=n,read_only=f==true,emit=c.custom(a),converter=b}if e.from_device~=nil then r.from_device=e.from_device end
if e.to_device~=nil then r.to_device=e.to_device end
if e.signed~=nil then r.signed=e.signed end
return x.dp_numeric(P,r)
end
function c.enum(P,n,a,p,f,z)
local U=f==true
and g.from_only(g.lookup_value((function()
local J={}for M,X in pairs(p)do J[X]=M end
return J
end)()))
or g.lookup_from_to(p)local e={name=n,read_only=f==true,converter=U,emit=c.custom(a)}if z==true then
return x.dp_numeric(P,e)end
return x.dp_enum(P,e)
end
function c.binary(P,n,a,p,f)
local U=f==true
and g.from_only(function(o)
for M,X in pairs(p)do
if o==X then return M end
end
return nil
end)
or g.lookup_from_to(p)return x.dp_binary(P,{name=n,read_only=f==true,converter=U,emit=c.custom(a)})
end
function c.raw(P,n,a,K,f)
return x.dp_raw(P,{name=n,converter=K,read_only=f==true,emit=c.custom(a)})
end
function c.schedule_converter(k,h)
local function E(o)
if type(o)~="string"then return nil end
local m={}for A=0,h-1 do
local R=2+A*4
local u,l,V,aa=string.byte(o,R,R+3)if u==nil or l==nil or V==nil or aa==nil then return nil end
m[#m+1]=string.format("%02d:%02d/%.1f",u,l,((V*256)+aa)/10)end
return table.concat(m," ")
end
local function S(o)
if type(o)~="string"then return nil end
local i,L={k or 0},0
for N in string.gmatch(o,"%S+")do
local Q,F,w=N:match"^(%d+):(%d+)/([%d%.%-]+)$"local u,l,j=tonumber(Q),tonumber(F),tonumber(w)if u==nil or l==nil or j==nil
or u<0 or u>24 or l<0 or l>60
or j<5 or j>35 then
return nil
end
local G=math.floor(j*10)i[#i+1]=math.floor(u)i[#i+1]=math.floor(l)i[#i+1]=math.floor(G/256)%256
i[#i+1]=G%256
L=L+1
end
if L~=h then return nil end
return string.char(table.unpack(i))
end
return g.from_to(E,S)
end
function c.add_day_schedules(d,W,s,T,h,y)
local ab={{"monday","Monday"},{"tuesday","Tuesday"},{"wednesday","Wednesday"},{"thursday","Thursday"},{"friday","Friday"},{"saturday","Saturday"},{"sunday","Sunday"}}for A,day in ipairs(ab)do
local k=A
if y==false then k=nil end
d[#d+1]=c.raw(T+A-1,W.."_schedule_"..day[1],s.."Schedule"..day[2],c.schedule_converter(k,h),false)end
end
function c.override_named_writer(d,n,Z)
local C=x.build_named_map(d,"name")C[n]=Z
d.named_mapping={named_mappings=C}
end
function c.attach_setpoint_range(d,I,H,Y)
d.heating_setpoint_range={minimum=I,maximum=H,step=Y,unit="C"}local D=d.runtime_start
d.runtime_start=function(O)
if D~=nil then D(O)end
O:emit_component_event({id="main"},B.thermostatHeatingSetpoint.heatingSetpointRange{value={minimum=I,maximum=H,step=Y},unit="C"})
end
end
return c
