local g,i,l=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family"local b=g.converter
local h,d=l.definition_registry()local m,e,a=b.lookup_from_to{test=true,idle=false},b.from_only(b.lookup_value{[0]="low",[1]="medium",[2]="high"}),i.nousETwelveWarmingUp()
local function k(j,c,n,f)
local p=c==true
if p then
j.thread:call_with_delay(120,function()
local q=a(j,"off",n,f)if q~=nil then
j:emit_event(q)end
end,"Nous E12 warming-up reset")
end
return a(j,p and"on"or"off",n,f)
end
local o={profile="safety-co-nous-e12",query_on_configure=false,time_start="off",initial_custom_state_query=false,refresh_state_query=false,g.dp_enum(1,{name="carbon_monoxide",read_only=true,emit=i.carbon_monoxide(),
converter=b.from_only(function(c)
return type(c)=="number"and c==0
end)
}),g.dp_numeric(2,{name="carbon_monoxide_value",read_only=true,emit=i.carbon_monoxide_level()}),g.dp_binary(8,{name="nous_e_twelve_test",emit=i.nousETwelveTest(),converter=m}),g.dp_enum(9,{name="nous_e_twelve_testing",read_only=true,emit=i.nousETwelveTesting(),
converter=b.from_only(function(c)
return type(c)=="number"and c==0 and"on"or"off"
end)
}),g.dp_binary(10,{name="nous_e_twelve_warming_up",read_only=true,emit=k}),g.dp_bitmap(11,{name="fault",read_only=true,emit=i.hardware_fault(),
converter=b.from_only(function(c)
return(tonumber(c)or 0)~=0
end)
}),g.dp_binary(12,{name="nous_e_twelve_end_of_life",read_only=true,emit=i.nousETwelveEndOfLife(),
converter=b.from_only(function(c)
return c==false and"on"or"off"
end)
}),g.dp_numeric(14,{name="nous_e_twelve_battery_state",read_only=true,emit=i.nousETwelveBatteryState(),converter=e})}d(o,{{manufacturer="_TZE284_sonkaxrd",model="TS0601"}})return{id="nous.e12",registrations=h}
