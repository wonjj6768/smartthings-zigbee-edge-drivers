local p,r,e=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family"local g=p.converter
local m,a=e.definition_registry()
local function q(name)
return assert(r[name],"missing Wave15 cover emitter: "..name)()
end
local function i(c)
return type(c)=="table"and type(c.preferences)=="table"and c.preferences.reverse==true
end
local function h()
return g.from_to(
function(d,c)
local f=tonumber(d)if f==nil then return nil end
return i(c)and 100-f or f
end,
function(d,c)
local f=tonumber(d)if f==nil then return nil end
return i(c)and 100-f or f
end
)
end
local function b()
return g.from_to(
function(d)
return({[0]="open",[1]="paused",[2]="closed"})[tonumber(d)]
end,
function(d)
return({open=0,stop=1,pause=1,close=2})[d]
end
)
end
local n,o=r.shade_level(),r.shade_state()
local function l(c,d,u,t)
local j,v={},n(c,d,u,t)if v~=nil then j[#j+1]=v end
local s=d<=0 and"closed"or(d>=100 and"open"or"partially open")local x=o(c,s,u,t)if x~=nil then j[#j+1]=x end
return #j>0 and j or nil
end
local y={profile="covers-wave15-box-erc2206z",package_group="rf-roller-shutter",magic_packet=true,query_on_configure=false,time_start="off",datapoints={p.dp_enum(1,{name="cover_state",transaction=1,converter=b(),emit=r.shade_state()}),p.dp_enum(5,{name="erc_six_direction",transaction=1,converter=g.lookup_from_to{forward=0,back=1},emit=q"ercSixDirection"}),p.dp_binary(101,{name="erc_six_record_rf",transaction=1,converter=g.lookup_from_to{record=true,stop=false},emit=q"ercSixRecordRf"}),p.dp_binary(102,{name="erc_six_clear_rf",transaction=1,converter=g.lookup_from_to{clear=true,stop=false},emit=q"ercSixClearRf"})}}a(y,e.create_fingerprints("TS0601",{"_TZE200_ra6wrlgv"}))local k={profile="covers-wave15-tuya-semicom-three",package_group="cover-panel",magic_packet=true,query_on_configure=false,time_start="off",datapoints={}}for _,w in ipairs{{1,2,"main"},{4,5,"cover2"},{101,102,"cover3"}}do
k.datapoints[#k.datapoints+1]=p.dp_enum(w[1],{name="cover_state",component=w[3],transaction=1,converter=b(),emit=r.shade_state()})k.datapoints[#k.datapoints+1]=p.dp_numeric(w[2],{name="cover_position",component=w[3],transaction=1,converter=h(),emit=l})end
a(k,e.create_fingerprints("TS0601",{"_TZE204_7lb6j8wg"}))return{id="ef00.covers.wave15",registrations=m}
