local c,k,d=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family"local a=c.converter
local j,b=d.definition_registry()
local function i(name)
return assert(k[name],"missing Wave13 custom emitter: "..name)()
end
local f,l,g={off=0,["30 minutes"]=1,["60 minutes"]=2,["90 minutes"]=3,["120 minutes"]=4,on=5},k.switch(),i"zbsSixteenSwitchOnTime"
local function h(q,s,o,n)
local e,p={},g(q,s,o,n)if p~=nil then e[#e+1]=p end
local r=l(q,s~="off",o,n)if r~=nil then e[#e+1]=r end
return #e>0 and e or nil
end
local m={profile="switches-wave13-avatto-zbs16",package_group="energy",magic_packet=true,query_on_configure=false,datapoints={c.dp_on_off(1,{name="switch",component="main",emit=k.switch()}),c.dp_numeric(20,{name="energy",read_only=true,converter=a.divide_by_from_only(1000),emit=k.energy()}),c.dp_numeric(21,{name="zbs_sixteen_current_ma",read_only=true,emit=i"zbsSixteenCurrentMa"}),c.dp_numeric(22,{name="power",read_only=true,converter=a.divide_by_from_only(10),emit=k.power()}),c.dp_numeric(23,{name="voltage",read_only=true,converter=a.divide_by_from_only(10),emit=k.voltage()}),c.dp_numeric(101,{name="zbs_sixteen_ac_frequency",read_only=true,converter=a.divide_by_from_only(10),emit=i"zbsSixteenAcFrequency"}),c.dp_enum(102,{name="zbs_sixteen_switch_on_time",converter=a.lookup_from_to(f),emit=h}),c.dp_numeric(103,{name="zbs_sixteen_countdown",emit=i"zbsSixteenCountdown"}),c.dp_numeric(104,{name="zbs_sixteen_total_on_time",read_only=true,emit=i"zbsSixteenTotalOnTime"})}}b(m,d.create_fingerprints("TS0601",{"_TZE284_udaucpdi"}))return{id="ef00.switches.wave13.avatto",registrations=j}
