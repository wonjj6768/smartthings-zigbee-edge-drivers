local e,l,h,g=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family",require"contracts.helpers.ef00_thermostat_wave12"local a=e.converter
local j,f=h.definition_registry()
local function d(name)
return assert(l[name],"missing Wave15 ZTRV emitter: "..name)()
end
local function b(r,name,m,k,i)
i=i or{}return e.dp_numeric(r,{name=name,read_only=i.read_only==true,signed=i.signed==true,transaction=1,converter=i.signed==true
and a.signed_number_pair(k or 1)or(k~=nil and k~=1 and a.divide_by_pair(k)or nil),emit=d(m)})
end
local c={profile="thermostats-wave15-moes-ztrv-s01",package_group="trv",magic_packet=true,query_on_configure=false,time_start="2000",datapoints={e.dp_enum(2,{name="ztrv_preset",transaction=1,converter=a.lookup_from_to{auto=0,manual=1,off=2,on=3},emit=d"ztrvPreset"}),e.dp_numeric(3,{name="running_state",read_only=true,transaction=1,
converter=a.from_only(function(p)
return({[0]="heating",[1]="idle"})[tonumber(p)]
end),
emit=l.thermostat_operating_state()}),e.dp_battery(6,{name="battery",read_only=true,transaction=1,emit=l.battery()}),e.dp_binary(7,{name="ztrv_child_lock",transaction=1,converter=a.lookup_from_to{LOCK=true,UNLOCK=false},emit=d"ztrvChildLock"}),b(9,"ztrv_max_temperature","ztrvMaxTemperature",10),b(10,"ztrv_min_temperature","ztrvMinTemperature",10),e.dp_binary(14,{name="ztrv_window_detection",transaction=1,converter=a.lookup_from_to{ON=true,OFF=false},emit=d"ztrvWindowDetection"}),e.dp_enum(15,{name="ztrv_window_state",read_only=true,transaction=1,converter=a.from_only(a.lookup_value{[0]="CLOSED",[1]="OPENED"}),emit=d"ztrvWindowState"})}}local q={{"monday","Monday"},{"tuesday","Tuesday"},{"wednesday","Wednesday"},{"thursday","Thursday"},{"friday","Friday"},{"saturday","Saturday"},{"sunday","Sunday"}}for o,day in ipairs(q)do
c.datapoints[#c.datapoints+1]=e.dp_raw(27+o,{name="ztrv_schedule_"..day[1],transaction=1,converter=g.schedule_converter(o,4),emit=d("ztrvSchedule"..day[2])})end
c.datapoints[#c.datapoints+1]=e.dp_binary(36,{name="ztrv_frost_protection",transaction=1,converter=a.lookup_from_to{ON=true,OFF=false},emit=d"ztrvFrostProtection"})c.datapoints[#c.datapoints+1]=b(47,"ztrv_temp_calibration","ztrvTempCalibration",10,{signed=true})c.datapoints[#c.datapoints+1]=b(102,"ztrv_valve_position","ztrvValvePosition",1,{read_only=true})c.datapoints[#c.datapoints+1]=e.dp_enum(103,{name="ztrv_screen_orientation",transaction=1,converter=a.lookup_from_to{["0"]=0,["1"]=1},emit=d"ztrvScreenOrientation"})c.datapoints[#c.datapoints+1]=b(105,"ztrv_eco_temperature","ztrvEcoTemperature",10)c.datapoints[#c.datapoints+1]=e.dp_binary(106,{name="ztrv_eco_mode",transaction=1,converter=a.lookup_from_to{ON=true,OFF=false},emit=d"ztrvEcoMode"})c.datapoints[#c.datapoints+1]=e.dp_numeric(108,{name="current_heating_setpoint",transaction=1,converter=a.divide_by_pair(10),emit=l.heating_setpoint"C"})c.datapoints[#c.datapoints+1]=e.dp_numeric(109,{name="local_temperature",read_only=true,transaction=1,converter=a.divide_by_pair(10),emit=l.temperature"C"})g.attach_setpoint_range(c,5,35,0.5)f(c,h.create_fingerprints("TS0601",{"_TZE200_ivdc0kwl"}))return{id="ef00.thermostats.wave15_trv",registrations=j}
