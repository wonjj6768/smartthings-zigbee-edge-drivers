local p,w,d=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family"local n=p.converter
local i,b=d.definition_registry()
local function f(c)
return type(c)=="table"and type(c.preferences)=="table"and c.preferences.reverse==true
end
local function j()
return n.from_to(
function(e,c)
local a=tonumber(e)if a==nil then return nil end
a=bit32.band(a,255)return f(c)and 100-a or a
end,
function(e,c)
local a=tonumber(e)if a==nil or a<0 or a>100 then return nil end
return f(c)and 100-a or a
end
)
end
local k,l=w.shade_level(),w.shade_state()
local function h(c,e,s,r)
local g={}if e>=0 and e<=100 then
local t=k(c,e,s,r)if t~=nil then g[#g+1]=t end
local q=e==0 and"closed"or(e==100 and"open"or"partially open")local u=l(c,q,s,r)if u~=nil then g[#g+1]=u end
end
return g[1]~=nil and g or nil
end
local function m(v)
local o=j()return{profile=v,package_group="wave19-cover",magic_packet=false,query_on_configure=false,time_start="off",datapoints={p.dp_enum(1,{name="cover_state",write_only=true,converter=n.lookup_from_to{open=0,stop=1,close=2}}),p.dp_numeric(2,{name="cover_position",converter=o,emit=h}),p.dp_numeric(3,{name="cover_arrived",read_only=true,converter=o,emit=h}),p.dp_numeric(105,{name="motor_speed_unexposed",read_only=true})}}
end
b(m"covers-wave19-legacy-tuya",{d.create_fingerprint("_TZE200_swhwv3k3","TS0601")})b(m"covers-wave19-legacy-tuya",{d.create_fingerprint("_TZE200_sbordckq","TS0601")})return{id="ef00.covers.wave19_legacy",registrations=i}
