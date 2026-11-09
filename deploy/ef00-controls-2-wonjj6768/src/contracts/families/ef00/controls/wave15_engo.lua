local f,m,g=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family"local a=f.converter
local h,e=g.definition_registry()
local function d(name)
return assert(m[name],"missing Wave15 ENGO emitter: "..name)()
end
local b,i={profile="controls-wave15-engo-ecb62zb",package_group="heating-control-box",magic_packet=true,query_on_configure=false,time_start="2000",datapoints={}},{"One","Two","Three","Four","Five","Six"}for j,word in ipairs(i)do
b.datapoints[#b.datapoints+1]=f.dp_binary(j,{name="ecb_zone_"..string.lower(word).."_demand",read_only=true,transaction=1,
converter=a.from_only(function(c)return c and"ON"or"OFF"end),
emit=d("ecbZone"..word .."Demand")})end
b.datapoints[#b.datapoints+1]=f.dp_binary(101,{name="ecb_pump_state",read_only=true,transaction=1,
converter=a.from_only(function(c)return c and"ON"or"OFF"end),
emit=d"ecbPumpState"})b.datapoints[#b.datapoints+1]=f.dp_binary(102,{name="ecb_boiler_state",read_only=true,transaction=1,
converter=a.from_only(function(c)return c and"ON"or"OFF"end),
emit=d"ecbBoilerState"})b.datapoints[#b.datapoints+1]=f.dp_binary(103,{name="ecb_zone_a_demand",read_only=true,transaction=1,
converter=a.from_only(function(c)return c and"ON"or"OFF"end),
emit=d"ecbZoneADemand"})b.datapoints[#b.datapoints+1]=f.dp_binary(104,{name="ecb_zone_b_demand",read_only=true,transaction=1,
converter=a.from_only(function(c)return c and"ON"or"OFF"end),
emit=d"ecbZoneBDemand"})for j,word in ipairs(i)do
b.datapoints[#b.datapoints+1]=f.dp_binary(104+j,{name="ecb_zone_"..string.lower(word).."_linked",read_only=true,transaction=1,
converter=a.from_only(function(c)return c and"ON"or"OFF"end),
emit=d("ecbZone"..word .."Linked")})end
local k={{111,"a","A"},{112,"b","B"},{113,"one","One"},{114,"two","Two"},{115,"three","Three"},{116,"four","Four"},{117,"five","Five"},{118,"six","Six"}}for _,row in ipairs(k)do
b.datapoints[#b.datapoints+1]=f.dp_string(row[1],{name="ecb_zone_"..row[2].."_name",transaction=1,emit=d("ecbZone"..row[3].."Name")})end
b.datapoints[#b.datapoints+1]=f.dp_enum(119,{name="ecb_pump_delay_time",transaction=1,converter=a.lookup_from_to{OFF=0,["3_min"]=1,["5_min"]=2,["15_min"]=3},emit=d"ecbPumpDelay"})b.datapoints[#b.datapoints+1]=f.dp_numeric(120,{name="voltage",read_only=true,transaction=1,converter=a.divide_by_pair(10),emit=m.voltage()})e(b,g.create_fingerprints("TS0601",{"_TZE200_oahqgdig","_TZE200_zaabefnt"}))return{id="ef00.controls.wave15_engo",registrations=h}
